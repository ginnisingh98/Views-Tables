--------------------------------------------------------
--  DDL for Package Body CSI_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INTERFACE_PKG" AS
/* $Header: csipitxb.pls 120.22.12010000.8 2010/02/10 21:40:11 lakmohan ship $ */

  PROCEDURE debug(
    p_message     IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name    IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_interface_pkg',
      p_api_name => p_api_name);
  END api_log;

  PROCEDURE record_time(
    p_label IN varchar2)
  IS
    l_time varchar2(200);
  BEGIN
    l_time := p_label||' Time :'||to_char(sysdate,'HH:MI:SS');
    debug(l_time);
  END record_time;

  PROCEDURE dump_instance_key(
    p_instance_key            IN  csi_utility_grp.config_instance_key)
  IS
    l_rec    csi_utility_grp.config_instance_key;
  BEGIN
    l_rec := p_instance_key;
    debug('configurator instance key  :');
    debug('  inst_hdr_id              :'||l_rec.inst_hdr_id);
    debug('  inst_item_id             :'||l_rec.inst_item_id);
    debug('  inst_rev_num             :'||l_rec.inst_rev_num);
    debug('  inst_baseline_rev_num    :'||l_rec.inst_baseline_rev_num);
  END dump_instance_key;

  PROCEDURE dump_instance_keys(
    p_instance_keys           IN  csi_utility_grp.config_instance_keys)
  IS
  BEGIN
    IF p_instance_keys.COUNT > 0 THEN
      FOR l_ind IN p_instance_keys.FIRST .. p_instance_keys.LAST
      LOOP
        dump_instance_key(p_instance_keys(l_ind));
      END LOOP;
    END IF;
  END dump_instance_keys;

  PROCEDURE get_default_sub_type_id(
    p_transaction_type_id  IN  number,
    x_sub_type_id          OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_default_sub_type_id');

    BEGIN
      SELECT sub_type_id
      INTO   x_sub_type_id
      FROM   csi_txn_sub_types
      WHERE  transaction_type_id = p_transaction_type_id
      AND    default_flag        = 'Y';
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI', 'CSI_DFLT_SUB_TYPE_MISSING');
        fnd_message.set_token('TXN_TYPE_ID',p_transaction_type_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      WHEN too_many_rows THEN
        fnd_message.set_name('CSI', 'CSI_MANY_DFLT_SUB_TYPES');
        fnd_message.set_token('TXN_TYPE_ID',p_transaction_type_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_default_sub_type_id;

  /* this routine gets the first trackable parent (order line record) from the
     sales order tree for the current processing order line */

  PROCEDURE get_ib_trackable_parent(
    p_source_line_rec    IN  source_line_rec,
    x_parent_found       OUT NOCOPY boolean,
    x_parent_line_rec    OUT NOCOPY source_line_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_org_id              number;
    l_organization_id     number;
    l_parent_line_id      number;
    l_parent_hdr_rec      source_header_rec;
    l_next_parent_line_id number;
    l_inventory_item_id   number;
    l_ib_trackable_flag   varchar2(1) := 'N';

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_ib_trackable_parent');

    x_parent_found := FALSE;

    l_parent_line_id := p_source_line_rec.link_to_line_id;

    LOOP

      SELECT inventory_item_id ,
             link_to_line_id ,
             org_id
      INTO   l_inventory_item_id ,
             l_next_parent_line_id,
             l_org_id
      FROM   oe_order_lines_all
      WHERE  line_id = l_parent_line_id;

      l_organization_id := oe_sys_parameters.value(
                             param_name => 'MASTER_ORGANIZATION_ID',
                             p_org_id   => l_org_id);

      SELECT nvl(msi.comms_nl_trackable_flag, 'N')
      INTO   l_ib_trackable_flag
      FROM   mtl_system_items msi
      WHERE  msi.inventory_item_id = l_inventory_item_id
      AND    msi.organization_id   = l_organization_id;

      IF l_ib_trackable_flag = 'Y' THEN

        get_order_line_source_info(
          p_order_line_id      => l_parent_line_id,
          x_source_header_rec  => l_parent_hdr_rec,
          x_source_line_rec    => x_parent_line_rec,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_parent_found := TRUE;
        exit;

      ELSE
        l_parent_line_id := l_next_parent_line_id;

        IF l_parent_line_id IS NULL THEN
          x_parent_found := FALSE;
          exit;
        END IF;

      END IF;
    END LOOP;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_ib_trackable_parent;


  /* this routine gets the first trackable parent (order line record) that has the
     installation details from the sales order tree for the current processing
     order line */

  PROCEDURE get_parent_with_txn_detail(
    p_source_line_rec    IN  source_line_rec,
    x_parent_found       OUT NOCOPY boolean,
    x_parent_line_rec    OUT NOCOPY source_line_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_trackable_parent_found       boolean := FALSE;
    l_parent_line_rec              source_line_rec;
    l_current_line_rec             source_line_rec;
    l_txn_line_rec                 csi_t_datastructures_grp.txn_line_rec;
    l_td_found                     boolean := FALSE;
    l_return_status                varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_parent_with_txn_detail');

    l_current_line_rec := p_source_line_rec;

    LOOP

      get_ib_trackable_parent(
        p_source_line_rec    => l_current_line_rec,
        x_parent_found       => l_trackable_parent_found,
        x_parent_line_rec    => l_parent_line_rec,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF NOT(l_trackable_parent_found) THEN
        x_parent_found := FALSE;
        exit;
      END IF;

      debug('  Parent Line ID :'||l_parent_line_rec.source_line_id);

      -- check for txn details
      l_txn_line_rec.source_transaction_table := g_om_source_table;
      l_txn_line_rec.source_transaction_id    := l_parent_line_rec.source_line_id;

      l_td_found := csi_t_txn_details_pvt.check_txn_details_exist(
                   p_txn_line_rec => l_txn_line_rec);

      IF l_td_found THEN
        x_parent_found := TRUE;
        exit;
      ELSE

        l_current_line_rec := l_parent_line_rec;

        IF l_current_line_rec.link_to_line_id is null THEN
          x_parent_found := FALSE;
          exit;
        END IF;
      END IF;

    END LOOP;

    x_parent_line_rec := l_parent_line_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_parent_with_txn_detail;

  PROCEDURE query_immediate_children (
    p_parent_line_id     IN  number,
    x_line_tbl           OUT NOCOPY source_line_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_hdr_rec     source_header_rec;
    l_line_rec    source_line_rec;

    l_return_status varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR op_cur is
      SELECT line_id
      FROM   oe_order_lines_all
      WHERE  link_to_line_id   = p_parent_line_id
      ORDER BY line_number, shipment_number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('query_immediate_children');

    debug('  Getting children for Line ID :'||p_parent_line_id);

    FOR op_rec IN op_cur
    LOOP

      IF op_rec.line_id <> p_parent_line_id THEN

        get_order_line_source_info(
          p_order_line_id      => op_rec.line_id,
          x_source_header_rec  => l_hdr_rec,
          x_source_line_rec    => l_line_rec,
          x_return_status      => l_return_status);

        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;

      END IF;

    END LOOP;

    debug('  Children count :'||x_line_tbl.COUNT);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END query_immediate_children;

  PROCEDURE get_ib_trackable_children(
    p_current_line_id    IN  number,
    x_trackable_line_tbl OUT NOCOPY source_line_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_organization_id    number;
    l_line_tbl           source_line_tbl;
    l_line_tbl_nxt_lvl   source_line_tbl;
    l_line_tbl_temp      source_line_tbl;
    l_line_tbl_final     source_line_tbl;

    l_config_line_rec    source_line_rec;

    l_nxt_ind            binary_integer;
    l_final_ind          binary_integer;

    l_ib_trackable_flag  varchar2(1);
    l_config_found       boolean := FALSE;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    api_log('get_ib_trackable_children');

    x_return_status := fnd_api.g_ret_sts_success;

    l_final_ind := 0;

    query_immediate_children (
      p_parent_line_id  => p_current_line_id,
      x_line_tbl        => l_line_tbl,
      x_return_status   => l_return_status);

    LOOP

      l_line_tbl_nxt_lvl.delete;
      l_nxt_ind := 0;

      EXIT when l_line_tbl.count = 0;

      FOR l_ind IN l_line_tbl.FIRST .. l_line_tbl.LAST
      LOOP

        l_organization_id := oe_sys_parameters.value(
                               param_name => 'MASTER_ORGANIZATION_ID',
                               p_org_id   => l_line_tbl(l_ind).org_id);

        SELECT nvl(msi.comms_nl_trackable_flag,'N')
        INTO   l_ib_trackable_flag
        FROM   mtl_system_items msi
        WHERE  msi.inventory_item_id = l_line_tbl(l_ind).inventory_item_id
        AND    msi.organization_id   = l_organization_id;

        /* if trackable populate it for the final out table */
        IF l_ib_trackable_flag = 'Y' THEN

          l_final_ind := l_final_ind + 1;
          l_line_tbl_final(l_final_ind) := l_line_tbl(l_ind);

        ELSE --[NOT Trackable]

          /* get the next level using this line ID as the parent */

          query_immediate_children (
            p_parent_line_id  => l_line_tbl(l_ind).source_line_id,
            x_line_tbl        => l_line_tbl_temp,
            x_return_status   => l_return_status);

          IF l_line_tbl_temp.count > 0 THEN
            FOR l_temp_ind IN l_line_tbl_temp.FIRST .. l_line_tbl_temp.LAST
            LOOP

              l_nxt_ind := l_nxt_ind + 1;
              l_line_tbl_nxt_lvl (l_nxt_ind) := l_line_tbl_temp(l_temp_ind);

            END LOOP;
          END IF;

        END IF;

      END LOOP;

      EXIT WHEN l_line_tbl_nxt_lvl.COUNT = 0;

      l_line_tbl.DELETE;
      l_line_tbl := l_line_tbl_nxt_lvl;

    END LOOP;

    l_config_found := FALSE;

    IF l_line_tbl_final.count > 0 THEN
      FOR l_ind IN l_line_tbl_final.FIRST .. l_line_tbl_final.LAST
      LOOP
        IF l_line_tbl_final(l_ind).item_type_code = 'CONFIG' THEN
          l_config_found := TRUE;
          l_config_line_rec := l_line_tbl_final(l_ind);
          exit;
        END IF;
      END LOOP;
    END IF;

    IF l_config_found THEN
      x_trackable_line_tbl(1) := l_config_line_rec;
    ELSE
      x_trackable_line_tbl := l_line_tbl_final;
    END IF;
    debug('  Trackable children count :'||x_trackable_line_tbl.count);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END  get_ib_trackable_children;

  --
  --
  --
  PROCEDURE cascade_txn_detail(
    p_parent_line_rec     IN  source_line_rec,
    p_child_line_rec      IN  source_line_rec,
    x_txn_line_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_party_acct_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_txn_line_query_rec         csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_g_line_dtl_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_g_pty_dtl_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_g_pty_acct_tbl       csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_g_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_g_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_g_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_g_csi_ea_tbl         csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_g_csi_eav_tbl        csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_g_txn_systems_tbl    csi_t_datastructures_grp.txn_systems_tbl;

    l_c_td_ind             binary_integer;
    l_c_pt_ind             binary_integer;
    l_c_pa_ind             binary_integer;
    l_c_oa_ind             binary_integer;
    l_c_ea_ind             binary_integer;

    l_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(512);
    l_msg_count            number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('cascade_txn_detail');

    l_txn_line_query_rec.source_transaction_table := g_om_source_table;
    l_txn_line_query_rec.source_transaction_id    := p_parent_line_rec.source_line_id;

    l_txn_line_detail_query_rec.source_transaction_flag := 'Y';

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version               => 1.0,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_txn_line_query_rec        => l_txn_line_query_rec,
      p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl       => l_g_line_dtl_tbl,
      p_get_parties_flag          => fnd_api.g_true,
      x_txn_party_detail_tbl      => l_g_pty_dtl_tbl,
      p_get_pty_accts_flag        => fnd_api.g_true,
      x_txn_pty_acct_detail_tbl   => l_g_pty_acct_tbl,
      p_get_ii_rltns_flag         => fnd_api.g_false,
      x_txn_ii_rltns_tbl          => l_g_ii_rltns_tbl,
      p_get_org_assgns_flag       => fnd_api.g_true,
      x_txn_org_assgn_tbl         => l_g_org_assgn_tbl,
      p_get_ext_attrib_vals_flag  => fnd_api.g_false,
      x_txn_ext_attrib_vals_tbl   => l_g_ext_attrib_tbl,
      p_get_csi_attribs_flag      => fnd_api.g_false,
      x_csi_ext_attribs_tbl       => l_g_csi_ea_tbl,
      p_get_csi_iea_values_flag   => fnd_api.g_false,
      x_csi_iea_values_tbl        => l_g_csi_eav_tbl,
      p_get_txn_systems_flag      => fnd_api.g_false,
      x_txn_systems_tbl           => l_g_txn_systems_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_c_td_ind := 0;
    l_c_pt_ind := 0;
    l_c_pa_ind := 0;
    l_c_oa_ind := 0;
    l_c_ea_ind := 0;

    IF l_g_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN l_g_line_dtl_tbl.FIRST .. l_g_line_dtl_tbl.LAST
      LOOP

        FOR i in 1..l_g_line_dtl_tbl(l_td_ind).quantity
        LOOP

          l_c_td_ind := l_c_td_ind + 1;

          l_line_dtl_tbl(l_c_td_ind)          := l_g_line_dtl_tbl(l_td_ind);
          l_line_dtl_tbl(l_c_td_ind).quantity := p_child_line_rec.source_quantity/
                                                 p_parent_line_rec.source_quantity;

          l_line_dtl_tbl(l_c_td_ind).transaction_line_id := fnd_api.g_miss_num;
          l_line_dtl_tbl(l_c_td_ind).txn_line_detail_id  := fnd_api.g_miss_num;
          l_line_dtl_tbl(l_c_td_ind).inventory_item_id   := p_child_line_rec.inventory_item_id;
          l_line_dtl_tbl(l_c_td_ind).unit_of_measure     := p_child_line_rec.uom_code;
          l_line_dtl_tbl(l_c_td_ind).inventory_revision  := p_child_line_rec.item_revision;
          l_line_dtl_tbl(l_c_td_ind).csi_transaction_id  := fnd_api.g_miss_num;
          l_line_dtl_tbl(l_c_td_ind).processing_status   := 'SUBMIT';
          l_line_dtl_tbl(l_c_td_ind).instance_exists_flag := 'N';
          l_line_dtl_tbl(l_c_td_ind).instance_id          := fnd_api.g_miss_num;
          l_line_dtl_tbl(l_c_td_ind).source_txn_line_detail_id  :=
                l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          -- derive the item related attributes here

          IF l_g_pty_dtl_tbl.COUNT > 0 THEN
            FOR l_pt_ind IN l_g_pty_dtl_tbl.FIRST .. l_g_pty_dtl_tbl.LAST
            LOOP

              IF l_g_pty_dtl_tbl(l_pt_ind).txn_line_detail_id =
                 l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id THEN

                l_c_pt_ind := l_c_pt_ind + 1;

                l_pty_dtl_tbl(l_c_pt_ind) := l_g_pty_dtl_tbl(l_pt_ind);
                l_pty_dtl_tbl(l_c_pt_ind).txn_line_detail_id     := fnd_api.g_miss_num;
                l_pty_dtl_tbl(l_c_pt_ind).txn_party_detail_id    := fnd_api.g_miss_num;
                l_pty_dtl_tbl(l_c_pt_ind).txn_line_details_index := l_c_td_ind;
                l_pty_dtl_tbl(l_c_pt_ind).instance_party_id      := fnd_api.g_miss_num;

                IF l_g_pty_acct_tbl.COUNT > 0 THEN

                  FOR l_pa_ind IN l_g_pty_acct_tbl.FIRST .. l_g_pty_acct_tbl.LAST
                  LOOP
                    IF l_g_pty_acct_tbl(l_pa_ind).txn_party_detail_id =
                      l_g_pty_dtl_tbl(l_pt_ind).txn_party_detail_id THEN

                      l_c_pa_ind := l_c_pa_ind + 1;

                      l_pty_acct_tbl(l_c_pa_ind) := l_g_pty_acct_tbl(l_pa_ind);
                      l_pty_acct_tbl(l_c_pa_ind).txn_party_detail_id     := fnd_api.g_miss_num;
                      l_pty_acct_tbl(l_c_pa_ind).txn_account_detail_id   := fnd_api.g_miss_num;
                      l_pty_acct_tbl(l_c_pa_ind).txn_party_details_index := l_c_pt_ind;
                      l_pty_acct_tbl(l_c_pa_ind).ip_account_id           := fnd_api.g_miss_num;

                    END IF; -- pty acct detail id chk

                  END LOOP; -- party acct table loop

                END IF; -- party acct count chk

              END IF; -- txn_line_detail_id check

            END LOOP; -- party table loop

          END IF; -- party count check

          IF l_g_org_assgn_tbl.COUNT > 0 THEN
            FOR l_oa_ind IN l_g_org_assgn_tbl.FIRST .. l_g_org_assgn_tbl.LAST
            LOOP
              IF l_g_org_assgn_tbl(l_oa_ind).txn_line_detail_id =
                l_g_line_dtl_tbl(l_td_ind).txn_line_detail_id THEN

                l_c_oa_ind := l_c_oa_ind + 1;
                l_org_assgn_tbl(l_c_oa_ind) := l_g_org_assgn_tbl(l_oa_ind);
                l_org_assgn_tbl(l_c_oa_ind).txn_line_detail_id     := fnd_api.g_miss_num;
                l_org_assgn_tbl(l_c_oa_ind).txn_operating_unit_id  := fnd_api.g_miss_num;
                l_org_assgn_tbl(l_c_oa_ind).txn_line_details_index := l_c_td_ind;
                l_org_assgn_tbl(l_c_oa_ind).instance_ou_id         := fnd_api.g_miss_num;

              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END LOOP; -- txn line details loop
    END IF;

    x_txn_line_detail_tbl := l_line_dtl_tbl;
    x_txn_party_tbl       := l_pty_dtl_tbl;
    x_txn_party_acct_tbl  := l_pty_acct_tbl;
    x_txn_org_assgn_tbl   := l_org_assgn_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
  END cascade_txn_detail;

  PROCEDURE get_item_attributes(
    p_inventory_item_id    IN  number,
    p_organization_id      IN  number,
    x_item_attrib_rec      OUT NOCOPY item_attributes_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS
  l_sql_stmt              VARCHAR2(2000);
  l_exists                VARCHAR2(1) := 'N';
  l_return                BOOLEAN;
  l_status                VARCHAR2(1);
  l_industry              VARCHAR2(1);
  l_oracle_schema         VARCHAR2(30);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_item_attributes');

    -- get item based attributes
    SELECT serial_number_control_code,
           lot_control_code,
           location_control_code,
           revision_qty_control_code,
           comms_nl_trackable_flag,
           shippable_item_flag,
           inventory_item_flag,
           stock_enabled_flag,
           bom_item_type,
           pick_components_flag,
           base_item_id,
           primary_uom_code
    INTO   x_item_attrib_rec.serial_control_code,
           x_item_attrib_rec.lot_control_code,
           x_item_attrib_rec.locator_control_code,
           x_item_attrib_rec.revision_control_code,
           x_item_attrib_rec.ib_trackable_flag,
           x_item_attrib_rec.shippable_flag,
           x_item_attrib_rec.inv_item_flag,
           x_item_attrib_rec.stockable_flag,
           x_item_attrib_rec.bom_item_type,
           x_item_attrib_rec.pick_components_flag,
           x_item_attrib_rec.model_item_id,
           x_item_attrib_rec.primary_uom_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_inventory_item_id
    AND    organization_id   = p_organization_id;

    -- get org attributes aswell
    -- Ib_item_instance_class column may or may not exists in mtl_system_items_b.
    -- Hence used a Dynamic sal based on the existance of this column in ALL_TAB_COLUMNS.

    -- For Bug 3431768
    l_return := FND_INSTALLATION.get_app_info('INV',l_status,l_industry,l_oracle_schema);

    IF NOT l_return THEN
      fnd_message.set_name('CSI','CSI_FND_INVALID_SCHEMA_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- End fix for Bug 3431768

    Begin
      select 'X'
      into l_exists
      from all_tab_columns
      where table_name = 'MTL_SYSTEM_ITEMS_B'
      and   column_name = 'IB_ITEM_INSTANCE_CLASS'
      and   OWNER       = l_oracle_schema
      and   rownum < 2;
    Exception
      when no_data_found then
        l_exists := 'N';
    End;
    l_sql_stmt := 'select ib_item_instance_class from MTL_SYSTEM_ITEMS_B '||
                  'where inventory_item_id = :item_id '||
                  'and   organization_id = :vld_org_id';
    --
    IF l_exists = 'X' THEN
      BEGIN
        EXECUTE IMMEDIATE l_sql_stmt INTO x_item_attrib_rec.ib_item_instance_class USING p_inventory_item_id,p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_item_attrib_rec.ib_item_instance_class := null;
      END;
    ELSE
      x_item_attrib_rec.ib_item_instance_class := null;
    END If;

    l_exists := 'N';

    -- for config_model_type
    Begin
      select 'X'
      into l_exists
      from all_tab_columns
      where table_name = 'MTL_SYSTEM_ITEMS_B'
      and   column_name = 'CONFIG_MODEL_TYPE'
      and   OWNER       = l_oracle_schema
      and   rownum < 2;
    Exception
      when no_data_found then
        l_exists := 'N';
    End;
    l_sql_stmt := 'select config_model_type from MTL_SYSTEM_ITEMS_B '||
                  'where inventory_item_id = :item_id '||
                  'and   organization_id = :vld_org_id';
    --
    IF l_exists = 'X' THEN
      BEGIN
        EXECUTE IMMEDIATE l_sql_stmt INTO x_item_attrib_rec.config_model_type USING p_inventory_item_id,p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_item_attrib_rec.config_model_type := null;
      END;
    ELSE
      x_item_attrib_rec.config_model_type := null;
    END If;


    SELECT nvl(negative_inv_receipt_code,2)
    INTO   x_item_attrib_rec.negative_balances_code
    FROM   mtl_parameters
    WHERE  organization_id = p_organization_id;

    debug('  serial_control_code   : '||x_item_attrib_rec.serial_control_code);
    debug('  lot_control_code      : '||x_item_attrib_rec.lot_control_code);
    debug('  locator_control_code  : '||x_item_attrib_rec.locator_control_code);
    debug('  revision_control_code : '||x_item_attrib_rec.revision_control_code);
    debug('  shippable_flag        : '||x_item_attrib_rec.shippable_flag);
    debug('  primary_uom_code      : '||x_item_attrib_rec.primary_uom_code);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_item_attributes;


  --
  --
  --
  PROCEDURE get_pricing_attributes(
    p_line_id               IN  number,
    x_pricing_attribs_tbl   OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_pa_tbl      csi_datastructures_pub.pricing_attribs_tbl;
    l_ind         binary_integer := 0;

    CURSOR price_cur IS
      SELECT pricing_context,
             pricing_attribute1,
             pricing_attribute2,
             pricing_attribute3,
             pricing_attribute4,
             pricing_attribute5,
             pricing_attribute6,
             pricing_attribute7,
             pricing_attribute8,
             pricing_attribute9,
             pricing_attribute10,
             pricing_attribute11,
             pricing_attribute12,
             pricing_attribute13,
             pricing_attribute14,
             pricing_attribute15,
             pricing_attribute16,
             pricing_attribute17,
             pricing_attribute18,
             pricing_attribute19,
             pricing_attribute20,
             pricing_attribute21,
             pricing_attribute22,
             pricing_attribute23,
             pricing_attribute24,
             pricing_attribute25,
             pricing_attribute26,
             pricing_attribute27,
             pricing_attribute28,
             pricing_attribute29,
             pricing_attribute30,
             pricing_attribute31,
             pricing_attribute32,
             pricing_attribute33,
             pricing_attribute34,
             pricing_attribute35,
             pricing_attribute36,
             pricing_attribute37,
             pricing_attribute38,
             pricing_attribute39,
             pricing_attribute40,
             pricing_attribute41,
             pricing_attribute42,
             pricing_attribute43,
             pricing_attribute44,
             pricing_attribute45,
             pricing_attribute46,
             pricing_attribute47,
             pricing_attribute48,
             pricing_attribute49,
             pricing_attribute50,
             pricing_attribute51,
             pricing_attribute52,
             pricing_attribute53,
             pricing_attribute54,
             pricing_attribute55,
             pricing_attribute56,
             pricing_attribute57,
             pricing_attribute58,
             pricing_attribute59,
             pricing_attribute60,
             pricing_attribute61,
             pricing_attribute62,
             pricing_attribute63,
             pricing_attribute64,
             pricing_attribute65,
             pricing_attribute66,
             pricing_attribute67,
             pricing_attribute68,
             pricing_attribute69,
             pricing_attribute70,
             pricing_attribute71,
             pricing_attribute72,
             pricing_attribute73,
             pricing_attribute74,
             pricing_attribute75,
             pricing_attribute76,
             pricing_attribute77,
             pricing_attribute78,
             pricing_attribute79,
             pricing_attribute80,
             pricing_attribute81,
             pricing_attribute82,
             pricing_attribute83,
             pricing_attribute84,
             pricing_attribute85,
             pricing_attribute86,
             pricing_attribute87,
             pricing_attribute88,
             pricing_attribute89,
             pricing_attribute90,
             pricing_attribute91,
             pricing_attribute92,
             pricing_attribute93,
             pricing_attribute94,
             pricing_attribute95,
             pricing_attribute96,
             pricing_attribute97,
             pricing_attribute98,
             pricing_attribute99,
             pricing_attribute100
      FROM   oe_order_price_attribs
      WHERE  line_id = p_line_id ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_pricing_attributes');

    -- Build the  pricing attribute table
    FOR price_rec IN price_cur
    LOOP

      l_ind := price_cur%rowcount;

      l_pa_tbl(l_ind).pricing_context      := price_rec.pricing_context ;
      l_pa_tbl(l_ind).pricing_attribute1   := price_rec.pricing_attribute1;
      l_pa_tbl(l_ind).pricing_attribute2   := price_rec.pricing_attribute2;
      l_pa_tbl(l_ind).pricing_attribute3   := price_rec.pricing_attribute3;
      l_pa_tbl(l_ind).pricing_attribute4   := price_rec.pricing_attribute4;
      l_pa_tbl(l_ind).pricing_attribute5   := price_rec.pricing_attribute5;
      l_pa_tbl(l_ind).pricing_attribute6   := price_rec.pricing_attribute6;
      l_pa_tbl(l_ind).pricing_attribute7   := price_rec.pricing_attribute7;
      l_pa_tbl(l_ind).pricing_attribute8   := price_rec.pricing_attribute8;
      l_pa_tbl(l_ind).pricing_attribute9   := price_rec.pricing_attribute9;
      l_pa_tbl(l_ind).pricing_attribute10  := price_rec.pricing_attribute10;
      l_pa_tbl(l_ind).pricing_attribute11  := price_rec.pricing_attribute11;
      l_pa_tbl(l_ind).pricing_attribute12  := price_rec.pricing_attribute12;
      l_pa_tbl(l_ind).pricing_attribute13  := price_rec.pricing_attribute13;
      l_pa_tbl(l_ind).pricing_attribute14  := price_rec.pricing_attribute14;
      l_pa_tbl(l_ind).pricing_attribute15  := price_rec.pricing_attribute15;
      l_pa_tbl(l_ind).pricing_attribute16  := price_rec.pricing_attribute16;
      l_pa_tbl(l_ind).pricing_attribute17  := price_rec.pricing_attribute17;
      l_pa_tbl(l_ind).pricing_attribute18  := price_rec.pricing_attribute18;
      l_pa_tbl(l_ind).pricing_attribute19  := price_rec.pricing_attribute19;
      l_pa_tbl(l_ind).pricing_attribute20  := price_rec.pricing_attribute20;
      l_pa_tbl(l_ind).pricing_attribute21  := price_rec.pricing_attribute21;
      l_pa_tbl(l_ind).pricing_attribute22  := price_rec.pricing_attribute22;
      l_pa_tbl(l_ind).pricing_attribute23  := price_rec.pricing_attribute23;
      l_pa_tbl(l_ind).pricing_attribute24  := price_rec.pricing_attribute24;
      l_pa_tbl(l_ind).pricing_attribute25  := price_rec.pricing_attribute25;
      l_pa_tbl(l_ind).pricing_attribute26  := price_rec.pricing_attribute26;
      l_pa_tbl(l_ind).pricing_attribute27  := price_rec.pricing_attribute27;
      l_pa_tbl(l_ind).pricing_attribute28  := price_rec.pricing_attribute28;
      l_pa_tbl(l_ind).pricing_attribute29  := price_rec.pricing_attribute29;
      l_pa_tbl(l_ind).pricing_attribute30  := price_rec.pricing_attribute30;
      l_pa_tbl(l_ind).pricing_attribute31  := price_rec.pricing_attribute31;
      l_pa_tbl(l_ind).pricing_attribute32  := price_rec.pricing_attribute32;
      l_pa_tbl(l_ind).pricing_attribute33  := price_rec.pricing_attribute33;
      l_pa_tbl(l_ind).pricing_attribute34  := price_rec.pricing_attribute34;
      l_pa_tbl(l_ind).pricing_attribute35  := price_rec.pricing_attribute35;
      l_pa_tbl(l_ind).pricing_attribute36  := price_rec.pricing_attribute36;
      l_pa_tbl(l_ind).pricing_attribute37  := price_rec.pricing_attribute37;
      l_pa_tbl(l_ind).pricing_attribute38  := price_rec.pricing_attribute38;
      l_pa_tbl(l_ind).pricing_attribute39  := price_rec.pricing_attribute39;
      l_pa_tbl(l_ind).pricing_attribute40  := price_rec.pricing_attribute40;
      l_pa_tbl(l_ind).pricing_attribute41  := price_rec.pricing_attribute41;
      l_pa_tbl(l_ind).pricing_attribute42  := price_rec.pricing_attribute42;
      l_pa_tbl(l_ind).pricing_attribute43  := price_rec.pricing_attribute43;
      l_pa_tbl(l_ind).pricing_attribute44  := price_rec.pricing_attribute44;
      l_pa_tbl(l_ind).pricing_attribute45  := price_rec.pricing_attribute45;
      l_pa_tbl(l_ind).pricing_attribute46  := price_rec.pricing_attribute46;
      l_pa_tbl(l_ind).pricing_attribute47  := price_rec.pricing_attribute47;
      l_pa_tbl(l_ind).pricing_attribute48  := price_rec.pricing_attribute48;
      l_pa_tbl(l_ind).pricing_attribute49  := price_rec.pricing_attribute49;
      l_pa_tbl(l_ind).pricing_attribute50  := price_rec.pricing_attribute50;
      l_pa_tbl(l_ind).pricing_attribute51  := price_rec.pricing_attribute51;
      l_pa_tbl(l_ind).pricing_attribute52  := price_rec.pricing_attribute52;
      l_pa_tbl(l_ind).pricing_attribute53  := price_rec.pricing_attribute53;
      l_pa_tbl(l_ind).pricing_attribute54  := price_rec.pricing_attribute54;
      l_pa_tbl(l_ind).pricing_attribute55  := price_rec.pricing_attribute55;
      l_pa_tbl(l_ind).pricing_attribute56  := price_rec.pricing_attribute56;
      l_pa_tbl(l_ind).pricing_attribute57  := price_rec.pricing_attribute57;
      l_pa_tbl(l_ind).pricing_attribute58  := price_rec.pricing_attribute58;
      l_pa_tbl(l_ind).pricing_attribute59  := price_rec.pricing_attribute59;
      l_pa_tbl(l_ind).pricing_attribute60  := price_rec.pricing_attribute60;
      l_pa_tbl(l_ind).pricing_attribute61  := price_rec.pricing_attribute61;
      l_pa_tbl(l_ind).pricing_attribute62  := price_rec.pricing_attribute62;
      l_pa_tbl(l_ind).pricing_attribute63  := price_rec.pricing_attribute63;
      l_pa_tbl(l_ind).pricing_attribute64  := price_rec.pricing_attribute64;
      l_pa_tbl(l_ind).pricing_attribute65  := price_rec.pricing_attribute65;
      l_pa_tbl(l_ind).pricing_attribute66  := price_rec.pricing_attribute66;
      l_pa_tbl(l_ind).pricing_attribute67  := price_rec.pricing_attribute67;
      l_pa_tbl(l_ind).pricing_attribute68  := price_rec.pricing_attribute68;
      l_pa_tbl(l_ind).pricing_attribute69  := price_rec.pricing_attribute69;
      l_pa_tbl(l_ind).pricing_attribute70  := price_rec.pricing_attribute70;
      l_pa_tbl(l_ind).pricing_attribute71  := price_rec.pricing_attribute71;
      l_pa_tbl(l_ind).pricing_attribute72  := price_rec.pricing_attribute72;
      l_pa_tbl(l_ind).pricing_attribute73  := price_rec.pricing_attribute73;
      l_pa_tbl(l_ind).pricing_attribute74  := price_rec.pricing_attribute74;
      l_pa_tbl(l_ind).pricing_attribute75  := price_rec.pricing_attribute75;
      l_pa_tbl(l_ind).pricing_attribute76  := price_rec.pricing_attribute76;
      l_pa_tbl(l_ind).pricing_attribute77  := price_rec.pricing_attribute77;
      l_pa_tbl(l_ind).pricing_attribute78  := price_rec.pricing_attribute78;
      l_pa_tbl(l_ind).pricing_attribute79  := price_rec.pricing_attribute79;
      l_pa_tbl(l_ind).pricing_attribute80  := price_rec.pricing_attribute80;
      l_pa_tbl(l_ind).pricing_attribute81  := price_rec.pricing_attribute81;
      l_pa_tbl(l_ind).pricing_attribute82  := price_rec.pricing_attribute82;
      l_pa_tbl(l_ind).pricing_attribute83  := price_rec.pricing_attribute83;
      l_pa_tbl(l_ind).pricing_attribute84  := price_rec.pricing_attribute84;
      l_pa_tbl(l_ind).pricing_attribute85  := price_rec.pricing_attribute85;
      l_pa_tbl(l_ind).pricing_attribute86  := price_rec.pricing_attribute86;
      l_pa_tbl(l_ind).pricing_attribute87  := price_rec.pricing_attribute87;
      l_pa_tbl(l_ind).pricing_attribute88  := price_rec.pricing_attribute88;
      l_pa_tbl(l_ind).pricing_attribute89  := price_rec.pricing_attribute89;
      l_pa_tbl(l_ind).pricing_attribute90  := price_rec.pricing_attribute90;
      l_pa_tbl(l_ind).pricing_attribute91  := price_rec.pricing_attribute91;
      l_pa_tbl(l_ind).pricing_attribute92  := price_rec.pricing_attribute92;
      l_pa_tbl(l_ind).pricing_attribute93  := price_rec.pricing_attribute93;
      l_pa_tbl(l_ind).pricing_attribute94  := price_rec.pricing_attribute94;
      l_pa_tbl(l_ind).pricing_attribute95  := price_rec.pricing_attribute95;
      l_pa_tbl(l_ind).pricing_attribute96  := price_rec.pricing_attribute96;
      l_pa_tbl(l_ind).pricing_attribute97  := price_rec.pricing_attribute97;
      l_pa_tbl(l_ind).pricing_attribute98  := price_rec.pricing_attribute98;
      l_pa_tbl(l_ind).pricing_attribute99  := price_rec.pricing_attribute99;
      l_pa_tbl(l_ind).pricing_attribute100 := price_rec.pricing_attribute100;

    END LOOP;

    x_pricing_attribs_tbl := l_pa_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_pricing_attributes;


  PROCEDURE build_td_from_source(
    p_split_flag            IN  varchar2,
    p_split_quantity        IN  number,
    p_split_loop            IN  number,
    p_transaction_type_id   IN  number,
    p_source_header_rec     IN  source_header_rec,
    p_source_line_rec       IN  source_line_rec,
    p_csi_txn_rec           IN  csi_datastructures_pub.transaction_rec,
    x_txn_line_rec          OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_line_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_party_acct_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_pricing_attribs_tbl   OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_default_sub_type_id   number;
    l_split_flag            varchar2(1) := fnd_api.g_false;
    l_split_quantity        number;
    l_split_loop            number;

    l_td_ind                binary_integer := 0;
    l_pt_ind                binary_integer := 0;
    l_pa_ind                binary_integer := 0;
    l_oa_ind                binary_integer := 0;
    l_ea_ind                binary_integer := 0;
    l_owner_pt_ind          binary_integer := 0;

    -- for partner ordering Bug 3443175
    l_partner_rec             oe_install_base_util.partner_order_rec;

    l_item_attributes_rec   item_attributes_rec;
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_td_from_source');

    -- get the default sub_type_id
    get_default_sub_type_id(
      p_transaction_type_id  => p_transaction_type_id,
      x_sub_type_id          => l_default_sub_type_id,
      x_return_status        => l_return_status);

    x_txn_line_rec.source_transaction_type_id := p_transaction_type_id;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- for partner ordering MRK
    -- Included the If condition for Bug 3893279, Don't call this for project Contracts
    IF p_transaction_type_id <> 326
    THEN
      OE_INSTALL_BASE_UTIL.get_partner_ord_rec(p_order_line_id      => p_source_line_rec.source_LINE_ID,
                                               x_partner_order_rec  => l_partner_rec);
    END IF;


    l_split_flag := p_split_flag;

    IF l_split_flag = fnd_api.g_false THEN

      get_item_attributes(
        p_inventory_item_id    => p_source_line_rec.inventory_item_id,
        p_organization_id      => p_source_line_rec.organization_id,
        x_item_attrib_rec      => l_item_attributes_rec,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_item_attributes_rec.serial_control_code <> 1 then
        l_split_flag     := fnd_api.g_true;
        l_split_quantity := 1;
        l_split_loop     := p_source_line_rec.source_quantity;
      END IF;

      IF l_split_flag = fnd_api.g_false THEN
        l_split_quantity := p_source_line_rec.source_quantity;
        l_split_loop     := 1;
      END IF;

    ELSE
      l_split_quantity := p_split_quantity;
      l_split_loop     := p_split_loop;
    END IF;

    --
    l_pt_ind := 0;
    l_pa_ind := 0;
    l_oa_ind := 0;

    FOR i IN 1 .. l_split_loop
    LOOP

      l_td_ind := i;

      x_txn_line_detail_tbl(l_td_ind).transaction_line_id := fnd_api.g_miss_num;
      x_txn_line_detail_tbl(l_td_ind).txn_line_detail_id  := fnd_api.g_miss_num;
      x_txn_line_detail_tbl(l_td_ind).sub_type_id         := l_default_sub_type_id;
      x_txn_line_detail_tbl(l_td_ind).inventory_item_id   := p_source_line_rec.inventory_item_id;
      x_txn_line_detail_tbl(l_td_ind).source_transaction_flag := 'Y';
      x_txn_line_detail_tbl(l_td_ind).inv_organization_id := p_source_line_rec.organization_id;
      x_txn_line_detail_tbl(l_td_ind).unit_of_measure     := p_source_line_rec.uom_code;
      x_txn_line_detail_tbl(l_td_ind).inventory_revision  := p_source_line_rec.item_revision;
      x_txn_line_detail_tbl(l_td_ind).quantity            := l_split_quantity;

      -- Added IF condition for Bug 4314464
      IF l_partner_rec.IB_CURRENT_LOCATION = 'INSTALL_BASE'
      THEN
        x_txn_line_detail_tbl(l_td_ind).location_type_code := fnd_api.g_miss_char;
        x_txn_line_detail_tbl(l_td_ind).location_id        := fnd_api.g_miss_num;
      ELSE
        x_txn_line_detail_tbl(l_td_ind).location_type_code := 'HZ_PARTY_SITES';
        x_txn_line_detail_tbl(l_td_ind).location_id        := p_source_line_rec.ship_to_party_site_id;
      END IF;

      -- Added for partner ordering
      -- Added IF condition for Bug 4314464
      IF l_partner_rec.IB_INSTALLED_AT_LOCATION = 'INSTALL_BASE'
      THEN
        x_txn_line_detail_tbl(l_td_ind).install_location_type_code := fnd_api.g_miss_char;
        x_txn_line_detail_tbl(l_td_ind).install_location_id        := fnd_api.g_miss_num;
      ELSE
        x_txn_line_detail_tbl(l_td_ind).install_location_type_code  := 'HZ_PARTY_SITES';
        x_txn_line_detail_tbl(l_td_ind).install_location_id         := p_source_line_rec.install_to_party_site_id;
      END IF;
      -- Added for partner ordering

      x_txn_line_detail_tbl(l_td_ind).processing_status   := 'SUBMIT';
      x_txn_line_detail_tbl(l_td_ind).instance_exists_flag := 'N';
      x_txn_line_detail_tbl(l_td_ind).object_version_number := 1.0;

      -- build owner party record
      l_pt_ind       := l_pt_ind + 1;
      l_owner_pt_ind := l_pt_ind;

      x_txn_party_tbl(l_pt_ind).txn_line_detail_id     := fnd_api.g_miss_num;
      x_txn_party_tbl(l_pt_ind).txn_party_detail_id    := fnd_api.g_miss_num;
      x_txn_party_tbl(l_pt_ind).txn_line_details_index := l_td_ind;
      x_txn_party_tbl(l_pt_ind).party_source_table     := 'HZ_PARTIES';

      -- For Bug 3443175.
      IF l_partner_rec.IB_OWNER = 'INSTALL_BASE'
      THEN
        x_txn_party_tbl(l_pt_ind).party_source_id      := fnd_api.g_miss_num;
      ELSE
        x_txn_party_tbl(l_pt_ind).party_source_id      := p_source_line_rec.owner_party_id;
      END IF;

      x_txn_party_tbl(l_pt_ind).relationship_type_code := 'OWNER';
      x_txn_party_tbl(l_pt_ind).contact_flag           := 'N';
      x_txn_party_tbl(l_pt_ind).object_version_number  := 1.0;

      -- build owner party account record
      l_pa_ind := l_pa_ind + 1;
      x_txn_party_acct_tbl(l_pa_ind).txn_party_detail_id     := fnd_api.g_miss_num;
      x_txn_party_acct_tbl(l_pa_ind).txn_account_detail_id   := fnd_api.g_miss_num;
      x_txn_party_acct_tbl(l_pa_ind).txn_party_details_index := l_owner_pt_ind;

      -- For Bug 3443175.
      IF l_partner_rec.IB_OWNER = 'INSTALL_BASE'
      THEN
        x_txn_party_acct_tbl(l_pa_ind).account_id := fnd_api.g_miss_num;
      ELSE
        x_txn_party_acct_tbl(l_pa_ind).account_id := p_source_line_rec.owner_party_account_id;
      END IF;

      x_txn_party_acct_tbl(l_pa_ind).relationship_type_code  := 'OWNER';
      IF p_source_line_rec.bill_to_address_id is not null THEN
        x_txn_party_acct_tbl(l_pa_ind).bill_to_address_id := p_source_line_rec.bill_to_address_id;
      END IF;
      IF p_source_line_rec.ship_to_address_id is not null THEN
        x_txn_party_acct_tbl(l_pa_ind).ship_to_address_id := p_source_line_rec.ship_to_address_id;
      END IF;
      x_txn_party_acct_tbl(l_pa_ind).object_version_number := 1.0;

      -- build sold_to party

      -- build ship_to contact
      IF p_source_line_rec.ship_to_contact_party_id is not null THEN

        l_pt_ind       := l_pt_ind + 1;

        x_txn_party_tbl(l_pt_ind).txn_line_detail_id     := fnd_api.g_miss_num;
        x_txn_party_tbl(l_pt_ind).txn_party_detail_id    := fnd_api.g_miss_num;
        x_txn_party_tbl(l_pt_ind).txn_line_details_index := l_td_ind;
        x_txn_party_tbl(l_pt_ind).party_source_table     := 'HZ_PARTIES';
        x_txn_party_tbl(l_pt_ind).party_source_id        :=
                                      p_source_line_rec.ship_to_contact_party_id;
        x_txn_party_tbl(l_pt_ind).relationship_type_code := 'SHIP_TO';
        x_txn_party_tbl(l_pt_ind).contact_flag           := 'Y';
        x_txn_party_tbl(l_pt_ind).contact_party_id       := l_owner_pt_ind;
        x_txn_party_tbl(l_pt_ind).object_version_number  := 1.0;

      END IF;

      -- build bill_to contact
      IF p_source_line_rec.bill_to_contact_party_id is not null THEN

        l_pt_ind       := l_pt_ind + 1;

        x_txn_party_tbl(l_pt_ind).txn_line_detail_id     := fnd_api.g_miss_num;
        x_txn_party_tbl(l_pt_ind).txn_party_detail_id    := fnd_api.g_miss_num;
        x_txn_party_tbl(l_pt_ind).txn_line_details_index := l_td_ind;
        x_txn_party_tbl(l_pt_ind).party_source_table     := 'HZ_PARTIES';
        x_txn_party_tbl(l_pt_ind).party_source_id        :=
                                      p_source_line_rec.bill_to_contact_party_id;
        x_txn_party_tbl(l_pt_ind).relationship_type_code := 'BILL_TO';
        x_txn_party_tbl(l_pt_ind).contact_flag           := 'Y';
        x_txn_party_tbl(l_pt_ind).contact_party_id          := l_owner_pt_ind;
        x_txn_party_tbl(l_pt_ind).object_version_number  := 1.0;

      END IF;

      -- build org units
      IF p_source_line_rec.sold_from_org_id is not null THEN
        l_oa_ind := l_oa_ind + 1;
        x_txn_org_assgn_tbl(l_oa_ind).txn_line_detail_id     := fnd_api.g_miss_num;
        x_txn_org_assgn_tbl(l_oa_ind).txn_line_details_index := l_td_ind;
        x_txn_org_assgn_tbl(l_oa_ind).operating_unit_id      :=
                                          p_source_line_rec.sold_from_org_id;
        x_txn_org_assgn_tbl(l_oa_ind).relationship_type_code := 'SOLD_FROM';
        x_txn_org_assgn_tbl(l_oa_ind).preserve_detail_flag   := 'Y';
        x_txn_org_assgn_tbl(l_oa_ind).object_version_number  := 1.0;
        x_txn_org_assgn_tbl(l_oa_ind).active_end_date        := NULL; --fix for bug5511381
      END IF;

    END LOOP;

  END build_td_from_source;
  /* ------------------------------------------------------------------- */
  /* use the source information and build a default transaction detail  */
  /* ------------------------------------------------------------------- */

  -- this routine also splits the txn_line_detail based on the srl cntrl flag
  -- and also based on the parent/child ratio so that the instance are
  -- based on the number of txn line detail records

  -- for shipping we might want to pass the mtl_txn_table based on which we should
  -- build the txn detail table

  -- cascades the txn details from the first parent with txn detail.

  PROCEDURE build_default_txn_detail(
    p_source_table          IN  varchar2,
    p_source_id             IN  number,
    p_source_header_rec     IN  source_header_rec,
    p_source_line_rec       IN  source_line_rec,
    p_csi_txn_rec           IN  csi_datastructures_pub.transaction_rec,
    px_txn_line_rec         IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec, --bug 5194812, changed this param to IN OUT
    x_txn_line_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_party_acct_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_pricing_attribs_tbl   OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_default_sub_type_id       number;

    l_cascade_flag              boolean := FALSE;
    l_cascade_string            varchar2(2000);

    l_parent_td_found           boolean := FALSE;
    l_parent_td_line_rec        source_line_rec;
    l_trackable_parent_found    boolean := FALSE;
    l_parent_line_rec           source_line_rec;
    l_child_order_line_tbl      source_line_tbl;

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_item_attributes_rec       item_attributes_rec;

    l_line_dtl_tbl              csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl              csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl             csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl            csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl                csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl               csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl           csi_t_datastructures_grp.txn_systems_tbl;

    l_split_flag                varchar2(1) := fnd_api.g_false;
    l_split_quantity            number      := 1;
    l_split_loop                number      := 1;

    l_return_status             varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                 number;
    l_msg_data                  varchar2(2000);
    l_transaction_type_id       number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_default_txn_detail');

    IF p_source_table = g_om_source_table THEN

      px_txn_line_rec.source_transaction_id      := p_source_line_rec.source_line_id;
      px_txn_line_rec.source_transaction_table   := g_om_source_table;

      --IF condition added for bug 5194812--
      IF nvl(px_txn_line_rec.source_transaction_type_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        px_txn_line_rec.source_transaction_type_id := g_om_txn_type_id;
      END IF;

      px_txn_line_rec.processing_status          := 'SUBMIT';

      IF p_source_line_rec.link_to_line_id is not null THEN

        /* the following code is to identify the first trackable parent having
           the installation detail. This is to cascade the installation detail
        */
        get_parent_with_txn_detail(
          p_source_line_rec    => p_source_line_rec,
          x_parent_found       => l_parent_td_found,
          x_parent_line_rec    => l_parent_td_line_rec,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_parent_td_found THEN
          debug('  Parent with transaction detail found. Line ID :'||l_parent_td_line_rec.source_line_id);

          cascade_txn_detail(
            p_parent_line_rec     => l_parent_td_line_rec,
            p_child_line_rec      => p_source_line_rec,
            x_txn_line_detail_tbl => l_line_dtl_tbl,
            x_txn_party_tbl       => l_pty_dtl_tbl,
            x_txn_party_acct_tbl  => l_pty_acct_tbl,
            x_txn_org_assgn_tbl   => l_org_assgn_tbl,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_cascade_flag := TRUE;

        END IF;

      END IF;

      IF l_cascade_flag THEN

        x_txn_line_detail_tbl  := l_line_dtl_tbl;
        x_txn_party_tbl        := l_pty_dtl_tbl;
        x_txn_party_acct_tbl   := l_pty_acct_tbl;
        x_txn_org_assgn_tbl    := l_org_assgn_tbl;

        -- rebuild_txn_details
        rebuild_txn_detail(
          p_source_table         => p_source_table,
          p_source_id            => p_source_id,
          p_source_header_rec    => p_source_header_rec,
          p_source_line_rec      => p_source_line_rec,
          p_csi_txn_rec          => p_csi_txn_rec,
          px_txn_line_rec        => px_txn_line_rec,
          px_txn_line_detail_tbl => x_txn_line_detail_tbl,
          px_txn_party_tbl       => x_txn_party_tbl,
          px_txn_party_acct_tbl  => x_txn_party_acct_tbl,
          px_txn_org_assgn_tbl   => x_txn_org_assgn_tbl,
          x_pricing_attribs_tbl  => x_pricing_attribs_tbl,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE -- not(l_cascade_flag) not cascaded from the parent

        /* this piece or code is to figure out if the order line is eligible for a
           split for building parent and child relationship
        */
        IF p_source_line_rec.link_to_line_id is not null THEN

          get_ib_trackable_parent(
            p_source_line_rec    => p_source_line_rec,
            x_parent_found       => l_trackable_parent_found,
            x_parent_line_rec    => l_parent_line_rec,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_trackable_parent_found THEN
            l_split_flag     := fnd_api.g_true;
            l_split_quantity := p_source_line_rec.source_quantity/l_parent_line_rec.source_quantity;
            l_split_loop     := l_parent_line_rec.source_quantity;
          END IF;

        END IF;

        IF p_source_line_rec.source_quantity > 1 THEN

          get_ib_trackable_children(
            p_current_line_id    => p_source_line_rec.source_line_id,
            x_trackable_line_tbl => l_child_order_line_tbl,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_child_order_line_tbl.COUNT > 0 THEN
            l_split_flag     := fnd_api.g_true;
            l_split_quantity := 1;
            l_split_loop     := p_source_line_rec.source_quantity;
          END IF;

        END IF;

        -- based on how it should be split while creating the default txn detail
        l_transaction_type_id := px_txn_line_rec.source_transaction_type_id;

        build_td_from_source(
          p_split_flag            => l_split_flag,
          p_split_quantity        => l_split_quantity,
          p_split_loop            => l_split_loop,
          p_transaction_type_id   => l_transaction_type_id , --bug 5194812
          p_source_header_rec     => p_source_header_rec,
          p_source_line_rec       => p_source_line_rec,
          p_csi_txn_rec           => p_csi_txn_rec,
          x_txn_line_rec          => px_txn_line_rec,
          x_txn_line_detail_tbl   => x_txn_line_detail_tbl,
          x_txn_party_tbl         => x_txn_party_tbl,
          x_txn_party_acct_tbl    => x_txn_party_acct_tbl,
          x_txn_org_assgn_tbl     => x_txn_org_assgn_tbl,
          x_pricing_attribs_tbl   => x_pricing_attribs_tbl,
          x_return_status         => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF; -- cascade check
      --
    ELSIF p_source_table = g_oke_source_table THEN

      l_split_flag     := fnd_api.g_false;
      l_split_quantity := p_source_line_rec.source_quantity;
      l_split_loop     := 1;

      build_td_from_source(
        p_split_flag            => l_split_flag,
        p_split_quantity        => l_split_quantity,
        p_split_loop            => l_split_loop,
        p_transaction_type_id   => g_oke_txn_type_id,
        p_source_header_rec     => p_source_header_rec,
        p_source_line_rec       => p_source_line_rec,
        p_csi_txn_rec           => p_csi_txn_rec,
        x_txn_line_rec          => px_txn_line_rec,
        x_txn_line_detail_tbl   => x_txn_line_detail_tbl,
        x_txn_party_tbl         => x_txn_party_tbl,
        x_txn_party_acct_tbl    => x_txn_party_acct_tbl,
        x_txn_org_assgn_tbl     => x_txn_org_assgn_tbl,
        x_pricing_attribs_tbl   => x_pricing_attribs_tbl,
        x_return_status         => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- build pricing attribs
    get_pricing_attributes(
      p_line_id             => p_source_line_rec.source_line_id,
      x_pricing_attribs_tbl => x_pricing_attribs_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_default_txn_detail;


  /* ------------------------------------------------------------------- */
  /* this routine is to rebuild the user entered transaction detail with */
  /* the addition of all the defaults like contacts, org assignments etc.*/
  /* ------------------------------------------------------------------- */

  -- rebuild also splits the transaction detail bases on the serial control
  -- flag or the based on the parent/child ratios.

  PROCEDURE rebuild_txn_detail(
    p_source_table         IN  varchar2,
    p_source_id            IN  number,
    p_source_header_rec    IN  source_header_rec,
    p_source_line_rec      IN  source_line_rec,
    p_csi_txn_rec          IN  csi_datastructures_pub.transaction_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_pricing_attribs_tbl  OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS
    l_tld_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pa_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_oa_tbl           csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_eav_tbl          csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl;

    l_return_status          varchar2(1);
    l_msg_count              number;
    l_msg_data               varchar2(2000);

    l_owner_pty_index        binary_integer := 0;

    l_owner_found            boolean := FALSE;
    l_ship_to_contact_found  boolean := FALSE;
    l_bill_to_contact_found  boolean := FALSE;
    l_org_assignment_found   boolean := FALSE;

    l_n_pt_ind               binary_integer := 0;
    l_n_pa_ind               binary_integer := 0;
    l_oa_n_ind               binary_integer := 0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('rebuild_txn_detail');

    -- convert all the ids to indexes

    l_tld_tbl := px_txn_line_detail_tbl;
    l_pty_tbl := px_txn_party_tbl;
    l_pa_tbl  := px_txn_party_acct_tbl;
    l_oa_tbl  := px_txn_org_assgn_tbl;

    csi_t_utilities_pvt.convert_ids_to_index(
      px_line_dtl_tbl    => l_tld_tbl,
      px_pty_dtl_tbl     => l_pty_tbl,
      px_pty_acct_tbl    => l_pa_tbl,
      px_ii_rltns_tbl    => l_ii_rltns_tbl,
      px_org_assgn_tbl   => l_oa_tbl,
      px_ext_attrib_tbl  => l_eav_tbl,
      px_txn_systems_tbl => l_systems_tbl);

    -- check if the tld needs to be split based on
      -- a. order line being a parent
      -- b. serialized item
      -- c. the split profile is turned on
    -- for ATandT qty is always one so not putting in the logic now.


    IF l_tld_tbl.count > 0 THEN
      FOR l_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP

        l_owner_found           := FALSE;
        l_ship_to_contact_found := FALSE;
        l_bill_to_contact_found := FALSE;
        l_org_assignment_found  := FALSE;
        l_owner_pty_index       := null;

        IF l_tld_tbl(l_ind).source_transaction_flag = 'Y' THEN
          -- check if every source tld has all the default contacts, org assign etc
          IF l_pty_tbl.COUNT > 0 THEN
            FOR l_pt_ind IN l_pty_tbl.FIRST .. l_pty_tbl.LAST
            LOOP
              IF l_pty_tbl(l_pt_ind).txn_line_details_index = l_ind THEN
                -- check if owner record is there /compare it with the om line customer
                -- check and default the contact party /ship to/ bill to
                -- also eliminate the owner account based on the owner change flag
                IF l_pty_tbl(l_pt_ind).relationship_type_code = 'OWNER' THEN

                  l_owner_found     := TRUE;
                  l_owner_pty_index := l_pt_ind;

                END IF;

                IF  l_pty_tbl(l_pt_ind).relationship_type_code = 'SHIP_TO'
                      AND
                    l_pty_tbl(l_pt_ind).contact_flag = 'Y'
                      AND
                    l_pty_tbl(l_pt_ind).party_source_table = 'HZ_PARTIES'
                      AND
                    l_pty_tbl(l_pt_ind).party_source_id = p_source_line_rec.ship_to_contact_party_id
                THEN
                  l_ship_to_contact_found := TRUE;
                END IF;

                IF  l_pty_tbl(l_pt_ind).relationship_type_code = 'BILL_TO'
                      AND
                    l_pty_tbl(l_pt_ind).contact_flag = 'Y'
                      AND
                    l_pty_tbl(l_pt_ind).party_source_table = 'HZ_PARTIES'
                      AND
                    l_pty_tbl(l_pt_ind).party_source_id = p_source_line_rec.bill_to_contact_party_id
                THEN
                  l_bill_to_contact_found := TRUE;
                END IF;

                IF l_pa_tbl.COUNT > 0 THEN

                  FOR l_pa_ind IN l_pa_tbl.FIRST .. l_pa_tbl.LAST
                  LOOP
                    IF l_pa_tbl(l_pa_ind).txn_party_details_index = l_pt_ind THEN
                      -- check and default the owner account
                      null;
                    END IF;
                  END LOOP;
                END IF;
              END IF; -- txn_line_details_index = l_ind
            END LOOP;
          END IF; -- pty_tbl.count > 0

          IF l_oa_tbl.COUNT > 0 THEN
            FOR l_oa_ind IN l_oa_tbl.FIRST .. l_oa_tbl.LAST
            LOOP
              IF l_oa_tbl(l_oa_ind).txn_line_details_index = l_ind THEN
              -- check and default the org assignments
                null;
                IF l_oa_tbl(l_oa_ind).relationship_type_code = 'SOLD_FROM'
                     AND
                   l_oa_tbl(l_oa_ind).operating_unit_id      = p_source_line_rec.sold_from_org_id
                THEN
                  l_org_assignment_found := TRUE;
                END IF;
              END IF;
            END LOOP;
          END IF; -- l_oa_tbl.count > 0

          IF l_owner_found THEN

            IF NOT (l_ship_to_contact_found)
                 AND
               p_source_line_rec.ship_to_contact_party_id is not null
            THEN

              l_n_pt_ind := l_pty_tbl.count + 1;

              l_pty_tbl(l_n_pt_ind).txn_line_detail_id     := fnd_api.g_miss_num;
              l_pty_tbl(l_n_pt_ind).txn_party_detail_id    := fnd_api.g_miss_num;
              l_pty_tbl(l_n_pt_ind).txn_line_details_index := l_ind;
              l_pty_tbl(l_n_pt_ind).party_source_table     := 'HZ_PARTIES';
              l_pty_tbl(l_n_pt_ind).party_source_id        := p_source_line_rec.ship_to_contact_party_id;
              l_pty_tbl(l_n_pt_ind).relationship_type_code := 'SHIP_TO';
              l_pty_tbl(l_n_pt_ind).contact_flag           := 'Y';
              l_pty_tbl(l_n_pt_ind).contact_party_id       := l_owner_pty_index;
              l_pty_tbl(l_n_pt_ind).object_version_number  := 1.0;
            END IF;

            IF NOT (l_bill_to_contact_found)
                 AND
               p_source_line_rec.bill_to_contact_party_id is not null
            THEN
              l_pty_tbl(l_n_pt_ind).txn_line_detail_id     := fnd_api.g_miss_num;
              l_pty_tbl(l_n_pt_ind).txn_party_detail_id    := fnd_api.g_miss_num;
              l_pty_tbl(l_n_pt_ind).txn_line_details_index := l_ind;
              l_pty_tbl(l_n_pt_ind).party_source_table     := 'HZ_PARTIES';
              l_pty_tbl(l_n_pt_ind).party_source_id        := p_source_line_rec.bill_to_contact_party_id;
              l_pty_tbl(l_n_pt_ind).relationship_type_code := 'BILL_TO';
              l_pty_tbl(l_n_pt_ind).contact_flag           := 'Y';
              l_pty_tbl(l_n_pt_ind).contact_party_id       := l_owner_pty_index;
              l_pty_tbl(l_n_pt_ind).object_version_number  := 1.0;
            END IF;

          END IF;

          IF NOT(l_org_assignment_found) THEN

            l_oa_n_ind := l_oa_tbl.COUNT + 1;

            l_oa_tbl(l_oa_n_ind).txn_line_detail_id     := fnd_api.g_miss_num;
            l_oa_tbl(l_oa_n_ind).txn_line_details_index := l_ind;
            l_oa_tbl(l_oa_n_ind).operating_unit_id      := p_source_line_rec.sold_from_org_id;
            l_oa_tbl(l_oa_n_ind).relationship_type_code := 'SOLD_FROM';
            l_oa_tbl(l_oa_n_ind).preserve_detail_flag   := 'Y';
            l_oa_tbl(l_oa_n_ind).object_version_number  := 1.0;

          END IF;

        END IF; -- source_transaction_flag = 'Y'
      END LOOP; -- l_tld_tbl loop
    END IF; -- l_tld_tbl.count > 0

    px_txn_line_detail_tbl := l_tld_tbl;
    px_txn_party_tbl       := l_pty_tbl;
    px_txn_party_acct_tbl  := l_pa_tbl;
    px_txn_org_assgn_tbl   := l_oa_tbl;

    IF px_txn_line_rec.source_transaction_table = 'OE_ORDER_LINES_ALL' THEN

      get_pricing_attributes(
        p_line_id               => px_txn_line_rec.source_transaction_id,
        x_pricing_attribs_tbl   => x_pricing_attribs_tbl,
        x_return_status         => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END rebuild_txn_detail;

  --
  --
  --
  PROCEDURE get_cz_txn_details(
    p_config_session_key   IN csi_utility_grp.config_session_key,
    x_txn_line_rec            OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_line_dtl_tbl        OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_party_acct_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_txn_ii_rltns_tbl        OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_eav_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_txn_line_query_rec         csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_g_line_dtl_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_g_pty_dtl_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_g_pty_acct_tbl       csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_g_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_g_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_g_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_g_csi_ea_tbl         csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_g_csi_eav_tbl        csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_g_txn_systems_tbl    csi_t_datastructures_grp.txn_systems_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(512);
    l_msg_count            number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_cz_txn_details');

    --l_txn_line_query_rec.source_transaction_type_id := 401;
    l_txn_line_query_rec.source_transaction_table := 'CONFIGURATOR';
    l_txn_line_query_rec.config_session_hdr_id    := p_config_session_key.session_hdr_id;
    l_txn_line_query_rec.config_session_item_id   := p_config_session_key.session_item_id;
    l_txn_line_query_rec.config_session_rev_num   := p_config_session_key.session_rev_num;

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version               => 1.0,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_txn_line_query_rec        => l_txn_line_query_rec,
      p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl       => l_g_line_dtl_tbl,
      p_get_parties_flag          => fnd_api.g_false,
      x_txn_party_detail_tbl      => l_g_pty_dtl_tbl,
      p_get_pty_accts_flag        => fnd_api.g_false,
      x_txn_pty_acct_detail_tbl   => l_g_pty_acct_tbl,
      p_get_ii_rltns_flag         => fnd_api.g_true,
      x_txn_ii_rltns_tbl          => l_g_ii_rltns_tbl,
      p_get_org_assgns_flag       => fnd_api.g_false,
      x_txn_org_assgn_tbl         => l_g_org_assgn_tbl,
      p_get_ext_attrib_vals_flag  => fnd_api.g_true,
      x_txn_ext_attrib_vals_tbl   => l_g_ext_attrib_tbl,
      p_get_csi_attribs_flag      => fnd_api.g_false,
      x_csi_ext_attribs_tbl       => l_g_csi_ea_tbl,
      p_get_csi_iea_values_flag   => fnd_api.g_false,
      x_csi_iea_values_tbl        => l_g_csi_eav_tbl,
      p_get_txn_systems_flag      => fnd_api.g_false,
      x_txn_systems_tbl           => l_g_txn_systems_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_g_line_dtl_tbl.COUNT > 0 THEN

      BEGIN
        SELECT source_transaction_type_id,
               transaction_line_id,
               source_transaction_table,
               config_session_hdr_id,
               config_session_item_id,
               config_session_rev_num
        INTO   x_txn_line_rec.source_transaction_type_id,
               x_txn_line_rec.transaction_line_id,
               x_txn_line_rec.source_transaction_table,
               x_txn_line_rec.config_session_hdr_id,
               x_txn_line_rec.config_session_item_id,
               x_txn_line_rec.config_session_rev_num
        FROM   csi_t_transaction_lines
        WHERE  transaction_line_id = l_g_line_dtl_tbl(1).transaction_line_id;
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;

    END IF;

    IF l_g_line_dtl_tbl.COUNT > 0 THEN
      FOR l_ind IN l_g_line_dtl_tbl.FIRST .. l_g_line_dtl_tbl.LAST
      LOOP
        l_g_line_dtl_tbl(l_ind).source_txn_line_detail_id :=
                                l_g_line_dtl_tbl(l_ind).txn_line_detail_id;
      END LOOP;
    END IF;


    x_txn_line_dtl_tbl := l_g_line_dtl_tbl;
    x_txn_ii_rltns_tbl := l_g_ii_rltns_tbl;
    x_txn_eav_tbl      := l_g_ext_attrib_tbl;

    debug('txn details record count :-');
    debug('  txn_line_dtl_tbl  :'||x_txn_line_dtl_tbl.COUNT);
    debug('  txn_ii_rltns_tbl  :'||x_txn_ii_rltns_tbl.COUNT);
    debug('  txn_eav_tbl       :'||x_txn_eav_tbl.COUNT);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_cz_txn_details;

  --
  --
  --
  PROCEDURE get_config_keys_for_order(
    p_header_id            IN  number,
    x_config_session_keys  OUT NOCOPY csi_utility_grp.config_session_keys,
    x_return_status        OUT NOCOPY varchar2)
  IS

    CURSOR keys_cur IS
      SELECT config_header_id  config_session_hdr_id,
             config_rev_nbr    config_session_rev_num,
             configuration_id  config_session_item_id
      FROM   oe_order_lines_all
      WHERE  header_id = p_header_id;

    l_ind                  binary_integer := 0;

    l_return_status        varchar2(1);
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_keys_for_order');

    FOR keys_rec IN keys_cur
    LOOP

      l_ind := keys_cur%rowcount;

      x_config_session_keys(l_ind).session_hdr_id  := keys_rec.config_session_hdr_id;
      x_config_session_keys(l_ind).session_item_id := keys_rec.config_session_item_id;
      x_config_session_keys(l_ind).session_rev_num := keys_rec.config_session_rev_num;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_keys_for_order;

  --
  --
  --
  PROCEDURE get_all_txn_rltns_for_order(
    p_header_id            IN  number,
    x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    -- get_cz_txn_details variable
    l_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_dtl_tbl     csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_party_acct_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl    csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_eav_tbl          csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_order_session_keys   csi_utility_grp.config_session_keys;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

    x_ind                  binary_integer := 0;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_all_txn_rltns_for_order');

    -- get all the session keys for the order using the header_id
    get_config_keys_for_order(
      p_header_id            => p_header_id,
      x_config_session_keys  => l_order_session_keys,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_order_session_keys.COUNT > 0 THEN
      FOR l_ind IN l_order_session_keys.FIRST .. l_order_session_keys.LAST
      LOOP

        get_cz_txn_details(
          p_config_session_key   => l_order_session_keys(l_ind),
          x_txn_line_rec         => l_txn_line_rec,
          x_txn_line_dtl_tbl     => l_txn_line_dtl_tbl,
          x_txn_party_tbl        => l_txn_party_tbl,
          x_txn_party_acct_tbl   => l_txn_party_acct_tbl,
          x_txn_org_assgn_tbl    => l_txn_org_assgn_tbl,
          x_txn_ii_rltns_tbl     => l_txn_ii_rltns_tbl,
          x_txn_eav_tbl          => l_txn_eav_tbl,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_txn_ii_rltns_tbl.COUNT > 0 THEN
          FOR l_ii_ind IN l_txn_ii_rltns_tbl.FIRST .. l_txn_ii_rltns_tbl.LAST
          LOOP

            x_ind := x_ind + 1;
            x_txn_ii_rltns_tbl(x_ind) := l_txn_ii_rltns_tbl(l_ii_ind);

          END LOOP;
        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_txn_rltns_for_order;

  --
  --
  --
  PROCEDURE filter_relations(
    p_instance_key         IN     csi_utility_grp.config_instance_key,
    p_transaction_line_id  IN     number,
    px_txn_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_rltns_tbl            csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_new_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_o_ind                binary_integer := 0;
    l_n_ind                binary_integer := 0;
    l_subject_object_flag  varchar2(1);
    l_instance_found       boolean := FALSE;
    l_already_processed    boolean := FALSE;
    l_processing_status    varchar2(30);

    l_dummy                varchar2(1);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('filter_relations');

    l_rltns_tbl := px_txn_ii_rltns_tbl;

    -- rebuild the relations for eliminating the already processed relations
    -- and the cannot process relations (subject or object not as instance)

    IF l_rltns_tbl.count > 0 THEN
      FOR l_ind IN l_rltns_tbl.FIRST .. l_rltns_tbl.LAST
      LOOP

        l_instance_found := FALSE;

        IF (  l_rltns_tbl(l_ind).sub_config_inst_hdr_id = p_instance_key.inst_hdr_id
              AND
              l_rltns_tbl(l_ind).sub_config_inst_rev_num = p_instance_key.inst_rev_num
              AND
              l_rltns_tbl(l_ind).sub_config_inst_item_id = p_instance_key.inst_item_id
           )
        THEN
          l_subject_object_flag := 'O';
        ELSE
          null;
        END IF;

        IF (  l_rltns_tbl(l_ind).obj_config_inst_hdr_id = p_instance_key.inst_hdr_id
              AND
              l_rltns_tbl(l_ind).obj_config_inst_rev_num = p_instance_key.inst_rev_num
              AND
              l_rltns_tbl(l_ind).obj_config_inst_item_id = p_instance_key.inst_item_id
           )
        THEN
          l_subject_object_flag := 'S';
        ELSE
          null;
        END IF;

        -- check if it is existing as an instance in installed base
        -- if not then eliminate this relation
        debug('transaction_line_id   :'||l_rltns_tbl(l_ind).transaction_line_id);
        debug('p_transaction_line_id :'||p_transaction_line_id);

        l_processing_status := 'PROCESSED';

        IF l_rltns_tbl(l_ind).transaction_line_id <> p_transaction_line_id THEN
          BEGIN
            SELECT processing_status
            INTO   l_processing_status
            FROM   csi_t_transaction_lines
            WHERE  transaction_line_id = l_rltns_tbl(l_ind).transaction_line_id;
          END;
        END IF;

        IF l_processing_status = 'PROCESSED' THEN

           IF l_subject_object_flag = 'O' THEN

              debug('This relation is OBJECT to the current processing line detail');

              debug('  inst_hdr_id  :'||l_rltns_tbl(l_ind).obj_config_inst_hdr_id);
              debug('  inst_rev_num :'||l_rltns_tbl(l_ind).obj_config_inst_rev_num);
              debug('  inst_item_id :'||l_rltns_tbl(l_ind).obj_config_inst_item_id);
              debug('  relationship :'||l_rltns_tbl(l_ind).relationship_type_code);

              IF l_rltns_tbl(l_ind).object_type = 'I' THEN
                 l_instance_found := TRUE;
              ELSE
                 BEGIN
                    SELECT 'Y' INTO l_dummy
                    FROM   csi_item_instances
                    WHERE  config_inst_hdr_id  = l_rltns_tbl(l_ind).obj_config_inst_hdr_id
                    --AND    config_inst_rev_num = l_rltns_tbl(l_ind).obj_config_inst_rev_num
                    AND    config_inst_item_id = l_rltns_tbl(l_ind).obj_config_inst_item_id;

                    l_instance_found := TRUE;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       BEGIN
                          SELECT 'Y' INTO l_dummy
                          FROM CSI_T_TXN_LINE_DETAILS
                          WHERE txn_line_detail_id = l_rltns_tbl(l_ind).object_id
                          AND   instance_id IS NOT NULL;

                          l_instance_found := TRUE;
                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             l_instance_found := FALSE;
                       END;
                 END;
              END IF;

           ELSIF l_subject_object_flag = 'S' THEN

              debug('This relation is SUBJECT to the current processing line detail');

              debug('  inst_hdr_id  :'||l_rltns_tbl(l_ind).sub_config_inst_hdr_id);
              debug('  inst_rev_num :'||l_rltns_tbl(l_ind).sub_config_inst_rev_num);
              debug('  inst_item_id :'||l_rltns_tbl(l_ind).sub_config_inst_item_id);
              debug('  relationship :'||l_rltns_tbl(l_ind).relationship_type_code);

              IF l_rltns_tbl(l_ind).subject_type = 'I' THEN
                 l_instance_found := TRUE;
              ELSE
                 BEGIN
                    SELECT 'Y' INTO l_dummy
                    FROM   csi_item_instances
                    WHERE  config_inst_hdr_id  = l_rltns_tbl(l_ind).sub_config_inst_hdr_id
                    --AND    config_inst_rev_num = l_rltns_tbl(l_ind).sub_config_inst_rev_num
                    AND    config_inst_item_id = l_rltns_tbl(l_ind).sub_config_inst_item_id;

                    l_instance_found := TRUE;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       BEGIN
                          SELECT 'Y' INTO l_dummy
                          FROM CSI_T_TXN_LINE_DETAILS
                          WHERE txn_line_detail_id = l_rltns_tbl(l_ind).subject_id
                          AND   instance_id IS NOT NULL;

                          l_instance_found := TRUE;
                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                             l_instance_found := FALSE;
                       END;
                 END;
              END IF;

           ELSE
              debug('neither subject nor object *');

              l_instance_found := FALSE;
           END IF;
        ELSE
          l_instance_found := FALSE;
        END IF;

        -- check if the relation is already processed into install base

        IF l_instance_found  THEN
          l_n_ind := l_new_rltns_tbl.COUNT + 1;
          l_new_rltns_tbl(l_n_ind) := l_rltns_tbl(l_ind);
        END IF;

      END LOOP;
    END IF;

    px_txn_ii_rltns_tbl := l_new_rltns_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END filter_relations;

  --
  --
  --
  PROCEDURE get_cz_relations(
    p_source_header_rec    IN  source_header_rec,
    p_source_line_rec      IN  source_line_rec,
    px_txn_line_rec        IN OUT NOCOPY  csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_eav_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_line_session_key     csi_utility_grp.config_session_key;

    l_src_instance_key     csi_utility_grp.config_instance_key;
    l_src_tld_rec          csi_t_datastructures_grp.txn_line_detail_rec;
    l_src_tld_index        binary_integer := 0;
    l_source_identified    boolean := FALSE;

    l_tld_tbl              csi_t_datastructures_grp.txn_line_detail_tbl;
    l_n_td_ind             binary_integer := 0;

    l_filtered_rltns_tbl   csi_t_datastructures_grp.txn_ii_rltns_tbl;

    -- get txn details variables
    l_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_dtl_tbl     csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_party_acct_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl    csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_eav_tbl          csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_ord_txn_ii_rltns_tbl csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status        varchar2(1);
    l_return_message       varchar2(2000);

    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_cz_relations');

    l_tld_tbl := px_txn_line_dtl_tbl;

    -- get_cz_txn_detail for the current order line using the line session key

    csi_utility_grp.get_config_key_for_om_line(
      p_line_id              => p_source_line_rec.source_line_id,
      x_config_session_key   => l_line_session_key,
      x_return_status        => l_return_status,
      x_return_message       => l_return_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    get_cz_txn_details(
      p_config_session_key   => l_line_session_key,
      x_txn_line_rec         => l_txn_line_rec,
      x_txn_line_dtl_tbl     => l_txn_line_dtl_tbl,
      x_txn_party_tbl        => l_txn_party_tbl,
      x_txn_party_acct_tbl   => l_txn_party_acct_tbl,
      x_txn_org_assgn_tbl    => l_txn_org_assgn_tbl,
      x_txn_ii_rltns_tbl     => l_txn_ii_rltns_tbl,
      x_txn_eav_tbl          => l_txn_eav_tbl,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- identify the txn line detail record that matches the current om line
    IF l_txn_line_dtl_tbl.COUNT > 0 THEN
      FOR l_ind IN l_txn_line_dtl_tbl.FIRST .. l_txn_line_dtl_tbl.LAST
      LOOP
        -- get the instance key for the source line detail record
        -- ## may have to change the condition here
        -- I should get only one record corresponding to the source being
        -- processed

        IF l_txn_line_dtl_tbl(l_ind).source_transaction_flag = 'Y' THEN

          l_src_instance_key.inst_hdr_id           := l_txn_line_dtl_tbl(l_ind).config_inst_hdr_id;
          l_src_instance_key.inst_rev_num          := l_txn_line_dtl_tbl(l_ind).config_inst_rev_num;
          l_src_instance_key.inst_item_id          := l_txn_line_dtl_tbl(l_ind).config_inst_item_id;
          l_src_instance_key.inst_baseline_rev_num := l_txn_line_dtl_tbl(l_ind).config_inst_baseline_rev_num;

          l_src_tld_rec       := l_txn_line_dtl_tbl(l_ind);
          l_src_tld_index     := l_ind;
          l_source_identified := TRUE;
          debug('dumping l_src_tld_rec..');
          csi_t_gen_utility_pvt.dump_line_detail_rec(l_src_tld_rec);
        ELSE
          l_n_td_ind := l_tld_tbl.COUNT + 1;
          l_tld_tbl(l_n_td_ind) := l_txn_line_dtl_tbl(l_ind);

          /* as the td indexes are chenged also remap the ext attrib indexes */
          IF l_txn_eav_tbl.COUNT > 0 THEN
            FOR l_e_ind IN l_txn_eav_tbl.FIRST .. l_txn_eav_tbl.LAST
            LOOP
              IF l_txn_eav_tbl(l_e_ind).txn_line_details_index = l_ind THEN
                l_txn_eav_tbl(l_e_ind).txn_line_details_index := l_n_td_ind;
              END IF;
            END LOOP;
          END IF;

        END IF;

      END LOOP;
    END IF;

    IF NOT(l_source_identified) THEN
      -- message source could not identified in the cz_txn_detail
      debug('source is not identified...');
      RAISE fnd_api.g_exc_error;
    END IF;

    dump_instance_key(l_src_instance_key);

    l_filtered_rltns_tbl := l_txn_ii_rltns_tbl;

    -- filter it where the src istance key matches either in the subject or object
    filter_relations(
      p_instance_key         => l_src_instance_key,
      p_transaction_line_id  => l_txn_line_rec.transaction_line_id,
      px_txn_ii_rltns_tbl    => l_filtered_rltns_tbl,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- return the filtered txn_ii_relation src_line detail and

    /* overlap the config source tld on the build or user entered source tld */
    IF l_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        IF l_tld_tbl(l_ind).source_transaction_flag = 'Y' THEN

          l_tld_tbl(l_ind).sub_type_id            := l_src_tld_rec.sub_type_id;
          l_tld_tbl(l_ind).config_inst_hdr_id     := l_src_tld_rec.config_inst_hdr_id;
          l_tld_tbl(l_ind).config_inst_rev_num    := l_src_tld_rec.config_inst_rev_num;
          l_tld_tbl(l_ind).config_inst_item_id    := l_src_tld_rec.config_inst_item_id;
          l_tld_tbl(l_ind).config_inst_baseline_rev_num := l_src_tld_rec.config_inst_baseline_rev_num;
          l_tld_tbl(l_ind).target_commitment_date := l_src_tld_rec.target_commitment_date;
          l_tld_tbl(l_ind).instance_description   := l_src_tld_rec.instance_description;

          l_tld_tbl(l_ind).active_start_date      := l_src_tld_rec.active_start_date;
          l_tld_tbl(l_ind).active_end_date        := l_src_tld_rec.active_end_date;
          --
          -- srramakr TSO with Equipment change.
          -- Since we started supporting Shippable items under MACD configuration and these items
          -- are serialized, there is a possiblity that Transaction detail record would have instance_id
          -- coming from build_shtd_tbl.
          -- Following instance_id assignment should be made based on instance_id value.
          --
          IF l_tld_tbl(l_ind).instance_id IS NULL OR
            l_tld_tbl(l_ind).instance_id = FND_API.G_MISS_NUM THEN
            IF l_src_tld_rec.instance_id IS NOT NULL
               AND
               l_src_tld_rec.instance_id <> FND_API.G_MISS_NUM
            THEN
              l_tld_tbl(l_ind).instance_id := l_src_tld_rec.instance_id;
              l_tld_tbl(l_ind).instance_exists_flag := 'Y';
            ELSE
              /* query install base to figure out the instance for the base line revision if TLD did not return*/
              BEGIN
                SELECT instance_id
                INTO   l_tld_tbl(l_ind).instance_id
                FROM   csi_item_instances
                WHERE  config_inst_hdr_id =  l_tld_tbl(l_ind).config_inst_hdr_id
                AND    config_inst_item_id = l_tld_tbl(l_ind).config_inst_item_id;
                l_tld_tbl(l_ind).instance_exists_flag := 'Y';
              EXCEPTION
                WHEN no_data_found THEN
                  l_tld_tbl(l_ind).instance_id          := fnd_api.g_miss_num;
                  l_tld_tbl(l_ind).instance_exists_flag := 'N';
              END;
            END IF;
          END IF;

          -- Fixed for Bug 4381930, Moved the Instance_id Query to above
          -- and assign the cz values if instance_id is existing, re-configuration case
          -- else take the values build from order or user entered.

          IF nvl(l_tld_tbl(l_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

            l_tld_tbl(l_ind).location_type_code     := l_src_tld_rec.location_type_code;
            l_tld_tbl(l_ind).location_id            := l_src_tld_rec.location_id;
            -- Added for partner ordering
            l_tld_tbl(l_ind).install_location_type_code     := l_src_tld_rec.install_location_type_code;
            l_tld_tbl(l_ind).install_location_id            := l_src_tld_rec.install_location_id;
            --
            -- Bug 4633376 CZ always passes the location info for re-configuration. Hence, inorder to
            -- distinguish between first time configuration and re-configuration, we use the instance_id.
            --
          ELSE
            IF nvl(l_src_tld_rec.location_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
               AND
               nvl(l_src_tld_rec.location_type_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
            THEN
              l_tld_tbl(l_ind).location_type_code     := l_src_tld_rec.location_type_code;
              l_tld_tbl(l_ind).location_id            := l_src_tld_rec.location_id;
            END IF;
            --
            IF nvl(l_src_tld_rec.install_location_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
               AND
               nvl(l_src_tld_rec.install_location_type_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
            THEN
              l_tld_tbl(l_ind).install_location_type_code     := l_src_tld_rec.install_location_type_code;
              l_tld_tbl(l_ind).install_location_id            := l_src_tld_rec.install_location_id;
            END IF;
          END IF;
          --
          -- srramakr Bug 4665537 TSO with Equipment.
          -- Inventory Revision and organization_id could come from WSH which is what we need to take.
          --
          IF l_tld_tbl(l_ind).inventory_revision IS NOT NULL AND
             l_tld_tbl(l_ind).inventory_revision = fnd_api.g_miss_char THEN
             l_tld_tbl(l_ind).inventory_revision := l_src_tld_rec.inventory_revision;
          END IF;
          --
          IF nvl(l_tld_tbl(l_ind).inv_organization_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
             l_tld_tbl(l_ind).inv_organization_id := l_src_tld_rec.inv_organization_id;
          END IF;
          --
          l_tld_tbl(l_ind).source_txn_line_detail_id := l_src_tld_rec.txn_line_detail_id;

          IF l_txn_eav_tbl.COUNT > 0 THEN
            FOR l_eav_ind IN l_txn_eav_tbl.FIRST .. l_txn_eav_tbl.LAST
            LOOP
              IF l_txn_eav_tbl(l_eav_ind).txn_line_detail_id = l_src_tld_rec.txn_line_detail_id
              THEN
                l_txn_eav_tbl(l_eav_ind).txn_line_details_index := l_ind;
                l_txn_eav_tbl(l_eav_ind).txn_line_detail_id := fnd_api.g_miss_num;
                l_txn_eav_tbl(l_eav_ind).txn_attrib_detail_id := fnd_api.g_miss_num;
              END IF;
            END LOOP;
          END IF;
        /* Begin fix for Bug 3502896 */
        ELSE
          csi_t_gen_utility_pvt.add(' NON SOURCE LINE ');
          BEGIN
            SELECT instance_id
            INTO   l_tld_tbl(l_ind).instance_id
            FROM   csi_item_instances
            WHERE  config_inst_hdr_id =  l_tld_tbl(l_ind).config_inst_hdr_id
            AND    config_inst_item_id = l_tld_tbl(l_ind).config_inst_item_id;
            l_tld_tbl(l_ind).instance_exists_flag := 'Y';
          EXCEPTION
            WHEN no_data_found THEN
              l_tld_tbl(l_ind).instance_id          := fnd_api.g_miss_num;
              l_tld_tbl(l_ind).instance_exists_flag := 'N';
			  fnd_message.set_name('CSI','CSI_TXN_CZ_INVALID_DATA');
			  fnd_message.set_token('INST_HDR_ID',l_tld_tbl(l_ind).config_inst_hdr_id);
			  fnd_message.set_token('INST_REV_NBR',l_tld_tbl(l_ind).config_inst_rev_num);
			  fnd_message.set_token('CONFIG_ITEM_ID',l_tld_tbl(l_ind).config_inst_item_id);
			  fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
          END;
        /* End fix for Bug 3502896 */
        END IF;
      END LOOP;
    END IF;

    px_txn_line_rec       := l_txn_line_rec;
    px_txn_line_dtl_tbl   := l_tld_tbl;
    x_txn_ii_rltns_tbl    := l_filtered_rltns_tbl;
    x_txn_eav_tbl         := l_txn_eav_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_cz_relations;
  --
  --
  --
  PROCEDURE get_instances_for_source(
    p_source_line_rec       IN  source_line_rec,
    x_instance_tbl          OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl      csi_datastructures_pub.instance_header_tbl;
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_instances_for_source');

    l_inst_query_rec.inventory_item_id     := p_source_line_rec.inventory_item_id;
    l_inst_query_rec.last_oe_order_line_id := p_source_line_rec.source_line_id;

    csi_t_gen_utility_pvt.dump_instance_query_rec(
      p_instance_query_rec => l_inst_query_rec);

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
      p_active_instance_only =>  fnd_api.g_true,
      x_instance_header_tbl  =>  l_instance_hdr_tbl,
      x_return_status        =>  l_return_status,
      x_msg_count            =>  l_msg_count,
      x_msg_data             =>  l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call get item instances here
    csi_utl_pkg.make_non_header_tbl(
      p_instance_header_tbl => l_instance_hdr_tbl,
      x_instance_tbl        => x_instance_tbl,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_instances_for_source;


  --
  --
  --
  PROCEDURE get_om_relations(
    p_source_line_rec      IN  source_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_parent_found         boolean := FALSE;
    l_parent_line_rec      source_line_rec;

    l_parent_instance_tbl  csi_datastructures_pub.instance_tbl;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_om_relations');

    -- get the ib trackable parent
    get_ib_trackable_parent(
      p_source_line_rec    => p_source_line_rec,
      x_parent_found       => l_parent_found,
      x_parent_line_rec    => l_parent_line_rec,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_parent_found THEN

      get_instances_for_source(
        p_source_line_rec  => l_parent_line_rec,
        x_instance_tbl     => l_parent_instance_tbl,
        x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_parent_instance_tbl.count > 0 THEN
        null;
        --build_parent_relation
      END IF;

    END IF;

    -- get the ib trackable children
    -- for each of the child check if the om line has come as instances
    -- if yes put them as non source and try building a component-of relation
    -- take the appropriate ratios in consideration

    --if not then do not worry about building relations


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_om_relations;


  /* this routine takes the source line info and the current entered source txn
     line detail info and builds the non source relation based on the source table
     information

       . if it is for the config line then it would read the config txn detail to read
         the relationship and builds them to the corresponding source line detail
         entered in the order line level

       . if it is for the fulfillment/shipment then it reads the parent and child
         information from the order line and builds the parent and the child relation
         for the current order line being processed

   */

  PROCEDURE get_relations(
    p_source_id            IN  number,
    p_source_table         IN  varchar2,
    p_source_header_rec    IN  source_header_rec,
    p_source_line_rec      IN  source_line_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_eav_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_txn_line_dtl_tbl     csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status        varchar2(1);
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_relations');

    -- change to an appropriate condition
    IF p_source_line_rec.config_header_id is not null THEN

      /* this routine gives the txn line details entered by the configurator
         1 source line is mandatory which will have the instance key corresponding to
         the processed order line.
         stamp the source instance key
         may have relations and extended attributes
      */

      get_cz_relations(
        p_source_header_rec    => p_source_header_rec,
        p_source_line_rec      => p_source_line_rec,
        px_txn_line_rec        => px_txn_line_rec,
        px_txn_line_dtl_tbl    => px_txn_line_dtl_tbl,
        x_txn_ii_rltns_tbl     => l_txn_ii_rltns_tbl,
        x_txn_eav_tbl          => x_txn_eav_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE

      get_om_relations(
        p_source_line_rec      => p_source_line_rec,
        px_txn_line_dtl_tbl    => px_txn_line_dtl_tbl,
        x_txn_ii_rltns_tbl     => l_txn_ii_rltns_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    x_txn_ii_rltns_tbl := l_txn_ii_rltns_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_relations;

  PROCEDURE get_extended_attrib_values(
    p_source_id            IN  number,
    p_source_table         IN  varchar2,
    p_source_header_rec    IN  source_header_rec,
    p_source_line_rec      IN  source_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_eav_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_extended_attrib_values');
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_extended_attrib_values;

  PROCEDURE get_order_line_source_info(
    p_order_line_id      IN  number,
    x_source_header_rec  OUT NOCOPY source_header_rec,
    x_source_line_rec    OUT NOCOPY source_line_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_line_rec  oe_order_lines_all%rowtype;
    l_hdr_rec   oe_order_headers_all%rowtype;

    -- For partner prdering
    l_partner_rec             oe_install_base_util.partner_order_rec;
    l_ib_owner                VARCHAR2(60);
    l_end_customer_id         NUMBER;
    l_partner_ib_owner        VARCHAR2(60);

    l_drop_ship_txn_type_id number := 30;


  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_order_line_source_info');

    BEGIN
      SELECT * INTO l_line_rec
      FROM   oe_order_lines_all
      WHERE  line_id = p_order_line_id;

      SELECT * INTO l_hdr_rec
      FROM   oe_order_headers_all
      WHERE  header_id = l_line_rec.header_id;

      -- assign values to the x_source_header_rec
      -- assign values to the x_source_line_rec

    EXCEPTION
      WHEN no_data_found THEN
        -- stack error message
        RAISE fnd_api.g_exc_error;
    END;

    x_source_header_rec.source_header_id       := l_hdr_rec.header_id;
    x_source_header_rec.source_header_ref      := l_hdr_rec.order_number;
    x_source_header_rec.org_id                 := l_hdr_rec.org_id;
    x_source_header_rec.sold_from_org_id       := l_hdr_rec.sold_from_org_id;
    x_source_header_rec.owner_party_account_id := l_hdr_rec.sold_to_org_id;
    x_source_header_rec.sold_to_org_id         := l_hdr_rec.sold_to_org_id;
    x_source_header_rec.agreement_id           := l_hdr_rec.agreement_id;
    x_source_header_rec.ship_to_address_id     := l_hdr_rec.ship_to_org_id;
    x_source_header_rec.bill_to_address_id     := l_hdr_rec.invoice_to_org_id;
    x_source_header_rec.ship_to_contact_id     := l_hdr_rec.ship_to_contact_id;
    x_source_header_rec.bill_to_contact_id     := l_hdr_rec.invoice_to_contact_id;
    x_source_header_rec.cust_po_number         := l_hdr_rec.cust_po_number;
    x_source_header_rec.deliver_to_org_id      := l_hdr_rec.deliver_to_org_id;

    x_source_line_rec.source_line_id         := l_line_rec.line_id;
    x_source_line_rec.source_line_ref        := l_line_rec.line_number||'.'||
                                                l_line_rec.shipment_number||'.'||
                                                l_line_rec.option_number;

    x_source_line_rec.org_id                 := l_line_rec.org_id;
    x_source_line_rec.sold_from_org_id       := nvl(l_line_rec.sold_from_org_id, l_hdr_rec.sold_from_org_id);
    x_source_line_rec.inventory_item_id      := l_line_rec.inventory_item_id;
    x_source_line_rec.organization_id        := nvl(l_line_rec.ship_from_org_id, l_hdr_rec.ship_from_org_id);
    x_source_line_rec.item_revision          := l_line_rec.item_revision;
    x_source_line_rec.uom_code               := l_line_rec.order_quantity_uom;
    x_source_line_rec.source_quantity        := l_line_rec.ordered_quantity;
    x_source_line_rec.shipped_quantity       := l_line_rec.shipped_quantity;
    x_source_line_rec.fulfilled_quantity     := l_line_rec.fulfilled_quantity;
    x_source_line_rec.owner_party_account_id := nvl(l_line_rec.sold_to_org_id, l_hdr_rec.sold_to_org_id);
    x_source_line_rec.ship_to_address_id     := nvl(l_line_rec.ship_to_org_id, l_hdr_rec.ship_to_org_id);
    x_source_line_rec.bill_to_address_id     := nvl(l_line_rec.invoice_to_org_id, l_hdr_rec.invoice_to_org_id);
    x_source_line_rec.deliver_to_org_id      := nvl(l_line_rec.deliver_to_org_id, l_hdr_rec.deliver_to_org_id);
    x_source_line_rec.sold_to_org_id         := nvl(l_line_rec.sold_to_org_id, l_hdr_rec.sold_to_org_id);
    x_source_line_rec.agreement_id           := nvl(l_line_rec.agreement_id, l_hdr_rec.agreement_id);
    x_source_line_rec.ship_to_contact_id     := nvl(l_line_rec.ship_to_contact_id, l_hdr_rec.ship_to_contact_id);
    x_source_line_rec.bill_to_contact_id     := nvl(l_line_rec.invoice_to_contact_id, l_hdr_rec.invoice_to_contact_id);
    x_source_line_rec.link_to_line_id        := l_line_rec.link_to_line_id;
    x_source_line_rec.top_model_line_id      := l_line_rec.top_model_line_id;
    x_source_line_rec.ato_line_id            := l_line_rec.ato_line_id;
    x_source_line_rec.item_type_code         := l_line_rec.item_type_code;
    x_source_line_rec.cust_po_number         := nvl(l_line_rec.cust_po_number, l_hdr_rec.cust_po_number);
    IF l_line_rec.fulfillment_date is not null THEN
      x_source_line_rec.fulfilled_date         := l_line_rec.fulfillment_date;
    ELSE
      -- bug 5256104 - for drop shipments of TSO equipment, shipment happen before the fulfill activity
      -- so fulfillment date remains as null. derive the transaction date of the logical shipment instead
      IF l_line_rec.source_type_code = 'EXTERNAL' THEN
        BEGIN
          SELECT transaction_date
          INTO   x_source_line_rec.fulfilled_date
          FROM   mtl_material_transactions
          WHERE  transaction_type_id = l_drop_ship_txn_type_id
          AND    trx_source_line_id  = l_line_rec.line_id
          AND    rownum              = 1;
        EXCEPTION
          WHEN no_data_found THEN
            x_source_line_rec.fulfilled_date := sysdate;
        END;
      ELSE
        x_source_line_rec.fulfilled_date := sysdate;
      END IF;
    END IF;
    x_source_line_rec.shipped_date           := l_line_rec.actual_shipment_date;

    x_source_line_rec.config_header_id       := l_line_rec.config_header_id;
    x_source_line_rec.config_rev_num         := l_line_rec.config_rev_nbr;
    x_source_line_rec.config_item_id         := l_line_rec.configuration_id;

    -- for partner ordering
    oe_install_base_util.get_partner_ord_rec(
      p_order_line_id      => p_order_line_id,
      x_partner_order_rec  => l_partner_rec);

    IF l_partner_rec.IB_OWNER = 'END_CUSTOMER' THEN
      IF l_partner_rec.END_CUSTOMER_ID is null Then
         fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
         fnd_msg_pub.add;
         raise fnd_api.g_exc_error;
      ELSE
         l_ib_owner                               := l_partner_rec.ib_owner;
         x_source_line_rec.owner_party_account_id := l_partner_rec.end_customer_id;
      END IF;
    ELSIF l_partner_rec.IB_OWNER = 'INSTALL_BASE'
    THEN
         l_ib_owner                               := l_partner_rec.ib_owner;
         x_source_line_rec.owner_party_account_id := fnd_api.g_miss_num;
    ELSE
      x_source_line_rec.owner_party_account_id    := x_source_line_rec.owner_party_account_id;
    END IF;

    IF l_partner_rec.IB_INSTALLED_AT_LOCATION is not null
    THEN
       x_source_line_rec.ib_install_loc   := l_partner_rec.IB_INSTALLED_AT_LOCATION;
       IF x_source_line_rec.ib_install_loc = 'END_CUSTOMER'
       THEN
         IF l_partner_rec.end_customer_site_use_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
            x_source_line_rec.ib_install_loc_id :=  l_partner_rec.end_customer_site_use_id;
         END IF;
       ELSIF x_source_line_rec.ib_install_loc = 'SHIP_TO'
       THEN
         IF x_source_line_rec.ship_to_address_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          x_source_line_rec.ib_install_loc_id := x_source_line_rec.ship_to_address_id;
         END IF;
       ELSIF  x_source_line_rec.ib_install_loc = 'SOLD_TO'
       THEN
         IF l_partner_rec.SOLD_TO_SITE_USE_ID is null -- 3412544 x_source_line_rec.sold_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          x_source_line_rec.ib_install_loc_id := l_partner_rec.SOLD_TO_SITE_USE_ID; -- 3412544 x_source_line_rec.sold_to_org_id;
         END IF;
       ELSIF x_source_line_rec.ib_install_loc = 'DELIVER_TO'
       THEN
          IF  x_source_line_rec.deliver_to_org_id is null
          THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
          ELSE
           x_source_line_rec.ib_install_loc_id := x_source_line_rec.deliver_to_org_id;
          END IF;
       ELSIF x_source_line_rec.ib_install_loc = 'BILL_TO'
       THEN
         IF x_source_line_rec.bill_to_address_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          x_source_line_rec.ib_install_loc_id := x_source_line_rec.bill_to_address_id;
         END IF;
       ELSIF x_source_line_rec.ib_install_loc = 'INSTALL_BASE'
       THEN
             x_source_line_rec.ib_install_loc_id := fnd_api.g_miss_num;
       END IF;
    ELSE
         x_source_line_rec.ib_install_loc_id := x_source_line_rec.ship_to_address_id;
    END IF;

    IF l_partner_rec.IB_CURRENT_LOCATION is not null
    THEN
       x_source_line_rec.ib_current_loc   := l_partner_rec.IB_CURRENT_LOCATION;
       IF x_source_line_rec.ib_current_loc = 'END_CUSTOMER'
       THEN
         IF l_partner_rec.end_customer_site_use_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
            x_source_line_rec.ib_current_loc_id :=  l_partner_rec.end_customer_site_use_id;
         END IF;
       ELSIF x_source_line_rec.ib_current_loc = 'SHIP_TO'
       THEN
         IF x_source_line_rec.ship_to_address_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          x_source_line_rec.ib_current_loc_id := x_source_line_rec.ship_to_address_id;
         END IF;
       ELSIF  x_source_line_rec.ib_current_loc = 'SOLD_TO'
       THEN
         IF l_partner_rec.SOLD_TO_SITE_USE_ID is null -- 3412544 x_source_line_rec.sold_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          x_source_line_rec.ib_current_loc_id := l_partner_rec.SOLD_TO_SITE_USE_ID; -- 3412544 x_source_line_rec.sold_to_org_id;
         END IF;
       ELSIF x_source_line_rec.ib_current_loc = 'DELIVER_TO'
       THEN
          IF  x_source_line_rec.deliver_to_org_id is null
          THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
          ELSE
           x_source_line_rec.ib_current_loc_id := x_source_line_rec.deliver_to_org_id;
          END IF;
       ELSIF x_source_line_rec.ib_current_loc = 'BILL_TO'
       THEN
         IF x_source_line_rec.bill_to_address_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          x_source_line_rec.ib_current_loc_id := x_source_line_rec.bill_to_address_id;
         END IF;
       ELSIF x_source_line_rec.ib_current_loc = 'INSTALL_BASE'
       THEN
             x_source_line_rec.ib_current_loc_id := fnd_api.g_miss_num;
       END IF;
    ELSE
         x_source_line_rec.ib_current_loc_id := x_source_line_rec.ship_to_address_id;
    END IF;

    -- Added the AND condition for Bug 3443175.
    IF x_source_line_rec.owner_party_account_id is not null
      AND
       nvl(l_partner_rec.ib_owner,'!@#') <> 'INSTALL_BASE'
    THEN
      SELECT party_id
      INTO   x_source_line_rec.owner_party_id
      FROM   hz_cust_accounts
      WHERE  cust_account_id = x_source_line_rec.owner_party_account_id;
    END IF;


    -- IF x_source_line_rec.ship_to_address_id is not null THEN
    -- Added the AND condition for Bug 3443175.
    IF x_source_line_rec.ib_current_loc_id is not null
      AND
       nvl(x_source_line_rec.ib_current_loc,'!@#') <> 'INSTALL_BASE'
    THEN
      SELECT hcas.party_site_id
      INTO   x_source_line_rec.ship_to_party_site_id
      FROM   hz_cust_site_uses_all  hcsu,
             hz_cust_acct_sites_all hcas
      WHERE  hcsu.site_use_id       = x_source_line_rec.ib_current_loc_id -- ship_to_address_id
      AND    hcas.cust_acct_site_id = hcsu.cust_acct_site_id;
    END IF;

    -- Added the AND condition for Bug 3443175.
    IF x_source_line_rec.ib_install_loc_id is not null
      AND
       nvl(x_source_line_rec.ib_install_loc,'!@#') <> 'INSTALL_BASE'
    THEN
      SELECT hcas.party_site_id
      INTO   x_source_line_rec.install_to_party_site_id
      FROM   hz_cust_site_uses_all  hcsu,
             hz_cust_acct_sites_all hcas
      WHERE  hcsu.site_use_id       = x_source_line_rec.ib_install_loc_id
      AND    hcas.cust_acct_site_id = hcsu.cust_acct_site_id;
    END IF;

    IF x_source_line_rec.ship_to_contact_id is not null THEN
      SELECT hzr.subject_id
      INTO   x_source_line_rec.ship_to_contact_party_id
      FROM   hz_relationships       hzr,
             hz_cust_account_roles  hzar
      WHERE  hzar.cust_account_role_id  = x_source_line_rec.ship_to_contact_id
      AND    hzr.party_id               = hzar.party_id
      AND    hzr.subject_table_name     = 'HZ_PARTIES'
      AND    hzr.object_table_name      = 'HZ_PARTIES'
      AND    hzr.directional_flag       = 'F';
    END IF;

    IF x_source_line_rec.bill_to_contact_id is not null THEN
      SELECT hzr.subject_id
      INTO   x_source_line_rec.bill_to_contact_party_id
      FROM   hz_relationships       hzr,
             hz_cust_account_roles  hzar
      WHERE  hzar.cust_account_role_id  = x_source_line_rec.bill_to_contact_id
      AND    hzr.party_id               = hzar.party_id
      AND    hzr.subject_table_name     = 'HZ_PARTIES'
      AND    hzr.object_table_name      = 'HZ_PARTIES'
      AND    hzr.directional_flag       = 'F';
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_order_line_source_info;


  PROCEDURE get_wsh_source_info(
    p_source_line_id     IN  number,
    x_source_header_rec  OUT NOCOPY source_header_rec,
    x_source_line_rec    OUT NOCOPY source_line_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS

    CURSOR oke_cur_tmp(p_dlv_id IN number) IS
      SELECT *
      FROM   oke_k_deliverables_vl
      WHERE  deliverable_id = p_dlv_id;

    CURSOR wsh_cur(p_src_line_id IN number) IS
      SELECT source_header_id,
             source_line_id,
             source_line_number,
             org_id,
             organization_id,
             customer_id,
             ship_to_site_use_id,
             ship_to_contact_id,
             cust_po_number,
             inventory_item_id,
             revision,
             src_requested_quantity,
             src_requested_quantity_uom,
             date_scheduled,
             top_model_line_id,
             ato_line_id
      FROM   wsh_delivery_details_ob_grp_v
      WHERE  delivery_detail_id = p_src_line_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_wsh_source_info');

    FOR wsh_rec IN wsh_cur (p_source_line_id)
    LOOP

      IF wsh_cur%rowcount = 1 THEN

        mo_global.set_policy_context('S', wsh_rec.org_id);

        x_source_header_rec.source_header_id       := wsh_rec.source_header_id;

        SELECT contract_number
        INTO   x_source_header_rec.source_header_ref
        FROM   okc_k_headers_all_b  --fix for bug5358612
        WHERE  id = wsh_rec.source_header_id;

        x_source_header_rec.owner_party_account_id := wsh_rec.customer_id;
      END IF;

      -- assign line_rec
      x_source_line_rec.source_line_id         := wsh_rec.source_line_id;
      x_source_line_rec.source_line_ref        := wsh_rec.source_line_number;
      x_source_line_rec.org_id                 := wsh_rec.org_id;
      x_source_line_rec.sold_from_org_id       := wsh_rec.org_id;
      x_source_line_rec.ship_to_address_id     := wsh_rec.ship_to_site_use_id;
      x_source_line_rec.ship_to_contact_id     := wsh_rec.ship_to_contact_id;
      x_source_line_rec.cust_po_number         := wsh_rec.cust_po_number;
      x_source_line_rec.inventory_item_id      := wsh_rec.inventory_item_id;
      x_source_line_rec.organization_id        := wsh_rec.organization_id;
      x_source_line_rec.item_revision          := wsh_rec.revision;
      x_source_line_rec.source_quantity        := wsh_rec.src_requested_quantity;
      x_source_line_rec.uom_code               := wsh_rec.src_requested_quantity_uom;
      x_source_line_rec.owner_party_account_id := wsh_rec.customer_id;
      x_source_line_rec.shipped_date           := wsh_rec.date_scheduled;

      IF x_source_line_rec.owner_party_account_id is not null THEN
        SELECT party_id
        INTO   x_source_line_rec.owner_party_id
        FROM   hz_cust_accounts
        WHERE  cust_account_id = x_source_line_rec.owner_party_account_id;
      END IF;


      IF x_source_line_rec.ship_to_address_id is not null THEN
        SELECT hcas.party_site_id
        INTO   x_source_line_rec.ship_to_party_site_id
        FROM   hz_cust_site_uses_all  hcsu,
               hz_cust_acct_sites_all hcas
        WHERE  hcsu.site_use_id       = x_source_line_rec.ship_to_address_id
        AND    hcas.cust_acct_site_id = hcsu.cust_acct_site_id;
      END IF;

      IF x_source_line_rec.ship_to_contact_id is not null THEN
        SELECT hzr.subject_id
        INTO   x_source_line_rec.ship_to_contact_party_id
        FROM   hz_relationships       hzr,
               hz_cust_account_roles  hzar
        WHERE  hzar.cust_account_role_id  = x_source_line_rec.ship_to_contact_id
        AND    hzr.party_id               = hzar.party_id
        AND    hzr.subject_table_name     = 'HZ_PARTIES'
        AND    hzr.object_table_name      = 'HZ_PARTIES'
        AND    hzr.directional_flag       = 'F';
      END IF;

    END LOOP;

    debug('  contract_number       : '||x_source_header_rec.source_header_ref);
    debug('  contract_header_id    : '||x_source_header_rec.source_header_id);
    debug('  source_line_number    : '||x_source_line_rec.source_line_ref);
    debug('  source_line_id        : '||x_source_line_rec.source_line_id);
    debug('  owner_account_id      : '||x_source_line_rec.owner_party_account_id);
    debug('  owner_party_id        : '||x_source_line_rec.owner_party_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_wsh_source_info;

  --
  --
  --
  PROCEDURE get_source_info(
    p_source_table         IN  varchar2,
    p_source_id            IN  number,
    x_source_header_rec    OUT NOCOPY source_header_rec,
    x_source_line_rec      OUT NOCOPY source_line_rec,
    x_return_status        OUT NOCOPY varchar)
  IS

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_source_header_rec    source_header_rec;
    l_source_line_rec      source_line_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_source_info');

    IF p_source_table = g_om_source_table THEN

      get_order_line_source_info(
        p_order_line_id      => p_source_id,
        x_source_header_rec  => l_source_header_rec,
        x_source_line_rec    => l_source_line_rec,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_source_line_rec.source_table := g_om_source_table;

    ELSIF p_source_table = g_oke_source_table THEN -- project contracts

      get_wsh_source_info(
        p_source_line_id     => p_source_id,
        x_source_header_rec  => l_source_header_rec,
        x_source_line_rec    => l_source_line_rec,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_source_line_rec.source_table := g_oke_source_table;

    END IF;

    x_source_header_rec := l_source_header_rec;
    x_source_line_rec   := l_source_line_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_source_info;

  /* This routine derives the location information for a NETWORK_LINK */
  /* A partner is identified from the connected to relationship info  */
  /* and derive the location from the partner. Assuming that a network*/
  /* link is not connected to a network link                          */

  PROCEDURE get_network_link_location(
    p_instance_key         IN  csi_utility_grp.config_instance_key,
    x_location_type_code   OUT NOCOPY varchar2,
    x_location_id          OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2)
  IS
    cursor partner_cur IS
      SELECT obj_config_inst_hdr_id  inst_hdr_id,
             obj_config_inst_item_id inst_item_id,
             obj_config_inst_rev_num inst_rev_num
      FROM   csi_t_ii_relationships
      WHERE  sub_config_inst_hdr_id  = p_instance_key.inst_hdr_id
      AND    sub_config_inst_item_id = p_instance_key.inst_item_id
      AND    sub_config_inst_rev_num = p_instance_key.inst_rev_num
      UNION
      SELECT sub_config_inst_hdr_id  inst_hdr_id,
             sub_config_inst_item_id inst_item_id,
             sub_config_inst_rev_num inst_rev_num
      FROM   csi_t_ii_relationships
      WHERE  obj_config_inst_hdr_id  = p_instance_key.inst_hdr_id
      AND    obj_config_inst_item_id = p_instance_key.inst_item_id
      AND    obj_config_inst_rev_num = p_instance_key.inst_rev_num;

    l_partner_location_found boolean := FALSE;
    l_location_id            number  := null;
    l_location_type_code     varchar2(30);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_network_link_location');

    FOR partner_rec IN partner_cur
    LOOP
      BEGIN

        SELECT location_id,
               location_type_code
        INTO   l_location_id,
               l_location_type_code
        FROM   csi_t_txn_line_details
        WHERE  config_inst_hdr_id  = partner_rec.inst_hdr_id
        AND    config_inst_item_id = partner_rec.inst_item_id
        AND    config_inst_rev_num = partner_rec.inst_rev_num;

        l_partner_location_found := TRUE;
        exit;
      EXCEPTION
        WHEN no_data_found THEN

          BEGIN

            SELECT location_id ,
                   location_type_code
            INTO   l_location_id,
                   l_location_type_code
            FROM   csi_item_instances
            WHERE  config_inst_hdr_id  = partner_rec.inst_hdr_id
            AND    config_inst_item_id = partner_rec.inst_item_id;

            l_partner_location_found := TRUE;
            exit;

          EXCEPTION
            WHEN no_data_found THEN
              l_partner_location_found := FALSE;
          END;
      END;
    END LOOP;

    IF NOT(l_partner_location_found) THEN
      fnd_message.set_name('CSI', 'CSI_NETWORK_PARTNER_NOT_FOUND');
      fnd_message.set_token('INST_HDR_ID', p_instance_key.inst_hdr_id);
      fnd_message.set_token('INST_ITEM_ID', p_instance_key.inst_item_id);
      fnd_message.set_token('INST_REV_NUM', p_instance_key.inst_rev_num);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  location_type_code :'||l_location_type_code);
    debug('  location_id        :'||l_location_id);

    x_location_type_code := l_location_type_code;
    x_location_id        := l_location_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_network_link_location;


  --
  -- based on the pl/sql index only
  --
  PROCEDURE build_instance_set(
    p_index                IN     binary_integer,
    p_source_line_rec      IN     csi_interface_pkg.source_line_rec,
    p_item_attrib_rec      IN     item_attributes_rec,
    p_txn_line_dtl_rec     IN     csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_party_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_party_acct_tbl   IN     csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_txn_org_assgn_tbl    IN     csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_txn_eav_tbl          IN     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_pricing_tbl         IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_instance_rec            OUT NOCOPY csi_datastructures_pub.instance_rec,
    x_party_tbl               OUT NOCOPY csi_datastructures_pub.party_tbl,
    x_party_acct_tbl          OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_eav_tbl                 OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_org_units_tbl           OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_i_rec            csi_datastructures_pub.instance_rec;
    l_p_tbl            csi_datastructures_pub.party_tbl;
    l_pa_tbl           csi_datastructures_pub.party_account_tbl;
    l_eav_tbl          csi_datastructures_pub.extend_attrib_values_tbl;
    l_ou_tbl           csi_datastructures_pub.organization_units_tbl;

    l_instance_key     csi_utility_grp.config_instance_key;

    p_ind              binary_integer := 0;
    pa_ind             binary_integer := 0;
    eav_ind            binary_integer := 0;
    ou_ind             binary_integer := 0;

    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;

    -- Added as part of fix for Bug 2960049
    l_instance_usage_code  varchar2(30);

  BEGIN
    api_log('build_instance_set');

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_index is not null THEN

      -- Added the nvl, fnd_api g_miss values to the p_txn_line_dtl_rec for Bug 3783088
      l_i_rec.instance_id             := p_txn_line_dtl_rec.instance_id;
      l_i_rec.instance_number         := fnd_api.g_miss_char;
      l_i_rec.external_reference      := nvl(p_txn_line_dtl_rec.external_reference,fnd_api.g_miss_char);
      l_i_rec.inventory_item_id       := p_txn_line_dtl_rec.inventory_item_id;
      l_i_rec.inventory_revision      := nvl(p_txn_line_dtl_rec.inventory_revision,fnd_api.g_miss_char);
      l_i_rec.vld_organization_id     := fnd_api.g_miss_num;  -- Bug 8811152-Inv org ID passed by Configurator is Master org ID
      l_i_rec.inv_master_organization_id := p_txn_line_dtl_rec.inv_organization_id; -- Bug 8811152-Inv org ID passed by Configurator is Master org ID
      l_i_rec.serial_number           := p_txn_line_dtl_rec.serial_number;
      l_i_rec.mfg_serial_number_flag  := nvl(p_txn_line_dtl_rec.mfg_serial_number_flag,fnd_api.g_miss_char);
      l_i_rec.lot_number              := nvl(p_txn_line_dtl_rec.lot_number,fnd_api.g_miss_char);
      l_i_rec.quantity                := p_txn_line_dtl_rec.quantity;
      l_i_rec.unit_of_measure         := p_txn_line_dtl_rec.unit_of_measure;
      l_i_rec.accounting_class_code   := 'CUST_PROD';
      l_i_rec.instance_condition_id   := nvl(p_txn_line_dtl_rec.item_condition_id,fnd_api.g_miss_num);
      l_i_rec.customer_view_flag      := 'Y';
      l_i_rec.merchant_view_flag      := 'Y';
      l_i_rec.sellable_flag           := nvl(p_txn_line_dtl_rec.sellable_flag,fnd_api.g_miss_char);
      l_i_rec.system_id               := nvl(p_txn_line_dtl_rec.csi_system_id,fnd_api.g_miss_num);
      l_i_rec.instance_type_code      := nvl(p_txn_line_dtl_rec.instance_type_code,fnd_api.g_miss_char);
      l_i_rec.active_start_date       := nvl(p_txn_line_dtl_rec.active_start_date,fnd_api.g_miss_date);
      l_i_rec.active_end_date         := nvl(p_txn_line_dtl_rec.active_end_date,fnd_api.g_miss_date);
	  --Start - added for bug 8586745  FP for 8490723
      IF(l_i_rec.active_start_date=fnd_api.g_miss_date AND l_i_rec.active_end_date<>fnd_api.g_miss_date) THEN
          IF(to_date(l_i_rec.active_end_date,'DD-MM-YY HH24:MI')<to_date(SYSDATE,'DD-MM-YY HH24:MI'))then
            l_i_rec.active_end_date:=SYSDATE;
          END IF;
      l_i_rec.active_start_date :=l_i_rec.active_end_date;
      end IF;
      --End - added for bug 8586745  FP for 8490723
      l_i_rec.location_type_code      := nvl(p_txn_line_dtl_rec.location_type_code,fnd_api.g_miss_char);
      l_i_rec.location_id             := nvl(p_txn_line_dtl_rec.location_id,fnd_api.g_miss_num);
      -- Added for partner ordering
      l_i_rec.install_location_type_code      := nvl(p_txn_line_dtl_rec.install_location_type_code,fnd_api.g_miss_char);
      l_i_rec.install_location_id             := nvl(p_txn_line_dtl_rec.install_location_id,fnd_api.g_miss_num);

      IF p_source_line_rec.source_table = g_om_source_table THEN
        l_i_rec.last_oe_order_line_id   := p_source_line_rec.source_line_id;
      ELSIF p_source_line_rec.source_table = 'CONFIGURATOR' THEN
        IF p_source_line_rec.batch_validate_flag = 'N' THEN
          l_i_rec.call_batch_validation := fnd_api.g_false;
        END IF;

      END IF;

      l_i_rec.last_txn_line_detail_id := p_txn_line_dtl_rec.txn_line_detail_id;
      l_i_rec.install_date            := nvl(p_txn_line_dtl_rec.active_start_date,fnd_api.g_miss_date);
      l_i_rec.manually_created_flag   := 'N';
      l_i_rec.return_by_date          := nvl(p_txn_line_dtl_rec.return_by_date,fnd_api.g_miss_date);
      l_i_rec.creation_complete_flag  := fnd_api.g_miss_char;
      l_i_rec.completeness_flag       := fnd_api.g_miss_char;
      l_i_rec.instance_usage_code     := 'OUT_OF_ENTERPRISE';

      -- Begin Fix for Bug 2960049
      IF nvl(l_i_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        BEGIN
          SELECT instance_usage_code
          INTO   l_instance_usage_code
          FROM   csi_item_instances
          WHERE  instance_id = l_i_rec.instance_id;

        EXCEPTION
          WHEN no_data_found THEN
            l_i_rec.instance_id    := fnd_api.g_miss_num;
        END;
        IF  l_instance_usage_code = 'IN_RELATIONSHIP' THEN
          l_i_rec.instance_usage_code  := l_instance_usage_code;
        END IF;
      END IF;
      -- End Fix for Bug 2960049

      l_i_rec.last_oe_agreement_id    := p_source_line_rec.agreement_id;
      l_i_rec.config_inst_hdr_id      := p_txn_line_dtl_rec.config_inst_hdr_id;
      l_i_rec.config_inst_rev_num     := p_txn_line_dtl_rec.config_inst_rev_num;
      l_i_rec.config_inst_item_id     := p_txn_line_dtl_rec.config_inst_item_id;
      l_i_rec.instance_description    := nvl(p_txn_line_dtl_rec.instance_description,fnd_api.g_miss_char);
      l_i_rec.last_txn_line_detail_id := p_txn_line_dtl_rec.source_txn_line_detail_id;

      IF p_item_attrib_rec.ib_item_instance_class = 'LINK' THEN

        l_i_rec.install_location_type_code := null;
        l_i_rec.install_location_id        := null;

        l_instance_key.inst_hdr_id  := l_i_rec.config_inst_hdr_id;
        l_instance_key.inst_item_id := l_i_rec.config_inst_item_id;
        l_instance_key.inst_rev_num := l_i_rec.config_inst_rev_num;

        get_network_link_location(
          p_instance_key         => l_instance_key,
          x_location_type_code   => l_i_rec.location_type_code,
          x_location_id          => l_i_rec.location_id,
          x_return_status        => l_return_status);

-- Bug 9023449 if the instance is in relationship then Location change is not allowed
         IF nvl(l_i_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
		AND NVL(l_i_rec.instance_usage_code, fnd_api.g_miss_char) = 'IN_RELATIONSHIP' THEN
           debug('instance_usage_code - ' || l_i_rec.instance_usage_code);
           l_i_rec.install_location_type_code := nvl(l_i_rec.install_location_type_code,fnd_api.g_miss_char);
           l_i_rec.install_location_id        := nvl(l_i_rec.install_location_id,fnd_api.g_miss_num);
           l_i_rec.location_type_code         := nvl(l_i_rec.location_type_code,fnd_api.g_miss_char);
           l_i_rec.location_id                := nvl(l_i_rec.location_id,fnd_api.g_miss_num);
        END IF;

      ELSE
        l_i_rec.install_location_type_code := nvl(p_txn_line_dtl_rec.location_type_code,fnd_api.g_miss_char);
        l_i_rec.install_location_id        := nvl(p_txn_line_dtl_rec.location_id,fnd_api.g_miss_num);
      END IF;

      -- contact switch parse
      IF p_txn_party_tbl.COUNT > 0 THEN
        FOR l_p_ind IN p_txn_party_tbl.FIRST .. p_txn_party_tbl.LAST
        LOOP
          IF p_txn_party_tbl(l_p_ind).txn_line_details_index = p_index THEN

            p_ind := p_ind + 1;

            /*
            if there is a party contact with l_p_ind as the contact_oparty id then
            switch that with p_ind
            */
            FOR l_pc_ind IN p_txn_party_tbl.FIRST .. p_txn_party_tbl.LAST
            LOOP
              IF p_txn_party_tbl(l_pc_ind).contact_flag = 'Y'
                   AND
                 p_txn_party_tbl(l_pc_ind).contact_party_id = l_p_ind
              THEN
                --p_txn_party_tbl(l_pc_ind).contact_party_id := p_ind;
                -- commented the above statement and added the below IF for bug 4945025
                IF nvl(l_i_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num Then
                  BEGIN
                    SELECT instance_party_id
                    INTO   p_txn_party_tbl(l_pc_ind).contact_party_id
                    FROM   csi_i_parties
                    WHERE  instance_id = l_i_rec.instance_id
                    AND    relationship_type_code = p_txn_party_tbl(l_p_ind).relationship_type_code
                    AND   ((active_end_date is null ) OR
                           (active_end_date > sysdate));
                  EXCEPTION
                    WHEN no_data_found THEN
                      fnd_message.set_name('CSI','CSI_INT_INV_INSTA_PTY_ID');
                      fnd_message.set_token('INSTANCE_ID',l_i_rec.instance_id);
                      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_txn_party_tbl(l_p_ind).relationship_type_code);
                      fnd_msg_pub.add;
                      IF p_txn_party_tbl(l_p_ind).relationship_type_code = 'OWNER' THEN
                         x_return_status := fnd_api.g_ret_sts_error;
                         raise fnd_api.g_exc_error;
                      ELSE
                        p_txn_party_tbl(l_pc_ind).contact_party_id := p_ind;
                        debug('relationship_type_code :'||p_txn_party_tbl(l_p_ind).relationship_type_code);
                      END IF;
                    WHEN too_many_rows THEN
                      fnd_message.set_name('CSI','CSI_INT_MANY_INSTA_PTY_FOUND');
                      fnd_message.set_token('INSTANCE_ID',l_i_rec.instance_id);
                      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_txn_party_tbl(l_p_ind).relationship_type_code);
                      fnd_msg_pub.add;
                      x_return_status := fnd_api.g_ret_sts_error;
                      raise fnd_api.g_exc_error;
                  END;
                ELSE
                  p_txn_party_tbl(l_pc_ind).contact_party_id := p_ind;
                END IF;
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END IF;

      p_ind := 0;

      IF p_txn_party_tbl.COUNT > 0 THEN
        FOR l_p_ind IN p_txn_party_tbl.FIRST .. p_txn_party_tbl.LAST
        LOOP
          IF p_txn_party_tbl(l_p_ind).txn_line_details_index = p_index THEN

            p_ind := p_ind + 1;

            l_p_tbl(p_ind).instance_party_id := p_txn_party_tbl(l_p_ind).instance_party_id;
            l_p_tbl(p_ind).instance_id       := l_i_rec.instance_id;
            l_p_tbl(p_ind).party_id          := p_txn_party_tbl(l_p_ind).party_source_id;
            l_p_tbl(p_ind).party_source_table := p_txn_party_tbl(l_p_ind).party_source_table;
            l_p_tbl(p_ind).relationship_type_code:= p_txn_party_tbl(l_p_ind).relationship_type_code;
            l_p_tbl(p_ind).contact_flag      := p_txn_party_tbl(l_p_ind).contact_flag;

            IF p_txn_party_tbl(l_p_ind).contact_flag = 'Y' THEN
               --l_p_tbl(p_ind).contact_parent_tbl_index := p_txn_party_tbl(l_p_ind).contact_party_id;
               -- commented the above statement and added the below statement for bug 4945025
               l_p_tbl(p_ind).contact_ip_id := p_txn_party_tbl(l_p_ind).contact_party_id;
            END IF;
            --l_p_tbl(p_ind).contact_ip_id     := p_txn_party_tbl(l_p_ind).contact_ip_id;
            l_p_tbl(p_ind).active_end_date   := p_txn_party_tbl(l_p_ind).active_start_date;

            /*
            l_p_tbl(p_ind).context           :=
            l_p_tbl(p_ind).attribute1        :=
            l_p_tbl(p_ind).attribute2        :=
            l_p_tbl(p_ind).attribute3        :=
            l_p_tbl(p_ind).attribute4        :=
            l_p_tbl(p_ind).attribute5        :=
            l_p_tbl(p_ind).attribute6        :=
            l_p_tbl(p_ind).attribute7        :=
            l_p_tbl(p_ind).attribute8        :=
            l_p_tbl(p_ind).attribute9        :=
            l_p_tbl(p_ind).attribute10       :=
            l_p_tbl(p_ind).attribute11       :=
            l_p_tbl(p_ind).attribute12       :=
            l_p_tbl(p_ind).attribute13       :=
            l_p_tbl(p_ind).attribute14       :=
            l_p_tbl(p_ind).attribute15       :=
            */

            IF p_txn_party_acct_tbl.COUNT > 0 THEN
              FOR l_pa_ind IN p_txn_party_acct_tbl.FIRST .. p_txn_party_acct_tbl.LAST
              LOOP
                IF p_txn_party_acct_tbl(l_pa_ind).txn_party_details_index = l_p_ind THEN

                  pa_ind := pa_ind + 1;

                  l_pa_tbl(pa_ind).parent_tbl_index := p_ind;
                  l_pa_tbl(pa_ind).ip_account_id    := p_txn_party_acct_tbl(l_pa_ind).ip_account_id;
                  l_pa_tbl(pa_ind).party_account_id := p_txn_party_acct_tbl(l_pa_ind).account_id;
                  l_pa_tbl(pa_ind).relationship_type_code := p_txn_party_acct_tbl(l_pa_ind).relationship_type_code;
                  l_pa_tbl(pa_ind).bill_to_address := p_txn_party_acct_tbl(l_pa_ind).bill_to_address_id;
                  l_pa_tbl(pa_ind).ship_to_address := p_txn_party_acct_tbl(l_pa_ind).ship_to_address_id;
                  l_pa_tbl(pa_ind).instance_party_id := l_p_tbl(p_ind).instance_party_id;
                  l_pa_tbl(pa_ind).active_start_date := p_txn_party_acct_tbl(l_pa_ind).active_start_date;
                  /*
                  l_pa_tbl(pa_ind).active_end_date :=
                  l_pa_tbl(pa_ind).context    :=
                  l_pa_tbl(pa_ind).attribute1 :=
                  l_pa_tbl(pa_ind).attribute2 :=
                  l_pa_tbl(pa_ind).attribute3 :=
                  l_pa_tbl(pa_ind).attribute4 :=
                  l_pa_tbl(pa_ind).attribute5 :=
                  l_pa_tbl(pa_ind).attribute6 :=
                  l_pa_tbl(pa_ind).attribute7 :=
                  l_pa_tbl(pa_ind).attribute8 :=
                  l_pa_tbl(pa_ind).attribute9 :=
                  l_pa_tbl(pa_ind).attribute10 :=
                  l_pa_tbl(pa_ind).attribute11 :=
                  l_pa_tbl(pa_ind).attribute12 :=
                  l_pa_tbl(pa_ind).attribute13 :=
                  l_pa_tbl(pa_ind).attribute14 :=
                  l_pa_tbl(pa_ind).attribute15 :=
                  l_pa_tbl(pa_ind).object_version_number :=
                  */
                END IF;
              END LOOP; -- party account loop
            END IF; -- patry account count > 0
          END IF;
        END LOOP; -- party loop
      END IF; -- party table count > 0

      -- org assignments
      IF p_txn_org_assgn_tbl.COUNT > 0 THEN
        FOR l_oa_ind IN p_txn_org_assgn_tbl.FIRST .. p_txn_org_assgn_tbl.LAST
        LOOP
          IF p_txn_org_assgn_tbl(l_oa_ind).txn_line_details_index = p_index THEN

            ou_ind := ou_ind + 1;

            l_ou_tbl(ou_ind).instance_ou_id    := p_txn_org_assgn_tbl(l_oa_ind).instance_ou_id;
            l_ou_tbl(ou_ind).operating_unit_id := p_txn_org_assgn_tbl(l_oa_ind).operating_unit_id;
            l_ou_tbl(ou_ind).instance_id       := l_i_rec.instance_id;
            l_ou_tbl(ou_ind).relationship_type_code :=  p_txn_org_assgn_tbl(l_oa_ind).relationship_type_code;
            l_ou_tbl(ou_ind).active_start_date := p_txn_org_assgn_tbl(l_oa_ind).active_start_date;
            l_ou_tbl(ou_ind).active_end_date   := p_txn_org_assgn_tbl(l_oa_ind).active_end_date;
            l_ou_tbl(ou_ind).object_version_number := 1.0;
            /*
            l_ou_tbl(ou_ind).context          :=
            l_ou_tbl(ou_ind).attribute1       :=
            l_ou_tbl(ou_ind).attribute2       :=
            l_ou_tbl(ou_ind).attribute3       :=
            l_ou_tbl(ou_ind).attribute4       :=
            l_ou_tbl(ou_ind).attribute5       :=
            l_ou_tbl(ou_ind).attribute6       :=
            l_ou_tbl(ou_ind).attribute7       :=
            l_ou_tbl(ou_ind).attribute8       :=
            l_ou_tbl(ou_ind).attribute9       :=
            l_ou_tbl(ou_ind).attribute10      :=
            l_ou_tbl(ou_ind).attribute11      :=
            l_ou_tbl(ou_ind).attribute12      :=
            l_ou_tbl(ou_ind).attribute13      :=
            l_ou_tbl(ou_ind).attribute14      :=
            l_ou_tbl(ou_ind).attribute15      :=
            */

          END IF;
        END LOOP; -- org assignments loop
      END IF; -- org assignments count > 0

      -- extended attribs
      IF p_txn_eav_tbl.COUNT > 0 THEN
        FOR l_eav_ind IN p_txn_eav_tbl.FIRST .. p_txn_eav_tbl.LAST
        LOOP
          IF p_txn_eav_tbl(l_eav_ind).txn_line_details_index = p_index THEN

            -- csi_t_gen_utility_Pvt.dump_txn_eav_rec(p_txn_eav_tbl(l_eav_ind));

            eav_ind := eav_ind + 1;

            l_eav_tbl(eav_ind).instance_id      := l_i_rec.instance_id;
            l_eav_tbl(eav_ind).attribute_value  := p_txn_eav_tbl(l_eav_ind).attribute_value;

            IF p_txn_eav_tbl(l_eav_ind).attrib_source_table = 'CSI_IEA_VALUES' THEN
              l_eav_tbl(eav_ind).attribute_value_id := p_txn_eav_tbl(l_eav_ind).attribute_source_id;
            ELSIF p_txn_eav_tbl(l_eav_ind).attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS' THEN
              l_eav_tbl(eav_ind).attribute_id   := p_txn_eav_tbl(l_eav_ind).attribute_source_id;
              IF l_i_rec.instance_id = fnd_api.g_miss_num THEN
                l_eav_tbl(eav_ind).attribute_value_id := fnd_api.g_miss_num;
              ELSE
                BEGIN
                  SELECT attribute_value_id
                  INTO   l_eav_tbl(eav_ind).attribute_value_id
                  FROM   csi_iea_values
                  WHERE  attribute_id = p_txn_eav_tbl(l_eav_ind).attribute_source_id
                  AND    instance_id  = l_i_rec.instance_id;
                EXCEPTION
                  WHEN no_data_found THEN
                    l_eav_tbl(eav_ind).attribute_value_id := fnd_api.g_miss_num;
                END;
              END IF;
            END IF;

            --l_eav_tbl(eav_ind).active_start_date := p_txn_eav_tbl(l_eav_ind).active_start_date;
            --l_eav_tbl(eav_ind).active_end_date  := p_txn_eav_tbl(l_eav_ind).active_end_date;
            l_eav_tbl(eav_ind).object_version_number  := 1.0;
            /*
            l_eav_tbl(eav_ind).context          :=
            l_eav_tbl(eav_ind).attribute1       :=
            l_eav_tbl(eav_ind).attribute2       :=
            l_eav_tbl(eav_ind).attribute3       :=
            l_eav_tbl(eav_ind).attribute4       :=
            l_eav_tbl(eav_ind).attribute5       :=
            l_eav_tbl(eav_ind).attribute6       :=
            l_eav_tbl(eav_ind).attribute7       :=
            l_eav_tbl(eav_ind).attribute8       :=
            l_eav_tbl(eav_ind).attribute9       :=
            l_eav_tbl(eav_ind).attribute10      :=
            l_eav_tbl(eav_ind).attribute11      :=
            l_eav_tbl(eav_ind).attribute12      :=
            l_eav_tbl(eav_ind).attribute13      :=
            l_eav_tbl(eav_ind).attribute14      :=
            l_eav_tbl(eav_ind).attribute15      :=
            */
          END IF;
        END LOOP; -- extended attribs loop
      END IF; -- extended attribs count > 0

      -- pricing attribs
      IF px_pricing_tbl.COUNT > 0 THEN
        FOR l_pr_ind IN px_pricing_tbl.FIRST .. px_pricing_tbl.LAST
        LOOP
           IF px_pricing_tbl(l_pr_ind).parent_tbl_index = p_index
              AND px_pricing_tbl(l_pr_ind).instance_id = fnd_api.g_miss_num
            THEN
               px_pricing_tbl(l_pr_ind).instance_id := l_i_rec.instance_id; -- bug 5093707
           END IF;
        END LOOP; -- pricing attribs loop
      END IF; -- pricing attribs count > 0

      x_instance_rec    := l_i_rec;
      x_party_tbl       := l_p_tbl;
      x_party_acct_tbl  := l_pa_tbl;
      x_org_units_tbl   := l_ou_tbl;
      x_eav_tbl         := l_eav_tbl;

    END IF; -- p_index is not null

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_instance_set;

  PROCEDURE sub_type_specific_vldns(
    p_source_flag          IN     varchar2,
    p_sub_type_rec         IN     csi_txn_sub_types%rowtype,
    p_instance_rec         IN     csi_datastructures_pub.instance_rec,
    p_party_tbl            IN     csi_datastructures_pub.party_tbl,
    p_party_acct_tbl       IN     csi_datastructures_pub.party_account_tbl,
    p_org_units_tbl        IN     csi_datastructures_pub.organization_units_tbl,
    p_eav_tbl              IN     csi_datastructures_pub.extend_attrib_values_tbl,
    p_pricing_tbl          IN     csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_csi_param_rec        csi_install_parameters%rowtype;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('sub_type_specific_vldns');
/* commenting this for bug 4028827 . since we do not seem to have any usage currently for this Query
    SELECT * INTO l_csi_param_rec
    FROM   csi_install_parameters;
*/
    debug('Instance Status ID :'||p_instance_rec.instance_status_id);

    -- check if an owner/account is passed if src_change_owner = 'E'
    --   and make sure that the owner party id is not the internal party
    -- if owner change is not set then clear the owner party passed.
    -- check for multiple owner error
    -- for non source check if an instance ref is specified

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END sub_type_specific_vldns;


  --
  --
  --
  PROCEDURE validate_and_derive_ids(
    px_instance_rec        IN OUT NOCOPY csi_datastructures_pub.instance_rec,
    px_party_tbl           IN OUT NOCOPY csi_datastructures_pub.party_tbl,
    px_party_acct_tbl      IN OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    px_org_units_tbl       IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    px_eav_tbl             IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    px_pricing_tbl         IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_active_end_date      date;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('validate_and_derive_ids');

    -- srramakr TSO with equipment. During DISCONNECT of Tangible item instance, we need to remove the config keys.
    -- In order to identify whether the item is tangible or not, we use the serial number of the item instance.
    -- Only tangible items can be shipped and possess a serial number. Non-tangible can only be fulfilled where
    -- there will not be any serial number.
    --
    SELECT object_version_number,
           serial_number ,
           active_end_date
    INTO   px_instance_rec.object_version_number,
           px_instance_rec.serial_number,
           l_active_end_date
    FROM   csi_item_instances
    WHERE  instance_id = px_instance_rec.instance_id;

    px_instance_rec.active_start_date := fnd_api.g_miss_date;

    -- 4946227 okeship of srlsoi returned for good fails
    IF nvl(l_active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date THEN
      IF px_instance_rec.active_end_date = fnd_api.g_miss_date THEN
        px_instance_rec.active_end_date := null;
      END IF;
    END IF;

    IF px_party_tbl.COUNT > 0 THEN
      FOR l_p_ind IN px_party_tbl.FIRST .. px_party_tbl.LAST
      LOOP

        px_party_tbl(l_p_ind).instance_id       := px_instance_rec.instance_id;
        px_party_tbl(l_p_ind).active_start_date := fnd_api.g_miss_date;

        IF nvl(px_party_tbl(l_p_ind).instance_party_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          BEGIN
            SELECT instance_party_id,
                   object_version_number
            INTO   px_party_tbl(l_p_ind).instance_party_id,
                   px_party_tbl(l_p_ind).object_version_number
            FROM   csi_i_parties
            WHERE  instance_id = px_instance_rec.instance_id
            AND    party_source_table = px_party_tbl(l_p_ind).party_source_table
            AND    relationship_type_code = px_party_tbl(l_p_ind).relationship_type_code;
          EXCEPTION
            WHEN no_data_found THEN
              px_party_tbl(l_p_ind).instance_party_id := fnd_api.g_miss_num;
              px_party_tbl(l_p_ind).object_version_number := 1.0;
            WHEN too_many_rows THEN
              BEGIN
                SELECT instance_party_id,
                       object_version_number
                INTO   px_party_tbl(l_p_ind).instance_party_id,
                       px_party_tbl(l_p_ind).object_version_number
                FROM   csi_i_parties
                WHERE  instance_id = px_instance_rec.instance_id
                AND    party_id = px_party_tbl(l_p_ind).party_id
                AND    party_source_table = px_party_tbl(l_p_ind).party_source_table
                AND    relationship_type_code = px_party_tbl(l_p_ind).relationship_type_code;
              EXCEPTION
                WHEN no_data_found THEN
                  px_party_tbl(l_p_ind).instance_party_id := fnd_api.g_miss_num;
                  px_party_tbl(l_p_ind).object_version_number := 1.0;
              END;
          END;

          -- party account
          IF px_party_acct_tbl.count > 0 THEN
            FOR l_pa_ind IN px_party_acct_tbl.FIRST .. px_party_acct_tbl.LAST
            LOOP
              IF px_party_acct_tbl(l_pa_ind).parent_tbl_index = l_p_ind THEN
                px_party_acct_tbl(l_pa_ind).instance_party_id := px_party_tbl(l_p_ind).instance_party_id;
                px_party_acct_tbl(l_pa_ind).active_start_date := fnd_api.g_miss_date;

                IF nvl(px_party_acct_tbl(l_pa_ind).ip_account_id , fnd_api.g_miss_num) = fnd_api.g_miss_num
                THEN
                  BEGIN

                    SELECT ip_account_id,
                           object_version_number
                    INTO   px_party_acct_tbl(l_pa_ind).ip_account_id,
                           px_party_acct_tbl(l_pa_ind).object_version_number
                    FROM   csi_ip_accounts
                    WHERE  instance_party_id      = px_party_acct_tbl(l_pa_ind).instance_party_id
                    AND    relationship_type_code = px_party_acct_tbl(l_pa_ind).relationship_type_code;

                  EXCEPTION
                    WHEN no_data_found THEN
                      px_party_acct_tbl(l_pa_ind).ip_account_id := fnd_api.g_miss_num;
                      px_party_acct_tbl(l_pa_ind).object_version_number := 1.0;
                    WHEN too_many_rows THEN
                      BEGIN
                        SELECT ip_account_id,
                               object_version_number
                        INTO   px_party_acct_tbl(l_pa_ind).ip_account_id,
                               px_party_acct_tbl(l_pa_ind).object_version_number
                        FROM   csi_ip_accounts
                        WHERE  instance_party_id      = px_party_acct_tbl(l_pa_ind).instance_party_id
                        AND    party_account_id       = px_party_acct_tbl(l_pa_ind).party_account_id
                        AND    relationship_type_code = px_party_acct_tbl(l_pa_ind).relationship_type_code;
                      EXCEPTION
                        WHEN no_data_found THEN
                          px_party_acct_tbl(l_pa_ind).ip_account_id := fnd_api.g_miss_num;
                          px_party_acct_tbl(l_pa_ind).object_version_number := 1.0;
                      END;
                  END;
                ELSE
                  SELECT object_version_number
                  INTO   px_party_acct_tbl(l_pa_ind).object_version_number
                  FROM   csi_ip_accounts
                  WHERE  ip_account_id = px_party_acct_tbl(l_pa_ind).ip_account_id;
                END IF;
              END IF;
            END LOOP;
          ELSE
            SELECT object_version_number
            INTO   px_party_tbl(l_p_ind).object_version_number
            FROM   csi_i_parties
            WHERE instance_party_id = px_party_tbl(l_p_ind).instance_party_id;
          END IF;

        END IF;
      END LOOP;
    END IF;

    -- org units

    IF px_org_units_tbl.COUNT > 0 THEN
      FOR l_ind IN px_org_units_tbl.FIRST .. px_org_units_tbl.LAST
      LOOP
        px_org_units_tbl(l_ind).instance_id := px_instance_rec.instance_id;
        px_org_units_tbl(l_ind).active_start_date := fnd_api.g_miss_date;
        IF nvl(px_org_units_tbl(l_ind).instance_ou_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          BEGIN
            SELECT instance_ou_id,
                   object_version_number
            INTO   px_org_units_tbl(l_ind).instance_ou_id,
                   px_org_units_tbl(l_ind).object_version_number
            FROM   csi_i_org_assignments
            WHERE  instance_id = px_org_units_tbl(l_ind).instance_id
            AND    operating_unit_id = px_org_units_tbl(l_ind).operating_unit_id
            AND    relationship_type_code = px_org_units_tbl(l_ind).relationship_type_code;
          EXCEPTION
            WHEN no_data_found THEN
              px_org_units_tbl(l_ind).instance_ou_id := fnd_api.g_miss_num;
              px_org_units_tbl(l_ind).object_version_number := 1.0;
          END;
        ELSE
          SELECT object_version_number
          INTO   px_org_units_tbl(l_ind).instance_ou_id
          FROM   csi_i_org_assignments
          WHERE  instance_ou_id = px_org_units_tbl(l_ind).instance_ou_id;
        END IF;
      END LOOP;
    END IF;

    -- extended attribs
    IF px_eav_tbl.COUNT > 0 THEN
      FOR l_ind IN px_eav_tbl.FIRST .. px_eav_tbl.LAST
      LOOP
        px_eav_tbl(l_ind).instance_id := px_instance_rec.instance_id;
        IF nvl(px_eav_tbl(l_ind).attribute_value_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          BEGIN
            null;
          EXCEPTION
            WHEN no_data_found THEN
              px_eav_tbl(l_ind).object_version_number := 1.0;
          END;
        ELSE
          SELECT object_version_number
          INTO   px_eav_tbl(l_ind).object_version_number
          FROM   csi_iea_values
          WHERE  attribute_value_id = px_eav_tbl(l_ind).attribute_value_id;
        END IF;
      END LOOP;
    END IF;

    -- pricing attribs
    -- Added for bug 5093707
    IF px_pricing_tbl.COUNT > 0 THEN
      FOR l_ind IN px_pricing_tbl.FIRST .. px_pricing_tbl.LAST
      LOOP
        px_pricing_tbl(l_ind).instance_id := px_instance_rec.instance_id;
        IF nvl(px_pricing_tbl(l_ind).pricing_attribute_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

    BEGIN
                SELECT pricing_attribute_id ,
                       object_version_number
                INTO   px_pricing_tbl(l_ind).pricing_attribute_id ,
                       px_pricing_tbl(l_ind).object_version_number
                FROM   csi_i_pricing_attribs
                WHERE  instance_id       = px_instance_rec.instance_id
                AND    pricing_context   = px_pricing_tbl(l_ind).pricing_context ;

           EXCEPTION
     WHEN NO_DATA_FOUND THEN
              px_pricing_tbl(l_ind).object_version_number := 1.0;
           END;

        ELSE
          SELECT object_version_number
          INTO   px_pricing_tbl(l_ind).object_version_number
          FROM   csi_i_pricing_attribs
          WHERE  pricing_attribute_id = px_pricing_tbl(l_ind).pricing_attribute_id;
        END IF;
      END LOOP;
    END IF;
    -- End Added for bug 5093707
    -- end pricing attribs


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_and_derive_ids;

  PROCEDURE build_relationship_tbl(
    p_txn_ii_rltns_tbl  IN    csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_line_dtl_tbl  IN    csi_t_datastructures_grp.txn_line_detail_tbl,
    x_c_ii_rltns_tbl    OUT NOCOPY   csi_datastructures_pub.ii_relationship_tbl,
    x_u_ii_rltns_tbl    OUT NOCOPY   csi_datastructures_pub.ii_relationship_tbl,
    x_return_status     OUT NOCOPY   varchar2)
  IS

    l_r_tbl             csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_td_tbl            csi_t_datastructures_grp.txn_line_detail_tbl;

    l_sub_instance_id   number;
    l_obj_instance_id   number;
    l_rel_end_date      date;

    --Fix for bug 5956280
    l_obj_end_date      date;
    l_sub_end_date      date;


    l_c_ind             binary_integer := 0;
    l_u_ind             binary_integer := 0;

    skip_the_relation   exception;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('build_relationship_tbl');

    debug('  ii_rltns_tbl    :'||p_txn_ii_rltns_tbl.count);

    l_r_tbl  := p_txn_ii_rltns_tbl;
    l_td_tbl := p_txn_line_dtl_tbl;

    IF l_r_tbl.COUNT > 0 THEN
      FOR l_ii_ind IN l_r_tbl.FIRST .. l_r_tbl.LAST
      LOOP
        l_rel_end_date := NULL;
        l_obj_end_date := NULL;
        l_sub_end_date := NULL;
        BEGIN

          debug('    sub_config_inst_hdr_id  :'||l_r_tbl(l_ii_ind).sub_config_inst_hdr_id);
          debug('    sub_config_inst_rev_num :'||l_r_tbl(l_ii_ind).sub_config_inst_rev_num);
          debug('    sub_config_inst_item_id :'||l_r_tbl(l_ii_ind).sub_config_inst_item_id);
          debug(' ');
          debug('    obj_config_inst_hdr_id  :'||l_r_tbl(l_ii_ind).obj_config_inst_hdr_id);
          debug('    obj_config_inst_rev_num :'||l_r_tbl(l_ii_ind).obj_config_inst_rev_num);
          debug('    obj_config_inst_item_id :'||l_r_tbl(l_ii_ind).obj_config_inst_item_id);

          IF l_r_tbl(l_ii_ind).subject_type = 'I' THEN
             l_sub_instance_id := l_r_tbl(l_ii_ind).subject_id;
          ELSE
             BEGIN
               SELECT instance_id,active_end_date
               INTO   l_sub_instance_id,l_sub_end_date --Fix for bug 5956280
               FROM   csi_item_instances
               WHERE  config_inst_hdr_id  = l_r_tbl(l_ii_ind).sub_config_inst_hdr_id
               --AND    config_inst_rev_num = l_r_tbl(l_ii_ind).sub_config_inst_rev_num
               AND    config_inst_item_id = l_r_tbl(l_ii_ind).sub_config_inst_item_id;
             EXCEPTION
               WHEN no_data_found THEN
                  BEGIN
                     SELECT instance_id,active_end_date
                     INTO   l_sub_instance_id,l_sub_end_date --Fix for bug 5956280
                     FROM CSI_T_TXN_LINE_DETAILS
                     WHERE txn_line_detail_id = l_r_tbl(l_ii_ind).subject_id;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        raise skip_the_relation;
                  END;
             END;
          END IF;

          IF l_r_tbl(l_ii_ind).object_type = 'I' THEN
             l_obj_instance_id := l_r_tbl(l_ii_ind).object_id;
          ELSE
             BEGIN
               SELECT instance_id,active_end_date
               INTO   l_obj_instance_id,l_obj_end_date --Fix for bug 5956280
               FROM   csi_item_instances
               WHERE  config_inst_hdr_id  = l_r_tbl(l_ii_ind).obj_config_inst_hdr_id
               --AND    config_inst_rev_num = l_r_tbl(l_ii_ind).obj_config_inst_rev_num
               AND    config_inst_item_id = l_r_tbl(l_ii_ind).obj_config_inst_item_id;
             EXCEPTION
               WHEN no_data_found THEN
                  BEGIN
                     SELECT instance_id,active_end_date
                     INTO   l_obj_instance_id,l_obj_end_date --Fix for bug 5956280
                     FROM CSI_T_TXN_LINE_DETAILS
                     WHERE txn_line_detail_id = l_r_tbl(l_ii_ind).object_id;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        raise skip_the_relation;
                  END;
             END;
          END IF;

          BEGIN
            SELECT relationship_id,
                   object_version_number,
                   active_end_date
            INTO   l_r_tbl(l_ii_ind).csi_inst_relationship_id,
                   l_r_tbl(l_ii_ind).object_version_number,
                   l_rel_end_date
            FROM   csi_ii_relationships
            WHERE  subject_id = l_sub_instance_id
            AND    object_id  = l_obj_instance_id;
          EXCEPTION
            WHEN no_data_found THEN
              l_r_tbl(l_ii_ind).csi_inst_relationship_id := fnd_api.g_miss_num;
          END;

          IF nvl(l_r_tbl(l_ii_ind).csi_inst_relationship_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            IF  l_r_tbl(l_ii_ind).active_end_date IS NULL AND l_obj_end_date IS NULL --Fix for bug 5956280
            AND l_sub_end_date IS NULL THEN
		l_c_ind := l_c_ind + 1;
		x_c_ii_rltns_tbl(l_c_ind).relationship_id := fnd_api.g_miss_num;
		x_c_ii_rltns_tbl(l_c_ind).subject_id      := l_sub_instance_id;
		x_c_ii_rltns_tbl(l_c_ind).relationship_type_code := l_r_tbl(l_ii_ind).relationship_type_code;
		x_c_ii_rltns_tbl(l_c_ind).object_id       := l_obj_instance_id;
		x_c_ii_rltns_tbl(l_c_ind).display_order   := l_r_tbl(l_ii_ind).display_order;
		x_c_ii_rltns_tbl(l_c_ind).position_reference  := l_r_tbl(l_ii_ind).position_reference;
	    END IF;
          ELSE

            /* if the relationship is not already end dated then take it for processing */
          --  IF l_rel_end_date is null THEN
              l_u_ind := l_u_ind + 1;
              x_u_ii_rltns_tbl(l_u_ind).relationship_id := l_r_tbl(l_ii_ind).csi_inst_relationship_id;
              x_u_ii_rltns_tbl(l_u_ind).subject_id      := l_sub_instance_id;
              x_u_ii_rltns_tbl(l_u_ind).relationship_type_code := l_r_tbl(l_ii_ind).relationship_type_code;
              x_u_ii_rltns_tbl(l_u_ind).object_id       := l_obj_instance_id;
              x_u_ii_rltns_tbl(l_u_ind).display_order   := l_r_tbl(l_ii_ind).display_order;
              x_u_ii_rltns_tbl(l_u_ind).position_reference  := l_r_tbl(l_ii_ind).position_reference;
	      --Modified for bug5928619
              IF l_rel_end_date is null THEN
                  x_u_ii_rltns_tbl(l_u_ind).active_end_date := l_r_tbl(l_ii_ind).active_end_date;
                  debug('l_rel_end_date is null '||l_rel_end_date);
              ELSE
                  x_u_ii_rltns_tbl(l_u_ind).active_end_date := null; --Added for bug5928619
                  debug('l_rel_end_date is not null '||l_rel_end_date);
              END IF;

              x_u_ii_rltns_tbl(l_u_ind).object_version_number := l_r_tbl(l_ii_ind).object_version_number;
        --    END IF;

          END IF;

        EXCEPTION
          WHEN skip_the_relation THEN
            null;
        END;
      END LOOP;
    END IF;

    debug('  create_ii_rltns :'||x_c_ii_rltns_tbl.count);
    debug('  update_ii_rltns :'||x_u_ii_rltns_tbl.count);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END build_relationship_tbl;

  PROCEDURE update_td_status(
    p_txn_line_rec         IN     csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_dtl_tbl     IN     csi_t_datastructures_grp.txn_line_detail_tbl,
    p_processing_status    IN     varchar2,
    x_return_status        OUT NOCOPY    varchar2)
  IS

    l_tl_rec               csi_t_datastructures_grp.txn_line_rec;
    l_td_tbl               csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pd_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pa_tbl               csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_oa_tbl               csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ea_tbl               csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_ir_tbl               csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('update_td_status');

    --l_tl_rec := p_txn_line_rec;
    IF nvl(p_txn_line_rec.transaction_line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_tl_rec.transaction_line_id := p_txn_line_rec.transaction_line_id;
      l_tl_rec.processing_status   := p_processing_status;
      l_tl_rec.api_caller_identity := 'CONFIG';

      IF p_txn_line_dtl_tbl.COUNT > 0 THEN
        FOR l_ind IN p_txn_line_dtl_tbl.FIRST .. p_txn_line_dtl_tbl.LAST
        LOOP
          l_td_tbl(l_ind).txn_line_detail_id := p_txn_line_dtl_tbl(l_ind).source_txn_line_detail_id;
          l_td_tbl(l_ind).processing_status  := p_processing_status;
          l_td_tbl(l_ind).api_caller_identity := 'CONFIG';

          IF p_processing_status = 'ERROR' THEN
            l_td_tbl(l_ind).error_explanation := p_txn_line_dtl_tbl(l_ind).error_explanation;
          END IF;

        END LOOP;
      END IF;

      csi_t_txn_details_grp.update_txn_line_dtls(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_full,
        p_txn_line_rec             => l_tl_rec,
        p_txn_line_detail_tbl      => l_td_tbl,
        px_txn_party_detail_tbl    => l_pd_tbl,
        px_txn_pty_acct_detail_tbl => l_pa_tbl,
        px_txn_org_assgn_tbl       => l_oa_tbl,
        px_txn_ext_attrib_vals_tbl => l_ea_tbl,
        px_txn_ii_rltns_tbl        => l_ir_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END update_td_status;
  --
  --
  --
  PROCEDURE interface_ib(
    p_source_header_rec    IN     csi_interface_pkg.source_header_rec,
    p_source_line_rec      IN     csi_interface_pkg.source_line_rec,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_eav_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_pricing_attribs_tbl IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status           OUT NOCOPY varchar2,
    x_return_message          OUT NOCOPY varchar2)
  IS

    l_instance_rec               csi_datastructures_pub.instance_rec;
    l_party_tbl                  csi_datastructures_pub.party_tbl;
    l_party_acct_tbl             csi_datastructures_pub.party_account_tbl;
    l_eav_tbl                    csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl                csi_datastructures_pub.pricing_attribs_tbl;
    l_org_units_tbl              csi_datastructures_pub.organization_units_tbl;

    l_sub_type_rec               csi_txn_sub_types%rowtype;
    l_item_attrib_rec            item_attributes_rec;

    l_csi_txn_rec                csi_datastructures_pub.transaction_rec;

    l_c_instance_rec             csi_datastructures_pub.instance_rec;
    l_c_party_tbl                csi_datastructures_pub.party_tbl;
    l_c_party_acct_tbl           csi_datastructures_pub.party_account_tbl;
    l_c_org_units_tbl            csi_datastructures_pub.organization_units_tbl;
    l_c_eav_tbl                  csi_datastructures_pub.extend_attrib_values_tbl;
    l_c_pricing_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_c_inst_asset_tbl           csi_datastructures_pub.instance_asset_tbl;

    l_u_end_date                 date := null;

    l_u_instance_rec             csi_datastructures_pub.instance_rec;
    l_u_party_tbl                csi_datastructures_pub.party_tbl;
    l_u_party_acct_tbl           csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl            csi_datastructures_pub.organization_units_tbl;
    l_u_eav_tbl                  csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_u_inst_asset_tbl           csi_datastructures_pub.instance_asset_tbl;
    l_u_inst_id_tbl              csi_datastructures_pub.id_tbl;

    l_c_ii_rltns_tbl             csi_datastructures_pub.ii_relationship_tbl;
    l_u_ii_rltns_tbl             csi_datastructures_pub.ii_relationship_tbl;

    l_txn_line_rec               csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_query_rec         csi_t_datastructures_grp.txn_line_query_rec;

    -- explode bom variables
    l_bom_std_item_rec           csi_datastructures_pub.instance_rec;
    l_comp_instance_tbl          csi_datastructures_pub.instance_tbl;
    l_comp_relation_tbl          csi_datastructures_pub.ii_relationship_tbl;
    l_bom_explode_flag           BOOLEAN := FALSE;

    l_create_flag                boolean     := FALSE;
    l_call_contracts             varchar2(1) := fnd_api.g_true;

     --4327207
    l_fulfilled_date             date        := fnd_api.g_miss_date;
    l_rlt_active_end_date        date        := fnd_api.g_miss_date;
    l_parent_line_rec            oe_order_pub.line_rec_type;
    om_vld_org_id                NUMBER;
    l_csi_order_line_rec         csi_order_ship_pub.order_line_rec;
    l_child_line_tbl             oe_order_pub.line_tbl_type;
    l_inst_query_rec             csi_datastructures_pub.instance_query_rec;
    l_party_query_rec            csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec         csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl           csi_datastructures_pub.instance_header_tbl;
    l_rel_ctr                    NUMBER;

    l_active_end_date            date        := fnd_api.g_miss_date;
    l_return_status              varchar2(1) := fnd_api.g_ret_sts_success;
    l_rel_type_code              varchar2(30) := 'COMPONENT-OF';
    l_msg_count                  number;
    l_msg_data                   varchar2(2000);

		-- Added for FP of bug 6755897 - Reconcilation changes
 	  l_item_instance_expired      varchar2(1);
  BEGIN

    api_log('interface_ib');

    x_return_status := fnd_api.g_ret_sts_success;

    debug('  input record count for interface_ib :-');
    debug('    txn_line_dtl_tbl    :'||px_txn_line_dtl_tbl.count);
    debug('    txn_party_tbl       :'||px_txn_party_tbl.count);
    debug('    txn_party_acct_tbl  :'||px_txn_party_acct_tbl.count);
    debug('    txn_org_assgn_tbl   :'||px_txn_org_assgn_tbl.count);
    debug('    txn_eav_tbl         :'||px_txn_eav_tbl.count);
    debug('    txn_ii_rltns_tbl    :'||px_txn_ii_rltns_tbl.count);
    debug('    pricing_attribs_tbl :'||px_pricing_attribs_tbl.count);

     --4327207
    l_fulfilled_date := nvl(p_source_line_rec.fulfilled_date,fnd_api.g_miss_date);

    -- get_item_attributes
    get_item_attributes(
      p_inventory_item_id    => p_source_line_rec.inventory_item_id,
      p_organization_id      => p_source_line_rec.organization_id,
      x_item_attrib_rec      => l_item_attrib_rec,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_source_line_rec.org_id is not null THEN
      om_vld_org_id := oe_sys_parameters.value(
                         param_name => 'MASTER_ORGANIZATION_ID',
                         p_org_id   => p_source_line_rec.org_id);
    END IF;


    IF px_txn_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN px_txn_line_dtl_tbl.FIRST .. px_txn_line_dtl_tbl.LAST
      LOOP

        debug('Transaction Type ID:'||px_txn_line_rec.source_transaction_type_id);
        debug('Sub Type ID        :'||px_txn_line_dtl_tbl(l_td_ind).sub_type_id);
        debug('Instance ID        :'||px_txn_line_dtl_tbl(l_td_ind).instance_id);

        --4327207

        --Added code for bug 7517240
        l_pricing_tbl := px_pricing_attribs_tbl; --Added for bug 7239142
        IF l_pricing_tbl.COUNT > 0 THEN
          FOR l_pricing_index IN l_pricing_tbl.FIRST..l_pricing_tbl.LAST LOOP
            debug('Pricing Attributes Table Record #  :'||l_pricing_index);
            debug('pricing_attribute_id        :'||l_pricing_tbl(l_pricing_index).pricing_attribute_id);
            debug('instance_id                 :'||l_pricing_tbl(l_pricing_index).instance_id);
            debug('active_start_date           :'||l_pricing_tbl(l_pricing_index).active_start_date);
            debug('active_end_date             :'||l_pricing_tbl(l_pricing_index).active_end_date);
            debug('pricing_context             :'||l_pricing_tbl(l_pricing_index).pricing_context);
          END LOOP;
        END IF;
        --End added code for bug 7517240

	l_create_flag :=FALSE; --5702851
        IF px_txn_line_rec.source_transaction_type_id = 401
           AND
           px_txn_line_rec.config_session_hdr_id IS NOT NULL
           AND
           px_txn_line_dtl_tbl(l_td_ind).active_end_date IS NOT NULL
        THEN
          IF p_source_line_rec.link_to_line_id IS NOT NULL THEN
            BEGIN
              -- Begin fix for bug 6964595, FP of bug 6916021
              -- If there are multiple relationships where
              -- the same item instance is the subject, get the active_end_date
              -- for the last one
              SELECT active_end_date
              INTO l_rlt_active_end_date
              FROM csi_ii_relationships
              WHERE relationship_id=
              (SELECT max(relationship_id)
              FROM csi_ii_relationships
              WHERE subject_id = px_txn_line_dtl_tbl(l_td_ind).instance_id
              AND relationship_type_code = l_rel_type_code);  -- srramakr added
              -- End fix for bug 6964595, FP of bug 6916021
            EXCEPTION
              WHEN no_data_found THEN
                debug('No relationship exists');
            END;

            IF l_rlt_active_end_date IS NOT NULL THEN
              csi_order_fulfill_pub.get_ib_trackable_parent(
                p_current_line_id   => p_source_line_rec.source_line_id,
                p_om_vld_org_id     => om_vld_org_id,
                x_parent_line_rec   => l_parent_line_rec,
                x_return_status     => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_parent_line_rec.fulfillment_date IS NOT NULL
                 AND
                 l_parent_line_rec.fulfillment_date > p_source_line_rec.fulfilled_date
              THEN
                l_fulfilled_date := l_parent_line_rec.fulfillment_date;
              END IF;
              debug('l_parent_fulfill_date_time..'||to_char(l_parent_line_rec.fulfillment_date,'dd-mon-yyyy hh:mi:ss'));
              debug('p_source_fulfill_date time..'||to_char(p_source_line_rec.fulfilled_date,'dd-mon-yyyy hh:mi:ss'));

            END IF;

          END IF;--end of link_to_line_id
        END IF;--end of disconnect fulfill date swap
        -- 4327207

        -- get sub_type rec
        BEGIN
          SELECT *
          INTO   l_sub_type_rec
          FROM   csi_txn_sub_types
          WHERE  transaction_type_id = px_txn_line_rec.source_transaction_type_id
          AND    sub_type_id         = px_txn_line_dtl_tbl(l_td_ind).sub_type_id;
        EXCEPTION
          WHEN no_data_found THEN
            fnd_message.set_name('CSI', 'CSI_INT_SUB_TYPE_REC_MISSING');
            fnd_message.set_token('SUB_TYPE_ID', px_txn_line_dtl_tbl(l_td_ind).sub_type_id);
            fnd_message.set_token('TRANSACTION_TYPE_ID',px_txn_line_rec.source_transaction_type_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END;

        debug('src_status_id      :'||l_sub_type_rec.src_status_id);

        IF nvl(px_csi_txn_rec.transaction_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          l_csi_txn_rec  := px_csi_txn_rec;
        ELSE
          l_csi_txn_rec.transaction_id          := fnd_api.g_miss_num;
          l_csi_txn_rec.transaction_type_id     := px_txn_line_rec.source_transaction_type_id;
          l_csi_txn_rec.txn_sub_type_id         := px_txn_line_dtl_tbl(l_td_ind).sub_type_id;
          l_csi_txn_rec.transaction_date        := sysdate;
          l_csi_txn_rec.source_header_ref_id    := p_source_header_rec.source_header_id;
          l_csi_txn_rec.source_header_ref       := p_source_header_rec.source_header_ref;
          l_csi_txn_rec.source_line_ref_id      := p_source_line_rec.source_line_id;
          l_csi_txn_rec.source_line_ref         := p_source_line_rec.source_line_ref;
          l_csi_txn_rec.source_transaction_date := l_fulfilled_date;
        END IF;

        debug('Txn line end date     :'||px_txn_line_dtl_tbl(l_td_ind).active_end_date);
        debug('Top model line id     :'||p_source_line_rec.top_model_line_id);
        debug('Link to line id       :'||p_source_line_rec.link_to_line_id);
        debug('l_fulfilled_date      :'||l_fulfilled_date);
        debug('Order fullfill date   :'||p_source_line_rec.fulfilled_date);
        debug('Relationship end date :'||l_rlt_active_end_date);

        -- adding this condition to make sure that the relationship processing
        -- happens once and only once within the interface_ib session
        IF l_td_ind = 1 THEN

          /* moved this update_relationship set above to address the issue with
             expire the relationship first before processing the children. The
             core API while expiring the parent instance automatically end dates
             the child instances. We are stopping that by expiring the relationsip
             first thus by hiding the shildren from the API.
          */

          IF px_txn_ii_rltns_tbl.COUNT > 0 THEN

            build_relationship_tbl(
              p_txn_ii_rltns_tbl    => px_txn_ii_rltns_tbl,
              p_txn_line_dtl_tbl    => px_txn_line_dtl_tbl,
              x_c_ii_rltns_tbl      => l_c_ii_rltns_tbl,
              x_u_ii_rltns_tbl      => l_u_ii_rltns_tbl,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            /* update the existing relationships */
            IF l_u_ii_rltns_tbl.COUNT > 0 THEN

              /* to stamp the source transaction date as end date */
              FOR l_ind IN l_u_ii_rltns_tbl.FIRST .. l_u_ii_rltns_tbl.LAST
              LOOP
                debug(' Relationship_ID      :'|| l_u_ii_rltns_tbl(l_ind).relationship_id);
                debug(' Relationship_End_Date:'|| l_u_ii_rltns_tbl(l_ind).active_end_date);
                IF nvl(l_u_ii_rltns_tbl(l_ind).active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date
                THEN
                  l_u_ii_rltns_tbl(l_ind).active_end_date := l_csi_txn_rec.source_transaction_date;
                END IF;
                debug(' Source_txn_date      :'|| l_u_ii_rltns_tbl(l_ind).active_end_date);
              END LOOP;

              record_time('Start');

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_ii_relationships_pub',
                p_api_name => 'update_relationship');

              csi_ii_relationships_pub.update_relationship(
                p_api_version        => 1.0,
                p_commit             => fnd_api.g_false,
                p_init_msg_list      => fnd_api.g_true,
                p_validation_level   => fnd_api.g_valid_level_full,
                p_relationship_tbl   => l_u_ii_rltns_tbl,
                p_txn_rec            => l_csi_txn_rec,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              record_time('End');

            END IF;
          END IF;
        END IF;

        -- build temporary instance set
        build_instance_set(
          p_index                => l_td_ind,
          p_source_line_rec      => p_source_line_rec,
          p_item_attrib_rec      => l_item_attrib_rec,
          p_txn_line_dtl_rec     => px_txn_line_dtl_tbl(l_td_ind),
          p_txn_party_tbl        => px_txn_party_tbl,
          p_txn_party_acct_tbl   => px_txn_party_acct_tbl,
          p_txn_org_assgn_tbl    => px_txn_org_assgn_tbl,
          p_txn_eav_tbl          => px_txn_eav_tbl,
          px_pricing_tbl         => l_pricing_tbl,
          x_instance_rec         => l_instance_rec,
          x_party_tbl            => l_party_tbl,
          x_party_acct_tbl       => l_party_acct_tbl,
          x_org_units_tbl        => l_org_units_tbl,
          x_eav_tbl              => l_eav_tbl,
          x_return_status        => l_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('source_transaction_flag :'||px_txn_line_dtl_tbl(l_td_ind).source_transaction_flag);
        IF px_txn_line_dtl_tbl(l_td_ind).source_transaction_flag = 'Y' THEN
          l_instance_rec.instance_status_id := nvl(l_sub_type_rec.src_status_id, fnd_api.g_miss_num);
        ELSE
          l_instance_rec.instance_status_id := nvl(l_sub_type_rec.non_src_status_id, fnd_api.g_miss_num);
        END IF;

        debug('  processing record count for instance :-');
        debug('    instance_id         :'||l_instance_rec.instance_id);
        debug('    party_tbl           :'||l_party_tbl.count);
        debug('    party_acct_tbl      :'||l_party_acct_tbl.count);
        debug('    org_units_tbl       :'||l_org_units_tbl.count);
        debug('    eav_tbl             :'||l_eav_tbl.count);
        debug('    pricing_tbl         :'||l_pricing_tbl.count);


        -- do sub type specific validations

        sub_type_specific_vldns(
          p_source_flag          => px_txn_line_dtl_tbl(l_td_ind).source_transaction_flag,
          p_sub_type_rec         => l_sub_type_rec,
          p_instance_rec         => l_instance_rec,
          p_party_tbl            => l_party_tbl,
          p_party_acct_tbl       => l_party_acct_tbl,
          p_eav_tbl              => l_eav_tbl,
          p_org_units_tbl        => l_org_units_tbl,
          p_pricing_tbl          => l_pricing_tbl,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF nvl(l_instance_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          l_create_flag := TRUE;
        END IF;

        IF l_create_flag THEN
          -- check if the instance created is in replacement for a non source ref
             -- then disable the new contracts call
          -- build create_instance
          l_c_instance_rec    := l_instance_rec;
          l_c_party_tbl       := l_party_tbl;
          l_c_party_acct_tbl  := l_party_acct_tbl;
          l_c_org_units_tbl   := l_org_units_tbl;
          l_c_eav_tbl         := l_eav_tbl;
          l_c_pricing_tbl     := l_pricing_tbl;

          csi_t_gen_utility_pvt.dump_csi_instance_rec(l_c_instance_rec);

          IF csi_t_gen_utility_pvt.g_debug_level >= 15 THEN
            csi_t_gen_utility_pvt.dump_csi_party_tbl(l_c_party_tbl);
            csi_t_gen_utility_pvt.dump_csi_account_tbl(l_c_party_acct_tbl);
            csi_t_gen_utility_pvt.dump_eav_tbl(l_c_eav_tbl);
          END IF;

          record_time('Start');

          csi_t_gen_utility_pvt.dump_api_info(
            p_pkg_name => 'csi_item_instance_pub',
            p_api_name => 'create_item_instance');

          csi_item_instance_pub.create_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_txn_rec               => l_csi_txn_rec,
            p_instance_rec          => l_c_instance_rec,
            p_party_tbl             => l_c_party_tbl,
            p_account_tbl           => l_c_party_acct_tbl,
            p_org_assignments_tbl   => l_c_org_units_tbl,
            p_ext_attrib_values_tbl => l_c_eav_tbl,
            p_pricing_attrib_tbl    => l_c_pricing_tbl,
            p_asset_assignment_tbl  => l_c_inst_asset_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data  );

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            raise fnd_api.g_exc_error;
          END IF;

          record_time('End');

          px_txn_line_dtl_tbl(l_td_ind).instance_id := l_c_instance_rec.instance_id;

          debug('Customer Product ID : '||l_c_instance_rec.instance_id);

          /* Setting values for Explode BOM in CREATE */

          IF l_c_instance_rec.quantity = 1 THEN
            l_bom_std_item_rec.instance_id         := l_c_instance_rec.instance_id ;
            l_bom_std_item_rec.inventory_item_id   := px_txn_line_dtl_tbl(l_td_ind).inventory_item_id ;
            l_bom_std_item_rec.vld_organization_id := px_txn_line_dtl_tbl(l_td_ind).inv_organization_id ;
            l_bom_std_item_rec.quantity            := 1;
          END IF;

          -- check auto split profile and split
        ELSE -- instance id reference is specified

          --validate and derive ids

          validate_and_derive_ids(
            px_instance_rec        => l_instance_rec,
            px_party_tbl           => l_party_tbl,
            px_party_acct_tbl      => l_party_acct_tbl,
            px_org_units_tbl       => l_org_units_tbl,
            px_eav_tbl             => l_eav_tbl,
            px_pricing_tbl         => l_pricing_tbl,
            x_return_status        => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- validations based on the baseline rev num ##

          -- TSO with equipment
          -- For Tangible item, since DISCONNECT is the only possible operation, we need to remove the config keys.
          -- Hence nullifying them.
          --
          IF l_instance_rec.serial_number IS NOT NULL AND
             l_instance_rec.serial_number <> FND_API.G_MISS_CHAR THEN
             l_instance_rec.config_inst_hdr_id := NULL;
             l_instance_rec.config_inst_rev_num := NULL;
             l_instance_rec.config_inst_item_id := NULL;
          END IF;
          l_u_instance_rec    := l_instance_rec;
          l_u_party_tbl       := l_party_tbl;
          l_u_party_acct_tbl  := l_party_acct_tbl;
          l_u_org_units_tbl   := l_org_units_tbl;
          l_u_eav_tbl         := l_eav_tbl;
          l_u_pricing_tbl     := l_pricing_tbl;

          csi_t_gen_utility_pvt.dump_csi_instance_rec(l_u_instance_rec);
          csi_t_gen_utility_pvt.dump_csi_party_tbl(l_u_party_tbl);
          csi_t_gen_utility_pvt.dump_csi_account_tbl(l_u_party_acct_tbl);
          csi_t_gen_utility_pvt.dump_eav_tbl(l_u_eav_tbl);


          IF nvl(l_u_instance_rec.active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date
          THEN
            l_u_instance_rec.active_end_date := l_csi_txn_rec.source_transaction_date;
          END IF;

					-- Start adding code for FP of bug 6755897 - Reconcilation changes
 	        BEGIN
 	          SELECT 'N'
 	          INTO l_item_instance_expired
 	          FROM csi_item_instances
 	          WHERE instance_id = l_u_instance_rec.instance_id
 	          AND ((active_end_date IS NULL) OR (active_end_date >= SYSDATE));
 	        EXCEPTION
 	          WHEN NO_DATA_FOUND THEN
 	            l_item_instance_expired := 'Y';
 	        END;

 	        IF l_item_instance_expired = 'Y' AND
 	          (nvl(l_u_instance_rec.active_end_date, fnd_api.g_miss_date) <> fnd_api.g_miss_date) THEN
 	          debug('Item instance ('||l_u_instance_rec.instance_id||') already expired, no need to expire again.');
 	        ELSE
 	        -- End adding code for FP of bug 6755897 - Reconcilation changes
						record_time('Start');

	          csi_t_gen_utility_pvt.dump_api_info(
	            p_pkg_name => 'csi_item_instance_pub',
	            p_api_name => 'update_item_instance');

	          csi_item_instance_pub.update_item_instance(
	            p_api_version           => 1.0,
	            p_commit                => fnd_api.g_false,
	            p_init_msg_list         => fnd_api.g_true,
	            p_validation_level      => fnd_api.g_valid_level_full,
	            p_txn_rec               => l_csi_txn_rec,
	            p_instance_rec          => l_u_instance_rec,
	            p_party_tbl             => l_u_party_tbl,
	            p_account_tbl           => l_u_party_acct_tbl,
	            p_org_assignments_tbl   => l_u_org_units_tbl,
	            p_ext_attrib_values_tbl => l_u_eav_tbl,
	            p_pricing_attrib_tbl    => l_u_pricing_tbl,
	            p_asset_assignment_tbl  => l_u_inst_asset_tbl,
	            x_instance_id_lst       => l_u_inst_id_tbl,
	            x_return_status         => l_return_status,
	            x_msg_count             => l_msg_count,
	            x_msg_data              => l_msg_data );

	          record_time('End');

	          -- For Bug 4057183
	          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
	          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
	            RAISE fnd_api.g_exc_error;
	          END IF;
					END IF; -- Added for FP of bug 6755897 - Reconcilation changes

          px_txn_line_dtl_tbl(l_td_ind).instance_id := l_u_instance_rec.instance_id;

          debug('Customer Product ID : '||l_u_instance_rec.instance_id);

          /* Setting values for Explode BOM in UPDATE */

          IF l_u_instance_rec.quantity = 1 THEN
            l_bom_std_item_rec.instance_id         := l_u_instance_rec.instance_id ;
            l_bom_std_item_rec.inventory_item_id   := px_txn_line_dtl_tbl(l_td_ind).inventory_item_id ;
            l_bom_std_item_rec.vld_organization_id := px_txn_line_dtl_tbl(l_td_ind).inv_organization_id ;
            l_bom_std_item_rec.quantity            := 1;
          END IF;


        END IF;

        /* Checking for BOM eligibility and Exploding */
        --
        -- srramakr check_standard_bom_pc will be called only for Project Contracts Shipments.
        -- For other transaction types we need to call Check_Standard_Bom routine.
        --
        IF l_csi_txn_rec.transaction_type_id = 326 THEN

           l_bom_explode_flag := check_standard_bom_pc(
               p_instance_id    =>  l_bom_std_item_rec.instance_id,
               p_std_item_rec   =>  l_bom_std_item_rec,
               p_bom_item_type  =>  l_item_attrib_rec.bom_item_type );
        ELSE
           l_bom_explode_flag := csi_item_instance_vld_pvt.Is_Config_Exploded
                                    (p_instance_id        =>  l_bom_std_item_rec.instance_id,
                                     p_stack_err_msg      =>  FALSE );
           --
           IF l_bom_explode_flag THEN -- Config Already Exploded. So set this to FALSE
              l_bom_explode_flag := FALSE;
           ELSE -- Not yet exploded. Check for eligibility
              l_csi_order_line_rec.header_id := p_source_header_rec.source_header_id;
              l_csi_order_line_rec.order_line_id := p_source_line_rec.source_line_id;
              l_csi_order_line_rec.inv_item_id := p_source_line_rec.inventory_item_id;
              l_csi_order_line_rec.inv_org_id := p_source_line_rec.organization_id;
              l_csi_order_line_rec.bom_item_type := l_item_attrib_rec.bom_item_type;
              l_csi_order_line_rec.item_type_code := p_source_line_rec.item_type_code;
              --
              l_bom_explode_flag := csi_utl_pkg.check_standard_bom
                                       (p_order_line_rec => l_csi_order_line_rec );
           END IF;
        END IF;

        IF l_bom_explode_flag THEN

         debug('This shipment from Project Contracts qualifies for BOM Explosion');
         debug('  instance_id :'||l_bom_std_item_rec.instance_id);
         debug('  inv_item_id :'||l_bom_std_item_rec.inventory_item_id);
         debug('  inv_org_id  :'||l_bom_std_item_rec.vld_organization_id);
         debug('  quantity    :'||l_bom_std_item_rec.quantity);

         record_time('Start');

         -- call the API for BOM Explosion
         csi_t_gen_utility_pvt.dump_api_info(
           p_pkg_name => 'csi_item_instance_pvt',
           p_api_name => 'explode_bom');

         csi_item_instance_pvt.explode_bom(
           p_api_version         => 1.0,
           p_commit              => fnd_api.g_false,
           p_init_msg_list       => fnd_api.g_true,
           p_validation_level    => fnd_api.g_valid_level_full,
           p_source_instance_rec => l_bom_std_item_rec,
           p_explosion_level     => fnd_api.g_miss_num,
           p_item_tbl            => l_comp_instance_tbl,
           p_item_relation_tbl   => l_comp_relation_tbl,
           p_create_instance     => fnd_api.g_true,
           p_txn_rec             => l_csi_txn_rec,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data);

         record_time('End');

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           debug('Failed csi_item_instance_pvt.explode_bom');
           RAISE fnd_api.g_exc_error;
         END IF;

         debug('  Trackable components       :'||l_comp_instance_tbl.count);
         debug('  Component-Of Relationships :'||l_comp_relation_tbl.count);

       END IF; -- End BOM Explosion

      END LOOP;
    END IF; -- px_txn_line_dtl_tbl.count > 0

    IF px_txn_ii_rltns_tbl.COUNT > 0 THEN

      build_relationship_tbl(
        p_txn_ii_rltns_tbl    => px_txn_ii_rltns_tbl,
        p_txn_line_dtl_tbl    => px_txn_line_dtl_tbl,
        x_c_ii_rltns_tbl      => l_c_ii_rltns_tbl,
        x_u_ii_rltns_tbl      => l_u_ii_rltns_tbl,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF; -- px_txn_ii_rltns_tbl.COUNT check
    --
    -- srramakr TSO with Equipment
    -- As a part of MACD flow if we fulfill a KIT(having config keys)i
    -- and ship the included items (not having config keys).
    -- We need to build the relationship between KIT and its included items. Since CZ would not have
    -- written relationships for these, we use the traditional get_ib_trackable children using the
    -- order line and finally get the item instances.
    --
    IF p_source_line_rec.item_type_code = 'KIT' AND
       l_bom_std_item_rec.instance_id IS NOT NULL AND -- Ensure that KIT Qty = 1
       l_bom_std_item_rec.instance_id <> FND_API.G_MISS_NUM THEN
       csi_order_fulfill_pub.get_ib_trackable_children
           ( p_current_line_id    => p_source_line_rec.source_line_id,
             p_om_vld_org_id      => om_vld_org_id,
             x_trackable_line_tbl => l_child_line_tbl,
             x_return_status      => l_return_status);

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Failed csi_order_fulfill_pub.get_ib_trackable_children');
          RAISE fnd_api.g_exc_error;
       END IF;
    END IF;
    --
    IF l_child_line_tbl.count > 0 THEN
       FOR l_ind in l_child_line_tbl.FIRST..l_child_line_tbl.LAST LOOP
   -- check if instance exists
   l_inst_query_rec.inventory_item_id     := l_child_line_tbl(l_ind).inventory_item_id;
   l_inst_query_rec.last_oe_order_line_id := l_child_line_tbl(l_ind).line_id;

   debug('query criteria for get_item_instances:');
   debug('  item id      : '||l_inst_query_rec.inventory_item_id);
   debug('  line id      : '||l_inst_query_rec.last_oe_order_line_id);

   csi_t_gen_utility_pvt.dump_api_info(
       p_api_name => 'get_item_instances',
       p_pkg_name => 'csi_item_instance_pub');

   csi_item_instance_pub.get_item_instances(
       p_api_version          => 1.0,
       p_commit               => fnd_api.g_false,
       p_init_msg_list        => fnd_api.g_true,
       p_validation_level     => fnd_api.g_valid_level_full,
       p_instance_query_rec   => l_inst_query_rec,
       p_party_query_rec      => l_party_query_rec,
       p_account_query_rec    => l_pty_acct_query_rec,
       p_transaction_id       => null,
       p_resolve_id_columns   => fnd_api.g_false,
       /* Modified the next line for bug 4865052*/
	   p_active_instance_only => fnd_api.g_false,
       x_instance_header_tbl  => l_instance_hdr_tbl,
       x_return_status        => l_return_status,
       x_msg_count            => l_msg_count,
       x_msg_data             => l_msg_data);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;
          --
          IF l_instance_hdr_tbl.count > 0 THEN
             FOR inst_hdr IN l_instance_hdr_tbl.FIRST .. l_instance_hdr_tbl.LAST LOOP
                IF l_instance_hdr_tbl.EXISTS(inst_hdr) THEN
                   l_rel_ctr := l_c_ii_rltns_tbl.COUNT + 1;
                   l_c_ii_rltns_tbl(l_rel_ctr).subject_id := l_instance_hdr_tbl(inst_hdr).instance_id;
                   l_c_ii_rltns_tbl(l_rel_ctr).object_id := l_bom_std_item_rec.instance_id;
                   l_c_ii_rltns_tbl(l_rel_ctr).relationship_type_code := 'COMPONENT-OF';
                END IF;
             END LOOP;
          END IF;
       END LOOP;
    END IF; -- l_child_line_tbl.count check
    --
    IF l_c_ii_rltns_tbl.COUNT > 0 THEN

       record_time('Start');
       csi_t_gen_utility_pvt.dump_api_info(
          p_pkg_name => 'csi_ii_relationships_pub',
          p_api_name => 'create_relationship');

       -- create relationship
       csi_ii_relationships_pub.create_relationship(
          p_api_version      => 1.0,
          p_commit           => fnd_api.g_false,
          p_init_msg_list    => fnd_api.g_true,
          p_validation_level => fnd_api.g_valid_level_full,
          p_relationship_tbl => l_c_ii_rltns_tbl,
          p_txn_rec          => l_csi_txn_rec,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data);

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
       END IF;
       record_time('End');

       FOR l_ind IN l_c_ii_rltns_tbl.FIRST .. l_c_ii_rltns_tbl.LAST
       LOOP

          debug('  '||l_c_ii_rltns_tbl(l_ind).subject_id ||' '||
                 l_c_ii_rltns_tbl(l_ind).relationship_type_code||' '||
                 l_c_ii_rltns_tbl(l_ind).object_id);

          IF l_c_ii_rltns_tbl(l_ind).relationship_type_code
             IN ('REPLACED-BY', 'REPLACEMENT-FOR', 'UPGRADED-FROM') THEN
            -- make call to swap the contracts
            null;
          END IF;

       END LOOP;
    END IF; -- l_c_ii_rltns_tbl.count check

    -- switch the processing status in transaction detail to PROCESSED
    update_td_status(
      p_txn_line_rec      => px_txn_line_rec,
      p_txn_line_dtl_tbl  => px_txn_line_dtl_tbl,
      p_processing_status => 'PROCESSED',
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('Transaction details interfaced to IB successfully.');

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error ;
      x_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error in Interface_IB: '||x_return_message);
    WHEN others THEN

      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', substr(sqlerrm, 1, 240));
      fnd_msg_pub.add;

      x_return_status  := fnd_api.g_ret_sts_unexp_error ;
      x_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error in Interface_IB: '||x_return_message);

  END interface_ib;

  --
  --
  --
  FUNCTION check_MACD_processing(
    p_config_session_key      IN csi_utility_grp.config_session_key,
    x_return_status           OUT NOCOPY varchar2)
  RETURN boolean
  IS

    l_td_found                varchar2(1) := 'N';
    l_configurator_enabled    varchar2(80) := null;
    l_mdl_instantiation_type  varchar2(1);

    l_MACD_processing         boolean := TRUE;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_config_session_key.session_hdr_id  is not null
         AND
       p_config_session_key.session_rev_num is not null
         AND
       p_config_session_key.session_item_id is not null
    THEN

      l_configurator_enabled := fnd_profile.value('CSI_CONFIGURATOR_ENABLED');

      -- check for config txn details
      BEGIN
        SELECT 'Y' INTO l_td_found
        FROM   csi_t_transaction_lines
        WHERE  source_transaction_table = 'CONFIGURATOR'
        AND    config_session_hdr_id    = p_config_session_key.session_hdr_id
        AND    config_session_rev_num   = p_config_session_key.session_rev_num
        AND    config_session_item_id   = p_config_session_key.session_item_id;
      EXCEPTION
        WHEN no_data_found THEN
          l_td_found := 'N';
      END;


      IF l_td_found = 'Y' THEN
        -- check for the profile CSI_CONFIGURATOR_ENABLED
        IF l_configurator_enabled = 'NETWORK' THEN

          -- make sure the item is network model otherwise do the
          SELECT model_instantiation_type
          INTO   l_mdl_instantiation_type
          FROM   cz_config_items_v
          WHERE  config_hdr_id  = p_config_session_key.session_hdr_id
          AND    config_rev_nbr = p_config_session_key.session_rev_num
          AND    config_item_id = p_config_session_key.session_item_id;

          IF l_mdl_instantiation_type <> 'N' THEN
            -- regular processing
            l_MACD_processing := FALSE;
          END IF;
        ELSIF l_configurator_enabled = 'ALWAYS' THEN
          null;
        ELSIF nvl(l_configurator_enabled, 'NEVER') = 'NEVER' THEN
          l_MACD_processing := FALSE;
        END IF;

      ELSE
        l_MACD_processing := FALSE;
      END IF;

    ELSE
      l_MACD_processing := FALSE;
    END IF;

    RETURN l_MACD_processing;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_MACD_processing;

  --
  --
  --
  /* This function specifies whether the instance qualifies for BOM Explosion or not */

  FUNCTION check_standard_bom_pc(
    p_instance_id   IN NUMBER,
    p_std_item_rec  IN csi_datastructures_pub.instance_rec,
    p_bom_item_type IN NUMBER)
  RETURN boolean
  IS

    l_bom_found    VARCHAR2(1);
    l_explode_flag VARCHAR2(1);
    l_found_child  VARCHAR2(1);
    no_explosion   EXCEPTION;

  BEGIN

    debug('check_standard_bom for Project Contracts');

    /* look at the explode_yes_no profile AND go FROM there */

    l_explode_flag := nvl(fnd_profile.value('CSI_EXPLODE_BOM'),'N');
    debug('Explode BOM Profile Option :'||l_explode_flag);

    IF l_explode_flag <> 'Y' THEN
       debug('Explode BOM Profile option is not set. ');
       RAISE no_explosion;
    END IF;

    /* check if this item is a standard item */

    IF p_bom_item_type <> 4  THEN
       debug('This inventory item is not a STANDARD item, so no explosion');
       RAISE no_explosion;
    END IF;

    /* check if BOM exists */

    BEGIN
      SELECT 'Y'
      INTO   l_bom_found
      FROM   bom_bill_of_materials
      WHERE  assembly_item_id = p_std_item_rec.inventory_item_id
      AND    organization_id  = p_std_item_rec.vld_organization_id
      AND    alternate_bom_designator is NULL;   -- added for bug 2443204. Checking only primary bom when multiple could have been defined.

    EXCEPTION
      WHEN no_data_found THEN
        debug('BOM not found. So, no explosion');
        RAISE no_explosion;
    END;

    /* logic to check if this instance already has any children */

    BEGIN
      SELECT 'Y'
      INTO   l_found_child
      FROM   csi_ii_relationships
      WHERE  object_id = p_instance_id
      AND    relationship_type_code = 'COMPONENT-OF';

      debug(' This instance already has a child with COMPONENT-OF relation.');
      RAISE no_explosion;

    EXCEPTION
      WHEN no_data_found THEN
        l_found_child := 'N';
      WHEN others THEN
        debug(' This instance already has children with COMPONENT-OF relation.');
        RAISE no_explosion;
    END;

    RETURN TRUE;

  EXCEPTION
    WHEN no_explosion THEN
      RETURN FALSE;
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;

  END check_standard_bom_pc;


  PROCEDURE get_mtl_txn_tbl(
    p_mtl_txn_id    IN  number,
    x_mtl_txn_tbl   OUT NOCOPY mtl_txn_tbl,
    x_return_status OUT NOCOPY varchar2)
  IS

    l_mtl_rec       mtl_txn_rec;
    l_mtl_tbl       mtl_txn_tbl;

    CURSOR mtl_txn_cur(p_txn_id IN NUMBER) IS
      SELECT mmt.trx_source_line_id         trx_source_line_id,
             mmt.inventory_item_id          inventory_item_id,
             mmt.organization_id            organization_id,
             mmt.revision                   revision,
             mmt.subinventory_code          subinventory_code,
             mmt.locator_id                 locator_id,
             null                           lot_number,
             mut.serial_number              serial_number,
             abs(mmt.transaction_quantity)  transaction_quantity,
             mmt.transaction_uom            transaction_uom,
             mmt.transaction_date           transaction_date,
             msi.lot_control_code           lot_control_code,
             msi.serial_number_control_code serial_control_code,
             msi.primary_uom_code           primary_uom,
             abs(mmt.primary_quantity)      primary_quantity,
             mmt.transaction_type_id        transaction_type_id,
             mmt.transaction_action_id      transaction_action_id
      FROM   mtl_system_items               msi,
             mtl_unit_transactions          mut,
             mtl_material_transactions      mmt
      WHERE  mmt.transaction_id       = p_txn_id
      AND    mmt.transaction_id       = mut.transaction_id(+)
      AND    msi.organization_id      = mmt.organization_id
      AND    msi.inventory_item_id    = mmt.inventory_item_id
      AND    msi.lot_control_code     = 1   -- no lot case
      UNION
      SELECT mmt.trx_source_line_id         trx_source_line_id,
             mmt.inventory_item_id          inventory_item_id,
             mmt.organization_id            organization_id,
             mmt.revision                   revision,
             mmt.subinventory_code          subinventory_code,
             mmt.locator_id                 locator_id,
             mtln.lot_number                lot_number,
             mut.serial_number              serial_number,
             abs(mtln.transaction_quantity) transaction_quantity,
             mmt.transaction_uom            transaction_uom,
             mmt.transaction_date           transaction_date,
             msi.lot_control_code           lot_control_code,
             msi.serial_number_control_code serial_control_code,
             msi.primary_uom_code           primary_uom,
             abs(mtln.primary_quantity)     primary_quantity,
             mmt.transaction_type_id        transaction_type_id,
             mmt.transaction_action_id      transaction_action_id
      FROM   mtl_system_items               msi,
             mtl_unit_transactions          mut,
             mtl_transaction_lot_numbers    mtln,
             mtl_material_transactions      mmt
      WHERE  mmt.transaction_id         = p_txn_id
      AND    mmt.transaction_id         = mtln.transaction_id(+)
      AND    mtln.serial_transaction_id = mut.transaction_id(+)
      AND    msi.organization_id        = mmt.organization_id
      AND    msi.inventory_item_id      = mmt.inventory_item_id
      AND    msi.lot_control_code       = 2;   -- lot control case
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR mtl_txn_rec IN mtl_txn_cur(p_mtl_txn_id)
    LOOP

      l_mtl_rec.trx_source_line_id    := mtl_txn_rec.trx_source_line_id;
      l_mtl_rec.inventory_item_id     := mtl_txn_rec.inventory_item_id;
      l_mtl_rec.organization_id       := mtl_txn_rec.organization_id;
      l_mtl_rec.revision              := nvl(mtl_txn_rec.revision,fnd_api.g_miss_char);
      l_mtl_rec.subinventory_code     := mtl_txn_rec.subinventory_code;
      l_mtl_rec.locator_id            := mtl_txn_rec.locator_id;
      l_mtl_rec.lot_number            := nvl(mtl_txn_rec.lot_number,fnd_api.g_miss_char);
      l_mtl_rec.serial_number         := nvl(mtl_txn_rec.serial_number,fnd_api.g_miss_char);
      l_mtl_rec.transaction_quantity  := mtl_txn_rec.transaction_quantity;
      l_mtl_rec.transaction_uom       := mtl_txn_rec.transaction_uom;
      l_mtl_rec.transaction_date      := mtl_txn_rec.transaction_date;
      l_mtl_rec.lot_control_code      := mtl_txn_rec.lot_control_code;
      l_mtl_rec.serial_control_code   := mtl_txn_rec.serial_control_code;
      l_mtl_rec.primary_uom           := mtl_txn_rec.primary_uom;
      l_mtl_rec.primary_quantity      := mtl_txn_rec.primary_quantity;
      l_mtl_rec.transaction_type_id   := mtl_txn_rec.transaction_type_id;
      l_mtl_rec.transaction_action_id := mtl_txn_rec.transaction_action_id;

      l_mtl_tbl(mtl_txn_cur%rowcount) := l_mtl_rec;

    END LOOP;

    x_mtl_txn_tbl := l_mtl_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_mtl_txn_tbl;

  PROCEDURE get_inventory_instances(
    p_item_attrib_rec IN     item_attributes_rec,
    px_mtl_txn_tbl    IN OUT NOCOPY mtl_txn_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_mtl_tbl               mtl_txn_tbl;

    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;
    l_inst_hdr_tbl          csi_datastructures_pub.instance_header_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_inventory_instances');

    l_mtl_tbl := px_mtl_txn_tbl;

    IF l_mtl_tbl.COUNT > 0 THEN
      FOR l_ind IN l_mtl_tbl.FIRST .. l_mtl_tbl.LAST
      LOOP

        l_inst_query_rec.location_type_code    := 'INVENTORY';
        l_inst_query_rec.instance_usage_code   := 'IN_INVENTORY';

        l_inst_query_rec.inventory_item_id     := l_mtl_tbl(l_ind).inventory_item_id;
        l_inst_query_rec.inv_organization_id   := l_mtl_tbl(l_ind).organization_id;
        l_inst_query_rec.inv_subinventory_name := l_mtl_tbl(l_ind).subinventory_code;
        l_inst_query_rec.inv_locator_id        := l_mtl_tbl(l_ind).locator_id;
        l_inst_query_rec.serial_number         := l_mtl_tbl(l_ind).serial_number;
        l_inst_query_rec.lot_number            := l_mtl_tbl(l_ind).lot_number;

        IF p_item_attrib_rec.serial_control_code = 6 THEN

          l_inst_query_rec.serial_number := null;

          IF l_ind > 1 THEN

            l_mtl_tbl(l_ind).instance_id            := l_mtl_tbl(1).instance_id;
            l_mtl_tbl(l_ind).object_version_num     := l_mtl_tbl(1).object_version_num;
            l_mtl_tbl(l_ind).negative_instance_flag := l_mtl_tbl(1).negative_instance_flag;

            goto skip_gii;
          END IF;

        END IF;

        csi_t_gen_utility_pvt.dump_instance_query_rec(
          p_instance_query_rec => l_inst_query_rec);

        csi_t_gen_utility_pvt.dump_api_info(
          p_pkg_name => 'csi_item_instance_pub',
          p_api_name => 'get_item_instances');

        csi_item_instance_pub.get_item_instances(
          p_api_version          => 1.0,
          p_commit               => fnd_api.g_false,
          p_init_msg_list        => fnd_api.g_true,
          p_validation_level     => fnd_api.g_valid_level_full,
          p_instance_query_rec   => l_inst_query_rec,
          p_party_query_rec      => l_party_query_rec,
          p_account_query_rec    => l_pty_acct_query_rec,
          p_transaction_id       => null,
          p_resolve_id_columns   => fnd_api.g_false,
          p_active_instance_only => fnd_api.g_false,
          x_instance_header_tbl  => l_inst_hdr_tbl,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_inst_hdr_tbl.count = 0 THEN

          IF p_item_attrib_rec.serial_control_code IN (1, 6)
             AND
             p_item_attrib_rec.negative_balances_code = 1
          THEN
            debug('non serial and negative balances allowed.');
            l_mtl_tbl(l_ind).negative_instance_flag := 'Y';
            l_mtl_tbl(l_ind).instance_id            := null;
            l_mtl_tbl(l_ind).object_version_num     := null;
          ELSE
            fnd_message.set_name('CSI','CSI_INT_INV_INST_NOT_FOUND');
            fnd_message.set_token('INV_ITEM_ID',l_mtl_tbl(l_ind).inventory_item_id);
            fnd_message.set_token('INV_ORG_ID', l_mtl_tbl(l_ind).organization_id);
            fnd_message.set_token('SUBINV',     l_mtl_tbl(l_ind).subinventory_code);
            fnd_message.set_token('LOCATOR',    l_mtl_tbl(l_ind).locator_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          IF l_inst_hdr_tbl.count = 1 THEN
            l_mtl_tbl(l_ind).instance_id        := l_inst_hdr_tbl(1).instance_id;
            l_mtl_tbl(l_ind).object_version_num := l_inst_hdr_tbl(1).object_version_number;
            debug('  instance_id       : '||l_mtl_tbl(l_ind).instance_id);
            debug('  instance_ovn      : '||l_mtl_tbl(l_ind).object_version_num);
          ELSE
            fnd_message.set_name('CSI','CSI_TXN_MULT_INST_FOUND');
            fnd_message.set_token('INV_ITEM_ID',l_mtl_tbl(l_ind).inventory_item_id);
            fnd_message.set_token('INV_ORG_ID', l_mtl_tbl(l_ind).organization_id);
            fnd_message.set_token('SUBINV',     l_mtl_tbl(l_ind).subinventory_code);
            fnd_message.set_token('LOCATOR',    l_mtl_tbl(l_ind).locator_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        <<skip_gii>>
        null;

      END LOOP;
    END IF;

    px_mtl_txn_tbl := l_mtl_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_inventory_instances;

  PROCEDURE pre_process_mtl_txn_tbl(
    p_item_attrib_rec IN     item_attributes_rec,
    px_mtl_txn_tbl    IN OUT NOCOPY mtl_txn_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_src_serial_flag        varchar2(1);
    l_dest_serial_flag       varchar2(1);
    l_create_update_flag     varchar2(1);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('pre_process_mtl_txn_tbl');

    IF p_item_attrib_rec.serial_control_code in (2,5) THEN
      l_src_serial_flag  := 'Y';
      l_dest_serial_flag := 'Y';
    ELSE
      l_src_serial_flag := 'N';
      IF p_item_attrib_rec.serial_control_code = 6 THEN
        l_dest_serial_flag := 'Y';
      ELSE
        l_dest_serial_flag := 'N';
      END IF;
    END IF;

    IF l_src_serial_flag = 'Y' AND l_dest_serial_flag = 'Y' THEN
      l_create_update_flag := 'U';
    ELSE
      l_create_update_flag := 'C';
    END IF;

    IF px_mtl_txn_tbl.count > 0 THEN
      FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
      LOOP
        px_mtl_txn_tbl(l_ind).src_serial_flag    := l_src_serial_flag;
        px_mtl_txn_tbl(l_ind).dest_serial_flag   := l_dest_serial_flag;
        px_mtl_txn_tbl(l_ind).create_update_flag := l_create_update_flag;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END pre_process_mtl_txn_tbl;


  PROCEDURE get_dflt_inv_location(
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
  END get_dflt_inv_location;

  PROCEDURE create_inv_negative_instance(
    px_mtl_txn_rec   IN OUT NOCOPY mtl_txn_rec,
    p_quantity       IN     number,
    px_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS
    l_instance_rec      csi_datastructures_pub.instance_rec;
    l_parties_tbl       csi_datastructures_pub.party_tbl;
    l_pty_accts_tbl     csi_datastructures_pub.party_account_tbl;
    l_org_units_tbl     csi_datastructures_pub.organization_units_tbl;
    l_ea_values_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_tbl       csi_datastructures_pub.pricing_attribs_tbl;
    l_assets_tbl        csi_datastructures_pub.instance_asset_tbl;

    l_internal_party_id number;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('create_inv_negative_instance');

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

    l_instance_rec.inventory_item_id      := px_mtl_txn_rec.inventory_item_id;
    l_instance_rec.inventory_revision     := px_mtl_txn_rec.revision;
    l_instance_rec.inv_subinventory_name  := px_mtl_txn_rec.subinventory_code;
    -- this is always a non serial instance
    l_instance_rec.serial_number          := fnd_api.g_miss_char;
    l_instance_rec.lot_number             := px_mtl_txn_rec.lot_number;
    l_instance_rec.quantity               := p_quantity;
    l_instance_rec.active_start_date      := sysdate;
    l_instance_rec.active_end_date        := null;
    l_instance_rec.unit_of_measure        := px_mtl_txn_rec.primary_uom;
    l_instance_rec.location_type_code     := 'INVENTORY';
    get_dflt_inv_location(
      p_subinventory_code => px_mtl_txn_rec.subinventory_code,
      p_organization_id   => px_mtl_txn_rec.organization_id,
      x_location_id       => l_instance_rec.location_id,
      x_return_status     => l_return_status);
    l_instance_rec.instance_usage_code    := 'IN_INVENTORY';
    l_instance_rec.inv_organization_id    := px_mtl_txn_rec.organization_id;
    l_instance_rec.vld_organization_id    := px_mtl_txn_rec.organization_id;
    l_instance_rec.inv_locator_id         := px_mtl_txn_rec.locator_id;
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

    -- creation of negative quantity inventory instance
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
      p_txn_rec               => px_txn_rec,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data );

    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      raise fnd_api.g_exc_error;
    END IF;

    px_mtl_txn_rec.instance_id        := l_instance_rec.instance_id;
    px_mtl_txn_rec.object_version_num := l_instance_rec.object_version_number;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_inv_negative_instance;


  PROCEDURE decrement_inventory_instnace(
    p_instance_id    IN     number,
    p_quantity       IN     number,
    px_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_instance_rec        csi_datastructures_pub.instance_rec;
    l_party_tbl           csi_datastructures_pub.party_tbl;
    l_party_acct_tbl      csi_datastructures_pub.party_account_tbl;
    l_inst_asset_tbl      csi_datastructures_pub.instance_asset_tbl;
    l_ext_attrib_val_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    l_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_inst_id_lst         csi_datastructures_pub.id_tbl;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count           number;
    l_msg_data            varchar2(2000);

  BEGIN

    x_return_status       := fnd_api.g_ret_sts_success;

    api_log('decrement_inventory_instnace');

    l_instance_rec.instance_id := p_instance_id;

    /*Code modified/added START for bug 4865052*/

    SELECT object_version_number,
           quantity - p_quantity,
           active_end_date
    INTO   l_instance_rec.object_version_number,
           l_instance_rec.quantity,
           l_instance_rec.active_end_date
    FROM   csi_item_instances
    WHERE  instance_id = l_instance_rec.instance_id;

    IF l_instance_rec.active_end_date is not null  THEN
      l_instance_rec.active_end_date := null;
      BEGIN
        SELECT instance_status_id
        INTO   l_instance_rec.instance_status_id
        FROM   csi_instance_statuses
        WHERE  name = fnd_profile.value('csi_default_instance_status');
      EXCEPTION
        WHEN no_data_found THEN
          l_instance_rec.instance_status_id := 510;
      END;
    END IF;
    /*Code modified/added END for bug 4865052*/

    csi_t_gen_utility_pvt.dump_csi_instance_rec(
      p_csi_instance_rec => l_instance_rec);

    record_time('Start');

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'update_item_instance',
      p_pkg_name => 'csi_item_instance_pub');

    /* decrement the inventory source instance */
    csi_item_instance_pub.update_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_instance_rec,
      p_ext_attrib_values_tbl => l_ext_attrib_val_tbl,
      p_party_tbl             => l_party_tbl,
      p_account_tbl           => l_party_acct_tbl,
      p_pricing_attrib_tbl    => l_pricing_attribs_tbl,
      p_org_assignments_tbl   => l_org_units_tbl,
      p_txn_rec               => px_txn_rec,
      p_asset_assignment_tbl  => l_inst_asset_tbl,
      x_instance_id_lst       => l_inst_id_lst,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    -- For Bug 4057183
    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      raise fnd_api.g_exc_error;
    END IF;

    record_time('End');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END decrement_inventory_instnace;

  PROCEDURE decrement_inventory_instances(
    p_item_attrib_rec IN     item_attributes_rec,
    p_mtl_txn_tbl     IN OUT NOCOPY mtl_txn_tbl,
    px_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('decrement_inventory_instances');

    IF p_mtl_txn_tbl.count > 0 THEN

      IF p_item_attrib_rec.serial_control_code = 6 THEN

        IF nvl(p_mtl_txn_tbl(1).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          decrement_inventory_instnace(
            p_instance_id    => p_mtl_txn_tbl(1).instance_id,
            p_quantity       => px_txn_rec.transaction_quantity,
            px_txn_rec       => px_txn_rec,
            x_return_status  => l_return_status);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;
        ELSE
          IF p_mtl_txn_tbl(1).negative_instance_flag = 'Y' THEN

            create_inv_negative_instance(
              px_mtl_txn_rec   => p_mtl_txn_tbl(1),
              p_quantity       => (-1)*(px_txn_rec.transaction_quantity),
              px_txn_rec       => px_txn_rec,
              x_return_status  => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;
        END IF;

      ELSE
        FOR l_ind IN p_mtl_txn_tbl.FIRST .. p_mtl_txn_tbl.LAST
        LOOP
          IF p_mtl_txn_tbl(l_ind).create_update_flag = 'C' THEN

            IF nvl(p_mtl_txn_tbl(l_ind).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              decrement_inventory_instnace(
                p_instance_id    => p_mtl_txn_tbl(l_ind).instance_id,
                p_quantity       => p_mtl_txn_tbl(l_ind).primary_quantity,
                px_txn_rec       => px_txn_rec,
                x_return_status  => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            ELSE
              IF p_mtl_txn_tbl(1).negative_instance_flag = 'Y' THEN

                create_inv_negative_instance(
                  px_mtl_txn_rec   => p_mtl_txn_tbl(l_ind),
                  p_quantity       => (-1)*(p_mtl_txn_tbl(l_ind).primary_quantity),
                  px_txn_rec       => px_txn_rec,
                  x_return_status  => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

              END IF;
            END IF;

          END IF;
        END LOOP;
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END decrement_inventory_instances;

  PROCEDURE initialize_txn_details(
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_eav_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl)
  IS
    l_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_dtl_tbl     csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_party_acct_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl    csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_eav_tbl          csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl;
  BEGIN
    api_log('initialize_txn_details');
    px_txn_line_rec       := l_txn_line_rec;
    px_txn_line_dtl_tbl   := l_txn_line_dtl_tbl;
    px_txn_party_tbl      := l_txn_party_tbl;
    px_txn_party_acct_tbl := l_txn_party_acct_tbl;
    px_txn_org_assgn_tbl  := l_txn_org_assgn_tbl;
    px_txn_eav_tbl        := l_txn_eav_tbl;
    px_txn_ii_rltns_tbl   := l_txn_ii_rltns_tbl;
  END initialize_txn_details;


  PROCEDURE pre_process_txn_line_dtl(
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    p_item_attrib_rec     IN     item_attributes_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('pre_process_txn_line_dtl');
    l_tld_tbl := px_txn_line_dtl_tbl;

    IF l_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        -- init error code with 'N' -- used as a matched_flag in this case
        l_tld_tbl(l_ind).error_code := 'N';

        -- source_txn_line_details -- to match with the children
        l_tld_tbl(l_ind).source_txn_line_detail_id := l_ind;

        IF nvl(l_tld_tbl(l_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          -- derive all the information (serial, lot, locator, rev etc ).
          null;
        ELSE
          IF nvl(l_tld_tbl(l_ind).serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
            -- get the instance_id for the item serial comb
            null;
          END IF;
        END IF;
      END LOOP;
    END IF;

    px_txn_line_dtl_tbl := l_tld_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END pre_process_txn_line_dtl;

  PROCEDURE split_tld_one_each(
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_dtl_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_eav_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_ii_rltns_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pd_tbl              csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pa_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_oa_tbl              csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_eav_tbl             csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_iir_tbl             csi_t_datastructures_grp.txn_ii_rltns_tbl;

    s_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;
    s_pd_tbl              csi_t_datastructures_grp.txn_party_detail_tbl;
    s_pa_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    s_oa_tbl              csi_t_datastructures_grp.txn_org_assgn_tbl;
    s_eav_tbl             csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    s_iir_tbl             csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_tld_ind             binary_integer := 0; -- new index
    l_pd_ind              binary_integer := 0;
    l_pa_ind              binary_integer := 0;
    l_oa_ind              binary_integer := 0;
    l_eav_ind             binary_integer := 0;
    l_iir_ind             binary_integer := 0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('split_tld_one_each');

    l_tld_tbl := px_txn_line_dtl_tbl;
    l_pd_tbl  := px_txn_party_dtl_tbl;
    l_pa_tbl  := px_txn_party_acct_tbl;
    l_oa_tbl  := px_txn_org_assgn_tbl;
    l_eav_tbl := px_txn_eav_tbl;
    l_iir_tbl := px_txn_ii_rltns_tbl;

    IF l_tld_tbl.COUNT > 0 THEN
      FOR tld_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        IF l_tld_tbl(tld_ind).quantity > 1 THEN
          FOR i IN 1..(l_tld_tbl(tld_ind).quantity - 1)
          LOOP
            -- create new tld record with qty
            l_tld_ind := l_tld_tbl.COUNT + 1;
            l_tld_tbl(l_tld_ind) := l_tld_tbl(tld_ind);
            l_tld_tbl(l_tld_ind).quantity := 1;

            -- create party records
            IF l_pd_tbl.COUNT > 0 THEN
              FOR pd_ind IN l_pd_tbl.FIRST .. l_pd_tbl.LAST
              LOOP
                IF l_pd_tbl(pd_ind).txn_line_details_index = tld_ind THEN
                  l_pd_ind := l_pd_tbl.COUNT + 1;
                  l_pd_tbl(l_pd_ind) := l_pd_tbl(pd_ind);
                  l_pd_tbl(pd_ind).txn_line_details_index := l_tld_ind;

                  -- create party account
                  IF l_pa_tbl.COUNT > 0 THEN
                    FOR pa_ind IN l_pa_tbl.FIRST .. l_pa_tbl.LAST
                    LOOP
                      IF l_pa_tbl(pa_ind).txn_party_details_index = pd_ind THEN
                        l_pa_ind := l_pa_tbl.COUNT + 1;
                        l_pa_tbl(l_pa_ind) := l_pa_tbl(pa_ind);
                        l_pa_tbl(l_pa_ind).txn_party_details_index := l_pd_ind;
                      END IF;
                    END LOOP; -- pa_tbl loop
                  END IF;

                END IF;
              END LOOP; -- pd_tbl loop
            END IF;
          END LOOP; -- 1..(qty-1) loop
          l_tld_tbl(tld_ind).quantity := 1;
        END IF;
      END LOOP; -- tld_tbl loop
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_tld_one_each;

  PROCEDURE sync_serials(
    p_mtl_txn_tbl         IN     mtl_txn_tbl,
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_mtl_tbl             mtl_txn_tbl;
    l_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;
    l_m_tld_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_m_ind               binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('sync_serials');

    l_mtl_tbl := p_mtl_txn_tbl;
    l_tld_tbl := px_txn_line_dtl_tbl;

    debug('Parse I  - eliminate cases where serials match');
    IF l_tld_tbl.COUNT > 0 THEN
      FOR t_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        IF l_tld_tbl(t_ind).error_code = 'N' THEN
          IF l_mtl_tbl.COUNT > 0 THEN
            FOR m_ind IN l_mtl_tbl.FIRST .. l_mtl_tbl.LAST
            LOOP
              debug('  TLD ID :'||l_tld_tbl(t_ind).source_txn_line_detail_id||
                    '  Serial :'||l_mtl_tbl(m_ind).serial_number||
                    '  Instance :'||l_mtl_tbl(m_ind).instance_id);
              IF l_mtl_tbl(m_ind).match_flag = 'N' THEN
                IF (l_tld_tbl(t_ind).serial_number = l_mtl_tbl(m_ind).serial_number)
                    OR
                   (l_tld_tbl(t_ind).instance_id = l_mtl_tbl(m_ind).instance_id)
                THEN
                  /* using this error_code column as a marked flag */
                  l_tld_tbl(t_ind).error_code := 'Y';
                  l_mtl_tbl(m_ind).match_flag := 'Y';

                  l_tld_tbl(t_ind).serial_number := l_mtl_tbl(m_ind).serial_number;
                  l_tld_tbl(t_ind).instance_id   := l_mtl_tbl(m_ind).instance_id;

                  --
                  debug('    Match');
                  exit;
                ELSE
                  debug('    NO Match');
                END IF;
              END IF;
            END LOOP;
          END IF;
        END IF; -- error_flag = 'N' -- unmatched tld
      END LOOP;
    END IF;

    /* the following logic assumes that the tld table is in quantity each */
    debug('Parse II - match based on quantity');
    IF l_tld_tbl.COUNT > 0 THEN
      FOR t_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        IF l_tld_tbl(t_ind).error_code = 'N' THEN
          IF l_mtl_tbl.COUNT > 0 THEN
            FOR m_ind IN l_mtl_tbl.FIRST .. l_mtl_tbl.LAST
            LOOP

              debug('  TLD ID :'||l_tld_tbl(t_ind).source_txn_line_detail_id||
                    '  Serial :'||l_mtl_tbl(m_ind).serial_number||
                    '  Instance :'||l_mtl_tbl(m_ind).instance_id);
              IF l_mtl_tbl(m_ind).match_flag = 'N' THEN
                l_tld_tbl(t_ind).error_code := 'Y';
                l_mtl_tbl(m_ind).match_flag := 'Y';

                l_tld_tbl(t_ind).mfg_serial_number_flag := 'Y';
                l_tld_tbl(t_ind).serial_number := l_mtl_tbl(m_ind).serial_number;
                l_tld_tbl(t_ind).instance_id   := l_mtl_tbl(m_ind).instance_id;
                l_tld_tbl(t_ind).lot_number    := l_mtl_tbl(m_ind).lot_number;

                debug('    Match');
                exit;
              END IF;

            END LOOP; -- mtl table loop
          END IF;
        END IF;
      END LOOP; -- tld loop
    END IF;

    --rebuild the tld_tbl
    IF l_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        IF l_tld_tbl(l_ind).error_code = 'Y' THEN

          l_m_ind := l_m_ind + 1;
          l_m_tld_tbl(l_m_ind) := l_tld_tbl(l_ind);

          debug('Instance_ID :'||l_m_tld_tbl(l_m_ind).instance_id);

        END IF;
      END LOOP;
    END IF;

    px_txn_line_dtl_tbl := l_m_tld_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END sync_serials;

  PROCEDURE sync_lots(
    p_mtl_txn_tbl         IN     mtl_txn_tbl,
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_mtl_tbl             mtl_txn_tbl;
    l_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;
    l_m_tld_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_m_ind               binary_integer := 0;

    t_n_ind               binary_integer := 0;
    l_remain_qty          number         := 0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('sync_lots');

    l_mtl_tbl := p_mtl_txn_tbl;
    l_tld_tbl := px_txn_line_dtl_tbl;

    debug('Parse I - Match by the lot number.');

    IF l_tld_tbl.COUNT > 0 THEN
      FOR t_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        -- unmatched tld
        IF l_tld_tbl(t_ind).error_code = 'N' THEN
          IF l_mtl_tbl.COUNT > 0 THEN
            FOR m_ind IN l_mtl_tbl.FIRST .. l_mtl_tbl.LAST
            LOOP
              debug('  TLD ID :'||l_tld_tbl(t_ind).source_txn_line_detail_id||
                    '  Lot :'||l_mtl_tbl(m_ind).lot_number||
                    '  Instance :'||l_mtl_tbl(m_ind).instance_id);
              -- unmatched mtl
              IF l_mtl_tbl(m_ind).match_flag = 'N' THEN
                IF (l_tld_tbl(t_ind).lot_number = l_mtl_tbl(m_ind).lot_number)
                    OR
                   (l_tld_tbl(t_ind).instance_id = l_mtl_tbl(m_ind).instance_id)
                THEN

                  /* this functionality will be used when there is a user entered */
                  /* txn detail for this source line                              */
                  /* code needs to be expanded                                    */

                  null;
                ELSE
                  debug('    No Match');
                END IF;
              END IF;
            END LOOP; --mtl_tbl loop
          END IF;
        END IF;
      END LOOP; --tld_tbl loop;
    END IF;

    debug('Parse II - Match by the lot quantity.');
    IF l_mtl_tbl.COUNT > 0 THEN
      FOR m_ind IN l_mtl_tbl.FIRST .. l_mtl_tbl.LAST
      LOOP
        -- unmatched mtl
        IF l_mtl_tbl(m_ind).match_flag = 'N' THEN

          IF l_tld_tbl.COUNT > 0 THEN
            FOR t_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
            LOOP
              debug('  TLD ID :'||l_tld_tbl(t_ind).source_txn_line_detail_id||
                    '  Lot :'||l_mtl_tbl(m_ind).lot_number||
                    '  Instance :'||l_mtl_tbl(m_ind).instance_id);

              -- unmatched tld
              IF l_tld_tbl(t_ind).error_code = 'N' THEN

                IF (l_tld_tbl(t_ind).quantity = l_mtl_tbl(m_ind).primary_quantity)
                THEN
                  debug('    Match');

                  l_tld_tbl(t_ind).error_code  := 'Y';
                  l_mtl_tbl(m_ind).match_flag  := 'Y';
                  l_tld_tbl(t_ind).lot_number  := l_mtl_tbl(m_ind).lot_number;
                  l_tld_tbl(t_ind).instance_id := fnd_api.g_miss_num;
                  l_tld_tbl(t_ind).instance_exists_flag := 'N';

                  exit;

                ELSE
                  debug('    No Match');
                  -- split it to primary_qty and the rest.

                  l_remain_qty := l_tld_tbl(t_ind).quantity - l_mtl_tbl(m_ind).primary_quantity;

                  -- create a new tld with the remain qty
                  t_n_ind := l_tld_tbl.COUNT + 1;

                  l_tld_tbl(t_n_ind) := l_tld_tbl(t_ind);
                  l_tld_tbl(t_ind).error_code  := 'N';
                  l_tld_tbl(t_n_ind).quantity  := l_remain_qty;
                  l_tld_tbl(t_n_ind).source_txn_line_detail_id := l_tld_tbl(t_ind).txn_line_detail_id;

                  -- mark the current tld as matched
                  l_tld_tbl(t_ind).error_code  := 'Y';
                  l_mtl_tbl(m_ind).match_flag  := 'Y';
                  l_tld_tbl(t_ind).lot_number  := l_mtl_tbl(m_ind).lot_number;
                  l_tld_tbl(t_ind).quantity    := l_mtl_tbl(m_ind).primary_quantity;
                  l_tld_tbl(t_ind).instance_id := fnd_api.g_miss_num;
                  l_tld_tbl(t_ind).instance_exists_flag := 'N';

                  exit;

                END IF;
              END IF;
            END LOOP; --tld_tbl loop
          END IF;
        END IF;
      END LOOP; --mtl_tbl loop;
    END IF;

    --rebuild the tld_tbl
    IF l_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
      LOOP
        IF l_tld_tbl(l_ind).error_code = 'Y' THEN

          l_m_ind := l_m_ind + 1;
          l_m_tld_tbl(l_m_ind) := l_tld_tbl(l_ind);

          debug('Instance_ID :'||l_m_tld_tbl(l_m_ind).instance_id);

        END IF;
      END LOOP;
    END IF;

    px_txn_line_dtl_tbl := l_m_tld_tbl;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END sync_lots;

  PROCEDURE sync_txn_dtl_and_mtl_txn(
    p_mtl_txn_tbl         IN     mtl_txn_tbl,
    p_item_attrib_rec     IN     item_attributes_rec,
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_dtl_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_eav_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_ii_rltns_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pd_tbl              csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pa_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_oa_tbl              csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_eav_tbl             csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_iir_tbl             csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('sync_txn_dtl_and_mtl_txn');

    l_tld_tbl := px_txn_line_dtl_tbl;
    l_pd_tbl  := px_txn_party_dtl_tbl;
    l_pa_tbl  := px_txn_party_acct_tbl;
    l_oa_tbl  := px_txn_org_assgn_tbl;
    l_eav_tbl := px_txn_eav_tbl;
    l_iir_tbl := px_txn_ii_rltns_tbl;

    pre_process_txn_line_dtl(
      px_txn_line_dtl_tbl   => l_tld_tbl,
      p_item_attrib_rec     => p_item_attrib_rec,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_mtl_txn_tbl.COUNT > 0 THEN

      -- if serialized match by serial/inst combination
      IF p_item_attrib_rec.serial_control_code in (2, 5, 6) THEN
        -- we need to stamp the serial attribute in the instance creation
        -- sync serials

        sync_serials(
          p_mtl_txn_tbl         => p_mtl_txn_tbl,
          px_txn_line_dtl_tbl   => l_tld_tbl,
          x_return_status       => l_return_status);

      ELSE
        IF p_item_attrib_rec.lot_control_code = 2 THEN
          -- we need to group and stamp the lot attribute in instnace creation
          -- sync_lots

          sync_lots(
            p_mtl_txn_tbl         => p_mtl_txn_tbl,
            px_txn_line_dtl_tbl   => l_tld_tbl,
            x_return_status       => l_return_status);

        ELSE
          null;
          -- just verify that the quantity that is in sync with the mtl txn qty
          -- sync_quantity
        END IF;
      END IF;

      -- if lot match by lot/inst

      -- if locator match by locator

      -- by qty

      -- split tld to match the mtl tbl (most frequent case) make sure it works
    END IF;

    px_txn_line_dtl_tbl   := l_tld_tbl;
    px_txn_party_dtl_tbl  := l_pd_tbl;
    px_txn_party_acct_tbl := l_pa_tbl;
    px_txn_org_assgn_tbl  := l_oa_tbl;
    px_txn_eav_tbl        := l_eav_tbl;
    px_txn_ii_rltns_tbl   := l_iir_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END sync_txn_dtl_and_mtl_txn;


  PROCEDURE default_owner_pty_and_acct(
    p_instance_id         IN     number,
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_dtl_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_owner_party_acct_id  number;
    l_owner_party_id       number;
    l_party_source_table   varchar2(80);

    l_pt_ind               binary_integer := 0;
    l_pa_ind               binary_integer := 0;

  BEGIN

    api_log('default_owner_pty_and_acct');
    x_return_status := fnd_api.g_ret_sts_success;

    IF px_txn_line_dtl_tbl.COUNT > 0 THEN

      SELECT owner_party_account_id,
             owner_party_id
      INTO   l_owner_party_acct_id,
             l_owner_party_id
      FROM   csi_item_instances
      WHERE  instance_id = p_instance_id;


      IF l_owner_party_id is not null THEN

        SELECT party_source_table
        INTO   l_party_source_table
        FROM   csi_i_parties
        WHERE  instance_id = p_instance_id
        AND    relationship_type_code = 'OWNER';

        FOR l_ind IN px_txn_line_dtl_tbl.FIRST .. px_txn_line_dtl_tbl.LAST
        LOOP

          -- check if owner is there
          l_pt_ind := px_txn_party_dtl_tbl.COUNT + 1;

          px_txn_party_dtl_tbl(l_pt_ind).txn_party_detail_id := fnd_api.g_miss_num;
          px_txn_party_dtl_tbl(l_pt_ind).txn_line_detail_id  := fnd_api.g_miss_num;
          px_txn_party_dtl_tbl(l_pt_ind).party_source_table  := l_party_source_table;
          px_txn_party_dtl_tbl(l_pt_ind).party_source_id     := l_owner_party_id;
          px_txn_party_dtl_tbl(l_pt_ind).relationship_type_code := 'OWNER';
          px_txn_party_dtl_tbl(l_pt_ind).contact_flag        := 'N';
          px_txn_party_dtl_tbl(l_pt_ind).txn_line_details_index := l_ind;

          IF l_owner_party_acct_id IS NOT null THEN

            l_pa_ind := px_txn_party_acct_tbl.COUNT + 1;

            px_txn_party_acct_tbl(l_pa_ind).txn_account_detail_id   := fnd_api.g_miss_num;
            px_txn_party_acct_tbl(l_pa_ind).txn_party_detail_id     := fnd_api.g_miss_num;
            px_txn_party_acct_tbl(l_pa_ind).account_id              := l_owner_party_acct_id;
            px_txn_party_acct_tbl(l_pa_ind).relationship_type_code  := 'OWNER';
            px_txn_party_acct_tbl(l_pa_ind).txn_party_details_index := l_pt_ind;

          END IF;

        END LOOP;
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END default_owner_pty_and_acct;

  --
  --
  --
  PROCEDURE process_cz_txn_details(
    p_config_session_keys  IN  csi_utility_grp.config_session_keys,
    p_instance_id          IN  number,
    x_instance_tbl         OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_source_hdr_rec       source_header_rec;
    l_source_line_rec      source_line_rec;
    l_src_instance_key     csi_utility_grp.config_instance_key;

    l_csi_txn_rec          csi_datastructures_pub.transaction_rec;

    l_tl_rec               csi_t_datastructures_grp.txn_line_rec;
    l_td_tbl               csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pd_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pa_tbl               csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_oa_tbl               csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ea_tbl               csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_ir_tbl               csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_pr_tbl               csi_datastructures_pub.pricing_attribs_tbl;
    l_sy_tbl               csi_t_datastructures_grp.txn_systems_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_return_message       varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('process_cz_txn_details');

    IF p_config_session_keys.COUNT > 0 THEN
      FOR l_ind IN p_config_session_keys.FIRST .. p_config_session_keys.LAST
      LOOP

        -- initialize txn detail set
        initialize_txn_details(
          px_txn_line_rec        => l_tl_rec,
          px_txn_line_dtl_tbl    => l_td_tbl,
          px_txn_party_tbl       => l_pd_tbl,
          px_txn_party_acct_tbl  => l_pa_tbl,
          px_txn_org_assgn_tbl   => l_oa_tbl,
          px_txn_eav_tbl         => l_ea_tbl,
          px_txn_ii_rltns_tbl    => l_ir_tbl);

        get_cz_txn_details(
          p_config_session_key   => p_config_session_keys(l_ind),
          x_txn_line_rec         => l_tl_rec,
          x_txn_line_dtl_tbl     => l_td_tbl,
          x_txn_party_tbl        => l_pd_tbl,
          x_txn_party_acct_tbl   => l_pa_tbl,
          x_txn_org_assgn_tbl    => l_oa_tbl,
          x_txn_eav_tbl          => l_ea_tbl,
          x_txn_ii_rltns_tbl     => l_ir_tbl,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_td_tbl.COUNT > 0 THEN

          -- get the source instance key
          FOR l_td_ind IN l_td_tbl.FIRST .. l_td_tbl.LAST
          LOOP
            IF l_td_tbl(l_td_ind).source_transaction_flag = 'Y' THEN

              l_src_instance_key.inst_hdr_id  := l_td_tbl(l_td_ind).config_inst_hdr_id;
              l_src_instance_key.inst_rev_num := l_td_tbl(l_td_ind).config_inst_rev_num;
              l_src_instance_key.inst_item_id := l_td_tbl(l_td_ind).config_inst_item_id;
              l_src_instance_key.inst_baseline_rev_num := l_td_tbl(l_td_ind).config_inst_baseline_rev_num;

              -- to get the item attributes I need to pass this
              l_source_line_rec.inventory_item_id := l_td_tbl(l_td_ind).inventory_item_id;
              l_source_line_rec.organization_id := l_td_tbl(l_td_ind).inv_organization_id;

            END IF;

              /* Moved this code from IF clause above after all the assignments as part of
                 fix for Bug 2730573 */

              /* moved this code out from interface IB */
              BEGIN
                SELECT instance_id
                INTO   l_td_tbl(l_td_ind).instance_id
                FROM   csi_item_instances
                WHERE  config_inst_hdr_id = l_td_tbl(l_td_ind).config_inst_hdr_id
                AND    config_inst_item_id = l_td_tbl(l_td_ind).config_inst_item_id;

                l_td_tbl(l_td_ind).instance_exists_flag := 'Y';

              EXCEPTION
                WHEN no_data_found THEN
                  l_td_tbl(l_td_ind).instance_id          := fnd_api.g_miss_num;
                  l_td_tbl(l_td_ind).instance_exists_flag := 'N';
              END;
             /* End of fix for Bug  2730573 */

          END LOOP;

          -- filter relations

          filter_relations(
            p_instance_key         => l_src_instance_key,
            p_transaction_line_id  => l_tl_rec.transaction_line_id,
            px_txn_ii_rltns_tbl    => l_ir_tbl,
            x_return_status        => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

           csi_t_utilities_pvt.convert_ids_to_index(
             px_line_dtl_tbl      => l_td_tbl,
             px_pty_dtl_tbl       => l_pd_tbl,
             px_pty_acct_tbl      => l_pa_tbl,
             px_ii_rltns_tbl      => l_ir_tbl,
             px_org_assgn_tbl     => l_oa_tbl,
             px_ext_attrib_tbl    => l_ea_tbl,
             px_txn_systems_tbl   => l_sy_tbl);

          --default owner party and account
          default_owner_pty_and_acct(
            p_instance_id         => p_instance_id,
            px_txn_line_dtl_tbl   => l_td_tbl,
            px_txn_party_dtl_tbl  => l_pd_tbl,
            px_txn_party_acct_tbl => l_pa_tbl,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_source_line_rec.fulfilled_date      := sysdate;
          l_source_hdr_rec.source_header_id     := l_src_instance_key.inst_hdr_id;
          l_source_hdr_rec.source_header_ref    := l_src_instance_key.inst_rev_num;
          l_source_line_rec.source_line_id      := l_src_instance_key.inst_item_id;
          l_source_line_rec.source_line_ref     := null;
          l_source_line_rec.source_table        := 'CONFIGURATOR';
          l_source_line_rec.batch_validate_flag := 'N';

          interface_ib(
            p_source_header_rec    => l_source_hdr_rec,
            p_source_line_rec      => l_source_line_rec,
            px_csi_txn_rec         => l_csi_txn_rec,
            px_txn_line_rec        => l_tl_rec,
            px_txn_line_dtl_tbl    => l_td_tbl,
            px_txn_party_tbl       => l_pd_tbl,
            px_txn_party_acct_tbl  => l_pa_tbl,
            px_txn_org_assgn_tbl   => l_oa_tbl,
            px_txn_eav_tbl         => l_ea_tbl,
            px_txn_ii_rltns_tbl    => l_ir_tbl,
            px_pricing_attribs_tbl => l_pr_tbl,
            x_return_status        => l_return_status,
            x_return_message       => l_return_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END process_cz_txn_details;
END csi_interface_pkg;

/
