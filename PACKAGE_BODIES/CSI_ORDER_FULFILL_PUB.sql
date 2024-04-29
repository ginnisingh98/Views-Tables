--------------------------------------------------------
--  DDL for Package Body CSI_ORDER_FULFILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ORDER_FULFILL_PUB" AS
/* $Header: csipiofb.pls 120.25.12010000.3 2009/09/17 20:33:32 devijay ship $*/

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => p_api_name,
      p_pkg_name => 'csi_order_fulfill_pub');
  END api_log;

  PROCEDURE create_csi_transaction(
    px_csi_txn_rec   IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status     OUT nocopy varchar2)
  IS
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count           number;
    l_msg_data            varchar2(2000);

  BEGIN

    x_return_status       := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'create_transaction',
      p_pkg_name => 'csi_transactions_pvt');

    csi_transactions_pvt.create_transaction(
      p_api_version            => 1.0,
      p_commit                 => fnd_api.g_false,
      p_init_msg_list          => fnd_api.g_true,
      p_validation_level       => fnd_api.g_valid_level_full,
      p_success_if_exists_flag => 'Y',
      p_transaction_rec        => px_csi_txn_rec,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  csi_transaction_id : '||px_csi_txn_rec.transaction_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_csi_transaction;

  PROCEDURE get_sub_type_rec(
    p_transaction_type_id IN  number,
    p_sub_type_id         IN  number,
    x_sub_type_rec        OUT NOCOPY sub_type_rec,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_sub_type_rec  sub_type_rec;
  BEGIN
    api_log('get_sub_type_rec');
    x_return_status  := fnd_api.g_ret_sts_success;

    l_sub_type_rec.transaction_type_id := p_transaction_type_id;
    l_sub_type_rec.sub_type_id         := p_sub_type_id;

    BEGIN
      SELECT nvl(src_change_owner, 'N'),
             src_change_owner_to_code,
             src_status_id,
             nvl(src_reference_reqd, 'N'),
             nvl(src_return_reqd,'N'),
             nvl(non_src_change_owner, 'N'),
             non_src_change_owner_to_code,
             non_src_status_id,
             nvl(non_src_reference_reqd,'N'),
             nvl(non_src_return_reqd,'N')
      INTO   l_sub_type_rec.src_change_owner,
             l_sub_type_rec.src_change_owner_code,
             l_sub_type_rec.src_status_id,
             l_sub_type_rec.src_reference_reqd,
             l_sub_type_rec.src_return_reqd,
             l_sub_type_rec.nsrc_change_owner,
             l_sub_type_rec.nsrc_change_owner_code,
             l_sub_type_rec.nsrc_status_id,
             l_sub_type_rec.nsrc_reference_reqd,
             l_sub_type_rec.nsrc_return_reqd
      FROM   csi_ib_txn_types
      WHERE  sub_type_id = p_sub_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_SUB_TYPE_REC_MISSING');
        fnd_message.set_token('SUB_TYPE_ID', p_sub_type_id);
        fnd_message.set_token('TRANSACTION_TYPE_ID', p_transaction_type_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;
    x_sub_type_rec := l_sub_type_rec;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_sub_type_rec;


  -- added for the bug 5464761
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


-- added for the bug 5464761
 PROCEDURE check_and_explode_bom
  ( p_order_line_rec   IN               oe_order_lines_all%rowtype,
    l_u_instance_rec   IN OUT   NOCOPY  csi_datastructures_pub.instance_rec,
   px_csi_txn_rec      IN OUT   NOCOPY  csi_datastructures_pub.transaction_rec,
   x_return_status     OUT      NOCOPY  varchar2)

   IS

     l_cps_tbl                  csi_order_ship_pub.customer_products_tbl;
    l_cp_ind                   binary_integer := 0;
    l_ind                    binary_integer := 0;
    l_all_cps_tbl              csi_order_ship_pub.customer_products_tbl;
    l_single_cps_tbl           csi_order_ship_pub.customer_products_tbl;
    l_acp_ind                  binary_integer := 0;
     l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
     l_msg_count                number;
    l_msg_data                 varchar2(2000);



-- explode_bom variables
    l_bom_ind                  binary_integer := 0;
    l_bom_std_item_rec         csi_datastructures_pub.instance_rec;
    l_bom_std_item_tbl         csi_datastructures_pub.instance_tbl;
    l_bom_explode_flag         BOOLEAN := FALSE;
    l_split_flag               varchar2(10);
    l_auto_split_instances       csi_datastructures_pub.instance_tbl;
    l_ship_order_line_rec        csi_order_ship_pub.order_line_rec;
    l_order_line_rec           oe_order_lines_all%rowtype;


   begin

	debug('Instance id' ||l_u_instance_rec.instance_id);
	debug('Order Line Id ' ||p_order_line_rec.line_id);


		/* This is done to get the quantity and inventory item id for explosion and auto split */
		SELECT  quantity,
		        inventory_item_id
		INTO   l_u_instance_rec.quantity,
                        l_u_instance_rec.inventory_item_id
	        FROM   csi_item_instances
	        WHERE  instance_id = l_u_instance_rec.instance_id;



	l_split_flag := nvl(fnd_profile.value('CSI_AUTO_SPLIT_INSTANCE' ),'N');
        debug('  profile_auto_split : '||l_split_flag);

         l_order_line_rec   := p_order_line_rec;
	 l_cp_ind := 0;
	 l_cps_tbl.delete;

                     debug('  l_cps_tbl(l_cp_ind).quantity   : '||l_u_instance_rec.quantity);
		    l_cp_ind := l_cp_ind + 1;
		    l_cps_tbl(l_cp_ind).instance_id        := l_u_instance_rec.instance_id;
		    l_cps_tbl(l_cp_ind).quantity           := l_u_instance_rec.quantity;
		    l_cps_tbl(l_cp_ind).txn_line_detail_id := l_u_instance_rec.last_txn_line_detail_id;
		    l_cps_tbl(l_cp_ind).line_id            := l_u_instance_rec.last_oe_order_line_id;
		    l_cps_tbl(l_cp_ind).transaction_id     := px_csi_txn_rec.transaction_id;
		    l_cps_tbl(l_cp_ind).serial_number      := l_u_instance_rec.serial_number;



	     BEGIN

	     DEBUG('Ship From Org ID '||l_order_line_rec.ship_from_org_id);

	     SELECT  serial_number_control_code,
		     Inventory_item_id,
		     organization_id,
		     bom_item_type
	     INTO     l_ship_order_line_rec.serial_code,
		     l_ship_order_line_rec.inv_item_id ,
		     l_ship_order_line_rec.inv_org_id,
		     l_ship_order_line_rec.bom_item_type
	     FROM   mtl_system_items
	     WHERE  inventory_item_id = l_u_instance_rec.inventory_item_id
	     AND    organization_id   = l_order_line_rec.ship_from_org_id;

	     EXCEPTION
	       WHEN OTHERS THEN
	       null;
	     END;


	       IF l_u_instance_rec.quantity > 1
		   AND
		   l_split_flag  = 'Y'
		   AND
		   l_ship_order_line_rec.serial_code = 1
		THEN

        	  l_auto_split_instances.delete;

        	auto_split_instances(
		    p_instance_rec  => l_u_instance_rec,
		    px_txn_rec      => px_csi_txn_rec,
		    x_instance_tbl  => l_auto_split_instances,
		    x_return_status => l_return_status);

		  IF l_return_status <> fnd_api.g_ret_sts_success THEN
		    RAISE fnd_api.g_exc_error;
		  END IF;
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
						l_u_instance_rec.last_txn_line_detail_id;
		      l_cps_tbl(l_cp_ind).line_id            :=
						l_u_instance_rec.last_oe_order_line_id;
		      l_cps_tbl(l_cp_ind).transaction_id     := px_csi_txn_rec.transaction_id;

		     END LOOP;
	    END IF;

	         IF l_cps_tbl.COUNT > 0 THEN
		    FOR r_cp_ind IN l_cps_tbl.FIRST .. l_cps_tbl.LAST
		    LOOP

		      l_acp_ind := l_acp_ind + 1;
		      l_all_cps_tbl(l_acp_ind) := l_cps_tbl(r_cp_ind);
		    END LOOP;
		 END IF;

		DEBUG('customer products :'||l_all_cps_tbl.COUNT);



		 --getting single quantity instances
	    IF l_all_cps_tbl.COUNT > 0 THEN
	    l_ind :=0;

	      FOR p_ind IN l_all_cps_tbl.FIRST .. l_all_cps_tbl.LAST
	      LOOP

		IF l_all_cps_tbl(p_ind).quantity = 1 THEN
		  l_ind := l_ind + 1;
		  l_single_cps_tbl(l_ind) := l_all_cps_tbl(p_ind);
		END IF;
	      END LOOP;
	    END IF; --end of getting single quantity instances


	     DEBUG('Single Quantity Instances Table Count'|| l_single_cps_tbl.count);

	    IF l_single_cps_tbl.count > 0 THEN

		  l_bom_explode_flag := csi_utl_pkg.check_standard_bom(
					  p_order_line_rec  => l_ship_order_line_rec);

		  IF l_bom_explode_flag THEN

		    FOR l_scp_ind IN l_single_cps_tbl.FIRST .. l_single_cps_tbl.LAST
		    LOOP

                      IF NOT(csi_utl_pkg.wip_config_exists(l_single_cps_tbl(l_scp_ind).instance_id)) THEN

			l_bom_std_item_rec.instance_id         := l_single_cps_tbl(l_scp_ind).instance_id ;
			l_bom_std_item_rec.inventory_item_id   := l_ship_order_line_rec.inv_item_id ;
			l_bom_std_item_rec.vld_organization_id := l_ship_order_line_rec.inv_org_id ;
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
			p_txn_rec             => px_csi_txn_rec,
			x_return_status       => l_return_status,
			x_msg_count           => l_msg_count,
			x_msg_data            => l_msg_data);

		      IF l_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE fnd_api.g_exc_error;
		      END IF;

		      debug('explode bom end time   :'||to_char(sysdate, 'hh24:mi:ss'));
	  END IF;
	  END IF; --bom explode flag
	 END IF;  --l_single_cps_tbl.count


   END check_and_explode_bom;


  PROCEDURE create_dflt_txn_dtls(
    p_order_line_rec    IN     oe_order_lines_all%rowtype,
    px_default_info_rec IN OUT nocopy default_info_rec,
    x_txn_line_rec         OUT nocopy csi_t_datastructures_grp.txn_line_rec,
    x_tld_tbl              OUT nocopy csi_t_datastructures_grp.txn_line_detail_tbl,
    x_tiir_tbl             OUT nocopy csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status        OUT nocopy varchar2)
  IS

    c_tl_rec            csi_t_datastructures_grp.txn_line_rec;
    c_tld_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    c_tpd_tbl           csi_t_datastructures_grp.txn_party_detail_tbl;
    c_tpa_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    c_iir_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;
    c_oa_tbl            csi_t_datastructures_grp.txn_org_assgn_tbl;
    c_ea_tbl            csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    c_ts_tbl            csi_t_datastructures_grp.txn_systems_tbl;

    l_loop_count        number := 1;
    l_quantity          number;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(4000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('create_dflt_txn_dtls');

    c_tl_rec.source_transaction_type_id := 51;
    c_tl_rec.source_transaction_table   := 'OE_ORDER_LINES_ALL';
    c_tl_rec.source_transaction_id      := p_order_line_rec.line_id;

    l_loop_count := 1;
    l_quantity   := p_order_line_rec.ordered_quantity;

    IF px_default_info_rec.split_flag = 'Y' THEN
      IF px_default_info_rec.ratio_split_flag = 'Y' THEN
        l_loop_count := p_order_line_rec.ordered_quantity/px_default_info_rec.split_ratio;
        l_quantity   := px_default_info_rec.split_ratio;
      ELSE
        l_loop_count := p_order_line_rec.ordered_quantity;
        l_quantity   := 1;
      END IF;
    ELSE
      l_loop_count := 1;
      l_quantity   := p_order_line_rec.ordered_quantity;
    END IF;

    FOR l_ind IN 1..l_loop_count
    LOOP

      c_tld_tbl(l_ind).sub_type_id             := px_default_info_rec.sub_type_id;
      c_tld_tbl(l_ind).instance_exists_flag    := 'N';
      c_tld_tbl(l_ind).source_transaction_flag := 'Y';
      c_tld_tbl(l_ind).inventory_item_id       := p_order_line_rec.inventory_item_id;
      c_tld_tbl(l_ind).inventory_revision      := p_order_line_rec.item_revision;
      c_tld_tbl(l_ind).inv_organization_id     := px_default_info_rec.om_vld_org_id;
      c_tld_tbl(l_ind).quantity                := l_quantity;
      c_tld_tbl(l_ind).unit_of_measure         := p_order_line_rec.order_quantity_uom;
      c_tld_tbl(l_ind).processing_status       := 'IN_PROCESS';

      IF nvl(px_default_info_rec.current_party_site_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        c_tld_tbl(l_ind).location_type_code    := 'HZ_PARTY_SITES';
        c_tld_tbl(l_ind).location_id           := px_default_info_rec.current_party_site_id;
      END IF;

      IF nvl(px_default_info_rec.install_party_site_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        c_tld_tbl(l_ind).install_location_type_code := 'HZ_PARTY_SITES';
        c_tld_tbl(l_ind).install_location_id        := px_default_info_rec.install_party_site_id;
      END IF;

      -- party details
      c_tpd_tbl(l_ind).party_source_table       := 'HZ_PARTIES';
      c_tpd_tbl(l_ind).relationship_type_code   := 'OWNER';
      c_tpd_tbl(l_ind).preserve_detail_flag     := 'Y';
      c_tpd_tbl(l_ind).txn_line_details_index   := l_ind;
      c_tpd_tbl(l_ind).contact_flag             := 'N';

      IF px_default_info_rec.src_change_owner = 'Y' THEN
        c_tpd_tbl(l_ind).party_source_id         := px_default_info_rec.owner_party_id;
        -- party account details
        c_tpa_tbl(l_ind).account_id              := px_default_info_rec.owner_party_acct_id;
        c_tpa_tbl(l_ind).bill_to_address_id      := p_order_line_rec.invoice_to_org_id;
        c_tpa_tbl(l_ind).ship_to_address_id      := p_order_line_rec.ship_to_org_id;
        c_tpa_tbl(l_ind).relationship_type_code  := 'OWNER';
        c_tpa_tbl(l_ind).preserve_detail_flag    := 'Y';
        c_tpa_tbl(l_ind).txn_party_details_index := l_ind;
      ELSE
        c_tpd_tbl(l_ind).party_source_id         := px_default_info_rec.internal_party_id;
      END IF;

      IF nvl(p_order_line_rec.sold_from_org_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        c_oa_tbl(l_ind).operating_unit_id      := p_order_line_rec.sold_from_org_id;
        c_oa_tbl(l_ind).relationship_type_code := 'SOLD_FROM';
        c_oa_tbl(l_ind).preserve_detail_flag   := 'Y';
        c_oa_tbl(l_ind).txn_line_details_index := l_ind;
      END IF;

    END LOOP;

    csi_t_txn_details_grp.create_transaction_dtls(
      p_api_version              => 1.0,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => fnd_api.g_true,
      p_validation_level         => fnd_api.g_valid_level_full,
      px_txn_line_rec            => c_tl_rec,
      px_txn_line_detail_tbl     => c_tld_tbl,
      px_txn_party_detail_tbl    => c_tpd_tbl,
      px_txn_pty_acct_detail_tbl => c_tpa_tbl,
      px_txn_ii_rltns_tbl        => c_iir_tbl,
      px_txn_org_assgn_tbl       => c_oa_tbl,
      px_txn_ext_attrib_vals_tbl => c_ea_tbl,
      px_txn_systems_tbl         => c_ts_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_txn_line_rec := c_tl_rec;
    x_tld_tbl      := c_tld_tbl;
    x_tiir_tbl     := c_iir_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_dflt_txn_dtls;

  PROCEDURE get_parent_txn_line_status (
    p_parent_line_id      IN  number,
    x_processing_status   OUT NOCOPY varchar2)
  IS
    l_processing_status   varchar2(30) := 'SUBMIT';
  BEGIN

    BEGIN

      SELECT processing_status
      INTO   l_processing_status
      FROM   csi_t_transaction_lines
      WHERE  source_transaction_table = 'OE_ORDER_LINES_ALL'
      AND    source_transaction_id    = p_parent_line_id;

    EXCEPTION
      WHEN no_data_found  THEN
        l_processing_status := 'SUBMIT';
    END;

    x_processing_status := l_processing_status;
  EXCEPTION
    WHEN others THEN
      x_processing_status := l_processing_status;
  END get_parent_txn_line_status;

  /* -------------------------------------------------------------------- */
  /* This routine converts the instance header table to instance table .  */
  /* We need to do this because the get_item_instances returns the header */
  /* table and we operate on the instance table.                          */
  /* -------------------------------------------------------------------- */
  PROCEDURE make_non_header_rec(
    p_instance_header_rec IN  csi_datastructures_pub.instance_header_rec,
    x_instance_rec        OUT NOCOPY csi_datastructures_pub.instance_rec,
    x_return_status       OUT NOCOPY varchar2)
  IS
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    x_instance_rec.instance_id                := p_instance_header_rec.instance_id;
    x_instance_rec.instance_number            := p_instance_header_rec.instance_number;
    x_instance_rec.external_reference         := p_instance_header_rec.external_reference;
    x_instance_rec.inventory_item_id          := p_instance_header_rec.inventory_item_id;
    x_instance_rec.inventory_revision         := p_instance_header_rec.inventory_revision;
    x_instance_rec.inv_master_organization_id := p_instance_header_rec.inv_master_organization_id;
    x_instance_rec.serial_number              := p_instance_header_rec.serial_number;
    x_instance_rec.mfg_serial_number_flag     := p_instance_header_rec.mfg_serial_number_flag;
    x_instance_rec.lot_number                 := p_instance_header_rec.lot_number;
    x_instance_rec.quantity                   := p_instance_header_rec.quantity;
    x_instance_rec.unit_of_measure            := p_instance_header_rec.unit_of_measure;
    x_instance_rec.accounting_class_code      := p_instance_header_rec.accounting_class_code;
    x_instance_rec.instance_condition_id      := p_instance_header_rec.instance_condition_id;
    x_instance_rec.instance_usage_code        := p_instance_header_rec.instance_usage_code;
    x_instance_rec.instance_status_id         := p_instance_header_rec.instance_status_id;
    x_instance_rec.customer_view_flag         := p_instance_header_rec.customer_view_flag;
    x_instance_rec.merchant_view_flag         := p_instance_header_rec.merchant_view_flag;
    x_instance_rec.sellable_flag              := p_instance_header_rec.sellable_flag;
    x_instance_rec.system_id                  := p_instance_header_rec.system_id;
    x_instance_rec.instance_type_code         := p_instance_header_rec.instance_type_code;
    x_instance_rec.active_start_date          := p_instance_header_rec.active_start_date;
    x_instance_rec.active_end_date            := p_instance_header_rec.active_end_date;
    x_instance_rec.location_type_code         := p_instance_header_rec.location_type_code;
    x_instance_rec.location_id                := p_instance_header_rec.location_id;
    -- Added for partner ordering
    x_instance_rec.install_location_type_code := p_instance_header_rec.install_location_type_code;
    x_instance_rec.install_location_id        := p_instance_header_rec.install_location_id;
    -- Added for partner ordering
    x_instance_rec.inv_organization_id        := p_instance_header_rec.inv_organization_id;
    x_instance_rec.inv_subinventory_name      := p_instance_header_rec.inv_subinventory_name;
    x_instance_rec.inv_locator_id             := p_instance_header_rec.inv_locator_id;
    x_instance_rec.pa_project_id              := p_instance_header_rec.pa_project_id;
    x_instance_rec.pa_project_task_id         := p_instance_header_rec.pa_project_task_id;
    x_instance_rec.in_transit_order_line_id   := p_instance_header_rec.in_transit_order_line_id;
    x_instance_rec.wip_job_id                 := p_instance_header_rec.wip_job_id;
    x_instance_rec.po_order_line_id           := p_instance_header_rec.po_order_line_id;
    x_instance_rec.last_oe_order_line_id      := p_instance_header_rec.last_oe_order_line_id;
    x_instance_rec.last_oe_rma_line_id        := p_instance_header_rec.last_oe_rma_line_id;
    x_instance_rec.last_po_po_line_id         := p_instance_header_rec.last_po_po_line_id;
    x_instance_rec.last_oe_po_number          := p_instance_header_rec.last_oe_po_number;
    x_instance_rec.last_wip_job_id            := p_instance_header_rec.last_wip_job_id;
    x_instance_rec.last_pa_project_id         := p_instance_header_rec.last_pa_project_id;
    x_instance_rec.last_pa_task_id            := p_instance_header_rec.last_pa_task_id;
    x_instance_rec.last_oe_agreement_id       := p_instance_header_rec.last_oe_agreement_id;
    x_instance_rec.install_date               := p_instance_header_rec.install_date;
    x_instance_rec.manually_created_flag      := p_instance_header_rec.manually_created_flag;
    x_instance_rec.return_by_date             := p_instance_header_rec.return_by_date;
    x_instance_rec.actual_return_date         := p_instance_header_rec.actual_return_date;
    x_instance_rec.creation_complete_flag     := p_instance_header_rec.creation_complete_flag;
    x_instance_rec.completeness_flag          := p_instance_header_rec.completeness_flag;
    x_instance_rec.context                    := p_instance_header_rec.context;
    x_instance_rec.attribute1                 := p_instance_header_rec.attribute1;
    x_instance_rec.attribute2                 := p_instance_header_rec.attribute2;
    x_instance_rec.attribute3                 := p_instance_header_rec.attribute3;
    x_instance_rec.attribute4                 := p_instance_header_rec.attribute4;
    x_instance_rec.attribute5                 := p_instance_header_rec.attribute5;
    x_instance_rec.attribute6                 := p_instance_header_rec.attribute6;
    x_instance_rec.attribute7                 := p_instance_header_rec.attribute7;
    x_instance_rec.attribute8                 := p_instance_header_rec.attribute8;
    x_instance_rec.attribute9                 := p_instance_header_rec.attribute9;
    x_instance_rec.attribute10                := p_instance_header_rec.attribute10;
    x_instance_rec.attribute11                := p_instance_header_rec.attribute11;
    x_instance_rec.attribute12                := p_instance_header_rec.attribute12;
    x_instance_rec.attribute13                := p_instance_header_rec.attribute13;
    x_instance_rec.attribute14                := p_instance_header_rec.attribute14;
    x_instance_rec.attribute15                := p_instance_header_rec.attribute15;
    x_instance_rec.object_version_number      := p_instance_header_rec.object_version_number;
  END make_non_header_rec;

  PROCEDURE make_non_header_tbl(
    p_instance_header_tbl IN  csi_datastructures_pub.instance_header_tbl,
    x_instance_tbl        OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_instance_header_tbl.COUNT > 0 THEN
      FOR l_ind IN p_instance_header_tbl.FIRST .. p_instance_header_tbl.LAST
      LOOP

        make_non_header_rec(
          p_instance_header_rec => p_instance_header_tbl(l_ind),
          x_instance_rec        => x_instance_tbl(l_ind),
          x_return_status       => l_return_status);

      END LOOP;
    END IF;

  END make_non_header_tbl;


  PROCEDURE split_instances_using_copy(
    p_instance_rec   IN            csi_datastructures_pub.instance_rec,
    px_csi_txn_rec   IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_tbl      OUT nocopy csi_datastructures_pub.instance_tbl,
    x_return_status     OUT nocopy varchar2)
  IS

    l_instance_usage_code   varchar2(80);
    l_location_type_code    varchar2(80);
    l_quantity              number;
    l_parent_instance_id    number;

    l_u_instance_rec        csi_datastructures_pub.instance_rec;
    l_u_parties_tbl         csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl       csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl       csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl       csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl         csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl          csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list   csi_datastructures_pub.id_tbl;

    l_instance_rec          csi_datastructures_pub.instance_rec;
    l_copy_instance_tbl     csi_datastructures_pub.instance_tbl;

    l_ii_rltns_tbl          csi_datastructures_pub.ii_relationship_tbl;

    l_instance_tbl          csi_datastructures_pub.instance_tbl;
    x_ind                   binary_integer := 0;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('split_instances_using_copy');

    IF nvl(p_instance_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      l_instance_rec := p_instance_rec;

      IF p_instance_rec.quantity > 1 THEN

        l_u_instance_rec.instance_id         := l_instance_rec.instance_id;
        l_u_instance_rec.quantity            := 1;

        SELECT object_version_number,
               instance_usage_code,
               location_type_code,
               quantity
        INTO   l_u_instance_rec.object_version_number,
               l_instance_usage_code ,
               l_location_type_code,
               l_quantity
        FROM   csi_item_instances
        WHERE  instance_id = l_u_instance_rec.instance_id;

        IF l_instance_usage_code = 'IN_RELATIONSHIP' THEN
          SELECT object_id
          INTO   l_parent_instance_id
          FROM   csi_ii_relationships
          WHERE  subject_id = p_instance_rec.instance_id
          AND    relationship_type_code = 'COMPONENT-OF'
          AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                         AND     nvl(active_end_date, sysdate+1);
        END IF;

        debug('  Inside API :csi_item_instance_pub.update_item_instance');
        debug('    instance_id      : '||l_u_instance_rec.instance_id);
        debug('    instance_ovn     : '||l_u_instance_rec.object_version_number);
        debug('    quantity         : '||l_u_instance_rec.quantity);

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

        IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_ind := x_ind + 1;
        l_instance_tbl(x_ind) := p_instance_rec;
        l_instance_tbl(x_ind).quantity := 1;

        FOR l_ind IN 1..(p_instance_rec.quantity - 1)
        LOOP

          l_instance_rec.quantity            := 1;
          l_instance_rec.instance_usage_code := 'RETURNED';

          debug('  Inside API :csi_item_instance_pub.copy_item_instance');

          csi_item_instance_pub.copy_item_instance(
            p_api_version            => 1.0,
            p_commit                 => fnd_api.g_false,
            p_init_msg_list          => fnd_api.g_true,
            p_validation_level       => fnd_api.g_valid_level_full,
            p_source_instance_rec    => l_instance_rec,
            p_copy_ext_attribs       => fnd_api.g_true,
            p_copy_org_assignments   => fnd_api.g_true,
            p_copy_parties           => fnd_api.g_true,
            p_copy_party_contacts    => fnd_api.g_true,
            p_copy_accounts          => fnd_api.g_true,
            p_copy_asset_assignments => fnd_api.g_true,
            p_copy_pricing_attribs   => fnd_api.g_true,
            p_copy_inst_children     => fnd_api.g_false,
            p_txn_rec                => px_csi_txn_rec,
            x_new_instance_tbl       => l_copy_instance_tbl,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_copy_instance_tbl.COUNT > 0 THEN
            FOR c_ind IN l_copy_instance_tbl.FIRST .. l_copy_instance_tbl.LAST
            LOOP
              x_ind := x_ind + 1;
              l_instance_tbl(x_ind) := l_copy_instance_tbl(c_ind);

              debug('    instance_id      : '||l_copy_instance_tbl(c_ind).instance_id);
              debug('    quantity         : '||l_copy_instance_tbl(c_ind).quantity);

              IF l_parent_instance_id is not null THEN

                l_ii_rltns_tbl(1).relationship_id        := fnd_api.g_miss_num;
                l_ii_rltns_tbl(1).relationship_type_code := 'COMPONENT-OF';
                l_ii_rltns_tbl(1).object_id              := l_parent_instance_id;
                l_ii_rltns_tbl(1).subject_id             := l_copy_instance_tbl(c_ind).instance_id;

                debug('  Inside API :csi_ii_relationships_pub.create_relationship');

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
                  RAISE fnd_api.g_exc_error;
                END IF;

              END IF;
            END LOOP;
          END IF;

        END LOOP;
      ELSE
        x_ind := x_ind + 1;
        l_instance_tbl(x_ind) := p_instance_rec;
      END IF;

      IF l_instance_tbl.COUNT > 0 THEN
        FOR inst_ind IN l_instance_tbl.FIRST .. l_instance_tbl.LAST
        LOOP
          SELECT location_type_code,
                 instance_usage_code
          INTO   l_instance_tbl(inst_ind).location_type_code,
                 l_instance_tbl(inst_ind).instance_usage_code
          FROM   csi_item_instances
          WHERE  instance_id = l_instance_tbl(inst_ind).instance_id;
        END LOOP;
      END IF;

      x_instance_tbl := l_instance_tbl;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_instances_using_copy;

  PROCEDURE split_instance(
    p_instance_id         IN     number,
    p_quantity            IN     number,
    px_csi_txn_rec        IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_rec           OUT nocopy csi_datastructures_pub.instance_rec,
    x_return_status          OUT nocopy varchar2)
  IS
    l_instance_quantity      number;
    l_instance_ovn           number;

    l_src_instance_rec       csi_datastructures_pub.instance_rec;
    l_new_instance_rec       csi_datastructures_pub.instance_rec;

    l_quantity1              number;
    l_quantity2              number;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data               varchar2(2000);
    l_msg_count              number;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('split_instance');

    SELECT quantity,
           object_version_number
    INTO   l_instance_quantity,
           l_instance_ovn
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;

    l_src_instance_rec.instance_id := p_instance_id;

    l_quantity1 := l_instance_quantity - p_quantity;
    l_quantity2 := p_quantity;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_item_instance_pvt',
      p_api_name => 'split_item_instance');

    csi_item_instance_pvt.split_item_instance (
      p_api_version            => 1.0,
      p_commit                 => fnd_api.g_false,
      p_init_msg_list          => fnd_api.g_true,
      p_validation_level       => fnd_api.g_valid_level_full,
      p_source_instance_rec    => l_src_instance_rec,
      p_quantity1              => l_quantity1,
      p_quantity2              => l_quantity2,
      p_copy_ext_attribs       => fnd_api.g_true,
      p_copy_org_assignments   => fnd_api.g_true,
      p_copy_parties           => fnd_api.g_true,
      p_copy_accounts          => fnd_api.g_true,
      p_copy_asset_assignments => fnd_api.g_true,
      p_copy_pricing_attribs   => fnd_api.g_true,
      p_txn_rec                => px_csi_txn_rec,
      x_new_instance_rec       => l_new_instance_rec,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_instance_rec := l_new_instance_rec;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_instance;

  PROCEDURE split_instance_using_ratio(
    p_instance_id         IN     number,
    p_qty_ratio           IN     number,
    p_parent_qty          IN     number,
    p_organization_id     IN     number,
    px_csi_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_splitted_instances     OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status          OUT NOCOPY varchar2)
  IS

    l_qty_remaining          number;

    l_init_instance_rec      csi_datastructures_pub.instance_rec;
    l_parent_instance_id     number;
    l_ii_rltns_tbl           csi_datastructures_pub.ii_relationship_tbl;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data               varchar2(2000);
    l_msg_count              number;

    l_split_flag             boolean := FALSE;

    l_splitted_instances     csi_datastructures_pub.instance_tbl;
    l_s_ind                  binary_integer;

    -- get_item_instance_details variables
    l_g_instance_rec         csi_datastructures_pub.instance_header_rec;
    l_g_ph_tbl               csi_datastructures_pub.party_header_tbl;
    l_g_pah_tbl              csi_datastructures_pub.party_account_header_tbl;
    l_g_ouh_tbl              csi_datastructures_pub.org_units_header_tbl;
    l_g_pa_tbl               csi_datastructures_pub.pricing_attribs_tbl;
    l_g_eav_tbl              csi_datastructures_pub.extend_attrib_values_tbl;
    l_g_ea_tbl               csi_datastructures_pub.extend_attrib_tbl;
    l_g_iah_tbl              csi_datastructures_pub.instance_asset_header_tbl;
    l_g_time_stamp           date;

    -- make_non_hdr variables
    l_instance_rec           csi_datastructures_pub.instance_rec;

    -- update_item_instance variables
    l_u_instance_rec         csi_datastructures_pub.instance_rec;
    l_u_parties_tbl          csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl          csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl           csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list    csi_datastructures_pub.id_tbl;

    -- create_item_instance varaibles
    l_c_instance_rec         csi_datastructures_pub.instance_rec;
    l_c_parties_tbl          csi_datastructures_pub.party_tbl;
    l_c_pty_accts_tbl        csi_datastructures_pub.party_account_tbl;
    l_c_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_c_ea_values_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
    l_c_pricing_tbl          csi_datastructures_pub.pricing_attribs_tbl;
    l_c_assets_tbl           csi_datastructures_pub.instance_asset_tbl;
    c_pa_ind                 binary_integer;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('split_instance_using_ratio');

    l_s_ind := 0;

    l_g_instance_rec.instance_id := p_instance_id;

    debug('  Inside API :csi_item_instance_pub.get_item_instance_details');

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

    make_non_header_rec(
      p_instance_header_rec => l_g_instance_rec,
      x_instance_rec        => l_instance_rec,
      x_return_status       => l_return_status);

    debug('    comp_instance_id : '||l_instance_rec.instance_id);
    debug('    comp_quantity    : '||l_instance_rec.quantity);
    debug('    comp_usage_code  : '||l_instance_rec.instance_usage_code);

    IF l_instance_rec.instance_usage_code = 'IN_RELATIONSHIP' THEN
      BEGIN
        SELECT object_id
        INTO   l_parent_instance_id
        FROM   csi_ii_relationships
        WHERE  subject_id = l_instance_rec.instance_id
        AND    relationship_type_code = 'COMPONENT-OF';
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;
    END IF;

    debug('  loop thru to split. allocate and update');

    l_qty_remaining := l_g_instance_rec.quantity;

    FOR ind IN 1 .. p_parent_qty
    LOOP

      IF l_qty_remaining > p_qty_ratio THEN

        l_split_flag := TRUE;

        -- initialize the record structure
        l_c_instance_rec := l_init_instance_rec;
        l_u_instance_rec := l_init_instance_rec;

        l_qty_remaining := l_qty_remaining - p_qty_ratio;


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

        debug('    alloc_qty(new)   : '||l_c_instance_rec.quantity);

        -- create a new instance for the decremented qty
        debug('    Inside API :csi_item_instance_pub.create_item_instance');

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

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('    new_instance_id  : '||l_c_instance_rec.instance_id);

        l_s_ind := l_s_ind + 1;
        l_splitted_instances(l_s_ind) := l_c_instance_rec;

        l_ii_rltns_tbl.delete;

        IF l_parent_instance_id is not null THEN

          l_ii_rltns_tbl(1).relationship_id        := fnd_api.g_miss_num;
          l_ii_rltns_tbl(1).relationship_type_code := 'COMPONENT-OF';
          l_ii_rltns_tbl(1).object_id              := l_parent_instance_id;
          l_ii_rltns_tbl(1).subject_id             := l_c_instance_rec.instance_id;

          debug('    Inside API :csi_ii_relationships_pub.create_relationship');

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
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

        -- decrementing the existing wip instance with the remaining quantity
        l_u_instance_rec.instance_id         := p_instance_id;
        l_u_instance_rec.quantity            := l_qty_remaining;
        l_u_instance_rec.vld_organization_id := p_organization_id;

        SELECT object_version_number
        INTO   l_u_instance_rec.object_version_number
        FROM   csi_item_instances
        WHERE  instance_id = l_u_instance_rec.instance_id;

        debug('    remain_qty(upd)  : '||l_u_instance_rec.quantity);
        debug('    Inside API :csi_item_instance_pub.update_item_instance');
        debug('    old_instance_id  : '||l_u_instance_rec.instance_id);

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

        IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
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


    IF l_splitted_instances.COUNT > 0 THEN
      FOR x_ind IN l_splitted_instances.FIRST .. l_splitted_instances.LAST
      LOOP
        SELECT location_type_code,
               instance_usage_code
        INTO   l_splitted_instances(x_ind).location_type_code,
               l_splitted_instances(x_ind).instance_usage_code
        FROM   csi_item_instances
        WHERE  instance_id = l_splitted_instances(x_ind).instance_id;
      END LOOP;
    END IF;

    debug('splitted instances count :'||l_splitted_instances.COUNT);

    x_splitted_instances := l_splitted_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_instance_using_ratio;


  PROCEDURE query_immediate_children (
    p_parent_line_id     IN  number,
    x_line_tbl           OUT NOCOPY oe_order_pub.line_tbl_type)
  IS

    l_line_rec  oe_order_pub.line_rec_type := oe_order_pub.g_miss_line_rec;

    CURSOR op_cur is
      SELECT line_id
      FROM   oe_order_lines_all
      WHERE  link_to_line_id   = p_parent_line_id
  and nvl(cancelled_flag, 'N') <> 'Y' -- added for Bug 2946778. shegde
      ORDER BY line_number, shipment_number, option_number;

  BEGIN

    debug('Getting next level children for Line ID :'||p_parent_line_id);

    FOR op_rec IN op_cur
    LOOP

      IF op_rec.line_id <> p_parent_line_id THEN

        oe_line_util.query_row(
          p_line_id  => op_rec.line_id,
          x_line_rec => l_line_rec );

        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;

      END IF;

    END LOOP;

    debug('Children count :'||x_line_tbl.COUNT);

  END query_immediate_children;

  /* --------------------------------------------------------------------- */
  /* This routine gets the next level trackable order line details for the */
  /* currently processed order line id(MODEL, CLASS, KIT)                  */
  /*                                                                       */
  /* Here is an example:                                                   */
  /*                           A (MODEL)                                   */
  /*                          / \                                          */
  /*            Non Trk (OC) B   C (OC) Trk                                */
  /*                        / \   \                                        */
  /*                       D   E   F                                       */
  /*  Both D and E are  trackable option items. In this example while      */
  /*  processing the Model (A) the relationship will be build between      */
  /*  A => C, A => D, A = E. Option class B will be ignored                */
  /* --------------------------------------------------------------------- */

  PROCEDURE get_ib_trackable_children(
    p_current_line_id    IN  number,
    p_om_vld_org_id      IN  number,
    x_trackable_line_tbl OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_line_tbl           oe_order_pub.line_tbl_type;
    l_line_tbl_nxt_lvl   oe_order_pub.line_tbl_type;
    l_line_tbl_temp      oe_order_pub.line_tbl_type;
    l_line_tbl_final     oe_order_pub.line_tbl_type;

    l_config_line_rec    oe_order_pub.line_rec_type := oe_order_pub.g_miss_line_rec;

    l_nxt_ind            binary_integer;
    l_final_ind          binary_integer;

    l_ib_trackable_flag  varchar2(1);
    l_config_found       boolean := FALSE;
    l_lvl                number  := 0;
    l_lpad_string        varchar2(80);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_ib_trackable_children');

    debug('lvl_0_line_id      : '||p_current_line_id);
    l_final_ind := 0;

    query_immediate_children (
      p_parent_line_id  => p_current_line_id,
      x_line_tbl        => l_line_tbl);

    l_lvl := 1;

    <<Next_Level>>

    l_line_tbl_nxt_lvl.delete;
    l_nxt_ind := 0;

    IF l_line_tbl.count > 0 THEN

      FOR l_ind IN l_line_tbl.FIRST .. l_line_tbl.LAST
      LOOP
        l_lpad_string := lpad(' ',l_lvl*2, ' ');

        debug(l_lpad_string||'lvl_'||l_lvl||'_line_id      : '||l_line_tbl(l_ind).line_id);

        SELECT nvl(msi.comms_nl_trackable_flag,'N')
        INTO   l_ib_trackable_flag
        FROM   mtl_system_items msi
        WHERE  msi.inventory_item_id = l_line_tbl(l_ind).inventory_item_id
        AND    msi.organization_id   = p_om_vld_org_id;

        debug(l_lpad_string||'item_type_code     : '||l_line_tbl(l_ind).item_type_code);
        debug(l_lpad_string||'ib_trackable_flag  : '||l_ib_trackable_flag);

        /* if trackable populate it for the final out table */
        IF l_ib_trackable_flag = 'Y' THEN

          l_final_ind := l_final_ind + 1;
          l_line_tbl_final(l_final_ind) := l_line_tbl(l_ind);

        ELSE --[NOT Trackable]

          /* get the next level using this line ID as the parent */

          query_immediate_children (
            p_parent_line_id  => l_line_tbl(l_ind).line_id,
            x_line_tbl        => l_line_tbl_temp);

          IF l_line_tbl_temp.count > 0 THEN
            FOR l_temp_ind IN l_line_tbl_temp.FIRST .. l_line_tbl_temp.LAST
            LOOP

              l_nxt_ind := l_nxt_ind + 1;
              l_line_tbl_nxt_lvl (l_nxt_ind) := l_line_tbl_temp(l_temp_ind);

            END LOOP;
          END IF;

        END IF;

      END LOOP;

      IF l_line_tbl_nxt_lvl.COUNT > 0 THEN
        l_line_tbl.DELETE;
        l_line_tbl := l_line_tbl_nxt_lvl;

        l_lvl := l_lvl + 1;
        goto Next_Level;

      END IF;

    END IF;

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

    debug('ib trackable children count :'||x_trackable_line_tbl.COUNT);

  END get_ib_trackable_children;

  PROCEDURE get_all_ib_trackable_children(
    p_model_line_id      IN  number,
    p_om_vld_org_id      IN  number,
    x_trackable_line_tbl OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_line_tbl           oe_order_pub.line_tbl_type;
    l_line_tbl_nxt_lvl   oe_order_pub.line_tbl_type;
    l_line_tbl_temp      oe_order_pub.line_tbl_type;
    l_line_tbl_final     oe_order_pub.line_tbl_type;

    l_nxt_ind            binary_integer;
    l_final_ind          binary_integer;

    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_final_ind := 0;

    get_ib_trackable_children(
      p_current_line_id    => p_model_line_id,
      p_om_vld_org_id      => p_om_vld_org_id,
      x_trackable_line_tbl => l_line_tbl,
      x_return_status      => l_return_status);

    <<Next_Level>>

    l_line_tbl_nxt_lvl.delete;
    l_nxt_ind := 0;

    IF l_line_tbl.count > 0 THEN

      FOR l_ind IN l_line_tbl.FIRST .. l_line_tbl.LAST
      LOOP

        l_final_ind := l_final_ind + 1;
        l_line_tbl_final(l_final_ind) := l_line_tbl(l_ind);

        /* get the next level using this line ID as the parent */

        get_ib_trackable_children(
          p_current_line_id    => l_line_tbl(l_ind).line_id,
          p_om_vld_org_id      => p_om_vld_org_id,
          x_trackable_line_tbl => l_line_tbl_temp,
          x_return_status      => l_return_status);

        IF l_line_tbl_temp.count > 0 THEN
          FOR l_temp_ind IN l_line_tbl_temp.FIRST .. l_line_tbl_temp.LAST
          LOOP

            l_nxt_ind := l_nxt_ind + 1;
            l_line_tbl_nxt_lvl (l_nxt_ind) := l_line_tbl_temp(l_temp_ind);

          END LOOP;
        END IF;

      END LOOP;

      IF l_line_tbl_nxt_lvl.COUNT > 0 THEN
        l_line_tbl.DELETE;
        l_line_tbl := l_line_tbl_nxt_lvl;

        goto Next_Level;

      END IF;

    END IF;

    x_trackable_line_tbl := l_line_tbl_final;

  END get_all_ib_trackable_children;


  /* --------------------------------------------------------------- */
  /* this routine gets the default transaction sub type id for the   */
  /* given transaction type id. For order management the transaction */
  /* type id is hard coded as 51                                     */
  /* --------------------------------------------------------------- */

  PROCEDURE get_txn_sub_type_id(
    p_txn_type_id     IN  number,
    x_txn_sub_type_id OUT NOCOPY number,
    x_return_status   OUT NOCOPY varchar2)
  IS
  BEGIN

    SELECT sub_type_id
    INTO   x_txn_sub_type_id
    FROM   csi_txn_sub_types
    WHERE  transaction_type_id = p_txn_type_id
    AND    default_flag = 'Y';

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.set_name('CSI','CSI_INVALID_TXN_TYPE_ID');
      FND_MSG_PUB.add;
    WHEN too_many_rows THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.set_name('CSI','CSI_INVALID_TXN_TYPE_ID');
      FND_MSG_PUB.add;
  END get_txn_sub_type_id;

  /* This routine splits the transaction details in to quantity one each */
  PROCEDURE split_txn_dtls(
    p_line_dtl_tbl   IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_ii_rltns_tbl   IN  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status  OUT NOCOPY varchar2)
  IS
    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_rec    csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_tbl    csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl     csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl    csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl   csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl      csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl     csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl csi_t_datastructures_grp.txn_systems_tbl;

    l_p_ii_rltns_tbl csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_split_count      number;

    l_c_pty_ind      binary_integer;
    l_c_pa_ind       binary_integer;

    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count      number;
    l_msg_data       varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('split_txn_dtls');

    l_split_count := 0;

    IF p_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind in p_line_dtl_tbl.FIRST .. p_line_dtl_tbl.LAST
      LOOP
        IF p_line_dtl_tbl(l_td_ind).quantity > 1 THEN

          l_split_count := l_split_count + 1;

          update csi_t_txn_line_details
          set    quantity = 1,
                 processing_status         = 'IN_PROCESS' ,
                 source_txn_line_detail_id = p_line_dtl_tbl(l_td_ind).txn_line_detail_id
          where  txn_line_detail_id        = p_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          l_txn_line_detail_query_rec.txn_line_detail_id := p_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          -- get_txn_line_details
          csi_t_txn_details_grp.get_transaction_details(
            p_api_version                => 1,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_txn_line_query_rec         => l_txn_line_query_rec,
            p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
            x_txn_line_detail_tbl        => l_line_dtl_tbl,
            p_get_parties_flag           => fnd_api.g_true,
            x_txn_party_detail_tbl       => l_pty_dtl_tbl,
            p_get_pty_accts_flag         => fnd_api.g_true,
            x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
            p_get_ii_rltns_flag          => fnd_api.g_false,
            x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
            p_get_org_assgns_flag        => fnd_api.g_true,
            x_txn_org_assgn_tbl          => l_org_assgn_tbl,
            p_get_ext_attrib_vals_flag   => fnd_api.g_true,
            x_txn_ext_attrib_vals_tbl    => l_ext_attrib_tbl,
            p_get_csi_attribs_flag       => fnd_api.g_false,
            x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
            p_get_csi_iea_values_flag    => fnd_api.g_false,
            x_csi_iea_values_tbl         => l_csi_eav_tbl,
            p_get_txn_systems_flag       => fnd_api.g_false,
            x_txn_systems_tbl            => l_txn_systems_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Error getting txn details for splitting the source for model.');
            RAISE fnd_api.g_exc_error;
          END IF;

          FOR l_ind in 1..(p_line_dtl_tbl(l_td_ind).quantity - 1)
          LOOP

            -- convert ids to indexes
            csi_t_utilities_pvt.convert_ids_to_index(
              px_line_dtl_tbl            => l_line_dtl_tbl,
              px_pty_dtl_tbl             => l_pty_dtl_tbl,
              px_pty_acct_tbl            => l_pty_acct_tbl,
              px_ii_rltns_tbl            => l_ii_rltns_tbl,
              px_org_assgn_tbl           => l_org_assgn_tbl,
              px_ext_attrib_tbl          => l_ext_attrib_tbl,
              px_txn_systems_tbl         => l_txn_systems_tbl);

            --create txn_line_details for quantity 1;
            l_line_dtl_rec                     := l_line_dtl_tbl(1);
            l_line_dtl_rec.transaction_line_id := p_line_dtl_tbl(l_td_ind).transaction_line_id;
            l_line_dtl_rec.quantity            := 1;
            l_line_dtl_rec.processing_status   := 'IN_PROCESS';

            ---Added (Start) for m-to-m enhancements
            l_line_dtl_rec.source_txn_line_detail_id :=
                                 p_line_dtl_tbl(l_td_ind).txn_line_detail_id ;
            ---Added (End) for m-to-m enhancements

            csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
              p_api_version              => 1.0,
              p_commit                   => fnd_api.g_false,
              p_init_msg_list            => fnd_api.g_true,
              p_validation_level         => fnd_api.g_valid_level_full,
              p_txn_line_dtl_index       => 1,
              p_txn_line_dtl_rec         => l_line_dtl_rec,
              px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
              px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
              px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
              px_txn_org_assgn_tbl       => l_org_assgn_tbl,
              px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
              x_return_status            => l_return_status,
              x_msg_count                => l_msg_count,
              x_msg_data                 => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Error creating txn details for splitting the source for model.');
              raise fnd_api.g_exc_error;
            END IF;

            l_line_dtl_tbl(1) := l_line_dtl_rec;

          END LOOP; -- (qauantity -1) loop

        ELSE

          update csi_t_txn_line_details
          set    processing_status = 'IN_PROCESS'
          where  txn_line_detail_id = p_line_dtl_tbl(l_td_ind).txn_line_detail_id;

        END IF; -- qty > 1

      END LOOP;
    END IF;

    debug('Splitted Transaction Details :'||l_split_count );

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       l_return_status := FND_API.g_ret_sts_error;
  END split_txn_dtls;

  PROCEDURE split_txn_dtls_with_ratio(
    p_quantity_ratio IN  number,
    px_line_dtl_tbl  IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_rec    csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_tbl    csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl     csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl    csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl   csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl      csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl     csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl csi_t_datastructures_grp.txn_systems_tbl;

    l_td_quantity     number;

    l_o_line_dtl_tbl  csi_t_datastructures_grp.txn_line_detail_tbl;
    l_o_ind           binary_integer := 0;

    l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('split_txn_dtls_with_ratio');

    IF px_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind in px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
      LOOP
        IF px_line_dtl_tbl(l_td_ind).quantity > p_quantity_ratio THEN

          update csi_t_txn_line_details
          set    quantity = p_quantity_ratio,
                 processing_status = 'IN_PROCESS'
          where  txn_line_detail_id = px_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          l_o_ind := l_o_ind + 1;
          l_o_line_dtl_tbl(l_o_ind) := px_line_dtl_tbl(l_td_ind);
          l_o_line_dtl_tbl(l_o_ind).quantity := p_quantity_ratio;

          l_txn_line_detail_query_rec.txn_line_detail_id := px_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          -- get_txn_line_details
          csi_t_txn_details_grp.get_transaction_details(
            p_api_version                => 1,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_txn_line_query_rec         => l_txn_line_query_rec,
            p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
            x_txn_line_detail_tbl        => l_line_dtl_tbl,
            p_get_parties_flag           => fnd_api.g_true,
            x_txn_party_detail_tbl       => l_pty_dtl_tbl,
            p_get_pty_accts_flag         => fnd_api.g_true,
            x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
            p_get_ii_rltns_flag          => fnd_api.g_false,
            x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
            p_get_org_assgns_flag        => fnd_api.g_true,
            x_txn_org_assgn_tbl          => l_org_assgn_tbl,
            p_get_ext_attrib_vals_flag   => fnd_api.g_true,
            x_txn_ext_attrib_vals_tbl    => l_ext_attrib_tbl,
            p_get_csi_attribs_flag       => fnd_api.g_false,
            x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
            p_get_csi_iea_values_flag    => fnd_api.g_false,
            x_csi_iea_values_tbl         => l_csi_eav_tbl,
            p_get_txn_systems_flag       => fnd_api.g_false,
            x_txn_systems_tbl            => l_txn_systems_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_line_dtl_tbl.COUNT > 0 THEN

            l_td_quantity := px_line_dtl_tbl(l_td_ind).quantity - p_quantity_ratio;

            WHILE l_td_quantity > 0
            LOOP

              -- convert ids to indexes
              csi_t_utilities_pvt.convert_ids_to_index(
                px_line_dtl_tbl            => l_line_dtl_tbl,
                px_pty_dtl_tbl             => l_pty_dtl_tbl,
                px_pty_acct_tbl            => l_pty_acct_tbl,
                px_ii_rltns_tbl            => l_ii_rltns_tbl,
                px_org_assgn_tbl           => l_org_assgn_tbl,
                px_ext_attrib_tbl          => l_ext_attrib_tbl,
                px_txn_systems_tbl         => l_txn_systems_tbl);

              --create txn_line_details for quantity 1;
              l_line_dtl_rec                     := l_line_dtl_tbl(1);
              l_line_dtl_rec.transaction_line_id := px_line_dtl_tbl(l_td_ind).transaction_line_id;
              l_line_dtl_rec.quantity            := p_quantity_ratio;
              l_line_dtl_rec.processing_status   := 'IN_PROCESS';

              -- create transaction detail

              csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
                p_api_version              => 1.0,
                p_commit                   => fnd_api.g_false,
                p_init_msg_list            => fnd_api.g_true,
                p_validation_level         => fnd_api.g_valid_level_full,
                p_txn_line_dtl_index       => 1,
                p_txn_line_dtl_rec         => l_line_dtl_rec,
                px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
                px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
                px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
                px_txn_org_assgn_tbl       => l_org_assgn_tbl,
                px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
                x_return_status            => l_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                 => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                raise fnd_api.g_exc_error;
              END IF;

              l_o_ind := l_o_ind + 1;
              l_o_line_dtl_tbl(l_o_ind) := l_line_dtl_rec;

              l_line_dtl_tbl(1) := l_line_dtl_rec;
              l_td_quantity := l_td_quantity - p_quantity_ratio;

            END LOOP;
          END IF;
        ELSE
          UPDATE csi_t_txn_line_details
          SET    processing_status = 'IN_PROCESS'
          WHERE  txn_line_detail_id = px_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          l_o_ind := l_o_ind + 1;
          l_o_line_dtl_tbl(l_o_ind) := px_line_dtl_tbl(l_td_ind);
          l_o_line_dtl_tbl(l_o_ind).processing_status := 'IN_PROCESS';

        END IF;
      END LOOP;
    END IF;
    px_line_dtl_tbl := l_o_line_dtl_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       l_return_status := FND_API.g_ret_sts_error;
  END split_txn_dtls_with_ratio;

  /* private routine to determine the item type  of the order line */
  PROCEDURE get_item_type(
    p_item_type_code    IN varchar2,
    p_line_id           IN number,
    p_ato_line_id       IN number,
    p_top_model_line_id IN number,
    x_item_type            OUT nocopy varchar2)
  IS
    l_sub_model_flag    varchar2(1);
    l_ato_line_id       NUMBER;
  BEGIN

    IF p_item_type_code = 'MODEL' THEN
      IF p_ato_line_id = p_line_id THEN
        x_item_type := 'ATO_MODEL';
      ELSIF p_ato_line_id is null THEN
        x_item_type := 'PTO_MODEL';
      END IF;
    ELSIF p_item_type_code = 'KIT' THEN
      x_item_type := 'KIT';
    ELSIF p_item_type_code = 'OPTION' THEN
      IF p_ato_line_id is not null THEN
        x_item_type := 'ATO_OPTION';
      ELSIF p_ato_line_id is null THEN
        x_item_type := 'PTO_OPTION';
      END IF;
    ELSIF p_item_type_code = 'CLASS' THEN
      IF p_ato_line_id is not null THEN
        BEGIN
          SELECT 'Y'
          INTO   l_sub_model_flag
          FROM   sys.dual
          WHERE  exists (
            SELECT 'X'
            FROM   bom_cto_order_lines
            WHERE  ato_line_id = p_ato_line_id
            AND    parent_ato_line_id = p_line_id);

		--5076453
	     IF l_sub_model_flag ='Y' THEN
	       IF p_ato_line_id = p_line_id THEN

	       SELECT ato_line_id
	       INTO   l_ato_line_id
	       FROM   oe_order_lines_all
	       WHERE  line_id=p_top_model_line_id;

	        IF l_ato_line_id IS NULL THEN
	          x_item_type := 'ATO_MODEL';
                END IF;
              ELSE -- p_ato_line_id
	      x_item_type  := 'ATO_SUB_MODEL';

          END IF;
	  END IF;

        EXCEPTION
          WHEN no_data_found THEN
            x_item_type := 'ATO_CLASS';
        END;
      ELSIF p_ato_line_id is null THEN
        x_item_type := 'PTO_CLASS';
      END IF;
    ELSIF p_item_type_code = 'INCLUDED' THEN
      x_item_type := 'INCLUDED_ITEM';
    ELSIF p_item_type_code = 'CONFIG' THEN
      x_item_type := 'CONFIG_ITEM';
    ELSIF p_item_type_code = 'STANDARD' THEN
      x_item_type := 'STANDARD';
    END IF;
    debug('  identified_type    : '||x_item_type);
  END get_item_type;

  PROCEDURE get_ib_trackable_parent(
    p_current_line_id    IN  number,
    p_om_vld_org_id      IN  number,
    x_parent_line_rec    OUT NOCOPY oe_order_pub.line_rec_type,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_org_id              number;
    l_parent_line_id      number;
    l_next_parent_line_id number;
    l_inventory_item_id   number;
    l_ib_trackable_flag   varchar2(1) := 'N';

    l_parent_line_rec     oe_order_pub.line_rec_type;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_ib_trackable_parent');

    BEGIN

      SELECT link_to_line_id ,
             org_id
      INTO   l_parent_line_id,
             l_org_id
      FROM   oe_order_lines_all
      WHERE  line_id = p_current_line_id;

      <<next_level>>

      IF l_parent_line_id is not null THEN

        SELECT inventory_item_id ,
               link_to_line_id
        INTO   l_inventory_item_id ,
               l_next_parent_line_id
        FROM   oe_order_lines_all
        WHERE  line_id = l_parent_line_id;

        SELECT nvl(msi.comms_nl_trackable_flag, 'N')
        INTO   l_ib_trackable_flag
        FROM   mtl_system_items msi
        WHERE  msi.inventory_item_id = l_inventory_item_id
        AND    msi.organization_id   = p_om_vld_org_id;

        IF l_ib_trackable_flag = 'Y' THEN
          oe_line_util.query_row(
            p_line_id  => l_parent_line_id,
            x_line_rec => l_parent_line_rec );
        ELSE
          l_parent_line_id := l_next_parent_line_id;
          goto next_level;
        END IF;
      END IF;

    END;

    debug('  parent_line_id     : '||l_parent_line_rec.line_id);
    debug('  parent_item_type   : '||l_parent_line_rec.item_type_code);
    debug('  parent_item        : '||l_parent_line_rec.ordered_item);
    debug('  parent_quantity    : '||l_parent_line_rec.ordered_quantity);

    x_parent_line_rec := l_parent_line_rec;

  END get_ib_trackable_parent;

  -- create non source record for relationship processing
  PROCEDURE build_non_source_rec(
    p_transaction_line_id   IN number,
    p_instance_id           IN number,
    px_default_info_rec     IN OUT nocopy default_info_rec,
    x_txn_line_dtl_id          OUT nocopy number,
    x_return_status            OUT nocopy varchar2)
  IS

    l_instance_rec          csi_datastructures_pub.instance_rec;
    l_g_instance_rec        csi_datastructures_pub.instance_header_rec;
    l_g_ph_tbl              csi_datastructures_pub.party_header_tbl;
    l_g_pah_tbl             csi_datastructures_pub.party_account_header_tbl;
    l_g_ouh_tbl             csi_datastructures_pub.org_units_header_tbl;
    l_g_pa_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_g_eav_tbl             csi_datastructures_pub.extend_attrib_values_tbl;
    l_g_ea_tbl              csi_datastructures_pub.extend_attrib_tbl;
    l_g_iah_tbl             csi_datastructures_pub.instance_asset_header_tbl;
    l_g_time_stamp          date;

    -- create_txn_line_dtls variables
    l_n_line_dtl_rec        csi_t_datastructures_grp.txn_line_detail_rec;
    l_n_pty_dtl_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_n_pty_acct_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_n_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_n_ext_attrib_tbl      csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_n_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(4000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_non_source_rec');

    l_g_instance_rec.instance_id := p_instance_id;

    debug('  instance_id : '||p_instance_id);

    IF nvl(p_instance_id, fnd_api.g_miss_num)  <> fnd_api.g_miss_num THEN

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_item_instance_pub',
        p_api_name => 'get_item_instance_details');

      -- get the instance party and party account info
      csi_item_instance_pub.get_item_instance_details(
        p_api_version           => 1.0,
        p_commit                => fnd_api.g_false,
        p_init_msg_list         => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_instance_rec          => l_g_instance_rec,
        p_get_parties           => fnd_api.g_false,
        p_party_header_tbl      => l_g_ph_tbl,
        p_get_accounts          => fnd_api.g_false,
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

      l_n_line_dtl_rec.txn_line_detail_id      := fnd_api.g_miss_num;
      l_n_line_dtl_rec.transaction_line_id     := p_transaction_line_id;
      l_n_line_dtl_rec.sub_type_id             := px_default_info_rec.sub_type_id;
      l_n_line_dtl_rec.processing_status       := 'IN_PROCESS';
      l_n_line_dtl_rec.source_transaction_flag := 'N';
      l_n_line_dtl_rec.inventory_item_id       := l_g_instance_rec.inventory_item_id;
      l_n_line_dtl_rec.inventory_revision      := l_g_instance_rec.inventory_revision;
      /* fix for bug 4941832 */
      l_n_line_dtl_rec.inv_organization_id     := l_g_instance_rec.vld_organization_id;
      l_n_line_dtl_rec.quantity                := l_g_instance_rec.quantity;
      l_n_line_dtl_rec.unit_of_measure         := l_g_instance_rec.unit_of_measure;
      l_n_line_dtl_rec.installation_date       := sysdate;
      l_n_line_dtl_rec.external_reference      := 'INTERFACE';
      l_n_line_dtl_rec.preserve_detail_flag    := 'Y';
      l_n_line_dtl_rec.instance_exists_flag    := 'Y';
      l_n_line_dtl_rec.instance_id             := l_g_instance_rec.instance_id;
      l_n_line_dtl_rec.serial_number           := l_g_instance_rec.serial_number;
      l_n_line_dtl_rec.mfg_serial_number_flag  := l_g_instance_rec.mfg_serial_number_flag;
      l_n_line_dtl_rec.lot_number              := l_g_instance_rec.lot_number;
      l_n_line_dtl_rec.object_version_number   := 1.0;

      csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_full,
        p_txn_line_dtl_index       => 1,
        p_txn_line_dtl_rec         => l_n_line_dtl_rec,
        px_txn_party_dtl_tbl       => l_n_pty_dtl_tbl,
        px_txn_pty_acct_detail_tbl => l_n_pty_acct_tbl,
        px_txn_ii_rltns_tbl        => l_n_ii_rltns_tbl,
        px_txn_org_assgn_tbl       => l_n_org_assgn_tbl,
        px_txn_ext_attrib_vals_tbl => l_n_ext_attrib_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      debug('non_source_tld_id : '||l_n_line_dtl_rec.txn_line_detail_id);
    END IF;
    x_txn_line_dtl_id := l_n_line_dtl_rec.txn_line_detail_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_non_source_rec;

  PROCEDURE get_tld(
    p_source_table       IN         varchar2,
    p_source_id          IN         number,
    p_source_flag        IN         varchar2,
    p_processing_status  IN         varchar2,
    x_line_dtl_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl           csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl          csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl         csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl        csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl            csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl           csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl       csi_t_datastructures_grp.txn_systems_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_tld');

    l_txn_line_query_rec.source_transaction_table        := p_source_table;
    l_txn_line_query_rec.source_transaction_id           := p_source_id;
    l_txn_line_detail_query_rec.source_transaction_flag  := p_source_flag;
    l_txn_line_detail_query_rec.processing_status        := p_processing_status;

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version               => 1,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_txn_line_query_rec        => l_txn_line_query_rec,
      p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl       => l_line_dtl_tbl,
      p_get_parties_flag          => fnd_api.g_false,
      x_txn_party_detail_tbl      => l_pty_dtl_tbl,
      p_get_pty_accts_flag        => fnd_api.g_false,
      x_txn_pty_acct_detail_tbl   => l_pty_acct_tbl,
      p_get_ii_rltns_flag         => fnd_api.g_false,
      x_txn_ii_rltns_tbl          => l_ii_rltns_tbl,
      p_get_org_assgns_flag       => fnd_api.g_false,
      x_txn_org_assgn_tbl         => l_org_assgn_tbl,
      p_get_ext_attrib_vals_flag  => fnd_api.g_false,
      x_txn_ext_attrib_vals_tbl   => l_ext_attrib_tbl,
      p_get_csi_attribs_flag      => fnd_api.g_false,
      x_csi_ext_attribs_tbl       => l_csi_ea_tbl,
      p_get_csi_iea_values_flag   => fnd_api.g_false,
      x_csi_iea_values_tbl        => l_csi_eav_tbl,
      p_get_txn_systems_flag      => fnd_api.g_false,
      x_txn_systems_tbl           => l_txn_systems_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    x_line_dtl_tbl := l_line_dtl_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_tld;

  PROCEDURE get_ato_options_only(
    px_line_tbl          IN OUT nocopy oe_order_pub.line_tbl_type,
    x_return_status         OUT nocopy varchar2)
  IS
    o_line_tbl    oe_order_pub.line_tbl_type;
    o_ind         binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_ato_options_only');

    IF px_line_tbl.COUNT > 0 THEN
      FOR l_ind IN px_line_tbl.FIRST .. px_line_tbl.LAST
      LOOP
        IF px_line_tbl(l_ind).item_type_code = 'OPTION' THEN
          o_ind := o_ind + 1;
          o_line_tbl(o_ind) := px_line_tbl(l_ind);
        END IF;
      END LOOP;
    END IF;

    px_line_tbl := o_line_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_ato_options_only;

  PROCEDURE get_parent_instances(
    p_parent_line_id     IN number,
    p_parent_item_id     IN number,
    x_parent_instances   OUT NOCOPY parent_instances,
    x_return_status      OUT NOCOPY varchar2)
  IS

    CURSOR inst_cur IS
      SELECT inventory_item_id,
             instance_id,
             serial_number,
             location_type_code,
             quantity
      FROM   csi_item_instances
      WHERE  inventory_item_id     = p_parent_item_id
      AND    last_oe_order_line_id = p_parent_line_id;

    l_parent_inst_found boolean := FALSE;

    l_parent_instances  parent_instances;
    l_ind               binary_integer := 0;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_parent_instances');

    FOR inst_rec IN inst_cur
    LOOP

      l_ind := l_ind + 1;

      l_parent_instances(l_ind).item_id        := inst_rec.inventory_item_id;
      l_parent_instances(l_ind).instance_id    := inst_rec.instance_id;
      l_parent_instances(l_ind).quantity       := inst_rec.quantity;
      l_parent_instances(l_ind).serial_number  := inst_rec.serial_number;
      l_parent_instances(l_ind).allocated_flag := 'N';
      l_parent_instances(l_ind).alloc_count    := 0;

    END LOOP;

    -- just the debug
    IF l_parent_instances.COUNT > 0 THEN
      FOR d_ind IN l_parent_instances.FIRST .. l_parent_instances.LAST
      LOOP
        debug('parent instances record # '||d_ind);
        debug('  instance_id        : '||l_parent_instances(d_ind).instance_id);
        debug('  quantity           : '||l_parent_instances(d_ind).quantity);
      END LOOP;
    END IF;
    x_parent_instances := l_parent_instances;

  END get_parent_instances;

  PROCEDURE get_partner_order_info(
    p_order_line_rec        IN  oe_order_lines_all%rowtype,
    x_end_customer_id       OUT nocopy number,
    x_current_site_use_id   OUT nocopy number,
    x_install_site_use_id   OUT nocopy number,
    x_return_status         OUT nocopy varchar2)
  IS

    l_partner_rec          oe_install_base_util.partner_order_rec;
    l_end_customer_id      number;
    l_current_site_use_id  number;
    l_install_site_use_id  number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_partner_order_info');

    -- for partner ordering
    oe_install_base_util.get_partner_ord_rec(
      p_order_line_id      => p_order_line_rec.line_id,
      x_partner_order_rec  => l_partner_rec);

    -- customer
    IF nvl(l_partner_rec.ib_owner, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      IF l_partner_rec.ib_owner = 'INSTALL_BASE' THEN
        l_end_customer_id := fnd_api.g_miss_num;
      ELSE

        IF l_partner_rec.ib_owner = 'END_CUSTOMER' THEN
          l_end_customer_id := l_partner_rec.end_customer_id;
        ELSIF l_partner_rec.ib_owner = 'SOLD_TO' THEN
          l_end_customer_id := p_order_line_rec.sold_to_org_id;
        END IF;

        IF nvl(l_end_customer_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;
    ELSE
      l_partner_rec.ib_owner := 'DEFAULT';
      l_end_customer_id := p_order_line_rec.sold_to_org_id;
    END IF;

    -- current location
    IF nvl(l_partner_rec.ib_current_location, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      IF l_partner_rec.ib_current_location = 'INSTALL_BASE' THEN
        l_current_site_use_id := fnd_api.g_miss_num;
      ELSE

        IF l_partner_rec.ib_current_location = 'END_CUSTOMER' THEN
          l_current_site_use_id := l_partner_rec.end_customer_site_use_id;
        ELSIF l_partner_rec.ib_current_location = 'SHIP_TO' THEN
          l_current_site_use_id := p_order_line_rec.ship_to_org_id;
        ELSIF l_partner_rec.ib_current_location = 'SOLD_TO' THEN
          l_current_site_use_id := l_partner_rec.sold_to_site_use_id;
        ELSIF l_partner_rec.ib_current_location = 'DELIVER_TO' THEN
          l_current_site_use_id := p_order_line_rec.deliver_to_org_id;
        ELSIF l_partner_rec.ib_current_location = 'BILL_TO' THEN
          l_current_site_use_id := p_order_line_rec.invoice_to_org_id;
        END IF;
        IF nvl(l_current_site_use_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    ELSE
      l_partner_rec.ib_current_location := 'DEFAULT';
      l_current_site_use_id := p_order_line_rec.ship_to_org_id;
    END IF;

    -- installed at location
    IF nvl(l_partner_rec.ib_installed_at_location, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      IF l_partner_rec.ib_installed_at_location = 'INSTALL_BASE' THEN
        l_install_site_use_id := fnd_api.g_miss_num;
      ELSE

        IF l_partner_rec.ib_installed_at_location = 'END_CUSTOMER' THEN
          l_install_site_use_id := l_partner_rec.end_customer_site_use_id;
        ELSIF l_partner_rec.ib_installed_at_location = 'SHIP_TO' THEN
          l_install_site_use_id := p_order_line_rec.ship_to_org_id;
        ELSIF l_partner_rec.ib_installed_at_location = 'SOLD_TO' THEN
          l_install_site_use_id := l_partner_rec.sold_to_site_use_id;
        ELSIF l_partner_rec.ib_installed_at_location = 'DELIVER_TO' THEN
          l_install_site_use_id := p_order_line_rec.deliver_to_org_id;
        ELSIF l_partner_rec.ib_installed_at_location = 'BILL_TO' THEN
          l_install_site_use_id := p_order_line_rec.invoice_to_org_id;
        END IF;
        IF nvl(l_install_site_use_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    ELSE
      l_partner_rec.ib_installed_at_location := 'DEFAULT';
      l_install_site_use_id := p_order_line_rec.ship_to_org_id;
    END IF;

    debug('  ib_owner           : '||l_partner_rec.ib_owner);
    debug('  current_location   : '||l_partner_rec.ib_current_location);
    debug('  install_location   : '||l_partner_rec.ib_installed_at_location);

    x_end_customer_id     := l_end_customer_id;
    x_current_site_use_id := l_current_site_use_id;
    x_install_site_use_id := l_install_site_use_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_partner_order_info;


  PROCEDURE convert_wip_instance_to_cp(
    p_instance_id       IN            number,
    p_order_hdr_rec     IN            oe_order_headers_all%rowtype,
    p_order_line_rec    IN            oe_order_lines_all%rowtype,
    p_tld_tbl           IN            csi_t_datastructures_grp.txn_line_detail_tbl,
    px_default_info_rec IN OUT nocopy default_info_rec,
    px_csi_txn_rec      IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY varchar2)
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

    l_pty_dtl_tbl              csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl             csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_org_assgn_tbl            csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_tld_tbl                  csi_t_datastructures_grp.txn_line_detail_tbl;
    l_upd_tld_rec              csi_t_datastructures_grp.txn_line_detail_rec;
    l_upd_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_upd_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_upd_order_line_rec       csi_order_ship_pub.order_line_rec;
    l_tld_found                VARCHAR2(1);

    l_instance_party_id        number;
    l_pty_object_ver_num       number;
    l_ip_account_id            number;
    l_acct_object_ver_num      number;

    l_sub_type_id              number;
    l_cascade_owner_flag       varchar2(1);
    l_src_change_owner         varchar2(1);
    l_src_change_owner_to_code varchar2(1);
    l_src_status_id            number;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(2000);

    l_ind                      binary_integer := 0;
    l_acct_ind                 binary_integer := 0;
    l_a_ind                    binary_integer := 0;
    l_eav_ind                  binary_integer := 0;
    l_ou_ind                   binary_integer := 0;

    -- Modification for bug 4091371
    PROCEDURE get_info_from_tld(
      p_instance_id          IN  number,
      px_tld_tbl             IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
      x_pty_dtl_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
      x_pty_acct_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
      x_org_assgn_tbl        OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
      x_sub_type_id          OUT nocopy number,
      x_cascade_owner_flag   OUT nocopy varchar2,
      x_tld_found            OUT NOCOPY VARCHAR2 )
    IS
      l_tld_found                 VARCHAR2(1) := fnd_api.g_false;
      l_txn_line_detail_id        NUMBER;
      l_tld_tbl                   csi_t_datastructures_grp.txn_line_detail_tbl;
      l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
      l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;
      l_txn_systems_tbl           csi_t_datastructures_grp.txn_systems_tbl;
      l_ext_attrib_tbl            csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
      l_csi_ea_tbl                csi_t_datastructures_grp.csi_ext_attribs_tbl;
      l_csi_iea_values_tbl        csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
      l_ii_rltns_tbl              csi_t_datastructures_grp.txn_ii_rltns_tbl;
      l_return_status             varchar2(1) := fnd_api.g_ret_sts_success;
      l_msg_count                 number;
      l_msg_data                  varchar2(2000);

    BEGIN
      IF p_tld_tbl.COUNT > 0 THEN
        FOR p_ind IN p_tld_tbl.FIRST .. p_tld_tbl.LAST
        LOOP
          IF p_tld_tbl(p_ind).instance_id = p_instance_id THEN
            x_sub_type_id        := p_tld_tbl(p_ind).sub_type_id;
            x_cascade_owner_flag := p_tld_tbl(p_ind).cascade_owner_flag;
            l_txn_line_detail_id := p_tld_tbl(p_ind).txn_line_detail_id;
            l_tld_found := fnd_api.g_true;
            exit;
          END IF;
        END LOOP;

        IF l_tld_found = fnd_api.g_false THEN
          x_sub_type_id        := p_tld_tbl(1).sub_type_id;
          x_cascade_owner_flag := p_tld_tbl(1).cascade_owner_flag;
          l_txn_line_detail_id := p_tld_tbl(1).txn_line_detail_id;
        END IF;
        l_txn_line_detail_query_rec.txn_line_detail_id := l_txn_line_detail_id ;

      -- get_txn_line_details
        csi_t_txn_details_grp.get_transaction_details(
          p_api_version                => 1,
          p_commit                     => fnd_api.g_false,
          p_init_msg_list              => fnd_api.g_true,
          p_validation_level           => fnd_api.g_valid_level_full,
          p_txn_line_query_rec         => l_txn_line_query_rec,
          p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
          x_txn_line_detail_tbl        => l_tld_tbl,
          p_get_parties_flag           => fnd_api.g_true,
          x_txn_party_detail_tbl       => x_pty_dtl_tbl,
          p_get_pty_accts_flag         => fnd_api.g_true,
          x_txn_pty_acct_detail_tbl    => x_pty_acct_tbl,
          p_get_ii_rltns_flag          => fnd_api.g_false,
          x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
          p_get_org_assgns_flag        => fnd_api.g_true,
          x_txn_org_assgn_tbl          => x_org_assgn_tbl,
          p_get_ext_attrib_vals_flag   => fnd_api.g_true,
          x_txn_ext_attrib_vals_tbl    => l_ext_attrib_tbl,
          p_get_csi_attribs_flag       => fnd_api.g_false,
          x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
          p_get_csi_iea_values_flag    => fnd_api.g_false,
          x_csi_iea_values_tbl         => l_csi_iea_values_tbl,
          p_get_txn_systems_flag       => fnd_api.g_false,
          x_txn_systems_tbl            => l_txn_systems_tbl,
          x_return_status              => l_return_status,
          x_msg_count                  => l_msg_count,
          x_msg_data                   => l_msg_data);
        IF nvl(l_tld_tbl.count,0) > 0 THEN
          l_tld_found    := fnd_api.g_true ;
          px_tld_tbl(1)  := l_tld_tbl(1);
        ELSE
          l_tld_found := fnd_api.g_false;
          x_sub_type_id        := px_default_info_rec.sub_type_id;
          x_cascade_owner_flag := px_default_info_rec.ownership_cascade_at_txn;

        END IF;
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           debug('Error getting txn details before converting item instance to customer product.');
           RAISE fnd_api.g_exc_error;
        ELSE
           csi_t_utilities_pvt.convert_ids_to_index(
              px_line_dtl_tbl    => px_tld_tbl,
              px_pty_dtl_tbl     => x_pty_dtl_tbl,
              px_pty_acct_tbl    => x_pty_acct_tbl,
              px_ii_rltns_tbl    => l_ii_rltns_tbl,
              px_org_assgn_tbl   => x_org_assgn_tbl,
              px_ext_attrib_tbl  => l_ext_attrib_tbl,
              px_txn_systems_tbl => l_txn_systems_tbl);
        END IF;
      ELSE
        x_sub_type_id        := px_default_info_rec.sub_type_id;
        x_cascade_owner_flag := px_default_info_rec.ownership_cascade_at_txn;
      END IF;
      x_tld_found := l_tld_found ;
    END get_info_from_tld;

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

    l_order_header_rec := p_order_hdr_rec;
    l_order_line_rec   := p_order_line_rec;

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

    IF l_order_line_rec.invoice_to_org_id is null THEN
       l_order_line_rec.invoice_to_org_id := l_order_header_rec.invoice_to_org_id;
    END IF;

    IF l_order_line_rec.deliver_to_org_id is null THEN
       l_order_line_rec.deliver_to_org_id := l_order_header_rec.deliver_to_org_id;
    END IF;

    l_party_site_id := px_default_info_rec.current_party_site_id;

    -- update the instance to make it a cp
    l_u_instance_rec.instance_id              := p_instance_id ;
    l_u_instance_rec.vld_organization_id      := l_order_line_rec.ship_from_org_id;
    l_u_instance_rec.location_type_code       := 'HZ_PARTY_SITES';
    l_u_instance_rec.location_id              := l_party_site_id;

    IF px_default_info_rec.install_party_site_id is not null THEN
      l_u_instance_rec.install_location_type_code := 'HZ_PARTY_SITES';
      l_u_instance_rec.install_location_id        := px_default_info_rec.install_party_site_id;
    END IF;

    l_u_instance_rec.last_oe_order_line_id    := p_order_line_rec.line_id;
    l_u_instance_rec.active_end_date          := null;
    l_u_instance_rec.instance_usage_code      := 'OUT_OF_ENTERPRISE';
    l_u_instance_rec.object_version_number    := l_inst_object_ver_num;


    -- Modification for bug 4091371
    l_tld_tbl := p_tld_tbl ;
    get_info_from_tld(
      p_instance_id        => p_instance_id,
      px_tld_tbl           => l_tld_tbl,
      x_pty_dtl_tbl        => l_pty_dtl_tbl,
      x_pty_acct_tbl       => l_pty_acct_tbl,
      x_org_assgn_tbl      => l_org_assgn_tbl,
      x_sub_type_id        => l_sub_type_id,
      x_cascade_owner_flag => l_cascade_owner_flag,
      x_tld_found          => l_tld_found );

      IF l_tld_found = fnd_api.g_true THEN
        FOR l_index IN l_tld_tbl.FIRST..l_tld_tbl.FIRST
        LOOP
          l_u_instance_rec.instance_id             := p_instance_id;
          l_u_instance_rec.instance_number         := fnd_api.g_miss_char;
          l_u_instance_rec.external_reference      := nvl(l_tld_tbl(l_index).external_reference,fnd_api.g_miss_char);
          l_u_instance_rec.unit_of_measure         := l_tld_tbl(l_index).unit_of_measure;
          l_u_instance_rec.instance_condition_id   := nvl(l_tld_tbl(l_index).item_condition_id,fnd_api.g_miss_num);
          l_u_instance_rec.sellable_flag           := nvl(l_tld_tbl(l_index).sellable_flag,fnd_api.g_miss_char);
          l_u_instance_rec.system_id               := nvl(l_tld_tbl(l_index).csi_system_id ,fnd_api.g_miss_num);
          l_u_instance_rec.instance_type_code      := nvl(l_tld_tbl(l_index).instance_type_code,fnd_api.g_miss_char);
          l_u_instance_rec.install_date            := nvl(l_tld_tbl(l_index).installation_date,fnd_api.g_miss_date);
          BEGIN
             IF NVL( p_instance_id , fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                SELECT active_start_date
                INTO   l_u_instance_rec.active_start_date
                FROM  csi_item_instances
                WHERE instance_id = p_instance_id;
              ELSE
                l_u_instance_rec.active_start_date       := nvl(l_tld_tbl(l_index).active_start_date,fnd_api.g_miss_date);
              END IF;
          EXCEPTION
            WHEN OTHERS THEN
             l_u_instance_rec.active_start_date       := nvl(l_tld_tbl(l_index).active_start_date,fnd_api.g_miss_date);
          END;

          l_u_instance_rec.active_end_date         := nvl(l_tld_tbl(l_index).active_end_date,fnd_api.g_miss_date);
          l_u_instance_rec.location_type_code      := 'HZ_PARTY_SITES';
          l_u_instance_rec.location_id             := l_party_site_id;
          l_u_instance_rec.return_by_date          := nvl(l_tld_tbl(l_index).return_by_date,fnd_api.g_miss_date);

          IF l_pty_dtl_tbl.COUNT > 0 THEN
            FOR l_p_ind IN l_pty_dtl_tbl.FIRST .. l_pty_dtl_tbl.LAST
            LOOP
              IF l_pty_dtl_tbl(l_p_ind).txn_line_details_index = l_index THEN
                 l_ind := l_ind + 1;
                 FOR l_pc_ind IN l_pty_dtl_tbl.FIRST .. l_pty_dtl_tbl.LAST
                 LOOP
                   IF l_pty_dtl_tbl(l_pc_ind).contact_flag = 'Y'
                      AND
                      l_pty_dtl_tbl(l_pc_ind).contact_party_id = l_p_ind
                  THEN
                  IF nvl(l_u_instance_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num Then

                    BEGIN
                      IF l_pty_dtl_tbl(l_p_ind).relationship_type_code = 'OWNER' THEN
                          SELECT instance_party_id
                          INTO   l_pty_dtl_tbl(l_pc_ind).contact_party_id
                          FROM   csi_i_parties
                          WHERE  instance_id = l_u_instance_rec.instance_id
                          AND    relationship_type_code = l_pty_dtl_tbl(l_p_ind).relationship_type_code
                          AND   ((active_end_date is null ) OR
                                 (active_end_date > sysdate));
                      ELSE
                          SELECT instance_party_id
                          INTO   l_pty_dtl_tbl(l_pc_ind).contact_party_id
                          FROM   csi_i_parties
                          WHERE  instance_id = l_u_instance_rec.instance_id
                          AND    party_id    = l_pty_dtl_tbl(l_p_ind).party_source_id -- old party
                          AND    party_source_table = l_pty_dtl_tbl(l_p_ind).party_source_table
                          AND    nvl(contact_flag,'N') = nvl(l_pty_dtl_tbl(l_p_ind).contact_flag,'N')
                          AND    relationship_type_code = l_pty_dtl_tbl(l_p_ind).relationship_type_code
                          AND   ((active_end_date is null ) OR
                                 (active_end_date > sysdate));
                       END IF;
                     EXCEPTION
                       WHEN no_data_found THEN
                         fnd_message.set_name('CSI','CSI_INT_INV_INSTA_PTY_ID');
                         fnd_message.set_token('INSTANCE_ID',l_u_instance_rec.instance_id);
                         fnd_message.set_token('RELATIONSHIP_TYPE_CODE',l_pty_dtl_tbl(l_p_ind).relationship_type_code);
                         fnd_msg_pub.add;
                         IF l_pty_dtl_tbl(l_p_ind).relationship_type_code = 'OWNER' THEN
                            x_return_status := fnd_api.g_ret_sts_error;
                            raise fnd_api.g_exc_error;
                         ELSE
                            l_pty_dtl_tbl(l_pc_ind).contact_party_id := l_ind;
                         END IF;
                       WHEN too_many_rows THEN
                         fnd_message.set_name('CSI','CSI_INT_MANY_INSTA_PTY_FOUND');
                         fnd_message.set_token('INSTANCE_ID',l_u_instance_rec.instance_id);
                         fnd_message.set_token('RELATIONSHIP_TYPE_CODE',l_pty_dtl_tbl(l_p_ind).relationship_type_code);
                         fnd_msg_pub.add;
                         x_return_status := fnd_api.g_ret_sts_error;
                         raise fnd_api.g_exc_error;
                     END;
                   ELSE
                     l_pty_dtl_tbl(l_pc_ind).contact_party_id := l_ind;
                   END IF;
                 END IF;
               END LOOP;
          END IF;
        END LOOP;
      END IF;

      IF l_org_assgn_tbl.COUNT > 0 THEN
        FOR l_oa_ind IN l_org_assgn_tbl.FIRST .. l_org_assgn_tbl.LAST
        LOOP
          IF l_org_assgn_tbl(l_oa_ind).txn_line_details_index = l_index THEN
            l_ou_ind := l_ou_ind + 1;
            l_u_org_units_tbl(l_ou_ind).instance_ou_id    := l_org_assgn_tbl(l_oa_ind).instance_ou_id;
            l_u_org_units_tbl(l_ou_ind).operating_unit_id := l_org_assgn_tbl(l_oa_ind).operating_unit_id;
            l_u_org_units_tbl(l_ou_ind).instance_id       := l_u_instance_rec.instance_id;
            l_u_org_units_tbl(l_ou_ind).relationship_type_code :=  l_org_assgn_tbl(l_oa_ind).relationship_type_code;
            l_u_org_units_tbl(l_ou_ind).active_start_date := l_org_assgn_tbl(l_oa_ind).active_start_date;
            l_u_org_units_tbl(l_ou_ind).active_end_date   := l_org_assgn_tbl(l_oa_ind).active_end_date;
            l_u_org_units_tbl(l_ou_ind).object_version_number := 1.0;
          END IF;
        END LOOP; -- org assignments loop
      END IF; -- org assignments count > 0
      END LOOP;  -- l_Index
    END IF;  -- l_tld_found = TRUE
    -- Modification end for 4091371

    l_u_instance_rec.cascade_ownership_flag := l_cascade_owner_flag;
    px_default_info_rec.cascade_owner_flag  := l_cascade_owner_flag;

    SELECT nvl(src_change_owner, 'N'),
           src_change_owner_to_code,
           src_status_id
    INTO   l_src_change_owner,
           l_src_change_owner_to_code,
           l_src_status_id
    FROM   csi_ib_txn_types
    WHERE  sub_type_id = l_sub_type_id;

    l_u_instance_rec.instance_status_id := nvl(l_src_status_id, fnd_api.g_miss_num);

    IF l_src_change_owner = 'Y' AND l_src_change_owner_to_code = 'E' THEN

      l_owner_party_id := px_default_info_rec.owner_party_id;

      SELECT instance_party_id,
             object_version_number
      INTO   l_instance_party_id,
             l_pty_object_ver_num
      FROM   csi_i_parties
      WHERE  instance_id = p_instance_id
      AND    relationship_type_code = 'OWNER';

      l_u_party_tbl(1).instance_party_id      := l_instance_party_id;
      l_u_party_tbl(1).instance_id            := p_instance_id;
      l_u_party_tbl(1).party_id               := l_owner_party_id;
      l_u_party_tbl(1).party_source_table     := 'HZ_PARTIES';
      l_u_party_tbl(1).relationship_type_code := 'OWNER';
      l_u_party_tbl(1).contact_flag           := 'N';
      l_u_party_tbl(1).object_version_number  :=  l_pty_object_ver_num;

      -- build owner account
      l_owner_account_id := px_default_info_rec.owner_party_acct_id;

      BEGIN
        SELECT ip_account_id,
               object_version_number
        INTO   l_ip_account_id,
               l_acct_object_ver_num
        FROM   csi_ip_accounts
        WHERE  instance_party_id      = l_instance_party_id
        AND    relationship_type_code = 'OWNER';
      EXCEPTION
        WHEN no_data_found THEN
          l_ip_account_id       := fnd_api.g_miss_num;
          l_acct_object_ver_num := 1;
      END;

      l_u_party_acct_tbl(1).ip_account_id          := l_ip_account_id;
      l_u_party_acct_tbl(1).party_account_id       := l_owner_account_id;
      l_u_party_acct_tbl(1).relationship_type_code := 'OWNER';
      l_u_party_acct_tbl(1).bill_to_address        := l_order_line_rec.invoice_to_org_id;
      l_u_party_acct_tbl(1).ship_to_address        := l_order_line_rec.ship_to_org_id;
      l_u_party_acct_tbl(1).active_end_date        := null;
      l_u_party_acct_tbl(1).instance_party_id      := l_instance_party_id;
      l_u_party_acct_tbl(1).parent_tbl_index       := 1;
      l_u_party_acct_tbl(1).object_version_number  := l_acct_object_ver_num;

    END IF;

    csi_t_gen_utility_pvt.dump_csi_instance_rec(
      p_csi_instance_rec => l_u_instance_rec);

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
      p_txn_rec               => px_csi_txn_rec,
      p_asset_assignment_tbl  => l_u_inst_asset_tbl,
      x_instance_id_lst       => l_u_inst_id_lst,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip issued instance converted to cp. instance_id : '||l_u_instance_rec.instance_id);


--added for the bug 5464761
/* this validation is done to make sure BOM Explosion happens only for the option items if any,
   also eliminating other regressions */
  IF  l_order_line_rec.item_type_code = 'OPTION' THEN

   check_and_explode_bom
  ( p_order_line_rec   =>p_order_line_rec,
    l_u_instance_rec   =>   l_u_instance_rec,
   px_csi_txn_rec      =>px_csi_txn_rec,
   x_return_status     =>l_return_status);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END convert_wip_instance_to_cp;

  PROCEDURE get_wip_instances(
    p_wip_entity_id      IN     number,
    p_inventory_item_id  IN     number,
    p_organization_id    IN     number,
    p_option_serial_code IN     number,
    p_config_rec         IN     config_rec,
    px_csi_txn_rec       IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_wip_instances         OUT nocopy wip_instances,
    x_return_status         OUT nocopy varchar2)
  IS

    CURSOR wip_nsrl_inst_cur(
      p_wip_entity_id     IN number,
      p_inventory_item_id IN number)
    IS
      SELECT instance_id,
             quantity,
             serial_number,
             location_type_code,
             instance_usage_code
      FROM   csi_item_instances
      WHERE  inventory_item_id  = p_inventory_item_id
      AND    ((location_type_code = 'WIP' AND  wip_job_id = p_wip_entity_id)
              OR
              (instance_usage_code = 'IN_RELATIONSHIP' AND last_wip_job_id = p_wip_entity_id));

    CURSOR wip_srl_inst_cur(
      p_wip_entity_id     IN number,
      p_inventory_item_id IN number)
    IS
      SELECT instance_id,
             quantity,
             serial_number,
             location_type_code,
             instance_usage_code
      FROM   csi_item_instances
      WHERE  inventory_item_id = p_inventory_item_id
      AND    ((location_type_code = 'WIP' AND wip_job_id  = p_wip_entity_id)
              OR
              (instance_usage_code = 'IN_RELATIONSHIP' AND last_wip_job_id = p_wip_entity_id));

    l_instances_found       boolean := FALSE;

    l_wip_instances         wip_instances;
    l_ind                   binary_integer := 0;

    n_wip_instances         wip_instances;
    n_ind                   binary_integer := 0;

    l_soi_instance_rec      csi_datastructures_pub.instance_rec;

    l_splitted_instances    csi_datastructures_pub.instance_tbl;
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_wip_instances');

    IF p_option_serial_code in (1, 6) THEN
      FOR wip_inst_rec IN wip_nsrl_inst_cur(
        p_wip_entity_id     => p_wip_entity_id,
        p_inventory_item_id => p_inventory_item_id)
      LOOP

        l_instances_found := TRUE;

        l_ind := l_ind + 1;
        l_wip_instances(l_ind).instance_id         := wip_inst_rec.instance_id;
        l_wip_instances(l_ind).quantity            := wip_inst_rec.quantity;
        l_wip_instances(l_ind).serial_number       := wip_inst_rec.serial_number;
        l_wip_instances(l_ind).location_type_code  := wip_inst_rec.location_type_code;
        l_wip_instances(l_ind).instance_usage_code := wip_inst_rec.instance_usage_code;
        l_wip_instances(l_ind).allocated_flag      := 'N';

      END LOOP;
    ELSIF p_option_serial_code IN (2,5) THEN
      FOR wip_inst_rec IN wip_srl_inst_cur(
        p_wip_entity_id     => p_wip_entity_id,
        p_inventory_item_id => p_inventory_item_id)
      LOOP

        l_instances_found := TRUE;

        l_ind := l_ind + 1;
        l_wip_instances(l_ind).instance_id         := wip_inst_rec.instance_id;
        l_wip_instances(l_ind).quantity            := wip_inst_rec.quantity;
        l_wip_instances(l_ind).serial_number       := wip_inst_rec.serial_number;
        l_wip_instances(l_ind).location_type_code  := wip_inst_rec.location_type_code;
        l_wip_instances(l_ind).instance_usage_code := wip_inst_rec.instance_usage_code;
        l_wip_instances(l_ind).allocated_flag      := 'N';

      END LOOP;
    END IF;

    IF NOT(l_instances_found) THEN

      fnd_message.set_name('CSI', 'CSI_NO_WIP_COMP_INSTANCE');
      fnd_message.set_token('INV_ITEM_ID', p_inventory_item_id);
      fnd_message.set_token('WIP_ENTITY_ID', p_wip_entity_id);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;
    END IF;


    IF p_option_serial_code = 6 THEN
      IF l_wip_instances.COUNT > 0 THEN
        FOR s_ind IN l_wip_instances.FIRST .. l_wip_instances.LAST
        LOOP
          IF l_wip_instances(s_ind).quantity > 1 THEN

            IF l_wip_instances(s_ind).location_type_code <> 'INVENTORY' THEN

              l_soi_instance_rec.instance_id         := l_wip_instances(s_ind).instance_id;
              l_soi_instance_rec.quantity            := l_wip_instances(s_ind).quantity;
              l_soi_instance_rec.instance_usage_code := l_wip_instances(s_ind).instance_usage_code;

              split_instances_using_copy(
                p_instance_rec   => l_soi_instance_rec,
                px_csi_txn_rec   => px_csi_txn_rec,
                x_instance_tbl   => l_splitted_instances,
                x_return_status  => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_splitted_instances.COUNT > 0 THEN
                FOR spl_ind IN l_splitted_instances.FIRST .. l_splitted_instances.LAST
                LOOP
                  n_ind := n_ind + 1;
                  n_wip_instances(n_ind).instance_id := l_splitted_instances(spl_ind).instance_id;
                  n_wip_instances(n_ind).quantity    := l_splitted_instances(spl_ind).quantity;
                  n_wip_instances(n_ind).location_type_code :=
                                         l_splitted_instances(spl_ind).location_type_code;
                  n_wip_instances(n_ind).instance_usage_code :=
                                         l_splitted_instances(spl_ind).instance_usage_code;
                  n_wip_instances(n_ind).allocated_flag := 'N';
                END LOOP;
              END IF;
            END IF;
          ELSE
            n_ind := n_ind + 1;
            n_wip_instances(n_ind) := l_wip_instances(s_ind);
          END IF;
        END LOOP;
        l_wip_instances := n_wip_instances;
      END IF;
    END IF;

    -- just the debug
    IF l_wip_instances.COUNT > 0 THEN
      FOR d_ind IN l_wip_instances.FIRST .. l_wip_instances.LAST
      LOOP
        debug('wip instances record # '||d_ind);
        debug('  instance_id        : '||l_wip_instances(d_ind).instance_id);
        debug('  quantity           : '||l_wip_instances(d_ind).quantity);
        debug('  serial_number      : '||l_wip_instances(d_ind).serial_number);
        debug('  instance_usage_code: '||l_wip_instances(d_ind).instance_usage_code);
        debug('  location_type_code : '||l_wip_instances(d_ind).location_type_code);
      END LOOP;
    END IF;
    x_wip_instances := l_wip_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_wip_instances;

  PROCEDURE get_wip_instances_for_line(
    p_option_line_rec    IN     oe_order_lines_all%rowtype,
    p_parent_line_rec    IN     oe_order_pub.line_rec_type,
    p_option_serial_code IN     number,
    p_class_option_ratio IN     number,
    p_config_rec         IN     config_rec,
    p_config_instances   IN     config_serial_inst_tbl,
    px_csi_txn_rec       IN OUT nocopy csi_datastructures_pub.transaction_rec,
    px_wip_instances     IN OUT nocopy wip_instances,
    x_return_status         OUT nocopy varchar2)
  IS
    l_ratio                 number;
    l_wip_instances         wip_instances;
    l_in_rel_wip_instances  wip_instances;
    l_temp_wip_instances    wip_instances;
    l_tot_wip_inst_qty      number := 0;

    l_parent_instance_id    number;

    l_n_wip_instance        wip_instance;
    n_ind                   binary_integer := 0;
    l_n_wip_instances       wip_instances;
    l_splitted_instances    csi_datastructures_pub.instance_tbl;
    l_option_count          number := 0;

    l_new_instance_rec      csi_datastructures_pub.instance_rec;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;

    FUNCTION tot_wip_inst_qty(
      p_wip_instances IN wip_instances)
    RETURN number
    IS
      l_total number := 0;
    BEGIN
      IF p_wip_instances.COUNT > 0 THEN
        FOR l_ind IN p_wip_instances.FIRST ..p_wip_instances.LAST
        LOOP
          l_total := l_total + p_wip_instances(l_ind).quantity;
        END LOOP;
      END IF;
      RETURN l_total;
    END tot_wip_inst_qty;

    PROCEDURE get_in_rel_options (
      p_config_instances IN     config_serial_inst_tbl,
      px_wip_instances   IN OUT nocopy wip_instances,
      x_return_status       OUT nocopy varchar2)
    IS
      n_ind                 binary_integer:= 0;
      l_n_wip_instances     wip_instances;
      l_parent_instance_id  number;
    BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      api_log('get_in_rel_options');
      IF px_wip_instances.count > 0 THEN
        FOR l_ind IN px_wip_instances.FIRST ..px_wip_instances.LAST
        LOOP

          IF px_wip_instances(l_ind).instance_usage_code = 'IN_RELATIONSHIP' THEN

            SELECT object_id
            INTO   l_parent_instance_id
            FROM   csi_ii_relationships
            WHERE  subject_id = px_wip_instances(l_ind).instance_id
            AND    relationship_type_code = 'COMPONENT-OF'
            AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                           AND     nvl(active_end_date, sysdate+1);

            IF p_config_instances.COUNT > 0 THEN
              FOR c_ind IN p_config_instances.FIRST .. p_config_instances.LAST
              LOOP
                IF p_config_instances(c_ind).instance_id =  l_parent_instance_id THEN
                  n_ind := n_ind + 1;
                  l_n_wip_instances(n_ind) := px_wip_instances(l_ind);
                END IF;
              END LOOP;
            END IF;

          END IF;
        END LOOP;
      END IF;
      debug('  in_rel_options.count : '||l_n_wip_instances.COUNT);
      px_wip_instances := l_n_wip_instances;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END get_in_rel_options;

    PROCEDURE mark_and_get(
      px_wip_instances  IN OUT nocopy wip_instances,
      x_wip_instance       OUT nocopy wip_instance)
    IS
      l_ind binary_integer := 0;
    BEGIN
      IF px_wip_instances.COUNT > 0 THEN
        l_ind := 0;
        LOOP
          l_ind := px_wip_instances.NEXT(l_ind);
          EXIT WHEN l_ind is null;
          x_wip_instance := px_wip_instances(l_ind);
          px_wip_instances.DELETE(l_ind);
          EXIT;
        END LOOP;
      END IF;
    END mark_and_get;

    PROCEDURE filter_processed_options(
      p_split_from_line_id   IN number,
      p_inventory_item_id    IN number,
      px_wip_instances       IN OUT nocopy wip_instances)
    IS
      l_wip_instances  wip_instances;
      l_ind            binary_integer := 0;
      px_ind           binary_integer := 0;
      CURSOR inst_cur IS
        SELECT instance_id
        FROM   csi_item_instances
        WHERE  inventory_item_id     = p_inventory_item_id
        AND    last_oe_order_line_id = p_split_from_line_id;
    BEGIN
      IF px_wip_instances.COUNT > 0 THEN
        FOR inst_rec IN inst_cur
        LOOP

          px_ind := 0;
          LOOP
            px_ind := px_wip_instances.NEXT(px_ind);
            EXIT WHEN px_ind is null;
            IF px_wip_instances(px_ind).instance_id = inst_rec.instance_id THEN
              px_wip_instances.DELETE(px_ind);
            END IF;
          END LOOP;

        END LOOP;
      END IF;

      IF px_wip_instances.COUNT > 0 THEN
        px_ind := 0;
        LOOP
          px_ind := px_wip_instances.NEXT(px_ind);
          EXIT WHEN px_ind is null;
          l_ind := l_ind + 1;
          l_wip_instances(l_ind) := px_wip_instances(px_ind);
        END LOOP;
      END IF;

      px_wip_instances := l_wip_instances;

    END filter_processed_options;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_wip_instances_for_line');

    l_wip_instances := px_wip_instances;

    -- order short closed when under shipped. bug 3690762
    IF p_option_line_rec.fulfilled_quantity <> p_option_line_rec.ordered_quantity THEN
      l_option_count := p_option_line_rec.fulfilled_quantity;
    ELSE
      l_option_count := p_option_line_rec.ordered_quantity;
    END IF;

    IF p_config_rec.serial_code in (2, 5) THEN

      -- as the relations will be built at wip we need to get the options that was tied in
      -- a component of relation at wip
      l_in_rel_wip_instances := l_wip_instances;

      get_in_rel_options(
        p_config_instances => p_config_instances,
        px_wip_instances   => l_in_rel_wip_instances,
        x_return_status    => l_return_status);
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      --fix for bug 4705806:If all the option instances for the order line are not in_rel
      --we pick instances left in wip and convert them into CP
      IF l_in_rel_wip_instances.COUNT <> l_option_count THEN
        debug('In_rel option count <> order line quantity,so picking option instances in_wip');
        n_ind := l_in_rel_wip_instances.COUNT;
        FOR l_ind IN l_wip_instances.FIRST ..l_wip_instances.LAST
        LOOP
        EXIT WHEN l_in_rel_wip_instances.COUNT >= l_option_count;
             IF l_wip_instances(l_ind).instance_usage_code = 'IN_WIP' THEN
                  n_ind := n_ind + 1;
                  l_in_rel_wip_instances(n_ind) := px_wip_instances(l_ind);
             END IF;
        END LOOP;
      END IF;
      debug('in_rel + in_wip options.count : '||l_in_rel_wip_instances.COUNT);
      --end of fix 4705806


      px_wip_instances := l_in_rel_wip_instances;

    END IF;

    -- config item is non serialized/serialized at so issue
    IF p_config_rec.serial_code IN (1, 6) OR l_in_rel_wip_instances.COUNT = 0 THEN

      -- filter out the wip instances that were processed for a split from order line
      IF p_option_line_rec.split_from_line_id is not null THEN
        filter_processed_options(
          p_split_from_line_id => p_option_line_rec.split_from_line_id,
          p_inventory_item_id  => p_option_line_rec.inventory_item_id,
          px_wip_instances     => l_wip_instances);
      END IF;

      IF p_option_serial_code in (2, 5, 6) THEN

        l_temp_wip_instances := l_wip_instances;
        FOR ind IN 1 .. l_option_count
        LOOP
          mark_and_get(
            px_wip_instances => l_temp_wip_instances,
            x_wip_instance   => l_n_wip_instance);
          IF nvl(l_n_wip_instance.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
            n_ind := n_ind + 1;
            l_n_wip_instances(n_ind) := l_n_wip_instance;
          END IF;
        END LOOP;

        px_wip_instances := l_n_wip_instances;

      ELSE -- option is non serial case
        IF l_wip_instances.COUNT > 0 THEN

          l_tot_wip_inst_qty := tot_wip_inst_qty(l_wip_instances);

          IF p_parent_line_rec.ordered_quantity = 1 THEN
            IF l_tot_wip_inst_qty > p_option_line_rec.fulfilled_quantity THEN
              --split the wip instance to take the order quantity out for this line
              --if it is an over issue case the excess stays in WIP
              IF l_wip_instances.COUNT = 1 THEN

                split_instance(
                  p_instance_id   => l_wip_instances(1).instance_id,
                  p_quantity      => p_option_line_rec.fulfilled_quantity,
                  px_csi_txn_rec  => px_csi_txn_rec,
                  x_instance_rec  => l_new_instance_rec,
                  x_return_status => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                n_ind := n_ind + 1;
                l_n_wip_instances(n_ind).instance_id   := l_new_instance_rec.instance_id;
                l_n_wip_instances(n_ind).quantity      := l_new_instance_rec.quantity;
                l_n_wip_instances(n_ind).location_type_code
                                         := l_new_instance_rec.location_type_code;
                l_n_wip_instances(n_ind).instance_usage_code
                                         := l_new_instance_rec.instance_usage_code;
                l_n_wip_instances(n_ind).allocated_flag:= 'N';

                px_wip_instances := l_n_wip_instances;
              ELSE
                -- this needs to be fixed. change with a logic to loop thru the
                -- instances and get only the fullfilled quantity equivalent
                px_wip_instances := l_wip_instances;
              END IF;
            ELSE
              px_wip_instances := l_wip_instances;
            END IF;

          ELSE -- parent ordered quantity > 1

            l_ratio := p_option_line_rec.ordered_quantity/p_parent_line_rec.ordered_quantity;

            IF l_wip_instances.COUNT = 1 THEN

              split_instance_using_ratio(
                p_instance_id         => l_wip_instances(1).instance_id,
                p_qty_ratio           => l_ratio,
                p_parent_qty          => p_parent_line_rec.ordered_quantity,
                p_organization_id     => p_option_line_rec.ship_from_org_id,
                px_csi_txn_rec        => px_csi_txn_rec,
                x_splitted_instances  => l_splitted_instances,
                x_return_status       => l_return_status);

              IF l_return_status <> fnd_Api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_splitted_instances.COUNT > 0 THEN
                FOR l_ind IN l_splitted_instances.FIRST .. l_splitted_instances.LAST
                LOOP
                  n_ind := n_ind + 1;
                  l_n_wip_instances(n_ind).instance_id   := l_splitted_instances(l_ind).instance_id;
                  l_n_wip_instances(n_ind).quantity      := l_splitted_instances(l_ind).quantity;
                  l_n_wip_instances(n_ind).location_type_code :=
                                           l_splitted_instances(l_ind).location_type_code;
                  l_n_wip_instances(n_ind).instance_usage_code :=
                                           l_splitted_instances(l_ind).instance_usage_code;
                  l_n_wip_instances(n_ind).allocated_flag:= 'N';
                END LOOP;
              END IF;

              IF p_option_line_rec.fulfilled_quantity <> p_option_line_rec.ordered_quantity THEN

                l_temp_wip_instances.DELETE;
                l_temp_wip_instances := l_n_wip_instances;

                l_n_wip_instances.DELETE;
                n_ind := 0;

                FOR l_ind IN 1 .. (p_option_line_rec.fulfilled_quantity/l_ratio)
                LOOP
                  mark_and_get(
                    px_wip_instances => l_temp_wip_instances,
                    x_wip_instance   => l_n_wip_instance);

                  IF nvl(l_n_wip_instance.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                    n_ind := n_ind + 1;
                    l_n_wip_instances(n_ind) := l_n_wip_instance;
                  END IF;
                END LOOP;
                px_wip_instances := l_n_wip_instances;
              ELSE
                px_wip_instances := l_n_wip_instances;
              END IF;

            ELSE

              IF l_wip_instances.COUNT > 0 THEN
                FOR l_ind IN l_wip_instances.FIRST .. l_wip_instances.LAST
                LOOP

                  IF l_wip_instances(l_ind).quantity > l_ratio THEN

                    split_instance_using_ratio(
                      p_instance_id         => l_wip_instances(l_ind).instance_id,
                      p_qty_ratio           => l_ratio,
                      p_parent_qty          => p_parent_line_rec.ordered_quantity,
                      p_organization_id     => p_option_line_rec.ship_from_org_id,
                      px_csi_txn_rec        => px_csi_txn_rec,
                      x_splitted_instances  => l_splitted_instances,
                      x_return_status       => l_return_status);

                    IF l_return_status <> fnd_Api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    IF l_splitted_instances.COUNT > 0 THEN
                      FOR l_ind IN l_splitted_instances.FIRST .. l_splitted_instances.LAST
                      LOOP
                        n_ind := n_ind + 1;
                        l_n_wip_instances(n_ind).instance_id   := l_splitted_instances(l_ind).instance_id;
                        l_n_wip_instances(n_ind).quantity      := l_splitted_instances(l_ind).quantity;
                        l_n_wip_instances(n_ind).location_type_code :=
                                                 l_splitted_instances(l_ind).location_type_code;
                        l_n_wip_instances(n_ind).instance_usage_code :=
                                                 l_splitted_instances(l_ind).instance_usage_code;
                        l_n_wip_instances(n_ind).allocated_flag:= 'N';
                      END LOOP;
                    END IF;
                  ELSE
                    n_ind := n_ind + 1;
                    l_n_wip_instances(n_ind) := l_wip_instances(l_ind);
                  END IF;
                END LOOP;
              END IF;

              IF p_option_line_rec.fulfilled_quantity <> p_option_line_rec.ordered_quantity THEN

                l_temp_wip_instances.DELETE;
                l_temp_wip_instances := l_n_wip_instances;
                l_n_wip_instances.DELETE;
                n_ind := 0;

                FOR l_ind IN 1 .. (p_option_line_rec.fulfilled_quantity/l_ratio)
                LOOP
                  mark_and_get(
                    px_wip_instances => l_temp_wip_instances,
                    x_wip_instance   => l_n_wip_instance);

                  IF nvl(l_n_wip_instance.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                    n_ind := n_ind + 1;
                    l_n_wip_instances(n_ind) := l_n_wip_instance;
                  END IF;
                END LOOP;

                px_wip_instances := l_n_wip_instances;

              ELSE
                px_wip_instances := l_n_wip_instances;
              END IF;
            END IF;

          END IF;
        END IF;
      END IF;
    END IF; -- serial/ non serial configured item

    -- just the debug
    IF px_wip_instances.COUNT > 0 THEN
      FOR d_ind IN px_wip_instances.FIRST .. px_wip_instances.LAST
      LOOP
        debug('wip instances record # '||d_ind);
        debug('  instance_id        : '||px_wip_instances(d_ind).instance_id);
        debug('  quantity           : '||px_wip_instances(d_ind).quantity);
        debug('  serial_number      : '||px_wip_instances(d_ind).serial_number);
        debug('  instance_usage_code: '||px_wip_instances(d_ind).instance_usage_code);
        debug('  location_type_code : '||px_wip_instances(d_ind).location_type_code);
      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_wip_instances_for_line;

  -- enhancements to be made in the genealogy area in this routine
  PROCEDURE distribute_wip_instances(
    p_qty_ratio          IN         number,
    p_option_serial_code IN         number,
    p_parent_line_rec    IN         oe_order_pub.line_rec_type,
    p_parent_instances   IN         parent_instances,
    p_wip_instances      IN         wip_instances,
    px_default_info_rec  IN OUT nocopy default_info_rec,
    x_ii_rltns_tbl          OUT nocopy csi_datastructures_pub.ii_relationship_tbl,
    x_return_status         OUT nocopy varchar2)
  IS

    l_parent_instances       parent_instances;
    l_wip_instances          wip_instances;
    l_alloc_wip_instance     wip_instance;
    ii_ind                   binary_integer := 0;
    l_ii_rltns_tbl           csi_datastructures_pub.ii_relationship_tbl;

    PROCEDURE mark_and_get(
      p_parent_instance    IN            parent_instance,
      px_wip_instances     IN OUT NOCOPY wip_instances,
      x_alloc_wip_instance    OUT NOCOPY wip_instance)
    IS
    BEGIN
      IF px_wip_instances.COUNT > 0 THEN
        FOR l_ind IN px_wip_instances.FIRST .. px_wip_instances.LAST
        LOOP
          IF px_wip_instances(l_ind).allocated_flag = 'N' THEN
            px_wip_instances(l_ind).allocated_flag := 'Y';
            x_alloc_wip_instance := px_wip_instances(l_ind);
            exit;
          END IF;
        END LOOP;
      END IF;
    END mark_and_get;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('distribute_wip_instances');

    l_parent_instances := p_parent_instances;
    l_wip_instances    := p_wip_instances;

    IF p_option_serial_code = 1 THEN
      IF l_parent_instances.COUNT > 0 THEN
        FOR p_ind IN l_parent_instances.FIRST .. l_parent_instances.LAST
        LOOP

          mark_and_get(
            p_parent_instance    => l_parent_instances(p_ind),
            px_wip_instances     => l_wip_instances,
            x_alloc_wip_instance => l_alloc_wip_instance);

          ii_ind := ii_ind + 1;
          l_ii_rltns_tbl(ii_ind).subject_id  := l_alloc_wip_instance.instance_id;
          l_ii_rltns_tbl(ii_ind).object_id   := l_parent_instances(p_ind).instance_id;
          l_ii_rltns_tbl(ii_ind).relationship_type_code := 'COMPONENT-OF';
          l_ii_rltns_tbl(ii_ind).cascade_ownership_flag := px_default_info_rec.cascade_owner_flag;

        END LOOP;
      END IF;
    ELSE
      IF l_parent_instances.COUNT > 0 THEN
        FOR p_ind IN l_parent_instances.FIRST .. l_parent_instances.LAST
        LOOP

          FOR r_ind IN 1..p_qty_ratio
          LOOP

            mark_and_get(
              p_parent_instance    => l_parent_instances(p_ind),
              px_wip_instances     => l_wip_instances,
              x_alloc_wip_instance => l_alloc_wip_instance);

            ii_ind := ii_ind + 1;
            l_ii_rltns_tbl(ii_ind).subject_id  := l_alloc_wip_instance.instance_id;
            l_ii_rltns_tbl(ii_ind).object_id   := l_parent_instances(p_ind).instance_id;
            l_ii_rltns_tbl(ii_ind).relationship_type_code := 'COMPONENT-OF';
            l_ii_rltns_tbl(ii_ind).cascade_ownership_flag := px_default_info_rec.cascade_owner_flag;

          END LOOP;

        END LOOP;
      END IF;
    END IF;

    x_ii_rltns_tbl := l_ii_rltns_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END distribute_wip_instances;

  PROCEDURE make_or_buy_from_unit_txn(
    p_serial_number     IN varchar2,
    p_inventory_item_id IN number,
    p_sub_config_flag   IN varchar2,
    px_config_rec       IN OUT nocopy config_rec,
    x_make_or_buy_flag     OUT nocopy varchar2)
  IS
    CURSOR all_txn_cur(
      p_serial_number  in varchar2,
      p_item_id        in number)
    IS
      SELECT mmt.creation_date               mtl_creation_date,
             mmt.transaction_id              mtl_txn_id,
             to_char(mmt.transaction_date,'dd-mm-yyyy hh24:mi:ss') mtl_txn_date,
             mmt.organization_id             organization_id,
             mmt.transaction_type_id         mtl_type_id,
             mtt.transaction_type_name       mtl_txn_name,
             mmt.transaction_action_id       mtl_action_id,
             mmt.transaction_source_type_id  mtl_source_type_id,
             mmt.transaction_source_id       mtl_source_id
      FROM   mtl_unit_transactions     mut,
             mtl_material_transactions mmt,
             mtl_transaction_types     mtt
      WHERE  mut.serial_number       = p_serial_number
      AND    mut.inventory_item_id   = p_item_id
      AND    mmt.transaction_id      = mut.transaction_id
      AND    mtt.transaction_type_id = mmt.transaction_type_id
      UNION
      SELECT mmt.creation_date               mtl_creation_date,
             mmt.transaction_id              mtl_txn_id,
             to_char(mmt.transaction_date,'dd-mm-yy hh24:mi:ss') mtl_txn_date,
             mmt.organization_id             organization_id,
             mmt.transaction_type_id         mtl_type_id,
             mtt.transaction_type_name       mtl_txn_name,
             mmt.transaction_action_id       mtl_action_id,
             mmt.transaction_source_type_id  mtl_source_type_id,
             mmt.transaction_source_id       mtl_source_id
      FROM   mtl_unit_transactions       mut,
             mtl_transaction_lot_numbers mtln,
             mtl_material_transactions   mmt,
             mtl_transaction_types       mtt
      WHERE  mut.serial_number          = p_serial_number
      AND    mut.inventory_item_id      = p_item_id
      AND    mtln.serial_transaction_id = mut.transaction_id
      AND    mmt.transaction_id         = mtln.transaction_id
      AND    mtt.transaction_type_id    = mmt.transaction_type_id
      ORDER BY 1 desc,  2 desc;
  BEGIN
    FOR all_txn_rec IN all_txn_cur(
      p_serial_number  => p_serial_number,
      p_item_id        => p_inventory_item_id)
    LOOP
      debug('    '||all_txn_cur%rowcount||
            '.  '||all_txn_rec.mtl_txn_date||
            '  '||all_txn_rec.mtl_txn_name);
      IF (all_txn_rec.mtl_source_type_id = 5 AND all_txn_rec.mtl_action_id = 31)
          OR
         (all_txn_rec.mtl_source_type_id = 1 AND all_txn_rec.mtl_action_id = 27)
      THEN
        IF all_txn_rec.mtl_source_type_id = 5 THEN

          x_make_or_buy_flag := 'M';
          IF p_sub_config_flag = 'N' THEN
            px_config_rec.config_wip_job_id := all_txn_rec.mtl_source_id;
            px_config_rec.config_wip_org_id := all_txn_rec.organization_id;
          ELSE
            px_config_rec.sub_config_wip_job_id := all_txn_rec.mtl_source_id;
            px_config_rec.sub_config_wip_org_id := all_txn_rec.organization_id;
          END IF;
        ELSE
          x_make_or_buy_flag := 'B';
        END IF;
        exit;
      END IF;
    END LOOP;
  END make_or_buy_from_unit_txn;

  PROCEDURE get_wip_info_from_txn(
    px_config_rec     IN OUT nocopy config_rec)
  IS

    CURSOR config_srl_cur (
      p_line_id        in number,
      p_item_id        in number)
    IS
      SELECT instance_id,
             serial_number
      FROM   csi_item_instances
      WHERE  inventory_item_id     = p_item_id
      AND    last_oe_order_line_id = p_line_id;

    l_make_or_buy_flag varchar2(1) := 'B';
  BEGIN
    api_log('get_wip_info_from_txn');
    FOR config_srl_rec in config_srl_cur(
      p_line_id => px_config_rec.line_id,
      p_item_id => px_config_rec.item_id)
    LOOP
      make_or_buy_from_unit_txn(
        p_serial_number     => config_srl_rec.serial_number,
        p_inventory_item_id => px_config_rec.item_id,
        p_sub_config_flag   => 'N',
        px_config_rec       => px_config_rec,
        x_make_or_buy_flag  => l_make_or_buy_flag);
      exit;
    END LOOP;
  END get_wip_info_from_txn;

  PROCEDURE get_job_for_config_line(
    p_config_rec           IN  config_rec,
    x_wip_entity_id        OUT nocopy number,
    x_wip_organization_id  OUT nocopy number,
    x_request_id           OUT nocopy number)
  IS

    l_job_found boolean := FALSE;

    CURSOR all_job_cur(p_source_line_id IN number) IS
      SELECT wip_entity_id,
             organization_id,
             request_id
      FROM   wip_discrete_jobs
      WHERE  primary_item_id = p_config_rec.item_id
      AND    organization_id = p_config_rec.ship_organization_id
      AND    source_line_id  = p_source_line_id
      AND    status_type    <> 7  -- excluding the cancelled wip jobs
      ORDER  by wip_entity_id desc;

  BEGIN

    l_job_found := FALSE;

    FOR all_job_rec IN all_job_cur(p_config_rec.line_id)
    LOOP
      x_wip_entity_id       := all_job_rec.wip_entity_id;
      x_wip_organization_id := all_job_rec.organization_id;
      x_request_id          := all_job_rec.request_id;
      l_job_found           := TRUE;
      exit;
    END LOOP;

    IF NOT(l_job_found) AND p_config_rec.split_from_line_id IS NOT null THEN
      FOR all_job_rec IN all_job_cur(p_config_rec.split_from_line_id)
      LOOP
        x_wip_entity_id       := all_job_rec.wip_entity_id;
        x_wip_organization_id := all_job_rec.organization_id;
        x_request_id          := all_job_rec.request_id;
        l_job_found           := TRUE;
        exit;
      END LOOP;
    END IF;

  END get_job_for_config_line;

  PROCEDURE get_sub_model_wip_info(
    px_config_rec            IN OUT nocopy config_rec,
    x_return_status             OUT nocopy varchar2)
  IS
    l_config_rec         config_rec;
    l_make_or_buy_flag   varchar2(1);

    CURSOR issued_srl_cur IS
      SELECT mut.serial_number,
             mut.inventory_item_id
      FROM   mtl_material_transactions mmt,
             mtl_unit_transactions     mut
      WHERE  mmt.transaction_source_type_id = 5
      AND    mmt.transaction_action_id      = 1
      AND    mmt.inventory_item_id          = px_config_rec.sub_config_item_id
      AND    mmt.transaction_source_id      = px_config_rec.config_wip_job_id
      AND    mut.transaction_id             = mmt.transaction_id
      AND    mut.inventory_item_id          = mmt.inventory_item_id
      UNION
      SELECT mut.serial_number,
             mut.inventory_item_id
      FROM   mtl_material_transactions   mmt,
             mtl_transaction_lot_numbers mtln,
             mtl_unit_transactions       mut
      WHERE  mmt.transaction_source_type_id = 5
      AND    mmt.transaction_action_id      = 1
      AND    mmt.inventory_item_id          = px_config_rec.sub_config_item_id
      AND    mmt.transaction_source_id      = px_config_rec.config_wip_job_id
      AND    mtln.transaction_id            = mmt.transaction_id
      AND    mtln.inventory_item_id         = mmt.inventory_item_id
      AND    mut.transaction_id             = mtln.serial_transaction_id
      AND    mut.inventory_item_id          = mtln.inventory_item_id;

  BEGIN
    l_config_rec := px_config_rec;

    SELECT serial_number_control_code
    INTO   l_config_rec.sub_model_serial_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = l_config_rec.sub_config_item_id
    AND    organization_id   = l_config_rec.ship_organization_id;

    IF l_config_rec.sub_model_serial_code in (2, 5) THEN
      debug('  sub model is either serialized at receipt/predefined.');
      FOR issued_srl_rec IN issued_srl_cur
      LOOP
        -- for each of the serial get the completion transaction
        make_or_buy_from_unit_txn(
          p_serial_number     => issued_srl_rec.serial_number,
          p_inventory_item_id => issued_srl_rec.inventory_item_id,
          p_sub_config_flag   => 'Y',
          px_config_rec       => l_config_rec,
          x_make_or_buy_flag  => l_make_or_buy_flag);
        exit;
      END LOOP;
      IF l_make_or_buy_flag = 'M' THEN
        l_config_rec.sub_config_make_flag := 'Y';
      ELSE
        l_config_rec.sub_config_make_flag := 'N';
      END IF;
    ELSE
      debug('  sub model is either non serialized/at so issue.');
      BEGIN
        SELECT wip_entity_id,
               organization_id
        INTO   l_config_rec.sub_config_wip_job_id,
               l_config_rec.sub_config_wip_org_id
        FROM   wip_discrete_jobs
        WHERE  primary_item_id = l_config_rec.sub_config_item_id
        AND    request_id      = l_config_rec.request_id
        AND    rownum = 1;
          l_config_rec.sub_config_make_flag := 'Y';
      EXCEPTION
        WHEN no_data_found THEN
          l_config_rec.sub_config_make_flag := 'N';
      END;
    END IF;

    px_config_rec := l_config_rec;

  END get_sub_model_wip_info;

  PROCEDURE get_config_info(
    p_line_id            IN     number,
    p_ato_header_id      IN     number,
    p_ato_line_id        IN     number,
    px_default_info_rec  IN OUT nocopy default_info_rec,
    x_config_rec            OUT nocopy config_rec,
    x_return_status         OUT nocopy varchar2)
  IS

    l_config_rec          config_rec;
    l_wip_found           boolean := FALSE;
    l_parent_ato_line_id  number;
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_info');

    BEGIN
      SELECT oel.line_id,
             oel.inventory_item_id,
             oel.ship_from_org_id,
             oel.ordered_quantity,
             oel.split_from_line_id
      INTO   l_config_rec.line_id,
             l_config_rec.item_id,
             l_config_rec.ship_organization_id,
             l_config_rec.order_quantity,
             l_config_rec.split_from_line_id
      FROM   oe_order_lines_all  oel
      WHERE  oel.header_id         = p_ato_header_id
      AND    oel.link_to_line_id   = p_ato_line_id
      AND    oel.item_type_code    = 'CONFIG';
    EXCEPTION
      WHEN no_data_found THEN
        null;
      WHEN too_many_rows THEN
        SELECT oel.line_id,
               oel.inventory_item_id,
               oel.ship_from_org_id,
               oel.ordered_quantity,
               oel.split_from_line_id
        INTO   l_config_rec.line_id,
               l_config_rec.item_id,
               l_config_rec.ship_organization_id,
               l_config_rec.order_quantity,
               l_config_rec.split_from_line_id
        FROM   oe_order_lines_all  oel
        WHERE  oel.header_id         = p_ato_header_id
        AND    oel.link_to_line_id   = p_ato_line_id
        AND    oel.item_type_code    = 'CONFIG'
        AND    oel.split_from_line_id is null;

    END;

    IF l_config_rec.line_id is not null THEN

      SELECT serial_number_control_code
      INTO   l_config_rec.serial_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_config_rec.item_id
      AND    organization_id   = l_config_rec.ship_organization_id;

      get_job_for_config_line(
        p_config_rec           => l_config_rec,
        x_wip_entity_id        => l_config_rec.config_wip_job_id,
        x_wip_organization_id  => l_config_rec.config_wip_org_id,
        x_request_id           => l_config_rec.request_id);

      IF l_config_rec.config_wip_job_id is null THEN
        IF l_config_rec.serial_code in (2, 5) THEN
          get_wip_info_from_txn(
            px_config_rec  => l_config_rec);
        END IF;
      END IF;

    END IF;

    IF l_config_rec.config_wip_job_id is not null THEN
      l_config_rec.make_flag := 'Y';
    ELSE
      l_config_rec.make_flag := 'N';
    END IF;

    IF l_config_rec.make_flag = 'Y' THEN
      BEGIN

        SELECT parent_ato_line_id
        INTO   l_parent_ato_line_id
        FROM   bom_cto_order_lines
        WHERE  line_id     = p_line_id;

        IF l_parent_ato_line_id is not null THEN

          IF l_parent_ato_line_id <> p_ato_line_id THEN
            l_config_rec.sub_model_flag    := 'Y';
            l_config_rec.sub_model_line_id := l_parent_ato_line_id;
          ELSIF px_default_info_rec.identified_item_type = 'ATO_SUB_MODEL' THEN
            l_config_rec.sub_model_flag    := 'Y';
            l_config_rec.sub_model_line_id := p_line_id;
          ELSE
            l_config_rec.sub_model_flag := 'N';
          END IF;

          IF l_config_rec.sub_model_flag = 'Y' THEN

            SELECT config_item_id,
                   wip_supply_type
            INTO   l_config_rec.sub_config_item_id,
                   l_config_rec.sub_model_wip_supply_type
            FROM   bom_cto_order_lines
            WHERE  line_id = l_config_rec.sub_model_line_id;

            IF l_config_rec.sub_config_item_id is not null
               AND
               l_config_rec.sub_model_wip_supply_type <> 6
            THEN
              get_sub_model_wip_info(
                px_config_rec   => l_config_rec,
                x_return_status => l_return_status);
              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            ELSE
              l_config_rec.sub_config_make_flag := 'N';
            END IF;

          END IF;

        ELSE
          l_config_rec.sub_model_flag := 'N';
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
         l_config_rec.sub_model_flag := 'N';
      END;

    END IF;

    debug('  config_line_id     : '||l_config_rec.line_id);
    debug('  config_item_id     : '||l_config_rec.item_id);
    debug('  config_serial_code : '||l_config_rec.serial_code);
    debug('  config_ord_qty     : '||l_config_rec.order_quantity);
    debug('  config_ship_org_id : '||l_config_rec.ship_organization_id);
    debug('  config_wip_job_id  : '||l_config_rec.config_wip_job_id);
    debug('  config_wip_org_id  : '||l_config_rec.config_wip_org_id);
    debug('  make_flag          : '||l_config_rec.make_flag);
    debug('  sub_model_flag     : '||l_config_rec.sub_model_flag);
    IF l_config_rec.sub_model_flag = 'Y' THEN
      debug('  sub_mdl_line_id    : '||l_config_rec.sub_model_line_id);
      debug('  sub_mdl_wip_supply : '||l_config_rec.sub_model_wip_supply_type);
      debug('  sub_cfg_item_id    : '||l_config_rec.sub_config_item_id);
      debug('  sub_cfg_serial_code: '||l_config_rec.sub_model_serial_code);
      debug('  sub_cfg_wip_job_id : '||l_config_rec.sub_config_wip_job_id);
      debug('  sub_cfg_wip_org_id : '||l_config_rec.sub_config_wip_org_id);
      debug('  sub_cfg_make_flag  : '||l_config_rec.sub_config_make_flag);
    END IF;

    x_config_rec := l_config_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_info;

  PROCEDURE get_config_nsrl_instances(
    p_config_rec         IN         config_rec,
    p_sub_config_flag    IN         varchar2,
    x_config_instances   OUT NOCOPY config_serial_inst_tbl,
    x_return_status      OUT NOCOPY varchar2)
  IS
    CURSOR config_inst_cur IS
      SELECT instance_id,
             location_type_code
      FROM   csi_item_instances
      WHERE  inventory_item_id     = p_config_rec.item_id
      AND    last_oe_order_line_id = p_config_rec.line_id;

    l_c_ind              binary_integer := 0;
    l_config_instances   config_serial_inst_tbl;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_nsrl_instances');
    FOR config_inst_rec IN config_inst_cur
    LOOP
      l_c_ind := l_c_ind + 1;
      l_config_instances(l_c_ind).instance_id        := config_inst_rec.instance_id;
      l_config_instances(l_c_ind).location_type_code := config_inst_rec.location_type_code;
      l_config_instances(l_c_ind).ship_flag          := 'Y';
      l_config_instances(l_c_ind).reship_flag        := 'N';
    END LOOP;

    IF l_config_instances.count > 0 THEN
      FOR l_d_ind IN l_config_instances.FIRST .. l_config_instances.LAST
      LOOP
        debug('config_instances. record # '||l_d_ind);
        debug('  serial_number      : '||l_config_instances(l_d_ind).serial_number);
        debug('  instance_id        : '||l_config_instances(l_d_ind).instance_id);
        debug('  location_type_code : '||l_config_instances(l_d_ind).location_type_code);
        debug('  ship_flag          : '||l_config_instances(l_d_ind).ship_flag);
        debug('  reship_flag        : '||l_config_instances(l_d_ind).reship_flag);
      END LOOP;
    END IF;

    x_config_instances := l_config_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_nsrl_instances;

  PROCEDURE get_config_srl_instances(
    p_config_rec         IN            config_rec,
    p_sub_config_flag    IN            varchar2,
    px_default_info_rec  IN OUT nocopy default_info_rec,
    px_csi_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_config_instances      OUT NOCOPY config_serial_inst_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS

    CURSOR inst_cur IS
      SELECT instance_id,
             serial_number,
             location_type_code
      FROM   csi_item_instances
      WHERE  inventory_item_id     = p_config_rec.item_id
      AND    last_oe_order_line_id = p_config_rec.line_id;

    l_config_inst_found boolean := FALSE;

    CURSOR wsh_cur IS
      SELECT serial_number,
             to_serial_number
      FROM   wsh_deliverables_v
      WHERE  source_line_id = p_config_rec.line_id
      AND    serial_number is not null;

    CURSOR in_rel_sc_inst_cur IS
      SELECT cii_sub.instance_id,
             cii_sub.serial_number,
             cii_sub.location_type_code
      FROM   csi_item_instances   cii_obj,
             csi_ii_relationships cir,
             csi_item_instances   cii_sub
      WHERE  cii_obj.inventory_item_id     = p_config_rec.item_id
      AND    cii_obj.last_oe_order_line_id = p_config_rec.line_id
      AND    cir.object_id                 = cii_obj.instance_id
      AND    cir.relationship_type_code    = 'COMPONENT-OF'
      AND    cii_sub.instance_id           = cir.subject_id
      AND    cii_sub.inventory_item_id     = p_config_rec.sub_config_item_id;

    CURSOR nsrl_sc_inst_cur IS
      SELECT cii.instance_id,
             cii.serial_number,
             cii.location_type_code
      FROM   csi_item_instances cii
      WHERE  cii.inventory_item_id  = p_config_rec.sub_config_item_id
      AND   ((cii.location_type_code = 'WIP'
              AND
              cii.wip_job_id = p_config_rec.config_wip_job_id)
            OR
              (cii.last_wip_job_id = p_config_rec.config_wip_job_id));

    l_fm_number          number;
    l_to_number          number;

    l_fm_prefix          varchar2(80);
    l_to_prefix          varchar2(80);

    l_prefix             varchar2(80);
    l_suffix             varchar2(80);

    l_prefix_length      number;
    l_suffix_length      number;
    l_serial_number      varchar2(80);
    l_instance_id        number;
    l_location_type_code varchar2(30);

    l_c_ind              binary_integer := 0;
    l_config_instances   config_serial_inst_tbl;

    l_order_hdr_rec      oe_order_headers_all%rowtype;
    l_order_line_rec     oe_order_lines_all%rowtype;
    l_tld_tbl            csi_t_datastructures_grp.txn_line_detail_tbl;

    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_srl_instances');

    IF p_sub_config_flag = 'N' THEN
      FOR inst_rec IN inst_cur
      LOOP
        l_config_inst_found := TRUE;
        l_c_ind := l_c_ind + 1;
        l_config_instances(l_c_ind).serial_number := inst_rec.serial_number;
        l_config_instances(l_c_ind).instance_id   := inst_rec.instance_id;
        l_config_instances(l_c_ind).location_type_code := inst_rec.location_type_code;
        l_config_instances(l_c_ind).ship_flag     := 'Y';
        l_config_instances(l_c_ind).reship_flag   := 'N';
      END LOOP;

      -- check if the record is still in wsh (shipped in OM but not in INV yet cases)
      IF NOT l_config_inst_found THEN
        FOR wsh_rec IN wsh_cur
        LOOP
          l_to_number := 1;
          IF wsh_rec.to_serial_number is not null THEN

            inv_validate.number_from_sequence(
              p_sequence => wsh_rec.serial_number,
              x_prefix   => l_fm_prefix,
              x_number   => l_fm_number);

            inv_validate.number_from_sequence(
              p_sequence => wsh_rec.to_serial_number,
              x_prefix   => l_to_prefix,
              x_number   => l_to_number);

            l_prefix        := l_fm_prefix;
            l_prefix_length  := nvl(length(l_prefix),0);
            l_suffix_length := length(wsh_rec.serial_number) - l_prefix_length;

            FOR l_ind IN l_fm_number .. l_to_number
            LOOP
              l_suffix := lpad(to_char(l_ind), l_suffix_length, '0');
              l_serial_number := l_prefix||l_suffix;

              BEGIN
                SELECT instance_id ,
                       location_type_code
                INTO   l_instance_id,
                       l_location_type_code
                FROM   csi_item_instances
                WHERE  inventory_item_id = p_config_rec.item_id
                AND    serial_number     = l_serial_number;

                l_c_ind := l_c_ind + 1;
                l_config_instances(l_c_ind).serial_number      := l_serial_number;
                l_config_instances(l_c_ind).instance_id        := l_instance_id;
                l_config_instances(l_c_ind).location_type_code := l_location_type_code;
                l_config_instances(l_c_ind).ship_flag          := 'N';

                IF p_config_rec.serial_code = 6 THEN
                  l_config_instances(l_c_ind).reship_flag   := 'Y';
                ELSE
                  l_config_instances(l_c_ind).reship_flag   := 'N';
                END IF;

              EXCEPTION
                WHEN no_data_found THEN
                  null;
              END;
            END LOOP;

          ELSE
            l_serial_number := wsh_rec.serial_number;
            BEGIN
              SELECT instance_id,
                     location_type_code
              INTO   l_instance_id,
                     l_location_type_code
              FROM   csi_item_instances
              WHERE  inventory_item_id = p_config_rec.item_id
              AND    serial_number     = l_serial_number;

              l_c_ind := l_c_ind + 1;
              l_config_instances(l_c_ind).serial_number      := l_serial_number;
              l_config_instances(l_c_ind).instance_id        := l_instance_id;
              l_config_instances(l_c_ind).location_type_code := l_location_type_code;
              l_config_instances(l_c_ind).ship_flag          := 'N';

              IF p_config_rec.serial_code = 6 THEN
                l_config_instances(l_c_ind).reship_flag   := 'Y';
              ELSE
                l_config_instances(l_c_ind).reship_flag   := 'N';
              END IF;

            EXCEPTION
              WHEN no_data_found THEN
                null;
            END;
          END IF;
        END LOOP;
      END IF;
    ELSE -- sub models

      SELECT * INTO l_order_line_rec
      FROM   oe_order_lines_all
      WHERE  line_id = p_config_rec.sub_model_line_id;

      SELECT * INTO l_order_hdr_rec
      FROM   oe_order_headers_all
      WHERE  header_id = l_order_line_rec.header_id;

      IF p_config_rec.serial_code in (2, 5) THEN
        FOR inst_rec IN in_rel_sc_inst_cur
        LOOP
          l_c_ind := l_c_ind + 1;
          l_config_instances(l_c_ind).serial_number      := inst_rec.serial_number;
          l_config_instances(l_c_ind).instance_id        := inst_rec.instance_id;
          l_config_instances(l_c_ind).location_type_code := inst_rec.location_type_code;
          l_config_instances(l_c_ind).ship_flag          := 'Y';
          l_config_instances(l_c_ind).reship_flag        := 'N';
        END LOOP;
      ELSE
        FOR inst_rec IN nsrl_sc_inst_cur
        LOOP
          l_c_ind := l_c_ind + 1;
          l_config_instances(l_c_ind).serial_number      := inst_rec.serial_number;
          l_config_instances(l_c_ind).instance_id        := inst_rec.instance_id;
          l_config_instances(l_c_ind).location_type_code := inst_rec.location_type_code;
          l_config_instances(l_c_ind).ship_flag          := 'Y';
          l_config_instances(l_c_ind).reship_flag        := 'N';

          IF inst_rec.location_type_code = 'WIP' THEN
            convert_wip_instance_to_cp(
              p_instance_id       => inst_rec.instance_id,
              p_order_hdr_rec     => l_order_hdr_rec,
              p_order_line_rec    => l_order_line_rec,
              p_tld_tbl           => l_tld_tbl,
              px_default_info_rec => px_default_info_rec,
              px_csi_txn_rec      => px_csi_txn_rec,
              x_return_status     => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
            l_config_instances(l_c_ind).location_type_code := 'HZ_PARTY_SITES';
          END IF;

        END LOOP;
      END IF;
    END IF;

    IF l_config_instances.count > 0 THEN
      FOR l_d_ind IN l_config_instances.FIRST .. l_config_instances.LAST
      LOOP
        debug('config_instances. record # '||l_d_ind);
        debug('  serial_number      : '||l_config_instances(l_d_ind).serial_number);
        debug('  instance_id        : '||l_config_instances(l_d_ind).instance_id);
        debug('  location_type_code : '||l_config_instances(l_d_ind).location_type_code);
        debug('  ship_flag          : '||l_config_instances(l_d_ind).ship_flag);
        debug('  reship_flag        : '||l_config_instances(l_d_ind).reship_flag);
      END LOOP;
    END IF;

    x_config_instances := l_config_instances;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_srl_instances;

  PROCEDURE get_config_shipped_serials(
    px_config_instances  IN OUT nocopy config_serial_inst_tbl,
    x_return_status         OUT nocopy varchar2)
  IS
    l_config_instances  config_serial_inst_tbl;
    l_c_ind             binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_shipped_serials');
    IF px_config_instances.COUNT > 0 THEN
      FOR l_ind IN px_config_instances.FIRST .. px_config_instances.LAST
      LOOP
        IF px_config_instances(l_ind).ship_flag = 'Y' THEN
          l_c_ind := l_c_ind + 1;
          l_config_instances(l_c_ind) := px_config_instances(l_ind);
        END IF;
      END LOOP;
    END IF;
    debug('  shipped srls count : '||l_config_instances.COUNT);
    px_config_instances := l_config_instances;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_shipped_serials;

  PROCEDURE check_for_re_shipment(
    p_header_id          IN number,
    px_config_instances  IN OUT NOCOPY config_serial_inst_tbl,
    x_reship_found       OUT NOCOPY boolean,
    x_return_status      OUT NOCOPY varchar2)
  IS

    CURSOR txn_cur(p_instance_id in number) IS
      SELECT ct.transaction_type_id
      FROM   csi_item_instances_h cih,
             csi_transactions ct
      WHERE  cih.instance_id   = p_instance_id
      AND    ct.transaction_id = cih.transaction_id
      AND NOT (ct.transaction_type_id = 51 AND ct.source_header_ref_id = p_header_id)
      ORDER BY ct.transaction_date desc;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('check_for_re_shipment');
    x_reship_found := FALSE;
    IF px_config_instances.COUNT > 0 THEN
      FOR l_ind IN px_config_instances.FIRST .. px_config_instances.LAST
      LOOP
        debug('  instance_id        : '||px_config_instances(l_ind).instance_id);
        IF px_config_instances(l_ind).reship_flag = 'N' THEN
          FOR txn_rec IN txn_cur ( px_config_instances(l_ind).instance_id)
          LOOP
            debug('    txn_type_id      : '||txn_rec.transaction_type_id);
            IF txn_rec.transaction_type_id = 51 THEN
              px_config_instances(l_ind).reship_flag := 'Y';
              x_reship_found := TRUE;
            END IF;
          END LOOP;
        ELSE
          x_reship_found := TRUE;
        END IF;
        debug('  reship_flag        : '||px_config_instances(l_ind).reship_flag);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_for_re_shipment;

  PROCEDURE get_reship_count(
    p_config_instances  IN  config_serial_inst_tbl,
    x_reship_count      OUT NOCOPY number,
    x_return_status     OUT NOCOPY varchar2)
  IS
    l_reship_count  number := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF p_config_instances.COUNT > 0 THEN
      FOR l_ind IN p_config_instances.FIRST .. p_config_instances.LAST
      LOOP
        IF p_config_instances(l_ind).reship_flag = 'Y' THEN
          l_reship_count := l_reship_count + 1;
        END IF;
      END LOOP;
    END IF;
    debug('  reship count       : '||l_reship_count);
    x_reship_count := l_reship_count;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_reship_count;

  PROCEDURE eliminate_reshipped_instances(
    p_config_instances  IN config_serial_inst_tbl,
    px_instances_tbl    IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status        OUT NOCOPY varchar2)
  IS
    l_instances_tbl     csi_datastructures_pub.instance_tbl;
    l_i_ind             binary_integer := 0;
    l_reshipped         boolean        := FALSE;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('eliminate_reshipped_instances');

    IF px_instances_tbl.COUNT > 0 THEN
      FOR l_ind IN px_instances_tbl.FIRST .. px_instances_tbl.LAST
      LOOP
        l_reshipped := FALSE;
        IF p_config_instances.COUNT > 0 THEN
          FOR l_r_ind IN p_config_instances.FIRST .. p_config_instances.LAST
          LOOP
            IF px_instances_tbl(l_ind).instance_id = p_config_instances(l_r_ind).instance_id
               AND
               p_config_instances(l_r_ind).reship_flag = 'Y'
            THEN
              l_reshipped := TRUE;
              exit;
            END IF;
          END LOOP;
        END IF;
        IF NOT l_reshipped THEN
          l_i_ind := l_i_ind + 1;
          l_instances_tbl(l_i_ind) := px_instances_tbl(l_ind);
        END IF;
      END LOOP;
    END IF;
    debug(' after eliminating the reshipped instances - COUNT :'||l_instances_tbl.COUNT);
    px_instances_tbl := l_instances_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END eliminate_reshipped_instances;

  PROCEDURE get_option_instances(
    p_config_instance_id  IN number,
    p_option_item_id      IN number,
    x_option_instances    OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_option_instances csi_datastructures_pub.instance_tbl;

    CURSOR option_inst_cur IS
      SELECT cii.instance_id
      FROM   csi_item_instances   cii,
             csi_ii_relationships cir
      WHERE  cir.object_id              = p_config_instance_id
      AND    cir.relationship_type_code = 'COMPONENT-OF'
      AND    cii.instance_id            = cir.subject_id
      AND    cii.inventory_item_id      = p_option_item_id
      AND    sysdate BETWEEN nvl(cii.active_start_date, sysdate-1)
                     AND     nvl(cii.active_end_date, sysdate+1);
  BEGIN
    FOR option_inst_rec IN option_inst_cur
    LOOP
      l_option_instances(option_inst_cur%rowcount).instance_id := option_inst_rec.instance_id;
    END LOOP;
    x_option_instances := l_option_instances;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_option_instances;

  /* when the serialized config item is shipped it moves the options along with */
  /* it because relations are created at the time of wip completion. When the   */
  /* options are fulfilled we just have to break the relation and stamp the ord */
  /* line id so that the fulfillment of option class wil once again build the   */
  /* component of relationships.                                                */

  PROCEDURE stamp_om_line(
    p_instance_id       IN  number,
    p_order_line_id     IN  number,
    px_csi_txn_rec      IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_inst_object_ver_num      number;

    l_u_instance_rec           csi_datastructures_pub.instance_rec;
    l_u_party_tbl              csi_datastructures_pub.party_tbl;
    l_u_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
    l_u_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_u_ext_attrib_val_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_u_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_u_inst_id_lst            csi_datastructures_pub.id_tbl;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('stamp_om_line');

    -- check if the instance is in WIP
    SELECT object_version_number
    INTO   l_inst_object_ver_num
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;

    l_u_instance_rec.instance_id              := p_instance_id ;
    l_u_instance_rec.last_oe_order_line_id    := p_order_line_id;
    l_u_instance_rec.object_version_number    := l_inst_object_ver_num;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'update_item_instance',
      p_pkg_name => 'csi_item_instance_pub');

    debug('  instance_id        : '||l_u_instance_rec.instance_id);
    debug('  last_oe_line_id    : '||l_u_instance_rec.last_oe_order_line_id);
    debug('  instance_ovn       : '||l_u_instance_rec.object_version_number);

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
      p_txn_rec               => px_csi_txn_rec,
      p_asset_assignment_tbl  => l_u_inst_asset_tbl,
      x_instance_id_lst       => l_u_inst_id_lst,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status not in (fnd_api.g_ret_sts_success, 'W') THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip issued component instance updated with the om info. instance_id : '||
          l_u_instance_rec.instance_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END stamp_om_line;

  PROCEDURE stamp_om_line_for_options(
    p_order_hdr_rec     IN     oe_order_headers_all%rowtype,
    p_order_line_rec    IN     oe_order_lines_all%rowtype,
    p_wip_instances     IN     wip_instances,
    p_tld_tbl           IN     csi_t_datastructures_grp.txn_line_detail_tbl,
    px_default_info_rec IN OUT nocopy default_info_rec,
    px_csi_txn_rec      IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status        OUT nocopy varchar2)
  IS
    l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('stamp_om_line_for_options');

    IF p_wip_instances.COUNT > 0 THEN
      FOR l_ind IN p_wip_instances.FIRST .. p_wip_instances.LAST
      LOOP

        IF p_wip_instances(l_ind).instance_usage_code = 'IN_RELATIONSHIP' THEN

          stamp_om_line(
            p_instance_id    => p_wip_instances(l_ind).instance_id,
            p_order_line_id  => p_order_line_rec.line_id,
            px_csi_txn_rec   => px_csi_txn_rec,
            x_return_status  => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE

          convert_wip_instance_to_cp(
            p_instance_id       => p_wip_instances(l_ind).instance_id,
            p_order_hdr_rec     => p_order_hdr_rec,
            p_order_line_rec    => p_order_line_rec,
            p_tld_tbl           => p_tld_tbl,
            px_default_info_rec => px_default_info_rec,
            px_csi_txn_rec      => px_csi_txn_rec,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END stamp_om_line_for_options;

  PROCEDURE get_config_serial_code(
    p_ato_line_id     IN  number,
    x_serial_code     OUT NOCOPY number,
    x_return_status   OUT NOCOPY varchar2)
  IS
    CURSOR config_cur IS
     SELECT msi.serial_number_control_code
     FROM   mtl_system_items    msi,
            oe_order_lines_all  oel
     WHERE  oel.link_to_line_id   = p_ato_line_id
     AND    oel.item_type_code    = 'CONFIG'
     AND    msi.organization_id   = oel.ship_from_org_id
     AND    msi.inventory_item_id = oel.inventory_item_id;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_serial_code');
    FOR config_rec IN config_cur
    LOOP
      x_serial_code := config_rec.serial_number_control_code;
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_serial_code;


  PROCEDURE break_relation(
    p_relationship_id  IN     number,
    p_relationship_ovn IN     number,
    px_csi_txn_rec     IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status       OUT nocopy varchar2)
  IS
    l_exp_rltns_rec          csi_datastructures_pub.ii_relationship_rec;
    l_instance_id_lst        csi_datastructures_pub.id_tbl;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('break_relation');

    l_exp_rltns_rec.relationship_id      := p_relationship_id;
    l_exp_rltns_rec.object_version_number:= p_relationship_ovn;

    debug('  relationship_id    :'||l_exp_rltns_rec.relationship_id);

    IF nvl(p_relationship_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      SELECT object_version_number
      INTO   l_exp_rltns_rec.object_version_number
      FROM   csi_ii_relationships
      WHERE  relationship_id = l_exp_rltns_rec.relationship_id;

      debug('  relationship_ovn   :'||l_exp_rltns_rec.object_version_number);
      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_ii_relationships_pub',
        p_api_name => 'expire_relationship');

      csi_ii_relationships_pub.expire_relationship(
        p_api_version               => 1.0,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_false,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_relationship_rec          => l_exp_rltns_rec,
        p_txn_rec                   => px_csi_txn_rec,
        x_instance_id_lst           => l_instance_id_lst,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END break_relation;

  /* this routine check the relationship record for the ato component in WIP */
  /* and breaks the relation                                                 */

  PROCEDURE check_and_break_relation(
    p_instance_id   IN     number,
    px_csi_txn_rec  IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status    OUT nocopy varchar2)
  IS


    l_relationship_query_rec csi_datastructures_pub.relationship_query_rec;
    l_relationship_tbl       csi_datastructures_pub.ii_relationship_tbl;
    l_time_stamp             date := sysdate;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number      := 0;
    l_msg_data               varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('check_and_break_relation');

    debug('  subject instance id :'||p_instance_id);

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

         break_relation(
           p_relationship_id  => l_relationship_tbl(l_ind).relationship_id,
           p_relationship_ovn => l_relationship_tbl(l_ind).object_version_number,
           px_csi_txn_rec     => px_csi_txn_rec,
           x_return_status    => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           RAISE fnd_api.g_exc_error;
         END IF;

      END LOOP;
    END IF;

    debug('check and break relation successful.');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_and_break_relation;

  PROCEDURE mark_and_get_config(
    px_config_instances  IN OUT nocopy config_serial_inst_tbl,
    x_config_instance       OUT nocopy config_serial_inst_rec,
    x_return_status         OUT nocopy varchar2)
  IS
    px_ind binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('mark_and_get_config');

    IF px_config_instances.COUNT > 0 THEN
      px_ind :=  px_config_instances.NEXT(px_ind);
      IF px_ind is null THEN
        null;
      ELSE
        x_config_instance := px_config_instances(px_ind);
        px_config_instances.DELETE(px_ind);
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END mark_and_get_config;

  PROCEDURE mark_and_get_src_tld(
    px_src_tld_tbl       IN OUT nocopy csi_t_datastructures_grp.txn_line_detail_tbl,
    x_src_tld_rec           OUT nocopy csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status         OUT nocopy varchar2)
  IS
    px_ind binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('mark_and_get_src_tld');

    IF px_src_tld_tbl.COUNT > 0 THEN
      px_ind :=  px_src_tld_tbl.NEXT(px_ind);
      IF px_ind is null THEN
        null;
      ELSE
        x_src_tld_rec := px_src_tld_tbl(px_ind);
        px_src_tld_tbl.DELETE(px_ind);
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END mark_and_get_src_tld;

  PROCEDURE mark_and_get_nsrl_option(
    p_class_quantity        IN            number,
    p_quantity_ratio        IN            number,
    px_ii_rltns_tbl         IN OUT nocopy csi_datastructures_pub.ii_relationship_tbl,
    px_csi_txn_rec          IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_option_ii_rltns_rec      OUT nocopy csi_datastructures_pub.ii_relationship_rec,
    x_return_status            OUT nocopy varchar2)
  IS

    px_ind                   binary_integer := 0;
    px_new_ind               binary_integer := 0;

    l_instance_quantity      number;
    l_vld_organization_id    number;

    l_splitted_instances     csi_datastructures_pub.instance_tbl;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('mark_and_get_nsrl_option');

    px_ind := 0;

    IF px_ii_rltns_tbl.COUNT > 0 THEN

      px_ind := px_ii_rltns_tbl.NEXT(px_ind);
      x_option_ii_rltns_rec := px_ii_rltns_tbl(px_ind);

      SELECT quantity ,
             last_vld_organization_id
      INTO   l_instance_quantity ,
             l_vld_organization_id
      FROM   csi_item_instances
      WHERE  instance_id = px_ii_rltns_tbl(px_ind).subject_id;

      IF l_instance_quantity > p_quantity_ratio THEN

        -- decrement quantity on the inrel instance and create another one
        -- with the same information

        split_instance_using_ratio(
          p_instance_id         => px_ii_rltns_tbl(px_ind).subject_id,
          p_qty_ratio           => p_quantity_ratio,
          p_parent_qty          => p_class_quantity,
          p_organization_id     => l_vld_organization_id,
          px_csi_txn_rec        => px_csi_txn_rec,
          x_splitted_instances  => l_splitted_instances,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_Api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        px_new_ind := px_ind;

        IF l_splitted_instances.COUNT > 0 THEN
          FOR l_ind IN l_splitted_instances.FIRST .. l_splitted_instances.LAST
          LOOP
            IF l_splitted_instances(l_ind).instance_id <> px_ii_rltns_tbl(px_ind).subject_id THEN

              px_new_ind := px_new_ind + 1;
              px_ii_rltns_tbl(px_new_ind).subject_id := l_splitted_instances(l_ind).instance_id;
              px_ii_rltns_tbl(px_new_ind).object_id  := px_ii_rltns_tbl(px_ind).object_id;
              px_ii_rltns_tbl(px_new_ind).relationship_type_code := 'COMPONENT-OF';

              BEGIN
                SELECT relationship_id,
                       object_version_number
                INTO   px_ii_rltns_tbl(px_new_ind).relationship_id,
                       px_ii_rltns_tbl(px_new_ind).object_version_number
                FROM   csi_ii_relationships
                WHERE  object_id              = px_ii_rltns_tbl(px_new_ind).object_id
                AND    subject_id             = px_ii_rltns_tbl(px_new_ind).subject_id
                AND    relationship_type_code = 'COMPONENT-OF';
              EXCEPTION
                WHEN no_data_found THEN
                  px_ii_rltns_tbl(px_new_ind).relationship_id := fnd_api.g_miss_num;
              END;
            END IF;
          END LOOP;
        END IF;

        IF nvl(px_ii_rltns_tbl(px_ind).relationship_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          break_relation(
            p_relationship_id  => px_ii_rltns_tbl(px_ind).relationship_id,
            p_relationship_ovn => px_ii_rltns_tbl(px_ind).object_version_number,
            px_csi_txn_rec     => px_csi_txn_rec,
            x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        px_ii_rltns_tbl.DELETE(px_ind);

      ELSE

        IF nvl(px_ii_rltns_tbl(px_ind).relationship_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          break_relation(
            p_relationship_id  => px_ii_rltns_tbl(px_ind).relationship_id,
            p_relationship_ovn => px_ii_rltns_tbl(px_ind).object_version_number,
            px_csi_txn_rec     => px_csi_txn_rec,
            x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        px_ii_rltns_tbl.DELETE(px_ind);

      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END mark_and_get_nsrl_option;

  PROCEDURE mark_and_get_srl_option(
    px_ii_rltns_tbl         IN OUT nocopy csi_datastructures_pub.ii_relationship_tbl,
    x_option_ii_rltns_rec      OUT nocopy csi_datastructures_pub.ii_relationship_rec,
    x_return_status            OUT nocopy varchar2)
  IS
    px_ind    binary_integer := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('mark_and_get_srl_option');
    IF px_ii_rltns_tbl.COUNT > 0 THEN
      px_ind := px_ii_rltns_tbl.NEXT(px_ind);
      x_option_ii_rltns_rec := px_ii_rltns_tbl(px_ind);
      px_ii_rltns_tbl.DELETE(px_ind);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END mark_and_get_srl_option;

  PROCEDURE filter_option_instances(
    p_option_line_rec       IN oe_order_pub.line_rec_type,
    p_option_serial_code    IN number,
    p_config_rec            IN config_rec,
    p_transaction_line_id   IN number,
    px_ii_rltns_tbl         IN OUT nocopy csi_datastructures_pub.ii_relationship_tbl,
    px_csi_txn_rec          IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status            OUT nocopy varchar2)
  IS
    l_option_instance varchar2(1);
    l_ind             binary_integer := 0;
    l_ii_rltns_tbl    csi_datastructures_pub.ii_relationship_tbl;
    l_wip_instances   wip_instances;
    l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
    CURSOR option_cp_cur IS
      SELECT cii.instance_id
      FROM   csi_item_instances cii
      WHERE  cii.inventory_item_id     = p_option_line_rec.inventory_item_id
      AND    cii.last_oe_order_line_id = p_option_line_rec.line_id
      AND    cii.location_type_code    = 'HZ_PARTY_SITES'
      AND    cii.instance_usage_code   = 'OUT_OF_ENTERPRISE'
      AND not exists (
        SELECT 'x' FROM csi_t_txn_line_details ctld
        WHERE  ctld.transaction_line_id     = p_transaction_line_id
        AND    ctld.source_transaction_flag = 'N'
        AND    ctld.instance_id             = cii.instance_id);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('filter_option_instances');

    IF px_ii_rltns_tbl.COUNT > 0 THEN
      FOR px_ind IN px_ii_rltns_tbl.FIRST .. px_ii_rltns_tbl.LAST
      LOOP
        BEGIN
          SELECT 'Y' INTO l_option_instance
          FROM   csi_item_instances cii
          WHERE  cii.instance_id = px_ii_rltns_tbl(px_ind).subject_id
          AND    cii.inventory_item_id = p_option_line_rec.inventory_item_id;

          l_ind := l_ind + 1;
          l_ii_rltns_tbl(l_ind) := px_ii_rltns_tbl(px_ind);
        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;
      END LOOP;
    END IF;

    IF l_ii_rltns_tbl.COUNT = 0 THEN
      FOR option_cp_rec IN option_cp_cur
      LOOP
        l_ind := l_ind + 1;
        l_ii_rltns_tbl(l_ind).subject_id := option_cp_rec.instance_id;
      END LOOP;
    END IF;

    IF l_ii_rltns_tbl.COUNT = 0 THEN
      -- check if the option instances are left in WIP due to no allocation at WIP
      get_wip_instances(
        p_wip_entity_id      => p_config_rec.config_wip_job_id,
        p_inventory_item_id  => p_option_line_rec.inventory_item_id,
        p_organization_id    => p_config_rec.ship_organization_id,
        p_option_serial_code => p_option_serial_code,
        p_config_rec         => p_config_rec,
        px_csi_txn_rec       => px_csi_txn_rec,
        x_wip_instances      => l_wip_instances,
        x_return_status      => l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_wip_instances.COUNT > 0 THEN
        FOR w_ind IN l_wip_instances.FIRST .. l_wip_instances.LAST
        LOOP
          l_ind := l_ind + 1;
          l_ii_rltns_tbl(l_ind).subject_id := l_wip_instances(w_ind).instance_id;
          IF l_wip_instances(w_ind).instance_usage_code = 'IN_RELATIONSHIP' THEN
            SELECT relationship_id,
                   object_version_number
            INTO   l_ii_rltns_tbl(l_ind).relationship_id,
                   l_ii_rltns_tbl(l_ind).object_version_number
            FROM   csi_ii_relationships
            WHERE  subject_id = l_wip_instances(w_ind).instance_id
            AND    relationship_type_code = 'COMPONENT-OF'
            AND    sysdate between nvl(active_start_date, sysdate-1)
                           and     nvl(active_end_date, sysdate+1);
          END IF;
        END LOOP;
      END IF;

    END IF;

    px_ii_rltns_tbl := l_ii_rltns_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END filter_option_instances;

  PROCEDURE check_wip_requirements(
    p_wip_entity_id     IN     number,
    p_option_item_id    IN     number,
    x_wip_processing       OUT NOCOPY boolean)
  IS
    l_wip_processing        boolean := TRUE;

    l_phantom               varchar2(1);
    l_wip_supply_type       number;
    l_quantity_issued       number;

  BEGIN
    BEGIN
      SELECT 'Y' INTO l_phantom
        FROM   sys.dual
        WHERE  EXISTS (
          SELECT '1' FROM wip_requirement_operations
          WHERE  wip_entity_id     = p_wip_entity_id
          AND    inventory_item_id = p_option_item_id
          AND    wip_supply_type   = 6); --phantoms
        debug('  supply_type : phantom - just the fulfillment of option' );
        l_wip_processing := FALSE;
      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            SELECT wip_supply_type,
                   quantity_issued
            INTO   l_wip_supply_type,
                   l_quantity_issued
            FROM   wip_requirement_operations
            WHERE  wip_entity_id     = p_wip_entity_id
            AND    inventory_item_id = p_option_item_id
            AND    rownum = 1;

            debug('  supply_type : non phantom - '||l_wip_supply_type||
                  '  quantity issued - '||l_quantity_issued );
          EXCEPTION
            WHEN no_data_found THEN
              debug('  wip requirements deleted/altered/substituted. will just fulfill the line.');
              l_wip_processing := FALSE;
          END;
    END;
    x_wip_processing := l_wip_processing;
  END check_wip_requirements;

  /* routine to plug in the option classes in between the build option relation at WIP */
  PROCEDURE rebuild_relation_for_ato(
    p_order_line_rec    IN            oe_order_lines_all%rowtype,
    p_config_rec        IN            config_rec,
    p_config_instances  IN            config_serial_inst_tbl,
    px_default_info_rec IN OUT NOCOPY default_info_rec,
    px_csi_txn_rec      IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status        OUT nocopy varchar2)
  IS

    l_src_tld_tbl            csi_t_datastructures_grp.txn_line_detail_tbl;
    l_temp_src_tld_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;

    l_config_class_ratio     number;

    lp_ind                   binary_integer := 0;
    l_parent_instances       parent_instances;
    l_parent_is_oc           boolean;
    l_config_instances       config_serial_inst_tbl;
    l_config_instance        config_serial_inst_rec;

    l_sub_config_instances   config_serial_inst_tbl;
    l_sub_config_instance    config_serial_inst_rec;
    l_child_line_tbl         oe_order_pub.line_tbl_type;
    l_parent_line_rec        oe_order_pub.line_rec_type;

    l_config_ns_tld_id       number;
    l_sub_config_ns_tld_id   number;

    l_oc_tld_rec             csi_t_datastructures_grp.txn_line_detail_rec;

    oct_ind                  binary_integer := 0;
    l_oc_tld_tbl             csi_t_datastructures_grp.txn_line_detail_tbl;

    l_ii_rltns_qry_rec       csi_datastructures_pub.relationship_query_rec;
    l_ii_rltns_tbl           csi_datastructures_pub.ii_relationship_tbl;
    l_temp_ii_rltns_tbl      csi_datastructures_pub.ii_relationship_tbl;

    l_time_stamp             date := null;

    l_pcm_tbl                parent_child_map_tbl;
    pcm_ind                  binary_integer := 0;

    l_class_option_ratio     number;
    l_option_serial_code     number;
    l_option_ii_rltns_rec    csi_datastructures_pub.ii_relationship_rec;
    l_option_ns_tld_id       number;

    l_exp_rltns_rec          csi_datastructures_pub.ii_relationship_rec;
    l_instance_id_lst        csi_datastructures_pub.id_tbl;

    l_t_rltns_tbl            csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_wip_processing         boolean      := FALSE;

    l_msg_count              number      := 0;
    l_msg_data               varchar2(2000);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR sc_inst_cur(
      p_top_config_instance_id IN number,
      p_sub_config_item_id     IN number)
    IS
      SELECT cir.subject_id,
             cir.relationship_id,
             cir.object_version_number
      FROM   csi_item_instances   cii_sub,
             csi_ii_relationships cir
      WHERE  cir.object_id              = p_top_config_instance_id
      AND    cir.relationship_type_code = 'COMPONENT-OF'
      AND    sysdate between nvl(cir.active_start_date, sysdate-1)
                     and     nvl(cir.active_end_date, sysdate+1)
      AND    cii_sub.instance_id        = cir.subject_id
      AND    cii_sub.inventory_item_id  = p_sub_config_item_id;

    PROCEDURE get_config_wrt_child(
      p_config_rec      IN  config_rec,
      p_parent_is_oc    IN  boolean,
      p_parent_instance IN  parent_instance,
      x_config_instance OUT nocopy config_serial_inst_rec,
      x_return_status   OUT nocopy varchar2)
    IS
      l_iir_tbl         csi_datastructures_pub.ii_relationship_tbl;
      l_return_status   varchar2(1) := fnd_api.g_ret_sts_success;
      l_msg_count       number;
      l_msg_data        varchar2(2000);
    BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      api_log('get_config_wrt_child');

      IF p_parent_is_oc THEN

        csi_item_instance_grp.get_all_parents(
          p_api_version      => 1.0,
          p_commit           => fnd_api.g_false,
          p_init_msg_list    => fnd_api.g_true,
          p_validation_level => fnd_api.g_valid_level_full,
          p_subject_id       => p_parent_instance.instance_id,
          x_rel_tbl          => l_iir_tbl,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        IF l_iir_tbl.COUNT > 0 THEN
          FOR iir_ind IN l_iir_tbl.FIRST .. l_iir_tbl.LAST
          LOOP
            BEGIN
              SELECT instance_id
              INTO   x_config_instance.instance_id
              FROM   csi_item_instances
              WHERE  instance_id       = l_iir_tbl(iir_ind).object_id
              AND    inventory_item_id = p_config_rec.item_id;
              exit;
            EXCEPTION
              WHEN no_data_found THEN
                null;
            END;
          END LOOP;
        END IF;
      ELSE
        x_config_instance.instance_id := p_parent_instance.instance_id;
      END IF;
      debug('  config_instance_id : '||x_config_instance.instance_id);
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END get_config_wrt_child;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('rebuild_relation_for_ato');

    IF p_order_line_rec.item_type_code = 'CLASS' THEN
      get_tld(
        p_source_table       => 'OE_ORDER_LINES_ALL',
        p_source_id          => p_order_line_rec.line_id,
        p_source_flag        => 'Y',
        p_processing_status  => 'IN_PROCESS',
        x_line_dtl_tbl       => l_src_tld_tbl,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      get_ib_trackable_parent(
        p_current_line_id   => p_order_line_rec.line_id,
        p_om_vld_org_id     => px_default_info_rec.om_vld_org_id,
        x_parent_line_rec   => l_parent_line_rec,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_config_class_ratio := p_order_line_rec.ordered_quantity/l_parent_line_rec.ordered_quantity;
      debug('  config_class_ratio : '||l_config_class_ratio);

      IF px_default_info_rec.identified_item_type = 'ATO_SUB_MODEL' THEN

        get_config_srl_instances(
          p_config_rec        => p_config_rec,
          p_sub_config_flag   => 'Y',
          px_default_info_rec => px_default_info_rec,
          px_csi_txn_rec      => px_csi_txn_rec,
          x_config_instances  => l_sub_config_instances,
          x_return_status     => l_return_status);
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF p_order_line_rec.ato_line_id = l_parent_line_rec.line_id THEN
          l_parent_is_oc := FALSE;
          debug('sub model directly under the model');
          -- the child is a sub config item. this is the most tricky part because we are tryig
          -- to put that guy as a child of the ato sub model breaking from the parent config.
          IF p_config_rec.serial_code = 1 THEN
            get_config_nsrl_instances(
              p_config_rec       => p_config_rec,
              p_sub_config_flag  => 'N',
              x_config_instances => l_config_instances,
              x_return_status    => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            l_config_instances := p_config_instances;
          END IF;

          IF l_config_instances.COUNT > 0 THEN
            FOR lc_ind IN l_config_instances.FIRST .. l_config_instances.LAST
            LOOP
              lp_ind := lp_ind + 1;
              l_parent_instances(lp_ind).instance_id := l_config_instances(lc_ind).instance_id;
            END LOOP;
          END IF;
        ELSE

          l_parent_is_oc := TRUE;

          debug('sub model not directly under the model');
          -- get_parent_instances
          get_parent_instances (
            p_parent_line_id   => l_parent_line_rec.line_id,
            p_parent_item_id   => l_parent_line_rec.inventory_item_id,
            x_parent_instances => l_parent_instances,
            x_return_status    => l_return_status);

          debug('  parent instances count : '||l_parent_instances.COUNT);

        END IF;

        l_temp_src_tld_tbl := l_src_tld_tbl;

        IF l_parent_instances.COUNT > 0 THEN

          debug('parent relationship');

          FOR pi_ind IN l_parent_instances.FIRST .. l_parent_instances.LAST
          LOOP

            -- for each of the parent config instance for the class build a non source tld
            build_non_source_rec(
              p_transaction_line_id  => px_default_info_rec.transaction_line_id,
              p_instance_id          => l_parent_instances(pi_ind).instance_id,
              px_default_info_rec    => px_default_info_rec,
              x_txn_line_dtl_id      => l_config_ns_tld_id,
              x_return_status        => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            oct_ind := 0;
            l_oc_tld_tbl.DELETE;

            FOR config_class_ratio_ind IN 1 .. l_config_class_ratio
            LOOP

              mark_and_get_src_tld(
                px_src_tld_tbl       => l_temp_src_tld_tbl,
                x_src_tld_rec        => l_oc_tld_rec,
                x_return_status      => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF nvl(l_oc_tld_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

                oct_ind := oct_ind + 1;
                l_oc_tld_tbl(oct_ind) := l_oc_tld_rec;

                pcm_ind := pcm_ind + 1;
                l_pcm_tbl(pcm_ind).object_tld_id := l_config_ns_tld_id;
                l_pcm_tbl(pcm_ind).subject_tld_id := l_oc_tld_rec.txn_line_detail_id;

              END IF;

            END LOOP; -- class/ratio apportion

            debug('child relation.');

            get_config_wrt_child(
              p_config_rec      => p_config_rec,
              p_parent_is_oc    => l_parent_is_oc,
              p_parent_instance => l_parent_instances(pi_ind),
              x_config_instance => l_config_instance,
              x_return_status   => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF p_config_rec.serial_code in (2, 5) THEN

              -- child relation
              FOR sc_inst_rec IN sc_inst_cur(
                p_top_config_instance_id => l_config_instance.instance_id,
                p_sub_config_item_id     => p_config_rec.sub_config_item_id)
              LOOP

                mark_and_get_src_tld(
                  px_src_tld_tbl       => l_oc_tld_tbl,
                  x_src_tld_rec        => l_oc_tld_rec,
                  x_return_status      => l_return_status);
                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                break_relation(
                  p_relationship_id  => sc_inst_rec.relationship_id,
                  p_relationship_ovn => sc_inst_rec.object_version_number,
                  px_csi_txn_rec     => px_csi_txn_rec,
                  x_return_status    => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                build_non_source_rec(
                  p_transaction_line_id  => px_default_info_rec.transaction_line_id,
                  p_instance_id          => sc_inst_rec.subject_id,
                  px_default_info_rec    => px_default_info_rec,
                  x_txn_line_dtl_id      => l_config_ns_tld_id,
                  x_return_status        => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                pcm_ind := pcm_ind + 1;
                l_pcm_tbl(pcm_ind).object_tld_id  := l_oc_tld_rec.txn_line_detail_id;
                l_pcm_tbl(pcm_ind).subject_tld_id := l_config_ns_tld_id;

              END LOOP;
            ELSE -- non serial/soi config block

              IF l_sub_config_instances.COUNT > 0 THEN

                FOR config_class_ratio_ind IN 1 .. l_config_class_ratio
                LOOP

                  mark_and_get_src_tld(
                    px_src_tld_tbl       => l_oc_tld_tbl,
                    x_src_tld_rec        => l_oc_tld_rec,
                    x_return_status      => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  IF nvl(l_oc_tld_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                  THEN

                    mark_and_get_config(
                      px_config_instances => l_sub_config_instances,
                      x_config_instance   => l_sub_config_instance,
                      x_return_status     => l_return_status);

                    IF l_sub_config_instance.instance_id is not null THEN
                      build_non_source_rec(
                        p_transaction_line_id  => px_default_info_rec.transaction_line_id,
                        p_instance_id          => l_sub_config_instance.instance_id,
                        px_default_info_rec    => px_default_info_rec,
                        x_txn_line_dtl_id      => l_sub_config_ns_tld_id,
                        x_return_status        => l_return_status);

                       IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE fnd_api.g_exc_error;
                      END IF;

                      pcm_ind := pcm_ind + 1;
                      l_pcm_tbl(pcm_ind).object_tld_id  := l_oc_tld_rec.txn_line_detail_id;
                      l_pcm_tbl(pcm_ind).subject_tld_id := l_sub_config_ns_tld_id;

                    END IF;

                  END IF;

                END LOOP;
              END IF;

            END IF; -- config serial code in (2, 5)

          END LOOP;
        END IF; -- config instance.count > 0
      ELSE -- non ato sub model classes

        get_ib_trackable_children(
          p_current_line_id    => p_order_line_rec.line_id,
          p_om_vld_org_id      => px_default_info_rec.om_vld_org_id,
          x_trackable_line_tbl => l_child_line_tbl,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        get_ato_options_only(
          px_line_tbl     => l_child_line_tbl,
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_temp_src_tld_tbl := l_src_tld_tbl;

        IF p_config_rec.sub_model_flag = 'N' THEN
          l_config_instances := p_config_instances;
        ELSE
          IF l_parent_line_rec.line_id = p_config_rec.sub_model_line_id THEN
            debug('  immediate child of an ato sub model');
            -- switch the l_config_instances with the sub_model_config_instances
            get_config_srl_instances(
              p_config_rec        => p_config_rec,
              p_sub_config_flag   => 'Y',
              px_default_info_rec => px_default_info_rec,
              px_csi_txn_rec      => px_csi_txn_rec,
              x_config_instances  => l_config_instances,
              x_return_status     => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END IF;

        IF p_config_rec.serial_code <> 1 THEN
          get_config_shipped_serials(
            px_config_instances => l_config_instances,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF l_config_instances.COUNT > 0 THEN
          FOR ci_ind IN l_config_instances.FIRST .. l_config_instances.LAST
          LOOP

            --{ begin parent relation code

            -- for each of the parent config instance for the class build a non source tld
            build_non_source_rec(
              p_transaction_line_id  => px_default_info_rec.transaction_line_id,
              p_instance_id          => l_config_instances(ci_ind).instance_id,
              px_default_info_rec    => px_default_info_rec,
              x_txn_line_dtl_id      => l_config_ns_tld_id,
              x_return_status        => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            oct_ind := 0;

            FOR config_class_ratio_ind IN 1 .. l_config_class_ratio
            LOOP

              mark_and_get_src_tld(
                px_src_tld_tbl       => l_temp_src_tld_tbl,
                x_src_tld_rec        => l_oc_tld_rec,
                x_return_status      => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              IF nvl(l_oc_tld_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

                oct_ind := oct_ind + 1;
                l_oc_tld_tbl(oct_ind) := l_oc_tld_rec;

                pcm_ind := pcm_ind + 1;
                l_pcm_tbl(pcm_ind).object_tld_id := l_config_ns_tld_id;
                l_pcm_tbl(pcm_ind).subject_tld_id := l_oc_tld_rec.txn_line_detail_id;

              END IF;

            END LOOP;

            -- } end parent relation code

            -- { begin child relation code

            l_ii_rltns_qry_rec.object_id              := l_config_instances(ci_ind).instance_id;
            l_ii_rltns_qry_rec.relationship_type_code := 'COMPONENT-OF';

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_ii_relationships_pub',
              p_api_name => 'get_relationships');

            csi_ii_relationships_pub.get_relationships(
              p_api_version               => 1.0,
              p_commit                    => fnd_api.g_false,
              p_init_msg_list             => fnd_api.g_true,
              p_validation_level          => fnd_api.g_valid_level_full,
              p_relationship_query_rec    => l_ii_rltns_qry_rec,
              p_depth                     => 1,
              p_time_stamp                => l_time_stamp,
              p_active_relationship_only  => fnd_api.g_true,
              x_relationship_tbl          => l_ii_rltns_tbl,
              x_return_status             => l_return_status,
              x_msg_count                 => l_msg_count,
              x_msg_data                  => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            debug('  ii relationship count :'||l_ii_rltns_tbl.COUNT);

            IF l_ii_rltns_tbl.COUNT > 0 THEN
              l_config_instances(ci_ind).wip_config_flag := 'Y';
            ELSE
              l_config_instances(ci_ind).wip_config_flag := 'N';
            END IF;

            l_temp_ii_rltns_tbl := l_ii_rltns_tbl;

            IF l_child_line_tbl.COUNT > 0 THEN
              FOR cl_ind IN l_child_line_tbl.FIRST .. l_child_line_tbl.LAST
              LOOP
      	      --If condition included for Bug 4514821:To ensure that breaking of child compoenent
	      --from config item and attaching with option class is done,only if
	      --child item is involved in wip transaction.
	       check_wip_requirements(
                p_wip_entity_id  => p_config_rec.config_wip_job_id,
                p_option_item_id => l_child_line_tbl(cl_ind).inventory_item_id,
                x_wip_processing => l_wip_processing);

	      IF (l_wip_processing) THEN

                debug('Child Item is involved in wip transaction, so trying to break relation with config');

                SELECT serial_number_control_code
                INTO   l_option_serial_code
                FROM   mtl_system_items
                WHERE  inventory_item_id = l_child_line_tbl(cl_ind).inventory_item_id
                AND    organization_id   = l_child_line_tbl(cl_ind).ship_from_org_id;

                l_ii_rltns_tbl := l_temp_ii_rltns_tbl;

                filter_option_instances(
                  p_option_line_rec     => l_child_line_tbl(cl_ind),
                  p_option_serial_code  => l_option_serial_code,
                  p_config_rec          => p_config_rec,
                  p_transaction_line_id => px_default_info_rec.transaction_line_id,
                  px_ii_rltns_tbl       => l_ii_rltns_tbl,
                  px_csi_txn_rec        => px_csi_txn_rec,
                  x_return_status       => l_return_status);

	       --Included the return status check, as part of fixing bug 4514821
	       IF l_return_status <> fnd_api.g_ret_sts_success THEN
	              RAISE fnd_api.g_exc_error;
	       END IF;
	       debug('ii relationship count :'||l_ii_rltns_tbl.COUNT);


                l_class_option_ratio := l_child_line_tbl(cl_ind).ordered_quantity/
                                        p_order_line_rec.ordered_quantity;

                IF l_oc_tld_tbl.COUNT > 0 THEN
                  FOR l_oc_ind IN l_oc_tld_tbl.FIRST .. l_oc_tld_tbl.LAST
                  LOOP

                    IF l_option_serial_code in (2, 5, 6) THEN
                      debug('  serial option');
                      FOR l_class_option_ratio_ind IN 1 .. l_class_option_ratio
                      LOOP
                        -- mark and get

                        mark_and_get_srl_option(
                          px_ii_rltns_tbl       => l_ii_rltns_tbl,
                          x_option_ii_rltns_rec => l_option_ii_rltns_rec,
                          x_return_status       => l_return_status);

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          RAISE fnd_api.g_exc_error;
                        END IF;

                        build_non_source_rec(
                          p_transaction_line_id  => px_default_info_rec.transaction_line_id,
                          p_instance_id          => l_option_ii_rltns_rec.subject_id,
                          px_default_info_rec    => px_default_info_rec,
                          x_txn_line_dtl_id      => l_option_ns_tld_id,
                          x_return_status        => l_return_status);

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          RAISE fnd_api.g_exc_error;
                        END IF;

                        IF nvl(l_option_ii_rltns_rec.relationship_id, fnd_api.g_miss_num) <>
                           fnd_api.g_miss_num
                        THEN
                          break_relation(
                            p_relationship_id  => l_option_ii_rltns_rec.relationship_id,
                            p_relationship_ovn => l_option_ii_rltns_rec.object_version_number,
                            px_csi_txn_rec     => px_csi_txn_rec,
                            x_return_status    => l_return_status);

                          IF l_return_status <> fnd_api.g_ret_sts_success THEN
                            RAISE fnd_api.g_exc_error;
                          END IF;
                        END IF;

                        pcm_ind := pcm_ind + 1;
                        l_pcm_tbl(pcm_ind).object_tld_id := l_oc_tld_tbl(l_oc_ind).txn_line_detail_id;
                        l_pcm_tbl(pcm_ind).subject_tld_id := l_option_ns_tld_id;

                      END LOOP; -- class option ratio check
                    ELSE -- non serial ato option case
                      debug('  non serial option');

                      mark_and_get_nsrl_option(
                        p_class_quantity      => p_order_line_rec.ordered_quantity,
                        p_quantity_ratio      => l_class_option_ratio,
                        px_csi_txn_rec        => px_csi_txn_rec,
                        px_ii_rltns_tbl       => l_ii_rltns_tbl,
                        x_option_ii_rltns_rec => l_option_ii_rltns_rec,
                        x_return_status       => l_return_status);

                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE fnd_api.g_exc_error;
                      END IF;

                      IF nvl(l_option_ii_rltns_rec.subject_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                      THEN
                        build_non_source_rec(
                          p_transaction_line_id  => px_default_info_rec.transaction_line_id,
                          p_instance_id          => l_option_ii_rltns_rec.subject_id,
                          px_default_info_rec    => px_default_info_rec,
                          x_txn_line_dtl_id      => l_option_ns_tld_id,
                          x_return_status        => l_return_status);

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          RAISE fnd_api.g_exc_error;
                        END IF;

                        pcm_ind := pcm_ind + 1;
                        l_pcm_tbl(pcm_ind).object_tld_id := l_oc_tld_tbl(l_oc_ind).txn_line_detail_id;
                        l_pcm_tbl(pcm_ind).subject_tld_id := l_option_ns_tld_id;
                      END IF;

                    END IF; -- option serial control check

                  END LOOP;
                END IF;
		END IF; --<<IF l_wip_processing = true >>Fix for bug 4514821
              END LOOP;
            END IF;

          END LOOP;  -- config serial instance loop
        END IF;
      END IF; -- sub models/NON sub models
    END IF; -- item type code = CLASS

    IF l_pcm_tbl.COUNT > 0 THEN
      FOR l_pcm_ind IN l_pcm_tbl.FIRST .. l_pcm_tbl.LAST
      LOOP
        -- build ii_rltns table
        l_t_rltns_tbl(l_pcm_ind).txn_relationship_id    := fnd_api.g_miss_num;
        l_t_rltns_tbl(l_pcm_ind).transaction_line_id    := px_default_info_rec.transaction_line_id;
        l_t_rltns_tbl(l_pcm_ind).subject_id             := l_pcm_tbl(l_pcm_ind).subject_tld_id;
        l_t_rltns_tbl(l_pcm_ind).object_id              := l_pcm_tbl(l_pcm_ind).object_tld_id;
        l_t_rltns_tbl(l_pcm_ind).relationship_type_code := 'COMPONENT-OF';
        l_t_rltns_tbl(l_pcm_ind).active_start_date      := sysdate;
        l_t_rltns_tbl(l_pcm_ind).subject_type           := 'T';
        l_t_rltns_tbl(l_pcm_ind).object_type            := 'T';
      END LOOP;

      csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
        p_api_version       => 1.0,
        p_commit            => fnd_api.g_false,
        p_init_msg_list     => fnd_api.g_true,
        p_validation_level  => fnd_api.g_valid_level_full,
        px_txn_ii_rltns_tbl => l_t_rltns_tbl,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISe fnd_api.g_exc_error;
      END IF;

    END IF; -- pcm tbl count > 0
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END rebuild_relation_for_ato;

  -- child order line instances should get hooked in to the ib trackable parent order line
  PROCEDURE build_parent_relation(
    p_order_line_rec       IN     oe_order_lines_all%rowtype,
    p_txn_line_rec         IN     csi_t_datastructures_grp.txn_line_rec,
    p_split_flag           IN     varchar2,
    p_identified_item_type IN     varchar2,
    p_config_rec           IN     config_rec,
    p_config_instances     IN     config_serial_inst_tbl,
    px_default_info_rec    IN OUT nocopy default_info_rec,
    px_csi_txn_rec         IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status           OUT nocopy varchar2)
  IS

    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl      csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl          csi_datastructures_pub.instance_tbl;

    l_line_dtl_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_t_iir_tbl             csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_parent_line_rec       oe_order_pub.line_rec_type := oe_order_pub.g_miss_line_rec;
    l_child_tld_rec         csi_t_datastructures_grp.txn_line_detail_rec;
    l_ns_tld_id             number;

    l_qty_ratio             number;

    l_instance_found        boolean;

    l_i_ind                 binary_integer := 0;
    l_object_id             number;
    l_subject_id            number;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;


    l_satisfied             varchar2(1) := 'N';
    l_qty_allocated         number;
    l_new_tld_qty           number;
    l_old_tld_qty           number;
    l_child_of_sub_ato_mdl  varchar2(1) := 'N';

    l_config_instances      config_serial_inst_tbl;

  BEGIN


    x_return_status := fnd_api.g_ret_sts_success;
    api_log('build_parent_relation');

    l_config_instances := p_config_instances;

    get_ib_trackable_parent(
      p_current_line_id   => p_txn_line_rec.source_transaction_id,
      p_om_vld_org_id     => px_default_info_rec.om_vld_org_id,
      x_parent_line_rec   => l_parent_line_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF nvl(l_parent_line_rec.line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      get_tld(
        p_source_table       => 'OE_ORDER_LINES_ALL',
        p_source_id          => p_order_line_rec.line_id,
        p_source_flag        => 'Y',
        p_processing_status  => 'IN_PROCESS',
        x_line_dtl_tbl       => l_line_dtl_tbl,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_child_of_sub_ato_mdl := 'N';

      /* if parent line id is the ATO model then switch the line id to the configs
         because the class and option items should be underneath the config item
      */
      IF ( p_identified_item_type = 'ATO_CLASS'
           AND
           p_order_line_rec.ato_line_id = l_parent_line_rec.line_id
         )
         OR
         ( p_identified_item_type = 'ATO_OPTION'
           AND
           p_order_line_rec.ato_line_id = l_parent_line_rec.line_id
         )
         OR
         ( p_identified_item_type = 'ATO_SUB_MODEL'
           AND
           p_order_line_rec.ato_line_id = l_parent_line_rec.line_id
         )
      THEN
        IF nvl(p_config_rec.line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          oe_line_util.query_row(
            p_line_id  => p_config_rec.line_id,
            x_line_rec => l_parent_line_rec);
        END IF;
      ELSE
        IF p_config_rec.sub_model_flag = 'Y'
           AND
          (l_parent_line_rec.line_id = p_config_rec.sub_model_line_id)
        THEN
          l_child_of_sub_ato_mdl := 'Y';
          debug('immediate child of an ato sub model');
          -- switch the l_config_instances with the sub_model_config_instances
          IF p_config_rec.sub_model_serial_code IN (2, 5, 6) THEN

            -- sub model is serialized so hook this line to the sub configured instances
            get_config_srl_instances(
              p_config_rec        => p_config_rec,
              p_sub_config_flag   => 'Y',
              px_default_info_rec => px_default_info_rec,
              px_csi_txn_rec      => px_csi_txn_rec,
              x_config_instances  => l_config_instances,
              x_return_status     => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;
        END IF;
      END IF;

      l_qty_ratio := p_order_line_rec.ordered_quantity/l_parent_line_rec.ordered_quantity;
      debug('  parent_child_ratio : '||l_qty_ratio);

      -- 2787905
      debug('  p_split_flag       :'||p_split_flag);
      IF p_order_line_rec.ordered_quantity > 1 THEN


        IF p_split_flag = 'N' THEN

          -- split txn_details in the ratio with the parent.
          split_txn_dtls_with_ratio(
            p_quantity_ratio => l_qty_ratio,
            px_line_dtl_tbl  => l_line_dtl_tbl,
            x_return_status  => l_return_status);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END IF;

      l_instance_found   := FALSE;

      IF l_child_of_sub_ato_mdl = 'Y' THEN
        --get sub model config instances in l_instance_tbl
        IF l_config_instances.COUNT > 0 THEN
          l_instance_found := TRUE;
          FOR lc_ind IN l_config_instances.FIRST..l_config_instances.LAST
          LOOP
            l_i_ind := l_i_ind + 1;
            l_instance_tbl(l_i_ind).instance_id := l_config_instances(lc_ind).instance_id;
          END LOOP;
        END IF;
      ELSE
        -- check if instance exists
        l_inst_query_rec.inventory_item_id     := l_parent_line_rec.inventory_item_id;
        l_inst_query_rec.last_oe_order_line_id := l_parent_line_rec.line_id;

        debug('query criteria for get_item_instances:');
        debug(' inventory_item_id     : '||l_inst_query_rec.inventory_item_id);
        debug(' last_oe_order_line_id : '||l_inst_query_rec.last_oe_order_line_id);

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
          x_msg_data             =>  l_msg_data  );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_instance_hdr_tbl.COUNT > 0 THEN
          l_instance_found := TRUE;

          debug('instances found for the parent COUNT: '||l_instance_hdr_tbl.COUNT);

          make_non_header_tbl(
            p_instance_header_tbl => l_instance_hdr_tbl,
            x_instance_tbl        => l_instance_tbl,
            x_return_status       => l_return_status);

        END IF;

      END IF;

      IF l_instance_found THEN

        IF l_parent_line_rec.item_type_code = 'CONFIG' THEN
          -- eliminate the reship parent instance because we do not want the relationship
          -- to be built.
          eliminate_reshipped_instances(
            p_config_instances  => l_config_instances,
            px_instances_tbl    => l_instance_tbl,
            x_return_status     => l_return_status);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF l_instance_tbl.COUNT > 0 THEN
          FOR l_i_ind IN l_instance_tbl.FIRST .. l_instance_tbl.LAST
          LOOP

            build_non_source_rec(
              p_transaction_line_id  => p_txn_line_rec.transaction_line_id,
              p_instance_id          => l_instance_tbl(l_i_ind).instance_id,
              px_default_info_rec    => px_default_info_rec,
              x_txn_line_dtl_id      => l_ns_tld_id,
              x_return_status        => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

            l_object_id := l_ns_tld_id;

            l_qty_allocated := 0;
            l_satisfied     := 'N';
            l_new_tld_qty   := 0;
            l_old_tld_qty   := 0;

            LOOP

              mark_and_get_src_tld(
                px_src_tld_tbl       => l_line_dtl_tbl,
                x_src_tld_rec        => l_child_tld_rec,
                x_return_status      => l_return_status);

              IF nvl(l_child_tld_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

                l_subject_id    := l_child_tld_rec.txn_line_detail_id;
                l_qty_allocated := l_qty_allocated + l_child_tld_rec.quantity;

                IF l_qty_allocated = l_qty_ratio THEN
                  l_satisfied := 'Y';
                END IF;

                IF l_qty_allocated > l_qty_ratio THEN
                  l_new_tld_qty := l_qty_allocated - l_qty_ratio;
                  l_old_tld_qty := l_child_tld_rec.quantity - l_new_tld_qty;
                  -- split the tld and add the new rec in l_line_dtl_tbl at the end
                  l_satisfied   := 'Y';
                END IF;

                l_t_iir_tbl.DELETE;

                -- build ii_rltns table
                l_t_iir_tbl(1).txn_relationship_id    := fnd_api.g_miss_num;
                l_t_iir_tbl(1).transaction_line_id    := p_txn_line_rec.transaction_line_id;
                l_t_iir_tbl(1).subject_id             := l_subject_id;
                l_t_iir_tbl(1).object_id              := l_object_id;
                l_t_iir_tbl(1).relationship_type_code := 'COMPONENT-OF';
                l_t_iir_tbl(1).active_start_date      := sysdate;
                l_t_iir_tbl(1).subject_type           := 'T';
                l_t_iir_tbl(1).object_type            := 'T';

                csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
                  p_api_version       => 1.0,
                  p_commit            => fnd_api.g_false,
                  p_init_msg_list     => fnd_api.g_true,
                  p_validation_level  => fnd_api.g_valid_level_full,
                  px_txn_ii_rltns_tbl => l_t_iir_tbl,
                  x_return_status     => l_return_status,
                  x_msg_count         => l_msg_count,
                  x_msg_data          => l_msg_data);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                IF l_satisfied = 'Y' THEN
                  exit;
                END IF;

              ELSE
                EXIT;
              END IF; -- parent_tld_rec.tld_id is found

            END LOOP; -- [quantity ratio loop]

          END LOOP; -- [instances loop]
        END IF;

      END IF; -- found parent instances

    END IF; -- found an ib trackable parent

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_parent_relation;

  PROCEDURE mark_and_get_instances(
    p_qty_ratio      IN            number,
    px_instance_tbl  IN OUT nocopy csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec   IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_instance_tbl      OUT nocopy csi_datastructures_pub.instance_tbl,
    x_return_status     OUT nocopy varchar2)
  IS
    l_satisfied      varchar2(1) := 'N';
    l_qty_allocated  number := 0;
    l_new_qty        number;
    l_old_qty        number;
    x_ind            binary_integer := 0;
    px_ind           binary_integer := 0;
--fix for bug5096435
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_new_instance_rec csi_datastructures_pub.instance_rec;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('mark_and_get_instances');

    l_satisfied := 'N';
    IF px_instance_tbl.COUNT > 0 THEN
      LOOP
        px_ind :=  px_instance_tbl.NEXT(px_ind);
        IF px_ind is null THEN
          exit;
        ELSE --fix for bug5096435
          l_qty_allocated := l_qty_allocated + px_instance_tbl(px_ind).quantity;
          IF l_qty_allocated = p_qty_ratio THEN
            l_satisfied := 'Y';
            x_ind := x_ind + 1;
            x_instance_tbl(x_ind) := px_instance_tbl(px_ind);
            px_instance_tbl.DELETE(px_ind);
          ELSIF l_qty_allocated > p_qty_ratio THEN
            -- split instances
            l_new_qty := l_qty_allocated - p_qty_ratio;
            l_satisfied := 'Y';
            l_old_qty := px_instance_tbl(px_ind).quantity - l_new_qty;
            px_instance_tbl(px_ind).quantity := l_old_qty;
	    --fix for bug5096435
            x_ind := x_ind + 1;
            x_instance_tbl(x_ind) := px_instance_tbl(px_ind);
	    debug('splitting instance ' || px_instance_tbl(px_ind).instance_id ||' based on qty '|| l_new_qty);
            split_instance(
              p_instance_id => px_instance_tbl(px_ind).instance_id,
              p_quantity    => l_new_qty,
              px_csi_txn_rec => px_csi_txn_rec,
              x_instance_rec => l_new_instance_rec,
              x_return_status => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
            debug('New instance created after splitiing : ' || l_new_instance_rec.instance_id);
          px_instance_tbl(px_instance_tbl.LAST+1) := l_new_instance_rec;
          px_instance_tbl.DELETE(px_ind);
          ELSIF l_qty_allocated < p_qty_ratio THEN
            x_ind := x_ind + 1;
            x_instance_tbl(x_ind) := px_instance_tbl(px_ind);
            px_instance_tbl.DELETE(px_ind);
            l_satisfied := 'N';
          END IF;
        END IF;
        IF l_satisfied = 'Y' THEN
            exit;
        END IF;
      END LOOP;
    END IF;
  END mark_and_get_instances;

  -- builds relation to the next level
  PROCEDURE build_child_relation(
    p_order_line_rec       IN     oe_order_lines_all%ROWTYPE,
    p_txn_line_rec         IN     csi_t_datastructures_grp.txn_line_rec,
    p_identified_item_type IN     varchar2,
    px_default_info_rec    IN OUT NOCOPY default_info_rec,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl      csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl          csi_datastructures_pub.instance_tbl;
    l_alloc_instance_tbl    csi_datastructures_pub.instance_tbl;


    l_tld_tbl               csi_t_datastructures_grp.txn_line_detail_tbl;

    l_child_line_tbl        oe_order_pub.line_tbl_type;
    l_grand_child_line_tbl  oe_order_pub.line_tbl_type;
    l_qty_ratio             number;

    l_model_order_qty       number;

    l_instance_found        boolean;

    l_ns_tld_id             number;
    l_object_id             number;
    l_subject_id            number;
    l_t_iir_tbl             csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(2000);
    l_msg_count             number;

    --fix for bug5096435
    l_order_line_qty        number;
    l_temp_child_line_rec   oe_order_pub.Line_Rec_Type;
    l_next_item_id          number := 0;
    l_temp_idx              number := 0;
    l_temp_instance_hdr_tbl csi_datastructures_pub.instance_header_tbl;
    l_temp_index            number := 0;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('build_child_relation');

    get_ib_trackable_children(
      p_current_line_id    => p_order_line_rec.line_id,
      p_om_vld_org_id      => px_default_info_rec.om_vld_org_id,
      x_trackable_line_tbl => l_child_line_tbl,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --fix for bug5096435
    --Here child_line_tbl is sorted and rearranged to ensure that
    --two/more different remnant lines of same inventory item are put together
    --in the plsql table.
    IF p_order_line_rec.model_remnant_flag = 'Y' THEN
        FOR i IN 1..l_child_line_tbl.COUNT
        LOOP
            IF l_child_line_tbl(i).model_remnant_flag = 'Y' THEN
                l_temp_index := i+1;
                FOR j IN l_temp_index..l_child_line_tbl.COUNT
                LOOP
                    IF l_child_line_tbl(j).inventory_item_id = l_child_line_tbl(i).inventory_item_id
                    AND j <> l_temp_index THEN
                        l_temp_child_line_rec := l_child_line_tbl(l_temp_index);
                        l_child_line_tbl(l_temp_index) := l_child_line_tbl(j);
                        l_child_line_tbl(j)   := l_temp_child_line_rec;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    IF l_child_line_tbl.COUNT > 0 THEN

      get_tld(
        p_source_table       => 'OE_ORDER_LINES_ALL',
        p_source_id          => p_order_line_rec.line_id,
        p_source_flag        => 'Y',
        p_processing_status  => 'IN_PROCESS',
        x_line_dtl_tbl       => l_tld_tbl,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      FOR l_ind in l_child_line_tbl.FIRST..l_child_line_tbl.LAST
      LOOP
	--fix for 5096435
        --This check ensures that we figure out quantity ratio by summing
        --order quantity,incase if remnant lines of same item are put
        --unpreportionate quantity.
        IF p_order_line_rec.model_remnant_flag = 'Y' THEN
            IF l_ind <> l_child_line_tbl.LAST THEN
                l_next_item_id := l_child_line_tbl(l_ind+1).inventory_item_id;
            ELSE
	        l_next_item_id := -99;
            END IF;
            IF l_child_line_tbl(l_ind).inventory_item_id <> l_next_item_id THEN
             BEGIN
            	select sum(ordered_quantity)
            	into l_order_line_qty
            	from oe_order_lines_all
            	where link_to_line_id = l_child_line_tbl(l_ind).link_to_line_id
            	and inventory_item_id = l_child_line_tbl(l_ind).inventory_item_id
            	and model_remnant_flag = 'Y';
             EXCEPTION
             WHEN others THEN
                NULL;
             END;
              l_qty_ratio := l_order_line_qty / p_order_line_rec.ordered_quantity;
            ELSE
              l_qty_ratio := -99;
	      debug('Remnant order line splitted across inproper qty,so qty_ratio calculated with adding ordered quantity');
            END IF;
        ELSE
            l_qty_ratio := l_child_line_tbl(l_ind).ordered_quantity/ p_order_line_rec.ordered_quantity;
        END IF;
        debug('l_qty_ratio : ' || l_qty_ratio);

        debug('  child_item_type  :'||l_child_line_tbl(l_ind).item_type_code);

        -- check if instance exists
        l_inst_query_rec.inventory_item_id     := l_child_line_tbl(l_ind).inventory_item_id;
        l_inst_query_rec.last_oe_order_line_id := l_child_line_tbl(l_ind).line_id;
	l_instance_found   := FALSE;

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
          p_active_instance_only => fnd_api.g_true,
          x_instance_header_tbl  => l_instance_hdr_tbl,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('instances found for the child order line COUNT : '||l_instance_hdr_tbl.COUNT);
        --fix for bug5096435
	IF l_instance_hdr_tbl.COUNT > 0 THEN
              debug('instances found for the child order line : '||l_instance_hdr_tbl.COUNT);
	      l_instance_found := TRUE;
        ELSE
              debug('instances not found for the child order line');
	      l_instance_found := FALSE;
        END IF;
	IF l_instance_found THEN
  	 IF nvl(p_order_line_rec.model_remnant_flag,'N') = 'Y' THEN
	      FOR i IN l_instance_hdr_tbl.FIRST..l_instance_hdr_tbl.LAST
              LOOP
               l_temp_idx := l_temp_idx + 1;
               l_temp_instance_hdr_tbl(l_temp_idx) := l_instance_hdr_tbl(i);
              END LOOP;
	    IF l_qty_ratio <> -99 THEN
                l_temp_idx := 0;
            END IF;
         ELSE
           l_temp_instance_hdr_tbl := l_instance_hdr_tbl;
         END IF;
	END IF;
      --Here we ensure that we go for building non-source rec only after accumulating
      --all the instances created among two/more remnant lines belonging to same inv item.
      IF nvl(p_order_line_rec.model_remnant_flag,'N') <> 'Y' OR
        (p_order_line_rec.model_remnant_flag = 'Y' AND l_qty_ratio <> -99) THEN
        IF l_temp_instance_hdr_tbl.COUNT > 0 THEN

          make_non_header_tbl(
            p_instance_header_tbl => l_temp_instance_hdr_tbl,       --end of fix for bug5096435
            x_instance_tbl        => l_instance_tbl,
            x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;

          l_temp_instance_hdr_tbl.DELETE;
          FOR t_ind IN l_tld_tbl.FIRST .. l_tld_tbl.LAST
          LOOP
            --fix for bug5096435
	    IF l_instance_tbl.COUNT = 0 THEN
                EXIT;
            END IF;

            mark_and_get_instances(
              p_qty_ratio      => l_qty_ratio,
              px_instance_tbl  => l_instance_tbl,
              px_csi_txn_rec   => px_csi_txn_rec,
              x_instance_tbl   => l_alloc_instance_tbl,
              x_return_status  => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            FOR a_ind IN l_alloc_instance_tbl.FIRST .. l_alloc_instance_tbl.LAST
            LOOP

              build_non_source_rec(
                p_transaction_line_id => p_txn_line_rec.transaction_line_id,
                p_instance_id         => l_alloc_instance_tbl(a_ind).instance_id,
                px_default_info_rec   => px_default_info_rec,
                x_txn_line_dtl_id     => l_ns_tld_id,
                x_return_status       => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              l_object_id  := l_tld_tbl(t_ind).txn_line_detail_id;
              l_subject_id := l_ns_tld_id;

              -- create ii_relationship
              l_t_iir_tbl.DELETE;
              -- build ii_rltns table
              l_t_iir_tbl(1).txn_relationship_id    := fnd_api.g_miss_num;
              l_t_iir_tbl(1).transaction_line_id    := p_txn_line_rec.transaction_line_id;
              l_t_iir_tbl(1).subject_id             := l_subject_id;
              l_t_iir_tbl(1).object_id              := l_object_id;
              l_t_iir_tbl(1).relationship_type_code := 'COMPONENT-OF';
              l_t_iir_tbl(1).active_start_date      := sysdate;
              l_t_iir_tbl(1).subject_type           := 'T';
              l_t_iir_tbl(1).object_type            := 'T';

              csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
                p_api_version       => 1.0,
                p_commit            => fnd_api.g_false,
                p_init_msg_list     => fnd_api.g_true,
                p_validation_level  => fnd_api.g_valid_level_full,
                px_txn_ii_rltns_tbl => l_t_iir_tbl,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            END LOOP; --<<end of l_alloc_instance_tbl>>

          END LOOP; --<<end of l_tld_tbl>>
        END IF; --<<end if l_temp_instance_hdr_tbl.COUNT > 0 >>
        END IF; --<<end if remnant condition >>
      END LOOP; --<<end of l_child_line_tbl>>
    END IF; --<<end if l_child_line_tbl.COUNT > 0>>

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_child_relation;

  /* the wip issued instances for the ato options using the configured item  */
  /* to wip job link and converts them as customer products and build the    */
  /* component of relationship with the parent (ato oc or the config item)   */

  PROCEDURE process_ato_option_nsrl(
    p_order_hdr_rec     IN  oe_order_headers_all%rowtype,
    p_order_line_rec    IN  oe_order_lines_all%rowtype,
    p_config_rec        IN  config_rec,
    p_tld_tbl           IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    px_default_info_rec IN OUT nocopy default_info_rec,
    x_return_status        OUT nocopy Varchar2)
  IS

    l_csi_txn_rec           csi_datastructures_pub.transaction_rec;

    l_parent_line_rec       oe_order_pub.line_rec_type;
    l_option_serial_code    number;

    l_wip_instances         wip_instances;
    l_parent_instances      parent_instances;

    l_config_instances      config_serial_inst_tbl;

    l_qty_ratio             number;

    l_ii_rltns_tbl          csi_datastructures_pub.ii_relationship_tbl;
    l_ind                   binary_integer;
    l_msg_count             number;
    l_msg_data              varchar2(2000);
    l_return_status         varchar2(1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('process_ato_option_nsrl');

    --assign the values for the csi_txn_rec
    l_csi_txn_rec.source_line_ref_id      := p_order_line_rec.line_id;
    l_csi_txn_rec.source_line_ref         := p_order_line_rec.line_number||'.'||
                                             p_order_line_rec.shipment_number||'.'||
                                             p_order_line_rec.option_number;
    l_csi_txn_rec.source_header_ref_id    := p_order_line_rec.header_id;
    l_csi_txn_rec.source_header_ref       := p_order_hdr_rec.order_number;
    l_csi_txn_rec.transaction_type_id     := 51;
    l_csi_txn_rec.transaction_date        := sysdate;
    l_csi_txn_rec.source_transaction_date := nvl(p_order_line_rec.fulfillment_date, sysdate);
    l_csi_txn_rec.transaction_status_code := 'PENDING';

    BEGIN

      SELECT serial_number_control_code
      INTO   l_option_serial_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_order_line_rec.inventory_item_id
      AND    organization_id   = p_order_line_rec.ship_from_org_id;

    END;

    get_wip_instances(
      p_wip_entity_id      => p_config_rec.config_wip_job_id,
      p_inventory_item_id  => p_order_line_rec.inventory_item_id,
      p_organization_id    => p_config_rec.ship_organization_id,
      p_option_serial_code => l_option_serial_code,
      p_config_rec         => p_config_rec,
      px_csi_txn_rec       => l_csi_txn_rec,
      x_wip_instances      => l_wip_instances,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    /* get the ib_trackable parent for the option item line */
    csi_order_fulfill_pub.get_ib_trackable_parent(
      p_current_line_id   => p_order_line_rec.line_id,
      p_om_vld_org_id     => px_default_info_rec.om_vld_org_id,
      x_parent_line_rec   => l_parent_line_rec,
      x_return_status     => l_return_status);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_parent_instances.DELETE;

    IF nvl(l_parent_line_rec.line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      l_qty_ratio := p_order_line_rec.ordered_quantity/l_parent_line_rec.ordered_quantity;

      debug('  parent_child_ratio :'||l_qty_ratio);

      -- if the trackable parent is the ato model then build the relation
      IF l_parent_line_rec.line_id = p_order_line_rec.ato_line_id THEN
      -- build relation between the config line and option items from wip

        debug('parent is ATO Model, switching the parent to the config line.');

        get_parent_instances(
          p_parent_line_id     => p_config_rec.line_id,
          p_parent_item_id     => p_config_rec.item_id,
          x_parent_instances   => l_parent_instances,
          x_return_status      => l_return_status);

      ELSE

        IF l_parent_line_rec.item_type_code = 'CLASS' THEN

          -- build relation with the ATO option class
          -- from the fulfillment interface for the option class
          -- we need to tie the ato option class to the config and not to the model.

          debug('  parent is ATO class.');

          get_parent_instances(
            p_parent_line_id     => l_parent_line_rec.line_id,
            p_parent_item_id     => l_parent_line_rec.inventory_item_id,
            x_parent_instances   => l_parent_instances,
            x_return_status      => l_return_status);

        END IF;

      END IF;

      debug('  parent_instances count : '||l_parent_instances.COUNT);

    END IF;

    get_wip_instances_for_line(
      p_option_line_rec    => p_order_line_rec,
      p_parent_line_rec    => l_parent_line_rec,
      p_option_serial_code => l_option_serial_code,
      p_class_option_ratio => l_qty_ratio,
      p_config_rec         => p_config_rec,
      p_config_instances   => l_config_instances,
      px_csi_txn_rec       => l_csi_txn_rec,
      px_wip_instances     => l_wip_instances,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_wip_instances.COUNT > 0 THEN

      stamp_om_line_for_options(
        p_order_hdr_rec     => p_order_hdr_rec,
        p_order_line_rec    => p_order_line_rec,
        p_wip_instances     => l_wip_instances,
        p_tld_tbl           => p_tld_tbl,
        px_default_info_rec => px_default_info_rec,
        px_csi_txn_rec      => l_csi_txn_rec,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_parent_instances.COUNT > 0 THEN
        distribute_wip_instances(
          p_qty_ratio          => l_qty_ratio,
          p_option_serial_code => l_option_serial_code,
          p_parent_line_rec    => l_parent_line_rec,
          p_parent_instances   => l_parent_instances,
          p_wip_instances      => l_wip_instances,
          px_default_info_rec  => px_default_info_rec,
          x_ii_rltns_tbl       => l_ii_rltns_tbl,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

    END IF;

    IF l_ii_rltns_tbl.count > 0 THEN

      csi_t_gen_utility_pvt.dump_csi_ii_rltns_tbl(l_ii_rltns_tbl);

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_ii_relationships_pub',
        p_api_name => 'create_relationship');

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

    debug('Order Fulfillment of ATO option item successful.');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others then
      fnd_message.set_name ('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', substr(sqlerrm, 1, 300));
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END process_ato_option_nsrl;

  PROCEDURE mark_and_get_class_instance(
    p_option_serial_code IN         number,
    p_config_instance_id IN         number,
    p_class_item_id      IN         number,
    p_class_option_ratio IN         number,
    px_class_instances   IN  OUT nocopy parent_instances,
    x_class_instance         OUT nocopy parent_instance,
    x_return_status          OUT nocopy varchar2)
  IS
    CURSOR class_inst_cur IS
      SELECT cii.instance_id,
             cir.relationship_id,
             cir.object_version_number
      FROM   csi_item_instances   cii,
             csi_ii_relationships cir
      WHERE  cir.object_id              = p_config_instance_id
      AND    cir.relationship_type_code = 'COMPONENT-OF'
      AND    cii.instance_id            = cir.subject_id
      AND    cii.inventory_item_id      = p_class_item_id;

      l_class_instance parent_instance;
      l_temp_ratio     number;
      l_delete_flag    varchar2(1);

    PROCEDURE srl_get_and_delete(
      p_instance_id        IN     number,
      p_class_option_ratio IN     number,
      px_class_instances   IN OUT nocopy parent_instances,
      x_class_instance        OUT nocopy parent_instance)
    IS
      l_ind binary_integer := 0;
    BEGIN
      IF px_class_instances.COUNT > 0 THEN
        l_ind := 0;
        LOOP
          l_ind := px_class_instances.NEXT(l_ind);
          EXIT WHEN l_ind is null;
          IF px_class_instances(l_ind).instance_id = p_instance_id THEN
            x_class_instance := px_class_instances(l_ind);
            px_class_instances(l_ind).alloc_count := px_class_instances(l_ind).alloc_count + 1;
            IF px_class_instances(l_ind).alloc_count = p_class_option_ratio THEN
              px_class_instances.DELETE(l_ind);
            END IF;
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END srl_get_and_delete;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('mark_and_get_class_instance');

    FOR class_inst_rec IN class_inst_cur
    LOOP

      srl_get_and_delete (
        p_instance_id        => class_inst_rec.instance_id,
        p_class_option_ratio => p_class_option_ratio,
        px_class_instances   => px_class_instances,
        x_class_instance     => l_class_instance);

      IF l_class_instance.instance_id is not null THEN
        x_class_instance := l_class_instance;
        x_class_instance.relationship_id := class_inst_rec.relationship_id;
        x_class_instance.relationship_ovn := class_inst_rec.object_version_number;

        debug('  class_instance_id  : '||l_class_instance.instance_id);
        debug('  instance_quantity  : '||l_class_instance.quantity);

        EXIT;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END mark_and_get_class_instance;

  PROCEDURE get_config_parent(
    p_wip_instance       IN         wip_instance,
    p_config_rec         IN         config_rec,
    x_config_instance    OUT nocopy config_serial_inst_rec,
    x_return_status      OUT nocopy varchar2)
  IS

    l_ii_rltns_qry_rec       csi_datastructures_pub.relationship_query_rec;
    l_ii_rltns_tbl           csi_datastructures_pub.ii_relationship_tbl;
    l_time_stamp             date := null;

    l_config_instance        config_serial_inst_rec;

    l_msg_count              number      := 0;
    l_msg_data               varchar2(2000);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR inst_cur(p_instance_id IN number) IS
      SELECT instance_id,
             serial_number,
             location_type_code
      FROM   csi_item_instances
      WHERE  instance_id       = p_instance_id
      AND    inventory_item_id = p_config_rec.item_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_parent');

    l_ii_rltns_qry_rec.subject_id             := p_wip_instance.instance_id;
    l_ii_rltns_qry_rec.relationship_type_code := 'COMPONENT-OF';

    debug('  subject_id         : '||l_ii_rltns_qry_rec.subject_id);
    debug('  relationship_type  : '||l_ii_rltns_qry_rec.relationship_type_code);

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_ii_relationships_pub',
      p_api_name => 'get_relationships');

    csi_ii_relationships_pub.get_relationships(
      p_api_version               => 1.0,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_relationship_query_rec    => l_ii_rltns_qry_rec,
      p_depth                     => 1,
      p_time_stamp                => l_time_stamp,
      p_active_relationship_only  => fnd_api.g_true,
      x_relationship_tbl          => l_ii_rltns_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  ii_rltns_tbl count : '||l_ii_rltns_tbl.COUNT);

    IF l_ii_rltns_tbl.COUNT > 0 THEN
      FOR l_ind IN l_ii_rltns_tbl.FIRST .. l_ii_rltns_tbl.LAST
      LOOP
        FOR inst_rec IN inst_cur(l_ii_rltns_tbl(l_ind).object_id)
        LOOP
          l_config_instance.instance_id        := inst_rec.instance_id;
          l_config_instance.serial_number      := inst_rec.serial_number;
          l_config_instance.location_type_code := inst_rec.location_type_code;
          l_config_instance.relationship_id    := l_ii_rltns_tbl(l_ind).relationship_id;
          l_config_instance.relationship_ovn   := l_ii_rltns_tbl(l_ind).object_version_number;
        END LOOP;
      END LOOP;
    END IF;

    debug('parent_config_rec    >');
    debug('  instance_id        : '||l_config_instance.instance_id);
    debug('  serial_number      : '||l_config_instance.serial_number);
    debug('  location_type_code : '||l_config_instance.location_type_code);
    debug('  relationship_id    : '||l_config_instance.relationship_id);
    debug('  relationship_ovn   : '||l_config_instance.relationship_ovn);

    x_config_instance := l_config_instance;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_config_parent;

  /* This routine is invoked from the fulfillment of ATO options of serialized*/
  /* Identifies the wip issued instances that are tied in relation with the   */
  /* serialized config and re-builds the relation with the OC if OC is IB     */
  /* trackable. Assy Component Relations are build at the WIP completion event*/
  PROCEDURE process_ato_option_srl(
    p_order_hdr_rec     IN  oe_order_headers_all%rowtype,
    p_order_line_rec    IN  oe_order_lines_all%rowtype,
    p_config_rec        IN  config_rec,
    p_config_instances  IN  config_serial_inst_tbl,
    p_tld_tbl           IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    px_default_info_rec IN OUT nocopy default_info_rec,
    x_return_status        OUT nocopy varchar2)
  IS

    l_csi_txn_rec           csi_datastructures_pub.transaction_rec;

    l_parent_line_rec       oe_order_pub.line_rec_type;
    l_option_serial_code    number;

    l_wip_instances         wip_instances;
    l_parent_instances      parent_instances;
    l_class_instance        parent_instance;

    l_class_option_ratio    number;
    l_config_class_ratio    number;

    l_config_parent         config_serial_inst_rec;

    l_exp_rltns_rec         csi_datastructures_pub.ii_relationship_rec;
    l_instance_id_lst       csi_datastructures_pub.id_tbl;

    l_ii_rltns_tbl          csi_datastructures_pub.ii_relationship_tbl;
    l_ii_ind                binary_integer := 0;

    l_msg_count             number;
    l_msg_data              varchar2(2000);
    l_return_status         varchar2(1);

    do_nothing              exception;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('process_ato_option_srl');

    --assign the values for the csi_txn_rec
    l_csi_txn_rec.source_line_ref_id      := p_order_line_rec.line_id;
    l_csi_txn_rec.source_line_ref         := p_order_line_rec.line_number||'.'||
                                             p_order_line_rec.shipment_number||'.'||
                                             p_order_line_rec.option_number;
    l_csi_txn_rec.source_header_ref_id    := p_order_line_rec.header_id;
    l_csi_txn_rec.source_header_ref       := p_order_hdr_rec.order_number;
    l_csi_txn_rec.transaction_type_id     := 51;
    l_csi_txn_rec.transaction_date        := sysdate;
    l_csi_txn_rec.source_transaction_date := nvl(p_order_line_rec.fulfillment_date, sysdate);
    l_csi_txn_rec.transaction_status_code := 'PENDING';

    SELECT serial_number_control_code
    INTO   l_option_serial_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_order_line_rec.inventory_item_id
    AND    organization_id   = p_order_line_rec.ship_from_org_id;

    get_wip_instances(
      p_wip_entity_id      => p_config_rec.config_wip_job_id,
      p_inventory_item_id  => p_order_line_rec.inventory_item_id,
      p_organization_id    => p_config_rec.ship_organization_id,
      p_option_serial_code => l_option_serial_code,
      p_config_rec         => p_config_rec,
      px_csi_txn_rec       => l_csi_txn_rec,
      x_wip_instances      => l_wip_instances,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('wip_instances count  :'||l_wip_instances.COUNT);

    /* get the ib_trackable parent for the option item line */
    csi_order_fulfill_pub.get_ib_trackable_parent(
      p_current_line_id   => p_order_line_rec.line_id,
      p_om_vld_org_id     => px_default_info_rec.om_vld_org_id,
      x_parent_line_rec   => l_parent_line_rec,
      x_return_status     => l_return_status);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_parent_instances.DELETE;

    IF nvl(l_parent_line_rec.line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      -- if the trackable parent is the ato model then do nothing
      IF l_parent_line_rec.line_id = p_order_line_rec.ato_line_id THEN

        -- stamp order line on the option instances
        stamp_om_line_for_options(
          p_order_hdr_rec     => p_order_hdr_rec,
          p_order_line_rec    => p_order_line_rec,
          p_wip_instances     => l_wip_instances,
          p_tld_tbl           => p_tld_tbl,
          px_default_info_rec => px_default_info_rec,
          px_csi_txn_rec      => l_csi_txn_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        RAISE do_nothing;
      ELSE

        IF l_parent_line_rec.item_type_code = 'CLASS' THEN

          debug('  parent is ato class');
          l_class_option_ratio := p_order_line_rec.ordered_quantity/l_parent_line_rec.ordered_quantity;
          debug('  class_option_ratio : '||l_class_option_ratio);

          l_config_class_ratio := l_parent_line_rec.ordered_quantity/
                                  p_config_rec.order_quantity;
          debug('  config_class_ratio : '||l_config_class_ratio);

          -- build relation with the ATO option class
          -- from the fulfillment interface for the option class
          -- we need to tie the ato option class to the config and not to the model.

          get_parent_instances(
            p_parent_line_id     => l_parent_line_rec.line_id,
            p_parent_item_id     => l_parent_line_rec.inventory_item_id,
            x_parent_instances   => l_parent_instances,
            x_return_status      => l_return_status);

        END IF;

      END IF;

      debug('  parent_instances count : '||l_parent_instances.COUNT);

    END IF;

    get_wip_instances_for_line(
      p_option_line_rec    => p_order_line_rec,
      p_parent_line_rec    => l_parent_line_rec,
      p_option_serial_code => l_option_serial_code,
      p_class_option_ratio => l_class_option_ratio,
      p_config_rec         => p_config_rec,
      p_config_instances   => p_config_instances,
      px_csi_txn_rec       => l_csi_txn_rec,
      px_wip_instances     => l_wip_instances,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_wip_instances.COUNT > 0 THEN
      stamp_om_line_for_options(
        p_order_hdr_rec     => p_order_hdr_rec,
        p_order_line_rec    => p_order_line_rec,
        p_wip_instances     => l_wip_instances,
        p_tld_tbl           => p_tld_tbl,
        px_default_info_rec => px_default_info_rec,
        px_csi_txn_rec      => l_csi_txn_rec,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF l_parent_instances.COUNT > 0 THEN
      IF l_wip_instances.COUNT > 0 THEN

        IF l_option_serial_code in (2, 5, 6) THEN

          FOR l_w_ind IN l_wip_instances.FIRST .. l_wip_instances.LAST
          LOOP

            get_config_parent(
              p_wip_instance    => l_wip_instances(l_w_ind),
              p_config_rec      => p_config_rec,
              x_config_instance => l_config_parent,
              x_return_status   => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            mark_and_get_class_instance(
              p_option_serial_code => l_option_serial_code,
              p_config_instance_id => l_config_parent.instance_id,
              p_class_item_id      => l_parent_line_rec.inventory_item_id,
              p_class_option_ratio => l_class_option_ratio,
              px_class_instances   => l_parent_instances,
              x_class_instance     => l_class_instance,
              x_return_status      => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_class_instance.instance_id is not null THEN
              l_ii_ind := l_ii_ind + 1;
              l_ii_rltns_tbl(l_ii_ind).relationship_id := fnd_api.g_miss_num;
              l_ii_rltns_tbl(l_ii_ind).relationship_type_code := 'COMPONENT-OF';
              l_ii_rltns_tbl(l_ii_ind).object_id       := l_class_instance.instance_id;
              l_ii_rltns_tbl(l_ii_ind).subject_id      := l_wip_instances(l_w_ind).instance_id;
              l_ii_rltns_tbl(l_ii_ind).cascade_ownership_flag :=
                                       px_default_info_rec.cascade_owner_flag;
            END IF;

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_config_parent.relationship_id is not null THEN

              break_relation(
                p_relationship_id  => l_config_parent.relationship_id,
                p_relationship_ovn => l_config_parent.relationship_ovn,
                px_csi_txn_rec     => l_csi_txn_rec,
                x_return_status    => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

          END LOOP;

        ELSE

          FOR l_w_ind IN l_wip_instances.FIRST .. l_wip_instances.LAST
          LOOP

            get_config_parent(
              p_wip_instance    => l_wip_instances(l_w_ind),
              p_config_rec      => p_config_rec,
              x_config_instance => l_config_parent,
              x_return_status   => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            mark_and_get_class_instance(
              p_option_serial_code => l_option_serial_code,
              p_config_instance_id => l_config_parent.instance_id,
              p_class_item_id      => l_parent_line_rec.inventory_item_id,
              p_class_option_ratio => 1,
              px_class_instances   => l_parent_instances,
              x_class_instance     => l_class_instance,
              x_return_status      => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

            IF l_class_instance.instance_id is not null THEN
              l_ii_ind := l_ii_ind + 1;
              l_ii_rltns_tbl(l_ii_ind).relationship_id := fnd_api.g_miss_num;
              l_ii_rltns_tbl(l_ii_ind).relationship_type_code := 'COMPONENT-OF';
              l_ii_rltns_tbl(l_ii_ind).object_id       := l_class_instance.instance_id;
              l_ii_rltns_tbl(l_ii_ind).subject_id      := l_wip_instances(l_w_ind).instance_id;
              l_ii_rltns_tbl(l_ii_ind).cascade_ownership_flag := px_default_info_rec.cascade_owner_flag;
            END IF;

            IF l_config_parent.relationship_id is not null THEN

              break_relation(
                p_relationship_id  => l_config_parent.relationship_id,
                p_relationship_ovn => l_config_parent.relationship_ovn,
                px_csi_txn_rec     => l_csi_txn_rec,
                x_return_status    => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

          END LOOP;
        END IF;

      END IF;
    END IF;

    IF l_ii_rltns_tbl.count > 0 THEN

      csi_t_gen_utility_pvt.dump_csi_ii_rltns_tbl(l_ii_rltns_tbl);

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_ii_relationships_pub',
        p_api_name => 'create_relationship');

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

    debug('Order Fulfillment of ATO option item successful.');

  EXCEPTION
    WHEN do_nothing THEN
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others then
      fnd_message.set_name ('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', substr(sqlerrm, 1, 300));
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END process_ato_option_srl;

  -- for ato options that are processed from wip
  PROCEDURE process_ato_option_from_wip(
    p_order_header_rec  IN            oe_order_headers_all%rowtype,
    p_order_line_rec    IN            oe_order_lines_all%rowtype,
    p_config_rec        IN            config_rec,
    p_config_instances  IN            config_serial_inst_tbl,
    px_default_info_rec IN OUT nocopy default_info_rec,
    x_wip_processing       OUT NOCOPY boolean,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_wip_processing        boolean := TRUE;
    l_src_tld_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_transaction_line_id   number;
    l_mdl_ordered_qty       number;
    l_model_hierarchy       varchar2(100);
    l_qty_ratio		    number; --declared for bug5096435

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('process_ato_option_from_wip');

    l_wip_processing  := TRUE;

    -- check wip requirement and see if this option is set as a phantom item in BOM.
    -- if yes then just allow the fulfillment

    IF p_config_rec.sub_model_flag = 'Y'
       AND
       p_config_rec.sub_model_wip_supply_type <> 6  -- non phantom
       AND
       p_config_rec.sub_config_wip_job_id is not null
    THEN
      check_wip_requirements(
        p_wip_entity_id  => p_config_rec.sub_config_wip_job_id,
        p_option_item_id => p_order_line_rec.inventory_item_id,
        x_wip_processing => l_wip_processing);
    ELSE
      check_wip_requirements(
        p_wip_entity_id  => p_config_rec.config_wip_job_id,
        p_option_item_id => p_order_line_rec.inventory_item_id,
        x_wip_processing => l_wip_processing);
    END IF;

    x_wip_processing := l_wip_processing;

    IF l_wip_processing THEN

      BEGIN
        SELECT transaction_line_id
        INTO   l_transaction_line_id
        FROM   csi_t_transaction_lines
        WHERE  source_transaction_table = 'OE_ORDER_LINES_ALL'
        AND    source_transaction_id    = p_order_line_rec.line_id;
      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            SELECT transaction_line_id
            INTO   l_transaction_line_id
            FROM   csi_t_transaction_lines
            WHERE  source_transaction_table = 'OE_ORDER_LINES_ALL'
            AND    source_transaction_id    = p_order_line_rec.top_model_line_id;

            SELECT ordered_quantity
            INTO   l_mdl_ordered_qty
            FROM   oe_order_lines_all
            WHERE  line_id = p_order_line_rec.top_model_line_id;

    	    --Fix for bug5096435
	    SELECT sum(ordered_quantity)/l_mdl_ordered_qty
	    INTO l_qty_ratio
	    FROM oe_order_lines_all
	    WHERE link_to_line_id = p_order_line_rec.link_to_line_id
	    AND inventory_item_id = p_order_line_rec.inventory_item_id;

            SELECT to_char(p_order_line_rec.top_model_line_id)||':'||
                   to_char(p_order_line_rec.line_id)||':'||
                   to_char(p_order_line_rec.inventory_item_id)||':'||
                   decode(nvl(p_order_line_rec.item_revision, '###'), '###',
                            null, p_order_line_rec.item_revision||':')||
                   to_char(l_qty_ratio)||':'||
                   p_order_line_rec.order_quantity_uom ||':'||
                   p_order_line_rec.ordered_quantity  --added for bug5096435
            INTO   l_model_hierarchy
            FROM  sys.dual;

            debug('  model hierarchy string: '||l_model_hierarchy);

            csi_t_utilities_pvt.cascade_child(
              p_data_string    => l_model_hierarchy,
              x_return_status  => l_return_status );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              l_transaction_line_id := null;
          END;
      END;

      IF l_transaction_line_id is not null THEN
        get_tld(
          p_source_table       => 'OE_ORDER_LINES_ALL',
          p_source_id          => p_order_line_rec.line_id,
          p_source_flag        => 'Y',
          p_processing_status  => 'UNPROCESSED',
          x_line_dtl_tbl       => l_src_tld_tbl,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      IF p_config_rec.serial_code in (1, 6) THEN

        process_ato_option_nsrl(
          p_order_hdr_rec     => p_order_header_rec,
          p_order_line_rec    => p_order_line_rec,
          p_config_rec        => p_config_rec,
          p_tld_tbl           => l_src_tld_tbl,
          px_default_info_rec => px_default_info_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSIF p_config_rec.serial_code IN (2,5) THEN

        process_ato_option_srl(
          p_order_hdr_rec     => p_order_header_rec,
          p_order_line_rec    => p_order_line_rec,
          p_config_rec        => p_config_rec,
          p_config_instances  => p_config_instances,
          p_tld_tbl           => l_src_tld_tbl,
          px_default_info_rec => px_default_info_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END process_ato_option_from_wip;

  PROCEDURE get_source_tlds(
    p_tld_tbl           IN         csi_t_datastructures_grp.txn_line_detail_tbl,
    x_src_tld_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_src_tld_total_qty OUT NOCOPY number)
  IS
    l_src_tld_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_src_ind           binary_integer := 0;
    l_src_tld_total_qty number         := 0;
  BEGIN
    IF p_tld_tbl.COUNT > 0 THEN
      FOR l_ind IN  p_tld_tbl.FIRST .. p_tld_tbl.LAST
      LOOP
        IF p_tld_tbl(l_ind).source_transaction_flag = 'Y' THEN
          l_src_ind := l_src_ind + 1;
          l_src_tld_tbl(l_src_ind) := p_tld_tbl(l_ind);
          l_src_tld_total_qty      := l_src_tld_total_qty + p_tld_tbl(l_ind).quantity;
        END IF;
      END LOOP;
    END IF;
    x_src_tld_tbl       := l_src_tld_tbl;
    x_src_tld_total_qty := l_src_tld_total_qty;
  END get_source_tlds;

  -- bug 4966316 - item instance ownership conversion...

  PROCEDURE demo_fulfillment(
    p_txn_type_id    IN     number,
    p_order_line_rec IN     oe_order_lines_all%rowtype,
    p_line_dtl_tbl   IN     csi_t_datastructures_grp.txn_line_detail_tbl,
    px_csi_txn_rec   IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status     OUT nocopy varchar2)
  IS

    l_csi_txn_rec            csi_datastructures_pub.transaction_rec;

    l_txn_line_query_rec     csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl            csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl          csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl        csi_t_datastructures_grp.txn_systems_tbl;
    l_csi_ea_tbl             csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl            csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;

    l_instance_rec           csi_datastructures_pub.instance_header_rec;
    l_party_header_tbl       csi_datastructures_pub.party_header_tbl;
    l_account_header_tbl     csi_datastructures_pub.party_account_header_tbl;
    l_org_assignments_tbl    csi_datastructures_pub.org_units_header_tbl;
    l_pricing_attrib_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_ext_attrib_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_ext_attrib_def_tbl     csi_datastructures_pub.extend_attrib_tbl;
    l_asset_assignment_tbl   csi_datastructures_pub.instance_asset_header_tbl;

    l_u_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_u_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_u_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_u_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_u_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_u_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_u_eav_tbl              csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    l_time_stamp             date;

    l_td_owner_id            number;
    l_td_owner_type          csi_i_parties.party_source_table%TYPE;
    l_inst_owner_id          number;
    l_inst_owner_type        csi_i_parties.party_source_table%TYPE;
    l_internal_party_id      number;
    l_ownership_override     varchar2(1) := 'N';
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data               varchar2(2000);
    l_msg_count              number;
    l_inst_loc_id            number;
    l_inst_loc_type          csi_item_instances.location_type_code%TYPE;
    l_split_new_inst_rec     csi_datastructures_pub.instance_rec;
    l_split_src_inst_rec     csi_datastructures_pub.instance_rec;
    l_quantity1              NUMBER;
    l_vld_orgn_id            number;

  BEGIN

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'demo_fulfillment',
      p_pkg_name => 'csi_order_fulfill_pub');

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_ownership_override := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;

    -- create csi_transaction
    create_csi_transaction(
      px_csi_txn_rec   => px_csi_txn_rec,
      x_return_status  => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN p_line_dtl_tbl.FIRST ..p_line_dtl_tbl.LAST
      LOOP
        IF nvl(p_line_dtl_tbl(l_td_ind).instance_id, fnd_api.g_miss_num)
                 <> fnd_api.g_miss_num
        THEN

          l_txn_line_detail_query_rec.txn_line_detail_id :=
            p_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          csi_t_txn_details_grp.get_transaction_details(
            p_api_version                => 1,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_txn_line_query_rec         => l_txn_line_query_rec,
            p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
            x_txn_line_detail_tbl        => l_line_dtl_tbl,
            p_get_parties_flag           => fnd_api.g_true,
            x_txn_party_detail_tbl       => l_pty_dtl_tbl,
            p_get_pty_accts_flag         => fnd_api.g_true,
            x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
            p_get_ii_rltns_flag          => fnd_api.g_false,
            x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
            p_get_org_assgns_flag        => fnd_api.g_false,
            x_txn_org_assgn_tbl          => l_org_assgn_tbl,
            p_get_ext_attrib_vals_flag   => fnd_api.g_false,
            x_txn_ext_attrib_vals_tbl    => l_txn_ext_attrib_tbl,
            p_get_csi_attribs_flag       => fnd_api.g_false,
            x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
            p_get_csi_iea_values_flag    => fnd_api.g_false,
            x_csi_iea_values_tbl         => l_csi_eav_tbl,
            p_get_txn_systems_flag       => fnd_api.g_false,
            x_txn_systems_tbl            => l_txn_systems_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Get transaction details failed for RMA Fulfillment.');
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_pty_dtl_tbl.COUNT > 0 THEN
            FOR l_ind IN l_pty_dtl_tbl.FIRST..l_pty_dtl_tbl.LAST
            LOOP
              IF l_pty_dtl_tbl(l_ind).relationship_type_code = 'OWNER' THEN
                l_td_owner_id   := l_pty_dtl_tbl(l_ind).party_source_id;
                l_td_owner_type := l_pty_dtl_tbl(l_ind).party_source_table;
                exit;
              END IF;
            END LOOP;
          ELSE
            debug('Party not found. Txn Line Dtl ID:'||p_line_dtl_tbl(l_td_ind).txn_line_detail_id);
            l_td_owner_id   := null;
            l_td_owner_type := null;
            --RAISE fnd_api.g_exc_error;
          END IF;

          l_instance_rec.instance_id := l_line_dtl_tbl(1).instance_id;

          csi_item_instance_pub.get_item_instance_details(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_get_parties           => fnd_api.g_true,
            p_party_header_tbl      => l_party_header_tbl,
            p_get_accounts          => fnd_api.g_true,
            p_account_header_tbl    => l_account_header_tbl,
            p_get_org_assignments   => fnd_api.g_false,
            p_org_header_tbl        => l_org_assignments_tbl,
            p_get_pricing_attribs   => fnd_api.g_false,
            p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
            p_get_ext_attribs       => fnd_api.g_false,
            p_ext_attrib_tbl        => l_ext_attrib_tbl,
            p_ext_attrib_def_tbl    => l_ext_attrib_def_tbl,
            p_get_asset_assignments => fnd_api.g_false,
            p_asset_header_tbl      => l_asset_assignment_tbl,
            p_time_stamp            => l_time_stamp,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Get item instance details failed for RMA Fulfillment.');
            RAISE fnd_api.g_exc_error;
          END IF;

          l_inst_loc_type := l_instance_rec.location_type_code;
          l_inst_loc_id   := l_instance_rec.location_id;

          IF nvl(l_line_dtl_tbl(1).inv_organization_id, fnd_api.g_miss_num)
                 <> fnd_api.g_miss_num
             AND l_instance_rec.vld_organization_id <> l_line_dtl_tbl(1).inv_organization_id
          THEN
            l_vld_orgn_id   := l_line_dtl_tbl(1).inv_organization_id; -- FP fix for bug 5072107
            IF l_instance_rec.inv_master_organization_id = l_line_dtl_tbl(1).inv_organization_id
            THEN
               -- this assignment is done so that conversion txns need not have the same
               -- shipped orgn context and ok as long as the master is the same
               -- addtl. check since the TLD rec will have the OM Master / Vldn Orgn
               -- as the inv_organization_id on it for Fulfillments.
               l_vld_orgn_id := l_instance_rec.vld_organization_id;
            ELSE
               fnd_message.set_name('CSI','CSI_INVALID_VLD_MAST_COMB');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          /* loop thru the party table to figure out the Instance Owner  */
          IF l_party_header_tbl.COUNT > 0 THEN
            FOR l_ind IN l_party_header_tbl.FIRST..l_party_header_tbl.LAST
            LOOP
              IF l_party_header_tbl(l_ind).relationship_type_code = 'OWNER' THEN
                l_inst_owner_id   := l_party_header_tbl(l_ind).party_id;
                l_inst_owner_type := l_party_header_tbl(l_ind).party_source_table;
                exit;
              END IF;
            END LOOP;
          ELSE
            debug('Party not found. Instance:'||l_instance_rec.instance_id);
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('Instance ID                : '||l_instance_rec.instance_id);
          debug('Instance owner party type  : '||l_inst_owner_type);
          debug('Instance owner party       : '||l_inst_owner_id);
          debug('Txn detail owner party type: '||l_td_owner_type);
          debug('Txn detail owner party     : '||l_td_owner_id);
          debug('Internal party             : '||l_internal_party_id);
          debug('Instance Curr Location type: '||l_inst_loc_type);
          debug('Instance Curr Location ID  : '||l_inst_loc_id);
          debug('Instance Vldn Organization : '||l_instance_rec.vld_organization_id);
          debug('OM Vldn Organization       : '||l_line_dtl_tbl(1).inv_organization_id);

          -- Validations:
            -- Current Location has to be  External
            -- Conversion/Ownership Qty has to be EQ / LT the orig shipped qty
            -- If Party doesn't match orig party then install param authorization requd
          IF l_inst_owner_id = l_internal_party_id
            AND l_inst_owner_type = 'HZ_PARTIES' THEN
            -- check if TLD says expire? If yes, Invalid
           IF nvl(l_line_dtl_tbl(1).active_end_date, fnd_api.g_miss_date)
              <> fnd_api.g_miss_date THEN
              debug('Active End date :'||l_line_dtl_tbl(1).active_end_date
                    || 'provided on transaction line detail: '
                    || l_line_dtl_tbl(1).txn_line_detail_id);
              fnd_message.set_name('CSI','CSI_TXN_INVALID_INST_REF');
              fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           ELSIF l_inst_loc_type
             NOT IN ( 'INVENTORY','HZ_PARTY_SITES', 'HZ_LOCATIONS', 'VENDOR_SITE', 'INTERNAL_SITE')
           THEN
              debug('Location type code is :'||l_inst_loc_type);
              fnd_message.set_name('CSI', 'CSI_TXN_SRC_LOC_INVALID');
              fnd_message.set_token('LOC_CODE', l_inst_loc_type);
              fnd_message.set_token('SRC_NAME', 'Conversion to a Customer Ownership ');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
              -- allow only externally located
           END IF;
          END IF;

          IF l_td_owner_type is not null THEN
           IF l_inst_owner_type <> l_td_owner_type THEN
              -- let's trap as an error currently so that it prevents
              -- ownership changes from HZ_PARTY TO PO_VENDOR or etc etc
              debug('Owner Change.');
              fnd_message.set_name('CSI', 'CSI_API_INVALID_PARTY_SOURCE');
              fnd_message.set_token('PARTY_SOURCE_TABLE', l_td_owner_type);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           ELSIF l_td_owner_id <> l_inst_owner_id THEN
             IF l_ownership_override = 'Y' THEN
                debug('Ownership Change and is allowed.');
             ELSE
                debug('Ownership Change but is not setup:'||l_ownership_override);
                fnd_message.set_name('CSI', 'CSI_SHIP_OWNER_MISMATCH');
                fnd_message.set_token('OLD_PARTY_ID',l_inst_owner_id);
                fnd_message.set_token('NEW_PARTY_ID',l_td_owner_id);
                fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error;
             END IF;
           END IF;
          ELSE -- no owner entered in TD
           IF ((l_inst_owner_type = 'HZ_PARTIES' )
               AND (l_inst_owner_id <> l_internal_party_id))
           THEN
             IF l_ownership_override = 'Y' THEN
                debug('Ownership Change and is allowed.');
             ELSE
              IF nvl(p_order_line_rec.end_customer_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                 AND l_inst_owner_id <> p_order_line_rec.end_customer_id
              THEN -- end customer exists
                 -- for normal NON-partner order, checks for ownership override will be
                 -- done anyway later in update_install_base since we do not have party_id here
                 debug('Ownership Change but is not setup:'||l_ownership_override);
                 fnd_message.set_name('CSI', 'CSI_SHIP_OWNER_MISMATCH');
                 fnd_message.set_token('OLD_PARTY_ID',l_inst_owner_id);
                 fnd_message.set_token('NEW_PARTY_ID',l_td_owner_id);
                 fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
              END IF;
             END IF;
           END IF;
          END IF;

          IF l_line_dtl_tbl(1).quantity <> l_instance_rec.quantity THEN
             debug('Original Instance Qty  : '||l_instance_rec.quantity);
             debug('Qty being processed    : '||l_line_dtl_tbl(1).quantity);
            -- check if the quantity is greater than the instance quantity
            IF p_line_dtl_tbl(l_td_ind).quantity > l_instance_rec.quantity THEN
               fnd_message.set_name('CSI','CSI_INT_QTY_CHK_FAILED');
               fnd_message.set_token('INSTANCE_ID',l_instance_rec.instance_id);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
            ELSIF l_line_dtl_tbl(1).quantity < l_instance_rec.quantity THEN
               -- split the instance and process....
               l_quantity1 := l_instance_rec.quantity - l_line_dtl_tbl(1).quantity ;
               l_split_src_inst_rec.instance_id := l_instance_rec.instance_id;
               --  l_csi_trxn_rec.split_reason_code := 'PARTIAL_RETURN';

               csi_t_gen_utility_pvt.dump_api_info(
                   p_pkg_name => 'csi_item_instance_pvt',
                   p_api_name => 'split_item_instance');

               csi_item_instance_pvt.split_item_instance (
                   p_api_version            => 1.0,
                   p_commit                 => fnd_api.g_false,
                   p_init_msg_list          => fnd_api.g_true,
                   p_validation_level       => fnd_api.g_valid_level_full,
                   p_source_instance_rec    => l_split_src_inst_rec,
                   p_quantity1              => l_quantity1,
                   p_quantity2              => l_line_dtl_tbl(1).quantity,
                   p_copy_ext_attribs       => fnd_api.g_true,
                   p_copy_org_assignments   => fnd_api.g_true,
                   p_copy_parties           => fnd_api.g_true,
                   p_copy_accounts          => fnd_api.g_true,
                   p_copy_asset_assignments => fnd_api.g_true,
                   p_copy_pricing_attribs   => fnd_api.g_true,
                   p_txn_rec                => px_csi_txn_rec,
                   x_new_instance_rec       => l_split_new_inst_rec,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data);

                IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
                   debug('csi_item_instance_pvt.split_item_instance raised errors');
                   raise fnd_api.g_exc_error;
                END IF;
                l_u_line_dtl_tbl(1).instance_id  := l_split_new_inst_rec.instance_id;
                l_u_line_dtl_tbl(1).preserve_detail_flag  := 'Y';
                debug('Newly split Instance ID  : '||l_split_new_inst_rec.instance_id);
            END IF;
          END IF;

          -- update the transaction line detail table with the inprocess status
          l_u_txn_line_rec.transaction_line_id := p_line_dtl_tbl(l_td_ind).transaction_line_id;

          l_u_line_dtl_tbl(1).txn_line_detail_id  := p_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          IF nvl(l_vld_orgn_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
             l_u_line_dtl_tbl(1).inv_organization_id := l_vld_orgn_id; -- FP fix for bug 5072107
          END IF;

          l_u_line_dtl_tbl(1).transaction_line_id := p_line_dtl_tbl(l_td_ind).transaction_line_id;
          l_u_line_dtl_tbl(1).processing_status   := 'IN_PROCESS';

          csi_t_txn_details_grp.update_txn_line_dtls(
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            p_txn_line_rec             => l_u_txn_line_rec,
            p_txn_line_detail_tbl      => l_u_line_dtl_tbl,
            px_txn_ii_rltns_tbl        => l_u_ii_rltns_tbl,
            px_txn_party_detail_tbl    => l_u_pty_dtl_tbl,
            px_txn_pty_acct_detail_tbl => l_u_pty_acct_tbl,
            px_txn_org_assgn_tbl       => l_u_org_assgn_tbl,
            px_txn_ext_attrib_vals_tbl => l_u_eav_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Update txn line dtls failed for RMA Fulfillment.');
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END demo_fulfillment;

  -- configurator fulfillment

  PROCEDURE cz_fulfillment(
    p_order_line_id    IN number,
    x_return_status    OUT NOCOPY varchar2,
    x_return_message   OUT NOCOPY varchar2)
  IS

    l_txn_line_rec          csi_t_datastructures_grp.txn_line_rec;
    l_td_found              boolean := FALSE;

    l_source_header_rec     csi_interface_pkg.source_header_rec;
    l_source_line_rec       csi_interface_pkg.source_line_rec;

    l_csi_txn_rec           csi_datastructures_pub.transaction_rec;

    l_txn_line_query_rec         csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_g_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_g_pty_dtl_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_g_pty_acct_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_g_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_g_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_g_ext_attrib_tbl      csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_g_csi_ea_tbl          csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_g_csi_eav_tbl         csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_g_txn_systems_tbl     csi_t_datastructures_grp.txn_systems_tbl;

    l_txn_line_detail_tbl   csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_party_acct_tbl    csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_eav_tbl           csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl       csi_t_datastructures_grp.txn_systems_tbl;

    l_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;

    -- Added this for unlock_item_instances
    l_config_tbl            csi_cz_int.config_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_return_message        varchar2(2000);
    l_msg_count             number;
    l_msg_data              varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('Configurator fulfillment for order line id :'||p_order_line_id);

    api_log('cz_fulfillment');

    savepoint cz_fulfillment;

    csi_interface_pkg.get_source_info(
      p_source_table         => csi_interface_pkg.g_om_source_table,
      p_source_id            => p_order_line_id,
      x_source_header_rec    => l_source_header_rec,
      x_source_line_rec      => l_source_line_rec,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- check for user entered transaction details
    l_txn_line_rec.source_transaction_table := csi_interface_pkg.g_om_source_table;
    l_txn_line_rec.source_transaction_id    := l_source_line_rec.source_line_id;

    l_td_found := csi_t_txn_details_pvt.check_txn_details_exist(
                    p_txn_line_rec => l_txn_line_rec);

    -- if entered then re build using the transaction details using the source info
    IF l_td_found THEN

      l_txn_line_query_rec.source_transaction_table := csi_interface_pkg.g_om_source_table;
      l_txn_line_query_rec.source_transaction_id    := l_source_line_rec.source_line_id;

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

--      l_txn_line_rec.source_transaction_type_id := csi_interface_pkg.g_om_txn_type_id;
      l_txn_line_rec.source_transaction_type_id := csi_interface_pkg.g_macd_txn_type_id; --bug 5194812

      l_txn_line_rec.processing_status          := 'SUBMIT';

      l_txn_line_detail_tbl := l_g_line_dtl_tbl;
      l_txn_party_tbl       := l_g_pty_dtl_tbl;
      l_txn_party_acct_tbl  := l_g_pty_acct_tbl;
      l_txn_org_assgn_tbl   := l_g_org_assgn_tbl;

      csi_interface_pkg.rebuild_txn_detail(
        p_source_table         => csi_interface_pkg.g_om_source_table,
        p_source_id            => p_order_line_id,
        p_source_header_rec    => l_source_header_rec,
        p_source_line_rec      => l_source_line_rec,
        p_csi_txn_rec          => l_csi_txn_rec,
        px_txn_line_rec        => l_txn_line_rec,
        px_txn_line_detail_tbl => l_txn_line_detail_tbl,
        px_txn_party_tbl       => l_txn_party_tbl,
        px_txn_party_acct_tbl  => l_txn_party_acct_tbl,
        px_txn_org_assgn_tbl   => l_txn_org_assgn_tbl,
        x_pricing_attribs_tbl  => l_pricing_attribs_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE -- if not entered then build a brand new one using the source info

      --code for bug 5194812--
      l_txn_line_rec.source_transaction_type_id := csi_interface_pkg.g_macd_txn_type_id;

      csi_interface_pkg.build_default_txn_detail(
        p_source_table         => csi_interface_pkg.g_om_source_table,
        p_source_id            => p_order_line_id,
        p_source_header_rec    => l_source_header_rec,
        p_source_line_rec      => l_source_line_rec,
        p_csi_txn_rec          => l_csi_txn_rec,
        px_txn_line_rec        => l_txn_line_rec, --bug 5194812, changed this param to IN OUT
        x_txn_line_detail_tbl  => l_txn_line_detail_tbl,
        x_txn_party_tbl        => l_txn_party_tbl,
        x_txn_party_acct_tbl   => l_txn_party_acct_tbl,
        x_txn_org_assgn_tbl    => l_txn_org_assgn_tbl,
        x_pricing_attribs_tbl  => l_pricing_attribs_tbl,
        x_return_status        => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    --get the relations from om/config transaction details

    csi_interface_pkg.get_relations(
      p_source_id               => p_order_line_id,
      p_source_table            => csi_interface_pkg.g_om_source_table,
      p_source_header_rec       => l_source_header_rec,
      p_source_line_rec         => l_source_line_rec,
      px_txn_line_rec           => l_txn_line_rec,
      px_txn_line_dtl_tbl       => l_txn_line_detail_tbl,
      x_txn_ii_rltns_tbl        => l_txn_ii_rltns_tbl,
      x_txn_eav_tbl             => l_txn_eav_tbl,
      x_return_status           => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

   -- Added the following call for unlockinig the config keys to be fulfilled
   IF l_txn_line_detail_tbl.count > 0
   THEN
     FOR inst in l_txn_line_detail_tbl.FIRST .. l_txn_line_detail_tbl.LAST
     Loop
       -- Unlock Routine
       l_config_tbl(1).source_application_id := 542;
       l_config_tbl(1).config_inst_hdr_id    := l_txn_line_detail_tbl(inst).config_inst_hdr_id;
       l_config_tbl(1).config_inst_item_id   := l_txn_line_detail_tbl(inst).config_inst_item_id;
       l_config_tbl(1).config_inst_rev_num   := l_txn_line_detail_tbl(inst).config_inst_rev_num;
       l_config_tbl(1).instance_id           := l_txn_line_detail_tbl(inst).instance_id;
       l_config_tbl(1).source_txn_header_ref := l_source_header_rec.source_header_id;
       l_config_tbl(1).source_txn_line_ref1 := l_source_line_rec.source_line_id;

       csi_cz_int.unlock_item_instances(
                p_api_version               => 1.0,
                p_init_msg_list             => fnd_api.g_true,
                p_commit                    => fnd_api.g_false,
                p_validation_level          => fnd_api.g_valid_level_full,
                p_config_tbl                => l_config_tbl,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data);

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
       END IF;
     END LOOP;
   END IF;


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

    debug('Configurator fulfillment successful for order line id :'||p_order_line_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      rollback to cz_fulfillment;
      debug(x_return_message);
    WHEN others THEN
      fnd_message.set_name ('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', 'OTHERS Error :'||substr(sqlerrm, 1, 300));
      fnd_msg_pub.add;
      x_return_status  := fnd_api.g_ret_sts_error;
      x_return_message := csi_t_gen_utility_pvt.dump_error_stack;
      rollback to cz_fulfillment;
      debug(x_return_message);
  END cz_fulfillment;

  PROCEDURE query_tld_and_update_ib(
    p_order_header_rec     IN oe_order_headers_all%rowtype,
    p_order_line_rec       IN csi_order_ship_pub.order_line_rec, --fix for bug5589710
    px_default_info_rec    IN OUT NOCOPY default_info_rec,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_error_rec           IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_tl_query_rec         csi_t_datastructures_grp.txn_line_query_rec;
    l_tld_query_rec        csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_p_order_line_rec     csi_order_ship_pub.order_line_rec;

    l_p_tl_rec             csi_t_datastructures_grp.txn_line_rec;

    l_p_tld_tbl            csi_t_datastructures_grp.txn_line_detail_tbl;
    l_p_tpd_tbl            csi_t_datastructures_grp.txn_party_detail_tbl;
    l_p_tpa_tbl            csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_p_tiir_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_p_toa_tbl            csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_p_teav_tbl           csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_p_tsys_tbl           csi_t_datastructures_grp.txn_systems_tbl;
    l_p_pa_tbl             csi_datastructures_pub.pricing_attribs_tbl;
    l_p_ea_tbl             csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_p_eav_tbl            csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;

    l_src_tld_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_src_tld_total_qty    number := 0;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

    l_cur_party_site_id	   number; --For bug 8816038
    l_inst_party_site_id   number; --For bug 8816038

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('query_tld_and_update_ib');

    l_p_tl_rec.transaction_line_id          := px_default_info_rec.transaction_line_id;
    l_p_tl_rec.source_transaction_table     := 'OE_ORDER_LINES_ALL';
    l_p_tl_rec.source_transaction_id        := p_order_line_rec.order_line_id;
    l_p_tl_rec.source_transaction_type_id   := 51;

    debug('get transaction details for the final process. IN_PROCESS Details');

    l_tl_query_rec.transaction_line_id      := px_default_info_rec.transaction_line_id;
    l_tl_query_rec.source_transaction_table := 'OE_ORDER_LINES_ALL';
    l_tl_query_rec.source_transaction_id    := p_order_line_rec.order_line_id;

    l_tld_query_rec.processing_status       := 'IN_PROCESS';
    l_tld_query_rec.source_transaction_flag := fnd_api.g_miss_char;

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version               => 1,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_txn_line_query_rec        => l_tl_query_rec,
      p_txn_line_detail_query_rec => l_tld_query_rec,
      x_txn_line_detail_tbl       => l_p_tld_tbl,
      p_get_parties_flag          => fnd_api.g_true,
      x_txn_party_detail_tbl      => l_p_tpd_tbl,
      p_get_pty_accts_flag        => fnd_api.g_true,
      x_txn_pty_acct_detail_tbl   => l_p_tpa_tbl,
      p_get_ii_rltns_flag         => fnd_api.g_true,
      x_txn_ii_rltns_tbl          => l_p_tiir_tbl,
      p_get_org_assgns_flag       => fnd_api.g_true,
      x_txn_org_assgn_tbl         => l_p_toa_tbl,
      p_get_ext_attrib_vals_flag  => fnd_api.g_true,
      x_txn_ext_attrib_vals_tbl   => l_p_teav_tbl,
      p_get_csi_attribs_flag      => fnd_api.g_false,
      x_csi_ext_attribs_tbl       => l_p_ea_tbl,
      p_get_csi_iea_values_flag   => fnd_api.g_false,
      x_csi_iea_values_tbl        => l_p_eav_tbl,
      p_get_txn_systems_flag      => fnd_api.g_true,
      x_txn_systems_tbl           => l_p_tsys_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_p_tld_tbl.COUNT > 0 THEN

      get_source_tlds(
        p_tld_tbl           => l_p_tld_tbl,
        x_src_tld_tbl       => l_src_tld_tbl,
        x_src_tld_total_qty => l_src_tld_total_qty);

      IF l_src_tld_tbl.COUNT = 1 THEN
        IF (p_order_line_rec.fulfilled_quantity <> p_order_line_rec.ordered_quantity)
            OR
           (p_order_line_rec.fulfilled_quantity <> l_src_tld_total_qty)
        THEN
          l_p_tld_tbl(1).quantity := p_order_line_rec.fulfilled_quantity;
        END IF;
      ELSE
        IF p_order_line_rec.fulfilled_quantity <> l_src_tld_total_qty THEN
          fnd_message.set_name ('CSI', 'CSI_FULFILL_TLD_QTY_MISMATCH');
          fnd_message.set_token('FULFILLED_QTY', p_order_line_rec.fulfilled_quantity);
          fnd_message.set_token('TOT_TLD_QTY', l_src_tld_total_qty);
          fnd_msg_pub.add;
        END IF;
      END IF;

      -- assign default current and default install location
      FOR l_ind IN l_p_tld_tbl.FIRST .. l_p_tld_tbl.LAST
      LOOP
        IF l_p_tld_tbl(l_ind).source_transaction_flag = 'Y' THEN
          IF nvl(l_p_tld_tbl(l_ind).location_type_code,fnd_api.g_miss_char) =
             fnd_api.g_miss_char
             OR
             nvl(l_p_tld_tbl(l_ind).location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
          --Below Begin to End added for bug 8816038 --
		    BEGIN

		      l_cur_party_site_id := null;

		      SELECT party_site_id
		      INTO   l_cur_party_site_id
		      FROM   hz_cust_acct_sites_all c,
			     hz_cust_site_uses_all u
		      WHERE  c.cust_acct_site_id = u.cust_acct_site_id
		      AND    u.site_use_id =  px_default_info_rec.current_party_site_id;

		     l_p_tld_tbl(l_ind).location_type_code := 'HZ_PARTY_SITES';
		     l_p_tld_tbl(l_ind).location_id        := l_cur_party_site_id;


		    EXCEPTION
		      WHEN no_data_found then
			fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
			fnd_message.set_token('LOCATION_ID', px_default_info_rec.current_party_site_id);
			fnd_msg_pub.add;
			raise fnd_api.g_exc_error;
		      WHEN too_many_rows then
			debug('Many Party sites found');
			raise fnd_api.g_exc_error;
		    END;
	  END IF;

          IF nvl(l_p_tld_tbl(l_ind).install_location_type_code,fnd_api.g_miss_char) =
             fnd_api.g_miss_char
             OR
             nvl(l_p_tld_tbl(l_ind).install_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
         --Below Begin to End added for bug 8816038 --

		  BEGIN

		      l_inst_party_site_id := null;

		      SELECT party_site_id
		      INTO   l_inst_party_site_id
		      FROM   hz_cust_acct_sites_all c,
			     hz_cust_site_uses_all u
		      WHERE  c.cust_acct_site_id = u.cust_acct_site_id
		      AND    u.site_use_id = px_default_info_rec.install_party_site_id;

		     l_p_tld_tbl(l_ind).install_location_type_code := 'HZ_PARTY_SITES';
		     l_p_tld_tbl(l_ind).install_location_id        := l_inst_party_site_id;


		    EXCEPTION
		      WHEN no_data_found then
			fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
			fnd_message.set_token('LOCATION_ID', px_default_info_rec.install_party_site_id);
			fnd_msg_pub.add;
			raise fnd_api.g_exc_error;
		      WHEN too_many_rows then
			debug('Many Party sites found');
			raise fnd_api.g_exc_error;
		    END;

	  END IF;
        END IF;
      END LOOP;
    END IF;

    csi_utl_pkg.get_pricing_attribs(
      p_line_id           => p_order_line_rec.order_line_id,
      x_pricing_attb_tbl  => l_p_pa_tbl,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF csi_t_gen_utility_pvt.g_debug_level >= 25 THEN
      csi_t_gen_utility_pvt.dump_txn_tables(
        p_ids_or_index_based => 'I',
        p_line_detail_tbl    => l_p_tld_tbl,
        p_party_detail_tbl   => l_p_tpd_tbl,
        p_pty_acct_tbl       => l_p_tpa_tbl,
        p_ii_rltns_tbl       => l_p_tiir_tbl,
        p_org_assgn_tbl      => l_p_toa_tbl,
        p_ea_vals_tbl        => l_p_teav_tbl);
    END IF;

    -- defaults directly from OM
    l_p_order_line_rec.header_id             := p_order_line_rec.header_id;
    l_p_order_line_rec.order_line_id         := p_order_line_rec.order_line_id;
    l_p_order_line_rec.inv_item_id           := p_order_line_rec.inv_item_id;
    l_p_order_line_rec.inv_org_id            := p_order_line_rec.inv_org_id;
    l_p_order_line_rec.ordered_quantity      := p_order_line_rec.ordered_quantity;
    l_p_order_line_rec.shipped_quantity      := p_order_line_rec.shipped_quantity;
    l_p_order_line_rec.fulfilled_quantity    := p_order_line_rec.fulfilled_quantity;
    l_p_order_line_rec.fulfillment_date      := p_order_line_rec.fulfillment_date;
    l_p_order_line_rec.top_model_line_id     := p_order_line_rec.top_model_line_id;
    l_p_order_line_rec.ato_line_id           := p_order_line_rec.ato_line_id;
    l_p_order_line_rec.link_to_line_id       := p_order_line_rec.link_to_line_id;
    l_p_order_line_rec.invoice_to_org_id     := p_order_line_rec.invoice_to_org_id;
    l_p_order_line_rec.ship_to_org_id        := p_order_line_rec.ship_to_org_id;
    l_p_order_line_rec.item_type_code        := p_order_line_rec.item_type_code;
    l_p_order_line_rec.ordered_item          := p_order_line_rec.ordered_item;
    l_p_order_line_rec.org_id                := p_order_line_rec.org_id;
    l_p_order_line_rec.deliver_to_org_id     := p_order_line_rec.deliver_to_org_id;
    l_p_order_line_rec.sold_from_org_id      := p_order_line_rec.sold_from_org_id;
    l_p_order_line_rec.sold_to_org_id        := p_order_line_rec.sold_to_org_id;
    l_p_order_line_rec.agreement_id          := p_order_line_rec.agreement_id;
    l_p_order_line_rec.ship_to_contact_id    := p_order_line_rec.ship_to_contact_id;
    l_p_order_line_rec.invoice_to_contact_id := p_order_line_rec.invoice_to_contact_id;
    l_p_order_line_rec.currency_code         := p_order_header_rec.transactional_curr_code;
    l_p_order_line_rec.unit_price            := p_order_line_rec.unit_price;
    l_p_order_line_rec.order_quantity_uom    := p_order_line_rec.order_quantity_uom;
    l_p_order_line_rec.bom_item_type         := p_order_line_rec.bom_item_type; --fix for bug5589710


    -- defaults derived from partner ordering/tca etc
    l_p_order_line_rec.om_vld_org_id         := px_default_info_rec.om_vld_org_id;
    l_p_order_line_rec.primary_uom           := px_default_info_rec.primary_uom_code;
    l_p_order_line_rec.ib_current_loc_id     := px_default_info_rec.current_party_site_id;
    l_p_order_line_rec.ib_install_loc_id     := px_default_info_rec.install_party_site_id;
    l_p_order_line_rec.customer_id           := px_default_info_rec.owner_party_acct_id;
    l_p_order_line_rec.end_customer_id       := px_default_info_rec.owner_party_acct_id;
    l_p_order_line_rec.trx_line_id           := px_default_info_rec.transaction_line_id;

    csi_order_ship_pub.update_install_base(
      p_api_version             => 1.0,
      p_commit                  => fnd_api.g_false,
      p_init_msg_list           => fnd_api.g_true,
      p_validation_level        => fnd_api.g_valid_level_full,
      p_txn_line_rec            => l_p_tl_rec,
      p_txn_line_detail_tbl     => l_p_tld_tbl,
      p_txn_party_detail_tbl    => l_p_tpd_tbl,
      p_txn_pty_acct_dtl_tbl    => l_p_tpa_tbl,
      p_txn_org_assgn_tbl       => l_p_toa_tbl,
      p_txn_ii_rltns_tbl        => l_p_tiir_tbl,
      p_txn_ext_attrib_vals_tbl => l_p_teav_tbl,
      p_txn_systems_tbl         => l_p_tsys_tbl,
      p_pricing_attribs_tbl     => l_p_pa_tbl,
      p_order_line_rec          => l_p_order_line_rec,
      p_trx_rec                 => px_csi_txn_rec,
      p_source                  => 'FULFILLMENT',
      p_validate_only           => 'N',
      px_error_rec              => px_error_rec,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    UPDATE csi_t_transaction_lines
    SET    processing_status    = 'PROCESSED'
    WHERE  transaction_line_id  = l_p_tl_rec.transaction_line_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END query_tld_and_update_ib;

  /* Main interface program for Order Fulfillment */
  PROCEDURE order_fulfillment(
    p_order_line_id  IN  number,
    p_message_id     IN  number,
    x_return_status  OUT NOCOPY varchar2,
    px_trx_error_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec)
  IS

    l_api_name             varchar2(30) := 'order_fulfillment';

    l_default_info_rec     default_info_rec;
    l_txn_line_id          number;
    l_txn_type_id          number := 51;
    l_txn_sub_type_id      number ;
    l_sub_type_rec         sub_type_rec;
    l_src_txn_table        varchar2(30) := 'OE_ORDER_LINES_ALL';
    l_transaction_line_id  number;

    l_cascade_eligible     varchar2(1) := 'N';
    l_model_hierarchy      varchar2(300);
    l_mdl_ordered_qty      number;

    l_config_instances     config_serial_inst_tbl;
    l_config_reship_found  boolean      := FALSE;
    l_config_reship_count  number       := 0;

    l_option_instances     csi_datastructures_pub.instance_tbl;

    l_trk_child_tbl        oe_order_pub.line_tbl_type;
    l_trk_parent_rec       oe_order_pub.line_rec_type;

    l_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_query_rec   csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec;
    l_txn_source_rec       csi_t_ui_pvt.txn_source_rec;

    l_g_line_dtl_tbl       csi_t_datastructures_grp.txn_line_detail_tbl;
    l_g_pty_dtl_tbl        csi_t_datastructures_grp.txn_party_detail_tbl;
    l_g_pty_acct_tbl       csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_g_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_g_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_g_ext_attrib_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_g_csi_ea_tbl         csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_g_csi_eav_tbl        csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_g_txn_systems_tbl    csi_t_datastructures_grp.txn_systems_tbl;

    l_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl          csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl;

    l_p_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_p_pty_dtl_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_p_pty_acct_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_p_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_p_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_p_ext_attrib_tbl      csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_p_txn_systems_tbl     csi_t_datastructures_grp.txn_systems_tbl;
    l_p_pricing_attribs_tbl csi_datastructures_pub.pricing_attribs_tbl;
    l_p_csi_ea_tbl          csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_p_csi_eav_tbl         csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;

    l_tmp_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    l_party_site_id         number;
    l_owner_party_id        number;
    l_owner_account_id      number;

    l_om_session_key        csi_utility_grp.config_session_key;
    l_macd_processing       boolean     := FALSE;

    l_inv_transactable_flag varchar2(1);
    l_serial_code           number;
    l_lot_code              number;
    l_revision_control_code number;
    l_locator_control_code  number;
    l_ib_trackable_flag     varchar2(1);
    l_bom_item_type         number;
    l_reservable_type       number;
    l_pick_components_flag  varchar2(1);
    l_primary_uom_code      varchar2(30);
    l_ato_line_id          number;
    l_order_line_qty       NUMBER; --added for bug5096435
    l_qty_ratio		   NUMBER;

    l_cascaded_flag        varchar2(1)  := 'N';
    l_shippable_item_flag  varchar2(1) := 'N';

    l_order_line_rec       oe_order_lines_all%rowtype;
    l_order_header_rec     oe_order_headers_all%rowtype;

    l_p_order_line_rec     csi_order_ship_pub.order_line_rec;
    l_csi_txn_rec          csi_datastructures_pub.transaction_rec;

    l_identified_item_type varchar2(30);
    l_processing_status    varchar2(30);

    l_ato_rebuild_flag     varchar2(1) := 'N';

    l_config_rec           config_rec;
    l_config_ratio         number;

    l_wip_processing       boolean := FALSE;
    l_found                boolean := FALSE;
    l_partial              boolean := FALSE;
    l_inst_ref_found       boolean := FALSE;

    l_split_flag           varchar2(30) := 'N';
    l_ratio_split_flag     varchar2(1) := 'N';
    l_ratio_split_qty      number := 0;

    l_debug_level          number;
    l_error_message        varchar2(2000);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(2000);
    l_msg_count            number;

    ---Added (Start) for m-to-m enhancements
    l_temp_txn_ii_rltns_tbl  csi_t_datastructures_grp.txn_ii_rltns_tbl;
    ---Added (End) for m-to-m enhancements

    skip_regular_process   exception;
    l_error_rec            csi_datastructures_pub.transaction_error_rec;

    -- For partner prdering
    l_end_customer_id      number;
    l_current_site_use_id  number;
    l_install_site_use_id  number;

    l_osp_vld_org_id       number;
    l_src_tld_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_src_tld_total_qty    number := 0;
    --
    l_ul_txn_line_id       NUMBER;
    l_ul_instance_rec      csi_datastructures_pub.instance_rec;
    l_u_parties_tbl        csi_datastructures_pub.party_tbl;
    l_u_pty_accts_tbl      csi_datastructures_pub.party_account_tbl;
    l_u_org_units_tbl      csi_datastructures_pub.organization_units_tbl;
    l_u_ea_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_pricing_tbl        csi_datastructures_pub.pricing_attribs_tbl;
    l_u_assets_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_u_instance_ids_list  csi_datastructures_pub.id_tbl;

  BEGIN

    savepoint order_fulfillment;

    x_return_status := fnd_api.g_ret_sts_success;
    l_error_rec     := px_trx_error_rec;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csisoful',
      p_file_segment2 => p_order_line_id);

    api_log(l_api_name);

    debug('  Transaction Time   : '||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type   : Sales Order Fulfillment');
    debug('  Order Line ID      : '||p_order_line_id);

    l_error_rec.source_id       := p_order_line_id;

    fnd_msg_pub.initialize;

    /* this routine checks if ib is active */
    csi_utility_grp.check_ib_active;

    l_default_info_rec.internal_party_id        :=
                       csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_default_info_rec.freeze_date              :=
                       csi_datastructures_pub.g_install_param_rec.freeze_date;
    l_default_info_rec.ownership_cascade_at_txn :=
                       csi_datastructures_pub.g_install_param_rec.ownership_cascade_at_txn;

    /* get the default sub type id */
    csi_utl_pkg.get_dflt_sub_type_id(
      p_transaction_type_id => l_txn_type_id,
      x_sub_type_id         => l_txn_sub_type_id,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    l_default_info_rec.sub_type_id := l_txn_sub_type_id;

    get_sub_type_rec(
      p_transaction_type_id => l_txn_type_id,
      p_sub_type_id         => l_txn_sub_type_id,
      x_sub_type_rec        => l_sub_type_rec,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_default_info_rec.src_change_owner      := l_sub_type_rec.src_change_owner;
    l_default_info_rec.src_change_owner_code := l_sub_type_rec.src_change_owner_code;
    l_default_info_rec.src_status_id         := l_sub_type_rec.src_status_id;


    BEGIN

      SELECT *
      INTO   l_order_line_rec
      FROM   oe_order_lines_all
      WHERE  line_id = p_order_line_id;

      SELECT *
      INTO   l_order_header_rec
      FROM   oe_order_headers_all
      WHERE  header_id = l_order_line_rec.header_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_OE_LINE_ID_INVALID');
        fnd_message.set_token('OE_LINE_ID', p_order_line_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_order_line_rec.org_id is null THEN
      l_order_line_rec.org_id := l_order_header_rec.org_id;
    END IF;

    IF l_order_line_rec.org_id is not null THEN
      l_default_info_rec.om_vld_org_id := oe_sys_parameters.value(
                                            param_name => 'MASTER_ORGANIZATION_ID',
                                            p_org_id   => l_order_line_rec.org_id);
    END IF;

    IF l_order_line_rec.ship_from_org_id is null THEN
      l_order_line_rec.ship_from_org_id := l_order_header_rec.ship_from_org_id;
      IF l_order_line_rec.ship_from_org_id is null THEN
        l_order_line_rec.ship_from_org_id := l_default_info_rec.om_vld_org_id;
      END IF;
    END IF;

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

    IF l_order_line_rec.ship_to_contact_id is null THEN
      l_order_line_rec.ship_to_contact_id := l_order_header_rec.ship_to_contact_id;
    END IF;

    IF l_order_line_rec.invoice_to_contact_id is null THEN
      l_order_line_rec.invoice_to_contact_id := l_order_header_rec.invoice_to_contact_id;
    END IF;

    -- for partner ordering

    IF l_order_line_rec.invoice_to_org_id is null THEN
      l_order_line_rec.invoice_to_org_id := l_order_header_rec.invoice_to_org_id;
    END IF;

    IF l_order_line_rec.deliver_to_org_id is null THEN
      l_order_line_rec.deliver_to_org_id := l_order_header_rec.deliver_to_org_id;
    END IF;

    IF l_order_line_rec.fulfilled_quantity is null THEN
      l_order_line_rec.fulfilled_quantity := 0;
    END IF;

    -- I have to do this because i spawn ib fulfillments for shippable ato opions
    -- right after the config shipments where the options may not have the fulfilled quantity
    -- Included the OR condition for handling Drop Shipment case where there might be any fulfilled qty.
    IF  (l_order_line_rec.item_type_code = 'OPTION' AND l_order_line_rec.ato_line_id is not null)
       OR
        (l_order_line_rec.source_type_code = 'EXTERNAL') -- Bug 4168922
    THEN
      l_order_line_rec.fulfilled_quantity := l_order_line_rec.shipped_quantity;
    ELSE
      IF l_order_line_rec.fulfilled_quantity <= 0 THEN
        fnd_message.set_name('CSI', 'CSI_ORDER_LINE_NOT_FULFILLED');
        fnd_message.set_token('FULFILLED_QUANTITY', l_order_line_rec.fulfilled_quantity);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    get_partner_order_info(
      p_order_line_rec        => l_order_line_rec,
      x_end_customer_id       => l_end_customer_id,
      x_current_site_use_id   => l_current_site_use_id,
      x_install_site_use_id   => l_install_site_use_id,
      x_return_status         => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;


   IF nvl(l_current_site_use_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      BEGIN
        SELECT HCAS.party_site_id
        INTO   l_party_site_id
        FROM   hz_cust_site_uses_all  HCSU,
               hz_cust_acct_sites_all HCAS
        WHERE  HCSU.site_use_id       = l_current_site_use_id
        AND    HCAS.cust_acct_site_id = HCSU.cust_acct_site_id;
        l_default_info_rec.current_party_site_id := l_party_site_id;
      EXCEPTION
        WHEN no_data_found THEN
          fnd_message.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
          fnd_message.set_token('SITE_USE_ID',l_current_site_use_id);
          fnd_message.set_token('SITE_USE_CODE','SITE_USE_ID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    IF nvl(l_install_site_use_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      BEGIN
        SELECT HCAS.party_site_id
        INTO   l_party_site_id
        FROM   hz_cust_site_uses_all  HCSU,
               hz_cust_acct_sites_all HCAS
        WHERE  HCSU.site_use_id       = l_install_site_use_id
        AND    HCAS.cust_acct_site_id = HCSU.cust_acct_site_id;
        l_default_info_rec.install_party_site_id := l_party_site_id;
      EXCEPTION
        WHEN no_data_found THEN
          fnd_message.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
          fnd_message.set_token('SITE_USE_ID',l_install_site_use_id);
          fnd_message.set_token('SITE_USE_CODE','SITE_USE_ID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    -- IF l_order_line_rec.sold_to_org_id is not null THEN
    IF nvl(l_end_customer_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      SELECT party_id
      INTO   l_owner_party_id
      FROM   hz_cust_accounts
      WHERE  cust_account_id = l_end_customer_id;
      l_default_info_rec.owner_party_acct_id := l_end_customer_id;
      l_default_info_rec.owner_party_id      := l_owner_party_id;
    END IF;

    -- building order line rec to pass it to Update Install Base Procedure
    l_p_order_line_rec.header_id         := l_order_line_rec.header_id;
    l_p_order_line_rec.order_line_id     := l_order_line_rec.line_id;
    l_p_order_line_rec.inv_item_id       := l_order_line_rec.inventory_item_id;
    l_p_order_line_rec.inv_org_id        := l_order_line_rec.ship_from_org_id;
    l_p_order_line_rec.ordered_quantity  := l_order_line_rec.ordered_quantity;
    l_p_order_line_rec.shipped_quantity  := l_order_line_rec.shipped_quantity;
    l_p_order_line_rec.fulfilled_quantity:= l_order_line_rec.fulfilled_quantity;
    l_p_order_line_rec.fulfillment_date  := l_order_line_rec.fulfillment_date;
    l_p_order_line_rec.top_model_line_id := l_order_line_rec.top_model_line_id;
    l_p_order_line_rec.ato_line_id       := l_order_line_rec.ato_line_id;
    l_p_order_line_rec.link_to_line_id   := l_order_line_rec.link_to_line_id;
    l_p_order_line_rec.invoice_to_org_id := l_order_line_rec.invoice_to_org_id;
    l_p_order_line_rec.ship_to_org_id    := l_order_line_rec.ship_to_org_id;
    l_p_order_line_rec.item_type_code    := l_order_line_rec.item_type_code;
    l_p_order_line_rec.ordered_item      := l_order_line_rec.ordered_item;
    l_p_order_line_rec.org_id            := l_order_line_rec.org_id;

    -- For partner ordering.
    l_p_order_line_rec.customer_id       := l_end_customer_id;
    -- For bug 3304668
    l_p_order_line_rec.end_customer_id   := l_end_customer_id;
    -- End bug fix 3304668
    l_p_order_line_rec.deliver_to_org_id := l_order_line_rec.deliver_to_org_id;
    --l_p_order_line_rec.ib_current_loc    := l_ib_current_loc;
    l_p_order_line_rec.ib_current_loc_id := l_current_site_use_id; --5147603
    --l_p_order_line_rec.ib_install_loc    := l_ib_install_loc;
    l_p_order_line_rec.ib_install_loc_id := l_install_site_use_id; --5147603
    -- Added for partner ordering.
    l_p_order_line_rec.sold_from_org_id  := l_order_line_rec.sold_from_org_id;
    l_p_order_line_rec.sold_to_org_id    := l_order_line_rec.sold_to_org_id;
    l_p_order_line_rec.agreement_id      := l_order_line_rec.agreement_id;
    l_p_order_line_rec.ship_to_contact_id:= l_order_line_rec.ship_to_contact_id;
    l_p_order_line_rec.invoice_to_contact_id:= l_order_line_rec.invoice_to_contact_id;

    l_p_order_line_rec.order_quantity_uom    := l_order_line_rec.order_quantity_uom;--fix for bug5589710
    l_p_order_line_rec.unit_price := l_order_line_rec.unit_selling_price;


    l_error_rec.source_header_ref_id := l_order_header_rec.header_id;
    l_error_rec.source_header_ref    := l_order_header_rec.order_number;
    l_error_rec.source_line_ref_id   := p_order_line_id;
    l_error_rec.source_line_ref      := l_order_line_rec.line_number||'.'||
                                        l_order_line_rec.shipment_number||'.'||
                                        l_order_line_rec.option_number;
    l_error_rec.inventory_item_id    := l_order_line_rec.inventory_item_id;

    debug('Order Information    :');
    debug('  order_number       : '||l_order_header_rec.order_number);
    debug('  header_id          : '||l_order_header_rec.header_id);
    debug('  line_number        : '||l_order_line_rec.line_number||'.'
                                   ||l_order_line_rec.shipment_number||'.'
                                   ||l_order_line_rec.option_number);
    debug('  ordered_item       : '||l_order_line_rec.ordered_item);
    debug('  item_type_code     : '||l_order_line_rec.item_type_code);
    debug('  status             : '||l_order_line_rec.flow_status_code);
    debug('  inventory_item_id  : '||l_order_line_rec.inventory_item_id);
    debug('  ship_from_org_id   : '||l_order_line_rec.ship_from_org_id);
    debug('  ordered_quantity   : '||l_order_line_rec.ordered_quantity);
    debug('  fulfilled_quantity : '||l_order_line_rec.fulfilled_quantity);
    debug('  fulfillment_date   : '||l_order_line_rec.fulfillment_date);
    debug('  ato_line_id        : '||l_order_line_rec.ato_line_id);
    debug('  top_model_line_id  : '||l_order_line_rec.top_model_line_id);
    debug('  link_to_line_id    : '||l_order_line_rec.link_to_line_id);

    debug('  customer_id        : '||l_end_customer_id);
    debug('  current_site_use_id: '||l_current_site_use_id);
    debug('  current_site_id    : '||l_default_info_rec.current_party_site_id);
    debug('  install_site_use_id: '||l_install_site_use_id);
    debug('  install_site_id    : '||l_default_info_rec.install_party_site_id);

    get_item_type(
      p_item_type_code    => l_order_line_rec.item_type_code,
      p_line_id           => l_order_line_rec.line_id,
      p_ato_line_id       => l_order_line_rec.ato_line_id,
      p_top_model_line_id => l_order_line_rec.top_model_line_id,
      x_item_type         => l_identified_item_type);

    l_default_info_rec.identified_item_type := l_identified_item_type;

    dbms_application_info.set_client_info(l_order_line_rec.org_id);

    l_om_session_key.session_hdr_id  := l_order_line_rec.config_header_id;
    l_om_session_key.session_rev_num := l_order_line_rec.config_rev_nbr;
    l_om_session_key.session_item_id := l_order_line_rec.configuration_id;

    l_macd_processing := csi_interface_pkg.check_macd_processing(
                            p_config_session_key => l_om_session_key,
                            x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_macd_processing THEN
      -- srramakr TSO with Equipment
      -- If this is a MACD order for shippable item that was previously unlocked by the RMA process
      -- then we need to update the Order line ID for the Item Instance.
      --
      SELECT nvl(shippable_item_flag ,'N')
      INTO  l_shippable_item_flag
      FROM MTL_SYSTEM_ITEMS_B
      WHERE  inventory_item_id = l_order_line_rec.inventory_item_id
      AND    organization_id   = l_order_line_rec.ship_from_org_id;
      --
      IF l_shippable_item_flag = 'Y' THEN
        l_ul_instance_rec.instance_id := NULL;
        Begin
          SELECT changed_instance_id,ctl.transaction_line_id
          INTO l_ul_instance_rec.instance_id,l_ul_txn_line_id
          FROM CSI_T_TRANSACTION_LINES ctl,
               CSI_T_TXN_LINE_DETAILS ctld
          WHERE  ctl.source_transaction_table = 'CONFIGURATOR'
          AND    ctl.config_session_hdr_id    = l_om_session_key.session_hdr_id
          AND    ctl.config_session_rev_num   = l_om_session_key.session_rev_num
          AND    ctl.config_session_item_id   = l_om_session_key.session_item_id
          AND    ctld.transaction_line_id = ctl.transaction_line_id
          AND    ctld.source_transaction_flag = 'Y';
        Exception
          when no_data_found then
            null;
        End;
        --
        IF l_ul_instance_rec.instance_id IS NOT NULL THEN
          select object_version_number
          into l_ul_instance_rec.object_version_number
          from CSI_ITEM_INSTANCES
          where instance_id = l_ul_instance_rec.instance_id;
          --
          l_ul_instance_rec.last_oe_order_line_id := p_order_line_id;
          --
          l_csi_txn_rec.source_line_ref_id      := p_order_line_id;
          l_csi_txn_rec.source_line_ref         := l_order_line_rec.line_number||'.'||
          l_order_line_rec.shipment_number||'.'||
          l_order_line_rec.option_number;
          l_csi_txn_rec.source_header_ref       := l_order_header_rec.order_number;
          l_csi_txn_rec.source_header_ref_id    := l_p_order_line_rec.header_id;

          l_csi_txn_rec.transaction_type_id     := csi_interface_pkg.g_macd_txn_type_id;  --l_txn_type_id; --bug 5194812

          l_csi_txn_rec.transaction_date        := sysdate;
          l_csi_txn_rec.source_transaction_date := nvl(l_order_line_rec.fulfillment_date, sysdate);
          --
          debug('  Inside API :csi_item_instance_pub.update_item_instance');
          debug('  instance_id      : '||l_ul_instance_rec.instance_id);
          debug('  Order Line ID         : '||l_ul_instance_rec.last_oe_order_line_id);
          --
          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_ul_instance_rec,
            p_party_tbl             => l_u_parties_tbl,
            p_account_tbl           => l_u_pty_accts_tbl,
            p_org_assignments_tbl   => l_u_org_units_tbl,
            p_ext_attrib_values_tbl => l_u_ea_values_tbl,
            p_pricing_attrib_tbl    => l_u_pricing_tbl,
            p_asset_assignment_tbl  => l_u_assets_tbl,
            p_txn_rec               => l_csi_txn_rec,
            x_instance_id_lst       => l_u_instance_ids_list,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);
          --
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            UPDATE csi_t_txn_line_details
            SET    processing_status       = 'PROCESSED'
            WHERE  transaction_line_id     = l_ul_txn_line_id;
            --
            RAISE skip_regular_process;
          END IF;
        END IF; -- Instance found check
      END IF; -- Shippable Item
      -- End of TSO with Equipment changes

      cz_fulfillment(
        p_order_line_id    => p_order_line_id,
        x_return_status    => l_return_status,
        x_return_message   => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      RAISE skip_regular_process;

    END IF;

    SELECT nvl(shippable_item_flag ,'N'),
           nvl(mtl_transactions_enabled_flag, 'N'),
           serial_number_control_code,
           lot_control_code,
           revision_qty_control_code,
           location_control_code,
           comms_nl_trackable_flag,
           bom_item_type,
           reservable_type,
           pick_components_flag,
           primary_uom_code
    INTO   l_shippable_item_flag,
           l_inv_transactable_flag,
           l_serial_code,
           l_lot_code,
           l_revision_control_code,
           l_locator_control_code,
           l_ib_trackable_flag,
           l_bom_item_type,
           l_reservable_type,
           l_pick_components_flag,
           l_primary_uom_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = l_order_line_rec.inventory_item_id
    AND    organization_id   = l_order_line_rec.ship_from_org_id;

    debug('  serial_code        : '||l_serial_code);
    debug('  shippable_flag     : '||l_shippable_item_flag);
    debug('  transactable_flag  : '||l_inv_transactable_flag);
    debug('  bom_item_type      : '||l_bom_item_type);

    l_p_order_line_rec.bom_item_type      := l_bom_item_type;
    l_p_order_line_rec.reservable_type    := l_reservable_type;
    l_p_order_line_rec.serial_code        := l_serial_code;
    l_default_info_rec.primary_uom_code   := l_primary_uom_code;

    l_error_rec.inventory_item_id         := l_order_line_rec.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code  := l_serial_code;
    l_error_rec.src_lot_ctrl_code         := l_lot_code;
    l_error_rec.src_rev_qty_ctrl_code     := l_revision_control_code;
    l_error_rec.src_location_ctrl_code    := l_locator_control_code;
    l_error_rec.comms_nl_trackable_flag   := l_ib_trackable_flag;

    --assign the values for the csi_txn_rec
    l_csi_txn_rec.source_line_ref_id      := p_order_line_id;
    l_csi_txn_rec.source_line_ref         := l_order_line_rec.line_number||'.'||
                                             l_order_line_rec.shipment_number||'.'||
                                             l_order_line_rec.option_number;
    l_csi_txn_rec.source_header_ref       := l_order_header_rec.order_number;
    l_csi_txn_rec.source_header_ref_id    := l_p_order_line_rec.header_id;
    l_csi_txn_rec.transaction_type_id     := l_txn_type_id;
    l_csi_txn_rec.transaction_date        := sysdate;
    l_csi_txn_rec.source_transaction_date := nvl(l_order_line_rec.fulfillment_date, sysdate);
    l_csi_txn_rec.transaction_status_code := 'PENDING';
    l_ato_rebuild_flag := 'N';

    IF l_order_line_rec.item_type_code in ('OPTION', 'CLASS')
       AND
       l_order_line_rec.ato_line_id is not null
    THEN

      get_config_info(
        p_line_id           => l_order_line_rec.line_id,
        p_ato_header_id     => l_order_line_rec.header_id,
        p_ato_line_id       => l_order_line_rec.ato_line_id,
        px_default_info_rec => l_default_info_rec,
        x_config_rec        => l_config_rec,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_order_line_rec.item_type_code = 'CLASS' THEN
        IF l_config_rec.make_flag = 'Y' THEN
          IF l_config_rec.serial_code IN (2, 5)
             OR
             l_default_info_rec.identified_item_type = 'ATO_SUB_MODEL'
             OR
             l_config_rec.sub_config_make_flag = 'Y'
          THEN
            l_ato_rebuild_flag := 'Y';
          END IF;
        END IF;
      END IF;

             --5076453
      IF l_default_info_rec.identified_item_type ='ATO_MODEL' AND
         l_order_line_rec.item_type_code in ('CLASS') THEN

	 IF l_order_line_rec.ato_line_id=l_order_line_rec.line_id THEN

	    SELECT ato_line_id
	    INTO l_ato_line_id
	    FROM oe_order_lines_all
	    WHERE line_id=l_order_line_rec.link_to_line_id;

	    IF l_ato_line_id IS NULL THEN
	       l_ato_rebuild_flag :='N';

	     END IF;
	  END IF;
        END IF;

      debug('ato_rebuild_flag : '||l_ato_rebuild_flag);

      IF l_config_rec.serial_code IN (2, 5, 6) THEN
        get_config_srl_instances(
          p_config_rec        => l_config_rec,
          p_sub_config_flag   => 'N',
          px_default_info_rec => l_default_info_rec,
          px_csi_txn_rec      => l_csi_txn_rec,
          x_config_instances  => l_config_instances,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      IF l_order_line_rec.item_type_code = 'OPTION' AND l_inv_transactable_flag = 'Y' THEN

        IF l_config_rec.make_flag = 'Y' THEN

          process_ato_option_from_wip(
            p_order_header_rec  => l_order_header_rec,
            p_order_line_rec    => l_order_line_rec,
            p_config_rec        => l_config_rec,
            p_config_instances  => l_config_instances,
            px_default_info_rec => l_default_info_rec,
            x_wip_processing    => l_wip_processing,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_wip_processing THEN
            RAISE skip_regular_process;
          END IF;

        END IF;

      END IF;

      -- if configuration is serialized then check if they are re-shippd
      IF l_config_rec.serial_code in (2, 5, 6) THEN

        IF l_config_instances.COUNT > 0 THEN
          check_for_re_shipment(
            p_header_id          => l_order_line_rec.header_id,
            px_config_instances  => l_config_instances,
            x_reship_found       => l_config_reship_found,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF l_config_reship_found THEN
          --assign the values for the csi_txn_rec
          -- get_reship_count
          get_reship_count(
            p_config_instances  => l_config_instances,
            x_reship_count      => l_config_reship_count,
            x_return_status     => l_return_status);

          IF l_config_instances.COUNT > 0 and l_config_reship_count > 0 THEN

            l_csi_txn_rec.source_line_ref_id      := p_order_line_id;
            l_csi_txn_rec.source_line_ref         := l_order_line_rec.line_number||'.'||
                                                     l_order_line_rec.shipment_number||'.'||
                                                     l_order_line_rec.option_number;
            l_csi_txn_rec.source_header_ref_id    := l_order_line_rec.header_id;
            l_csi_txn_rec.source_header_ref       := l_order_header_rec.order_number;
            l_csi_txn_rec.transaction_type_id     := l_txn_type_id;
            l_csi_txn_rec.transaction_date        := sysdate;
            l_csi_txn_rec.source_transaction_date := sysdate ;

            FOR l_cf_ind IN l_config_instances.FIRST .. l_config_instances.LAST
            LOOP

              IF l_config_instances(l_cf_ind).reship_flag = 'Y' THEN

                -- get_configs_inrelation_option_instances
                get_option_instances(
                  p_config_instance_id  => l_config_instances(l_cf_ind).instance_id,
                  p_option_item_id      => l_order_line_rec.inventory_item_id,
                  x_option_instances    => l_option_instances,
                  x_return_status       => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                IF l_option_instances.COUNT > 0 THEN
                  FOR l_o_ind IN l_option_instances.FIRST .. l_option_instances.LAST
                  LOOP
                    -- stamp_om_line
                    stamp_om_line(
                      p_instance_id   => l_option_instances(l_o_ind).instance_id,
                      p_order_line_id => p_order_line_id,
                      px_csi_txn_rec  => l_csi_txn_rec,
                      x_return_status => l_return_status);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;
                  END LOOP;
                END IF;
              END IF;
            END LOOP;

          END IF;

          IF l_config_reship_count > 0 THEN

            -- get the ratio between the config item qty and option that is getting fulfilled

            l_config_ratio := l_order_line_rec.ordered_quantity/l_config_rec.order_quantity;

            l_order_line_rec.fulfilled_quantity :=
               l_order_line_rec.fulfilled_quantity - (l_config_ratio * l_config_reship_count);

            debug('  config_ratio       : '||l_config_ratio);
            debug('  fulfilled_quantity : '||l_order_line_rec.fulfilled_quantity);

            IF l_order_line_rec.fulfilled_quantity = 0 THEN
              RAISE skip_regular_process;
            END IF;

          END IF;

        END IF;
      END IF;

    END IF;

    -- END MARK

    -- initialization
    l_split_flag       := 'N';
    l_ratio_split_flag := 'N';
    l_ratio_split_qty  := 1;

    IF l_order_line_rec.fulfilled_quantity > 1 THEN

      l_split_flag := nvl(fnd_profile.value('CSI_AUTO_SPLIT_INSTANCE'), 'N');

      debug('  auto split profile :'||l_split_flag);

      l_ratio_split_flag  := 'N';

      IF l_serial_code <> 1 THEN
        l_split_flag := 'Y';
      END IF;

      IF l_split_flag <> 'Y' THEN

        get_ib_trackable_children(
          p_current_line_id    => l_order_line_rec.line_id,
          p_om_vld_org_id      => l_default_info_rec.om_vld_org_id,
          x_trackable_line_tbl => l_trk_child_tbl,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_trk_child_tbl.count > 0 THEN

          l_split_flag := 'Y';

        ELSE

          debug('ib trackable children not found for order line');

          get_ib_trackable_parent(
            p_current_line_id  => l_order_line_rec.line_id,
            p_om_vld_org_id    => l_default_info_rec.om_vld_org_id,
            x_parent_line_rec  => l_trk_parent_rec,
            x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF nvl(l_trk_parent_rec.line_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
            l_ratio_split_flag := 'Y';
            l_split_flag       := 'Y';
            --fix for bug5096435
            IF l_order_line_rec.model_remnant_flag = 'Y' THEN
            BEGIN
            	select sum(ordered_quantity)
            	into l_order_line_qty
            	from oe_order_lines_all
            	where link_to_line_id = l_order_line_rec.link_to_line_id
            	and inventory_item_id = l_order_line_rec.inventory_item_id
            	and model_remnant_flag = 'Y';
            EXCEPTION
            WHEN others THEN
                NULL;
            END;
               l_ratio_split_qty := l_order_line_qty/l_trk_parent_rec.ordered_quantity;
            ELSE --end of fix of bug 5096435
            l_ratio_split_qty  := l_order_line_rec.ordered_quantity/
                                  l_trk_parent_rec.ordered_quantity;
	    END IF;
            debug('  parent child ratio :'||l_ratio_split_qty);
          ELSE
            debug('ib trackable parent not found for order line');
            l_ratio_split_flag := 'N';
            l_split_flag       := 'N';
          END IF;

        END IF;

      END IF; -- split_flag <> 'Y'

    END IF; -- fulfilled_quantity > 1

    debug('  split_flag       : '||l_split_flag);
    debug('  ratio_split_flag : '||l_ratio_split_flag);
    debug('  ratio_split_qty  : '||l_ratio_split_qty);

    l_default_info_rec.split_flag       := l_split_flag;
    l_default_info_rec.ratio_split_flag := l_ratio_split_flag;
    l_default_info_rec.split_ratio      := l_ratio_split_qty;

    /* the fulfillment event happens once and only once. This happens if all
       the shippable items(options/config) are shipped OR if the the line is
       short closed. If short closed then the fulfilled quantity can be less
       than the ordered quantity.
    */

    debug('  ordered quantity   : '||l_order_line_rec.ordered_quantity);
    debug('  fulfilled quantity : '||l_order_line_rec.fulfilled_quantity);

    IF l_order_line_rec.fulfilled_quantity < l_order_line_rec.ordered_quantity
    THEN
      l_partial := TRUE;
    END IF;

    -- check transaction details exist
    l_txn_line_rec.source_transaction_table := l_src_txn_table;
    l_txn_line_rec.source_transaction_id    := p_order_line_id;

    l_found := csi_t_txn_details_pvt.check_txn_details_exist(
                p_txn_line_rec => l_txn_line_rec);

    l_txn_line_rec.source_transaction_type_id := l_txn_type_id;

    IF NOT(l_found) THEN

     debug('installation details not found for the order line.');

      -- check if this line is eligible for cascade
      l_cascade_eligible := 'N';

      IF l_order_line_rec.top_model_line_id is not null THEN
        BEGIN
          SELECT 'Y'
          INTO   l_cascade_eligible
          FROM   csi_t_transaction_lines
          WHERE  source_transaction_table = l_src_txn_table
          AND    source_transaction_id    = l_order_line_rec.top_model_line_id;
        EXCEPTION
          WHEN others THEN
            null;
        END;
      END IF;

      l_cascaded_flag := 'N';

      IF l_cascade_eligible = 'Y' THEN

        debug('top model line ('||l_order_line_rec.top_model_line_id||') has transaction details.');

        SELECT ordered_quantity
        INTO   l_mdl_ordered_qty
        FROM   oe_order_lines_all
        WHERE  line_id = l_order_line_rec.top_model_line_id;

       --fix for bug5096435
       SELECT sum(ordered_quantity)/l_mdl_ordered_qty
       INTO l_qty_ratio
       FROM oe_order_lines_all
       WHERE link_to_line_id = l_order_line_rec.link_to_line_id
       AND inventory_item_id = l_order_line_rec.inventory_item_id;


        SELECT to_char(l_order_line_rec.top_model_line_id)||':'||
               to_char(l_order_line_rec.line_id)||':'||
               to_char(l_order_line_rec.inventory_item_id)||':'||
               decode(nvl(l_order_line_rec.item_revision, '###'),
                      '###', null, l_order_line_rec.item_revision||':')||
               to_char(l_qty_ratio)||':'||
               l_order_line_rec.order_quantity_uom ||':'||
               l_order_line_rec.ordered_quantity  --added for bug5096435
        INTO   l_model_hierarchy
        FROM  sys.dual;

        csi_t_utilities_pvt.cascade_child(
          p_data_string    => l_model_hierarchy,
          x_return_status  => l_return_status );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        -- call cascade
        l_found         := TRUE;
        l_cascaded_flag := 'Y';

      ELSE
        l_found := FALSE;
      END IF;

    END IF;

    -- call the get api
    IF (l_found) then

      BEGIN

        SELECT processing_status ,
               transaction_line_id
        INTO   l_processing_status,
               l_transaction_line_id
        FROM   csi_t_transaction_lines
        WHERE  source_transaction_table = l_src_txn_table
        AND    source_transaction_id    = p_order_line_id;

        l_default_info_rec.transaction_line_id := l_transaction_line_id;

        IF l_processing_status = 'PROCESSED' THEN
          debug('This transaction detail is already PROCESSED.');
          fnd_message.set_name('CSI', 'CSI_TXN_SRC_ALREADY_PROCESSED');
          fnd_message.set_token('SRC_TBL', l_src_txn_table);
          fnd_message.set_token('SRC_ID', p_order_line_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        UPDATE csi_t_transaction_lines
        SET    processing_status   = 'IN_PROCESS'
        WHERE  transaction_line_id = l_transaction_line_id;

      END;

      -- build the txn_query_rec
      l_txn_line_query_rec.transaction_line_id             := l_transaction_line_id;
      l_txn_line_detail_query_rec.transaction_line_id      := l_transaction_line_id;
      l_txn_line_detail_query_rec.processing_status        := 'UNPROCESSED';
      l_txn_line_detail_query_rec.source_transaction_flag  := 'Y';

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version               => 1,
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
        raise fnd_api.g_exc_error;
      END IF;

      l_txn_line_rec.transaction_line_id := l_transaction_line_id;

      /* check if instance reference is found in the user created txn details
         this would be for a RMA Fulfillment. Ex Cancelling an extended attribs
         for an existing instance etc..
      */

      IF l_g_line_dtl_tbl.COUNT > 0 THEN
        FOR l_ind in l_g_line_dtl_tbl.FIRST..l_g_line_dtl_tbl.LAST
        LOOP
          IF l_g_line_dtl_tbl(l_ind).instance_exists_flag = 'Y' THEN
            l_inst_ref_found := TRUE;
            exit;
          END IF;
        END LOOP;
      END IF;

      /* go to the end of the program and quit */
      IF (l_inst_ref_found) THEN

        demo_fulfillment(
          p_txn_type_id     => l_txn_type_id,
          p_order_line_rec  => l_order_line_rec,
          p_line_dtl_tbl    => l_g_line_dtl_tbl,
          px_csi_txn_rec    => l_csi_txn_rec,
          x_return_status   => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        goto DEMO_FULFILL;

      END IF;

    ELSE -- [Transaction Detail Not Found]

      create_dflt_txn_dtls(
        p_order_line_rec    => l_order_line_rec,
        px_default_info_rec => l_default_info_rec,
        x_txn_line_rec      => l_txn_line_rec,
        x_tld_tbl           => l_line_dtl_tbl,
        x_tiir_tbl          => l_ii_rltns_tbl,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_default_info_rec.transaction_line_id := l_txn_line_rec.transaction_line_id;

    END IF;

    l_p_order_line_rec.trx_line_id := l_txn_line_rec.transaction_line_id;

    UPDATE csi_t_transaction_lines
    SET    processing_status   = 'IN_PROCESS'
    WHERE  transaction_line_id = l_txn_line_rec.transaction_line_id;

    /* transaction details found case */
    IF (l_found) THEN
      l_line_dtl_tbl := l_g_line_dtl_tbl;
      l_ii_rltns_tbl := l_g_ii_rltns_tbl;
    ELSE
      l_line_dtl_tbl := l_line_dtl_tbl;
      l_ii_rltns_tbl := l_ii_rltns_tbl;
    END IF;


    IF l_split_flag = 'Y' THEN
      IF l_ratio_split_flag = 'Y' THEN

        split_txn_dtls_with_ratio(
          p_quantity_ratio => l_ratio_split_qty,
          px_line_dtl_tbl  => l_line_dtl_tbl,
          x_return_status  => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

      ELSE

        split_txn_dtls(
          p_line_dtl_tbl   => l_line_dtl_tbl,
          p_ii_rltns_tbl   => l_ii_rltns_tbl,
          x_return_status  => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

        ---added (start) for m-to-m enhancements
        csi_utl_pkg.build_txn_relations(
          l_line_dtl_tbl,
          l_temp_txn_ii_rltns_tbl,
          x_return_status);

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_temp_txn_ii_rltns_tbl.count > 0 THEN
          csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
            p_api_version       => 1.0,
            p_commit            => fnd_api.g_false,
            p_init_msg_list     => fnd_api.g_true,
            p_validation_level  => fnd_api.g_valid_level_full,
            px_txn_ii_rltns_tbl => l_temp_txn_ii_rltns_tbl,
            x_return_status     => x_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            raise fnd_api.g_exc_error;
          END IF;
        END IF ; ---l_temp_txn_ii_rltns_tbl.count>0
        ---added (end) for m-to-m enhancements

      END IF;
    END IF;

    IF l_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
      LOOP
        UPDATE csi_t_txn_line_details
        SET    processing_status = 'IN_PROCESS'
        WHERE  txn_line_detail_id = l_line_dtl_tbl(l_td_ind).txn_line_detail_id;
      END LOOP;
    END IF;

    debug( 'creating csi transaction for the fulfillment line.');

    create_csi_transaction(
      px_csi_txn_rec   => l_csi_txn_rec,
      x_return_status  => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('  ato_rebuild_flag   : '||l_ato_rebuild_flag);

    IF l_order_line_rec.item_type_code in ('KIT', 'MODEL', 'CLASS') THEN

      IF l_ato_rebuild_flag = 'Y' THEN
        rebuild_relation_for_ato(
          p_order_line_rec    => l_order_line_rec,
          p_config_rec        => l_config_rec,
          p_config_instances  => l_config_instances,
          px_default_info_rec => l_default_info_rec,
          px_csi_txn_rec      => l_csi_txn_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE

        /* this routine checks for any relation within the order lines and builds
           a ii relation table for the final processor */

    debug('Model remnant flag...'||l_order_line_rec.model_remnant_flag);

        build_child_relation(
          p_order_line_rec       => l_order_line_rec,
          p_txn_line_rec         => l_txn_line_rec,
          p_identified_item_type => l_identified_item_type,
          px_default_info_rec    => l_default_info_rec,
          px_csi_txn_rec         => l_csi_txn_rec,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;
    END IF;

    debug('Model remnant flag...'||l_order_line_rec.model_remnant_flag);


     IF nvl(l_order_line_rec.link_to_line_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      IF l_ato_rebuild_flag = 'N' THEN

        build_parent_relation(
          p_order_line_rec       => l_order_line_rec,
          p_txn_line_rec         => l_txn_line_rec,
          p_split_flag           => l_split_flag,
          p_identified_item_type => l_identified_item_type,
          p_config_rec           => l_config_rec,
          p_config_instances     => l_config_instances,
          px_default_info_rec    => l_default_info_rec,
          px_csi_txn_rec         => l_csi_txn_rec,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    END IF;

    <<DEMO_FULFILL>>

    -- get the transaction details for final processing
    /* mark all the non source transaction details as 'IN_PROCESS' */

    UPDATE csi_t_txn_line_details
    SET    processing_status       = 'IN_PROCESS'
    WHERE  transaction_line_id     = l_txn_line_rec.transaction_line_id
    AND    source_transaction_flag = 'N';

    -- FP for bug 8857720 and 8909397
    --l_default_info_rec.current_party_site_id := l_current_site_use_id; --5147603
    --l_default_info_rec.install_party_site_id := l_install_site_use_id; --5147603

    query_tld_and_update_ib(
      p_order_header_rec   => l_order_header_rec,
      p_order_line_rec     => l_p_order_line_rec, --fix for bug 5589710
      px_default_info_rec  => l_default_info_rec,
      px_csi_txn_rec       => l_csi_txn_rec,
      px_error_rec         => l_error_rec,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('order fulfillment integration successfull for order line_id : '||p_order_line_id);

  EXCEPTION
    WHEN skip_regular_process THEN
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN fnd_api.g_exc_error THEN
      rollback to order_fulfillment;
      x_return_status := fnd_api.g_ret_sts_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      l_error_rec.error_text := l_error_message;
      debug('Error(E) :'||l_error_message);
      px_trx_error_rec := l_error_rec;

      UPDATE csi_t_transaction_lines
      SET    processing_status        = 'ERROR'
      WHERE  source_transaction_id    = p_order_line_id
      AND    source_transaction_table = 'OE_ORDER_LINES_ALL';

      csi_utl_pkg.update_txn_line_dtl (
        p_source_trx_id    => p_order_line_id,
        p_source_trx_table => 'OE_ORDER_LINES_ALL',
        p_api_name         => l_api_name,
        p_error_message    => l_error_message );

    WHEN others THEN
      rollback to order_fulfillment;
      fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',substr(sqlerrm,1,540));
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      l_error_rec.error_text := l_error_message;
      debug('Error(O) :'||l_error_message);
      px_trx_error_rec := l_error_rec;

      UPDATE csi_t_transaction_lines
      SET    processing_status        = 'ERROR'
      WHERE  source_transaction_id    = p_order_line_id
      AND    source_transaction_table = 'OE_ORDER_LINES_ALL';

      csi_utl_pkg.update_txn_line_dtl (
        p_source_trx_id    => p_order_line_id,
        p_source_trx_table => 'OE_ORDER_LINES_ALL',
        p_api_name         => l_api_name,
        p_error_message    => l_error_message );

  END order_fulfillment;

  PROCEDURE construct_txn_dtls(
    x_order_shipment_tbl      IN OUT NOCOPY csi_order_ship_pub.order_shipment_tbl,
    p_order_line_rec          IN csi_order_ship_pub.order_line_rec,
    p_trackable_parent        IN boolean,
    x_trx_line_id             OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_instance_id          number;
    l_loop_count           number := 0;
    l_inst_party_id        number;
    l_ip_account_id        number;
    l_sub_type_id          number;
    l_party_site_id        number;
    l_index                number;
    l_trx_line_id          number;
    l_txn_line_rec_exists  boolean  := FALSE;
    l_create_txn_line_dtls boolean  := TRUE;

    l_c_tld_rec            csi_t_datastructures_grp.txn_line_detail_rec ;

    l_c_tl_rec             csi_t_datastructures_grp.txn_line_rec ;
    l_c_tld_tbl            csi_t_datastructures_grp.txn_line_detail_tbl;
    l_c_tpd_tbl            csi_t_datastructures_grp.txn_party_detail_tbl ;
    l_c_tpad_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_c_toa_tbl            csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_c_teav_tbl           csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_c_ts_tbl             csi_t_datastructures_grp.txn_systems_tbl;
    l_c_tiir_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_continue             boolean := TRUE;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

    l_install_party_site_id  number;

  BEGIN

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('construct_txn_dtls');

    /* assign values for the columns in Txn_line_rec */
    l_c_tl_rec.source_transaction_id      := p_order_line_rec.order_line_id ;
    l_c_tl_rec.source_transaction_table   := 'OE_ORDER_LINES_ALL';
    l_c_tl_rec.source_transaction_type_id := 51;
    l_c_tl_rec.processing_status          := 'IN_PROCESS';
    l_c_tl_rec.object_version_number      := 1;

    /* getting the default sub type id */
    csi_utl_pkg.get_dflt_sub_type_id(
      p_transaction_type_id  => 51,
      x_sub_type_id          => l_sub_type_id,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    /*------------------------------------------------------*/
    /* Check if transaction_line_rec exists .If it does not */
    /* exist then create the trx_line_rec only              */
    /*------------------------------------------------------*/

    l_continue := TRUE;

    LOOP

      BEGIN

        SELECT transaction_line_id
        INTO   l_trx_line_id
        FROM   csi_t_transaction_lines
        WHERE  source_transaction_id      = l_c_tl_rec.source_transaction_id
        AND    source_transaction_table   = l_c_tl_rec.source_transaction_table
        AND    source_transaction_type_id = l_c_tl_rec.source_transaction_type_id;

        l_continue := TRUE;
        debug('Transaction Detail-Hdr Found. Ttansaction Line ID :'||l_trx_line_id);

      EXCEPTION
        WHEN no_data_found THEN
          debug('Not Processed. So creating one.');

          BEGIN

            debug('Transaction Detail-Hdr NOT found. So, creating one.');

            csi_t_transaction_lines_pkg.insert_row(
              px_transaction_line_id       => l_c_tl_rec.transaction_line_id,
              p_source_transaction_type_id => l_c_tl_rec.source_transaction_type_id,
              p_source_transaction_table => l_c_tl_rec.source_transaction_table,

              ---Added (Start) for m-to-m enhancements
              p_source_txn_header_id    => l_c_tl_rec.source_txn_header_id,
              ---Added (End) for m-to-m enhancements
              p_source_transaction_id    => l_c_tl_rec.source_transaction_id,

              -- Added for CZ Integration (Begin)
              p_config_session_hdr_id  => l_c_tl_rec.config_session_hdr_id ,
              p_config_session_rev_num  => l_c_tl_rec.config_session_rev_num ,
              p_config_session_item_id  => l_c_tl_rec.config_session_item_id ,
              p_config_valid_status  => l_c_tl_rec.config_valid_status ,
              p_source_transaction_status  => l_c_tl_rec.source_transaction_status ,
            -- Added for CZ Integration (End)
              p_error_code               => l_c_tl_rec.error_code,
              p_error_explanation        => l_c_tl_rec.error_explanation,
              p_processing_status        => 'SUBMIT',
              p_attribute1               => l_c_tl_rec.attribute1,
              p_attribute2               => l_c_tl_rec.attribute2,
              p_attribute3               => l_c_tl_rec.attribute3,
              p_attribute4               => l_c_tl_rec.attribute4,
              p_attribute5               => l_c_tl_rec.attribute5,
              p_attribute6               => l_c_tl_rec.attribute6,
              p_attribute7               => l_c_tl_rec.attribute7,
              p_attribute8               => l_c_tl_rec.attribute8,
              p_attribute9               => l_c_tl_rec.attribute9,
              p_attribute10              => l_c_tl_rec.attribute10,
              p_attribute11              => l_c_tl_rec.attribute11,
              p_attribute12              => l_c_tl_rec.attribute12,
              p_attribute13              => l_c_tl_rec.attribute13,
              p_attribute14              => l_c_tl_rec.attribute14,
              p_attribute15              => l_c_tl_rec.attribute15,
              p_created_by               => fnd_global.user_id,
              p_creation_date            => sysdate,
              p_last_updated_by          => fnd_global.user_id,
              p_last_update_date         => sysdate,
              p_last_update_login        => fnd_global.login_id,
              p_object_version_number    => 1.0,
              p_context                  => l_c_tl_rec.context);

            l_trx_line_id := l_c_tl_rec.transaction_line_id;
            l_continue := TRUE;

        EXCEPTION
          WHEN dup_val_on_index THEN
            debug('DUP_VAL_ON_INDEX detected while creating Transaction Detail-Hdr.');
            l_continue := FALSE;
          WHEN others THEN

            fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE','insert_row failed '||sqlerrm);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
        END;
      END ;
      IF l_continue THEN
        exit;
      END IF;
    END LOOP;

    x_trx_line_id := l_trx_line_id;

    IF x_order_shipment_tbl.count > 0 THEN
      FOR i IN x_order_shipment_tbl.FIRST..x_order_shipment_tbl.LAST LOOP

          BEGIN
            SELECT party_site_id
            INTO   l_party_site_id
            FROM   hz_cust_acct_sites_all c,
                   hz_cust_site_uses_all u
            WHERE  c.cust_acct_site_id = u.cust_acct_site_id
            AND    u.site_use_id = x_order_shipment_tbl(i).ib_current_loc_id;
          EXCEPTION
            WHEN no_data_found THEN
              fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
              fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_current_loc_id);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            WHEN too_many_rows THEN
              fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
              fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_current_loc_id);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          END;

          IF x_order_shipment_tbl(i).ib_install_loc is not null
            AND
             x_order_shipment_tbl(i).ib_install_loc_id is not null
            AND
             x_order_shipment_tbl(i).ib_install_loc_id <> fnd_api.g_miss_num
          THEN
            BEGIN
              SELECT party_site_id
              INTO   l_install_party_site_id
              FROM   hz_cust_acct_sites_all c,
                     hz_cust_site_uses_all u
              WHERE  c.cust_acct_site_id = u.cust_acct_site_id
              AND    u.site_use_id = x_order_shipment_tbl(i).ib_install_loc_id;
            EXCEPTION
              WHEN no_data_found THEN
                fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
                fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_install_loc_id);
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
              WHEN too_many_rows THEN
                fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
                fnd_message.set_token('LOCATION_ID', x_order_shipment_tbl(i).ib_install_loc_id);
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
            END;
          END IF;

          -- IF p_trackable_parent AND x_order_shipment_tbl(i).shipped_quantity > 1 THEN
          --   l_loop_count := x_order_shipment_tbl(i).shipped_quantity;
          --   x_order_shipment_tbl(i).shipped_quantity := 1;
          -- ELSE
          --   l_loop_count := 1;
          -- END IF;

          -- FOR ind IN 1 .. l_loop_count
          -- LOOP

            /* Initialize the pl/sql tables */
            l_c_tld_tbl.delete;
            l_c_tpd_tbl.delete;
            l_c_tpad_tbl.delete;
            l_c_toa_tbl.delete;
            l_c_teav_tbl.delete;
            l_c_ts_tbl.delete;
            l_c_tiir_tbl.delete;

            /* assign values for the columns in Txn_line_details_tbl */
            IF ( x_order_shipment_tbl(i).instance_id is not null
              AND
               x_order_shipment_tbl(i).instance_id <> fnd_api.g_miss_num )
            THEN
              l_c_tld_tbl(i).instance_id           := x_order_shipment_tbl(i).instance_id;
              l_c_tld_tbl(i).instance_exists_flag  := 'Y';

              l_inst_party_id := csi_utl_pkg.get_instance_party_id(x_order_shipment_tbl(i).instance_id);

              IF l_inst_party_id = -1 THEN
                 raise fnd_api.g_exc_error;
              END IF;

            END IF;

            l_c_tld_tbl(i).source_transaction_flag := 'Y';
            l_c_tld_tbl(i).sub_type_id           := l_sub_type_id ;
            l_c_tld_tbl(i).inventory_item_id     := x_order_shipment_tbl(i).inventory_item_id  ;
            l_c_tld_tbl(i).inv_organization_id   := x_order_shipment_tbl(i).organization_id  ;
            l_c_tld_tbl(i).inventory_revision    := x_order_shipment_tbl(i).revision  ;
            l_c_tld_tbl(i).item_condition_id     := fnd_api.g_miss_num;
            l_c_tld_tbl(i).instance_type_code    := fnd_api.g_miss_char;
            l_c_tld_tbl(i).quantity              := x_order_shipment_tbl(i).shipped_quantity  ;
            l_c_tld_tbl(i).unit_of_measure       := x_order_shipment_tbl(i).transaction_uom ;
            l_c_tld_tbl(i).serial_number         := x_order_shipment_tbl(i).serial_number;
            l_c_tld_tbl(i).lot_number            := x_order_shipment_tbl(i).lot_number;
            l_c_tld_tbl(i).location_type_code    := 'HZ_PARTY_SITES';
            l_c_tld_tbl(i).location_id           := l_party_site_id;
            -- For partner ordering
            l_c_tld_tbl(i).install_location_type_code    := 'HZ_PARTY_SITES';
            l_c_tld_tbl(i).install_location_id           := l_install_party_site_id;
            -- For partner ordering
            l_c_tld_tbl(i).sellable_flag         := 'Y';
            l_c_tld_tbl(i).object_version_number := 1  ;
            l_c_tld_tbl(i).preserve_detail_flag  := 'Y';
            l_c_tld_tbl(i).processing_status     := 'IN_PROCESS';
            l_c_tld_tbl(i).active_start_date     := x_order_shipment_tbl(i).transaction_date;

            IF p_order_line_rec.serial_code <> 1   Then
              l_c_tld_tbl(i).mfg_serial_number_flag := 'Y';
              l_c_tld_tbl(i).quantity               := 1;
            ELSE
              l_c_tld_tbl(i).mfg_serial_number_flag  := 'N';
            END IF;

            -- l_inst_party_id := csi_utl_pkg.get_instance_party_id(l_instance_id);

            -- IF l_inst_party_id = -1 THEN
            --  raise fnd_api.g_exc_error;
            -- END IF;

            /* assign values for the columns in txn_party_detail_tbl*/
            l_c_tpd_tbl(i).instance_party_id      := l_inst_party_id;
            l_c_tpd_tbl(i).party_source_id        := x_order_shipment_tbl(i).party_id;
            l_c_tpd_tbl(i).party_source_table     := 'HZ_PARTIES';
            l_c_tpd_tbl(i).relationship_type_code := 'OWNER';
            l_c_tpd_tbl(i).contact_flag           := 'N';
            l_c_tpd_tbl(i).preserve_detail_flag   := 'Y';
            l_c_tpd_tbl(i).object_version_number  := 1;
            l_c_tpd_tbl(i).txn_line_details_index := i;

            /* get ip_account_id if instance_party_id exist */

             IF l_inst_party_id is not null THEN
               l_ip_account_id := csi_utl_pkg.get_ip_account_id(l_inst_party_id);

              -- /* If ip_account_id is -1 then           */
              -- /* party account does not exist in IB    */

               IF l_ip_account_id = -1 THEN
                  l_ip_account_id := NULL;
                 debug('Party account not found for instance. create one.. ');
               END IF;
             END IF;

            /* assign values for the columns in txn_pty_acct_dtl_tbl */
            l_c_tpad_tbl(i).ip_account_id          := l_ip_account_id;
            l_c_tpad_tbl(i).account_id             := x_order_shipment_tbl(i).party_account_id;
            l_c_tpad_tbl(i).bill_to_address_id     := x_order_shipment_tbl(i).invoice_to_org_id;
            l_c_tpad_tbl(i).ship_to_address_id     := x_order_shipment_tbl(i).ship_to_org_id;
            l_c_tpad_tbl(i).relationship_type_code := 'OWNER';
            l_c_tpad_tbl(i).preserve_detail_flag   := 'Y';
            l_c_tpad_tbl(i).object_version_number  := 1;
            l_c_tpad_tbl(i).txn_party_details_index := i;

            /*assign values for the columns in x_txn_org_assgn_tbl */
            IF nvl(x_order_shipment_tbl(i).sold_from_org_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
            THEN
              l_c_toa_tbl(i).txn_operating_unit_id  := fnd_api.g_miss_num;
              l_c_toa_tbl(i).txn_line_detail_id     := fnd_api.g_miss_num;
              l_c_toa_tbl(i).instance_ou_id         := fnd_api.g_miss_num;
              l_c_toa_tbl(i).operating_unit_id      := x_order_shipment_tbl(i).sold_from_org_id;
              l_c_toa_tbl(i).relationship_type_code := 'SOLD_FROM';
              l_c_toa_tbl(i).preserve_detail_flag   := 'Y';
              l_c_toa_tbl(i).txn_line_details_index := i;
              l_c_toa_tbl(i).object_version_number  := 1;
            END IF;

            -- Mark the shipment rec as processed
            x_order_shipment_tbl(i).txn_dtls_qty   := x_order_shipment_tbl(i).shipped_quantity ;
            x_order_shipment_tbl(i).instance_match := 'Y';
            x_order_shipment_tbl(i).quantity_match := 'Y';

            l_index := i;
            l_c_tld_rec                     := l_c_tld_tbl(i);
            l_c_tld_rec.transaction_line_id := l_trx_line_id;

            -- call api to create the transaction line details
            csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
              p_api_version              => 1.0 ,
              p_commit                   => fnd_api.g_false,
              p_init_msg_list            => fnd_api.g_true,
              p_validation_level         => fnd_api.g_valid_level_none,
              p_txn_line_dtl_index       => l_index,
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
              raise fnd_api.g_exc_error;
            END IF;

          -- END LOOP;

      END LOOP; --end of processing all shipping table
    END IF; -- shipping table count > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END construct_txn_dtls;


  PROCEDURE logical_drop_ship(
    p_mtl_txn_id           IN  number,
    p_message_id           IN  number,
    x_return_status        OUT NOCOPY varchar2,
    px_trx_error_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec)
  IS

    l_api_name             varchar2(30) := 'logical_drop_ship';
    l_txn_line_id          number;
    l_txn_type_id          number := 51;
    l_txn_sub_type_id      number ;
    l_src_txn_table        varchar2(30) := 'OE_ORDER_LINES_ALL';
    p_order_line_id        number;

    l_debug_level          number;
    l_error_message        varchar2(2000);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(2000);
    l_msg_count            number;

    skip_regular_process   exception;
    l_error_rec            csi_datastructures_pub.transaction_error_rec;
    l_order_line_rec       csi_order_ship_pub.order_line_rec;
    x_order_shipment_tbl   csi_order_ship_pub.order_shipment_tbl;
    l_count                number := 0;
    l_party_id             number;
    l_uom_rate             number;
    l_shipped_qty          number;
    p_trackable_parent     boolean;
    x_trx_line_id          number;

    l_txn_line_rec         csi_t_datastructures_grp.txn_line_rec;
    l_trx_detail_exist     boolean := FALSE;
    l_trx_rec              csi_datastructures_pub.transaction_rec;

    l_exp_instance_rec     csi_datastructures_pub.instance_rec;
    l_exp_instance_id_lst  csi_datastructures_pub.id_tbl;
    l_exp_instance_id      number;
    l_exp_obj_ver_num      number;
    l_exp_active_end_date  date;
    l_exp_loc_type_code    varchar2(30);

    p_instance_rec          csi_datastructures_pub.instance_rec;
    p_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    p_party_tbl             csi_datastructures_pub.party_tbl;
    p_party_account_tbl     csi_datastructures_pub.party_account_tbl;
    p_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    p_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
    p_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
    p_txn_rec               csi_datastructures_pub.transaction_rec;
    x_instance_id_lst       csi_datastructures_pub.id_tbl;
    -- x_return_status         varchar2(2000);
    x_msg_count             number;
    x_msg_data              varchar2(2000);
    t_output                varchar2(2000);
    t_msg_dummy             number;
    l_inst_party_id         number;

    l_inv_transactable_flag varchar2(1);
    l_serial_code           number;
    l_lot_code              number;
    l_revision_control_code number;
    l_locator_control_code  number;
    l_ib_trackable_flag     varchar2(1);
    l_shippable_item_flag   varchar2(1) := 'N';
    l_ship_from_org_id      number;


    CURSOR mmt_cur(p_mtl_txn_id IN NUMBER) IS
      SELECT ool.line_id,
             ool.header_id,
             ool.item_type_code,
             ool.cust_po_number,
             ool.line_type_id,
             ool.ato_line_id,
             ool.top_model_line_id,
             ool.link_to_line_id,
             NVL(ool.invoice_to_contact_id ,ooh.invoice_to_contact_id ) invoice_to_contact_id ,
             NVL(ool.ship_to_contact_id, ooh.ship_to_contact_id) ship_to_contact_id,
             NVL(ool.ship_from_org_id, ooh.ship_from_org_id)     ship_from_org_id  ,
             NVL(ool.sold_to_org_id, ooh.sold_to_org_id)         sold_to_org_id    ,
             NVL(ool.sold_from_org_id, ooh.sold_from_org_id)     sold_from_org_id  ,
             NVL(ool.ship_to_org_id, ooh.ship_to_org_id)         ship_to_org_id    ,
             NVL(ool.invoice_to_org_id, ooh.invoice_to_org_id)   invoice_to_org_id ,
             NVL(ool.deliver_to_org_id, ooh.deliver_to_org_id)   deliver_to_org_id ,
             ool.ordered_quantity,
             ool.shipped_quantity ord_line_shipped_qty,
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
             to_number(null)         ib_current_loc_id
      FROM   oe_order_headers_all         ooh,
             oe_order_lines_all           ool,
             mtl_system_items             msi,
             mtl_unit_transactions        mut,
             mtl_material_transactions    mmt,
             mtl_secondary_inventories    msei,
             hr_all_organization_units    haou
      WHERE  mmt.transaction_id       = p_mtl_txn_id
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
             ool.line_type_id,
             ool.ato_line_id,
             ool.top_model_line_id,
             ool.link_to_line_id,
             NVL(ool.invoice_to_contact_id, ooh.invoice_to_contact_id ) invoice_to_contact_id ,
             NVL(ool.ship_to_contact_id, ooh.ship_to_contact_id)  ship_to_contact_id,
             NVL(ool.ship_from_org_id , ooh.ship_from_org_id)     ship_from_org_id  ,
             NVL(ool.sold_to_org_id , ooh.sold_to_org_id)         sold_to_org_id    ,
             NVL(ool.sold_from_org_id, ooh.sold_from_org_id)      sold_from_org_id  ,
             NVL(ool.ship_to_org_id , ooh.ship_to_org_id)         ship_to_org_id    ,
             NVL(ool.invoice_to_org_id, ooh.invoice_to_org_id)    invoice_to_org_id ,
             NVL(ool.deliver_to_org_id, ooh.deliver_to_org_id)   deliver_to_org_id ,
             ool.ordered_quantity,
             ool.shipped_quantity ord_line_shipped_qty,
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
             to_number(null)         ib_current_loc_id
      FROM   oe_order_headers_all         ooh,
             oe_order_lines_all           ool,
             mtl_system_items             msi,
             mtl_unit_transactions        mut,
             mtl_transaction_lot_numbers  mtln,
             mtl_material_transactions    mmt,
             mtl_secondary_inventories    msei,
             hr_all_organization_units    haou
      WHERE  mmt.transaction_id         = p_mtl_txn_id
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
    l_error_rec     := px_trx_error_rec;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

      SELECT trx_source_line_id
      INTO   p_order_line_id
      FROM   mtl_material_transactions
      WHERE  transaction_id = p_mtl_txn_id;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csisoful',
      p_file_segment2 => p_order_line_id);

    api_log(l_api_name);

    debug('  Transaction Time   :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type   : Logical Drop Shipment');
    debug('  Order Line ID      :'||p_order_line_id);

    l_error_rec.source_id := p_mtl_txn_id;

    /* this routine checks if ib is active */
    csi_utility_grp.check_ib_active;

    -- Get the order line details
    csi_utl_pkg.get_order_line_dtls(
      p_mtl_transaction_id => p_mtl_txn_id,
      x_order_line_rec     => l_order_line_rec,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    dbms_application_info.set_client_info(l_order_line_rec.org_id);

    SELECT ship_from_org_id
    INTO   l_ship_from_org_id
    FROM   oe_order_lines_all
    WHERE  line_id = p_order_line_id;

    SELECT nvl(shippable_item_flag ,'N'),
           nvl(mtl_transactions_enabled_flag, 'N'),
           serial_number_control_code,
           lot_control_code,
           revision_qty_control_code,
           location_control_code,
           comms_nl_trackable_flag
    INTO   l_shippable_item_flag,
           l_inv_transactable_flag,
           l_serial_code,
           l_lot_code,
           l_revision_control_code,
           l_locator_control_code,
           l_ib_trackable_flag
    FROM   mtl_system_items
    WHERE  inventory_item_id = l_order_line_rec.inv_item_id
    AND    organization_id   = l_ship_from_org_id;

    debug('  serial_control_code :'||l_serial_code);
    debug('  shippable_item_flag :'||l_shippable_item_flag);
    debug('  transactable_flag   :'||l_inv_transactable_flag);

    -- added for bug 3441361
    l_order_line_rec.serial_code         := l_serial_code;

    l_error_rec.src_serial_num_ctrl_code := l_serial_code;
    l_error_rec.src_lot_ctrl_code        := l_lot_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_revision_control_code;
    l_error_rec.src_location_ctrl_code   := l_locator_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_ib_trackable_flag;

    l_error_rec.source_header_ref_id := l_order_line_rec.header_id;
    l_error_rec.source_header_ref    := l_order_line_rec.order_number;
    l_error_rec.source_line_ref_id   := p_order_line_id;
    l_error_rec.source_line_ref      := l_order_line_rec.line_number;
    l_error_rec.inventory_item_id    := l_order_line_rec.inv_item_id;

    -- Assign parameters for txn_line_rec
    l_txn_line_rec.source_transaction_id       :=  l_order_line_rec.order_line_id;
    l_txn_line_rec.source_transaction_table    :=  'OE_ORDER_LINES_ALL';

    -- Check If user entered Transaction Details Exists
    l_trx_detail_exist := csi_t_txn_details_grp.check_txn_details_exist(
                          p_txn_line_rec  => l_txn_line_rec );

    IF Not l_trx_detail_exist THEN

      debug('User entered Transaction details not found');

      -- Build Transaction Details.
      FOR mmt_rec IN mmt_cur(p_mtl_txn_id) LOOP

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


        csi_utl_pkg.get_party_id(
          p_cust_acct_id  => mmt_rec.end_customer_id, -- mmt_rec.sold_to_org_id,
          x_party_id      => l_party_id,
          x_return_status => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           raise fnd_api.g_exc_error;
        END IF;

        debug('Customer_id         :'||mmt_rec.end_customer_id); -- mmt_rec.sold_to_org_id);
        debug('Party_id            :'||l_party_id);

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

        x_order_shipment_tbl(l_count).line_id            := mmt_rec.line_id ;
        x_order_shipment_tbl(l_count).header_id          := mmt_rec.header_id;
        -- x_order_shipment_tbl(l_count).instance_id        := l_instance_header_tbl(1).instance_id;
        -- x_order_shipment_tbl(l_count).instance_qty       := l_instance_header_tbl(1).quantity;
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
        x_order_shipment_tbl(l_count).customer_id        := mmt_rec.end_customer_id; -- mmt_rec.sold_to_org_id ;
        x_order_shipment_tbl(l_count).transaction_date   := mmt_rec.transaction_date ;
        x_order_shipment_tbl(l_count).item_type_code     := mmt_rec.item_type_code ;
        x_order_shipment_tbl(l_count).cust_po_number     := mmt_rec.cust_po_number ;
        x_order_shipment_tbl(l_count).ato_line_id        := mmt_rec.ato_line_id ;
        x_order_shipment_tbl(l_count).top_model_line_id  := mmt_rec.top_model_line_id ;
        x_order_shipment_tbl(l_count).link_to_line_id    := mmt_rec.link_to_line_id ;
        x_order_shipment_tbl(l_count).instance_match     := 'N' ;
        x_order_shipment_tbl(l_count).quantity_match     := 'N' ;
        x_order_shipment_tbl(l_count).invoice_to_contact_id   := mmt_rec.invoice_to_contact_id ;
        x_order_shipment_tbl(l_count).ord_line_shipped_qty    :=  mmt_rec.ord_line_shipped_qty;
        -- Added for Partner Ordering.
        x_order_shipment_tbl(l_count).ib_install_loc_id  := mmt_rec.ib_install_loc_id;
        x_order_shipment_tbl(l_count).ib_current_loc_id  := mmt_rec.ib_current_loc_id;
        x_order_shipment_tbl(l_count).ib_install_loc     := mmt_rec.ib_install_loc;
        x_order_shipment_tbl(l_count).ib_current_loc     := mmt_rec.ib_current_loc;

        -- x_order_shipment_tbl(l_count).inst_obj_version_number :=  l_instance_header_tbl(1).object_version_number;

        IF l_serial_code in (2,5,6) THEN
          x_order_shipment_tbl(l_count).shipped_quantity := 1;

          -- Check if an instance with the same serial number exists as CUST_PROD

          BEGIN
            SELECT instance_id,
                   object_version_number,
                   active_end_date,
                   location_type_code
            INTO   l_exp_instance_id,
                   l_exp_obj_ver_num,
                   l_exp_active_end_date,
                   l_exp_loc_type_code
            FROM   csi_item_instances
            WHERE  inventory_item_id = mmt_rec.inventory_item_id
            AND    serial_number     = mmt_rec.serial_number;
          EXCEPTION
            WHEN no_data_found THEN
              null;
          END;

          IF l_exp_instance_id is not null Then
            debug('found instance '||l_exp_instance_id||' for Item '||mmt_rec.inventory_item_id||' and serial number '||mmt_rec.serial_number);
            -- To do a drop shipment first expire the instance
            p_instance_rec.instance_id                := l_exp_instance_id;
            p_instance_rec.object_version_number      := l_exp_obj_ver_num;
            p_instance_rec.active_end_date            := sysdate;

            l_inst_party_id := csi_utl_pkg.get_instance_party_id(l_exp_instance_id);

            IF l_inst_party_id = -1 THEN
              raise fnd_api.g_exc_error;
            END IF;

            p_party_tbl(1).instance_party_id         := l_inst_party_id;
            p_party_tbl(1).instance_id               := l_exp_instance_id;
            -- p_party_tbl(1).party_source_table        := 'HZ_PARTIES';
            p_party_tbl(1).party_id                  := l_party_id;
            p_party_tbl(1).relationship_type_code    := 'OWNER';
            p_party_tbl(1).contact_flag              := 'N';

            BEGIN
              SELECT object_version_number
              INTO   p_party_tbl(1).object_version_number
              FROM   csi_i_parties
              WHERE  instance_party_id = l_inst_party_id;
            END;

            p_party_account_tbl(1).parent_tbl_index  := 1;
            p_party_account_tbl(1).instance_party_id := l_inst_party_id;
            p_party_account_tbl(1).party_account_id  := mmt_rec.end_customer_id; -- mmt_rec.sold_to_org_id;
            p_party_account_tbl(1).relationship_type_code := 'OWNER';
            p_party_account_tbl(1).bill_to_address   := mmt_rec.invoice_to_org_id;
            p_party_account_tbl(1).ship_to_address   := mmt_rec.ship_to_org_id;

            p_txn_rec.transaction_id                 := fnd_api.g_miss_num;
            p_txn_rec.transaction_date               := sysdate;
            p_txn_rec.source_transaction_date        := sysdate;
            p_txn_rec.transaction_type_id            := l_txn_type_id;

            l_trx_rec.transaction_id                 := fnd_api.g_miss_num;

            csi_t_gen_utility_pvt.dump_api_info(
                p_api_name => 'update_item_instance',
                p_pkg_name => 'csi_item_instance_pub');

            csi_item_instance_pub.update_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => p_instance_rec,
              p_ext_attrib_values_tbl => p_ext_attrib_values_tbl,
              p_party_tbl             => p_party_tbl,
              p_account_tbl           => p_party_account_tbl,
              p_pricing_attrib_tbl    => p_pricing_attrib_tbl,
              p_org_assignments_tbl   => p_org_assignments_tbl,
              p_txn_rec               => p_txn_rec,
              p_asset_assignment_tbl  => p_asset_assignment_tbl,
              x_instance_id_lst       => x_instance_id_lst,
              x_return_status         => l_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data );

            IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
              debug('csi_item_instance_pub.expire_item_instance');
              raise fnd_api.g_exc_error;
            END IF;

            BEGIN
              SELECT object_version_number
              INTO   l_exp_instance_rec.object_version_number
              FROM   csi_item_instances
              WHERE  instance_id =  l_exp_instance_id;
            END;

            x_order_shipment_tbl(l_count).instance_id             := l_exp_instance_id;
            x_order_shipment_tbl(l_count).inst_obj_version_number := l_exp_instance_rec.object_version_number;
          END IF;

        ELSE
          x_order_shipment_tbl(l_count).shipped_quantity := l_shipped_qty;
        END IF;


      END LOOP;

      -- Building Transaction Details
      construct_txn_dtls(
        x_order_shipment_tbl => x_order_shipment_tbl,
        p_order_line_rec     => l_order_line_rec,
        p_trackable_parent   => p_trackable_parent,
        x_trx_line_id        => x_trx_line_id,
        x_return_status      => l_return_status );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

    ELSE

      debug('User entered transaction details found');

      -- Check if an instance is refrenced in the source transaction line detail.


    END IF;

    csi_order_fulfill_pub.order_fulfillment(
          p_order_line_id  => l_order_line_rec.order_line_id,
          p_message_id     => null,
          x_return_status  => l_return_status,
          px_trx_error_rec => l_error_rec);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
   END IF;



  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      l_error_rec.source_id := p_mtl_txn_id; -- For Bug 4168922
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      l_error_rec.error_text := l_error_message;
      debug('Error(E) :'||l_error_message);
      px_trx_error_rec := l_error_rec;

    WHEN others THEN
      fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',substr(sqlerrm,1,540));
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;
      l_error_rec.source_id := p_mtl_txn_id; -- For 4168922
      l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      l_error_rec.error_text := l_error_message;
      debug('Error(O) :'||l_error_message);
      px_trx_error_rec := l_error_rec;

  END logical_drop_ship;

  PROCEDURE order_fulfillment(
    p_order_line_id        IN  number,
    p_message_id           IN  number,
    x_return_status        OUT NOCOPY varchar2,
    x_error_message        OUT NOCOPY varchar2)
  IS

    l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_message_id       NUMBER;
    l_error_code       NUMBER;
    l_error_message    VARCHAR2(4000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_ont_txn_pub.PostTransaction(
      p_order_line_id    => p_order_line_id,
      x_message_id       => l_message_id,
      x_error_code       => l_error_code,
      x_return_status    => l_return_status,
      x_error_message    => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END order_fulfillment;

  /* to be used in the fulfillment workflow for the ib interface */
  PROCEDURE fulfill_wf(
    itemtype           IN     VARCHAR2,
    itemkey            IN     VARCHAR2,
    actid              IN     NUMBER,
    funcmode           IN     VARCHAR2,
    resultout          IN OUT NOCOPY VARCHAR2)
  AS

    l_order_line_id    NUMBER;

    l_return_status    VARCHAR2(1);
    l_message_id       NUMBER;
    l_error_code       NUMBER;
    l_error_message    VARCHAR2(4000);

  BEGIN

    IF (funcmode = 'RUN') THEN

      l_order_line_id := TO_NUMBER(itemkey);

      csi_ont_txn_pub.posttransaction(
        p_order_line_id    => l_order_line_id,
        x_return_status    => l_return_status,
        x_message_id       => l_message_id,
        x_error_code       => l_error_code,
        x_error_message    => l_error_message);

      IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
        resultout := 'COMPLETE:N';
        RETURN;
      ELSE
        resultout := 'COMPLETE:Y';
        RETURN;
      END IF;

    END IF; -- End for 'RUN' mode

    --
    -- CANCEL mode - activity 'compensation'
    --
    -- This is an event point is called with the effect of the activity must
    -- be undone, for example when a process is reset to an earlier point
    -- due to a loop back.
    --
    IF (funcmode = 'CANCEL') THEN

      -- your cancel code goes here
      NULL;

      -- no result needed
      resultout := 'COMPLETE';
        RETURN;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      -- The line below records this function call in the error system
      -- in the case of an exception.

      Wf_Core.context('OEOL', 'IB Integration', itemtype, itemkey, TO_CHAR(actid), funcmode);
      RAISE;

  END fulfill_wf;

  PROCEDURE fulfill_old_line(
    p_order_line_id   IN NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_error_message   OUT NOCOPY VARCHAR2)
  IS

    l_message_id      NUMBER;
    l_bypass          VARCHAR2(1);

    l_return_status   VARCHAR2(1);
    l_error_code      VARCHAR2(30);
    l_error_message   VARCHAR2(2000);
    l_error_rec       csi_datastructures_pub.transaction_error_rec;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csi',
      p_file_segment2 => to_char(sysdate, 'DDMMYY'),
      p_file_segment3 => 'invoke');

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_bypass := csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag;

    IF l_bypass = 'Y' THEN

      csi_t_gen_utility_pvt.add('Bypassing the SDP queue for the order line id: '||p_order_line_id);

      csi_inv_txnstub_pkg.execute_trx_dpl(
        p_transaction_type  => 'CSISOFUL',
        p_transaction_id    => p_order_line_id,
        x_trx_return_status => l_return_status,
        x_trx_error_rec     => l_error_rec);

      IF (l_return_status <> fnd_api.g_ret_sts_success) then
        csi_inv_trxs_pkg.log_csi_error(l_error_rec);
      END IF;

    ELSE

      csi_t_gen_utility_pvt.add('Publishing the order line id '||p_order_line_id||' for fulfillment.');

      csi_t_gen_utility_pvt.add('Transaction Type :CSISOFUL');
      csi_t_gen_utility_pvt.add('Transaction ID   :'||p_order_line_id);

      XNP_CSISOFUL_U.publish(
        xnp$order_line_id => p_order_line_id,
        x_message_id      => l_message_id,
        x_error_code      => l_error_code,
        x_error_message   => l_error_message);

      IF (l_error_message is not null) THEN
        x_error_message := l_error_message;
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_error_message := substr(sqlerrm, 1, 255);
  END fulfill_old_line;

  --
  /******************************************************************************
  ** Procedure Name : Process_old_order_lines
  ** Author         : srramakr
  **
  ** This Procedure is to process the Old Fulfillable order Lines created
  ** prior to moving into 11.5.6. The cut-off is check against the Freeze_date in
  ** CSI_INSTALL_PARAMETERS. The lines are read from the ASO Queue and validated.
  ** Once a line is eligible, we call the Fulfillment API which processes the line
  ** and  creates the Item Instance.
  ********************************************************************************/
  --
  PROCEDURE process_old_order_lines (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER)
  IS
    l_return_status   VARCHAR2(1);
    l_msg_count   NUMBER;
    l_msg_data   VARCHAR2(240);
    l_msg_index   NUMBER;
    l_dequeue_mode                    VARCHAR2(240) DEFAULT DBMS_AQ.REMOVE;
    l_navigation                      VARCHAR2(240) DEFAULT DBMS_AQ.NEXT_MESSAGE;
    l_wait    NUMBER    DEFAULT DBMS_AQ.NO_WAIT;
    l_no_more_messages  VARCHAR2(240);
    l_header_rec   OE_Order_PUB.Header_Rec_Type;
    l_old_header_rec   OE_Order_PUB.Header_Rec_Type;
    l_Header_Adj_tbl   OE_Order_PUB.Header_Adj_Tbl_Type;
    l_old_Header_Adj_tbl  OE_Order_PUB.Header_Adj_Tbl_Type;
    l_Header_Price_Att_tbl  OE_Order_PUB.Header_Price_Att_Tbl_Type;
    l_old_Header_Price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl  OE_Order_PUB.Header_Adj_Att_Tbl_Type;
    l_old_Header_Adj_Att_tbl  OE_Order_PUB.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
    l_old_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl  OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_old_Header_Scredit_tbl  OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_line_tbl   OE_Order_PUB.Line_Tbl_Type;
    l_old_line_tbl   OE_Order_PUB.Line_Tbl_Type;
    l_Line_Adj_tbl   OE_Order_PUB.Line_Adj_Tbl_Type;
    l_old_Line_Adj_tbl  OE_Order_PUB.Line_Adj_Tbl_Type;
    l_Line_Price_Att_tbl  OE_Order_PUB.Line_Price_Att_Tbl_Type;
    l_old_Line_Price_Att_tbl  OE_Order_PUB.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl  OE_Order_PUB.Line_Adj_Att_Tbl_Type;
    l_old_Line_Adj_Att_tbl  OE_Order_PUB.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
    l_old_Line_Adj_Assoc_tbl  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl  OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_old_Line_Scredit_tbl  OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_Lot_Serial_tbl   OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_old_Lot_Serial_tbl  OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_action_request_tbl  OE_Order_PUB.request_tbl_type;
    --
    l_exp_line_tbl   OE_Order_PUB.Line_Tbl_Type;
    l_exp_old_line_tbl         OE_Order_PUB.Line_Tbl_Type;
    l_exp_count                       NUMBER;
    l_exp_flag                        VARCHAR2(1);
    l_line_count                      NUMBER;
    l_multi_org_flag                  VARCHAR2(1);
    l_organization_id                 NUMBER;
    l_order_line_id                   VARCHAR2(240);
    l_process_profile                 VARCHAR2(1);
    l_freeze_date                     DATE;
    l_error_message                   VARCHAR2(2000);
    v_commit_counter                  NUMBER := 0;
    v_exists                          VARCHAR2(1);
    --
    Process_Next                      EXCEPTION;
    ASO_HANDLE_NORMAL                 EXCEPTION;
    ASO_HANDLE_EXCEPTION              EXCEPTION;
  BEGIN
    SAVEPOINT PROCESS_OLD_ORDER_LINES;
    --
    l_process_profile := fnd_profile.value('CSI_PROCESS_FULFILL_LINES');
    --
    if l_process_profile is null then
      fnd_file.put_line(fnd_file.log,'Profile CSI_PROCESS_FULFILL_LINES is not set');
      retcode := 2;
      RETURN;
    end if;
    --
    if l_process_profile = 'N' then
      fnd_file.put_line(fnd_file.log,'No more lines to be processed...');
      RETURN;
    end if;
    --
    -- Get the Date from CSI_INSTALL_PARAMETERS

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;

    --
    -- Get the Multi-org Flag.
    l_multi_org_flag := 'X';
    Begin
      select multi_org_flag
      into l_multi_org_flag
      from FND_PRODUCT_GROUPS;
    Exception
      when others then
        null;
    End;
    fnd_file.put_line(fnd_file.log, 'Multi Org Flag is '||l_multi_org_flag);
    --
    fnd_file.put_line(fnd_file.log,'Processing Regular Queue..');
    WHILE(TRUE)
    LOOP
      BEGIN
        l_line_count  := 0;
        ASO_ORDER_FEEDBACK_PUB.GET_NOTICE (
          p_api_version                  => 1.0,
          p_init_msg_list                => FND_API.G_TRUE,
          p_commit                       => FND_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data,
          p_app_short_name               => 'CS',
          p_wait                         => l_wait,
          x_no_more_messages             => l_no_more_messages,
          x_header_rec                   => l_header_rec,
          x_old_header_rec               => l_old_header_rec,
          x_Header_Adj_tbl               => l_header_adj_tbl,
          x_old_Header_Adj_tbl           => l_old_header_adj_tbl,
          x_Header_price_Att_tbl         => l_header_price_att_tbl,
          x_old_Header_Price_Att_tbl     => l_old_header_price_att_tbl,
          x_Header_Adj_Att_tbl           => l_header_adj_att_tbl,
          x_old_Header_Adj_Att_tbl       => l_old_header_adj_att_tbl,
          x_Header_Adj_Assoc_tbl         => l_header_adj_assoc_tbl,
          x_old_Header_Adj_Assoc_tbl     => l_old_header_adj_assoc_tbl,
          x_Header_Scredit_tbl           => l_header_scredit_tbl,
          x_old_Header_Scredit_tbl       => l_old_header_scredit_tbl,
          x_line_tbl                     => l_line_tbl,
          x_old_line_tbl                 => l_old_line_tbl,
          x_Line_Adj_tbl                 => l_line_adj_tbl,
          x_old_Line_Adj_tbl             => l_old_line_adj_tbl,
          x_Line_Price_Att_tbl           => l_line_price_att_tbl,
          x_old_Line_Price_Att_tbl       => l_old_line_price_att_tbl,
          x_Line_Adj_Att_tbl             => l_line_adj_att_tbl,
          x_old_Line_Adj_Att_tbl         => l_old_line_adj_att_tbl,
          x_Line_Adj_Assoc_tbl           => l_line_adj_assoc_tbl,
          x_old_Line_Adj_Assoc_tbl       => l_old_line_adj_assoc_tbl,
          x_Line_Scredit_tbl             => l_line_scredit_tbl,
          x_old_Line_Scredit_tbl         => l_old_line_scredit_tbl,
          x_Lot_Serial_tbl               => l_lot_serial_tbl,
          x_old_Lot_Serial_tbl           => l_old_lot_serial_tbl,
          x_action_request_tbl           => l_action_request_tbl);
        --
        IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          retcode := 2;
          fnd_file.put_line(fnd_file.log, 'Finished execution in failing to get queue message.');
          fnd_file.put_line(fnd_file.output, 'Process Old Order Lines Program finished with error. ');
          l_msg_index := 1;
          WHILE l_msg_count > 0
          LOOP
            l_msg_data := FND_MSG_PUB.GET( l_msg_index, FND_API.G_FALSE);
            fnd_file.PUT_LINE(fnd_file.log, 'message data = '||l_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
          END LOOP;
          ROLLBACK TO PROCESS_OLD_ORDER_LINES;
          RETURN;
        END IF;
        --
        EXIT WHEN l_no_more_messages = FND_API.G_TRUE;
        --
        l_line_count := l_line_tbl.count;

        IF l_line_count <= 0 THEN
          fnd_file.put_line(fnd_file.log, 'No line info found for this message.');
        ELSE
          l_exp_count := 0;
          l_exp_flag := 'N';
          l_exp_line_tbl.delete;
          l_exp_old_line_tbl.delete;
          --
          FOR l_count IN 1..l_line_count
          Loop
            Begin
              l_order_line_id := to_char(l_line_tbl(l_count).line_id);
              fnd_file.put_line(fnd_file.log, 'Processing order line with id = '||l_order_line_id);
              -- We need to process the order lines which are fulfillable only.
              IF ( (WF_ENGINE.ACTIVITY_EXIST_IN_PROCESS(
                     'OEOL'        -- ITEM_TYPE
                    ,to_char(l_line_tbl(l_count).line_id) -- ITEM_KEY
                    ,'OEOL'        -- ACTIVITY_ITEM_TYPE
                    ,'SHIP_LINE'   -- ACTIVITY
                    )) OR -- fix for Bug 2818157
                    NVL(l_line_tbl(l_count).shippable_flag,'N') = 'Y') THEN
                fnd_file.put_line(fnd_file.log,'This Line has Shipping Node. Ignoring this line...');
                Raise Process_Next;
              END IF;
              -- Check Fulfillment Event
              IF ((l_line_tbl(l_count).fulfilled_quantity > 0) AND
                 (NVL(l_line_tbl(l_count).fulfilled_quantity,-1) <>
                 NVL(l_old_line_tbl(l_count).fulfilled_quantity ,-1))) THEN
                --
                -- Check whether the line creation date is <= CSI Install Parameters Freeze date
                IF l_line_tbl(l_count).creation_date > l_freeze_date OR
                   l_line_tbl(l_count).fulfillment_date < l_freeze_date THEN
                  fnd_file.put_line(fnd_file.log,'Line creation date is after moving to 11.5.6. Ignoring this Line...');
                  Raise Process_Next;
                END IF;
                --
                -- Get the Master Organization corresponding to the Order Line ORG ID.
                l_organization_id := null;
                IF l_multi_org_flag = 'Y' then
                  Begin

                    l_organization_id :=
                      oe_sys_parameters.value(
                        param_name => 'MASTER_ORGANIZATION_ID',
                        p_org_id   => l_line_tbl(l_count).org_id);

                    select mp.master_organization_id
                    into l_organization_id
                    from MTL_PARAMETERS mp
                    where mp.organization_id = l_organization_id;

                  Exception
                    when others then
                      fnd_file.put_line(fnd_file.log,'Unable to get Master Organization for ORG ID '
                      ||to_char(l_line_tbl(l_count).org_id));
                      l_exp_count := l_exp_count + 1;
                      l_exp_flag := 'Y';
                      l_exp_line_tbl(l_exp_count) := l_line_tbl(l_count);
                      l_exp_old_line_tbl(l_exp_count) := l_old_line_tbl(l_count);
                      Raise Process_Next;
                  End;
                ELSE -- Non Multi-Org
                  Begin
                    l_organization_id :=
                      oe_sys_parameters.value(
                        param_name => 'MASTER_ORGANIZATION_ID',
                        p_org_id   => l_line_tbl(l_count).org_id);

                    select mp.master_organization_id
                    into l_organization_id
                    from MTL_PARAMETERS mp
                    where mp.organization_id = l_organization_id;
                  Exception
                    when others then
                      fnd_file.put_line(fnd_file.log,'Unable to get Master Organization for ORG ID ');
                      l_exp_count := l_exp_count + 1;
                      l_exp_flag := 'Y';
                      l_exp_line_tbl(l_exp_count) := l_line_tbl(l_count);
                      l_exp_old_line_tbl(l_exp_count) := l_old_line_tbl(l_count);
                      Raise Process_Next;
                  End;
                END IF;
                -- If Master Organization ID is NULL add the line to the Exception queue.
                IF l_organization_id is null THEN
                  fnd_file.put_line(fnd_file.log,'Master organization is NULL for this Order Line');
                  l_exp_count := l_exp_count + 1;
                  l_exp_flag := 'Y';
                  l_exp_line_tbl(l_exp_count) := l_line_tbl(l_count);
                  l_exp_old_line_tbl(l_exp_count) := l_old_line_tbl(l_count);
                  Raise Process_Next;
                END IF;
                -- Check if the item is NL Trackable or not
                IF NOT (csi_item_instance_vld_pvt.is_trackable(
                   p_inv_item_id => l_line_tbl(l_count).inventory_item_id,
                   p_org_id      => l_organization_id))
                THEN
                  fnd_file.put_line(fnd_file.log,'This Item is not NL Trackable. Ignoring this Line.');
                  Raise Process_Next;
                END IF;
                --
                -- All the above conditions are met and the line is eligible for processing.
                fnd_file.put_line(fnd_file.log, 'This line has been fulfilled. Processing this line...');
                fulfill_old_line(
                  p_order_line_id   => l_line_tbl(l_count).line_id,
                  x_return_status   => l_return_status,
                  x_error_message   => l_error_message);
                IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  fnd_file.put_line(fnd_file.log,'Error while creating the Instance '
                  ||'----'||l_error_message);
                  fnd_file.put_line(fnd_file.log,'Please Use the Transaction Re-processing FORM to re-process this line..');
                  Raise Process_Next;
                ELSE
                  fnd_file.put_line(fnd_file.log,'Fulfillment API returned Success...');
                END IF;
              ELSE
                fnd_file.put_line(fnd_file.log, 'This line has not yet been fulfilled. Ignoring this line');
              END IF;
            Exception
              When Process_Next then
                null;
            End;
          End Loop;
          --
          IF l_exp_flag = 'Y' THEN
            Raise ASO_HANDLE_NORMAL;
          END IF;
        END IF;
      EXCEPTION
        When ASO_HANDLE_NORMAL then
          fnd_file.put_line(fnd_file.log, 'adding message to exception queue...');
          ASO_ORDER_FEEDBACk_PUB.HANDLE_EXCEPTION(
            p_api_version   => 1.0,
            p_init_msg_list   => FND_API.G_FALSE,
            p_commit    => FND_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count   => l_msg_count,
            x_msg_data   => l_msg_data,
            p_app_short_name   => 'CS',
            p_header_rec   => l_header_rec,
            p_old_header_rec   => l_old_header_rec,
            p_header_adj_tbl   => l_header_adj_tbl,
            p_old_header_adj_tbl  => l_old_header_adj_tbl,
            p_header_price_att_tbl  => l_header_price_att_tbl,
            p_old_header_price_att_tbl => l_old_header_price_att_tbl,
            p_Header_Adj_Att_tbl  => l_Header_Adj_Att_tbl,
            p_old_Header_Adj_Att_tbl  => l_old_Header_Adj_Att_tbl,
            p_Header_Adj_Assoc_tbl  => l_Header_Adj_Assoc_tbl,
            p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl,
            p_Header_Scredit_tbl  => l_Header_Scredit_tbl,
            p_old_Header_Scredit_tbl  => l_old_Header_Scredit_tbl,
            p_line_tbl   => l_exp_line_tbl,
            p_old_line_tbl   => l_exp_old_line_tbl,
            p_Line_Adj_tbl   => l_Line_Adj_tbl,
            p_old_Line_Adj_tbl  => l_old_Line_Adj_tbl,
            p_Line_Price_Att_tbl  => l_Line_Price_Att_tbl,
            p_old_Line_Price_Att_tbl  => l_old_Line_Price_Att_tbl,
            p_Line_Adj_Att_tbl  => l_Line_Adj_Att_tbl,
            p_old_Line_Adj_Att_tbl  => l_old_Line_Adj_Att_tbl,
            p_Line_Adj_Assoc_tbl  => l_Line_Adj_Assoc_tbl,
            p_old_Line_Adj_Assoc_tbl  => l_old_Line_Adj_Assoc_tbl,
            p_Line_Scredit_tbl  => l_Line_Scredit_tbl,
            p_old_Line_Scredit_tbl  => l_old_Line_Scredit_tbl,
            p_Lot_Serial_tbl   => l_Lot_Serial_tbl,
            p_old_Lot_Serial_tbl  => l_old_Lot_Serial_tbl,
            p_action_request_tbl  => l_action_request_tbl);
      END;
      COMMIT;
      fnd_file.put_line(fnd_file.log, 'Finished processing one message in the Order Queue');
      FND_MSG_PUB.initialize;   -- reinit the error messages
    END LOOP;
    -- End of Processing Regular Queue
    fnd_file.put_line(fnd_file.log,'End of Regular Queue Processing ...');
    fnd_file.put_line(fnd_file.log,'Processing Exception Queue..');
    WHILE(TRUE)
     LOOP
       BEGIN
         l_line_count  := 0;
         ASO_ORDER_FEEDBACK_PUB.GET_EXCEPTION (
           p_api_version                  => 1.0,
           p_init_msg_list                => FND_API.G_TRUE,
           p_commit                       => FND_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => l_msg_count,
           x_msg_data                     => l_msg_data,
           p_app_short_name               => 'CS',
           p_wait                         => l_wait,
           p_dequeue_mode                 => l_dequeue_mode,
           p_navigation                   => l_navigation,
           x_no_more_messages             => l_no_more_messages,
           x_header_rec                   => l_header_rec,
           x_old_header_rec               => l_old_header_rec,
           x_Header_Adj_tbl               => l_header_adj_tbl,
           x_old_Header_Adj_tbl           => l_old_header_adj_tbl,
           x_Header_price_Att_tbl         => l_header_price_att_tbl,
           x_old_Header_Price_Att_tbl     => l_old_header_price_att_tbl,
           x_Header_Adj_Att_tbl           => l_header_adj_att_tbl,
           x_old_Header_Adj_Att_tbl       => l_old_header_adj_att_tbl,
           x_Header_Adj_Assoc_tbl         => l_header_adj_assoc_tbl,
           x_old_Header_Adj_Assoc_tbl     => l_old_header_adj_assoc_tbl,
           x_Header_Scredit_tbl           => l_header_scredit_tbl,
           x_old_Header_Scredit_tbl       => l_old_header_scredit_tbl,
           x_line_tbl                     => l_line_tbl,
           x_old_line_tbl                 => l_old_line_tbl,
           x_Line_Adj_tbl                 => l_line_adj_tbl,
           x_old_Line_Adj_tbl             => l_old_line_adj_tbl,
           x_Line_Price_Att_tbl           => l_line_price_att_tbl,
           x_old_Line_Price_Att_tbl       => l_old_line_price_att_tbl,
           x_Line_Adj_Att_tbl             => l_line_adj_att_tbl,
           x_old_Line_Adj_Att_tbl         => l_old_line_adj_att_tbl,
           x_Line_Adj_Assoc_tbl           => l_line_adj_assoc_tbl,
           x_old_Line_Adj_Assoc_tbl       => l_old_line_adj_assoc_tbl,
           x_Line_Scredit_tbl             => l_line_scredit_tbl,
           x_old_Line_Scredit_tbl         => l_old_line_scredit_tbl,
           x_Lot_Serial_tbl               => l_lot_serial_tbl,
           x_old_Lot_Serial_tbl           => l_old_lot_serial_tbl,
           x_action_request_tbl           => l_action_request_tbl);
         --
         IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           retcode := 2;
           fnd_file.put_line(fnd_file.log, 'Finished execution in failing to get Exception queue message.');
           fnd_file.put_line(fnd_file.output, 'Process Old Order Lines Program finished with error. ');
           l_msg_index := 1;
           WHILE l_msg_count > 0
           LOOP
             l_msg_data := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
             fnd_file.PUT_LINE(fnd_file.log, 'message data = '||l_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
           END LOOP;
           ROLLBACK TO PROCESS_OLD_ORDER_LINES;
           RETURN;
         END IF;
         --
         EXIT WHEN l_no_more_messages = FND_API.G_TRUE;
         --
         l_line_count := l_line_tbl.count;

         IF l_line_count <= 0 THEN
           fnd_file.put_line(fnd_file.log, 'No line info found for this message.');
         ELSE
           l_exp_count := 0;
           l_exp_flag := 'N';
           l_exp_line_tbl.delete;
           l_exp_old_line_tbl.delete;
           --
           FOR l_count IN 1..l_line_count
           Loop
             Begin
               l_order_line_id := to_char(l_line_tbl(l_count).line_id);
               fnd_file.put_line(fnd_file.log, 'Processing order line with id = '||l_order_line_id);
               -- We need to process the order lines which are fulfillable only.
               IF ( (WF_ENGINE.ACTIVITY_EXIST_IN_PROCESS(
                     'OEOL'        -- ITEM_TYPE
                     ,to_char(l_line_tbl(l_count).line_id) -- ITEM_KEY
                     ,'OEOL'        -- ACTIVITY_ITEM_TYPE
                     ,'SHIP_LINE'   -- ACTIVITY
                     )) AND
                       NVL(l_line_tbl(l_count).shippable_flag,'N') = 'Y') THEN
                 fnd_file.put_line(fnd_file.log,'This Line has Shipping Node. Ignoring this line...');
                 Raise Process_Next;
               END IF;
               -- Check Fulfillment Event
               IF ((l_line_tbl(l_count).fulfilled_quantity > 0) AND
                  (NVL(l_line_tbl(l_count).fulfilled_quantity,-1) <>
                  NVL(l_old_line_tbl(l_count).fulfilled_quantity ,-1))) THEN
                 --
                 -- Check whether the line creation date is <= CSI Install Parameters Freeze date
                 IF l_line_tbl(l_count).creation_date > l_freeze_date THEN
                   fnd_file.put_line(fnd_file.log,'Line creation date is after moving to 11.5.6. Ignoring this Line..');
                   Raise Process_Next;
                 END IF;
                 --
                 -- Get the Master Organization corresponding to the Order Line ORG ID.
                 l_organization_id := null;
                 IF l_multi_org_flag = 'Y' then
                   Begin
                    l_organization_id :=
                      oe_sys_parameters.value(
                        param_name => 'MASTER_ORGANIZATION_ID',
                        p_org_id   => l_line_tbl(l_count).org_id);

                    select mp.master_organization_id
                    into l_organization_id
                    from MTL_PARAMETERS mp
                    where mp.organization_id = l_organization_id;
                   Exception
                     when others then
                       fnd_file.put_line(fnd_file.log,'Unable to get Master Organization for ORG ID '
                       ||to_char(l_line_tbl(l_count).org_id));
                       l_exp_count := l_exp_count + 1;
                       l_exp_flag := 'Y';
                       l_exp_line_tbl(l_exp_count) := l_line_tbl(l_count);
                       l_exp_old_line_tbl(l_exp_count) := l_old_line_tbl(l_count);
                       Raise Process_Next;
                   End;
                 ELSE -- Non Multi-Org
                   Begin
                    l_organization_id :=
                      oe_sys_parameters.value(
                        param_name => 'MASTER_ORGANIZATION_ID',
                        p_org_id   => l_line_tbl(l_count).org_id);

                    select mp.master_organization_id
                    into l_organization_id
                    from MTL_PARAMETERS mp
                    where mp.organization_id = l_organization_id;
                   Exception
                     when others then
                       fnd_file.put_line(fnd_file.log,'Unable to get Master Organization for ORG ID ');
                       l_exp_count := l_exp_count + 1;
                       l_exp_flag := 'Y';
                       l_exp_line_tbl(l_exp_count) := l_line_tbl(l_count);
                       l_exp_old_line_tbl(l_exp_count) := l_old_line_tbl(l_count);
                       Raise Process_Next;
                   End;
                 END IF;
                 -- If Master Organization ID is NULL add the line to the Exception queue.
                 IF l_organization_id is null THEN
                   fnd_file.put_line(fnd_file.log,'Master organization is NULL for this Order Line');
                   l_exp_count := l_exp_count + 1;
                   l_exp_flag := 'Y';
                   l_exp_line_tbl(l_exp_count) := l_line_tbl(l_count);
                   l_exp_old_line_tbl(l_exp_count) := l_old_line_tbl(l_count);
                   Raise Process_Next;
                 END IF;
                 -- Check if the item is NL Trackable or not
                 IF NOT (csi_item_instance_vld_pvt.is_trackable(
                    p_inv_item_id => l_line_tbl(l_count).inventory_item_id,
                    p_org_id      => l_organization_id)) THEN
                   fnd_file.put_line(fnd_file.log,'This Line is not NL Trackable. Ignoring this Line.');
                   Raise Process_Next;
                 END IF;
                 --
                 -- All the above conditions are met and the line is eligible for processing.
                 fnd_file.put_line(fnd_file.log,'This line has been fulfilled. Processing this line..');
                 fulfill_old_line(
                   p_order_line_id   => l_line_tbl(l_count).line_id,
                   x_return_status   => l_return_status,
                   x_error_message   => l_error_message);
                 IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   fnd_file.put_line(fnd_file.log,'Error while creating the Instance '
                   ||'----'||l_error_message);
                   fnd_file.put_line(fnd_file.log,'Please Use the Transaction Re-processing FORM to re-process this line..');
                   Raise Process_Next;
                 ELSE
                   fnd_file.put_line(fnd_file.log,'Fulfillment API returned Success...');
                 END IF;
               ELSE
                 fnd_file.put_line(fnd_file.log, 'This line has not yet been fulfilled. Ignoring this line');
               END IF;
             Exception
               When Process_Next then
                 null;
             End;
           End Loop;
           --
           IF l_exp_flag = 'Y' THEN
             Raise ASO_HANDLE_EXCEPTION;
           END IF;
        END IF;
      EXCEPTION
        When ASO_HANDLE_EXCEPTION then
          fnd_file.put_line(fnd_file.log, 'Adding message to exception queue again ...');
          ASO_ORDER_FEEDBACk_PUB.HANDLE_EXCEPTION (
            p_api_version   => 1.0,
            p_init_msg_list   => FND_API.G_FALSE,
            p_commit    => FND_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count   => l_msg_count,
            x_msg_data   => l_msg_data,
            p_app_short_name   => 'CS',
            p_header_rec   => l_header_rec,
            p_old_header_rec   => l_old_header_rec,
            p_header_adj_tbl   => l_header_adj_tbl,
            p_old_header_adj_tbl  => l_old_header_adj_tbl,
            p_header_price_att_tbl  => l_header_price_att_tbl,
            p_old_header_price_att_tbl => l_old_header_price_att_tbl,
            p_Header_Adj_Att_tbl  => l_Header_Adj_Att_tbl,
            p_old_Header_Adj_Att_tbl  => l_old_Header_Adj_Att_tbl,
            p_Header_Adj_Assoc_tbl  => l_Header_Adj_Assoc_tbl,
            p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl,
            p_Header_Scredit_tbl  => l_Header_Scredit_tbl,
            p_old_Header_Scredit_tbl  => l_old_Header_Scredit_tbl,
            p_line_tbl   => l_exp_line_tbl,
            p_old_line_tbl   => l_exp_old_line_tbl,
            p_Line_Adj_tbl   => l_Line_Adj_tbl,
            p_old_Line_Adj_tbl  => l_old_Line_Adj_tbl,
            p_Line_Price_Att_tbl  => l_Line_Price_Att_tbl,
            p_old_Line_Price_Att_tbl  => l_old_Line_Price_Att_tbl,
            p_Line_Adj_Att_tbl  => l_Line_Adj_Att_tbl,
            p_old_Line_Adj_Att_tbl  => l_old_Line_Adj_Att_tbl,
            p_Line_Adj_Assoc_tbl  => l_Line_Adj_Assoc_tbl,
            p_old_Line_Adj_Assoc_tbl  => l_old_Line_Adj_Assoc_tbl,
            p_Line_Scredit_tbl  => l_Line_Scredit_tbl,
            p_old_Line_Scredit_tbl  => l_old_Line_Scredit_tbl,
            p_Lot_Serial_tbl   => l_Lot_Serial_tbl,
            p_old_Lot_Serial_tbl  => l_old_Lot_Serial_tbl,
            p_action_request_tbl  => l_action_request_tbl);
      END;
      COMMIT;
      fnd_file.put_line(fnd_file.log, 'Finished processing one message in the Order Exception Queue');
      FND_MSG_PUB.initialize;   -- reinit the error messages
    END LOOP;
    fnd_file.put_line(fnd_file.log,'End of Exception Queue Processing ...');
  END Process_old_order_Lines;

  --
  /************************************************************************************
  ** Procedure Name : Update_Profile
  ** Author         : srramakr
  **
  ** This Procedure is to update the Profile CSI_PROCESS_FULFILL_LINES to N, so that
  ** the Process Old Fulfill Order Lines program does not get executed.
  ** It basically checks for fulfillable lines created prior to moving into 11.5.6
  ** and not yet fulfilled and still remain open.
  ** If the none of the order lines fall in the above category, it updates the profile
  ** to N.
  **************************************************************************************/
  --
  PROCEDURE Update_profile (
    errbuf OUT NOCOPY VARCHAR2,
   retcode OUT NOCOPY NUMBER)
  IS
    CURSOR OE_LINE_CUR(p_freeze_date DATE) IS
      SELECT line_id,inventory_item_id,org_id,shippable_flag
      FROM OE_ORDER_LINES_ALL
      WHERE  creation_date <= p_freeze_date
      AND    nvl(fulfilled_flag,'N') <> 'Y'
      AND    open_flag = 'Y';
    --
    l_freeze_date              DATE;
    l_organization_id          NUMBER;
    l_multi_org_flag           VARCHAR2(1);
    v_ret_counter              NUMBER := 0;
    l_profile_option_id        NUMBER;
    --
    Process_Next               EXCEPTION;
  BEGIN
    -- Get the Profile Option ID
    Begin
      select profile_option_id
      into l_profile_option_id
      from   FND_PROFILE_OPTIONS
      where  upper(profile_option_name) = 'CSI_PROCESS_FULFILL_LINES';
    Exception
      when no_data_found then
        fnd_file.put_line(fnd_file.log,'Unable to find the Profile Option CSI_PROCESS_FULFILL_LINES');
        retcode := 2;
        RETURN;
    End;

    -- Get the Date from CSI_INSTALL_PARAMETERS
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_freeze_date := csi_datastructures_pub.g_install_param_rec.freeze_date;

    --
    l_multi_org_flag := 'X';
    Begin
      select multi_org_flag
      into l_multi_org_flag
      from FND_PRODUCT_GROUPS;
    Exception
      when others then
        null;
    End;
    --
    fnd_file.put_line(fnd_file.log, 'Multi Org Flag is '||l_multi_org_flag);
    --
    For v_rec in OE_LINE_CUR(l_freeze_date)
    Loop
      Begin
        v_ret_counter := 0;
        if ( (WF_ENGINE.ACTIVITY_EXIST_IN_PROCESS(
           'OEOL'                   -- ITEM_TYPE
          ,to_char(v_rec.line_id)  -- ITEM_KEY
          ,'OEOL'                  -- ACTIVITY_ITEM_TYPE
          ,'SHIP_LINE'             -- ACTIVITY
         )) and
          nvl(v_rec.shippable_flag,'N') = 'Y' ) then
          Raise Process_Next;
        end if;
        --
        -- Get the Master Organization corresponding to the Order Line ORG ID.
        IF l_multi_org_flag = 'Y' then
          Begin
            l_organization_id :=
              oe_sys_parameters.value(
              param_name => 'MASTER_ORGANIZATION_ID',
              p_org_id   => v_rec.org_id);

            select mp.master_organization_id
            into l_organization_id
            from MTL_PARAMETERS mp
            where mp.organization_id = l_organization_id;
          Exception
            when others then
              fnd_file.put_line(fnd_file.log,'Unable to get Master Organization for ORG ID '
                ||to_char(v_rec.org_id));
              Raise Process_Next;
          End;
        ELSE -- Non Multi-Org
          Begin
            l_organization_id :=
              oe_sys_parameters.value(
              param_name => 'MASTER_ORGANIZATION_ID',
              p_org_id   => v_rec.org_id);

            select mp.master_organization_id
            into l_organization_id
            from MTL_PARAMETERS mp
            where mp.organization_id = l_organization_id;
          Exception
            when others then
              fnd_file.put_line(fnd_file.log,'Unable to get Master Organization for ORG ID ');
              Raise Process_Next;
          End;
        END IF;
        -- Check if the item is NL Trackable or not
        IF NOT (csi_item_instance_vld_pvt.is_trackable(
          p_inv_item_id => v_rec.inventory_item_id,
          p_org_id      => l_organization_id)) THEN
          Raise Process_Next;
        END IF;
        v_ret_counter := 1;
        fnd_file.put_line(fnd_file.log,'There are still open fulfillable lines...');
        exit;
      Exception
        when Process_Next then
          null;
      End;
    End Loop;
    if v_ret_counter = 0 then
      fnd_file.put_line(fnd_file.log,'All Old Fulfillable lines have been Processed. Updating the Profile');
      -- update the profile
      UPDATE fnd_profile_option_values
      SET    profile_option_value = 'N'
      WHERE  profile_option_id = l_profile_option_id
      AND    application_id=542 --fix for the bug 4907945
      AND    level_id = 10001;
      commit;
    end if;
  END Update_Profile;

END csi_order_fulfill_pub;

/
