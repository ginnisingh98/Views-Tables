--------------------------------------------------------
--  DDL for Package Body CSI_ORDER_SHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ORDER_SHIP_PUB" AS
/* $Header: csipiosb.pls 120.34.12010000.3 2009/03/18 08:45:44 dsingire ship $ */


  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF csi_t_gen_utility_pvt.g_debug_level > 0 THEN
      csi_t_gen_utility_pvt.add(p_message);
    END IF;
  END debug;

  PROCEDURE api_log(
    p_api_name  IN varchar2)
  IS
  BEGIN

    g_api_name := 'csi_order_ship_pub.'||p_api_name;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => p_api_name,
      p_pkg_name => 'csi_order_ship_pub');

  END api_log;

  PROCEDURE process_ato_options(
    p_order_line_rec   IN order_line_rec,
    x_return_status    OUT NOCOPY varchar2)
  IS
    CURSOR ato_option_cur(p_ato_line_id in number) IS
      SELECT oel.line_id
      FROM   mtl_system_items   msi,
             oe_order_lines_all oel
      WHERE  oel.ato_line_id                       = p_ato_line_id
      AND    oel.item_type_code                    = 'OPTION'
      AND    nvl(oel.cancelled_flag,'N')          <> 'Y'
      AND    msi.inventory_item_id                 = oel.inventory_item_id
      AND    msi.organization_id                   = p_order_line_rec.om_vld_org_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y'
      AND    nvl(msi.shippable_item_flag, 'N')     = 'Y';

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message       varchar2(2000);
    l_already_interfaced  varchar2(1);
    l_bypass              varchar2(1);

    l_error_code          number;
    l_message_id          number;
    l_error_rec           csi_datastructures_pub.transaction_error_rec;

  BEGIN

    api_log('process_ato_options');

    x_return_status := fnd_api.g_ret_sts_success;

    IF nvl(p_order_line_rec.ato_line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN

      l_bypass := nvl(fnd_profile.value('CSE_BYPASS_EVENT_QUEUE'), 'N');

      FOR ato_option_rec IN ato_option_cur(p_order_line_rec.ato_line_id)
      LOOP

        IF l_bypass = 'N' THEN

          debug('  Publishing CSISOFUL for option line :'||ato_option_rec.line_id);

          XNP_CSISOFUL_U.publish(
            xnp$order_line_id => ato_option_rec.line_id,
            x_message_id      => l_message_id,
            x_error_code      => l_error_code,
            x_error_message   => l_error_message);
        ELSE

          debug('  Invoking CSISOFUL for option line :'||ato_option_rec.line_id);

          l_error_rec.source_id           := ato_option_rec.line_id;
          l_error_rec.source_type         := 'CSISOFUL';
          l_error_rec.transaction_type_id := 51;

          csi_inv_txnstub_pkg.execute_trx_dpl(
            p_transaction_type  => 'CSISOFUL',
            p_transaction_id    => ato_option_rec.line_id,
            x_trx_return_status => l_return_status,
            x_trx_error_rec     => l_error_rec);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            csi_inv_trxs_pkg.log_csi_error(l_error_rec);
            l_return_status := fnd_api.g_ret_sts_success;
          END IF;

        END IF;

        csi_t_gen_utility_pvt.build_file_name(
          p_file_segment1 => 'csisoshp',
          p_file_segment2 => p_order_line_rec.inv_mtl_transaction_id);

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END process_ato_options;

  PROCEDURE create_dflt_td_from_ship(
    p_serial_code         IN            number,
    p_order_line_rec      IN            order_line_rec,
    p_trackable_parent    IN            boolean,
    px_order_shipment_tbl IN OUT NOCOPY order_shipment_tbl,
    x_transaction_line_id    OUT NOCOPY number,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_ship_tbl            order_shipment_tbl;

    l_c_ind               binary_integer := 0;
    l_c_tl_rec            csi_t_datastructures_grp.txn_line_rec ;
    l_c_tld_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_c_t_pty_tbl         csi_t_datastructures_grp.txn_party_detail_tbl ;
    l_c_t_pty_acct_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_c_t_oa_tbl          csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_c_t_ea_tbl          csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_c_t_sys_tbl         csi_t_datastructures_grp.txn_systems_tbl;
    l_c_t_iir_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

    l_msg_count           number;
    l_msg_data            varchar2(2000);
    l_instance_party_id   number;
    l_ip_account_id       number;
    l_end_loop            number;
    l_quantity            number;
    l_parent_ord_qty      number;
    l_total_qty           number := 0;

    l_satisfied           boolean := FALSE;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('create_dflt_td_from_ship');

    l_ship_tbl := px_order_shipment_tbl;

    /* Initialize the pl/sql tables */
    l_c_tld_tbl.delete;
    l_c_t_pty_tbl.delete;
    l_c_t_pty_acct_tbl.delete;
    l_c_t_oa_tbl.delete;
    l_c_t_ea_tbl.delete;
    l_c_t_sys_tbl.delete;
    l_c_t_iir_tbl.delete;

    -- assign values for the columns in Txn_line_rec
    l_c_tl_rec.transaction_line_id        := fnd_api.g_miss_num;
    l_c_tl_rec.source_transaction_id      := p_order_line_rec.order_line_id;
    l_c_tl_rec.source_transaction_type_id := g_txn_type_id;
    l_c_tl_rec.source_transaction_table   := 'WSH_DELIVERY_DETAILS';
    l_c_tl_rec.processing_status          := 'IN_PROCESS';
    l_c_tl_rec.object_version_number      := 1;

    BEGIN
      SELECT transaction_line_id
      INTO   l_c_tl_rec.transaction_line_id
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_table   = l_c_tl_rec.source_transaction_table
      AND    source_transaction_id      = l_c_tl_rec.source_transaction_id
      AND    source_transaction_type_id = l_c_tl_rec.source_transaction_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    IF l_ship_tbl.count > 0 THEN

      FOR s_ind in l_ship_tbl.FIRST .. l_ship_tbl.LAST
      LOOP

        IF p_serial_code <> 1 OR p_trackable_parent THEN
          l_end_loop := l_ship_tbl(s_ind).shipped_quantity;
          l_quantity := 1;
        ELSE

          IF nvl(p_order_line_rec.link_to_line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

            -- create tld records with respect to the parent/child ratio
            SELECT ordered_quantity
            INTO   l_parent_ord_qty
            FROM   oe_order_lines_all
            WHERE  line_id = p_order_line_rec.link_to_line_id;

            l_end_loop := l_parent_ord_qty;
            l_quantity := p_order_line_rec.ordered_quantity/l_parent_ord_qty;

          ELSE
            l_end_loop := 1;
            l_quantity := l_ship_tbl(s_ind).shipped_quantity;
          END IF;

        END IF;

        SELECT instance_party_id
        INTO   l_instance_party_id
        FROM   csi_i_parties
        WHERE  instance_id = l_ship_tbl(s_ind).instance_id
        AND    relationship_type_code = 'OWNER';

        BEGIN
          SELECT ip_account_id
          INTO   l_ip_account_id
          FROM   csi_ip_accounts
          WHERE  instance_party_id      = l_instance_party_id
          AND    relationship_type_code = 'OWNER';
        EXCEPTION
          WHEN no_data_found THEN
            l_ip_account_id := fnd_api.g_miss_num;
        END;

        l_satisfied := FALSE;

        FOR q_ind IN 1..l_end_loop
        LOOP

          IF p_serial_code = 1 AND NOT(p_trackable_parent)
             AND
             nvl(p_order_line_rec.link_to_line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
          THEN
            l_total_qty := l_total_qty + l_quantity;

            IF l_total_qty = l_ship_tbl(s_ind).shipped_quantity THEN
              l_satisfied := TRUE;
            ELSIF l_total_qty > l_ship_tbl(s_ind).shipped_quantity THEN
              l_quantity := l_ship_tbl(s_ind).shipped_quantity - (l_quantity*(q_ind-1));
              l_satisfied := TRUE;
            END IF;
          END IF;

          l_c_ind := l_c_ind + 1;

          -- assign values for the columns in txn_line_details_tbl
          l_c_tld_tbl(l_c_ind).instance_id             := l_ship_tbl(s_ind).instance_id;
          l_c_tld_tbl(l_c_ind).instance_exists_flag    := 'Y';
          l_c_tld_tbl(l_c_ind).source_transaction_flag := 'Y';
          l_c_tld_tbl(l_c_ind).sub_type_id             := g_dflt_sub_type_id ;
          l_c_tld_tbl(l_c_ind).inventory_item_id       := l_ship_tbl(s_ind).inventory_item_id;
          l_c_tld_tbl(l_c_ind).inv_organization_id     := l_ship_tbl(s_ind).organization_id;
          l_c_tld_tbl(l_c_ind).inventory_revision      := l_ship_tbl(s_ind).revision;
          l_c_tld_tbl(l_c_ind).item_condition_id       := fnd_api.g_miss_num;
          l_c_tld_tbl(l_c_ind).instance_type_code      := fnd_api.g_miss_char;
          l_c_tld_tbl(l_c_ind).unit_of_measure         := l_ship_tbl(s_ind).transaction_uom;
          l_c_tld_tbl(l_c_ind).serial_number           := l_ship_tbl(s_ind).serial_number;
          l_c_tld_tbl(l_c_ind).quantity                := l_quantity;
          l_c_tld_tbl(l_c_ind).lot_number              := l_ship_tbl(s_ind).lot_number;
          l_c_tld_tbl(l_c_ind).location_type_code      := 'HZ_PARTY_SITES';
          l_c_tld_tbl(l_c_ind).location_id             := p_order_line_rec.ship_to_party_site_id;
          l_c_tld_tbl(l_c_ind).sellable_flag           := 'Y';
          l_c_tld_tbl(l_c_ind).active_start_date       := sysdate;
          l_c_tld_tbl(l_c_ind).object_version_number   := 1;
          l_c_tld_tbl(l_c_ind).preserve_detail_flag    := 'Y';
          l_c_tld_tbl(l_c_ind).processing_status       := 'IN_PROCESS';

          IF p_serial_code <> 1 THEN
            l_c_tld_tbl(l_c_ind).mfg_serial_number_flag  := 'Y';
          ELSE
            l_c_tld_tbl(l_c_ind).mfg_serial_number_flag  := 'N';
          END IF;

          -- assign party record values
          l_c_t_pty_tbl(l_c_ind).instance_party_id      := l_instance_party_id;
          l_c_t_pty_tbl(l_c_ind).party_source_id        := l_ship_tbl(s_ind).party_id;
          l_c_t_pty_tbl(l_c_ind).party_source_table     := 'HZ_PARTIES';
          l_c_t_pty_tbl(l_c_ind).relationship_type_code := 'OWNER';
          l_c_t_pty_tbl(l_c_ind).contact_flag           := 'N';
          l_c_t_pty_tbl(l_c_ind).active_start_date      := sysdate;
          l_c_t_pty_tbl(l_c_ind).preserve_detail_flag   := 'Y';
          l_c_t_pty_tbl(l_c_ind).object_version_number  := 1;
          l_c_t_pty_tbl(l_c_ind).txn_line_details_index := l_c_ind;

          -- assign party account values
          l_c_t_pty_acct_tbl(l_c_ind).ip_account_id           := l_ip_account_id;
          l_c_t_pty_acct_tbl(l_c_ind).account_id              := l_ship_tbl(s_ind).party_account_id;
          l_c_t_pty_acct_tbl(l_c_ind).bill_to_address_id      := l_ship_tbl(s_ind).invoice_to_org_id;
          l_c_t_pty_acct_tbl(l_c_ind).ship_to_address_id      := l_ship_tbl(s_ind).ship_to_org_id;
          l_c_t_pty_acct_tbl(l_c_ind).relationship_type_code  := 'OWNER';
          l_c_t_pty_acct_tbl(l_c_ind).active_start_date       := sysdate;
          l_c_t_pty_acct_tbl(l_c_ind).preserve_detail_flag    := 'Y';
          l_c_t_pty_acct_tbl(l_c_ind).object_version_number   := 1;
          l_c_t_pty_acct_tbl(l_c_ind).txn_party_details_index := l_c_ind;

          -- assign org assignment values
          IF nvl(l_ship_tbl(s_ind).sold_from_org_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
          THEN

            l_c_t_oa_tbl(l_c_ind).txn_operating_unit_id  := fnd_api.g_miss_num;
            l_c_t_oa_tbl(l_c_ind).txn_line_detail_id     := fnd_api.g_miss_num;
            l_c_t_oa_tbl(l_c_ind).instance_ou_id         := fnd_api.g_miss_num;
            l_c_t_oa_tbl(l_c_ind).operating_unit_id      := l_ship_tbl(s_ind).sold_from_org_id;
            l_c_t_oa_tbl(l_c_ind).relationship_type_code := 'SOLD_FROM';
            l_c_t_oa_tbl(l_c_ind).active_start_date      := sysdate;
            l_c_t_oa_tbl(l_c_ind).preserve_detail_flag   := 'Y';
            l_c_t_oa_tbl(l_c_ind).txn_line_details_index := l_c_ind;
            l_c_t_oa_tbl(l_c_ind).object_version_number  := 1;
          END IF;

          -- assign the txn details in the shipping pl/sql table
          l_ship_tbl(s_ind).txn_dtls_qty   := l_c_tld_tbl(l_c_ind).quantity;
          l_ship_tbl(s_ind).instance_match := 'Y';
          l_ship_tbl(s_ind).quantity_match := 'Y';

          IF l_satisfied THEN
            exit;
          END IF;

        END LOOP;
      END LOOP;

      debug('  l_c_tld_tbl.count        :'||l_c_tld_tbl.count);
      debug('  l_c_t_pty_tbl.count      :'||l_c_t_pty_tbl.count);
      debug('  l_c_t_pty_acct_tbl.count :'||l_c_t_pty_acct_tbl.count);
      debug('  l_c_t_iir_tbl.count      :'||l_c_t_iir_tbl.count);
      debug('  l_c_t_oa_tbl.count       :'||l_c_t_oa_tbl.count);
      debug('  l_c_t_ea_tbl.count       :'||l_c_t_ea_tbl.count);
      debug('  l_c_t_sys_tbl.count      :'||l_c_t_sys_tbl.count);

      csi_t_txn_details_grp.create_transaction_dtls(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_none,
        px_txn_line_rec            => l_c_tl_rec,
        px_txn_line_detail_tbl     => l_c_tld_tbl,
        px_txn_party_detail_tbl    => l_c_t_pty_tbl,
        px_txn_pty_acct_detail_tbl => l_c_t_pty_acct_tbl,
        px_txn_ii_rltns_tbl        => l_c_t_iir_tbl,
        px_txn_org_assgn_tbl       => l_c_t_oa_tbl,
        px_txn_ext_attrib_vals_tbl => l_c_t_ea_tbl,
        px_txn_systems_tbl         => l_c_t_sys_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      x_transaction_line_id := l_c_tl_rec.transaction_line_id;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_dflt_td_from_ship;


  /* sync tld quantities with sales order quantity */
  PROCEDURE sync_tld_and_order(
    p_order_line_rec          IN order_line_rec,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_transaction_line_id     number;
    l_total_tld_quantity      number;
    l_diff_quantity           number;

    l_src_change_owner_to_code varchar2(1);
    l_src_change_owner         varchar2(1);

    l_c_tld_rec               csi_t_datastructures_grp.txn_line_detail_rec ;
    l_c_tpd_tbl               csi_t_datastructures_grp.txn_party_detail_tbl ;
    l_c_tpad_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_c_toa_tbl               csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_c_teav_tbl              csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_c_ts_tbl                csi_t_datastructures_grp.txn_systems_tbl;
    l_c_tiir_tbl              csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN

      SELECT transaction_line_id
      INTO   l_transaction_line_id
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_table = 'OE_ORDER_LINES_ALL'
      AND    source_transaction_id    = p_order_line_rec.order_line_id;

      SELECT sum(abs(quantity))
      INTO   l_total_tld_quantity
      FROM   csi_t_txn_line_details
      WHERE  transaction_line_id     = l_transaction_line_id
      AND    source_transaction_flag = 'Y';

      IF l_total_tld_quantity < p_order_line_rec.ordered_quantity THEN

        -- now sync the dif
        l_diff_quantity :=  p_order_line_rec.ordered_quantity - l_total_tld_quantity;
        debug('diff quantity :'|| l_diff_quantity);

        l_c_tld_rec.source_transaction_flag := 'Y';
        l_c_tld_rec.instance_exists_flag    := 'N';
        l_c_tld_rec.sub_type_id             := g_dflt_sub_type_id;
        l_c_tld_rec.transaction_line_id     := l_transaction_line_id;
        l_c_tld_rec.txn_line_detail_id      := fnd_api.g_miss_num;
        l_c_tld_rec.inventory_item_id       := p_order_line_rec.inv_item_id;
        l_c_tld_rec.inv_organization_id     := p_order_line_rec.inv_org_id;
        l_c_tld_rec.quantity                := l_diff_quantity;
        l_c_tld_rec.unit_of_measure         := p_order_line_rec.order_quantity_uom;
        l_c_tld_rec.object_version_number   := 1;
        l_c_tld_rec.processing_status       := 'SUBMIT';

        SELECT src_change_owner,
               src_change_owner_to_code
        INTO   l_src_change_owner,
               l_src_change_owner_to_code
        FROM   csi_ib_txn_types
        WHERE  sub_type_id = l_c_tld_rec.sub_type_id;

        IF l_src_change_owner = 'Y' AND l_src_change_owner_to_code = 'E' THEN

          l_c_tpd_tbl(1).txn_party_detail_id      := fnd_api.g_miss_num;

          SELECT party_id
          INTO   l_c_tpd_tbl(1).party_source_id
          FROM   hz_cust_accounts
          WHERE  cust_account_id = p_order_line_rec.customer_id;

          l_c_tpd_tbl(1).party_source_table       := 'HZ_PARTIES';
          l_c_tpd_tbl(1).relationship_type_code   := 'OWNER';
          l_c_tpd_tbl(1).contact_flag             := 'N';
          l_c_tpd_tbl(1).active_start_date        := sysdate;
          l_c_tpd_tbl(1).object_version_number    := 1;
          l_c_tpd_tbl(1).txn_line_details_index   := 1;


          l_c_tpad_tbl(1).txn_account_detail_id   := fnd_api.g_miss_num;
          l_c_tpad_tbl(1).account_id              := p_order_line_rec.customer_id;
          l_c_tpad_tbl(1).relationship_type_code  := 'OWNER';
          l_c_tpad_tbl(1).active_start_date       := sysdate;
          l_c_tpad_tbl(1).object_version_number   := 1;
          l_c_tpad_tbl(1).txn_party_details_index := 1;

        END IF;

        -- call api to create the transaction line details
        csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
          p_api_version              => 1.0 ,
          p_commit                   => fnd_api.g_false,
          p_init_msg_list            => fnd_api.g_true,
          p_validation_level         => fnd_api.g_valid_level_none,
          p_txn_line_dtl_index       => 1,
          p_txn_line_dtl_rec         => l_c_tld_rec,
          px_txn_party_dtl_tbl       => l_c_tpd_tbl,
          px_txn_pty_acct_detail_tbl => l_c_tpad_tbl,
          px_txn_ii_rltns_tbl        => l_c_tiir_tbl,
          px_txn_org_assgn_tbl       => l_c_toa_tbl,
          px_txn_ext_attrib_vals_tbl => l_c_teav_tbl,
          x_return_status            => l_return_status,
          x_msg_count                => l_msg_count,
          x_msg_data                 => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END sync_tld_and_order;

  /*--------------------------------------------------------------------*/
  /* This is the main procedure to interface the order and installation */
  /* details info in to oracle Install Base                             */
  /*--------------------------------------------------------------------*/
  PROCEDURE order_shipment(
    p_mtl_transaction_id   IN            number,
    p_message_id           IN            number,
    x_return_status           OUT NOCOPY varchar2,
    px_trx_error_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec)
  IS

    l_trx_detail_exist        boolean := FALSE;
    l_copy_trx_detail_exist   boolean := FALSE;

    l_partial_ship            boolean := FALSE;
    l_qty_ratio               number;
    l_split_ord_line_id       number;
    l_trx_type_id             number;
    l_internal_party_id       number;
    l_trx_line_id             number;
    x_msg_count               number;
    x_msg_data                varchar2(2000);

    x_order_shipment_tbl      order_shipment_tbl;
    x_txn_line_query_rec      csi_t_datastructures_grp.txn_line_query_rec  ;
    x_pricing_attb_tbl        csi_datastructures_pub.pricing_attribs_tbl;

    l_txn_line_query_rec      csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_dtl_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;
    l_txn_line_rec            csi_t_datastructures_grp.txn_line_rec;
    l_transaction_line_rec    csi_t_datastructures_grp.txn_line_rec;
    l_tmp_txn_line_rec        csi_t_datastructures_grp.txn_line_rec;
    l_order_line_rec          order_line_rec;
    l_trk_oe_line_tbl         oe_order_pub.line_tbl_type;
    l_trackable_parent        boolean := FALSE;

    l_txn_line_detail_tbl     csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_detail_tbl    csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_dtl_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_ext_attrib_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ext_attribs_tbl     csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_iea_values_tbl      csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl  ;
    l_txn_systems_tbl         csi_t_datastructures_grp.txn_systems_tbl;

    l_src_txn_line_rec        csi_t_datastructures_grp.txn_line_rec;
    l_new_txn_line_rec        csi_t_datastructures_grp.txn_line_rec;
    l_trx_rec                 csi_datastructures_pub.transaction_rec;

    l_copy_txn_line_rec       csi_t_datastructures_grp.txn_line_rec;

    x_trx_sub_type_rec        txn_sub_type_rec;
    x_txn_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    x_model_inst_tbl          model_inst_tbl;

    l_item_control_rec        csi_order_ship_pub.item_control_rec;
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(2000);
    l_temp_txn_ii_rltns_tbl   csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_t_ii_indx               NUMBER := 0;

    l_error_rec               csi_datastructures_pub.transaction_error_rec;
    l_parent_line_qty         NUMBER := fnd_api.g_miss_num;
    l_literal1   	      VARCHAR2(30) ;
    l_literal2   	      VARCHAR2(30) ;
    l_source_header_rec       csi_interface_pkg.source_header_rec;
    l_source_line_rec         csi_interface_pkg.source_line_rec;
    l_conv_to_prim_uom_req    VARCHAR2(1) := 'Y';
    --Added for bug 5194812--
    l_om_session_key            csi_utility_grp.config_session_key;
    l_macd_processing           BOOLEAN     := FALSE;


  BEGIN

    /* Standard Start of API savepoint */
    savepoint  order_shipment;

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;
    l_error_rec     := px_trx_error_rec;

    csi_t_gen_utility_pvt.build_file_name (
      p_file_segment1 => 'csisoshp',
      p_file_segment2 => p_mtl_transaction_id);

    api_log('order_shipment');

    debug('  Transaction Time   : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type   : Sales Order Shipment');
    debug('  Transaction ID     : '||p_mtl_transaction_id);

    l_error_rec.source_id     := p_mtl_transaction_id;

    /* this routine checks if ib is active */
    csi_utility_grp.check_ib_active;

    /* get internal party id */
    csi_utl_pkg.get_int_party(
      x_int_party_id  => l_internal_party_id,
      x_return_status => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    -- Get the order line details
    csi_utl_pkg.get_order_line_dtls(
      p_mtl_transaction_id => p_mtl_transaction_id,
      x_order_line_rec     => l_order_line_rec,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

--Code start for bug 5194812--
      l_om_session_key.session_hdr_id  := l_order_line_rec.config_header_id;
      l_om_session_key.session_rev_num := l_order_line_rec.config_rev_nbr;
      l_om_session_key.session_item_id := l_order_line_rec.configuration_id;
      --
      l_macd_processing := csi_interface_pkg.check_macd_processing
                               ( p_config_session_key => l_om_session_key,
                                 x_return_status      => l_return_status
                               );
--Code end for bug5194812--

    IF l_order_line_rec.mtl_action_id = 1 and l_order_line_rec.mtl_src_type_id = 8 THEN
      g_txn_type_id := 126;
    ELSE
      --- Added for bug 5194812
      IF l_macd_processing THEN
        g_txn_type_id := 401;
      ELSE
        g_txn_type_id := 51;
      END IF;
      --- Code end for bug 5194812
    END IF;


    dbms_application_info.set_client_info(l_order_line_rec.org_id);

    csi_utl_pkg.get_item_control_rec(
      p_mtl_txn_id        => p_mtl_transaction_id,
      x_item_control_rec  => l_item_control_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- assign the values to l_order_line_rec
    l_order_line_rec.inv_mtl_transaction_id := p_mtl_transaction_id;
    l_order_line_rec.internal_party_id      := l_internal_party_id;
    l_order_line_rec.serial_code            := l_item_control_rec.serial_control_code;
    l_order_line_rec.reservable_type        := l_item_control_rec.reservable_type;
    l_order_line_rec.negative_balances_code := l_item_control_rec.negative_balances_code;
    l_order_line_rec.bom_item_type          := l_item_control_rec.bom_item_type;
    l_order_line_rec.primary_uom            := l_item_control_rec.primary_uom_code;

    l_error_rec.source_header_ref        := l_order_line_rec.order_number;
    l_error_rec.source_header_ref_id     := l_order_line_rec.header_id;
    l_error_rec.source_line_ref          := l_order_line_rec.line_number;
    l_error_rec.source_line_ref_id       := l_order_line_rec.order_line_id;
    l_error_rec.inventory_item_id        := l_item_control_rec.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_item_control_rec.serial_control_code;
    l_error_rec.src_lot_ctrl_code        := l_item_control_rec.lot_control_code;
    l_error_rec.src_location_ctrl_code   := l_item_control_rec.locator_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_item_control_rec.revision_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_item_control_rec.ib_trackable_flag;

    IF NVL(l_order_line_rec.link_to_line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      csi_utl_pkg.get_link_to_line_id (
        x_link_to_line_id  => l_order_line_rec.link_to_line_id,
        x_return_status    => l_return_status );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

    END IF;

    -- check if there is any ib trackable children for the current order line
    csi_utl_pkg.get_ib_trackable_children(
      p_order_line_rec     => l_order_line_rec,
      x_trackable_line_tbl => l_trk_oe_line_tbl,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_trk_oe_line_tbl.COUNT > 0 THEN
      l_trackable_parent := TRUE;
    END IF;

    /* getting the default sub type id */
    csi_utl_pkg.get_dflt_sub_type_id(
      p_transaction_type_id  => g_txn_type_id,
      x_sub_type_id          => g_dflt_sub_type_id,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    csi_utl_pkg.get_sub_type_rec(
      p_sub_type_id        => g_dflt_sub_type_id,
      p_trx_type_id        => g_txn_type_id,
      x_trx_sub_type_rec   => x_trx_sub_type_rec,
      x_return_status      => l_return_status) ;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    debug('  transaction_type_id: '||x_trx_sub_type_rec.trx_type_id );
    debug('  default sub_type_id: '||x_trx_sub_type_rec.sub_type_id );

    /* assign the parameter for txn_line_rec */
    l_txn_line_rec.source_transaction_id       :=  l_order_line_rec.order_line_id;
    l_txn_line_rec.source_transaction_table    :=  'OE_ORDER_LINES_ALL';

    -- Check if txn details exist
    l_trx_detail_exist := csi_t_txn_details_grp.check_txn_details_exist(
                            p_txn_line_rec  => l_txn_line_rec );

    IF l_trx_detail_exist THEN

      debug('user entered installation details found.' );

      --sync source tld quantites with order line quantity
      sync_tld_and_order(
        p_order_line_rec => l_order_line_rec,
        x_return_status  => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      /*------------------------------------------------*/
      /* If the order line has a parent then create txn */
      /* line dtls in the parent/child order qty ratio  */
      /* -----------------------------------------------*/

      IF NVL(l_order_line_rec.link_to_line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

        debug('This is a child order line. Check model and cascade installation details.');

        csi_utl_pkg.get_qty_ratio(
          p_order_line_qty   => l_order_line_rec.ordered_quantity,
	  p_order_item_id    => l_order_line_rec.inv_item_id,
	  p_model_remnant_flag => l_order_line_rec.model_remnant_flag, --added for bug5096435
          p_link_to_line_id  => l_order_line_rec.link_to_line_id,
          x_qty_ratio        => l_qty_ratio ,
          x_return_status    => l_return_status );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

        csi_utl_pkg.cascade_txn_dtls(
          p_source_trx_id    => l_order_line_rec.order_line_id,
          p_source_trx_table => 'OE_ORDER_LINES_ALL',
          p_ratio            => l_qty_ratio,
          x_return_status    => x_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

      END IF;


      l_copy_txn_line_rec.source_transaction_id    :=  l_order_line_rec.order_line_id;
      l_copy_txn_line_rec.source_transaction_table :=  'WSH_DELIVERY_DETAILS';

      debug('Concurrency check - Is installation details copied already?' );

      -- Check if txn details exist
      l_copy_trx_detail_exist := csi_t_txn_details_grp.check_txn_details_exist(
                                   p_txn_line_rec  => l_copy_txn_line_rec );

      IF l_copy_trx_detail_exist THEN

        debug('  Yes it is.' );

        BEGIN
          SELECT transaction_line_id
          INTO   l_trx_line_id
          FROM   csi_t_transaction_lines
          WHERE  source_transaction_id    = l_copy_txn_line_rec.source_transaction_id
          AND    source_transaction_table = l_copy_txn_line_rec.source_transaction_table;

        EXCEPTION
          WHEN no_data_found THEN
            fnd_message.set_name('CSI','CSI_INT_TRX_LINE_MISSING');
            fnd_message.set_token('SOURCE_TRANSACTION_ID', l_copy_txn_line_rec.SOURCE_TRANSACTION_ID);
            fnd_message.set_token('SOURCE_TRANSACTION_TABLE',l_copy_txn_line_rec.SOURCE_TRANSACTION_TABLE);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
        END;

      ELSE

        debug('  No it is not. Copying installation details as WSH_DELIVERY_DETAILS.');

        --Parameters for the source order line
        l_src_txn_line_rec.source_transaction_id      := l_order_line_rec.order_line_id;
        l_src_txn_line_rec.source_transaction_table   := 'OE_ORDER_LINES_ALL';

        --Parameters for the new source trx rec
        l_new_txn_line_rec.source_transaction_id      := l_order_line_rec.order_line_id;
        l_new_txn_line_rec.source_transaction_table   := 'WSH_DELIVERY_DETAILS';
        l_new_txn_line_rec.source_transaction_type_id := g_txn_type_id;


        ---Added (Start) for m-to-m enhancements
        l_new_txn_line_rec.source_txn_header_id := l_order_line_rec.header_id ;
        ---Added (End) for m-to-m enhancements

        csi_t_txn_details_pvt.copy_transaction_dtls(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_true,
          p_validation_level      => fnd_api.g_valid_level_none,
          p_src_txn_line_rec      => l_src_txn_line_rec,
          px_new_txn_line_rec     => l_new_txn_line_rec,
          p_copy_parties_flag     => fnd_api.g_true,
          p_copy_pty_accts_flag   => fnd_api.g_true,
          p_copy_ii_rltns_flag    => fnd_api.g_true,
          p_copy_org_assgn_flag   => fnd_api.g_true,
          p_copy_ext_attribs_flag => fnd_api.g_true,
          p_copy_txn_systems_flag => fnd_api.g_true,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          g_api_name := 'csi_t_txn_details_pvt.copy_transaction_dtls';
          raise fnd_api.g_exc_error;
        END IF;

        l_trx_line_id :=  l_new_txn_line_rec.transaction_line_id;

        ---Added (Start) for m-to-m enhancements
        ---Now split the copied TLD's to one each.
        IF l_item_control_rec.serial_control_code <> 1  OR l_trackable_parent THEN

          debug('splitting the WSH txn details in to one each.' );

          -- shegde 2769321 oe_orderlines_all changed to wsh_delivery_details
          csi_utl_pkg.create_txn_dtls(
            p_source_trx_id    =>  l_order_line_rec.order_line_id,
            p_source_trx_table =>  'WSH_DELIVERY_DETAILS',
            x_return_status    =>  x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

        END IF;
        ---Added (End) for m-to-m enhancements

      END IF;

    ELSE -- installation details not entered

      debug('user entered installation details not found');

      /*----------------------------------------------------------------*/
      /* In case of option and config items, call cascade_model that    */
      /* will cascade the txn_line_details to option/ config lines      */
      /* from the txn line details entered for the top model            */
      /*----------------------------------------------------------------*/

      IF NVL(l_order_line_rec.top_model_line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

        debug('component of a pto/ato model. cascade installation details from top model.');

        csi_t_utilities_pvt.cascade_model(
          p_model_line_id    => l_order_line_rec.top_model_line_id,
          x_return_status    => l_return_status );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

        l_txn_line_rec.source_transaction_id       :=  l_order_line_rec.order_line_id;
        l_txn_line_rec.source_transaction_table    :=  'OE_ORDER_LINES_ALL';

        debug('check if installation details are cascaded from the model ?');

        -- Check if txn details exist
        l_trx_detail_exist := csi_t_txn_details_grp.check_txn_details_exist(
                                p_txn_line_rec  => l_txn_line_rec );

        IF l_trx_detail_exist THEN

          debug('  yes. cascaded from top model.');

          /*------------------------------------------------*/
          /* If the order line has a parent then create txn */
          /* line dtls in the parent/child order qty ratio  */
          /* -----------------------------------------------*/

          IF NVL(l_order_line_rec.link_to_line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

            csi_utl_pkg.get_qty_ratio(
              p_order_line_qty   => l_order_line_rec.ordered_quantity,
	      p_order_item_id    => l_order_line_rec.inv_item_id,
	      p_model_remnant_flag => l_order_line_rec.model_remnant_flag, --added for bug5096435
              p_link_to_line_id  => l_order_line_rec.link_to_line_id,
              x_qty_ratio        => l_qty_ratio ,
              x_return_status    => l_return_status );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

            csi_utl_pkg.cascade_txn_dtls(
              p_source_trx_id    => l_order_line_rec.order_line_id,
              p_source_trx_table => 'OE_ORDER_LINES_ALL',
              p_ratio            => l_qty_ratio ,
              x_return_status    => l_return_status );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;--link_to_line_id <>fnd_api.g_miss_num

          /* assign the parameter for txn_line_rec */
          l_copy_txn_line_rec.SOURCE_TRANSACTION_ID       :=  l_order_line_rec.order_line_id;
          l_copy_txn_line_rec.SOURCE_TRANSACTION_TABLE    :=  'WSH_DELIVERY_DETAILS';

          debug('concurrency check - is installation details copied already?' );

          -- Check if txn details exist
          l_copy_trx_detail_exist := csi_t_txn_details_grp.check_txn_details_exist(
                                       p_txn_line_rec  => l_copy_txn_line_rec );

          IF l_copy_trx_detail_exist THEN
            debug('  Yes it is.');
            BEGIN
              SELECT transaction_line_id
              INTO   l_trx_line_id
              FROM   csi_t_transaction_lines
              WHERE  source_transaction_id    = l_copy_txn_line_rec.source_transaction_id
              AND    source_transaction_table = l_copy_txn_line_rec.source_transaction_table;
            EXCEPTION
              WHEN no_data_found  THEN
                fnd_message.set_name('CSI','CSI_INT_TRX_LINE_MISSING');
                fnd_message.set_token('SOURCE_TRANSACTION_ID',
                                       l_copy_txn_line_rec.SOURCE_TRANSACTION_ID);
                fnd_message.set_token('SOURCE_TRANSACTION_TABLE',
                                       l_copy_txn_line_rec.SOURCE_TRANSACTION_TABLE);
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
            END;
          ELSE

            debug('  No it is not. Copying installation details as WSH_DELIVERY_DETAILS.');

            --Parameters for the source order line
            l_src_txn_line_rec.source_transaction_id      := l_order_line_rec.order_line_id;
            l_src_txn_line_rec.source_transaction_table   := 'OE_ORDER_LINES_ALL';

            --Parameters for the new source trx rec
            l_new_txn_line_rec.source_transaction_id      := l_order_line_rec.order_line_id;
            l_new_txn_line_rec.source_transaction_table   := 'WSH_DELIVERY_DETAILS';
            l_new_txn_line_rec.source_transaction_type_id := g_txn_type_id;

            csi_t_txn_details_pvt.copy_transaction_dtls(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_none,
              p_src_txn_line_rec      => l_src_txn_line_rec,
              px_new_txn_line_rec     => l_new_txn_line_rec,
              p_copy_parties_flag     => fnd_api.g_true,
              p_copy_pty_accts_flag   => fnd_api.g_true,
              p_copy_ii_rltns_flag    => fnd_api.g_true,
              p_copy_org_assgn_flag   => fnd_api.g_true,
              p_copy_ext_attribs_flag => fnd_api.g_true,
              p_copy_txn_systems_flag => fnd_api.g_true,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              g_api_name := 'csi_t_txn_details_pvt.copy_transaction_dtls';
              raise fnd_api.g_exc_error;
            END IF;

            l_trx_line_id :=  l_new_txn_line_rec.transaction_line_id;

            /* Copied the following code from IF condition above as part of fix for bug 3555078 */
            ---Added (Start) for m-to-m enhancements
            ---Now split the copied TLD's to one each.
            IF l_item_control_rec.serial_control_code <> 1  OR l_trackable_parent THEN

               debug('splitting the WSH txn details in to one each' );
               -- shegde 2769321 oe_orderlines_all changed to wsh_delivery_details
               csi_utl_pkg.create_txn_dtls(
                 p_source_trx_id    =>  l_order_line_rec.order_line_id,
                 p_source_trx_table =>  'WSH_DELIVERY_DETAILS',
                 x_return_status    =>  l_return_status );

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                 raise fnd_api.g_exc_error;
               END IF;
             END IF;
             ---Added (End) for m-to-m enhancements
            /* Copied the above code from IF condition above as part of fix for bug 3555078 */

          END IF ; -- if NOT(l_copy_trx_detail_exist)
        END IF; -- if l_trx_detail_exist for option and model
      END IF; -- if item_type_code in (config,option)
    END IF; -- installation details entered check

    /* get the splitted order line for partial shipment */
    IF l_trx_detail_exist then

      debug('check if this is a partial shipment case.');

      csi_utl_pkg.get_split_order_line(
        l_order_line_rec.order_line_id,
        l_order_line_rec.header_id,
        l_split_ord_line_id,
        l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      IF l_split_ord_line_id is not null THEN

        l_partial_ship := TRUE;

        debug('  Yes. split_order_line_id :'||l_split_ord_line_id);

        l_order_line_rec.split_ord_line_id := l_split_ord_line_id;

        /* assign the parameter for txn_line_rec */
        l_copy_txn_line_rec.source_transaction_id    :=  l_split_ord_line_id;
        l_copy_txn_line_rec.source_transaction_table :=  'OE_ORDER_LINES_ALL';

        debug('Check if copied installation details exist for the split order line?' );

        l_copy_trx_detail_exist := csi_t_txn_details_grp.check_txn_details_exist(
                                     p_txn_line_rec  => l_copy_txn_line_rec );

        IF NOT(l_copy_trx_detail_exist) THEN

          /*------------------------------------------------------------------------*/
          /* Copy the txn details with the same source for the splitted order line  */
          /*------------------------------------------------------------------------*/

          --Parameters for the source transaction
          l_src_txn_line_rec.source_transaction_id     := l_order_line_rec.order_line_id;
          l_src_txn_line_rec.source_transaction_table  := 'OE_ORDER_LINES_ALL';

          --Parameters for the destination trx rec
          l_new_txn_line_rec.source_transaction_id      := l_split_ord_line_id;
          l_new_txn_line_rec.source_transaction_table   := 'OE_ORDER_LINES_ALL';
          l_new_txn_line_rec.source_transaction_type_id := g_txn_type_id;
          l_new_txn_line_rec.transaction_line_id        := fnd_api.g_miss_num;

          debug('  No. So copying installation details for the split order line.' );

          csi_t_txn_details_pvt.copy_transaction_dtls(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_none,
            p_src_txn_line_rec      => l_src_txn_line_rec,
            px_new_txn_line_rec     => l_new_txn_line_rec,
            p_copy_parties_flag     => fnd_api.g_true,
            p_copy_pty_accts_flag   => fnd_api.g_true,
            p_copy_ii_rltns_flag    => fnd_api.g_true,
            p_copy_org_assgn_flag   => fnd_api.g_true,
            p_copy_ext_attribs_flag => fnd_api.g_true,
            p_copy_txn_systems_flag => fnd_api.g_true,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            g_api_name := 'csi_t_txn_details_pvt.copy_transaction_dtls';
            raise fnd_api.g_exc_error;
          END IF;

        END IF; -- installation details check
      ELSE
        l_partial_ship := FALSE;
        debug('  No.');
      END IF; -- split line id check
    END IF; -- end if l_trx_line_detail_exists

    l_order_line_rec.trx_line_id            := l_trx_line_id;

    --assign the values for the trx_rec
    l_trx_rec.source_header_ref_id        := l_order_line_rec.header_id;
    l_trx_rec.source_header_ref           := l_order_line_rec.order_number;
    l_trx_rec.source_line_ref_id          := l_order_line_rec.order_line_id;
    l_trx_rec.source_line_ref             := l_order_line_rec.line_number;
    l_trx_rec.inv_material_transaction_id := p_mtl_transaction_id;
    l_trx_rec.transaction_type_id         := g_txn_type_id  ;
    l_trx_rec.transaction_date            := l_order_line_rec.transaction_date ;
    l_trx_rec.source_transaction_date     := l_order_line_rec.transaction_date ;
    l_trx_rec.transaction_status_code     := 'PENDING';

    /* Create csi transaction and use this trx_rec for all  ib transactions */
    csi_transactions_pvt.create_transaction(
      p_api_version            => 1.0,
      p_commit                 => fnd_api.g_false,
      p_init_msg_list          => fnd_api.g_true,
      p_validation_level       => fnd_api.g_valid_level_full,
      p_success_if_exists_flag => 'Y',
      p_transaction_rec        => l_trx_rec,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      g_api_name := 'csi_transactions_pvt.create_transaction';
      raise fnd_api.g_exc_error;
    END IF;

    debug('csi transaction_id :'||l_trx_rec.transaction_id);

    /* -------------------------------------------------*/
    /* Match the txn details with shipment and          */
    /* build the relationship for Component OF          */
    /*--------------------------------------------------*/

    -- Included Transaction rec as part of fix for Bug 2767338
    build_shtd_table(
      p_mtl_transaction_id  =>  p_mtl_transaction_id,
      p_order_line_rec      =>  l_order_line_rec,
      p_txn_sub_type_rec    =>  x_trx_sub_type_rec,
      p_trx_detail_exist    =>  l_trx_detail_exist,
      p_transaction_rec     =>  l_trx_rec,
      p_trackable_parent    =>  l_trackable_parent,
      x_order_shipment_tbl  =>  x_order_shipment_tbl,
      px_error_rec          =>  l_error_rec,
      x_return_status       =>  l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    /* switch the non source transaction details to the IN_PROCESS status */
    --Assign the literals.. bug 4311676
    l_literal1 := 'PROCESSED';
    l_literal2 := 'WSH_DELIVERY_DETAILS';

    UPDATE csi_t_txn_line_details
    SET    processing_status = 'IN_PROCESS'
    WHERE  transaction_line_id IN (
      SELECT transaction_line_id
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_table = l_literal2
      AND    source_transaction_id    = l_order_line_rec.order_line_id)
      AND    source_transaction_flag = 'N'
      AND    processing_status <> l_literal1;
    --
    l_txn_line_query_rec.SOURCE_TRANSACTION_ID    := l_order_line_rec.order_line_id;
    l_txn_line_query_rec.SOURCE_TRANSACTION_TABLE := 'WSH_DELIVERY_DETAILS';
    l_txn_line_dtl_query_rec.PROCESSING_STATUS    := 'IN_PROCESS';

    /* read all the matched txn line dtls and all the child tables for final processing */

    debug('Installation details for the final process - Update Install Base.' );

    csi_t_txn_details_grp.get_transaction_details (
      p_api_version               => 1.0,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_txn_line_query_rec        => l_txn_line_query_rec,
      p_txn_line_detail_query_rec => l_txn_line_dtl_query_rec,
      x_txn_line_detail_tbl       => l_txn_line_detail_tbl,
      p_get_parties_flag          => fnd_api.g_true,
      x_txn_party_detail_tbl      => l_txn_party_detail_tbl,
      p_get_pty_accts_flag        => fnd_api.g_true,
      x_txn_pty_acct_detail_tbl   => l_txn_pty_acct_dtl_tbl,
      ---Added (Start) for m-to-m enhancements
      -- Let us not get relations here.
      -- get_ii_relations_tbl will get the relations at later stage
      p_get_ii_rltns_flag         => fnd_api.g_false,
      ---Added (End) for m-to-m enhancements
      x_txn_ii_rltns_tbl          => l_txn_ii_rltns_tbl,
      p_get_org_assgns_flag       => fnd_api.g_true,
      x_txn_org_assgn_tbl         => l_txn_org_assgn_tbl,
      p_get_ext_attrib_vals_flag  => fnd_api.g_true,
      x_txn_ext_attrib_vals_tbl   => l_txn_ext_attrib_vals_tbl,
      p_get_csi_attribs_flag      => fnd_api.g_false,
      x_csi_ext_attribs_tbl       => l_csi_ext_attribs_tbl,
      p_get_csi_iea_values_flag   => fnd_api.g_false,
      x_csi_iea_values_tbl        => l_csi_iea_values_tbl,
      p_get_txn_systems_flag      => fnd_api.g_true,
      x_txn_systems_tbl           => l_txn_systems_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      g_api_name := 'csi_t_txn_details_grp.get_transaction_details';
      raise fnd_api.g_exc_error;
    END IF;

    debug('  txn_line_detail_tbl.count  :'|| l_txn_line_detail_tbl.count  );
    debug('  txn_party_detail_tbl.count :'|| l_txn_party_detail_tbl.count  );
    debug('  txn_pty_acct_dtl_tbl.count :'|| l_txn_pty_acct_dtl_tbl.count  );
    debug('  txn_org_assgn_tbl.count    :'|| l_txn_org_assgn_tbl.count  );
    debug('  txn_systems_tbl.count      :'|| l_txn_systems_tbl.count  );
    debug('  txn_ii_rltns_tbl.count     :'|| l_txn_ii_rltns_tbl.count  );
    debug('  txn_eav_tbl.count          :'|| l_txn_ext_attrib_vals_tbl.count );

    /*---------------------------------------------------*/
    /* Get the pricing attributes for the order line and */
    /* pass it to update_install_base                    */
    /*---------------------------------------------------*/

    csi_utl_pkg.Get_Pricing_Attribs(
      p_line_id           =>  l_order_line_rec.order_line_id,
      x_pricing_attb_tbl  =>  x_pricing_attb_tbl,
      x_return_status     =>  x_return_status );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_error;
    END IF;

    debug('  pricing_attb_tbl.count :'||x_pricing_attb_tbl.count ) ;

    -- Added for bug 5101635
    l_conv_to_prim_uom_req := 'Y';
    IF l_txn_line_detail_tbl.count > 0 THEN
      FOR u in l_txn_line_detail_tbl.FIRST..l_txn_line_detail_tbl.LAST
      LOOP
        IF NVL(l_txn_line_detail_tbl(u).serial_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char AND
           NVL(l_txn_line_detail_tbl(u).quantity,fnd_api.g_miss_num) = 1 THEN
           l_conv_to_prim_uom_req := 'N';   -- No UOM Conversion Required
	   Exit;
        END IF;
      END LOOP;
    END IF;
    -- End bug 5101635

    IF l_conv_to_prim_uom_req = 'Y' THEN      -- Added for bug 5101635
      csi_utl_pkg.conv_to_prim_uom(
         p_inv_organization_id => l_order_line_rec.inv_org_id,
         p_inventory_item_id   => l_order_line_rec.inv_item_id,
         p_uom                 => l_order_line_rec.order_quantity_uom,
         x_txn_line_dtl_tbl    => l_txn_line_detail_tbl,
         x_return_status       => x_return_status);

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          raise fnd_api.g_exc_error;
        END IF;
    END IF;

    --
    -- srramakr TSO with Equipment.
    -- If this is a MACD order line then we need to merge the Transaction details written by CZ and WSH
    -- For this, we call CSI_INTERFACE_PKG.Get_CZ_Relations.
    -- macd_order_line flag is set by Build_Shtd_Table routine.
    --
    IF l_order_line_rec.macd_order_line = FND_API.G_TRUE THEN
       l_source_line_rec.source_line_id := l_order_line_rec.order_line_id;
       --
       Csi_Interface_Pkg.Get_CZ_Relations
          ( p_source_header_rec     =>  l_source_header_rec,
            p_source_line_rec       =>  l_source_line_rec,
            px_txn_line_rec         =>  l_transaction_line_rec,
            px_txn_line_dtl_tbl     =>  l_txn_line_detail_tbl,
            x_txn_ii_rltns_tbl      =>  l_txn_ii_rltns_tbl,
            x_txn_eav_tbl           =>  l_txn_ext_attrib_vals_tbl,
            x_return_status         =>  x_return_status
          );
       IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          raise fnd_api.g_exc_error;
       END IF;
    END IF;
    --
    --
    l_transaction_line_rec := l_tmp_txn_line_rec;
    --
    l_transaction_line_rec.transaction_line_id        := l_order_line_rec.trx_line_id;
    l_transaction_line_rec.source_transaction_id      := l_order_line_rec.order_line_id;
    l_transaction_line_rec.source_transaction_table   := 'WSH_DELIVERY_DETAILS';
    l_transaction_line_rec.source_transaction_type_id := g_txn_type_id ;

    /*--------------------------------------------------------*/
    /* Once the txn details are matched and COMPONENT-OF      */
    /* relationships are build  then Update instance in IB    */
    /*--------------------------------------------------------*/

    update_install_base(
      p_api_version             => 1.0,
      p_commit                  => fnd_api.g_false,
      p_init_msg_list           => fnd_api.g_true,
      p_validation_level        => fnd_api.g_valid_level_full,
      p_txn_line_rec            => l_transaction_line_rec,
      p_txn_line_detail_tbl     => l_txn_line_detail_tbl,
      p_txn_party_detail_tbl    => l_txn_party_detail_tbl,
      p_txn_pty_acct_dtl_tbl    => l_txn_pty_acct_dtl_tbl,
      p_txn_org_assgn_tbl       => l_txn_org_assgn_tbl,
      p_txn_ext_attrib_vals_tbl => l_txn_ext_attrib_vals_tbl,
      p_txn_ii_rltns_tbl        => l_txn_ii_rltns_tbl,
      p_txn_systems_tbl         => l_txn_systems_tbl,
      p_pricing_attribs_tbl     => x_pricing_attb_tbl,
      p_order_line_rec          => l_order_line_rec,
      p_trx_rec                 => l_trx_rec,
      p_source                  => 'SHIPMENT',
      p_validate_only           => 'N',
      px_error_rec              => l_error_rec,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_error;
    END IF;

    debug('end: csi_order_ship_pub.order_shipment. status: successful');
    debug('  timestamp : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to order_shipment;
      x_return_status        := fnd_api.g_ret_sts_error;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec := l_error_rec;
      debug('Error(E) :'||l_error_rec.error_text);
    WHEN fnd_api.g_exc_unexpected_error THEN
      rollback to order_shipment;
      x_return_status        := fnd_api.g_ret_sts_unexp_error ;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec := l_error_rec;
      debug('Error(U) :'||l_error_rec.error_text);
    WHEN others THEN
      rollback to order_shipment;
      x_return_status        := fnd_api.g_ret_sts_unexp_error;
      l_error_rec.error_text := substr(sqlerrm, 1, 540);
      px_trx_error_rec        := l_error_rec;
      debug('Error(O) :'||l_error_rec.error_text);
  END order_shipment;

  PROCEDURE process_non_source(
    p_txn_line_detail_rec  IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_call_contracts       IN  varchar2 := fnd_api.g_true,
    p_trx_rec              IN  csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_trx_rec                    csi_datastructures_pub.transaction_rec;

    l_ns_instance_rec            csi_datastructures_pub.instance_rec;
    l_ns_party_tbl               csi_datastructures_pub.party_tbl;
    l_ns_party_acct_tbl          csi_datastructures_pub.party_account_tbl;
    l_ns_pricing_attribs_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_ns_ext_attrib_val_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_ns_org_units_tbl           csi_datastructures_pub.organization_units_tbl;
    l_ns_inst_asset_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_ns_inst_id_lst             csi_datastructures_pub.id_tbl;

    l_ii_relation_code           varchar2(30);
    l_location_code              varchar2(30);
    l_serial_number              varchar2(80);
    l_active_end_date            date;
    l_exp_instance_id_lst        csi_datastructures_pub.id_tbl;
    l_exp_instance_rec           csi_datastructures_pub.instance_rec;

    l_return_status              varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                  number;
    l_msg_data                   varchar2(2000);

    -- Added this parameter as part of fix for Bug 3145503.
    l_upd_ns_inst                varchar2(1) := 'Y';

    CURSOR comp_of_cur(p_tl_id IN number, p_tld_id IN number) IS
      SELECT txn_relationship_id
      FROM   csi_t_ii_relationships
      WHERE  transaction_line_id = p_tl_id
      AND   (subject_id = p_tld_id
              OR
              object_id = p_tld_id)
      AND    relationship_type_code = 'COMPONENT-OF';

    l_comp_of_tld boolean := FALSE;

    CURSOR other_nsrc_cur(p_tl_id IN number, p_tld_id IN number) IS
      SELECT sub_tld.instance_id sub_instance_id,
             obj_tld.instance_id obj_instance_id
      FROM   csi_t_ii_relationships iir,
             csi_t_txn_line_details sub_tld,
             csi_t_txn_line_details obj_tld
      WHERE  iir.transaction_line_id = p_tl_id
      AND    (iir.subject_id = p_tld_id
              OR
              iir.object_id = p_tld_id)
      AND    iir.relationship_type_code <> 'COMPONENT-OF'
      AND    sub_tld.transaction_line_id = iir.transaction_line_id
      AND    sub_tld.txn_line_detail_id  = iir.subject_id
      AND    obj_tld.transaction_line_id = iir.transaction_line_id
      AND    obj_tld.txn_line_detail_id  = iir.object_id;

    l_skip_reason   varchar2(80);
    skip_non_source exception ;

  BEGIN

    api_log('process_non_source');

    x_return_status  := fnd_api.g_ret_sts_success;
    l_trx_rec        := p_trx_rec;

    l_comp_of_tld := FALSE;

    FOR comp_of_rec IN comp_of_cur(
          p_txn_line_detail_rec.transaction_line_id,
          p_txn_line_detail_rec.txn_line_detail_id)
    LOOP
      l_comp_of_tld := TRUE;
    END LOOP;

    IF NOT(l_comp_of_tld) THEN

      -- check if the source and the non source points to the same instance
      FOR other_nsrc_rec IN other_nsrc_cur(
            p_txn_line_detail_rec.transaction_line_id,
            p_txn_line_detail_rec.txn_line_detail_id)
      LOOP
        IF other_nsrc_rec.sub_instance_id = other_nsrc_rec.obj_instance_id THEN
          l_skip_reason := 'source and non source instances are the same.';
          RAISE skip_non_source;
        END IF;
      END LOOP;

      l_ns_instance_rec.instance_id := p_txn_line_detail_rec.instance_id;

      BEGIN
        SELECT  non_src_status_id
        INTO    l_ns_instance_rec.instance_status_id
        FROM    csi_txn_sub_types
        WHERE   transaction_type_id = p_trx_rec.transaction_type_id
        AND     sub_type_id = p_txn_line_detail_rec.sub_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;

      l_trx_rec.txn_sub_type_id := p_txn_line_detail_rec.sub_type_id;

      -- added this IF as part of fix for bug 3145503.
      IF l_location_code <> 'INVENTORY'
      THEN
        l_ns_instance_rec.active_end_date :=
          nvl(p_txn_line_detail_rec.active_end_date,fnd_api.g_miss_date);
        l_ns_instance_rec.return_by_date :=  p_txn_line_detail_rec.return_by_date;
      END IF;

      l_ns_instance_rec.call_contracts := p_call_contracts;

      BEGIN

        SELECT object_version_number,
               location_type_code,
               serial_number,
	       active_end_date
        INTO   l_ns_instance_rec.object_version_number,
               l_location_code,
               l_serial_number,
	       l_active_end_date
        FROM   csi_item_instances
        WHERE  instance_id = p_txn_line_detail_rec.instance_id;

        debug('  TXN Line Dtl ID :'||p_txn_line_detail_rec.txn_line_detail_id);
        debug('  Instance ID     :'||l_ns_instance_rec.instance_id );
        debug('  Status ID       :'||l_ns_instance_rec.instance_status_id);
        debug('  location Code   :'||l_location_code);
        debug('  Active end date :'||l_active_end_date);

        -- IF l_location_code <> 'INVENTORY'
        --   AND
        -- Commented the above condition as part of fix for bug 3145503.
        IF  l_ns_instance_rec.instance_status_id IS NOT NULL
        THEN

          -- check for terminable status bug 2272771
          IF csi_item_instance_vld_pvt.val_inst_ter_flag(
               p_status_id => l_ns_instance_rec.instance_status_id)
          THEN

            -- Added the fillowing If condition as part of fix for Bug 3145503.
            IF l_location_code = 'INVENTORY' Then
              debug('Instance Status is TERMINABLE so cannot update the instance status');
              l_upd_ns_inst  := 'N';
            ELSE
            -- End code for Bug 3145503.
              debug('  Instance Status is defined as TERMINABLE.');
              IF nvl(l_ns_instance_rec.active_end_date, fnd_api.g_miss_date) = fnd_api.g_miss_date
              THEN
                --bug 4026148
                --l_ns_instance_rec.active_end_date := sysdate;
                l_ns_instance_rec.active_end_date := l_trx_rec.source_transaction_date;
                --bug 4026148
              END IF;
            END IF;  -- End if for Bug 3145503.
          END IF;

          IF l_upd_ns_inst  = 'Y' -- Added as fix for Bug 3145503.
          THEN
	    l_ns_instance_rec.last_oe_order_line_id := l_trx_rec.source_line_ref_id;
           -- we should be stamping the replaced instance also with the
           --order information. not sure why it wasn't done ... shegde. bug 3692473
           --code modification start for 3681856--
            IF (l_active_end_date is NOT NULL) AND (l_active_end_date <= sysdate)
            THEN -- we will expire the instance back. Contracts shouldn't be called while unexpiring
	       l_ns_instance_rec.call_contracts := fnd_api.g_false;
            END IF;
           --code modification end for 3681856--

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pub',
              p_api_name => 'update_item_instance');

            csi_t_gen_utility_pvt.dump_csi_instance_rec(
              p_csi_instance_rec => l_ns_instance_rec);

            /* non source status update call. */
            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_ns_instance_rec,
              p_ext_attrib_values_tbl => l_ns_ext_attrib_val_tbl,
              p_party_tbl             => l_ns_party_tbl,
              p_account_tbl           => l_ns_party_acct_tbl,
              p_pricing_attrib_tbl    => l_ns_pricing_attribs_tbl,
              p_org_assignments_tbl   => l_ns_org_units_tbl,
              p_txn_rec               => l_trx_rec,
              p_asset_assignment_tbl  => l_ns_inst_asset_tbl,
              x_instance_id_lst       => l_ns_inst_id_lst,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data );

            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF (l_active_end_date is NOT NULL) AND (l_active_end_date <= sysdate)
            THEN
              -- expiring the instance back. Added this IF for Bug 3039821

	      SELECT object_version_number
              INTO   l_exp_instance_rec.object_version_number
              FROM   csi_item_instances
              WHERE  instance_id = p_txn_line_detail_rec.instance_id;

              l_exp_instance_rec.instance_id 	:= p_txn_line_detail_rec.instance_id;

            --code modification start for 3681856--
      	      --l_exp_instance_rec.call_contracts   := p_call_contracts;
	      l_exp_instance_rec.call_contracts := fnd_api.g_false;
            --code modification end for 3681856--

              l_trx_rec.transaction_id       	:= fnd_api.g_miss_num;

              csi_t_gen_utility_pvt.dump_api_info(
                p_api_name => 'expire_item_instance',
                p_pkg_name => 'csi_item_instance_pub');

              csi_item_instance_pub.expire_item_instance(
                p_api_version      => 1.0,
                p_commit           => fnd_api.g_false,
                p_init_msg_list    => fnd_api.g_true,
                p_validation_level => fnd_api.g_valid_level_full,
                p_instance_rec     => l_exp_instance_rec,
                p_expire_children  => fnd_api.g_true,
                p_txn_rec          => l_trx_rec,
                x_instance_id_lst  => l_exp_instance_id_lst,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data);

              IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
                g_api_name := 'csi_item_instance_pub.expire_item_instance';
                raise fnd_api.g_exc_error;
              END IF;
	    END IF;

            l_trx_rec.source_group_ref_id := l_ns_instance_rec.instance_id;
            l_trx_rec.source_group_ref    := l_serial_number;

            SELECT object_version_number
            INTO   l_trx_rec.object_version_number
            FROM   csi_transactions
            WHERE  transaction_id = l_trx_rec.transaction_id;

            csi_transactions_pvt.update_transactions(
              p_api_version       => 1.0,
              p_init_msg_list     => fnd_api.g_false,
              p_commit            => fnd_api.g_false,
              p_validation_level  => fnd_api.g_valid_level_full,
              p_transaction_rec   => l_trx_rec,
              x_return_status     => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_data);
          END IF; -- Added as fix for Bug 3145503.
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          debug('Could not find the non source instance.');
      END;
    ELSE
      debug('Non Source record built by interface. Do not process.');
    END IF;

  EXCEPTION
    WHEN skip_non_source THEN
      debug('  skip non source processing :'||l_skip_reason);
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END process_non_source;

  /* ********************************************************************** */
  /* Procedure name: get_order_shipment_rec                                 */
  /* Description   : Procedure that identifies the the instance shipped and */
  /*                 build the Shipment record for all the delivery lines   */
  /*                 for that material transaction id                       */
  /* ********************************************************************** */

  -- Included Transaction rec as part of fix for Bug 2767338
  PROCEDURE get_order_shipment_rec(
    p_mtl_transaction_id      IN  NUMBER,
    p_order_line_rec          IN  order_line_rec,
    p_txn_sub_type_rec        IN  txn_sub_type_rec,
    p_transaction_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_order_shipment_tbl      OUT NOCOPY order_shipment_tbl,
    px_error_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_party_tbl             csi_datastructures_pub.party_tbl;
    l_party_account_tbl     csi_datastructures_pub.party_account_tbl;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;
    l_instance_header_tbl   csi_datastructures_pub.instance_header_tbl;
    l_ext_attrib_val_tabl   csi_datastructures_pub.extend_attrib_values_tbl;
    l_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;
    l_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;

    -- Added a column reservable_type from mtl_systems_items for negative quantity check.
    l_cre_instance_rec        csi_datastructures_pub.instance_rec;
    l_cre_party_tbl           csi_datastructures_pub.party_tbl;
    l_cre_ext_attrib_val_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
    l_cre_party_acct_tbl      csi_datastructures_pub.party_account_tbl;
    l_cre_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    l_cre_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_cre_inst_asset_tbl      csi_datastructures_pub.instance_asset_tbl;
    l_trx_rec                 csi_datastructures_pub.transaction_rec;

    -- Added for updating instance to ZERO
    l_zero_instance_rec       csi_datastructures_pub.instance_rec;
    l_zero_parties_tbl        csi_datastructures_pub.party_tbl;
    l_zero_pty_accts_tbl      csi_datastructures_pub.party_account_tbl;
    l_zero_org_units_tbl      csi_datastructures_pub.organization_units_tbl;
    l_zero_ea_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_zero_pricing_tbl        csi_datastructures_pub.pricing_attribs_tbl;
    l_zero_assets_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_inst_id_lst             csi_datastructures_pub.id_tbl;

    x_msg_count             NUMBER;
    x_msg_data              varchar2(2000);
    l_party_id              NUMBER;
    l_uom_rate              NUMBER;
    l_shipped_qty           NUMBER;
    l_count                 NUMBER := 0;
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_active_instances_only varchar2(1);

    -- Included Transaction rec as part of fix for Bug 2767338
    CURSOR mmt_cur(p_trx_id IN NUMBER) IS
      SELECT ool.line_id,
             ool.header_id,
             ool.item_type_code,
             ool.cust_po_number,
             ool.ato_line_id,
             ool.top_model_line_id,
             ool.link_to_line_id,
             NVL(ool.invoice_to_contact_id ,ooh.invoice_to_contact_id ) invoice_to_contact_id ,
             ool.line_type_id,
             ool.ordered_quantity,
             ool.shipped_quantity ord_line_shipped_qty,
             NVL(ool.ship_to_contact_id, ooh.ship_to_contact_id) ship_to_contact_id,
             NVL(ool.ship_from_org_id, ooh.ship_from_org_id)     ship_from_org_id  ,
             NVL(ool.sold_to_org_id, ooh.sold_to_org_id)         sold_to_org_id    ,
             NVL(ool.sold_from_org_id, ooh.sold_from_org_id)     sold_from_org_id  ,
             NVL(ool.ship_to_org_id, ooh.ship_to_org_id)         ship_to_org_id    ,
             NVL(ool.invoice_to_org_id, ooh.invoice_to_org_id)   invoice_to_org_id ,
             NVL(ool.deliver_to_org_id, ooh.deliver_to_org_id)   deliver_to_org_id ,
             ool.order_quantity_uom,
             mmt.inventory_item_id   inventory_item_id,
             mmt.organization_id     inv_organization_id,
             mmt.revision            revision,
             mmt.subinventory_code   subinventory,
             mmt.locator_id          locator_id,
             null                    lot_number,
             mut.serial_number       serial_number,
             abs(mmt.transaction_quantity)  shipped_quantity,
             mmt.transaction_uom,
             mmt.transaction_date,
             msi.lot_control_code,
             msi.serial_number_control_code,
             msi.reservable_type,
             haou.location_id        hr_location_id,
             msei.location_id        subinv_location_id,
             to_char(null)           ib_owner,
             to_number(null)         end_customer_id,
             to_char(null)           ib_install_loc,
             to_number(null)         ib_install_loc_id,
             to_char(null)           ib_current_loc,
             to_number(null)         ib_current_loc_id,
             ooh.order_source_id     order_source_id -- Added for Siebel Genesis Project
      FROM   oe_order_headers_all         ooh,
             oe_order_lines_all           ool,
             mtl_system_items             msi,
             mtl_unit_transactions        mut,
             mtl_material_transactions    mmt,
             mtl_secondary_inventories    msei,
             hr_all_organization_units    haou
      WHERE  mmt.transaction_id       = p_trx_id
      AND    mmt.transaction_id       = mut.transaction_id(+)
      AND    msi.organization_id      = mmt.organization_id
      AND    msi.inventory_item_id    = mmt.inventory_item_id
      AND    msi.lot_control_code     = 1   -- no lot case
      AND    mmt.organization_id      = haou.organization_id(+)
      AND    mmt.subinventory_code    = msei.secondary_inventory_name(+)
      AND    mmt.organization_id      = msei.organization_id(+)
      AND    ool.line_id              = mmt.trx_source_line_id
      AND    ooh.header_id            = ool.header_id
      UNION
      SELECT ool.line_id,
             ool.header_id,
             ool.item_type_code,
             ool.cust_po_number,
             ool.ato_line_id,
             ool.top_model_line_id,
             ool.link_to_line_id,
             NVL(ool.invoice_to_contact_id, ooh.invoice_to_contact_id ) invoice_to_contact_id ,
             ool.line_type_id,
             ool.ordered_quantity,
             ool.shipped_quantity ord_line_shipped_qty,
             NVL(ool.ship_to_contact_id, ooh.ship_to_contact_id)  ship_to_contact_id,
             NVL(ool.ship_from_org_id , ooh.ship_from_org_id)     ship_from_org_id  ,
             NVL(ool.sold_to_org_id , ooh.sold_to_org_id)         sold_to_org_id    ,
             NVL(ool.sold_from_org_id, ooh.sold_from_org_id)      sold_from_org_id  ,
             NVL(ool.ship_to_org_id , ooh.ship_to_org_id)         ship_to_org_id    ,
             NVL(ool.invoice_to_org_id, ooh.invoice_to_org_id)    invoice_to_org_id ,
             NVL(ool.deliver_to_org_id, ooh.deliver_to_org_id)    deliver_to_org_id ,
             ool.order_quantity_uom     ,
             mmt.inventory_item_id   inventory_item_id,
             mmt.organization_id     inv_organization_id,
             mmt.revision            revision,
             mmt.subinventory_code   subinventory,
             mmt.locator_id          locator_id,
             mtln.lot_number         lot_number,
             mut.serial_number         serial_number,
             abs(mtln.transaction_quantity)  shipped_quantity,
             mmt.transaction_uom,
             mmt.transaction_date,
             msi.lot_control_code,
             msi.serial_number_control_code,
             msi.reservable_type,
             haou.location_id        hr_location_id,
             msei.location_id        subinv_location_id,
             to_char(null)           ib_owner,
             to_number(null)         end_customer_id,
             to_char(null)           ib_install_loc,
             to_number(null)         ib_install_loc_id,
             to_char(null)           ib_current_loc,
             to_number(null)         ib_current_loc_id,
             ooh.order_source_id     order_source_id -- Added for Siebel Genesis Project
      FROM   oe_order_headers_all         ooh,
             oe_order_lines_all           ool,
             mtl_system_items             msi,
             mtl_unit_transactions        mut,
             mtl_transaction_lot_numbers  mtln,
             mtl_material_transactions    mmt,
             mtl_secondary_inventories    msei,
             hr_all_organization_units    haou
      WHERE  mmt.transaction_id         = p_trx_id
      AND    mmt.transaction_id         = mtln.transaction_id(+)
      AND    mtln.serial_transaction_id = mut.transaction_id(+)
      AND    msi.organization_id        = mmt.organization_id
      AND    msi.inventory_item_id      = mmt.inventory_item_id
      AND    msi.lot_control_code       = 2   -- lot control case
      AND    mmt.organization_id        = haou.organization_id(+)
      AND    mmt.subinventory_code      = msei.secondary_inventory_name(+)
      AND    mmt.organization_id        = msei.organization_id(+)
      AND    mmt.trx_source_line_id     = ool.line_id
      AND    ool.header_id              = ooh.header_id;

      -- For partner prdering
      l_partner_rec             oe_install_base_util.partner_order_rec;
      l_partner_owner_id        NUMBER;
      l_partner_owner_acct_id   NUMBER;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    -- Included Transaction rec as part of fix for Bug 2767338
    l_trx_rec := p_transaction_rec;

    api_log('get_order_shipment_rec');

    /* Get the shipment record and assign to PL/SQL table */
    FOR mmt_rec IN mmt_cur(p_mtl_transaction_id) LOOP

      px_error_rec.serial_number := mmt_rec.serial_number;
      px_error_rec.lot_number    := mmt_rec.lot_number;

      l_count := l_count + 1;

      -- for partner ordering
      OE_INSTALL_BASE_UTIL.get_partner_ord_rec(p_order_line_id      => mmt_rec.line_id,
                                               x_partner_order_rec  => l_partner_rec);

      IF l_partner_rec.IB_OWNER = 'END_CUSTOMER'
      THEN
        IF l_partner_rec.END_CUSTOMER_ID is null Then
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
        ELSE
           mmt_rec.ib_owner        := l_partner_rec.ib_owner;
           mmt_rec.end_customer_id := l_partner_rec.end_customer_id;
        END IF;
      ELSIF l_partner_rec.IB_OWNER = 'INSTALL_BASE'
      THEN
           mmt_rec.ib_owner        := l_partner_rec.ib_owner;
           mmt_rec.end_customer_id := fnd_api.g_miss_num;
      ELSE
        mmt_rec.end_customer_id   := mmt_rec.sold_to_org_id;
      END IF;

      IF l_partner_rec.IB_INSTALLED_AT_LOCATION is not null
      THEN
       mmt_rec.ib_install_loc   := l_partner_rec.IB_INSTALLED_AT_LOCATION;
       IF mmt_rec.ib_install_loc = 'END_CUSTOMER'
       THEN
         IF l_partner_rec.end_customer_site_use_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_install_loc_id :=  l_partner_rec.end_customer_site_use_id;
         END IF;
       ELSIF mmt_rec.ib_install_loc = 'SHIP_TO'
       THEN
         IF mmt_rec.ship_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_install_loc_id := mmt_rec.ship_to_org_id;
         END IF;
       ELSIF  mmt_rec.ib_install_loc = 'SOLD_TO'
       THEN
         IF l_partner_rec.SOLD_TO_SITE_USE_ID is null -- 3412544 mmt_rec.sold_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_install_loc_id := l_partner_rec.SOLD_TO_SITE_USE_ID; -- 3412544 mmt_rec.sold_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_install_loc = 'DELIVER_TO'
       THEN
         IF mmt_rec.deliver_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_install_loc_id := mmt_rec.deliver_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_install_loc = 'BILL_TO'
       THEN
         IF mmt_rec.invoice_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_install_loc_id := mmt_rec.invoice_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_install_loc = 'INSTALL_BASE'
       THEN
          mmt_rec.ib_install_loc_id := fnd_api.g_miss_num;
       END IF;
     ELSE
       mmt_rec.ib_install_loc_id := mmt_rec.ship_to_org_id;
     END IF;

    IF l_partner_rec.IB_CURRENT_LOCATION is not null
    THEN
       mmt_rec.ib_current_loc   := l_partner_rec.IB_CURRENT_LOCATION;
       IF mmt_rec.ib_current_loc = 'END_CUSTOMER'
       THEN
         IF l_partner_rec.end_customer_site_use_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_current_loc_id :=  l_partner_rec.end_customer_site_use_id;
         END IF;
       ELSIF mmt_rec.ib_current_loc = 'SHIP_TO'
       THEN
         IF mmt_rec.ship_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_current_loc_id := mmt_rec.ship_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_current_loc = 'SOLD_TO'
       THEN
         IF l_partner_rec.SOLD_TO_SITE_USE_ID is null -- 3412544 mmt_rec.sold_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_current_loc_id := l_partner_rec.SOLD_TO_SITE_USE_ID; -- 3412544 mmt_rec.sold_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_current_loc = 'DELIVER_TO'
       THEN
         IF mmt_rec.deliver_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           mmt_rec.ib_current_loc_id := mmt_rec.deliver_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_current_loc = 'BILL_TO'
       THEN
         IF  mmt_rec.invoice_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          mmt_rec.ib_current_loc_id := mmt_rec.invoice_to_org_id;
         END IF;
       ELSIF mmt_rec.ib_current_loc = 'INSTALL_BASE'
         THEN
           mmt_rec.ib_current_loc_id := fnd_api.g_miss_num;
       END IF;
    ELSE
      mmt_rec.ib_current_loc_id := mmt_rec.ship_to_org_id;
    END IF;


      /* Derive the party_id from hz_cust_accounts table */

      csi_utl_pkg.get_party_id(
        p_cust_acct_id  => mmt_rec.end_customer_id, --mmt_rec.sold_to_org_id,
        x_party_id      => l_party_id,
        x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      IF l_party_id = -1 THEN
        raise fnd_api.g_exc_error;
      END IF;

      /* Convert the shipped qty to UOM in OM */
      inv_convert.inv_um_conversion (
        from_unit  => mmt_rec.transaction_uom,
        to_unit    => mmt_rec.order_quantity_uom,
        item_id    => mmt_rec.inventory_item_id,
        uom_rate   => l_uom_rate );

      debug('UOM Conv Factor     :'||l_uom_rate);

      IF l_uom_rate = -99999 THEN
        debug('inv_convert.inv_um_conversion failed ');
        raise fnd_api.g_exc_error;
      END IF;

      l_shipped_qty := (l_uom_rate * mmt_rec.shipped_quantity);

      l_inst_query_rec.location_type_code  := 'INVENTORY';
      l_inst_query_rec.instance_usage_code := 'IN_INVENTORY';

      IF mmt_rec.serial_number_control_code in (1,6) THEN
        l_inst_query_rec.inventory_item_id     := mmt_rec.inventory_item_id;
        l_inst_query_rec.inv_organization_id   := mmt_rec.inv_organization_id;
        l_inst_query_rec.inventory_revision    := mmt_rec.revision;
        l_inst_query_rec.inv_subinventory_name := mmt_rec.subinventory;
        l_inst_query_rec.inv_locator_id        := mmt_rec.locator_id;
        l_inst_query_rec.serial_number         := NULL; -- Bug 3056511
      ELSE
        l_inst_query_rec.inventory_item_id     := mmt_rec.inventory_item_id;
        l_inst_query_rec.inv_organization_id   := mmt_rec.inv_organization_id;
        l_inst_query_rec.inv_subinventory_name := mmt_rec.subinventory;
        l_inst_query_rec.serial_number         := mmt_rec.serial_number;
      END IF;

      IF mmt_rec.lot_control_code = 2 THEN
        l_inst_query_rec.lot_number            :=  mmt_rec.lot_number;
      END IF;

      debug('query criteria to identify inventory source instance' );
      debug('----------------------------------------------------' );
      debug('inventory_item_id    :'||l_inst_query_rec.inventory_item_id);
      debug('inv_organization_id  :'||l_inst_query_rec.inv_organization_id);
      debug('location_type_code   :'||l_inst_query_rec.location_type_code);
      debug('instance_usage_code  :'||l_inst_query_rec.instance_usage_code);
      debug('inventory_revision   :'||l_inst_query_rec.inventory_revision);
      debug('inv_subinv_name      :'||l_inst_query_rec.inv_subinventory_name);
      debug('inv_locator_id       :'||l_inst_query_rec.inv_locator_id);
      debug('lot_number           :'||l_inst_query_rec.lot_number);
      debug('serial_number        :'||l_inst_query_rec.serial_number);
      debug('----------------------------------------------------' );

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_item_instance_pub',
        p_api_name => 'get_item_instances');

      -- As part of fix for Bug 2985193 this call even brings the expired Inv. Instances.
      -- To achieve this p_active_instances_only should have a value of false.

      IF mmt_rec.reservable_type = 2
      THEN
         l_active_instances_only := fnd_api.g_false;
      ELSE
         l_active_instances_only := fnd_api.g_true;
      END IF;

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
        p_active_instance_only => l_active_instances_only,-- fnd_api.g_false,  --fnd_api.g_true,
        x_instance_header_tbl  => l_instance_header_tbl,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data);

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        raise fnd_api.g_exc_error;
      END IF;

      debug('Instance(s) Count   :'||l_instance_header_tbl.count);

      IF l_instance_header_tbl.count < 1 THEN

        -- Bug 2767338
        -- Begin Code for negative quantity option set at Org Level

        IF p_order_line_rec.negative_balances_code= 1
          AND
           mmt_rec.reservable_type = 2
          AND
            mmt_rec.serial_number_control_code in (1,6)
        THEN

          debug(' Negative Quantity allowed for this Org so Building Instance Rec');

          -- Create a Instance with missing Quantity
          -- Building Instance Rec
          l_cre_instance_rec.inventory_item_id       := l_inst_query_rec.inventory_item_id;
          l_cre_instance_rec.inv_organization_id     := l_inst_query_rec.inv_organization_id;
          l_cre_instance_rec.vld_organization_id     := l_inst_query_rec.inv_organization_id;
          l_cre_instance_rec.location_type_code      := l_inst_query_rec.location_type_code;
          l_cre_instance_rec.instance_usage_code     := l_inst_query_rec.instance_usage_code;
          l_cre_instance_rec.inventory_revision      := l_inst_query_rec.inventory_revision;
          l_cre_instance_rec.inv_subinventory_name   := l_inst_query_rec.inv_subinventory_name;
          l_cre_instance_rec.inv_locator_id          := l_inst_query_rec.inv_locator_id;
          l_cre_instance_rec.lot_number              := l_inst_query_rec.lot_number;
          l_cre_instance_rec.serial_number           := l_inst_query_rec.serial_number;
          l_cre_instance_rec.quantity                := 1; --mmt_rec.shipped_quantity;
          l_cre_instance_rec.unit_of_measure         := mmt_rec.transaction_uom;
          l_cre_instance_rec.location_id             := nvl(mmt_rec.subinv_location_id,mmt_rec.hr_location_id);
          l_cre_instance_rec.operational_status_code := 'NOT_USED';
          -- Begin Add Code for Siebel Genesis Project
          IF (mmt_rec.order_source_id = '28' OR mmt_rec.order_source_id = '29')
          THEN
             l_cre_instance_rec.source_code := 'SIEBEL';
          END IF;
          -- End Add Code for Siebel Genesis Project

          IF nvl(l_inst_query_rec.serial_number,fnd_api.g_miss_char) = fnd_api.g_miss_char  THEN
            l_cre_instance_rec.mfg_serial_number_flag := 'N';
          ELSE
            l_cre_instance_rec.mfg_serial_number_flag := 'Y';
          END IF;

          -- Building Party Rec for creating Instance with missing Quantity
          l_cre_party_tbl(1).party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

          l_cre_party_tbl(1).party_source_table     :=  'HZ_PARTIES';
          l_cre_party_tbl(1).relationship_type_code :=  'OWNER';
          l_cre_party_tbl(1).contact_flag           :=  'N';

          debug('Creating an inventory instance in the staging area for non reservable item.');
          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'create_item_instance',
            p_pkg_name => 'csi_item_instance_pub');

          /* Creation of instance with the Shippable Quantity for Negative Quantities */

          debug('Creating an instance with quantity 1 for Non-Reservable Item');
          csi_item_instance_pub.create_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_cre_instance_rec,
            p_ext_attrib_values_tbl => l_cre_ext_attrib_val_tbl,
            p_party_tbl             => l_cre_party_tbl,
            p_account_tbl           => l_cre_party_acct_tbl,
            p_pricing_attrib_tbl    => l_cre_pricing_attribs_tbl,
            p_org_assignments_tbl   => l_cre_org_units_tbl,
            p_asset_assignment_tbl  => l_cre_inst_asset_tbl,
            p_txn_rec               => l_trx_rec,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data  );

          -- For Bug 4057183
          -- IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          IF NOT(x_return_status in (fnd_api.g_ret_sts_success,'W')) THEN
            g_api_name := 'csi_item_instance_pub.create_item_instance';
            raise fnd_api.g_exc_error;
          END IF;

          l_zero_instance_rec.instance_id           := l_cre_instance_rec.instance_id;
          l_zero_instance_rec.quantity              := 0;

          -- debug('After Create OBJECT_VERSION_NUMBER '||l_cre_instance_rec.object_version_number);
          Select object_version_number
          Into   l_zero_instance_rec.object_version_number
          From   csi_item_instances
          Where  instance_id = l_cre_instance_rec.instance_id;

          -- debug('Before calling update OBJECT_VERSION_NUMBER '||l_zero_instance_rec.object_version_number);

          debug('Updating Created Instance to zero Quantity');

          csi_t_gen_utility_pvt.dump_api_info(
            p_pkg_name => 'csi_item_instance_pub',
            p_api_name => 'update_item_instance');

          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_zero_instance_rec,
            p_party_tbl             => l_zero_parties_tbl,
            p_account_tbl           => l_zero_pty_accts_tbl,
            p_org_assignments_tbl   => l_zero_org_units_tbl,
            p_ext_attrib_values_tbl => l_zero_ea_values_tbl,
            p_pricing_attrib_tbl    => l_zero_pricing_tbl,
            p_asset_assignment_tbl  => l_zero_assets_tbl,
            p_txn_rec               => l_trx_rec,
            x_instance_id_lst       => l_inst_id_lst,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data);

          -- For Bug 4057183
          -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('Instance ('||l_zero_instance_rec.instance_id||') created and updated with zero quantity successfully.');
          l_instance_header_tbl(1).instance_id           := l_zero_instance_rec.instance_id;
          l_instance_header_tbl(1).quantity              := l_zero_instance_rec.quantity;
          -- l_instance_header_tbl(1).object_version_number := l_cre_instance_rec.object_version_number;

          Select object_version_number
          Into   l_instance_header_tbl(1).object_version_number
          From   csi_item_instances
          Where  instance_id = l_zero_instance_rec.instance_id;

          px_error_rec.instance_id := l_zero_instance_rec.instance_id;

        ELSE
          fnd_message.SET_NAME('CSI','CSI_INT_NO_INST_FOUND');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        END IF;
      END IF;
      -- Bug 2767338
      -- End Fix for negative quantity option set at Org Level

      IF l_instance_header_tbl.count > 1 THEN
        fnd_message.SET_NAME('CSI','CSI_INT_MANY_INST_FOUND');
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
      END IF;

      debug('Unique inventory instance found.....!');
      px_error_rec.instance_id := l_instance_header_tbl(1).instance_id;

      debug('  Inventory Instance_ID :'||l_instance_header_tbl(1).instance_id);
      debug('  Instance Quantity     :'||l_instance_header_tbl(1).quantity );

      x_order_shipment_tbl(l_count).line_id            := mmt_rec.line_id ;
      x_order_shipment_tbl(l_count).header_id          := mmt_rec.header_id;
      x_order_shipment_tbl(l_count).instance_id        := l_instance_header_tbl(1).instance_id;
      x_order_shipment_tbl(l_count).instance_qty       := l_instance_header_tbl(1).quantity;
      x_order_shipment_tbl(l_count).party_id           := l_party_id;
      x_order_shipment_tbl(l_count).party_source_table := 'HZ_PARTIES';
      x_order_shipment_tbl(l_count).party_account_id   := mmt_rec.end_customer_id; -- mmt_rec.sold_to_org_id;
      x_order_shipment_tbl(l_count).inventory_item_id  := mmt_rec.inventory_item_id ;
      x_order_shipment_tbl(l_count).organization_id    := mmt_rec.inv_organization_id ;
      x_order_shipment_tbl(l_count).revision           := mmt_rec.revision;
      x_order_shipment_tbl(l_count).subinventory       := mmt_rec.subinventory ;
      x_order_shipment_tbl(l_count).locator_id         := mmt_rec.locator_id ;
      x_order_shipment_tbl(l_count).lot_number         := mmt_rec.lot_number ;
      x_order_shipment_tbl(l_count).serial_number      := mmt_rec.serial_number  ;
      x_order_shipment_tbl(l_count).transaction_uom    := mmt_rec.transaction_uom  ;
      x_order_shipment_tbl(l_count).order_quantity_uom := mmt_rec.order_quantity_uom  ;
      x_order_shipment_tbl(l_count).invoice_to_org_id  := mmt_rec.invoice_to_org_id;
      x_order_shipment_tbl(l_count).line_type_id       := mmt_rec.line_type_id  ;
      x_order_shipment_tbl(l_count).ordered_quantity   := mmt_rec.ordered_quantity;
      x_order_shipment_tbl(l_count).ship_to_contact_id := mmt_rec.ship_to_contact_id;
      x_order_shipment_tbl(l_count).ship_to_org_id     := mmt_rec.ship_to_org_id  ;
      x_order_shipment_tbl(l_count).ship_from_org_id   := mmt_rec.ship_from_org_id ;
      x_order_shipment_tbl(l_count).sold_to_org_id     := mmt_rec.sold_to_org_id  ;
      x_order_shipment_tbl(l_count).sold_from_org_id   := mmt_rec.sold_from_org_id ;

      /* added this if condition for the bug 2356340 */
      /* Added 2 and 5 as part of fix for Bug 3089110 */

      IF mmt_rec.serial_number_control_code in (2,5,6) THEN
        x_order_shipment_tbl(l_count).shipped_quantity := 1;
      ELSE
        x_order_shipment_tbl(l_count).shipped_quantity := l_shipped_qty;
      END IF;

      x_order_shipment_tbl(l_count).customer_id        := mmt_rec.end_customer_id; -- mmt_rec.sold_to_org_id ;
      x_order_shipment_tbl(l_count).transaction_date   := mmt_rec.transaction_date ;
      x_order_shipment_tbl(l_count).item_type_code     := mmt_rec.item_type_code ;
      x_order_shipment_tbl(l_count).cust_po_number     := mmt_rec.cust_po_number ;
      x_order_shipment_tbl(l_count).ato_line_id        := mmt_rec.ato_line_id ;
      x_order_shipment_tbl(l_count).top_model_line_id  := mmt_rec.top_model_line_id ;
      x_order_shipment_tbl(l_count).link_to_line_id    := mmt_rec.link_to_line_id ;
      x_order_shipment_tbl(l_count).instance_match     := 'N' ;
      x_order_shipment_tbl(l_count).quantity_match     := 'N' ;
      -- Added lot_match for bug 3384668
      x_order_shipment_tbl(l_count).lot_match          := 'N' ;
      x_order_shipment_tbl(l_count).invoice_to_contact_id   := mmt_rec.invoice_to_contact_id ;
      x_order_shipment_tbl(l_count).ord_line_shipped_qty    :=  mmt_rec.ord_line_shipped_qty;
      x_order_shipment_tbl(l_count).inst_obj_version_number :=  l_instance_header_tbl(1).object_version_number;
      -- Added for Partner Ordering.
      x_order_shipment_tbl(l_count).ib_install_loc_id  := mmt_rec.ib_install_loc_id;
      x_order_shipment_tbl(l_count).ib_current_loc_id  := mmt_rec.ib_current_loc_id;
      x_order_shipment_tbl(l_count).ib_install_loc     := mmt_rec.ib_install_loc;
      x_order_shipment_tbl(l_count).ib_current_loc     := mmt_rec.ib_current_loc;
      -- Begin Fix for Bug 3361434
      x_order_shipment_tbl(l_count).end_customer_id    := mmt_rec.end_customer_id;
      -- End Fix for Bug 3361434
      -- Begin Add Code for Siebel Genesis Project
      IF (mmt_rec.order_source_id = '28' OR mmt_rec.order_source_id = '29')
      THEN
         x_order_shipment_tbl(l_count).source_code := 'SIEBEL';
      END IF;
      -- End Add Code for Siebel Genesis Project
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_order_shipment_rec;

  /* To build  the matched txn line details if entered for order line .  */
  /* If txn line details does not exist then it creates one from the     */
  /* shipment details. Also it builds the COMPONENT-OF relationship if   */
  /* there is a top model for that order line                            */

  PROCEDURE build_shtd_table(
    p_mtl_transaction_id  IN     number,
    p_order_line_rec      IN OUT NOCOPY order_line_rec,
    p_txn_sub_type_rec    IN     txn_sub_type_rec,
    p_trx_detail_exist    IN     boolean,
    p_trackable_parent    IN     boolean,
    p_transaction_rec     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_order_shipment_tbl     OUT NOCOPY order_shipment_tbl,
    px_error_rec          IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS
    x_msg_count                number;
    x_msg_data                 varchar2(2000);
    x_trx_line_id              number;

    l_txn_line_rec              csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_dtl_query_rec    csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_txn_line_detail_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_detail_tbl      csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_detail_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_ii_rltns_tbl          csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_ext_attrib_vals_tbl   csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ext_attribs_tbl       csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_extend_attrib_values_tbl  csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_org_assgn_tbl         csi_t_datastructures_grp.txn_org_assgn_tbl  ;
    l_txn_systems_tbl           csi_t_datastructures_grp.txn_systems_tbl;

    l_upd_txn_line_rec          csi_t_datastructures_grp.txn_line_rec;
    l_upd_txn_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    l_upd_txn_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_upd_txn_party_detail_tbl  csi_t_datastructures_grp.txn_party_detail_tbl;
    l_upd_txn_pty_acct_dtl_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_upd_txn_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_upd_txn_ext_attr_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    x_model_inst_tbl            model_inst_tbl;
    l_qty_ratio                 number;
    l_model_exist               boolean := FALSE;

    l_return_status             varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                 number;
    l_msg_data                  varchar2(2000);

    -- Included Transaction rec as part of fix for Bug 2767338
    l_trx_rec                   csi_datastructures_pub.transaction_rec;

    ---Added (Start) for m-to-m enhancements
    l_temp_txn_ii_rltns_tbl   csi_t_datastructures_grp.txn_ii_rltns_tbl;
    ---Added (End) for m-to-m enhancements

    l_parent_line_qty           NUMBER := fnd_api.g_miss_num;
    --
    -- srramakr Added for TSO With Equipment
    l_om_session_key            csi_utility_grp.config_session_key;
    l_macd_processing           BOOLEAN     := FALSE;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    -- Included Transaction rec as part of fix for Bug 2767338
    l_trx_rec := p_transaction_rec;

    api_log('build_shtd_table');

    /* Build the Shipment table for the mtl_trx_id */
    -- Included Transaction rec as part of fix for Bug 2767338
    get_order_shipment_rec(
      p_mtl_transaction_id  => p_mtl_transaction_id,
      p_order_line_rec      => p_order_line_rec,
      p_txn_sub_type_rec    => p_txn_sub_type_rec,
      p_transaction_rec     => l_trx_rec,
      x_order_shipment_tbl  => x_order_shipment_tbl,
      px_error_rec          => px_error_rec,
      x_return_status       => l_return_status );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    debug('  order_shipment_tbl.count :'||x_order_shipment_tbl.count);

    /* Get the instances for the option class/model line_id (ATO/PTO) */
    IF NVL(p_order_line_rec.link_to_line_id ,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      x_model_inst_tbl.delete;
      --
      -- srramakr Added for TSO with Equipment
      l_om_session_key.session_hdr_id := p_order_line_rec.config_header_id;
      l_om_session_key.session_rev_num := p_order_line_rec.config_rev_nbr;
      l_om_session_key.session_item_id := p_order_line_rec.configuration_id;
      --
      l_macd_processing := csi_interface_pkg.check_macd_processing
                               ( p_config_session_key => l_om_session_key,
                                 x_return_status      => l_return_status
                               );
      --
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      --
      IF NOT l_macd_processing THEN
         csi_utl_pkg.get_model_inst_lst(
           p_parent_line_id => p_order_line_rec.link_to_line_id,
           x_model_inst_tbl => x_model_inst_tbl,
           x_return_status  => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           raise fnd_api.g_exc_error;
         END IF;
      ELSE -- MACD Order Line
         p_order_line_rec.macd_order_line := FND_API.G_TRUE;
      END IF; -- MACD Processing check
      -- srramakr End of TSO with Equipment
      --
      debug('  model_inst_tbl.count :'||x_model_inst_tbl.count);

      IF x_model_inst_tbl.COUNT > 0 THEN
        l_model_exist := TRUE;
      ELSE
        l_model_exist := FALSE;
      END IF;

    END IF;

    /* ---------------------------------------------------*/
    /*   The following scenarios are handled              */
    /*        1.Transaction line Details does not exist   */
    /*           1.1 Partial                              */
    /*           1.2 Full                                 */
    /*           1.3 Config (ATO)                         */
    /*           1.4 Option items (PTO)                   */
    /*        2.Transaction line details exist            */
    /*            1.1 Partial                             */
    /*            1.2 Full                                */
    /*  --------------------------------------------------*/
    IF NOT(p_trx_detail_exist )  THEN
      /* Txn details does not exist for the order line*/
      IF p_order_line_rec.item_type_code = 'CONFIG' THEN

        create_dflt_td_from_ship(
          p_serial_code         => p_order_line_rec.serial_code,
          p_order_line_rec      => p_order_line_rec,
          p_trackable_parent    => TRUE,
          px_order_shipment_tbl => x_order_shipment_tbl,
          x_transaction_line_id => x_trx_line_id,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

      ELSIF p_order_line_rec.item_type_code = 'OPTION' THEN

        process_option_item(
          p_serial_code        => p_order_line_rec.serial_code,
          p_txn_sub_type_rec   => p_txn_sub_type_rec,
          p_order_line_rec     => p_order_line_rec,
	  p_trackable_parent   => p_trackable_parent,
          x_order_shipment_tbl => x_order_shipment_tbl,
          x_model_inst_tbl     => x_model_inst_tbl,
          x_trx_line_id        => x_trx_line_id,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

      ELSE

        IF l_model_exist THEN

          process_option_item(
            p_serial_code        => p_order_line_rec.serial_code,
            p_txn_sub_type_rec   => p_txn_sub_type_rec,
            p_order_line_rec     => p_order_line_rec,
	    p_trackable_parent   => p_trackable_parent,
            x_order_shipment_tbl => x_order_shipment_tbl,
            x_model_inst_tbl     => x_model_inst_tbl,
            x_trx_line_id        => x_trx_line_id,
            x_return_status      => l_return_status );

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

        ELSE -- create transaction details

          create_dflt_td_from_ship(
            p_serial_code         => p_order_line_rec.serial_code,
            p_order_line_rec      => p_order_line_rec,
            p_trackable_parent    => p_trackable_parent,
            px_order_shipment_tbl => x_order_shipment_tbl,
            x_transaction_line_id => x_trx_line_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

        END IF;

      END IF;

      p_order_line_rec.trx_line_id :=  x_trx_line_id ;

    ELSE

      /*--------------------------------------------*/
      /* If txn details exist then Get txn details  */
      /* and match it with shipment table           */
      /*--------------------------------------------*/

      x_trx_line_id       := p_order_line_rec.trx_line_id;
      l_txn_line_query_rec.source_transaction_id    := p_order_line_rec.order_line_id;
      l_txn_line_query_rec.source_transaction_table := 'WSH_DELIVERY_DETAILS';
      l_txn_line_dtl_query_rec.processing_status    := 'UNPROCESSED';

      debug('Getting installation details for matching with material transaction info.' );

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version               => 1.0,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_true,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_txn_line_query_rec        => l_txn_line_query_rec,
        p_txn_line_detail_query_rec => l_txn_line_dtl_query_rec,
        x_txn_line_detail_tbl       => l_txn_line_detail_tbl,
        p_get_parties_flag          => fnd_api.g_false,
        x_txn_party_detail_tbl      => l_txn_party_detail_tbl,
        p_get_pty_accts_flag        => fnd_api.g_false,
        x_txn_pty_acct_detail_tbl   => l_txn_pty_acct_detail_tbl,
        p_get_ii_rltns_flag         => fnd_api.g_true,
        x_txn_ii_rltns_tbl          => l_txn_ii_rltns_tbl,
        p_get_org_assgns_flag       => fnd_api.g_false,
        x_txn_org_assgn_tbl         => l_txn_org_assgn_tbl,
        p_get_ext_attrib_vals_flag  => fnd_api.g_false,
        x_txn_ext_attrib_vals_tbl   => l_txn_ext_attrib_vals_tbl,
        p_get_csi_attribs_flag      => fnd_api.g_false,
        x_csi_ext_attribs_tbl       => l_csi_ext_attribs_tbl,
        p_get_csi_iea_values_flag   => fnd_api.g_false,
        x_csi_iea_values_tbl        => l_extend_attrib_values_tbl,
        p_get_txn_systems_flag      => fnd_api.g_false,
        x_txn_systems_tbl           => l_txn_systems_tbl,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

      debug('  txn_line_detail_tbl.count :'||l_txn_line_detail_tbl.count );
      debug('  txn_ii_rltns_tbl.count    :'||l_txn_ii_rltns_tbl.count );

      IF l_txn_line_detail_tbl.COUNT > 0 THEN

        construct_for_txn_exists(
          p_txn_sub_type_rec     => p_txn_sub_type_rec,
          p_order_line_rec       => p_order_line_rec,
          x_txn_line_detail_tbl  => l_txn_line_detail_tbl,
          x_txn_ii_rltns_tbl     => l_txn_ii_rltns_tbl,
          x_order_shipment_tbl   => x_order_shipment_tbl,
          x_return_status        => l_return_status );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
         raise fnd_api.g_exc_error;
       END IF;

       --Added (Start) for m-to-m enhancements
       --05/20 For each TLD in ,l_txn_line_detail_tbl
       --get the relations and append these relations to l_txn_ii_rltns_tbl.

       csi_utl_pkg.build_txn_relations(
         l_txn_line_detail_tbl,
         l_temp_txn_ii_rltns_tbl,
         l_return_status);

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
         raise fnd_api.g_exc_error;
       END IF;

       --Create these relations in csi_t_ii_relationships table

       IF l_temp_txn_ii_rltns_tbl.count > 0 THEN
         csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
           p_api_version       => 1.0,
           p_commit            => fnd_api.g_false,
           p_init_msg_list     => fnd_api.g_true,
           p_validation_level  => fnd_api.g_valid_level_full,
           px_txn_ii_rltns_tbl => l_temp_txn_ii_rltns_tbl,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           raise fnd_api.g_exc_error;
         END IF;
       END IF ; ---l_temp_txn_ii_rltns_tbl.count>0
       --added (end) for m-to-m enhancements
      ELSE

        IF p_order_line_rec.item_type_code = 'CONFIG' THEN

          create_dflt_td_from_ship(
            p_serial_code         => p_order_line_rec.serial_code,
            p_order_line_rec      => p_order_line_rec,
            p_trackable_parent    => TRUE ,
            px_order_shipment_tbl => x_order_shipment_tbl,
            x_transaction_line_id => x_trx_line_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

        ELSIF p_order_line_rec.item_type_code = 'OPTION' THEN

          process_option_item(
            p_serial_code        => p_order_line_rec.serial_code,
            p_txn_sub_type_rec   => p_txn_sub_type_rec,
            p_order_line_rec     => p_order_line_rec,
	    p_trackable_parent   => p_trackable_parent,
            x_order_shipment_tbl => x_order_shipment_tbl,
            x_model_inst_tbl     => x_model_inst_tbl,
            x_trx_line_id        => x_trx_line_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

        ELSE

          create_dflt_td_from_ship(
            p_serial_code         => p_order_line_rec.serial_code,
            p_order_line_rec      => p_order_line_rec,
            p_trackable_parent    => p_trackable_parent,
            px_order_shipment_tbl => x_order_shipment_tbl,
            x_transaction_line_id => x_trx_line_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

       END IF;
     END IF;
   END IF;

   /*-----------------------------------------------*/
   /* If top model exists for that order line       */
   /* then build the component-of relationship table*/
   /*-----------------------------------------------*/

   IF x_model_inst_tbl.count > 0 THEN

     debug('Instance exists for option class/Model, so building relation' );

     l_txn_line_query_rec.source_transaction_id       := p_order_line_rec.order_line_id;
     l_txn_line_query_rec.source_transaction_table    := 'WSH_DELIVERY_DETAILS';
     l_txn_line_dtl_query_rec.processing_status       := 'IN_PROCESS';
     l_txn_line_dtl_query_rec.source_transaction_flag := 'Y';

     debug('Getting only matched txn line dtls ' );

     csi_t_txn_details_grp.get_transaction_details(
        p_api_version           =>   1.0
       ,p_commit                =>   fnd_api.g_false
       ,p_init_msg_list         =>   fnd_api.g_true
       ,p_validation_level      =>   fnd_api.g_valid_level_full
       ,p_txn_line_query_rec    =>   l_txn_line_query_rec
       ,p_txn_line_detail_query_rec => l_txn_line_dtl_query_rec
       ,x_txn_line_detail_tbl   =>   l_txn_line_detail_tbl
       ,p_get_parties_flag      =>   fnd_api.g_false
       ,x_txn_party_detail_tbl  =>   l_txn_party_detail_tbl
       ,p_get_pty_accts_flag    =>   fnd_api.g_false
       ,x_txn_pty_acct_detail_tbl => l_txn_pty_acct_detail_tbl
        ---Added (Start) for m-to-m enhancements
        -- Now get the relations
       ,p_get_ii_rltns_flag     =>   fnd_api.g_true
        ---Added (End) for m-to-m enhancements
       ,x_txn_ii_rltns_tbl      =>   l_txn_ii_rltns_tbl
       ,p_get_org_assgns_flag   =>   fnd_api.g_false
       ,x_txn_org_assgn_tbl     =>   l_txn_org_assgn_tbl
       ,p_get_ext_attrib_vals_flag => fnd_api.g_false
       ,x_txn_ext_attrib_vals_tbl => l_txn_ext_attrib_vals_tbl
       ,p_get_csi_attribs_flag  =>   fnd_api.g_false
       ,x_csi_ext_attribs_tbl   =>   l_csi_ext_attribs_tbl
       ,p_get_csi_iea_values_flag => fnd_api.g_false
       ,x_csi_iea_values_tbl    =>   l_extend_attrib_values_tbl
       ,p_get_txn_systems_flag  =>   fnd_api.g_false
       ,x_txn_systems_tbl       =>   l_txn_systems_tbl
       ,x_return_status         =>   x_return_status
       ,x_msg_count             =>   x_msg_count
       ,x_msg_data              =>   x_msg_data      );

     IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
       raise fnd_api.g_exc_error;
     END IF;

     debug('l_txn_line_detail_tbl.count ='||l_txn_line_detail_tbl.count );

     csi_utl_pkg.get_qty_ratio(
       p_order_line_qty   => p_order_line_rec.ordered_quantity,
       p_link_to_line_id  => p_order_line_rec.link_to_line_id,
       p_order_item_id    => p_order_line_rec.inv_item_id,
       p_model_remnant_flag => p_order_line_rec.model_remnant_flag, --added for bug5096435
       x_qty_ratio        => l_qty_ratio ,
       x_return_status    => l_return_status );

     IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
       raise fnd_api.g_exc_error;
     END IF;

     debug('l_qty_ratio = '||l_qty_ratio );

     IF x_model_inst_tbl.count > 0 THEN
       FOR i in x_model_inst_tbl.first..x_model_inst_tbl.last
       LOOP
         x_model_inst_tbl(i).rem_qty      := l_qty_ratio;
         x_model_inst_tbl(i).process_flag := 'N';
       END LOOP;
     END IF;

     csi_utl_pkg.build_parent_relation(
       p_order_line_rec    => p_order_line_rec,
       x_model_inst_tbl    => x_model_inst_tbl,
       x_txn_line_dtl_tbl  => l_txn_line_detail_tbl,
       x_txn_ii_rltns_tbl  => l_txn_ii_rltns_tbl,
       x_return_status     => x_return_status  );

     IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
       raise fnd_api.g_exc_error;
     END IF;

     csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
       p_api_version       => 1.0,
       p_commit            => fnd_api.g_false,
       p_init_msg_list     => fnd_api.g_true,
       p_validation_level  => fnd_api.g_valid_level_full,
       px_txn_ii_rltns_tbl => l_txn_ii_rltns_tbl,
       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data);

     IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
       g_api_name := 'csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls';
       raise fnd_api.g_exc_error;
     END IF;

   END IF;

   l_txn_line_rec.source_transaction_table := 'WSH_DELIVERY_DETAILS';
   l_txn_line_rec.source_transaction_id    := p_order_line_rec.order_line_id;
   BEGIN
     SELECT transaction_line_id
     INTO   l_txn_line_rec.transaction_line_id
     FROM   csi_t_transaction_lines
     WHERE  source_transaction_id    = l_txn_line_rec.source_transaction_id
     AND    source_transaction_table = l_txn_line_rec.source_transaction_table;
   EXCEPTION
     WHEN no_data_found THEN
       null;
   END;

  IF NVL(p_order_line_rec.model_remnant_flag,'N') <> 'Y' THEN
    csi_utl_pkg.build_child_relation(
      p_order_line_rec     => p_order_line_rec,
      p_model_txn_line_rec => l_txn_line_rec,
      px_csi_txn_rec       => l_trx_rec,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

 END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END build_shtd_table;


  PROCEDURE check_return_processing(
    px_txn_line_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status         OUT NOCOPY    varchar2)
  IS
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_instance_usage_code   varchar2(30) := 'NULL';
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('check_return_processing');

    IF px_txn_line_detail_tbl.COUNT > 0 THEN
      FOR l_ind IN px_txn_line_detail_tbl.FIRST .. px_txn_line_detail_tbl.LAST
      LOOP
        IF px_txn_line_detail_tbl(l_ind).source_transaction_flag = 'Y'
           AND
           nvl(px_txn_line_detail_tbl(l_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN

          debug('  referred instance id :'||px_txn_line_detail_tbl(l_ind).instance_id);

          BEGIN
            SELECT instance_usage_code
            INTO   l_instance_usage_code
            FROM   csi_item_instances
            WHERE  instance_id = px_txn_line_detail_tbl(l_ind).instance_id;
          EXCEPTION
            WHEN no_data_found THEN
              l_instance_usage_code := 'NULL';
          END;

          debug('  instance usage code  :'||l_instance_usage_code);

          IF l_instance_usage_code = 'RETURNED' THEN
            px_txn_line_detail_tbl(l_ind).changed_instance_id :=
                                         px_txn_line_detail_tbl(l_ind).instance_id ;
            px_txn_line_detail_tbl(l_ind).instance_id         := null;
          END IF;
        END IF;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END check_return_processing;

  /*---------------------------------------------------------------*/
  /* Procedure does matching of txn line details with the shipment */
  /*---------------------------------------------------------------*/
  PROCEDURE construct_for_txn_exists(
    p_txn_sub_type_rec        IN  txn_sub_type_rec,
    p_order_line_rec          IN order_line_rec,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('construct_for_txn_exists');

    /* brmanesh - hooking this procedure to check if the instance referenced is a
       returned configured non serial instance . If yes then save this instance id in
       the changed_instance_id column in installation details and mark the record for
       return processing
    */
    check_return_processing(
      px_txn_line_detail_tbl  => x_txn_line_detail_tbl,
      x_return_status         => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    match_txn_with_ship(
      p_serial_code             => p_order_line_rec.serial_code,
      x_txn_line_detail_tbl     => x_txn_line_detail_tbl,
      x_order_shipment_tbl      => x_order_shipment_tbl,
      x_return_status           => l_return_status );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    process_txn_dtl(
      p_serial_code             => p_order_line_rec.serial_code,
      p_txn_sub_type_rec        => p_txn_sub_type_rec,
      p_order_line_rec          => p_order_line_rec,
      x_txn_line_detail_tbl     => x_txn_line_detail_tbl,
      x_txn_ii_rltns_tbl        => x_txn_ii_rltns_tbl,
      x_order_shipment_tbl      => x_order_shipment_tbl,
      x_return_status           => l_return_status );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END construct_for_txn_exists;

  /* ------------------------------------------------------------------------*/
  /* procedure compare if the inventory instance and the qty on the shipment */
  /* material transaction matches with the installation details and marks    */
  /* ------------------------------------------------------------------------*/

  PROCEDURE match_txn_with_ship(
    p_serial_code             IN number,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('match_txn_with_ship');
    debug('  order_shipment_tbl.count  :'||x_order_shipment_tbl.count );
    debug('  txn_line_detail_tbl.count :'||x_txn_line_detail_tbl.count);

    debug('Trying to match with the instance id.' );

    IF x_order_shipment_tbl.count > 0 THEN
      FOR i IN x_order_shipment_tbl.FIRST..x_order_shipment_tbl.LAST LOOP

        IF x_txn_line_detail_tbl.count > 0 THEN
          FOR j  IN x_txn_line_detail_tbl.FIRST..x_txn_line_detail_tbl.LAST LOOP

            IF x_txn_line_detail_tbl(j).source_transaction_flag = 'Y'
               AND
               x_txn_line_detail_tbl(j).processing_status in ('SUBMIT','ERROR')
            THEN

              debug('  td line_detail_id    :'||x_txn_line_detail_tbl(j).txn_line_detail_id);
              debug('  td instance_id       :'||x_txn_line_detail_tbl(j).instance_id);
              debug('  td quantity          :'||x_txn_line_detail_tbl(j).quantity);

              IF x_order_shipment_tbl(i).instance_id =
                                         NVL(x_txn_line_detail_tbl(j).instance_id,-1)
              THEN

                IF x_order_shipment_tbl(i).shipped_quantity =
                                           x_txn_line_detail_tbl(j).quantity
                THEN
                  x_txn_line_detail_tbl(j).processing_status := 'MATCH' ;
                  x_order_shipment_tbl(i).instance_match     := 'Y';
                  x_order_shipment_tbl(i).quantity_match     := 'Y';
                  -- Added lot_match for Bug 3384668
                  x_order_shipment_tbl(i).lot_match          := 'N';
                  x_order_shipment_tbl(i).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                  debug('INSTANCE AND QTY MATCH');
                  exit;
                ELSE
                  x_order_shipment_tbl(i).instance_match     := 'Y';
                  x_order_shipment_tbl(i).quantity_match     := 'N';
                  -- Added lot_match for Bug 3384668
                  x_order_shipment_tbl(i).lot_match          := 'N';
                  x_txn_line_detail_tbl(j).processing_status := 'INST_MATCH' ;
                  x_order_shipment_tbl(i).txn_line_detail_id :=  x_txn_line_detail_tbl(j).txn_line_detail_id;
                  debug('INSTANCE MATCH');
                END IF;
              END IF;
            END IF; -- processing status <> 'in_process'
          END LOOP; -- end of processing txn table
        END IF;
      END LOOP; -- end loop processing  shipment table
    END IF;  -- end if shipment table

    -- Begin fix for BUg 3384668
    debug('Trying to match with Lot Number ');
    IF x_order_shipment_tbl.count > 0
    THEN
      FOR i IN x_order_shipment_tbl.FIRST..x_order_shipment_tbl.LAST
      LOOP
        IF x_order_shipment_tbl(i).instance_match = 'N'
          AND
           x_order_shipment_tbl(i).quantity_match = 'N'
          AND
           x_order_shipment_tbl(i).lot_match      = 'N'
        THEN
          IF x_txn_line_detail_tbl.count > 0
          THEN
            FOR j  IN x_txn_line_detail_tbl.FIRST..x_txn_line_detail_tbl.LAST
            LOOP
              IF (x_txn_line_detail_tbl(j).source_transaction_flag = 'Y')
                AND
                 (x_txn_line_detail_tbl(j).processing_status in ('ERROR','NO_MATCH','SUBMIT'))
              THEN
                IF x_order_shipment_tbl(i).lot_number = NVL(x_txn_line_detail_tbl(j).lot_number,-1)
                THEN
                  debug('LOT MATCH for :'||x_txn_line_detail_tbl(j).lot_number);
                  debug('td line_detail_id    :'||x_txn_line_detail_tbl(j).txn_line_detail_id);
                  debug('td instance_id       :'||x_txn_line_detail_tbl(j).instance_id);
                  debug('td quantity          :'||x_txn_line_detail_tbl(j).quantity);

                  IF x_order_shipment_tbl(i).shipped_quantity = x_txn_line_detail_tbl(j).quantity
                  THEN
                    x_order_shipment_tbl(i).instance_match     := 'N';
                    x_order_shipment_tbl(i).lot_match          := 'Y';
                    x_order_shipment_tbl(i).quantity_match     := 'Y';
                    x_txn_line_detail_tbl(j).processing_status := 'MATCH' ;
                    x_order_shipment_tbl(i).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                    debug('LOT and QUANTITY Match');
                    exit;
                  ELSE
                    x_order_shipment_tbl(i).instance_match     := 'N';
                    x_order_shipment_tbl(i).lot_match          := 'Y';
                    x_order_shipment_tbl(i).quantity_match     := 'N';
                    x_txn_line_detail_tbl(j).processing_status := 'LOT_MATCH' ;
                    x_order_shipment_tbl(i).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                    debug('LOT Match');
                  END IF;
                END IF;
              END IF;
            END LOOP;
          END IF;
        END IF;
      END LOOP;
    END IF;
    -- End fix for BUg 3384668

    debug('Trying to match with the quantity.' );

    IF x_order_shipment_tbl.count > 0 THEN
      FOR i IN x_order_shipment_tbl.FIRST..x_order_shipment_tbl.LAST LOOP

        IF x_order_shipment_tbl(i).instance_match = 'N'
           and
           x_order_shipment_tbl(i).quantity_match = 'N'
           -- Added the followinh and condition for Bug 3384668
           and
           x_order_shipment_tbl(i).lot_match      = 'N'
        THEN

          IF x_txn_line_detail_tbl.count > 0 THEN
            FOR j  IN x_txn_line_detail_tbl.FIRST..x_txn_line_detail_tbl.LAST LOOP

              IF (x_txn_line_detail_tbl(j).source_transaction_flag = 'Y')
                  AND
                 (x_txn_line_detail_tbl(j).processing_status in ('ERROR','NO_MATCH','SUBMIT'))
              THEN

                debug('  td line_detail_id    :'||x_txn_line_detail_tbl(j).txn_line_detail_id);
                debug('  td instance_id       :'||x_txn_line_detail_tbl(j).instance_id);
                debug('  td quantity          :'||x_txn_line_detail_tbl(j).quantity);

                IF x_order_shipment_tbl(i).instance_id <> NVL(x_txn_line_detail_tbl(j).instance_id,-1)
                  -- added the following and condition for bug 3384668
                  and
                  -- added nvl for Bug 3523567
                   nvl(x_order_shipment_tbl(i).lot_number,'@#$') <> nvl(x_txn_line_detail_tbl(j).lot_number,'$#@')
                THEN
                  IF x_order_shipment_tbl(i).shipped_quantity = x_txn_line_detail_tbl(j).quantity
                  THEN

                    x_order_shipment_tbl(i).instance_match     :=  'N';
                    x_order_shipment_tbl(i).quantity_match     :=  'Y';
                    -- Added lot_match for Bug 3384668
                    x_order_shipment_tbl(i).lot_match          :=  'N';
                    x_txn_line_detail_tbl(j).processing_status :=  'QTY_MATCH' ;
                    x_order_shipment_tbl(i).txn_line_detail_id :=   x_txn_line_detail_tbl(j).txn_line_detail_id;
                    debug('QTY MATCH');
                    exit;
                  ELSE
                    x_order_shipment_tbl(i).instance_match     :=  'N';
                    x_order_shipment_tbl(i).quantity_match     :=  'N';
                    -- Added lot_match for Bug 3384668
                    x_order_shipment_tbl(i).lot_match          :=  'N';
                    x_txn_line_detail_tbl(j).processing_status :=  'NO_MATCH' ;
                    debug('NEITHER INSTANCE, LOT NUMBER OR QTY MATCH  ');
                  END IF;
                END IF;
              END IF; -- processing status <> 'in_process'
            END LOOP; -- end of processing txn table
          END IF;
        END IF; -- end if inst_match = N and qty_match = N
      END LOOP; -- end of processing shipment table
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END match_txn_with_ship;

  /*----------------------------------------------------------*/
  /* Description   :  Procedure that matches the unresolved   */
  /*   the txn line details and updates the txn line dtls     */
  /*   with the processing_status as "IN_PROCESS"             */
  /*----------------------------------------------------------*/

  PROCEDURE process_txn_dtl(
    p_serial_code             IN NUMBER,
    p_txn_sub_type_rec        IN txn_sub_type_rec,
    p_order_line_rec          IN order_line_rec,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl        IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    x_msg_count                 number ;
    x_msg_data                  varchar2(2000);
    l_upd                       number  := 1;
    l_exit_flag                 boolean := FALSE;
    l_config_exists             boolean := FALSE;
    l_tmp                       number;
    l_proc_qty                  number;
    l_total_proc_qty            number;
    l_rem_qty			number; --fix for bug 4354267

    l_upd_txn_line_rec          csi_t_datastructures_grp.txn_line_rec;
    l_upd_txn_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    l_upd_txn_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_upd_txn_party_detail_tbl  csi_t_datastructures_grp.txn_party_detail_tbl;
    l_upd_txn_pty_acct_dtl_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_upd_txn_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_upd_txn_ext_attr_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_return_status             varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                 number;
    l_msg_data                  varchar2(2000);

  BEGIN

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('process_txn_dtl');

    /* assign values for the columns in l_upd_txn_line_rec */
    l_upd_txn_line_rec.transaction_line_id        := p_order_line_rec.trx_line_id;
    l_upd_txn_line_rec.source_transaction_id      := p_order_line_rec.order_line_id;
    l_upd_txn_line_rec.source_transaction_type_id := g_txn_type_id;
    l_upd_txn_line_rec.source_transaction_table   := 'WSH_DELIVERY_DETAILS';

    /* Initialize the pl/sql tables used for processing */
    l_upd_txn_line_dtl_tbl.delete;
    l_upd_txn_ii_rltns_tbl.delete;
    l_upd_txn_party_detail_tbl.delete;
    l_upd_txn_pty_acct_dtl_tbl.delete ;
    l_upd_txn_org_assgn_tbl.delete;
    l_upd_txn_ext_attr_vals_tbl.delete;

    debug('  order_shipment_tbl.count  :'||x_order_shipment_tbl.count);
    debug('  txn_line_detail_tbl.count :'||x_txn_line_detail_tbl.count);

    IF x_order_shipment_tbl.count > 0 THEN
      FOR i IN x_order_shipment_tbl.FIRST..x_order_shipment_tbl.LAST
      LOOP

        IF ( x_order_shipment_tbl(i).instance_match  = 'Y'
             -- Added the or condition for bug 3384668
             OR
             x_order_shipment_tbl(i).lot_match = 'Y'
           )
           AND
           ( x_order_shipment_tbl(i).quantity_match  = 'N' )
        THEN

          debug('INSTANCE/LOT MATCH BUT QTY DOES NOT MATCH');

          IF x_txn_line_detail_tbl.count > 0 THEN
            FOR j in x_txn_line_detail_tbl.first..x_txn_line_detail_tbl.last
            LOOP

              IF x_txn_line_detail_tbl(j).source_transaction_flag = 'Y' AND
                 x_txn_line_detail_tbl(j).processing_status <> 'IN_PROCESS' THEN

                IF (x_txn_line_detail_tbl(j).txn_line_detail_id = x_order_shipment_tbl(i).txn_line_detail_id)
                  AND
                   (x_txn_line_detail_tbl(j).processing_status = 'INST_MATCH'
                    -- Added the or condition for bug 3384668
                    OR
                    x_txn_line_detail_tbl(j).processing_status = 'LOT_MATCH'
                   )
                THEN

                  debug('Checking if Config exists..  ');

                  l_config_exists := csi_utl_pkg.Check_config_exists(
                                       x_txn_ii_rltns_tbl,
                                       x_txn_line_detail_tbl(j).txn_line_detail_id);

                  IF l_config_exists AND
                     x_txn_line_detail_tbl(j).preserve_detail_flag = 'N' THEN

                    debug('Config exists so ignoring txn_dtls and creating one  ');

                    /* update the txn_line_detail as ERROR and create new txn_line_dtls*/

                    l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                    l_upd_txn_line_dtl_tbl(l_upd).processing_status  := 'ERROR';

                    csi_utl_pkg.create_txn_details(
                      x_txn_line_dtl_rec   => x_txn_line_detail_tbl(j),
                      p_txn_sub_type_rec   => p_txn_sub_type_rec,
                      p_order_shipment_rec => x_order_shipment_tbl(i),
                      p_order_line_rec     => p_order_line_rec,
                      x_return_status      => x_return_status);

                    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                      raise fnd_api.g_exc_error;
                    END IF;

                    l_upd := l_upd +1;

                    x_order_shipment_tbl(i).quantity_match := 'Y';
                    -- Added the IF/ELSE for 3384668
                    -- x_order_shipment_tbl(i).instance_match := 'Y';
                    IF x_order_shipment_tbl(i).instance_match  = 'Y'
                    THEN
                      x_order_shipment_tbl(i).instance_match := 'Y';
                    ELSE
                      x_order_shipment_tbl(i).lot_match := 'Y';
                    END IF;

                    x_txn_line_detail_tbl(j).processing_status := 'IN_PROCESS';
                    exit;
                  ELSE

                    IF x_order_shipment_tbl(i).shipped_quantity > x_txn_line_detail_tbl(j).quantity THEN

                      debug('shipped_qty > txn_dtl_qty  ');

                      /*---------------------------------------------------------*/
                      /* Process the txn_line_dtl and check if there are other   */
                      /* txn_line_dtls with the same instance. Else create a     */
                      /* txn_line_dtl with the shipment details for remaining qty*/
                      /*---------------------------------------------------------*/

                      l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                      l_upd_txn_line_dtl_tbl(l_upd).preserve_detail_flag := 'Y';
                      l_upd_txn_line_dtl_tbl(l_upd).serial_number     := x_order_shipment_tbl(i).serial_number;
                      l_upd_txn_line_dtl_tbl(l_upd).lot_number        := x_order_shipment_tbl(i).lot_number;
                      l_upd_txn_line_dtl_tbl(l_upd).inv_organization_id := x_order_shipment_tbl(i).organization_id;
                      l_upd_txn_line_dtl_tbl(l_upd).processing_status := 'IN_PROCESS';
                      l_upd_txn_line_dtl_tbl(l_upd).changed_instance_id := x_txn_line_detail_tbl(j).changed_instance_id;

                      -- Begin fix for Bug 3384668
                      l_upd_txn_line_dtl_tbl(l_upd).inventory_item_id   := x_order_shipment_tbl(i).inventory_item_id;
                      l_upd_txn_line_dtl_tbl(l_upd).instance_id         := x_order_shipment_tbl(i).instance_id;
                      -- End fix for Bug 3384668

                      /* Begin fix for Bug 2972082 cascade owner flag */
                      l_upd_txn_line_dtl_tbl(l_upd).cascade_owner_flag := x_txn_line_detail_tbl(j).cascade_owner_flag;
                      /* end fix for Bug 2972082 cascade owner flag */

                      l_proc_qty := x_order_shipment_tbl(i).shipped_quantity - x_txn_line_detail_tbl(j).quantity;
                      x_txn_line_detail_tbl(j).processing_status := 'IN_PROCESS';

                      debug('Remaining qty to process ='||l_proc_qty);

                      csi_utl_pkg.split_ship_rec(
                        x_upd_txn_line_dtl_tbl    => l_upd_txn_line_dtl_tbl,
                        x_txn_line_detail_tbl     => x_txn_line_detail_tbl,
                        x_txn_line_detail_rec     => x_txn_line_detail_tbl(j),
                        p_txn_sub_type_rec        => p_txn_sub_type_rec,
                        p_order_shipment_rec      => x_order_shipment_tbl(i),
                        p_order_line_rec          => p_order_line_rec,
                        p_proc_qty                => l_proc_qty,
                        x_return_status           => x_return_status );

                      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                        raise fnd_api.g_exc_error;
                      END IF;

                      debug('After split_ship_rec ');
                      debug('  upd_txn_line_dtl_tbl.count  : '||l_upd_txn_line_dtl_tbl.count);
                      debug('  txn_line_detail_tbl.count   : '||x_txn_line_detail_tbl.count);

                      x_order_shipment_tbl(i).quantity_match := 'Y';
                      -- Added the IF/ELSE for 3384668
                      -- x_order_shipment_tbl(i).instance_match := 'Y';
                      IF x_order_shipment_tbl(i).instance_match  = 'Y'
                      THEN
                        x_order_shipment_tbl(i).instance_match := 'Y';
                      ELSE
                        x_order_shipment_tbl(i).lot_match := 'Y';
                      END IF;

                      l_upd := l_upd +1;

                      exit;

                    ELSIF x_txn_line_detail_tbl(j).quantity > x_order_shipment_tbl(i).shipped_quantity THEN

                      debug('shipped_qty < txn_dtl_qty  ');

                      /* update the txn_detail with the qty of difference between txn_line_dtls and shipment*/

                      l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id   := x_txn_line_detail_tbl(j).txn_line_detail_id;
                      -- Begin change for Bug 3384668
                      -- l_upd_txn_line_dtl_tbl(l_upd).quantity
                                               --  := x_txn_line_detail_tbl(j).quantity - x_order_shipment_tbl(i).shipped_quantity;
                      l_upd_txn_line_dtl_tbl(l_upd).quantity             := x_order_shipment_tbl(i).shipped_quantity;
                      -- End change for Bug 3384668
                      l_upd_txn_line_dtl_tbl(l_upd).inv_organization_id  := x_order_shipment_tbl(i).organization_id;
                      l_upd_txn_line_dtl_tbl(l_upd).serial_number        := x_order_shipment_tbl(i).serial_number;
                      l_upd_txn_line_dtl_tbl(l_upd).lot_number           := x_order_shipment_tbl(i).lot_number;
                      l_upd_txn_line_dtl_tbl(l_upd).processing_status    := 'IN_PROCESS';
                      l_upd_txn_line_dtl_tbl(l_upd).preserve_detail_flag := 'Y';
                      l_upd_txn_line_dtl_tbl(l_upd).changed_instance_id  :=
                             x_txn_line_detail_tbl(j).changed_instance_id;

                      -- Begin fix for Bug 3384668
                      l_upd_txn_line_dtl_tbl(l_upd).inventory_item_id   := x_order_shipment_tbl(i).inventory_item_id;
                      l_upd_txn_line_dtl_tbl(l_upd).instance_id         := x_order_shipment_tbl(i).instance_id;
                      -- End fix for Bug 3384668

                      /* Begin fix for Bug 2972082 cascade owner flag */
                      l_upd_txn_line_dtl_tbl(l_upd).cascade_owner_flag := x_txn_line_detail_tbl(j).cascade_owner_flag;
                      /* end fix for Bug 2972082 cascade owner flag */

                      debug('shipped_qty ='||x_order_shipment_tbl(i).shipped_quantity);
                      debug('txn_qty     ='||x_txn_line_detail_tbl(j).quantity);

                      /* create_txn_line_dtls with the shipped qty */
                      csi_utl_pkg.create_txn_details(
                        x_txn_line_dtl_rec        => x_txn_line_detail_tbl(j),
                        p_txn_sub_type_rec        => p_txn_sub_type_rec,
                        p_order_shipment_rec      => x_order_shipment_tbl(i),
                        p_order_line_rec          => p_order_line_rec,
                        x_return_status           => x_return_status );

                      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                        raise fnd_api.g_exc_error;
                      END IF;

                      UPDATE csi_t_txn_line_details
                      SET processing_status = 'SUBMIT'
                      WHERE txn_line_detail_id = x_txn_line_detail_tbl(j).txn_line_detail_id;

                      l_upd := l_upd +1;

                      x_order_shipment_tbl(i).quantity_match := 'Y';
                      -- Added the IF/ELSE for 3384668
                      -- x_order_shipment_tbl(i).instance_match := 'Y';
                      IF x_order_shipment_tbl(i).instance_match  = 'Y'
                      THEN
                        x_order_shipment_tbl(i).instance_match := 'Y';
                      ELSE
                        x_order_shipment_tbl(i).lot_match := 'Y';
                      END IF;
                      x_txn_line_detail_tbl(j).processing_status := 'IN_PROCESS';

                      exit;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END LOOP;
          END IF;
        ELSIF ( x_order_shipment_tbl(i).instance_match  = 'Y'
               -- added the or condition for bug 3384668
                OR
                x_order_shipment_tbl(i).lot_match = 'Y'
              )
              AND
              ( x_order_shipment_tbl(i).quantity_match  = 'Y' )
        THEN

          debug('BOTH INSTANCE/LOT AND QTY MATCH ');

          IF x_txn_line_detail_tbl.count > 0 THEN
            FOR j in x_txn_line_detail_tbl.first..x_txn_line_detail_tbl.last LOOP

              -- debug('txn_line_detail_id ='||x_txn_line_detail_tbl(j).txn_line_detail_id);

              IF x_txn_line_detail_tbl(j).source_transaction_flag = 'Y' AND
                 x_txn_line_detail_tbl(j).processing_status <> 'IN_PROCESS' THEN

                IF (x_txn_line_detail_tbl(j).txn_line_detail_id = x_order_shipment_tbl(i).txn_line_detail_id ) AND
                   (x_txn_line_detail_tbl(j).processing_status  = 'MATCH'  ) THEN

                  /* Process the txn_line_dtls as both instance and qty matches */

                  debug('Processing the txn_dtl  ');

                  l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                  l_upd_txn_line_dtl_tbl(l_upd).processing_status := 'IN_PROCESS' ;
                  l_upd_txn_line_dtl_tbl(l_upd).preserve_detail_flag := 'Y';
                  l_upd_txn_line_dtl_tbl(l_upd).serial_number     := x_order_shipment_tbl(i).serial_number;
                  l_upd_txn_line_dtl_tbl(l_upd).lot_number        := x_order_shipment_tbl(i).lot_number;
                  l_upd_txn_line_dtl_tbl(l_upd).inv_organization_id := x_order_shipment_tbl(i).organization_id;

                  -- Begin fix for Bug 3384668
                  l_upd_txn_line_dtl_tbl(l_upd).inventory_item_id   := x_order_shipment_tbl(i).inventory_item_id;
                  l_upd_txn_line_dtl_tbl(l_upd).instance_id         := x_order_shipment_tbl(i).instance_id;
                  l_upd_txn_line_dtl_tbl(l_upd).changed_instance_id := x_txn_line_detail_tbl(j).changed_instance_id;
                  -- End fix for Bug 3384668

                  /* Begin fix for Bug 2972082 cascade owner flag */
                  l_upd_txn_line_dtl_tbl(l_upd).cascade_owner_flag := x_txn_line_detail_tbl(j).cascade_owner_flag;
                  /* end fix for Bug 2972082 cascade owner flag */

                  l_upd := l_upd +1;

                  x_txn_line_detail_tbl(j).processing_status := 'IN_PROCESS';
                  x_order_shipment_tbl(i).quantity_match := 'Y';

                  -- Begin fix for Bug 3384668
                  IF x_order_shipment_tbl(i).lot_match = 'Y'
                  THEN
                     x_order_shipment_tbl(i).lot_match := 'Y';
                  ELSE
                  -- End fix for Bug 3384668
                     x_order_shipment_tbl(i).instance_match := 'Y';
                  END IF;
                  exit;
                END IF;
              END IF;

            END LOOP;
          END IF;

        ELSIF (x_order_shipment_tbl(i).instance_match   = 'N' )
               -- added the lot_match and condition for Bug 3384668
               AND
              (x_order_shipment_tbl(i).lot_match   = 'N' )
               AND
              (x_order_shipment_tbl(i).quantity_match   = 'Y' )
        THEN

          debug('QTY MATCH BUT INSTANCE/LOT DOES NOT MATCH ');

          IF x_txn_line_detail_tbl.count > 0 THEN
            FOR j in x_txn_line_detail_tbl.first..x_txn_line_detail_tbl.last LOOP

            IF x_txn_line_detail_tbl(j).source_transaction_flag = 'Y'
               AND
               x_txn_line_detail_tbl(j).processing_status <> 'IN_PROCESS'
            THEN

              IF x_txn_line_detail_tbl(j).txn_line_detail_id = x_order_shipment_tbl(i).txn_line_detail_id
                 AND
                 x_txn_line_detail_tbl(j).processing_status  = 'QTY_MATCH'
              THEN

                IF (x_txn_line_detail_tbl(j).instance_exists_flag = 'N' ) THEN

                  debug('No instance reference exists,so processing the txn line ');

                  /* update the txn_detail with the instance in shipping record */
                  l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id  :=
                                            x_txn_line_detail_tbl(j).txn_line_detail_id;
                  l_upd_txn_line_dtl_tbl(l_upd).instance_id         :=
                                            x_order_shipment_tbl(i).instance_id;
                  l_upd_txn_line_dtl_tbl(l_upd).instance_exists_flag := 'Y';
                  l_upd_txn_line_dtl_tbl(l_upd).quantity            :=
                                            x_order_shipment_tbl(i).shipped_quantity;
                  l_upd_txn_line_dtl_tbl(l_upd).preserve_detail_flag := 'Y';
                  l_upd_txn_line_dtl_tbl(l_upd).serial_number       :=
                                            x_order_shipment_tbl(i).serial_number;
                  l_upd_txn_line_dtl_tbl(l_upd).lot_number          :=
                                            x_order_shipment_tbl(i).lot_number;
                  l_upd_txn_line_dtl_tbl(l_upd).processing_status   := 'IN_PROCESS';
                  l_upd_txn_line_dtl_tbl(l_upd).inv_organization_id :=
                                            x_order_shipment_tbl(i).organization_id;
                  l_upd_txn_line_dtl_tbl(l_upd).inventory_item_id   :=
                                            x_order_shipment_tbl(i).inventory_item_id;
                  l_upd_txn_line_dtl_tbl(l_upd).changed_instance_id :=
                                            x_txn_line_detail_tbl(j).changed_instance_id;
                  /* Begin fix for Bug 2972082 cascade owner flag */
                  l_upd_txn_line_dtl_tbl(l_upd).cascade_owner_flag  :=
                                            x_txn_line_detail_tbl(j).cascade_owner_flag;
                  /* end fix for Bug 2972082 cascade owner flag */
                  l_upd := l_upd +1;
                  exit;
                ELSE

                  debug('Checking if config exists ');

                  l_config_exists := csi_utl_pkg.Check_config_exists(
                                       x_txn_ii_rltns_tbl,
                                       x_txn_line_detail_tbl(j).txn_line_detail_id);
                  IF l_config_exists
                     AND
                     x_txn_line_detail_tbl(j).preserve_detail_flag = 'N'
                  THEN

                    /* update the txn_dtls as errored and create txn_dtls from shipping rec */

                    l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
                    l_upd_txn_line_dtl_tbl(l_upd).processing_status := 'ERROR' ;
                    l_upd := l_upd +1;

                    debug('Config exists so ignoring the txn_line_dtl and creating one');

                    csi_utl_pkg.create_txn_details(
                      x_txn_line_dtl_rec        => x_txn_line_detail_tbl(j),
                      p_txn_sub_type_rec        => p_txn_sub_type_rec,
                      p_order_shipment_rec      => x_order_shipment_tbl(i),
                      p_order_line_rec          => p_order_line_rec,
                      x_return_status           => x_return_status );

                    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                      raise fnd_api.g_exc_error;
                    END IF;

                    x_order_shipment_tbl(i).quantity_match := 'Y';
                    x_order_shipment_tbl(i).instance_match := 'Y';
                    x_txn_line_detail_tbl(j).processing_status := 'MATCH';
                    exit;
                  ELSE

                    /*update the txn_detail with the instance in shipping record */

                    debug('Config does not exists, so processing the txn line dtls ');

                    l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id   :=
                                           x_txn_line_detail_tbl(j).txn_line_detail_id;
                    l_upd_txn_line_dtl_tbl(l_upd).instance_id          :=
                                           x_order_shipment_tbl(i).instance_id;
                    l_upd_txn_line_dtl_tbl(l_upd).instance_exists_flag := 'Y';
                    l_upd_txn_line_dtl_tbl(l_upd).quantity             :=
                                           x_order_shipment_tbl(i).shipped_quantity;
                    l_upd_txn_line_dtl_tbl(l_upd).preserve_detail_flag := 'Y';
                    l_upd_txn_line_dtl_tbl(l_upd).serial_number        :=
                                           x_order_shipment_tbl(i).serial_number;
                    l_upd_txn_line_dtl_tbl(l_upd).lot_number           :=
                                           x_order_shipment_tbl(i).lot_number;
                    l_upd_txn_line_dtl_tbl(l_upd).processing_status    := 'IN_PROCESS';
                    l_upd_txn_line_dtl_tbl(l_upd).inv_organization_id  :=
                                           x_order_shipment_tbl(i).organization_id;
                    l_upd_txn_line_dtl_tbl(l_upd).changed_instance_id  :=
                                           x_txn_line_detail_tbl(j).changed_instance_id;
                /* Added  the item id assignment for bug 3734427 */
                    l_upd_txn_line_dtl_tbl(l_upd).inventory_item_id   :=
                                            x_order_shipment_tbl(i).inventory_item_id;
                    /* Begin fix for Bug 2972082 cascade owner flag */
                    l_upd_txn_line_dtl_tbl(l_upd).cascade_owner_flag   :=
                                           x_txn_line_detail_tbl(j).cascade_owner_flag;
                    /* end fix for Bug 2972082 cascade owner flag */

                    l_upd := l_upd +1;

                    x_order_shipment_tbl(i).quantity_match := 'Y';
                    x_order_shipment_tbl(i).instance_match := 'Y';
                    x_txn_line_detail_tbl(j).processing_status := 'MATCH';
                    exit;
                  END IF;
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;
      ELSIF ( x_order_shipment_tbl(i).instance_match    = 'N' )
              AND
            ( x_order_shipment_tbl(i).quantity_match    = 'N' )
             -- added the and condition for bug 3384668
              AND
            ( x_order_shipment_tbl(i).lot_match = 'N' )
      THEN

    debug('NEITHER INSTANCE, LOT OR QTY MATCH ');
    l_total_proc_qty := x_order_shipment_tbl(i).shipped_quantity;

    debug('total_proc_qty :' ||l_total_proc_qty);

    IF x_txn_line_detail_tbl.count > 0 THEN
      FOR j in x_txn_line_detail_tbl.first..x_txn_line_detail_tbl.last LOOP

       IF x_txn_line_detail_tbl(j).source_transaction_flag = 'Y' AND
          x_txn_line_detail_tbl(j).processing_status <> 'IN_PROCESS' THEN

         IF x_txn_line_detail_tbl(j).instance_exists_flag = 'N' THEN

           debug('Checking if config exists ');

           l_config_exists := csi_utl_pkg.Check_config_exists
                                               (x_txn_ii_rltns_tbl,
                                                x_txn_line_detail_tbl(j).txn_line_detail_id);
           IF l_config_exists AND
             x_txn_line_detail_tbl(j).preserve_detail_flag = 'N'  THEN

             debug('Config exists so ignoring the txn_line_dtl and creating one');

             l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
             l_upd_txn_line_dtl_tbl(l_upd).processing_status := 'ERROR' ;

             x_order_shipment_tbl(i).quantity_match := 'Y';
             x_order_shipment_tbl(i).instance_match := 'Y';
             x_txn_line_detail_tbl(j).processing_status := 'ERROR';

             csi_utl_pkg.create_txn_details
             (x_txn_line_dtl_rec        => x_txn_line_detail_tbl(j)
             ,p_txn_sub_type_rec        => p_txn_sub_type_rec
             ,p_order_shipment_rec      => x_order_shipment_tbl(i)
             ,p_order_line_rec          => p_order_line_rec
             ,x_return_status           => x_return_status );

            IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
               raise fnd_api.g_exc_error;
            END IF;

            l_upd := l_upd +1;

            exit;
         ELSE

            debug('Config does not exist so processing the txn_line_dtl ');

            /* update txn_detail with the instance from shipping record */
            l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
            l_upd_txn_line_dtl_tbl(l_upd).instance_id       := x_order_shipment_tbl(i).instance_id;
            l_upd_txn_line_dtl_tbl(l_upd).serial_number := x_order_shipment_tbl(i).serial_number;
            IF nvl(x_order_shipment_tbl(i).serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
              l_upd_txn_line_dtl_tbl(l_upd).mfg_serial_number_flag := 'Y';
            END IF;
            debug('Serial Number :'||l_upd_txn_line_dtl_tbl(l_upd).serial_number);
            l_upd_txn_line_dtl_tbl(l_upd).lot_number        := x_order_shipment_tbl(i).lot_number;
            l_upd_txn_line_dtl_tbl(l_upd).preserve_detail_flag := 'Y';
            l_upd_txn_line_dtl_tbl(l_upd).instance_exists_flag := 'Y';
            l_upd_txn_line_dtl_tbl(l_upd).processing_status := 'IN_PROCESS';
            l_upd_txn_line_dtl_tbl(l_upd).inv_organization_id := x_order_shipment_tbl(i).organization_id;
         /* Added  the item id assignment for bug 3734427 */
            l_upd_txn_line_dtl_tbl(l_upd).inventory_item_id := x_order_shipment_tbl(i).inventory_item_id;

            /* Begin fix for Bug 2972082 cascade owner flag */
            l_upd_txn_line_dtl_tbl(l_upd).cascade_owner_flag   := x_txn_line_detail_tbl(j).cascade_owner_flag;
            /* end fix for Bug 2972082 cascade owner flag */

           IF l_total_proc_qty > x_txn_line_detail_tbl(j).quantity THEN
            l_total_proc_qty := l_total_proc_qty - x_txn_line_detail_tbl(j).quantity;
	   --Start of fix for bug 4354267
	   ELSIF l_total_proc_qty < x_txn_line_detail_tbl(j).quantity THEN
            l_upd_txn_line_dtl_tbl(l_upd).quantity := l_total_proc_qty;
            l_rem_qty   := x_txn_line_detail_tbl(j).quantity - l_total_proc_qty;
	    debug('Installation line detail quantity > mtl transaction quantity,so split line dtls');
            csi_utl_pkg.split_txn_dtls_with_qty(
            split_txn_dtl_id => x_txn_line_detail_tbl(j).txn_line_detail_id,
            p_split_qty      => l_rem_qty,
            x_return_status => l_return_status );
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                raise fnd_api.g_exc_error;
            END IF;
            exit;
	    --End of fix for bug 4354267
           ELSE
            l_upd_txn_line_dtl_tbl(l_upd).quantity := l_total_proc_qty;
            exit;
           END IF;

           x_order_shipment_tbl(i).quantity_match := 'Y';
           x_order_shipment_tbl(i).instance_match := 'Y';
           x_txn_line_detail_tbl(j).processing_status := 'IN_PROCESS';
           l_upd := l_upd +1;

           IF x_order_shipment_tbl.count > 1 THEN
             exit;
           END IF;

          END IF;
        ELSE

           debug('Instance reference exists so ignoring the txn_line_dtls and creating one ');

           l_upd_txn_line_dtl_tbl(l_upd).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
           l_upd_txn_line_dtl_tbl(l_upd).processing_status := 'ERROR' ;

           csi_utl_pkg.create_txn_details
           (x_txn_line_dtl_rec        => x_txn_line_detail_tbl(j)
           ,p_txn_sub_type_rec        => p_txn_sub_type_rec
           ,p_order_shipment_rec      => x_order_shipment_tbl(i)
           ,p_order_line_rec          => p_order_line_rec
           ,x_return_status           => x_return_status );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;

          l_upd := l_upd +1;

          x_txn_line_detail_tbl(j).processing_status := 'IN_PROCESS';
          x_order_shipment_tbl(i).quantity_match := 'Y';
          x_order_shipment_tbl(i).instance_match := 'Y';
          exit;

       END IF;
      END IF;

     END LOOP;
    END IF;
   END IF;

      END LOOP;
    END IF;

    debug('Stamping the transaction details with the material transaction info.');
    debug('  upd_txn_line_dtl_tbl.count :'||l_upd_txn_line_dtl_tbl.count);

    IF l_upd_txn_line_dtl_tbl.count > 0 then

      /* update the txn dtls with the processing status */

      csi_t_txn_details_grp.update_txn_line_dtls(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_none,
        p_txn_line_rec             => l_upd_txn_line_rec,
        p_txn_line_detail_tbl      => l_upd_txn_line_dtl_tbl,
        px_txn_ii_rltns_tbl        => l_upd_txn_ii_rltns_tbl,
        px_txn_party_detail_tbl    => l_upd_txn_party_detail_tbl,
        px_txn_pty_acct_detail_tbl => l_upd_txn_pty_acct_dtl_tbl,
        px_txn_org_assgn_tbl       => l_upd_txn_org_assgn_tbl,
        px_txn_ext_attrib_vals_tbl => l_upd_txn_ext_attr_vals_tbl,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data);

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        g_api_name := 'csi_t_txn_details_grp.update_txn_line_dtls';
        raise fnd_api.g_exc_error;
      END IF;

      debug('update_txn_line_dtls completed successfully');

    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END process_txn_dtl;

  PROCEDURE decrement_source_instance(
    p_instance_id    in number,
    p_quantity       in number,
    p_trx_rec        in OUT NOCOPY csi_datastructures_pub.transaction_rec,
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

    api_log('decrement_source_instance');


    l_instance_rec.instance_id := p_instance_id;

    SELECT object_version_number,
           quantity - p_quantity
    INTO   l_instance_rec.object_version_number,
           l_instance_rec.quantity
    FROM   csi_item_instances
    WHERE  instance_id = l_instance_rec.instance_id;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'update_item_instance',
      p_pkg_name => 'csi_item_instance_pub');

    csi_t_gen_utility_pvt.dump_csi_instance_rec(
      p_csi_instance_rec => l_instance_rec);

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
      p_txn_rec               => p_trx_rec,
      p_asset_assignment_tbl  => l_inst_asset_tbl,
      x_instance_id_lst       => l_inst_id_lst,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    -- For Bug 4057183
    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
      g_api_name := 'csi_item_instance_pub.update_item_instance';
      raise fnd_api.g_exc_error;
    END IF;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END decrement_source_instance;

  PROCEDURE dump_customer_products(
    p_cps_tbl                 IN customer_products_tbl)
  IS
    l_rec                     customer_product_rec;
  BEGIN
    IF p_cps_tbl.COUNT > 0 THEN

      debug('InstID     Quantity   LineID     TLDID      CSITxnID   Serial          Lot            ');
      debug('---------- ---------- ---------- ---------- ---------- --------------- ---------------');

      FOR l_ind IN p_cps_tbl.FIRST .. p_cps_tbl.LAST
      LOOP

        l_rec := p_cps_tbl(l_ind);

        debug(rpad(to_char(l_rec.instance_id), 11, ' ')||
              rpad(to_char(l_rec.quantity), 11, ' ')||
              rpad(to_char(l_rec.line_id), 11, ' ')||
              rpad(to_char(l_rec.txn_line_detail_id), 11, ' ')||
              rpad(to_char(l_rec.transaction_id), 11, ' ')||
              rpad(l_rec.serial_number, 16, ' ')||
              rpad(l_rec.lot_number, 16, ' '));

      END LOOP;

     END IF;

  END dump_customer_products;

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
        l_c_instance_rec.operational_status_code:= 'NOT_USED';

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

    x_splitted_instances := l_splitted_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_instance_using_ratio;

  PROCEDURE convert_wip_instance_to_cp(
    p_instance_id       IN  number,
    p_line_id           IN  number,
    p_csi_txn_rec       IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_party_site_id            number;
    l_owner_party_id           number;
    l_owner_account_id         number;

    l_order_line_rec           oe_order_lines_all%rowtype;
    l_order_header_rec         oe_order_headers_all%rowtype;

    l_location_type_code       varchar2(80);
    l_inst_object_ver_num      number;

    l_u_instance_rec           csi_datastructures_pub.instance_rec;
    l_u_party_tbl              csi_datastructures_pub.party_tbl;
    l_u_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
    l_u_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_u_ext_attrib_val_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_u_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_u_inst_id_lst            csi_datastructures_pub.id_tbl;

    l_instance_party_id        number;
    l_pty_object_ver_num       number;
    l_pa_object_ver_num        number;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('convert_wip_instance_to_cp');

    -- check if the instance is in WIP
    SELECT object_version_number,
           location_type_code
    INTO   l_inst_object_ver_num,
           l_location_type_code
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;

    SELECT * INTO l_order_line_rec
    FROM   oe_order_lines_all
    WHERE  line_id = p_line_id;

    SELECT * INTO l_order_header_rec
    FROM   oe_order_headers_all
    WHERE  header_id = l_order_line_rec.header_id;

    -- derive location

    IF l_order_line_rec.ship_to_org_id is null THEN
      l_order_line_rec.ship_to_org_id := l_order_header_rec.ship_to_org_id;
    END IF;

    IF l_order_line_rec.sold_from_org_id is null THEN
      l_order_line_rec.sold_from_org_id := l_order_header_rec.sold_from_org_id;
    END IF;

    IF l_order_line_rec.sold_to_org_id is null THEN
      l_order_line_rec.sold_to_org_id := l_order_header_rec.sold_to_org_id;
    END IF;

    IF l_order_line_rec.agreement_id is null THEN
      l_order_line_rec.agreement_id := l_order_header_rec.agreement_id;
    END IF;

    IF l_order_line_rec.ship_to_org_id is not null THEN

      BEGIN

        SELECT HCAS.party_site_id
        INTO   l_party_site_id
        FROM   hz_cust_site_uses_all  HCSU,
               hz_cust_acct_sites_all HCAS
        WHERE  HCSU.site_use_id       = l_order_line_rec.ship_to_org_id
        AND    HCAS.cust_acct_site_id = HCSU.cust_acct_site_id;

      EXCEPTION
        WHEN no_data_found THEN

          fnd_message.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
          fnd_message.set_token('SITE_USE_ID',l_order_line_rec.ship_to_org_id);
          fnd_message.set_token('SITE_USE_CODE','SHIP_TO');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
      END;

    END IF;

    -- update the instance to make it a cp
    l_u_instance_rec.instance_id              := p_instance_id ;
    l_u_instance_rec.vld_organization_id      := l_order_line_rec.ship_from_org_id;
    l_u_instance_rec.location_type_code       := 'HZ_PARTY_SITES';
    l_u_instance_rec.location_id              := l_party_site_id;
    l_u_instance_rec.install_location_type_code := 'HZ_PARTY_SITES';
    l_u_instance_rec.install_location_id      := l_party_site_id;
    l_u_instance_rec.accounting_class_code    := 'CUST_PROD';
    l_u_instance_rec.active_end_date          := null;
    l_u_instance_rec.instance_usage_code      := 'OUT_OF_ENTERPRISE';
    l_u_instance_rec.object_version_number    := l_inst_object_ver_num;

    -- build owner party

    SELECT party_id
    INTO   l_owner_party_id
    FROM   hz_cust_accounts
    WHERE  cust_account_id = l_order_line_rec.sold_to_org_id;

    SELECT instance_party_id,
           object_version_number
    INTO   l_instance_party_id,
           l_pty_object_ver_num
    FROM   csi_i_parties
    WHERE  instance_id = p_instance_id;

    l_u_party_tbl(1).instance_party_id      := l_instance_party_id;
    l_u_party_tbl(1).instance_id            := p_instance_id;
    l_u_party_tbl(1).party_id               := l_owner_party_id;
    l_u_party_tbl(1).party_source_table     := 'HZ_PARTIES';
    l_u_party_tbl(1).relationship_type_code := 'OWNER';
    l_u_party_tbl(1).contact_flag           := 'N';
    l_u_party_tbl(1).object_version_number  :=  l_pty_object_ver_num;

    -- build owner account
    l_owner_account_id := l_order_line_rec.sold_to_org_id;

    l_u_party_acct_tbl(1).ip_account_id          := fnd_api.g_miss_num;
    l_u_party_acct_tbl(1).party_account_id       := l_owner_account_id;
    l_u_party_acct_tbl(1).relationship_type_code := 'OWNER';
    l_u_party_acct_tbl(1).bill_to_address        := fnd_api.g_miss_num;
    l_u_party_acct_tbl(1).ship_to_address        := fnd_api.g_miss_num;
    l_u_party_acct_tbl(1).instance_party_id      := l_instance_party_id;
    l_u_party_acct_tbl(1).parent_tbl_index       := 1;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'update_item_instance',
      p_pkg_name => 'csi_item_instance_pub');

    csi_item_instance_pub.update_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_u_instance_rec,
      p_ext_attrib_values_tbl => l_u_ext_attrib_val_tbl,
      p_party_tbl             => l_u_party_tbl,
      p_account_tbl           => l_u_party_acct_tbl,
      p_pricing_attrib_tbl    => l_u_pricing_attribs_tbl,
      p_org_assignments_tbl   => l_u_org_units_tbl,
      p_txn_rec               => p_csi_txn_rec,
      p_asset_assignment_tbl  => l_u_inst_asset_tbl,
      x_instance_id_lst       => l_u_inst_id_lst,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    -- For Bug 4057183
    -- IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
    IF NOT(l_return_status in (fnd_api.g_ret_sts_success,'W')) THEN
      raise fnd_api.g_exc_error;
    END IF;

    debug('WIP instance is successfully converted to a CP.');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END convert_wip_instance_to_cp;

  PROCEDURE get_single_qty_instances(
    p_all_cps_tbl        IN     customer_products_tbl,
    x_single_cps_tbl        OUT nocopy customer_products_tbl)
  IS
    l_cps_tbl        customer_products_tbl;
    l_ind            binary_integer := 0;
  BEGIN
    IF p_all_cps_tbl.COUNT > 0 THEN
      FOR p_ind IN p_all_cps_tbl.FIRST .. p_all_cps_tbl.LAST
      LOOP
        IF p_all_cps_tbl(p_ind).quantity = 1 THEN
          l_ind := l_ind + 1;
          l_cps_tbl(l_ind) := p_all_cps_tbl(p_ind);
        END IF;
      END LOOP;
    END IF;
    x_single_cps_tbl := l_cps_tbl;
  END get_single_qty_instances;

  PROCEDURE get_comp_instances_from_wip(
    p_wip_entity_id   IN     number,
    p_organization_id IN     number,
    p_cps_tbl         IN     customer_products_tbl,
    px_csi_txn_rec    IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_iir_tbl            OUT nocopy csi_datastructures_pub.ii_relationship_tbl,
    x_return_status      OUT nocopy varchar2)
  IS

    l_cps_tbl                customer_products_tbl;
    l_qty_per_assy           number := 0;
    l_iir_ind                binary_integer := 0;
    l_iir_tbl                csi_datastructures_pub.ii_relationship_tbl;
    l_serial_code            number;

    l_splitted_instances     csi_datastructures_pub.instance_tbl;
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR req_cur IS
      SELECT wip.inventory_item_id,
             sum(required_quantity)     qty_required,
             sum(quantity_issued)       qty_issued,
             sum(quantity_per_assembly) qty_per_assy
      FROM   wip_requirement_operations wip,
             mtl_system_items           msi
      WHERE  wip_entity_id         = p_wip_entity_id
      AND    wip.organization_id   = p_organization_id
      AND    wip.inventory_item_id = msi.inventory_item_id
      AND    wip.organization_id   = msi.organization_id
      AND    nvl(msi.comms_nl_trackable_flag, 'N') = 'Y'
      AND    nvl(quantity_issued,0) > 0
      GROUP BY wip.inventory_item_id;

    CURSOR wip_nsrl_cur(p_item_id IN number) IS
      SELECT instance_id,
             quantity,
             serial_number
      FROM   csi_item_instances
      WHERE  inventory_item_id  = p_item_id
      AND    location_type_code = 'WIP'
      AND    wip_job_id         = p_wip_entity_id;

    CURSOR wip_inst_cur(p_item_id IN number, p_qty_per_assy IN number) IS
      SELECT instance_id,
             quantity,
             serial_number
      FROM   csi_item_instances
      WHERE  inventory_item_id  = p_item_id
      AND    location_type_code = 'WIP'
      AND    wip_job_id         = p_wip_entity_id
      AND    quantity          <= p_qty_per_assy;

    FUNCTION already_allocated(
      p_subject_id       IN number,
      p_iir_tbl          IN csi_datastructures_pub.ii_relationship_tbl)
    RETURN BOOLEAN
    IS
       l_allocated boolean := FALSE;
    BEGIN
      IF p_iir_tbl.COUNT > 0 THEN
        FOR l_ind IN p_iir_tbl.FIRST .. p_iir_tbl.LAST
        LOOP
          IF p_iir_tbl(l_ind).subject_id = p_subject_id THEN
            l_allocated := TRUE;
            exit;
          END IF;
        END LOOP;
      END IF;
      RETURN l_allocated;
    END already_allocated;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_comp_instances_from_wip');

    l_cps_tbl := p_cps_tbl;

    FOR req_rec IN req_cur
    LOOP

      IF req_rec.qty_per_assy > 0 THEN

        SELECT serial_number_control_code
        INTO   l_serial_code
        FROM   mtl_system_items
        WHERE  inventory_item_id = req_rec.inventory_item_id
        AND    organization_id   = p_organization_id;

        IF l_serial_code in (2, 5) THEN
          IF l_cps_tbl.count > 0 THEN
            FOR l_cp_ind IN l_cps_tbl.FIRST .. l_cps_tbl.LAST
            LOOP
              l_qty_per_assy := req_rec.qty_per_assy;
              FOR wip_inst_rec IN wip_inst_cur(req_rec.inventory_item_id, req_rec.qty_per_assy)
              LOOP
                IF l_qty_per_assy > 0 THEN
                  -- check in iir as subject and skip
                  IF NOT already_allocated(wip_inst_rec.instance_id, l_iir_tbl) THEN
                    l_iir_ind := l_iir_ind + 1;
                    l_iir_tbl(l_iir_ind).subject_id := wip_inst_rec.instance_id;
                    l_iir_tbl(l_iir_ind).object_id  := l_cps_tbl(l_cp_ind).instance_id;
                    l_iir_tbl(l_iir_ind).relationship_type_code := 'COMPONENT-OF';
                    l_qty_per_assy := l_qty_per_assy - 1;
                  END IF;
                END IF;
              END LOOP;
            END LOOP;
          END IF;

        ELSIF l_serial_code in (1, 6) THEN

          -- split_instance_by_ratio
          FOR wip_nsrl_rec IN wip_nsrl_cur(req_rec.inventory_item_id)
          LOOP

            split_instance_using_ratio(
              p_instance_id         => wip_nsrl_rec.instance_id,
              p_qty_ratio           => req_rec.qty_per_assy,
              p_qty_completed       => p_cps_tbl.count,
              p_organization_id     => p_organization_id,
              px_csi_txn_rec        => px_csi_txn_rec,
              x_splitted_instances  => l_splitted_instances,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END LOOP;

          IF l_cps_tbl.count > 0 THEN
            FOR l_cp_ind IN l_cps_tbl.FIRST .. l_cps_tbl.LAST
            LOOP
              FOR wip_inst_rec IN wip_inst_cur(req_rec.inventory_item_id, req_rec.qty_per_assy)
              LOOP
                -- check in iir as subject and skip
                IF NOT already_allocated(wip_inst_rec.instance_id, l_iir_tbl) THEN
                  l_iir_ind := l_iir_ind + 1;
                  l_iir_tbl(l_iir_ind).subject_id := wip_inst_rec.instance_id;
                  l_iir_tbl(l_iir_ind).object_id  := l_cps_tbl(l_cp_ind).instance_id;
                  l_iir_tbl(l_iir_ind).relationship_type_code := 'COMPONENT-OF';
                  exit;
                END IF;
              END LOOP;
            END LOOP;
          END IF;
        END IF;

      END IF;

    END LOOP;

    x_iir_tbl := l_iir_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_comp_instances_from_wip;

  PROCEDURE get_tld_set(
    px_tld_rec          IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_tld_party_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_tld_account_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_tld_oa_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_tld_ea_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    -- out set
    x_tld_party_tbl        OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_tld_account_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_tld_oa_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_tld_ea_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_create_flag      varchar2(1) := 'N';

    l_tld_party_tbl    csi_t_datastructures_grp.txn_party_detail_tbl;
    l_tld_account_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_tld_oa_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_tld_ea_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_p_ind            binary_integer := 0;
    l_a_ind            binary_integer := 0;
    l_oa_ind           binary_integer := 0;
    l_ea_ind           binary_integer := 0;
    l_iir_ind          binary_integer := 0;
    l_pa_ind           binary_integer := 0;

    p_ind            binary_integer := 0;
    a_ind            binary_integer := 0;
    oa_ind           binary_integer := 0;
    ea_ind           binary_integer := 0;
    iir_ind          binary_integer := 0;
    pa_ind           binary_integer := 0;

  BEGIN

    api_Log('get_tld_set');

    x_return_status := fnd_api.g_ret_sts_success;

    IF nvl(px_tld_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      l_create_flag := 'Y';
    ELSE
      l_create_flag := 'N';
    END IF;

    IF px_tld_party_tbl.COUNT > 0 THEN
      p_ind := 0;
      LOOP
        p_ind := px_tld_party_tbl.NEXT(p_ind);
        EXIT when p_ind is null;
        IF px_tld_party_tbl(p_ind).txn_line_detail_id = px_tld_rec.txn_line_detail_id THEN
          l_p_ind := l_p_ind + 1;
          l_tld_party_tbl(l_p_ind) := px_tld_party_tbl(p_ind);

          IF px_tld_account_tbl.COUNT > 0 THEN
            a_ind := 0;
            LOOP
              a_ind := px_tld_account_tbl.NEXT(a_ind);
              exit when a_ind is null;
              IF px_tld_account_tbl(a_ind).txn_party_detail_id =
                 px_tld_party_tbl(p_ind).txn_party_detail_id
              THEN
                l_a_ind := l_a_ind + 1;
                l_tld_account_tbl(l_a_ind) := px_tld_account_tbl(a_ind);
                px_tld_account_tbl.delete(a_ind);
              END IF;
            END LOOP;
          END IF;
          px_tld_party_tbl.DELETE(p_ind);
        END IF;
      END LOOP;
    END IF;

    IF px_tld_oa_tbl.COUNT > 0 THEN
      oa_ind := 0;
      LOOP
        oa_ind := px_tld_oa_tbl.NEXT(oa_ind);
        exit when oa_ind is null;
        IF px_tld_oa_tbl(oa_ind).txn_line_detail_id = px_tld_rec.txn_line_detail_id THEN
          l_oa_ind := l_oa_ind + 1;
          l_tld_oa_tbl(l_oa_ind) := px_tld_oa_tbl(oa_ind);
          px_tld_oa_tbl.delete(oa_ind);
        END IF;
      END LOOP;
    END IF;

    IF px_tld_ea_tbl.COUNT > 0 THEN
      ea_ind := 0;
      LOOP
        ea_ind := px_tld_ea_tbl.NEXT(ea_ind);
        exit when ea_ind is null;
        IF px_tld_ea_tbl(ea_ind).txn_line_detail_id = px_tld_rec.txn_line_detail_id THEN
          l_ea_ind := l_ea_ind + 1;
          l_tld_ea_tbl(l_ea_ind) := px_tld_ea_tbl(ea_ind);
          px_tld_ea_tbl.delete(ea_ind);
        END IF;
      END LOOP;
    END IF;

    debug('TLD set counts:');
    debug('  l_tld_party_tbl   :'||l_tld_party_tbl.COUNT);
    debug('  l_tld_account_tbl :'||l_tld_account_tbl.COUNT);
    debug('  l_tld_oa_tbl      :'||l_tld_oa_tbl.COUNT);
    debug('  l_tld_ea_tbl      :'||l_tld_ea_tbl.COUNT);

    x_tld_party_tbl    := l_tld_party_tbl;
    x_tld_account_tbl  := l_tld_account_tbl;
    x_tld_oa_tbl       := l_tld_oa_tbl;
    x_tld_ea_tbl       := l_tld_ea_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_tld_set;


  -- convert txn_systems in to csi_systems
  PROCEDURE create_csi_systems(
    px_csi_txn_rec     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_txn_systems_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    px_tld_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_system_exist     boolean := FALSE;
    l_system_rec       csi_datastructures_pub.system_rec;
    l_system_id        number;

    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count        number;
    l_msg_data         varchar2(2000);
  BEGIN

    x_return_status    :=  fnd_api.g_ret_sts_success;
    api_log('create_csi_systems');

    IF px_txn_systems_tbl.count > 0 THEN

      FOR ind in px_txn_systems_tbl.FIRST..px_txn_systems_tbl.LAST
      LOOP

        BEGIN
          SELECT system_id
          INTO   l_system_id
          FROM   csi_systems_vl
          WHERE  system_type_code = px_txn_systems_tbl(ind).system_type_code
          AND    name             = px_txn_systems_tbl(ind).system_name
          AND    customer_id      = px_txn_systems_tbl(ind).customer_id;

          debug('  CSI System ID :'||l_system_id);

          l_system_exist := TRUE;

        EXCEPTION
          WHEN no_data_found THEN
            l_system_exist := FALSE;
          WHEN too_many_rows THEN
            fnd_message.set_name('CSI','CSI_INT_MUL_SYS_FOUND');
            fnd_message.set_token('SYSTEM_NUMBER',px_txn_systems_tbl(ind).system_number);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END;

        IF NOT(l_system_exist) THEN
          csi_utl_pkg.get_system_tbl(
            p_txn_systems_rec  => px_txn_systems_tbl(ind),
            x_cre_systems_rec  => l_system_rec );

          csi_t_gen_utility_pvt.dump_api_info(
            p_pkg_name => 'csi_systems_pub',
            p_api_name => 'create_system');

          csi_systems_pub.create_system(
            p_api_version       => 1.0,
            p_commit            => fnd_api.g_false,
            p_init_msg_list     => fnd_api.g_true,
            p_validation_level  => fnd_api.g_valid_level_full,
            p_system_rec        => l_system_rec,
            p_txn_rec           => px_csi_txn_rec,
            x_system_id         => l_system_id,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('  CSI System Created Successfully. System ID :'||l_system_id);
        END IF;

        IF px_tld_tbl.count > 0 THEN
          FOR tld_ind IN px_tld_tbl.FIRST .. px_tld_tbl.LAST
          LOOP
            IF px_tld_tbl(tld_ind).transaction_system_id =
               px_txn_systems_tbl(ind).transaction_system_id
            THEN
               px_tld_tbl(tld_ind).csi_system_id  := l_system_id;
            END IF;
          END LOOP;
        END IF;

      END LOOP; -- txn systems loop
    END IF; -- end if for system table count > 0
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_csi_systems;


  PROCEDURE proc_for_last_mtl_trx(
    p_source              IN         varchar2,
    p_transaction_line_id IN         number,
    p_order_line_rec      IN         order_line_rec,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_order_quantity    number;
    l_total_qty         number := 0;
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_literal1   	VARCHAR2(30) := 'PROCESSED' ;
    l_literal2   	VARCHAR2(30) := 'OE_ORDER_LINES_ALL' ;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('proc_for_last_mtl_trx');

    IF p_source = 'FULFILLMENT' THEN
      l_order_quantity := p_order_line_rec.fulfilled_quantity;
    ELSIF p_source = 'SHIPMENT' THEN
      l_order_quantity := p_order_line_rec.shipped_quantity;
    END IF;

    BEGIN
      SELECT sum(quantity)
      INTO   l_total_qty
      FROM   csi_item_instances
      WHERE  last_oe_order_line_id = p_order_line_rec.order_line_id
      AND    inventory_item_id     = p_order_line_rec.inv_item_id;
    EXCEPTION
      WHEN others then
        l_total_qty := 0;
    END;

    debug('  order_quantity          : '||l_order_quantity);
    debug('  total_inst_qty_for_line : '||l_total_qty);

    IF l_total_qty >= l_order_quantity  THEN

      debug('  last transaction for this order line...!');

      UPDATE csi_t_txn_line_details a
      SET    error_code        = NULL,
             error_explanation = NULL ,
             processing_status = 'PROCESSED'
      WHERE  a.processing_status <> l_literal1
      AND    a.source_transaction_flag = 'Y'
      AND    a.inventory_item_id       = p_order_line_rec.inv_item_id
      AND    a.transaction_line_id in (SELECT transaction_line_id
				 FROM csi_t_transaction_lines b
                    WHERE -- a.transaction_line_id = b.transaction_line_id AND -- Commented for Perf Bug bug 4311676
                     b.source_transaction_id    = p_order_line_rec.order_line_id
                     AND  b.source_transaction_table = l_literal2 );

      UPDATE csi_t_transaction_lines
      SET    processing_status = 'PROCESSED'
      WHERE  source_transaction_id = p_order_line_rec.order_line_id;

      DELETE FROM csi_t_txn_line_details
      WHERE  transaction_line_id     = p_transaction_line_id
      AND    source_transaction_flag = 'Y'
      AND    processing_status      <> l_literal1;

      -- R12 changes because ATO Option funcillment will happen from the OM Code.
      /*
      IF p_source = 'SHIPMENT' AND p_order_line_rec.item_type_code = 'CONFIG' THEN
        debug('  ato config shipment. spawn shippable option lines for fulfillment.');
        process_ato_options(
          p_order_line_rec   => p_order_line_rec,
          x_return_status    => l_return_status);
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
      */

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
     WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END proc_for_last_mtl_trx ;

  PROCEDURE auto_split_instances(
    p_instance_rec            IN  csi_datastructures_pub.instance_rec,
    px_txn_rec                IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_tbl               OUT nocopy csi_datastructures_pub.instance_tbl,
    x_return_status              OUT nocopy varchar2)
  IS
    l_src_instance_rec        csi_datastructures_pub.instance_rec;
    l_instance_tbl            csi_datastructures_pub.instance_tbl;
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('auto_split_instances');

    l_src_instance_rec.instance_id                := p_instance_rec.instance_id ;
    l_src_instance_rec.vld_organization_id        := p_instance_rec.vld_organization_id;
    l_src_instance_rec.location_type_code         := p_instance_rec.location_type_code;
    l_src_instance_rec.location_id                := p_instance_rec.location_id;
    l_src_instance_rec.install_location_type_code := p_instance_rec.install_location_type_code;
    l_src_instance_rec.install_location_id        := p_instance_rec.install_location_id;
    l_src_instance_rec.instance_usage_code        := p_instance_rec.instance_usage_code;
    -- START changes for bug 4050897
    l_src_instance_rec.version_label              := p_instance_rec.version_label;
    l_src_instance_rec.instance_type_code         := p_instance_rec.instance_type_code;
    l_src_instance_rec.instance_condition_id      := p_instance_rec.instance_condition_id;
    l_src_instance_rec.return_by_date             := p_instance_rec.return_by_date;
    -- END changes for bug 4050897
    l_src_instance_rec.inv_organization_id        := null;
    l_src_instance_rec.inv_subinventory_name      := null;
    l_src_instance_rec.inv_locator_id             := null;
    l_src_instance_rec.pa_project_id              := null;
    l_src_instance_rec.pa_project_task_id         := null;
    l_src_instance_rec.wip_job_id                 := null;
    l_src_instance_rec.po_order_line_id           := null;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_item_instance_pvt',
      p_api_name => 'split_item_instance_lines');

    csi_item_instance_pvt.split_item_instance_lines(
      p_api_version            => 1.0,
      p_commit                 => fnd_api.g_false,
      p_init_msg_list          => fnd_api.g_true,
      p_validation_level       => fnd_api.g_valid_level_full,
      p_source_instance_rec    => l_src_instance_rec,
      p_copy_ext_attribs       => fnd_api.g_true,
      p_copy_org_assignments   => fnd_api.g_true,
      p_copy_parties           => fnd_api.g_true,
      p_copy_accounts          => fnd_api.g_true,
      p_copy_asset_assignments => fnd_api.g_true,
      p_copy_pricing_attribs   => fnd_api.g_true,
      p_txn_rec                => px_txn_rec,
      x_new_instance_tbl       => l_instance_tbl,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

    IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_instance_tbl := l_instance_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END auto_split_instances;

  PROCEDURE update_install_base(
    p_api_version             IN  number,
    p_commit                  IN  varchar2 := fnd_api.g_false,
    p_init_msg_list           IN  varchar2 := fnd_api.g_false,
    p_validation_level        IN  number   := fnd_api.g_valid_level_full,
    p_txn_line_rec            IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_detail_tbl     IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_party_detail_tbl    IN  OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_pty_acct_dtl_tbl    IN  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_txn_org_assgn_tbl       IN  OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_txn_ext_attrib_vals_tbl IN  OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    p_txn_ii_rltns_tbl        IN  OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_systems_tbl         IN  OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    p_pricing_attribs_tbl     IN  OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    p_order_line_rec          IN  order_line_rec,
    p_trx_rec                 IN  csi_datastructures_pub.transaction_rec,
    p_source                  IN  varchar2,
    p_validate_only           IN  varchar2,
    px_error_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT NOCOPY varchar2,
    x_msg_count               OUT NOCOPY number,
    x_msg_data                OUT NOCOPY varchar2)
  IS

    l_api_name          CONSTANT varchar2(30)   := 'update_install_base';
    l_api_version       CONSTANT NUMBER         := 1.0;
    l_csi_debug_level            varchar2(1);

    l_return_status              varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                  number;
    l_msg_data                   varchar2(2000);

    l_order_line_rec             order_line_rec;
    l_item_control_rec           item_control_rec;

    x_trx_sub_type_rec           txn_sub_type_rec;
    l_tmp_instance_rec           csi_datastructures_pub.instance_rec;
    l_upd_instance_rec           csi_datastructures_pub.instance_rec;
    l_upd_txn_rec                csi_datastructures_pub.transaction_rec;
    l_upd_party_tbl              csi_datastructures_pub.party_tbl;
    l_upd_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
    l_upd_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_upd_ext_attrib_val_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_upd_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_upd_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_inst_id_lst                csi_datastructures_pub.id_tbl;
    l_upd_ii_rltns_tbl           csi_datastructures_pub.ii_relationship_tbl;

    l_upd_so_instance_rec        csi_datastructures_pub.instance_rec;
    l_upd_so_party_tbl           csi_datastructures_pub.party_tbl;
    l_upd_so_party_acct_tbl      csi_datastructures_pub.party_account_tbl;
    l_upd_so_inst_asset_tbl      csi_datastructures_pub.instance_asset_tbl;
    l_upd_so_ext_attrib_val_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
    l_upd_so_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    l_upd_so_org_units_tbl       csi_datastructures_pub.organization_units_tbl;

    l_cre_instance_rec           csi_datastructures_pub.instance_rec;
    l_cre_txn_rec                csi_datastructures_pub.transaction_rec;
    l_cre_party_tbl              csi_datastructures_pub.party_tbl;
    l_cre_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
    l_cre_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_cre_ext_attrib_val_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_cre_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_cre_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_cre_ii_rltns_tbl           csi_datastructures_pub.ii_relationship_tbl;
    l_cre_systems_rec            csi_datastructures_pub.system_rec;

    l_txn_line_rec               csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_query_rec         csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_detail_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_detail_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_ii_rltns_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_ext_attrib_vals_tbl    csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ext_attribs_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_iea_values_tbl         csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_org_assgn_tbl          csi_t_datastructures_grp.txn_org_assgn_tbl  ;
    l_txn_systems_tbl            csi_t_datastructures_grp.txn_systems_tbl;

    l_upd_txn_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_upd_txn_party_detail_tbl   csi_t_datastructures_grp.txn_party_detail_tbl;
    l_upd_txn_pty_acct_dtl_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_upd_txn_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_upd_txn_ext_attr_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    /*  Pricing Attributes variables */
    l_old_index  NUMBER := 0;
    l_new_index  NUMBER := 0;
    l_old_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_new_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;

    /*  Extended Attributes variables */
    l_ext_old_index  NUMBER := 0;
    l_ext_new_index  NUMBER := 0;
    l_old_extended_attribs_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
    l_new_extended_attribs_tbl    csi_datastructures_pub.extend_attrib_values_tbl;

    /* Decrement and Increment Logic variables */
    l_un_exp_instance_rec         csi_datastructures_pub.instance_rec;
    l_un_exp_party_tbl            csi_datastructures_pub.party_tbl;
    l_un_exp_party_acct_tbl       csi_datastructures_pub.party_account_tbl;
    l_un_exp_inst_asset_tbl       csi_datastructures_pub.instance_asset_tbl;
    l_un_exp_ext_attrib_val_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
    l_un_exp_pricing_attribs_tbl  csi_datastructures_pub.pricing_attribs_tbl;
    l_un_exp_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_un_exp_ii_rltns_tbl         csi_datastructures_pub.ii_relationship_tbl;
    l_un_exp_systems_rec          csi_datastructures_pub.system_rec;

    l_trx_rec                    csi_datastructures_pub.transaction_rec;
    l_auto_split_instances       csi_datastructures_pub.instance_tbl;

    l_split_src_inst_rec         csi_datastructures_pub.instance_rec;
    l_split_src_trx_rec          csi_datastructures_pub.transaction_rec;
    l_split_new_inst_rec         csi_datastructures_pub.instance_rec;
    l_sys_query_rec              csi_datastructures_pub.system_query_rec;
    x_systems_tbl                csi_datastructures_pub.systems_tbl;

    /* expire item instance variables */
    l_exp_instance_rec           csi_datastructures_pub.instance_rec;
    l_exp_instance_id_lst        csi_datastructures_pub.id_tbl;
    l_expire_flag                BOOLEAN := FALSE;

    /* non source processing variables */
    l_ns_instance_rec            csi_datastructures_pub.instance_rec;
    l_ns_party_tbl               csi_datastructures_pub.party_tbl;
    l_ns_party_acct_tbl          csi_datastructures_pub.party_account_tbl;
    l_ns_pricing_attribs_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_ns_ext_attrib_val_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_ns_org_units_tbl           csi_datastructures_pub.organization_units_tbl;
    l_ns_inst_asset_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_ns_inst_id_lst             csi_datastructures_pub.id_tbl;

    l_chg_instance_rec           csi_datastructures_pub.instance_rec;
    l_chg_party_tbl              csi_datastructures_pub.party_tbl;
    l_chg_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
    l_chg_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_chg_ext_attrib_val_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_chg_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_chg_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_chg_inst_id_lst            csi_datastructures_pub.id_tbl;
    l_chg_txn_rec                csi_datastructures_pub.transaction_rec;

    l_all_tld_party_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_all_tld_account_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_all_tld_oa_tbl             csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_all_tld_ea_tbl             csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_tld_rec                    csi_t_datastructures_grp.txn_line_detail_rec;
    l_tld_party_tbl              csi_t_datastructures_grp.txn_party_detail_tbl;
    l_tld_account_tbl            csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_tld_oa_tbl                 csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_tld_ea_tbl                 csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_quantity1                NUMBER;
    l_quantity2                NUMBER;
    x_system_id                NUMBER;
    l_model_inst_id            NUMBER := -1;
    l_option_inst_id           NUMBER := -1;
    x_master_org_id            NUMBER ;
    l_object_inst_id           NUMBER;
    l_trx_type_id              NUMBER;
    l_subject_inst_id          NUMBER;
    l_rel_exist                BOOLEAN := TRUE;
    l_end                      NUMBER := 1;
    l_split_flag               varchar2(10);
    l_found                    BOOLEAN := FALSE;
    l_ii_rel_id                NUMBER;
    l_curr_object_id           NUMBER;
    l_curr_subject_id          NUMBER;
    l_date                     DATE := fnd_api.g_miss_date;
    l_debug_level              NUMBER;
    l_inst_status_id           NUMBER;
    l_inst_obj_ver_num         NUMBER;
    l_pty_changed              BOOLEAN := FALSE;
    l_curr_pty_id              NUMBER;
    l_instance_id              NUMBER;
    l_curr_instance_qty        NUMBER;
    l_instance_party_id        NUMBER;
    l_int_pty_obj_ver_num      NUMBER;
    l_ip_account_id            NUMBER;
    l_pty_acct_obj_ver_num     NUMBER;
    l_instance_ou_id           NUMBER;
    l_ou_obj_ver_num           NUMBER;
    l_attrib_value_id          NUMBER;
    l_av_obj_ver_num           NUMBER;
    l_party_id                 NUMBER;
    l_party_acct_id            NUMBER;
    l_start                    NUMBER;
    l_bom_explode_flag         BOOLEAN := FALSE;
    l_party_site_id            NUMBER;
    l_total_qty_processed      NUMBER := 0;
    l_system_id                NUMBER;
    l_system_exist             BOOLEAN := FALSE;
    l_parent_tbl_index         NUMBER;
    l_process_acct_flag        BOOLEAN := TRUE;
    l_explosion_level          NUMBER := 0;
    l_so_qty                   NUMBER;
    l_so_instance_id           NUMBER;
    l_so_obj_ver_num           NUMBER;
    is_instance_rma            BOOLEAN := FALSE;
    l_relationship_id          NUMBER;
    l_ii_rel_obj_ver_num       NUMBER;
    l_instance_pty_id          NUMBER;
    l_exp_ii_relationship_rec  csi_datastructures_pub.ii_relationship_rec;
    l_exp_instance_id_tbl      csi_datastructures_pub.id_tbl;

    l_dflt_inst_status_id      NUMBER;
    l_owner_party_id           NUMBER;
    l_internal_party_id        NUMBER;
    l_ownership_flag           VARCHAR2(1);

    -- explode_bom variables
    l_bom_ind                  binary_integer := 0;
    l_bom_std_item_rec         csi_datastructures_pub.instance_rec;
    l_bom_std_item_tbl         csi_datastructures_pub.instance_tbl;

    l_comp_instance_tbl        csi_datastructures_pub.instance_tbl;
    l_comp_relation_tbl        csi_datastructures_pub.ii_relationship_tbl;

    l_active_end_date          date := fnd_api.g_miss_date;
    l_call_contracts           varchar2(1) := fnd_api.g_true;

    -- profile value checking
    l_default_install_date    VARCHAR2(1);

    l_install_party_site_id   NUMBER;

    -- Partner Order changes
    l_upd_party_site_id        number;
    l_cre_party_site_id        number;

    l_owner_pty_rec            csi_datastructures_pub.party_rec;
    l_owner_acct_rec           csi_datastructures_pub.party_account_rec;

    --brmanesh 01-DEC-2003
    l_wip_job_id               number;
    l_wip_iir_tbl              csi_datastructures_pub.ii_relationship_tbl;
    l_cps_tbl                  customer_products_tbl;
    l_cp_ind                   binary_integer := 0;
    l_all_cps_tbl              customer_products_tbl;
    l_single_cps_tbl           customer_products_tbl;
    l_acp_ind                  binary_integer := 0;
    -- Added this for unlock_item_instances
    l_config_tbl               csi_cz_int.config_tbl;
    l_cia_found                varchar2(1);

  BEGIN

    /* Standard Start of API savepoint */
    SAVEPOINT  update_install_base;

    api_log('update_install_base');

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;

    debug('  txn_line_detail_tbl.count     :'||p_txn_line_detail_tbl.count );
    debug('  txn_party_detail_tbl.count    :'||p_txn_party_detail_tbl.count );
    debug('  txn_pty_acct_dtl_tbl.count    :'||p_txn_pty_acct_dtl_tbl.count);
    debug('  txn_org_assgn_tbl.count       :'||p_txn_org_assgn_tbl.count);
    debug('  txn_ii_rltns_tbl.count        :'||p_txn_ii_rltns_tbl.count);
    debug('  txn_ext_attrib_vals_tbl.count :'||p_txn_ext_attrib_vals_tbl.count);
    debug('  pricing_attribs_tbl.count     :'||p_pricing_attribs_tbl.count);
    debug('  txn_systems_tbl.count         :'||p_txn_systems_tbl.count);

   IF p_txn_line_detail_tbl.count <= 0
   THEN
       fnd_message.set_name('CSI', 'CSI_CANNOT_UPDATE');
       fnd_message.set_token('OBJECT_ID','');
       fnd_message.set_token('RELATIONSHIP_TYPE_CODE','');
       fnd_msg_pub.add;
       Raise fnd_api.g_exc_error;
   END IF;

    /* get the profile value for CSI default install date */
    BEGIN
       SELECT nvl(fnd_profile.value('CSI_DEF_INST_DATE'),'N')
       INTO   l_default_install_date
       FROM   dual;
    EXCEPTION
       WHEN OTHERS THEN
          NULL;
    END;

    /* assign the trx_rec that will be used for all trx's in IB*/
    l_trx_rec := p_trx_rec;

    /* get the debug level from the profile */
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    l_order_line_rec := p_order_line_rec;

    /* validate the txn table and its child tables */
    validate_txn_tbl(
      p_txn_line_rec         => p_txn_line_rec,
      p_txn_line_detail_tbl  => p_txn_line_detail_tbl,
      p_txn_party_detail_tbl => p_txn_party_detail_tbl,
      p_txn_pty_acct_dtl_tbl => p_txn_pty_acct_dtl_tbl,
      p_txn_ii_rltns_tbl     => p_txn_ii_rltns_tbl,
      p_txn_org_assgn_tbl    => p_txn_org_assgn_tbl,
      p_order_line_rec       => l_order_line_rec,
      p_source               => p_source,
      x_return_status        => x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_error;
    END IF;

    l_all_tld_party_tbl   := p_txn_party_detail_tbl;
    l_all_tld_account_tbl := p_txn_pty_acct_dtl_tbl;
    l_all_tld_oa_tbl      := p_txn_org_assgn_tbl;
    l_all_tld_ea_tbl      := p_txn_ext_attrib_vals_tbl;

    /* Process the txn details only if  p_validate_only is 'N' */
    IF p_validate_only = 'N' THEN

      /*-----------------------------------------------*/
      /* Check if the systems exists,if found          */
      /* then use the system else create a new system  */
      /*-----------------------------------------------*/
      IF p_txn_systems_tbl.count > 0 THEN
        create_csi_systems(
          px_csi_txn_rec     => l_trx_rec,
          px_txn_systems_tbl => p_txn_systems_tbl,
          px_tld_tbl         => p_txn_line_detail_tbl,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF; -- end if for system table count > 0

      csi_utl_pkg.get_dflt_inst_status_id(
        x_instance_status_id  => l_dflt_inst_status_id,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_split_flag := nvl(fnd_profile.value('CSI_AUTO_SPLIT_INSTANCE' ),'N');

      debug('  profile_auto_split : '||l_split_flag);


      /* Process the txn details and the child tables     */

      IF p_txn_line_detail_tbl.count > 0 THEN

        debug ('Processing the txn line dtl and child tables.' );

        FOR i IN p_txn_line_detail_tbl.FIRST..p_txn_line_detail_tbl.LAST
        LOOP

          l_tld_rec := p_txn_line_detail_tbl(i);

          debug('processing tld record # '||i||' source_flag : '||l_tld_rec.source_transaction_flag);

          l_cp_ind := 0;
          l_cps_tbl.delete;

          /* Process only txn details that have the source_trx_flag = 'Y' */
          IF l_debug_level > 1 THEN
            csi_t_gen_utility_pvt.dump_line_detail_rec(l_tld_rec);
          END IF;

          get_tld_set(
            px_tld_rec          => l_tld_rec,
            px_tld_party_tbl    => l_all_tld_party_tbl,
            px_tld_account_tbl  => l_all_tld_account_tbl,
            px_tld_oa_tbl       => l_all_tld_oa_tbl,
            px_tld_ea_tbl       => l_all_tld_ea_tbl,
            -- out set
            x_tld_party_tbl     => l_tld_party_tbl,
            x_tld_account_tbl   => l_tld_account_tbl,
            x_tld_oa_tbl        => l_tld_oa_tbl,
            x_tld_ea_tbl        => l_tld_ea_tbl,
            x_return_status     => l_return_status);

        IF (l_tld_rec.source_transaction_flag = 'Y') AND
           (l_tld_rec.processing_status = 'IN_PROCESS') THEN

          px_error_rec.serial_number := l_tld_rec.serial_number;
          px_error_rec.lot_number    := l_tld_rec.lot_number;
          px_error_rec.instance_id   := l_tld_rec.instance_id;

          /* Initialize the pl/sql table for each txn_line_dtls*/
          l_cre_party_tbl.delete;
          l_upd_party_tbl.delete;
          l_cre_party_acct_tbl.delete;
          l_upd_party_acct_tbl.delete;
          l_cre_org_units_tbl.delete;
          l_upd_org_units_tbl.delete;
          l_cre_ext_attrib_val_tbl.delete;
          l_upd_ext_attrib_val_tbl.delete;
          l_cre_pricing_attribs_tbl.delete;

          /* Keep the txn_line_dtl qty processed */
          l_total_qty_processed := l_total_qty_processed + l_tld_rec.quantity;

          /* Get the sub_type_rec from the txn line_dtls */

          csi_utl_pkg.get_sub_type_rec(
            p_sub_type_id            => l_tld_rec.sub_type_id,
            p_trx_type_id            => p_txn_line_rec.source_transaction_type_id,
            x_trx_sub_type_rec       => x_trx_sub_type_rec,
            x_return_status          => x_return_status) ;

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;

          csi_utl_pkg.get_org_assignment_tbl(
            p_txn_line_detail_rec     => l_tld_rec,
            p_txn_org_assgn_tbl       => l_tld_oa_tbl,
            x_cre_org_units_tbl       => l_cre_org_units_tbl,
            x_upd_org_units_tbl       => l_upd_org_units_tbl,
            x_return_status           => x_return_status);

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;

          csi_utl_pkg.get_ext_attribs_tbl(
            p_txn_line_detail_rec     => l_tld_rec,
            p_txn_ext_attrib_vals_tbl => l_tld_ea_tbl,
            x_cre_ext_attrib_val_tbl  => l_cre_ext_attrib_val_tbl,
            x_upd_ext_attrib_val_tbl  => l_upd_ext_attrib_val_tbl,
            x_return_status           => x_return_status );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;

          csi_utl_pkg.get_party_owner(
            p_txn_line_detail_rec     => l_tld_rec,
            p_txn_party_detail_tbl    => l_tld_party_tbl,
            p_txn_pty_acct_dtl_tbl    => l_tld_account_tbl,
            x_trx_sub_type_rec        => x_trx_sub_type_rec,
            p_order_line_rec          => p_order_line_rec,
            x_upd_party_tbl           => l_upd_party_tbl,
            x_upd_party_acct_tbl      => l_upd_party_acct_tbl,
            x_cre_party_tbl           => l_cre_party_tbl,
            x_cre_party_acct_tbl      => l_cre_party_acct_tbl,
            x_return_status           => x_return_status );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;


          IF p_source = 'SHIPMENT' THEN
            IF l_upd_party_acct_tbl.COUNT = 0 THEN
              l_upd_party_acct_tbl :=   l_cre_party_acct_tbl;
              l_cre_party_acct_tbl.delete;
            END IF;
          ELSIF p_source = 'FULFILLMENT' THEN
            -- Bug 4996316, these are demo conversion shipments and have a need to convert
            -- an externally located but internally owned item instance to CP
            -- current check for it is simple and additional checks may be added in here...
            IF nvl(l_tld_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
            THEN
             IF l_upd_party_acct_tbl.COUNT = 0 THEN
                l_upd_party_acct_tbl :=   l_cre_party_acct_tbl;
                l_cre_party_acct_tbl.delete;
             END IF;
            END IF;
          END IF;

          debug('After building all the pl/sql tables');
          debug('  upd_party_tbl.count           :'||l_upd_party_tbl.count);
          debug('  upd_party_acct_tbl.count      :'||l_upd_party_acct_tbl.count);
          debug('  upd_org_units_tbl.count       :'||l_upd_org_units_tbl.count);
          debug('  upd_inst_asset_tbl.count      :'||l_upd_inst_asset_tbl.count);
          debug('  upd_ext_attrib_val_tbl.count  :'||l_upd_ext_attrib_val_tbl.count);
          debug('  upd_pricing_attribs_tbl.count :'||l_upd_pricing_attribs_tbl.count);
          debug('  cre_party_tbl.count           :'||l_cre_party_tbl.count);
          debug('  cre_party_acct_tbl.count      :'||l_cre_party_acct_tbl.count);
          debug('  cre_org_units_tbl.count       :'||l_cre_org_units_tbl.count);
          debug('  cre_inst_asset_tbl.count      :'||l_cre_inst_asset_tbl.count);
          debug('  cre_ext_attrib_val_tbl.count  :'||l_cre_ext_attrib_val_tbl.count);
          debug('  cre_pricing_attribs_tbl.count :'||l_cre_pricing_attribs_tbl.count);

          -- Forward Port bug 7420858 for base bug 7312328
          IF NVL(l_tld_rec.location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num AND
             p_order_line_rec.ib_current_loc_id IS NOT NULL -- added for bug 5069906
	  THEN

            BEGIN

              SELECT party_site_id
              INTO   l_party_site_id
              FROM   hz_cust_acct_sites_all c,
                     hz_cust_site_uses_all u
              WHERE  c.cust_acct_site_id = u.cust_acct_site_id
              AND    u.site_use_id = p_order_line_rec.ib_current_loc_id; -- ship_to_org_id;

            EXCEPTION
              WHEN no_data_found then
                fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
                fnd_message.set_token('LOCATION_ID', l_tld_rec.location_id);
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
              WHEN too_many_rows then
                debug('Many Party sites found');
                raise fnd_api.g_exc_error;
            END;

            l_tld_rec.location_id        := l_party_site_id;
            l_tld_rec.location_type_code := 'HZ_PARTY_SITES';

          END IF;

          -- Forward Port bug 7420858 for base bug 7312328
          IF NVL(l_tld_rec.install_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
	  AND  p_order_line_rec.ib_install_loc_id IS NOT NULL THEN --5147603
            BEGIN

              SELECT party_site_id
              INTO   l_install_party_site_id
              FROM   hz_cust_acct_sites_all c,
                     hz_cust_site_uses_all u
              WHERE  c.cust_acct_site_id = u.cust_acct_site_id
              AND    u.site_use_id = p_order_line_rec.ib_install_loc_id; -- ship_to_org_id;

            EXCEPTION
              WHEN no_data_found then
                fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
                fnd_message.set_token('LOCATION_ID',p_order_line_rec.ib_install_loc_id);--5147603
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
              WHEN too_many_rows then
                debug('Many Party sites found');
                raise fnd_api.g_exc_error;
            END;

            l_tld_rec.install_location_id        := l_install_party_site_id;
            l_tld_rec.install_location_type_code := 'HZ_PARTY_SITES';

          END IF;

          /* If the instance reference exists then call update instance api else */
          /* call create instance api .Also check if the split instance profile  */
          /* is on then split it into so many number of instances                */

          IF NVL(l_tld_rec.instance_id,fnd_api.g_miss_num ) <> fnd_api.g_miss_num THEN

           l_upd_instance_rec := l_tmp_instance_rec;

            csi_utl_pkg.get_instance(
              p_instance_id        => l_tld_rec.instance_id,
              x_obj_version_number => l_inst_obj_ver_num,
              x_inst_qty           => l_curr_instance_qty,
              x_return_status      => x_return_status);

            IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              raise fnd_api.g_exc_error;
            END IF;

            debug('Referenced Instance ID :'||l_tld_rec.instance_id);
            debug('  object_ver_num       :'||l_inst_obj_ver_num);
            debug('  quantitity           :'||l_curr_instance_qty);
            debug('  returned instance id :'||l_tld_rec.changed_instance_id);

            l_instance_id := l_tld_rec.instance_id;

            IF p_order_line_rec.serial_code = 6 THEN

              /*--------------------------------------------------------------------*/
              /* Check if the instance exists with shipped serial number then it is */
              /* a shipping of returned instance So decrement the source instance   */
              /* and update the destination instance to make it a cp                */
              /*--------------------------------------------------------------------*/

              BEGIN

                SELECT instance_id,
                       quantity,
                       object_version_number
                INTO   l_so_instance_id,
                       l_so_qty,
                       l_so_obj_ver_num
                FROM   csi_item_instances
                WHERE  serial_number       = l_tld_rec.serial_number
                AND    inventory_item_id   = l_tld_rec.inventory_item_id
                AND    (instance_usage_code = 'RETURNED' --added the outer braces for bug6310708
		--Start of code for 6188180
                OR (instance_usage_code = 'IN_TRANSIT'
                    AND
                    active_end_date IS NOT NULL));
		--End of code for 6188180

                debug('Returned instance found. Instance ID :'||l_so_instance_id);

                decrement_source_instance(
                  p_instance_id    => l_tld_rec.instance_id,
                  p_quantity       => 1,
                  p_trx_rec        => l_trx_rec,
                  x_return_status  => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                debug('Rebuilding the TD tables for the returned instance.');

                l_curr_instance_qty := l_so_qty ;
                l_inst_obj_ver_num  := l_so_obj_ver_num;
                l_instance_id       := l_so_instance_id;

                csi_utl_pkg.rebuild_tbls(
                  p_new_instance_id        => l_so_instance_id,
                  x_upd_party_tbl          => l_upd_party_tbl,
                  x_upd_party_acct_tbl     => l_upd_party_acct_tbl,
                  x_upd_org_units_tbl      => l_upd_org_units_tbl,
                  x_upd_ext_attrib_val_tbl => l_upd_ext_attrib_val_tbl,
                  x_cre_org_units_tbl      => l_cre_org_units_tbl,
                  x_cre_ext_attrib_val_tbl => l_cre_ext_attrib_val_tbl,
                  x_txn_ii_rltns_tbl       => p_txn_ii_rltns_tbl,
                  x_txn_line_detail_rec    => l_tld_rec,
                  x_return_status          => x_return_status);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                  raise fnd_api.g_exc_error;
                END IF;

                -- Mark the instance as RMA so that it is not eligible for split
                is_instance_rma := TRUE;

              EXCEPTION
               WHEN no_data_found THEN
                 is_instance_rma := FALSE;
                 debug('Returned Instance not found for the serial number.');
              END;
            END IF;

            /* this code is exclusively for re-shipping a returned non serial config */
            /* instance. ATO non serial config assembly for xerox bug 2304221        */
            IF nvl(l_tld_rec.changed_instance_id, fnd_api.g_miss_num) <>
               fnd_api.g_miss_num
		    AND p_order_line_rec.serial_code = 1 -- Added for Bug 3008953
            THEN
              debug('re-shipping of a returned configuration.');
              -- a returned instance reference specified.

              is_instance_rma := TRUE;

              decrement_source_instance(
                p_instance_id    => l_tld_rec.instance_id,
                p_quantity       => 1,
                p_trx_rec        => l_trx_rec,
                x_return_status  => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              debug('Rebuilding the TD tables for the returned config instance.');

              l_curr_instance_qty := 1 ;
              l_instance_id       := l_tld_rec.changed_instance_id;

              SELECT object_version_number
              INTO   l_inst_obj_ver_num
              FROM   csi_item_instances
              WHERE  instance_id = l_tld_rec.changed_instance_id;

              csi_utl_pkg.rebuild_tbls(
                p_new_instance_id        => l_instance_id,
                x_upd_party_tbl          => l_upd_party_tbl,
                x_upd_party_acct_tbl     => l_upd_party_acct_tbl,
                x_upd_org_units_tbl      => l_upd_org_units_tbl,
                x_upd_ext_attrib_val_tbl => l_upd_ext_attrib_val_tbl,
                x_cre_org_units_tbl      => l_cre_org_units_tbl,
                x_cre_ext_attrib_val_tbl => l_cre_ext_attrib_val_tbl,
                x_txn_ii_rltns_tbl       => p_txn_ii_rltns_tbl,
                x_txn_line_detail_rec    => l_tld_rec,
                x_return_status          => x_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                raise fnd_api.g_exc_error;
              END IF;

            END IF;

            IF (p_order_line_rec.serial_code in (1,6))
                AND
               (NOT(is_instance_rma))
                -- Commented as part of fix for Bug 2985193
                -- AND
                -- (l_curr_instance_qty > l_tld_rec.quantity )
            -- Begin code fix for Bug 2985193
            THEN
              IF (l_curr_instance_qty > l_tld_rec.quantity )
              THEN
                /* Split the instance if the inst_qty >  shipped_qty                           */
                /* update the existing instance with the qty equal to (inst_qty - shipped_qty) */
                /* and create a new instance with qty equal to txn qty                         */
                l_quantity1 := (l_curr_instance_qty - l_tld_rec.quantity );
                l_quantity2 :=  l_tld_rec.quantity ;
              ELSIF ( l_curr_instance_qty - l_tld_rec.quantity ) < 0
              THEN
                IF p_order_line_rec.negative_balances_code = 1
                THEN
                  IF  l_curr_instance_qty = 0
                    AND p_order_line_rec.reservable_type = 2
                  THEN

                    /*
                    debug('Non reservable Item and is expired so unexpiring first');

                    -- Calling update_item_instance to unexpire the source instance
                    l_un_exp_instance_rec.instance_id           := l_tld_rec.instance_id;
                    l_un_exp_instance_rec.active_end_date       := null;
                    l_un_exp_instance_rec.object_version_number := l_inst_obj_ver_num;

                    csi_t_gen_utility_pvt.dump_api_info(
                      p_pkg_name => 'csi_item_instance_pub',
                      p_api_name => 'update_item_instance');

                    csi_item_instance_pub.update_item_instance(
                      p_api_version           => 1.0,
                      p_commit                => fnd_api.g_false,
                      p_init_msg_list         => fnd_api.g_true,
                      p_validation_level      => fnd_api.g_valid_level_full,
                      p_instance_rec          => l_un_exp_instance_rec,
                      p_ext_attrib_values_tbl => l_un_exp_ext_attrib_val_tbl,
                      p_party_tbl             => l_un_exp_party_tbl,
                      p_account_tbl           => l_un_exp_party_acct_tbl,
                      p_pricing_attrib_tbl    => l_un_exp_pricing_attribs_tbl,
                      p_org_assignments_tbl   => l_un_exp_org_units_tbl,
                      p_txn_rec               => l_trx_rec,
                      p_asset_assignment_tbl  => l_un_exp_inst_asset_tbl,
                      x_instance_id_lst       => l_chg_inst_id_lst,
                      x_return_status         => l_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data );

                    -- For Bug 4057183
                    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                       RAISE fnd_api.g_exc_error;
                    END IF;
                    debug('After Non reservable Item instance is unexpired');
                    */
                    -- instead of an unexpiry I am passing the end date of the source instance
                    -- for the split as null and passing created as the instance status.

                    l_split_src_inst_rec.active_end_date       := null;
                    l_split_src_inst_rec.instance_status_id    := 510;
                  END IF;
                  l_quantity1 := (l_curr_instance_qty - l_tld_rec.quantity );
                  l_quantity2 :=  l_tld_rec.quantity ;
                ELSE
                  fnd_message.set_name('CSI', 'CSI_ORG_NO_NEG_QTY');
                  fnd_message.set_token('ORG_ID',l_tld_rec.inv_organization_id);
                  fnd_msg_pub.add;
                  Raise fnd_api.g_exc_error;
                END IF;
              ELSE
                l_quantity1 := (l_curr_instance_qty - l_tld_rec.quantity );
                l_quantity2 :=  l_tld_rec.quantity ;
              END IF;
            -- END IF;  -- Commented as part of Bug 3033092
            -- End code fix for Bug 2985193

              l_split_src_inst_rec.instance_id           := l_tld_rec.instance_id;
              l_split_src_inst_rec.vld_organization_id   := l_tld_rec.inv_organization_id;
              l_split_src_inst_rec.location_type_code    := l_tld_rec.location_type_code;
              l_split_src_inst_rec.location_id           := l_tld_rec.location_id;
              -- Added for partner ordering
              l_split_src_inst_rec.install_location_type_code    := l_tld_rec.install_location_type_code;
              l_split_src_inst_rec.install_location_id           := l_tld_rec.install_location_id;
              -- Added for partner ordering
              l_split_src_inst_rec.inv_organization_id   := null;
              l_split_src_inst_rec.inv_subinventory_name := null;
              l_split_src_inst_rec.inv_locator_id        := null;
              l_split_src_inst_rec.pa_project_id         := null;
              l_split_src_inst_rec.pa_project_task_id    := null;
              l_split_src_inst_rec.wip_job_id            := null;
              l_split_src_inst_rec.po_order_line_id      := null;
              l_split_src_inst_rec.version_label         := nvl(l_tld_rec.version_label,fnd_api.g_miss_char);--bug 5112946
              l_split_src_trx_rec := p_trx_rec;

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_item_instance_pvt',
                p_api_name => 'split_item_instance');

              /* split the inventory staging instance when the instance qty > ship qty */
              /* the owner party is still internal */
              csi_item_instance_pvt.split_item_instance (
                p_api_version            => 1.0,
                p_commit                 => fnd_api.g_false,
                p_init_msg_list          => fnd_api.g_true,
                p_validation_level       => fnd_api.g_valid_level_full,
                p_source_instance_rec    => l_split_src_inst_rec,
                p_quantity1              => l_quantity1,
                p_quantity2              => l_quantity2,
                p_copy_ext_attribs       => fnd_api.g_true,
                p_copy_org_assignments   => fnd_api.g_true,
                p_copy_parties           => fnd_api.g_true,
                p_copy_accounts          => fnd_api.g_true,
                p_copy_asset_assignments => fnd_api.g_true,
                p_copy_pricing_attribs   => fnd_api.g_true,
                p_txn_rec                => l_split_src_trx_rec,
                x_new_instance_rec       => l_split_new_inst_rec,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data);

              IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                g_api_name := 'csi_item_instance_pvt.split_item_instance';
                raise fnd_api.g_exc_error;
              END IF;

              l_instance_id      := l_split_new_inst_rec.instance_id ;
              l_inst_obj_ver_num := l_split_new_inst_rec.object_version_number;

              debug('  Old Instance_ID :' ||l_tld_rec.instance_id );
              debug('  New Instance_ID :' ||l_split_new_inst_rec.instance_id );

              debug('Rebuilding the TD tables for the newly created instance.');

              csi_utl_pkg.rebuild_tbls(
                p_new_instance_id         => l_instance_id,
                x_upd_party_tbl           => l_upd_party_tbl,
                x_upd_party_acct_tbl      => l_upd_party_acct_tbl,
                x_upd_org_units_tbl       => l_upd_org_units_tbl,
                x_upd_ext_attrib_val_tbl  => l_upd_ext_attrib_val_tbl,
                x_cre_org_units_tbl       => l_cre_org_units_tbl,
                x_cre_ext_attrib_val_tbl  => l_cre_ext_attrib_val_tbl,
                x_txn_ii_rltns_tbl        => p_txn_ii_rltns_tbl,
                x_txn_line_detail_rec     => l_tld_rec,
                x_return_status           => x_return_status  );

              IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                raise fnd_api.g_exc_error;
              END IF;

            END IF; -- end of split_item_instances
             -- Uncommented the end if as part of fix for Bug 3033092
            -- Commented the END IF and moved it to before even building the split record
            -- as part of fix for Bug 2985193

            IF NVL(x_trx_sub_type_rec.src_status_id,fnd_api.g_miss_num) =  fnd_api.g_miss_num THEN

              l_inst_status_id := l_dflt_inst_status_id;

              l_upd_instance_rec.instance_status_id := l_inst_status_id;
            ELSE
              l_upd_instance_rec.instance_status_id := x_trx_sub_type_rec.src_status_id;
            END IF;

            l_trx_rec.txn_sub_type_id := l_tld_rec.sub_type_id;

            /* Assign the values for update_instance_rec */

            l_upd_instance_rec.instance_id              := l_instance_id ;
            l_upd_instance_rec.vld_organization_id      := l_tld_rec.inv_organization_id;

            -- Partner Ordering Code change
            -- l_upd_instance_rec.location_type_code       := l_tld_rec.location_type_code;
            -- l_upd_instance_rec.location_id              := l_tld_rec.location_id;
            -- Added the nvl to l_ltd_rec optional columns for Bug 3818547
            l_upd_instance_rec.install_location_type_code  := nvl(l_tld_rec.install_location_type_code,fnd_api.g_miss_char);
            IF p_order_line_rec.ib_install_loc is not null
              AND
               p_order_line_rec.ib_install_loc <> fnd_api.g_miss_char
            THEN
              BEGIN
                SELECT HCAS.party_site_id
                INTO   l_upd_party_site_id
                FROM   hz_cust_site_uses_all  HCSU,
                       hz_cust_acct_sites_all HCAS
                WHERE  HCSU.site_use_id       = p_order_line_rec.ib_install_loc_id
                AND    HCAS.cust_acct_site_id = HCSU.cust_acct_site_id;

              EXCEPTION
                WHEN others THEN
                  NULL;
              END;

              IF  l_upd_party_site_id <> l_tld_rec.install_location_id
              THEN
                l_upd_instance_rec.install_location_id  := l_upd_party_site_id;
              -- Added else as part of fix for Bug 3419098
              ELSE
                l_upd_instance_rec.install_location_id  := nvl(l_tld_rec.install_location_id,fnd_api.g_miss_num);
              END IF;
            ELSE
              l_upd_instance_rec.install_location_id    := nvl(l_tld_rec.install_location_id,fnd_api.g_miss_num);
            END IF;
            l_upd_instance_rec.location_type_code       := nvl(l_tld_rec.location_type_code,l_tld_rec.install_location_type_code);
            l_upd_instance_rec.location_id              := nvl(l_tld_rec.location_id,l_upd_instance_rec.install_location_id);
            -- Partner Ordering code change

            l_upd_instance_rec.external_reference       := nvl(l_tld_rec.external_reference,fnd_api.g_miss_char);
            l_upd_instance_rec.system_id                := nvl(l_tld_rec.csi_system_id,fnd_api.g_miss_num);
            -- l_upd_instance_rec.accounting_class_code    := 'CUST_PROD';

            IF nvl(l_tld_rec.installation_date,fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
               IF l_default_install_date = 'Y' THEN
                  IF p_source =  'SHIPMENT' THEN
                     l_upd_instance_rec.install_date := p_order_line_rec.actual_shipment_date;
                  ELSIF p_source = 'FULFILLMENT' THEN
                     l_upd_instance_rec.install_date := nvl(p_order_line_rec.fulfillment_date,sysdate);
                  END IF;
               END IF;
            ELSE
               /* Begin code change for 3254347 Install_Date and Start_Date changes */
              IF p_source =  'SHIPMENT' THEN
                 l_upd_instance_rec.install_date := GREATEST(l_tld_rec.installation_date,p_order_line_rec.actual_shipment_date);
              ELSIF  p_source = 'FULFILLMENT' THEN
							  l_upd_instance_rec.install_date       := l_tld_rec.installation_date; --Added for bug 7668298
 	              /* --Commented  for bug 7668298
					      IF p_order_line_rec.fulfillment_date is NOT NULL
					        AND
					          p_order_line_rec.fulfillment_date <> fnd_api.g_miss_date
					      THEN
					        l_upd_instance_rec.install_date       := GREATEST(l_tld_rec.installation_date,p_order_line_rec.fulfillment_date);
					      ELSE
					          l_upd_instance_rec.install_date      := GREATEST(l_tld_rec.installation_date,sysdate);
					      END IF;
      					*/ --Commented  for bug 7668298
              END IF;
               --l_upd_instance_rec.install_date             := l_tld_rec.installation_date;
               /* End code change for 3254347 Install_Date and Start_Date changes */
            END IF;

            l_upd_instance_rec.instance_type_code       := nvl(l_tld_rec.instance_type_code,fnd_api.g_miss_char);
            l_upd_instance_rec.instance_condition_id    := nvl(l_tld_rec.item_condition_id,fnd_api.g_miss_num);
            l_upd_instance_rec.quantity                 := l_tld_rec.quantity;
            l_upd_instance_rec.unit_of_measure          := l_tld_rec.unit_of_measure;
            l_upd_instance_rec.sellable_flag            := nvl(l_tld_rec.sellable_flag,fnd_api.g_miss_char);
            l_upd_instance_rec.last_oe_order_line_id    := p_order_line_rec.order_line_id ;
            l_upd_instance_rec.last_txn_line_detail_id  := l_tld_rec.txn_line_detail_id ;
            l_upd_instance_rec.return_by_date           := nvl(l_tld_rec.return_by_date,fnd_api.g_miss_date);
            --l_upd_instance_rec.active_end_date          := nvl(l_tld_rec.active_end_date,fnd_api.g_miss_date);--Bug3964060
            l_upd_instance_rec.active_end_date          := l_tld_rec.active_end_date;
	     --Added IF condition for bug 5112946--
            IF (p_order_line_rec.serial_code in (2,5)) OR
                 (p_order_line_rec.serial_code =6 AND is_instance_rma) THEN
              l_upd_instance_rec.version_label            := nvl(l_tld_rec.version_label,fnd_api.g_miss_char);
            END IF;
            l_upd_instance_rec.lot_number               := nvl(l_tld_rec.lot_number,fnd_api.g_miss_char);
            l_upd_instance_rec.instance_usage_code      := 'OUT_OF_ENTERPRISE';
            l_upd_instance_rec.last_oe_agreement_id     := p_order_line_rec.agreement_id;
            l_upd_instance_rec.actual_return_date       := null;

            l_upd_instance_rec.object_version_number    := l_inst_obj_ver_num;
            l_upd_instance_rec.source_code              := p_order_line_rec.source_code; -- Added for Siebel Genesis Project

            -- Added this as part of fix for Bug 2972082
            l_upd_instance_rec.cascade_ownership_flag   := l_tld_rec.cascade_owner_flag;
            -- End fix for Bug 2972082

            IF p_order_line_rec.serial_code = 6 THEN
              l_upd_instance_rec.serial_number          := l_tld_rec.serial_number ;
              l_upd_instance_rec.mfg_serial_number_flag := 'Y';
            END IF;

            /* Null the inventory location attributes  */
            l_upd_instance_rec.inv_organization_id      := NULL;
            l_upd_instance_rec.inv_subinventory_name    := NULL;
            l_upd_instance_rec.inv_locator_id           := NULL;
            l_upd_instance_rec.pa_project_id            := NULL;
            l_upd_instance_rec.pa_project_task_id       := NULL;
            l_upd_instance_rec.wip_job_id               := NULL;
            l_upd_instance_rec.po_order_line_id         := NULL;

            l_expire_flag := FALSE;

            IF nvl(l_upd_instance_rec.active_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
	     AND (l_upd_instance_rec.active_end_date) <= SYSDATE
            THEN

              l_upd_ext_attrib_val_tbl.DELETE;
              l_upd_party_tbl.DELETE;
              l_upd_party_acct_tbl.DELETE;
              l_upd_pricing_attribs_tbl.DELETE;
              l_upd_org_units_tbl.DELETE;
              l_upd_inst_asset_tbl.DELETE;

              l_upd_instance_rec.active_end_date := fnd_api.g_miss_date;

              l_expire_flag := TRUE;

            END IF;


            /* check if this is a replacement instnace. If this is replacement
               then pass the call_contracts flag as false . bug 2298453*/
            csi_utl_pkg.call_contracts_chk(
              p_txn_line_detail_id => l_tld_rec.txn_line_detail_id,
              p_txn_ii_rltns_tbl   => p_txn_ii_rltns_tbl,
              x_call_contracts     => l_call_contracts,
              x_return_status      => l_return_status);

            -- set the call contracts
            l_upd_instance_rec.call_contracts := l_call_contracts;

            -- set the flag in party record also for the owner
            IF l_upd_party_tbl.count > 0 THEN
              FOR l_upa_ind IN l_upd_party_tbl.FIRST .. l_upd_party_tbl.LAST
              LOOP
                IF l_upd_party_tbl(l_upa_ind).relationship_type_code = 'OWNER' THEN
                  l_upd_party_tbl(l_upa_ind).call_contracts := l_call_contracts;
                END IF;
              END LOOP;
            END IF;

            -- set the flag in party account record also for the owner
            IF l_upd_party_acct_tbl.count > 0 THEN
              FOR l_upa_ind IN l_upd_party_acct_tbl.FIRST .. l_upd_party_acct_tbl.LAST
              LOOP
                IF l_upd_party_acct_tbl(l_upa_ind).relationship_type_code = 'OWNER' THEN
                  l_upd_party_acct_tbl(l_upa_ind).call_contracts := l_call_contracts;
                END IF;
              END LOOP;
            END IF;

            /* Code fix as part of ER 2581101 */

            IF x_trx_sub_type_rec.src_change_owner = 'Y' THEN

              IF l_upd_party_acct_tbl.COUNT > 0 THEN

                l_chg_instance_rec.instance_id     := l_upd_instance_rec.instance_id;
                l_chg_instance_rec.active_end_date := null;

                SELECT owner_party_id,
                       object_version_number
                INTO   l_owner_party_id,
                       l_chg_instance_rec.object_version_number
                FROM   CSI_ITEM_INSTANCES
                WHERE  instance_id = l_upd_party_tbl(1).instance_id;

                IF l_owner_party_id <> p_order_line_rec.internal_party_id
                   AND
                   l_owner_party_id <> l_upd_party_tbl(1).party_id
                THEN

                  l_ownership_flag:=
                    NVL(csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn,'N');

                  IF l_ownership_flag = 'N' Then
                    fnd_message.set_name('CSI','CSI_SHIP_OWNER_MISMATCH');
                    fnd_message.set_token('OLD_PARTY_ID',l_owner_party_id);
                    fnd_message.set_token('NEW_PARTY_ID',l_upd_party_tbl(1).party_id);
                    fnd_message.set_token('INSTANCE_ID',l_upd_party_tbl(1).instance_id);
                    fnd_msg_pub.add;
                    raise fnd_api.g_exc_error;
                  Else

                    /* Changing the Owner to Internal Before shipping to New Customer */
                    l_chg_party_tbl(1).instance_id          := l_upd_party_tbl(1).instance_id;
                    l_chg_party_tbl(1).instance_party_id    := l_upd_party_tbl(1).instance_party_id;
                    l_chg_party_tbl(1).object_version_number:= l_upd_party_tbl(1).object_version_number;
                    l_chg_party_tbl(1).party_source_table   := 'HZ_PARTIES';
                    l_chg_party_tbl(1).relationship_type_code := 'OWNER';
                    l_chg_party_tbl(1).contact_flag           := 'N';
                    l_chg_party_tbl(1).party_id               := p_order_line_rec.internal_party_id;

                    debug('change owner to internal to terminate contracts.');

                    csi_t_gen_utility_pvt.dump_api_info(
                      p_pkg_name => 'csi_item_instance_pub',
                      p_api_name => 'update_item_instance');

                    -- owner change to internal
                    csi_item_instance_pub.update_item_instance(
                      p_api_version           => 1.0,
                      p_commit                => fnd_api.g_false,
                      p_init_msg_list         => fnd_api.g_true,
                      p_validation_level      => fnd_api.g_valid_level_full,
                      p_instance_rec          => l_chg_instance_rec,
                      p_ext_attrib_values_tbl => l_chg_ext_attrib_val_tbl,
                      p_party_tbl             => l_chg_party_tbl,
                      p_account_tbl           => l_chg_party_acct_tbl,
                      p_pricing_attrib_tbl    => l_chg_pricing_attribs_tbl,
                      p_org_assignments_tbl   => l_chg_org_units_tbl,
                      p_txn_rec               => l_trx_rec,
                      p_asset_assignment_tbl  => l_chg_inst_asset_tbl,
                      x_instance_id_lst       => l_chg_inst_id_lst,
                      x_return_status         => l_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data );

                    -- For Bug 4057183
                    -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    l_upd_party_tbl(1).instance_party_id     := l_chg_party_tbl(1).instance_party_id;
                    /* Fixed for Bug 2728984 */
                    BEGIN
                      SELECT object_version_number
                      INTO   l_upd_instance_rec.object_version_number
                      FROM   CSI_ITEM_INSTANCES
                      WHERE  instance_id = l_upd_instance_rec.instance_id;
                    END;

                    BEGIN
                      SELECT object_version_number
                      INTO   l_upd_party_tbl(1).object_version_number
                      FROM   CSI_I_PARTIES
                      WHERE  instance_party_id = l_upd_party_tbl(1).instance_party_id;
                    END;
                    /* End Of fix for Bug  2728984 */
                  END IF;
                END IF;
              END IF;
              /* Fixed for Bug 2714715 */

              l_owner_pty_rec  := l_upd_party_tbl(1);
              l_owner_acct_rec := l_upd_party_acct_tbl(1);

            ELSIF NVL(x_trx_sub_type_rec.src_change_owner,'N') = 'N' THEN
              l_upd_party_tbl.delete;
              l_upd_party_acct_tbl.delete;
              l_owner_pty_rec  := null;
              l_owner_acct_rec := null;

              BEGIN
                SELECT 'Y' INTO l_cia_found
                FROM   sys.dual
                WHERE  exists (
                  SELECT '1' FROM csi_i_assets
                  WHERE  instance_id = l_upd_instance_rec.instance_id
                  AND    sysdate between nvl(active_start_date, sysdate-1) and nvl(active_end_date, sysdate+1));
                l_upd_instance_rec.operational_status_code := 'IN_SERVICE';
              EXCEPTION
                WHEN no_data_found THEN
                  null;
              END;

            END IF;
            /* End Of Code fix as part of ER 2581101 */

            csi_utl_pkg.get_parties_and_accounts(
              p_instance_id      => l_upd_instance_rec.instance_id,
              p_tld_rec          => l_tld_rec,
              p_t_pty_tbl        => l_tld_party_tbl,
              p_t_pty_acct_tbl   => l_tld_account_tbl,
              p_owner_pty_rec    => l_owner_pty_rec,
              p_owner_acct_rec   => l_owner_acct_rec,
              p_order_line_rec   => p_order_line_rec,
              x_i_pty_tbl        => l_upd_party_tbl,
              x_i_pty_acct_tbl   => l_upd_party_acct_tbl,
              x_return_status    => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            -- srramakr TSO with Equipment
            -- Need to pass the config keys to the Update_Item_Instance API.
            l_upd_instance_rec.config_inst_hdr_id  := l_tld_rec.config_inst_hdr_id;
            l_upd_instance_rec.config_inst_rev_num := l_tld_rec.config_inst_rev_num;
            l_upd_instance_rec.config_inst_item_id := l_tld_rec.config_inst_item_id;
            --

            l_upd_instance_rec.sales_currency_code := l_order_line_rec.currency_code;

            IF l_order_line_rec.primary_uom <> l_order_line_rec.order_quantity_uom THEN

              l_item_control_rec.inventory_item_id := l_order_line_rec.inv_item_id;
              l_item_control_rec.organization_id   := l_order_line_rec.inv_org_id;
              l_item_control_rec.primary_uom_code  := l_order_line_rec.primary_uom;

              csi_utl_pkg.get_unit_price_in_primary_uom(
                p_unit_price                => l_order_line_rec.unit_price,
                p_unit_price_uom            => l_order_line_rec.order_quantity_uom,
                px_item_control_rec         => l_item_control_rec,
                x_unit_price_in_primary_uom => l_upd_instance_rec.sales_unit_price,
                x_return_status             => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            ELSE
              l_upd_instance_rec.sales_unit_price := l_order_line_rec.unit_price;
            END IF;

            debug('  upd_party_tbl.count           :'||l_upd_party_tbl.count);
            debug('  upd_party_acct_tbl.count      :'||l_upd_party_acct_tbl.count);
            debug('  upd_org_units_tbl.count       :'||l_upd_org_units_tbl.count);
            debug('  upd_inst_asset_tbl.count      :'||l_upd_inst_asset_tbl.count);
            debug('  upd_ext_attrib_val_tbl.count  :'||l_upd_ext_attrib_val_tbl.count);
            debug('  upd_pricing_attribs_tbl.count :'||l_upd_pricing_attribs_tbl.count);

            IF l_debug_level > 1 THEN
              csi_t_gen_utility_pvt.dump_csi_instance_rec(l_upd_instance_rec);
            END IF;

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'update_item_instance',
              p_pkg_name => 'csi_item_instance_pub');

            debug('Converting the instance into a customer product....!');

            /* this is the call that makes the instance as customer product */
            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_upd_instance_rec,
              p_ext_attrib_values_tbl => l_upd_ext_attrib_val_tbl,
              p_party_tbl             => l_upd_party_tbl,
              p_account_tbl           => l_upd_party_acct_tbl,
              p_pricing_attrib_tbl    => l_upd_pricing_attribs_tbl,
              p_org_assignments_tbl   => l_upd_org_units_tbl,
              p_txn_rec               => l_trx_rec,
              p_asset_assignment_tbl  => l_upd_inst_asset_tbl,
              x_instance_id_lst       => l_inst_id_lst,
              x_return_status         => l_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);

            -- For Bug 4057183
            -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
              g_api_name := 'csi_item_instance_pub.update_item_instance';
              raise fnd_api.g_exc_error;
            END IF;

            IF l_expire_flag THEN

              l_exp_instance_rec.instance_id           := l_upd_instance_rec.instance_id;
              l_exp_instance_rec.object_version_number := l_inst_obj_ver_num + 1;

              l_trx_rec.transaction_id                 := fnd_api.g_miss_num;

              csi_t_gen_utility_pvt.dump_api_info(
                p_api_name => 'expire_item_instance',
                p_pkg_name => 'csi_item_instance_pub');

              csi_item_instance_pub.expire_item_instance(
                p_api_version      => 1.0,
                p_commit           => fnd_api.g_false,
                p_init_msg_list    => fnd_api.g_true,
                p_validation_level => fnd_api.g_valid_level_full,
                p_instance_rec     => l_exp_instance_rec,
                p_expire_children  => fnd_api.g_true,
                p_txn_rec          => l_trx_rec,
                x_instance_id_lst  => l_exp_instance_id_lst,
                x_return_status    => l_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data);

              IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
                g_api_name := 'csi_item_instance_pub.expire_item_instance';
                raise fnd_api.g_exc_error;
              END IF;

            END IF;

            l_instance_id := l_upd_instance_rec.instance_id ;

            l_tld_rec.changed_instance_id    := l_upd_instance_rec.instance_id;
            l_tld_rec.inv_mtl_transaction_id := p_order_line_rec.inv_mtl_transaction_id;

            debug('Customer Product ID :'||l_upd_instance_rec.instance_id);

            l_cp_ind := l_cp_ind + 1;
            l_cps_tbl(l_cp_ind).instance_id        := l_upd_instance_rec.instance_id;
            l_cps_tbl(l_cp_ind).quantity           := l_upd_instance_rec.quantity;
            l_cps_tbl(l_cp_ind).txn_line_detail_id := l_upd_instance_rec.last_txn_line_detail_id;
            l_cps_tbl(l_cp_ind).line_id            := l_upd_instance_rec.last_oe_order_line_id;
            l_cps_tbl(l_cp_ind).transaction_id     := l_trx_rec.transaction_id;
            l_cps_tbl(l_cp_ind).serial_number      := l_tld_rec.serial_number;
            l_cps_tbl(l_cp_ind).lot_number         := l_upd_instance_rec.lot_number;

            IF NOT (l_expire_flag) THEN

              /* create pricing attributes */

              IF p_pricing_attribs_tbl.count > 0 THEN
                --Changes for bug 3901064 Start
                l_new_pricing_attribs_tbl.delete;
                l_old_pricing_attribs_tbl.delete;
                l_old_index := 0;
                l_new_index := 0;
                --Changes for bug 3901064 End
                FOR l_index in p_pricing_attribs_tbl.first..p_pricing_attribs_tbl.last LOOP
                  p_pricing_attribs_tbl(l_index).instance_id := l_upd_instance_rec.instance_id ;
                END LOOP;
              END IF;

              -- BEGIN MRK CODE FOR UPDATE PRICING ATTRIBUTE

              IF p_pricing_attribs_tbl.count > 0 THEN
                For i in p_pricing_attribs_tbl.first..p_pricing_attribs_tbl.last LOOP
                  BEGIN
                    SELECT pricing_attribute_id,
                           object_version_number
                    INTO   p_pricing_attribs_tbl(i).pricing_attribute_id,
                           p_pricing_attribs_tbl(i).object_version_number
                    FROM   csi_i_pricing_attribs
                    WHERE  instance_id = p_pricing_attribs_tbl(i).instance_id
                    AND    pricing_context = p_pricing_attribs_tbl(i).pricing_context;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         Null;
                  END;
                  IF (  p_pricing_attribs_tbl(i).pricing_attribute_id is not null
                      AND
                        p_pricing_attribs_tbl(i).pricing_attribute_id <> fnd_api.g_miss_num
                     )
                  THEN
                    l_old_index                            := l_old_index + 1;
                    l_old_pricing_attribs_tbl(l_old_index) := p_pricing_attribs_tbl(i);
                    l_old_pricing_attribs_tbl(l_old_index).active_end_date := null;
                  ELSE
                    l_new_index                            := l_new_index + 1;
                    l_new_pricing_attribs_tbl(l_new_index) := p_pricing_attribs_tbl(i);
                  END IF;
                END LOOP;
              END IF;

              IF l_old_pricing_attribs_tbl.count > 0 THEN
                debug('Update Pricing_Attributes Count '||l_old_pricing_attribs_tbl.count);

                csi_t_gen_utility_pvt.dump_api_info(
                  p_api_name => 'update_pricing_attribs',
                  p_pkg_name => 'csi_pricing_attribs_pub');

                csi_pricing_attribs_pub.update_pricing_attribs(
                  p_api_version         => 1.0,
                  p_commit              => fnd_api.g_false,
                  p_init_msg_list       => fnd_api.g_true,
                  p_validation_level    => fnd_api.g_valid_level_full,
                  p_pricing_attribs_tbl => l_old_pricing_attribs_tbl,
                  p_txn_rec             => l_trx_rec,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                   g_api_name := 'csi_pricing_attribs_pub.update_pricing_attribs';
                   raise fnd_api.g_exc_error;
                END IF;
                   debug('Pricing Attributes updated successfully.');
              END IF;

              -- IF p_pricing_attribs_tbl.count > 0 THEN
              -- END MRK CODE FOR UPDATE PRICING ATTRIBUTE

             IF l_new_pricing_attribs_tbl.count > 0 THEN
                debug('Creating Pricing_Attributes Count '||l_new_pricing_attribs_tbl.count);

                csi_t_gen_utility_pvt.dump_api_info(
                  p_api_name => 'create_pricing_attribs',
                  p_pkg_name => 'csi_pricing_attribs_pub');

                csi_pricing_attribs_pub.create_pricing_attribs(
                  p_api_version         => 1.0,
                  p_commit              => fnd_api.g_false,
                  p_init_msg_list       => fnd_api.g_true,
                  p_validation_level    => fnd_api.g_valid_level_full,
                  p_pricing_attribs_tbl => l_new_pricing_attribs_tbl, --p_pricing_attribs_tbl,
                  p_txn_rec             => l_trx_rec,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                  g_api_name := 'csi_pricing_attribs_pub.create_pricing_attribs';
                  raise fnd_api.g_exc_error;
                END IF;

                debug('Pricing Attributes created successfully.');

              END IF;

/*
              csi_utl_pkg.create_party_and_acct(
                p_instance_id            => l_instance_id,
                p_txn_line_detail_rec    => l_tld_rec,
                p_txn_party_detail_tbl   => l_tld_party_tbl,
                p_txn_pty_acct_dtl_tbl   => l_tld_account_tbl,
                p_order_line_rec         => l_order_line_rec,
                p_trx_rec                => l_trx_rec,
                x_return_status          => x_return_status);

              IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                raise fnd_api.g_exc_error;
              END IF;
*/

              debug('Party and Account created successfully.');

              IF l_cre_org_units_tbl.count > 0 THEN

                csi_t_gen_utility_pvt.dump_api_info(
                  p_api_name => 'create_organization_unit',
                  p_pkg_name => 'csi_organization_unit_pub');

                csi_organization_unit_pub.create_organization_unit(
                  p_api_version         => 1.0,
                  p_commit              => fnd_api.g_false,
                  p_init_msg_list       => fnd_api.g_true,
                  p_validation_level    => fnd_api.g_valid_level_full,
                  p_org_unit_tbl        => l_cre_org_units_tbl,
                  p_txn_rec             => l_trx_rec,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                  g_api_name := 'csi_organization_unit_pub.create_organization_unit';
                  raise fnd_api.g_exc_error;
                END IF;

                debug('Org Assignment created successfully.');
              END IF;

              -- BEGIN MRK CODE FOR UPDATE EXTENDED ATTRIBUTE

              IF l_cre_ext_attrib_val_tbl.count > 0 THEN

                --Changes for bug 3901064 Start
                  l_old_extended_attribs_tbl.delete;
                  l_new_extended_attribs_tbl.delete;
                  l_ext_old_index := 0;
                  l_ext_new_index := 0;
                --Changes for bug 3901064 End

                FOR i in l_cre_ext_attrib_val_tbl.first..l_cre_ext_attrib_val_tbl.last LOOP
                  BEGIN
                    SELECT attribute_value_id,
                           object_version_number
                    INTO   l_cre_ext_attrib_val_tbl(i).attribute_value_id,
                           l_cre_ext_attrib_val_tbl(i).object_version_number
                    FROM   csi_iea_values
                    WHERE  instance_id = l_cre_ext_attrib_val_tbl(i).instance_id
                    AND    attribute_id = l_cre_ext_attrib_val_tbl(i).attribute_id;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          Null;
                  END;
                  IF (  l_cre_ext_attrib_val_tbl(i).attribute_value_id is not null
                       AND
                        l_cre_ext_attrib_val_tbl(i).attribute_value_id <> fnd_api.g_miss_num
                      )
                  THEN
                    l_old_extended_attribs_tbl(l_ext_old_index) := l_cre_ext_attrib_val_tbl(i);
                    l_ext_old_index                             := l_ext_old_index + 1;
                  ELSE
                    l_new_extended_attribs_tbl(l_ext_new_index) := l_cre_ext_attrib_val_tbl(i);
                    l_ext_new_index                             := l_ext_new_index + 1;
                  END IF;
                END LOOP;
              END IF;

              IF l_old_extended_attribs_tbl.count > 0 THEN
                debug('Update Extended_Attributes Count '||l_old_extended_attribs_tbl.count);

                csi_t_gen_utility_pvt.dump_api_info(
                  p_api_name => 'update_extended_attrib_values',
                  p_pkg_name => 'csi_item_instance_pub');

                csi_item_instance_pub.update_extended_attrib_values(
                  p_api_version         => 1.0,
                  p_commit              => fnd_api.g_false,
                  p_init_msg_list       => fnd_api.g_true,
                  p_validation_level    => fnd_api.g_valid_level_full,
                  p_ext_attrib_tbl      => l_old_extended_attribs_tbl,
                  p_txn_rec             => l_trx_rec,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                   g_api_name := 'csi_item_instance_pub.update_extended_attrib_values';
                   raise fnd_api.g_exc_error;
                END IF;

                debug('Extended Attributed updated successfully.');
              END IF;

              --IF l_cre_ext_attrib_val_tbl.count > 0 THEN
              IF l_new_extended_attribs_tbl.count > 0 THEN
                debug('Create Extended_Attributes Count '||l_new_extended_attribs_tbl.count);

                -- END MRK CODE FOR UPDATE EXTENDED ATTRIBUTE

                csi_t_gen_utility_pvt.dump_api_info(
                  p_api_name => 'create_extended_attrib_values',
                  p_pkg_name => 'csi_item_instance_pub');

                csi_item_instance_pub.create_extended_attrib_values(
                  p_api_version         => 1.0,
                  p_commit              => fnd_api.g_false,
                  p_init_msg_list       => fnd_api.g_true,
                  p_validation_level    => fnd_api.g_valid_level_full,
                  p_ext_attrib_tbl      =>  l_new_extended_attribs_tbl, --l_cre_ext_attrib_val_tbl
                  p_txn_rec             => l_trx_rec,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                  g_api_name := 'csi_item_instance_pub.create_extended_attrib_values';
                  raise fnd_api.g_exc_error;
                END IF;

                debug('Extended Attributed created successfully.');

              END IF;
            END IF;

            IF p_source = 'FULFILLMENT'
               AND
               (NVL(l_tld_rec.active_end_date,l_date)  <> l_date)
            THEN

              /*-----------------------------------------------------*/
              /* If instance is expired then check if there is any   */
              /* relationships in csi_ii_relationship. If exist then */
              /* expire the instance-to-instance relationships also  */
              /*-----------------------------------------------------*/

              BEGIN

                SELECT relationship_id,
                       object_version_number
                INTO   l_relationship_id,
                       l_ii_rel_obj_ver_num
                FROM   csi_ii_relationships
                WHERE  subject_id = l_tld_rec.instance_id
                AND    (active_end_date is null OR active_end_date >= sysdate);

                l_exp_ii_relationship_rec.relationship_id := l_relationship_id;
                l_exp_ii_relationship_rec.object_version_number := l_ii_rel_obj_ver_num;

                csi_t_gen_utility_pvt.dump_api_info(
                  p_api_name => 'expire_relationship',
                  p_pkg_name => 'csi_ii_relationships_pub');

                csi_ii_relationships_pub.expire_relationship(
                  p_api_version           => 1.0,
                  p_commit                => fnd_api.g_false,
                  p_init_msg_list         => fnd_api.g_true,
                  p_validation_level      => fnd_api.g_valid_level_full,
                  p_relationship_rec      => l_exp_ii_relationship_rec,
                  p_txn_rec               => l_trx_rec,
                  x_instance_id_lst       => l_exp_instance_id_tbl,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data);

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                  g_api_name := 'csi_ii_relationship_pub.expire_relationship';
                  raise fnd_api.g_exc_error;
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

            END IF; --l_tld_rec.active_end_date,l_date

            IF (p_order_line_rec.serial_code = 1)
                AND
               (l_split_flag  = 'Y' )
                AND
               (l_upd_instance_rec.quantity > 1)
            THEN

              l_auto_split_instances.delete;
	      --Added for bug 5112946--
              l_upd_instance_rec.version_label            := nvl(l_tld_rec.version_label,fnd_api.g_miss_char);

              auto_split_instances(
                p_instance_rec  => l_upd_instance_rec,
                px_txn_rec      => l_trx_rec,
                x_instance_tbl  => l_auto_split_instances,
                x_return_status => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_auto_split_instances.count > 0 THEN
                l_cp_ind := 0;
                l_cps_tbl.delete;
                FOR nis_ind in l_auto_split_instances.FIRST .. l_auto_split_instances.LAST
                LOOP
                  debug(' Instance ID :'||l_auto_split_instances(nis_ind).instance_id);

                  l_cp_ind := l_cp_ind + 1;
                  l_cps_tbl(l_cp_ind).instance_id        := l_auto_split_instances(nis_ind).instance_id;
                  l_cps_tbl(l_cp_ind).quantity           := 1;
                  l_cps_tbl(l_cp_ind).txn_line_detail_id := l_upd_instance_rec.last_txn_line_detail_id;
                  l_cps_tbl(l_cp_ind).line_id            := l_upd_instance_rec.last_oe_order_line_id;
                  l_cps_tbl(l_cp_ind).transaction_id     := l_trx_rec.transaction_id;

                END LOOP;
              END IF;

              IF p_txn_ii_rltns_tbl.count > 0 THEN

                csi_utl_pkg.build_inst_ii_tbl(
                  p_orig_inst_id     => l_upd_instance_rec.instance_id,
                  p_txn_ii_rltns_tbl => p_txn_ii_rltns_tbl ,
                  p_new_instance_tbl => l_auto_split_instances,
                  x_return_status    => x_return_status  );

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                  raise fnd_api.g_exc_error;
                END IF;

              END IF; -- p_txn_ii_rltns_tbl.count > 0
            END IF; -- l_split_flag  = 'Y'

      ELSE /* Instance reference does not exist so create instance */

        l_cre_instance_rec := l_tmp_instance_rec;

        /* get the master organization */
        csi_utl_pkg.get_master_organization(
          p_organization_id        => l_tld_rec.inv_organization_id,
          p_master_organization_id => x_master_org_id,
          x_return_status          => x_return_status);

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          raise fnd_api.g_exc_error;
        END IF;

        debug('Instance reference does not exist, So calling create API');

        IF NVL(x_trx_sub_type_rec.src_status_id ,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

          l_inst_status_id := l_dflt_inst_status_id;

          l_cre_instance_rec.instance_status_id      := l_inst_status_id;
        ELSE
          l_cre_instance_rec.instance_status_id      := x_trx_sub_type_rec.src_status_id;
        END IF;

        l_trx_rec.txn_sub_type_id := l_tld_rec.sub_type_id;

        /* If the instance reference does not exist then create an instance */

        l_cre_instance_rec.instance_id             := fnd_api.g_miss_num;
        l_cre_instance_rec.instance_number         := fnd_api.g_miss_char;
        l_cre_instance_rec.external_reference      := l_tld_rec.external_reference ;
        l_cre_instance_rec.inventory_item_id       := l_tld_rec.inventory_item_id;
        l_cre_instance_rec.inventory_revision      := l_tld_rec.inventory_revision;
        l_cre_instance_rec.inv_master_organization_id := x_master_org_id;
        l_cre_instance_rec.serial_number           := l_tld_rec.serial_number;
        l_cre_instance_rec.mfg_serial_number_flag  := l_tld_rec.mfg_serial_number_flag;
        l_cre_instance_rec.lot_number              := l_tld_rec.lot_number;
        l_cre_instance_rec.quantity                := l_tld_rec.quantity;
        l_cre_instance_rec.unit_of_measure         := l_tld_rec.unit_of_measure;
        -- l_cre_instance_rec.accounting_class_code   := 'CUST_PROD'   ;
        l_cre_instance_rec.instance_condition_id   := l_tld_rec.item_condition_id;
        l_cre_instance_rec.customer_view_flag      := 'Y';
        l_cre_instance_rec.merchant_view_flag      := 'Y';
        l_cre_instance_rec.sellable_flag           := l_tld_rec.sellable_flag;
        l_cre_instance_rec.system_id               := l_tld_rec.csi_system_id;
        l_cre_instance_rec.instance_type_code      := l_tld_rec.instance_type_code;
        -- l_cre_instance_rec.active_start_date       := l_tld_rec.active_start_date;
        l_cre_instance_rec.active_end_date         := l_tld_rec.active_end_date;
        l_cre_instance_rec.location_type_code      := l_tld_rec.location_type_code;
        l_cre_instance_rec.location_id             := l_tld_rec.location_id;
        -- Changed for Partner ordering
        l_cre_instance_rec.install_location_type_code      := l_tld_rec.install_location_type_code;
        l_cre_instance_rec.source_code             := p_order_line_rec.source_code; -- Added for Siebel Genesis Project
        IF p_order_line_rec.ib_install_loc is not null
          AND
           p_order_line_rec.ib_install_loc <> fnd_api.g_miss_char
        THEN
          BEGIN
            SELECT HCAS.party_site_id
            INTO   l_cre_party_site_id
            FROM   hz_cust_site_uses_all  HCSU,
                   hz_cust_acct_sites_all HCAS
            WHERE  HCSU.site_use_id       = p_order_line_rec.ib_install_loc_id
            AND    HCAS.cust_acct_site_id = HCSU.cust_acct_site_id;

          EXCEPTION
            WHEN others THEN
                 NULL;
          END;

          IF l_cre_party_site_id <> l_tld_rec.install_location_id
          THEN
            l_cre_instance_rec.install_location_id := l_cre_party_site_id;
          -- Added the else for Bug 3419098
          ELSE
            l_cre_instance_rec.install_location_id := l_tld_rec.install_location_id;
          END IF;
        ELSE
          l_cre_instance_rec.install_location_id             := l_tld_rec.install_location_id;
        END IF;
        -- Changed for Partner ordering
        l_cre_instance_rec.vld_organization_id     := l_tld_rec.inv_organization_id;
        l_cre_instance_rec.last_oe_order_line_id   := p_order_line_rec.order_line_id ;
        l_cre_instance_rec.last_txn_line_detail_id := l_tld_rec.txn_line_detail_id ;

        /* Begin fix for Bug 3254347 Install_Date and Start_Date changes */
        IF l_tld_rec.active_start_date IS NOT NULL
          AND
           l_tld_rec.active_start_date <> fnd_api.g_miss_date
        THEN
          IF p_source = 'FULFILLMENT'
          THEN
            --l_cre_instance_rec.active_start_date   := p_order_line_rec.fulfillment_date; Bug 3807619
            l_cre_instance_rec.active_start_date   := nvl(Nvl(l_tld_rec.active_start_date,p_order_line_rec.fulfillment_date),sysdate); -- Bug 7668298
          ELSIF  p_source = 'SHIPMENT'
          THEN
            l_cre_instance_rec.active_start_date   := p_order_line_rec.transaction_date;
          END IF;
        END IF;
        /* End fix for Bug 3254347 Install_Date and Start_Date changes */

        /* Fix for Bug 3578671 */
        debug(' Default Install Date Profile Value '||l_default_install_date);

        IF nvl(l_tld_rec.installation_date,fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
           IF l_default_install_date = 'Y' THEN
              IF p_source =  'SHIPMENT' THEN
                 -- For Bug 3578671
                 IF nvl(p_order_line_rec.actual_shipment_date,fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
                    l_cre_instance_rec.install_date := l_trx_rec.source_transaction_date;
                 ELSE
                    l_cre_instance_rec.install_date := p_order_line_rec.actual_shipment_date;
                 END IF;
              ELSIF p_source = 'FULFILLMENT' THEN
                 -- For Bug 3578671
                 IF nvl(p_order_line_rec.fulfillment_date,fnd_api.g_miss_date) = fnd_api.g_miss_date THEN
                   l_cre_instance_rec.install_date := sysdate;
                 ELSE
                   l_cre_instance_rec.install_date := p_order_line_rec.fulfillment_date;
                 END IF;
              END IF;
           END IF;
        ELSE
          /* Begin fix for Bug 3254347 Install_Date and Start_Date changes */
          IF p_source =  'SHIPMENT' THEN
           l_cre_instance_rec.install_date       :=
               GREATEST(l_tld_rec.installation_date,p_order_line_rec.actual_shipment_date);
          ELSIF p_source = 'FULFILLMENT' THEN
					  l_cre_instance_rec.install_date       := l_tld_rec.installation_date; --Added for bug 7668298
  				 /* --Commented  for bug 7668298
						IF p_order_line_rec.fulfillment_date is NOT NULL
							AND
							 p_order_line_rec.fulfillment_date <> fnd_api.g_miss_date
						THEN
							l_cre_instance_rec.install_date      := GREATEST(l_tld_rec.installation_date,p_order_line_rec.fulfillment_date);
						ELSE
							l_cre_instance_rec.install_date      := GREATEST(l_tld_rec.installation_date,sysdate);
						END IF;
						*/ --Commented  for bug 7668298
					END IF;
					/* End fix for Bug 3254347 Install_Date and Start_Date changes */
        END IF;

        l_cre_instance_rec.manually_created_flag   := 'N';
        l_cre_instance_rec.return_by_date          := l_tld_rec.return_by_date;
        l_cre_instance_rec.creation_complete_flag  := fnd_api.g_miss_char;
        l_cre_instance_rec.completeness_flag       := fnd_api.g_miss_char;
        l_cre_instance_rec.instance_usage_code     := 'OUT_OF_ENTERPRISE';
        l_cre_instance_rec.last_oe_agreement_id    := p_order_line_rec.agreement_id;
        -- Included for Bug 2962072.
        l_cre_instance_rec.version_label           := l_tld_rec.version_label;
        l_cre_instance_rec.operational_status_code := 'NOT_USED';

        /* Fix for Bug 2668504   */
        l_cre_pricing_attribs_tbl := p_pricing_attribs_tbl;

        l_owner_pty_rec  := l_cre_party_tbl(1);
        l_owner_acct_rec := l_cre_party_acct_tbl(1);

        csi_utl_pkg.get_parties_and_accounts(
          p_instance_id      => l_cre_instance_rec.instance_id,
          p_tld_rec          => l_tld_rec,
          p_t_pty_tbl        => l_tld_party_tbl,
          p_t_pty_acct_tbl   => l_tld_account_tbl,
          p_owner_pty_rec    => l_owner_pty_rec,
          p_owner_acct_rec   => l_owner_acct_rec,
          p_order_line_rec   => p_order_line_rec,
          x_i_pty_tbl        => l_cre_party_tbl,
          x_i_pty_acct_tbl   => l_cre_party_acct_tbl,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        --
        -- srramakr TSO with Equipment
        -- Serialized instance gets created as a part of shipment for Items with srl ctl 6 (AT SO Issue)
        -- Hence assigning the config keys during create.
        --
        IF p_order_line_rec.serial_code = 6 THEN
          l_cre_instance_rec.CONFIG_INST_HDR_ID := l_tld_rec.CONFIG_INST_HDR_ID;
          l_cre_instance_rec.CONFIG_INST_REV_NUM := l_tld_rec.CONFIG_INST_REV_NUM;
          l_cre_instance_rec.CONFIG_INST_ITEM_ID := l_tld_rec.CONFIG_INST_ITEM_ID;
        END IF;
        --

        l_cre_instance_rec.sales_currency_code := l_order_line_rec.currency_code;

        IF l_order_line_rec.primary_uom <> l_order_line_rec.order_quantity_uom THEN

          l_item_control_rec.inventory_item_id := l_order_line_rec.inv_item_id;
          l_item_control_rec.organization_id   := l_order_line_rec.inv_org_id;
          l_item_control_rec.primary_uom_code  := l_order_line_rec.primary_uom;

          csi_utl_pkg.get_unit_price_in_primary_uom(
            p_unit_price                => l_order_line_rec.unit_price,
            p_unit_price_uom            => l_order_line_rec.order_quantity_uom,
            px_item_control_rec         => l_item_control_rec,
            x_unit_price_in_primary_uom => l_cre_instance_rec.sales_unit_price,
            x_return_status             => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE
          l_cre_instance_rec.sales_unit_price := l_order_line_rec.unit_price;
        END IF;

        debug('  party_tbl.count           :'||l_cre_party_tbl.count);
        debug('  party_acct_tbl.count      :'||l_cre_party_acct_tbl.count);
        debug('  org_units_tbl.count       :'||l_cre_org_units_tbl.count);
        debug('  inst_asset_tbl.count      :'||l_cre_inst_asset_tbl.count);
        debug('  pricing_attribs_tbl.count :'||l_cre_pricing_attribs_tbl.count);
        debug('  ext_attrib_val_tbl.count  :'||l_cre_ext_attrib_val_tbl.count);

        csi_t_gen_utility_pvt.dump_api_info(
          p_api_name => 'create_item_instance',
          p_pkg_name => 'csi_item_instance_pub');

        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_csi_instance_rec(l_cre_instance_rec);
        END IF;

        /* for order fulfillment instance ref is not there so create an instance */
        csi_item_instance_pub.create_item_instance(
          p_api_version           => 1.0,
          p_commit                => fnd_api.g_false,
          p_init_msg_list         => fnd_api.g_true,
          p_validation_level      => fnd_api.g_valid_level_full,
          p_instance_rec          => l_cre_instance_rec,
          p_ext_attrib_values_tbl => l_cre_ext_attrib_val_tbl,
          p_party_tbl             => l_cre_party_tbl,
          p_account_tbl           => l_cre_party_acct_tbl,
          p_pricing_attrib_tbl    => l_cre_pricing_attribs_tbl,
          p_org_assignments_tbl   => l_cre_org_units_tbl,
          p_asset_assignment_tbl  => l_cre_inst_asset_tbl,
          p_txn_rec               => l_trx_rec,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data  );

        -- For Bug 4057183
        -- IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        IF NOT(x_return_status in(fnd_api.g_ret_sts_success,'W')) THEN
          g_api_name := 'csi_item_instance_pub.create_item_instance';
          raise fnd_api.g_exc_error;
        END IF;

        l_cp_ind := l_cp_ind + 1;

        l_cps_tbl(l_cp_ind).instance_id        := l_cre_instance_rec.instance_id;
        l_cps_tbl(l_cp_ind).quantity           := l_cre_instance_rec.quantity;
        l_cps_tbl(l_cp_ind).txn_line_detail_id := l_cre_instance_rec.last_txn_line_detail_id;
        l_cps_tbl(l_cp_ind).line_id            := l_cre_instance_rec.last_oe_order_line_id;
        l_cps_tbl(l_cp_ind).transaction_id     := l_trx_rec.transaction_id;
        l_cps_tbl(l_cp_ind).serial_number      := l_cre_instance_rec.serial_number;
        l_cps_tbl(l_cp_ind).lot_number         := l_cre_instance_rec.lot_number;

        debug('Instance created successfully. Instance ID :'||l_cre_instance_rec.instance_id);

        l_tld_rec.changed_instance_id    := l_cre_instance_rec.instance_id;

        /* After instance is created assign the instance_id for the subject and object id */

        l_tld_rec.instance_id := l_cre_instance_rec.instance_id;
        l_tld_rec.instance_exists_flag := 'Y';

        debug('  txn_party_detail_tbl.count :'||p_txn_party_detail_tbl.count);
        debug('  txn_pty_acct_dtl_tbl.count :'||p_txn_pty_acct_dtl_tbl.count);

/*
        csi_utl_pkg.create_party_and_acct(
          p_instance_id            => l_cre_instance_rec.instance_id,
          p_txn_line_detail_rec    => l_tld_rec ,
          p_txn_party_detail_tbl   => p_txn_party_detail_tbl ,
          p_txn_pty_acct_dtl_tbl   => p_txn_pty_acct_dtl_tbl,
          p_order_line_rec         => p_order_line_rec,
          p_trx_rec                => l_trx_rec,
          x_return_status          => x_return_status );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          RAISE fnd_api.g_exc_error;
        END IF;
*/

        IF l_cre_instance_rec.quantity > 1
           AND
           l_split_flag  = 'Y'
           AND
           p_order_line_rec.serial_code = 1
        THEN

          l_auto_split_instances.delete;

          auto_split_instances(
            p_instance_rec  => l_cre_instance_rec,
            px_txn_rec      => l_trx_rec,
            x_instance_tbl  => l_auto_split_instances,
            x_return_status => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;


          IF l_auto_split_instances.count > 0 THEN
            l_cp_ind := 0;
            l_cps_tbl.delete;
            FOR nis_ind in l_auto_split_instances.FIRST .. l_auto_split_instances.LAST
            LOOP

              l_cp_ind := l_cp_ind + 1;
              l_cps_tbl(l_cp_ind).instance_id        := l_auto_split_instances(nis_ind).instance_id;
              l_cps_tbl(l_cp_ind).quantity           := 1;
              l_cps_tbl(l_cp_ind).txn_line_detail_id :=
                                        l_cre_instance_rec.last_txn_line_detail_id;
              l_cps_tbl(l_cp_ind).line_id            :=
                                        l_cre_instance_rec.last_oe_order_line_id;
              l_cps_tbl(l_cp_ind).transaction_id     := l_trx_rec.transaction_id;

             END LOOP;
           END IF;

                IF p_txn_ii_rltns_tbl.count > 0 THEN

                  csi_utl_pkg.build_inst_ii_tbl(
                    p_orig_inst_id     => l_cre_instance_rec.instance_id,
                    p_txn_ii_rltns_tbl => p_txn_ii_rltns_tbl,
                    p_new_instance_tbl => l_auto_split_instances,
                    x_return_status    => x_return_status);

                  IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                    raise fnd_api.g_exc_error;
                  END IF;

                  debug('build_inst_ii_tbl completed successfully ');
                END IF; -- p_txn_ii_rltns_tbl.count > 0
              END IF; -- l_split_flag  = 'Y'
            END IF; -- end if for instance_exists_flag = 'Y'

            /* Update the txn_line_detail to processed after updating IB successfully */

            l_tld_rec.processing_status  := 'PROCESSED';
            l_tld_rec.error_code         := NULL;
            l_tld_rec.error_explanation  := NULL;
            l_tld_rec.csi_transaction_id := p_trx_rec.transaction_id;

          END IF;  -- end if for source_trx_flag = 'Y' -- bug 3692473.The child item instances for a Non-sourced item instance gets updated in a replacement scenario. This need to happen after the get_ii_realtion_tbl routine.

          IF l_cps_tbl.COUNT > 0 THEN
            FOR r_cp_ind IN l_cps_tbl.FIRST .. l_cps_tbl.LAST
            LOOP
              l_acp_ind := l_acp_ind + 1;
              l_all_cps_tbl(l_acp_ind) := l_cps_tbl(r_cp_ind);
            END LOOP;
          END IF;

          p_txn_line_detail_tbl(i) := l_tld_rec;

        END LOOP; -- end of for  loop for p_txn_detail_tbl

        debug('customer products :'||l_all_cps_tbl.COUNT);

    -- added for bug
        dump_customer_products(l_all_cps_tbl);

        get_single_qty_instances(
          p_all_cps_tbl    => l_all_cps_tbl,
          x_single_cps_tbl => l_single_cps_tbl);

        IF l_single_cps_tbl.count > 0 THEN

          l_bom_explode_flag := csi_utl_pkg.check_standard_bom(
                                  p_order_line_rec  => l_order_line_rec);

          IF l_bom_explode_flag THEN

            FOR l_scp_ind IN l_single_cps_tbl.FIRST .. l_single_cps_tbl.LAST
            LOOP

              IF NOT(csi_utl_pkg.wip_config_exists(l_single_cps_tbl(l_scp_ind).instance_id)) THEN

                l_bom_std_item_rec.instance_id         := l_single_cps_tbl(l_scp_ind).instance_id ;
                l_bom_std_item_rec.inventory_item_id   := l_order_line_rec.inv_item_id ;
                l_bom_std_item_rec.vld_organization_id := l_order_line_rec.inv_org_id ;
                l_bom_std_item_rec.quantity            := 1;

                l_bom_ind := l_bom_ind + 1;
                l_bom_std_item_tbl(l_bom_ind) := l_bom_std_item_rec;

              END IF;
            END LOOP;

            IF l_bom_std_item_tbl.COUNT > 0 THEN
              debug('explode bom start time :'||to_char(sysdate, 'hh24:mi:ss'));

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_item_instance_grp',
                p_api_name => 'explode_bom');

              csi_item_instance_grp.explode_bom( -- changes done to call the Group API for performance issues, bug3722382
                p_api_version         => 1.0,
                p_commit              => fnd_api.g_false,
                p_init_msg_list       => fnd_api.g_true,
                p_validation_level    => fnd_api.g_valid_level_full,
                p_source_instance_tbl => l_bom_std_item_tbl,
                p_explosion_level     => fnd_api.g_miss_num,
                p_txn_rec             => l_trx_rec,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              debug('explode bom end time   :'||to_char(sysdate, 'hh24:mi:ss'));
            END IF;
          ELSE

            IF l_order_line_rec.item_type_code = 'STANDARD'
               AND
               l_order_line_rec.order_line_id = l_order_line_rec.ato_line_id
               AND
               nvl(l_order_line_rec.top_model_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
               AND
               l_order_line_rec.serial_code in (1, 6)
            THEN

              BEGIN

                SELECT wip_entity_id
                INTO   l_wip_job_id
                FROM   wip_discrete_jobs
                WHERE  primary_item_id = l_order_line_rec.inv_item_id
                AND    organization_id = l_order_line_rec.inv_org_id
                AND    source_line_id  = l_order_line_rec.order_line_id
                AND    status_type    <> 7;  -- excluding the cancelled wip jobs

                get_comp_instances_from_wip(
                  p_wip_entity_id    => l_wip_job_id,
                  p_organization_id  => l_order_line_rec.inv_org_id,
                  p_cps_tbl          => l_single_cps_tbl,
                  px_csi_txn_rec     => l_trx_rec,
                  x_iir_tbl          => l_wip_iir_tbl,
                  x_return_status    => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                IF l_wip_iir_tbl.COUNT > 0 THEN
                  FOR l_w_ind IN l_wip_iir_tbl.FIRST .. l_wip_iir_tbl.LAST
                  LOOP

                    debug('object_id :'||l_wip_iir_tbl(l_w_ind).object_id||
                          'subject_id :'||l_wip_iir_tbl(l_w_ind).subject_id);

                    convert_wip_instance_to_cp(
                      p_instance_id       => l_wip_iir_tbl(l_w_ind).subject_id,
                      p_line_id           => l_order_line_rec.order_line_id,
                      p_csi_txn_rec       => l_trx_rec,
                      x_return_status     => l_return_status);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;

                  END LOOP;

                  csi_t_gen_utility_pvt.dump_api_info(
                    p_api_name => 'create_relationship',
                    p_pkg_name => 'csi_ii_relationships_pub');

                  csi_ii_relationships_pub.create_relationship(
                    p_api_version      => 1.0,
                    p_commit           => fnd_api.g_false,
                    p_init_msg_list    => fnd_api.g_true,
                    p_validation_level => fnd_api.g_valid_level_full,
                    p_relationship_tbl => l_wip_iir_tbl,
                    p_txn_rec          => l_trx_rec,
                    x_return_status    => l_return_status,
                    x_msg_count        => l_msg_count,
                    x_msg_data         => l_msg_data);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;
                END IF;

              EXCEPTION
                WHEN no_data_found THEN
                  null;
                WHEN too_many_rows THEN
                  null;
              END;

            END IF;

          END IF; -- bom explode flag
        END IF;

	-- changes for 3692473. moved the entire code unconditionally to  process relationships
        -- (get_ii_relation_tbl) before the non-source txn details updates.

        -- initialize the pl/sql table
        l_upd_ii_rltns_tbl.delete;
        l_cre_ii_rltns_tbl.delete;

        -- srramakr TSO with Equipment changes.
        -- For a Tangible line under a MACD order, we need to build the relationships using the
        -- relationship records written by Configurator. p_txn_ii_rltns_tbl contains this info.
        -- We will fork the code based on MACD order line flag in l_order_line_rec
        --
        IF l_order_line_rec.macd_order_line = FND_API.G_TRUE THEN
	   csi_interface_pkg.build_relationship_tbl(
	     p_txn_ii_rltns_tbl  =>  p_txn_ii_rltns_tbl,
	     p_txn_line_dtl_tbl  =>  p_txn_line_detail_tbl,
	     x_c_ii_rltns_tbl    =>  l_cre_ii_rltns_tbl,
	     x_u_ii_rltns_tbl    =>  l_upd_ii_rltns_tbl,
	     x_return_status     =>  x_return_status );

           IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
             raise fnd_api.g_exc_error;
           END IF;
        ELSE
           /*  Added p_trx_rec for ER 2581101 */

           csi_utl_pkg.get_ii_relation_tbl(
             p_txn_line_detail_tbl  => p_txn_line_detail_tbl,
             p_txn_ii_rltns_tbl     => p_txn_ii_rltns_tbl ,
             p_trx_rec              => l_trx_rec,
             p_order_line_rec       => l_order_line_rec,
             x_cre_ii_rltns_tbl     => l_cre_ii_rltns_tbl ,
             x_upd_ii_rltns_tbl     => l_upd_ii_rltns_tbl ,
             x_return_status        => x_return_status   );

           IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
             raise fnd_api.g_exc_error;
           END IF;
        END IF; -- MACD Order Check

        debug('upd_txn_ii_rltns_tbl.count :'||l_upd_ii_rltns_tbl.count );
        debug('cre_txn_ii_rltns_tbl.count :'||l_cre_ii_rltns_tbl.count );

        /* update instance relationship in IB */
        IF l_upd_ii_rltns_tbl.count > 0  THEN

          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'update_relationship',
            p_pkg_name => 'csi_ii_relationships_pub');

          csi_ii_relationships_pub.update_relationship(
            p_api_version         => 1.0,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_relationship_tbl    => l_upd_ii_rltns_tbl,
            p_txn_rec             => l_trx_rec,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data  );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;
          debug('update_relationship completed successfully');
        END IF;

          /* Create instance relationships in IB */
        IF l_cre_ii_rltns_tbl.count > 0 THEN

          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'create_relationship',
            p_pkg_name => 'csi_ii_relationships_pub');

          csi_ii_relationships_pub.create_relationship(
            p_api_version         => 1.0,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_relationship_tbl    => l_cre_ii_rltns_tbl,
            p_txn_rec             => l_trx_rec,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data  );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;

          debug('create_relationship completed sucessfully');
        END IF; -- end if for l_cre_txn_ii_rltns_tbl.count > 0

        -- relooping for non-source. bug 3692473

        FOR i IN p_txn_line_detail_tbl.FIRST..p_txn_line_detail_tbl.LAST
        LOOP

          l_tld_rec := p_txn_line_detail_tbl(i);

          IF l_tld_rec.source_transaction_flag = 'N' THEN

            debug('processing tld record # '||i||' source_transaction_flag : '||
                  l_tld_rec.source_transaction_flag);
            IF nvl(l_tld_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num then

              /* check if this is a replacement instnace. If this is replacement
                 then pass the call_contracts flag as false . bug 2298453*/
              l_call_contracts := fnd_api.g_true;

              csi_utl_pkg.call_contracts_chk(
                p_txn_line_detail_id => l_tld_rec.txn_line_detail_id,
                p_txn_ii_rltns_tbl   => p_txn_ii_rltns_tbl,
                x_call_contracts     => l_call_contracts,
                x_return_status      => l_return_status);

              process_non_source(
                p_txn_line_detail_rec => l_tld_rec,
                p_call_contracts      => l_call_contracts,
                p_trx_rec             => l_trx_rec,
                x_return_status       => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                raise fnd_api.g_exc_error;
              END IF;

              /* bug 2351217 non source not stamping the status */
              l_tld_rec.processing_status           := 'PROCESSED';
              l_tld_rec.error_code                  := NULL;
              l_tld_rec.error_explanation           := NULL;
              l_tld_rec.csi_transaction_id          := p_trx_rec.transaction_id;

              p_txn_line_detail_tbl(i) := l_tld_rec;

            END IF;

          END IF;  -- end if for source_trx_flag = 'N'
        END LOOP; -- end of for  loop for p_txn_detail_tbl
      END IF; -- end if for p_txn_detail_tbl.count > 0

      IF p_source in ('SHIPMENT','FULFILLMENT') THEN

        IF p_txn_line_detail_tbl.count > 0 THEN

          debug('Updating the Transaction Details to reflect the processing status.' );

          csi_t_txn_details_grp.update_txn_line_dtls(
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            p_txn_line_rec             => p_txn_line_rec,
            p_txn_line_detail_tbl      => p_txn_line_detail_tbl,
            px_txn_ii_rltns_tbl        => l_upd_txn_ii_rltns_tbl,
            px_txn_party_detail_tbl    => l_upd_txn_party_detail_tbl,
            px_txn_pty_acct_detail_tbl => l_upd_txn_pty_acct_dtl_tbl,
            px_txn_org_assgn_tbl       => l_upd_txn_org_assgn_tbl,
            px_txn_ext_attrib_vals_tbl => l_upd_txn_ext_attr_vals_tbl,
            x_return_status            => x_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data);

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            g_api_name := 'csi_t_txn_details_grp.update_txn_line_dtls';
            raise fnd_api.g_exc_error;
          END IF;

        END IF;
      END IF; -- end of p_source
      -- check if the shipment/fulfillment is the last txn for final update
      -- and spawning ato fulfillments.

      proc_for_last_mtl_trx(
        p_source              => p_source,
        p_transaction_line_id => p_txn_line_rec.transaction_line_id,
        p_order_line_rec      => l_order_line_rec,
        x_return_status       => l_return_status );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      --
      -- srramakr TSO With Equipment
      -- Need to update the Processing status of Configurator written Txn Line and Details.
      -- This status will be used by Filter_Relations while processing the fulfillable line.
      --
      IF l_order_line_rec.macd_order_line = FND_API.G_TRUE THEN
         IF p_txn_line_detail_tbl.count > 0 THEN
            FOR J IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST LOOP
               IF p_txn_line_detail_tbl.EXISTS(J) THEN
                  IF p_txn_line_detail_tbl(J).source_transaction_flag = 'Y' AND
                     p_txn_line_detail_tbl(J).config_inst_hdr_id IS NOT NULL AND
                     p_txn_line_detail_tbl(J).config_inst_rev_num IS NOT NULL AND
                     p_txn_line_detail_tbl(J).config_inst_item_id IS NOT NULL THEN
                     --
                     -- Unlocking the Tangible Item
		     l_config_tbl(1).source_application_id := 542;
		     l_config_tbl(1).config_inst_hdr_id  := p_txn_line_detail_tbl(J).config_inst_hdr_id;
		     l_config_tbl(1).config_inst_item_id := p_txn_line_detail_tbl(J).config_inst_item_id;
		     l_config_tbl(1).config_inst_rev_num := p_txn_line_detail_tbl(J).config_inst_rev_num;
		     l_config_tbl(1).source_txn_header_ref := l_order_line_rec.header_id;
                     l_config_tbl(1).source_txn_line_ref1 := l_order_line_rec.order_line_id;
                     --
                     debug('Calling csi_cz_int.unlock_item_instances...');
		     csi_cz_int.unlock_item_instances(
			      p_api_version               => 1.0,
			      p_init_msg_list             => fnd_api.g_true,
			      p_commit                    => fnd_api.g_false,
			      p_validation_level          => fnd_api.g_valid_level_full,
			      p_config_tbl                => l_config_tbl,
			      x_return_status             => x_return_status,
			      x_msg_count                 => x_msg_count,
			      x_msg_data                  => x_msg_data);

		     IF x_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE fnd_api.g_exc_error;
		     END IF;
		     --
                     debug('Updating CONFIGURATOR Created Transaction Details...');
                     --
                     UPDATE CSI_T_TRANSACTION_LINES
                     set PROCESSING_STATUS = 'PROCESSED'
                     where transaction_line_id in
                                ( select transaction_line_id
                                  from CSI_T_TXN_LINE_DETAILS
                                  where config_inst_hdr_id = p_txn_line_detail_tbl(J).config_inst_hdr_id
                                  and   config_inst_rev_num = p_txn_line_detail_tbl(J).config_inst_rev_num
                                  and   config_inst_item_id = p_txn_line_detail_tbl(J).config_inst_item_id
                                 )
                     and  processing_status = 'SUBMIT';
                     --
                     UPDATE CSI_T_TXN_LINE_DETAILS
                     set PROCESSING_STATUS = 'PROCESSED'
                     where config_inst_hdr_id = p_txn_line_detail_tbl(J).config_inst_hdr_id
                     and   config_inst_rev_num = p_txn_line_detail_tbl(J).config_inst_rev_num
                     and   config_inst_item_id = p_txn_line_detail_tbl(J).config_inst_item_id
                     and   source_transaction_flag = 'Y'
                     and  processing_status = 'SUBMIT';
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;
    END IF; -- end if for p_validate_flag = 'N'

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count ,
      p_data  => x_msg_data );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_install_base;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_install_base;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data );
    WHEN others THEN

      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', substr(sqlerrm, 1, 240));
      fnd_msg_pub.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data );

  END update_install_base;

  /*----------------------------------------------------------*/
  /* Procedure name:  validate_txn_tbl                        */
  /* Description : Procedure that validates the               */
  /*               txn line details and the child tables      */
  /*----------------------------------------------------------*/

  PROCEDURE validate_txn_tbl(
    p_txn_line_rec            IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_pty_acct_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_order_line_rec          IN OUT NOCOPY order_line_rec,
    p_source                  IN varchar2,
    x_return_status           OUT NOCOPY varchar2)
  IS

    x_txn_sub_type_rec    txn_sub_type_rec;
    l_found               BOOLEAN := FALSE;
    l_owner_count         NUMBER;
    l_ii_rel_id           NUMBER;
    l_curr_object_id      NUMBER;
    l_curr_subject_id     NUMBER;
    l_object_inst_id      NUMBER;
    l_trx_type_id         NUMBER;
    l_org_assign          BOOLEAN := FALSE;
    l_ind_org             NUMBER;
    l_party_id            NUMBER;
    l_pty                 NUMBER := 0;
    l_acct                NUMBER := 0;
    l_txn_party_detail_id NUMBER;
    l_sold_to_pty         BOOLEAN := TRUE;
    l_sold_to_acct        BOOLEAN := TRUE;
    l_acct_owner_count    NUMBER;
    l_sold_from_org_found varchar2(1);
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

    -- Partner ordering
    l_owner_party         NUMBER;

    -- Porting 11.5.9 changes for Bug 3625218
    l_owner_txn_pty_dtl_id NUMBER := 0;
    l_owner_pty_accounts  varchar2(1) := 'N';
    l_owner_pty_contacts  varchar2(1) := 'N';

  BEGIN

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('validate_txn_tbl');

    IF p_txn_line_detail_tbl.count > 0 THEN
      FOR i IN p_txn_line_detail_tbl.FIRST..p_txn_line_detail_tbl.LAST LOOP

        debug('  txn_line_detail_id      :'||p_txn_line_detail_tbl(i).txn_line_detail_id);
        debug('  source_transaction_flag :'||p_txn_line_detail_tbl(i).source_transaction_flag);
        debug('  instance_exists_flag    :'||p_txn_line_detail_tbl(i).instance_exists_flag);
        debug('  instance_id             :'||p_txn_line_detail_tbl(i).instance_id);
        debug('  quantity                :'||p_txn_line_detail_tbl(i).quantity);

        /* Derive the trx_sub_type from the txn details */
        csi_utl_pkg.get_sub_type_rec(
          p_sub_type_id        => p_txn_line_detail_tbl(i).sub_type_id,
          p_trx_type_id        => p_txn_line_rec.source_transaction_type_id,
          x_trx_sub_type_rec   => x_txn_sub_type_rec,
          x_return_status      => x_return_status) ;

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          raise fnd_api.g_exc_error;
        END IF;

        /*-----------------------------------------------------------------*/
        /* If Org assignment with 'SOLD_FROM' relationship_type_code       */
        /* does not exist then 'SOLD_FROM' create an org assignments       */
        /*-----------------------------------------------------------------*/

        IF nvl(p_order_line_rec.sold_from_org_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN
          IF p_txn_org_assgn_tbl.count > 0 THEN
            FOR l_org in p_txn_org_assgn_tbl.first..p_txn_org_assgn_tbl.last
            LOOP
              IF p_txn_org_assgn_tbl(l_org).txn_line_detail_id = p_txn_line_detail_tbl(i).txn_line_detail_id
                 AND
                 p_txn_org_assgn_tbl(l_org).relationship_type_code='SOLD_FROM'
              THEN
                l_org_assign := TRUE;
              END IF;
            END LOOP;
          END IF;

          IF NOT(l_org_assign) THEN
            /* also check if the instance reference already has a SOLD_FROM relation */
            IF nvl(p_txn_line_detail_tbl(i).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              BEGIN
                SELECT 'X'
                INTO   l_sold_from_org_found
                FROM   csi_i_org_assignments
                WHERE  instance_id = p_txn_line_detail_tbl(i).instance_id
		AND    operating_unit_id  = p_order_line_rec.sold_from_org_id
                AND    relationship_type_code = 'SOLD_FROM'
		AND    nvl (active_end_date, sysdate+1) > sysdate;



                l_org_assign := TRUE;

              EXCEPTION
                WHEN no_data_found THEN
                  l_org_assign := FALSE;
                WHEN too_many_rows THEN
                  l_org_assign := TRUE;
              END;
            END IF;
          END IF;

          IF NOT(l_org_assign) THEN
            l_ind_org := p_txn_org_assgn_tbl.count + 1;

            debug('Building the SOLD_FROM org assignment.. ' );

            p_txn_org_assgn_tbl(l_ind_org).txn_operating_unit_id  := fnd_api.g_miss_num;
            p_txn_org_assgn_tbl(l_ind_org).txn_line_detail_id     := p_txn_line_detail_tbl(i).txn_line_detail_id;
            p_txn_org_assgn_tbl(l_ind_org).instance_ou_id         := fnd_api.g_miss_num;
            p_txn_org_assgn_tbl(l_ind_org).operating_unit_id      := p_order_line_rec.sold_from_org_id;
            p_txn_org_assgn_tbl(l_ind_org).relationship_type_code := 'SOLD_FROM';
            p_txn_org_assgn_tbl(l_ind_org).active_start_date      := sysdate;
            p_txn_org_assgn_tbl(l_ind_org).active_end_date        := p_txn_line_detail_tbl(i).active_end_date; -- fix for 4293723
            p_txn_org_assgn_tbl(l_ind_org).preserve_detail_flag   := 'Y';
            p_txn_org_assgn_tbl(l_ind_org).txn_line_details_index := i;
            p_txn_org_assgn_tbl(l_ind_org).object_version_number  := 1;

          END IF;
        END IF;
        -- Begin porting of fix for Bug 3625218 -- To get party detail for OWNER party
        IF p_txn_party_detail_tbl.count > 0 THEN
          FOR j in p_txn_party_detail_tbl.FIRST..p_txn_party_detail_tbl.LAST LOOP
                IF p_txn_party_detail_tbl(j).relationship_type_code = 'OWNER'
                   AND
                   p_txn_party_detail_tbl(j).contact_flag = 'N'
                   AND
                   p_txn_party_detail_tbl(j).txn_line_detail_id = p_txn_line_detail_tbl(i).txn_line_detail_id
                THEN
                  l_owner_txn_pty_dtl_id  := p_txn_party_detail_tbl(j).txn_party_detail_id;
                  exit;
                END IF;
          END LOOP;
        END IF;
        -- End porting of fix for Bug 3625218
        /* sub type validation for source transactions */

        IF p_txn_line_detail_tbl(i).source_transaction_flag = 'Y' THEN

          l_owner_count := 0;
          l_acct_owner_count := 0;

          /*---------------------------------------*/
          /* Validate the following things if      */
          /*    1. there is owner party            */
          /*    2. there is an owner party account */
          /*    2. the sold_to party is passed     */
          /*    3. the sold_to account is passed   */
          /*---------------------------------------*/

          IF p_txn_party_detail_tbl.COUNT > 0 THEN
            FOR l_index IN p_txn_party_detail_tbl.FIRST .. p_txn_party_detail_tbl.LAST
            LOOP

              IF p_txn_party_detail_tbl(l_index).txn_line_detail_id =
                 p_txn_line_detail_tbl(i).txn_line_detail_id
              THEN

                IF p_txn_party_detail_tbl(l_index).relationship_type_code = 'OWNER' THEN
                  l_owner_count := l_owner_count + 1;
                END IF;

                IF p_txn_party_detail_tbl(l_index).relationship_type_code = 'SOLD_TO' THEN
                  l_sold_to_pty := FALSE;
                END IF;
                -- Begin porting for 11.5.9 3625218: Check for additional contacts that exists for OWNER party
                IF p_txn_party_detail_tbl(l_index).contact_party_id = l_owner_txn_pty_dtl_id
                   AND
                   p_txn_party_detail_tbl(l_index).contact_flag = 'Y'
                THEN
                   l_owner_pty_contacts := 'Y';
                END IF;
                -- End porting for 11.5.9 3625218
                IF p_txn_pty_acct_dtl_tbl.count > 0 THEN
                  FOR l_ind_acct in p_txn_pty_acct_dtl_tbl.first..p_txn_pty_acct_dtl_tbl.last
                  LOOP
                    IF p_txn_pty_acct_dtl_tbl(l_ind_acct).txn_party_detail_id =
                       p_txn_party_detail_tbl(l_index).txn_party_detail_id
                    THEN
                      -- Begin porting for 3625218: Check for additional accounts that exists for OWNER party
                      IF p_txn_party_detail_tbl(l_index).relationship_type_code = 'OWNER'
                               AND
                         p_txn_pty_acct_dtl_tbl(l_ind_acct).relationship_type_code <> 'OWNER' THEN
                                 l_owner_pty_accounts := 'Y';
                      END IF;
                      -- End porting for 3625218
                      IF p_txn_pty_acct_dtl_tbl(l_ind_acct).relationship_type_code = 'OWNER' THEN
                        l_acct_owner_count := l_acct_owner_count + 1;
                      END IF;

                      IF p_txn_pty_acct_dtl_tbl(l_ind_acct).relationship_type_code = 'SOLD_TO' THEN
                        l_sold_to_acct := FALSE;
                      END IF;
                    END IF;
                  END LOOP;
                END IF ;  --p_txn_pty_acct_dtl_tbl.count > 0
              END IF;
            END LOOP;
          END IF;--p_txn_party_detail_tbl.COUNT > 0

          /* If multiple owner exists then raise error */
          IF (l_owner_count > 1) THEN
            fnd_message.set_name('CSI','CSI_INT_MULTIPLE_OWNER');
            fnd_message.set_token('TXN_LINE_DETAIL_ID', p_txn_line_detail_tbl(i).txn_line_detail_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

          /* If src_change_owner = Y and owner party does not exist then raise error */
          IF x_txn_sub_type_rec.src_change_owner = 'Y' THEN
            IF (l_owner_count = 0) THEN
              fnd_message.set_name('CSI','CSI_INT_PTY_OWNER_MISSING');
              fnd_message.set_token('TXN_LINE_DETAIL_ID', p_txn_line_detail_tbl(i).txn_line_detail_id);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            END IF;
          END IF;

          IF nvl(x_txn_sub_type_rec.src_change_owner, 'N') = 'N' THEN
            p_order_line_rec.ship_to_contact_id := fnd_api.g_miss_num;
            p_order_line_rec.invoice_to_contact_id := fnd_api.g_miss_num;
          END IF;

          /* If multiple owner exists then raise error */
          IF (l_acct_owner_count > 1) THEN
            fnd_message.set_name('CSI','CSI_INT_MULTI_ACCT_OWNER');
            fnd_message.set_token('TXN_LINE_DETAIL_ID', p_txn_line_detail_tbl(i).txn_line_detail_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

          /* If src_change_owner = Y and owner party does not exist then raise error */
          IF x_txn_sub_type_rec.src_change_owner = 'Y' THEN
            IF (l_acct_owner_count = 0) THEN
              fnd_message.set_name('CSI','CSI_INT_ACCT_OWNER_MISSING');
              fnd_message.set_token('TXN_LINE_DETAIL_ID', p_txn_line_detail_tbl(i).txn_line_detail_id);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            END IF;
          END IF;

          /*---------------------------------------------------------*/
          /*   Check if the OWNER party passed matches with the      */
          /*   Shipped OWNER party . If it does not match then update*/
          /*   update the party with the Shipped OWNER Party .       */
          /*   Also create another party rec with the 'SOLD_TO'      */
          /*   relationship                                          */
          /*---------------------------------------------------------*/

          l_pty  := p_txn_party_detail_tbl.count + 1;
          l_acct := p_txn_pty_acct_dtl_tbl.count + 1;

          IF p_txn_party_detail_tbl.COUNT > 0 THEN
            FOR l_txn_pty in p_txn_party_detail_tbl.first..p_txn_party_detail_tbl.last
            LOOP
              IF p_txn_party_detail_tbl(l_txn_pty).txn_line_detail_id =
                 p_txn_line_detail_tbl(i).txn_line_detail_id
                 AND
                 p_txn_party_detail_tbl(l_txn_pty).relationship_type_code = 'OWNER'
                 AND
                 l_sold_to_pty
              THEN

                debug('Building the SOLD_TO Party record.');

                BEGIN
                  SELECT csi_t_party_details_s.nextval
                  INTO   l_txn_party_detail_id
                  FROM   sys.dual;
                EXCEPTION
                  WHEN others THEN
                    debug('Sequence csi_t_party_details_s is missing');
                    raise fnd_api.g_exc_error;
                END;

                p_txn_party_detail_tbl(l_pty) := p_txn_party_detail_tbl(l_txn_pty);
                p_txn_party_detail_tbl(l_pty).instance_party_id := fnd_api.g_miss_num;
                p_txn_party_detail_tbl(l_pty).txn_party_detail_id := l_txn_party_detail_id;
                p_txn_party_detail_tbl(l_pty).relationship_type_code := 'SOLD_TO';

                csi_utl_pkg.get_party_id(
                  p_cust_acct_id  => p_order_line_rec.sold_to_org_id,
                  x_party_id      => l_party_id,
                  x_return_status => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                p_txn_party_detail_tbl(l_pty).party_source_id        := l_party_id;

                csi_utl_pkg.get_party_id(
                  p_cust_acct_id  => p_order_line_rec.end_customer_id,
                  x_party_id      => l_owner_party,
                  x_return_status => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;
                --Added clause to if condition for bug 5897123 (FP 5764676)
                IF p_txn_party_detail_tbl(l_txn_pty).party_source_id <> l_owner_party AND x_txn_sub_type_rec.src_change_owner = 'Y' THEN
                  -- Begin porting for 3625218: If owner party mismatch occurs then Erroring out if
                  -- additional contacts/accounts exists for OWNER party.:w!
                  IF l_owner_pty_accounts = 'Y'
                    OR
                     l_owner_pty_contacts = 'Y'
                  THEN
                    fnd_message.set_name('CSI','CSI_OWNER_PARTY_MISMATCH');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
                  END IF;
                  -- End porting for 3625218
                  debug('Party_id on txn_dtls is not same as Shipment Party_id ');
                  p_txn_party_detail_tbl(l_txn_pty).party_source_id := l_owner_party ;
                  -- Added this for Bug 3757156
                  p_txn_party_detail_tbl(l_pty).party_source_id := l_party_id;
                  -- End fix for Bug 3757156
                END IF;

                IF p_txn_pty_acct_dtl_tbl.count > 0 THEN
                  FOR l_txn_acct in p_txn_pty_acct_dtl_tbl.first..p_txn_pty_acct_dtl_tbl.last
                  LOOP
                    IF p_txn_pty_acct_dtl_tbl(l_txn_acct).txn_party_detail_id =
                       p_txn_party_detail_tbl(l_txn_pty).txn_party_detail_id
                       AND
                       p_txn_pty_acct_dtl_tbl(l_txn_acct).relationship_type_code = 'OWNER'
                       AND
                       l_sold_to_acct
                     THEN

                       debug('Building the SOLD_TO Account record. ');
                       p_txn_pty_acct_dtl_tbl(l_acct) := p_txn_pty_acct_dtl_tbl(l_txn_acct);
                       p_txn_pty_acct_dtl_tbl(l_acct).ip_account_id  := fnd_api.g_miss_num;
                       p_txn_pty_acct_dtl_tbl(l_acct).txn_party_detail_id := l_txn_party_detail_id;
                       p_txn_pty_acct_dtl_tbl(l_acct).relationship_type_code := 'SOLD_TO';
                       p_txn_pty_acct_dtl_tbl(l_acct).account_id :=  p_order_line_rec.sold_to_org_id;

                       -- Begin fix for Bug 3757156
                       p_txn_pty_acct_dtl_tbl(l_acct).bill_to_address_id     :=
                         p_order_line_rec.invoice_to_org_id;
                       p_txn_pty_acct_dtl_tbl(l_acct).ship_to_address_id     :=
                         p_order_line_rec.ship_to_org_id;
                       -- End Fix for Bug 3757156

                       -- Fix for Bug 2666489
                       IF p_txn_pty_acct_dtl_tbl(l_txn_acct).account_id <> p_order_line_rec.end_customer_id
                        OR p_txn_pty_acct_dtl_tbl(l_txn_acct).bill_to_address_id <> -- added for bug 5075764
                           p_order_line_rec.invoice_to_org_id
                        OR p_txn_pty_acct_dtl_tbl(l_txn_acct).ship_to_address_id <> -- added for bug 5075764
                           p_order_line_rec.ship_to_org_id
		       THEN
                           debug('Party_Account_id on txn_dtls is not same as Shipment Party_Account_id ');
                           p_txn_pty_acct_dtl_tbl(l_txn_acct).account_id         := p_order_line_rec.end_customer_id; -- p_order_line_rec.sold_to_org_id;
                           p_txn_pty_acct_dtl_tbl(l_txn_acct).bill_to_address_id := p_order_line_rec.invoice_to_org_id;
                           p_txn_pty_acct_dtl_tbl(l_txn_acct).ship_to_address_id := p_order_line_rec.ship_to_org_id;
                        END IF;
                        -- End of fix for Bug 2666489.
                    END IF;
                  END LOOP;
                END IF; -- p_txn_pty_acct_dtl_tbl.count > 0
              END IF; -- end if for the match txn_party_detail_id
            END LOOP;
          END IF; -- p_txn_party_detail_tbl.COUNT > 0

          /* If the src_reference_reqd = "Y" then check if the instance is referenced */
          IF x_txn_sub_type_rec.src_reference_reqd = 'Y'
             AND
             NVL(p_txn_line_detail_tbl(i).instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
            fnd_message.set_name('CSI','CSI_INT_INST_REF_MISSING');
            fnd_message.set_token('TXN_LINE_DETAIL_ID', p_txn_line_detail_tbl(i).txn_line_detail_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

          /* If the src_return_reqd = "Y" then check if the return_by_date is not null */
          IF x_txn_sub_type_rec.src_return_reqd = 'Y'
             AND
             NVL(p_txn_line_detail_tbl(i).return_by_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
          THEN
            fnd_message.set_name('CSI','CSI_INT_RET_DATE_MISSING');
            fnd_message.set_token('TXN_LINE_DETAIL_ID', p_txn_line_detail_tbl(i).txn_line_detail_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

          IF p_txn_party_detail_tbl.count > 0 THEN
            FOR j in p_txn_party_detail_tbl.first..p_txn_party_detail_tbl.last LOOP
              IF p_txn_party_detail_tbl(j).txn_line_detail_id = p_txn_line_detail_tbl(i).txn_line_detail_id THEN

                IF NVL(p_txn_line_detail_tbl(i).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num AND
                   NVL(p_txn_party_detail_tbl(j).instance_party_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num  THEN

                   /* validate if the instance_party_id is for that instance_id */
                   l_found := csi_utl_pkg.validate_inst_party
                                             (p_txn_line_detail_tbl(i).instance_id,
                                              p_txn_party_detail_tbl(j).instance_party_id,
                                              p_txn_party_detail_tbl(j).relationship_type_code);

                   IF NOT(l_found) THEN
                     fnd_message.set_name('CSI','CSI_INT_INV_INST_PTY_ID');
                     fnd_message.set_token('INSTANCE_ID',p_txn_line_detail_tbl(i).instance_id);
                     fnd_message.set_token('INSTANCE_PARTY_ID',p_txn_party_detail_tbl(j).instance_party_id);
                     fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_txn_party_detail_tbl(j).relationship_type_code);
                     fnd_msg_pub.add;
                     raise fnd_api.g_exc_error;
                   END IF;
                 END IF;

                 IF (p_txn_party_detail_tbl(j).relationship_type_code = 'OWNER') THEN
                  IF (x_txn_sub_type_rec.src_change_owner = 'Y') THEN

                    IF NVL(p_txn_line_detail_tbl(i).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                      IF x_txn_sub_type_rec.src_chg_owner_code = 'E' THEN

                        /* if change_owner = Y and chg_owner_code = E then party id should
                        be external party id */
                        IF p_txn_party_detail_tbl(j).party_source_id = p_order_line_rec.internal_party_id THEN
                          fnd_message.set_name('CSI','CSI_INT_INV_PTY_ID');
                          fnd_message.set_token('PARTY_ID',p_txn_party_detail_tbl(j).party_source_id);
                          fnd_message.set_token('INTERNAL_PARTY_ID',p_order_line_rec.internal_party_id);
                          fnd_msg_pub.add;
                          raise fnd_api.g_exc_error;
                        END IF;
                      ELSE
                        /* if change_owner = N and chg_owner_code <> E then party id should
                        be external party id */
                        IF p_txn_party_detail_tbl(j).party_source_id <> p_order_line_rec.internal_party_id THEN
                          fnd_message.set_name('CSI','CSI_INT_INV_PTY_ID');
                          fnd_message.set_token('PARTY_ID',p_txn_party_detail_tbl(j).party_source_id);
                          fnd_message.set_token('INTERNAL_PARTY_ID',p_order_line_rec.internal_party_id);
                          fnd_msg_pub.add;
                          raise fnd_api.g_exc_error;
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END LOOP;
          END IF;
        ELSIF p_txn_line_detail_tbl(i).source_transaction_flag = 'N' THEN
          /* sub type validation for non-source transactions */

          /* If the src_reference_reqd = "Y" then check if the instance is referenced */
          IF x_txn_sub_type_rec.nsrc_reference_reqd = 'Y'
             AND
             NVL(p_txn_line_detail_tbl(i).instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
            fnd_message.set_name('CSI','CSI_INT_INST_REF_MISSING');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

          /* If the src_return_reqd = "Y" then check if the return_by_date is not null */

          IF x_txn_sub_type_rec.nsrc_return_reqd = 'Y'
             AND
              NVL(p_txn_line_detail_tbl(i).return_by_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
          THEN
            fnd_message.set_name('CSI','CSI_INT_RET_DATE_MISSING');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

          /* If  src_reference_reqd = 'Y' then the relationship should be defined in the txn_ii_rltns_tbl */

         IF x_txn_sub_type_rec.src_reference_reqd = 'Y'
            AND
            NOT(csi_utl_pkg.check_relation_exists(
              p_txn_ii_rltns_tbl,
              p_txn_line_detail_tbl(i).txn_line_detail_id))
         THEN
           fnd_message.set_name('CSI','CSI_INT_NSRC_REL_MISSING');
           fnd_message.set_token('TXN_LINE_DETAIL_ID',p_txn_line_detail_tbl(i).txn_line_detail_id );
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         END IF;

         IF p_txn_party_detail_tbl.count > 0 THEN
           FOR j in p_txn_party_detail_tbl.first..p_txn_party_detail_tbl.last LOOP
             IF p_txn_party_detail_tbl(j).txn_line_detail_id = p_txn_line_detail_tbl(i).txn_line_detail_id THEN

               IF NVL(p_txn_line_detail_tbl(i).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num AND
                  NVL(p_txn_party_detail_tbl(j).instance_party_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

                  /* validate if the instance_party_id is for that instance_id */

                 l_found := csi_utl_pkg.validate_inst_party
                                             (p_txn_line_detail_tbl(i).instance_id,
                                              p_txn_party_detail_tbl(j).instance_party_id,
                                              p_txn_party_detail_tbl(j).relationship_type_code);
                 IF NOT(l_found) THEN
                   fnd_message.set_name('CSI','CSI_INT_INV_INST_PTY_ID');
                   fnd_message.set_token('INSTANCE_ID',p_txn_line_detail_tbl(i).instance_id);
                   fnd_message.set_token('INSTANCE_PARTY_ID',p_txn_party_detail_tbl(j).instance_party_id);
                   fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_txn_party_detail_tbl(j).relationship_type_code);
                   fnd_msg_pub.add;
                   raise fnd_api.g_exc_error;
                 END IF;
               END IF;

               IF (p_txn_party_detail_tbl(j).relationship_type_code = 'OWNER') THEN
                 IF (x_txn_sub_type_rec.nsrc_change_owner = 'Y') THEN

                   IF x_txn_sub_type_rec.nsrc_chg_owner_code = 'E' THEN

                     /* if change_owner = Y and chg_owner_code = E then party id should
                     be external party id */
                     IF p_txn_party_detail_tbl(j).party_source_id = p_order_line_rec.internal_party_id THEN
                       fnd_message.set_name('CSI','CSI_INT_INV_PTY_ID');
                       fnd_message.set_token('PARTY_ID',p_txn_party_detail_tbl(j).party_source_id);
                       fnd_message.set_token('INSTANCE_PARTY_ID',p_order_line_rec.internal_party_id);
                       fnd_msg_pub.add;
                       raise fnd_api.g_exc_error;
                     END IF;
                   ELSE

                     /* if change_owner = N and chg_owner_code <> E then party id should
                     be external party id */

                     IF p_txn_party_detail_tbl(j).party_source_id <> p_order_line_rec.internal_party_id THEN
                       fnd_message.set_name('CSI','CSI_INT_INV_PTY_ID');
                       fnd_message.set_token('PARTY_ID',p_txn_party_detail_tbl(j).party_source_id);
                       fnd_message.set_token('INSTANCE_PARTY_ID',p_order_line_rec.internal_party_id);
                       fnd_msg_pub.add;
                       raise fnd_api.g_exc_error;
                     END IF;
                   END IF;
                 END IF;
               END IF;
             END IF;
           END LOOP;
         END IF;
       END IF;
     END LOOP;
   END IF;

   /* validating the relationships */

    IF p_txn_ii_rltns_tbl.count > 0 THEN
     FOR j in p_txn_ii_rltns_tbl.first..p_txn_ii_rltns_tbl.last LOOP

       debug('Validating ii_relationships .. ' );

       IF NVL(p_txn_ii_rltns_tbl(j).csi_inst_relationship_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

         csi_utl_pkg.get_inst_relation(
           p_ii_relationship_id => p_txn_ii_rltns_tbl(j).csi_inst_relationship_id,
           x_object_id          => l_curr_object_id,
           x_subject_id         => l_curr_subject_id,
           x_return_status      => x_return_status);

         IF NOT(x_return_status = fnd_api.g_ret_sts_success)  THEN
           fnd_message.set_name('CSI','CSI_INT_II_REL_MISSING');
           fnd_message.set_token('II_RELATIONSHIP_ID',p_txn_ii_rltns_tbl(j).csi_inst_relationship_id);
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         END IF;

         IF p_txn_line_detail_tbl.count > 0 THEN
           FOR i IN p_txn_line_detail_tbl.FIRST..p_txn_line_detail_tbl.LAST LOOP
             IF p_txn_line_detail_tbl(i).txn_line_detail_id = p_txn_ii_rltns_tbl(j).object_id then
               l_object_inst_id := p_txn_line_detail_tbl(i).instance_id;
               exit;
             END IF;
           END LOOP;
         END IF;

         /* Check if the object id is being updated, if so raise error */

         IF l_curr_object_id <> l_object_inst_id THEN
           fnd_message.set_name('CSI','CSI_INT_OBJ_ID_NOT_ALLOW_UPD');
           fnd_message.set_token('OBJECT_ID',l_object_inst_id);
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         END IF;

       END IF;

      ---Added (Start) for m-to-m enhancements
      -- IF p_txn_ii_rltns_tbl(j).relationship_type_code <> 'COMPONENT-OF' THEN
      --   debug('Only Component of relationship is allowed');
      -- END IF;
      ---Added (End) for m-to-m enhancements

     END LOOP;
     END IF; -- end of relationship validation

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END validate_txn_tbl;

  /*----------------------------------------------------------*/
  /* Procedure name:  process_option_item                     */
  /* Description : Procedure used to create the txn line      */
  /* details if the txn line dtls have to be splitted in qty  */
  /* ratio and txn details does not exist                     */
  /*----------------------------------------------------------*/

  PROCEDURE process_option_item(
    p_serial_code        IN     NUMBER,
    p_order_line_rec     IN     order_line_rec,
    p_txn_sub_type_rec   IN     txn_sub_type_rec,
    p_trackable_parent   IN      BOOLEAN,
    x_order_shipment_tbl IN OUT NOCOPY order_shipment_tbl,
    x_model_inst_tbl     IN OUT NOCOPY model_inst_tbl,
    x_trx_line_id           OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_qty_ratio     NUMBER;
    l_instance_id   NUMBER;
    l_inst_party_id NUMBER;
    l_ip_account_id NUMBER;
    l_txn_ii        NUMBER := 1;
    l_index         NUMBER;
    x_msg_count     NUMBER;
    x_msg_data      varchar2(2000);
    l_party_site_id NUMBER;
    l_trx_line_id   NUMBER;

    x_cre_txn_line_rec            csi_t_datastructures_grp.txn_line_rec ;
    x_txn_line_dtl_rec            csi_t_datastructures_grp.txn_line_detail_rec;
    x_cre_txn_line_dtls_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    x_cre_txn_party_dtls_tbl      csi_t_datastructures_grp.txn_party_detail_tbl ;
    x_cre_txn_pty_acct_dtls_tbl   csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    x_cre_txn_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    x_cre_txn_ext_attb_vals_tbl   csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    x_cre_txn_systems_tbl         csi_t_datastructures_grp.txn_systems_tbl;
    x_cre_txn_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_install_party_site_id  NUMBER;
    l_parent_line_qty        NUMBER := fnd_api.g_miss_num;
    l_return_status       varchar2(1)   := fnd_api.g_ret_sts_success;

  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('process_option_item');

    /* Initialize the pl/sql tables */
    x_cre_txn_line_dtls_tbl.delete;
    x_cre_txn_party_dtls_tbl.delete;
    x_cre_txn_pty_acct_dtls_tbl.delete;
    x_cre_txn_org_assgn_tbl.delete;
    x_cre_txn_ext_attb_vals_tbl.delete;
    x_cre_txn_systems_tbl.delete;
    x_cre_txn_ii_rltns_tbl.delete;

    -- assign values for the columns in Txn_line_rec
    x_cre_txn_line_rec.transaction_line_id        := fnd_api.g_miss_num;
    x_cre_txn_line_rec.source_transaction_id      := p_order_line_rec.order_line_id;
    x_cre_txn_line_rec.source_transaction_type_id := g_txn_type_id;
    x_cre_txn_line_rec.source_transaction_table   := 'WSH_DELIVERY_DETAILS';
    x_cre_txn_line_rec.processing_status          := 'IN_PROCESS';
    x_cre_txn_line_rec.object_version_number      := 1;

--Code added for bug5194812--
 IF x_cre_txn_line_rec.source_transaction_type_id = 401 THEN
    x_cre_txn_line_rec.config_session_hdr_id  := p_order_line_rec.config_header_id;
    x_cre_txn_line_rec.config_session_rev_num := p_order_line_rec.config_rev_nbr;
    x_cre_txn_line_rec.config_session_item_id := p_order_line_rec.configuration_id;
    x_cre_txn_line_rec.api_caller_identity       := 'CONFIG';
 END IF;
--Code end for bug5194812--

    BEGIN

      SELECT transaction_line_id
      INTO   l_trx_line_id
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_id      = x_cre_txn_line_rec.source_transaction_id
      and    source_transaction_table   = x_cre_txn_line_rec.source_transaction_table
      and    source_transaction_type_id = x_cre_txn_line_rec.source_transaction_type_id;

      debug('  transaction_line_id : '||l_trx_line_id);
    EXCEPTION
      WHEN no_data_found THEN
        csi_t_txn_details_grp.create_transaction_dtls(
          p_api_version              => 1.0,
          p_commit                   => fnd_api.g_false,
          p_init_msg_list            => fnd_api.g_true,
          p_validation_level         => fnd_api.g_valid_level_none,
          px_txn_line_rec            => x_cre_txn_line_rec,
          px_txn_line_detail_tbl     => x_cre_txn_line_dtls_tbl,
          px_txn_party_detail_tbl    => x_cre_txn_party_dtls_tbl,
          px_txn_pty_acct_detail_tbl => x_cre_txn_pty_acct_dtls_tbl,
          px_txn_ii_rltns_tbl        => x_cre_txn_ii_rltns_tbl,
          px_txn_org_assgn_tbl       => x_cre_txn_org_assgn_tbl,
          px_txn_ext_attrib_vals_tbl => x_cre_txn_ext_attb_vals_tbl,
          px_txn_systems_tbl         => x_cre_txn_systems_tbl,
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data);

        l_trx_line_id := x_cre_txn_line_rec.transaction_line_id;

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          raise fnd_api.g_exc_error;
        END IF;

    END ;

    x_trx_line_id := l_trx_line_id;

    csi_utl_pkg.get_qty_ratio(
      p_order_line_qty   => p_order_line_rec.ordered_quantity,
      p_order_item_id    => p_order_line_rec.inv_item_id,
      p_model_remnant_flag => p_order_line_rec.model_remnant_flag, --added for bug5096435
      p_link_to_line_id  => p_order_line_rec.link_to_line_id,
      x_qty_ratio        => l_qty_ratio ,
      x_return_status    => l_return_status );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_error;
    END IF;

    rebuild_shipping_tbl(
      p_qty_ratio               => l_qty_ratio
     ,x_order_shipment_tbl      => x_order_shipment_tbl
     ,x_return_status           => x_return_status );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      debug('rebuild_shipping_tbl failed ');
      raise fnd_api.g_exc_error;
    END IF;



    IF x_order_shipment_tbl.count > 0 THEN
      FOR i in x_order_shipment_tbl.first..x_order_shipment_tbl.last LOOP

        l_instance_id := x_order_shipment_tbl(i).instance_id ;

        BEGIN
          SELECT party_site_id
          INTO   l_party_site_id
          FROM   hz_cust_acct_sites_all c,
                 hz_cust_site_uses_all u
          WHERE  c.cust_acct_site_id = u.cust_acct_site_id
          AND    u.site_use_id = x_order_shipment_tbl(i).ib_current_loc_id; -- ship_to_org_id;
        Exception
          When no_data_found then
            fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
            fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_current_loc_id); -- ship_to_org_id);
            fnd_msg_pub.add;
            debug('Party_site_id not found');
            raise fnd_api.g_exc_error;
          when too_many_rows then
            fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
            fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_current_loc_id); -- ship_to_org_id);
            fnd_msg_pub.add;
            debug('Party_site_id not found');
            raise fnd_api.g_exc_error;
        END ;

        IF x_order_shipment_tbl(i).ib_install_loc is not null
          AND
           x_order_shipment_tbl(i).ib_install_loc_id is not null
          AND
           x_order_shipment_tbl(i).ib_install_loc_id <> fnd_api.g_miss_num
        Then
          BEGIN
            SELECT party_site_id
            INTO   l_install_party_site_id
            FROM   hz_cust_acct_sites_all c,
                   hz_cust_site_uses_all u
            WHERE  c.cust_acct_site_id = u.cust_acct_site_id
            AND    u.site_use_id = x_order_shipment_tbl(i).ib_install_loc_id; -- ship_to_org_id;
          Exception
           When no_data_found then
              fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
              fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_install_loc_id); -- ship_to_org_id);
              fnd_msg_pub.add;
              debug('Party_site_id not found');
              raise fnd_api.g_exc_error;
           when too_many_rows then
              fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
              fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_install_loc_id); -- ship_to_org_id);
              fnd_msg_pub.add;
              debug('Party_site_id not found');
              raise fnd_api.g_exc_error;
          end ;
        END IF;


        -- assign values for the columns in Txn_line_details_tbl
        x_cre_txn_line_dtls_tbl(i).instance_id             := l_instance_id;
        x_cre_txn_line_dtls_tbl(i).sub_type_id             := g_dflt_sub_type_id;
        x_cre_txn_line_dtls_tbl(i).instance_exists_flag    := 'Y';
        x_cre_txn_line_dtls_tbl(i).source_transaction_flag := 'Y';
        x_cre_txn_line_dtls_tbl(i).inventory_item_id       := x_order_shipment_tbl(i).inventory_item_id  ;
        x_cre_txn_line_dtls_tbl(i).inv_organization_id     := x_order_shipment_tbl(i).organization_id  ;
        x_cre_txn_line_dtls_tbl(i).inventory_revision      := x_order_shipment_tbl(i).revision  ;
        x_cre_txn_line_dtls_tbl(i).item_condition_id       := fnd_api.g_miss_num;
        x_cre_txn_line_dtls_tbl(i).instance_type_code      := fnd_api.g_miss_char;
        x_cre_txn_line_dtls_tbl(i).quantity                := x_order_shipment_tbl(i).shipped_quantity  ;
        x_cre_txn_line_dtls_tbl(i).unit_of_measure         := x_order_shipment_tbl(i).transaction_uom ;
        x_cre_txn_line_dtls_tbl(i).serial_number           := x_order_shipment_tbl(i).serial_number;
        x_cre_txn_line_dtls_tbl(i).lot_number              := x_order_shipment_tbl(i).lot_number;
        x_cre_txn_line_dtls_tbl(i).location_type_code      := 'HZ_PARTY_SITES';
        x_cre_txn_line_dtls_tbl(i).location_id             := l_party_site_id;
        -- Added for partner ordering
        x_cre_txn_line_dtls_tbl(i).install_location_type_code := x_cre_txn_line_dtls_tbl(i).location_type_code;
        x_cre_txn_line_dtls_tbl(i).install_location_id     := l_install_party_site_id;
        -- End for Partner Ordering
        x_cre_txn_line_dtls_tbl(i).sellable_flag           := 'Y';
        x_cre_txn_line_dtls_tbl(i).active_start_date       := sysdate;
        x_cre_txn_line_dtls_tbl(i).object_version_number   := 1  ;
        x_cre_txn_line_dtls_tbl(i).preserve_detail_flag    := 'Y';
        x_cre_txn_line_dtls_tbl(i).processing_status       := 'IN_PROCESS';

        IF p_order_line_rec.serial_code <> 1   Then
          x_cre_txn_line_dtls_tbl(i).mfg_serial_number_flag  := 'Y';
        ELSE
          x_cre_txn_line_dtls_tbl(i).mfg_serial_number_flag  := 'N';
        END IF;

        l_inst_party_id := csi_utl_pkg.get_instance_party_id(l_instance_id);

        IF l_inst_party_id = -1 THEN
          raise fnd_api.g_exc_error;
        END IF;

        -- assign values for the columns in txn_party_detail_tbl
        x_cre_txn_party_dtls_tbl(i).instance_party_id      := l_inst_party_id;
        x_cre_txn_party_dtls_tbl(i).party_source_id        := x_order_shipment_tbl(i).party_id;
        x_cre_txn_party_dtls_tbl(i).party_source_table     := 'HZ_PARTIES';
        x_cre_txn_party_dtls_tbl(i).relationship_type_code := 'OWNER';
        x_cre_txn_party_dtls_tbl(i).contact_flag           := 'N';
        x_cre_txn_party_dtls_tbl(i).active_start_date      := sysdate;
        x_cre_txn_party_dtls_tbl(i).preserve_detail_flag   := 'Y';
        x_cre_txn_party_dtls_tbl(i).object_version_number  := 1;
        x_cre_txn_party_dtls_tbl(i).txn_line_details_index := i;

        /* get ip_account_id only if instance_party_id does not exist */

        IF l_inst_party_id is not null THEN
          l_ip_account_id := csi_utl_pkg.get_ip_account_id(l_inst_party_id);
        END IF;

        /* If ip_account_id is -1 then account does not exist in IB */

        IF l_ip_account_id = -1 THEN
          l_ip_account_id := NULL;
        END IF;

        /* assign values for the columns in txn_pty_acct_dtl_tbl */
        x_cre_txn_pty_acct_dtls_tbl(i).ip_account_id          := l_ip_account_id;
        x_cre_txn_pty_acct_dtls_tbl(i).account_id             := x_order_shipment_tbl(i).end_customer_id; -- x_order_shipment_tbl(i).sold_to_org_id;
        x_cre_txn_pty_acct_dtls_tbl(i).bill_to_address_id     := x_order_shipment_tbl(i).invoice_to_org_id;
        x_cre_txn_pty_acct_dtls_tbl(i).ship_to_address_id     := x_order_shipment_tbl(i).ship_to_org_id;
        x_cre_txn_pty_acct_dtls_tbl(i).relationship_type_code := 'OWNER';
        x_cre_txn_pty_acct_dtls_tbl(i).active_start_date      := sysdate;
        x_cre_txn_pty_acct_dtls_tbl(i).preserve_detail_flag   := 'Y';
        x_cre_txn_pty_acct_dtls_tbl(i).object_version_number  := 1;
        x_cre_txn_pty_acct_dtls_tbl(i).txn_party_details_index := i;

        /*assign values for the columns in x_txn_org_assgn_tbl */
        IF nvl(x_order_shipment_tbl(i).sold_from_org_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN
          x_cre_txn_org_assgn_tbl(i).txn_operating_unit_id  := fnd_api.g_miss_num;
          x_cre_txn_org_assgn_tbl(i).txn_line_detail_id     := fnd_api.g_miss_num;
          x_cre_txn_org_assgn_tbl(i).instance_ou_id         := fnd_api.g_miss_num;
          x_cre_txn_org_assgn_tbl(i).operating_unit_id      := x_order_shipment_tbl(i).sold_from_org_id;
          x_cre_txn_org_assgn_tbl(i).relationship_type_code := 'SOLD_FROM';
          x_cre_txn_org_assgn_tbl(i).active_start_date      := sysdate;
          x_cre_txn_org_assgn_tbl(i).preserve_detail_flag   := 'Y';
          x_cre_txn_org_assgn_tbl(i).txn_line_details_index := i;
          x_cre_txn_org_assgn_tbl(i).object_version_number  := 1;
        END IF;

        l_index := i;
        x_txn_line_dtl_rec                     := x_cre_txn_line_dtls_tbl(i);
        x_txn_line_dtl_rec.transaction_line_id := l_trx_line_id;

        debug('  cre_txn_line_dtls_tbl.count     : '||x_cre_txn_line_dtls_tbl.count );
        debug('  cre_txn_party_dtls_tbl.count    : '||x_cre_txn_party_dtls_tbl.count );
        debug('  cre_txn_pty_acct_dtls_tbl.count : '||x_cre_txn_pty_acct_dtls_tbl.count);
        debug('  cre_txn_ii_rltns_tbl.count      : '||x_cre_txn_ii_rltns_tbl.count);
        debug('  cre_txn_org_assgn_tbl.count     : '||x_cre_txn_org_assgn_tbl.count);
        debug('  cre_txn_ext_attb_vals_tbl.count : '||x_cre_txn_ext_attb_vals_tbl.count);
        debug('  cre_txn_systems_tbl.count       : '||x_cre_txn_systems_tbl.count);

        -- call api to create the transaction line details
        csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
          p_api_version               => 1.0 ,
          p_commit                    => fnd_api.g_false,
          p_init_msg_list             => fnd_api.g_true,
          p_validation_level          => fnd_api.g_valid_level_none,
          p_txn_line_dtl_index        => l_index,
          p_txn_line_dtl_rec          => x_txn_line_dtl_rec,
          px_txn_party_dtl_tbl        => x_cre_txn_party_dtls_tbl,
          px_txn_pty_acct_detail_tbl  => x_cre_txn_pty_acct_dtls_tbl,
          px_txn_ii_rltns_tbl         => x_cre_txn_ii_rltns_tbl,
          px_txn_org_assgn_tbl        => x_cre_txn_org_assgn_tbl,
          px_txn_ext_attrib_vals_tbl  => x_cre_txn_ext_attb_vals_tbl,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

        -- assign the txn details in the shipping pl/sql table
        x_order_shipment_tbl(i).txn_dtls_qty   := x_order_shipment_tbl(i).shipped_quantity ;
        x_order_shipment_tbl(i).instance_match := 'Y';
        x_order_shipment_tbl(i).quantity_match := 'Y';

      END LOOP;

      --4483052
      IF p_trackable_parent
      THEN
       debug('Splitting the created installation details in to one each if it is a parent' );
        csi_utl_pkg.create_txn_dtls(
          p_source_trx_id    =>  p_order_line_rec.order_line_id,
          p_source_trx_table =>  'WSH_DELIVERY_DETAILS',
          x_return_status    =>  l_return_status );
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           raise fnd_api.g_exc_error;
         END IF;
      END IF;


    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END process_option_item;

  /*----------------------------------------------------------*/
  /* Procedure name:  rebuild_shipping_tbl                    */
  /* Description : Procedure that splits the shipment into    */
  /* quantity of one if the item type code is config          */
  /*----------------------------------------------------------*/

  PROCEDURE rebuild_shipping_tbl(
    p_qty_ratio               IN NUMBER
   ,x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl
   ,x_return_status           OUT NOCOPY varchar2)
  IS

    l_split_flag     BOOLEAN := FALSE;
    l_instance_id    NUMBER;
    l_ship_quantity  NUMBER;
    x_msg_count      NUMBER;
    x_msg_data       varchar2(2000);
    l_count          NUMBER := 1;
    l_rem_qty        NUMBER ;

    l_order_shipment_tbl  order_shipment_tbl;

  BEGIN

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('rebuild_shipping_tbl');

    l_order_shipment_tbl.delete;

    IF x_order_shipment_tbl.count > 0 THEN
      FOR i in x_order_shipment_tbl.first..x_order_shipment_tbl.last LOOP

        IF x_order_shipment_tbl(i).shipped_quantity > p_qty_ratio THEN

          l_rem_qty     := x_order_shipment_tbl(i).shipped_quantity;
          x_order_shipment_tbl(i).shipped_quantity := p_qty_ratio;
          l_instance_id := x_order_shipment_tbl(i).instance_id;
          l_split_flag  := TRUE;

          WHILE l_split_flag LOOP

            l_rem_qty       := l_rem_qty - p_qty_ratio;

            IF l_rem_qty > p_qty_ratio THEN
              l_split_flag := TRUE;
              l_ship_quantity   :=  p_qty_ratio;
            ELSE
              l_split_flag := FALSE;
              l_ship_quantity   :=  l_rem_qty  ;
            END IF;

            l_order_shipment_tbl(l_count).line_id            :=  x_order_shipment_tbl(i).line_id ;
            l_order_shipment_tbl(l_count).header_id          :=  x_order_shipment_tbl(i).header_id;
            l_order_shipment_tbl(l_count).instance_id        :=  l_instance_id;
            l_order_shipment_tbl(l_count).party_id           :=  x_order_shipment_tbl(i).party_id;
            l_order_shipment_tbl(l_count).party_source_table :=  'HZ_PARTIES';
            l_order_shipment_tbl(l_count).party_account_id   :=  x_order_shipment_tbl(i).end_customer_id; -- x_order_shipment_tbl(i).sold_to_org_id;
            l_order_shipment_tbl(l_count).inst_obj_version_number :=  x_order_shipment_tbl(i).inst_obj_version_number;
            l_order_shipment_tbl(l_count).inventory_item_id  :=  x_order_shipment_tbl(i).inventory_item_id ;
            l_order_shipment_tbl(l_count).organization_id    :=  x_order_shipment_tbl(i).organization_id ;
            l_order_shipment_tbl(l_count).revision           :=  x_order_shipment_tbl(i).revision;
            l_order_shipment_tbl(l_count).subinventory       :=  x_order_shipment_tbl(i).subinventory ;
            l_order_shipment_tbl(l_count).locator_id         :=  x_order_shipment_tbl(i).locator_id ;
            l_order_shipment_tbl(l_count).lot_number         :=  x_order_shipment_tbl(i).lot_number ;
            l_order_shipment_tbl(l_count).serial_number      :=  x_order_shipment_tbl(i).serial_number  ;
            l_order_shipment_tbl(l_count).transaction_uom    :=  x_order_shipment_tbl(i).transaction_uom  ;
            l_order_shipment_tbl(l_count).order_quantity_uom :=  x_order_shipment_tbl(i).order_quantity_uom  ;
            l_order_shipment_tbl(l_count).invoice_to_contact_id  := x_order_shipment_tbl(i).invoice_to_contact_id ;
            l_order_shipment_tbl(l_count).invoice_to_org_id  :=  x_order_shipment_tbl(i).invoice_to_org_id;
            l_order_shipment_tbl(l_count).line_type_id       :=  x_order_shipment_tbl(i).line_type_id  ;
            l_order_shipment_tbl(l_count).ordered_quantity   :=  x_order_shipment_tbl(i).ordered_quantity;
            l_order_shipment_tbl(l_count).ord_line_shipped_qty  :=  x_order_shipment_tbl(i).ord_line_shipped_qty;
            l_order_shipment_tbl(l_count).ship_to_contact_id :=  x_order_shipment_tbl(i).ship_to_contact_id;
            l_order_shipment_tbl(l_count).ship_to_org_id     :=  x_order_shipment_tbl(i).ship_to_org_id  ;
            l_order_shipment_tbl(l_count).ship_from_org_id   :=  x_order_shipment_tbl(i).ship_from_org_id ;
            l_order_shipment_tbl(l_count).sold_to_org_id     :=  x_order_shipment_tbl(i).sold_to_org_id  ;
            l_order_shipment_tbl(l_count).sold_from_org_id   :=  x_order_shipment_tbl(i).sold_from_org_id ;
            l_order_shipment_tbl(l_count).source_line_id     :=  x_order_shipment_tbl(i).source_line_id ;
            l_order_shipment_tbl(l_count).transaction_type_id :=  x_order_shipment_tbl(i).transaction_type_id ;
            l_order_shipment_tbl(l_count).customer_id        :=  x_order_shipment_tbl(i).end_customer_id; -- x_order_shipment_tbl(i).customer_id ;
            l_order_shipment_tbl(l_count).transaction_date   :=  x_order_shipment_tbl(i).transaction_date ;
            l_order_shipment_tbl(l_count).item_type_code     :=  x_order_shipment_tbl(i).item_type_code ;
            l_order_shipment_tbl(l_count).cust_po_number     :=  x_order_shipment_tbl(i).cust_po_number ;
            l_order_shipment_tbl(l_count).ato_line_id        :=  x_order_shipment_tbl(i).ato_line_id ;
            l_order_shipment_tbl(l_count).top_model_line_id  :=  x_order_shipment_tbl(i).top_model_line_id ;
            l_order_shipment_tbl(l_count).link_to_line_id    :=  x_order_shipment_tbl(i).link_to_line_id ;
            l_order_shipment_tbl(l_count).shipped_quantity   :=  l_ship_quantity ;
            -- Added for partner ordering
            l_order_shipment_tbl(l_count).ib_install_loc     :=  x_order_shipment_tbl(i).ib_install_loc;
            l_order_shipment_tbl(l_count).ib_install_loc_id  :=  x_order_shipment_tbl(i).ib_install_loc_id;
            l_order_shipment_tbl(l_count).ib_current_loc     :=  x_order_shipment_tbl(i).ib_current_loc;
            l_order_shipment_tbl(l_count).ib_current_loc_id  :=  x_order_shipment_tbl(i).ib_current_loc_id;
            -- Begin fix for Bug 3435269
            l_order_shipment_tbl(l_count).end_customer_id    :=  x_order_shipment_tbl(i).end_customer_id;
            -- End fix for 3435269
            -- End for partner ordering
            l_count := l_count +1 ;

          END LOOP; -- end of while loop

        END IF;
      END LOOP; -- end of for loop
    END IF; -- end if for x_order_shipment_tbl > 0

    debug('l_order_shipment_tbl.count ='||l_order_shipment_tbl.count );

    IF l_order_shipment_tbl.count > 0 THEN
      FOR i in l_order_shipment_tbl.first..l_order_shipment_tbl.last LOOP
        x_order_shipment_tbl(x_order_shipment_tbl.count + 1) := l_order_shipment_tbl(i);
      END LOOP;
    END IF;

    debug('x_order_shipment_tbl.count ='||x_order_shipment_tbl.count );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END rebuild_shipping_tbl;

  /*----------------------------------------------------------*/
  /* Procedure name :DECODE_MESSAGE                           */
  /* Description    :Procedure used to decode the messages    */
  /*----------------------------------------------------------*/

  PROCEDURE decode_message(
    p_msg_header      IN  XNP_MESSAGE.MSG_HEADER_REC_TYPE,
    p_msg_text        IN  varchar2,
    x_return_status   OUT NOCOPY varchar2,
    x_error_message   OUT NOCOPY varchar2,
    x_mtl_trx_rec     OUT NOCOPY MTL_TXN_REC)
  IS

    l_api_name            varchar2(100) := 'csi_order_ship_pub.decode_message';
    l_fnd_unexpected      varchar2(1)   := fnd_api.g_ret_sts_unexp_error;
    l_mtl_txn_id          number;
    l_return_status       varchar2(1)   := fnd_api.g_ret_sts_success;

  BEGIN

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     api_log('decode_message');

     xnp_xml_utils.decode(P_Msg_Text, 'MTL_TRANSACTION_ID', l_mtl_txn_id);

     IF (l_mtl_txn_id is NULL) or
        (l_mtl_txn_id = fnd_api.g_miss_num) THEN
       raise fnd_api.g_exc_error;
     END IF;

     csi_utl_pkg.get_source_trx_dtls(
       p_mtl_transaction_id => l_mtl_txn_id,
       x_mtl_txn_rec        => X_MTL_TRX_REC,
       x_error_message      => x_error_message,
       x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      fnd_message.set_name('CSI','CSI_DECODE_MGS_ERROR');
      fnd_message.set_token('message_id',p_msg_header.message_id);
      fnd_message.set_token('MESSAGE_CODE',p_msg_header.message_code);
      fnd_msg_pub.add;
      x_error_message := fnd_msg_pub.get;
      x_return_status := l_fnd_unexpected;

    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      fnd_msg_pub.add;
      x_error_message := fnd_msg_pub.get;
      x_return_status := l_fnd_unexpected;
  END decode_message;

  PROCEDURE oke_shipment(
    p_mtl_txn_id       IN  number,
    x_return_status    OUT NOCOPY varchar2,
    px_trx_error_rec   IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec)
  IS

    l_oke_source_table      varchar2(30) := csi_interface_pkg.g_oke_source_table;

    l_inventory_item_id     number;
    l_organization_id       number;
    l_source_line_id        number;
    l_source_quantity       number;
    l_mtl_txn_tbl           csi_interface_pkg.mtl_txn_tbl;
    l_item_attrib_rec       csi_interface_pkg.item_attributes_rec;

    l_source_header_rec     csi_interface_pkg.source_header_rec;
    l_source_line_rec       csi_interface_pkg.source_line_rec;

    l_csi_txn_rec           csi_datastructures_pub.transaction_rec;

    l_txn_line_rec          csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_detail_tbl   csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_party_acct_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_eav_tbl           csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl       csi_t_datastructures_grp.txn_systems_tbl;

    l_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_return_message        varchar2(2000);
    l_msg_count             number;
    l_msg_data              varchar2(2000);

    l_error_rec             csi_datastructures_pub.transaction_error_rec;

  BEGIN

    savepoint oke_shipment;

    x_return_status := fnd_api.g_ret_sts_success;
    l_error_rec     := px_trx_error_rec;

    /* builds the debug file name */
    csi_t_gen_utility_pvt.build_file_name (
      p_file_segment1 => 'csiokshp',
      p_file_segment2 => p_mtl_txn_id);

    api_log('oke_shipment');

    debug('  Transaction Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type :Sales Order Shipment');
    debug('  Transaction ID   :'||p_mtl_txn_id);

    l_error_rec.source_id     := p_mtl_txn_id;

    /* this routine checks if ib is active */
    csi_utility_grp.check_ib_active;

    SELECT inventory_item_id,
           organization_id,
           picking_line_id,
           abs(primary_quantity)
    INTO   l_inventory_item_id,
           l_organization_id,
           l_source_line_id,
           l_source_quantity
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_mtl_txn_id;

    csi_interface_pkg.get_source_info(
      p_source_table         => l_oke_source_table,
      p_source_id            => l_source_line_id,
      x_source_header_rec    => l_source_header_rec,
      x_source_line_rec      => l_source_line_rec,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.source_header_ref    := l_source_header_rec.source_header_ref;
    l_error_rec.source_header_ref_id := l_source_header_rec.source_header_id;
    l_error_rec.source_line_ref      := l_source_line_rec.source_line_ref;
    l_error_rec.source_line_ref_id   := l_source_line_rec.source_line_id;

    l_source_line_rec.source_quantity  := l_source_quantity;
    l_source_line_rec.shipped_quantity := l_source_quantity;

    csi_interface_pkg.get_item_attributes(
      p_inventory_item_id  => l_inventory_item_id,
      p_organization_id    => l_organization_id,
      x_item_attrib_rec    => l_item_attrib_rec,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_error_rec.inventory_item_id        := l_inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_item_attrib_rec.serial_control_code;
    l_error_rec.src_lot_ctrl_code        := l_item_attrib_rec.lot_control_code;
    l_error_rec.src_location_ctrl_code   := l_item_attrib_rec.locator_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_item_attrib_rec.revision_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_item_attrib_rec.ib_trackable_flag;

    l_source_line_rec.uom_code := l_item_attrib_rec.primary_uom_code;

    csi_interface_pkg.get_mtl_txn_tbl(
      p_mtl_txn_id    => p_mtl_txn_id,
      x_mtl_txn_tbl   => l_mtl_txn_tbl,
      x_return_status => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_mtl_txn_tbl.count > 0 THEN

      -- create csi_txn_rec

      l_csi_txn_rec.transaction_id := fnd_api.g_miss_num;
      l_csi_txn_rec.source_header_ref_id        := l_source_header_rec.source_header_id;
      l_csi_txn_rec.source_header_ref           := l_source_header_rec.source_header_ref;
      l_csi_txn_rec.source_line_ref_id          := l_source_line_rec.source_line_id;
      l_csi_txn_rec.source_line_ref             := l_source_line_rec.source_line_ref;
      l_csi_txn_rec.inv_material_transaction_id := p_mtl_txn_id;
      l_csi_txn_rec.transaction_type_id         := 326;
      l_csi_txn_rec.transaction_date            := sysdate;
      l_csi_txn_rec.source_transaction_date     := l_mtl_txn_tbl(1).transaction_date;
      l_csi_txn_rec.transaction_quantity        := l_source_line_rec.shipped_quantity;
      l_csi_txn_rec.transaction_status_code     := 'PENDING';

      csi_transactions_pvt.create_transaction(
        p_api_version            => 1.0,
        p_commit                 => fnd_api.g_false,
        p_init_msg_list          => fnd_api.g_true,
        p_validation_level       => fnd_api.g_valid_level_full,
        p_success_if_exists_flag => 'Y',
        p_transaction_rec        => l_csi_txn_rec,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);

      csi_interface_pkg.pre_process_mtl_txn_tbl(
        p_item_attrib_rec => l_item_attrib_rec,
        px_mtl_txn_tbl    => l_mtl_txn_tbl,
        x_return_status   => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      csi_interface_pkg.get_inventory_instances(
        p_item_attrib_rec => l_item_attrib_rec,
        px_mtl_txn_tbl    => l_mtl_txn_tbl,
        x_return_status   => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- decrement source instances
      csi_interface_pkg.decrement_inventory_instances(
        p_item_attrib_rec => l_item_attrib_rec,
        p_mtl_txn_tbl     => l_mtl_txn_tbl,
        px_txn_rec        => l_csi_txn_rec,
        x_return_status   => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_item_attrib_rec.serial_control_code = 6 THEN
        IF l_mtl_txn_tbl.count > 0 THEN
          FOR ret_ind IN l_mtl_txn_tbl.FIRST .. l_mtl_txn_tbl.LAST
          LOOP
            BEGIN
              SELECT instance_id
              INTO   l_mtl_txn_tbl(ret_ind).instance_id
              FROM   csi_item_instances
              WHERE  inventory_item_id = l_mtl_txn_tbl(ret_ind).inventory_item_id
              AND    serial_number     = l_mtl_txn_tbl(ret_ind).serial_number
              AND    instance_usage_code = 'RETURNED';
            EXCEPTION
              WHEN no_data_found THEN
                l_mtl_txn_tbl(ret_ind).instance_id := fnd_api.g_miss_num;
            END;
          END LOOP;
        END IF;
      END IF;

      csi_interface_pkg.build_default_txn_detail(
        p_source_table         => l_oke_source_table,
        p_source_id            => l_source_line_id,
        p_source_header_rec    => l_source_header_rec,
        p_source_line_rec      => l_source_line_rec,
        p_csi_txn_rec          => l_csi_txn_rec,
        px_txn_line_rec        => l_txn_line_rec,--Modified to IN OUT param for bug 5194812
        x_txn_line_detail_tbl  => l_txn_line_detail_tbl,
        x_txn_party_tbl        => l_txn_party_tbl,
        x_txn_party_acct_tbl   => l_txn_party_acct_tbl,
        x_txn_org_assgn_tbl    => l_txn_org_assgn_tbl,
        x_pricing_attribs_tbl  => l_pricing_attribs_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- match transaction detail with material transaction
      csi_interface_pkg.sync_txn_dtl_and_mtl_txn(
        p_mtl_txn_tbl         => l_mtl_txn_tbl,
        p_item_attrib_rec     => l_item_attrib_rec,
        px_txn_line_dtl_tbl   => l_txn_line_detail_tbl,
        px_txn_party_dtl_tbl  => l_txn_party_tbl,
        px_txn_party_acct_tbl => l_txn_party_acct_tbl,
        px_txn_org_assgn_tbl  => l_txn_org_assgn_tbl,
        px_txn_eav_tbl        => l_txn_eav_tbl,
        px_txn_ii_rltns_tbl   => l_txn_ii_rltns_tbl,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- ##**##-- comment this line later.
      l_source_line_rec.fulfilled_date := sysdate;

      csi_interface_pkg.interface_ib(
        p_source_header_rec    => l_source_header_rec,
        p_source_line_rec      => l_source_line_rec,
        px_csi_txn_rec         => l_csi_txn_rec,
        px_txn_line_rec        => l_txn_line_rec,
        px_txn_line_dtl_tbl    => l_txn_line_detail_tbl,
        px_txn_party_tbl       => l_txn_party_tbl,
        px_txn_party_acct_tbl  => l_txn_party_acct_tbl,
        px_txn_org_assgn_tbl   => l_txn_org_assgn_tbl,
        px_txn_eav_tbl         => l_txn_eav_tbl,
        px_txn_ii_rltns_tbl    => l_txn_ii_rltns_tbl,
        px_pricing_attribs_tbl => l_pricing_attribs_tbl,
        x_return_status        => l_return_status,
        x_return_message       => l_return_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE
      null;
      -- no material transaction records. error to be set
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to oke_shipment;
      x_return_status        := fnd_api.g_ret_sts_error;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      debug('Error(E) :'||l_error_rec.error_text);
    WHEN others THEN
      rollback to oke_shipment;
      fnd_message.set_name ('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', 'OTHERS Error :'||substr(sqlerrm, 1, 540));
      fnd_msg_pub.add;
      x_return_status        := fnd_api.g_ret_sts_error;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      px_trx_error_rec       := l_error_rec;
      debug('Error(O) :'||l_error_rec.error_text);
  END oke_shipment;

END csi_order_ship_pub ;

/
