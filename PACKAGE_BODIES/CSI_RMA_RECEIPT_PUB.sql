--------------------------------------------------------
--  DDL for Package Body CSI_RMA_RECEIPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_RMA_RECEIPT_PUB" AS
/* $Header: csipirmb.pls 120.12.12010000.2 2009/06/03 12:35:58 ngoutam ship $*/

  /* local debug procedure */
  PROCEDURE debug(
    p_message          IN  varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  /* local api log procedure */
  PROCEDURE api_log(
    p_api_name         IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => p_api_name,
      p_pkg_name => 'csi_rma_receipt_pub');
  END api_log;


  /* local debug dump routines */
  PROCEDURE dump_item_control_rec(
    p_item_control_rec IN item_control_rec)
  IS
    l_rec              item_control_rec;
  BEGIN

    l_rec := p_item_control_rec;

    debug('Dumping values for item_control_rec:');

    debug('  inventory_item_id        : '||l_rec.inventory_item_id);
    debug('  organization_id          : '||l_rec.organization_id);
    debug('  primary_uom_code         : '||l_rec.primary_uom_code);
    debug('  serial_control_code      : '||l_rec.serial_control_code);
    debug('  lot_control_code         : '||l_rec.lot_control_code);
    debug('  rev_control_code         : '||l_rec.revision_control_code);
    debug('  bom_item_type            : '||l_rec.bom_item_type);

  END dump_item_control_rec;

  /* local debug dump routines */
  PROCEDURE dump_mtl_txn_rec(
    p_mtl_txn_rec      IN mtl_txn_rec)
  IS
    l_rec              mtl_txn_rec;
  BEGIN
    l_rec := p_mtl_txn_rec;
    debug('Dumping values for mtl_transaction_recs:');
    debug('  transaction_id           : '||l_rec.transaction_id);
    debug('  transaction_type_id      : '||l_rec.transaction_type_id);
    debug('  oe_line_id               : '||l_rec.oe_line_id);
    debug('  inventory_item_id        : '||l_rec.inventory_item_id);
    debug('  item_revision            : '||l_rec.revision);
    debug('  organization_id          : '||l_rec.organization_id);
    debug('  subinventory             : '||l_rec.subinventory_code);
    debug('  locator_id               : '||l_rec.locator_id);
    debug('  mmt_primary_quantity     : '||l_rec.mmt_primary_quantity);
    debug('  serial_number            : '||l_rec.serial_number);
    debug('  lot_number               : '||l_rec.lot_number);
    debug('  lot_primary_quantity     : '||l_rec.lot_primary_quantity);
    debug('  instance_quantity        : '||l_rec.instance_quantity);
  END dump_mtl_txn_rec;

  /* local debug dump routines */
  PROCEDURE dump_txn_status_tbl(
    p_mtl_txn_tbl    IN mtl_txn_tbl)
  IS
   l_tbl             mtl_txn_tbl;
  BEGIN
    l_tbl := p_mtl_txn_tbl;
    IF l_tbl.COUNT > 0 THEN
      debug('ITEM    REV  LOT          SERIAL          SUBINV          LOC    INST    QTY     V P');
      debug('------- ---- ------------ --------------- --------------- ------ ------- ------- - -');
      FOR l_ind IN l_tbl.FIRST .. l_tbl.LAST
      LOOP
        debug(rpad(nvl(to_char(l_tbl(l_ind).inventory_item_id), ' '), 8,' ') ||
              rpad(nvl(l_tbl(l_ind).revision, ' '), 5, ' ') ||
              rpad(nvl(l_tbl(l_ind).lot_number, ' '), 13, ' ') ||
              rpad(nvl(l_tbl(l_ind).serial_number, ' '), 16, ' ') ||
              rpad(nvl(l_tbl(l_ind).subinventory_code, ' '), 16, ' ') ||
              rpad(nvl(to_char(l_tbl(l_ind).locator_id), ' '), 7, ' ') ||
              rpad(nvl(to_char(l_tbl(l_ind).instance_id),' '), 8, ' ') ||
              rpad(nvl(to_char(l_tbl(l_ind).instance_quantity), ' '), 8, ' ') ||
              rpad(nvl(l_tbl(l_ind).verified_flag, ' '), 2, ' ') ||
              rpad(nvl(l_tbl(l_ind).processed_flag, ' '), 2, ' ') );
      END LOOP;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END dump_txn_status_tbl;

  /* local debug dump routines */
  PROCEDURE dump_mtl_txn_tbl(
    p_mtl_txn_tbl    IN mtl_txn_tbl)
  IS
  BEGIN
    IF p_mtl_txn_tbl.COUNT > 0 THEN
      FOR l_ind IN p_mtl_txn_tbl.FIRST .. p_mtl_txn_tbl.LAST
      LOOP
        dump_mtl_txn_rec(p_mtl_txn_tbl(l_ind));
      END LOOP;
    END IF;
  END dump_mtl_txn_tbl;

  PROCEDURE get_instance_pa_dtls(
    p_transaction_type_id IN number,
    p_sub_type_id         IN number,
    px_inst_pa_rec        IN OUT NOCOPY inst_pa_rec,
    x_sub_type_rec        OUT NOCOPY csi_txn_sub_types%rowtype,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_return_status      varchar2(1)    := fnd_api.g_ret_sts_success;
  BEGIN
      api_log('get_instance_pa_dtls');
      x_return_status := fnd_api.g_ret_sts_success;
      BEGIN
            SELECT party_id ,
                   instance_party_id,
                   object_version_number
            INTO   px_inst_pa_rec.party_id,
                   px_inst_pa_rec.instance_party_id,
                   px_inst_pa_rec.pty_obj_version
            FROM   csi_i_parties
            WHERE  instance_id            = px_inst_pa_rec.instance_id
            AND    relationship_type_code = 'OWNER'
            AND    sysdate between nvl(active_end_date,sysdate) and sysdate+1 ;
            px_inst_pa_rec.party_rltnshp_code := 'OWNER';
            --## brmanesh leased out internal item may not have a owner account
            --## code enhancement required here
            -- Added Begin , Exception and End as part of fix for Bug 2733128
              SELECT party_account_id,
                     ip_account_id,
                     object_version_number
              INTO   px_inst_pa_rec.account_id,
                     px_inst_pa_rec.ip_account_id,
                     px_inst_pa_rec.acct_obj_version
              FROM   csi_ip_accounts
              WHERE  instance_party_id      = px_inst_pa_rec.instance_party_id
              AND    relationship_type_code = 'OWNER';
              px_inst_pa_rec.acct_rltnshp_code := 'OWNER';
      EXCEPTION
          WHEN no_data_found THEN
           --## to seed some error message appropriately
             l_return_status := fnd_api.g_ret_sts_error;
             RAISE fnd_api.g_exc_error;
      END;

      get_sub_type_rec(
         p_transaction_type_id => p_transaction_type_id,
         p_sub_type_id         => p_sub_type_id,
         x_sub_type_rec        => x_sub_type_rec,
         x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         raise fnd_api.g_exc_error;
      END IF;

         debug('  Instance ID              : '||px_inst_pa_rec.instance_id);
         debug('  Internal Party ID        : '||px_inst_pa_rec.internal_party_id);
         debug('  Current Party ID         : '||px_inst_pa_rec.party_id);
         debug('  Current Party Account ID : '||px_inst_pa_rec.account_id);
         debug('  RMA Party ID             : '||px_inst_pa_rec.src_txn_party_id );
         debug('  RMA Party Account ID     : '||px_inst_pa_rec.src_txn_acct_id );
         debug('  Party override Flag      : '||px_inst_pa_rec.ownership_ovr_flag);

      IF px_inst_pa_rec.party_id <> px_inst_pa_rec.internal_party_id
          AND
         px_inst_pa_rec.party_id <> px_inst_pa_rec.src_txn_party_id
          AND
         px_inst_pa_rec.ownership_ovr_flag = 'N' THEN

           fnd_message.set_name('CSI','CSI_RMA_OWNER_MISMATCH'); -- need to seed a new message
           fnd_message.set_token('INSTANCE_ID', px_inst_pa_rec.instance_id );
           fnd_message.set_token('OLD_PARTY_ID', px_inst_pa_rec.party_id );
           fnd_message.set_token('NEW_PARTY_ID', px_inst_pa_rec.src_txn_party_id );
           fnd_msg_pub.add;
           l_return_status := fnd_api.g_ret_sts_error;
           RAISE fnd_api.g_exc_error;
      END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := l_return_status;
  END get_instance_pa_dtls;

  PROCEDURE get_dflt_sub_type_id(
    p_transaction_type_id IN  number,
    x_sub_type_id         OUT NOCOPY number,
    x_return_status       OUT NOCOPY varchar2)
  IS
  BEGIN

    api_log('get_dflt_sub_type_id');

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT sub_type_id
    INTO   x_sub_type_id
    FROM   csi_source_ib_types -- SQL repository changes.
    WHERE  transaction_type_id = p_transaction_type_id
    AND    default_flag        = 'Y';

    debug('  Dflt Sub Type ID :'||x_sub_type_id);

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI', 'CSI_DFLT_SUB_TYPE_MISSING');
      fnd_message.set_token('TXN_TYPE_ID', p_transaction_type_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI', 'CSI_MANY_DFLT_SUB_TYPES');
      fnd_message.set_token('TXN_TYPE_ID', p_transaction_type_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

  END get_dflt_sub_type_id;


  PROCEDURE get_sub_type_rec(
    p_transaction_type_id IN  number,
    p_sub_type_id         IN  number,
    x_sub_type_rec        OUT NOCOPY csi_txn_sub_types%rowtype,
    x_return_status       OUT NOCOPY varchar2)
  IS
  BEGIN

    api_log('get_sub_type_rec');

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT *
    INTO   x_sub_type_rec
    FROM   csi_txn_sub_types
    WHERE  transaction_type_id = p_transaction_type_id
    AND    sub_type_id         = p_sub_type_id;

    debug('  transaction_type_id :'||x_sub_type_rec.transaction_type_id);
    debug('  sub_type_id         :'||x_sub_type_rec.sub_type_id);
    debug('  name                :'||x_sub_type_rec.name);
    debug('  description         :'||x_sub_type_rec.description);
    debug('  src_reference_reqd  :'||x_sub_type_rec.src_reference_reqd);
    debug('  src_change_owner    :'||x_sub_type_rec.src_change_owner);
    debug('  src_owner_to_code   :'||x_sub_type_rec.src_change_owner_to_code);
    debug('  src_return_reqd     :'||x_sub_type_rec.src_return_reqd);

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI', 'CSI_INT_SUB_TYPE_REC_MISSING');
      fnd_message.set_token('SUB_TYPE_ID', p_sub_type_id);
      fnd_message.set_token('TRANSACTION_TYPE_ID', p_transaction_type_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_sub_type_rec;

  PROCEDURE get_item_control_rec(
    p_mtl_txn_id        IN  number,
    x_item_control_rec  OUT NOCOPY item_control_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_item_control_rec  item_control_rec;
    l_tmp_id1        number;

  BEGIN

    api_log('get_item_control_rec');
    x_return_status := fnd_api.g_ret_sts_success;
    BEGIN

      SELECT inventory_item_id,
             organization_id
      INTO   l_item_control_rec.inventory_item_id,
             l_item_control_rec.organization_id
      FROM   mtl_material_transactions
      WHERE  transaction_id = p_mtl_txn_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_NO_INVENTORY_RECORDS');
        fnd_message.set_token('MTL_TRANSACTION_ID',p_mtl_txn_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    BEGIN
      SELECT serial_number_control_code,
             lot_control_code,
             revision_qty_control_code,
             bom_item_type,
             primary_uom_code,
             base_item_id,
             pick_components_flag
      INTO   l_item_control_rec.serial_control_code,
             l_item_control_rec.lot_control_code,
             l_item_control_rec.revision_control_code,
             l_item_control_rec.bom_item_type,
             l_item_control_rec.primary_uom_code,
             l_item_control_rec.model_item_id,
             l_item_control_rec.pick_components_flag
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_item_control_rec.inventory_item_id
      AND    organization_id   = l_item_control_rec.organization_id;
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI', 'CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID', l_item_control_rec.inventory_item_id);
        fnd_message.set_token('INV_ORGANZATION_ID', l_item_control_rec.organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    BEGIN
      SELECT distinct serial_number_control_code
      INTO   l_tmp_id1
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = l_item_control_rec.inventory_item_id;
      l_item_control_rec.mult_srl_control_flag := 'N';
    EXCEPTION
      WHEN too_many_rows THEN
      l_item_control_rec.mult_srl_control_flag := 'Y';
      WHEN no_data_found THEN
        fnd_message.set_name('CSI', 'CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID', l_item_control_rec.inventory_item_id);
        fnd_message.set_token('INV_ORGANZATION_ID', l_item_control_rec.organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    dump_item_control_rec(
      p_item_control_rec => l_item_control_rec);

    x_item_control_rec := l_item_control_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END get_item_control_rec;



  /* new API Added to get the details for Partner Ordering  */
PROCEDURE get_partner_order_info(
      p_mtl_txn_id       in   number,
      x_partner_order_rec OUT  NOCOPY oe_install_base_util.partner_order_rec,
      x_end_cust_party_id OUT NOCOPY number,
      X_return_status     OUT NOCOPY varchar2)
  IS

    l_party_id        number;
    l_account_status  hz_cust_accounts.status%type;
    l_rma_line_id number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_partner_order_info');

    SELECT trx_source_line_id
    INTO   l_rma_line_id
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_mtl_txn_id;

 IF l_rma_line_id IS NOT NULL THEN

    SELECT nvl(oel.IB_OWNER,oeh.IB_OWNER),
           nvl(oel.IB_INSTALLED_AT_LOCATION,oeh.IB_INSTALLED_AT_LOCATION),
           nvl(oel.IB_CURRENT_LOCATION,oeh.IB_CURRENT_LOCATION),
           nvl(oel.END_CUSTOMER_ID,oeh.END_CUSTOMER_ID),
           nvl(oel.END_CUSTOMER_CONTACT_ID,oeh.END_CUSTOMER_CONTACT_ID),
           nvl(oel.END_CUSTOMER_SITE_USE_ID,oeh.END_CUSTOMER_SITE_USE_ID),
           oeh.sold_to_site_use_id
    INTO   x_partner_order_rec.IB_OWNER,
           x_partner_order_rec.IB_INSTALLED_AT_LOCATION,
           x_partner_order_rec.IB_CURRENT_LOCATION,
           x_partner_order_rec.END_CUSTOMER_ID,
           x_partner_order_rec.END_CUSTOMER_CONTACT_ID,
           x_partner_order_rec.END_CUSTOMER_SITE_USE_ID,
           x_partner_order_rec.SOLD_TO_SITE_USE_ID
    FROM   oe_order_lines_all oel,
           oe_order_headers_all oeh
    WHERE  oel.line_id = l_rma_line_id
    AND    oeh.header_id = oel.header_id;

   IF x_partner_order_rec.IB_OWNER = 'END_CUSTOMER'  THEN

     IF x_partner_order_rec.END_CUSTOMER_ID is null Then
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
     ELSE
            BEGIN
                SELECT party_id,
                       status
                INTO   l_party_id,
                       l_account_status
                FROM   hz_cust_accounts
                WHERE  cust_account_id = x_partner_order_rec.END_CUSTOMER_ID;
            EXCEPTION
              WHEN no_data_found THEN
                   fnd_message.set_name('CSI','CSI_INT_INV_CUST_ACCT_ID');
                   fnd_message.set_token('CUST_ACCOUNT_ID', x_partner_order_rec.END_CUSTOMER_ID);
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
              END;

        IF l_party_id = -1 THEN
           raise fnd_api.g_exc_error;
        END IF;

            x_end_cust_party_id := l_party_id;

      IF l_account_status <> 'A' THEN
        debug('This cust account '||x_partner_order_rec.END_CUSTOMER_ID||' has status '||l_account_status);
      END IF;


        END IF; --partner order

       END IF; --rma line id end if

 END IF;

 EXCEPTION
 WHEN fnd_api.g_exc_error THEN
 x_return_status := fnd_api.g_ret_sts_error;

 END get_partner_order_info;


  PROCEDURE get_src_order_info(
    p_mtl_txn_id         IN  number,
    x_src_order_rec      OUT NOCOPY source_order_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_ship_to_org   number;
    l_invoice_to_org   number;
    l_cust_acct_site_use_id   number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_src_order_info');

    x_src_order_rec.transaction_id := p_mtl_txn_id;

    SELECT trx_source_line_id
    INTO   x_src_order_rec.rma_line_id
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_mtl_txn_id;

    SELECT nvl(reference_line_id , fnd_api.g_miss_num)
    INTO   x_src_order_rec.original_order_line_id
    FROM   oe_order_lines_all
    WHERE  line_id = x_src_order_rec.rma_line_id;

    IF x_src_order_rec.rma_line_id IS NOT NULL THEN

      BEGIN
        SELECT nvl(oel.sold_to_org_id ,oeh.sold_to_org_id) ,
               nvl(oel.ship_to_org_id,oeh.ship_to_org_id),
               nvl(oel.invoice_to_org_id,oeh.invoice_to_org_id), -- Modified SQL to add headers and to also read Invoice to since that needs to be atleast required on RMA's - Self bug. shegde
               ordered_quantity
        INTO   x_src_order_rec.customer_account_id,
               l_ship_to_org,
               l_invoice_to_org,
               x_src_order_rec.original_order_qty
        FROM   oe_order_lines_all oel, oe_order_headers_all oeh
        WHERE  line_id = x_src_order_rec.rma_line_id
	 AND   oeh.header_id = oel.header_id;

           debug('  Original Order Line ID: '||x_src_order_rec.original_order_line_id);
           debug('  Original Return Quantity: '||x_src_order_rec.original_order_qty);
        IF x_src_order_rec.customer_account_id IS NOT NULL THEN
          SELECT party_id
          INTO   x_src_order_rec.party_id
          FROM   hz_cust_accounts
          WHERE  cust_account_id = x_src_order_rec.customer_account_id;
        END IF;
	l_cust_acct_site_use_id := nvl(l_ship_to_org, l_invoice_to_org); -- Invoice to is to be not null in RMA's - Self bug. shegde
        IF l_cust_acct_site_use_id IS NOT NULL THEN
          BEGIN
            SELECT HCAS.party_site_id
            INTO   x_src_order_rec.customer_location_id
            FROM   hz_cust_site_uses_all  HCSU,
                   hz_cust_acct_sites_all HCAS
            WHERE  HCSU.site_use_id       = l_cust_acct_site_use_id
            AND    HCAS.cust_acct_site_id = HCSU.cust_acct_site_id;
          EXCEPTION
            WHEN no_data_found THEN
              fnd_message.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
              fnd_message.set_token('SITE_USE_ID',l_cust_acct_site_use_id);
              fnd_message.set_token('SITE_USE_CODE','SHIP_TO');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          END;
	    ELSE -- null for both ship and Invoice to org in RMA's - Self bug. Raise the error much before rather than in the API. shegde
              fnd_message.set_name('CSI','CSI_TXN_SITE_USE_INVALID');
              fnd_message.set_token('SITE_USE_ID',l_cust_acct_site_use_id);
              fnd_message.set_token('SITE_USE_CODE','INVOICE_TO');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_src_order_info;

  PROCEDURE get_mtl_txn_recs(
    p_mtl_txn_id         IN  number,
    x_src_mtl_txn_tbl    OUT NOCOPY mtl_txn_tbl,
    x_dest_mtl_txn_tbl   OUT NOCOPY mtl_txn_tbl,
    x_item_control_rec   OUT NOCOPY item_control_rec,
    x_src_order_rec      OUT NOCOPY source_order_rec,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_return_status      varchar2(1)    := fnd_api.g_ret_sts_success;
    l_debug_level        number;

    l_s_ind              binary_integer := 0;
    l_d_ind              binary_integer := 0;
    l_src_mtl_txn_tbl    mtl_txn_tbl;
    l_dest_mtl_txn_tbl   mtl_txn_tbl;
    l_item_control_rec   item_control_rec;
    l_src_order_rec      source_order_rec;

    CURSOR l_txn_cur IS
      SELECT mmt.transaction_id          transaction_id,
             mmt.inventory_item_id       inventory_item_id,
             mmt.organization_id         organization_id,
             mmt.subinventory_code       subinventory_code,
             mmt.revision                revision,
             mmt.transaction_quantity    transaction_quantity,
             mmt.transaction_uom         transaction_uom,
             mmt.locator_id              locator_id,
             mmt.transaction_date        transaction_date,
             mut.serial_number           serial_number,
             mtln.lot_number             lot_number,
             msi.location_id             subinv_location_id,
             haou.location_id            hr_location_id,
             mmt.primary_quantity        mmt_primary_quantity,
             mtln.primary_quantity       lot_primary_quantity,
             mmt.trx_source_line_id      oe_line_id,
             mmt.transaction_type_id     transaction_type_id,
             mmt.creation_date           creation_date -- bug 4026148
      FROM   hr_all_organization_units   haou,
             mtl_transaction_lot_numbers mtln,
             mtl_unit_transactions       mut,
             mtl_secondary_inventories   msi,
             mtl_material_transactions   mmt
      WHERE  mmt.transaction_id        = p_mtl_txn_id
      AND    mmt.transaction_id        = mut.transaction_id(+)
      AND    mmt.transaction_id        = mtln.transaction_id(+)
      AND    mmt.subinventory_code     = msi.secondary_inventory_name
      AND    mmt.organization_id       = msi.organization_id
      AND    haou.organization_id      = mmt.organization_id;

    CURSOR l_lotsrl_cur IS
      SELECT mmt.transaction_id          transaction_id,
             mmt.inventory_item_id       inventory_item_id,
             mmt.organization_id         organization_id,
             mmt.subinventory_code       subinventory_code,
             mmt.revision                revision,
             mmt.transaction_quantity    transaction_quantity,
             mmt.transaction_uom         transaction_uom,
             mmt.locator_id              locator_id,
             mmt.transaction_date        transaction_date,
             mut.serial_number           serial_number,
             mtln.lot_number             lot_number,
             msi.location_id             subinv_location_id,
             haou.location_id            hr_location_id,
             mmt.primary_quantity        mmt_primary_quantity,
             mtln.primary_quantity       lot_primary_quantity,
             mmt.trx_source_line_id      oe_line_id,
             mmt.transaction_type_id     transaction_type_id,
             mmt.creation_date           creation_date -- bug 4026148
      FROM   hr_all_organization_units   haou,
             mtl_transaction_lot_numbers mtln,
             mtl_unit_transactions       mut,
             mtl_secondary_inventories   msi,
             mtl_material_transactions   mmt
      WHERE  mmt.transaction_id        = p_mtl_txn_id
      AND    mmt.subinventory_code     = msi.secondary_inventory_name
      AND    mmt.organization_id       = msi.organization_id
      AND    mtln.transaction_id       = mmt.transaction_id
      AND    mut.transaction_id        = mtln.serial_transaction_id
      AND    mmt.organization_id       = haou.organization_id;

    CURSOR l_6_cur IS
      SELECT mmt.transaction_id          transaction_id,
             mmt.inventory_item_id       inventory_item_id,
             mmt.organization_id         organization_id,
             mmt.subinventory_code       subinventory_code,
             mmt.revision                revision,
             mmt.transaction_quantity    transaction_quantity,
             mmt.transaction_uom         transaction_uom,
             mmt.locator_id              locator_id,
             mmt.transaction_date        transaction_date,
             null                        serial_number,
             mtln.lot_number             lot_number,
             msi.location_id             subinv_location_id,
             haou.location_id            hr_location_id,
             mmt.primary_quantity        mmt_primary_quantity,
             mtln.primary_quantity       lot_primary_quantity,
             mmt.trx_source_line_id      oe_line_id,
             mmt.transaction_type_id     transaction_type_id,
             mmt.creation_date           creation_date -- bug 4026148
      FROM   hr_all_organization_units   haou,
             mtl_transaction_lot_numbers mtln,
             mtl_secondary_inventories   msi,
             mtl_material_transactions   mmt
      WHERE  mmt.transaction_id        = p_mtl_txn_id
      AND    mmt.transaction_id        = mtln.transaction_id(+)
      AND    mmt.subinventory_code     = msi.secondary_inventory_name
      AND    mmt.organization_id       = msi.organization_id
      AND    haou.organization_id      = mmt.organization_id;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_mtl_txn_recs');

    l_debug_level   := csi_t_gen_utility_pvt.g_debug_level;

    get_src_order_info(
      p_mtl_txn_id        => p_mtl_txn_id,
      x_src_order_rec     => l_src_order_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

      x_src_order_rec     := l_src_order_rec;

    get_item_control_rec(
      p_mtl_txn_id        => p_mtl_txn_id,
      x_item_control_rec  => l_item_control_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF  (l_item_control_rec.serial_control_code in (2, 5, 6)
         AND
         l_item_control_rec.lot_control_code = 1 )    -- serial control only
        --
        OR
        --
        (l_item_control_rec.serial_control_code = 1
         AND
         l_item_control_rec.lot_control_code = 2)    -- lot control only
        --
        OR
        (l_item_control_rec.serial_control_code = 1
         AND
         l_item_control_rec.lot_control_code = 1)     -- no lot, no serial
    THEN

      FOR l_txn_rec IN l_txn_cur LOOP

        l_s_ind := l_txn_cur%rowcount;

        l_src_mtl_txn_tbl(l_s_ind).transaction_id       := l_txn_rec.transaction_id;
        l_src_mtl_txn_tbl(l_s_ind).inventory_item_id    := l_txn_rec.inventory_item_id;
        l_src_mtl_txn_tbl(l_s_ind).organization_id      := l_txn_rec.organization_id;
        l_src_mtl_txn_tbl(l_s_ind).subinventory_code    := l_txn_rec.subinventory_code;
        l_src_mtl_txn_tbl(l_s_ind).revision             := l_txn_rec.revision;
        l_src_mtl_txn_tbl(l_s_ind).transaction_quantity := l_txn_rec.transaction_quantity;
        l_src_mtl_txn_tbl(l_s_ind).transaction_uom      := l_txn_rec.transaction_uom;
        l_src_mtl_txn_tbl(l_s_ind).locator_id           := l_txn_rec.locator_id;
        l_src_mtl_txn_tbl(l_s_ind).transaction_date     := l_txn_rec.transaction_date;
        l_src_mtl_txn_tbl(l_s_ind).serial_number        := l_txn_rec.serial_number;
        l_src_mtl_txn_tbl(l_s_ind).lot_number           := l_txn_rec.lot_number;
        l_src_mtl_txn_tbl(l_s_ind).inv_location_id      := nvl(l_txn_rec.subinv_location_id,
                                                               l_txn_rec.hr_location_id);

        l_src_mtl_txn_tbl(l_s_ind).primary_uom_code     := l_item_control_rec.primary_uom_code;
        l_src_mtl_txn_tbl(l_s_ind).mmt_primary_quantity := l_txn_rec.mmt_primary_quantity;
        l_src_mtl_txn_tbl(l_s_ind).lot_primary_quantity := l_txn_rec.lot_primary_quantity;
        l_src_mtl_txn_tbl(l_s_ind).oe_line_id           := l_txn_rec.oe_line_id;
        l_src_mtl_txn_tbl(l_s_ind).transaction_type_id  := l_txn_rec.transaction_type_id;

        l_src_mtl_txn_tbl(l_s_ind).original_order_line_id:= l_src_order_rec.original_order_line_id;
        l_src_mtl_txn_tbl(l_s_ind).customer_location_id := l_src_order_rec.customer_location_id;
        l_src_mtl_txn_tbl(l_s_ind).customer_account_id  := l_src_order_rec.customer_account_id;
        l_src_mtl_txn_tbl(l_s_ind).party_id             := l_src_order_rec.party_id;
        l_src_mtl_txn_tbl(l_s_ind).mtl_txn_creation_date        := l_txn_rec.creation_date; -- bug4026148

        -- no lot, no serial
        IF (l_item_control_rec.serial_control_code = 1
            AND
            l_item_control_rec.lot_control_code = 1)
        THEN

          l_src_mtl_txn_tbl(l_s_ind).instance_quantity := l_txn_rec.mmt_primary_quantity;

        -- lot only case
        ELSIF (l_item_control_rec.serial_control_code = 1
            AND
            l_item_control_rec.lot_control_code = 2)
        THEN
          l_src_mtl_txn_tbl(l_s_ind).instance_quantity := l_txn_rec.lot_primary_quantity;
        -- serial only case
        ELSIF (l_item_control_rec.serial_control_code in (2, 5, 6)
            AND
            l_item_control_rec.lot_control_code = 1 )
        THEN
          l_src_mtl_txn_tbl(l_s_ind).instance_quantity := 1;
        END IF;

      END LOOP;

    ELSIF (l_item_control_rec.serial_control_code in (2, 5, 6)
           AND
           l_item_control_rec.lot_control_code  = 2)
    THEN

      FOR l_lotsrl_rec IN l_lotsrl_cur LOOP

        l_s_ind := l_lotsrl_cur%rowcount;

        l_src_mtl_txn_tbl(l_s_ind).transaction_id       := l_lotsrl_rec.transaction_id;
        l_src_mtl_txn_tbl(l_s_ind).inventory_item_id    := l_lotsrl_rec.inventory_item_id;
        l_src_mtl_txn_tbl(l_s_ind).organization_id      := l_lotsrl_rec.organization_id;
        l_src_mtl_txn_tbl(l_s_ind).subinventory_code    := l_lotsrl_rec.subinventory_code;
        l_src_mtl_txn_tbl(l_s_ind).revision             := l_lotsrl_rec.revision;
        l_src_mtl_txn_tbl(l_s_ind).transaction_quantity := l_lotsrl_rec.transaction_quantity;
        l_src_mtl_txn_tbl(l_s_ind).transaction_uom      := l_lotsrl_rec.transaction_uom;
        l_src_mtl_txn_tbl(l_s_ind).locator_id           := l_lotsrl_rec.locator_id;
        l_src_mtl_txn_tbl(l_s_ind).transaction_date     := l_lotsrl_rec.transaction_date;
        l_src_mtl_txn_tbl(l_s_ind).serial_number        := l_lotsrl_rec.serial_number;
        l_src_mtl_txn_tbl(l_s_ind).lot_number           := l_lotsrl_rec.lot_number;
        l_src_mtl_txn_tbl(l_s_ind).inv_location_id      := nvl(l_lotsrl_rec.subinv_location_id,
                                                               l_lotsrl_rec.hr_location_id);
        l_src_mtl_txn_tbl(l_s_ind).primary_uom_code     := l_item_control_rec.primary_uom_code;
        l_src_mtl_txn_tbl(l_s_ind).mmt_primary_quantity := l_lotsrl_rec.mmt_primary_quantity;
        l_src_mtl_txn_tbl(l_s_ind).lot_primary_quantity := l_lotsrl_rec.lot_primary_quantity;
        l_src_mtl_txn_tbl(l_s_ind).oe_line_id           := l_lotsrl_rec.oe_line_id;
        l_src_mtl_txn_tbl(l_s_ind).transaction_type_id  := l_lotsrl_rec.transaction_type_id;
        l_src_mtl_txn_tbl(l_s_ind).instance_quantity    := 1;

        l_src_mtl_txn_tbl(l_s_ind).original_order_line_id:= l_src_order_rec.original_order_line_id;
        l_src_mtl_txn_tbl(l_s_ind).customer_location_id := l_src_order_rec.customer_location_id;
        l_src_mtl_txn_tbl(l_s_ind).customer_account_id  := l_src_order_rec.customer_account_id;
        l_src_mtl_txn_tbl(l_s_ind).party_id             := l_src_order_rec.party_id;
        l_src_mtl_txn_tbl(l_s_ind).mtl_txn_creation_date:= l_lotsrl_rec.creation_date;--bug 4026148
      END LOOP;

    ELSE
      debug('This transaction has a special item control : '||p_mtl_txn_id);
    END IF;

    IF l_item_control_rec.serial_control_code = 6 THEN

      FOR l_6_rec IN l_6_cur LOOP

        l_d_ind := l_6_cur%rowcount;

        l_dest_mtl_txn_tbl(l_d_ind).transaction_id       := l_6_rec.transaction_id;
        l_dest_mtl_txn_tbl(l_d_ind).inventory_item_id    := l_6_rec.inventory_item_id;
        l_dest_mtl_txn_tbl(l_d_ind).organization_id      := l_6_rec.organization_id;
        l_dest_mtl_txn_tbl(l_d_ind).subinventory_code    := l_6_rec.subinventory_code;
        l_dest_mtl_txn_tbl(l_d_ind).revision             := l_6_rec.revision;
        l_dest_mtl_txn_tbl(l_d_ind).transaction_quantity := l_6_rec.transaction_quantity;
        l_dest_mtl_txn_tbl(l_d_ind).transaction_uom      := l_6_rec.transaction_uom;
        l_dest_mtl_txn_tbl(l_d_ind).locator_id           := l_6_rec.locator_id;
        l_dest_mtl_txn_tbl(l_d_ind).transaction_date     := l_6_rec.transaction_date;
        l_dest_mtl_txn_tbl(l_d_ind).serial_number        := l_6_rec.serial_number;
        l_dest_mtl_txn_tbl(l_d_ind).lot_number           := l_6_rec.lot_number;
        l_dest_mtl_txn_tbl(l_d_ind).inv_location_id      := nvl(l_6_rec.subinv_location_id,
                                                              l_6_rec.hr_location_id);
        l_dest_mtl_txn_tbl(l_d_ind).primary_uom_code     := l_item_control_rec.primary_uom_code;
        l_dest_mtl_txn_tbl(l_d_ind).mmt_primary_quantity := l_6_rec.mmt_primary_quantity;
        l_dest_mtl_txn_tbl(l_d_ind).lot_primary_quantity := l_6_rec.lot_primary_quantity;
        l_dest_mtl_txn_tbl(l_d_ind).oe_line_id           := l_6_rec.oe_line_id;
        l_dest_mtl_txn_tbl(l_d_ind).transaction_type_id  := l_6_rec.transaction_type_id;

        IF l_item_control_rec.lot_control_code = 2 THEN
          l_dest_mtl_txn_tbl(l_d_ind).instance_quantity  := l_6_rec.lot_primary_quantity;
        ELSE
          l_dest_mtl_txn_tbl(l_d_ind).instance_quantity  := l_6_rec.mmt_primary_quantity;
        END IF;

        l_dest_mtl_txn_tbl(l_d_ind).original_order_line_id:= l_src_order_rec.original_order_line_id;
        l_dest_mtl_txn_tbl(l_d_ind).customer_location_id := l_src_order_rec.customer_location_id;
        l_dest_mtl_txn_tbl(l_d_ind).customer_account_id  := l_src_order_rec.customer_account_id;
        l_dest_mtl_txn_tbl(l_d_ind).party_id             := l_src_order_rec.party_id;
        l_dest_mtl_txn_tbl(l_d_ind).mtl_txn_creation_date:= l_6_rec.creation_date;--bug 4026148

      END LOOP;

    ELSE
      l_dest_mtl_txn_tbl := l_src_mtl_txn_tbl;
    END IF;

    IF l_s_ind = 0 then
      fnd_message.set_name('CSI','CSI_NO_INVENTORY_RECORDS');
      fnd_message.set_token('MTL_TRANSACTION_ID',p_mtl_txn_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('Mtl Transaction Recs Count(Source)      : '||l_src_mtl_txn_tbl.COUNT);
    debug('Mtl Transaction Recs Count(Destination) : '||l_dest_mtl_txn_tbl.COUNT);

    IF l_debug_level >= 10 THEN

      debug('Dumping source material transaction recs.');

      dump_mtl_txn_tbl(
        p_mtl_txn_tbl => l_src_mtl_txn_tbl);

      debug('Dumping destination material transaction recs.');

      dump_mtl_txn_tbl(
        p_mtl_txn_tbl => l_dest_mtl_txn_tbl);

    END IF;

    x_item_control_rec := l_item_control_rec;
    x_src_mtl_txn_tbl  := l_src_mtl_txn_tbl;
    x_dest_mtl_txn_tbl := l_dest_mtl_txn_tbl;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN

      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','get_mtl_txn_recs');
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 240));
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END get_mtl_txn_recs;

  PROCEDURE build_instance_query_rec(
    p_mtl_txn_rec           IN  mtl_txn_rec,
    x_instance_query_rec    OUT NOCOPY csi_datastructures_pub.instance_query_rec,
    x_party_query_rec       OUT NOCOPY csi_datastructures_pub.party_query_rec,
    x_pty_acct_query_rec    OUT NOCOPY csi_datastructures_pub.party_account_query_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_inv_location_id       number;
    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_instance_query_rec');

    l_inst_query_rec.inventory_item_id     := p_mtl_txn_rec.inventory_item_id;
    l_inst_query_rec.lot_number            := p_mtl_txn_rec.lot_number;
    l_inst_query_rec.serial_number         := p_mtl_txn_rec.serial_number;

    --comenting this because ui allows creation of cp with other than hz_party_sites
    --l_inst_query_rec.location_type_code    := 'HZ_PARTY_SITES';

   /* start of ER 2646086 + RMA for Repair with different party */
   /* removing party from the search criteria */

    --l_party_query_rec.party_id               := p_mtl_txn_rec.party_id;
    --l_party_query_rec.relationship_type_code := 'OWNER';

   /* end of ER 2646086 + RMA for Repair with different party */

    x_instance_query_rec := l_inst_query_rec;
    x_party_query_rec    := l_party_query_rec;

    debug('Instance query criteria for the customer product.');

    csi_t_gen_utility_pvt.dump_instance_query_rec(
      p_instance_query_rec => x_instance_query_rec);

    debug('party query criteria :');
    debug('  party_id                 :'||l_party_query_rec.party_id);
    debug('  relationship_type_code   :'||l_party_query_rec.relationship_type_code);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_instance_query_rec;


  PROCEDURE identify_source_instance(
    px_mtl_txn_rec          IN OUT NOCOPY mtl_txn_rec,
    p_item_control_rec      IN  item_control_rec, -- Added for Multi WIP Job ER
    x_return_status         OUT NOCOPY varchar2)
  IS
    l_instance_query_rec    csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;
    l_instance_header_tbl   csi_datastructures_pub.instance_header_tbl;
    l_assm_qty              number;
    l_qry_exp_inst          varchar2(1) := fnd_api.g_false;
    l_wip_entity_type       number;

    l_msg_count             number;
    l_msg_data              varchar2(2000);
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    api_log('identify_source_instance');

    x_return_status := fnd_api.g_ret_sts_success;

    build_instance_query_rec(
      p_mtl_txn_rec          => px_mtl_txn_rec,
      x_instance_query_rec   => l_instance_query_rec,
      x_party_query_rec      => l_party_query_rec,
      x_pty_acct_query_rec   => l_pty_acct_query_rec,
      x_return_status        => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- RMA fulfillment ER, get expired instances also. Instance id is mandatory in TD entered for RMA fl.
    -- This fix 2733128 (11.5.8) is already taken care of in 11.5.9
/*
    IF nvl(px_mtl_txn_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_qry_exp_inst := fnd_api.g_true;
    END IF;

    debug('  Bring expired instances Flag  :'||l_qry_exp_inst);
*/ -- shegde removing this check since  referencing an instance should not be a pre-requisite.

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => 'get_item_instances',
      p_pkg_name => 'csi_item_instance_pub');

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
      p_active_instance_only => l_qry_exp_inst,
      x_instance_header_tbl  => l_instance_header_tbl,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_instance_header_tbl.COUNT > 0 THEN
      IF l_instance_header_tbl.COUNT = 1 THEN
        debug('Unique source instance found. Instance ID: '||l_instance_header_tbl(1).instance_id);
        px_mtl_txn_rec.instance_id := l_instance_header_tbl(1).instance_id;

        -- Included INVENTORY in the Condition and also added the else condition as part of
        -- fix for Bug 2733128.

        IF l_instance_header_tbl(1).location_type_code
             NOT IN ( 'INVENTORY','HZ_PARTY_SITES', 'HZ_LOCATIONS', 'VENDOR_SITE', 'INTERNAL_SITE')
        THEN
           IF l_instance_header_tbl(1).location_type_code = 'WIP'
             AND l_instance_header_tbl(1).wip_job_id is NOT NULL THEN
         -- Multi-WIP Job fallout. These are the srl. Orphan components hanging out in WIP!!
            debug('Could be Multi-WIP Job fallout.'||l_instance_header_tbl(1).instance_id);
 /* Commented for now to avoid select on wip entities. Assumption being any instance being RMAed with location as WIP are created only as a result of a multi wip job.
            Begin
                SELECT entity_type
                INTO   l_wip_entity_type
                FROM   wip_entities
                WHERE  wip_entity_id   = l_instance_header_tbl(1).wip_job_id
                AND    organization_id = l_instance_header_tbl(1).vld_organization_id;

              IF l_wip_entity_type in (1,3) THEN
                SELECT start_quantity
                INTO   l_assm_qty
                FROM   wip_discrete_jobs
                WHERE  wip_entity_id   = l_instance_header_tbl(1).wip_job_id
                AND    organization_id = l_instance_header_tbl(1).vld_organization_id;
              END IF;
              IF l_assm_qty > 1
               AND p_item_control_rec.serial_control_code in (2,5) THEN
                  debug('A Multi-WIP Job and Serialized instance.'||l_instance_header_tbl(1).instance_id);
              ELSE
                  debug('Location type code is :'||l_instance_header_tbl(1).location_type_code);
                  fnd_message.set_name('CSI', 'CSI_NON_RETURNABLE_INSTANCE');
                  fnd_message.set_token('LOC_TYPE_CODE', l_instance_header_tbl(1).location_type_code);
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
              END IF;

            Exception when others then
              fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',substr(sqlerrm,1,255));
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            End;
*/
           ELSE
              debug('Location type code is :'||l_instance_header_tbl(1).location_type_code);
              fnd_message.set_name('CSI', 'CSI_NON_RETURNABLE_INSTANCE');
              fnd_message.set_token('LOC_TYPE_CODE', l_instance_header_tbl(1).location_type_code);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        -- fix for Bug 2733128.
        ELSE
         IF ( l_instance_header_tbl(1).location_type_code = 'INVENTORY'
             AND
              NVL(l_instance_header_tbl(1).active_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date
            )
         THEN
            debug('Location type code is :'||l_instance_header_tbl(1).location_type_code);
            fnd_message.set_name('CSI', 'CSI_NON_RETURNABLE_INSTANCE');
            fnd_message.set_token('LOC_TYPE_CODE', l_instance_header_tbl(1).location_type_code);
            fnd_message.set_token('INV_ORG_ID',l_instance_query_rec.inv_organization_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
         END IF;
        END IF;
      ELSIF (p_item_control_rec.serial_control_code <> 1
       AND p_item_control_rec.lot_control_code <> 2 ) THEN
        -- Added condition for bug 6336254, if the item is non-serialized but lot controlled,
	-- there are could be multiple instances found in install base
        debug('Multiple Source Instances Found.');
        fnd_message.set_name('CSI', 'CSI_TXN_MULT_INST_FOUND');
        fnd_message.set_token('INV_ITEM_ID',l_instance_query_rec.inventory_item_id);
        fnd_message.set_token('INV_ORG_ID',l_instance_query_rec.inv_organization_id);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
      END IF;
    ELSE
      debug('RMA Processor could not find the source instance.');
      px_mtl_txn_rec.instance_id := fnd_api.g_miss_num;
    END IF;
  EXCEPTION
	 WHEN fnd_api.g_exc_error THEN
	    x_return_status := fnd_api.g_ret_sts_error;
  END identify_source_instance;


  PROCEDURE identify_source_instances(
    px_mtl_txn_tbl          IN OUT NOCOPY mtl_txn_tbl,
    p_item_control_rec      IN  item_control_rec, -- Added for Multi WIP Job ER
    x_return_status         OUT NOCOPY varchar2)
  IS
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('identify_source_instances');

    IF px_mtl_txn_tbl.COUNT > 0 THEN
      FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
      LOOP

        identify_source_instance(
          px_mtl_txn_rec   => px_mtl_txn_tbl(l_ind),
          p_item_control_rec => p_item_control_rec,
          x_return_status  => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END identify_source_instances;

  PROCEDURE get_master_organization_id(
    p_organization_id        IN  number,
    x_master_organization_id OUT NOCOPY number,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_master_organization_id number;
  BEGIN
    api_log('get_master_organization_id');
    x_return_status := fnd_api.g_ret_sts_success;
    SELECT master_organization_id
    INTO   l_master_organization_id
    FROM   mtl_parameters
    WHERE  organization_id = p_organization_id;
    x_master_organization_id := l_master_organization_id;
  EXCEPTION
    WHEN no_data_found THEN
      null;
  END get_master_organization_id;

  PROCEDURE build_process_tables_TD(
    p_line_dtl_tbl           IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_mtl_txn_tbl            IN  mtl_txn_tbl,
    p_item_control_rec       IN  item_control_rec,
    x_txn_rec                OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_instances_tbl          OUT NOCOPY csi_process_txn_grp.txn_instances_tbl,
    x_i_parties_tbl          OUT NOCOPY csi_process_txn_grp.txn_i_parties_tbl,
    x_ip_accounts_tbl        OUT NOCOPY csi_process_txn_grp.txn_ip_accounts_tbl,
    x_org_units_tbl          OUT NOCOPY csi_process_txn_grp.txn_org_units_tbl,
    x_ext_attrib_values_tbl  OUT NOCOPY csi_process_txn_grp.txn_ext_attrib_values_tbl,
    x_pricing_attribs_tbl    OUT NOCOPY csi_process_txn_grp.txn_pricing_attribs_tbl,
    x_instance_asset_tbl     OUT NOCOPY csi_process_txn_grp.txn_instance_asset_tbl,
    x_ii_relationships_tbl   OUT NOCOPY csi_process_txn_grp.txn_ii_relationships_tbl,
    x_dest_location_rec      OUT NOCOPY csi_process_txn_grp.dest_location_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS

    --Hard Coded Values
    l_transaction_type_id    number       := 53;
    l_txn_sub_type_id        number       := 38;
    l_sub_type_rec           csi_txn_sub_types%rowtype;

    l_internal_party_id      number;
    l_master_organization_id number;
    l_instance_quantity      number;

    l_rma_order_rec          mtl_trx_type;
    l_txn_rec                csi_datastructures_pub.transaction_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;
    l_mtl_txn_rec		     mtl_txn_rec;

    -- get_transaction_details variables

    l_txn_line_query_rec     csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl            csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl           csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl          csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_eav_tbl            csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl        csi_t_datastructures_grp.txn_systems_tbl;
    l_csi_ea_tbl             csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl            csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;


    -- misc variables
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);
    l_error_message          varchar2(2000);

    l_pty_ind                binary_integer;
    l_pa_ind                 binary_integer;
    l_oa_ind                 binary_integer;
    l_ea_ind                 binary_integer;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_process_tables_TD');

    get_dflt_sub_type_id(
      p_transaction_type_id => l_transaction_type_id,
      x_sub_type_id         => l_txn_sub_type_id,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    l_pty_ind := 1;
    l_pa_ind  := 1;

    IF p_mtl_txn_tbl.COUNT > 0 THEN


      FOR l_ind IN p_mtl_txn_tbl.FIRST .. p_mtl_txn_tbl.LAST
      LOOP

        -- get this information only once and use it in the loop
        IF l_ind = 1 THEN
          get_rma_info(
            p_transaction_id  => p_mtl_txn_tbl(l_ind).transaction_id,
            x_mtl_trx_type    => l_rma_order_rec,
            x_error_message   => l_error_message,
            x_return_status   => l_return_status);
        END IF;

        -- get_txn_line_details
        IF nvl(p_mtl_txn_tbl(l_ind).txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN

          l_txn_line_detail_query_rec.txn_line_detail_id := p_mtl_txn_tbl(l_ind).txn_line_detail_id;
          l_txn_line_detail_query_rec.processing_status  := 'IN_PROCESS'; -- added for bug 3094905

          csi_t_txn_details_grp.get_transaction_details(
            p_api_version                => 1.0,
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
            x_txn_ext_attrib_vals_tbl    => l_txn_eav_tbl,
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
            debug('Error getting the transaction details info for the subject id');
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

        IF l_ind = 1 THEN

          get_master_organization_id(
            p_organization_id        => p_mtl_txn_tbl(l_ind).organization_id,
            x_master_organization_id => l_master_organization_id,
            x_return_status          => l_return_status);

          l_dest_location_rec.location_type_code    := 'INVENTORY';
          l_dest_location_rec.location_id           := p_mtl_txn_tbl(l_ind).inv_location_id;
          l_dest_location_rec.inv_organization_id   := p_mtl_txn_tbl(l_ind).organization_id;
          l_dest_location_rec.inv_subinventory_name := p_mtl_txn_tbl(l_ind).subinventory_code;
          l_dest_location_rec.inv_locator_id := p_mtl_txn_tbl(l_ind).locator_id;
          --
          --
          l_txn_rec.inv_material_transaction_id := p_mtl_txn_tbl(l_ind).transaction_id;
          l_txn_rec.transaction_quantity     := p_mtl_txn_tbl(l_ind).transaction_quantity;
          l_txn_rec.transaction_uom_code     := p_mtl_txn_tbl(l_ind).transaction_uom;
          l_txn_rec.source_transaction_date  := p_mtl_txn_tbl(l_ind).transaction_date;
          l_txn_rec.transaction_date         := sysdate;
          l_txn_rec.transaction_type_id      := l_transaction_type_id;
          l_txn_rec.txn_sub_type_id          := p_mtl_txn_tbl(l_ind).sub_type_id;

          IF nvl(l_txn_rec.txn_sub_type_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            l_txn_rec.txn_sub_type_id    := l_txn_sub_type_id;
          END IF;

          get_sub_type_rec(
            p_transaction_type_id => l_txn_rec.transaction_type_id,
            p_sub_type_id         => l_txn_rec.txn_sub_type_id,
            x_sub_type_rec        => l_sub_type_rec,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

          l_txn_rec.source_header_ref     := l_rma_order_rec.source_header_ref;
          l_txn_rec.source_header_ref_id  := l_rma_order_rec.source_header_id;
          l_txn_rec.source_line_ref       := l_rma_order_rec.source_line_ref;
          l_txn_rec.source_line_ref_id    := p_mtl_txn_tbl(l_ind).oe_line_id;
          l_txn_rec.transaction_status_code := 'PENDING';

        END IF;

        --
        --
        debug('Building instance rec '||l_ind||' for process transaction.');

        l_instances_tbl(l_ind).ib_txn_segment_flag  := 'S';
        l_instances_tbl(l_ind).actual_return_date   := p_mtl_txn_tbl(l_ind).transaction_date;
        l_instances_tbl(l_ind).return_by_date       := null;
        /* this is because we query txn details by txn_line_detail_id */
        IF l_line_dtl_tbl.COUNT = 1
          AND nvl(p_mtl_txn_tbl(l_ind).txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
	THEN
          l_instances_tbl(l_ind).instance_id            := l_line_dtl_tbl(1).instance_id;
        END IF;

        IF nvl(l_instances_tbl(l_ind).instance_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          l_instances_tbl(l_ind).instance_id          := p_mtl_txn_tbl(l_ind).instance_id;
        END IF;

        l_instances_tbl(l_ind).mtl_txn_creation_date  := nvl(p_mtl_txn_tbl(l_ind).mtl_txn_creation_date,sysdate);--bug4026148
        l_instances_tbl(l_ind).quantity               := p_mtl_txn_tbl(l_ind).instance_quantity;

        IF nvl(l_instances_tbl(l_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          BEGIN

            SELECT quantity
            INTO   l_instance_quantity
            FROM   csi_item_instances
            WHERE  instance_id = l_instances_tbl(l_ind).instance_id;
/* We do not do this anymore.Complete RMA cancellations are always Expire cases. Bug 3746600 .
           IF l_line_dtl_tbl(1).reference_source_id is NOT NULL
            AND l_line_dtl_tbl(1).reference_source_line_id is NOT NULL THEN
         -- RMA fulfillment case. A shippable item was fulfilled earlier thru RMA FL
         -- and now it is coming back on a std RMA receipt. So it could even be expired
         -- earlier but Qty was reduced so this time do NOT reduce it and unexpire it.
      	     IF NOT (WF_ENGINE.ACTIVITY_EXIST_IN_PROCESS(
				'OEOL'
				,to_char(l_line_dtl_tbl(1).reference_source_line_id)
				,'OEOL'
				,'RMA_RECEIVING_SUB'
				 ))
	     THEN
		debug('This Line had No Receiving Node in the RMA fulfillment earlier. Special Processing...');

                l_instances_tbl(l_ind).active_end_date := NULL; -- this is done in process txn also
                IF p_item_control_rec.serial_control_code = 1 THEN -- pass g_miss so that process txn API does not double update source instance
                    l_instances_tbl(l_ind).instance_id := fnd_api.g_miss_num;
                END IF;
             ELSE
		debug('sorry!!. This Line had A Receiving Node on the RMA Order earlier. Normal Processing...');
                IF l_instance_quantity < l_instances_tbl(l_ind).quantity THEN

                   fnd_message.set_name('CSI', 'CSI_INT_QTY_CHK_FAILED');
                   fnd_message.set_token('INSTANCE_ID', l_instances_tbl(l_ind).instance_id);
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;

                END IF;
	     END IF;
           ELSIF l_instance_quantity < l_instances_tbl(l_ind).quantity THEN
Bug 3746600 */
           IF l_instance_quantity < l_instances_tbl(l_ind).quantity THEN

              fnd_message.set_name('CSI', 'CSI_INT_QTY_CHK_FAILED');
              fnd_message.set_token('INSTANCE_ID', l_instances_tbl(l_ind).instance_id);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;

           END IF;

          EXCEPTION
            WHEN no_data_found THEN
              null;
          END;
        ELSIF p_item_control_rec.serial_control_code <> 1 THEN
           l_mtl_txn_rec  := p_mtl_txn_tbl(l_ind);
           identify_source_instance(
                px_mtl_txn_rec    => l_mtl_txn_rec ,
                p_item_control_rec => p_item_control_rec,
                x_return_status   => l_return_status);

                IF l_mtl_txn_rec.instance_id <> fnd_api.g_miss_num THEN
                   l_instances_tbl(l_ind).instance_id := l_mtl_txn_rec.instance_id;
                END IF;
        END IF;

        l_instances_tbl(l_ind).inventory_item_id      := p_mtl_txn_tbl(l_ind).inventory_item_id;
        l_instances_tbl(l_ind).vld_organization_id    := p_mtl_txn_tbl(l_ind).organization_id;

        l_instances_tbl(l_ind).inv_master_organization_id := l_master_organization_id;
        l_instances_tbl(l_ind).inventory_revision      := p_mtl_txn_tbl(l_ind).revision;

        l_instances_tbl(l_ind).last_oe_rma_line_id    := p_mtl_txn_tbl(l_ind).oe_line_id;
        l_instances_tbl(l_ind).object_version_number  := 1.0;

        IF nvl(p_mtl_txn_tbl(l_ind).serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
          l_instances_tbl(l_ind).mfg_serial_number_flag := 'N';
        ELSE
          l_instances_tbl(l_ind).mfg_serial_number_flag := 'Y';
        END IF;

        l_instances_tbl(l_ind).serial_number := p_mtl_txn_tbl(l_ind).serial_number;
        l_instances_tbl(l_ind).lot_number    := p_mtl_txn_tbl(l_ind).lot_number;
        --l_instances_tbl(l_ind).location_type_code := 'HZ_PARTY_SITES';
        --l_instances_tbl(l_ind).instance_usage_code := 'IN_INVENTORY';

        l_instances_tbl(l_ind).unit_of_measure        := p_mtl_txn_tbl(l_ind).primary_uom_code;
        --
        --

      IF p_item_control_rec.serial_control_code not in (1,6) THEN
    -- Added this check to filter out serial code 1 and 6. shegde.
    --building td party recs here could mean association of these parties to the Inventory instance(non-serialized cases) which is not correct

        IF l_pty_dtl_tbl.COUNT > 0 THEN

          FOR l_pd_ind IN l_pty_dtl_tbl.FIRST .. l_pty_dtl_tbl.LAST
          LOOP
            IF l_pty_dtl_tbl(l_pd_ind).relationship_type_code <> 'OWNER' THEN

        debug('Building TD party rec '||l_pty_ind||' for process transaction.');

              l_i_parties_tbl(l_pty_ind).parent_tbl_index   := l_ind;
              l_i_parties_tbl(l_pty_ind).party_source_table :=
                                         l_pty_dtl_tbl(l_pd_ind).party_source_table;
              l_i_parties_tbl(l_pty_ind).party_id           :=
                                         l_pty_dtl_tbl(l_pd_ind).party_source_id;
              l_i_parties_tbl(l_pty_ind).relationship_type_code :=
                                         l_pty_dtl_tbl(l_pd_ind).relationship_type_code;
              l_i_parties_tbl(l_pty_ind).contact_flag       :=
                                         l_pty_dtl_tbl(l_pd_ind).contact_flag;


            IF nvl(l_sub_type_rec.src_change_owner, 'N') = 'N'
      -- Added this If piece for the ER 2482219
             AND l_pty_acct_tbl.COUNT > 0 THEN

             FOR l_pad_ind IN l_pty_acct_tbl.FIRST .. l_pty_acct_tbl.LAST
             LOOP

             IF l_pty_acct_tbl(l_pad_ind).txn_party_detail_id = l_pty_dtl_tbl(l_pd_ind).txn_party_detail_id THEN
               IF l_pty_acct_tbl(l_pad_ind).relationship_type_code <> 'OWNER' THEN

                    debug('Building TD account rec '||l_pa_ind||' for process transaction.');

              l_ip_accounts_tbl(l_pa_ind).parent_tbl_index       := l_pty_ind;
              l_ip_accounts_tbl(l_pa_ind).party_account_id       := l_pty_acct_tbl(l_pad_ind).account_id;
              l_ip_accounts_tbl(l_pa_ind).ip_account_id       := l_pty_acct_tbl(l_pad_ind).ip_account_id;
              l_ip_accounts_tbl(l_pa_ind).relationship_type_code := l_pty_acct_tbl(l_pad_ind).relationship_type_code;
              l_ip_accounts_tbl(l_pa_ind).bill_to_address       := l_pty_acct_tbl(l_pad_ind).bill_to_address_id;
              l_ip_accounts_tbl(l_pa_ind).ship_to_address       := l_pty_acct_tbl(l_pad_ind).ship_to_address_id;
              l_ip_accounts_tbl(l_pa_ind).active_end_date       := l_pty_acct_tbl(l_pad_ind).active_end_date;

                l_pa_ind := l_pa_ind + 1;
          END IF;
        END IF;
          END LOOP;  -- pty_acct_tbl loop
         END IF; -- l_pty_acct_tbl.count > 0

            l_pty_ind := l_pty_ind + 1;

           END IF; -- pty record <> 'OWNER'
          END LOOP; -- pty_dtl_tbl loop
         END IF; -- pty_dtl_tbl.count > 0

       END IF; -- serial code not in 1,6

        --
        --

        -- check_and_break relation
        IF (nvl(l_instances_tbl(l_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
            AND
            l_instances_tbl(l_ind).mfg_serial_number_flag = 'Y')
            OR
            -- for non serial configured item break it from the ato model
            nvl(p_item_control_rec.model_item_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN

          --  Moved the routine to process txn pvt to avoid circular dependancy
          --  introduced in that routine for bug 2373109 and also to not load rma receipt for
          --  Non RMA txns . shegde. Bug 2443204

          csi_process_txn_pvt.check_and_break_relation(
            p_instance_id   => l_instances_tbl(l_ind).instance_id,
            p_csi_txn_rec   => l_txn_rec,
            x_return_status => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;

    END IF;

    x_txn_rec                := l_txn_rec;
    x_instances_tbl          := l_instances_tbl;
    x_i_parties_tbl          := l_i_parties_tbl;
    x_ip_accounts_tbl        := l_ip_accounts_tbl;
    x_org_units_tbl          := l_org_units_tbl;
    x_ext_attrib_values_tbl  := l_ext_attrib_values_tbl;
    x_pricing_attribs_tbl    := l_pricing_attribs_tbl;
    x_instance_asset_tbl     := l_instance_asset_tbl;
    x_ii_relationships_tbl   := l_ii_relationships_tbl;
    x_dest_location_rec      := l_dest_location_rec;

  END;

  PROCEDURE build_process_tables_NOTD(
    p_mtl_txn_tbl            IN  mtl_txn_tbl,
    p_item_control_rec       IN  item_control_rec,
    x_txn_rec                OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_instances_tbl          OUT NOCOPY csi_process_txn_grp.txn_instances_tbl,
    x_i_parties_tbl          OUT NOCOPY csi_process_txn_grp.txn_i_parties_tbl,
    x_ip_accounts_tbl        OUT NOCOPY csi_process_txn_grp.txn_ip_accounts_tbl,
    x_org_units_tbl          OUT NOCOPY csi_process_txn_grp.txn_org_units_tbl,
    x_ext_attrib_values_tbl  OUT NOCOPY csi_process_txn_grp.txn_ext_attrib_values_tbl,
    x_pricing_attribs_tbl    OUT NOCOPY csi_process_txn_grp.txn_pricing_attribs_tbl,
    x_instance_asset_tbl     OUT NOCOPY csi_process_txn_grp.txn_instance_asset_tbl,
    x_ii_relationships_tbl   OUT NOCOPY csi_process_txn_grp.txn_ii_relationships_tbl,
    x_dest_location_rec      OUT NOCOPY csi_process_txn_grp.dest_location_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS

    --Hard Coded Values
    l_transaction_type_id    number       := 53;
    l_txn_sub_type_id        number       := 38;
    l_sub_type_rec           csi_txn_sub_types%rowtype;

    l_internal_party_id      number;
    l_master_organization_id number;
    l_rma_order_rec          mtl_trx_type;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);

    l_txn_rec                csi_datastructures_pub.transaction_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_process_tables_NOTD');

    get_dflt_sub_type_id(
      p_transaction_type_id => l_transaction_type_id,
      x_sub_type_id         => l_txn_sub_type_id,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    IF p_mtl_txn_tbl.COUNT > 0 THEN
      FOR l_ind IN p_mtl_txn_tbl.FIRST .. p_mtl_txn_tbl.LAST
      LOOP

        IF l_ind = 1 THEN

         get_rma_info(
           p_transaction_id  => p_mtl_txn_tbl(l_ind).transaction_id,
           x_mtl_trx_type    => l_rma_order_rec,
           x_error_message   => l_error_message,
           x_return_status   => l_return_status);

          get_master_organization_id(
            p_organization_id        => p_mtl_txn_tbl(l_ind).organization_id,
            x_master_organization_id => l_master_organization_id,
            x_return_status          => l_return_status);

          l_dest_location_rec.location_type_code    := 'INVENTORY';
          l_dest_location_rec.location_id           := p_mtl_txn_tbl(l_ind).inv_location_id;
          l_dest_location_rec.inv_organization_id   := p_mtl_txn_tbl(l_ind).organization_id;
          l_dest_location_rec.inv_subinventory_name := p_mtl_txn_tbl(l_ind).subinventory_code;
          l_dest_location_rec.inv_locator_id        := p_mtl_txn_tbl(l_ind).locator_id;
          --
          --
          l_txn_rec.inv_material_transaction_id := p_mtl_txn_tbl(l_ind).transaction_id;
          l_txn_rec.transaction_quantity     := p_mtl_txn_tbl(l_ind).transaction_quantity;
          l_txn_rec.transaction_uom_code     := p_mtl_txn_tbl(l_ind).transaction_uom;
          l_txn_rec.source_transaction_date  := p_mtl_txn_tbl(l_ind).transaction_date;
          l_txn_rec.transaction_date         := sysdate;
          l_txn_rec.transaction_type_id      := l_transaction_type_id;
          l_txn_rec.txn_sub_type_id          := l_txn_sub_type_id;

          get_sub_type_rec(
            p_transaction_type_id => l_txn_rec.transaction_type_id,
            p_sub_type_id         => l_txn_rec.txn_sub_type_id,
            x_sub_type_rec        => l_sub_type_rec,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

          l_txn_rec.source_header_ref    := l_rma_order_rec.source_header_ref;
          l_txn_rec.source_header_ref_id := l_rma_order_rec.source_header_id;
          l_txn_rec.source_line_ref      := l_rma_order_rec.source_line_ref;
          l_txn_rec.source_line_ref_id   := p_mtl_txn_tbl(l_ind).oe_line_id;
          l_txn_rec.transaction_status_code := 'PENDING';

        END IF;
        --
        l_instances_tbl(l_ind).ib_txn_segment_flag    := 'S';
        l_instances_tbl(l_ind).actual_return_date     := p_mtl_txn_tbl(l_ind).transaction_date;
        l_instances_tbl(l_ind).return_by_date         := null;
        l_instances_tbl(l_ind).instance_id            := p_mtl_txn_tbl(l_ind).instance_id;
        l_instances_tbl(l_ind).inventory_item_id      := p_mtl_txn_tbl(l_ind).inventory_item_id;
        l_instances_tbl(l_ind).quantity               := p_mtl_txn_tbl(l_ind).instance_quantity;
        l_instances_tbl(l_ind).vld_organization_id    := p_mtl_txn_tbl(l_ind).organization_id;
        l_instances_tbl(l_ind).inventory_revision     := p_mtl_txn_tbl(l_ind).revision;
        l_instances_tbl(l_ind).inv_master_organization_id := l_master_organization_id;
        l_instances_tbl(l_ind).last_oe_rma_line_id    := p_mtl_txn_tbl(l_ind).oe_line_id;
        l_instances_tbl(l_ind).object_version_number  := 1.0;

        l_instances_tbl(l_ind).serial_number := p_mtl_txn_tbl(l_ind).serial_number;
        l_instances_tbl(l_ind).lot_number    := p_mtl_txn_tbl(l_ind).lot_number; -- added Self Bug shegde.
        --l_instances_tbl(l_ind).location_type_code := 'HZ_PARTY_SITES';
        --l_instances_tbl(l_ind).instance_usage_code := 'IN_INVENTORY';
        l_instances_tbl(l_ind).mtl_txn_creation_date := nvl(p_mtl_txn_tbl(l_ind).mtl_txn_creation_date,sysdate);--bug4026148
        IF nvl(p_mtl_txn_tbl(l_ind).serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
          l_instances_tbl(l_ind).mfg_serial_number_flag := 'N';
        ELSE
          l_instances_tbl(l_ind).mfg_serial_number_flag := 'Y';
        END IF;

        l_instances_tbl(l_ind).unit_of_measure        := p_mtl_txn_tbl(l_ind).primary_uom_code;

        -- check_and_break relation
        IF (nvl(l_instances_tbl(l_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
            AND
            l_instances_tbl(l_ind).mfg_serial_number_flag = 'Y' )
           OR
            -- for non serial configured item break it from the ato model
            nvl(p_item_control_rec.model_item_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN

          -- Moved the routine to process txn pvt to avoid circular dependancy
          -- introduced in that routine for bug 2373109 and also to not load rma
          -- receipt for Non RMA txns . shegde. Bug 2443204

          csi_process_txn_pvt.check_and_break_relation(
            p_instance_id   => l_instances_tbl(l_ind).instance_id,
            p_csi_txn_rec   => l_txn_rec,
            x_return_status => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;
      END LOOP;

    END IF;

    x_txn_rec                := l_txn_rec;
    x_instances_tbl          := l_instances_tbl;
    x_i_parties_tbl          := l_i_parties_tbl;
    x_ip_accounts_tbl        := l_ip_accounts_tbl;
    x_org_units_tbl          := l_org_units_tbl;
    x_ext_attrib_values_tbl  := l_ext_attrib_values_tbl;
    x_pricing_attribs_tbl    := l_pricing_attribs_tbl;
    x_instance_asset_tbl     := l_instance_asset_tbl;
    x_ii_relationships_tbl   := l_ii_relationships_tbl;
    x_dest_location_rec      := l_dest_location_rec;

  END build_process_tables_NOTD;

/* corrected the following routines  match_mtl_txn_for_txn_dtl, split_mtl_txn_tbl, sync_txn_dtls_and_mtl_txn
   for bug 3094905 . updated routines are as below */

  PROCEDURE match_mtl_txn_for_txn_dtl(
    px_txn_dtl_rec          IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_mtl_txn_tbl          IN OUT NOCOPY mtl_txn_tbl,
    px_tld_inst_tbl         IN OUT NOCOPY tld_inst_tbl,
    p_item_control_rec      IN item_control_rec,
    p_match_qty             IN number,
    x_match_flag               OUT NOCOPY varchar2,
    x_match_basis              OUT NOCOPY varchar2,
    x_return_status            OUT NOCOPY varchar2)
  IS
    l_mtl_txn_rec              mtl_txn_rec;
    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_inst_qty                 number;
    i_index                    number := 0;
    l_found                    varchar2(1) := 'N';
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('match_mtl_txn_for_txn_dtl');

    x_match_flag  := 'N';
    x_match_basis := null;

    /* try matching with lot and serial attributes */
    IF px_mtl_txn_tbl.COUNT > 0 THEN
      FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
      LOOP

        IF nvl(px_mtl_txn_tbl(l_ind).lot_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
           AND
           nvl(px_mtl_txn_tbl(l_ind).serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
        THEN

          IF px_mtl_txn_tbl(l_ind).verified_flag <> 'Y' THEN

            IF (nvl(px_txn_dtl_rec.serial_number, fnd_api.g_miss_char ) =
                nvl(px_mtl_txn_tbl(l_ind).serial_number , fnd_api.g_miss_char ) )
               AND
               (nvl(px_txn_dtl_rec.lot_number, fnd_api.g_miss_char ) =
                nvl(px_mtl_txn_tbl(l_ind).lot_number , fnd_api.g_miss_char ) )
            THEN
              x_match_flag  := 'Y';
              x_match_basis := 'ALL_ATTRIBUTES';
              px_mtl_txn_tbl(l_ind).verified_flag      := 'Y';
              px_mtl_txn_tbl(l_ind).instance_id        := px_txn_dtl_rec.instance_id;
              px_mtl_txn_tbl(l_ind).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
              px_mtl_txn_tbl(l_ind).sub_type_id        := px_txn_dtl_rec.sub_type_id;
              l_mtl_txn_rec := px_mtl_txn_tbl(l_ind);
              exit;
            END IF;
          END IF;
        END IF;
      END LOOP;

      IF x_match_flag = 'N' THEN

        /* try matching with serial number alone */
        FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
        LOOP
          IF nvl(px_mtl_txn_tbl(l_ind).lot_number, fnd_api.g_miss_char) = fnd_api.g_miss_char
             AND
             nvl(px_mtl_txn_tbl(l_ind).serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
          THEN
            IF px_mtl_txn_tbl(l_ind).verified_flag <> 'Y' THEN
              IF nvl(px_txn_dtl_rec.serial_number, fnd_api.g_miss_char ) =
                 nvl(px_mtl_txn_tbl(l_ind).serial_number , fnd_api.g_miss_char )
              THEN
                x_match_flag  := 'Y';
                x_match_basis := 'SRL_ATTRIBUTE';
                px_mtl_txn_tbl(l_ind).verified_flag      := 'Y';
                px_mtl_txn_tbl(l_ind).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
                px_mtl_txn_tbl(l_ind).sub_type_id        := px_txn_dtl_rec.sub_type_id;
                l_mtl_txn_rec := px_mtl_txn_tbl(l_ind);
                IF nvl(px_txn_dtl_rec.instance_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                 debug('Entered txn line detail has null Instance_ID. Trying to identify one.');

		 -- Add if condition for bug 7207346, only call identify_source_instance for serial controled items

		  IF p_item_control_rec.serial_control_code <> 1 THEN
                  identify_source_instance(
                    px_mtl_txn_rec    => px_mtl_txn_tbl(l_ind),
                    p_item_control_rec => p_item_control_rec,
                    x_return_status   => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    raise fnd_api.g_exc_error;
                  END IF;
		  end if;
                ELSE
                  px_mtl_txn_tbl(l_ind).instance_id        := px_txn_dtl_rec.instance_id;
                END IF;
                exit;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;

      IF x_match_flag = 'N' THEN

        /* try matching with lot number alone */
        FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
        LOOP
         IF nvl(px_mtl_txn_tbl(l_ind).lot_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char AND
          ( nvl(px_mtl_txn_tbl(l_ind).serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char OR    -- Added for bug 4244887
              nvl(px_txn_dtl_rec.serial_number, fnd_api.g_miss_char ) <> fnd_api.g_miss_char) THEN    -- Added for bug 4244887
          IF nvl(px_txn_dtl_rec.lot_number, fnd_api.g_miss_char ) =
                    nvl(px_mtl_txn_tbl(l_ind).lot_number , fnd_api.g_miss_char)
             AND px_mtl_txn_tbl(l_ind).instance_quantity >= ABS(px_txn_dtl_rec.quantity) -- self bug. Added GT sign
          THEN
            IF px_mtl_txn_tbl(l_ind).verified_flag <> 'Y' THEN
              IF nvl(px_txn_dtl_rec.lot_number, fnd_api.g_miss_char ) =
                 nvl(px_mtl_txn_tbl(l_ind).lot_number , fnd_api.g_miss_char )
              THEN
                x_match_flag  := 'Y';
                x_match_basis := 'LOT_ATTRIBUTE';
                IF px_mtl_txn_tbl(l_ind).transaction_quantity >= p_match_qty THEN
                    px_mtl_txn_tbl(l_ind).verified_flag := 'Y';
                END IF;
                px_mtl_txn_tbl(l_ind).instance_id   := px_txn_dtl_rec.instance_id;
                px_mtl_txn_tbl(l_ind).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
                px_mtl_txn_tbl(l_ind).sub_type_id        := px_txn_dtl_rec.sub_type_id;
                --fix for bug5159276
		identify_source_instance(
                    px_mtl_txn_rec    => px_mtl_txn_tbl(l_ind),
                    p_item_control_rec => p_item_control_rec,
                    x_return_status   => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    raise fnd_api.g_exc_error;
                  END IF;
		l_mtl_txn_rec := px_mtl_txn_tbl(l_ind);
		--end of fix for bug5159276
                exit;
              END IF;
            END IF;
          END IF;
         END IF;
        END LOOP;

      END IF;

      IF x_match_flag = 'N' THEN
        /* try matching with quantity */
        l_found := 'N';

        FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
        LOOP
	 IF nvl(px_txn_dtl_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          IF nvl(p_item_control_rec.mult_srl_control_flag, fnd_api.g_miss_char) = 'Y' THEN
           IF p_item_control_rec.serial_control_code <> 1 THEN
            IF nvl(px_txn_dtl_rec.serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
             debug('Serial control codes are different. Non serial item instances referenced');
             IF px_mtl_txn_tbl(l_ind).verified_flag <> 'Y' THEN
              i_index := NVL(px_tld_inst_tbl.LAST,0) + 1 ;
              IF px_tld_inst_tbl.count > 0 THEN
               debug('Transaction Details count: '||px_tld_inst_tbl.count);
               For i in px_tld_inst_tbl.FIRST ..px_tld_inst_tbl.LAST Loop
                 IF px_tld_inst_tbl(i).txn_line_detail_id = px_txn_dtl_rec.txn_line_detail_id THEN
                   l_found := 'Y';
                 END IF;
               End Loop;
              END IF;
              IF l_found <> 'Y' THEN
                   px_tld_inst_tbl(i_index).instance_id := px_txn_dtl_rec.instance_id;
                   px_tld_inst_tbl(i_index).inventory_item_id := px_txn_dtl_rec.inventory_item_id;
                   px_tld_inst_tbl(i_index).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
                   px_tld_inst_tbl(i_index).sub_type_id := px_txn_dtl_rec.sub_type_id;
                   px_tld_inst_tbl(i_index).quantity := px_txn_dtl_rec.quantity;
                   px_tld_inst_tbl(i_index).serial_number := px_txn_dtl_rec.serial_number;
                   px_tld_inst_tbl(i_index).lot_number := px_txn_dtl_rec.lot_number;
                   px_tld_inst_tbl(i_index).verified_flag := 'Y';
              END IF;
             END IF;
            END IF;
           ELSE
           -- Non serialized
            IF nvl(px_txn_dtl_rec.serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
            THEN
             debug('Serial control codes are different. Serialized item instances referenced');
             debug('Transaction Details count: '||px_tld_inst_tbl.count);
             IF px_tld_inst_tbl.count > 0 THEN
               i_index := NVL(px_tld_inst_tbl.LAST,0) + 1 ;
               For i in px_tld_inst_tbl.FIRST ..px_tld_inst_tbl.LAST Loop
                 IF px_tld_inst_tbl(i).txn_line_detail_id <> px_txn_dtl_rec.txn_line_detail_id THEN
                   px_tld_inst_tbl(i_index).instance_id := px_txn_dtl_rec.instance_id;
                   px_tld_inst_tbl(i_index).inventory_item_id := px_txn_dtl_rec.inventory_item_id;
                   px_tld_inst_tbl(i_index).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
                   px_tld_inst_tbl(i_index).sub_type_id := px_txn_dtl_rec.sub_type_id;
                   px_tld_inst_tbl(i_index).quantity := px_txn_dtl_rec.quantity;
                   px_tld_inst_tbl(i_index).serial_number := px_txn_dtl_rec.serial_number;
                   px_tld_inst_tbl(i_index).lot_number := px_txn_dtl_rec.lot_number;
                   px_tld_inst_tbl(i_index).verified_flag := 'Y';
                   x_match_flag := 'Y';  -- Added For BUG 4244887
                   px_tld_inst_tbl(i_index).mtl_txn_creation_date := px_mtl_txn_tbl(l_ind).mtl_txn_creation_date; --bug4026148
                 END IF;
               End Loop;
             ELSE
                   px_tld_inst_tbl(1).instance_id := px_txn_dtl_rec.instance_id;
                   px_tld_inst_tbl(1).inventory_item_id := px_txn_dtl_rec.inventory_item_id;
                   px_tld_inst_tbl(1).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
                   px_tld_inst_tbl(1).sub_type_id := px_txn_dtl_rec.sub_type_id;
                   px_tld_inst_tbl(1).quantity := px_txn_dtl_rec.quantity;
                   px_tld_inst_tbl(1).serial_number := px_txn_dtl_rec.serial_number;
                   px_tld_inst_tbl(1).lot_number := px_txn_dtl_rec.lot_number;
                   px_tld_inst_tbl(1).verified_flag := 'Y';
                   x_match_flag := 'Y';  -- Added For BUG 4244887
                   px_tld_inst_tbl(1).mtl_txn_creation_date := px_mtl_txn_tbl(l_ind).mtl_txn_creation_date;--bug4026148
             END IF;
            END IF;
           END IF;
          END IF;
          IF px_mtl_txn_tbl(l_ind).verified_flag <> 'Y' THEN
            IF nvl(abs(px_txn_dtl_rec.quantity), fnd_api.g_miss_num ) =
               nvl(px_mtl_txn_tbl(l_ind).instance_quantity , fnd_api.g_miss_num ) AND
               nvl(px_mtl_txn_tbl(l_ind).serial_number,fnd_api.g_miss_char)= fnd_api.g_miss_char THEN  -- Added For BUG 4244887

              px_mtl_txn_tbl(l_ind).instance_id        := px_txn_dtl_rec.instance_id;
              px_mtl_txn_tbl(l_ind).txn_line_detail_id := px_txn_dtl_rec.txn_line_detail_id;
              px_mtl_txn_tbl(l_ind).sub_type_id        := px_txn_dtl_rec.sub_type_id;
              IF p_item_control_rec.serial_control_code <> 1
			    OR p_item_control_rec.lot_control_code = 2 THEN
                -- get the instance_id for the transaction serial / Lot  number
                debug('Serial / Lot  number specified is not the serial / Lot  received. ');
                identify_source_instance(
                  px_mtl_txn_rec    => px_mtl_txn_tbl(l_ind),
                  p_item_control_rec => p_item_control_rec,
                  x_return_status   => l_return_status);
                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     px_mtl_txn_tbl(l_ind).verified_flag      := 'N';
			      x_match_flag  := 'N';
			      l_mtl_txn_rec := px_mtl_txn_tbl(l_ind);
                ELSE
                  x_match_flag  := 'Y';
                  x_match_basis := 'MTL_ATTRIBUTE';
                  px_mtl_txn_tbl(l_ind).verified_flag := 'Y';
                END IF;
                IF px_mtl_txn_tbl(l_ind).instance_id = fnd_api.g_miss_num THEN
                  px_mtl_txn_tbl(l_ind).instance_id := NULL;
                END IF;
              ELSIF nvl(px_txn_dtl_rec.serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
                  x_match_flag  := 'Y';
                  x_match_basis := 'QTY_ATTRIBUTE';
                  IF px_mtl_txn_tbl(l_ind).transaction_quantity >= p_match_qty THEN
                        px_mtl_txn_tbl(l_ind).verified_flag := 'Y';
                  END IF;

              END IF;
              l_mtl_txn_rec := px_mtl_txn_tbl(l_ind);
              exit;
            END IF;
          END IF;
	 END IF;
        END LOOP;
      END IF;
    END IF;

    IF x_match_flag = 'Y' THEN
      debug ('Match Basis:'||x_match_basis);

/*-- Added filer conditions for bug 4006563 --*/
      IF (p_item_control_rec.lot_control_code = 2 AND px_txn_dtl_rec.lot_number = l_mtl_txn_rec.lot_number) OR
         (p_item_control_rec.serial_control_code <> 1 AND px_txn_dtl_rec.serial_number = l_mtl_txn_rec.serial_number) OR
         (p_item_control_rec.serial_control_code = 1 AND p_item_control_rec.lot_control_code = 1)
      THEN
          px_txn_dtl_rec.processing_status      := 'IN_PROCESS';
      END IF;

/*-- End: Added filer conditions for bug 4006563 --*/

--    px_txn_dtl_rec.quantity               := l_mtl_txn_rec.instance_quantity;
      IF l_mtl_txn_rec.instance_id <> fnd_api.g_miss_num THEN
       IF p_item_control_rec.serial_control_code = 1 THEN -- non serilized / lot
	    Begin
		Select quantity
		into l_inst_qty
		from csi_item_instances
		where instance_id = l_mtl_txn_rec.instance_id
		and sysdate between nvl(active_end_date, sysdate-1) and sysdate+1;
	    Exception when others then
		   fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
		   fnd_message.set_token('API_NAME','match_mtl_txn_for_txn_dtl');
		   fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 240));
		   fnd_msg_pub.add;
		   raise fnd_api.g_exc_error;
	    End;

	    IF p_item_control_rec.lot_control_code = 2 THEN
             IF l_inst_qty  < l_mtl_txn_rec.instance_quantity THEN -- self bug
		    px_txn_dtl_rec.quantity  := (-1 * l_inst_qty); -- matching for the max allowed inst qty
	     END IF;
            ELSE
	        px_txn_dtl_rec.quantity  := ( -1 * l_mtl_txn_rec.transaction_quantity);
            END IF;
       ELSE
		  px_txn_dtl_rec.quantity  := -1; -- serialized item
       END IF;
      END IF;
/*-- Commented as part of bug 4244887
      px_txn_dtl_rec.lot_number             := l_mtl_txn_rec.lot_number;
      px_txn_dtl_rec.serial_number          := l_mtl_txn_rec.serial_number;
      px_txn_dtl_rec.inv_mtl_transaction_id := l_mtl_txn_rec.transaction_id;
      px_txn_dtl_rec.instance_id            := l_mtl_txn_rec.instance_id;
*/

/*-- Added filter condition for bug 4244887 --*/
      IF (p_item_control_rec.lot_control_code = 2 AND px_txn_dtl_rec.lot_number = l_mtl_txn_rec.lot_number) OR
         (p_item_control_rec.serial_control_code <> 1 AND px_txn_dtl_rec.serial_number = l_mtl_txn_rec.serial_number) OR
         (px_txn_dtl_rec.processing_status = 'IN_PROCESS') OR
         (p_item_control_rec.serial_control_code = 1 AND p_item_control_rec.lot_control_code = 1 AND x_match_flag = 'Y')
      THEN
          px_txn_dtl_rec.inv_mtl_transaction_id := l_mtl_txn_rec.transaction_id;
          px_txn_dtl_rec.instance_id            := l_mtl_txn_rec.instance_id;
  	  --fix for bug5159276
	  px_txn_dtl_rec.lot_number             := l_mtl_txn_rec.lot_number;
	  px_txn_dtl_rec.serial_number          := l_mtl_txn_rec.serial_number;
          --end of fix for bug5159276
      END IF;
/*--End: Added filter condition for bug 4244887 --*/

    ELSE
      debug('Could not match the entered installation details with the material txn info.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END match_mtl_txn_for_txn_dtl;


  PROCEDURE split_mtl_txn_tbl(
    px_line_dtl_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_mtl_txn_tbl      IN OUT NOCOPY mtl_txn_tbl,
    p_item_control_rec  IN item_control_rec,
    x_return_status        OUT NOCOPY varchar2)
  IS
    l_new_quantity  number;
    l_new_ind       binary_integer := 0;
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN

    api_log('split_mtl_txn_tbl');

    IF px_line_dtl_tbl.COUNT > 0 THEN
      FOR l_t_ind IN px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
      LOOP

        IF px_mtl_txn_tbl.count > 0 THEN
          FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
          LOOP
            IF px_mtl_txn_tbl(l_ind).verified_flag <> 'Y' THEN
              l_new_quantity :=  px_mtl_txn_tbl(l_ind).instance_quantity -
                                 abs(px_line_dtl_tbl(l_t_ind).quantity);
             IF nvl(px_mtl_txn_tbl(l_ind).instance_id, fnd_api.g_miss_num)
                      = fnd_api.g_miss_num
               AND ( p_item_control_rec.serial_control_code <> 1) THEN

                identify_source_instance(
                     px_mtl_txn_rec    => px_mtl_txn_tbl(l_ind),
                     p_item_control_rec => p_item_control_rec,
                     x_return_status   => l_return_status);
             END IF;
             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                raise fnd_api.g_exc_error;
             END IF;
--              px_mtl_txn_tbl(l_ind).instance_id   := px_line_dtl_tbl(l_t_ind).instance_id;
             IF p_item_control_rec.serial_control_code = 1 THEN
	      IF p_item_control_rec.lot_control_code <> 1 THEN
	       IF nvl(px_line_dtl_tbl(l_t_ind).lot_number, fnd_api.g_miss_char )
                 = nvl(px_mtl_txn_tbl(l_ind).lot_number , fnd_api.g_miss_char ) THEN
                  px_mtl_txn_tbl(l_ind).instance_id   := px_line_dtl_tbl(l_t_ind).instance_id;
	       ELSE
		  l_return_status  := fnd_api.g_ret_sts_error;
		  debug('Lot number referenced on the transaction line detail is different from the one being received..');
		  fnd_message.set_name('CSI','CSI_TXN_PARAM_IGNORED_WARN');
		  fnd_message.set_token('PARAM','Lot Number');
		  fnd_message.set_token('VALUE',px_line_dtl_tbl(l_t_ind).lot_number);
		  fnd_message.set_token('REASON','The Lot number and/or instance referenced on the transaction details is different from the one received. Pl. correct it and reprocess the error');
		  fnd_msg_pub.add;
		  raise fnd_api.g_exc_error;
	       END IF;
	      ELSE
	          px_mtl_txn_tbl(l_ind).instance_id   := px_line_dtl_tbl(l_t_ind).instance_id;
                  px_line_dtl_tbl(l_t_ind).processing_status := 'IN_PROCESS';
	      END IF;
	     END IF;

              px_mtl_txn_tbl(l_ind).instance_quantity := abs(px_line_dtl_tbl(l_t_ind).quantity);
              px_mtl_txn_tbl(l_ind).txn_line_detail_id := px_line_dtl_tbl(l_t_ind).txn_line_detail_id;
              px_mtl_txn_tbl(l_ind).verified_flag := 'Y';
              IF l_new_quantity > 0 THEN
                l_new_ind := px_mtl_txn_tbl.count + 1;
                px_mtl_txn_tbl(l_new_ind) := px_mtl_txn_tbl(l_ind);

                px_mtl_txn_tbl(l_new_ind).instance_id := null;
                px_mtl_txn_tbl(l_new_ind).instance_quantity := l_new_quantity;
                px_mtl_txn_tbl(l_new_ind).verified_flag := 'N';
              END IF;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
   Exception
     when fnd_api.g_exc_error then
       debug('fnd_api.g_exc_error raised in split_mtl_txn_tbl');
       x_return_status := l_return_status;
  END split_mtl_txn_tbl;

  PROCEDURE sync_txn_dtls_and_mtl_txn(
    px_mtl_txn_tbl          IN OUT NOCOPY  mtl_txn_tbl,
    px_line_dtl_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_tld_inst_tbl             OUT NOCOPY tld_inst_tbl,
    p_item_control_rec      IN item_control_rec,
    x_return_status            OUT NOCOPY varchar2)
  IS

    l_mtl_txn_tbl           mtl_txn_tbl;
    l_mtl_txn_qty           number := 0;
    l_txn_dtl_qty           number := 0;
    l_oe_line_id            number;

    l_line_dtl_rec          csi_t_datastructures_grp.txn_line_detail_rec;
    l_match_flag            varchar2(1) := 'N';
    l_match_basis           varchar2(30);
    l_matched_quantity      number := 0;

    l_u_txn_line_rec        csi_t_datastructures_grp.txn_line_rec;
    l_u_line_dtl_tbl        csi_t_datastructures_grp.txn_line_detail_tbl;
    l_u_pty_dtl_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_u_pty_acct_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_u_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_u_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_u_eav_tbl             csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

    u_td_ind                binary_integer;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);
    l_new_ind               binary_integer := 0;
    l_tld_inst_tbl          tld_inst_tbl;
    l_txn_sub_type_id       number;              -- Added for bug 4244887

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('sync_txn_dtls_and_mtl_txn');

    l_mtl_txn_tbl := px_mtl_txn_tbl;

    l_mtl_txn_qty := 0;
    u_td_ind  := 0;

    IF l_mtl_txn_tbl.COUNT > 0 THEN
      l_mtl_txn_qty := l_mtl_txn_tbl(1).mmt_primary_quantity;
      l_oe_line_id  := l_mtl_txn_tbl(1).oe_line_id;
    END IF;
    /* this logic takes the txn details and mtl txns in case of lot controlled items and if there are many-many */
    /* and a mismatch in the number of records,with the number of inv txn records being more than the txn details */
    /* then it just splits and matches them */
    IF p_item_control_rec.serial_control_code = 1
      AND p_item_control_rec.lot_control_code = 2 THEN -- lot controlled item
	IF ( ( px_line_dtl_tbl.COUNT > 1 AND px_mtl_txn_tbl.count > 1)
	 AND (px_line_dtl_tbl.COUNT <> px_mtl_txn_tbl.count)) THEN
	  IF px_line_dtl_tbl.COUNT > px_mtl_txn_tbl.count THEN
	     debug('Multiple Lots being received and Multiple transaction details entered');
	  -- split the txn details upfront to match the mtl txns first.
	    FOR l_td_ind IN px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
	    LOOP
	      FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
	      LOOP
	       IF nvl(px_mtl_txn_tbl(l_ind).lot_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
                IF px_mtl_txn_tbl(l_ind).verified_flag = 'N' THEN
		 IF nvl(px_line_dtl_tbl(l_td_ind).lot_number, fnd_api.g_miss_char )
                   = nvl(px_mtl_txn_tbl(l_ind).lot_number , fnd_api.g_miss_char ) THEN
		    IF px_mtl_txn_tbl(l_ind).instance_quantity > abs(px_line_dtl_tbl(l_td_ind).quantity) THEN
		       l_new_ind := px_mtl_txn_tbl.count + 1;
		       px_mtl_txn_tbl(l_new_ind) := px_mtl_txn_tbl(l_ind);
		       px_mtl_txn_tbl(l_new_ind).instance_quantity :=
		         (px_mtl_txn_tbl(l_ind).instance_quantity - abs(px_line_dtl_tbl(l_td_ind).quantity));
		       px_mtl_txn_tbl(l_new_ind).verified_flag := 'N';
		       px_mtl_txn_tbl(l_ind).verified_flag := 'S';
		       px_mtl_txn_tbl(l_ind).instance_quantity := abs(px_line_dtl_tbl(l_td_ind).quantity);
		    END IF;
		 END IF;
		END IF;
	       END IF;
              END LOOP;
	    END LOOP;
	  END IF;
	END IF;
    END IF;

    /* this logic is to filter the txn line details for the processing quantity */

    IF px_line_dtl_tbl.COUNT > 0 THEN
      FOR l_ind IN px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
      LOOP

        l_txn_dtl_qty := l_txn_dtl_qty + abs(px_line_dtl_tbl(l_ind).quantity);

	IF  px_line_dtl_tbl(l_ind).processing_status <>'PROCESSED' THEN --4201911

        match_mtl_txn_for_txn_dtl(
          px_txn_dtl_rec     => px_line_dtl_tbl(l_ind),
          px_mtl_txn_tbl     => px_mtl_txn_tbl,
          px_tld_inst_tbl    => x_tld_inst_tbl,
          p_item_control_rec => p_item_control_rec,
          p_match_qty        => l_matched_quantity,
          x_match_flag       => l_match_flag,
          x_match_basis      => l_match_basis,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
		      debug('Errors  while matching txn del with mtl txn.');
		      RAISE fnd_api.g_exc_error;
	 END IF;

	 END IF;

        IF l_match_flag = 'Y' THEN

          l_txn_sub_type_id := px_line_dtl_tbl(l_ind).sub_type_id;  -- Added for bug 4244887
          u_td_ind := u_td_ind + 1;
          l_u_line_dtl_tbl(u_td_ind).txn_line_detail_id := px_line_dtl_tbl(l_ind).txn_line_detail_id;
          l_u_line_dtl_tbl(u_td_ind).processing_status  := px_line_dtl_tbl(l_ind).processing_status;
          l_u_line_dtl_tbl(u_td_ind).inventory_item_id  := px_line_dtl_tbl(l_ind).inventory_item_id;
          l_u_line_dtl_tbl(u_td_ind).inv_organization_id  := px_line_dtl_tbl(l_ind).inv_organization_id;
          l_u_line_dtl_tbl(u_td_ind).quantity           := px_line_dtl_tbl(l_ind).quantity;
          l_u_line_dtl_tbl(u_td_ind).lot_number         := px_line_dtl_tbl(l_ind).lot_number;
          l_u_line_dtl_tbl(u_td_ind).serial_number      := px_line_dtl_tbl(l_ind).serial_number;
          l_u_line_dtl_tbl(u_td_ind).inventory_revision := px_line_dtl_tbl(l_ind).inventory_revision;
          l_u_line_dtl_tbl(u_td_ind).instance_id        := px_line_dtl_tbl(l_ind).instance_id;
          l_matched_quantity := abs(l_u_line_dtl_tbl(u_td_ind).quantity) + l_matched_quantity;

        END IF;
        /*-- Added for bug 4244887 --*/
        IF l_mtl_txn_qty = l_matched_quantity THEN
           EXIT;
        END IF;
        /*--End: Added for bug 4244887 --*/

      END LOOP;

	  debug('Match Flag: '||l_match_flag);

      IF px_mtl_txn_tbl.COUNT > 0 THEN
        FOR m_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
        LOOP
           /*-- Added for bug 4244887 --*/ -- Assigning sub-type to mtl_txn table if sub-type is null
            IF nvl(px_mtl_txn_tbl(m_ind).sub_type_id,fnd_api.g_miss_num) = fnd_api.g_miss_num AND
               l_txn_sub_type_id IS NOT NULL THEN
               px_mtl_txn_tbl(m_ind).sub_type_id  := l_txn_sub_type_id;
            END IF;
           /*-- End: Added for bug 4244887 --*/

            IF px_mtl_txn_tbl(m_ind).verified_flag = 'N' THEN
                l_match_flag := 'N';
            END IF;
        END LOOP;
      END IF;

	  debug('Matched Qty: '||l_matched_quantity||' Mtl txn Qty: '||l_mtl_txn_qty);
      /*-- Added for bug 4244887 --*/
      IF l_mtl_txn_qty = l_matched_quantity AND
         l_match_flag = 'N' THEN
	  debug('Quantity matched setting match flag to Y');
         l_match_flag := 'Y';   -- This is done so that transaction details can be updated
      END IF;
     /*-- End: Added for bug 4244887 --*/

      IF l_matched_quantity = l_mtl_txn_qty AND l_match_flag <> 'N' THEN
        -- update the transaction line detail table with the IN_PROCESS status
        l_u_txn_line_rec.transaction_line_id := px_line_dtl_tbl(1).transaction_line_id;

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

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Update txn line dtls failed while matching txn del with mtl txn.');
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE

        debug('Transaction Details could not be matched with the material transaction info.');

        IF l_txn_dtl_qty = l_mtl_txn_qty THEN
          IF px_mtl_txn_tbl.COUNT = 1 AND px_line_dtl_tbl.COUNT > 1 THEN
            px_mtl_txn_tbl(1).verified_flag := 'N';
            debug ('Splitting material transaction records to make in sync with txn dtls.');

            split_mtl_txn_tbl(
              px_line_dtl_tbl => px_line_dtl_tbl,
              px_mtl_txn_tbl  => px_mtl_txn_tbl,
              p_item_control_rec  => p_item_control_rec,
		      x_return_status => l_return_status);

	    IF l_return_status <> fnd_api.g_ret_sts_success THEN
	       raise fnd_api.g_exc_error;
	    END IF;
        --  END IF;

          /*
          dump_mtl_txn_tbl(
            p_mtl_txn_tbl => px_mtl_txn_tbl);
          */

          ELSIF px_mtl_txn_tbl.COUNT > 1 AND px_line_dtl_tbl.COUNT = 1 THEN
            debug('Using the same txn line detail attribute for all the material txn records');
            FOR l_ind IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
            LOOP
              IF p_item_control_rec.serial_control_code <> 1
               OR p_item_control_rec.lot_control_code = 2 THEN

                 identify_source_instance(
                  px_mtl_txn_rec    => px_mtl_txn_tbl(l_ind),
                  p_item_control_rec => p_item_control_rec,
                  x_return_status   => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  raise fnd_api.g_exc_error;
                END IF;
                IF nvl(px_mtl_txn_tbl(l_ind).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                 AND px_line_dtl_tbl(1).instance_id <> px_mtl_txn_tbl(l_ind).instance_id
                THEN
                   px_line_dtl_tbl(1).instance_id := px_mtl_txn_tbl(l_ind).instance_id;
		 ELSE
		/*Marking the transaction details as IN_PROCESS for the cases where the user
                selects only the transaction sub type and source instance reference is not required
		for bug 4570399*/
		 px_line_dtl_tbl(1).processing_status:='IN_PROCESS';

               --fix for bug 5898987
                      IF px_mtl_txn_tbl(1).instance_id <> fnd_api.g_miss_num THEN
		            px_line_dtl_tbl(1).instance_id := px_mtl_txn_tbl(1).instance_id;
                       ELSE
		            px_line_dtl_tbl(1).instance_id := NULL;
                       END IF;
		px_line_dtl_tbl(1).serial_number := px_mtl_txn_tbl(1).serial_number;
          	--end of fix for bug 5898987
                END IF;
              ELSE
                px_mtl_txn_tbl(l_ind).instance_id        := px_line_dtl_tbl(1).instance_id;
              END IF;

              px_mtl_txn_tbl(l_ind).txn_line_detail_id := px_line_dtl_tbl(1).txn_line_detail_id;
              px_mtl_txn_tbl(l_ind).sub_type_id        := px_line_dtl_tbl(1).sub_type_id;
              px_mtl_txn_tbl(l_ind).verified_flag := 'Y';
            END LOOP;
          --END IF;
        ELSE
          IF px_mtl_txn_tbl.COUNT = 1 AND px_line_dtl_tbl.COUNT = 1 THEN
            debug('same txn line detail and the material txn record');
            IF p_item_control_rec.serial_control_code <> 1
             OR p_item_control_rec.lot_control_code = 2 THEN

                 identify_source_instance(
                  px_mtl_txn_rec    => px_mtl_txn_tbl(1),
                  p_item_control_rec => p_item_control_rec,
                  x_return_status   => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  raise fnd_api.g_exc_error;
                END IF;
                IF nvl(px_mtl_txn_tbl(1).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                 AND px_line_dtl_tbl(1).instance_id <> px_mtl_txn_tbl(1).instance_id
                THEN
                   px_line_dtl_tbl(1).instance_id := px_mtl_txn_tbl(1).instance_id;

		ELSE
		/*Marking the transaction details as IN_PROCESS for the cases where the user
                selects only the transaction sub type and source instance reference is not required
		for bug 4570399*/
		  px_line_dtl_tbl(1).processing_status:='IN_PROCESS';

                END IF;
            ELSE
                px_mtl_txn_tbl(1).instance_id        := px_line_dtl_tbl(1).instance_id;
            END IF;
            px_mtl_txn_tbl(1).txn_line_detail_id := px_line_dtl_tbl(1).txn_line_detail_id;
            px_mtl_txn_tbl(1).sub_type_id        := px_line_dtl_tbl(1).sub_type_id;
            px_mtl_txn_tbl(1).verified_flag      := 'Y';
          ELSIF p_item_control_rec.serial_control_code = 1 THEN -- qty mismatch + txn dtl qty also mismatch with the total mmt qty!!!
		    debug('The combination of Transaction Details entered could not be matched with the multiple material transaction records.');
          /* serialized items should be processed no matter what txn details
             are entered. hence handled separately at the end */
	        l_return_status := fnd_api.g_ret_sts_error;
	        RAISE fnd_api.g_exc_error;
          END IF;
         END IF;
       ELSE -- qty mismatch with txn dtl qty - Error!!
	    debug('Transaction Details quantity does not be match with the material transaction');
         IF p_item_control_rec.lot_control_code = 2 THEN
           IF px_mtl_txn_tbl.COUNT = px_line_dtl_tbl.COUNT THEN --lot's match but qty does not - partial RMA?
	     FOR t IN px_line_dtl_tbl.FIRST .. px_line_dtl_tbl.LAST
	     LOOP
                l_match_flag := 'N' ;
		FOR m IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST
		LOOP
                   IF ( px_mtl_txn_tbl(m).verified_flag <> 'S' and
                        px_line_dtl_tbl(t).instance_id is not null) THEN
	            IF nvl(px_line_dtl_tbl(t).lot_number, fnd_api.g_miss_char )
                      = nvl(px_mtl_txn_tbl(m).lot_number , fnd_api.g_miss_char ) THEN
			    px_line_dtl_tbl(t).quantity := -1*(px_mtl_txn_tbl(m).lot_primary_quantity);
			    px_mtl_txn_tbl(m).verified_flag := 'S';
			    px_mtl_txn_tbl(m).instance_quantity := abs(px_line_dtl_tbl(t).quantity);
                            px_mtl_txn_tbl(m).instance_id := px_line_dtl_tbl(t).instance_id;
	                    px_line_dtl_tbl(t).processing_status := 'IN_PROCESS';
                            px_mtl_txn_tbl(m).txn_line_detail_id := px_line_dtl_tbl(t).txn_line_detail_id;
                            l_match_flag := 'Y';
		            debug('match basis: '||'MTL_ATTRIBUTE');
                           exit;
		    END IF;
		   END IF;
		END LOOP;
	      END LOOP; -- match_flag = 'Y'
            END IF;
            IF l_match_flag <> 'Y' THEN
       	      l_return_status := fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSIF p_item_control_rec.serial_control_code = 1 THEN
          /* serialized items should be processed no matter what txn details
             are entered. hence handled separately - build_process..*/
		/*ported for bug 3686818-Check For Partial receipt on Non-Serialized Item */
            IF nvl(p_item_control_rec.mult_srl_control_flag,fnd_api.g_miss_char) = 'Y' THEN
              IF x_tld_inst_tbl.count > 0 THEN
                 null;-- process these in the next routine
              END IF;
	    ELSIF px_mtl_txn_tbl.COUNT = 1 AND px_line_dtl_tbl.COUNT = 1 THEN
              IF ( px_line_dtl_tbl(1).instance_id IS NOT NULL
               AND nvl(px_line_dtl_tbl(1).serial_number, fnd_api.g_miss_char) = fnd_api.g_miss_char)  THEN
                   px_line_dtl_tbl(1).quantity := -1*(px_mtl_txn_tbl(1).instance_quantity);
	           px_mtl_txn_tbl(1).verified_flag := 'S';
                   px_mtl_txn_tbl(1).instance_quantity := abs(px_line_dtl_tbl(1).quantity);
                   px_mtl_txn_tbl(1).instance_id := px_line_dtl_tbl(1).instance_id;
	           px_line_dtl_tbl(1).processing_status := 'IN_PROCESS';
                   px_mtl_txn_tbl(1).txn_line_detail_id := px_line_dtl_tbl(1).txn_line_detail_id;
                   l_match_flag := 'Y';
	           debug('match basis: '||'NS_ATTRIBUTE');
              END IF;
            ELSE -- modified for bug 3644297. non serial qty matches need to error out...
	      l_return_status := fnd_api.g_ret_sts_error;
	      RAISE fnd_api.g_exc_error;
            END IF;

	   --Fix for bug 4125459:To take sub transaction type from txn details in the case of partial receipt
           ELSIF p_item_control_rec.serial_control_code <> 1 THEN
                 FOR m IN px_mtl_txn_tbl.FIRST .. px_mtl_txn_tbl.LAST LOOP
		    IF  px_mtl_txn_tbl(m).verified_flag = 'N' THEN
			px_mtl_txn_tbl(m).sub_type_id := px_line_dtl_tbl(1).sub_type_id;
		    END IF;
                 END LOOP;
          END IF;
       END IF;
        -- update the transaction line detail table with the queried instance..
        l_u_txn_line_rec.transaction_line_id := px_line_dtl_tbl(1).transaction_line_id;

        csi_t_txn_details_grp.update_txn_line_dtls(
          p_api_version              => 1.0,
          p_commit                   => fnd_api.g_false,
          p_init_msg_list            => fnd_api.g_true,
          p_validation_level         => fnd_api.g_valid_level_full,
          p_txn_line_rec             => l_u_txn_line_rec,
          p_txn_line_detail_tbl      => px_line_dtl_tbl,
          px_txn_ii_rltns_tbl        => l_u_ii_rltns_tbl,
          px_txn_party_detail_tbl    => l_u_pty_dtl_tbl,
          px_txn_pty_acct_detail_tbl => l_u_pty_acct_tbl,
          px_txn_org_assgn_tbl       => l_u_org_assgn_tbl,
          px_txn_ext_attrib_vals_tbl => l_u_eav_tbl,
          x_return_status            => l_return_status,
          x_msg_count                => l_msg_count,
          x_msg_data                 => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Update txn line dtls failed while matching txn del with mtl txn.');
          RAISE fnd_api.g_exc_error;
        END IF;

     END IF;
    END IF;
   Exception
     when fnd_api.g_exc_error then
       debug('fnd_api.g_exc_error raised in sync_txn_dtls_and_mtl_txn');
       x_return_status := l_return_status;
     when others then
       debug('when others raised in sync_txn_dtls_and_mtl_txn');
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME','sync_txn_dtls_and_mtl_txn');
       fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 240));
       fnd_msg_pub.add;
  END sync_txn_dtls_and_mtl_txn;

  PROCEDURE rma_receipt(
    p_mtl_txn_id          IN  number,
    p_message_id          IN  number,
    x_return_status          OUT NOCOPY varchar2,
    px_trx_error_rec      IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec)
  IS

    l_api_name                  varchar2(30) := 'rma_receipt';
    l_return_status             varchar2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count                 number;
    l_msg_data                  varchar2(2000);

    l_rma_order_rec             mtl_trx_type;

    l_src_mtl_txn_tbl           mtl_txn_tbl;
    l_dest_mtl_txn_tbl          mtl_txn_tbl;
    l_item_control_rec          item_control_rec;

    -- added shegde
    l_src_order_rec             source_order_rec;
    l_mtl_txn_rec               mtl_txn_rec;
    l_sub_type_rec              csi_txn_sub_types%rowtype;
    l_owner_pty_passed          varchar2(1) := 'N';
    l_owner_act_passed          varchar2(1) := 'N';
    i_p_ind                     binary_integer;
    i_pa_ind                    binary_integer;
    l_internal_party_id         number;
    l_cur_owner_party_id        number;
    l_cur_owner_acct_id         number;

    -- added as part of fix for Bug 2733128
    l_chg_instance_rec          csi_datastructures_pub.instance_rec;
    l_chg_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;
    l_chg_ext_attrib_val_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
    l_chg_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_chg_inst_asset_tbl        csi_datastructures_pub.instance_asset_tbl;
    l_chg_inst_id_lst           csi_datastructures_pub.id_tbl;


    l_owner_pty_ip_id           number;
    l_owner_pty_obj_ver_num     number;
    l_owner_acct_ipa_id         number;
    l_owner_acct_obj_ver_num    number;

    l_pty_override_flag         varchar2(1) := 'N';

    l_crt_instance_rec          csi_datastructures_pub.instance_rec;
    l_crt_parties_tbl           csi_datastructures_pub.party_tbl;
    l_crt_pty_accts_tbl         csi_datastructures_pub.party_account_tbl;
    l_crt_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_crt_ea_values_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_crt_pricing_tbl           csi_datastructures_pub.pricing_attribs_tbl;
    l_crt_assets_tbl            csi_datastructures_pub.instance_asset_tbl;
    l_upd_parties_tbl           csi_datastructures_pub.party_tbl;
    l_upd_pty_accts_tbl         csi_datastructures_pub.party_account_tbl;

    l_txn_line_rec              csi_t_datastructures_grp.txn_line_rec;
    l_td_found                  boolean := FALSE;
    l_partial_receipt           boolean := FALSE;                       -- Added for bug 4244887
    l_split_txn_line_rec        csi_t_datastructures_grp.txn_line_rec;  -- Added for bug 4244887
    -- get_transaction_details variables

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_tbl              csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl              csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl             csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_eav_tbl               csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl           csi_t_datastructures_grp.txn_systems_tbl;
    l_csi_ea_tbl                csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl               csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;


    -- get_item_instance_details variables

    l_instance_rec           csi_datastructures_pub.instance_header_rec;
    l_party_header_tbl       csi_datastructures_pub.party_header_tbl;
    l_account_header_tbl     csi_datastructures_pub.party_account_header_tbl;
    l_org_assignments_tbl    csi_datastructures_pub.org_units_header_tbl;
    l_pricing_attrib_tbl     csi_datastructures_pub.pricing_attribs_tbl;
    l_ext_attrib_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
    l_ext_attrib_def_tbl     csi_datastructures_pub.extend_attrib_tbl;
    l_asset_assignment_tbl   csi_datastructures_pub.instance_asset_header_tbl;
    l_time_stamp             date;

    -- process_transaction  variables

    l_api_version            NUMBER       := 1.0;
    l_commit                 VARCHAR2(1)  := fnd_api.g_false;
    l_init_msg_list          VARCHAR2(1)  := fnd_api.g_false;
    l_validation_level       NUMBER       := fnd_api.g_valid_level_full;
    l_validate_only_flag     VARCHAR2(1)  := fnd_api.g_false;
    l_in_out_flag            VARCHAR2(30) := 'IN';

    l_txn_rec                csi_datastructures_pub.transaction_rec;
    l_instances_tbl          csi_process_txn_grp.txn_instances_tbl;
    l_i_parties_tbl          csi_process_txn_grp.txn_i_parties_tbl;
    l_ip_accounts_tbl        csi_process_txn_grp.txn_ip_accounts_tbl;
    l_org_units_tbl          csi_process_txn_grp.txn_org_units_tbl;
    l_ext_attrib_values_tbl  csi_process_txn_grp.txn_ext_attrib_values_tbl;
    l_pricing_attribs_tbl    csi_process_txn_grp.txn_pricing_attribs_tbl;
    l_instance_asset_tbl     csi_process_txn_grp.txn_instance_asset_tbl;
    l_ii_relationships_tbl   csi_process_txn_grp.txn_ii_relationships_tbl;
    l_dest_location_rec      csi_process_txn_grp.dest_location_rec;

    l_error_message          varchar2(4000);
    l_error_rec              csi_datastructures_pub.transaction_error_rec;

    l_split_src_inst_rec     csi_datastructures_pub.instance_rec;
    l_split_src_trx_rec      csi_datastructures_pub.transaction_rec;
    l_split_new_inst_rec     csi_datastructures_pub.instance_rec;
    l_quantity1              NUMBER;
    l_quantity2              NUMBER;
    -- multi srl control variables
    l_inst_pa_rec            inst_pa_rec;
    l_tld_inst_tbl           tld_inst_tbl;
    l_u_instance_rec         csi_datastructures_pub.instance_rec;
    l_u_party_tbl            csi_datastructures_pub.party_tbl;
    l_u_party_acct_tbl       csi_datastructures_pub.party_account_tbl;
    l_u_pricing_attribs_tbl  csi_datastructures_pub.pricing_attribs_tbl;
    l_u_ext_attrib_val_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
    l_u_org_units_tbl        csi_datastructures_pub.organization_units_tbl;
    l_u_inst_asset_tbl       csi_datastructures_pub.instance_asset_tbl;
    l_u_inst_id_lst          csi_datastructures_pub.id_tbl;
    l_u_txn_rec              csi_datastructures_pub.transaction_rec;
    l_upd_inst_tbl           csi_datastructures_pub.instance_tbl;
    l_split_nsrc_inst_rec    csi_datastructures_pub.instance_rec;
    l_split_nsrc_trx_rec     csi_datastructures_pub.transaction_rec;
    l_new_nsrc_inst_rec      csi_datastructures_pub.instance_rec;
    l_obj_ver_num            NUMBER;
    l_end_date               DATE;
    u_ind                    number := 0;
    l_srl_qty                NUMBER;
    l_nsrl_qty               NUMBER;
    l_rem_qty                NUMBER;
    l_i_ind                  number := 1;
    l_pi_ind                 number := 1;
    l_count                  NUMBER;
    l_active_end_date        date;
    l_exp_instance_rec       csi_datastructures_pub.instance_rec;
    l_literal1   	     VARCHAR2(30) ;
    l_literal2    	     VARCHAR2(30) ;
    l_instance_rev_num       NUMBER;
    l_lock_id                NUMBER;
    l_lock_status            NUMBER;
    l_unlock_inst_tbl        csi_cz_int.config_tbl;
    -- For partner prdering
    l_end_cust_party_id  NUMBER;
    l_partner_order_rec             oe_install_base_util.partner_order_rec;

  BEGIN

    savepoint rma_receipt;

    fnd_msg_pub.initialize;

    x_return_status := fnd_api.g_ret_sts_success;

    csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csirmarc',
      p_file_segment2 => p_mtl_txn_id);

    api_log('rma_receipt');

    debug('  Transaction Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
    debug('  Transaction Type :RMA Receipt');
    debug('  Transaction ID   :'||p_mtl_txn_id);

    csi_utility_grp.check_ib_active;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_error_rec                             := px_trx_error_rec;
    l_error_rec.source_id                   := p_mtl_txn_id;
    l_error_rec.inv_material_transaction_id := p_mtl_txn_id;

    get_rma_info(
      p_transaction_id  => p_mtl_txn_id,
      x_mtl_trx_type    => l_rma_order_rec,
      x_error_message   => l_error_message,
      x_return_status   => l_return_status);

    l_error_rec.transaction_type_id  := 53;
    l_error_rec.source_header_ref    := l_rma_order_rec.source_header_ref;
    l_error_rec.source_header_ref_id := l_rma_order_rec.source_header_id;
    l_error_rec.source_line_ref      := l_rma_order_rec.source_line_ref;
    l_error_rec.source_line_ref_id   := l_rma_order_rec.source_line_id;

    debug('  RMA Number: '||l_rma_order_rec.source_header_ref);
    debug('  RMA Line Number: '||l_rma_order_rec.source_line_ref);
    debug('  RMA Line ID: '||l_rma_order_rec.source_line_id);

    -- get material transaction info
    get_mtl_txn_recs(
      p_mtl_txn_id        => p_mtl_txn_id,
      x_src_mtl_txn_tbl   => l_src_mtl_txn_tbl,
      x_dest_mtl_txn_tbl  => l_dest_mtl_txn_tbl,
      x_item_control_rec  => l_item_control_rec,
      x_src_order_rec     => l_src_order_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('get_mtl_txn_recs Failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    /* start of ER 2646086 + RMA for Repair with different party */
    /* Get the value for the source of truth flag */

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_pty_override_flag := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;

    /* end of ER 2646086 + RMA for Repair with different party */

    l_error_rec.inventory_item_id        := l_item_control_rec.inventory_item_id;
    l_error_rec.src_serial_num_ctrl_code := l_item_control_rec.serial_control_code;
    l_error_rec.src_lot_ctrl_code        := l_item_control_rec.lot_control_code;
    l_error_rec.src_rev_qty_ctrl_code    := l_item_control_rec.revision_control_code;
    l_error_rec.src_location_ctrl_code   := l_item_control_rec.locator_control_code;
    l_error_rec.comms_nl_trackable_flag  := l_item_control_rec.ib_trackable_flag;

    dump_txn_status_tbl(
      p_mtl_txn_tbl => l_src_mtl_txn_tbl);

    l_txn_line_rec.source_transaction_table := 'OE_ORDER_LINES_ALL';
    l_txn_line_rec.source_transaction_id    := l_src_mtl_txn_tbl(1).oe_line_id;

    l_td_found := csi_t_txn_details_pvt.check_txn_details_exist(
                    p_txn_line_rec => l_txn_line_rec);

    IF l_td_found THEN
      debug('Transaction details found for the RMA Order.');

      l_txn_line_query_rec.source_transaction_table        := 'OE_ORDER_LINES_ALL';
      l_txn_line_query_rec.source_transaction_id           := l_src_mtl_txn_tbl(1).oe_line_id;
      l_txn_line_detail_query_rec.source_transaction_flag  := 'Y';

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version               => 1.0,
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
        x_txn_ext_attrib_vals_tbl   => l_txn_eav_tbl,
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
        debug('Error getting transaction details for RMA Receipt to IB Interface.');
        raise fnd_api.g_exc_error;
      END IF;

      /* check if instance reference is specified */

      IF l_line_dtl_tbl.COUNT > 0 THEN

        FOR l_ind IN l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
        LOOP

          /* bug 2291543. added the serial code check here to allow the serial
             installation details without instance reference
          */
          IF l_item_control_rec.serial_control_code = 1 THEN
            IF nvl(l_line_dtl_tbl(l_ind).instance_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
              debug('No instance reference in Txn Details for non serial item.');
              fnd_message.set_name('CSI', 'CSI_INST_REF_NOT_ENTERED');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

        END LOOP;

      END IF;

      sync_txn_dtls_and_mtl_txn(
        px_mtl_txn_tbl     => l_src_mtl_txn_tbl,
        px_line_dtl_tbl    => l_line_dtl_tbl,
        x_tld_inst_tbl     => l_tld_inst_tbl,
        p_item_control_rec => l_item_control_rec,
        x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('CSI','CSI_TXN_PARAM_IGNORED_WARN');
    	fnd_message.set_token('PARAM','Item attributes');
    	fnd_message.set_token('VALUE','Lot / Serial');
    	fnd_message.set_token('REASON','The transaction details entered do not match the inventory material transaction for one or more of the attributes. Pl. correct it and reprocess the error');
    	fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      build_process_tables_TD(
        p_mtl_txn_tbl             => l_src_mtl_txn_tbl,
        p_item_control_rec        => l_item_control_rec,
        p_line_dtl_tbl            => l_line_dtl_tbl,
        x_txn_rec                 => l_txn_rec,
        x_instances_tbl           => l_instances_tbl,
        x_i_parties_tbl           => l_i_parties_tbl,
        x_ip_accounts_tbl         => l_ip_accounts_tbl,
        x_org_units_tbl           => l_org_units_tbl,
        x_ext_attrib_values_tbl   => l_ext_attrib_values_tbl,
        x_pricing_attribs_tbl     => l_pricing_attribs_tbl,
        x_instance_asset_tbl      => l_instance_asset_tbl,
        x_ii_relationships_tbl    => l_ii_relationships_tbl,
        x_dest_location_rec       => l_dest_location_rec,
        x_return_status           => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_tld_inst_tbl.count > 0 THEN
        debug('Instance updates to be processed for Multiple serial control codes.. '||l_tld_inst_tbl.count);
        l_inst_pa_rec.src_txn_party_id   := l_src_order_rec.party_id;
        l_inst_pa_rec.src_txn_acct_id    := l_src_order_rec.customer_account_id;
        l_inst_pa_rec.internal_party_id  := l_internal_party_id;
        l_inst_pa_rec.ownership_ovr_flag := l_pty_override_flag;
        l_upd_inst_tbl.delete;
        l_i_ind  :=  l_tld_inst_tbl.count; -- initialize

        IF l_item_control_rec.serial_control_code = 1
         AND l_item_control_rec.lot_control_code = 1
        THEN
            -- call to update the srl item instance
            -- update the tld rec for instance_id = g_miss so that inv instance is created/updated
            -- for loop with the mtl txn count..
          l_nsrl_qty  := l_src_mtl_txn_tbl(1).transaction_quantity; -- the total non serial qty received
          l_srl_qty   := l_tld_inst_tbl.count; -- the total serial qty referenced on txn dtls
          IF l_src_order_rec.original_order_qty > l_nsrl_qty THEN
           -- partial rcpt
             l_i_ind  :=  l_srl_qty - (l_src_order_rec.original_order_qty - l_nsrl_qty);
          ELSE
             l_i_ind  :=  l_srl_qty ;
          END IF;
          For i in 1 ..  l_i_ind Loop
           -- this is done to ensure that the number of srl item instances updated are limited
           --to only the total transacted quantity for nsrl items
            IF nvl(l_tld_inst_tbl(i).instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
             AND nvl(l_tld_inst_tbl(i).serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
            THEN
             l_inst_pa_rec.instance_id  := l_tld_inst_tbl(i).instance_id;
             get_instance_pa_dtls(
                p_transaction_type_id => l_txn_rec.transaction_type_id,
                p_sub_type_id         => l_tld_inst_tbl(i).sub_type_id,
                px_inst_pa_rec        => l_inst_pa_rec,
                x_sub_type_rec        => l_sub_type_rec,
                x_return_status       => l_return_status);

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;
             Begin
                SELECT object_version_number, active_end_date
                INTO   l_obj_ver_num, l_end_date
                FROM   csi_item_instances
                WHERE  instance_id = l_tld_inst_tbl(i).instance_id;
             Exception
               when others then
                  FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_INST_REF');
                  FND_MESSAGE.set_token('INSTANCE_ID', l_tld_inst_tbl(i).instance_id);
                  FND_MSG_PUB.add;
             End;
             l_upd_inst_tbl(i).object_version_number  := l_obj_ver_num;
             IF nvl(l_end_date , sysdate) between sysdate and sysdate +1 THEN --already expired earlier
                l_upd_inst_tbl(i).instance_id  := l_tld_inst_tbl(i).instance_id;
                l_upd_inst_tbl(i).last_oe_rma_line_id  := l_txn_rec.source_line_ref_id;
                IF nvl(l_sub_type_rec.src_change_owner,'N') = 'Y'
                 AND l_sub_type_rec.src_change_owner_to_code = 'I' THEN
                  --bug 4026148--
                -- l_upd_inst_tbl(i).active_end_date := l_txn_rec.source_transaction_date;
                   l_upd_inst_tbl(i).active_end_date := l_tld_inst_tbl(i).mtl_txn_creation_date;
                  --bug 4026148--

                   l_upd_inst_tbl(i).instance_status_id := nvl(l_sub_type_rec.src_status_id,1119); -- returned for credit
                   -- should we also change owner to Internal ? leaving as is for now for an easy way out
                   -- 'cause there seems to be too much reliance on the tld instance reference
                ELSE
                   l_upd_inst_tbl(i).instance_status_id := nvl(l_sub_type_rec.src_status_id,1094);-- returned for repair
                END IF;
             END IF;
            END IF;
            l_pi_ind  := l_instances_tbl.count; -- initialize
            IF l_src_order_rec.original_order_qty > l_nsrl_qty THEN
             -- partial rcpt
             IF l_src_order_rec.original_order_qty > l_srl_qty THEN
              -- non srl instances also referenced on txn dtls
               l_pi_ind  :=  l_srl_qty - (l_src_order_rec.original_order_qty - l_nsrl_qty);
             ELSE
               l_pi_ind  :=  l_nsrl_qty; -- update as many srl instances as the rcpt qty
             END IF;
            END IF;
            IF l_pi_ind > 0 THEN
             l_count := 0;
             For k in l_instances_tbl.first .. l_instances_tbl.last Loop
              --Only loop through till for the actual qty received...
              IF nvl(l_instances_tbl(k).instance_id,fnd_api.g_miss_num)
                 = nvl(l_tld_inst_tbl(i).instance_id,fnd_api.g_miss_num) THEN
                 l_instances_tbl(k).instance_id := fnd_api.g_miss_num;
                 l_instances_tbl(k).serial_number := fnd_api.g_miss_char;
                 l_count := l_count + 1;
                 IF l_count >= l_pi_ind THEN
                   exit;
                 END IF;
               -- initializing the variables for the correct update of destination
               -- item instances in process txn API
              END IF;
             End Loop;
            END IF;
          End Loop;
         ELSIF l_item_control_rec.serial_control_code <> 1 THEN
          u_ind := 0 ;
          l_nsrl_qty := 0;
          For j in 1 .. l_instances_tbl.count Loop
           IF nvl(l_instances_tbl(j).instance_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
             l_nsrl_qty := l_nsrl_qty + 1;
           END IF;
          End Loop;
          l_rem_qty  := l_nsrl_qty;

          For l in 1 .. l_instances_tbl.count Loop
           IF nvl(l_instances_tbl(l).instance_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            For m in l_tld_inst_tbl.first .. l_tld_inst_tbl.last  Loop
             IF nvl(l_tld_inst_tbl(m).processed_flag, 'N') = 'N' THEN
               u_ind  :=  u_ind + 1;
               IF abs(l_tld_inst_tbl(m).quantity) >= l_rem_qty THEN
                  l_quantity2 := l_rem_qty;
               ELSE
                  l_quantity2 := abs(l_tld_inst_tbl(m).quantity);
               END IF;
               Begin
                 SELECT quantity, active_end_date, object_version_number
                 INTO   l_quantity1, l_end_date, l_obj_ver_num
                 FROM   csi_item_instances
                 WHERE  instance_id = l_tld_inst_tbl(m).instance_id;
               Exception
                 when others then
                   FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_INST_REF');
                   FND_MESSAGE.set_token('INSTANCE_ID', l_tld_inst_tbl(m).instance_id);
                   FND_MSG_PUB.add;
               End;
               l_upd_inst_tbl(m).object_version_number  := l_obj_ver_num;
               IF l_rem_qty > 0 THEN
                IF l_quantity1 > l_quantity2 THEN -- need to split the instance
                  l_split_nsrc_inst_rec.instance_id  := l_tld_inst_tbl(m).instance_id;
                  l_split_nsrc_inst_rec.last_txn_line_detail_id  := l_tld_inst_tbl(m).txn_line_detail_id;
                  l_split_nsrc_inst_rec.last_oe_rma_line_id  := l_txn_rec.source_line_ref_id;
                  --Active_Start_date added for bug5248037--
                  l_split_src_inst_rec.active_start_date      := l_instances_tbl(m).mtl_txn_creation_date;

                  l_txn_rec.split_reason_code := 'PARTIAL_RETURN';
                  l_txn_rec.transaction_action_code := 'MULT_ITEM_SRL_CONTROL'; -- temporarily setting a unique identifier

	              csi_t_gen_utility_pvt.dump_api_info(
      	                    p_pkg_name => 'csi_item_instance_pvt',
            	            p_api_name => 'split_item_instance');

	              csi_t_gen_utility_pvt.dump_csi_instance_rec(
      	                    p_csi_instance_rec => l_split_nsrc_inst_rec);

 	              csi_item_instance_pvt.split_item_instance (
      	                   p_api_version            => 1.0,
            	           p_commit                 => fnd_api.g_false,
	                   p_init_msg_list          => fnd_api.g_true,
      	                   p_validation_level       => fnd_api.g_valid_level_full,
            	           p_source_instance_rec    => l_split_nsrc_inst_rec,
	                   p_quantity1              => l_quantity1 - l_quantity2 ,
      	                   p_quantity2              => l_quantity2,
            	           p_copy_ext_attribs       => fnd_api.g_true,
	                   p_copy_org_assignments   => fnd_api.g_true,
      	                   p_copy_parties           => fnd_api.g_true,
            	           p_copy_accounts          => fnd_api.g_true,
	                   p_copy_asset_assignments => fnd_api.g_true,
      	                   p_copy_pricing_attribs   => fnd_api.g_true,
            	           p_txn_rec                => l_txn_rec,
	                   x_new_instance_rec       => l_new_nsrc_inst_rec,
      	                   x_return_status          => l_return_status,
            	           x_msg_count              => l_msg_count,
	                   x_msg_data               => l_msg_data);

      	               IF l_return_status <> fnd_api.g_ret_sts_success  THEN
            	          debug('csi_item_instance_pvt.split_item_instance raised errors');
	                  raise fnd_api.g_exc_error;
      	               END IF;

	              debug('New Instance ID: '||l_new_nsrc_inst_rec.instance_id
      	                   ||' New Instance Qty.: '||l_new_nsrc_inst_rec.quantity);

	              l_upd_inst_tbl(u_ind).instance_id  := l_new_nsrc_inst_rec.instance_id ;
      	              l_upd_inst_tbl(u_ind).object_version_number := l_new_nsrc_inst_rec.object_version_number;
            	      l_upd_inst_tbl(u_ind).active_end_date := sysdate;
	              l_upd_inst_tbl(u_ind).last_oe_rma_line_id  := l_txn_rec.source_line_ref_id;
      	              l_upd_inst_tbl(u_ind).last_txn_line_detail_id  := l_tld_inst_tbl(m).txn_line_detail_id;
            	      l_upd_inst_tbl(u_ind).instance_status_id := 1; -- just expiring for now
	              l_tld_inst_tbl(u_ind).processed_flag  := 'Y'; --set it to processed
	              l_rem_qty := l_rem_qty - l_quantity2;
      	              exit;
                ELSE
	          IF nvl(l_end_date , sysdate) between sysdate and sysdate +1 THEN
      	                l_upd_inst_tbl(u_ind).instance_id  := l_tld_inst_tbl(m).instance_id;
	                l_upd_inst_tbl(u_ind).active_end_date := sysdate;
      	                l_upd_inst_tbl(u_ind).last_oe_rma_line_id  := l_txn_rec.source_line_ref_id;
            	        l_upd_inst_tbl(u_ind).last_txn_line_detail_id  := l_tld_inst_tbl(m).txn_line_detail_id;
	                l_upd_inst_tbl(u_ind).instance_status_id := 1; -- just expiring for now
      	                l_tld_inst_tbl(u_ind).processed_flag  := 'Y'; --set it to processed
	                l_rem_qty := l_rem_qty - l_quantity2;
            	        exit;
                  ELSE
	                  FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_INST_REF');
      	                  FND_MESSAGE.set_token('INSTANCE_ID', l_tld_inst_tbl(m).instance_id);
            	          FND_MSG_PUB.add;
	          END IF;
      	        END IF;
               END IF;
             END IF;
            End Loop;
           END IF;
          End Loop;
         END IF;
         IF l_upd_inst_tbl.count > 0 THEN
          debug('Multiple Serial control codes. Instances for Final Update:'||l_upd_inst_tbl.count);
          For n in l_upd_inst_tbl.first .. l_upd_inst_tbl.last Loop
             l_u_instance_rec.instance_id             := l_upd_inst_tbl(n).instance_id;
             l_u_instance_rec.active_end_date         := l_upd_inst_tbl(n).active_end_date;
             l_u_instance_rec.instance_status_id      := l_upd_inst_tbl(n).instance_status_id;
             l_u_instance_rec.last_oe_rma_line_id     := l_upd_inst_tbl(n).last_oe_rma_line_id;
             l_u_instance_rec.last_txn_line_detail_id := l_upd_inst_tbl(n).last_txn_line_detail_id;
             l_u_instance_rec.object_version_number   := l_upd_inst_tbl(n).object_version_number;
             l_txn_rec.transaction_action_code        := 'MULT_ITEM_SRL_CONTROL'; -- temporarily setting a unique identifier

             csi_t_gen_utility_pvt.dump_api_info(
               p_pkg_name => 'csi_item_instance_pub',
               p_api_name => 'update_item_instance');

             csi_t_gen_utility_pvt.dump_csi_instance_rec(
               p_csi_instance_rec => l_u_instance_rec);

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
               p_txn_rec               => l_txn_rec,
               p_asset_assignment_tbl  => l_u_inst_asset_tbl,
               x_instance_id_lst       => l_u_inst_id_lst,
               x_return_status         => l_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data );

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;
          End Loop;
         END IF;
      END IF;
    ELSE

      debug('Transaction details NOT found for the RMA Order.');

      IF l_item_control_rec.serial_control_code = 1 THEN
        debug('NON Serialized item and installation details not entered.');
        fnd_message.set_name('CSI', 'CSI_INST_DTLS_NOT_ENTERED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      ELSE
        -- serialized item, so figure out the owner's instance
        identify_source_instances(
          px_mtl_txn_tbl   => l_src_mtl_txn_tbl,
          p_item_control_rec => l_item_control_rec,
          x_return_status  => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      --   build the process transaction pl/sql tables using the mtl txn info
      build_process_tables_NOTD(
        p_mtl_txn_tbl             => l_src_mtl_txn_tbl,
        p_item_control_rec        => l_item_control_rec,
        x_txn_rec                 => l_txn_rec,
        x_instances_tbl           => l_instances_tbl,
        x_i_parties_tbl           => l_i_parties_tbl,
        x_ip_accounts_tbl         => l_ip_accounts_tbl,
        x_org_units_tbl           => l_org_units_tbl,
        x_ext_attrib_values_tbl   => l_ext_attrib_values_tbl,
        x_pricing_attribs_tbl     => l_pricing_attribs_tbl,
        x_instance_asset_tbl      => l_instance_asset_tbl,
        x_ii_relationships_tbl    => l_ii_relationships_tbl,
        x_dest_location_rec       => l_dest_location_rec,
        x_return_status           => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    get_sub_type_rec(
      p_transaction_type_id => l_txn_rec.transaction_type_id,
      p_sub_type_id         => l_txn_rec.txn_sub_type_id,
      x_sub_type_rec        => l_sub_type_rec,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    /* start of ER 2646086 + RMA for Repair with different party */
    /* Get the value for the source of truth flag */

    l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
    l_pty_override_flag := csi_datastructures_pub.g_install_param_rec.ownership_override_at_txn;

    /* end of ER 2646086 + RMA for Repair with different party */

    -- Added the complete FOR piece for ER 2482219. Return for repair
    /*added for  5456153 */
 	     get_partner_order_info(
 	       p_mtl_txn_id        => p_mtl_txn_id,
 	       x_partner_order_rec => l_partner_order_rec,
 	       x_end_cust_party_id => l_end_cust_party_id,
 	       x_return_status     => l_return_status);

    FOR i_ind in l_instances_tbl.FIRST .. l_instances_tbl.LAST
    LOOP

      IF l_item_control_rec.serial_control_code <> 1 THEN

        /* start of ER 2646086 + RMA for Repair with different party          */
        /* Added the IF piece to get required data. This is only done for the */
        /* serialized instances.                                              */

        debug('Check if owner needs to be overridden. Return from a different guy.');

        IF nvl(l_instances_tbl(i_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN

          l_error_rec.instance_id := l_instances_tbl(i_ind).instance_id;

          BEGIN

            SELECT party_id ,
                   instance_party_id,
                   object_version_number
            INTO   l_cur_owner_party_id,
                   l_owner_pty_ip_id,
                   l_owner_pty_obj_ver_num
            FROM   csi_i_parties
            WHERE  instance_id            = l_instances_tbl(i_ind).instance_id
            AND    relationship_type_code = 'OWNER';

            --## brmanesh leased out internal item may not have a owner account
            --## code enhancement required here

            -- Added Begin , Exception and End as part of fix for Bug 2733128
            BEGIN
              SELECT party_account_id,
                     ip_account_id,
                     object_version_number
              INTO   l_cur_owner_acct_id,
                     l_owner_acct_ipa_id,
                     l_owner_acct_obj_ver_num
              FROM   csi_ip_accounts
              WHERE  instance_party_id      = l_owner_pty_ip_id
              AND    relationship_type_code = 'OWNER';

            EXCEPTION
              WHEN no_data_found THEN
                   null;
            END;
          EXCEPTION
            WHEN no_data_found THEN
              --## to seed some error message appropriately
              RAISE fnd_api.g_exc_error;
          END;

          debug('  Instance ID              :'||l_instances_tbl(i_ind).instance_id);
          debug('  Internal Party ID        :'||l_internal_party_id);
          debug('  Current Party ID         :'||l_cur_owner_party_id);
          debug('  Current Party Account ID :'||l_cur_owner_acct_id);
          debug('  RMA Party ID             :'||l_src_order_rec.party_id );
          debug('  RMA Party Account ID     :'||l_src_order_rec.customer_account_id );
          debug('  Party override Flag      :'||l_pty_override_flag);
          debug('  RMA Owner :                :'||l_partner_order_rec.IB_OWNER);
          debug('  End Custmer Account ID     :'||l_partner_order_rec.END_CUSTOMER_ID);


          IF l_cur_owner_party_id <> l_internal_party_id
              AND
             l_cur_owner_party_id <> l_src_order_rec.party_id
              AND
             l_pty_override_flag = 'N'
          THEN
            fnd_message.set_name('CSI','CSI_RMA_OWNER_MISMATCH'); -- need to seed a new message
            fnd_message.set_token('INSTANCE_ID', l_instances_tbl(i_ind).instance_id );
            fnd_message.set_token('OLD_PARTY_ID', l_cur_owner_party_id );
            fnd_message.set_token('NEW_PARTY_ID', l_src_order_rec.party_id );
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;

          /* end of ER 2646086 + RMA for Repair with different party */

          /* for serial items we do the owner change logic */
          IF nvl(l_sub_type_rec.src_change_owner,'N') = 'Y'
             AND
             l_sub_type_rec.src_change_owner_to_code = 'I' THEN

            debug('Building INTERNAL OWNER party rec '||i_ind||' for process transaction.');

            i_p_ind := nvl(l_i_parties_tbl.LAST, 0) +1;

            l_i_parties_tbl(i_p_ind).parent_tbl_index       := i_ind;
            l_i_parties_tbl(i_p_ind).party_source_table     := 'HZ_PARTIES';
            l_i_parties_tbl(i_p_ind).party_id               := l_internal_party_id;
            l_i_parties_tbl(i_p_ind).relationship_type_code := 'OWNER';
            l_i_parties_tbl(i_p_ind).contact_flag           := 'N';

          ELSIF nvl(l_sub_type_rec.src_change_owner,'N') = 'N' THEN

            -- typically the return loaner transaction
            IF l_cur_owner_party_id = l_internal_party_id THEN
              l_instances_tbl(i_ind).install_location_type_code := null;
              l_instances_tbl(i_ind).install_location_id        := null;
            END IF;

            /* start of ER 2646086 + RMA for Repair with different party */
            /* Added the IF piece to handle repair cases */

            IF l_cur_owner_party_id <> l_internal_party_id
                AND
               l_cur_owner_party_id <> l_src_order_rec.party_id
                AND
               l_pty_override_flag = 'Y'
            THEN
              -- Transfer the Ownership first to the new RMA Customer and then process
              -- the RMA as a Normal one.
              -- Begin code fix as part of fix for Bug 2733128.


	    IF (l_partner_ORDER_rec.IB_OWNER = 'END_CUSTOMER' AND  l_cur_owner_party_id =l_end_cust_party_id) THEN
                debug('Ownership Change  not required as End Customer is the Current Owner.');
             ELSE

              BEGIN
                SELECT object_version_number
                INTO   l_chg_instance_rec.object_version_number
                FROM   csi_item_instances
                WHERE  instance_id = l_instances_tbl(i_ind).instance_id;

              EXCEPTION
                WHEN no_data_found THEN
                     NULL;
              END;

	          /*Added for End Customer Check  5437907 */
           IF (l_partner_ORDER_rec.IB_OWNER = 'END_CUSTOMER' AND  l_cur_owner_party_id <>l_end_cust_party_id) THEN
              l_upd_parties_tbl(1).party_id               := l_end_cust_party_id;
              l_upd_pty_accts_tbl(1).party_account_id     := l_partner_ORDER_rec.END_CUSTOMER_ID;
           ELSE
              l_upd_parties_tbl(1).party_id:=l_src_order_rec.party_id;
              l_upd_pty_accts_tbl(1).party_account_id     := l_src_order_rec.customer_account_id;
           END IF;

              l_chg_instance_rec.instance_id              := l_instances_tbl(i_ind).instance_id;
              l_chg_instance_rec.active_end_date          := NUll;
              -- End code fix as part of fix for Bug 2733128.

              l_upd_parties_tbl(1).instance_party_id      := l_owner_pty_ip_id;
              l_upd_parties_tbl(1).object_version_number  := l_owner_pty_obj_ver_num;

              l_upd_parties_tbl(1).party_source_table     := 'HZ_PARTIES';
             -- l_upd_parties_tbl(1).party_id               := l_src_order_rec.party_id;
              l_upd_parties_tbl(1).relationship_type_code := 'OWNER';
              l_upd_parties_tbl(1).contact_flag           := 'N';
              l_upd_parties_tbl(1).call_contracts         := fnd_api.g_false;

              l_upd_pty_accts_tbl(1).ip_account_id        := l_owner_acct_ipa_id;
              l_upd_pty_accts_tbl(1).instance_party_id    := l_owner_pty_ip_id;
              l_upd_pty_accts_tbl(1).object_version_number:= l_owner_acct_obj_ver_num;
              l_upd_pty_accts_tbl(1).parent_tbl_index     := 1;
              --l_upd_pty_accts_tbl(1).party_account_id     := l_src_order_rec.customer_account_id;
              l_upd_pty_accts_tbl(1).relationship_type_code := 'OWNER';
              l_upd_pty_accts_tbl(1).call_contracts       := fnd_api.g_false;

/* Commented the call as part of fix for Bug 2733128. Added call to Update_Item_Instance instead
              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_party_relationships_pub',
                p_api_name => 'update_inst_party_relationship');

              csi_party_relationships_pub.update_inst_party_relationship (
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_party_tbl             => l_upd_parties_tbl,
                p_party_account_tbl     => l_upd_pty_accts_tbl,
                p_txn_rec               => l_txn_rec,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);
*/

              csi_t_gen_utility_pvt.dump_api_info(
                p_pkg_name => 'csi_item_instance_pub',
                p_api_name => 'update_item_instance');

              csi_item_instance_pub.update_item_instance(
                p_api_version           => 1.0,
                p_commit                => fnd_api.g_false,
                p_init_msg_list         => fnd_api.g_true,
                p_validation_level      => fnd_api.g_valid_level_full,
                p_instance_rec          => l_chg_instance_rec,
                p_ext_attrib_values_tbl => l_chg_ext_attrib_val_tbl,
                p_party_tbl             => l_upd_parties_tbl,
                p_account_tbl           => l_upd_pty_accts_tbl,
                p_pricing_attrib_tbl    => l_chg_pricing_attribs_tbl,
                p_org_assignments_tbl   => l_chg_org_units_tbl,
                p_txn_rec               => l_txn_rec,
                p_asset_assignment_tbl  => l_chg_inst_asset_tbl,
                x_instance_id_lst       => l_chg_inst_id_lst,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              debug('Ownership Changed Successfully.');

             END IF; --End Customer Check
            END IF; -- owner override check

            /* end of ER 2646086 + RMA for Repair with different party */

            IF l_item_control_rec.serial_control_code = 6 THEN

              debug('Building INTERNAL OWNER party rec '||i_ind||' for process transaction.');
              i_p_ind := nvl(l_i_parties_tbl.LAST, 0) +1;

              l_i_parties_tbl(i_p_ind).parent_tbl_index       := i_ind;
              l_i_parties_tbl(i_p_ind).party_source_table     := 'HZ_PARTIES';
              l_i_parties_tbl(i_p_ind).party_id               := l_internal_party_id;
              l_i_parties_tbl(i_p_ind).relationship_type_code := 'OWNER';
              l_i_parties_tbl(i_p_ind).contact_flag           := 'N';

            END IF;

          END IF; -- sub_type ownerchange check

        ELSE -- instance not found -- try creating a source

          /* this logic is for creation of instances for a first time rma */
          /* receipt of serial instance in IB                             */

          -- assign the values to the new src mtl rec from the l instances tbl
          l_mtl_txn_rec.inventory_item_id    := l_instances_tbl(i_ind).inventory_item_id;
          l_mtl_txn_rec.serial_number        := l_instances_tbl(i_ind).serial_number;
          l_mtl_txn_rec.lot_number           := l_instances_tbl(i_ind).lot_number;
          l_mtl_txn_rec.transaction_quantity := 1;

          -- try one more time to get the source instance.
          -- arise, awake and stop not till the goal is reached ...!

          identify_source_instance(
            px_mtl_txn_rec   => l_mtl_txn_rec,
            p_item_control_rec => l_item_control_rec,
            x_return_status  => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_mtl_txn_rec.instance_id = fnd_api.g_miss_num THEN

            debug('Create a source serialized instance. Looks like first time IB creation.');

            l_crt_instance_rec.instance_id            := fnd_api.g_miss_num;
            l_crt_instance_rec.instance_number        := fnd_api.g_miss_char;
            l_crt_instance_rec.inventory_item_id      := l_instances_tbl(i_ind).inventory_item_id;
            l_crt_instance_rec.inventory_revision     := l_instances_tbl(i_ind).inventory_revision;
            l_crt_instance_rec.serial_number          := l_instances_tbl(i_ind).serial_number;
            l_crt_instance_rec.mfg_serial_number_flag := 'Y';
            l_crt_instance_rec.lot_number             := l_instances_tbl(i_ind).lot_number;
            l_crt_instance_rec.quantity               := 1;
            l_crt_instance_rec.unit_of_measure        := l_instances_tbl(i_ind).unit_of_measure;
            l_crt_instance_rec.location_type_code     := 'HZ_PARTY_SITES';
            l_crt_instance_rec.location_id            := l_src_order_rec.customer_location_id;
            l_crt_instance_rec.instance_usage_code    := 'OUT_OF_ENTERPRISE';
            l_crt_instance_rec.inv_master_organization_id := l_instances_tbl(i_ind).inv_master_organization_id;
            l_crt_instance_rec.vld_organization_id    := l_instances_tbl(i_ind).vld_organization_id;
            l_crt_instance_rec.last_oe_rma_line_id    := l_instances_tbl(i_ind).last_oe_rma_line_id;
            l_crt_instance_rec.customer_view_flag     := 'N';
            l_crt_instance_rec.merchant_view_flag     := 'Y';
            l_crt_instance_rec.object_version_number  := 1;
            l_crt_instance_rec.call_contracts         := fnd_api.g_false;
            --fix for bug5086652
	    l_crt_instance_rec.active_start_date      := l_instances_tbl(i_ind).mtl_txn_creation_date;

	    l_crt_parties_tbl(1).instance_party_id    := fnd_api.g_miss_num;
            l_crt_parties_tbl(1).party_source_table   := 'HZ_PARTIES';
            l_crt_parties_tbl(1).party_id             := l_src_order_rec.party_id;
            l_crt_parties_tbl(1).relationship_type_code:= 'OWNER';
            l_crt_parties_tbl(1).contact_flag         := 'N';
            l_crt_parties_tbl(1).call_contracts       := fnd_api.g_false;

            l_crt_pty_accts_tbl(1).ip_account_id      := fnd_api.g_miss_num;
            l_crt_pty_accts_tbl(1).parent_tbl_index   := 1;
            l_crt_pty_accts_tbl(1).party_account_id   := l_src_order_rec.customer_account_id;
            l_crt_pty_accts_tbl(1).relationship_type_code := 'OWNER';
            l_crt_pty_accts_tbl(1).call_contracts     := fnd_api.g_false;

            csi_t_gen_utility_pvt.dump_csi_instance_rec(
              p_csi_instance_rec => l_crt_instance_rec);

            csi_t_gen_utility_pvt.dump_api_info(
              p_pkg_name => 'csi_item_instance_pub',
              p_api_name => 'create_item_instance');

            csi_item_instance_pub.create_item_instance(
              p_api_version           => 1.0,
              p_commit                => fnd_api.g_false,
              p_init_msg_list         => fnd_api.g_true,
              p_validation_level      => fnd_api.g_valid_level_full,
              p_instance_rec          => l_crt_instance_rec,
              p_party_tbl             => l_crt_parties_tbl,
              p_account_tbl           => l_crt_pty_accts_tbl,
              p_org_assignments_tbl   => l_crt_org_units_tbl,
              p_ext_attrib_values_tbl => l_crt_ea_values_tbl,
              p_pricing_attrib_tbl    => l_crt_pricing_tbl,
              p_asset_assignment_tbl  => l_crt_assets_tbl,
              p_txn_rec               => l_txn_rec,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

            l_instances_tbl(i_ind).instance_id := l_crt_instance_rec.instance_id;

          ELSE
            l_instances_tbl(i_ind).instance_id := l_mtl_txn_rec.instance_id;

          END IF;-- instance_id = g_miss_num

          l_error_rec.instance_id := l_instances_tbl(i_ind).instance_id;
          debug('Source Customer Product ID :'||l_crt_instance_rec.instance_id);

          IF ( nvl(l_sub_type_rec.src_change_owner,'N') = 'Y'
               AND
               l_sub_type_rec.src_change_owner_to_code = 'I')
             OR
             (l_item_control_rec.serial_control_code = 6)
          THEN

            debug('Building INTERNAL OWNER party rec '||i_ind||' for process transaction.');

            i_p_ind := nvl(l_i_parties_tbl.LAST, 0) +1;

            l_i_parties_tbl(i_p_ind).parent_tbl_index       := i_ind;
            l_i_parties_tbl(i_p_ind).party_source_table     := 'HZ_PARTIES';
            l_i_parties_tbl(i_p_ind).party_id               := l_internal_party_id;
            l_i_parties_tbl(i_p_ind).relationship_type_code := 'OWNER';
            l_i_parties_tbl(i_p_ind).contact_flag           := 'N';

          END IF;

        END IF; -- instance_id = fnd_api.g_miss_num

      ELSE -- Non_Serialized Item in INV , serial code = 1
        IF nvl(l_instances_tbl(i_ind).instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
         /* Split the instance at source for Non serialized items */
        THEN

          BEGIN
            SELECT quantity, active_end_date
            INTO   l_quantity2, l_active_end_date
            FROM   csi_item_instances
            WHERE  instance_id = l_instances_tbl(i_ind).instance_id;

            debug('Original Instance Quantity: '||l_quantity2);

          EXCEPTION
            WHEN no_data_found THEN
                 debug('Failed to retrieve Instance data');
                 raise fnd_api.g_exc_error;
          END;

          IF l_quantity2 > l_instances_tbl(i_ind).quantity THEN -- inst qty > txn qty
            IF (l_active_end_date is NOT NULL) AND (l_active_end_date <= sysdate)
            THEN
            -- we will have to unexpire and expire the instance back.
            -- Contracts shouldn't be called while unexpiring

                csi_process_txn_pvt.unexpire_instance(
                  p_instance_id      => l_instances_tbl(i_ind).instance_id,
                  p_call_contracts   => fnd_api.g_false,
                  p_transaction_rec  => l_txn_rec,
                  x_return_status    => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;
            END IF;

              l_quantity1 := l_quantity2 - l_instances_tbl(i_ind).quantity ;
              l_quantity2 := l_instances_tbl(i_ind).quantity ;

              l_split_src_inst_rec.instance_id   := l_instances_tbl(i_ind).instance_id;
		--active_start_date added for bug5248037--
              l_split_src_inst_rec.active_start_date      := l_instances_tbl(i_ind).mtl_txn_creation_date;

              l_txn_rec.split_reason_code        := 'PARTIAL_RETURN';

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
                p_quantity2              => l_quantity2,
                p_copy_ext_attribs       => fnd_api.g_true,
                p_copy_org_assignments   => fnd_api.g_true,
                p_copy_parties           => fnd_api.g_true,
                p_copy_accounts          => fnd_api.g_true,
                p_copy_asset_assignments => fnd_api.g_true,
                p_copy_pricing_attribs   => fnd_api.g_true,
                p_txn_rec                => l_txn_rec,
                x_new_instance_rec       => l_split_new_inst_rec,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data);

              IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
                debug('csi_item_instance_pvt.split_item_instance raised errors');
                raise fnd_api.g_exc_error;
              END IF;

          IF (l_active_end_date is NOT NULL) AND (l_active_end_date <= sysdate)
          THEN -- expire the instance back.

  	      SELECT object_version_number
              INTO   l_exp_instance_rec.object_version_number
              FROM   csi_item_instances
              WHERE  instance_id = l_instances_tbl(i_ind).instance_id;

              l_exp_instance_rec.instance_id 	      := l_instances_tbl(i_ind).instance_id;
	      l_exp_instance_rec.call_contracts       := fnd_api.g_false;
              l_exp_instance_rec.active_end_date      := sysdate;
              l_exp_instance_rec.last_oe_rma_line_id  := l_txn_rec.source_line_ref_id;

             csi_t_gen_utility_pvt.dump_api_info(
               p_pkg_name => 'csi_item_instance_pub',
               p_api_name => 'update_item_instance');

             csi_t_gen_utility_pvt.dump_csi_instance_rec(
               p_csi_instance_rec => l_exp_instance_rec);

             csi_item_instance_pub.update_item_instance(
               p_api_version           => 1.0,
               p_commit                => fnd_api.g_false,
               p_init_msg_list         => fnd_api.g_true,
               p_validation_level      => fnd_api.g_valid_level_full,
               p_instance_rec          => l_exp_instance_rec,
               p_ext_attrib_values_tbl => l_u_ext_attrib_val_tbl,
               p_party_tbl             => l_u_party_tbl,
               p_account_tbl           => l_u_party_acct_tbl,
               p_pricing_attrib_tbl    => l_u_pricing_attribs_tbl,
               p_org_assignments_tbl   => l_u_org_units_tbl,
               p_txn_rec               => l_txn_rec,
               p_asset_assignment_tbl  => l_u_inst_asset_tbl,
               x_instance_id_lst       => l_u_inst_id_lst,
               x_return_status         => l_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data );

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;
          END IF;

              l_instances_tbl(i_ind).instance_id  := l_split_new_inst_rec.instance_id ;
              l_instances_tbl(i_ind).object_version_number := l_split_new_inst_rec.object_version_number;
              debug('New Instance ID: '||l_split_new_inst_rec.instance_id
                     ||' New Instance Qty.: '||l_split_new_inst_rec.quantity);

          END IF;
        END IF;

        /* for non serial items we do not work with the owner change logic */

        debug('Building INTERNAL OWNER party rec '||i_ind||' for process transaction.');

        i_p_ind := nvl(l_i_parties_tbl.LAST, 0) +1;

        l_i_parties_tbl(i_p_ind).parent_tbl_index       := i_ind;
        l_i_parties_tbl(i_p_ind).party_source_table     := 'HZ_PARTIES';
        l_i_parties_tbl(i_p_ind).party_id               := l_internal_party_id;
        l_i_parties_tbl(i_p_ind).relationship_type_code := 'OWNER';
        l_i_parties_tbl(i_p_ind).contact_flag           := 'N';

      END IF; -- serial_control code <> 1

    END LOOP; -- loop thru the instances table

    l_error_rec.instance_id := null;
    --
    -- srramakr TSO with Equipment
    -- RMA Receipt process should nullify the config keys
    IF l_instances_tbl.count > 0 THEN
       FOR J in l_instances_tbl.FIRST .. l_instances_tbl.LAST LOOP
          -- Nullify the Config Keys
          l_instances_tbl(J). CONFIG_INST_HDR_ID := NULL;
          l_instances_tbl(J). CONFIG_INST_REV_NUM := NULL;
          l_instances_tbl(J). CONFIG_INST_ITEM_ID := NULL;
       END LOOP;
    END IF;
    --
    debug('Calling Process Transaction Routine.');

    -- Call process transaction
    csi_process_txn_grp.process_transaction(
      p_api_version             => l_api_version,
      p_commit                  => l_commit,
      p_init_msg_list           => l_init_msg_list,
      p_validation_level        => l_validation_level,
      p_validate_only_flag      => l_validate_only_flag,
      p_in_out_flag             => l_in_out_flag,
      p_dest_location_rec       => l_dest_location_rec,
      p_txn_rec                 => l_txn_rec,
      p_instances_tbl           => l_instances_tbl,
      p_i_parties_tbl           => l_i_parties_tbl,
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

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Process transaction routine failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    --update the csi txn line details with the processed status

    Begin
     --Assign the literals..
     l_literal1 := 'IN_PROCESS';
     l_literal2 := 'OE_ORDER_LINES_ALL';

      UPDATE csi_t_txn_line_details a
      SET    error_code        = NULL,
             error_explanation = NULL ,
             processing_status = 'PROCESSED'
      WHERE  a.processing_status = l_literal1
      AND    a.source_transaction_flag = 'Y'
      AND    a.inventory_item_id       = l_item_control_rec.inventory_item_id
      AND    a.transaction_line_id in (SELECT transaction_line_id
				 FROM csi_t_transaction_lines b
                    WHERE -- a.transaction_line_id = b.transaction_line_id AND -- Commented for Perf Bug 4311676
                     b.source_transaction_id    = l_rma_order_rec.source_line_id
                     AND  b.source_transaction_table = l_literal2 );
    EXCEPTION
       WHEN others THEN
          debug('Failed to Update the Transaction Details data');
    End;

    debug('RMA Receipt Interface Successful for Material Transaction ID :'||p_mtl_txn_id);

   IF l_td_found THEN
       debug('Processing Transaction details in case of Partial RMA receipts.');
       l_txn_line_rec.source_transaction_table         := 'OE_ORDER_LINES_ALL';
       l_txn_line_rec.source_transaction_id            := l_rma_order_rec.source_line_id; -- l_src_mtl_txn_tbl(1).oe_line_id;
       l_txn_line_rec.source_transaction_type_id       := 53;
       l_split_txn_line_rec.source_transaction_table   := 'OE_ORDER_LINES_ALL';
       l_split_txn_line_rec.source_transaction_type_id := 53;
       l_line_dtl_tbl(1).inv_mtl_transaction_id        := p_mtl_txn_id;
       l_td_found        := FALSE;

       BEGIN
         SELECT line_id,
                header_id
         INTO   l_split_txn_line_rec.source_transaction_id,
                l_split_txn_line_rec.source_txn_header_id
         FROM   oe_order_lines_all
         WHERE  split_from_line_id = l_rma_order_rec.source_line_id  --l_src_mtl_txn_tbl(1).oe_line_id
         AND    header_id          = l_rma_order_rec.source_header_id ;

         l_partial_receipt := TRUE;
         l_td_found := csi_t_txn_details_pvt.check_txn_details_exist(
                           p_txn_line_rec => l_split_txn_line_rec);
       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           debug('Multiple RMA split lines found in OM for the RMA Order.');
           RAISE fnd_api.g_exc_error;
           l_partial_receipt := FALSE;
           l_td_found        := FALSE;
         WHEN OTHERS THEN
           l_partial_receipt := FALSE;
           l_td_found        := FALSE;
       END;

       IF l_partial_receipt AND NOT l_td_found THEN
         csi_t_txn_details_grp.split_transaction_details(
             p_api_version           => 1.0,
             p_commit                => fnd_api.g_false,
             p_init_msg_list         => fnd_api.g_true,
             p_validation_level      => fnd_api.g_valid_level_full,
             p_src_txn_line_rec      => l_txn_line_rec,
             px_split_txn_line_rec   => l_split_txn_line_rec,
             px_line_dtl_tbl         => l_line_dtl_tbl,
             x_pty_dtl_tbl           => l_pty_dtl_tbl,
             x_pty_acct_tbl          => l_pty_acct_tbl,
             x_org_assgn_tbl         => l_org_assgn_tbl,
             x_txn_ext_attrib_vals_tbl => l_txn_eav_tbl,
             x_txn_systems_tbl       => l_txn_systems_tbl,
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug(l_msg_data);
            Debug(' Failed to post Transaction Details to split RMA Line for partial RMA Cases.');
         ELSE
            Debug(' Transaction Details succefully posted to split RMA Line.');
         END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      rollback to rma_receipt;

      x_return_status := fnd_api.g_ret_sts_error;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error:(E) '||l_error_rec.error_text);
      px_trx_error_rec := l_error_rec;

    WHEN others THEN
      rollback to rma_receipt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',substr(sqlerrm, 1, 540));
      fnd_msg_pub.add;
      l_error_rec.error_text := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error:(O) '||l_error_rec.error_text);
      px_trx_error_rec := l_error_rec;

  END rma_receipt;


  PROCEDURE get_rma_info(
    p_transaction_id     IN  number,
    x_mtl_trx_type       OUT NOCOPY mtl_trx_type,
    x_error_message      OUT NOCOPY varchar2,
    x_return_status      OUT NOCOPY varchar2)
  IS
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN

      SELECT transaction_id,
             transaction_date,
             transaction_type_id,
             trx_source_line_id
      INTO   x_mtl_trx_type.transaction_id,
             x_mtl_trx_type.transaction_date,
             x_mtl_trx_type.transaction_type_id,
             x_mtl_trx_type.source_line_id
      FROM   mtl_material_transactions
      WHERE  transaction_id = p_transaction_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI', 'CSI_INT_MTL_TXN_ID_INVALID');
        fnd_message.set_token('MTL_TXN_ID', p_transaction_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    BEGIN

      SELECT ooh.header_id,
             ooh.order_number,
             ool.line_id,
             ool.line_number||'.'||ool.shipment_number
      INTO   x_mtl_trx_type.source_header_id,
             x_mtl_trx_type.source_header_ref,
             x_mtl_trx_type.source_line_id,
             x_mtl_trx_type.source_line_ref
      FROM   oe_order_headers_all ooh,
             oe_order_lines_all ool
      WHERE  ool.line_id = x_mtl_trx_type.source_line_id
      AND    ool.header_id = ooh.header_id;

    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_error_message := fnd_msg_pub.get;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_rma_info;


  PROCEDURE decode_message (
    p_msg_header       IN  XNP_MESSAGE.MSG_HEADER_REC_TYPE,
    p_msg_text         IN  VARCHAR2,
    x_mtl_trx_rec      OUT NOCOPY MTL_TRX_TYPE,
    x_error_message    OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2)
  IS

   l_api_name          VARCHAR2(100):= 'csi_wip_trxs_pkg.decode_message';
   l_fnd_unexpected    VARCHAR2(1)  := fnd_api.g_ret_sts_unexp_error;
   l_return_status     VARCHAR2(1)  := fnd_api.g_ret_sts_success;
   l_mtl_txn_id        number;

  BEGIN

    xnp_xml_utils.decode(P_Msg_Text, 'MTL_TRANSACTION_ID', l_mtl_txn_id);

    IF nvl(l_mtl_txn_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',
        'xnp_xml_utils.decode failed for '||p_msg_header.message_id);
      fnd_msg_pub.add;

      RAISE fnd_api.g_exc_error;
    END IF;

    get_rma_info(
      p_transaction_id     => l_mtl_txn_id,
      x_mtl_trx_type       => x_mtl_trx_rec,
      x_error_message      => x_error_message,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_error_message := csi_t_gen_utility_pvt.dump_error_stack;
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_msg_pub.get;
      x_return_status := l_fnd_unexpected;

  END decode_message;

END csi_rma_receipt_pub;

/
