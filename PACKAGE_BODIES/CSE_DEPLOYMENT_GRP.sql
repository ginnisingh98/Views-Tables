--------------------------------------------------------
--  DDL for Package Body CSE_DEPLOYMENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_DEPLOYMENT_GRP" AS
/* $Header: CSEDPLGB.pls 120.21.12010000.7 2010/01/12 21:03:56 devijay ship $ */

  l_debug  varchar2(1) := NVL(fnd_profile.value('cse_debug_option'),'N');

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log,p_message);
      END IF;
    END IF;

  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE process_retirements(
    p_instance_id           IN     number,
    p_asset_id              IN     number,
    p_proceeds_of_sale      IN     number,
    p_cost_of_removal       IN     number,
    p_operational_flag      IN     varchar2 default 'N',
    p_financial_flag        IN     varchar2 default 'N',
    px_txn_rec              IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status            OUT nocopy varchar2)
  IS

    CURSOR inst_asset_cur IS
      SELECT instance_asset_id,
             instance_id,
             fa_asset_id,
             fa_book_type_code,
             fa_location_id
      FROM   csi_i_assets
      WHERE  instance_id = p_instance_id
      AND    fa_asset_id = p_asset_id
      AND    asset_quantity > 0
      AND    sysdate between nvl(active_start_date, sysdate-1) and nvl(active_end_date, sysdate+1);

    l_inst_asset_found           boolean := FALSE;
    l_asset_id                   number;

    l_location_type_code         varchar2(30);
    l_operational_status_code    varchar2(30);
    l_instance_usage_code        varchar2(30);
    l_accounting_class_code      varchar2(30);
    l_quantity                   number;
    l_last_vld_organization_id   number;
    l_object_version_number      number;


    l_source_instance_rec        csi_datastructures_pub.instance_rec;
    l_new_instance_rec           csi_datastructures_pub.instance_rec;
    l_source_instance_qty        number;
    l_new_instance_qty           number;

    l_u_instance_rec             csi_datastructures_pub.instance_rec;
    l_u_parties_tbl              csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl            csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl            csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl            csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl               csi_datastructures_pub.instance_asset_tbl;
    l_instance_ids_list          csi_datastructures_pub.id_tbl;

    l_msg_data                   varchar2(2000);
    l_msg_count                  number;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('inside api process_retirements');
    debug('  p_instance_id          : '||p_instance_id);
    debug('  p_asset_id             : '||p_asset_id);
    debug('  p_operational_flag     : '||p_operational_flag);
    debug('  p_financial_flag       : '||p_financial_flag);

    savepoint process_retirements;

    IF p_financial_flag = 'Y' THEN
      FOR inst_asset_rec in inst_asset_cur
      LOOP

        cse_fa_txn_pkg.asset_retirement(
          p_instance_id      => inst_asset_rec.instance_id,
          p_book_type_code   => inst_asset_rec.fa_book_type_code,
          p_asset_id         => inst_asset_rec.fa_asset_id,
          p_units            => px_txn_rec.transaction_quantity,
          p_trans_date       => px_txn_rec.source_transaction_date,
          p_trans_by         => px_txn_rec.transacted_by,
          px_txn_rec         => px_txn_rec,
          x_return_status    => l_return_status,
          x_error_message    => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        cse_fa_txn_pkg.populate_retirement_interface(
          p_csi_txn_id       => px_txn_rec.transaction_id,
          p_asset_id         => inst_asset_rec.fa_asset_id,
          p_book_type_code   => inst_asset_rec.fa_book_type_code,
          p_fa_location_id   => inst_asset_rec.fa_location_id,
          p_proceeds_of_sale => p_proceeds_of_sale,
          p_cost_of_removal  => p_cost_of_removal,
          p_retirement_units => px_txn_rec.transaction_quantity,
          p_retirement_date  => px_txn_rec.source_transaction_date,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END LOOP;
    END IF;

    IF p_operational_flag = 'Y' THEN
      debug('Operational Update :-');

      SELECT location_type_code,
             operational_status_code,
             instance_usage_code,
             accounting_class_code,
             quantity,
             last_vld_organization_id,
             object_version_number
      INTO   l_location_type_code,
             l_operational_status_code,
             l_instance_usage_code,
             l_accounting_class_code,
             l_quantity,
             l_last_vld_organization_id,
             l_object_version_number
      FROM   csi_item_instances
      WHERE  instance_id = p_instance_id;

      debug('  instance_usage_code    : '||l_instance_usage_code);
      debug('  acct_class_code        : '||l_accounting_class_code);
      debug('  location_type_code     : '||l_location_type_code);
      debug('  instance_quantity      : '||l_quantity);

      FOR inst_asset_rec IN inst_asset_cur
      LOOP
        l_inst_asset_found := TRUE;
        l_asset_id         := inst_asset_rec.fa_asset_id;
        exit;
      END LOOP;

      -- operational retirement without financial check for cia link
      IF l_instance_usage_code = 'IN_SERVICE' OR l_accounting_class_code = 'ASSET' THEN
        IF p_financial_flag = 'N' THEN

          IF l_inst_asset_found THEN
            fnd_message.set_name('CSE', 'CSE_WFM_RETIRE_FLAG_ERROR');
            fnd_message.set_token('ASSET_ID',l_asset_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;
      END IF; -- in_service or acct_class_code = 'ASSET'

      IF l_location_type_code = 'PROJECT' THEN
        IF NOT(l_inst_asset_found) THEN
          fnd_message.set_name('CSE', 'CSE_WFM_RETIRE_CIP_ERROR');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_location_type_code IN ('INVENTORY', 'WIP') THEN
        fnd_message.set_name('CSE', 'CSE_WFM_RETIRE_INT_ERROR');
        fnd_message.set_token('INST_ID', p_instance_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_quantity > px_txn_rec.transaction_quantity THEN
        -- partial retirement
        -- split
        l_source_instance_rec.instance_id := p_instance_id;
        l_source_instance_rec.vld_organization_id   := l_last_vld_organization_id;
        l_source_instance_rec.object_version_number := l_object_version_number;

        l_source_instance_qty  := l_quantity - px_txn_rec.transaction_quantity;
        l_new_instance_qty     := px_txn_rec.transaction_quantity;

        debug('Calling API csi_item_instance_pvt.split_item_instance');

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
          p_copy_asset_assignments => fnd_api.g_false,
          p_copy_pricing_attribs   => fnd_api.g_true,
          p_txn_rec                => px_txn_rec,
          x_new_instance_rec       => l_new_instance_rec,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('  new_instance_id      : '||l_new_instance_rec.instance_id);
        debug('  new_instance_quantity: '||l_new_instance_rec.quantity);

        l_u_instance_rec.instance_id := l_new_instance_rec.instance_id;

      ELSE
        -- full retirement
        l_u_instance_rec.instance_id := p_instance_id;
      END IF;


      SELECT object_version_number
      INTO   l_u_instance_rec.object_version_number
      FROM   csi_item_instances
      WHERE  instance_id = l_u_instance_rec.instance_id;

      l_u_instance_rec.active_end_date         := sysdate;
      l_u_instance_rec.instance_usage_code     := 'OUT_OF_SERVICE';
      l_u_instance_rec.operational_status_code := 'OUT_OF_SERVICE';

      debug('Calling API csi_item_instance_pub.update_item_instance');
      debug('  instance_id            : '||l_u_instance_rec.instance_id);
      debug('  active_end_date        : '||l_u_instance_rec.active_end_date);
      debug('  instance_usage_code    : '||l_u_instance_rec.instance_usage_code);
      debug('  operation_status_code  : '||l_u_instance_rec.operational_status_code);

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
        p_txn_rec               => px_txn_rec,
        x_instance_id_lst       => l_instance_ids_list,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF; -- operational_flag = 'Y'

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to process_retirements;
      x_return_status := fnd_api.g_ret_sts_error;
  END process_retirements;

  PROCEDURE rebuild_child_entities(
    p_instance_id           IN  number,
    x_t_party_tbl           OUT nocopy csi_process_txn_grp.txn_i_parties_tbl,
    x_t_pty_acct_tbl        OUT nocopy csi_process_txn_grp.txn_ip_accounts_tbl,
    x_t_ou_tbl              OUT nocopy csi_process_txn_grp.txn_org_units_tbl,
    x_t_price_tbl           OUT nocopy csi_process_txn_grp.txn_pricing_attribs_tbl,
    x_return_status         OUT nocopy varchar2)
  IS

    -- giid variables
    l_inst_rec             csi_datastructures_pub.instance_header_rec ;
    l_pty_tbl              csi_datastructures_pub.party_header_tbl  ;
    l_pty_acct_tbl         csi_datastructures_pub.party_account_header_tbl ;
    l_org_tbl              csi_datastructures_pub.org_units_header_tbl ;
    l_price_tbl            csi_datastructures_pub.pricing_attribs_tbl ;
    l_ea_tbl               csi_datastructures_pub.extend_attrib_tbl ;
    l_eav_tbl              csi_datastructures_pub.extend_attrib_values_tbl ;
    l_ia_tbl               csi_datastructures_pub.instance_asset_header_tbl;
    l_time_stamp           date := null;

    -- out variables build
    l_t_pty_tbl            csi_process_txn_grp.txn_i_parties_tbl ;
    l_t_pty_acct_tbl       csi_process_txn_grp.txn_ip_accounts_tbl ;
    l_t_org_tbl            csi_process_txn_grp.txn_org_units_tbl ;
    l_t_price_tbl          csi_process_txn_grp.txn_pricing_attribs_tbl ;

    xp_ind                 binary_integer := 0;
    xpa_ind                binary_integer := 0;
    xo_ind                 binary_integer := 0;
    xpr_ind                binary_integer := 0;
    xr_ind                 binary_integer := 0;

    l_msg_data             varchar2(2000);
    l_msg_count            number;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF nvl(p_instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      l_inst_rec.instance_id := p_instance_id;

      csi_item_instance_pub.get_item_instance_details(
        p_api_version           => 1.0,
        p_commit                => fnd_api.g_false,
        p_init_msg_list         => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_instance_rec          => l_inst_rec,
        p_get_parties           => fnd_api.g_true,
        p_party_header_tbl      => l_pty_tbl,
        p_get_accounts          => fnd_api.g_true,
        p_account_header_tbl    => l_pty_acct_tbl,
        p_get_org_assignments   => fnd_api.g_true,
        p_org_header_tbl        => l_org_tbl,
        p_get_pricing_attribs   => fnd_api.g_true,
        p_pricing_attrib_tbl    => l_price_tbl,
        p_get_ext_attribs       => fnd_api.g_false,
        p_ext_attrib_tbl        => l_eav_tbl,
        p_ext_attrib_def_tbl    => l_ea_tbl,
        p_get_asset_assignments => fnd_api.g_false,
        p_asset_header_tbl      => l_ia_tbl,
        p_resolve_id_columns    => fnd_api.g_false,
        p_time_stamp            => l_time_stamp,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_pty_tbl.count > 0 THEN

        FOR p_ind IN l_pty_tbl.FIRST .. l_pty_tbl.LAST
        LOOP
          IF nvl(l_pty_tbl(p_ind).active_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN

            xp_ind := xp_ind + 1;

            l_t_pty_tbl(xp_ind).instance_party_id     := fnd_api.g_miss_num;
            l_t_pty_tbl(xp_ind).parent_tbl_index      := 1;
            l_t_pty_tbl(xp_ind).instance_id           := p_instance_id;
            l_t_pty_tbl(xp_ind).party_source_table    := l_pty_tbl(p_ind).party_source_table;
            l_t_pty_tbl(xp_ind).party_id              := l_pty_tbl(p_ind).party_id;
            l_t_pty_tbl(xp_ind).relationship_type_code:= l_pty_tbl(p_ind).relationship_type_code;
            l_t_pty_tbl(xp_ind).contact_flag          := l_pty_tbl(p_ind).contact_flag;
            l_t_pty_tbl(xp_ind).contact_ip_id         := l_pty_tbl(p_ind).contact_ip_id;
            l_t_pty_tbl(xp_ind).active_start_date     := fnd_api.g_miss_date;
            l_t_pty_tbl(xp_ind).active_end_date       := fnd_api.g_miss_date;
            l_t_pty_tbl(xp_ind).context               := l_pty_tbl(p_ind).context;
            l_t_pty_tbl(xp_ind).attribute1            := l_pty_tbl(p_ind).attribute1;
            l_t_pty_tbl(xp_ind).attribute2            := l_pty_tbl(p_ind).attribute2;
            l_t_pty_tbl(xp_ind).attribute3            := l_pty_tbl(p_ind).attribute3;
            l_t_pty_tbl(xp_ind).attribute4            := l_pty_tbl(p_ind).attribute4;
            l_t_pty_tbl(xp_ind).attribute5            := l_pty_tbl(p_ind).attribute5;
            l_t_pty_tbl(xp_ind).attribute6            := l_pty_tbl(p_ind).attribute6;
            l_t_pty_tbl(xp_ind).attribute7            := l_pty_tbl(p_ind).attribute7;
            l_t_pty_tbl(xp_ind).attribute8            := l_pty_tbl(p_ind).attribute8;
            l_t_pty_tbl(xp_ind).attribute9            := l_pty_tbl(p_ind).attribute9;
            l_t_pty_tbl(xp_ind).attribute10           := l_pty_tbl(p_ind).attribute10;
            l_t_pty_tbl(xp_ind).attribute11           := l_pty_tbl(p_ind).attribute11;
            l_t_pty_tbl(xp_ind).attribute12           := l_pty_tbl(p_ind).attribute12;
            l_t_pty_tbl(xp_ind).attribute13           := l_pty_tbl(p_ind).attribute13;
            l_t_pty_tbl(xp_ind).attribute14           := l_pty_tbl(p_ind).attribute14;
            l_t_pty_tbl(xp_ind).attribute15           := l_pty_tbl(p_ind).attribute15;
            l_t_pty_tbl(xp_ind).object_version_number := 1;

            IF l_pty_acct_tbl.COUNT > 0 THEN
              FOR pa_ind IN l_pty_acct_tbl.FIRST .. l_pty_acct_tbl.LAST
              LOOP

                IF l_pty_acct_tbl(pa_ind).instance_party_id = l_pty_tbl(p_ind).instance_party_id
                   AND
                   nvl(l_pty_acct_tbl(pa_ind).active_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date
                THEN
                  xpa_ind := xpa_ind + 1;
                  l_t_pty_acct_tbl(xpa_ind).ip_account_id         := fnd_api.g_miss_num;
                  l_t_pty_acct_tbl(xpa_ind).parent_tbl_index      := xp_ind;
                  l_t_pty_acct_tbl(xpa_ind).instance_party_id     := fnd_api.g_miss_num;
                  l_t_pty_acct_tbl(xpa_ind).party_account_id      := l_pty_acct_tbl(pa_ind).party_account_id;
                  l_t_pty_acct_tbl(xpa_ind).relationship_type_code:= l_pty_acct_tbl(pa_ind).relationship_type_code;
                  l_t_pty_acct_tbl(xpa_ind).bill_to_address       := l_pty_acct_tbl(pa_ind).bill_to_address;
                  l_t_pty_acct_tbl(xpa_ind).ship_to_address       := l_pty_acct_tbl(pa_ind).ship_to_address;
                  l_t_pty_acct_tbl(xpa_ind).active_start_date     := fnd_api.g_miss_date;
                  l_t_pty_acct_tbl(xpa_ind).active_end_date       := fnd_api.g_miss_date;
                  l_t_pty_acct_tbl(xpa_ind).context               := l_pty_acct_tbl(pa_ind).context;
                  l_t_pty_acct_tbl(xpa_ind).attribute1            := l_pty_acct_tbl(pa_ind).attribute1;
                  l_t_pty_acct_tbl(xpa_ind).attribute2            := l_pty_acct_tbl(pa_ind).attribute2;
                  l_t_pty_acct_tbl(xpa_ind).attribute3            := l_pty_acct_tbl(pa_ind).attribute3;
                  l_t_pty_acct_tbl(xpa_ind).attribute4            := l_pty_acct_tbl(pa_ind).attribute4;
                  l_t_pty_acct_tbl(xpa_ind).attribute5            := l_pty_acct_tbl(pa_ind).attribute5;
                  l_t_pty_acct_tbl(xpa_ind).attribute6            := l_pty_acct_tbl(pa_ind).attribute6;
                  l_t_pty_acct_tbl(xpa_ind).attribute7            := l_pty_acct_tbl(pa_ind).attribute7;
                  l_t_pty_acct_tbl(xpa_ind).attribute8            := l_pty_acct_tbl(pa_ind).attribute8;
                  l_t_pty_acct_tbl(xpa_ind).attribute9            := l_pty_acct_tbl(pa_ind).attribute9;
                  l_t_pty_acct_tbl(xpa_ind).attribute10           := l_pty_acct_tbl(pa_ind).attribute10;
                  l_t_pty_acct_tbl(xpa_ind).attribute11           := l_pty_acct_tbl(pa_ind).attribute11;
                  l_t_pty_acct_tbl(xpa_ind).attribute12           := l_pty_acct_tbl(pa_ind).attribute12;
                  l_t_pty_acct_tbl(xpa_ind).attribute13           := l_pty_acct_tbl(pa_ind).attribute13;
                  l_t_pty_acct_tbl(xpa_ind).attribute14           := l_pty_acct_tbl(pa_ind).attribute14;
                  l_t_pty_acct_tbl(xpa_ind).attribute15           := l_pty_acct_tbl(pa_ind).attribute15;
                  l_t_pty_acct_tbl(xpa_ind).object_version_number := 1;
                END IF;

              END LOOP;

            END IF;
          END IF;
        END LOOP;

      END IF;

      IF l_org_tbl.count > 0 THEN
        FOR o_ind IN l_org_tbl.FIRST .. l_org_tbl.LAST
        LOOP
          IF nvl(l_org_tbl(o_ind).active_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
            xo_ind := xo_ind + 1;
            l_t_org_tbl(xo_ind).instance_ou_id        := fnd_api.g_miss_num;
            l_t_org_tbl(xo_ind).parent_tbl_index      := 1;
            l_t_org_tbl(xo_ind).instance_id           := p_instance_id;
            l_t_org_tbl(xo_ind).operating_unit_id     := l_org_tbl(o_ind).operating_unit_id;
            l_t_org_tbl(xo_ind).relationship_type_code:= l_org_tbl(o_ind).relationship_type_code;
            l_t_org_tbl(xo_ind).active_start_date     := fnd_api.g_miss_date;
            l_t_org_tbl(xo_ind).active_end_date       := fnd_api.g_miss_date;
            l_t_org_tbl(xo_ind).context               := l_org_tbl(o_ind).context;
            l_t_org_tbl(xo_ind).attribute1            := l_org_tbl(o_ind).attribute1;
            l_t_org_tbl(xo_ind).attribute2            := l_org_tbl(o_ind).attribute2;
            l_t_org_tbl(xo_ind).attribute3            := l_org_tbl(o_ind).attribute3;
            l_t_org_tbl(xo_ind).attribute4            := l_org_tbl(o_ind).attribute4;
            l_t_org_tbl(xo_ind).attribute5            := l_org_tbl(o_ind).attribute5;
            l_t_org_tbl(xo_ind).attribute6            := l_org_tbl(o_ind).attribute6;
            l_t_org_tbl(xo_ind).attribute7            := l_org_tbl(o_ind).attribute7;
            l_t_org_tbl(xo_ind).attribute8            := l_org_tbl(o_ind).attribute8;
            l_t_org_tbl(xo_ind).attribute9            := l_org_tbl(o_ind).attribute9;
            l_t_org_tbl(xo_ind).attribute10           := l_org_tbl(o_ind).attribute10;
            l_t_org_tbl(xo_ind).attribute11           := l_org_tbl(o_ind).attribute11;
            l_t_org_tbl(xo_ind).attribute12           := l_org_tbl(o_ind).attribute12;
            l_t_org_tbl(xo_ind).attribute13           := l_org_tbl(o_ind).attribute13;
            l_t_org_tbl(xo_ind).attribute14           := l_org_tbl(o_ind).attribute14;
            l_t_org_tbl(xo_ind).attribute15           := l_org_tbl(o_ind).attribute15;
            l_t_org_tbl(xo_ind).object_version_number := 1;
          END IF;
        END LOOP;
      END IF;

      IF l_price_tbl.count > 0 THEN
        FOR pr_ind IN l_price_tbl.FIRST .. l_price_tbl.LAST
        LOOP
          IF nvl(l_price_tbl(pr_ind).active_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
            xpr_ind := xpr_ind + 1;
          END IF;
        END LOOP;
      END IF;

    END IF;

    x_t_party_tbl     := l_t_pty_tbl;
    x_t_pty_acct_tbl  := l_t_pty_acct_tbl;
    x_t_ou_tbl        := l_t_org_tbl;
    x_t_price_tbl     := l_t_price_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END rebuild_child_entities;

/*---------------------------------------------------------------*/
/* Procedure name:  interface_nl_to_pa                           */
/* Description :    Added for Bug 8670632                        */
/*		    This procedure is used to interface the      */
/*                  project transfer transaction to expenditures */
/*                  in projects.                                 */
/*---------------------------------------------------------------*/

 PROCEDURE interface_nl_to_pa(
    p_trf_pa_attr_rec IN cse_datastructures_pub.Proj_Itm_Insv_PA_ATTR_REC_TYPE,
    p_conc_request_id    IN NUMBER ,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_error_message      OUT NOCOPY VARCHAR2)
  IS
    l_api_name       CONSTANT  VARCHAR2(30) := 'cse_deployment_grp';
    l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_error_message            VARCHAR2(2000);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_api_version              NUMBER         DEFAULT  1.0;
    l_commit                   VARCHAR2(1)    DEFAULT  FND_API.G_FALSE;
    l_init_msg_list            VARCHAR2(1)    DEFAULT  FND_API.G_TRUE;
    l_validation_level         NUMBER         DEFAULT  FND_API.G_VALID_LEVEL_FULL;
    l_active_instance_only     VARCHAR2(1)    DEFAULT  FND_API.G_TRUE;
    l_txn_rec                  csi_datastructures_pub.transaction_rec;
    l_asset_location_rec       csi_datastructures_pub.instance_asset_location_rec;
    l_asset_location_tbl       csi_datastructures_pub.instance_asset_location_tbl;
    l_nl_pa_interface_tbl      CSE_IPA_TRANS_PKG.nl_pa_interface_tbl_type;
    l_burden_cost_sum          NUMBER;
    l_qty_sum                  NUMBER;
    l_sum_of_qty               NUMBER;
    l_fa_location_id           NUMBER;
    l_attribute8               VARCHAR2(150);
    l_attribute9               VARCHAR2(150);
    l_attribute10              VARCHAR2(150);
    l_proj_itm_trf_qty        NUMBER;
    l_hz_location_id           NUMBER;
    i                          PLS_INTEGER := 0;
    l_org_id                   NUMBER;
    l_incurred_by_org_id       PA_EXPENDITURES_ALL.INCURRED_BY_ORGANIZATION_ID%TYPE;
    l_item_name                MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
    l_user_id                  NUMBER  DEFAULT FND_GLOBAL.USER_ID;
    l_transaction_source       PA_EXPENDITURE_ITEMS_ALL.TRANSACTION_SOURCE%TYPE;
    l_sysdate                  DATE:=sysdate;
    l_ref_sufix                NUMBER;
    l_project_number           VARCHAR2(25);
    l_task_number              VARCHAR2(25);
    l_from_project_number      VARCHAR2(25);
    l_from_task_number         VARCHAR2(25);
    l_organization_name        VARCHAR2(240);
    l_app_short_name           VARCHAR2(8):='CSE';
    TYPE exp_item_rec IS RECORD (
      expenditure_item_id number,
      expenditure_id      number,
      quantity            number,
      split_flag          varchar2(1),
      split_quantity      number);

    l_exp_item_rec  exp_item_rec;

    CURSOR ei_cur IS
      SELECT item.expenditure_item_id,
             item.project_id,
             item.task_id,
             item.transaction_source,
             item.org_id,
             item.expenditure_type,
             item.expenditure_item_date,
             item.denom_currency_code,
             item.attribute6,
             item.attribute7,
             item.quantity        quantity,
             item.raw_cost        raw_cost,
             item.denom_raw_cost  denom_raw_cost,
             item.denom_raw_cost/item.quantity unit_denom_raw_cost,
             item.raw_cost_rate,
             item.burden_cost     burden_cost,
             item.burden_cost/item.quantity burden_cost_rate,
             item.override_to_organization_id,
             item.system_linkage_function,
             item.orig_transaction_reference,
             dist.dr_code_combination_id,
             dist.cr_code_combination_id,
             dist.gl_date,
             dist.acct_raw_cost,
             dist.system_reference1,
             dist.system_reference2,
             dist.system_reference3,
             dist.system_reference4,
	     dist.system_reference5,
             exp.expenditure_id,
             exp.expenditure_ending_date,
             exp.incurred_by_organization_id
      FROM   pa_expenditure_items_all        item,
             pa_cost_distribution_lines_all  dist,
             pa_expenditures_all             exp
      WHERE  item.transaction_source IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
      AND    item.project_id          = p_trf_pa_attr_rec.project_id
      AND    item.task_id             = p_trf_pa_attr_rec.task_id
      AND    item.attribute8         IS null
      AND    item.attribute9         IS null
      AND    item.attribute10        IS null
      AND    item.quantity            > 0
      AND    item.attribute6          = l_item_name
      AND    nvl(item.attribute7, '**xyz**') = NVL(p_trf_pa_attr_rec.serial_number, '**xyz**')
      AND    nvl(item.net_zero_adjustment_flag, 'N') <> 'Y'
      AND    dist.expenditure_item_id = item.expenditure_item_id
      AND    dist.line_type           = 'R'
      AND    nvl(dist.reversed_flag, 'N') <> 'Y'
      AND    dist.cr_code_combination_id IS NOT NULL
      AND    dist.dr_code_combination_id IS NOT NULL
      AND    exp.expenditure_id       = item.expenditure_id;

    l_paapi_status  NUMBER;
    l_found         BOOLEAN:=FALSE;

Cursor txn_intf_csr IS
      SELECT transaction_source,
             batch_name,
             expenditure_ending_date,
             employee_number,
             organization_name,
             expenditure_item_date,
             project_number,
             task_number,
             expenditure_type,
             non_labor_resource,
             non_labor_resource_org_name,
             quantity, raw_cost,
             expenditure_comment,
             transaction_status_code,
             transaction_rejection_code,
             expenditure_id,
             orig_transaction_reference,
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
             raw_cost_rate,
             interface_id,
             unmatched_negative_txn_flag,
             expenditure_item_id,
             org_id,
             dr_code_combination_id,
             cr_code_combination_id,
             cdl_system_reference1,
             cdl_system_reference2,
             cdl_system_reference3,
             cdl_system_reference4,
	     cdl_system_reference5,
             gl_date,
             burdened_cost,
             burdened_cost_rate,
             system_linkage,
             txn_interface_id,
             user_transaction_source,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             receipt_currency_amount,
             receipt_currency_code,
             receipt_exchange_rate,
             denom_currency_code,
             denom_raw_cost,
             denom_burdened_cost,
             acct_rate_date,
             acct_rate_type,
             acct_exchange_rate,
             acct_raw_cost,
             acct_burdened_cost,
             acct_exchange_rounding_limit,
             project_currency_code,
             project_rate_date,
             project_rate_type,
             project_exchange_rate,
             orig_exp_txn_reference1,
             orig_exp_txn_reference2,
             orig_exp_txn_reference3,
             orig_user_exp_txn_reference,
             vendor_number,
             override_to_organization_name,
             reversed_orig_txn_reference,
             billable_flag,
             person_business_group_name,
             override_to_organization_id,
             denom_raw_cost/quantity unit_denom_raw_cost
        FROM pa_transaction_interface_all
       WHERE transaction_source IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
         AND project_number = l_from_project_number
         AND task_number = l_from_task_number
         AND attribute8 IS NULL
         AND attribute9 IS NULL
         AND attribute10 IS NULL
         AND quantity > 0
         AND attribute6          = l_item_name
         AND nvl(attribute7, '**xyz**') = NVL(p_trf_pa_attr_rec.serial_number, '**xyz**')
         AND ROWNUM=1;

    CURSOR c_Business_Group_cur( c_org_id NUMBER ) IS
    SELECT ho.name
    FROM   hr_all_organization_units ho, hr_all_organization_units hoc
    WHERE  hoc.organization_id =  c_org_id
    AND    ho.organization_id  = hoc.business_group_id  ;

    l_Business_Group_rec   c_Business_Group_cur%ROWTYPE;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_message := NULL;
    cse_util_pkg.set_debug;

    debug('Inside API cse_deployment_grp.interface_nl_to_pa');

    debug('  inventory_item_id  : '||p_trf_pa_attr_rec.item_id);
    debug('  organization_id    : '||p_trf_pa_attr_rec.inv_master_org_id);
    debug('  project_id         : '||p_trf_pa_attr_rec.project_id);
    debug('  task_id            : '||p_trf_pa_attr_rec.task_id);
    debug('  serial_number      : '||p_trf_pa_attr_rec.serial_number);
    debug('  transaction_id     : '||p_trf_pa_attr_rec.transaction_id);
    debug('  in_service_qty     : '||p_trf_pa_attr_rec.quantity);
    debug('  to_project_id      : '||p_trf_pa_attr_rec.to_project_id);
    debug('  to_task_id         : '||p_trf_pa_attr_rec.to_task_id);
    debug('  instance_id        : '||p_trf_pa_attr_rec.instance_id);

    SELECT concatenated_segments
    INTO   l_item_name
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = p_trf_pa_attr_rec.item_id
    AND    organization_id   = p_trf_pa_attr_rec.inv_master_org_id;

    debug('  item               : '||l_item_name);

    SELECT segment1
    INTO   l_project_number
    FROM   pa_projects_all
    WHERE  project_id = p_trf_pa_attr_rec.to_project_id;

    SELECT task_number
    INTO   l_task_number
    FROM   pa_tasks
    WHERE  task_id = p_trf_pa_attr_rec.to_task_id;

    l_proj_itm_trf_qty := p_trf_pa_attr_rec.quantity;
    i := 0;

    FOR ei_rec IN ei_cur LOOP
      l_found:=TRUE;
      debug('cursor record # '||ei_cur%rowcount);

      debug('  expenditure_item_id  : '||ei_rec.expenditure_item_id);
      debug('  quantity             : '||ei_rec.quantity);
      debug('  l_proj_itm_trf_qty  : '||l_proj_itm_trf_qty);
      dbms_application_info.set_client_info(ei_rec.org_id);
      IF l_proj_itm_trf_qty = 0 THEN
        EXIT;
      END IF;

      IF ei_rec.quantity <= l_proj_itm_trf_qty THEN
        l_proj_itm_trf_qty := l_proj_itm_trf_qty - ei_rec.quantity;
        l_exp_item_rec.expenditure_item_id := ei_rec.expenditure_item_id;
        l_exp_item_rec.expenditure_id      := ei_rec.expenditure_id;
        l_exp_item_rec.quantity            := ei_rec.quantity;
        l_exp_item_rec.split_flag          := 'N';
      ELSE
        l_exp_item_rec.expenditure_item_id := ei_rec.expenditure_item_id;
        l_exp_item_rec.expenditure_id      := ei_rec.expenditure_id;
        l_exp_item_rec.quantity            := l_proj_itm_trf_qty;
        l_exp_item_rec.split_flag          := 'Y';
        l_exp_item_rec.split_quantity      := ei_rec.quantity - l_proj_itm_trf_qty;
      END IF;

      debug('Inside API pa_nl_installed.reverse_eib_ei');
      debug('expenditure_item_id : '||l_exp_item_rec.expenditure_item_id);
     -- This code does the reversal
     pa_nl_installed.reverse_eib_ei(
        x_exp_item_id          => l_exp_item_rec.expenditure_item_id,
        x_expenditure_id       => l_exp_item_rec.expenditure_id,
        x_transfer_status_code => 'V',
        x_status               => l_paapi_status);

      IF l_paapi_status <> 0 THEN
        l_error_message := sqlerrm;
        RAISE fnd_api.g_exc_error;
      END IF;

      SELECT name
      INTO   l_organization_name
      FROM   hr_organization_units
      WHERE  organization_id =
             nvl(ei_rec.override_to_organization_id, ei_rec.incurred_by_organization_id);

      i := i+1;

      debug('capitalizable record # '||i);
      debug('  capitalizable exp_item_id : '||l_exp_item_rec.expenditure_item_id);
      debug('  capitalizable quantity    : '||l_exp_item_rec.quantity);

      SELECT csi_pa_interface_s.nextval
      INTO   l_ref_sufix
      FROM   sys.dual;

      OPEN  c_Business_Group_cur( ei_rec.org_id ) ;
      FETCH c_Business_Group_cur INTO l_Business_Group_rec;
      CLOSE c_Business_Group_cur;

      l_nl_pa_interface_tbl(i).transaction_source      := ei_rec.transaction_source;

      IF( p_trf_pa_attr_rec.transaction_id = FND_API.G_MISS_NUM)
	THEN
	  l_nl_pa_interface_tbl(i).batch_name		:= FND_API.G_MISS_CHAR;
	ELSE
	  l_nl_pa_interface_tbl(i).batch_name		:= p_trf_pa_attr_rec.transaction_id;
      END IF;

      l_nl_pa_interface_tbl(i).expenditure_ending_date := ei_rec.expenditure_ending_date;
      l_nl_pa_interface_tbl(i).employee_number         := null;
      l_nl_pa_interface_tbl(i).organization_name       := l_organization_name;
      l_nl_pa_interface_tbl(i).expenditure_item_date   := ei_rec.expenditure_item_date;
      l_nl_pa_interface_tbl(i).project_number          := l_project_number;
      l_nl_pa_interface_tbl(i).task_number             := l_task_number;
      l_nl_pa_interface_tbl(i).expenditure_type        := ei_rec.expenditure_type;
      l_nl_pa_interface_tbl(i).expenditure_comment     := 'ENTERPRISE INSTALL BASE';
      l_nl_pa_interface_tbl(i).transaction_status_code := 'P';
      l_nl_pa_interface_tbl(i).orig_transaction_reference
                               := p_trf_pa_attr_rec.instance_id||'-'||l_ref_sufix;
      l_nl_pa_interface_tbl(i).attribute_category      := NULL;
      l_nl_pa_interface_tbl(i).attribute1              := NULL;
      l_nl_pa_interface_tbl(i).attribute2              := NULL;
      l_nl_pa_interface_tbl(i).attribute3              := NULL;
      l_nl_pa_interface_tbl(i).attribute4              := NULL;
      l_nl_pa_interface_tbl(i).attribute5              := NULL;
      l_nl_pa_interface_tbl(i).attribute6              := l_item_name;
      l_nl_pa_interface_tbl(i).attribute7              := p_trf_pa_attr_rec.serial_number;
      l_nl_pa_interface_tbl(i).attribute8              := Null;
      l_nl_pa_interface_tbl(i).attribute9              := Null;
      l_nl_pa_interface_tbl(i).attribute10             := Null;
      l_nl_pa_interface_tbl(i).interface_id            := NULL;
      l_nl_pa_interface_tbl(i).unmatched_negative_txn_flag := 'Y';
      l_nl_pa_interface_tbl(i).org_id                  := ei_rec.org_id;
      l_nl_pa_interface_tbl(i).dr_code_combination_id  := ei_rec.dr_code_combination_id;
      l_nl_pa_interface_tbl(i).cr_code_combination_id  := ei_rec.cr_code_combination_id;
      l_nl_pa_interface_tbl(i).gl_date                 := ei_rec.gl_date;
      l_nl_pa_interface_tbl(i).system_linkage          := ei_rec.system_linkage_function;
      l_nl_pa_interface_tbl(i).person_business_group_name := l_Business_Group_rec.name;
      l_nl_pa_interface_tbl(i).inventory_item_id  := p_trf_pa_attr_rec.item_id;

      IF ei_rec.transaction_source = 'CSE_PO_RECEIPT' THEN
        BEGIN
          SELECT segment1
          INTO   l_nl_pa_interface_tbl(i).vendor_number
          FROM   po_vendors
          WHERE  vendor_id =  ei_rec.system_reference1;
        EXCEPTION
          WHEN no_data_found THEN
            l_nl_pa_interface_tbl(i).system_linkage     := 'INV';
        END;
      END IF;
        l_nl_pa_interface_tbl(i).user_transaction_source := 'ENTERPRISE INSTALL BASE';
       --Added for bug 8670632 --
        l_nl_pa_interface_tbl(i).cdl_system_reference1   := ei_rec.system_reference1;
        l_nl_pa_interface_tbl(i).cdl_system_reference2   := ei_rec.system_reference2;
        l_nl_pa_interface_tbl(i).cdl_system_reference3   := ei_rec.system_reference3;
        l_nl_pa_interface_tbl(i).cdl_system_reference4   := ei_rec.system_reference4;
        IF ei_rec.transaction_source = 'CSE_PO_RECEIPT' AND ei_rec.system_reference5 is NULL THEN
          l_nl_pa_interface_tbl(i).cdl_system_reference5 := cse_asset_util_pkg.get_rcv_sub_ledger_id(ei_rec.system_reference4);
        ELSE
          l_nl_pa_interface_tbl(i).cdl_system_reference5   := ei_rec.system_reference5;
        END IF;

        debug('  system_reference4   : '||ei_rec.system_reference4);
        debug('  system_reference5   : '||ei_rec.system_reference5);
        debug('  system_reference5   : '||l_nl_pa_interface_tbl(i).cdl_system_reference5);
       --Added for bug 8670632 --

      l_nl_pa_interface_tbl(i).last_update_date        := l_sysdate;
      l_nl_pa_interface_tbl(i).last_updated_by         := l_user_id;
      l_nl_pa_interface_tbl(i).creation_date           := l_sysdate;
      l_nl_pa_interface_tbl(i).created_by              := l_user_id;
      l_nl_pa_interface_tbl(i).billable_flag           := 'Y';
      l_nl_pa_interface_tbl(i).quantity                := l_exp_item_rec.quantity;

      l_nl_pa_interface_tbl(i).denom_raw_cost          :=
        ei_rec.unit_denom_raw_cost * l_exp_item_rec.quantity;

      l_nl_pa_interface_tbl(i).acct_raw_cost           :=
        ei_rec.unit_denom_raw_cost * l_exp_item_rec.quantity;

      IF l_exp_item_rec.split_flag = 'Y' THEN

        i := i + 1;

        debug('  spillover record # '||i);
        debug('  spillover exp_item_id : '|| l_exp_item_rec.expenditure_item_id);
        debug('  spillover quantity    : '|| l_exp_item_rec.split_quantity);

        l_nl_pa_interface_tbl(i) := l_nl_pa_interface_tbl(i-1);

        SELECT csi_pa_interface_s.nextval
        INTO   l_ref_sufix
        FROM   sys.dual;

        SELECT segment1
          INTO l_nl_pa_interface_tbl(i).project_number
          FROM pa_projects_all
         WHERE project_id = p_trf_pa_attr_rec.project_id;

        SELECT task_number
          INTO l_nl_pa_interface_tbl(i).task_number
          FROM pa_tasks
         WHERE task_id = p_trf_pa_attr_rec.task_id;

        l_nl_pa_interface_tbl(i).orig_transaction_reference := p_trf_pa_attr_rec.transaction_id;
        l_nl_pa_interface_tbl(i).attribute8            := null;
        l_nl_pa_interface_tbl(i).attribute9            := null;
        l_nl_pa_interface_tbl(i).attribute10           := null;
        l_nl_pa_interface_tbl(i).quantity              := l_exp_item_rec.split_quantity;
        l_nl_pa_interface_tbl(i).denom_raw_cost        :=
                                 ei_rec.unit_denom_raw_cost * l_exp_item_rec.split_quantity;
        l_nl_pa_interface_tbl(i).acct_raw_cost         :=
                                 ei_rec.unit_denom_raw_cost * l_exp_item_rec.split_quantity;
        EXIT;
      END IF;

    END LOOP;

    -- Here we write the logic for the records not found in pa_expenditure_items_all
    -- but found in pa_transaction_interface_all
    BEGIN
      SELECT segment1
        INTO l_from_project_number
        FROM pa_projects_all
       WHERE project_id = p_trf_pa_attr_rec.project_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    BEGIN
      SELECT task_number
        INTO l_from_task_number
        FROM pa_tasks
       WHERE task_id = p_trf_pa_attr_rec.task_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;


    IF NOT(l_found)
    THEN
     debug('Since the record was not found in pa_expenditure_items_all checking in pa_txn_intf_all ');
     FOR l_txn_intf_csr IN txn_intf_csr
     LOOP
      l_found:=TRUE;
       i := i+1;
      debug('Record found in pa_txn_intf_all ');
       SELECT csi_pa_interface_s.nextval
         INTO l_ref_sufix
         FROM sys.dual;

        IF l_txn_intf_csr.transaction_source = 'CSE_PO_RECEIPT'
        THEN
         l_nl_pa_interface_tbl(i).vendor_number :=l_txn_intf_csr.vendor_number;
         IF l_nl_pa_interface_tbl(i).vendor_number IS NULL
         THEN
            l_nl_pa_interface_tbl(i).system_linkage  := 'INV';
         END IF;
        END IF;

        OPEN  c_Business_Group_cur( l_txn_intf_csr.org_id ) ;
        FETCH c_Business_Group_cur INTO l_Business_Group_rec;
        CLOSE c_Business_Group_cur;

        -- Here we build a record that will have a -ve qty
         l_nl_pa_interface_tbl(i).transaction_source := l_txn_intf_csr.transaction_source;
         l_nl_pa_interface_tbl(i).batch_name         := l_txn_intf_csr.batch_name; --p_trf_pa_attr_rec.transaction_id;
         l_nl_pa_interface_tbl(i).expenditure_ending_date :=l_txn_intf_csr.expenditure_ending_date;
         l_nl_pa_interface_tbl(i).employee_number    :=NULL;
         l_nl_pa_interface_tbl(i).organization_name  :=l_txn_intf_csr.organization_name;
         l_nl_pa_interface_tbl(i).expenditure_item_date :=l_txn_intf_csr.expenditure_item_date;
         l_nl_pa_interface_tbl(i).project_number     :=l_from_project_number;
         l_nl_pa_interface_tbl(i).task_number        := l_from_task_number;
         l_nl_pa_interface_tbl(i).expenditure_type   :=l_txn_intf_csr.expenditure_type;
         l_nl_pa_interface_tbl(i).quantity           := (0-p_trf_pa_attr_rec.quantity);
         l_nl_pa_interface_tbl(i).expenditure_comment:='ENTERPRISE INSTALL BASE';
         l_nl_pa_interface_tbl(i).transaction_status_code:='P';
         l_nl_pa_interface_tbl(i).expenditure_id     := l_txn_intf_csr.expenditure_id;
         l_nl_pa_interface_tbl(i).orig_transaction_reference :=p_trf_pa_attr_rec.transaction_id||'-'||l_ref_sufix;
         l_nl_pa_interface_tbl(i).attribute_category := null;
         l_nl_pa_interface_tbl(i).attribute1         := null;
         l_nl_pa_interface_tbl(i).attribute2         := null;
         l_nl_pa_interface_tbl(i).attribute3         := null;
         l_nl_pa_interface_tbl(i).attribute4         := null;
         l_nl_pa_interface_tbl(i).attribute5         := null;
         l_nl_pa_interface_tbl(i).attribute6         := l_item_name;
         l_nl_pa_interface_tbl(i).attribute7         := p_trf_pa_attr_rec.serial_number;
         l_nl_pa_interface_tbl(i).attribute8         := Null;
         l_nl_pa_interface_tbl(i).attribute9         := Null;
         l_nl_pa_interface_tbl(i).attribute10        := Null;
         l_nl_pa_interface_tbl(i).interface_id       := NULL;
         l_nl_pa_interface_tbl(i).unmatched_negative_txn_flag:='Y';
         l_nl_pa_interface_tbl(i).expenditure_item_id:=l_txn_intf_csr.expenditure_item_id;
         l_nl_pa_interface_tbl(i).org_id             :=l_txn_intf_csr.org_id;
         l_nl_pa_interface_tbl(i).dr_code_combination_id := l_txn_intf_csr.dr_code_combination_id;
         l_nl_pa_interface_tbl(i).cr_code_combination_id := l_txn_intf_csr.cr_code_combination_id;
         l_nl_pa_interface_tbl(i).gl_date            :=l_txn_intf_csr.gl_date;
         l_nl_pa_interface_tbl(i).system_linkage     := l_txn_intf_csr.system_linkage;
         l_nl_pa_interface_tbl(i).user_transaction_source := 'ENTERPRISE INSTALL BASE';
       --Added for bug 8670632 --
        l_nl_pa_interface_tbl(i).cdl_system_reference1   := l_txn_intf_csr.cdl_system_reference1;
        l_nl_pa_interface_tbl(i).cdl_system_reference2   := l_txn_intf_csr.cdl_system_reference2;
        l_nl_pa_interface_tbl(i).cdl_system_reference3   := l_txn_intf_csr.cdl_system_reference3;
        l_nl_pa_interface_tbl(i).cdl_system_reference4   := l_txn_intf_csr.cdl_system_reference4;
        IF l_txn_intf_csr.transaction_source = 'CSE_PO_RECEIPT' AND l_txn_intf_csr.cdl_system_reference5 is NULL THEN
          l_nl_pa_interface_tbl(i).cdl_system_reference5 := cse_asset_util_pkg.get_rcv_sub_ledger_id(l_txn_intf_csr.cdl_system_reference4);
        ELSE
          l_nl_pa_interface_tbl(i).cdl_system_reference5   := l_txn_intf_csr.cdl_system_reference5;
        END IF;
       --Added for bug 8670632 --
         l_nl_pa_interface_tbl(i).last_update_date   := l_sysdate;
         l_nl_pa_interface_tbl(i).last_updated_by    := l_user_id;
         l_nl_pa_interface_tbl(i).creation_date      := l_sysdate;
         l_nl_pa_interface_tbl(i).created_by         := l_user_id;
         l_nl_pa_interface_tbl(i).person_business_group_name := l_Business_Group_rec.name;
	 l_nl_pa_interface_tbl(i).inventory_item_id  := p_trf_pa_attr_rec.item_id;
         l_nl_pa_interface_tbl(i).denom_raw_cost     :=
             -1 * (l_txn_intf_csr.unit_denom_raw_cost * p_trf_pa_attr_rec.quantity);

         l_nl_pa_interface_tbl(i).acct_raw_cost      :=
             -1 * (l_txn_intf_csr.unit_denom_raw_cost * p_trf_pa_attr_rec.quantity);

         l_nl_pa_interface_tbl(i).billable_flag      := l_txn_intf_csr.billable_flag;

        -- Here we build a new record with +ve quantity and new proj_number and new task_number
        i := i + 1;

        l_nl_pa_interface_tbl(i) := l_nl_pa_interface_tbl(i-1);

        SELECT csi_pa_interface_s.nextval
        INTO   l_ref_sufix
        FROM   sys.dual;

        SELECT segment1
          INTO l_nl_pa_interface_tbl(i).project_number
          FROM pa_projects_all
         WHERE project_id = p_trf_pa_attr_rec.to_project_id;

        SELECT task_number
          INTO l_nl_pa_interface_tbl(i).task_number
          FROM pa_tasks
         WHERE task_id = p_trf_pa_attr_rec.to_task_id;

        l_nl_pa_interface_tbl(i).orig_transaction_reference := p_trf_pa_attr_rec.transaction_id||'-'||l_ref_sufix;
        l_nl_pa_interface_tbl(i).attribute8            := null;
        l_nl_pa_interface_tbl(i).attribute9            := null;
        l_nl_pa_interface_tbl(i).attribute10           := null;
        l_nl_pa_interface_tbl(i).quantity              := p_trf_pa_attr_rec.quantity;

        l_nl_pa_interface_tbl(i).denom_raw_cost        :=
                                 l_txn_intf_csr.unit_denom_raw_cost * p_trf_pa_attr_rec.quantity;

        l_nl_pa_interface_tbl(i).acct_raw_cost         :=
                                 l_txn_intf_csr.unit_denom_raw_cost * p_trf_pa_attr_rec.quantity;

        EXIT;

     END LOOP;
    END IF;

    debug('l_nl_pa_interface_tbl.count : '||l_nl_pa_interface_tbl.COUNT);

    IF l_nl_pa_interface_tbl.COUNT > 0
    THEN
      debug('Calling API cse_ipa_trans_pkg.populate_pa_interface');
      cse_ipa_trans_pkg.populate_pa_interface(
        p_nl_pa_interface_tbl => l_nl_pa_interface_tbl,
        x_return_status       => l_return_status,
        x_error_message       => l_error_message);
      IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
        debug('error_ message : '||l_error_message);
        RAISE fnd_api.g_exc_error;
      END IF;

      --update transaction record with new txn_status_code = 'INTERFACE_TO_PA'
 /*   --commented for bug 8670632 --
      l_txn_rec                         := CSE_UTIL_PKG.init_txn_rec;
      l_txn_rec.transaction_id          := p_trf_pa_attr_rec.transaction_id;
      l_txn_rec.source_group_ref_id     := p_conc_request_id;
      l_txn_rec.transaction_status_code := cse_datastructures_pub.G_INTERFACED_TO_PA;
       select object_version_number
         into l_txn_rec.object_version_number
         from csi_transactions
        where transaction_id = l_txn_rec.transaction_id;
      l_txn_rec.transaction_date        := sysdate;
      l_txn_rec.source_transaction_date := sysdate;
      l_txn_rec.transaction_type_id:= 152; --cse_util_pkg.get_txn_type_id('PROJECT_TRANSFER', l_app_short_name);

      debug('Calling API csi_transactions_pvt.update_transactions');
      debug(' transaction_id : '||l_txn_rec.transaction_id);

      csi_transactions_pvt.update_transactions(
        p_api_version      => l_api_version,
        p_init_msg_list    => l_init_msg_list,
        p_commit           => l_commit,
        p_validation_level => l_validation_level,
        p_transaction_rec  => l_txn_rec,
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data);

      IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      --commented for bug 8670632 --
*/
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := l_return_status;
      x_error_message := l_error_message;
      debug('Error in cse_deployment_grp.interface_nl_to_pa : '||x_error_message);
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG',l_api_name||'='|| SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      debug('Inside others exception in cse_deployment_grp.interface_nl_to_pa : ' ||x_error_message);
  END interface_nl_to_pa;
--  Added for 8670632--

  PROCEDURE process_transaction (
    p_instance_tbl          IN            txn_instances_tbl,
    p_dest_location_tbl     IN            dest_location_tbl,
    p_ext_attrib_values_tbl IN OUT NOCOPY txn_ext_attrib_values_tbl,
    p_txn_tbl               IN OUT NOCOPY transaction_tbl,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_error_msg             OUT NOCOPY    VARCHAR2 )
  IS
    l_txn_error_rec         csi_datastructures_pub.transaction_error_rec ;
    l_txn_rec               csi_datastructures_pub.transaction_rec ;
    l_t_inst_tbl            csi_process_txn_grp.txn_instances_tbl ;
    l_t_party_tbl           csi_process_txn_grp.txn_i_parties_tbl ;
    l_t_pty_acct_tbl        csi_process_txn_grp.txn_ip_accounts_tbl ;
    l_t_ou_tbl              csi_process_txn_grp.txn_org_units_tbl ;
    l_t_eav_tbl             csi_process_txn_grp.txn_ext_attrib_values_tbl ;
    l_t_price_tbl           csi_process_txn_grp.txn_pricing_attribs_tbl ;
    l_t_ia_tbl              csi_process_txn_grp.txn_instance_asset_tbl ;
    l_t_iir_tbl             csi_process_txn_grp.txn_ii_relationships_tbl ;
    l_trf_pa_attr_rec       cse_datastructures_pub.Proj_Itm_Insv_PA_ATTR_REC_TYPE; --Added for bug 8670632
    l_return_status         varchar2(1);
    l_msg_data              varchar2(2000);
    l_msg_count             number ;
    l_msg_index             number ;
    l_error_msg             varchar2(2000);

    ind                     binary_integer := 0;
    l_dest_location_rec     csi_process_txn_grp.dest_location_rec ;
    l_sysdate               date ;
    l_redeploy_flag         varchar2(1);
    l_depreciable           varchar2(1);
    l_project_id            number;
    l_task_id               number;

    l_last_project_id         number;
    l_last_task_id            number;

    l_owner_party_id          number;
    l_owner_party_account_id  number;
    l_acct_class_code         varchar2(80);
    l_location_type_code      varchar2(80);
    l_location_id             number;
    l_instance_usage_code     varchar2(80);
    l_operational_status_code varchar2(80);
    l_t_eav_tbl_empty         csi_process_txn_grp.txn_ext_attrib_values_tbl ;--Added for 9262531
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success ;

    savepoint process_transaction;

    cse_util_pkg.set_debug;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'cse',
      p_file_segment2 => to_char(sysdate, 'DDMONYYYY'));

    SELECT sysdate INTO l_sysdate FROM sys.dual;

    debug('Inside API cse_deployment_grp.process_transaction '||to_char(l_sysdate, 'dd-mon-yyyy hh24:mi:ss'));
    debug('  instance_tbl.count     : '||p_instance_tbl.count);
    debug('  dest_loc_tbl.count     : '||p_dest_location_tbl.count);
    debug('  ea_val_tbl.count       : '||p_ext_attrib_values_tbl.count);
    debug('  txn_tbl.count          : '||p_txn_tbl.count);

    IF p_instance_tbl.COUNT > 0 THEN
      FOR si_ind IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
      LOOP

        debug('instance_tbl record # '||si_ind);
        debug('  instance_id            : '||p_instance_tbl(si_ind).instance_id);

        SELECT inventory_item_id,
               last_vld_organization_id,
               serial_number,
               lot_number,
               inventory_revision,
               operational_status_code,
               unit_of_measure,
               pa_project_id,
               pa_project_task_id,
               last_pa_project_id,
               last_pa_task_id,
               owner_party_id,
               owner_party_account_id,
               accounting_class_code,
               location_type_code,
               location_id,
               instance_usage_code,
               operational_status_code
        INTO   l_t_inst_tbl(1).inventory_item_id ,
               l_t_inst_tbl(1).vld_organization_id ,
               l_t_inst_tbl(1).serial_number,
               l_t_inst_tbl(1).lot_number,
               l_t_inst_tbl(1).inventory_revision,
               l_t_inst_tbl(1).operational_status_code,
               l_t_inst_tbl(1).unit_of_measure,
               l_project_id,
               l_task_id,
               l_last_project_id,
               l_last_task_id,
               l_owner_party_id,
               l_owner_party_account_id,
               l_acct_class_code,
               l_location_type_code,
               l_location_id,
               l_instance_usage_code,
               l_operational_status_code
        FROM   csi_item_instances
        WHERE  instance_id = p_instance_tbl(si_ind).instance_id;

        l_t_inst_tbl(1).ib_txn_segment_flag  := 'S';
        l_t_inst_tbl(1).instance_id        := p_instance_tbl(si_ind).instance_id ;
        l_t_inst_tbl(1).active_start_date  := p_instance_tbl(si_ind).active_start_date ;
        l_t_inst_tbl(1).active_end_date    := p_instance_tbl(si_ind).active_end_date ;
        l_t_inst_tbl(1).instance_status_id := p_instance_tbl(si_ind).instance_status_id;
        l_t_inst_tbl(1).quantity           := p_txn_tbl(si_ind).transaction_quantity ;

        IF l_t_inst_tbl(1).serial_number is not null THEN --4616287
          l_t_inst_tbl(1).instance_status_id := p_instance_tbl(si_ind).instance_status_id ;
        END IF;

        debug('  serial_number          : '||l_t_inst_tbl(1).serial_number);
        debug('  lot_number             : '||l_t_inst_tbl(1).lot_number);
        debug('  transaction_quantity   : '||l_t_inst_tbl(1).quantity);


        -- transaction entity
        l_txn_rec.source_group_ref        := p_txn_tbl(si_ind).source_group_ref ;
        l_txn_rec.source_group_ref_id     := p_txn_tbl(si_ind).source_group_ref_id;

        IF l_project_id is not null OR l_last_project_id is not null THEN
          l_txn_rec.source_header_ref_id  := nvl(l_project_id, l_last_project_id);
          l_txn_rec.source_line_ref_id    := nvl(l_task_id,  l_last_task_id);
        ELSE
          l_txn_rec.source_header_ref_id  := p_txn_tbl(si_ind).source_header_ref_id;
          l_txn_rec.source_line_ref_id    := fnd_api.g_miss_num;
        END IF;

        l_txn_rec.source_header_ref       := p_txn_tbl(si_ind).source_header_ref;
        l_txn_rec.source_line_ref         := fnd_api.g_miss_char;
        l_txn_rec.txn_sub_type_id         := p_txn_tbl(si_ind).txn_sub_type_id ;
        l_txn_rec.source_transaction_date := p_txn_tbl(si_ind).source_transaction_date ;
        l_txn_rec.transaction_quantity    := p_txn_tbl(si_ind).transaction_quantity ;


        l_txn_rec.transaction_type_id     := p_txn_tbl(si_ind).transaction_type_id ;
        l_txn_rec.transaction_status_code := 'COMPLETE';

        IF p_txn_tbl(si_ind).transaction_type_id = 106 THEN -- Proj Item Install
          IF l_project_id IS  NULL THEN
            l_txn_rec.transaction_type_id     := 154; -- item install
          END IF;
        ELSIF p_txn_tbl(si_ind).transaction_type_id = 109 THEN -- In Service
          IF l_last_project_id IS NOT NULL THEN
            l_txn_rec.transaction_type_id     := 108; -- project item in service
            l_txn_rec.transaction_status_code := 'PENDING';
          END IF;
          -- Added for bug 8628510 -- For cases where project item is put into service without installing it
          IF l_project_id IS NOT NULL AND l_last_project_id IS  NULL THEN
            l_txn_rec.transaction_type_id     := 108; -- project item in service
            l_txn_rec.transaction_status_code := 'PENDING';
          END IF;
        ELSIF p_txn_tbl(si_ind).transaction_type_id = 107 THEN -- project item uninstall
          IF l_last_project_id IS  NULL THEN
            l_txn_rec.transaction_type_id     := 155; -- item uninstall
          END IF;
        ELSIF l_txn_rec.transaction_type_id = 111 THEN -- item move
          l_txn_rec.transaction_status_code := 'PENDING';
        ELSIF p_txn_tbl(si_ind).transaction_type_id = 107 THEN -- project item uninstall
          IF l_last_project_id IS NULL THEN
            l_txn_rec.transaction_type_id     := 155; -- item uninstall
          END IF;
        END IF;

        debug('  transaction_type_id    : '||l_txn_rec.transaction_type_id);

        -- for customer owned item instances we do not allow updates to FA. these transactions
        -- should not be visible for Asset Tracking programs. so mark the txn status as complete.
        IF l_owner_party_account_id is not null THEN
          l_txn_rec.transaction_status_code := 'COMPLETE';
        END IF;

        IF p_dest_location_tbl.COUNT > 0 THEN

          FOR dl_ind IN p_dest_location_tbl.FIRST .. p_dest_location_tbl.LAST
          LOOP

            IF p_dest_location_tbl(dl_ind).parent_tbl_index = si_ind THEN

              l_dest_location_rec.parent_tbl_index        := p_dest_location_tbl(dl_ind).parent_tbl_index ;

              IF p_dest_location_tbl(dl_ind).location_type_code = 'HR_LOCATIONS' THEN
                l_dest_location_rec.location_type_code    := 'INTERNAL_SITE';
              ELSE
                l_dest_location_rec.location_type_code    := p_dest_location_tbl(dl_ind).location_type_code ;
                -- Added for bug 8628510 -- For cases where project item is put into service without installing it
                IF l_txn_rec.transaction_type_id in (108, 109) AND l_project_id IS NOT NULL AND l_last_project_id IS  NULL THEN
                  l_dest_location_rec.location_type_code    := 'INTERNAL_SITE';
                END IF;
              END IF;
              l_dest_location_rec.location_id             := p_dest_location_tbl(dl_ind).location_id ;
              l_dest_location_rec.last_pa_project_id      := p_dest_location_tbl(dl_ind).last_pa_project_id ;
              l_dest_location_rec.last_pa_project_task_id := p_dest_location_tbl(dl_ind).last_pa_project_task_id ;
              l_dest_location_rec.external_reference      := p_dest_location_tbl(dl_ind).external_reference ;
              l_dest_location_rec.operational_status_code := p_dest_location_tbl(dl_ind).operational_status_code ;
              l_dest_location_rec.instance_usage_code     := p_dest_location_tbl(dl_ind).instance_usage_code;

              IF l_dest_location_rec.location_type_code = 'PROJECT' THEN
                l_dest_location_rec.pa_project_id      := p_dest_location_tbl(dl_ind).pa_project_id;
                l_dest_location_rec.pa_project_task_id := p_dest_location_tbl(dl_ind).pa_project_task_id;
              END IF;

              debug('  location_type_code     : '||l_dest_location_rec.location_type_code);
              debug('  location_id            : '||l_dest_location_rec.location_id);

            END IF ;
          END LOOP ;

        ELSE
          fnd_message.set_name('CSI','CSI_DPL_INVALID_LOCATION');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error ;
        END IF ; --p_dest_location_tbl.COUNT


        -- override destination location attribs based on transaction type
        IF l_txn_rec.transaction_type_id in (154,106) THEN --Item Install
          l_dest_location_rec.operational_status_code := 'INSTALLED' ;
          l_dest_location_rec.instance_usage_code     := 'INSTALLED';
          IF l_txn_rec.transaction_type_id = 106 THEN
            l_dest_location_rec.last_pa_project_id      := l_project_id;
            l_dest_location_rec.last_pa_project_task_id := l_task_id ;
          END IF;

          IF l_project_id is not null THEN
            l_t_inst_tbl(1).last_pa_project_id := l_project_id;
            l_t_inst_tbl(1).last_pa_task_id    := l_task_id;
            l_t_inst_tbl(1).pa_project_id      := null;
            l_t_inst_tbl(1).pa_project_task_id := null;
          END IF;

        ELSIF l_txn_rec.transaction_type_id in (108, 109) THEN -- In Service
          l_dest_location_rec.operational_status_code := 'IN_SERVICE' ;
          l_dest_location_rec.instance_usage_code     := 'IN_SERVICE';
          -- Added for bug 8628510 -- For cases where project item is put into service without installing it
          IF l_project_id IS NOT NULL AND l_last_project_id IS  NULL THEN
            l_dest_location_rec.last_pa_project_id      := l_project_id;
            l_dest_location_rec.last_pa_project_task_id := l_task_id ;
            l_t_inst_tbl(1).last_pa_project_id := l_project_id;
            l_t_inst_tbl(1).last_pa_task_id    := l_task_id;
            l_t_inst_tbl(1).pa_project_id      := null;
            l_t_inst_tbl(1).pa_project_task_id := null;
          END IF;
        ELSIF l_txn_rec.transaction_type_id = 110 THEN -- out of service
          l_dest_location_rec.operational_status_code := 'OUT_OF_SERVICE' ;
          l_dest_location_rec.instance_usage_code     := 'OUT_OF_SERVICE';
        ELSIF l_txn_rec.transaction_type_id = 111 THEN -- item move
          --fix for the bug 4620445
          IF nvl(l_dest_location_rec.location_type_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
             OR
             nvl(l_dest_location_rec.location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
            fnd_message.set_name('CSI','CSI_DPL_INVALID_LOCATION');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;
          l_dest_location_rec.operational_status_code := l_operational_status_code;
          l_dest_location_rec.instance_usage_code     := l_instance_usage_code;
        ELSIF l_txn_rec.transaction_type_id in (107, 155) THEN -- uninstall
          IF l_last_project_id is not null THEN
            l_t_inst_tbl(1).pa_project_id               := l_last_project_id;
            l_t_inst_tbl(1).pa_project_task_id          := l_last_task_id;
            l_t_inst_tbl(1).last_pa_project_id          := NULL;
            l_t_inst_tbl(1).last_pa_task_id             := NULL;
            l_dest_location_rec.location_type_code      := 'PROJECT';
            l_dest_location_rec.pa_project_id           := l_last_project_id; --Addded for bug 8667816
            l_dest_location_rec.pa_project_task_id      := l_last_task_id;    --Addded for bug 8667816
          END IF;
          l_dest_location_rec.operational_status_code := 'NOT_USED';
          l_dest_location_rec.instance_usage_code     := 'IN_PROCESS';
        ELSIF l_txn_rec.transaction_type_id = 152 THEN -- project transfer
          l_t_inst_tbl(1).location_type_code := l_location_type_code;
          l_t_inst_tbl(1).location_id        := l_location_id;
          IF l_project_id is not null THEN
            l_t_inst_tbl(1).pa_project_id      := l_project_id;
            l_t_inst_tbl(1).pa_project_task_id := l_task_id;
          END IF;
          IF l_last_project_id is not null THEN
            l_t_inst_tbl(1).last_pa_project_id := l_last_project_id;
            l_t_inst_tbl(1).last_pa_task_id    := l_last_task_id;
          END IF;
        ELSIF l_txn_rec.transaction_type_id = 104 THEN -- asset retirements
          l_dest_location_rec.operational_status_code := 'OUT_OF_SERVICE';
        ELSE
          fnd_message.set_name('CSI','CSI_INVALID_TXN_TYPE_ID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF; ---Txn Type

        -- Bug 9262531
        ind := 0;
        IF p_ext_attrib_values_tbl.COUNT > 0 THEN
          l_t_eav_tbl := l_t_eav_tbl_empty; --Added for bug 9262531
          FOR av_ind IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
          LOOP
            IF p_ext_attrib_values_tbl(av_ind).parent_tbl_index = si_ind THEN
              ind := ind+1;
              l_t_eav_tbl(ind).attribute_value_id    := p_ext_attrib_values_tbl(av_ind).attribute_value_id ;
              -- Bug 9262531
              -- The parent tbl index will always be 1
              -- as the l_t_inst_tbl is built with index 1
              --l_t_eav_tbl(ind).parent_tbl_index      := p_ext_attrib_values_tbl(av_ind).parent_tbl_index ;
              l_t_eav_tbl(ind).parent_tbl_index      := 1 ;
              l_t_eav_tbl(ind).instance_id           := p_ext_attrib_values_tbl(av_ind).instance_id ;
              l_t_eav_tbl(ind).attribute_id          := p_ext_attrib_values_tbl(av_ind).attribute_id ;
              l_t_eav_tbl(ind).attribute_code        := p_ext_attrib_values_tbl(av_ind).attribute_code ;
              l_t_eav_tbl(ind).attribute_value       := p_ext_attrib_values_tbl(av_ind).attribute_value ;
              l_t_eav_tbl(ind).object_version_number := p_ext_attrib_values_tbl(av_ind).object_version_number;
            END IF ;
          END LOOP ;
        END IF ;--p_ext_attribs_values_tbl.COUNT > 0

        debug('  instance_usage_code    : '||l_dest_location_rec.instance_usage_code);
        debug('  operation_status_code  : '||l_dest_location_rec.operational_status_code);

        -- not taking the retirement transactions thru the process transaction api
        IF l_txn_rec.transaction_type_id = 104 THEN
          process_retirements(
            p_instance_id           => p_instance_tbl(si_ind).instance_id,
            p_asset_id              => p_instance_tbl(si_ind).asset_id,
            p_proceeds_of_sale      => p_txn_tbl(si_ind).proceeds_of_sale,
            p_cost_of_removal       => p_txn_tbl(si_ind).cost_of_removal,
            p_operational_flag      => p_txn_tbl(si_ind).operational_flag, --Bug 8712734
            p_financial_flag        => p_txn_tbl(si_ind).financial_flag,
            px_txn_rec              => l_txn_rec,
            x_return_status         => l_return_status);

          IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE

          IF l_owner_party_account_id is not null AND l_t_inst_tbl(1).serial_number is null THEN

            debug('  owner_account_id     : '||l_owner_party_account_id);
            debug('  acct_class_code      : '||l_acct_class_code);

            -- put logic here to re-build the external party and account
            rebuild_child_entities(
              p_instance_id           => l_t_inst_tbl(1).instance_id,
              x_t_party_tbl           => l_t_party_tbl,
              x_t_pty_acct_tbl        => l_t_pty_acct_tbl,
              x_t_ou_tbl              => l_t_ou_tbl,
              x_t_price_tbl           => l_t_price_tbl,
              x_return_status         => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          csi_process_txn_grp.process_transaction(
            p_api_version             => 1.0,
            p_commit                  => fnd_api.g_false,
            p_init_msg_list           => fnd_api.g_false,
            p_validation_level        => fnd_api.g_valid_level_full,
            p_validate_only_flag      => fnd_api.g_false,
            p_in_out_flag             => 'INT',
            p_dest_location_rec       => l_dest_location_rec ,
            p_txn_rec                 => l_txn_rec  ,
            p_instances_tbl           => l_t_inst_tbl,
            p_i_parties_tbl           => l_t_party_tbl,
            p_ip_accounts_tbl         => l_t_pty_acct_tbl,
            p_org_units_tbl           => l_t_ou_tbl,
            p_ext_attrib_vlaues_tbl   => l_t_eav_tbl,
            p_pricing_attribs_tbl     => l_t_price_tbl,
            p_instance_asset_tbl      => l_t_ia_tbl,
            p_ii_relationships_tbl    => l_t_iir_tbl,
            px_txn_error_rec          => l_txn_error_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF; -- retirement/non retirement transactions

	--Added for Bug 8670632
	IF l_txn_rec.transaction_type_id = 152 THEN -- project transfer

	     debug('INSTANCE_ID is ' || p_instance_tbl(si_ind).INSTANCE_ID);

	     l_trf_pa_attr_rec.instance_id	:=	p_instance_tbl(si_ind).INSTANCE_ID;
	     select INV_MASTER_ORGANIZATION_ID into l_trf_pa_attr_rec.inv_master_org_id
		from csi_item_instances where INSTANCE_ID = l_trf_pa_attr_rec.instance_id;

	     l_trf_pa_attr_rec.serial_number	:=	p_instance_tbl(si_ind).SERIAL_NUMBER;
	     l_trf_pa_attr_rec.item_id		:=	p_instance_tbl(si_ind).INVENTORY_ITEM_ID;
	     l_trf_pa_attr_rec.transaction_id   :=      l_txn_rec.TRANSACTION_ID;
	     l_trf_pa_attr_rec.quantity		:=	p_txn_tbl(si_ind).transaction_quantity;
	     l_trf_pa_attr_rec.project_id	:=	l_dest_location_rec.last_pa_project_id;
	     l_trf_pa_attr_rec.task_id		:=	l_dest_location_rec.last_pa_project_task_id;
	     l_trf_pa_attr_rec.to_project_id	:=	l_dest_location_rec.pa_project_id;
	     l_trf_pa_attr_rec.to_task_id	:=	l_dest_location_rec.pa_project_task_id;

	     debug('Calling interface_nl_to_pa');
	     cse_deployment_grp.interface_nl_to_pa(
		 p_trf_pa_attr_rec    => l_trf_pa_attr_rec,
		 p_conc_request_id    => 111 ,
		 x_return_status      => l_return_status,
		 x_error_message      => l_error_msg );

	END IF;
	--Added for Bug 8670632
      END LOOP ;
    END IF ; --p_instance_tbl.COUNT > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_msg     := nvl(l_error_msg, cse_util_pkg.dump_error_stack);
      debug('Error : '||x_error_msg);
      rollback to process_transaction;
  END process_transaction;

END cse_deployment_grp;

/
