--------------------------------------------------------
--  DDL for Package Body CSE_FA_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_FA_TXN_PKG" AS
/* $Header: CSEASTXB.pls 120.7 2006/06/28 22:56:10 brmanesh noship $   */


  l_debug varchar2(1) := NVL(fnd_profile.value('cse_debug_option'),'N');

  PROCEDURE debug( p_message IN varchar2) IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log, p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE create_inst_asset(
    px_inst_asset_rec   IN OUT nocopy csi_datastructures_pub.instance_asset_rec,
    px_csi_txn_rec      IN OUT nocopy csi_datastructures_pub.transaction_rec,
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
    px_inst_asset_rec   IN OUT nocopy csi_datastructures_pub.instance_asset_rec,
    px_csi_txn_rec      IN OUT nocopy csi_datastructures_pub.transaction_rec,
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

    IF nvl(px_inst_asset_rec.instance_asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      px_inst_asset_rec.fa_sync_flag := 'Y';

      SELECT object_version_number
      INTO   px_inst_asset_rec.object_version_number
      FROM   csi_i_assets
      WHERE  instance_asset_id = px_inst_asset_rec.instance_asset_id;

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

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END update_inst_asset;


  FUNCTION total_inst_asset_qty(
    p_inst_asset_tbl    IN      csi_datastructures_pub.instance_asset_header_tbl)
  RETURN number
  IS
    l_total_qty number := 0;
  BEGIN
    IF p_inst_asset_tbl.COUNT > 0 THEN
      FOR l_ind IN p_inst_asset_tbl.FIRST .. p_inst_asset_tbl.LAST
      LOOP
        l_total_qty := l_total_qty +  p_inst_asset_tbl(l_ind).asset_quantity;
      END LOOP;
    END IF;
    RETURN l_total_qty;
  END total_inst_asset_qty;


  PROCEDURE reinstate_inst_asset(
    p_inst_asset_rec        IN     csi_datastructures_pub.instance_asset_header_rec,
    p_units                 IN     number,
    px_csi_txn_rec          IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status            OUT nocopy varchar2)
  IS

    l_inst_asset_qry_rec       csi_datastructures_pub.instance_asset_query_rec;
    l_inst_asset_tbl           csi_datastructures_pub.instance_asset_header_tbl;
    l_time_stamp               date := null;

    l_total_inst_asset_qty     number := 0;
    l_inst_asset_rec           csi_datastructures_pub.instance_asset_rec;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(2000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    -- check if there is any instance asset record with in_service
    l_inst_asset_qry_rec.fa_asset_id       := p_inst_asset_rec.fa_asset_id;
    l_inst_asset_qry_rec.fa_book_type_code := p_inst_asset_rec.fa_book_type_code;
    l_inst_asset_qry_rec.fa_location_id    := p_inst_asset_rec.fa_location_id;
    l_inst_asset_qry_rec.update_status     := 'IN_SERVICE';

    csi_asset_pvt.get_instance_assets(
      p_api_version              => 1.0,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => fnd_api.g_true,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_instance_asset_query_rec => l_inst_asset_qry_rec,
      p_resolve_id_columns       => fnd_api.g_false,
      p_time_stamp               => l_time_stamp,
      x_instance_asset_tbl       => l_inst_asset_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_inst_asset_tbl.COUNT > 0 THEN

      IF l_inst_asset_tbl.COUNT = 1 THEN

        l_inst_asset_rec.instance_asset_id := l_inst_asset_tbl(1).instance_asset_id;
        l_inst_asset_rec.asset_quantity    := l_inst_asset_tbl(1).asset_quantity + p_units;

        update_inst_asset(
          px_inst_asset_rec   => l_inst_asset_rec,
          px_csi_txn_rec      => px_csi_txn_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE
        null;
      END IF;

    ELSE

      l_inst_asset_rec.instance_asset_id := p_inst_asset_rec.instance_asset_id;
      l_inst_asset_rec.update_status     := 'IN_SERVICE';
      l_inst_asset_rec.asset_quantity    := p_units;

      update_inst_asset(
        px_inst_asset_rec   => l_inst_asset_rec,
        px_csi_txn_rec      => px_csi_txn_rec,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END reinstate_inst_asset;

  PROCEDURE retire_inst_asset(
    p_inst_asset_id         IN     number,
    px_csi_txn_rec          IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status            OUT nocopy varchar2)
  IS

    l_inst_asset_rec       csi_datastructures_pub.instance_asset_rec;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_inst_asset_rec.instance_asset_id         := p_inst_asset_id;
    l_inst_asset_rec.update_status             := 'RETIRED';
    l_inst_asset_rec.active_end_date           := sysdate;
    l_inst_asset_rec.check_for_instance_expiry := fnd_api.g_false;

    update_inst_asset(
      px_inst_asset_rec   => l_inst_asset_rec,
      px_csi_txn_rec      => px_csi_txn_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END retire_inst_asset;

  PROCEDURE split_inst_asset(
    p_inst_asset_rec        IN     csi_datastructures_pub.instance_asset_header_rec,
    p_quantity              IN     number,
    px_csi_txn_rec          IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_new_inst_asset_id        OUT nocopy number,
    x_return_status            OUT nocopy varchar2)
  IS
    l_old_asset_qty        number;
    l_inst_asset_rec       csi_datastructures_pub.instance_asset_rec;
    l_lookup_tbl           csi_asset_pvt.lookup_tbl;
    l_asset_count_rec      csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl         csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl        csi_asset_pvt.asset_loc_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_old_asset_qty := p_inst_asset_rec.asset_quantity - p_quantity;

    l_inst_asset_rec.instance_asset_id := p_inst_asset_rec.instance_asset_id;
    l_inst_asset_rec.asset_quantity    := l_old_asset_qty;

    update_inst_asset(
      px_inst_asset_rec   => l_inst_asset_rec,
      px_csi_txn_rec      => px_csi_txn_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_inst_asset_rec                   := null;
    l_inst_asset_rec.instance_asset_id := fnd_api.g_miss_num;
    l_inst_asset_rec.instance_id       := p_inst_asset_rec.instance_id;
    l_inst_asset_rec.fa_asset_id       := p_inst_asset_rec.fa_asset_id;
    l_inst_asset_rec.fa_book_type_code := p_inst_asset_rec.fa_book_type_code;
    l_inst_asset_rec.fa_location_id    := p_inst_asset_rec.fa_location_id;
    l_inst_asset_rec.asset_quantity    := p_quantity;
    l_inst_asset_rec.update_status     := 'IN_SERVICE';
    l_inst_asset_rec.fa_sync_flag      := 'Y';

    create_inst_asset(
      px_inst_asset_rec   => l_inst_asset_rec,
      px_csi_txn_rec      => px_csi_txn_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END split_inst_asset;

  PROCEDURE asset_retirement(
    p_instance_id           IN     NUMBER,
    p_book_type_code        IN     VARCHAR2,
    p_asset_id              IN     NUMBER,
    p_units                 IN     NUMBER,
    p_trans_date            IN     DATE,
    p_trans_by              IN     NUMBER,
    px_txn_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_error_message            OUT NOCOPY VARCHAR2)
  IS

    l_inst_asset_qry_rec       csi_datastructures_pub.instance_asset_query_rec;
    l_inst_asset_tbl           csi_datastructures_pub.instance_asset_header_tbl;
    l_time_stamp               date := null;

    l_new_inst_asset_id        number;
    l_total_inst_asset_qty     number := 0;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('inside api cse_fa_txn_pkg.asset_retirement');

    l_inst_asset_qry_rec.instance_id       := p_instance_id;
    l_inst_asset_qry_rec.fa_asset_id       := p_asset_id;
    l_inst_asset_qry_rec.fa_book_type_code := p_book_type_code;
    l_inst_asset_qry_rec.update_status     := 'IN_SERVICE';

    csi_asset_pvt.get_instance_assets(
      p_api_version              => 1.0,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => fnd_api.g_true,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_instance_asset_query_rec => l_inst_asset_qry_rec,
      p_resolve_id_columns       => fnd_api.g_false,
      p_time_stamp               => l_time_stamp,
      x_instance_asset_tbl       => l_inst_asset_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_inst_asset_tbl.COUNT > 0 THEN

      IF nvl(px_txn_rec.transaction_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        px_txn_rec.transaction_date        := sysdate;
        px_txn_rec.source_transaction_date := sysdate;
        px_txn_rec.transaction_type_id     := 104;
        px_txn_rec.source_line_ref         := 'ASSET_ID';
        px_txn_rec.source_line_ref_id      := p_asset_id;
        px_txn_rec.source_group_ref_id     := fnd_global.conc_request_id;
        px_txn_rec.transaction_status_code := cse_datastructures_pub.g_complete;
        px_txn_rec.transaction_quantity    := p_units;
      END IF;

      IF l_inst_asset_tbl.COUNT = 1 THEN
        IF l_inst_asset_tbl(1).asset_quantity > p_units THEN

          split_inst_asset(
            p_inst_asset_rec     => l_inst_asset_tbl(1),
            p_quantity           => p_units,
            px_csi_txn_rec       => px_txn_rec,
            x_new_inst_asset_id  => l_new_inst_asset_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          retire_inst_asset(
            p_inst_asset_id      => l_new_inst_asset_id,
            px_csi_txn_rec       => px_txn_rec,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE

          retire_inst_asset(
            p_inst_asset_id      => l_inst_asset_tbl(1).instance_asset_id,
            px_csi_txn_rec       => px_txn_rec,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      ELSE  -- quantity > 1
        -- try and see if the retirement units match with the total inst asset quantity
        l_total_inst_asset_qty := total_inst_asset_qty(l_inst_asset_tbl);

        IF l_total_inst_asset_qty <=  p_units THEN
          FOR l_ind IN l_inst_asset_tbl.FIRST .. l_inst_asset_tbl.LAST
          LOOP

            retire_inst_asset(
              p_inst_asset_id      => l_inst_asset_tbl(l_ind).instance_asset_id,
              px_csi_txn_rec       => px_txn_rec,
              x_return_status      => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END LOOP;

        ELSE
          null;
          -- could not figure out which one to retire.
        END IF;

      END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END asset_retirement;

  PROCEDURE asset_reinstatement(
    p_retirement_id         IN     NUMBER,
    p_book_type_code        IN     VARCHAR2,
    p_asset_id              IN     NUMBER,
    p_units                 IN     NUMBER,
    p_trans_date            IN     DATE,
    p_trans_by              IN     NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_error_message            OUT NOCOPY VARCHAR2)
  IS

    l_inst_asset_qry_rec       csi_datastructures_pub.instance_asset_query_rec;
    l_inst_asset_tbl           csi_datastructures_pub.instance_asset_header_tbl;
    l_csi_txn_rec              csi_datastructures_pub.transaction_rec;
    l_time_stamp               date := null;
    l_new_inst_asset_id        number;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                number;
    l_msg_data                 varchar2(2000);

    CURSOR dist_cur(p_retirement_id IN number) IS
      SELECT distribution_id,
             units_assigned,
             transaction_units,
             location_id,
             assigned_to
      FROM   fa_distribution_history
      WHERE  retirement_id = p_retirement_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    FOR dist_rec IN dist_cur(p_retirement_id)
    LOOP

      l_inst_asset_qry_rec.fa_asset_id       := p_asset_id;
      l_inst_asset_qry_rec.fa_book_type_code := p_book_type_code;
      l_inst_asset_qry_rec.update_status     := 'RETIRED';
      l_inst_asset_qry_rec.fa_location_id    := dist_rec.location_id;

      csi_asset_pvt.get_instance_assets(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_full,
        p_instance_asset_query_rec => l_inst_asset_qry_rec,
        p_resolve_id_columns       => fnd_api.g_false,
        p_time_stamp               => l_time_stamp,
        x_instance_asset_tbl       => l_inst_asset_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_inst_asset_tbl.COUNT > 0 THEN

        l_csi_txn_rec.transaction_id          := fnd_api.g_miss_num;
        l_csi_txn_rec.transaction_date        := sysdate;
        l_csi_txn_rec.source_transaction_date := sysdate;
        l_csi_txn_rec.transaction_type_id     := 103;
        l_csi_txn_rec.source_line_ref         := 'ASSET_ID';
        l_csi_txn_rec.source_line_ref_id      := p_asset_id;
        l_csi_txn_rec.transaction_status_code := cse_datastructures_pub.g_complete;
        l_csi_txn_rec.transaction_quantity    := p_units;

        IF l_inst_asset_tbl.COUNT = 1 THEN

          reinstate_inst_asset(
            p_inst_asset_rec      => l_inst_asset_tbl(1),
            p_units               => p_units,
            px_csi_txn_rec        => l_csi_txn_rec,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE

          -- just reinstate one of the retired instance asset
          reinstate_inst_asset(
            p_inst_asset_rec      => l_inst_asset_tbl(1),
            p_units               => p_units,
            px_csi_txn_rec        => l_csi_txn_rec,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END asset_reinstatement;


  PROCEDURE populate_retirement_interface(
    p_csi_txn_id          IN number,
    p_asset_id            IN number,
    p_book_type_code      IN varchar2,
    p_fa_location_id      IN number,
    p_proceeds_of_sale    IN number,
    p_cost_of_removal     IN number,
    p_retirement_units    IN number,
    p_retirement_date     IN date,
    x_return_status       OUT nocopy varchar2)
  IS
    l_ext_ret_rec            fa_mass_ext_retirements%ROWTYPE;
    l_batch_name             varchar2(30);
    l_mass_ext_retire_id     number;
    l_prorate_convention     varchar2(20);

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);

    CURSOR prorate_conv_cur(p_asset_id number,p_book_type_code varchar2) IS
      SELECT fcbd.retirement_prorate_convention
      FROM   fa_category_book_defaults fcbd,
             fa_books       fb,
             fa_additions_b fab
      WHERE  fab.asset_id = p_asset_id
      AND    fb.asset_id  = fab.asset_id
      and    fb.book_type_code  = p_book_type_code
      AND    fb.date_ineffective is null
      AND    fcbd.book_type_code = fb.book_type_code
      AND    fcbd.category_id    = fab.asset_category_id;

    CURSOR fa_dist_cur(p_asset_id number,p_book_type_code varchar2, p_fa_location_id number) IS
      SELECT distribution_id,
             assigned_to,
             units_assigned
      FROM   fa_distribution_history
      WHERE  asset_id         = p_asset_id
      AND    book_type_code   = p_book_type_code
      AND    location_id      = p_fa_location_id
      AND    date_ineffective is null;

    l_units_retired number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('inside api cse_asset_txn_pkg.populate_retirement_interface');

    l_batch_name := 'CSE-'||p_csi_txn_id;

    debug('  batch_name             : '||l_batch_name);

    FOR prorate_conv_rec IN prorate_conv_cur(p_asset_id, p_book_type_code)
    LOOP
      l_prorate_convention := prorate_conv_rec.retirement_prorate_convention;
    END LOOP;

    debug('  prorate_convention     : '||l_prorate_convention);

    l_units_retired := p_retirement_units;

    FOR fa_dist_rec IN fa_dist_cur(p_asset_id, p_book_type_code, p_fa_location_id)
    LOOP

      l_units_retired := l_units_retired - fa_dist_rec.units_assigned;

      SELECT fa_mass_ext_retirements_s.nextval
      INTO   l_mass_ext_retire_id
      FROM   sys.dual ;

      debug('  fa_distribution_id     : '||fa_dist_rec.distribution_id);
      debug('  mass_ext_retire_id     : '||l_mass_ext_retire_id);

      l_ext_ret_rec.mass_external_retire_id       := l_mass_ext_retire_id;
      l_ext_ret_rec.retirement_prorate_convention := l_prorate_convention;
      l_ext_ret_rec.batch_name           := l_batch_name;
      l_ext_ret_rec.book_type_code       := p_book_type_code;
      l_ext_ret_rec.review_status        := 'POST';
      l_ext_ret_rec.retirement_type_code := 'EXTRAORDINARY';
      l_ext_ret_rec.asset_id             := p_asset_id;
      l_ext_ret_rec.date_retired         := p_retirement_date;
      l_ext_ret_rec.date_effective       := p_retirement_date;
      l_ext_ret_rec.units                := fa_dist_rec.units_assigned;
      l_ext_ret_rec.cost_of_removal      := p_cost_of_removal;
      l_ext_ret_rec.proceeds_of_sale     := p_proceeds_of_sale;
      l_ext_ret_rec.calc_gain_loss_flag  := 'N';
      l_ext_ret_rec.created_by           := fnd_global.user_id;
      l_ext_ret_rec.creation_date        := sysdate;
      l_ext_ret_rec.last_updated_by      := fnd_global.user_id;
      l_ext_ret_rec.last_update_date     := sysdate;
      l_ext_ret_rec.last_update_login    := fnd_global.login_id;
      l_ext_ret_rec.distribution_id      := fa_dist_rec.distribution_id ;

      cse_asset_adjust_pkg.insert_retirement(
        p_ext_ret_rec    => l_ext_ret_rec,
        x_return_status  => l_return_status,
        x_error_msg      => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      EXIT when l_units_retired <= 0;

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END populate_retirement_interface;


END cse_fa_txn_pkg;

/
