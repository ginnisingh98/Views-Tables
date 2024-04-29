--------------------------------------------------------
--  DDL for Package Body CSI_PROCESS_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PROCESS_TXN_PVT" AS
/* $Header: csivptxb.pls 120.27.12010000.3 2010/02/11 06:55:41 dnema ship $ */

  PROCEDURE debug (
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_process_txn_pvt',
      p_api_name => p_api_name);
  EXCEPTION
    WHEN others THEN
      null;
  END api_log;

  PROCEDURE get_dfl_inv_location(
    p_subinventory_code IN  varchar2,
    p_organization_id   IN  number,
    x_location_id       OUT NOCOPY number,
    x_return_status     OUT NOCOPY varchar2)
  IS
    l_location_id  number;
  BEGIN

    BEGIN
      SELECT location_id
      INTO   l_location_id
      FROM   mtl_secondary_inventories
      WHERE  organization_id = p_organization_id
      AND    secondary_inventory_name = p_subinventory_code;
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_DEST_SUBINV_INVALID');
        fnd_message.set_token('INV_ORG_ID',p_organization_id);
        fnd_message.set_token('SUBINV_ID',p_subinventory_code);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_location_id is null THEN
      BEGIN
        SELECT location_id
        INTO   l_location_id
        FROM   hr_organization_units
        WHERE  organization_id = p_organization_id;
      EXCEPTION
        WHEN no_data_found THEN
          fnd_message.set_name('CSI','CSI_INT_DEST_ORG_ID_INVALID');
          fnd_message.set_token('INV_ORG_ID',p_organization_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    x_location_id := l_location_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_dfl_inv_location;

  PROCEDURE validate_dest_location_rec(
    p_in_out_flag       IN     varchar2,
    p_dest_location_rec IN OUT NOCOPY csi_process_txn_grp.dest_location_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS
    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_in_out_flag = 'IN' THEN

      csi_t_vldn_routines_pvt.check_reqd_param(
        p_value      => p_dest_location_rec.inv_organization_id,
        p_param_name => 'p_dest_location_rec.inv_organization_id',
        p_api_name   => 'csi_process_txn_grp.process_transaction');

      IF p_dest_location_rec.location_type_code = 'INVENTORY' THEN

        get_dfl_inv_location(
          p_subinventory_code => p_dest_location_rec.inv_subinventory_name,
          p_organization_id   => p_dest_location_rec.inv_organization_id,
          x_location_id       => p_dest_location_rec.location_id,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_dest_location_rec;

  PROCEDURE get_sub_type_rec(
    p_txn_type_id       IN  number,
    p_sub_type_id       IN  number,
    x_sub_type_rec      OUT NOCOPY csi_txn_sub_types%rowtype,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_sub_type_rec      csi_txn_sub_types%rowtype;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT *
    INTO   l_sub_type_rec
    FROM   csi_txn_sub_types
    WHERE  transaction_type_id = p_txn_type_id
    AND    sub_type_id         = p_sub_type_id;

    IF l_sub_type_rec.src_status_id is null THEN
      l_sub_type_rec.src_status_id := fnd_api.g_miss_num;
    END IF;

    l_sub_type_rec.src_change_owner     := nvl(l_sub_type_rec.src_change_owner, 'N');
    l_sub_type_rec.non_src_change_owner := nvl(l_sub_type_rec.non_src_change_owner, 'N');

    x_sub_type_rec := l_sub_type_rec;

  EXCEPTION
    WHEN no_data_found THEN

      fnd_message.set_name('CSI','CSI_INT_SUB_TYPE_REC_MISSING');
      fnd_message.set_token('SUB_TYPE_ID',p_sub_type_id);
      fnd_message.set_token('TRANSACTION_TYPE_ID',p_txn_type_id);
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
  END get_sub_type_rec;



  /* --------------------------------------------------------------- */
  /* validate whether a reference is found in the instances table as */
  /* specified by the sub type definition (reference_reqd_flag) for  */
  /* the parent(P), source(S) and non source(N)                      */
  /* --------------------------------------------------------------- */

  PROCEDURE validate_reference(
    p_reference_type    IN  varchar2,
    p_txn_instances_tbl IN  csi_process_txn_grp.txn_instances_tbl,
    x_return_status     OUT NOCOPY varchar2)
  IS
    l_reference_found      boolean;
    l_reference_code       varchar2(30);
  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'validate_reference');

    l_reference_found := FALSE;

    IF p_txn_instances_tbl.COUNT > 0 THEN
      FOR l_ind IN p_txn_instances_tbl.FIRST .. p_txn_instances_tbl.LAST
      LOOP

        IF p_txn_instances_tbl(l_ind).ib_txn_segment_flag = p_reference_type THEN
          l_reference_found := TRUE;
          exit;
        END IF;

      END LOOP;
    END IF;

    IF NOT (l_reference_found) THEN

      SELECT decode(p_reference_type,'P','Parent','N','Non Source','S','Source')
      INTO   l_reference_code
      FROM   sys.dual;

      fnd_message.set_name('CSI','CSI_TXN_SRC_REF_NOT_FOUND');
      fnd_message.set_token('REF_TYPE',l_reference_code);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;

    END IF;

  EXCEPTION
    when fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_reference;


  /* --------------------------------------------------------------- */
  /* validate if atleast one owner is found in the party table for   */
  /* each of the instance record as dictated by the transaction      */
  /* sub type definition                                             */
  /* --------------------------------------------------------------- */

  PROCEDURE validate_owner_reference(
    p_reference_type       IN  varchar2,
    p_change_owner_to_code IN  varchar2,
    p_txn_instances_tbl    IN  csi_process_txn_grp.txn_instances_tbl,
    p_txn_i_parties_tbl    IN  csi_process_txn_grp.txn_i_parties_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_owner_found          boolean;
    l_internal_party_id    number;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'validate_owner_reference');

    x_return_status := fnd_api.g_ret_sts_success;

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    IF p_txn_instances_tbl.COUNT > 0 THEN
      FOR l_i_ind IN p_txn_instances_tbl.FIRST .. p_txn_instances_tbl.LAST
      LOOP
        l_owner_found := TRUE;

        IF p_txn_instances_tbl(l_i_ind).ib_txn_segment_flag = p_reference_type THEN

          l_owner_found := FALSE;

          IF p_txn_i_parties_tbl.COUNT > 0 THEN
            FOR l_p_ind IN p_txn_i_parties_tbl.FIRST .. p_txn_i_parties_tbl.LAST
            LOOP
              IF p_txn_i_parties_tbl(l_p_ind).parent_tbl_index = l_i_ind THEN
                IF p_txn_i_parties_tbl(l_p_ind).relationship_type_code = 'OWNER' THEN

                  l_owner_found := TRUE;

                  IF ( p_change_owner_to_code = 'E'
                       AND
                       p_txn_i_parties_tbl(l_p_ind).party_id = l_internal_party_id
                     )
                     OR
                     ( p_change_owner_to_code = 'I'
                       AND
                       p_txn_i_parties_tbl(l_p_ind).party_id <> l_internal_party_id
                     )
                  THEN

                    fnd_message.set_name('CSI','CSI_INT_INV_PTY_ID');
                    fnd_message.set_token('PARTY_ID',p_txn_i_parties_tbl(l_p_ind).party_id);
                    fnd_message.set_token('INTERNAL_PARTY_ID',l_internal_party_id);
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;

                  END IF;

                  exit;
                END IF;
              END IF;
            END LOOP;
          END IF;

          IF NOT (l_owner_found) THEN
            fnd_message.set_name('CSI','CSI_TXN_OWNER_NOT_FOUND');
            fnd_message.set_token('INDEX',l_i_ind);
            fnd_message.set_token('ITEM_ID',p_txn_instances_tbl(l_i_ind).inventory_item_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_owner_reference;

  /* --------------------------------------------------------------- */
  /* all the sub type specific validations handled in this routine   */
  /* --------------------------------------------------------------- */

  PROCEDURE sub_type_validations(
    p_sub_type_rec       IN  csi_txn_sub_types%rowtype,
    p_txn_instances_tbl  IN  csi_process_txn_grp.txn_instances_tbl,
    p_txn_i_parties_tbl  IN  csi_process_txn_grp.txn_i_parties_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'sub_type_validations');

    debug('Transaction type ID: '||p_sub_type_rec.transaction_type_id);
    debug('Sub type ID        : '||p_sub_type_rec.sub_type_id);

    IF p_sub_type_rec.src_reference_reqd = 'Y' THEN

      validate_reference(
        p_reference_type    => 'S',
        p_txn_instances_tbl => p_txn_instances_tbl,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF p_sub_type_rec.non_src_reference_reqd = 'Y' THEN

      validate_reference(
        p_reference_type    => 'N',
        p_txn_instances_tbl => p_txn_instances_tbl,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF p_sub_type_rec.parent_reference_reqd = 'Y' THEN

      validate_reference(
        p_reference_type    => 'P',
        p_txn_instances_tbl => p_txn_instances_tbl,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF p_sub_type_rec.src_change_owner = 'Y' THEN

      validate_owner_reference(
        p_reference_type       => 'S',
        p_change_owner_to_code => p_sub_type_rec.src_change_owner_to_code,
        p_txn_instances_tbl    => p_txn_instances_tbl,
        p_txn_i_parties_tbl    => p_txn_i_parties_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF p_sub_type_rec.non_src_change_owner = 'Y' THEN

      validate_owner_reference(
        p_reference_type       => 'N',
        p_change_owner_to_code => p_sub_type_rec.non_src_change_owner_to_code,
        p_txn_instances_tbl    => p_txn_instances_tbl,
        p_txn_i_parties_tbl    => p_txn_i_parties_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END sub_type_validations;


  /* -------------------------------------------------------------------- */
  /* gets all the inventory item specific attributes from the item master */
  /* -------------------------------------------------------------------- */

  PROCEDURE get_item_attributes(
    p_in_out_flag            IN  varchar2,
    p_sub_type_rec           IN  csi_txn_sub_types%rowtype,
    p_inventory_item_id      IN  number,
    p_organization_id        IN  number,
    x_item_attr_rec          OUT NOCOPY csi_process_txn_pvt.item_attr_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_item_attr_rec          csi_process_txn_pvt.item_attr_rec;

    l_serial_code            mtl_system_items.serial_number_control_code%TYPE;
    l_lot_code               mtl_system_items.lot_control_code%TYPE;
    l_locator_code           mtl_system_items.location_control_code%TYPE;
    l_revision_code          mtl_system_items.revision_qty_control_code%TYPE;
    l_ib_trackable_flag      mtl_system_items.comms_nl_trackable_flag%TYPE;
    l_shippable_flag         mtl_system_items.shippable_item_flag%TYPE;
    l_inv_item_flag          mtl_system_items.inventory_item_flag%TYPE;
    l_stockable_flag         mtl_system_items.stock_enabled_flag%TYPE;
    l_bom_item_type          mtl_system_items.bom_item_type%TYPE;

  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'get_item_attributes');

    x_return_status          := fnd_api.g_ret_sts_success;

    BEGIN

      SELECT serial_number_control_code,
             lot_control_code,
             location_control_code,
             revision_qty_control_code,
             nvl(comms_nl_trackable_flag,'N'),
             nvl(shippable_item_flag,'N'),
             nvl(inventory_item_flag,'N'),
             nvl(stock_enabled_flag,'N'),
             bom_item_type
      INTO   l_serial_code,
             l_lot_code,
             l_locator_code,
             l_revision_code,
             l_ib_trackable_flag,
             l_shippable_flag,
             l_inv_item_flag,
             l_stockable_flag,
             l_bom_item_type
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id   = p_organization_id;

    EXCEPTION
      WHEN no_data_found THEN

        fnd_message.set_name('CSI','CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID',p_inventory_item_id);
        fnd_message.set_token('INV_ORGANIZATION_ID',p_organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_serial_code = 1 THEN
      l_item_attr_rec.src_serial_control_flag := 'N';
      l_item_attr_rec.dst_serial_control_flag := 'N';
    ELSE
      IF l_serial_code = 6  THEN

        /* serial number generated for the SO Issue transaction */
        IF p_in_out_flag = 'OUT' THEN

          l_item_attr_rec.src_serial_control_flag := 'N';
          l_item_attr_rec.dst_serial_control_flag := 'Y';

        /* inventory cumulates the inbound quantity from an external source */
        ELSIF p_in_out_flag in ('IN', 'NONE') THEN

          l_item_attr_rec.src_serial_control_flag := 'Y';
          l_item_attr_rec.dst_serial_control_flag := 'N';

        ELSIF p_in_out_flag = 'INT' THEN

          l_item_attr_rec.src_serial_control_flag := 'N';
          l_item_attr_rec.dst_serial_control_flag := 'N';

        END IF;

      ELSE
        l_item_attr_rec.src_serial_control_flag := 'Y';
        l_item_attr_rec.dst_serial_control_flag := 'Y';
      END IF;
    END IF;

    IF l_lot_code = 1 THEN
      l_item_attr_rec.lot_control_flag    := 'N';
    ELSE
      l_item_attr_rec.lot_control_flag    := 'Y';
    END IF;

    IF l_locator_code = 1 THEN
      l_item_attr_rec.locator_control_flag := 'N';
    ELSE
      l_item_attr_rec.locator_control_flag := 'Y';
    END IF;

    IF l_revision_code = 1 THEN
      l_item_attr_rec.revision_control_flag := 'N';
    ELSE
      l_item_attr_rec.revision_control_flag := 'Y';
    END IF;

    l_item_attr_rec.ib_trackable_flag := l_ib_trackable_flag;
    l_item_attr_rec.shippable_flag    := l_shippable_flag;
    l_item_attr_rec.bom_item_type     := l_bom_item_type;
    l_item_attr_rec.stockable_flag    := l_stockable_flag;

    x_item_attr_rec := l_item_attr_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_item_attributes;


  /* -------------------------------------------------------------------- */
  /* validates the mandatory attributes for the instance. this is done to */
  /* ensure that the right query criteria is derived to fetch the item    */
  /* instance from the installed base                                     */
  /* -------------------------------------------------------------------- */

  PROCEDURE validate_instance_rec(
    p_instance_rec          IN  csi_process_txn_grp.txn_instance_rec,
    p_item_attr_rec         IN  csi_process_txn_pvt.item_attr_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS
  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'validate_instance_rec');

    x_return_status := fnd_api.g_ret_sts_success;

    -- serial control
    IF p_item_attr_rec.src_serial_control_flag = 'Y'
       OR
       p_item_attr_rec.dst_serial_control_flag = 'Y'
    THEN

      IF nvl(p_instance_rec.serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN

        fnd_message.set_name('CSI','CSI_TXN_SERIAL_NUM_MISSING');
        fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
        fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;

    -- lot control
    IF p_item_attr_rec.lot_control_flag = 'Y' THEN
      IF nvl(p_instance_rec.lot_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
        fnd_message.set_name('CSI','CSI_TXN_LOT_NUM_MISSING');
        fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
        fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- revision control
    IF p_item_attr_rec.revision_control_flag = 'Y' THEN
      IF nvl(p_instance_rec.inventory_revision, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
        fnd_message.set_name('CSI','CSI_TXN_ITEM_REV_MISSING');
        fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
        fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- locator control
    /*
    -- elliminated this validation as core API does this
    IF p_item_attr_rec.locator_control_flag = 'Y' THEN
      IF nvl(p_instance_rec.inv_locator_id , fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        fnd_message.set_name('CSI','CSI_TXN_LOCATOR_MISSING');
        fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
        fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    */

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_instance_rec;


  /* ----------------------------------------------------------------------- */
  /* this routine builds the query criteria for each of the instance records */
  /* passed without an instance id. The query criteria is built based on the */
  /* location attributes for the inventory item                              */
  /* ----------------------------------------------------------------------- */

  PROCEDURE build_instance_query_rec(
    p_query_criteria        IN  varchar2,
    p_in_out_flag           IN  varchar2,
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_instance_rec          IN  csi_process_txn_grp.txn_instance_rec,
    p_dest_location_rec     IN  csi_process_txn_grp.dest_location_rec,
    p_item_attr_rec         IN  csi_process_txn_pvt.item_attr_rec,
    x_instance_query_rec    OUT NOCOPY csi_datastructures_pub.instance_query_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'build_instance_query_rec');

    l_inst_query_rec.inventory_item_id     := p_instance_rec.inventory_item_id;
    l_inst_query_rec.unit_of_measure       := p_instance_rec.unit_of_measure;

    l_inst_query_rec.serial_number         := p_instance_rec.serial_number;

    -- lot control
    IF p_item_attr_rec.lot_control_flag = 'Y' THEN
      l_inst_query_rec.lot_number          := p_instance_rec.lot_number;
    END IF;

    -- revision control
    IF p_item_attr_rec.revision_control_flag = 'Y' THEN
      l_inst_query_rec.inventory_revision  := p_instance_rec.inventory_revision;
    ELSE
      -- If item is not revision controled or flipped to no-revision control
      -- assigning NULL, so that it will fetch single inatance
      l_inst_query_rec.inventory_revision  := null;
    END IF;

    IF p_query_criteria = 'SOURCE' THEN

      l_inst_query_rec.location_type_code    := p_instance_rec.location_type_code;
      l_inst_query_rec.location_id           := p_instance_rec.location_id;

      l_inst_query_rec.inv_organization_id   := p_instance_rec.inv_organization_id;
      l_inst_query_rec.inv_subinventory_name := p_instance_rec.inv_subinventory_name;
      l_inst_query_rec.inv_locator_id        := p_instance_rec.inv_locator_id;
      l_inst_query_rec.wip_job_id            := p_instance_rec.last_wip_job_id;

      IF p_item_attr_rec.src_serial_control_flag = 'N' THEN
        l_inst_query_rec.serial_number       := null;
      END IF;

    ELSIF p_query_criteria = 'DESTINATION' THEN

      l_inst_query_rec.location_type_code    := p_dest_location_rec.location_type_code;
      l_inst_query_rec.location_id           := p_dest_location_rec.location_id;

      l_inst_query_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
      l_inst_query_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
      l_inst_query_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
      l_inst_query_rec.instance_usage_code   := p_dest_location_rec.instance_usage_code;
      l_inst_query_rec.operational_status_code := p_dest_location_rec.operational_status_code;

      IF p_item_attr_rec.dst_serial_control_flag = 'N' THEN
        l_inst_query_rec.serial_number       := null;
      END IF;

      l_inst_query_rec.wip_job_id  := p_dest_location_rec.wip_job_id;

      IF l_inst_query_rec.location_type_code = 'WIP' THEN
        l_inst_query_rec.instance_usage_code := 'IN_WIP';
      END IF;

      IF l_inst_query_rec.location_type_code = 'PROJECT' THEN
        l_inst_query_rec.pa_project_id      := p_dest_location_rec.pa_project_id;
        l_inst_query_rec.pa_project_task_id := p_dest_location_rec.pa_project_task_id;
      END IF;

    END IF;

    IF l_inst_query_rec.location_type_code = 'INVENTORY' THEN
      l_inst_query_rec.instance_usage_code := 'IN_INVENTORY';
      l_inst_query_rec.location_id         := fnd_api.g_miss_num;
    END IF;

    x_instance_query_rec := l_inst_query_rec;

    debug('Instance query criteria for '||p_query_criteria);

    csi_t_gen_utility_pvt.dump_instance_query_rec(
      p_instance_query_rec => x_instance_query_rec);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_instance_query_rec;


  PROCEDURE get_negative_code(
    p_organization_id  in  number,
    x_negative_code    OUT NOCOPY number,
    x_return_status    OUT NOCOPY varchar2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    SELECT negative_inv_receipt_code
    INTO   x_negative_code
    FROM   mtl_parameters
    WHERE  organization_id = p_organization_id;
  EXCEPTION
    WHEN others then
      x_return_status := fnd_api.g_ret_sts_error;
  END get_negative_code;

  PROCEDURE create_zero_qty_instance(
    p_instance_rec  in     csi_process_txn_grp.txn_instance_rec,
    p_txn_rec       in OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_instance_id      OUT NOCOPY number,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_transaction_rec   csi_datastructures_pub.transaction_rec;
    l_instance_rec      csi_datastructures_pub.instance_rec;
    l_parties_tbl       csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl     csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl     csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl       csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl        csi_datastructures_pub.instance_asset_tbl;

    l_internal_party_id number;

    l_u_instance_rec    csi_datastructures_pub.instance_rec;
    l_u_parties_tbl     csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl   csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl   csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl      csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list csi_datastructures_pub.id_tbl;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('create_zero_qty_instance');

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    l_instance_rec.inventory_item_id      := p_instance_rec.inventory_item_id;
    l_instance_rec.inventory_revision     := p_instance_rec.inventory_revision;
    l_instance_rec.inv_subinventory_name  := p_instance_rec.inv_subinventory_name;
    -- this is always a non serial instance
    l_instance_rec.serial_number          := fnd_api.g_miss_char;
    l_instance_rec.lot_number             := p_instance_rec.lot_number;
    l_instance_rec.quantity               := 1;
    l_instance_rec.active_start_date      := sysdate;
    l_instance_rec.active_end_date        := null;
    l_instance_rec.unit_of_measure        := p_instance_rec.unit_of_measure;
    l_instance_rec.location_type_code     := 'INVENTORY';
    l_instance_rec.location_id            := p_instance_rec.location_id;
    IF nvl(l_instance_rec.location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      get_dfl_inv_location(
        p_subinventory_code => p_instance_rec.inv_subinventory_name,
        p_organization_id   => p_instance_rec.inv_organization_id,
        x_location_id       => l_instance_rec.location_id,
        x_return_status     => l_return_status);
    END IF;
    l_instance_rec.instance_usage_code    := 'IN_INVENTORY';
    l_instance_rec.inv_organization_id    := p_instance_rec.inv_organization_id;
    l_instance_rec.vld_organization_id    := p_instance_rec.inv_organization_id;
    l_instance_rec.inv_locator_id         := p_instance_rec.inv_locator_id;
    l_instance_rec.customer_view_flag     := 'N';
    l_instance_rec.merchant_view_flag     := 'Y';
    l_instance_rec.object_version_number  := 1;

    l_parties_tbl(1).party_source_table    := 'HZ_PARTIES';
    l_parties_tbl(1).party_id              := l_internal_party_id;
    l_parties_tbl(1).relationship_type_code:= 'OWNER';
    l_parties_tbl(1).contact_flag          := 'N';

    csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'create_item_instance');

    -- creation of zero quantity instance
    csi_item_instance_pub.create_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_instance_rec,
      p_party_tbl             => l_parties_tbl,
      p_account_tbl           => l_pty_accts_tbl,
      p_org_assignments_tbl   => l_org_units_tbl,
      p_ext_attrib_values_tbl => l_ea_values_tbl,
      p_pricing_attrib_tbl    => l_pricing_tbl,
      p_asset_assignment_tbl  => l_assets_tbl,
      p_txn_rec               => p_txn_rec,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data );

    -- For Bug 4057183
    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      raise fnd_api.g_exc_error;
    END IF;

    x_instance_id := l_instance_rec.instance_id;

    debug('Instance created successfully. Instance ID :'||l_instance_rec.instance_id);

    l_u_instance_rec.instance_id := l_instance_rec.instance_id;
    l_u_instance_rec.quantity    := 0;
    l_u_instance_rec.object_version_number := l_instance_rec.object_version_number;

    csi_t_gen_utility_pvt.dump_csi_instance_rec(l_u_instance_rec);

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'update_item_instance');

    -- update to make a zero quantity instance
    csi_item_instance_pub.update_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_u_instance_rec,
      p_party_tbl             => l_u_parties_tbl,
      p_account_tbl           => l_u_pty_accts_tbl,
      p_org_assignments_tbl   => l_u_org_units_tbl,
      p_ext_attrib_values_tbl => l_u_ea_values_tbl,
      p_pricing_attrib_tbl    => l_u_pricing_tbl,
      p_asset_assignment_tbl  => l_u_assets_tbl,
      p_txn_rec               => p_txn_rec,
      x_instance_id_lst       => l_instance_ids_list,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    -- For Bug 4057183
    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_zero_qty_instance;

  /* ---------------------------------------------------------------------- */
  /* core routine that gets the item instance from the installed base. this */
  /* routine returns an error when multiple instances are fetched for the   */
  /* given query criteria
  /* ---------------------------------------------------------------------- */

  PROCEDURE get_src_instance_id(
    p_in_out_flag           IN  varchar2,
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_instance_rec          IN  csi_process_txn_grp.txn_instance_rec,
    p_dest_location_rec     IN  csi_process_txn_grp.dest_location_rec,
    p_item_attr_rec         IN  csi_process_txn_pvt.item_attr_rec,
    p_transaction_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_instance_id           OUT NOCOPY number,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_instance_query_rec    csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    l_instance_header_tbl   csi_datastructures_pub.instance_header_tbl;
    l_change_owner          varchar2(1);
    l_owner_to_code         varchar2(1);
    l_negative_code         number;
    l_pty_override_flag      varchar2(1) := 'N';

    instance_not_found      exception;
    skip_instance_search    exception;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

    -- Begin adding code for bug 7207346
    l_num_unexpired_instances   number := 0;
    l_unexpired_instance_index  number := 0;
    l_expired_status_id         number := 0;
    l_expired                   varchar2(1);
    -- End adding code for bug 7207346

  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'get_src_instance_id');

    x_return_status         := fnd_api.g_ret_sts_success;

    /* for WIP component return transaction  the source instance will be processed
       in the WIP pice of code itself
    */
    IF p_in_out_flag = 'INT' and p_instance_rec.location_type_code = 'WIP' THEN
      x_instance_id := fnd_api.g_miss_num;
      RAISE skip_instance_search;
    END IF;

    validate_instance_rec(
      p_instance_rec        => p_instance_rec,
      p_item_attr_rec       => p_item_attr_rec,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    build_instance_query_rec(
      p_query_criteria      => 'SOURCE',
      p_in_out_flag         => p_in_out_flag,
      p_sub_type_rec        => p_sub_type_rec,
      p_instance_rec        => p_instance_rec,
      p_dest_location_rec   => p_dest_location_rec,
      p_item_attr_rec       => p_item_attr_rec,
      x_instance_query_rec  => l_instance_query_rec,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_item_instance_pub.get_item_instances(
      p_api_version          => 1.0,
      p_commit               => fnd_api.g_false,
      p_init_msg_list        => fnd_api.g_true,
      p_validation_level     => fnd_api.g_valid_level_full,
      p_instance_query_rec   => l_instance_query_rec,
      p_party_query_rec      => l_party_query_rec,
      p_account_query_rec    => l_pty_acct_query_rec,
      p_transaction_id       => NULL,
      p_resolve_id_columns   => fnd_api.g_false,
      p_active_instance_only => fnd_api.g_false,
      x_instance_header_tbl  => l_instance_header_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_change_owner     := p_sub_type_rec.src_change_owner;
    l_owner_to_code    := p_sub_type_rec.src_change_owner_to_code;

    debug('Instance table count :'||l_instance_header_tbl.COUNT);

    -- Start adding code for bug 7207346
    -- In the event of multiple instances begining returned
    -- Not sure if also need to filter for terminated instances
    l_num_unexpired_instances := 0;
    l_unexpired_instance_index := 0;

    IF l_instance_header_tbl.COUNT > 0 THEN
       BEGIN
        SELECT instance_status_id
        INTO   l_expired_status_id
        FROM   csi_instance_statuses
        WHERE  name = 'EXPIRED';
       EXCEPTION
         WHEN OTHERS THEN
         NULL;
       END;

       FOR l_ind IN l_instance_header_tbl.FIRST .. l_instance_header_tbl.LAST
         LOOP
          BEGIN
            SELECT 'Y'
            INTO   l_expired
            FROM   csi_item_instances
            WHERE  instance_id = l_instance_header_tbl(l_ind).instance_id
            AND    instance_status_id = l_expired_status_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_expired := 'N';
          END;

          IF l_expired = 'N' THEN
            l_num_unexpired_instances := l_num_unexpired_instances + 1;
             IF l_num_unexpired_instances > 1 THEN
               EXIT;
             END IF;
             l_unexpired_instance_index := l_ind;
          END IF;
        END LOOP;
      END IF;
      -- End adding code for bug 7207346

    IF l_instance_header_tbl.COUNT = 0 THEN

      x_instance_id := fnd_api.g_miss_num;

      /* here are the conditions where instance ref is reqd If a reference  */
      /* cannot be obtained then it is an error condition. Either the query */
      /* criteria (Item, Rev, Org, Subinv, Locator, Lot Num, Serial Num) is */
      /* not passed correctly or the material receipt is not converted in   */
      /* to an instance                                                     */

      /* issue to projects /issue to wip job/misc issue/wip comp return */
      IF p_in_out_flag = 'INT' and l_change_owner = 'N' THEN

        /* wip comp return */
        IF nvl(p_instance_rec.location_type_code,fnd_api.g_miss_char) = 'WIP' THEN
          x_instance_id := fnd_api.g_miss_num;

        ELSE
          /* wip comp issue or for anything the source is inventory */
          IF nvl(p_instance_rec.location_type_code,fnd_api.g_miss_char) = 'INVENTORY' THEN
            get_negative_code(
              p_organization_id => p_instance_rec.inv_organization_id,
              x_negative_code   => l_negative_code,
              x_return_status   => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;
            -- for wip comp issue override it with the backflush profile value
            IF l_negative_code = 2 AND p_transaction_rec.transaction_type_id = 71 THEN
              l_negative_code := nvl(fnd_profile.value('inv_override_neg_for_backflush'), 2);
            END IF;
            IF l_negative_code = 1 and p_item_attr_rec.src_serial_control_flag = 'N' THEN
              debug('Org allows negative quantities. So creating an instance with 0 quantity.');
              csi_process_txn_pvt.create_zero_qty_instance(
                p_instance_rec  => p_instance_rec,
                p_txn_rec       => p_transaction_rec,
                x_instance_id   => x_instance_id,
                x_return_status => l_return_status);
              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            ELSE
              raise instance_not_found;
            END IF;

          ELSE
            raise instance_not_found;
          END IF;
        END IF;
      END IF;

      -- receipt from customer / into the subinventory
      IF p_in_out_flag = 'IN' THEN

        IF l_change_owner = 'N' THEN

          -- exclude misc receipt (source location attributes are null)
          IF nvl(p_instance_rec.location_type_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
             OR
             nvl(p_instance_rec.location_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
             OR
             nvl(p_instance_rec.inv_organization_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
             OR
             nvl(p_instance_rec.inv_subinventory_name, fnd_api.g_miss_char)<> fnd_api.g_miss_char
          THEN
            -- if it is return for repair from customer  and item is serialized and
            -- the CSI Profile to process the txn is set to 'Y' then a source instance is not required
            -- Added this for the ER 2482219. Return for repair

            l_pty_override_flag:= csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;

            debug('  ownership_override_at_txn : '||l_pty_override_flag);

            IF p_item_attr_rec.src_serial_control_flag = 'Y'
               AND
               p_instance_rec.location_type_code = 'HZ_PARTY_SITES'
               AND
               nvl(l_pty_override_flag, 'N') = 'Y'
            THEN
              debug(' return for repair and no instance found:: marking for create');
              x_instance_id := fnd_api.g_miss_num;
            ELSE
              /* for subinventory transfer the source instance ref is required */
              raise instance_not_found;
            END IF;
          ELSE
            /* for miscellaneous receipt source instance is not required */
            x_instance_id := fnd_api.g_miss_num;
          END IF;

        /* receipt in from customer - return for credit case */
        ELSIF l_change_owner = 'Y' THEN
          x_instance_id := fnd_api.g_miss_num;
        END IF;

      END IF;

      /* ship to customer from inventory, install operation from field service*/
      IF p_in_out_flag = 'OUT' THEN

        /* this logic is added to fix bug 2260019. This is the case when onhand balance is 0
           and there is no instance in ib as source and the inv org allows negative balances
           when the quantity goes to -ive create a 0 qty instance and use it to decrement qty
        */
        IF nvl(p_instance_rec.location_type_code,fnd_api.g_miss_char) = 'INVENTORY' THEN
          get_negative_code(
            p_organization_id => p_instance_rec.inv_organization_id,
            x_negative_code   => l_negative_code,
            x_return_status   => l_return_status);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;
          IF l_negative_code = 1 and p_item_attr_rec.src_serial_control_flag = 'N' THEN
            debug('Org allows negative quantities. So creating an instance with 0 quantity.');
            csi_process_txn_pvt.create_zero_qty_instance(
              p_instance_rec  => p_instance_rec,
              p_txn_rec       => p_transaction_rec,
              x_instance_id   => x_instance_id,
              x_return_status => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            raise instance_not_found;
          END IF;

        ELSE
          raise instance_not_found;
        END IF;
      END IF;

    ELSIF l_instance_header_tbl.COUNT = 1 THEN
      x_instance_id := l_instance_header_tbl(1).instance_id;

      /* doing this because the wip instance can be returned even if there is no
         quantity in WIP -- srini knows the scenario
      */
      IF nvl(p_instance_rec.location_type_code,fnd_api.g_miss_char) = 'WIP'
         AND l_instance_header_tbl(1).quantity = 0 THEN
        x_instance_id := fnd_api.g_miss_num;
      END IF;

       ELSIF l_instance_header_tbl.COUNT > 1 AND l_num_unexpired_instances = 1 THEN
       debug('only 1 of the '||l_instance_header_tbl.COUNT||' instances found is unexpired');
       x_instance_id := l_instance_header_tbl(l_unexpired_instance_index).instance_id;

       /* doing this because the wip instance can be returned even if there is no
           quantity in WIP -- srini knows the scenario
        */
        IF nvl(p_instance_rec.location_type_code, fnd_api.g_miss_char) = 'WIP'
          AND l_instance_header_tbl(l_unexpired_instance_index).quantity = 0 THEN
          x_instance_id := fnd_api.g_miss_num;
        END IF;

    ELSE --[Multiple instances found]


      /* receive from customer */
      IF p_in_out_flag = 'IN' and l_change_owner = 'Y' THEN
        x_instance_id := fnd_api.g_miss_num;
      ELSE
        fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
        fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
        fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
        fnd_message.set_token('SUBINV',p_instance_rec.inv_subinventory_name);
        fnd_message.set_token('LOCATOR',p_instance_rec.inv_locator_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN skip_instance_search THEN
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN instance_not_found THEN
      fnd_message.set_name('CSI','CSI_TXN_INST_NOT_FOUND');
      fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
      fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
      fnd_message.set_token('SUBINV',p_instance_rec.inv_subinventory_name);
      fnd_message.set_token('LOCATOR',p_instance_rec.inv_locator_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_src_instance_id;


  PROCEDURE get_dest_instance_id(
    p_in_out_flag           IN  varchar2,
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_instance_rec          IN  csi_process_txn_grp.txn_instance_rec,
    p_dest_location_rec     IN  csi_process_txn_grp.dest_location_rec,
    p_item_attr_rec         IN  csi_process_txn_pvt.item_attr_rec,
    x_instance_id           OUT NOCOPY number,
    x_return_status         OUT NOCOPY varchar2)

  IS

    l_instance_query_rec    csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    l_instance_header_tbl   csi_datastructures_pub.instance_header_tbl;
    l_change_owner          varchar2(1);
    l_owner_to_code         varchar2(1);

    instance_not_found      exception;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

     -- Begin adding code for bug 7207346
     l_num_unexpired_instances   number := 0;
     l_unexpired_instance_index  number := 0;
     l_expired_status_id         number := 0;
     l_expired                   varchar2(1);
     -- End adding code for bug 7207346

  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'get_dest_instance_id');

    x_return_status         := fnd_api.g_ret_sts_success;

    build_instance_query_rec(
      p_query_criteria      => 'DESTINATION',
      p_in_out_flag         => p_in_out_flag,
      p_sub_type_rec        => p_sub_type_rec,
      p_instance_rec        => p_instance_rec,
      p_dest_location_rec   => p_dest_location_rec,
      p_item_attr_rec       => p_item_attr_rec,
      x_instance_query_rec  => l_instance_query_rec,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'get_item_instances');

    csi_item_instance_pub.get_item_instances(
      p_api_version          => 1.0,
      p_commit               => fnd_api.g_false,
      p_init_msg_list        => fnd_api.g_true,
      p_validation_level     => fnd_api.g_valid_level_full,
      p_instance_query_rec   => l_instance_query_rec,
      p_party_query_rec      => l_party_query_rec,
      p_account_query_rec    => l_pty_acct_query_rec,
      p_transaction_id       => NULL,
      p_resolve_id_columns   => fnd_api.g_false,
      p_active_instance_only => fnd_api.g_false,
      x_instance_header_tbl  => l_instance_header_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_change_owner     := p_sub_type_rec.src_change_owner;
    l_owner_to_code    := p_sub_type_rec.src_change_owner_to_code;

    debug('Instance table count :'||l_instance_header_tbl.COUNT);

    -- Start adding code for bug 7207346
    -- In the event of multiple instances begining returned
    -- Must filter for expired instances
    l_num_unexpired_instances := 0;
    l_unexpired_instance_index := 0;

    IF l_instance_header_tbl.COUNT > 0 THEN
       BEGIN
         SELECT instance_status_id
         INTO   l_expired_status_id
         FROM   csi_instance_statuses
         WHERE  name = 'EXPIRED';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

       FOR l_ind IN l_instance_header_tbl.FIRST .. l_instance_header_tbl.LAST
        LOOP
          BEGIN
            SELECT 'Y'
            INTO   l_expired
            FROM   csi_item_instances
            WHERE  instance_id = l_instance_header_tbl(l_ind).instance_id
            AND    instance_status_id = l_expired_status_id;
           EXCEPTION
            WHEN OTHERS THEN
              l_expired := 'N';
          END;

          IF l_expired = 'N' THEN
            l_num_unexpired_instances := l_num_unexpired_instances + 1;
            IF l_num_unexpired_instances > 1 THEN
              EXIT;
            END IF;
            l_unexpired_instance_index := l_ind;
          END IF;
        END LOOP;
      END IF;
      -- End adding code for bug 7207346

    IF l_instance_header_tbl.COUNT = 0 THEN

      x_instance_id := fnd_api.g_miss_num;

    ELSIF l_instance_header_tbl.COUNT = 1 THEN
      x_instance_id := l_instance_header_tbl(1).instance_id;
    ELSIF l_instance_header_tbl.COUNT > 1 AND l_num_unexpired_instances = 1 THEN -- Add condition for bug 7207346
      debug('only 1 of the '||l_instance_header_tbl.COUNT||' instances found is unexpired');
      x_instance_id := l_instance_header_tbl(l_unexpired_instance_index).instance_id;
    ELSE

      fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
      fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
      fnd_message.set_token('INV_ORG_ID',p_dest_location_rec.inv_organization_id);
      fnd_message.set_token('SUBINV',p_dest_location_rec.inv_subinventory_name);
      fnd_message.set_token('LOCATOR',p_dest_location_rec.inv_locator_id);

      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

    END IF;

  EXCEPTION
    WHEN instance_not_found THEN
      fnd_message.set_name('CSI','CSI_TXN_INST_NOT_FOUND');
      fnd_message.set_token('INV_ITEM_ID',p_instance_rec.inventory_item_id);
      fnd_message.set_token('INV_ORG_ID',p_instance_rec.inv_organization_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_dest_instance_id;


  /* ---------------------------------------------------------------------*/
  /* this routine translates the txn_instance_rec into instance_rec. this */
  /* also determines whether the instance is marked for a creation or     */
  /* for an update based on the availability on the instance record       */
  /* ---------------------------------------------------------------------*/

  PROCEDURE build_instance_rec(
    p_sub_type_rec        IN  csi_txn_sub_types%rowtype,
    p_item_attr_rec       IN  csi_process_txn_pvt.item_attr_rec,
    p_instance_rec        IN  csi_process_txn_grp.txn_instance_rec,
    p_dest_location_rec   IN  csi_process_txn_grp.dest_location_rec,
    x_instance_rec        OUT NOCOPY csi_datastructures_pub.instance_rec,
    x_process_mode        OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_instance_rec        csi_datastructures_pub.instance_rec;
    l_process_mode        varchar2(30);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_instance_rec.instance_id   := p_instance_rec.instance_id;

    /* the derived instance id would be in the new_instance_id column */
    IF nvl(p_instance_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      l_instance_rec.instance_id := p_instance_rec.new_instance_id;
    END IF;

    IF nvl(l_instance_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_process_mode := 'UPDATE';
    ELSE
      l_process_mode := 'CREATE';
    END IF;

    l_instance_rec.instance_number       := p_instance_rec.instance_number;
    l_instance_rec.external_reference    := p_instance_rec.external_reference;
    l_instance_rec.inventory_item_id     := p_instance_rec.inventory_item_id;
    l_instance_rec.vld_organization_id   := p_instance_rec.vld_organization_id;
    l_instance_rec.inventory_revision    := p_instance_rec.inventory_revision;
    l_instance_rec.inv_master_organization_id := p_instance_rec.inv_master_organization_id;
    l_instance_rec.serial_number         := p_instance_rec.serial_number;
    l_instance_rec.mfg_serial_number_flag := p_instance_rec.mfg_serial_number_flag;
    l_instance_rec.lot_number            := p_instance_rec.lot_number;
    l_instance_rec.quantity              := p_instance_rec.quantity;
    l_instance_rec.unit_of_measure       := p_instance_rec.unit_of_measure;
    l_instance_rec.accounting_class_code := p_instance_rec.accounting_class_code;
    l_instance_rec.instance_condition_id := p_instance_rec.instance_condition_id;
    l_instance_rec.customer_view_flag    := p_instance_rec.customer_view_flag;
    l_instance_rec.merchant_view_flag    := p_instance_rec.merchant_view_flag;
    l_instance_rec.sellable_flag         := p_instance_rec.sellable_flag;
    l_instance_rec.system_id             := p_instance_rec.system_id;
    l_instance_rec.instance_type_code    := p_instance_rec.instance_type_code;
    l_instance_rec.active_start_date     := p_instance_rec.active_start_date;
    l_instance_rec.active_end_date       := p_instance_rec.active_end_date;
    l_instance_rec.location_type_code    := p_instance_rec.location_type_code;
    l_instance_rec.location_id           := p_instance_rec.location_id;
    l_instance_rec.inv_organization_id   := p_instance_rec.inv_organization_id;
    l_instance_rec.inv_subinventory_name := p_instance_rec.inv_subinventory_name;
    l_instance_rec.inv_locator_id        := p_instance_rec.inv_locator_id;
    l_instance_rec.pa_project_id         := p_instance_rec.pa_project_id;
    l_instance_rec.pa_project_task_id    := p_instance_rec.pa_project_task_id;
    l_instance_rec.in_transit_order_line_id := p_instance_rec.in_transit_order_line_id;
    l_instance_rec.wip_job_id            := p_instance_rec.wip_job_id;
    l_instance_rec.po_order_line_id      := p_instance_rec.po_order_line_id;
    l_instance_rec.last_oe_order_line_id := p_instance_rec.last_oe_order_line_id;
    l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;
    l_instance_rec.last_po_po_line_id    := p_instance_rec.last_po_po_line_id;
    l_instance_rec.last_oe_po_number     := p_instance_rec.last_oe_po_number;
    l_instance_rec.last_wip_job_id       := p_instance_rec.last_wip_job_id;
    l_instance_rec.last_pa_project_id    := p_instance_rec.last_pa_project_id;
    l_instance_rec.last_pa_task_id       := p_instance_rec.last_pa_task_id;
    l_instance_rec.last_oe_agreement_id  := p_instance_rec.last_oe_agreement_id;
    l_instance_rec.install_date          := p_instance_rec.install_date;
    l_instance_rec.manually_created_flag := p_instance_rec.manually_created_flag;
    l_instance_rec.return_by_date        := p_instance_rec.return_by_date;
    l_instance_rec.actual_return_date    := p_instance_rec.actual_return_date;
    l_instance_rec.creation_complete_flag := p_instance_rec.creation_complete_flag;
    l_instance_rec.completeness_flag     := p_instance_rec.completeness_flag;
    l_instance_rec.version_label         := p_instance_rec.version_label;
    l_instance_rec.version_label_description := p_instance_rec.version_label_description;
    l_instance_rec.context               := p_instance_rec.context;
    l_instance_rec.attribute1            := p_instance_rec.attribute1;
    l_instance_rec.attribute2            := p_instance_rec.attribute2;
    l_instance_rec.attribute3            := p_instance_rec.attribute3;
    l_instance_rec.attribute4            := p_instance_rec.attribute4;
    l_instance_rec.attribute5            := p_instance_rec.attribute5;
    l_instance_rec.attribute6            := p_instance_rec.attribute6;
    l_instance_rec.attribute7            := p_instance_rec.attribute7;
    l_instance_rec.attribute8            := p_instance_rec.attribute8;
    l_instance_rec.attribute9            := p_instance_rec.attribute9;
    l_instance_rec.attribute10           := p_instance_rec.attribute10;
    l_instance_rec.attribute11           := p_instance_rec.attribute11;
    l_instance_rec.attribute12           := p_instance_rec.attribute12;
    l_instance_rec.attribute13           := p_instance_rec.attribute13;
    l_instance_rec.attribute14           := p_instance_rec.attribute14;
    l_instance_rec.attribute15           := p_instance_rec.attribute15;
    l_instance_rec.object_version_number := p_instance_rec.object_version_number;
    l_instance_rec.last_txn_line_detail_id := p_instance_rec.last_txn_line_detail_id;
    l_instance_rec.install_location_type_code := p_instance_rec.install_location_type_code;
    l_instance_rec.install_location_id   := p_instance_rec.install_location_id;
    l_instance_rec.instance_status_id    := p_instance_rec.instance_status_id;
    --
    -- srramakr TSO with Equipment
    -- Input instance_rec will have NULL config keys in case of RMA Receipt/Fulfillment.
    -- This needs to be passed to Update_Item_Instace API to Nullify the same
    --
    l_instance_rec.CONFIG_INST_HDR_ID := p_instance_rec.CONFIG_INST_HDR_ID;
    l_instance_rec.CONFIG_INST_REV_NUM := p_instance_rec.CONFIG_INST_REV_NUM;
    l_instance_rec.CONFIG_INST_ITEM_ID := p_instance_rec.CONFIG_INST_ITEM_ID;
    --
    --
    IF p_dest_location_rec.location_type_code = 'INVENTORY' THEN
      l_instance_rec.instance_usage_code := 'IN_INVENTORY';
    END IF;

    IF p_item_attr_rec.src_serial_control_flag = 'Y' AND
       p_item_attr_rec.dst_serial_control_flag = 'Y' THEN
      IF nvl(l_instance_rec.instance_status_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        l_instance_rec.instance_status_id := p_sub_type_rec.src_status_id;
      END IF;
    END IF;

    x_instance_rec := l_instance_rec;
    x_process_mode := l_process_mode;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_instance_rec;


  /* --------------------------------------------------------------------- */
  /* this routine builds the party and party accounts table for a specific */
  /* parent (instance). The master and the child tables are tied up using  */
  /* the parent_tbl_index column                                           */
  /* --------------------------------------------------------------------- */

  PROCEDURE build_parties_for_index(
    p_instance_index      IN  binary_integer,
    p_i_parties_tbl       IN  csi_process_txn_grp.txn_i_parties_tbl,
    p_ip_accounts_tbl     IN  csi_process_txn_grp.txn_ip_accounts_tbl,
    x_parties_tbl         OUT NOCOPY csi_datastructures_pub.party_tbl,
    x_pty_accts_tbl       OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    c_ind                 binary_integer;
    c_a_ind               binary_integer;

    l_pty_tbl             csi_datastructures_pub.party_tbl;
    l_pty_acct_tbl        csi_datastructures_pub.party_account_tbl;

  BEGIN

    c_ind   := 0;
    c_a_ind := 0;
    IF p_i_parties_tbl.COUNT > 0 THEN
      FOR l_ind IN p_i_parties_tbl.FIRST .. p_i_parties_tbl.LAST
      LOOP

        IF p_i_parties_tbl(l_ind).parent_tbl_index = p_instance_index THEN

          /* debug messages */
          csi_t_gen_utility_pvt.dump_txn_i_party_rec(
            p_txn_i_party_rec  => p_i_parties_tbl(l_ind));

          c_ind := c_ind + 1;

          l_pty_tbl(c_ind).instance_party_id := p_i_parties_tbl(l_ind).instance_party_id;
          l_pty_tbl(c_ind).instance_id       := p_i_parties_tbl(l_ind).instance_id;
          l_pty_tbl(c_ind).party_source_table:= p_i_parties_tbl(l_ind).party_source_table;
          l_pty_tbl(c_ind).party_id          := p_i_parties_tbl(l_ind).party_id;
          l_pty_tbl(c_ind).relationship_type_code:= p_i_parties_tbl(l_ind).relationship_type_code;
          l_pty_tbl(c_ind).contact_flag      := p_i_parties_tbl(l_ind).contact_flag;
          l_pty_tbl(c_ind).contact_ip_id     := p_i_parties_tbl(l_ind).contact_ip_id;
          l_pty_tbl(c_ind).active_start_date := p_i_parties_tbl(l_ind).active_start_date;
          l_pty_tbl(c_ind).active_end_date   := p_i_parties_tbl(l_ind).active_end_date;
          l_pty_tbl(c_ind).context           := p_i_parties_tbl(l_ind).context;
          l_pty_tbl(c_ind).attribute1        := p_i_parties_tbl(l_ind).attribute1;
          l_pty_tbl(c_ind).attribute2        := p_i_parties_tbl(l_ind).attribute2;
          l_pty_tbl(c_ind).attribute3        := p_i_parties_tbl(l_ind).attribute3;
          l_pty_tbl(c_ind).attribute4        := p_i_parties_tbl(l_ind).attribute4;
          l_pty_tbl(c_ind).attribute5        := p_i_parties_tbl(l_ind).attribute5;
          l_pty_tbl(c_ind).attribute6        := p_i_parties_tbl(l_ind).attribute6;
          l_pty_tbl(c_ind).attribute7        := p_i_parties_tbl(l_ind).attribute7;
          l_pty_tbl(c_ind).attribute8        := p_i_parties_tbl(l_ind).attribute8;
          l_pty_tbl(c_ind).attribute9        := p_i_parties_tbl(l_ind).attribute9;
          l_pty_tbl(c_ind).attribute10       := p_i_parties_tbl(l_ind).attribute10;
          l_pty_tbl(c_ind).attribute11       := p_i_parties_tbl(l_ind).attribute11;
          l_pty_tbl(c_ind).attribute12       := p_i_parties_tbl(l_ind).attribute12;
          l_pty_tbl(c_ind).attribute13       := p_i_parties_tbl(l_ind).attribute13;
          l_pty_tbl(c_ind).attribute14       := p_i_parties_tbl(l_ind).attribute14;
          l_pty_tbl(c_ind).attribute15       := p_i_parties_tbl(l_ind).attribute15;
          l_pty_tbl(c_ind).object_version_number := p_i_parties_tbl(l_ind).object_version_number;


          IF p_ip_accounts_tbl.COUNT > 0 THEN
            FOR l_a_ind IN p_ip_accounts_tbl.FIRST .. p_ip_accounts_tbl.LAST
            LOOP

              IF p_ip_accounts_tbl(l_a_ind).parent_tbl_index = l_ind THEN

                /* debug messages */
                csi_t_gen_utility_pvt.dump_txn_ip_account_rec(
                  p_txn_ip_account_rec => p_ip_accounts_tbl(l_a_ind));

                c_a_ind := c_a_ind + 1;

                l_pty_acct_tbl(c_a_ind).ip_account_id := p_ip_accounts_tbl(l_a_ind).ip_account_id;
                l_pty_acct_tbl(c_a_ind).parent_tbl_index := c_ind;
                l_pty_acct_tbl(c_a_ind).instance_party_id := p_ip_accounts_tbl(l_a_ind).instance_party_id;
                l_pty_acct_tbl(c_a_ind).party_account_id := p_ip_accounts_tbl(l_a_ind).party_account_id;
                l_pty_acct_tbl(c_a_ind).relationship_type_code := p_ip_accounts_tbl(l_a_ind).relationship_type_code;
                l_pty_acct_tbl(c_a_ind).bill_to_address := p_ip_accounts_tbl(l_a_ind).bill_to_address;
                l_pty_acct_tbl(c_a_ind).ship_to_address := p_ip_accounts_tbl(l_a_ind).ship_to_address;
                l_pty_acct_tbl(c_a_ind).active_start_date := p_ip_accounts_tbl(l_a_ind).active_start_date;
                l_pty_acct_tbl(c_a_ind).active_end_date := p_ip_accounts_tbl(l_a_ind).active_end_date;
                l_pty_acct_tbl(c_a_ind).context     := p_ip_accounts_tbl(l_a_ind).context;
                l_pty_acct_tbl(c_a_ind).attribute1  := p_ip_accounts_tbl(l_a_ind).attribute1;
                l_pty_acct_tbl(c_a_ind).attribute2  := p_ip_accounts_tbl(l_a_ind).attribute2;
                l_pty_acct_tbl(c_a_ind).attribute3  := p_ip_accounts_tbl(l_a_ind).attribute3;
                l_pty_acct_tbl(c_a_ind).attribute4  := p_ip_accounts_tbl(l_a_ind).attribute4;
                l_pty_acct_tbl(c_a_ind).attribute5  := p_ip_accounts_tbl(l_a_ind).attribute5;
                l_pty_acct_tbl(c_a_ind).attribute6  := p_ip_accounts_tbl(l_a_ind).attribute6;
                l_pty_acct_tbl(c_a_ind).attribute7  := p_ip_accounts_tbl(l_a_ind).attribute7;
                l_pty_acct_tbl(c_a_ind).attribute8  := p_ip_accounts_tbl(l_a_ind).attribute8;
                l_pty_acct_tbl(c_a_ind).attribute9  := p_ip_accounts_tbl(l_a_ind).attribute9;
                l_pty_acct_tbl(c_a_ind).attribute10 := p_ip_accounts_tbl(l_a_ind).attribute10;
                l_pty_acct_tbl(c_a_ind).attribute11 := p_ip_accounts_tbl(l_a_ind).attribute11;
                l_pty_acct_tbl(c_a_ind).attribute12 := p_ip_accounts_tbl(l_a_ind).attribute12;
                l_pty_acct_tbl(c_a_ind).attribute13 := p_ip_accounts_tbl(l_a_ind).attribute13;
                l_pty_acct_tbl(c_a_ind).attribute14 := p_ip_accounts_tbl(l_a_ind).attribute14;
                l_pty_acct_tbl(c_a_ind).attribute15 := p_ip_accounts_tbl(l_a_ind).attribute15;
                l_pty_acct_tbl(c_a_ind).object_version_number := p_ip_accounts_tbl(l_a_ind).object_version_number;
              END IF; -- if party account rec is for the parent_tbl_inde

            END LOOP; -- party account loop

          END IF; -- if party account table count > 0

        END IF; -- if party rec is for the parent_tbl_index

      END LOOP; -- parties loop

    END IF; -- if parties table count > 0

    x_parties_tbl   := l_pty_tbl;
    x_pty_accts_tbl := l_pty_acct_tbl;

  END build_parties_for_index;


  /* --------------------------------------------------------------------- */
  /* this routine builds the extended_ attribute_vals table for a specific */
  /* parent (instance). The master and the child tables are tied up using  */
  /* the parent_tbl_index column                                           */
  /* --------------------------------------------------------------------- */

  PROCEDURE build_ext_vals_for_index(
    p_instance_index      IN  binary_integer,
    p_ext_attrib_vals_tbl IN  csi_process_txn_grp.txn_ext_attrib_values_tbl,
    x_ea_values_tbl       OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_eav_tbl             csi_datastructures_pub.extend_attrib_values_tbl;
    c_ind                 binary_integer;
  BEGIN
  c_ind  :=0;

    IF p_ext_attrib_vals_tbl.COUNT > 0 THEN
      FOR l_ind IN p_ext_attrib_vals_tbl.FIRST .. p_ext_attrib_vals_tbl.LAST
      LOOP
        IF p_ext_attrib_vals_tbl(l_ind).parent_tbl_index = p_instance_index THEN

          /* debug messages */
          csi_t_gen_utility_pvt.dump_txn_eav_rec(
            p_txn_eav_rec => p_ext_attrib_vals_tbl(l_ind));

          c_ind := c_ind + 1;

          l_eav_tbl(c_ind).attribute_value_id := p_ext_attrib_vals_tbl(l_ind).attribute_value_id;
          l_eav_tbl(c_ind).instance_id  := p_ext_attrib_vals_tbl(l_ind).instance_id;
          l_eav_tbl(c_ind).attribute_id := p_ext_attrib_vals_tbl(l_ind).attribute_id;
          l_eav_tbl(c_ind).attribute_code := p_ext_attrib_vals_tbl(l_ind).attribute_code;
          l_eav_tbl(c_ind).attribute_value := p_ext_attrib_vals_tbl(l_ind).attribute_value;
          l_eav_tbl(c_ind).active_start_date := p_ext_attrib_vals_tbl(l_ind).active_start_date;
          l_eav_tbl(c_ind).active_end_date := p_ext_attrib_vals_tbl(l_ind).active_end_date;
          l_eav_tbl(c_ind).context     := p_ext_attrib_vals_tbl(l_ind).context;
          l_eav_tbl(c_ind).attribute1  := p_ext_attrib_vals_tbl(l_ind).attribute1;
          l_eav_tbl(c_ind).attribute2  := p_ext_attrib_vals_tbl(l_ind).attribute2;
          l_eav_tbl(c_ind).attribute3  := p_ext_attrib_vals_tbl(l_ind).attribute3;
          l_eav_tbl(c_ind).attribute4  := p_ext_attrib_vals_tbl(l_ind).attribute4;
          l_eav_tbl(c_ind).attribute5  := p_ext_attrib_vals_tbl(l_ind).attribute5;
          l_eav_tbl(c_ind).attribute6  := p_ext_attrib_vals_tbl(l_ind).attribute6;
          l_eav_tbl(c_ind).attribute7  := p_ext_attrib_vals_tbl(l_ind).attribute7;
          l_eav_tbl(c_ind).attribute8  := p_ext_attrib_vals_tbl(l_ind).attribute8;
          l_eav_tbl(c_ind).attribute9  := p_ext_attrib_vals_tbl(l_ind).attribute9;
          l_eav_tbl(c_ind).attribute10 := p_ext_attrib_vals_tbl(l_ind).attribute10;
          l_eav_tbl(c_ind).attribute11 := p_ext_attrib_vals_tbl(l_ind).attribute11;
          l_eav_tbl(c_ind).attribute12 := p_ext_attrib_vals_tbl(l_ind).attribute12;
          l_eav_tbl(c_ind).attribute13 := p_ext_attrib_vals_tbl(l_ind).attribute13;
          l_eav_tbl(c_ind).attribute14 := p_ext_attrib_vals_tbl(l_ind).attribute14;
          l_eav_tbl(c_ind).attribute15 := p_ext_attrib_vals_tbl(l_ind).attribute15;
          l_eav_tbl(c_ind).object_version_number := p_ext_attrib_vals_tbl(l_ind).object_version_number;

        END IF;
      END LOOP;
    END IF;

    x_ea_values_tbl := l_eav_tbl;
  END build_ext_vals_for_index;


  /* --------------------------------------------------------------------- */
  /* this routine builds the pricing_attribute_tbl table for a specific    */
  /* parent (instance). The master and the child tables are tied up using  */
  /* the parent_tbl_index column                                           */
  /* --------------------------------------------------------------------- */

  PROCEDURE build_price_tbl_for_index(
    p_instance_index      IN  binary_integer,
    p_pricing_attribs_tbl IN  csi_process_txn_grp.txn_pricing_attribs_tbl,
    x_pricing_tbl         OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_price_tbl           csi_datastructures_pub.pricing_attribs_tbl;
    c_ind                 binary_integer;
  BEGIN

    IF p_pricing_attribs_tbl.COUNT > 0 THEN
      FOR l_ind IN p_pricing_attribs_tbl.FIRST .. p_pricing_attribs_tbl.LAST
      LOOP
        IF p_pricing_attribs_tbl(l_ind).parent_tbl_index = p_instance_index THEN

          /* debug messages */
          csi_t_gen_utility_pvt.dump_txn_price_rec(
            p_txn_price_rec => p_pricing_attribs_tbl(l_ind));

          c_ind := c_ind + 1;

          l_price_tbl(c_ind).pricing_attribute_id :=  p_pricing_attribs_tbl(l_ind).pricing_attribute_id;
          l_price_tbl(c_ind).instance_id :=  p_pricing_attribs_tbl(l_ind).instance_id;
          l_price_tbl(c_ind).active_start_date :=  p_pricing_attribs_tbl(l_ind).active_start_date;
          l_price_tbl(c_ind).active_end_date :=  p_pricing_attribs_tbl(l_ind).active_end_date;
          l_price_tbl(c_ind).pricing_context :=  p_pricing_attribs_tbl(l_ind).pricing_context;
          l_price_tbl(c_ind).pricing_attribute1 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute1;
          l_price_tbl(c_ind).pricing_attribute2 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute2;
          l_price_tbl(c_ind).pricing_attribute3 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute3;
          l_price_tbl(c_ind).pricing_attribute4 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute4;
          l_price_tbl(c_ind).pricing_attribute5 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute5;
          l_price_tbl(c_ind).pricing_attribute6 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute6;
          l_price_tbl(c_ind).pricing_attribute7 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute7;
          l_price_tbl(c_ind).pricing_attribute8 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute8;
          l_price_tbl(c_ind).pricing_attribute9 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute9;
          l_price_tbl(c_ind).pricing_attribute10 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute10;
          l_price_tbl(c_ind).pricing_attribute11 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute11;
          l_price_tbl(c_ind).pricing_attribute12 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute12;
          l_price_tbl(c_ind).pricing_attribute13 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute13;
          l_price_tbl(c_ind).pricing_attribute14 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute14;
          l_price_tbl(c_ind).pricing_attribute15 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute15;
          l_price_tbl(c_ind).pricing_attribute16 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute16;
          l_price_tbl(c_ind).pricing_attribute17 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute17;
          l_price_tbl(c_ind).pricing_attribute18 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute18;
          l_price_tbl(c_ind).pricing_attribute19 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute19;
          l_price_tbl(c_ind).pricing_attribute20 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute20;
          l_price_tbl(c_ind).pricing_attribute21 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute21;
          l_price_tbl(c_ind).pricing_attribute22 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute22;
          l_price_tbl(c_ind).pricing_attribute23 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute23;
          l_price_tbl(c_ind).pricing_attribute24 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute24;
          l_price_tbl(c_ind).pricing_attribute25 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute25;
          l_price_tbl(c_ind).pricing_attribute26 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute26;
          l_price_tbl(c_ind).pricing_attribute27 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute27;
          l_price_tbl(c_ind).pricing_attribute28 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute28;
          l_price_tbl(c_ind).pricing_attribute29 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute29;
          l_price_tbl(c_ind).pricing_attribute30 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute30;
          l_price_tbl(c_ind).pricing_attribute31 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute31;
          l_price_tbl(c_ind).pricing_attribute32 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute32;
          l_price_tbl(c_ind).pricing_attribute33 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute33;
          l_price_tbl(c_ind).pricing_attribute34 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute34;
          l_price_tbl(c_ind).pricing_attribute35 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute35;
          l_price_tbl(c_ind).pricing_attribute36 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute36;
          l_price_tbl(c_ind).pricing_attribute37 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute37;
          l_price_tbl(c_ind).pricing_attribute38 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute38;
          l_price_tbl(c_ind).pricing_attribute39 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute39;
          l_price_tbl(c_ind).pricing_attribute40 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute40;
          l_price_tbl(c_ind).pricing_attribute41 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute41;
          l_price_tbl(c_ind).pricing_attribute42 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute42;
          l_price_tbl(c_ind).pricing_attribute43 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute43;
          l_price_tbl(c_ind).pricing_attribute44 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute44;
          l_price_tbl(c_ind).pricing_attribute45 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute45;
          l_price_tbl(c_ind).pricing_attribute46 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute46;
          l_price_tbl(c_ind).pricing_attribute47 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute47;
          l_price_tbl(c_ind).pricing_attribute48 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute48;
          l_price_tbl(c_ind).pricing_attribute49 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute49;
          l_price_tbl(c_ind).pricing_attribute50 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute50;
          l_price_tbl(c_ind).pricing_attribute51 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute51;
          l_price_tbl(c_ind).pricing_attribute52 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute52;
          l_price_tbl(c_ind).pricing_attribute53 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute53;
          l_price_tbl(c_ind).pricing_attribute54 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute54;
          l_price_tbl(c_ind).pricing_attribute55 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute55;
          l_price_tbl(c_ind).pricing_attribute56 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute56;
          l_price_tbl(c_ind).pricing_attribute57 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute57;
          l_price_tbl(c_ind).pricing_attribute58 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute58;
          l_price_tbl(c_ind).pricing_attribute59 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute59;
          l_price_tbl(c_ind).pricing_attribute60 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute60;
          l_price_tbl(c_ind).pricing_attribute61 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute61;
          l_price_tbl(c_ind).pricing_attribute62 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute62;
          l_price_tbl(c_ind).pricing_attribute63 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute63;
          l_price_tbl(c_ind).pricing_attribute64 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute64;
          l_price_tbl(c_ind).pricing_attribute65 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute65;
          l_price_tbl(c_ind).pricing_attribute66 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute66;
          l_price_tbl(c_ind).pricing_attribute67 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute67;
          l_price_tbl(c_ind).pricing_attribute68 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute68;
          l_price_tbl(c_ind).pricing_attribute69 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute69;
          l_price_tbl(c_ind).pricing_attribute70 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute70;
          l_price_tbl(c_ind).pricing_attribute71 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute71;
          l_price_tbl(c_ind).pricing_attribute72 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute72;
          l_price_tbl(c_ind).pricing_attribute73 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute73;
          l_price_tbl(c_ind).pricing_attribute74 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute74;
          l_price_tbl(c_ind).pricing_attribute75 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute75;
          l_price_tbl(c_ind).pricing_attribute76 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute76;
          l_price_tbl(c_ind).pricing_attribute77 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute77;
          l_price_tbl(c_ind).pricing_attribute78 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute78;
          l_price_tbl(c_ind).pricing_attribute79 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute79;
          l_price_tbl(c_ind).pricing_attribute80 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute80;
          l_price_tbl(c_ind).pricing_attribute81 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute81;
          l_price_tbl(c_ind).pricing_attribute82 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute82;
          l_price_tbl(c_ind).pricing_attribute83 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute83;
          l_price_tbl(c_ind).pricing_attribute84 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute84;
          l_price_tbl(c_ind).pricing_attribute85 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute85;
          l_price_tbl(c_ind).pricing_attribute86 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute86;
          l_price_tbl(c_ind).pricing_attribute87 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute87;
          l_price_tbl(c_ind).pricing_attribute88 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute88;
          l_price_tbl(c_ind).pricing_attribute89 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute89;
          l_price_tbl(c_ind).pricing_attribute90 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute90;
          l_price_tbl(c_ind).pricing_attribute91 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute91;
          l_price_tbl(c_ind).pricing_attribute92 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute92;
          l_price_tbl(c_ind).pricing_attribute93 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute93;
          l_price_tbl(c_ind).pricing_attribute94 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute94;
          l_price_tbl(c_ind).pricing_attribute95 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute95;
          l_price_tbl(c_ind).pricing_attribute96 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute96;
          l_price_tbl(c_ind).pricing_attribute97 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute97;
          l_price_tbl(c_ind).pricing_attribute98 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute98;
          l_price_tbl(c_ind).pricing_attribute99 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute99;
          l_price_tbl(c_ind).pricing_attribute100 :=  p_pricing_attribs_tbl(l_ind).pricing_attribute100;
          l_price_tbl(c_ind).context :=  p_pricing_attribs_tbl(l_ind).context;
          l_price_tbl(c_ind).attribute1 :=  p_pricing_attribs_tbl(l_ind).attribute1;
          l_price_tbl(c_ind).attribute2 :=  p_pricing_attribs_tbl(l_ind).attribute2;
          l_price_tbl(c_ind).attribute3 :=  p_pricing_attribs_tbl(l_ind).attribute3;
          l_price_tbl(c_ind).attribute4 :=  p_pricing_attribs_tbl(l_ind).attribute4;
          l_price_tbl(c_ind).attribute5 :=  p_pricing_attribs_tbl(l_ind).attribute5;
          l_price_tbl(c_ind).attribute6 :=  p_pricing_attribs_tbl(l_ind).attribute6;
          l_price_tbl(c_ind).attribute7 :=  p_pricing_attribs_tbl(l_ind).attribute7;
          l_price_tbl(c_ind).attribute8 :=  p_pricing_attribs_tbl(l_ind).attribute8;
          l_price_tbl(c_ind).attribute9 :=  p_pricing_attribs_tbl(l_ind).attribute9;
          l_price_tbl(c_ind).attribute10 :=  p_pricing_attribs_tbl(l_ind).attribute10;
          l_price_tbl(c_ind).attribute11 :=  p_pricing_attribs_tbl(l_ind).attribute11;
          l_price_tbl(c_ind).attribute12 :=  p_pricing_attribs_tbl(l_ind).attribute12;
          l_price_tbl(c_ind).attribute13 :=  p_pricing_attribs_tbl(l_ind).attribute13;
          l_price_tbl(c_ind).attribute14 :=  p_pricing_attribs_tbl(l_ind).attribute14;
          l_price_tbl(c_ind).attribute15 :=  p_pricing_attribs_tbl(l_ind).attribute15;
          l_price_tbl(c_ind).object_version_number :=  p_pricing_attribs_tbl(l_ind).object_version_number;

        END IF;
      END LOOP;
    END IF;

    x_pricing_tbl := l_price_tbl;

  END build_price_tbl_for_index;


  /* --------------------------------------------------------------------- */
  /* this routine builds the organization_assignments table for a specific */
  /* parent (instance). The master and the child tables are tied up using  */
  /* the parent_tbl_index column                                           */
  /* --------------------------------------------------------------------- */

  PROCEDURE build_org_units_for_index(
    p_instance_index      IN  binary_integer,
    p_org_units_tbl       IN  csi_process_txn_grp.txn_org_units_tbl,
    x_org_units_tbl       OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    c_ind          binary_integer;
    l_ou_tbl       csi_datastructures_pub.organization_units_tbl;
  BEGIN

    c_ind := 0;
    IF p_org_units_tbl.COUNT > 0 THEN
      FOR l_ind IN p_org_units_tbl.FIRST .. p_org_units_tbl.LAST
      LOOP
        IF p_org_units_tbl(l_ind).parent_tbl_index = p_instance_index THEN

          /* debug messages */
          csi_t_gen_utility_pvt.dump_txn_org_unit_rec(
            p_txn_org_unit_rec => p_org_units_tbl(l_ind));

          c_ind := c_ind + 1;

          l_ou_tbl(c_ind).instance_ou_id := p_org_units_tbl(l_ind).instance_ou_id;
          l_ou_tbl(c_ind).instance_id    := p_org_units_tbl(l_ind).instance_id;
          l_ou_tbl(c_ind).operating_unit_id := p_org_units_tbl(l_ind).operating_unit_id;
          l_ou_tbl(c_ind).relationship_type_code := p_org_units_tbl(l_ind).relationship_type_code;
          l_ou_tbl(c_ind).active_start_date := p_org_units_tbl(l_ind).active_start_date;
          l_ou_tbl(c_ind).active_end_date   := p_org_units_tbl(l_ind).active_end_date;
          l_ou_tbl(c_ind).context     := p_org_units_tbl(l_ind).context;
          l_ou_tbl(c_ind).attribute1  := p_org_units_tbl(l_ind).attribute1;
          l_ou_tbl(c_ind).attribute2  := p_org_units_tbl(l_ind).attribute2;
          l_ou_tbl(c_ind).attribute3  := p_org_units_tbl(l_ind).attribute3;
          l_ou_tbl(c_ind).attribute4  := p_org_units_tbl(l_ind).attribute4;
          l_ou_tbl(c_ind).attribute5  := p_org_units_tbl(l_ind).attribute5;
          l_ou_tbl(c_ind).attribute6  := p_org_units_tbl(l_ind).attribute6;
          l_ou_tbl(c_ind).attribute7  := p_org_units_tbl(l_ind).attribute7;
          l_ou_tbl(c_ind).attribute8  := p_org_units_tbl(l_ind).attribute8;
          l_ou_tbl(c_ind).attribute9  := p_org_units_tbl(l_ind).attribute9;
          l_ou_tbl(c_ind).attribute10 := p_org_units_tbl(l_ind).attribute10;
          l_ou_tbl(c_ind).attribute11 := p_org_units_tbl(l_ind).attribute11;
          l_ou_tbl(c_ind).attribute12 := p_org_units_tbl(l_ind).attribute12;
          l_ou_tbl(c_ind).attribute13 := p_org_units_tbl(l_ind).attribute13;
          l_ou_tbl(c_ind).attribute14 := p_org_units_tbl(l_ind).attribute14;
          l_ou_tbl(c_ind).attribute15 := p_org_units_tbl(l_ind).attribute15;
          l_ou_tbl(c_ind).object_version_number := p_org_units_tbl(l_ind).object_version_number;

        END IF;
      END LOOP;
    END IF;

    x_org_units_tbl := l_ou_tbl;

  END build_org_units_for_index;


  /* --------------------------------------------------------------------- */
  /* this routine builds the instance_assets  table for a specific         */
  /* parent (instance). The master and the child tables are tied up using  */
  /* the parent_tbl_index column                                           */
  /* --------------------------------------------------------------------- */

  PROCEDURE build_assets_for_index(
    p_instance_index      IN  binary_integer,
    p_instance_asset_tbl  IN  csi_process_txn_grp.txn_instance_asset_tbl,
    x_assets_tbl          OUT NOCOPY csi_datastructures_pub.instance_asset_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    c_ind                 binary_integer;
    l_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
  BEGIN
   debug('Just in the asset build');
    IF p_instance_asset_tbl.COUNT > 0 THEN
      FOR l_ind IN p_instance_asset_tbl.FIRST .. p_instance_asset_tbl.LAST
      LOOP
        IF p_instance_asset_tbl(l_ind).parent_tbl_index = p_instance_index THEN

          /* debug messages */
          csi_t_gen_utility_pvt.dump_txn_asset_rec(
            p_txn_asset_rec => p_instance_asset_tbl(l_ind));

          c_ind := c_ind + 1;

          l_assets_tbl(c_ind).instance_asset_id :=  p_instance_asset_tbl(l_ind).instance_asset_id;
          l_assets_tbl(c_ind).instance_id :=  p_instance_asset_tbl(l_ind).instance_id;
          l_assets_tbl(c_ind).fa_asset_id :=  p_instance_asset_tbl(l_ind).fa_asset_id;
          l_assets_tbl(c_ind).fa_book_type_code :=  p_instance_asset_tbl(l_ind).fa_book_type_code;
          l_assets_tbl(c_ind).fa_location_id :=  p_instance_asset_tbl(l_ind).fa_location_id;
          l_assets_tbl(c_ind).asset_quantity :=  p_instance_asset_tbl(l_ind).asset_quantity;
          l_assets_tbl(c_ind).update_status :=  p_instance_asset_tbl(l_ind).update_status;
          l_assets_tbl(c_ind).active_start_date :=  p_instance_asset_tbl(l_ind).active_start_date;
          l_assets_tbl(c_ind).active_end_date :=  p_instance_asset_tbl(l_ind).active_end_date;
          l_assets_tbl(c_ind).object_version_number :=  p_instance_asset_tbl(l_ind).object_version_number;

        END IF;
      END LOOP;
    END IF;

    x_assets_tbl := l_assets_tbl;

  END build_assets_for_index;

  PROCEDURE get_ids_for_instance(
    p_in_out_flag        IN     varchar2,
    p_sub_type_rec       IN     csi_txn_sub_types%rowtype,
    p_instance_rec       IN OUT NOCOPY csi_datastructures_pub.instance_rec,
    p_parties_tbl        IN OUT NOCOPY csi_datastructures_pub.party_tbl,
    p_pty_accts_tbl      IN OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    p_org_units_tbl      IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    p_ea_values_tbl      IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    p_pricing_tbl        IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    p_assets_tbl         IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS
    l_parties_tbl             csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl           csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl           csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl           csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl             csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl              csi_datastructures_pub.instance_asset_tbl;

    l_debug_level             number;
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(2000);

    l_location_type_code      varchar2(30);
    l_instance_expire_flag    boolean := FALSE;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_ids_for_instance');

    l_location_type_code := p_instance_rec.location_type_code;

    IF nvl(l_location_type_code,fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
      SELECT location_type_code
      INTO   l_location_type_code
      FROM   csi_item_instances
      WHERE  instance_id = p_instance_rec.instance_id;
    END IF;

    IF p_parties_tbl.COUNT > 0 THEN
      FOR l_ind IN p_parties_tbl.FIRST .. p_parties_tbl.LAST
      LOOP

        p_parties_tbl(l_ind).instance_id := p_instance_rec.instance_id;

        BEGIN

          IF p_parties_tbl(l_ind).relationship_type_code = 'OWNER' THEN

            SELECT instance_party_id ,
                   object_version_number
            INTO   p_parties_tbl(l_ind).instance_party_id,
                   p_parties_tbl(l_ind).object_version_number
            FROM   csi_i_parties
            WHERE  instance_id = p_instance_rec.instance_id
            AND    relationship_type_code = 'OWNER'
            AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                           AND     nvl(active_end_date, sysdate+1);

          ELSE

            p_parties_tbl(l_ind).instance_party_id     := fnd_api.g_miss_num;
            p_parties_tbl(l_ind).object_version_number := 1;

          END IF;

          debug('  Instance Party ID    :'||p_parties_tbl(l_ind).instance_party_id);
          debug('  Object Verison Num   :'||p_parties_tbl(l_ind).object_version_number);

          IF p_pty_accts_tbl.COUNT > 0 THEN
            FOR l_a_ind IN p_pty_accts_tbl.FIRST .. p_pty_accts_tbl.LAST
            LOOP

              p_pty_accts_tbl(l_a_ind).instance_party_id := p_parties_tbl(l_ind).instance_party_id;

              IF p_pty_accts_tbl(l_a_ind).relationship_type_code = 'OWNER' THEN

                BEGIN
                  SELECT ip_account_id,
                         object_version_number
                  INTO   p_pty_accts_tbl(l_a_ind).ip_account_id,
                         p_pty_accts_tbl(l_a_ind).object_version_number
                  FROM   csi_ip_accounts
                  WHERE  instance_party_id      = p_pty_accts_tbl(l_a_ind).instance_party_id
                  AND    relationship_type_code = 'OWNER'
                  AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                                 AND     nvl(active_end_date, sysdate+1);

                EXCEPTION
                  WHEN no_data_found THEN
                    p_pty_accts_tbl(l_a_ind).ip_account_id := fnd_api.g_miss_num;
                    p_pty_accts_tbl(l_a_ind).object_version_number  := 1;
                END;
              ELSE
                p_pty_accts_tbl(l_a_ind).ip_account_id := fnd_api.g_miss_num;
                p_pty_accts_tbl(l_a_ind).object_version_number  := 1;
              END IF;

              debug('  IP Account ID        :'||p_pty_accts_tbl(l_a_ind).ip_account_id);
              debug('  Object Verison Num   :'||p_pty_accts_tbl(l_a_ind).object_version_number);

            END LOOP;
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            p_parties_tbl(l_ind).instance_party_id := fnd_api.g_miss_num;
        END;

      END LOOP;
    END IF;

    IF p_org_units_tbl.COUNT > 0 THEN
      FOR l_ind IN p_org_units_tbl.FIRST .. p_org_units_tbl.LAST
      LOOP
        BEGIN
          SELECT instance_ou_id ,
                 object_version_number
          INTO   p_org_units_tbl(l_ind).instance_ou_id,
                 p_org_units_tbl(l_ind).object_version_number
          FROM   csi_i_org_assignments
          WHERE  instance_id            = p_instance_rec.instance_id
          AND    relationship_type_code = p_org_units_tbl(l_ind).relationship_type_code
          AND    operating_unit_id      = p_org_units_tbl(l_ind).operating_unit_id
          AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                         AND     nvl(active_end_date, sysdate+1);

        EXCEPTION
          WHEN no_data_found THEN
            p_org_units_tbl(l_ind).operating_unit_id     := fnd_api.g_miss_num;
            p_org_units_tbl(l_ind).object_version_number := 1;
        END;
      END LOOP;
    END IF;

    /*
    IF p_assets_tbl.COUNT > 0 THEN
      FOR l_ind IN p_assets_tbl.FIRST .. p_assets_tbl.LAST
      LOOP
        BEGIN
          SELECT instance_asset_id,
                 object_version_number
          INTO   p_assets_tbl(l_ind).instance_asset_id,
                 p_assets_tbl(l_ind).object_version_number
          FROM   csi_i_assets
          WHERE  instance_id = p_instance_rec.instance_id
          AND    fa_asset_id = p_assets_tbl(l_ind).fa_asset_id
          AND    fa_book_type_code = p_assets_tbl(l_ind).fa_book_type_code
          AND    rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            p_assets_tbl(l_ind).instance_asset_id     := fnd_api.g_miss_num;
            p_assets_tbl(l_ind).object_version_number := 1;
        END;
      END LOOP;
    END IF;
    */


    /* This logic is to de-activate all the entities when the instance switches
       to an inventory instance owned by the inventory organization
    */
    IF p_sub_type_rec.src_change_owner = 'Y'
       AND
       p_sub_type_rec.src_change_owner_to_code = 'I'
       AND
       l_location_type_code = 'INVENTORY'
    THEN

      DECLARE

        l_end_date date := sysdate;

        CURSOR exp_pty_cur IS
          SELECT instance_party_id,
                 object_version_number,
                 party_id,
                 relationship_type_code
          FROM   csi_i_parties
          WHERE  instance_id = p_instance_rec.instance_id
          AND    relationship_type_code <> 'OWNER'
          AND    contact_flag = 'N'
          AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                         AND     nvl(active_end_date, sysdate+1);
        l_np_ind   binary_integer;

        CURSOR exp_price_cur IS
          SELECT pricing_attribute_id,
                 pricing_context,
                 object_version_number
          FROM   csi_i_pricing_attribs
          WHERE  instance_id = p_instance_rec.instance_id
          AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                         AND     nvl(active_end_date, sysdate+1);
        l_npr_ind  binary_integer;

        CURSOR exp_ou_cur IS
          SELECT instance_ou_id,
                 operating_unit_id,
                 relationship_type_code,
                 object_version_number
          FROM   csi_i_org_assignments
          WHERE  instance_id = p_instance_rec.instance_id
          AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                         AND     nvl(active_end_date, sysdate+1);
        l_nou_ind  binary_integer;

      BEGIN
        /* expire all the parties other than owner */
        l_np_ind := p_parties_tbl.count;
        FOR ep_rec IN exp_pty_cur
        LOOP
          l_np_ind := l_np_ind + 1;
          p_parties_tbl(l_np_ind).instance_party_id     := ep_rec.instance_party_id;
          p_parties_tbl(l_np_ind).object_version_number := ep_rec.object_version_number;
          p_parties_tbl(l_np_ind).active_end_date       := l_end_date;
        END LOOP;

        /* expire all the pricing attribs */
        l_npr_ind := p_pricing_tbl.count;
        FOR epr_rec IN exp_price_cur
        LOOP
          l_npr_ind := l_npr_ind + 1;
          p_pricing_tbl(l_npr_ind).pricing_attribute_id := epr_rec.pricing_attribute_id;
          p_pricing_tbl(l_npr_ind).object_version_number := epr_rec.object_version_number;
          p_pricing_tbl(l_npr_ind).active_end_date := l_end_date;
        END LOOP;

        /* expire all the org assignments */
        l_nou_ind := p_org_units_tbl.count;
        FOR eou_rec IN exp_ou_cur
        LOOP
          l_nou_ind := l_nou_ind + 1;
          p_org_units_tbl(l_nou_ind).instance_ou_id := eou_rec.instance_ou_id;
          p_org_units_tbl(l_nou_ind).object_version_number := eou_rec.object_version_number;
          p_org_units_tbl(l_nou_ind).active_end_date := l_end_date;
        END LOOP;
      END;

    END IF;

  END get_ids_for_instance;


  PROCEDURE get_internal_party_tbl(
    p_instance_id           IN  number,
    p_parties_tbl           OUT NOCOPY csi_datastructures_pub.party_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS
    l_internal_party_id     number;
    l_instance_party_id     number;
    l_object_version_number number;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_internal_party_tbl');

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    SELECT instance_party_id,
           object_version_number
    INTO   l_instance_party_id,
           l_object_version_number
    FROM   csi_i_parties
    WHERE  instance_id            = p_instance_id
    AND    relationship_type_code = 'OWNER';

    p_parties_tbl(1).instance_party_id     := l_instance_party_id;
    p_parties_tbl(1).instance_id           := p_instance_id;
    p_parties_tbl(1).object_version_number := l_object_version_number;
    p_parties_tbl(1).party_id              := l_internal_party_id;
    p_parties_tbl(1).party_source_table    := 'HZ_PARTIES';
    p_parties_tbl(1).relationship_type_code:= 'OWNER';
    p_parties_tbl(1).contact_flag          := 'N';

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_internal_party_tbl;

  -- unexpire the instance
  -- code modification for 3681856;parameter added to determine whether or not to invoke contracts API
  PROCEDURE unexpire_instance(
    p_instance_id       IN  number,
    p_call_contracts    IN  varchar2 := fnd_api.g_true,
    p_transaction_rec   IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status     OUT nocopy varchar2)
  IS
    l_u_instance_rec    csi_datastructures_pub.instance_rec;
    l_u_parties_tbl     csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl   csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl   csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl      csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list csi_datastructures_pub.id_tbl;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('unexpire_instance');

    IF nvl(p_instance_id , fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      l_u_instance_rec.instance_id     := p_instance_id;
      l_u_instance_rec.active_end_date := null;
      l_u_instance_rec.call_contracts := p_call_contracts;

      SELECT object_version_number
      INTO   l_u_instance_rec.object_version_number
      FROM   csi_item_instances
      WHERE  instance_id = l_u_instance_rec.instance_id;

      csi_t_gen_utility_pvt.dump_csi_instance_rec(l_u_instance_rec);

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_item_instance_pub',
        p_api_name => 'update_item_instance');

      -- unexpire instance call.
      csi_item_instance_pub.update_item_instance(
        p_api_version           => 1.0,
        p_commit                => fnd_api.g_false,
        p_init_msg_list         => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_instance_rec          => l_u_instance_rec,
        p_party_tbl             => l_u_parties_tbl,
        p_account_tbl           => l_u_pty_accts_tbl,
        p_org_assignments_tbl   => l_u_org_units_tbl,
        p_ext_attrib_values_tbl => l_u_ea_values_tbl,
        p_pricing_attrib_tbl    => l_u_pricing_tbl,
        p_asset_assignment_tbl  => l_u_assets_tbl,
        p_txn_rec               => p_transaction_rec,
        x_instance_id_lst       => l_instance_ids_list,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

      -- For Bug 4057183
      -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END unexpire_instance;

  PROCEDURE preserve_ownership(
    p_item_attr_rec         IN     csi_process_txn_pvt.item_attr_rec,
    p_instance_rec          IN     csi_datastructures_pub.instance_rec,
    px_parties_tbl          IN OUT nocopy csi_datastructures_pub.party_tbl,
    px_pty_accts_tbl        IN OUT nocopy csi_datastructures_pub.party_account_tbl,
    x_return_status            OUT nocopy varchar2)
  IS
    l_internal_party_id     number;
    l_parties_tbl           csi_datastructures_pub.party_tbl;
    l_p_ind                 binary_integer := 0;
    l_pty_accts_tbl         csi_datastructures_pub.party_account_tbl;
    l_pa_ind                binary_integer := 0;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('preserve_ownership');

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    IF nvl(p_instance_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      IF p_item_attr_rec.src_serial_control_flag = 'Y' AND
         p_item_attr_rec.dst_serial_control_flag = 'Y'
      THEN
        -- ignore the owner
        IF px_parties_tbl.COUNT > 0 THEN
          FOR p_ind IN px_parties_tbl.FIRST .. px_parties_tbl.LAST
          LOOP
            IF px_parties_tbl(p_ind).relationship_type_code <> 'OWNER' THEN
              l_p_ind := l_p_ind + 1;
              l_parties_tbl(l_p_ind) := px_parties_tbl(p_ind);
            END IF;

            IF px_pty_accts_tbl.COUNT > 0 THEN
              FOR pa_ind IN px_pty_accts_tbl.FIRST .. px_pty_accts_tbl.LAST
             LOOP
                IF px_pty_accts_tbl(pa_ind).parent_tbl_index = p_ind THEN
                  IF  px_pty_accts_tbl(pa_ind).relationship_type_code <> 'OWNER' THEN
                    l_pa_ind := l_pa_ind + 1;
                    l_pty_accts_tbl(l_pa_ind) := px_pty_accts_tbl(pa_ind);
                    l_pty_accts_tbl(l_pa_ind).parent_tbl_index := l_p_ind;
                  END IF;
                END IF;
              END LOOP;
            END IF;
          END LOOP;

          px_parties_tbl   := l_parties_tbl;
          px_pty_accts_tbl := l_pty_accts_tbl;

        END IF;
      ELSE
        IF px_parties_tbl.COUNT > 0 THEN
          FOR p_ind IN px_parties_tbl.FIRST .. px_parties_tbl.LAST
          LOOP
            IF px_parties_tbl(p_ind).relationship_type_code = 'OWNER' THEN

              debug('switching the owner here to internal...!');
              px_parties_tbl(p_ind).party_id := l_internal_party_id;

              IF px_pty_accts_tbl.COUNT > 0 THEN
                FOR pa_ind IN px_pty_accts_tbl.FIRST .. px_pty_accts_tbl.LAST
                 LOOP
                  IF px_pty_accts_tbl(pa_ind).parent_tbl_index = p_ind THEN
                    IF  px_pty_accts_tbl(pa_ind).relationship_type_code NOT IN ('OWNER', 'SOLD_TO')
                    THEN
                      l_pa_ind := l_pa_ind + 1;
                      l_pty_accts_tbl(l_pa_ind) := px_pty_accts_tbl(pa_ind);
                    END IF;
                  END IF;
                END LOOP;
                px_pty_accts_tbl := l_pty_accts_tbl;
              END IF;
            END IF;
          END LOOP;
        END IF;
      END IF;
    ELSE
      IF px_parties_tbl.COUNT > 0 THEN
        FOR p_ind IN px_parties_tbl.FIRST .. px_parties_tbl.LAST
        LOOP
          IF px_parties_tbl(p_ind).relationship_type_code = 'OWNER' THEN

            debug('switching the owner here to internal...!');

            px_parties_tbl(p_ind).party_id := l_internal_party_id;

            IF px_pty_accts_tbl.COUNT > 0 THEN
              FOR pa_ind IN px_pty_accts_tbl.FIRST .. px_pty_accts_tbl.LAST
              LOOP
                IF px_pty_accts_tbl(pa_ind).parent_tbl_index = p_ind THEN
                  IF  px_pty_accts_tbl(pa_ind).relationship_type_code NOT IN ('OWNER', 'SOLD_TO')
                  THEN
                    l_pa_ind := l_pa_ind + 1;
                    l_pty_accts_tbl(l_pa_ind) := px_pty_accts_tbl(pa_ind);
                  END IF;
                END IF;
              END LOOP;
              px_pty_accts_tbl := l_pty_accts_tbl;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END IF;
  END preserve_ownership;

  /* -------------------------------------------------------------------- */
  /* This is the main routine that calls all the core IB APIs             */
  /* -------------------------------------------------------------------- */

  PROCEDURE process_ib(
    p_in_out_flag           IN     varchar2,
    p_sub_type_rec          IN     csi_txn_sub_types%rowtype,
    p_item_attr_rec         IN     csi_process_txn_pvt.item_attr_rec,
    p_instance_index        IN     binary_integer,
    p_dest_location_rec     IN     csi_process_txn_grp.dest_location_rec,
    p_instance_rec          IN OUT NOCOPY csi_process_txn_grp.txn_instance_rec,
    p_i_parties_tbl         IN OUT NOCOPY csi_process_txn_grp.txn_i_parties_tbl,
    p_ip_accounts_tbl       IN OUT NOCOPY csi_process_txn_grp.txn_ip_accounts_tbl,
    p_ext_attrib_vals_tbl   IN OUT NOCOPY csi_process_txn_grp.txn_ext_attrib_values_tbl,
    p_pricing_attribs_tbl   IN OUT NOCOPY csi_process_txn_grp.txn_pricing_attribs_tbl,
    p_org_units_tbl         IN OUT NOCOPY csi_process_txn_grp.txn_org_units_tbl,
    p_instance_asset_tbl    IN OUT NOCOPY csi_process_txn_grp.txn_instance_asset_tbl,
    p_transaction_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_txn_error_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status            OUT NOCOPY varchar2)

  IS

    l_process_mode            varchar2(20);

    l_transaction_rec         csi_datastructures_pub.transaction_rec;
    l_instance_rec            csi_datastructures_pub.instance_rec;
    l_parties_tbl             csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl           csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl           csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl           csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl             csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl              csi_datastructures_pub.instance_asset_tbl;
    l_systems_tbl             csi_datastructures_pub.systems_tbl;

    l_dest_instance_id        number;
    l_src_instance_id         number;
    l_returned_instance_id    number;
    l_instance_ids_list       csi_datastructures_pub.id_tbl;
    l_location_type_code      varchar2(30);
    l_instance_usage_code     varchar2(30);

    l_object_version_number   number;
    l_src_instance_qty        number;
    l_dest_instance_qty       number;
    l_serial_number           varchar2(30);
    l_mfg_serial_number_flag  varchar2(1);
    l_active_end_date         date;
    l_owner_party_account_id  number;

    l_dummy_instance_rec      csi_datastructures_pub.instance_rec;

    l_u_instance_rec          csi_datastructures_pub.instance_rec;
    l_u_parties_tbl           csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl         csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl           csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl            csi_datastructures_pub.instance_asset_tbl;
    l_u_systems_tbl           csi_datastructures_pub.systems_tbl;

    l_config_return           varchar2(1) := 'N';

    l_current_procedure       varchar2(30);
    l_debug_level             number;
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    l_debug_level   := csi_t_gen_utility_pvt.g_debug_level;

    /* debug messages */

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'process_ib');

    debug('Processing record no. '||p_instance_index||' from the instances tbl.');

    IF l_debug_level > 1 THEN

      csi_t_gen_utility_pvt.dump_txn_instance_rec(
        p_txn_instance_rec  => p_instance_rec);

      csi_t_gen_utility_pvt.dump_dest_location_rec(
        p_dest_location_rec => p_dest_location_rec);

    END IF;

    /* end debug messages */


    px_txn_error_rec.serial_number := p_instance_rec.serial_number;
    px_txn_error_rec.lot_number    := p_instance_rec.lot_number;
    px_txn_error_rec.instance_id   := p_instance_rec.instance_id;

    l_current_procedure := 'build_instance_rec';

    build_instance_rec(
      p_sub_type_rec        => p_sub_type_rec,
      p_item_attr_rec       => p_item_attr_rec,
      p_instance_rec        => p_instance_rec,
      p_dest_location_rec   => p_dest_location_rec,
      x_instance_rec        => l_instance_rec,
      x_process_mode        => l_process_mode,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_current_procedure := 'build_parties_for_index';

    debug('Processing instance p pty tbl count'|| p_i_parties_tbl.count||'p acct tbl count'||p_ip_accounts_tbl.count);

    build_parties_for_index(
      p_instance_index      => p_instance_index,
      p_i_parties_tbl       => p_i_parties_tbl,
      P_ip_accounts_tbl     => p_ip_accounts_tbl,
      x_parties_tbl         => l_parties_tbl,
      x_pty_accts_tbl       => l_pty_accts_tbl,
      x_return_status       => l_return_status);

    debug('Processing instance x pty tbl count'|| l_parties_tbl.count||'x accts tbl'||l_pty_accts_tbl.count);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_current_procedure := 'build_org_units_for_index';

    build_org_units_for_index(
      p_instance_index      => p_instance_index,
      p_org_units_tbl       => p_org_units_tbl,
      x_org_units_tbl       => l_org_units_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_current_procedure := 'build_ext_vals_for_index';

    build_ext_vals_for_index(
      p_instance_index      => p_instance_index,
      p_ext_attrib_vals_tbl => p_ext_attrib_vals_tbl,
      x_ea_values_tbl       => l_ea_values_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_current_procedure := 'build_price_tbl_for_index';

    build_price_tbl_for_index(
      p_instance_index      => p_instance_index,
      p_pricing_attribs_tbl => p_pricing_attribs_tbl,
      x_pricing_tbl         => l_pricing_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_current_procedure := 'build_assets_for_index';

    build_assets_for_index(
      p_instance_index      => p_instance_index,
      p_instance_asset_tbl  => p_instance_asset_tbl,
      x_assets_tbl          => l_assets_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_process_mode = 'CREATE' THEN

      debug('Instance marked for creation.');

      IF p_in_out_flag = 'OUT' THEN

        l_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
        l_instance_rec.location_id           := p_dest_location_rec.location_id;
 l_instance_rec.install_location_type_code    := p_dest_location_rec.location_type_code;--5086636
        l_instance_rec.install_location_id           := p_dest_location_rec.location_id; --5086636
        l_instance_rec.install_date                  := nvl(p_transaction_rec.source_transaction_date,Sysdate);--5086636
        l_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
        l_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
        l_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
        l_instance_rec.active_end_date       := null;
        l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;
        IF nvl(p_dest_location_rec.instance_usage_code, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
          l_instance_rec.instance_usage_code   := 'OUT_OF_ENTERPRISE';
        ELSE
          l_instance_rec.instance_usage_code := p_dest_location_rec.instance_usage_code;
        END IF;
        l_instance_rec.operational_status_code := p_dest_location_rec.operational_status_code;

        l_current_procedure := 'create_item_instance';

        csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

        csi_t_gen_utility_pvt.dump_api_info(
          p_pkg_name => 'csi_item_instance_pub',
          p_api_name => 'create_item_instance');

        -- create destination instance (when there is only creation of destination)
        csi_item_instance_pub.create_item_instance(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_true,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_instance_rec          => l_instance_rec,
          p_party_tbl             => l_parties_tbl,
          p_account_tbl           => l_pty_accts_tbl,
          p_org_assignments_tbl   => l_org_units_tbl,
          p_ext_attrib_values_tbl => l_ea_values_tbl,
          p_pricing_attrib_tbl    => l_pricing_tbl,
          p_asset_assignment_tbl  => l_assets_tbl,
          p_txn_rec               => p_transaction_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data );

        -- For Bug 4057183
        -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        p_instance_rec.new_instance_id := l_instance_rec.instance_id;

        debug('Instance creation successful. Instance ID: '||l_instance_rec.instance_id);

      END IF;

      IF p_in_out_flag in ('IN', 'INT') THEN

        debug('Checking if the inventory destination instance is already there.');

        /* check if a destination instance is found , if found then update
           the destination instance otherwise create
        */
        csi_process_txn_pvt.get_dest_instance_id(
          p_in_out_flag       => p_in_out_flag,
          p_sub_type_rec      => p_sub_type_rec,
          p_instance_rec      => p_instance_rec,
          p_dest_location_rec => p_dest_location_rec,
          p_item_attr_rec     => p_item_attr_rec,
          x_instance_id       => l_dest_instance_id,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('csi_process_txn_pvt.get_dest_instance_id Failed.');
          RAISE fnd_api.g_exc_error;
        END IF;

        IF nvl(l_dest_instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

          debug('Destination instance not found. So Creating one.');

          l_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
          l_instance_rec.location_id           := p_dest_location_rec.location_id;
          l_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
          l_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
          l_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
          l_instance_rec.active_end_date       := null;
          l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;
          l_instance_rec.operational_status_code := p_dest_location_rec.operational_status_code;
          l_u_instance_rec.external_reference      :=p_dest_location_rec.external_reference;


          IF l_instance_rec.location_type_code = 'INVENTORY' THEN
            l_instance_rec.instance_usage_code := 'IN_INVENTORY';
          ELSIF l_instance_rec.location_type_code = 'WIP' THEN
            l_instance_rec.instance_usage_code := 'IN_WIP';
          END IF;

         -- 4524712 viasat and xerox
          IF nvl(p_dest_location_rec.wip_job_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
            l_instance_rec.wip_job_id          := p_dest_location_rec.wip_job_id;
          END IF;

          IF p_item_attr_rec.dst_serial_control_flag = 'N' THEN
            l_instance_rec.mfg_serial_number_flag := 'N';
            l_instance_rec.serial_number          := fnd_api.g_miss_char;
          ELSE
            l_instance_rec.return_by_date      := p_instance_rec.return_by_date;
            l_instance_rec.actual_return_date  := p_instance_rec.actual_return_date;
          END IF;

          l_current_procedure := 'create_item_instance';

          csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

          csi_t_gen_utility_pvt.dump_api_info(
            p_pkg_name => 'csi_item_instance_pub',
            p_api_name => 'create_item_instance');

          csi_item_instance_pub.create_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_party_tbl             => l_parties_tbl,
            p_account_tbl           => l_pty_accts_tbl,
            p_org_assignments_tbl   => l_org_units_tbl,
            p_ext_attrib_values_tbl => l_ea_values_tbl,
            p_pricing_attrib_tbl    => l_pricing_tbl,
            p_asset_assignment_tbl  => l_assets_tbl,
            p_txn_rec               => p_transaction_rec,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data );

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          p_instance_rec.new_instance_id := l_instance_rec.instance_id;

          debug('Created Instance Susccessfully. Instance ID: '||l_instance_rec.instance_id);

        ELSE

          px_txn_error_rec.instance_id := l_dest_instance_id;

          debug('Destination Instance found. Instance ID: '||l_dest_instance_id);

          -- Call update routine.

          SELECT object_version_number,
                 quantity
          INTO   l_instance_rec.object_version_number,
                 l_dest_instance_qty
          FROM   csi_item_instances
          WHERE  instance_id = l_dest_instance_id;

          debug('Instance Quantity    :'||l_dest_instance_qty);
          debug('Transaction Quantity :'||p_instance_rec.quantity);

          l_instance_rec.instance_id           := l_dest_instance_id;

          IF p_item_attr_rec.dst_serial_control_flag = 'Y' THEN
            l_instance_rec.quantity              := 1;
            l_instance_rec.return_by_date        := p_instance_rec.return_by_date;
            l_instance_rec.actual_return_date    := p_instance_rec.actual_return_date;
          ELSE
            l_instance_rec.quantity := l_dest_instance_qty + p_instance_rec.quantity;
            IF p_dest_location_rec.location_type_code = 'INVENTORY' THEN
              l_parties_tbl.DELETE;
              l_pty_accts_tbl.DELETE;
            END IF;
          END IF;

          l_instance_rec.active_start_date     := fnd_api.g_miss_date;
          l_instance_rec.active_end_date       := null;

          get_ids_for_instance(
            p_in_out_flag        => p_in_out_flag,
            p_sub_type_rec       => p_sub_type_rec,
            p_instance_rec       => l_instance_rec,
            p_parties_tbl        => l_parties_tbl,
            p_pty_accts_tbl      => l_pty_accts_tbl,
            p_org_units_tbl      => l_org_units_tbl,
            p_ea_values_tbl      => l_ea_values_tbl,
            p_pricing_tbl        => l_pricing_tbl,
            p_assets_tbl         => l_assets_tbl,
            x_return_status      => l_return_status);

      --5086636
       IF p_sub_type_rec.src_change_owner = 'Y'
       AND
       p_sub_type_rec.src_change_owner_to_code = 'I'
      THEN
            l_instance_rec.install_location_type_code := null;
            l_instance_rec.install_location_id        := null;
            l_instance_rec.install_date               := null;

       END IF;

          l_instance_rec.location_type_code    := fnd_api.g_miss_char;
          l_instance_rec.location_id           := fnd_api.g_miss_num;
          l_instance_rec.inv_organization_id   := fnd_api.g_miss_num;
          l_instance_rec.inv_subinventory_name := fnd_api.g_miss_char;
          l_instance_rec.inv_locator_id        := fnd_api.g_miss_num;
          l_instance_rec.active_end_date       := null;
          l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;
          l_instance_rec.operational_status_code := p_dest_location_rec.operational_status_code;

          IF l_instance_rec.location_type_code = 'INVENTORY' THEN
            l_instance_rec.instance_usage_code := 'IN_INVENTORY';
          ELSIF l_instance_rec.location_type_code = 'WIP' THEN
            l_instance_rec.instance_usage_code := 'IN_WIP';
          END IF;
          IF nvl(l_instance_rec.instance_usage_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
             AND
             nvl(p_dest_location_rec.instance_usage_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
          THEN
            l_instance_rec.instance_usage_code := p_dest_location_rec.instance_usage_code;
          END IF;

          IF p_item_attr_rec.dst_serial_control_flag = 'N' THEN
            l_instance_rec.mfg_serial_number_flag := 'N';
            l_instance_rec.serial_number          := fnd_api.g_miss_char;
          END IF;

          l_current_procedure := 'update_item_instance';

          csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

          csi_t_gen_utility_pvt.dump_api_info(
             p_pkg_name => 'csi_item_instance_pub',
             p_api_name => 'update_item_instance');

          -- destination update for IN and INT
          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_party_tbl             => l_parties_tbl,
            p_account_tbl           => l_pty_accts_tbl,
            p_org_assignments_tbl   => l_org_units_tbl,
            p_ext_attrib_values_tbl => l_ea_values_tbl,
            p_pricing_attrib_tbl    => l_pricing_tbl,
            p_asset_assignment_tbl  => l_assets_tbl,
            p_txn_rec               => p_transaction_rec,
            x_instance_id_lst       => l_instance_ids_list,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('Destination Instance Updated successfully. Instance ID: '||l_dest_instance_id);

        END IF; -- instance found chk

      END IF; -- p_in_out_flag in 'IN', 'INT'

    END IF; -- l_proces_mode = 'CREATE'

    IF l_process_mode = 'UPDATE' THEN

      debug('Source Instance marked for updation.');

      IF p_item_attr_rec.src_serial_control_flag = 'Y'
         AND
         p_item_attr_rec.dst_serial_control_flag = 'Y'
      THEN

        px_txn_error_rec.instance_id := l_instance_rec.instance_id;

        debug('serialized at source and destination. so just updating the instance location.');

        /* for serialized items just go ahead and stamp the the destination
           location attributes on to the source instance . I have no idea why
           we are treating serialized items seperately then the others
        */

        -- Added as part of testing for 3810963. For RMA cancellation we need to
        -- check if the instance is expired
        SELECT active_end_date
        INTO   l_active_end_date
        FROM   csi_item_instances
        WHERE  instance_id = l_instance_rec.instance_id;

        IF p_in_out_flag <> 'NONE' THEN

          -- added this condition for RMA fulfillment because u may have a case of expiring
          -- a serialized shippable instance

          -- Stamp the destination location Attributes - BRMANESH
          l_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
          l_instance_rec.location_id           := p_dest_location_rec.location_id;
          l_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
          l_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
          l_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
          l_instance_rec.wip_job_id            := p_dest_location_rec.wip_job_id;
          l_instance_rec.last_wip_job_id       := p_dest_location_rec.last_wip_job_id; --bug 5376024
          l_instance_rec.active_end_date       := null;
          l_instance_rec.operational_status_code := p_dest_location_rec.operational_status_code;
          l_instance_rec.external_reference      :=p_dest_location_rec.external_reference;
          l_instance_rec.last_pa_project_id:=p_dest_location_rec.last_pa_project_id;
          l_instance_rec.last_pa_task_id:=p_dest_location_rec.last_pa_project_task_id;
          l_instance_rec.pa_project_id           := p_dest_location_rec.pa_project_id; --5090515
          l_instance_rec.pa_project_task_id      := p_dest_location_rec.pa_project_task_id;

          --5086636
          IF ( p_in_out_flag ='OUT' OR (p_transaction_rec.transaction_type_id in (154, 106) AND p_in_out_flag ='INT')) THEN
            -- Modified for 4926773
            l_instance_rec.install_location_type_code    := p_dest_location_rec.location_type_code;
            l_instance_rec.install_location_id           := p_dest_location_rec.location_id;
            l_instance_rec.install_date                  := nvl(p_transaction_rec.source_transaction_date,Sysdate);
          END IF;

          -- Modified for 4926773
          IF (p_transaction_rec.transaction_type_id in (110,155,107) AND  p_in_out_flag ='INT') THEN
            l_instance_rec.install_location_type_code    := NULL;
            l_instance_rec.install_location_id           := NULL;
            l_instance_rec.install_date                  := NULL;
          END IF;

          IF l_instance_rec.location_type_code = 'INVENTORY' THEN
            l_instance_rec.instance_usage_code := 'IN_INVENTORY';
          ELSIF l_instance_rec.location_type_code = 'WIP' THEN
            l_instance_rec.instance_usage_code := 'IN_WIP';
          END IF;

          -- END IF; Bug 3746600. Simplifying the Cancellation updates in Process Txn API.

          l_instance_rec.active_start_date     := fnd_api.g_miss_date;
          l_instance_rec.instance_status_id    := p_instance_rec.instance_status_id;
          l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;

          l_instance_rec.return_by_date        := p_instance_rec.return_by_date;
          l_instance_rec.actual_return_date    := p_instance_rec.actual_return_date;

          -- logic to get the instance status id
          IF nvl(p_instance_rec.instance_status_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            l_instance_rec.instance_status_id := p_sub_type_rec.src_status_id;
          END IF;

          -- bug 4285349 forward port of 4055799 moved the check and break outside the if
          -- included this call to check_and_break as part of fix for Bug : 2373109
          check_and_break_relation(
            p_instance_id   => l_instance_rec.instance_id,
            p_csi_txn_rec   => p_transaction_rec,
            x_return_status => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          /* BUG# 2177025 RMA Return not removing the INSTALL information */
          IF p_sub_type_rec.src_change_owner = 'Y'
             AND
             p_sub_type_rec.src_change_owner_to_code = 'I'
          THEN
            l_instance_rec.install_location_type_code := null;
            l_instance_rec.install_location_id        := null;
            l_instance_rec.install_date               := null;
	    l_instance_rec.external_reference         :=null;
          END IF;

        ELSE -- RMA Cancellation. Bug 3746600
          --initializing the instance rec to avoid issues. Bug 3878126
          l_instance_rec := l_dummy_instance_rec;
          l_instance_rec.instance_id    := p_instance_rec.instance_id;


          IF l_active_end_date is not null THEN
            debug('  Expired. Unexpiring to stamp rma info.');
                -- RMA Cancellation, no need to invoke contracts API, so passing false
                --code modification start for 3681856--
            unexpire_instance(
              p_instance_id      => l_instance_rec.instance_id,
              p_call_contracts   => fnd_api.g_false,
              p_transaction_rec  => p_transaction_rec,
              x_return_status    => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          l_instance_rec.instance_status_id    := p_sub_type_rec.src_status_id;
          l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;

          l_instance_rec.return_by_date        := p_instance_rec.return_by_date;
          l_instance_rec.actual_return_date    := p_instance_rec.actual_return_date;
          l_instance_rec.active_end_date       := sysdate; -- expired added for 3616051

          -- srramakr TSO with Equipment
          l_instance_rec.CONFIG_INST_HDR_ID := NULL;
          l_instance_rec.CONFIG_INST_REV_NUM := NULL;
          l_instance_rec.CONFIG_INST_ITEM_ID := NULL;
          --
        END IF;


        get_ids_for_instance(
          p_in_out_flag        => p_in_out_flag,
          p_sub_type_rec       => p_sub_type_rec,
          p_instance_rec       => l_instance_rec,
          p_parties_tbl        => l_parties_tbl,
          p_pty_accts_tbl      => l_pty_accts_tbl,
          p_org_units_tbl      => l_org_units_tbl,
          p_ea_values_tbl      => l_ea_values_tbl,
          p_pricing_tbl        => l_pricing_tbl,
          p_assets_tbl         => l_assets_tbl,
          x_return_status      => l_return_status);

        -- serialized item outbound and no change of owner
        IF p_in_out_flag = 'OUT'
           AND
           p_sub_type_rec.src_change_owner = 'N'
        THEN

          debug('serialized: out bound transaction and no change of owner');

          preserve_ownership(
            p_item_attr_rec   => p_item_attr_rec,
            p_instance_rec    => l_instance_rec,
            px_parties_tbl    => l_parties_tbl,
            px_pty_accts_tbl  => l_pty_accts_tbl,
            x_return_status   => l_return_status);

        END IF;

	IF p_sub_type_rec.src_change_owner = 'Y' AND p_sub_type_rec.src_change_owner_to_code = 'I'
	THEN
	   l_instance_rec.install_date := null;
	END IF;

        SELECT object_version_number
        INTO   l_instance_rec.object_version_number
        FROM   csi_item_instances
        WHERE  instance_id = l_instance_rec.instance_id;

        l_current_procedure := 'update_item_instance';

        csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

        csi_t_gen_utility_pvt.dump_api_info(
           p_pkg_name => 'csi_item_instance_pub',
           p_api_name => 'update_item_instance');

        -- serialized update at dest
        csi_item_instance_pub.update_item_instance(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_true,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_instance_rec          => l_instance_rec,
          p_party_tbl             => l_parties_tbl,
          p_account_tbl           => l_pty_accts_tbl,
          p_org_assignments_tbl   => l_org_units_tbl,
          p_ext_attrib_values_tbl => l_ea_values_tbl,
          p_pricing_attrib_tbl    => l_pricing_tbl,
          p_asset_assignment_tbl  => l_assets_tbl,
          p_txn_rec               => p_transaction_rec,
          x_instance_id_lst       => l_instance_ids_list,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data);

        -- For Bug 4057183
        -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('update instance successful. instance id : '||l_instance_rec.instance_id);

      ELSE -- [Non Serial Case]

        -- source inventory instance updation
        IF p_in_out_flag IN ('IN', 'INT', 'NONE') THEN
          debug('non serialized at either source or destination or both');

          IF nvl(l_instance_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

            px_txn_error_rec.instance_id := l_instance_rec.instance_id;

            SELECT quantity,
                   object_version_number,
                   serial_number,
                   nvl(mfg_serial_number_flag, 'N'),
                   active_end_date,
                   owner_party_account_id
            INTO   l_src_instance_qty,
                   l_object_version_number,
                   l_serial_number,
                   l_mfg_serial_number_flag,
                   l_active_end_date,
                   l_owner_party_account_id
            FROM   csi_item_instances
            WHERE  instance_id = l_instance_rec.instance_id;

            l_u_instance_rec.instance_id           := l_instance_rec.instance_id;
            l_u_instance_rec.object_version_number := l_object_version_number;
            l_u_instance_rec.last_oe_rma_line_id   := l_instance_rec.last_oe_rma_line_id;

            -- Bug 3746600
            IF p_in_out_flag = 'NONE' THEN -- simplifying for RMA fulfillment. bug 3746600

              IF l_active_end_date is not null THEN

                debug('expired. unexpiring to stamp rma info.');
                unexpire_instance(
                  p_instance_id      => l_u_instance_rec.instance_id,
                  p_call_contracts   => fnd_api.g_false,
                  p_transaction_rec  => p_transaction_rec,
                  x_return_status    => l_return_status);
                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

              END IF;

              l_u_instance_rec.last_oe_rma_line_id := p_instance_rec.last_oe_rma_line_id;
              l_u_instance_rec.instance_status_id  := p_sub_type_rec.src_status_id;
              l_u_instance_rec.active_end_date     := sysdate; -- expire it

            ELSE --[ != NONE ]

              IF p_item_attr_rec.src_serial_control_flag = 'Y' THEN --[SRLSOI]

                debug('serialized at so issue item. trying to update the source instance.');

                /* Included this call as part of fix for Bug : 5014633 */

                IF p_in_out_flag <> 'NONE' THEN

                  check_and_break_relation(
                    p_instance_id   => l_instance_rec.instance_id,
                    p_csi_txn_rec   => p_transaction_rec,
                    x_return_status => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;
                END IF;

                IF p_sub_type_rec.src_change_owner = 'Y'
                   AND
                   p_sub_type_rec.src_change_owner_to_code = 'I'
                THEN

                  debug('srlsoi: return for good');

                  IF l_active_end_date is not null THEN
                    debug('  source instance is expired. unexpiring to stamp rma info.');

                    unexpire_instance(
                      p_instance_id      => l_u_instance_rec.instance_id,
                      p_call_contracts   => fnd_api.g_false,
                      p_transaction_rec  => p_transaction_rec,
                      x_return_status    => l_return_status);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;

                  END IF;

                  l_u_instance_rec.active_end_date     :=
                  nvl(p_instance_rec.mtl_txn_creation_date, p_transaction_rec.source_transaction_date);
                  l_u_instance_rec.last_oe_rma_line_id := p_instance_rec.last_oe_rma_line_id;
                  l_u_instance_rec.instance_status_id  := p_sub_type_rec.src_status_id;

                  l_u_instance_rec.install_location_type_code := null;
                  l_u_instance_rec.install_location_id        := null;
                  l_u_instance_rec.install_date               := null;

                  l_u_instance_rec.instance_usage_code   := 'RETURNED';
                  l_u_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
                  l_u_instance_rec.location_id           := p_dest_location_rec.location_id;
                  l_u_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
                  l_u_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
                  l_u_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
                  l_u_instance_rec.operational_status_code:=p_dest_location_rec.operational_status_code;
                  l_u_instance_rec.external_reference      :=p_dest_location_rec.external_reference;

                  l_u_parties_tbl := l_parties_tbl;
                  IF l_u_parties_tbl.count > 0 THEN
                    FOR l_up_ind IN l_u_parties_tbl.FIRST .. l_u_parties_tbl.LAST
                    LOOP
                      l_u_parties_tbl(l_up_ind).instance_id := l_u_instance_rec.instance_id;
                      BEGIN
                        SELECT instance_party_id ,
                               object_version_number
                        INTO   l_u_parties_tbl(l_up_ind).instance_party_id,
                               l_u_parties_tbl(l_up_ind).object_version_number
                        FROM   csi_i_parties
                        WHERE  instance_id = l_u_instance_rec.instance_id
                        AND    relationship_type_code =
                               l_u_parties_tbl(l_up_ind).relationship_type_code;
                      EXCEPTION
                        WHEN no_data_found THEN
                          l_u_parties_tbl(l_up_ind).instance_party_id := fnd_api.g_miss_num;
                          l_u_parties_tbl(l_up_ind).object_version_number := 1.0;
                      END;
                    END LOOP;
                  END IF;

                ELSE

                  debug('srlsoi: return for repair');

                  l_u_instance_rec.instance_status_id  := p_sub_type_rec.src_status_id;
                  l_u_instance_rec.last_oe_rma_line_id := p_instance_rec.last_oe_rma_line_id;
                  l_u_instance_rec.instance_usage_code   := 'RETURNED';
                  l_u_instance_rec.active_end_date       := null;
                  l_u_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
                  l_u_instance_rec.location_id           := p_dest_location_rec.location_id;
                  l_u_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
                  l_u_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
                  l_u_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
                  l_u_instance_rec.operational_status_code:=p_dest_location_rec.operational_status_code;

                END IF;

                get_ids_for_instance(
                  p_in_out_flag        => p_in_out_flag,
                  p_sub_type_rec       => p_sub_type_rec,
                  p_instance_rec       => l_u_instance_rec,
                  p_parties_tbl        => l_u_parties_tbl,
                  p_pty_accts_tbl      => l_u_pty_accts_tbl,
                  p_org_units_tbl      => l_u_org_units_tbl,
                  p_ea_values_tbl      => l_u_ea_values_tbl,
                  p_pricing_tbl        => l_u_pricing_tbl,
                  p_assets_tbl         => l_u_assets_tbl,
                  x_return_status      => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

              ELSE /* this is exclusively for the non serialized source instance update */


                debug('nsrl: source update');

                /* following code specific to BUG 2304221. return of non serial config */
                IF p_sub_type_rec.transaction_type_id in (53,54) THEN

                  debug('nsrl: rma');

                  -- added for bug 3616051 to account for Non srl intermediate parent cancellations
                  /* check if the returned item is a nonserial item which has children */
                  BEGIN
                    SELECT 'Y'
                    INTO   l_config_return
                    FROM   sys.dual
                    WHERE  exists (SELECT relationship_id
                                   FROM   csi_ii_relationships
                                   WHERE  object_id = l_u_instance_rec.instance_id
                                   AND    relationship_type_code = 'COMPONENT-OF');
                  EXCEPTION
                    WHEN no_data_found THEN
                      l_config_return := 'N';
                  END;

                  IF l_config_return = 'Y' THEN

                    debug('nsrl config item. treat as srlsoi');

                    check_and_break_relation(
                      p_instance_id   => l_u_instance_rec.instance_id,
                      p_csi_txn_rec   => p_transaction_rec,
                      x_return_status => l_return_status);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    IF p_sub_type_rec.src_change_owner = 'Y'
                       AND
                       p_sub_type_rec.src_change_owner_to_code = 'I'
                    THEN

                      debug('nsrl config: return for good');

                      l_u_instance_rec.instance_status_id  := p_sub_type_rec.src_status_id;
                      l_u_instance_rec.instance_usage_code := 'RETURNED';
                      l_u_instance_rec.active_end_date     := nvl(p_instance_rec.mtl_txn_creation_date,
                                                           p_transaction_rec.source_transaction_date);

                      l_u_instance_rec.install_location_id        := null;
                      l_u_instance_rec.install_location_type_code := null;

                    ELSE

                      debug('nsrl config: return for repair');

                      /* for the return for repair case the configuration is moved to inventory
                         and the owner still is the customer, and the installed location is
                         at the customer site
                      */
                      l_u_instance_rec.instance_status_id    := p_sub_type_rec.src_status_id;
                      l_u_instance_rec.instance_usage_code   := 'RETURNED';
                      l_u_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
                      l_u_instance_rec.location_id           := p_dest_location_rec.location_id;
                      l_u_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
                      l_u_instance_rec.inv_subinventory_name :=
                                       p_dest_location_rec.inv_subinventory_name;
                      l_u_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
                    END IF;
                  ELSE
                    debug ('non serial standalone item');
                    l_u_instance_rec.quantity  := l_src_instance_qty - p_instance_rec.quantity;

                    IF l_active_end_date is not null THEN
                      debug('  Expired. Unexpiring non serial to stamp rma info.');
                      unexpire_instance(
                        p_instance_id      => l_instance_rec.instance_id,
                        p_transaction_rec  => p_transaction_rec,
                        x_return_status    => l_return_status); --4717075

                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE fnd_api.g_exc_error;
                      END IF;

                    END IF;

                  END IF;

                  l_u_instance_rec.last_oe_rma_line_id     := l_instance_rec.last_oe_rma_line_id;
                  l_u_instance_rec.last_txn_line_detail_id := l_instance_rec.last_txn_line_detail_id;

                ELSE

                  debug('nsrl: non rma - source update just decrement');

                  l_u_instance_rec.quantity           := l_src_instance_qty - p_instance_rec.quantity;
                  l_u_instance_rec.external_reference :=p_dest_location_rec.external_reference;


                  -- this condition is to drive the inv quantity negative for INT transactions
                  -- for source instance
                  IF l_src_instance_qty = 0 THEN
                    l_u_instance_rec.active_end_date    := null;
                    -- just to take out the expired status
                    l_u_instance_rec.instance_status_id := p_sub_type_rec.src_status_id;
                  END IF;

                END IF; -- diff rma and others

              END IF;

              l_u_instance_rec.instance_id := l_instance_rec.instance_id;

              IF l_u_instance_rec.quantity = 0 THEN
                l_u_instance_rec.active_end_date :=
                  nvl(p_instance_rec.mtl_txn_creation_date, p_transaction_rec.source_transaction_date);
              END IF;

            END IF;

            SELECT object_version_number
            INTO   l_object_version_number
            FROM   csi_item_instances
            WHERE  instance_id = l_u_instance_rec.instance_id;

            l_u_instance_rec.object_version_number := l_object_version_number;
            l_u_instance_rec.return_by_date        := p_instance_rec.return_by_date;
            l_u_instance_rec.actual_return_date    := p_instance_rec.actual_return_date;

            -- srramakr TSO with Equipment
            l_u_instance_rec.CONFIG_INST_HDR_ID := NULL;
            l_u_instance_rec.CONFIG_INST_REV_NUM := NULL;
            l_u_instance_rec.CONFIG_INST_ITEM_ID := NULL;

            debug('  src_inst_id  : '||l_instance_rec.instance_id);
            debug('  src_inst_ovn : '||l_object_version_number);
            debug('  src_inst_qty : '||l_src_instance_qty);
            debug('  txn_qty      : '||p_instance_rec.quantity);

            csi_t_gen_utility_pvt.dump_csi_instance_rec(l_u_instance_rec);

            l_current_procedure := 'update_item_instance';

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pub',
              p_api_name => 'update_item_instance');

            /* source instance update for srl at so issue and non serial */
            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_u_instance_rec,
              p_party_tbl             => l_u_parties_tbl,
              p_account_tbl           => l_u_pty_accts_tbl,
              p_org_assignments_tbl   => l_u_org_units_tbl,
              p_ext_attrib_values_tbl => l_u_ea_values_tbl,
              p_pricing_attrib_tbl    => l_u_pricing_tbl,
              p_asset_assignment_tbl  => l_u_assets_tbl,
              p_txn_rec               => p_transaction_rec,
              x_instance_id_lst       => l_instance_ids_list,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data);

            -- For Bug 4057183
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            debug('source instance updated successfully. instance_id :'||l_u_instance_rec.instance_id);

          END IF;

          /* code to process the destination instance */
          IF p_in_out_flag in ('IN', 'INT') THEN

            debug('figure out the inventory/wip destination instance.');

            IF p_in_out_flag in ('INT') THEN
              IF nvl(p_instance_rec.instance_status_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                l_instance_rec.instance_status_id := nvl(p_sub_type_rec.src_status_id,fnd_api.g_miss_num);
              END IF; --4619398
            END IF;

            IF (p_transaction_rec.transaction_type_id in (154, 106) AND  p_in_out_flag ='INT') THEN -- Modified for 4926773
              l_instance_rec.install_location_type_code    := p_dest_location_rec.location_type_code;
              l_instance_rec.install_location_id           := p_dest_location_rec.location_id;
              l_instance_rec.install_date                  := nvl(p_transaction_rec.source_transaction_date,Sysdate);
            END IF;

            IF (p_transaction_rec.transaction_type_id in (110, 155,107)  AND  p_in_out_flag ='INT') THEN   -- Modified for 4926773
              l_instance_rec.install_location_type_code    := NULL;
              l_instance_rec.install_location_id           := NULL;
              l_instance_rec.install_date                  := NULL;
            END IF;

            -- brmanesh r12 jun 16 06
            -- in item move transaction for non serial external owned always create a new destination instance
            -- cos you can have multiple instances and merging the contracts etc is complex
            -- complex rules engine can only resolve the destination item instance
            IF p_transaction_rec.transaction_type_id in (111,154, 155, 109)  AND l_owner_party_account_id is  not null THEN
              -- 111 - item move
              -- 154 - item install
              -- 155 - item uninstall
              -- 109 - in service
              l_dest_instance_id := fnd_api.g_miss_num;
            ELSE
              csi_process_txn_pvt.get_dest_instance_id(
                p_in_out_flag       => p_in_out_flag,
                p_sub_type_rec      => p_sub_type_rec,
                p_instance_rec      => p_instance_rec,
                p_dest_location_rec => p_dest_location_rec,
                p_item_attr_rec     => p_item_attr_rec,
                x_instance_id       => l_dest_instance_id,
                x_return_status     => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            IF nvl(l_dest_instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

              debug('destination instance could not be identified, so creating one.');

              /* if a destination instance is not found then create a new instance */

              l_instance_rec.instance_id           := fnd_api.g_miss_num;
              l_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
              l_instance_rec.location_id           := p_dest_location_rec.location_id;
              l_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
              l_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
              l_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
              l_instance_rec.active_start_date     :=nvl(p_transaction_rec.source_transaction_date,fnd_api.g_miss_date); --4620445
              l_instance_rec.active_end_date       := null;
              l_instance_rec.wip_job_id            := p_dest_location_rec.wip_job_id;
              l_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;
              l_instance_rec.operational_status_code := p_dest_location_rec.operational_status_code;
              l_instance_rec.last_pa_project_id      := p_dest_location_rec.last_pa_project_id;
              l_instance_rec.last_pa_task_id         := p_dest_location_rec.last_pa_project_task_id;
              l_instance_rec.pa_project_id           := p_dest_location_rec.pa_project_id;
              l_instance_rec.pa_project_task_id      := p_dest_location_rec.pa_project_task_id;


              IF p_item_attr_rec.dst_serial_control_flag = 'N' THEN
                l_instance_rec.mfg_serial_number_flag := 'N';
                l_instance_rec.serial_number          := fnd_api.g_miss_char;
              END IF;

              IF l_instance_rec.location_type_code = 'INVENTORY' THEN
                l_instance_rec.instance_usage_code := 'IN_INVENTORY';
              ELSIF l_instance_rec.location_type_code = 'WIP' THEN
                l_instance_rec.instance_usage_code := 'IN_WIP';
              END IF;

              IF nvl(l_instance_rec.instance_usage_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
              THEN
                l_instance_rec.instance_usage_code := p_dest_location_rec.instance_usage_code;
              END IF;

              IF l_parties_tbl.count = 0 THEN
                IF p_transaction_rec.transaction_type_id IN (106,107,108,109,110,152,154,155,111)   THEN

                  l_instance_rec.inv_organization_id   := p_instance_rec.inv_organization_id;
                  l_instance_rec.inv_subinventory_name := p_instance_rec.inv_subinventory_name;

                  l_parties_tbl(1).party_source_table      := 'HZ_PARTIES' ;
                  l_parties_tbl(1).party_id                := csi_datastructures_pub.g_install_param_rec.Internal_Party_Id;
                  l_parties_tbl(1).relationship_type_code  := 'OWNER';
                  l_parties_tbl(1).contact_flag            := 'N';
                END IF;
              END IF;

              --Bug 9301695
	      --Nullifying attribute_value_id so that it will take its value from sequence

              IF l_ea_values_tbl.Count > 0 THEN
                 FOR ea_ind IN l_ea_values_tbl.first..l_ea_values_tbl.last LOOP
                    l_ea_values_tbl(ea_ind).attribute_value_id :=  fnd_api.g_miss_num;
                 END LOOP;

              END IF;

              -- end Bug 9301695

              l_current_procedure := 'create_item_instance';

              csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_item_instance_pub',
                p_api_name => 'create_item_instance');

              /* non serial destination instance create */
              csi_item_instance_pub.create_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_instance_rec,
                p_party_tbl             => l_parties_tbl,
                p_account_tbl           => l_pty_accts_tbl,
                p_org_assignments_tbl   => l_org_units_tbl,
                p_ext_attrib_values_tbl => l_ea_values_tbl,
                p_pricing_attrib_tbl    => l_pricing_tbl,
                p_asset_assignment_tbl  => l_assets_tbl,
                p_txn_rec               => p_transaction_rec,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data );

              -- For Bug 4051783
              -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              p_instance_rec.new_instance_id := l_instance_rec.instance_id;

              debug('destination inst created successfully. Instance ID: '||l_instance_rec.instance_id);

            ELSE -- destination instance found

              debug('destination instance found. instance_id: '||l_dest_instance_id);
              px_txn_error_rec.instance_id := l_dest_instance_id;

              SELECT quantity,
                     object_version_number
              INTO   l_dest_instance_qty,
                     l_object_version_number
              FROM   csi_item_instances
              WHERE  instance_id = l_dest_instance_id;

              l_u_instance_rec := l_dummy_instance_rec;

              debug('  dest_inst_id  : '||l_dest_instance_id);
              debug('  dest_inst_ovn : '||l_object_version_number);
              debug('  dest_inst_qty : '||l_dest_instance_qty);
              debug('  txn_qty       : '||p_instance_rec.quantity);

              l_u_instance_rec.instance_id           := l_dest_instance_id;
              l_u_instance_rec.quantity              := l_dest_instance_qty + p_instance_rec.quantity;
              l_u_instance_rec.object_version_number := l_object_version_number;
              l_u_instance_rec.active_end_date       := null;
              l_u_instance_rec.last_oe_rma_line_id   := p_instance_rec.last_oe_rma_line_id;
              l_u_instance_rec.instance_usage_code   := p_dest_location_rec.instance_usage_code;
              l_u_instance_rec.operational_status_code := p_dest_location_rec.operational_status_code;
              l_u_instance_rec.last_pa_project_id:=p_dest_location_rec.last_pa_project_id;
              l_u_instance_rec.last_pa_task_id:=p_dest_location_rec.last_pa_project_task_id;


              /* for non serialized inventory destination instance at inventory
                 there is no need for passing the party and party account for updation */

              IF p_item_attr_rec.dst_serial_control_flag = 'N' THEN
                IF p_dest_location_rec.location_type_code = 'INVENTORY' THEN
                  l_parties_tbl.DELETE;
                  l_pty_accts_tbl.DELETE;
                END IF;
              END IF;

              /* this routine derived the primary key references of the child */
              /* entities like party, party account etc..                    */

              get_ids_for_instance(
                p_in_out_flag        => p_in_out_flag,
                p_sub_type_rec       => p_sub_type_rec,
                p_instance_rec       => l_u_instance_rec,
                p_parties_tbl        => l_parties_tbl,
                p_pty_accts_tbl      => l_pty_accts_tbl,
                p_org_units_tbl      => l_org_units_tbl,
                p_ea_values_tbl      => l_ea_values_tbl,
                p_pricing_tbl        => l_pricing_tbl,
                p_assets_tbl         => l_assets_tbl,
                x_return_status      => l_return_status);

              -- update item instance
              l_current_procedure := 'update_item_instance';

              csi_t_gen_utility_pvt.dump_csi_instance_rec(l_u_instance_rec);

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_item_instance_pub',
                p_api_name => 'update_item_instance');

              /* non serial destination instance update */
              csi_item_instance_pub.update_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_u_instance_rec,
                p_party_tbl             => l_parties_tbl,
                p_account_tbl           => l_pty_accts_tbl,
                p_org_assignments_tbl   => l_org_units_tbl,
                p_ext_attrib_values_tbl => l_ea_values_tbl,
                p_pricing_attrib_tbl    => l_pricing_tbl,
                p_asset_assignment_tbl  => l_assets_tbl,
                p_txn_rec               => p_transaction_rec,
                x_instance_id_lst       => l_instance_ids_list,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

              -- For Bug 4057183
              -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              p_instance_rec.new_instance_id := l_dest_instance_id;

              debug('destination instance updated successfully. instance_id: '||l_dest_instance_id);

            END IF; -- destination instance found/not [CREATE/UPDATE]

          END IF; -- IN/INT destination instance

        ELSIF p_in_out_flag = 'OUT' THEN  -- [OUT]

          debug('ship/install operation of a non serial/soi item');

          -- decrement  source instance
          csi_process_txn_pvt.get_src_instance_id(
            p_in_out_flag       => p_in_out_flag,
            p_sub_type_rec      => p_sub_type_rec,
            p_instance_rec      => p_instance_rec,
            p_dest_location_rec => p_dest_location_rec,
            p_item_attr_rec     => p_item_attr_rec,
            p_transaction_rec   => p_transaction_rec,
            x_instance_id       => l_src_instance_id,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF nvl(l_src_instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            debug('source instance not found. create one and decrement.');
            -- create a zero qty instance and decrement
            null;
          ELSE
            debug('source inventory instance found. decrement it');
            l_u_instance_rec := l_dummy_instance_rec;

            -- decrement the inv instance
            SELECT object_version_number,
                   quantity,
                   active_end_date
            INTO   l_object_version_number,
                   l_src_instance_qty,
                   l_active_end_date
            FROM   csi_item_instances
            WHERE  instance_id = l_src_instance_id;

            debug(' src_instance_id  : '||l_src_instance_id);
            debug(' quantity         : '||l_src_instance_qty);
            debug(' active_end_date  : '||l_active_end_date);
            debug(' instance_ovn     : '||l_object_version_number);

            l_u_instance_rec.instance_id           := l_src_instance_id;
            l_u_instance_rec.quantity              := l_src_instance_qty - p_instance_rec.quantity;
            l_u_instance_rec.object_version_number := l_object_version_number;

            IF l_active_end_date is not null THEN
              l_u_instance_rec.active_end_date := null;
              IF l_u_instance_rec.quantity = 0 THEN
                l_u_instance_rec.active_end_date := sysdate;
              END IF;
            END IF;

            l_u_parties_tbl.DELETE;
            l_u_pty_accts_tbl.DELETE;
            l_u_org_units_tbl.DELETE;
            l_u_ea_values_tbl.DELETE;
            l_u_pricing_tbl.DELETE;
            l_u_assets_tbl.DELETE;

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pub',
              p_api_name => 'update_item_instance');

            -- decrement inv instance for OUT transactions
            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_u_instance_rec,
              p_party_tbl             => l_u_parties_tbl,
              p_account_tbl           => l_u_pty_accts_tbl,
              p_org_assignments_tbl   => l_u_org_units_tbl,
              p_ext_attrib_values_tbl => l_u_ea_values_tbl,
              p_pricing_attrib_tbl    => l_u_pricing_tbl,
              p_asset_assignment_tbl  => l_u_assets_tbl,
              p_txn_rec               => p_transaction_rec,
              x_instance_id_lst       => l_instance_ids_list,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data);

            -- For Bug 4057183
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            debug('source instance updated successfully. instance id : '||l_u_instance_rec.instance_id);

          END IF;

          l_returned_instance_id := fnd_api.g_miss_num;

          IF p_item_attr_rec.dst_serial_control_flag = 'Y' THEN
            BEGIN
              --check for re-shipment of returned serialized instance
              SELECT instance_id,
                     object_version_number,
                     active_end_date,
                     location_type_code,
                     instance_usage_code
              INTO   l_returned_instance_id,
                     l_object_version_number,
                     l_active_end_date,
                     l_location_type_code,
                     l_instance_usage_code
              FROM   csi_item_instances
              WHERE  inventory_item_id  = l_instance_rec.inventory_item_id
              AND    serial_number      = l_instance_rec.serial_number;

              debug('returned customer product found');
              debug(' ret_instance_id     : '||l_returned_instance_id);
              debug(' active_end_date     : '||l_active_end_date);
              debug(' instance_ovn        : '||l_object_version_number);
              debug(' location_type_code  : '||l_location_type_code);
              debug(' instance_usage_code : '||l_instance_usage_code);

            EXCEPTION
              WHEN no_data_found THEN
                l_returned_instance_id := fnd_api.g_miss_num;
                l_object_version_number := 1.0;
            END;
          END IF;

          /* for sales order shipment just create another instance with the
             new party and location information
          */
          IF nvl(l_returned_instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

            l_instance_rec.instance_id           := fnd_api.g_miss_num;
            l_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
            l_instance_rec.location_id           := p_dest_location_rec.location_id;
            l_instance_rec.install_location_type_code    := p_dest_location_rec.location_type_code; --5086636
            l_instance_rec.install_location_id           := p_dest_location_rec.location_id; --5086636
            l_instance_rec.install_date                  := nvl(p_transaction_rec.source_transaction_date,Sysdate); --5086636
            l_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
            l_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
            l_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
            l_instance_rec.instance_status_id    := p_sub_type_rec.src_status_id;
            l_instance_rec.instance_usage_code   := 'OUT_OF_ENTERPRISE';

            /* create the instance for the destination location . for sales order
               shipment you do not have to cumulate the quantitites in the customers
               location. Every shipment creates one instance for the customer
            */

            IF p_sub_type_rec.src_change_owner = 'Y'
               AND
               p_sub_type_rec.src_change_owner_to_code = 'E'
            THEN
              debug('change ownership to external');
            ELSE

              debug('out bound transaction and no change of owner. preserve owner');

              preserve_ownership(
                p_item_attr_rec   => p_item_attr_rec,
                p_instance_rec    => l_instance_rec,
                px_parties_tbl    => l_parties_tbl,
                px_pty_accts_tbl  => l_pty_accts_tbl,
                x_return_status   => l_return_status);

            END IF;

            l_current_procedure := 'create_item_instance';

            csi_t_gen_utility_pvt.dump_csi_instance_rec(l_instance_rec);

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pub',
              p_api_name => 'create_item_instance');

            csi_item_instance_pub.create_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_instance_rec,
              p_party_tbl             => l_parties_tbl,
              p_account_tbl           => l_pty_accts_tbl,
              p_org_assignments_tbl   => l_org_units_tbl,
              p_ext_attrib_values_tbl => l_ea_values_tbl,
              p_pricing_attrib_tbl    => l_pricing_tbl,
              p_asset_assignment_tbl  => l_assets_tbl,
              p_txn_rec               => p_transaction_rec,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data );

            -- For Bug 4051783
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            p_instance_rec.new_instance_id := l_instance_rec.instance_id;
            debug('customer product created successfully. instance id: '||l_instance_rec.instance_id);

          ELSE

            -- update the returned instance to make it a customer product
            l_instance_rec.instance_id           := l_returned_instance_id;
            l_instance_rec.location_type_code    := p_dest_location_rec.location_type_code;
            l_instance_rec.location_id           := p_dest_location_rec.location_id;
            l_instance_rec.install_location_type_code    := p_dest_location_rec.location_type_code; --5086636
            l_instance_rec.install_location_id           := p_dest_location_rec.location_id; --5086636
            l_instance_rec.install_date                  := nvl(p_transaction_rec.source_transaction_date,Sysdate); --5086636
            l_instance_rec.inv_organization_id   := p_dest_location_rec.inv_organization_id;
            l_instance_rec.inv_subinventory_name := p_dest_location_rec.inv_subinventory_name;
            l_instance_rec.inv_locator_id        := p_dest_location_rec.inv_locator_id;
            l_instance_rec.instance_status_id    := p_sub_type_rec.src_status_id;
            l_instance_rec.instance_usage_code   := 'OUT_OF_ENTERPRISE';
            l_instance_rec.object_version_number := l_object_version_number;

            get_ids_for_instance(
              p_in_out_flag        => p_in_out_flag,
              p_sub_type_rec       => p_sub_type_rec,
              p_instance_rec       => l_instance_rec,
              p_parties_tbl        => l_parties_tbl,
              p_pty_accts_tbl      => l_pty_accts_tbl,
              p_org_units_tbl      => l_org_units_tbl,
              p_ea_values_tbl      => l_ea_values_tbl,
              p_pricing_tbl        => l_pricing_tbl,
              p_assets_tbl         => l_assets_tbl,
              x_return_status      => l_return_status);

            IF l_active_end_date is not null THEN
              l_instance_rec.active_end_date := null;
            END IF;

            IF p_sub_type_rec.src_change_owner = 'Y'
               AND
               p_sub_type_rec.src_change_owner_to_code = 'E'
            THEN
              debug('change ownership to external');
            ELSE

              debug('out bound transaction and no change of owner. preserve owner');

              preserve_ownership(
                p_item_attr_rec   => p_item_attr_rec,
                p_instance_rec    => l_instance_rec,
                px_parties_tbl    => l_parties_tbl,
                px_pty_accts_tbl  => l_pty_accts_tbl,
                x_return_status   => l_return_status);

            END IF;

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pub',
              p_api_name => 'update_item_instance');

            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_instance_rec,
              p_party_tbl             => l_parties_tbl,
              p_account_tbl           => l_pty_accts_tbl,
              p_org_assignments_tbl   => l_org_units_tbl,
              p_ext_attrib_values_tbl => l_ea_values_tbl,
              p_pricing_attrib_tbl    => l_pricing_tbl,
              p_asset_assignment_tbl  => l_assets_tbl,
              p_txn_rec               => p_transaction_rec,
              x_instance_id_lst       => l_instance_ids_list,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data);

            -- For Bug 4057183
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            debug('returned product updated successfully. instance id: '||l_instance_rec.instance_id);
            p_instance_rec.new_instance_id := l_instance_rec.instance_id;

          END IF;
        END IF; --IN INT NON versus OUT

      END IF; -- non serial case

    END IF; -- l_process_mode = 'UPDATE'

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.add_exc_msg(
        p_pkg_name       => g_pkg_name,
        p_procedure_name => l_current_procedure);

  END process_ib;

  /* ----------------------------------------------------------------------- */
  /* this routine converts the object and the subject indexes into instances */
  /* this also converts the txn relations in to csi relations so that the    */
  /* output can be passed to create relationships                            */
  /* ----------------------------------------------------------------------- */

  PROCEDURE build_ii_rltns_rec(
    p_txn_ii_rltns_rec  IN  csi_process_txn_grp.txn_ii_relationship_rec,
    p_instances_tbl     IN  csi_process_txn_grp.txn_instances_tbl,
    x_ii_rltns_rec      OUT NOCOPY csi_datastructures_pub.ii_relationship_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_ii_rltns_rec      csi_datastructures_pub.ii_relationship_rec;

    l_obj_ind           binary_integer;
    l_sub_ind           binary_integer;
    l_sub_inst_id       number;
    l_obj_inst_id       number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_obj_ind := p_txn_ii_rltns_rec.object_index;
    l_sub_ind := p_txn_ii_rltns_rec.subject_index;

    /* for source instance rec we stamp the instance on the new_instance_id    */
    /* for parent instance rec the user passes the instance on the instance_id */

    IF p_instances_tbl(l_obj_ind).ib_txn_segment_flag = 'S' THEN
      l_obj_inst_id := p_instances_tbl(l_obj_ind).new_instance_id;
    ELSE
      l_obj_inst_id := p_instances_tbl(l_obj_ind).instance_id;
    END IF;

    IF p_instances_tbl(l_sub_ind).ib_txn_segment_flag = 'S' THEN
      l_sub_inst_id := p_instances_tbl(l_sub_ind).new_instance_id;
    ELSE
      l_sub_inst_id := p_instances_tbl(l_sub_ind).instance_id;
    END IF;

    l_ii_rltns_rec.relationship_id        := p_txn_ii_rltns_rec.relationship_id;
    l_ii_rltns_rec.relationship_type_code := p_txn_ii_rltns_rec.relationship_type_code;

    l_ii_rltns_rec.object_id              := l_obj_inst_id;
    l_ii_rltns_rec.subject_id             := l_sub_inst_id;

    l_ii_rltns_rec.subject_has_child      := p_txn_ii_rltns_rec.subject_has_child;
    l_ii_rltns_rec.position_reference     := p_txn_ii_rltns_rec.position_reference;
    l_ii_rltns_rec.active_start_date      := p_txn_ii_rltns_rec.active_start_date;
    l_ii_rltns_rec.active_end_date        := p_txn_ii_rltns_rec.active_end_date;
    l_ii_rltns_rec.display_order          := p_txn_ii_rltns_rec.display_order;
    l_ii_rltns_rec.mandatory_flag         := p_txn_ii_rltns_rec.mandatory_flag;
    l_ii_rltns_rec.context                := p_txn_ii_rltns_rec.context;
    l_ii_rltns_rec.attribute1             := p_txn_ii_rltns_rec.attribute1;
    l_ii_rltns_rec.attribute2             := p_txn_ii_rltns_rec.attribute2;
    l_ii_rltns_rec.attribute3             := p_txn_ii_rltns_rec.attribute3;
    l_ii_rltns_rec.attribute4             := p_txn_ii_rltns_rec.attribute4;
    l_ii_rltns_rec.attribute5             := p_txn_ii_rltns_rec.attribute5;
    l_ii_rltns_rec.attribute6             := p_txn_ii_rltns_rec.attribute6;
    l_ii_rltns_rec.attribute7             := p_txn_ii_rltns_rec.attribute7;
    l_ii_rltns_rec.attribute8             := p_txn_ii_rltns_rec.attribute8;
    l_ii_rltns_rec.attribute9             := p_txn_ii_rltns_rec.attribute9;
    l_ii_rltns_rec.attribute10            := p_txn_ii_rltns_rec.attribute10;
    l_ii_rltns_rec.attribute11            := p_txn_ii_rltns_rec.attribute11;
    l_ii_rltns_rec.attribute12            := p_txn_ii_rltns_rec.attribute12;
    l_ii_rltns_rec.attribute13            := p_txn_ii_rltns_rec.attribute13;
    l_ii_rltns_rec.attribute14            := p_txn_ii_rltns_rec.attribute14;
    l_ii_rltns_rec.attribute15            := p_txn_ii_rltns_rec.attribute15;
    l_ii_rltns_rec.object_version_number  := p_txn_ii_rltns_rec.object_version_number;

    x_ii_rltns_rec := l_ii_rltns_rec;

    csi_t_gen_utility_pvt.dump_txn_ii_rltns_rec(
      p_txn_ii_rltns_rec  => p_txn_ii_rltns_rec);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END build_ii_rltns_rec;

  /* -------------------------------------------------------------------- */
  /* This routine converts the relations index into instances and creates */
  /* the realtion in the the Installed Base                               */
  /* -------------------------------------------------------------------- */

  PROCEDURE process_relation(
    p_instances_tbl         IN     csi_process_txn_grp.txn_instances_tbl,
    p_ii_relationships_tbl  IN     csi_process_txn_grp.txn_ii_relationships_tbl,
    p_transaction_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status            OUT NOCOPY varchar2)
  IS

    l_ii_rltns_rec          csi_datastructures_pub.ii_relationship_rec;
    l_comp_iir_tbl          csi_datastructures_pub.ii_relationship_tbl;
    l_comp_ind              binary_integer := 0;

    l_oth_iir_tbl           csi_datastructures_pub.ii_relationship_tbl;
    l_oth_ind               binary_integer := 0;

    l_current_procedure     varchar2(30);
    l_return_status         varchar2(1);
    l_msg_count             number;
    l_msg_data              varchar2(2000);


  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => 'process_relation');

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_ii_relationships_tbl.COUNT > 0 THEN
      FOR l_ind IN p_ii_relationships_tbl.FIRST .. p_ii_relationships_tbl.LAST
      LOOP

        build_ii_rltns_rec(
          p_txn_ii_rltns_rec  => p_ii_relationships_tbl(l_ind),
          p_instances_tbl     => p_instances_tbl,
          x_ii_rltns_rec      => l_ii_rltns_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_ii_rltns_rec.relationship_type_code = 'COMPONENT-OF' THEN
          l_comp_ind := l_comp_ind + 1;
          l_comp_iir_tbl(l_comp_ind) := l_ii_rltns_rec;

          debug('Subject ID :'||l_ii_rltns_rec.subject_id);
          debug('Object ID  :'||l_ii_rltns_rec.object_id);
        ELSE
          l_oth_ind := l_oth_ind + 1;
          l_oth_iir_tbl(l_comp_ind) := l_ii_rltns_rec;
        END IF;

      END LOOP;
    END IF;

    IF l_comp_iir_tbl.COUNT > 0 THEN

      csi_ii_relationships_pub.create_relationship (
        p_api_version         => 1.0,
        p_commit              => fnd_api.g_false,
        p_init_msg_list       => fnd_api.g_true,
        p_validation_level    => fnd_api.g_valid_level_full,
        p_relationship_tbl    => l_comp_iir_tbl,
        p_txn_rec             => p_transaction_rec,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF l_oth_iir_tbl.count > 0 THEN

      FOR l_o_ind IN l_oth_iir_tbl.FIRST .. l_oth_iir_tbl.LAST
      LOOP

        IF l_oth_iir_tbl(l_o_ind).relationship_type_code IN (
           'REPLACED-BY', 'REPLACEMENT-FOR', 'UPGRADED-FROM')
        THEN

          csi_utl_pkg.amend_contracts(
            p_relationship_type_code => l_oth_iir_tbl(l_o_ind).relationship_type_code,
            p_object_instance_id     => l_oth_iir_tbl(l_o_ind).object_id,
            p_subject_instance_id    => l_oth_iir_tbl(l_o_ind).subject_id,
            p_trx_rec                => p_transaction_rec,
            x_return_status          => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.add_exc_msg(
        p_pkg_name       => g_pkg_name,
        p_procedure_name => l_current_procedure);

  END process_relation;

  --Moved the check_and_break routine from RMA receipt pub to avoid circular dependancy
  --introduced in that routine for bug 2373109 and also to not load rma receipt for
  --Non RMA txns . shegde. Bug 2443204

  PROCEDURE check_and_break_relation(
    p_instance_id   in     number,
    p_csi_txn_rec   in OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status    OUT NOCOPY varchar2)
  IS
    l_relationship_query_rec csi_datastructures_pub.relationship_query_rec;
    l_relationship_tbl       csi_datastructures_pub.ii_relationship_tbl;
    l_time_stamp             date := null;

    l_exp_relationship_rec   csi_datastructures_pub.ii_relationship_rec;
    l_instance_id_lst        csi_datastructures_pub.id_tbl;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number      := 0;
    l_msg_data               varchar2(2000);
    l_instance_rev_num       NUMBER;
    l_lock_id                NUMBER;
    l_lock_status            NUMBER;
    l_locked                 BOOLEAN;
    l_unlock_inst_tbl        csi_cz_int.config_tbl;
    l_instance_inst_hdr_id   NUMBER;
    l_instance_inst_item_id  NUMBER;
    l_instance_inst_rev_num  NUMBER;
    l_locked_inst_rev_num    NUMBER;
    l_validation_status      VARCHAR2(1);
    l_instance_usage_code    VARCHAR2(30);
    l_instance_end_date      DATE;

    CURSOR exp_inst_cur(p_instance_id in number) IS
      SELECT cii.active_end_date
      FROM   csi_item_instances cii
      WHERE  cii.instance_id = p_instance_id
      AND    cii.active_end_date is not null
      AND    EXISTS (
             SELECT 'X' from csi_ii_relationships cir
             WHERE  cir.subject_id             = p_instance_id
             AND    cir.relationship_type_code = 'COMPONENT-OF'
             AND    sysdate BETWEEN nvl(cir.active_start_date, sysdate-1)
                            AND     nvl(cir.active_end_date,   sysdate+1) );
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('check_and_break_relation');

    debug('  subject instance id :'||p_instance_id);

    l_instance_inst_hdr_id := null;
    l_instance_inst_item_id := null;
    l_instance_inst_rev_num := null;
    l_locked_inst_rev_num := null;
    l_locked := FALSE;
    --
    IF nvl(p_instance_id , fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
       -- For RMA processed, need to Check for Locks on the the Item Instance and break the same.
       -- Need to notify CZ for such unlocks
       IF p_csi_txn_rec.transaction_type_id in (53,54) THEN
   l_lock_id := NULL;
   l_lock_status := NULL;
   l_instance_inst_rev_num := NULL;
   Begin
      select cil.lock_id,cil.lock_status,
      cil.config_inst_rev_num
      into l_lock_id,l_lock_status,
    l_locked_inst_rev_num
      from CSI_ITEM_INSTANCE_LOCKS cil
      where cil.instance_id = p_instance_id
      and   cil.lock_status <> 0;
             --
             l_locked := TRUE;
          Exception
             when no_data_found then
                l_locked := FALSE;
          End;
          --
          select config_inst_hdr_id,config_inst_item_id,config_inst_rev_num,
                 instance_usage_code,active_end_date
          into l_instance_inst_hdr_id,l_instance_inst_item_id,
               l_instance_inst_rev_num,l_instance_usage_code,l_instance_end_date
          from CSI_ITEM_INSTANCES
   where instance_id = p_instance_id;
          --
          IF l_locked = TRUE THEN
             debug('Instance '||p_instance_id||' is Locked. Updating TLD and Unlocking it..');
      -- Update any pending TLD for the same config keys (fetched from lock table)
      -- with the instance_id so that when regular fulfillment happens for this
      -- tangible item (DISCONNECT), only the order line_id will be updated in the item instance
             --
      Update CSI_T_TXN_LINE_DETAILS
      Set changed_instance_id = p_instance_id
         ,overriding_csi_txn_id = p_csi_txn_rec.transaction_id
      Where config_inst_hdr_id = l_instance_inst_hdr_id
      and   config_inst_item_id = l_instance_inst_item_id
      and   config_inst_rev_num = l_locked_inst_rev_num
      and   nvl(processing_status,'$#$') = 'SUBMIT';
      --
      --

      --Added for 5217556--
      IF l_lock_status = 2 THEN
         l_lock_status := 0;
      END IF;

      -- Instance is in Locked State
      l_unlock_inst_tbl.DELETE;
             l_unlock_inst_tbl(1).source_application_id := 542;
      l_unlock_inst_tbl(1).lock_id := l_lock_id;
      l_unlock_inst_tbl(1).lock_status := l_lock_status;
      l_unlock_inst_tbl(1).instance_id := p_instance_id;
      l_unlock_inst_tbl(1).source_txn_header_ref := p_csi_txn_rec.source_header_ref_id;
      l_unlock_inst_tbl(1).source_txn_line_ref1 := p_csi_txn_rec.source_line_ref_id;

      --
      debug('Calling Unlock Item Instances for Instance Id '||to_char(p_instance_id));
      CSI_ITEM_INSTANCE_GRP.unlock_item_instances
   (
     p_api_version        => 1.0
    ,p_commit             => fnd_api.g_false
    ,p_init_msg_list      => fnd_api.g_false
    ,p_validation_level   => fnd_api.g_valid_level_full
    ,p_config_tbl         => l_unlock_inst_tbl
    ,x_return_status      => l_return_status
    ,x_msg_count          => l_msg_count
    ,x_msg_data           => l_msg_data
   );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
  debug('Unlock Item Instances routine failed.');
  RAISE fnd_api.g_exc_error;
      END IF;
          END IF; -- If locked
   --
   -- Call CZ API for Notification
          IF nvl(l_instance_usage_code,'$#$') = 'IN_RELATIONSHIP' AND
             nvl(l_instance_end_date,(sysdate+1)) > sysdate AND
             l_instance_inst_hdr_id IS NOT NULL AND
             l_instance_inst_item_id IS NOT NULL AND
             l_instance_inst_rev_num IS NOT NULL THEN
             debug('Calling CZ_IB_TSO_GRP.Remove_Returned_Config_Item...');
      CZ_IB_TSO_GRP.Remove_Returned_Config_Item
  ( p_instance_hdr_id         =>  l_instance_inst_hdr_id,
    p_instance_rev_nbr        =>  l_instance_inst_rev_num,
    p_returned_config_item_id =>  l_instance_inst_item_id,
    p_locked_instance_rev_nbr =>  l_locked_inst_rev_num,
    p_application_id          =>  542,
    p_config_eff_date         =>  sysdate,
    x_validation_status       =>  l_validation_status,
    x_return_status           =>  l_return_status,
    x_msg_count               =>  l_msg_count,
    x_msg_data                =>  l_msg_data
  );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
  debug('Remove_Returned_Config_Item routine failed.');
  RAISE fnd_api.g_exc_error;
      END IF;
          END IF;
       END IF; -- Tx Type check
      --
      FOR exp_inst_rec in exp_inst_cur(p_instance_id)
      LOOP
        debug('  subject instance is expired. unexpiring..');
        --code modification for 3681856 , p_call_contracts added; here we pass the default of True
        unexpire_instance(
          p_instance_id      => p_instance_id,
          p_call_contracts   => fnd_api.g_true,
          p_transaction_rec  => p_csi_txn_rec,
          x_return_status    => l_return_status);
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        exit;
      END LOOP;

      l_relationship_query_rec.subject_id             := p_instance_id;
      l_relationship_query_rec.relationship_type_code := 'COMPONENT-OF';

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_ii_relationships_pub',
        p_api_name => 'get_relationships');

      csi_ii_relationships_pub.get_relationships(
        p_api_version               => 1.0,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_true,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_relationship_query_rec    => l_relationship_query_rec,
        p_depth                     => 1,
        p_time_stamp                => l_time_stamp,
        p_active_relationship_only  => fnd_api.g_true,
        x_relationship_tbl          => l_relationship_tbl,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      debug('  relationship table count :'||l_relationship_tbl.COUNT);

      IF l_relationship_tbl.COUNT > 0 THEN
        FOR l_ind IN l_relationship_tbl.FIRST .. l_relationship_tbl.LAST
        LOOP

          l_exp_relationship_rec.relationship_id       :=
                                 l_relationship_tbl(l_ind).relationship_id;
          l_exp_relationship_rec.object_version_number :=
                                 l_relationship_tbl(l_ind).object_version_number;

          csi_t_gen_utility_pvt.dump_api_info(
            p_pkg_name => 'csi_ii_relationships_pub',
            p_api_name => 'expire_relationship');

          debug('  relationship id :'||l_exp_relationship_rec.relationship_id);

          csi_ii_relationships_pub.expire_relationship(
            p_api_version      => 1.0,
            p_commit           => fnd_api.g_false,
            p_init_msg_list    => fnd_api.g_true,
            p_validation_level => fnd_api.g_valid_level_full,
            p_relationship_rec => l_exp_relationship_rec,
            p_txn_rec          => p_csi_txn_rec,
            x_instance_id_lst  => l_instance_id_lst,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END LOOP;
      END IF;
    END IF;

    debug('check and break relation successful.');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_and_break_relation;

END csi_process_txn_pvt;

/
