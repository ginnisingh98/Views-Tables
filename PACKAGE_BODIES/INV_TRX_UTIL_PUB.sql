--------------------------------------------------------
--  DDL for Package Body INV_TRX_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRX_UTIL_PUB" AS
  /* $Header: INVTRXUB.pls 120.8.12010000.13 2011/11/22 09:31:09 gke ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_TRX_UTIL_PUB';

  PROCEDURE TRACE(p_mesg VARCHAR2, p_mod VARCHAR2, p_level NUMBER := 9) IS
  BEGIN
    inv_log_util.TRACE(p_mesg, p_mod, p_level);
  END;

  --
  --    Name: INSERT_LINE_TRX
  --
  --     Functions:  This API inserts a row into MTL_MATERIAL_TRANSACTIONS_TEMP
  --        The function returns the transaction_temp_id which is unique for this
  --        record, and could be used for coupling Lot and Serial Transaction
  --        records associated with this transaction.
  --
  FUNCTION insert_line_trx(
    p_trx_hdr_id                  IN            NUMBER
  , p_item_id                     IN            NUMBER
  , p_revision                    IN            VARCHAR2 := NULL
  , p_org_id                      IN            NUMBER
  , p_trx_action_id               IN            NUMBER
  , p_subinv_code                 IN            VARCHAR2
  , p_tosubinv_code               IN            VARCHAR2 := NULL
  , p_locator_id                  IN            NUMBER := NULL
  , p_tolocator_id                IN            NUMBER := NULL
  , p_xfr_org_id                  IN            NUMBER := NULL
  , p_trx_type_id                 IN            NUMBER
  , p_trx_src_type_id             IN            NUMBER
  , p_trx_qty                     IN            NUMBER
  , p_pri_qty                     IN            NUMBER
  , p_uom                         IN            VARCHAR2
  , p_date                        IN            DATE := SYSDATE
  , p_reason_id                   IN            NUMBER := NULL
  , p_user_id                     IN            NUMBER
  , p_frt_code                    IN            VARCHAR2 := NULL
  , p_ship_num                    IN            VARCHAR2 := NULL
  , p_dist_id                     IN            NUMBER := NULL
  , p_way_bill                    IN            VARCHAR2 := NULL
  , p_exp_arr                     IN            DATE := NULL
  , p_cost_group                  IN            NUMBER := NULL
  , p_from_lpn_id                 IN            NUMBER := NULL
  , p_cnt_lpn_id                  IN            NUMBER := NULL
  , p_xfr_lpn_id                  IN            NUMBER := NULL
  , p_trx_src_id                  IN            NUMBER := NULL
  , x_trx_tmp_id                  OUT NOCOPY    NUMBER
  , x_proc_msg                    OUT NOCOPY    VARCHAR2
  , p_xfr_cost_group              IN            NUMBER := NULL
  , p_completion_trx_id           IN            NUMBER := NULL
  , p_flow_schedule               IN            VARCHAR2 := NULL
  , p_trx_cost                    IN            NUMBER := NULL
  , p_project_id                  IN            NUMBER := NULL
  , p_task_id                     IN            NUMBER := NULL
  , p_cost_of_transfer            IN            NUMBER := NULL
  , p_cost_of_transportation      IN            NUMBER := NULL
  , p_transfer_percentage         IN            NUMBER := NULL
  , p_transportation_cost_account IN            NUMBER := NULL
  , p_planning_org_id             IN            NUMBER
  , p_planning_tp_type            IN            NUMBER
  , p_owning_org_id               IN            NUMBER
  , p_owning_tp_type              IN            NUMBER
  , p_trx_src_line_id             IN            NUMBER := NULL
  , p_secondary_trx_qty           IN            NUMBER := NULL
  , p_secondary_uom               IN            VARCHAR2 := NULL
  , p_move_order_line_id          IN            NUMBER := NULL
  , p_posting_flag                IN            VARCHAR2 := NULL
  , p_move_order_header_id        IN            NUMBER
  , p_serial_allocated_flag       IN            VARCHAR2
  , p_transaction_status          IN            NUMBER
  , p_process_flag                IN            VARCHAR2 := NULL
  , p_ship_to_location_id         IN            NUMBER  --eIB Build; Bug# 4348541
  , p_relieve_reservations_flag	  IN		VARCHAR2 := NULL	--	Bug 6310875
  , p_opm_org_in_xfer             IN            VARCHAR2                --      Bug 8939057
  )
    RETURN NUMBER IS
    v_trxqty           NUMBER  := p_trx_qty;
    v_priqty           NUMBER  := p_pri_qty;
    v_acct_period_id   NUMBER;
    v_open_past_period BOOLEAN := FALSE;
    v_trx_hdr_id       NUMBER  := p_trx_hdr_id;
    v_item_id          NUMBER  := p_item_id;
    l_debug            NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    --8939057
    l_api_name                VARCHAR2(30) := 'INSERT_LINE_TRX';
    x_transfer_price          NUMBER;
    x_currency_code           VARCHAR2(31);
    x_transfer_price_priuom   NUMBER;
    x_incr_transfer_price     NUMBER;
    x_incr_currency_code      VARCHAR2(31);
    x_return_status           VARCHAR2(1);
    x_msg_data                VARCHAR2(2000);
    x_msg_count               NUMBER;

    --bug 9022750
    l_lot_ctrl_code    NUMBER;
    l_ser_ctrl_code    NUMBER;
    l_rev_ctrl_code    NUMBER;
    l_loc_ctrl_code    NUMBER;

	--bug 12588822
    l_xfr_project_id     NUMBER    :=  NULL;
    l_xfr_task_id        NUMBER    :=  NULL;

  BEGIN

    -- get the account period ID
    invttmtx.tdatechk(p_org_id, p_date, v_acct_period_id, v_open_past_period);

    IF (v_acct_period_id = 0)
       OR(v_acct_period_id = -1) THEN
      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

     -- Start Bug 8939057
     inv_log_util.trace('p_process_flag is:' || p_process_flag, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_relieve_reservations_flag is:' || p_relieve_reservations_flag, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_opm_org_in_xfer is:' || p_opm_org_in_xfer, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_item_id is:' || p_item_id, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_trx_qty is:' || p_trx_qty, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_uom is:' || p_uom, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_from_org_id is:' || p_org_id, g_pkg_name || '.' || l_api_name, 5);
     inv_log_util.trace('p_to_org_id is  :' || p_xfr_org_id, g_pkg_name || '.' || l_api_name, 5);

     -- Call GMF get transfer price only if FROM or TO org is process enabled.
     IF (p_opm_org_in_xfer = 'Y') THEN

         inv_log_util.trace('Calling GMF_get_transfer_price_PUB.get_transfer_price', g_pkg_name || '.' || l_api_name, 5);

         GMF_get_transfer_price_PUB.get_transfer_price (
           p_api_version             => 1.0
         , p_init_msg_list           => 'F'

         , p_inventory_item_id       => p_item_id
         , p_transaction_qty         => p_trx_qty
         , p_transaction_uom         => p_uom

         , p_transaction_id          => NULL -- mtl_trx_line.transaction_id  ***
         , p_global_procurement_flag => 'N'
         , p_drop_ship_flag          => 'N'

         , p_from_organization_id    => p_org_id
         , p_from_ou                 => 1 -- Passing dummy value as this is fetched again in GMF.
         , p_to_organization_id      => p_xfr_org_id
         , p_to_ou                   => 1 -- Passing dummy value as this is fetched again in GMF.

         , p_transfer_type           => 'INTORG'
         , p_transfer_source         => 'INTORG'

         , x_return_status           => x_return_status
         , x_msg_data                => x_msg_data
         , x_msg_count               => x_msg_count

         , x_transfer_price          => x_transfer_price
         , x_transfer_price_priuom   => x_transfer_price_priuom	/* Store Transfer Price in pri uom */
         , x_currency_code           => x_currency_code
         , x_incr_transfer_price     => x_incr_transfer_price
         , x_incr_currency_code      => x_incr_currency_code
         );

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    	THEN
      		inv_log_util.trace('X_return status is <> S',g_pkg_name || '.' || l_api_name, 5);
  		x_transfer_price  := 0;
    	END IF;

        inv_log_util.trace('x_transfer_price is:' || x_transfer_price, g_pkg_name || '.' || l_api_name, 5);
        inv_log_util.trace('x_currency_code is :' || x_currency_code, g_pkg_name || '.' || l_api_name, 5);
     END IF;
     -- End Bug 8939057

    IF (p_trx_action_id = inv_globals.g_action_issue)
       OR(p_trx_action_id = inv_globals.g_action_intransitshipment) THEN
      v_trxqty  := -1 * p_trx_qty;
      v_priqty  := -1 * p_pri_qty;
    END IF;

  /*  SELECT mtl_material_transactions_s.NEXTVAL
      INTO x_trx_tmp_id
      FROM DUAL; */

    -- If content Item Id is not NULL then set ItemId = -1;
    IF (p_cnt_lpn_id IS NOT NULL) THEN
      v_item_id  := -1;
    END IF;

    -- If the user passes NULL for p_trx_hdr_id insert into MMTT.TRX_HDR_ID
    -- same value as TRX_TEMP_ID
/*    IF (v_trx_hdr_id IS NULL) THEN
      v_trx_hdr_id  := x_trx_tmp_id;
    END IF;  */

    --bug 9022750
    BEGIN

        SELECT lot_control_code, serial_number_control_code, revision_qty_control_code, location_control_code
        INTO l_lot_ctrl_code, l_ser_ctrl_code, l_rev_ctrl_code, l_loc_ctrl_code
        FROM mtl_system_items
        WHERE organization_id = p_org_id
        AND inventory_item_id = p_item_id;

        IF (l_debug = 1) THEN
            TRACE('lot ctrl:'||l_lot_ctrl_code||' ser ctrl:'||l_ser_ctrl_code||' rev ctrl:'||l_rev_ctrl_code||' loc ctrl:'||l_loc_ctrl_code, 'INVTRXUB', 9);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            l_lot_ctrl_code := 0;
            l_ser_ctrl_code := 0;
            l_rev_ctrl_code := 0;
            l_loc_ctrl_code := 0;
            IF (l_debug = 1) THEN
                TRACE('Exception:'||SQLERRM, 'INVTRXUB', 9);
            END IF;

    END;

     --bug 12588822
    IF ( (p_trx_action_id = inv_globals.G_ACTION_CONTAINERPACK OR p_trx_action_id = inv_globals.G_ACTION_CONTAINERUNPACK OR p_trx_action_id = inv_globals.G_ACTION_CONTAINERSPLIT)
          AND p_trx_src_type_id = inv_globals.G_SOURCETYPE_INVENTORY) THEN
         l_xfr_project_id := p_project_id;
         l_xfr_task_id    := p_task_id;
    END IF;

    INSERT INTO mtl_material_transactions_temp
                (
                 transaction_header_id
               , transaction_temp_id
               , process_flag
               , creation_date
               , created_by
               , last_update_date
               , last_updated_by
               , last_update_login
               , inventory_item_id
               , organization_id
               , subinventory_code
               , locator_id
               , transfer_to_location
               , transaction_quantity
               , primary_quantity
               , transaction_uom
               , secondary_transaction_quantity
               , secondary_uom_code
               , transaction_type_id
               , transaction_action_id
               , transaction_source_type_id
               , transaction_date
               , acct_period_id
               , transfer_organization
               , transfer_subinventory
               , reason_id
               , shipment_number
               , distribution_account_id
               , waybill_airbill
               , expected_arrival_date
               , freight_code
               , revision
               , lpn_id
               , content_lpn_id
               , transfer_lpn_id
               , cost_group_id
               , transaction_source_id
               , trx_source_line_id
               , transfer_cost_group_id
               , completion_transaction_id
               , flow_schedule
               , transaction_cost
               , project_id
               , task_id
               , planning_organization_id
               , planning_tp_type
               , owning_organization_id
               , owning_tp_type
               , posting_flag
               , transfer_cost
               , transportation_cost
               , transfer_percentage
               , transportation_account
               , move_order_header_id
               , move_order_line_id
               , serial_allocated_flag
               , transaction_status
               , ship_to_location --eIB Build; Bug# 4348541
               , relieve_reservations_flag		--	Bug 6310875
               , transfer_price 	                --      Bug 8939057
               --bug9022750
               , item_lot_control_code
               , item_serial_control_code
               , item_revision_qty_control_code
               , item_location_control_code
               , to_project_id                 --bug 12588822
               , to_task_id                    --bug 12588822
                )
         VALUES (
                 nvl(v_trx_hdr_id,mtl_material_transactions_s.NEXTVAL)
 --              , x_trx_tmp_id
               , mtl_material_transactions_s.NEXTVAL  -- Bug 5535030
               , nvl(p_process_flag,'Y')
               , SYSDATE
               , p_user_id
               , SYSDATE
               , p_user_id
               , p_user_id
               , v_item_id
               , p_org_id
               , p_subinv_code
               , p_locator_id
               , p_tolocator_id
               , v_trxqty
               , v_priqty
               , p_uom
               , p_secondary_trx_qty
               , p_secondary_uom
               , p_trx_type_id
               , p_trx_action_id
               , p_trx_src_type_id
               , p_date
               , v_acct_period_id
               , p_xfr_org_id
               , p_tosubinv_code
               , p_reason_id
               , p_ship_num
               , p_dist_id
               , p_way_bill
               , p_exp_arr
               , p_frt_code
               , p_revision
               , p_from_lpn_id
               , p_cnt_lpn_id
               , p_xfr_lpn_id
               , p_cost_group
               , p_trx_src_id
               , p_trx_src_line_id
               , p_xfr_cost_group
               , p_completion_trx_id
               , p_flow_schedule
               , p_trx_cost
               , p_project_id
               , p_task_id
               , p_planning_org_id
               , p_planning_tp_type
               , p_owning_org_id
               , p_owning_tp_type
               , nvl(p_posting_flag,'Y')
               , p_cost_of_transfer
               , p_cost_of_transportation
               , p_transfer_percentage
               , p_transportation_cost_account
               , p_move_order_header_id
               , p_move_order_line_id
               , p_serial_allocated_flag
               , p_transaction_status
               , p_ship_to_location_id --eIB Build; Bug# 4348541
               , p_relieve_reservations_flag				--	Bug 6310875
               , x_transfer_price		  -- Bug 8939057
               --bug9022750
               , l_lot_ctrl_code
               , l_ser_ctrl_code
               , l_rev_ctrl_code
               , l_loc_ctrl_code
               , l_xfr_project_id                   --bug 12588822
               , l_xfr_task_id                      --bug 12588822
      ) RETURNING transaction_temp_id INTO x_trx_tmp_id;


    RETURN 0;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_proc_msg  := fnd_msg_pub.get(1, 'F');
      RETURN -1;
    WHEN OTHERS THEN
      x_proc_msg  := SUBSTR(SQLERRM, 1, 200);
      RETURN -1;
  END;

  --
  --     Name: INSERT_LOT_TRX
  --
  --      Functions: This function inserts a Lot Transaction record into
  --          MTL_TRANSACTION_LOT_NUMBERS. The argument p_trx_tmp_id is
  --          used to couple this record with a transaction-line in
  --          MTL_MATERIAL_TRANSACTIONS_TEMP
  --
  FUNCTION insert_lot_trx(
    p_trx_tmp_id             IN            NUMBER
  , p_user_id                IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_trx_qty                IN            NUMBER
  , p_pri_qty                IN            NUMBER
  , p_exp_date               IN            DATE := NULL
  , p_description            IN            VARCHAR2 := NULL
  , p_vendor_name            IN            VARCHAR2 := NULL
  , p_supplier_lot_number    IN            VARCHAR2 := NULL
  , p_origination_date       IN            DATE := NULL
  , p_date_code              IN            VARCHAR2 := NULL
  , p_grade_code             IN            VARCHAR2 := NULL
  , p_change_date            IN            DATE := NULL
  , p_maturity_date          IN            DATE := NULL
  , p_status_id              IN            NUMBER := NULL
  , p_retest_date            IN            DATE := NULL
  , p_age                    IN            NUMBER := NULL
  , p_item_size              IN            NUMBER := NULL
  , p_color                  IN            VARCHAR2 := NULL
  , p_volume                 IN            NUMBER := NULL
  , p_volume_uom             IN            VARCHAR2 := NULL
  , p_place_of_origin        IN            VARCHAR2 := NULL
  , p_best_by_date           IN            DATE := NULL
  , p_length                 IN            NUMBER := NULL
  , p_length_uom             IN            VARCHAR2 := NULL
  , p_recycled_content       IN            NUMBER := NULL
  , p_thickness              IN            NUMBER := NULL
  , p_thickness_uom          IN            VARCHAR2 := NULL
  , p_width                  IN            NUMBER := NULL
  , p_width_uom              IN            VARCHAR2 := NULL
  , p_curl_wrinkle_fold      IN            VARCHAR2 := NULL
  , p_lot_attribute_category IN            VARCHAR2 := NULL
  , p_c_attribute1           IN            VARCHAR2 := NULL
  , p_c_attribute2           IN            VARCHAR2 := NULL
  , p_c_attribute3           IN            VARCHAR2 := NULL
  , p_c_attribute4           IN            VARCHAR2 := NULL
  , p_c_attribute5           IN            VARCHAR2 := NULL
  , p_c_attribute6           IN            VARCHAR2 := NULL
  , p_c_attribute7           IN            VARCHAR2 := NULL
  , p_c_attribute8           IN            VARCHAR2 := NULL
  , p_c_attribute9           IN            VARCHAR2 := NULL
  , p_c_attribute10          IN            VARCHAR2 := NULL
  , p_c_attribute11          IN            VARCHAR2 := NULL
  , p_c_attribute12          IN            VARCHAR2 := NULL
  , p_c_attribute13          IN            VARCHAR2 := NULL
  , p_c_attribute14          IN            VARCHAR2 := NULL
  , p_c_attribute15          IN            VARCHAR2 := NULL
  , p_c_attribute16          IN            VARCHAR2 := NULL
  , p_c_attribute17          IN            VARCHAR2 := NULL
  , p_c_attribute18          IN            VARCHAR2 := NULL
  , p_c_attribute19          IN            VARCHAR2 := NULL
  , p_c_attribute20          IN            VARCHAR2 := NULL
  , p_d_attribute1           IN            DATE := NULL
  , p_d_attribute2           IN            DATE := NULL
  , p_d_attribute3           IN            DATE := NULL
  , p_d_attribute4           IN            DATE := NULL
  , p_d_attribute5           IN            DATE := NULL
  , p_d_attribute6           IN            DATE := NULL
  , p_d_attribute7           IN            DATE := NULL
  , p_d_attribute8           IN            DATE := NULL
  , p_d_attribute9           IN            DATE := NULL
  , p_d_attribute10          IN            DATE := NULL
  , p_n_attribute1           IN            NUMBER := NULL
  , p_n_attribute2           IN            NUMBER := NULL
  , p_n_attribute3           IN            NUMBER := NULL
  , p_n_attribute4           IN            NUMBER := NULL
  , p_n_attribute5           IN            NUMBER := NULL
  , p_n_attribute6           IN            NUMBER := NULL
  , p_n_attribute7           IN            NUMBER := NULL
  , p_n_attribute8           IN            NUMBER := NULL
  , p_n_attribute9           IN            NUMBER := NULL
  , p_n_attribute10          IN            NUMBER := NULL
  , x_ser_trx_id             OUT NOCOPY    NUMBER
  , x_proc_msg               OUT NOCOPY    VARCHAR2
  , p_territory_code         IN            VARCHAR2 := NULL
  , p_vendor_id              IN            VARCHAR2 := NULL
  , p_secondary_qty          IN            NUMBER   --Bug# 8204534,we shouldn't assign it to NULL
  , p_secondary_uom          IN            VARCHAR2 --Bug# 8204534,we shouldn't assign it to NULL

  --Bug No 3952081
  --Add arguments to intake new OPM attributes of the lot
  , p_parent_lot_number      IN            MTL_LOT_NUMBERS.PARENT_LOT_NUMBER%TYPE := NULL
  , p_origination_type       IN            MTL_LOT_NUMBERS.ORIGINATION_TYPE%TYPE := NULL
  , p_expriration_action_date IN           MTL_LOT_NUMBERS.EXPIRATION_ACTION_DATE%TYPE := NULL
  , p_expriration_action_code IN           MTL_LOT_NUMBERS.EXPIRATION_ACTION_CODE%TYPE := NULL
  , p_hold_date              IN            MTL_LOT_NUMBERS.HOLD_DATE%TYPE := NULL
  )
    RETURN NUMBER IS
    -- Bug# 2032659 Beginning
    l_description            VARCHAR(250) := NULL;
    l_vendor_name            VARCHAR(250) := NULL;
    l_supplier_lot_number    VARCHAR(250) := NULL;
    l_origination_date       DATE         := NULL;
    l_date_code              VARCHAR(250) := NULL;
    l_grade_code             VARCHAR(250) := NULL;
    l_change_date            DATE         := NULL;
    l_maturity_date          DATE         := NULL;
    l_retest_date            DATE         := NULL;
    l_age                    NUMBER       := NULL;
    l_item_size              NUMBER       := NULL;
    l_color                  VARCHAR(250) := NULL;
    l_volume                 NUMBER       := NULL;
    l_volume_uom             VARCHAR(250) := NULL;
    l_place_of_origin        VARCHAR(250) := NULL;
    l_best_by_date           DATE         := NULL;
    l_length                 NUMBER       := NULL;
    l_length_uom             VARCHAR(250) := NULL;
    l_recycled_content       NUMBER       := NULL;
    l_thickness              NUMBER       := NULL;
    l_thickness_uom          VARCHAR(250) := NULL;
    l_width                  NUMBER       := NULL;
    l_width_uom              VARCHAR(250) := NULL;
    l_curl_wrinkle_fold      VARCHAR(250) := NULL;
    l_lot_attribute_category VARCHAR(250) := NULL;
    l_c_attribute1           VARCHAR(250) := NULL;
    l_c_attribute2           VARCHAR(250) := NULL;
    l_c_attribute3           VARCHAR(250) := NULL;
    l_c_attribute4           VARCHAR(250) := NULL;
    l_c_attribute5           VARCHAR(250) := NULL;
    l_c_attribute6           VARCHAR(250) := NULL;
    l_c_attribute7           VARCHAR(250) := NULL;
    l_c_attribute8           VARCHAR(250) := NULL;
    l_c_attribute9           VARCHAR(250) := NULL;
    l_c_attribute10          VARCHAR(250) := NULL;
    l_c_attribute11          VARCHAR(250) := NULL;
    l_c_attribute12          VARCHAR(250) := NULL;
    l_c_attribute13          VARCHAR(250) := NULL;
    l_c_attribute14          VARCHAR(250) := NULL;
    l_c_attribute15          VARCHAR(250) := NULL;
    l_c_attribute16          VARCHAR(250) := NULL;
    l_c_attribute17          VARCHAR(250) := NULL;
    l_c_attribute18          VARCHAR(250) := NULL;
    l_c_attribute19          VARCHAR(250) := NULL;
    l_c_attribute20          VARCHAR(250) := NULL;
    l_d_attribute1           DATE         := NULL;
    l_d_attribute2           DATE         := NULL;
    l_d_attribute3           DATE         := NULL;
    l_d_attribute4           DATE         := NULL;
    l_d_attribute5           DATE         := NULL;
    l_d_attribute6           DATE         := NULL;
    l_d_attribute7           DATE         := NULL;
    l_d_attribute8           DATE         := NULL;
    l_d_attribute9           DATE         := NULL;
    l_d_attribute10          DATE         := NULL;
    l_n_attribute1           NUMBER       := NULL;
    l_n_attribute2           NUMBER       := NULL;
    l_n_attribute3           NUMBER       := NULL;
    l_n_attribute4           NUMBER       := NULL;
    l_n_attribute5           NUMBER       := NULL;
    l_n_attribute6           NUMBER       := NULL;
    l_n_attribute7           NUMBER       := NULL;
    l_n_attribute8           NUMBER       := NULL;
    l_n_attribute9           NUMBER       := NULL;
    l_n_attribute10          NUMBER       := NULL;
    l_vendor_id              VARCHAR(250) := NULL;
    l_territory_code         VARCHAR(250) := NULL;
    -- Bug# 2032659 End
    l_debug                  NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    --Bug No 3952081
    --Add variables to hold existent OPM attributes of the lot
    l_parent_lot_number      MTL_LOT_NUMBERS.PARENT_LOT_NUMBER%TYPE := NULL;
    l_origination_type       MTL_LOT_NUMBERS.ORIGINATION_TYPE%TYPE := NULL;
    l_expriration_action_date MTL_LOT_NUMBERS.EXPIRATION_ACTION_DATE%TYPE := NULL;
    l_expriration_action_code MTL_LOT_NUMBERS.EXPIRATION_ACTION_CODE%TYPE := NULL;
    l_hold_date              MTL_LOT_NUMBERS.HOLD_DATE%TYPE := NULL;
  BEGIN


    -- Bug# 2032659
    -- If Lot exists already, take the attributes from MTL_LOT_NUMBERS, else
    -- take the input attribute values. This has to be done, because, in mobile
    -- transactions, Lot Attribute page is not visited if the lot transaction
    -- involves already exisiting lot and because of this MTLT will get populated without attribute
    -- values. Later, MTL_TRANSACTION_LOT_NUMBERS will also get populated without attribute
    -- values. Form 'Material Transactions' is built on a view with base table
    -- MTL_TRANSACTION_LOT_NUMBERS. And for transactions that were done with existing
    -- lot, lot attributes weren't visible in this form. This problem is solved
    -- right in the beginning of transaction life, ie., by populating MTLT attribute values
    -- from MTL_LOT_NUMBERS if Lot already exists.
    BEGIN
      SELECT description
           , vendor_name
           , supplier_lot_number
           , origination_date
           , date_code
           , grade_code
           , change_date
           , maturity_date
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
           , vendor_id
           , territory_code
        INTO l_description
           , l_vendor_name
           , l_supplier_lot_number
           , l_origination_date
           , l_date_code
           , l_grade_code
           , l_change_date
           , l_maturity_date
           , l_retest_date
           , l_age
           , l_item_size
           , l_color
           , l_volume
           , l_volume_uom
           , l_place_of_origin
           , l_best_by_date
           , l_length
           , l_length_uom
           , l_recycled_content
           , l_thickness
           , l_thickness_uom
           , l_width
           , l_width_uom
           , l_curl_wrinkle_fold
           , l_lot_attribute_category
           , l_c_attribute1
           , l_c_attribute2
           , l_c_attribute3
           , l_c_attribute4
           , l_c_attribute5
           , l_c_attribute6
           , l_c_attribute7
           , l_c_attribute8
           , l_c_attribute9
           , l_c_attribute10
           , l_c_attribute11
           , l_c_attribute12
           , l_c_attribute13
           , l_c_attribute14
           , l_c_attribute15
           , l_c_attribute16
           , l_c_attribute17
           , l_c_attribute18
           , l_c_attribute19
           , l_c_attribute20
           , l_d_attribute1
           , l_d_attribute2
           , l_d_attribute3
           , l_d_attribute4
           , l_d_attribute5
           , l_d_attribute6
           , l_d_attribute7
           , l_d_attribute8
           , l_d_attribute9
           , l_d_attribute10
           , l_n_attribute1
           , l_n_attribute2
           , l_n_attribute3
           , l_n_attribute4
           , l_n_attribute5
           , l_n_attribute6
           , l_n_attribute7
           , l_n_attribute8
           , l_n_attribute9
           , l_n_attribute10
           , l_vendor_id
           , l_territory_code
        FROM mtl_lot_numbers mln, mtl_material_transactions_temp mmtt
       WHERE mln.lot_number = LTRIM(RTRIM(p_lot_number))
         AND mmtt.transaction_temp_id = p_trx_tmp_id
         AND mln.organization_id = mmtt.organization_id
         AND mln.inventory_item_id = mmtt.inventory_item_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    INSERT INTO mtl_transaction_lots_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , transaction_quantity
               , primary_quantity
               , secondary_quantity
               , secondary_unit_of_measure
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
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
               , vendor_id
               , territory_code
	       --Bug No 3952081
	       --Insert OPM attributes
	       , PARENT_LOT_NUMBER
	       , ORIGINATION_TYPE
	       , EXPIRATION_ACTION_DATE
	       , EXPIRATION_ACTION_CODE
	       , HOLD_DATE
                )
         VALUES (
                 p_trx_tmp_id
               , SYSDATE
               , p_user_id
               , SYSDATE
               , p_user_id
               , p_trx_qty
               , p_pri_qty
               , p_secondary_qty
               , p_secondary_uom
               , LTRIM(RTRIM(p_lot_number))
               , p_exp_date
--               , x_ser_trx_id
	       , mtl_material_transactions_s.NEXTVAL
               , NVL(p_description, l_description)
               , NVL(p_vendor_name, l_vendor_name)
               , NVL(p_supplier_lot_number, l_supplier_lot_number)
               , NVL(p_origination_date, l_origination_date)
               , NVL(p_date_code, l_date_code)
               , NVL(p_grade_code, l_grade_code)
               , NVL(p_change_date, l_change_date)
               , NVL(p_maturity_date, l_maturity_date)
               , p_status_id -- This is not attribute column
               , NVL(p_retest_date, l_retest_date)
               , NVL(p_age, l_age)
               , NVL(p_item_size, l_item_size)
               , NVL(p_color, l_color)
               , NVL(p_volume, l_volume)
               , NVL(p_volume_uom, l_volume_uom)
               , NVL(p_place_of_origin, l_place_of_origin)
               , NVL(p_best_by_date, l_best_by_date)
               , NVL(p_length, l_length)
               , NVL(p_length_uom, l_length_uom)
               , NVL(p_recycled_content, l_recycled_content)
               , NVL(p_thickness, l_thickness)
               , NVL(p_thickness_uom, l_thickness_uom)
               , NVL(p_width, l_width)
               , NVL(p_width_uom, l_width_uom)
               , NVL(p_curl_wrinkle_fold, l_curl_wrinkle_fold)
               , NVL(p_lot_attribute_category, l_lot_attribute_category)
               , NVL(p_c_attribute1, l_c_attribute1)
               , NVL(p_c_attribute2, l_c_attribute2)
               , NVL(p_c_attribute3, l_c_attribute3)
               , NVL(p_c_attribute4, l_c_attribute4)
               , NVL(p_c_attribute5, l_c_attribute5)
               , NVL(p_c_attribute6, l_c_attribute6)
               , NVL(p_c_attribute7, l_c_attribute7)
               , NVL(p_c_attribute8, l_c_attribute8)
               , NVL(p_c_attribute9, l_c_attribute9)
               , NVL(p_c_attribute10, l_c_attribute10)
               , NVL(p_c_attribute11, l_c_attribute11)
               , NVL(p_c_attribute12, l_c_attribute12)
               , NVL(p_c_attribute13, l_c_attribute13)
               , NVL(p_c_attribute14, l_c_attribute14)
               , NVL(p_c_attribute15, l_c_attribute15)
               , NVL(p_c_attribute16, l_c_attribute16)
               , NVL(p_c_attribute17, l_c_attribute17)
               , NVL(p_c_attribute18, l_c_attribute18)
               , NVL(p_c_attribute19, l_c_attribute19)
               , NVL(p_c_attribute20, l_c_attribute20)
               , NVL(p_d_attribute1, l_d_attribute1)
               , NVL(p_d_attribute2, l_d_attribute2)
               , NVL(p_d_attribute3, l_d_attribute3)
               , NVL(p_d_attribute4, l_d_attribute4)
               , NVL(p_d_attribute5, l_d_attribute5)
               , NVL(p_d_attribute6, l_d_attribute6)
               , NVL(p_d_attribute7, l_d_attribute7)
               , NVL(p_d_attribute8, l_d_attribute8)
               , NVL(p_d_attribute9, l_d_attribute9)
               , NVL(p_d_attribute10, l_d_attribute10)
               , NVL(p_n_attribute1, l_n_attribute1)
               , NVL(p_n_attribute2, l_n_attribute2)
               , NVL(p_n_attribute3, l_n_attribute3)
               , NVL(p_n_attribute4, l_n_attribute4)
               , NVL(p_n_attribute5, l_n_attribute5)
               , NVL(p_n_attribute6, l_n_attribute6)
               , NVL(p_n_attribute7, l_n_attribute7)
               , NVL(p_n_attribute8, l_n_attribute8)
               , NVL(p_n_attribute9, l_n_attribute9)
               , NVL(p_n_attribute10, l_n_attribute10)
               , NVL(p_vendor_id, l_vendor_id)
               , NVL(p_territory_code, l_territory_code)
	       --Bug 3952081
	       --Use tha passed arguments directly to populate MTLT.
	       , p_parent_lot_number
	       , p_origination_type
	       , p_expriration_action_date
	       , p_expriration_action_code
	       , p_hold_date
                ) RETURNING serial_transaction_temp_id INTO x_ser_trx_id;

    -- Bug# 2032659   Change done till here
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      x_proc_msg  := SUBSTR(SQLERRM, 1, 200);
      RETURN -1;
  END;

  --
  --     Name: INSERT_SER_TRX
  --
  --
  --      Functions: This API inserts a Serial Transaction record into
  --       MTL_SERIAL_NUMBERS_TEMP. The argument p_trx_tmp_id is
  --       used to couple this record with a transaction-line in
  --       MTL_MATERIAL_TRANSACTIONS_TEMP
  --
  FUNCTION insert_ser_trx(
    p_trx_tmp_id                IN            NUMBER
  , p_user_id                   IN            NUMBER
  , p_fm_ser_num                IN            VARCHAR2
  , p_to_ser_num                IN            VARCHAR2
  , p_ven_ser_num               IN            VARCHAR2 := NULL
  , p_vet_lot_num               IN            VARCHAR2 := NULL
  , p_parent_ser_num            IN            VARCHAR2 := NULL
  , p_end_item_unit_num         IN            VARCHAR2 := NULL
  , p_serial_attribute_category IN            VARCHAR2 := NULL
  , p_orgination_date           IN            DATE := NULL
  , p_c_attribute1              IN            VARCHAR2 := NULL
  , p_c_attribute2              IN            VARCHAR2 := NULL
  , p_c_attribute3              IN            VARCHAR2 := NULL
  , p_c_attribute4              IN            VARCHAR2 := NULL
  , p_c_attribute5              IN            VARCHAR2 := NULL
  , p_c_attribute6              IN            VARCHAR2 := NULL
  , p_c_attribute7              IN            VARCHAR2 := NULL
  , p_c_attribute8              IN            VARCHAR2 := NULL
  , p_c_attribute9              IN            VARCHAR2 := NULL
  , p_c_attribute10             IN            VARCHAR2 := NULL
  , p_c_attribute11             IN            VARCHAR2 := NULL
  , p_c_attribute12             IN            VARCHAR2 := NULL
  , p_c_attribute13             IN            VARCHAR2 := NULL
  , p_c_attribute14             IN            VARCHAR2 := NULL
  , p_c_attribute15             IN            VARCHAR2 := NULL
  , p_c_attribute16             IN            VARCHAR2 := NULL
  , p_c_attribute17             IN            VARCHAR2 := NULL
  , p_c_attribute18             IN            VARCHAR2 := NULL
  , p_c_attribute19             IN            VARCHAR2 := NULL
  , p_c_attribute20             IN            VARCHAR2 := NULL
  , p_d_attribute1              IN            DATE := NULL
  , p_d_attribute2              IN            DATE := NULL
  , p_d_attribute3              IN            DATE := NULL
  , p_d_attribute4              IN            DATE := NULL
  , p_d_attribute5              IN            DATE := NULL
  , p_d_attribute6              IN            DATE := NULL
  , p_d_attribute7              IN            DATE := NULL
  , p_d_attribute8              IN            DATE := NULL
  , p_d_attribute9              IN            DATE := NULL
  , p_d_attribute10             IN            DATE := NULL
  , p_n_attribute1              IN            NUMBER := NULL
  , p_n_attribute2              IN            NUMBER := NULL
  , p_n_attribute3              IN            NUMBER := NULL
  , p_n_attribute4              IN            NUMBER := NULL
  , p_n_attribute5              IN            NUMBER := NULL
  , p_n_attribute6              IN            NUMBER := NULL
  , p_n_attribute7              IN            NUMBER := NULL
  , p_n_attribute8              IN            NUMBER := NULL
  , p_n_attribute9              IN            NUMBER := NULL
  , p_n_attribute10             IN            NUMBER := NULL
  , p_status_id                 IN            NUMBER := NULL
  , p_territory_code            IN            VARCHAR2 := NULL
  , p_time_since_new            IN            NUMBER := NULL
  , p_cycles_since_new          IN            NUMBER := NULL
  , p_time_since_overhaul       IN            NUMBER := NULL
  , p_cycles_since_overhaul     IN            NUMBER := NULL
  , p_time_since_repair         IN            NUMBER := NULL
  , p_cycles_since_repair       IN            NUMBER := NULL
  , p_time_since_visit          IN            NUMBER := NULL
  , p_cycles_since_visit        IN            NUMBER := NULL
  , p_time_since_mark           IN            NUMBER := NULL
  , p_cycles_since_mark         IN            NUMBER := NULL
  , p_number_of_repairs         IN            NUMBER := NULL
  , p_validation_level          IN            NUMBER := NULL
  , p_wms_installed             IN            VARCHAR2 := NULL
  , p_quantity                  IN            NUMBER := NULL -- Number of Serials between FROM and TO
  , x_proc_msg                  OUT NOCOPY    VARCHAR2
  , p_attribute_category 	IN	      VARCHAR2 := NULL
  , p_attribute1		IN	      VARCHAR2 := NULL
  , p_attribute2		IN            VARCHAR2 := NULL
  , p_attribute3		IN            VARCHAR2 := NULL
  , p_attribute4		IN            VARCHAR2 := NULL
  , p_attribute5		IN            VARCHAR2 := NULL
  , p_attribute6		IN            VARCHAR2 := NULL
  , p_attribute7		IN            VARCHAR2 := NULL
  , p_attribute8		IN            VARCHAR2 := NULL
  , p_attribute9		IN            VARCHAR2 := NULL
  , p_attribute10		IN            VARCHAR2 := NULL
  , p_attribute11		IN            VARCHAR2 := NULL
  , p_attribute12		IN            VARCHAR2 := NULL
  , p_attribute13		IN            VARCHAR2 := NULL
  , p_attribute14		IN            VARCHAR2 := NULL
  , p_attribute15		IN            VARCHAR2 := NULL
  , p_dffupdatedflag		IN	      VARCHAR2 := NULL
  )
    RETURN NUMBER IS
    l_serial_prefix            NUMBER;
    l_real_serial_prefix       VARCHAR2(30);
    l_serial_numeric_frm       NUMBER;
    l_serial_numeric_to        NUMBER;
    l_number_of_serial_numbers NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number               VARCHAR2(80);
    l_transaction_temp_id      NUMBER; -- transaction temp id of parent row in MMTT
    l_item_id                  NUMBER;
    l_org_id                   NUMBER;
    l_trx_header_id            NUMBER;
    l_serial_trx_tmp_id        NUMBER       := NULL;
    l_err_code                 NUMBER;
    l_trx_type_id              NUMBER;
    l_subinventory_code        VARCHAR2(10);
    l_locator_id               NUMBER;
    l_debug                    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
/*Fixed Bug#6758460 regardless of validation level
  txn temp id should be validated and serial number should be marked
  If customer does not pass validation leverl as full then this API
  does not derive txn temp id and pass null to API serial_check.inv_mark_serial
  This cause serial number to me unmarked and it makes ITS fails with error
  missing serial number error.
*/

/* Uncommented following IF condition for bug 7322274 */
    IF (p_validation_level = fnd_api.g_valid_level_full) THEN
      BEGIN
        SELECT mmtt.transaction_temp_id
             , mmtt.transaction_header_id
             , mmtt.inventory_item_id
             , mmtt.organization_id
             , mmtt.transaction_type_id
             , mmtt.subinventory_code
             , mmtt.locator_id
          INTO l_transaction_temp_id
             , l_trx_header_id
             , l_item_id
             , l_org_id
             , l_trx_type_id
             , l_subinventory_code
             , l_locator_id
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_temp_id = p_trx_tmp_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- both lot and serial controlled, then p_trx_tmp_id is coupled
          -- with a row in MTLT
          BEGIN
            SELECT mmtt.transaction_temp_id
                 , mmtt.transaction_header_id
                 , mmtt.inventory_item_id
                 , mmtt.organization_id
                 , mmtt.transaction_type_id
                 , mmtt.subinventory_code
                 , mmtt.locator_id
                 , mtlt.lot_number
              INTO l_transaction_temp_id
                 , l_trx_header_id
                 , l_item_id
                 , l_org_id
                 , l_trx_type_id
                 , l_subinventory_code
                 , l_locator_id
                 , l_lot_number
              FROM mtl_transaction_lots_temp mtlt, mtl_material_transactions_temp mmtt
             WHERE mtlt.serial_transaction_temp_id = p_trx_tmp_id
               AND mtlt.transaction_temp_id = mmtt.transaction_temp_id;

            l_serial_trx_tmp_id  := p_trx_tmp_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                TRACE('INVALID p_trx_tmp_id', 'INVTRXUB', 9);
              END IF;

              x_proc_msg  := SUBSTR(SQLERRM, 1, 200);
              RETURN -1;
          END;
      END;

      IF (l_debug = 1) THEN
        TRACE('CALCULATED TRX TEMP ID IS :' || l_transaction_temp_id, 'INVTRXUB', 9);
        TRACE('SERIAL TRX TEMP ID IS :' || l_serial_trx_tmp_id, 'INVTRXUB', 9);
      END IF;

      SELECT COUNT(msn.serial_number)
        INTO l_number_of_serial_numbers
        FROM mtl_serial_numbers msn
       WHERE msn.inventory_item_id = l_item_id
         AND msn.serial_number BETWEEN p_fm_ser_num AND p_to_ser_num
         AND LENGTH(msn.serial_number) = LENGTH(p_fm_ser_num)
         AND current_status = 3
         AND msn.current_organization_id = l_org_id
         AND(msn.group_mark_id IS NULL OR msn.group_mark_id <= 0)
         AND msn.current_subinventory_code = l_subinventory_code
         /*Fixed for bug#6758460
           Condition modified to handle the null locator id
           if item is non locator controlled then this condition
           fails and cause group mark id not marked in MSN
         */
         /*AND msn.current_locator_id = l_locator_id*/
         AND  nvl(msn.current_locator_id,-999999) = nvl(l_locator_id,-999999)
         AND(l_lot_number IS NULL OR msn.lot_number = l_lot_number)
         AND(
             inv_material_status_grp.is_status_applicable(
               p_wms_installed
             , NULL -- p_trx_status_enabled
             , l_trx_type_id
             , NULL -- p_lot_status_enabled
             , NULL -- p_serial_status_enabled
             , l_org_id
             , l_item_id
             , l_subinventory_code
             , l_locator_id
             , l_lot_number
             , msn.serial_number
             , 'A'
             ) = 'Y'
            );

      IF (l_debug = 1) THEN
        TRACE('NUMBER OF VALID SERIAL NUMBERS FOUND IS :' || l_number_of_serial_numbers, 'INVTRXUB', 9);
      END IF;

      IF (l_number_of_serial_numbers <> p_quantity) THEN
        IF (l_debug = 1) THEN
          TRACE('validation error: valid serial number quantity does not match', 'INVTRXUB', 9);
        END IF;

        x_proc_msg  := 'valid serial number quantity does not match';
        RETURN -1;
      END IF;
    END IF; /* Uncommented for bug 7322274 */

    /* added as part of bug fix 2527211 */
    l_real_serial_prefix  := RTRIM(p_fm_ser_num, '0123456789');
    l_serial_numeric_frm  := TO_NUMBER(SUBSTR(p_fm_ser_num, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
    l_serial_numeric_to   := TO_NUMBER(SUBSTR(p_to_ser_num, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
    l_serial_prefix       := (l_serial_numeric_to - l_serial_numeric_frm) + 1;

    IF (l_debug = 1) THEN
      TRACE('SERIAL_PREFIX IS :' || l_serial_prefix, 'INVTRXUB', 9);
    END IF;

    /* end of bug fix 2527211 */
    INSERT INTO mtl_serial_numbers_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , vendor_serial_number
               , vendor_lot_number
               , fm_serial_number
               , to_serial_number
               , serial_prefix -- Bug#2527211
               , parent_serial_number
               , end_item_unit_number
               , serial_attribute_category
               , origination_date
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
               , dff_updated_flag
                )
         VALUES (
                 p_trx_tmp_id
               , SYSDATE
               , p_user_id
               , SYSDATE
               , p_user_id
               , p_user_id
               , p_ven_ser_num
               , p_vet_lot_num
               , p_fm_ser_num
               , p_to_ser_num
               , NVL(l_serial_prefix, 1) -- Bug#2527211
               , p_parent_ser_num
               , p_end_item_unit_num
               , p_serial_attribute_category
               , p_orgination_date
               , p_c_attribute1
               , p_c_attribute2
               , p_c_attribute3
               , p_c_attribute4
               , p_c_attribute5
               , p_c_attribute6
               , p_c_attribute7
               , p_c_attribute8
               , p_c_attribute9
               , p_c_attribute10
               , p_c_attribute11
               , p_c_attribute12
               , p_c_attribute13
               , p_c_attribute14
               , p_c_attribute15
               , p_c_attribute16
               , p_c_attribute17
               , p_c_attribute18
               , p_c_attribute19
               , p_c_attribute20
               , p_d_attribute1
               , p_d_attribute2
               , p_d_attribute3
               , p_d_attribute4
               , p_d_attribute5
               , p_d_attribute6
               , p_d_attribute7
               , p_d_attribute8
               , p_d_attribute9
               , p_d_attribute10
               , p_n_attribute1
               , p_n_attribute2
               , p_n_attribute3
               , p_n_attribute4
               , p_n_attribute5
               , p_n_attribute6
               , p_n_attribute7
               , p_n_attribute8
               , p_n_attribute9
               , p_n_attribute10
               , p_status_id
               , p_territory_code
               , p_time_since_new
               , p_cycles_since_new
               , p_time_since_overhaul
               , p_cycles_since_overhaul
               , p_time_since_repair
               , p_cycles_since_repair
               , p_time_since_visit
               , p_cycles_since_visit
               , p_time_since_mark
               , p_cycles_since_mark
               , p_number_of_repairs
	       , p_attribute_category
	       , p_attribute1
               , p_attribute2
               , p_attribute3
               , p_attribute4
               , p_attribute5
               , p_attribute6
               , p_attribute7
               , p_attribute8
               , p_attribute9
               , p_attribute10
               , p_attribute11
               , p_attribute12
               , p_attribute13
               , p_attribute14
               , p_attribute15
	       , p_dffupdatedflag
                );

    -- Populate group_mark_id in MSN for the range of serial passed
    serial_check.inv_mark_serial(
      from_serial_number           => p_fm_ser_num
    , to_serial_number             => p_to_ser_num
    , item_id                      => l_item_id
    , org_id                       => l_org_id
    , hdr_id                       => l_trx_header_id
    , temp_id                      => l_transaction_temp_id
    , lot_temp_id                  => l_serial_trx_tmp_id
    , success                      => l_err_code
    );

    IF (l_err_code >= 0) THEN
      RETURN 0;
    ELSE
      RETURN -1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_proc_msg  := SUBSTR(SQLERRM, 1, 200);
      RETURN -1;
  END;

  /**
    * Creates a New MMTT by copying column values from an Existing MMTT.
    */
  PROCEDURE copy_insert_line_trx(
    x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_new_txn_temp_id          OUT NOCOPY NUMBER
  , p_transaction_temp_id      IN         NUMBER
  , p_transaction_header_id    IN         NUMBER
  , p_inventory_item_id        IN         NUMBER
  , p_revision                 IN         VARCHAR2
  , p_organization_id          IN         NUMBER
  , p_subinventory_code        IN         VARCHAR2
  , p_locator_id               IN         NUMBER
  , p_cost_group_id            IN         NUMBER
  , p_to_organization_id       IN         NUMBER
  , p_to_subinventory_code     IN         VARCHAR2
  , p_to_locator_id            IN         NUMBER
  , p_to_cost_group_id         IN         NUMBER
  , p_txn_qty                  IN         NUMBER
  , p_primary_qty              IN         NUMBER
  , p_sec_txn_qty              IN         NUMBER --INVCONV KKILLAMS
  , p_transaction_uom          IN         VARCHAR2
  , p_lpn_id                   IN         NUMBER
  , p_transfer_lpn_id          IN         NUMBER
  , p_content_lpn_id           IN         NUMBER
  , p_txn_type_id              IN         NUMBER
  , p_txn_action_id            IN         NUMBER
  , p_txn_source_type_id       IN         NUMBER
  , p_transaction_date         IN         DATE
  , p_transaction_source_id    IN         NUMBER
  , p_trx_source_line_id       IN         NUMBER
  , p_move_order_line_id       IN         NUMBER
  , p_reservation_id           IN         NUMBER
  , p_parent_line_id           IN         NUMBER
  , p_pick_slip_number         IN         NUMBER
  , p_wms_task_type            IN         NUMBER
  , p_user_id                  IN         NUMBER
  , p_move_order_header_id     IN         NUMBER
  , p_serial_allocated_flag    IN         VARCHAR2
  , p_operation_plan_id        IN         NUMBER --lezhang
  , p_transaction_status       IN         NUMBER
  ) IS
    l_debug             NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_api_name          VARCHAR2(30) := 'COPY_INSERT_LINE_TRX';
    l_acct_period_id    NUMBER;
    l_open_past_period  BOOLEAN;
    l_transaction_date  DATE;
    l_organization_id   NUMBER;
    l_inventory_item_id NUMBER;
    l_txn_qty           NUMBER;
    l_primary_qty       NUMBER;
    l_new_txn_temp_id   NUMBER;
    l_primary_uom       mtl_system_items.primary_uom_code%TYPE;
    l_transaction_uom   mtl_system_items.primary_uom_code%TYPE;
    l_secondary_uom  varchar2(3);

    CURSOR c_mmtt_info IS
      SELECT mmtt.organization_id, mmtt.inventory_item_id, mmtt.transaction_uom
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id;

    CURSOR c_item_info IS
      SELECT primary_uom_code
        FROM mtl_system_items msi
       WHERE msi.inventory_item_id = l_inventory_item_id
         AND msi.organization_id   = l_organization_id;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      inv_log_util.trace('Creating a new record in MMTT from TxnTempID = ' || p_transaction_temp_id, g_pkg_name || '.' || l_api_name, 5);
    END IF;

    -- Transaction Temp ID has to be passed with a valid value.
    IF p_transaction_temp_id IS NULL OR p_transaction_temp_id = fnd_api.g_miss_num THEN
      IF l_debug = 1 THEN
        inv_log_util.trace('Error: Transaction Temp ID has to be passed', g_pkg_name || '.' || l_api_name, 3);
      END IF;
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Not Nullable columns should not be passed as MissNum or MissChar or MissDate
    IF (    (p_inventory_item_id = fnd_api.g_miss_num OR p_organization_id = fnd_api.g_miss_num)
         OR (p_txn_qty = fnd_api.g_miss_num OR p_primary_qty = fnd_api.g_miss_num OR p_transaction_uom = fnd_api.g_miss_char)
         OR (p_txn_type_id = fnd_api.g_miss_num OR p_txn_action_id = fnd_api.g_miss_num OR p_txn_source_type_id = fnd_api.g_miss_num)
         OR (p_transaction_date = fnd_api.g_miss_date) )
    THEN
      IF l_debug = 1 THEN
        inv_log_util.trace('Error: ItemID, OrgID, PriQty, TxnQty, TxnUOM, TxnTypeID, TxnActionID, TxnSourceTypeID or TxnDate is invalid', g_pkg_name || '.' || l_api_name, 3);
        inv_log_util.trace('Error: The passed value will make the Not NULLABLE column NULL', g_pkg_name || '.' || l_api_name, 3);
      END IF;
      fnd_message.set_name('INV','INV_DATA_ERROR');
      fnd_message.set_token('ENTITY',l_api_name);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Querying MMTT to get some required values.
    IF (p_organization_id IS NULL
        OR (((p_primary_qty IS NULL AND p_txn_qty IS NOT NULL)
             OR (p_primary_qty IS NOT NULL AND p_txn_qty IS NULL))
            AND (p_inventory_item_id IS NULL OR p_transaction_uom IS NULL)))
    THEN
      OPEN c_mmtt_info;
      FETCH c_mmtt_info INTO l_organization_id, l_inventory_item_id, l_transaction_uom;
      IF c_mmtt_info%NOTFOUND THEN
        CLOSE c_mmtt_info;
        IF l_debug = 1 THEN
          inv_log_util.trace('Error: No Record found for the given Transaction Temp ID', g_pkg_name || '.' || l_api_name, 3);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_mmtt_info;
    END IF;

    l_organization_id   := nvl(p_organization_id, l_organization_id);
    l_inventory_item_id := nvl(p_inventory_item_id, l_inventory_item_id);
    l_transaction_date  := nvl(p_transaction_date, SYSDATE);
    l_transaction_uom   := nvl(p_transaction_uom, l_transaction_uom);
    l_txn_qty           := p_txn_qty;
    l_primary_qty       := p_primary_qty;

    -- Open Period Check
    invttmtx.tdatechk(l_organization_id, l_transaction_date, l_acct_period_id, l_open_past_period);
    IF l_acct_period_id = -1 OR l_acct_period_id = 0 THEN
      inv_log_util.trace('Error: Period is not open for the Organization', g_pkg_name || '.' || l_api_name, 3);
      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Conversion between Primary Qty and Transaction Qty
    IF (p_txn_qty IS NOT NULL AND p_primary_qty IS NULL) OR (p_txn_qty IS NULL AND p_primary_qty IS NOT NULL) THEN
      OPEN c_item_info;
      FETCH c_item_info INTO l_primary_uom;
      IF c_item_info%NOTFOUND THEN
        CLOSE c_item_info;
        fnd_message.set_name('INV','INV_INVALID_ITEM_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_item_info;

      IF l_primary_qty IS NULL THEN
        l_primary_qty := inv_convert.inv_um_convert(
                           item_id        => l_inventory_item_id
                         , precision      => NULL
                         , from_quantity  => l_txn_qty
                         , from_unit      => l_transaction_uom
                         , to_unit        => l_primary_uom
                         , from_name      => NULL
                         , to_name        => NULL
                         );
        IF l_primary_qty <= -99999 THEN
          fnd_message.set_name('INV','INV_UOM_CONVERSION_ERROR');
          fnd_message.set_token('UOM1',l_transaction_uom);
          fnd_message.set_token('UOM2',l_primary_uom);
          fnd_message.set_token('MODULE',l_api_name);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_txn_qty IS NULL AND l_primary_qty IS NOT NULL THEN
        l_txn_qty     := inv_convert.inv_um_convert(
                           item_id        => l_inventory_item_id
                         , precision      => NULL
                         , from_quantity  => l_primary_qty
                         , from_unit      => l_primary_uom
                         , to_unit        => l_transaction_uom
                         , from_name      => NULL
                         , to_name        => NULL
                         );
        IF l_txn_qty <= -99999 THEN
          fnd_message.set_name('INV','INV_UOM_CONVERSION_ERROR');
          fnd_message.set_token('UOM1',l_primary_uom);
          fnd_message.set_token('UOM2',l_transaction_uom);
          fnd_message.set_token('MODULE',l_api_name);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    /*Bug#7716563,To fetch secondary_uom_code so as to update child MMTT with secondary_uom_code */
   SELECT secondary_uom_code
    INTO l_secondary_uom
     FROM mtl_system_items msi
     WHERE msi.inventory_item_id =
                     (SELECT decode(l_inventory_item_id, NULL, inventory_item_id, l_inventory_item_id)
                      FROM mtl_material_transactions_temp
                      WHERE transaction_temp_id = p_transaction_temp_id)
           AND msi.organization_id   = l_organization_id;
    SELECT mtl_material_transactions_s.NEXTVAL INTO x_new_txn_temp_id FROM DUAL;

    INSERT INTO mtl_material_transactions_temp(
                  transaction_header_id
                , transaction_temp_id
                , inventory_item_id
                , revision
                , organization_id
                , subinventory_code
                , locator_id
                , cost_group_id
                , transfer_organization
                , transfer_subinventory
                , transfer_to_location
                , transfer_cost_group_id
                , transaction_quantity
                , primary_quantity
                , transaction_uom
                , move_order_header_id
                , move_order_line_id
                , serial_allocated_flag
                , reservation_id
                , lpn_id
                , transfer_lpn_id
                , content_lpn_id
                , transaction_type_id
                , transaction_action_id
                , transaction_source_type_id
                , transaction_source_name
                , transaction_source_id
                , trx_source_line_id
                , trx_source_delivery_id
                , demand_source_header_id
                , demand_source_line
                , demand_source_delivery
                , transaction_cost
                , transaction_date
                , acct_period_id
                , distribution_account_id
                , parent_line_id
                , parent_transaction_temp_id
                , pick_slip_number
                , container_item_id
                , cartonization_id
                , standard_operation_id
                , operation_plan_id
                , wms_task_type
                , wms_task_status
                , task_priority
                , task_group_id
                , transaction_reference
                , requisition_line_id
                , requisition_distribution_id
                , reason_id
                , lot_number
                , lot_expiration_date
                , serial_number
                , receiving_document
                , demand_id
                , rcv_transaction_id
                , move_transaction_id
                , completion_transaction_id
                , schedule_id
                , repetitive_line_id
                , employee_code
                , primary_switch
                , schedule_update_code
                , setup_teardown_code
                , item_ordering
                , negative_req_flag
                , operation_seq_num
                , picking_line_id
                , physical_adjustment_id
                , cycle_count_id
                , rma_line_id
                , customer_ship_id
                , currency_code
                , currency_conversion_rate
                , currency_conversion_type
                , currency_conversion_date
                , ussgl_transaction_code
                , vendor_lot_number
                , encumbrance_account
                , encumbrance_amount
                , ship_to_location
                , shipment_number
                , transfer_cost
                , transportation_cost
                , transportation_account
                , freight_code
                , containers
                , waybill_airbill
                , expected_arrival_date
                , new_average_cost
                , value_change
                , percentage_change
                , material_allocation_temp_id
                , allowed_units_lookup_code
                , wip_entity_type
                , department_id
                , department_code
                , wip_supply_type
                , supply_subinventory
                , supply_locator_id
                , valid_subinventory_flag
                , valid_locator_flag
                , wip_commit_flag
                , shippable_flag
                , posting_flag
                , required_flag
                , process_flag
                , item_segments
                , item_description
                , item_trx_enabled_flag
                , item_location_control_code
                , item_restrict_subinv_code
                , item_restrict_locators_code
                , item_revision_qty_control_code
                , item_primary_uom_code
                , item_uom_class
                , item_shelf_life_code
                , item_shelf_life_days
                , item_lot_control_code
                , item_serial_control_code
                , item_inventory_asset_flag
                , error_code
                , error_explanation
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
                , reservation_quantity
                , shipped_quantity
                , transaction_line_number
                , task_id
                , to_task_id
                , source_task_id
                , project_id
                , source_project_id
                , pa_expenditure_org_id
                , to_project_id
                , expenditure_type
                , final_completion_flag
                , transfer_percentage
                , transaction_sequence_id
                , material_account
                , material_overhead_account
                , resource_account
                , outside_processing_account
                , overhead_account
                , flow_schedule
                , demand_class
                , qa_collection_id
                , kanban_card_id
                , overcompletion_transaction_id
                , overcompletion_primary_qty
                , overcompletion_transaction_qty
                , end_item_unit_number
                , scheduled_payback_date
                , line_type_code
                , put_away_strategy_id
                , put_away_rule_id
                , pick_strategy_id
                , pick_rule_id
                , common_bom_seq_id
                , common_routing_seq_id
                , cost_type_id
                , org_cost_group_id
                , source_code
                , source_line_id
                , transaction_mode
                , lock_flag
                , transaction_status
                , last_update_date
                , last_updated_by
                , creation_date
                , created_by
                , last_update_login
                , request_id
                , program_application_id
                , program_id
                , program_update_date
                , secondary_transaction_quantity --INVCONV kkillams
                , secondary_uom_code       -- Bug#7716563
		)
         SELECT decode(p_transaction_header_id, fnd_api.g_miss_num, NULL, NULL, transaction_header_id, p_transaction_header_id)
              , x_new_txn_temp_id
              , decode(l_inventory_item_id, NULL, inventory_item_id, l_inventory_item_id)
              , decode(p_revision, fnd_api.g_miss_char, NULL, NULL, revision, p_revision)
              , decode(l_organization_id, NULL, organization_id, l_organization_id)
              , decode(p_subinventory_code, fnd_api.g_miss_char, NULL, NULL, subinventory_code, p_subinventory_code)
              , decode(p_locator_id, fnd_api.g_miss_num, NULL, NULL, locator_id, p_locator_id)
              , decode(p_cost_group_id, fnd_api.g_miss_num, NULL, NULL, cost_group_id, p_cost_group_id)
              , decode(p_to_organization_id, fnd_api.g_miss_num, NULL, NULL, transfer_organization, p_to_organization_id)
              , decode(p_to_subinventory_code, fnd_api.g_miss_char, NULL, NULL, transfer_subinventory, p_to_subinventory_code)
              , decode(p_to_locator_id, fnd_api.g_miss_num, NULL, NULL, transfer_to_location, p_to_locator_id)
              , decode(p_to_cost_group_id, fnd_api.g_miss_num, NULL, NULL, transfer_cost_group_id, p_to_cost_group_id)
              , decode(l_txn_qty, NULL, transaction_quantity, l_txn_qty)
              , decode(l_primary_qty, NULL, primary_quantity, l_primary_qty)
              , decode(l_transaction_uom, NULL, transaction_uom, l_transaction_uom)
              , decode(p_move_order_header_id, fnd_api.g_miss_num, NULL, NULL, move_order_header_id, p_move_order_header_id)
              , decode(p_move_order_line_id, fnd_api.g_miss_num, NULL, NULL, move_order_line_id, p_move_order_line_id)
              , decode(p_serial_allocated_flag, fnd_api.g_miss_char, NULL, NULL, serial_allocated_flag, p_serial_allocated_flag)
              , decode(p_reservation_id, fnd_api.g_miss_num, NULL, NULL, reservation_id, p_reservation_id)
              , decode(p_lpn_id, fnd_api.g_miss_num, NULL, NULL, lpn_id, p_lpn_id)
              , decode(p_transfer_lpn_id, fnd_api.g_miss_num, NULL, NULL, transfer_lpn_id, p_transfer_lpn_id)
              , decode(p_content_lpn_id, fnd_api.g_miss_num, NULL, NULL, content_lpn_id, p_content_lpn_id)
              , decode(p_txn_type_id, NULL, transaction_type_id, p_txn_type_id)
              , decode(p_txn_action_id, NULL, transaction_action_id, p_txn_action_id)
              , decode(p_txn_source_type_id, NULL, transaction_source_type_id, p_txn_source_type_id)
              , transaction_source_name
              , decode(p_transaction_source_id, fnd_api.g_miss_num, NULL, NULL, transaction_source_id, p_transaction_source_id)
              , decode(p_trx_source_line_id, fnd_api.g_miss_num, NULL, NULL, trx_source_line_id, p_trx_source_line_id)
              , trx_source_delivery_id
              , decode(p_transaction_source_id, fnd_api.g_miss_num, NULL, NULL, demand_source_header_id, p_transaction_source_id)
              , decode(p_trx_source_line_id, fnd_api.g_miss_num, NULL, NULL, demand_source_line, p_trx_source_line_id)
              , demand_source_delivery
              , transaction_cost
              , l_transaction_date
              , l_acct_period_id
              , distribution_account_id
              , decode(p_parent_line_id, fnd_api.g_miss_num, NULL, NULL, parent_line_id, p_parent_line_id)
              , parent_transaction_temp_id
              , decode(p_pick_slip_number, fnd_api.g_miss_num, NULL, NULL, pick_slip_number, p_pick_slip_number)
              , container_item_id
              , cartonization_id
              , standard_operation_id
              , decode(p_operation_plan_id, fnd_api.g_miss_num, NULL, NULL, operation_plan_id, p_operation_plan_id) --lezhang
              , decode(p_wms_task_type, fnd_api.g_miss_num, NULL, NULL, wms_task_type, p_wms_task_type)
              , wms_task_status
              , task_priority
              , task_group_id
              , transaction_reference
              , requisition_line_id
              , requisition_distribution_id
              , reason_id
              , lot_number
              , lot_expiration_date
              , serial_number
              , receiving_document
              , demand_id
              , rcv_transaction_id
              , move_transaction_id
              , completion_transaction_id
              , schedule_id
              , repetitive_line_id
              , employee_code
              , primary_switch
              , schedule_update_code
              , setup_teardown_code
              , item_ordering
              , negative_req_flag
              , operation_seq_num
              , picking_line_id
              , physical_adjustment_id
              , cycle_count_id
              , rma_line_id
              , customer_ship_id
              , currency_code
              , currency_conversion_rate
              , currency_conversion_type
              , currency_conversion_date
              , ussgl_transaction_code
              , vendor_lot_number
              , encumbrance_account
              , encumbrance_amount
              , ship_to_location
              , shipment_number
              , transfer_cost
              , transportation_cost
              , transportation_account
              , freight_code
              , containers
              , waybill_airbill
              , expected_arrival_date
              , new_average_cost
              , value_change
              , percentage_change
              , material_allocation_temp_id
              , allowed_units_lookup_code
              , wip_entity_type
              , department_id
              , department_code
              , wip_supply_type
              , supply_subinventory
              , supply_locator_id
              , valid_subinventory_flag
              , valid_locator_flag
              , wip_commit_flag
              , shippable_flag
              , posting_flag
              , required_flag
              , process_flag
              , item_segments
              , item_description
              , item_trx_enabled_flag
              , item_location_control_code
              , item_restrict_subinv_code
              , item_restrict_locators_code
              , item_revision_qty_control_code
              , item_primary_uom_code
              , item_uom_class
              , item_shelf_life_code
              , item_shelf_life_days
              , item_lot_control_code
              , item_serial_control_code
              , item_inventory_asset_flag
              , error_code
              , error_explanation
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
              , reservation_quantity
              , shipped_quantity
              , transaction_line_number
              , task_id
              , to_task_id
              , source_task_id
              , project_id
              , source_project_id
              , pa_expenditure_org_id
              , to_project_id
              , expenditure_type
              , final_completion_flag
              , transfer_percentage
              , transaction_sequence_id
              , material_account
              , material_overhead_account
              , resource_account
              , outside_processing_account
              , overhead_account
              , flow_schedule
              , demand_class
              , qa_collection_id
              , kanban_card_id
              , overcompletion_transaction_id
              , overcompletion_primary_qty
              , overcompletion_transaction_qty
              , end_item_unit_number
              , scheduled_payback_date
              , line_type_code
              , put_away_strategy_id
              , put_away_rule_id
              , pick_strategy_id
              , pick_rule_id
              , common_bom_seq_id
              , common_routing_seq_id
              , cost_type_id
              , org_cost_group_id
              , source_code
              , source_line_id
              , transaction_mode
              , lock_flag
              , NVL(p_transaction_status, transaction_status)
              , SYSDATE
              , nvl(p_user_id, fnd_global.user_id)
              , SYSDATE
              , nvl(p_user_id, fnd_global.user_id)
              , last_update_login
              , request_id
              , program_application_id
              , program_id
              , program_update_date
              , decode(p_sec_txn_qty, fnd_api.g_miss_num, NULL, NULL, secondary_transaction_quantity, p_sec_txn_qty) --INVCONV KKILLAMS
	      ,decode(l_secondary_uom, NULL, secondary_uom_code, l_secondary_uom) --Bug#7716563
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_transaction_temp_id;

    IF l_debug = 1 THEN
      inv_log_util.trace('Inserted a new record into MMTT with TxnTempID = ' || x_new_txn_temp_id, g_pkg_name || '.' || l_api_name, 5);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END copy_insert_line_trx;


  --     Name: DELETE_SER_TRX
  --
  --      Functions: This API deletes all records with the input transaction
  --      temp id  from MTL_SERIAL_NUMBERS_TEMP.
  --      It also unmarks these serial numbers in MSN.
  FUNCTION delete_ser_trx(
    p_trx_header_id       IN            NUMBER
  , p_trx_tmp_id          IN            NUMBER
  , p_serial_trx_tmp_id   IN            NUMBER
  , p_serial_control_code IN            NUMBER
  , p_user_id             IN            NUMBER
  , x_proc_msg            OUT NOCOPY    VARCHAR2
  )
    RETURN NUMBER IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    DELETE FROM mtl_serial_numbers_temp
          WHERE transaction_temp_id = NVL(p_serial_trx_tmp_id, p_trx_tmp_id);

    serial_check.inv_unmark_serial(
      from_serial_number           => NULL
    , to_serial_number             => NULL
    , serial_code                  => p_serial_control_code
    , hdr_id                       => p_trx_header_id
    , temp_id                      => p_trx_tmp_id
    , lot_temp_id                  => p_serial_trx_tmp_id
    );
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      x_proc_msg  := SUBSTR(SQLERRM, 1, 200);
      RETURN -1;
  END;

  /*
   *  Procedure: DELETE_TRANSACTION
   *    1. Deletes a MMTT record given the Transaction Temp ID
   *    2. If it is a Lot Controlled Item, cascades the Delete till MTLT
   *    3. If it is a Serial Controlled Item , cascades the Delete till MSNT. Unmarks the Serial.
   *    4. Cascades the delete till WDT. Care should be taked to call the API if the Task is Loaded.
   */
  PROCEDURE delete_transaction(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , p_transaction_temp_id            NUMBER
  , p_update_parent                  BOOLEAN
  ) IS
    l_inventory_item_id   NUMBER;
    l_lot_control_code    NUMBER;
    l_serial_control_code NUMBER;
    l_fm_serial_number    VARCHAR2(30);
    l_to_serial_number    VARCHAR2(30);
    l_unmarked_count      NUMBER       := 0;
    l_parent_line_id      NUMBER;
    l_child_txn_qty       NUMBER;
    l_child_pri_qty       NUMBER;
    l_child_uom           VARCHAR2(3);
    l_txn_hdr_id          NUMBER ; --Bug#6211912

    CURSOR c_item_info IS
      SELECT msi.inventory_item_id, msi.lot_control_code, msi.serial_number_control_code, mmtt.parent_line_id
             ,mmtt.transaction_header_id --Bug#6211912
        FROM mtl_system_items msi, mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id
         AND msi.inventory_item_id = mmtt.inventory_item_id
         AND msi.organization_id = mmtt.organization_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
      TRACE('Cleaning up MMTT, MTLT and MSNT for Txn Temp ID = ' || p_transaction_temp_id, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
    END IF;

    OPEN c_item_info;
    FETCH c_item_info INTO l_inventory_item_id, l_lot_control_code, l_serial_control_code, l_parent_line_id,l_txn_hdr_id;
    CLOSE c_item_info;

    IF l_debug = 1 THEN
      TRACE('Item ID        = ' || l_inventory_item_id, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
      TRACE('Lot Control    = ' || l_lot_control_code, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
      TRACE('Serial Control = ' || l_serial_control_code, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
      TRACE('Parent Line ID = ' || l_parent_line_id, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
    END IF;


    IF l_parent_line_id IS NOT NULL AND p_update_parent THEN
      IF l_debug = 1 THEN
        TRACE('Child Record... Updating the Parent: TxnTempID = ' || l_parent_line_id, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
      END IF;

      update_parent_mmtt(
        x_return_status       => x_return_status
      , p_parent_line_id      => l_parent_line_id
      , p_child_line_id       => p_transaction_temp_id
      , p_lot_control_code    => l_lot_control_code
      , p_serial_control_code => l_serial_control_code
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug = 1 THEN
          TRACE('Error occurred while updating the Parent Record', 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Unmarking and Deleting all the Serials associated with the Transaction
    IF l_serial_control_code IN(2, 5) THEN --If serial controlled
      IF l_lot_control_code = 2 THEN -- If lot controlled also

       UPDATE mtl_serial_numbers
       SET group_mark_id = NULL, line_mark_id = NULL, lot_line_mark_id = NULL
       WHERE group_mark_id  IN (SELECT serial_transaction_temp_id
                                 FROM mtl_transaction_lots_temp
                                 WHERE transaction_temp_id = p_transaction_temp_id
								 UNION ALL
								 select l_txn_hdr_id
								 from dual) ; --Bug#6157372 -- 12419592

        l_unmarked_count := SQL%ROWCOUNT;

        DELETE mtl_serial_numbers_temp
         WHERE transaction_temp_id IN (SELECT serial_transaction_temp_id
                                        FROM mtl_transaction_lots_temp
                                        WHERE transaction_temp_id = p_transaction_temp_id);

      ELSE -- only serial controlled but not lot controlled.

       UPDATE mtl_serial_numbers
       SET group_mark_id = NULL, line_mark_id = NULL, lot_line_mark_id = NULL
       WHERE group_mark_id in (p_transaction_temp_id,l_txn_hdr_id); --Bug#12419592
	   --Bug#6157372

       l_unmarked_count := SQL%ROWCOUNT;

       DELETE mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_transaction_temp_id;

      END IF;

      IF l_debug = 1 THEN
        TRACE('Serials unmarked in MSN = ' || l_unmarked_count, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
        TRACE('Records deleted in MSNT = ' || SQL%ROWCOUNT, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
      END IF;
    END IF;

    -- Deleting all the Lots associated with the Transaction
    IF l_lot_control_code = 2 THEN
      DELETE mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_transaction_temp_id;

      IF l_debug = 1 THEN
        TRACE('Records deleted in MTLT = ' || SQL%ROWCOUNT, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
      END IF;
    END IF;

    -- Deleting the Task
    DELETE wms_dispatched_tasks
     WHERE transaction_temp_id = p_transaction_temp_id;

    IF l_debug = 1 THEN
      TRACE('Records deleted in WDT = ' || SQL%ROWCOUNT, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
    END IF;

    -- Deleting the Transaction
    DELETE mtl_material_transactions_temp
     WHERE transaction_temp_id = p_transaction_temp_id;

    IF l_debug = 1 THEN
      TRACE('Records deleted in MMTT = ' || SQL%ROWCOUNT, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      TRACE('Exception Occurred = ' || SQLERRM, 'INV_TRX_UTIL_PUB.DELETE_TRANSACTION');
  END delete_transaction;

  PROCEDURE delete_lot_ser_trx(
    p_trx_tmp_id    IN            NUMBER
  , p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_lotctrl       IN            NUMBER
  , p_serctrl       IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  ) IS
    CURSOR c_serial(l_txn_tmp_id IN NUMBER) IS
      SELECT fm_serial_number, NVL(to_serial_number, fm_serial_number) to_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = l_txn_tmp_id;

    CURSOR c_lot(l_txn_tmp_id IN NUMBER) IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = l_txn_tmp_id;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    TRACE('parameters passed to delete_lot_ser_trx', 'INVTRXUB', 9);
    TRACE('p_trx_tmp_id = '|| p_trx_tmp_id|| 'p_org_id = '|| p_org_id|| 'p_item_id = '|| p_item_id|| 'p_lotctrl = '|| p_lotctrl|| 'p_serctrl = '|| p_serctrl, 'INVTRXUB', 9);

    IF (p_trx_tmp_id IS NULL) OR(p_org_id IS NULL) OR(p_item_id IS NULL) OR(p_lotctrl IS NULL) OR(p_serctrl IS NULL) THEN
      TRACE('Parameter passed is null...', 'INVTRXUB', 9);
      RAISE fnd_api.g_exc_error;
    END IF;

    IF ((p_serctrl <> 1) AND(p_lotctrl <> 2)) THEN
      --Item is only serial controlled
      FOR c_serial_rec IN c_serial(p_trx_tmp_id) LOOP
        --Now Call inv_unmark_serial
        serial_check.inv_unmark_serial(
          from_serial_number           => c_serial_rec.fm_serial_number
        , to_serial_number             => c_serial_rec.to_serial_number
        , serial_code                  => p_serctrl
        , hdr_id                       => NULL
        , temp_id                      => NULL
        , lot_temp_id                  => NULL
        , p_inventory_item_id          => p_item_id
        );
      END LOOP;
      DELETE FROM mtl_serial_numbers_temp msnt WHERE msnt.transaction_temp_id = p_trx_tmp_id;
    ELSIF((p_serctrl <> 1) AND(p_lotctrl = 2)) THEN
      --Item is lot controlled and serial controlled

      FOR c_lot_rec IN c_lot(p_trx_tmp_id) LOOP
        --Now get the serial txn temp ids

        FOR c_serial_rec IN c_serial(c_lot_rec.serial_transaction_temp_id) LOOP
          --Now call inv_unmark_serial
          serial_check.inv_unmark_serial(
            from_serial_number           => c_serial_rec.fm_serial_number
          , to_serial_number             => c_serial_rec.to_serial_number
          , serial_code                  => p_serctrl
          , hdr_id                       => NULL
          , temp_id                      => NULL
          , lot_temp_id                  => NULL
          , p_inventory_item_id          => p_item_id
          );
        END LOOP;
      END LOOP;

      --Delete records from MSNT and MTLT
      DELETE FROM mtl_serial_numbers_temp msnt
            WHERE msnt.transaction_temp_id IN(
                                SELECT mtlt.serial_transaction_temp_id
                                  FROM mtl_transaction_lots_temp mtlt
                                 WHERE mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
                                   AND mtlt.transaction_temp_id = p_trx_tmp_id);

      DELETE FROM mtl_transaction_lots_temp WHERE transaction_temp_id = p_trx_tmp_id;

    --Item is only lot controlled. Not serial controlled.
    ELSIF(p_serctrl = 1 AND p_lotctrl = 2) THEN

       DELETE mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_trx_tmp_id;


        TRACE('Records deleted in MTLT = ' || SQL%ROWCOUNT, 'INV_TRX_UTIL_PUB.delete_lot_ser_trx');

    END IF;



    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      TRACE('Expected error has occured...', 'INVTRXUB', 9);
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      TRACE('Unexpected error has occured...', 'INVTRXUB', 9);
      TRACE('SQLERRM...' || SUBSTR(SQLERRM, 1, 100), 'INVTRXUB', 9);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END delete_lot_ser_trx;

  /*
   *  Procedure: UPDATE_PARENT_MMTT
   *    This procedure updates or deletes the parent task when one of the child tasks
   *    is deleted. Generally this procedure is called before deleting a Child Record.
   *    1. Parent MMTT Qty is updated if there will be more than one MMTT even after
   *       the deletion of the child record.
   *    2. Parent MMTT is deleted along with the Task when there will be only one MMTT
   *       after the deletion of the child record. Child Tasks will not be dispatched
   *       or Queued.
   */
  PROCEDURE update_parent_mmtt(
    x_return_status       OUT NOCOPY    VARCHAR2
  , p_parent_line_id      IN            NUMBER
  , p_child_line_id       IN            NUMBER
  , p_lot_control_code    IN            NUMBER
  , p_serial_control_code IN            NUMBER
  ) IS
    l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_api_return_status  VARCHAR2(1);
    l_item_id            NUMBER;
    l_child_pri_qty      NUMBER;
    l_child_txn_qty      NUMBER;
	l_child_sec_txn_qty  NUMBER; --BUG12753174

    l_child_uom          VARCHAR2(3);

    l_parent_pri_qty     NUMBER;
    l_parent_uom         VARCHAR2(3);

    l_serials_tbl        inv_globals.varchar_tbl_type;

    l_lot_number         mtl_transaction_lots_temp.lot_number%TYPE; -- added for Bug 11931654


    CURSOR c_child_details IS
      SELECT c.inventory_item_id, c.primary_quantity, c.transaction_quantity, c.secondary_transaction_quantity, c.transaction_uom, p.transaction_uom --BUG12753174
        FROM mtl_material_transactions_temp c, mtl_material_transactions_temp p
       WHERE c.transaction_temp_id = p_child_line_id
         AND p.transaction_temp_id = p_parent_line_id;

	--  Start 1 of Fix for Bug 11931654
    --  adding a cursor to store the lot_number for child record with p_child_line_id as transaction_temp_id in mtl_transaction_lots_temp

    CURSOR c_child_lot_details IS
        SELECT c.lot_number
          FROM mtl_transaction_lots_temp c
         WHERE c.transaction_temp_id = p_child_line_id;

    --  End 1 of Fix of Bug 11931654

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    OPEN c_child_details;
    FETCH c_child_details INTO l_item_id, l_child_pri_qty, l_child_txn_qty, l_child_sec_txn_qty, l_child_uom, l_parent_uom; --BUG12753174
    IF c_child_details%NOTFOUND THEN
      TRACE('Either Parent TxnTempID or Child TxnTempID is invalid', 'INV_TRX_UTIL_PUB.UPDATE_PARENT_MMTT');
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    -- Delete the Serials
    IF p_serial_control_code NOT IN (1,6) THEN
      IF p_lot_control_code = 2 THEN
        DELETE mtl_serial_numbers_temp
         WHERE transaction_temp_id IN (SELECT serial_transaction_temp_id FROM mtl_transaction_lots_temp
                                        WHERE transaction_temp_id = p_parent_line_id)
           AND fm_serial_number IN (SELECT msnt.fm_serial_number
                                      FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
                                     WHERE mtlt.transaction_temp_id = p_child_line_id
                                       AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id)
         RETURNING fm_serial_number BULK COLLECT INTO l_serials_tbl;

        IF SQL%ROWCOUNT = 0 THEN
          DELETE mtl_serial_numbers_temp
           WHERE transaction_temp_id IN (SELECT serial_transaction_temp_id FROM mtl_transaction_lots_temp
                                          WHERE transaction_temp_id = p_parent_line_id)
             AND ROWNUM <= l_child_pri_qty
           RETURNING fm_serial_number BULK COLLECT INTO l_serials_tbl;
        END IF;
      ELSE
        DELETE mtl_serial_numbers_temp
         WHERE transaction_temp_id = p_parent_line_id
          AND fm_serial_number IN (SELECT msnt.fm_serial_number FROM mtl_serial_numbers_temp msnt
                                    WHERE msnt.transaction_temp_id = p_child_line_id)
         RETURNING fm_serial_number BULK COLLECT INTO l_serials_tbl;

        IF SQL%ROWCOUNT = 0 THEN
          DELETE mtl_serial_numbers_temp
           WHERE transaction_temp_id = p_parent_line_id
             AND ROWNUM <= l_child_pri_qty
           RETURNING fm_serial_number BULK COLLECT INTO l_serials_tbl;
        END IF;
      END IF;

      IF l_serials_tbl.COUNT > 0 THEN
        FORALL i IN l_serials_tbl.FIRST..l_serials_tbl.LAST
          UPDATE mtl_serial_numbers
             SET group_mark_id = NULL, line_mark_id = NULL, lot_line_mark_id = NULL
           WHERE inventory_item_id = l_item_id
             AND serial_number = l_serials_tbl(i);
      END IF;
    END IF;

    -- Delete the Lots
    IF p_lot_control_code = 2 THEN

	  -- Start 2 of fix for Bug 11931654
	  OPEN c_child_lot_details;
      LOOP
         FETCH c_child_lot_details INTO l_lot_number;
         EXIT WHEN c_child_lot_details%NOTFOUND;

         UPDATE mtl_transaction_lots_temp p
          SET (p.primary_quantity, p.transaction_quantity, p.secondary_quantity) =
             (SELECT p.primary_quantity - SUM(c.primary_quantity)
                   , p.transaction_quantity - inv_convert.inv_um_convert(l_item_id, NULL, SUM(c.transaction_quantity), l_child_uom, l_parent_uom, NULL, NULL)
				   , p.secondary_quantity - SUM(c.secondary_quantity) --BUG12753174
                FROM mtl_transaction_lots_temp c
               WHERE c.transaction_temp_id = p_child_line_id
      	         AND c.lot_number = l_lot_number
      	       GROUP BY c.lot_number)
         WHERE p.transaction_temp_id = p_parent_line_id AND p.lot_number = l_lot_number;

      END LOOP;
      CLOSE c_child_lot_details;
	  -- End 2 of fix for Bug 11931654

	  /*
	  UPDATE mtl_transaction_lots_temp p
         SET (p.primary_quantity, p.transaction_quantity) =
             (SELECT p.primary_quantity - SUM(c.primary_quantity)
                   , p.transaction_quantity - inv_convert.inv_um_convert(l_item_id, NULL, SUM(c.transaction_quantity), l_child_uom, l_parent_uom, NULL, NULL)
                FROM mtl_transaction_lots_temp c
               WHERE c.transaction_temp_id = p_child_line_id
      	         AND c.lot_number = p.lot_number
      	       GROUP BY c.lot_number)
       WHERE p.transaction_temp_id = p_parent_line_id;
	  */

      DELETE mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_parent_line_id
         AND primary_quantity <= 0;
    END IF;

    IF l_debug = 1 THEN
      TRACE('Updating the Parent Task with Txn Temp ID = ' || p_parent_line_id, 'INV_TRX_UTIL_PUB.UPDATE_PARENT_MMTT');
    END IF;

    UPDATE mtl_material_transactions_temp
       SET transaction_quantity = transaction_quantity - inv_convert.inv_um_convert(inventory_item_id, NULL, l_child_txn_qty, l_child_uom, transaction_uom, NULL, NULL)
         , primary_quantity = primary_quantity - l_child_pri_qty
		 , secondary_transaction_quantity = secondary_transaction_quantity - l_child_sec_txn_qty --BUG12753174
     WHERE transaction_temp_id = p_parent_line_id
     RETURNING primary_quantity INTO l_parent_pri_qty;

    IF l_parent_pri_qty <= 0 THEN
      IF inv_control.get_current_release_level >=
         inv_release.get_j_release_level
      THEN
         IF l_debug = 1 THEN
            TRACE('Checking if parent should be archived:  Txn Temp ID = ' || p_parent_line_id
                 , 'INV_TRX_UTIL_PUB.UPDATE_PARENT_MMTT');
         END IF;

         l_api_return_status := fnd_api.g_ret_sts_success;
         inv_parent_mmtt_pvt.process_parent
         ( x_return_status  => l_api_return_status
         , p_parent_temp_id => p_parent_line_id
         );

         IF l_api_return_status <> fnd_api.g_ret_sts_success
         THEN
            IF l_debug = 1 THEN
               TRACE('Error from inv_parent_mmtt_pvt.process_parent'
                    , 'INV_TRX_UTIL_PUB.UPDATE_PARENT_MMTT');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
         IF l_debug = 1 THEN
           TRACE('Deleting the Parent Task with Txn Temp ID = ' || p_parent_line_id, 'INV_TRX_UTIL_PUB.UPDATE_PARENT_MMTT');
         END IF;

         DELETE wms_dispatched_tasks WHERE transaction_temp_id = p_parent_line_id;
         DELETE mtl_material_transactions_temp WHERE transaction_temp_id = p_parent_line_id;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        TRACE('Unexpected Error occurred - ' || SQLERRM, 'INV_TRX_UTIL_PUB.UPDATE_PARENT_MMTT');
      END IF;
  END update_parent_mmtt;

  /*  Bug 13020024
   *  Procedure: call_rcv_manager
   *    Input Parameters:
   *          p_trx_header_id : Transaction Header Id
   *    Output Parameters:
   *          x_return_status : Return value of calling RCV TM
   *          x_outcome       : Outcome of calling RCV TM
   *          x_msg           : Error message
   *    This procedure is to call RCVTM for IOT in online mode.
   *    1. Fetches MMTs with p_trx_header_id, and update the related RTIs with a new group_id.
   *    2. Make a call to RCVTM with this group_id
   */

  PROCEDURE call_rcv_manager
            ( x_return_value       OUT  NOCOPY   NUMBER,
              x_outcome            OUT  NOCOPY   VARCHAR2,
              x_msg                OUT  NOCOPY   VARCHAR2,
              p_trx_header_id      IN   NUMBER
	           ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;
  l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_group_id    NUMBER;
  l_rpc_timeout NUMBER := 172800;
  l_count       NUMBER;

  BEGIN

    x_return_value := 0;
    x_outcome:= 'SUCCESS';
    x_msg := NULL;

	  IF (l_debug = 1) THEN
        TRACE('*** Entering inv_trx_util_pub.call_rcv_manager. TrxHeaderId='||p_trx_header_id, 'INV_TRX_UTIL_PUB.CALL_RCV_MANAGER');
    END IF;

    IF (p_trx_header_id IS NOT NULL) AND (p_trx_header_id <> -1 ) THEN

       SELECT Count(rti.interface_transaction_id)
         INTO l_count
         FROM rcv_transactions_interface rti
        WHERE rti.processing_status_code = 'RUNNING'
              AND rti.processing_mode_code = 'ONLINE'
              AND rti.transaction_status_code = 'PENDING'
              AND EXISTS
             (SELECT 1
                FROM mtl_material_transactions mmt
               WHERE mmt.transaction_id = rti.inv_transaction_id
                 AND mmt.transaction_set_id = p_trx_header_id );

       IF l_count > 0 THEN

         SELECT rcv_interface_groups_s.NEXTVAL
           INTO l_group_id
           FROM dual;

         UPDATE rcv_transactions_interface rti
            SET group_id = l_group_id
          WHERE rti.processing_status_code = 'RUNNING'
                AND rti.processing_mode_code = 'ONLINE'
                AND rti.transaction_status_code = 'PENDING'
                AND EXISTS
               (SELECT 1
                  FROM mtl_material_transactions mmt
                 WHERE mmt.transaction_id = rti.inv_transaction_id
                   AND mmt.transaction_set_id = p_trx_header_id );

         COMMIT;

         x_return_value := fnd_transaction.synchronous(l_rpc_timeout,x_outcome,x_msg,'PO','RCVTPO','ONLINE',l_group_id, NULL,
                                                       NULL, NULL, NULL, NULL, NULL,NULL, NULL,
                                                       NULL, NULL, NULL, NULL, NULL, NULL,NULL,
                                                       NULL, NULL, NULL);
         COMMIT;


         IF l_debug = 1 THEN
            TRACE('After call rcv manager. GrpId=' || l_group_id ||',retval:'||x_return_value||',outcome:'||x_outcome||',message:'|| x_msg
                , 'INV_TRX_UTIL_PUB.CALL_RCV_MANAGER');
         END IF;

      END IF;

    END IF;

   EXCEPTION
       WHEN OTHERS THEN
         x_return_value := -1;
         x_outcome := 'ERROR';
         x_msg := 'Failed to call Receiving Transaction Processor!';
         IF (l_debug = 1) THEN
            TRACE('Unexpected Error occurred - ' || SQLERRM, 'INV_TRX_UTIL_PUB.CALL_RCV_MANAGER');
         END IF;
   END call_rcv_manager;

END inv_trx_util_pub;

/
