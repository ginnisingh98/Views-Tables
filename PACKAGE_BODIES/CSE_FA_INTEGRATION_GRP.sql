--------------------------------------------------------
--  DDL for Package Body CSE_FA_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_FA_INTEGRATION_GRP" AS
/* $Header: CSEGFAIB.pls 120.16.12010000.2 2009/09/18 19:00:29 devijay ship $ */

  l_debug    varchar2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

  FUNCTION is_oat_enabled RETURN BOOLEAN
  IS
    l_enabled_flag    char := 'N';
    l_enabled         boolean := FALSE;
    l_dummy           varchar2(40);
    l_fnd_ret         boolean;

    CURSOR ib_param_cur IS
      SELECT 'Y'
      FROM   csi_install_parameters
      WHERE  freeze_flag = 'Y';
  BEGIN

    OPEN ib_param_cur;
    FETCH ib_param_cur INTO l_enabled_flag;
    CLOSE ib_param_cur;

    IF l_enabled_flag = 'Y' THEN
      l_fnd_ret := fnd_installation.get_app_info('CSE',l_enabled_flag, l_dummy, l_dummy);
      IF l_enabled_flag = 'I' THEN
        l_enabled := TRUE;
      END IF;
    END IF;

    RETURN l_enabled;

  END is_oat_enabled;

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

  FUNCTION get_tieback_csi_txn_id(
    p_mass_addition_id       IN number,
    p_asset_id              IN number,
    p_instance_asset_id     IN number)
  RETURN number IS
    CURSOR ma_txn_cur IS
      SELECT transaction_id
      FROM   csi_transactions
      WHERE  transaction_type_id = 123
      AND    source_line_ref     = 'MASS_ADD_ID'
      AND    source_line_ref_id  = p_mass_addition_id
      ORDER by source_transaction_date desc;
    l_csi_txn_id number := fnd_api.g_miss_num;
  BEGIN
    IF p_mass_addition_id is not null THEN
      FOR ma_txn_rec IN ma_txn_cur
      LOOP
        l_csi_txn_id := ma_txn_rec.transaction_id;
        exit;
      END LOOP;
    END IF;
    RETURN l_csi_txn_id;
  END get_tieback_csi_txn_id;

  PROCEDURE create_inst_asset(
    px_csi_txn_rec      IN OUT nocopy csi_datastructures_pub.transaction_rec,
    px_inst_asset_rec   IN OUT nocopy csi_datastructures_pub.instance_asset_rec,
    x_return_status        OUT nocopy varchar2)
  IS
    l_lookup_tbl           csi_asset_pvt.lookup_tbl;
    l_asset_count_rec      csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl         csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl        csi_asset_pvt.asset_loc_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    px_inst_asset_rec.fa_sync_flag := 'Y';

    csi_asset_pvt.create_instance_asset(
      p_api_version        => 1.0 ,
      p_commit             => fnd_api.g_false,
      p_init_msg_list      => fnd_api.g_true,
      p_validation_level   => fnd_api.g_valid_level_full,
      p_instance_asset_rec => px_inst_asset_rec,
      p_txn_rec            => px_csi_txn_rec,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data ,
      p_lookup_tbl         => l_lookup_tbl,
      p_asset_count_rec    => l_asset_count_rec,
      p_asset_id_tbl       => l_asset_id_tbl,
      p_asset_loc_tbl      => l_asset_loc_tbl);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END create_inst_asset;


  PROCEDURE update_inst_asset(
    px_csi_txn_rec      IN OUT nocopy csi_datastructures_pub.transaction_rec,
    px_inst_asset_rec   IN OUT nocopy csi_datastructures_pub.instance_asset_rec,
    x_return_status        OUT nocopy varchar2)
  IS

    l_lookup_tbl           csi_asset_pvt.lookup_tbl;
    l_asset_count_rec      csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl         csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl        csi_asset_pvt.asset_loc_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    px_inst_asset_rec.fa_sync_flag := 'Y';
    px_inst_asset_rec.check_for_instance_expiry := fnd_api.g_false;

    csi_asset_pvt.update_instance_asset (
      p_api_version         => 1.0,
      p_commit              => fnd_api.g_false,
      p_init_msg_list       => fnd_api.g_true,
      p_validation_level    => fnd_api.g_valid_level_full,
      p_instance_asset_rec  => px_inst_asset_rec,
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

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END update_inst_asset;

  FUNCTION addition(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_desc_rec    IN     fa_api_types.asset_desc_rec_type,
    p_asset_fin_rec     IN     fa_api_types.asset_fin_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type)
  RETURN boolean
  IS

    l_csi_txn_rec          csi_datastructures_pub.transaction_rec;
    l_inst_asset_rec       csi_datastructures_pub.instance_asset_rec;

    l_instance_id          number;
    l_inst_asset_query_rec csi_datastructures_pub.instance_asset_query_rec;
    l_inst_asset_tbl       csi_datastructures_pub.instance_asset_header_tbl;
    l_time_stamp           date := null;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

    CURSOR cia_cur(p_mass_addition_id IN number) IS
      SELECT cia.instance_asset_id,
             cia.asset_quantity,
             cia.instance_id,
             cia.object_version_number,
             cii.inventory_item_id,
             cii.serial_number
      FROM   csi_i_assets cia,
             csi_item_instances cii
      WHERE  cia.fa_mass_addition_id = p_mass_addition_id
      AND    cii.instance_id         = cia.instance_id;

    CURSOR proj_cur(p_project_asset_line_id IN number) IS
      SELECT pei.expenditure_item_id,
             pei.orig_transaction_reference txn_ref
      FROM   pa_expenditure_items_all      pei,
             pa_project_asset_line_details ppald,
             pa_project_asset_lines_all    ppal
      WHERE  ppal.project_asset_line_id         = p_project_asset_line_id
      AND    ppald.project_asset_line_detail_id = ppal.project_asset_line_detail_id
      AND    pei.expenditure_item_id            = ppald.expenditure_item_id
      AND    pei.transaction_source             IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
      AND    pei.net_zero_adjustment_flag         = 'N'
      AND   (pei.attribute8 is not null and pei.attribute9 is not null);

  BEGIN

    savepoint cse_addition;

    IF is_oat_enabled THEN

      cse_util_pkg.set_debug;

      debug('Inside API cse_fa_integration_grp.addition');
      debug('  p_inv_tbl.count        : '||p_inv_tbl.count);
      debug('  p_asset_dist_tbl.count : '||p_asset_dist_tbl.count);

      -- invoke oat routines
      IF p_inv_tbl.COUNT > 0 THEN

        l_csi_txn_rec.transaction_type_id     := 123;
        l_csi_txn_rec.source_transaction_date := sysdate;
        l_csi_txn_rec.transaction_date        := sysdate;

        FOR p_ind IN p_inv_tbl.FIRST .. p_inv_tbl.LAST
        LOOP

          debug('  feeder_system_name  : '||p_inv_tbl(p_ind).feeder_system_name);

          IF p_inv_tbl(p_ind).feeder_system_name IN ( 'ORACLE ENTERPRISE INSTALL BASE', 'ORACLE PROJECTS') THEN

            IF p_inv_tbl(p_ind).feeder_system_name = 'ORACLE ENTERPRISE INSTALL BASE' THEN

              IF p_inv_tbl(p_ind).parent_mass_addition_id is not null THEN

                FOR cia_rec IN cia_cur (p_inv_tbl(p_ind).parent_mass_addition_id)
                LOOP

                  debug('  inst_asset_id  : '||cia_rec.instance_asset_id);

                  l_inst_asset_rec.instance_asset_id     := cia_rec.instance_asset_id;
                  l_inst_asset_rec.fa_asset_id           := p_asset_hdr_rec.asset_id;
                  l_inst_asset_rec.fa_book_type_code     := p_asset_hdr_rec.book_type_code;
                  -- assuming that there is only one distribution per addition
                  l_inst_asset_rec.fa_location_id        := p_asset_dist_tbl(1).location_ccid;
                  l_inst_asset_rec.object_version_number := cia_rec.object_version_number;

                  l_csi_txn_rec.transaction_id := get_tieback_csi_txn_id(
                    p_mass_addition_id   => p_inv_tbl(p_ind).parent_mass_addition_id,
                    p_asset_id           => p_asset_hdr_rec.asset_id,
                    p_instance_asset_id  => cia_rec.instance_asset_id);

                  update_inst_asset (
                    px_csi_txn_rec     => l_csi_txn_rec,
                    px_inst_asset_rec  => l_inst_asset_rec,
                    x_return_status    => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;

                END LOOP;

              END IF;
            ELSIF  p_inv_tbl(p_ind).feeder_system_name = 'ORACLE PROJECTS' THEN

              IF p_inv_tbl(p_ind).parent_mass_addition_id is not null THEN
                FOR proj_rec IN proj_cur(p_inv_tbl(p_ind).project_asset_line_id)
                LOOP
                  debug('  expenditure_item_id : '||proj_rec.expenditure_item_id);
                  BEGIN
                    l_instance_id:=to_number(substr(proj_rec.txn_ref,1,(instr(proj_rec.txn_ref,'-')-1)));
                  EXCEPTION
                    WHEN others THEN
                      l_instance_id := null;
                  END;
                  exit;
                END LOOP;

                debug('  instance_id    : '||l_instance_id);

                IF l_instance_id is not null THEN

                  l_inst_asset_query_rec.instance_id := l_instance_id;

                  csi_asset_pvt.get_instance_assets(
                    p_api_version              => 1.0,
                    p_commit                   => fnd_api.g_false,
                    p_init_msg_list            => fnd_api.g_true,
                    p_validation_level         => fnd_api.g_valid_level_full,
                    p_instance_asset_query_rec => l_inst_asset_query_rec,
                    p_resolve_id_columns       => fnd_api.g_false,
                    p_time_stamp               => l_time_stamp,
                    x_instance_asset_tbl       => l_inst_asset_tbl,
                    x_return_status            => l_return_status,
                    x_msg_count                => l_msg_count,
                    x_msg_data                 => l_msg_data);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  IF l_inst_asset_tbl.COUNT = 0 THEN

                    l_inst_asset_rec.fa_asset_id       := p_asset_hdr_rec.asset_id;
                    l_inst_asset_rec.fa_book_type_code := p_asset_hdr_rec.book_type_code;
                    l_inst_asset_rec.asset_quantity    := p_asset_dist_tbl(1).units_assigned;
                    l_inst_asset_rec.fa_location_id    := p_asset_dist_tbl(1).location_ccid;
                    l_inst_asset_rec.instance_id       := l_instance_Id;
                    l_inst_asset_rec.update_status     := cse_datastructures_pub.g_in_service;
                    l_inst_asset_rec.check_for_instance_expiry:= fnd_api.g_false;

                    create_inst_asset(
                      px_csi_txn_rec    => l_csi_txn_rec,
                      px_inst_asset_rec => l_inst_asset_rec,
                      x_return_status   => l_return_status);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      RAISE fnd_api.g_exc_error;
                    END IF;

                  ELSE

                    IF l_inst_asset_tbl.COUNT = 1 THEN

                      l_inst_asset_rec.instance_asset_id := l_inst_asset_tbl(1).instance_asset_id;
                      l_inst_asset_rec.fa_asset_id       := p_asset_hdr_rec.asset_id;
                      l_inst_asset_rec.fa_book_type_code := p_asset_hdr_rec.book_type_code;
                      -- assuming that there is only one distribution per addition
                      l_inst_asset_rec.fa_location_id    := p_asset_dist_tbl(1).location_ccid;
                      l_inst_asset_rec.asset_quantity    := l_inst_asset_tbl(1).asset_quantity +
                                                            p_asset_dist_tbl(1).transaction_units;
                      -- Bug 8901283 Assigning object version queried
                      -- This will fix both R12 and 12.1.1 issues
                      l_inst_asset_rec.object_version_number := l_inst_asset_tbl(1).object_version_number;

                      update_inst_asset (
                        px_csi_txn_rec    => l_csi_txn_rec,
                        px_inst_asset_rec => l_inst_asset_rec,
                        x_return_status   => l_return_status);

                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE fnd_api.g_exc_error;
                      END IF;
                    ELSE
                      null;
                    END IF;
                  END IF;

                ELSE

                  -- dump in to the staging table
                  cse_fa_stage_pkg.stage_addition(
                    p_trans_rec         => p_trans_rec,
                    p_asset_hdr_rec     => p_asset_hdr_rec,
                    p_asset_desc_rec    => p_asset_desc_rec,
                    p_asset_fin_rec     => p_asset_fin_rec,
                    p_asset_dist_tbl    => p_asset_dist_tbl,
                    p_inv_tbl           => p_inv_tbl);

                END IF; -- instance is is not null
              END IF;

            ELSE

              -- dump in to the staging table
              cse_fa_stage_pkg.stage_addition(
                p_trans_rec         => p_trans_rec,
                p_asset_hdr_rec     => p_asset_hdr_rec,
                p_asset_desc_rec    => p_asset_desc_rec,
                p_asset_fin_rec     => p_asset_fin_rec,
                p_asset_dist_tbl    => p_asset_dist_tbl,
                p_inv_tbl           => p_inv_tbl);

            END IF; -- proj or oat identifies chk

          ELSE

            -- dump in to the staging table
            cse_fa_stage_pkg.stage_addition(
              p_trans_rec         => p_trans_rec,
              p_asset_hdr_rec     => p_asset_hdr_rec,
              p_asset_desc_rec    => p_asset_desc_rec,
              p_asset_fin_rec     => p_asset_fin_rec,
              p_asset_dist_tbl    => p_asset_dist_tbl,
              p_inv_tbl           => p_inv_tbl);

          END IF;
        END LOOP;
      ELSE

        -- dump in to the staging table
        cse_fa_stage_pkg.stage_addition(
          p_trans_rec         => p_trans_rec,
          p_asset_hdr_rec     => p_asset_hdr_rec,
          p_asset_desc_rec    => p_asset_desc_rec,
          p_asset_fin_rec     => p_asset_fin_rec,
          p_asset_dist_tbl    => p_asset_dist_tbl,
          p_inv_tbl           => p_inv_tbl);

      END IF;

    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to cse_addition;
      RETURN FALSE;
    WHEN others THEN
      rollback to cse_addition;
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_integration_grp.addition');
      fnd_message.set_token('SQL_ERROR',sqlerrm);
      fnd_msg_pub.add;
      RETURN FALSE;
  END addition;

  FUNCTION unit_adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type)
  RETURN boolean
  IS
  BEGIN
    IF is_oat_enabled THEN
      -- invoke oat routines
      null;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_integration_grp.unit_adjustment');
      fnd_message.set_token('SQL_ERROR',sqlerrm);
      fnd_msg_pub.add;
      RETURN FALSE;
  END unit_adjustment;

  FUNCTION adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_fin_rec_adj IN     fa_api_types.asset_fin_rec_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type)
  RETURN boolean IS

    l_asset_id               number;
    l_book_type_code         varchar2(30);
    l_units                  number;
    l_current_units          number;
    l_location_id            number;
    l_expense_ccid           number;
    l_employee_id            number;
    l_new_dist_id            number;
    l_instance_id            number;
    l_exp_item_id            number;

    l_txn_error_id           number;
    l_txn_error_rec          csi_datastructures_pub.transaction_error_rec;

    l_xml_string             varchar2(2000);
    l_error_message          varchar2(4000);
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;

    CURSOR exp_inst_cur(p_project_asset_line_id IN number) IS
      SELECT pei.expenditure_item_id,
             pei.orig_transaction_reference txn_ref,
             pei.attribute6 item,
             pei.attribute7 serial_number,
             pei.attribute8 location,
             pei.attribute9 asset_category,
             pei.attribute10 product_class,
             ppa.location_id,
             ppa.depreciation_expense_ccid expense_ccid,
             ppa.assigned_to_person_id     employee_id
      FROM   pa_expenditure_items_all      pei,
             pa_project_asset_line_details ppald,
             pa_project_asset_lines_all    ppal,
             pa_project_assets_all         ppa
      WHERE  ppal.project_asset_line_id         = p_project_asset_line_id
      AND    ppa.project_asset_id               = ppal.project_asset_id
      AND    ppald.project_asset_line_detail_id = ppal.project_asset_line_detail_id
      AND    pei.expenditure_item_id            = ppald.expenditure_item_id
      AND    pei.transaction_source             IN ('CSE_PO_RECEIPT','CSE_INV_ISSUE')
      AND    pei.net_zero_adjustment_flag       = 'N'
      AND   (pei.attribute8 is not null and pei.attribute9 is not null);

  BEGIN
    IF is_oat_enabled THEN
      debug('inside cse_fa_integration_grp.cost_adjustment');
      -- cost adjustment only for now
      IF nvl(p_asset_fin_rec_adj.cost, 0) <> 0 THEN
        -- invoke oat routines
        IF p_inv_tbl.COUNT > 0 THEN
          FOR p_ind IN p_inv_tbl.FIRST .. p_inv_tbl.LAST
          LOOP

            debug('  feeder_system_name         : '||p_inv_tbl(p_ind).feeder_system_name);

            IF p_inv_tbl(p_ind).feeder_system_name = 'ORACLE PROJECTS' THEN

              l_asset_id           := p_asset_hdr_rec.asset_id;
              l_book_type_code     := p_asset_hdr_rec.book_type_code;

              debug('  asset_id                   : '||l_asset_id);
              debug('  book_type_code             : '||l_book_type_code);
              debug('  project_id                 : '||p_inv_tbl(p_ind).project_id);
              debug('  task_id                    : '||p_inv_tbl(p_ind).task_id);
              debug('  project_asset_line_id      : '||p_inv_tbl(p_ind).project_asset_line_id);
              debug('  transaction_type_code      : '||p_trans_rec.transaction_type_code);
              debug('  transaction_subtype        : '||p_trans_rec.transaction_subtype);
              debug('  payables_units             : '||p_inv_tbl(p_ind).payables_units);

              SELECT current_units
              INTO   l_current_units
              FROM   fa_additions
              WHERE  asset_id = l_asset_id;

              debug('  current_units              : '||l_current_units);

              l_units := p_inv_tbl(p_ind).payables_units - l_current_units;

              debug('  units_adjusted             : '||l_units);

              FOR exp_inst_rec IN exp_inst_cur(p_inv_tbl(p_ind).project_asset_line_id)
              LOOP

                l_location_id   := exp_inst_rec.location_id;
                l_expense_ccid  := exp_inst_rec.expense_ccid;
                l_employee_id   := exp_inst_rec.employee_id;
                l_exp_item_id   := exp_inst_rec.expenditure_item_id;

                BEGIN
                  l_instance_id:=to_number(substr(exp_inst_rec.txn_ref,1,(instr(exp_inst_rec.txn_ref,'-')-1)));
                EXCEPTION
                  WHEN others THEN
                    l_instance_id := null;
                END;

                debug('  expenditure_item_id        : '||exp_inst_rec.expenditure_item_id);
                debug('  txn_ref                    : '||exp_inst_rec.txn_ref);
                debug('  instance_id                : '||l_instance_id);
                debug('  location_id                : '||l_location_id);
                debug('  depreciation_expense_ccid  : '||l_expense_ccid);

                IF l_instance_id is not null THEN
                  EXIT;
                END IF;

              END LOOP;

              IF l_instance_id is not null AND l_units <> 0 THEN

                cse_util_pkg.build_error_string(l_xml_string,'ASSET_ID',l_asset_id);
                cse_util_pkg.build_error_string(l_xml_string,'BOOK_TYPE_CODE',l_book_type_code);
                cse_util_pkg.build_error_string(l_xml_string,'UNITS',l_units);
                cse_util_pkg.build_error_string(l_xml_string,'LOCATION_ID',l_location_id);
                cse_util_pkg.build_error_string(l_xml_string,'EMPLOYEE_ID',l_employee_id);
                cse_util_pkg.build_error_string(l_xml_string,'DEPRN_EXPENSE_CCID',l_expense_ccid);
                cse_util_pkg.build_error_string(l_xml_string,'INSTANCE_ID',l_instance_id);
                cse_util_pkg.build_error_string(l_xml_string,'PA_ASSET_LINE_ID',p_inv_tbl(p_ind).project_asset_line_id);
                cse_util_pkg.build_error_string(l_xml_string,'EXP_ITEM_ID', l_exp_item_id);

                l_txn_error_rec.source_id            := p_inv_tbl(p_ind).project_asset_line_id;
                l_txn_error_rec.source_type          := 'FA_UNIT_ADJUSTMENT_NORMAL';
                l_txn_error_rec.source_header_ref    := 'ASSET_ID';
                l_txn_error_rec.source_header_ref_id := l_asset_id;
                l_txn_error_rec.source_line_ref      := 'EXP_ITEM_ID';
                l_txn_error_rec.source_line_ref_id   := l_exp_item_id;
                l_txn_error_rec.processed_flag       := cse_datastructures_pub.g_bypass_flag;
                l_txn_error_rec.error_text           := l_error_message;
                l_txn_error_rec.error_stage          := cse_datastructures_pub.g_fa_update;
                l_txn_error_rec.message_string       := l_xml_string;

                debug('calling csi_transactions_pvt.create_txn_error to create unit adjustment entry');

                csi_transactions_pvt.create_txn_error(
                  p_api_version          => 1.0,
                  p_init_msg_list        => fnd_api.g_true,
                  p_commit               => fnd_api.g_false,
                  p_validation_level     => fnd_api.g_valid_level_full,
                  p_txn_error_rec        => l_txn_error_rec,
                  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data,
                  x_transaction_error_id => l_txn_error_id);

              END IF;

            END IF; -- feeder_system_name = 'ORACLE PROJECTS'
          END LOOP;
        END IF; -- p_inv_tbl.count > 0
      END IF;
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_integration_grp.adjustment');
      fnd_message.set_token('SQL_ERROR',sqlerrm);
      fnd_msg_pub.add;
      RETURN FALSE;
  END adjustment;

  FUNCTION transfer(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type)
  RETURN boolean
  IS
  BEGIN
    IF is_oat_enabled THEN
      -- invoke oat routines
      null;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_integration_grp.transfer');
      fnd_message.set_token('SQL_ERROR',sqlerrm);
      fnd_msg_pub.add;
      RETURN FALSE;
  END transfer;

  FUNCTION retire(
    p_asset_id          IN     number,
    p_book_type_code    IN     varchar2,
    p_retirement_id     IN     number,
    p_retirement_date   IN     date,
    p_retirement_units  IN     number)
  RETURN boolean
  IS
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message     varchar2(2000);
  BEGIN
    IF is_oat_enabled THEN
      null;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_integration_grp.retire');
      fnd_message.set_token('SQL_ERROR',sqlerrm);
      fnd_msg_pub.add;
      RETURN FALSE;
  END retire;

  FUNCTION reinstate(
    p_asset_id            IN   number,
    p_book_type_code      IN   varchar2,
    p_retirement_id       IN   number,
    p_reinstatement_date  IN   date,
    p_reinstatement_units IN   number)
  RETURN boolean
  IS
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message     varchar2(2000);
  BEGIN
    IF is_oat_enabled THEN
      -- invoke oat routines
      cse_fa_txn_pkg.asset_reinstatement(
        p_retirement_id   => p_retirement_id,
        p_book_type_code  => p_book_type_code,
        p_asset_id        => p_asset_id,
        p_units           => p_reinstatement_units,
        p_trans_date      => p_reinstatement_date,
        p_trans_by        => fnd_global.user_id,
        x_return_status   => l_return_status,
        x_error_message   => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','csi_fa_integration_grp.reinstate');
      fnd_message.set_token('SQL_ERROR',sqlerrm);
      fnd_msg_pub.add;
      RETURN FALSE;
  END reinstate;

END cse_fa_integration_grp;

/
