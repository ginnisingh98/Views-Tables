--------------------------------------------------------
--  DDL for Package Body CSI_WIP_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_WIP_TRXS_PKG" AS
/* $Header: csipiwpb.pls 120.21.12010000.3 2009/06/10 21:13:59 devijay ship $ */

  l_debug_level  number := fnd_profile.value('csi_debug_level');

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug_level > 0 THEN
      csi_t_gen_utility_pvt.add(p_message);
    END IF;
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2,
    p_pkg_name IN varchar2 default 'csi_wip_trxs_pkg')
  IS
  BEGIN
    IF l_debug_level > 0 THEN
      g_api_name := p_pkg_name||'.'||p_api_name;
      csi_t_gen_utility_pvt.add('Inside API : '||p_pkg_name||'.'||p_api_name);
    END IF;
  END api_log;

  PROCEDURE dump_assy_comp_relation(
    p_assy_comp_map_tbl   IN assy_comp_map_tbl)
  IS
    l_rec assy_comp_map_rec;
  BEGIN
    IF p_assy_comp_map_tbl.COUNT > 0 THEN
      debug('Assembly Instance   Component Instance  Component Quantity');
      debug('-----------------   ------------------  ------------------');
      FOR l_ind IN p_assy_comp_map_tbl.FIRST .. p_assy_comp_map_tbl.LAST
      LOOP
        l_rec := p_assy_comp_map_tbl(l_ind);
        debug(rpad(to_char(l_rec.assy_instance_id), 20, ' ')||
              rpad(to_char(l_rec.comp_instance_id), 20, ' ')||
              to_char(l_rec.comp_quantity));
      END LOOP;
    END IF;
  END dump_assy_comp_relation;

  PROCEDURE dump_mmt_tbl(
    p_mmt_tbl  IN mmt_tbl)
  IS
    l_string varchar2(240);
    l_rec mmt_rec;
  BEGIN
    IF p_mmt_tbl.count > 0 THEN

      l_string := rpad('subinventory', 20, ' ')||
                  rpad('serial_number', 20, ' ')||
                  rpad('lot_number', 12, ' ')||
                  rpad('quantity', 10, ' ')||
                  rpad('loc_id', 10, ' ');
      debug(l_string);

      l_string := rpad('------------', 20, ' ')||
                  rpad('-------------', 20, ' ')||
                  rpad('----------', 12, ' ')||
                  rpad('--------', 10, ' ')||
                  rpad('------', 10, ' ');
      debug(l_string);

      FOR l_ind IN p_mmt_tbl.FIRST .. p_mmt_tbl.LAST
      LOOP

        l_rec := p_mmt_tbl(l_ind);

        l_string := rpad(l_rec.subinventory_code, 20, ' ')||
                    rpad(nvl(l_rec.serial_number,' '), 20, ' ')||
                    rpad(nvl(l_rec.lot_number,' '), 12, ' ')||
                    rpad(l_rec.instance_quantity, 10, ' ')||
                    rpad(l_rec.locator_id, 10, ' ');
        debug(l_string);

      END LOOP;
    END IF;
  END dump_mmt_tbl;

  PROCEDURE get_mmt_info(
    p_transaction_id     IN  number,
    x_txn_ref            OUT nocopy txn_ref,
    x_mmt_tbl            OUT nocopy mmt_tbl,
    x_return_status      OUT nocopy varchar2)
  IS

    l_mmt_tbl            mmt_tbl;
    l_txn_ref            txn_ref;
    l_ind                binary_integer  := 0;

    CURSOR c_mmt IS
      SELECT mmt.creation_date               creation_date,
             mmt.transaction_id              transaction_id,
             mmt.inventory_item_id           inventory_item_id,
             mmt.organization_id             organization_id,
             mmt.subinventory_code           subinventory_code,
             mmt.revision                    revision,
             mmt.transaction_quantity        transaction_quantity,
             mmt.transaction_uom             transaction_uom,
             mmt.transaction_type_id         transaction_type_id,
             mmt.transaction_action_id       transaction_action_id,
             mmt.transaction_source_id       transaction_source_id,
             mmt.locator_id                  locator_id,
             mmt.transaction_date            transaction_date,
             mut.serial_number               serial_number,
             mtln.lot_number                 lot_number,
             msi.location_id                 subinv_location_id,
             haou.location_id                hr_location_id,
             abs(mmt.primary_quantity)       mmt_primary_quantity,
             abs(mtln.primary_quantity)      lot_primary_quantity,
             mmt.transaction_set_id          transaction_set_id --bug 5376024
      FROM   hr_all_organization_units       haou,
             mtl_transaction_lot_numbers     mtln,
             mtl_unit_transactions           mut,
             mtl_secondary_inventories       msi,
             mtl_material_transactions       mmt
      WHERE  mmt.transaction_id       = p_transaction_id
      AND    mmt.transaction_id       = mut.transaction_id(+)
      AND    mmt.transaction_id       = mtln.transaction_id(+)
      AND    mmt.subinventory_code    = msi.secondary_inventory_name
      AND    mmt.organization_id      = msi.organization_id
      AND    haou.organization_id     = mmt.organization_id;

    CURSOR c_lotsrl_mmt IS
      SELECT mmt.creation_date               creation_date,
             mmt.transaction_id              transaction_id,
             mmt.inventory_item_id           inventory_item_id,
             mmt.organization_id             organization_id,
             mmt.subinventory_code           subinventory_code,
             mmt.revision                    revision,
             mmt.transaction_quantity        transaction_quantity,
             mmt.transaction_uom             transaction_uom,
             mmt.transaction_type_id         transaction_type_id,
             mmt.transaction_action_id       transaction_action_id,
             mmt.transaction_source_id       transaction_source_id,
             mmt.locator_id                  locator_id,
             mmt.transaction_date            transaction_date,
             mut.serial_number               serial_number,
             mtln.lot_number                 lot_number,
             msi.location_id                 subinv_location_id,
             haou.location_id                hr_location_id,
             abs(mmt.primary_quantity)       mmt_primary_quantity,
             abs(mtln.primary_quantity)      lot_primary_quantity,
             mmt.transaction_set_id          transaction_set_id --bug 5376024
      FROM   hr_all_organization_units    haou,
             mtl_transaction_lot_numbers  mtln,
             mtl_unit_transactions        mut,
             mtl_secondary_inventories    msi,
             mtl_material_transactions    mmt
      WHERE  mmt.transaction_id       = p_transaction_id
      AND    mmt.subinventory_code    = msi.secondary_inventory_name
      AND    mmt.organization_id      = msi.organization_id
      AND    mtln.transaction_id      = mmt.transaction_id
      AND    mut.transaction_id       = mtln.serial_transaction_id
      AND    mmt.organization_id      = haou.organization_id;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_mmt_info');

    BEGIN

      SELECT transaction_id,
             transaction_date,
             inventory_item_id,
             organization_id,
             abs(primary_quantity),
             transaction_type_id,
             transaction_source_type_id,
             transaction_action_id,
             transaction_source_id,
             creation_date
      INTO   l_txn_ref.transaction_id,
             l_txn_ref.transaction_date,
             l_txn_ref.inventory_item_id,
             l_txn_ref.organization_id,
             l_txn_ref.primary_quantity,
             l_txn_ref.transaction_type_id,
             l_txn_ref.transaction_source_type_id,
             l_txn_ref.transaction_action_id,
             l_txn_ref.wip_entity_id,
             l_txn_ref.creation_date
      FROM   mtl_material_transactions
      WHERE  transaction_id = p_transaction_id;

      SELECT master_organization_id
      INTO   l_txn_ref.master_organization_id
      FROM   mtl_parameters
      WHERE  organization_id = l_txn_ref.organization_id;

      SELECT primary_uom_code,
             serial_number_control_code,
             lot_control_code,
             revision_qty_control_code,
             location_control_code,
             comms_nl_trackable_flag,
             bom_item_type,
             segment1,
             eam_item_type
      INTO   l_txn_ref.primary_uom_code,
             l_txn_ref.srl_control_code,
             l_txn_ref.lot_control_code,
             l_txn_ref.rev_control_code,
             l_txn_ref.loc_control_code,
             l_txn_ref.ib_trackable_flag,
             l_txn_ref.bom_item_type,
             l_txn_ref.item,
             l_txn_ref.eam_item_type
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_txn_ref.inventory_item_id
      AND    organization_id   = l_txn_ref.organization_id;

      BEGIN

        SELECT wip_entity_name,
               entity_type
        INTO   l_txn_ref.wip_entity_name,
               l_txn_ref.wip_entity_type
        FROM   wip_entities
        WHERE  wip_entity_id   = l_txn_ref.wip_entity_id
        AND    organization_id = l_txn_ref.organization_id;

        BEGIN
          IF l_txn_ref.wip_entity_type = 4 THEN  -- flow schedules
            SELECT primary_item_id,
                   quantity_completed,
                   quantity_completed,
                   status
            INTO   l_txn_ref.wip_assembly_item_id,
                   l_txn_ref.wip_start_quantity, -- wo less case compl qty is job qty
                   l_txn_ref.wip_completed_quantity,
                   l_txn_ref.wip_status_type
            FROM   wip_flow_schedules
            WHERE  wip_entity_id   = l_txn_ref.wip_entity_id
            AND    organization_id = l_txn_ref.organization_id;
          ELSE -- discrete jobs
            SELECT primary_item_id,
                   start_quantity,
                   quantity_completed,
                   job_type,
                   status_type,
                   nvl(maintenance_object_source, 0),
                   source_code,
                   source_line_id,
                   maintenance_object_type,
                   maintenance_object_id
            INTO   l_txn_ref.wip_assembly_item_id,
                   l_txn_ref.wip_start_quantity,
                   l_txn_ref.wip_completed_quantity,
                   l_txn_ref.wip_job_type,
                   l_txn_ref.wip_status_type,
                   l_txn_ref.wip_maint_source_code,
                   l_txn_ref.wip_source_code,
                   l_txn_ref.wip_source_line_id,
                   l_txn_ref.wip_maint_obj_type,
                   l_txn_ref.wip_maint_obj_id
            FROM   wip_discrete_jobs
            WHERE  wip_entity_id   = l_txn_ref.wip_entity_id
            AND    organization_id = l_txn_ref.organization_id;
          END  IF;
        EXCEPTION
          WHEN no_data_found THEN
            l_txn_ref.wip_start_quantity := 0;
        END;

      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_NO_INVENTORY_RECORDS');
        fnd_message.set_token('MTL_TRANSACTION_ID',p_transaction_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    debug('  item              : '||l_txn_ref.item);
    debug('  inventory_item_id : '||l_txn_ref.inventory_item_id);
    debug('  organization_id   : '||l_txn_ref.organization_id);
    debug('  srl_control_code  : '||l_txn_ref.srl_control_code);
    debug('  lot_control_code  : '||l_txn_ref.lot_control_code);
    debug('  rev_control_code  : '||l_txn_ref.rev_control_code);
    debug('  loc_control_code  : '||l_txn_ref.loc_control_code);
    debug('  mtl_txn_type_id   : '||l_txn_ref.transaction_type_id);
    debug('  mtl_src_type_id   : '||l_txn_ref.transaction_source_type_id);
    debug('  mtl_action_id     : '||l_txn_ref.transaction_action_id);
    debug('  mtl_txn_date      : '||l_txn_ref.transaction_date);
    debug('  primary_quantity  : '||l_txn_ref.primary_quantity);
    debug('  primary_uom       : '||l_txn_ref.primary_uom_code);
    debug('  wip_entity_name   : '||l_txn_ref.wip_entity_name);
    debug('  wip_entity_id     : '||l_txn_ref.wip_entity_id);
    debug('  wip_entity_type   : '||l_txn_ref.wip_entity_type);
    debug('  wip_status_type   : '||l_txn_ref.wip_status_type);
    debug('  assy_item_id      : '||l_txn_ref.wip_assembly_item_id);
    debug('  maint_source_code : '||l_txn_ref.wip_maint_source_code);
    debug('  job_quantity      : '||l_txn_ref.wip_start_quantity);
    debug('  completed_qty     : '||l_txn_ref.wip_completed_quantity);

    IF ((l_txn_ref.srl_control_code IN (1, 6)) AND (l_txn_ref.lot_control_code = 2))  -- Only Lot
        OR
       ((l_txn_ref.lot_control_code = 1) AND (l_txn_ref.srl_control_code <> 1)) -- Only Serial
        OR
       ((l_txn_ref.lot_control_code = 1) AND (l_txn_ref.srl_control_code = 1))  -- No Lot, No Serial
    THEN

      FOR r_mmt IN c_mmt LOOP

        l_ind := c_mmt%rowcount;

        l_mmt_tbl(l_ind).inventory_item_id        := r_mmt.inventory_item_id;
        l_mmt_tbl(l_ind).organization_id          := r_mmt.organization_id;
        l_mmt_tbl(l_ind).subinventory_code        := r_mmt.subinventory_code;
        l_mmt_tbl(l_ind).revision                 := r_mmt.revision;
        l_mmt_tbl(l_ind).transaction_source_id    := r_mmt.transaction_source_id;
        l_mmt_tbl(l_ind).transaction_quantity     := r_mmt.transaction_quantity;
        l_mmt_tbl(l_ind).transaction_uom          := r_mmt.transaction_uom;
        l_mmt_tbl(l_ind).locator_id               := r_mmt.locator_id;
        l_mmt_tbl(l_ind).transaction_date         := r_mmt.transaction_date;
        l_mmt_tbl(l_ind).serial_number            := r_mmt.serial_number;
        l_mmt_tbl(l_ind).lot_number               := r_mmt.lot_number;
        l_mmt_tbl(l_ind).subinv_location_id       := r_mmt.subinv_location_id;
        l_mmt_tbl(l_ind).hr_location_id           := r_mmt.hr_location_id;
        l_mmt_tbl(l_ind).mmt_primary_quantity     := r_mmt.mmt_primary_quantity;
        l_mmt_tbl(l_ind).lot_primary_quantity     := r_mmt.lot_primary_quantity;
        l_mmt_tbl(l_ind).transaction_set_id       := r_mmt.transaction_set_id; --bug 5376024

        IF r_mmt.serial_number IS NOT NULL THEN
          l_mmt_tbl(l_ind).instance_quantity := 1;
        ELSE
          IF r_mmt.lot_number IS NOT NULL THEN
            l_mmt_tbl(l_ind).instance_quantity := r_mmt.lot_primary_quantity;
          ELSE
            l_mmt_tbl(l_ind).instance_quantity := r_mmt.mmt_primary_quantity;
          END IF;
        END IF;

      END LOOP;

    ELSIF ((l_txn_ref.lot_control_code = 2) AND (l_txn_ref.srl_control_code <> 1)) THEN  --Lot+Srl

      FOR r_mmt IN c_lotsrl_mmt
      LOOP

        l_ind := c_lotsrl_mmt%rowcount;

        l_mmt_tbl(l_ind).inventory_item_id        := r_mmt.inventory_item_id;
        l_mmt_tbl(l_ind).organization_id          := r_mmt.organization_id;
        l_mmt_tbl(l_ind).subinventory_code        := r_mmt.subinventory_code;
        l_mmt_tbl(l_ind).revision                 := r_mmt.revision;
        l_mmt_tbl(l_ind).transaction_source_id    := r_mmt.transaction_source_id;
        l_mmt_tbl(l_ind).transaction_quantity     := r_mmt.transaction_quantity;
        l_mmt_tbl(l_ind).transaction_uom          := r_mmt.transaction_uom;
        l_mmt_tbl(l_ind).locator_id               := r_mmt.locator_id;
        l_mmt_tbl(l_ind).serial_number            := r_mmt.serial_number;
        l_mmt_tbl(l_ind).lot_number               := r_mmt.lot_number;
        l_mmt_tbl(l_ind).subinv_location_id       := r_mmt.subinv_location_id;
        l_mmt_tbl(l_ind).hr_location_id           := r_mmt.hr_location_id;
        l_mmt_tbl(l_ind).mmt_primary_quantity     := r_mmt.mmt_primary_quantity;
        l_mmt_tbl(l_ind).lot_primary_quantity     := r_mmt.lot_primary_quantity;
        l_mmt_tbl(l_ind).transaction_set_id       := r_mmt.transaction_set_id; --bug 5376024

        IF r_mmt.serial_number IS NOT NULL THEN
          l_mmt_tbl(l_ind).instance_quantity := 1;
        ELSE
          IF r_mmt.lot_number IS NOT NULL THEN
            l_mmt_tbl(l_ind).instance_quantity := r_mmt.lot_primary_quantity;
          ELSE
            l_mmt_tbl(l_ind).instance_quantity := r_mmt.mmt_primary_quantity;
          END IF;
        END IF;

      END LOOP;
    END IF;

    debug('  mmt_tbl.count     : '||l_mmt_tbl.count);

    IF l_mmt_tbl.COUNT = 0 THEN
      fnd_message.set_name('CSI','CSI_NO_INVENTORY_RECORDS');
      fnd_message.set_token('MTL_TRANSACTION_ID',p_transaction_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    dump_mmt_tbl(l_mmt_tbl);

    x_txn_ref := l_txn_ref;
    x_mmt_tbl := l_mmt_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_mmt_info;

  PROCEDURE make_non_hdr_rec(
    p_instance_hdr_rec  IN         csi_datastructures_pub.instance_header_rec,
    x_instance_rec      OUT NOCOPY csi_datastructures_pub.instance_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_instance_hdr_tbl  csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl      csi_datastructures_pub.instance_tbl;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := l_return_status;

    api_log('make_non_hdr_rec');


    l_instance_hdr_tbl(1) := p_instance_hdr_rec;

    csi_utl_pkg.make_non_header_tbl(
      p_instance_header_tbl => l_instance_hdr_tbl,
      x_instance_tbl        => l_instance_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_instance_rec := l_instance_tbl(1);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END make_non_hdr_rec;

  PROCEDURE increment_comp_instance(
    p_instance_id          IN number,
    p_quantity             IN number,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_u_instance_rec        csi_datastructures_pub.instance_rec;
    l_u_parties_tbl         csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list   csi_datastructures_pub.id_tbl;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count           number;
    l_msg_data            varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('increment_comp_instance');

    l_u_instance_rec.instance_id := p_instance_id;

    SELECT quantity + p_quantity,
           object_version_number
    INTO   l_u_instance_rec.quantity,
           l_u_instance_rec.object_version_number
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;

    api_log(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'update_item_instance');

    debug('  instance_id       : '||l_u_instance_rec.instance_id);
    debug('  quantity          : '||l_u_instance_rec.quantity);
    debug('  instance_ovn      : '||l_u_instance_rec.object_version_number);

    -- update item_instance
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
      p_txn_rec               => px_csi_txn_rec,
      x_instance_id_lst       => l_u_instance_ids_list,
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
  END increment_comp_instance;


  PROCEDURE decrement_wip_instance(
    p_instance_id          IN number,
    p_quantity             IN number,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_u_instance_rec       csi_datastructures_pub.instance_rec;
    l_u_parties_tbl        csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl      csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl      csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl        csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list  csi_datastructures_pub.id_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('decrement_wip_instance');

    l_u_instance_rec.instance_id := p_instance_id;

    SELECT quantity - p_quantity,
           object_version_number
    INTO   l_u_instance_rec.quantity,
           l_u_instance_rec.object_version_number
    FROM   csi_item_instances
    WHERE  instance_id = l_u_instance_rec.instance_id;

    api_log(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'update_item_instance');

    debug('  instance_id       : '||l_u_instance_rec.instance_id);
    debug('  quantity          : '||l_u_instance_rec.quantity);
    debug('  instance_ovn      : '||l_u_instance_rec.object_version_number);

    -- update item_instance
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
      p_txn_rec               => px_csi_txn_rec,
      x_instance_id_lst       => l_u_instance_ids_list,
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
  END decrement_wip_instance;


  PROCEDURE create_wip_instance_as(
    p_instance_id         IN     number,
    p_quantity            IN     number,
    p_organization_id     IN     number,
    x_new_instance_id        OUT NOCOPY number,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

    -- get_item_instance_details variables
    l_g_instance_rec        csi_datastructures_pub.instance_header_rec;
    l_g_ph_tbl              csi_datastructures_pub.party_header_tbl;
    l_g_pah_tbl             csi_datastructures_pub.party_account_header_tbl;
    l_g_ouh_tbl             csi_datastructures_pub.org_units_header_tbl;
    l_g_pa_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_g_eav_tbl             csi_datastructures_pub.extend_attrib_values_tbl;
    l_g_ea_tbl              csi_datastructures_pub.extend_attrib_tbl;
    l_g_iah_tbl             csi_datastructures_pub.instance_asset_header_tbl;
    l_g_time_stamp          date;

    -- make_non_hdr variables
    l_instance_rec          csi_datastructures_pub.instance_rec;

    -- create_item_instance varaibles
    l_c_instance_rec        csi_datastructures_pub.instance_rec;
    l_c_parties_tbl         csi_datastructures_pub.party_tbl;
    l_c_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_c_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_c_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_c_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_c_assets_tbl          csi_datastructures_pub.instance_asset_tbl;

    c_pa_ind                binary_integer := 0;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('create_wip_instance_as');

    l_g_instance_rec.instance_id := p_instance_id;

    api_log(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'get_item_instance_details');

    -- get the instance party and party account info
    csi_item_instance_pub.get_item_instance_details(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_g_instance_rec,
      p_get_parties           => fnd_api.g_true,
      p_party_header_tbl      => l_g_ph_tbl,
      p_get_accounts          => fnd_api.g_true,
      p_account_header_tbl    => l_g_pah_tbl,
      p_get_org_assignments   => fnd_api.g_false,
      p_org_header_tbl        => l_g_ouh_tbl,
      p_get_pricing_attribs   => fnd_api.g_false,
      p_pricing_attrib_tbl    => l_g_pa_tbl,
      p_get_ext_attribs       => fnd_api.g_false,
      p_ext_attrib_tbl        => l_g_eav_tbl,
      p_ext_attrib_def_tbl    => l_g_ea_tbl,
      p_get_asset_assignments => fnd_api.g_false,
      p_asset_header_tbl      => l_g_iah_tbl,
      p_time_stamp            => l_g_time_stamp,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    make_non_hdr_rec(
      p_instance_hdr_rec => l_g_instance_rec,
      x_instance_rec     => l_instance_rec,
      x_return_status    => l_return_status);

    debug('  instance_id       : '||l_instance_rec.instance_id);

    l_c_instance_rec := l_instance_rec;

    -- substitute create specific attributes
    l_c_instance_rec.instance_id           := fnd_api.g_miss_num;
    l_c_instance_rec.instance_number       := fnd_api.g_miss_char;
    l_c_instance_rec.object_version_number := 1.0;
    l_c_instance_rec.vld_organization_id   := p_organization_id;
    l_c_instance_rec.quantity              := p_quantity;

    debug('  new instance qty  :'||l_c_instance_rec.quantity);

    -- build party
    l_c_parties_tbl.DELETE;
    l_c_pty_accts_tbl.DELETE;

    IF l_g_ph_tbl.COUNT > 0 THEN

      FOR l_pt_ind IN l_g_ph_tbl.FIRST ..l_g_ph_tbl.LAST
      LOOP

        l_c_parties_tbl(l_pt_ind).instance_party_id  := fnd_api.g_miss_num;
        l_c_parties_tbl(l_pt_ind).instance_id        := fnd_api.g_miss_num;
        l_c_parties_tbl(l_pt_ind).party_id           := l_g_ph_tbl(l_pt_ind).party_id;
        l_c_parties_tbl(l_pt_ind).party_source_table := l_g_ph_tbl(l_pt_ind).party_source_table;
        l_c_parties_tbl(l_pt_ind).relationship_type_code :=
                             l_g_ph_tbl(l_pt_ind).relationship_type_code;
        l_c_parties_tbl(l_pt_ind).contact_flag       := 'N';

        -- build party account
        IF l_g_pah_tbl.COUNT > 0 THEN
          FOR l_pa_ind IN l_g_pah_tbl.FIRST..l_g_pah_tbl.LAST
          LOOP
            IF l_g_pah_tbl(l_pa_ind).instance_party_id = l_g_ph_tbl(l_pt_ind).instance_party_id
            THEN
              c_pa_ind := c_pa_ind + 1;
              l_c_pty_accts_tbl(c_pa_ind).parent_tbl_index   := l_pt_ind;
              l_c_pty_accts_tbl(c_pa_ind).ip_account_id      := fnd_api.g_miss_num;
              l_c_pty_accts_tbl(c_pa_ind).instance_party_id  := fnd_api.g_miss_num;
              l_c_pty_accts_tbl(c_pa_ind).party_account_id   :=
                                          l_g_pah_tbl(l_pa_ind).party_account_id;
              l_c_pty_accts_tbl(c_pa_ind).relationship_type_code :=
                                          l_g_pah_tbl(l_pa_ind).relationship_type_code;
            END IF;
          END LOOP;
        END IF;

      END LOOP;
    END IF;

    -- create a new instance for the decremented qty
    api_log(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'create_item_instance');

    csi_item_instance_pub.create_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_c_instance_rec,
      p_party_tbl             => l_c_parties_tbl,
      p_account_tbl           => l_c_pty_accts_tbl,
      p_org_assignments_tbl   => l_c_org_units_tbl,
      p_ext_attrib_values_tbl => l_c_ea_values_tbl,
      p_pricing_attrib_tbl    => l_c_pricing_tbl,
      p_asset_assignment_tbl  => l_c_assets_tbl,
      p_txn_rec               => px_csi_txn_rec,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data );

    -- For Bug 4057183
    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  new instance_id   : '||l_c_instance_rec.instance_id);

    x_new_instance_id := l_c_instance_rec.instance_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_wip_instance_as;

  PROCEDURE apportion_always(
    p_assembly_instances  IN  csi_datastructures_pub.instance_tbl,
    p_splitted_instances  IN  csi_datastructures_pub.instance_tbl,
    p_job_quantity        IN  number,
    p_comp_serial_code    IN  number,
    x_assy_comp_map_tbl   OUT NOCOPY assy_comp_map_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

   l_assy_tbl             csi_datastructures_pub.instance_tbl;
   l_issues_tbl           csi_datastructures_pub.instance_tbl;

   l_ac_mapping_tbl       assy_comp_map_tbl;
   l_ac_ind               binary_integer;
   l_remaining_quantity   number;
   l_allocated_quantity   number;
   l_reverse_ind          number;

   --Included for bug 4941800
   l_gen_child_qty        number;
   l_qty_ratio            number;

   l_genealogy_traced     boolean := FALSE;

   l_parent_object_id     number;
   l_parent_serial_number mtl_serial_numbers.serial_number%type;
   l_parent_item_id       number;
   l_c_ind                binary_integer;

   CURSOR mog_cur(p_parent_object_id IN number) IS
     SELECT msn.serial_number child_serial_number
     FROM   mtl_object_genealogy mog,
            mtl_serial_numbers   msn
     WHERE  mog.parent_object_type = 2
     AND    mog.parent_object_id   = p_parent_object_id
     AND    mog.object_type        = 2
     AND    msn.gen_object_id      = mog.object_id
     AND    sysdate BETWEEN nvl(mog.start_date_active, sysdate-1)
                    AND     nvl(mog.end_date_active,   sysdate+1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('apportion_always');

    l_issues_tbl := p_splitted_instances;
    l_assy_tbl   := p_assembly_instances;

    l_ac_ind := 0;
    --Included for bug 4941800
    BEGIN
        l_qty_ratio := l_issues_tbl.COUNT / p_job_quantity;
      EXCEPTION
        WHEN zero_divide THEN
          l_qty_ratio := 0;
          --seed message appropriately
    END;


    /* for non serialized items the instances are splitted in the
       split issued instances routine in the appropriate ratio
    */
    IF p_comp_serial_code IN (1, 6) THEN
      IF l_assy_tbl.COUNT > 0 THEN
        FOR l_a_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
        LOOP

          IF l_issues_tbl.COUNT > 0 THEN
            l_c_ind := 0;
            LOOP
              l_c_ind := l_issues_tbl.NEXT(l_c_ind);
              EXIT when l_c_ind is null;

              l_ac_ind := l_ac_ind + 1;

              l_ac_mapping_tbl(l_ac_ind).assy_instance_id :=
                                         l_assy_tbl(l_a_ind).instance_id;
              l_ac_mapping_tbl(l_ac_ind).comp_instance_id :=
                                         l_issues_tbl(l_c_ind).instance_id;
              l_ac_mapping_tbl(l_ac_ind).comp_quantity :=
                                         l_issues_tbl(l_c_ind).quantity;

              l_issues_tbl.DELETE(l_c_ind);
              EXIT;
            END LOOP;
          END IF;
        END LOOP;
      END IF;
    ELSE -- serialized case

      IF l_assy_tbl.COUNT > 0 THEN
        /* making an assumption here for serialized components the total
           issued component quantity is the count of the table */
        l_remaining_quantity := l_issues_tbl.COUNT;

        --l_reverse_ind      := l_assy_tbl.COUNT;
        l_reverse_ind        := p_job_quantity;

        -- check genealogy here if genealogy can be traced then map accordingly
        debug('Parse I - Genealogy check.');

        FOR l_a_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
        LOOP

          debug('  Parent Serial   :'||l_assy_tbl(l_a_ind).serial_number);

          BEGIN
            l_genealogy_traced := FALSE;
	    l_gen_child_qty    := 0; --fix for bug4941800

            SELECT gen_object_id
            INTO   l_parent_object_id
            FROM   mtl_serial_numbers
            WHERE  inventory_item_id = l_assy_tbl(l_a_ind).inventory_item_id
            AND    serial_number     = l_assy_tbl(l_a_ind).serial_number;

            FOR mog_rec in mog_cur (l_parent_object_id)
            LOOP

              l_genealogy_traced := TRUE;
              debug('    Child Serial(G)'||mog_rec.child_serial_number);

              IF l_issues_tbl.COUNT > 0 THEN
                l_c_ind := 0;
                LOOP

                  l_c_ind := l_issues_tbl.NEXT(l_c_ind);
                  EXIT when l_c_ind is null;

                  IF  mog_rec.child_serial_number = l_issues_tbl(l_c_ind).serial_number THEN


                    l_ac_ind := l_ac_ind + 1;
                    l_ac_mapping_tbl(l_ac_ind).assy_instance_id :=
                                         l_assy_tbl(l_a_ind).instance_id;
                    l_ac_mapping_tbl(l_ac_ind).comp_instance_id :=
                                         l_issues_tbl(l_c_ind).instance_id;
                    l_ac_mapping_tbl(l_ac_ind).comp_quantity :=
                                         l_issues_tbl(l_c_ind).quantity;
                    l_issues_tbl.DELETE(l_c_ind);
                    l_remaining_quantity := l_remaining_quantity - 1;
		    l_gen_child_qty	 := l_gen_child_qty + 1; --fix for bug4941800

                  END IF;
                END LOOP;

              END IF;

            END LOOP;
          -- exception to be handled
          END;

          /* do not get confused here. Using the processed flag in instance rec
             just to mark that genealogy is found for this assembly and skip this
             for random allocation
          */
  	  --Included for bug 4941800:processed_flag set to 'Y' only if all geneology child
	  -- specified are picked for building relationship.
          IF l_genealogy_traced AND l_gen_child_qty >= l_qty_ratio THEN
            l_assy_tbl(l_a_ind).processed_flag := 'Y';
          ELSE
            l_assy_tbl(l_a_ind).processed_flag := 'N';
          END IF;

	END LOOP;

        --for the ones that genealogy is not specified then

        debug('Parse II - Random allocation.');

        FOR l_a_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
        LOOP

          debug('  Parent Serial   :'||l_assy_tbl(l_a_ind).serial_number);

          IF nvl(l_assy_tbl(l_a_ind).processed_flag,'N') <> 'Y' THEN

            IF l_issues_tbl.COUNT > 0 THEN

              l_allocated_quantity := CEIL(l_remaining_quantity/l_reverse_ind);
              l_reverse_ind        := l_reverse_ind - 1;
              l_remaining_quantity := l_remaining_quantity - l_allocated_quantity;

              l_c_ind := 0;
              LOOP
                l_c_ind := l_issues_tbl.NEXT(l_c_ind);
                EXIT when l_c_ind is null;

                l_ac_ind := l_ac_ind + 1;

                l_ac_mapping_tbl(l_ac_ind).assy_instance_id :=
                                         l_assy_tbl(l_a_ind).instance_id;
                l_ac_mapping_tbl(l_ac_ind).comp_instance_id :=
                                         l_issues_tbl(l_c_ind).instance_id;
                l_ac_mapping_tbl(l_ac_ind).comp_quantity :=
                                         l_issues_tbl(l_c_ind).quantity;

                debug('    Child Serial  :'||l_issues_tbl(l_c_ind).serial_number);

                l_issues_tbl.DELETE(l_c_ind);
                l_allocated_quantity := l_allocated_quantity - 1;
                IF l_allocated_quantity = 0 THEN
                  EXIT;
                END IF;
              END LOOP;
            END IF;
          END IF;

        END LOOP; --assy table loop;
      END IF; -- assy table count > 0
    END IF; -- serial check

    x_assy_comp_map_tbl := l_ac_mapping_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END apportion_always;


  /* this routine gets the instances created for the asssembly completion instances
     and are in inventory location . Just created instances before they move to another
     location like WIP or customer location
  */

  PROCEDURE get_assembly_instances(
    p_wip_entity_id       IN  number,
    p_organization_id     IN  number,
    p_assembly_item_id    IN  number,
    p_completion_quantity IN  number,
    p_location_code       IN  varchar2,
    x_instance_tbl        OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    --l_inventory_item_id     wip_discrete_jobs.primary_item_id%TYPE;
    l_completion_quantity   number;
    l_relation_found        varchar2(1) := 'N';

    -- get_item_instances variables
    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    --
    l_instance_hdr_tbl      csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl          csi_datastructures_pub.instance_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_assembly_instances');

    l_completion_quantity  := p_completion_quantity;

    -- instance query parameters

    l_inst_query_rec.inventory_item_id   := p_assembly_item_id;
    l_inst_query_rec.last_wip_job_id     := p_wip_entity_id;

    -- qeury by last_vld_organization_id is appropriate
    -- but since there is no column in instance_query_record

    IF p_location_code = 'INVENTORY' THEN
      l_inst_query_rec.location_type_code  := 'INVENTORY';
      l_inst_query_rec.instance_usage_code := 'IN_INVENTORY';
      l_inst_query_rec.inv_organization_id := p_organization_id;
    END IF;

    csi_t_gen_utility_pvt.dump_instance_query_rec(l_inst_query_rec);

    api_log(
      p_api_name => 'get_item_instances',
      p_pkg_name => 'csi_item_instance_pub');

    csi_item_instance_pub.get_item_instances(
      p_api_version          =>  1.0,
      p_commit               =>  fnd_api.g_false,
      p_init_msg_list        =>  fnd_api.g_true,
      p_validation_level     =>  fnd_api.g_valid_level_full,
      p_instance_query_rec   =>  l_inst_query_rec,
      p_party_query_rec      =>  l_party_query_rec,
      p_account_query_rec    =>  l_pty_acct_query_rec,
      p_transaction_id       =>  null,
      p_resolve_id_columns   =>  fnd_api.g_false,
      p_active_instance_only =>  fnd_api.g_true,
      x_instance_header_tbl  =>  l_instance_hdr_tbl,
      x_return_status        =>  l_return_status,
      x_msg_count            =>  l_msg_count,
      x_msg_data             =>  l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('Assembly instances count :'||l_instance_hdr_tbl.COUNT);

    IF l_instance_hdr_tbl.COUNT > 0 THEN

      csi_utl_pkg.make_non_header_tbl(
        p_instance_header_tbl => l_instance_hdr_tbl,
        x_instance_tbl        => l_instance_tbl,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    x_instance_tbl := l_instance_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END get_assembly_instances;

  PROCEDURE get_qty_per_assembly(
    p_organization_id      IN number,
    p_wip_entity_id        IN number,
    p_component_item_id    IN number,
    x_qty_per_assembly     OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2)
  IS
    l_qty_per_assy  number;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_qty_per_assembly');

    SELECT sum(nvl(quantity_per_assembly,0))
    INTO   l_qty_per_assy
    FROM   wip_requirement_operations
    WHERE  organization_id   = p_organization_id
    AND    wip_entity_id     = p_wip_entity_id
    AND    inventory_item_id = p_component_item_id;

    debug('  qty_per_assy :'||l_qty_per_assy);

    x_qty_per_assembly := abs(l_qty_per_assy);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_qty_per_assembly;

  PROCEDURE get_issued_requirements (
    p_wip_entity_id    IN  number,
    p_organization_id  IN  number,
    p_assembly_item_id IN  number,
    p_auto_allocate    IN  varchar2,
    x_requirements_tbl OUT NOCOPY requirements_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS

    CURSOR wro_cur_all IS
      SELECT wip.inventory_item_id,
             sum(required_quantity)     qty_required,
             sum(quantity_issued)       qty_issued,
             nvl(sum(nvl(quantity_per_assembly,0)),0) qty_per_assy
      FROM   wip_requirement_operations wip, mtl_system_items msi
      WHERE  wip.wip_entity_id         = p_wip_entity_id
      AND    wip.organization_id   = p_organization_id
      AND    wip.inventory_item_id <> p_assembly_item_id
      AND    wip.inventory_item_id = msi.inventory_item_id
      AND    wip.organization_id   = msi.organization_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y'
      AND    (nvl(quantity_issued,0) > 0
              OR
              EXISTS (
                SELECT 'X' FROM mtl_material_transactions mmt
                WHERE  mmt.transaction_action_id      in (1,34)
                AND    mmt.transaction_source_type_id = 5
                AND    mmt.transaction_source_id      = wip.wip_entity_id
                AND    mmt.inventory_item_id          = wip.inventory_item_id))
      GROUP BY wip.inventory_item_id;

    CURSOR wro_cur_required IS
      SELECT wip.inventory_item_id,
             sum(required_quantity)     qty_required,
             sum(quantity_issued)       qty_issued,
             nvl(sum(nvl(quantity_per_assembly,0)),0) qty_per_assy
      FROM   wip_requirement_operations wip, mtl_system_items msi
      WHERE  wip.wip_entity_id         = p_wip_entity_id
      AND    wip.organization_id   = p_organization_id
      AND    wip.inventory_item_id <> p_assembly_item_id
      AND    wip.inventory_item_id = msi.inventory_item_id
      AND    wip.organization_id   = msi.organization_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y'
      AND    nvl(quantity_per_assembly, 0) > 0
      AND    (nvl(quantity_issued,0) > 0
              OR
              EXISTS (
                SELECT 'X' FROM mtl_material_transactions mmt
                WHERE  mmt.transaction_action_id      in (1,34)
                AND    mmt.transaction_source_type_id = 5
                AND    mmt.transaction_source_id      = wip.wip_entity_id
                AND    mmt.inventory_item_id          = wip.inventory_item_id))
      GROUP BY wip.inventory_item_id;

    l_job_quantity         number;
    l_requirements_tbl     requirements_tbl;
    l_ind                  binary_integer;
    l_qty_per_assy         number;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_issued_requirements');

    BEGIN
      SELECT start_quantity
      INTO   l_job_quantity
      FROM   wip_discrete_jobs
      WHERE  wip_entity_id   = p_wip_entity_id
      AND    organization_id = p_organization_id;
    EXCEPTION
      WHEN no_data_found THEN
        l_job_quantity := 0;
    END;

    IF p_auto_allocate = 'Y' OR l_job_quantity = 1 THEN

      FOR req_rec IN wro_cur_all
      LOOP

        l_ind := wro_cur_all%ROWCOUNT;

        l_requirements_tbl(l_ind).wip_entity_id     := p_wip_entity_id;
        l_requirements_tbl(l_ind).organization_id   := p_organization_id;
        l_requirements_tbl(l_ind).inventory_item_id := req_rec.inventory_item_id;
        l_requirements_tbl(l_ind).required_quantity := req_rec.qty_required;
        l_requirements_tbl(l_ind).issued_quantity   := req_rec.qty_issued;
        l_requirements_tbl(l_ind).quantity_per_assy := req_rec.qty_per_assy;

        IF l_requirements_tbl(l_ind).issued_quantity = 0 THEN
          SELECT sum(nvl(abs(transaction_quantity),0))
          INTO   l_requirements_tbl(l_ind).issued_quantity
          FROM   mtl_material_transactions mmt
          WHERE  mmt.transaction_action_id      in (1,34)
          AND    mmt.transaction_source_type_id = 5
          AND    mmt.inventory_item_id          = l_requirements_tbl(l_ind).inventory_item_id
          AND    mmt.transaction_source_id      = p_wip_entity_id;
        END IF;
      END LOOP;

    ELSE

      debug('  Restricted Mode Requirements..');

      FOR req_rec IN wro_cur_required
      LOOP

        l_ind := wro_cur_required%ROWCOUNT;

        l_requirements_tbl(l_ind).wip_entity_id     := p_wip_entity_id;
        l_requirements_tbl(l_ind).organization_id   := p_organization_id;
        l_requirements_tbl(l_ind).inventory_item_id := req_rec.inventory_item_id;
        l_requirements_tbl(l_ind).required_quantity := req_rec.qty_required;
        l_requirements_tbl(l_ind).issued_quantity   := req_rec.qty_issued;

        get_qty_per_assembly(
          p_organization_id      => p_organization_id,
          p_wip_entity_id        => p_wip_entity_id,
          p_component_item_id    => req_rec.inventory_item_id,
          x_qty_per_assembly     => l_qty_per_assy,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_requirements_tbl(l_ind).quantity_per_assy := l_qty_per_assy;

        IF l_requirements_tbl(l_ind).issued_quantity = 0 THEN
          SELECT sum(nvl(abs(transaction_quantity),0))
          INTO   l_requirements_tbl(l_ind).issued_quantity
          FROM   mtl_material_transactions mmt
          WHERE  mmt.transaction_action_id      in (1,34)
          AND    mmt.transaction_source_type_id = 5
          AND    mmt.inventory_item_id          = l_requirements_tbl(l_ind).inventory_item_id
          AND    mmt.transaction_source_id      = p_wip_entity_id;
        END IF;

      END LOOP;

    END IF;

    x_requirements_tbl := l_requirements_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_issued_requirements;

  PROCEDURE get_issued_instances(
    p_wip_entity_id       IN  number,
    p_organization_id     IN  number,
    p_inventory_item_id   IN  number,
    p_serial_number       IN  varchar2,
    x_instance_tbl        OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    -- get_item_instances variables
    l_inst_query_rec      csi_datastructures_pub.instance_query_rec;
    l_party_query_rec     csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec  csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl    csi_datastructures_pub.instance_header_tbl;

    l_instance_tbl        csi_datastructures_pub.instance_tbl;
    --
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data            varchar2(2000);
    l_msg_count           number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_issued_instances');

    l_inst_query_rec.wip_job_id          := p_wip_entity_id;
    l_inst_query_rec.location_type_code  := 'WIP';
    l_inst_query_rec.inventory_item_id   := p_inventory_item_id;
    l_inst_query_rec.serial_number       := p_serial_number;
    l_inst_query_rec.instance_usage_code := 'IN_WIP';

    api_log(
      p_api_name => 'get_item_instances',
      p_pkg_name => 'csi_item_instance_pub');

    csi_item_instance_pub.get_item_instances(
      p_api_version          =>  1.0,
      p_commit               =>  fnd_api.g_false,
      p_init_msg_list        =>  fnd_api.g_true,
      p_validation_level     =>  fnd_api.g_valid_level_full,
      p_instance_query_rec   =>  l_inst_query_rec,
      p_party_query_rec      =>  l_party_query_rec,
      p_account_query_rec    =>  l_pty_acct_query_rec,
      p_transaction_id       =>  null,
      p_resolve_id_columns   =>  fnd_api.g_false,
      p_active_instance_only =>  fnd_api.g_true,
      x_instance_header_tbl  =>  l_instance_hdr_tbl,
      x_return_status        =>  l_return_status,
      x_msg_count            =>  l_msg_count,
      x_msg_data             =>  l_msg_data  );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_instance_hdr_tbl.COUNT > 0 THEN
      debug('Issued instances found for inventory item id: '||p_inventory_item_id);
    ELSE
      debug('Issued instances not found for inventory item id: '||p_inventory_item_id);
    END IF;

    csi_utl_pkg.make_non_header_tbl(
      p_instance_header_tbl => l_instance_hdr_tbl,
      x_instance_tbl        => l_instance_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_instance_tbl := l_instance_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END get_issued_instances;

  PROCEDURE get_serial_instance(
    p_inventory_item_id   IN  number,
    p_serial_number       IN  varchar2,
    x_instance_tbl        OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    -- get_item_instances variables
    l_inst_query_rec      csi_datastructures_pub.instance_query_rec;
    l_party_query_rec     csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec  csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl    csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl        csi_datastructures_pub.instance_tbl;

    --
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data            varchar2(2000);
    l_msg_count           number;

    l_t_ind               binary_integer := 0;
    l_tmp_inst_hdr_tbl    csi_datastructures_pub.instance_header_tbl;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_serial_instance');

    l_inst_query_rec.inventory_item_id   := p_inventory_item_id;
    l_inst_query_rec.serial_number       := p_serial_number;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'get_item_instances',
      p_pkg_name => 'csi_item_instance_pub');

    csi_item_instance_pub.get_item_instances(
      p_api_version          =>  1.0,
      p_commit               =>  fnd_api.g_false,
      p_init_msg_list        =>  fnd_api.g_true,
      p_validation_level     =>  fnd_api.g_valid_level_full,
      p_instance_query_rec   =>  l_inst_query_rec,
      p_party_query_rec      =>  l_party_query_rec,
      p_account_query_rec    =>  l_pty_acct_query_rec,
      p_transaction_id       =>  null,
      p_resolve_id_columns   =>  fnd_api.g_false,
      p_active_instance_only =>  fnd_api.g_false,
      x_instance_header_tbl  =>  l_instance_hdr_tbl,
      x_return_status        =>  l_return_status,
      x_msg_count            =>  l_msg_count,
      x_msg_data             =>  l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_instance_hdr_tbl.COUNT > 0 THEN
      debug('instance tbl count :'||l_instance_hdr_tbl.COUNT);
      csi_utl_pkg.make_non_header_tbl(
        p_instance_header_tbl => l_instance_hdr_tbl,
        x_instance_tbl        => l_instance_tbl,
        x_return_status       => l_return_status);

      /* this is just for debugging */
      IF l_instance_tbl.count > 0 THEN
        FOR l_ind IN l_instance_tbl.FIRST .. l_instance_tbl.LAST
        LOOP
          debug('  instance_id             :'||l_instance_tbl(l_ind).instance_id);
          debug('    accounting_class_code :'||l_instance_tbl(l_ind).accounting_class_code);
          debug('    location_type_code    :'||l_instance_tbl(l_ind).location_type_code);
          debug('    instance_usage_code   :'||l_instance_tbl(l_ind).instance_usage_code);
          debug('    wip_job_id            :'||l_instance_tbl(l_ind).wip_job_id);
          debug('    last_oe_rma_line_id   :'||l_instance_tbl(l_ind).last_oe_rma_line_id);
          debug('    last_oe_order_line_id :'||l_instance_tbl(l_ind).last_oe_order_line_id);
          debug('    active_end_date       :'||l_instance_tbl(l_ind).active_end_date);
        END LOOP;
      END IF;

    END IF;

    x_instance_tbl := l_instance_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_serial_instance;

  PROCEDURE split_instance_using_ratio(
    p_instance_id         IN     number,
    p_qty_ratio           IN     number,
    p_qty_completed       IN     number,
    p_organization_id     IN     number,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_splitted_instances     OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_qty_remaining         number;

    l_init_instance_rec     csi_datastructures_pub.instance_rec;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

    l_split_flag            boolean := FALSE;

    l_splitted_instances    csi_datastructures_pub.instance_tbl;
    l_s_ind                 binary_integer;

    -- get_item_instance_details variables
    l_g_instance_rec        csi_datastructures_pub.instance_header_rec;
    l_g_ph_tbl              csi_datastructures_pub.party_header_tbl;
    l_g_pah_tbl             csi_datastructures_pub.party_account_header_tbl;
    l_g_ouh_tbl             csi_datastructures_pub.org_units_header_tbl;
    l_g_pa_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_g_eav_tbl             csi_datastructures_pub.extend_attrib_values_tbl;
    l_g_ea_tbl              csi_datastructures_pub.extend_attrib_tbl;
    l_g_iah_tbl             csi_datastructures_pub.instance_asset_header_tbl;
    l_g_time_stamp          date;

    -- make_non_hdr variables
    l_instance_rec          csi_datastructures_pub.instance_rec;

    -- update_item_instance variables
    l_u_instance_rec        csi_datastructures_pub.instance_rec;
    l_u_parties_tbl         csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list   csi_datastructures_pub.id_tbl;

    -- create_item_instance varaibles
    l_c_instance_rec        csi_datastructures_pub.instance_rec;
    l_c_parties_tbl         csi_datastructures_pub.party_tbl;
    l_c_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_c_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_c_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_c_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_c_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    c_pa_ind                binary_integer;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('split_instance_using_ratio');

    l_s_ind := 0;

    l_g_instance_rec.instance_id := p_instance_id;

    api_log(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'get_item_instance_details');

    -- get the instance party and party account info
    csi_item_instance_pub.get_item_instance_details(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_g_instance_rec,
      p_get_parties           => fnd_api.g_true,
      p_party_header_tbl      => l_g_ph_tbl,
      p_get_accounts          => fnd_api.g_true,
      p_account_header_tbl    => l_g_pah_tbl,
      p_get_org_assignments   => fnd_api.g_false,
      p_org_header_tbl        => l_g_ouh_tbl,
      p_get_pricing_attribs   => fnd_api.g_false,
      p_pricing_attrib_tbl    => l_g_pa_tbl,
      p_get_ext_attribs       => fnd_api.g_false,
      p_ext_attrib_tbl        => l_g_eav_tbl,
      p_ext_attrib_def_tbl    => l_g_ea_tbl,
      p_get_asset_assignments => fnd_api.g_false,
      p_asset_header_tbl      => l_g_iah_tbl,
      p_time_stamp            => l_g_time_stamp,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    make_non_hdr_rec(
      p_instance_hdr_rec => l_g_instance_rec,
      x_instance_rec     => l_instance_rec,
      x_return_status    => l_return_status);

    debug('  Component Instance ID :'||l_instance_rec.instance_id);
    debug('  Component Quantity    :'||l_instance_rec.quantity);

    l_qty_remaining := l_g_instance_rec.quantity;

    FOR ind IN 1 .. p_qty_completed
    LOOP

      IF l_qty_remaining > p_qty_ratio THEN

        l_split_flag := TRUE;

        -- initialize the record structure
        l_c_instance_rec := l_init_instance_rec;
        l_u_instance_rec := l_init_instance_rec;

        l_qty_remaining := l_qty_remaining - p_qty_ratio;

        debug('  Allocated Qty(NEW) :'||p_qty_ratio);
        debug('  Remaining Qty(UPD) :'||l_qty_remaining );

        l_c_instance_rec := l_instance_rec;

        -- substitute create specific attributes
        l_c_instance_rec.instance_id           := fnd_api.g_miss_num;
        l_c_instance_rec.instance_number       := fnd_api.g_miss_char;
        l_c_instance_rec.object_version_number := 1.0;
        l_c_instance_rec.vld_organization_id   := p_organization_id;
        l_c_instance_rec.quantity              := p_qty_ratio;

        -- build party
        l_c_parties_tbl.DELETE;
        l_c_pty_accts_tbl.DELETE;
        c_pa_ind := 0;

        IF l_g_ph_tbl.COUNT > 0 THEN

          FOR l_pt_ind IN l_g_ph_tbl.FIRST ..l_g_ph_tbl.LAST
          LOOP
            l_c_parties_tbl(l_pt_ind).instance_party_id  := fnd_api.g_miss_num;
            l_c_parties_tbl(l_pt_ind).instance_id        := fnd_api.g_miss_num;
            l_c_parties_tbl(l_pt_ind).party_id           :=
                            l_g_ph_tbl(l_pt_ind).party_id;
            l_c_parties_tbl(l_pt_ind).party_source_table :=
                             l_g_ph_tbl(l_pt_ind).party_source_table;
            l_c_parties_tbl(l_pt_ind).relationship_type_code :=
                             l_g_ph_tbl(l_pt_ind).relationship_type_code;
            l_c_parties_tbl(l_pt_ind).contact_flag       := 'N';

            -- build party account
            IF l_g_pah_tbl.COUNT > 0 THEN
              FOR l_pa_ind IN l_g_pah_tbl.FIRST..l_g_pah_tbl.LAST
              LOOP
                IF l_g_pah_tbl(l_pa_ind).instance_party_id = l_g_ph_tbl(l_pt_ind).instance_party_id
                THEN
                  c_pa_ind := c_pa_ind + 1;
                  l_c_pty_accts_tbl(c_pa_ind).parent_tbl_index   := l_pt_ind;
                  l_c_pty_accts_tbl(c_pa_ind).ip_account_id      := fnd_api.g_miss_num;
                  l_c_pty_accts_tbl(c_pa_ind).instance_party_id  := fnd_api.g_miss_num;
                  l_c_pty_accts_tbl(c_pa_ind).party_account_id       :=
                                              l_g_pah_tbl(l_pa_ind).party_account_id;
                  l_c_pty_accts_tbl(c_pa_ind).relationship_type_code :=
                            l_g_pah_tbl(l_pa_ind).relationship_type_code;
                END IF;
              END LOOP;
            END IF;

          END LOOP;
        END IF;

        -- create a new instance for the decremented qty
        api_log(
          p_pkg_name => 'csi_item_instance_pub',
          p_api_name => 'create_item_instance');

        csi_item_instance_pub.create_item_instance(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_true,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_instance_rec          => l_c_instance_rec,
          p_party_tbl             => l_c_parties_tbl,
          p_account_tbl           => l_c_pty_accts_tbl,
          p_org_assignments_tbl   => l_c_org_units_tbl,
          p_ext_attrib_values_tbl => l_c_ea_values_tbl,
          p_pricing_attrib_tbl    => l_c_pricing_tbl,
          p_asset_assignment_tbl  => l_c_assets_tbl,
          p_txn_rec               => px_csi_txn_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data );

        -- For Bug 4057183
        -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('  New Instance ID :'||l_c_instance_rec.instance_id);

        l_s_ind := l_s_ind + 1;
        l_splitted_instances(l_s_ind) := l_c_instance_rec;

        -- decrementing the existing wip instance with the remaining quantity
        l_u_instance_rec.instance_id         := p_instance_id;
        l_u_instance_rec.quantity            := l_qty_remaining;
        l_u_instance_rec.vld_organization_id := p_organization_id;

        SELECT object_version_number
        INTO   l_u_instance_rec.object_version_number
        FROM   csi_item_instances
        WHERE  instance_id = l_u_instance_rec.instance_id;

        api_log(
          p_pkg_name => 'csi_item_instance_pub',
          p_api_name => 'update_item_instance');

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
          p_txn_rec               => px_csi_txn_rec,
          x_instance_id_lst       => l_u_instance_ids_list,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data);

        -- For Bug 4057183
        -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE

        -- we get two cases here < and =
        -- when the remaining qty is < ratio do not allocate it to an assy instance
        -- making sure that assy instances are always getting the full ratio. this
        -- simplifies the process of elliminating assy instances when further partial
        -- issues are done. otherwise it is difficult to get the partially allocated
        -- component instance and update it with the remaining ratio qty blah blah blah
        --(just simplifying my coding)

        IF l_qty_remaining < p_qty_ratio THEN
          NULL;
        ELSE

          l_s_ind := l_s_ind + 1;

          IF l_split_flag THEN
            l_splitted_instances(l_s_ind) := l_u_instance_rec;
          ELSE
            l_splitted_instances(l_s_ind) := l_instance_rec;
          END IF;

        END IF;

        EXIT;

      END IF;

    END LOOP;

    debug('  Splitted instances count :'||l_splitted_instances.COUNT);

    x_splitted_instances := l_splitted_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_instance_using_ratio;


  PROCEDURE split_instances_using_ratio(
    p_qty_ratio           IN number,
    p_qty_completed       IN number,
    p_organization_id     IN number,
    p_issued_instances    IN csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_splitted_instances     OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_splitted_instances     csi_datastructures_pub.instance_tbl;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('split_instances_using_ratio');

    IF p_issued_instances.COUNT > 0 THEN
      FOR l_ind IN p_issued_instances.FIRST .. p_issued_instances.LAST
      LOOP

        split_instance_using_ratio(
          p_instance_id         => p_issued_instances(l_ind).instance_id,
          p_qty_ratio           => p_qty_ratio,
          p_qty_completed       => p_qty_completed,
          p_organization_id     => p_organization_id,
          px_csi_txn_rec        => px_csi_txn_rec,
          x_splitted_instances  => l_splitted_instances,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END LOOP;
    END IF;

    x_splitted_instances := l_splitted_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END split_instances_using_ratio;


  PROCEDURE split_issued_instances(
    p_organization_id     IN     number,
    p_job_quantity        IN     number,
    p_completion_quantity IN     number,
    px_issued_instances   IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_splitted_instances     OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_allocated_quantity    number;
    l_remaining_quantity    number;

    l_new_instance_rec      csi_datastructures_pub.instance_rec;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

    l_split_counter         number;

    l_splitted_instances    csi_datastructures_pub.instance_tbl;
    l_s_ind                 binary_integer;

    -- get_item_instance_details variables
    l_g_instance_rec        csi_datastructures_pub.instance_header_rec;
    l_g_ph_tbl              csi_datastructures_pub.party_header_tbl;
    l_g_pah_tbl             csi_datastructures_pub.party_account_header_tbl;
    l_g_ouh_tbl             csi_datastructures_pub.org_units_header_tbl;
    l_g_pa_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_g_eav_tbl             csi_datastructures_pub.extend_attrib_values_tbl;
    l_g_ea_tbl              csi_datastructures_pub.extend_attrib_tbl;
    l_g_iah_tbl             csi_datastructures_pub.instance_asset_header_tbl;
    l_g_time_stamp          date;

    -- update_item_instance variables
    l_u_instance_rec        csi_datastructures_pub.instance_rec;
    l_u_parties_tbl         csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list   csi_datastructures_pub.id_tbl;

    -- create_item_instance varaibles
    l_c_instance_rec        csi_datastructures_pub.instance_rec;
    l_c_parties_tbl         csi_datastructures_pub.party_tbl;
    l_c_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_c_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_c_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_c_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_c_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    c_pa_ind                binary_integer;

    l_instance_rec          csi_datastructures_pub.instance_rec;
    --

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('split_issued_instances');

    l_s_ind := 0;

    l_split_counter := p_completion_quantity;

    IF px_issued_instances.COUNT > 0 THEN

      FOR l_ind IN px_issued_instances.FIRST .. px_issued_instances.LAST
      LOOP

        debug('  Component Instance ID :'||px_issued_instances(l_ind).instance_id);
        debug('  Component Instance Qty:'||px_issued_instances(l_ind).quantity);

	--Fix for bug 5015147:If condition added to allow aplit only if inst_qty > 1
	IF px_issued_instances(l_ind).quantity > 1 THEN

        l_g_instance_rec.instance_id := px_issued_instances(l_ind).instance_id;

        api_log(
          p_pkg_name => 'csi_item_instance_pub',
          p_api_name => 'get_item_instance_details');

        -- get the instance party and party account info
        csi_item_instance_pub.get_item_instance_details(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_true,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_instance_rec          => l_g_instance_rec,
          p_get_parties           => fnd_api.g_true,
          p_party_header_tbl      => l_g_ph_tbl,
          p_get_accounts          => fnd_api.g_true,
          p_account_header_tbl    => l_g_pah_tbl,
          p_get_org_assignments   => fnd_api.g_false,
          p_org_header_tbl        => l_g_ouh_tbl,
          p_get_pricing_attribs   => fnd_api.g_false,
          p_pricing_attrib_tbl    => l_g_pa_tbl,
          p_get_ext_attribs       => fnd_api.g_false,
          p_ext_attrib_tbl        => l_g_eav_tbl,
          p_ext_attrib_def_tbl    => l_g_ea_tbl,
          p_get_asset_assignments => fnd_api.g_false,
          p_asset_header_tbl      => l_g_iah_tbl,
          p_time_stamp            => l_g_time_stamp,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_remaining_quantity := l_g_instance_rec.quantity;

        make_non_hdr_rec(
          p_instance_hdr_rec  => l_g_instance_rec,
          x_instance_rec      => l_instance_rec,
          x_return_status     => l_return_status);

        debug('Splitting the comp instance for the job quantity '||p_job_quantity);

        FOR i IN REVERSE 1..p_job_quantity
        LOOP

          l_allocated_quantity := CEIL(l_remaining_quantity/i);
          l_remaining_quantity := l_remaining_quantity - l_allocated_quantity;

          debug('  Allocated Qty(NEW) :'||l_allocated_quantity);
          debug('  Remaining Qty(UPD) :'||l_remaining_quantity);

          -- take all that is in issued instance rec
          l_c_instance_rec := l_instance_rec;

          -- substitute create specific attributes
          l_c_instance_rec.instance_id           := fnd_api.g_miss_num;
          l_c_instance_rec.instance_number       := fnd_api.g_miss_char;
          l_c_instance_rec.object_version_number := 1.0;
          l_c_instance_rec.vld_organization_id   := p_organization_id;
          l_c_instance_rec.quantity              := l_allocated_quantity;

          -- build party
          l_c_parties_tbl.DELETE;
          l_c_pty_accts_tbl.DELETE;
          c_pa_ind := 0;

          IF l_g_ph_tbl.COUNT > 0 THEN
            FOR l_pt_ind IN l_g_ph_tbl.FIRST ..l_g_ph_tbl.LAST
            LOOP
              l_c_parties_tbl(l_pt_ind).instance_party_id  := fnd_api.g_miss_num;
              l_c_parties_tbl(l_pt_ind).instance_id        := fnd_api.g_miss_num;
              l_c_parties_tbl(l_pt_ind).party_id           :=
                           l_g_ph_tbl(l_pt_ind).party_id;
              l_c_parties_tbl(l_pt_ind).party_source_table :=
                             l_g_ph_tbl(l_pt_ind).party_source_table;
              l_c_parties_tbl(l_pt_ind).relationship_type_code :=
                             l_g_ph_tbl(l_pt_ind).relationship_type_code;
              l_c_parties_tbl(l_pt_ind).contact_flag       := 'N';

              -- build party account

              IF l_g_pah_tbl.COUNT > 0 THEN
                FOR l_pa_ind IN l_g_pah_tbl.FIRST..l_g_pah_tbl.LAST
                LOOP
                  IF l_g_pah_tbl(l_pa_ind).instance_party_id =
                     l_g_ph_tbl(l_pt_ind).instance_party_id
                  THEN
                    c_pa_ind := c_pa_ind + 1;
                    l_c_pty_accts_tbl(c_pa_ind).parent_tbl_index   := l_pt_ind;
                    l_c_pty_accts_tbl(c_pa_ind).ip_account_id      := fnd_api.g_miss_num;
                    l_c_pty_accts_tbl(c_pa_ind).instance_party_id  := fnd_api.g_miss_num;
                    l_c_pty_accts_tbl(c_pa_ind).party_account_id       :=
                          l_g_pah_tbl(l_pa_ind).party_account_id;
                    l_c_pty_accts_tbl(c_pa_ind).relationship_type_code :=
                          l_g_pah_tbl(l_pa_ind).relationship_type_code;
                  END IF;
                END LOOP;
              END IF;

            END LOOP;
          END IF;

          -- create a new instance for the decremented qty
          api_log(
            p_pkg_name => 'csi_item_instance_pub',
            p_api_name => 'create_item_instance');

          csi_item_instance_pub.create_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_c_instance_rec,
            p_party_tbl             => l_c_parties_tbl,
            p_account_tbl           => l_c_pty_accts_tbl,
            p_org_assignments_tbl   => l_c_org_units_tbl,
            p_ext_attrib_values_tbl => l_c_ea_values_tbl,
            p_pricing_attrib_tbl    => l_c_pricing_tbl,
            p_asset_assignment_tbl  => l_c_assets_tbl,
            p_txn_rec               => px_csi_txn_rec,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data );

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('  New Instance ID :'||l_c_instance_rec.instance_id);

          l_s_ind := l_s_ind + 1;
          l_splitted_instances(l_s_ind) := l_c_instance_rec;


          -- decrementing the existing wip instance with the new quantity (l_new_qty)
          l_u_instance_rec.instance_id         := px_issued_instances(l_ind).instance_id;
          l_u_instance_rec.quantity            := l_remaining_quantity;
          l_u_instance_rec.vld_organization_id := p_organization_id;

          SELECT object_version_number
          INTO   l_u_instance_rec.object_version_number
          FROM   csi_item_instances
          WHERE  instance_id = l_u_instance_rec.instance_id;

          api_log(
            p_pkg_name => 'csi_item_instance_pub',
            p_api_name => 'update_item_instance');

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
            p_txn_rec               => px_csi_txn_rec,
            x_instance_id_lst       => l_u_instance_ids_list,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_remaining_quantity <= l_allocated_quantity THEN
            l_s_ind := l_s_ind + 1;
            l_splitted_instances(l_s_ind) := l_u_instance_rec;
            EXIT;
          END IF;

          l_split_counter := l_split_counter - 1;
          IF l_split_counter = 0 THEN
            EXIT;
          END IF;

        END LOOP;
	ELSE --Fix for bug 5015147
	  l_s_ind := l_s_ind + 1;
          l_splitted_instances(l_s_ind) := px_issued_instances(l_ind);
          debug('Since Instance quantity is not more than than one,no split is done');
        END IF;
       END LOOP;
    END IF;

    x_splitted_instances := l_splitted_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_issued_instances;

  PROCEDURE create_assy_comp_relation(
    p_assy_comp_map_tbl   IN  assy_comp_map_tbl,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_ii_rltns_tbl        csi_datastructures_pub.ii_relationship_tbl;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_rltn_exists         varchar2(1) := 'N';

    l_iir_ind             binary_integer := 0;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('create_assy_comp_relation');

    IF p_assy_comp_map_tbl.COUNT > 0 THEN
      FOR l_ind IN p_assy_comp_map_tbl.FIRST .. p_assy_comp_map_tbl.LAST
      LOOP

        -- Added for Ikon . Bug 2443204.
        -- This is to rebuild the correct configuration in IB when Users work on an
        -- already existing assembly in IB. shegde.
        Begin

          l_rltn_exists := 'N';

          SELECT 'Y'
          INTO   l_rltn_exists
          FROM   csi_ii_relationships
          WHERE  subject_id = p_assy_comp_map_tbl(l_ind).comp_instance_id
          AND    object_id  = p_assy_comp_map_tbl(l_ind).assy_instance_id
          AND    relationship_type_code = 'COMPONENT-OF'
          AND    active_end_date is NULL OR active_end_date > sysdate;

        EXCEPTION
          WHEN no_data_found THEN
            l_rltn_exists := 'N';
        END;

        IF l_rltn_exists = 'N' THEN
          l_iir_ind := l_iir_ind + 1;
          l_ii_rltns_tbl(l_iir_ind).relationship_id := fnd_api.g_miss_num;
          l_ii_rltns_tbl(l_iir_ind).subject_id := p_assy_comp_map_tbl(l_ind).comp_instance_id;
          l_ii_rltns_tbl(l_iir_ind).object_id  := p_assy_comp_map_tbl(l_ind).assy_instance_id;
          l_ii_rltns_tbl(l_iir_ind).relationship_type_code := 'COMPONENT-OF';
        END IF;
        -- End Bug 2443204

      END LOOP;
    END IF;

    api_log(
      p_pkg_name => 'csi_ii_relationships_pub',
      p_api_name => 'create_relationship');

    csi_ii_relationships_pub.create_relationship(
      p_api_version      => 1.0,
      p_commit           => fnd_api.g_false,
      p_init_msg_list    => fnd_api.g_true,
      p_validation_level => fnd_api.g_valid_level_full,
      p_relationship_tbl => l_ii_rltns_tbl,
      p_txn_rec          => px_csi_txn_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Error in csi_ii_relationships_pub.create_relationship.');
      RAISE fnd_api.g_exc_error;
    END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_assy_comp_relation;

  PROCEDURE get_genealogy_children(
    px_assembly_instances  IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_assy_comp_map_tbl       OUT NOCOPY assy_comp_map_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    CURSOR mog_cur(p_parent_object_id IN number) IS
      SELECT msn.serial_number      child_serial_number,
             msn.inventory_item_id  child_item_id
      FROM   mtl_object_genealogy mog,
             mtl_serial_numbers   msn
      WHERE  mog.parent_object_type = 2
      AND    mog.parent_object_id   = p_parent_object_id
      AND    mog.object_type        = 2
      AND    msn.gen_object_id      = mog.object_id
      AND    sysdate BETWEEN nvl(mog.start_date_active, sysdate-1)
                     AND     nvl(mog.end_date_active,   sysdate+1);

    l_ac_map_tbl           assy_comp_map_tbl;
    l_ac_ind               binary_integer := 0;
    l_assy_tbl             csi_datastructures_pub.instance_tbl;
    l_parent_object_id     number;
    l_children_count       number;

    l_child_instance_id    number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_genealogy_children');

    l_assy_tbl := px_assembly_instances;

    IF l_assy_tbl.count > 0 THEN
      FOR l_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
      LOOP

        debug('Parent Serial :'||l_assy_tbl(l_ind).serial_number);

        SELECT gen_object_id
        INTO   l_parent_object_id
        FROM   mtl_serial_numbers
        WHERE  inventory_item_id = l_assy_tbl(l_ind).inventory_item_id
        AND    serial_number     = l_assy_tbl(l_ind).serial_number;

        l_children_count := 0;

        FOR mog_rec in mog_cur(l_parent_object_id)
        LOOP

          debug('  Genealogy Child :'||mog_rec.child_serial_number);

          l_children_count := l_children_count + 1;

          BEGIN

            SELECT instance_id
            INTO   l_child_instance_id
            FROM   csi_item_instances
            WHERE  inventory_item_id = mog_rec.child_item_id
            AND    serial_number     = mog_rec.child_serial_number;

            debug('  Instance ID :'||l_child_instance_id);

            l_ac_ind := l_ac_ind + 1;
            l_ac_map_tbl(l_ac_ind).assy_instance_id := l_assy_tbl(l_ind).instance_id;
            l_ac_map_tbl(l_ac_ind).comp_instance_id := l_child_instance_id;
            l_ac_map_tbl(l_ac_ind).comp_quantity    := 1;

          EXCEPTION
            WHEN no_data_found THEN
              debug('  Genealogy child instance not in IB yet.');
              l_child_instance_id := null;
          END;

        END LOOP;

        l_assy_tbl(l_ind).attribute1 := l_children_count;

      END LOOP;
    END IF;

    px_assembly_instances := l_assy_tbl;
    x_assy_comp_map_tbl   := l_ac_map_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END get_genealogy_children;

  PROCEDURE get_parent_serial_number(
     p_child_item_id        IN  number,
     p_child_serial_number  IN  varchar2,
     x_parent_item_id       OUT NOCOPY varchar2,
     x_parent_serial_number OUT NOCOPY varchar2,
     x_return_status        OUT NOCOPY varchar2)
  IS
    l_child_object_id       number;
    l_parent_item_id        number;
    l_parent_serial_number  varchar2(80);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_parent_serial_number');

    SELECT gen_object_id,
           parent_serial_number
    INTO   l_child_object_id,
           l_parent_serial_number
    FROM   mtl_serial_numbers
    WHERE  inventory_item_id = p_child_item_id
    and    serial_number     = p_child_serial_number;

    IF l_parent_serial_number is not null THEN
      BEGIN
        SELECT msn.serial_number,
               msn.inventory_item_id
        INTO   l_parent_serial_number,
               l_parent_item_id
        FROM   mtl_object_genealogy mog,
               mtl_serial_numbers   msn
        WHERE  mog.object_type        = 2  -- serial genealogy
        AND    mog.object_id          = l_child_object_id
        AND    mog.parent_object_type = 2  -- serial genealogy
        AND    msn.gen_object_id      = mog.parent_object_id
        AND    sysdate BETWEEN nvl(mog.start_date_active, sysdate-1)
                       AND     nvl(mog.end_date_active,   sysdate+1);
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;
    END IF;

    debug('  Parent Serial Number :'||l_parent_serial_number);

    x_parent_item_id       := l_parent_item_id;
    x_parent_serial_number := l_parent_serial_number;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_parent_serial_number;


  PROCEDURE apportion_serialized(
    p_context              IN varchar2,
    p_requirements_flag    IN varchar2,
    p_qty_per_assy         IN number,
    p_total_qty_issued     IN number,
    p_job_qty              IN number,
    p_component_item_id    IN number,
    p_assembly_instances   IN csi_datastructures_pub.instance_tbl,
    p_component_instances  IN csi_datastructures_pub.instance_tbl,
    px_assy_comp_map_tbl   IN OUT NOCOPY assy_comp_map_tbl,
    x_return_status        IN OUT NOCOPY varchar2)
  IS

    l_qty_remaining        number;

    l_assy_tbl             csi_datastructures_pub.instance_tbl;
    l_comp_tbl             csi_datastructures_pub.instance_tbl;
    l_ac_map_tbl           assy_comp_map_tbl;

    l_already_alloc_count  number := 0;
    l_c_ind                binary_integer := 0;
    l_nac_ind              binary_integer := 0;

    l_tot_qty_remaining    number := 0;
    l_assy_counter         number := 0;

--Fix for bug 4705806
    l_parent_item_id       number;
    l_parent_serial_number varchar2(80)   := null;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;


    FUNCTION alloc_count(p_object_id IN number, p_comp_item_id IN number)
    RETURN number
    IS
      l_alloc_count number := 0;
    BEGIN
      SELECT count(*)
      INTO   l_alloc_count
      FROM   csi_ii_relationships cir,
             csi_item_instances   cii
      WHERE  cir.object_id = p_object_id
      AND    cir.relationship_type_code = 'COMPONENT-OF'
      AND    sysdate BETWEEN nvl(cir.active_start_date, sysdate-1)
                     AND     nvl(cir.active_end_date, sysdate+1)
      AND    cii.instance_id = cir.subject_id
      AND    cii.inventory_item_id = p_comp_item_id;
      RETURN l_alloc_count;
    END alloc_count;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('apportion_serialized');

    l_assy_tbl   := p_assembly_instances;
    l_comp_tbl   := p_component_instances;
    l_ac_map_tbl := px_assy_comp_map_tbl;

    l_assy_counter      := p_job_qty;
    l_tot_qty_remaining := p_total_qty_issued;

    IF p_context = 'COMPLETION' THEN

      IF l_assy_tbl.COUNT > 0 THEN

        FOR l_a_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
        LOOP

          IF p_requirements_flag = 'Y' THEN
            l_qty_remaining     := abs(p_qty_per_assy);
          ELSE
            l_qty_remaining     := ceil(l_tot_qty_remaining/l_assy_counter);

            l_tot_qty_remaining := l_tot_qty_remaining - l_qty_remaining;
            l_assy_counter      := l_assy_counter - 1;
          END IF;

          l_already_alloc_count := to_number(l_assy_tbl(l_a_ind).attribute1);
          l_qty_remaining       := l_qty_remaining - l_already_alloc_count;

          IF l_qty_remaining > 0 THEN

            debug('    Parent Serial :'||l_assy_tbl(l_a_ind).serial_number);
            IF l_comp_tbl.COUNT > 0 THEN

              l_c_ind := 0;
              LOOP
                l_c_ind := l_comp_tbl.NEXT(l_c_ind);
                EXIT when l_c_ind is null;
		--Fix for bug 4705806:Here we ensure that if issued component has a genealogy
		--parent,we avoid that instance getting in relationship with other parent randomly.
		get_parent_serial_number(
                      p_child_item_id        => l_comp_tbl(l_c_ind).inventory_item_id,
                      p_child_serial_number  => l_comp_tbl(l_c_ind).serial_number,
                      x_parent_item_id       => l_parent_item_id,
                      x_parent_serial_number => l_parent_serial_number,
                      x_return_status        => l_return_status );
                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                END IF;
		IF l_parent_serial_number IS NOT NULL THEN
                    l_comp_tbl.DELETE(l_c_ind);
                ELSE	--end of bug fix 4705806

                l_nac_ind := l_ac_map_tbl.COUNT + 1;

                l_ac_map_tbl(l_nac_ind).assy_instance_id := l_assy_tbl(l_a_ind).instance_id;
                l_ac_map_tbl(l_nac_ind).comp_instance_id := l_comp_tbl(l_c_ind).instance_id;
                l_ac_map_tbl(l_nac_ind).comp_quantity    := 1;

                debug('      Child Serial  :'||l_comp_tbl(l_c_ind).serial_number);

                l_comp_tbl.DELETE(l_c_ind);
                l_qty_remaining  := l_qty_remaining - 1;
                IF l_qty_remaining = 0 THEN
                  EXIT;
                END IF;
		END IF;
              END LOOP;
            END IF;
          END IF;

        END LOOP; --assy table loop;
      END IF; -- assy table count > 0
    ELSIF p_context = 'ISSUE' THEN

      IF l_assy_tbl.COUNT > 0 THEN
        FOR l_a_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
        LOOP

          IF p_requirements_flag = 'Y' THEN
            l_qty_remaining     := p_qty_per_assy;
          ELSE
            l_qty_remaining     := ceil(l_tot_qty_remaining/l_assy_counter);

            l_tot_qty_remaining := l_tot_qty_remaining - l_qty_remaining;
            l_assy_counter      := l_assy_counter - 1;
          END IF;

          l_already_alloc_count := alloc_count(l_assy_tbl(l_a_ind).instance_id, p_component_item_id);

          IF l_ac_map_tbl.COUNT > 0 THEN
            FOR l_ac_ind IN l_ac_map_tbl.FIRST .. l_ac_map_tbl.LAST
            LOOP
              IF l_ac_map_tbl(l_ac_ind).assy_instance_id = l_assy_tbl(l_a_ind).instance_id THEN
                l_already_alloc_count := l_already_alloc_count + 1;
              END IF;
            END LOOP;
          END IF;

          l_qty_remaining := l_qty_remaining - l_already_alloc_count;

          IF l_qty_remaining > 0 THEN

            debug('    Parent Serial :'||l_assy_tbl(l_a_ind).serial_number);
            IF l_comp_tbl.COUNT > 0 THEN
              l_c_ind := 0;
              LOOP
                l_c_ind := l_comp_tbl.NEXT(l_c_ind);
                EXIT when l_c_ind is null;
		--Fix for bug 4705806
		get_parent_serial_number(
                      p_child_item_id        => l_comp_tbl(l_c_ind).inventory_item_id,
                      p_child_serial_number  => l_comp_tbl(l_c_ind).serial_number,
                      x_parent_item_id       => l_parent_item_id,
                      x_parent_serial_number => l_parent_serial_number,
                      x_return_status        => l_return_status );
                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                END IF;
                IF l_parent_serial_number IS NOT NULL THEN
                    l_comp_tbl.DELETE(l_c_ind);
                ELSE --end of bug fix 4705806

                l_nac_ind := l_ac_map_tbl.COUNT + 1;

                l_ac_map_tbl(l_nac_ind).assy_instance_id := l_assy_tbl(l_a_ind).instance_id;
                l_ac_map_tbl(l_nac_ind).comp_instance_id := l_comp_tbl(l_c_ind).instance_id;
                l_ac_map_tbl(l_nac_ind).comp_quantity    := 1;
                debug('      Child Serial  :'||l_comp_tbl(l_c_ind).serial_number);

                l_comp_tbl.DELETE(l_c_ind);

                l_qty_remaining := l_qty_remaining - 1;

                IF l_qty_remaining = 0 THEN
                  EXIT;
                END IF;
		END IF;
              END LOOP;
            END IF;

          END IF;

        END LOOP;
      END IF;
    END IF;

    px_assy_comp_map_tbl := l_ac_map_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END apportion_serialized;

  PROCEDURE apportion_nonserial_instance(
    p_requirements_flag    IN varchar2,
    p_qty_per_assy         IN number,
    p_qty_issued           IN number,
    p_total_qty_issued     IN number,
    p_job_qty              IN number,
    p_organization_id      IN number,
    p_assembly_instances   IN csi_datastructures_pub.instance_tbl,
    p_component_instance   IN csi_datastructures_pub.instance_rec,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_assy_comp_map_tbl    OUT NOCOPY assy_comp_map_tbl,
    x_return_status        IN OUT NOCOPY varchar2)
  IS

    CURSOR comp_cur (p_object_id in number, p_comp_item_id in number) IS
      SELECT cir.subject_id, cii.quantity
      FROM   csi_ii_relationships cir,
             csi_item_instances   cii
      WHERE  cir.object_id = p_object_id
      AND    cir.relationship_type_code = 'COMPONENT-OF'
      AND    cii.instance_id = cir.subject_id
      AND    cii.inventory_item_id = p_comp_item_id
      AND    nvl(cii.active_end_date,sysdate+1) > sysdate; --Added end date condition for bug 5376024

    l_qty_remaining        number := 0;
    l_qty_available        number := 0;
    l_qty_allocated        number := 0;
    l_already_allocated    number := 0;

    l_assy_counter         number := 0;
    l_tot_qty_remaining    number := 0;

    l_comp_found           boolean := FALSE;

    l_assy_tbl             csi_datastructures_pub.instance_tbl;
    l_comp_rec             csi_datastructures_pub.instance_rec;

    l_ac_ind               binary_integer := 0;
    l_ac_map_tbl           assy_comp_map_tbl;

    l_new_instance_id      number;

    l_instance_rec         csi_datastructures_pub.instance_rec;

    -- update_item_instance variables
    l_u_instance_rec       csi_datastructures_pub.instance_rec;
    l_u_parties_tbl        csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl      csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl      csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl        csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list  csi_datastructures_pub.id_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

    FUNCTION alloc_quantity(p_object_id IN number, p_comp_item_id IN number)
    RETURN number
    IS
      l_alloc_qty number := 0;
    BEGIN
      SELECT sum(cii.quantity)
      INTO   l_alloc_qty
      FROM   csi_ii_relationships cir,
             csi_item_instances   cii
      WHERE  cir.object_id = p_object_id
      AND    cir.relationship_type_code = 'COMPONENT-OF'
      AND    cii.instance_id = cir.subject_id
      AND    cii.inventory_item_id = p_comp_item_id;
      RETURN l_alloc_qty;
    EXCEPTION
      WHEN others THEN
        RETURN l_alloc_qty;
    END alloc_quantity;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('apportion_nonserial_instance');

    debug('  requirements_flag '||p_requirements_flag);
    debug('  quantity_per_assy '||p_qty_per_assy);

    l_assy_tbl          := p_assembly_instances;
    l_comp_rec          := p_component_instance;
    l_qty_remaining     := l_comp_rec.quantity;

    -- to process no requirement ratio
    l_assy_counter      := p_job_qty;
    l_tot_qty_remaining := p_total_qty_issued;

    IF l_assy_tbl.COUNT > 0 THEN

      FOR l_a_ind IN l_assy_tbl.FIRST .. l_assy_tbl.LAST
      LOOP

        debug('  qty_remaining     :'||l_qty_remaining);


        IF l_qty_remaining > 0 THEN

          IF p_requirements_flag = 'Y' THEN
            l_qty_available     := p_qty_per_assy;
          ELSE
            l_qty_available     := ceil(l_tot_qty_remaining/l_assy_counter);
            l_tot_qty_remaining := l_tot_qty_remaining - l_qty_available;
            l_assy_counter      := l_assy_counter - 1;
          END IF;

          l_already_allocated := nvl(alloc_quantity(l_assy_tbl(l_a_ind).instance_id,
                                                l_comp_rec.inventory_item_id),0);

          debug('  already_allocated :'||l_already_allocated );

          l_qty_available     := l_qty_available - l_already_allocated ;

          debug('  qty_available     :'||l_qty_available );

          IF l_qty_available > 0 THEN

            IF l_qty_remaining > l_qty_available THEN
              l_qty_allocated := l_qty_available;
            ELSE
              l_qty_allocated := l_qty_remaining;
            END IF;

            debug('  qty_allocated     :'||l_qty_allocated );

            l_comp_found := FALSE;

            FOR comp_rec IN comp_cur(l_assy_tbl(l_a_ind).instance_id, l_comp_rec.inventory_item_id)
            LOOP

              l_comp_found := TRUE;

              --update comp instance with the new qty
              increment_comp_instance(
                p_instance_id         => comp_rec.subject_id,
                p_quantity            => l_qty_allocated,
                px_csi_txn_rec        => px_csi_txn_rec,
                x_return_status       => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              --decrement the wip instance
              decrement_wip_instance(
                p_instance_id         => l_comp_rec.instance_id,
                p_quantity            => l_qty_allocated,
                px_csi_txn_rec        => px_csi_txn_rec,
                x_return_status       => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              exit;
            END LOOP;

            IF NOT(l_comp_found) THEN

              IF l_qty_allocated = l_qty_remaining THEN

                -- just build the ac_map tbl
                l_ac_ind := l_ac_ind + 1;
                l_ac_map_tbl(l_ac_ind).assy_instance_id := l_assy_tbl(l_a_ind).instance_id;
                l_ac_map_tbl(l_ac_ind).comp_instance_id := l_comp_rec.instance_id;
                l_ac_map_tbl(l_ac_ind).comp_quantity    := l_qty_allocated;

              ELSE

                --create a WIP instance and make it component for in_relation
                create_wip_instance_as(
                  p_instance_id      => l_comp_rec.instance_id,
                  p_quantity         => l_qty_allocated,
                  p_organization_id  => p_organization_id,
                  x_new_instance_id  => l_new_instance_id,
                  px_csi_txn_rec     => px_csi_txn_rec,
                  x_return_status    => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                --decrement the wip instance
                decrement_wip_instance(
                  p_instance_id         => l_comp_rec.instance_id,
                  p_quantity            => l_qty_allocated,
                  px_csi_txn_rec        => px_csi_txn_rec,
                  x_return_status       => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                l_ac_ind := l_ac_ind + 1;
                l_ac_map_tbl(l_ac_ind).assy_instance_id := l_assy_tbl(l_a_ind).instance_id;
                l_ac_map_tbl(l_ac_ind).comp_instance_id := l_new_instance_id;
                l_ac_map_tbl(l_ac_ind).comp_quantity    := l_qty_allocated;

              END IF;

            END IF;

            l_qty_remaining := l_qty_remaining - l_qty_allocated;

          END IF;

        END IF;

      END LOOP;
    END IF;

    debug('  Assy Comp Map Tbl Count :'||l_ac_map_tbl.COUNT);

    x_assy_comp_map_tbl := l_ac_map_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END apportion_nonserial_instance;

  PROCEDURE apportion_non_serialized(
    p_context              IN varchar2,
    p_requirements_flag    IN varchar2,
    p_qty_per_assy         IN number,
    p_qty_issued           IN number,
    p_total_qty_issued     IN number,
    p_job_qty              IN number,
    p_organization_id      IN number,
    p_assembly_instances   IN csi_datastructures_pub.instance_tbl,
    p_component_instances  IN csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_assy_comp_map_tbl       OUT NOCOPY assy_comp_map_tbl,
    x_return_status        IN OUT NOCOPY varchar2)
  IS

    l_tmp_ac_map_tbl       assy_comp_map_tbl;
    l_ac_ind               binary_integer := 0;
    l_ac_map_tbl           assy_comp_map_tbl;
    l_return_status        varchar2(1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('apportion_non_serialized');

    IF p_component_instances.COUNT > 0 THEN
      FOR l_ind IN p_component_instances.FIRST .. p_component_instances.LAST
      LOOP

        apportion_nonserial_instance(
          p_requirements_flag    => p_requirements_flag,
          p_qty_per_assy         => p_qty_per_assy,
          p_qty_issued           => p_qty_issued,
          p_total_qty_issued     => p_total_qty_issued,
          p_job_qty              => p_job_qty,
          p_organization_id      => p_organization_id,
          p_assembly_instances   => p_assembly_instances,
          p_component_instance   => p_component_instances(l_ind),
          px_csi_txn_rec         => px_csi_txn_rec,
          x_assy_comp_map_tbl    => l_tmp_ac_map_tbl,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_tmp_ac_map_tbl.COUNT > 0 THEN
          FOR l_t_ind IN l_tmp_ac_map_tbl.FIRST .. l_tmp_ac_map_tbl.LAST
          LOOP
            l_ac_ind := l_ac_ind + 1;
            l_ac_map_tbl(l_ac_ind) := l_tmp_ac_map_tbl(l_t_ind);
          END LOOP;
        END IF;

      END LOOP;
    END IF;

    debug('  TOTAL Assy Comp Map Tbl Count :'||l_ac_map_tbl.COUNT);

    x_assy_comp_map_tbl := l_ac_map_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END apportion_non_serialized;

  PROCEDURE build_discrete_rltn_at_wipac(
    p_txn_ref             IN txn_ref,
    p_assembly_instances  IN csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_auto_allocate       varchar2(1);

    l_requirements_tbl    requirements_tbl;
    l_issued_instances    csi_datastructures_pub.instance_tbl;
    l_assembly_instances  csi_datastructures_pub.instance_tbl;

    l_splitted_instances  csi_datastructures_pub.instance_tbl;
    l_assy_comp_map_tbl   assy_comp_map_tbl;
    l_comp_serial_code    number;

    end_process           exception;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

    l_requirements_flag   varchar2(1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_discrete_rltn_at_wipac');

    l_auto_allocate := csi_datastructures_pub.g_install_param_rec.auto_allocate_comp_at_wip;

    l_assembly_instances := p_assembly_instances;

    debug('Assembly Instances Count: '||l_assembly_instances.COUNT);

    IF l_assembly_instances.COUNT = 0 THEN
      debug('Could not find the assembly instances. Process terminates here.');
      RAISE end_process;
    END IF;

    get_issued_requirements(
      p_wip_entity_id       => p_txn_ref.wip_entity_id,
      p_organization_id     => p_txn_ref.organization_id,
      p_assembly_item_id    => p_txn_ref.wip_assembly_item_id,
      p_auto_allocate       => l_auto_allocate,
      x_requirements_tbl    => l_requirements_tbl,
      x_return_status       => l_return_status);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('Issued Requirements Count: '||l_requirements_tbl.COUNT);

    IF l_requirements_tbl.COUNT > 0 THEN

      FOR l_ind IN l_requirements_tbl.FIRST ..l_requirements_tbl.LAST
      LOOP

        get_issued_instances(
          p_wip_entity_id     => p_txn_ref.wip_entity_id,
          p_organization_id   => p_txn_ref.organization_id,
          p_inventory_item_id => l_requirements_tbl(l_ind).inventory_item_id,
          p_serial_number     => fnd_api.g_miss_char,
          x_instance_tbl      => l_issued_instances,
          x_return_status     => l_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('Issued Instances Count: '||l_issued_instances.COUNT);

        IF l_issued_instances.COUNT > 0 THEN

          SELECT serial_number_control_code
          INTO   l_comp_serial_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = l_requirements_tbl(l_ind).inventory_item_id
          AND    organization_id   = p_txn_ref.organization_id;

          -- only for non serial
          IF l_comp_serial_code in (1, 6) THEN

            IF l_requirements_tbl(l_ind).quantity_per_assy > 0 THEN

              split_instances_using_ratio(
                p_qty_ratio           => l_requirements_tbl(l_ind).quantity_per_assy,
                p_qty_completed       => p_txn_ref.wip_completed_quantity,
                p_organization_id     => p_txn_ref.organization_id,
                p_issued_instances    => l_issued_instances,
                px_csi_txn_rec        => px_csi_txn_rec,
                x_splitted_instances  => l_splitted_instances,
                x_return_status       => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            ELSE

              IF l_auto_allocate = 'Y' OR p_txn_ref.wip_start_quantity = 1 THEN

                IF p_txn_ref.wip_start_quantity > 1 THEN
                  split_issued_instances(
                    p_organization_id     => p_txn_ref.organization_id,
                    p_job_quantity        => p_txn_ref.wip_start_quantity,
                    p_completion_quantity => p_txn_ref.wip_completed_quantity,
                    px_issued_instances   => l_issued_instances,
                    px_csi_txn_rec        => px_csi_txn_rec,
                    x_splitted_instances  => l_splitted_instances,
                    x_return_status       => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;
                ELSE
                  l_splitted_instances := l_issued_instances;
                END IF;
              END IF;

            END IF;

            debug('Splitted Instance Count: '||l_splitted_instances.COUNT);

            apportion_always(
              p_assembly_instances  => l_assembly_instances,
              p_splitted_instances  => l_splitted_instances,
              p_job_quantity        => p_txn_ref.wip_start_quantity,
              p_comp_serial_code    => l_comp_serial_code,
              x_assy_comp_map_tbl   => l_assy_comp_map_tbl,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          ELSE

            get_genealogy_children(
              px_assembly_instances  => l_assembly_instances,
              x_assy_comp_map_tbl    => l_assy_comp_map_tbl,
              x_return_status        => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_auto_allocate = 'Y' OR p_txn_ref.wip_start_quantity = 1 THEN

              IF l_requirements_tbl(l_ind).quantity_per_assy = 0 THEN
                l_requirements_flag := 'N';
              ELSE
                l_requirements_flag := 'Y';
              END IF;

              apportion_serialized(
                p_context              => 'COMPLETION',
                p_requirements_flag    => l_requirements_flag,
                p_qty_per_assy         => l_requirements_tbl(l_ind).quantity_per_assy,
                p_total_qty_issued     => l_requirements_tbl(l_ind).issued_quantity,
                p_job_qty              => p_txn_ref.wip_start_quantity,
                p_component_item_id    => l_requirements_tbl(l_ind).inventory_item_id,
                p_assembly_instances   => l_assembly_instances,
                p_component_instances  => l_issued_instances,
                px_assy_comp_map_tbl   => l_assy_comp_map_tbl,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF;

          END IF;

          IF l_assy_comp_map_tbl.COUNT > 0 THEN

            dump_assy_comp_relation(
              p_assy_comp_map_tbl => l_assy_comp_map_tbl);

            create_assy_comp_relation(
              p_assy_comp_map_tbl   => l_assy_comp_map_tbl,
              px_csi_txn_rec        => px_csi_txn_rec,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

        ELSE
          debug('Could not find issued instances. Process continues without building relation.');
        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN end_process THEN
      x_return_status := fnd_api.g_ret_sts_success;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_discrete_rltn_at_wipac;

  PROCEDURE filter_assembly_instances(
    p_wip_entity_id            IN number,
    p_assembly_instances       IN csi_datastructures_pub.instance_tbl,
    p_component_item_id        IN number,
    p_quantity_ratio           IN number,
    x_filtered_assy_instances  OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status            OUT NOCOPY varchar2)
  IS

    CURSOR rltns_cur(p_parent_instance_id IN number) IS
      SELECT  cir.subject_id, cii.quantity
      FROM    csi_ii_relationships cir,
              csi_item_instances   cii
      WHERE   cir.object_id              = p_parent_instance_id
      AND     cir.relationship_type_code = 'COMPONENT-OF'
      AND     cii.instance_id            = cir.subject_id
      AND     cii.inventory_item_id      = p_component_item_id
      AND     cii.last_wip_job_id        = p_wip_entity_id;

    /*
      AND     cii.quantity               < p_quantity_ratio;
      AND     sysdate between nvl(cii.active_start_date, sysdate-1)
                      and     nvl(cii.active_end_date,   sysdate+1);
    */

    l_filtered_assy_instances  csi_datastructures_pub.instance_tbl;
    l_relation_found           boolean        := FALSE;
    l_return_status            varchar2(1)    := fnd_api.g_ret_sts_success;
    l_f_ind                    binary_integer := 0;

    l_comp_quantity            number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('filter_assembly_instances');

    IF p_assembly_instances.COUNT > 0 THEN

      FOR l_ind IN p_assembly_instances.FIRST .. p_assembly_instances.LAST
      LOOP

        l_comp_quantity  := 0;
        l_relation_found := FALSE;

        FOR rltns_rec IN rltns_cur(p_assembly_instances(l_ind).instance_id)
        LOOP
          l_comp_quantity := l_comp_quantity + rltns_rec.quantity;
        END LOOP;

        IF l_comp_quantity >= p_quantity_ratio THEN
          l_relation_found := TRUE;
        ELSE
          l_relation_found := FALSE;
        END IF;

        IF l_relation_found = FALSE THEN
          l_f_ind := l_f_ind + 1;
          l_filtered_assy_instances(l_f_ind) := p_assembly_instances(l_ind);
        END IF;

      END LOOP;
    END IF;

    debug('  Filtered instances count :'||l_filtered_assy_instances.COUNT);

    x_filtered_assy_instances := l_filtered_assy_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END filter_assembly_instances;

  PROCEDURE get_genealogy_parent(
    px_component_instances IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_assy_comp_map_tbl       OUT NOCOPY assy_comp_map_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_parent_item_id       number;
    l_parent_serial_number varchar2(80)   := null;

    l_parent_instance_id   number;

    l_return_status        varchar2(1)    := fnd_api.g_ret_sts_success;
    l_a_ind                binary_integer := 0;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_genealogy_parent');

    IF px_component_instances.COUNT > 0 THEN
      FOR l_ind IN px_component_instances.FIRST .. px_component_instances.LAST
      LOOP

        -- get genealogy parent
        get_parent_serial_number(
          p_child_item_id        => px_component_instances(l_ind).inventory_item_id,
          p_child_serial_number  => px_component_instances(l_ind).serial_number,
          x_parent_item_id       => l_parent_item_id,
          x_parent_serial_number => l_parent_serial_number,
          x_return_status        => l_return_status );

        IF l_parent_serial_number is not null THEN

          -- mark the comp instance as processed
          px_component_instances(l_ind).processed_flag := 'Y';

          BEGIN
            SELECT instance_id
            INTO   l_parent_instance_id
            FROM   csi_item_instances
            WHERE  inventory_item_id = l_parent_item_id
            AND    serial_number     = l_parent_serial_number
            AND    nvl(active_end_date,sysdate+1) > sysdate; --fix for bug 5393515

            debug('  Parent Instance ID :'||l_parent_instance_id);

            l_a_ind := l_a_ind + 1;
            x_assy_comp_map_tbl(l_a_ind).assy_instance_id := l_parent_instance_id;
            x_assy_comp_map_tbl(l_a_ind).comp_instance_id := px_component_instances(l_ind).instance_id;
            x_assy_comp_map_tbl(l_a_ind).comp_quantity    := 1;

          EXCEPTION
            WHEN no_data_found THEN
              null;
          END;
        ELSE
          px_component_instances(l_ind).processed_flag := 'N';
        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_genealogy_parent;

  PROCEDURE get_unprocessed_instances(
    px_component_instances IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_upc_instances        csi_datastructures_pub.instance_tbl;
    l_upc_ind              binary_integer := 0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_unprocessed_instances');

    IF px_component_instances.COUNT > 0 THEN

      FOR l_ind IN px_component_instances.FIRST .. px_component_instances.LAST
      LOOP
        IF px_component_instances(l_ind).processed_flag <> 'Y' THEN
          l_upc_ind := l_upc_ind + 1;
          l_upc_instances(l_upc_ind) := px_component_instances(l_ind);
        END IF;
      END LOOP;

    END IF;

    debug('  unprocessed component instances :'||l_upc_instances.count);

    px_component_instances := l_upc_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_unprocessed_instances;

  PROCEDURE build_discrete_rltn_at_wipci(
    p_txn_ref           IN            txn_ref,
    px_csi_txn_rec      IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_auto_allocate       varchar2(1);

    l_issued_instances    csi_datastructures_pub.instance_tbl;
    l_assembly_instances  csi_datastructures_pub.instance_tbl;
    l_splitted_instances  csi_datastructures_pub.instance_tbl;
    l_f_assy_instances    csi_datastructures_pub.instance_tbl;
    l_assy_comp_map_tbl   assy_comp_map_tbl;

    l_f_assy_count        number;
    l_qty_per_assy        number;
    l_total_qty_issued    number;

    process_no_relation   exception;
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_discrete_rltn_at_wipci');

    l_auto_allocate := csi_datastructures_pub.g_install_param_rec.auto_allocate_comp_at_wip;

    get_issued_instances(
      p_wip_entity_id     => p_txn_ref.wip_entity_id,
      p_organization_id   => p_txn_ref.organization_id,
      p_inventory_item_id => p_txn_ref.inventory_item_id,
      p_serial_number     => fnd_api.g_miss_char,
      x_instance_tbl      => l_issued_instances,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_issued_instances.COUNT > 0 THEN

      -- get all the completed assy instances no matter where they are.
      -- we will not be able to handle a case where the assembly instance has
      -- been issued to another wip job and completed we will loose the
      -- last_wip_job_id

      get_assembly_instances(
        p_wip_entity_id       => p_txn_ref.wip_entity_id,
        p_organization_id     => p_txn_ref.organization_id,
        p_assembly_item_id    => p_txn_ref.wip_assembly_item_id,
        p_completion_quantity => p_txn_ref.wip_completed_quantity,
        p_location_code       => 'ALL',
        x_instance_tbl        => l_assembly_instances,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_assembly_instances.COUNT > 0 THEN
        -- get the ratio of the issued inventory instance

        get_qty_per_assembly(
          p_organization_id      => p_txn_ref.organization_id,
          p_wip_entity_id        => p_txn_ref.wip_entity_id,
          p_component_item_id    => p_txn_ref.inventory_item_id,
          x_qty_per_assembly     => l_qty_per_assy,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF nvl(l_qty_per_assy,0) > 0 THEN

          IF p_txn_ref.srl_control_code in (1,6) THEN

            -- filter assembly instances and figure out instances that can be used as
            -- candidates to build relations, means elliminate the ones for which relation
            -- has been build already by one of the partially issued component for completed
            -- assembly

            filter_assembly_instances(
              p_wip_entity_id            => p_txn_ref.wip_entity_id,
              p_assembly_instances       => l_assembly_instances,
              p_component_item_id        => p_txn_ref.inventory_item_id,
              p_quantity_ratio           => l_qty_per_assy,
              x_filtered_assy_instances  => l_f_assy_instances,
              x_return_status            => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            l_f_assy_count := l_f_assy_instances.COUNT;

            IF l_f_assy_instances.COUNT > 0 THEN

              apportion_non_serialized(
                p_context              => 'ISSUE',
                p_requirements_flag    => 'Y',
                p_qty_per_assy         => l_qty_per_assy,
                p_qty_issued           => p_txn_ref.primary_quantity,
                p_total_qty_issued     => null,
                p_job_qty              => null,
                p_organization_id      => p_txn_ref.organization_id,
                p_assembly_instances   => l_f_assy_instances,
                p_component_instances  => l_issued_instances,
                px_csi_txn_rec         => px_csi_txn_rec,
                x_assy_comp_map_tbl    => l_assy_comp_map_tbl,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF;

          ELSE -- serialized case

            -- we have to do these components in two parses
            -- parse I
            --   read genealogy parent and populate assy_comp_map table
            --
            -- parse II -- do this phase only if the auto_allocate = 'Y'
            --   for all the queried asssy instances check if they are
            --   allocated quantities for the ratio.

            get_genealogy_parent(
              px_component_instances => l_issued_instances,
              x_assy_comp_map_tbl    => l_assy_comp_map_tbl,
              x_return_status        => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            -- II
            IF l_auto_allocate = 'Y' OR p_txn_ref.wip_start_quantity = 1 THEN

              -- work with the remaining component instances as to allocate them in
              -- the ratio.
              get_unprocessed_instances(
                px_component_instances => l_issued_instances,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              apportion_serialized(
                p_context              => 'ISSUE',
                p_requirements_flag    => 'Y',
                p_qty_per_assy         => l_qty_per_assy,
                p_total_qty_issued     => null,
                p_job_qty              => null,
                p_component_item_id    => p_txn_ref.inventory_item_id,
                p_assembly_instances   => l_assembly_instances,
                p_component_instances  => l_issued_instances,
                px_assy_comp_map_tbl   => l_assy_comp_map_tbl,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF;
          END IF;

        ELSE

          debug('No Requirements case...!');

          -- the question is do you want to apportion the total issued quantity
          -- with the total completed assembly. who knows there may be more
          -- component issues comming on the way. allocation here is way difficult

          IF l_auto_allocate = 'Y' OR p_txn_ref.wip_start_quantity = 1 THEN

            -- get the total quantity issued from the requirements
            SELECT sum(nvl(quantity_issued,0))
            INTO   l_total_qty_issued
            FROM   wip_requirement_operations
            WHERE  wip_entity_id     = p_txn_ref.wip_entity_id
            AND    organization_id   = p_txn_ref.organization_id
            AND    inventory_item_id = p_txn_ref.inventory_item_id;

            IF p_txn_ref.srl_control_code in (1,6) THEN

              apportion_non_serialized(
                p_context              => 'ISSUE',
                p_requirements_flag    => 'N',
                p_qty_per_assy         => l_qty_per_assy,
                p_qty_issued           => p_txn_ref.primary_quantity,
                p_total_qty_issued     => l_total_qty_issued,
                p_job_qty              => p_txn_ref.wip_start_quantity,
                p_organization_id      => p_txn_ref.organization_id,
                p_assembly_instances   => l_assembly_instances,
                p_component_instances  => l_issued_instances,
                px_csi_txn_rec         => px_csi_txn_rec,
                x_assy_comp_map_tbl    => l_assy_comp_map_tbl,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            ELSE

              get_genealogy_parent(
                px_component_instances => l_issued_instances,
                x_assy_comp_map_tbl    => l_assy_comp_map_tbl,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              get_unprocessed_instances(
                px_component_instances => l_issued_instances,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              apportion_serialized(
                p_context              => 'ISSUE',
                p_requirements_flag    => 'N',
                p_qty_per_assy         => l_qty_per_assy,
                p_total_qty_issued     => l_total_qty_issued,
                p_job_qty              => p_txn_ref.wip_start_quantity,
                p_component_item_id    => p_txn_ref.inventory_item_id,
                p_assembly_instances   => l_assembly_instances,
                p_component_instances  => l_issued_instances,
                px_assy_comp_map_tbl   => l_assy_comp_map_tbl,
                x_return_status        => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END IF;

          ELSE
            debug('Process cannot continue. Cannot derive the quantity per assembly.');
            RAISE process_no_relation;
          END IF;

        END IF;

        IF l_assy_comp_map_tbl.COUNT > 0 THEN

          dump_assy_comp_relation(
            p_assy_comp_map_tbl => l_assy_comp_map_tbl);

          create_assy_comp_relation(
            p_assy_comp_map_tbl   => l_assy_comp_map_tbl,
            px_csi_txn_rec        => px_csi_txn_rec,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END IF; -- assembly_instances.count > 0

    END IF; -- issued_instances.count > 0

  EXCEPTION
    WHEN process_no_relation THEN
      null;
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_discrete_rltn_at_wipci;


  PROCEDURE build_wo_less_rltn_at_wipac(
    p_mtl_txn_id         IN  number,
    p_wip_entity_id      IN  number,
    p_organization_id    IN  number,
    p_qty_completed      IN  number,
    p_assembly_instances IN  csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_assembly_instances    csi_datastructures_pub.instance_tbl;
    l_issued_instances      csi_datastructures_pub.instance_tbl;
    l_splitted_instances    csi_datastructures_pub.instance_tbl;
    l_assy_comp_map_tbl     assy_comp_map_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_comp_serial_code      number;
    l_qty_ratio             number;
    l_comp_item             varchar2(80);

    CURSOR issue_cur IS
      SELECT inventory_item_id,
             sum(abs(primary_quantity)) qty_issued
      FROM   mtl_material_transactions
      WHERE  transaction_action_id      = 1
      AND    transaction_source_type_id = 5
      AND    transaction_source_id      = p_wip_entity_id
      GROUP BY inventory_item_id;

  BEGIN

    api_log('build_wo_less_rltn_at_wipac');

    x_return_status := fnd_api.g_ret_sts_success;

    l_assembly_instances := p_assembly_instances;

    FOR issue_rec IN issue_cur
    LOOP


      SELECT serial_number_control_code ,
             segment1
      INTO   l_comp_serial_code,
             l_comp_item
      FROM   mtl_system_items
      WHERE  inventory_item_id = issue_rec.inventory_item_id
      AND    organization_id   = p_organization_id;

      debug('  Component Item :'||l_comp_item||' - '||issue_rec.inventory_item_id);

      -- get ratio
      debug('Derive Assembly Component Ratio :');
      debug('  Quantity Issued    :'||issue_rec.qty_issued);
      debug('  Quantity Completed :'||p_qty_completed);

      BEGIN
        l_qty_ratio := issue_rec.qty_issued / p_qty_completed;
      EXCEPTION
        WHEN zero_divide THEN
          l_qty_ratio := 0;
          --seed message appropriately
      END;

      debug('  Quantity Ratio     :'||l_qty_ratio);

      -- get issued instances
      get_issued_instances(
        p_wip_entity_id     => p_wip_entity_id,
        p_organization_id   => p_organization_id,
        p_inventory_item_id => issue_rec.inventory_item_id,
        p_serial_number     => fnd_api.g_miss_char,
        x_instance_tbl      => l_issued_instances,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      --fix for bug 4941800:IF condition added to ensure relationship
      --not build if issued instance count = 0
      IF l_issued_instances.COUNT > 0 THEN

      IF l_comp_serial_code in (1, 6) THEN

        IF p_qty_completed > 1 THEN
          IF l_issued_instances.COUNT > 0 THEN

            split_issued_instances(
              p_organization_id     => p_organization_id,
              p_job_quantity        => p_qty_completed,
              p_completion_quantity => p_qty_completed,
              px_issued_instances   => l_issued_instances,
              px_csi_txn_rec        => px_csi_txn_rec,
              x_splitted_instances  => l_splitted_instances,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;
        ELSE
          l_splitted_instances := l_issued_instances;
        END IF;

      ELSE
        l_splitted_instances := l_issued_instances;
      END IF;

      -- apportion
      apportion_always(
        p_assembly_instances  => l_assembly_instances,
        p_splitted_instances  => l_splitted_instances,
        p_job_quantity        => p_qty_completed,
        p_comp_serial_code    => l_comp_serial_code,
        x_assy_comp_map_tbl   => l_assy_comp_map_tbl,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      dump_assy_comp_relation(
        p_assy_comp_map_tbl => l_assy_comp_map_tbl);

      create_assy_comp_relation(
        p_assy_comp_map_tbl   => l_assy_comp_map_tbl,
        px_csi_txn_rec        => px_csi_txn_rec,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      ELSE	--Fix for bug 4941800
	debug('Could not find issued instances. Process continues without building relation.');
      END IF;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_wo_less_rltn_at_wipac;


  PROCEDURE build_wo_less_rltn_at_wipci(
    p_txn_ref           IN  txn_ref,
    p_qty_completed     IN  number,
    p_issued_instances  IN  csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec      IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_assembly_instances    csi_datastructures_pub.instance_tbl;
    l_f_assy_instances      csi_datastructures_pub.instance_tbl; --included for bug 5395829
    l_issued_instances      csi_datastructures_pub.instance_tbl;
    l_splitted_instances    csi_datastructures_pub.instance_tbl;
    l_assy_comp_map_tbl     assy_comp_map_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_comp_serial_code      number;
    l_qty_ratio             number;

    CURSOR issue_cur IS
      SELECT inventory_item_id,
             sum(abs(primary_quantity)) qty_issued
      FROM   mtl_material_transactions
      WHERE  transaction_action_id      = 1
      AND    transaction_source_type_id = 5
      AND    transaction_source_id      = p_txn_ref.wip_entity_id
      GROUP BY inventory_item_id;

  BEGIN

    api_log('build_wo_less_rltn_at_wipci');

    x_return_status := fnd_api.g_ret_sts_success;

    -- get assy instances
    get_assembly_instances(
      p_wip_entity_id       => p_txn_ref.wip_entity_id,
      p_organization_id     => p_txn_ref.organization_id,
      p_assembly_item_id    => p_txn_ref.wip_assembly_item_id,
      p_completion_quantity => p_qty_completed,
      p_location_code       => 'INVENTORY',
      x_instance_tbl        => l_assembly_instances,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_assembly_instances.COUNT > 0 THEN

      -- get ratio
      debug('Derive Assembly Component Ratio :');
      debug('  Quantity Issued    :'||p_txn_ref.primary_quantity);
      debug('  Quantity Completed :'||p_qty_completed);

      BEGIN
        l_qty_ratio := p_txn_ref.primary_quantity / p_qty_completed;
      EXCEPTION
        WHEN zero_divide THEN
          l_qty_ratio := 0;
      END;

      debug('  Quantity Ratio     :'||l_qty_ratio);

      --fix for bug 5395829:Included to filter out assemblies which are already
      --in relationship with child instances as per bom ratio
      filter_assembly_instances(
              p_wip_entity_id            => p_txn_ref.wip_entity_id,
              p_assembly_instances       => l_assembly_instances,
              p_component_item_id        => p_txn_ref.inventory_item_id,
              p_quantity_ratio           => l_qty_ratio,
              x_filtered_assy_instances  => l_f_assy_instances,
              x_return_status            => l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      --end of fix 5395829

      l_issued_instances := p_issued_instances;

      IF l_issued_instances.COUNT > 0 THEN
        IF p_qty_completed > 1 THEN
          IF p_txn_ref.srl_control_code in (1, 6) THEN
            split_issued_instances(
              p_organization_id     => p_txn_ref.organization_id,
              p_job_quantity        => p_qty_completed,
              p_completion_quantity => p_qty_completed,
              px_issued_instances   => l_issued_instances,
              px_csi_txn_rec        => px_csi_txn_rec,
              x_splitted_instances  => l_splitted_instances,
              x_return_status       => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            l_splitted_instances := l_issued_instances;
          END IF;
        ELSE
          l_splitted_instances := l_issued_instances;
        END IF;

        -- apportion splitted instances
        apportion_always(
          p_assembly_instances  => l_f_assy_instances,
          p_splitted_instances  => l_splitted_instances,
          p_job_quantity        => p_qty_completed,
          p_comp_serial_code    => l_comp_serial_code,
          x_assy_comp_map_tbl   => l_assy_comp_map_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        dump_assy_comp_relation(
          p_assy_comp_map_tbl => l_assy_comp_map_tbl);

        create_assy_comp_relation(
          p_assy_comp_map_tbl   => l_assy_comp_map_tbl,
          px_csi_txn_rec        => px_csi_txn_rec,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF; -- issued_instances.count > 0

    END IF; -- assy_instances.count > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_wo_less_rltn_at_wipci;


  PROCEDURE check_mtl_txn_in_csi(
    p_transaction_id   IN  number,
    x_txn_found        OUT NOCOPY boolean,
    x_return_status    OUT NOCOPY varchar2)
  IS

    CURSOR csi_txn_cur IS
      SELECT transaction_id
      FROM   csi_transactions
      WHERE  inv_material_transaction_id = p_transaction_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    x_txn_found := FALSE;

    FOR csi_txn_rec IN csi_txn_cur
    LOOP
      x_txn_found := TRUE;
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_mtl_txn_in_csi;

  PROCEDURE check_prior_wip_txns_in_csi(
    p_mtl_creation_date IN date,
    p_transaction_id    IN  number,
    p_wip_entity_id     IN  number,
    x_return_status     OUT NOCOPY varchar2)
  IS

    CURSOR mtl_txn_cur(p_migration_date IN date) IS
      SELECT transaction_id
      FROM   mtl_system_items  msi,
             mtl_material_transactions mmt
      WHERE  mmt.transaction_source_type_id = 5  -- job/schedule transactions
      AND    mmt.transaction_source_id   = p_wip_entity_id
      AND    mmt.transaction_action_id  in (1, 27, 31, 32, 33, 34) -- ib handled wip actions
      AND    mmt.creation_date           < p_mtl_creation_date
      AND    mmt.transaction_date        > p_migration_date
      AND    msi.organization_id         = mmt.organization_id
      AND    msi.inventory_item_id       = mmt.inventory_item_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y';

    l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
    l_processed_flag  boolean     := TRUE;
    l_migration_date  date;

  BEGIN
    api_log('check_prior_wip_txns_in_csi');

    x_return_status := fnd_api.g_ret_sts_success;

    l_migration_date := csi_datastructures_pub.g_install_param_rec.freeze_date;

    debug('  migration_date :'||l_migration_date);

    FOR mtl_txn_rec IN mtl_txn_cur(l_migration_date)
    LOOP

      check_mtl_txn_in_csi(
        p_transaction_id  => mtl_txn_rec.transaction_id,
        x_txn_found       => l_processed_flag,
        x_return_status   => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF NOT( l_processed_flag ) THEN

        fnd_message.set_name('CSI', 'CSI_WIP_PRIOR_TXN_FAILED');
        fnd_message.set_token('WIP_ENTITY_ID', p_wip_entity_id);
        fnd_message.set_token('MTL_TXN_ID', mtl_txn_rec.transaction_id);

        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_prior_wip_txns_in_csi;


  PROCEDURE get_order_of_processing(
    p_context           IN  varchar2,
    p_mtl_txn_id        IN  number,
    p_wip_entity_id     IN  number,
    x_order_of_process  OUT NOCOPY varchar2,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_qty_completed    number;

    l_issues_found     boolean := FALSE;
    l_completion_found boolean := FALSE;
    l_csi_txn_found    varchar2(1) := 'N';

    CURSOR issue_cur(pc_wip_entity_id in number) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_source_type_id = 5
      AND    transaction_action_id    in (1, 34)
      AND    transaction_source_id      = pc_wip_entity_id;

    CURSOR compl_cur(pc_wip_entity_id in number) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_action_id      = 31
      AND    transaction_source_type_id = 5
      AND    transaction_source_id      = pc_wip_entity_id;

  BEGIN

    api_log('get_order_of_processing');
    x_return_status := fnd_api.g_ret_sts_success;
    debug('  Context          :'||p_context);
    IF p_context = 'ISSUE' THEN
      l_completion_found := FALSE;
      l_csi_txn_found    := 'N';
      FOR compl_rec in compl_cur(p_wip_entity_id)
      LOOP
        -- also check if the txn is in csi_transaction
        BEGIN
          SELECT 'Y'
          INTO   l_csi_txn_found
          FROM   sys.dual
          WHERE  exists (
            SELECT 'X' FROM csi_transactions
            WHERE inv_material_transaction_id = compl_rec.transaction_id);
          l_completion_found := TRUE;
        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;
      END LOOP;

      IF l_completion_found THEN
        x_order_of_process := 'ISSUE_AFTER_COMPLETION';
      ELSE
        x_order_of_process := 'ISSUE_FIRST';
      END IF;

    ELSIF p_context = 'COMPLETION' THEN
      l_issues_found := FALSE;

      FOR issue_rec in issue_cur(p_wip_entity_id)
      LOOP
        -- also check if the txn is in csi_transaction
        BEGIN
          SELECT 'Y'
          INTO   l_csi_txn_found
          FROM   sys.dual
          WHERE  exists (
            SELECT 'X' FROM csi_transactions
            WHERE inv_material_transaction_id = issue_rec.transaction_id);
          l_issues_found := TRUE;
        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;
      END LOOP;

      IF l_issues_found THEN
        x_order_of_process := 'COMPLETION_AFTER_ISSUE';
      ELSE
        x_order_of_process := 'COMPLETION_FIRST';
      END IF;
    END IF;

    debug('  Processing Order :'||x_order_of_process);
  EXCEPTION
    when fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_order_of_processing;


  /* process relationships at the time of WIP assembly completion */
  PROCEDURE process_relation_at_wipac(
    p_txn_ref            IN            txn_ref,
    p_assembly_instances IN            csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_context            CONSTANT char(10)  := 'COMPLETION';

    l_organization_id    number;
    l_qty_completed      number;
    l_job_qty            number;
    l_wip_entity_id      number;

    l_assy_item_id       number;
    l_assy_serial_code   number;

    l_order_of_process   varchar2(30);

    l_auto_allocate      varchar2(1);
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
    process_no_relation  exception;

  BEGIN

    x_return_status := l_return_status;

    api_log('process_relation_at_wipac');

    l_auto_allocate :=  csi_datastructures_pub.g_install_param_rec.auto_allocate_comp_at_wip;

    IF p_txn_ref.srl_control_code  in (1, 6) THEN
      debug('no relationship processing for non serial assemblies.');
      RAISE process_no_relation;
    ELSE

      get_order_of_processing(
        p_context           => l_context,
        p_mtl_txn_id        => p_txn_ref.transaction_id,
        p_wip_entity_id     => p_txn_ref.wip_entity_id,
        x_order_of_process  => l_order_of_process,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      IF l_order_of_process = 'COMPLETION_FIRST' THEN
        -- completion is the very first txn for this job. issues are not made yet.
        RAISE process_no_relation;
      ELSIF l_order_of_process = 'COMPLETION_AFTER_ISSUE' THEN
        --we have to work with building relations here

        check_prior_wip_txns_in_csi(
          p_mtl_creation_date => p_txn_ref.creation_date,
          p_transaction_id    => p_txn_ref.transaction_id,
          p_wip_entity_id     => p_txn_ref.wip_entity_id,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        -- work order less completion -- entity type = 4 (flow schedules)
        IF p_txn_ref.wip_entity_type = 4 THEN

          build_wo_less_rltn_at_wipac(
            p_mtl_txn_id         => p_txn_ref.transaction_id,
            p_wip_entity_id      => p_txn_ref.wip_entity_id,
            p_organization_id    => p_txn_ref.organization_id,
            p_qty_completed      => p_txn_ref.wip_completed_quantity,
            p_assembly_instances => p_assembly_instances,
            px_csi_txn_rec       => px_csi_txn_rec,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE -- wip_entity_type <> 4

          IF p_txn_ref.wip_entity_type in (1, 3) THEN

            build_discrete_rltn_at_wipac(
              p_txn_ref             => p_txn_ref,
              p_assembly_instances  => p_assembly_instances,
              px_csi_txn_rec        => px_csi_txn_rec,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          ELSE
            debug('no relationship processing for wip_entity_type : '||p_txn_ref.wip_entity_type);
            RAISE process_no_relation;
          END IF;

        END IF; -- wip entity check

      END IF; -- order of processing

    END IF; -- serial non serial check

    debug('assembly component configuration process successful');

  EXCEPTION
    WHEN process_no_relation THEN
      null;
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END process_relation_at_wipac;

  PROCEDURE process_relation_at_wipci(
    p_txn_ref             IN            txn_ref,
    p_component_instances IN            csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_context              CONSTANT char(5) := 'ISSUE';
    l_order_of_process     varchar2(30);

    l_assy_serial_code     number;
    l_qty_completed        number;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

    process_no_relation    exception;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('process_relation_at_wipci');

    IF nvl(p_txn_ref.wip_assembly_item_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      debug('no relationship processing for repair jobs without assembly.');
      RAISE process_no_relation;
    END IF;

    IF p_txn_ref.inventory_item_id = p_txn_ref.wip_assembly_item_id THEN
      debug('no relationship processing when assembly is issued as a component.');
      RAISE process_no_relation;
    END IF;

    SELECT serial_number_control_code
    INTO   l_assy_serial_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_txn_ref.wip_assembly_item_id
    AND    organization_id   = p_txn_ref.organization_id;

    IF l_assy_serial_code in (1, 6) THEN -- non serial assembly
      debug('no relationship processing for non serial assemblies.');
      RAISE process_no_relation;
    ELSE -- serialized assemblies

      get_order_of_processing(
        p_context           => l_context,
        p_mtl_txn_id        => p_txn_ref.transaction_id,
        p_wip_entity_id     => p_txn_ref.wip_entity_id,
        x_order_of_process  => l_order_of_process,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;


      IF l_order_of_process = 'ISSUE_FIRST' THEN
        -- issue transaction is happening before completion  so, do nothing
        RAISE process_no_relation;
      ELSIF l_order_of_process = 'ISSUE_AFTER_COMPLETION' THEN

        IF p_txn_ref.wip_entity_type = 4 THEN  -- wo less completions

          SELECT nvl(mmt_assem.primary_quantity,0)
          INTO   l_qty_completed
          FROM   mtl_material_transactions mmt_assem,
	         mtl_material_transactions mmt_comp
          WHERE  mmt_assem.transaction_action_id      = 31
          AND    mmt_assem.transaction_source_type_id = 5
          AND    mmt_comp.transaction_source_id      = p_txn_ref.wip_entity_id
	  AND    mmt_comp.transaction_id             = p_txn_ref.transaction_id
	  AND    mmt_comp.completion_transaction_id  = mmt_assem.completion_transaction_id; --5225921

          debug('  quantity_completed: '||l_qty_completed);

          build_wo_less_rltn_at_wipci(
            p_txn_ref           => p_txn_ref,
            p_qty_completed     => l_qty_completed,
            p_issued_instances  => p_component_instances,
            px_csi_txn_rec      => px_csi_txn_rec,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE  -- wip_entity_type <> 4

          IF p_txn_ref.wip_entity_type in (1, 3) THEN -- discrete jobs

            build_discrete_rltn_at_wipci(
              p_txn_ref        => p_txn_ref,
              px_csi_txn_rec   => px_csi_txn_rec,
              x_return_status  => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          ELSE
            debug('not handling relationship for wip_entity_type : '||p_txn_ref.wip_entity_type);
            RAISE process_no_relation;
          END IF;

        END IF; -- seperate WO less completions

      END IF; -- check if ISSUE after completion

    END IF; -- check for serialized assembly

    debug('assembly component configuration process successful.');

  EXCEPTION
    WHEN process_no_relation THEN
      null;
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
     WHEN OTHERS THEN
     null;
  END process_relation_at_wipci;

  PROCEDURE bld_inst_tables_for_issue(
    p_txn_ref             IN            txn_ref,
    p_mmt_rec             IN            mmt_rec,
    x_dest_loc_rec           OUT nocopy csi_process_txn_grp.dest_location_rec,
    x_instances_tbl          OUT nocopy csi_process_txn_grp.txn_instances_tbl,
    x_parties_tbl            OUT nocopy csi_process_txn_grp.txn_i_parties_tbl,
    x_org_units_tbl          OUT nocopy csi_process_txn_grp.txn_org_units_tbl,
    x_return_status          OUT nocopy varchar2)
  IS
    l_int_party_id  number;
    l_wip_loc_id    number;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('bld_inst_tables_for_issue');

    l_int_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
   -- l_wip_loc_id   := csi_datastructures_pub.g_install_param_rec.wip_location_id;

    -- build destination location attribs
    x_dest_loc_rec.location_type_code             := 'WIP';
    x_dest_loc_rec.location_id                    := nvl(p_mmt_rec.subinv_location_id,p_mmt_rec.hr_location_id); --5277935
    x_dest_loc_rec.wip_job_id                     := p_txn_ref.wip_entity_id;
    x_dest_loc_rec.instance_usage_code            := 'IN_WIP';
    x_dest_loc_rec.last_wip_job_id                := null; --bug 5376024

    x_dest_loc_rec.inv_organization_id            := fnd_api.g_miss_num;
    x_dest_loc_rec.inv_subinventory_name          := fnd_api.g_miss_char;
    x_dest_loc_rec.inv_locator_id                 := fnd_api.g_miss_num;
    x_dest_loc_rec.pa_project_id                  := fnd_api.g_miss_num;
    x_dest_loc_rec.pa_project_task_id             := fnd_api.g_miss_num;
    x_dest_loc_rec.in_transit_order_line_id       := fnd_api.g_miss_num;
    x_dest_loc_rec.po_order_line_id               := fnd_api.g_miss_num;

    -- build instances
    x_instances_tbl(1).ib_txn_segment_flag        := 'S';
    x_instances_tbl(1).inventory_item_id          := p_mmt_rec.inventory_item_id;
    x_instances_tbl(1).inventory_revision         := p_mmt_rec.revision;
    x_instances_tbl(1).vld_organization_id        := p_mmt_rec.organization_id;
    x_instances_tbl(1).inv_master_organization_id := p_txn_ref.master_organization_id;
    x_instances_tbl(1).serial_number              := p_mmt_rec.serial_number;

    IF nvl(x_instances_tbl(1).serial_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      x_instances_tbl(1).mfg_serial_number_flag   := 'Y';
    ELSE
      x_instances_tbl(1).mfg_serial_number_flag   := 'N';
    END IF;

    x_instances_tbl(1).lot_number                 := p_mmt_rec.lot_number;
    x_instances_tbl(1).quantity                   := abs(p_mmt_rec.instance_quantity);

    x_instances_tbl(1).unit_of_measure            := p_txn_ref.primary_uom_code;

    x_instances_tbl(1).location_type_code         := 'INVENTORY';
    x_instances_tbl(1).location_id                := p_mmt_rec.subinv_location_id;

    IF nvl(x_instances_tbl(1).location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      x_instances_tbl(1).location_id              := p_mmt_rec.hr_location_id;
    END IF;

    x_instances_tbl(1).inv_organization_id        := p_mmt_rec.organization_id;
    x_instances_tbl(1).inv_subinventory_name      := p_mmt_rec.subinventory_code;
    x_instances_tbl(1).inv_locator_id             := p_mmt_rec.locator_id;
    x_instances_tbl(1).instance_usage_code        := 'IN_INVENTORY';

    x_instances_tbl(1).active_start_date          := p_txn_ref.transaction_date;
    x_instances_tbl(1).customer_view_flag         := 'N';
    x_instances_tbl(1).merchant_view_flag         := 'Y';
    x_instances_tbl(1).object_version_number      := 1.0;

    -- build parties
    IF p_txn_ref.srl_control_code in (1, 6) THEN
      x_parties_tbl(1).parent_tbl_index           := 1;
      x_parties_tbl(1).party_source_table         := 'HZ_PARTIES';
      x_parties_tbl(1).party_id                   := l_int_party_id;
      x_parties_tbl(1).relationship_type_code     := 'OWNER';
      x_parties_tbl(1).contact_flag               := 'N';
      x_parties_tbl(1).object_version_number      := 1.0;
    END IF;

  END bld_inst_tables_for_issue;

  PROCEDURE Delink_ReplaceRebuilds(
    p_wip_entity_id      IN     number,
    p_organization_id    IN     number,
    px_csi_txn_rec       IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_replace_rebuilds      OUT nocopy eam_utility_grp.replace_rebuild_tbl_type,
    x_return_status         OUT nocopy varchar2)
  IS
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);

    l_replace_rebuild_tbl    EAM_Utility_GRP.Replace_Rebuild_TBL_Type;
    l_entity_type            NUMBER := 0; --Added for bug 7363267
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('delink_replacerebuilds');

    SELECT  entity_type
    INTO    l_entity_type
    FROM    wip_entities
    WHERE   wip_entity_id = p_wip_entity_id
    AND     organization_id = p_organization_id;

   --Added if condition for bug 7363267,  EAM_Utility_Grp.Get_ReplacedRebuilds
   --is only suppose to be invoked for EAM work order
   IF (l_entity_type IN (6,7)) THEN
    debug('Inside API : eam_utility_grp.get_replacedrebuilds');

    EAM_Utility_Grp.Get_ReplacedRebuilds (
      p_api_version          => 1.0,
      p_commit               => fnd_api.g_false,
      p_validation_level     => fnd_api.g_valid_level_full,
      p_init_msg_list        => fnd_api.g_true,
      p_wip_entity_id        => p_wip_entity_id,
      p_organization_id      => p_organization_id,
      x_replaced_rebuild_tbl => l_replace_rebuild_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  replace_rebuild_tbl.count : '||l_replace_rebuild_tbl.COUNT);

    IF l_replace_rebuild_tbl.COUNT > 0 THEN
      FOR l_ind IN l_replace_rebuild_tbl.FIRST .. l_replace_rebuild_tbl.LAST
      LOOP

        csi_process_txn_pvt.check_and_break_relation(
          p_instance_id   => l_replace_rebuild_tbl(l_ind).instance_id,
          p_csi_txn_rec   => px_csi_txn_rec,
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END LOOP;
    END IF;
   END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END Delink_ReplaceRebuilds;

  PROCEDURE wip_issue(
    p_mmt_rec          IN     mtl_material_transactions%rowtype,
    px_csi_txn_rec     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_trx_error_rec   IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_api_name               varchar2(100):= 'csi_wip_trxs_pkg.wip_component_issue';
    l_txn_ref                txn_ref;
    l_mmt_tbl                mmt_tbl;

    l_in_out_flag            varchar2(30) := 'INT';
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;

    l_csi_txn_rec            csi_datastructures_pub.transaction_rec;

    l_c_dest_loc_rec         csi_process_txn_grp.dest_location_rec;
    l_c_instances_tbl        csi_process_txn_grp.txn_instances_tbl;
    l_c_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_c_org_units_tbl        csi_process_txn_grp.txn_org_units_tbl;

    l_api_success            varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);

    l_issued_instances       csi_datastructures_pub.instance_tbl;
    l_i_ind                  binary_integer := 0;

    l_error_rec              csi_datastructures_pub.transaction_error_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('wip_issue');

    l_error_rec    := px_trx_error_rec;
    l_csi_txn_rec  := px_csi_txn_rec;

    csi_wip_trxs_pkg.get_mmt_info(
      p_transaction_id => p_mmt_rec.transaction_id,
      x_txn_ref        => l_txn_ref,
      x_mmt_tbl        => l_mmt_tbl,
      x_return_status  => l_return_status);

    IF l_return_status <> l_api_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.source_header_ref        := l_txn_ref.wip_entity_name;
    l_error_rec.source_header_ref_id     := l_txn_ref.wip_entity_id;
    l_error_rec.inventory_item_id        := l_txn_ref.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_txn_ref.srl_control_code;
    l_error_rec.src_lot_ctrl_code        := l_txn_ref.lot_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_txn_ref.rev_control_code;
    l_error_rec.src_location_ctrl_code   := l_txn_ref.loc_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_txn_ref.ib_trackable_flag;

    IF l_mmt_tbl.COUNT > 0 THEN

      l_csi_txn_rec.source_header_ref       := l_txn_ref.wip_entity_name;
      l_csi_txn_rec.source_header_ref_id    := l_txn_ref.wip_entity_id;
      l_csi_txn_rec.source_transaction_date := l_txn_ref.transaction_date;
      l_csi_txn_rec.transaction_quantity    := l_txn_ref.primary_quantity;
      l_csi_txn_rec.transaction_uom_code    := l_txn_ref.primary_uom_code;
      l_csi_txn_rec.transaction_status_code := 'PENDING';

      FOR l_ind in l_mmt_tbl.FIRST .. l_mmt_tbl.LAST
      LOOP

        l_error_rec.serial_number := l_mmt_tbl(l_ind).serial_number;
        l_error_rec.lot_number    := l_mmt_tbl(l_ind).lot_number;

        bld_inst_tables_for_issue(
          p_txn_ref         => l_txn_ref,
          p_mmt_rec         => l_mmt_tbl(l_ind),
          x_dest_loc_rec    => l_c_dest_loc_rec,
          x_instances_tbl   => l_c_instances_tbl,
          x_parties_tbl     => l_c_parties_tbl,
          x_org_units_tbl   => l_c_org_units_tbl,
          x_return_status   => l_return_status);

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        csi_process_txn_grp.process_transaction(
          p_api_version             => 1.0,
          p_commit                  => fnd_api.g_false,
          p_init_msg_list           => fnd_api.g_false,
          p_validation_level        => fnd_api.g_valid_level_full,
          p_validate_only_flag      => fnd_api.g_false,
          p_in_out_flag             => l_in_out_flag, -- valid values are 'IN','OUT'
          p_dest_location_rec       => l_c_dest_loc_rec,
          p_txn_rec                 => l_csi_txn_rec,
          p_instances_tbl           => l_c_instances_tbl,
          p_i_parties_tbl           => l_c_parties_tbl,
          p_ip_accounts_tbl         => l_ip_accounts_tbl,
          p_org_units_tbl           => l_org_units_tbl,
          p_ext_attrib_vlaues_tbl   => l_ext_attrib_values_tbl,
          p_pricing_attribs_tbl     => l_pricing_attribs_tbl,
          p_instance_asset_tbl      => l_instance_asset_tbl,
          p_ii_relationships_tbl    => l_ii_relationships_tbl,
          px_txn_error_rec          => l_error_rec,
          x_return_status           => l_return_status,
          x_msg_count               => l_msg_count,
          x_msg_data                => l_msg_data );

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_c_instances_tbl.COUNT > 0 THEN
          FOR l_c_ind IN l_c_instances_tbl.FIRST .. l_c_instances_tbl.LAST
          LOOP

            l_i_ind := l_i_ind + 1;
            l_issued_instances(l_i_ind).instance_id   := l_c_instances_tbl(l_c_ind).new_instance_id;
            l_issued_instances(l_i_ind).serial_number := l_c_instances_tbl(l_c_ind).serial_number;
            l_issued_instances(l_i_ind).quantity      := l_c_instances_tbl(l_c_ind).quantity;

          END LOOP;
        END IF;

      END LOOP;

      /* 1 - EAM, 2 - AHL 0 - NULL */
	 --R12 Changes for OPM
      IF l_txn_ref.wip_maint_source_code <> 2 OR l_txn_ref.wip_entity_type <> 10 THEN
       process_relation_at_wipci(
          p_txn_ref             => l_txn_ref,
          p_component_instances => l_issued_instances,
          px_csi_txn_rec        => l_csi_txn_rec,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
  END wip_issue;

  PROCEDURE wip_comp_issue(
    p_transaction_id     IN            number,
    p_message_id         IN            number,
    px_trx_error_rec     IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status         OUT nocopy varchar2)
  IS

    l_mmt_rec            mtl_material_transactions%rowtype;
    l_csi_txn_rec        csi_datastructures_pub.transaction_rec;
    l_error_rec          csi_datastructures_pub.transaction_error_rec;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipci',
      p_file_segment2 => p_transaction_id);

    api_log('wip_comp_issue');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP Component Issue');
    debug('  Transaction ID    : '||p_transaction_id);

    csi_utility_grp.check_ib_active;

    savepoint wip_comp_issue;

    fnd_msg_pub.initialize;

    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec := px_trx_error_rec;

    l_error_rec.source_type                   := 'CSIWIPCI';
    l_error_rec.source_id                     := p_transaction_id;
    l_error_rec.transaction_type_id           := 71;
    l_error_rec.message_id                    := p_message_id;

    l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
    l_csi_txn_rec.transaction_date            := sysdate;
    l_csi_txn_rec.transaction_type_id         := 71;
    l_csi_txn_rec.txn_sub_type_id             := 3;
    l_csi_txn_rec.message_id                  := p_message_id;
    l_csi_txn_rec.inv_material_transaction_id := p_transaction_id;
    l_csi_txn_rec.object_version_number       := 1.0;


    SELECT * INTO l_mmt_rec
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_transaction_id;

    wip_issue(
      p_mmt_rec          => l_mmt_rec,
      px_csi_txn_rec     => l_csi_txn_rec,
      px_trx_error_rec   => l_error_rec,
      x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip component issue transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_comp_issue;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_comp_issue;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 540));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      debug('Error(O) :'||l_error_rec.error_text);
  END wip_comp_issue;

  PROCEDURE wip_assy_return(
    p_transaction_id     IN            number,
    p_message_id         IN            number,
    px_trx_error_rec     IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status         OUT nocopy varchar2)
  IS

    l_mmt_rec            mtl_material_transactions%rowtype;
    l_csi_txn_rec        csi_datastructures_pub.transaction_rec;
    l_error_rec          csi_datastructures_pub.transaction_error_rec;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipar',
      p_file_segment2 => p_transaction_id);

    api_log('wip_assy_return');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP Assembly Return');
    debug('  Transaction ID    : '||p_transaction_id);

    csi_utility_grp.check_ib_active;

    savepoint wip_assy_return;

    fnd_msg_pub.initialize;

    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec := px_trx_error_rec;

    l_error_rec.source_type                   := 'CSIWIPAR';
    l_error_rec.source_id                     := p_transaction_id;
    l_error_rec.transaction_type_id           := 74;
    l_error_rec.message_id                    := p_message_id;

    l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
    l_csi_txn_rec.transaction_date            := sysdate;
    l_csi_txn_rec.transaction_type_id         := 74;
    l_csi_txn_rec.txn_sub_type_id             := 3;
    l_csi_txn_rec.message_id                  := p_message_id;
    l_csi_txn_rec.inv_material_transaction_id := p_transaction_id;
    l_csi_txn_rec.object_version_number       := 1.0;


    SELECT * INTO l_mmt_rec
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_transaction_id;

    wip_issue(
      p_mmt_rec          => l_mmt_rec,
      px_csi_txn_rec     => l_csi_txn_rec,
      px_trx_error_rec   => l_error_rec,
      x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip assembly return transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_assy_return;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_assy_return;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 540));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      debug('Error(O) :'||l_error_rec.error_text);
  END wip_assy_return;


/* R12 Change for OPM*/

 PROCEDURE wip_byproduct_return(
    p_transaction_id     IN            number,
    p_message_id         IN            number,
    px_trx_error_rec     IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status         OUT nocopy varchar2)
  IS

    l_mmt_rec            mtl_material_transactions%rowtype;
    l_csi_txn_rec        csi_datastructures_pub.transaction_rec;
    l_error_rec          csi_datastructures_pub.transaction_error_rec;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipbr',
      p_file_segment2 => p_transaction_id);

    api_log('wip_byproduct_return');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP ByProduct Return');
    debug('  Transaction ID    : '||p_transaction_id);

    csi_utility_grp.check_ib_active;

    savepoint wip_byproduct_return;

    fnd_msg_pub.initialize;

    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec := px_trx_error_rec;

    l_error_rec.source_type                   := 'CSIWIPBR';
    l_error_rec.source_id                     := p_transaction_id;
    l_error_rec.transaction_type_id           := 76;
    l_error_rec.message_id                    := p_message_id;

    l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
    l_csi_txn_rec.transaction_date            := sysdate;
    l_csi_txn_rec.transaction_type_id         := 76;
    l_csi_txn_rec.txn_sub_type_id             := 3;
    l_csi_txn_rec.message_id                  := p_message_id;
    l_csi_txn_rec.inv_material_transaction_id := p_transaction_id;
    l_csi_txn_rec.object_version_number       := 1.0;


    SELECT * INTO l_mmt_rec
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_transaction_id;

    wip_issue(
      p_mmt_rec          => l_mmt_rec,
      px_csi_txn_rec     => l_csi_txn_rec,
      px_trx_error_rec   => l_error_rec,
      x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip by product return transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_byproduct_return;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_byproduct_return;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 540));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      debug('Error(O) :'||l_error_rec.error_text);
  END wip_byproduct_return;


  PROCEDURE wip_neg_comp_return(
    p_transaction_id     IN            number,
    p_message_id         IN            number,
    px_trx_error_rec     IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status         OUT nocopy varchar2)
  IS

    l_mmt_rec            mtl_material_transactions%rowtype;
    l_csi_txn_rec        csi_datastructures_pub.transaction_rec;
    l_error_rec          csi_datastructures_pub.transaction_error_rec;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipnr',
      p_file_segment2 => p_transaction_id);

    api_log('wip_neg_comp_return');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP Negative Component  Return');
    debug('  Transaction ID    : '||p_transaction_id);

    csi_utility_grp.check_ib_active;

    savepoint wip_neg_comp_return;

    fnd_msg_pub.initialize;

    --
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec := px_trx_error_rec;

    l_error_rec.source_type                   := 'CSIWIPNR';
    l_error_rec.source_id                     := p_transaction_id;
    l_error_rec.transaction_type_id           := 71;
    l_error_rec.message_id                    := p_message_id;

    l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
    l_csi_txn_rec.transaction_date            := sysdate;
    l_csi_txn_rec.transaction_type_id         := 71;
    l_csi_txn_rec.txn_sub_type_id             := 3;
    l_csi_txn_rec.message_id                  := p_message_id;
    l_csi_txn_rec.inv_material_transaction_id := p_transaction_id;
    l_csi_txn_rec.object_version_number       := 1.0;


    SELECT * INTO l_mmt_rec
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_transaction_id;

    wip_issue(
      p_mmt_rec          => l_mmt_rec,
      px_csi_txn_rec     => l_csi_txn_rec,
      px_trx_error_rec   => l_error_rec,
      x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip negative component return transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_neg_comp_return;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_neg_comp_return;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 540));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      debug('Error(O) :'||l_error_rec.error_text);
  END wip_neg_comp_return;

  PROCEDURE get_issued_serial_instance(
    px_instance_rec        IN OUT NOCOPY csi_process_txn_grp.txn_instance_rec,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_inst_query_rec       csi_datastructures_pub.instance_query_rec;
    l_party_query_rec      csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec   csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl     csi_datastructures_pub.instance_header_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_issued_serial_instance');

    -- look for a serialized instance in csi_item_instances
    -- if it is in customer location then

    l_inst_query_rec.inventory_item_id := px_instance_rec.inventory_item_id;
    l_inst_query_rec.serial_number     := px_instance_rec.serial_number;

    csi_item_instance_pub.get_item_instances(
      p_api_version          => 1.0,
      p_commit               => fnd_api.g_false,
      p_init_msg_list        => fnd_api.g_true,
      p_validation_level     => fnd_api.g_valid_level_full,
      p_instance_query_rec   => l_inst_query_rec,
      p_party_query_rec      => l_party_query_rec,
      p_account_query_rec    => l_pty_acct_query_rec,
      p_transaction_id       => NULL,
      p_resolve_id_columns   => fnd_api.g_false,
      p_active_instance_only => fnd_api.g_false,
      x_instance_header_tbl  => l_instance_hdr_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_instance_hdr_tbl.count = 0 THEN
      px_instance_rec.instance_id := fnd_api.g_miss_num;
    ELSE
      IF l_instance_hdr_tbl.count = 1 THEN
        px_instance_rec.instance_id := l_instance_hdr_tbl(1).instance_id;
      ELSE
        debug('Too many serialized source instances found. '||l_instance_hdr_tbl.count);
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_issued_serial_instance;

  -- handle only the return of WIP instances
  -- after the relations are build you could have multiple
  -- instances if it is allocated to a multiple quantity job
  /* the correct way to do this code here is to look for a WIP instance
     first that is issued out excessly
     then go and knock the ones in order for the components that are
     already tied up in relations.
  */

  PROCEDURE get_instances(
    p_instance_query_rec   IN csi_datastructures_pub.instance_query_rec,
    x_instance_tbl         OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_party_query_rec      csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec   csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl     csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl         csi_datastructures_pub.instance_tbl;


    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN

    csi_t_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec);

    api_log(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'get_item_instances');

    csi_item_instance_pub.get_item_instances(
      p_api_version          => 1.0,
      p_commit               => fnd_api.g_false,
      p_init_msg_list        => fnd_api.g_true,
      p_validation_level     => fnd_api.g_valid_level_full,
      p_instance_query_rec   => p_instance_query_rec,
      p_party_query_rec      => l_party_query_rec,
      p_account_query_rec    => l_pty_acct_query_rec,
      p_transaction_id       => null,
      p_resolve_id_columns   => fnd_api.g_false,
      p_active_instance_only => fnd_api.g_true,
      x_instance_header_tbl  => l_instance_hdr_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_instance_hdr_tbl.COUNT > 0 THEN
      csi_utl_pkg.make_non_header_tbl(
        p_instance_header_tbl => l_instance_hdr_tbl,
        x_instance_tbl        => l_instance_tbl,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_instance_tbl := l_instance_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_instances;


  PROCEDURE get_issued_in_wip_instance(
    p_wip_entity_id        IN number,
    p_component_item_id    IN number,
    p_organization_id      IN number,
    p_lot_number           IN varchar2,
    x_instance_tbl            OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_inst_query_rec       csi_datastructures_pub.instance_query_rec;
    l_inst_tbl             csi_datastructures_pub.instance_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_issued_in_wip_instance');

    -- first get the excess WIP instance that needs to be knocked off
    l_inst_query_rec.inventory_item_id  := p_component_item_id;
    l_inst_query_rec.wip_job_id         := p_wip_entity_id;
    l_inst_query_rec.lot_number         := p_lot_number;
    l_inst_query_rec.location_type_code := 'WIP';
    l_inst_query_rec.instance_usage_code:= 'IN_WIP';

    -- for a non serial item at WIP we should only hit one WIP instance
    get_instances(
      p_instance_query_rec   => l_inst_query_rec,
      x_instance_tbl         => l_inst_tbl,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('IN_WIP Instances COUNT :'||l_inst_tbl.COUNT);
    x_instance_tbl := l_inst_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_issued_in_wip_instance;


  PROCEDURE get_issued_in_inv_instances(
    p_wip_entity_id        IN number,
    p_component_item_id    IN number,
    p_organization_id      IN number,
    p_lot_number           IN varchar2,
    x_instance_tbl            OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_inst_query_rec       csi_datastructures_pub.instance_query_rec;
    l_inst_tbl             csi_datastructures_pub.instance_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_issued_in_inv_instances');

    l_inst_query_rec.inventory_item_id   := p_component_item_id;
    l_inst_query_rec.last_wip_job_id     := p_wip_entity_id;
    l_inst_query_rec.lot_number          := p_lot_number;
    l_inst_query_rec.instance_usage_code := 'IN_RELATIONSHIP';

    get_instances(
      p_instance_query_rec   => l_inst_query_rec,
      x_instance_tbl         => l_inst_tbl,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip in_relation instance count: '||l_inst_tbl.COUNT);

    IF l_inst_tbl.COUNT > 0 THEN
      FOR l_ind IN l_inst_tbl.FIRST .. l_inst_tbl.LAST
      LOOP
        BEGIN
          SELECT object_id
          INTO   l_inst_tbl(l_ind).attribute1
          FROM   csi_ii_relationships
          WHERE  subject_id = l_inst_tbl(l_ind).instance_id
          AND    relationship_type_code = 'COMPONENT-OF';
        EXCEPTION
          WHEN no_data_found THEN
            l_inst_tbl(l_ind).attribute1 := null;
        END;
      END LOOP;
    END IF;

    x_instance_tbl := l_inst_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_issued_in_inv_instances;


  PROCEDURE get_issued_in_rel_instances(
    p_wip_entity_id        IN number,
    p_component_item_id    IN number,
    p_organization_id      IN number,
    p_lot_number           IN varchar2,
    x_instance_tbl            OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_inst_query_rec       csi_datastructures_pub.instance_query_rec;
    l_inst_tbl             csi_datastructures_pub.instance_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_issued_in_rel_instances');

    l_inst_query_rec.inventory_item_id   := p_component_item_id;
    l_inst_query_rec.wip_job_id          := p_wip_entity_id;
    l_inst_query_rec.lot_number          := p_lot_number;
    l_inst_query_rec.instance_usage_code := 'IN_RELATIONSHIP';

    get_instances(
      p_instance_query_rec   => l_inst_query_rec,
      x_instance_tbl         => l_inst_tbl,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('repair in_relation instance count: '||l_inst_tbl.COUNT);
    x_instance_tbl := l_inst_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_issued_in_rel_instances;

  PROCEDURE deallocate_using_qty_per_assy(
    p_qty_returned         IN number,
    p_qty_per_assy         IN number,
    p_instances_tbl        IN csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_qty_remaining        IN OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2)
  IS

    TYPE da_rec IS RECORD(
      instance_id   number,
      quantity      number,
      new_quantity  number);

    TYPE da_tbl IS TABLE OF da_rec index by binary_integer;

    l_qty_remaining        number;
    l_qty_available        number;
    l_qty_dealloc          number;

    l_inst_tbl             csi_datastructures_pub.instance_tbl;
    l_ind                  binary_integer := 0;
    l_f_ind                binary_integer := 0;
    l_da_ind               binary_integer := 0;
    l_da_tbl               da_tbl;

    l_parent_instance_id   number;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('deallocate_using_qty_per_assy');

    l_inst_tbl := p_instances_tbl;

    l_qty_remaining := p_qty_returned;

    -- put logic
    IF l_inst_tbl.COUNT > 0 THEN
      l_ind := 0;
      LOOP

        l_ind := l_inst_tbl.NEXT(l_ind);
        EXIT when l_ind is null;

        l_parent_instance_id := l_inst_tbl(l_ind).attribute1;

        l_da_ind := l_da_ind + 1;
        l_da_tbl(l_da_ind).instance_id := l_inst_tbl(l_ind).instance_id;
        l_da_tbl(l_da_ind).quantity    := l_inst_tbl(l_ind).quantity;

        --filter_group
        l_f_ind := l_ind;
        LOOP
          l_f_ind := l_inst_tbl.NEXT(l_f_ind);
          EXIT when l_f_ind is null;

          IF l_inst_tbl(l_f_ind).attribute1 = l_parent_instance_id THEN
            l_da_ind := l_da_ind + 1;
            l_da_tbl(l_da_ind).instance_id := l_inst_tbl(l_f_ind).instance_id;
            l_da_tbl(l_da_ind).quantity    := l_inst_tbl(l_f_ind).quantity;
            l_inst_tbl.delete(l_f_ind);
          END IF;
        END LOOP;

        l_da_ind := 0;

        IF l_qty_remaining > 0 THEN

          IF l_qty_remaining < p_qty_per_assy THEN
            l_qty_available := l_qty_remaining;
          ELSE
            l_qty_available := p_qty_per_assy;
          END IF;

          IF l_da_tbl.COUNT > 0 THEN
            FOR l_t_ind IN l_da_tbl.FIRST .. l_da_tbl.LAST
            LOOP

              IF l_qty_available > 0 THEN

                IF l_da_tbl(l_t_ind).quantity >= l_qty_available THEN
                  l_qty_dealloc := l_qty_available;
                ELSE
                  l_qty_dealloc := l_da_tbl(l_t_ind).quantity;
                END IF;

                -- call decrement wip instance;
                decrement_wip_instance(
                  p_instance_id         => l_da_tbl(l_t_ind).instance_id,
                  p_quantity            => l_qty_dealloc,
                  px_csi_txn_rec        => px_csi_txn_rec,
                  x_return_status       => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                l_qty_available := l_qty_available - l_qty_dealloc;
                l_qty_remaining := l_qty_remaining - l_qty_dealloc;

              END IF;

            END LOOP;
          END IF;
        END IF;

      END LOOP;
    END IF;

    x_qty_remaining := l_qty_remaining;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END deallocate_using_qty_per_assy;


  PROCEDURE deallocate_wip_instances(
    p_wip_entity_id        IN number,
    p_component_item_id    IN number,
    p_organization_id      IN number,
    p_lot_number           IN varchar2,
    p_returned_quantity    IN number,
    p_auto_allocate        IN varchar2,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_qty_remaining        number;
    l_qty_to_dealloc       number;

    l_qty_per_assy         number;
    l_total_qty_issued     number;

    l_instance_tbl         csi_datastructures_pub.instance_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('deallocate_wip_instances');

    l_qty_remaining := p_returned_quantity;

    get_issued_in_wip_instance(
      p_wip_entity_id      => p_wip_entity_id,
      p_component_item_id  => p_component_item_id,
      p_organization_id    => p_organization_id,
      p_lot_number         => p_lot_number,
      x_instance_tbl       => l_instance_tbl,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_instance_tbl.COUNT > 0 THEN
      IF l_instance_tbl.COUNT = 1 THEN

        IF l_instance_tbl(1).quantity > l_qty_remaining THEN
          l_qty_to_dealloc := l_qty_remaining;
        ELSE
          l_qty_to_dealloc := l_instance_tbl(1).quantity;
        END IF;

        decrement_wip_instance(
          p_instance_id          => l_instance_tbl(1).instance_id,
          p_quantity             => l_qty_to_dealloc,
          px_csi_txn_rec         => px_csi_txn_rec,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_qty_remaining := l_qty_remaining - l_qty_to_dealloc;

      ELSE
        -- this case should not arise. There cannot be multiple IN_WIP instances
        -- for a non serial instance given a lot number in the transaction.
        null;
      END IF;
    END IF;

    IF l_qty_remaining > 0 THEN

      get_qty_per_assembly(
        p_organization_id      => p_organization_id,
        p_wip_entity_id        => p_wip_entity_id,
        p_component_item_id    => p_component_item_id,
        x_qty_per_assembly     => l_qty_per_assy,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      get_issued_in_inv_instances(
        p_wip_entity_id      => p_wip_entity_id,
        p_component_item_id  => p_component_item_id,
        p_organization_id    => p_organization_id,
        p_lot_number         => p_lot_number,
        x_instance_tbl       => l_instance_tbl,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_qty_per_assy = 0 AND p_auto_allocate = 'Y' THEN

        l_qty_per_assy := l_qty_remaining;

      END IF;

      IF l_qty_per_assy > 0 THEN

        deallocate_using_qty_per_assy(
          p_qty_returned     => l_qty_remaining,
          p_qty_per_assy     => l_qty_per_assy,
          p_instances_tbl    => l_instance_tbl,
          px_csi_txn_rec     => px_csi_txn_rec,
          x_qty_remaining    => l_qty_remaining,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_qty_remaining > 0 THEN

          get_issued_in_rel_instances(
            p_wip_entity_id      => p_wip_entity_id,
            p_component_item_id  => p_component_item_id,
            p_organization_id    => p_organization_id,
            p_lot_number         => p_lot_number,
            x_instance_tbl       => l_instance_tbl,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          deallocate_using_qty_per_assy(
            p_qty_returned     => l_qty_remaining,
            p_qty_per_assy     => l_qty_per_assy,
            p_instances_tbl    => l_instance_tbl,
            px_csi_txn_rec     => px_csi_txn_rec,
            x_qty_remaining    => l_qty_remaining,
            x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END deallocate_wip_instances;


  PROCEDURE bld_inst_tables_for_return(
    p_txn_ref           IN  txn_ref,
    p_mmt_rec           IN  mmt_rec,
    p_csi_txn_rec       IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_dest_loc_rec      OUT NOCOPY csi_process_txn_grp.dest_location_rec,
    x_instances_tbl     OUT NOCOPY csi_process_txn_grp.txn_instances_tbl,
    x_parties_tbl       OUT NOCOPY csi_process_txn_grp.txn_i_parties_tbl,
    x_org_units_tbl     OUT NOCOPY csi_process_txn_grp.txn_org_units_tbl,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_in_out_flag       varchar2(3) := 'INT';

    l_int_party_id      number;
    l_auto_allocate     varchar2(1);
    l_wip_loc_id        number;
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_instance_id       number;

    --Added for bug 5376024--
    l_inv_item_id       number;
    l_serial_number     varchar2(30);
    l_quantity          number;
    --Added for bug 5376024--

    l_dest_loc_rec      csi_process_txn_grp.dest_location_rec;
    l_instances_tbl     csi_process_txn_grp.txn_instances_tbl;
    l_parties_tbl       csi_process_txn_grp.txn_i_parties_tbl;

    l_csi_instance_tbl  csi_datastructures_pub.instance_tbl;

    l_maintenance_source  number := 0;
    l_relation_found      varchar2(1) := 'N';
    l_parent_instance_id  number;

    -- Bug 8345922
    CURSOR parent_item_csr (p_transaction_set_id IN NUMBER) IS
      SELECT  mmt.inventory_item_id     inventory_item_id,
              mut.serial_number         serial_number
        --INTO  l_inv_item_id, l_serial_number
        FROM  mtl_material_transactions   mmt,
              mtl_unit_transactions       mut
        WHERE mmt.transaction_id = mut.transaction_id
        AND mmt.transaction_set_id = p_transaction_set_id
        AND mmt.transaction_type_id = 17;

    CURSOR child_item_csr (p_inventory_item_id IN NUMBER, p_serial_number IN varchar2) IS
    select cir.subject_id,ci2.quantity
           from csi_item_instances ci1, csi_item_instances ci2, csi_ii_relationships cir
           where ci1.instance_id = cir.object_id
           and ci1.inventory_item_id = p_inventory_item_id
           and ci1.serial_number = p_serial_number
           and ci2.inventory_item_id = p_mmt_rec.inventory_item_id
           and ci2.instance_id = cir.subject_id
           and cir.relationship_type_code = 'COMPONENT-OF'
           and sysdate between nvl(cir.active_start_date, sysdate-1)
                        and     nvl(cir.active_end_date, sysdate+1)
           and sysdate between nvl(ci2.active_start_date, sysdate-1)
                        and     nvl(ci2.active_end_date, sysdate+1);

    l_parent_item_csr parent_item_csr%ROWTYPE;
    l_child_item_csr child_item_csr%ROWTYPE;
    l_child_instance_count NUMBER;
    -- End of addition for bug 8345922


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('bld_inst_tables_for_return');

    l_int_party_id  := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_auto_allocate := nvl(csi_datastructures_pub.g_install_param_rec.auto_allocate_comp_at_wip, 'N');
   -- l_wip_loc_id    := csi_datastructures_pub.g_install_param_rec.wip_location_id;

    -- build destination location attribs
    l_dest_loc_rec.location_type_code       := 'INVENTORY';
    l_dest_loc_rec.location_id              := p_mmt_rec.subinv_location_id;

    IF nvl(x_dest_loc_rec.location_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      l_dest_loc_rec.location_id            := p_mmt_rec.hr_location_id;
    END IF;

    l_dest_loc_rec.inv_organization_id      := p_mmt_rec.organization_id;
    l_dest_loc_rec.inv_subinventory_name    := p_mmt_rec.subinventory_code;
    l_dest_loc_rec.inv_locator_id           := p_mmt_rec.locator_id;
    l_dest_loc_rec.pa_project_id            := fnd_api.g_miss_num;
    l_dest_loc_rec.pa_project_task_id       := fnd_api.g_miss_num;
    l_dest_loc_rec.in_transit_order_line_id := fnd_api.g_miss_num;
    l_dest_loc_rec.wip_job_id               := fnd_api.g_miss_num;
    l_dest_loc_rec.po_order_line_id         := fnd_api.g_miss_num;
    l_dest_loc_rec.instance_usage_code      := 'IN_INVENTORY';

    -- build instances
    l_instances_tbl(1).ib_txn_segment_flag        := 'S';
    l_instances_tbl(1).inventory_item_id          := p_mmt_rec.inventory_item_id;
    l_instances_tbl(1).inventory_revision         := p_mmt_rec.revision;
    l_instances_tbl(1).vld_organization_id        := p_mmt_rec.organization_id;
    l_instances_tbl(1).inv_master_organization_id := p_txn_ref.master_organization_id;
    l_instances_tbl(1).serial_number              := p_mmt_rec.serial_number;

    IF nvl(l_instances_tbl(1).serial_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      l_instances_tbl(1).mfg_serial_number_flag   := 'Y';
    ELSE
      l_instances_tbl(1).mfg_serial_number_flag   := 'N';
    END IF;

    l_instances_tbl(1).lot_number                 := p_mmt_rec.lot_number;
    l_instances_tbl(1).quantity                   := abs(p_mmt_rec.instance_quantity);
    l_instances_tbl(1).unit_of_measure            := p_txn_ref.primary_uom_code;

    l_instances_tbl(1).location_type_code         := 'WIP';
    l_instances_tbl(1).location_id                := nvl(p_mmt_rec.organization_id,fnd_api.g_miss_num); --5224875
    l_instances_tbl(1).last_wip_job_id            := p_mmt_rec.transaction_source_id;

    l_instances_tbl(1).inv_organization_id        := fnd_api.g_miss_num;
    l_instances_tbl(1).inv_subinventory_name      := fnd_api.g_miss_char;
    l_instances_tbl(1).inv_locator_id             := fnd_api.g_miss_num;

    l_instances_tbl(1).active_start_date          := p_txn_ref.transaction_date;
    l_instances_tbl(1).customer_view_flag         := 'N';
    l_instances_tbl(1).merchant_view_flag         := 'Y';
    l_instances_tbl(1).instance_usage_code        := 'IN_INVENTORY';

    -- build parties
    l_parties_tbl(1).parent_tbl_index             := 1;
    l_parties_tbl(1).party_source_table           := 'HZ_PARTIES';
    l_parties_tbl(1).party_id                     := l_int_party_id;
    l_parties_tbl(1).relationship_type_code       := 'OWNER';
    l_parties_tbl(1).contact_flag                 := 'N';

    -- build org. assignments

    -- for serialized instances
    IF p_txn_ref.srl_control_code not in (1, 6) then

      get_issued_serial_instance(
        px_instance_rec        => l_instances_tbl(1),
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- check the location of the instance here before further process.

      -- any serialized component being returned back to Inv .
      IF nvl(l_instances_tbl(1).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN

        /* 1 - EAM, 2 - AHL 0 - NULL */
        IF p_txn_ref.wip_maint_source_code = 2 THEN
          l_relation_found := 'N';
          -- check if it is in a relation
          BEGIN
            SELECT 'Y', object_id
            INTO   l_relation_found , l_parent_instance_id
            FROM   csi_ii_relationships
            WHERE  subject_id = l_instances_tbl(1).instance_id
            AND    relationship_type_code = 'COMPONENT-OF'
            AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                           AND     nvl(active_end_date, sysdate+1);
          EXCEPTION
            WHEN no_data_found THEN
              l_relation_found := 'N';
          END;
          IF l_relation_found = 'Y' THEN
            fnd_message.set_name('CSI', 'CSI_MAINT_JOB_RTN_DISALLOWED');
            fnd_message.set_token('PARENT_INSTANCE_ID', l_parent_instance_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        csi_process_txn_pvt.check_and_break_relation(
          p_instance_id   => l_instances_tbl(1).instance_id,
          p_csi_txn_rec   => p_csi_txn_rec ,
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_parties_tbl.delete;

      END IF;

    ELSE -- non serialized case
    --Added for bug 5376024--
    /*  BEGIN
        select mmt.inventory_item_id, mut.serial_number
        into  l_inv_item_id, l_serial_number
        from mtl_material_transactions mmt, mtl_unit_transactions mut
        where mmt.transaction_id = mut.transaction_id
        and mmt.transaction_set_id = p_mmt_rec.transaction_set_id
        and mmt.transaction_type_id = 17;

        BEGIN
           select cir.subject_id,ci2.quantity
           into l_instance_id, l_quantity
           from csi_item_instances ci1, csi_item_instances ci2, csi_ii_relationships cir
           where ci1.instance_id = cir.object_id
           and ci1.inventory_item_id = l_inv_item_id
           and ci1.serial_number = l_serial_number
           and ci2.inventory_item_id = p_mmt_rec.inventory_item_id
           and ci2.instance_id = cir.subject_id
           and cir.relationship_type_code = 'COMPONENT-OF'
           and sysdate between nvl(cir.active_start_date, sysdate-1)
                        and     nvl(cir.active_end_date, sysdate+1)
           and sysdate between nvl(ci2.active_start_date, sysdate-1)
                        and     nvl(ci2.active_end_date, sysdate+1);
        EXCEPTION
           WHEN no_data_found THEN
             debug('First no data');
             null;
        END;

      EXCEPTION
         WHEN no_data_found THEN
           debug('Second no data');
           null;
      END;

      IF nvl(l_instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              --decrement the wip instance
      */
      -- Bug 8345922
      l_child_instance_count := 0;
      FOR l_parent_item_csr IN parent_item_csr(p_mmt_rec.transaction_set_id) LOOP
         FOR l_child_item_csr IN child_item_csr(l_parent_item_csr.inventory_item_id,
                l_parent_item_csr.serial_number) LOOP
          l_instance_id := l_child_item_csr.subject_id;
          l_quantity := l_child_item_csr.quantity;

          debug('l_instance_id '||l_instance_id);
          debug('l_quantity '||l_quantity);
          decrement_wip_instance(
            p_instance_id         => l_instance_id,
            p_quantity            => l_quantity,
            px_csi_txn_rec        => p_csi_txn_rec,
            x_return_status       => l_return_status);

          l_child_instance_count := l_child_instance_count + 1;

        END LOOP; -- l_child_item_csr IN child_item_csr
     END LOOP; -- l_parent_item_csr IN parent_item_csr

    --ELSE -- Commented for bug 8345922
    IF l_child_instance_count = 0 THEN -- Bug 8345922
      --Added for bug 5376024--
      -- get all the WIP instances and allocated component of inv instances
      -- decrement the instances in the appropriate
      deallocate_wip_instances(
        p_wip_entity_id        => p_mmt_rec.transaction_source_id,
        p_component_item_id    => p_mmt_rec.inventory_item_id,
        p_organization_id      => p_mmt_rec.organization_id,
        p_lot_number           => p_mmt_rec.lot_number,
        p_returned_quantity    => abs(p_mmt_rec.instance_quantity),
        p_auto_allocate        => l_auto_allocate,
        px_csi_txn_rec         => p_csi_txn_rec,
        x_return_status        => l_return_status);

     -- END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
      l_instances_tbl(1).instance_id := fnd_api.g_miss_num;

    END IF;

    x_dest_loc_rec  := l_dest_loc_rec;
    x_instances_tbl := l_instances_tbl;
    x_parties_tbl   := l_parties_tbl;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END bld_inst_tables_for_return;

  /* main routine for the wip component return transaction. */
  PROCEDURE wip_comp_receipt(
    p_transaction_id     IN            number,
    p_message_id         IN            number,
    px_trx_error_rec     IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status         OUT nocopy VARCHAR2)
  IS

    l_api_name               varchar2(100):= 'csi_wip_trxs_pkg.wip_component_return';
    l_txn_ref                txn_ref;
    l_mmt_tbl                mmt_tbl;

    l_in_out_flag            varchar2(30) := 'INT';
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;

    l_csi_txn_rec        csi_datastructures_pub.transaction_rec;

    l_c_dest_loc_rec         csi_process_txn_grp.dest_location_rec;
    l_c_instances_tbl        csi_process_txn_grp.txn_instances_tbl;
    l_c_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_c_org_units_tbl        csi_process_txn_grp.txn_org_units_tbl;

    l_api_success            varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);
    l_error_rec              csi_datastructures_pub.transaction_error_rec;

  BEGIN

    savepoint wip_component_receipt;

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;


    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipcr',
      p_file_segment2 => p_transaction_id);

    api_log('wip_comp_receipt');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP Component Return');
    debug('  Transaction ID    : '||p_transaction_id);

    -- This procedure check if the installed base is active
    csi_utility_grp.check_ib_active;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec                          := px_trx_error_rec;
    l_error_rec.transaction_type_id      := 72;
    l_error_rec.source_id                := p_transaction_id;

    csi_wip_trxs_pkg.get_mmt_info(
      p_transaction_id => p_transaction_id,
      x_txn_ref        => l_txn_ref,
      x_mmt_tbl        => l_mmt_tbl,
      x_return_status  => l_return_status);

    IF l_return_status <> l_api_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.source_header_ref        := l_txn_ref.wip_entity_name;
    l_error_rec.source_header_ref_id     := l_txn_ref.wip_entity_id;
    l_error_rec.inventory_item_id        := l_txn_ref.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_txn_ref.srl_control_code;
    l_error_rec.src_lot_ctrl_code        := l_txn_ref.lot_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_txn_ref.rev_control_code;
    l_error_rec.src_location_ctrl_code   := l_txn_ref.loc_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_txn_ref.ib_trackable_flag;

    IF l_mmt_tbl.COUNT > 0 THEN

      l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
      l_csi_txn_rec.source_header_ref           := l_txn_ref.wip_entity_name;
      l_csi_txn_rec.source_header_ref_id        := l_txn_ref.wip_entity_id;
      l_csi_txn_rec.source_transaction_date     := l_txn_ref.transaction_date;

      l_csi_txn_rec.transaction_date            := sysdate;
      l_csi_txn_rec.transaction_quantity        := l_txn_ref.primary_quantity;
      l_csi_txn_rec.transaction_uom_code        := l_txn_ref.primary_uom_code;
      l_csi_txn_rec.message_id                  := p_message_id;
      l_csi_txn_rec.inv_material_transaction_id := l_txn_ref.transaction_id;
      l_csi_txn_rec.object_version_number       := 1.0;
      l_csi_txn_rec.transaction_type_id         := 72;
      l_csi_txn_rec.txn_sub_type_id             := 3;
      l_csi_txn_rec.transaction_status_code     := 'PENDING';

      FOR l_ind in l_mmt_tbl.FIRST .. l_mmt_tbl.LAST
      LOOP

        l_error_rec.serial_number := l_mmt_tbl(l_ind).serial_number;
        l_error_rec.lot_number    := l_mmt_tbl(l_ind).lot_number;

        bld_inst_tables_for_return(
          p_txn_ref               => l_txn_ref,
          p_mmt_rec               => l_mmt_tbl(l_ind),
          p_csi_txn_rec           => l_csi_txn_rec,
          x_dest_loc_rec          => l_c_dest_loc_rec,
          x_instances_tbl         => l_c_instances_tbl,
          x_parties_tbl           => l_c_parties_tbl,
          x_org_units_tbl         => l_c_org_units_tbl,
          x_return_status         => l_return_status);

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        csi_process_txn_grp.process_transaction(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_false,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_validate_only_flag    => fnd_api.g_false,
          p_in_out_flag           => l_in_out_flag, -- valid values are 'IN','OUT'
          p_dest_location_rec     => l_c_dest_loc_rec,
          p_txn_rec               => l_csi_txn_rec,
          p_instances_tbl         => l_c_instances_tbl,
          p_i_parties_tbl         => l_c_parties_tbl,
          p_ip_accounts_tbl       => l_ip_accounts_tbl,
          p_org_units_tbl         => l_org_units_tbl,
          p_ext_attrib_vlaues_tbl => l_ext_attrib_values_tbl,
          p_pricing_attribs_tbl   => l_pricing_attribs_tbl,
          p_instance_asset_tbl    => l_instance_asset_tbl,
          p_ii_relationships_tbl  => l_ii_relationships_tbl,
          px_txn_error_rec        => l_error_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data );

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END LOOP;
    END IF;

    debug('wip component return transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_component_receipt;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;

      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_component_receipt;

      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 255));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;

      debug('Error(O) :'||l_error_rec.error_text);

  END wip_comp_receipt;

  PROCEDURE bld_inst_tables_for_compl(
    p_txn_ref             IN  txn_ref,
    p_mmt_rec             IN  mmt_rec,
    px_csi_txn_rec        IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_dest_loc_rec        OUT NOCOPY csi_process_txn_grp.dest_location_rec,
    x_instances_tbl       OUT NOCOPY csi_process_txn_grp.txn_instances_tbl,
    x_parties_tbl         OUT NOCOPY csi_process_txn_grp.txn_i_parties_tbl,
    x_org_units_tbl       OUT NOCOPY csi_process_txn_grp.txn_org_units_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_int_party_id      number;
    l_comp_is_assy      varchar2(1) := 'N';
    l_issued_instances  csi_datastructures_pub.instance_tbl;
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_instance_found    boolean := FALSE;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('bld_inst_tables_for_compl');

    l_int_party_id  := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    -- destination location attributes
    x_dest_loc_rec.location_type_code       := 'INVENTORY';
    x_dest_loc_rec.location_id              := p_mmt_rec.subinv_location_id;
    x_dest_loc_rec.instance_usage_code      := 'IN_INVENTORY';

    IF nvl(x_dest_loc_rec.location_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      x_dest_loc_rec.location_id            := p_mmt_rec.hr_location_id;
    END IF;

    x_dest_loc_rec.inv_organization_id      := p_mmt_rec.organization_id;
    x_dest_loc_rec.inv_subinventory_name    := p_mmt_rec.subinventory_code;
    x_dest_loc_rec.inv_locator_id           := p_mmt_rec.locator_id;

    x_dest_loc_rec.pa_project_id            := fnd_api.g_miss_num;
    x_dest_loc_rec.pa_project_task_id       := fnd_api.g_miss_num;
    x_dest_loc_rec.in_transit_order_line_id := fnd_api.g_miss_num;
    x_dest_loc_rec.wip_job_id               := fnd_api.g_miss_num;
    x_dest_loc_rec.po_order_line_id         := fnd_api.g_miss_num;

    -- instances
    x_instances_tbl(1).ib_txn_segment_flag        := 'S';
    x_instances_tbl(1).inventory_item_id          := p_mmt_rec.inventory_item_id;
    x_instances_tbl(1).inventory_revision         := p_mmt_rec.revision;
    x_instances_tbl(1).vld_organization_id        := p_mmt_rec.organization_id;
    x_instances_tbl(1).unit_of_measure            := p_txn_ref.primary_uom_code;
    x_instances_tbl(1).inv_master_organization_id := p_txn_ref.master_organization_id;
    x_instances_tbl(1).quantity                   := abs(p_mmt_rec.instance_quantity);
    x_instances_tbl(1).serial_number              := p_mmt_rec.serial_number;
    x_instances_tbl(1).lot_number                 := p_mmt_rec.lot_number;

    IF nvl(x_instances_tbl(1).serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      x_instances_tbl(1).mfg_serial_number_flag := 'Y';
    END IF;

    x_instances_tbl(1).location_type_code         := fnd_api.g_miss_char;
    x_instances_tbl(1).location_id                := fnd_api.g_miss_num;
    x_instances_tbl(1).inv_subinventory_name      := fnd_api.g_miss_char;
    x_instances_tbl(1).inv_organization_id        := fnd_api.g_miss_num;
    x_instances_tbl(1).inv_locator_id             := fnd_api.g_miss_num;

    x_instances_tbl(1).last_wip_job_id            := p_mmt_rec.transaction_source_id;
    x_instances_tbl(1).active_start_date          := p_txn_ref.transaction_date;
    x_instances_tbl(1).customer_view_flag         := 'N';
    x_instances_tbl(1).merchant_view_flag         := 'Y';
    x_instances_tbl(1).instance_usage_code        := 'IN_INVENTORY';

    IF p_txn_ref.eam_item_type IN (1, 3) THEN
      IF p_txn_ref.wip_maint_obj_type = 3 THEN
        l_instance_found := TRUE;
        x_instances_tbl(1).instance_id := p_txn_ref.wip_maint_obj_id;
      ELSE
        l_instance_found := FALSE;
      END IF;
    END IF;

    IF x_instances_tbl(1).mfg_serial_number_flag = 'Y' AND NOT(l_instance_found) THEN

      l_comp_is_assy := 'N';

      BEGIN
        SELECT 'Y'
        INTO   l_comp_is_assy
        FROM   sys.dual
        WHERE  exists (
          SELECT 'X'
          FROM   csi_item_instances
          WHERE  last_vld_organization_id = p_mmt_rec.organization_id
          AND    location_type_code       = 'WIP'
          AND    wip_job_id               = p_mmt_rec.transaction_source_id
          AND    serial_number            = p_mmt_rec.serial_number
          AND    inventory_item_id        = p_mmt_rec.inventory_item_id);
      EXCEPTION
        WHEN no_data_found THEN
          l_comp_is_assy := 'N';
      END;

      IF l_comp_is_assy = 'Y' THEN
        -- call get_item_instances for the WIP

        get_issued_instances(
          p_wip_entity_id     => p_mmt_rec.transaction_source_id,
          p_organization_id   => p_mmt_rec.organization_id,
          p_inventory_item_id => p_mmt_rec.inventory_item_id,
          p_serial_number     => p_mmt_rec.serial_number,
          x_instance_tbl      => l_issued_instances,
          x_return_status     => l_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_issued_instances.count = 1 THEN
          debug('Unique wip issued serial instance found. ID :'||l_issued_instances(1).instance_id);
          x_instances_tbl(1).instance_id := l_issued_instances(1).instance_id;
          l_instance_found := TRUE;
        END IF;
      END IF;

      IF NOT(l_instance_found) THEN
        -- relaxing the check here because ERP allows some transactions
        -- misc issue and complete
        debug('Check if there is a serialized instance in the system.');
        get_serial_instance(
          p_inventory_item_id => p_mmt_rec.inventory_item_id,
          p_serial_number     => p_mmt_rec.serial_number,
          x_instance_tbl      => l_issued_instances,
          x_return_status     => l_return_status);
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        IF l_issued_instances.count = 1 THEN
          x_instances_tbl(1).instance_id := l_issued_instances(1).instance_id;
          l_instance_found := TRUE;
        END IF;
      END IF;

      IF l_instance_found THEN
        -- check and break relation
        csi_process_txn_pvt.check_and_break_relation(
          p_instance_id   => l_issued_instances(1).instance_id,
          p_csi_txn_rec   => px_csi_txn_rec ,
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    IF NOT(l_instance_found) THEN
      x_parties_tbl(1).parent_tbl_index         := 1;
      x_parties_tbl(1).party_source_table       := 'HZ_PARTIES';
      x_parties_tbl(1).party_id                 := l_int_party_id;
      x_parties_tbl(1).relationship_type_code   := 'OWNER';
      x_parties_tbl(1).contact_flag             := 'N';
    END IF;

  END bld_inst_tables_for_compl;



   PROCEDURE wip_byproduct_completion(
    p_transaction_id       IN            number,
    p_message_id           IN            number,
    px_trx_error_rec       IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT nocopy varchar2)
  IS

    l_api_name               varchar2(100):= 'csi_wip_trxs_pkg.wip_Byproduct_completion';
    l_txn_ref                txn_ref;
    l_mmt_tbl                mmt_tbl;

    l_in_out_flag            varchar2(30) := 'IN';
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(240);

    l_csi_txn_rec            csi_datastructures_pub.transaction_rec;

    l_c_dest_loc_rec         csi_process_txn_grp.dest_location_rec;
    l_c_instances_tbl        csi_process_txn_grp.txn_instances_tbl;
    l_c_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_c_org_units_tbl        csi_process_txn_grp.txn_org_units_tbl;

    l_api_success            varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);

    l_completed_instances    csi_datastructures_pub.instance_tbl;
    l_c_ind                  binary_integer := 0;

    l_error_rec              csi_datastructures_pub.transaction_error_rec;
    l_replace_rebuilds       EAM_Utility_GRP.Replace_Rebuild_TBL_Type;

  BEGIN

    savepoint wip_byproduct_completion;

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipbc',
      p_file_segment2 => p_transaction_id);

    api_log('wip_byproduct_completion');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP Byproduct Completion');
    debug('  Transaction ID    : '||p_transaction_id);

    csi_utility_grp.check_ib_active;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec                          := px_trx_error_rec;
    l_error_rec.transaction_type_id      := 75;
    l_error_rec.source_id                := p_transaction_id;

    csi_wip_trxs_pkg.get_mmt_info(
      p_transaction_id => p_transaction_id,
      x_txn_ref        => l_txn_ref,
      x_mmt_tbl        => l_mmt_tbl,
      x_return_status  => l_return_status);

    IF l_return_status <> l_api_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.source_header_ref        := l_txn_ref.wip_entity_name;
    l_error_rec.source_header_ref_id     := l_txn_ref.wip_entity_id;
    l_error_rec.inventory_item_id        := l_txn_ref.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_txn_ref.srl_control_code;
    l_error_rec.src_lot_ctrl_code        := l_txn_ref.lot_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_txn_ref.rev_control_code;
    l_error_rec.src_location_ctrl_code   := l_txn_ref.loc_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_txn_ref.ib_trackable_flag;

    IF l_mmt_tbl.COUNT > 0 THEN

      l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
      l_csi_txn_rec.source_transaction_date     := l_txn_ref.transaction_date;
      l_csi_txn_rec.source_header_ref           := l_txn_ref.wip_entity_name;
      l_csi_txn_rec.source_header_ref_id        := l_txn_ref.wip_entity_id;

      l_csi_txn_rec.transaction_date            := sysdate;
      l_csi_txn_rec.transaction_quantity        := l_txn_ref.primary_quantity;
      l_csi_txn_rec.transaction_uom_code        := l_txn_ref.primary_uom_code;
      l_csi_txn_rec.transaction_type_id         := 75;
      l_csi_txn_rec.message_id                  := p_message_id;
      l_csi_txn_rec.inv_material_transaction_id := l_txn_ref.transaction_id;
      l_csi_txn_rec.object_version_number       := 1.0;
      l_csi_txn_rec.txn_sub_type_id             := 3;
      l_csi_txn_rec.transaction_status_code     := 'PENDING';


      IF l_txn_ref.eam_item_type in (1, 3) THEN

        Delink_ReplaceRebuilds(
          p_wip_entity_id    => l_txn_ref.wip_entity_id,
          p_organization_id  => l_txn_ref.organization_id,
          px_csi_txn_rec     => l_csi_txn_rec,
          x_replace_rebuilds => l_replace_rebuilds,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

      FOR l_ind in l_mmt_tbl.FIRST .. l_mmt_tbl.LAST
      LOOP

        l_error_rec.serial_number := l_mmt_tbl(l_ind).serial_number;
        l_error_rec.lot_number    := l_mmt_tbl(l_ind).lot_number;

        bld_inst_tables_for_compl(
          p_txn_ref        => l_txn_ref,
          p_mmt_rec        => l_mmt_tbl(l_ind),
          px_csi_txn_rec   => l_csi_txn_rec,
          x_dest_loc_rec   => l_c_dest_loc_rec,
          x_instances_tbl  => l_c_instances_tbl,
          x_parties_tbl    => l_c_parties_tbl,
          x_org_units_tbl  => l_c_org_units_tbl,
          x_return_status  => l_return_status);

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        csi_process_txn_grp.process_transaction(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_false,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_validate_only_flag    => fnd_api.g_false,
          p_in_out_flag           => l_in_out_flag,
          p_dest_location_rec     => l_c_dest_loc_rec,
          p_txn_rec               => l_csi_txn_rec,
          p_instances_tbl         => l_c_instances_tbl,
          p_i_parties_tbl         => l_c_parties_tbl,
          p_ip_accounts_tbl       => l_ip_accounts_tbl,
          p_org_units_tbl         => l_org_units_tbl,
          p_ext_attrib_vlaues_tbl => l_ext_attrib_values_tbl,
          p_pricing_attribs_tbl   => l_pricing_attribs_tbl,
          p_instance_asset_tbl    => l_instance_asset_tbl,
          p_ii_relationships_tbl  => l_ii_relationships_tbl,
          px_txn_error_rec        => l_error_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data );

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_c_instances_tbl.COUNT > 0 THEN
          FOR l_a_ind IN l_c_instances_tbl.FIRST .. l_c_instances_tbl.LAST
          LOOP
            l_c_ind := l_c_ind + 1;
            l_completed_instances(l_c_ind).instance_id       :=
                                           l_c_instances_tbl(l_a_ind).new_instance_id;
            l_completed_instances(l_c_ind).serial_number     :=
                                           l_c_instances_tbl(l_a_ind).serial_number;
            l_completed_instances(l_c_ind).inventory_item_id :=
                                           l_c_instances_tbl(l_a_ind).inventory_item_id;
            l_completed_instances(l_c_ind).quantity          :=
                                           l_c_instances_tbl(l_a_ind).quantity;
          END LOOP;
        END IF;

      END LOOP;

      /* 1 - EAM, 2 - AHL 0 - NULL */
      --R12 Changes for OPM
      IF l_txn_ref.wip_maint_source_code <> 2 OR l_txn_ref.wip_entity_type <> 10 THEN
        process_relation_at_wipac(
          p_txn_ref            => l_txn_ref,
          p_assembly_instances => l_completed_instances,
          px_csi_txn_rec       => l_csi_txn_rec,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

    END IF;
    debug('wip Byproduct completion transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_byproduct_completion;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_byproduct_completion;

      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 255));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      debug('Error(E) :'||l_error_rec.error_text);

  END wip_byproduct_completion;






  PROCEDURE wip_assy_completion(
    p_transaction_id       IN            number,
    p_message_id           IN            number,
    px_trx_error_rec       IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT nocopy varchar2)
  IS

    l_api_name               varchar2(100):= 'csi_wip_trxs_pkg.wip_Assembly_completion';
    l_txn_ref                txn_ref;
    l_mmt_tbl                mmt_tbl;

    l_in_out_flag            varchar2(30) := 'IN';
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(240);

    l_csi_txn_rec            csi_datastructures_pub.transaction_rec;

    l_c_dest_loc_rec         csi_process_txn_grp.dest_location_rec;
    l_c_instances_tbl        csi_process_txn_grp.txn_instances_tbl;
    l_c_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_c_org_units_tbl        csi_process_txn_grp.txn_org_units_tbl;

    l_api_success            varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);

    l_completed_instances    csi_datastructures_pub.instance_tbl;
    l_c_ind                  binary_integer := 0;

    l_error_rec              csi_datastructures_pub.transaction_error_rec;
    l_replace_rebuilds       EAM_Utility_GRP.Replace_Rebuild_TBL_Type;

  BEGIN

    savepoint wip_assy_completion;

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.initialize;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwipac',
      p_file_segment2 => p_transaction_id);

    api_log('wip_assy_completion');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : WIP Assembly Completion');
    debug('  Transaction ID    : '||p_transaction_id);

    csi_utility_grp.check_ib_active;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec                          := px_trx_error_rec;
    l_error_rec.transaction_type_id      := 73;
    l_error_rec.source_id                := p_transaction_id;

    csi_wip_trxs_pkg.get_mmt_info(
      p_transaction_id => p_transaction_id,
      x_txn_ref        => l_txn_ref,
      x_mmt_tbl        => l_mmt_tbl,
      x_return_status  => l_return_status);

    IF l_return_status <> l_api_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.source_header_ref        := l_txn_ref.wip_entity_name;
    l_error_rec.source_header_ref_id     := l_txn_ref.wip_entity_id;
    l_error_rec.inventory_item_id        := l_txn_ref.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_txn_ref.srl_control_code;
    l_error_rec.src_lot_ctrl_code        := l_txn_ref.lot_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_txn_ref.rev_control_code;
    l_error_rec.src_location_ctrl_code   := l_txn_ref.loc_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_txn_ref.ib_trackable_flag;

    IF l_mmt_tbl.COUNT > 0 THEN

      l_csi_txn_rec.transaction_id              := fnd_api.g_miss_num;
      l_csi_txn_rec.source_transaction_date     := l_txn_ref.transaction_date;
      l_csi_txn_rec.source_header_ref           := l_txn_ref.wip_entity_name;
      l_csi_txn_rec.source_header_ref_id        := l_txn_ref.wip_entity_id;

      l_csi_txn_rec.transaction_date            := sysdate;
      l_csi_txn_rec.transaction_quantity        := l_txn_ref.primary_quantity;
      l_csi_txn_rec.transaction_uom_code        := l_txn_ref.primary_uom_code;
      l_csi_txn_rec.transaction_type_id         := 73;
      l_csi_txn_rec.message_id                  := p_message_id;
      l_csi_txn_rec.inv_material_transaction_id := l_txn_ref.transaction_id;
      l_csi_txn_rec.object_version_number       := 1.0;
      l_csi_txn_rec.txn_sub_type_id             := 3;
      l_csi_txn_rec.transaction_status_code     := 'PENDING';


      IF l_txn_ref.eam_item_type in (1, 3) THEN

        Delink_ReplaceRebuilds(
          p_wip_entity_id    => l_txn_ref.wip_entity_id,
          p_organization_id  => l_txn_ref.organization_id,
          px_csi_txn_rec     => l_csi_txn_rec,
          x_replace_rebuilds => l_replace_rebuilds,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

      FOR l_ind in l_mmt_tbl.FIRST .. l_mmt_tbl.LAST
      LOOP

        l_error_rec.serial_number := l_mmt_tbl(l_ind).serial_number;
        l_error_rec.lot_number    := l_mmt_tbl(l_ind).lot_number;

        bld_inst_tables_for_compl(
          p_txn_ref        => l_txn_ref,
          p_mmt_rec        => l_mmt_tbl(l_ind),
          px_csi_txn_rec   => l_csi_txn_rec,
          x_dest_loc_rec   => l_c_dest_loc_rec,
          x_instances_tbl  => l_c_instances_tbl,
          x_parties_tbl    => l_c_parties_tbl,
          x_org_units_tbl  => l_c_org_units_tbl,
          x_return_status  => l_return_status);

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        csi_process_txn_grp.process_transaction(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_false,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_validate_only_flag    => fnd_api.g_false,
          p_in_out_flag           => l_in_out_flag,
          p_dest_location_rec     => l_c_dest_loc_rec,
          p_txn_rec               => l_csi_txn_rec,
          p_instances_tbl         => l_c_instances_tbl,
          p_i_parties_tbl         => l_c_parties_tbl,
          p_ip_accounts_tbl       => l_ip_accounts_tbl,
          p_org_units_tbl         => l_org_units_tbl,
          p_ext_attrib_vlaues_tbl => l_ext_attrib_values_tbl,
          p_pricing_attribs_tbl   => l_pricing_attribs_tbl,
          p_instance_asset_tbl    => l_instance_asset_tbl,
          p_ii_relationships_tbl  => l_ii_relationships_tbl,
          px_txn_error_rec        => l_error_rec,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data );

        IF l_return_status <> l_api_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_c_instances_tbl.COUNT > 0 THEN
          FOR l_a_ind IN l_c_instances_tbl.FIRST .. l_c_instances_tbl.LAST
          LOOP
            l_c_ind := l_c_ind + 1;
            l_completed_instances(l_c_ind).instance_id       :=
                                           l_c_instances_tbl(l_a_ind).new_instance_id;
            l_completed_instances(l_c_ind).serial_number     :=
                                           l_c_instances_tbl(l_a_ind).serial_number;
            l_completed_instances(l_c_ind).inventory_item_id :=
                                           l_c_instances_tbl(l_a_ind).inventory_item_id;
            l_completed_instances(l_c_ind).quantity          :=
                                           l_c_instances_tbl(l_a_ind).quantity;
          END LOOP;
        END IF;

      END LOOP;

      /* 1 - EAM, 2 - AHL 0 - NULL */
      --R12 Changes for OPM
      IF l_txn_ref.wip_maint_source_code <> 2 OR l_txn_ref.wip_entity_type <> 10 THEN
        process_relation_at_wipac(
          p_txn_ref            => l_txn_ref,
          p_assembly_instances => l_completed_instances,
          px_csi_txn_rec       => l_csi_txn_rec,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

    END IF;
    debug('wip assembly completion transaction successful : '||p_transaction_id);
    debug('end timestamp       : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to wip_assy_completion;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_error;
      debug('Error(E) :'||l_error_rec.error_text);

    WHEN others then
      rollback to wip_assy_completion;

      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',g_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 255));
      fnd_msg_pub.add;

      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      debug('Error(E) :'||l_error_rec.error_text);

  END wip_assy_completion;


  PROCEDURE build_ii_relation_rec(
    p_tiir_rec       IN         csi_t_datastructures_grp.txn_ii_rltns_rec,
    p_tld_tbl        IN         csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_iir_rec        OUT NOCOPY csi_datastructures_pub.ii_relationship_rec,
    x_return_status  OUT NOCOPY varchar2)
  IS

    l_obj_instance_id      number;
    l_sub_instance_id      number;
    l_sub_tld_qty          number;
    l_sub_instance_qty     number;
    l_sub_tld_id           number := -999999;
    l_vld_organization_id  number;

    l_source_instance_rec  csi_datastructures_pub.instance_rec;
    l_new_instance_rec     csi_datastructures_pub.instance_rec;
    l_source_instance_qty  number;
    l_new_instance_qty     number;

    l_iir_rec              csi_datastructures_pub.ii_relationship_rec;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN

    api_log('build_ii_relation_rec');

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN p_tld_tbl.FIRST .. p_tld_tbl.LAST
      LOOP
        IF p_tiir_rec.object_id = p_tld_tbl(l_ind).txn_line_detail_id THEN
          l_obj_instance_id := p_tld_tbl(l_ind).instance_id;
        END IF;
        IF p_tiir_rec.subject_id = p_tld_tbl(l_ind).txn_line_detail_id THEN
          l_sub_tld_id      := p_tld_tbl(l_ind).txn_line_detail_id;
          l_sub_instance_id := p_tld_tbl(l_ind).instance_id;
          l_sub_tld_qty     := p_tld_tbl(l_ind).quantity;
        END IF;
      END LOOP;
    END IF;
    IF l_sub_instance_id is not null then

      SELECT quantity,
             last_vld_organization_id
      INTO   l_sub_instance_qty,
             l_vld_organization_id
      FROM   csi_item_instances
      WHERE  instance_id = l_sub_instance_id;

      IF l_sub_instance_qty > l_sub_tld_qty THEN

        l_source_instance_rec.instance_id         := l_sub_instance_id;
        l_source_instance_rec.vld_organization_id := l_vld_organization_id;

        l_source_instance_qty := l_sub_instance_qty - l_sub_tld_qty;
        l_new_instance_qty    := l_sub_tld_qty;

        csi_item_instance_pvt.split_item_instance (
          p_api_version            => 1.0,
          p_commit                 => fnd_api.g_false,
          p_init_msg_list          => fnd_api.g_true,
          p_validation_level       => fnd_api.g_valid_level_full,
          p_source_instance_rec    => l_source_instance_rec,
          p_quantity1              => l_source_instance_qty,
          p_quantity2              => l_new_instance_qty,
          p_copy_ext_attribs       => fnd_api.g_true,
          p_copy_org_assignments   => fnd_api.g_true,
          p_copy_parties           => fnd_api.g_true,
          p_copy_accounts          => fnd_api.g_true,
          p_copy_asset_assignments => fnd_api.g_true,
          p_copy_pricing_attribs   => fnd_api.g_true,
          p_txn_rec                => px_txn_rec,
          x_new_instance_rec       => l_new_instance_rec,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        l_sub_instance_id := l_new_instance_rec.instance_id;

        UPDATE csi_t_txn_line_details
        SET    instance_id        = l_sub_instance_id
        WHERE  txn_line_detail_id = l_sub_tld_id;

      END IF;

      l_iir_rec.object_id              := l_obj_instance_id;
      l_iir_rec.subject_id             := l_sub_instance_id;
      l_iir_rec.relationship_type_code := 'COMPONENT-OF';
      l_iir_rec.active_end_date        := null;
      l_iir_rec.cascade_ownership_flag := 'Y';

      BEGIN
        SELECT relationship_id,
               object_version_number
        INTO   l_iir_rec.relationship_id,
               l_iir_rec.object_version_number
        FROM   csi_ii_relationships
        WHERE  object_id  = l_obj_instance_id
        AND    subject_id = l_sub_instance_id;
      EXCEPTION
        WHEN no_data_found THEN
          l_iir_rec.relationship_id       := fnd_api.g_miss_num;
          l_iir_rec.object_version_number := 1.0;
      END;

    END IF;

    debug('  object instance id  :'||l_iir_rec.object_id);
    debug('  subject instance id :'||l_iir_rec.subject_id);
    debug('  relationship type   :'||l_iir_rec.relationship_type_code);
    debug('  relationship id     :'||l_iir_rec.relationship_id);
    debug('  object version num  :'||l_iir_rec.object_version_number);

    x_iir_rec := l_iir_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_ii_relation_rec;

  PROCEDURE update_tld_status(
    p_tld_tbl         IN csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status   OUT NOCOPY varchar2)
  IS
  BEGIN

    IF p_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN p_tld_tbl.FIRST .. p_tld_tbl.LAST
      LOOP
        UPDATE csi_t_txn_line_details
        SET    processing_status  = 'PROCESSED'
        WHERE  txn_line_detail_id = p_tld_tbl(l_ind).txn_line_detail_id;
      END LOOP;
    END IF;

  END update_tld_status;

  PROCEDURE process_manual_rltns(
    p_wip_entity_id   IN         number,
    x_return_status   OUT NOCOPY varchar2,
    x_error_message   OUT NOCOPY varchar2)
  IS

    l_wip_entity_name varchar2(80);

    l_tl_query_rec    csi_t_datastructures_grp.txn_line_query_rec;
    l_tld_query_rec   csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_tld_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_tpty_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_tpacct_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_tiir_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_teav_tbl        csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_cea_tbl         csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_ceav_tbl        csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_toa_tbl         csi_t_datastructures_grp.txn_org_assgn_tbl  ;
    l_tsys_tbl        csi_t_datastructures_grp.txn_systems_tbl;

    l_txn_rec         csi_datastructures_pub.transaction_rec;
    l_iir_rec         csi_datastructures_pub.ii_relationship_rec;
    l_c_iir_tbl       csi_datastructures_pub.ii_relationship_tbl;
    l_u_iir_tbl       csi_datastructures_pub.ii_relationship_tbl;
    l_c_ind           binary_integer := 0;
    l_u_ind           binary_integer := 0;

    l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_error_message   varchar2(2000);

  BEGIN

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiwiprel',
      p_file_segment2 => p_wip_entity_id);

    api_log('process_manual_rltns');

    savepoint process_manual_rltns;

    debug('  wip_entity_id   :'||p_wip_entity_id);

    SELECT wip_entity_name
    INTO   l_wip_entity_name
    FROM   wip_entities
    WHERE  wip_entity_id = p_wip_entity_id;

    debug('  wip_entity_name :'||l_wip_entity_name);

    x_return_status := fnd_api.g_ret_sts_success;

    l_tl_query_rec.source_transaction_table := 'WIP_ENTITIES';
    l_tl_query_rec.source_transaction_id    := p_wip_entity_id;
    l_tld_query_rec.processing_status       := 'UNPROCESSED';

    --get_transaction_details
    csi_t_txn_details_grp.get_transaction_details (
      p_api_version               => 1.0,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_txn_line_query_rec        => l_tl_query_rec,
      p_txn_line_detail_query_rec => l_tld_query_rec,
      x_txn_line_detail_tbl       => l_tld_tbl,
      p_get_parties_flag          => fnd_api.g_false,
      x_txn_party_detail_tbl      => l_tpty_tbl,
      p_get_pty_accts_flag        => fnd_api.g_false,
      x_txn_pty_acct_detail_tbl   => l_tpacct_tbl,
      p_get_ii_rltns_flag         => fnd_api.g_true,
      x_txn_ii_rltns_tbl          => l_tiir_tbl,
      p_get_org_assgns_flag       => fnd_api.g_false,
      x_txn_org_assgn_tbl         => l_toa_tbl,
      p_get_ext_attrib_vals_flag  => fnd_api.g_false,
      x_txn_ext_attrib_vals_tbl   => l_teav_tbl,
      p_get_csi_attribs_flag      => fnd_api.g_false,
      x_csi_ext_attribs_tbl       => l_cea_tbl,
      p_get_csi_iea_values_flag   => fnd_api.g_false,
      x_csi_iea_values_tbl        => l_ceav_tbl,
      p_get_txn_systems_flag      => fnd_api.g_false,
      x_txn_systems_tbl           => l_tsys_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  txn_detail.count :'||l_tld_tbl.COUNT);
    debug('  txn_rltns.count  :'||l_tiir_tbl.COUNT);

    IF l_tiir_tbl.count > 0 THEN

      -- build transaction rec
      l_txn_rec.source_transaction_date := sysdate;
      l_txn_rec.transaction_date        := sysdate;
      l_txn_rec.transaction_type_id     := 9;
      l_txn_rec.txn_sub_type_id         := 6;
      l_txn_rec.source_header_ref_id    := p_wip_entity_id;
      l_txn_rec.source_header_ref       := l_wip_entity_name;

      FOR l_ind IN l_tiir_tbl.FIRST .. l_tiir_tbl.LAST
      LOOP

        build_ii_relation_rec(
          p_tiir_rec      => l_tiir_tbl(l_ind),
          p_tld_tbl       => l_tld_tbl,
          px_txn_rec      => l_txn_rec,
          x_iir_rec       => l_iir_rec,
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF nvl(l_iir_rec.relationship_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          l_c_ind := l_c_ind + 1;
          l_c_iir_tbl(l_c_ind) := l_iir_rec;
        ELSE
          l_u_ind := l_u_ind + 1;
          l_u_iir_tbl(l_u_ind) := l_iir_rec;
        END IF;
      END LOOP;

      debug('create_relationship.COUNT :'||l_c_iir_tbl.COUNT);

      IF l_c_iir_tbl.COUNT > 0 THEN
        api_log(
          p_pkg_name => 'csi_ii_relationships_pub',
          p_api_name => 'create_relationship');

        csi_ii_relationships_pub.create_relationship(
          p_api_version      => 1.0,
          p_commit           => fnd_api.g_false,
          p_init_msg_list    => fnd_api.g_true,
          p_validation_level => fnd_api.g_valid_level_full,
          p_relationship_tbl => l_c_iir_tbl,
          p_txn_rec          => l_txn_rec,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      debug('update_relationship.COUNT :'||l_u_iir_tbl.COUNT);

      IF l_u_iir_tbl.COUNT > 0 THEN
        api_log(
          p_pkg_name => 'csi_ii_relationships_pub',
          p_api_name => 'update_relationship');

        debug('No code here yet for update relationship...');

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      update_tld_status(
        p_tld_tbl       => l_tld_tbl,
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      rollback to process_manual_rltns;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error :'||l_error_message);

      x_error_message := l_error_message;
      x_return_status := fnd_api.g_ret_sts_error;
  END process_manual_rltns;

  PROCEDURE eam_wip_completion(
    p_wip_entity_id    IN number,
    p_organization_id  IN number,
    px_trx_error_rec   OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status    OUT nocopy varchar2)
  IS
    CURSOR mtl_txn_cur(p_wip_entity_id IN number, p_migration_date IN date) IS
      SELECT transaction_id
      FROM   mtl_system_items  msi,
             mtl_material_transactions mmt
      WHERE  mmt.transaction_source_type_id = 5  -- job/schedule transactions
      AND    mmt.transaction_source_id   = p_wip_entity_id
      AND    mmt.transaction_action_id  in (1, 27, 31, 32, 33, 34) -- ib handled wip actions
      AND    mmt.transaction_date        > p_migration_date
      AND    msi.organization_id         = mmt.organization_id
      AND    msi.inventory_item_id       = mmt.inventory_item_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y';

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_processed_flag      boolean := FALSE;

    CURSOR wip_inst_cur(p_wip_entity_id IN number, p_instance_id IN number) IS
      SELECT instance_id,
             quantity,
             serial_number
      FROM   csi_item_instances
      WHERE  location_type_code = 'WIP'
      AND    wip_job_id         = p_wip_entity_id
      AND    instance_id       <> p_instance_id;

    l_instance_id         number;
    l_csi_txn_rec         csi_datastructures_pub.transaction_rec;
    l_iir_ind             binary_integer := 0;
    l_ii_rltns_tbl        csi_datastructures_pub.ii_relationship_tbl;
    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_replace_rebuilds    EAM_Utility_GRP.Replace_Rebuild_TBL_Type;

    FUNCTION replace_rebuild(
      p_instance_id       IN number,
      p_replace_rebuilds  IN EAM_Utility_GRP.Replace_Rebuild_TBL_Type)
    RETURN boolean
    IS
      l_return            boolean := FALSE;
    BEGIN
      IF p_replace_rebuilds.COUNT > 0 THEN
        FOR l_ind IN p_replace_rebuilds.FIRST .. l_replace_rebuilds.LAST
        LOOP
          IF p_replace_rebuilds(l_ind).instance_id = p_instance_id THEN
            l_return := TRUE;
            exit;
          END IF;
        END LOOP;
      END IF;
      RETURN l_return;
    END replace_rebuild;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csieamwc',
      p_file_segment2 => p_wip_entity_id);

    api_log('eam_wip_completion');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : EAM Work Order Completion');
    debug('  Transaction ID    : '||p_wip_entity_id);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_csi_txn_rec.transaction_type_id     := 92;
    l_csi_txn_rec.source_transaction_date := sysdate;
    l_csi_txn_rec.transaction_date        := sysdate;
    l_csi_txn_rec.source_header_ref_id    := p_wip_entity_id;

    SELECT wip_entity_name
    INTO   l_csi_txn_rec.source_header_ref
    FROM   wip_entities
    WHERE  wip_entity_id   = p_wip_entity_id
    AND    organization_id = p_organization_id;

    l_csi_txn_rec.transaction_status_code := 'PENDING';

    debug('  wip_entity_name   : '||l_csi_txn_rec.source_header_ref);

    delink_replacerebuilds(
      p_wip_entity_id    => p_wip_entity_id,
      p_organization_id  => p_organization_id,
      px_csi_txn_rec     => l_csi_txn_rec,
      x_replace_rebuilds => l_replace_rebuilds,
      x_return_status    => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    FOR mtl_txn_rec IN mtl_txn_cur(
      p_wip_entity_id  => p_wip_entity_id,
      p_migration_date => csi_datastructures_pub.g_install_param_rec.freeze_date)
    LOOP

      debug('  prior transaction_id : '||mtl_txn_rec.transaction_id);

      check_mtl_txn_in_csi(
        p_transaction_id  => mtl_txn_rec.transaction_id,
        x_txn_found       => l_processed_flag,
        x_return_status   => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF NOT( l_processed_flag ) THEN

        fnd_message.set_name('CSI', 'CSI_WIP_PRIOR_TXN_FAILED');
        fnd_message.set_token('WIP_ENTITY_ID', p_wip_entity_id);
        fnd_message.set_token('MTL_TXN_ID', mtl_txn_rec.transaction_id);

        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

    END LOOP;

    SELECT maintenance_object_id
    INTO   l_instance_id
    FROM   wip_discrete_jobs
    WHERE  wip_entity_id   = p_wip_entity_id
    AND    organization_id = p_organization_id;

    debug('  parent_instance_id   : '||l_instance_id);

    debug('component instances :-');

    FOR wip_inst_rec in wip_inst_cur(p_wip_entity_id, l_instance_id)
    LOOP

      debug('  instance_id    : '||wip_inst_rec.instance_id);
      debug('  serial_number  : '||wip_inst_rec.serial_number);
      debug('  instance_qty   : '||wip_inst_rec.quantity);

      -- eliminate replace rebuilds that are in the wip location
      IF NOT(replace_rebuild(wip_inst_rec.instance_id, l_replace_rebuilds)) THEN

        l_iir_ind := l_iir_ind + 1;
        l_ii_rltns_tbl(l_iir_ind).relationship_id        := fnd_api.g_miss_num;
        l_ii_rltns_tbl(l_iir_ind).object_id              := l_instance_id;
        l_ii_rltns_tbl(l_iir_ind).subject_id             := wip_inst_rec.instance_id;
        l_ii_rltns_tbl(l_iir_ind).relationship_type_code := 'COMPONENT-OF';

      ELSE
        debug('  this is a replace rebuild. ');
      END IF;

    END LOOP;

    debug('total components : '||l_ii_rltns_tbl.COUNT);

    IF l_ii_rltns_tbl.COUNT > 0 THEN

      api_log(p_pkg_name => 'csi_ii_relationships_pub',p_api_name => 'create_relationship');

      csi_ii_relationships_pub.create_relationship(
        p_api_version      => 1.0,
        p_commit           => fnd_api.g_false,
        p_init_msg_list    => fnd_api.g_true,
        p_validation_level => fnd_api.g_valid_level_full,
        p_relationship_tbl => l_ii_rltns_tbl,
        p_txn_rec          => l_csi_txn_rec,
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    debug('eam_wip_completion successful');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END eam_wip_completion;

  PROCEDURE eam_rebuildable_return(
    p_wip_entity_id    IN number,
    p_organization_id  IN number,
    p_instance_id      IN number,
    px_trx_error_rec   OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status    OUT nocopy varchar2)
  IS
    l_csi_txn_rec      csi_datastructures_pub.transaction_rec;
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csieamrr',
      p_file_segment2 => p_wip_entity_id);

    api_log('eam_rebuildable_return');

    debug('  Transaction Time  : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type  : EAM Rebuildable Return');
    debug('  Transaction ID    : '||p_wip_entity_id);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_csi_txn_rec.transaction_type_id     := 93;
    l_csi_txn_rec.source_transaction_date := sysdate;
    l_csi_txn_rec.transaction_date        := sysdate;
    l_csi_txn_rec.source_header_ref_id    := p_wip_entity_id;

    SELECT wip_entity_name
    INTO   l_csi_txn_rec.source_header_ref
    FROM   wip_entities
    WHERE  wip_entity_id   = p_wip_entity_id
    AND    organization_id = p_organization_id;

    l_csi_txn_rec.transaction_status_code := 'PENDING';

    debug('  instance_id     : '||p_instance_id);
    debug('  wip_entity_name : '||l_csi_txn_rec.source_header_ref);

    csi_process_txn_pvt.check_and_break_relation(
      p_instance_id   => p_instance_id,
      p_csi_txn_rec   => l_csi_txn_rec ,
      x_return_status => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('eam_rebuildable_return successful');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END eam_rebuildable_return;

END csi_wip_trxs_pkg;

/
