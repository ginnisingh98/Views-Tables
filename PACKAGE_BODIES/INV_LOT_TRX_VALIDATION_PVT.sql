--------------------------------------------------------
--  DDL for Package Body INV_LOT_TRX_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_TRX_VALIDATION_PVT" AS
/* $Header: INVVLTVB.pls 120.10 2006/07/26 11:39:03 pmadadi noship $ */

  /*Bug:5354721. The following table holds the name, value type and length of all the
    lot Attributes of MTL_LOT_NUMBERS table which will then be used in
    get_lot_att_record procedure to populate the values for the corresponding columns.
  */

  g_lot_attr_tbl inv_lot_sel_attr.lot_sel_attributes_tbl_type;

  /*Bug 5354721. Building the following statement to get lot attributes from MTLI or MLN. */
  g_select_stmt LONG :=
  'SELECT
   NVL(MTLI.ATTRIBUTE_CATEGORY     , MLN.ATTRIBUTE_CATEGORY     ),
   NVL(MTLI.ATTRIBUTE1             , MLN.ATTRIBUTE1             ),
   NVL(MTLI.ATTRIBUTE2             , MLN.ATTRIBUTE2             ),
   NVL(MTLI.ATTRIBUTE3             , MLN.ATTRIBUTE3             ),
   NVL(MTLI.ATTRIBUTE4             , MLN.ATTRIBUTE4             ),
   NVL(MTLI.ATTRIBUTE5             , MLN.ATTRIBUTE5             ),
   NVL(MTLI.ATTRIBUTE6             , MLN.ATTRIBUTE6             ),
   NVL(MTLI.ATTRIBUTE7             , MLN.ATTRIBUTE7             ),
   NVL(MTLI.ATTRIBUTE8             , MLN.ATTRIBUTE8             ),
   NVL(MTLI.ATTRIBUTE9             , MLN.ATTRIBUTE9             ),
   NVL(MTLI.ATTRIBUTE10            , MLN.ATTRIBUTE10            ),
   NVL(MTLI.ATTRIBUTE11            , MLN.ATTRIBUTE11            ),
   NVL(MTLI.ATTRIBUTE12            , MLN.ATTRIBUTE12            ),
   NVL(MTLI.ATTRIBUTE13            , MLN.ATTRIBUTE13            ),
   NVL(MTLI.ATTRIBUTE14            , MLN.ATTRIBUTE14            ),
   NVL(MTLI.ATTRIBUTE15            , MLN.ATTRIBUTE15            ),
   NVL(MTLI.DESCRIPTION            , MLN.DESCRIPTION            ),
   NVL(MTLI.VENDOR_NAME            , MLN.VENDOR_NAME            ),
   NVL(MTLI.DATE_CODE              , MLN.DATE_CODE              ),
   NVL(MTLI.CHANGE_DATE            , MLN.CHANGE_DATE            ),
   NVL(MTLI.AGE                    , MLN.AGE                    ),
   NVL(MTLI.LOT_ATTRIBUTE_CATEGORY , MLN.LOT_ATTRIBUTE_CATEGORY ),
   NVL(MTLI.ITEM_SIZE              , MLN.ITEM_SIZE              ),
   NVL(MTLI.COLOR                  , MLN.COLOR                  ),
   NVL(MTLI.VOLUME                 , MLN.VOLUME                 ),
   NVL(MTLI.VOLUME_UOM             , MLN.VOLUME_UOM             ),
   NVL(MTLI.PLACE_OF_ORIGIN        , MLN.PLACE_OF_ORIGIN        ),
   NVL(MTLI.BEST_BY_DATE           , MLN.BEST_BY_DATE           ),
   NVL(MTLI.LENGTH                 , MLN.LENGTH                 ),
   NVL(MTLI.LENGTH_UOM             , MLN.LENGTH_UOM             ),
   NVL(MTLI.RECYCLED_CONTENT       , MLN.RECYCLED_CONTENT       ),
   NVL(MTLI.THICKNESS              , MLN.THICKNESS              ),
   NVL(MTLI.THICKNESS_UOM          , MLN.THICKNESS_UOM          ),
   NVL(MTLI.WIDTH                  , MLN.WIDTH                  ),
   NVL(MTLI.WIDTH_UOM              , MLN.WIDTH_UOM              ),
   NVL(MTLI.CURL_WRINKLE_FOLD      , MLN.CURL_WRINKLE_FOLD      ),
   NVL(MTLI.C_ATTRIBUTE1           , MLN.C_ATTRIBUTE1           ),
   NVL(MTLI.C_ATTRIBUTE2           , MLN.C_ATTRIBUTE2           ),
   NVL(MTLI.C_ATTRIBUTE3           , MLN.C_ATTRIBUTE3           ),
   NVL(MTLI.C_ATTRIBUTE4           , MLN.C_ATTRIBUTE4           ),
   NVL(MTLI.C_ATTRIBUTE5           , MLN.C_ATTRIBUTE5           ),
   NVL(MTLI.C_ATTRIBUTE6           , MLN.C_ATTRIBUTE6           ),
   NVL(MTLI.C_ATTRIBUTE7           , MLN.C_ATTRIBUTE7           ),
   NVL(MTLI.C_ATTRIBUTE8           , MLN.C_ATTRIBUTE8           ),
   NVL(MTLI.C_ATTRIBUTE9           , MLN.C_ATTRIBUTE9           ),
   NVL(MTLI.C_ATTRIBUTE10          , MLN.C_ATTRIBUTE10          ),
   NVL(MTLI.C_ATTRIBUTE11          , MLN.C_ATTRIBUTE11          ),
   NVL(MTLI.C_ATTRIBUTE12          , MLN.C_ATTRIBUTE12          ),
   NVL(MTLI.C_ATTRIBUTE13          , MLN.C_ATTRIBUTE13          ),
   NVL(MTLI.C_ATTRIBUTE14          , MLN.C_ATTRIBUTE14          ),
   NVL(MTLI.C_ATTRIBUTE15          , MLN.C_ATTRIBUTE15          ),
   NVL(MTLI.C_ATTRIBUTE16          , MLN.C_ATTRIBUTE16          ),
   NVL(MTLI.C_ATTRIBUTE17          , MLN.C_ATTRIBUTE17          ),
   NVL(MTLI.C_ATTRIBUTE18          , MLN.C_ATTRIBUTE18          ),
   NVL(MTLI.C_ATTRIBUTE19          , MLN.C_ATTRIBUTE19          ),
   NVL(MTLI.C_ATTRIBUTE20          , MLN.C_ATTRIBUTE20          ),
   NVL(MTLI.D_ATTRIBUTE1           , MLN.D_ATTRIBUTE1           ),
   NVL(MTLI.D_ATTRIBUTE2           , MLN.D_ATTRIBUTE2           ),
   NVL(MTLI.D_ATTRIBUTE3           , MLN.D_ATTRIBUTE3           ),
   NVL(MTLI.D_ATTRIBUTE4           , MLN.D_ATTRIBUTE4           ),
   NVL(MTLI.D_ATTRIBUTE5           , MLN.D_ATTRIBUTE5           ),
   NVL(MTLI.D_ATTRIBUTE6           , MLN.D_ATTRIBUTE6           ),
   NVL(MTLI.D_ATTRIBUTE7           , MLN.D_ATTRIBUTE7           ),
   NVL(MTLI.D_ATTRIBUTE8           , MLN.D_ATTRIBUTE8           ),
   NVL(MTLI.D_ATTRIBUTE9           , MLN.D_ATTRIBUTE9           ),
   NVL(MTLI.D_ATTRIBUTE10          , MLN.D_ATTRIBUTE10          ),
   NVL(MTLI.N_ATTRIBUTE1           , MLN.N_ATTRIBUTE1           ),
   NVL(MTLI.N_ATTRIBUTE2           , MLN.N_ATTRIBUTE2           ),
   NVL(MTLI.N_ATTRIBUTE3           , MLN.N_ATTRIBUTE3           ),
   NVL(MTLI.N_ATTRIBUTE4           , MLN.N_ATTRIBUTE4           ),
   NVL(MTLI.N_ATTRIBUTE5           , MLN.N_ATTRIBUTE5           ),
   NVL(MTLI.N_ATTRIBUTE6           , MLN.N_ATTRIBUTE6           ),
   NVL(MTLI.N_ATTRIBUTE7           , MLN.N_ATTRIBUTE7           ),
   NVL(MTLI.N_ATTRIBUTE8           , MLN.N_ATTRIBUTE8           ),
   NVL(MTLI.N_ATTRIBUTE9           , MLN.N_ATTRIBUTE9           ),
   NVL(MTLI.N_ATTRIBUTE10          , MLN.N_ATTRIBUTE10          ),
   NVL(MTLI.VENDOR_ID              , MLN.VENDOR_ID              ),
   NVL(MTLI.TERRITORY_CODE         , MLN.TERRITORY_CODE         )
   ';

  PROCEDURE print_debug (p_message IN VARCHAR2, p_module IN VARCHAR2)
  IS
    l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    --dbms_output.put_line(g_pkg_name||'.'||p_module||': ' || p_message);
    IF (l_debug = 1)
    THEN
      --INSERT INTO abhi(log, pkg, module) VALUES(p_message, g_pkg_name, p_module);
      --COMMIT;
      inv_log_util.TRACE (p_message, g_pkg_name || '.' || p_module, 9);
    END IF;
  END print_debug;


  /***************************************************************************
    Fetch the records from Interface tables and populate
    the tables which are later used for validations purpose.

    Added following for serial controlled items:-

    If the item is serial controlled Then
     If lot split and merge Then
      get the values for the st_ser_num_tbl etc from MSNI
    Else If lot Translate Then
      get the Serial Numbers belonging to the lot item org combo and
      populate the tables.
    End If;

  *****************************************************************************/
  PROCEDURE populate_records (
    x_validation_status        OUT NOCOPY      VARCHAR2
  , x_return_status            OUT NOCOPY      VARCHAR2
  , x_st_interface_id_tbl      OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_item_id_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_org_id_tbl            OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_revision_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.revision_table
  , x_st_sub_code_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.sub_code_table
  , x_st_locator_id_tbl        OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_lot_num_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.lot_number_table
  ,
    --Support for Lot Serial
    x_st_ser_num_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.serial_number_table
  , x_st_ser_parent_lot_tbl    OUT NOCOPY      inv_lot_trx_validation_pub.parent_lot_table
  , x_rs_ser_parent_lot_tbl    OUT NOCOPY      inv_lot_trx_validation_pub.parent_lot_table
  , x_rs_ser_num_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.serial_number_table
  , x_st_ser_status_tbl        OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_ser_status_tbl        OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_ser_grp_mark_id_tbl   OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_ser_grp_mark_id_tbl   OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_ser_parent_sub_tbl    OUT NOCOPY      inv_lot_trx_validation_pub.parent_sub_table
  , x_st_ser_parent_loc_tbl    OUT NOCOPY      inv_lot_trx_validation_pub.parent_loc_table
  ,
    --Support for Lot Serial
    x_st_lpn_id_tbl            OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_quantity_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_cost_group_tbl        OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_uom_tbl               OUT NOCOPY      inv_lot_trx_validation_pub.uom_table
  , x_st_status_id_tbl         OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_interface_id_tbl      OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_item_id_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_org_id_tbl            OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_revision_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.revision_table
  , x_rs_sub_code_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.sub_code_table
  , x_rs_locator_id_tbl        OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_lot_num_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.lot_number_table
  , x_rs_lpn_id_tbl            OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_quantity_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_cost_group_tbl        OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_rs_uom_tbl               OUT NOCOPY      inv_lot_trx_validation_pub.uom_table
  , x_rs_status_id_tbl         OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_lot_exp_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.date_table
  , x_rs_lot_exp_tbl           OUT NOCOPY      inv_lot_trx_validation_pub.date_table
  , x_transaction_type_id      OUT NOCOPY      NUMBER
  , x_acct_period_tbl          OUT NOCOPY      inv_lot_trx_validation_pub.number_table
  , x_st_dist_account_id       OUT NOCOPY      NUMBER
  , x_rs_dist_account_id       OUT NOCOPY      NUMBER
  , p_parent_id                IN              NUMBER
  )
  IS
    CURSOR mti_csr (p_parent_id NUMBER)
    IS
      SELECT transaction_interface_id
           , inventory_item_id
           , revision
           , organization_id
           , transaction_quantity
           , primary_quantity
           , transaction_uom
           , subinventory_code
           , locator_id
           , transaction_type_id
           , transaction_action_id
           , acct_period_id
           , distribution_account_id
           , transfer_subinventory
           , transfer_organization
           , transfer_locator
           , parent_id
           , cost_group_id
           , transfer_cost_group_id
           , lpn_id
           , transfer_lpn_id
        FROM mtl_transactions_interface
       WHERE parent_id = p_parent_id;

    CURSOR mtli_csr (p_transaction_interface_id NUMBER)
    IS
      SELECT transaction_interface_id
           , lot_number
           , lot_expiration_date
           , transaction_quantity
           , primary_quantity
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
           , n_attribute10
           , supplier_lot_number
           , n_attribute9
           , territory_code
           , serial_transaction_temp_id
        FROM mtl_transaction_lots_interface
       WHERE transaction_interface_id = p_transaction_interface_id;

    /*Support for Lot Serial:
     *this cursor is to be used in case of the lot split and merge transactions and not for lot
     *translate transaction
     */
    CURSOR msni_csr (p_serial_transaction_temp_id IN NUMBER)
    IS
      SELECT fm_serial_number
           , NVL (to_serial_number, fm_serial_number) to_serial_number
        FROM mtl_serial_numbers_interface
       WHERE transaction_interface_id = p_serial_transaction_temp_id;

    l_ser_csr                      msni_csr%ROWTYPE;


    CURSOR per_serial_msn_csr (
      p_serial_number       IN   VARCHAR2
    , p_organization_id     IN   NUMBER
    , p_inventory_item_id   IN   NUMBER
    )
    IS
      SELECT group_mark_id
           , status_id
        FROM mtl_serial_numbers
       WHERE serial_number = p_serial_number
         AND current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;


    CURSOR per_serial_msn_src_csr (
      p_serial_number       IN   VARCHAR2
    , p_organization_id     IN   NUMBER
    , p_inventory_item_id   IN   NUMBER
    , p_lot_number 	    IN   VARCHAR2
    , p_subinventory_code   IN   VARCHAR2
    , p_locator_id          IN   NUMBER
    , p_lpn_id		    IN   NUMBER
    , p_revision	    IN   VARCHAR2
    )
    IS
      SELECT group_mark_id
           , status_id
        FROM mtl_serial_numbers
       WHERE serial_number = p_serial_number
         AND current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
	 AND lot_number = p_lot_number
         AND current_subinventory_code = p_subinventory_code
         AND nvl(current_locator_id, -9999) = nvl(p_locator_id, -9999)
         AND nvl(lpn_id, -9999) = nvl(p_lpn_id, -9999)
	 AND nvl(revision, '@#') = nvl(p_revision, '@#')
	 AND current_status in (1,3,6)
	 AND reservation_id IS NULL;


    /*Support for Lot Serial:
     *This cursor is to be used for lot translate transaction. Here we have to get all the serial for
     *that item ,lot, sub and locator combination from the mtl_serial_nunbers table.
     */
    CURSOR msn_csr (
      p_lot_number          IN   VARCHAR2
    , p_inventory_item_id   IN   NUMBER
    , p_subinventory_code   IN   VARCHAR2
    , p_locator_id          IN   NUMBER
    , p_organization_id     IN   NUMBER
    , p_lpn_id		    IN   NUMBER
    , p_revision	    IN   VARCHAR2
    )
    IS
      SELECT serial_number
           , status_id
           , group_mark_id
        FROM mtl_serial_numbers
       WHERE lot_number = p_lot_number
         AND current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         AND current_subinventory_code = p_subinventory_code
         AND nvl(current_locator_id, -9999) = nvl(p_locator_id, -9999)
	 AND nvl(lpn_id, -9999)		    = nvl(p_lpn_id , -9999)
	 AND nvl(revision, '@#')	    = nvl(p_revision, '@#')
         AND current_status IN (1,3,6)
	 AND reservation_id IS NULL;

    l_ser_msn_csr                  msn_csr%ROWTYPE;
    l_transaction_type_id          NUMBER;
    l_transaction_interface_id     NUMBER;
    l_transaction_action_id        NUMBER;
    l_st_item_id_tbl               inv_lot_trx_validation_pub.number_table;
    l_st_org_id_tbl                inv_lot_trx_validation_pub.number_table;
    l_st_revision_tbl              inv_lot_trx_validation_pub.revision_table;
    l_st_quantity_tbl              inv_lot_trx_validation_pub.number_table;
    l_st_primary_quantity_tbl      inv_lot_trx_validation_pub.number_table;
    l_st_uom_tbl                   inv_lot_trx_validation_pub.uom_table;
    l_st_locator_id_tbl            inv_lot_trx_validation_pub.number_table;
    l_st_sub_code_tbl              inv_lot_trx_validation_pub.sub_code_table;
    l_st_cost_group_id_tbl         inv_lot_trx_validation_pub.number_table;
    l_st_lpn_id_tbl                inv_lot_trx_validation_pub.number_table;
    l_rs_item_id_tbl               inv_lot_trx_validation_pub.number_table;
    l_rs_org_id_tbl                inv_lot_trx_validation_pub.number_table;
    l_rs_revision_tbl              inv_lot_trx_validation_pub.revision_table;
    l_rs_quantity_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_primary_quantity_tbl      inv_lot_trx_validation_pub.number_table;
    l_rs_uom_tbl                   inv_lot_trx_validation_pub.uom_table;
    l_rs_locator_id_tbl            inv_lot_trx_validation_pub.number_table;
    l_rs_sub_code_tbl              inv_lot_trx_validation_pub.sub_code_table;
    l_rs_lpn_id_tbl                inv_lot_trx_validation_pub.number_table;
    l_rs_cost_group_id_tbl         inv_lot_trx_validation_pub.number_table;
    l_st_lot_number_tbl            inv_lot_trx_validation_pub.lot_number_table;
    l_rs_lot_number_tbl            inv_lot_trx_validation_pub.lot_number_table;
    l_st_ser_number_tbl            inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_parent_lot_tbl        inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_parent_lot_tbl        inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_number_tbl            inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_status_tbl            inv_lot_trx_validation_pub.number_table;
    l_rs_ser_status_tbl            inv_lot_trx_validation_pub.number_table;
    l_st_ser_group_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_rs_ser_group_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_st_ser_parent_sub_tbl        inv_lot_trx_validation_pub.parent_sub_table;
    l_st_ser_parent_loc_tbl        inv_lot_trx_validation_pub.parent_loc_table;
    l_serial_transaction_temp_id   NUMBER;
    l_serial_diff                  NUMBER;
    l_status_id                    NUMBER;
    l_group_mark_id                NUMBER;
    l_st_status_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_rs_status_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_st_interface_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_interface_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_lot_exp_tbl               inv_lot_trx_validation_pub.date_table;
    l_st_lot_exp_tbl               inv_lot_trx_validation_pub.date_table;
    l_rs_index                     NUMBER;
    l_st_index                     NUMBER;
    l_st_ser_index                 NUMBER;
    l_rs_ser_index                 NUMBER;
    l_serial_code                  NUMBER;
    l_source_record                VARCHAR2 (1);
    l_next_serial                  VARCHAR2 (30);
    l_old_serial                   VARCHAR2 (30);
    l_count                        NUMBER;
    l_primary_quantity             NUMBER;
    l_primary_uom_code             VARCHAR2 (3);
    l_transaction_quantity         NUMBER;
    l_acct_period_tbl              inv_lot_trx_validation_pub.number_table;
    l_st_dist_account_id           NUMBER;
    l_rs_dist_account_id           NUMBER;
    l_validation_status            VARCHAR2 (1);
    l_start_primary_uom       VARCHAR2 (3);
    l_revision_control        VARCHAR2 (5);
    l_debug                        NUMBER
                             := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_validation_status := 'Y';

    IF (l_debug = 1)
    THEN
      print_debug ('Inside populate_records', 'Populate_REcords');
      print_debug ('l_marker  10', 'Populate_REcords');
      print_debug ('p_parent_id is ' || p_parent_id, 'Populate_Records');
    END IF;

    l_st_item_id_tbl  		:= inv_lot_trx_validation_pub.number_table ();
    l_st_org_id_tbl   		:= inv_lot_trx_validation_pub.number_table ();
    l_st_revision_tbl 		:= inv_lot_trx_validation_pub.revision_table ();
    l_st_quantity_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_st_primary_quantity_tbl   := inv_lot_trx_validation_pub.number_table ();
    l_st_uom_tbl 		:= inv_lot_trx_validation_pub.uom_table ();
    l_st_locator_id_tbl 	:= inv_lot_trx_validation_pub.number_table ();
    l_st_sub_code_tbl 		:= inv_lot_trx_validation_pub.sub_code_table ();
    l_st_cost_group_id_tbl 	:= inv_lot_trx_validation_pub.number_table ();
    l_st_lpn_id_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_rs_item_id_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_rs_org_id_tbl := inv_lot_trx_validation_pub.number_table ();
    l_rs_revision_tbl := inv_lot_trx_validation_pub.revision_table ();
    l_rs_quantity_tbl := inv_lot_trx_validation_pub.number_table ();
    l_rs_primary_quantity_tbl := inv_lot_trx_validation_pub.number_table ();
    l_rs_uom_tbl := inv_lot_trx_validation_pub.uom_table ();
    l_rs_locator_id_tbl := inv_lot_trx_validation_pub.number_table ();
    l_rs_sub_code_tbl := inv_lot_trx_validation_pub.sub_code_table ();
    l_rs_lpn_id_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_rs_cost_group_id_tbl      := inv_lot_trx_validation_pub.number_table ();
    l_st_lot_number_tbl 	:= inv_lot_trx_validation_pub.lot_number_table ();
    l_rs_lot_number_tbl 	:= inv_lot_trx_validation_pub.lot_number_table ();
    l_st_ser_status_tbl 	:= inv_lot_trx_validation_pub.number_table ();
    l_rs_ser_status_tbl 	:= inv_lot_trx_validation_pub.number_table ();
    l_st_ser_group_mark_id_tbl  := inv_lot_trx_validation_pub.number_table ();
    l_rs_ser_group_mark_id_tbl  := inv_lot_trx_validation_pub.number_table ();
    l_st_interface_id_tbl 	:= inv_lot_trx_validation_pub.number_table ();
    l_rs_interface_id_tbl 	:= inv_lot_trx_validation_pub.number_table ();
    l_st_status_id_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_rs_status_id_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_st_lot_exp_tbl 		:= inv_lot_trx_validation_pub.date_table ();
    l_rs_lot_exp_tbl 		:= inv_lot_trx_validation_pub.date_table ();
    l_acct_period_tbl 		:= inv_lot_trx_validation_pub.number_table ();
    l_count := 0;
    l_rs_index := 0;
    l_st_index := 0;
    l_st_ser_index := 0;
    l_rs_ser_index := 0;
    l_st_dist_account_id := NULL;
    l_rs_dist_account_id := NULL;
    print_debug ('l_marker  20', 'Populate_REcords');

    FOR l_mti_csr IN mti_csr (p_parent_id)
    LOOP
      l_count := l_count + 1;
      l_transaction_interface_id := l_mti_csr.transaction_interface_id;

      IF (l_debug = 1)
      THEN
        print_debug (   'l_transaction_interface_id is '
                     || l_transaction_interface_id
                   , 'populate_records'
                    );
        print_debug ('l_count is ' || l_count, 'populate_records');
        print_debug ('Account Period Id ' || l_mti_csr.acct_period_id
                   , 'populate_records'
                    );
      END IF;

      l_transaction_type_id := l_mti_csr.transaction_type_id;
      l_transaction_action_id := l_mti_csr.transaction_action_id;
      l_acct_period_tbl.EXTEND (1);
      l_acct_period_tbl (l_count) := l_mti_csr.acct_period_id;

      /*Derive the primary quantity */
      BEGIN
        SELECT primary_uom_code
          INTO l_start_primary_uom
          FROM mtl_system_items
         WHERE organization_id = l_mti_csr.organization_id
           AND inventory_item_id = l_mti_csr.inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          fnd_message.set_name ('INV', 'INV_INT_ITEM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
      IF (l_start_primary_uom <> l_mti_csr.transaction_uom)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug (   'The UOMs are different '
                          , 'populate_records'
                      );
        END IF;

        -- call inv_um.convert
        l_primary_quantity :=
          inv_convert.inv_um_convert (item_id           => l_mti_csr.inventory_item_id
                                    , PRECISION         => 5
                                    , from_quantity     => l_mti_csr.transaction_quantity
                                    , from_unit         => l_mti_csr.transaction_uom
                                    , to_unit           => l_start_primary_uom
                                    , from_name         => NULL
                                    , to_name           => NULL
                                     );

        IF (l_primary_quantity = -99999)
        THEN
          fnd_message.set_name ('INV', 'INV-CANNOT CONVERT');
          fnd_message.set_token ('UOM', l_mti_csr.transaction_uom);
          fnd_message.set_token ('ROUTINE'
                               , g_pkg_name || 'Validate_Quantity');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_primary_quantity := l_mti_csr.transaction_quantity;
      END IF;


      IF (l_debug = 1)
      THEN
        print_debug ('l_transaction_type_id is ' || l_transaction_type_id
                   , 'populate_records'
                    );
        print_debug ('l_transaction_action_id is ' || l_transaction_action_id
                   , 'populate_records'
                    );
        print_debug ('l_acct_period_id is ' || l_acct_period_tbl (l_count)
                   , 'populate_records'
                    );
      END IF;

      IF (   l_transaction_type_id = inv_globals.g_type_inv_lot_split
          OR l_transaction_type_id = inv_globals.g_type_inv_lot_translate
         )
      THEN
        IF (l_transaction_interface_id = p_parent_id)
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  30 l_count' || l_count
                       , 'Populate_REcords'
                        );
            print_debug
                     (   'TRansaction Interface ID : Lot Split/Lot Translate'
                      || l_transaction_interface_id
                    , 'Populate_REcords'
                     );
          END IF;

          l_primary_quantity := -1 * ABS (l_primary_quantity);
          l_transaction_quantity := -1 * ABS (l_mti_csr.transaction_quantity);
          l_st_index := l_st_index + 1;
          l_st_interface_id_tbl.EXTEND (1);
          l_st_interface_id_tbl (l_st_index) :=
                                            l_mti_csr.transaction_interface_id;
          l_st_item_id_tbl.EXTEND (1);
          l_st_item_id_tbl (l_st_index) := l_mti_csr.inventory_item_id;
          l_st_org_id_tbl.EXTEND (1);
          l_st_org_id_tbl (l_st_index) := l_mti_csr.organization_id;
          l_st_revision_tbl.EXTEND (1);
          l_st_revision_tbl (l_st_index) := l_mti_csr.revision;
          l_st_quantity_tbl.EXTEND (1);
          l_st_quantity_tbl (l_st_index) :=
                                          ABS (l_mti_csr.transaction_quantity);
          l_st_primary_quantity_tbl.EXTEND (1);
          l_st_primary_quantity_tbl (l_st_index) := ABS (l_primary_quantity);
          l_st_uom_tbl.EXTEND (1);
          l_st_uom_tbl (l_st_index) := l_mti_csr.transaction_uom;
          l_st_locator_id_tbl.EXTEND (1);
          l_st_locator_id_tbl (l_st_index) := l_mti_csr.locator_id;
          l_st_sub_code_tbl.EXTEND (1);
          l_st_sub_code_tbl (l_st_index) := l_mti_csr.subinventory_code;
          l_st_cost_group_id_tbl.EXTEND (1);
          l_st_cost_group_id_tbl (l_st_index) := l_mti_csr.cost_group_id;
          l_st_lpn_id_tbl.EXTEND (1);
          l_st_lpn_id_tbl (l_st_index) := l_mti_csr.lpn_id;
          l_st_dist_account_id := l_mti_csr.distribution_account_id;

          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  40 l_count' || l_count
                       , 'Populate_REcords'
                        );
            print_debug ('Primary qty' || l_primary_quantity
                       , 'Populate_REcords'
                        );
          END IF;
        ELSE
          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  50 l_count' || l_count
                       , 'Populate_REcords'
                        );
            print_debug
                (   'Else TRansaction Interface ID : Lot Split/Lot Translate'
                 || l_transaction_interface_id
               , 'Populate_REcords'
                );
          END IF;

          l_primary_quantity := 1 * ABS (l_primary_quantity);
          l_transaction_quantity := 1 * ABS (l_mti_csr.transaction_quantity);
          l_rs_index := l_rs_index + 1;
          l_rs_interface_id_tbl.EXTEND (1);
          l_rs_interface_id_tbl (l_rs_index) :=
                                            l_mti_csr.transaction_interface_id;
          l_rs_item_id_tbl.EXTEND (1);
          l_rs_item_id_tbl (l_rs_index) := l_mti_csr.inventory_item_id;
          l_rs_org_id_tbl.EXTEND (1);
          l_rs_org_id_tbl (l_rs_index) := l_mti_csr.organization_id;
          l_rs_revision_tbl.EXTEND (1);
          l_rs_revision_tbl (l_rs_index) := l_mti_csr.revision;
          l_rs_quantity_tbl.EXTEND (1);
          l_rs_quantity_tbl (l_rs_index) :=
                                          ABS (l_mti_csr.transaction_quantity);
          l_rs_primary_quantity_tbl.EXTEND (1);
          l_rs_primary_quantity_tbl (l_rs_index) := ABS (l_primary_quantity);
          l_rs_uom_tbl.EXTEND (1);
          l_rs_uom_tbl (l_rs_index) := l_mti_csr.transaction_uom;
          l_rs_locator_id_tbl.EXTEND (1);
          l_rs_locator_id_tbl (l_rs_index) := l_mti_csr.locator_id;
          l_rs_sub_code_tbl.EXTEND (1);
          l_rs_sub_code_tbl (l_rs_index) := l_mti_csr.subinventory_code;
          l_rs_cost_group_id_tbl.EXTEND (1);
          l_rs_cost_group_id_tbl (l_rs_index) := l_mti_csr.cost_group_id;
          l_rs_lpn_id_tbl.EXTEND (1);
          l_rs_lpn_id_tbl (l_rs_index) := l_mti_csr.transfer_lpn_id;
          l_rs_dist_account_id := l_mti_csr.distribution_account_id;

          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  60 l_count' || l_count
                       , 'Populate_REcords'
                        );
            print_debug ('Primary qty' || l_primary_quantity
                       , 'Populate_REcords'
                        );
          END IF;
        END IF;
      ELSIF (l_transaction_type_id = inv_globals.g_type_inv_lot_merge)
      THEN
        IF (l_transaction_interface_id = p_parent_id)
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  70 l_count' || l_count
                       , 'Populate_REcords'
                        );
            print_debug (   'TRansaction Interface ID : Lot Merge'
                         || l_transaction_interface_id
                       , 'Populate_REcords'
                        );
          END IF;

          l_primary_quantity := 1 * ABS (l_primary_quantity);
          l_transaction_quantity := 1 * ABS (l_mti_csr.transaction_quantity);
          l_rs_index := l_rs_index + 1;
          l_rs_interface_id_tbl.EXTEND (1);
          l_rs_interface_id_tbl (l_rs_index) :=
                                            l_mti_csr.transaction_interface_id;
          l_rs_item_id_tbl.EXTEND (1);
          l_rs_item_id_tbl (l_rs_index) := l_mti_csr.inventory_item_id;
          l_rs_org_id_tbl.EXTEND (1);
          l_rs_org_id_tbl (l_rs_index) := l_mti_csr.organization_id;
          l_rs_revision_tbl.EXTEND (1);
          l_rs_revision_tbl (l_rs_index) := l_mti_csr.revision;
          l_rs_quantity_tbl.EXTEND (1);
          l_rs_quantity_tbl (l_rs_index) :=
                                          ABS (l_mti_csr.transaction_quantity);
          l_rs_primary_quantity_tbl.EXTEND (1);
          l_rs_primary_quantity_tbl (l_rs_index) := ABS (l_primary_quantity);
          l_rs_uom_tbl.EXTEND (1);
          l_rs_uom_tbl (l_rs_index) := l_mti_csr.transaction_uom;
          l_rs_locator_id_tbl.EXTEND (1);
          l_rs_locator_id_tbl (l_rs_index) := l_mti_csr.locator_id;
          l_rs_sub_code_tbl.EXTEND (1);
          l_rs_sub_code_tbl (l_rs_index) := l_mti_csr.subinventory_code;
          l_rs_cost_group_id_tbl.EXTEND (1);
          l_rs_cost_group_id_tbl (l_rs_index) := l_mti_csr.cost_group_id;
          l_rs_lpn_id_tbl.EXTEND (1);
          l_rs_lpn_id_tbl (l_rs_index) := l_mti_csr.transfer_lpn_id;
        ELSE
          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  80 l_count' || l_count
                       , 'Populate_REcords'
                        );
            print_debug (   'Else TRansaction Interface ID : Lot Merge'
                         || l_transaction_interface_id
                       , 'Populate_REcords'
                        );
          END IF;

          l_primary_quantity := -1 * ABS (l_primary_quantity);
          l_transaction_quantity := -1 * ABS (l_mti_csr.transaction_quantity);
          l_st_index := l_st_index + 1;
          l_st_interface_id_tbl.EXTEND (1);
          l_st_interface_id_tbl (l_st_index) :=
                                            l_mti_csr.transaction_interface_id;
          l_st_item_id_tbl.EXTEND (1);
          l_st_item_id_tbl (l_st_index) := l_mti_csr.inventory_item_id;
          l_st_org_id_tbl.EXTEND (1);
          l_st_org_id_tbl (l_st_index) := l_mti_csr.organization_id;
          l_st_revision_tbl.EXTEND (1);
          l_st_revision_tbl (l_st_index) := l_mti_csr.revision;
          l_st_quantity_tbl.EXTEND (1);
          l_st_quantity_tbl (l_st_index) :=
                                          ABS (l_mti_csr.transaction_quantity);
          l_st_primary_quantity_tbl.EXTEND (1);
          l_st_primary_quantity_tbl (l_st_index) := ABS (l_primary_quantity);
          l_st_uom_tbl.EXTEND (1);
          l_st_uom_tbl (l_st_index) := l_mti_csr.transaction_uom;
          l_st_locator_id_tbl.EXTEND (1);
          l_st_locator_id_tbl (l_st_index) := l_mti_csr.locator_id;
          l_st_sub_code_tbl.EXTEND (1);
          l_st_sub_code_tbl (l_st_index) := l_mti_csr.subinventory_code;
          l_st_cost_group_id_tbl.EXTEND (1);
          l_st_cost_group_id_tbl (l_st_index) := l_mti_csr.cost_group_id;
          l_st_lpn_id_tbl.EXTEND (1);
          l_st_lpn_id_tbl (l_st_index) := l_mti_csr.lpn_id;
        END IF;
      END IF;

      IF (l_debug = 1)
      THEN
        print_debug ('l_marker  90 l_count' || l_count, 'Populate_REcords');
        print_debug ('l_marker  l_transaction_quantity' || l_transaction_quantity, 'Populate_REcords');
        print_debug ('l_marker  l_primary_quantity' || l_primary_quantity, 'Populate_REcords');
      END IF;



      UPDATE mtl_transactions_interface
         SET transaction_quantity = l_transaction_quantity
           , primary_quantity = l_primary_quantity
       WHERE transaction_interface_id = l_transaction_interface_id;

      UPDATE mtl_transaction_lots_interface
         SET transaction_quantity = ABS (l_transaction_quantity)
           , primary_quantity = ABS (l_primary_quantity)
       WHERE transaction_interface_id = l_transaction_interface_id;

      /*Support for Lot Serial */
      SELECT serial_number_control_code
        INTO l_serial_code
        FROM mtl_system_items
       WHERE inventory_item_id = l_mti_csr.inventory_item_id
         AND organization_id = l_mti_csr.organization_id;

      IF (l_debug = 1)
      THEN
        print_debug ('l_marker  100 l_count' || l_count, 'Populate_REcords');
        print_debug ('l_st_index is ' || l_st_index, 'Populate_records');
        print_debug ('l_rs_index is ' || l_rs_index, 'Populate_records');
      END IF;

      FOR l_lot_csr IN mtli_csr (l_transaction_interface_id)
      LOOP
        l_serial_transaction_temp_id := l_lot_csr.serial_transaction_temp_id;

        IF (l_transaction_interface_id = p_parent_id)
        THEN
          l_source_record := 'Y';
        ELSE
          l_source_record := 'N';
        END IF;

        IF (l_debug = 1)
        THEN
          print_debug ('l_marker  110 l_count' || l_count
                     , 'Populate_REcords');
        END IF;

        IF (   l_transaction_type_id = inv_globals.g_type_inv_lot_split
            OR l_transaction_type_id = inv_globals.g_type_inv_lot_translate
           )
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  120 l_count' || l_count
                       , 'Populate_REcords'
                        );
          END IF;

          IF (l_source_record = 'Y')
          THEN
            l_st_lot_number_tbl.EXTEND (1);
            l_st_lot_number_tbl (l_st_index) := l_lot_csr.lot_number;
            l_st_status_id_tbl.EXTEND (1);
            l_st_status_id_tbl (l_st_index) := l_lot_csr.status_id;
            l_st_lot_exp_tbl.EXTEND (1);
            l_st_lot_exp_tbl (l_st_index) := l_lot_csr.lot_expiration_date;
          ELSE
            l_rs_lot_number_tbl.EXTEND (1);
            l_rs_lot_number_tbl (l_rs_index) := l_lot_csr.lot_number;
            l_rs_status_id_tbl.EXTEND (1);
            l_rs_status_id_tbl (l_rs_index) := l_lot_csr.status_id;
            l_rs_lot_exp_tbl.EXTEND (1);
            l_rs_lot_exp_tbl (l_rs_index) := l_lot_csr.lot_expiration_date;
          END IF;
        ELSIF (l_transaction_type_id = inv_globals.g_type_inv_lot_merge)
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('l_marker  130 l_count' || l_count
                       , 'Populate_REcords'
                        );
          END IF;

          IF (l_source_record = 'Y')
          THEN
            l_rs_lot_number_tbl.EXTEND (1);
            l_rs_lot_number_tbl (l_rs_index) := l_lot_csr.lot_number;
            l_rs_status_id_tbl.EXTEND (1);
            l_rs_status_id_tbl (l_rs_index) := l_lot_csr.status_id;
            l_rs_lot_exp_tbl.EXTEND (1);
            l_rs_lot_exp_tbl (l_rs_index) := l_lot_csr.lot_expiration_date;
          ELSE
            l_st_lot_number_tbl.EXTEND (1);
            l_st_lot_number_tbl (l_st_index) := l_lot_csr.lot_number;
            l_st_status_id_tbl.EXTEND (1);
            l_st_status_id_tbl (l_st_index) := l_lot_csr.status_id;
            l_st_lot_exp_tbl.EXTEND (1);
            l_st_lot_exp_tbl (l_st_index) := l_lot_csr.lot_expiration_date;
          END IF;
        END IF;
        /*Support for Lot Serial
         *For each lot fetched from the MTLI cursor get all the serials for that lot and
         *populate the starting and resultant records.
         */
        BEGIN
          IF (l_serial_code IN (2, 5))
          THEN
            IF (   (    l_transaction_type_id =
                                              inv_globals.g_type_inv_lot_split
                    AND l_source_record = 'Y'
                   )
                OR (    l_transaction_type_id =
                                              inv_globals.g_type_inv_lot_merge
                    AND l_source_record = 'N'
                   )
               )
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('l_marker  140 l_count' || l_count
                           , 'Populate_REcords'
                            );
                   print_debug ('l_serial_transaction_temp_id ' || l_serial_transaction_temp_id
                           , 'Populate_REcords'
                            );
              END IF;



              FOR l_ser_csr  IN msni_csr(l_serial_transaction_temp_id) LOOP
                l_next_serial := l_ser_csr.fm_serial_number;
                l_serial_diff :=
                  inv_serial_number_pub.get_serial_diff
                                                  (l_ser_csr.fm_serial_number
                                                 , l_ser_csr.to_serial_number
                                                  );

                IF (l_serial_diff = -1)
                THEN
                  fnd_message.set_name ('INV', 'INV_INVALID_SERIAL_RANGE');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                FOR i IN 1 .. l_serial_diff
                LOOP
                  l_st_ser_index := l_st_ser_index + 1;
                  l_st_ser_number_tbl (l_next_serial) :=     l_next_serial;
                  l_st_ser_parent_lot_tbl (l_next_serial) := l_lot_csr.lot_number;
                  l_st_ser_parent_sub_tbl (l_next_serial) := l_mti_csr.subinventory_code;
                  l_st_ser_parent_loc_tbl (l_next_serial) := l_mti_csr.locator_id;

                  OPEN per_serial_msn_src_csr (
					   l_next_serial
                                         , l_mti_csr.organization_id
                                         , l_mti_csr.inventory_item_id
					 , l_lot_csr.lot_number
					 , l_mti_csr.subinventory_code
					 , l_mti_csr.locator_id
					 , l_mti_csr.lpn_id
					 , l_mti_csr.revision
                                          );

                  FETCH per_serial_msn_src_csr
                   INTO l_group_mark_id
                      , l_status_id;

		  IF(per_serial_msn_src_csr%NOTFOUND) THEN
		    IF(per_serial_msn_src_csr%ISOPEN) THEN
			CLOSE per_serial_msn_src_csr;
		    END IF;
		    fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
		    fnd_msg_pub.ADD;
		    RAISE NO_DATA_FOUND;
		  END IF;



                  l_st_ser_status_tbl.EXTEND (1);
                  l_st_ser_status_tbl (l_st_ser_index)        := l_status_id;
                  l_st_ser_group_mark_id_tbl.EXTEND (1);
                  l_st_ser_group_mark_id_tbl (l_st_ser_index) := l_group_mark_id;

                  IF (per_serial_msn_src_csr%ISOPEN)
                  THEN
                    CLOSE per_serial_msn_src_csr;
                  END IF;

                  l_old_serial := l_next_serial;
                  l_next_serial :=
                    inv_serial_number_pub.increment_ser_num
                                                                (l_old_serial
                                                               , 1
                                                                );

                  IF (l_old_serial = l_next_serial)
                  THEN
                    fnd_message.set_name ('INV', 'INVALID_SERIAL_NUMBER');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                END LOOP;
              END LOOP;
            /*Resulting side records*/
            ELSIF (   (    l_transaction_type_id =
                                              inv_globals.g_type_inv_lot_split
                       AND l_source_record = 'N'
                      )
                   OR (    l_transaction_type_id =
                                              inv_globals.g_type_inv_lot_merge
                       AND l_source_record = 'Y'
                      )
                  )
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('l_marker  150 l_count' || l_count
                           , 'Populate_REcords'
                            );
                 print_debug ('here is  150 open cursor'
                           , 'Populate_REcords'
                            );
                 print_debug ('l_serial_transaction_temp_id ' || l_serial_transaction_temp_id
                           , 'Populate_REcords'
                            );
              END IF;

                FOR l_ser_csr  IN msni_csr(l_serial_transaction_temp_id) LOOP
                  l_next_serial := l_ser_csr.fm_serial_number;
                  print_debug ('processing serial ' || l_next_serial
                           , 'Populate_REcords'
                            );
                  l_serial_diff :=
                  inv_serial_number_pub.get_serial_diff
                                                  (l_ser_csr.fm_serial_number
                                                 , l_ser_csr.to_serial_number
                                                  );

                IF (l_serial_diff = -1)
                THEN
                  fnd_message.set_name ('INV', 'INV_INVALID_SERIAL_RANGE');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                FOR i IN 1 .. l_serial_diff
                LOOP
                  l_rs_ser_index := l_rs_ser_index + 1;
                  l_rs_ser_number_tbl (l_next_serial) := l_next_serial;
                  /*This will be used in validate_quantity to make sure that there
                   *are same number of serials for each lot as in MTLI.quantity
                   */
                  l_rs_ser_parent_lot_tbl (l_next_serial) :=
                                                         l_lot_csr.lot_number;

                  print_debug ('Open per_Ser_msn_csr for  ' || l_next_serial
                           , 'Populate_REcords'
                            );
                  OPEN per_serial_msn_csr (l_next_serial
                                         , l_mti_csr.organization_id
                                         , l_mti_csr.inventory_item_id
                                          );
                   FETCH per_serial_msn_csr
                   INTO l_group_mark_id
                      , l_status_id;

		  IF(per_serial_msn_csr%NOTFOUND) THEN
		    IF(per_serial_msn_csr%ISOPEN) THEN
			CLOSE per_serial_msn_csr;
		    END IF;
		    fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
		    fnd_msg_pub.ADD;
		    RAISE NO_DATA_FOUND;
		  END IF;

                  l_rs_ser_status_tbl.EXTEND (1);
                  l_rs_ser_status_tbl (l_rs_ser_index)        := l_status_id;
                  l_rs_ser_group_mark_id_tbl.EXTEND (1);
                  l_rs_ser_group_mark_id_tbl (l_rs_ser_index) := l_group_mark_id;

                  IF (per_serial_msn_csr%ISOPEN)
                  THEN
                    CLOSE per_serial_msn_csr;
                  END IF;

                  l_old_serial := l_next_serial;
                  print_debug ('calling increment_serial_number  ' || l_next_serial
                           , 'Populate_REcords'
                            );
                  l_next_serial :=
                    inv_serial_number_pub.increment_ser_num
                                                                (l_old_serial
                                                               , 1
                                                                );

                  IF (l_next_serial = l_old_serial)
                  THEN
                    fnd_message.set_name ('INV', 'INVALID_SERIAL_NUMBER');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                END LOOP;
              END LOOP;
            /*It is a lot translate transaction.*/
            ELSIF (l_transaction_type_id =
                                          inv_globals.g_type_inv_lot_translate
                   AND l_source_record = 'Y'
                  )
            THEN
            l_st_ser_index := 0;
            l_rs_ser_index := 0;
            IF (l_debug = 1)
            THEN
              print_debug ('l_lot_csr.lot_number ' || l_lot_csr.lot_number
                         , 'Populate_REcords'
                          );
              print_debug ('l_mti_csr.inventory_item_id ' || l_mti_csr.inventory_item_id
                         , 'Populate_REcords'
                          );
              print_debug ('l_mti_csr.subinventory_code ' || l_mti_csr.subinventory_code
                         , 'Populate_REcords'
                          );
              print_debug ('l_mti_csr.locator_id ' || l_mti_csr.locator_id
                         , 'Populate_REcords'
                          );
              print_debug ('l_mti_csr.organization_id ' || l_mti_csr.organization_id
                         , 'Populate_REcords'
                          );
              print_debug ('l_mti_csr.lpn_id ' || l_mti_csr.lpn_id
                         , 'Populate_REcords'
                          );
              print_debug ('l_mti_csr.revision ' || l_mti_csr.revision
                         , 'Populate_REcords'
                          );

            END IF;


                FOR l_ser_msn_csr  IN msn_csr(l_lot_csr.lot_number
                          , l_mti_csr.inventory_item_id
                          , l_mti_csr.subinventory_code
                          , l_mti_csr.locator_id
                          , l_mti_csr.organization_id
			  , l_mti_csr.lpn_id
			  , l_mti_csr.revision
                           )
              LOOP
                IF (l_debug = 1)
                THEN
                  print_debug ('l_marker  160 l_count' || l_count
                             , 'Populate_REcords'
                              );
                END IF;

                  l_st_ser_index := l_st_ser_index + 1;
                  l_st_ser_number_tbl (l_ser_msn_csr.serial_number) :=
                                                  l_ser_msn_csr.serial_number;
                  --This will be used at the time of inv_serial_number_pub.validate_serials
                  l_st_ser_parent_lot_tbl (l_ser_msn_csr.serial_number)     := l_lot_csr.lot_number;
                  l_st_ser_status_tbl.EXTEND (1);
                  l_st_ser_status_tbl (l_st_ser_index)        := l_ser_msn_csr.status_id;
                  l_st_ser_group_mark_id_tbl.EXTEND (1);
                  l_st_ser_group_mark_id_tbl (l_st_ser_index) := l_ser_msn_csr.group_mark_id;
                  /*Resulting serial array is also populated using the source record.
                   *as the resulting item, lot combination may not be present in the
                   *mtl_Serial_numbers table.
                   */
                  l_rs_ser_index := l_rs_ser_index + 1;
                  l_rs_ser_number_tbl (l_ser_msn_csr.serial_number)     := l_ser_msn_csr.serial_number;
                  l_rs_ser_parent_lot_tbl (l_ser_msn_csr.serial_number) := l_lot_csr.lot_number;
                  l_rs_ser_status_tbl.EXTEND (1);
                  l_rs_ser_status_tbl (l_rs_ser_index)              := l_ser_msn_csr.status_id;
                  l_rs_ser_group_mark_id_tbl.EXTEND (1);
                  l_rs_ser_group_mark_id_tbl (l_rs_ser_index)       := l_ser_msn_csr.group_mark_id;


              END LOOP;                                              --MSN_CSR
            END IF;
          END IF;                                        --ITEM IS LOT/SERIAL.
        EXCEPTION
          WHEN OTHERS
          THEN
            IF (l_debug = 1)
            THEN
              print_debug ('l_marker  160 l_count' || l_count
                         , 'Populate_REcords'
                          );
              print_debug ('Serial Info in MSNI is invalid.Following may be the cause=>' ||
			   ' a).Invalid Item/Rev/Lot/Sub/Loc/LPN/Serial combo ' ||
			   ' b).Current status is not in 1 or 3 ' ||
			   ' c).Serial is reserved '
                         , 'Populate_REcords'
                          );
              print_debug ('Error while fetching the serial information' || SQLERRM
                         , 'Populate_REcords'
                          );
            END IF;

            l_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
        END;
      END LOOP;                                    --End loop for MTLI records
    END LOOP;                                      --End loop for MTI  records

    x_st_item_id_tbl := l_st_item_id_tbl;
    x_st_org_id_tbl := l_st_org_id_tbl;
    x_st_revision_tbl := l_st_revision_tbl;
    x_st_sub_code_tbl := l_st_sub_code_tbl;
    x_st_locator_id_tbl := l_st_locator_id_tbl;
    x_st_lot_num_tbl := l_st_lot_number_tbl;
    x_st_lpn_id_tbl := l_st_lpn_id_tbl;
    x_st_quantity_tbl := l_st_quantity_tbl;
    x_st_cost_group_tbl := l_st_cost_group_id_tbl;
    x_st_uom_tbl := l_st_uom_tbl;
    x_rs_item_id_tbl := l_rs_item_id_tbl;
    x_rs_org_id_tbl := l_rs_org_id_tbl;
    x_rs_revision_tbl := l_rs_revision_tbl;
    x_rs_sub_code_tbl := l_rs_sub_code_tbl;
    x_rs_locator_id_tbl := l_rs_locator_id_tbl;
    x_rs_lot_num_tbl := l_rs_lot_number_tbl;
    x_rs_lpn_id_tbl := l_rs_lpn_id_tbl;
    x_rs_quantity_tbl := l_rs_quantity_tbl;
    x_rs_cost_group_tbl := l_rs_cost_group_id_tbl;
    x_rs_uom_tbl := l_rs_uom_tbl;
    x_transaction_type_id := l_transaction_type_id;
    x_st_interface_id_tbl := l_st_interface_id_tbl;
    x_rs_interface_id_tbl := l_rs_interface_id_tbl;
    x_st_status_id_tbl := l_st_status_id_tbl;
    x_rs_status_id_tbl := l_rs_status_id_tbl;
    x_st_lot_exp_tbl := l_st_lot_exp_tbl;
    x_rs_lot_exp_tbl := l_rs_lot_exp_tbl;
    x_acct_period_tbl := l_acct_period_tbl;
    x_st_dist_account_id := l_st_dist_account_id;
    x_rs_dist_account_id := l_rs_dist_account_id;
    x_st_ser_num_tbl := l_st_ser_number_tbl;
    x_st_ser_parent_lot_tbl := l_st_ser_parent_lot_tbl;
    x_rs_ser_parent_lot_tbl := l_rs_ser_parent_lot_tbl;
    x_rs_ser_num_tbl := l_rs_ser_number_tbl;
    x_st_ser_status_tbl := l_st_ser_status_tbl;
    x_rs_ser_status_tbl := l_rs_ser_status_tbl;
    x_st_ser_grp_mark_id_tbl := l_st_ser_group_mark_id_tbl;
    x_rs_ser_grp_mark_id_tbl := l_rs_ser_group_mark_id_tbl;
    x_st_ser_parent_sub_tbl  := l_st_ser_parent_sub_tbl;
    x_st_ser_parent_loc_tbl  := l_st_ser_parent_loc_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      x_validation_status := 'E';
      x_return_status := fnd_api.g_ret_sts_error;
  END populate_records;

  /* Bug 5354721. The following procedure populates the column name, value type and length
     of all the Lot Attribute columns in MTL_LOT_NUMBERS in the global table g_lot_attr_tbl.
     And this table will be then used in get_lot_attr_record procedure to get the values of the
     corresponding columns. Moved this part of code from get_lot_Attr_record to here as this metadata
     poupulation can only be done once and be re-used for all the subsequent records.
  */
  PROCEDURE  get_lot_attr_table
  IS
    l_lot_attr_tbl       inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_debug              NUMBER
                             := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

  BEGIN

    print_debug('Before setting all the column names and types' , 'get_lot_attr_table');
    /*Bug:5408823. Instead of fetching the metadata details from ALL_TAB_COLUMNS,
      hardcoding them as follows.
    */
      l_lot_attr_tbl (1).column_name :=  'ATTRIBUTE_CATEGORY';
      l_lot_attr_tbl (1).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (1).column_length := 30;
      l_lot_attr_tbl (2).column_name :=  'ATTRIBUTE1';
      l_lot_attr_tbl (2).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (2).column_length := 150;
      l_lot_attr_tbl (3).column_name :=  'ATTRIBUTE2' ;
      l_lot_attr_tbl (3).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (3).column_length := 150;
      l_lot_attr_tbl (4).column_name :=  'ATTRIBUTE3';
      l_lot_attr_tbl (4).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (4).column_length := 150;
      l_lot_attr_tbl (5).column_name :=  'ATTRIBUTE4';
      l_lot_attr_tbl (5).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (5).column_length := 150;
      l_lot_attr_tbl (6).column_name :=  'ATTRIBUTE5';
      l_lot_attr_tbl (6).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (6).column_length := 150;
      l_lot_attr_tbl (7).column_name :=  'ATTRIBUTE6';
      l_lot_attr_tbl (7).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (7).column_length := 150;
      l_lot_attr_tbl (8).column_name :=  'ATTRIBUTE7';
      l_lot_attr_tbl (8).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (8).column_length := 150;
      l_lot_attr_tbl (9).column_name :=  'ATTRIBUTE8';
      l_lot_attr_tbl (9).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (9).column_length := 150;
      l_lot_attr_tbl (10).column_name :=  'ATTRIBUTE9';
      l_lot_attr_tbl (10).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (10).column_length := 150;
      l_lot_attr_tbl (11).column_name :=  'ATTRIBUTE10';
      l_lot_attr_tbl (11).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (11).column_length := 150;
      l_lot_attr_tbl (12).column_name := 'ATTRIBUTE11';
      l_lot_attr_tbl (12).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (12).column_length := 150;
      l_lot_attr_tbl (13).column_name := 'ATTRIBUTE12';
      l_lot_attr_tbl (13).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (13).column_length := 150;
      l_lot_attr_tbl (14).column_name := 'ATTRIBUTE13';
      l_lot_attr_tbl (14).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (14).column_length := 150;
      l_lot_attr_tbl (15).column_name := 'ATTRIBUTE14';
      l_lot_attr_tbl (15).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (15).column_length := 150;
      l_lot_attr_tbl (16).column_name := 'ATTRIBUTE15';
      l_lot_attr_tbl (16).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (16).column_length := 150;
      l_lot_attr_tbl (17).column_name := 'DESCRIPTION' ;
      l_lot_attr_tbl (17).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (17).column_length := 256;
      l_lot_attr_tbl (18).column_name := 'VENDOR_NAME';
      l_lot_attr_tbl (18).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (18).column_length := 240;
      l_lot_attr_tbl (19).column_name := 'DATE_CODE';
      l_lot_attr_tbl (19).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (19).column_length := 150  ;
      l_lot_attr_tbl (20).column_name := 'CHANGE_DATE';
      l_lot_attr_tbl (20).column_type  :=  'DATE';
      l_lot_attr_tbl (20).column_length := 11;
      l_lot_attr_tbl (21).column_name := 'AGE';
      l_lot_attr_tbl (21).column_type  :=  'NUMBER';
      l_lot_attr_tbl (21).column_length := 38;
      l_lot_attr_tbl (22).column_name := 'LOT_ATTRIBUTE_CATEGORY';
      l_lot_attr_tbl (22).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (22).column_length := 30;
      l_lot_attr_tbl (23).column_name := 'ITEM_SIZE';
      l_lot_attr_tbl (23).column_type  :=  'NUMBER';
      l_lot_attr_tbl (23).column_length := 38;
      l_lot_attr_tbl (24).column_name := 'COLOR';
      l_lot_attr_tbl (24).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (24).column_length := 150;
      l_lot_attr_tbl (25).column_name := 'VOLUME';
      l_lot_attr_tbl (25).column_type  :=  'NUMBER';
      l_lot_attr_tbl (25).column_length := 38;
      l_lot_attr_tbl (26).column_name := 'VOLUME_UOM';
      l_lot_attr_tbl (26).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (26).column_length := 3;
      l_lot_attr_tbl (27).column_name := 'PLACE_OF_ORIGIN';
      l_lot_attr_tbl (27).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (27).column_length := 150;
      l_lot_attr_tbl (28).column_name := 'BEST_BY_DATE';
      l_lot_attr_tbl (28).column_type  :=  'DATE';
      l_lot_attr_tbl (28).column_length := 11;
      l_lot_attr_tbl (29).column_name := 'LENGTH';
      l_lot_attr_tbl (29).column_type  :=  'NUMBER';
      l_lot_attr_tbl (29).column_length := 38;
      l_lot_attr_tbl (30).column_name := 'LENGTH_UOM';
      l_lot_attr_tbl (30).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (30).column_length := 3;
      l_lot_attr_tbl (31).column_name := 'RECYCLED_CONTENT';
      l_lot_attr_tbl (31).column_type  :=  'NUMBER';
      l_lot_attr_tbl (31).column_length := 38;
      l_lot_attr_tbl (32).column_name := 'THICKNESS';
      l_lot_attr_tbl (32).column_type  :=  'NUMBER';
      l_lot_attr_tbl (32).column_length := 38;
      l_lot_attr_tbl (33).column_name := 'THICKNESS_UOM';
      l_lot_attr_tbl (33).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (33).column_length := 3;
      l_lot_attr_tbl (34).column_name := 'WIDTH';
      l_lot_attr_tbl (34).column_type  :=  'NUMBER';
      l_lot_attr_tbl (34).column_length := 38;
      l_lot_attr_tbl (35).column_name := 'WIDTH_UOM';
      l_lot_attr_tbl (35).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (35).column_length := 3;
      l_lot_attr_tbl (36).column_name := 'CURL_WRINKLE_FOLD';
      l_lot_attr_tbl (36).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (36).column_length := 150;
      l_lot_attr_tbl (37).column_name := 'C_ATTRIBUTE1';
      l_lot_attr_tbl (37).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (37).column_length := 150;
      l_lot_attr_tbl (38).column_name := 'C_ATTRIBUTE2';
      l_lot_attr_tbl (38).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (38).column_length := 150;
      l_lot_attr_tbl (39).column_name := 'C_ATTRIBUTE3';
      l_lot_attr_tbl (39).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (39).column_length := 150;
      l_lot_attr_tbl (40).column_name := 'C_ATTRIBUTE4';
      l_lot_attr_tbl (40).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (40).column_length := 150;
      l_lot_attr_tbl (41).column_name := 'C_ATTRIBUTE5';
      l_lot_attr_tbl (41).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (41).column_length := 150;
      l_lot_attr_tbl (42).column_name := 'C_ATTRIBUTE6';
      l_lot_attr_tbl (42).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (42).column_length := 150;
      l_lot_attr_tbl (43).column_name := 'C_ATTRIBUTE7';
      l_lot_attr_tbl (43).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (43).column_length := 150;
      l_lot_attr_tbl (44).column_name := 'C_ATTRIBUTE8';
      l_lot_attr_tbl (44).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (44).column_length := 150;
      l_lot_attr_tbl (45).column_name := 'C_ATTRIBUTE9';
      l_lot_attr_tbl (45).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (45).column_length := 150;
      l_lot_attr_tbl (46).column_name := 'C_ATTRIBUTE10';
      l_lot_attr_tbl (46).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (46).column_length := 150;
      l_lot_attr_tbl (47).column_name := 'C_ATTRIBUTE11';
      l_lot_attr_tbl (47).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (47).column_length := 150;
      l_lot_attr_tbl (48).column_name := 'C_ATTRIBUTE12';
      l_lot_attr_tbl (48).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (48).column_length := 150;
      l_lot_attr_tbl (49).column_name := 'C_ATTRIBUTE13';
      l_lot_attr_tbl (49).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (49).column_length := 150;
      l_lot_attr_tbl (50).column_name := 'C_ATTRIBUTE14';
      l_lot_attr_tbl (50).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (50).column_length := 150;
      l_lot_attr_tbl (51).column_name := 'C_ATTRIBUTE15';
      l_lot_attr_tbl (51).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (51).column_length := 150;
      l_lot_attr_tbl (52).column_name := 'C_ATTRIBUTE16';
      l_lot_attr_tbl (52).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (52).column_length := 150;
      l_lot_attr_tbl (53).column_name := 'C_ATTRIBUTE17';
      l_lot_attr_tbl (53).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (53).column_length := 150;
      l_lot_attr_tbl (54).column_name := 'C_ATTRIBUTE18';
      l_lot_attr_tbl (54).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (54).column_length := 150;
      l_lot_attr_tbl (55).column_name := 'C_ATTRIBUTE19';
      l_lot_attr_tbl (55).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (55).column_length := 150;
      l_lot_attr_tbl (56).column_name := 'C_ATTRIBUTE20';
      l_lot_attr_tbl (56).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (56).column_length := 150;
      l_lot_attr_tbl (57).column_name := 'D_ATTRIBUTE1';
      l_lot_attr_tbl (57).column_type  :=  'DATE';
      l_lot_attr_tbl (57).column_length := 11;
      l_lot_attr_tbl (58).column_name := 'D_ATTRIBUTE2';
      l_lot_attr_tbl (58).column_type  :=  'DATE';
      l_lot_attr_tbl (58).column_length := 11;
      l_lot_attr_tbl (59).column_name := 'D_ATTRIBUTE3';
      l_lot_attr_tbl (59).column_type  :=  'DATE';
      l_lot_attr_tbl (59).column_length := 11;
      l_lot_attr_tbl (60).column_name := 'D_ATTRIBUTE4';
      l_lot_attr_tbl (60).column_type  :=  'DATE';
      l_lot_attr_tbl (60).column_length := 11;
      l_lot_attr_tbl (61).column_name := 'D_ATTRIBUTE5';
      l_lot_attr_tbl (61).column_type  :=  'DATE';
      l_lot_attr_tbl (61).column_length := 11;
      l_lot_attr_tbl (62).column_name := 'D_ATTRIBUTE6';
      l_lot_attr_tbl (62).column_type  :=  'DATE';
      l_lot_attr_tbl (62).column_length := 11;
      l_lot_attr_tbl (63).column_name := 'D_ATTRIBUTE7';
      l_lot_attr_tbl (63).column_type  :=  'DATE';
      l_lot_attr_tbl (63).column_length := 11;
      l_lot_attr_tbl (64).column_name := 'D_ATTRIBUTE8';
      l_lot_attr_tbl (64).column_type  :=  'DATE';
      l_lot_attr_tbl (64).column_length := 11;
      l_lot_attr_tbl (65).column_name := 'D_ATTRIBUTE9';
      l_lot_attr_tbl (65).column_type  :=  'DATE';
      l_lot_attr_tbl (65).column_length := 11;
      l_lot_attr_tbl (66).column_name := 'D_ATTRIBUTE10';
      l_lot_attr_tbl (66).column_type  :=  'DATE';
      l_lot_attr_tbl (66).column_length := 11;
      l_lot_attr_tbl (67).column_name := 'N_ATTRIBUTE1';
      l_lot_attr_tbl (67).column_type  :=  'NUMBER';
      l_lot_attr_tbl (67).column_length := 38;
      l_lot_attr_tbl (68).column_name := 'N_ATTRIBUTE2';
      l_lot_attr_tbl (68).column_type  :=  'NUMBER';
      l_lot_attr_tbl (68).column_length := 38;
      l_lot_attr_tbl (69).column_name := 'N_ATTRIBUTE3';
      l_lot_attr_tbl (69).column_type  :=  'NUMBER';
      l_lot_attr_tbl (69).column_length := 38;
      l_lot_attr_tbl (70).column_name := 'N_ATTRIBUTE4';
      l_lot_attr_tbl (70).column_type  :=  'NUMBER';
      l_lot_attr_tbl (70).column_length := 38;
      l_lot_attr_tbl (71).column_name := 'N_ATTRIBUTE5';
      l_lot_attr_tbl (71).column_type  :=  'NUMBER';
      l_lot_attr_tbl (71).column_length := 38;
      l_lot_attr_tbl (72).column_name := 'N_ATTRIBUTE6';
      l_lot_attr_tbl (72).column_type  :=  'NUMBER';
      l_lot_attr_tbl (72).column_length := 38;
      l_lot_attr_tbl (73).column_name := 'N_ATTRIBUTE7';
      l_lot_attr_tbl (73).column_type  :=  'NUMBER';
      l_lot_attr_tbl (73).column_length := 38;
      l_lot_attr_tbl (74).column_name := 'N_ATTRIBUTE8';
      l_lot_attr_tbl (74).column_type  :=  'NUMBER';
      l_lot_attr_tbl (74).column_length := 38;
      l_lot_attr_tbl (75).column_name := 'N_ATTRIBUTE9';
      l_lot_attr_tbl (75).column_type  :=  'NUMBER';
      l_lot_attr_tbl (75).column_length := 38;
      l_lot_attr_tbl (76).column_name := 'N_ATTRIBUTE10';
      l_lot_attr_tbl (76).column_type  :=  'NUMBER';
      l_lot_attr_tbl (76).column_length := 38;
      l_lot_attr_tbl (77).column_name := 'VENDOR_ID';
      l_lot_attr_tbl (77).column_type  :=  'NUMBER';
      l_lot_attr_tbl (77).column_length := 38;
      l_lot_attr_tbl (78).column_name := 'TERRITORY_CODE';
      l_lot_attr_tbl (78).column_type  :=  'VARCHAR2';
      l_lot_attr_tbl (78).column_length := 30;


    print_debug('After setting all the column names and types' , 'get_lot_attr_table');
    g_lot_attr_tbl  := l_lot_attr_tbl;

  EXCEPTION
    WHEN OTHERS
    THEN

      IF (l_debug = 1)
      THEN
        print_debug ('In Exception in get_lot_attr_table',
                     'get_lot_attr_table'
                    );
      END IF;
  END get_lot_attr_table;


  PROCEDURE get_lot_attr_record (
    x_lot_attr_tbl               OUT  NOCOPY    inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_transaction_interface_id   IN       NUMBER
  , p_lot_number                 IN       VARCHAR2
  , p_starting_lot_number        IN       VARCHAR2
  , p_organization_id            IN       NUMBER
  , p_inventory_item_id          IN       NUMBER
  )
  IS
    /*Bug:5354721. Moved the following code to procedure get_lot_attr_table. */
    /*l_app_owner_schema   VARCHAR2 (30);
    l_app_status         VARCHAR2 (1);
    l_app_industry       VARCHAR2 (1);
    l_app_info_status    BOOLEAN
      := fnd_installation.get_app_info (application_short_name     => 'INV'
                                      , status                     => l_app_status
                                      , industry                   => l_app_industry
                                      , oracle_schema              => l_app_owner_schema
                                       );

    CURSOR lot_column_csr (p_table_name VARCHAR2)
    IS
      SELECT   column_name
             , data_type
             , data_length
          FROM all_tab_columns
         WHERE table_name = UPPER (p_table_name)
           AND owner = l_app_owner_schema
           AND column_id > 22
      ORDER BY column_id; */

    l_lot_attr_tbl       inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_column_idx         NUMBER;
    l_select_stmt        LONG                                         := NULL;
    l_sql_p              INTEGER                                      := NULL;
    l_rows_processed     INTEGER                                      := NULL;
    l_line               NUMBER                                       := 1;
    l_stmt               LONG;
    l_lot_num            NUMBER                                       := 0;
    l_debug              NUMBER
                             := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN

    /*Bug 5354721. The following satement copies all the columns names, type and length into l_lot_attr_tbl*/
    l_lot_attr_tbl :=  g_lot_attr_tbl;


    BEGIN
      SELECT COUNT (lot_number)
        INTO l_lot_num
        FROM mtl_lot_numbers mtl
       WHERE lot_number = p_lot_number
         AND inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_INVALID_LOT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    /*Bug:5354721. Moved the following code to get_lot_Attr_table where all the
      metadata information column name , type and length are populated in global table
      g_lot_attr_tbl.

      Also, instead of building the SELECT clause here in the loop it is defined in the
      global varialble g_select_stmt only once.

    */
    /*
    FOR l_lot_column_csr IN lot_column_csr ('MTL_TRANSACTION_LOTS_INTERFACE')
    LOOP
      l_column_idx := l_column_idx + 1;
      l_lot_attr_tbl (l_column_idx).column_name :=
                                                 l_lot_column_csr.column_name;
      l_lot_attr_tbl (l_column_idx).column_type := l_lot_column_csr.data_type;

      IF UPPER (l_lot_column_csr.data_type) = 'DATE'
      THEN
        l_lot_attr_tbl (l_column_idx).column_length := 11;
      ELSIF UPPER (l_lot_column_csr.data_type) = 'NUMBER'
      THEN
        l_lot_attr_tbl (l_column_idx).column_length := 38;
      ELSE
        l_lot_attr_tbl (l_column_idx).column_length :=
                                                 l_lot_column_csr.data_length;
      END IF;

      IF (l_column_idx = 1)
      THEN
        l_select_stmt :=
             l_select_stmt
          || ' NVL(MTLI.'
          || l_lot_attr_tbl (l_column_idx).column_name
          || ', MTL.'
          || l_lot_attr_tbl (l_column_idx).column_name
          || ')';
      ELSE
        l_select_stmt :=
             l_select_stmt
          || ' , NVL(MTLI.'
          || l_lot_attr_tbl (l_column_idx).column_name
          || ', MTL.'
          || l_lot_attr_tbl (l_column_idx).column_name
          || ')';
      END IF;
    END LOOP;
    */

    IF (l_lot_num > 0)
    THEN
      /*Bug:5354721.  Appending FROM clause to the global statement. */
      l_select_stmt :=
           g_select_stmt
        || ' FROM MTL_TRANSACTION_LOTS_INTERFACE MTLI, MTL_TRANSACTIONS_INTERFACE MTI, '
        || ' MTL_LOT_NUMBERS MLN '
        || ' WHERE mtli.transaction_interface_id = :b_interface_id '
        || ' AND   mtli.lot_number = :b_lot_number '
        || ' AND   mtli.transaction_interface_id = mti.transaction_interface_id '
        || ' AND   mln.lot_number = mtli.lot_number (+)'
        || ' AND   mln.inventory_item_id = mti.inventory_item_id (+)'
        || ' AND   mln.organization_id = mti.organization_id (+)';
    ELSE
      -- If it is a new lot, we get all the attributes from MTI
      -- and for others which are not mentioned, we get ir from the
      -- parent lot. Passing a new parameter called starting lot
      -- which is the lot number of the parent lot.
      l_select_stmt :=
           g_select_stmt
        || ' FROM MTL_TRANSACTION_LOTS_INTERFACE MTLI, MTL_TRANSACTIONS_INTERFACE MTI, '
        || ' MTL_LOT_NUMBERS MLN '
        || ' WHERE mtli.transaction_interface_id = :b_interface_id '
        || ' AND   mtli.lot_number = :b_lot_number '
        || ' AND   mtli.transaction_interface_id = mti.transaction_interface_id '
        || ' AND   mln.lot_number = :b_starting_lot_number'
        || ' AND   mln.inventory_item_id = mti.inventory_item_id (+)'
        || ' AND   mln.organization_id = mti.organization_id (+)';
    -- l_select_stmt := l_select_stmt || ' FROM MTL_TRANSACTION_LOTS_INTERFACE ' ||
    --   ' WHERE lot_number = :b_lot_number ' ||
    --   ' AND   transaction_interface_id = :b_interface_id ';
    END IF;

    --print_debug(l_select_stmt, 'get_lot_attr_record');
    IF (l_debug = 1)
    THEN
      print_debug ('after setting the sql stmt', 'get_lot_attr_record');
    END IF;

    l_sql_p := DBMS_SQL.open_cursor;
    DBMS_SQL.parse (l_sql_p, l_select_stmt, DBMS_SQL.native);
    DBMS_SQL.bind_variable (l_sql_p
                          , 'b_interface_id'
                          , p_transaction_interface_id
                           );
    DBMS_SQL.bind_variable (l_sql_p, 'b_lot_number', p_lot_number);

    IF l_lot_num = 0
    THEN
      DBMS_SQL.bind_variable (l_sql_p
                            , 'b_starting_lot_number'
                            , p_starting_lot_number
                             );
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('after open cursor and bind variables'
                 , 'get_lot_attr_record'
                  );
    END IF;

    l_column_idx := 0;

    FOR i IN 1 .. l_lot_attr_tbl.COUNT
    LOOP
      l_column_idx := i;
      DBMS_SQL.define_column (l_sql_p
                            , l_column_idx
                            , l_lot_attr_tbl (i).column_value
                            , l_lot_attr_tbl (i).column_length
                             );
    END LOOP;

    IF (l_debug = 1)
    THEN
      print_debug ('after define columns', 'get_lot_attr_record');
    END IF;

    l_rows_processed := DBMS_SQL.EXECUTE (l_sql_p);

    IF (l_debug = 1)
    THEN
      print_debug ('l_rows_processed is ' || l_rows_processed
                 , 'get_lot_attr_record'
                  );
      print_debug ('Interface Id ' || p_transaction_interface_id
                 , 'get_lot_attr_record'
                  );
      print_debug ('Lot Number passed ' || p_lot_number
                 , 'get_lot_attr_record');
      print_debug ('Starting Lot Number passed ' || p_starting_lot_number
                 , 'get_lot_attr_record'
                  );
    END IF;

    LOOP
      IF (DBMS_SQL.fetch_rows (l_sql_p) > 0)
      THEN
        l_column_idx := 0;

        FOR i IN 1 .. l_lot_attr_tbl.COUNT
        LOOP
          l_column_idx := i;
          DBMS_SQL.column_value (l_sql_p
                               , l_column_idx
                               , l_lot_attr_tbl (i).column_value
                                );
        END LOOP;
      ELSE
        --dbms_sql.close_cursor(l_sql_p);
        EXIT;
      END IF;

      EXIT;
    END LOOP;

    IF (l_debug = 1)
    THEN
      print_debug ('after fetching rows', 'get_lot_attr_record');
    END IF;

    DBMS_SQL.close_cursor (l_sql_p);

    IF (l_debug = 1)
    THEN
      print_debug ('after closing cursor', 'get_lot_attr_record');
      print_debug ('Count of the attr table' || l_lot_attr_tbl.COUNT
                 , 'get_lot_attr_record'
                  );
      print_debug ('Lot Number' || l_lot_num, 'get_lot_attr_record');
    END IF;

    FOR i IN 1 .. l_lot_attr_tbl.COUNT
    LOOP
      IF (l_lot_attr_tbl (i).column_value IS NOT NULL)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Column_NAME is ' || l_lot_attr_tbl (i).column_name
                     , 'get_lot_attr_record'
                      );
          print_debug ('Column Value is ' || l_lot_attr_tbl (i).column_value
                     , 'get_lot_attr_record'
                      );
        END IF;
      END IF;
    END LOOP;

    x_lot_attr_tbl := l_lot_attr_tbl;
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_message.set_name ('WMS', 'WMS_GET_LOT_ATTR_ERROR');
      fnd_msg_pub.ADD;

--  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1)
      THEN
        print_debug ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                   , 'get_lot_attr_record'
                    );
      END IF;
  END get_lot_attr_record;

  PROCEDURE update_lot_attr_record (
    p_lot_attr_tbl               IN   inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_transaction_interface_id   IN   NUMBER
  , p_lot_number                 IN   VARCHAR2
  , p_organization_id            IN   NUMBER
  , p_inventory_item_id          IN   NUMBER
  )
  IS
    l_lot_attr_tbl     inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_column_idx       NUMBER;
    l_update_stmt      LONG   := 'UPDATE MTL_TRANSACTION_LOTS_INTERFACE SET ';
    l_sql_p            INTEGER                                      := NULL;
    l_rows_processed   INTEGER                                      := NULL;
    l_debug            NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    print_debug ('Inside update attr', 'Validate_Lot_Split');
    print_debug ('Count' || p_lot_attr_tbl.COUNT, 'Update Lot attr');
    print_debug ('Lot Number' || p_lot_number, 'Update Lot attr');
    l_column_idx := 1;

    FOR i IN 1 .. p_lot_attr_tbl.COUNT
    LOOP
      --if( i = 1 ) then
      IF (p_lot_attr_tbl (i).column_value IS NOT NULL)
      THEN
        IF (p_lot_attr_tbl (i).column_type = 'NUMBER')
        THEN
          EXECUTE IMMEDIATE    'Update mtl_transaction_lots_interface
		    set '
                            || p_lot_attr_tbl (i).column_name
                            || ' = :1 '
                            || 'where transaction_interface_id = :2 '
                      USING p_lot_attr_tbl (i).column_value
                          , p_transaction_interface_id;
        END IF;

        IF (p_lot_attr_tbl (i).column_type = 'DATE')
        THEN
          EXECUTE IMMEDIATE    'Update Mtl_transaction_lots_interface
		    SET '
                            || p_lot_attr_tbl (i).column_name
                            || ' = :1 '
                            || 'where transaction_interface_id = :2 '
                      USING
                            fnd_date.canonical_to_date
                                               (p_lot_attr_tbl (i).column_value
                                               )
                          , p_transaction_interface_id;
        END IF;

        IF (p_lot_attr_tbl (i).column_type = 'VARCHAR2')
        THEN
          EXECUTE IMMEDIATE    'Update Mtl_transaction_lots_interface
		    SET '
                            || p_lot_attr_tbl (i).column_name
                            || ' = :1 '
                            || 'where transaction_interface_id = :2 '
                      USING p_lot_attr_tbl (i).column_value
                          , p_transaction_interface_id;
        END IF;
      END IF;
    -- end if;
    --print_debug(p_lot_attr_tbl(i).COLUMN_NAME, 'update_lot_attr_record');
    END LOOP;
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_message.set_name ('WMS', 'WMS_UPDATE_ATTR_ERROR');
      fnd_msg_pub.ADD;

      --    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1)
      THEN
        print_debug ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                   , 'get_lot_attr_record'
                    );
      END IF;
  END update_lot_attr_record;

  PROCEDURE validate_lot_split_trx (
    x_return_status       OUT NOCOPY      VARCHAR2
  , x_msg_count           OUT NOCOPY      NUMBER
  , x_msg_data            OUT NOCOPY      VARCHAR2
  , x_validation_status   OUT NOCOPY      VARCHAR2
  , p_parent_id           IN              NUMBER
  )
  IS
    l_return_status              VARCHAR2 (1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2 (255);
    l_validation_status          VARCHAR2 (1);
    l_transaction_type_id        NUMBER;
    --  l_acct_period_id NUMBER;
    l_transaction_interface_id   NUMBER;
    l_transaction_action_id      NUMBER;
    l_st_item_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_st_org_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_st_revision_tbl            inv_lot_trx_validation_pub.revision_table;
    l_st_quantity_tbl            inv_lot_trx_validation_pub.number_table;
    l_st_uom_tbl                 inv_lot_trx_validation_pub.uom_table;
    l_st_locator_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_st_sub_code_tbl            inv_lot_trx_validation_pub.sub_code_table;
    l_st_cost_group_id_tbl       inv_lot_trx_validation_pub.number_table;
    l_st_lpn_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_item_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_rs_org_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_revision_tbl            inv_lot_trx_validation_pub.revision_table;
    l_rs_quantity_tbl            inv_lot_trx_validation_pub.number_table;
    l_rs_uom_tbl                 inv_lot_trx_validation_pub.uom_table;
    l_rs_locator_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_sub_code_tbl            inv_lot_trx_validation_pub.sub_code_table;
    l_rs_lpn_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_cost_group_id_tbl       inv_lot_trx_validation_pub.number_table;
    l_st_lot_number_tbl          inv_lot_trx_validation_pub.lot_number_table;
    l_rs_lot_number_tbl          inv_lot_trx_validation_pub.lot_number_table;
    --Added for OSFM Support to Serialized Lot Items
    l_st_ser_number_tbl          inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_parent_lot_tbl      inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_parent_lot_tbl      inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_number_tbl          inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_status_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_ser_status_tbl          inv_lot_trx_validation_pub.number_table;
    l_st_ser_grp_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_rs_ser_grp_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_is_serial_control          VARCHAR2 (1);
    l_st_ser_parent_sub_tbl      inv_lot_trx_validation_pub.parent_sub_table;
    l_st_ser_parent_loc_tbl      inv_lot_trx_validation_pub.parent_loc_table;
    --Added for OSFM Support to Serialized Lot Items
    l_st_status_id_tbl           inv_lot_trx_validation_pub.number_table;
    l_rs_status_id_tbl           inv_lot_trx_validation_pub.number_table;
    l_st_interface_id_tbl        inv_lot_trx_validation_pub.number_table;
    l_rs_interface_id_tbl        inv_lot_trx_validation_pub.number_table;
    l_rs_index                   NUMBER;
    l_count                      NUMBER;
    l_st_lot_attr_tbl            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_rs_lot_attr_tbl            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_lot_attr_tbl               inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_st_lot_exp_tbl             inv_lot_trx_validation_pub.date_table;
    l_rs_lot_exp_tbl             inv_lot_trx_validation_pub.date_table;
    l_acct_period_tbl            inv_lot_trx_validation_pub.number_table;
    l_wms_installed              VARCHAR2 (1);
    l_wms_enabled                VARCHAR2 (1);
    l_wsm_enabled                VARCHAR2 (1);
    l_st_dist_account_id         NUMBER;
    l_rs_dist_account_id         NUMBER;
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    l_is_serial_controlled       VARCHAR2 (1);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('inside validate_lot_split_trx', 'Validate_Lot_Split');
      print_debug ('calling populate_records', 'Validate_Lot_Split');
      print_debug ('breadcrumb 10', 'validate_lot_split_trx');
    END IF;

    l_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN
      populate_records (x_validation_status          => l_validation_status
                      , x_return_status              => x_return_status
                      , x_st_interface_id_tbl        => l_st_interface_id_tbl
                      , x_st_item_id_tbl             => l_st_item_id_tbl
                      , x_st_org_id_tbl              => l_st_org_id_tbl
                      , x_st_revision_tbl            => l_st_revision_tbl
                      , x_st_sub_code_tbl            => l_st_sub_code_tbl
                      , x_st_locator_id_tbl          => l_st_locator_id_tbl
                      , x_st_lot_num_tbl             => l_st_lot_number_tbl
                      , x_st_ser_num_tbl             => l_st_ser_number_tbl
                      , x_st_ser_parent_lot_tbl      => l_st_ser_parent_lot_tbl
                      , x_rs_ser_parent_lot_tbl      => l_rs_ser_parent_lot_tbl
                      , x_rs_ser_num_tbl             => l_rs_ser_number_tbl
                      , x_st_ser_status_tbl          => l_st_ser_status_tbl
                      , x_rs_ser_status_tbl          => l_rs_ser_status_tbl
                      , x_st_ser_grp_mark_id_tbl     => l_st_ser_grp_mark_id_tbl
                      , x_rs_ser_grp_mark_id_tbl     => l_rs_ser_grp_mark_id_tbl
                      , x_st_ser_parent_sub_tbl      => l_st_ser_parent_sub_tbl
                      , x_st_ser_parent_loc_tbl      => l_st_ser_parent_loc_tbl
                      , x_st_lpn_id_tbl              => l_st_lpn_id_tbl
                      , x_st_quantity_tbl            => l_st_quantity_tbl
                      , x_st_cost_group_tbl          => l_st_cost_group_id_tbl
                      , x_st_uom_tbl                 => l_st_uom_tbl
                      , x_st_status_id_tbl           => l_st_status_id_tbl
                      , x_rs_interface_id_tbl        => l_rs_interface_id_tbl
                      , x_rs_item_id_tbl             => l_rs_item_id_tbl
                      , x_rs_org_id_tbl              => l_rs_org_id_tbl
                      , x_rs_revision_tbl            => l_rs_revision_tbl
                      , x_rs_sub_code_tbl            => l_rs_sub_code_tbl
                      , x_rs_locator_id_tbl          => l_rs_locator_id_tbl
                      , x_rs_lot_num_tbl             => l_rs_lot_number_tbl
                      , x_rs_lpn_id_tbl              => l_rs_lpn_id_tbl
                      , x_rs_quantity_tbl            => l_rs_quantity_tbl
                      , x_rs_cost_group_tbl          => l_rs_cost_group_id_tbl
                      , x_rs_uom_tbl                 => l_rs_uom_tbl
                      , x_rs_status_id_tbl           => l_rs_status_id_tbl
                      , x_st_lot_exp_tbl             => l_st_lot_exp_tbl
                      , x_rs_lot_exp_tbl             => l_rs_lot_exp_tbl
                      , x_transaction_type_id        => l_transaction_type_id
                      , x_acct_period_tbl            => l_acct_period_tbl
                      , x_st_dist_account_id         => l_st_dist_account_id
                      , x_rs_dist_account_id         => l_rs_dist_account_id
                      , p_parent_id                  => p_parent_id
                       );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Populate_records raised error'
                     , 'Validate_lot_Split_Trx'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_RETRIEVE_RECORD');
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSIF (l_validation_status <> 'Y')
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('breadcrumb 20', 'validate_lot_split_trx');
    END IF;
    /* Removing the check...
    -- If wms is not installed and wsm is not enabled, we do not support lot transactions through the interface
    inv_lot_trx_validation_pub.get_org_info
                                      (x_wms_installed       => l_wms_installed
                                     , x_wsm_enabled         => l_wsm_enabled
                                     , x_wms_enabled         => l_wms_enabled
                                     , x_return_status       => x_return_status
                                     , x_msg_count           => x_msg_count
                                     , x_msg_data            => x_msg_data
                                     , p_organization_id     => l_st_org_id_tbl
                                                                           (1)
                                      );

    IF (l_debug = 1)
    THEN
      print_debug ('breadcrumb 30', 'validate_lot_split_trx');
    END IF;

    IF (x_return_status = fnd_api.g_ret_sts_error)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('breadcrumb 40', 'validate_lot_split_trx');
    END IF;

    IF ((NVL (l_wsm_enabled, 'N') = 'N')
        AND (NVL (l_wms_installed, 'N') = 'N')
       )
    THEN
      -- raise error
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 50', 'validate_lot_split_trx');
      END IF;

      print_debug ('Validation failed on wsm/wms install'
                 , 'Validate_lot_Split_Trx'
                  );
      fnd_message.set_name ('WMS', 'WMS_NOT_INSTALLED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    */
    IF (l_debug = 1)
    THEN
      print_debug ('calling Validate_Organization', 'Validate_lot_Split_Trx');
      print_debug ('breadcrumb 60', 'validate_lot_split_trx');
    END IF;

    BEGIN
      inv_lot_trx_validation_pub.validate_organization
                                 (x_return_status         => x_return_status
                                , x_msg_count             => x_msg_count
                                , x_msg_data              => x_msg_data
                                , x_validation_status     => l_validation_status
                                , p_organization_id       => l_st_org_id_tbl
                                                                           (1)
                                , p_period_tbl            => l_acct_period_tbl
                                 );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_RETRIEVE_PERIOD');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_lots', 'Validate_lot_Split_Trx');
      print_debug ('breadcrumb 70', 'validate_lot_split_trx');
    END IF;

    BEGIN
      inv_lot_trx_validation_pub.validate_lots
                             (x_return_status           => x_return_status
                            , x_msg_count               => x_msg_count
                            , x_msg_data                => x_msg_data
                            , x_validation_status       => l_validation_status
                            , p_transaction_type_id     => l_transaction_type_id
                            , p_st_org_id_tbl           => l_st_org_id_tbl
                            , p_st_item_id_tbl          => l_st_item_id_tbl
                            , p_st_lot_num_tbl          => l_st_lot_number_tbl
                            , p_rs_org_id_tbl           => l_rs_org_id_tbl
                            , p_rs_item_id_tbl          => l_rs_item_id_tbl
                            , p_rs_lot_num_tbl          => l_rs_lot_number_tbl
                            , p_st_lot_exp_tbl          => l_st_lot_exp_tbl
                            , p_rs_lot_exp_tbl          => l_rs_lot_exp_tbl
                            , p_st_revision_tbl         => l_st_revision_tbl
                            , p_rs_revision_tbl         => l_rs_revision_tbl
                            , p_st_quantity_tbl         => l_st_quantity_tbl
                            , p_rs_quantity_tbl         => l_rs_quantity_tbl
                             );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 80', 'validate_lot_split_trx');
        END IF;

        fnd_message.set_name ('WMS', 'WMS_VALIDATE_LOT_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 90', 'validate_lot_split_trx');
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_material_status'
                 , 'Validate_lot_Split_Trx'
                  );
    END IF;

    BEGIN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 100', 'validate_lot_split_trx');
      END IF;

      inv_lot_trx_validation_pub.validate_material_status
                              (x_return_status           => x_return_status
                             , x_msg_count               => x_msg_count
                             , x_msg_data                => x_msg_data
                             , x_validation_status       => l_validation_status
                             , p_transaction_type_id     => l_transaction_type_id
                             , p_organization_id         => l_st_org_id_tbl
                                                                           (1)
                             , p_inventory_item_id       => l_st_item_id_tbl
                                                                           (1)
                             , p_lot_number              => l_st_lot_number_tbl
                                                                           (1)
                             , p_subinventory_code       => l_st_sub_code_tbl
                                                                           (1)
                             , p_locator_id              => l_st_locator_id_tbl
                                                                           (1)
                             , p_status_id               => l_st_status_id_tbl
                                                                           (1)
                              );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 110', 'validate_lot_split_trx');
        END IF;

        fnd_message.set_name ('WMS', 'WMS_VALIDATE_STATUS_ERROR');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get (p_count     => x_msg_count
                                 , p_data      => x_msg_data
                                  );
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (l_debug = 1)
    THEN
      print_debug ('After calling validate_material_status'
                 , 'Validate_lot_Split_Trx'
                  );
      print_debug ('Message Count' || x_msg_count, 'Validate_lot_Split_Trx');
      print_debug ('Return Status' || x_return_status
                 , 'Validate_lot_Split_Trx'
                  );
    END IF;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 120', 'validate_lot_split_trx');
      END IF;

      fnd_message.set_name ('WMS', 'WMS_VALIDATE_STATUS_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
      RAISE fnd_api.g_exc_error;
    END IF;

    BEGIN
      SELECT transaction_action_id
        INTO l_transaction_action_id
        FROM mtl_transaction_types
       WHERE transaction_type_id = l_transaction_type_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 130', 'validate_lot_split_trx');
        END IF;

        fnd_message.set_name ('INV', 'INV_INT_TRX_TYPE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 140', 'validate_lot_split_trx');
        END IF;

        fnd_message.set_name ('INV', 'INV_INT_TRX_TYPE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_cost_groups', 'Validate_lot_Split_Trx');
    END IF;

    BEGIN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 150', 'validate_lot_split_trx');
      END IF;

      inv_lot_trx_validation_pub.validate_cost_groups
                          (x_rs_cost_group_tbl         => l_rs_cost_group_id_tbl
                         , x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_transaction_type_id       => l_transaction_type_id
                         , p_transaction_action_id     => l_transaction_action_id
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_st_item_id_tbl            => l_st_item_id_tbl
                         , p_st_sub_code_tbl           => l_st_sub_code_tbl
                         , p_st_loc_id_tbl             => l_st_locator_id_tbl
                         , p_st_lot_num_tbl            => l_st_lot_number_tbl
                         , p_st_cost_group_tbl         => l_st_cost_group_id_tbl
                         , p_st_revision_tbl           => l_st_revision_tbl
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_item_id_tbl            => l_rs_org_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_loc_id_tbl             => l_rs_locator_id_tbl
                         , p_rs_lot_num_tbl            => l_rs_lot_number_tbl
                         , p_rs_revision_tbl           => l_rs_revision_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                          );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 160', 'validate_lot_split_trx');
        END IF;

        fnd_message.set_name ('WMS', 'VALIDATE_COST_GROUP_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      IF (l_validation_status <> 'Y')
      THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        FOR i IN 1 .. l_rs_interface_id_tbl.COUNT
        LOOP
          UPDATE mtl_transactions_interface
             SET cost_group_id = l_rs_cost_group_id_tbl (i)
           WHERE transaction_interface_id = l_rs_interface_id_tbl (i);
        END LOOP;
      END IF;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_quantity', 'Validate_lot_Split_Trx');
    END IF;

    BEGIN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 170', 'validate_lot_split_trx');
      END IF;


      inv_lot_trx_validation_pub.validate_quantity
                          (x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_transaction_type_id       => l_transaction_type_id
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_st_item_id_tbl            => l_st_item_id_tbl
                         , p_st_sub_code_tbl           => l_st_sub_code_tbl
                         , p_st_loc_id_tbl             => l_st_locator_id_tbl
                         , p_st_lot_num_tbl            => l_st_lot_number_tbl
                         , p_st_cost_group_tbl         => l_st_cost_group_id_tbl
                         , p_st_revision_tbl           => l_st_revision_tbl
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_st_quantity_tbl           => l_st_quantity_tbl
                         , p_st_uom_tbl                => l_st_uom_tbl
                         , p_st_ser_number_tbl         => l_st_ser_number_tbl
                         , p_st_ser_parent_lot_tbl     => l_st_ser_parent_lot_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_item_id_tbl            => l_rs_item_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_loc_id_tbl             => l_rs_locator_id_tbl
                         , p_rs_lot_num_tbl            => l_rs_lot_number_tbl
                         , p_rs_cost_group_tbl         => l_rs_cost_group_id_tbl
                         , p_rs_revision_tbl           => l_rs_revision_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                         , p_rs_quantity_tbl           => l_rs_quantity_tbl
                         , p_rs_uom_tbl                => l_rs_uom_tbl
                         , p_rs_ser_number_tbl         => l_rs_ser_number_tbl
                         , p_rs_ser_parent_lot_tbl     => l_rs_ser_parent_lot_tbl
                          );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 180', 'validate_lot_split_trx');
          print_debug ('validate_quantity raised exception'
                     , 'Validate_lot_Split_Trx'
                      );
        END IF;

        fnd_message.set_name ('WMS', 'WMS_VALIDATE_QUANTITY_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      print_debug ('breadcrumb 190', 'validate_lot_split_trx');
      print_debug ('validate_quantity returned with Error'
                 , 'Validate_lot_Split_Trx'
                  );
      RAISE fnd_api.g_exc_error;
    END IF;

    print_debug ('calling get_lot_attr_record for parent record'
               , 'Validate_lot_Split_Trx'
                );
    /*Added LPN Validations */
    BEGIN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 191', 'validate_lot_split_trx');
      END IF;


      inv_lot_trx_validation_pub.validate_lpn_info
                          (x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_locator_id_tbl         => l_rs_locator_id_tbl
                         );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 195', 'validate_lot_split_trx');
          print_debug ('validate_lpn_info raised exception'
                     , 'Validate_lot_Split_Trx'
                      );
        END IF;

        fnd_message.set_name ('INV', 'INV_INT_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      print_debug ('breadcrumb 196', 'validate_lot_split_trx');
      print_debug ('validate_lpn_info returned with Error'
                 , 'Validate_lot_Split_Trx'
                  );
      RAISE fnd_api.g_exc_error;
    END IF;
    /*End of LPN Validations */

    BEGIN
      BEGIN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 200', 'validate_lot_split_trx');
          print_debug ('Determine the serial control code'
                     , 'Validate_Lot_Split'
                      );
        END IF;

        SELECT DECODE (serial_number_control_code, 2, 'Y', 5, 'Y', 'N')
          INTO l_is_serial_controlled
          FROM mtl_system_items
         WHERE inventory_item_id = l_st_item_id_tbl (1)
           AND organization_id = l_st_org_id_tbl (1);
      EXCEPTION
        WHEN OTHERS
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('breadcrumb 210', 'validate_lot_split_trx');
            print_debug ('Cannot fetch the serial control code for the item'
                       , 'Validate_lot_Split_Trx'
                        );
          END IF;

          l_validation_status := 'N';
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (l_debug = 1)
      THEN
        print_debug ('l_is_serial_controlled ' || l_is_serial_controlled
                   , 'Validate_Lot_Split'
                    );
      END IF;

      IF (l_is_serial_controlled = 'Y')
      THEN
        IF (   l_st_ser_number_tbl.COUNT = 0
            OR l_rs_ser_number_tbl.COUNT = 0
            OR l_st_ser_number_tbl.COUNT < l_rs_ser_number_tbl.COUNT
           )
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('breadcrumb 220', 'validate_lot_split_trx');
            print_debug
              ('Either the Serial records are empty or starting and result serial records do not match'
             , 'Validate_lot_Split_Trx'
              );
          END IF;

          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_SERIAL_INFO_MISSING');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          BEGIN
            IF (l_debug = 1)
            THEN
              print_debug ('Calling validate_serials'
                         , 'Validate_lot_Split_Trx'
                          );
            END IF;

            inv_lot_trx_validation_pub.validate_serials
                        (x_return_status              => x_return_status
                       , x_msg_count                  => x_msg_count
                       , x_msg_data                   => x_msg_data
                       , x_validation_status          => l_validation_status
                       , p_transaction_type_id        => l_transaction_type_id
                       , p_st_org_id_tbl              => l_st_org_id_tbl
                       , p_rs_org_id_tbl              => l_rs_org_id_tbl
                       , p_st_item_id_tbl             => l_st_item_id_tbl
                       , p_rs_item_id_tbl             => l_rs_item_id_tbl
                       , p_st_quantity_tbl            => l_st_quantity_tbl
                       --Needed for status control check
                       , p_st_sub_code_tbl            => l_st_sub_code_tbl
                       , p_st_locator_id_tbl          => l_st_locator_id_tbl
                       , p_st_ser_parent_lot_tbl      => l_st_ser_parent_lot_tbl
                       , p_rs_lot_num_tbl             => l_rs_lot_number_tbl
                       , p_st_ser_number_tbl          => l_st_ser_number_tbl
                       , p_rs_ser_number_tbl          => l_rs_ser_number_tbl
                       , p_st_ser_status_tbl          => l_st_ser_status_tbl
                       , p_st_ser_grp_mark_id_tbl     => l_st_ser_grp_mark_id_tbl
                       , p_st_ser_parent_sub_tbl      => l_st_ser_parent_sub_tbl
                       , p_st_ser_parent_loc_tbl      => l_st_ser_parent_loc_tbl
                      );
          EXCEPTION
            WHEN OTHERS
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('breadcrumb 230', 'validate_lot_split_trx');
                print_debug ('Validate_serials has raised exception'
                           , 'Validate_lot_Split_Trx'
                            );
              END IF;

              l_validation_status := 'N';
              fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;

          IF (   x_return_status <> fnd_api.g_ret_sts_success
              OR l_validation_status <> 'Y'
             )
          THEN
            print_debug ('breadcrumb 240', 'validate_lot_split_trx');
            print_debug ('Validate_serials returned with error code'
                       , 'Validate_lot_Split_Trx'
                        );
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 250', 'validate_lot_split_trx');
          print_debug ('Validate_serials returned with success'
                     , 'Validate_lot_Split_Trx'
                      );
        END IF;
      END IF;                                       --is lot serial controlled
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 260', 'validate_lot_split_trx');
          print_debug ('Error while validating serials'
                     , 'Validate_lot_Split_Trx'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    /*Bug:5354721. The following procedure populates the column name, type and
      length for all the Lot Attributes. */
    get_lot_attr_table;

    BEGIN
      get_lot_attr_record
                     (x_lot_attr_tbl                 => l_st_lot_attr_tbl
                    , p_transaction_interface_id     => l_st_interface_id_tbl
                                                                           (1)
                    , p_lot_number                   => l_st_lot_number_tbl
                                                                           (1)
                    , p_starting_lot_number          => l_st_lot_number_tbl
                                                                           (1)
                    , p_organization_id              => l_st_org_id_tbl (1)
                    , p_inventory_item_id            => l_st_item_id_tbl (1)
                     );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('WMS', 'WMS_GET_LOT_ATTR_ERROR');
        fnd_msg_pub.ADD;
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    FOR i IN 1 .. l_rs_interface_id_tbl.COUNT
    LOOP
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 270', 'validate_lot_split_trx');
        print_debug ('calling get_lot_attr_record for resultant records'
                   , 'Validate_lot_Split_Trx'
                    );
      END IF;

      BEGIN
        get_lot_attr_record
                     (x_lot_attr_tbl                 => l_rs_lot_attr_tbl
                    , p_transaction_interface_id     => l_rs_interface_id_tbl
                                                                           (i)
                    , p_lot_number                   => l_rs_lot_number_tbl
                                                                           (i)
                    , p_starting_lot_number          => l_st_lot_number_tbl
                                                                           (1)
                    , p_organization_id              => l_rs_org_id_tbl (i)
                    , p_inventory_item_id            => l_rs_item_id_tbl (i)
                     );
      EXCEPTION
        WHEN OTHERS
        THEN
          fnd_message.set_name ('WMS', 'WMS_GET_LOT_ATTR_ERROR');
          fnd_msg_pub.ADD;
          l_validation_status := 'N';
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 280', 'validate_lot_split_trx');
        print_debug ('calling validate_attributes', 'Validate_lot_split_trx');
      END IF;

      BEGIN
        inv_lot_trx_validation_pub.validate_attributes
                              (x_return_status           => x_return_status
                             , x_msg_count               => x_msg_count
                             , x_msg_data                => x_msg_data
                             , x_validation_status       => l_validation_status
                             , x_lot_attr_tbl            => l_lot_attr_tbl
                             , p_lot_number              => l_st_lot_number_tbl
                                                                           (1)
                             , p_organization_id         => l_rs_org_id_tbl
                                                                           (i)
                             , p_inventory_item_id       => l_rs_item_id_tbl
                                                                           (i)
                             , p_parent_lot_attr_tbl     => l_st_lot_attr_tbl
                             , p_result_lot_attr_tbl     => l_rs_lot_attr_tbl
                             , p_transaction_type_id     => l_transaction_type_id
                              );
      EXCEPTION
        WHEN OTHERS
        THEN
          fnd_message.set_name ('WMS', 'WMS_VALIDATE_ATTR_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (   x_return_status <> fnd_api.g_ret_sts_success
          OR l_validation_status <> 'Y'
         )
      THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        IF (l_lot_attr_tbl.COUNT > 0)
        THEN
          -- this means user does not provide the lot attribute for the result lot.
          -- we need to update the mtl_transation_lots_interface with the parent
          -- lot attributes if it exists or use default lot attributes
          IF (l_debug = 1)
          THEN
            print_debug ('calling update_lot_attr_record'
                       , 'validate_lot_split_trx'
                        );
          END IF;

          update_lot_attr_record
                      (p_lot_attr_tbl                 => l_lot_attr_tbl
                     , p_transaction_interface_id     => l_rs_interface_id_tbl
                                                                           (i)
                     , p_lot_number                   => l_rs_lot_number_tbl
                                                                           (i)
                     , p_organization_id              => l_rs_org_id_tbl (i)
                     , p_inventory_item_id            => l_rs_item_id_tbl (i)
                      );
        END IF;
      END IF;
    END LOOP;

    -- Call to compute the correct expiration date
    BEGIN
      inv_lot_trx_validation_pub.compute_lot_expiration
                             (x_return_status           => x_return_status
                            , x_msg_count               => x_msg_count
                            , x_msg_data                => x_msg_data
                            , p_parent_id               => p_parent_id
                            , p_transaction_type_id     => l_transaction_type_id
                            , p_item_id                 => l_st_item_id_tbl
                                                                           (1)
                            , p_organization_id         => l_st_org_id_tbl (1)
                            , p_st_lot_num              => l_st_lot_number_tbl
                                                                           (1)
                            , p_rs_lot_num_tbl          => l_rs_lot_number_tbl
                            , p_rs_lot_exp_tbl          => l_rs_lot_exp_tbl
                             );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_LOT_EXP_COMPUTE_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      fnd_message.set_name ('INV', 'INV_LOT_EXP_COMPUTE_ERROR');
      fnd_msg_pub.ADD;
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    -- if we reach here, it means all validations are successfull
    x_return_status := fnd_api.g_ret_sts_success;
    x_validation_status := 'Y';
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_validation_status := l_validation_status;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_status := l_validation_status;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_status := 'E';

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Lot_Split_Trx');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_lot_split_trx;

  PROCEDURE validate_lot_merge_trx (
    x_return_status       OUT NOCOPY      VARCHAR2
  , x_msg_count           OUT NOCOPY      NUMBER
  , x_msg_data            OUT NOCOPY      VARCHAR2
  , x_validation_status   OUT NOCOPY      VARCHAR2
  , p_parent_id           IN              NUMBER
  )
  IS
    l_return_status              VARCHAR2 (1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2 (255);
    l_validation_status          VARCHAR2 (1);
    l_transaction_type_id        NUMBER;
    --  l_acct_period_id NUMBER;
    l_transaction_interface_id   NUMBER;
    l_transaction_action_id      NUMBER;
    l_st_item_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_st_org_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_st_revision_tbl            inv_lot_trx_validation_pub.revision_table;
    l_st_quantity_tbl            inv_lot_trx_validation_pub.number_table;
    l_st_uom_tbl                 inv_lot_trx_validation_pub.uom_table;
    l_st_locator_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_st_sub_code_tbl            inv_lot_trx_validation_pub.sub_code_table;
    l_st_cost_group_id_tbl       inv_lot_trx_validation_pub.number_table;
    l_st_lpn_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_item_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_rs_org_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_revision_tbl            inv_lot_trx_validation_pub.revision_table;
    l_rs_quantity_tbl            inv_lot_trx_validation_pub.number_table;
    l_rs_uom_tbl                 inv_lot_trx_validation_pub.uom_table;
    l_rs_locator_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_sub_code_tbl            inv_lot_trx_validation_pub.sub_code_table;
    l_rs_lpn_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_cost_group_id_tbl       inv_lot_trx_validation_pub.number_table;
    l_st_lot_number_tbl          inv_lot_trx_validation_pub.lot_number_table;
    --Added for OSFM Support to Serialized Lot Items
    l_st_ser_number_tbl          inv_lot_trx_validation_pub.serial_number_table;
    l_rs_ser_parent_lot_tbl      inv_lot_trx_validation_pub.parent_lot_table;
    l_st_ser_parent_lot_tbl      inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_number_tbl          inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_status_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_ser_status_tbl          inv_lot_trx_validation_pub.number_table;
    l_st_ser_grp_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_rs_ser_grp_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_is_serial_controlled       VARCHAR2 (1);
    l_st_ser_parent_sub_tbl      inv_lot_trx_validation_pub.parent_sub_table;
    l_st_ser_parent_loc_tbl      inv_lot_trx_validation_pub.parent_loc_table;
    --Added for OSFM Support to Serialized Lot Items
    l_rs_lot_number_tbl          inv_lot_trx_validation_pub.lot_number_table;
    l_st_status_id_tbl           inv_lot_trx_validation_pub.number_table;
    l_rs_status_id_tbl           inv_lot_trx_validation_pub.number_table;
    l_st_interface_id_tbl        inv_lot_trx_validation_pub.number_table;
    l_rs_interface_id_tbl        inv_lot_trx_validation_pub.number_table;
    l_st_lot_exp_tbl             inv_lot_trx_validation_pub.date_table;
    l_rs_lot_exp_tbl             inv_lot_trx_validation_pub.date_table;
    l_rs_index                   NUMBER;
    l_count                      NUMBER;
    l_st_lot_attr_tbl            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_rs_lot_attr_tbl            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_lot_attr_tbl               inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_represenatative_lot        mtl_transaction_lots_interface.lot_number%TYPE
                                                                      := NULL;
    l_max_lot_qty                NUMBER                                  := 0;
    l_lot_number                 mtl_transaction_lots_interface.lot_number%TYPE
                                                                      := NULL;
    l_acct_period_tbl            inv_lot_trx_validation_pub.number_table;
    l_wms_installed              VARCHAR2 (1);
    l_wms_enabled                VARCHAR2 (1);
    l_wsm_enabled                VARCHAR2 (1);
    l_st_dist_account_id         NUMBER;
    l_rs_dist_account_id         NUMBER;
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1)
    THEN
      print_debug ('calling populate records', 'validate_lot_merge_trx');
    END IF;

    BEGIN
      populate_records (x_validation_status          => l_validation_status
                      , x_return_status              => x_return_status
                      , x_st_interface_id_tbl        => l_st_interface_id_tbl
                      , x_st_item_id_tbl             => l_st_item_id_tbl
                      , x_st_org_id_tbl              => l_st_org_id_tbl
                      , x_st_revision_tbl            => l_st_revision_tbl
                      , x_st_sub_code_tbl            => l_st_sub_code_tbl
                      , x_st_locator_id_tbl          => l_st_locator_id_tbl
                      , x_st_lot_num_tbl             => l_st_lot_number_tbl
                      , x_st_ser_num_tbl             => l_st_ser_number_tbl
                      , x_st_ser_parent_lot_tbl      => l_st_ser_parent_lot_tbl
                      , x_rs_ser_parent_lot_tbl      => l_rs_ser_parent_lot_tbl
                      , x_rs_ser_num_tbl             => l_rs_ser_number_tbl
                      , x_st_ser_status_tbl          => l_st_ser_status_tbl
                      , x_rs_ser_status_tbl          => l_rs_ser_status_tbl
                      , x_st_ser_grp_mark_id_tbl     => l_st_ser_grp_mark_id_tbl
                      , x_rs_ser_grp_mark_id_tbl     => l_rs_ser_grp_mark_id_tbl
                      , x_st_ser_parent_sub_tbl      => l_st_ser_parent_sub_tbl
                      , x_st_ser_parent_loc_tbl      => l_st_ser_parent_loc_tbl
                      , x_st_lpn_id_tbl              => l_st_lpn_id_tbl
                      , x_st_quantity_tbl            => l_st_quantity_tbl
                      , x_st_cost_group_tbl          => l_st_cost_group_id_tbl
                      , x_st_uom_tbl                 => l_st_uom_tbl
                      , x_st_status_id_tbl           => l_st_status_id_tbl
                      , x_rs_interface_id_tbl        => l_rs_interface_id_tbl
                      , x_rs_item_id_tbl             => l_rs_item_id_tbl
                      , x_rs_org_id_tbl              => l_rs_org_id_tbl
                      , x_rs_revision_tbl            => l_rs_revision_tbl
                      , x_rs_sub_code_tbl            => l_rs_sub_code_tbl
                      , x_rs_locator_id_tbl          => l_rs_locator_id_tbl
                      , x_rs_lot_num_tbl             => l_rs_lot_number_tbl
                      , x_rs_lpn_id_tbl              => l_rs_lpn_id_tbl
                      , x_rs_quantity_tbl            => l_rs_quantity_tbl
                      , x_rs_cost_group_tbl          => l_rs_cost_group_id_tbl
                      , x_rs_uom_tbl                 => l_rs_uom_tbl
                      , x_rs_status_id_tbl           => l_rs_status_id_tbl
                      , x_st_lot_exp_tbl             => l_st_lot_exp_tbl
                      , x_rs_lot_exp_tbl             => l_rs_lot_exp_tbl
                      , x_transaction_type_id        => l_transaction_type_id
                      , x_acct_period_tbl            => l_acct_period_tbl
                      , x_st_dist_account_id         => l_st_dist_account_id
                      , x_rs_dist_account_id         => l_rs_dist_account_id
                      , p_parent_id                  => p_parent_id
                       );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Populate_records raised exception'
                     , 'Validate_lot_merge_Trx'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_RETRIEVE_RECORD');
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSIF (l_validation_status <> 'Y')
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    /*Removing the check...
    -- If wms is not installed and wsm is not enabled, we do not support lot transactions through the interface
    inv_lot_trx_validation_pub.get_org_info
                                      (x_wms_installed       => l_wms_installed
                                     , x_wsm_enabled         => l_wsm_enabled
                                     , x_wms_enabled         => l_wms_enabled
                                     , x_return_status       => x_return_status
                                     , x_msg_count           => x_msg_count
                                     , x_msg_data            => x_msg_data
                                     , p_organization_id     => l_st_org_id_tbl
                                                                           (1)
                                      );

    IF (x_return_status = fnd_api.g_ret_sts_error)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF ((NVL (l_wsm_enabled, 'N') = 'N')
        AND (NVL (l_wms_installed, 'N') = 'N')
       )
    THEN
      -- raise error
      print_debug ('Validation failed on wsm/wms install'
                 , 'Validate_lot_Split_Trx'
                  );
      fnd_message.set_name ('WMS', 'WMS_NOT_INSTALLED');
      fnd_msg_pub.ADD;
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;
    */
    IF (l_debug = 1)
    THEN
      print_debug ('calling Validate_Organization', 'Validate_lot_Split_Trx');
    END IF;

    BEGIN
      inv_lot_trx_validation_pub.validate_organization
                                 (x_return_status         => x_return_status
                                , x_msg_count             => x_msg_count
                                , x_msg_data              => x_msg_data
                                , x_validation_status     => l_validation_status
                                , p_organization_id       => l_st_org_id_tbl
                                                                           (1)
                                , p_period_tbl            => l_acct_period_tbl
                                 );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_RETRIEVE_PERIOD');
        fnd_msg_pub.ADD;
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_lots', 'validate_lot_merge_trx');
    END IF;

    inv_lot_trx_validation_pub.validate_lots
                              (x_return_status           => x_return_status
                             , x_msg_count               => x_msg_count
                             , x_msg_data                => x_msg_data
                             , x_validation_status       => l_validation_status
                             , p_transaction_type_id     => l_transaction_type_id
                             , p_st_org_id_tbl           => l_st_org_id_tbl
                             , p_st_item_id_tbl          => l_st_item_id_tbl
                             , p_st_lot_num_tbl          => l_st_lot_number_tbl
                             , p_rs_org_id_tbl           => l_rs_org_id_tbl
                             , p_rs_item_id_tbl          => l_rs_item_id_tbl
                             , p_rs_lot_num_tbl          => l_rs_lot_number_tbl
                             , p_st_lot_exp_tbl          => l_st_lot_exp_tbl
                             , p_rs_lot_exp_tbl          => l_rs_lot_exp_tbl
                             , p_st_revision_tbl         => l_st_revision_tbl
                             , p_rs_revision_tbl         => l_rs_revision_tbl
                             , p_st_quantity_tbl         => l_st_quantity_tbl
                             , p_rs_quantity_tbl         => l_rs_quantity_tbl
                              );

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_material_status'
                 , 'validate_lot_merge_trx'
                  );
    END IF;

    FOR i IN 1 .. l_st_lot_number_tbl.COUNT
    LOOP
      inv_lot_trx_validation_pub.validate_material_status
                             (x_return_status           => x_return_status
                            , x_msg_count               => x_msg_count
                            , x_msg_data                => x_msg_data
                            , x_validation_status       => l_validation_status
                            , p_transaction_type_id     => l_transaction_type_id
                            , p_organization_id         => l_st_org_id_tbl (1)
                            , p_inventory_item_id       => l_st_item_id_tbl
                                                                           (1)
                            , p_lot_number              => l_st_lot_number_tbl
                                                                           (i)
                            , p_subinventory_code       => l_st_sub_code_tbl
                                                                           (i)
                            , p_locator_id              => l_st_locator_id_tbl
                                                                           (i)
                            , p_status_id               => l_st_status_id_tbl
                                                                           (i)
                             );

      IF (l_debug = 1)
      THEN
        print_debug ('After calling validate_material_status'
                   , 'Validate_lot_Merge_Trx'
                    );
        print_debug ('Lot Number is' || l_st_lot_number_tbl (i)
                   , 'Validate_lot_Merge_Trx'
                    );
        print_debug ('Status ID is' || l_st_status_id_tbl (i)
                   , 'Validate_lot_Merge_Trx'
                    );
        print_debug ('Message Count' || x_msg_count, 'Validate_lot_Merge_Trx');
        print_debug ('Return Status' || x_return_status
                   , 'Validate_lot_merge_Trx'
                    );
      END IF;

      IF (   x_return_status <> fnd_api.g_ret_sts_success
          OR l_validation_status <> 'Y'
         )
      THEN
        fnd_message.set_name ('WMS', 'WMS_VALIDATE_STATUS_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    BEGIN
      SELECT transaction_action_id
        INTO l_transaction_action_id
        FROM mtl_transaction_types
       WHERE transaction_type_id = l_transaction_type_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        fnd_message.set_name ('INV', 'INV_INT_TRX_TYPE');
        fnd_msg_pub.ADD;
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_INT_TRX_TYPE');
        fnd_msg_pub.ADD;
        l_validation_status := 'E';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_cost_groups', 'validate_lot_merge_trx');
    END IF;

    inv_lot_trx_validation_pub.validate_cost_groups
                          (x_rs_cost_group_tbl         => l_rs_cost_group_id_tbl
                         , x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_transaction_type_id       => l_transaction_type_id
                         , p_transaction_action_id     => l_transaction_action_id
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_st_item_id_tbl            => l_st_item_id_tbl
                         , p_st_sub_code_tbl           => l_st_sub_code_tbl
                         , p_st_loc_id_tbl             => l_st_locator_id_tbl
                         , p_st_lot_num_tbl            => l_st_lot_number_tbl
                         , p_st_cost_group_tbl         => l_st_cost_group_id_tbl
                         , p_st_revision_tbl           => l_st_revision_tbl
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_item_id_tbl            => l_rs_org_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_loc_id_tbl             => l_rs_locator_id_tbl
                         , p_rs_lot_num_tbl            => l_rs_lot_number_tbl
                         , p_rs_revision_tbl           => l_rs_revision_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                          );

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSE
      IF (l_validation_status <> 'Y')
      THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        FOR i IN 1 .. l_rs_interface_id_tbl.COUNT
        LOOP
          UPDATE mtl_transactions_interface
             SET cost_group_id = l_rs_cost_group_id_tbl (i)
           WHERE transaction_interface_id = l_rs_interface_id_tbl (i);
        END LOOP;
      END IF;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_quantity', 'validate_lot_merge_trx');
    END IF;

    inv_lot_trx_validation_pub.validate_quantity
                          (x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_transaction_type_id       => l_transaction_type_id
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_st_item_id_tbl            => l_st_item_id_tbl
                         , p_st_sub_code_tbl           => l_st_sub_code_tbl
                         , p_st_loc_id_tbl             => l_st_locator_id_tbl
                         , p_st_lot_num_tbl            => l_st_lot_number_tbl
                         , p_st_cost_group_tbl         => l_st_cost_group_id_tbl
                         , p_st_revision_tbl           => l_st_revision_tbl
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_st_quantity_tbl           => l_st_quantity_tbl
                         , p_st_uom_tbl                => l_st_uom_tbl
                         , p_st_ser_parent_lot_tbl     => l_st_ser_parent_lot_tbl
                         , p_st_ser_number_tbl         => l_st_ser_number_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_item_id_tbl            => l_rs_item_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_loc_id_tbl             => l_rs_locator_id_tbl
                         , p_rs_lot_num_tbl            => l_rs_lot_number_tbl
                         , p_rs_cost_group_tbl         => l_rs_cost_group_id_tbl
                         , p_rs_revision_tbl           => l_rs_revision_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                         , p_rs_quantity_tbl           => l_rs_quantity_tbl
                         , p_rs_uom_tbl                => l_rs_uom_tbl
                         , p_rs_ser_number_tbl         => l_rs_ser_number_tbl
                         , p_rs_ser_parent_lot_tbl     => l_rs_ser_parent_lot_tbl
                          );

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('validate_quantity returned with error'
                   , 'validate_lot_merge_trx'
                    );
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    /*Call LPN Validations*/
    BEGIN
        IF (l_debug = 1)
        THEN
          print_debug('calling validate_lpn_info' , 'validate_lot_merge_trx');
        END IF;



        inv_lot_trx_validation_pub.validate_lpn_info
                            (x_return_status             => x_return_status
                           , x_msg_count                 => x_msg_count
                           , x_msg_data                  => x_msg_data
                           , x_validation_status         => l_validation_status
                           , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                           , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                           , p_st_org_id_tbl             => l_st_org_id_tbl
                           , p_rs_org_id_tbl             => l_rs_org_id_tbl
                           , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                           , p_rs_locator_id_tbl         => l_rs_locator_id_tbl
                           );
        IF(l_debug = 1) THEN
          print_debug('after validate_lpn_info ' , 'validate_lot_merge_trx');
        END IF;

      EXCEPTION
        WHEN OTHERS
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('validate_lpn_info raised exception'
                       , 'Validate_lot_merge_Trx'
                        );
          END IF;

          fnd_message.set_name ('INV', 'INV_INT_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (   x_return_status <> fnd_api.g_ret_sts_success
          OR l_validation_status <> 'Y'
         )
      THEN

        print_debug ('validate_lpn_info returned with Error'
                   , 'Validate_lot_merge_Trx'
                    );
        RAISE fnd_api.g_exc_error;
      END IF;

    /*Call LPN Validations*/


    BEGIN
      BEGIN
        IF (l_debug = 1)
        THEN
          print_debug ('Trying to get the serial control code'
                     , 'validate_lot_merge_trx'
                      );
        END IF;

        SELECT DECODE (serial_number_control_code, 2, 'Y', 5, 'Y', 'N')
          INTO l_is_serial_controlled
          FROM mtl_system_items
         WHERE inventory_item_id = l_st_item_id_tbl (1)
           AND organization_id = l_st_org_id_tbl (1);
      EXCEPTION
        WHEN OTHERS
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('Cannot fetch the serial control code for the item'
                       , 'Validate_lot_Merge_Trx'
                        );
          END IF;

          l_validation_status := 'E';
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (l_is_serial_controlled = 'Y')
      THEN
        IF (   l_st_ser_number_tbl.COUNT = 0
            OR l_rs_ser_number_tbl.COUNT = 0
            OR l_st_ser_number_tbl.COUNT <> l_rs_ser_number_tbl.COUNT
           )
        THEN
          IF (l_debug = 1)
          THEN
            print_debug
              ('Either the serial record is empty or the starting and resulting records do not match'
             , 'Validate_lot_Merge_Trx'
              );
          END IF;

          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_SERIAL_INFO_MISSING');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          BEGIN
            IF (l_debug = 1)
            THEN
              print_debug ('calling validate_serials'
                         , 'Validate_lot_Merge_Trx'
                          );
            END IF;

            inv_lot_trx_validation_pub.validate_serials
                        (x_return_status              => x_return_status
                       , x_msg_count                  => x_msg_count
                       , x_msg_data                   => x_msg_data
                       , x_validation_status          => l_validation_status
                       , p_transaction_type_id        => l_transaction_type_id
                       , p_st_org_id_tbl              => l_st_org_id_tbl
                       , p_rs_org_id_tbl              => l_rs_org_id_tbl
                       , p_st_item_id_tbl             => l_st_item_id_tbl
                       , p_rs_item_id_tbl             => l_rs_item_id_tbl
                       , p_st_quantity_tbl            => l_st_quantity_tbl
                       --Needed for status control check
                       , p_st_sub_code_tbl            => l_st_sub_code_tbl
                       , p_st_locator_id_tbl          => l_st_locator_id_tbl
                       , p_st_ser_parent_lot_tbl      => l_st_ser_parent_lot_tbl
                       , p_rs_lot_num_tbl             => l_rs_lot_number_tbl
                       , p_st_ser_number_tbl          => l_st_ser_number_tbl
                       , p_rs_ser_number_tbl          => l_rs_ser_number_tbl
                       , p_st_ser_status_tbl          => l_st_ser_status_tbl
                       , p_st_ser_grp_mark_id_tbl     => l_st_ser_grp_mark_id_tbl
                       , p_st_ser_parent_sub_tbl      => l_st_ser_parent_sub_tbl
                       , p_st_ser_parent_loc_tbl      => l_st_ser_parent_loc_tbl
                      );

          EXCEPTION
            WHEN OTHERS
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('Validate_serials has raised exception'
                           , 'Validate_lot_Merge_Trx'
                            );
              END IF;

              l_validation_status := 'N';
              fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;

          IF (   x_return_status <> fnd_api.g_ret_sts_success
              OR l_validation_status <> 'Y'
             )
          THEN
            IF (l_debug = 1)
            THEN
              print_debug ('Validate_serials returned with error code'
                         , 'Validate_lot_Merge_Trx'
                          );
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;                                       --is lot serial controlled
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Error while validating serial info'
                     , 'Validate_lot_Merge_Trx'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    /***** Check for the representative Lot  and if it is populated
    ---populate the attributes based on the lot else send the default lot
    --  number ****/
    SELECT representative_lot_number
      INTO l_represenatative_lot
      FROM mtl_transactions_interface
     WHERE transaction_interface_id = l_st_interface_id_tbl (1);

    IF l_represenatative_lot IS NULL
    THEN
      FOR i IN 1 .. l_st_interface_id_tbl.COUNT
      LOOP
        IF l_st_quantity_tbl (i) > l_max_lot_qty
        THEN
          l_lot_number := l_st_lot_number_tbl (i);
          l_max_lot_qty := l_st_quantity_tbl (i);
          l_transaction_interface_id := l_st_interface_id_tbl (i);
        END IF;
      END LOOP;
    ELSE
      l_lot_number := l_represenatative_lot;
      l_transaction_interface_id := l_st_interface_id_tbl (1);
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('l_lot_number is ' || l_lot_number
                 , 'Validate_lot_merge_trx'
                  );
      print_debug ('calling get_lot_attr_record for starting lot'
                 , 'Validate_lot_merge_trx'
                  );
    END IF;

    /*Bug:5354721. The following procedure populates the column name, type and
      length for all the Lot Attributes. */
    get_lot_attr_table;

    get_lot_attr_record
                    (x_lot_attr_tbl                 => l_st_lot_attr_tbl
                   , p_transaction_interface_id     => l_transaction_interface_id
                   , p_lot_number                   => l_lot_number
                   , p_starting_lot_number          => l_lot_number
                   , p_organization_id              => l_st_org_id_tbl (1)
                   , p_inventory_item_id            => l_st_item_id_tbl (1)
                    );

    IF (l_debug = 1)
    THEN
      print_debug ('calling get_lot_attr_record for resulting lot'
                 , 'Validate_lot_Merge_Trx'
                  );
    END IF;

    get_lot_attr_record
                      (x_lot_attr_tbl                 => l_rs_lot_attr_tbl
                     , p_transaction_interface_id     => l_rs_interface_id_tbl
                                                                           (1)
                     , p_lot_number                   => l_rs_lot_number_tbl
                                                                           (1)
                     , p_starting_lot_number          => l_lot_number
                     , p_organization_id              => l_rs_org_id_tbl (1)
                     , p_inventory_item_id            => l_rs_item_id_tbl (1)
                      );

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_attributes', 'Validate_lot_merge_trx');
    END IF;

    inv_lot_trx_validation_pub.validate_attributes
                               (x_return_status           => x_return_status
                              , x_msg_count               => x_msg_count
                              , x_msg_data                => x_msg_data
                              , x_validation_status       => l_validation_status
                              , x_lot_attr_tbl            => l_lot_attr_tbl
                              , p_lot_number              => l_rs_lot_number_tbl
                                                                           (1)
                              , p_organization_id         => l_rs_org_id_tbl
                                                                           (1)
                              , p_inventory_item_id       => l_rs_item_id_tbl
                                                                           (1)
                              , p_parent_lot_attr_tbl     => l_st_lot_attr_tbl
                              , p_result_lot_attr_tbl     => l_rs_lot_attr_tbl
                              , p_transaction_type_id     => l_transaction_type_id
                               );

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      -- we have to update the attributes with either the max
      -- -lot or with the lot the User has specified as the
      --  resesenatattive lot
      IF (l_debug = 1)
      THEN
        print_debug ('callign update_lot_attr_record', 'validate_lot_merge');
      END IF;

      IF (l_lot_attr_tbl.COUNT > 0)
      THEN
        update_lot_attr_record
                     (p_lot_attr_tbl                 => l_lot_attr_tbl
                    , p_transaction_interface_id     => l_rs_interface_id_tbl
                                                                           (1)
                    , p_lot_number                   => l_rs_lot_number_tbl
                                                                           (1)
                    , p_organization_id              => l_rs_org_id_tbl (1)
                    , p_inventory_item_id            => l_rs_item_id_tbl (1)
                     );
      END IF;
    END IF;

    -- Call to compute the correct expiration dates
    BEGIN
      l_st_lot_number_tbl (1) := l_lot_number;
      -- Send in just one lot number
      inv_lot_trx_validation_pub.compute_lot_expiration
                             (x_return_status           => x_return_status
                            , x_msg_count               => x_msg_count
                            , x_msg_data                => x_msg_data
                            , p_parent_id               => p_parent_id
                            , p_transaction_type_id     => l_transaction_type_id
                            , p_item_id                 => l_st_item_id_tbl
                                                                           (1)
                            , p_organization_id         => l_st_org_id_tbl (1)
                            , p_st_lot_num              => l_st_lot_number_tbl
                                                                           (1)
                            , p_rs_lot_num_tbl          => l_rs_lot_number_tbl
                            , p_rs_lot_exp_tbl          => l_rs_lot_exp_tbl
                             );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_LOT_EXP_COMPUTE_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      fnd_message.set_name ('INV', 'INV_LOT_EXP_COMPUTE_ERROR');
      fnd_msg_pub.ADD;
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    -- if we reach here, it means all validations are successfull
    x_return_status := fnd_api.g_ret_sts_success;
    x_validation_status := 'Y';
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_validation_status := l_validation_status;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_status := l_validation_status;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_status := 'E';

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'validate_lot_merge_trx');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_lot_merge_trx;

  PROCEDURE validate_lot_translate_trx (
    x_return_status       OUT NOCOPY      VARCHAR2
  , x_msg_count           OUT NOCOPY      NUMBER
  , x_msg_data            OUT NOCOPY      VARCHAR2
  , x_validation_status   OUT NOCOPY      VARCHAR2
  , p_parent_id           IN              NUMBER
  )
  IS
    l_return_status              VARCHAR2 (1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2 (255);
    l_validation_status          VARCHAR2 (1);
    l_transaction_type_id        NUMBER;
    --    l_acct_period_id NUMBER;
    l_transaction_interface_id   NUMBER;
    l_transaction_action_id      NUMBER;
    l_st_item_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_st_org_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_st_revision_tbl            inv_lot_trx_validation_pub.revision_table;
    l_st_quantity_tbl            inv_lot_trx_validation_pub.number_table;
    l_st_uom_tbl                 inv_lot_trx_validation_pub.uom_table;
    l_st_locator_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_st_sub_code_tbl            inv_lot_trx_validation_pub.sub_code_table;
    l_st_cost_group_id_tbl       inv_lot_trx_validation_pub.number_table;
    l_st_lpn_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_item_id_tbl             inv_lot_trx_validation_pub.number_table;
    l_rs_org_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_revision_tbl            inv_lot_trx_validation_pub.revision_table;
    l_rs_quantity_tbl            inv_lot_trx_validation_pub.number_table;
    l_rs_uom_tbl                 inv_lot_trx_validation_pub.uom_table;
    l_rs_locator_id_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_sub_code_tbl            inv_lot_trx_validation_pub.sub_code_table;
    l_rs_lpn_id_tbl              inv_lot_trx_validation_pub.number_table;
    l_rs_cost_group_id_tbl       inv_lot_trx_validation_pub.number_table;
    l_st_lot_number_tbl          inv_lot_trx_validation_pub.lot_number_table;
    l_rs_lot_number_tbl          inv_lot_trx_validation_pub.lot_number_table;
    --Added for OSFM Support to Serialized Lot Items
    l_is_serial_controlled       VARCHAR2 (1);
    l_st_ser_number_tbl          inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_parent_lot_tbl      inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_parent_lot_tbl      inv_lot_trx_validation_pub.parent_lot_table;
    l_rs_ser_number_tbl          inv_lot_trx_validation_pub.serial_number_table;
    l_st_ser_status_tbl          inv_lot_trx_validation_pub.number_table;
    l_rs_ser_status_tbl          inv_lot_trx_validation_pub.number_table;
    l_st_ser_grp_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_rs_ser_grp_mark_id_tbl     inv_lot_trx_validation_pub.number_table;
    l_st_ser_parent_sub_tbl      inv_lot_trx_validation_pub.parent_sub_table;
    l_st_ser_parent_loc_tbl      inv_lot_trx_validation_pub.parent_loc_table;
    --Added for OSFM Support to Serialized Lot Items
    l_st_status_id_tbl           inv_lot_trx_validation_pub.number_table;
    l_rs_status_id_tbl           inv_lot_trx_validation_pub.number_table;
    l_st_interface_id_tbl        inv_lot_trx_validation_pub.number_table;
    l_rs_interface_id_tbl        inv_lot_trx_validation_pub.number_table;
    l_rs_index                   NUMBER;
    l_count                      NUMBER;
    l_st_lot_attr_tbl            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_rs_lot_attr_tbl            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_st_lot_exp_tbl             inv_lot_trx_validation_pub.date_table;
    l_rs_lot_exp_tbl             inv_lot_trx_validation_pub.date_table;
    l_lot_attr_tbl               inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_distribution_account_id    wsm_parameters.transaction_account_id%TYPE
                                                                      := NULL;
    l_acct_period_tbl            inv_lot_trx_validation_pub.number_table;
    l_wms_installed              VARCHAR2 (1);
    l_wms_enabled                VARCHAR2 (1);
    l_wsm_enabled                VARCHAR2 (1);
    l_st_dist_account_id         NUMBER;
    l_rs_dist_account_id         NUMBER;
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    l_dist_id                    NUMBER;
    l_interface_id               NUMBER;
  BEGIN
    l_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_lot_translate', 'Validate_lot_translate');
      print_debug ('Calling populate_records', 'Validate_lot_translate');
    END IF;

    BEGIN
      populate_records (x_validation_status          => l_validation_status
                      , x_return_status              => x_return_status
                      , x_st_interface_id_tbl        => l_st_interface_id_tbl
                      , x_st_item_id_tbl             => l_st_item_id_tbl
                      , x_st_org_id_tbl              => l_st_org_id_tbl
                      , x_st_revision_tbl            => l_st_revision_tbl
                      , x_st_sub_code_tbl            => l_st_sub_code_tbl
                      , x_st_locator_id_tbl          => l_st_locator_id_tbl
                      , x_st_lot_num_tbl             => l_st_lot_number_tbl
                      , x_st_ser_num_tbl             => l_st_ser_number_tbl
                      , x_st_ser_parent_lot_tbl      => l_st_ser_parent_lot_tbl
                      , x_rs_ser_parent_lot_tbl      => l_rs_ser_parent_lot_tbl
                      , x_rs_ser_num_tbl             => l_rs_ser_number_tbl
                      , x_st_ser_status_tbl          => l_st_ser_status_tbl
                      , x_rs_ser_status_tbl          => l_rs_ser_status_tbl
                      , x_st_ser_grp_mark_id_tbl     => l_st_ser_grp_mark_id_tbl
                      , x_rs_ser_grp_mark_id_tbl     => l_rs_ser_grp_mark_id_tbl
                      , x_st_ser_parent_sub_tbl      => l_st_ser_parent_sub_tbl
                      , x_st_ser_parent_loc_tbl      => l_st_ser_parent_loc_tbl
                      , x_st_lpn_id_tbl              => l_st_lpn_id_tbl
                      , x_st_quantity_tbl            => l_st_quantity_tbl
                      , x_st_cost_group_tbl          => l_st_cost_group_id_tbl
                      , x_st_uom_tbl                 => l_st_uom_tbl
                      , x_st_status_id_tbl           => l_st_status_id_tbl
                      , x_rs_interface_id_tbl        => l_rs_interface_id_tbl
                      , x_rs_item_id_tbl             => l_rs_item_id_tbl
                      , x_rs_org_id_tbl              => l_rs_org_id_tbl
                      , x_rs_revision_tbl            => l_rs_revision_tbl
                      , x_rs_sub_code_tbl            => l_rs_sub_code_tbl
                      , x_rs_locator_id_tbl          => l_rs_locator_id_tbl
                      , x_rs_lot_num_tbl             => l_rs_lot_number_tbl
                      , x_rs_lpn_id_tbl              => l_rs_lpn_id_tbl
                      , x_rs_quantity_tbl            => l_rs_quantity_tbl
                      , x_rs_cost_group_tbl          => l_rs_cost_group_id_tbl
                      , x_rs_uom_tbl                 => l_rs_uom_tbl
                      , x_rs_status_id_tbl           => l_rs_status_id_tbl
                      , x_st_lot_exp_tbl             => l_st_lot_exp_tbl
                      , x_rs_lot_exp_tbl             => l_rs_lot_exp_tbl
                      , x_transaction_type_id        => l_transaction_type_id
                      , x_acct_period_tbl            => l_acct_period_tbl
                      , x_st_dist_account_id         => l_st_dist_account_id
                      , x_rs_dist_account_id         => l_rs_dist_account_id
                      , p_parent_id                  => p_parent_id
                       );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Populate_records raised error'
                     , 'Validate_lot_translate_Trx'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_RETRIEVE_RECORD');
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSIF (l_validation_status <> 'Y')
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    /*Removing the check...
    -- If wms is not installed and wsm is not enabled, we do not support lot transactions through the interface
    IF (l_debug = 1)
    THEN
      print_debug ('calling get_org_info', 'Validate_lot_translate_Trx');
    END IF;

    inv_lot_trx_validation_pub.get_org_info
                                      (x_wms_installed       => l_wms_installed
                                     , x_wsm_enabled         => l_wsm_enabled
                                     , x_wms_enabled         => l_wms_enabled
                                     , x_return_status       => x_return_status
                                     , x_msg_count           => x_msg_count
                                     , x_msg_data            => x_msg_data
                                     , p_organization_id     => l_st_org_id_tbl
                                                                           (1)
                                      );

    IF (x_return_status = fnd_api.g_ret_sts_error)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('get_org_info returned with error'
                   , 'Validate_lot_translate_Trx'
                    );
      END IF;

      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('get_org_info returned with unexpected error'
                   , 'Validate_lot_translate_Trx'
                    );
      END IF;

      l_validation_status := 'E';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF ((NVL (l_wsm_enabled, 'N') = 'N')
        AND (NVL (l_wms_installed, 'N') = 'N')
       )
    THEN
      -- raise error
      print_debug ('Validation failed on wsm/wms install'
                 , 'Validate_lot_translate'
                  );
      fnd_message.set_name ('WMS', 'WMS_NOT_INSTALLED');
      fnd_msg_pub.ADD;
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;
    */
    IF (l_debug = 1)
    THEN
      print_debug ('calling Validate_Organization', 'Validate_lot_Split_Trx');
    END IF;

    BEGIN
      inv_lot_trx_validation_pub.validate_organization
                                 (x_return_status         => x_return_status
                                , x_msg_count             => x_msg_count
                                , x_msg_data              => x_msg_data
                                , x_validation_status     => l_validation_status
                                , p_organization_id       => l_st_org_id_tbl
                                                                           (1)
                                , p_period_tbl            => l_acct_period_tbl
                                 );
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Validate_organization raised exception'
                     , 'Validate_lot_translate_Trx'
                      );
        END IF;

        fnd_message.set_name ('INV', 'INV_RETRIEVE_PERIOD');
        fnd_msg_pub.ADD;
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- FOR lot Translate, we have  TO get the distribution account id and
    -- populate it IN MTI

    --   BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('after calling populate_records'
                 , 'validate_lot_translate');
      print_debug ('getting wsm_enabled_flag from mtl_parameters'
                 , 'validate_lot_translate'
                  );
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('l_st_dist_account_id = ' || l_st_dist_account_id
                 , 'Validate_lot_translate'
                  );
      print_debug ('l_rs_dist_account_id = ' || l_rs_dist_account_id
                 , 'Validate_lot_translate'
                  );
    END IF;

    IF (l_st_dist_account_id IS NULL OR l_rs_dist_account_id IS NULL)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('l_wsm_enabled = ' || l_wsm_enabled
                   , 'Validate_lot_translate'
                    );
      END IF;

      IF (NVL (l_wsm_enabled, 'N') = 'N')
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Not OSFM Organization', 'Validate_lot_translate');
        END IF;

        /*Bug:4879175. Removing the following check as the distribution_id needs
          to be fetched irrespective of WMS Installation in the organization*/
        /*IF (NVL (l_wms_installed, 'N') = 'Y')
        THEN*/
        IF (l_debug = 1)
          THEN
            print_debug ('l_wms_installed = ' || l_wms_installed
                       , 'Validate_lot_translate'
                        );
        END IF;

        BEGIN
          SELECT distribution_account_id
          INTO   l_distribution_account_id
          FROM   mtl_parameters
          WHERE  organization_id = l_st_org_id_tbl (1);
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            fnd_message.set_name ('INV', 'INV_NO_DIST_ACCOUNT_ID');
            fnd_msg_pub.ADD;

            IF (l_debug = 1)
              THEN
                print_debug ('INV_NO_DIST_ACCOUNT_ID : ' || SQLERRM
                           , 'Validate_lot_translate'
                            );
            END IF;

            l_validation_status := 'N';
            RAISE fnd_api.g_exc_error;
        END;
        /*Bug:4879175.Commenting the following ELSE part.*/
        /*ELSE
          IF (l_debug = 1)
          THEN
            print_debug ('Validation failed on wsm/wms install'
                       , 'Validate_lot_Translate'
                        );
          END IF;

          fnd_message.set_name ('WMS', 'WMS_NOT_INSTALLED');
          fnd_msg_pub.ADD;
          l_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;*/
      ELSE
        BEGIN
          SELECT transaction_account_id
            INTO l_distribution_account_id
            FROM wsm_parameters
           WHERE organization_id = l_st_org_id_tbl (1);
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            fnd_message.set_name ('INV', 'INV_NO_DIST_ACCOUNT_ID');
            fnd_msg_pub.ADD;

            IF (l_debug = 1)
            THEN
              print_debug ('INV_NO_DIST_ACCOUNT_ID : ' || SQLERRM
                         , 'Validate_lot_translate'
                          );
            END IF;

            l_validation_status := 'N';
            RAISE fnd_api.g_exc_error;
        END;
      END IF;

      IF (l_distribution_account_id IS NULL)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Distribution account id is null'
                     , 'Validate_lot_translate'
                      );
          fnd_message.set_name ('INV', 'INV_NO_DIST_ACCOUNT_ID');
          fnd_msg_pub.ADD;
          l_validation_status := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        IF (l_debug = 1)
        THEN
          print_debug (   'Updating dist account id: '
                       || l_distribution_account_id
                     , 'Validate_lot_translate'
                      );
          print_debug (   'l_st_interface_id_tbl(1): '
                       || l_st_interface_id_tbl (1)
                     , 'Validate_lot_translate'
                      );
          print_debug (   'l_rs_interface_id_tbl(1): '
                       || l_rs_interface_id_tbl (1)
                     , 'Validate_lot_translate'
                      );
        END IF;

        UPDATE mtl_transactions_interface
           SET distribution_account_id = l_distribution_account_id
         WHERE transaction_interface_id IN
                       (l_st_interface_id_tbl (1), l_rs_interface_id_tbl (1));
      END IF;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('Calling validate_lots', 'Validate_lot_translate');
    END IF;

    inv_lot_trx_validation_pub.validate_lots
                              (x_return_status           => x_return_status
                             , x_msg_count               => x_msg_count
                             , x_msg_data                => x_msg_data
                             , x_validation_status       => l_validation_status
                             , p_transaction_type_id     => l_transaction_type_id
                             , p_st_org_id_tbl           => l_st_org_id_tbl
                             , p_st_item_id_tbl          => l_st_item_id_tbl
                             , p_st_lot_num_tbl          => l_st_lot_number_tbl
                             , p_rs_org_id_tbl           => l_rs_org_id_tbl
                             , p_rs_item_id_tbl          => l_rs_item_id_tbl
                             , p_rs_lot_num_tbl          => l_rs_lot_number_tbl
                             , p_st_lot_exp_tbl          => l_st_lot_exp_tbl
                             , p_rs_lot_exp_tbl          => l_rs_lot_exp_tbl
                             , p_st_revision_tbl         => l_st_revision_tbl
                             , p_rs_revision_tbl         => l_rs_revision_tbl
                             , p_st_quantity_tbl         => l_st_quantity_tbl
                             , p_rs_quantity_tbl         => l_rs_quantity_tbl
                              );

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('Calling validate_material_status'
                 , 'Validate_lot_translate'
                  );
    END IF;

    inv_lot_trx_validation_pub.validate_material_status
                              (x_return_status           => x_return_status
                             , x_msg_count               => x_msg_count
                             , x_msg_data                => x_msg_data
                             , x_validation_status       => l_validation_status
                             , p_transaction_type_id     => l_transaction_type_id
                             , p_organization_id         => l_st_org_id_tbl
                                                                           (1)
                             , p_inventory_item_id       => l_st_item_id_tbl
                                                                           (1)
                             , p_lot_number              => l_st_lot_number_tbl
                                                                           (1)
                             , p_subinventory_code       => l_st_sub_code_tbl
                                                                           (1)
                             , p_locator_id              => l_st_locator_id_tbl
                                                                           (1)
                             , p_status_id               => l_st_status_id_tbl
                                                                           (1)
                              );

    IF (l_debug = 1)
    THEN
      print_debug ('After calling validate_material_status'
                 , 'Validate_lot_Translate_Trx'
                  );
      print_debug ('Message Count' || x_msg_count
                 , 'Validate_lot_translate_Trx'
                  );
      print_debug ('Return Status' || x_return_status
                 , 'Validate_lot_translate_Trx'
                  );
    END IF;

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      fnd_message.set_name ('WMS', 'WMS_VALIDATE_STATUS_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    BEGIN
      SELECT transaction_action_id
        INTO l_transaction_action_id
        FROM mtl_transaction_types
       WHERE transaction_type_id = l_transaction_type_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        fnd_message.set_name ('INV', 'INV_INT_TRX_TYPE');
        fnd_msg_pub.ADD;
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_INT_TRX_TYPE');
        fnd_msg_pub.ADD;
        l_validation_status := 'E';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (l_debug = 1)
    THEN
      print_debug ('Calling validate_cost_groups', 'Validate_lot_translate');
    END IF;

    inv_lot_trx_validation_pub.validate_cost_groups
                          (x_rs_cost_group_tbl         => l_rs_cost_group_id_tbl
                         , x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_transaction_type_id       => l_transaction_type_id
                         , p_transaction_action_id     => l_transaction_action_id
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_st_item_id_tbl            => l_st_item_id_tbl
                         , p_st_sub_code_tbl           => l_st_sub_code_tbl
                         , p_st_loc_id_tbl             => l_st_locator_id_tbl
                         , p_st_lot_num_tbl            => l_st_lot_number_tbl
                         , p_st_cost_group_tbl         => l_st_cost_group_id_tbl
                         , p_st_revision_tbl           => l_st_revision_tbl
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_item_id_tbl            => l_rs_org_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_loc_id_tbl             => l_rs_locator_id_tbl
                         , p_rs_lot_num_tbl            => l_rs_lot_number_tbl
                         , p_rs_revision_tbl           => l_rs_revision_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                          );

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSE
      IF (l_validation_status <> 'Y')
      THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        FOR i IN 1 .. l_rs_interface_id_tbl.COUNT
        LOOP
          UPDATE mtl_transactions_interface
             SET cost_group_id = l_rs_cost_group_id_tbl (i)
               , distribution_account_id = l_distribution_account_id
           WHERE transaction_interface_id = l_rs_interface_id_tbl (i);
        END LOOP;
      END IF;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('Calling validate_quantity', 'Validate_lot_translate');
    END IF;

    inv_lot_trx_validation_pub.validate_quantity
                          (x_return_status             => x_return_status
                         , x_msg_count                 => x_msg_count
                         , x_msg_data                  => x_msg_data
                         , x_validation_status         => l_validation_status
                         , p_transaction_type_id       => l_transaction_type_id
                         , p_st_org_id_tbl             => l_st_org_id_tbl
                         , p_st_item_id_tbl            => l_st_item_id_tbl
                         , p_st_sub_code_tbl           => l_st_sub_code_tbl
                         , p_st_loc_id_tbl             => l_st_locator_id_tbl
                         , p_st_lot_num_tbl            => l_st_lot_number_tbl
                         , p_st_cost_group_tbl         => l_st_cost_group_id_tbl
                         , p_st_revision_tbl           => l_st_revision_tbl
                         , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                         , p_st_quantity_tbl           => l_st_quantity_tbl
                         , p_st_uom_tbl                => l_st_uom_tbl
                         , p_st_ser_parent_lot_tbl     => l_st_ser_parent_lot_tbl
                         , p_st_ser_number_tbl         => l_st_ser_number_tbl
                         , p_rs_org_id_tbl             => l_rs_org_id_tbl
                         , p_rs_item_id_tbl            => l_rs_item_id_tbl
                         , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                         , p_rs_loc_id_tbl             => l_rs_locator_id_tbl
                         , p_rs_lot_num_tbl            => l_rs_lot_number_tbl
                         , p_rs_cost_group_tbl         => l_rs_cost_group_id_tbl
                         , p_rs_revision_tbl           => l_rs_revision_tbl
                         , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                         , p_rs_quantity_tbl           => l_rs_quantity_tbl
                         , p_rs_uom_tbl                => l_rs_uom_tbl
                         , p_rs_ser_number_tbl         => l_rs_ser_number_tbl
                         , p_rs_ser_parent_lot_tbl     => l_rs_ser_parent_lot_tbl
                          );

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('validate_quantity returned with error'
                   , 'Validate_lot_translate_Trx'
                    );
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('Calling get_lot_attr_record for parent record'
                 , 'Validate_lot_translate'
                  );
    END IF;
    /*Call LPN Validations*/
    BEGIN
        IF (l_debug = 1)
        THEN
          print_debug('calling validate_lpn_info' , 'validate_lot_translate_trx');
        END IF;



        inv_lot_trx_validation_pub.validate_lpn_info
                            (x_return_status             => x_return_status
                           , x_msg_count                 => x_msg_count
                           , x_msg_data                  => x_msg_data
                           , x_validation_status         => l_validation_status
                           , p_st_lpn_id_tbl             => l_st_lpn_id_tbl
                           , p_rs_lpn_id_tbl             => l_rs_lpn_id_tbl
                           , p_st_org_id_tbl             => l_st_org_id_tbl
                           , p_rs_org_id_tbl             => l_rs_org_id_tbl
                           , p_rs_sub_code_tbl           => l_rs_sub_code_tbl
                           , p_rs_locator_id_tbl         => l_rs_locator_id_tbl
                           );
        IF(l_debug = 1) THEN
          print_debug('after validate_lpn_info ' , 'validate_lot_translate_trx');
        END IF;

      EXCEPTION
        WHEN OTHERS
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('validate_lpn_info raised exception'
                       , 'Validate_lot_translate_Trx'
                        );
          END IF;

          fnd_message.set_name ('INV', 'INV_INT_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (   x_return_status <> fnd_api.g_ret_sts_success
          OR l_validation_status <> 'Y'
         )
      THEN

        print_debug ('validate_lpn_info returned with Error'
                   , 'Validate_lot_translate_Trx'
                    );
        RAISE fnd_api.g_exc_error;
      END IF;

    /*Call LPN Validations*/

    BEGIN
      BEGIN
        IF (l_debug = 1)
        THEN
          print_debug ('getting serial control code'
                     , 'Validate_lot_translate_Trx'
                      );
        END IF;

        SELECT DECODE (serial_number_control_code, 2, 'Y'
                       , 5, 'Y',
                       'N')
          INTO l_is_serial_controlled
          FROM mtl_system_items
         WHERE inventory_item_id = l_st_item_id_tbl (1)
           AND organization_id = l_st_org_id_tbl (1);
      EXCEPTION
        WHEN OTHERS
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('Cannot fetch the serial control code for the item'
                       , 'Validate_lot_Translate_Trx'
                        );
          END IF;

          l_validation_status := 'N';
          RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (l_is_serial_controlled = 'Y')
      THEN
        IF (   l_st_ser_number_tbl.COUNT = 0
            OR l_rs_ser_number_tbl.COUNT = 0
            OR l_st_ser_number_tbl.COUNT <> l_rs_ser_number_tbl.COUNT
           )
        THEN
          IF (l_debug = 1)
          THEN
            print_debug
              ('Either the serial records are empty or the starting and resulting records do not match'
             , 'Validate_lot_Translate_Trx'
              );
          END IF;

          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_SERIAL_INFO_MISSING');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          BEGIN
            IF (l_debug = 1)
            THEN
              print_debug ('calling validate_serials'
                         , 'Validate_lot_Translate_Trx'
                          );
            END IF;

            inv_lot_trx_validation_pub.validate_serials
                        (x_return_status              => x_return_status
                       , x_msg_count                  => x_msg_count
                       , x_msg_data                   => x_msg_data
                       , x_validation_status          => l_validation_status
                       , p_transaction_type_id        => l_transaction_type_id
                       , p_st_org_id_tbl              => l_st_org_id_tbl
                       , p_rs_org_id_tbl              => l_rs_org_id_tbl
                       , p_st_item_id_tbl             => l_st_item_id_tbl
                       , p_rs_item_id_tbl             => l_rs_item_id_tbl
                       , p_st_quantity_tbl            => l_st_quantity_tbl
                       --Needed for status control check
                       , p_st_sub_code_tbl            => l_st_sub_code_tbl
                       , p_st_locator_id_tbl          => l_st_locator_id_tbl
                       , p_st_ser_parent_lot_tbl      => l_st_ser_parent_lot_tbl
                       , p_rs_lot_num_tbl             => l_rs_lot_number_tbl
                       , p_st_ser_number_tbl          => l_st_ser_number_tbl
                       , p_rs_ser_number_tbl          => l_rs_ser_number_tbl
                       , p_st_ser_status_tbl          => l_st_ser_status_tbl
                       , p_st_ser_grp_mark_id_tbl     => l_st_ser_grp_mark_id_tbl
                       , p_st_ser_parent_sub_tbl      => l_st_ser_parent_sub_tbl
                       , p_st_ser_parent_loc_tbl      => l_st_ser_parent_loc_tbl
                      );
          EXCEPTION
            WHEN OTHERS
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('Validate_serials has raised exception'
                           , 'Validate_lot_Translate_Trx'
                            );
              END IF;

              l_validation_status := 'N';
              fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;

          IF (   x_return_status <> fnd_api.g_ret_sts_success
              OR l_validation_status <> 'Y'
             )
          THEN
            IF (l_debug = 1)
            THEN
              print_debug ('Validate_serials returned with error code'
                         , 'Validate_lot_Translate_Trx'
                          );
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;                                       --is lot serial controlled
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('Error in validating serial info'
                     , 'Validate_lot_Translate_Trx'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    /*Bug:5354721. The following procedure populates the column name, type and
      length for all the Lot Attributes. */
    get_lot_attr_table;

    get_lot_attr_record
                      (x_lot_attr_tbl                 => l_st_lot_attr_tbl
                     , p_transaction_interface_id     => l_st_interface_id_tbl
                                                                           (1)
                     , p_lot_number                   => l_st_lot_number_tbl
                                                                           (1)
                     , p_starting_lot_number          => l_st_lot_number_tbl
                                                                           (1)
                     , p_organization_id              => l_st_org_id_tbl (1)
                     , p_inventory_item_id            => l_st_item_id_tbl (1)
                      );

    --For i in 1..l_rs_interface_id_tbl.COUNT loop
    IF (l_debug = 1)
    THEN
      print_debug ('Calling get_lot_attr_record for resultant records'
                 , 'Validate_lot_translate'
                  );
      print_debug ('l_rs_interface_id is ' || l_rs_interface_id_tbl (1)
                 , 'Validate_lot_translate'
                  );
    END IF;

    get_lot_attr_record
                      (x_lot_attr_tbl                 => l_rs_lot_attr_tbl
                     , p_transaction_interface_id     => l_rs_interface_id_tbl
                                                                           (1)
                     , p_lot_number                   => l_rs_lot_number_tbl
                                                                           (1)
                     , p_starting_lot_number          => l_st_lot_number_tbl
                                                                           (1)
                     , p_organization_id              => l_rs_org_id_tbl (1)
                     , p_inventory_item_id            => l_rs_item_id_tbl (1)
                      );

    IF (l_debug = 1)
    THEN
      print_debug ('calling validate_attributes for resultant records'
                 , 'Validate_lot_translate'
                  );
    END IF;

    inv_lot_trx_validation_pub.validate_attributes
                               (x_return_status           => x_return_status
                              , x_msg_count               => x_msg_count
                              , x_msg_data                => x_msg_data
                              , x_validation_status       => l_validation_status
                              , x_lot_attr_tbl            => l_lot_attr_tbl
                              , p_lot_number              => l_st_lot_number_tbl
                                                                           (1)
                              , p_organization_id         => l_rs_org_id_tbl
                                                                           (1)
                              , p_inventory_item_id       => l_rs_item_id_tbl
                                                                           (1)
                              , p_parent_lot_attr_tbl     => l_st_lot_attr_tbl
                              , p_result_lot_attr_tbl     => l_rs_lot_attr_tbl
                              , p_transaction_type_id     => l_transaction_type_id
                               );

    IF (   x_return_status <> fnd_api.g_ret_sts_success
        OR l_validation_status <> 'Y'
       )
    THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      IF (l_lot_attr_tbl.COUNT > 0)
      THEN
        -- this means user does not provide the lot attribute for the result lot.
        -- we need to update the mtl_transation_lots_interface with the parent
        -- lot attributes if it exists or use default lot attributes
        update_lot_attr_record
                     (p_lot_attr_tbl                 => l_lot_attr_tbl
                    , p_transaction_interface_id     => l_rs_interface_id_tbl
                                                                           (1)
                    , p_lot_number                   => l_rs_lot_number_tbl
                                                                           (1)
                    , p_organization_id              => l_rs_org_id_tbl (1)
                    , p_inventory_item_id            => l_rs_item_id_tbl (1)
                     );
      END IF;
    END IF;

     --end loop;
    -- Call to compute the correct expiration dates
    BEGIN
      -- Send in just one lot number
      inv_lot_trx_validation_pub.compute_lot_expiration
                             (x_return_status           => x_return_status
                            , x_msg_count               => x_msg_count
                            , x_msg_data                => x_msg_data
                            , p_parent_id               => p_parent_id
                            , p_transaction_type_id     => l_transaction_type_id
                            , p_item_id                 => l_st_item_id_tbl
                                                                           (1)
                            , p_organization_id         => l_st_org_id_tbl (1)
                            , p_st_lot_num              => l_st_lot_number_tbl
                                                                           (1)
                            , p_rs_lot_num_tbl          => l_rs_lot_number_tbl
                            , p_rs_lot_exp_tbl          => l_rs_lot_exp_tbl
                             );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('INV', 'INV_LOT_EXP_COMPUTE_ERROR');
        fnd_msg_pub.ADD;
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      fnd_message.set_name ('INV', 'INV_LOT_EXP_COMPUTE_ERROR');
      fnd_msg_pub.ADD;
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    -- if we reach here, it means all validations are successfull
    x_return_status := fnd_api.g_ret_sts_success;
    x_validation_status := 'Y';
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_validation_status := l_validation_status;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_status := l_validation_status;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_status := 'E';

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'validate_lot_translate_trx');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_lot_translate_trx;
END inv_lot_trx_validation_pvt;

/
