--------------------------------------------------------
--  DDL for Package Body INV_TXN_MANAGER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TXN_MANAGER_GRP" AS
/* $Header: INVTXGGB.pls 120.72.12010000.54 2012/01/12 12:00:20 sadibhat ship $ */

--------------------------------------------------
-- Private Procedures and Functions
--------------------------------------------------

/** Following portion of the code is the common objects DECLARATION/DEFINITION
    that are used in the Package **/

l_error_code         VARCHAR2(3000);
l_error_exp          VARCHAR2(3000);
l_debug              number := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
l_acctid_validated   BOOLEAN := FALSE ; --Bug#4247753. Added this variable
                                       --to indicate if 'validate_acctid' has
                                       --already been called in 'GETACCTID'
g_pkg_name    VARCHAR2(80) ;
g_lot_ser_attr_tbl   inv_lot_sel_attr.lot_sel_attributes_tbl_type;
g_select_stmt LONG :=
 'SELECT NVL(MSNI.SERIAL_ATTRIBUTE_CATEGORY,
      MSN.SERIAL_ATTRIBUTE_CATEGORY),
  NVL(MSNI.C_ATTRIBUTE1,
      MSN.C_ATTRIBUTE1),
  NVL(MSNI.C_ATTRIBUTE2,
      MSN.C_ATTRIBUTE2),
  NVL(MSNI.C_ATTRIBUTE3,
      MSN.C_ATTRIBUTE3),
  NVL(MSNI.C_ATTRIBUTE4,
      MSN.C_ATTRIBUTE4),
  NVL(MSNI.C_ATTRIBUTE5,
      MSN.C_ATTRIBUTE5),
  NVL(MSNI.C_ATTRIBUTE6,
      MSN.C_ATTRIBUTE6),
  NVL(MSNI.C_ATTRIBUTE7,
      MSN.C_ATTRIBUTE7),
  NVL(MSNI.C_ATTRIBUTE8,
      MSN.C_ATTRIBUTE8),
  NVL(MSNI.C_ATTRIBUTE9,
      MSN.C_ATTRIBUTE9),
  NVL(MSNI.C_ATTRIBUTE10,
      MSN.C_ATTRIBUTE10),
  NVL(MSNI.C_ATTRIBUTE11,
      MSN.C_ATTRIBUTE11),
  NVL(MSNI.C_ATTRIBUTE12,
      MSN.C_ATTRIBUTE12),
  NVL(MSNI.C_ATTRIBUTE13,
      MSN.C_ATTRIBUTE13),
  NVL(MSNI.C_ATTRIBUTE14,
      MSN.C_ATTRIBUTE14),
  NVL(MSNI.C_ATTRIBUTE15,
      MSN.C_ATTRIBUTE15),
  NVL(MSNI.C_ATTRIBUTE16,
      MSN.C_ATTRIBUTE16),
  NVL(MSNI.C_ATTRIBUTE17,
      MSN.C_ATTRIBUTE17),
  NVL(MSNI.C_ATTRIBUTE18,
      MSN.C_ATTRIBUTE18),
  NVL(MSNI.C_ATTRIBUTE19,
      MSN.C_ATTRIBUTE19),
  NVL(MSNI.C_ATTRIBUTE20,
      MSN.C_ATTRIBUTE20),
  NVL(MSNI.D_ATTRIBUTE1,
      MSN.D_ATTRIBUTE1),
  NVL(MSNI.D_ATTRIBUTE2,
      MSN.D_ATTRIBUTE2),
  NVL(MSNI.D_ATTRIBUTE3,
      MSN.D_ATTRIBUTE3),
  NVL(MSNI.D_ATTRIBUTE4,
      MSN.D_ATTRIBUTE4),
  NVL(MSNI.D_ATTRIBUTE5,
      MSN.D_ATTRIBUTE5),
  NVL(MSNI.D_ATTRIBUTE6,
      MSN.D_ATTRIBUTE6),
  NVL(MSNI.D_ATTRIBUTE7,
      MSN.D_ATTRIBUTE7),
  NVL(MSNI.D_ATTRIBUTE8,
      MSN.D_ATTRIBUTE8),
  NVL(MSNI.D_ATTRIBUTE9,
      MSN.D_ATTRIBUTE9),
  NVL(MSNI.D_ATTRIBUTE10,
      MSN.D_ATTRIBUTE10),
  NVL(MSNI.N_ATTRIBUTE1,
      MSN.N_ATTRIBUTE1),
  NVL(MSNI.N_ATTRIBUTE2,
      MSN.N_ATTRIBUTE2),
  NVL(MSNI.N_ATTRIBUTE3,
      MSN.N_ATTRIBUTE3),
  NVL(MSNI.N_ATTRIBUTE4,
      MSN.N_ATTRIBUTE4),
  NVL(MSNI.N_ATTRIBUTE5,
      MSN.N_ATTRIBUTE5),
  NVL(MSNI.N_ATTRIBUTE6,
      MSN.N_ATTRIBUTE6),
  NVL(MSNI.N_ATTRIBUTE7,
      MSN.N_ATTRIBUTE7),
  NVL(MSNI.N_ATTRIBUTE8,
      MSN.N_ATTRIBUTE8),
  NVL(MSNI.N_ATTRIBUTE9,
      MSN.N_ATTRIBUTE9),
  NVL(MSNI.N_ATTRIBUTE10,
      MSN.N_ATTRIBUTE10),
  NVL(MSNI.TERRITORY_CODE,
      MSN.TERRITORY_CODE),
  NVL(MSNI.TIME_SINCE_NEW,
      MSN.TIME_SINCE_NEW),
  NVL(MSNI.CYCLES_SINCE_NEW,
      MSN.CYCLES_SINCE_NEW),
  NVL(MSNI.TIME_SINCE_OVERHAUL,
      MSN.TIME_SINCE_OVERHAUL),
  NVL(MSNI.CYCLES_SINCE_OVERHAUL,
      MSN.CYCLES_SINCE_OVERHAUL),
  NVL(MSNI.TIME_SINCE_REPAIR,
      MSN.TIME_SINCE_REPAIR),
  NVL(MSNI.CYCLES_SINCE_REPAIR,
      MSN.CYCLES_SINCE_REPAIR),
  NVL(MSNI.TIME_SINCE_VISIT,
      MSN.TIME_SINCE_VISIT),
  NVL(MSNI.CYCLES_SINCE_VISIT,
      MSN.CYCLES_SINCE_VISIT),
  NVL(MSNI.TIME_SINCE_MARK,
      MSN.TIME_SINCE_MARK),
  NVL(MSNI.CYCLES_SINCE_MARK,
      MSN.CYCLES_SINCE_MARK),
  NVL(MSNI.NUMBER_OF_REPAIRS,
      MSN.NUMBER_OF_REPAIRS),
  NVL(MSNI.ATTRIBUTE_CATEGORY,
      MSN.ATTRIBUTE_CATEGORY),
  NVL(MSNI.ATTRIBUTE1,
      MSN.ATTRIBUTE1),
  NVL(MSNI.ATTRIBUTE2,
      MSN.ATTRIBUTE2),
  NVL(MSNI.ATTRIBUTE3,
      MSN.ATTRIBUTE3),
  NVL(MSNI.ATTRIBUTE4,
      MSN.ATTRIBUTE4),
  NVL(MSNI.ATTRIBUTE5,
      MSN.ATTRIBUTE5),
  NVL(MSNI.ATTRIBUTE6,
      MSN.ATTRIBUTE6),
  NVL(MSNI.ATTRIBUTE7,
      MSN.ATTRIBUTE7),
  NVL(MSNI.ATTRIBUTE8,
      MSN.ATTRIBUTE8),
  NVL(MSNI.ATTRIBUTE9,
      MSN.ATTRIBUTE9),
  NVL(MSNI.ATTRIBUTE10,
      MSN.ATTRIBUTE10),
  NVL(MSNI.ATTRIBUTE11,
      MSN.ATTRIBUTE11),
  NVL(MSNI.ATTRIBUTE12,
      MSN.ATTRIBUTE12),
  NVL(MSNI.ATTRIBUTE13,
      MSN.ATTRIBUTE13),
  NVL(MSNI.ATTRIBUTE14,
      MSN.ATTRIBUTE14),
  NVL(MSNI.ATTRIBUTE15,
      MSN.ATTRIBUTE15)
FROM
  MTL_SERIAL_NUMBERS_INTERFACE MSNI,
  MTL_SERIAL_NUMBERS MSN
WHERE
  MSNI.TRANSACTION_INTERFACE_ID = :B_PARENT_ID   AND
  MSNI.FM_SERIAL_NUMBER = :B_FM_SERIAL_NUMBER   AND
  MSNI.TO_SERIAL_NUMBER = :B_TO_SERIAL_NUMBER   AND
  MSN.SERIAL_NUMBER = :B_SERIAL_NUMBER   AND
  MSN.INVENTORY_ITEM_ID = :B_ITEM_ID    AND
  MSN.CURRENT_ORGANIZATION_ID = :B_ORG_ID';

lg_ret_sts_error         CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
lg_ret_sts_unexp_error   CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
lg_ret_sts_success       CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;

lg_exc_error             EXCEPTION  ; --fnd_api.g_exc_error;
lg_exc_unexpected_error  EXCEPTION  ; --fnd_api.g_exc_unexpected_error;


TYPE seg_rec_type IS RECORD
   (colname    varchar2(30),
    colvalue   varchar2(150));
TYPE bool_array IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;


client_info_org_id NUMBER := -1;
pjm_installed NUMBER := -1;

TS_DEFAULT    NUMBER := 1;
TS_SAVE_ONLY  NUMBER := 2;
TS_PROCESS    NUMBER := 3;
SALORDER      NUMBER := 2;
INTORDER      NUMBER := 8;
MDS_RELIEF    NUMBER := 1;
MPS_RELIEF    NUMBER := 2;

R_WORK_ORDER  NUMBER := 1;
R_PURCH_ORDER NUMBER := 2;
R_SALES_ORDER NUMBER := 3;
TO_BE_PROCESSED NUMBER := 2;
NOT_TO_BE_PROCESSED NUMBER := 1;

g_true        NUMBER := 1;
g_false       NUMBER := 0;

g_create_loc_at NUMBER; --Bug#5044059


/*FUNCTION getitemid( itemid OUT nocopy NUMBER, orgid IN NUMBER, rowid VARCHAR2);
FUNCTION getacctid( acct OUT nocopy NUMBER, orgid IN NUMBER, rowid VARCHAR2);
FUNCTION setorgclientinfo(orgid IN NUMBER);
FUNCTION getlocid(locid OUT nocopy NUMBER, orgid IN NUMBER, subinv NUMBER,
                        rowid VARCHAR2, locctrl NUMBER);
FUNCTION getxlocid(locid OUT nocopy NUMBER, orgid IN NUMBER, subinv IN VARCHAR2,
                        rowid IN VARCHAR2, locctrl IN NUMBER);
FUNCTION getsrcid(trxsrc OUT nocopy NUMBER, srctype IN NUMBER, orgid IN NUMBER,
                        rowid IN VARCHAR2);
PROCEDURE errupdate(p_rowid IN VARCHAR2, lot_rowid IN VARCHAR2 DEFAULT NULL);
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


TYPE seg_arr_type IS TABLE OF seg_rec_type INDEX BY BINARY_INTEGER;

--TYPE segment_array IS TABLE OF segment_rec_type INDEX BY BINARY_INTEGER;

TYPE segment_array IS TABLE OF VARCHAR2(200);


/******************************************************************
 *
 * loaderrmsg
 *
 ******************************************************************/
PROCEDURE mydebug( p_msg        IN        VARCHAR2
                  ,p_module     IN        VARCHAR2 DEFAULT NULL)
IS
BEGIN

inv_log_util.trace( p_message => p_msg,
p_module  => g_pkg_name ||'.'||p_module ,
p_level => 9);

--dbms_output.put_line( p_msg );
END mydebug;

PROCEDURE validate_derive_object_details  -- R12 Genealogy Enhancements  - New Procedure
( p_org_id              IN   NUMBER
, p_object_type         IN   NUMBER
, p_object_id           IN   NUMBER
, p_object_number       IN   VARCHAR2
, p_item_id             IN   NUMBER
, p_object_type2        IN   NUMBER
, p_object_id2          IN   NUMBER
, p_object_number2      IN   VARCHAR2
, p_serctrl             IN   NUMBER
, p_lotctrl             IN   NUMBER
, p_rowid               IN  rowid
, p_table               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE validate_serial_genealogy_data-- R12 Genealogy Enhancements  - New Procedure
( p_interface_id        IN    NUMBER
, p_org_id              IN    NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE loaderrmsg(mesg1 IN VARCHAR2, mesg2 IN VARCHAR2) IS
BEGIN
      fnd_message.set_name('INV', mesg1);
      l_error_code := fnd_message.get;

      fnd_message.set_name('INV', mesg2);
      l_error_exp := fnd_message.get;
END;



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
 *******************************************************************/
Function Check_Partial_Split(
    p_parent_id         IN NUMBER,
    p_current_index     IN NUMBER
) RETURN boolean
IS
    cursor mti_csr(p_interface_id NUMBER) IS
       select mti.transaction_header_id,
         mti.acct_period_id,
         mti.distribution_account_id,
         mti.transaction_interface_id,
         mti.transaction_Type_id,
         mti.inventory_item_id,
         mti.revision,
         mti.organization_id,
         mti.subinventory_code,
         mti.locator_id,
         mti.transaction_quantity,
         mti.primary_quantity,
         mti.transaction_uom,
         mti.lpn_id,
         mti.transfer_lpn_id,
         mti.cost_group_id,
         mti.transaction_source_type_id,
         mti.transaction_Action_id,
         mti.parent_id,
         mti.created_by,
         mtli.lot_number,
         mtli.lot_expiration_date,
         mtli.description,
         mtli.vendor_id,
         mtli.supplier_lot_number,
         mtli.territory_code,
         mtli.grade_code,
         mtli.origination_date,
         mtli.date_code,
         mtli.status_id,
         mtli.change_date,
         mtli.age,
         mtli.retest_date,
         mtli.maturity_date,
         mtli.lot_attribute_category,
         mtli.item_size,
         mtli.color,
         mtli.volume,
         mtli.volume_uom,
         mtli.place_of_origin,
         mtli.best_by_date,
         mtli.length,
         mtli.length_uom,
         mtli.recycled_content,
         mtli.thickness,
         mtli.thickness_uom,
         mtli.width,
         mtli.width_uom,
         mtli.curl_wrinkle_fold,
         mtli.c_attribute1,
         mtli.c_Attribute2,
         mtli.c_attribute3,
         mtli.c_attribute4,
         mtli.c_attribute5,
         mtli.c_attribute6,
         mtli.c_attribute7,
         mtli.c_attribute8,
         mtli.c_attribute9,
         mtli.c_attribute10,
         mtli.c_attribute11,
         mtli.c_attribute12,
         mtli.c_attribute13,
         mtli.c_attribute14,
         mtli.c_attribute15,
         mtli.c_attribute16,
         mtli.c_attribute17,
         mtli.c_attribute18,
         mtli.c_attribute19,
         mtli.c_attribute20,
         mtli.d_attribute1,
         mtli.d_attribute2,
         mtli.d_attribute3,
         mtli.d_attribute4,
         mtli.d_attribute5,
         mtli.d_attribute6,
         mtli.d_attribute7,
         mtli.d_attribute8,
         mtli.d_attribute9,
         mtli.d_attribute10,
         mtli.n_attribute1,
         mtli.n_attribute2,
         mtli.n_attribute3,
         mtli.n_attribute4,
         mtli.n_attribute5,
         mtli.n_attribute6,
         mtli.n_attribute7,
         mtli.n_attribute8,
         mtli.n_attribute9,
         mtli.n_attribute10,
         mtli.attribute1,
         mtli.attribute2,
         mtli.attribute3,
         mtli.attribute4,
         mtli.attribute5,
         mtli.attribute6,
         mtli.attribute7,
         mtli.attribute8,
         mtli.attribute9,
         mtli.attribute10,
         mtli.attribute11,
         mtli.attribute12,
         mtli.attribute13,
         mtli.attribute14,
         mtli.attribute15,
         mtli.attribute_category,
         mtli.parent_object_type,     --R12 Genealogy enhancements
         mtli.parent_object_id,       --R12 Genealogy enhancements
         mtli.parent_object_number,   --R12 Genealogy enhancements
         mtli.parent_item_id,         --R12 Genealogy enhancements
         mtli.parent_object_type2,    --R12 Genealogy enhancements
         mtli.parent_object_id2,      --R12 Genealogy enhancements
         mtli.parent_object_number2,  --R12 Genealogy enhancements
         msi.description item_description,
         msi.location_control_code,
         msi.restrict_subinventories_code,
         msi.restrict_locators_code,
         msi.revision_qty_control_code,
         msi.primary_uom_code,
         msi.shelf_life_code,
         msi.shelf_life_days,
         msi.allowed_units_lookup_code,
         mti.transaction_batch_id,
         mti.transaction_batch_seq,
         mti.kanban_card_id,
         mti.transaction_mode --J-dev
         FROM MTL_TRANSACTIONS_INTERFACE MTI,
         MTL_TRANSACTION_LOTS_INTERFACE MTLI,
         MTL_SYSTEM_ITEMS_B MSI
         WHERE mti.transaction_interface_id = p_interface_id
         AND MTI.transaction_interface_id = mtli.transaction_interface_id
         AND MTI.organization_id = msi.organization_id
         AND mti.inventory_item_id = msi.inventory_item_id
         and mti.process_flag = 1;
    l_count NUMBER := 0;
    l_partial_total_qty NUMBER :=0;
    l_remaining_qty NUMBER := 0;
    l_split_qty NUMBER := 0;
    l_split_uom VARCHAR2(3);
    l_transaction_interface_id NUMBER; --J-dev
BEGIN

   SELECT count(parent_id)
     INTO   l_count
     FROM   mtl_transactions_interface
     WHERE  parent_id = p_parent_id;

   SELECT abs(primary_quantity)
     INTO   l_split_qty
     FROM   mtl_transactions_interface
     WHERE  transaction_interface_id = p_parent_id;

   SELECT sum(abs(primary_quantity))
     INTO l_partial_total_qty
     FROM   mtl_transactions_interface
     WHERE  parent_id = p_parent_id
     AND    transaction_interface_id <> p_parent_id;

   l_remaining_qty := l_split_qty - l_partial_total_qty;

   if( p_current_index = l_count AND  l_remaining_qty > 0 ) then
      select mtl_material_transactions_s.nextval
        into l_transaction_interface_id --J-dev
        FROM dual;
      for l_mti_csr in mti_csr(p_parent_id ) LOOP
         IF (l_debug = 1) THEN
            inv_log_util.trace('insert into mmti is ' || l_mti_csr.transaction_interface_id, 'INV_TXN_MANAGER_GRP', 9);
         END IF;

            INSERT INTO   mtl_transactions_interface
              ( transaction_header_id ,
                transaction_interface_id ,
                transaction_mode ,
                lock_flag ,
                Process_flag
                ,last_update_date ,
                last_updated_by ,
                creation_date ,
                created_by ,
                last_update_login
                ,request_id ,
                program_application_id ,
                program_id ,
                program_update_date
                ,inventory_item_id ,
                revision ,
                organization_id
                ,subinventory_code ,
                locator_id
                ,transaction_quantity ,
                primary_quantity ,
                transaction_uom
                ,transaction_type_id ,
                transaction_action_id ,
                transaction_source_type_id
                ,transaction_date ,
                acct_period_id ,
                distribution_account_id,
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
                parent_id,--J-dev
                lpn_id ,
                transfer_lpn_id
                ,cost_group_id,
                transaction_batch_id,
              transaction_batch_seq,
              kanban_card_id)
              VALUES
              ( l_mti_csr.transaction_header_id,
                l_transaction_interface_id,--J-dev
                l_mti_csr.transaction_mode /*2722754 */,
                2,--J-dev
                1,--J-dev
                sysdate,
                l_mti_csr.created_by,
                sysdate,
                l_mti_csr.created_by,
                l_mti_csr.created_by,
                NULL,
                NULL,
                NULL,
                NULL,
                l_mti_csr.inventory_item_id,
                l_mti_csr.revision,
                l_mti_csr.organization_id,
                l_mti_csr.subinventory_code,
                l_mti_csr.locator_id,
                l_remaining_qty,
                l_remaining_qty,
                l_mti_csr.primary_uom_code,
                l_mti_csr.transaction_type_id,
                l_mti_csr.transaction_action_id,
                l_mti_csr.transaction_source_type_id,
                sysdate,
                l_mti_csr.acct_period_id,
                l_mti_csr.distribution_account_id,
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
              l_mti_csr.parent_id,
              l_mti_csr.lpn_id,
              l_mti_csr.transfer_lpn_id,
              l_mti_csr.cost_group_id,
              l_mti_csr.transaction_batch_id,
              l_mti_csr.transaction_batch_seq,
              l_mti_csr.kanban_card_id);
            INSERT  INTO mtl_transaction_lots_interface
              (transaction_interface_id, --J-dev
               last_update_date ,
            last_updated_by ,
            creation_date ,
            created_by ,
            last_update_login,
            request_id ,
            program_application_id ,
            program_id ,
               program_update_date,
               transaction_quantity ,
               primary_quantity,
               lot_number ,
               lot_expiration_date,
               description ,
               vendor_id ,
               supplier_lot_number ,
               territory_code,
               grade_code ,
               origination_date ,
               date_code,
               status_id ,
               change_date ,
               age ,
               retest_date,
               maturity_date ,
               lot_attribute_category ,
               item_size,
               color ,
               volume ,
               volume_uom,
               place_of_origin ,
               best_by_date ,
               length ,
               length_uom,
               recycled_content ,
               thickness ,
               thickness_uom,
               width ,
               width_uom ,
               curl_wrinkle_fold,
               c_attribute1 ,
               c_attribute2 ,
              c_attribute3 ,
              c_attribute4 ,
              c_attribute5,
              c_attribute6 ,
              c_attribute7 ,
              c_attribute8 ,
              c_attribute9 ,
              c_attribute10,
              c_attribute11 ,
              c_attribute12 ,
              c_attribute13 ,
              c_attribute14 ,
              c_attribute15,
              c_attribute16 ,
              c_attribute17 ,
              c_attribute18 ,
              c_attribute19 ,
              c_attribute20,
              d_attribute1 ,
              d_attribute2 ,
              d_attribute3 ,
              d_attribute4 ,
              d_attribute5 ,
              d_attribute6 ,
              d_attribute7 ,
              d_attribute8 ,
              d_attribute9 ,
              d_attribute10,
              n_attribute1 ,
              n_attribute2 ,
              n_attribute3 ,
              n_attribute4 ,
              n_attribute5 ,
              n_attribute6 ,
              n_attribute7 ,
              n_attribute8 ,
              n_attribute9 ,
              n_attribute10 ,
              attribute1 ,
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
              attribute15,
              attribute_category ,
              parent_object_type,      --R12 Genealogy enhancements
              parent_object_id,        --R12 Genealogy enhancements
              parent_object_number,    --R12 Genealogy enhancements
              parent_item_id,          --R12 Genealogy enhancements
              parent_object_type2,     --R12 Genealogy enhancements
              parent_object_id2,       --R12 Genealogy enhancements
              parent_object_number2)   --R12 Genealogy enhancements
              VALUES
              ( l_transaction_interface_id,
                SYSDATE,
                l_mti_csr.created_by,
                SYSDATE,
                l_mti_csr.created_by,
                l_mti_Csr.created_by,
                NULL,
                NULL,
                NULL,
                NULL,
                l_remaining_qty,
                l_remaining_qty,
                l_mti_csr.lot_number,
                l_mti_csr.lot_expiration_date,
                l_mti_csr.description,
                l_mti_csr.vendor_id,
                l_mti_csr.supplier_lot_number,
                l_mti_csr.territory_code,
                l_mti_csr.grade_code,
                l_mti_csr.origination_date,
                l_mti_csr.date_code,
                l_mti_csr.status_id,
                l_mti_csr.change_date,
                l_mti_csr.age,
                l_mti_csr.retest_date,
                l_mti_csr.maturity_date,
                l_mti_csr.lot_attribute_category,
                l_mti_csr.item_size,
                l_mti_csr.color,
                l_mti_csr.volume,
                l_mti_csr.volume_uom,
                l_mti_csr.place_of_origin,
                l_mti_csr.best_by_date,
                l_mti_csr.length,
                l_mti_csr.length_uom,
                l_mti_csr.recycled_content,
                l_mti_csr.thickness,
                l_mti_csr.thickness_uom,
                l_mti_csr.width,
                l_mti_csr.width_uom,
                l_mti_csr.curl_wrinkle_fold,
                l_mti_csr.c_attribute1,
                l_mti_csr.c_attribute2,
                l_mti_csr.c_attribute3,
                l_mti_csr.c_attribute4,
                l_mti_csr.c_attribute5,
                l_mti_csr.c_attribute6,
                l_mti_csr.c_attribute7,
                l_mti_csr.c_attribute8,
                l_mti_csr.c_attribute9,
                l_mti_csr.c_attribute10,
                l_mti_csr.c_attribute11,
                l_mti_csr.c_attribute12,
                l_mti_csr.c_attribute13,
                l_mti_csr.c_attribute14,
                l_mti_csr.c_attribute15,
                l_mti_csr.c_attribute16,
                l_mti_csr.c_attribute17,
                l_mti_csr.c_attribute18,
                l_mti_csr.c_attribute19,
                l_mti_csr.c_attribute20,
                l_mti_csr.d_attribute1,
                l_mti_csr.d_attribute2,
                l_mti_csr.d_attribute3,
                l_mti_csr.d_attribute4,
                l_mti_csr.d_attribute5,
                l_mti_csr.d_attribute6,
                l_mti_csr.d_attribute7,
                l_mti_csr.d_attribute8,
                l_mti_csr.d_attribute9,
                l_mti_csr.d_attribute10,
                l_mti_csr.n_attribute1,
                l_mti_csr.n_attribute2,
                l_mti_csr.n_attribute3,
                l_mti_csr.n_attribute4,
                l_mti_csr.n_attribute5,
                l_mti_csr.n_attribute6,
                l_mti_csr.n_attribute7,
                l_mti_csr.n_attribute8,
                l_mti_csr.n_attribute9,
                l_mti_csr.n_attribute10,
                l_mti_csr.attribute1,
                l_mti_csr.attribute2,
                l_mti_csr.attribute3,
                l_mti_csr.attribute4,
                l_mti_csr.attribute5,
                l_mti_csr.attribute6,
                l_mti_csr.attribute7,
                l_mti_csr.attribute8,
                l_mti_csr.attribute9,
                l_mti_csr.attribute10,
                l_mti_csr.attribute11,
                l_mti_csr.attribute12,
                l_mti_csr.attribute13,
                l_mti_csr.attribute14,
                l_mti_csr.attribute15,
                l_mti_csr.attribute_category,
                l_mti_csr.parent_object_type,     --R12 Genealogy enhancements
                l_mti_csr.parent_object_id,       --R12 Genealogy enhancements
                l_mti_csr.parent_object_number,   --R12 Genealogy enhancements
                l_mti_csr.parent_item_id,         --R12 Genealogy enhancements
                l_mti_csr.parent_object_type2,    --R12 Genealogy enhancements
                l_mti_csr.parent_object_id2,      --R12 Genealogy enhancements
                l_mti_csr.parent_object_number2); --R12 Genealogy enhancements

      END LOOP;
   END if;
   return true;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      IF (l_debug = 1) THEN
       inv_log_util.trace('SQL : ' || substr(sqlerrm, 1, 200), 'INV_TXN_MANAGER_GRP','9');
       inv_log_util.trace('Error in check_partial_split : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','9');
    END IF;
        return FALSE;
   when Others  then
    IF (l_debug = 1) THEN
       inv_log_util.trace('SQL : ' || substr(sqlerrm, 1, 200), 'INV_TXN_MANAGER_GRP','9');
       inv_log_util.trace('Error in check_partial_split : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','9');
    END IF;
        return false;
END Check_Partial_Split;

  /* Bug#4247753.  Added the below functon for validating the Account combination ID*/
  /* Bug#5176266. Added one more parameter, 'p_txn_date' to the function, 'validate_acctid'*/

  FUNCTION validate_acctid(p_acctid IN NUMBER, p_orgid IN NUMBER, p_txn_date IN DATE)
  RETURN BOOLEAN
  IS
    l_chart      number;
    catsegs      varchar2(200);
  BEGIN
    --Bug# 10019284
    SELECT gl.chart_of_accounts_id
    INTO   l_chart
    FROM   hr_organization_information hoi,
         hr_all_organization_units hou,
         gl_sets_of_books gl
    WHERE       hoi.organization_id = hou.organization_id
         AND hoi.org_information1 = TO_CHAR (gl.set_of_books_id)
         AND hoi.org_information_context = 'Accounting Information'
         AND hoi.organization_id = p_orgid;

    IF (l_debug = 1) THEN
	    inv_log_util.trace('chart_of_accounts_id:'|| to_char(l_chart), 'INV_TXN_MANAGER_GRP','1');
    END IF;

    IF fnd_flex_keyval.validate_ccid ( APPL_SHORT_NAME    => 'SQLGL'
                                       ,KEY_FLEX_CODE     => 'GL#'
                                       ,STRUCTURE_NUMBER  => l_chart
                                       ,COMBINATION_ID    => p_acctid )
    THEN
      catsegs := fnd_flex_keyval.concatenated_values;
      IF fnd_flex_keyval.validate_segs ( OPERATION         => 'CHECK_COMBINATION'
                                        ,APPL_SHORT_NAME   => 'SQLGL'
                                        ,KEY_FLEX_CODE     => 'GL#'
                                        ,STRUCTURE_NUMBER  => l_chart
                                        ,CONCAT_SEGMENTS   => catsegs
                                        ,VALIDATION_DATE   => p_txn_date
                                        ,VRULE             => '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN'||
                                                         '\0GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nE\nAPPL=INV;NAME=INV_VRULE_POSTING\nN' )
      THEN
        IF (l_debug = 1) THEN
          inv_log_util.trace('Distribution acct id : ' || p_acctid || ' is valid', 'INV_TXN_MANAGER_GRP','1');
        END IF;
        RETURN TRUE;
      ELSE
        l_error_exp := substr(fnd_flex_keyval.error_message,1,240);
        IF (l_debug = 1) THEN
           inv_log_util.trace('Distribution acct id is invalid '|| l_error_exp, 'INV_TXN_MANAGER_GRP','1');
        END IF;
        RETURN FALSE;
      END IF;
    ELSE
      l_error_exp := substr(fnd_flex_keyval.error_message,1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Distribution acct id Validation Error '|| l_error_exp, 'INV_TXN_MANAGER_GRP','1');
      END IF;
      RETURN FALSE;
    END IF ;

  EXCEPTION
  WHEN OTHERS THEN
    l_error_exp := substr(fnd_flex_keyval.error_message,1,240);
    IF (l_debug = 1) THEN
      inv_log_util.trace('Error in validate_acctid : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
      inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
    END IF;
    RETURN FALSE;
  END validate_acctid;

 /* getacctid()
 *
 ******************************************************************/
FUNCTION getacctid(x_acctid OUT NOCOPY NUMBER, p_orgid IN NUMBER, p_rowid IN VARCHAR2)
RETURN BOOLEAN
IS

   kff        fnd_flex_key_api.flexfield_type;
   str        fnd_flex_key_api.structure_type;
   seg        fnd_flex_key_api.segment_type;
   seg_list   fnd_flex_key_api.segment_list;
   j          number;
   i          number;
   nsegs      number;
   l_popul    boolean;
   segarray   fnd_flex_ext.segmentarray;
   --segarray   segment_array;
   tmp_seg_arr     seg_arr_type;
   concat     varchar2(2000);
   l_chart      number;
   l_acctid      number;
   l_trxdate     date;   --Bug#5176266.
begin

  SELECT DST_SEGMENT1, DST_SEGMENT2, DST_SEGMENT3,
         DST_SEGMENT4, DST_SEGMENT5, DST_SEGMENT6,
         DST_SEGMENT7, DST_SEGMENT8, DST_SEGMENT9,
         DST_SEGMENT10, DST_SEGMENT11, DST_SEGMENT12,
         DST_SEGMENT13, DST_SEGMENT14, DST_SEGMENT15,
         DST_SEGMENT16, DST_SEGMENT17, DST_SEGMENT18,
         DST_SEGMENT19, DST_SEGMENT20, DST_SEGMENT21,
         DST_SEGMENT22, DST_SEGMENT23, DST_SEGMENT24,
         DST_SEGMENT25, DST_SEGMENT26, DST_SEGMENT27,
         DST_SEGMENT28, DST_SEGMENT29, DST_SEGMENT30,
         TRANSACTION_DATE /*Bug#5176266*/
    INTO tmp_seg_arr(1).colvalue, tmp_seg_arr(2).colvalue, tmp_seg_arr(3).colvalue,
         tmp_seg_arr(4).colvalue, tmp_seg_arr(5).colvalue, tmp_seg_arr(6).colvalue,
         tmp_seg_arr(7).colvalue, tmp_seg_arr(8).colvalue, tmp_seg_arr(9).colvalue,
         tmp_seg_arr(10).colvalue, tmp_seg_arr(11).colvalue, tmp_seg_arr(12).colvalue,
         tmp_seg_arr(13).colvalue, tmp_seg_arr(14).colvalue, tmp_seg_arr(15).colvalue,
         tmp_seg_arr(16).colvalue, tmp_seg_arr(17).colvalue, tmp_seg_arr(18).colvalue,
         tmp_seg_arr(19).colvalue, tmp_seg_arr(20).colvalue, tmp_seg_arr(21).colvalue,
         tmp_seg_arr(22).colvalue, tmp_seg_arr(23).colvalue, tmp_seg_arr(24).colvalue,
         tmp_seg_arr(25).colvalue, tmp_seg_arr(26).colvalue, tmp_seg_arr(27).colvalue,
         tmp_seg_arr(28).colvalue, tmp_seg_arr(29).colvalue, tmp_seg_arr(30).colvalue,
         l_trxdate/*Bug#5176266*/
    FROM MTL_TRANSACTIONS_INTERFACE
   WHERE ROWID = p_rowid;

   l_popul := FALSE;
   i := 0;
   WHILE (i < 30) and (NOT l_popul) loop
     i := i + 1;
     IF (tmp_seg_arr(i).colvalue IS NOT NULL) THEN
        l_popul := TRUE;
     END IF;
   END LOOP;

   IF NOT l_popul THEN
        return true;
   END IF;

   SELECT CHART_OF_ACCOUNTS_ID
    INTO l_chart
    FROM ORG_ORGANIZATION_DEFINITIONS
   WHERE ORGANIZATION_ID = p_orgid;


   kff := fnd_flex_key_api.find_flexfield('SQLGL','GL#');
   str := fnd_flex_key_api.find_structure(kff, l_chart);
   fnd_flex_key_api.get_segments(kff, str, TRUE, nsegs, seg_list);

  /*
   * When the flexfield is defined, the order the segments are displayed
   * and the order of segment columns need not be the same.  For example, a
   * flexfield may contain 3 segments, which are defined as segment 1, 4 and 3.
   * The following loop re-arranges the order of the flexfield segments
   * so that the AOL routine can process it.
   */
   for i in 1..nsegs loop
     seg := fnd_flex_key_api.find_segment(kff, str, seg_list(i));
     j := 1;
     while (j <= tmp_seg_arr.count) loop
         if (seg.column_name = 'SEGMENT' || j) THEN
            segarray(i) := tmp_seg_arr(j).colvalue;
            j := tmp_seg_arr.count + 2;
         else
            j := j + 1;
         end if;
     end loop;
     if (j = tmp_seg_arr.count + 1) then
       j := j;
       --
       -- Error raise exception.
       --
     end if;
   end loop;

   --
   -- Now we have the all segment values in correct order in segarray.
   l_acctid_validated := TRUE; --Bug#4247753
   --
   if fnd_flex_ext.get_combination_id(APPLICATION_SHORT_NAME => 'SQLGL',
                                      KEY_FLEX_CODE => 'GL#',
                                      STRUCTURE_NUMBER => l_chart,
                                      N_SEGMENTS => nsegs,
                                      VALIDATION_DATE => l_trxdate,/*Bug#5176266*/
                                      SEGMENTS => segarray,
                                      COMBINATION_ID => l_acctid)
   then

   /* Bug#4247753. Added call to 'validate_acctid' */
   IF ( NOT validate_acctid(l_acctid , p_orgid, l_trxdate) ) THEN
     RETURN FALSE;
   END IF;

     IF (l_debug = 1) THEN
        inv_log_util.trace('Distribution acct id : ' || x_acctid, 'INV_TXN_MANAGER_GRP','1');
     END IF;
     x_acctid := l_acctid;
     RETURN TRUE;
   else
     l_error_exp := substr(FND_MESSAGE.get,1,240);
     IF (l_debug = 1) THEN
        inv_log_util.trace('Distribution acct id error '|| l_error_exp, 'INV_TXN_MANAGER_GRP','1');
     END IF;
     RETURN FALSE;
   end if;
   --x_acctid := fnd_flex_ext.concatenate_segments(nsegs,segarray, str.segment_separator);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('INV','INV-Database corrupt');
        FND_MESSAGE.set_token('ROUTINE','getacctid');
        RETURN FALSE;
   WHEN OTHERS THEN
      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getacctid : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_acctid := NULL;
      RETURN FALSE;
END getacctid;

/******************************************************************
-- Procedure
--   getitemid
-- Description
--   find the item_id using the flex field segments
-- Output Parameters
--   x_item_id   locator or null if error occurred
 ******************************************************************/
FUNCTION getitemid(x_itemid out NOCOPY NUMBER, p_orgid NUMBER, p_rowid VARCHAR2)
RETURN BOOLEAN
   IS
      l_nseg           NUMBER;
      l_seglist        fnd_flex_key_api.segment_list;
      l_segs1          fnd_flex_ext.segmentarray;
      l_fftype         fnd_flex_key_api.flexfield_type;
      l_ffstru         fnd_flex_key_api.structure_type;
      l_segment_type   fnd_flex_key_api.segment_type;
      -- Local array to hold the data for getting the cancatenated segment.
      l_segmentarray   fnd_flex_ext.segmentarray;
      l_itemsegs       VARCHAR2(32000);
      l_delim          VARCHAR2(1);
      l_result         BOOLEAN := FALSE;
BEGIN
   -- Getting the segments from MTI
   SELECT
        ITEM_SEGMENT1,
        ITEM_SEGMENT2,
        ITEM_SEGMENT3,
        ITEM_SEGMENT4,
        ITEM_SEGMENT5,
        ITEM_SEGMENT6,
        ITEM_SEGMENT7,
        ITEM_SEGMENT8,
        ITEM_SEGMENT9,
        ITEM_SEGMENT10,
        ITEM_SEGMENT11,
        ITEM_SEGMENT12,
        ITEM_SEGMENT13,
        ITEM_SEGMENT14,
        ITEM_SEGMENT15,
        ITEM_SEGMENT16,
        ITEM_SEGMENT17,
        ITEM_SEGMENT18,
        ITEM_SEGMENT19,
        ITEM_SEGMENT20
   INTO
        l_segs1(1),
        l_segs1(2),
        l_segs1(3),
        l_segs1(4),
        l_segs1(5),
        l_segs1(6),
        l_segs1(7),
        l_segs1(8),
        l_segs1(9),
        l_segs1(10),
        l_segs1(11),
        l_segs1(12),
        l_segs1(13),
        l_segs1(14),
        l_segs1(15),
        l_segs1(16),
        l_segs1(17),
        l_segs1(18),
        l_segs1(19),
        l_segs1(20)
   FROM mtl_transactions_interface mti
   WHERE mti.rowid = p_rowid;

   -- find flex field type
   l_fftype := fnd_flex_key_api.find_flexfield('INV', 'MSTK');

   -- find flex structure type
   l_ffstru := fnd_flex_key_api.find_structure(l_fftype, 101);

   -- find segment list for the key flex field
   fnd_flex_key_api.get_segments(l_fftype, l_ffstru, TRUE, l_nseg, l_seglist);

    -- find segment delimiter
       l_delim := l_ffstru.segment_separator;

   -- get the corresponding column for all segments
   FOR l_loop IN 1..l_nseg LOOP
      l_segment_type := fnd_flex_key_api.find_segment(l_fftype, l_ffstru, l_seglist(l_loop));
      -- Bug Fix#4747090
      --l_segmentarray contains data in the order flexfield is defined. Used in creating cancatenated segments for validation.
      l_segmentarray(l_loop) := l_segs1(To_number(Substr(l_segment_type.column_name, 8)));
   END LOOP;
   -- Bug Fix#4747090
   -- Gets the encoded cancatenated string
   l_itemsegs := fnd_flex_ext.concatenate_segments(n_segments => l_nseg,
                                                   segments   => l_segmentarray,
                                                   delimiter  => l_delim);
   l_result := FND_FLEX_KEYVAL.Validate_Segs(
                 OPERATION        => 'FIND_COMBINATION',
                 APPL_SHORT_NAME  => 'INV',
                 KEY_FLEX_CODE  => 'MSTK',
                 STRUCTURE_NUMBER  => 101,
                 CONCAT_SEGMENTS  => l_itemsegs,
                 VALUES_OR_IDS  => 'I',
                 DATA_SET  => p_orgid,
                 SELECT_COMB_FROM_VIEW => 'MTL_SYSTEM_ITEMS_FVL') ;

   if l_result then
       x_itemid := fnd_flex_keyval.combination_id;
   else
       x_itemid := NULL;
       l_error_exp := substr(fnd_flex_key_api.message(),1,240);
       inv_log_util.trace('Error in getitemid : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
       inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
   end if;
   return l_result;

END getitemid;


 /******************************************************************
 -- Procedure
 --   getsrcid
 -- Description
 --   find the Source ID using the flex field segments
 -- Output Parameters
 --   x_trxsrc   transaction source id or null if error occurred
 ******************************************************************/
FUNCTION getsrcid(x_trxsrc OUT NOCOPY NUMBER, p_srctype IN NUMBER, p_orgid IN NUMBER, p_rowid IN VARCHAR2)
RETURN BOOLEAN
   IS
      l_nseg           NUMBER;
      l_seglist        fnd_flex_key_api.segment_list;
      l_fftype         fnd_flex_key_api.flexfield_type;
      l_ffstru         fnd_flex_key_api.structure_type;
      l_segment_type   fnd_flex_key_api.segment_type;
      l_structure_list fnd_flex_key_api.structure_list;
      l_chart          NUMBER;
      segarray   fnd_flex_ext.segmentarray;
      tmp_seg_arr     seg_arr_type;
      i                      NUMBER;
      j                NUMBER;
      l_app_shortname  VARCHAR2(20);
      l_struct_number  NUMBER;
      l_flex_code      VARCHAR2(20);
      seg        fnd_flex_key_api.segment_type;
      l_result boolean; -- Added for bug 3346767

BEGIN
   SELECT DSP_SEGMENT1, DSP_SEGMENT2, DSP_SEGMENT3,
         DSP_SEGMENT4, DSP_SEGMENT5, DSP_SEGMENT6,
         DSP_SEGMENT7, DSP_SEGMENT8, DSP_SEGMENT9,
         DSP_SEGMENT10, DSP_SEGMENT11, DSP_SEGMENT12,
         DSP_SEGMENT13, DSP_SEGMENT14, DSP_SEGMENT15,
         DSP_SEGMENT16, DSP_SEGMENT17, DSP_SEGMENT18,
         DSP_SEGMENT19, DSP_SEGMENT20, DSP_SEGMENT21,
         DSP_SEGMENT22, DSP_SEGMENT23, DSP_SEGMENT24,
         DSP_SEGMENT25, DSP_SEGMENT26, DSP_SEGMENT27,
         DSP_SEGMENT28, DSP_SEGMENT29, DSP_SEGMENT30
    INTO tmp_seg_arr(1).colvalue, tmp_seg_arr(2).colvalue, tmp_seg_arr(3).colvalue,
         tmp_seg_arr(4).colvalue, tmp_seg_arr(5).colvalue, tmp_seg_arr(6).colvalue,
         tmp_seg_arr(7).colvalue, tmp_seg_arr(8).colvalue, tmp_seg_arr(9).colvalue,
         tmp_seg_arr(10).colvalue, tmp_seg_arr(11).colvalue, tmp_seg_arr(12).colvalue,
         tmp_seg_arr(13).colvalue, tmp_seg_arr(14).colvalue, tmp_seg_arr(15).colvalue,
         tmp_seg_arr(16).colvalue, tmp_seg_arr(17).colvalue, tmp_seg_arr(18).colvalue,
         tmp_seg_arr(19).colvalue, tmp_seg_arr(20).colvalue, tmp_seg_arr(21).colvalue,
         tmp_seg_arr(22).colvalue, tmp_seg_arr(23).colvalue, tmp_seg_arr(24).colvalue,
         tmp_seg_arr(25).colvalue, tmp_seg_arr(26).colvalue, tmp_seg_arr(27).colvalue,
         tmp_seg_arr(28).colvalue, tmp_seg_arr(29).colvalue, tmp_seg_arr(30).colvalue
    FROM MTL_TRANSACTIONS_INTERFACE
   WHERE ROWID = p_rowid;

   SELECT CHART_OF_ACCOUNTS_ID
     INTO l_chart
     FROM ORG_ORGANIZATION_DEFINITIONS
    WHERE ORGANIZATION_ID = p_orgid;


   -- find flex field type
   -- find flex structure type
   l_app_shortname := 'INV';
   l_struct_number := 101;
   IF (p_srctype = 2) OR (p_srctype = 8) THEN
     l_flex_code := 'MKTS';
   ELSE
     IF (p_srctype = 3) THEN
       l_app_shortname := 'SQLGL';
       l_flex_code := 'GL#';
       l_struct_number := l_chart;
     ELSE
       IF (p_srctype = 6) THEN
         l_flex_code := 'MDSP';
       END IF;
     END IF;
   END IF;

   l_fftype := fnd_flex_key_api.find_flexfield(l_app_shortname,l_flex_code);
   l_ffstru := fnd_flex_key_api.find_structure(l_fftype, l_struct_number);

   -- find segment list for the key flex field
   fnd_flex_key_api.get_segments(l_fftype, l_ffstru, TRUE, l_nseg, l_seglist);

  /*
   * When the flexfield is defined, the order the segments are displayed
   * and the order of segment columns need not be the same.  For example, a
   * flexfield may contain 3 segments, which are defined as segment 1, 4 and 3.
   * The following loop re-arranges the order of the flexfield segments
   * so that the AOL routine can process it.
   */
   for i in 1..l_nseg loop
     seg := fnd_flex_key_api.find_segment(l_fftype, l_ffstru, l_seglist(i));
     j := 1;
     while (j <= tmp_seg_arr.count) loop
         if (seg.column_name = 'SEGMENT' || j) THEN
            segarray(i) := tmp_seg_arr(j).colvalue;
            j := tmp_seg_arr.count + 2;
         else
            j := j + 1;
         end if;
     end loop;
     if (j = tmp_seg_arr.count + 1) then
       j := j;
       --
       -- Error raise exception.
       --
     end if;
   end loop;

   --
   -- Now we have the all segment values in correct order in segarray.
   --
   -- Bug 3273172 Added DATA_SET => p_orgid to the below FND call
   -- Changed for bug 3346767
   IF (p_srctype = 6) THEN
        l_result := fnd_flex_ext.get_combination_id(APPLICATION_SHORT_NAME => l_app_shortname,
                                      KEY_FLEX_CODE => l_flex_code,
                                      STRUCTURE_NUMBER => l_struct_number,
                                      VALIDATION_DATE => sysdate,
                                      N_SEGMENTS => l_nseg,
                                      SEGMENTS => segarray,
                                      COMBINATION_ID => x_trxsrc,
                                      DATA_SET => p_orgid);
  ELSE
       l_result := fnd_flex_ext.get_combination_id(APPLICATION_SHORT_NAME => l_app_shortname,
                                      KEY_FLEX_CODE => l_flex_code,
                                      STRUCTURE_NUMBER => l_struct_number,
                                      VALIDATION_DATE => sysdate,
                                      N_SEGMENTS => l_nseg,
                                      SEGMENTS => segarray,
                                      COMBINATION_ID => x_trxsrc);
  END IF;
   if l_result then
     IF (l_debug = 1) THEN
        inv_log_util.trace('Transaction Source ID : ' || x_trxsrc, 'INV_TXN_MANAGER_GRP','1');
     END IF;
     RETURN TRUE;
   else
     l_error_exp := substr(FND_MESSAGE.get,1,240);
     IF (l_debug = 1) THEN
        inv_log_util.trace('Transaction Source ID error '|| l_error_exp, 'INV_TXN_MANAGER_GRP','1'
);
     END IF;
     RETURN FALSE;
   end if;

EXCEPTION
   WHEN OTHERS THEN
      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getsrcid : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_trxsrc := NULL;
      return FALSE;

END getsrcid;

/******************************************************************
 *
 * errupdate()
 *
 ******************************************************************/

/* Bug 5343678 rowid is a keyword so we should never pass it as parameter */
/* Also passed the reqd number of parameters in all places just to avoid confusion as
   parameter name is not prefixed in any of the calls */

PROCEDURE errupdate(p_rowid IN VARCHAR2 DEFAULT NULL, lot_rowid IN VARCHAR2 DEFAULT NULL)
IS

 l_userid  NUMBER := -1; -- = prg_info.userid;
 l_reqstid  NUMBER := -1; -- = prg_info.reqstid;
 l_applid  NUMBER := -1; -- = prg_info.appid;
 l_progid  NUMBER := -1; -- = prg_info.progid;
 l_loginid  NUMBER := -1; --= prg_info.loginid;
BEGIN

    -- WHENEVER NOT FOUND CONTINUE;
    --Jalaj Srivastava Bug 4969885
    --if errors are for lot record then also update MLTI
    IF (lot_rowid IS NOT NULL) THEN

        UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
          SET LAST_UPDATE_DATE    = SYSDATE,
              LAST_UPDATED_BY     = l_userid,
              LAST_UPDATE_LOGIN   = l_loginid,
              PROGRAM_UPDATE_DATE = SYSDATE,
              ERROR_CODE          = substrb(l_error_code,1,240)
          WHERE ROWID = lot_rowid;
    END IF;
  IF (p_rowid IS NOT NULL) THEN
    UPDATE MTL_TRANSACTIONS_INTERFACE
       SET ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = l_userid,
           LAST_UPDATE_LOGIN = l_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2
     WHERE ROWID = p_rowid;
  END IF;
    return;

EXCEPTION
  WHEN OTHERS THEN
        RETURN;
END errupdate;



/******************************************************************
-- Procedure
--   derive_segment_ids
-- Description
--   derive segment-ids  based on segment values
-- Output Parameters
--
 ******************************************************************/
PROCEDURE derive_segment_ids(p_header_id NUMBER, x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER, x_msg_data OUT NOCOPY VARCHAR2)
IS
CURSOR c_mti IS
       SELECT inventory_item_id,
              organization_id,
              distribution_account_id,
              transaction_source_type_id,
              transaction_source_id,
              transaction_date,  --Bug#5176266.
              rowid
       FROM MTL_TRANSACTIONS_INTERFACE
       WHERE transaction_header_id = p_header_id
         AND process_flag = 1
         AND (inventory_item_id is NULL OR distribution_account_id is NULL
              OR
             (transaction_source_id is NULL AND transaction_source_type_id in (2,3,6,8))); --Bug 2971400

l_itemid  MTL_TRANSACTIONS_INTERFACE.INVENTORY_ITEM_ID%TYPE;
l_acctid  MTL_TRANSACTIONS_INTERFACE.DISTRIBUTION_ACCOUNT_ID%TYPE;
l_srctype  MTL_TRANSACTIONS_INTERFACE.TRANSACTION_SOURCE_TYPE_ID%TYPE;
l_trxsrc  MTL_TRANSACTIONS_INTERFACE.TRANSACTION_SOURCE_ID%TYPE;
l_trxdate MTL_TRANSACTIONS_INTERFACE.TRANSACTION_DATE%TYPE;  --Bug#5176266.
BEGIN

    FOR c_mti_row in c_mti LOOP
      l_acctid := c_mti_row.distribution_account_id;
      l_itemid := c_mti_row.inventory_item_id;
      l_srctype := c_mti_row.transaction_source_type_id;
      l_trxsrc := c_mti_row.transaction_source_id;
      l_trxdate :=c_mti_row.transaction_date;  --Bug#5176266.

      IF (l_itemid IS NULL) THEN
            IF (NOT getitemid(l_itemid, c_mti_row.organization_id, c_mti_row.rowid)) THEN
                l_error_exp := FND_MESSAGE.get;

                FND_MESSAGE.set_name('INV', 'INV_INT_ITMSEGCODE');
                l_error_code := FND_MESSAGE.get;

                errupdate(c_mti_row.rowid,null);
            END IF;
      END IF;
/* Bug 3273172,moved the below code here
  for Account, Account Alias source is populated first before getting the account */
        IF ( (  l_srctype=INV_Globals.G_SourceType_SalesOrder OR
                l_srctype = INV_Globals.G_SourceType_Account OR
                l_srctype = INV_Globals.G_SourceType_AccountAlias OR
                l_srctype = INV_Globals.G_SourceType_IntOrder)
              AND (l_trxsrc is NULL) ) THEN
              IF ( NOT getsrcid(l_trxsrc, l_srctype, c_mti_row.organization_id, c_mti_row.rowid)) THEN
                  l_error_exp := FND_MESSAGE.get;

                  FND_MESSAGE.set_name('INV', 'INV_INT_SRCSEGCODE');
                  l_error_code := FND_MESSAGE.get;

                  errupdate(c_mti_row.rowid,null);
               END IF;
        END IF;
       l_acctid_validated := FALSE; --Bug#4247753
      IF (l_acctid IS NULL) THEN
          IF (l_srctype = 3 OR l_srctype = 6) THEN
              IF (l_srctype = 6) THEN
                      SELECT DISTRIBUTION_ACCOUNT
                        INTO l_acctid
                        FROM MTL_GENERIC_DISPOSITIONS
                       WHERE ORGANIZATION_ID = c_mti_row.organization_id
                         AND DISPOSITION_ID = l_trxsrc;
              ELSE
                  l_acctid := l_trxsrc;
              END IF;

          ELSE
              IF (NOT getacctid(l_acctid, c_mti_row.organization_id, c_mti_row.rowid)) THEN
                 --l_error_exp := FND_MESSAGE.get; --Bug#4247753. Error Explaination is
                                                   --already set in getacctid()
                 FND_MESSAGE.set_name('INV', 'INV_INT_ACTCODE');
                 l_error_code := FND_MESSAGE.get;

                 errupdate(c_mti_row.rowid,null);
              END IF;
          END IF;
      END IF;

     --Bug#4247753  calling the functon, validate_acctid() for validating the Account combination ID
      IF ( l_acctid IS NOT NULL  AND  (NOT l_acctid_validated)) THEN
        IF ( NOT validate_acctid(l_acctid, c_mti_row.organization_id, l_trxdate)) THEN
           FND_MESSAGE.set_name('INV', 'INV_INT_ACTCODE');
           l_error_code := FND_MESSAGE.get;
           errupdate(c_mti_row.rowid,null);
        END IF;
      END IF;

/* Bug 2971400 populating transaction source id */
/* Bug 3273172,Moving the below code to above
        IF ( (  l_srctype=INV_Globals.G_SourceType_SalesOrder OR
                l_srctype = INV_Globals.G_SourceType_Account OR
                l_srctype = INV_Globals.G_SourceType_AccountAlias OR
                l_srctype = INV_Globals.G_SourceType_IntOrder)
              AND (l_trxsrc is NULL) ) THEN
              IF ( NOT getsrcid(l_trxsrc, l_srctype, c_mti_row.organization_id, c_mti_row.rowid)) THEN
                  l_error_exp := FND_MESSAGE.get;

                  FND_MESSAGE.set_name('INV', 'INV_INT_SRCSEGCODE');
                  l_error_code := FND_MESSAGE.get;

                  errupdate(c_mti_row.rowid,null);
               END IF;

        END IF; */

      UPDATE MTL_TRANSACTIONS_INTERFACE
      SET inventory_item_id = l_itemid,
          distribution_account_id = l_acctid,
          transaction_source_id = l_trxsrc
      WHERE rowid = c_mti_row.rowid;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          inv_log_util.trace('Error in derive_segment_ids : ' || l_error_exp, 'INV_TXN_MANAGER_GRP ','1');
          inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;

END derive_segment_ids;

-----------------------------------------------------------------------
-- Name : validate_quantities
-- Desc : This procedure is used to validate transaction quantity2
--
-- I/P Params :
--     All the relevant transaction details :
--        - organization id
--        - item_id
--        - lot, revision, subinventory
--        - transaction quantities
-- O/P Params :
--     x_rerturn_status.
-- RETURN VALUE :
--   TRUE : IF the transaction is valid regarding Quantity2 and lot indivisible
--   FALSE : IF the transaction is NOT valid regarding Quantity2 and lot indivisible
--
-- HISTORY
--   Jalaj Srivastava Bug 4969885
--     Added parameter p_lot_rowid
--   Jalaj Srivastava Bug 5446542
--     Check for lot indivisibility here
--     Make sure that lot indivisibility api is called
--     with primary quantity
-----------------------------------------------------------------------
FUNCTION validate_quantities(
  p_rowid                IN  VARCHAR2
, p_lot_rowid            IN  VARCHAR2
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_transaction_quantity IN  OUT  NOCOPY NUMBER
, p_transaction_uom      IN  VARCHAR2
, p_secondary_quantity   IN  OUT  NOCOPY NUMBER
, p_secondary_uom_code   IN  OUT  NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_lot_divisible_flag    VARCHAR2(1);
l_tracking_quantity_ind VARCHAR2(30);
l_secondary_default_ind VARCHAR2(30);
l_secondary_uom_code    VARCHAR2(3);
l_secondary_qty         NUMBER;
l_transaction_quantity  NUMBER;
l_lot_indiv_trx_valid   BOOLEAN;
l_msg                   VARCHAR2(4000);
l_msg_index_out         pls_integer;
l_return_status         varchar2(1);
l_msg_data              varchar2(4000);
l_msg_count             pls_integer;
l_primary_uom_code      VARCHAR2(3);--Bug 5446542
l_primary_quantity      NUMBER;--Bug 5446542

CURSOR get_item_details( org_id IN NUMBER
                       , item_id IN NUMBER) IS
SELECT lot_divisible_flag
, tracking_quantity_ind
, secondary_default_ind
, secondary_uom_code
, primary_uom_code /* Bug 5446542 */
FROM mtl_system_items
WHERE organization_id = org_id
AND inventory_item_id = item_id;

CURSOR check_gme_reversal IS
  SELECT count(1)
  FROM gme_transaction_pairs gtp, MTL_TRANSACTIONS_INTERFACE mti
  WHERE mti.rowid = p_rowid
  AND gtp.batch_id = mti.transaction_source_id
  AND gtp.material_detail_id = mti.trx_source_line_id
  AND transaction_id1 = mti.source_line_id
  AND pair_type = gme_common_pvt.g_pairs_reversal_type;
l_is_reversal NUMBER := 0;
CURSOR get_transaction_details( trx_type_id IN NUMBER) IS
SELECT transaction_action_id
, transaction_source_type_id
FROM mtl_transaction_types
WHERE transaction_type_id = trx_type_id;
l_transaction_action_id      NUMBER;
l_transaction_source_type_id NUMBER;
x_primary_quantity      NUMBER; /* Fix for Bug#11729772*/
x_secondary_quantity    NUMBER; /* Fix for Bug#11729772 */


BEGIN
   IF (l_debug is null)
   THEN
          l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   IF (l_debug = 1) THEN
     inv_log_util.trace('validate_quantities: Start ', 'INV_TXN_MANAGER_GRP', 9);
     inv_log_util.trace('org id='||to_char(p_organization_id)||' item id='||to_char(p_inventory_item_id)||' rev='||p_revision, 'INV_TXN_MANAGER_GRP', 9);
     inv_log_util.trace('txn uom='||p_transaction_uom||' qty='||to_char(p_transaction_quantity), 'INV_TXN_MANAGER_GRP', 9);
     inv_log_util.trace('sec uom='||p_secondary_uom_code||' qty='||to_char(p_secondary_quantity), 'INV_TXN_MANAGER_GRP', 9);
   END IF;


   /* =======================================================================
     Init variables
    =======================================================================  */
   OPEN get_item_details( p_organization_id
                        , p_inventory_item_id);
   FETCH get_item_details
    INTO l_lot_divisible_flag
       , l_tracking_quantity_ind
       , l_secondary_default_ind
       , l_secondary_uom_code
       , l_primary_uom_code;/* Bug 5446542 */
   --Item has already been validated
   --no need to check for no_data_found
   CLOSE get_item_details;
   --{
   IF (l_tracking_quantity_ind = 'PS') THEN

      /** Quantity  Validation **/
      IF (p_transaction_quantity IS NULL AND p_secondary_quantity IS NULL) THEN
         IF (l_debug = 1) THEN
           inv_log_util.trace('validate_quantities: both transaction and secondary quantities are null', 'INV_TXN_MANAGER_GRP', 9);
         END IF;
         loaderrmsg('INV_INT_QTYCODE','INV_INT_QTYCODE');
         errupdate(p_rowid, p_lot_rowid);
         return false;
      END IF;

      -- the item is DUOM controlled

      /** UOM Validation **/
      IF (p_secondary_uom_code <> l_secondary_uom_code) THEN
         IF (l_debug = 1) THEN
           inv_log_util.trace('validate_quantities: sec uom passed in not same as item sec uom', 'INV_TXN_MANAGER_GRP', 9);
         END IF;
         loaderrmsg('INV_INCORRECT_SECONDARY_UOM','INV_INCORRECT_SECONDARY_UOM');
         errupdate(p_rowid, p_lot_rowid);
         return false;
      END IF;
      -- Set the default UOM2 if missing
      IF (p_secondary_uom_code IS NULL) THEN
         p_secondary_uom_code := l_secondary_uom_code;
      END IF;
      IF (l_debug = 1) THEN
           inv_log_util.trace('validate_quantities: assigned sec uom='||p_secondary_uom_code, 'INV_TXN_MANAGER_GRP', 9);
      END IF;
      -- Set the Qty2 from Qty1 if missing:
      --{
      IF (p_secondary_quantity IS NULL) THEN
          l_secondary_qty := INV_CONVERT.INV_UM_CONVERT
            ( item_id         => p_inventory_item_id
             ,lot_number      => p_lot_number
             ,organization_id => p_organization_id
             ,precision       => 5
             ,from_quantity   => p_transaction_quantity
             ,from_unit       => p_transaction_uom
             ,to_unit         => p_secondary_uom_code
             ,from_name       => NULL
             ,to_name         => NULL);

          IF (l_secondary_qty = -99999) THEN
             IF (l_debug = 1) THEN
                inv_log_util.trace('validate_quantities: INV_CONVERT.INV_UM_CONVERT error while calculating sec qty', 'INV_TXN_MANAGER_GRP', 9);
             END IF;
             loaderrmsg('INV_NO_CONVERSION_ERR','INV_NO_CONVERSION_ERR');
             errupdate(p_rowid, p_lot_rowid);
             return false;
          END IF;
          p_secondary_quantity := l_secondary_qty;
          IF (l_debug = 1) THEN
            inv_log_util.trace('validate_quantities: new secondary qty is: '|| l_secondary_qty , 'INV_TXN_MANAGER_GRP', 9);
          END IF;
      END IF;--}

      -- Set the Qty1 from Qty2 if missing:
      --{
      IF (p_transaction_quantity IS NULL) THEN
         l_transaction_quantity := INV_CONVERT.INV_UM_CONVERT
               ( item_id         => p_inventory_item_id
               , lot_number      => p_lot_number
               , organization_id => p_organization_id
               , precision       => 5
               , from_quantity   => p_secondary_quantity
               , from_unit       => p_secondary_uom_code
               , to_unit         => p_transaction_uom
               , from_name       => NULL
               , to_name         => NULL);

         IF (l_transaction_quantity = -99999) THEN
             IF (l_debug = 1) THEN
               inv_log_util.trace('validate_quantities:  INV_CONVERT.INV_UM_CONVERT ERROR while calculating transaction quantity', 'INV_TXN_MANAGER_GRP', 9);
             END IF;
             loaderrmsg('INV_NO_CONVERSION_ERR','INV_NO_CONVERSION_ERR');
             errupdate(p_rowid, p_lot_rowid);
             return false;
         END IF;
         p_transaction_quantity := l_transaction_quantity;
         IF (l_debug = 1) THEN
          inv_log_util.trace('validate_quantities: new transaction qty is: '|| l_transaction_quantity , 'INV_TXN_MANAGER_GRP', 9);
         END IF;
      END IF;--}

      --Jalaj Srivastava Bug 4969885
      --We will not check for deviation
      --calling programs and customers should validate for deviation
      --before loading in mti
   ELSE
      --tracking is in primary
      p_secondary_quantity := NULL;
      p_secondary_uom_code := NULL;
   END IF;--}

   --Jalaj Srivastava Bug 5446542
   --Lot indivisibility check will be done here
   -- Lot Indivisible Validation
  --{
   IF (l_lot_divisible_flag = 'N') THEN
      --Jalaj Srivastava Bug 5446542
      --if txn uom is not same as the primary uom then
      --convert txn qty to prim qty.
      IF (l_primary_uom_code <> p_transaction_uom) THEN
        l_primary_quantity := INV_CONVERT.INV_UM_CONVERT
          ( item_id         => p_inventory_item_id
           ,lot_number      => p_lot_number
           ,organization_id => p_organization_id
           ,precision       => 5
           ,from_quantity   => p_transaction_quantity
           ,from_unit       => p_transaction_uom
           ,to_unit         => l_primary_uom_code
           ,from_name       => NULL
           ,to_name         => NULL);

        IF (l_primary_quantity = -99999) THEN
          IF (l_debug = 1) THEN
             inv_log_util.trace('validate_quantities: INV_CONVERT.INV_UM_CONVERT error while calculating primary qty', 'INV_TXN_MANAGER_GRP', 9);
          END IF;
          loaderrmsg('INV_NO_CONVERSION_ERR','INV_NO_CONVERSION_ERR');
          errupdate(p_rowid, p_lot_rowid);
          return false;
        END IF;
      ELSE
        l_primary_quantity := p_transaction_quantity;
      END IF;
      /*Bug,9717803 start Avoiding the indivisible lot validation for the reversal transactions */
      OPEN get_transaction_details(p_transaction_type_id);
      FETCH get_transaction_details
      INTO l_transaction_action_id
        , l_transaction_source_type_id;
      IF (get_transaction_details%NOTFOUND)
      THEN
         CLOSE get_transaction_details;
         FND_MESSAGE.SET_NAME('INV','TRX_TYPE_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE_ID', p_transaction_type_id);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE get_transaction_details;

      IF l_transaction_source_type_id = 5 AND l_transaction_action_id =32 THEN
        OPEN check_gme_reversal;
         FETCH check_gme_reversal INTO l_is_reversal;
         CLOSE check_gme_reversal;
      END IF;
      IF (l_debug = 1) THEN
            inv_log_util.trace('validate_quantities: check for lot indivisibility,gme_reversal'||l_is_reversal, 'INV_TXN_MANAGER_GRP', 9);
      END IF;

      IF l_is_reversal <> 1 THEN
          /*Bug,9717803 END  Avoiding the indivisible lot validation for the reversal transactions */

         l_lot_indiv_trx_valid := INV_LOT_API_PUB.VALIDATE_LOT_INDIVISIBLE
            ( p_api_version          => 1.0
            , p_init_msg_list        => fnd_api.g_false
            , p_transaction_type_id  => p_transaction_type_id
            , p_organization_id      => p_organization_id
            , p_inventory_item_id    => p_inventory_item_id
            , p_revision             => p_revision
            , p_subinventory_code    => p_subinventory_code
            , p_locator_id           => p_locator_id
            , p_lot_number           => p_lot_number
            , p_primary_quantity     => l_primary_quantity /* Bug 5446542: pass primary qty and not txn qty */
            , p_secondary_quantity   => p_secondary_quantity /* Fix for Bug#11729772 */
            , p_qoh                  => NULL
            , p_atr                  => NULL
	    , x_primary_quantity     => x_primary_quantity   /* Fix for Bug#11729772 */
            , x_secondary_quantity   => x_secondary_quantity /* Fix for Bug#11729772 */
            , x_return_status        => l_return_status
            , x_msg_count            => l_msg_count
            , x_msg_data             => l_msg_data);

         IF (NOT l_lot_indiv_trx_valid) THEN
            --the transaction is not valid regarding lot indivisible:
            IF (l_debug = 1) THEN
               inv_log_util.trace('validate_quantities: Failed check for lot indivisibility', 'INV_TXN_MANAGER_GRP', 9);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;
      IF (l_debug = 1) THEN
         inv_log_util.trace('validate_quantities: passed check for lot indivisibility', 'INV_TXN_MANAGER_GRP', 9);
      END IF;

   END IF;--}    -- l_lot_divisible_flag = 'N'

IF (l_debug = 1) THEN
        inv_log_util.trace('validate_quantities: End .... ', 'INV_TXN_MANAGER_GRP', 9);
END IF;

RETURN TRUE;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Get(
    p_msg_index     => 1,
    p_data          => l_msg,
    p_encoded       => FND_API.G_FALSE,
    p_msg_index_out => l_msg_index_out);

    l_error_exp  := l_msg;
    l_error_code := l_msg;

    IF (l_debug = 1) THEN
      inv_log_util.trace('validate_quantities: FND_API.G_EXC_ERROR ' || l_error_code, 'INV_TXN_MANAGER_GRP', 9);
    END IF;

    errupdate(p_rowid, p_lot_rowid);
    RETURN FALSE;

WHEN OTHERS THEN
  IF (l_debug = 1) THEN
    inv_log_util.trace('validate_quantities: when others'||substr(sqlerrm,1,240),'INV_TXN_MANAGER_GRP',1);
  END IF;
  RETURN FALSE;

END validate_quantities;


/******************************************************************
 *
 * validate_group
 * Validate a group of MTI records in a batch together

 * J-dev (WIP related validations)
 *  For patchet J, wip desktop transactions will be inserted into MTI,
 *  validated by INV and moved to MMTT. Since WIP already does some
 *  validations, we will by-pass some validation done here (based on the
 *  variable l_validation_full)
 *  The validation to be done for WIP desktop are:
 *  MTI  WIP Validation
 *  DESKTOP WIP TRANSACTIONS
 *  1. Flow Schedule will only exist for WIP Transactions
 *  2. Derive Transaction_action_id and Transaction_source_type_id
 *  from transaction_type_id
 *  3. Validate Shippable_flag records in MTI have transaction_enabled items.
 *  4. Validate Inventory_item_flag, Inventory_asset_flag  Costing  Enabled_Flag
 *  5. Validate Subinventory_code(disabled ?)
 *  6. Validate Transfer Subinventory(disabled ?)
 *  7. Validate Restricted Subinventories
 *  8. Validate Subinventory for the following:
 *  -You cannot issue from non tracked
 *  - You cannot transfer from expense sub to asset sub for  asset items
 *  -If the expense to asset transfer allowed profile  is set then
 *  You cannot issue from a non-tracked sub
 *  All other transfers are valid
 *  9. Validate Transaction_type_id (disable date )
 *  10. Validate Transaction_action(currently we do not support cycle
 *  count
 *  and some internal orders through MTI)
 *  11. Validate Organization(disable date)
 *  12. Validate Locators(disable date)
 *  13. Validate Revision ( should exists in mtl_item_revisions,
 *  we do not validate against disbaled_date for revision).
 *  14. Validate Transaction reasons(disable date)
 *  15. Validate Transaction Qty Sign
 *  16. Validate OverCompletion Trx qtyshould not be -ve or greater
 *  than the transaction qty.
   *  17. Validate Distribution Account
   *(if dist account id is not null or if null,should be an asset item/sub)
 *18.  Validate transaction UOM
 *19. Validate cost_group, Xfr cost Groups
* 20. Validate VMI: po_asl_attributes
  * 21. Validate LPN, Xfr LPN, Contenet LPN
  * All Other validations will be by-passed
 ******************************************************************/
   PROCEDURE validate_group(
                            p_header_id NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_userid NUMBER,
                            p_loginid NUMBER,
                            p_validation_level NUMBER:= fnd_api.g_valid_level_full)
   IS

      srctypeid   NUMBER;
      tvu_flow_schedule  VARCHAR2(50);
      tev_scheduled_flag NUMBER;
      flow_schedule_children   VARCHAR2(50);
      l_count  NUMBER;
      l_profile VARCHAR2(100);
      EXP_TO_AST_ALLOWED NUMBER;
      EXP_TYPE_REQUIRED NUMBER;
      NUMHOLD NUMBER:=0;
      l_validate_full BOOLEAN := TRUE; --J-dev

    -- INVCONV start fabdi
    -- new cursor AA2
    CURSOR AA2 IS
    SELECT
       ROWID,
       TRANSACTION_TYPE_ID,
       ORGANIZATION_ID,
       INVENTORY_ITEM_ID,
       REVISION,
       SUBINVENTORY_CODE,
       LOCATOR_ID,
       TRANSACTION_QUANTITY,
       TRANSACTION_UOM,
        SECONDARY_TRANSACTION_QUANTITY,
            SECONDARY_UOM_CODE
    FROM MTL_TRANSACTIONS_INTERFACE
    WHERE TRANSACTION_HEADER_ID = p_header_id
      AND PROCESS_FLAG = 1
    ORDER BY ORGANIZATION_ID,INVENTORY_ITEM_ID,REVISION,
          SUBINVENTORY_CODE,LOCATOR_ID;

        l_transaction_quantity NUMBER ;
        l_transaction_uom_code VARCHAR(3);
        l_secondary_quantity NUMBER;
        l_secondary_uom_code VARCHAR(3);
        l_return_status  VARCHAR(3);
        l_msg_count NUMBER;
        l_msg_data VARCHAR(200);

        l_transaction_type_id NUMBER;
    l_organization_id NUMBER;
        l_inventory_item_id NUMBER;
        l_revision  VARCHAR(3);
    l_subinventory_code VARCHAR(10);
    l_locator_id     NUMBER;
        l_rowid VARCHAR(31);
        l_tracking_quantity_ind mtl_system_items_b.tracking_quantity_ind%TYPE;
        l_item_secondary_uom_code    mtl_system_items_b.secondary_uom_code%TYPE;

        l_qty_check BOOLEAN;
        l_lot_control_code number;

    /* get lot control flag */
    CURSOR get_item_info( org_id IN NUMBER
                       , item_id IN NUMBER) IS
    SELECT lot_control_code, tracking_quantity_ind, secondary_uom_code
     FROM mtl_system_items
     WHERE organization_id = org_id
     AND inventory_item_id = item_id;

        -- INVCONV end fabdi


   BEGIN
      if (l_debug is null) then
         l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      end if;


/*---------------------------------------------------------+
| Derive transaction_action_id and transaction_source_
| type_id
+---------------------------------------------------------*/

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           TRANSACTION_ACTION_ID =
               (SELECT MTT.TRANSACTION_ACTION_ID
                FROM MTL_TRANSACTION_TYPES MTT
                WHERE MTT.TRANSACTION_TYPE_ID
                = MTI.TRANSACTION_TYPE_ID),
           TRANSACTION_SOURCE_TYPE_ID =
               (SELECT MTT.TRANSACTION_SOURCE_TYPE_ID
                FROM MTL_TRANSACTION_TYPES MTT
                WHERE MTT.TRANSACTION_TYPE_ID
                = MTI.TRANSACTION_TYPE_ID)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1;


  /*+-----------------------------------------------------------------+
  | OPM INVCONV umoogala (Bug 4432078)                                |
  | Flag error for all unsupported txns for Process Mfg Orgs.         |
  +-----------------------------------------------------------------+*/

    loaderrmsg('INV_TXN_NOT_SUPPORTED_CODE', 'INV_TXN_NOT_SUPPORTED_CODE_EXP');

    UPDATE mtl_transactions_interface mti
       SET last_update_date = SYSDATE,
           last_updated_by = p_userid,
           last_update_login = p_loginid,
           program_update_date = SYSDATE,
           process_flag = 3,
           lock_flag = 2,
           error_code = substrb(l_error_code,1,240),
           error_explanation = substrb(l_error_exp,1,240)
     WHERE transaction_header_id = p_header_id
       AND process_flag = 1
       AND transaction_type_id in (25, 90, 91, 92, 38, 48, 55,
                                   56, 57, 58, 24, 93, 66, 67,
                                   68, 80, 94, 26, 28, 77)
       AND EXISTS
            (SELECT 'This is a Process Mfg Org'
               FROM mtl_parameters mp
              WHERE mp.process_enabled_flag = 'Y'
                AND mp.organization_id = mti.organization_id
            );

    l_count := SQL%ROWCOUNT;
/*------------------------------------------------------+
| get flow schedule control variables
+------------------------------------------------------*/

    BEGIN
        SELECT TRANSACTION_SOURCE_TYPE_ID,
        DECODE(UPPER(NVL(FLOW_SCHEDULE,'N')), 'Y',1,0),
        NVL(SCHEDULED_FLAG,0)
          INTO srctypeid, tvu_flow_schedule, tev_scheduled_flag
          FROM MTL_TRANSACTIONS_INTERFACE
         WHERE TRANSACTION_HEADER_ID = p_header_id
           AND PROCESS_FLAG = 1
           AND ROWNUM < 2;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_data := 'No Transaction found in MTI';
           return;
    END;

    /**J-dev check we need to perform a full validation*/
    IF (l_debug = 1) THEN
       inv_log_util.trace('wip_constants.DMF_PATCHSET_LEVEL'||wip_constants.dmf_patchset_level,'INV_TXN_MANAGER_GRP', 9);
       inv_log_util.trace('wip_constants.DMF_PATCHSET_J_VALUE'||wip_constants.dmf_patchset_J_VALUE,'INV_TXN_MANAGER_GRP', 9);
    END IF;

    IF (srctypeid = 5 AND wip_constants.DMF_PATCHSET_LEVEL>= wip_constants.DMF_PATCHSET_J_VALUE)  THEN
      IF (p_validation_level <> fnd_api.g_valid_level_full) THEN
         l_validate_full := FALSE;
         /**implies this a WIP desktop transaction*/
         IF (l_debug = 1) THEN
            inv_log_util.trace('Val Grp:WIP desktop trx','INV_TXN_MANAGER_GRP', 9);
         END IF;
       ELSE
         IF (l_debug = 1) THEN
            inv_log_util.trace('Val Grp:WIP MTI trx','INV_TXN_MANAGER_GRP', 9);
         END IF;
      END IF;
    END IF;

    IF (l_validate_full) THEN--J-dev
       /* The flow_schedule will only make sense for wip transactions */
       IF  srctypeid = 5  THEN
      BEGIN
         SELECT
           DECODE(UPPER(NVL(FLOW_SCHEDULE,'N')), 'Y',1,0)
           INTO flow_schedule_children
           FROM MTL_TRANSACTIONS_INTERFACE
           WHERE TRANSACTION_HEADER_ID = p_header_id
           AND TRANSACTION_ACTION_ID IN (1, 27, 33, 34)
           AND PROCESS_FLAG = 1
           AND ROWNUM < 2;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            flow_schedule_children := 0;
      END;
       END IF;
    END IF;--J-dev



/*-------------------------------------------------------------------------+
| Derive inventory_item_id, distribution_acct_id and transaction_source_id
| where not supplied
+--------------------------------------------------------------------------*/


  /* commented logical validations fr inv_globals pre-req*/
  IF (l_validate_full) THEN --J-dev
     fnd_flex_key_api.set_session_mode('seed_data');
     derive_segment_ids(p_header_id, x_return_status ,x_msg_count, x_msg_data);
  END IF;
  loaderrmsg('INV_INT_TRXACTCODE', 'INV_INT_TRXACTCODE');

  --------------------------------------------------------+
  --Validate Logical Transactions.
  --========================================================
  -- Add a check to prevent processing logical transactions
  -- that are populated directly to the interface table
  --------------------------------------------------------

  --J-dev for Drop Ship
    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
    SET LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = p_userid,
    LAST_UPDATE_LOGIN = p_loginid,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROCESS_FLAG = 3,
    LOCK_FLAG = 2,
    ERROR_CODE = substrb(l_error_code,1,240),
    ERROR_EXPLANATION = substrb(l_error_exp,1,240)
    WHERE TRANSACTION_HEADER_ID = p_header_id
    AND process_flag = 1
    AND ((transaction_source_type_id = inv_globals.G_sourcetype_inventory
          AND transaction_action_id IN
          (inv_globals.G_action_logicalissue,
           inv_globals.G_action_logicalicsales,
           inv_globals.G_action_logicalicreceipt,
           inv_globals.G_action_logicalicrcptreturn,
           inv_globals.G_action_logicalicsalesreturn,
           inv_globals.G_action_logicalreceipt)) OR
         (transaction_source_type_id = inv_globals.G_sourcetype_rma
          AND transaction_action_id = inv_globals.G_action_logicalreceipt)
         OR
         (transaction_source_type_id = inv_globals.G_sourcetype_purchaseorder
          AND transaction_action_id in
          (inv_globals.G_action_logicalissue,
--         inv_globals.G_action_logicaldeladj,
--         inv_globals.G_action_logicalreceipt,
           inv_globals.G_action_retropriceupdate)) OR
         (transaction_source_type_id = inv_globals.G_sourcetype_rma
          AND transaction_action_id = inv_globals.G_action_logicalreceipt) OR
         (transaction_source_type_id = inv_globals.G_sourcetype_intreq
          AND transaction_action_id = inv_globals.G_action_logicalexpreqreceipt) OR
    (transaction_source_type_id = inv_globals.G_sourcetype_salesorder
     and transaction_action_id = inv_globals.G_action_logicalissue))   ;
  --J-dev for Drop Ship

  /*------------------------------------------------------+
  | Validate inventory item
    +------------------------------------------------------*/
    l_count := 0;

    loaderrmsg('INV_INT_ITMCODE', 'INV_INT_ITMEXP');

    -- Bug: 3616999: The WIP phantom items are not transactable items
    -- but are still inserted into MTI. We should not validate them
    -- but will have to move them to MMTT and it will be deleted from the
    -- table before pushed to MMT. So, if the source type is 5 (WIP) and
    -- wip_supply_type is 6, we do not validate them
    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID <> 24
      AND NVL(SHIPPABLE_FLAG,'Y') = 'Y'
      AND NOT (TRANSACTION_SOURCE_TYPE_ID = 5 AND
               nvl(OPERATION_SEQ_NUM,1) < 0 AND nvl(WIP_SUPPLY_TYPE,0) = 6)
   --   AND ((TRANSACTION_SOURCE_TYPE_ID = 5 AND WIP_SUPPLY_TYPE <> 6) OR
--         (transaction_source_type_id <>5))
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y');

    l_count := SQL%ROWCOUNT;


/*----------------------------------------------------+
| Start validation of item where it is specified
+----------------------------------------------------*/
    loaderrmsg('INV_INT_ITMCODE','INV_INT_ITMEXP');


        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_userid,
            LAST_UPDATE_LOGIN = p_loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 3,
            LOCK_FLAG = 2,
            ERROR_CODE = substrb(l_error_code,1,240),
            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = p_header_id
        AND INVENTORY_ITEM_ID IS NOT NULL
        AND (TRANSACTION_ACTION_ID NOT IN (1, 27, 33, 34)
                OR TRANSACTION_SOURCE_TYPE_ID <> 5)
        AND PROCESS_FLAG = 1
        AND NOT EXISTS (
         SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
          WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
            AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
            AND MSI.INVENTORY_ITEM_FLAG = 'Y');

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating specified item ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;



/*----------------------------------------------------------------+
| The items are validated seperately for average cost update
| transactions as done in the form
+----------------------------------------------------------------*/

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID = 24
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_FLAG = 'Y'
             AND MSI.INVENTORY_ASSET_FLAG = 'Y'
             AND MSI.COSTING_ENABLED_FLAG = 'Y');

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating specified item ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

/*----------------------------------------------------------------+
| The inv layer is validated seperately for layer cost update
| transactions. Only positive qty layers can be updated.
+----------------------------------------------------------------*/

  IF (l_validate_full) THEN--J-dev
     loaderrmsg('INV_POS_QTY_LAYER','INV_POS_QTY_LAYER');
    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
      SET LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = p_userid,
      LAST_UPDATE_LOGIN = p_loginid,
      PROGRAM_UPDATE_DATE = SYSDATE,
      PROCESS_FLAG = 3,
      LOCK_FLAG = 2,
      ERROR_CODE = substrb(l_error_code,1,240),
      ERROR_EXPLANATION = substrb(l_error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = p_header_id
      AND PROCESS_FLAG = 1
      AND TRANSACTION_ACTION_ID = 24
      AND TRANSACTION_SOURCE_TYPE_ID = 15
      AND NOT EXISTS (
                      SELECT NULL
                      FROM CST_INV_LAYERS CIL
                      WHERE CIL.INV_LAYER_ID = MTI.TRANSACTION_SOURCE_ID
                      AND CIL.LAYER_QUANTITY > 0);

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating for layer cost update ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;
  END IF;--J-dev

/*------------------------------------------------------------------------+
| Validate for lot/serial/revision control for direct inter-org transfers
+------------------------------------------------------------------------*/

  IF (l_validate_full) THEN--J-dev
     loaderrmsg('INV_INT_ITMCTRL','INV_INT_ITMECTRL');

     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID = 3 AND TRANSACTION_TYPE_ID <> 54 --Bug 13365231
       AND EXISTS (
                   SELECT NULL
                   FROM MTL_SYSTEM_ITEMS MS1,
                   MTL_SYSTEM_ITEMS MS2
                   WHERE MS1.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                   AND MS1.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                   AND MS2.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                   AND MS2.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
                   AND ((MS1.LOT_CONTROL_CODE = 1 AND
                         MS2.LOT_CONTROL_CODE = 2)
                        OR (MS1.SERIAL_NUMBER_CONTROL_CODE IN (1,6)
                            AND MS2.SERIAL_NUMBER_CONTROL_CODE IN (2,3,5))
                        OR (MS1.REVISION_QTY_CONTROL_CODE = 1 AND
                            MS2.REVISION_QTY_CONTROL_CODE = 2)));

     l_count := SQL%ROWCOUNT;
     IF (l_debug = 1) THEN
        inv_log_util.trace('Validating lot/serial/revision control for direct inter-org transfers (exclude internal order) ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
     END IF;

    /**Bug 13365231 we need allow serial contorl 'sale order receipt' at source org
      * when the transaction is Int Order Direct Ship
      */
    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID = 3 AND TRANSACTION_TYPE_ID = 54 --Bug 13365231
       AND EXISTS (
                   SELECT NULL
                   FROM MTL_SYSTEM_ITEMS MS1,
                   MTL_SYSTEM_ITEMS MS2
                   WHERE MS1.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                   AND MS1.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                   AND MS2.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                   AND MS2.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
                   AND ((MS1.LOT_CONTROL_CODE = 1 AND
                         MS2.LOT_CONTROL_CODE = 2)
                        OR (MS1.SERIAL_NUMBER_CONTROL_CODE IN (1)  --Bug 13365231
                            AND MS2.SERIAL_NUMBER_CONTROL_CODE IN (2,3,5))
                        OR (MS1.REVISION_QTY_CONTROL_CODE = 1 AND
                            MS2.REVISION_QTY_CONTROL_CODE = 2)));

     l_count := SQL%ROWCOUNT;
     IF (l_debug = 1) THEN
        inv_log_util.trace('Validating lot/serial/revision control for direct inter-org transfers (only for internal order) ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
     END IF;
     /*End Bug 13365231 */

  END IF;--J-dev


/*-----------------------------------------------------------+
| Validating inventory item against transfer organization
+-----------------------------------------------------------*/

IF (l_validate_full) THEN --J-dev
   loaderrmsg('INV_INT_ITEMCODE','INV_INT_XFRITMEXP');

   UPDATE MTL_TRANSACTIONS_INTERFACE MTI
     SET LAST_UPDATE_DATE = SYSDATE,
     LAST_UPDATED_BY = p_userid,
     LAST_UPDATE_LOGIN = p_loginid,
     PROGRAM_UPDATE_DATE = SYSDATE,
     PROCESS_FLAG = 3,
     LOCK_FLAG = 2,
     ERROR_CODE = substrb(l_error_code,1,240),
     ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
     AND TRANSACTION_ACTION_ID = 3
     AND PROCESS_FLAG = 1
     AND NVL(SHIPPABLE_FLAG,'Y') = 'Y'
     AND NOT EXISTS (
                     SELECT NULL
                     FROM MTL_SYSTEM_ITEMS MSI
                     WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                     AND MSI.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
                     AND MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y');

   l_count := SQL%ROWCOUNT;
   IF (l_debug = 1) THEN
      inv_log_util.trace('Validating item against xfer org ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
   END IF;

END IF;--J-dev


   /*-----------------------------------------------+
   | Start validation of subinventory code
   +-----------------------------------------------*/
    loaderrmsg('INV_INT_SUBCODE','INV_INT_SUBEXP');


     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_userid,
            LAST_UPDATE_LOGIN = p_loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 3,
            LOCK_FLAG = 2,
            ERROR_CODE = substrb(l_error_code,1,240),
            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = p_header_id
        AND PROCESS_FLAG = 1
        AND TRANSACTION_ACTION_ID NOT IN (24, 30) /* CFM Scrap Transactions */
        AND (NVL(SHIPPABLE_FLAG,'Y') = 'Y'
             AND NOT EXISTS (
             SELECT NULL
               FROM MTL_SECONDARY_INVENTORIES MSI
              WHERE MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                AND MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
                AND NVL(MSI.DISABLE_DATE,SYSDATE+1) > SYSDATE)
             OR (SHIPPABLE_FLAG = 'N'
                 AND SUBINVENTORY_CODE IS NOT NULL
                 AND NOT EXISTS (
                 SELECT NULL
                 FROM MTL_SECONDARY_INVENTORIES MSI
                 WHERE MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                 AND MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
                 AND NVL(MSI.DISABLE_DATE,SYSDATE+1) > SYSDATE)));

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating subinventory code ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;



    /*-----------------------------------------------------------+
     | Start validating the transfer subinventory                |
     +-----------------------------------------------------------*/

       IF (l_validate_full) THEN --J-dev

          loaderrmsg('INV_INT_XSUBCODE','INV_INT_XSUBEXP');


          UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_userid,
            LAST_UPDATE_LOGIN = p_loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 3,
            LOCK_FLAG = 2,
            ERROR_CODE = substrb(l_error_code,1,240),
            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
            WHERE TRANSACTION_HEADER_ID = p_header_id
            AND PROCESS_FLAG = 1
            AND (TRANSACTION_ACTION_ID IN (2,3,21,5)
                 AND TRANSFER_SUBINVENTORY IS NOT NULL)
                   AND ((NVL(SHIPPABLE_FLAG,'Y') = 'Y'
                         AND NOT EXISTS (
                                         SELECT NULL
                                         FROM MTL_SECONDARY_INVENTORIES MSI
                                         WHERE MSI.ORGANIZATION_ID =
                                         DECODE(MTI.TRANSACTION_ACTION_ID,2,
                                                MTI.ORGANIZATION_ID,5,MTI.organization_id,
                                                MTI.TRANSFER_ORGANIZATION)
                                         AND MSI.SECONDARY_INVENTORY_NAME = MTI.TRANSFER_SUBINVENTORY
                                         AND NVL(MSI.DISABLE_DATE,SYSDATE+1) > SYSDATE))
                        OR (SHIPPABLE_FLAG = 'N'
                            AND TRANSFER_SUBINVENTORY IS NOT NULL
                            AND NOT EXISTS (
                                            SELECT NULL
                                            FROM MTL_SECONDARY_INVENTORIES MSI
                                            WHERE MSI.ORGANIZATION_ID =
                                            DECODE(MTI.TRANSACTION_ACTION_ID,3,
                                                   MTI.TRANSFER_ORGANIZATION,21,
                                                   MTI.TRANSFER_ORGANIZATION,MTI.ORGANIZATION_ID)
                                            AND MSI.SECONDARY_INVENTORY_NAME =
                                            MTI.TRANSFER_SUBINVENTORY
                                            AND NVL(MSI.DISABLE_DATE,SYSDATE+1) > SYSDATE)));

                            l_count := SQL%ROWCOUNT;
                            IF (l_debug = 1) THEN
                               inv_log_util.trace('Validating xfer subinventory code ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
                            END IF;
       END IF;--J-dev



/*-----------------------------------------------------------+
| Validating restricted subinventories
+-----------------------------------------------------------*/
    loaderrmsg('INV_INT_SUBCODE','INV_INT_RESUBEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND SUBINVENTORY_CODE IS NOT NULL
       AND PROCESS_FLAG = 1
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_SUB_INVENTORIES MIS,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_SUBINVENTORIES_CODE = 1
             AND MIS.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MIS.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MIS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MIS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MIS.SECONDARY_INVENTORY = MTI.SUBINVENTORY_CODE
           UNION
             SELECT NULL
               FROM MTL_SYSTEM_ITEMS ITM
              WHERE ITM.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                AND ITM.RESTRICT_SUBINVENTORIES_CODE = 2);

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating restricted subinventories ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;


/*--------------------------------------------------------+
| Validating restricted subinventory against transfer
| organization
+--------------------------------------------------------*/

  IF (l_validate_full) THEN --J-dev

     loaderrmsg('INV_INT_XSUBCODE','INV_INT_RESXFRSUBEXP');


     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSFER_SUBINVENTORY IS NOT NULL
         AND TRANSACTION_ACTION_ID in (2,21,3,5)
         AND NOT EXISTS (
                         SELECT NULL
                         FROM MTL_ITEM_SUB_INVENTORIES MIS,
                         MTL_SYSTEM_ITEMS MSI
                         WHERE MSI.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID, 2,
                                                            MTI.ORGANIZATION_ID,
                                                            MTI.TRANSFER_ORGANIZATION)
                         AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                         AND MSI.RESTRICT_SUBINVENTORIES_CODE = 1
                         AND MIS.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID,2,
                                                          MTI.ORGANIZATION_ID,
                                                          MTI.TRANSFER_ORGANIZATION)
                         AND MIS.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                         AND MIS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                         AND MIS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                         AND MIS.SECONDARY_INVENTORY = MTI.TRANSFER_SUBINVENTORY
                         UNION
                         SELECT NULL
                         FROM MTL_SYSTEM_ITEMS ITM
                         WHERE ITM.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID,2,
                                                            MTI.ORGANIZATION_ID,
                                                            MTI.TRANSFER_ORGANIZATION)
                         AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                         AND ITM.RESTRICT_SUBINVENTORIES_CODE = 2);


       l_count := SQL%ROWCOUNT;
       IF (l_debug = 1) THEN
          inv_log_util.trace('Validating xfer res subs ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
       END IF;

  END IF;--J-dev

/*----------------------------------------------------------------------+
| Validate Subinventory for the following:
|    You cannot issue from non tracked
|    You cannot issue from expense sub for intransit shipment
|    You cannot transfer from expense sub to asset sub for asset items
|If the expense to asset transfer allowed profiel is set then
|    You cannot issue from a non-tracked sub
|    All other transfers are valid
|exp_to_ast_allowed = 1 means that the exp to ast trx are not alowed
+----------------------------------------------------------------------*/
     SELECT FND_PROFILE.VALUE('INV:EXPENSE_TO_ASSET_TRANSFER')
     INTO l_profile
     FROM dual;

     IF SQL%FOUND THEN
        IF l_profile = '2' THEN
           exp_to_ast_allowed := 1;
        ELSE
             exp_to_ast_allowed := 2;
        END IF;
     ELSE
          exp_to_ast_allowed := 1;
     END IF;


    IF exp_to_ast_allowed = 1  THEN

        loaderrmsg('INV_INT_SUBCODE','INV_INT_SUBTYPEXP');

       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
         SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = p_userid,
         LAST_UPDATE_LOGIN = p_loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 3,
         LOCK_FLAG = 2,
         ERROR_CODE = substrb(l_error_code,1,240),
         ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
         AND PROCESS_FLAG = 1
         AND ((TRANSACTION_ACTION_ID in (1,2,3,30,31,5)
         AND EXISTS (
           SELECT 'X'
           FROM MTL_SECONDARY_INVENTORIES MSI
           WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
           AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
           AND MSI.QUANTITY_TRACKED = 2))
           OR (TRANSACTION_ACTION_ID = 21
             AND EXISTS (
              SELECT 'X'
                FROM MTL_SECONDARY_INVENTORIES MSI,
                MTL_SYSTEM_ITEMS ITM
                WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
                AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                AND ITM.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                AND ITM.ORGANIZATION_ID =  MSI.ORGANIZATION_ID
                AND ITM.INVENTORY_ASSET_FLAG = 'Y'
                AND MSI.ASSET_INVENTORY = 2)));

        l_count :=  SQL%ROWCOUNT;


       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
         SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = p_userid,
         LAST_UPDATE_LOGIN = p_loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 3,
         LOCK_FLAG = 2,
         ERROR_CODE = substrb(l_error_code,1,240),
         ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
         AND PROCESS_FLAG = 1
         AND TRANSACTION_ACTION_ID in (2,5)
         AND EXISTS (
           SELECT 'X'
           FROM MTL_SECONDARY_INVENTORIES MSI,
           MTL_SYSTEM_ITEMS ITM
           WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
             AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND ITM.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND ITM.INVENTORY_ASSET_FLAG = 'Y'
             AND MSI.ASSET_INVENTORY = 2)
             AND EXISTS (
               SELECT 'X'
                 FROM MTL_SECONDARY_INVENTORIES MSI,
                 MTL_SYSTEM_ITEMS ITM
                 WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.TRANSFER_SUBINVENTORY
                   AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                   AND ITM.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                   AND ITM.INVENTORY_ASSET_FLAG = 'Y'
                   AND MSI.ASSET_INVENTORY = 1);

        l_count := l_count + SQL%ROWCOUNT;

       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                SET LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = p_userid,
                LAST_UPDATE_LOGIN = p_loginid,
                PROGRAM_UPDATE_DATE = SYSDATE,
                PROCESS_FLAG = 3,
                LOCK_FLAG = 2,
                ERROR_CODE = substrb(l_error_code,1,240),
                ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
         AND PROCESS_FLAG = 1
         AND TRANSACTION_ACTION_ID = 3
         AND EXISTS (
           SELECT 'X'
           FROM MTL_SECONDARY_INVENTORIES MSI
           WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
             AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSI.ASSET_INVENTORY = 2)
             AND EXISTS (
               SELECT 'X'
               FROM MTL_SECONDARY_INVENTORIES MSI
               WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.TRANSFER_SUBINVENTORY
                AND MSI.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
                AND MSI.ASSET_INVENTORY = 1);

        l_count :=  l_count + SQL%ROWCOUNT;

        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating subs ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
        FND_MESSAGE.set_name('INV', 'INV_ERR_DETVAL');
        FND_MESSAGE.set_token('token', numhold);

     ELSE

       loaderrmsg('INV_INT_SUBCODE','INV_INT_SUBTYPEXP');

       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
         SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = p_userid,
         LAST_UPDATE_LOGIN = p_loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 3,
         LOCK_FLAG = 2,
         ERROR_CODE = substrb(l_error_code,1,240),
         ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
         AND PROCESS_FLAG = 1
         AND ((TRANSACTION_ACTION_ID in (1,2,3,30,31,5)
         AND EXISTS (
           SELECT 'X'
             FROM MTL_SECONDARY_INVENTORIES MSI
             WHERE MSI.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
             AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSI.QUANTITY_TRACKED = 2)
             )) ;

        l_count :=  SQL%ROWCOUNT;
        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating subs else ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
        FND_MESSAGE.set_name('INV', 'INV_ERR_DETVAL');
          FND_MESSAGE.set_token('token', numhold);

     END IF;


/*--------------------------------------------------------------------+
| Start validation of transaction source
+--------------------------------------------------------------------*/

  IF (l_validate_full) THEN --J-dev

     loaderrmsg('INV_INT_SRCCODE','INV_INT_SALEXP');


     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_SOURCE_TYPE_ID in (2,8)
       AND NOT EXISTS (
                       SELECT NULL
                       FROM MTL_SALES_ORDERS MSO
                       WHERE MSO.SALES_ORDER_ID = MTI.TRANSACTION_SOURCE_ID
                       AND NVL(START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
                       AND NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE
                       AND ENABLED_FLAG = 'Y');

     l_count := SQL%ROWCOUNT;
     loaderrmsg('INV_INT_SRCCODE','INV_INT_ACCTEXP');

     /*Bug#5176266. Made changes to the below UPDATE statement
       to validate the Account effective date against transactions
       date( not sysdate)*/
     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_SOURCE_TYPE_ID = 3
       AND NOT EXISTS (
                       SELECT NULL
                       FROM GL_CODE_COMBINATIONS GCC,
                       ORG_ORGANIZATION_DEFINITIONS OOD
                       WHERE GCC.CODE_COMBINATION_ID = MTI.TRANSACTION_SOURCE_ID
                       AND GCC.CHART_OF_ACCOUNTS_ID = OOD.CHART_OF_ACCOUNTS_ID
                       AND OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                       AND GCC.ENABLED_FLAG = 'Y'
                       AND NVL(GCC.START_DATE_ACTIVE, MTI.TRANSACTION_DATE - 1) <= MTI.TRANSACTION_DATE
                       AND NVL(GCC.END_DATE_ACTIVE, MTI.TRANSACTION_DATE + 1) > MTI.TRANSACTION_DATE);

     l_count := l_count + SQL%ROWCOUNT;
     loaderrmsg('INV_INT_SRCCODE','INV_INT_ALIASEXP');

     /* Bug# 3249130/ 3249131, Port change of Bug# 3238160. Changing the DML statement that populates the
        error code in MTI when the Account alias is inactive. The query now checks for the
        EFFECTIVE_DATE and DISABLE_DATE rather than START_DATE_ACTIVE and END_DATE_ACTIVE*/

     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_SOURCE_TYPE_ID = INV_GLOBALS.G_SourceType_AccountAlias
       AND NOT EXISTS (
                       SELECT NULL
                       FROM MTL_GENERIC_DISPOSITIONS MGD
                       WHERE MGD.DISPOSITION_ID = MTI.TRANSACTION_SOURCE_ID
                       AND MGD.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                       AND MGD.ENABLED_FLAG = 'Y'
                       AND NVL(MGD.EFFECTIVE_DATE, SYSDATE - 1) <= SYSDATE
                       AND NVL(MGD.DISABLE_DATE, SYSDATE + 1) > SYSDATE );
                      /* AND NVL(MGD.START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
                       AND NVL(MGD.END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE );*/


     l_count :=  l_count + SQL%ROWCOUNT;
     IF (l_debug = 1) THEN
        inv_log_util.trace('Validating transaction source ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
     END IF;

  END IF;--J-dev

/*----------------------------------------------------+
| Validating transaction type
+----------------------------------------------------*/
    loaderrmsg('INV_INT_TRXTYPCODE','INV_INT_TYPEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_TRANSACTION_TYPES MTT
            WHERE MTT.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
            AND  nvl(MTT.DISABLE_DATE,SYSDATE+1) > SYSDATE );

    l_count :=  SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating transaction type ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;


/*-------------------------------------------------------+
| Validating transaction actions
+-------------------------------------------------------*/
    loaderrmsg('INV_INT_TRXACTCODE','INV_INT_TRXACTEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND (TRANSACTION_ACTION_ID in (4,8,12,28,29)
            OR (TRANSACTION_ACTION_ID = 30 AND UPPER(NVL(FLOW_SCHEDULE,'N')) <> 'Y')); /* CFM Scrap Transaction */

    l_count :=  SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating transaction action ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;


/*-------------------------------------------------------+
| Start validation of organization
+-------------------------------------------------------*/

    loaderrmsg('INV_INT_ORGCODE','INV_INT_ORGEXP');


        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_userid,
            LAST_UPDATE_LOGIN = p_loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 3,
            LOCK_FLAG = 2,
            ERROR_CODE = substrb(l_error_code,1,240),
            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = p_header_id
        AND PROCESS_FLAG = 1
        AND NOT EXISTS (
           SELECT NULL
             FROM ORG_ORGANIZATION_DEFINITIONS OOD
            WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND NVL(OOD.DISABLE_DATE, SYSDATE + 1) > SYSDATE);

    l_count :=  SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating ORG ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;


/*-------------------------------------------------------------+
| Start validating the transfer organization
+-------------------------------------------------------------*/

  IF (l_validate_full) THEN --J-dev

     loaderrmsg('INV_INT_XORGCODE','INV_INT_XORGEXP');


     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND TRANSACTION_ACTION_ID in (3,21)
       AND PROCESS_FLAG = 1
       AND (NOT EXISTS (
                        SELECT NULL
                        FROM ORG_ORGANIZATION_DEFINITIONS OOD
                        WHERE OOD.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
                        AND NVL(OOD.DISABLE_DATE, SYSDATE + 1) > SYSDATE)
            OR NOT EXISTS (
                           SELECT NULL
                           FROM MTL_INTERORG_PARAMETERS MIP
                           WHERE MIP.TO_ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
                           AND MIP.FROM_ORGANIZATION_ID = MTI.ORGANIZATION_ID));

     l_count :=  SQL%ROWCOUNT;
     IF (l_debug = 1) THEN
        inv_log_util.trace('Validating xfer ORG ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
     END IF;

  END IF;--J-dev

     /*--------------------------------------------------+
     | Validating item revisions
       +--------------------------------------------------*/
    loaderrmsg('INV_INT_REVCODE','INV_INT_REVEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID NOT IN (24,33,34)
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
              AND MIR.REVISION = MTI.REVISION
             UNION
              SELECT NULL
                FROM MTL_SYSTEM_ITEMS ITM
               WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
                 AND MTI.REVISION IS NULL
                 AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                 AND ITM.ORGANIZATION_ID = MTI.ORGANIZATION_ID);


    l_count := SQL%ROWCOUNT;

    IF (l_validate_full) THEN --J-dev

    loaderrmsg('INV_INT_REVCODE','INV_INT_REVXFREXP');


    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID = 3
       AND NOT EXISTS (
            SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
              AND MIR.REVISION = MTI.REVISION
              AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            UNION
              SELECT NULL
                FROM MTL_SYSTEM_ITEMS ITM
               WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
             --    AND MTI.REVISION IS NULL  --Bug#3285134. No REVISION validation for Revision to Non-Revision Org Xfer
                 AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                 AND ITM.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION);

                 l_count := l_count +  SQL%ROWCOUNT;

    END IF;--J-dev

    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating revisions ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

 /* Bug# 10331476 - Start : Restricting unimplemented item revisions for transactions with source type (13, 6, 3)*/

    loaderrmsg('INV_INT_REVCODE','INV_INT_REVEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_SOURCE_TYPE_ID IN (13, 6, 3)
       AND TRANSACTION_ACTION_ID IN (1, 27, 2)
       AND EXISTS (
           SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
              AND MIR.REVISION = MTI.REVISION
              AND NVL(Trunc(MIR.IMPLEMENTATION_DATE), Trunc(SYSDATE + 1)) > Trunc (SYSDATE));

    l_count := SQL%ROWCOUNT;

    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating unimplemented revisions ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

/* Bug# 10331476: End */



/*------------------------------------------------------+
| Validating transaction reasons
+------------------------------------------------------*/
    loaderrmsg('INV_INT_REACODE','INV_INT_REAEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND REASON_ID IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_TRANSACTION_REASONS MTR
            WHERE MTR.REASON_ID = MTI.REASON_ID
              AND NVL(MTR.DISABLE_DATE, SYSDATE + 1) > SYSDATE);

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating reasons ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

    --Jalaj Srivastava Bug 4969885
    --Validate the transaction uom befoire validating quantities
/*---------------------------------------------------------+
| Start validating the transaction uom
+---------------------------------------------------------*/

    loaderrmsg('INV_INT_UOMCODE','INV_INT_UOMEXP');


    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND INVENTORY_ITEM_ID IS NOT NULL
       AND PROCESS_FLAG = 1
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_ITEM_UOMS_VIEW MIUV
            WHERE MIUV.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MIUV.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND MIUV.UOM_CODE = MTI.TRANSACTION_UOM);

    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating transaction uom ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

/*------------------------------------------------------+
| Validating transaction quantity
+------------------------------------------------------*/

    loaderrmsg('INV_INT_QTYCODE','INV_INT_QTYSGNEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_QUANTITY > 0
       AND TRANSACTION_ACTION_ID IN (1,21,32,34);

    l_count := SQL%ROWCOUNT;

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_QUANTITY < 0
       AND TRANSACTION_ACTION_ID IN (12,27,31,33);

    l_count := l_count + SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating transaction quantity ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

   IF (l_debug = 1) THEN
     inv_log_util.trace('start of OPM validations within (validate_group)' , 'INV_TXN_MANAGER_GRP', 9);
   END IF;

   OPEN AA2 ;
   LOOP
   FETCH AA2 INTO
                 l_rowid
                ,l_transaction_type_id
                ,l_organization_id
                ,l_inventory_item_id
                ,l_revision
                ,l_subinventory_code
                ,l_locator_id
                ,l_transaction_quantity
                ,l_transaction_uom_code
                ,l_secondary_quantity
                ,l_secondary_uom_code ;

     OPEN get_item_info(l_organization_id,l_inventory_item_id) ;
     FETCH get_item_info INTO l_lot_control_code, l_tracking_quantity_ind, l_item_secondary_uom_code;
     --item is already validated at this point no need to check for no_data_found
     CLOSE get_item_info;

        /* bug 4178299, bypass dual qty validations for none-lot ctl items
         * since qty will be validated at lot level per line, at header level
         * we only need to check that transaction qty equals the sum of the lines total */
      --{
      IF (l_tracking_quantity_ind = 'PS') THEN
        --{
        IF (l_lot_control_code = 1 ) THEN

          IF (l_debug = 1) THEN
            inv_log_util.trace('calling validate_quantities IN (validate_group)' , 'INV_TXN_MANAGER_GRP', 9);
          END IF;

        /*------------------------------------------------------+
        | Validating secondary quantity, only
        | If the item is tracked in both primary AND secondary
        |
        +------------------------------------------------------*/
                l_qty_check := validate_quantities(
                                                  p_rowid               => l_rowid
                                                , p_lot_rowid           => NULL
                                                , p_transaction_type_id => l_transaction_type_id
                                                , p_organization_id     => l_organization_id
                                                , p_inventory_item_id   => l_inventory_item_id
                                                , p_revision            => l_revision
                                                , p_subinventory_code   => l_subinventory_code
                                                , p_locator_id          => l_locator_id
                                                , p_lot_number          => NULL
                                                , p_transaction_quantity    => l_transaction_quantity
                                                , p_transaction_uom    => l_transaction_uom_code
                                                , p_secondary_quantity  => l_secondary_quantity
                                                , p_secondary_uom_code  => l_secondary_uom_code
                                                );
                --{
                IF (l_qty_check) THEN
                   IF (l_debug = 1) THEN
                      inv_log_util.trace('validate_quantities IN (validate_group) - PASSED '  , 'INV_TXN_MANAGER_GRP', 9);
                   END IF;

                   UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                   SET    TRANSACTION_QUANTITY           = l_transaction_quantity,
                          SECONDARY_TRANSACTION_QUANTITY = l_secondary_quantity,
                          SECONDARY_UOM_CODE             = l_secondary_uom_code
                   WHERE  ROWID = l_rowid;

                ELSE
                  -- validation failed
                  IF (l_debug = 1) THEN
                    inv_log_util.trace('validate_quantities IN (validate_group) - FAIL ' || l_msg_data , 'INV_TXN_MANAGER_GRP', 9);
                    inv_log_util.trace('validate_group: TRANSACTION_QUANTITY ' || l_transaction_quantity , 'INV_TXN_MANAGER_GRP', 9);
                    inv_log_util.trace('validate_group: SECONDARY_TRANSACTION_QUANTITY ' || l_secondary_quantity || ' uom2 '|| l_secondary_uom_code ,
                                             'INV_TXN_MANAGER_GRP', 9);
                  END IF;
                END IF;--}
        ELSIF (l_lot_control_code = 2 ) THEN
          IF (l_debug = 1) THEN
              inv_log_util.trace('validate_group: for lot controlled items secondary uom='||l_secondary_uom_code, 'INV_TXN_MANAGER_GRP', 9);
          END IF;
          IF (l_secondary_uom_code <> l_item_secondary_uom_code) THEN
            IF (l_debug = 1) THEN
              inv_log_util.trace('validate_group: sec uom in mti is diff than item sec uom', 'INV_TXN_MANAGER_GRP', 9);
            END IF;
            loaderrmsg('INV_INCORRECT_SECONDARY_UOM','INV_INCORRECT_SECONDARY_UOM');
            errupdate(l_rowid, NULL);
          END IF;
          --Set the default UOM2 if missing
          IF (l_secondary_uom_code IS NULL) THEN
            UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET    SECONDARY_UOM_CODE = l_item_secondary_uom_code
            WHERE  ROWID = l_rowid;
          END IF;
        END IF;--} -- Lot ctl check
      ELSE
        --tracking is primary. no need for sec uom/qty
        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
        SET    SECONDARY_TRANSACTION_QUANTITY = NULL,
               SECONDARY_UOM_CODE             = NULL
        WHERE  ROWID = l_rowid;
      END IF;--}

        EXIT WHEN AA2%NOTFOUND;
        END LOOP;
        CLOSE AA2;

-- INVCONV end fabdi


/*------------------------------------------------------+
| Validating Overcompletion transaction quantity
+------------------------------------------------------*/

    FND_MESSAGE.set_name('INV', 'INV_GREATER_THAN');
    FND_MESSAGE.set_token('ENTITY1','overcompletion_txn_qty');
    FND_MESSAGE.set_token('ENTITY2','zero');

    l_error_exp := FND_MESSAGE.get;

    FND_MESSAGE.set_name('INV', 'INV_GREATER_THAN');
    l_error_code := FND_MESSAGE.get;


    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND NVL(OVERCOMPLETION_TRANSACTION_QTY,1) <= 0;

    l_count := SQL%ROWCOUNT;

    FND_MESSAGE.set_name('INV', 'INV_GREATER_THAN');
    FND_MESSAGE.set_token('ENTITY1','transaction quantity-cap');
    FND_MESSAGE.set_token('ENTITY2','overcompletion_txn_qty');

    l_error_exp := FND_MESSAGE.get;

    FND_MESSAGE.set_name('INV', 'INV_GREATER_THAN');
    l_error_code := FND_MESSAGE.get;



    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
    WHERE TRANSACTION_HEADER_ID = p_header_id
      AND PROCESS_FLAG = 1
      AND OVERCOMPLETION_TRANSACTION_QTY IS NOT NULL
      AND OVERCOMPLETION_TRANSACTION_QTY > TRANSACTION_QUANTITY;

    l_count := l_count + SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating overcompletion quantity ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;


/*------------------------------------------------------+
| Validate distribution account
  +------------------------------------------------------*/

  IF (l_validate_full) THEN --J-dev

     loaderrmsg('INV_INT_DISTCODE','INV_INT_DISTEXP');

     /*Bug#5176266. Made changes to the below UPDATE statement
       to validate the Account effective date against transactions
       date( not sysdate)*/

     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       AND DISTRIBUTION_ACCOUNT_ID IS NOT NULL
         AND NOT EXISTS (
                         SELECT NULL
                         FROM GL_CODE_COMBINATIONS GCC
                         WHERE GCC.CODE_COMBINATION_ID = MTI.DISTRIBUTION_ACCOUNT_ID
                         AND GCC.CHART_OF_ACCOUNTS_ID
                         = (SELECT CHART_OF_ACCOUNTS_ID
                            FROM ORG_ORGANIZATION_DEFINITIONS OOD
                            WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
                         AND GCC.ENABLED_FLAG = 'Y'
                         AND NVL(GCC.START_DATE_ACTIVE, MTI.TRANSACTION_DATE - 1) <= MTI.TRANSACTION_DATE
                         AND NVL(GCC.END_DATE_ACTIVE, MTI.TRANSACTION_DATE + 1) > MTI.TRANSACTION_DATE);

       l_count := SQL%ROWCOUNT;


       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
         SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = p_userid,
         LAST_UPDATE_LOGIN = p_loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 3,
         LOCK_FLAG = 2,
         ERROR_CODE = substrb(l_error_code,1,240),
         ERROR_EXPLANATION = substrb(l_error_exp,1,240)
         WHERE TRANSACTION_HEADER_ID = p_header_id
         AND PROCESS_FLAG = 1
         AND DISTRIBUTION_ACCOUNT_ID IS NULL
           AND (TRANSACTION_SOURCE_TYPE_ID = INV_Globals.G_SourceType_Inventory OR
                TRANSACTION_SOURCE_TYPE_ID >=100)
         AND NVL(OWNING_ORGANIZATION_ID,organization_id) = organization_id
         AND NVL(OWNING_TP_TYPE,2) = 2  -- if it is null we are considering it as normal item..
         -- Added the above two lines for the bug # 5896859
           AND (TRANSACTION_ACTION_ID IN (1,27)
                AND EXISTS (
                            SELECT NULL
                            FROM MTL_SYSTEM_ITEMS MSI,
                            mtl_secondary_inventories MSUB
                            WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                            AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                            AND MSI.INVENTORY_ASSET_FLAG = 'Y'
                            AND MSUB.SECONDARY_INVENTORY_NAME = MTI.SUBINVENTORY_CODE
                            AND MSUB.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                            AND MSUB.ASSET_INVENTORY = 1));


         l_count := l_count + SQL%ROWCOUNT;
         IF (l_debug = 1) THEN
            inv_log_util.trace('Validating distribution account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
         END IF;

  END IF;--J-dev



/*-----------------------------------------------------------+
| Validate freight and freight account
+-----------------------------------------------------------*/


  IF (l_validate_full) THEN --J-dev

     loaderrmsg('INV_INT_FRTCODE','INV_INT_FRTEXP');


     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND TRANSACTION_ACTION_ID in (3,21)
       AND FREIGHT_CODE IS NOT NULL
         AND PROCESS_FLAG = 1
         AND NOT EXISTS (
                         SELECT NULL
                         FROM ORG_FREIGHT FR
                         WHERE FR.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                         AND FR.FREIGHT_CODE    = MTI.FREIGHT_CODE
                         AND NVL(FR.DISABLE_DATE, SYSDATE + 1) > SYSDATE);

       l_count := SQL%ROWCOUNT;
       loaderrmsg('INV_INT_FRTACTCODE','INV_INT_FRTACTEXP');


       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
         SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = p_userid,
         LAST_UPDATE_LOGIN = p_loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 3,
         LOCK_FLAG = 2,
         ERROR_CODE = substrb(l_error_code,1,240),
         ERROR_EXPLANATION = substrb(l_error_exp,1,240)
         WHERE TRANSACTION_HEADER_ID = p_header_id
         AND TRANSACTION_ACTION_ID in (3,21)
         AND TRANSPORTATION_ACCOUNT IS NOT NULL
           AND PROCESS_FLAG = 1
           AND NOT EXISTS (
                           SELECT NULL
                           FROM ORG_FREIGHT FR
                           WHERE FR.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                           AND FR.FREIGHT_CODE    = MTI.FREIGHT_CODE
                           AND FR.DISTRIBUTION_Account = MTI.TRANSPORTATION_ACCOUNT
                           AND NVL(FR.DISABLE_DATE, SYSDATE + 1) > SYSDATE);

         l_count := l_count + SQL%ROWCOUNT;
         IF (l_debug = 1) THEN
            inv_log_util.trace('Validating freight account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
         END IF;
  END IF; --J-dev

/*--------------------------------------------------------+
| Start validation of wip_entity for wip transactions for
| non-CFMs.
|+--------------------------------------------------------*/

  --J-dev This should not be done for WIP MTI records in J.
  -- WIP will do this validation.
  IF (srctypeid = 5 AND wip_constants.dmf_patchset_level< wip_constants.DMF_PATCHSET_J_VALUE) THEN --J-dev
     loaderrmsg('INV_INT_SRCCODE','INV_INT_SRCWIPEXP');


     IF srctypeid = 5 THEN

        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
          SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_userid,
          LAST_UPDATE_LOGIN = p_loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 3,
          LOCK_FLAG = 2,
          ERROR_CODE = substrb(l_error_code,1,240),
          ERROR_EXPLANATION = substrb(l_error_exp,1,240)
          WHERE TRANSACTION_HEADER_ID = p_header_id
          AND PROCESS_FLAG = 1
          AND TRANSACTION_SOURCE_TYPE_ID = 5
          AND UPPER(NVL(FLOW_SCHEDULE,'N')) = 'N'
          AND NOT EXISTS (
                          SELECT NULL
                          FROM WIP_ENTITIES WEN
                          WHERE WEN.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                          AND WEN.WIP_ENTITY_ID = MTI.TRANSACTION_SOURCE_ID);

        l_count := SQL%ROWCOUNT;
        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating wip entity non-CFM ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
     END IF;
  END IF;--J-dev


/*------------------------------------------------------+
|  Start validation of wip_entity for wip transactions
|  that are CFMs
+------------------------------------------------------*/

  --J-dev
  --This validation should not be done for WIP MTI in J.
  --WIP will do this validation in J.

  IF (srctypeid = 5 AND wip_constants.dmf_patchset_level< wip_constants.DMF_PATCHSET_J_VALUE) THEN --J-dev
     loaderrmsg('INV_INT_SRCCODE','INV_INT_SRCCFMEXP');
     IF srctypeid = 5 THEN
        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
          SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_userid,
          LAST_UPDATE_LOGIN = p_loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 3,
          LOCK_FLAG = 2,
          ERROR_CODE = substrb(l_error_code,1,240),
          ERROR_EXPLANATION = substrb(l_error_exp,1,240)
          WHERE TRANSACTION_HEADER_ID = p_header_id
          AND PROCESS_FLAG = 1
          AND TRANSACTION_SOURCE_TYPE_ID = 5
          AND UPPER(NVL(FLOW_SCHEDULE,'N')) = 'Y'
          AND NOT EXISTS (
                          SELECT NULL
                          FROM WIP_ENTITIES WEN
                          WHERE WEN.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                          AND WEN.WIP_ENTITY_ID = MTI.TRANSACTION_SOURCE_ID);

        l_count := SQL%ROWCOUNT;
        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating wip entity CFM ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
     END IF;
  END IF;--J-dev

/*---------------------------------------------------------------+
|  Validating Projects Contracts
|
+----------------------------------------------------------------*/
/* load message to detect source project contracts error*/

  IF (l_validate_full) THEN --J-dev

     loaderrmsg('INV_PROJCON_ERR','INV_PROJCON_ERR');

     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROCESS_FLAG = 3,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND TRANSACTION_SOURCE_TYPE_ID = INV_GLOBALS.G_SourceType_PrjContracts
       AND NOT EXISTS (
                       SELECT NULL
                       FROM   OKE_K_HEADERS_V OKHV
                       WHERE  MTI.TRANSACTION_SOURCE_ID = OKHV.K_HEADER_ID);

     l_count := SQL%ROWCOUNT;
     /*-----------------------------------------------------------+
     | Start validating source_project_id, source_task_id,
       | expenditure_type and expenditure_org_id for miscllaneous
       | trxs that are project related.
       +-----------------------------------------------------------*/

       -- Bug #2505534 Moved validation of source_project_id inside validate_line()

       /* validate source task id */
       loaderrmsg('INV_TASK_ERR','INV_TASK_ERR');


     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
            (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
       AND TRANSACTION_ACTION_ID IN (1, 27 )
       AND PROCESS_FLAG = 1
       AND EXISTS (
                   SELECT NULL
                   FROM MTL_TRANSACTION_TYPES MTTY
                   WHERE MTTY.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                   AND MTTY.TYPE_CLASS = 1 )
       AND NOT EXISTS (
                       SELECT NULL
                       FROM PA_TASKS_LOWEST_V TSK
                       WHERE TSK.PROJECT_ID = MTI.SOURCE_PROJECT_ID AND
                       TSK.TASK_ID = MTI.SOURCE_TASK_ID );


     l_count := l_count + SQL%ROWCOUNT;

     /* validate expenditure type */
     /* get value of profile INV:Miscllaneous Project transaction to see
     if the expenditure type field is required and has a value or
       that it does not have a user entered value
       INV: Project Miscellaneous Transaction Expenditure Type
       INV_PROJ_MISC_TXN_EXP_TYPE
       user_entered = 2 (user must provide valid exp type)
       system derived = 1 (user must NOT provide any value for exp type)
       */

       SELECT FND_PROFILE.VALUE('INV_PROJ_MISC_TXN_EXP_TYPE')
       INTO l_profile
       FROM dual;

     IF SQL%FOUND THEN
        if l_profile = '2' THEN
           exp_type_required := 2 ;
         else
           exp_type_required := 1 ;
        end if;
      ELSE
        exp_type_required := 1;
     END IF;

     loaderrmsg('INV_ETYPE_ERR','INV_ETYPE_ERR');
     IF  exp_type_required = 2 THEN

        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
          SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_userid,
          LAST_UPDATE_LOGIN = p_loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 3,
          LOCK_FLAG = 2,
          ERROR_CODE = substrb(l_error_code,1,240),
          ERROR_EXPLANATION = substrb(l_error_exp,1,240)
          WHERE TRANSACTION_HEADER_ID = p_header_id
          AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
               (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
          AND TRANSACTION_ACTION_ID IN (1, 27 )
          AND PROCESS_FLAG = 1
          AND EXISTS (
                      SELECT NULL
                      FROM MTL_TRANSACTION_TYPES MTTY
                      WHERE MTTY.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                      AND MTTY.TYPE_CLASS = 1 )
          AND NOT EXISTS (
                          SELECT NULL
                          FROM CST_PROJ_EXP_TYPES_VAL_V CET
                          WHERE CET.EXPENDITURE_TYPE = MTI.EXPENDITURE_TYPE
                          AND CET.COST_ELEMENT_ID = 1
                          AND TRUNC(MTI.TRANSACTION_DATE) >= CET.SYS_LINK_START_DATE
                          AND TRUNC(MTI.TRANSACTION_DATE) <= NVL(SYS_LINK_END_DATE,
                                                                 MTI.TRANSACTION_DATE + 1)
                          AND TRUNC(MTI.TRANSACTION_DATE) >= CET.EXP_TYPE_START_DATE
                          AND TRUNC(MTI.TRANSACTION_DATE) <= NVL(EXP_TYPE_END_DATE,
                                                                 MTI.TRANSACTION_DATE+1)) ;

        l_count := l_count + SQL%ROWCOUNT;

      ELSE
        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
          SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_userid,
          LAST_UPDATE_LOGIN = p_loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 3,
          LOCK_FLAG = 2,
          ERROR_CODE = substrb(l_error_code,1,240),
          ERROR_EXPLANATION = substrb(l_error_exp,1,240)
          WHERE TRANSACTION_HEADER_ID = p_header_id
          AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
               (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
          AND TRANSACTION_ACTION_ID IN (1, 27 )
          AND PROCESS_FLAG = 1
          AND EXISTS (
                      SELECT NULL
                      FROM MTL_TRANSACTION_TYPES MTTY
                      WHERE MTTY.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                      AND MTTY.TYPE_CLASS = 1 )
          AND MTI.EXPENDITURE_TYPE IS NOT NULL ;

          l_count := l_count + SQL%ROWCOUNT;

     END IF;

     /* validate expenditure org id */
     --Bug #2505534 moved validation code inside validate_line()
     /*+--------------------------------------------------------------+
     | Now validate cost group ids, these must exist and must be    |
       | enabled in terms of date                                     |
       +--------------------------------------------------------------+*/
       loaderrmsg('INV_INT_CSTGRP','INV_INT_CSTEXP');

     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       PROCESS_FLAG = 3,
       LOCK_FLAG = 2,
       ERROR_CODE = substrb(l_error_code,1,240),
       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND PROCESS_FLAG = 1
       --AND TRANSACTION_ACTION_ID = 24
       --AND TRANSACTION_SOURCE_TYPE_ID IN (13,15)
       AND COST_GROUP_ID IS NOT NULL
         AND NOT EXISTS (
                         SELECT NULL
                         FROM CST_COST_GROUPS CCG
                         WHERE CCG.COST_GROUP_ID = MTI.COST_GROUP_ID
                         AND NVL(CCG.ORGANIZATION_ID, MTI.ORGANIZATION_ID)
                         =MTI.ORGANIZATION_ID
                         AND TRUNC(NVL(CCG.DISABLE_DATE,SYSDATE+1)) >= TRUNC(SYSDATE) ) ;

       l_count := SQL%ROWCOUNT;
       IF (l_debug = 1) THEN
          inv_log_util.trace('Validating cost group ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
       END IF;

  END IF;--J-dev


  /*+-----------------------------------------------------------------------+
  | Now validate transfer cost group ids, these must exist and must be    |
    | enabled in terms of date                                              |
    +-----------------------------------------------------------------------+*/
    loaderrmsg('INV_INT_XCSTGRP','INV_INT_XCSTEXP');

  UPDATE MTL_TRANSACTIONS_INTERFACE MTI
    SET LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = p_userid,
    LAST_UPDATE_LOGIN = p_loginid,
    PROGRAM_UPDATE_DATE = SYSDATE,
    PROCESS_FLAG = 3,
    LOCK_FLAG = 2,
    ERROR_CODE = substrb(l_error_code,1,240),
    ERROR_EXPLANATION = substrb(l_error_exp,1,240)
    WHERE TRANSACTION_HEADER_ID = p_header_id
    AND PROCESS_FLAG = 1
    AND TRANSFER_COST_GROUP_ID IS NOT NULL
      AND NOT EXISTS (
                      SELECT NULL
                      FROM CST_COST_GROUPS CCG
                      WHERE CCG.COST_GROUP_ID = MTI.TRANSFER_COST_GROUP_ID
                      AND NVL(CCG.ORGANIZATION_ID, MTI.ORGANIZATION_ID) =
                      MTI.ORGANIZATION_ID
                      AND TRUNC(NVL(CCG.DISABLE_DATE,SYSDATE+1)) >= TRUNC(SYSDATE) ) ;


    l_count := SQL%ROWCOUNT;
    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating xfer cost group ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

    /*-------------------------------------------------------------+
    | Validate the interface table for Planning Organization
      | to be used for VMI transactions
      +-------------------------------------------------------------*/

      loaderrmsg('INV_INT_PLANORG','INV_INT_PLANORG');

/*Bug#4951558. In the where clause of the below UPDATE statement, added the
  condition, 'paa.using_organization_code = -1' because
  'using_organization_code' is set to -1 in the table, 'po_asl_attributes' if
  the global flag is set to 'Yes' in the ASL for an (item, supplier)
  combination*/

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
      SET LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = p_userid,
      LAST_UPDATE_LOGIN = p_loginid,
      PROGRAM_UPDATE_DATE = SYSDATE,
      PROCESS_FLAG = 3,
      LOCK_FLAG = 2,
      ERROR_CODE = substrb(l_error_code,1,240),
      ERROR_EXPLANATION = substrb(l_error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = p_header_id
      AND  PROCESS_FLAG = 1
      AND PLANNING_ORGANIZATION_ID IS NOT NULL
        AND planning_tp_type = 1
        AND planning_organization_id <> ORGANIZATION_ID
        AND NOT EXISTS (
                        SELECT NULL
                        FROM po_asl_attributes paa
                        WHERE PAA.vendor_site_id = mti.planning_organization_id
                        AND PAA.ITEM_ID = MTI.INVENTORY_ITEM_ID
                        AND (paa.using_organization_id = -1 OR
                             paa.using_organization_id = mti.organization_id));

      l_count := SQL%ROWCOUNT;
      IF (l_debug = 1) THEN
         inv_log_util.trace('Validating group Plann Org:Supplier' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
      END IF;

      --if the planning _org is a inventory org it should be in
      --mtl_parameters.

      UPDATE MTL_TRANSACTIONS_INTERFACE MTI
        SET LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = p_userid,
        LAST_UPDATE_LOGIN = p_loginid,
        PROGRAM_UPDATE_DATE = SYSDATE,
        PROCESS_FLAG = 3,
        LOCK_FLAG = 2,
        ERROR_CODE = substrb(l_error_code,1,240),
        ERROR_EXPLANATION = substrb(l_error_exp,1,240)
        WHERE TRANSACTION_HEADER_ID = p_header_id
        AND  PROCESS_FLAG = 1
        AND PLANNING_ORGANIZATION_ID IS NOT NULL
          AND planning_tp_type = 2
          AND planning_organization_id <> ORGANIZATION_ID
          AND NOT EXISTS (
                          SELECT NULL
                          FROM mtl_parameters mp
                          where
                          mp.organization_id = mti.planning_organization_id);


        l_count := SQL%ROWCOUNT;
        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating group Planning Org:Inventory Org' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
        END IF;


        /*-------------------------------------------------------------+
        | Validate the Interface table for LPN
          +-------------------------------------------------------------*/

          loaderrmsg('INV_INT_LPN','INV_INT_LPN');


        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
          SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_userid,
          LAST_UPDATE_LOGIN = p_loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 3,
          LOCK_FLAG = 2,
          ERROR_CODE = substrb(l_error_code,1,240),
          ERROR_EXPLANATION = substrb(l_error_exp,1,240)
          WHERE TRANSACTION_HEADER_ID = p_header_id
          AND  PROCESS_FLAG = 1
          AND  lpn_id IS NOT NULL
            AND NOT EXISTS (
                            SELECT NULL
                            FROM wms_license_plate_numbers wlpn
                            where
                            wlpn.lpn_id = mti.lpn_id);


          l_count := SQL%ROWCOUNT;
          IF (l_debug = 1) THEN
             inv_log_util.trace('Validating group LPN:LPN_ID' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
          END IF;

          --Validate Xfr LPN

          UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_userid,
            LAST_UPDATE_LOGIN = p_loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 3,
            LOCK_FLAG = 2,
            ERROR_CODE = substrb(l_error_code,1,240),
            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
            WHERE TRANSACTION_HEADER_ID = p_header_id
            AND  PROCESS_FLAG = 1
            AND  TRANSFER_LPN_ID IS NOT NULL
              AND NOT EXISTS (
                              SELECT NULL
                              FROM wms_license_plate_numbers wlpn
                              where
                              wlpn.lpn_id = mti.transfer_lpn_id

                          /* for bug 6903894 */
         AND (
                --WIP Assembly Completion
                ((TRANSACTION_TYPE_ID = 44) OR (TRANSACTION_SOURCE_TYPE_ID = 5 and TRANSACTION_ACTION_ID = 31))
                AND lpn_context IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV, WMS_CONTAINER_PUB.LPN_CONTEXT_WIP, WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED, WMS_CONTAINER_PUB.LPN_PREPACK_FOR_WIP)

                OR
                --Account Alias Issue
                ((TRANSACTION_TYPE_ID = 31) OR (TRANSACTION_SOURCE_TYPE_ID = 6 and TRANSACTION_ACTION_ID = 1))
                AND lpn_context  IN  (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)

	        OR --bug10009302
                --Miscellaneous Receipt
                ( (TRANSACTION_TYPE_ID = 42) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 27)
                  OR (TRANSACTION_SOURCE_TYPE_ID >= 100 and TRANSACTION_ACTION_ID = 27)  ) /*Bug11858317 */
                AND lpn_context  IN  (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)

	        OR
                --Miscellaneous Issue
                ((TRANSACTION_TYPE_ID = 32) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 1))
                AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)

                OR
                --Issue Components to WIP
                ((TRANSACTION_TYPE_ID = 35) OR (TRANSACTION_SOURCE_TYPE_ID = 5 and TRANSACTION_ACTION_ID = 1))
                AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV)

                OR
                --Account Alias Receipt
                ((TRANSACTION_TYPE_ID = 41) OR (TRANSACTION_SOURCE_TYPE_ID = 6 and TRANSACTION_ACTION_ID = 27))
                AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)

               OR
                --Subinventory Transfer
        (
		((TRANSACTION_TYPE_ID = 2) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 2)) OR
		(TRANSACTION_SOURCE_TYPE_ID >= 100 and TRANSACTION_ACTION_ID = 2)   /* 13076071  */
		)
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)

        OR
        --Direct Interorganization Transfer
        ((TRANSACTION_TYPE_ID = 3) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 3))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_WIP,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)

        OR
        --Intransit Shipment
        ((TRANSACTION_TYPE_ID = 21) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 21))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_WIP,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED)
        OR
        --Average Cost Update
        ((TRANSACTION_TYPE_ID = 80) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 24))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_WIP,WMS_CONTAINER_PUB.LPN_CONTEXT_RCV,WMS_CONTAINER_PUB.LPN_CONTEXT_INTRANSIT,WMS_CONTAINER_PUB.LPN_PREPACK_FOR_WIP)

        OR
        --Sales Order Shipment
        ((TRANSACTION_TYPE_ID = 33) OR (TRANSACTION_SOURCE_TYPE_ID = 2 and TRANSACTION_ACTION_ID = 1))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PACKING,WMS_CONTAINER_PUB.LPN_LOADED_FOR_SHIPMENT,WMS_CONTAINER_PUB.LPN_CONTEXT_PICKED)

        OR
        --Return Assemblies to WIP
        ((TRANSACTION_TYPE_ID = 17) OR (TRANSACTION_SOURCE_TYPE_ID = 5 and TRANSACTION_ACTION_ID = 32))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED,WMS_CONTAINER_PUB.LPN_PREPACK_FOR_WIP)


        OR

      -- Bug 7417173 - Container Split --bug10149138
(((TRANSACTION_TYPE_ID=89) OR (TRANSACTION_SOURCE_TYPE_ID = 13 AND TRANSACTION_ACTION_ID = 52))
AND lpn_context NOT IN (WMS_CONTAINER_PUB.LPN_CONTEXT_STORES))

	OR --Bug 10009302
        --Packing
        (((TRANSACTION_TYPE_ID = 87) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 50))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED,WMS_CONTAINER_PUB.LPN_LOADED_FOR_SHIPMENT,WMS_CONTAINER_PUB.LPN_CONTEXT_PICKED))

	OR --Bug 12944629
        --lot translate
        (((TRANSACTION_TYPE_ID = 84) OR (TRANSACTION_SOURCE_TYPE_ID = 13 and TRANSACTION_ACTION_ID = 42))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED))

	OR

        --Return Components from WIP
        ((TRANSACTION_TYPE_ID = 43) OR (TRANSACTION_SOURCE_TYPE_ID = 5 and TRANSACTION_ACTION_ID = 27))
        AND lpn_context  IN (WMS_CONTAINER_PUB.LPN_CONTEXT_INV,WMS_CONTAINER_PUB.LPN_CONTEXT_WIP,WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED,WMS_CONTAINER_PUB.LPN_PREPACK_FOR_WIP)--bug 10153918

        )
        /* for bug  6903894*/

                              );


            l_count := SQL%ROWCOUNT;
            IF (l_debug = 1) THEN
               inv_log_util.trace('Validating group LPN:XFER_LPN_ID' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
            END IF;


            --Validate Content LPN

            UPDATE MTL_TRANSACTIONS_INTERFACE MTI
              SET LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATED_BY = p_userid,
              LAST_UPDATE_LOGIN = p_loginid,
              PROGRAM_UPDATE_DATE = SYSDATE,
              PROCESS_FLAG = 3,
              LOCK_FLAG = 2,
              ERROR_CODE = substrb(l_error_code,1,240),
              ERROR_EXPLANATION = substrb(l_error_exp,1,240)
              WHERE TRANSACTION_HEADER_ID = p_header_id
              AND  PROCESS_FLAG = 1
              AND  CONTENT_LPN_ID IS NOT NULL
                AND NOT EXISTS (
                                SELECT NULL
                                FROM wms_license_plate_numbers wlpn
                                where
                                wlpn.lpn_id = mti.CONTENT_LPN_ID);


              l_count := SQL%ROWCOUNT;
              IF (l_debug = 1) THEN
                 inv_log_util.trace('Validating group LPN:Content_LPN_ID' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
              END IF;


/*-------------------------------------------------------------+
| Update the interface table with shippable item flag
| to be used for OE transactions
+-------------------------------------------------------------*/



  IF (srctypeid = INV_GLOBALS.G_SourceType_SalesOrder OR
      srctypeid = INV_GLOBALS.G_SourceType_IntOrder OR
      srctypeid = INV_GLOBALS.G_SourceType_PrjContracts) THEN
     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = p_userid,
       LAST_UPDATE_LOGIN = p_loginid,
       PROGRAM_UPDATE_DATE = SYSDATE,
       SHIPPABLE_FLAG = (SELECT SHIPPABLE_ITEM_FLAG
                         FROM MTL_SYSTEM_ITEMS MSI
                         WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                         AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
       WHERE TRANSACTION_HEADER_ID = p_header_id
       AND INVENTORY_ITEM_ID IS NOT NULL
         AND TRANSACTION_SOURCE_TYPE_ID in (2,8,16)
         AND PROCESS_FLAG = 1;

  END IF;

  /*-----------------------------------------------------------+
  | Deriving values for inventory_item_id and wip_entity_type
    | for WIP transactions. Do this for bot CFM and non-CFMs.
    +------------------------------------------------------------*/

    --J-dev
    --This validation should not be done for WIP MTI in J.
    --WIP will do this validation in J.

     IF (srctypeid = 5 AND wip_constants.dmf_patchset_level< wip_constants.DMF_PATCHSET_J_VALUE) THEN --J-dev

        IF (srctypeid = 5) THEN
           UPDATE MTL_TRANSACTIONS_INTERFACE MTI
             SET LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = p_userid,
             LAST_UPDATE_LOGIN = p_loginid,
             PROGRAM_UPDATE_DATE = SYSDATE,
             INVENTORY_ITEM_ID = (SELECT DECODE(MTI.TRANSACTION_ACTION_ID,30,
                                                PRIMARY_ITEM_ID,31,PRIMARY_ITEM_ID,32,
                                                PRIMARY_ITEM_ID,
                                                MTI.INVENTORY_ITEM_ID) -- CFM Scrap Transactions
                                  FROM WIP_ENTITIES WE
                                  WHERE WE.WIP_ENTITY_ID  = MTI.TRANSACTION_SOURCE_ID
                                  AND WE.ORGANIZATION_ID = MTI.ORGANIZATION_ID),
             WIP_ENTITY_TYPE = (SELECT ENTITY_TYPE
                                FROM WIP_ENTITIES WE
                                WHERE WE.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                                AND WE.WIP_ENTITY_ID = MTI.TRANSACTION_SOURCE_ID)
             WHERE TRANSACTION_HEADER_ID = p_header_id
             AND TRANSACTION_SOURCE_TYPE_ID = 5
             AND PROCESS_FLAG = 1;


           /*-------------------------------------------------------------+
           | Update MTI with right op seq num for non-CFMs
             +--------------------------------------------------------------*/

             UPDATE MTL_TRANSACTIONS_INTERFACE MTI
             SET LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = p_userid,
             LAST_UPDATE_LOGIN = p_loginid,
             PROGRAM_UPDATE_DATE = SYSDATE,
             OPERATION_SEQ_NUM = (SELECT nvl(max(operation_seq_num),1)
                                  FROM WIP_OPERATIONS WO
                                  WHERE WO.WIP_ENTITY_ID  = MTI.TRANSACTION_SOURCE_ID
                                  AND WO.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
             WHERE TRANSACTION_HEADER_ID = p_header_id
             AND TRANSACTION_SOURCE_TYPE_ID = 5
             AND UPPER(NVL(FLOW_SCHEDULE,'N')) = 'N'
             AND TRANSACTION_ACTION_ID IN (32,31)
             AND PROCESS_FLAG = 1;

        END IF;
     END IF;--J-dev

/*-------------------------------------------------------------+
| If a single transaction within a group fails all transactions
| in that group should not be processed.
+--------------------------------------------------------------*/

      loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

      UPDATE MTL_TRANSACTIONS_INTERFACE MTI
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_userid,
            LAST_UPDATE_LOGIN = p_loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 3,
            LOCK_FLAG = 2,
            ERROR_CODE = substrb(l_error_code,1,240)
        WHERE TRANSACTION_HEADER_ID = p_header_id
        AND PROCESS_FLAG = 1
        AND EXISTS
            (SELECT 'Y'
               FROM MTL_TRANSACTIONS_INTERFACE MTI2
              WHERE MTI2.TRANSACTION_HEADER_ID = p_header_id
                AND MTI2.PROCESS_FLAG = 3
                AND MTI2.ERROR_CODE IS NOT NULL
                AND MTI2.TRANSACTION_BATCH_ID = MTI.TRANSACTION_BATCH_ID);

/* Commented following and Added EXISTS clause above for bug 8444982

        AND TRANSACTION_BATCH_ID IN
               (SELECT DISTINCT MTI2.TRANSACTION_BATCH_ID
                FROM MTL_TRANSACTIONS_INTERFACE MTI2
                WHERE MTI2.TRANSACTION_HEADER_ID = p_header_id
                  AND MTI2.PROCESS_FLAG = 3
                  AND MTI2.ERROR_CODE IS NOT NULL);

*/
-- start of fix for eam
-- added following validation on rebuild_item_id (valid in MSI and transactable)
-- and rebuild_activity_id (valid in MSI)
/*----------------------------------------------------+
| validate rebuild item id and rebuild activity id where it is specified
+----------------------------------------------------*/


   IF (l_validate_full) THEN --J-dev

      loaderrmsg('INV_REB_ITMCODE','INV_REB_ITMEXP');

      /* Bug# 5264549 : made changes to the REBUILD_ITEM_ID query to
         update EAM validations from Transaction Manager */

      UPDATE MTL_TRANSACTIONS_INTERFACE MTI
        SET LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = p_userid,
        LAST_UPDATE_LOGIN = p_loginid,
        PROGRAM_UPDATE_DATE = SYSDATE,
        PROCESS_FLAG = 3,
        LOCK_FLAG = 2,
        ERROR_CODE = substrb(l_error_code,1,240),
        ERROR_EXPLANATION = substrb(l_error_exp,1,240)
        WHERE TRANSACTION_HEADER_ID = p_header_id
        AND PROCESS_FLAG = 1
        AND ((REBUILD_ITEM_ID IS NOT NULL
              AND NOT EXISTS (
                              SELECT NULL
                              FROM MTL_SYSTEM_ITEMS MSI, MTL_PARAMETERS MP
                              WHERE MSI.INVENTORY_ITEM_ID = MTI.REBUILD_ITEM_ID
                              AND MSI.ORGANIZATION_ID = MP.ORGANIZATION_ID
                              AND MP.MAINT_ORGANIZATION_ID = MTI.ORGANIZATION_ID
                              AND MSI.EAM_ITEM_TYPE = 3
                              AND MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y'))

              OR (REBUILD_ACTIVITY_ID IS NOT NULL
                 AND NOT EXISTS (
                                 SELECT NULL
                                 FROM MTL_SYSTEM_ITEMS MSI
                                 WHERE MSI.INVENTORY_ITEM_ID = MTI.REBUILD_ACTIVITY_ID
                                 AND MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
                                 AND MSI.EAM_ITEM_TYPE = 2)));

             l_count := SQL%ROWCOUNT;
             IF (l_debug = 1) THEN
                inv_log_util.trace('Validating rebuild items ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
             END IF;
             -- end of fix for eam

   END IF;--J-dev

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FND_MESSAGE.clear;


EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          inv_log_util.trace('Error in validate_group : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
          inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.clear;

END validate_group;





/******* LINE VALIDATION OBJECTS  ***************/

/******************************************************************
 *
 * lotcheck
 *
 ******************************************************************/
FUNCTION lotcheck(p_rowid VARCHAR2, p_orgid NUMBER, p_itemid NUMBER, p_intid NUMBER,
               p_priuom VARCHAR2, p_trxuom VARCHAR2, p_lotuniq NUMBER,
               p_shlfcode NUMBER, p_shlfdays NUMBER, p_serctrl NUMBER, p_srctype NUMBER, p_acttype NUMBER,
               p_is_wsm_enabled VARCHAR2,
               -- INVCONV start fabdi
               p_trx_typeid NUMBER, p_revision VARCHAR2, p_subinvtory_code VARCHAR2, p_locator NUMBER, serial_tagged NUMBER)
               -- INVCONV end fabdi

RETURN BOOLEAN
IS
  -- INVCONV fabdi start
  CURSOR INT3 IS
  SELECT LOT_NUMBER,
         TRANSACTION_QUANTITY,
        -- INVCONV start fabdi
         SECONDARY_TRANSACTION_QUANTITY,
         GRADE_CODE,
         RETEST_DATE,
         MATURITY_DATE,
         PARENT_LOT_NUMBER,
         ORIGINATION_DATE,
         ORIGINATION_TYPE,
         EXPIRATION_ACTION_CODE,
         EXPIRATION_ACTION_DATE,
         LOT_EXPIRATION_DATE,
         HOLD_DATE,
         REASON_ID,
         -- INVCONV end fabdi
         SERIAL_TRANSACTION_TEMP_ID,
         fnd_date.date_to_canonical(LOT_EXPIRATION_DATE),
         ROWID,
         parent_object_type,      --R12 Genealogy enhancements
         parent_object_id,        --R12 Genealogy enhancements
         parent_object_number,    --R12 Genealogy enhancements
         parent_item_id,          --R12 Genealogy enhancements
         parent_object_type2,     --R12 Genealogy enhancements
         parent_object_id2,       --R12 Genealogy enhancements
         parent_object_number2,    --R12 Genealogy enhancements
	 status_id                -- Material Status Enhancement - Tracking bug: 13519864
  FROM MTL_TRANSACTION_LOTS_INTERFACE
  WHERE TRANSACTION_INTERFACE_ID = p_intid;
  -- INVCONV fabdi end



    l_lotnum VARCHAR2(80); -- changed lot_number to 80,  inconv
    --- mrana changed to type ROWID   l_lotrowid VARCHAR2(20);
    l_lotrowid ROWID;
    l_lotexpdate VARCHAR2(22);
    l_userid NUMBER := -1; --prg_info.userid;
    l_reqstid NUMBER := -1; -- prg_info.reqstid;
    l_applid NUMBER := -1; -- prg_info.appid;
    l_progid NUMBER := -1; -- prg_info.progid;
    l_loginid NUMBER := -1; -- prg_info.loginid;
    l_lotqty NUMBER;
    l_lotpriqty NUMBER;
    l_sertempid NUMBER;
    l_tnum NUMBER;

        -- INVCONV start fabdi
    L_parent_object_type      NUMBER;    --R12 Genealogy enhancements
    L_parent_object_id        NUMBER;    --R12 Genealogy enhancements
    L_parent_object_number    NUMBER;    --R12 Genealogy enhancements
    L_parent_item_id          NUMBER;    --R12 Genealogy enhancements
    L_parent_object_type2     NUMBER;    --R12 Genealogy enhancements
    L_parent_object_id2       NUMBER;    --R12 Genealogy enhancements
    L_parent_object_number2   NUMBER;    --R12 Genealogy enhancements
    l_table  VARCHAR2(10);
    l_rowid  ROWID;
    l_serrowid  ROWID;
    l_fm_serial_number  VARCHAR2(30);
    l_to_serial_number  VARCHAR2(30);
    l_process_enabled_flag VARCHAR2(1); --ADM bug 9959125

    /* get copy lot attribute flag  */
        CURSOR get_org_copy_lot_flag   IS
    SELECT  copy_lot_attribute_flag,
            lot_number_generation,
            nvl(process_enabled_flag, 'N') --ADM bug 9959125
    FROM  mtl_parameters
    WHERE  organization_id = p_orgid;

       /* get item information */
    CURSOR  c_get_item_info IS
    SELECT COPY_LOT_ATTRIBUTE_FLAG , child_lot_flag
        from mtl_system_items
        WHERE inventory_item_id = p_itemid
    AND  organization_id   = p_orgid;

    -- nsinghi bug 5209065. Added the cursor.
    CURSOR cur_get_interface_id IS
       SELECT transaction_interface_id
       FROM MTL_TRANSACTIONS_INTERFACE
       WHERE ROWID = p_rowid;

    l_item_copy_lot_attribute_flag VARCHAR2(1);
    l_org_copy_lot_attribute_flag VARCHAR2(1);
    l_lot_number_generation NUMBER;
    l_copy_lot_attribute_flag  VARCHAR2(1);
    l_child_lot_enabled  VARCHAR2(1);

        l_transaction_uom_code VARCHAR(3);
        l_secondary_quantity NUMBER;
        l_secondary_uom_code VARCHAR(3);
        l_qty_check BOOLEAN;

        l_grade_code  VARCHAR2(250);
        l_retest_date  DATE;
        l_maturity_date    DATE;
        l_parent_lot_number VARCHAR2(80);
        l_origination_date DATE;
        l_origination_type    NUMBER;
        l_expiration_action_code  VARCHAR2(80);
        l_expiration_action_date   DATE    ;
        l_expiration_date     DATE;
        l_hold_date     DATE;
        l_attr_check boolean;
        l_error_message  varchar2(200);
        l_reason_id number;

        l_return_status  VARCHAR(3);
        l_msg_count NUMBER;
        l_msg_data VARCHAR(200);

        -- INVCONV end fabdi
        l_interface_id NUMBER; -- nsinghi bug 5209065
	l_status_id number := NULL; -- Material Status Enhancement - Tracking bug: 13519864
	l_default_status_id number:= NULL; -- Material Status Enhancement - Tracking bug: 13519864
	l_allow_status_entry VARCHAR2(3)   := NVL(fnd_profile.VALUE('INV_ALLOW_ONHAND_STATUS_ENTRY'), 'N');  -- Material Status Enhancement - Tracking bug: 13519864
BEGIN
g_pkg_name := 'Lot_check';

   if (l_debug is null) then
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    end if;
    if l_debug = 1 then
        mydebug ('In lot check ...' );
        mydebug ('p_rowid : ' || p_rowid );
        mydebug ('p_orgid  : ' || p_orgid  );
        mydebug ('p_itemid  : ' || p_itemid  );
        mydebug ('p_intid  : ' || p_intid  );
        mydebug ('p_priuom  : ' || p_priuom  );
        mydebug ('p_trxuom  : ' || p_trxuom  );
        mydebug ('p_lotuniq  : ' || p_lotuniq  );
        mydebug ('p_shlfcode  : ' || p_shlfcode  );
        mydebug ('p_shlfdays  : ' || p_shlfdays  );
        mydebug ('p_serctrl  : ' || p_serctrl  );
        mydebug ('p_srctype : ' || p_srctype );
        mydebug ('p_acttype  : ' || p_acttype  );
        mydebug ('p_trx_typeid  : ' || p_trx_typeid  );
        mydebug ('p_revision  : ' || p_revision  );
        mydebug ('p_subinvtory_code : ' || p_subinvtory_code );
        mydebug ('p_locator  : ' || p_locator  );
        mydebug ('p_is_wsm_enabled : ' || p_is_wsm_enabled );
    end if;

    -- INVCONV start fabdi
    IF (l_debug = 1) THEN
        inv_log_util.trace('invconv: inside lotcheck..', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

        /* GET Copy Lot Attribute_flag */

    OPEN get_org_copy_lot_flag;
    FETCH get_org_copy_lot_flag INTO l_org_copy_lot_attribute_flag, l_lot_number_generation, l_process_enabled_flag; --ADM bug 9959125
    CLOSE get_org_copy_lot_flag;

    /* Get item info */
    OPEN c_get_item_info;
    FETCH c_get_item_info INTO l_item_copy_lot_attribute_flag, l_child_lot_enabled;
    CLOSE c_get_item_info;

    IF  l_lot_number_generation = 1 THEN
         l_copy_lot_attribute_flag := NVL(l_org_copy_lot_attribute_flag,'N') ;
    ELSIF  l_lot_number_generation IN (2,3) THEN
         l_copy_lot_attribute_flag :=  NVL(l_item_copy_lot_attribute_flag,'N') ;
    END IF;
        -- INVCONV end fabdi

    --WHENEVER NOT FOUND CONTINUE;

    loaderrmsg('INV_INT_LOTCODE','INV_INT_LOTEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = l_userid,
           LAST_UPDATE_LOGIN = l_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE ROWID = p_rowid
      AND ABS(TRANSACTION_QUANTITY) <>
           (SELECT ABS(SUM(TRANSACTION_QUANTITY))
            FROM MTL_TRANSACTION_LOTS_INTERFACE MTLI
            WHERE MTLI.TRANSACTION_INTERFACE_ID = p_intid);

    IF SQL%FOUND THEN
        return(FALSE);
    END IF;

    IF p_lotuniq = 1 THEN
          FND_MESSAGE.set_name('INV','INV_INT_LOTUNIQCODE');
          l_error_code := FND_MESSAGE.get;

        UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = l_userid,
               LAST_UPDATE_LOGIN = l_loginid,
               PROGRAM_APPLICATION_ID = l_applid,
               PROGRAM_ID = l_progid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               REQUEST_ID = l_reqstid,
               ERROR_CODE = substrb(l_error_code,1,240)
         WHERE TRANSACTION_INTERFACE_ID = p_intid
           AND EXISTS (
               SELECT NULL
               FROM MTL_LOT_NUMBERS MLN
               WHERE MLN.LOT_NUMBER = MTLI.LOT_NUMBER
                 AND MLN.INVENTORY_ITEM_ID <> p_itemid);

        IF SQL%FOUND THEN
                FND_MESSAGE.set_name('INV','INV_INT_LOTUNIQEXP');
                l_error_exp := FND_MESSAGE.get;

            UPDATE MTL_TRANSACTIONS_INTERFACE MTI
               SET LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = l_userid,
                   LAST_UPDATE_LOGIN = l_loginid,
                   PROGRAM_UPDATE_DATE = SYSDATE,
                   PROCESS_FLAG = 3,
                   LOCK_FLAG = 2,
                   ERROR_CODE = substrb(l_error_code,1,240),
                   ERROR_EXPLANATION = substrb(l_error_exp,1,240)
             WHERE ROWID = p_rowid;

            return(FALSE);
        END IF;

    END IF;

    OPEN INT3;

    while (TRUE) LOOP

        FETCH INT3 INTO
            l_lotnum,
            l_lotqty,
            -- INVCONV start fabdi
            l_secondary_quantity,
            l_grade_code,
            l_retest_date,
            l_maturity_date,
            l_parent_lot_number,
            l_origination_date,
            l_origination_type,
            l_expiration_action_code ,
            l_expiration_action_date,
            l_expiration_date ,
            l_hold_date ,
            l_reason_id,
            -- INVCONV end fabdi
            l_sertempid,
            l_lotexpdate,
            l_lotrowid,
            l_parent_object_type,      --R12 Genealogy enhancements
            l_parent_object_id,        --R12 Genealogy enhancements
            l_parent_object_number,    --R12 Genealogy enhancements
            l_parent_item_id,          --R12 Genealogy enhancements
            l_parent_object_type2,     --R12 Genealogy enhancements
            l_parent_object_id2,       --R12 Genealogy enhancements
            l_parent_object_number2,   --R12 Genealogy enhancements
	    l_status_id;               --Material Status Enhancement - Tracking bug: 13519864

        IF int3%NOTFOUND THEN
           CLOSE int3;
           return(true);
        END IF;

    BEGIN

-- INVCONV start fabdi
    l_transaction_uom_code := p_trxuom;

    IF (l_debug = 1) THEN
        inv_log_util.trace('lotcheck: calling validate_quantities', 'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_object_type: ' || l_parent_object_type,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_object_id: ' || l_parent_object_id,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_object_number: ' || l_parent_object_number,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_item_id: ' || l_parent_item_id,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_object_type2: ' || l_parent_object_type2,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_object_id2: ' || l_parent_object_id2,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_parent_object_number2: ' || l_parent_object_number2,'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('l_sertempid: ' || l_sertempid,'INV_TXN_MANAGER_GRP', 9);

    END IF;


    /*------------------------------------------------------+
     | Validating quantity both (primary and secondary qty)
     | in MTLT, only
     | If the item is tracked in both primary AND secondary
     |
     +------------------------------------------------------*/

    l_qty_check := validate_quantities(
                                                  p_rowid               => p_rowid
                                                , p_lot_rowid           => l_lotrowid
                                                , p_transaction_type_id => p_trx_typeid
                                                , p_organization_id     => p_orgid
                                                , p_inventory_item_id   => p_itemid
                                                , p_revision            => p_revision
                                                , p_subinventory_code   => p_subinvtory_code
                                                , p_locator_id          => p_locator
                                                , p_lot_number          => l_lotnum
                                                , p_transaction_quantity => l_lotqty
                                                , p_transaction_uom     => l_transaction_uom_code
                                                , p_secondary_quantity  => l_secondary_quantity
                                                , p_secondary_uom_code  => l_secondary_uom_code
                                                );


                IF (l_qty_check) THEN
                  IF (l_debug = 1) THEN
                     inv_log_util.trace('validate_quantities IN (lotcheck) ==> PASS ' , 'INV_TXN_MANAGER_GRP', 9);
                  END IF;

                 UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
                 SET    TRANSACTION_QUANTITY           = l_lotqty,
                        SECONDARY_TRANSACTION_QUANTITY = l_secondary_quantity
                 WHERE ROWID = l_lotrowid;
                ELSE
                  IF (l_debug = 1) THEN
                    inv_log_util.trace('validate_quantities IN (lotcheck) - FAIL ' || l_msg_data, 'INV_TXN_MANAGER_GRP', 9);
                  END IF;
                  l_error_exp := '';
                  l_error_code := '';
                  FND_MESSAGE.clear;
                  return(FALSE);
                END IF;

                IF (l_debug = 1) THEN
                inv_log_util.trace('calling VALIDATE_ADDITIONAL_ATTR', 'INV_TXN_MANAGER_GRP', 9);
                end if;

                 IF l_child_lot_enabled = 'N'
         THEN
                l_parent_lot_number := NULL ;
         END IF;

         /* nsinghi bug 5209065. Following cursor used to set interface id, so that interface record can be queried
         for custom expiration dt calculation. When transaction is created through API, lot expiration date
         calculation is handled by the following code. */
         OPEN cur_get_interface_id;
         FETCH cur_get_interface_id INTO l_interface_id;
         CLOSE cur_get_interface_id;
         inv_calculate_exp_date.set_txn_id (p_table => 1, p_header_id => l_interface_id);
         inv_calculate_exp_date.set_lot_txn_id (p_table => 1, p_header_id => l_lotrowid);

        /* this api will validate all the added new lot attributes intoduced in INVCONV
                project */
                l_attr_check := VALIDATE_ADDITIONAL_ATTR(
                                          p_api_version                 => 1.0
                                        , p_init_msg_list               => fnd_api.g_false
                                                , p_validation_level            => fnd_api.g_valid_level_full
                                                , p_intid                                       =>      p_intid
                                                , p_rowid                       =>      p_rowid
                                                , p_inventory_item_id           =>      p_itemid
                                                , p_organization_id             =>      p_orgid
                                                , p_lot_number                  =>  l_lotnum
                                                , p_grade_code              =>  l_grade_code
                                                , p_retest_date             =>  l_retest_date
                                                , p_maturity_date           =>  l_maturity_date
                                                , p_parent_lot_number       =>  l_parent_lot_number
                                                , p_origination_date        =>  l_origination_date
                                                , p_origination_type        =>  l_origination_type
                                                , p_expiration_action_code  =>  l_expiration_action_code
                                                , p_expiration_action_date  =>  l_expiration_action_date
                                                , p_expiration_date         =>  l_expiration_date
                                                , p_hold_date               =>  l_hold_date
                                                , p_reason_id               =>  l_reason_id
                                                , p_copy_lot_attribute_flag =>  l_copy_lot_attribute_flag
                                                , x_return_status               => l_return_status
                                                , x_msg_count                   => l_msg_count
                                                , x_msg_data                    => l_msg_data
                                                )  ;
                IF (l_attr_check)
                THEN

          IF (l_debug = 1) THEN
                    inv_log_util.trace('VALIDATE_ADDITIONAL_ATTR IN (lotcheck) ==> PASS ' , 'INV_TXN_MANAGER_GRP', 9);
              END IF;

         -- nsinghi bug 5209065. Added the following line.
         -- Expiration date was getting reset and hence ensured that appropriate value gets updated to MTLI.
         -- nsinghi bug#5209065 rework. Added fnd_date.date_to_canonical call.
         l_lotexpdate := fnd_date.date_to_canonical(l_expiration_date);

         UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
         SET    GRADE_CODE =  l_grade_code ,
                        RETEST_DATE = l_retest_date ,
                        MATURITY_DATE = l_maturity_date,
                        PARENT_LOT_NUMBER = l_parent_lot_number,
                        ORIGINATION_DATE = l_origination_date,
                        ORIGINATION_TYPE = l_origination_type ,
                        EXPIRATION_ACTION_CODE = l_expiration_action_code,
                        EXPIRATION_ACTION_DATE = l_expiration_action_date ,
                        LOT_EXPIRATION_DATE = l_expiration_date ,
                        HOLD_DATE = l_hold_date,
                        REASON_ID = l_reason_id
         WHERE ROWID = l_lotrowid;

            ELSE
         IF (l_debug = 1) THEN
                    inv_log_util.trace('VALIDATE_ADDITIONAL_ATTR IN (lotcheck) - FAIL ' || l_msg_data, 'INV_TXN_MANAGER_GRP', 9);
              END IF;
          l_error_exp := '';
          l_error_code := '';
          FND_MESSAGE.clear;
              return(FALSE);
                END IF;

-- INVCONV end fabdi

   -- R12 Genealogy Enhancement :  Start
   IF  (p_srctype = INV_GLOBALS.G_SOURCETYPE_WIP AND
       p_acttype = INV_GLOBALS.G_ACTION_ISSUE)  THEN
      IF  (p_serctrl = 2 OR p_serctrl = 5) -- Lot + serial Controlled
      THEN
        -- mrana:5443557: this is not needed anymore AND (p_is_wsm_enabled = 'N')) THEN
         IF (l_debug = 1) THEN
            INV_log_util.trace('{{- It is lot+serial controlled item. Call validate_serial_genealogy_data }}'
                                , 'INV_TXN_MANAGER_GRP', 9);
         END IF;
         validate_serial_genealogy_data ( p_interface_id   => l_sertempid
                                        , p_org_id         => p_orgid
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data);
            IF l_return_status <> lg_ret_sts_success THEN
               IF (l_debug=1) THEN mydebug(' l_return_status: ' || l_return_status); END IF;
              --RAISE lg_exc_error; ????
            END IF;
      ELSE
         IF (l_debug = 1) THEN
            INV_log_util.trace('{{- It is lot controlled item - if parent details are available, }} ' ||
                               '{{  Validation/derivation of parent object details should happen here}}'
                                , 'INV_TXN_MANAGER_GRP', 9);
         END IF;
         IF (l_parent_object_id is NOT NULL AND l_parent_object_type is NOT NULL) OR
            (l_parent_object_type is NOT NULL AND l_parent_object_number is NOT NULL
                                           AND l_parent_Item_id IS NOT NULL)  THEN
            IF (l_debug = 1) THEN
            inv_log_util.trace('{{- Parent details are available - Validation/derivation of  }} ' ||
                               '{{  parent object details is called here}}' , 'INV_TXN_MANAGER_GRP', 9);
            END IF;
            validate_derive_object_details
            ( p_org_id              => p_orgid
            , p_object_type         => l_parent_object_type
            , p_object_id           => l_parent_object_id
            , p_object_number       => l_parent_object_number
            , p_item_id             => l_parent_Item_id
            , p_object_type2        => l_parent_object_type2
            , p_object_id2          => l_parent_object_id2
            , p_object_number2      => l_parent_object_number2
            , p_serctrl             => p_serctrl
            , p_lotctrl             => 2
            , p_rowid               => l_lotrowid
            , p_table               => 'MTLI'
            , x_return_status       => l_return_status
            , x_msg_count           => l_msg_count
            , x_msg_data            => l_msg_data);
            IF l_return_status <> lg_ret_sts_success THEN
               IF (l_debug=1) THEN mydebug(' l_return_status: ' || l_return_status); END IF;
              --RAISE lg_exc_error; ????
            END IF;

         ELSE
            null; -- Parent object details not populated during wip issue . It is OK
            IF (l_debug = 1) THEN
            inv_log_util.trace('{{ Parent object details not populated during WIP issue . It is OK }}' ,
               'INV_TXN_MANAGER_GRP', 9);
            END IF;
         END IF;
      END IF;
      IF (l_debug = 1) THEN
      inv_log_util.trace('{{- It is not a WIP issue transactioon, so no validation/derivation of }}' ||
                         '{{  parent object details should happen here}}' , 'INV_TXN_MANAGER_GRP', 9);
      END IF;
   END IF;
   -- R12 Genealogy Enhancement :  End
   --bug 8497953  kbanddyo added lot number and org id as in parameters for invoking inv_convert
   -- this is done to cater to lot specific uom conversions.
          IF (p_srctype =5) then
               --ADM bug 9959125, converting only for discrete orgs.
               If l_process_enabled_flag = 'N' Then
                    l_lotpriqty := inv_convert.inv_um_convert(p_itemid,l_lotnum,p_orgid,6,l_lotqty,p_trxuom,p_priuom,'','');
               End If;
            ELSE
              l_lotpriqty := inv_convert.inv_um_convert(p_itemid,l_lotnum,p_orgid,5,l_lotqty,p_trxuom,p_priuom,'','');
           END IF;


        EXCEPTION
           WHEN OTHERS THEN

        /*IF (NOT UomConvert(l_itemid,0,l_trxuom, '',
                        l_priuom, '',l_lotqty,
                        l_lotpriqty, 0)) THEN */
              l_error_exp := FND_MESSAGE.get;

              FND_MESSAGE.set_name('INV','INV_INT_UOMCONVCODE');
              l_error_code := FND_MESSAGE.get;

            UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
               SET LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = l_userid,
                   LAST_UPDATE_LOGIN = l_loginid,
                   PROGRAM_APPLICATION_ID = l_applid,
                   PROGRAM_ID = l_progid,
                   PROGRAM_UPDATE_DATE = SYSDATE,
                   REQUEST_ID = l_reqstid,
                   ERROR_CODE = substrb(l_error_code,1,240)
             WHERE ROWID = l_lotrowid;

            UPDATE MTL_TRANSACTIONS_INTERFACE
               SET ERROR_CODE = substrb(l_error_code,1,240),
                   ERROR_EXPLANATION = substrb(l_error_exp,1,240),
                   LAST_UPDATE_DATE = sysdate,
                   LAST_UPDATED_BY = l_userid,
                   LAST_UPDATE_LOGIN = l_loginid,
                   PROGRAM_UPDATE_DATE = SYSDATE,
                   PROCESS_FLAG = 3,
                   LOCK_FLAG = 2
             WHERE ROWID = p_rowid;

            return(FALSE);
        END;
/* Changes done in the below if condition for bug2725491
   Hadling the no_data_found exception when the lot is new
   and expiration is set */
        IF ((p_shlfcode <> 1) AND (l_lotexpdate IS NULL)) THEN
           BEGIN
                SELECT
                  fnd_date.date_to_canonical(EXPIRATION_DATE)
                  INTO l_lotexpdate
                  FROM MTL_LOT_NUMBERS
                 WHERE INVENTORY_ITEM_ID = p_itemid
                   AND ORGANIZATION_ID = p_orgid
                   AND LOT_NUMBER = l_lotnum;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF ((p_shlfcode = 2) AND (l_lotexpdate IS NULL)) THEN
                    SELECT fnd_date.date_to_canonical(SYSDATE + p_shlfdays)
                      INTO l_lotexpdate
                      FROM DUAL;
            END IF;

            IF ((p_shlfcode = 4) AND (l_lotexpdate IS NULL)) THEN

                  FND_MESSAGE.set_name('INV','INV_LOT_EXPREQD');
                  l_error_exp := FND_MESSAGE.get;
                  FND_MESSAGE.set_name('INV','INV_LOT_EXPREQD');
                  l_error_code := FND_MESSAGE.get;

                UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
                   SET LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = l_userid,
                       LAST_UPDATE_LOGIN = l_loginid,
                       PROGRAM_APPLICATION_ID = l_applid,
                       PROGRAM_ID = l_progid,
                       PROGRAM_UPDATE_DATE = SYSDATE,
                       REQUEST_ID = l_reqstid,
                       ERROR_CODE = substrb(l_error_code,1,240)
                 WHERE ROWID = l_lotrowid;

                 UPDATE MTL_TRANSACTIONS_INTERFACE
                    SET ERROR_CODE = substrb(l_error_code,1,240),
                        ERROR_EXPLANATION = substrb(l_error_exp,1,240),
                        LAST_UPDATE_DATE = sysdate,
                        LAST_UPDATED_BY = l_userid,
                        LAST_UPDATE_LOGIN = l_loginid,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2
                  WHERE ROWID = p_rowid;


                 return(FALSE);

            END IF;
         END;
        END IF;

      --Bug #5738503
      --If the item is not under shelf life control and
      --expiration date is not null then set the expiration date to null
      IF ((p_shlfcode = 1) AND (l_lotexpdate IS NOT NULL)) THEN
        l_lotexpdate := NULL;
      END IF;

      --serial tagging
      /*
      IF (p_serctrl = 2 OR p_serctrl = 5 OR (p_serctrl = 6 AND
             p_srctype = 2 AND p_acttype = 1) OR (p_serctrl = 6 AND
        p_srctype = INV_GLOBALS.G_SourceType_IntOrder AND p_acttype = 1)
          OR (p_serctrl = 6 AND p_srctype = 8)
          OR (P_serctrl = 6 AND p_srctype = 16 and p_acttype = 1)
          OR (P_serctrl = 6 AND (p_trx_typeid = 93 OR p_trx_typeid = 94) ))
      */
      IF (serial_tagged = 2)
      THEN
        BEGIN
          SELECT 1
           into l_tnum
          FROM MTL_SERIAL_NUMBERS_INTERFACE
          WHERE TRANSACTION_INTERFACE_ID = l_sertempid
            AND ROWNUM < 2;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             loaderrmsg('INV_INT_SERMISCODE','INV_INT_SERMISEXP');

             UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
                   SET LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = l_userid,
                       LAST_UPDATE_LOGIN = l_loginid,
                       PROGRAM_APPLICATION_ID = l_applid,
                       PROGRAM_ID = l_progid,
                       PROGRAM_UPDATE_DATE = SYSDATE,
                       REQUEST_ID = l_reqstid,
                       ERROR_CODE = substrb(l_error_code,1,240)
                 WHERE ROWID = l_lotrowid;

                    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                       SET LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = l_userid,
                           LAST_UPDATE_LOGIN = l_loginid,
                           PROGRAM_UPDATE_DATE = SYSDATE,
                           PROCESS_FLAG = 3,
                           LOCK_FLAG = 2,
                           ERROR_CODE = substrb(l_error_code,1,240),
                           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                     WHERE ROWID = p_rowid;


                return(FALSE);
        END;

      ELSE
            IF (l_sertempid IS NOT NULL) THEN
                DELETE FROM MTL_SERIAL_NUMBERS_INTERFACE
                 WHERE TRANSACTION_INTERFACE_ID = l_sertempid;
            END IF;

      END IF;
            UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
                SET LAST_UPDATE_DATE = SYSDATE,
                    LAST_UPDATED_BY = l_userid,
                    LAST_UPDATE_LOGIN = l_loginid,
                    PROGRAM_APPLICATION_ID = l_applid,
                    PROGRAM_ID = l_progid,
                    PROGRAM_UPDATE_DATE = SYSDATE,
                    REQUEST_ID = l_reqstid,
                    PRIMARY_QUANTITY = nvl(l_lotpriqty, abs(PRIMARY_QUANTITY)*sign(TRANSACTION_QUANTITY) ), --ADM bug 9959125
                    LOT_EXPIRATION_DATE = fnd_date.canonical_to_date(l_lotexpdate),
                    SERIAL_TRANSACTION_TEMP_ID = l_sertempid
              WHERE ROWID = l_lotrowid;

       /* Material Status Enhancement - Tracking bug: 13519864 */
       /*validate material status for comingling */

      IF (l_status_id IS NOT NULL AND l_allow_status_entry  = 'Y') THEN

	if inv_cache.set_org_rec(p_orgid) then
	  l_default_status_id :=  inv_cache.org_rec.default_status_id;
	end if;

	IF (l_default_status_id is not null) THEN

		FND_MESSAGE.set_name('INV', 'INV_STATUS_COMINGLING');
      		l_error_code := 'INV_STATUS_COMINGLING';
                l_error_exp := FND_MESSAGE.get;

                      UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
                              SET LAST_UPDATE_DATE = SYSDATE,
                                  LAST_UPDATED_BY = l_userid,
                                  LAST_UPDATE_LOGIN = l_loginid,
                                  PROGRAM_APPLICATION_ID = l_applid,
                                  PROGRAM_ID = l_progid,
                                  PROGRAM_UPDATE_DATE = SYSDATE,
                                  REQUEST_ID = l_reqstid,
                                  ERROR_CODE = substrb(l_error_code,1,240)
                      WHERE TRANSACTION_INTERFACE_ID = p_intid
                      AND EXISTS
                           (
                             select 'comingling exists'
                             from mtl_onhand_quantities_detail moqd,
                                  mtl_transactions_interface mti
                             WHERE mti.TRANSACTION_INTERFACE_ID = p_intid
                             AND PROCESS_FLAG = 1
                             AND moqd.organization_id = mti.organization_id
                             AND moqd.inventory_item_id = mti.inventory_item_id
                             and moqd.subinventory_code = mti.subinventory_code
                             and nvl(moqd.locator_id, -9999) = nvl(mti.locator_id, -9999)
                             and nvl(moqd.lot_number, '@@@@') = nvl(mtli.lot_number, '@@@@')
                             and nvl(moqd.lpn_id, -9999) = nvl(mti.lpn_id, -9999)
                             and nvl(moqd.status_id, -9999) <> nvl(mtli.status_id, -9999)
                           );

                      IF SQL%FOUND THEN
                             FND_MESSAGE.set_name('INV','INV_STATUS_COMINGLING');
                             l_error_exp := FND_MESSAGE.get;

                      UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                         SET LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = l_loginid,
                           LAST_UPDATE_LOGIN = l_loginid,
                           PROGRAM_UPDATE_DATE = SYSDATE,
                           PROCESS_FLAG = 3,
                           LOCK_FLAG = 2,
                           ERROR_CODE = substrb(l_error_code,1,240),
                           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                         WHERE TRANSACTION_INTERFACE_ID = p_intid
                           AND PROCESS_FLAG = 1
                           AND EXISTS
                           (
                             select 'comingling exists'
                             from mtl_onhand_quantities_detail moqd,
                                  mtl_transaction_lots_interface mtli
                             WHERE moqd.organization_id = mti.organization_id
                             AND moqd.inventory_item_id = mti.inventory_item_id
                             and moqd.subinventory_code = mti.subinventory_code
                             and nvl(moqd.locator_id, -9999) = nvl(mti.locator_id, -9999)
                             and nvl(moqd.lot_number, '@@@@') = nvl(mtli.lot_number, '@@@@')
                             and nvl(moqd.lpn_id, -9999) = nvl(mti.lpn_id, -9999)
                             and nvl(moqd.status_id, -9999) <> nvl(mtli.status_id, -9999)
                           );

                      END IF;
	END IF;
      END IF;

    END LOOP;
    IF int3%ISOPEN THEN
       CLOSE int3;
    END IF ;

 EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.set_name('INV','INV_INT_UOMCONVCODE');

    --WHENEVER SQL ERROR CONTINUE;
    UPDATE MTL_TRANSACTIONS_INTERFACE
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = l_userid,
               LAST_UPDATE_LOGIN = l_loginid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               PROCESS_FLAG = 3,
               LOCK_FLAG = 2,
               ERROR_CODE = substrb(l_error_code,1,240)
     WHERE ROWID = p_rowid;

    return FALSE;

END lotcheck;



/******************************************************************
 *
 * setorgclientinfo()
 *
 ******************************************************************/
FUNCTION setorgclientinfo(p_orgid in NUMBER)
RETURN BOOLEAN
IS

 x_return_status varchar2(50);

BEGIN

--WHENEVER NOT FOUND CONTINUE;

--Commenting the processing based on checking PJM_INSTALL. Bug 3812559
/*
 IF (pjm_installed = -1) THEN
   IF PJM_INSTALL.check_install
   THEN
        pjm_installed := 1;
   ELSE
        pjm_installed := 0;
   END IF;

 END IF;
*/

/* IF (pjm_installed = 1) THEN */
  IF (client_info_org_id <> p_orgid) THEN
          INV_Project.Set_Org_client_info(x_return_status,
                                          p_orgid);
     IF (x_return_status <> 'S') THEN
        return FALSE;
     END IF;
     -- commented as a part of bug #2505534
     --client_info_org_id := p_orgid;
   END IF;
/* END IF; */
 return TRUE;

 EXCEPTION
    WHEN OTHERS THEN
     return FALSE;
END setorgclientinfo;

/******************************************************************
-- Function
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

FUNCTION getloc(x_locid OUT NOCOPY NUMBER, p_org_id NUMBER, p_locctrl NUMBER, p_segmentarray fnd_flex_ext.segmentarray) return BOOLEAN is
      l_nseg           NUMBER;
      l_seglist        fnd_flex_key_api.segment_list;
      l_fftype         fnd_flex_key_api.flexfield_type;
      l_ffstru         fnd_flex_key_api.structure_type;
      l_segment_type   fnd_flex_key_api.segment_type;
      l_locator        VARCHAR2(32000);
      l_error_exp      VARCHAR2(250);
      l_structure_list fnd_flex_key_api.structure_list;
      l_nstru          NUMBER;
      l_index          NUMBER;
      l_locid          NUMBER;
      l_delim          VARCHAR2(1);
      l_val            BOOLEAN  := FALSE;
      DYNAMIC CONSTANT NUMBER := 3;
      l_operation      VARCHAR2(100);
    -- Local array to hold the data for getting the cancatenated segment.
      l_segmentarray fnd_flex_ext.segmentarray;
BEGIN

    fnd_flex_key_api.set_session_mode('seed_data');

   -- find flex field type
   l_fftype := fnd_flex_key_api.find_flexfield('INV', 'MTLL');

   -- find flex structure type
   l_ffstru := fnd_flex_key_api.find_structure(l_fftype, 101);

   -- find segment list for the key flex field
   fnd_flex_key_api.get_segments(l_fftype, l_ffstru, TRUE, l_nseg, l_seglist);

   -- find segment delimiter
   l_delim := l_ffstru.segment_separator;

   -- get the corresponding column for all segments
   --
   -- The default segments for the LocatorKFF is SEGMENT1 - SEGMENT20
   --  'To_number(Substr(l_segment_type.column_name, 8))' gives the
   -- number of the segment i.e. 1 - 20 which is used as index to
   -- fetch the corresponding columns from segments array
   --
   FOR l_loop IN 1..l_nseg LOOP

      l_segment_type := fnd_flex_key_api.find_segment(l_fftype, l_ffstru, l_seglist(l_loop));
      -- Bug Fix#4747090
      --l_segmentarray contains data in the order flexfield is defined. Used in creating cancatenated segments for validation.
      l_segmentarray(l_loop) := p_segmentarray(To_number(Substr(l_segment_type.column_name, 8)));
   END LOOP;
   -- Bug Fix#4747090
   -- Gets the encoded cancatenated string
   l_locator := fnd_flex_ext.concatenate_segments(n_segments => l_nseg,
                                                   segments   => l_segmentarray,
                                                   delimiter  => l_delim);
   IF (l_debug = 1) THEN
      inv_log_util.trace('Locator is : ' || l_locator, 'INV_TXN_MANAGER_GRP','1');
   END IF;
   /*
    * If Locator control allows dynamic creation then create the combination
    * if it does not already exist else just check if it exists.
    */
   if p_locctrl = DYNAMIC then
    /*Bug#5044059, if the profile 'INV_CREATE_LOC_AT' is set to 'YES',
      call FND_FLEX_KEYVAL.Validate_Segs with 'CREATE_COMBINATION' operation*/
     IF (g_create_loc_at = 1) then
       l_operation := 'CREATE_COMBINATION';
     ELSE
       l_operation := 'CREATE_COMB_NO_AT';
     END IF;
   else
      l_operation := 'FIND_COMBINATION';
   end if;

   l_val := FND_FLEX_KEYVAL.Validate_Segs(
                 OPERATION        => l_operation,
                 APPL_SHORT_NAME  => 'INV',
                 KEY_FLEX_CODE  => 'MTLL',
                 STRUCTURE_NUMBER  => 101,
                 CONCAT_SEGMENTS  => l_locator,
                 VALUES_OR_IDS  => 'I',
                 DATA_SET  => p_org_id ) ;

    if l_val then
       x_locid := fnd_flex_keyval.combination_id;
    else
       x_locid := NULL;
       l_error_exp := substr(fnd_flex_key_api.message(),1,240);
       IF (l_debug = 1) THEN
          inv_log_util.trace('Error in getloc : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
          inv_log_util.trace('Error in getloc : error_segment :' || FND_FLEX_KEYVAL.error_segment , 'INV_TXN_MANAGER_GRP','1');
          inv_log_util.trace('Error in getloc : error_message :' || FND_FLEX_KEYVAL.error_message , 'INV_TXN_MANAGER_GRP','1');
          inv_log_util.trace('Error in getloc : encoded_error_message :' || FND_FLEX_KEYVAL.encoded_error_message , 'INV_TXN_MANAGER_GRP','1');
       END IF;
    end if;

     return l_val;

EXCEPTION

   WHEN OTHERS THEN

      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getloc : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_locid := NULL;
      return FALSE;

END getloc;
/******************************************************************
-- Function
--   getlocid
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/
FUNCTION getlocid(x_locid OUT NOCOPY NUMBER, p_org_id NUMBER, p_subinv VARCHAR2, p_rowid VARCHAR2, p_locctrl NUMBER) return BOOLEAN is
 l_segs1     fnd_flex_ext.segmentArray;
 l_error_exp VARCHAR2(250);
 l_locid     number;
begin

   SELECT
        LOCATOR_ID,
        LOC_SEGMENT1,
        LOC_SEGMENT2,
        LOC_SEGMENT3,
        LOC_SEGMENT4,
        LOC_SEGMENT5,
        LOC_SEGMENT6,
        LOC_SEGMENT7,
        LOC_SEGMENT8,
        LOC_SEGMENT9,
        LOC_SEGMENT10,
        LOC_SEGMENT11,
        LOC_SEGMENT12,
        LOC_SEGMENT13,
        LOC_SEGMENT14,
        LOC_SEGMENT15,
        LOC_SEGMENT16,
        LOC_SEGMENT17,
        LOC_SEGMENT18,
        LOC_SEGMENT19,
        LOC_SEGMENT20
   INTO
        l_locid,
        l_segs1(1),
        l_segs1(2),
        l_segs1(3),
        l_segs1(4),
        l_segs1(5),
        l_segs1(6),
        l_segs1(7),
        l_segs1(8),
        l_segs1(9),
        l_segs1(10),
        l_segs1(11),
        l_segs1(12),
        l_segs1(13),
        l_segs1(14),
        l_segs1(15),
        l_segs1(16),
        l_segs1(17),
        l_segs1(18),
        l_segs1(19),
        l_segs1(20)
   FROM mtl_transactions_interface mti
   WHERE mti.rowid = p_rowid;

   return getloc(x_locid, p_org_id, p_locctrl, l_segs1);

EXCEPTION

   WHEN OTHERS THEN
      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getlocId : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_locid := NULL;
      return FALSE;

END getlocid;

/******************************************************************
-- Function
--   getxlocid
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/

FUNCTION getxlocid(x_locid OUT NOCOPY NUMBER, p_org_id NUMBER, p_subinv VARCHAR2, p_rowid VARCHAR2, p_locctrl NUMBER) return BOOLEAN is
 l_segs1      fnd_flex_ext.segmentArray;
 l_error_exp  VARCHAR2(250);
 l_locid      number;
begin

   SELECT
        TRANSFER_LOCATOR,
        XFER_LOC_SEGMENT1,
        XFER_LOC_SEGMENT2,
        XFER_LOC_SEGMENT3,
        XFER_LOC_SEGMENT4,
        XFER_LOC_SEGMENT5,
        XFER_LOC_SEGMENT6,
        XFER_LOC_SEGMENT7,
        XFER_LOC_SEGMENT8,
        XFER_LOC_SEGMENT9,
        XFER_LOC_SEGMENT10,
        XFER_LOC_SEGMENT11,
        XFER_LOC_SEGMENT12,
        XFER_LOC_SEGMENT13,
        XFER_LOC_SEGMENT14,
        XFER_LOC_SEGMENT15,
        XFER_LOC_SEGMENT16,
        XFER_LOC_SEGMENT17,
        XFER_LOC_SEGMENT18,
        XFER_LOC_SEGMENT19,
        XFER_LOC_SEGMENT20
   INTO
        l_locid,
        l_segs1(1),
        l_segs1(2),
        l_segs1(3),
        l_segs1(4),
        l_segs1(5),
        l_segs1(6),
        l_segs1(7),
        l_segs1(8),
        l_segs1(9),
        l_segs1(10),
        l_segs1(11),
        l_segs1(12),
        l_segs1(13),
        l_segs1(14),
        l_segs1(15),
        l_segs1(16),
        l_segs1(17),
        l_segs1(18),
        l_segs1(19),
        l_segs1(20)
   FROM mtl_transactions_interface mti
   WHERE mti.rowid = p_rowid;

   return getloc(x_locid, p_org_id, p_locctrl, l_segs1);

EXCEPTION

   WHEN OTHERS THEN
      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getxlocId : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_locid := NULL;
      return FALSE;

END getxlocid;

/******************************************************************
-- Function
--   getplocid. Added for Bug: 7323175
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work.
--   Used only in case of Project enabled ords for the
--   creation of physical locators
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/
/** Altered the changes made in the bug 7323175 for the bug 12922489*/
/*FUNCTION getplocid(x_locid OUT NOCOPY NUMBER, p_org_id NUMBER, p_subinv VARCHAR2, p_rowid VARCHAR2, p_locctrl NUMBER) return BOOLEAN is
 l_segs1     fnd_flex_ext.segmentArray;
 l_error_exp VARCHAR2(250);
 l_locid     number;
begin

   SELECT
        LOCATOR_ID,
        LOC_SEGMENT1,
        LOC_SEGMENT2,
        LOC_SEGMENT3,
        LOC_SEGMENT4,
        LOC_SEGMENT5,
        LOC_SEGMENT6,
        LOC_SEGMENT7,
        LOC_SEGMENT8,
        LOC_SEGMENT9,
        LOC_SEGMENT10,
        LOC_SEGMENT11,
        LOC_SEGMENT12,
        LOC_SEGMENT13,
        LOC_SEGMENT14,
        LOC_SEGMENT15,
        LOC_SEGMENT16,
        LOC_SEGMENT17,
        LOC_SEGMENT18,
        '',
        ''
   INTO
        l_locid,
        l_segs1(1),
        l_segs1(2),
        l_segs1(3),
        l_segs1(4),
        l_segs1(5),
        l_segs1(6),
        l_segs1(7),
        l_segs1(8),
        l_segs1(9),
        l_segs1(10),
        l_segs1(11),
        l_segs1(12),
        l_segs1(13),
        l_segs1(14),
        l_segs1(15),
        l_segs1(16),
        l_segs1(17),
        l_segs1(18),
        l_segs1(19),
        l_segs1(20)



   FROM mtl_transactions_interface mti
   WHERE mti.rowid = p_rowid;

   return getloc(x_locid, p_org_id, p_locctrl, l_segs1);

EXCEPTION

   WHEN OTHERS THEN
      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getplocId : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_locid := NULL;
      return FALSE;

END getplocid;*/

/******************************************************************
-- Function
--   getxplocid        : Added for Bug: 7323175
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work
--   Used only in case of Project enabled orgs for the
--   creation of physical locators for transfer transactions
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/
/** Altered the changes made in the bug 7323175 for the bug 12922489*/
/*FUNCTION getxplocid(x_locid OUT NOCOPY NUMBER, p_org_id NUMBER, p_subinv VARCHAR2, p_rowid VARCHAR2, p_locctrl NUMBER) return BOOLEAN is
 l_segs1      fnd_flex_ext.segmentArray;
 l_error_exp  VARCHAR2(250);
 l_locid      number;
begin

   SELECT
        TRANSFER_LOCATOR,
        XFER_LOC_SEGMENT1,
        XFER_LOC_SEGMENT2,
        XFER_LOC_SEGMENT3,
        XFER_LOC_SEGMENT4,
        XFER_LOC_SEGMENT5,
        XFER_LOC_SEGMENT6,
        XFER_LOC_SEGMENT7,
        XFER_LOC_SEGMENT8,
        XFER_LOC_SEGMENT9,
        XFER_LOC_SEGMENT10,
        XFER_LOC_SEGMENT11,
        XFER_LOC_SEGMENT12,
        XFER_LOC_SEGMENT13,
        XFER_LOC_SEGMENT14,
        XFER_LOC_SEGMENT15,
        XFER_LOC_SEGMENT16,
        XFER_LOC_SEGMENT17,
        XFER_LOC_SEGMENT18,
        '',
        ''

   INTO
        l_locid,
        l_segs1(1),
        l_segs1(2),
        l_segs1(3),
        l_segs1(4),
        l_segs1(5),
        l_segs1(6),
        l_segs1(7),
        l_segs1(8),
        l_segs1(9),
        l_segs1(10),
        l_segs1(11),
        l_segs1(12),
        l_segs1(13),
        l_segs1(14),
        l_segs1(15),
        l_segs1(16),
        l_segs1(17),
        l_segs1(18),
        l_segs1(19),
        l_segs1(20)


   FROM mtl_transactions_interface mti
   WHERE mti.rowid = p_rowid;

   return getloc(x_locid, p_org_id, p_locctrl, l_segs1);

EXCEPTION

   WHEN OTHERS THEN
      l_error_exp := substr(fnd_flex_key_api.message(),1,240);
      IF (l_debug = 1) THEN
         inv_log_util.trace('Error in getxplocId : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
         inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
      END IF;
      x_locid := NULL;
      return FALSE;

END getxplocid;*/


/******************************************************************
 *
 * validate_loc_for_project()
 *
 ******************************************************************/
FUNCTION validate_loc_for_project(p_ltv_locid in NUMBER, p_ltv_orgid in NUMBER, p_ltv_srctype in NUMBER,
                              p_ltv_trxact in NUMBER, p_ltv_trx_src_id in NUMBER, p_ltv_flow_schedule in NUMBER,
                              p_ltv_scheduled_flag in NUMBER)
RETURN BOOLEAN
IS

CURSOR LTV1 IS
       SELECT PROJECT_ID, TASK_ID
       FROM WIP_DISCRETE_JOBS
       WHERE WIP_ENTITY_ID = p_ltv_trx_src_id
         AND ROWNUM < 2 ;

CURSOR LTV2 IS
       SELECT PROJECT_ID, TASK_ID
       FROM WIP_FLOW_SCHEDULES
       WHERE WIP_ENTITY_ID = p_ltv_trx_src_id
         AND ROWNUM < 2 ;

    l_ltv_project_ref_enabled NUMBER := 0 ;
    l_ltv_project_id NUMBER;
    l_ltv_task_id NUMBER;
    l_ltv_mode VARCHAR2(20);
    l_ltv_reqd_flag VARCHAR2(10);
    l_ltv_loc_project_valid NUMBER := 1;
    l_ltv_error_mesg VARCHAR2(241);

BEGIN

    -- WHENEVER NOT FOUND CONTINUE;

    BEGIN
      SELECT DECODE(NVL(PROJECT_REFERENCE_ENABLED, 2),1,1,0)
      INTO l_ltv_project_ref_enabled
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = p_ltv_orgid ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('INV','INV_INT_ORGEXP');
        return(FALSE);
    END;

    IF l_ltv_project_ref_enabled = 0 THEN
        return(TRUE);
    END IF;

    l_ltv_mode := 'ANY';
    l_ltv_reqd_flag := 'N';

    IF  p_ltv_srctype = 5 THEN
        IF p_ltv_scheduled_flag = 1 THEN

            IF p_ltv_trx_src_id IS NULL THEN
                FND_MESSAGE.set_name('INV','INV_INT_SRCWIPEXP');
                return FALSE;
            END IF;

            IF p_ltv_flow_schedule = 0 THEN
                OPEN LTV1 ;
                FETCH LTV1 INTO
                l_ltv_project_id,
                l_ltv_task_id;

                IF SQL%NOTFOUND THEN
                   FND_MESSAGE.set_name('INV','INV_INT_SRCWIPEXP');
                   CLOSE LTV1;
                   return(FALSE);
                END IF;
                CLOSE LTV1;
            ELSE
                IF  p_ltv_flow_schedule = 1  THEN
                   OPEN LTV2 ;
                   FETCH LTV2 INTO
                   l_ltv_project_id,
                   l_ltv_task_id;

                   IF SQL%NOTFOUND THEN
                      FND_MESSAGE.set_name('INV','INV_INT_SRCWIPEXP');
                      CLOSE LTV2;
                      return(FALSE);
                   END IF;
                   CLOSE LTV2;
                END IF;
            END IF;

            l_ltv_mode := 'SPECIFIC';
            IF ( p_ltv_trxact = 31 OR p_ltv_trxact = 32 ) THEN
                l_ltv_reqd_flag := 'Y';
            END IF;
        ELSE
            return(TRUE);
        END IF;
    END IF;
    IF (l_debug=1) THEN
       inv_log_util.trace('Validating l_ltv_project_id='||l_ltv_project_id||' l_ltv_task_id='||l_ltv_task_id, 'INV_TXN_MANAGER_GRP','9');
    END IF;

    IF p_ltv_scheduled_flag = 1 THEN
        inv_wwacst.call_prj_loc_validation(
                                       p_ltv_locid,
                                       p_ltv_orgid,
                                       l_ltv_mode,
                                       l_ltv_reqd_flag,
                                       l_ltv_project_id,
                                       l_ltv_task_id,
                                       l_ltv_loc_project_valid,
                                       l_ltv_error_mesg);


        IF l_ltv_loc_project_valid = 0 THEN
        --Bug #6449667, Modified the code below so that relavant error message are displayed from project validation API.
        IF (l_debug=1) THEN
          inv_log_util.trace('Error in validate_loc_for_project : ' || l_ltv_error_mesg, 'INV_TXN_MANAGER_GRP','9');
        END IF;
         --FND_MESSAGE.set_name('INV','INV_INT_SRCWIPEXP');
         FND_MESSAGE.set_name('INV', 'INV_FND_GENERIC_MSG');
         FND_MESSAGE.set_token('MSG', l_ltv_error_mesg);
           return(FALSE);
        ELSE
           FND_MESSAGE.clear;
           return(TRUE);
      END IF;


      ELSE
      return(TRUE);
    END IF;


EXCEPTION
  WHEN OTHERS THEN
        RETURN FALSE;
END validate_loc_for_project;


/******************************************************************
 *
 * validate_unit_number()
 *
 ******************************************************************/
FUNCTION validate_unit_number(p_unit_number in VARCHAR2, p_orgid in NUMBER, p_itemid in NUMBER,
                                   p_srctype in NUMBER, p_acttype in NUMBER)

RETURN BOOLEAN
 IS

l_unit_no_ok  NUMBER := 1;

BEGIN

    -- WHENEVER NOT FOUND CONTINUE;

    IF (NVL(PJM_UNIT_EFF.ENABLED,'N') = 'Y') THEN
      IF (PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM(p_itemid,p_orgid) = 'Y') THEN
        IF (p_srctype = 3 AND p_acttype in(3,21) AND p_unit_number IS NOT NULL) then
          l_unit_no_ok := 0;
           SELECT count(1) INTO l_unit_no_ok
           FROM PJM_UNIT_NUMBERS_LOV_V
           WHERE UNIT_NUMBER =p_unit_number;
        END IF;
      END IF;
    END IF;

    IF (l_unit_no_ok = 0) THEN

       FND_MESSAGE.set_name('INV','INV_INT_UNITNUMBER');
         FND_MESSAGE.set_token('ROUTINE','validate_unit_number');
       return FALSE;
    ELSE
       FND_MESSAGE.clear;
       return  TRUE;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
        RETURN FALSE;
END validate_unit_number;

/******************************************************************
 * get_costgrpid() : This function derives the cost group id for a particular Organization, Subinventory and Locator_id combination
 * Added for Bug 6356567
 ******************************************************************/

FUNCTION get_costgrpid(p_org_id in NUMBER, p_subinv in VARCHAR2, p_locatorid in NUMBER)
RETURN mtl_transactions_interface.cost_group_id%TYPE IS
        l_cost_group_id number;
        l_org_cost_group_id number;
        l_primary_cost_method mtl_parameters.primary_cost_method%TYPE;
        l_project_enabled NUMBER;
        l_project_id NUMBER;
BEGIN
        IF p_org_id is NULL then
                return NULL;
        END IF;

        l_cost_group_id := NULL; /* Initializing the value of Cost Group id to Null */

        BEGIN
           SELECT Nvl(project_reference_enabled,2), default_cost_group_id, primary_cost_method
             INTO l_project_enabled, l_org_cost_group_id, l_primary_cost_method
             FROM mtl_parameters
            WHERE organization_id = p_org_id
            and   WMS_ENABLED_FLAG = 'N' ;                        -- Bug 8345339
        EXCEPTION
            WHEN no_data_found THEN
            return NULL;
        END;

        IF (l_project_enabled = 1 and p_locatorid is not null) THEN     --If the Org is Project enabled Org
           BEGIN
                SELECT project_id INTO l_project_id
                  FROM mtl_item_locations
                 WHERE organization_id =p_org_id
                   AND inventory_location_id = p_locatorid;
           EXCEPTION
                WHEN no_data_found THEN
                l_project_id := null;
           END;

           IF l_project_id IS NOT NULL THEN
                SELECT mpp.costing_group_id INTO l_cost_group_id
                  FROM mrp_project_parameters mpp
                 WHERE mpp.project_id = l_project_id
                   AND mpp.organization_id = p_org_id;
           END IF;                                                      --IF l_project_id IS NOT NULL THEN
        END IF;

        IF (l_cost_group_id is null) then
                IF l_primary_cost_method = 1 THEN                       -- costing method is standard
                   BEGIN
                        SELECT default_cost_group_id INTO l_cost_group_id
                          FROM mtl_secondary_inventories
                         WHERE secondary_inventory_name = p_subinv
                           AND organization_id = p_org_id
                           AND default_cost_group_id IS NOT NULL;
                   EXCEPTION
                        WHEN no_data_found THEN
                        l_cost_group_id := l_org_cost_group_id;
                   END;
                ELSE                                                    -- costing method is not standard
                        l_cost_group_id := l_org_cost_group_id;
                END IF;
        END IF;
        return l_cost_group_id;
END get_costgrpid;

/******************************************************************
 *
 * update_mil() : To update dynamic locators in autonomous mode
 * Added for Bug# 5044059
 * Added a parameter p_plocid Physical Locator for Bug# 7323175
 * Altered the changes made in the bug 7323175 for the bug 12922489
 ******************************************************************/
PROCEDURE update_mil(p_userid NUMBER,
                     p_loginid NUMBER,
                     p_applid NUMBER,
                     p_progid NUMBER,
                     p_reqstid NUMBER,
                     p_subinv VARCHAR2,
                     p_default_locator_status NUMBER,
                     p_orgid NUMBER,
                     p_locid NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_count NUMBER := 0;
BEGIN

    begin
      SELECT 1 INTO l_count
        FROM MTL_ITEM_LOCATIONS
       WHERE ORGANIZATION_ID = p_orgid
        /* Start: Fix for Bug# 7323175 : Also considering the physical locator for locking */
         AND INVENTORY_LOCATION_ID = p_locid
         --AND INVENTORY_LOCATION_ID IN (p_locid,p_plocid)
        /* End: Fix for Bug# 7323175 */
         AND SUBINVENTORY_CODE is NULL FOR UPDATE NOWAIT;
    exception
      when others then
        l_count := 0;
        IF (l_debug = 1) THEN
           inv_log_util.trace('Could not lock MIL : ' || substr(sqlerrm, 1, 200), 'INV_TXN_MANAGER_GRP','9');
        END IF;
    end;

    IF (l_count = 1) THEN
      UPDATE MTL_ITEM_LOCATIONS
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_userid,
          LAST_UPDATE_LOGIN = p_loginid,
          PROGRAM_APPLICATION_ID = p_applid,
          PROGRAM_ID = p_progid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          REQUEST_ID = p_reqstid,
          SUBINVENTORY_CODE = p_subinv,
          STATUS_ID = p_default_locator_status
          /* Start: Fix for Bug# 7323175: Stamping PHYSICAL_LOCATION_ID with the physical locator for both
          physical and logical locators for Project enabled Orgs. For the case of Non project enabled orgs
          p_plocid would be null */
          --PHYSICAL_LOCATION_ID = p_plocid
          /* End: Fix for Bug# 7323175 */
      WHERE ORGANIZATION_ID = p_orgid
          /* Start: Fix for Bug# 7323175: Updating the physical locator as well in mil */
         AND INVENTORY_LOCATION_ID = p_locid
        --AND INVENTORY_LOCATION_ID IN (p_locid,p_plocid)
          /* End: Fix for Bug# 7323175 */
        AND SUBINVENTORY_CODE is NULL;


      IF (l_debug = 1) THEN
         inv_log_util.trace('Rows updated in MIL = '||SQL%ROWCOUNT, 'INV_TXN_MANAGER_GRP','9');
      END IF;
    END IF;

    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
        IF (l_debug = 1) THEN
           inv_log_util.trace('update_mil SQL : ' || substr(sqlerrm, 1, 200), 'INV_TXN_MANAGER_GRP','9');
        END IF;
        ROLLBACK;
        RETURN;
END update_mil;


/*Bug#5125632. Added the following procedure to update the lot status
of lots for a given line in MTLI, if they are NULL.
 Fist MTL_LOT_NUMBERS is checked to find the status. If there is no row in this
 table, then, MTL_SYSTEM_ITEMS is checked to fetch the 'default_lot_status_id'
 for the corresponding item*/

Procedure update_status_id_in_mtli( p_txn_interface_id  IN NUMBER
                                   ,p_org_id            IN NUMBER
                                    ,p_inventory_item_id IN NUMBER ) Is
l_status_enabled VARCHAR2(1);
l_status_id NUMBER;
l_mtli_status_id NUMBER;
l_lot_num   VARCHAR2(31);

CURSOR lots IS
SELECT ROWID
     , lot_number
     , status_id
FROM MTL_TRANSACTION_LOTS_INTERFACE
WHERE transaction_interface_id = p_txn_interface_id;

Begin
  IF (l_debug = 1) THEN
    inv_log_util.trace('Entered The Procedure update_status_id_in_mtli() with the parameters:', 'INV_TXN_MANAGER_GRP','1');
    inv_log_util.trace('p_txn_interface_id:'||p_txn_interface_id, 'INV_TXN_MANAGER_GRP','1');
    inv_log_util.trace('p_org_id:'||p_org_id, 'INV_TXN_MANAGER_GRP','1');
    inv_log_util.trace('p_inventory_item_id:'||p_inventory_item_id, 'INV_TXN_MANAGER_GRP','1');
  End If;

FOR lots_rec IN lots
LOOP
  IF lots_rec.status_id IS NULL THEN
    l_mtli_status_id := lots_rec.status_id;--To initialize 'lots_rec.status_id' with NULL
    IF (l_debug = 1) THEN
      inv_log_util.trace('Current cursor values are :', 'INV_TXN_MANAGER_GRP','1');
      inv_log_util.trace('lots_rec.lot_number:'||lots_rec.lot_number, 'INV_TXN_MANAGER_GRP','1');
      inv_log_util.trace('lots_rec.status_id:'||lots_rec.status_id, 'INV_TXN_MANAGER_GRP','1');
    End If;
    BEGIN
      SELECT status_id
      INTO l_mtli_status_id
      FROM mtl_lot_numbers
      WHERE organization_id   = p_org_id
        AND inventory_item_id = p_inventory_item_id
        AND lot_number      = lots_rec.lot_number;

    IF (l_debug = 1) THEN
      inv_log_util.trace('After selecting from MLN, Value is:', 'INV_TXN_MANAGER_GRP','1');
      inv_log_util.trace('l_mtli_status_id:'||l_mtli_status_id, 'INV_TXN_MANAGER_GRP','1');
    End If;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT lot_status_enabled
              ,default_lot_status_id
        INTO l_status_enabled
            ,l_status_id
        FROM mtl_system_items
        WHERE organization_id = p_org_id
          AND inventory_item_id = p_inventory_item_id;
        IF (l_debug = 1) THEN
          inv_log_util.trace('After selecting from MSI, Values are:', 'INV_TXN_MANAGER_GRP','1');
          inv_log_util.trace('lot_status_enabled:'||l_status_enabled, 'INV_TXN_MANAGER_GRP','1');
          inv_log_util.trace('default_lot_status_id:'||l_status_id, 'INV_TXN_MANAGER_GRP','1');
        End If;

        IF (NVL(l_status_enabled, 'N') = 'Y') THEN
          l_mtli_status_id := l_status_id;
        ELSE
          l_mtli_status_id := 1;
        END IF;
      END;
    END;

        IF (l_debug = 1) THEN
          inv_log_util.trace('Before Update of MTLI', 'INV_TXN_MANAGER_GRP','1');
        End If;

    UPDATE mtl_transaction_lots_interface
    SET   status_id = l_mtli_status_id
         ,last_updated_by = fnd_global.user_id
         ,last_update_date = sysdate
         ,last_update_login = fnd_global.login_id
         ,request_id = fnd_global.conc_request_id
         ,program_application_id = fnd_global.prog_appl_id
         ,program_id = fnd_global.conc_program_id
         ,program_update_date = Decode(fnd_global.conc_request_id, -1, NULL, SYSDATE)
    WHERE ROWID = lots_rec.rowid;

        IF (l_debug = 1) THEN
          inv_log_util.trace('After Update of MTLI', 'INV_TXN_MANAGER_GRP','1');
        End If;

  END IF;
END LOOP;
EXCEPTION WHEN OTHERS THEN
  IF lots%ISOPEN THEN
    CLOSE lots;
  END IF;
  IF (l_debug = 1) THEN
    inv_log_util.trace('Exception occurred in update_status_id_in_mtli procedure:', 'INV_TXN_MANAGER_GRP','1');
    inv_log_util.trace('Error Is:'||SQLERRM, 'INV_TXN_MANAGER_GRP','1');
  End If;

End update_status_id_in_mtli;

/******************************************************************
 *
 * validate_lot_serial_for_rcpt()
 * SDPAUL Bug# 5710830
 * This private procedure is used to validate a set of
 * MTL_TRANSACTION_LOTS_INTERFACE and MTL_SERIAL_NUMBERS_INTERFACE records
 * and inserts them into the corresponding master tables.
 * These validations are only needed for Receipt into stores transaction -> 27
 * and for the transaction sources -> 3,6 and 13.
 *
 ******************************************************************/

  PROCEDURE validate_lot_serial_for_rcpt
  (p_interface_id                 IN NUMBER
   , p_org_id                     IN NUMBER
   , p_item_id                    IN NUMBER
   , p_lotctrl                    IN NUMBER
   , p_serctrl                    IN NUMBER
   , p_rev                        IN VARCHAR2 DEFAULT NULL
   , p_trx_src_id                 IN NUMBER DEFAULT NULL
   , p_trx_action_id              IN NUMBER DEFAULT NULL
   , p_subinventory_code          IN VARCHAR2 DEFAULT NULL
   , p_locator_id                 IN NUMBER DEFAULT NULL
   , x_proc_msg                   OUT NOCOPY VARCHAR2
   , x_return_status              OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR cur_MTLI IS
    SELECT LOT_NUMBER
           , LOT_EXPIRATION_DATE
           , LOT_ATTRIBUTE_CATEGORY
           , ATTRIBUTE_CATEGORY
           , ATTRIBUTE1
           , ATTRIBUTE2
           , ATTRIBUTE3
           , ATTRIBUTE4
           , ATTRIBUTE5
           , ATTRIBUTE6
           , ATTRIBUTE7
           , ATTRIBUTE8
           , ATTRIBUTE9
           , ATTRIBUTE10
           , ATTRIBUTE11
           , ATTRIBUTE12
           , ATTRIBUTE13
           , ATTRIBUTE14
           , ATTRIBUTE15
           , C_ATTRIBUTE1
           , C_ATTRIBUTE2
           , C_ATTRIBUTE3
           , C_ATTRIBUTE4
           , C_ATTRIBUTE5
           , C_ATTRIBUTE6
           , C_ATTRIBUTE7
           , C_ATTRIBUTE8
           , C_ATTRIBUTE9
           , C_ATTRIBUTE10
           , C_ATTRIBUTE11
           , C_ATTRIBUTE12
           , C_ATTRIBUTE13
           , C_ATTRIBUTE14
           , C_ATTRIBUTE15
           , C_ATTRIBUTE16
           , C_ATTRIBUTE17
           , C_ATTRIBUTE18
           , C_ATTRIBUTE19
           , C_ATTRIBUTE20
           , N_ATTRIBUTE1
           , N_ATTRIBUTE2
           , N_ATTRIBUTE3
           , N_ATTRIBUTE4
           , N_ATTRIBUTE5
           , N_ATTRIBUTE6
           , N_ATTRIBUTE7
           , N_ATTRIBUTE8
           , N_ATTRIBUTE9
           , N_ATTRIBUTE10
           , D_ATTRIBUTE1
           , D_ATTRIBUTE2
           , D_ATTRIBUTE3
           , D_ATTRIBUTE4
           , D_ATTRIBUTE5
           , D_ATTRIBUTE6
           , D_ATTRIBUTE7
           , D_ATTRIBUTE8
           , D_ATTRIBUTE9
           , D_ATTRIBUTE10
           , GRADE_CODE
           , ORIGINATION_DATE
           , DATE_CODE
           , STATUS_ID
           , CHANGE_DATE
           , AGE
           , RETEST_DATE
           , MATURITY_DATE
           , ITEM_SIZE
           , COLOR
           , VOLUME
           , VOLUME_UOM
           , PLACE_OF_ORIGIN
           , BEST_BY_DATE
           , LENGTH
           , LENGTH_UOM
           , RECYCLED_CONTENT
           , THICKNESS
           , THICKNESS_UOM
           , WIDTH
           , WIDTH_UOM
           , TERRITORY_CODE
           , SUPPLIER_LOT_NUMBER
           , VENDOR_NAME
           , SERIAL_TRANSACTION_TEMP_ID
      FROM MTL_TRANSACTION_LOTS_INTERFACE
      WHERE TRANSACTION_INTERFACE_ID = p_interface_id;

    CURSOR cur_MSNI(interface_id NUMBER) IS
    SELECT FM_SERIAL_NUMBER
           , TO_SERIAL_NUMBER
      FROM   MTL_SERIAL_NUMBERS_INTERFACE
      WHERE  TRANSACTION_INTERFACE_ID = interface_id;

    -- PL/SQL table to store lot attributes
    l_attributes_tbl   inv_lot_api_pub.char_tbl;
    l_c_attributes_tbl inv_lot_api_pub.char_tbl;
    l_n_attributes_tbl inv_lot_api_pub.number_tbl;
    l_d_attributes_tbl inv_lot_api_pub.date_tbl;

    l_lot_exists NUMBER := 0;
    l_ret_number NUMBER := 0;
    l_qty        NUMBER := NULL;
    l_start_qty  NUMBER := 0;
    l_end_ser    VARCHAR2(30);

    l_expiration_date DATE;
    l_object_id       NUMBER;
    l_msg_count       NUMBER;

  BEGIN
    x_return_status  := lg_ret_sts_success;

    -- Check for both lot and serial controlled item
    IF (p_lotctrl = 2 AND p_serctrl IN (2,5) ) THEN
      IF (l_debug = 1) THEN
        inv_log_util.trace('Validating both lot and serial controlled item','INV_TXN_MANAGER_GRP', 9);
      END IF;
      -- Looping through all MTLI records
      FOR rec_MTLI IN cur_MTLI
      LOOP

        -- Check to see if the lot already exists
        -- If 'NO' then call the create_inv_lot API
        l_lot_exists := 0;
        BEGIN
         SELECT 1 INTO l_lot_exists
           FROM DUAL
           WHERE EXISTS(SELECT  lot_number
                          FROM  mtl_lot_numbers
                          WHERE lot_number = rec_MTLI.LOT_NUMBER
                            AND inventory_item_id = p_item_id
                            AND organization_id = p_org_id);
        EXCEPTION
        WHEN OTHERS THEN
          l_lot_exists := 0;
        END; -- End of check for lot exists

        IF (l_lot_exists = 1) THEN
          IF (l_debug = 1) THEN
            inv_log_util.trace('Lot already exists','INV_TXN_MANAGER_GRP', 9);
          END IF;
        ELSE -- Have to create a new lot

          l_attributes_tbl(1)  := rec_MTLI.ATTRIBUTE1;
          l_attributes_tbl(2)  := rec_MTLI.ATTRIBUTE2;
          l_attributes_tbl(3)  := rec_MTLI.ATTRIBUTE3;
          l_attributes_tbl(4)  := rec_MTLI.ATTRIBUTE4;
          l_attributes_tbl(5)  := rec_MTLI.ATTRIBUTE5;
          l_attributes_tbl(6)  := rec_MTLI.ATTRIBUTE6;
          l_attributes_tbl(7)  := rec_MTLI.ATTRIBUTE7;
          l_attributes_tbl(8)  := rec_MTLI.ATTRIBUTE8;
          l_attributes_tbl(9)  := rec_MTLI.ATTRIBUTE9;
          l_attributes_tbl(10) := rec_MTLI.ATTRIBUTE10;
          l_attributes_tbl(11) := rec_MTLI.ATTRIBUTE11;
          l_attributes_tbl(12) := rec_MTLI.ATTRIBUTE12;
          l_attributes_tbl(13) := rec_MTLI.ATTRIBUTE13;
          l_attributes_tbl(14) := rec_MTLI.ATTRIBUTE14;
          l_attributes_tbl(15) := rec_MTLI.ATTRIBUTE15;

          l_c_attributes_tbl(1)  := rec_MTLI.C_ATTRIBUTE1;
          l_c_attributes_tbl(2)  := rec_MTLI.C_ATTRIBUTE2;
          l_c_attributes_tbl(3)  := rec_MTLI.C_ATTRIBUTE3;
          l_c_attributes_tbl(4)  := rec_MTLI.C_ATTRIBUTE4;
          l_c_attributes_tbl(5)  := rec_MTLI.C_ATTRIBUTE5;
          l_c_attributes_tbl(6)  := rec_MTLI.C_ATTRIBUTE6;
          l_c_attributes_tbl(7)  := rec_MTLI.C_ATTRIBUTE7;
          l_c_attributes_tbl(8)  := rec_MTLI.C_ATTRIBUTE8;
          l_c_attributes_tbl(9)  := rec_MTLI.C_ATTRIBUTE9;
          l_c_attributes_tbl(10) := rec_MTLI.C_ATTRIBUTE10;
          l_c_attributes_tbl(11) := rec_MTLI.C_ATTRIBUTE11;
          l_c_attributes_tbl(12) := rec_MTLI.C_ATTRIBUTE12;
          l_c_attributes_tbl(13) := rec_MTLI.C_ATTRIBUTE13;
          l_c_attributes_tbl(14) := rec_MTLI.C_ATTRIBUTE14;
          l_c_attributes_tbl(15) := rec_MTLI.C_ATTRIBUTE15;
          l_c_attributes_tbl(16) := rec_MTLI.C_ATTRIBUTE16;
          l_c_attributes_tbl(17) := rec_MTLI.C_ATTRIBUTE17;
          l_c_attributes_tbl(18) := rec_MTLI.C_ATTRIBUTE18;
          l_c_attributes_tbl(19) := rec_MTLI.C_ATTRIBUTE19;
          l_c_attributes_tbl(20) := rec_MTLI.C_ATTRIBUTE20;

          l_n_attributes_tbl(1)  := rec_MTLI.N_ATTRIBUTE1;
          l_n_attributes_tbl(2)  := rec_MTLI.N_ATTRIBUTE2;
          l_n_attributes_tbl(3)  := rec_MTLI.N_ATTRIBUTE3;
          l_n_attributes_tbl(4)  := rec_MTLI.N_ATTRIBUTE4;
          l_n_attributes_tbl(5)  := rec_MTLI.N_ATTRIBUTE5;
          l_n_attributes_tbl(6)  := rec_MTLI.N_ATTRIBUTE6;
          l_n_attributes_tbl(7)  := rec_MTLI.N_ATTRIBUTE7;
          l_n_attributes_tbl(8)  := rec_MTLI.N_ATTRIBUTE8;
          l_n_attributes_tbl(9)  := rec_MTLI.N_ATTRIBUTE9;
          l_n_attributes_tbl(10) := rec_MTLI.N_ATTRIBUTE10;

          l_d_attributes_tbl(1)  := rec_MTLI.D_ATTRIBUTE1;
          l_d_attributes_tbl(2)  := rec_MTLI.D_ATTRIBUTE2;
          l_d_attributes_tbl(3)  := rec_MTLI.D_ATTRIBUTE3;
          l_d_attributes_tbl(4)  := rec_MTLI.D_ATTRIBUTE4;
          l_d_attributes_tbl(5)  := rec_MTLI.D_ATTRIBUTE5;
          l_d_attributes_tbl(6)  := rec_MTLI.D_ATTRIBUTE6;
          l_d_attributes_tbl(7)  := rec_MTLI.D_ATTRIBUTE7;
          l_d_attributes_tbl(8)  := rec_MTLI.D_ATTRIBUTE8;
          l_d_attributes_tbl(9)  := rec_MTLI.D_ATTRIBUTE9;
          l_d_attributes_tbl(10) := rec_MTLI.D_ATTRIBUTE10;

          IF (l_debug=1) THEN
            inv_log_util.trace('Before call to inv_lot_api_pub.create_inv_lot', 'INV_TXN_MANAGER_GRP', 9);
          END IF;

          inv_lot_api_pub.create_inv_lot(
          x_return_status            => x_return_status
          , x_msg_count              => l_msg_count
          , x_msg_data               => x_proc_msg
          , p_inventory_item_id      => p_item_id
          , p_organization_id        => p_org_id
          , p_lot_number             => rec_MTLI.LOT_NUMBER
          , p_expiration_date        => rec_MTLI.LOT_EXPIRATION_DATE
          , p_disable_flag           => null
          , p_attribute_category     => rec_MTLI.ATTRIBUTE_CATEGORY
          , p_lot_attribute_category => rec_MTLI.LOT_ATTRIBUTE_CATEGORY
          , p_attributes_tbl         => l_attributes_tbl
          , p_c_attributes_tbl       => l_c_attributes_tbl
          , p_n_attributes_tbl       => l_n_attributes_tbl
          , p_d_attributes_tbl       => l_d_attributes_tbl
          , p_grade_code             => rec_MTLI.GRADE_CODE
          , p_origination_date       => rec_MTLI.ORIGINATION_DATE
          , p_date_code              => rec_MTLI.DATE_CODE
          , p_status_id              => rec_MTLI.STATUS_ID
          , p_change_date            => rec_MTLI.CHANGE_DATE
          , p_age                    => rec_MTLI.AGE
          , p_retest_date            => rec_MTLI.RETEST_DATE
          , p_maturity_date          => rec_MTLI.MATURITY_DATE
          , p_item_size              => rec_MTLI.ITEM_SIZE
          , p_color                  => rec_MTLI.COLOR
          , p_volume                 => rec_MTLI.VOLUME
          , p_volume_uom             => rec_MTLI.VOLUME_UOM
          , p_place_of_origin        => rec_MTLI.PLACE_OF_ORIGIN
          , p_best_by_date           => rec_MTLI.BEST_BY_DATE
          , p_length                 => rec_MTLI.LENGTH
          , p_length_uom             => rec_MTLI.LENGTH_UOM
          , p_recycled_content       => rec_MTLI.RECYCLED_CONTENT
          , p_thickness              => rec_MTLI.THICKNESS
          , p_thickness_uom          => rec_MTLI.THICKNESS_UOM
          , p_width                  => rec_MTLI.WIDTH
          , p_width_uom              => rec_MTLI.WIDTH_UOM
          , p_territory_code         => rec_MTLI.TERRITORY_CODE
          , p_supplier_lot_number    => rec_MTLI.SUPPLIER_LOT_NUMBER
          , p_vendor_name            => rec_MTLI.VENDOR_NAME
          , p_source                 => null
          );

          IF (l_debug=1) THEN
            inv_log_util.trace('After call to inv_lot_api_pub.create_inv_lot', 'INV_TXN_MANAGER_GRP', 9);
            inv_log_util.trace(' x_return_status : ' || x_return_status, 'INV_TXN_MANAGER_GRP', 9);
          END IF;
        END IF; -- End of Lot Exists check

        IF (x_return_status = lg_ret_sts_success) THEN
          IF (l_debug=1) THEN
            inv_log_util.trace('Call to inv_lot_api_pub.create_inv_lot was successful','INV_TXN_MANAGER_GRP', 9);
          END IF;
          -- Looping through every serials in the lot
          FOR rec_MSNI IN cur_MSNI(rec_MTLI.SERIAL_TRANSACTION_TEMP_ID)
          LOOP
            IF (l_debug=1) THEN
              inv_log_util.trace('About to call inv_serial_number_pub.validate_serials', 'INV_TXN_MANAGER_GRP', 9);
            END IF;

            l_qty := NULL;
            l_end_ser := NVL(rec_MSNI.TO_SERIAL_NUMBER,rec_MSNI.FM_SERIAL_NUMBER);
            l_start_qty := inv_serial_number_pub.get_serial_diff(rec_MSNI.FM_SERIAL_NUMBER,l_end_ser);
            l_ret_number := inv_serial_number_pub.validate_serials(
                            p_org_id                  => p_org_id
                            , p_item_id               => p_item_id
                            , p_qty                   => l_qty
                            , p_rev                   => p_rev
                            , p_lot                   => rec_MTLI.LOT_NUMBER
                            , p_start_ser             => rec_MSNI.FM_SERIAL_NUMBER
                            , p_trx_src_id            => p_trx_src_id
                            , p_trx_action_id         => p_trx_action_id
                            , p_subinventory_code     => p_subinventory_code
                            , p_locator_id            => p_locator_id
                            , p_issue_receipt         => 'R'
                            , x_end_ser               => l_end_ser
                            , x_proc_msg              => x_proc_msg
                            , p_check_for_grp_mark_id => 'Y'
                            );
            -- Check for group mark validations
            IF (l_start_qty <> l_qty) THEN
              x_return_status := lg_ret_sts_error;
              loaderrmsg('INV_INT_SERMISCODE','INV_LOT_SERIAL_VALIDATION_FAIL');
              IF (l_debug = 1) THEN
                inv_log_util.trace('Group mark validations failed', 'INV_TXN_MANAGER_GRP', 9);
              END IF;
              RETURN;
            END IF; -- End of group mark validations
            IF (l_debug=1) THEN
              inv_log_util.trace('After call to inv_serial_number_pub.validate_serials', 'INV_TXN_MANAGER_GRP', 9);
              inv_log_util.trace(' l_ret_number : ' || l_ret_number, 'INV_TXN_MANAGER_GRP', 9);
            END IF;
            IF (l_ret_number = 0) THEN -- Success from inv_serial_number_pub.validate_serials
              x_return_status := lg_ret_sts_success;
              IF (l_debug = 1) THEN
                inv_log_util.trace('Call to inv_serial_number_pub.validate_serials was successful','INV_TXN_MANAGER_GRP', 9);
              END IF;
            ELSIF (l_ret_number = 1) THEN
              x_return_status := lg_ret_sts_error;
              loaderrmsg('INV_INT_SERMISCODE','INV_LOT_SERIAL_VALIDATION_FAIL');
              IF (l_debug = 1) THEN
                inv_log_util.trace('Error from inv_serial_number_pub.validate_serials'|| x_proc_msg || ':' || sqlerrm,'INV_TXN_MANAGER_GRP', 9);
              END IF;
              RETURN;
            END IF;
          END LOOP; -- End of cur_MSNI cursor

        ELSE  -- Failure from inv_lot_api_pub.create_inv_lot
          x_return_status := lg_ret_sts_error;
          loaderrmsg('INV_INT_LOTCODE','INV_LOT_SERIAL_VALIDATION_FAIL');
          IF (l_debug = 1) THEN
            inv_log_util.trace('Error from inv_lot_api_pub.create_inv_lot'|| x_proc_msg || ':' || sqlerrm,'INV_TXN_MANAGER_GRP', 9);
          END IF;
          RETURN;
        END IF;

      END LOOP; -- End of cur_MTLI

    -- Check for only serial controlled item
    ELSIF (p_lotctrl = 1 AND p_serctrl IN (2,5)) THEN

      -- Looping through every serials in the table
      FOR rec_MSNI IN cur_MSNI(p_interface_id)
      LOOP

        l_qty := NULL;
        l_end_ser := NVL(rec_MSNI.TO_SERIAL_NUMBER,rec_MSNI.FM_SERIAL_NUMBER);
        l_start_qty := inv_serial_number_pub.get_serial_diff(rec_MSNI.FM_SERIAL_NUMBER,l_end_ser);
        IF (l_debug=1) THEN
          inv_log_util.trace('About to call inv_serial_number_pub.validate_serials', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
        l_ret_number := inv_serial_number_pub.validate_serials(
                        p_org_id                  => p_org_id
                        , p_item_id               => p_item_id
                        , p_qty                   => l_qty
                        , p_rev                   => p_rev
                        , p_lot                   => null
                        , p_start_ser             => rec_MSNI.FM_SERIAL_NUMBER
                        , p_trx_src_id            => p_trx_src_id
                        , p_trx_action_id         => p_trx_action_id
                        , p_subinventory_code     => p_subinventory_code
                        , p_locator_id            => p_locator_id
                        , p_issue_receipt         => 'R'
                        , x_end_ser               => l_end_ser
                        , x_proc_msg              => x_proc_msg
                        , p_check_for_grp_mark_id => 'Y'
                        );
        --Check for Group mark validations
        IF (l_start_qty <> l_qty) THEN
          x_return_status := lg_ret_sts_error;
          loaderrmsg('INV_INT_SERMISCODE','INV_LOT_SERIAL_VALIDATION_FAIL');
          IF (l_debug = 1) THEN
            inv_log_util.trace('Group mark validations failed', 'INV_TXN_MANAGER_GRP', 9);
          END IF;
          RETURN;
        END IF;  -- End of check for group mark validations
        IF (l_debug=1) THEN
          inv_log_util.trace('After call to inv_serial_number_pub.validate_serials', 'INV_TXN_MANAGER_GRP', 9);
          inv_log_util.trace(' l_ret_number : ' || l_ret_number, 'INV_TXN_MANAGER_GRP', 9);
        END IF;

        IF (l_ret_number = 0) THEN -- Success from inv_serial_number_pub.validate_serials
          x_return_status := lg_ret_sts_success;
          IF (l_debug = 1) THEN
            inv_log_util.trace('Call to inv_serial_number_pub.validate_serials was successful','INV_TXN_MANAGER_GRP', 9);
          END IF;
        ELSIF (l_ret_number = 1) THEN -- Failure from inv_serial_number_pub.validate_serials
          x_return_status := lg_ret_sts_error;
          loaderrmsg('INV_INT_SERMISCODE','INV_LOT_SERIAL_VALIDATION_FAIL');
          IF (l_debug = 1) THEN
            inv_log_util.trace('Error from inv_serial_number_pub.validate_serials'|| x_proc_msg || ':' || sqlerrm,'INV_TXN_MANAGER_GRP', 9);
          END IF;
          RETURN;
        END IF;

      END LOOP; -- End of cur_MSNI
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := lg_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
        inv_log_util.trace(' x_return_status : ' || x_return_status, 'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('Exception in validate_lot_serial_for_rcpt '|| x_proc_msg || ':' || sqlerrm, 'INV_TXN_MANAGER_GRP', 9);
      END IF;
      loaderrmsg('INV_INT_SERMISCODE','INV_LOT_SERIAL_VALIDATION_FAIL');

  END validate_lot_serial_for_rcpt;

/******************************************************************
 *
 * validate_lines() : Outer
 *
 ******************************************************************/
PROCEDURE validate_lines(p_header_id NUMBER,
                         p_commit VARCHAR2 := fnd_api.g_false     ,
                         p_validation_level NUMBER  := fnd_api.g_valid_level_full  ,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2,
                         p_userid NUMBER,
                         p_loginid NUMBER,
                         p_applid NUMBER,
                         p_progid NUMBER)
AS

    CURSOR AA1 IS
    SELECT
        TRANSACTION_INTERFACE_ID,
        TRANSACTION_HEADER_ID,
        REQUEST_ID,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        SUBINVENTORY_CODE,
        TRANSFER_ORGANIZATION,
        TRANSFER_SUBINVENTORY,
        TRANSACTION_UOM,
        TRANSACTION_DATE,
        TRANSACTION_QUANTITY,
        LOCATOR_ID,
        TRANSFER_LOCATOR,
        TRANSACTION_SOURCE_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_TYPE_ID,
        DISTRIBUTION_ACCOUNT_ID,
        NVL(SHIPPABLE_FLAG,'Y'),
        ROWID,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        RESOURCE_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        REQUISITION_LINE_ID,
        OVERCOMPLETION_TRANSACTION_QTY,   /* Overcompletion Transactions */
        END_ITEM_UNIT_NUMBER,
        SCHEDULED_PAYBACK_DATE, /* Borrow Payback */
        REVISION,   /* Borrow Payback */
        ORG_COST_GROUP_ID,  /* PCST */
        COST_TYPE_ID, /* PCST */
        PRIMARY_QUANTITY,
        SOURCE_LINE_ID,
        PROCESS_FLAG,
        TRANSACTION_SOURCE_NAME,
        TRX_SOURCE_DELIVERY_ID,
        TRX_SOURCE_LINE_ID,
        PARENT_ID,
        TRANSACTION_BATCH_ID,
        TRANSACTION_BATCH_SEQ,
        -- INVCONV start fabdi
        SECONDARY_TRANSACTION_QUANTITY,
        SECONDARY_UOM_CODE
        -- INVCONV end fabdi
       ,SHIP_TO_LOCATION_ID --eIB Build; Bug# 4348541
       , transfer_price     -- OPM INVCONV umoogala Bug 4432078
       ,wip_entity_type -- Pawan 11th july added
       /*Bug:5392366. Added the following two columns. */
       ,completion_transaction_id
       ,move_transaction_id
    FROM MTL_TRANSACTIONS_INTERFACE
    WHERE TRANSACTION_HEADER_ID = p_header_id
      AND PROCESS_FLAG = 1
    ORDER BY ORGANIZATION_ID,INVENTORY_ITEM_ID,REVISION,
          SUBINVENTORY_CODE,LOCATOR_ID;


   line_vldn_error_flag VARCHAR(1);
   l_Line_Rec_Type inv_txn_manager_pub.Line_Rec_Type;
   l_count number;

BEGIN
    if ( l_debug is null) then
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    end if;

    fnd_flex_key_api.set_session_mode('seed_data');

     FOR l_Line_rec_Type IN AA1 LOOP
       BEGIN
         savepoint line_validation_svpt;
           validate_lines(p_line_Rec_Type => l_Line_rec_type,
                          p_commit => p_commit,
                          p_validation_level => p_validation_level,
                          p_error_flag => line_vldn_error_flag,
                          p_userid => p_userid,
                          p_loginid => p_loginid,
                          p_applid => p_applid,
                          p_progid => p_progid);
                IF (line_vldn_error_flag = 'Y') then
                        IF (l_debug = 1) THEN
                           inv_log_util.trace('Error in Line Validatin', 'INV_TXN_MANAGER_GRP', 9);
                        END IF;
                END IF;

       END;
     END LOOP;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
        IF (l_debug = 1) THEN
        inv_log_util.trace('Error in outer validate_lines'||substr(sqlerrm,1,240),
                                'INV_TXN_MANAGER_GRP',1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END validate_lines;


/******************************************************************
 *
 * validate_lines()
 *  Validate one transaction record in MTL_TRANSACTIONS_INTERFACE
 *
 ******************************************************************/
PROCEDURE validate_lines(p_line_Rec_Type inv_txn_manager_pub.line_rec_type,
                         p_commit VARCHAR2 := fnd_api.g_false     ,
                         p_validation_level NUMBER  := fnd_api.g_valid_level_full  ,
                         p_error_flag OUT NOCOPY VARCHAR2,
                         p_userid NUMBER,
                         p_loginid NUMBER,
                         p_applid NUMBER,
                         p_progid NUMBER)
AS

    l_shlfdays NUMBER;
    l_count NUMBER;
    l_header_id NUMBER;
    l_intid NUMBER;
    l_itemid NUMBER;
    l_orgid NUMBER;
    l_xorgid NUMBER;
    l_locid NUMBER;
    l_loci NUMBER;
    l_prdid NUMBER;
    l_xlocid NUMBER;
    l_acttype NUMBER;
    l_trxtype NUMBER;
    l_srctypeid NUMBER;
    l_error_num NUMBER;
    l_mat_accnt NUMBER;
    l_mat_ovhd_accnt NUMBER;
    l_res_accnt NUMBER;
    l_osp_accnt NUMBER;
    l_ovhd_accnt NUMBER;
    l_srctype NUMBER;
    l_req_line_id NUMBER;
    l_primary_cost_method NUMBER;
    l_acct NUMBER;
    l_trxsrc VARCHAR(40);
    l_cost_type_id NUMBER;
    l_org_cost_group_id NUMBER;  /* PCST (Periodic Cost Update) */
    l_default_locator_status NUMBER;     /* Status Control */
    l_overcomp_txn_qty NUMBER;
    l_overcomp_primary_qty NUMBER :=0; /* Overcompletion Transactions */
    tev_flow_schedule NUMBER := 0;
    tev_scheduled_flag NUMBER := 1; --Bug #6449667, changing the default value from 0 to 1.
    l_trxqty NUMBER;
    l_priqty NUMBER;
    l_new_avg_cst NUMBER;
    l_val_chng NUMBER;
    l_per_chng NUMBER;
    l_rowid VARCHAR2(20);
    l_subinv VARCHAR2(11);
    l_xsubinv VARCHAR2(11);
    l_trxdate DATE;
    -- l_trxdate VARCHAR2(22);
    l_scheduled_payback_date VARCHAR2(22);
    l_trxuom VARCHAR2(4);
    l_priuom VARCHAR2(4);
    l_unit_number VARCHAR2(31);
    l_itmshpflag VARCHAR2(1);
    l_revision VARCHAR2(3); /* Borrow Payback */
    x_return_status VARCHAR2(1);
    l_locctrl NUMBER;
    l_xlocctrl NUMBER;
    l_lotctrl NUMBER;
    l_serctrl NUMBER;
    l_resloc NUMBER;
    l_xlotctrl NUMBER;
    l_xserctrl NUMBER;
    l_xresloc NUMBER;
    l_engitemflag NUMBER;
    l_lotuniq NUMBER;
    l_shlfcode VARCHAR2(40);
    l_avg_cost_update NUMBER;
    l_flow_schedule_children NUMBER;
    l_exp_type_required NUMBER :=1;
    l_tnum NUMBER;
    l_cst_temp NUMBER;
    l_reqstid NUMBER;

    l_result NUMBER;
    l_lcm_enabled_org mtl_parameters.lcm_enabled_flag%type := 'N';


    /* WMS installed -- Installed:1, not installed: 0 */
    wms_installed               NUMBER;

    l_wms_installed boolean;
    l_return_status      VARCHAR2(300);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(300);
    l_validate_full      BOOLEAN :=TRUE;

     l_cg_org NUMBER := NULL;                   -- Bug 6356567 Starting
    l_cost_group_id NUMBER := NULL;
    l_xfer_cost_group_id NUMBER := NULL;
    l_temp_cost_group_id NUMBER := NULL;
    l_temp_xfer_cost_group_id NUMBER := NULL;   -- Bug 6356567 Ending

    -- INVCONV fabdi start
    l_secondary_qty NUMBER;
    l_secondary_UOM VARCHAR2(3);
    -- INVCONV fabdi end

    -- OPM INVCONV umoogala For Process-Discrete Enh.
    -- Bug 4432078
    l_pd_xfer_ind             BINARY_INTEGER;
    l_transfer_price          NUMBER;
    l_transfer_price_priuom   NUMBER;
    l_from_ou                 BINARY_INTEGER;
    l_to_ou                   BINARY_INTEGER;
    /* l_order_line_id           BINARY_INTEGER;  commented for bug 10174613 */
    l_order_line_id           NUMBER;
    l_xfer_type               VARCHAR2(6);
    l_xfer_source             VARCHAR2(6);

    x_currency_code           VARCHAR2(31);
    x_incr_transfer_price     NUMBER;
    x_incr_currency_code      VARCHAR2(31);
    x_msg_data                VARCHAR2(3000);
    x_msg_count               NUMBER;

    l_process_enabled_flag_from VARCHAR2(1);
    l_process_enabled_flag_to   VARCHAR2(1);

    l_ic_invoicing_enabled      NUMBER;
    -- End OPM INVCONV umoogala

    l_is_wsm_enabled     VARCHAR2(1);
    /*Bug#5205455. Added the below 2 variables*/
    l_fob_point NUMBER;
    l_validate_xfer_org BOOLEAN := FALSE;

    --hjogleka
    --Bug #5497519
    l_lot_ser_qty NUMBER;
    l_account varchar2(100); /* Bug 6271039 */

    --Start: Fix for Bug# 7323175
    l_project_ref_enabled NUMBER := 0;
    l_plocid NUMBER;
    l_xplocid NUMBER;
    --End: Fix for Bug# 7323175

    -- Altered the changes made in the bug 7323175 for the bug 12922489
    v_result  BOOLEAN      := TRUE;
    v_mode    VARCHAR2(10) := 'ANY';
    v_required_flag    VARCHAR2(3)  := 'N';
    v_project_id          NUMBER       := NULL;
    v_task_id             NUMBER       := NULL;
    -- Altered the changes made in the bug 7323175 for the bug 12922489

    --serial tagging
    serial_tagged NUMBER := 0;
BEGIN

    if (l_debug is null) then
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    end if;
    IF (l_debug = 1) THEN
        inv_log_util.trace('in Validate_lines ....','INV_TXN_MANAGER_GRP', 9);
    END IF;

    l_count := 0;

    /*----------------------------------------
    |  Checking whether WMS is installed
    +-----------------------------------------*/
     l_wms_installed := wms_install.check_install
       (x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_organization_id => null );

        IF l_wms_installed then
          wms_installed := 1;
      else
        wms_installed := 0;
      END IF;

    /* ACP */
    l_avg_cost_update := 2;


            l_intid    := p_line_Rec_Type.TRANSACTION_INTERFACE_ID;
            l_header_id:= p_line_Rec_Type.TRANSACTION_HEADER_ID;
            l_reqstid  := p_line_Rec_Type.REQUEST_ID;
            l_itemid   := p_line_Rec_Type.INVENTORY_ITEM_ID;
            l_orgid    := p_line_Rec_Type.ORGANIZATION_ID;
            l_subinv   := p_line_Rec_Type.SUBINVENTORY_CODE;
            l_xorgid   := p_line_Rec_Type.TRANSFER_ORGANIZATION;
            l_xsubinv  := p_line_Rec_Type.TRANSFER_SUBINVENTORY;
            l_trxuom   := p_line_Rec_Type.TRANSACTION_UOM;
            l_trxdate  := p_line_Rec_Type.TRANSACTION_DATE;
            l_trxqty   := p_line_Rec_Type.TRANSACTION_QUANTITY;
            l_locid    := p_line_Rec_Type.LOCATOR_ID;
            l_xlocid   := p_line_Rec_Type.TRANSFER_LOCATOR;
            l_trxsrc   := p_line_Rec_Type.TRANSACTION_SOURCE_ID;
            l_srctype  := p_line_Rec_Type.TRANSACTION_SOURCE_TYPE_ID;
            l_acttype  := p_line_Rec_Type.TRANSACTION_ACTION_ID;
            l_trxtype  := p_line_Rec_Type.TRANSACTION_TYPE_ID;
            l_acct     := p_line_Rec_Type.DISTRIBUTION_ACCOUNT_ID;
            l_itmshpflag       := p_line_Rec_Type.SHIPPABLE_FLAG ;
            l_rowid            := p_line_Rec_Type.ROWID;
            l_new_avg_cst      := p_line_Rec_Type.NEW_AVERAGE_COST;
            l_val_chng         := p_line_Rec_Type.VALUE_CHANGE;
            l_per_chng         := p_line_Rec_Type.PERCENTAGE_CHANGE;
            l_mat_accnt        := p_line_Rec_Type.MATERIAL_ACCOUNT;
            l_mat_ovhd_accnt   := p_line_Rec_Type.MATERIAL_OVERHEAD_ACCOUNT;
            l_res_accnt        := p_line_Rec_Type.RESOURCE_ACCOUNT;
            l_osp_accnt        := p_line_Rec_Type.OUTSIDE_PROCESSING_ACCOUNT;
            l_ovhd_accnt       := p_line_Rec_Type.OVERHEAD_ACCOUNT;
            l_req_line_id      := p_line_Rec_Type.REQUISITION_LINE_ID;
            l_overcomp_txn_qty := p_line_Rec_Type.OVERCOMPLETION_TRANSACTION_QTY;
            l_unit_number      := p_line_Rec_Type.END_ITEM_UNIT_NUMBER;
            l_scheduled_payback_date := p_line_Rec_Type.SCHEDULED_PAYBACK_DATE;
            l_revision          := p_line_Rec_Type.REVISION ;
            l_org_cost_group_id := p_line_Rec_Type.ORG_COST_GROUP_ID;
            l_cost_type_id      := p_line_Rec_Type.COST_TYPE_ID;
            l_secondary_qty     := p_line_Rec_Type.SECONDARY_TRANSACTION_QUANTITY;
            l_secondary_uom     := p_line_Rec_Type.SECONDARY_UOM_CODE;
            l_transfer_price    := p_line_Rec_Type.TRANSFER_PRICE;  -- INVCONV umoogala  Bug 4432078
            l_order_line_id     := p_line_Rec_Type.TRX_SOURCE_LINE_ID;  -- INVCONV umoogala  Bug 4432078

            IF l_locid IS NOT NULL THEN
                l_loci := 1;
            ELSE
                l_loci := -1;
            END IF;

            IF (l_debug = 1) THEN
                inv_log_util.trace('Before calling fnd_profile.put MFG_ORGANIZATION_ID','INV_TXN_MANAGER_PUB',9);
            END IF;

            fnd_profile.put('MFG_ORGANIZATION_ID',l_orgid);

            /**J-dev check we need to perform a full validation*/
            IF (l_debug = 1) THEN
               inv_log_util.trace('wip_constants.DMF_PATCHSET_LEVEL'||wip_constants.dmf_patchset_level,'INV_TXN_MANAGER_GRP', 9);
               inv_log_util.trace('wip_constants.DMF_PATCHSET_J_VALUE'||wip_constants.dmf_patchset_J_VALUE,'INV_TXN_MANAGER_GRP', 9);
            END IF;

            IF (l_srctype = 5 AND wip_constants.DMF_PATCHSET_LEVEL>= wip_constants.DMF_PATCHSET_J_VALUE)  THEN
               IF (p_validation_level <> fnd_api.g_valid_level_full) THEN
                  l_validate_full := FALSE;
                  /**implies this a WIP desktop transaction*/
                  IF (l_debug = 1) THEN
                     inv_log_util.trace('Val line:WIP desktop trx','INV_TXN_MANAGER_GRP', 9);
                  END IF;
                ELSE
                  IF (l_debug = 1) THEN
                     inv_log_util.trace('Val line:WIP MTI trx','INV_TXN_MANAGER_GRP', 9);
                  END IF;
               END IF;
            END IF;--J-dev

            --serial tagging
            inv_serial_number_pub.is_serial_controlled(
                l_itemid,
                l_orgid,
                NULL,
                l_trxtype,
                l_srctype,
                l_acttype,
                l_serctrl,
                NULL,
                serial_tagged,
                l_return_status
            );
            IF l_return_status <> 'S' THEN
              serial_tagged := 1;
            END IF;


            --Begin Fix 2505534

            IF (l_debug = 1) THEN
               inv_log_util.trace('Before calling setorgclientinfo with l_orgid '||l_orgid, 'INV_TXN_MANAGER_GRP', 9);
            END IF;

            IF (NOT setorgclientinfo(l_orgid)) THEN
            RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_debug = 1) THEN
            inv_log_util.trace('After calling setorgclientinfo', 'INV_TXN_MANAGER_GRP',9);
            END IF;

            /* load message to detect source project error */
                loaderrmsg('INV_PRJ_ERR','INV_PRJ_ERR');

            IF (l_debug = 1) THEN
            inv_log_util.trace('After loaderrmsg INV_PRJ_ERR', 'INV_TXN_MANAGER_GRP',9);
            END IF;

            /* validate source project id */
            IF (l_debug = 1) THEN
               inv_log_util.trace('#$Validating source project ID l_error_code '||l_error_code||' l_error_exp '||l_error_exp , 'INV_TXN_MANAGER_GRP', 9);
               inv_log_util.trace('#$l_rowid '||l_rowid, 'INV_TXN_MANAGER_GRP', 9);
            END IF;


                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                    SET LAST_UPDATE_DATE = SYSDATE,
                    LAST_UPDATED_BY = p_userid,
                    LAST_UPDATE_LOGIN = p_loginid,
                    PROGRAM_UPDATE_DATE = SYSDATE,
                    PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                    ERROR_CODE = substrb(l_error_code,1,240),
                    ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                WHERE ROWID = l_rowid
                    AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
                            (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
                    AND TRANSACTION_ACTION_ID IN (1, 27 )
                    AND PROCESS_FLAG = 1
                    AND EXISTS (
                            SELECT null
                            FROM MTL_TRANSACTION_TYPES MTTY
                            WHERE MTTY.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                    AND MTTY.TYPE_CLASS = 1 )
                    AND NOT EXISTS (
                            SELECT null
                    FROM pa_projects_expend_v prj1
                    WHERE prj1.project_id = mti.source_project_id ) ;

                if sql%notfound then
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Passed the source project Validation**', 'INV_TXN_MANAGER_GRP',9);
                     END IF;
                else
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Failed the source project Validation**', 'INV_TXN_MANAGER_GRP',9);
                     END IF;
                     l_count := l_count + 1;
                     RAISE fnd_api.g_exc_error;
                end if;

           IF (l_debug = 1) THEN
              inv_log_util.trace('After update on MTI for INV_PRJ_ERR', 'INV_TXN_MANAGER_GRP',9);
           END IF;

            /*

            IF (SQL%FOUND) THEN
            l_count := l_count + 1;
            RAISE fnd_api.g_exc_error;
            END IF;

            */

         /*Fixe for bug#8819962
             Added validation for Negative transaction cost for
             issue and receipt transactions.
           */

           IF (l_debug = 1) THEN
           inv_log_util.trace('Before loaderrmsg INV_UNIT_COST_NEG','INV_TXN_MANAGER_GRP',9);
           END IF;

           /* validate Negative transaction cost */

                loaderrmsg('INV_UNIT_COST_NEG','INV_UNIT_COST_NEG');

                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                    SET LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY = p_userid,
                        LAST_UPDATE_LOGIN = p_loginid,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = substrb(l_error_code,1,240),
                        ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                WHERE ROWID = l_rowid
                    AND TRANSACTION_ACTION_ID IN ( 1,27 )
                    AND PROCESS_FLAG = 1
                    AND TRANSACTION_COST <0
                    and exists
                       (
                           SELECT organization_id
                           FROM mtl_parameters
                           WHERE organization_id = MTI.organization_id
                             and NVL(process_enabled_flag, 'N') ='N'
                       );

                if sql%notfound then
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Passed the Negative Txn cost Validation**', 'INV_TXN_MANAGER_GRP',9);
                     END IF;
                else
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Failed the Negative Txn cost Validation**', 'INV_TXN_MANAGER_GRP',9);
                     END IF;
                     l_count := l_count + 1;
                     RAISE fnd_api.g_exc_error;
                end if;

                IF (l_debug = 1) THEN
                   inv_log_util.trace('After update on MTI for INV_UNIT_COST_NEG','INV_TXN_MANAGER_GRP',9);
                END IF;


           IF (l_debug = 1) THEN
           inv_log_util.trace('Before loaderrmsg INV_PAORG_ERR','INV_TXN_MANAGER_GRP',9);
           END IF;

           /* validate expenditure org id */

                loaderrmsg('INV_PAORG_ERR','INV_PAORG_ERR');

                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                    SET LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY = p_userid,
                        LAST_UPDATE_LOGIN = p_loginid,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = substrb(l_error_code,1,240),
                        ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                WHERE ROWID = l_rowid
                    AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
                            (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
                    AND TRANSACTION_ACTION_ID IN (1, 27 )
                    AND PROCESS_FLAG = 1
                    AND EXISTS (
                            SELECT NULL
                            FROM MTL_TRANSACTION_TYPES MTTY
                            WHERE MTTY.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                    AND MTTY.TYPE_CLASS = 1 )
                    AND NOT EXISTS (
                    SELECT NULL
                    FROM PA_ORGANIZATIONS_EXPEND_V POE
                    WHERE POE.ORGANIZATION_ID = MTI.PA_EXPENDITURE_ORG_ID
                    AND TRUNC(SYSDATE) BETWEEN POE.DATE_FROM
                    AND NVL(POE.DATE_TO, TRUNC(SYSDATE)));

                if sql%notfound then
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Passed the exp org Validation**', 'INV_TXN_MANAGER_GRP',9);
                     END IF;
                else
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Failed the exp org Validation**', 'INV_TXN_MANAGER_GRP',9);
                     END IF;
                     l_count := l_count + 1;
                     RAISE fnd_api.g_exc_error;
                end if;

                IF (l_debug = 1) THEN
                   inv_log_util.trace('After update on MTI for INV_PAORG_ERR','INV_TXN_MANAGER_GRP',9);
                END IF;

        /*
                IF (SQL%ROWCOUNT > 0) THEN
                    l_count := l_count + 1;
                    RAISE fnd_api.g_exc_error;
                END IF;
        */

                --End   Fix 2505534

        l_flow_schedule_children := 0;


        IF (l_acttype = 2) THEN
            l_xorgid := l_orgid;
        END IF;

        IF ( (  l_srctype=INV_Globals.G_SourceType_SalesOrder OR
                l_srctype = INV_Globals.G_SourceType_Account OR
                l_srctype = INV_Globals.G_SourceType_AccountAlias OR
                l_srctype = INV_Globals.G_SourceType_IntOrder)
         AND (l_trxsrc is NULL) ) THEN
            IF ( NOT getsrcid(l_trxsrc, l_srctype, l_orgid, l_rowid)) THEN
                FND_MESSAGE.set_name('INV', 'INV_INT_SRCSEGCODE');
                l_error_code := FND_MESSAGE.get;

                errupdate(l_rowid,null);
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

        IF l_itemid IS NULL THEN
            IF (NOT getitemid(l_itemid, l_orgid, l_rowid)) THEN
                FND_MESSAGE.set_name('INV', 'INV_INT_ITMSEGCODE');
                l_error_code := FND_MESSAGE.get;

                errupdate(l_rowid,null);
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

         /* CFM Scrap Transactions */
        IF ((l_itmshpflag = 'N') OR l_acttype = 24 OR l_acttype = 30)  THEN
           BEGIN
                SELECT PRIMARY_UOM_CODE,1,1,1,2
                  INTO l_priuom,
                       l_locctrl,
                       l_lotctrl,
                       l_serctrl,
                       l_resloc
                  FROM MTL_SYSTEM_ITEMS
                 WHERE INVENTORY_ITEM_ID = l_itemid
                   AND ORGANIZATION_ID = l_orgid;

                 /* Bug 12589617: For these transactions serial details are not
                  * needed
                  */
                 IF (l_debug = 1) THEN
                   inv_log_util.trace('setting the serial_tagged to 1 for Scrap transactions','INV_TXN_MANAGER_GRP',9);
                 END IF;

                 serial_tagged := 1;

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  loaderrmsg('INV_INT_ITMCODE','INV-No item record');
                  errupdate(l_rowid,null);
                  l_count := l_count + 1;
                  --exit;
                  RAISE fnd_api.g_exc_error;
           END;

        ELSE
          BEGIN
            SELECT decode(P.STOCK_LOCATOR_CONTROL_CODE,4,
                          decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE,
                                 S.LOCATOR_TYPE),P.STOCK_LOCATOR_CONTROL_CODE),
                   PRIMARY_UOM_CODE,
                   LOT_CONTROL_CODE,
                   SERIAL_NUMBER_CONTROL_CODE,
                   RESTRICT_LOCATORS_CODE,
                   SHELF_LIFE_CODE,
                   SHELF_LIFE_DAYS,
                   P.LOT_NUMBER_UNIQUENESS
              INTO l_locctrl ,
                   l_priuom,
                   l_lotctrl,
                   l_serctrl,
                   l_resloc,
                   l_shlfcode,
                   l_shlfdays,
                   l_lotuniq
              FROM MTL_PARAMETERS P,
                   MTL_SECONDARY_INVENTORIES S,
                   MTL_SYSTEM_ITEMS I
             WHERE I.INVENTORY_ITEM_ID = l_itemid
               AND S.SECONDARY_INVENTORY_NAME = l_subinv
               AND P.ORGANIZATION_ID = l_orgid
               AND I.ORGANIZATION_ID = S.ORGANIZATION_ID
               AND P.ORGANIZATION_ID = S.ORGANIZATION_ID
               AND P.ORGANIZATION_ID = I.ORGANIZATION_ID;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                loaderrmsg('INV_INT_ITMCODE','INV-No item record');
                errupdate(l_rowid,null);
                l_count := l_count + 1;
                --exit;
                RAISE fnd_api.g_exc_error;
             END;
        END IF;


        IF ((l_locctrl = 1) OR l_acttype = 24) THEN
            l_loci := -1;
            l_locid := NULL; --Added for bug 3703053
        END IF;
        /*For Bug#5044059, added the following code to read the profilele value
          'INV_CREATE_LOC_AT' that indicates whether locators should be created
          in autonomous mode or not*/
        IF (g_create_loc_at is null) THEN
          SELECT Nvl(FND_PROFILE.Value('INV_CREATE_LOC_AT'), 2)
                 INTO g_create_loc_at
          FROM DUAL;
        END IF;

        IF (l_debug = 1) THEN
           inv_log_util.trace('g_create_loc_at : '||g_create_loc_at, 'INV_TXN_MANAGER_GRP', 9);
        END IF;


        IF ((l_loci = -1) AND (l_locctrl <> 1 AND l_acttype <> 24)) THEN
            IF (l_resloc = 1) THEN
                l_locctrl := 2;
                END IF;
            IF ( NOT getlocid(l_locid, l_orgid, l_subinv, l_rowid, l_locctrl)) THEN
                FND_MESSAGE.set_name('INV', 'INV_INT_LOCSEGCODE');
                l_error_exp := FND_MESSAGE.get; --bug6679112, error_code=>error_exp
                errupdate(l_rowid,null);
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;

            /* get the default locator status  */
                IF l_wms_installed  THEN
                    l_default_locator_status :=INV_MATERIAL_STATUS_PKG.get_default_locator_status(
                  l_orgid, l_subinv);
                  ELSE
                     l_default_locator_status := 1;
                      END IF;

           /*Bug#5044059, if the profile 'INV_CREATE_LOC_AT' is set to 'YES',
             update Locators in autonomous mode*/
            IF (g_create_loc_at = 1) THEN
               update_mil( p_userid
                         , p_loginid
                         , p_applid
                         , p_progid
                         , l_reqstid
                         , l_subinv
                         , l_default_locator_status
                         , l_orgid
                         , l_locid);
            /* Added one more parameter l_plocid for Bug# 7323175 to update_mil() for the physical locator */

            ELSE
              UPDATE MTL_ITEM_LOCATIONS
              SET LAST_UPDATE_DATE = SYSDATE,
                  LAST_UPDATED_BY = p_userid,
                  LAST_UPDATE_LOGIN = p_loginid,
                  PROGRAM_APPLICATION_ID = p_applid,
                  PROGRAM_ID = p_progid,
                  PROGRAM_UPDATE_DATE = SYSDATE,
                  REQUEST_ID = l_reqstid,
                  SUBINVENTORY_CODE = l_subinv,
                  STATUS_ID = l_default_locator_status
                  /* Start: Fix for Bug# 7323175: Stamping PHYSICAL_LOCATION_ID with the physical locator for both
                     physical and logical locators for Project enabled Orgs. For the case of Non project enabled orgs
                     p_plocid would be null */
                  --PHYSICAL_LOCATION_ID = l_plocid
                  /* End: Fix for Bug# 7323175 */
               WHERE ORGANIZATION_ID = l_orgid
                  /* Start: Fix for Bug# 7323175: Updating the physical locator as well in mil */
                  AND INVENTORY_LOCATION_ID = l_locid
                  --AND INVENTORY_LOCATION_ID IN (l_locid,l_plocid)
                  /* End: Fix for Bug# 7323175 */
                  AND SUBINVENTORY_CODE is NULL;

            END IF;

            IF l_locid = -2 THEN
                l_loci := -1;
            END IF;

           BEGIN
                SELECT DECODE(NVL(PROJECT_REFERENCE_ENABLED, 2),1,1,0)
                INTO l_project_ref_enabled
                FROM MTL_PARAMETERS
                WHERE ORGANIZATION_ID = l_orgid ;
		EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_project_ref_enabled := 0;
            END;

	         IF l_project_ref_enabled = 1 THEN

		 v_result  := inv_projectlocator_pub.check_project_references(
		        arg_organization_id          => l_orgid
		      , arg_locator_id               => l_locid
		      , arg_validation_mode          => v_mode
		      , arg_required_flag            => v_required_flag
		      , arg_project_id               => v_project_id
		      , arg_task_id                  => v_task_id
		      );

		    IF (v_result = FALSE) THEN
	               l_error_exp := FND_MESSAGE.get;
	               FND_MESSAGE.set_name('INV', 'INV_INT_XLOCCODE');
	               l_error_code := FND_MESSAGE.get;
		   END IF;

	          END IF;

        END IF;

        /*------------------------------------------------------------------------+
          | Now check whether locator is valid under project
          | mfg. constraints. Validate newly created locator ids and
          | ids which are populated into the table.
          +------------------------------------------------------------------------*/

        -- Bug #6721912, fetching FLOW_SCHEDULE, SCHEDULED_FLAG from MTI
        --   So that validate_loc_for_project is called with right parameters
        --   In future this select statement should be merged in cursor AA1.
        /*------------------------------------------------------+
        | get flow schedule control variables
        +------------------------------------------------------*/
        IF l_srctype = 5 THEN
          BEGIN
            SELECT DECODE(UPPER(NVL(FLOW_SCHEDULE,'N')), 'Y', 1, 0), NVL(SCHEDULED_FLAG, 0)
              INTO tev_flow_schedule, tev_scheduled_flag
              FROM MTL_TRANSACTIONS_INTERFACE
             WHERE ROWID = l_rowid;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              tev_flow_schedule := 0;
              tev_scheduled_flag := 0;
          END;

          IF (l_debug = 1) THEN
            inv_log_util.trace('flow_schedule = '|| tev_flow_schedule || ', scheduled_flag = ' || tev_scheduled_flag,'INV_TXN_MANAGER_GRP', 9);
          END IF;
        END IF;


        IF ( l_loci <> -1 AND (l_locctrl <>1 AND l_acttype <>24) ) THEN
            IF ( NOT validate_loc_for_project(l_locid, l_orgid, l_srctype,
                                           l_acttype, l_trxsrc, tev_flow_schedule, tev_scheduled_flag) ) THEN

                    l_error_exp := FND_MESSAGE.get;

                    FND_MESSAGE.set_name('INV', 'INV_INT_LOCSEGCODE');
                l_error_code := FND_MESSAGE.get;

                errupdate(l_rowid,null);
                l_count := l_count + 1;
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;

        END IF;

        IF ((l_acttype = 2) OR (l_acttype=3)) THEN
            IF (l_xsubinv IS NULL) THEN
                IF (l_srctype = 8) THEN
                    BEGIN
                        SELECT SUBINVENTORY_CODE
                          INTO l_xsubinv
                          FROM MTL_ITEM_SUB_DEFAULTS
                         WHERE INVENTORY_ITEM_ID = l_itemid
                           AND ORGANIZATION_ID = l_xorgid
                           AND DEFAULT_TYPE = 2;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           loaderrmsg('INV_INT_XSUBCODE','INV_DEFAULT_SUB');
                           errupdate(l_rowid,null);
                           l_count := l_count + 1;
                           --exit;
                           RAISE fnd_api.g_exc_error;
                    END;
                ELSE
                    loaderrmsg('INV_INT_XSUBCODE','INV_INT_XSUBEXP');
                    errupdate(l_rowid,null);
                    l_count := l_count + 1;
                    --exit;
                    RAISE fnd_api.g_exc_error;
                END IF;
            END IF;


            BEGIN
               SELECT decode(P.STOCK_LOCATOR_CONTROL_CODE,4,
                         decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE,
                                S.LOCATOR_TYPE),P.STOCK_LOCATOR_CONTROL_CODE),
                      LOT_CONTROL_CODE,
                      SERIAL_NUMBER_CONTROL_CODE,
                      RESTRICT_LOCATORS_CODE
                 INTO l_xlocctrl,
                      l_xlotctrl,
                      l_xserctrl,
                      l_xresloc
                 FROM MTL_PARAMETERS P,
                      MTL_SECONDARY_INVENTORIES S,
                      MTL_SYSTEM_ITEMS I
                WHERE I.INVENTORY_ITEM_ID = l_itemid
                  AND S.SECONDARY_INVENTORY_NAME = l_xsubinv
                  AND P.ORGANIZATION_ID = l_xorgid
                  AND I.ORGANIZATION_ID = S.ORGANIZATION_ID
                  AND P.ORGANIZATION_ID = S.ORGANIZATION_ID
                  AND P.ORGANIZATION_ID = I.ORGANIZATION_ID;

            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     loaderrmsg('INV_INT_ITMCODE','INV-No item record');
                     errupdate(l_rowid,null);
                     l_count := l_count + 1;
                    --exit;
                     RAISE fnd_api.g_exc_error;
            END;

            --IF (l_xlocctrl IS NULL) THEN     bug2460745

            /* Bug #2493941 - Call validation logic for destination locator
             * (getxlocid) only when locator control code != 1 and xferlocid is NULL
             */
            -- Begin changes for bug 3703053
             IF l_xlocctrl = 1 THEN
               l_xlocid := NULL;
             END IF;
            -- End changes for bug 3703053
            IF ((l_xlocctrl <> 1) AND (l_xlocid IS NULL)) THEN
                IF (l_xresloc = 1) THEN
                  l_xlocctrl := 2;
                END IF;

                IF (l_srctype = 8) THEN
                   BEGIN
                     SELECT LOCATOR_ID
                       INTO l_xlocid
                       FROM MTL_ITEM_LOC_DEFAULTS MTLD,
                            MTL_ITEM_LOCATIONS MIL
                      WHERE MTLD.LOCATOR_ID=MIL.INVENTORY_LOCATION_ID
                        AND MTLD.ORGANIZATION_ID=MIL.ORGANIZATION_ID
                        AND MTLD.INVENTORY_ITEM_ID = l_itemid
                        AND MTLD.ORGANIZATION_ID = l_xorgid
                        AND MTLD.SUBINVENTORY_CODE = l_xsubinv
                        AND MTLD.DEFAULT_TYPE = 2
                        AND NVL(MIL.DISABLE_DATE,SYSDATE+1) > SYSDATE;

                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                         loaderrmsg('INV_INT_XLOCCODE','INV_DEFAULT_LOC');
                         errupdate(l_rowid,null);
                         l_count := l_count + 1;
                         --exit;
                         RAISE fnd_api.g_exc_error;
                   END;

/* For srctype = 8 i.e internal order, the below code is added to append
   project and task from the requisition to a locator that is selected
   from locator defaults. If the transfer bet orgs is 'direct', the shipment
   transaction itself creates the recipt transaction and while doing so
   it picks up the default locator from the locator defaults.
*/
               IF (l_req_line_id IS NOT NULL) THEN
                   INV_PROJECT.Get_project_loc_for_prj_Req(
                                    x_return_status,
                                    l_xlocid,
                                    l_xorgid,
                                    l_req_line_id);

                    IF (x_return_status <> 'S') THEN
                        l_error_exp := FND_MESSAGE.get;
                        FND_MESSAGE.set_name('INV', 'INV_INT_XLOCCODE');
                        l_error_code := FND_MESSAGE.get;

                        errupdate(l_rowid,null);
                        l_count := l_count + 1;
                        --exit;
                        RAISE fnd_api.g_exc_error;
                    END IF;
                END IF;
            ELSE
                -- Bug 5011566 setting transfer org as org context
                IF (l_srctype in (8, 13)) and (l_acttype = 3) and (l_xorgid is not null) THEN
                   IF (NOT setorgclientinfo(l_xorgid)) THEN
                       RAISE fnd_api.g_exc_error;
                   END IF;
                   fnd_profile.put('MFG_ORGANIZATION_ID',l_xorgid);
                END IF;

                IF (NOT getxlocid(l_xlocid, l_xorgid, l_xsubinv, l_rowid,
                               l_xlocctrl)) THEN
                        FND_MESSAGE.set_name('INV', 'INV_INT_XLOCCODE');
                        l_error_code := FND_MESSAGE.get;
                        --exit;
                        RAISE fnd_api.g_exc_error;
                END IF;

                   /* get the default locator status  */
                IF l_wms_installed THEN
                   l_default_locator_status :=INV_MATERIAL_STATUS_PKG.get_default_locator_status(
                    l_xorgid, l_xsubinv);
                 ELSE
                   l_default_locator_status := 1;
                 END IF;


                 /*Bug#5044059, if the profile 'INV_CREATE_LOC_AT' is set to 'YES',
                  update Locators in autonomous mode*/
                 IF (g_create_loc_at = 1) THEN
                   update_mil( p_userid
                             , p_loginid
                             , p_applid
                             , p_progid
                             , l_reqstid
                             , l_xsubinv
                             , l_default_locator_status
                             , l_xorgid
                             , l_xlocid);
                  /* Addded a parameter l_xplocid for Bug# 7323175 in update_mil */
                 ELSE
                   UPDATE MTL_ITEM_LOCATIONS
                   SET LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = p_userid,
                       LAST_UPDATE_LOGIN = p_loginid,
                       PROGRAM_APPLICATION_ID = p_applid,
                       PROGRAM_ID = p_progid,
                       PROGRAM_UPDATE_DATE = SYSDATE,
                       REQUEST_ID = l_reqstid,
                       SUBINVENTORY_CODE = l_xsubinv,
                       STATUS_ID = l_default_locator_status
                       /* Start: Fix for Bug# 7323175: Stamping PHYSICAL_LOCATION_ID with the physical locator for both
                        physical and logical locators for Project enabled Orgs. For the case of Non project enabled orgs
                        l_xplocid would be null */
                        --PHYSICAL_LOCATION_ID = l_xplocid
                       /* End: Fix for Bug# 7323175 */
                   WHERE ORGANIZATION_ID = l_xorgid
                   /* Start: Fix for Bug# 7323175: Updating the physical locator as well in mil */
                 AND INVENTORY_LOCATION_ID = l_xlocid
                  --AND INVENTORY_LOCATION_ID IN (l_xlocid,l_xplocid)
                  /* End: Fix for Bug# 7323175 */
                  AND SUBINVENTORY_CODE is NULL;
                 END IF;

		  BEGIN
                      SELECT DECODE(NVL(PROJECT_REFERENCE_ENABLED, 2),1,1,0)
                      INTO l_project_ref_enabled
                      FROM MTL_PARAMETERS
                      WHERE ORGANIZATION_ID = l_xorgid ;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       l_project_ref_enabled := 0;
                  END;

                  IF l_project_ref_enabled = 1 THEN
		         v_result  := inv_projectlocator_pub.check_project_references(
				        arg_organization_id          => l_xorgid
				      , arg_locator_id               => l_xlocid
				      , arg_validation_mode          => v_mode
				      , arg_required_flag            => v_required_flag
				      , arg_project_id               => v_project_id
				      , arg_task_id                  => v_task_id
				      );
			IF (v_result = FALSE) THEN
			        l_error_exp := FND_MESSAGE.get;
			        FND_MESSAGE.set_name('INV', 'INV_INT_XLOCCODE');
			        l_error_code := FND_MESSAGE.get;
			END IF;

                  END IF;
                -- Bug 5011566 re-setting org as org context
                IF (l_srctype in (8, 13)) and (l_acttype = 3) and (l_xorgid is not null) then
                   IF (NOT setorgclientinfo(l_orgid)) THEN
                       RAISE fnd_api.g_exc_error;
                   END IF;
                   fnd_profile.put('MFG_ORGANIZATION_ID',l_orgid);
                END IF;
                END IF;
        END IF;
     END IF;

         /*------------------------------------------------------------------------+
          | Now check whether locator is valid under project
          | mfg. constraints. Validate newly created locator ids and
          | ids which are populated into the table.
          +------------------------------------------------------------------------*/
        IF ( (l_xlocid IS NOT NULL) AND (l_xlocctrl <> 1) AND (l_acttype = 2 OR l_acttype = 3)) THEN
            IF ( NOT validate_loc_for_project(l_xlocid, l_xorgid, l_srctype,
                                           l_acttype, l_trxsrc, tev_flow_schedule, tev_scheduled_flag) ) THEN

                    l_error_exp := FND_MESSAGE.get;

                    FND_MESSAGE.set_name('INV', 'INV_INT_LOCSEGCODE');
                l_error_code := FND_MESSAGE.get;

                errupdate(l_rowid,null);
                l_count := l_count + 1;
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;

        END IF;


        BEGIN
           IF (l_srctype = 5) then
              l_priqty := inv_convert.inv_um_convert(l_itemid,6,l_trxqty,
                                                     l_trxuom,l_priuom,'','');
            ELSE
              l_priqty := inv_convert.inv_um_convert(l_itemid,5,l_trxqty,
                                                     l_trxuom,l_priuom,'','');
           END IF;
        EXCEPTION
           WHEN OTHERS THEN
        /*IF (NOT UomConvert(l_itemid,0,l_trxuom, '',
                        l_priuom,  '', l_trxqty,
                        l_priqty,  0)) THEN */
                l_error_exp := FND_MESSAGE.get;

                FND_MESSAGE.set_name('INV', 'INV_INT_UOMSEGCODE');
            l_error_code := FND_MESSAGE.get;

            errupdate(l_rowid,null);
            l_count := l_count + 1;
            --exit;
            RAISE fnd_api.g_exc_error;
        END;

        /* Borrow Payback */
        IF(l_acttype = 2) THEN
            l_result := PJM_BORROW_PAYBACK.validate_trx(l_trxtype,l_acttype,
                                             l_orgid,l_subinv,l_locid,
                                             l_xsubinv,l_xlocid,
                                             l_itemid,l_revision,
                                             l_priqty,l_trxdate, l_scheduled_payback_date,l_error_code);

            IF(l_result = 1) THEN

                l_error_exp := FND_MESSAGE.get;

                errupdate(l_rowid,null);
                l_count := l_count + 1;
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;
        --prOR := 0;
        IF (l_srctype <> 14)  THEN /* PCST */

           IF l_trxdate <= sysdate THEN
               l_tnum := 1;
           ELSE
                loaderrmsg('INV_INT_TDATECODE','INV_INT_TDATEEX');

                errupdate(l_rowid,null);
                l_count := l_count + 1;
                --exit;
                RAISE fnd_api.g_exc_error;
           END IF;

         l_prdid := get_open_period(l_orgid,l_trxdate,0);


          IF (l_prdid = -1 OR l_prdid = 0) THEN
              FND_MESSAGE.set_name('INV', 'INV_INT_PRDCODE');
              l_error_code := FND_MESSAGE.get;
              FND_MESSAGE.set_name('INV', 'INV_NO_OPEN_PERIOD');
                  /*END IF;*/

              l_error_exp := FND_MESSAGE.get;

              errupdate(l_rowid,null);
              l_count := l_count + 1;
              --exit;
              RAISE fnd_api.g_exc_error;
          END IF;
          /*Bug#5205455. Validation of the acc period for to_org */
          IF ( l_acttype IN ( 3, 21) OR
             (l_srctype = 8 AND l_acttype IN (1, 2)) ) THEN
            IF l_acttype IN ( 1, 2, 21) THEN
              IF (l_debug = 1) THEN
                inv_log_util.trace('l_acttype: '||l_acttype||' l_srctype: '||l_srctype, 'INV_TXN_MANAGER_GRP', 9);
              END IF;

              BEGIN
                IF (l_debug = 1) THEN
                  inv_log_util.trace('Getting the FOB Point between the orgs, '||l_orgid||' and '||l_xorgid, 'INV_TXN_MANAGER_GRP', 9);
                END IF;

                SELECT fob_point
                INTO l_fob_point
                FROM mtl_interorg_parameters
                WHERE from_organization_id = l_orgid
                  AND to_organization_id = l_xorgid;

                IF (l_debug = 1) THEN
                  inv_log_util.trace('FOB Point is: '||l_fob_point, 'INV_TXN_MANAGER_GRP', 9);
                END IF;

              EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  inv_log_util.trace('Exception while finding the FOB Point.', 'INV_TXN_MANAGER_GRP', 9);
                END IF;
                l_fob_point := NULL;
              END;
              IF l_fob_point = 1 THEN
                l_validate_xfer_org := TRUE;
              ELSIF (l_fob_point = 2) THEN
                l_validate_xfer_org := FALSE;
              END IF;
            ELSE
              l_validate_xfer_org := TRUE;
            END IF;
            IF (l_validate_xfer_org) THEN
              IF (l_debug = 1) THEN
                inv_log_util.trace('l_validate_xfer_org is TRUE', 'INV_TXN_MANAGER_GRP', 9);
              END IF;
              IF ( get_open_period(l_xorgid,l_trxdate,0) IN (-1, 0)) THEN
                FND_MESSAGE.set_name('INV', 'INV_INT_PRDCODE');
                l_error_code := FND_MESSAGE.get;
                FND_MESSAGE.set_name('INV', 'INV_NO_OPEN_PERIOD_TOORG');
                l_error_exp := FND_MESSAGE.get;
                errupdate(l_rowid,null);
                l_count := l_count + 1;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END IF;



        ELSE
          l_prdid := 0;  /* Bug 4122107 */
        END IF;

        /* Bug# 6271039, For average cost update and layer cost update, validate rows in
         *    MTI for material account, material overhead account, resource account,
         *    outside processing account, overhead account. */

        IF ( l_acttype = 24 AND ((l_srctype = INV_Globals.G_SourceType_Inventory) OR (l_srctype = 15)) AND ( l_avg_cost_update = 2 ) )
        THEN

             /*-----------------------------------------------------------+
              | Validate material account
             +-----------------------------------------------------------*/

             IF (l_validate_full) THEN --J-dev
                FND_MESSAGE.set_name('INV','INV_MATERIAL_ACCOUNT');
                l_account := FND_MESSAGE.get ;

                fnd_message.set_name('INV', 'INV_INT_ACCCODE');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_code := fnd_message.get;

                fnd_message.set_name('INV', 'INV_INT_ACCEXP');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_exp := fnd_message.get;

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                        SET LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATED_BY = p_userid,
                            LAST_UPDATE_LOGIN = p_loginid,
                            PROGRAM_UPDATE_DATE = SYSDATE,
                            PROCESS_FLAG = 3,
                            LOCK_FLAG = 2,
                            ERROR_CODE = substrb(l_error_code,1,240),
                            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                      WHERE TRANSACTION_HEADER_ID = l_header_id
                        AND PROCESS_FLAG = 1
                        AND MATERIAL_ACCOUNT IS NOT NULL
                        AND NOT EXISTS (
                            SELECT NULL
                            FROM GL_CODE_COMBINATIONS GCC
                            WHERE GCC.CODE_COMBINATION_ID = MTI.MATERIAL_ACCOUNT
                            AND GCC.CHART_OF_ACCOUNTS_ID
                                                 = (SELECT CHART_OF_ACCOUNTS_ID
                                                    FROM ORG_ORGANIZATION_DEFINITIONS OOD
                                                    WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
                           AND GCC.ENABLED_FLAG = 'Y'
                           AND trunc(NVL(GCC.START_DATE_ACTIVE, mti.transaction_date - 1)) <=  trunc(mti.transaction_date)
                           AND trunc(NVL(GCC.END_DATE_ACTIVE, mti.transaction_date + 1))   >=  trunc(mti.transaction_date));

                      l_count := SQL%ROWCOUNT;
                      IF (l_debug = 1) THEN
                         inv_log_util.trace('Validating material account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
                      END IF;

            END IF; --J-dev


            /*-----------------------------------------------------------+
              | Validate material overhead account
             +-----------------------------------------------------------*/

             IF (l_validate_full) THEN --J-dev
                FND_MESSAGE.set_name('INV','INV_MAT_OVRHD_ACCOUNT');
                l_account := FND_MESSAGE.get ;

                fnd_message.set_name('INV', 'INV_INT_ACCCODE');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_code := fnd_message.get;

                fnd_message.set_name('INV', 'INV_INT_ACCEXP');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_exp := fnd_message.get;

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                        SET LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATED_BY = p_userid,
                            LAST_UPDATE_LOGIN = p_loginid,
                            PROGRAM_UPDATE_DATE = SYSDATE,
                            PROCESS_FLAG = 3,
                            LOCK_FLAG = 2,
                            ERROR_CODE = substrb(l_error_code,1,240),
                            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                      WHERE TRANSACTION_HEADER_ID = l_header_id
                        AND PROCESS_FLAG = 1
                        AND MATERIAL_OVERHEAD_ACCOUNT IS NOT NULL
                        AND NOT EXISTS (
                            SELECT NULL
                            FROM GL_CODE_COMBINATIONS GCC
                            WHERE GCC.CODE_COMBINATION_ID = MTI.MATERIAL_OVERHEAD_ACCOUNT
                            AND GCC.CHART_OF_ACCOUNTS_ID
                                                 = (SELECT CHART_OF_ACCOUNTS_ID
                                                    FROM ORG_ORGANIZATION_DEFINITIONS OOD
                                                    WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
                           AND GCC.ENABLED_FLAG = 'Y'
                           AND trunc(NVL(GCC.START_DATE_ACTIVE, mti.transaction_date - 1)) <=  trunc(mti.transaction_date)
                           AND trunc(NVL(GCC.END_DATE_ACTIVE, mti.transaction_date + 1))   >=  trunc(mti.transaction_date));

                      l_count := SQL%ROWCOUNT;
                      IF (l_debug = 1) THEN
                         inv_log_util.trace('Validating material overhead account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
                      END IF;

            END IF; --J-dev

            /*-----------------------------------------------------------+
              | Validate resource account
             +-----------------------------------------------------------*/

             IF (l_validate_full) THEN --J-dev
                FND_MESSAGE.set_name('INV','INV_RESOURCE_ACCOUNT');
                l_account := FND_MESSAGE.get ;

                fnd_message.set_name('INV', 'INV_INT_ACCCODE');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_code := fnd_message.get;

                fnd_message.set_name('INV', 'INV_INT_ACCEXP');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_exp := fnd_message.get;

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                        SET LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATED_BY = p_userid,
                            LAST_UPDATE_LOGIN = p_loginid,
                            PROGRAM_UPDATE_DATE = SYSDATE,
                            PROCESS_FLAG = 3,
                            LOCK_FLAG = 2,
                            ERROR_CODE = substrb(l_error_code,1,240),
                            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                      WHERE TRANSACTION_HEADER_ID = l_header_id
                        AND PROCESS_FLAG = 1
                        AND RESOURCE_ACCOUNT IS NOT NULL
                        AND NOT EXISTS (
                            SELECT NULL
                            FROM GL_CODE_COMBINATIONS GCC
                            WHERE GCC.CODE_COMBINATION_ID = MTI.RESOURCE_ACCOUNT
                            AND GCC.CHART_OF_ACCOUNTS_ID
                                                 = (SELECT CHART_OF_ACCOUNTS_ID
                                                    FROM ORG_ORGANIZATION_DEFINITIONS OOD
                                                    WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
                           AND GCC.ENABLED_FLAG = 'Y'
                           AND trunc(NVL(GCC.START_DATE_ACTIVE, mti.transaction_date - 1)) <=  trunc(mti.transaction_date)
                           AND trunc(NVL(GCC.END_DATE_ACTIVE, mti.transaction_date + 1))   >=  trunc(mti.transaction_date));

                      l_count := SQL%ROWCOUNT;
                      IF (l_debug = 1) THEN
                         inv_log_util.trace('Validating resource account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
                      END IF;

            END IF; --J-dev

            /*-----------------------------------------------------------+
              | Validate outside processing account
             +-----------------------------------------------------------*/

             IF (l_validate_full) THEN --J-dev
                FND_MESSAGE.set_name('INV','INV_OUTSIDE_PROC_ACCOUNT');
                l_account := FND_MESSAGE.get ;

                fnd_message.set_name('INV', 'INV_INT_ACCCODE');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_code := fnd_message.get;

                fnd_message.set_name('INV', 'INV_INT_ACCEXP');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_exp := fnd_message.get;

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                        SET LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATED_BY = p_userid,
                            LAST_UPDATE_LOGIN = p_loginid,
                            PROGRAM_UPDATE_DATE = SYSDATE,
                            PROCESS_FLAG = 3,
                            LOCK_FLAG = 2,
                            ERROR_CODE = substrb(l_error_code,1,240),
                            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                      WHERE TRANSACTION_HEADER_ID = l_header_id
                        AND PROCESS_FLAG = 1
                        AND OUTSIDE_PROCESSING_ACCOUNT IS NOT NULL
                        AND NOT EXISTS (
                            SELECT NULL
                            FROM GL_CODE_COMBINATIONS GCC
                            WHERE GCC.CODE_COMBINATION_ID = MTI.OUTSIDE_PROCESSING_ACCOUNT
                            AND GCC.CHART_OF_ACCOUNTS_ID
                                                 = (SELECT CHART_OF_ACCOUNTS_ID
                                                    FROM ORG_ORGANIZATION_DEFINITIONS OOD
                                                    WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
                           AND GCC.ENABLED_FLAG = 'Y'
                           AND trunc(NVL(GCC.START_DATE_ACTIVE, mti.transaction_date - 1)) <=  trunc(mti.transaction_date)
                           AND trunc(NVL(GCC.END_DATE_ACTIVE, mti.transaction_date + 1))   >=  trunc(mti.transaction_date));

                      l_count := SQL%ROWCOUNT;
                      IF (l_debug = 1) THEN
                         inv_log_util.trace('Validating outside processing account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
                      END IF;

            END IF; --J-dev

            /*-----------------------------------------------------------+
              | Validate overhead account
             +-----------------------------------------------------------*/

             IF (l_validate_full) THEN --J-dev
                FND_MESSAGE.set_name('INV','INV_OVERHEAD_ACCOUNT');
                l_account := FND_MESSAGE.get ;

                fnd_message.set_name('INV', 'INV_INT_ACCCODE');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_code := fnd_message.get;

                fnd_message.set_name('INV', 'INV_INT_ACCEXP');
                fnd_message.set_token('ACCOUNT',l_account);
                l_error_exp := fnd_message.get;

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                        SET LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATED_BY = p_userid,
                            LAST_UPDATE_LOGIN = p_loginid,
                            PROGRAM_UPDATE_DATE = SYSDATE,
                            PROCESS_FLAG = 3,
                            LOCK_FLAG = 2,
                            ERROR_CODE = substrb(l_error_code,1,240),
                            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                      WHERE TRANSACTION_HEADER_ID = l_header_id
                        AND PROCESS_FLAG = 1
                        AND OVERHEAD_ACCOUNT IS NOT NULL
                        AND NOT EXISTS (
                            SELECT NULL
                            FROM GL_CODE_COMBINATIONS GCC
                            WHERE GCC.CODE_COMBINATION_ID = MTI.OVERHEAD_ACCOUNT
                            AND GCC.CHART_OF_ACCOUNTS_ID
                                                 = (SELECT CHART_OF_ACCOUNTS_ID
                                                    FROM ORG_ORGANIZATION_DEFINITIONS OOD
                                                    WHERE OOD.ORGANIZATION_ID = MTI.ORGANIZATION_ID)
                           AND GCC.ENABLED_FLAG = 'Y'
                           AND trunc(NVL(GCC.START_DATE_ACTIVE, mti.transaction_date - 1)) <=  trunc(mti.transaction_date)
                           AND trunc(NVL(GCC.END_DATE_ACTIVE, mti.transaction_date + 1))   >=  trunc(mti.transaction_date));

                      l_count := SQL%ROWCOUNT;
                      IF (l_debug = 1) THEN
                         inv_log_util.trace('Validating overhead account ' || l_count || ' failed', 'INV_TXN_MANAGER_GRP', 9);
                      END IF;

            END IF; --J-dev


        END IF; /* l_acttype = 24 AND (l_srctype = 14 or  l_srctype = 15*/
        /* End of Bug# 6271039 */

        /* for average cost update and layer cost update, validate rows in */
        /* mtl_txn_cost_det_interface table , if R10 avg cost profile is set */


        IF ( l_acttype = 24 AND ((l_srctype = INV_Globals.G_SourceType_Inventory)
                                 OR (l_srctype = 15)) ) THEN
            IF ( l_avg_cost_update = 2 ) THEN

                /* should we check also if interface id is not null and
                   generate an id if it is null before calling validate */
                CSTPACIT.cost_det_validate(l_intid,
                                           l_orgid,
                                           l_itemid,
                                           l_new_avg_cst,
                                           l_per_chng,
                                           l_val_chng,
                                           l_mat_accnt,
                                           l_mat_ovhd_accnt,
                                           l_res_accnt,
                                           l_osp_accnt,
                                           l_ovhd_accnt,
                                           l_error_num,
                                           l_error_code,
                                           l_error_exp);
                IF ( l_error_exp IS NOT NULL) THEN
                    errupdate(l_rowid,null);
                    l_count := l_count + 1;
                    --exit;
                    RAISE fnd_api.g_exc_error;
                END IF;
            END IF;
        END IF;

        IF ( l_acttype = 24 AND l_srctype = 14 ) THEN    /* PCST */
           CSTPPCIT.periodic_cost_validate(
                              l_org_cost_group_id,
                              l_cost_type_id,
                              l_trxdate,--Bug #4156979 Removed the call to fnd_date.canonical_to_date
                              l_intid,
                              l_orgid,
                              l_itemid,
                              l_new_avg_cst,
                              l_per_chng,
                              l_val_chng,
                              l_mat_accnt,
                              l_mat_ovhd_accnt,
                              l_res_accnt,
                              l_osp_accnt,
                              l_ovhd_accnt,
                              l_error_num,
                              l_error_code,
                              l_error_exp) ;
            IF l_error_exp IS NOT NULL  THEN
                errupdate(l_rowid,null);
                l_count := l_count + 1;
                --exit;
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

        /* Do this snapshot moves for non-CFM WIP completions,returns,
        /*scraps */
        /* In J WIP will do this. move snapshot.*/
        IF ( wip_constants.DMF_PATCHSET_LEVEL < wip_constants.DMF_PATCHSET_J_VALUE) THEN --J-dev
           IF ( ( (l_acttype =30)
                  OR (l_acttype =31)
                  OR (l_acttype =32) )
                AND l_srctype = 5 AND
                tev_flow_schedule = 0) THEN

              SELECT PRIMARY_COST_METHOD
                INTO   l_primary_cost_method
                FROM   MTL_PARAMETERS
                WHERE  ORGANIZATION_ID = l_orgid ;

              IF ( l_avg_cost_update = 2 AND  (l_primary_cost_method = 2   OR
                                               l_primary_cost_method = 5     OR
                                               l_primary_cost_method = 6 )  )
              THEN
                 l_cst_temp := CSTPACMS.validate_move_snap_to_temp
                   (l_intid,
                    l_intid,
                    1, -- for inventory l_interface_table=1
                    l_priqty,
                    l_error_num,
                    l_error_code,
                    l_error_exp) ;
                    IF l_error_exp IS NOT NULL THEN
                        errupdate(l_rowid,null);
                        l_count := l_count + 1;
                        --exit;
                        RAISE fnd_api.g_exc_error;
                    END IF;
              END IF;
           END IF;
        END IF; --J-dev

        -- hjogleka
        -- Bug #5497519, Added code to validate lot quantity and serial count
        --   against quantities in MTI/MLTI.
        -- Bug #5566760, added ABS() while comparing the quantities.
        --Bug #5614139
        --Do not validate lot/serial quantity for lot split, merge and translate
        --The inv_lot_trx_validations_pub API would already have done it by the
        --time control comes here
        IF (l_validate_full AND l_acttype NOT IN (
               INV_GLOBALS.G_ACTION_COSTUPDATE
             , INV_GLOBALS.G_ACTION_INV_LOT_SPLIT
             , INV_GLOBALS.G_ACTION_INV_LOT_MERGE
             , INV_GLOBALS.G_ACTION_INV_LOT_TRANSLATE)
           ) THEN

          --Serial Tagging

          /*
          IF (l_lotctrl = 2 AND
                 (l_serctrl = 2 OR l_serctrl = 5 OR
                   (l_serctrl = 6 AND l_srctype = 2 AND l_acttype = 1) OR
                   (l_serctrl = 6 AND l_srctype = 16 AND l_acttype = 1) OR
                   (l_serctrl = 6 AND l_srctype = 8 AND l_acttype IN (3,21)) OR
                   --serial tagging
                   (l_serctrl = 6 AND l_trxtype in (93,94,35,43) )
                 )
          */
          IF (l_lotctrl = 2 AND
              serial_tagged = 2
              ) THEN
               -- lot and serial controlled item
               -- validate lot quantities and mmtt quantity.
               BEGIN
                  IF (l_debug = 1) THEN
                     inv_log_util.trace('validating lot/serial quantities','INV_TXN_MANAGER_GRP', 9);
                  END IF;

                  SELECT NVL(SUM(ABS(NVL(mtli.transaction_quantity,0))), 0)
                    INTO l_lot_ser_qty
                    FROM mtl_transaction_lots_interface mtli
                    WHERE mtli.transaction_interface_id =l_intid
                      AND ABS(nvl(mtli.primary_quantity, inv_convert.inv_um_convert
                          (l_itemid,5,mtli.transaction_quantity,l_trxuom,l_priuom,'','')))
                           = (SELECT SUM(get_serial_diff_wrp
                                      (msni.fm_serial_number,nvl(msni.to_serial_number,msni.fm_serial_number)))
                                FROM mtl_serial_numbers_interface msni
                                WHERE msni.transaction_interface_id
                                                      = mtli.serial_transaction_temp_id);
               EXCEPTION
                  WHEN others THEN
                     IF (l_debug = 1) THEN
                        inv_log_util.trace('Ex.. while checking lot/serial quantities','INV_TXN_MANAGER_GRP', 9);
                     END IF;
                     l_lot_ser_qty := 0;
               END;

               IF (ABS(l_trxqty) <> l_lot_ser_qty) THEN
                  IF (l_debug = 1) THEN
                     inv_log_util.trace('mismatch in lot/serial quantities','INV_TXN_MANAGER_GRP', 9);
                  END IF;
                  loaderrmsg('INV_INT_LOTCODE','INV_INVLTPU_LOTTRX_QTY');
                  errupdate(l_rowid,null);
                  l_count := l_count + 1;
                  RAISE fnd_api.g_exc_error;
               ELSE
                  IF (l_debug = 1) THEN
                     inv_log_util.trace('no mismatch in lot/serial quantities','INV_TXN_MANAGER_GRP', 9);
                  END IF;
               END IF;

        --Serial Tagging
        /*
        ELSIF ( l_serctrl = 2 OR l_serctrl = 5 OR
               (l_serctrl = 6 AND l_srctype = 2 AND l_acttype = 1) OR
               (l_serctrl = 6 AND l_srctype = 16 AND l_acttype = 1) OR
               (l_serctrl = 6 AND l_srctype = 8 AND l_acttype IN (3,21)) OR
               --serial tagging
               (l_serctrl = 6 AND l_trxtype in (93,94,35,43) )
        */
        ELSIF ( serial_tagged = 2
              ) THEN

              -- serial controlled item
              -- validate serial quantities only.
              BEGIN
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('validating lot/serial quantities','INV_TXN_MANAGER_GRP', 9);
                 END IF;

                 SELECT SUM(get_serial_diff_wrp
                           (fm_serial_number,NVL(to_serial_number,fm_serial_number)))
                   INTO l_lot_ser_qty
                   FROM mtl_serial_numbers_interface msni
                   WHERE msni.transaction_interface_id =l_intid;
              EXCEPTION
                 WHEN others THEN
                    IF (l_debug = 1) THEN
                     --serial tagging
                     inv_log_util.trace('Exception '||SQLERRM,'INV_TXN_MANAGER_GRP', 9);
                     inv_log_util.trace('Ex.. while checking lot/serial quantities','INV_TXN_MANAGER_GRP', 9);
                    END IF;
                    l_lot_ser_qty := 0;
              END;
              IF (ABS(l_priqty) <> l_lot_ser_qty) THEN
                IF (l_debug = 1) THEN
                  inv_log_util.trace('mismatch in serial quantities','INV_TXN_MANAGER_GRP', 9);
                END IF;
                loaderrmsg('INV_INT_SERMISCODE','INV_INVLTPU_LOTTRX_QTY');
                errupdate(l_rowid,null);
                l_count := l_count + 1;
                RAISE fnd_api.g_exc_error;
              ELSE
                IF (l_debug = 1) THEN
                  inv_log_util.trace('no mismatch in serial quantities','INV_TXN_MANAGER_GRP', 9);
                END IF;
              END IF;
           END IF;
        END IF;

        -- SDPAUL
        -- Bug# 5710830 Added code to validate serials and lots and insert into the corresponding
        -- master tables. These validations are only needed for Receipt into stores transaction -> 27
        -- and for the transaction sources -> 3,6 and 13.
        IF (l_acttype = 27 AND l_srctype IN(3,6,13)) THEN

          IF (l_debug = 1) THEN
            inv_log_util.trace('Before calling validate_lot_serial_for_rcpt','INV_TXN_MANAGER_GRP', 9);
          END IF;
          SAVEPOINT val_lot_serial_for_rcpt_sp;
          validate_lot_serial_for_rcpt( p_interface_id        => l_intid
                                        , p_org_id            => l_orgid
                                        , p_item_id           => l_itemid
                                        , p_lotctrl           => l_lotctrl
                                        , p_serctrl           => l_serctrl
                                        , p_rev               => l_revision
                                        , p_trx_src_id        => l_srctype
                                        , p_trx_action_id     => l_acttype
                                        , p_subinventory_code => l_subinv
                                        , p_locator_id        => l_locid
                                        , x_proc_msg          => l_msg_data
                                        , x_return_status     => l_return_status );
          IF (l_debug = 1) THEN
            inv_log_util.trace('After call to validate_lot_serial_for_rcpt','INV_TXN_MANAGER_GRP', 9);
          END IF;

          IF (l_return_status <> lg_ret_sts_success) THEN -- Failure from validate_lot_serial_for_rcpt
            IF (l_debug = 1) THEN
              inv_log_util.trace('Error from validate_lot_serial_for_rcpt','INV_TXN_MANAGER_GRP', 9);
            END IF;
            errupdate(l_rowid,null);
            l_count := l_count + 1;
            ROLLBACK TO val_lot_serial_for_rcpt_sp;
            RAISE fnd_api.g_exc_error;
          ELSE
            IF (l_debug = 1) THEN
              inv_log_util.trace('Call to validate_lot_serial_for_rcpt successful','INV_TXN_MANAGER_GRP', 9);
            END IF;
          END IF;

        END IF; -- End of fix for Bug# 5710830

            --J-dev, do not do lot and serial validations for WIP desktop
            --transactions
            IF (l_validate_full) then
               IF (l_lotctrl = 2 AND l_acttype <> 24)
                 THEN
                  IF l_intid IS NOT NULL THEN
                    BEGIN
                       SELECT 1
                         into l_tnum
                         FROM MTL_TRANSACTION_LOTS_INTERFACE
                         WHERE TRANSACTION_INTERFACE_ID = l_intid
                         AND ROWNUM < 2;

                       /**********************************************************
                       * we cannot call lotcheck for lot split and lot translate
                         * since the resultant lot can be a new lot
                         **********************************************************/
                         if( l_acttype not in (40, 42)) then
                            /** end of change for lot transactions **/
                            IF(NOT lotcheck(l_rowid,l_orgid,l_itemid,l_intid,l_priuom,
                                        l_trxuom,l_lotuniq,l_shlfcode,l_shlfdays,
                                        l_serctrl, l_srctype, l_acttype, l_is_wsm_enabled,
                                        -- INVCONV start fabdi
                                        l_trxtype, l_revision, l_subinv, l_locid, serial_tagged))
                                        -- INVCONV end fabdi
                        THEN
                           l_count := l_count + 1;
                           --exit;
                           RAISE fnd_api.g_exc_error;

                        -- bug 8669802 When txn_uom is different from pri_uom, the primary qty on for item and lot could be
                        -- different, if uom conversion setup for item is different from lot. We need honor
                        -- lot primary_qty converion.
                        ELSE
                           if l_trxuom <> l_priuom then
                             begin
                               IF (l_debug = 1) THEN
                                  inv_log_util.trace('txn uom different from primary uom','INV_TXN_MANAGER_GRP', 9);
                               END IF;

                               SELECT SUM(PRIMARY_QUANTITY)
                                 INTO l_lot_ser_qty
                                 FROM mtl_transaction_lots_interface
                                 WHERE transaction_interface_id =l_intid;
                                 inv_log_util.trace('total lot primary quantity '||l_lot_ser_qty,'INV_TXN_MANAGER_GRP', 9);

                             EXCEPTION
                             WHEN others THEN
                                IF (l_debug = 1) THEN
                                 inv_log_util.trace('Ex.. while checking lot primary quantities','INV_TXN_MANAGER_GRP', 9);
                                END IF;
                                l_lot_ser_qty := 0;
                             end;

                             l_priqty :=l_lot_ser_qty;
                           end if;

                        END IF;
                     end if;--action
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      loaderrmsg('INV_INT_LOTCODE','INV_INT_LOTEXP');
                      errupdate(l_rowid,null);
                      l_count := l_count + 1;
                      --exit;
                      RAISE fnd_api.g_exc_error;
                END;
               ELSE
                      loaderrmsg('INV_INT_LOTCODE','INV_INT_LOTEXP');
                      errupdate(l_rowid,null);
                      l_count := l_count + 1;
                      --exit;
                      RAISE fnd_api.g_exc_error;
              END IF;--l_intid is null
            ELSE
                 IF l_intid IS NOT NULL  THEN
                    DELETE FROM MTL_TRANSACTION_LOTS_INTERFACE
                      WHERE TRANSACTION_INTERFACE_ID = l_intid;
                 END IF;

           /* Additional checking for Dynamic SerCtrl and srctype = 8
           /* Changed the if condition for contracts validation */

                --Serial Tagging
                /*
                IF ( (l_serctrl = 2 OR l_serctrl = 5 OR
                        (l_serctrl = 6 AND l_srctype = 2 AND l_acttype = 1) OR
                        (l_serctrl = 6 AND l_srctype = 16 AND l_acttype = 1) OR
                        (l_serctrl = 6 AND l_srctype = 16 AND l_acttype = 1)OR
                        (l_serctrl = 6 AND l_srctype = 8 ) OR
                        --serial tagging
                        (l_serctrl = 6 AND l_trxtype in (93,94,35,43) )
                */
                IF (
                     serial_tagged = 2
                     AND l_acttype <> 24

                   ) THEN

                   IF (l_intid IS NULL) THEN
                      loaderrmsg('INV_INT_SERMISCODE','INV_INT_SERMISEXP');
                      errupdate(l_rowid,null);
                      l_count := l_count + 1;
                      --exit;
                      RAISE fnd_api.g_exc_error;
                   ELSE
                     BEGIN
                     SELECT 1
                       into l_tnum
                       FROM MTL_SERIAL_NUMBERS_INTERFACE
                       WHERE TRANSACTION_INTERFACE_ID = l_intid
                       AND ROWNUM < 2;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        loaderrmsg('INV_INT_SERMISCODE','INV_INT_SERMISEXP');
                        errupdate(l_rowid,null);
                        l_count := l_count + 1;
                        RAISE fnd_api.g_exc_error;
                        --exit;
                     END;
                   END IF;--l_intid is null
                ELSE
                      IF (l_intid IS NOT NULL) THEN
                         DELETE FROM MTL_SERIAL_NUMBERS_INTERFACE
                           WHERE TRANSACTION_INTERFACE_ID = l_intid;
                      END IF;
                END IF; --actions for serials.
           END IF;--if check actions for lots

           -- R12 Genealogy Enhancement :  Start
           IF (l_srctype = INV_GLOBALS.G_SOURCETYPE_WIP AND l_acttype = INV_GLOBALS.G_ACTION_ISSUE) THEN
              IF ((l_lotctrl = 1 AND l_acttype <> 24) AND
                  (l_lotctrl = 1 AND (l_serctrl = 2 OR l_serctrl = 5)) )
              THEN
                 IF (l_debug = 1) THEN
                    INV_log_util.trace('{{- It is serial controlled item. Call validate_serial_genealogy_data }}'
                                        , 'INV_TXN_MANAGER_GRP', 9);
                 END IF;
                 validate_serial_genealogy_data ( p_interface_id   => l_intid
                                                , p_org_id         => l_orgid
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data);
                    IF l_return_status <> lg_ret_sts_success THEN
                       IF (l_debug=1) THEN mydebug(' l_return_status: ' || l_return_status); END IF;
                      --RAISE lg_exc_error; ????
                    END IF;
              END IF;
           ELSE
              IF (l_debug = 1) THEN
              inv_log_util.trace('{{-It is not a WIP issue transactioon, so no validation/derivation of }}' ||
                                  '{{  parent object details will not happen }}' , 'INV_TXN_MANAGER_GRP', 9);
              END IF;
           END IF;
   -- R12 Genealogy Enhancement :  End

        END IF;--l_validate_full
       /*Bug#5125632. Calling 'update_status_id_in_mtli' to update the 'status_id' column
        of the table, 'MTLI', for the row corrsponding to the currnet line */

        IF (l_lotctrl = 2) THEN
          update_status_id_in_mtli(l_intid
                                  ,l_orgid
                                  ,l_itemid);
        END IF;

       l_acctid_validated := FALSE; --Bug#4247753

        IF (l_acct IS NULL) THEN
            IF (l_srctype = 3 OR l_srctype = 6) THEN
                IF (l_srctype = 6) THEN
                        SELECT DISTRIBUTION_ACCOUNT
                          INTO l_acct
                          FROM MTL_GENERIC_DISPOSITIONS
                         WHERE ORGANIZATION_ID = l_orgid
                           AND DISPOSITION_ID = l_trxsrc;
                ELSE
                    l_acct := l_trxsrc;
                END IF;

            ELSE
               /***************************************************************
                * Lot transaction open interface changes
                * We need to bypass the validation of distribution accout for
                *   lot split and lot merge transactions
                **************************************************************/
               IF( l_acttype not in (40,41)) THEN
                /** end of changes for lot transactions **/
                IF (NOT getacctid(l_acct, l_orgid, l_rowid)) THEN
                   FND_MESSAGE.set_name('INV', 'INV_INT_ACTCODE');
                   l_error_code := FND_MESSAGE.get;

                   errupdate(l_rowid,null);
                   --exit;
                  RAISE fnd_api.g_exc_error;
                END IF;
               END IF;
            END IF;

        END IF;--l_acct is null

        -- Bug#4247753. Calling the functon, validate_acctid() for validating the Account combination ID
        IF ( l_acct IS NOT NULL AND (NOT l_acctid_validated)) THEN
           IF ( NOT validate_acctid(l_acct, l_orgid, l_trxdate)) THEN
              FND_MESSAGE.set_name('INV', 'INV_INT_ACTCODE');
              l_error_code := FND_MESSAGE.get;
              errupdate(l_rowid,null);
              RAISE fnd_api.g_exc_error;
           END IF;
        END IF;

        --J-dev
  /* Validate the unit number for unit_effectivity */

   IF (NOT validate_unit_number(l_unit_number,l_orgid,l_itemid,l_srctype,l_acttype))
           THEN
                l_error_exp := FND_MESSAGE.get;
                l_error_exp := FND_MESSAGE.get;

                FND_MESSAGE.set_name('INV', 'INV_INT_UNITNUMBER');
            l_error_code := FND_MESSAGE.get;

            errupdate(l_rowid,null);
            l_count := l_count + 1;
            --exit;
            RAISE fnd_api.g_exc_error;

    END IF;


    IF (l_overcomp_txn_qty IS NOT NULL) THEN  /* Overcompletion Transactions */
        BEGIN
           IF (l_srctype=5)then
              l_overcomp_primary_qty := inv_convert.inv_um_convert(l_itemid,6,l_overcomp_txn_qty,
                                                                   l_trxuom,l_priuom,'','');
            ELSE
              l_overcomp_primary_qty := inv_convert.inv_um_convert(l_itemid,5,l_overcomp_txn_qty,
                                                                   l_trxuom,l_priuom,'','');
           END IF;
        EXCEPTION
           WHEN OTHERS THEN
        /*IF (NOT UomConvert(l_itemid,0,l_trxuom,'',l_priuom,'',
                       l_overcomp_txn_qty, l_overcomp_primary_qty,0))
        THEN */
                l_error_exp := FND_MESSAGE.get;

                FND_MESSAGE.set_name('INV', 'INV_INT_UOMCONVCODE');
            l_error_code := FND_MESSAGE.get;

            errupdate(l_rowid,null);
            l_count := l_count + 1;
        END;
    END IF;

        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = p_userid,
               LAST_UPDATE_LOGIN = p_loginid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               INVENTORY_ITEM_ID = l_itemid,
               DISTRIBUTION_ACCOUNT_ID = l_acct,
               LOCATOR_ID = l_locid,
               TRANSACTION_SOURCE_ID = l_trxsrc,
               ACCT_PERIOD_ID = l_prdid,
               PRIMARY_QUANTITY = l_priqty,
               TRANSFER_ORGANIZATION = l_xorgid,
               TRANSFER_SUBINVENTORY = l_xsubinv,
               TRANSFER_LOCATOR = l_xlocid,
               TRANSACTION_INTERFACE_ID = l_intid,
               END_ITEM_UNIT_NUMBER = l_unit_number,
               OVERCOMPLETION_PRIMARY_QTY = l_overcomp_primary_qty
         WHERE ROWID = l_rowid;

        --J-dev moving validate locators as version 115.80 incorrectly put
        --this validation IN outer validate_lines(). that would never get called.
        /* Moved the locator validation from validate_group to here
        /*So that the derived id's will get validated
        /*Begin changes for the bug 3015128 */

 /* Bug 3703053 validation of locator and xfr locator was wrongly placed
    in the j-dev project.This validation should happen after populating
    the locator_id,trasfer_locator_id into MTI not before that .Moved it
    down so that the populated locators get validated. */
/*-------------------------------------------------------------+
| Validating locators
+-------------------------------------------------------------*/
    loaderrmsg('INV_INT_LOCCODE','INV_INT_LOCEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE rowid =l_rowid
       AND PROCESS_FLAG = 1
       AND LOCATOR_ID IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_LOCATIONS MIL
           WHERE MIL.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MIL.SUBINVENTORY_CODE = MTI.SUBINVENTORY_CODE
             AND MIL.INVENTORY_LOCATION_ID = MTI.LOCATOR_ID
             AND TRUNC(MTI.TRANSACTION_DATE) <= NVL(MIL.DISABLE_DATE,
                                                 MTI.TRANSACTION_DATE + 1));


    loaderrmsg('INV_INT_LOCCODE','INV_INT_RESLOCEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE rowid =l_rowid
       AND PROCESS_FLAG = 1
       AND LOCATOR_ID IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SECONDARY_LOCATORS MSL,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 1
             AND MSL.ORGANIZATION_ID = MTI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MSL.SUBINVENTORY_CODE = MTI.SUBINVENTORY_CODE
             AND MSL.SECONDARY_LOCATOR = MTI.LOCATOR_ID
           UNION
           SELECT NULL
             FROM MTL_SYSTEM_ITEMS ITM
            WHERE ITM.RESTRICT_LOCATORS_CODE = 2
              AND ITM.ORGANIZATION_ID = MTI.ORGANIZATION_ID
              AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID);

    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating locators','INV_TXN_MANAGER_GRP',9);
    END IF;


/*-----------------------------------------------------------+
| Validating transfer locators against transfer organization
+-----------------------------------------------------------*/

    loaderrmsg('INV_INT_XLOCCODE','INV_INT_XFRLOCEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE ROWID = l_rowid
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID IN (2,3,5)
       AND TRANSFER_LOCATOR IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_LOCATIONS MIL
           WHERE MIL.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID,3,
                 MTI.TRANSFER_ORGANIZATION,MTI.ORGANIZATION_ID)
             AND MIL.SUBINVENTORY_CODE = MTI.TRANSFER_SUBINVENTORY
             AND MIL.INVENTORY_LOCATION_ID = MTI.TRANSFER_LOCATOR
             AND TRUNC(MTI.TRANSACTION_DATE) <= NVL(MIL.DISABLE_DATE,
                                                    MTI.TRANSACTION_DATE + 1));



/*------------------------------------------------------+
| Validating transfer locators for restricted list
+------------------------------------------------------*/
    loaderrmsg('INV_INT_XLOCCODE','INV_INT_RESXFRLOCEXP');

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_userid,
           LAST_UPDATE_LOGIN = p_loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(l_error_code,1,240),
           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE ROWID=l_rowid
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID in (2,21,3,5)
       AND TRANSFER_LOCATOR IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SECONDARY_LOCATORS MSL,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID,2,
                MTI.ORGANIZATION_ID, MTI.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 1
             AND MSL.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID,2,
                MTI.ORGANIZATION_ID, MTI.TRANSFER_ORGANIZATION)
             AND MSL.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MSL.SUBINVENTORY_CODE = MTI.TRANSFER_SUBINVENTORY
             AND MSL.SECONDARY_LOCATOR = MTI.TRANSFER_LOCATOR
           UNION
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MTI.TRANSACTION_ACTION_ID,2,
                MTI.ORGANIZATION_ID, MTI.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 2);


    IF (l_debug = 1) THEN
       inv_log_util.trace('Validating xfer locators ','INV_TXN_MANAGER_GRP',9);
    END IF;
/* End changes for bug 3009135 */


    --============================================================
    -- Bug 4432078
    -- OPM INVCONV  umoogala  05-Apr-2005
    -- For process-to-discrete call new transfer_price API.
    -- No change for discrete/discrete orders.
    --============================================================

    --
    -- Bug 5230916: Added direct xfer txn
    -- Bug 5349860: Process/Discrete Xfer: stamp xfer price for internal order
    --              issues to expense destination also (src/act: 8/1)
    --
    IF (l_acttype = 21
    OR (l_acttype = 3 and l_trxqty < 0)
    OR (l_srctype = 8 and l_acttype = 1))
    THEN

      --
      -- Get process mfg org flag for from and to orgs
      --
      SELECT mp_from.process_enabled_flag, mp_to.process_enabled_flag
        INTO l_process_enabled_flag_from, l_process_enabled_flag_to
        FROM mtl_parameters mp_from, mtl_parameters mp_to
       WHERE mp_from.organization_id = l_orgid
         AND mp_to.organization_id   = l_xorgid;

      --
      -- Get Operating Units for from and to orgs
      -- Bug 5240801: Was org_information2, which is legal entity.
      -- We need to get OU, so now using org_information3.
      --
      SELECT TO_NUMBER(src.org_information3) src_ou, TO_NUMBER(dest.org_information3) dest_ou
        INTO l_from_ou, l_to_ou
        FROM hr_organization_information src, hr_organization_information dest
       WHERE src.organization_id = l_orgid
         AND src.org_information_context = 'Accounting Information'
         AND dest.organization_id = l_xorgid
         AND dest.org_information_context = 'Accounting Information'
      ;

      -- get transfer price for:
      -- 1. Process-Discrete Transfers
      -- 2. Process-to-Process Orgs transfer across OUs
      -- 3. Discrete-to-Discrete Orgs transfer across OUs with IC Invoicing enabled.
      --
      l_ic_invoicing_enabled := fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER');

      IF (l_process_enabled_flag_from <> l_process_enabled_flag_to) OR
         (l_process_enabled_flag_from = 'Y' AND l_process_enabled_flag_to = 'Y' AND
          l_from_ou <> l_to_ou) OR
         (l_process_enabled_flag_from = 'N' AND l_process_enabled_flag_to = 'N' AND
          l_from_ou <> l_to_ou AND
          l_ic_invoicing_enabled = 1 AND
          l_srctype = 8 AND l_acttype = 21)
      THEN

        IF (l_debug = 1) THEN
           IF (l_process_enabled_flag_from <> l_process_enabled_flag_to)
           THEN
             inv_log_util.trace('This is process-discrete xfer. Getting Transfer Price.','INV_TXN_MANAGER_GRP',9);
           ELSIF (l_process_enabled_flag_from = 'Y' AND
                  l_process_enabled_flag_to   = 'Y')
           THEN
             inv_log_util.trace('This is process-process xfer across OUs. Getting Transfer Price.','INV_TXN_MANAGER_GRP',9);
           ELSIF (l_process_enabled_flag_from = 'N' AND
                  l_process_enabled_flag_to   = 'N')
           THEN
             inv_log_util.trace('This is discrete-discrete xfer across OUs with IC enabled. Getting Transfer Price.','INV_TXN_MANAGER_GRP',9);
           END IF;
        END IF;

        --
        -- For internal orders across OUs and IC Invoicing is enabled, then
        -- set transfer type to 'INTCOM'. IF transfer type is 'INTCOM' the
        -- API below calls INV_TRANSACTION_FLOW_PUB.get_transfer_price.
        --
        -- For INTORG transfers, new transfer price API is called.
        --
        IF l_from_ou <> l_to_ou
        AND l_srctype = 8
        -- Internal Orders across OUs
        THEN
          --
          -- Bug 5349354: direct xfers are not considered as inter-company txn.
          --
          IF l_ic_invoicing_enabled = 1 and l_acttype = 21
          THEN
            l_xfer_type   := 'INTCOM';
            l_xfer_source := 'INTCOM';
          ELSE
            l_xfer_type   := 'INTORD';
            l_xfer_source := 'INTORD';
          END IF;
        ELSIF l_from_ou = l_to_ou
        AND   l_srctype = 8
        -- Internal Orders within same OUs
        THEN
          l_xfer_type   := 'INTORD';
          l_xfer_source := 'INTORD';
        ELSE
        -- InterOrg xfers
          l_xfer_type   := 'INTORG';
          l_xfer_source := 'INTORG';
        END IF;

        -- call transfer price API
        GMF_get_transfer_price_PUB.get_transfer_price (
                  p_api_version             => 1.0
                , p_init_msg_list           => 'FALSE'

                , p_inventory_item_id       => l_itemid
                , p_transaction_qty         => l_trxqty
                , p_transaction_uom         => l_trxuom

                --Bug9227278 , passing the p_transaction_date parameter.
                , p_transaction_date        => l_trxdate

                , p_transaction_id          => l_order_line_id
                , p_global_procurement_flag => 'N'
                , p_drop_ship_flag          => 'N'

                , p_from_organization_id    => l_orgid
                , p_from_ou                 => l_from_ou
                , p_to_organization_id      => l_xorgid
                , p_to_ou                   => l_to_ou

                , p_transfer_type           => l_xfer_type  -- INTORG or INTCOM
                , p_transfer_source         => l_xfer_source

                , x_return_status           => x_return_status
                , x_msg_data                => x_msg_data
                , x_msg_count               => x_msg_count

                , x_transfer_price          => l_transfer_price        -- in base currency txn uom
                , x_transfer_price_priuom   => l_transfer_price_priuom -- in base currency
                , x_currency_code           => x_currency_code
                , x_incr_transfer_price     => x_incr_transfer_price
                , x_incr_currency_code      => x_incr_currency_code
        );

        IF (l_debug = 1) THEN
           inv_log_util.trace('After getting transfer price. Status: ' || x_return_status,  'INV_TXN_MANAGER_GRP','1');
        END IF;

        IF x_return_status = FND_API.G_RET_STS_SUCCESS
        THEN

          --
          -- Bug 5136335
          -- l_transfer_price_priuom can be NULL for discrete/discrete intercompany xfers.
          -- We need to ignore this error when intercompany setup is not done. This is handled
          -- in above GMF API call.
          -- So, moved this condition from above condition to not to raise any error.
          --
          IF l_transfer_price_priuom IS NOT NULL
          THEN

            IF (l_debug = 1) THEN
               inv_log_util.trace('Updating MTI with transfer price: ' || l_transfer_price_priuom,  'INV_TXN_MANAGER_GRP','1');
            END IF;

            UPDATE MTL_TRANSACTIONS_INTERFACE MTI
               SET LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = p_userid,
                   LAST_UPDATE_LOGIN = p_loginid,
                   transfer_price = l_transfer_price_priuom
             WHERE ROWID = l_rowid;
          END IF;
        ELSE
          l_error_exp := x_msg_data;
          FND_MESSAGE.set_name('BOM', 'CST_XFER_PRICE_ERROR');
          l_error_code := FND_MESSAGE.get;
          errupdate(l_rowid,null);
          l_count := l_count + 1;
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE
        IF (l_debug = 1) THEN
           inv_log_util.trace('InterOrg Xfer. Skipping transfer price API call as all conditions are not met.' ||
             ' From/To ProcessFlags: ' || l_process_enabled_flag_from ||'/'|| l_process_enabled_flag_to ||
             ' From/To OUs: ' || l_from_ou ||'/'|| l_to_ou ||
             ' l_ic_invoicing_enabled: ' || l_ic_invoicing_enabled,
           'INV_TXN_MANAGER_GRP',9);
        END IF;
        -- Not a process-discrete xfer. So, set xfer price to NULL
        l_transfer_price := NULL;
      END IF;
    END IF;
    --============================================================
    -- End OPM INVCONV  changes by umoogala
    --============================================================
    IF (l_debug = 1) THEN
        inv_log_util.trace('end of validate lines inner sec uom code='||p_line_Rec_Type.secondary_uom_code, 'INV_TXN_MANAGER_GRP', 9);
        inv_log_util.trace('end of validate lines inner lot control='||to_char(l_lotctrl), 'INV_TXN_MANAGER_GRP', 9);
      END IF;
    --Jalaj Srivastava Bug 4969885
    IF (l_lotctrl=2 AND p_line_Rec_Type.secondary_uom_code IS NOT NULL) THEN
      IF (l_debug = 1) THEN
        inv_log_util.trace('update secondary quantity on line as sum of lot level secondary quantities', 'INV_TXN_MANAGER_GRP', 9);
      END IF;
      UPDATE MTL_TRANSACTIONS_INTERFACE MTI
      SET    secondary_transaction_quantity = (SELECT SUM(SECONDARY_TRANSACTION_QUANTITY)
                                               FROM   MTL_TRANSACTION_LOTS_INTERFACE MTLI
                                               WHERE  MTLI.TRANSACTION_INTERFACE_ID = p_line_Rec_Type.TRANSACTION_INTERFACE_ID)
      WHERE  ROWID = l_rowid;
    END IF;

/* Bug 6356567 Changes Starting */
/*--------------------------------------------------------------+
   Validating Cost group
+--------------------------------------------------------------*/

   SELECT cost_group_id, transfer_cost_group_id
     INTO l_cost_group_id, l_xfer_cost_group_id
     FROM MTL_TRANSACTIONS_INTERFACE
    WHERE ROWID = l_rowid
      AND PROCESS_FLAG = 1;

   IF l_cost_group_id is not null and l_acttype not in (5,6,24,30,50,51,52) THEN        -- Modified 7025628
        l_temp_cost_group_id := get_costgrpid(l_orgid, l_subinv, l_locid);
        loaderrmsg('INV_INT_CSTGRP','INV_INT_CSTEXP');

        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = p_userid,
               LAST_UPDATE_LOGIN = p_loginid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               PROCESS_FLAG = 3,
               LOCK_FLAG = 2,
               ERROR_CODE = substrb(l_error_code,1,240),
               ERROR_EXPLANATION = substrb(l_error_exp,1,240)
         WHERE ROWID = l_rowid
           AND PROCESS_FLAG = 1
           AND TRANSACTION_ACTION_ID NOT IN (5,6,24,30,50,51,52)                        -- Added 7025628
           AND COST_GROUP_ID IS NOT NULL
           AND COST_GROUP_ID <> l_temp_cost_group_id
           AND EXISTS ( SELECT 1                                                        -- Bug 8345339 Changes Start
                        FROM MTL_PARAMETERS
                        WHERE ORGANIZATION_ID = l_orgid
                        AND WMS_ENABLED_FLAG = 'N');                                        -- Bug 8345339 Changes End

        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating cost group ', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
   END IF;

/*--------------------------------------------------------------+
   Validating Transfer Cost group
+--------------------------------------------------------------*/

   IF l_xfer_cost_group_id is not null and l_acttype in (2,5,3,21) THEN
        IF l_acttype in (2, 5) THEN
           l_cg_org := l_orgid;
        ELSIF l_acttype in (3, 21) THEN
           l_cg_org := l_xorgid;
        END IF;

        l_temp_xfer_cost_group_id := get_costgrpid(l_cg_org, l_xsubinv, l_xlocid);
        loaderrmsg('INV_INT_XCSTGRP','INV_INT_XCSTEXP');

        UPDATE MTL_TRANSACTIONS_INTERFACE MTI
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = p_userid,
               LAST_UPDATE_LOGIN = p_loginid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               PROCESS_FLAG = 3,
               LOCK_FLAG = 2,
               ERROR_CODE = substrb(l_error_code,1,240),
               ERROR_EXPLANATION = substrb(l_error_exp,1,240)
         WHERE ROWID = l_rowid
           AND PROCESS_FLAG = 1
           AND TRANSACTION_ACTION_ID IN (2,3,21,5)
           AND TRANSFER_COST_GROUP_ID IS NOT NULL
           AND TRANSFER_COST_GROUP_ID <> l_temp_xfer_cost_group_id
           AND EXISTS ( SELECT 1                                                        -- Bug 8345339 Changes Start
                        FROM MTL_PARAMETERS
                        WHERE ORGANIZATION_ID = l_cg_org
                        AND WMS_ENABLED_FLAG = 'N');                                        -- Bug 8345339 Changes End

        IF (l_debug = 1) THEN
           inv_log_util.trace('Validating xfer cost group ', 'INV_TXN_MANAGER_GRP', 9);
        END IF;
   END IF;

/* Bug 6356567 Changes Ending */

/*---------------------------------------+
 | Commit work only if not a CFM WIP txn |
 +---------------------------------------*/
        IF (l_flow_schedule_children <> 1) AND FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
--    END LOOP;

--Fix For 9186813

--Verifying whether any of the specified serials are Group Marked
--Particularly cross checking the serials against MO Txr suggession
--If any of the serials marked then update the MTI record with error

    FND_MESSAGE.set_name('INV', 'INV_SERIAL_USED');
    l_error_code := FND_MESSAGE.get;
    l_error_exp := l_error_code;

    UPDATE MTL_TRANSACTIONS_INTERFACE
      SET LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = p_userid,
        LAST_UPDATE_LOGIN = p_loginid,
        PROGRAM_UPDATE_DATE = SYSDATE,
        PROCESS_FLAG = 3,
        LOCK_FLAG = 2,
        ERROR_CODE = substrb(l_error_code,1,240),
        ERROR_EXPLANATION = substrb(l_error_exp,1,240)
      WHERE ROWID = l_rowid
        AND PROCESS_FLAG = 1
        AND (
        EXISTS
        (
          select 1 FROM mtl_serial_numbers msn, mtl_serial_numbers_interface msni,
          mtl_transactions_interface mti, mtl_material_transactions_temp mmtt
          WHERE msn.serial_number BETWEEN msni.fm_serial_number AND msni.to_serial_number
          AND Length(msn.serial_number) = Length(msni.fm_serial_number)
          AND msn.current_organization_id = mti.organization_id
          AND msn.inventory_item_id = mti.inventory_item_id
          AND msni.transaction_interface_id = mti.transaction_interface_id
          AND mmtt.transaction_temp_id = msn.group_mark_id
          AND mmtt.inventory_item_id = mti.inventory_item_id
          AND mmtt.transaction_source_type_id = 4 AND mmtt.transaction_action_id = 2
          AND mmtt.transaction_type_id = 64
          AND mmtt.organization_id = mti.organization_id
          AND mti.ROWID = l_rowid
        )
        OR EXISTS
        (
          select msn.serial_number, msn.group_mark_id,mti.transaction_interface_id
          FROM mtl_serial_numbers msn, mtl_serial_numbers_interface msni,
          mtl_transactions_interface mti,mtl_transaction_lots_interface mtli,
          mtl_material_transactions_temp mmtt
          WHERE msn.serial_number BETWEEN msni.fm_serial_number AND msni.to_serial_number
          AND Length(msn.serial_number) = Length(msni.fm_serial_number)
          AND msn.current_organization_id = mti.organization_id
          AND msn.inventory_item_id = mti.inventory_item_id
          AND msni.transaction_interface_id = mtli.serial_transaction_temp_id
          AND mtli.transaction_interface_id =  mti.transaction_interface_id
          AND mmtt.transaction_temp_id = msn.group_mark_id
          AND mmtt.inventory_item_id = mti.inventory_item_id
          AND mmtt.transaction_source_type_id = 4
          AND mmtt.transaction_action_id = 2
          AND mmtt.transaction_type_id = 64
          AND mmtt.organization_id = mti.organization_id
          AND mti.ROWID = l_rowid
        ));

--End of Fix 9186813

EXCEPTION
    WHEN OTHERS THEN
    p_error_flag:='Y';
    IF (l_debug = 1) THEN
       inv_log_util.trace('Error in validate_line : ' || l_error_exp, 'INV_TXN_MANAGER_GRP','1');
       inv_log_util.trace('Error:'||substr(sqlerrm,1,250),'INV_TXN_MANAGER_GRP',1);
    END IF;

    UPDATE MTL_TRANSACTIONS_INTERFACE
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = p_userid,
               LAST_UPDATE_LOGIN = p_loginid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               PROCESS_FLAG = 3,
               LOCK_FLAG = 2,
               ERROR_CODE = substrb(l_error_code,1,240),
               ERROR_EXPLANATION = substrb(l_error_exp,1,240)
     WHERE ROWID = l_rowid
       AND PROCESS_FLAG = 1;

/*---------------------------------------+
 | Commit work only if not a CFM WIP txn |
 +---------------------------------------*/
    IF (l_flow_schedule_children <> 1) AND FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    l_error_exp := '';
    l_error_code := '';
    FND_MESSAGE.clear;
    return;
END validate_lines;


/******************************************************************
 *
 * get_open_period()
 *
 ******************************************************************/
FUNCTION get_open_period(p_org_id NUMBER,p_trans_date DATE,p_chk_date NUMBER) RETURN NUMBER IS

chk_date NUMBER;  /* 0 ignore date,1-return 0 if date doesn't fall in current
                     period, -1 if Oracle error, otherwise period id*/
trans_date  DATE; /* transaction_date */
acct_period_id NUMBER;  /* period_close_id of current period */

BEGIN
    if ( l_debug is null) then
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    end if;

    acct_period_id := 0; /* default value */

     if (chk_date = 1) THEN

         SELECT ACCT_PERIOD_ID
         INTO   acct_period_id
         FROM   ORG_ACCT_PERIODS
         WHERE  PERIOD_CLOSE_DATE IS NULL
         AND    ORGANIZATION_ID = p_org_id
         AND    INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(NVL(p_trans_date,SYSDATE),p_org_id)
                      BETWEEN PERIOD_START_DATE and SCHEDULE_CLOSE_DATE
         ORDER BY PERIOD_START_DATE DESC, SCHEDULE_CLOSE_DATE ASC;

    else

         SELECT ACCT_PERIOD_ID
         INTO   acct_period_id
         FROM   ORG_ACCT_PERIODS
         WHERE  PERIOD_CLOSE_DATE IS NULL
         AND ORGANIZATION_ID = p_org_id
         AND TRUNC(SCHEDULE_CLOSE_DATE) >=
              INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(NVL(p_trans_date,SYSDATE),p_org_id)
          AND TRUNC(PERIOD_START_DATE) <=
              INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(NVL(p_trans_date,SYSDATE),p_org_id);
    end if;

   return(acct_period_id);

exception
   when NO_DATA_FOUND then
        acct_period_id := 0;
        return(acct_period_id);
   when OTHERS then
        acct_period_id  := -1;
        return(acct_period_id);


end get_open_period;



/******************************************************************
 *
 * tmpinsert()
 *
 ******************************************************************/
   FUNCTION tmpinsert(p_header_id IN NUMBER,
                      p_validation_level IN NUMBER  := fnd_api.g_valid_level_full )
RETURN BOOLEAN
IS

    l_lt_flow_schedule NUMBER;
    l_count            NUMBER := 0;
    l_patchset_j       NUMBER := 0;  /* 0 = No 1 = Yes */

BEGIN
    IF (l_debug is null) then
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    end if;

    --bug 4574806. this will be used in the statements below for final
    --completion flag AS a decode
    IF (wip_constants.DMF_PATCHSET_LEVEL>=
        wip_constants.DMF_PATCHSET_J_VALUE) THEN
       l_patchset_j := 1;
    END IF;

    --J-dev
    /** For patchset J.wip will do the computation for the
    /*completion_transaction_id. For J new colmns have been added
    /* move_transaction_id (new)
    /*completion_transaction_id (new)
    /*wip_supply_type (new)*/

    l_lt_flow_schedule := gi_flow_schedule ;

    /*OSFM Support for Serialized Lot Items*/
    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE (   'In tmpinsert '
                          , 'INV_TXN_MANAGER_GRP'
                        , '9'
                         );
    END IF;
    /*********************************************************************
     * In case there are only Lot Split/Merge/Translate Transactions only*
     * we do a successful return                                         *
     *********************************************************************/
    BEGIN
      SELECT 1
        INTO l_count
        FROM DUAL
        WHERE EXISTS (SELECT transaction_interface_id
           FROM  mtl_transactions_interface
           WHERE transaction_header_id = p_header_id
           AND process_flag = 1
           AND transaction_type_id NOT IN
                 (inv_globals.g_type_inv_lot_split
                , inv_globals.g_type_inv_lot_merge
                , inv_globals.g_type_inv_lot_translate));
    EXCEPTION
        WHEN OTHERS THEN
          l_count := 0;
          IF(l_debug = 1) THEN
          inv_log_util.TRACE (   'Exce. Section l_count => ' || l_count
                     , 'INV_TXN_MANAGER_GRP'
                   , '9'
                    );
          END IF;
    END;
    IF(l_count = 0 OR l_count IS NULL) THEN
      IF (l_debug = 1)
      THEN
       inv_log_util.TRACE (   'Returning from tmpinsert '
                           , 'INV_TXN_MANAGER_GRP'
                         , '9'
                          );
      END IF;
      RETURN TRUE;
    END IF;

    /*OSFM Support for Serialized Lot Items*/

    IF ( l_lt_flow_schedule = 0) THEN

        INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP (
        TRANSACTION_HEADER_ID,
        TRANSACTION_TEMP_ID,
        SOURCE_CODE,
        SOURCE_LINE_ID,
        PROCESS_FLAG,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID,
        ORGANIZATION_ID,
        SUBINVENTORY_CODE,
        LOCATOR_ID,
        INVENTORY_ITEM_ID,
        REVISION,
        TRANSACTION_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_SOURCE_ID,
        TRANSACTION_SOURCE_NAME,
        TRANSACTION_REFERENCE,
        REASON_ID,
        TRANSACTION_DATE,
        ACCT_PERIOD_ID,
        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,
        PRIMARY_QUANTITY,
        TRANSACTION_COST,
        DISTRIBUTION_ACCOUNT_ID,
        TRANSFER_SUBINVENTORY,
        TRANSFER_ORGANIZATION,
        TRANSFER_TO_LOCATION,
        SHIPMENT_NUMBER,
        TRANSPORTATION_COST,
        TRANSFER_COST,
        TRANSPORTATION_ACCOUNT,
        FREIGHT_CODE,
        CONTAINERS,
        WAYBILL_AIRBILL,
        EXPECTED_ARRIVAL_DATE,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        DEMAND_ID,
        DEMAND_SOURCE_HEADER_ID,
        DEMAND_SOURCE_LINE,
        DEMAND_SOURCE_DELIVERY,
        CUSTOMER_SHIP_ID,
        TRX_SOURCE_DELIVERY_ID,
        TRX_SOURCE_LINE_ID,
        PICKING_LINE_ID,
        REQUIRED_FLAG,
        NEGATIVE_REQ_FLAG,
        REPETITIVE_LINE_ID,
        PRIMARY_SWITCH,
        OPERATION_SEQ_NUM,
        SETUP_TEARDOWN_CODE,
        SCHEDULE_UPDATE_CODE,
        DEPARTMENT_ID,
        EMPLOYEE_CODE,
        SCHEDULE_ID,
        WIP_ENTITY_TYPE,
        ENCUMBRANCE_AMOUNT,
        ENCUMBRANCE_ACCOUNT,
        USSGL_TRANSACTION_CODE,
        SHIPPABLE_FLAG,
        REQUISITION_LINE_ID,
        REQUISITION_DISTRIBUTION_ID,
        SHIP_TO_LOCATION,
        COMPLETION_TRANSACTION_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        MOVEMENT_ID,
        SOURCE_PROJECT_ID,
        SOURCE_TASK_ID,
        EXPENDITURE_TYPE,
        PA_EXPENDITURE_ORG_ID,
        PROJECT_ID,
        TASK_ID,
        TO_PROJECT_ID,
        TO_TASK_ID,
        POSTING_FLAG,
        FINAL_COMPLETION_FLAG,
        TRANSFER_PERCENTAGE,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        RESOURCE_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        COST_GROUP_ID,
        FLOW_SCHEDULE,
        QA_COLLECTION_ID,
        OVERCOMPLETION_TRANSACTION_QTY, /* Overcompletion Transactions */
        OVERCOMPLETION_PRIMARY_QTY,
        OVERCOMPLETION_TRANSACTION_ID,
        END_ITEM_UNIT_NUMBER,
        ORG_COST_GROUP_ID, /* PCST (Periodic Cost Update) */
        COST_TYPE_ID, /* PCST */
        MOVE_ORDER_LINE_ID,
        LPN_ID,
        CONTENT_LPN_ID,
        TRANSFER_LPN_ID,
        ORGANIZATION_TYPE,
        TRANSFER_ORGANIZATION_TYPE,
        OWNING_ORGANIZATION_ID,
        OWNING_TP_TYPE,
        XFR_OWNING_ORGANIZATION_ID,
        TRANSFER_OWNING_TP_TYPE,
        PLANNING_ORGANIZATION_ID,
        PLANNING_TP_TYPE,
        XFR_PLANNING_ORGANIZATION_ID,
        TRANSFER_PLANNING_TP_TYPE,
        TRANSACTION_BATCH_ID,
        TRANSACTION_BATCH_SEQ,
        TRANSFER_COST_GROUP_ID,
        TRANSACTION_MODE,
     -- start of fix for eam
     -- added following 4 columns
         REBUILD_ITEM_ID,
         REBUILD_ACTIVITY_ID,
         REBUILD_SERIAL_NUMBER,
          rebuild_job_name,
          kanban_card_id  ,-- end of fix for eam
          class_code,--J dev (accounting_class in MTI)
          scheduled_flag,--J dev
          schedule_number,--J dev
          routing_revision_date,--J dev
          move_transaction_id,--J dev
          wip_supply_type,--J dev
          build_sequence,--J dev
          bom_revision,--J dev
          routing_revision,--J dev
          bom_revision_date,--J dev
          alternate_bom_designator,--J dev
          alternate_routing_designator,   -- end of fix for eam
          SECONDARY_TRANSACTION_QUANTITY, -- INVCONV fabdi start
          SECONDARY_UOM_CODE, -- INVCONV fabdi end
    RELIEVE_RESERVATIONS_FLAG,      /*** {{ R12 Enhanced reservations code changes ***/
    RELIEVE_HIGH_LEVEL_RSV_FLAG,    /*** {{ R12 Enhanced reservations code changes ***/
    TRANSFER_PRICE,                  -- INVCONV umoogala  For Process-Discrete Transfer Enh.
    scheduled_payback_date  --BUG 7683172
          )
    SELECT
        TRANSACTION_HEADER_ID,
        TRANSACTION_INTERFACE_ID,
        SOURCE_CODE,
        SOURCE_LINE_ID,
        'Y',
        SYSDATE,
        CREATED_BY,
        SYSDATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        PROGRAM_ID,
        SYSDATE,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID,
        ORGANIZATION_ID,
        SUBINVENTORY_CODE,
        LOCATOR_ID,
        INVENTORY_ITEM_ID,
        REVISION,
        TRANSACTION_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_SOURCE_ID,
        TRANSACTION_SOURCE_NAME,
        TRANSACTION_REFERENCE,
        REASON_ID,
        TRANSACTION_DATE,
        ACCT_PERIOD_ID,
        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,
        PRIMARY_QUANTITY,
        TRANSACTION_COST,
        DISTRIBUTION_ACCOUNT_ID,
        TRANSFER_SUBINVENTORY,
        TRANSFER_ORGANIZATION,
        TRANSFER_LOCATOR,
        SHIPMENT_NUMBER,
        TRANSPORTATION_COST,
        TRANSFER_COST,
        TRANSPORTATION_ACCOUNT,
        FREIGHT_CODE,
        CONTAINERS,
        WAYBILL_AIRBILL,
        EXPECTED_ARRIVAL_DATE,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        DEMAND_ID,
        DEMAND_SOURCE_HEADER_ID,
        DEMAND_SOURCE_LINE,
        DEMAND_SOURCE_DELIVERY,
        CUSTOMER_SHIP_ID,
        TRX_SOURCE_DELIVERY_ID,
        TRX_SOURCE_LINE_ID,
        PICKING_LINE_ID,
        REQUIRED_FLAG,
        NEGATIVE_REQ_FLAG,
        REPETITIVE_LINE_ID,
        PRIMARY_SWITCH,
        OPERATION_SEQ_NUM,
        SETUP_TEARDOWN_CODE,
        SCHEDULE_UPDATE_CODE,
        DEPARTMENT_ID,
        EMPLOYEE_CODE,
        SCHEDULE_ID,
        WIP_ENTITY_TYPE,
        ENCUMBRANCE_AMOUNT,
        ENCUMBRANCE_ACCOUNT,
        USSGL_TRANSACTION_CODE,
        SHIPPABLE_FLAG,
        REQUISITION_LINE_ID,
        REQUISITION_DISTRIBUTION_ID,
        SHIP_TO_LOCATION_ID,
        Nvl(completion_transaction_id,DECODE(TRANSACTION_ACTION_ID,31,
               MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL,32,MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL,NULL)),--J-dev as wip will pass this to us. For I we need the decode.
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        MOVEMENT_ID,
        SOURCE_PROJECT_ID,
        SOURCE_TASK_ID,
        EXPENDITURE_TYPE,
        PA_EXPENDITURE_ORG_ID,
        PROJECT_ID,
        TASK_ID,
        TO_PROJECT_ID,
        TO_TASK_ID,
        'N',
        NVL(FINAL_COMPLETION_FLAG,Decode(l_patchset_j,1,FINAL_COMPLETION_FLAG,
'N')),
        TRANSFER_PERCENTAGE,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        RESOURCE_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        COST_GROUP_ID,
        FLOW_SCHEDULE,
        QA_COLLECTION_ID,
        OVERCOMPLETION_TRANSACTION_QTY, /* Overcompletion Transactions */
        OVERCOMPLETION_PRIMARY_QTY,
        OVERCOMPLETION_TRANSACTION_ID,
        END_ITEM_UNIT_NUMBER,
        ORG_COST_GROUP_ID,  /* PCST */
        COST_TYPE_ID,
        DECODE(TRANSACTION_SOURCE_TYPE_ID,4,SOURCE_LINE_ID,null),       /* PCST */
        LPN_ID,
        CONTENT_LPN_ID,
          transfer_lpn_id,
          organization_type,
          transfer_organization_type,
          owning_organization_id,
          owning_tp_type,
          xfr_owning_organization_id,
          transfer_owning_tp_type,
          planning_organization_id,
          planning_tp_type,
          xfr_planning_organization_id,
          TRANSFER_PLANNING_TP_TYPE,
          TRANSACTION_BATCH_ID,
          TRANSACTION_BATCH_SEQ,
          TRANSFER_COST_GROUP_ID,
          Decode(p_validation_level,fnd_api.g_valid_level_none,transaction_mode,INV_TXN_MANAGER_GRP.proc_mode_mti),
-- start of fix for eam
-- added following 4 columns
          REBUILD_ITEM_ID,
          REBUILD_ACTIVITY_ID,
          REBUILD_SERIAL_NUMBER,
          rebuild_job_name,
          -- end of fix for eam
          kanban_card_id,
          accounting_class,--J dev (class_code in mmtt)
          scheduled_flag,--J dev
          schedule_number,--J dev
          routing_revision_date,--J dev
          move_transaction_id,--J dev
          wip_supply_type , --J dev
          build_sequence,--J dev
          bom_revision,--J dev
          routing_revision,--J dev
          bom_revision_date,--J dev
          alternate_bom_designator,--J dev
          alternate_routing_designator, --J-dev
          SECONDARY_TRANSACTION_QUANTITY, -- INVCONV start fabdi
          SECONDARY_UOM_CODE,             -- INVCONV fabdi end
    RELIEVE_RESERVATIONS_FLAG,      /*** {{ R12 Enhanced reservations code changes ***/
    RELIEVE_HIGH_LEVEL_RSV_FLAG,    /*** {{ R12 Enhanced reservations code changes ***/
    TRANSFER_PRICE,                  -- INVCONV umoogala  For Process-Discrete Transfer Enh.
    scheduled_payback_date  --BUG 7683172
   FROM MTL_TRANSACTIONS_INTERFACE
         --WHERE ROWID = p_rowid--J-dev
         WHERE transaction_header_id = p_header_id
          AND PROCESS_FLAG = 1
           AND transaction_type_id NOT IN          /*OSFM Support for Lot Serialized Items*/
                 (inv_globals.g_type_inv_lot_split
                , inv_globals.g_type_inv_lot_merge
                , inv_globals.g_type_inv_lot_translate
                 );

    ELSE
     IF ( l_lt_flow_schedule <> 0 ) THEN
        INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP (
        TRANSACTION_HEADER_ID,
        TRANSACTION_TEMP_ID,
        SOURCE_CODE,
        SOURCE_LINE_ID,
        PROCESS_FLAG,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID,
        ORGANIZATION_ID,
        SUBINVENTORY_CODE,
        LOCATOR_ID,
        INVENTORY_ITEM_ID,
        REVISION,
        TRANSACTION_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_SOURCE_ID,
        TRANSACTION_SOURCE_NAME,
        TRANSACTION_REFERENCE,
        REASON_ID,
        TRANSACTION_DATE,
        ACCT_PERIOD_ID,
        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,
        PRIMARY_QUANTITY,
        TRANSACTION_COST,
        DISTRIBUTION_ACCOUNT_ID,
        TRANSFER_SUBINVENTORY,
        TRANSFER_ORGANIZATION,
        TRANSFER_TO_LOCATION,
        SHIPMENT_NUMBER,
        TRANSPORTATION_COST,
        TRANSFER_COST,
        TRANSPORTATION_ACCOUNT,
        FREIGHT_CODE,
        CONTAINERS,
        WAYBILL_AIRBILL,
        EXPECTED_ARRIVAL_DATE,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        DEMAND_ID,
        DEMAND_SOURCE_HEADER_ID,
        DEMAND_SOURCE_LINE,
        DEMAND_SOURCE_DELIVERY,
        DEMAND_CLASS,
        CUSTOMER_SHIP_ID,
        TRX_SOURCE_DELIVERY_ID,
        TRX_SOURCE_LINE_ID,
        PICKING_LINE_ID,
        REQUIRED_FLAG,
        NEGATIVE_REQ_FLAG,
        REPETITIVE_LINE_ID,
        PRIMARY_SWITCH,
        OPERATION_SEQ_NUM,
        SETUP_TEARDOWN_CODE,
        SCHEDULE_UPDATE_CODE,
        DEPARTMENT_ID,
        EMPLOYEE_CODE,
        SCHEDULE_ID,
        WIP_ENTITY_TYPE,
        ENCUMBRANCE_AMOUNT,
        ENCUMBRANCE_ACCOUNT,
        USSGL_TRANSACTION_CODE,
        SHIPPABLE_FLAG,
        REQUISITION_LINE_ID,
        REQUISITION_DISTRIBUTION_ID,
        SHIP_TO_LOCATION,
        COMPLETION_TRANSACTION_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        MOVEMENT_ID,
        SOURCE_PROJECT_ID,
        SOURCE_TASK_ID,
        EXPENDITURE_TYPE,
        PA_EXPENDITURE_ORG_ID,
        PROJECT_ID,
        TASK_ID,
        TO_PROJECT_ID,
        TO_TASK_ID,
        POSTING_FLAG,
        FINAL_COMPLETION_FLAG,
        TRANSFER_PERCENTAGE,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        RESOURCE_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        COST_GROUP_ID,
        FLOW_SCHEDULE,
        QA_COLLECTION_ID,
        OVERCOMPLETION_TRANSACTION_QTY, /* Overcompletion Transactions */
        OVERCOMPLETION_PRIMARY_QTY,
        OVERCOMPLETION_TRANSACTION_ID,
        END_ITEM_UNIT_NUMBER,
        COMMON_BOM_SEQ_ID,
        COMMON_ROUTING_SEQ_ID,
        ORG_COST_GROUP_ID,    /* PCST */
        COST_TYPE_ID,
        LPN_ID,
        CONTENT_LPN_ID,
          transfer_lpn_id,
          organization_type,
          transfer_organization_type,
          owning_organization_id,
          owning_tp_type,
          xfr_owning_organization_id,
          transfer_owning_tp_type,
          planning_organization_id,
          planning_tp_type,
          xfr_planning_organization_id,
          TRANSFER_PLANNING_TP_TYPE,
          TRANSACTION_BATCH_ID,
          TRANSACTION_BATCH_SEQ,
          TRANSFER_COST_GROUP_ID,
          TRANSACTION_MODE,
-- start of fix for eam
-- added following 4 columns
          REBUILD_ITEM_ID,
          REBUILD_ACTIVITY_ID,
          REBUILD_SERIAL_NUMBER,
          rebuild_job_name,
          -- end of fix for eam
          kanban_card_id,
          class_code,--J dev (class_code in mmtt)
          scheduled_flag,--J dev
          schedule_number,--J dev
          routing_revision_date,--J dev
          move_transaction_id,--J dev
          wip_supply_type,
          build_sequence,--J dev
          bom_revision,--J dev
          routing_revision,--J dev
          bom_revision_date,--J dev
          alternate_bom_designator,--J dev
          alternate_routing_designator , --J dev
          SECONDARY_TRANSACTION_QUANTITY , -- INVCONV fabdi
          SECONDARY_UOM_CODE,              -- INVCONV fabdi end
    RELIEVE_RESERVATIONS_FLAG,       /*** {{ R12 Enhanced reservations code changes ***/
    RELIEVE_HIGH_LEVEL_RSV_FLAG,     /*** {{ R12 Enhanced reservations code changes ***/
    TRANSFER_PRICE                   -- INVCONV umoogala  For Process-Discrete Transfer Enh.
          )
   SELECT
        MTI.TRANSACTION_HEADER_ID,
        MTI.TRANSACTION_INTERFACE_ID,
        MTI.SOURCE_CODE,
        MTI.SOURCE_LINE_ID,
        'Y',
        SYSDATE,
        MTI.CREATED_BY,
        SYSDATE,
        MTI.LAST_UPDATED_BY,
        MTI.LAST_UPDATE_LOGIN,
        MTI.PROGRAM_ID,
        SYSDATE,
        MTI.PROGRAM_APPLICATION_ID,
        MTI.REQUEST_ID,
        MTI.ORGANIZATION_ID,
        MTI.SUBINVENTORY_CODE,
        MTI.LOCATOR_ID,
        MTI.INVENTORY_ITEM_ID,
        MTI.REVISION,
        MTI.TRANSACTION_TYPE_ID,
        MTI.TRANSACTION_ACTION_ID,
        MTI.TRANSACTION_SOURCE_TYPE_ID,
        MTI.TRANSACTION_SOURCE_ID,
        MTI.TRANSACTION_SOURCE_NAME,
        MTI.TRANSACTION_REFERENCE,
        MTI.REASON_ID,
        MTI.TRANSACTION_DATE,
        MTI.ACCT_PERIOD_ID,
        MTI.TRANSACTION_QUANTITY,
        MTI.TRANSACTION_UOM,
        MTI.PRIMARY_QUANTITY,
        MTI.TRANSACTION_COST,
        MTI.DISTRIBUTION_ACCOUNT_ID,
        MTI.TRANSFER_SUBINVENTORY,
        MTI.TRANSFER_ORGANIZATION,
        MTI.TRANSFER_LOCATOR,
        MTI.SHIPMENT_NUMBER,
        MTI.TRANSPORTATION_COST,
        MTI.TRANSFER_COST,
        MTI.TRANSPORTATION_ACCOUNT,
        MTI.FREIGHT_CODE,
        MTI.CONTAINERS,
        MTI.WAYBILL_AIRBILL,
        MTI.EXPECTED_ARRIVAL_DATE,
        MTI.CURRENCY_CODE,
        MTI.CURRENCY_CONVERSION_DATE,
        MTI.CURRENCY_CONVERSION_TYPE,
        MTI.CURRENCY_CONVERSION_RATE,
        MTI.NEW_AVERAGE_COST,
        MTI.VALUE_CHANGE,
        MTI.PERCENTAGE_CHANGE,
        MTI.DEMAND_ID,
        MTI.DEMAND_SOURCE_HEADER_ID,
        MTI.DEMAND_SOURCE_LINE,
        MTI.DEMAND_SOURCE_DELIVERY,
        MTI.DEMAND_CLASS,
        MTI.CUSTOMER_SHIP_ID,
        MTI.TRX_SOURCE_DELIVERY_ID,
        MTI.TRX_SOURCE_LINE_ID,
        MTI.PICKING_LINE_ID,
        MTI.REQUIRED_FLAG,
        MTI.NEGATIVE_REQ_FLAG,
        MTI.REPETITIVE_LINE_ID,
        MTI.PRIMARY_SWITCH,
        MTI.OPERATION_SEQ_NUM,
        MTI.SETUP_TEARDOWN_CODE,
        MTI.SCHEDULE_UPDATE_CODE,
        MTI.DEPARTMENT_ID,
        MTI.EMPLOYEE_CODE,
        MTI.SCHEDULE_ID,
        MTI.WIP_ENTITY_TYPE,
        MTI.ENCUMBRANCE_AMOUNT,
        MTI.ENCUMBRANCE_ACCOUNT,
        MTI.USSGL_TRANSACTION_CODE,
        MTI.SHIPPABLE_FLAG,
        MTI.REQUISITION_LINE_ID,
        MTI.REQUISITION_DISTRIBUTION_ID,
        MTI.SHIP_TO_LOCATION_ID,
        NVL(mti.completion_transaction_id,MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL),
        --J-dev as wip may pass this to us in J. NVL for I
        MTI.ATTRIBUTE_CATEGORY,
        MTI.ATTRIBUTE1,
        MTI.ATTRIBUTE2,
        MTI.ATTRIBUTE3,
        MTI.ATTRIBUTE4,
        MTI.ATTRIBUTE5,
        MTI.ATTRIBUTE6,
        MTI.ATTRIBUTE7,
        MTI.ATTRIBUTE8,
        MTI.ATTRIBUTE9,
        MTI.ATTRIBUTE10,
        MTI.ATTRIBUTE11,
        MTI.ATTRIBUTE12,
        MTI.ATTRIBUTE13,
        MTI.ATTRIBUTE14,
        MTI.ATTRIBUTE15,
        MTI.MOVEMENT_ID,
        MTI.SOURCE_PROJECT_ID,
        MTI.SOURCE_TASK_ID,
        MTI.EXPENDITURE_TYPE,
        MTI.PA_EXPENDITURE_ORG_ID,
        MTI.PROJECT_ID,
        MTI.TASK_ID,
        MTI.TO_PROJECT_ID,
        MTI.TO_TASK_ID,
        'Y',
        NVL(MTI.FINAL_COMPLETION_FLAG,Decode(l_patchset_j,1,MTI.FINAL_COMPLETION_FLAG,'N')),
        MTI.TRANSFER_PERCENTAGE,
        MTI.MATERIAL_ACCOUNT,
        MTI.MATERIAL_OVERHEAD_ACCOUNT,
        MTI.RESOURCE_ACCOUNT,
        MTI.OUTSIDE_PROCESSING_ACCOUNT,
        MTI.OVERHEAD_ACCOUNT,
        MTI.COST_GROUP_ID,
        MTI.FLOW_SCHEDULE,
        MTI.QA_COLLECTION_ID,
        MTI.OVERCOMPLETION_TRANSACTION_QTY, /* Overcompletion Transactions */
        MTI.OVERCOMPLETION_PRIMARY_QTY,
        MTI.OVERCOMPLETION_TRANSACTION_ID,
        MTI.END_ITEM_UNIT_NUMBER,
        BOM.COMMON_BILL_SEQUENCE_ID,
        BOR.COMMON_ROUTING_SEQUENCE_ID,
        ORG_COST_GROUP_ID,               /* PCST */
        COST_TYPE_ID,                    /* PCST */
        MTI.LPN_ID,
        MTI.CONTENT_LPN_ID,
        MTI.TRANSFER_LPN_ID,
        MTI.ORGANIZATION_TYPE,
        MTI.TRANSFER_ORGANIZATION_TYPE,
        MTI.OWNING_ORGANIZATION_ID,
        MTI.OWNING_TP_TYPE,
        MTI.XFR_OWNING_ORGANIZATION_ID,
        MTI.TRANSFER_OWNING_TP_TYPE,
        MTI.PLANNING_ORGANIZATION_ID,
        MTI.PLANNING_TP_TYPE,
        MTI.XFR_PLANNING_ORGANIZATION_ID,
        MTI.TRANSFER_PLANNING_TP_TYPE,
        MTI.TRANSACTION_BATCH_ID,
        MTI.TRANSACTION_BATCH_SEQ,
        MTI.TRANSFER_COST_GROUP_ID,
        Decode(p_validation_level,fnd_api.g_valid_level_none,mti.transaction_mode,INV_TXN_MANAGER_GRP.proc_mode_mti),
-- start of fix for eam
-- added following 4 columns
        MTI.REBUILD_ITEM_ID,
        MTI.REBUILD_ACTIVITY_ID,
        MTI.REBUILD_SERIAL_NUMBER,
        MTI.rebuild_job_name,
          -- end of fix for eam
          mti.kanban_card_id,
          mti.accounting_class,--J dev (class_code in mmtt)
          mti.scheduled_flag,--J dev
          mti.schedule_number,--J dev
          mti.routing_revision_date,--J dev
          mti.move_transaction_id,--J dev
          mti.wip_supply_type,--J-dev
          mti.build_sequence,--J dev
          mti.bom_revision,--J dev
          mti.routing_revision,--J dev
          mti.bom_revision_date,--J dev
          mti.alternate_bom_designator,--J dev
          mti.alternate_routing_designator, --J dev
          mti.SECONDARY_TRANSACTION_QUANTITY , -- INVCONV fabdi
          mti.SECONDARY_UOM_CODE,              -- INVCONV fabdi
    mti.RELIEVE_RESERVATIONS_FLAG,      /*** {{ R12 Enhanced reservations code changes ***/
    mti.RELIEVE_HIGH_LEVEL_RSV_FLAG,    /*** {{ R12 Enhanced reservations code changes ***/
    mti.TRANSFER_PRICE                  -- INVCONV umoogala  For Process-Discrete Transfer Enh.
        FROM MTL_TRANSACTIONS_INTERFACE MTI,
             BOM_BILL_OF_MATERIALS BOM,
             BOM_OPERATIONAL_ROUTINGS BOR
        WHERE TRANSACTION_HEADER_ID = p_header_id
        /*WHERE MTI.ROWID = p_rowid*/--J-dev
        AND PROCESS_FLAG = 1
        AND TRANSACTION_ACTION_ID IN (30,31, 32) /* CFM Scrap Transactions */
        AND BOM.ASSEMBLY_ITEM_ID(+) = MTI.INVENTORY_ITEM_ID
        AND BOM.ORGANIZATION_ID(+) = MTI.ORGANIZATION_ID
        AND ((BOM.ALTERNATE_BOM_DESIGNATOR is null AND
              MTI.ALTERNATE_BOM_DESIGNATOR is null) OR
             (BOM.ALTERNATE_BOM_DESIGNATOR = MTI.ALTERNATE_BOM_DESIGNATOR))
        AND BOR.ASSEMBLY_ITEM_ID(+) = MTI.INVENTORY_ITEM_ID
        AND BOR.ORGANIZATION_ID(+) = MTI.ORGANIZATION_ID
        AND ((BOR.ALTERNATE_ROUTING_DESIGNATOR is null AND
              MTI.ALTERNATE_ROUTING_DESIGNATOR is null) OR
             (BOR.ALTERNATE_ROUTING_DESIGNATOR = MTI.ALTERNATE_ROUTING_DESIGNATOR));


              --J-dev IF WIP J is installed, directly copy all records for
              --action 1, 27, 33, 34. The parnet will be in MTI and not in
              --MMTT
              --In case for I, use the current statement.

              IF (wip_constants.DMF_PATCHSET_LEVEL>= wip_constants.DMF_PATCHSET_J_VALUE) THEN
                 INSERT INTO mtl_material_transactions_temp
                   (
                    TRANSACTION_HEADER_ID,
                    TRANSACTION_TEMP_ID,
                    SOURCE_CODE,
                    SOURCE_LINE_ID,
                    PROCESS_FLAG,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    PROGRAM_APPLICATION_ID,
                    REQUEST_ID,
                    ORGANIZATION_ID,
                    SUBINVENTORY_CODE,
                    LOCATOR_ID,
                    INVENTORY_ITEM_ID,
                    REVISION,
                    TRANSACTION_TYPE_ID,
                    TRANSACTION_ACTION_ID,
                    TRANSACTION_SOURCE_TYPE_ID,
                    TRANSACTION_SOURCE_ID,
                    TRANSACTION_SOURCE_NAME,
                    TRANSACTION_REFERENCE,
                    REASON_ID,
                    TRANSACTION_DATE,
                    ACCT_PERIOD_ID,
                    TRANSACTION_QUANTITY,
                    TRANSACTION_UOM,
                    PRIMARY_QUANTITY,
                    TRANSACTION_COST,
                    DISTRIBUTION_ACCOUNT_ID,
                    TRANSFER_SUBINVENTORY,
                    TRANSFER_ORGANIZATION,
                    TRANSFER_TO_LOCATION,
                    SHIPMENT_NUMBER,
                    TRANSPORTATION_COST,
                    TRANSFER_COST,
                    TRANSPORTATION_ACCOUNT,
                    FREIGHT_CODE,
                   CONTAINERS,
                   WAYBILL_AIRBILL,
                   EXPECTED_ARRIVAL_DATE,
                   CURRENCY_CODE,
                   CURRENCY_CONVERSION_DATE,
                   CURRENCY_CONVERSION_TYPE,
                   CURRENCY_CONVERSION_RATE,
                   NEW_AVERAGE_COST,
                   VALUE_CHANGE,
                   PERCENTAGE_CHANGE,
                   DEMAND_ID,
                   DEMAND_SOURCE_HEADER_ID,
                   DEMAND_SOURCE_LINE,
                   DEMAND_SOURCE_DELIVERY,
                   DEMAND_CLASS,
                   CUSTOMER_SHIP_ID,
                   TRX_SOURCE_DELIVERY_ID,
                   TRX_SOURCE_LINE_ID,
                   PICKING_LINE_ID,
                   REQUIRED_FLAG,
                   NEGATIVE_REQ_FLAG,
                   REPETITIVE_LINE_ID,
                   PRIMARY_SWITCH,
                   OPERATION_SEQ_NUM,
                   SETUP_TEARDOWN_CODE,
                   SCHEDULE_UPDATE_CODE,
                   DEPARTMENT_ID,
                   EMPLOYEE_CODE,
                   SCHEDULE_ID,
                   WIP_ENTITY_TYPE,
                   ENCUMBRANCE_AMOUNT,
                   ENCUMBRANCE_ACCOUNT,
                   USSGL_TRANSACTION_CODE,
                   SHIPPABLE_FLAG,
                   REQUISITION_LINE_ID,
                   REQUISITION_DISTRIBUTION_ID,
                   SHIP_TO_LOCATION,
                   COMPLETION_TRANSACTION_ID,
                   ATTRIBUTE_CATEGORY,
                   ATTRIBUTE1,
                   ATTRIBUTE2,
                   ATTRIBUTE3,
                   ATTRIBUTE4,
                   ATTRIBUTE5,
                   ATTRIBUTE6,
                   ATTRIBUTE7,
                   ATTRIBUTE8,
                   ATTRIBUTE9,
                   ATTRIBUTE10,
                   ATTRIBUTE11,
                   ATTRIBUTE12,
                   ATTRIBUTE13,
                   ATTRIBUTE14,
                   ATTRIBUTE15,
                   MOVEMENT_ID,
                   SOURCE_PROJECT_ID,
                   SOURCE_TASK_ID,
                   EXPENDITURE_TYPE,
                   PA_EXPENDITURE_ORG_ID,
                   PROJECT_ID,
                   TASK_ID,
                   TO_PROJECT_ID,
                   TO_TASK_ID,
                   POSTING_FLAG,
                   FINAL_COMPLETION_FLAG,
                   TRANSFER_PERCENTAGE,
                   MATERIAL_ACCOUNT,
                   MATERIAL_OVERHEAD_ACCOUNT,
                   RESOURCE_ACCOUNT,
                   OUTSIDE_PROCESSING_ACCOUNT,
                   OVERHEAD_ACCOUNT,
                   COST_GROUP_ID,
                   FLOW_SCHEDULE,
                   QA_COLLECTION_ID,
                   OVERCOMPLETION_TRANSACTION_QTY, -- Overcompletion Transactions --
                   OVERCOMPLETION_PRIMARY_QTY,
                   OVERCOMPLETION_TRANSACTION_ID,
                   END_ITEM_UNIT_NUMBER,
                   ORG_COST_GROUP_ID,   -- PCST --
                   COST_TYPE_ID,         /* PCST */
                   LPN_ID,
                   CONTENT_LPN_ID,
                   transfer_lpn_id,
                   organization_type,
                   transfer_organization_type,
                   owning_organization_id,
                   owning_tp_type,
                   xfr_owning_organization_id,
                   transfer_owning_tp_type,
                   planning_organization_id,
                   planning_tp_type,
                   xfr_planning_organization_id,
                   TRANSFER_PLANNING_TP_TYPE,
                   TRANSACTION_BATCH_ID,
                   TRANSACTION_BATCH_SEQ,
                   TRANSFER_COST_GROUP_ID,
                   TRANSACTION_MODE,
                   -- start of fix for eam
                   -- added following 4 columns
                   REBUILD_ITEM_ID,
                   REBUILD_ACTIVITY_ID,
                   REBUILD_SERIAL_NUMBER,
                   rebuild_job_name,
                   kanban_card_id,
                   class_code,--J dev (class_code in mmtt)
                   scheduled_flag,--J dev
                   schedule_number,--J dev
                   routing_revision_date,--J dev
                   move_transaction_id,--J dev
                   wip_supply_type,
                   build_sequence,--J dev
                   bom_revision,--J dev
                   routing_revision,--J dev
                   bom_revision_date,--J dev
                   alternate_bom_designator,--J dev
                   alternate_routing_designator , -- end of fix for eam
                   SECONDARY_TRANSACTION_QUANTITY , -- INVCONV fabdi start
                   SECONDARY_UOM_CODE,              -- INVCONV fabdi end
       RELIEVE_RESERVATIONS_FLAG,       /*** {{ R12 Enhanced reservations code changes ***/
       RELIEVE_HIGH_LEVEL_RSV_FLAG,     /*** {{ R12 Enhanced reservations code changes ***/
       TRANSFER_PRICE                   -- INVCONV umoogala  For Process-Discrete Transfer Enh.
                   )
                   SELECT
                   MTI.TRANSACTION_HEADER_ID,
                   MTI.TRANSACTION_INTERFACE_ID,
                   MTI.SOURCE_CODE,
                   MTI.SOURCE_LINE_ID,
                   'Y',
                   SYSDATE,
                   MTI.CREATED_BY,
                   SYSDATE,
                   MTI.LAST_UPDATED_BY,
                   MTI.LAST_UPDATE_LOGIN,
                   MTI.PROGRAM_ID,
                   SYSDATE,
                   MTI.PROGRAM_APPLICATION_ID,
                   MTI.REQUEST_ID,
                   MTI.ORGANIZATION_ID,
                   MTI.SUBINVENTORY_CODE,
                   MTI.LOCATOR_ID,
                   MTI.INVENTORY_ITEM_ID,
                   MTI.REVISION,
                   MTI.TRANSACTION_TYPE_ID,
                   MTI.TRANSACTION_ACTION_ID,
                   MTI.TRANSACTION_SOURCE_TYPE_ID,
                   MTI.TRANSACTION_SOURCE_ID,
                   MTI.TRANSACTION_SOURCE_NAME,
                   MTI.TRANSACTION_REFERENCE,
                   MTI.REASON_ID,
                   MTI.TRANSACTION_DATE,
                   MTI.ACCT_PERIOD_ID,
                   MTI.TRANSACTION_QUANTITY,
                   MTI.TRANSACTION_UOM,
                   MTI.PRIMARY_QUANTITY,
                   MTI.TRANSACTION_COST,
                   MTI.DISTRIBUTION_ACCOUNT_ID,
                   MTI.TRANSFER_SUBINVENTORY,
                   MTI.TRANSFER_ORGANIZATION,
                   MTI.TRANSFER_LOCATOR,
                   MTI.SHIPMENT_NUMBER,
                   MTI.TRANSPORTATION_COST,
                   MTI.TRANSFER_COST,
                   MTI.TRANSPORTATION_ACCOUNT,
                   MTI.FREIGHT_CODE,
                   MTI.CONTAINERS,
                   MTI.WAYBILL_AIRBILL,
                   MTI.EXPECTED_ARRIVAL_DATE,
                   MTI.CURRENCY_CODE,
                   MTI.CURRENCY_CONVERSION_DATE,
                   MTI.CURRENCY_CONVERSION_TYPE,
                   MTI.CURRENCY_CONVERSION_RATE,
                   MTI.NEW_AVERAGE_COST,
                   MTI.VALUE_CHANGE,
                   MTI.PERCENTAGE_CHANGE,
                   MTI.DEMAND_ID,
                   MTI.DEMAND_SOURCE_HEADER_ID,
                   MTI.DEMAND_SOURCE_LINE,
                   MTI.DEMAND_SOURCE_DELIVERY,
                   MTI.DEMAND_CLASS,
                   MTI.CUSTOMER_SHIP_ID,
                   MTI.TRX_SOURCE_DELIVERY_ID,
                   MTI.TRX_SOURCE_LINE_ID,
                   MTI.PICKING_LINE_ID,
                   MTI.REQUIRED_FLAG,
                   MTI.NEGATIVE_REQ_FLAG,
                   MTI.REPETITIVE_LINE_ID,
                   MTI.PRIMARY_SWITCH,
                   MTI.OPERATION_SEQ_NUM,
                   MTI.SETUP_TEARDOWN_CODE,
                   MTI.SCHEDULE_UPDATE_CODE,
                   MTI.DEPARTMENT_ID,
                   MTI.EMPLOYEE_CODE,
                   MTI.SCHEDULE_ID,
                   MTI.WIP_ENTITY_TYPE,
                   MTI.ENCUMBRANCE_AMOUNT,
                   MTI.ENCUMBRANCE_ACCOUNT,
                   MTI.USSGL_TRANSACTION_CODE,
                   MTI.SHIPPABLE_FLAG,
                   MTI.REQUISITION_LINE_ID,
                   MTI.REQUISITION_DISTRIBUTION_ID,
                   MTI.SHIP_TO_LOCATION_ID,
                   MTI.COMPLETION_TRANSACTION_ID,
                   MTI.ATTRIBUTE_CATEGORY,
                   MTI.ATTRIBUTE1,
                   MTI.ATTRIBUTE2,
                   MTI.ATTRIBUTE3,
                   MTI.ATTRIBUTE4,
                   MTI.ATTRIBUTE5,
                   MTI.ATTRIBUTE6,
                   MTI.ATTRIBUTE7,
                   MTI.ATTRIBUTE8,
                   MTI.ATTRIBUTE9,
                   MTI.ATTRIBUTE10,
                   MTI.ATTRIBUTE11,
                   MTI.ATTRIBUTE12,
                   MTI.ATTRIBUTE13,
                   MTI.ATTRIBUTE14,
                   MTI.ATTRIBUTE15,
                   MTI.MOVEMENT_ID,
                   MTI.SOURCE_PROJECT_ID,
                   MTI.SOURCE_TASK_ID,
                   MTI.EXPENDITURE_TYPE,
                   MTI.PA_EXPENDITURE_ORG_ID,
                   MTI.PROJECT_ID,
                   MTI.TASK_ID,
                   MTI.TO_PROJECT_ID,
                   MTI.TO_TASK_ID,
                   'Y',
                   NVL(MTI.FINAL_COMPLETION_FLAG,Decode(l_patchset_j,1,MTI.FINAL_COMPLETION_FLAG,'N')),
                   MTI.TRANSFER_PERCENTAGE,
                   MTI.MATERIAL_ACCOUNT,
                   MTI.MATERIAL_OVERHEAD_ACCOUNT,
                   MTI.RESOURCE_ACCOUNT,
                   MTI.OUTSIDE_PROCESSING_ACCOUNT,
                   MTI.OVERHEAD_ACCOUNT,
                   MTI.COST_GROUP_ID,
                   MTI.FLOW_SCHEDULE,
                   MTI.QA_COLLECTION_ID,
                   MTI.OVERCOMPLETION_TRANSACTION_QTY, /* Overcompletion Transactions */
                   MTI.OVERCOMPLETION_PRIMARY_QTY,
                   MTI.OVERCOMPLETION_TRANSACTION_ID,
                   MTI.END_ITEM_UNIT_NUMBER,
                   MTI.ORG_COST_GROUP_ID,  /* PCST */
                   MTI.COST_TYPE_ID,        /* PCST */
                   MTI.LPN_ID,
                   MTI.CONTENT_LPN_ID,
                   MTI.TRANSFER_LPN_ID  ,      /* PCST */
                   mti.organization_type,
                   mti.transfer_organization_type,
                   mti.owning_organization_id,
                   mti.owning_tp_type,
                   mti.xfr_owning_organization_id,
                   mti.transfer_owning_tp_type,
                   mti.planning_organization_id,
                   mti.planning_tp_type,
                   mti.xfr_planning_organization_id,
                   mti.TRANSFER_PLANNING_TP_TYPE,
                   MTI.TRANSACTION_BATCH_ID,
                   MTI.TRANSACTION_BATCH_SEQ,
                   MTI.TRANSFER_COST_GROUP_ID,
                   Decode(p_validation_level,fnd_api.g_valid_level_none,mti.transaction_mode,INV_TXN_MANAGER_GRP.proc_mode_mti),
                   -- start of fix for eam
                   -- added following 4 columns
                   MTI.REBUILD_ITEM_ID,
                   MTI.REBUILD_ACTIVITY_ID,
                   MTI.REBUILD_SERIAL_NUMBER,
                   MTI.rebuild_job_name,
                   -- end of fix for eam
                   mti.kanban_card_id,
                   mti.accounting_class,--J dev (class_code in mmtt)
                   mti.scheduled_flag,--J dev
                   mti.schedule_number,--J dev
                   mti.routing_revision_date,--J dev
                   mti.move_transaction_id,--J de
                   mti.wip_supply_type,
                   mti.build_sequence,--J dev
                   mti.bom_revision,--J dev
                   mti.routing_revision,--J dev
                   mti.bom_revision_date,--J dev
                   mti.alternate_bom_designator,--J dev
                   mti.alternate_routing_designator ,
                   mti.SECONDARY_TRANSACTION_QUANTITY , -- INVCONV fabdi start
                   mti.SECONDARY_UOM_CODE, -- INVCONV fabdi end
       mti.RELIEVE_RESERVATIONS_FLAG,       /*** {{ R12 Enhanced reservations code changes ***/
       mti.RELIEVE_HIGH_LEVEL_RSV_FLAG,     /*** {{ R12 Enhanced reservations code changes ***/
       mti.TRANSFER_PRICE                   -- INVCONV umoogala  For Process-Discrete Transfer Enh.
                   FROM MTL_TRANSACTIONS_INTERFACE MTI
                   WHERE MTI.TRANSACTION_HEADER_ID = p_header_id
                   and MTI.PROCESS_FLAG = 1
                   and MTI.TRANSACTION_ACTION_ID IN (1, 27, 33, 34) ;

               ELSE

                 INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP (
                                                             TRANSACTION_HEADER_ID,
                                                             TRANSACTION_TEMP_ID,
                                                             SOURCE_CODE,
                                                             SOURCE_LINE_ID,
                                                             PROCESS_FLAG,
                                                             CREATION_DATE,
                                                             CREATED_BY,
                                                             LAST_UPDATE_DATE,
                                                             LAST_UPDATED_BY,
                                                             LAST_UPDATE_LOGIN,
                                                             PROGRAM_ID,
                                                             PROGRAM_UPDATE_DATE,
                                                             PROGRAM_APPLICATION_ID,
                                                             REQUEST_ID,
                                                             ORGANIZATION_ID,
                                                             SUBINVENTORY_CODE,
                                                             LOCATOR_ID,
                                                             INVENTORY_ITEM_ID,
                                                             REVISION,
                                                             TRANSACTION_TYPE_ID,
                                                             TRANSACTION_ACTION_ID,
                                                             TRANSACTION_SOURCE_TYPE_ID,
                                                             TRANSACTION_SOURCE_ID,
                                                             TRANSACTION_SOURCE_NAME,
                                                             TRANSACTION_REFERENCE,
                                                             REASON_ID,
        TRANSACTION_DATE,
        ACCT_PERIOD_ID,
        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,
        PRIMARY_QUANTITY,
        TRANSACTION_COST,
        DISTRIBUTION_ACCOUNT_ID,
        TRANSFER_SUBINVENTORY,
        TRANSFER_ORGANIZATION,
        TRANSFER_TO_LOCATION,
        SHIPMENT_NUMBER,
        TRANSPORTATION_COST,
        TRANSFER_COST,
        TRANSPORTATION_ACCOUNT,
        FREIGHT_CODE,
        CONTAINERS,
        WAYBILL_AIRBILL,
        EXPECTED_ARRIVAL_DATE,
        CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        DEMAND_ID,
        DEMAND_SOURCE_HEADER_ID,
        DEMAND_SOURCE_LINE,
        DEMAND_SOURCE_DELIVERY,
        DEMAND_CLASS,
        CUSTOMER_SHIP_ID,
        TRX_SOURCE_DELIVERY_ID,
        TRX_SOURCE_LINE_ID,
        PICKING_LINE_ID,
        REQUIRED_FLAG,
        NEGATIVE_REQ_FLAG,
        REPETITIVE_LINE_ID,
        PRIMARY_SWITCH,
        OPERATION_SEQ_NUM,
        SETUP_TEARDOWN_CODE,
        SCHEDULE_UPDATE_CODE,
        DEPARTMENT_ID,
        EMPLOYEE_CODE,
        SCHEDULE_ID,
        WIP_ENTITY_TYPE,
        ENCUMBRANCE_AMOUNT,
        ENCUMBRANCE_ACCOUNT,
        USSGL_TRANSACTION_CODE,
        SHIPPABLE_FLAG,
        REQUISITION_LINE_ID,
        REQUISITION_DISTRIBUTION_ID,
        SHIP_TO_LOCATION,
        COMPLETION_TRANSACTION_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        MOVEMENT_ID,
        SOURCE_PROJECT_ID,
        SOURCE_TASK_ID,
        EXPENDITURE_TYPE,
        PA_EXPENDITURE_ORG_ID,
        PROJECT_ID,
        TASK_ID,
        TO_PROJECT_ID,
        TO_TASK_ID,
        POSTING_FLAG,
        FINAL_COMPLETION_FLAG,
        TRANSFER_PERCENTAGE,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        RESOURCE_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        COST_GROUP_ID,
        FLOW_SCHEDULE,
        QA_COLLECTION_ID,
        OVERCOMPLETION_TRANSACTION_QTY, -- Overcompletion Transactions --
        OVERCOMPLETION_PRIMARY_QTY,
        OVERCOMPLETION_TRANSACTION_ID,
        END_ITEM_UNIT_NUMBER,
        ORG_COST_GROUP_ID,   -- PCST --
        COST_TYPE_ID,         /* PCST */
        LPN_ID,
        CONTENT_LPN_ID,
        transfer_lpn_id,
        organization_type,
        transfer_organization_type,
        owning_organization_id,
        owning_tp_type,
        xfr_owning_organization_id,
        transfer_owning_tp_type,
        planning_organization_id,
        planning_tp_type,
        xfr_planning_organization_id,
        TRANSFER_PLANNING_TP_TYPE,
        TRANSACTION_BATCH_ID,
        TRANSACTION_BATCH_SEQ,
        TRANSFER_COST_GROUP_ID,
        TRANSACTION_MODE,
-- start of fix for eam
-- added following 4 columns
        REBUILD_ITEM_ID,
        REBUILD_ACTIVITY_ID,
        REBUILD_SERIAL_NUMBER,
          rebuild_job_name,
                   kanban_card_id,
                   build_sequence,--J dev
          bom_revision,--J dev
          routing_revision,--J dev
          bom_revision_date,--J dev
          alternate_bom_designator,--J dev
          alternate_routing_designator,-- end of fix for eam
          SECONDARY_TRANSACTION_QUANTITY, -- INVCONV fabdi
          SECONDARY_UOM_CODE, -- INVCONV fabdi end
    RELIEVE_RESERVATIONS_FLAG,      /*** {{ R12 Enhanced reservations code changes ***/
    RELIEVE_HIGH_LEVEL_RSV_FLAG,    /*** {{ R12 Enhanced reservations code changes ***/
    TRANSFER_PRICE                  -- INVCONV umoogala  For Process-Discrete Transfer Enh.
          )
    SELECT
        MTI.TRANSACTION_HEADER_ID,
        MTI.TRANSACTION_INTERFACE_ID,
        MTI.SOURCE_CODE,
        MTI.SOURCE_LINE_ID,
        'Y',
        SYSDATE,
        MTI.CREATED_BY,
        SYSDATE,
        MTI.LAST_UPDATED_BY,
        MTI.LAST_UPDATE_LOGIN,
        MTI.PROGRAM_ID,
        SYSDATE,
        MTI.PROGRAM_APPLICATION_ID,
        MTI.REQUEST_ID,
        MTI.ORGANIZATION_ID,
        MTI.SUBINVENTORY_CODE,
        MTI.LOCATOR_ID,
        MTI.INVENTORY_ITEM_ID,
        MTI.REVISION,
        MTI.TRANSACTION_TYPE_ID,
        MTI.TRANSACTION_ACTION_ID,
        MTI.TRANSACTION_SOURCE_TYPE_ID,
        MTI.TRANSACTION_SOURCE_ID,
        MTI.TRANSACTION_SOURCE_NAME,
        MTI.TRANSACTION_REFERENCE,
        MTI.REASON_ID,
        MTI.TRANSACTION_DATE,
        MTI.ACCT_PERIOD_ID,
        MTI.TRANSACTION_QUANTITY,
        MTI.TRANSACTION_UOM,
        MTI.PRIMARY_QUANTITY,
        MTI.TRANSACTION_COST,
        MTI.DISTRIBUTION_ACCOUNT_ID,
        MTI.TRANSFER_SUBINVENTORY,
        MTI.TRANSFER_ORGANIZATION,
        MTI.TRANSFER_LOCATOR,
        MTI.SHIPMENT_NUMBER,
        MTI.TRANSPORTATION_COST,
        MTI.TRANSFER_COST,
        MTI.TRANSPORTATION_ACCOUNT,
        MTI.FREIGHT_CODE,
        MTI.CONTAINERS,
        MTI.WAYBILL_AIRBILL,
        MTI.EXPECTED_ARRIVAL_DATE,
        MTI.CURRENCY_CODE,
        MTI.CURRENCY_CONVERSION_DATE,
        MTI.CURRENCY_CONVERSION_TYPE,
        MTI.CURRENCY_CONVERSION_RATE,
        MTI.NEW_AVERAGE_COST,
        MTI.VALUE_CHANGE,
        MTI.PERCENTAGE_CHANGE,
        MTI.DEMAND_ID,
        MTI.DEMAND_SOURCE_HEADER_ID,
        MTI.DEMAND_SOURCE_LINE,
        MTI.DEMAND_SOURCE_DELIVERY,
        MTI.DEMAND_CLASS,
        MTI.CUSTOMER_SHIP_ID,
        MTI.TRX_SOURCE_DELIVERY_ID,
        MTI.TRX_SOURCE_LINE_ID,
        MTI.PICKING_LINE_ID,
        MTI.REQUIRED_FLAG,
        MTI.NEGATIVE_REQ_FLAG,
        MTI.REPETITIVE_LINE_ID,
        MTI.PRIMARY_SWITCH,
        MTI.OPERATION_SEQ_NUM,
        MTI.SETUP_TEARDOWN_CODE,
        MTI.SCHEDULE_UPDATE_CODE,
        MTI.DEPARTMENT_ID,
        MTI.EMPLOYEE_CODE,
        MTI.SCHEDULE_ID,
        MTI.WIP_ENTITY_TYPE,
        MTI.ENCUMBRANCE_AMOUNT,
        MTI.ENCUMBRANCE_ACCOUNT,
        MTI.USSGL_TRANSACTION_CODE,
        MTI.SHIPPABLE_FLAG,
        MTI.REQUISITION_LINE_ID,
        MTI.REQUISITION_DISTRIBUTION_ID,
        MTI.SHIP_TO_LOCATION_ID,
        MMTT.COMPLETION_TRANSACTION_ID,
        MTI.ATTRIBUTE_CATEGORY,
        MTI.ATTRIBUTE1,
        MTI.ATTRIBUTE2,
        MTI.ATTRIBUTE3,
        MTI.ATTRIBUTE4,
        MTI.ATTRIBUTE5,
        MTI.ATTRIBUTE6,
        MTI.ATTRIBUTE7,
        MTI.ATTRIBUTE8,
        MTI.ATTRIBUTE9,
        MTI.ATTRIBUTE10,
        MTI.ATTRIBUTE11,
        MTI.ATTRIBUTE12,
        MTI.ATTRIBUTE13,
        MTI.ATTRIBUTE14,
        MTI.ATTRIBUTE15,
        MTI.MOVEMENT_ID,
        MTI.SOURCE_PROJECT_ID,
        MTI.SOURCE_TASK_ID,
        MTI.EXPENDITURE_TYPE,
        MTI.PA_EXPENDITURE_ORG_ID,
        MTI.PROJECT_ID,
        MTI.TASK_ID,
        MTI.TO_PROJECT_ID,
        MTI.TO_TASK_ID,
        'Y',
         NVL(MTI.FINAL_COMPLETION_FLAG,
             Decode(l_patchset_j,1,MTI.FINAL_COMPLETION_FLAG,'N')),
        MTI.TRANSFER_PERCENTAGE,
        MTI.MATERIAL_ACCOUNT,
        MTI.MATERIAL_OVERHEAD_ACCOUNT,
        MTI.RESOURCE_ACCOUNT,
        MTI.OUTSIDE_PROCESSING_ACCOUNT,
        MTI.OVERHEAD_ACCOUNT,
        MTI.COST_GROUP_ID,
        MTI.FLOW_SCHEDULE,
        MTI.QA_COLLECTION_ID,
        MTI.OVERCOMPLETION_TRANSACTION_QTY, /* Overcompletion Transactions */
        MTI.OVERCOMPLETION_PRIMARY_QTY,
        MTI.OVERCOMPLETION_TRANSACTION_ID,
        MTI.END_ITEM_UNIT_NUMBER,
        MTI.ORG_COST_GROUP_ID,  /* PCST */
        MTI.COST_TYPE_ID,        /* PCST */
        MTI.LPN_ID,
        MTI.CONTENT_LPN_ID,
          MTI.TRANSFER_LPN_ID  ,      /* PCST */
          mti.organization_type,
          mti.transfer_organization_type,
          mti.owning_organization_id,
          mti.owning_tp_type,
          mti.xfr_owning_organization_id,
          mti.transfer_owning_tp_type,
          mti.planning_organization_id,
          mti.planning_tp_type,
          mti.xfr_planning_organization_id,
          mti.TRANSFER_PLANNING_TP_TYPE,
          MTI.TRANSACTION_BATCH_ID,
          MTI.TRANSACTION_BATCH_SEQ,
          MTI.TRANSFER_COST_GROUP_ID,
          Decode(p_validation_level,fnd_api.g_valid_level_none,mti.transaction_mode,INV_TXN_MANAGER_GRP.proc_mode_mti),
-- start of fix for eam
-- added following 4 columns
          MTI.REBUILD_ITEM_ID,
          MTI.REBUILD_ACTIVITY_ID,
          MTI.REBUILD_SERIAL_NUMBER,
          MTI.rebuild_job_name,
          -- end of fix for eam
                   mti.kanban_card_id,
                   mti.build_sequence,--J dev
          mti.bom_revision,--J dev
          mti.routing_revision,--J dev
          mti.bom_revision_date,--J dev
          mti.alternate_bom_designator,--J dev
          mti.alternate_routing_designator,
          mti.SECONDARY_TRANSACTION_QUANTITY, -- INVCONV fabdi
          mti.SECONDARY_UOM_CODE,             -- INVCONV fabdi end
    mti.RELIEVE_RESERVATIONS_FLAG,      /*** {{ R12 Enhanced reservations code changes ***/
    mti.RELIEVE_HIGH_LEVEL_RSV_FLAG,    /*** {{ R12 Enhanced reservations code changes ***/
    mti.TRANSFER_PRICE                  -- INVCONV umoogala  For Process-Discrete Transfer Enh.
        FROM MTL_TRANSACTIONS_INTERFACE MTI,
             MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
        WHERE MTI.TRANSACTION_HEADER_ID = p_header_id
       /* WHERE MTI.ROWID = p_rowid J-dev*/
        and MTI.PROCESS_FLAG = 1
        and MTI.TRANSACTION_ACTION_ID IN (1, 27, 33, 34)
        and MTI.PARENT_ID = MMTT.TRANSACTION_TEMP_ID
        and MTI.TRANSACTION_HEADER_ID = MMTT.TRANSACTION_HEADER_ID;
              END IF;
     END IF;
    END IF;--J-dev


    IF (l_debug = 1) THEN
       inv_log_util.trace('going to insert lot'||p_header_id,'INV_TXN_MANAGER_GRP','9');
    END IF;

    /* Inserting LOT transactions */
        INSERT INTO MTL_TRANSACTION_LOTS_TEMP
            (TRANSACTION_TEMP_ID,
             LOT_NUMBER,
             LOT_EXPIRATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             REQUEST_ID,
             PRIMARY_QUANTITY,
             TRANSACTION_QUANTITY,
             serial_transaction_temp_id,
                   LOT_ATTRIBUTE_CATEGORY,   --Bug #3841935
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
             N_ATTRIBUTE9,
             n_attribute10,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             ATTRIBUTE_CATEGORY ,
             group_header_id,--added for J
             DESCRIPTION,
             VENDOR_NAME,
             SUPPLIER_LOT_NUMBER,
             ORIGINATION_DATE,
             DATE_CODE,
             GRADE_CODE,
             CHANGE_DATE,
             MATURITY_DATE,
             STATUS_ID,
             RETEST_DATE,
             AGE,
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
             VENDOR_ID,
             TERRITORY_CODE,
             PARENT_LOT_NUMBER , -- INVCONV start fabdi
             ORIGINATION_TYPE  ,
             EXPIRATION_ACTION_DATE  ,
             EXPIRATION_ACTION_CODE,
             HOLD_DATE ,
             REASON_ID,
             SECONDARY_QUANTITY, -- INVCONV start fabdi
             parent_object_type,       --R12 Genealogy enhancements
             parent_object_id,         --R12 Genealogy enhancements
             parent_object_number,     --R12 Genealogy enhancements
             parent_item_id,           --R12 Genealogy enhancements
             parent_object_type2,      --R12 Genealogy enhancements
             parent_object_id2,        --R12 Genealogy enhancements
             parent_object_number2     --R12 Genealogy enhancements
            )
         SELECT
             TRANSACTION_INTERFACE_ID,
             ltrim(rtrim(LOT_NUMBER)),                /*Bug 6390860 added ltrim, rtrim*/
             LOT_EXPIRATION_DATE,
             LAST_UPDATED_BY,
             SYSDATE,
             SYSDATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             SYSDATE,
             REQUEST_ID,
             PRIMARY_QUANTITY,
             TRANSACTION_QUANTITY,
             serial_transaction_temp_id,
             LOT_ATTRIBUTE_CATEGORY,
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
             N_ATTRIBUTE9,
             n_attribute10,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             ATTRIBUTE_CATEGORY ,
             p_header_id ,--J dev corresponds to the header_id
             DESCRIPTION,
             VENDOR_NAME,
             SUPPLIER_LOT_NUMBER,
             ORIGINATION_DATE,
             DATE_CODE,
             GRADE_CODE,
             CHANGE_DATE,
             MATURITY_DATE,
             STATUS_ID,
             RETEST_DATE,
             AGE,
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
             VENDOR_ID,
             TERRITORY_CODE,
             PARENT_LOT_NUMBER , -- INVCONV start fabdi
             ORIGINATION_TYPE  ,
             EXPIRATION_ACTION_DATE  ,
             EXPIRATION_ACTION_CODE,
             HOLD_DATE ,
             REASON_ID,
             SECONDARY_TRANSACTION_QUANTITY,    -- INVCONV start fabdi
             parent_object_type,   --R12 Genealogy enhancements
             parent_object_id,   --R12 Genealogy enhancements
             parent_object_number,   --R12 Genealogy enhancements
             parent_item_id,   --R12 Genealogy enhancements
             parent_object_type2,   --R12 Genealogy enhancements
             parent_object_id2,   --R12 Genealogy enhancements
             parent_object_number2   --R12 Genealogy enhancements
        FROM MTL_TRANSACTION_LOTS_INTERFACE
       WHERE TRANSACTION_INTERFACE_ID IN (
             SELECT TRANSACTION_INTERFACE_ID
               FROM MTL_TRANSACTIONS_INTERFACE MTI
              WHERE mti.TRANSACTION_HEADER_ID = p_header_id
              /*WHERE MTI.ROWID = p_rowid J-dev*/
                AND mti.TRANSACTION_INTERFACE_ID IS NOT NULL
                AND mti.PROCESS_FLAG = 1
                AND transaction_type_id NOT IN           /*OSFM Support for Lot Serialized Items*/
                        (inv_globals.g_type_inv_lot_split
                       , inv_globals.g_type_inv_lot_merge
                       , inv_globals.g_type_inv_lot_translate
                        ));



        INSERT INTO MTL_SERIAL_NUMBERS_TEMP
            (TRANSACTION_TEMP_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             VENDOR_SERIAL_NUMBER,
             VENDOR_LOT_NUMBER,
             FM_SERIAL_NUMBER,
             TO_SERIAL_NUMBER,
             parent_serial_number,
             SERIAL_ATTRIBUTE_CATEGORY,  --Bug #3841935
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
             N_ATTRIBUTE9,
             n_attribute10,
             group_header_id, --added for J
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
             attribute15,
             status_id,     --Bug 5023244
             parent_object_type,   --R12 Genealogy enhancements
             parent_object_id,   --R12 Genealogy enhancements
             parent_object_number,   --R12 Genealogy enhancements
             parent_item_id,   --R12 Genealogy enhancements
             parent_object_type2,   --R12 Genealogy enhancements
             parent_object_id2,   --R12 Genealogy enhancements
             parent_object_number2)  --R12 Genealogy enhancements
         SELECT
             TRANSACTION_INTERFACE_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             VENDOR_SERIAL_NUMBER,
             VENDOR_LOT_NUMBER,
             ltrim(rtrim(FM_SERIAL_NUMBER)),/*Bug 4764048 added ltrim,rtrim*/
             ltrim(rtrim(TO_SERIAL_NUMBER)),/*Bug 4764048 added ltrim,rtrim*/
             parent_serial_number,
             SERIAL_ATTRIBUTE_CATEGORY,
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
             N_ATTRIBUTE9,
             n_attribute10,
             p_header_id,
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
             attribute15,
             status_id,    --Bug 5023244
             parent_object_type,   --R12 Genealogy enhancements
             parent_object_id,   --R12 Genealogy enhancements
             parent_object_number,   --R12 Genealogy enhancements
             parent_item_id,   --R12 Genealogy enhancements
             parent_object_type2,   --R12 Genealogy enhancements
             parent_object_id2,   --R12 Genealogy enhancements
             parent_object_number2   --R12 Genealogy enhancements
        FROM MTL_SERIAL_NUMBERS_INTERFACE
       WHERE (TRANSACTION_INTERFACE_ID IN (
             SELECT TRANSACTION_INTERFACE_ID
               FROM MTL_TRANSACTIONS_INTERFACE MTI
              WHERE TRANSACTION_HEADER_ID = p_header_id
              /*WHERE MTI.ROWID = p_rowid*/--J-dev
                AND TRANSACTION_INTERFACE_ID IS NOT NULL
                AND PROCESS_FLAG = 1
                AND transaction_type_id NOT IN
                         (inv_globals.g_type_inv_lot_split
                        , inv_globals.g_type_inv_lot_merge
                        , inv_globals.g_type_inv_lot_translate
                         )
              UNION ALL
              SELECT SERIAL_TRANSACTION_TEMP_ID
               FROM MTL_TRANSACTION_LOTS_INTERFACE
               WHERE TRANSACTION_INTERFACE_ID IN (
                     SELECT TRANSACTION_INTERFACE_ID
                      FROM MTL_TRANSACTIONS_INTERFACE
                      WHERE TRANSACTION_HEADER_ID = p_header_id
                      /*WHERE rowid = p_rowid J-dev*/
                      AND TRANSACTION_INTERFACE_ID IS NOT NULL
                      AND PROCESS_FLAG = 1
                      AND transaction_type_id NOT IN
                                  (inv_globals.g_type_inv_lot_split
                                 , inv_globals.g_type_inv_lot_merge
                                 , inv_globals.g_type_inv_lot_translate
                                  )))
              );

    RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
    IF (l_debug = 1) THEN
       inv_log_util.trace('Error in tmpinsert: sqlerrm : ' || substr(sqlerrm, 1, 200),
            'INV_TXN_MANAGER_GRP','9');
    END IF;
    RETURN FALSE;

END tmpinsert;


  /*Bug:5408823. The following procedure populates the column name, data type
    and length of all the Serial Attributes into global table g_lot_ser_attr_tbl
    which will be later used in procedure get_serial_attr_record. */

  PROCEDURE get_serial_attr_table
  IS
  l_lot_ser_attr_tbl   inv_lot_sel_attr.lot_sel_attributes_tbl_type;
  l_debug              NUMBER
                             := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

  BEGIN

    inv_log_util.trace('Before setting all the column names and types' , 'get_serial_attr_table',9);


    l_lot_ser_attr_tbl (1).column_name :=  'SERIAL_ATTRIBUTE_CATEGORY';
    l_lot_ser_attr_tbl (1).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (1).column_length := 30;
    l_lot_ser_attr_tbl (2).column_name :=  'C_ATTRIBUTE1';
    l_lot_ser_attr_tbl (2).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (2).column_length := 150;
    l_lot_ser_attr_tbl (3).column_name :=  'C_ATTRIBUTE2' ;
    l_lot_ser_attr_tbl (3).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (3).column_length := 150;
    l_lot_ser_attr_tbl (4).column_name :=  'C_ATTRIBUTE3';
    l_lot_ser_attr_tbl (4).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (4).column_length := 150;
    l_lot_ser_attr_tbl (5).column_name :=  'C_ATTRIBUTE4';
    l_lot_ser_attr_tbl (5).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (5).column_length := 150;
    l_lot_ser_attr_tbl (6).column_name :=  'C_ATTRIBUTE5';
    l_lot_ser_attr_tbl (6).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (6).column_length := 150;
    l_lot_ser_attr_tbl (7).column_name :=  'C_ATTRIBUTE6';
    l_lot_ser_attr_tbl (7).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (7).column_length := 150;
    l_lot_ser_attr_tbl (8).column_name :=  'C_ATTRIBUTE7';
    l_lot_ser_attr_tbl (8).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (8).column_length := 150;
    l_lot_ser_attr_tbl (9).column_name :=  'C_ATTRIBUTE8';
    l_lot_ser_attr_tbl (9).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (9).column_length := 150;
    l_lot_ser_attr_tbl (10).column_name :=  'C_ATTRIBUTE9';
    l_lot_ser_attr_tbl (10).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (10).column_length := 150;
    l_lot_ser_attr_tbl (11).column_name :=  'C_ATTRIBUTE10';
    l_lot_ser_attr_tbl (11).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (11).column_length := 150;
    l_lot_ser_attr_tbl (12).column_name := 'C_ATTRIBUTE11';
    l_lot_ser_attr_tbl (12).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (12).column_length := 150;
    l_lot_ser_attr_tbl (13).column_name := 'C_ATTRIBUTE12';
    l_lot_ser_attr_tbl (13).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (13).column_length := 150;
    l_lot_ser_attr_tbl (14).column_name := 'C_ATTRIBUTE13';
    l_lot_ser_attr_tbl (14).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (14).column_length := 150;
    l_lot_ser_attr_tbl (15).column_name := 'C_ATTRIBUTE14';
    l_lot_ser_attr_tbl (15).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (15).column_length := 150;
    l_lot_ser_attr_tbl (16).column_name := 'C_ATTRIBUTE15';
    l_lot_ser_attr_tbl (16).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (16).column_length := 150;
    l_lot_ser_attr_tbl (17).column_name := 'C_ATTRIBUTE16' ;
    l_lot_ser_attr_tbl (17).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (17).column_length := 150;
    l_lot_ser_attr_tbl (18).column_name := 'C_ATTRIBUTE17';
    l_lot_ser_attr_tbl (18).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (18).column_length := 150;
    l_lot_ser_attr_tbl (19).column_name := 'C_ATTRIBUTE18';
    l_lot_ser_attr_tbl (19).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (19).column_length := 150;
    l_lot_ser_attr_tbl (20).column_name := 'C_ATTRIBUTE19';
    l_lot_ser_attr_tbl (20).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (20).column_length := 150;
    l_lot_ser_attr_tbl (21).column_name := 'C_ATTRIBUTE20';
    l_lot_ser_attr_tbl (21).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (21).column_length := 150;
    l_lot_ser_attr_tbl (22).column_name := 'D_ATTRIBUTE1';
    l_lot_ser_attr_tbl (22).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (22).column_length := 11;
    l_lot_ser_attr_tbl (23).column_name := 'D_ATTRIBUTE2';
    l_lot_ser_attr_tbl (23).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (23).column_length := 11;
    l_lot_ser_attr_tbl (24).column_name := 'D_ATTRIBUTE3';
    l_lot_ser_attr_tbl (24).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (24).column_length := 11;
    l_lot_ser_attr_tbl (25).column_name := 'D_ATTRIBUTE4';
    l_lot_ser_attr_tbl (25).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (25).column_length := 11;
    l_lot_ser_attr_tbl (26).column_name := 'D_ATTRIBUTE5';
    l_lot_ser_attr_tbl (26).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (26).column_length := 11;
    l_lot_ser_attr_tbl (27).column_name := 'D_ATTRIBUTE6';
    l_lot_ser_attr_tbl (27).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (27).column_length := 11;
    l_lot_ser_attr_tbl (28).column_name := 'D_ATTRIBUTE7';
    l_lot_ser_attr_tbl (28).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (28).column_length := 11;
    l_lot_ser_attr_tbl (29).column_name := 'D_ATTRIBUTE8';
    l_lot_ser_attr_tbl (29).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (29).column_length := 11;
    l_lot_ser_attr_tbl (30).column_name := 'D_ATTRIBUTE9';
    l_lot_ser_attr_tbl (30).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (30).column_length := 11;
    l_lot_ser_attr_tbl (31).column_name := 'D_ATTRIBUTE10';
    l_lot_ser_attr_tbl (31).column_type  :=  'DATE';
    l_lot_ser_attr_tbl (31).column_length := 11;
    l_lot_ser_attr_tbl (32).column_name := 'N_ATTRIBUTE1';
    l_lot_ser_attr_tbl (32).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (32).column_length := 38;
    l_lot_ser_attr_tbl (33).column_name := 'N_ATTRIBUTE2';
    l_lot_ser_attr_tbl (33).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (33).column_length := 38;
    l_lot_ser_attr_tbl (34).column_name := 'N_ATTRIBUTE3';
    l_lot_ser_attr_tbl (34).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (34).column_length := 38;
    l_lot_ser_attr_tbl (35).column_name := 'N_ATTRIBUTE4';
    l_lot_ser_attr_tbl (35).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (35).column_length := 38;
    l_lot_ser_attr_tbl (36).column_name := 'N_ATTRIBUTE5';
    l_lot_ser_attr_tbl (36).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (36).column_length := 38;
    l_lot_ser_attr_tbl (37).column_name := 'N_ATTRIBUTE6';
    l_lot_ser_attr_tbl (37).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (37).column_length := 38;
    l_lot_ser_attr_tbl (38).column_name := 'N_ATTRIBUTE7';
    l_lot_ser_attr_tbl (38).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (38).column_length := 38;
    l_lot_ser_attr_tbl (39).column_name := 'N_ATTRIBUTE8';
    l_lot_ser_attr_tbl (39).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (39).column_length := 38;
    l_lot_ser_attr_tbl (40).column_name := 'N_ATTRIBUTE9';
    l_lot_ser_attr_tbl (40).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (40).column_length := 38;
    l_lot_ser_attr_tbl (41).column_name := 'N_ATTRIBUTE10';
    l_lot_ser_attr_tbl (41).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (41).column_length := 38;
    l_lot_ser_attr_tbl (42).column_name := 'TERRITORY_CODE';
    l_lot_ser_attr_tbl (42).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (42).column_length := 30;
    l_lot_ser_attr_tbl (43).column_name := 'TIME_SINCE_NEW';
    l_lot_ser_attr_tbl (43).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (43).column_length := 38;
    l_lot_ser_attr_tbl (44).column_name := 'CYCLES_SINCE_NEW';
    l_lot_ser_attr_tbl (44).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (44).column_length := 38;
    l_lot_ser_attr_tbl (45).column_name := 'TIME_SINCE_OVERHAUL';
    l_lot_ser_attr_tbl (45).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (45).column_length := 38;
    l_lot_ser_attr_tbl (46).column_name := 'CYCLES_SINCE_OVERHAUL';
    l_lot_ser_attr_tbl (46).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (46).column_length := 38;
    l_lot_ser_attr_tbl (47).column_name := 'TIME_SINCE_REPAIR';
    l_lot_ser_attr_tbl (47).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (47).column_length := 38;
    l_lot_ser_attr_tbl (48).column_name := 'CYCLES_SINCE_REPAIR';
    l_lot_ser_attr_tbl (48).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (48).column_length := 38;
    l_lot_ser_attr_tbl (49).column_name := 'TIME_SINCE_VISIT';
    l_lot_ser_attr_tbl (49).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (49).column_length := 38;
    l_lot_ser_attr_tbl (50).column_name := 'CYCLES_SINCE_VISIT';
    l_lot_ser_attr_tbl (50).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (50).column_length := 38;
    l_lot_ser_attr_tbl (51).column_name := 'TIME_SINCE_MARK';
    l_lot_ser_attr_tbl (51).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (51).column_length := 38;
    l_lot_ser_attr_tbl (52).column_name := 'CYCLES_SINCE_MARK';
    l_lot_ser_attr_tbl (52).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (52).column_length := 38;
    l_lot_ser_attr_tbl (53).column_name := 'NUMBER_OF_REPAIRS';
    l_lot_ser_attr_tbl (53).column_type  :=  'NUMBER';
    l_lot_ser_attr_tbl (53).column_length := 38;
    l_lot_ser_attr_tbl (54).column_name := 'ATTRIBUTE_CATEGORY';
    l_lot_ser_attr_tbl (54).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (54).column_length := 30;
    l_lot_ser_attr_tbl (55).column_name := 'ATTRIBUTE1';
    l_lot_ser_attr_tbl (55).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (55).column_length := 150;
    l_lot_ser_attr_tbl (56).column_name := 'ATTRIBUTE2';
    l_lot_ser_attr_tbl (56).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (56).column_length := 150;
    l_lot_ser_attr_tbl (57).column_name := 'ATTRIBUTE3';
    l_lot_ser_attr_tbl (57).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (57).column_length := 150;
    l_lot_ser_attr_tbl (58).column_name := 'ATTRIBUTE4';
    l_lot_ser_attr_tbl (58).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (58).column_length := 150;
    l_lot_ser_attr_tbl (59).column_name := 'ATTRIBUTE5';
    l_lot_ser_attr_tbl (59).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (59).column_length := 150;
    l_lot_ser_attr_tbl (60).column_name := 'ATTRIBUTE6';
    l_lot_ser_attr_tbl (60).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (60).column_length := 150;
    l_lot_ser_attr_tbl (61).column_name := 'ATTRIBUTE7';
    l_lot_ser_attr_tbl (61).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (61).column_length := 150;
    l_lot_ser_attr_tbl (62).column_name := 'ATTRIBUTE8';
    l_lot_ser_attr_tbl (62).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (62).column_length := 150;
    l_lot_ser_attr_tbl (63).column_name := 'ATTRIBUTE9';
    l_lot_ser_attr_tbl (63).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (63).column_length := 150;
    l_lot_ser_attr_tbl (64).column_name := 'ATTRIBUTE10';
    l_lot_ser_attr_tbl (64).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (64).column_length := 150;
    l_lot_ser_attr_tbl (65).column_name := 'ATTRIBUTE11';
    l_lot_ser_attr_tbl (65).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (65).column_length := 150;
    l_lot_ser_attr_tbl (66).column_name := 'ATTRIBUTE12';
    l_lot_ser_attr_tbl (66).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (66).column_length := 150;
    l_lot_ser_attr_tbl (67).column_name := 'ATTRIBUTE13';
    l_lot_ser_attr_tbl (67).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (67).column_length := 150;
    l_lot_ser_attr_tbl (68).column_name := 'ATTRIBUTE14';
    l_lot_ser_attr_tbl (68).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (68).column_length := 150;
    l_lot_ser_attr_tbl (69).column_name := 'ATTRIBUTE15';
    l_lot_ser_attr_tbl (69).column_type  :=  'VARCHAR2';
    l_lot_ser_attr_tbl (69).column_length := 150;

    g_lot_ser_attr_tbl  := l_lot_ser_attr_tbl;


    inv_log_util.trace('After setting all the column names and types' , 'get_serial_attr_table',9);

  EXCEPTION
    WHEN OTHERS
    THEN

      IF (l_debug = 1)
      THEN
        inv_log_util.trace('In Exception in get_serial_attr_table' , 'get_serial_attr_table',9);
      END IF;

  END get_serial_attr_table;

  /*****************************************************************************
   *Private procedure used in tmpinsert2(). This is used to get all the serial *
   *attributes from MSNI in x_lot_ser_attr_tbl which is then used for attr val.*
   *****************************************************************************/

  PROCEDURE get_serial_attr_record (
    x_lot_ser_attr_tbl           OUT NOCOPY   inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_transaction_interface_id   IN       NUMBER
  , p_fm_serial_number           IN VARCHAR2
  , p_to_serial_number           IN VARCHAR2
  , p_serial_number              IN VARCHAR2
  , p_item_id                    IN NUMBER
  , p_org_id                     IN NUMBER
  , p_organization_id            IN       NUMBER
  , p_inventory_item_id          IN       NUMBER
  )

  IS
    /*Bug:5408823.Commented out the following code as the code to
      populate metadata of the serial attributes is moved to
      get_serial_attr_table.
    */
    /*l_app_owner_schema   VARCHAR2 (30);
    l_app_status         VARCHAR2 (1);
    l_app_industry       VARCHAR2 (1);
    l_app_info_status    BOOLEAN
      := fnd_installation.get_app_info (application_short_name     => 'INV'
                                      , status                     => l_app_status
                                      , industry                   => l_app_industry
                                      , oracle_schema              => l_app_owner_schema
                                       );

    CURSOR serial_column_csr (p_table_name VARCHAR2)
    IS
      SELECT   column_name
             , data_type
             , data_length
          FROM all_tab_columns
         WHERE table_name = UPPER (p_table_name)
           AND owner = l_app_owner_schema
           Bug:4724150. Commented the following condition 1 as the attribute
             columns becomes out of range of 20 to 91 when some extraneous attributes are added
           --AND column_id BETWEEN 20 AND 101      --attribute columns.
           AND column_name NOT IN ('STATUS_ID','STATUS_NAME', 'ORIGINATION_DATE')
      ORDER BY column_id;
      */

    l_column_id          NUMBER;
    l_lot_ser_attr_tbl   inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_column_idx         NUMBER;
    --l_select_stmt        LONG;
    l_sql_p              INTEGER;
    l_rows_processed     INTEGER;
    l_line               NUMBER;
    l_stmt               LONG;
    l_debug              NUMBER
                             := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN

    /*Bug:5408823. Copying the global table which is populated in get_serial_attr_table procedure. */
    l_lot_ser_attr_tbl := g_lot_ser_attr_tbl;
    l_sql_p := NULL;
    l_rows_processed := NULL;
    l_line := 1;


    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 10', 'get_serial_attr_record');
    END IF;

    /*Bug:5408823. Commenting the following code which popultes the column name,
      type and length of Serial Attributes, as this is being done in seperate procedure
      get_serial_attr_table. */

    /*FOR l_lot_ser_column_csr IN
      serial_column_csr ('MTL_SERIAL_NUMBERS_INTERFACE')
    LOOP
      l_column_idx := l_column_idx + 1;
      l_lot_ser_attr_tbl (l_column_idx).column_name :=
                                             l_lot_ser_column_csr.column_name;
      l_lot_ser_attr_tbl (l_column_idx).column_type :=
                                               l_lot_ser_column_csr.data_type;

      IF UPPER (l_lot_ser_column_csr.data_type) = 'DATE'
      THEN
        l_lot_ser_attr_tbl (l_column_idx).column_length := 11;
      ELSIF UPPER (l_lot_ser_column_csr.data_type) = 'NUMBER'
      THEN
        l_lot_ser_attr_tbl (l_column_idx).column_length := 38;
      ELSE
        l_lot_ser_attr_tbl (l_column_idx).column_length :=
                                             l_lot_ser_column_csr.data_length;
      END IF;

      IF (l_column_idx = 1)
      THEN
        l_select_stmt :=
             l_select_stmt
          || ' NVL(MSNI.'
          || l_lot_ser_attr_tbl (l_column_idx).column_name
          || ', MSN.'
          || l_lot_ser_attr_tbl (l_column_idx).column_name
          || ')';
      ELSE
        l_select_stmt :=
             l_select_stmt
          || ', NVL(MSNI.'
          || l_lot_ser_attr_tbl (l_column_idx).column_name
          || ', MSN.'
          || l_lot_ser_attr_tbl (l_column_idx).column_name
          || ')';
      END IF;

    END LOOP;*/

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 20', 'get_serial_attr_record');
    END IF;



    -- unlike lot case we do not need a condition for lot_number > 0 for the serials will exists
    -- in the system
    /*
    l_select_stmt :=
         l_select_stmt
      || '  from   mtl_serial_numbers_interface msni,'
      || '               mtl_serial_numbers msn,'
      || '                   mtl_transaction_lots_interface mtli,'
      || '               mtl_transactions_interface mti'
      || '   where mti.parent_id = :b_parent_id'
      || '   and         mti.transaction_interface_id <> mti.parent_id'
      || '   and   mtli.transaction_interface_id = mti.transaction_interface_id'
      || '   and   msni.transaction_interface_id  = mtli.serial_transaction_temp_id'
      || '   AND   inv_serial_number_pub.get_serial_diff(msni.fm_serial_number,:b_serial_number) <> -1'
      || '   and   inv_serial_number_pub.get_serial_diff(msni.fm_serial_number,nvl(msni.to_serial_number,msni.fm_serial_number)) >='
      || '         inv_serial_number_pub.get_serial_diff(msni.fm_serial_number,:b_serial_number)'
      || '   AND   msn.serial_number = :b_serial_number'
      || '   AND   msn.inventory_item_id = mti.inventory_item_id '
      || '   AND   msn.current_organization_id = mti.organization_id ';
      */
    l_sql_p := DBMS_SQL.open_cursor;

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 30', 'get_serial_attr_record');
    END IF;

    DBMS_SQL.parse (l_sql_p, g_select_stmt, DBMS_SQL.native);

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 40', 'get_serial_attr_record');
      mydebug ('b_parent_id '|| p_transaction_interface_id, 'get_serial_attr_record');
      mydebug ('b_serial_number ' || p_serial_number, 'get_serial_attr_record');
      mydebug ('b_fm_serial_number ' ||p_fm_serial_number , 'get_serial_attr_record');
      mydebug ('b_to_serial_number ' ||p_to_serial_number , 'get_serial_attr_record');
      mydebug ('b_item_id ' ||p_item_id , 'get_serial_attr_record');
      mydebug ('b_org_id ' ||p_org_id , 'get_serial_attr_record');
    END IF;

    DBMS_SQL.bind_variable (l_sql_p, 'B_PARENT_ID', p_transaction_interface_id);
    DBMS_SQL.bind_variable (l_sql_p, 'B_FM_SERIAL_NUMBER', p_fm_serial_number);
    DBMS_SQL.bind_variable (l_sql_p, 'B_TO_SERIAL_NUMBER', p_to_serial_number);
    DBMS_SQL.bind_variable (l_sql_p, 'B_SERIAL_NUMBER', p_serial_number);
    DBMS_SQL.bind_variable (l_sql_p, 'B_ITEM_ID', p_item_id);
    DBMS_SQL.bind_variable (l_sql_p, 'B_ORG_ID', p_org_id);

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 50', 'get_serial_attr_record');
    END IF;

    l_column_idx := 0;

    FOR i IN 1 .. l_lot_ser_attr_tbl.COUNT
    LOOP
      l_column_idx := i;
      DBMS_SQL.define_column (l_sql_p
                            , l_column_idx
                            , l_lot_ser_attr_tbl (i).column_value
                            , l_lot_ser_attr_tbl (i).column_length
                             );
    END LOOP;

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 60', 'get_serial_attr_record');
    END IF;

    l_rows_processed := DBMS_SQL.EXECUTE (l_sql_p);

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 70', 'get_serial_attr_record');
    END IF;

    LOOP
      IF (DBMS_SQL.fetch_rows (l_sql_p) > 0)
      THEN
        l_column_idx := 0;

        FOR i IN 1 .. l_lot_ser_attr_tbl.COUNT
        LOOP
          l_column_idx := i;
          DBMS_SQL.column_value (l_sql_p
                               , l_column_idx
                               , l_lot_ser_attr_tbl (i).column_value
                                );
        END LOOP;

        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 80', 'get_serial_attr_record');
        END IF;
      ELSE
        EXIT;
      END IF;

      EXIT;
    END LOOP;

    DBMS_SQL.close_cursor (l_sql_p);

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 90', 'get_serial_attr_record');
      mydebug ('l_lot_ser_attr_tbl.COUNT => ' || l_lot_ser_attr_tbl.COUNT
                 , 'get_serial_attr_record'
                  );

      FOR i IN 1 .. l_lot_ser_attr_tbl.COUNT
      LOOP
        mydebug (   l_lot_ser_attr_tbl (i).column_name
                     || ' => '
                     || l_lot_ser_attr_tbl (i).column_value
                   , 'get_serial_attr_record'
                    );
      END LOOP;
    END IF;

    x_lot_ser_attr_tbl := l_lot_ser_attr_tbl;
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_message.set_name ('WMS', 'WMS_GET_LOT_ATTR_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1)
      THEN
        mydebug ('Exception in get_serial_attr_record' || SQLERRM, 'get_lot_attr_record');
      END IF;
  END get_serial_attr_record;


  /***********************************************************************
   * tmpinsert2() : Procedure to insert records in to MMTT, MTLT and MSNT*
   * for lot split/merge/translate transactions                          *
   ***************************PSEUDO CODE*********************************
   * for each MTI fetched for the given header_id                        *
   *                                                                     *
   *  insert into MMTT                                                   *
   *  fetch the MTLI corresponding to the MTI fetched above.             *
   *  insert into MTLT (there will be only one MTLI for a given MTI)     *
   *  if(Lot Split OR Lot Merge) then                                    *
   *     for each MSNI for the above MTLI                                *
   *       Get the number of serials in MSNI (if frm_serial <> to_serial)*
   *       Get the serial difference if serials present in range         *
   *       For each expanded serial Loop                                 *
   *           If Resulting Serial THEN                                  *
   *             Do Serial Attribute Validations                         *
   *             Insert into MSNT                                        *
   *           Else IF Source Serial                                     *
   *             Insert into MSNT with serial attribts directly from MSNI*
   *       End Loop                                                      *
   *   Else If Lot Translate Then                                        *
   *       For each serial in MSN for the lot in MTI Loop                *
   *       Insert into MSNT                                              *
   *       End Loop                                                      *
   *       Update the MTLT with the serial_txn_temp_id as txn_temp_id of *
   *       the MSNTs inserted above.                                     *
   *   End If                                                            *
   *                                                                     *
   *  Populate the genealogy records for the MSNTs inserted.             *
   *  For lot split     : populate the resulting MSNTs                   *
   *  For lot merge     : populate the source MSNTs                      *
   *  For lot translate : populate the resulting MSNTs                   *
   ***********************************************************************/
  PROCEDURE tmpinsert2 (
    x_return_status       OUT NOCOPY      VARCHAR2
  , x_msg_count           OUT NOCOPY      NUMBER
  , x_msg_data            OUT NOCOPY      VARCHAR2
  , x_validation_status   OUT NOCOPY      VARCHAR2
  , p_header_id           IN              NUMBER
  , p_validation_level    IN              NUMBER
        := fnd_api.g_valid_level_full
  )
  IS
    /*Select only lot split/merge and translate transactions */
    CURSOR mti_csr(l_header_id IN NUMBER)
    IS
      SELECT   mti.transaction_header_id
             , mti.parent_id
             , mti.transaction_interface_id
             , mti.source_code
             , mti.source_line_id
             , mti.created_by
             , mti.last_updated_by
             , mti.last_update_login
             , mti.program_id
             , mti.program_application_id
             , mti.request_id
             , mti.organization_id
             , mti.subinventory_code
             , mti.locator_id
             , mti.inventory_item_id
             , mti.revision
             , mti.transaction_type_id
             , mti.transaction_action_id
             , mti.transaction_source_type_id
             , mti.transaction_source_id
             , mti.transaction_source_name
             , mti.transaction_reference
             , mti.reason_id
             , mti.transaction_date
             , mti.acct_period_id
             , mti.transaction_quantity
             , mti.transaction_uom
             , mti.primary_quantity
             , mti.transaction_cost
             , mti.distribution_account_id
             , mti.transfer_subinventory
             , mti.transfer_organization
             , mti.transfer_locator
             , mti.shipment_number
             , mti.transportation_cost
             , mti.transfer_cost
             , mti.transportation_account
             , mti.freight_code
             , mti.containers
             , mti.waybill_airbill
             , mti.expected_arrival_date
             , mti.currency_code
             , mti.currency_conversion_date
             , mti.currency_conversion_type
             , mti.currency_conversion_rate
             , mti.new_average_cost
             , mti.value_change
             , mti.percentage_change
             , mti.demand_id
             , mti.demand_source_header_id
             , mti.demand_source_line
             , mti.demand_source_delivery
             , mti.customer_ship_id
             , mti.trx_source_delivery_id
             , mti.trx_source_line_id
             , mti.picking_line_id
             , mti.required_flag
             , mti.negative_req_flag
             , mti.repetitive_line_id
             , mti.primary_switch
             , mti.operation_seq_num
             , mti.setup_teardown_code
             , mti.schedule_update_code
             , mti.department_id
             , mti.employee_code
             , mti.schedule_id
             , mti.wip_entity_type
             , mti.encumbrance_amount
             , mti.encumbrance_account
             , mti.ussgl_transaction_code
             , mti.shippable_flag
             , mti.requisition_line_id
             , mti.requisition_distribution_id
             , mti.ship_to_location_id
             , mti.completion_transaction_id
             , mti.attribute_category
             , mti.attribute1
             , mti.attribute2
             , mti.attribute3
             , mti.attribute4
             , mti.attribute5
             , mti.attribute6
             , mti.attribute7
             , mti.attribute8
             , mti.attribute9
             , mti.attribute10
             , mti.attribute11
             , mti.attribute12
             , mti.attribute13
             , mti.attribute14
             , mti.attribute15
             , mti.movement_id
             , mti.source_project_id
             , mti.source_task_id
             , mti.expenditure_type
             , mti.pa_expenditure_org_id
             , mti.project_id
             , mti.task_id
             , mti.to_project_id
             , mti.to_task_id
             , mti.final_completion_flag
             , mti.transfer_percentage
             , mti.material_account
             , mti.material_overhead_account
             , mti.resource_account
             , mti.outside_processing_account
             , mti.overhead_account
             , mti.cost_group_id
             , mti.flow_schedule
             , mti.qa_collection_id
             , mti.overcompletion_transaction_qty
             , mti.overcompletion_primary_qty
             , mti.overcompletion_transaction_id
             , mti.end_item_unit_number
             , mti.org_cost_group_id
             , mti.cost_type_id
             , mti.lpn_id
             , mti.content_lpn_id
             , mti.transfer_lpn_id
             , mti.organization_type
             , mti.transfer_organization_type
             , mti.owning_organization_id
             , mti.owning_tp_type
             , mti.xfr_owning_organization_id
             , mti.transfer_owning_tp_type
             , mti.planning_organization_id
             , mti.planning_tp_type
             , mti.xfr_planning_organization_id
             , mti.transfer_planning_tp_type
             , mti.transaction_batch_id
             , mti.transaction_batch_seq
             , mti.transfer_cost_group_id
             , mti.transaction_mode
             , mti.rebuild_item_id
             , mti.rebuild_activity_id
             , mti.rebuild_serial_number
             , mti.rebuild_job_name
             , mti.kanban_card_id
             , mti.accounting_class
             , mti.scheduled_flag
             , mti.schedule_number
             , mti.routing_revision_date
             , mti.move_transaction_id
             , mti.wip_supply_type
             , mti.build_sequence
             , mti.bom_revision
             , mti.routing_revision
             , mti.bom_revision_date
             , mti.alternate_bom_designator
             , mti.alternate_routing_designator
             , mti.secondary_transaction_quantity
             , mti.secondary_uom_code
             , mti.relieve_reservations_flag   /*** {{ R12 Enhanced reservations code changes ***/
             , mti.relieve_high_level_rsv_flag /*** {{ R12 Enhanced reservations code changes ***/
          FROM mtl_transactions_interface mti
         WHERE mti.transaction_header_id = l_header_id
           AND mti.transaction_action_id IN
                 (inv_globals.g_action_inv_lot_split
                , inv_globals.g_action_inv_lot_merge
                , inv_globals.g_action_inv_lot_translate
                 )
           AND mti.transaction_source_type_id = 13
           AND mti.process_flag = 1
      ORDER BY mti.transaction_batch_id
             , mti.transaction_batch_seq
             , mti.organization_id
             , mti.inventory_item_id
             , mti.revision
             , mti.subinventory_code
             , mti.locator_id;

    /*To this cursor we would pass the parent_id from each mti fetched frm the cursor MTI_CSR*/
    CURSOR mtli_csr (p_transaction_interface_id IN NUMBER)
    IS
      SELECT transaction_interface_id
           , ltrim(rtrim(lot_number)) lot_number        /*Bug 6390860 added ltrim, rtrim and alias*/
           , lot_expiration_date
           , last_updated_by
           , created_by
           , last_update_login
           , program_update_date
           , program_application_id
           , program_id
           , request_id
           , primary_quantity
           , transaction_quantity
           , serial_transaction_temp_id
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
           , p_header_id
           , description
           , vendor_name
           , supplier_lot_number
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
           , vendor_id
           , territory_code
           , parent_lot_number
           , origination_type
           , expiration_action_date
           , expiration_action_code
           , hold_date
           , reason_id
           , secondary_transaction_quantity
                                    --R12 Genealogy enhancements
           , parent_object_type
                 , parent_object_id
                 , parent_object_number
                 , parent_item_id
                 , parent_object_type2
                 , parent_object_id2
                 , parent_object_number2  --R12 Genealogy enhancements
        FROM mtl_transaction_lots_interface
       WHERE transaction_interface_id = p_transaction_interface_id;

    CURSOR msni_csr (l_serial_transaction_temp_id IN NUMBER)
    IS
      SELECT transaction_interface_id
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
           , ltrim(rtrim(fm_serial_number)) fm_serial_number /*Bug 4764048 added ltrim,rtrim*/
           , ltrim(rtrim(to_serial_number)) to_serial_number /*Bug 4764048 added ltrim,rtrim*/
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
        FROM mtl_serial_numbers_interface msni
       WHERE transaction_interface_id = l_serial_transaction_temp_id;

    CURSOR msn_serial_attributes_csr (
      l_serial_number       IN   VARCHAR2
    , l_inventory_item_id   IN   NUMBER
    , l_organization_id     IN   NUMBER
    )
    IS
      SELECT serial_attribute_category
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
        FROM mtl_serial_numbers msn
       WHERE msn.serial_number = l_serial_number
         AND msn.inventory_item_id = l_inventory_item_id
         AND msn.current_organization_id = l_organization_id;

    /*Bug:5408823. Modified the where condition of the following cursor
      to add NVL to locator_id column and add a new parameter p_lpn_id which is
      used in the WHERE clause. */
    CURSOR msn_csr (
      p_lot_number          IN   VARCHAR2
    , p_inventory_item_id   IN   NUMBER
    , p_subinventory_code   IN   VARCHAR2
    , p_locator_id          IN   NUMBER
    , p_organization_id     IN   NUMBER
    , p_lpn_id              IN   NUMBER
    )
    IS
      SELECT last_update_date
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
           , serial_number
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
           , p_header_id
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
        FROM mtl_serial_numbers
        WHERE inventory_item_id = p_inventory_item_id
         AND current_organization_id = p_organization_id
         AND current_status = 3
         AND current_subinventory_code = p_subinventory_code
         AND NVL(current_locator_id,-1) = NVL(p_locator_id, -1)
         AND NVL(lpn_id, -1) = NVL(p_lpn_id, -1)
         AND lot_number = p_lot_number ;

    /*This cursor is used to get the serials in lot merge transaction for which the genealogy
     *columns need to be populated/updated. We will pass the serial_transaction_temp_id of the
     *resultant lot(l_mtli_csr.serial_transaction_temp_id)
     */
    CURSOR msnt_serials_csr (l_serial_transaction_temp_id IN NUMBER)
    IS
      SELECT     fm_serial_number
               , transaction_temp_id
            FROM mtl_serial_numbers_temp
           WHERE transaction_temp_id = l_serial_transaction_temp_id
      FOR UPDATE NOWAIT;

    CURSOR mtli_parent_lots_csr (l_transaction_interface_id IN NUMBER)
    IS
      SELECT mtli.lot_number
           , mtli.serial_transaction_temp_id
        FROM mtl_transaction_lots_interface mtli
       WHERE mtli.transaction_interface_id =
               (SELECT mti.transaction_interface_id
                  FROM mtl_transactions_interface mti
                 WHERE mti.parent_id = l_transaction_interface_id
                   AND mti.transaction_interface_id <> mti.parent_id);

    l_parent_id                    NUMBER;
    l_transaction_interface_id     NUMBER;
    l_next_serial                  VARCHAR2(30);
    l_old_serial                  VARCHAR2(30);
    l_serial_diff                  NUMBER;
    l_serial_code                  NUMBER;
    l_parent_object_number2        VARCHAR2 (80);
    l_current_serial               VARCHAR2 (30);
    l_is_parent_lot                NUMBER;
    l_serial_temp_id               NUMBER;
    l_current_parent_lot           VARCHAR2 (30);
    l_current_serial_txn_temp_id   NUMBER;
    l_user_id                      NUMBER;
    l_login_id                     NUMBER;
    l_sysdate                      DATE;
    l_mtli_csr                     mtli_csr%ROWTYPE;
    l_serial_attributes_csr        msn_serial_attributes_csr%ROWTYPE;
    l_ser_attr_tbl                 inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_validated_ser_attr_tbl       inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_debug                        NUMBER;
    l_indexed_ser_attr_tbl         lot_sel_index_attr_tbl_type;
    l_sequence                     NUMBER;
    l_validation_status            VARCHAR2 (1);
    l_old_item_id                  NUMBER;
    l_old_lot_num                  VARCHAR2(80);
    l_old_sub_code                 VARCHAR2(10);
    l_old_locator_id               NUMBER;
    l_old_lpn_id                   NUMBER; --Bug 5408823
    l_context_value_dst            mtl_flex_context.descriptive_flex_context_code%TYPE;
    l_context_value_src            mtl_flex_context.descriptive_flex_context_code%TYPE;
    l_patchset_j       NUMBER := 0;  /* 0 = No 1 = Yes */

  BEGIN

    l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

    IF (l_debug = 1)
    THEN
      mydebug ('breadcrumb 10', 'tmpinsert2');
    END IF;

    l_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;
    l_sysdate := SYSDATE;
    l_user_id := fnd_global.user_id;
    l_login_id := fnd_global.login_id;

    --bug 4574806. this will be used in the statements below for final
    --completion flag AS a decode
    IF (wip_constants.DMF_PATCHSET_LEVEL>=
        wip_constants.DMF_PATCHSET_J_VALUE) THEN
       l_patchset_j := 1;
    END IF;

    /*Bug:5408823. The following procedure populates the column name, data type
      and length of all the Serial Attributes into global table g_lot_ser_attr_tbl
      which will be later used in procedure get_serial_attr_record. */
    get_serial_attr_table;

    /*  Insert the MMTT for each MTI. For each MTI insert the corresponding MTLT.
     *  For each MTLT there might be several MSNIs. Populate these into MSNTs .
     *  For lot translate there will be no MSNIs. In this case we have to get the
     *  values from the MTLT and MSN.
     */
    BEGIN
      IF (l_debug = 1)
      THEN
        mydebug ('breadcrumb 20 header id ' || p_header_id, 'tmpinsert2');
      END IF;

      FOR l_mti_csr IN mti_csr(p_header_id)
      LOOP
        l_parent_id := l_mti_csr.parent_id;
        l_transaction_interface_id := l_mti_csr.transaction_interface_id;

        IF (l_debug = 1)
        THEN
          mydebug ('Inserting into MMTT',
                       'tmpinsert2');
          mydebug ('l_parent_id                => '|| l_parent_id,
                        'tmpinsert2');
          mydebug ('l_transaction_interface_id => '|| l_transaction_interface_id
                       , 'tmpinsert2'
                      );
        END IF;

        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 30','tmpinsert2');
        END IF;

        INSERT INTO mtl_material_transactions_temp
                    (transaction_header_id
                   , transaction_temp_id
                   , source_code
                   , source_line_id
                   , process_flag
                   , creation_date
                   , created_by
                   , last_update_date
                   , last_updated_by
                   , last_update_login
                   , program_id
                   , program_update_date
                   , program_application_id
                   , request_id
                   , organization_id
                   , subinventory_code
                   , locator_id
                   , inventory_item_id
                   , revision
                   , transaction_type_id
                   , transaction_action_id
                   , transaction_source_type_id
                   , transaction_source_id
                   , transaction_source_name
                   , transaction_reference
                   , reason_id
                   , transaction_date
                   , acct_period_id
                   , transaction_quantity
                   , transaction_uom
                   , primary_quantity
                   , transaction_cost
                   , distribution_account_id
                   , transfer_subinventory
                   , transfer_organization
                   , transfer_to_location
                   , shipment_number
                   , transportation_cost
                   , transfer_cost
                   , transportation_account
                   , freight_code
                   , containers
                   , waybill_airbill
                   , expected_arrival_date
                   , currency_code
                   , currency_conversion_date
                   , currency_conversion_type
                   , currency_conversion_rate
                   , new_average_cost
                   , value_change
                   , percentage_change
                   , demand_id
                   , demand_source_header_id
                   , demand_source_line
                   , demand_source_delivery
                   , customer_ship_id
                   , trx_source_delivery_id
                   , trx_source_line_id
                   , picking_line_id
                   , required_flag
                   , negative_req_flag
                   , repetitive_line_id
                   , primary_switch
                   , operation_seq_num
                   , setup_teardown_code
                   , schedule_update_code
                   , department_id
                   , employee_code
                   , schedule_id
                   , wip_entity_type
                   , encumbrance_amount
                   , encumbrance_account
                   , ussgl_transaction_code
                   , shippable_flag
                   , requisition_line_id
                   , requisition_distribution_id
                   , ship_to_location
                   , completion_transaction_id
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
                   , movement_id
                   , source_project_id
                   , source_task_id
                   , expenditure_type
                   , pa_expenditure_org_id
                   , project_id
                   , task_id
                   , to_project_id
                   , to_task_id
                   , posting_flag
                   , final_completion_flag
                   , transfer_percentage
                   , material_account
                   , material_overhead_account
                   , resource_account
                   , outside_processing_account
                   , overhead_account
                   , cost_group_id
                   , flow_schedule
                   , qa_collection_id
                   , overcompletion_transaction_qty
                   , overcompletion_primary_qty
                   , overcompletion_transaction_id
                   , end_item_unit_number
                   , org_cost_group_id
                   , cost_type_id
                   , move_order_line_id
                   , lpn_id
                   , content_lpn_id
                   , transfer_lpn_id
                   , organization_type
                   , transfer_organization_type
                   , owning_organization_id
                   , owning_tp_type
                   , xfr_owning_organization_id
                   , transfer_owning_tp_type
                   , planning_organization_id
                   , planning_tp_type
                   , xfr_planning_organization_id
                   , transfer_planning_tp_type
                   , transaction_batch_id
                   , transaction_batch_seq
                   , transfer_cost_group_id
                   , transaction_mode
                   , rebuild_item_id
                   , rebuild_activity_id
                   , rebuild_serial_number
                   , rebuild_job_name
                   , kanban_card_id
                   , class_code
                   , scheduled_flag
                   , schedule_number
                   , routing_revision_date
                   , move_transaction_id
                   , wip_supply_type
                   , build_sequence
                   , bom_revision
                   , routing_revision
                   , bom_revision_date
                   , alternate_bom_designator
                   , alternate_routing_designator
                   , secondary_transaction_quantity
                   , secondary_uom_code
                   , parent_transaction_temp_id
                   , relieve_reservations_flag   /*** {{ R12 Enhanced reservations code changes ***/
                   , relieve_high_level_rsv_flag /*** {{ R12 Enhanced reservations code changes ***/
                    )
             VALUES (l_mti_csr.transaction_header_id
                   , l_mti_csr.transaction_interface_id
                   , l_mti_csr.source_code
                   , l_mti_csr.source_line_id
                   , 'Y'
                   , l_sysdate
                   , l_user_id
                   , l_sysdate
                   , l_user_id
                   , l_login_id
                   , l_mti_csr.program_id
                   , l_sysdate
                   , l_mti_csr.program_application_id
                   , l_mti_csr.request_id
                   , l_mti_csr.organization_id
                   , l_mti_csr.subinventory_code
                   , l_mti_csr.locator_id
                   , l_mti_csr.inventory_item_id
                   , l_mti_csr.revision
                   , l_mti_csr.transaction_type_id
                   , l_mti_csr.transaction_action_id
                   , l_mti_csr.transaction_source_type_id
                   , l_mti_csr.transaction_source_id
                   , l_mti_csr.transaction_source_name
                   , l_mti_csr.transaction_reference
                   , l_mti_csr.reason_id
                   , l_mti_csr.transaction_date
                   , l_mti_csr.acct_period_id
                   , l_mti_csr.transaction_quantity
                   , l_mti_csr.transaction_uom
                   , l_mti_csr.primary_quantity
                   , l_mti_csr.transaction_cost
                   , l_mti_csr.distribution_account_id
                   , l_mti_csr.transfer_subinventory
                   , l_mti_csr.transfer_organization
                   , l_mti_csr.transfer_locator
                   , l_mti_csr.shipment_number
                   , l_mti_csr.transportation_cost
                   , l_mti_csr.transfer_cost
                   , l_mti_csr.transportation_account
                   , l_mti_csr.freight_code
                   , l_mti_csr.containers
                   , l_mti_csr.waybill_airbill
                   , l_mti_csr.expected_arrival_date
                   , l_mti_csr.currency_code
                   , l_mti_csr.currency_conversion_date
                   , l_mti_csr.currency_conversion_type
                   , l_mti_csr.currency_conversion_rate
                   , l_mti_csr.new_average_cost
                   , l_mti_csr.value_change
                   , l_mti_csr.percentage_change
                   , l_mti_csr.demand_id
                   , l_mti_csr.demand_source_header_id
                   , l_mti_csr.demand_source_line
                   , l_mti_csr.demand_source_delivery
                   , l_mti_csr.customer_ship_id
                   , l_mti_csr.trx_source_delivery_id
                   , l_mti_csr.trx_source_line_id
                   , l_mti_csr.picking_line_id
                   , l_mti_csr.required_flag
                   , l_mti_csr.negative_req_flag
                   , l_mti_csr.repetitive_line_id
                   , l_mti_csr.primary_switch
                   , l_mti_csr.operation_seq_num
                   , l_mti_csr.setup_teardown_code
                   , l_mti_csr.schedule_update_code
                   , l_mti_csr.department_id
                   , l_mti_csr.employee_code
                   , l_mti_csr.schedule_id
                   , l_mti_csr.wip_entity_type
                   , l_mti_csr.encumbrance_amount
                   , l_mti_csr.encumbrance_account
                   , l_mti_csr.ussgl_transaction_code
                   , l_mti_csr.shippable_flag
                   , l_mti_csr.requisition_line_id
                   , l_mti_csr.requisition_distribution_id
                   , l_mti_csr.ship_to_location_id
                   , NVL (l_mti_csr.completion_transaction_id
                        , DECODE (l_mti_csr.transaction_action_id
                                , 31, mtl_material_transactions_s.NEXTVAL
                                , 32, mtl_material_transactions_s.NEXTVAL
                                , NULL
                                 )
                         )
                   , l_mti_csr.attribute_category
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
                   , l_mti_csr.movement_id
                   , l_mti_csr.source_project_id
                   , l_mti_csr.source_task_id
                   , l_mti_csr.expenditure_type
                   , l_mti_csr.pa_expenditure_org_id
                   , l_mti_csr.project_id
                   , l_mti_csr.task_id
                   , l_mti_csr.to_project_id
                   , l_mti_csr.to_task_id
                   , 'N'
                   , NVL(l_mti_csr.final_completion_flag,Decode(l_patchset_j,1,l_mti_csr.final_completion_flag,'N'))
                   , l_mti_csr.transfer_percentage
                   , l_mti_csr.material_account
                   , l_mti_csr.material_overhead_account
                   , l_mti_csr.resource_account
                   , l_mti_csr.outside_processing_account
                   , l_mti_csr.overhead_account
                   , l_mti_csr.cost_group_id
                   , l_mti_csr.flow_schedule
                   , l_mti_csr.qa_collection_id
                   , l_mti_csr.overcompletion_transaction_qty
                   ,                         /* Overcompletion Transactions */
                     l_mti_csr.overcompletion_primary_qty
                   , l_mti_csr.overcompletion_transaction_id
                   , l_mti_csr.end_item_unit_number
                   , l_mti_csr.org_cost_group_id
                   , l_mti_csr.cost_type_id
                   , DECODE (l_mti_csr.transaction_source_type_id
                           , 4, l_mti_csr.source_line_id
                           , NULL
                            )
                   , l_mti_csr.lpn_id
                   , l_mti_csr.content_lpn_id
                   , l_mti_csr.transfer_lpn_id
                   , l_mti_csr.organization_type
                   , l_mti_csr.transfer_organization_type
                   , l_mti_csr.owning_organization_id
                   , l_mti_csr.owning_tp_type
                   , l_mti_csr.xfr_owning_organization_id
                   , l_mti_csr.transfer_owning_tp_type
                   , l_mti_csr.planning_organization_id
                   , l_mti_csr.planning_tp_type
                   , l_mti_csr.xfr_planning_organization_id
                   , l_mti_csr.transfer_planning_tp_type
                   , l_mti_csr.transaction_batch_id
                   , l_mti_csr.transaction_batch_seq
                   , l_mti_csr.transfer_cost_group_id
                   ,
                     --this goes into transaction_mode
                     DECODE (p_validation_level
                           , fnd_api.g_valid_level_none, l_mti_csr.transaction_mode
                           , inv_txn_manager_grp.proc_mode_mti
                            )
                   , l_mti_csr.rebuild_item_id
                   , l_mti_csr.rebuild_activity_id
                   , l_mti_csr.rebuild_serial_number
                   , l_mti_csr.rebuild_job_name
                   , l_mti_csr.kanban_card_id
                   , l_mti_csr.accounting_class
                   , l_mti_csr.scheduled_flag
                   , l_mti_csr.schedule_number
                   , l_mti_csr.routing_revision_date
                   , l_mti_csr.move_transaction_id
                   , l_mti_csr.wip_supply_type
                   , l_mti_csr.build_sequence
                   , l_mti_csr.bom_revision
                   , l_mti_csr.routing_revision
                   , l_mti_csr.bom_revision_date
                   , l_mti_csr.alternate_bom_designator
                   , l_mti_csr.alternate_routing_designator
                   , l_mti_csr.secondary_transaction_quantity
                   , l_mti_csr.secondary_uom_code
                   , l_mti_csr.parent_id
                   , l_mti_csr.relieve_reservations_flag   /*** {{ R12 Enhanced reservations code changes ***/
                   , l_mti_csr.relieve_high_level_rsv_flag /*** {{ R12 Enhanced reservations code changes ***/
                    );

        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 40', 'tmpinsert2');
        END IF;


        --For each MTI there will be a corresponding only one MTLI
        FOR l_mtli_csr IN mtli_csr(l_transaction_interface_id) LOOP

        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 50', 'tmpinsert2');
          mydebug ('Inserting into MTLI', 'tmpinsert2');
        END IF;

        INSERT INTO mtl_transaction_lots_temp
                    (transaction_temp_id
                   , lot_number
                   , lot_expiration_date
                   , last_updated_by
                   , last_update_date
                   , creation_date
                   , created_by
                   , last_update_login
                   , program_application_id
                   , program_id
                   , program_update_date
                   , request_id
                   , primary_quantity
                   , transaction_quantity
                   , serial_transaction_temp_id
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
                   , group_header_id
                   , description
                   , vendor_name
                   , supplier_lot_number
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
                   , vendor_id
                   , territory_code
                   , parent_lot_number
                   , origination_type
                   , expiration_action_date
                   , expiration_action_code
                   , hold_date
                   , reason_id
                   , secondary_quantity
                     --R12 Genealogy enhancements
                   , parent_object_type
                         , parent_object_id
                         , parent_object_number
                         , parent_item_id
                         , parent_object_type2
                         , parent_object_id2
                         , parent_object_number2
                     --R12 Genealogy enhancements
                    )
             VALUES (l_mtli_csr.transaction_interface_id
                   , l_mtli_csr.lot_number
                   , l_mtli_csr.lot_expiration_date
                   , l_user_id
                   , l_sysdate
                   , l_sysdate
                   , l_user_id
                   , l_login_id
                   , l_mtli_csr.program_application_id
                   , l_mtli_csr.program_id
                   , l_mtli_csr.program_update_date
                   , l_mtli_csr.request_id
                   , l_mtli_csr.primary_quantity
                   , l_mtli_csr.transaction_quantity
                   , l_mtli_csr.serial_transaction_temp_id
                   , l_mtli_csr.lot_attribute_category
                   , l_mtli_csr.c_attribute1
                   , l_mtli_csr.c_attribute2
                   , l_mtli_csr.c_attribute3
                   , l_mtli_csr.c_attribute4
                   , l_mtli_csr.c_attribute5
                   , l_mtli_csr.c_attribute6
                   , l_mtli_csr.c_attribute7
                   , l_mtli_csr.c_attribute8
                   , l_mtli_csr.c_attribute9
                   , l_mtli_csr.c_attribute10
                   , l_mtli_csr.c_attribute11
                   , l_mtli_csr.c_attribute12
                   , l_mtli_csr.c_attribute13
                   , l_mtli_csr.c_attribute14
                   , l_mtli_csr.c_attribute15
                   , l_mtli_csr.c_attribute16
                   , l_mtli_csr.c_attribute17
                   , l_mtli_csr.c_attribute18
                   , l_mtli_csr.c_attribute19
                   , l_mtli_csr.c_attribute20
                   , l_mtli_csr.d_attribute1
                   , l_mtli_csr.d_attribute2
                   , l_mtli_csr.d_attribute3
                   , l_mtli_csr.d_attribute4
                   , l_mtli_csr.d_attribute5
                   , l_mtli_csr.d_attribute6
                   , l_mtli_csr.d_attribute7
                   , l_mtli_csr.d_attribute8
                   , l_mtli_csr.d_attribute9
                   , l_mtli_csr.d_attribute10
                   , l_mtli_csr.n_attribute1
                   , l_mtli_csr.n_attribute2
                   , l_mtli_csr.n_attribute3
                   , l_mtli_csr.n_attribute4
                   , l_mtli_csr.n_attribute5
                   , l_mtli_csr.n_attribute6
                   , l_mtli_csr.n_attribute7
                   , l_mtli_csr.n_attribute8
                   , l_mtli_csr.n_attribute9
                   , l_mtli_csr.n_attribute10
                   , l_mtli_csr.attribute1
                   , l_mtli_csr.attribute2
                   , l_mtli_csr.attribute3
                   , l_mtli_csr.attribute4
                   , l_mtli_csr.attribute5
                   , l_mtli_csr.attribute6
                   , l_mtli_csr.attribute7
                   , l_mtli_csr.attribute8
                   , l_mtli_csr.attribute9
                   , l_mtli_csr.attribute10
                   , l_mtli_csr.attribute11
                   , l_mtli_csr.attribute12
                   , l_mtli_csr.attribute13
                   , l_mtli_csr.attribute14
                   , l_mtli_csr.attribute15
                   , l_mtli_csr.attribute_category
                   , l_mtli_csr.p_header_id
                   , l_mtli_csr.description
                   , l_mtli_csr.vendor_name
                   , l_mtli_csr.supplier_lot_number
                   , l_mtli_csr.origination_date
                   , l_mtli_csr.date_code
                   , l_mtli_csr.grade_code
                   , l_mtli_csr.change_date
                   , l_mtli_csr.maturity_date
                   , l_mtli_csr.status_id
                   , l_mtli_csr.retest_date
                   , l_mtli_csr.age
                   , l_mtli_csr.item_size
                   , l_mtli_csr.color
                   , l_mtli_csr.volume
                   , l_mtli_csr.volume_uom
                   , l_mtli_csr.place_of_origin
                   , l_mtli_csr.best_by_date
                   , l_mtli_csr.LENGTH
                   , l_mtli_csr.length_uom
                   , l_mtli_csr.recycled_content
                   , l_mtli_csr.thickness
                   , l_mtli_csr.thickness_uom
                   , l_mtli_csr.width
                   , l_mtli_csr.width_uom
                   , l_mtli_csr.curl_wrinkle_fold
                   , l_mtli_csr.vendor_id
                   , l_mtli_csr.territory_code
                   , l_mtli_csr.parent_lot_number
                   , l_mtli_csr.origination_type
                   , l_mtli_csr.expiration_action_date
                   , l_mtli_csr.expiration_action_code
                   , l_mtli_csr.hold_date
                   , l_mtli_csr.reason_id
                   , l_mtli_csr.secondary_transaction_quantity
                     --R12 Genealogy enhancements
                   , l_mtli_csr.parent_object_type
                         , l_mtli_csr.parent_object_id
                         , l_mtli_csr.parent_object_number
                         , l_mtli_csr.parent_item_id
                         , l_mtli_csr.parent_object_type2
                         , l_mtli_csr.parent_object_id2
                         , l_mtli_csr.parent_object_number2
                     --R12 Genealogy enhancements
                    );

        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 60', 'tmpinsert2');
        END IF;

        /* Need to insert the MSNTs if the item is serial controlled as well */
        BEGIN
          IF (l_debug = 1)
          THEN
            mydebug ('Determine the serial control code', 'tmpinsert2');
          END IF;

          SELECT serial_number_control_code
            INTO l_serial_code
            FROM mtl_system_items
           WHERE inventory_item_id = l_mti_csr.inventory_item_id
             AND organization_id = l_mti_csr.organization_id;
        EXCEPTION
          WHEN OTHERS
          THEN
            IF (l_debug = 1)
            THEN
              mydebug
                        ('Cannot fetch the serial control code for the item'
                       , 'tmpinsert2'
                        );
            END IF;

            x_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 70', 'tmpinsert2');
          mydebug ('Serial control code is ' || l_serial_code
                     , 'tmpinsert2'
                      );
        END IF;

        IF (l_serial_code IN (2, 5))
        THEN
          IF (   l_mti_csr.transaction_action_id =
                                              inv_globals.g_action_inv_lot_split
              OR l_mti_csr.transaction_action_id =
                                              inv_globals.g_action_inv_lot_merge
             )
          THEN
            BEGIN
              IF (l_debug = 1)
              THEN
                mydebug ('breadcrumb 80', 'tmpinsert2');
                mydebug ('Lot Split/merge transaction', 'tmpinsert2');
                mydebug ('l_mti_csr.transaction_action_id        => ' || l_mti_csr.transaction_action_id
                           , 'tmpinsert2'
                            );
                mydebug ( 'l_mtli_csr.serial_transaction_temp_id => '|| l_mtli_csr.serial_transaction_temp_id
                           , 'tmpinsert2'
                            );
              END IF;


              FOR l_ser_csr IN msni_csr (l_mtli_csr.serial_transaction_temp_id)
              LOOP
                l_next_serial := l_ser_csr.fm_serial_number;
                l_serial_diff :=
                  inv_serial_number_pub.get_serial_diff
                                                 (l_ser_csr.fm_serial_number
                                                , l_ser_csr.to_serial_number
                                                 );

                IF (l_debug = 1)
                THEN
                  mydebug ('breadcrumb 90', 'tmpinsert2');
                  mydebug ('l_next_serial => ' || l_next_serial
                             , 'tmpinsert2'
                              );
                  mydebug ('l_serial_diff => ' || l_serial_diff
                             , 'tmpinsert2'
                              );
                END IF;

                IF (l_serial_diff = -1)
                THEN
                  fnd_message.set_name ('INV', 'INV_INVALID_SERIAL_RANGE');
                  fnd_msg_pub.ADD;
                  l_validation_status := 'N';
                  RAISE fnd_api.g_exc_error;
                END IF;

                /***********************************************************************
                 * Each MSNI can have a range of serials. Need to expand them and      *
                 * process each one individually.                                      *
                 ***********************************************************************/


                l_next_serial := l_ser_csr.fm_serial_number;
                FOR i IN 1 .. l_serial_diff
                LOOP
                  IF (l_debug = 1)
                  THEN
                    mydebug ('breadcrumb 100', 'tmpinsert2');
                  END IF;
                  l_old_serial := l_next_serial;


                  IF (l_debug = 1)
                  THEN
                    mydebug ('processing serial => ' || l_next_serial
                               , 'tmpinsert2'
                                );
                    mydebug ('breadcrumb 110', 'tmpinsert2');
                  END IF;

                  /************************************************************************************
                   * Need to see wether the attributes are present in the MSNI. If yes copy from there*
                   *  ..if not copy from MSN...then call validate_serial_attributes....               *
                   * Will validate only the resulting MSNTs while for the source MSNTs we will        *
                   * just copy the serial attributes from the MSNI to MSNT.                           *
                   ************************************************************************************/
                  IF (   (    l_mtli_csr.transaction_interface_id <>
                                                           l_mti_csr.parent_id
                          AND l_mti_csr.transaction_action_id =
                                              inv_globals.g_action_inv_lot_split
                         )
                      OR (    l_mtli_csr.transaction_interface_id =
                                                           l_mti_csr.parent_id
                          AND l_mti_csr.transaction_action_id =
                                              inv_globals.g_action_inv_lot_merge
                         )
                     )
                  THEN
                    BEGIN
                      IF (l_debug = 1)
                      THEN
                        mydebug ('breadcrumb 120', 'tmpinsert2');
                        mydebug
                          ('Processing the child record attrs for split/merge'
                         , 'tmpinsert2'
                          );
                        mydebug ('Calling get_serial_attr_record'
                                   , 'tmpinsert2'
                                    );
                      END IF;

                      get_serial_attr_record
                        (x_lot_ser_attr_tbl             => l_ser_attr_tbl
                       , p_transaction_interface_id     => l_ser_csr.transaction_interface_id
                       , p_serial_number                => l_next_serial
                       , p_item_id                      => l_mti_csr.inventory_item_id
                       , p_org_id                       => l_mti_csr.organization_id
                       , p_fm_serial_number            =>  l_ser_csr.fm_serial_number
                       , p_to_serial_number             => l_ser_csr.to_serial_number
                       , p_organization_id              => l_mti_csr.organization_id
                       , p_inventory_item_id            => l_mti_csr.inventory_item_id
                        );
                      IF(l_debug = 1) THEN
                        mydebug ('Done with get_serial_attr_record'
                                     , 'tmpinsert2'
                                      );
                        mydebug ('l_ser_attr_tbl.count => ' || l_ser_attr_tbl.COUNT
                                     , 'tmpinsert2'
                                      );
                      END IF;


                    EXCEPTION
                      WHEN OTHERS
                      THEN
                        IF (l_debug = 1)
                        THEN
                          mydebug
                            ('Exception while calling get_Serial_attr_record'
                           , 'tmpinsert2'
                            );
                        END IF;

                        fnd_message.set_name ('WMS', 'WMS_GET_LOT_ATTR_ERROR');
                        fnd_msg_pub.ADD;
                        l_validation_status := 'N';
                        RAISE fnd_api.g_exc_unexpected_error;
                    END;

                    BEGIN
                      IF (l_debug = 1)
                      THEN
                        mydebug ('breadcrumb 130', 'tmpinsert2');
                        mydebug ('Calling validate_serial_attributes'
                                   , 'tmpinsert2'
                                    );
                      END IF;

                      inv_lot_trx_validation_pub.validate_serial_attributes
                          (x_return_status           => x_return_status
                         , x_msg_count               => x_msg_count
                         , x_msg_data                => x_msg_data
                         , x_validation_status       => x_validation_status
                         , x_ser_attr_tbl            => l_validated_ser_attr_tbl
                         , p_ser_number              => l_next_serial
                         , p_organization_id         => l_mti_csr.organization_id
                         , p_inventory_item_id       => l_mti_csr.inventory_item_id
                         , p_result_ser_attr_tbl     => l_ser_attr_tbl
                          );
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                        IF (l_debug = 1)
                        THEN
                          mydebug
                              ('validate_serial_attributes rasied exception'
                             , 'tmpinsert2'
                              );
                        END IF;

                        fnd_message.set_name ('WMS'
                                            , 'WMS_VALIDATE_ATTR_ERROR');
                        fnd_msg_pub.ADD;
                        l_validation_status := 'N';
                        RAISE fnd_api.g_exc_unexpected_error;
                    END;

                    IF (   x_return_status <> fnd_api.g_ret_sts_success
                        OR x_validation_status <> 'Y'
                       )
                    THEN
                      IF (l_debug = 1)
                      THEN
                        mydebug
                           ('validate_serial_attributes returned with error'
                          , 'tmpinsert2'
                           );
                      END IF;
                      l_validation_status := 'N';
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    IF (l_debug = 1)
                    THEN
                      mydebug ('breadcrumb 140', 'tmpinsert2');
                      mydebug ('l_validated_ser_attr_tbl.COUNT => ' || l_validated_ser_attr_tbl.COUNT, 'tmpinsert2');
                    END IF;

                    FOR j IN 1 .. l_validated_ser_attr_tbl.COUNT
                    LOOP
                      l_indexed_ser_attr_tbl
                                     (l_validated_ser_attr_tbl (j).column_name
                                     ).column_value :=
                                     l_validated_ser_attr_tbl (j).column_value;
                      --mydebug (l_validated_ser_attr_tbl (j).column_name || ' => ' || l_validated_ser_attr_tbl (j).column_value, 'tmpinsert2');
                    END LOOP;

                    IF (l_debug = 1)
                    THEN
                      mydebug ('Inserting into MSNT', 'tmpinsert2');
                    END IF;

                    INSERT INTO mtl_serial_numbers_temp
                                (transaction_temp_id
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
                               , dff_updated_flag
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
                               , group_header_id
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
                                )
                         VALUES (l_ser_csr.transaction_interface_id
                               , l_sysdate
                               , l_ser_csr.last_updated_by
                               , l_sysdate
                               , l_ser_csr.created_by
                               , l_ser_csr.last_update_login
                               , l_ser_csr.request_id
                               , l_ser_csr.program_application_id
                               , l_ser_csr.program_id
                               , l_ser_csr.program_update_date
                               , l_ser_csr.vendor_serial_number
                               , l_ser_csr.vendor_lot_number
                               , l_next_serial
                               , l_next_serial
                               , l_ser_csr.parent_serial_number
                               , 'Y'
                               , l_indexed_ser_attr_tbl('SERIAL_ATTRIBUTE_CATEGORY').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE1').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE2').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE3').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE4').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE5').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE6').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE7').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE8').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE9').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE10').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE11').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE12').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE13').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE14').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE15').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE16').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE17').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE18').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE19').column_value
                               , l_indexed_ser_attr_tbl ('C_ATTRIBUTE20').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE1').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE2').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE3').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE4').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE5').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE6').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE7').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE8').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE9').column_value
                               , l_indexed_ser_attr_tbl ('D_ATTRIBUTE10').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE1').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE2').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE3').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE4').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE5').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE6').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE7').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE8').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE9').column_value
                               , l_indexed_ser_attr_tbl ('N_ATTRIBUTE10').column_value
                               , p_header_id                    -- Added for J
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE_CATEGORY').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE1').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE2').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE3').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE4').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE5').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE6').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE7').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE8').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE9').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE10').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE11').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE12').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE13').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE14').column_value
                               , l_indexed_ser_attr_tbl ('ATTRIBUTE15').column_value
                               , l_ser_csr.status_id
                               , l_indexed_ser_attr_tbl ('TERRITORY_CODE').column_value
                               , l_indexed_ser_attr_tbl ('TIME_SINCE_NEW').column_value
                               , l_indexed_ser_attr_tbl ('CYCLES_SINCE_NEW').column_value
                               , l_indexed_ser_attr_tbl ('TIME_SINCE_OVERHAUL').column_value
                               , l_indexed_ser_attr_tbl ('CYCLES_SINCE_OVERHAUL').column_value
                               , l_indexed_ser_attr_tbl ('TIME_SINCE_REPAIR').column_value
                               , l_indexed_ser_attr_tbl ('CYCLES_SINCE_REPAIR').column_value
                               , l_indexed_ser_attr_tbl ('TIME_SINCE_VISIT').column_value
                               , l_indexed_ser_attr_tbl ('CYCLES_SINCE_VISIT').column_value
                               , l_indexed_ser_attr_tbl ('TIME_SINCE_MARK').column_value
                               , l_indexed_ser_attr_tbl ('CYCLES_SINCE_MARK').column_value
                               , l_indexed_ser_attr_tbl ('NUMBER_OF_REPAIRS').column_value
                                );

                    IF (l_debug = 1)
                    THEN
                      mydebug ('breadcrumb 150', 'tmpinsert2');
                    END IF;
                  ELSE
                  /*These are the source MSNTs ...no need to validate the source MSNT attrs*/
                    IF (l_debug = 1)
                    THEN
                      mydebug ('breadcrumb 160', 'tmpinsert2');
                      mydebug
                           ('Inserting MSNTs for the source for split/merge'
                          , 'tmpinsert2'
                           );
                    END IF;

                    INSERT INTO mtl_serial_numbers_temp
                                (transaction_temp_id
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
                               , dff_updated_flag
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
                               , group_header_id
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
                                )
                         VALUES (l_ser_csr.transaction_interface_id
                               , l_sysdate
                               , l_user_id
                               , l_sysdate
                               , l_user_id
                               , l_login_id
                               , l_ser_csr.request_id
                               , l_ser_csr.program_application_id
                               , l_ser_csr.program_id
                               , l_ser_csr.program_update_date
                               , l_ser_csr.vendor_serial_number
                               , l_ser_csr.vendor_lot_number
                               , l_next_serial
                               , l_next_serial
                               , l_ser_csr.parent_serial_number
                               , 'Y'
                               , l_ser_csr.serial_attribute_category
                               , l_ser_csr.c_attribute1
                               , l_ser_csr.c_attribute2
                               , l_ser_csr.c_attribute3
                               , l_ser_csr.c_attribute4
                               , l_ser_csr.c_attribute5
                               , l_ser_csr.c_attribute6
                               , l_ser_csr.c_attribute7
                               , l_ser_csr.c_attribute8
                               , l_ser_csr.c_attribute9
                               , l_ser_csr.c_attribute10
                               , l_ser_csr.c_attribute11
                               , l_ser_csr.c_attribute12
                               , l_ser_csr.c_attribute13
                               , l_ser_csr.c_attribute14
                               , l_ser_csr.c_attribute15
                               , l_ser_csr.c_attribute16
                               , l_ser_csr.c_attribute17
                               , l_ser_csr.c_attribute18
                               , l_ser_csr.c_attribute19
                               , l_ser_csr.c_attribute20
                               , l_ser_csr.d_attribute1
                               , l_ser_csr.d_attribute2
                               , l_ser_csr.d_attribute3
                               , l_ser_csr.d_attribute4
                               , l_ser_csr.d_attribute5
                               , l_ser_csr.d_attribute6
                               , l_ser_csr.d_attribute7
                               , l_ser_csr.d_attribute8
                               , l_ser_csr.d_attribute9
                               , l_ser_csr.d_attribute10
                               , l_ser_csr.n_attribute1
                               , l_ser_csr.n_attribute2
                               , l_ser_csr.n_attribute3
                               , l_ser_csr.n_attribute4
                               , l_ser_csr.n_attribute5
                               , l_ser_csr.n_attribute6
                               , l_ser_csr.n_attribute7
                               , l_ser_csr.n_attribute8
                               , l_ser_csr.n_attribute9
                               , l_ser_csr.n_attribute10
                               , p_header_id
                               , l_ser_csr.attribute_category
                               , l_ser_csr.attribute1
                               , l_ser_csr.attribute2
                               , l_ser_csr.attribute3
                               , l_ser_csr.attribute4
                               , l_ser_csr.attribute5
                               , l_ser_csr.attribute6
                               , l_ser_csr.attribute7
                               , l_ser_csr.attribute8
                               , l_ser_csr.attribute9
                               , l_ser_csr.attribute10
                               , l_ser_csr.attribute11
                               , l_ser_csr.attribute12
                               , l_ser_csr.attribute13
                               , l_ser_csr.attribute14
                               , l_ser_csr.attribute15
                               , l_ser_csr.status_id
                               , l_ser_csr.territory_code
                               , l_ser_csr.time_since_new
                               , l_ser_csr.cycles_since_new
                               , l_ser_csr.time_since_overhaul
                               , l_ser_csr.cycles_since_overhaul
                               , l_ser_csr.time_since_repair
                               , l_ser_csr.cycles_since_repair
                               , l_ser_csr.time_since_visit
                               , l_ser_csr.cycles_since_visit
                               , l_ser_csr.time_since_mark
                               , l_ser_csr.cycles_since_mark
                               , l_ser_csr.number_of_repairs
                                );
                  END IF;
                  l_next_serial :=
                    inv_serial_number_pub.increment_ser_num
                                                               (l_old_serial
                                                              , 1
                                                               );

                  IF (l_next_serial = l_old_serial)
                  THEN
                    IF (l_debug = 1)
                    THEN
                      mydebug ('Error in increment_serial_number '
                                 , 'tmpinsert2'
                                  );
                    END IF;

                    fnd_message.set_name ('INV', 'INVALID_SERIAL_NUMBER');
                    fnd_msg_pub.ADD;
                    l_validation_status := 'N';
                    RAISE fnd_api.g_exc_error;
                  END IF;

                END LOOP;
              END LOOP;

              IF (l_debug = 1)
              THEN
                mydebug ('breadcrumb 170', 'tmpinsert2');
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
                IF (l_debug = 1)
                THEN
                  mydebug
                    ('NO_DATA_FOUND while inserting into MSNT for lot /split'
                   , ''
                    );
                END IF;

                l_validation_status := 'N';
                RAISE fnd_api.g_exc_unexpected_error;
              WHEN OTHERS
              THEN
                IF (l_debug = 1)
                THEN
                  mydebug
                    ('exception raised while inserting into MSNT for lot split/merge'
                   , SQLERRM
                    );
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
            END;
          ELSE
            IF (l_debug = 1)
            THEN
              mydebug ('This is lot translate transaction', 'tmpinsert2');
              mydebug ('breadcrumb 180', 'tmpinsert2');
            END IF;

            /******************************************************************************
             *Lot translate transaction. Users are not expected to populate the MSNIs for *
             *Lot Translate txns. We need to generate the MSNTs based on MTLIs and MSN.   *
             ******************************************************************************/
            SELECT mtl_material_transactions_s.NEXTVAL
              INTO l_sequence
              FROM DUAL;
            /******************************************************************************
             *If this is the resulting MTIs then we need to query the against the source  *
             *item, lot and subinventory because after lot translate these may get changed*
             *and there wil be no record in the MSN for the new lot etc.                  *
             ******************************************************************************/

            /* Bug:5408823. Also fetching lpn_id column from MTI. */
            IF(l_mti_csr.transaction_interface_id <> l_mti_csr.parent_id) THEN
            SELECT  mti.inventory_item_id
                  , mtli.lot_number
                  , mti.subinventory_code
                  , mti.locator_id
                  , mti.lpn_id
              INTO l_old_item_id
                  ,l_old_lot_num
                  ,l_old_sub_code
                  ,l_old_locator_id
                  ,l_old_lpn_id
              FROM mtl_transactions_interface mti
                  ,mtl_transaction_lots_interface mtli
              WHERE mti.transaction_interface_id = mtli.transaction_interface_id
              AND   mti.transaction_interface_id = mti.parent_id
              AND   mti.transaction_interface_id  = l_mti_csr.parent_id;
              IF(l_old_item_id <> l_mti_csr.inventory_item_id) THEN
              --Check if the source and destination Items have the attribute context.
                IF(l_debug = 1) THEN
                    mydebug('In Lot translate : dest Records : checking DFF context', 'tmpinsert2');
                END IF;
                inv_lot_sel_attr.get_context_code(
                 context_value  => l_context_value_src
                ,org_id         => l_mti_csr.organization_id
                ,item_id        => l_old_item_id
                ,flex_name      => 'Serial Attributes'
                ,p_lot_serial_number    => null);

                IF(l_debug = 1) THEN
                   mydebug('l_context_value_src => '|| l_context_value_src, 'tmpinsert2');
                END IF;

                inv_lot_sel_attr.get_context_code(
                 context_value  => l_context_value_dst
                ,org_id         => l_mti_csr.organization_id
                ,item_id        => l_mti_csr.inventory_item_id
                ,flex_name      => 'Serial Attributes'
                ,p_lot_serial_number    => null);

                IF(l_debug = 1) THEN
                   mydebug('l_context_value_dst => '|| l_context_value_dst, 'tmpinsert2');
                END IF;

                IF( NOT(
                        (l_context_value_src IS NULL AND l_context_value_dst IS NULL)  OR
                        (l_context_value_src = l_context_value_dst)
                        )
                  ) THEN
                 IF(l_debug = 1) THEN
                        mydebug('breadcrumb 185', 'tmpinsert2');
                        mydebug('Lot translate : Items have different Serial Attr Context', 'tmpinsert2');
                 END IF;
                 fnd_message.set_name ('INV', 'INV_SERIAL_CONTEXT_DIFF');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
                 l_validation_status := 'N';
                END IF;
              END IF;
            ELSE    /*Source MTIs*/
                   l_old_item_id    := l_mti_csr.inventory_item_id;
                   l_old_lot_num    := l_mtli_csr.lot_number;
                   l_old_sub_code   := l_mti_csr.subinventory_code;
                   l_old_locator_id := l_mti_csr.locator_id;
                   l_old_lpn_id     := l_mti_csr.lpn_id; --Bug 5408823
            END IF;

            /*Bug:5408823. Added new parameter l_old_lpn_id to pass lpn_id. */
            FOR l_ser_csr IN msn_csr (l_old_lot_num
                                    , l_old_item_id
                                    , l_old_sub_code
                                    , l_old_locator_id
                                    , l_mti_csr.organization_id
                                    , l_old_lpn_id
                                     )
            LOOP
              IF (l_debug = 1)
              THEN
                mydebug ('breadcrumb 190', 'tmpinsert2');
                mydebug ('In loop Inserting MSNT for serial => ' || l_ser_csr.serial_number
                           , 'tmpinsert2'
                            );
              END IF;

              INSERT INTO mtl_serial_numbers_temp
                          (transaction_temp_id
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
                         , group_header_id
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
                          )
                   VALUES (l_sequence
                         , l_sysdate
                         , l_user_id
                         , l_sysdate
                         , l_user_id
                         , l_login_id
                         , l_ser_csr.request_id
                         , l_ser_csr.program_application_id
                         , l_ser_csr.program_id
                         , l_ser_csr.program_update_date
                         , l_ser_csr.vendor_serial_number
                         , l_ser_csr.vendor_lot_number
                         , l_ser_csr.serial_number
                         , l_ser_csr.serial_number
                         , l_ser_csr.parent_serial_number
                         , l_ser_csr.serial_attribute_category
                         , l_ser_csr.c_attribute1
                         , l_ser_csr.c_attribute2
                         , l_ser_csr.c_attribute3
                         , l_ser_csr.c_attribute4
                         , l_ser_csr.c_attribute5
                         , l_ser_csr.c_attribute6
                         , l_ser_csr.c_attribute7
                         , l_ser_csr.c_attribute8
                         , l_ser_csr.c_attribute9
                         , l_ser_csr.c_attribute10
                         , l_ser_csr.c_attribute11
                         , l_ser_csr.c_attribute12
                         , l_ser_csr.c_attribute13
                         , l_ser_csr.c_attribute14
                         , l_ser_csr.c_attribute15
                         , l_ser_csr.c_attribute16
                         , l_ser_csr.c_attribute17
                         , l_ser_csr.c_attribute18
                         , l_ser_csr.c_attribute19
                         , l_ser_csr.c_attribute20
                         , l_ser_csr.d_attribute1
                         , l_ser_csr.d_attribute2
                         , l_ser_csr.d_attribute3
                         , l_ser_csr.d_attribute4
                         , l_ser_csr.d_attribute5
                         , l_ser_csr.d_attribute6
                         , l_ser_csr.d_attribute7
                         , l_ser_csr.d_attribute8
                         , l_ser_csr.d_attribute9
                         , l_ser_csr.d_attribute10
                         , l_ser_csr.n_attribute1
                         , l_ser_csr.n_attribute2
                         , l_ser_csr.n_attribute3
                         , l_ser_csr.n_attribute4
                         , l_ser_csr.n_attribute5
                         , l_ser_csr.n_attribute6
                         , l_ser_csr.n_attribute7
                         , l_ser_csr.n_attribute8
                         , l_ser_csr.n_attribute9
                         , l_ser_csr.n_attribute10
                         , p_header_id
                         , l_ser_csr.attribute_category
                         , l_ser_csr.attribute1
                         , l_ser_csr.attribute2
                         , l_ser_csr.attribute3
                         , l_ser_csr.attribute4
                         , l_ser_csr.attribute5
                         , l_ser_csr.attribute6
                         , l_ser_csr.attribute7
                         , l_ser_csr.attribute8
                         , l_ser_csr.attribute9
                         , l_ser_csr.attribute10
                         , l_ser_csr.attribute11
                         , l_ser_csr.attribute12
                         , l_ser_csr.attribute13
                         , l_ser_csr.attribute14
                         , l_ser_csr.attribute15
                         , l_ser_csr.status_id
                         , l_ser_csr.territory_code
                         , l_ser_csr.time_since_new
                         , l_ser_csr.cycles_since_new
                         , l_ser_csr.time_since_overhaul
                         , l_ser_csr.cycles_since_overhaul
                         , l_ser_csr.time_since_repair
                         , l_ser_csr.cycles_since_repair
                         , l_ser_csr.time_since_visit
                         , l_ser_csr.cycles_since_visit
                         , l_ser_csr.time_since_mark
                         , l_ser_csr.cycles_since_mark
                         , l_ser_csr.number_of_repairs
                          );

              IF (l_debug = 1)
              THEN
                mydebug ('breadcrumb 200', 'tmpinsert2');
              END IF;
            END LOOP;

            /*Need to update the MTLT with the serial_transaction_temp_id generated above */
            IF (l_debug = 1)
            THEN
              mydebug
                    (' update the MTLT with the serial transaction temp_id '
                   , 'tmpinsert2'
                    );
              mydebug (' serial_txn_temp_id => ' || l_sequence
                         , 'tmpinsert2'
                          );
            END IF;

            UPDATE mtl_transaction_lots_temp
               SET serial_transaction_temp_id = l_sequence
             WHERE transaction_temp_id = l_mtli_csr.transaction_interface_id;
          END IF;  --if transaction lot split/merge

          IF (l_debug = 1)
          THEN
            mydebug ('Abt to populate the genealogy columns  '
                       , 'tmpinsert2'
                        );
            mydebug ('breadcrumb 210', 'tmpinsert2');
          END IF;

        /*****************************************************************************************
         *  Following genealogy columns need to be populated :-                                  *
         *  parent_object_number            : parent_serial_number                               *
         *  object_number2                  : current lot to which the serial number belong to   *
         *  parent_object_number2           : previous lot to which the serial number belonged to*
         *  Object_type2/parent_object_type2 : The type of object                                *
         *  This is how the colums are populated:-                                               *
         *  For lot split : populate the resulting MSNTs                                         *
         *  For lot merge : populate the source MSNTs                                            *
         *  For lot translate : populate the resulting MSNTs                                     *
         *****************************************************************************************/
          IF (l_mtli_csr.transaction_interface_id <> l_mti_csr.parent_id)
          THEN
            BEGIN
              IF (l_debug = 1)
              THEN
                mydebug ('breadcrumb 220', 'tmpinsert2');
              END IF;

              SELECT lot_number
                INTO l_parent_object_number2
                FROM mtl_transaction_lots_interface
               WHERE transaction_interface_id = l_mti_csr.parent_id;

              SELECT serial_transaction_temp_id
                INTO l_serial_temp_id
                FROM mtl_transaction_lots_temp
               WHERE transaction_temp_id = l_mtli_csr.transaction_interface_id;

              IF (l_debug = 1)
              THEN
                mydebug (   'l_parent_object_number2 => '
                             || l_parent_object_number2
                           , 'tmpinsert2'
                            );
                mydebug ('l_serial_temp_id => ' || l_serial_temp_id
                           , 'tmpinsert2'
                            );
              END IF;

              IF ((   l_mti_csr.transaction_action_id =
                                              inv_globals.g_action_inv_lot_split
                   OR l_mti_csr.transaction_action_id =
                                          inv_globals.g_action_inv_lot_translate
                  )
                 )
              THEN
                IF (l_debug = 1)
                THEN
                  mydebug ('breadcrumb 230', 'tmpinsert2');
                  mydebug (' Genealogy columns for lot split/translate '
                             , 'tmpinsert2'
                              );
                  mydebug (   'parent_object_number2 => '
                               || l_mtli_csr.lot_number
                             , 'tmpinsert2'
                              );
                  mydebug ('object_number2 => ' || l_parent_object_number2
                             , 'tmpinsert2'
                              );
                END IF;
                /*The behaviour here is taken from LotTrxManager.Bit Strange!*/
                UPDATE mtl_serial_numbers_temp
                   SET parent_object_number2 = l_mtli_csr.lot_number
                     , parent_object_number = fm_serial_number
                     , object_number2 = l_parent_object_number2
                     , object_type2 = 1
                     , parent_object_type2 = 1
                 WHERE transaction_temp_id =
                         NVL (l_mtli_csr.serial_transaction_temp_id --For Lot translate
                            , l_serial_temp_id
                             );
              ELSIF (l_mti_csr.transaction_action_id =
                                              inv_globals.g_action_inv_lot_merge
                    )
              THEN
                IF (l_debug = 1)
                THEN
                  mydebug ('breadcrumb 240', 'tmpinsert2');
                  mydebug (' Genealogy columns for lot merge '
                             , 'tmpinsert2'
                              );
                  mydebug (   'parent_object_number2 => '|| l_parent_object_number2
                             , 'tmpinsert2'
                              );
                  mydebug ('object_number2           => '|| l_mtli_csr.lot_number
                             , 'tmpinsert2'
                              );
                END IF;

                UPDATE mtl_serial_numbers_temp
                   SET parent_object_number2 = l_parent_object_number2
                     , parent_object_number = fm_serial_number
                     , object_number2 = l_mtli_csr.lot_number
                     , object_type2 = 1
                     , parent_object_type2 = 1
                 WHERE transaction_temp_id =
                                         l_mtli_csr.serial_transaction_temp_id;
              END IF;

              IF (l_debug = 1)
              THEN
                mydebug ('breadcrumb 250', 'tmpinsert2');
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
                IF (l_debug = 1)
                THEN
                  mydebug ('breadcrumb 260', 'tmpinsert2');
                  mydebug
                       ('NO_DATA_FOUND while fetching the genealogy columns'
                      , 'tmpinsert2'
                       );
                END IF;

                l_validation_status := 'N';
                RAISE fnd_api.g_exc_unexpected_error;
              WHEN OTHERS
              THEN
                IF (l_debug = 1)
                THEN
                  mydebug ('breadcrumb 270', 'tmpinsert2');
                  mydebug
                           ('exception while fetching the genealogy columns'
                          , 'tmpinsert2'
                           );
                END IF;

                l_validation_status := 'N';
                RAISE fnd_api.g_exc_unexpected_error;
            END;
          END IF;
         END IF;                                         --if serial_controlled
       END LOOP;--loop of MTLI
      END LOOP;                                                  --loop of MTI
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          mydebug ('breadcrumb 280', 'tmpinsert2');
          mydebug (' exception happened in tmpinsert2 ' || SQLERRM, 'tmpinsert2');
        END IF;

        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    /*All records processed successfully*/
    IF (l_debug = 1)
    THEN
      mydebug (' insertions done .. !! ', 'tmpinsert2');
    END IF;

    x_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      IF (l_debug = 1)
      THEN
        mydebug ('breadcrumb 290', 'tmpinsert2');
      END IF;

      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'tmpinert2');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END tmpinsert2;








/******************************************************************
 *
 * poget()
 *
 ******************************************************************/
PROCEDURE poget(p_prof IN VARCHAR2, x_ret OUT NOCOPY VARCHAR2)
IS
BEGIN
  SELECT FND_PROFILE.value(p_prof)
  INTO x_ret
  FROM dual;
END poget;







-----------------------------------------------------------------------
   -- Name : Validate_Transactions
   -- Desc : This procedure is used ot validate record inserted in MYI
   --through desktop forms AND moved TO mmtt. it does NOT call the
   --  transaction manager TO process the transactions.
   --        It is called to validate a batch of transaction_records .
   --
   -- I/P Params :
   --     p_header_id  : Transaction Header Id
   -- O/P Params :
   --     x_trans_count : count of transaction records validate
   --History
   --  Jalaj Srivastava Bug 5155661
   --    Add new parameter p_free_tree
   --  Namit Singhi Bug 5286961.
   --    Do not call the query_tree for gme yield transactions.
   -----------------------------------------------------------------------
   FUNCTION Validate_Transactions(
          p_api_version         IN     NUMBER            ,
          p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false     ,
          p_validation_level IN NUMBER  := fnd_api.g_valid_level_full  ,
          p_header_id           IN      NUMBER,
          x_return_status       OUT     NOCOPY VARCHAR2                        ,
          x_msg_count           OUT     NOCOPY NUMBER                          ,
          x_msg_data            OUT     NOCOPY VARCHAR2                        ,
          x_trans_count         OUT     NOCOPY NUMBER                          ,
          p_free_tree           IN      VARCHAR2 := fnd_api.g_true)

     RETURN NUMBER
     IS
        l_header_id NUMBER;
        l_source_header_id NUMBER;
        l_totrows NUMBER;
        l_initotrows NUMBER;
        l_midtotrows NUMBER;
        l_userid NUMBER;
        l_loginid NUMBER;
        l_progid NUMBER;
        l_applid NUMBER;
        l_reqstid NUMBER;
        l_trx_batch_id NUMBER;
        batch_error BOOLEAN;
        l_last_trx_batch_id NUMBER;
        line_vldn_error_flag VARCHAR(1);
        l_Line_Rec_Type inv_txn_manager_pub.Line_Rec_Type;

        l_tempid NUMBER;
        l_item_id NUMBER;
           l_org_id NUMBER;
        l_locid NUMBER;
        l_srctypeid NUMBER;
        l_actid NUMBER;
        l_srcid NUMBER;
        l_xlocid NUMBER;
        l_temp_rowid VARCHAR2(21);
        l_sub_code VARCHAR2(11);
        -- Increased lot size to 80 Char - Mercy Thomas - B4625329
        l_lotnum VARCHAR2(80);
        l_src_code VARCHAR2(30);
        l_xfrsub VARCHAR2(11);
        l_rev VARCHAR2(4);
        l_srclineid VARCHAR2(40);
        l_trxdate DATE;
        l_qoh NUMBER;
        l_rqoh NUMBER;
        l_pqoh NUMBER;
        l_qr NUMBER;
        l_qs NUMBER;
        l_att NUMBER;
        l_atr NUMBER;

        /* Added the following variables for Bug 3679189 */
        l_neg_inv_rcpt number;
        l_cnt_res number;
        l_item_qoh NUMBER;
        l_item_rqoh NUMBER;
        l_item_pqoh NUMBER;
        l_item_qr NUMBER;
        l_item_qs NUMBER;
        l_item_att NUMBER;
        l_item_atr NUMBER;

        /*Added following variables for Bug 4194323 */
        l_dem_hdr_id NUMBER ;
        l_dem_line_id NUMBER ;


        l_rctrl NUMBER;
        l_lctrl NUMBER;
        l_flow_schedule NUMBER;
        l_trx_qty NUMBER;
        l_qty  NUMBER := 0;
        tree_exists BOOLEAN;
        l_revision_control BOOLEAN;
        l_lot_control BOOLEAN;
        l_disp  VARCHAR2(3000);
        l_msg_count  NUMBER;
        l_msg_data   VARCHAR2(2000);
        l_return_status VARCHAR2(1);
        l_tree_id NUMBER;
        l_override_neg_for_backflush NUMBER := 0;
        l_override_rsv_for_backflush NUMBER := 2; --Bug 4764343 Base 4645686.Added for a specific customer.Default value is set to 'NO'(value 2)
        l_translate BOOLEAN := TRUE;
        /*Bug#5075521. Added the below 3 variables.*/
        l_current_batch_failed BOOLEAN := FALSE;
        l_current_err_batch_id NUMBER;
        l_count_success NUMBER;


        CURSOR AA1 IS
           SELECT
        TRANSACTION_INTERFACE_ID,
        TRANSACTION_HEADER_ID,
        REQUEST_ID,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        SUBINVENTORY_CODE,
        TRANSFER_ORGANIZATION,
        TRANSFER_SUBINVENTORY,
        TRANSACTION_UOM,
        TRANSACTION_DATE,
        TRANSACTION_QUANTITY,
        LOCATOR_ID,
        TRANSFER_LOCATOR,
        TRANSACTION_SOURCE_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_TYPE_ID,
        DISTRIBUTION_ACCOUNT_ID,
        NVL(SHIPPABLE_FLAG,'Y'),
        ROWID,
        NEW_AVERAGE_COST,
        VALUE_CHANGE,
        PERCENTAGE_CHANGE,
        MATERIAL_ACCOUNT,
        MATERIAL_OVERHEAD_ACCOUNT,
        RESOURCE_ACCOUNT,
        OUTSIDE_PROCESSING_ACCOUNT,
        OVERHEAD_ACCOUNT,
        REQUISITION_LINE_ID,
        OVERCOMPLETION_TRANSACTION_QTY,   /* Overcompletion Transactions */
        END_ITEM_UNIT_NUMBER,
        SCHEDULED_PAYBACK_DATE, /* Borrow Payback */
        REVISION,   /* Borrow Payback */
        ORG_COST_GROUP_ID,  /* PCST */
        COST_TYPE_ID, /* PCST */
        PRIMARY_QUANTITY,
        SOURCE_LINE_ID,
        PROCESS_FLAG,
        TRANSACTION_SOURCE_NAME,
        TRX_SOURCE_DELIVERY_ID,
        TRX_SOURCE_LINE_ID,
        PARENT_ID,
        TRANSACTION_BATCH_ID,
        TRANSACTION_BATCH_SEQ,
        -- INVCONV start fabdi
        SECONDARY_TRANSACTION_QUANTITY,
        SECONDARY_UOM_CODE
        -- INVCONV end fabdi
        ,SHIP_TO_LOCATION_ID -- eIB Build; Bug# 4348541
        ,TRANSFER_PRICE      -- OPM INVCONV umoogala Process-Discrete Xfers Enh.
        ,WIP_ENTITY_TYPE     -- Pawan  11th july added for subinventory issue
        /*Bug:5392366. Added following two columns. */
        ,COMPLETION_TRANSACTION_ID
        ,MOVE_TRANSACTION_ID
    FROM MTL_TRANSACTIONS_INTERFACE
    WHERE TRANSACTION_HEADER_ID = p_header_id
    AND PROCESS_FLAG = 1
   /* added for bug 4634810 */
    AND NOT( transaction_source_type_id = 5 AND
             NVL(operation_seq_num, 1) < 0 AND
             NVL(wip_supply_type, 0) = 6
            )
    ORDER BY TRANSACTION_BATCH_ID,TRANSACTION_BATCH_SEQ,ORGANIZATION_ID,
      INVENTORY_ITEM_ID,REVISION,SUBINVENTORY_CODE,LOCATOR_ID;



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
     --Jalaj Srivastava 5010595
     --for GME (wip_enity_type=10) select only non lot controlled items
     AND ((MSI.LOT_CONTROL_CODE = 1) OR (p_line_rec_type.transaction_source_type_id=5 and p_line_rec_type.wip_entity_type <> 10))--J-dev--verify this
     AND (    (     (p_line_rec_type.wip_entity_type <> 10)
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

   BEGIN
      l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

      l_header_id := p_header_id;

      IF (l_debug = 1)
        THEN
         inv_log_util.trace('-----Inside validate_Transactions-------.trxhdr='||p_header_id, 'INV_TXN_MANAGER_GRP', 9);
      END IF;


    /*----------------------------------------------------------+
    |  retrieving information
    +----------------------------------------------------------*/

    poget('LOGIN_ID', l_loginid);
    poget('USER_ID', l_userid);
    poget('CONC_PROGRAM_ID', l_progid);
    poget('CONC_REQUEST_ID', l_reqstid);
    poget('PROG_APPL_ID', l_applid);

    IF l_loginid is NULL THEN
    l_loginid := -1;
    END IF;
    IF l_userid is NULL THEN
    l_userid := -1;
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count  :=  0;
    x_msg_data := '';
    x_trans_count := 0;


    /*+--------------------------------------------------------------+
    | The global gi_flow_schedule will be '1' (or true) for        |
    | WIP flow schedules ONLY.                                     |
    +--------------------------------------------------------------+ */
      BEGIN
          SELECT DECODE(UPPER(FLOW_SCHEDULE),'Y', 1, 0)
            INTO gi_flow_schedule
            FROM MTL_TRANSACTIONS_INTERFACE
            WHERE TRANSACTION_HEADER_ID = l_header_id
            AND TRANSACTION_SOURCE_TYPE_ID = 5
            AND TRANSACTION_ACTION_ID IN (30,31, 32) --CFM Scrap Transactions
            AND PROCESS_FLAG = 1
            AND ROWNUM < 2 ;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            gi_flow_schedule := 0;
      END;

  --Group Validate
    /***** Group Validation *******************************/
    validate_group(l_header_id,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    l_userid,
                    l_loginid,
                    p_validation_level);

    IF x_return_status = FND_API.G_RET_STS_ERROR   THEN
        IF (l_debug = 1) THEN
          inv_log_util.trace('Unexpected Error in Validate Group : ' || x_msg_data,'INV_TXN_MANAGER_GRP', 9);
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    batch_error := FALSE;

    FOR l_Line_rec_Type IN AA1 LOOP

        l_trx_batch_id := l_Line_rec_Type.TRANSACTION_BATCH_ID;
        IF batch_error AND l_trx_batch_id = l_last_trx_batch_id THEN
          /** This group of transactions has failed move on to next **/
          /** UPDATE MTI row with Group Failure Message **/
          null;
        ELSE
          batch_error := FALSE;
          l_last_trx_batch_id := l_trx_batch_id;

          /* Bug 6679112, adding BEGIN-EXCEPTION-END */
          BEGIN  --validate_lines block

                  validate_lines( p_line_Rec_Type =>l_Line_rec_type,
                          p_validation_level =>p_validation_level,
                          p_error_flag =>line_vldn_error_flag,
                          p_userid => l_userid,
                          p_loginid => l_loginid,
                          p_applid => l_applid,
                          p_progid => l_progid
                          );
                 IF (line_vldn_error_flag = 'Y') then
                      IF (l_debug = 1) THEN
                        inv_log_util.trace('Error in Line Validatin', 'INV_TXN_MANAGER_GRP', 9);
                            END IF;
                      RAISE  fnd_api.g_exc_unexpected_error;
                      --SQL error
                END IF;
          EXCEPTION
          /* Added for Bug 6679112 */
                 WHEN others THEN
                        batch_error := TRUE;
                        IF (l_debug = 1) THEN
                                inv_log_util.trace('Error:'||sqlerrm,'INV_TXN_MANAGER_GRP', 9);
                        END IF;
          END; --validate_lines block
          /* Changes for bug 6679112 end */

        END IF;--BatchId
    END LOOP;--AA1


    /*-------------------------------------------------------------+
    | If a single transaction within a group fails all transactions
    | in that group should not be processed.
    +--------------------------------------------------------------*/


      --check for batch error at line validation
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
      AND EXISTS
          (SELECT 'Y'
             FROM MTL_TRANSACTIONS_INTERFACE MTI2
            WHERE MTI2.TRANSACTION_HEADER_ID = l_header_id
              AND MTI2.PROCESS_FLAG = 3
              AND MTI2.ERROR_CODE IS NOT NULL
              AND MTI2.TRANSACTION_BATCH_ID = MTI.TRANSACTION_BATCH_ID);

/* Commented following and Added EXISTS clause above for bug 8444982
      AND TRANSACTION_BATCH_ID IN
      (SELECT DISTINCT MTI2.TRANSACTION_BATCH_ID
        FROM MTL_TRANSACTIONS_INTERFACE MTI2
        WHERE MTI2.TRANSACTION_HEADER_ID = l_header_id
        AND MTI2.PROCESS_FLAG = 3
        AND MTI2.ERROR_CODE IS NOT NULL);
*/
        --                               group error changes.



        --Need to call the qty tree.
        --LOOP for each record
        --create tree
        --query tree
        --compare qty
        --UPDATE tree
        --END LOOP
    --clear all tree cache.

    IF (l_debug = 1) THEN
        inv_log_util.trace('Going to open cursor AA1', 'INV_TXN_MANAGER_GRP', 9);
    END IF;

    FOR l_Line_rec_Type IN AA1 LOOP
            /*Bug#5075521. Moved all the validation code inside the below IF condition so that
              the validation is done only if the current record does not belong to an errored
              batch.*/
      IF (    l_current_err_batch_id IS NULL
            OR l_Line_rec_Type.transaction_batch_id IS NULL
            OR l_current_err_batch_id <>  l_Line_rec_Type.transaction_batch_id )THEN --050
        l_current_batch_failed := FALSE;
        FOR z1_rec IN
          Z1(gi_flow_schedule,l_Line_rec_type) LOOP

            tree_exists := FALSE;

          IF (l_debug = 1) THEN
                  inv_log_util.trace('Getting values from Z1 cursor', 'INV_TXN_MANAGER_GRP', 9);
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
                  inv_log_util.trace('Calling Create tree', 'INV_TXN_MANAGER_GRP', 9);
            END IF;

          -- Bug 4194323 WIP Assembly Return transactions need to look for Available Quantity against the Sales Order
          --  if it's linked to job

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
                                                     || x_msg_data,'INV_TXN_MANAGER_GRP', 9);
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
                                     inv_log_util.trace('After create tree tree : ' || l_msg_data,'INV_TXN_MANAGER_GRP', 9);
                                  END IF;



                               IF l_return_status IN (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) THEN
                                  IF (l_debug = 1) THEN
                                     inv_log_util.trace('Error while creating tree : x_msg_data = ' || l_msg_data,'INV_TXN_MANAGER_GRP', 9);
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
--                               group error changes.

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
                                     inv_log_util.trace('Expected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_GRP', 9);
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
--                               group error changes.
                                  l_current_batch_failed := TRUE;--Bug#5075521
                                  l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521

                               END IF ;

                               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                  IF (l_debug = 1) THEN
                                     inv_log_util.trace('UnExpected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_GRP', 9);
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
                               inv_log_util.trace('L_QOH : ' || l_qoh,'INV_TXN_MANAGER_GRP', 9);
                               inv_log_util.trace('L_RQOH : ' || l_rqoh,'INV_TXN_MANAGER_GRP', 9);
                               inv_log_util.trace('L_PQOH : ' || l_pqoh,'INV_TXN_MANAGER_GRP', 9);
                               inv_log_util.trace('L_QR : ' || l_qr,'INV_TXN_MANAGER_GRP', 9);
                               inv_log_util.trace('L_QS : ' || l_qs,'INV_TXN_MANAGER_GRP', 9);
                               inv_log_util.trace('L_ATT : ' || l_att,'INV_TXN_MANAGER_GRP', 9);
                               inv_log_util.trace('L_ATR : ' || l_atr,'INV_TXN_MANAGER_GRP', 9);
                               END IF;
                               END IF;--100

                               -- Bug 3427817: For WIP backflush transactions, we should not
                               -- check for negative availability. If it is
                               -- a backflush transaction, then get the
                               -- profile value and do not check for
                               -- availability if the profile is set to
                               -- YES.

                               IF ( NOT l_current_batch_failed ) THEN--150

                               -- nsinghi bug#5286961. Do not call the query_tree for gme yield transactions.

                               IF ((l_Line_rec_Type.wip_entity_type <> 10) OR -- not GME
                               (l_Line_rec_Type.wip_entity_type = 10 AND
                               l_line_rec_Type.transaction_type_id NOT IN (43, 44, 1002))) THEN

                                 /*Bug:5392366. Modified the following condition to also check
                                   completion_transaction_id and move_transaction_id to make sure it
                                   is a backflush transaction. If both these values are null then
                                   it is is not a backflush transaction*/
                                 IF ((l_line_rec_Type.transaction_source_type_id = inv_globals.G_SOURCETYPE_WIP) AND
                                     (l_line_rec_Type.transaction_action_id
                                      IN (inv_globals.G_ACTION_ISSUE, inv_globals.G_ACTION_NEGCOMPRETURN) AND (l_line_rec_type.completion_transaction_id is not null OR l_line_rec_type.move_transaction_id is not null))) THEN
                                    -- It is a backflush transaction. Get the
                                    -- override flag.
                                    l_override_neg_for_backflush :=
                                      fnd_profile.value('INV_OVERRIDE_NEG_FOR_BACKFLUSH');
                                    /*Bug 4764343 Base Bug:4645686. Introducing a new profile
                                    'INV_OVERRIDE_RSV_FOR_BACKFLUSH' for a specific customer.If set to 'Yes',
                                    backflush transaction can drive inventory negative, even if any reservations
                                    exist for the item*/
                                  l_override_rsv_for_backflush := NVL(fnd_profile.value('INV_OVERRIDE_RSV_FOR_BACKFLUSH'), 2);
                                 ELSE
                                   l_override_neg_for_backflush := 0;
                                   l_override_rsv_for_backflush := 2;
                                 END IF;
                                 IF (l_debug = 1) THEN
                                    inv_log_util.trace('l_override_neg_for_backflush ' || l_override_neg_for_backflush,'INV_TXN_MANAGER_GRP', 9);
                                    inv_log_util.trace('l_override_rsv_for_backflush ' || l_override_rsv_for_backflush,'INV_TXN_MANAGER_GRP', 9);
                                 END IF;

                                 --Bug 3487453: Added and set the variable l_translate
                                 -- to true for the token to be translated.
                                 IF  (l_att < l_trx_qty) THEN
                                    IF (l_neg_inv_rcpt = 1 OR l_override_neg_for_backflush = 1) THEN

                                       IF (l_qr >l_trx_qty  OR l_qs >0) THEN
                                          /*Bug 4764343 base Bug::4645686. This condition is added for a specific customer by introducing
                                           a new profile 'INV_OVERRIDE_RSV_FOR_BACKFLUSH' . If this profile is not set to 'Yes'
                                           then the backflush transaction can not consume existing reservations.Else it can consume
                                           existing reservation and can drive inventory go negative. */
                                          IF (l_override_rsv_for_backflush <> 1 ) THEN
                                          inv_log_util.trace('Transaction quantity must be less than or equal to available quantity','INV_TXN_MANAGER_GRP', 9);
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
                                             --                               group error changes.
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
                                             inv_log_util.trace('Expected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_GRP', 9);
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
                                             --                               group error changes.
                                             l_current_batch_failed := TRUE;--Bug#5075521
                                             l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
                                       END IF ;

                                       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                          IF (l_debug = 1) THEN
                                             inv_log_util.trace('UnExpected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_GRP', 9);
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
                                       inv_log_util.trace('L_ITEM_QOH : ' || l_item_qoh,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_ITEM_RQOH : ' || l_item_rqoh,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_ITEM_PQOH : ' || l_item_pqoh,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_ITEM_QR : ' || l_item_qr,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_ITEM_QS : ' || l_item_qs,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_ITEM_ATT : ' || l_item_att,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_ITEM_ATR : ' || l_item_atr,'INV_TXN_MANAGER_GRP', 9);
                                       inv_log_util.trace('L_TRX_QTY : ' || l_trx_qty,'INV_TXN_MANAGER_GRP', 9);

                                       IF ( NOT l_current_batch_failed) THEN --250
                                       IF (l_item_qoh <> l_item_att) THEN -- Higher Level Reservations
                                          IF (l_item_att < l_trx_qty AND l_item_qr > 0) THEN
                                          /*Bug 4764343 Base Bug::4645686. This condition is added for a specific customer by introducing
                                           a new profile 'INV_OVERRIDE_RSV_FOR_BACKFLUSH' . If this profile is not set to 'Yes'then the
                                           backflush transaction can not consume existing reservations.Else it can consume existing
                                           reservation and can drive inventory  negative. */
                                          IF (l_override_rsv_for_backflush <> 1 ) THEN
                                             inv_log_util.trace('Total Org quantity cannot become negative when there are reservations present','INV_TXN_MANAGER_GRP', 9);
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
                                            inv_log_util.trace('Not Enough Qty: l_att,l_trx_qty:' || l_att||','||l_trx_qty,'INV_TXN_MANAGER_GRP', 9);
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
                               END IF; --nsinghi bug#5286961 l_Line_rec_Type.wip_entity_type = 10


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
                                     inv_log_util.trace('after update of quantity tree qoh='||l_qoh||' l_att='||l_att||' l_atr='||l_atr,'INV_TXN_MANAGER_GRP', 9);
                                   END IF;
                                 END IF;
                               END IF;-- Pawan Added for IF (l_actid in (2,28))
                               END IF; --300
                              END IF; --150
                              END LOOP;--
                           END IF;--050
                                 /* This should be for any error other than not found */
                                 --IF z1%OPEN
                                 --CLOSE Z1;
                                 --------------Qty tree end

                            END LOOP; --AA1

                            --free all trees created so far.
                            /* INV_QUANTITY_TREE_PVT.free_All
                            (   p_api_version_number   => 1.0
                              ,  p_init_msg_lst         => fnd_api.g_false
                              ,  x_return_status        => l_return_status
                              ,  x_msg_count            => l_msg_count
                              ,  x_msg_data             => l_msg_data); */

                              --Jalaj Srivastava Bug 4672291
                              --Call free_tree only when l_tree_id is not null
                              --Jalaj Srivastava Bug 5155661
                              --free the tree only if p_free_tree is true
                              IF    (p_free_tree = fnd_api.G_TRUE)
                                AND (l_tree_id IS NOT NULL) THEN
                                INV_QUANTITY_TREE_PVT.free_tree
                                  (  p_api_version_number  => 1.0
                                   , p_init_msg_lst        => fnd_api.g_false
                                   , x_return_status       => l_return_status
                                   , x_msg_count           => l_msg_count
                                   , x_msg_data            => l_msg_data
                                   , p_tree_id              => l_tree_id );
                              END IF;

                              SELECT COUNT(*)
                              INTO l_count_success
                              FROM mtl_transactions_interface
                              WHERE transaction_header_id = l_header_id
                                AND process_flag = 1;

                              IF (l_count_success = 0) THEN
                                  RETURN -1;
                              END IF;

                            -- ADD tmp Insert here. In case of an error
                            --return -1.
                            --J-dev

                            IF (NOT tmpinsert(l_header_id,p_validation_level)) THEN
                               l_error_exp := FND_MESSAGE.get;
                               IF (l_debug = 1) THEN
                                  inv_log_util.trace('Error in tmpinsert='|| l_error_exp, 'INV_TXN_MANAGER_GRP', 9);
                               END IF;
                               FND_MESSAGE.set_name('INV','INV_INT_TMPXFRCODE');
                               l_error_code := FND_MESSAGE.get;
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
                                 WHERE TRANSACTION_HEADER_ID =l_header_id
                                 AND PROCESS_FLAG = 1;

                               return -1;
                             ELSE
                               --delete from mti/mtli/msni

                               DELETE FROM MTL_SERIAL_NUMBERS_INTERFACE
                                 WHERE TRANSACTION_INTERFACE_ID
                                 IN(
                                    SELECT TRANSACTION_INTERFACE_ID
                                    FROM MTL_TRANSACTIONS_INTERFACE
                                    WHERE TRANSACTION_HEADER_ID =l_header_id
                                    AND PROCESS_FLAG <> 3
                                 union all
                                 SELECT SERIAL_TRANSACTION_TEMP_ID
                                 FROM MTL_TRANSACTION_LOTS_INTERFACE
                                 WHERE TRANSACTION_INTERFACE_ID
                                 IN (
                                      SELECT TRANSACTION_INTERFACE_ID
                                      FROM MTL_TRANSACTIONS_INTERFACE
                                      WHERE TRANSACTION_HEADER_ID = l_header_id
                                      AND PROCESS_FLAG <> 3 )) ;
                               DELETE FROM MTL_TRANSACTION_LOTS_INTERFACE
                                 WHERE TRANSACTION_INTERFACE_ID IN
                                 (SELECT TRANSACTION_INTERFACE_ID
                                  FROM MTL_TRANSACTIONS_INTERFACE
                                  WHERE TRANSACTION_HEADER_ID =l_header_id
                                  AND PROCESS_FLAG <> 3);
                               DELETE FROM MTL_TRANSACTIONS_INTERFACE
                                 WHERE TRANSACTION_HEADER_ID = l_header_id
                                 AND PROCESS_FLAG <> 3;
                               IF (l_debug = 1) THEN
                                  inv_log_util.trace('*** Del recs mti valid trx', 'INV_TXN_MANAGER_GRP',9);
                               END IF;
                            END IF;--tmpinsert

                            return 0;--return success.


 EXCEPTION
   WHEN OTHERS THEN
        IF (l_debug = 1) THEN
        inv_log_util.trace('*** SQL error '||substr(sqlerrm, 1, 200), 'INV_TXN_MANAGER_GRP',9);
        END IF;

          FND_MESSAGE.set_name('INV','INV_INT_SQLCODE');
          l_error_code := FND_MESSAGE.get;

          UPDATE MTL_TRANSACTIONS_INTERFACE
             SET LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = l_userid,
                 LAST_UPDATE_LOGIN = l_loginid,
                 PROGRAM_UPDATE_DATE = SYSDATE,
                 PROCESS_FLAG = 3,
                 LOCK_FLAG = 2,
                 ERROR_CODE = substrb(l_error_code,1,240),
                 ERROR_EXPLANATION = substrb(l_error_exp,1,240)
           WHERE TRANSACTION_HEADER_ID = l_header_id
             AND PROCESS_FLAG = 1;

          return -1;


   END Validate_Transactions;



FUNCTION Validate_Additional_Attr(
       p_api_version            IN     NUMBER
     , p_init_msg_list          IN      VARCHAR2 := fnd_api.g_false
         , p_validation_level           IN      NUMBER  := fnd_api.g_valid_level_full
         , p_intid                                      IN     NUMBER
         , p_rowid                  IN     VARCHAR2
     , p_inventory_item_id      IN     NUMBER
     , p_organization_id        IN     NUMBER
     , p_lot_number             IN     VARCHAR2
     , p_grade_code             IN OUT NOCOPY    VARCHAR2
     , p_retest_date            IN OUT NOCOPY    DATE
     , p_maturity_date          IN OUT NOCOPY    DATE
     , p_parent_lot_number      IN OUT NOCOPY    VARCHAR2
     , p_origination_date       IN OUT NOCOPY    DATE
     , p_origination_type       IN OUT NOCOPY    NUMBER
     , p_expiration_action_code IN OUT NOCOPY    VARCHAR2
     , p_expiration_action_date IN OUT NOCOPY    DATE
     , p_expiration_date        IN OUT NOCOPY    DATE
     , p_hold_date                  IN OUT NOCOPY    DATE
         , p_reason_id              IN OUT NOCOPY    NUMBER
         , p_copy_lot_attribute_flag IN  VARCHAR2
         , x_return_status       OUT NOCOPY VARCHAR2
         , x_msg_count           OUT NOCOPY NUMBER
     , x_msg_data            OUT NOCOPY VARCHAR2        )
RETURN BOOLEAN
IS

  /* get lot record info  */
   CURSOR  c_get_lot_record ( p_orgid NUMBER, p_itemid NUMBER, p_lotnum VARCHAR2)
   IS
   SELECT  *
     FROM  mtl_lot_numbers
    WHERE  lot_number        = p_lotnum
      AND  inventory_item_id = p_itemid
      AND  organization_id   = p_orgid;

   l_lot_record    c_get_lot_record%ROWTYPE;
   l_parent_lot_record    c_get_lot_record%ROWTYPE;

   /* Get reason code info */
   CURSOR c_get_reason_info  IS
    SELECT MTR.REASON_ID
    FROM MTL_TRANSACTION_REASONS MTR
    WHERE MTR.REASON_ID = p_reason_id
    AND NVL(MTR.DISABLE_DATE, SYSDATE + 1) > SYSDATE;

    /* get item information */
    CURSOR  c_get_item_info IS
    select RETEST_INTERVAL,
               EXPIRATION_ACTION_INTERVAL ,
                   SHELF_LIFE_CODE,
                   MATURITY_DAYS,
                   HOLD_DAYS,
                   CHILD_LOT_FLAG ,
                   GRADE_CONTROL_FLAG
        from mtl_system_items
        WHERE inventory_item_id = p_inventory_item_id
    AND  organization_id   = p_organization_id;


  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(3000);


  l_api_version        NUMBER         := 1.0;
  l_init_msg_list      VARCHAR2(3)    := 'F';
  l_commit             VARCHAR2(3)    := 'F';


  -- FABDI
    l_userid NUMBER := -1; --prg_info.userid;
    l_reqstid NUMBER := -1; -- prg_info.reqstid;
    l_applid NUMBER := -1; -- prg_info.appid;
    l_progid NUMBER := -1; -- prg_info.progid;
    l_loginid NUMBER := -1; -- prg_info.loginid;

    l_retest_interval NUMBER;
    l_exp_action_interval NUMBER;
    l_shelf_life_code  NUMBER;
    l_maturity_days   NUMBER;
    l_hold_days      NUMBER;
    l_reason_id      NUMBER;
    l_check BOOLEAN := TRUE;

    l_parent_lot_number VARCHAR2(80);
    l_lot_number VARCHAR2(80);
    l_itemid   NUMBER;
    l_orgid    NUMBER;

    l_child_lot_flag VARCHAR2(1);
    l_grade_control_flag VARCHAR2(1);

    l_new_parent_lot BOOLEAN ;
    l_new_child_lot BOOLEAN ;
    l_lot_onhand NUMBER; --Bug#7139549
    l_orig_date              DATE;
 l_existing_pending_lot NUMBER := 0; --bug#7425435
      --bug#7425435
   x_lot_rec                  MTL_LOT_NUMBERS%ROWTYPE;
   l_in_lot_rec               MTL_LOT_NUMBERS%ROWTYPE;
    l_source                   NUMBER;

  BEGIN

         IF (l_debug is null)
         THEN
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
         END IF;

     IF (l_debug = 1) THEN
                inv_log_util.trace('inside Validate_Additional_Attr' , 'INV_TXN_MANAGER_GRP', 9);
     END IF;



    /* Get Lot Child Information*/
    OPEN c_get_lot_record (p_organization_id, p_inventory_item_id, p_lot_number);
    FETCH c_get_lot_record INTO l_lot_record;

    IF  c_get_lot_record%NOTFOUND
    THEN
        -- dbms_output.put_line('New Lot Child  ');
        l_new_child_lot := TRUE;
    ELSE
      /*Bug#7139549 check if the lot exists but it is a pending product lot */

        SELECT count(1) into l_lot_onhand
        FROM   mtl_onhand_quantities_detail
        WHERE  INVENTORY_ITEM_ID = p_inventory_item_id
        AND    ORGANIZATION_ID = p_organization_id
        AND    lot_number = p_lot_number
        AND    PRIMARY_TRANSACTION_QUANTITY > 0
        AND    rownum = 1;

        IF (l_lot_onhand = 0) THEN
	     l_existing_pending_lot := 1; --Bug#9761494
             inv_calculate_exp_date.get_origination_date
                     (  p_inventory_item_id    => p_inventory_item_id
                       ,p_organization_id      => p_organization_id
                       ,p_lot_number           => p_lot_number
                       ,x_orig_date            => l_orig_date
                       ,x_return_status        => l_return_status
                     );

             IF l_return_status <> 'S' THEN
              IF (l_debug = 1) THEN
                inv_log_util.trace('Error from get_origination_date', 'INV_TXN_MANAGER_GRP', 9);
              END IF;
               CLOSE c_get_lot_record;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
        --  dbms_output.put_line('Existing Lot Child  ');
          IF (l_orig_date IS NULL AND p_expiration_date IS NULL) THEN
           IF (l_debug = 1) THEN
             inv_log_util.trace('existing pending lot having no expiry date', 'INV_TXN_MANAGER_GRP', 9);
           END IF;
           l_new_child_lot := TRUE;
          END IF; --expiration date null
        ELSE
           IF (l_debug = 1) THEN
             inv_log_util.trace('new lot', 'INV_TXN_MANAGER_GRP', 9);
           END IF;
          l_new_child_lot := FALSE;
        END IF; --lot onhand condition
    END IF;

    CLOSE c_get_lot_record;

    if p_parent_lot_number IS NOT NULL
    THEN
        /* Get Parent Lot Child Information*/
        OPEN c_get_lot_record (p_organization_id, p_inventory_item_id, p_parent_lot_number);
        FETCH c_get_lot_record INTO l_parent_lot_record;

        IF  c_get_lot_record%NOTFOUND
        THEN
                -- dbms_output.put_line('New Lot Parent Lot ' );
                l_new_parent_lot := TRUE;
        Else
                -- dbms_output.put_line('Existing Parent Lot ' );
                l_new_parent_lot := FALSE;
        END IF;
        CLOSE c_get_lot_record;
    ELSE
                -- dbms_output.put_line('No Parent Lot  ' );
                l_new_parent_lot := FALSE;
    END IF;



    /* Get item info */
    OPEN c_get_item_info;
    FETCH c_get_item_info INTO l_retest_interval,  l_exp_action_interval, l_shelf_life_code,
                                        l_maturity_days, l_hold_days, l_child_lot_flag, l_grade_control_flag;
    CLOSE c_get_item_info;

    /* Check Lot */
    IF (l_new_child_lot) THEN

      IF (l_debug = 1) THEN
                inv_log_util.trace('Validate_Additional_Attr: This is a New Lot : ' , 'INV_TXN_MANAGER_GRP', 9);
      END IF;

      /* defult missing values */
      l_lot_record.inventory_item_id  := p_inventory_item_id ;
      l_lot_record.organization_id := p_organization_id ;

      l_lot_record.lot_number := p_lot_number ;
     /*Bug#9007238 Added the below nvl condition */
      l_lot_record.parent_lot_number := nvl(p_parent_lot_number,l_lot_record.parent_lot_number);

      l_lot_record.grade_code := p_grade_code ;
      l_lot_record.retest_date := p_retest_date ;
          l_lot_record.maturity_date := p_maturity_date ;

      l_lot_record.origination_date  := NVL(p_origination_date, SYSDATE);

      l_lot_record.origination_type := p_origination_type ;
      l_lot_record.expiration_action_code := p_expiration_action_code ;
      l_lot_record.expiration_action_date := p_expiration_action_date ;
      l_lot_record.hold_date := p_hold_date ;
      /*Fixed for bug#6626120
        Lot record is initialized with exp date if lot expiration is 'user defined'.
        This code ensure that for user defined the exp date passed is not ignored
        and not assigned to null.
        For shelf life day the exp date is always calcualted so no need to
        initialize for that case. If we initalize for that as well then
        system will not calculate the exp date for shel life days hence will
        break the functionality. Hence the initialzation is done
        conditionally.
      */
       if l_shelf_life_code = 4 and p_expiration_date is not null then
          l_lot_record.expiration_date :=p_expiration_date;
       end if;

      -- dbms_output.put_line('l_copy_lot_attribute_flag   ' || p_copy_lot_attribute_flag   );

      IF (l_debug = 1) THEN
                inv_log_util.trace('Validate_Additional_Attr: p_copy_lot_attribute_flag   ' || p_copy_lot_attribute_flag , 'INV_TXN_MANAGER_GRP', 9);
       END IF;

      IF ((p_parent_lot_number IS NOT NULL) AND
                 (l_child_lot_flag = 'Y'))
      THEN
        IF p_copy_lot_attribute_flag = 'N'
        THEN
                    IF (l_debug = 1) THEN
                                inv_log_util.trace('Calling   Inv_Lot_API_PKG.Set_Msi_Default_Attr (1) ' , 'INV_TXN_MANAGER_GRP', 9);
                END IF;
            -- dbms_output.put_line('Calling   Inv_Lot_API_PKG.Set_Msi_Default_Attr (1 )');
                /* Default attributes for lot from item master */
                -- inv_lot_api_pub.Set_Msi_Default_Attr(p_lot_rec  => l_lot_record);

            Inv_Lot_API_PKG.Set_Msi_Default_Attr ( p_lot_rec           => l_lot_record
                                                                                  , x_return_status     => l_return_status
                                                  , x_msg_count         => l_msg_count
                                                  , x_msg_data         => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success
                    THEN
                                        l_error_code := l_msg_data;
                                        l_error_exp := l_msg_data;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                p_grade_code                    :=   l_lot_record.grade_code;
                p_retest_date                   :=       l_lot_record.retest_date;
                        p_maturity_date                 :=   l_lot_record.maturity_date;
                p_origination_date              :=   l_lot_record.origination_date;
                p_origination_type              :=   l_lot_record.origination_type;
                p_expiration_action_code        :=   l_lot_record.expiration_action_code;
                p_expiration_action_date  :=   l_lot_record.expiration_action_date;
                p_hold_date                             :=      l_lot_record.hold_date;
                p_expiration_date           := l_lot_record.expiration_date;
        ELSE
         -- Default attributes form Parent lot
         OPEN c_get_lot_record (p_organization_id, p_inventory_item_id, l_lot_record.parent_lot_number);
         FETCH c_get_lot_record INTO l_parent_lot_record;
         CLOSE c_get_lot_record;
         /* Check if Parent lot exists */
         IF NOT (l_new_parent_lot)
                 THEN
                    IF (l_debug = 1) THEN
                                inv_log_util.trace('Validate_Additional_Attr: Parent lot EXISTS   ' , 'INV_TXN_MANAGER_GRP', 9);
                END IF;
            if p_expiration_date is null
            then
                        p_expiration_date                       :=    l_parent_lot_record.expiration_date;
                        end if;

                    IF p_grade_code IS NULL
                    THEN
                        p_grade_code                    :=    l_parent_lot_record.grade_code;
                    END IF;
                    IF p_retest_date IS NULL
                    THEN
                p_retest_date                           :=        l_parent_lot_record.retest_date;
                END IF;
                    IF p_maturity_date IS NULL
                    THEN
                                p_maturity_date                 :=    l_parent_lot_record.maturity_date;
                        END IF;
                    IF p_origination_date IS NULL
                    THEN
                        p_origination_date              :=    l_parent_lot_record.origination_date;
                END IF;
                    IF p_origination_type IS NULL
                    THEN
                        p_origination_type              :=    l_parent_lot_record.origination_type;
                END IF;
                    IF p_expiration_action_code IS NULL
                    THEN
                        p_expiration_action_code :=   l_parent_lot_record.expiration_action_code;
                END IF;
                    IF p_expiration_action_date IS NULL
                    THEN
                        p_expiration_action_date :=   l_parent_lot_record.expiration_action_date;
                END IF;
                    IF p_hold_date IS NULL
                    THEN
                        p_hold_date                      :=   l_parent_lot_record.hold_date;
                END IF;
             Else
                -- dbms_output.put_line('Parent lot does not EXISTS, default from item '  );
                    IF (l_debug = 1) THEN
                                inv_log_util.trace('Calling   Inv_Lot_API_PKG.Set_Msi_Default_Attr (2) ' , 'INV_TXN_MANAGER_GRP', 9);
                END IF;

             /* new parent lot , default from item master */

           Inv_Lot_API_PKG.Set_Msi_Default_Attr (
                    p_lot_rec           => l_lot_record
                  , x_return_status     => l_return_status
                  , x_msg_count         => l_msg_count
                  , x_msg_data         => l_msg_data
                  );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                        l_error_code := l_msg_data;
                                        l_error_exp := l_msg_data;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                p_grade_code                    :=   l_lot_record.grade_code;
                p_retest_date                   :=       l_lot_record.retest_date;
                        p_maturity_date                 :=   l_lot_record.maturity_date;
                p_origination_date              :=   l_lot_record.origination_date;
                p_origination_type              :=   l_lot_record.origination_type;
                p_expiration_action_code        :=   l_lot_record.expiration_action_code;
                p_expiration_action_date  :=   l_lot_record.expiration_action_date;
                p_hold_date                             :=      l_lot_record.hold_date;
                p_expiration_date           := l_lot_record.expiration_date;
             END IF;
            END IF; -- end copy lot attrib check
           ELSE
                 -- dbms_output.put_line('lot is new and Item is not child lot enabled  ' );
            /* lot is new and Item is not child lot enabled */

                    IF (l_debug = 1) THEN
                                inv_log_util.trace('Calling   Inv_Lot_API_PKG.Set_Msi_Default_Attr (3) ' , 'INV_TXN_MANAGER_GRP', 9);
                END IF;

            Inv_Lot_API_PKG.Set_Msi_Default_Attr (
                    p_lot_rec           => l_lot_record
                  , x_return_status     => l_return_status
                  , x_msg_count         => l_msg_count
                  , x_msg_data         => l_msg_data
                  );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                        l_error_code := l_msg_data;
                                        l_error_exp := l_msg_data;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                p_grade_code                    :=   l_lot_record.grade_code;
                p_retest_date                   :=       l_lot_record.retest_date;
                        p_maturity_date                 :=   l_lot_record.maturity_date;
                p_origination_date              :=   l_lot_record.origination_date;
                p_origination_type              :=   l_lot_record.origination_type;
                p_expiration_action_code        :=   l_lot_record.expiration_action_code;
                p_expiration_action_date  :=   l_lot_record.expiration_action_date;
                p_hold_date                             :=      l_lot_record.hold_date;
                p_expiration_date           := l_lot_record.expiration_date;
          END IF;



      l_itemid   := p_inventory_item_id;
      l_orgid    := p_organization_id;
/*
          dbms_output.put_line('***************************************' );
      dbms_output.put_line('grade code ' || p_grade_code  );
      dbms_output.put_line('retest date ' || p_retest_date   );
          dbms_output.put_line('maturity date ' || p_maturity_date  );
      dbms_output.put_line('origination date ' || p_origination_date   )  ;
      dbms_output.put_line('origination type ' || p_origination_type   );
      dbms_output.put_line('expiration action Code ' || p_expiration_action_code   );
      dbms_output.put_line('expiration action date ' || p_expiration_action_date   );
      dbms_output.put_line('Hold date ' || p_hold_date   );
      dbms_output.put_line('expiration date ' || p_expiration_date   );
          dbms_output.put_line('***************************************' );
*/

      /* VALIDATE parent/child lot number */
          l_check := INV_LOT_ATTR_PUB.validate_child_lot( p_parent_lot_number => p_parent_lot_number
                                                                                                        ,p_lot_number               => p_lot_number
                                                                                                        ,p_org_id                       => l_orgid
                                                                                                        ,p_inventory_item_id  => l_itemid
                                                                                                        ,p_child_lot_flag     => l_child_lot_flag
                                                                                                        ,x_return_status      => l_return_status
                                                                                                        ,x_msg_count          => l_msg_count
                                                                                                        ,x_msg_data           => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;

                END IF;

        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_child_lot pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;


        /******************* START Grade Code validation logic ********************/
        l_check := INV_LOT_ATTR_PUB.validate_grade_code( p_grade_code                   => p_grade_code
                                                                                        , p_org_id              => l_orgid
                                                                                        , p_inventory_item_id   => l_itemid
                                                                                        , p_grade_control_flag  => l_grade_control_flag
                                                                                        , x_return_status               => l_return_status
                                                                                        , x_msg_count                   => l_msg_count
                                                                                        , x_msg_data                    => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_grade_code pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

                  /******************* START Origination Type validation logic ********************/
          l_check := INV_LOT_ATTR_PUB.validate_origination_type(  p_origination_type => p_origination_type
                                                                                                                                , x_return_status        => l_return_status
                                                                                                                                , x_msg_count                => l_msg_count
                                                                                                                                , x_msg_data                => l_msg_data);
              IF NOT(l_check)
                  THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_origination_type pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;


          -- dbms_output.put_line('Validate_Additional_Attr: Origination type validation - PASS...');

        /******************* START Expiration Action Code validation logic ********************/
        l_check := INV_LOT_ATTR_PUB.validate_exp_action_code( p_expiration_action_code => p_expiration_action_code
                                                                                                                        , p_org_id => l_orgid
                                                                                                                        , p_inventory_item_id => l_itemid
                                                                                                                        , p_shelf_life_code => l_shelf_life_code
                                                                                                                        , x_return_status => l_return_status
                                                                                                                        , x_msg_count => l_msg_count
                                                                                                                        , x_msg_data => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
       IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_exp_action_code pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

        -- dbms_output.put_line('Validate_Additional_Attr: Expiration Action Code validation - PASS...');

        /******************* START Retest Date validation logic ********************/
        l_check := INV_LOT_ATTR_PUB.validate_retest_date(p_retest_date          => p_retest_date
                                                                                                                ,p_origination_date       => p_origination_date
                                                                                                                ,x_return_status         => l_return_status
                                                                                                                ,x_msg_count              => l_msg_count
                                                                                                                ,x_msg_data                       => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_retest_date pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

        /******************* START Expiration Action Date validation logic ********************/
         l_check := INV_LOT_ATTR_PUB.validate_exp_action_date( p_expiration_action_date => p_expiration_action_date
                                                                                                                         , p_expiration_date => p_expiration_date
                                                                                                                         , x_return_status => l_return_status
                                                                                                                         , x_msg_count => l_msg_count
                                                                                                                         , x_msg_data => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;

                END IF;
        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_exp_action_date pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;


        /******************* START Maturity Date validation logic ********************/
        l_check := INV_LOT_ATTR_PUB.validate_maturity_date( p_maturity_date => p_maturity_date
                                                                                                                   ,p_origination_date => p_origination_date
                                                                                                                   ,x_return_status => l_return_status
                                                                                                                   ,x_msg_count => l_msg_count
                                                                                                                   ,x_msg_data => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_maturity_date pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

        /******************* START Hold Date validation logic ********************/
        l_check := INV_LOT_ATTR_PUB.validate_hold_date( p_hold_date => p_hold_date
                                                                                                                   ,p_origination_date => p_origination_date
                                                                                                                   ,x_return_status => l_return_status
                                                                                                                   ,x_msg_count => l_msg_count
                                                                                                                   ,x_msg_data => l_msg_data);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
       IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_hold_date pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

                /******************* START Reason Code validation logic ********************/
            l_check := INV_LOT_ATTR_PUB.validate_reason_code( p_reason_code => null
                                                                                                                 ,p_reason_id => p_reason_id
                                                                                                                 ,x_return_status => l_return_status
                                                                                                                 ,x_msg_count => l_msg_count
                                                                                                                 ,x_msg_data => l_msg_count);
                IF NOT(l_check)
                THEN
                        l_error_code := l_msg_data;
                        l_error_exp := l_msg_data;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
        IF (l_debug = 1) THEN
                        inv_log_util.trace('validate_reason_code pass', 'INV_TXN_MANAGER_GRP', 9);
        END IF;

    ELSE
        IF (l_debug = 1) THEN
                        inv_log_util.trace('Validate_Additional_Attr: NO NEED FOR VALIDATION.. just default ',
                         'INV_TXN_MANAGER_GRP', 9);
        END IF;

        -- dbms_output.put_line('Validate_Additional_Attr: LOT EXISTS, NO NEED FOR VALIDATION.. just default from MLN : '||
                --                       l_lot_record.lot_number);

                p_parent_lot_number                     :=    l_lot_record.parent_lot_number;
                p_expiration_date                       :=    l_lot_record.expiration_date;
                p_grade_code                                    :=    l_lot_record.grade_code;
        p_retest_date                                   :=        l_lot_record.retest_date;
                p_maturity_date                                 :=    l_lot_record.maturity_date;
        p_origination_date                              :=    l_lot_record.origination_date;
        p_origination_type                              :=    l_lot_record.origination_type;
        p_expiration_action_code                :=    l_lot_record.expiration_action_code;
        p_expiration_action_date                :=    l_lot_record.expiration_action_date;
        p_hold_date                                     :=    l_lot_record.hold_date;
/*
          dbms_output.put_line('***************************************' );
      dbms_output.put_line('p_parent_lot_number ' || p_parent_lot_number  );
      dbms_output.put_line('grade code ' || p_grade_code  );
      dbms_output.put_line('retest date ' || p_retest_date   );
          dbms_output.put_line('maturity date ' || p_maturity_date  );
      dbms_output.put_line('origination date ' || p_origination_date   )  ;
      dbms_output.put_line('origination type ' || p_origination_type   );
      dbms_output.put_line('expiration action Code ' || p_expiration_action_code   );
      dbms_output.put_line('expiration action date ' || p_expiration_action_date   );
      dbms_output.put_line('Hold date ' || p_hold_date   );
      dbms_output.put_line('expiration date ' || p_expiration_date   );
          dbms_output.put_line('***************************************' );
*/

    END IF;
     /*Bug#7425435 for the newlots created from the pending lots window of the
      batch details form, the attribured should be updated to the lots table */
    IF (l_new_child_lot) and l_existing_pending_lot = 1 THEN
         l_in_lot_rec := l_lot_record;
         INV_LOT_API_PUB.Update_Inv_lot(
                    x_return_status     =>     l_return_status
                  , x_msg_count         =>     l_msg_count
                  , x_msg_data          =>     l_msg_data
                  , x_lot_rec           =>     x_lot_rec
                  , p_lot_rec           =>     l_in_lot_rec
                  , p_source            =>     l_source
                  , p_api_version       =>     l_api_version
                  , p_init_msg_list     =>     l_init_msg_list
                  , p_commit            =>     l_commit
                   );
          IF l_return_status <> 'S' THEN
            l_error_code := l_msg_data;
            l_error_exp := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

    END IF;

 return true;
 /******************* END Perform Date validation logic ********************/
  EXCEPTION
         WHEN FND_API.G_EXC_ERROR  THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;
      UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
      SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = l_userid,
               LAST_UPDATE_LOGIN = l_loginid,
               PROGRAM_APPLICATION_ID = l_applid,
               PROGRAM_ID = l_progid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               REQUEST_ID = l_reqstid,
               ERROR_CODE = substrb(l_error_code,1,240)
      WHERE TRANSACTION_INTERFACE_ID = p_intid;

      errupdate(p_rowid,null);

     RETURN FALSE;

     WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
                inv_log_util.trace('Validate_Additional_Attr: error NO_DATA_FOUND' , 'INV_TXN_MANAGER_GRP', 9);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                    p_count => x_msg_count,
                                                                p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;

      l_error_code := x_msg_data;
      l_error_exp := x_msg_data;
      UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
      SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = l_userid,
               LAST_UPDATE_LOGIN = l_loginid,
               PROGRAM_APPLICATION_ID = l_applid,
               PROGRAM_ID = l_progid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               REQUEST_ID = l_reqstid,
               ERROR_CODE = substrb(l_error_code,1,240)
      WHERE TRANSACTION_INTERFACE_ID = p_intid;

      errupdate(p_rowid,null);
      RETURN FALSE;


     WHEN OTHERS THEN
      IF (l_debug = 1) THEN
                inv_log_util.trace('Validate_Additional_Attr: error OTHERS exception' , 'INV_TXN_MANAGER_GRP', 9);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                    p_count => x_msg_count,
                                                                p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;

      l_error_code := x_msg_data;
      l_error_exp := x_msg_data;

      UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
      SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = l_userid,
               LAST_UPDATE_LOGIN = l_loginid,
               PROGRAM_APPLICATION_ID = l_applid,
               PROGRAM_ID = l_progid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               REQUEST_ID = l_reqstid,
               ERROR_CODE = substrb(l_error_code,1,240)
      WHERE TRANSACTION_INTERFACE_ID = p_intid;

      errupdate(p_rowid,null);

     RETURN FALSE;


  END Validate_Additional_Attr;


PROCEDURE validate_derive_object_details
( p_org_id              IN  NUMBER
, p_object_type         IN  NUMBER
, p_object_id           IN  NUMBER
, p_object_number       IN  VARCHAR2
, p_item_id             IN  NUMBER
, p_object_type2        IN  NUMBER
, p_object_id2          IN  NUMBER
, p_object_number2      IN  VARCHAR2
, p_serctrl             IN  NUMBER
, p_lotctrl             IN  NUMBER
, p_rowid               IN  ROWID
, p_table               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2)
IS
    l_api_name        CONSTANT VARCHAR2(30)    := 'validate_derive_object_details';
    l_object_id         NUMBER;
    l_object_id2        NUMBER;
    l_object_number     VARCHAR2(240);
    l_object_number2    VARCHAR2(240);
    l_inventory_item_id NUMBER;

BEGIN
    x_return_status  := lg_ret_sts_success;
    -- Standard Start of API savepoint
    SAVEPOINT   sp_validations;

    g_pkg_name := l_api_name;
    IF (l_debug = 1) THEN
       mydebug('Entered  validate_derive_object_details ...');
       mydebug ('p_org_id        : ' || p_org_id );
       mydebug ('p_object_type   : ' || p_object_type );
       mydebug ('p_object_id     : ' || p_object_id );
       mydebug ('p_object_number : ' || p_object_number);
       mydebug ('p_item_id       : ' || p_item_id );
       mydebug ('p_object_type2  : ' || p_object_type2 );
       mydebug ('p_object_id2    : ' || p_object_id2 );
       mydebug ('p_object_number2: ' || p_object_number2);
       mydebug ('p_serctrl       : ' || p_serctrl );
       mydebug ('p_lotctrl       : ' || p_lotctrl );
       mydebug ('p_rowid         : ' || p_rowid );
       mydebug ('p_table         : ' || p_table );
    END IF;
   l_object_id := p_object_id;
   l_object_id2 := p_object_id2;
   l_object_number := p_object_number;
   l_object_number2 := p_object_number2;

   IF p_object_id is NOT NULL and p_object_type is NOT NULL
   THEN
      IF (l_debug = 1) THEN mydebug('{{- Use p_object_id and  p_object_type to - }}' ); END IF;
      IF p_object_type = 1 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select lot_number from MLN}}' ); END IF;
         select lot_number
         INTO   l_object_number
         FROM   mtl_lot_numbers
         WHERE  gen_object_id = p_object_id;
      ELSIF p_object_type = 2 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select serial_number from MSN }}' ); END IF;
         SELECT serial_number
         INTO   l_object_number
         FROM   mtl_serial_numbers
         WHERE  gen_object_id = p_object_id;
      END IF;
      IF (l_debug = 1) THEN mydebug('l_object_number : ' || l_object_number ); END IF;

   ELSIF p_object_type is NOT NULL AND p_object_number IS NOT NULL AND p_item_id IS NOT NULL
   THEN
      IF (l_debug = 1) THEN mydebug('{{- Use p_object_number,p_item_id, p_org_id to - }}' ); END IF;
      IF p_object_type = 1 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select gen_object_id from MLN }}' ); END IF;
         select gen_object_id
         INTO   l_object_id
         FROM   mtl_lot_numbers
         WHERE  organization_id = p_org_id
         AND    inventory_item_id = p_item_id
         AND    lot_number = p_object_number;
      ELSIF p_object_type = 2 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select gen_object_id from MSN}}' ); END IF;
         SELECT gen_object_id
         INTO   l_object_id
         FROM   mtl_serial_numbers
         WHERE  current_organization_id = p_org_id
         AND    inventory_item_id = p_item_id
         AND    serial_number = p_object_number;
      END IF;
      IF (l_debug = 1) THEN mydebug('l_object_id2 : ' || l_object_id2 ); END IF;
   END IF;
   IF p_object_id2 is NOT NULL and p_object_type2 is NOT NULL
   THEN
      IF (l_debug = 1) THEN mydebug('{{- Use p_object_id2 and  p_object_type2 to - }}' ); END IF;
      IF p_object_type2 = 1 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select lot_number from MLN}}' ); END IF;
         select lot_number
         INTO   l_object_number2
         FROM   mtl_lot_numbers
         WHERE  gen_object_id = p_object_id2;
      ELSIF p_object_type2 = 2 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select serial_number from MSN }}' ); END IF;
         SELECT serial_number
         INTO   l_object_number2
         FROM   mtl_serial_numbers
         WHERE  gen_object_id = p_object_id2;
      END IF;
      IF (l_debug = 1) THEN mydebug('l_object_number2 : ' || l_object_number2 ); END IF;
   ELSIF p_object_type2 is NOT NULL AND p_object_number2 IS NOT NULL AND p_item_id IS NOT NULL
   THEN
      IF (l_debug = 1) THEN mydebug('{{- Use p_object_number2,p_item_id, p_org_id to - }}' ); END IF;
      IF p_object_type2 = 1 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select gen_object_id from MLN }}' ); END IF;
         select gen_object_id
         INTO   l_object_id2
         FROM   mtl_lot_numbers
         WHERE  organization_id = p_org_id
         AND    inventory_item_id = p_item_id
         AND    lot_number = p_object_number2;
      ELSIF p_object_type = 2 THEN
         IF (l_debug = 1) THEN mydebug('{{  Select gen_object_id from MSN}}' ); END IF;
         SELECT gen_object_id
         INTO   l_object_id2
         FROM   mtl_serial_numbers
         WHERE  current_organization_id = p_org_id
         AND    inventory_item_id = p_item_id
         AND    serial_number = p_object_number2;
      END IF;
      IF (l_debug = 1) THEN mydebug('l_object_id2 : ' || l_object_id2 ); END IF;
   END IF;

   IF l_object_id IS NOT NULL OR l_object_number IS NOT NULL OR
      l_object_number2 IS NOT NULL OR l_object_id2 IS NOT NULL
   THEN
      IF p_table = 'MTLI' THEN
         UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
         SET    parent_object_id = l_object_id
                ,parent_object_id2 = l_object_id2
                ,parent_object_number = l_object_number
                ,parent_object_number2 = l_object_number2
         WHERE ROWID = p_rowid;
      ELSIF p_table = 'MSNI' THEN
         UPDATE MTL_SERIAL_NUMBERS_INTERFACE MSNI
         SET    parent_object_id = l_object_id
                ,parent_object_id2 = l_object_id2
                ,parent_object_number = l_object_number
                ,parent_object_number2 = l_object_number2
         WHERE ROWID = p_rowid;
      END IF;
   END IF;

EXCEPTION
WHEN OTHERS THEN
IF (l_debug = 1) THEN mydebug('exception WHEN OTHERS'|| x_msg_data || ':' || sqlerrm); END IF;
      x_return_status  := lg_ret_sts_unexp_error;
      ROLLBACK TO sp_validations;

END validate_derive_object_details;


PROCEDURE validate_serial_genealogy_data
( p_interface_id        IN    NUMBER
, p_org_id              IN    NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2)
IS
  CURSOR cur_MSNI IS
  SELECT FM_SERIAL_NUMBER
         ,TO_SERIAL_NUMBER
         ,PARENT_SERIAL_NUMBER
         ,PARENT_OBJECT_TYPE
         ,PARENT_OBJECT_ID
         ,PARENT_OBJECT_NUMBER
         ,PARENT_OBJECT_TYPE2
         ,PARENT_OBJECT_ID2
         ,PARENT_OBJECT_NUMBER2
         ,PARENT_ITEM_ID
         ,ROWID
  FROM  MTL_SERIAL_NUMBERS_INTERFACE
  WHERE TRANSACTION_INTERFACE_ID = p_interface_id;

BEGIN
    x_return_status  := lg_ret_sts_success;
    -- Standard Start of API savepoint
    SAVEPOINT   sp_gen_validations;

    g_pkg_name := 'validate_serial_genealogy_data';
    IF (l_debug = 1) THEN
        mydebug ('p_interface_id : ' ||  p_interface_id);
        mydebug ('p_org_id  : '  || p_org_id );
    END IF;


   FOR rec_MSNI in cur_MSNI
   LOOP

   IF (l_debug = 1) THEN
        mydebug ('FM_SERIAL_NUMBER : ' ||  rec_MSNI.FM_SERIAL_NUMBER);
        mydebug ('TO_SERIAL_NUMBER  : '  || rec_MSNI.TO_SERIAL_NUMBER );
        mydebug('PARENT_OBJECT_TYPE   :' || rec_MSNI.PARENT_OBJECT_TYPE   );
        mydebug('PARENT_OBJECT_ID     :' || rec_MSNI.PARENT_OBJECT_ID     );
        mydebug('PARENT_OBJECT_NUMBER :' || rec_MSNI.PARENT_OBJECT_NUMBER );
        mydebug('PARENT_OBJECT_TYPE2  :' || rec_MSNI.PARENT_OBJECT_TYPE2  );
        mydebug('PARENT_OBJECT_ID2    :' || rec_MSNI.PARENT_OBJECT_ID2    );
        mydebug('PARENT_OBJECT_NUMBER2:' || rec_MSNI.PARENT_OBJECT_NUMBER2);
        mydebug('PARENT_ITEM_ID:' || rec_MSNI.PARENT_ITEM_ID);
        mydebug('PARENT_SERIAL_NUMBER:' || rec_MSNI.PARENT_SERIAL_NUMBER);
        mydebug('ROWID:' || rec_MSNI.ROWID);
    END IF;


   IF (rec_MSNI.parent_object_id is NOT NULL AND rec_MSNI.parent_object_type is NOT NULL) OR
      (rec_MSNI.parent_object_type is NOT NULL AND rec_MSNI.parent_object_number is NOT NULL
                                               AND rec_MSNI.parent_Item_id IS NOT NULL)  THEN
      IF (l_debug = 1) THEN
         mydebug('{{- Parent details are available - Validation/derivation of  }} ' ||
                 '{{  parent object details is called here}}' );
      END IF;
      validate_derive_object_details
            ( p_org_id              => p_org_id
            , p_object_type         => rec_MSNI.parent_object_type
            , p_object_id           => rec_MSNI.parent_object_id
            , p_object_number       => rec_MSNI.parent_object_number
            , p_item_id             => rec_MSNI.parent_Item_id
            , p_object_type2        => rec_MSNI.parent_object_type2
            , p_object_id2          => rec_MSNI.parent_object_id2
            , p_object_number2      => rec_MSNI.parent_object_number2
            , p_serctrl             => NULL
            , p_lotctrl             => NULL
            , p_rowid               => rec_MSNI.rowid
            , p_table               => 'MSNI'
            , x_return_status       => x_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data);
      IF x_return_status <> lg_ret_sts_success THEN
         IF (l_debug=1) THEN mydebug(' x_return_status: ' || x_return_status); END IF;
         --RAISE lg_exc_error; ????
      END IF;
   ELSE
      IF (l_debug = 1) THEN
         mydebug('{{- Parent details are NOT available, so no validations }}' );
      END IF;
   END IF;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
IF (l_debug = 1) THEN mydebug('exception WHEN OTHERS'|| x_msg_data || ':' || sqlerrm); END IF;
x_return_status  := lg_ret_sts_unexp_error;
ROLLBACK TO sp_gen_validations;


NULL;

END validate_serial_genealogy_data;

--
--     Name: GET_SERIAL_DIFF_WRP
--
--     Input parameters:
--       p_fm_serial          'from' Serial Number
--       p_to_serial          'to'   Serial Number
--
--      Output parameters:
--       return_status       quantity between passed serial numbers,
--                           0 if pased serial numbers are invalid.
--
FUNCTION get_serial_diff_wrp(p_fm_serial IN VARCHAR2, p_to_serial IN VARCHAR2)
RETURN NUMBER AS
   l_qty NUMBER := 0;
BEGIN
   l_qty := inv_serial_number_pub.get_serial_diff(p_fm_serial, p_to_serial);
   IF (l_qty <= 0) THEN
      return 0;
   ELSE
      return l_qty;
   END IF;

END get_serial_diff_wrp;

END INV_TXN_MANAGER_GRP;

/
