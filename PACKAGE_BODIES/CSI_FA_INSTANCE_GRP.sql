--------------------------------------------------------
--  DDL for Package Body CSI_FA_INSTANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_FA_INSTANCE_GRP" AS
/* $Header: csigfaib.pls 120.15.12010000.2 2010/01/20 13:05:22 aradhakr ship $ */

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_gen_utility_pvt.put_line(p_message);
  END debug;

  FUNCTION dump_error_stack RETURN varchar2
  IS
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_msg_index_out   number;
    x_msg_data        varchar2(4000);
  BEGIN
    x_msg_data := null;
    fnd_msg_pub.count_and_get(
      p_count  => l_msg_count,
      p_data   => l_msg_data);

    FOR l_ind IN 1..l_msg_count
    LOOP
      fnd_msg_pub.get(
        p_msg_index     => l_ind,
        p_encoded       => fnd_api.g_false,
        p_data          => l_msg_data,
        p_msg_index_out => l_msg_index_out);

      x_msg_data := ltrim(x_msg_data||' '||l_msg_data);

      IF length(x_msg_data) > 1999 THEN
        x_msg_data := substr(x_msg_data, 1, 1999);
        exit;
      END IF;
    END LOOP;
    RETURN x_msg_data;
  EXCEPTION
    when others then
      RETURN x_msg_data;
  END dump_error_stack;

  PROCEDURE validate_inst_asset(
    px_inst_asset_rec     IN OUT nocopy csi_datastructures_pub.instance_asset_rec,
    x_return_status          OUT nocopy varchar2)
  IS
    l_acct_class_code            varchar2(30);
    l_location_type_code         varchar2(30);
    l_inventory_item_id          number;
    l_organization_id            number;
    l_inst_num                   varchar2(30);
    l_inventory_item             varchar2(80);
    l_asset_creation_code        varchar2(1);
    l_serial_number              varchar2(120);
    l_serial_code                number;
    l_pending_status             varchar2(30) := 'PENDING';
    l_pending_txn                boolean := FALSE;
    l_pending_txn_id             number;
    l_pending_mass_add           boolean := FALSE;
    l_fa_mass_add_id             number;


    CURSOR cia_cur(p_instance_id in number, p_asset_id in number) IS
      SELECT cia.instance_asset_id,
             cia.asset_quantity,
             cia.object_version_number,
             cia.fa_asset_id,
             cia.active_end_date
      FROM   csi_i_assets cia
      WHERE  cia.instance_id = p_instance_id
      AND    cia.fa_asset_id = p_asset_id
      AND    sysdate BETWEEN nvl(cia.active_start_date, sysdate-1) AND nvl(cia.active_end_date, sysdate+1);

    CURSOR uniq_fa_cur(p_instance_id in number) IS
      SELECT cia.fa_asset_id
      FROM   csi_i_assets cia
      WHERE  instance_id = p_instance_id
      AND    sysdate BETWEEN nvl(cia.active_start_date, sysdate-1) AND nvl(cia.active_end_date, sysdate+1);

    CURSOR pending_txn_cur(p_instance_id in number) is
      SELECT ct.transaction_id
      FROM   csi_item_instances_h ciih,
             csi_transactions     ct
      WHERE  ciih.instance_id  = p_instance_id
      AND    ct.transaction_id = ciih.transaction_id
      AND    ct.transaction_type_id IN (117, 129, 128, 105, 112, 118, 119)
      AND    ct.transaction_status_code = l_pending_status
      AND    ct.inv_material_transaction_id is not null;

    -- eib supported transactions for fixed asset creation
    ------------------------------------------------------------
    --  117 - ('MISC_RECEIPT')               - depreciable items
    --  129 - ('ACCT_ALIAS_RECEIPT')         - depreciable items
    --  128 - ('ACCT_RECEIPT')               - depreciable items
    --  105 - ('PO_RECEIPT_INTO_PROJECT')    - depreciable items
    --  112 - ('PO_RECEIPT_INTO_INVENTORY')  - depreciable items
    --  118 - ('PHYSICAL_INVENTORY')         - depreciable items
    --  119 - ('CYCLE_COUNT_ADJUSTMENT'      - depreciable items
    ------------------------------------------------------------

    CURSOR pending_mass_add_cur(p_instance_id in number) IS
      SELECT cia.fa_mass_addition_id
      FROM   csi_i_assets cia
      WHERE  instance_id = p_instance_id
      AND    fa_asset_id is null
      AND    sysdate BETWEEN nvl(cia.active_start_date, sysdate-1) AND nvl(cia.active_end_date, sysdate+1);

  BEGIN

    debug('validate_inst_asset');

    x_return_status := fnd_api.g_ret_sts_success;

    IF nvl(px_inst_asset_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      SELECT accounting_class_code,
             location_type_code,
             inventory_item_id,
             last_vld_organization_id,
             instance_number,
             serial_number
      INTO   l_acct_class_code,
             l_location_type_code,
             l_inventory_item_id,
             l_organization_id,
             l_inst_num,
             l_serial_number
      FROM   csi_item_instances
      WHERE  instance_id = px_inst_asset_rec.instance_id;

      IF l_acct_class_code = 'CUST_PROD' THEN
        fnd_message.set_name('CSI', 'CSI_INST_ASSET_AC_INVALID');
        fnd_message.set_token('INST_NUM', l_inst_num);
        fnd_message.set_token('AC_CODE', l_acct_class_code);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_location_type_code in ('WIP', 'PROJECT', 'IN_TRANSIT') THEN
        fnd_message.set_name('CSI', 'CSI_INST_ASSET_LOC_INVALID');
        fnd_message.set_token('INST_NUM', l_inst_num);
        fnd_message.set_token('LOC_CODE', l_location_type_code);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      SELECT asset_creation_code,
             segment1,
             serial_number_control_code
      INTO   l_asset_creation_code,
             l_inventory_item,
             l_serial_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_inventory_item_id
      AND    organization_id   = l_organization_id;

      IF nvl(l_asset_creation_code,'0') in ('1', 'Y') THEN

        l_pending_txn := FALSE;
        FOR pending_txn_rec in pending_txn_cur(px_inst_asset_rec.instance_id)
        LOOP
          l_pending_txn    := TRUE;
          l_pending_txn_id := pending_txn_rec.transaction_id;
          exit;
        END LOOP;

        IF l_pending_txn THEN
          fnd_message.set_name('CSI', 'CSI_DEPR_ADD_PENDING_TXN');
          fnd_message.set_token('TXN_ID', l_pending_txn_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_pending_mass_add := FALSE;
        FOR pending_mass_add_rec IN pending_mass_add_cur(px_inst_asset_rec.instance_id)
        LOOP
          l_pending_mass_add := TRUE;
          l_fa_mass_add_id   := pending_mass_add_rec.fa_mass_addition_id;
          exit;
        END LOOP;

        IF l_pending_mass_add THEN
          fnd_message.set_name('CSI', 'CSI_DEPR_ADD_PENDING_MASSADD');
          fnd_message.set_token('MASS_ADD_ID', l_fa_mass_add_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

      debug('serial code   : '||l_serial_code);
      debug('inst_asset_id : '||px_inst_asset_rec.instance_asset_id);
      debug('inst_id       : '||px_inst_asset_rec.instance_id);
      debug('fa_asset_id   : '||px_inst_asset_rec.fa_asset_id);

      IF l_serial_code in (2, 5) or l_serial_number is not null THEN

        IF nvl(px_inst_asset_rec.instance_asset_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          -- create case
          FOR uniq_fa_rec IN uniq_fa_cur(px_inst_asset_rec.instance_id)
          LOOP
            fnd_message.set_name('CSI', 'CSI_SRL_DUP_FA_ERROR');
            fnd_message.set_token('INST_ID', px_inst_asset_rec.instance_id);
            fnd_message.set_token('ASSET_ID', uniq_fa_rec.fa_asset_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END LOOP;

        ELSE
          null;
          -- update case
        END IF;
      ELSE
        FOR cia_rec IN cia_cur(px_inst_asset_rec.instance_id, px_inst_asset_rec.fa_asset_id)
        LOOP
          px_inst_asset_rec.instance_asset_id     := cia_rec.instance_asset_id;
          px_inst_asset_rec.object_version_number := cia_rec.object_version_number;
          exit;
        END LOOP;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_inst_asset;

  PROCEDURE derive_fa_missing_values(
    p_instance_rec        IN     csi_datastructures_pub.instance_rec,
    p_fixed_asset_rec     IN     fixed_asset_rec,
    x_fa_location_id         OUT nocopy number,
    x_fa_quantity            OUT nocopy number,
    x_fa_book_type_code      OUT nocopy varchar2,
    x_return_status          OUT nocopy varchar2)
  IS

    l_location_type_code      varchar2(30);
    l_location_id             number;
    l_instance_quantity       number;

    l_location_table          varchar2(30);
    l_fa_location_id          number;
    l_fa_quantity             number;
    l_fa_book_type_code       varchar2(30);

    l_latest_fa_location_id   number;
    l_latest_fa_quantity      number;
    l_dist_found              boolean := FALSE;

    CURSOR btc_cur(p_asset_id IN number) IS
      SELECT fb.book_type_code
      FROM   fa_books         fb,
             fa_book_controls fbc
      WHERE  fb.asset_id = p_asset_id
      AND    fb.date_ineffective is null
      AND    fbc.book_type_code  = fb.book_type_code
      AND    fbc.book_class      = 'CORPORATE';

    CURSOR a_loc_cur(p_table in varchar2, p_loc_id in number) IS
      SELECT fa_location_id
      FROM   csi_a_locations
      WHERE  location_table = p_table
      AND    location_id    = p_loc_id;

    CURSOR fa_dist_cur(p_asset_id IN number, p_book_type_code in varchar2) IS
      SELECT location_id,
             distribution_id,
             units_assigned
      FROM   fa_distribution_history
      WHERE  asset_id       = p_asset_id
      AND    book_type_code = p_book_type_code
      AND    date_ineffective is null
      ORDER BY date_effective desc; -- latest one first

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('derive fa loc');

    IF nvl(p_fixed_asset_rec.book_type_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      l_fa_book_type_code := p_fixed_asset_rec.book_type_code;
    ELSE
      FOR btc_rec IN btc_cur(p_fixed_asset_rec.asset_id)
      LOOP
        l_fa_book_type_code := btc_rec.book_type_code;
        exit;
      END LOOP;
    END IF;

    l_location_table := null;

    IF nvl(p_instance_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      SELECT location_type_code,
             location_id,
             quantity
      INTO   l_location_type_code,
             l_location_id,
             l_instance_quantity
      FROM   csi_item_instances
      WHERE  instance_id = p_instance_rec.instance_id;
    ELSE
      l_location_type_code := p_instance_rec.location_type_code;
      l_location_id        := p_instance_rec.location_id;
    END IF;

    IF nvl(p_fixed_asset_rec.asset_location_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_fa_location_id := p_fixed_asset_rec.asset_location_id;
    ELSE

      l_location_table := null;

      IF l_location_type_code = 'INVENTORY' THEN
        l_location_table := 'HR_LOCATIONS';
      ELSIF l_location_type_code = 'HZ_LOCATIONS' THEN
        l_location_table := 'HZ_LOCATIONS';
      ELSIF l_location_type_code = 'HZ_PARTY_SITES' THEN
        l_location_table := 'HZ_LOCATIONS';

        SELECT location_id
        INTO   l_location_id
        FROM   hz_party_sites
        WHERE  party_site_id = l_location_id;

      ELSIF l_location_type_code = 'INTERNAL_SITE' THEN
        l_location_table := 'HR_LOCATIONS';
      END IF;

      debug('location table :'||l_location_table);

      IF l_location_table is not null THEN
        FOR a_loc_rec IN a_loc_cur(l_location_table, l_location_id)
        LOOP
          l_fa_location_id := a_loc_rec.fa_location_id;
        END LOOP;
      END IF;
    END IF;

    debug(' l_fa_location_id : '||l_fa_location_id);

    l_dist_found := FALSE;
    -- now get the quantity from the distribution
    FOR fa_dist_rec IN fa_dist_cur(p_fixed_asset_rec.asset_id, l_fa_book_type_code)
    LOOP
      IF fa_dist_cur%rowcount = 1 THEN
        l_latest_fa_location_id := fa_dist_rec.location_id;
        l_latest_fa_quantity    := fa_dist_rec.units_assigned;
      END IF;
      IF fa_dist_rec.location_id = l_fa_location_id THEN
        l_dist_found  := TRUE;
        l_fa_quantity := fa_dist_rec.units_assigned;
        exit;
      END IF;
    END LOOP;

    IF NOT(l_dist_found) THEN
      l_fa_location_id := l_latest_fa_location_id;
      l_fa_quantity    := l_latest_fa_quantity;
    END IF;

    debug(' fa location id : '||l_fa_location_id);

    x_fa_location_id    := l_fa_location_id;
    x_fa_quantity       := least(l_fa_quantity, l_instance_quantity);
    x_fa_book_type_code := l_fa_book_type_code;

  END derive_fa_missing_values;


  PROCEDURE create_item_instance(
    p_fixed_asset_rec          IN     fixed_asset_rec,
    p_eam_rec                  IN     eam_rec,
    p_instance_rec             IN     csi_datastructures_pub.instance_rec,
    p_instance_serial_tbl      IN     instance_serial_tbl,
    p_party_tbl                IN     csi_datastructures_pub.party_tbl,
    p_party_account_tbl        IN     csi_datastructures_pub.party_account_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_tbl                OUT nocopy csi_datastructures_pub.instance_tbl,
    x_instance_asset_tbl          OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2)
  IS

    l_fa_location_id        number;
    l_fa_quantity           number;
    l_fa_book_type_code     varchar2(30);

    l_miss_num              number := fnd_api.g_miss_num;
    l_miss_char             varchar2(200) := fnd_api.g_miss_char;

    l_serial_control_code   number;
    l_eam_item_type         number;
    l_eam_item              boolean := FALSE;

    -- group create_item_instance variables
    l_instance_tbl          csi_datastructures_pub.instance_tbl;
    l_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    l_party_tbl             csi_datastructures_pub.party_tbl;
    l_account_tbl           csi_datastructures_pub.party_account_tbl;
    l_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
    l_instance_asset_tbl    csi_datastructures_pub.instance_asset_tbl;
    l_csi_txn_tbl           csi_datastructures_pub.transaction_tbl;
    l_grp_error_tbl         csi_datastructures_pub.grp_error_tbl;


    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);
    l_error_message         varchar2(2000);
    l_warning_flag          varchar2(1) := 'N';

    --
    g_inst_ind              binary_integer := 0;
    g_pty_ind               binary_integer := 0;
    g_pa_ind                binary_integer := 0;
    g_ia_ind                binary_integer := 0;

    --bug 9227016
    l_item_inst_grp_excep EXCEPTION;
    l_error_msg VARCHAR2(5000) := '';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    savepoint fa_grp_create_instance;

    -- validate mandatory fields

    -- inventory item id
    csi_item_instance_vld_pvt.check_reqd_param_num(
      p_number      => p_instance_rec.inventory_item_id,
      p_param_name  => 'p_instance_rec.inventory_item_id',
      p_api_name    => 'csi_fa_instance_grp.create_item_instance');

    -- validation organization id
    csi_item_instance_vld_pvt.check_reqd_param_num(
      p_number      => p_instance_rec.vld_organization_id,
      p_param_name  => 'p_instance_rec.vld_organization_id',
      p_api_name    => 'csi_fa_instance_grp.create_item_instance');

    -- location type code
    csi_item_instance_vld_pvt.check_reqd_param_char(
      p_variable    => p_instance_rec.location_type_code,
      p_param_name  => 'p_instance_re.location_type_code',
      p_api_name    => 'csi_fa_instance_grp.create_item_instance');

    -- location id
    csi_item_instance_vld_pvt.check_reqd_param_num(
      p_number      => p_instance_rec.location_id,
      p_param_name  => 'p_instance_rec.location_id',
      p_api_name    => 'csi_fa_instance_grp.create_item_instance');

    -- source_transaction_date in csi_transactions
    csi_item_instance_vld_pvt.check_reqd_param_date(
      p_date        => px_csi_txn_rec.source_transaction_date,
      p_param_name  => 'px_csi_txn_rec.source_transaction_date',
      p_api_name    => 'csi_fa_instance_grp.create_item_instance');

    -- transaction_type_id in csi_transactions
    csi_item_instance_vld_pvt.check_reqd_param_num(
      p_number      => px_csi_txn_rec.transaction_type_id,
      p_param_name  => 'px_csi_txn_rec.transaction_type_id',
      p_api_name    => 'csi_fa_instance_grp.create_item_instance');

    -- derive eam_item_type
    IF nvl(p_instance_rec.inventory_item_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
       AND
       nvl(p_instance_rec.vld_organization_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN

      SELECT eam_item_type,
             serial_number_control_code
      INTO   l_eam_item_type,
             l_serial_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_instance_rec.inventory_item_id
      AND    organization_id   = p_instance_rec.vld_organization_id;

      IF l_eam_item_type in (1, 3) AND l_serial_control_code <> 1 THEN
        l_eam_item := TRUE;
      END IF;

    END IF;

    IF nvl(p_fixed_asset_rec.asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      IF nvl(p_fixed_asset_rec.asset_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
         OR
         nvl(p_fixed_asset_rec.asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num
         OR
         nvl(p_fixed_asset_rec.book_type_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
      THEN

        derive_fa_missing_values(
          p_instance_rec      => p_instance_rec,
          p_fixed_asset_rec   => p_fixed_asset_rec,
          x_fa_location_id    => l_fa_location_id,
          x_fa_quantity       => l_fa_quantity,
          x_fa_book_type_code => l_fa_book_type_code,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

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

    IF p_instance_serial_tbl.COUNT > 0 THEN
      FOR srl_ind IN p_instance_serial_tbl.FIRST .. p_instance_serial_tbl.LAST
      LOOP

        g_inst_ind := g_inst_ind + 1;

        l_csi_txn_tbl(g_inst_ind) := px_csi_txn_rec;

        l_instance_tbl(g_inst_ind) := p_instance_rec;

        l_instance_tbl(g_inst_ind).quantity               := 1;
        --l_instance_tbl(g_inst_ind).mfg_serial_number_flag := 'Y';


        -- override with serial attributes
        l_instance_tbl(g_inst_ind).instance_number :=
          nvl(p_instance_serial_tbl(srl_ind).instance_number, l_miss_char);
        l_instance_tbl(g_inst_ind).serial_number :=
          nvl(p_instance_serial_tbl(srl_ind).serial_number, l_miss_char);
        l_instance_tbl(g_inst_ind).lot_number :=
          nvl(p_instance_serial_tbl(srl_ind).lot_number, p_instance_rec.lot_number);
        l_instance_tbl(g_inst_ind).external_reference :=
          nvl(p_instance_serial_tbl(srl_ind).external_reference, p_instance_rec.external_reference);
        l_instance_tbl(g_inst_ind).instance_usage_code :=
          nvl(p_instance_serial_tbl(srl_ind).instance_usage_code, p_instance_rec.instance_usage_code);
        l_instance_tbl(g_inst_ind).operational_status_code :=
          nvl(p_instance_serial_tbl(srl_ind).operational_status_code,
              p_instance_rec.operational_status_code);
        l_instance_tbl(g_inst_ind).instance_description :=
          nvl(p_instance_serial_tbl(srl_ind).instance_description, p_instance_rec.instance_description);

        -- override with eam attributes
        l_instance_tbl(g_inst_ind).asset_criticality_code :=
                                nvl(p_eam_rec.asset_criticality_code, l_miss_char);
        l_instance_tbl(g_inst_ind).category_id :=
                                nvl(p_eam_rec.category_id, l_miss_num);


        IF p_party_tbl.COUNT > 0 THEN
          FOR pty_ind IN p_party_tbl.FIRST .. p_party_tbl.LAST
          LOOP

            g_pty_ind := g_pty_ind + 1;
            l_party_tbl(g_pty_ind) := p_party_tbl(pty_ind);
            l_party_tbl(g_pty_ind).parent_tbl_index := g_inst_ind;


            IF p_party_account_tbl.COUNT > 0 THEN
              FOR pa_ind IN p_party_account_tbl.FIRST .. p_party_account_tbl.LAST
              LOOP
                g_pa_ind := g_pa_ind + 1;
                l_account_tbl(g_pa_ind) := p_party_account_tbl(pa_ind);
                l_account_tbl(g_pa_ind).parent_tbl_index := g_pty_ind;
              END LOOP;
            END IF;

          END LOOP;
        END IF;

        IF nvl(p_fixed_asset_rec.asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          g_ia_ind := g_ia_ind + 1;
          l_instance_asset_tbl(g_ia_ind).parent_tbl_index  := g_inst_ind;
          l_instance_asset_tbl(g_ia_ind).fa_asset_id       := p_fixed_asset_rec.asset_id;
          l_instance_asset_tbl(g_ia_ind).fa_book_type_code := l_fa_book_type_code;
          l_instance_asset_tbl(g_ia_ind).fa_location_id    := l_fa_location_id;
          l_instance_asset_tbl(g_ia_ind).asset_quantity    := 1; -- for serialized
          l_instance_asset_tbl(g_ia_ind).update_status     := 'IN_SERVICE';
          l_instance_asset_tbl(g_ia_ind).fa_sync_flag      := p_fixed_asset_rec.fa_sync_flag;
          l_instance_asset_tbl(g_ia_ind).fa_sync_validation_reqd  :=
            nvl(p_fixed_asset_rec.fa_sync_validation_reqd, fnd_api.g_false);

          validate_inst_asset(
            px_inst_asset_rec     => l_instance_asset_tbl(g_ia_ind),
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;
    ELSE

      g_inst_ind := g_inst_ind + 1;

      l_csi_txn_tbl(g_inst_ind) := px_csi_txn_rec;

      l_instance_tbl(g_inst_ind) := p_instance_rec;

      -- override with eam attributes
      l_instance_tbl(g_inst_ind).asset_criticality_code :=
                              nvl(p_eam_rec.asset_criticality_code, l_miss_char);
      l_instance_tbl(g_inst_ind).category_id :=
                              nvl(p_eam_rec.category_id, l_miss_num);

      IF p_party_tbl.COUNT > 0 THEN
        FOR pty_ind IN p_party_tbl.FIRST .. p_party_tbl.LAST
        LOOP

          g_pty_ind := g_pty_ind + 1;
          l_party_tbl(g_pty_ind) := p_party_tbl(pty_ind);
          l_party_tbl(g_pty_ind).parent_tbl_index := g_inst_ind;

          IF p_party_account_tbl.COUNT > 0 THEN
            FOR pa_ind IN p_party_account_tbl.FIRST .. p_party_account_tbl.LAST
            LOOP
              g_pa_ind := g_pa_ind + 1;
              l_account_tbl(g_pa_ind) := p_party_account_tbl(pa_ind);
              l_account_tbl(g_pa_ind).parent_tbl_index := g_pty_ind;
            END LOOP;
          END IF;

        END LOOP;
      END IF;

      IF nvl(p_fixed_asset_rec.asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        g_ia_ind := g_ia_ind + 1;
        l_instance_asset_tbl(g_ia_ind).parent_tbl_index  := g_inst_ind;
        l_instance_asset_tbl(g_ia_ind).fa_asset_id       := p_fixed_asset_rec.asset_id;
        l_instance_asset_tbl(g_ia_ind).fa_book_type_code := l_fa_book_type_code;
        l_instance_asset_tbl(g_ia_ind).fa_location_id    := l_fa_location_id;
        l_instance_asset_tbl(g_ia_ind).asset_quantity    := p_instance_rec.quantity;
        l_instance_asset_tbl(g_ia_ind).update_status     := 'IN_SERVICE';
        l_instance_asset_tbl(g_ia_ind).fa_sync_flag      := p_fixed_asset_rec.fa_sync_flag;
        l_instance_asset_tbl(g_ia_ind).fa_sync_validation_reqd  :=
          nvl(p_fixed_asset_rec.fa_sync_validation_reqd, fnd_api.g_false);

        validate_inst_asset(
          px_inst_asset_rec     => l_instance_asset_tbl(g_ia_ind),
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    END IF;

    debug('instance_tbl.count        : '||l_instance_tbl.count);
    debug('instance_asset_tbl.count  : '||l_instance_asset_tbl.count);

    csi_item_instance_grp.create_item_instance (
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_tbl          => l_instance_tbl,
      p_ext_attrib_values_tbl => l_ext_attrib_values_tbl,
      p_party_tbl             => l_party_tbl,
      p_account_tbl           => l_account_tbl,
      p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
      p_org_assignments_tbl   => l_org_assignments_tbl,
      p_asset_assignment_tbl  => l_instance_asset_tbl,
      p_txn_tbl               => l_csi_txn_tbl,
      p_call_from_bom_expl    => 'N',
      p_grp_error_tbl         => l_grp_error_tbl,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      --bug 9227016
      RAISE l_item_inst_grp_excep;
      --RAISE fnd_api.g_exc_error;
    END IF;

    IF l_grp_error_tbl.COUNT > 0 THEN
      -- errors should be passes out as error.
      FOR err_ind IN l_grp_error_tbl.FIRST ..l_grp_error_tbl.LAST
      LOOP
        IF l_grp_error_tbl(err_ind).process_status = 'E' THEN
	 --bug 9227016
          --l_error_message := l_grp_error_tbl(err_ind).error_message;
          --RAISE fnd_api.g_exc_error;
	  RAISE l_item_inst_grp_excep;
        END IF;
      END LOOP;

    END IF;

    IF l_instance_tbl.COUNT > 0 THEN
      FOR inst_ind IN l_instance_tbl.FIRST .. l_instance_tbl.LAST
      LOOP

        IF l_eam_item THEN
          -- to be uncommented later
          eam_maint_attributes_pub.create_maint_attributes(
            p_api_version           => 1.0,
            p_init_msg_list         => fnd_api.g_true,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_id           => l_instance_tbl(inst_ind).instance_id,
            p_owning_department_id  => p_eam_rec.owning_department_id,
            p_accounting_class_code => p_eam_rec.wip_accounting_class_code,
            p_area_id               => p_eam_rec.area_id,
            p_parent_instance_id    => p_eam_rec.parent_instance_id,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

      END LOOP;
    END IF;

    x_instance_tbl       := l_instance_tbl;
    x_instance_asset_tbl := l_instance_asset_tbl;


    IF l_instance_asset_tbl.COUNT > 0 THEN
      FOR l_ind IN l_instance_asset_tbl.FIRST .. l_instance_asset_tbl.LAST
      LOOP
        IF l_instance_asset_tbl(l_ind).fa_sync_flag = 'N' THEN
          l_warning_flag := 'Y';
        END IF;
      END LOOP;
    END IF;

    IF l_warning_flag = 'Y' THEN
      fnd_message.set_name('CSI', 'CSI_INST_ASSET_SYNC_WARNING');
      fnd_msg_pub.add;
      x_return_status := 'W';
      x_error_message := dump_error_stack;
    END IF;

  EXCEPTION
  --bug 9227016 start
  WHEN l_item_inst_grp_excep THEN
    rollback to fa_grp_create_instance;
    IF l_grp_error_tbl.COUNT > 0 THEN
     -- errors should be passes out as error.
     FOR err_ind IN l_grp_error_tbl.FIRST ..l_grp_error_tbl.LAST
      LOOP
        IF l_grp_error_tbl(err_ind).process_status = 'E' THEN
          l_error_message := l_error_message || l_grp_error_tbl(err_ind).error_message || ' ';
        END IF;
      END LOOP;
     END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := l_error_message;
    --bug 9227016 end
    WHEN fnd_api.g_exc_error THEN
      rollback to fa_grp_create_instance;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := dump_error_stack;
    WHEN others THEN
      rollback to fa_grp_create_instance;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_instance_grp.create_item_instance');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      fnd_msg_pub.add;
      x_error_message := dump_error_stack;
  END create_item_instance;

  PROCEDURE copy_item_instance(
    p_fixed_asset_rec          IN     fixed_asset_rec,
    p_instance_rec             IN     csi_datastructures_pub.instance_rec,
    p_instance_serial_tbl      IN     instance_serial_tbl,
    p_eam_rec                  IN     eam_rec,
    p_copy_parties             IN     varchar2,
    p_copy_accounts            IN     varchar2,
    p_copy_contacts            IN     varchar2,
    p_copy_org_assignments     IN     varchar2,
    p_copy_asset_assignments   IN     varchar2,
    p_copy_pricing_attribs     IN     varchar2,
    p_copy_ext_attribs         IN     varchar2,
    p_copy_inst_children       IN     varchar2,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_tbl                OUT nocopy csi_datastructures_pub.instance_tbl,
    x_instance_asset_tbl          OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2)
  IS

    TYPE copy_flags_rec IS RECORD(
      copy_parties             varchar2(1),
      copy_accounts            varchar2(1),
      copy_contacts            varchar2(1),
      copy_org_assignments     varchar2(1),
      copy_asset_assignments   varchar2(1),
      copy_pricing_attribs     varchar2(1),
      copy_ext_attribs         varchar2(1),
      copy_inst_children       varchar2(1));

    l_fa_flow                  varchar2(1);
    l_copy_flags_rec           copy_flags_rec;
    l_instance_rec             csi_datastructures_pub.instance_rec;

    l_miss_num                 number := fnd_api.g_miss_num;
    l_miss_char                varchar2(200) := fnd_api.g_miss_char;

    l_instance_tbl             csi_datastructures_pub.instance_tbl;

    o_ind                      binary_integer := 0;
    o_instance_tbl             csi_datastructures_pub.instance_tbl;

    ia_ind                     binary_integer := 0;
    l_instance_asset_tbl       csi_datastructures_pub.instance_asset_tbl;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(4000);
    l_error_message            varchar2(2000);

    l_serial_control_code       number;
    l_eam_item_type             number;
    l_eam_item                  boolean := FALSE;
    l_owning_department_id      number;
    l_wip_accounting_class_code varchar2(200);
    l_parent_instance_id        number;
    l_area_id                   number;

    PROCEDURE do_copy(
      p_fa_flow         IN            varchar2,
      p_instance_rec    IN            csi_datastructures_pub.instance_rec,
      p_copy_flags_rec  IN            copy_flags_rec,
      px_csi_txn_rec    IN OUT nocopy csi_datastructures_pub.transaction_rec,
      x_instance_tbl       OUT nocopy csi_datastructures_pub.instance_tbl,
      x_return_status      OUT nocopy varchar2)
    IS
      l_instance_tbl           csi_datastructures_pub.instance_tbl;
      l_internal_party_id      number;

      l_instance_rec           csi_datastructures_pub.instance_rec;
      l_party_tbl              csi_datastructures_pub.party_tbl;
      l_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
      l_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
      l_eav_tbl                csi_datastructures_pub.extend_attrib_values_tbl;
      l_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
      l_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
      l_inst_id_lst            csi_datastructures_pub.id_tbl;

      l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
      l_msg_count              number;
      l_msg_data               varchar2(4000);
    BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      csi_item_instance_pvt.copy_item_instance(
        p_api_version            => 1.0,
        p_commit                 => fnd_api.g_false,
        p_init_msg_list          => fnd_api.g_true,
        p_validation_level       => fnd_api.g_valid_level_full,
        p_source_instance_rec    => p_instance_rec,
        p_copy_ext_attribs       => p_copy_flags_rec.copy_ext_attribs,
        p_copy_org_assignments   => p_copy_flags_rec.copy_org_assignments,
        p_copy_parties           => p_copy_flags_rec.copy_parties,
        p_copy_contacts          => p_copy_flags_rec.copy_contacts,
        p_copy_accounts          => p_copy_flags_rec.copy_accounts,
        p_copy_asset_assignments => p_copy_flags_rec.copy_asset_assignments,
        p_copy_pricing_attribs   => p_copy_flags_rec.copy_pricing_attribs,
        p_copy_inst_children     => p_copy_flags_rec.copy_inst_children,
        p_call_from_split        => fnd_api.g_false,
        p_txn_rec                => px_csi_txn_rec,
        x_new_instance_tbl       => l_instance_tbl,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF nvl(p_fa_flow, 'N') = 'Y' THEN

        IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
          csi_gen_utility_pvt.populate_install_param_rec;
        END IF;

        l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

        l_party_tbl.delete;

        SELECT instance_party_id,
               object_version_number,
               party_id
        INTO   l_party_tbl(1).instance_party_id,
               l_party_tbl(1).object_version_number,
               l_party_tbl(1).party_id
        FROM   csi_i_parties
        WHERE  instance_id = l_instance_tbl(1).instance_id  -- for copy children case need to change
        AND    relationship_type_code = 'OWNER';

        IF l_party_tbl(1).party_id <> l_internal_party_id THEN

          l_party_tbl(1).instance_id            := l_instance_tbl(1).instance_id;
          l_party_tbl(1).party_source_table     := 'HZ_PARTIES';
          l_party_tbl(1).party_id               := l_internal_party_id;
          l_party_tbl(1).relationship_type_code := 'OWNER';
          l_party_tbl(1).contact_flag           := 'N';

          -- change the owner to internal
          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_instance_rec,
            p_ext_attrib_values_tbl => l_eav_tbl,
            p_party_tbl             => l_party_tbl,
            p_account_tbl           => l_party_acct_tbl,
            p_pricing_attrib_tbl    => l_pricing_attribs_tbl,
            p_org_assignments_tbl   => l_org_units_tbl,
            p_txn_rec               => px_csi_txn_rec,
            p_asset_assignment_tbl  => l_inst_asset_tbl,
            x_instance_id_lst       => l_inst_id_lst,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END IF;

      x_instance_tbl := l_instance_tbl;

    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END do_copy;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    savepoint fa_grp_copy_instance;

    csi_item_instance_vld_pvt.check_reqd_param_num (
      p_number      => p_instance_rec.instance_id,
      p_param_name  => 'p_instance_rec.instance_id',
      p_api_name    => 'csi_fa_instance_rec.copy_item_instance');

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

    IF nvl(p_fixed_asset_rec.asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_fa_flow := 'Y';
      l_copy_flags_rec.copy_parties         := fnd_api.g_false;
      l_copy_flags_rec.copy_accounts        := fnd_api.g_false;
      l_copy_flags_rec.copy_contacts        := fnd_api.g_false;
    ELSE
      l_fa_flow := 'N';
      l_copy_flags_rec.copy_parties         := p_copy_parties;
      l_copy_flags_rec.copy_accounts        := p_copy_accounts;
      l_copy_flags_rec.copy_contacts        := p_copy_contacts;
    END IF;

    l_copy_flags_rec.copy_org_assignments   := p_copy_org_assignments;
    l_copy_flags_rec.copy_pricing_attribs   := p_copy_pricing_attribs;
    l_copy_flags_rec.copy_ext_attribs       := p_copy_ext_attribs;
    l_copy_flags_rec.copy_asset_assignments := p_copy_asset_assignments;
    l_copy_flags_rec.copy_inst_children     := p_copy_inst_children;

    -- derive eam_item_type
    IF nvl(p_instance_rec.inventory_item_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
       AND
       nvl(p_instance_rec.vld_organization_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN

      SELECT eam_item_type,
             serial_number_control_code
      INTO   l_eam_item_type,
             l_serial_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_instance_rec.inventory_item_id
      AND    organization_id   = p_instance_rec.vld_organization_id;

      IF l_eam_item_type in (1, 3) AND l_serial_control_code <> 1 THEN
        l_eam_item := TRUE;
      END IF;

    END IF;

    IF p_instance_serial_tbl.COUNT > 0 THEN

      FOR srl_ind IN p_instance_serial_tbl.FIRST .. p_instance_serial_tbl.LAST
      LOOP

        l_instance_rec := p_instance_rec;

        -- override with serial attributes
        l_instance_rec.instance_number :=
          nvl(p_instance_serial_tbl(srl_ind).instance_number, l_miss_char);
        l_instance_rec.serial_number :=
          nvl(p_instance_serial_tbl(srl_ind).serial_number, l_miss_char);
        l_instance_rec.lot_number :=
          nvl(p_instance_serial_tbl(srl_ind).lot_number, l_miss_char);
        l_instance_rec.external_reference :=
          nvl(p_instance_serial_tbl(srl_ind).external_reference, p_instance_rec.external_reference);
        l_instance_rec.instance_usage_code :=
          nvl(p_instance_serial_tbl(srl_ind).instance_usage_code, p_instance_rec.instance_usage_code);
        l_instance_rec.operational_status_code :=
          nvl(p_instance_serial_tbl(srl_ind).operational_status_code,
              p_instance_rec.operational_status_code);
        l_instance_rec.instance_description :=
          nvl(p_instance_serial_tbl(srl_ind).instance_description, p_instance_rec.instance_description);
        l_instance_rec.quantity             := 1;

        -- override with eam attributes
        l_instance_rec.asset_criticality_code :=
                       nvl(p_eam_rec.asset_criticality_code, l_miss_char);
        l_instance_rec.category_id :=
                       nvl(p_eam_rec.category_id, l_miss_num);

        do_copy(
          p_fa_flow         => l_fa_flow,
          p_instance_rec    => l_instance_rec,
          p_copy_flags_rec  => l_copy_flags_rec,
          px_csi_txn_rec    => px_csi_txn_rec,
          x_instance_tbl    => l_instance_tbl,
          x_return_status   => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          l_error_message := dump_error_stack;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_instance_tbl.COUNT > 0 THEN
          FOR inst_ind IN l_instance_tbl.FIRST .. l_instance_tbl.LAST
          LOOP
            o_ind := o_ind + 1;
            o_instance_tbl(o_ind) := l_instance_tbl(inst_ind);
          END LOOP;
        END IF;

      END LOOP;

    ELSE
      l_instance_rec := p_instance_rec;
      -- override with eam attributes
      l_instance_rec.asset_criticality_code :=
                     nvl(p_eam_rec.asset_criticality_code, l_miss_char);
      l_instance_rec.category_id :=
                     nvl(p_eam_rec.category_id, l_miss_num);

      do_copy(
        p_fa_flow         => l_fa_flow,
        p_instance_rec    => l_instance_rec,
        p_copy_flags_rec  => l_copy_flags_rec,
        px_csi_txn_rec    => px_csi_txn_rec,
        x_instance_tbl    => l_instance_tbl,
        x_return_status   => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        l_error_message := dump_error_stack;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_instance_tbl.COUNT > 0 THEN
        FOR inst_ind IN l_instance_tbl.FIRST .. l_instance_tbl.LAST
        LOOP
          o_ind := o_ind + 1;
          o_instance_tbl(o_ind) := l_instance_tbl(inst_ind);
        END LOOP;
      END IF;

    END IF;

    IF o_instance_tbl.COUNT > 0 THEN
      FOR inst_ind IN o_instance_tbl.FIRST .. o_instance_tbl.LAST
      LOOP

        IF  nvl(p_fixed_asset_rec.asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
          ia_ind := ia_ind + 1;
          l_instance_asset_tbl(ia_ind).instance_id       := o_instance_tbl(inst_ind).instance_id;
          l_instance_asset_tbl(ia_ind).fa_asset_id       := p_fixed_asset_rec.asset_id;
          l_instance_asset_tbl(ia_ind).fa_book_type_code := p_fixed_asset_rec.book_type_code;
          l_instance_asset_tbl(ia_ind).fa_location_id    := p_fixed_asset_rec.asset_location_id;
          l_instance_asset_tbl(ia_ind).asset_quantity    := o_instance_tbl(inst_ind).quantity;
          l_instance_asset_tbl(ia_ind).update_status     := 'IN_SERVICE';
          l_instance_asset_tbl(ia_ind).fa_sync_flag      := p_fixed_asset_rec.fa_sync_flag;
          l_instance_asset_tbl(ia_ind).fa_sync_validation_reqd :=
            p_fixed_asset_rec.fa_sync_validation_reqd;
        END IF;

        IF l_eam_item THEN

	  /*Need to flip the EAM attributes.*/
          IF p_eam_rec.owning_department_id = FND_API.G_MISS_NUM THEN
            l_owning_department_id := NULL;
          ELSIF p_eam_rec.owning_department_id IS  NULL THEN
            l_owning_department_id := FND_API.G_MISS_NUM;
          END IF;

          IF p_eam_rec.wip_accounting_class_code = FND_API.G_MISS_CHAR THEN
            l_wip_accounting_class_code := NULL;
          ELSIF p_eam_rec.owning_department_id IS  NULL THEN
            l_wip_accounting_class_code := FND_API.G_MISS_CHAR;
          END IF;

          IF p_eam_rec.area_id = FND_API.G_MISS_NUM THEN
            l_area_id := NULL;
          ELSIF p_eam_rec.owning_department_id IS  NULL THEN
            l_area_id := FND_API.G_MISS_NUM;
          END IF;

           IF p_eam_rec.parent_instance_id = FND_API.G_MISS_NUM THEN
            l_parent_instance_id := NULL;
          ELSIF p_eam_rec.owning_department_id IS  NULL THEN
            l_parent_instance_id := FND_API.G_MISS_NUM;
          END IF;

          eam_maint_attributes_pub.create_maint_attributes(
            p_api_version           => 1.0,
            p_init_msg_list         => fnd_api.g_true,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_id           => l_instance_tbl(inst_ind).instance_id,
            p_owning_department_id  => l_owning_department_id,
            p_accounting_class_code => l_wip_accounting_class_code,
            p_area_id               => l_area_id,
            p_parent_instance_id    => l_parent_instance_id,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

      END LOOP;
    END IF;

    IF l_instance_asset_tbl.COUNT > 0 THEN

      create_instance_assets(
        px_instance_asset_tbl  => l_instance_asset_tbl,
        px_csi_txn_rec         => px_csi_txn_rec,
        x_return_status        => l_return_status,
        x_error_message        => l_error_message);

      IF l_return_status IN (fnd_api.g_ret_sts_success, 'W') THEN
        x_return_status := l_return_status;
        x_error_message := l_error_message;
      ELSE
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    x_instance_tbl       := o_instance_tbl;
    x_instance_asset_tbl := l_instance_asset_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to fa_grp_copy_instance;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := dump_error_stack;
    WHEN others THEN
      rollback to fa_grp_copy_instance;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_instance_grp.copy_item_instance');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      fnd_msg_pub.add;
      x_error_message := dump_error_stack;
  END copy_item_instance;

  --
  PROCEDURE associate_item_instance(
    p_fixed_asset_rec          IN     fixed_asset_rec,
    p_instance_tbl             IN     csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_asset_tbl          OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2)
  IS

    l_fa_location_id          number;
    l_fa_quantity             number;
    l_fa_book_type_code       varchar2(30);

    l_instance_asset_tbl    csi_datastructures_pub.instance_asset_tbl;
    l_lookup_tbl            csi_asset_pvt.lookup_tbl;
    l_asset_count_rec       csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl          csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl         csi_asset_pvt.asset_loc_tbl;

    g_ia_ind                binary_integer := 0;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

    l_error_message         varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    debug('associate_item_isntance');

    IF p_instance_tbl.COUNT > 0 THEN

      FOR inst_ind IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
      LOOP

        g_ia_ind := g_ia_ind + 1;
        l_instance_asset_tbl(g_ia_ind).instance_id       := p_instance_tbl(inst_ind).instance_id;
        l_instance_asset_tbl(g_ia_ind).fa_asset_id       := p_fixed_asset_rec.asset_id;
        l_instance_asset_tbl(g_ia_ind).fa_book_type_code := p_fixed_asset_rec.book_type_code;
        l_instance_asset_tbl(g_ia_ind).fa_location_id    := p_fixed_asset_rec.asset_location_id;
        l_instance_asset_tbl(g_ia_ind).asset_quantity    := p_instance_tbl(inst_ind).quantity;
        l_instance_asset_tbl(g_ia_ind).update_status     := 'IN_SERVICE';

        IF nvl(p_fixed_asset_rec.asset_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
           OR
           nvl(p_fixed_asset_rec.asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num
           OR
           nvl(p_fixed_asset_rec.book_type_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
        THEN

          derive_fa_missing_values(
            p_instance_rec      => p_instance_tbl(inst_ind),
            p_fixed_asset_rec   => p_fixed_asset_rec,
            x_fa_location_id    => l_fa_location_id,
            x_fa_quantity       => l_fa_quantity,
            x_fa_book_type_code => l_fa_book_type_code,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('location_id :'||l_fa_location_id);

          IF nvl(p_fixed_asset_rec.asset_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            l_instance_asset_tbl(g_ia_ind).fa_location_id  := l_fa_location_id;
          END IF;

          IF nvl(p_fixed_asset_rec.asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            l_instance_asset_tbl(g_ia_ind).asset_quantity  := l_fa_quantity;
          END IF;

          l_instance_asset_tbl(g_ia_ind).fa_book_type_code := l_fa_book_type_code;
          l_instance_asset_tbl(g_ia_ind).fa_sync_flag := p_fixed_asset_rec.fa_sync_flag;
          l_instance_asset_tbl(g_ia_ind).fa_sync_validation_reqd  :=
            nvl(p_fixed_asset_rec.fa_sync_validation_reqd, fnd_api.g_false);

        END IF;

      END LOOP;
    END IF;

    IF l_instance_asset_tbl.COUNT > 0 THEN

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

      create_instance_assets(
        px_instance_asset_tbl  => l_instance_asset_tbl,
        px_csi_txn_rec         => px_csi_txn_rec,
        x_return_status        => l_return_status,
        x_error_message        => l_error_message);

      IF l_return_status IN (fnd_api.g_ret_sts_success, 'W')  THEN
        x_return_status := l_return_status;
        x_error_message := l_error_message;
      ELSE
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := dump_error_stack;
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_instance_grp.associate_item_instance');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      fnd_msg_pub.add;
      x_error_message := dump_error_stack;
  END associate_item_instance;

  PROCEDURE update_asset_association(
    p_instance_asset_tbl       IN     csi_datastructures_pub.instance_asset_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2)
  IS

    l_instance_asset_rec    csi_datastructures_pub.instance_asset_rec;
    l_lookup_tbl            csi_asset_pvt.lookup_tbl;
    l_asset_count_rec       csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl          csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl         csi_asset_pvt.asset_loc_tbl;
    l_warning_flag          varchar2(1) := 'N';

    l_return_status         varchar2(2000) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    IF p_instance_asset_tbl.count > 0 THEN

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

      FOR l_ind IN p_instance_asset_tbl.FIRST .. p_instance_asset_tbl.LAST
      LOOP

        l_instance_asset_rec := p_instance_asset_tbl(l_ind);

        csi_asset_pvt.update_instance_asset (
          p_api_version         => 1.0,
          p_commit              => fnd_api.g_false,
          p_init_msg_list       => fnd_api.g_true,
          p_validation_level    => fnd_api.g_valid_level_full,
          p_instance_asset_rec  => l_instance_asset_rec,
          p_txn_rec             => px_csi_txn_rec,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_lookup_tbl          => l_lookup_tbl,
          p_asset_count_rec     => l_asset_count_rec,
          p_asset_id_tbl        => l_asset_id_tbl,
          p_asset_loc_tbl       => l_asset_loc_tbl);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_instance_asset_rec.fa_sync_flag = 'N' THEN
          l_warning_flag := 'Y';
        END IF;

      END LOOP;

    END IF;

    IF l_warning_flag = 'Y' THEN
      fnd_message.set_name('CSI', 'CSI_INST_ASSET_SYNC_WARNING');
      fnd_msg_pub.add;
      x_return_status := 'W';
      x_error_message := dump_error_stack;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := dump_error_stack;
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_instance_grp.update_asset_association');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      fnd_msg_pub.add;
      x_error_message := dump_error_stack;
  END update_asset_association;

  PROCEDURE create_instance_assets(
    px_instance_asset_tbl  IN OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    px_csi_txn_rec         IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status           OUT nocopy varchar2,
    x_error_message           OUT nocopy varchar2)
  IS

    l_fixed_asset_rec       fixed_asset_rec;
    l_instance_rec          csi_datastructures_pub.instance_rec;
    l_lookup_tbl            csi_asset_pvt.lookup_tbl;
    l_asset_count_rec       csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl          csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl         csi_asset_pvt.asset_loc_tbl;

    l_asset_quantity        number;
    l_asset_location_id     number;

    l_return_status         varchar2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(2000);

    l_warning_flag          varchar2(1) := 'N';


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('create_instance_assets');

    savepoint create_instance_assets;

    IF px_instance_asset_tbl.COUNT > 0 THEN

      FOR ia_ind IN px_instance_asset_tbl.FIRST .. px_instance_asset_tbl.LAST
      LOOP

        IF nvl(px_instance_asset_tbl(ia_ind).fa_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
           OR
           nvl(px_instance_asset_tbl(ia_ind).asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num
        THEN

          l_instance_rec.instance_id          := px_instance_asset_tbl(ia_ind).instance_id;
          l_fixed_asset_rec.asset_id          := px_instance_asset_tbl(ia_ind).fa_asset_id;
          l_fixed_asset_rec.asset_location_id := px_instance_asset_tbl(ia_ind).fa_location_id;
          l_fixed_asset_rec.asset_quantity    := px_instance_asset_tbl(ia_ind).asset_quantity;

          derive_fa_missing_values(
            p_instance_rec      => l_instance_rec,
            p_fixed_asset_rec   => l_fixed_asset_rec,
            x_fa_location_id    => l_asset_location_id,
            x_fa_quantity       => l_asset_quantity,
            x_fa_book_type_code => px_instance_asset_tbl(ia_ind).fa_book_type_code,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF nvl(px_instance_asset_tbl(ia_ind).fa_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
            px_instance_asset_tbl(ia_ind).fa_location_id := l_asset_location_id;
          END IF;

          IF nvl(px_instance_asset_tbl(ia_ind).asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num
          THEN
            px_instance_asset_tbl(ia_ind).asset_quantity := l_asset_quantity;
          END IF;

        END IF;

        validate_inst_asset(
          px_inst_asset_rec     => px_instance_asset_tbl(ia_ind),
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF nvl(px_instance_asset_tbl(ia_ind).instance_asset_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

          csi_asset_pvt.create_instance_asset(
            p_api_version         => 1.0,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_instance_asset_rec  => px_instance_asset_tbl(ia_ind),
            p_txn_rec             => px_csi_txn_rec,
            p_lookup_tbl          => l_lookup_tbl,
            p_asset_count_rec     => l_asset_count_rec,
            p_asset_id_tbl        => l_asset_id_tbl,
            p_asset_loc_tbl       => l_asset_loc_tbl,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE
          null;
        END IF;

        IF px_instance_asset_tbl(ia_ind).fa_sync_flag = 'N' THEN
          l_warning_flag := 'Y';
        END IF;

      END LOOP;

    END IF;

    IF l_warning_flag = 'Y' THEN
      fnd_message.set_name('CSI', 'CSI_INST_ASSET_SYNC_WARNING');
      fnd_msg_pub.add;
      x_return_status := 'W';
      x_error_message := dump_error_stack;
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to create_instance_assets;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := dump_error_stack;
    WHEN others THEN
      rollback to create_instance_assets;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_error_message := substr(sqlerrm, 1, 2000);
  END create_instance_assets;

END csi_fa_instance_grp;

/
