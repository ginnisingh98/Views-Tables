--------------------------------------------------------
--  DDL for Package Body INV_SERIAL_NUMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SERIAL_NUMBER_PUB" AS
  /* $Header: INVPSNB.pls 120.7.12010000.11 2010/07/27 12:10:05 hjogleka ship $*/

  --  Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_SERIAL_NUMBER_PUB';
/* -- Added for DMV Project */
-- Bug# 6825191, Commenting the variables to be obsoleted
--G_first_row_of_trx boolean := true;
--G_first_row_trx_tmp_id number := 0;
l_status_after_p1 NUMBER := 0;
l_status_before_p1 NUMBER := 0;
MSN_UPDATE_FIRST_PASS BOOLEAN := TRUE;

PROCEDURE set_firstscan(p_firstscan IN BOOLEAN) IS
   l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
   g_firstscan  := p_firstscan;
END;

-- Procedure used to trace message for debugging
PROCEDURE invtrace(p_msg VARCHAR2 := NULL) IS
   --Bug: 3772309: Performance bug fix.The fnd call happens everytime
   -- debug_print is called.
   -- l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
   -- IF (l_debug = 1) THEN
   inv_log_util.TRACE(p_msg, 'INVSER', 9);
   --  END IF;
END;

PROCEDURE populateattributescolumn IS
   l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
   g_serial_attributes_tbl(1).column_name   := 'SERIAL_ATTRIBUTE_CATEGORY';
   g_serial_attributes_tbl(1).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(2).column_name   := 'ORIGINATION_DATE';
   g_serial_attributes_tbl(2).column_type   := 'DATE';
   g_serial_attributes_tbl(3).column_name   := 'C_ATTRIBUTE1';
   g_serial_attributes_tbl(3).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(4).column_name   := 'C_ATTRIBUTE2';
   g_serial_attributes_tbl(4).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(5).column_name   := 'C_ATTRIBUTE3';
   g_serial_attributes_tbl(5).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(6).column_name   := 'C_ATTRIBUTE4';
   g_serial_attributes_tbl(6).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(7).column_name   := 'C_ATTRIBUTE5';
   g_serial_attributes_tbl(7).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(8).column_name   := 'C_ATTRIBUTE6';
   g_serial_attributes_tbl(8).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(9).column_name   := 'C_ATTRIBUTE7';
   g_serial_attributes_tbl(9).column_type   := 'VARCHAR2';
   g_serial_attributes_tbl(10).column_name  := 'C_ATTRIBUTE8';
   g_serial_attributes_tbl(10).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(11).column_name  := 'C_ATTRIBUTE9';
   g_serial_attributes_tbl(11).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(12).column_name  := 'C_ATTRIBUTE10';
   g_serial_attributes_tbl(12).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(13).column_name  := 'C_ATTRIBUTE11';
   g_serial_attributes_tbl(13).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(14).column_name  := 'C_ATTRIBUTE12';
   g_serial_attributes_tbl(14).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(15).column_name  := 'C_ATTRIBUTE13';
   g_serial_attributes_tbl(15).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(16).column_name  := 'C_ATTRIBUTE14';
   g_serial_attributes_tbl(16).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(17).column_name  := 'C_ATTRIBUTE15';
   g_serial_attributes_tbl(17).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(18).column_name  := 'C_ATTRIBUTE16';
   g_serial_attributes_tbl(18).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(19).column_name  := 'C_ATTRIBUTE17';
   g_serial_attributes_tbl(19).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(20).column_name  := 'C_ATTRIBUTE18';
   g_serial_attributes_tbl(20).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(21).column_name  := 'C_ATTRIBUTE19';
   g_serial_attributes_tbl(21).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(22).column_name  := 'C_ATTRIBUTE20';
   g_serial_attributes_tbl(22).column_type  := 'VARCHAR2';
   g_serial_attributes_tbl(23).column_name  := 'D_ATTRIBUTE1';
   g_serial_attributes_tbl(23).column_type  := 'DATE';
   g_serial_attributes_tbl(24).column_name  := 'D_ATTRIBUTE2';
   g_serial_attributes_tbl(24).column_type  := 'DATE';
   g_serial_attributes_tbl(25).column_name  := 'D_ATTRIBUTE3';
   g_serial_attributes_tbl(25).column_type  := 'DATE';
   g_serial_attributes_tbl(26).column_name  := 'D_ATTRIBUTE4';
   g_serial_attributes_tbl(26).column_type  := 'DATE';
   g_serial_attributes_tbl(27).column_name  := 'D_ATTRIBUTE5';
   g_serial_attributes_tbl(27).column_type  := 'DATE';
   g_serial_attributes_tbl(28).column_name  := 'D_ATTRIBUTE6';
   g_serial_attributes_tbl(28).column_type  := 'DATE';
   g_serial_attributes_tbl(29).column_name  := 'D_ATTRIBUTE7';
   g_serial_attributes_tbl(29).column_type  := 'DATE';
   g_serial_attributes_tbl(30).column_name  := 'D_ATTRIBUTE8';
   g_serial_attributes_tbl(30).column_type  := 'DATE';
   g_serial_attributes_tbl(31).column_name  := 'D_ATTRIBUTE9';
   g_serial_attributes_tbl(31).column_type  := 'DATE';
   g_serial_attributes_tbl(32).column_name  := 'D_ATTRIBUTE10';
   g_serial_attributes_tbl(32).column_type  := 'DATE';
   g_serial_attributes_tbl(33).column_name  := 'N_ATTRIBUTE1';
   g_serial_attributes_tbl(33).column_type  := 'NUMBER';
   g_serial_attributes_tbl(34).column_name  := 'N_ATTRIBUTE2';
   g_serial_attributes_tbl(34).column_type  := 'NUMBER';
   g_serial_attributes_tbl(35).column_name  := 'N_ATTRIBUTE3';
   g_serial_attributes_tbl(35).column_type  := 'NUMBER';
   g_serial_attributes_tbl(36).column_name  := 'N_ATTRIBUTE4';
   g_serial_attributes_tbl(36).column_type  := 'NUMBER';
   g_serial_attributes_tbl(37).column_name  := 'N_ATTRIBUTE5';
   g_serial_attributes_tbl(37).column_type  := 'NUMBER';
   g_serial_attributes_tbl(38).column_name  := 'N_ATTRIBUTE6';
   g_serial_attributes_tbl(38).column_type  := 'NUMBER';
   g_serial_attributes_tbl(39).column_name  := 'N_ATTRIBUTE7';
   g_serial_attributes_tbl(39).column_type  := 'NUMBER';
   g_serial_attributes_tbl(40).column_name  := 'N_ATTRIBUTE8';
   g_serial_attributes_tbl(40).column_type  := 'NUMBER';
   g_serial_attributes_tbl(41).column_name  := 'N_ATTRIBUTE9';
   g_serial_attributes_tbl(41).column_type  := 'NUMBER';
   g_serial_attributes_tbl(42).column_name  := 'N_ATTRIBUTE10';
   g_serial_attributes_tbl(42).column_type  := 'NUMBER';
   g_serial_attributes_tbl(43).column_name  := 'STATUS_ID';
   g_serial_attributes_tbl(43).column_type  := 'NUMBER';
   g_serial_attributes_tbl(44).column_name  := 'TERRITORY_CODE';
   g_serial_attributes_tbl(44).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(45).column_name   := 'ATTRIBUTE_CATEGORY';
	g_serial_attributes_tbl(45).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(46).column_name   := 'ATTRIBUTE1';
	g_serial_attributes_tbl(46).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(47).column_name   := 'ATTRIBUTE2';
	g_serial_attributes_tbl(47).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(48).column_name   := 'ATTRIBUTE3';
	g_serial_attributes_tbl(48).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(49).column_name   := 'ATTRIBUTE4';
	g_serial_attributes_tbl(49).column_type   := 'VARCHAR2';
	g_serial_attributes_tbl(50).column_name   := 'ATTRIBUTE5';
	g_serial_attributes_tbl(50).column_type   := 'VARCHAR2';
	g_serial_attributes_tbl(51).column_name   := 'ATTRIBUTE6';
	g_serial_attributes_tbl(51).column_type   := 'VARCHAR2';
	g_serial_attributes_tbl(52).column_name   := 'ATTRIBUTE7';
	g_serial_attributes_tbl(52).column_type   := 'VARCHAR2';
	g_serial_attributes_tbl(53).column_name  := 'ATTRIBUTE8';
	g_serial_attributes_tbl(53).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(54).column_name  := 'ATTRIBUTE9';
	g_serial_attributes_tbl(54).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(55).column_name  := 'ATTRIBUTE10';
	g_serial_attributes_tbl(55).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(56).column_name  := 'ATTRIBUTE11';
	g_serial_attributes_tbl(56).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(57).column_name  := 'ATTRIBUTE12';
	g_serial_attributes_tbl(57).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(58).column_name  := 'ATTRIBUTE13';
	g_serial_attributes_tbl(58).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(59).column_name  := 'ATTRIBUTE14';
	g_serial_attributes_tbl(59).column_type  := 'VARCHAR2';
	g_serial_attributes_tbl(60).column_name  := 'ATTRIBUTE15';
	g_serial_attributes_tbl(60).column_type  := 'VARCHAR2';
END;

-- OverLoaded Procedure insertSerial for eAM
PROCEDURE insertserial
  (
   p_api_version         IN            NUMBER
   , p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false
   , p_commit              IN            VARCHAR2 := fnd_api.g_false
   , p_validation_level    IN            NUMBER := fnd_api.g_valid_level_full
   , p_inventory_item_id   IN            NUMBER
   , p_organization_id     IN            NUMBER
   , p_serial_number       IN            VARCHAR2
   , p_current_status      IN            NUMBER
   , p_group_mark_id       IN            NUMBER
   , p_lot_number          IN            VARCHAR2
   , p_initialization_date IN            DATE DEFAULT SYSDATE
   , x_return_status       OUT NOCOPY    VARCHAR2
   , x_msg_count           OUT NOCOPY    NUMBER
   , x_msg_data            OUT NOCOPY    VARCHAR2
   , p_organization_type   IN            NUMBER DEFAULT NULL
   , p_owning_org_id       IN            NUMBER DEFAULT NULL
   , p_owning_tp_type      IN            NUMBER DEFAULT NULL
   , p_planning_org_id     IN            NUMBER DEFAULT NULL
  , p_planning_tp_type    IN            NUMBER DEFAULT NULL
  ) IS
     l_api_version CONSTANT NUMBER         := 1.0;
     l_api_name    CONSTANT VARCHAR2(30)   := 'insertSerial';
     l_userid               NUMBER;
     l_loginid              NUMBER;
     l_serial_control_code  NUMBER;
     l_return_status        VARCHAR2(1);
     l_msg_data             VARCHAR2(2000);
     l_msg_count            NUMBER;
     isunique               NUMBER;
     item_count             NUMBER;
     eam_item               NUMBER;
     l_current_status       NUMBER;
     x_object_id            NUMBER;
     l_debug                NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT apiinsertserial_apipub;

   -- Standard call to check for call compatibility.
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   --  Initialize API return status to success
   -- API body

   --Block for Organization Validation
    BEGIN
       SELECT 1
         INTO item_count
         FROM mtl_parameters
         WHERE organization_id = p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          item_count  := 0;
       WHEN OTHERS THEN
          --Bug 3153585:Raising exception to populate error message correctly.
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
             fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'insertSerial');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (item_count = 0) THEN
       fnd_message.set_name('INV', 'INV_INVALID_ORGANIZATION');
       fnd_msg_pub.ADD;
       --Bug 3153585:Raising exception to populate error message correctly.
       RAISE fnd_api.g_exc_error;
    END IF;

    -- Block to check the Serial Control Code
    BEGIN
       SELECT serial_number_control_code
         , eam_item_type
         INTO l_serial_control_code
         , eam_item
         FROM mtl_system_items
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;

       IF (l_serial_control_code = 1
           AND is_serial_tagged(p_inventory_item_id,p_organization_id,NULL) = 1) THEN
          fnd_message.set_name('INV', 'INV_ITEM_NOT_SERIAL_CONTROLLED');
          fnd_msg_pub.ADD;
          --Bug 3153585:Raising exception to populate error message correctly.
          RAISE fnd_api.g_exc_error;
       END IF;

       IF eam_item IS NULL THEN
          l_current_status  := 1;
        ELSE
          l_current_status  := p_current_status;
       END IF;
    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          RAISE fnd_api.g_exc_error;
          --Bug 3153585:Raising exception to populate error message correctly.
       WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_INVALID_ITEM');
          fnd_msg_pub.ADD;
          --Bug 3153585:Raising exception to populate error message correctly.
          RAISE fnd_api.g_exc_error;
       WHEN OTHERS THEN
          --Bug 3152585:Raising Exception to populate error message correctly.
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
             fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'insertSerial');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
    END;

    SELECT mtl_gen_object_id_s.NEXTVAL
      INTO x_object_id
      FROM DUAL;

    l_userid         := fnd_global.user_id;
    l_loginid        := fnd_global.login_id;
    isunique         := is_serial_unique(p_organization_id, p_inventory_item_id, p_serial_number, x_msg_data);

    IF (isunique = 0) THEN
       INSERT INTO mtl_serial_numbers
         (
          inventory_item_id
          , serial_number
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by
          , last_update_login
          , current_status
          , current_organization_id
          , group_mark_id
          , gen_object_id
          , lot_number
          , initialization_date
          , organization_type
          , owning_organization_id
          , owning_tp_type
          , planning_organization_id
          , planning_tp_type
          )
         VALUES (
                 p_inventory_item_id
                 , p_serial_number
                 , SYSDATE
                 , l_userid
                 , SYSDATE
                 , l_userid
                 , l_loginid
                 , l_current_status
                 , p_organization_id
                 , p_group_mark_id
                 , x_object_id
                 , p_lot_number
                 , p_initialization_date
                 , NVL(p_organization_type, 2)
                 , NVL(p_owning_org_id, p_organization_id)
                 , NVL(p_owning_tp_type, 2)
                 , NVL(p_planning_org_id, p_organization_id)
                 , NVL(p_planning_tp_type, 2)
                  );
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- End of API body.
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO apiinsertserial_apipub;
      --Bug 3153585:Populating the message from the message stack
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      --Bug 3153585:Populating the message from the message stack
      ROLLBACK TO apiinsertserial_apipub;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      ROLLBACK TO apiinsertserial_apipub;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'insertSerial');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END insertserial;

  -- 'Serial Tracking in WIP project. insert wip_entity_id, operation_seq_num and intraoperation_step_type
  -- into MSN.
  PROCEDURE insertserial(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_serial_number            IN            VARCHAR2
  , p_initialization_date      IN            DATE
  , p_completion_date          IN            DATE
  , p_ship_date                IN            DATE
  , p_revision                 IN            VARCHAR2
  , p_lot_number               IN            VARCHAR2
  , p_current_locator_id       IN            NUMBER
  , p_subinventory_code        IN            VARCHAR2
  , p_trx_src_id               IN            NUMBER
  , p_unit_vendor_id           IN            NUMBER
  , p_vendor_lot_number        IN            VARCHAR2
  , p_vendor_serial_number     IN            VARCHAR2
  , p_receipt_issue_type       IN            NUMBER
  , p_txn_src_id               IN            NUMBER
  , p_txn_src_name             IN            VARCHAR2
  , p_txn_src_type_id          IN            NUMBER
  , p_transaction_id           IN            NUMBER
  , p_current_status           IN            NUMBER
  , p_parent_item_id           IN            NUMBER
  , p_parent_serial_number     IN            VARCHAR2
  , p_cost_group_id            IN            NUMBER
  , p_transaction_action_id    IN            NUMBER
  , p_transaction_temp_id      IN            NUMBER
  , p_status_id                IN            NUMBER
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_organization_type        IN            NUMBER DEFAULT NULL
  , p_owning_org_id            IN            NUMBER DEFAULT NULL
  , p_owning_tp_type           IN            NUMBER DEFAULT NULL
  , p_planning_org_id          IN            NUMBER DEFAULT NULL
  , p_planning_tp_type         IN            NUMBER DEFAULT NULL
  --Serial Tracking in WIP project
  , p_wip_entity_id            IN            NUMBER DEFAULT NULL
  , p_operation_seq_num        IN            NUMBER DEFAULT NULL
  , p_intraoperation_step_type IN            NUMBER DEFAULT NULL
  ) IS
    l_api_version     CONSTANT NUMBER                                             := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)                                       := 'insertSerial';
    l_userid                   NUMBER;
    l_loginid                  NUMBER;
    l_serial_control_code      NUMBER;
    l_attributes_default       inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_attributes_default_count NUMBER;
    l_attributes_in            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_column_idx               BINARY_INTEGER                                     := 44;
    l_return_status            VARCHAR2(1);
    l_msg_data                 VARCHAR2(2000);
    l_msg_count                NUMBER;
    l_status_rec               inv_material_status_pub.mtl_status_update_rec_type;
    l_status_id                NUMBER                                             := NULL;
    l_lot_status_enabled       VARCHAR2(1);
    l_default_lot_status_id    NUMBER                                             := NULL;
    l_serial_status_enabled    VARCHAR2(1);
    l_default_serial_status_id NUMBER;
    l_wms_installed            BOOLEAN;

    CURSOR serial_temp_csr(p_transaction_temp_id NUMBER) IS
      SELECT serial_attribute_category
           , fnd_date.date_to_canonical(origination_date)
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
           , fnd_date.date_to_canonical(d_attribute1)
           , fnd_date.date_to_canonical(d_attribute2)
           , fnd_date.date_to_canonical(d_attribute3)
           , fnd_date.date_to_canonical(d_attribute4)
           , fnd_date.date_to_canonical(d_attribute5)
           , fnd_date.date_to_canonical(d_attribute6)
           , fnd_date.date_to_canonical(d_attribute7)
           , fnd_date.date_to_canonical(d_attribute8)
           , fnd_date.date_to_canonical(d_attribute9)
           , fnd_date.date_to_canonical(d_attribute10)
           , TO_CHAR(n_attribute1)
           , TO_CHAR(n_attribute2)
           , TO_CHAR(n_attribute3)
           , TO_CHAR(n_attribute4)
           , TO_CHAR(n_attribute5)
           , TO_CHAR(n_attribute6)
           , TO_CHAR(n_attribute7)
           , TO_CHAR(n_attribute8)
           , TO_CHAR(n_attribute9)
           , TO_CHAR(n_attribute10)
           , status_id
           , territory_code
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_transaction_temp_id
         AND p_serial_number BETWEEN fm_serial_number AND NVL(to_serial_number, fm_serial_number);

    l_input_idx                BINARY_INTEGER;
    l_debug                    NUMBER                                             := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT apiinsertserial_apipub;

    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('In insertserial() procedure. ', 'INV_SERIAL_NUMBER_PUB', 9);
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /** ssia we don't need this if condition **/
    /*IF (p_transaction_action_id = 3 AND g_firstscan = FALSE) THEN*/
    /*** ssia note end ****/
    x_return_status  := fnd_api.g_ret_sts_success;

    /**ELSE**/
    BEGIN
      SELECT serial_number_control_code
        INTO l_serial_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;

      -- invtrace('serial_number_control_code is ' || l_serial_control_code);
      IF (l_serial_control_code = 1
           AND is_serial_tagged(p_inventory_item_id,p_organization_id,NULL) = 1) THEN
        -- invtrace('serial_control_code is 1.there is no serial control.');
        fnd_message.set_name('INV', 'INV_ITEM_NOT_SERIAL_CONTROLLED');
        fnd_msg_pub.ADD;
        --Bug 3153585:Populating the message from the message stack
        RAISE fnd_api.g_exc_error;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_INVALID_ITEM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    SELECT mtl_gen_object_id_s.NEXTVAL
      INTO x_object_id
      FROM DUAL;

    -- invtrace('next genealogy object id from the sequence mtl_gen_object_id_s is ' || x_object_id);
    l_wms_installed  :=
      wms_install.check_install(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => NULL   --p_organization_id
      );
    -- bug 2771342/2768690
    -- Moved this line before the if statement so that this code is
    -- called for the else part of the if statement too.
    populateattributescolumn();

    -- invtrace('wms is installed?' || l_wms_installed);
    IF (p_transaction_temp_id IS NOT NULL) THEN
      -- invtrace('transaction_temp_id is not null. It is  ' || p_transaction_temp_id);
      OPEN serial_temp_csr(p_transaction_temp_id);

      --populateattributescolumn();
      FETCH serial_temp_csr
       INTO g_serial_attributes_tbl(1).column_value
          , g_serial_attributes_tbl(2).column_value
          , g_serial_attributes_tbl(3).column_value
          , g_serial_attributes_tbl(4).column_value
          , g_serial_attributes_tbl(5).column_value
          , g_serial_attributes_tbl(6).column_value
          , g_serial_attributes_tbl(7).column_value
          , g_serial_attributes_tbl(8).column_value
          , g_serial_attributes_tbl(9).column_value
          , g_serial_attributes_tbl(10).column_value
          , g_serial_attributes_tbl(11).column_value
          , g_serial_attributes_tbl(12).column_value
          , g_serial_attributes_tbl(13).column_value
          , g_serial_attributes_tbl(14).column_value
          , g_serial_attributes_tbl(15).column_value
          , g_serial_attributes_tbl(16).column_value
          , g_serial_attributes_tbl(17).column_value
          , g_serial_attributes_tbl(18).column_value
          , g_serial_attributes_tbl(19).column_value
          , g_serial_attributes_tbl(20).column_value
          , g_serial_attributes_tbl(21).column_value
          , g_serial_attributes_tbl(22).column_value
          , g_serial_attributes_tbl(23).column_value
          , g_serial_attributes_tbl(24).column_value
          , g_serial_attributes_tbl(25).column_value
          , g_serial_attributes_tbl(26).column_value
          , g_serial_attributes_tbl(27).column_value
          , g_serial_attributes_tbl(28).column_value
          , g_serial_attributes_tbl(29).column_value
          , g_serial_attributes_tbl(30).column_value
          , g_serial_attributes_tbl(31).column_value
          , g_serial_attributes_tbl(32).column_value
          , g_serial_attributes_tbl(33).column_value
          , g_serial_attributes_tbl(34).column_value
          , g_serial_attributes_tbl(35).column_value
          , g_serial_attributes_tbl(36).column_value
          , g_serial_attributes_tbl(37).column_value
          , g_serial_attributes_tbl(38).column_value
          , g_serial_attributes_tbl(39).column_value
          , g_serial_attributes_tbl(40).column_value
          , g_serial_attributes_tbl(41).column_value
          , g_serial_attributes_tbl(42).column_value
          , g_serial_attributes_tbl(43).column_value
          , g_serial_attributes_tbl(44).column_value;

      CLOSE serial_temp_csr;

      IF l_wms_installed THEN
        -- invtrace('wms is installed ');
        l_input_idx  := 0;

        FOR x IN 1 .. 44 LOOP
          IF (g_serial_attributes_tbl(x).column_value IS NOT NULL) THEN
            l_input_idx                                := l_input_idx + 1;
            -- invtrace('in serial attributes loop. input_idx is ' || l_input_idx);
            l_attributes_in(l_input_idx).column_name   := g_serial_attributes_tbl(x).column_name;
            -- invtrace('l_attributes_in(l_input_idx).column_name is ' || l_attributes_in(l_input_idx).column_name);
            l_attributes_in(l_input_idx).column_type   := g_serial_attributes_tbl(x).column_type;
            -- invtrace('l_attributes_in(l_input_idx).column_type is ' || l_attributes_in(l_input_idx).column_type);
            l_attributes_in(l_input_idx).column_value  := g_serial_attributes_tbl(x).column_value;
          -- invtrace('l_attributes_in(l_input_idx).column_value is ' || l_attributes_in(l_input_idx).column_value);
          END IF;
        END LOOP;
      END IF;   -- if wms installed is true
    END IF;   -- if transaction_Temp_id is not null

        ----------------------------------------------------------
        -- call inv_lot_sel_attr.get_default to get the default value
        -- of the lot attributes
        ---------------------------------------------------------
    -- invtrace('calling inv_lot_sel_attr.get_default to get the default value of lot attributes');
    IF l_wms_installed THEN
      inv_lot_sel_attr.get_default(
        x_attributes_default         => l_attributes_default
      , x_attributes_default_count   => l_attributes_default_count
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_table_name                 => 'MTL_SERIAL_NUMBERS'
      , p_attributes_name            => 'Serial Attributes'
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_lot_serial_number          => p_serial_number
      , p_attributes                 => l_attributes_in
      );

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        x_return_status  := l_return_status;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_attributes_default_count > 0) THEN
        FOR i IN 1 .. l_attributes_default_count LOOP
          FOR j IN 1 .. g_serial_attributes_tbl.COUNT LOOP
            IF (l_attributes_default(i).column_name = g_serial_attributes_tbl(j).column_name) THEN
              g_serial_attributes_tbl(j).column_value  := l_attributes_default(i).column_value;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;   -- end if of wms install is true

    --END IF; -- delete this since we don't need the if condition to set the l_return_status
    l_userid         := fnd_global.user_id;
    l_loginid        := fnd_global.login_id;

    -- invtrace('transaction_action_id is ' || p_transaction_action_id);
    IF (p_transaction_action_id = 3
        AND g_firstscan = FALSE) THEN
      -- invtrace(' inserting into MSN values ');
       ---------#-#-#-#get the values later
      INSERT INTO mtl_serial_numbers
                  (
                   inventory_item_id
                 , serial_number
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , initialization_date
                 , completion_date
                 , ship_date
                 , current_status
                 , revision
                 , lot_number
                 , fixed_asset_tag
                 , reserved_order_id
                 , parent_item_id
                 , parent_serial_number
                 , original_wip_entity_id
                 , original_unit_vendor_id
                 , vendor_serial_number
                 , vendor_lot_number
                 , last_txn_source_type_id
                 , last_transaction_id
                 , last_receipt_issue_type
                 , last_txn_source_name
                 , last_txn_source_id
                 , descriptive_text
                 , current_subinventory_code
                 , current_locator_id
                 , current_organization_id
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
                 , group_mark_id
                 , line_mark_id
                 , lot_line_mark_id
                 , end_item_unit_number
                 , gen_object_id
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
                 , cost_group_id
                 , organization_type
                 , owning_organization_id
                 , owning_tp_type
                 , planning_organization_id
                 , planning_tp_type
                 , wip_entity_id
                 , operation_seq_num
                 , intraoperation_step_type
                  )
        SELECT inventory_item_id
             , serial_number
             , SYSDATE
             , l_userid
             , SYSDATE
             , l_userid
             , l_loginid
             , request_id
             , program_application_id
             , program_id
             , program_update_date
             , initialization_date
             , completion_date
             , ship_date
             , current_status
             , revision
             , lot_number
             , fixed_asset_tag
             , reserved_order_id
             , parent_item_id
             , parent_serial_number
             , original_wip_entity_id
             , original_unit_vendor_id
             , vendor_serial_number
             , vendor_lot_number
             , last_txn_source_type_id
             , p_transaction_id
             , last_receipt_issue_type
             , p_txn_src_name
             , p_txn_src_id
             , descriptive_text
             , p_subinventory_code
             , p_current_locator_id
             , p_organization_id
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
             , group_mark_id
             , line_mark_id
             , lot_line_mark_id
             , end_item_unit_number
             , x_object_id
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
             , inv_cost_group_pub.g_cost_group_id
             , NVL(p_organization_type, 2)
             , NVL(p_owning_org_id, p_organization_id)
             , NVL(p_owning_tp_type, 2)
             , NVL(p_planning_org_id, p_organization_id)
             , NVL(p_planning_tp_type, 2)
             , wip_entity_id
             , operation_seq_num
             , intraoperation_step_type
          FROM mtl_serial_numbers
         WHERE serial_number = p_serial_number
           AND current_organization_id = g_transfer_org_id
           AND inventory_item_id = p_inventory_item_id
           AND NOT EXISTS(
                SELECT NULL
                  FROM mtl_serial_numbers sn
                 WHERE sn.serial_number = p_serial_number
                   AND sn.current_organization_id = p_organization_id
                   AND sn.inventory_item_id = p_inventory_item_id);

      -- prepare to insert the initial status to the status history table
      -- bug 1870120
      SELECT status_id
        INTO l_status_id
        FROM mtl_serial_numbers
       WHERE serial_number = p_serial_number
         AND current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;
    -- invtrace('l_status_id from MSN when serial_number = ' || p_serial_number || ' current_organization_id = ' || p_organization_id || 'inventory_item_id = ' || p_inventory_item_id);
    ELSE
      /** Populate Serial Attribute Category info. **/
      IF (l_wms_installed) THEN
        -- invtrace('wms is installed. Calling inv_lot_sel_attr.get_context_code');
        inv_lot_sel_attr.get_context_code(g_serial_attributes_tbl(1).column_value, p_organization_id, p_inventory_item_id
        , 'Serial Attributes');
      ELSE
        -- invtrace('wms is not installed. populating all the column values in the g_serial_attributes_tbl with null value');
        g_serial_attributes_tbl(1).column_value  := NULL;
      END IF;

      -- if the p_status_id is null, then default the status if it is
      -- specified in the mtl_system_items
      -- invtrace('p_status_id is ' || p_status_id);
      IF p_status_id IS NULL THEN
        -- invtrace('p_status_id is null. calling inv_material_status_grp.get_lot_serial_status_control');
        inv_material_status_grp.get_lot_serial_status_control(
          p_organization_id            => p_organization_id
        , p_inventory_item_id          => p_inventory_item_id
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_lot_status_enabled         => l_lot_status_enabled
        , x_default_lot_status_id      => l_default_lot_status_id
        , x_serial_status_enabled      => l_serial_status_enabled
        , x_default_serial_status_id   => l_default_serial_status_id
        );

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          x_return_status  := l_return_status;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF (NVL(l_serial_status_enabled, 'Y') = 'Y') THEN
          l_status_id  := l_default_serial_status_id;
        END IF;
      ELSE
        l_status_id  := p_status_id;
      END IF;

      -- invtrace('inserting into MSN values');
      INSERT INTO mtl_serial_numbers
                  (
                   inventory_item_id
                 , serial_number
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , initialization_date
                 , completion_date
                 , ship_date
                 , current_status
                 , revision
                 , lot_number
                 , fixed_asset_tag
                 , reserved_order_id
                 , parent_item_id
                 , parent_serial_number
                 , original_wip_entity_id
                 , original_unit_vendor_id
                 , vendor_serial_number
                 , vendor_lot_number
                 , last_txn_source_type_id
                 , last_transaction_id
                 , last_receipt_issue_type
                 , last_txn_source_name
                 , last_txn_source_id
                 , descriptive_text
                 , current_subinventory_code
                 , current_locator_id
                 , current_organization_id
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
                 , group_mark_id
                 , line_mark_id
                 , lot_line_mark_id
                 , end_item_unit_number
                 , gen_object_id
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
                 , cost_group_id
                 , organization_type
                 , owning_organization_id
                 , owning_tp_type
                 , planning_organization_id
                 , planning_tp_type
                 , wip_entity_id
                 , operation_seq_num
                 , intraoperation_step_type
                  )
           VALUES (
                   p_inventory_item_id
                 , p_serial_number
                 , SYSDATE
                 , l_userid
                 , SYSDATE
                 , l_userid
                 , l_loginid
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , p_initialization_date
                 , p_completion_date
                 , p_ship_date
                 , p_current_status
                 , p_revision
                 , p_lot_number
                 , NULL
                 , NULL
                 , p_parent_item_id
                 , p_parent_serial_number
                 , p_trx_src_id
                 , p_unit_vendor_id
                 , p_vendor_serial_number
                 , p_vendor_lot_number
                 , p_txn_src_type_id
                 , p_transaction_id
                 , p_receipt_issue_type
                 , p_txn_src_name
                 , p_txn_src_id
                 , g_serial_attributes_tbl(31).column_value
                 , p_subinventory_code
                 , p_current_locator_id
                 , p_organization_id
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , x_object_id
                 , g_serial_attributes_tbl(1).column_value
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(2).column_value)
                 , g_serial_attributes_tbl(3).column_value
                 , g_serial_attributes_tbl(4).column_value
                 , g_serial_attributes_tbl(5).column_value
                 , g_serial_attributes_tbl(6).column_value
                 , g_serial_attributes_tbl(7).column_value
                 , g_serial_attributes_tbl(8).column_value
                 , g_serial_attributes_tbl(9).column_value
                 , g_serial_attributes_tbl(10).column_value
                 , g_serial_attributes_tbl(11).column_value
                 , g_serial_attributes_tbl(12).column_value
                 , g_serial_attributes_tbl(13).column_value
                 , g_serial_attributes_tbl(14).column_value
                 , g_serial_attributes_tbl(15).column_value
                 , g_serial_attributes_tbl(16).column_value
                 , g_serial_attributes_tbl(17).column_value
                 , g_serial_attributes_tbl(18).column_value
                 , g_serial_attributes_tbl(19).column_value
                 , g_serial_attributes_tbl(20).column_value
                 , g_serial_attributes_tbl(21).column_value
                 , g_serial_attributes_tbl(22).column_value
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(23).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(24).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(25).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(26).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(27).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(28).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(29).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(30).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(31).column_value)
                 , fnd_date.canonical_to_date(g_serial_attributes_tbl(32).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(33).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(34).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(35).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(36).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(37).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(38).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(39).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(40).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(41).column_value)
                 , TO_NUMBER(g_serial_attributes_tbl(42).column_value)
                 , l_status_id
                 , g_serial_attributes_tbl(44).column_value
                 , inv_cost_group_pub.g_cost_group_id
                 , NVL(p_organization_type, 2)
                 , NVL(p_owning_org_id, p_organization_id)
                 , NVL(p_owning_tp_type, 2)
                 , NVL(p_planning_org_id, p_organization_id)
                 , NVL(p_planning_tp_type, 2)
                 , p_wip_entity_id
                 , p_operation_seq_num
                 , p_intraoperation_step_type
                  );
    -- invtrace(' p_inventory_item_id  ' || p_inventory_item_id);
    -- invtrace(', p_serial_number ' || p_serial_number);
    -- invtrace(' last_update_date ' || SYSDATE);
    -- invtrace('last updated by' || l_userid);
    -- invtrace('creation_date ' || SYSDATE);
    -- invtrace(' created_by ' ||l_userid);
    -- invtrace('last_update_login ' || l_loginid);
    -- invtrace('request_id ' || NULL);
    -- invtrace('program application id is NULL ');
             -- invtrace('program id is NULL');
             -- invtrace('program update date is  NULL');
             -- invtrace('initialization_date is ' || p_initialization_date);
             -- invtrace('completion_date is ' || p_completion_date);
             -- invtrace('ship date is ' || p_ship_date);
             -- invtrace('current status is ' || p_current_status);
             -- invtrace('revision is ' || p_revision);
             -- invtrace('lot number is ' || p_lot_number);
             -- invtrace('fixed asset tag is NULL');
             -- invtrace('reserved order id is NULL');
             -- invtrace('parent item id is '|| p_parent_item_id);
             -- invtrace('parent_serial_number is ' || p_parent_serial_number);
             -- invtrace('trx_src_id is ' ||p_trx_src_id);
             -- invtrace('p_unit_vendor_id is ' ||p_unit_vendor_id);
             -- invtrace('p_vendor_serial_number is ' || p_vendor_serial_number);
             -- invtrace('p_vendor_lot_number is ' || p_vendor_lot_number);
             -- invtrace('p_txn_src_type_id  is ' || p_txn_src_type_id);
             -- invtrace('p_transaction_id is ' || p_transaction_id);
             -- invtrace('p_receipt_issue_type ' || p_receipt_issue_type);
             -- invtrace('p_txn_src_name is ' || p_txn_src_name);
             -- invtrace('p_txn_src_id is ' || p_txn_src_id);
             -- invtrace('g_serial_attributes_tbl(31).column_value is ' || g_serial_attributes_tbl(31).column_value);
             -- invtrace('p_subinventory_code is ' || p_subinventory_code);
             -- invtrace('p_current_locator_id is ' || p_current_locator_id);
             -- invtrace('current organization_id is '|| p_organization_id);
             -- invtrace('attribute category is NULL');
             -- invtrace(' attributes 1 to 15 are NULL');
             -- invtrace('group mark id is NULL');
             -- invtrace('line mark_id is NULL');
             -- invtrace('lot_linemark_id is  NULL');
             -- invtrace('end item unit number is NULL');
             -- invtrace('gen_object_id is ' ||x_object_id);
             -- invtrace('serial attribute category is ' || g_serial_attributes_tbl(1).column_value);
             -- invtrace('origination date is ' || fnd_date.canonical_to_date(g_serial_attributes_tbl(2).column_value));
             -- invtrace('c_attribute1 '|| g_serial_attributes_tbl(3).column_value);
             -- invtrace('cattribute2 ' || g_serial_attributes_tbl(4).column_value);
             -- invtrace('cattribute3 ' ||g_serial_attributes_tbl(5).column_value);
             -- invtrace('cattribute4 ' ||g_serial_attributes_tbl(6).column_value);
             -- invtrace('cattribute5 ' ||g_serial_attributes_tbl(7).column_value);
             -- invtrace('cattribute6 ' ||g_serial_attributes_tbl(8).column_value);
             -- invtrace('cattribute7 ' ||g_serial_attributes_tbl(9).column_value);
             -- invtrace('cattribute8 ' ||g_serial_attributes_tbl(10).column_value);
             -- invtrace('cattribute9 ' ||g_serial_attributes_tbl(11).column_value);
             -- invtrace('cattribute10 ' ||g_serial_attributes_tbl(12).column_value);
             -- invtrace('cattribute11 ' ||g_serial_attributes_tbl(13).column_value);
             -- invtrace('cattribute12 ' ||g_serial_attributes_tbl(14).column_value);
             -- invtrace('cattribute13 ' ||g_serial_attributes_tbl(15).column_value);
             -- invtrace('cattribute14 ' ||g_serial_attributes_tbl(16).column_value);
             -- invtrace('cattribute15 ' ||g_serial_attributes_tbl(17).column_value);
             -- invtrace('cattribute16 ' ||g_serial_attributes_tbl(18).column_value);
             -- invtrace('cattribute17 ' ||g_serial_attributes_tbl(19).column_value);
             -- invtrace('cattribute18 ' ||g_serial_attributes_tbl(20).column_value);
             -- invtrace('cattribute19 ' ||g_serial_attributes_tbl(21).column_value);
             -- invtrace('cattribute20 ' ||g_serial_attributes_tbl(22).column_value);
             -- invtrace('dattribute1 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(23).column_value));
             -- invtrace('dattribute2 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(24).column_value));
             -- invtrace('dattribute3 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(25).column_value));
             -- invtrace('dattribute4 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(26).column_value));
             -- invtrace('dattribute5 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(27).column_value));
             -- invtrace('dattribute6 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(28).column_value));
             -- invtrace('dattribute7 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(29).column_value));
             -- invtrace('dattribute8 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(30).column_value));
             -- invtrace('dattribute9 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(31).column_value));
             -- invtrace('dattribute10 ' ||fnd_date.canonical_to_date(g_serial_attributes_tbl(32).column_value));
             -- invtrace('nattribute1 ' ||TO_NUMBER(g_serial_attributes_tbl(33).column_value));
             -- invtrace('nattribute2 ' ||TO_NUMBER(g_serial_attributes_tbl(34).column_value));
             -- invtrace('nattribute3 ' ||TO_NUMBER(g_serial_attributes_tbl(35).column_value));
             -- invtrace('nattribute4 ' ||TO_NUMBER(g_serial_attributes_tbl(36).column_value));
             -- invtrace('nattribute5 ' ||TO_NUMBER(g_serial_attributes_tbl(37).column_value));
             -- invtrace('nattribute6 ' ||TO_NUMBER(g_serial_attributes_tbl(38).column_value));
             -- invtrace('nattribute7 ' ||TO_NUMBER(g_serial_attributes_tbl(39).column_value));
             -- invtrace('nattribute8 ' ||TO_NUMBER(g_serial_attributes_tbl(40).column_value));
             -- invtrace('nattribute9 ' ||TO_NUMBER(g_serial_attributes_tbl(41).column_value));
             -- invtrace('nattribute10 ' ||TO_NUMBER(g_serial_attributes_tbl(42).column_value));
             -- invtrace('status id is ' ||l_status_id);
             -- invtrace('territory code is ' || g_serial_attributes_tbl(44).column_value);
             -- invtrace('cost group id is ' ||inv_cost_group_pub.g_cost_group_id);
             -- invtrace('organization type is ' ||NVL(p_organization_type, 2));
             -- invtrace('owning org id ' ||NVL(p_owning_org_id, p_organization_id));
             -- invtrace('owning tp type ' ||NVL(p_owning_tp_type, 2));
             -- invtrace('planning org id is ' ||NVL(p_planning_org_id, p_organization_id));
             -- invtrace('planning tp type is ' ||NVL(p_planning_tp_type, 2));
             -- invtrace('wip entity id is ' || p_wip_entity_id);
             -- invtrace('operation_seq_num is ' || p_operation_seq_num);
             -- invtrace('intraoperation_step_type is ' || p_intraoperation_step_type);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- insert into the status history table for bug 1870120
    IF (l_status_id IS NOT NULL) THEN
      l_status_rec.update_method        := inv_material_status_pub.g_update_method_auto;
      l_status_rec.organization_id      := p_organization_id;
      l_status_rec.inventory_item_id    := p_inventory_item_id;
      l_status_rec.serial_number        := p_serial_number;
      l_status_rec.status_id            := l_status_id;
      l_status_rec.initial_status_flag  := 'Y';
      inv_material_status_pkg.insert_status_history(l_status_rec);
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO apiinsertserial_apipub;
      --Bug 3153585:Populating x_msg_data from message stack
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      ROLLBACK TO apiinsertserial_apipub;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'insertSerial');
      END IF;

      --Bug 3153585:Populating x_msg_data from message stack
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END insertserial;

  PROCEDURE insert_range_serial(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id     IN            NUMBER
  , p_organization_id       IN            NUMBER
  , p_from_serial_number    IN            VARCHAR2
  , p_to_serial_number      IN            VARCHAR2
  , p_initialization_date   IN            DATE
  , p_completion_date       IN            DATE
  , p_ship_date             IN            DATE
  , p_revision              IN            VARCHAR2
  , p_lot_number            IN            VARCHAR2
  , p_current_locator_id    IN            NUMBER
  , p_subinventory_code     IN            VARCHAR2
  , p_trx_src_id            IN            NUMBER
  , p_unit_vendor_id        IN            NUMBER
  , p_vendor_lot_number     IN            VARCHAR2
  , p_vendor_serial_number  IN            VARCHAR2
  , p_receipt_issue_type    IN            NUMBER
  , p_txn_src_id            IN            NUMBER
  , p_txn_src_name          IN            VARCHAR2
  , p_txn_src_type_id       IN            NUMBER
  , p_transaction_id        IN            NUMBER
  , p_current_status        IN            NUMBER
  , p_parent_item_id        IN            NUMBER
  , p_parent_serial_number  IN            VARCHAR2
  , p_cost_group_id         IN            NUMBER
  , p_transaction_action_id IN            NUMBER
  , p_transaction_temp_id   IN            NUMBER
  , p_status_id             IN            NUMBER
  , p_inspection_status     IN            NUMBER
  , x_object_id             OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_organization_type     IN            NUMBER DEFAULT NULL
  , p_owning_org_id         IN            NUMBER DEFAULT NULL
  , p_owning_tp_type        IN            NUMBER DEFAULT NULL
  , p_planning_org_id       IN            NUMBER DEFAULT NULL
  , p_planning_tp_type      IN            NUMBER DEFAULT NULL
  , p_rcv_serial_flag       IN            VARCHAR2 DEFAULT NULL
  ) IS
    l_from_ser_number      NUMBER;
    l_to_ser_number        NUMBER;
    l_range_numbers        NUMBER;
    l_temp_prefix          VARCHAR2(30);
    l_cur_serial_number    VARCHAR2(30);
    l_cur_ser_number       NUMBER;
    l_object_id            NUMBER;
    l_return_status        VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_current_status       NUMBER;
    l_group_mark_id        NUMBER;
    l_api_version CONSTANT NUMBER         := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)   := 'insert_range_serial';
    l_debug                NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- invtrace('INV_SERIAL_NUMBER_PUB', 'insert_range_serial - 10');
    SAVEPOINT sp_insert_range_serial;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- get the number part of the from serial
    inv_validate.number_from_sequence(p_from_serial_number, l_temp_prefix, l_from_ser_number);
    -- get the number part of the to serial
    inv_validate.number_from_sequence(p_to_serial_number, l_temp_prefix, l_to_ser_number);
    -- total number of serials inserted into mtl_serial_numbers
    l_range_numbers  := l_to_ser_number - l_from_ser_number + 1;

    FOR i IN 1 .. l_range_numbers LOOP
      l_cur_ser_number  := l_from_ser_number + i - 1;

      -- concatenate the serial number to be inserted
      IF (l_from_ser_number = -1
          AND l_to_ser_number = -1) THEN
        l_cur_serial_number  := p_from_serial_number;
      ELSE
        l_cur_serial_number  := SUBSTR(p_from_serial_number, 1, LENGTH(p_from_serial_number) - LENGTH(l_cur_ser_number))
                                || l_cur_ser_number;
      END IF;

      -- check the status code and group_mark_id
      BEGIN
        SELECT current_status
             , NVL(group_mark_id, -1)
          INTO l_current_status
             , l_group_mark_id
          FROM mtl_serial_numbers
         WHERE serial_number = l_cur_serial_number
           AND inventory_item_id = p_inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_current_status  := -1;
          l_group_mark_id   := -2;
        WHEN OTHERS THEN
          NULL;
      END;

      --invtrace('INV_SERIAL_NUMBER_PUB', '  l_cur_serial_number, l_current_status AND l_group_mark_id  ' || l_cur_serial_number || ' ' || l_current_status
      -- || '   :   ' || l_group_mark_id);

      /* Bug #1767236
       * When the status is 4 (out of stores) then update the status do not insert
       */
      IF (l_current_status = 1
          AND l_group_mark_id = -1)
         OR(l_current_status = 4
            AND l_group_mark_id = -1)
         OR(l_current_status = 6
            AND l_group_mark_id = -1) THEN

        -- Bug 5385315, Update the current_organization_id to p_organization_id
        -- in mtl_serial_numbers while updating the current_status from 4 to 1.

        IF (p_current_status = 1 AND l_current_status = 4) THEN
           -- pre-defined serial, update status
           UPDATE mtl_serial_numbers
             SET current_status = p_current_status
               , inspection_status = p_inspection_status
               , lpn_id = null --bug 5152103
               , current_organization_id = p_organization_id
           WHERE serial_number = l_cur_serial_number
             AND inventory_item_id = p_inventory_item_id;
        ELSE
          -- pre-defined serial, update status
          UPDATE mtl_serial_numbers
             SET current_status = p_current_status
               , inspection_status = p_inspection_status
--             , lpn_id = decode(p_current_status,1,decode(current_status,4,null,lpn_id),lpn_id) --bug 5152103
           WHERE serial_number = l_cur_serial_number
             AND inventory_item_id = p_inventory_item_id;
        END IF;
      /* FP-J Lot/Serial Support Enhancement - Check for serial uniqueness
       * when the current status is Resides in receiving(7) also
       */
      ELSIF (l_current_status <> 5)
            OR(l_current_status = 5
               AND l_group_mark_id > 0)
            OR(l_current_status = 7
               AND l_group_mark_id > 0) THEN
        -- Need to do uniqueness check here.
        -- If any serial is in use, then discard the entire range insertion.
        IF is_serial_unique(p_org_id      => p_organization_id, p_item_id => p_inventory_item_id, p_serial => l_cur_serial_number
           , x_proc_msg                   => l_msg_data) = 1 THEN
          fnd_message.set_name('INV', 'INV_SERIAL_USED');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          -- invtrace('INV_SERIAL_NUMBER_PUB', 'insert_range_serial - 60');
          -- uniqueness check passed
          -- and it is not a pre-defined serial
          inv_serial_number_pub.insertserial(
            p_api_version                => p_api_version
          , p_init_msg_list              => p_init_msg_list
          , p_commit                     => p_commit
          , p_validation_level           => p_validation_level
          , p_inventory_item_id          => p_inventory_item_id
          , p_organization_id            => p_organization_id
          , p_serial_number              => l_cur_serial_number
          , p_initialization_date        => p_initialization_date
          , p_completion_date            => p_completion_date
          , p_ship_date                  => p_ship_date
          , p_revision                   => p_revision
          , p_lot_number                 => p_lot_number
          , p_current_locator_id         => p_current_locator_id
          , p_subinventory_code          => p_subinventory_code
          , p_trx_src_id                 => p_trx_src_id
          , p_unit_vendor_id             => p_unit_vendor_id
          , p_vendor_lot_number          => p_vendor_lot_number
          , p_vendor_serial_number       => p_vendor_serial_number
          , p_receipt_issue_type         => p_receipt_issue_type
          , p_txn_src_id                 => p_txn_src_id
          , p_txn_src_name               => p_txn_src_name
          , p_txn_src_type_id            => p_txn_src_type_id
          , p_transaction_id             => p_transaction_id
          , p_current_status             => p_current_status
          , p_parent_item_id             => p_parent_item_id
          , p_parent_serial_number       => p_parent_serial_number
          , p_cost_group_id              => p_cost_group_id
          , p_transaction_action_id      => p_transaction_action_id
          , p_transaction_temp_id        => p_transaction_temp_id
          , p_status_id                  => p_status_id
          , x_object_id                  => l_object_id
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_organization_type          => p_organization_type
          , p_owning_org_id              => p_owning_org_id
          , p_owning_tp_type             => p_owning_tp_type
          , p_planning_org_id            => p_planning_org_id
          , p_planning_tp_type           => p_planning_tp_type
          );

          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name('INV', 'INV_SERIAL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed and this API is called from
       * the Mobile receiving UI, then we should only attach the revision and
       * lot number to the serial if it was newly created above (in which case
       * the current status of the serial would be defined but not used)
       * We should not be updating any other columns for the serial number
       * For this case, the flag p_rcv_serial_flag would have the value 'Y'
       *
       * If WMS or PO J are not installed or this API is called from other
       * routines, then updates to the serial number are retained
       */
      IF (NVL(p_rcv_serial_flag, 'N') <> 'Y') THEN
        UPDATE mtl_serial_numbers
           SET inspection_status = p_inspection_status
             , lot_number = p_lot_number
             , revision = p_revision
             , current_organization_id = p_organization_id
             , organization_type = NVL(p_organization_type, 2)
             , owning_organization_id = NVL(p_owning_org_id, p_organization_id)
             , owning_tp_type = NVL(p_owning_tp_type, 2)
             , planning_organization_id = NVL(p_planning_org_id, p_organization_id)
             , planning_tp_type = NVL(p_planning_tp_type, 2)
         WHERE serial_number = l_cur_serial_number
           AND inventory_item_id = p_inventory_item_id;
      ELSE
        UPDATE mtl_serial_numbers
           SET lot_number = p_lot_number
             , revision = p_revision
         WHERE serial_number = l_cur_serial_number
           AND inventory_item_id = p_inventory_item_id
           AND current_status IN(1, 4, 5, 6);
      END IF;
    END LOOP;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- End of API body
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO sp_insert_range_serial;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_insert_range_serial;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO sp_insert_range_serial;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END insert_range_serial;

  PROCEDURE updateserial(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_serial_number            IN            VARCHAR2
  , p_initialization_date      IN            DATE
  , p_completion_date          IN            DATE
  , p_ship_date                IN            DATE
  , p_revision                 IN            VARCHAR2
  , p_lot_number               IN            VARCHAR2
  , p_current_locator_id       IN            NUMBER
  , p_subinventory_code        IN            VARCHAR2
  , p_trx_src_id               IN            NUMBER
  , p_unit_vendor_id           IN            NUMBER
  , p_vendor_lot_number        IN            VARCHAR2
  , p_vendor_serial_number     IN            VARCHAR2
  , p_receipt_issue_type       IN            NUMBER
  , p_txn_src_id               IN            NUMBER
  , p_txn_src_name             IN            VARCHAR2
  , p_txn_src_type_id          IN            NUMBER
  , p_current_status           IN            NUMBER
  , p_parent_item_id           IN            NUMBER
  , p_parent_serial_number     IN            VARCHAR2
  , p_serial_temp_id           IN            NUMBER
  , p_last_status              IN            NUMBER
  , p_status_id                IN            NUMBER
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_organization_type        IN            NUMBER DEFAULT NULL
  , p_owning_org_id            IN            NUMBER DEFAULT NULL
  , p_owning_tp_type           IN            NUMBER DEFAULT NULL
  , p_planning_org_id          IN            NUMBER DEFAULT NULL
  , p_planning_tp_type         IN            NUMBER DEFAULT NULL
  , p_transaction_action_id    IN            NUMBER DEFAULT NULL
  , p_wip_entity_id            IN            NUMBER DEFAULT NULL
  , p_operation_seq_num        IN            NUMBER DEFAULT NULL
  , p_intraoperation_step_type IN            NUMBER DEFAULT NULL
  , p_line_mark_id             IN            NUMBER DEFAULT NULL
  ) IS
    l_api_version      CONSTANT NUMBER         := 1.0;
    l_api_name         CONSTANT VARCHAR2(30)   := 'updateSerial';
    l_userid                    NUMBER;
    l_loginid                   NUMBER;
    l_serial_attribute_category VARCHAR2(150);
    l_origination_date          DATE;
    l_c_attribute1              VARCHAR2(150);
    l_c_attribute2              VARCHAR2(150);
    l_c_attribute3              VARCHAR2(150);
    l_c_attribute4              VARCHAR2(150);
    l_c_attribute5              VARCHAR2(150);
    l_c_attribute6              VARCHAR2(150);
    l_c_attribute7              VARCHAR2(150);
    l_c_attribute8              VARCHAR2(150);
    l_c_attribute9              VARCHAR2(150);
    l_c_attribute10             VARCHAR2(150);
    l_c_attribute11             VARCHAR2(150);
    l_c_attribute12             VARCHAR2(150);
    l_c_attribute13             VARCHAR2(150);
    l_c_attribute14             VARCHAR2(150);
    l_c_attribute15             VARCHAR2(150);
    l_c_attribute16             VARCHAR2(150);
    l_c_attribute17             VARCHAR2(150);
    l_c_attribute18             VARCHAR2(150);
    l_c_attribute19             VARCHAR2(150);
    l_c_attribute20             VARCHAR2(150);
    l_d_attribute1              DATE;
    l_d_attribute2              DATE;
    l_d_attribute3              DATE;
    l_d_attribute4              DATE;
    l_d_attribute5              DATE;
    l_d_attribute6              DATE;
    l_d_attribute7              DATE;
    l_d_attribute8              DATE;
    l_d_attribute9              DATE;
    l_d_attribute10             DATE;
    l_n_attribute1              NUMBER;
    l_n_attribute2              NUMBER;
    l_n_attribute3              NUMBER;
    l_n_attribute4              NUMBER;
    l_n_attribute5              NUMBER;
    l_n_attribute6              NUMBER;
    l_n_attribute7              NUMBER;
    l_n_attribute8              NUMBER;
    l_n_attribute9              NUMBER;
    l_n_attribute10             NUMBER;
    l_territory_code            VARCHAR2(150);
    l_wms_installed             BOOLEAN;
    l_return_status             VARCHAR2(1);
    l_msg_data                  VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_group_mark_id             NUMBER;

    CURSOR l_serial_attr_csr(p_serial_temp_id NUMBER) IS
      SELECT serial_attribute_category
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
           , territory_code
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_serial_temp_id
         AND p_serial_number BETWEEN fm_serial_number AND NVL(to_serial_number, fm_serial_number);

    l_debug                     NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT apiupdateserial_apipub;

    IF (l_debug = 1) THEN
       invtrace('*** Inside UpdateSerial ****');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- API body

    IF (l_debug = 1) THEN
       invtrace('CurStat =' || p_current_status || ',CG=' ||
                inv_cost_group_pub.g_cost_group_id || ',lastStat=' ||
                p_last_status || 'p_wip_entity_id = ' || p_wip_entity_id ||
                'SerialNumber = ' || p_serial_number);
    END IF;
    l_userid         := fnd_global.user_id;
    l_loginid        := fnd_global.login_id;

    -- Get serial-attributes only if the last-state of serialNumber
    -- is 'Defined But Not Used' (1) or 'Dynamically generated' (6)
    IF p_wip_entity_id IS NOT NULL THEN
      l_group_mark_id  := p_wip_entity_id;
    ELSE
      l_group_mark_id  := NULL;
    END IF;

    IF (p_last_status = 1)
       OR(p_last_status = 6) THEN
      l_wms_installed  :=
        wms_install.check_install(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data
        , p_organization_id            => p_organization_id);

      IF (l_wms_installed AND p_serial_temp_id IS NOT NULL) THEN
        -- invtrace('wms is installed... opening l_serial_attr_csr with serial_temp_id as '|| p_serial_temp_id);
        OPEN l_serial_attr_csr(p_serial_temp_id);

        FETCH l_serial_attr_csr
         INTO l_serial_attribute_category
            , l_origination_date
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
            , l_territory_code;
      --END IF;

      -- invtrace('updating MSN with values ');
      -- invtrace('current_status '|| p_current_status);
           -- invtrace('initialization_date '|| initialization_date);
           -- invtrace('completion_date '|| p_completion_date);
           -- invtrace('ship_date '|| p_ship_date);
           -- invtrace('revision '|| p_revision);
           -- invtrace('lot_number '|| p_lot_number);
           -- do not update group mark id for staging transfer vipartha
           -- invtrace('group_mark_id '|| DECODE(p_transaction_action_id, 28, group_mark_id, NULL));
           -- invtrace('line_mark_id '|| NULL);
           -- invtrace('lot_line_mark_id '|| NULL);
           -- invtrace('current_organization_id '|| p_organization_id);
           -- invtrace('organization_type '|| NVL(p_organization_type, 2));
           -- invtrace('owning_organization_id '|| NVL(p_owning_org_id, p_organization_id));
           -- invtrace('owning_tp_type '|| NVL(p_owning_tp_type, 2));
           -- invtrace('planning_organization_id '|| NVL(p_planning_org_id, p_organization_id));
           -- invtrace('planning_tp_type '|| NVL(p_planning_tp_type, 2));
           -- invtrace('current_locator_id '|| p_current_locator_id);
           -- invtrace('current_subinventory_code ' || p_subinventory_code);
           -- invtrace('original_wip_entity_id ' || p_trx_src_id);
           -- invtrace('original_unit_vendor_id ' || p_unit_vendor_id);
           -- invtrace('vendor_lot_number ' || p_vendor_lot_number);
           -- invtrace('vendor_serial_number ' || p_vendor_serial_number);
           -- invtrace('last_receipt_issue_type ' || p_receipt_issue_type);
           -- invtrace('last_txn_source_id ' || p_txn_src_id);
           -- invtrace('last_txn_source_type_id ' || p_txn_src_type_id);
           -- invtrace('last_txn_source_name ' || p_txn_src_name);
           -- invtrace('last_update_date ' || SYSDATE);
           -- invtrace('last_updated_by ' || l_userid);
           -- invtrace('parent_item_id ' || p_parent_item_id);
           -- invtrace('parent_serial_number ' || p_parent_serial_number);
           -- invtrace('origination_date ' || l_origination_date);
           -- invtrace('c_attribute1 ' || l_c_attribute1);
           -- invtrace('c_attribute2 ' || l_c_attribute2);
           -- invtrace('c_attribute3 ' || l_c_attribute3);
           -- invtrace('c_attribute4 ' || l_c_attribute4);
           -- invtrace('c_attribute5 ' || l_c_attribute5);
           -- invtrace('c_attribute6 ' || l_c_attribute6);
           -- invtrace('c_attribute7 ' || l_c_attribute7);
           -- invtrace('c_attribute8 ' || l_c_attribute8);
           -- invtrace('c_attribute9 ' || l_c_attribute9);
           -- invtrace('c_attribute10 ' || l_c_attribute10);
           -- invtrace('c_attribute11 ' || l_c_attribute11);
           -- invtrace('c_attribute12 ' || l_c_attribute12);
           -- invtrace('c_attribute13 ' || l_c_attribute13);
           -- invtrace('c_attribute14 ' || l_c_attribute14);
           -- invtrace('c_attribute15 ' || l_c_attribute15);
           -- invtrace('c_attribute16 ' || l_c_attribute16);
           -- invtrace('c_attribute17 ' || l_c_attribute17);
           -- invtrace('c_attribute18 ' || l_c_attribute18);
           -- invtrace('c_attribute19 ' || l_c_attribute19);
           -- invtrace('c_attribute20 ' || l_c_attribute20);
           -- invtrace('d_attribute1 ' || l_d_attribute1);
           -- invtrace('d_attribute2 ' || l_d_attribute2);
           -- invtrace('d_attribute3 ' || l_d_attribute3);
           -- invtrace('d_attribute4 ' || l_d_attribute4);
           -- invtrace('d_attribute5 ' || l_d_attribute5);
           -- invtrace('d_attribute6 ' || l_d_attribute6);
           -- invtrace('d_attribute7 ' || l_d_attribute7);
           -- invtrace('d_attribute8 ' || l_d_attribute8);
           -- invtrace('d_attribute9 ' || l_d_attribute9);
           -- invtrace('d_attribute10 ' || l_d_attribute10);
           -- invtrace('n_attribute1 ' || l_n_attribute1);
           -- invtrace('n_attribute2 ' || l_n_attribute2);
           -- invtrace('n_attribute3 ' || l_n_attribute3);
           -- invtrace('n_attribute4 ' || l_n_attribute4);
           -- invtrace('n_attribute5 ' || l_n_attribute5);
           -- invtrace('n_attribute6 ' || l_n_attribute6);
           -- invtrace('n_attribute7 ' || l_n_attribute7);
           -- invtrace('n_attribute8 ' || l_n_attribute8);
           -- invtrace('n_attribute9 ' || l_n_attribute9);
           -- invtrace('n_attribute10 ' || l_n_attribute10);
           -- invtrace('territory_code ' || l_territory_code);
           -- invtrace('cost_group_id ' || inv_cost_group_pub.g_cost_group_id);

      UPDATE mtl_serial_numbers
         SET current_status = decode(p_current_status, null,
                                        decode(p_wip_entity_id, null, current_status, decode(current_status, 6, 1, current_status)),
                                        decode(p_wip_entity_id, null, p_current_status,decode(p_current_status, 6, 1, p_current_status)) )
           , initialization_date = initialization_date
           , completion_date = p_completion_date
           , ship_date = p_ship_date
           , revision = p_revision
           , lot_number = p_lot_number
           ,   -- do not update group mark id for staging transfer vipartha
             -- group_mark_id = DECODE(p_transaction_action_id, 28, group_mark_id, NULL)
             group_mark_id = DECODE(p_transaction_action_id, 28, group_mark_id, l_group_mark_id)
           , line_mark_id = p_line_mark_id
           , lot_line_mark_id = NULL
           , current_organization_id = p_organization_id
           , organization_type = NVL(p_organization_type, 2)
           , owning_organization_id = NVL(p_owning_org_id, p_organization_id)
           , owning_tp_type = NVL(p_owning_tp_type, 2)
           , planning_organization_id = NVL(p_planning_org_id, p_organization_id)
           , planning_tp_type = NVL(p_planning_tp_type, 2)
           , current_locator_id = p_current_locator_id
           , current_subinventory_code = p_subinventory_code
           , original_wip_entity_id = p_trx_src_id
           , original_unit_vendor_id = p_unit_vendor_id
           , vendor_lot_number = p_vendor_lot_number
           , vendor_serial_number = p_vendor_serial_number
           , last_receipt_issue_type = p_receipt_issue_type
           , last_txn_source_id = p_txn_src_id
           , last_txn_source_type_id = p_txn_src_type_id
           , last_txn_source_name = p_txn_src_name
           , last_update_date = SYSDATE
           , last_updated_by = l_userid
           , parent_item_id = p_parent_item_id
           , parent_serial_number = p_parent_serial_number
           , origination_date = l_origination_date
           , c_attribute1 = l_c_attribute1
           , c_attribute2 = l_c_attribute2
           , c_attribute3 = l_c_attribute3
           , c_attribute4 = l_c_attribute4
           , c_attribute5 = l_c_attribute5
           , c_attribute6 = l_c_attribute6
           , c_attribute7 = l_c_attribute7
           , c_attribute8 = l_c_attribute8
           , c_attribute9 = l_c_attribute9
           , c_attribute10 = l_c_attribute10
           , c_attribute11 = l_c_attribute11
           , c_attribute12 = l_c_attribute12
           , c_attribute13 = l_c_attribute13
           , c_attribute14 = l_c_attribute14
           , c_attribute15 = l_c_attribute15
           , c_attribute16 = l_c_attribute16
           , c_attribute17 = l_c_attribute17
           , c_attribute18 = l_c_attribute18
           , c_attribute19 = l_c_attribute19
           , c_attribute20 = l_c_attribute20
           , d_attribute1 = l_d_attribute1
           , d_attribute2 = l_d_attribute2
           , d_attribute3 = l_d_attribute3
           , d_attribute4 = l_d_attribute4
           , d_attribute5 = l_d_attribute5
           , d_attribute6 = l_d_attribute6
           , d_attribute7 = l_d_attribute7
           , d_attribute8 = l_d_attribute8
           , d_attribute9 = l_d_attribute9
           , d_attribute10 = l_d_attribute10
           , n_attribute1 = l_n_attribute1
           , n_attribute2 = l_n_attribute2
           , n_attribute3 = l_n_attribute3
           , n_attribute4 = l_n_attribute4
           , n_attribute5 = l_n_attribute5
           , n_attribute6 = l_n_attribute6
           , n_attribute7 = l_n_attribute7
           , n_attribute8 = l_n_attribute8
           , n_attribute9 = l_n_attribute9
           , n_attribute10 = l_n_attribute10
           , territory_code = l_territory_code
           , cost_group_id = inv_cost_group_pub.g_cost_group_id
           , wip_entity_id = p_wip_entity_id
           , operation_seq_num = p_operation_seq_num
           , intraoperation_step_type = p_intraoperation_step_type
       WHERE inventory_item_id = p_inventory_item_id
         AND serial_number = p_serial_number
         AND DECODE(current_status, 6, 1, current_status) = DECODE(p_last_status, 6, 1, p_last_status);
     ELSE
         UPDATE mtl_serial_numbers
         SET current_status = decode(p_current_status, null,
                                decode(p_wip_entity_id, null, current_status, decode(current_status, 6, 1, current_Status)),
                                decode(p_wip_entity_id, null, p_current_status, decode(p_current_status, 6, 1, p_current_status)))
           , initialization_date = initialization_date
           , completion_date = p_completion_date
           , ship_date = p_ship_date
           , revision = p_revision
           , lot_number = p_lot_number
           ,   -- do not update group mark id for staging transfer vipartha
             --group_mark_id = DECODE(p_transaction_action_id, 28, group_mark_id, NULL)
             group_mark_id = DECODE(p_transaction_action_id, 28, group_mark_id, l_group_mark_id)
           , line_mark_id = p_line_mark_id
           , lot_line_mark_id = NULL
           , current_organization_id = p_organization_id
           , current_locator_id = p_current_locator_id
           , current_subinventory_code = p_subinventory_code
           , original_wip_entity_id = p_trx_src_id
           , original_unit_vendor_id = p_unit_vendor_id
           , vendor_lot_number = p_vendor_lot_number
           , vendor_serial_number = p_vendor_serial_number
           , last_receipt_issue_type = p_receipt_issue_type
           , last_txn_source_id = p_txn_src_id
           , last_txn_source_type_id = p_txn_src_type_id
           , last_txn_source_name = p_txn_src_name
           , last_update_date = SYSDATE
           , last_updated_by = l_userid
           , parent_item_id = p_parent_item_id
           , parent_serial_number = p_parent_serial_number
           , wip_entity_id = p_wip_entity_id
           , operation_seq_num = p_operation_seq_num
           , intraoperation_step_type = p_intraoperation_step_type
       WHERE inventory_item_id = p_inventory_item_id
         AND serial_number = p_serial_number
         AND DECODE(current_status, 6, 1, current_status) = DECODE(p_last_status, 6, 1, p_last_status);
     END IF;    -- !wms_installed OR p_serial_temp_id is NULL. --Bug4535887
    ELSE
      -- invtrace('last status is neither 1 nor 6');
      -- invtrace('updating MSN WITH values ');
      -- invtrace('current_status ' || p_current_status);
          -- invtrace(' initialization_date ' || initialization_date);
          -- invtrace(' completion_date ' || p_completion_date);
          -- invtrace(' ship_date ' || p_ship_date);
          -- invtrace(' revision ' || p_revision);
          -- invtrace(' lot_number ' || p_lot_number);
          -- do not update group mark id for staging transfer vipartha);
          -- invtrace('group_mark_id ' || DECODE(p_transaction_action_id,28,group_mark_id, NULL));
          -- invtrace(' line_mark_id is NULL');
          -- invtrace(' lot_line_mark_id IS NULL');
          -- invtrace(' current_organization_id ' || p_organization_id);
          -- invtrace(' current_locator_id ' || p_current_locator_id);
          -- invtrace(' current_subinventory_code ' || p_subinventory_code);
          -- invtrace(' original_wip_entity_id ' || p_trx_src_id);
          -- invtrace(' original_unit_vendor_id ' || p_unit_vendor_id);
          -- invtrace(' vendor_lot_number ' || p_vendor_lot_number);
          -- invtrace(' vendor_serial_number ' || p_vendor_serial_number);
          -- invtrace(' last_receipt_issue_type ' || p_receipt_issue_type);
          -- invtrace(' last_txn_source_id ' || p_txn_src_id);
          -- invtrace(' last_txn_source_type_id ' || p_txn_src_type_id);
          -- invtrace(' last_txn_source_name ' || p_txn_src_name);
          -- invtrace(' last_update_date ' || SYSDATE);
          -- invtrace(' last_updated_by ' || l_userid);
          -- invtrace(' parent_item_id ' || p_parent_item_id);
          -- invtrace(' parent_serial_number ' || p_parent_serial_number);
      UPDATE mtl_serial_numbers
         SET current_status = decode(p_current_status, null,
                                decode(p_wip_entity_id, null, current_status, decode(current_status, 6, 1, current_Status)),
                                decode(p_wip_entity_id, null, p_current_status, decode(p_current_status, 6, 1, p_current_status)))
           , initialization_date = initialization_date
           , completion_date = p_completion_date
           , ship_date = p_ship_date
           , revision = p_revision
           , lot_number = p_lot_number
           ,   -- do not update group mark id for staging transfer vipartha
             --group_mark_id = DECODE(p_transaction_action_id, 28, group_mark_id, NULL)
             group_mark_id = DECODE(p_transaction_action_id, 28, group_mark_id, l_group_mark_id)
           , line_mark_id = p_line_mark_id
           , lot_line_mark_id = NULL
           , current_organization_id = p_organization_id
           , current_locator_id = p_current_locator_id
           , current_subinventory_code = p_subinventory_code
           , original_wip_entity_id = p_trx_src_id
           , original_unit_vendor_id = p_unit_vendor_id
           , vendor_lot_number = p_vendor_lot_number
           , vendor_serial_number = p_vendor_serial_number
           , last_receipt_issue_type = p_receipt_issue_type
           , last_txn_source_id = p_txn_src_id
           , last_txn_source_type_id = p_txn_src_type_id
           , last_txn_source_name = p_txn_src_name
           , last_update_date = SYSDATE
           , last_updated_by = l_userid
           , parent_item_id = p_parent_item_id
           , parent_serial_number = p_parent_serial_number
           , wip_entity_id = p_wip_entity_id
           , operation_seq_num = p_operation_seq_num
           , intraoperation_step_type = p_intraoperation_step_type
       WHERE inventory_item_id = p_inventory_item_id
         AND serial_number = p_serial_number
         AND DECODE(current_status, 6, 1, current_status) = DECODE(p_last_status, 6, 1, p_last_status);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- End of API body.
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO apiupdateserial_apipub;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'updateSerial');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END updateserial;

  PROCEDURE insertunittrx(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id     IN            NUMBER
  , p_organization_id       IN            NUMBER
  , p_serial_number         IN            VARCHAR2
  , p_current_locator_id    IN            NUMBER
  , p_subinventory_code     IN            VARCHAR2
  , p_transaction_date      IN            DATE
  , p_txn_src_id            IN            NUMBER
  , p_txn_src_name          IN            VARCHAR2
  , p_txn_src_type_id       IN            NUMBER
  , p_transaction_id        IN            NUMBER
  , p_transaction_action_id IN            NUMBER
  , p_transaction_temp_id   IN            NUMBER
  , p_receipt_issue_type    IN            NUMBER
  , p_customer_id           IN            NUMBER
  , p_ship_id               IN            NUMBER
  , p_status_id             IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_api_version     CONSTANT NUMBER                                       := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)                                 := 'insertSerial';
    l_userid                   NUMBER;
    l_loginid                  NUMBER;
    l_serial_control_code      NUMBER;
    l_attributes_default       inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_attributes_default_count NUMBER;
    l_attributes_in            inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_column_idx               BINARY_INTEGER                               := 44;
    l_return_status            VARCHAR2(1);
    l_msg_data                 VARCHAR2(2000);
    l_msg_count                NUMBER;
    l_wms_installed            BOOLEAN;

     l_sys_date date := NULL;
     l_date2    date := NULL;
     l_date23   date := NULL;
     l_date24   date := NULL;
     l_date25   date := NULL;
     l_date26   date := NULL;
     l_date27   date := NULL;
     l_date28   date := NULL;
     l_date29   date := NULL;
     l_date30   date := NULL;
     l_date31   date := NULL;
     l_date32   date := NULL;

     l_num33    NUMBER := NULL;
     l_num34    NUMBER := NULL;
     l_num35    NUMBER := NULL;
     l_num36    NUMBER := NULL;
     l_num37    NUMBER := NULL;
     l_num38    NUMBER := NULL;
     l_num39    NUMBER := NULL;
     l_num40    NUMBER := NULL;
     l_num41    NUMBER := NULL;
     l_num42    NUMBER := NULL;

    CURSOR serial_temp_csr(p_transaction_temp_id NUMBER) IS
      SELECT serial_attribute_category
           , fnd_date.date_to_canonical(origination_date)
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
           , fnd_date.date_to_canonical(d_attribute1)
           , fnd_date.date_to_canonical(d_attribute2)
           , fnd_date.date_to_canonical(d_attribute3)
           , fnd_date.date_to_canonical(d_attribute4)
           , fnd_date.date_to_canonical(d_attribute5)
           , fnd_date.date_to_canonical(d_attribute6)
           , fnd_date.date_to_canonical(d_attribute7)
           , fnd_date.date_to_canonical(d_attribute8)
           , fnd_date.date_to_canonical(d_attribute9)
           , fnd_date.date_to_canonical(d_attribute10)
           , TO_CHAR(n_attribute1)
           , TO_CHAR(n_attribute2)
           , TO_CHAR(n_attribute3)
           , TO_CHAR(n_attribute4)
           , TO_CHAR(n_attribute5)
           , TO_CHAR(n_attribute6)
           , TO_CHAR(n_attribute7)
           , TO_CHAR(n_attribute8)
           , TO_CHAR(n_attribute9)
           , TO_CHAR(n_attribute10)
           , status_id
           , territory_code
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_transaction_temp_id
         AND LPAD(p_serial_number,30) BETWEEN LPAD(fm_serial_number,30) AND LPAD(NVL(to_serial_number, fm_serial_number),30);
         /* Bug 3622025 -- Added the LPAD function in the above where clause */

    l_input_idx                BINARY_INTEGER;
    l_debug                    NUMBER                                       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT apiinsertserial_apipub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success

    /**IF (p_transaction_action_id = 3 AND g_firstscan = FALSE) THEN
      x_return_status  := fnd_api.g_ret_sts_success;
    ELSE**/
    x_return_status  := fnd_api.g_ret_sts_success;
    l_wms_installed  :=
      wms_install.check_install(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => NULL   --p_organization_id
      );

    IF (p_transaction_temp_id IS NOT NULL) THEN
      OPEN serial_temp_csr(p_transaction_temp_id);

      populateattributescolumn();

      FETCH serial_temp_csr
       INTO g_serial_attributes_tbl(1).column_value
          , g_serial_attributes_tbl(2).column_value
          , g_serial_attributes_tbl(3).column_value
          , g_serial_attributes_tbl(4).column_value
          , g_serial_attributes_tbl(5).column_value
          , g_serial_attributes_tbl(6).column_value
          , g_serial_attributes_tbl(7).column_value
          , g_serial_attributes_tbl(8).column_value
          , g_serial_attributes_tbl(9).column_value
          , g_serial_attributes_tbl(10).column_value
          , g_serial_attributes_tbl(11).column_value
          , g_serial_attributes_tbl(12).column_value
          , g_serial_attributes_tbl(13).column_value
          , g_serial_attributes_tbl(14).column_value
          , g_serial_attributes_tbl(15).column_value
          , g_serial_attributes_tbl(16).column_value
          , g_serial_attributes_tbl(17).column_value
          , g_serial_attributes_tbl(18).column_value
          , g_serial_attributes_tbl(19).column_value
          , g_serial_attributes_tbl(20).column_value
          , g_serial_attributes_tbl(21).column_value
          , g_serial_attributes_tbl(22).column_value
          , g_serial_attributes_tbl(23).column_value
          , g_serial_attributes_tbl(24).column_value
          , g_serial_attributes_tbl(25).column_value
          , g_serial_attributes_tbl(26).column_value
          , g_serial_attributes_tbl(27).column_value
          , g_serial_attributes_tbl(28).column_value
          , g_serial_attributes_tbl(29).column_value
          , g_serial_attributes_tbl(30).column_value
          , g_serial_attributes_tbl(31).column_value
          , g_serial_attributes_tbl(32).column_value
          , g_serial_attributes_tbl(33).column_value
          , g_serial_attributes_tbl(34).column_value
          , g_serial_attributes_tbl(35).column_value
          , g_serial_attributes_tbl(36).column_value
          , g_serial_attributes_tbl(37).column_value
          , g_serial_attributes_tbl(38).column_value
          , g_serial_attributes_tbl(39).column_value
          , g_serial_attributes_tbl(40).column_value
          , g_serial_attributes_tbl(41).column_value
          , g_serial_attributes_tbl(42).column_value
          , g_serial_attributes_tbl(43).column_value
          , g_serial_attributes_tbl(44).column_value;

      CLOSE serial_temp_csr;

      l_input_idx  := 0;

      IF l_wms_installed THEN
        FOR x IN 1 .. 44 LOOP
          IF (g_serial_attributes_tbl(x).column_value IS NOT NULL) THEN
            l_input_idx                                := l_input_idx + 1;
            l_attributes_in(l_input_idx).column_name   := g_serial_attributes_tbl(x).column_name;
            l_attributes_in(l_input_idx).column_type   := g_serial_attributes_tbl(x).column_type;
            l_attributes_in(l_input_idx).column_value  := g_serial_attributes_tbl(x).column_value;
          END IF;
        END LOOP;
      END IF;   -- if wms_installed is true
    END IF;   -- if transaction_temp_id is not null

    ----------------------------------------------------------
    -- call inv_lot_sel_attr.get_default to get the default value
    -- of the lot attributes
    ---------------------------------------------------------
    IF l_wms_installed THEN
      inv_lot_sel_attr.get_default(
        x_attributes_default         => l_attributes_default
      , x_attributes_default_count   => l_attributes_default_count
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_table_name                 => 'MTL_SERIAL_NUMBERS'
      , p_attributes_name            => 'Serial Attributes'
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_lot_serial_number          => p_serial_number
      , p_attributes                 => l_attributes_in
      );

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        x_return_status  := l_return_status;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /* Get the default attribs only when there is no value on the form (in MSNT).
       * In case the user changes the context and the attributes while recieving,
       * they would be lost if we get the default context again--2756040
       */
      IF (l_attributes_default_count > 0
          AND(g_serial_attributes_tbl(1).column_value = NULL)) THEN
        FOR i IN 1 .. l_attributes_default_count LOOP
          FOR j IN 1 .. g_serial_attributes_tbl.COUNT LOOP
            IF (l_attributes_default(i).column_name = g_serial_attributes_tbl(j).column_name) THEN
              g_serial_attributes_tbl(j).column_value  := l_attributes_default(i).column_value;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;   -- if wms install is true

    l_userid         := fnd_global.user_id;
    l_loginid        := fnd_global.login_id;
    l_sys_date       := SYSDATE;

    IF (p_transaction_action_id = 3 AND g_firstscan = FALSE) THEN
      INSERT INTO mtl_unit_transactions
                  (
                   transaction_id
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , serial_number
                 , inventory_item_id
                 , organization_id
                 , subinventory_code
                 , locator_id
                 , transaction_date
                 , transaction_source_id
                 , transaction_source_type_id
                 , transaction_source_name
                 , receipt_issue_type
                 , customer_id
                 , ship_id
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
                  )
        SELECT p_transaction_id
             , l_sys_date
             , l_userid
             , creation_date
             , created_by
             , l_loginid
             , p_serial_number
             , p_inventory_item_id
             , p_organization_id
             , p_subinventory_code
             , p_current_locator_id
             , p_transaction_date
             , p_txn_src_id
             , p_txn_src_type_id
             , p_txn_src_name
             , p_receipt_issue_type
             , p_customer_id
             , p_ship_id
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
          FROM mtl_serial_numbers
         WHERE serial_number = p_serial_number
           AND current_organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id;
    /* Bug 2207912 */
    /* The following not exists statement is commented out
    ** because  this part of the statement gets executed
    ** only for ORG TRANSFER and for the delivery side of
    ** of transaction as firstscan is false now, before this
    ** insert statement gets executed the mtl_serial_number is
    ** table is already updated with the organization_id of the
    ** delivered org and status from the TM, so there will be an entry always exist
    ** ing for the where condition specified in the exists clasue
    ** for mtl_serial_number table
    ** So the insert statement will always fail.
    */
    --and   not exists
    --   ( select NULL
    --  from mtl_serial_numbers sn
    --  where sn.serial_number = p_serial_number
    --  and sn.current_organization_id = p_organization_id
    -- and sn.inventory_item_id = p_inventory_item_id);
    ELSE
      IF l_wms_installed THEN
        /** 2756040 - Populate Serial Attribute Category info when it is not
         ** a receiving transaction **/
        IF ((g_serial_attributes_tbl(1).column_value = NULL)
            OR(p_transaction_action_id NOT IN(12, 27, 31))) THEN
          inv_lot_sel_attr.get_context_code(g_serial_attributes_tbl(1).column_value, p_organization_id, p_inventory_item_id
          , 'Serial Attributes');
        END IF;
      ELSE
        g_serial_attributes_tbl(1).column_value  := NULL;
      END IF;

       l_date2 := fnd_date.canonical_to_date(g_serial_attributes_tbl(2).COLUMN_VALUE);
       l_date23 := fnd_date.canonical_to_date(g_serial_attributes_tbl(23).COLUMN_VALUE);
       l_date24 := fnd_date.canonical_to_date(g_serial_attributes_tbl(24).COLUMN_VALUE);
       l_date25 := fnd_date.canonical_to_date(g_serial_attributes_tbl(25).COLUMN_VALUE);
       l_date26 := fnd_date.canonical_to_date(g_serial_attributes_tbl(26).COLUMN_VALUE);
       l_date27 := fnd_date.canonical_to_date(g_serial_attributes_tbl(27).COLUMN_VALUE);
       l_date28 := fnd_date.canonical_to_date(g_serial_attributes_tbl(28).COLUMN_VALUE);
       l_date29 := fnd_date.canonical_to_date(g_serial_attributes_tbl(29).COLUMN_VALUE);
       l_date30 := fnd_date.canonical_to_date(g_serial_attributes_tbl(30).COLUMN_VALUE);
       l_date31 := fnd_date.canonical_to_date(g_serial_attributes_tbl(31).COLUMN_VALUE);
       l_date32 := fnd_date.canonical_to_date(g_serial_attributes_tbl(32).COLUMN_VALUE);
       l_num33 := to_number(g_serial_attributes_tbl(33).COLUMN_VALUE);
       l_num34 := to_number(g_serial_attributes_tbl(34).COLUMN_VALUE);
       l_num35 := to_number(g_serial_attributes_tbl(35).COLUMN_VALUE);
       l_num36 := to_number(g_serial_attributes_tbl(36).COLUMN_VALUE);
       l_num37 := to_number(g_serial_attributes_tbl(37).COLUMN_VALUE);
       l_num38 := to_number(g_serial_attributes_tbl(38).COLUMN_VALUE);
       l_num39 := to_number(g_serial_attributes_tbl(39).COLUMN_VALUE);
       l_num40 := to_number(g_serial_attributes_tbl(40).COLUMN_VALUE);
       l_num41 := to_number(g_serial_attributes_tbl(41).COLUMN_VALUE);
       l_num42 := to_number(g_serial_attributes_tbl(42).COLUMN_VALUE);

      IF (p_transaction_temp_id > 0) THEN
        --Bug 2067223 paranthesis are added in the where clause
        -- of the select statement
        INSERT INTO mtl_unit_transactions
                    (
                     transaction_id
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , serial_number
                   , inventory_item_id
                   , organization_id
                   , subinventory_code
                   , locator_id
                   , transaction_date
                   , transaction_source_id
                   , transaction_source_type_id
                   , transaction_source_name
                   , receipt_issue_type
                   , customer_id
                   , ship_id
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
                   , product_code
                   , product_transaction_id
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
                    )
          SELECT p_transaction_id
               , l_sys_date
               , l_userid
               , creation_date
               , l_userid
               , l_loginid
               , p_serial_number
               , p_inventory_item_id
               , p_organization_id
               , p_subinventory_code
               , p_current_locator_id
               , p_transaction_date
               , p_txn_src_id
               , p_txn_src_type_id
               , p_txn_src_name
               , p_receipt_issue_type
               , p_customer_id
               , p_ship_id
               , g_serial_attributes_tbl(1).column_value
               , l_date2
               , g_serial_attributes_tbl(3).column_value
               , g_serial_attributes_tbl(4).column_value
               , g_serial_attributes_tbl(5).column_value
               , g_serial_attributes_tbl(6).column_value
               , g_serial_attributes_tbl(7).column_value
               , g_serial_attributes_tbl(8).column_value
               , g_serial_attributes_tbl(9).column_value
               , g_serial_attributes_tbl(10).column_value
               , g_serial_attributes_tbl(11).column_value
               , g_serial_attributes_tbl(12).column_value
               , g_serial_attributes_tbl(13).column_value
               , g_serial_attributes_tbl(14).column_value
               , g_serial_attributes_tbl(15).column_value
               , g_serial_attributes_tbl(16).column_value
               , g_serial_attributes_tbl(17).column_value
               , g_serial_attributes_tbl(18).column_value
               , g_serial_attributes_tbl(19).column_value
               , g_serial_attributes_tbl(20).column_value
               , g_serial_attributes_tbl(21).column_value
               , g_serial_attributes_tbl(22).column_value
               , l_date23
               , l_date24
               , l_date25
               , l_date26
               , l_date27
               , l_date28
               , l_date29
               , l_date30
               , l_date31
               , l_date32
               , l_num33
               , l_num34
               , l_num35
               , l_num36
               , l_num37
               , l_num38
               , l_num39
               , l_num40
               , l_num41
               , l_num42
               , p_status_id
               , g_serial_attributes_tbl(44).column_value
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
               , product_code
               , product_transaction_id
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
            FROM mtl_serial_numbers_temp
           WHERE transaction_temp_id = p_transaction_temp_id
             AND LPAD(p_serial_number,30) BETWEEN LPAD(fm_serial_number,30) AND LPAD(NVL(to_serial_number, fm_serial_number),30);
         /* Bug 3622025 -- Added the LPAD function in the above where clause */
      ELSE
        INSERT INTO mtl_unit_transactions
                    (
                     transaction_id
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , serial_number
                   , inventory_item_id
                   , organization_id
                   , subinventory_code
                   , locator_id
                   , transaction_date
                   , transaction_source_id
                   , transaction_source_type_id
                   , transaction_source_name
                   , receipt_issue_type
                   , customer_id
                   , ship_id
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
                    )
          SELECT p_transaction_id
               , SYSDATE
               , l_userid
               , SYSDATE
               , l_userid
               , l_loginid
               , p_serial_number
               , p_inventory_item_id
               , p_organization_id
               , p_subinventory_code
               , p_current_locator_id
               , p_transaction_date
               , p_txn_src_id
               , p_txn_src_type_id
               , p_txn_src_name
               , p_receipt_issue_type
               , p_customer_id
               , p_ship_id
               , g_serial_attributes_tbl(1).column_value
               , l_date2
               , g_serial_attributes_tbl(3).column_value
               , g_serial_attributes_tbl(4).column_value
               , g_serial_attributes_tbl(5).column_value
               , g_serial_attributes_tbl(6).column_value
               , g_serial_attributes_tbl(7).column_value
               , g_serial_attributes_tbl(8).column_value
               , g_serial_attributes_tbl(9).column_value
               , g_serial_attributes_tbl(10).column_value
               , g_serial_attributes_tbl(11).column_value
               , g_serial_attributes_tbl(12).column_value
               , g_serial_attributes_tbl(13).column_value
               , g_serial_attributes_tbl(14).column_value
               , g_serial_attributes_tbl(15).column_value
               , g_serial_attributes_tbl(16).column_value
               , g_serial_attributes_tbl(17).column_value
               , g_serial_attributes_tbl(18).column_value
               , g_serial_attributes_tbl(19).column_value
               , g_serial_attributes_tbl(20).column_value
               , g_serial_attributes_tbl(21).column_value
               , g_serial_attributes_tbl(22).column_value
               , l_date23
               , l_date24
               , l_date25
               , l_date26
               , l_date27
               , l_date28
               , l_date29
               , l_date30
               , l_date31
               , l_date32
               , l_num33
               , l_num34
               , l_num35
               , l_num36
               , l_num37
               , l_num38
               , l_num39
               , l_num40
               , l_num41
               , l_num42
               , p_status_id
               , g_serial_attributes_tbl(44).column_value
               , msn.time_since_new
               , msn.cycles_since_new
               , msn.time_since_overhaul
               , msn.cycles_since_overhaul
               , msn.time_since_repair
               , msn.cycles_since_repair
               , msn.time_since_visit
               , msn.cycles_since_visit
               , msn.time_since_mark
               , msn.cycles_since_mark
               , msn.number_of_repairs
            FROM mtl_serial_numbers msn
           WHERE inventory_item_id = p_inventory_item_id
             AND serial_number = p_serial_number;
      END IF;
    END IF;

     /*bug 2756040 Update MSN also with values from MSNT in case of
    receipt transaction or intransit receipt txn
    (transaction_action_id = 12 or 27) */
      IF (p_transaction_action_id IN(12, 27, 31)) THEN
         IF (l_debug = 1) THEN
            invtrace('transaction_action_id = ' || p_transaction_action_id
                     || ' org _id ' || p_organization_id || 'item ' ||
                     p_inventory_item_id);
         END IF;

      BEGIN
        UPDATE mtl_serial_numbers
           SET serial_attribute_category = g_serial_attributes_tbl(1).column_value
             , origination_date = l_date2
             , c_attribute1 = g_serial_attributes_tbl(3).column_value
             , c_attribute2 = g_serial_attributes_tbl(4).column_value
             , c_attribute3 = g_serial_attributes_tbl(5).column_value
             , c_attribute4 = g_serial_attributes_tbl(6).column_value
             , c_attribute5 = g_serial_attributes_tbl(7).column_value
             , c_attribute6 = g_serial_attributes_tbl(8).column_value
             , c_attribute7 = g_serial_attributes_tbl(9).column_value
             , c_attribute8 = g_serial_attributes_tbl(10).column_value
             , c_attribute9 = g_serial_attributes_tbl(11).column_value
             , c_attribute10 = g_serial_attributes_tbl(12).column_value
             , c_attribute11 = g_serial_attributes_tbl(13).column_value
             , c_attribute12 = g_serial_attributes_tbl(14).column_value
             , c_attribute13 = g_serial_attributes_tbl(15).column_value
             , c_attribute14 = g_serial_attributes_tbl(16).column_value
             , c_attribute15 = g_serial_attributes_tbl(17).column_value
             , c_attribute16 = g_serial_attributes_tbl(18).column_value
             , c_attribute17 = g_serial_attributes_tbl(19).column_value
             , c_attribute18 = g_serial_attributes_tbl(20).column_value
             , c_attribute19 = g_serial_attributes_tbl(21).column_value
             , c_attribute20 = g_serial_attributes_tbl(22).column_value
             , d_attribute1 = l_date23
             , d_attribute2 = l_date24
             , d_attribute3 = l_date25
             , d_attribute4 = l_date26
             , d_attribute5 = l_date27
             , d_attribute6 = l_date28
             , d_attribute7 = l_date29
             , d_attribute8 = l_date30
             , d_attribute9 = l_date31
             , d_attribute10 = l_date32
             , n_attribute1 = l_num33
             , n_attribute2 = l_num34
             , n_attribute3 = l_num35
             , n_attribute4 = l_num36
             , n_attribute5 = l_num37
             , n_attribute6 = l_num38
             , n_attribute7 = l_num39
             , n_attribute8 = l_num40
             , n_attribute9 = l_num41
             , n_attribute10 = l_num42
         WHERE serial_number = p_serial_number
           AND inventory_item_id = p_inventory_item_id
           AND current_organization_id = p_organization_id;

        IF (l_debug = 1) THEN
          invtrace('updating MSN with values ');
          invtrace('serial_attribute_category ' || g_serial_attributes_tbl(1).column_value);
          invtrace('origination_date ' || g_serial_attributes_tbl(2).column_value);
          invtrace(' C_ATTRIBUTE1 = ' || g_serial_attributes_tbl(3).column_value);
          invtrace('C_ATTRIBUTE2 = ' || g_serial_attributes_tbl(4).column_value);
          invtrace('C_ATTRIBUTE3 = ' || g_serial_attributes_tbl(5).column_value);
          invtrace('C_ATTRIBUTE4 = ' || g_serial_attributes_tbl(6).column_value);
          invtrace('C_ATTRIBUTE5 = ' || g_serial_attributes_tbl(7).column_value);
          invtrace('C_ATTRIBUTE6 = ' || g_serial_attributes_tbl(8).column_value);
          invtrace('C_ATTRIBUTE7 = ' || g_serial_attributes_tbl(9).column_value);
          invtrace('C_ATTRIBUTE8 = ' || g_serial_attributes_tbl(10).column_value);
          invtrace('C_ATTRIBUTE9 = ' || g_serial_attributes_tbl(11).column_value);
          invtrace('C_ATTRIBUTE10 = ' || g_serial_attributes_tbl(12).column_value);
          invtrace('C_ATTRIBUTE11 = ' || g_serial_attributes_tbl(13).column_value);
          invtrace('C_ATTRIBUTE12 = ' || g_serial_attributes_tbl(14).column_value);
          invtrace('C_ATTRIBUTE13 =  ' || g_serial_attributes_tbl(15).column_value);
          invtrace('C_ATTRIBUTE14 =  ' || g_serial_attributes_tbl(16).column_value);
          invtrace('C_ATTRIBUTE15 = ' || g_serial_attributes_tbl(17).column_value);
          invtrace('C_ATTRIBUTE16 = ' || g_serial_attributes_tbl(18).column_value);
          invtrace('C_ATTRIBUTE17 = ' || g_serial_attributes_tbl(19).column_value);
          invtrace('C_ATTRIBUTE18 =  ' || g_serial_attributes_tbl(20).column_value);
          invtrace('C_ATTRIBUTE19 = ' || g_serial_attributes_tbl(21).column_value);
          invtrace('C_ATTRIBUTE20 = ' || g_serial_attributes_tbl(22).column_value);
          invtrace('D_ATTRIBUTE1 =  ' || g_serial_attributes_tbl(23).column_value);
          invtrace('D_ATTRIBUTE2 =  ' || g_serial_attributes_tbl(24).column_value);
          invtrace('D_ATTRIBUTE3 =  ' || g_serial_attributes_tbl(25).column_value);
          invtrace('D_ATTRIBUTE4 =  ' || g_serial_attributes_tbl(26).column_value);
          invtrace('D_ATTRIBUTE5 = ' || g_serial_attributes_tbl(27).column_value);
          invtrace('D_ATTRIBUTE6 =  ' || g_serial_attributes_tbl(28).column_value);
          invtrace('D_ATTRIBUTE7 =  ' || g_serial_attributes_tbl(29).column_value);
          invtrace('D_ATTRIBUTE8 = ' || g_serial_attributes_tbl(30).column_value);
          invtrace('D_ATTRIBUTE9 = ' || g_serial_attributes_tbl(31).column_value);
          invtrace('D_ATTRIBUTE10 = ' || g_serial_attributes_tbl(32).column_value);
          invtrace('N_ATTRIBUTE1 =  ' || g_serial_attributes_tbl(33).column_value);
          invtrace('N_ATTRIBUTE2 =  ' || g_serial_attributes_tbl(34).column_value);
          invtrace('N_ATTRIBUTE3 =  ' || g_serial_attributes_tbl(35).column_value);
          invtrace('N_ATTRIBUTE4 =  ' || g_serial_attributes_tbl(36).column_value);
          invtrace('N_ATTRIBUTE5 =  ' || g_serial_attributes_tbl(37).column_value);
          invtrace('N_ATTRIBUTE6 =  ' || g_serial_attributes_tbl(38).column_value);
          invtrace('N_ATTRIBUTE7 =  ' || g_serial_attributes_tbl(39).column_value);
          invtrace('N_ATTRIBUTE8 =  ' || g_serial_attributes_tbl(40).column_value);
          invtrace('N_ATTRIBUTE9 =  ' || g_serial_attributes_tbl(41).column_value);
          invtrace('N_ATTRIBUTE10 = ' || g_serial_attributes_tbl(42).column_value);
          invtrace(' for the serial ' || p_serial_number);
        END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               invtrace('no data found while updating msn');
            END IF;
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               invtrace('some other error' || SQLERRM);
            END IF;
      END;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;

    -- End of API body.
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_msg_data);
    x_msg_data       := SUBSTR(l_msg_data, 0, 198);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO apiinsertserial_apipub;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'insertUnitTrx');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END insertunittrx;

  ------------------------------------------------------------------------------
  --     Name: GENERATE_SERIALSJ
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_qty                Count of Serial Numbers
  --       p_wip_id             Wip Entity ID
  --       p_rev                Revision
  --       p_lot                Lot Number
  --       p_skip_serial        0, do not skip, called in context of transaction
  --                                                         processing
  --                            1, skip-serials : concurrent-program
  --      Output parameters:
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --      Function: Call specification for Java Stored Procedure. This function
  --      is not called directly but through GENERATE_SERIALS to support
  --      autonomous transaction
  --
  --
  FUNCTION generate_serialsj(
    p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_wip_id        IN            NUMBER
  , p_rev           IN            VARCHAR2
  , p_lot           IN            VARCHAR2
  , p_skip_serial                 NUMBER
  , p_group_mark_id               NUMBER
  , p_line_mark_id                NUMBER
  , x_start_ser     OUT NOCOPY    VARCHAR2
  , x_end_ser       OUT NOCOPY    VARCHAR2
  , x_proc_msg      OUT NOCOPY    VARCHAR2
  )
    RETURN NUMBER AS
    LANGUAGE JAVA
    NAME 'oracle.apps.inv.transaction.server.TrxProcessor.generateSerials(java.lang.Long,
      java.lang.Long,
      java.lang.Long,
      java.lang.Long,
      java.lang.String,
      java.lang.String,
      java.lang.Long,
      java.lang.Long,
      java.lang.Long,
      java.lang.String[],
      java.lang.String[],
      java.lang.String[]) return java.lang.Integer';

  --
  --
  -- Purpose: This procedure will be called from Concurrent Manager. This Procedure
  -- is replacement for INCTSN.opp. It generates the serial number.
  --
  -- MODIFICATION HISTORY
  -- Person      Date    Comments
  -- ---------   ------  -------------------------------------------
  -- vipathak    8/31/01 Created.
  --
  -- Declare program variables as shown above
  PROCEDURE generate_serials(
    x_retcode       OUT NOCOPY    VARCHAR2
  , x_errbuf        OUT NOCOPY    VARCHAR2
  , p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_serial_code   IN            VARCHAR2
  , p_wip_id        IN            NUMBER
  , p_rev           IN            NUMBER
  , p_lot           IN            NUMBER
  , p_group_mark_id IN            NUMBER DEFAULT NULL
  , p_line_mark_id  IN            NUMBER DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_commit      VARCHAR2(12)   := fnd_api.g_true;
    v_mesg        VARCHAR2(2000);
    l_start_ser   VARCHAR2(100);
    l_end_ser     VARCHAR2(100);
    v_retval      NUMBER;
    ret           BOOLEAN;
    l_skip_serial NUMBER         := 1;
    l_debug       NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    v_retval  :=
      generate_serialsj(
        p_org_id                     => p_org_id
      , p_item_id                    => p_item_id
      , p_qty                        => p_qty
      , p_wip_id                     => p_wip_id
      , p_rev                        => p_rev
      , p_lot                        => p_lot
      , p_skip_serial                => l_skip_serial
      , p_group_mark_id              => p_group_mark_id
      , p_line_mark_id               => p_line_mark_id
      , x_start_ser                  => l_start_ser
      , x_end_ser                    => l_end_ser
      , x_proc_msg                   => v_mesg
      );

    IF (v_retval = 1) THEN
      ret        := fnd_concurrent.set_completion_status('ERROR', v_mesg);
      x_retcode  := 2;
      x_errbuf   := v_mesg;
    ELSIF(v_retval = 2) THEN
      ret        := fnd_concurrent.set_completion_status('WARNING', v_mesg);
      x_retcode  := 0;
    ELSE
      ret        := fnd_concurrent.set_completion_status('NORMAL', v_mesg);
      x_retcode  := 0;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      x_retcode  := 2;
      x_errbuf   := SUBSTR(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 250);
      ret        := fnd_concurrent.set_completion_status('ERROR', v_mesg);
      RAISE;
  END generate_serials;

  /*-------------------------------------------------------------------------------
  --     Name: GENERATE_SERIALS
  --         Wrapper for GENERATE_SERIALSJ with Autonomous Tramsaction support
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_qty                Count of Serial Numbers
  --       p_wip_id             Wip Entity ID
  --       p_rev                Revision
  --       p_lot                Lot Number
  --       l_calling_program    0, being called from mobile UI
  --      Output parameters:
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --
  */
  FUNCTION generate_serials(
    p_org_id        IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_qty           IN            NUMBER
  , p_wip_id        IN            NUMBER
  , p_rev           IN            VARCHAR2
  , p_lot           IN            VARCHAR2
  , p_group_mark_id IN            NUMBER DEFAULT NULL
  , p_line_mark_id  IN            NUMBER DEFAULT NULL
  , x_start_ser     OUT NOCOPY    VARCHAR2
  , x_end_ser       OUT NOCOPY    VARCHAR2
  , x_proc_msg      OUT NOCOPY    VARCHAR2
  , p_skip_serial   IN            NUMBER DEFAULT NULL
  )
    RETURN NUMBER AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_retval      NUMBER;
    l_skip_serial NUMBER := NVL(p_skip_serial, 0);
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_retval  :=
      generate_serialsj(
        p_org_id                     => p_org_id
      , p_item_id                    => p_item_id
      , p_qty                        => p_qty
      , p_wip_id                     => p_wip_id
      , p_rev                        => p_rev
      , p_lot                        => p_lot
      , p_skip_serial                => l_skip_serial
      , p_group_mark_id              => p_group_mark_id
      , p_line_mark_id               => p_line_mark_id
      , x_start_ser                  => x_start_ser
      , x_end_ser                    => x_end_ser
      , x_proc_msg                   => x_proc_msg
      );
    COMMIT;
    RETURN l_retval;
  END;

  --
  --     Name: IS_SERIAL_UNIQUE
  --
  --     Input parameters:
  --       p_org_id             Organization ID
  --       p_item_id            Item ID
  --       p_serial             Serial Number
  --
  --      Output parameters:
  --       x_proc_msg          Message from the Process-Manager
  --       return_status       0 on Success, 1 on Error
  --
  --
  FUNCTION is_serial_unique(p_org_id IN NUMBER, p_item_id IN NUMBER, p_serial IN VARCHAR2, x_proc_msg OUT NOCOPY VARCHAR2)
    RETURN NUMBER AS
    LANGUAGE JAVA
    NAME 'oracle.apps.inv.transaction.server.TrxProcessor.isSerialNumberUnique(java.lang.Long,
                                                java.lang.Long,
                                                java.lang.String,
                                                java.lang.String[]) return java.lang.Integer';

  --
  --     Name: GET_SERIAL_DIFF
  --
  --     Input parameters:
  --       p_fm_serial          'from' Serial Number
  --       p_to_serial          'to'   Serial Number
  --
  --      Output parameters:
  --       return_status       quantity between passed serial numbers
  --
  FUNCTION get_serial_diff(p_fm_serial IN VARCHAR2, p_to_serial IN VARCHAR2)
    RETURN NUMBER AS
    LANGUAGE JAVA
    NAME 'oracle.apps.inv.transaction.server.TrxProcessor.getSerNumDiff(java.lang.String,
                           java.lang.String) return java.lang.Integer';

  -- Bug 7541512, added p_rcv_parent_txn_id to validate serial number on return to vendor transactions.
   /*Bug 6898933, 1.Added new parameter p_transaction_type_id in below procedure
                  2.Modified called to TrxProcessor.validateSerialNumbers by adding last parameter value*/


  FUNCTION validate_serialsj(
    p_org_id                IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_qty                   IN OUT NOCOPY NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot                   IN            VARCHAR2
  , p_start_ser             IN            VARCHAR2
  , p_trx_src_id            IN            NUMBER
  , p_trx_action_id         IN            NUMBER
  , p_subinventory_code     IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_wip_entity_id         IN            NUMBER
  , p_group_mark_id         IN            NUMBER
  , p_line_mark_id          IN            NUMBER
  , p_issue_receipt         IN            VARCHAR2
  , x_end_ser               IN OUT NOCOPY VARCHAR2
  , x_proc_msg              OUT NOCOPY    VARCHAR2
  , p_check_for_grp_mark_id IN            VARCHAR2
  , p_rcv_validate          IN            VARCHAR2
  , p_rcv_source_line_id    IN            NUMBER
  , p_xfr_org_id            IN            NUMBER -- Bug#4153297
  , p_rcv_parent_txn_id     IN            NUMBER
  , p_transaction_type_id   IN            NUMBER
  )   --Bug# 2656316
    RETURN NUMBER AS
    LANGUAGE JAVA
    NAME 'oracle.apps.inv.transaction.server.TrxProcessor.validateSerialNumbers(java.lang.Long,
                                                java.lang.Long,
                                                java.lang.Integer[],
                                                java.lang.String,
                                                java.lang.String,
                                                java.lang.String,
                                                java.lang.Integer,
                                                java.lang.Integer,
                                                java.lang.String,
                                                java.lang.Long,
                                                java.lang.Long,
                                                java.lang.Long,
                                                java.lang.Long,
                                                java.lang.String,
                                                java.lang.String[],
                                                java.lang.String[],
                                                java.lang.String,
                                                java.lang.String,
                                                java.lang.Long,
                                                java.lang.Long,
                                                java.lang.Long,
                                                java.lang.Integer
                                                ) return java.lang.Integer';   --Bug# 2656316
--Bug#4153297
--
-- Bug 3194093 added two more parameters to the below function
-- validate_serials() and to the above function validate_serialsj()
-- p_rcv_validate,p_rcv_shipment_line_id to support serial
-- validation for intransit receipt transactions
-- applicable for Inter-org,Internal sales order Intransit txns
-- Bug 3384652 Changing the param name p_rcv_shipment_line_id to
-- p_rcv_source_line_id.And the value passed to this is either
-- shipment_line_id or ram_line_id depending on the transaction
-- Source type and action.To support serial validation for RMA
-- Bug 7541512, added p_rcv_parent_txn_id to validate serial numbers
-- on return to vendor transactions.
 /* Bug 6898933  Added new parameter p_transaction_type_id in below procedure */
  FUNCTION validate_serials(
    p_org_id                IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_qty                   IN OUT NOCOPY NUMBER
  , p_rev                   IN            VARCHAR2 DEFAULT NULL
  , p_lot                   IN            VARCHAR2 DEFAULT NULL
  , p_start_ser             IN            VARCHAR2
  , p_trx_src_id            IN            NUMBER DEFAULT NULL
  , p_trx_action_id         IN            NUMBER DEFAULT NULL
  , p_subinventory_code     IN            VARCHAR2 DEFAULT NULL
  , p_locator_id            IN            NUMBER DEFAULT NULL
  , p_wip_entity_id         IN            NUMBER DEFAULT NULL
  , p_group_mark_id         IN            NUMBER DEFAULT NULL
  , p_line_mark_id          IN            NUMBER DEFAULT NULL
  , p_issue_receipt         IN            VARCHAR2 DEFAULT NULL
  , x_end_ser               IN OUT NOCOPY VARCHAR2
  , x_proc_msg              OUT NOCOPY    VARCHAR2
  , p_check_for_grp_mark_id IN            VARCHAR2
  , p_rcv_validate          IN            VARCHAR2 DEFAULT 'N'
  , p_rcv_source_line_id    IN            NUMBER   DEFAULT -1
  , p_xfr_org_id            IN            NUMBER   DEFAULT -1 -- Bug#4153297
  , p_rcv_parent_txn_id     IN            NUMBER   DEFAULT -1
  , p_transaction_type_id   IN            NUMBER   DEFAULT 0
  )   --Bug# 2656316
    RETURN NUMBER AS
    ret_number       NUMBER := 0;
    local_locator_id NUMBER;
    l_debug          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('About to call VALIDATE_SERIALSJ ', 'VALIDATE_SERIALS', 9);
    END IF;

    /* Bug 6898933 : passed new parameter p_transaction_type_id in below call */
        ret_number  :=
      validate_serialsj(
        p_org_id                     => p_org_id
      , p_item_id                    => p_item_id
      , p_qty                        => p_qty
      , p_rev                        => p_rev
      , p_lot                        => p_lot
      , p_start_ser                  => p_start_ser
      , p_trx_src_id                 => p_trx_src_id
      , p_trx_action_id              => p_trx_action_id
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_wip_entity_id              => p_wip_entity_id
      , p_group_mark_id              => p_group_mark_id
      , p_line_mark_id               => p_line_mark_id
      , p_issue_receipt              => p_issue_receipt
      , x_end_ser                    => x_end_ser
      , x_proc_msg                   => x_proc_msg
      , p_check_for_grp_mark_id      => p_check_for_grp_mark_id   --Bug# 2656316
      , p_rcv_validate               => p_rcv_validate
      , p_rcv_source_line_id         => p_rcv_source_line_id
      , p_xfr_org_id                 => p_xfr_org_id
      , p_rcv_parent_txn_id          => p_rcv_parent_txn_id
      , p_transaction_type_id        => p_transaction_type_id
      );

    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('Returned from VALIDATE_SERIALSJ ', 'VALIDATE_SERIALS', 9);
    END IF;

    RETURN ret_number;
  END validate_serials;


  FUNCTION increment_ser_num(p_curr_serial VARCHAR2, p_inc_value NUMBER) RETURN VARCHAR2 IS
    LANGUAGE JAVA NAME 'oracle.apps.inv.transaction.server.TrxProcessor.incrementSerNum(
                          java.lang.String
                        , java.lang.Long
                        ) return java.lang.String' ;

      --Procedure for validating and updating serial attributes.
      PROCEDURE validate_update_serial_att
      (x_return_status         OUT NOCOPY VARCHAR2,
       x_msg_count             OUT NOCOPY NUMBER,
       x_msg_data              OUT NOCOPY VARCHAR2,
       x_validation_status     OUT NOCOPY VARCHAR2,
       p_serial_number         IN  VARCHAR2,
       p_organization_id       IN  NUMBER,
       p_inventory_item_id     IN  NUMBER,
       p_serial_att_tbl    IN  inv_lot_sel_attr.lot_sel_attributes_tbl_type,
       p_validate_only         IN  BOOLEAN
       ) IS
          l_attributes_name VARCHAR2(50) := 'Serial Attributes';
          v_flexfield     fnd_dflex.dflex_r;
          v_flexinfo      fnd_dflex.dflex_dr;
          v_contexts      fnd_dflex.contexts_dr;
          v_segments      fnd_dflex.segments_dr;
          l_attributes_default_count NUMBER;
          l_enabled_attributes NUMBER;
          l_attributes_default INV_LOT_SEL_ATTR.Lot_Sel_Attributes_Tbl_Type;
          v_context_value mtl_flex_context.descriptive_flex_context_code%type;
          v_colName VARCHAR2(50);
          l_context_value VARCHAR2(150);
          l_return_status VARCHAR2(1);
          l_msg_data VARCHAR2(255);
          l_msg_count NUMBER;
          l_validation_status VARCHAR2(1);
          l_status BOOLEAN;
          l_count NUMBER := 0;
          l_rs_lot_attr_category VARCHAR2(30);
          l_st_lot_attr_category VARCHAR2(30);
          l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      BEGIN
         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:Entered...');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:p_inventory_item_id='||p_inventory_item_id);
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:p_organization_id='||p_organization_id);
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:p_serial_number='||p_serial_number);
         END IF;

         -- call to see if the Serial attributes is enabled for this item/org/category combination
         l_enabled_attributes := INV_LOT_SEL_ATTR.is_enabled(p_flex_name => l_attributes_name,
                                                             p_organization_id => p_organization_id,
                                                             p_inventory_item_id => p_inventory_item_id);
         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_enabled_attributes='||l_enabled_attributes);
         END IF;

         --Populate serial attribute columns

         populateattributescolumn;

         IF (p_serial_att_tbl.COUNT <> 0 ) THEN
            -- derived from the start lot attributes
            FOR i IN 1..p_serial_att_tbl.COUNT LOOP
               FOR j IN 1..g_serial_attributes_tbl.COUNT LOOP
                  IF (UPPER(g_serial_attributes_tbl(j).COLUMN_NAME) = UPPER(p_serial_att_tbl(i).COLUMN_NAME) ) THEN
                     IF (l_debug = 1) THEN
                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:'||g_serial_attributes_tbl(j).COLUMN_NAME);
                     END IF;
                     g_serial_attributes_tbl(j).COLUMN_VALUE := p_serial_att_tbl(i).COLUMN_VALUE;
                     IF (l_debug = 1) THEN
                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:'||g_serial_attributes_tbl(j).COLUMN_NAME||':'||g_serial_attributes_tbl(j).COLUMN_VALUE);
                     END IF;
                  END IF;
                  EXIT WHEN (UPPER(g_serial_attributes_tbl(j).COLUMN_NAME) = UPPER(p_serial_att_tbl(i).COLUMN_NAME));
               END LOOP;
            END LOOP;
         END IF;

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling inv_lot_sel_attr.get_default...');
         END IF;

         inv_lot_sel_attr.get_default(x_attributes_default         => l_attributes_default,
                                      x_attributes_default_count   => l_attributes_default_count,
                                      x_return_status              => l_return_status,
                                      x_msg_count                  => l_msg_count,
                                      x_msg_data                   => x_msg_data,
                                      p_table_name                 => 'MTL_SERIAL_NUMBERS',
                                      p_attributes_name            => 'Serial Attributes',
                                      p_inventory_item_id          => p_inventory_item_id,
                                      p_organization_id            => p_organization_id,
                                      p_lot_serial_number          => p_serial_number,
                                      p_attributes                 => g_serial_attributes_tbl);

         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            x_validation_status := 'N';
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_attributes_default_count='||l_attributes_default_count);
         END IF;

         IF (l_attributes_default_count > 0) THEN
            FOR i IN 1..l_attributes_default_count LOOP
               FOR j IN 1..g_serial_attributes_tbl.COUNT LOOP
                  IF (Upper(l_attributes_default(i).COLUMN_NAME) = Upper(g_serial_attributes_tbl(j).COLUMN_NAME)
                      AND l_attributes_default(i).COLUMN_VALUE IS NOT NULL) THEN
                     IF (l_debug = 1) THEN
                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:g_serial_attributes_tbl(j).COLUMN_VALUE='||g_serial_attributes_tbl(j).COLUMN_VALUE);
                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_attributes_default(i).COLUMN_VALUE='||l_attributes_default(i).column_value);
                     END IF;

                     IF (g_serial_attributes_tbl(j).COLUMN_VALUE IS NULL) THEN
                        g_serial_attributes_tbl(j).COLUMN_VALUE := l_attributes_default(i).COLUMN_VALUE;
                     END IF;

                     g_serial_attributes_tbl(j).REQUIRED := l_attributes_default(i).REQUIRED;

                  END IF;
                  EXIT WHEN (Upper(l_attributes_default(i).COLUMN_NAME) = Upper(g_serial_attributes_tbl(j).COLUMN_NAME));
               END LOOP;
      END LOOP;
         END IF;

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_dflex.get_flexfield...');
         END IF;
         -- Get flexfield
         fnd_dflex.get_flexfield('INV', l_attributes_name, v_flexfield, v_flexinfo);

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_dflex.get_context...');
         END IF;
         -- Get Contexts
         l_context_value := NULL;
         fnd_dflex.get_contexts(v_flexfield, v_contexts);

         FOR i IN 1..g_serial_attributes_tbl.COUNT LOOP
            IF (Upper(g_serial_attributes_tbl(i).COLUMN_NAME) = 'SERIAL_ATTRIBUTE_CATEGORY'
                AND g_serial_attributes_tbl(i).column_value IS NULL ) THEN
               inv_lot_sel_attr.get_context_code(l_context_value, p_organization_id,p_inventory_item_id,l_attributes_name);
               g_serial_attributes_tbl(i).column_value := l_context_value;
             ELSE
               l_context_value :=  g_serial_attributes_tbl(i).column_value;
            END IF;
            EXIT WHEN (Upper(g_serial_attributes_tbl(i).COLUMN_NAME) = 'SERIAL_ATTRIBUTE_CATEGORY');
         END LOOP;

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_context_value='||l_context_value);
         END IF;

         IF ( (l_enabled_attributes = 0 ) OR ( l_context_value is null)) then

            IF (l_debug = 1) THEN
               invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_context is null, attr enabaled=0');
            END IF;

            l_validation_status := 'Y';
            x_msg_count := 0;
            x_msg_data := NULL;
          ELSE --IF ( (l_enabled_attributes = 0 ) OR ( l_context_value is null)) then
            IF (l_debug = 1) THEN
               invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_flex_descval.set_context_value...');
            END IF;

            fnd_flex_descval.set_context_value(l_context_value);

            IF (l_debug = 1) THEN
               invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_flex_descval.clear_column_values...');
            END IF;

            fnd_flex_descval.clear_column_values;

            IF (l_debug = 1) THEN
               invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_flex_descval.set_column_values SERIAL_ATTRIBUTE_CATEGORY='||l_context_value);
            END IF;

            fnd_flex_descval.set_column_value('SERIAL_ATTRIBUTE_CATEGORY', l_context_value);

            -- Setting the Values for Validating
            IF (l_debug = 1) THEN
               invtrace('VALIDATE_UPDATE_SERIAL_ATT:g_serial_attributes_tbl.COUNT='||g_serial_attributes_tbl.COUNT);
            END IF;

            FOR i IN 1..v_contexts.ncontexts LOOP
               IF (v_contexts.is_enabled(i) AND ((UPPER(v_contexts.context_code(i)) = UPPER(l_context_value)) OR
                                                 v_contexts.is_global(i))) THEN
                  -- Get segments
                  IF (l_debug = 1) THEN
                     invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_dflex.get_segments...');
                  END IF;

                  fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield, v_contexts.context_code(i)), v_segments, TRUE);
                  <<segmentLoop>>
                    FOR j IN 1..v_segments.nsegments LOOP
                       IF v_segments.is_enabled(j) THEN
                          v_colName := v_segments.application_column_name(j);

                          IF (l_debug = 1) THEN
                             invtrace('VALIDATE_UPDATE_SERIAL_ATT:v_colName='||v_colName);
                          END IF;

                          <<columnLoop>>
                            FOR k IN 1..g_serial_attributes_tbl.COUNT LOOP
                               IF UPPER(v_colName) = UPPER(g_serial_attributes_tbl(k).column_name) THEN
                                  IF (l_debug = 1) THEN
                                     invtrace('VALIDATE_UPDATE_SERIAL_ATT:'||g_serial_attributes_tbl(k).Column_name);
                                  END IF;
                                  -- Sets the Values for Validation
                                  -- Setting the column data type for validation
                                  IF g_serial_attributes_tbl(k).column_type = 'DATE' THEN
                                     IF (l_debug = 1) THEN
                                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:set_column_value='||g_serial_attributes_tbl(k).column_value);
                                     END IF;
                                     fnd_flex_descval.set_column_value(g_serial_attributes_tbl(k).column_name,
                                                                       fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(k).column_value)));
                                  END IF;

                                  IF g_serial_attributes_tbl(k).column_type = 'NUMBER' THEN
                                     IF (l_debug = 1) THEN
                                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:set_column_value='||g_serial_attributes_tbl(k).column_value);
                                     END IF;
                                     fnd_flex_descval.set_column_value(g_serial_attributes_tbl(k).column_name,
                                                                       To_number(g_serial_attributes_tbl(k).column_value));
                                  END IF;

                                  IF g_serial_attributes_tbl(k).column_type = 'VARCHAR2' THEN
                                     IF (l_debug = 1) THEN
                                        invtrace('VALIDATE_UPDATE_SERIAL_ATT:set_column_value='||g_serial_attributes_tbl(k).column_value);
                                     END IF;
                                     fnd_flex_descval.set_column_value(g_serial_attributes_tbl(k).column_name,
                                                                       g_serial_attributes_tbl(k).column_value);
                                  END IF;

                                  IF (v_segments.is_required(j)) THEN
                                     IF (g_serial_attributes_tbl(k).COLUMN_VALUE IS NULL) THEN
                                        IF (l_debug = 1) THEN
                                           invtrace('VALIDATE_UPDATE_SERIAL_ATT:'||g_serial_attributes_tbl(k).COLUMN_NAME||':'||g_serial_attributes_tbl(k).COLUMN_VALUE);
                                        END IF;
                                        fnd_message.set_name('INV', 'INV_LOT_SEL_DEFAULT_REQUIRED');
                                        fnd_message.set_token('ATTRNAME',l_attributes_name);
                                        fnd_message.set_token('CONTEXTCODE', v_contexts.context_code(i));
                                        fnd_message.set_token('SEGMENT', v_segments.application_column_name(j));
                                        fnd_msg_pub.ADD;
                                     END IF;
                                  END IF;
                               END IF;
                               EXIT when (Upper(v_colName) = Upper(g_serial_attributes_tbl(k).column_name));
                            END LOOP;
                       END IF;
                    END LOOP;
               END IF;
            END LOOP;
            -- Call the  validating routine for Lot Attributes.

            IF (l_debug = 1) THEN
               invtrace('VALIDATE_UPDATE_SERIAL_ATT:Calling fnd_flex_descval.validate_desccols...');
            END IF;
            l_status := fnd_flex_descval.validate_desccols(appl_short_name => 'INV',
                                                           desc_flex_name => l_attributes_name);
            IF l_status = TRUE then
               IF (l_debug = 1) THEN
                  invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_status is TRUE');
               END IF;
               l_validation_status := 'Y';
             ELSE
               IF (l_debug = 1) THEN
                  invtrace('VALIDATE_UPDATE_SERIAL_ATT:l_status is FALSE');
               END IF;
               l_validation_status := 'N';
               x_return_status := FND_API.G_RET_STS_ERROR ;
               x_msg_data := fnd_flex_descval.error_message;
               fnd_message.set_name('INV', 'GENERIC');
               fnd_message.set_token('MSGBODY', x_msg_data );
               fnd_msg_pub.ADD;
               x_msg_count := nvl(x_msg_count,0) + 1 ;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; -- if l_context_value is not null

         x_validation_status := l_validation_status;

         -- if validation passed then update the attributes.

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:Updating the Attributes...');
         END IF;

         IF l_validation_status = 'Y' THEN
            IF NOT p_validate_only THEN
               UPDATE mtl_serial_numbers
                 SET serial_attribute_category = g_serial_attributes_tbl(1).COLUMN_VALUE
                 , origination_date = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(2).COLUMN_VALUE))
                 , c_attribute1  = g_serial_attributes_tbl(3).COLUMN_VALUE
                 , c_attribute2  = g_serial_attributes_tbl(4).COLUMN_VALUE
                 , c_attribute3  = g_serial_attributes_tbl(5).COLUMN_VALUE
                 , c_attribute4  = g_serial_attributes_tbl(6).COLUMN_VALUE
                 , c_attribute5  = g_serial_attributes_tbl(7).COLUMN_VALUE
                 , c_attribute6  = g_serial_attributes_tbl(8).COLUMN_VALUE
                 , c_attribute7  = g_serial_attributes_tbl(9).COLUMN_VALUE
                 , c_attribute8  = g_serial_attributes_tbl(10).COLUMN_VALUE
                 , c_attribute9  = g_serial_attributes_tbl(11).COLUMN_VALUE
                 , c_attribute10 = g_serial_attributes_tbl(12).COLUMN_VALUE
                 , c_attribute11 = g_serial_attributes_tbl(13).COLUMN_VALUE
                 , c_attribute12 = g_serial_attributes_tbl(14).COLUMN_VALUE
                 , c_attribute13 = g_serial_attributes_tbl(15).COLUMN_VALUE
                 , c_attribute14 = g_serial_attributes_tbl(16).COLUMN_VALUE
                 , c_attribute15 = g_serial_attributes_tbl(17).COLUMN_VALUE
                 , c_attribute16 = g_serial_attributes_tbl(18).COLUMN_VALUE
                 , c_attribute17 = g_serial_attributes_tbl(19).COLUMN_VALUE
                 , c_attribute18 = g_serial_attributes_tbl(20).COLUMN_VALUE
                 , c_attribute19 = g_serial_attributes_tbl(21).COLUMN_VALUE
                 , c_attribute20 = g_serial_attributes_tbl(22).COLUMN_VALUE
                 , d_attribute1  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(23).COLUMN_VALUE))
                 , d_attribute2  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(24).COLUMN_VALUE))
                 , d_attribute3  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(25).COLUMN_VALUE))
                 , d_attribute4  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(26).COLUMN_VALUE))
                 , d_attribute5  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(27).COLUMN_VALUE))
                 , d_attribute6  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(28).COLUMN_VALUE))
                 , d_attribute7  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(29).COLUMN_VALUE))
                 , d_attribute8  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(30).COLUMN_VALUE))
                 , d_attribute9  = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(31).COLUMN_VALUE))
                 , d_attribute10 = fnd_date.canonical_to_date(fnd_date.date_to_canonical(g_serial_attributes_tbl(32).COLUMN_VALUE))
                 , n_attribute1  = to_number(g_serial_attributes_tbl(33).COLUMN_VALUE)
                 , n_attribute2  = to_number(g_serial_attributes_tbl(34).COLUMN_VALUE)
                 , n_attribute3  = to_number(g_serial_attributes_tbl(35).COLUMN_VALUE)
                 , n_attribute4  = to_number(g_serial_attributes_tbl(36).COLUMN_VALUE)
                 , n_attribute5  = to_number(g_serial_attributes_tbl(37).COLUMN_VALUE)
                 , n_attribute6  = to_number(g_serial_attributes_tbl(38).COLUMN_VALUE)
                 , n_attribute7  = to_number(g_serial_attributes_tbl(39).COLUMN_VALUE)
                 , n_attribute8  = to_number(g_serial_attributes_tbl(40).COLUMN_VALUE)
                 , n_attribute9  = to_number(g_serial_attributes_tbl(41).COLUMN_VALUE)
                 , n_attribute10 = to_number(g_serial_attributes_tbl(42).COLUMN_VALUE)
                 , status_id = Nvl(to_number(g_serial_attributes_tbl(43).COLUMN_VALUE),status_id)
                 , territory_code = g_serial_attributes_tbl(44).COLUMN_VALUE
				 , attribute_category = g_serial_attributes_tbl(45).COLUMN_VALUE
                 , attribute1  = g_serial_attributes_tbl(46).COLUMN_VALUE
                 , attribute2  = g_serial_attributes_tbl(47).COLUMN_VALUE
                 , attribute3  = g_serial_attributes_tbl(48).COLUMN_VALUE
                 , attribute4  = g_serial_attributes_tbl(49).COLUMN_VALUE
                 , attribute5  = g_serial_attributes_tbl(50).COLUMN_VALUE
                 , attribute6  = g_serial_attributes_tbl(51).COLUMN_VALUE
                 , attribute7  = g_serial_attributes_tbl(52).COLUMN_VALUE
                 , attribute8  = g_serial_attributes_tbl(53).COLUMN_VALUE
                 , attribute9  = g_serial_attributes_tbl(54).COLUMN_VALUE
                 , attribute10 = g_serial_attributes_tbl(55).COLUMN_VALUE
                 , attribute11 = g_serial_attributes_tbl(56).COLUMN_VALUE
                 , attribute12 = g_serial_attributes_tbl(57).COLUMN_VALUE
                 , attribute13 = g_serial_attributes_tbl(58).COLUMN_VALUE
                 , attribute14 = g_serial_attributes_tbl(59).COLUMN_VALUE
                 , attribute15 = g_serial_attributes_tbl(60).COLUMN_VALUE
                 WHERE inventory_item_id = p_inventory_item_id
                 AND serial_number = p_serial_number
                 AND current_organization_id = p_organization_id;
            END IF; -- IF NOT p_validate_only THEN
         END IF; --IF l_validation_status = 'Y' THEN

         IF (l_debug = 1) THEN
            invtrace('VALIDATE_UPDATE_SERIAL_ATT:Exitting...');
         END IF;

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            x_validation_status := l_validation_status;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_validation_status := l_validation_status;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         WHEN OTHERS THEN
            x_validation_status := l_validation_status;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Validate_Attributes');
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
      END validate_update_serial_att;

FUNCTION SNGetMask(P_txn_act_id          IN      NUMBER,
                   P_txn_src_type_id     IN      NUMBER,
                   P_serial_control      IN      NUMBER,
                   x_to_status           OUT NOCOPY    NUMBER,
                   x_dynamic_ok          OUT NOCOPY    NUMBER,
                   P_receipt_issue_flag  IN      VARCHAR2,
                   x_mask                OUT NOCOPY    VARCHAR2,
                   x_errorcode           OUT NOCOPY    NUMBER)
                   RETURN BOOLEAN IS
   --
   TYPE L_mask_tab IS TABLE OF VARCHAR2(17)
        INDEX BY BINARY_INTEGER;
   L_sn_mask  L_mask_tab;
   L_group NUMBER := 0;
   --
BEGIN
   x_errorcode := 0;
   x_to_status := 0;
   x_dynamic_ok := 0;

  -- Bug 7427382, Modified the sn_mask array table to include statuses 6, 7 and 8 also.

   L_sn_mask(1) := 'I0110100010000004';
   L_sn_mask(2) := 'I0000011010000014';
   L_sn_mask(3) := 'R0110001001000003';
   L_sn_mask(4) := 'R0000101991000013';
   L_sn_mask(5) := 'R0000011001000011';
   L_sn_mask(6) := '00000000000000000';
   L_sn_mask(7) := 'R0110001001000003';
   L_sn_mask(8) := 'R0000101001000013';
   L_sn_mask(9) := 'I0110100010000004';
   L_sn_mask(10):= '00000000000000000';
   L_sn_mask(11):= 'R0110110011000003';
   L_sn_mask(12):= 'I0110110010000004';
   L_sn_mask(13):= '00000000000000000';
   L_sn_mask(14):= 'R0110001001101003';
   L_sn_mask(15):= 'R0000101001101013';
   L_sn_mask(16):= 'I0110100010000005';
   L_sn_mask(17):= '00000000000000000';
   /*---------------------------------------------------------------------
   | Determine which group the transactions to.  the value of
   |  group will be used to provide the appropriate offset in the sn_mask
   |  array table
   +----------------------------------------------------------------------*/
   -- Sales Order [SO] - 2
   -- RMA              - 12
   -- SO RMA GROUP     - 0
   IF P_txn_src_type_id in (2,12) then
       L_group := 0;
   ELSE
      IF P_txn_act_id = 2 THEN                -- SUBXFR
         L_group := 10 ;                      -- SUB_XFER_GROUP
      ELSIF P_txn_act_id IN ( 12, 21 ) THEN   -- INTERECEIPT(12) or INTSHIP(21)
         L_group := 13 ;                      -- INTRANS_GROUP
      ELSE                                    -- Default Value
         L_group := 6 ;                       -- STD_GROUP
      END IF;
   END IF;
   L_group := L_group + 1;    -- It starts from 0th position, just to avoid
   x_mask := L_sn_mask(L_group);
   /*---------------------------------------------------------------------
   | Match up the transaction with the appropriate mas and get the assigned
   | status.  If there is no match, then to_status will still be zero after
   | the loop
   +-----------------------------------------------------------------------*/
   WHILE ( substr(x_mask,1,1) <> '0' )
   LOOP
      if ( substr(x_mask,1,1) = P_receipt_issue_flag ) AND
         ( substr(x_mask,P_serial_control+1,1) = '1' ) then
         x_to_status := to_number(substr(x_mask,17,1));  -- get the 17th character from mask
         x_dynamic_ok := to_number(substr(x_mask,16,1)); -- get the 16th character from mask
         exit;
      end if;
      L_group := L_group + 1;  -- go to next mask group
      x_mask := L_sn_mask(L_group);
   END LOOP;

   IF x_to_status = 0  then
      FND_MESSAGE.SET_NAME('INV', 'INV_INLTIS_SNGETMASK');
      FND_MSG_PUB.Add;
      x_errorcode := 123;
      return(FALSE);
   ELSE
      return(TRUE);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_errorcode := -1;
     return(FALSE);
END SNGetmask;

PROCEDURE update_msn
 (x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
   p_trxdate              IN    DATE,
   p_transaction_temp_id  IN    NUMBER,
   p_rev                  IN    VARCHAR2,
   p_lotnum               IN    VARCHAR2,
   p_orgid                IN    NUMBER,
   p_locid                IN    NUMBER, -- :lii,
   p_subinv               IN    VARCHAR2,
   p_trxsrctypid          IN    NUMBER,
   p_trxsrcid             IN    NUMBER,
   p_trx_act_id           IN    NUMBER,
   p_vendid               IN    NUMBER, -- :i_vendor_idi,
   p_venlot               IN    VARCHAR2,
   p_receipt_issue_type   IN    NUMBER,
   p_trxsname             IN    VARCHAR2,
   p_lstupdby             IN    NUMBER,
   p_parent_item_id       IN    NUMBER, -- :parent_item_i,
   p_parent_ser_num       IN    VARCHAR2, -- :parent_sn_i,
   p_ser_ctrl_code        IN    NUMBER,
   p_xfr_ser_ctrl_code    IN    NUMBER,
   p_trx_qty              IN    NUMBER,
   p_invitemid            IN    NUMBER,
   p_f_ser_num            IN    VARCHAR2,
   p_t_ser_num            IN    VARCHAR2,
   x_serial_updated      OUT NOCOPY NUMBER

) IS
   l_acct_prof_value VARCHAR2(1) := '';
   l_qty NUMBER := 0;
   l_last_status NUMBER := 0;
   l_to_status NUMBER := 0;
   l_canonical_trx_date DATE;
   l_sys_date           DATE := SYSDATE;
   l_init_date          DATE := trunc(sysdate);
   l_cg_id              NUMBER := nvl(inv_cost_group_pub.g_cost_group_id, 0);
   l_upd_count          NUMBER := 0;
   l_receipt_issue_flag VARCHAR2(1);
   l_error_code         NUMBER;
   l_dynamic_ok         NUMBER;
   l_mask               VARCHAR2(17); -- Bug 7427382
   l_status             BOOLEAN;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   null;

   IF (p_trx_act_id = inv_globals.g_action_stgxfr) THEN
      IF (l_debug = 1) THEN
         invtrace('The transaction action is staging transfer. Bulk processing of serials are not supported for this transaction');

      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF nvl(fnd_profile.value('INV_RESTRICT_RCPT_SER'), '2') = '1' THEN
        l_acct_prof_Value := 'Y';
   else
        l_acct_prof_value := 'N';
   end if;

   if( p_trx_qty < 0 ) THEN
        l_qty := -1 * p_trx_qty;
   else
        l_qty := p_trx_qty;
   end if;
   IF (l_debug = 1) THEN
      invtrace('l_acct_prof_value = ' || l_acct_prof_value);
      invtrace('p_trxdate = ' || p_trxdate);
      invtrace('p_transaction_temp_id = ' || p_transaction_temp_id);
      invtrace('p_rev = ' || p_rev);
      invtrace('p_lotnum = ' || p_lotnum);
      invtrace('p_orgid = ' || p_orgid);
      invtrace('p_locid = ' || p_locid);
      invtrace('p_subinv = ' || p_subinv);
      invtrace('p_trxsrctypid = ' || p_trxsrctypid);
      invtrace('p_trxsrcid = ' || p_trxsrcid);
      invtrace('p_trx_act_id = ' || p_trx_act_id);
      invtrace('p_vendid = ' || p_vendid);
      invtrace('p_venlot = ' || p_venlot);
      invtrace('p_receipt_issue_type = ' || p_receipt_issue_type);
      invtrace('p_trxsname = ' || p_trxsname);
      invtrace('p_lstupdby = ' || p_lstupdby);
      invtrace('p_parent_item_id = ' || p_parent_item_id);
      invtrace('p_parent_Ser_num = ' || p_parent_Ser_num);
      invtrace('p_ser_ctrl_code = ' || p_ser_ctrl_code);
      invtrace('p_xfr_ser_ctrl_code = ' || p_xfr_ser_ctrl_code);
      invtrace('p_trx_qty = ' || p_trx_qty);
      invtrace('p_invitemid = ' || p_invitemid);
      invtrace('p_f_ser_num = ' || p_f_ser_num);
      invtrace('p_t_ser_num = ' || p_t_ser_num);
   END IF;

   SELECT current_status
   INTO l_last_status
   FROM mtl_serial_numbers
   WHERE inventory_item_id = p_invitemid
     AND serial_number = p_f_ser_num;

   IF (l_debug = 1) THEN
      invtrace('l_last_status = ' || l_last_status);
   END IF;

   if( p_receipt_issue_type = 1 ) THEN
        l_receipt_issue_flag := 'I';
   else
        l_receipt_issue_flag := 'R';
   end if;

   IF (l_debug = 1) THEN
      invtrace('l_receipt_issue_flag = ' || l_receipt_issue_flag);
   END IF;

   l_status := SNGetMask(p_txn_act_id => p_trx_act_id,
                         p_txn_src_type_id => p_trxsrctypid,
                         p_serial_control  => p_ser_ctrl_code,
                         x_to_status       => l_to_status,
                         x_dynamic_ok      => l_dynamic_ok,
                         p_receipt_issue_flag => l_receipt_issue_flag,
                         x_mask               => l_mask,
                         x_errorcode          => l_error_code) ;

   IF (l_debug = 1) THEN
      invtrace('l_mask = ' || l_mask);
   END IF;

   if( l_status = FALSE ) THEN
      IF (l_debug = 1) THEN
         invtrace('error from SNGetMask');
      END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   IF (l_debug = 1) THEN
      invtrace('l_to_status is ' || l_to_status);
   END IF;

   IF( p_trx_qty < 0 AND p_trx_act_id = 2 ) THEN
        l_status_after_p1 := l_to_status;
        l_status_before_p1 := l_last_status;
        x_return_status := 'S';
        x_msg_count := 0;
        x_msg_data := NULL;
        x_serial_updated := abs(p_trx_qty);
        IF( MSN_UPDATE_FIRST_PASS  ) THEN
            MSN_UPDATE_FIRST_PASS := FALSE;
        END if;
        return;
   else
        IF msn_update_first_pass THEN
           l_status_after_p1 := l_last_status;
           l_status_before_p1 := l_last_status;
        end if;
   end if;

   IF (l_debug = 1) THEN
      invtrace('About to call fnd_date.canonical_to_date');
      --l_canonical_trx_date := fnd_date.canonical_to_date(p_trxdate);
      invtrace('After call fnd_date.canonical_to_date');
   END IF;

   if( l_to_status in (1, 6) ) THEN
        UPDATE MTL_SERIAL_NUMBERS MSN
        SET msn.current_status = l_to_status,
            msn.initialization_date = l_init_date,
            msn.completion_date = null,
                     msn.SHIP_DATE = NULL,
         msn.REVISION = NULL,
         msn.LOT_NUMBER = NULL,
         msn.GROUP_MARK_ID = NULL,
         msn.LINE_MARK_ID = NULL,
         msn.LOT_LINE_MARK_ID = NULL,
         msn.CURRENT_ORGANIZATION_ID = p_orgid,
         msn.CURRENT_LOCATOR_ID = NULL,
         msn.CURRENT_SUBINVENTORY_CODE = NULL,
         msn.ORIGINAL_WIP_ENTITY_ID = NULL,
         msn.ORIGINAL_UNIT_VENDOR_ID = NULL,
         msn.VENDOR_LOT_NUMBER = NULL,
         msn.LAST_RECEIPT_ISSUE_TYPE = p_receipt_issue_type,
         msn.LAST_TXN_SOURCE_ID =NULL,
         msn.LAST_TXN_SOURCE_TYPE_ID = NULL,
         msn.LAST_TXN_SOURCE_NAME = NULL,
         msn.LAST_UPDATE_DATE = l_sys_date,
         msn.LAST_UPDATED_BY = p_lstupdby,
         msn.PARENT_ITEM_ID = p_parent_item_id, -- :parent_item_i,
         msn.PARENT_SERIAL_NUMBER = p_parent_ser_num, -- :parent_sn_i,
         msn.PREVIOUS_STATUS = l_status_after_p1, -- l_last_status, -- p_last_status,
         msn.STATUS_ID = NULL,
         msn.ORGANIZATION_TYPE = 2,
         msn.OWNING_ORGANIZATION_ID = p_orgid,
         msn.OWNING_TP_TYPE = 2,
         msn.PLANNING_ORGANIZATION_ID = p_orgid,
         msn.PLANNING_TP_TYPE = 2
         WHERE
             msn.INVENTORY_ITEM_ID = p_invitemid
         AND msn.SERIAL_NUMBER BETWEEN p_f_ser_num AND p_t_ser_num
         AND decode( msn.CURRENT_STATUS, 6, 1, msn.CURRENT_STATUS ) = l_status_after_p1 -- l_last_status -- p_last_status
         AND Nvl(msn.owning_tp_type,2) <> 1
         AND Nvl(msn.owning_organization_id,msn.current_organization_id) = msn.current_organization_id
         AND inv_serial_number_pub.valsn(
                p_trxsrctypid,       -- trx_src_typ_id       IN   NUMBER,
                p_trx_act_id,        -- trx_action_id        IN   NUMBER,
                p_rev,               -- revision             IN   VARCHAR2,
                p_subinv,            -- curr_subinv_code     IN   VARCHAR2,
                p_locid, -- :lii,         -- locator_id           IN   NUMBER,
                p_invitemid,         -- item                 IN   NUMBER,
                p_orgid,             -- curr_org_id          IN   NUMBER,
                p_lotnum,            -- lot                  IN   VARCHAR2,
                msn.serial_number,  -- curr_ser_num         IN   VARCHAR2,
                p_ser_ctrl_code,     -- ser_num_ctrl_code    IN   NUMBER,
                p_xfr_ser_ctrl_code,
                p_trx_qty,         -- trx_qty              IN   NUMBER,
                l_acct_prof_value,    -- acct_prof_value      IN   VARCHAR2,
                l_mask,            -- P_mask               IN   VARCHAR2,
                msn.current_status,  /* db_current_status  IN   NUMBER, */
                msn.current_organization_id,    -- db_current_organization_id IN   NUMBER,
                msn.revision,                   -- db_revision          IN   VARCHAR2,
                msn.lot_number,                 -- db_lot_number        IN   VARCHAR2,
                msn.current_subinventory_code,  -- db_current_subinventory_code IN   VARCHAR2,
                msn.current_locator_id,         -- db_current_locator_id IN   NUMBER,
                decode( nvl( msn.original_wip_entity_id, -1 ), -1, -1 , 1 ),  -- db_wip_ent_id_ind IN  NUMBER,
                msn.last_txn_source_type_id     -- db_lst_txn_src_typ_id IN NUMBER
         ) = l_to_status;

   ELSE /* To status not in 1,6 */

      -- l_canonical_trx_date := NULL;
      --l_canonical_trx_date := fnd_date.canonical_to_date( p_trxdate );
      --dbms_output.put_line('tostatus not in 1, 6');
      IF (l_debug = 1) THEN
         invtrace( 'To Status not in 1,6');
      END IF;

      UPDATE  MTL_SERIAL_NUMBERS msn
      SET
         msn.CURRENT_STATUS = l_to_status, -- p_current_status,
         msn.COMPLETION_DATE = NVL( msn.COMPLETION_DATE, p_trxdate ),
         msn.SHIP_DATE = DECODE( l_to_status, 3, NULL, NVL( msn.SHIP_DATE, p_trxdate ) ),
         msn.REVISION = DECODE( l_last_status, 3, msn.REVISION, p_rev ),
         msn.LOT_NUMBER = DECODE( l_last_status, 3, msn.LOT_NUMBER, p_lotnum ),
         msn.CURRENT_ORGANIZATION_ID = p_orgid,
         msn.CURRENT_LOCATOR_ID = p_locid, -- :lii,
         msn.CURRENT_SUBINVENTORY_CODE = p_subinv,
         msn.ORIGINAL_WIP_ENTITY_ID = decode( p_trxsrctypid, 5, p_trxsrcid, 2, NULL, msn.ORIGINAL_WIP_ENTITY_ID ),
         msn.ORIGINAL_UNIT_VENDOR_ID = NVL( msn.ORIGINAL_UNIT_VENDOR_ID, p_vendid ), -- :i_vendor_idi),
         msn.VENDOR_LOT_NUMBER = NVL( msn.VENDOR_LOT_NUMBER,p_venlot ),
         msn.LAST_RECEIPT_ISSUE_TYPE = p_receipt_issue_type,
         msn.LAST_TXN_SOURCE_ID = p_trxsrcid,
         msn.LAST_TXN_SOURCE_TYPE_ID = p_trxsrctypid,
         msn.LAST_TXN_SOURCE_NAME = p_trxsname,
         msn.GROUP_MARK_ID = NULL,
         msn.LINE_MARK_ID = NULL,
         msn.LOT_LINE_MARK_ID = NULL,
         msn.LAST_UPDATE_DATE = l_sys_date,
         msn.LAST_UPDATED_BY = p_lstupdby,
         msn.PARENT_ITEM_ID = p_parent_item_id, -- :parent_item_i,
         msn.PARENT_SERIAL_NUMBER = p_parent_ser_num, -- :parent_sn_i,
         msn.COST_GROUP_ID =  l_cg_id,
         msn.ORGANIZATION_TYPE = 2,
         msn.OWNING_ORGANIZATION_ID = p_orgid,
         msn.OWNING_TP_TYPE = 2,
         msn.PLANNING_ORGANIZATION_ID = p_orgid,
         msn.PLANNING_TP_TYPE = 2
         WHERE
             msn.INVENTORY_ITEM_ID = p_invitemid
         AND msn.SERIAL_NUMBER BETWEEN p_f_ser_num AND p_t_ser_num
         AND decode( msn.CURRENT_STATUS, 6, 1, msn.CURRENT_STATUS ) = l_last_status
         AND Nvl(msn.owning_organization_id,msn.current_organization_id) = msn.current_organization_id
         AND Nvl(msn.owning_tp_type,2) <> 1
         AND inv_serial_number_pub.valsn(
                p_trxsrctypid,       -- trx_src_typ_id       IN   NUMBER,
                p_trx_act_id,        -- trx_action_id        IN   NUMBER,
                p_rev,               -- revision             IN   VARCHAR2,
                p_subinv,            -- curr_subinv_code     IN   VARCHAR2,
                p_locid, -- :lii,         -- locator_id           IN   NUMBER,
                p_invitemid,         -- item                 IN   NUMBER,
                p_orgid,             -- curr_org_id          IN   NUMBER,
                p_lotnum,            -- lot                  IN   VARCHAR2,
                msn.serial_number,  -- curr_ser_num         IN   VARCHAR2,
                p_ser_ctrl_code,     -- ser_num_ctrl_code    IN   NUMBER,
                nvl(p_xfr_ser_ctrl_code,1), -- p_xfr_ser_ctrl_code  IN   NUMBER
                p_trx_qty,         -- trx_qty              IN   NUMBER,
                l_acct_prof_value,    -- acct_prof_value      IN   VARCHAR2,
                l_mask,            -- P_mask               IN   VARCHAR2,
                msn.current_status,
                msn.current_organization_id,    -- db_current_organization_id IN   NUMBER,
                msn.revision,                   -- db_revision          IN   VARCHAR2,
                msn.lot_number,                 -- db_lot_number        IN   VARCHAR2,
                msn.current_subinventory_code,  -- db_current_subinventory_code IN   VARCHAR2,
                msn.current_locator_id,         -- db_current_locator_id IN   NUMBER,
                decode( nvl( msn.original_wip_entity_id, -1 ), -1, -1 , 1 ),  -- db_wip_ent_id_ind IN  NUMBER,
                msn.last_txn_source_type_id     -- db_lst_txn_src_typ_id IN NUMBER
         ) > 0;

   end if;

   l_upd_count := SQL%ROWCOUNT;
   IF (l_debug = 1) THEN
      invtrace( 'updated=' || to_char( l_upd_count ));
   END IF;

   IF ( l_upd_count <> l_qty ) THEN
      IF (l_debug = 1) THEN
         invtrace( ' Updated not the same as the transaction. trx qty: ' || l_qty);
      END IF;
      x_return_status := 'W';
      x_msg_count := 0;
      x_msg_data  := 'Can only update ' || to_char( l_upd_count ) || ' of ' ||
                      to_char( l_qty ) || '. Rejecting update';
    ELSE
      IF (l_debug = 1) THEN
         invtrace( ' Updated  same as the transaction. Success');
      END IF;
      x_serial_updated := l_upd_count;
      x_return_status := 'S';
      x_msg_count := 0;
      x_msg_data := NULL;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := 'U';
        x_msg_data := substr(sqlerrm, 1, 255);
        x_msg_count := 1;
        IF (l_debug = 1) THEN
           invtrace( ' Unexpected error in update_msn API');
        END IF;

   WHEN OTHERS THEN
      x_return_status := 'U';
      x_msg_data := substr( sqlerrm,1 , 255);
      IF (l_debug = 1) THEN
         invtrace( 'in when others');
         invtrace( 'x_return_status=' || x_return_status);
         invtrace( 'x_msg_data = ' || x_msg_data );
         IF (l_debug = 1) THEN
           invtrace( ' Error in update_msn API');
        END IF;
      END IF;

END update_msn;

FUNCTION getGroupId(
   p_trx_source_type_id         IN NUMBER,
   p_trx_action_id              IN NUMBER) RETURN NUMBER
IS
   l_groupId NUMBER := 0;
   /*
   Trx_source_Type_id
  ------------------------
   2 - Sales Order
   12 - RMA
   8  - Internal Order
   7  - Internal Requisition
   16 - Project Contracts

    TRX Action:
    ------------------
    2 - Sub Transfer
    5 - Planning Transfer
    6 - Consign Transfer
    12 - Intransit receipt
    21 - Intransit Shipment
    50 - pack
    51 - unpack
    52 - LPN Split

    Group Id
    1 - SO_RMA_GROUP
    2 - SUB_XFER_GROUP
    3 - INTRANS_GROUP
    4 - PACKUNPACK_GROUP
    5 - STD_GROUP
   */

BEGIN
  if( p_trx_source_Type_id in (2, 7, 8, 12, 16 )) THEN
      l_groupId := 1;
  else
      if( p_trx_action_id in ( 2, 5, 6)  ) THEN
        l_groupId := 2;
      elsif( p_trx_action_id in (12, 21) ) THEN
        l_groupId := 3;
      elsif( p_trx_action_id in (50, 51, 52 )) THEN
        l_groupId := 4;
      else
        l_groupId := 5;
      end if;
  END IF;
  return l_groupId;
END getGroupId;

FUNCTION validate_status(
   p_trx_src_type_id         IN number,
   p_trx_action_id           IN number,
   p_isIssue                 IN boolean,
   p_ser_num_ctrl_code       IN number,
   p_curr_status             IN number,
   p_last_trx_src_type_id    IN NUMBER,
   p_xfr_Ser_num_ctrl_code   IN NUMBER,
   p_isRestrictRcptSerial    IN NUMBER
) return number
IS
    --l_debug                NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_groupId              NUMBER := 0;
    l_newStatus            NUMBER := p_curr_status;
    l_isRestrictRcptSerial NUMBER := p_isRestrictRcptSerial;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
    if( l_debug = 1 ) then
        invtrace('inside validate_status, p_trx_src_type_id = ' || p_trx_src_type_id);
        invtrace('inside validate_status, p_trx_action_id = ' || p_trx_action_id);
        invtrace('inside validate_status, p_ser_num_ctrl_code = ' || p_ser_num_ctrl_code);
        invtrace('inside validate_status, p_curr_status = ' || p_curr_status);
        invtrace('inside validate_status, p_last_trx_src_type_id = ' || p_last_trx_src_type_id);
        invtrace('inside validate_status, p_xfr_ser_num_ctrl_code = ' || p_xfr_ser_num_ctrl_code);
    end if;
    l_groupId := getGroupId(p_trx_src_type_id, p_trx_action_id);

    --l_isRestrictRcptSerial := fnd_profile.value('INV_RESTRICT_RCPT_SER');

    /*if( l_debug = 1 ) then
        invtrace('l_groupId = ' || l_groupId);
    end if;*/

    if( l_groupId = 1 )THEN
        if( p_isIssue ) THEN
            if( p_ser_num_ctrl_code in (2, 3, 5)) THEN
                if( p_trx_src_type_id = 8 AND p_trx_action_id = 21 ) THEN
                    if( p_curr_status = 3 ) THEN
                       if( p_xfr_ser_num_ctrl_code = 1 ) THEN
                            l_newStatus := 4;
                       else
                            l_newStatus := 5;
                       end if;
                    end if;
                elsif( p_curr_status = 3 ) THEN
                    l_newStatus := 4;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -1;
                end if;
            elsif( p_ser_num_ctrl_code = 6 ) THEN
                if( p_trx_src_type_id = 8 AND p_trx_action_id = 21 ) THEN
                    if( p_curr_status in (1, 3, 6) ) then
                        l_newStatus := 5;
                    end if;
                elsif( p_curr_status in (1, 3, 6) ) THEN
                   l_newStatus := 4;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -2;
                end if;
           end if;
        else -- p_isIssue is false;
           if( p_ser_num_ctrl_code in (2, 3, 5) ) THEN
                if( p_curr_status in (1, 4, 6)) THEN
                    l_newStatus := 3;
                else
                    if( (p_trx_src_type_id in (12, 7)) AND (p_curr_status in (5, 7))) THEN
                        l_newStatus := 4;
                    else
                        --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                        --FND_MSG_PUB.ADD;
                        return -3;
                    end if;
                end if;
           elsif( p_ser_num_ctrl_code = 6 ) THEN
                if( p_last_trx_src_type_id = 12 AND p_curr_status = 1 AND l_isRestrictRcptSerial = 1 ) THEN
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -1;
                elsif( (p_trx_src_type_id = 7 OR p_trx_action_id = 12) AND (p_curr_status in (5, 7 ))) THEN
                    l_newStatus := 1;
                else
                    if( p_curr_status in (1, 4, 5, 6, 7 ) ) THEN
                        l_newStatus := 1;
                    else
                        --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                        --FND_MSG_PUB.ADD;
                        return -1;
                    end if;
                end if;
           end if;
        end if;
   elsif( l_groupId = 2 ) THEN
        if( p_ser_num_ctrl_code in (2, 3, 5)) THEN
            if( p_curr_status = 3 ) THEN
                l_newStatus := 3;
            else
                --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                --FND_MSG_PUB.ADD;
                return -1;
            end if;
        end if;
   elsif( l_groupId = 3 ) THEN
        if( p_isIssue ) THEN
            if( p_ser_num_ctrl_code in (2, 3, 5) ) then
                if( p_curr_status = 3 ) THEN
                    if( p_xfr_ser_num_ctrl_code = 1 ) THEN
                        l_newStatus := 4;
                    else
                        l_newStatus := 5;
                    end if;
                else
                   --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                   --FND_MSG_PUB.ADD;
                   return -1;
                end if;
            end if;
        else
            if( p_ser_num_ctrl_code in (2, 3, 5) ) THEN
                if( p_curr_status in (1, 4, 5, 6, 7) ) THEN
                    l_newStatus := 3;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -1;
                end if;
            elsif( p_ser_num_ctrl_code = 6 ) THEN
                if( p_curr_status in (5,7) AND ( p_trx_src_type_id = 7 OR p_trx_action_id = 12) ) THEN
                   l_newStatus := 1;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -1;
                end if;
            end if;
        end if;
   elsif( l_groupId = 4 ) THEN
        if( p_curr_status <> 3 ) THEN
            --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
            --FND_MSG_PUB.ADD;
            return -1;
        end if;
   elsif( l_groupId = 5 ) THEN
        if( p_isIssue ) THEN
           if( p_ser_num_ctrl_code in (2, 3, 5)) THEN
                if( p_curr_status = 3 ) then
                    l_newStatus := 4;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -1;
                end if;
           end if;
        else
           if( p_ser_num_ctrl_code in (2, 3, 5) ) THEN
               if( l_isRestrictRcptSerial = 1 AND p_trx_action_id = 27 AND
                    p_curr_status = 4 AND p_last_trx_src_Type_id = 2 ) THEN
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    return -1;
                end if;
                if( p_curr_status in (1, 4, 6)) THEN
                     if( p_trx_action_id = 3 AND p_xfr_ser_num_ctrl_code = 6 ) THEN
                         l_newStatus := 1;
                     else
                         l_newStatus := 4;
                     end if;
                else
                     if( (p_trx_src_type_id in (1, 5) AND p_curr_status = 5 )OR
                         (p_trx_src_type_id = 1 AND p_curr_status = 7 )) THEN
                          l_newStatus := 3;
                     else
                         --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                         --FND_MSG_PUB.ADD;
                         return -1;
                     end if;
                end if;
             end if;
        end if;
   end if;

   return l_newStatus;
End validate_status;

FUNCTION valsn(
   p_trx_src_type_id              IN   NUMBER,
   p_trx_action_id                IN   NUMBER,
   p_revision                     IN   VARCHAR2,
   p_curr_subinv_code             IN   VARCHAR2,
   p_locator_id                   IN   NUMBER,
   p_item                         IN   NUMBER,
   p_curr_org_id                  IN   NUMBER,
   p_lot                          IN   VARCHAR2,
   p_curr_ser_num                 IN   VARCHAR2,
   p_ser_num_ctrl_code            IN   NUMBER,
   p_xfr_ser_num_ctrl_code        IN   NUMBER,
   p_trx_qty                      IN   NUMBER,
   p_acct_prof_value              IN   VARCHAR2,
   p_mask                         IN   VARCHAR2,
   p_db_current_status            IN   NUMBER,
   p_db_current_organization_id   IN   NUMBER,
   p_db_revision                  IN   VARCHAR2,
   p_db_lot_number                IN   VARCHAR2,
   p_db_current_subinventory_code IN   VARCHAR2,
   p_db_current_locator_id        IN   NUMBER,
   p_db_wip_ent_id_ind            IN   NUMBER,
   p_db_lst_txn_src_type_id       IN   NUMBER
) RETURN NUMBER IS
   l_isIssue BOOLEAN := FALSE;

   l_newStatus NUMBER := 0;
   l_retval NUMBER := 0;
   l_parent_ser_number VARCHAR2(30) := '';
   l_isRestrictRcptSerial NUMBER;
   l_groupId NUMBER := 0;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   --null;
   IF (l_debug = 1) THEN
      invtrace('p_trx_src_type_id = ' || p_trx_src_type_id);
      invtrace('p_trx_action_id = ' || p_trx_action_id);
      invtrace('p_revision = ' || p_revision);
      invtrace('p_curr_subinv_code = ' || p_curr_subinv_code);
      invtrace('p_locator_id = ' || p_locator_id);
      invtrace('p_item = ' || p_item);
      invtrace('p_curr_org_id = ' || p_curr_org_id);
      invtrace('p_lot = ' || p_lot);
      invtrace('p_curr_ser_num = ' || p_curr_ser_num);
      invtrace('p_ser_num_ctrl_code = ' || p_ser_num_ctrl_code);
      invtrace('p_xfr_ser_num_ctrl_code = ' || p_xfr_ser_num_ctrl_code);
      invtrace('p_trx_qty = ' || p_trx_qty);
      invtrace('p_acct_prof_value = ' || p_acct_prof_value);
      invtrace('p_mask = ' || p_mask);
      invtrace('p_db_current_status = ' || p_db_current_status);
      invtrace('p_db_current_organization_id = ' || p_db_current_organization_id);
      invtrace('p_db_revision = ' || p_db_revision);
      invtrace('p_db_lot_number = ' || p_db_lot_number);
      invtrace('p_db_current_subinventory_code = ' || p_db_current_subinventory_code);
      invtrace('p_db_current_locator_id = ' || p_db_current_locator_id);
      invtrace('p_db_wip_ent_id_ind = ' || p_db_wip_ent_id_ind);
      invtrace('p_db_lst_txn_src_type_id = ' || p_db_lst_txn_src_type_id);
   END IF;

   if( p_trx_qty < 0 ) THEN
      l_isIssue := TRUE;
      IF (l_debug = 1) THEN
         invtrace('l_isIssue is true');
      END IF;
   else
      l_isIssue := FALSE;
      IF (l_debug = 1) THEN
         invtrace('l_isIssue is false');
      END IF;
   end if;

   IF p_acct_prof_value = 'Y' THEN
      l_isRestrictRcptSerial := 1;
   else
      l_isRestrictRcptSerial := 0;
   end if;

   -- getting the group id
  if( p_trx_src_Type_id in (2, 7, 8, 12, 16 )) THEN
      l_groupId := 1;
  else
      if( p_trx_action_id in ( 2, 5, 6)  ) THEN
        l_groupId := 2;
      elsif( p_trx_action_id in (12, 21) ) THEN
        l_groupId := 3;
      elsif( p_trx_action_id in (50, 51, 52 )) THEN
        l_groupId := 4;
      else
        l_groupId := 5;
      end if;
  END IF;

  --dbms_output.put_line('inside valsn, l_groupId = ' || l_groupId);
  IF (l_debug = 1) THEN
     invtrace('substr(p_mask, pdbcurrstats+7) = ' || substr(p_mask, p_db_current_status+7, 1));
     invtrace('l_groupId = ' || l_groupId);
  END IF;

   IF substr( P_mask, p_db_current_status + 7, 1 )= '0' THEN
      -- return to_number( 'A' );
      -- ppush( 'avd_debug','db_current_status='|| to_char( db_current_status ) );
      -- ppush( 'avd_debug','curr_ser_num='|| curr_ser_num );
      -- ppush( 'avd_debug', '923');
      return -923;
   END IF;

      -- Bug 7427382, supporting statuses 6, 7 and 8 also.
   IF ( p_db_current_status = -1 or p_db_current_status = 2 or
        p_db_current_status < 1 or p_db_current_status > 8 or p_db_current_status is NULL ) THEN
      --fnd_message.set_name( 'INV', 'INV_INVALID_SERIAL' );
      return  -913;
   END IF;

  -- validate status
    if( l_groupId = 1 )THEN
        if( l_isIssue ) THEN
            if( p_ser_num_ctrl_code in (2, 3, 5)) THEN
                if( p_trx_src_type_id = 8 AND p_trx_action_id = 21 ) THEN
                    if( p_db_current_status = 3 ) THEN
                       if( nvl(p_xfr_ser_num_ctrl_code, 0) = 1 ) THEN
                            l_newStatus := 4;
                       else
                            l_newStatus := 5;
                       end if;
                    end if;
                elsif( p_db_current_status = 3 ) THEN
                    l_newStatus := 4;
                else
                    l_retval := -901;
                end if;
            elsif( p_ser_num_ctrl_code = 6 ) THEN
                if( p_trx_src_type_id = 8 AND p_trx_action_id = 21 ) THEN
                    if( p_db_current_status in (1, 3, 6) ) then
                        l_newStatus := 5;
                    end if;
                elsif( p_db_current_status in (1, 3, 6) ) THEN
                   l_newStatus := 4;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    l_retval := -902;
                end if;
           end if;
        else -- p_isIssue is false;
           if( p_ser_num_ctrl_code in (2, 3, 5) ) THEN
                if( p_db_current_status in (1, 4, 6)) THEN
                    l_newStatus := 3;
                else
                    if( (p_trx_src_type_id in (12, 7)) AND (p_db_current_status in (5, 7))) THEN
                        l_newStatus := 4;
                    else
                        --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                        --FND_MSG_PUB.ADD;
                        l_retval := -903;
                    end if;
                end if;
           elsif( p_ser_num_ctrl_code = 6 ) THEN
                if( p_db_lst_txn_src_type_id = 12 AND p_db_current_status = 1 AND l_isRestrictRcptSerial = 1 ) THEN
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    l_retval := -904;
                elsif( (p_trx_src_type_id = 7 OR p_trx_action_id = 12) AND (p_db_current_status in (5, 7 ))) THEN
                    l_newStatus := 1;
                else
                    if( p_db_current_status in (1, 4, 5, 6, 7 ) ) THEN
                        l_newStatus := 1;
                    else
                        --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                        --FND_MSG_PUB.ADD;
                        l_retval := -905;
                    end if;
                end if;
           end if;
        end if;
   elsif( l_groupId = 2 ) THEN
        if( p_ser_num_ctrl_code in (2, 3, 5)) THEN
            if( p_db_current_status = 3 ) THEN
                l_newStatus := 3;
            else
                --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                --FND_MSG_PUB.ADD;
                l_retval := -906;
            end if;
        end if;
   elsif( l_groupId = 3 ) THEN
        if( l_isIssue ) THEN
            if( p_ser_num_ctrl_code in (2, 3, 5) ) then
                if( p_db_current_status = 3 ) THEN
                    if( p_xfr_ser_num_ctrl_code = 1 ) THEN
                        l_newStatus := 4;
                    else
                        l_newStatus := 5;
                    end if;
                else
                   --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                   --FND_MSG_PUB.ADD;
                   l_retval := -907;
                end if;
            end if;
        else
            if( p_ser_num_ctrl_code in (2, 3, 5) ) THEN
                if( p_db_current_status in (1, 4, 5, 6, 7) ) THEN
                    l_newStatus := 3;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    l_retval := -908;
                end if;
            elsif( p_ser_num_ctrl_code = 6 ) THEN
                if( p_db_current_status in (5,7) AND ( p_trx_src_type_id = 7 OR p_trx_action_id = 12) ) THEN
                   l_newStatus := 1;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    l_retval := -908;
                end if;
            end if;
        end if;
   elsif( l_groupId = 4 ) THEN
        if( p_db_current_status <> 3 ) THEN
            --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
            --FND_MSG_PUB.ADD;
            l_retval := -909;
        end if;
   elsif( l_groupId = 5 ) THEN
        --dbms_output.put_line('standard group');
        if( l_isIssue ) THEN
           if( p_ser_num_ctrl_code in (2, 3, 5)) THEN
                if( p_db_current_status = 3 ) then
                    l_newStatus := 4;
                else
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    l_retval := -910;
                end if;
           end if;
        else
           --dbms_output.put_line('inside receipt part');
           if( p_ser_num_ctrl_code in (2, 3, 5) ) THEN
               if( l_isRestrictRcptSerial = 1 AND p_trx_action_id = 27 AND
                    p_db_current_status = 4 AND p_db_lst_txn_src_Type_id = 2 ) THEN
                    --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                    --FND_MSG_PUB.ADD;
                    l_retval := -911;
                end if;
                if( p_db_current_status in (1, 4, 6)) THEN
                     if( p_trx_action_id = 3 AND p_xfr_ser_num_ctrl_code = 6 ) THEN
                         l_newStatus := 1;
                     else
                         l_newStatus := 3;
                     end if;
                else
                     if( (p_trx_src_type_id in (1, 5) AND p_db_current_status = 5 )OR
                         (p_trx_src_type_id = 1 AND p_db_current_status = 7 )) THEN
                          l_newStatus := 3;
                     else
                         --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SERIAL');
                         --FND_MSG_PUB.ADD;
                         l_retval := -912;
                     end if;
                end if;
             end if;
        end if;
   end if;

   /*l_NewStatus := validate_Status(p_trx_src_type_id, p_trx_action_id, l_isIssue, p_ser_num_ctrl_code, p_db_current_status,
        p_db_lst_txn_src_type_id, p_xfr_ser_num_ctrl_code, l_isRestrictRcptSerial);*/

   IF ( ( p_db_current_status = 3 OR p_db_current_status = 1 )
        AND p_db_current_organization_id <> p_curr_org_id ) THEN
      --fnd_message.set_name( 'INV', 'INV_SER_ORG_INVALID' );
      l_retval := -914;
   END IF;


   IF (p_db_current_status = 3) THEN
      IF (p_db_revision IS NOT NULL AND p_db_revision <> p_revision ) THEN

         --fnd_message.set_name('INV', 'INV_SER_REV_INVALID');
         --fnd_message.set_Token('TOKEN1', p_db_Revision);
         --fnd_message.set_Token('TOKEN2', p_revision);
         l_retval := -915;
      END IF;

      IF ( p_db_lot_number IS NOT NULL AND p_db_Lot_Number <> p_lot ) THEN
         --fnd_message.set_name('INV', 'INV_SER_LOT_INVALID');
         --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
         --fnd_message.set_Token('TOKEN2', p_db_Lot_Number);
         l_retval := -916;
      END IF;
   END IF;

   /* commented out because of db_lpn_id...do not know why used */
   -- IF (bool AND db_current_status = 3 AND db_lpn_id = 0) THEN
   IF (l_isIssue AND p_db_current_status = 3 ) THEN

      IF (p_db_current_subinventory_code IS NOT NULL AND
          p_db_current_subinventory_code <> p_curr_subinv_code) THEN
         --fnd_message.set_name('INV', 'INV_SER_SUB_INVALID');
         --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
         --fnd_message.set_Token('TOKEN2', p_db_current_subinventory_code);
         l_retval := -917;
      END IF;

      IF (p_db_current_locator_id <> 0 AND
          p_db_current_locator_id <> p_locator_id ) THEN
         --fnd_message.set_name('INV', 'INV_SER_LOC_INVALID');
         --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
         l_retval := -918;
      END IF;

   END IF;


    IF (p_trx_src_type_id = 5 ) THEN -- {
        IF ((p_trx_action_id = 31 AND p_db_current_status <> 1)
            OR (p_trx_action_id = 32)
            OR (p_trx_action_id = 27)) THEN -- {
            IF (p_db_wip_ent_id_ind = -1) THEN -- {
               --fnd_message.set_name('INV', 'INV_SER_STATUS_NA');
               --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
               l_retval := -919; -- return(FALSE);
            END IF; -- }
        END IF; -- }
    END IF; -- }

   -- For any receipt into warehouse for Serial Control - Dyn. at inv. receipt
   -- LOV does not validate the serial number entered.
   -- So any serial number with current status = 4 gets successfully received .

    IF ( (p_ser_num_ctrl_code = 5) AND (p_db_current_status = 4 )
         AND (p_trx_qty > 0 ) AND ( p_trx_action_id =27 )
         AND (p_trx_src_type_id <> 5) AND (p_db_wip_ent_id_ind <> -1)
         AND ( p_acct_prof_value = 'Y' /*1*/) AND (p_db_lst_txn_src_type_id = 5 )) THEN -- {

       --fnd_message.set_name('INV', 'INV_SER_STATUS_NA');
       --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
       l_retval := -920; -- return(FALSE);

    END IF; -- }

    IF ( (p_ser_num_ctrl_code = 5) AND (p_db_current_status = 4 )
         AND (p_trx_qty > 0 ) AND ( p_trx_action_id = 27 )
         AND (p_trx_src_type_id <> 5) AND (p_db_wip_ent_id_ind <> -1)
         AND (p_acct_prof_value = 'Y' /*1*/) AND (p_db_lst_txn_src_type_id = 6 )
         AND (p_trx_src_type_id <> 6 )) THEN -- {

       --fnd_message.set_name('INV', 'INV_SER_STATUS_NA');
       --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
       l_retval := -920; -- return(FALSE);

    END IF; -- }

    IF ( (p_ser_num_ctrl_code = 5) AND (p_db_current_status = 4 )
         AND (( p_trx_action_id = 31 ) OR (p_trx_action_id = 1))
         AND (p_trx_src_type_id = 5) AND (p_db_wip_ent_id_ind <> -1)
         AND (p_acct_prof_value = 'Y' /*1*/)
         AND ((p_db_lst_txn_src_type_id = 5) OR (p_db_lst_txn_src_type_id = 6 ))) THEN -- {

       --fnd_message.set_name('INV', 'INV_SER_STATUS_NA');
       --fnd_message.set_Token('TOKEN1', p_curr_ser_num);
       l_retval := -921; -- return(FALSE);

    END IF; -- }

    IF (l_debug = 1) THEN
       invtrace('l_retval = ' || l_retval);
    END IF;

   IF ( l_retval > -900 ) then
      RETURN l_newstatus;
      -- RETURN validateStatus(trx_src_typ_id, trx_action_id, bool, ser_num_ctrl_code, db_current_status);
   ELSE
      RETURN l_retval;
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
      RAISE;
END valsn;

PROCEDURE insertRangeUnitTrx(
            p_api_version               IN  NUMBER,
            p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER,
            p_fm_serial_number          IN VARCHAR2,
            p_to_serial_number          IN VARCHAR2,
            p_current_locator_id        IN NUMBER,
            p_subinventory_code         IN VARCHAR2,
            p_transaction_date          IN DATE,
            p_txn_src_id                IN NUMBER,
            p_txn_src_name              IN VARCHAR2,
            p_txn_src_type_id           IN NUMBER,
            p_transaction_id            IN NUMBER,
            p_transaction_action_id     IN NUMBER,
            p_transaction_temp_id       IN NUMBER,
            p_receipt_issue_type        IN NUMBER,
            p_customer_id               IN NUMBER,
            p_ship_id                   IN NUMBER,
            p_status_id                 IN NUMBER,
            x_return_status             OUT nOCOPY VARCHAR2,
            x_msg_count                 OUT nOCOPY NUMBER,
            x_msg_data                  OUT nOCOPY VARCHAR2)
IS
     l_api_version                 CONSTANT NUMBER := 1.0;
     l_api_name                    CONSTANT VARCHAR2(30):= 'insertRangeUnitTrx';
     l_userid                      NUMBER;
     l_loginid                     NUMBER;
     l_serial_control_code         NUMBER;
     l_attributes_default          INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;
     l_attributes_default_count    NUMBER;
     l_attributes_in               INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;
     l_column_idx                  BINARY_INTEGER := 44;
     l_return_status               VARCHAR2(1);
     l_msg_data                    VARCHAR2(2000);
     l_msg_count                   NUMBER;
     l_upd_count                   NUMBER;
     l_TIME_SINCE_NEW          mtl_serial_numbers_temp.TIME_SINCE_NEW%type;
     l_CYCLES_SINCE_NEW        mtl_serial_numbers_temp.CYCLES_SINCE_NEW%type;
     l_TIME_SINCE_OVERHAUL     mtl_serial_numbers_temp.TIME_SINCE_OVERHAUL%type := NULL;
     l_CYCLES_SINCE_OVERHAUL   mtl_serial_numbers_temp.CYCLES_SINCE_OVERHAUL%type;
     l_TIME_SINCE_REPAIR       mtl_serial_numbers_temp.TIME_SINCE_REPAIR%type;
     l_CYCLES_SINCE_REPAIR     mtl_serial_numbers_temp.CYCLES_SINCE_REPAIR%type;
     l_TIME_SINCE_VISIT        mtl_serial_numbers_temp.TIME_SINCE_VISIT%type;
     l_CYCLES_SINCE_VISIT      mtl_serial_numbers_temp.CYCLES_SINCE_VISIT%type;
     l_TIME_SINCE_MARK         mtl_serial_numbers_temp.TIME_SINCE_MARK%type;
     l_CYCLES_SINCE_MARK       mtl_serial_numbers_temp.CYCLES_SINCE_MARK%type;
     l_NUMBER_OF_REPAIRS       mtl_serial_numbers_temp.NUMBER_OF_REPAIRS%type;


     l_sys_date date := NULL;
     l_date2    date := NULL;
     l_date23   date := NULL;
     l_date24   date := NULL;
     l_date25   date := NULL;
     l_date26   date := NULL;
     l_date27   date := NULL;
     l_date28   date := NULL;
     l_date29   date := NULL;
     l_date30   date := NULL;
     l_date31   date := NULL;
     l_date32   date := NULL;

     l_num33    NUMBER := NULL;
     l_num34    NUMBER := NULL;
     l_num35    NUMBER := NULL;
     l_num36    NUMBER := NULL;
     l_num37    NUMBER := NULL;
     l_num38    NUMBER := NULL;
     l_num39    NUMBER := NULL;
     l_num40    NUMBER := NULL;
     l_num41    NUMBER := NULL;
     l_num42    NUMBER := NULL;

        cursor serial_temp_csr(p_transaction_temp_id NUMBER) is
            select SERIAL_ATTRIBUTE_CATEGORY
                   , fnd_date.date_to_canonical(ORIGINATION_DATE )
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
                   , fnd_date.date_to_canonical(D_ATTRIBUTE1 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE2 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE3 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE4 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE5 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE6 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE7)
                   , fnd_date.date_to_canonical(D_ATTRIBUTE8)
                   , fnd_date.date_to_canonical( D_ATTRIBUTE9)
                   , fnd_date.date_to_canonical(D_ATTRIBUTE10 )
                   , to_char(N_ATTRIBUTE1 )
                   , to_char(N_ATTRIBUTE2)
                   , to_char(N_ATTRIBUTE3)
                   , to_char(N_ATTRIBUTE4)
                   , to_char(N_ATTRIBUTE5)
                   , to_char(N_ATTRIBUTE6)
                   , to_char(N_ATTRIBUTE7)
                   , to_char(N_ATTRIBUTE8)
                   , to_char( N_ATTRIBUTE9)
                   , to_char(N_ATTRIBUTE10)
                   , STATUS_ID
                   , TERRITORY_CODE
                   , TIME_SINCE_NEW
                   , CYCLES_SINCE_NEW
                   , TIME_SINCE_OVERHAUL
                   , CYCLES_SINCE_OVERHAUL
                   , TIME_SINCE_REPAIR
                   , CYCLES_SINCE_REPAIR
                   , TIME_SINCE_VISIT
                   , CYCLES_SINCE_VISIT
                   , TIME_SINCE_MARK
                   , CYCLES_SINCE_MARK
                   , NUMBER_OF_REPAIRS
            from mtl_serial_numbers_temp
            where transaction_temp_id = p_transaction_temp_id
            and fm_serial_number = p_fm_serial_number and to_serial_number = p_to_serial_number;
    l_input_idx BINARY_INTEGER;

    l_fm_serial_number VARCHAR2(30) := lpad(p_fm_serial_number, 30);
    l_to_serial_number VARCHAR2(30) := lpad(p_to_serial_number, 30);
    l_wms_installed BOOLEAN;
    l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      invtrace('Inside InsertRangeUnitTrx');
      invtrace('l_fm_serial_number is ' || l_fm_serial_number);
      invtrace('l_to_serial_number is ' || l_to_serial_number);
   END IF;

   --Bug# 6825191, Commenting out the code below.
   --It is safe to comment the following code because
   -- 1. variables G_first_row_of_trx, G_first_row_trx_tmp_id are
   --    not referenced anytime later.
   -- 2. having this code introduces two problems
   --    a. It inserts MUT only for the first MSNT in multiple MSNT scenario.
   --    b. It does not insert MUT's for receipt side in transfer transaction flows.
/*
   IF ( G_first_row_of_trx ) THEN
      IF (l_debug = 1) THEN
         invtrace('setting G_first_row_of_trx');
      END IF;

      G_first_row_of_trx := FALSE;
      G_first_row_trx_tmp_id := p_transaction_temp_id ;
      IF (l_debug = 1) THEN
         invtrace('G_first_row_trx_tmp_id = ' || G_first_row_trx_tmp_id);
      END IF;
    ELSE
       IF ( p_transaction_temp_id <> g_first_row_trx_tmp_id ) THEN
          g_first_row_trx_tmp_id := p_transaction_temp_id;
       ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          RETURN;
       END IF;
    END IF;
*/
    -- Standard Start of API savepoint
    SAVEPOINT apiinsertserial_apipub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success

    /**IF (p_transaction_action_id = 3 AND g_firstscan = FALSE) THEN
      x_return_status  := fnd_api.g_ret_sts_success;
    ELSE**/
    x_return_status  := fnd_api.g_ret_sts_success;
    l_wms_installed  :=
      wms_install.check_install(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => NULL   --p_organization_id
      );

    IF (p_transaction_temp_id IS NOT NULL) THEN
       IF (l_debug = 1) THEN
          invtrace('p_transaction_temp_id is notnull');
       END IF;

      OPEN serial_temp_csr(p_transaction_temp_id);

      populateattributescolumn();

      FETCH serial_temp_csr
       INTO g_serial_attributes_tbl(1).column_value
          , g_serial_attributes_tbl(2).column_value
          , g_serial_attributes_tbl(3).column_value
          , g_serial_attributes_tbl(4).column_value
          , g_serial_attributes_tbl(5).column_value
          , g_serial_attributes_tbl(6).column_value
          , g_serial_attributes_tbl(7).column_value
          , g_serial_attributes_tbl(8).column_value
          , g_serial_attributes_tbl(9).column_value
          , g_serial_attributes_tbl(10).column_value
          , g_serial_attributes_tbl(11).column_value
          , g_serial_attributes_tbl(12).column_value
          , g_serial_attributes_tbl(13).column_value
          , g_serial_attributes_tbl(14).column_value
          , g_serial_attributes_tbl(15).column_value
          , g_serial_attributes_tbl(16).column_value
          , g_serial_attributes_tbl(17).column_value
          , g_serial_attributes_tbl(18).column_value
          , g_serial_attributes_tbl(19).column_value
          , g_serial_attributes_tbl(20).column_value
          , g_serial_attributes_tbl(21).column_value
          , g_serial_attributes_tbl(22).column_value
          , g_serial_attributes_tbl(23).column_value
          , g_serial_attributes_tbl(24).column_value
          , g_serial_attributes_tbl(25).column_value
          , g_serial_attributes_tbl(26).column_value
          , g_serial_attributes_tbl(27).column_value
          , g_serial_attributes_tbl(28).column_value
          , g_serial_attributes_tbl(29).column_value
          , g_serial_attributes_tbl(30).column_value
          , g_serial_attributes_tbl(31).column_value
          , g_serial_attributes_tbl(32).column_value
          , g_serial_attributes_tbl(33).column_value
          , g_serial_attributes_tbl(34).column_value
          , g_serial_attributes_tbl(35).column_value
          , g_serial_attributes_tbl(36).column_value
          , g_serial_attributes_tbl(37).column_value
          , g_serial_attributes_tbl(38).column_value
          , g_serial_attributes_tbl(39).column_value
          , g_serial_attributes_tbl(40).column_value
          , g_serial_attributes_tbl(41).column_value
          , g_serial_attributes_tbl(42).column_value
          , g_serial_attributes_tbl(43).column_value
          , g_serial_attributes_tbl(44).column_value
          , l_TIME_SINCE_NEW, l_CYCLES_SINCE_NEW, l_TIME_SINCE_OVERHAUL, l_CYCLES_SINCE_OVERHAUL,
                  l_TIME_SINCE_REPAIR, l_CYCLES_SINCE_REPAIR , l_TIME_SINCE_VISIT, l_CYCLES_SINCE_VISIT,
                  l_TIME_SINCE_MARK, l_CYCLES_SINCE_MARK, l_NUMBER_OF_REPAIRS;

      CLOSE serial_temp_csr;

      l_input_idx  := 0;

      IF l_wms_installed THEN
        FOR x IN 1 .. 44 LOOP
          IF (g_serial_attributes_tbl(x).column_value IS NOT NULL) THEN
            l_input_idx                                := l_input_idx + 1;
            l_attributes_in(l_input_idx).column_name   := g_serial_attributes_tbl(x).column_name;
            l_attributes_in(l_input_idx).column_type   := g_serial_attributes_tbl(x).column_type;
            l_attributes_in(l_input_idx).column_value  := g_serial_attributes_tbl(x).column_value;
          END IF;
        END LOOP;
      END IF;   -- if wms_installed is true
    END IF;   -- if transaction_temp_id is not null

    ----------------------------------------------------------
    -- call inv_lot_sel_attr.get_default to get the default value
    -- of the lot attributes
    ---------------------------------------------------------
    IF l_wms_installed THEN
      inv_lot_sel_attr.get_default(
        x_attributes_default         => l_attributes_default
      , x_attributes_default_count   => l_attributes_default_count
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_table_name                 => 'MTL_SERIAL_NUMBERS'
      , p_attributes_name            => 'Serial Attributes'
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_lot_serial_number          => p_fm_serial_number
      , p_attributes                 => l_attributes_in
      );

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        x_return_status  := l_return_status;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /* Get the default attribs only when there is no value on the form (in MSNT).
       * In case the user changes the context and the attributes while recieving,
       * they would be lost if we get the default context again--2756040
       */
      IF (l_attributes_default_count > 0
          AND(g_serial_attributes_tbl(1).column_value = NULL)) THEN
        FOR i IN 1 .. l_attributes_default_count LOOP
          FOR j IN 1 .. g_serial_attributes_tbl.COUNT LOOP
            IF (l_attributes_default(i).column_name = g_serial_attributes_tbl(j).column_name) THEN
              g_serial_attributes_tbl(j).column_value  := l_attributes_default(i).column_value;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;   -- if wms install is true

    l_userid         := fnd_global.user_id;
    l_loginid        := fnd_global.login_id;
    l_sys_date       := SYSDATE;

    IF (p_transaction_action_id = 3 AND g_firstscan = FALSE) THEN
       IF (l_debug = 1) THEN
          invtrace('p_transaction_action_id = 3 and g_firstscan is false');
       END IF;
      INSERT INTO mtl_unit_transactions
                  (
                   transaction_id
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , serial_number
                 , inventory_item_id
                 , organization_id
                 , subinventory_code
                 , locator_id
                 , transaction_date
                 , transaction_source_id
                 , transaction_source_type_id
                 , transaction_source_name
                 , receipt_issue_type
                 , customer_id
                 , ship_id
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
                  )
        SELECT p_transaction_id
             , l_sys_date
             , l_userid
             , msn.creation_date
             , msn.created_by
             , l_loginid
             , msn.serial_number
             , p_inventory_item_id
             , p_organization_id
             , p_subinventory_code
             , p_current_locator_id
             , p_transaction_date
             , p_txn_src_id
             , p_txn_src_type_id
             , p_txn_src_name
             , p_receipt_issue_type
             , p_customer_id
             , p_ship_id
             , msn.serial_attribute_category
             , msn.origination_date
             , msn.c_attribute1
             , msn.c_attribute2
             , msn.c_attribute3
             , msn.c_attribute4
             , msn.c_attribute5
             , msn.c_attribute6
             , msn.c_attribute7
             , msn.c_attribute8
             , msn.c_attribute9
             , msn.c_attribute10
             , msn.c_attribute11
             , msn.c_attribute12
             , msn.c_attribute13
             , msn.c_attribute14
             , msn.c_attribute15
             , msn.c_attribute16
             , msn.c_attribute17
             , msn.c_attribute18
             , msn.c_attribute19
             , msn.c_attribute20
             , msn.d_attribute1
             , msn.d_attribute2
             , msn.d_attribute3
             , msn.d_attribute4
             , msn.d_attribute5
             , msn.d_attribute6
             , msn.d_attribute7
             , msn.d_attribute8
             , msn.d_attribute9
             , msn.d_attribute10
             , msn.n_attribute1
             , msn.n_attribute2
             , msn.n_attribute3
             , msn.n_attribute4
             , msn.n_attribute5
             , msn.n_attribute6
             , msn.n_attribute7
             , msn.n_attribute8
             , msn.n_attribute9
             , msn.n_attribute10
             , msn.status_id
             , msn.territory_code
             , msn.time_since_new
             , msn.cycles_since_new
             , msn.time_since_overhaul
             , msn.cycles_since_overhaul
             , msn.time_since_repair
             , msn.cycles_since_repair
             , msn.time_since_visit
             , msn.cycles_since_visit
             , msn.time_since_mark
             , msn.cycles_since_mark
             , msn.number_of_repairs
          FROM mtl_serial_numbers msn
         WHERE msn.serial_number between  p_fm_serial_number and p_to_serial_number
           AND msn.current_organization_id = p_organization_id
           AND msn.inventory_item_id = p_inventory_item_id;
    /* Bug 2207912 */
    /* The following not exists statement is commented out
    ** because  this part of the statement gets executed
    ** only for ORG TRANSFER and for the delivery side of
    ** of transaction as firstscan is false now, before this
    ** insert statement gets executed the mtl_serial_number is
    ** table is already updated with the organization_id of the
    ** delivered org and status from the TM, so there will be an entry always exist
    ** ing for the where condition specified in the exists clasue
    ** for mtl_serial_number table
    ** So the insert statement will always fail.
    */
    --and   not exists
    --   ( select NULL
    --  from mtl_serial_numbers sn
    --  where sn.serial_number = p_serial_number
    --  and sn.current_organization_id = p_organization_id
    -- and sn.inventory_item_id = p_inventory_item_id);
      ELSE
       IF (l_debug = 1) THEN
          invtrace('not org transfer');
       END IF;
      IF l_wms_installed THEN
        /** 2756040 - Populate Serial Attribute Category info when it is not
         ** a receiving transaction **/
        IF ((g_serial_attributes_tbl(1).column_value = NULL)
            OR(p_transaction_action_id NOT IN(12, 27, 31))) THEN
          inv_lot_sel_attr.get_context_code(g_serial_attributes_tbl(1).column_value, p_organization_id, p_inventory_item_id
          , 'Serial Attributes');
        END IF;
      ELSE
        g_serial_attributes_tbl(1).column_value  := NULL;
      END IF;

      l_date2 := fnd_date.canonical_to_date(g_serial_attributes_tbl(2).COLUMN_VALUE);
       l_date23 := fnd_date.canonical_to_date(g_serial_attributes_tbl(23).COLUMN_VALUE);
       l_date24 := fnd_date.canonical_to_date(g_serial_attributes_tbl(24).COLUMN_VALUE);
       l_date25 := fnd_date.canonical_to_date(g_serial_attributes_tbl(25).COLUMN_VALUE);
       l_date26 := fnd_date.canonical_to_date(g_serial_attributes_tbl(26).COLUMN_VALUE);
       l_date27 := fnd_date.canonical_to_date(g_serial_attributes_tbl(27).COLUMN_VALUE);
       l_date28 := fnd_date.canonical_to_date(g_serial_attributes_tbl(28).COLUMN_VALUE);
       l_date29 := fnd_date.canonical_to_date(g_serial_attributes_tbl(29).COLUMN_VALUE);
       l_date30 := fnd_date.canonical_to_date(g_serial_attributes_tbl(30).COLUMN_VALUE);
       l_date31 := fnd_date.canonical_to_date(g_serial_attributes_tbl(31).COLUMN_VALUE);
       l_date32 := fnd_date.canonical_to_date(g_serial_attributes_tbl(32).COLUMN_VALUE);
       l_num33 := to_number(g_serial_attributes_tbl(33).COLUMN_VALUE);
       l_num34 := to_number(g_serial_attributes_tbl(34).COLUMN_VALUE);
       l_num35 := to_number(g_serial_attributes_tbl(35).COLUMN_VALUE);
       l_num36 := to_number(g_serial_attributes_tbl(36).COLUMN_VALUE);
       l_num37 := to_number(g_serial_attributes_tbl(37).COLUMN_VALUE);
       l_num38 := to_number(g_serial_attributes_tbl(38).COLUMN_VALUE);
       l_num39 := to_number(g_serial_attributes_tbl(39).COLUMN_VALUE);
       l_num40 := to_number(g_serial_attributes_tbl(40).COLUMN_VALUE);
       l_num41 := to_number(g_serial_attributes_tbl(41).COLUMN_VALUE);
       l_num42 := to_number(g_serial_attributes_tbl(42).COLUMN_VALUE);

      IF (p_transaction_temp_id > 0) THEN
        --Bug 2067223 paranthesis are added in the where clause
        -- of the select statement

         -- Bug 3772309: Removing this sql as this is not being used
         -- anywhere. for performance reason.
         /*****
         SELECT count(*)
           into l_upd_count
           FROM mtl_serial_numbers msn, mtl_serial_numbers_temp msnt
           WHERE msnt.transaction_temp_id = p_transaction_temp_id
           AND lpad(msn.serial_number, 30) between lpad(msnt.fm_serial_number,30) AND LPAD(NVL(msnt.to_serial_number, msnt.fm_serial_number),30)
           AND Lpad(msnt.fm_serial_number,30) = l_fm_serial_number
           AND Lpad(msnt.to_serial_number,30) = l_to_serial_number;
           IF (l_debug = 1) THEN
           invtrace('l_upd_count = ' || l_upd_count);
           end if;
           ****/
           IF (l_debug = 1) THEN
              invtrace('insert into mut with tempid = ' ||
                       p_transaction_temp_id);
           END IF;
-- Bug 3772309: Making some changes to the insert statement as it does full
         -- tablescan on MSN.
         IF (p_to_serial_number IS NOT NULL AND p_to_serial_number <>
             p_fm_serial_number) THEN
            IF (l_debug = 1) THEN
               invtrace('inside to_serial different from from_serial.');
               invtrace('from serial =. ' || p_fm_serial_number);
               invtrace('to serial =. ' || p_to_serial_number);
            END IF;

            INSERT INTO mtl_unit_transactions
              (
               transaction_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , serial_number
               , inventory_item_id
               , organization_id
               , subinventory_code
               , locator_id
               , transaction_date
               , transaction_source_id
               , transaction_source_type_id
               , transaction_source_name
               , receipt_issue_type
               , customer_id
               , ship_id
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
              , product_code
              , product_transaction_id
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
              )
              SELECT p_transaction_id
              , l_sys_date
              , l_userid
              , l_sys_date
              , l_userid
              , l_loginid
              , msn.serial_number
              , p_inventory_item_id
              , p_organization_id
              , p_subinventory_code
              , p_current_locator_id
              , p_transaction_date
              , p_txn_src_id
              , p_txn_src_type_id
              , p_txn_src_name
              , p_receipt_issue_type
              , p_customer_id
              , p_ship_id
              , g_serial_attributes_tbl(1).column_value
              , l_date2
              , g_serial_attributes_tbl(3).column_value
              , g_serial_attributes_tbl(4).column_value
              , g_serial_attributes_tbl(5).column_value
              , g_serial_attributes_tbl(6).column_value
              , g_serial_attributes_tbl(7).column_value
              , g_serial_attributes_tbl(8).column_value
              , g_serial_attributes_tbl(9).column_value
              , g_serial_attributes_tbl(10).column_value
              , g_serial_attributes_tbl(11).column_value
              , g_serial_attributes_tbl(12).column_value
              , g_serial_attributes_tbl(13).column_value
              , g_serial_attributes_tbl(14).column_value
              , g_serial_attributes_tbl(15).column_value
              , g_serial_attributes_tbl(16).column_value
              , g_serial_attributes_tbl(17).column_value
              , g_serial_attributes_tbl(18).column_value
              , g_serial_attributes_tbl(19).column_value
              , g_serial_attributes_tbl(20).column_value
              , g_serial_attributes_tbl(21).column_value
              , g_serial_attributes_tbl(22).column_value
              , l_date23
              , l_date24
              , l_date25
              , l_date26
              , l_date27
              , l_date28
              , l_date29
              , l_date30
              , l_date31
              , l_date32
              , l_num33
              , l_num34
              , l_num35
              , l_num36
              , l_num37
              , l_num38
              , l_num39
              , l_num40
              , l_num41
              , l_num42
              , p_status_id
              , g_serial_attributes_tbl(44).column_value
              , l_time_since_new
              , l_cycles_since_new
              , l_time_since_overhaul
              , l_cycles_since_overhaul
              , l_time_since_repair
              , l_cycles_since_repair
              , l_time_since_visit
              , l_cycles_since_visit
              , l_time_since_mark
              , l_cycles_since_mark
              , l_number_of_repairs
              , msnt.product_code
              , msnt.product_transaction_id
              , msnt.attribute_category
              , msnt.attribute1
              , msnt.attribute2
              , msnt.attribute3
              , msnt.attribute4
              , msnt.attribute5
              , msnt.attribute6
              , msnt.attribute7
              , msnt.attribute8
              , msnt.attribute9
              , msnt.attribute10
              , msnt.attribute11
              , msnt.attribute12
              , msnt.attribute13
              , msnt.attribute14
              , msnt.attribute15
              FROM mtl_serial_numbers_temp msnt, mtl_serial_numbers msn
              WHERE msnt.transaction_temp_id = p_transaction_temp_id
              AND  msn.current_organization_id = p_organization_id
              AND msn.inventory_item_id = p_inventory_item_id
              AND lpad(msn.serial_number,30) between lpad(msnt.fm_serial_number,30) AND lpad(msnt.to_serial_number,30)
              AND lpad(msnt.fm_serial_number,30) = l_fm_serial_number
              AND lpad(msnt.to_serial_number,30) = l_to_serial_number;
            /* Bug 3622025 -- Added the LPAD function in the above where clause */

            l_upd_count := SQL%ROWCOUNT;
            IF (l_debug = 1) THEN
               invtrace('l_upd_count = ' || l_upd_count);
            END IF;

          ELSE -- to_serial is either null or is the same as from serial
            IF (l_debug = 1) THEN
               invtrace('inside to_serial is either null or the same.');
               invtrace('from serial =. ' || p_fm_serial_number);
               invtrace('to serial =. ' || p_to_serial_number);
            END IF;

            INSERT INTO mtl_unit_transactions
              (
               transaction_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , serial_number
               , inventory_item_id
               , organization_id
               , subinventory_code
               , locator_id
               , transaction_date
               , transaction_source_id
               , transaction_source_type_id
               , transaction_source_name
               , receipt_issue_type
               , customer_id
               , ship_id
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
              , product_code
              , product_transaction_id
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
              )
              SELECT p_transaction_id
              , l_sys_date
              , l_userid
              , l_sys_date
              , l_userid
              , l_loginid
              , msn.serial_number
              , p_inventory_item_id
              , p_organization_id
              , p_subinventory_code
              , p_current_locator_id
              , p_transaction_date
              , p_txn_src_id
              , p_txn_src_type_id
              , p_txn_src_name
              , p_receipt_issue_type
              , p_customer_id
              , p_ship_id
              , g_serial_attributes_tbl(1).column_value
              , l_date2
              , g_serial_attributes_tbl(3).column_value
              , g_serial_attributes_tbl(4).column_value
              , g_serial_attributes_tbl(5).column_value
              , g_serial_attributes_tbl(6).column_value
              , g_serial_attributes_tbl(7).column_value
              , g_serial_attributes_tbl(8).column_value
              , g_serial_attributes_tbl(9).column_value
              , g_serial_attributes_tbl(10).column_value
              , g_serial_attributes_tbl(11).column_value
              , g_serial_attributes_tbl(12).column_value
              , g_serial_attributes_tbl(13).column_value
              , g_serial_attributes_tbl(14).column_value
              , g_serial_attributes_tbl(15).column_value
              , g_serial_attributes_tbl(16).column_value
              , g_serial_attributes_tbl(17).column_value
              , g_serial_attributes_tbl(18).column_value
              , g_serial_attributes_tbl(19).column_value
              , g_serial_attributes_tbl(20).column_value
              , g_serial_attributes_tbl(21).column_value
              , g_serial_attributes_tbl(22).column_value
              , l_date23
              , l_date24
              , l_date25
              , l_date26
              , l_date27
              , l_date28
              , l_date29
              , l_date30
              , l_date31
              , l_date32
              , l_num33
              , l_num34
              , l_num35
              , l_num36
              , l_num37
              , l_num38
              , l_num39
              , l_num40
              , l_num41
              , l_num42
              , p_status_id
              , g_serial_attributes_tbl(44).column_value
              , l_time_since_new
              , l_cycles_since_new
              , l_time_since_overhaul
              , l_cycles_since_overhaul
              , l_time_since_repair
              , l_cycles_since_repair
              , l_time_since_visit
              , l_cycles_since_visit
              , l_time_since_mark
              , l_cycles_since_mark
              , l_number_of_repairs
              , msnt.product_code
              , msnt.product_transaction_id
              , msnt.attribute_category
              , msnt.attribute1
              , msnt.attribute2
              , msnt.attribute3
              , msnt.attribute4
              , msnt.attribute5
              , msnt.attribute6
              , msnt.attribute7
              , msnt.attribute8
              , msnt.attribute9
              , msnt.attribute10
              , msnt.attribute11
              , msnt.attribute12
              , msnt.attribute13
              , msnt.attribute14
              , msnt.attribute15
              FROM mtl_serial_numbers_temp msnt, mtl_serial_numbers msn
              WHERE msnt.transaction_temp_id = p_transaction_temp_id
              AND  msn.current_organization_id = p_organization_id
              AND msn.inventory_item_id = p_inventory_item_id
              AND lpad(msn.serial_number,30) = lpad(msnt.fm_serial_number,30)
              AND lpad(msnt.fm_serial_number,30) = l_fm_serial_number;
            /* Bug 3622025 -- Added the LPAD function in the above where clause */
         END IF;

         -- End changes to bug 3772309
       ELSE
         IF (l_debug = 1) THEN
            invtrace('no transaction temp id');
         END IF;

       INSERT INTO mtl_unit_transactions
                    (
                     transaction_id
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , serial_number
                   , inventory_item_id
                   , organization_id
                   , subinventory_code
                   , locator_id
                   , transaction_date
                   , transaction_source_id
                   , transaction_source_type_id
                   , transaction_source_name
                   , receipt_issue_type
                   , customer_id
                   , ship_id
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
                    )
          SELECT p_transaction_id
               , SYSDATE
               , l_userid
               , SYSDATE
               , l_userid
               , l_loginid
               , msn.serial_number
               , p_inventory_item_id
               , p_organization_id
               , p_subinventory_code
               , p_current_locator_id
               , p_transaction_date
               , p_txn_src_id
               , p_txn_src_type_id
               , p_txn_src_name
               , p_receipt_issue_type
               , p_customer_id
               , p_ship_id
               , g_serial_attributes_tbl(1).column_value
               , l_date2
               , g_serial_attributes_tbl(3).column_value
               , g_serial_attributes_tbl(4).column_value
               , g_serial_attributes_tbl(5).column_value
               , g_serial_attributes_tbl(6).column_value
               , g_serial_attributes_tbl(7).column_value
               , g_serial_attributes_tbl(8).column_value
               , g_serial_attributes_tbl(9).column_value
               , g_serial_attributes_tbl(10).column_value
               , g_serial_attributes_tbl(11).column_value
               , g_serial_attributes_tbl(12).column_value
               , g_serial_attributes_tbl(13).column_value
               , g_serial_attributes_tbl(14).column_value
               , g_serial_attributes_tbl(15).column_value
               , g_serial_attributes_tbl(16).column_value
               , g_serial_attributes_tbl(17).column_value
               , g_serial_attributes_tbl(18).column_value
               , g_serial_attributes_tbl(19).column_value
               , g_serial_attributes_tbl(20).column_value
               , g_serial_attributes_tbl(21).column_value
               , g_serial_attributes_tbl(22).column_value
               , l_date23
               , l_date24
               , l_date25
               , l_date26
               , l_date27
               , l_date28
               , l_date29
               , l_date30
               , l_date31
               , l_date32
               , l_num33
               , l_num34
               , l_num35
               , l_num36
               , l_num37
               , l_num38
               , l_num39
               , l_num40
               , l_num41
               , l_num42
               , p_status_id
               , g_serial_attributes_tbl(44).column_value
               , l_time_since_new
               , l_cycles_since_new
               , l_time_since_overhaul
               , l_cycles_since_overhaul
               , l_time_since_repair
               , l_cycles_since_repair
               , l_time_since_visit
               , l_cycles_since_visit
               , l_time_since_mark
               , l_cycles_since_mark
               , l_number_of_repairs
            FROM mtl_serial_numbers msn
           WHERE inventory_item_id = p_inventory_item_id
             AND serial_number between p_fm_serial_number AND p_to_serial_number;
      END IF;
    END IF;

     /*bug 2756040 Update MSN also with values from MSNT in case of
    receipt transaction or intransit receipt txn
    (transaction_action_id = 12 or 27) */
      IF (p_transaction_action_id IN(12, 27, 31)) THEN
         IF (l_debug = 1) THEN
            invtrace('transaction_action_id = ' || p_transaction_action_id
                     || ' org _id ' || p_organization_id || 'item ' ||
                     p_inventory_item_id);
         END IF;
      BEGIN
        UPDATE mtl_serial_numbers
           SET serial_attribute_category = g_serial_attributes_tbl(1).column_value
             , origination_date = l_date2
             , c_attribute1 = g_serial_attributes_tbl(3).column_value
             , c_attribute2 = g_serial_attributes_tbl(4).column_value
             , c_attribute3 = g_serial_attributes_tbl(5).column_value
             , c_attribute4 = g_serial_attributes_tbl(6).column_value
             , c_attribute5 = g_serial_attributes_tbl(7).column_value
             , c_attribute6 = g_serial_attributes_tbl(8).column_value
             , c_attribute7 = g_serial_attributes_tbl(9).column_value
             , c_attribute8 = g_serial_attributes_tbl(10).column_value
             , c_attribute9 = g_serial_attributes_tbl(11).column_value
             , c_attribute10 = g_serial_attributes_tbl(12).column_value
             , c_attribute11 = g_serial_attributes_tbl(13).column_value
             , c_attribute12 = g_serial_attributes_tbl(14).column_value
             , c_attribute13 = g_serial_attributes_tbl(15).column_value
             , c_attribute14 = g_serial_attributes_tbl(16).column_value
             , c_attribute15 = g_serial_attributes_tbl(17).column_value
             , c_attribute16 = g_serial_attributes_tbl(18).column_value
             , c_attribute17 = g_serial_attributes_tbl(19).column_value
             , c_attribute18 = g_serial_attributes_tbl(20).column_value
             , c_attribute19 = g_serial_attributes_tbl(21).column_value
             , c_attribute20 = g_serial_attributes_tbl(22).column_value
             , d_attribute1 = l_date23
             , d_attribute2 = l_date24
             , d_attribute3 = l_date25
             , d_attribute4 = l_date26
             , d_attribute5 = l_date27
             , d_attribute6 = l_date28
             , d_attribute7 = l_date29
             , d_attribute8 = l_date30
             , d_attribute9 = l_date31
             , d_attribute10 = l_date32
             , n_attribute1 = l_num33
             , n_attribute2 = l_num34
             , n_attribute3 = l_num35
             , n_attribute4 = l_num36
             , n_attribute5 = l_num37
            , n_attribute6 = l_num38
             , n_attribute7 = l_num39
             , n_attribute8 = l_num40
             , n_attribute9 = l_num41
             , n_attribute10 = l_num42
         WHERE serial_number between p_fm_serial_number and p_to_serial_number
           AND inventory_item_id = p_inventory_item_id
           AND current_organization_id = p_organization_id;

        IF (l_debug = 1) THEN
           invtrace('updating MSN with values ');
           invtrace('serial_attribute_category ' || g_serial_attributes_tbl(1).column_value);
           invtrace('origination_date ' || g_serial_attributes_tbl(2).column_value);
           invtrace(' C_ATTRIBUTE1 = ' || g_serial_attributes_tbl(3).column_value);
           invtrace('C_ATTRIBUTE2 = ' || g_serial_attributes_tbl(4).column_value);
           invtrace('C_ATTRIBUTE3 = ' || g_serial_attributes_tbl(5).column_value);
           invtrace('C_ATTRIBUTE4 = ' || g_serial_attributes_tbl(6).column_value);
           invtrace('C_ATTRIBUTE5 = ' || g_serial_attributes_tbl(7).column_value);
           invtrace('C_ATTRIBUTE6 = ' || g_serial_attributes_tbl(8).column_value);
           invtrace('C_ATTRIBUTE7 = ' || g_serial_attributes_tbl(9).column_value);
           invtrace('C_ATTRIBUTE8 = ' || g_serial_attributes_tbl(10).column_value);
           invtrace('C_ATTRIBUTE9 = ' || g_serial_attributes_tbl(11).column_value);
           invtrace('C_ATTRIBUTE10 = ' || g_serial_attributes_tbl(12).column_value);
           invtrace('C_ATTRIBUTE11 = ' || g_serial_attributes_tbl(13).column_value);
           invtrace('C_ATTRIBUTE12 = ' || g_serial_attributes_tbl(14).column_value);
           invtrace('C_ATTRIBUTE13 =  ' || g_serial_attributes_tbl(15).column_value);
           invtrace('C_ATTRIBUTE14 =  ' || g_serial_attributes_tbl(16).column_value);
           invtrace('C_ATTRIBUTE15 = ' || g_serial_attributes_tbl(17).column_value);
           invtrace('C_ATTRIBUTE16 = ' || g_serial_attributes_tbl(18).column_value);
           invtrace('C_ATTRIBUTE17 = ' || g_serial_attributes_tbl(19).column_value);
           invtrace('C_ATTRIBUTE18 =  ' || g_serial_attributes_tbl(20).column_value);
           invtrace('C_ATTRIBUTE19 = ' || g_serial_attributes_tbl(21).column_value);
           invtrace('C_ATTRIBUTE20 = ' || g_serial_attributes_tbl(22).column_value);
           invtrace('D_ATTRIBUTE1 =  ' || g_serial_attributes_tbl(23).column_value);
           invtrace('D_ATTRIBUTE2 =  ' || g_serial_attributes_tbl(24).column_value);
           invtrace('D_ATTRIBUTE3 =  ' || g_serial_attributes_tbl(25).column_value);
           invtrace('D_ATTRIBUTE4 =  ' || g_serial_attributes_tbl(26).column_value);
           invtrace('D_ATTRIBUTE5 = ' || g_serial_attributes_tbl(27).column_value);
           invtrace('D_ATTRIBUTE6 =  ' || g_serial_attributes_tbl(28).column_value);
           invtrace('D_ATTRIBUTE7 =  ' || g_serial_attributes_tbl(29).column_value);
           invtrace('D_ATTRIBUTE8 = ' || g_serial_attributes_tbl(30).column_value);
           invtrace('D_ATTRIBUTE9 = ' || g_serial_attributes_tbl(31).column_value);
           invtrace('D_ATTRIBUTE10 = ' || g_serial_attributes_tbl(32).column_value);
           invtrace('N_ATTRIBUTE1 =  ' || g_serial_attributes_tbl(33).column_value);
           invtrace('N_ATTRIBUTE2 =  ' || g_serial_attributes_tbl(34).column_value);
           invtrace('N_ATTRIBUTE3 =  ' || g_serial_attributes_tbl(35).column_value);
           invtrace('N_ATTRIBUTE4 =  ' || g_serial_attributes_tbl(36).column_value);
           invtrace('N_ATTRIBUTE5 =  ' || g_serial_attributes_tbl(37).column_value);
           invtrace('N_ATTRIBUTE6 =  ' || g_serial_attributes_tbl(38).column_value);
           invtrace('N_ATTRIBUTE7 =  ' || g_serial_attributes_tbl(39).column_value);
           invtrace('N_ATTRIBUTE8 =  ' || g_serial_attributes_tbl(40).column_value);
           invtrace('N_ATTRIBUTE9 =  ' || g_serial_attributes_tbl(41).column_value);
           invtrace('N_ATTRIBUTE10 = ' || g_serial_attributes_tbl(42).column_value);
		   invtrace('attribute_category ' || g_serial_attributes_tbl(45).column_value);
           invtrace('ATTRIBUTE1 = ' || g_serial_attributes_tbl(46).column_value);
           invtrace('ATTRIBUTE2 = ' || g_serial_attributes_tbl(47).column_value);
           invtrace('ATTRIBUTE3 = ' || g_serial_attributes_tbl(48).column_value);
           invtrace('ATTRIBUTE4 = ' || g_serial_attributes_tbl(49).column_value);
           invtrace('ATTRIBUTE5 = ' || g_serial_attributes_tbl(50).column_value);
           invtrace('ATTRIBUTE6 = ' || g_serial_attributes_tbl(51).column_value);
           invtrace('ATTRIBUTE7 = ' || g_serial_attributes_tbl(52).column_value);
           invtrace('ATTRIBUTE8 = ' || g_serial_attributes_tbl(53).column_value);
           invtrace('ATTRIBUTE9 = ' || g_serial_attributes_tbl(54).column_value);
           invtrace('ATTRIBUTE10 = ' || g_serial_attributes_tbl(55).column_value);
           invtrace('ATTRIBUTE11 = ' || g_serial_attributes_tbl(56).column_value);
           invtrace('ATTRIBUTE12 = ' || g_serial_attributes_tbl(57).column_value);
           invtrace('ATTRIBUTE13 =  ' || g_serial_attributes_tbl(58).column_value);
           invtrace('ATTRIBUTE14 =  ' || g_serial_attributes_tbl(59).column_value);
           invtrace('ATTRIBUTE15 = ' || g_serial_attributes_tbl(60).column_value);
           invtrace(' for the serial ' || p_fm_serial_number);
        END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               invtrace('no data found while updating msn');
            END IF;

         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               invtrace('some other error' || SQLERRM);
            END IF;

      END;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
   -- End of API body.
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_msg_data);
    x_msg_data       := SUBSTR(l_msg_data, 0, 198);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO apiinsertserial_apipub;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'insertRangeUnitTrx');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
END insertRangeUnitTrx;

--serial tagging
-- Output variables
-- x_serial_control: 1 => No, 2=> Yes
PROCEDURE is_serial_controlled(
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER,
            p_transfer_org_id           IN NUMBER DEFAULT NULL,
            p_txn_type_id               IN NUMBER DEFAULT NULL,
            p_txn_src_type_id           IN NUMBER DEFAULT NULL,
            p_txn_action_id             IN NUMBER DEFAULT NULL,
            p_serial_control            IN NUMBER DEFAULT NULL,
            p_xfer_serial_control       IN NUMBER DEFAULT NULL,
            x_serial_control            OUT NOCOPY NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2)
IS
    l_serial_control_code       NUMBER;
    l_xfer_serial_control_code  NUMBER := 1;
    l_tagged                    NUMBER;
    l_txn_type_id               NUMBER;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    x_serial_control := 1;
    x_return_status  := fnd_api.g_ret_sts_success;
    IF p_txn_type_id = 1005 THEN
        l_txn_type_id := 36;
    ELSE
        l_txn_type_id := p_txn_type_id;
    END IF;

    --Assume x_serial_control holds serial_control_code if passed
    IF l_debug = 1 THEN
        invtrace('is_serial_controlled:'||p_inventory_item_id||' '||p_organization_id||' '||l_txn_type_id||' '||p_txn_src_type_id||' '||p_txn_action_id);
        invtrace(p_serial_control||' '||p_xfer_serial_control||' '||p_transfer_org_id);
    END IF;
    IF p_serial_control IS NULL THEN

      SELECT serial_number_control_code
        INTO l_serial_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;
    ELSE
      l_serial_control_code := p_serial_control;
    END IF;

    IF l_debug = 1 THEN
        invtrace('serial_control:'||l_serial_control_code);
    END IF;

    IF l_serial_control_code IN (2,5) THEN
      x_serial_control := 2;
      RETURN;

    ELSIF l_serial_control_code IN (1,6) THEN

      IF p_xfer_serial_control IS NULL
         AND (p_transfer_org_id IS NOT NULL AND p_transfer_org_id NOT IN (0,-1))
      THEN

        BEGIN
            SELECT serial_number_control_code
              INTO l_xfer_serial_control_code
              FROM mtl_system_items
             WHERE inventory_item_id = p_inventory_item_id
               AND organization_id = p_transfer_org_id;
        EXCEPTION
            WHEN No_Data_Found THEN
                l_xfer_serial_control_code := 1;
        END;
      ELSIF p_xfer_serial_control IS NOT NULL THEN
        l_xfer_serial_control_code := p_xfer_serial_control;
      END IF;

      l_tagged := inv_cache.get_serial_tagged(p_organization_id, p_inventory_item_id, l_txn_type_id);
      /*
      BEGIN
        SELECT Count(1) INTO l_tagged
          FROM MTL_SERIAL_TAGGING_ASSIGNMENTS
          WHERE ORGANIZATION_ID = p_organization_id
          AND INVENTORY_ITEM_ID = p_inventory_item_id
          AND TRANSACTION_TYPE_ID = p_txn_type_id
          AND rownum = 1;
      EXCEPTION
          WHEN OTHERS THEN
           l_tagged := 0;
      END;
      */


      /* Bug 3644289: Separating the conditions for internal order and internal reqs.
         Bug 3644289: Checking to see if it is an internal req intransit receipt and if control is at SO issue,
                      we should be checking for serial numbers, only if the source org is either serial at
                      receipt or predefined or sales order issue.
                      If the source has no control,we should not be checking the serials or updating their status.
         Bug 5507524: If transaction source type is internal req and action is org xfer (transaction type is
                      internal req direct org transfer), it should be considered as serialized transaction
         Bug 3318924: Allow receipt of serials into stores against an intransit receipt even if the serial control
                      is dynamic at SO Issue if serials were shipped (serial control code in the source org is
                      predefined or dynamic at receipt). The status of these serials would be updated to
                      "Defined but not used" upon receipt
         Bug 6798024: should transfer serials for Internal order direct-org xfers/sub-xfers if the item is at
                      SO Issue serial control in the destination org or sub
      */
      IF l_debug = 1 THEN
        invtrace('Serial tagged: '||l_tagged);
      END IF;

      IF  (( l_serial_control_code = 6 AND
            (   -- SO Issue or Project Contract Issue
               ((p_txn_src_type_id = 2 OR p_txn_src_type_id = 16) AND p_txn_action_id = 1)
               -- RMA
            OR (p_txn_src_type_id = 12)
               -- Int Ord Issue/Sub xfer/Direct Org Xfer/Intransit Org
            OR (p_txn_src_type_id = 8 AND p_txn_action_id IN (1,2,3,21))
               -- Int Req Sub xfer/Receipt/Direct Transfer
            OR (p_txn_src_type_id = 7 AND p_txn_action_id IN (2,3,12) AND l_xfer_serial_control_code IN (2,5,6)
               )
               -- Intransit shipment receipt
            OR (p_txn_src_type_id = 13 AND p_txn_action_id = 12 AND l_xfer_serial_control_code IN (2,5)
               )
            )
           )
            --serial tagging
            OR (l_serial_control_code IN (1,6) AND l_tagged = 2)
          )
      THEN
        x_serial_control := 2;
        RETURN;
      END IF;

    END IF; --l_serial_control_code IN (1,6)

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_SERIAL_NUMBER_PUB', 'is_serial_controlled');
        IF l_debug = 1 THEN
            invtrace('Exception:'||SQLERRM);
        END IF;

      END IF;
      x_serial_control := 1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END is_serial_controlled;

  --serial tagging
  FUNCTION is_serial_tagged(
              p_inventory_item_id         IN NUMBER,
              p_organization_id           IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN is_serial_tagged(p_inventory_item_id, p_organization_id, NULL);
  END is_serial_tagged;

  FUNCTION is_serial_tagged(
              p_inventory_item_id         IN NUMBER DEFAULT NULL,
              p_organization_id           IN NUMBER DEFAULT NULL,
              p_template_id               IN NUMBER
  ) RETURN NUMBER IS
    l_exists NUMBER := 1;
  BEGIN
    IF p_template_id IS NOT NULL THEN
      BEGIN
        SELECT 2 INTO l_exists
        FROM DUAL
        WHERE EXISTS (SELECT 1 FROM mtl_serial_tagging_assignments
                      WHERE NVL(organization_id,-1) = NVL(p_organization_id,-1)
                      AND template_id = p_template_id
                     );
      EXCEPTION
        WHEN Others THEN
          null;
      END;
    ELSIF p_organization_id IS NULL OR p_inventory_item_id IS NULL THEN
      NULL;
    ELSE
      BEGIN
        SELECT 2 INTO l_exists
        FROM DUAL
        WHERE EXISTS (SELECT 1 FROM mtl_serial_tagging_assignments
                      WHERE organization_id = p_organization_id
                      AND inventory_item_id = p_inventory_item_id
                     );
      EXCEPTION
        WHEN Others THEN
          --l_exists := 1;
          null;
      END;
    END IF;

    RETURN l_exists;

  END is_serial_tagged;

  --serial tagging
  PROCEDURE copy_serial_tag_assignments(
            p_from_org_id               IN NUMBER DEFAULT NULL,
            p_from_item_id              IN NUMBER DEFAULT NULL,
            p_from_template_id          IN NUMBER DEFAULT NULL,
            p_to_org_id                 IN NUMBER DEFAULT NULL,
            p_to_item_id                IN NUMBER DEFAULT NULL,
            p_to_template_id            IN NUMBER DEFAULT NULL,
            x_return_status             OUT NOCOPY VARCHAR2)
  IS
    l_debug          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_userid         NUMBER := fnd_global.user_id;
    l_loginid        NUMBER := fnd_global.login_id;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF ( (     p_to_item_id     IS NULL
           AND p_to_template_id IS NOT NULL)
         OR
         (     p_to_org_id      IS NOT NULL
           AND p_to_item_id     IS NOT NULL
           AND p_to_template_id IS NULL)
       )
    THEN
        NULL;
    ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        IF l_debug = 1 THEN
            invtrace('Incorrect Destination org/item/template Combination :' ||
                      p_to_org_id || ':' || p_to_item_id || ':' || p_to_template_id );
        END IF;
        RETURN;
    END IF;

    IF ( (     p_from_item_id     IS NULL
           AND p_from_template_id IS NOT NULL)
         OR
         (     p_from_org_id      IS NOT NULL
           AND p_from_item_id     IS NOT NULL
           AND p_from_template_id IS NULL)
       )
    THEN
        NULL;
    ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        IF l_debug = 1 THEN
            invtrace('Incorrect Source org/item/template Combination :' ||
                      p_from_org_id || ':' || p_from_item_id || ':' || p_from_template_id );
        END IF;
        RETURN;
    END IF;

    IF p_from_item_id IS NOT NULL AND p_to_item_id IS NOT NULL THEN
      BEGIN
        INSERT INTO mtl_serial_tagging_assignments
          (  ORGANIZATION_ID , INVENTORY_ITEM_ID , TEMPLATE_ID , TRANSACTION_TYPE_ID
           , CREATED_BY , CREATION_DATE , LAST_UPDATED_BY , LAST_UPDATE_DATE , LAST_UPDATE_LOGIN , CONTEXT )
          SELECT p_to_org_id , p_to_item_id , p_to_template_id , transaction_type_id
               , l_userid , SYSDATE , l_userid , SYSDATE , l_loginid , context
          FROM mtl_serial_tagging_assignments msta1
          WHERE organization_id = p_from_org_id
          AND inventory_item_id = p_from_item_id
          AND NOT EXISTS (SELECT 1
                          FROM mtl_serial_tagging_assignments msta2
                          WHERE msta2.organization_id   = p_to_org_id
                          AND msta2.inventory_item_id   = p_to_item_id
                          AND msta2.transaction_type_id = msta1.transaction_type_id
                         )
        ;

      EXCEPTION
        WHEN others THEN
          x_return_status := fnd_api.g_ret_sts_error;
          IF l_debug = 1 THEN
            invtrace('Exception in copyTagAssignments 1:'||SQLERRM);
          END IF;
      END;
    ELSIF p_from_item_id IS NOT NULL AND p_to_template_id IS NOT NULL THEN
      BEGIN
        INSERT INTO mtl_serial_tagging_assignments
          (  ORGANIZATION_ID , INVENTORY_ITEM_ID , TEMPLATE_ID , TRANSACTION_TYPE_ID
           , CREATED_BY , CREATION_DATE , LAST_UPDATED_BY , LAST_UPDATE_DATE , LAST_UPDATE_LOGIN , CONTEXT )
          SELECT p_to_org_id , p_to_item_id , p_to_template_id , transaction_type_id
               , l_userid , SYSDATE , l_userid , SYSDATE , l_loginid , context
          FROM mtl_serial_tagging_assignments msta1
          WHERE organization_id = p_from_org_id
          AND inventory_item_id = p_from_item_id
          AND NOT EXISTS (SELECT 1
                          FROM mtl_serial_tagging_assignments msta2
                          WHERE NVL(msta2.organization_id,-1)   = NVL(p_to_org_id,-1)
                          AND msta2.template_id         = p_to_template_id
                          AND msta2.transaction_type_id = msta1.transaction_type_id
                         )
        ;

      EXCEPTION
        WHEN others THEN
          x_return_status := fnd_api.g_ret_sts_error;
          IF l_debug = 1 THEN
            invtrace('Exception in copyTagAssignments 2:'||SQLERRM);
          END IF;
      END;
    ELSIF p_from_template_id IS NOT NULL AND p_to_item_id IS NOT NULL THEN
      BEGIN
        INSERT INTO mtl_serial_tagging_assignments
          (  ORGANIZATION_ID , INVENTORY_ITEM_ID , TEMPLATE_ID , TRANSACTION_TYPE_ID
           , CREATED_BY , CREATION_DATE , LAST_UPDATED_BY , LAST_UPDATE_DATE , LAST_UPDATE_LOGIN , CONTEXT )
          SELECT p_to_org_id , p_to_item_id , p_to_template_id , transaction_type_id
               , l_userid , SYSDATE , l_userid , SYSDATE , l_loginid , context
          FROM mtl_serial_tagging_assignments msta1
          WHERE NVL(organization_id,-1) = NVL(p_from_org_id,-1)
          AND template_id = p_from_template_id
          AND NOT EXISTS (SELECT 1
                          FROM mtl_serial_tagging_assignments msta2
                          WHERE msta2.organization_id   = p_to_org_id
                          AND msta2.inventory_item_id   = p_to_item_id
                          AND msta2.transaction_type_id = msta1.transaction_type_id
                         )
        ;

      EXCEPTION
        WHEN others THEN
          x_return_status := fnd_api.g_ret_sts_error;
          IF l_debug = 1 THEN
            invtrace('Exception in copyTagAssignments 3:'||SQLERRM);
          END IF;
      END;
    ELSIF p_from_template_id IS NOT NULL AND p_to_template_id IS NOT NULL THEN
      BEGIN
        INSERT INTO mtl_serial_tagging_assignments
          (  ORGANIZATION_ID , INVENTORY_ITEM_ID , TEMPLATE_ID , TRANSACTION_TYPE_ID
           , CREATED_BY , CREATION_DATE , LAST_UPDATED_BY , LAST_UPDATE_DATE , LAST_UPDATE_LOGIN , CONTEXT )
          SELECT p_to_org_id , p_to_item_id , p_to_template_id , transaction_type_id
               , l_userid , SYSDATE , l_userid , SYSDATE , l_loginid , context
          FROM mtl_serial_tagging_assignments msta1
          WHERE NVL(organization_id,-1) = NVL(p_from_org_id,-1)
          AND template_id = p_from_template_id
          AND NOT EXISTS (SELECT 1
                          FROM mtl_serial_tagging_assignments msta2
                          WHERE NVL(msta2.organization_id,-1)   = NVL(p_to_org_id,-1)
                          AND msta2.template_id         = p_to_template_id
                          AND msta2.transaction_type_id = msta1.transaction_type_id
                         )
        ;

      EXCEPTION
        WHEN others THEN
          x_return_status := fnd_api.g_ret_sts_error;
          IF l_debug = 1 THEN
            invtrace('Exception in copyTagAssignments 4:'||SQLERRM);
          END IF;
      END;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
        invtrace('Exception in copyTagAssignments 4:'||SQLERRM);
      END IF;
  END copy_serial_tag_assignments;

  PROCEDURE delete_serial_tag_assignments(
            p_inventory_item_id         IN NUMBER,
            p_organization_id           IN NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2) IS
  BEGIN
    delete_serial_tag_assignments(p_inventory_item_id, p_organization_id, NULL, x_return_status);
  END delete_serial_tag_assignments;

  PROCEDURE delete_serial_tag_assignments(
            p_inventory_item_id         IN NUMBER DEFAULT NULL,
            p_organization_id           IN NUMBER DEFAULT NULL,
            p_template_id               IN NUMBER,
            x_return_status             OUT NOCOPY VARCHAR2) IS
    l_debug          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF (        p_inventory_item_id     IS NULL
            AND p_template_id           IS NOT NULL)
    THEN
        DELETE FROM MTL_SERIAL_TAGGING_ASSIGNMENTS
        WHERE template_id = p_template_id
         AND NVL(organization_id,-99) = NVL(p_organization_id,-99);

    ELSIF (     p_inventory_item_id     IS NOT NULL
            AND p_organization_id       IS NOT NULL
            AND p_template_id           IS NULL)
    THEN
        DELETE FROM MTL_SERIAL_TAGGING_ASSIGNMENTS
        WHERE inventory_item_id = p_inventory_item_id
        AND   organization_id   = p_organization_id;
    ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        IF l_debug = 1 THEN
            invtrace('Incorrect org/item/template Combination :' ||
               p_organization_id || ':' || p_inventory_item_id || ':' || p_template_id );
        END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF l_debug = 1 THEN
            invtrace('Exception in delete_serial_tag_assignments:' || sqlerrm );
        END IF;

  END delete_serial_tag_assignments;

END inv_serial_number_pub;

/
