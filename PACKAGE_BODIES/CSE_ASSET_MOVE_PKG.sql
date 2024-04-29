--------------------------------------------------------
--  DDL for Package Body CSE_ASSET_MOVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_ASSET_MOVE_PKG" AS
/* $Header: CSEFAMVB.pls 120.35.12010000.5 2010/03/15 20:35:09 lakmohan ship $ */

  l_debug varchar2(1) := NVL(fnd_profile.value('CSE_DEBUG_OPTION'),'N');
  g_asset_attrib_rec cse_datastructures_pub.asset_attrib_rec ;

  TYPE fa_inst_dtls_rec IS RECORD (
    transaction_id       NUMBER,
    instance_id          NUMBER,
    instance_qty         NUMBER,
    instance_serial_number  VARCHAR2(30),
    instance_end_date    DATE,
    fa_asset_id          NUMBER,
    fa_category_id       NUMBER,
    fa_book_type_code    VARCHAR2(15),
    fa_dpi               DATE,
    fa_cost              NUMBER,
    fa_units             NUMBER,
    fa_serial_number     VARCHAR2(35),
    fa_tag_number        VARCHAR2(15),
    fa_key_ccid          NUMBER,
    fa_asset_type        VARCHAR2(11),
    fa_depreciate_flag   VARCHAR2(3),
    fa_model_number      VARCHAR2(40),
    fa_manufacturer_name VARCHAR2(30),
    fa_distribution_id   NUMBER,
    fa_location_id       NUMBER,
    fa_employee_id       NUMBER,
    fa_expense_ccid      NUMBER,
    fa_loc_units         NUMBER,
    instance_asset_id    NUMBER,
    instance_asset_qty   NUMBER);

  TYPE src_fa_inst_dtls_tbl IS  TABLE OF fa_inst_dtls_rec INDEX BY BINARY_INTEGER;
  TYPE dest_fa_inst_dtls_tbl IS  TABLE OF fa_inst_dtls_rec INDEX BY BINARY_INTEGER;

  TYPE fa_rec IS RECORD(
    fa_asset_id         NUMBER,
    fa_category_id      NUMBER,
    fa_book_type_code   VARCHAR2(15),
    fa_dpi              DATE,
    fa_cost             NUMBER,
    fa_units            NUMBER,
    fa_serial_number    VARCHAR2(30),
    fa_tag_number       VARCHAR2(15),
    fa_key_ccid         NUMBER );

  TYPE txn_id_rec IS RECORD(txn_id  number, txn_action varchar2(30), txn_error varchar2(2000));
  TYPE txn_id_tbl IS TABLE OF txn_id_rec INDEX BY binary_integer;

  PROCEDURE debug(
    p_message IN varchar2)
  IS
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

  PROCEDURE out( p_message IN varchar2)
  IS
  BEGIN
    fnd_file.put_line(fnd_file.output,p_message);
  END out;

  FUNCTION fill(
    p_column IN varchar2,
    p_width  IN number,
    p_side   IN varchar2 default 'R')
  RETURN varchar2 IS
    l_column varchar2(2000);
  BEGIN
    l_column := nvl(p_column, ' ');
    IF p_side = 'L' THEN
      return(lpad(l_column, p_width, ' '));
    ELSIF p_side = 'R' THEN
      return(rpad(l_column, p_width, ' '));
    END IF;
  END fill;

  PROCEDURE report_output(
    p_success_txn_tbl IN txn_id_tbl,
    p_failure_txn_tbl IN txn_id_tbl)
  IS

    l_total number;

    PROCEDURE header(p_header_type IN varchar2) IS
      l_string varchar2(540);
    BEGIN

      l_string := fill('Txn ID', 12, 'L')||
                  fill(' ', 2)||
                  fill('Txn Type', 30)||
                  fill('MTL Txn ID', 12);

      IF p_header_type = 'PROCESSED' THEN
        l_string := l_string||fill('Action', 12);
      ELSIF p_header_type = 'FAILED' THEN
        l_string := l_string||fill('Error Text', 36);
      END IF;

      out(l_string);

      l_string := fill('------', 12, 'L')||
                  fill(' ', 2)||
                  fill('--------', 30)||
                  fill('----------', 12);

      IF p_header_type = 'PROCESSED' THEN
        l_string := l_string||fill('------', 12);
      ELSIF p_header_type = 'FAILED' THEN
        l_string := l_string||fill('----------', 36);
      END IF;

      out(l_string);

    END header;

    PROCEDURE body(
      p_txn_id     IN number,
      p_txn_action IN varchar2,
      p_txn_error  IN varchar2,
      p_body_type  IN varchar2)
    IS
      l_txn_type_id         number;
      l_mtl_txn_id          number;
      l_txn_date            date;
      l_transacted_by       number;
      l_txn_type            varchar2(50);

      l_string              varchar2(4000);

    BEGIN
      SELECT transaction_type_id,
             inv_material_transaction_id,
             transaction_date,
             transacted_by
      INTO   l_txn_type_id,
             l_mtl_txn_id,
             l_txn_date,
             l_transacted_by
      FROM   csi_transactions
      WHERE  transaction_id = p_txn_id;

      SELECT source_txn_type_name
      INTO   l_txn_type
      FROM   csi_txn_types
      WHERE  transaction_type_id = l_txn_type_id;

      l_string := fill(p_txn_id, 12, 'L')||
                  fill(' ', 2)||
                  fill(l_txn_type, 30)||
                  fill(l_mtl_txn_id, 12);

      IF p_body_type = 'PROCESSED' THEN
        l_string := l_string||fill(p_txn_action, 12);
      END IF;

      IF p_body_type = 'FAILED' THEN
        l_string := l_string||fill(p_txn_error, 36);
      END IF;

      out(l_string);

      -- overflow error message
      IF p_body_type = 'FAILED' THEN
        l_string := ltrim(substr(p_txn_error, 37));
        l_string := fill(' ', 14)||l_string;
        out(l_string);
      END IF;

    END body;

  BEGIN

    out('                         Move Transactions Report');
    out('                         ------------------------');

    out('  Summary :-');
    out('  -------');
    out(' ');

    l_total := p_success_txn_tbl.count+p_failure_txn_tbl.count;

    out('  Total     : '||l_total);
    out('  Processed : '||p_success_txn_tbl.count);
    out('  Failed    : '||p_failure_txn_tbl.count);

    IF p_success_txn_tbl.count > 0 THEN

      out(' ');
      out(' ');
      out('  Processed Transactions - Details');
      out('  --------------------------------');

      header('PROCESSED');

      FOR l_ind IN p_success_txn_tbl.FIRST .. p_success_txn_tbl.LAST
      LOOP

        body(
          p_txn_id     => p_success_txn_tbl(l_ind).txn_id,
          p_txn_action => p_success_txn_tbl(l_ind).txn_action,
          p_txn_error  => p_success_txn_tbl(l_ind).txn_error,
          p_body_type  => 'PROCESSED');

      END LOOP;
    END IF;

    IF p_failure_txn_tbl.count > 0 THEN
      out(' ');
      out(' ');
      out('  Failed Transactions - Details');
      out('  -----------------------------');

      header('FAILED');

      FOR l_ind IN p_failure_txn_tbl.FIRST .. p_failure_txn_tbl.LAST
      LOOP
        body(
          p_txn_id     => p_failure_txn_tbl(l_ind).txn_id,
          p_txn_action => p_failure_txn_tbl(l_ind).txn_action,
          p_txn_error  => p_failure_txn_tbl(l_ind).txn_error,
          p_body_type  => 'FAILED');
      END LOOP;

    END IF;

  END report_output;

  PROCEDURE update_txn_status (
    p_src_move_trans_tbl     IN  move_trans_tbl,
    p_dest_move_trans_tbl    IN  move_trans_tbl,
    p_conc_request_id        IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_error_msg              OUT NOCOPY VARCHAR2)
  IS

    l_txn_rec                     csi_datastructures_pub.transaction_rec ;
    l_dest_txn_processed  NUMBER ;
    l_dest_txn_qty        NUMBER ;
    l_msg_index                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    l_msg_count                     NUMBER;
    l_return_status                 VARCHAR2(1);
    l_error_msg                     VARCHAR2(2000);
    l_src_transaction_id            NUMBER ;

    CURSOR csi_txn_cur (c_transaction_id IN NUMBER) IS
      SELECT object_version_number
      FROM   csi_transactions
      WHERE  transaction_id = c_transaction_id ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('Inside API update_txn_status');

    IF p_src_move_trans_tbl.COUNT > 0 THEN
      IF p_src_move_trans_tbl(1).source_transaction_type  NOT IN ('ISO_SHIPMENT', 'INTERORG_TRANS_SHIPMENT') THEN

        debug('updating source transaction');

        l_src_transaction_id := p_src_move_trans_tbl(1).transaction_id ;
        l_txn_rec := cse_util_pkg.init_txn_rec;
        l_txn_rec.transaction_id :=  p_src_move_trans_tbl(1).transaction_id ;
        l_txn_rec.source_group_ref_id := p_conc_request_id;

        l_txn_rec.transaction_status_code := cse_datastructures_pub.G_COMPLETE ;
        --For Intransit InterOrg Transfers, source txn can have multiple
        --dest transactions, in this case we will be updating source
        --txn multiple times , so get the latest object version.

        OPEN csi_txn_cur (p_src_move_trans_tbl(1).transaction_id) ;
        FETCH csi_txn_cur INTO l_txn_rec.object_version_number ;
        CLOSE csi_txn_cur ;

        debug('Inside API csi_transactions_pvt.update_transactions');
        debug('  transactio_id      : '||l_txn_rec.transaction_id);
        debug('  transaction_status : '||l_txn_rec.transaction_status_code);

        csi_transactions_pvt.update_transactions(
          p_api_version      => 1.0,
          p_init_msg_list    => fnd_api.g_true,
          p_commit           => fnd_api.g_false,
          p_validation_level => fnd_api.g_valid_level_full,
          p_transaction_rec  => l_txn_rec,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data);

        IF l_return_status <> fnd_api.G_RET_STS_success THEN
          l_error_msg := cse_util_pkg.dump_error_stack ;
          RAISE fnd_api.g_exc_error ;
        END IF;

      END IF ; ---src_move_tbl.transaction
    END IF ; --p_src_trans_tbl.COUNT > 0

    ---Now Update the Destination Txns, if it is other than source transaction.
    IF  p_dest_move_trans_tbl.COUNT > 0 THEN
      FOR j IN p_dest_move_trans_tbl.FIRST ..  p_dest_move_trans_tbl.LAST
      LOOP
        IF p_dest_move_trans_tbl(j).serial_number IS NOT NULL
           AND
           p_dest_move_trans_tbl(j).source_transaction_type IN ('ISO_REQUISITION_RECEIPT','INTERORG_TRANS_RECEIPT')
        THEN
           l_dest_txn_processed := NVL(l_dest_txn_processed,0)+1 ;
        END IF;

        l_dest_txn_qty := ABS(p_dest_move_trans_tbl(j).transaction_quantity) ;

        IF ((p_dest_move_trans_tbl(j).source_transaction_type IN ('ISO_REQUISITION_RECEIPT','INTERORG_TRANS_RECEIPT')
            AND
            l_dest_txn_processed = l_dest_txn_qty
            AND
            p_dest_move_trans_tbl(j).serial_number IS NOT NULL)
           OR
           (p_dest_move_trans_tbl(j).transaction_id <> l_src_transaction_id
            AND
           ((p_dest_move_trans_tbl(j).source_transaction_type NOT IN
              ('ISO_REQUISITION_RECEIPT','INTERORG_TRANS_RECEIPT')
           OR p_dest_move_trans_tbl(j).serial_number IS NULL))))
        THEN
          debug('updating destination transaction');

          l_dest_txn_processed := 0;

          l_txn_rec := cse_util_pkg.init_txn_rec;
          l_txn_rec.transaction_id := p_dest_move_trans_tbl(j).transaction_id ;
          l_txn_rec.source_group_ref_id := p_conc_request_id;

          l_txn_rec.transaction_status_code := cse_datastructures_pub.G_COMPLETE ;

          l_txn_rec.object_version_number:= p_dest_move_trans_tbl(j).object_version_number ;

          debug('Inside API csi_transactions_pvt.update_transactions');
          debug('  transaction_id     : '||l_txn_rec.transaction_id);
          debug('  transaction_status : '||l_txn_rec.transaction_status_code);

          csi_transactions_pvt.update_transactions(
            p_api_version      => 1.0,
            p_init_msg_list    => fnd_api.g_true,
            p_commit           => fnd_api.g_false,
            p_validation_level => fnd_api.g_valid_level_full,
            p_transaction_rec  => l_txn_rec,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

          IF l_return_status <> fnd_api.G_RET_STS_success THEN
            l_error_msg := cse_util_pkg.dump_error_stack ;
            RAISE fnd_api.g_exc_error ;
          END IF;
        END IF; ---l_dest_move_trans_tbl.
      END LOOP ; --L-dest_trans_id_tbl
    END IF ; ---L-dest_trans_id_tbl.COUNT > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      x_error_msg := l_error_msg ;
  END update_txn_status ;

  ------------------------------------------------------------------------------------------
  -- Creates a CSI Transactions record using CSI Private API.
  ------------------------------------------------------------------------------------------
  PROCEDURE create_csi_txn(
    px_txn_rec   IN OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_REC,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2)
  IS

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(200);
    l_error_msg             VARCHAR2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success ;

    px_txn_rec.object_version_number  :=  1;
    px_txn_rec.transaction_date       := sysdate;

    csi_transactions_pvt.create_transaction(
      p_api_version            => 1.0,
      p_commit                 => fnd_api.g_false,
      p_init_msg_list          => fnd_api.g_true,
      p_validation_level       => fnd_api.g_valid_level_full,
      p_success_if_exists_flag => 'Y',
      p_transaction_rec        => px_txn_rec,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := cse_util_pkg.dump_error_stack;
  END create_csi_txn;
  -----------------------------------------------------------------------------------------
  -- Derives the unit cost of the FA based on FA_UNITS and FA_COST
  -- Prorates the same for p_units_to_retire
  -- It creates a record into FA_MASS_EXT_RETIREMENTS
  -----------------------------------------------------------------------------------------
  PROCEDURE retire_asset (
    p_fa_inst_dtls_rec IN fa_inst_dtls_rec ,
    p_units_to_retire  IN NUMBER,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_error_msg        OUT NOCOPY VARCHAR2)
  IS

    l_mass_external_retire_id    number ;
    l_prorate_convention         varchar2(10);
    l_ext_ret_rec                fa_mass_ext_retirements%ROWTYPE ;
    l_sysdate                    date ;
    l_unit_cost                  number;
    l_txn_rec                    csi_datastructures_pub.transaction_rec;

    l_return_status              varchar2(1);
    l_error_msg                  varchar2(2000);

    CURSOR prorate_convention_cur ( c_book_type_code IN VARCHAR2, c_asset_id IN NUMBER) IS
      SELECT fcgd.retirement_prorate_convention
      FROM   fa_category_book_defaults fcgd,
             fa_books                  fb,
             fa_additions_b            fa
      WHERE  fa.asset_id         = c_asset_id
      AND    fb.asset_id         = fa.asset_id
      AND    fb.book_type_code   = c_book_type_code
      AND    fb.date_ineffective IS NULL
      AND    fcgd.category_id    = fa.asset_category_id
      AND    fcgd.book_type_code = fb.book_type_code
      AND    fb.date_placed_in_service
        BETWEEN fcgd.start_dpis AND NVL(fcgd.end_dpis, fb.date_placed_in_service);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    debug('Inside API retire_asset');

    SELECT sysdate INTO l_sysdate FROM sys.dual ;

    OPEN  prorate_convention_cur ( p_fa_inst_dtls_rec.fa_book_type_code, p_fa_inst_dtls_rec.fa_asset_id ) ;
    FETCH prorate_convention_cur INTO l_prorate_convention ;
    CLOSE prorate_convention_cur ;

    l_txn_rec.source_header_ref    := 'CSI_TXN_ID';
    l_txn_rec.source_header_ref_id := p_fa_inst_dtls_rec.transaction_id;

    SELECT fa_mass_ext_retirements_s.nextval
    INTO   l_mass_external_retire_id
    FROM   dual ;

    l_unit_cost :=  p_fa_inst_dtls_rec.fa_cost/p_fa_inst_dtls_rec.fa_units;

    l_ext_ret_rec.asset_id                      := p_fa_inst_dtls_rec.fa_asset_id ;
    l_ext_ret_rec.book_type_code                := p_fa_inst_dtls_rec.fa_book_type_code ;
    l_ext_ret_rec.batch_name                    := 'CSE-'||p_fa_inst_dtls_rec.instance_id;
    l_ext_ret_rec.mass_external_retire_id       := l_mass_external_retire_id ;
    l_ext_ret_rec.review_status                 := 'POST' ;
    l_ext_ret_rec.retirement_type_code          := 'EXTRAORDINARY' ;
    l_ext_ret_rec.date_retired                  := p_fa_inst_dtls_rec.instance_end_date ;
    l_ext_ret_rec.date_effective                := p_fa_inst_dtls_rec.instance_end_date ;
    l_ext_ret_rec.cost_retired                  := ROUND(l_unit_cost*p_units_to_retire,2) ;

    debug('  cost_retired : '|| l_ext_ret_rec.cost_retired);

    l_ext_ret_rec.retirement_prorate_convention := l_prorate_convention ;
    l_ext_ret_rec.units                         := p_units_to_retire ;
    l_ext_ret_rec.cost_of_removal               := 0 ;
    l_ext_ret_rec.proceeds_of_sale              := 0 ;
    l_ext_ret_rec.calc_gain_loss_flag           := 'N' ;
    l_ext_ret_rec.created_by                    := fnd_global.user_id ;
    l_ext_ret_rec.creation_date                 := l_sysdate ;
    l_ext_ret_rec.last_updated_by               := fnd_global.user_id ;
    l_ext_ret_rec.last_update_date              := l_sysdate ;
    l_ext_ret_rec.last_update_login             := fnd_global.login_id ;
    l_ext_ret_rec.distribution_id               := p_fa_inst_dtls_rec.fa_distribution_id ;

    cse_asset_adjust_pkg.insert_retirement(
      p_ext_ret_rec   => l_ext_ret_rec,
      x_return_status => l_return_status,
      x_error_msg     => l_error_msg) ;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Insert into Retirements table failed ');
      RAISE fnd_api.g_exc_error ;
    END IF ;

    cse_fa_txn_pkg.asset_retirement(
      p_instance_id     => p_fa_inst_dtls_rec.instance_id,
      p_book_type_code  => p_fa_inst_dtls_rec.fa_book_type_code,
      p_asset_id        => p_fa_inst_dtls_rec.fa_asset_id,
      p_units           => p_units_to_retire,
      p_trans_date      => l_sysdate,
      p_trans_by        => fnd_global.user_id,
      px_txn_rec        => l_txn_rec,
      x_return_status   => l_return_status,
      x_error_message   => l_error_msg);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_msg     := l_error_msg ;
  END retire_asset ;

  PROCEDURE get_fa_details (
    p_src_move_trans_rec       IN  move_trans_rec,
    x_src_fa_inst_dtls_tbl     OUT NOCOPY src_fa_inst_dtls_tbl,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2)
  IS

    i                   PLS_INTEGER := 0;
    l_prev_fa_asset_id  NUMBER ;
    l_fa_cost           NUMBER ;

    l_return_status     VARCHAR2(1);
    l_unposted_fa_cost  NUMBER;

    CURSOR src_fa_inst_dtl_cur (c_instance_id IN NUMBER) IS
      SELECT cii.instance_id,
             cii.quantity instance_qty,
             cii.serial_number instance_serial_number,
	     NVL(cii.active_end_date,sysdate) active_end_date,
             fa.asset_id fa_asset_id,
             fa.asset_category_id fa_category_id,
             fdh.book_type_code fa_book_type_code,
             fb.date_placed_in_service fa_dpi,
             fb.cost fa_cost,
             fa.current_units fa_units,
             fa.serial_number fa_serial_number,
             fa.asset_key_ccid fa_key_ccid,
             fa.tag_number fa_tag_number,
             fa.asset_type fa_asset_type,
             fa.model_number,
             fa.manufacturer_name,
             fb.depreciate_flag,
             fdh.distribution_id,
             fdh.location_id ,
             NVL(fdh.units_assigned,0) fa_loc_units,
             fdh.code_combination_id fa_depr_expense_ccid,
             fdh.assigned_to fa_employee_id,
             cia.asset_quantity instance_asset_qty,
             cia.instance_asset_id
      FROM   fa_distribution_history fdh,
             csi_i_assets cia,
             fa_additions fa,
             fa_books fb,
             csi_item_instances cii
      WHERE  cii.instance_id = c_instance_id
      AND    cia.instance_id = cii.instance_id
      AND    cia.fa_asset_id = fdh.asset_id
      AND    cia.fa_book_type_code = fdh.book_type_code
      AND    cia.fa_location_id = fdh.location_id
      AND    sysdate BETWEEN nvl(cia.active_start_date, sysdate-1) AND nvl(cia.active_end_date, sysdate+1)
      AND    fdh.date_ineffective is null
      AND    cia.fa_asset_id = fa.asset_id
      AND    fa.asset_id = fb.asset_id
      AND    cia.fa_book_type_code = fb.book_type_code
      AND    fb.date_ineffective IS NULL
      AND    cia.asset_quantity > 0
      AND    cia.fa_sync_flag = 'Y'
      AND    NOT EXISTS  (
               SELECT 'X' FROM fa_retirements fr
               WHERE fdh.retirement_id = fr.retirement_id
               AND fr.status IN ('PENDING','ERROR'))
      AND    NOT EXISTS (
               SELECT 'X' FROM fa_mass_ext_retirements fmer
               WHERE fdh.retirement_id = fmer.retirement_id
               AND fmer.review_status IN ('POST','ERROR'))
      ORDER BY fb.date_placed_in_service ;

    CURSOR unposted_famass_add_cur(c_asset_id IN NUMBER, c_book_type_code IN VARCHAR2) IS
      SELECT SUM(NVL(fma.fixed_assets_cost,0)) cost
      FROM   fa_mass_additions fma
      WHERE  fma.posting_status = 'POST'
      AND    fma.book_type_code = c_book_type_code
      AND    fma.add_to_asset_id = c_asset_id;

  BEGIN

    x_return_status  := fnd_api.g_ret_sts_success ;

    debug('Inside API get_fa_details');

    FOR src_fa_inst_dtl_rec IN src_fa_inst_dtl_cur(p_src_move_trans_rec.instance_id)
    LOOP

      i := i+1;

      OPEN  unposted_famass_add_cur (src_fa_inst_dtl_rec.fa_asset_id, src_fa_inst_dtl_rec.fa_book_type_code) ;
      FETCH unposted_famass_add_cur INTO l_unposted_fa_cost ;
      CLOSE unposted_famass_add_cur ;

      l_fa_cost := src_fa_inst_dtl_rec.fa_cost + NVL(l_unposted_fa_cost,0) ;

      x_src_fa_inst_dtls_tbl(i).transaction_id         := p_src_move_trans_rec.transaction_id;
      x_src_fa_inst_dtls_tbl(i).instance_id            := src_fa_inst_dtl_rec.instance_id ;
      x_src_fa_inst_dtls_tbl(i).instance_qty           := src_fa_inst_dtl_rec.instance_qty ;
      x_src_fa_inst_dtls_tbl(i).instance_serial_number := src_fa_inst_dtl_rec.instance_serial_number ;
      x_src_fa_inst_dtls_tbl(i).instance_end_date      := src_fa_inst_dtl_rec.active_end_date;
      x_src_fa_inst_dtls_tbl(i).fa_asset_id            := src_fa_inst_dtl_rec.fa_asset_id ;
      x_src_fa_inst_dtls_tbl(i).fa_category_id         := src_fa_inst_dtl_rec.fa_category_id ;
      x_src_fa_inst_dtls_tbl(i).fa_book_type_code      := src_fa_inst_dtl_rec.fa_book_type_code ;
      x_src_fa_inst_dtls_tbl(i).fa_dpi                 := src_fa_inst_dtl_rec.fa_dpi ;
      x_src_fa_inst_dtls_tbl(i).fa_cost                := l_fa_cost ;
      x_src_fa_inst_dtls_tbl(i).fa_units               := src_fa_inst_dtl_rec.fa_units ;
      x_src_fa_inst_dtls_tbl(i).fa_serial_number       := src_fa_inst_dtl_rec.fa_serial_number ;
      x_src_fa_inst_dtls_tbl(i).fa_key_ccid            := src_fa_inst_dtl_rec.fa_key_ccid ;
      x_src_fa_inst_dtls_tbl(i).fa_tag_number          := src_fa_inst_dtl_rec.fa_tag_number ;
      x_src_fa_inst_dtls_tbl(i).fa_asset_type          := src_fa_inst_dtl_rec.fa_asset_type ;
      x_src_fa_inst_dtls_tbl(i).fa_depreciate_flag     := src_fa_inst_dtl_rec.depreciate_flag ;
      x_src_fa_inst_dtls_tbl(i).fa_model_number        := src_fa_inst_dtl_rec.model_number ;
      x_src_fa_inst_dtls_tbl(i).fa_manufacturer_name   := src_fa_inst_dtl_rec.manufacturer_name ;
      x_src_fa_inst_dtls_tbl(i).fa_distribution_id     := src_fa_inst_dtl_rec.distribution_id ;
      x_src_fa_inst_dtls_tbl(i).fa_loc_units           := src_fa_inst_dtl_rec.fa_loc_units ;
      x_src_fa_inst_dtls_tbl(i).fa_location_id         := src_fa_inst_dtl_rec.location_id ;
      x_src_fa_inst_dtls_tbl(i).fa_expense_ccid        := src_fa_inst_dtl_rec.fa_depr_expense_ccid ;
      x_src_fa_inst_dtls_tbl(i).fa_employee_id         := src_fa_inst_dtl_rec.fa_employee_id ;
      x_src_fa_inst_dtls_tbl(i).instance_asset_qty     := src_fa_inst_dtl_rec.instance_asset_qty ;
      x_src_fa_inst_dtls_tbl(i).instance_asset_id      := src_fa_inst_dtl_rec.instance_asset_id ;

      l_prev_fa_asset_id := src_fa_inst_dtl_rec.fa_asset_id ;

      debug(' asset record # : '||i);
      debug('  instance_id          : '||src_fa_inst_dtl_rec.instance_id);
      debug('  serial_number        : '||src_fa_inst_dtl_rec.instance_serial_number);
      debug('  instance_asset_id    : '||src_fa_inst_dtl_rec.instance_asset_id);
      debug('  asset_id             : '||src_fa_inst_dtl_rec.fa_asset_id);
      debug('  asset_category_id    : '||src_fa_inst_dtl_rec.fa_category_id);
      debug('  asset_units          : '||src_fa_inst_dtl_rec.fa_units);
      debug('  asset_location_id    : '||src_fa_inst_dtl_rec.location_id);
      debug('  asset_dist_id        : '||src_fa_inst_dtl_rec.distribution_id);
      debug('  asset_employee_id    : '||src_fa_inst_dtl_rec.fa_employee_id);

    END LOOP; --src_fa_inst_dtl_rec

  END get_fa_details ;

  -----------------------------------------------------------------------------------------------
  -- Its a wrapper around get, update and create_instance_asset API.
  -- Callers will set the rec. If the rec is set with the instance_asset_id, then it is Update.
  -- If record does not have the instance_asset_id, then this proc will first search for meatching rec using get
  -- If it finds one, it will update else it will create.
  -- Callers will pass +ve to increment the instance-asset by p_transaction_units or -ve to decrement.
  -----------------------------------------------------------------------------------------------
  PROCEDURE update_inst_asset (
    p_inst_asset_rec IN csi_datastructures_pub.instance_asset_rec ,
    p_transaction_units IN NUMBER,
    p_csi_txn_rec    IN csi_datastructures_pub.transaction_rec,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_error_msg      OUT NOCOPY VARCHAR2)
  IS

    ---Variables require for calling Pub API's
    l_msg_count               NUMBER;
    l_msg_index               NUMBER;
    l_msg_data                VARCHAR2(200);
    l_error_msg           VARCHAR2(2000);
    l_return_status           VARCHAR2(1);
    l_time_stamp              DATE ;
    l_sysdate                 DATE ;

    --Specific to the API's here
    l_dest_inst_asset_query_rec   csi_datastructures_pub.instance_asset_query_rec ;
    l_dest_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_dest_inst_asset_header_tbl  csi_datastructures_pub.instance_asset_header_tbl;
    l_dest_asset_tbl              cse_datastructures_pub.asset_query_tbl;
    l_asset_id_tbl                csi_asset_pvt.asset_id_tbl ;
    l_asset_loc_tbl               csi_asset_pvt.asset_loc_tbl ;
    l_lookup_tbl                  csi_asset_pvt.lookup_tbl ;
    l_asset_count_rec             csi_asset_pvt.asset_count_rec ;

    ---Local variables only for this spec.
    l_inst_asset_rec              csi_datastructures_pub.instance_asset_rec ;
    l_csi_txn_rec                 csi_datastructures_pub.transaction_rec ;

    CURSOR inst_asset_cur (c_instance_asset_id IN NUMBER) IS
      SELECT cia.object_version_number
      FROM   csi_i_assets cia
      WHERE  cia.instance_asset_id = c_instance_asset_id ;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success ;

    debug('Inside API update_inst_asset');

    debug('  p_transaction_units  : '||p_transaction_units);
    debug('  instance_asset_id    : '||p_inst_asset_rec.instance_asset_id);
    debug('  instance_id          : '||p_inst_asset_rec.instance_id);
    debug('  fa_book_type_code    : '||p_inst_asset_rec.fa_book_type_code);
    debug('  fa_location_id       : '||p_inst_asset_rec.fa_location_id);
    debug('  active_end_date      : '||p_inst_asset_rec.active_end_date);
    debug('  inst_asset_qty       : '||p_inst_asset_rec.asset_quantity);

    ---Init Constatnts
    l_time_stamp   := NULL ;

    SELECT sysdate
    INTO   l_sysdate
    FROM   sys.DUAL ;

    l_csi_txn_rec    := p_csi_txn_rec ;
    l_inst_asset_rec := p_inst_asset_rec ;

    IF nvl(p_inst_asset_rec.instance_asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      l_inst_asset_rec.asset_quantity := l_inst_asset_rec.asset_quantity + p_transaction_units ;
      l_inst_asset_rec.check_for_instance_expiry := fnd_api.G_FALSE ;

      OPEN  inst_asset_cur (p_inst_asset_rec.instance_asset_id);
      FETCH inst_asset_cur INTO l_inst_asset_rec.object_version_number ;
      CLOSE inst_asset_cur ;

      IF l_inst_asset_rec.asset_quantity <= 0 THEN
        l_inst_asset_rec.active_end_date := sysdate;
      END IF;

      debug('Calling csi_asset_pvt.update_instance_asset');

      csi_asset_pvt.update_instance_asset (
        p_api_version         => 1.0,
        p_commit              => fnd_api.g_false,
        p_init_msg_list       => fnd_api.g_false,
        p_validation_level    => fnd_api.g_valid_level_full,
        p_instance_asset_rec  => l_inst_asset_rec,
        p_txn_rec             => l_csi_txn_rec,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data,
        p_lookup_tbl          => l_lookup_tbl,
        p_asset_count_rec     => l_asset_count_rec,
        p_asset_id_tbl        => l_asset_id_tbl,
        p_asset_loc_tbl       => l_asset_loc_tbl );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        l_error_msg := cse_util_pkg.dump_error_stack ;
        RAISE fnd_api.g_exc_error;
      END IF ;
    ELSE

      --Call get_inst_asset API
      l_dest_inst_asset_query_rec                   := cse_util_pkg.init_instance_asset_query_rec;

      l_dest_inst_asset_query_rec.update_status     := cse_datastructures_pub.g_in_service;
      l_dest_inst_asset_query_rec.instance_id       := l_inst_asset_rec.instance_id;
      l_dest_inst_asset_query_rec.fa_asset_id       := l_inst_asset_rec.fa_asset_id;
      l_dest_inst_asset_query_rec.fa_location_id    := l_inst_asset_rec.fa_location_id;
      l_dest_inst_asset_query_rec.fa_book_type_code := l_inst_asset_rec.fa_book_type_code;

      debug('Inside API csi_asset_pvt.get_instance_assets');

      csi_asset_pvt.get_instance_assets(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_false,
        p_validation_level         => fnd_api.g_valid_level_full,
        p_instance_asset_query_rec => l_dest_inst_asset_query_rec,
        p_resolve_id_columns       => NULL ,
        p_time_stamp               => l_time_stamp ,
        x_instance_asset_tbl       => l_dest_inst_asset_header_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        l_error_msg := cse_util_pkg.dump_error_stack ;
        RAISE fnd_api.g_exc_error ;
      END IF ;

      debug('  x_inst_asset_tbl.count : '||l_dest_inst_asset_header_tbl.count);

      IF l_dest_inst_asset_header_tbl.COUNT=1 THEN
        -- update destination instance Asset
        l_dest_inst_asset_tbl(1).instance_asset_id         := l_dest_inst_asset_header_tbl(1).instance_asset_id;
        l_dest_inst_asset_tbl(1).instance_id               := l_dest_inst_asset_header_tbl(1).instance_id;
        l_dest_inst_asset_tbl(1).asset_quantity :=
          l_dest_inst_asset_header_tbl(1).asset_quantity  + p_transaction_units;
        l_dest_inst_asset_tbl(1).object_version_number     := l_dest_inst_asset_header_tbl(1).object_version_number;
        l_dest_inst_asset_tbl(1).active_end_date           := p_inst_asset_rec.active_end_date;
        l_dest_inst_asset_tbl(1).check_for_instance_expiry := fnd_api.g_false;

        debug('Inside API csi_asset_pvt.update_instance_asset');
        debug('  instance_asset_id    : '||l_dest_inst_asset_tbl(1).instance_asset_id);
        debug('  instance_asset_qty   : '||l_dest_inst_asset_tbl(1).asset_quantity);

        csi_asset_pvt.update_instance_asset (
          p_api_version         => 1.0,
          p_commit              => fnd_api.g_false,
          p_init_msg_list       => fnd_api.g_false,
          p_validation_level    => fnd_api.g_valid_level_full,
          p_instance_asset_rec  => l_dest_inst_asset_tbl(1),
          p_txn_rec             => l_csi_txn_rec,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_lookup_tbl          => l_lookup_tbl,
          p_asset_count_rec     => l_asset_count_rec,
          p_asset_id_tbl        => l_asset_id_tbl,
          p_asset_loc_tbl       => l_asset_loc_tbl );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          l_error_msg := cse_util_pkg.dump_error_stack ;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        ---Create a new destination Instance
        l_dest_inst_asset_tbl(1).update_status         := cse_datastructures_pub.G_IN_SERVICE ;
        l_dest_inst_asset_tbl(1).object_version_number := 1 ;
        l_dest_inst_asset_tbl(1).instance_id           := l_inst_asset_rec.instance_id ;
        l_dest_inst_asset_tbl(1).fa_asset_id           := l_inst_asset_rec.fa_asset_id ;
        l_dest_inst_asset_tbl(1).fa_location_id        := l_inst_asset_rec.fa_location_id ;
        l_dest_inst_asset_tbl(1).fa_book_type_code     := l_inst_asset_rec.fa_book_type_code ;
        l_dest_inst_asset_tbl(1).active_start_date     := l_sysdate;
        l_dest_inst_asset_tbl(1).asset_quantity        := p_transaction_units ;
        l_dest_inst_asset_tbl(1).check_for_instance_expiry := fnd_api.G_FALSE ;
        l_dest_inst_asset_tbl(1).fa_sync_flag              := 'Y';
        l_dest_inst_asset_tbl(1).fa_sync_validation_reqd   := fnd_api.g_false;

        debug('Inside API csi_asset_pvt.create_instance_asset');
        debug('  fa_asset_id          : '||l_dest_inst_asset_tbl(1).fa_asset_id);
        debug('  fa_book_type_code    : '||l_dest_inst_asset_tbl(1).fa_book_type_code);
        debug('  fa_location_id       : '||l_dest_inst_asset_tbl(1).fa_location_id);
        debug('  instance_asset_qty   : '||l_dest_inst_asset_tbl(1).asset_quantity);

        csi_asset_pvt.create_instance_asset (
          p_api_version         => 1.0,
          p_commit              => fnd_api.g_false,
          p_init_msg_list       => fnd_api.g_false,
          p_validation_level    => fnd_api.g_valid_level_full,
          p_instance_asset_rec  => l_dest_inst_asset_tbl(1),
          p_txn_rec             => l_csi_txn_rec,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_lookup_tbl          => l_lookup_tbl,
          p_asset_count_rec     => l_asset_count_rec,
          p_asset_id_tbl        => l_asset_id_tbl,
          p_asset_loc_tbl       => l_asset_loc_tbl );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          l_error_msg := cse_util_pkg.dump_error_stack ;
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('  instance_asset_id    : '||l_dest_inst_asset_tbl(1).instance_asset_id);

      END IF ;---dest instance asset found
    END IF ; -- p_src_inst_asset_rec.instance_asset_id IS NOT NULL

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
      x_error_msg     := l_error_msg ;
  END update_inst_asset ;

  PROCEDURE do_dist_transfer (
    p_src_fa_inst_dtls_rec IN  fa_inst_dtls_rec,
    p_dest_move_trans_rec  IN  move_trans_rec,
    p_dest_fa_dist_rec     IN  cse_datastructures_pub.distribution_rec,
    p_transaction_units    IN  NUMBER,
    p_csi_txn_rec          IN  csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_error_msg            OUT NOCOPY VARCHAR2 )
  IS
    l_api_version         NUMBER ;
    l_calling_fn          VARCHAR2(30) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_trans_rec          FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec      FA_API_TYPES.asset_hdr_rec_type;
    l_asset_dist_tbl     FA_API_TYPES.asset_dist_tbl_type ;
    i                    PLS_INTEGER ;
    l_transaction_units  NUMBER ;
    l_upd_csi_i_assets   VARCHAR2(1);
    l_hook_used          number;
    l_fnd_success       VARCHAR2(1);
    l_fnd_error         VARCHAR2(1);
    l_asset_attrib_rec  CSE_DATASTRUCTURES_PUB.asset_attrib_rec;

    temp_str            VARCHAR2(512);
    l_src_inst_asset_rec csi_datastructures_pub.instance_asset_rec ;
    l_dest_inst_asset_rec csi_datastructures_pub.instance_asset_rec ;

    e_error EXCEPTION  ;
    l_error_msg VARCHAR2(2000);


  BEGIN

    l_fnd_success := FND_API.G_RET_STS_SUCCESS;
    l_fnd_error := FND_API.G_RET_STS_ERROR;
    x_return_status  := l_fnd_success ;
    l_calling_fn := 'OAT';
    l_upd_csi_i_assets := 'N';

    IF p_src_fa_inst_dtls_rec.fa_location_id <> p_dest_fa_dist_rec.location_id THEN
      debug('Source and Destination Location are different, perfroming Dist. Transfer');

      ---Set Asset Hdr details.
      l_asset_hdr_rec.asset_id := p_src_fa_inst_dtls_rec.fa_asset_id ;
      l_asset_hdr_rec.book_type_code := p_src_fa_inst_dtls_rec.fa_book_type_code ;

      --Set Dist. Table
      --Set a FROM rec from where units should be transfered.
      i := 1 ;

      l_asset_dist_tbl(i).distribution_id := p_src_fa_inst_dtls_rec.fa_distribution_id ;
      l_asset_dist_tbl(i).transaction_units   := (-1)*p_transaction_units ;
      debug('Source Distribution ID : '|| l_asset_dist_tbl(i).distribution_id);
      debug('Source Transaction units: '|| l_asset_dist_tbl(i).transaction_units);

      --Set a TO rec where location is being transferred.
      i:=i+1 ;
      l_asset_dist_tbl(i).transaction_units   := p_transaction_units ;
      l_asset_dist_tbl(i).location_ccid  := p_dest_fa_dist_rec.location_id ;
      l_asset_dist_tbl(i).assigned_to  := p_dest_fa_dist_rec.employee_id ;
      l_asset_dist_tbl(i).expense_ccid  := p_dest_fa_dist_rec.deprn_expense_ccid ;

      ---Set the FA Transaction Rec
      l_trans_rec.who_info.last_updated_by := fnd_global.user_id ;
      l_trans_rec.who_info.last_update_login := fnd_global.login_id ;

      debug('FA Asset ID : '|| l_asset_hdr_rec.asset_id );

      debug('FA Book : '|| l_asset_hdr_rec.book_type_code );

    -- Bug 9433941 (FP of bug 8422679)
      -- Get Employee Id from Stub
      debug('Calling cse_asset_client_ext_stub.get_employee');
      cse_asset_client_ext_stub.get_employee(
        p_asset_attrib_rec  => l_asset_attrib_rec
      , x_employee_id         => l_asset_dist_tbl(i).assigned_to
      , x_hook_used           => l_hook_used
      , x_error_msg           => l_error_msg
      );

      IF l_hook_used = 0 THEN
        l_asset_dist_tbl(i).assigned_to := p_dest_fa_dist_rec.employee_id;
      END IF;
      -- End 8422679

      debug('Destination Location ID :'|| l_asset_dist_tbl(i).location_ccid );
      debug('Destination Assigned ID :'|| l_asset_dist_tbl(i).assigned_to );

      l_asset_attrib_rec.Transaction_ID :=p_csi_txn_rec.source_header_ref_id; --Bug 5893220

      cse_asset_client_ext_stub.get_deprn_expense_ccid(
 	         p_asset_attrib_rec  => l_asset_attrib_rec,
 	         x_deprn_expense_ccid  => l_asset_dist_tbl(i).expense_ccid,
 	         x_hook_used           => l_hook_used,
 	         x_error_msg           => l_error_msg);
	IF l_hook_used = 0 THEN
 	l_asset_dist_tbl(i).expense_ccid := p_dest_fa_dist_rec.deprn_expense_ccid;
 	END IF;
      debug('Destination Expense CCID :'|| l_asset_dist_tbl(i).expense_ccid );
      debug('Destination Transaction Units :'|| l_asset_dist_tbl(i).transaction_units );

      fa_transfer_pub.do_transfer (
        p_api_version  => 1.0 ,
        p_init_msg_list       => fnd_api.g_false,
        p_commit              => fnd_api.g_false,
        p_validation_level    => fnd_api.g_valid_level_full,
        p_calling_fn          => l_calling_fn ,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data ,
        px_trans_rec          => l_trans_rec,
        px_asset_hdr_rec      => l_asset_hdr_rec,
        px_asset_dist_tbl     => l_asset_dist_tbl);

      --Get the message the way FA does.

      debug('After calling fa_transfer_pub.do_transfer : '|| l_return_status );
      IF (l_return_status = l_fnd_error) THEN
        l_error_msg := cse_util_pkg.dump_error_stack;
        debug('Error :'||l_error_msg);
        RAISE e_error ;
      END IF;
      l_upd_csi_i_assets := 'Y';
    ELSE

      IF p_src_fa_inst_dtls_rec.instance_id = p_dest_move_trans_rec.instance_id THEN
        ---As FA Locations are same and also the Instance ID's are same, no need to take any action.
        debug('Both Source and Destination Location and also Instances are same, no updates are required');
        l_upd_csi_i_assets := 'N' ;
      ELSE
        debug('Both Source and Destination Location are same but Instances are different, updating just CIA');
        l_upd_csi_i_assets := 'Y';
      END IF ;
    END IF ; --p_src_fa_inst_dtls_rec.fa_location_id <> p_dest_fa_location_id

    IF l_upd_csi_i_assets = 'Y' THEN
      debug('Updating Inst-Asset link ');
      ---Now update the Source CSI_I_ASSETS.
      l_src_inst_asset_rec.instance_asset_id := p_src_fa_inst_dtls_rec.instance_asset_id ;
      l_src_inst_asset_rec.asset_quantity := p_src_fa_inst_dtls_rec.instance_asset_qty ;
      l_transaction_units := (-1)*p_transaction_units ;

      update_inst_asset (
        p_inst_asset_rec     => l_src_inst_asset_rec,
        p_transaction_units  => l_transaction_units,
        p_csi_txn_rec        => p_csi_txn_rec,
        x_return_status      => l_return_status,
        x_error_msg          => l_error_msg);

      debug('After  Source update  Inst-Asset link '|| l_return_status ); --???
      IF l_return_status = l_fnd_error THEN
        debug('Source  Inst-Asset link Failed'); --???
        RAISE e_error ;
      END IF ;

      ---Update Destination Instance Asset.
      l_dest_inst_asset_rec := NULL ;
      l_dest_inst_asset_rec.instance_id        := p_dest_move_trans_rec.instance_id ;
      l_dest_inst_asset_rec.fa_asset_id        := p_src_fa_inst_dtls_rec.fa_asset_id ;
      l_dest_inst_asset_rec.fa_book_type_code  := p_src_fa_inst_dtls_rec.fa_book_type_code ;
      l_dest_inst_asset_rec.fa_location_id     := p_dest_fa_dist_rec.location_id ;

      l_transaction_units := p_transaction_units ;
      debug('Before Dest update  Inst-Asset link '); --???

      update_inst_asset (
        p_inst_asset_rec     => l_dest_inst_asset_rec,
        p_transaction_units => l_transaction_units,
        p_csi_txn_rec        => p_csi_txn_rec,
        x_return_status      => l_return_status,
        x_error_msg          => l_error_msg);

      debug('After  Dest update  Inst-Asset link '|| l_return_status ); --???

      IF l_return_status = l_fnd_error THEN
        debug('Destination  Inst-Asset link Failed'); --???
        RAISE e_error ;
      END IF ;
    END IF ; --l_upd_csi_i_assets = 'Y

  EXCEPTION
    WHEN e_error THEN
      x_return_status := l_fnd_error ;
      x_error_msg := l_error_msg ;
      debug ('Error in do_dist_transfer : '|| x_error_msg);
    WHEN OTHERS THEN
      x_return_status  := l_fnd_error ;
      x_error_msg := l_error_msg || SQLERRM;
      debug ('OTHERS- in do_dist_transfer '||x_error_msg);
  END do_dist_transfer ;

  -----------------------------------------------------------------------------------------------
  -- This process  Retires the "Source" Instance's Assocaited FA
  -- Finds the "Destination" FA in FA Mass Add or FA
  -- If Found updates the FA else creates a new FA
  -----------------------------------------------------------------------------------------------

  PROCEDURE do_inter_asset_transfer(
    p_src_fa_inst_dtls_rec IN  fa_inst_dtls_rec,
    p_dest_move_trans_rec  IN  move_trans_rec,
    p_dest_fa_rec          IN  fa_rec,
    p_dest_fa_dist_rec     IN  cse_datastructures_pub.distribution_rec,
    p_transaction_units    IN  NUMBER,
    p_csi_txn_rec          IN  csi_datastructures_pub.transaction_rec,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_error_msg            OUT NOCOPY VARCHAR2)
  IS
    l_return_status       VARCHAR2(1);
    l_error_message       VARCHAR2(2000);
    l_inst_tbl            cse_asset_creation_pkg.instance_tbl;
    l_err_inst_rec        cse_asset_creation_pkg.instance_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    retire_asset (
      p_fa_inst_dtls_rec => p_src_fa_inst_dtls_rec,
      p_units_to_retire  => p_transaction_units,
      x_return_status    => l_return_status,
      x_error_msg        => l_error_message);

    IF l_return_status =  fnd_api.G_RET_STS_ERROR THEN
      RAISE fnd_api.g_exc_error;
    END IF ;


    l_inst_tbl(1).instance_id            := p_dest_move_trans_rec.instance_id;
    l_inst_tbl(1).csi_txn_id             := p_dest_move_trans_rec.transaction_id;
    l_inst_tbl(1).csi_txn_type_id        := p_dest_move_trans_rec.transaction_type_id;
    l_inst_tbl(1).csi_txn_date           := p_dest_move_trans_rec.transaction_date;
    l_inst_tbl(1).mtl_txn_id             := p_dest_move_trans_rec.inv_material_transaction_id;
    l_inst_tbl(1).mtl_txn_date           := p_dest_move_trans_rec.transaction_date;
    l_inst_tbl(1).mtl_txn_qty            := p_dest_move_trans_rec.transaction_quantity;
    l_inst_tbl(1).quantity               := p_transaction_units;
    l_inst_tbl(1).inventory_item_id      := p_dest_move_trans_rec.inv_item_id;
    l_inst_tbl(1).organization_id        := p_dest_move_trans_rec.inv_org_id;
    l_inst_tbl(1).subinventory_code      := p_dest_move_trans_rec.inv_subinventory_name;
    l_inst_tbl(1).serial_number          := null;
    l_inst_tbl(1).location_type_code     := p_dest_move_trans_rec.location_type_code;
    l_inst_tbl(1).location_id            := p_dest_move_trans_rec.location_id;
    --l_inst_tbl(1).asset_description      := l_dest_asset_query_rec.description;
    l_inst_tbl(1).asset_unit_cost        :=
      p_src_fa_inst_dtls_rec.fa_cost/p_src_fa_inst_dtls_rec.fa_units ;
    l_inst_tbl(1).asset_cost             :=
      ROUND(l_inst_tbl(1).asset_unit_cost * p_transaction_units, 2) ;
    l_inst_tbl(1).asset_category_id      := p_dest_fa_rec.fa_category_id ;
    l_inst_tbl(1).book_type_code         := p_dest_fa_rec.fa_book_type_code ;
    l_inst_tbl(1).date_placed_in_service := p_dest_fa_rec.fa_dpi;
    l_inst_tbl(1).asset_key_ccid         := p_dest_fa_rec.fa_key_ccid;
    l_inst_tbl(1).asset_location_id      := p_dest_fa_dist_rec.location_id;
    l_inst_tbl(1).deprn_expense_ccid     := p_dest_fa_dist_rec.deprn_expense_ccid;
    l_inst_tbl(1).payables_ccid          := p_dest_fa_rec.fa_key_ccid;
    l_inst_tbl(1).employee_id            := p_dest_fa_dist_rec.employee_id;
    l_inst_tbl(1).tag_number             := p_dest_fa_rec.fa_tag_number;
    --l_inst_tbl(1).model_number           := l_model_number;
    --l_inst_tbl(1).manufacturer_name      := l_manufacturer_name;
    --l_inst_tbl(1).group_asset_id         := l_default_group_asset_id;
    --l_inst_tbl(1).search_method          := l_search_method;

    cse_asset_creation_pkg.create_asset(
      p_inst_tbl       => l_inst_tbl,
      x_return_status  => l_return_status,
      x_err_inst_rec   => l_err_inst_rec);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_msg     := l_error_message ;
  END do_inter_asset_transfer ;

  PROCEDURE process_adjustment_trans(
    p_transaction_id    IN  NUMBER,
    p_conc_request_id   IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_error_msg         OUT NOCOPY VARCHAR2)
  IS

    CURSOR cse_neg_adj_cur IS
      SELECT ct.transaction_id,
             cii.instance_id ,
             DECODE(cii.serial_number, NULL, mmt.primary_quantity, 1) primary_units,
             cii.serial_number,
             Nvl(mmt.inventory_item_id, cii.inventory_item_id)  inventory_item_id ,
             cii.instance_usage_code,
             ctt.source_transaction_type ,
             NVL(mmt.organization_id,cii.last_vld_organization_id ) inv_organization_id,
             mmt.subinventory_code inv_subinventory_name ,
             cii.location_id ,
             cii.location_type_code ,
             ct.transaction_date ,
             mmt.transaction_id inv_material_transaction_id ,
             ct.object_version_number,
             cii.operational_status_code
      FROM   csi_item_instances cii,
             csi_item_instances_h ciih,
             csi_transactions ct,
             mtl_material_transactions mmt,
             csi_txn_types ctt
      WHERE  ct.transaction_id = p_transaction_id
      AND    ct.inv_material_transaction_id = mmt.transaction_id(+)
      AND    ct.transaction_type_id = ctt.transaction_type_id
      AND    cii.instance_id = ciih.instance_id
      AND    ciih.transaction_id = ct.transaction_id
      AND   (Nvl(mmt.primary_quantity,-1) < 0
             OR
             --Misc Receipt from HZ Loc
             (ct.transaction_type_id = 134  AND cii.operational_status_code = 'OUT_OF_SERVICE')
             AND
             cii.serial_number IS NULL) ;

    CURSOR csi_txn_error_cur (c_transaction_id IN NUMBER) IS
      SELECT transaction_error_id
      FROM   csi_txn_errors
      WHERE  transaction_id = c_transaction_id
      AND    source_type = 'ASSET_MOVE' ;

    l_txn_qty                NUMBER ;
    l_qty_to_process         NUMBER ;
    l_qty_canbe_process      NUMBER ;
    l_qty_being_process      NUMBER ;

    l_fnd_success           VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_fnd_error             VARCHAR2(1) := fnd_api.g_ret_sts_error;
    l_sysdate               DATE        := sysdate;
    l_txn_rec               CSI_DATASTRUCTURES_PUB.transaction_rec ;
    l_error_msg             VARCHAR2(4000);
    l_return_status         VARCHAR2(1);
    l_valid_to_process      VARCHAR2(1);
    l_src_move_trans_rec    move_trans_rec ;
    l_src_fa_inst_dtls_tbl  src_fa_inst_dtls_tbl ;
    l_src_transaction_id    NUMBER ;
    l_dest_move_trans_tbl   move_trans_tbl ;
    l_src_move_trans_tbl    move_trans_tbl;

    ---For Public API's
    l_api_name              VARCHAR2(100) := 'cse_asset_move_pkg.process_adjustment_trans';
    l_api_version           NUMBER        := 1.0;
    l_commit                VARCHAR2(1)   := fnd_api.g_false;
    l_init_msg_list         VARCHAR2(1)   := fnd_api.g_true;
    l_validation_level      NUMBER        := fnd_api.g_valid_level_full;
    l_msg_index             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;
    l_trx_error_rec         csi_datastructures_pub.transaction_error_rec ;
    l_txn_error_id          NUMBER ;
    l_mass_add_rec          fa_mass_additions%ROWTYPE ;
    l_asset_query_rec       cse_datastructures_pub.asset_query_rec ;

  BEGIN

    x_return_status := l_fnd_success ;
    debug('inside api cse_asset_move_pkg.process_adjustment_trans ');

    FOR cse_neg_adj_rec IN cse_neg_adj_cur
    LOOP

      debug('  transaction_id     : '||cse_neg_adj_rec.transaction_id);
      debug('  instance_id        : '||cse_neg_adj_rec.instance_id);
      debug('  serial_number      : '||cse_neg_adj_rec.serial_number);
      debug('  location_type_code : '||cse_neg_adj_rec.location_type_code);
      debug('  location_id        : '||cse_neg_adj_rec.location_id);
      debug('  operational_status : '||cse_neg_adj_rec.operational_status_code);
      debug('  mtl_transaction_id : '||cse_neg_adj_rec.inv_material_transaction_id);
      debug('  primary_units      : '||cse_neg_adj_rec.primary_units);

      BEGIN

        l_src_transaction_id :=  cse_neg_adj_rec.transaction_id ;
        l_qty_to_process := ABS(cse_neg_adj_rec.primary_units) ;

        cse_asset_util_pkg.is_valid_to_process (
          p_asset_attrib_rec => g_asset_attrib_rec,
          x_valid_to_process => l_valid_to_process,
          x_return_status    => l_return_status,
          x_error_msg        => l_error_msg);

        IF l_return_status = l_fnd_error THEN
          RAISE fnd_api.g_exc_error;
        END IF ;

        IF l_valid_to_process <> 'Y' THEN
          debug('this transaction cannot be processed as there are prior pending transaction ');
          RAISE fnd_api.g_exc_error ;
        END IF ;

        l_src_move_trans_rec.transaction_id              := p_transaction_id ;
        l_src_move_trans_rec.transaction_date            := cse_neg_adj_rec.transaction_date  ;
        l_src_move_trans_rec.object_version_number       := cse_neg_adj_rec.object_version_number ;
        l_src_move_trans_rec.instance_id                 := cse_neg_adj_rec.instance_id   ;
        l_src_move_trans_rec.primary_units               := cse_neg_adj_rec.primary_units ;
        l_src_move_trans_rec.instance_usage_code         := cse_neg_adj_rec.instance_usage_code ;
        l_src_move_trans_rec.serial_number               := cse_neg_adj_rec.serial_number ;
        l_src_move_trans_rec.inv_material_transaction_id := cse_neg_adj_rec.inv_material_transaction_id  ;
        l_src_move_trans_rec.source_transaction_type     := cse_neg_adj_rec.source_transaction_type ;
        l_src_move_trans_rec.inv_item_id                 := cse_neg_adj_rec.inventory_item_id ;
        l_src_move_trans_rec.inv_organization_id         := cse_neg_adj_rec.inv_organization_id   ;
        l_src_move_trans_rec.inv_subinventory_name       := cse_neg_adj_rec.inv_subinventory_name ;
        l_src_move_trans_rec.location_id                 := cse_neg_adj_rec.location_id  ;
        l_src_move_trans_rec.location_type_code          := cse_neg_adj_rec.location_type_code ;

        get_fa_details (
          p_src_move_trans_rec    => l_src_move_trans_rec,
          x_src_fa_inst_dtls_tbl  => l_src_fa_inst_dtls_tbl,
          x_return_status         => l_return_status,
          x_error_msg             => l_error_msg) ;

        debug('after get_fa_details. count : ' ||l_src_fa_inst_dtls_tbl.COUNT);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error ;
        END IF ;

        IF l_src_fa_inst_dtls_tbl.COUNT > 0 THEN

          FOR j IN l_src_fa_inst_dtls_tbl.FIRST .. l_src_fa_inst_dtls_tbl.LAST
          LOOP

            debug ('source fa dist : '|| l_src_fa_inst_dtls_tbl(j).fa_distribution_id);

            IF l_src_fa_inst_dtls_tbl(j).instance_asset_qty <= l_src_fa_inst_dtls_tbl(j).fa_loc_units
            THEN
              l_qty_canbe_process := l_src_fa_inst_dtls_tbl(j).instance_asset_qty ;
            ELSE
              l_qty_canbe_process := l_src_fa_inst_dtls_tbl(j).fa_loc_units ;
            END IF ;

            IF l_qty_canbe_process <= l_qty_to_process THEN
              l_qty_being_process := l_qty_canbe_process ;
            ELSE
              l_qty_being_process := l_qty_to_process ;
            END IF ;

            retire_asset (
              p_fa_inst_dtls_rec => l_src_fa_inst_dtls_tbl(j),
              p_units_to_retire  => l_qty_being_process,
              x_return_status    => l_return_status,
              x_error_msg        => l_error_msg);

            IF l_return_status = l_fnd_error THEN
              RAISE fnd_api.g_exc_error ;
            END IF ;

            l_qty_to_process := l_qty_to_process - l_qty_being_process ;

            IF  l_qty_to_process <= 0 THEN
              debug('Done with the retirements..');
              EXIT ;
            END IF ;

          END LOOP ; -- l_src_fa_inst_dtls_tbl
        ELSE
          fnd_message.set_name('CSE','CSE_SRC_INST_ASSET_NOTFOUND');
          fnd_message.set_token('CSI_TRANSACTION', l_src_transaction_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error ;
        END IF;

        l_src_move_trans_tbl(1) :=  l_src_move_trans_rec ;
        update_txn_status (
          p_src_move_trans_tbl  => l_src_move_trans_tbl,
          p_dest_move_trans_tbl => l_dest_move_trans_tbl,
          p_conc_request_id     => p_conc_request_id,
          x_return_status       => l_return_status,
          x_error_msg           => l_error_msg);

        IF l_return_status = fnd_api.G_RET_STS_ERROR THEN
          debug ('Update Status Failed ..');
          RAISE fnd_api.g_exc_error ;
        END IF ;

      END; ---cse_neg_adj_cur
    END LOOP; ---cse_neg_adj_cur

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      l_error_msg                    := l_error_msg ;
      x_return_status                := fnd_api.G_RET_STS_ERROR ;
      l_trx_error_rec.transaction_id := l_src_transaction_id ;
      l_trx_error_rec.error_text     :=  l_error_msg;
      l_trx_error_rec.source_type    := 'ASSET_MOVE';
      l_trx_error_rec.source_id      :=  l_src_transaction_id ;
      l_trx_error_rec.source_group_ref_id  := p_conc_request_id ;
      l_txn_error_id                := NULL ;

      OPEN csi_txn_error_cur (l_trx_error_rec.transaction_id);
      FETCH csi_txn_error_cur INTO l_txn_error_id ;
      CLOSE csi_txn_error_cur ;

      IF l_txn_error_id IS NULL THEN
        csi_transactions_pvt.create_txn_error(
          l_api_version,
          l_init_msg_list,
          l_commit,
          l_validation_level,
          l_trx_error_rec,
          l_return_status,
          l_msg_count,
          l_msg_data,
          l_txn_error_id);
      ELSE
        UPDATE  csi_txn_errors
        SET     error_text          = l_trx_error_rec.error_text ,
                source_group_ref_id = p_conc_request_id,
                last_update_date    = sysdate
        WHERE   transaction_error_id = l_txn_error_id ;
      END IF ;

      debug ('Error in process_adjustment_trans p_conc_req id '  || l_error_msg );
      x_error_msg := l_error_msg ;
   WHEN OTHERS THEN
     l_error_msg := l_error_msg || SQLERRM ;
     x_return_status := fnd_api.G_RET_STS_ERROR ;
     fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
     fnd_message.set_token('API_NAME','process_adjustment_trans');
     fnd_message.set_token('SQL_ERROR',SQLERRM);
     x_error_msg := fnd_message.get;

     l_trx_error_rec.transaction_id :=  l_src_transaction_id ;
     l_trx_error_rec.error_text     :=  l_error_msg;
     l_trx_error_rec.source_type    := 'ASSET_CREATION';
     l_trx_error_rec.source_id      := l_src_transaction_id ;

     l_txn_error_id := NULL ;

     OPEN csi_txn_error_cur (l_trx_error_rec.transaction_id);
     FETCH csi_txn_error_cur INTO l_txn_error_id ;
     CLOSE csi_txn_error_cur ;

     IF l_txn_error_id IS NULL THEN
       csi_transactions_pvt.create_txn_error
           (l_api_version, l_init_msg_list, l_commit, l_validation_level,
            l_trx_error_rec, l_return_status, l_msg_count,l_msg_data,
            l_txn_error_id);
     ELSE
       SELECT sysdate INTO l_sysdate FROM DUAL ;
       UPDATE  csi_txn_errors
       SET     error_text = l_trx_error_rec.error_text ,
               source_group_ref_id = p_conc_request_id,
               last_update_date = l_sysdate
       WHERE   transaction_error_id = l_txn_error_id ;
     END IF ;
     x_error_msg := l_error_msg ;
     debug ('Error -Others-in process_adjustment_trans '  || x_error_msg );
  END process_adjustment_trans ;

  PROCEDURE get_inst_txn_dtls_srl(
    p_instance_id       IN number,
    p_transaction_id    IN number,
    p_source_dest_flag  IN varchar2 default 'C',
    x_instance_rec         OUT nocopy csi_datastructures_pub.instance_header_rec,
    x_return_status        OUT nocopy varchar2)
  IS

    l_transaction_id       number;
    l_time_stamp           date   := sysdate;

    -- get instance details variables
    g_inst_rec             csi_datastructures_pub.instance_header_rec;
    g_pty_tbl              csi_datastructures_pub.party_header_tbl;
    g_pa_tbl               csi_datastructures_pub.party_account_header_tbl;
    g_ou_tbl               csi_datastructures_pub.org_units_header_tbl;
    g_prc_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    g_eav_tbl              csi_datastructures_pub.extend_attrib_values_tbl;
    g_ea_tbl               csi_datastructures_pub.extend_attrib_tbl;
    g_asset_tbl            csi_datastructures_pub.instance_asset_header_tbl;

    l_return_status        varchar2(1);
    l_msg_data             varchar2(2000);
    l_msg_count            number;

  BEGIN

    debug('Inside get_inst_dtls_srl');

    debug('  p_source_dest_flag  : '||p_source_dest_flag);
    debug('  p_transaction_id    : '||p_transaction_id);
    debug('  p_instance_id       : '||p_instance_id);

    l_transaction_id := p_transaction_id;

    IF p_source_dest_flag = 'D' THEN

      SELECT creation_date
      INTO   l_time_stamp
      FROM   csi_item_instances_h
      WHERE  transaction_id = l_transaction_id
      AND    instance_id    = p_instance_id;

    ELSIF p_source_dest_flag = 'S' THEN

      SELECT max(transaction_id)
      INTO   l_transaction_id
      FROM   csi_item_instances_h
      WHERE  instance_id    = p_instance_id
      AND    transaction_id < l_transaction_id;

      SELECT creation_date
      INTO   l_time_stamp
      FROM   csi_item_instances_h
      WHERE  transaction_id = l_transaction_id
      AND    instance_id    = p_instance_id;

    END IF;

    g_inst_rec.instance_id := p_instance_id;

    debug('Calling csi_item_instance_pub.get_item_instance_details - '||g_inst_rec.instance_id);
    debug('  l_time_stamp        : '||to_char(l_time_stamp, 'dd-mon-yyyy hh24:mi:ss'));

    csi_item_instance_pub.get_item_instance_details (
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => g_inst_rec,
      p_get_parties           => fnd_api.g_false,
      p_party_header_tbl      => g_pty_tbl,
      p_get_accounts          => fnd_api.g_false,
      p_account_header_tbl    => g_pa_tbl,
      p_get_org_assignments   => fnd_api.g_false,
      p_org_header_tbl        => g_ou_tbl,
      p_get_pricing_attribs   => fnd_api.g_false,
      p_pricing_attrib_tbl    => g_prc_tbl,
      p_get_ext_attribs       => fnd_api.g_false,
      p_ext_attrib_tbl        => g_eav_tbl,
      p_ext_attrib_def_tbl    => g_ea_tbl,
      p_get_asset_assignments => fnd_api.g_false,
      p_asset_header_tbl      => g_asset_tbl,
      p_resolve_id_columns    => fnd_api.g_false,
      p_time_stamp            => l_time_stamp,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_instance_rec := g_inst_rec;

    debug('  location_type_code  : '||x_instance_rec.location_type_code);
    debug('  location_id         : '||x_instance_rec.location_id);
    debug('  organization_id     : '||x_instance_rec.inv_organization_id);
    debug('  subinventory_code   : '||x_instance_rec.inv_subinventory_name);
    debug('  quantity            : '||x_instance_rec.quantity);
    debug('  serial_number       : '||x_instance_rec.serial_number);
    debug('  instance_usage_code : '||x_instance_rec.instance_usage_code);


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_inst_txn_dtls_srl;


  PROCEDURE get_move_txn_details(
    p_transaction_id        IN  number,
    x_src_move_trans_tbl    OUT nocopy cse_asset_move_pkg.move_trans_tbl,
    x_dest_move_trans_tbl   OUT nocopy cse_asset_move_pkg.move_trans_tbl,
    x_return_status         OUT nocopy varchar2)
  IS
    CURSOR csi_txn_cur IS
      SELECT ct.transaction_type_id,
             ct.transaction_id,
             ct.transaction_date,
             ct.source_transaction_date,
             ct.inv_material_transaction_id,
             ct.object_version_number,
             ctt.source_transaction_type
      FROM   csi_transactions ct,
             csi_txn_types    ctt
      WHERE  ct.transaction_id = p_transaction_id
      AND    ctt.transaction_type_id = ct.transaction_type_id;

    CURSOR mtl_txn_cur(p_mtl_txn_id IN number) IS
      SELECT mmt.inventory_item_id,
             mmt.organization_id,
             mmt.primary_quantity,
             msi.serial_number_control_code,
             msi.primary_unit_of_measure
      FROM   mtl_material_transactions mmt,
             mtl_system_items msi
      WHERE  mmt.transaction_id    = p_mtl_txn_id
      AND    msi.inventory_item_id = mmt.inventory_item_id
      AND    msi.organization_id   = mmt.organization_id;

    CURSOR csi_txn_item_cur IS
      SELECT ciih.instance_id,
             cii.inventory_item_id,
             cii.last_vld_organization_id,
             msi.serial_number_control_code,
             msi.primary_unit_of_measure
      FROM   csi_item_instances_h ciih,
             csi_item_instances   cii,
             mtl_system_items     msi
      WHERE  ciih.transaction_id   = p_transaction_id
      AND    cii.instance_id       = ciih.instance_id
      AND    msi.inventory_item_id = cii.inventory_item_id
      AND    msi.organization_id   = cii.last_vld_organization_id;

    CURSOR inst_cur(p_item_id in number) IS
      SELECT cii.instance_id,
             cii.serial_number,
             cii.instance_usage_code,
             nvl(ciih.old_quantity,0)  old_quantity,
             nvl(ciih.new_quantity, 0) new_quantity
      FROM   csi_item_instances_h ciih,
             csi_item_instances   cii
      WHERE  ciih.transaction_id   = p_transaction_id
      AND    cii.instance_id       = ciih.instance_id
      AND    cii.inventory_item_id = p_item_id;

    CURSOR nsrl_inst_cur(p_item_id NUMBER, p_transaction_id NUMBER, p_txn_quantity NUMBER) IS
      SELECT cii.instance_id,
             cii.serial_number,
             cii.instance_usage_code,
             cit.transaction_id,
             cit.transaction_type_id
      FROM   csi_item_instances_h ciih,
             csi_item_instances   cii,
             csi_transactions cit,
             csi_i_assets cia
      WHERE  cit.transaction_id   <= p_transaction_id
      AND    cii.inventory_item_id =  p_item_id
      AND    cii.instance_id       = ciih.instance_id
      AND    ciih.transaction_id   = cit.transaction_id
      AND    cia.instance_id = cii.instance_id
      AND    cia.asset_quantity    >= p_txn_quantity
      AND    cia.active_end_date IS NULL
      ORDER BY cit.transaction_id desc;

    CURSOR nsrl_asset_cur( p_instance_id NUMBER ) IS
      SELECT cia.instance_id,
             cia.fa_asset_id,
             cia.asset_quantity
      FROM   csi_i_assets cia
      WHERE  cia.instance_id       = p_instance_id
      AND    cia.asset_quantity    > 0
      AND    cia.active_end_date IS NULL ;


    l_csi_txn_rec               csi_txn_cur%rowtype;
    l_mtl_txn_rec               mtl_txn_cur%rowtype;
    l_csi_txn_item_rec          csi_txn_item_cur%rowtype;
    l_serial_code               number;
    l_item_id                   number;
    l_organization_id           number;
    l_txn_quantity              number;

    l_src_move_tbl              cse_asset_move_pkg.move_trans_tbl;
    l_dest_move_tbl             cse_asset_move_pkg.move_trans_tbl;
    l_src_inst_rec              csi_datastructures_pub.instance_header_rec;
    l_dest_inst_rec             csi_datastructures_pub.instance_header_rec;

    s_ind                       binary_integer := 0;
    d_ind                       binary_integer := 0;

    l_return_status             varchar2(1) := fnd_api.g_ret_sts_success;
    l_instance_id               number;
    l_transaction_id            number;
    l_nsrl_asset_rec            nsrl_asset_cur%ROWTYPE;
    l_nsrl_inst_rec             nsrl_inst_cur%ROWTYPE;

  BEGIN

    x_return_status := l_return_status;

    OPEN  csi_txn_cur;
    FETCH csi_txn_cur INTO l_csi_txn_rec;
    CLOSE csi_txn_cur;

    IF l_csi_txn_rec.inv_material_transaction_id is not null THEN

      OPEN  mtl_txn_cur(l_csi_txn_rec.inv_material_transaction_id);
      FETCH mtl_txn_cur INTO l_mtl_txn_rec;
      CLOSE mtl_txn_cur;

      l_serial_code     := l_mtl_txn_rec.serial_number_control_code;
      l_item_id         := l_mtl_txn_rec.inventory_item_id;
      l_organization_id := l_mtl_txn_rec.organization_id;

    ELSE

      -- ui and other eam location update transactions
      OPEN  csi_txn_item_cur;
      FETCH csi_txn_item_cur INTO l_csi_txn_item_rec;
      CLOSE csi_txn_item_cur;

      l_serial_code     := l_csi_txn_item_rec.serial_number_control_code;
      l_item_id         := l_csi_txn_item_rec.inventory_item_id;
      l_organization_id := l_csi_txn_item_rec.last_vld_organization_id;

    END IF;

    IF l_serial_code in (2, 5) THEN

      FOR inst_rec in inst_cur(l_item_id)
      LOOP

        get_inst_txn_dtls_srl(
          p_instance_id       => inst_rec.instance_id,
          p_transaction_id    => p_transaction_id,
          p_source_dest_flag  => 'S',
          x_instance_rec      => l_src_inst_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        s_ind := inst_cur%rowcount;

        l_src_move_tbl(s_ind).transaction_id               := p_transaction_id;
        l_src_move_tbl(s_ind).transaction_type_id          := l_csi_txn_rec.transaction_type_id;
        l_src_move_tbl(s_ind).instance_id                  := inst_rec.instance_id;
        l_src_move_tbl(s_ind).primary_units                := 1;
        l_src_move_tbl(s_ind).serial_number                := inst_rec.serial_number;
        l_src_move_tbl(s_ind).inv_material_transaction_id  := l_csi_txn_rec.inv_material_transaction_id;
        l_src_move_tbl(s_ind).source_transaction_type      := l_csi_txn_rec.source_transaction_type;
        l_src_move_tbl(s_ind).inv_item_id                  := l_item_id;
        l_src_move_tbl(s_ind).inv_org_id                   := l_organization_id;
        --l_src_move_tbl(s_ind).shipment_number              :=
        l_src_move_tbl(s_ind).inv_organization_id          := l_src_inst_rec.inv_organization_id;
        l_src_move_tbl(s_ind).inv_subinventory_name        := l_src_inst_rec.inv_subinventory_name;
        l_src_move_tbl(s_ind).location_id                  := l_src_inst_rec.location_id;
        l_src_move_tbl(s_ind).location_type_code           := l_src_inst_rec.location_type_code;
        l_src_move_tbl(s_ind).transaction_date             := l_csi_txn_rec.source_transaction_date;
        l_src_move_tbl(s_ind).transaction_quantity         := 1;
        l_src_move_tbl(s_ind).object_version_number        := l_csi_txn_rec.object_version_number;
        l_src_move_tbl(s_ind).instance_usage_code          := l_src_inst_rec.instance_usage_code;
        l_src_move_tbl(s_ind).serial_control_code          := l_serial_code;

        get_inst_txn_dtls_srl(
          p_instance_id       => inst_rec.instance_id,
          p_transaction_id    => p_transaction_id,
          p_source_dest_flag  => 'D',
          x_instance_rec      => l_dest_inst_rec,
          x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        d_ind := inst_cur%rowcount;

        l_dest_move_tbl(d_ind).transaction_id              := p_transaction_id;
        l_dest_move_tbl(d_ind).transaction_type_id         := l_csi_txn_rec.transaction_type_id;
        l_dest_move_tbl(d_ind).instance_id                 := inst_rec.instance_id;
        l_dest_move_tbl(d_ind).primary_units               := 1;
        l_dest_move_tbl(d_ind).serial_number               := inst_rec.serial_number;
        l_dest_move_tbl(d_ind).inv_material_transaction_id := l_csi_txn_rec.inv_material_transaction_id;
        l_dest_move_tbl(d_ind).source_transaction_type     := l_csi_txn_rec.source_transaction_type;
        l_dest_move_tbl(d_ind).inv_item_id                 := l_item_id;
        l_dest_move_tbl(d_ind).inv_org_id                  := l_organization_id;
        --l_dest_move_tbl(d_ind).shipment_number             :=
        l_dest_move_tbl(d_ind).inv_organization_id         := l_dest_inst_rec.inv_organization_id;
        l_dest_move_tbl(d_ind).inv_subinventory_name       := l_dest_inst_rec.inv_subinventory_name;
        l_dest_move_tbl(d_ind).location_id                 := l_dest_inst_rec.location_id;
        l_dest_move_tbl(d_ind).location_type_code          := l_dest_inst_rec.location_type_code;
        l_dest_move_tbl(d_ind).transaction_date            := l_csi_txn_rec.source_transaction_date;
        l_dest_move_tbl(d_ind).transaction_quantity        := 1;
        l_dest_move_tbl(d_ind).object_version_number       := l_csi_txn_rec.object_version_number;
        l_dest_move_tbl(d_ind).instance_usage_code         := l_src_inst_rec.instance_usage_code;
        l_dest_move_tbl(d_ind).source_index                := s_ind;
        l_dest_move_tbl(d_ind).serial_control_code         := l_serial_code;

      END LOOP;

    ELSE
      -- parse 1 get all the source instances
      FOR inst_rec in inst_cur(l_item_id)
      LOOP

        l_txn_quantity := inst_rec.new_quantity - inst_rec.old_quantity;

        IF inst_rec.old_quantity >= inst_rec.new_quantity THEN

	   -- Added for bug 5764739
           l_instance_id    := inst_rec.instance_id;
           l_transaction_id := p_transaction_id;

           IF inst_rec.instance_usage_code ='OUT_OF_SERVICE' THEN
             debug(' Out of Service Source item instance is : '|| l_instance_id ||' Searching for Assets ');
             OPEN nsrl_asset_cur( inst_rec.instance_id );
             FETCH nsrl_asset_cur INTO l_nsrl_asset_rec;
             IF nsrl_asset_cur%NOTFOUND THEN
                CLOSE nsrl_asset_cur;
                DEBUG(' No Assets found for Instance '||l_instance_id );
                DEBUG(' Searching for previous stage instance before transaction '||l_transaction_id );
                OPEN nsrl_inst_cur(l_item_id , p_transaction_id , l_txn_quantity );
                FETCH nsrl_inst_cur INTO l_nsrl_inst_rec;
                CLOSE nsrl_inst_cur;

                debug('Found Instance : '||l_nsrl_inst_rec.instance_id ||' Now Search for assets associated with this instance');

                OPEN nsrl_asset_cur( l_nsrl_inst_rec.instance_id );
                FETCH nsrl_asset_cur INTO l_nsrl_asset_rec;
                IF nsrl_asset_cur%FOUND THEN
                   debug('FOUND Asset '||l_nsrl_asset_rec.fa_asset_id ||' transaction : '||l_nsrl_inst_rec.transaction_id||' Instance : '||l_nsrl_inst_rec.instance_id);
                   l_instance_id    := l_nsrl_inst_rec.instance_id;
                   l_transaction_id := l_nsrl_inst_rec.transaction_id;
                END IF;

                CLOSE nsrl_asset_cur;
               ELSE
                CLOSE nsrl_asset_cur;
               END IF;
           END IF;
	   -- Added for bug 5764739


          get_inst_txn_dtls_srl(
            p_instance_id       => l_instance_id,
            p_transaction_id    => l_transaction_id,
            p_source_dest_flag  => 'D',
            x_instance_rec      => l_src_inst_rec,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_txn_quantity = 0 THEN
            l_txn_quantity := l_src_inst_rec.quantity;
          END IF;

          s_ind := s_ind + 1;

          l_src_move_tbl(s_ind).transaction_id               := l_transaction_id;
          l_src_move_tbl(s_ind).transaction_type_id          := l_csi_txn_rec.transaction_type_id;
          l_src_move_tbl(s_ind).instance_id                  := l_instance_id;
          l_src_move_tbl(s_ind).primary_units                := l_txn_quantity;
          l_src_move_tbl(s_ind).serial_number                := inst_rec.serial_number;
          l_src_move_tbl(s_ind).inv_material_transaction_id  := l_csi_txn_rec.inv_material_transaction_id;
          l_src_move_tbl(s_ind).source_transaction_type      := l_csi_txn_rec.source_transaction_type;
          l_src_move_tbl(s_ind).inv_item_id                  := l_item_id;
          l_src_move_tbl(s_ind).inv_org_id                   := l_organization_id;
          --l_src_move_tbl(s_ind).shipment_number              :=
          l_src_move_tbl(s_ind).inv_organization_id          := l_src_inst_rec.inv_organization_id;
          l_src_move_tbl(s_ind).inv_subinventory_name        := l_src_inst_rec.inv_subinventory_name;
          l_src_move_tbl(s_ind).location_id                  := l_src_inst_rec.location_id;
          l_src_move_tbl(s_ind).location_type_code           := l_src_inst_rec.location_type_code;
          l_src_move_tbl(s_ind).transaction_date             := l_csi_txn_rec.source_transaction_date;
          l_src_move_tbl(s_ind).transaction_quantity         := l_txn_quantity;
          l_src_move_tbl(s_ind).object_version_number        := l_csi_txn_rec.object_version_number;
          l_src_move_tbl(s_ind).instance_usage_code          := l_src_inst_rec.instance_usage_code;
          l_src_move_tbl(s_ind).serial_control_code          := l_serial_code;

        END IF;

      END LOOP;

      -- get all the destination instances
      FOR inst_rec in inst_cur(l_item_id)
      LOOP

        IF inst_rec.old_quantity <= inst_rec.new_quantity THEN

          l_instance_id       := inst_rec.instance_id ;
          l_transaction_id    := p_transaction_id ;

          DEBUG( 'BEFORE l_instance_id : '||l_instance_id );
          DEBUG( 'BEFORE l_transaction_id : '||l_transaction_id );

          IF inst_rec.instance_usage_code = 'OUT_OF_SERVICE' THEN
             BEGIN

             SELECT a.instance_id  , a.transaction_id
             INTO    l_instance_id,  l_transaction_id
             FROM   csi_item_instances_h a,
               ( SELECT  b.transaction_id, b.instance_id
                FROM    csi_inst_txn_details_v b
                WHERE   b.transaction_id >  l_transaction_id
                AND     b.instance_id    = l_instance_id
                AND     b.transaction_type_id = 109
                AND     ROWNUM = 1
                ORDER BY  b.transaction_id ) c
             WHERE  a.transaction_id = c.transaction_id
             AND  a.instance_id    <> c.instance_id
             AND  ROWNUM =1 ;

             EXCEPTION
               WHEN OTHERS THEN
                    NULL;
             END;
          END IF;
          DEBUG( 'AFTER l_instance_id : '||l_instance_id );
          DEBUG( 'AFTER l_transaction_id : '|| l_transaction_id );


          get_inst_txn_dtls_srl(
            p_instance_id       => l_instance_id,
            p_transaction_id    => l_transaction_id ,
            p_source_dest_flag  => 'D',
            x_instance_rec      => l_dest_inst_rec,
            x_return_status     => l_return_status);

            DEBUG(' return Status '||l_return_status );

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_txn_quantity = 0 THEN
            l_txn_quantity := l_dest_inst_rec.quantity;
          END IF;

          d_ind := d_ind + 1;

          l_dest_move_tbl(d_ind).transaction_id              := p_transaction_id;
          l_dest_move_tbl(d_ind).transaction_type_id         := l_csi_txn_rec.transaction_type_id;
          l_dest_move_tbl(d_ind).instance_id                 := l_instance_id;
          l_dest_move_tbl(d_ind).primary_units               := l_txn_quantity;
          l_dest_move_tbl(d_ind).serial_number               := inst_rec.serial_number;
          l_dest_move_tbl(d_ind).inv_material_transaction_id := l_csi_txn_rec.inv_material_transaction_id;
          l_dest_move_tbl(d_ind).source_transaction_type     := l_csi_txn_rec.source_transaction_type;
          l_dest_move_tbl(d_ind).inv_item_id                 := l_item_id;
          l_dest_move_tbl(d_ind).inv_org_id                  := l_organization_id;
          --l_dest_move_tbd(d_ind).shipment_number             :=
          l_dest_move_tbl(d_ind).inv_subinventory_name       := l_dest_inst_rec.inv_subinventory_name;
          l_dest_move_tbl(d_ind).location_id                 := l_dest_inst_rec.location_id;
          l_dest_move_tbl(d_ind).location_type_code          := l_dest_inst_rec.location_type_code;
          l_dest_move_tbl(d_ind).transaction_date            := l_csi_txn_rec.source_transaction_date;
          l_dest_move_tbl(d_ind).transaction_quantity        := l_txn_quantity;
          l_dest_move_tbl(d_ind).object_version_number       := l_csi_txn_rec.object_version_number;
          l_dest_move_tbl(d_ind).instance_usage_code         := l_dest_inst_rec.instance_usage_code;
          l_dest_move_tbl(d_ind).serial_control_code         := l_serial_code;

          IF l_dest_inst_rec.instance_usage_code = 'IN_TRANSIT' THEN
            l_dest_move_tbl(d_ind).inv_organization_id       := l_organization_id;
          END IF;

          IF l_src_move_tbl.count = 1 THEN
            l_dest_move_tbl(d_ind).source_index := 1;
          ELSE
            -- need to put some code in here for the nonserial lot items
            null;
          END IF;


        END IF;

      END LOOP;

    END IF; -- serial or non serial check

    x_src_move_trans_tbl   := l_src_move_tbl;
    x_dest_move_trans_tbl  := l_dest_move_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_move_txn_details;

  --  CASE                                                   ACTION
  -------------------------------------------------------------------------------
  -- INTER-ASSET
  --   Destination Instance ID and              Perform a source cost adjustment
  --   Destination Asset not found              Perform a source unit adjustment
  --   in Instance Asset table w/ available     Update source instance asset
  --   status                                   Create a new destination instance asset


  ----INTRA-ASSET
  --2. Destination Instance ID found     2. Update Source Instance Asset
  --   Destination Asset found                Update dest. Instance Asset
  --  Destination Asset = Source Asset
  --    Destination Location found on Asset
  --    Destination Location = Source Location


  ----INTRA-ASSET
  --3. Destination Instance ID found      3. Perform a source-to-destination unit transfer
  --    Destination Asset found                 Update source instance asset
  --    Destination Asset = Source Asset         Update destination instance asset
  --    Destination Location found on Asset
  --    Destination Location <> Source Location


  --  INTRA-ASSET
  --4.  Destination Instance ID found      4. Perform a source-to-destination unit transfer
  --    Destination Asset found                 Update source instance asset
  --    Destination Asset = Source Asset         Create a new destination instance asset
  --    Destination Location not found on Asset

  --  INTER-ASSET
  --5. Destination Instance ID found      5. Perform a source cost adjustment
  --    Destination Asset found                 Perform a source unit adjustment
  --    Destination Asset <> Source Asset         Update source instance asset
  --    Destination Location found on Asset Perform a destination cost adjustment
  --                                         Perform a destination unit adjustment
  --                                         Update destination instance asset
  --
  --
  --  INTER-ASSET
  --6. Destination Instance ID found      6. Perform a source cost adjustment
  --    Destination Asset found                 Perform a source unit adjustment
  --    Destination Asset <> Source Asset         Update source instance asset
  --    Destination Location not found on Asset   Perform a destination cost adjustment
  --                                         Perform a destination unit adjustment
  --                                         Perform a destination unit transfer
  --                                         Update a destination instance asset
  --
  --  INTRA-ASSET
  --7. Dest Instance Not found.                 7. Create new dest instance asset
  --  Dest Asset exists.                          Update Source Instance Asset.
  --  Source loc = Dest loc
  --   Dest Asset = Source Asset
  --
  ----INTRA-ASSET
  --8. Dest Instance Not found.                 8. Create new dest instance asset
  --   Dest Asset exists.                          Update Source Instance Asset.
  --   Source loc <> Dest loc                      Perform source-to-dest unit transfer.
  --   Dest Asset = Source Asset
  --
  ----INTRA-ASSET
  --9. Serialized Item Moved from               9. Do NOTHING.
  --   One Loc to Other. Source Asset
  --   = Dest Asset , Source Loc
  --= Dest Loc. Source Inst = Dest Inst
  --
  ----INTER-ASSET
  --10. Destination Instance Asset Not          10. Perform a source cost adjustment
  --    Found. Destination Asset Exists.            Perform a source unit adjustment
  --    Dest Asset <> Source Asset                  Update source instance asset
  --                                                Perform a destination cost adjustment
  --                                           Perform a destination unit adjustment
  --                                           Perform a destination unit transfer
  --                                          Update a destination instance asset
  -----------------------------------------------------------------------------
  ---  It is Assumed that the src and dest table is for a group transactions ONLY.
  ---  Meaning, if something fails for one of the rows of any of the src or dest table,
  ---  whole process will be rolledback and exception will be raised to the calling program.
  --------------------------------------------------------------------------------
  PROCEDURE update_fa (
    p_transaction_id       IN     number,
    p_src_move_trans_tbl   IN     move_trans_tbl,
    p_dest_move_trans_tbl  IN     move_trans_tbl,
    x_return_status           OUT nocopy varchar2,
    x_error_msg               OUT nocopy varchar2)
  IS

    l_fa_rec                  fa_rec ;
    l_fa_action_code          VARCHAR2(1);

    l_txn_qty                 NUMBER;
    l_qty_to_process          NUMBER;
    l_qty_canbe_process       NUMBER;
    l_qty_being_process       NUMBER;

    l_sysdate                 DATE  := sysdate;
    l_txn_rec                 csi_datastructures_pub.transaction_rec;

    l_src_transaction_id      NUMBER;
    l_src_fa_inst_dtls_tbl    src_fa_inst_dtls_tbl;

    l_dest_fa_rec             fa_rec;
    l_dest_fa_dist_rec        cse_datastructures_pub.distribution_rec;
    l_dest_trans_cnt          number;
    l_dest_txn_qty            number;
    l_hook_used               pls_integer;
    l_dest_fa_book_type_code  varchar2(15);
    l_dest_fa_category_id     number;
    l_dest_fa_location_id     number;
    l_inst_loc_rec            cse_asset_util_pkg.inst_loc_rec;
    l_prev_instance_id        number;

    l_serial_control_code    NUMBER;
    l_total_qty_processed   NUMBER :=0;
    l_total_asset_qty    NUMBER:=0;

    --fa api related variables
    l_calling_fn              varchar2(30);
    l_msg_count               number;
    l_msg_data                VARCHAR2(2000);
    l_trans_rec               fa_api_types.trans_rec_type;
    l_asset_hdr_rec           fa_api_types.asset_hdr_rec_type;
    l_asset_cat_rec_new       FA_API_TYPES.asset_cat_rec_type;
    l_recl_opt_rec            FA_API_TYPES.reclass_options_rec_type;
    temp_str                  VARCHAR2(512);

    l_return_status           VARCHAR2(1);
    l_error_msg               VARCHAR2(4000);
    l_fnd_success             VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_fnd_error               VARCHAR2(1) := fnd_api.g_ret_sts_error;
    e_error                   Exception;  --added by sreeram
  BEGIN

    x_return_status := l_fnd_success ;

    debug('Inside update_fa');
    debug('  src_move_trans_tbl.count   : '||p_src_move_trans_tbl.count);
    debug('  dst_move_trans_tbl.count   : '||p_dest_move_trans_tbl.count);

    IF p_src_move_trans_tbl.COUNT > 0 THEN

      l_txn_rec                          := cse_util_pkg.init_txn_rec;
      l_txn_rec.source_transaction_date  := l_sysdate;
      l_txn_rec.transaction_date         := l_sysdate;
      l_txn_rec.transaction_type_id      := cse_util_pkg.get_txn_type_id('INSTANCE_ASSET_TIEBACK','CSE');
      l_txn_rec.transaction_quantity     := 1;
      l_txn_rec.transaction_status_code  :=  cse_datastructures_pub.G_COMPLETE;
      l_txn_rec.source_header_ref        := 'CSI_TXN_ID';
      l_txn_rec.source_header_ref_id     := p_transaction_id;
      l_txn_rec.object_version_number    := 1;

      create_csi_txn(l_txn_rec, l_return_status, l_error_msg);

      IF l_return_status <> l_fnd_success THEN
        x_error_msg := l_error_msg ;
        RAISE fnd_api.g_exc_error;
      END IF ;

      FOR s_ind IN p_src_move_trans_tbl.FIRST .. p_src_move_trans_tbl.LAST
      LOOP

        debug(' source.instance_id        : '||p_src_move_trans_tbl(s_ind).instance_id);

        l_src_transaction_id  :=  p_src_move_trans_tbl(s_ind).transaction_id ;
        l_txn_qty             :=  p_src_move_trans_tbl(s_ind).primary_units;
        l_serial_control_code :=  p_src_move_trans_tbl(s_ind).serial_control_code;
        debug('source asset information : ');

        get_fa_details (
          p_src_move_trans_rec   => p_src_move_trans_tbl(s_ind),
          x_src_fa_inst_dtls_tbl => l_src_fa_inst_dtls_tbl,
          x_return_status        => l_return_status,
          x_error_msg            => l_error_msg) ;

        IF l_return_status = l_fnd_error THEN
          RAISE fnd_api.g_exc_error ;
        END IF ;

        IF l_src_fa_inst_dtls_tbl.COUNT = 0 THEN
          fnd_message.set_name('CSE','CSE_SRC_INST_ASSET_NOTFOUND');
          fnd_message.set_token('CSI_TRANSACTION', l_src_transaction_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error ;
        END IF ;

        <<dest_move_trans_loop>>
        FOR d_ind IN p_dest_move_trans_tbl.FIRST .. p_dest_move_trans_tbl.LAST
        LOOP

          IF p_dest_move_trans_tbl(d_ind).source_index =  s_ind THEN

            debug('  destination instance_id : '||p_dest_move_trans_tbl(d_ind).instance_id);

            l_dest_trans_cnt := l_dest_trans_cnt+1 ;

            IF p_src_move_trans_tbl(s_ind).source_transaction_type IN (
                 'ISO_SHIPMENT',
                 'INTERORG_TRANS_SHIPMENT',
                 'INTERORG_TRANSFER')
            THEN
              l_qty_to_process := ABS(p_dest_move_trans_tbl(d_ind).primary_units);
            ELSE
              l_qty_to_process := ABS(p_src_move_trans_tbl(s_ind).primary_units);
            END IF ;

            l_dest_txn_qty := ABS(p_dest_move_trans_tbl(d_ind).transaction_quantity) ;

            cse_asset_client_ext_stub.get_book_type(g_asset_attrib_rec , l_hook_used, l_error_msg);
            l_dest_fa_book_type_code := g_asset_attrib_rec.book_type_code ;
            IF l_hook_used <> 1 THEN
              l_dest_fa_book_type_code := NULL ;
            END IF ;

            debug('src inv_organization_id    : '||p_src_move_trans_tbl(s_ind).inv_organization_id);
            debug('dst inv_organization_id    : '||p_dest_move_trans_tbl(d_ind).inv_organization_id);

            cse_asset_client_ext_stub.get_asset_category(g_asset_attrib_rec, l_hook_used, l_error_msg);
            IF l_hook_used = 1 THEN
              l_dest_fa_category_id := g_asset_attrib_rec.asset_category_id ;
            ELSE
              IF p_dest_move_trans_tbl(d_ind).inv_organization_id <> p_src_move_trans_tbl(s_ind).inv_organization_id
              THEN
                SELECT asset_category_id
                INTO   l_dest_fa_category_id
                FROM   mtl_system_items
                WHERE  inventory_item_id = p_dest_move_trans_tbl(d_ind).inv_item_id
                AND    organization_id   = p_dest_move_trans_tbl(d_ind).inv_organization_id;
              END IF;
            END IF ;

            l_inst_loc_rec := NULL ;
            l_inst_loc_rec.instance_id           := p_dest_move_trans_tbl(d_ind).instance_id;
            l_inst_loc_rec.transaction_id        := p_dest_move_trans_tbl(d_ind).transaction_id;
            l_inst_loc_rec.transaction_date      := p_dest_move_trans_tbl(d_ind).transaction_date;
            l_inst_loc_rec.location_type_code    := p_dest_move_trans_tbl(d_ind).location_type_code;
            l_inst_loc_rec.inv_organization_id   := p_dest_move_trans_tbl(d_ind).inv_organization_id;
            l_inst_loc_rec.inv_subinventory_name := p_dest_move_trans_tbl(d_ind).inv_subinventory_name;
            l_inst_loc_rec.location_id           := p_dest_move_trans_tbl(d_ind).location_id;

            debug ('get destination asset location_id :');

            cse_asset_util_pkg.get_fa_location(
              p_inst_loc_rec      => l_inst_loc_rec,
              x_asset_location_id => l_dest_fa_location_id,
              x_return_status     => l_return_status,
              x_error_msg         => l_error_msg);

            IF l_return_status = l_fnd_error THEN
              RAISE fnd_api.g_exc_error ;
            END IF ;

             l_dest_fa_dist_rec.location_id := l_dest_fa_location_id ;
             IF l_src_fa_inst_dtls_tbl.COUNT > 0 THEN
	         FOR k IN l_src_fa_inst_dtls_tbl.FIRST .. l_src_fa_inst_dtls_tbl.LAST
                 LOOP
		   l_total_asset_qty := l_total_asset_qty + l_src_fa_inst_dtls_tbl(k).fa_loc_units;
                 END LOOP;

                 IF l_total_asset_qty < abs(l_txn_qty) THEN
					debug('Total asset qty is less than transaction qty');
					debug('l_total_asset_qty' || l_total_asset_qty);
					debug('abs(l_txn_qty)' || abs(l_txn_qty));
					/* fnd_message.set_name('CSE','CSE_SRC_INST_ASSET_NOTFOUND');
					fnd_message.set_token('CSI_TRANSACTION', l_src_transaction_id);
					fnd_msg_pub.add;*/
					RAISE fnd_api.g_exc_error ;
                 END IF;
              END IF;

            IF l_src_fa_inst_dtls_tbl.COUNT > 0 THEN
              FOR j IN l_src_fa_inst_dtls_tbl.FIRST .. l_src_fa_inst_dtls_tbl.LAST
              LOOP
                  debug('source_fa_dist_id  : '||l_src_fa_inst_dtls_tbl(j).fa_distribution_id);
                  debug('instance_asset_qty : '||l_src_fa_inst_dtls_tbl(j).instance_asset_qty);
                  debug('fa_loc_units       : '||l_src_fa_inst_dtls_tbl(j).fa_loc_units);
                  debug('l_qty_to_process   : '||l_qty_to_process);

                IF l_src_fa_inst_dtls_tbl(j).instance_asset_qty <= l_src_fa_inst_dtls_tbl(j).fa_loc_units THEN
                  l_qty_canbe_process := l_src_fa_inst_dtls_tbl(j).instance_asset_qty ;
                ELSE
                  l_qty_canbe_process := l_src_fa_inst_dtls_tbl(j).fa_loc_units ;
                END IF ;

                IF l_qty_canbe_process <= l_qty_to_process THEN
                  l_qty_being_process := l_qty_canbe_process ;
                ELSE
                  l_qty_being_process := l_qty_to_process ;
                END IF ;

                debug ('units being processed : '|| l_qty_being_process);

                IF l_dest_fa_category_id IS NOT NULL
                   AND
                   l_src_fa_inst_dtls_tbl(j).fa_category_id <> l_dest_fa_category_id
                THEN

                  IF l_src_fa_inst_dtls_tbl.COUNT = 1 --Is it a Full Reclassification
                     AND
                     l_src_fa_inst_dtls_tbl(j).fa_units = l_src_fa_inst_dtls_tbl(j).instance_qty
                     AND
                     p_src_move_trans_tbl(s_ind).transaction_quantity  = l_src_fa_inst_dtls_tbl(j).instance_qty
                     AND
                     l_src_fa_inst_dtls_tbl(j).fa_book_type_code =
                     NVL(l_dest_fa_book_type_code,l_src_fa_inst_dtls_tbl(j).fa_book_type_code )
                  THEN
                    -- Full Reclassification
                    l_fa_action_code := '1' ; --RECLASS
                    debug ('Action : RECLASS');
                  ELSE
                    l_fa_action_code := '2'; --INTER-ASSET
                    debug ('Action : INTER-ASSET');
                  END IF ;
                ELSIF l_dest_fa_book_type_code IS NOT NULL
                      AND
                      l_src_fa_inst_dtls_tbl(j).fa_book_type_code <> l_dest_fa_book_type_code
                THEN
                  l_fa_action_code := '2'; --INTER-ASSET
                  debug ('Action : INTER-ASSET');
                ELSE
                  l_fa_action_code := '3'; --INTRA-ASSET
                  debug ('Action : INTRA-ASSET');
                END IF ; ---What action

                IF l_fa_action_code = '1' THEN -- RECLASS

                  l_trans_rec.who_info.last_update_date := l_sysdate ;
                  l_trans_rec.who_info.creation_date := l_trans_rec.who_info.last_update_date ;
                  l_trans_rec.who_info.created_by := l_trans_rec.who_info.last_updated_by ;

                  /*
                  l_asset_hdr_rec.asset_id := l_src_fa_inst_dtls_tbl(j).fa_asset_id ;
                  l_asset_cat_rec_new.category_id := l_dest_fa_category_id ;

                  debug('inside api fa_reclass_pub.do_reclass');

                  fa_reclass_pub.do_reclass (
                     p_api_version         => 1.0 ,
                     p_init_msg_list       => fnd_api.g_false,
                     p_commit              => fnd_api.g_false,
                     p_validation_level    => fnd_api.g_valid_level_full,
                     p_calling_fn          => l_calling_fn ,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data,
                     px_trans_rec          => l_trans_rec,
                     px_asset_hdr_rec      => l_asset_hdr_rec,
                     px_asset_cat_rec_new  => l_asset_cat_rec_new,
                     p_recl_opt_rec        => l_recl_opt_rec );

                  IF (l_return_status = l_fnd_error) THEN
                    l_error_msg := cse_util_pkg.dump_error_stack;
                    RAISE fnd_api.g_exc_error ;
                  END IF;
                  */

                  -- For updating the FA Location.
                  l_dest_fa_dist_rec.employee_id        := l_src_fa_inst_dtls_tbl(j).fa_employee_id ;
                  l_dest_fa_dist_rec.deprn_expense_ccid := l_src_fa_inst_dtls_tbl(j).fa_expense_ccid ;

                  do_dist_transfer (
                     p_src_fa_inst_dtls_rec => l_src_fa_inst_dtls_tbl(j),
                     p_dest_move_trans_rec  => p_dest_move_trans_tbl(d_ind),
                     p_dest_fa_dist_rec     => l_dest_fa_dist_rec,
                     p_transaction_units    => l_qty_being_process,
                     p_csi_txn_rec          => l_txn_rec,
                     x_return_status        => l_return_status,
                     x_error_msg            => l_error_msg);

                  IF l_return_status = l_fnd_error THEN
                    RAISE fnd_api.g_exc_error ;
                  END IF ;

                  l_asset_hdr_rec.asset_id := l_src_fa_inst_dtls_tbl(j).fa_asset_id ;
                  l_asset_cat_rec_new.category_id := l_dest_fa_category_id ;

                  debug('inside api fa_reclass_pub.do_reclass');

                  fa_reclass_pub.do_reclass (
                     p_api_version         => 1.0 ,
                     p_init_msg_list       => fnd_api.g_false,
                     p_commit              => fnd_api.g_false,
                     p_validation_level    => fnd_api.g_valid_level_full,
                     p_calling_fn          => l_calling_fn ,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data,
                     px_trans_rec          => l_trans_rec,
                     px_asset_hdr_rec      => l_asset_hdr_rec,
                     px_asset_cat_rec_new  => l_asset_cat_rec_new,
                     p_recl_opt_rec        => l_recl_opt_rec );

                  IF (l_return_status = l_fnd_error) THEN
                    l_error_msg := cse_util_pkg.dump_error_stack;
                    RAISE fnd_api.g_exc_error ;
                  END IF;

                ELSIF l_fa_action_code = '2' THEN --INTER-ASSET transfer
                  --Create a new FA with a new DPI.
                  l_dest_fa_rec.fa_dpi := l_sysdate ;
                  l_dest_fa_rec.fa_book_type_code :=
                                NVL(l_dest_fa_book_type_code, l_src_fa_inst_dtls_tbl(j).fa_book_type_code);
                  l_dest_fa_rec.fa_category_id := NVL(l_dest_fa_category_id, l_src_fa_inst_dtls_tbl(j).fa_category_id);
                  l_dest_fa_rec.fa_tag_number := l_src_fa_inst_dtls_tbl(j).fa_tag_number;
                  l_dest_fa_rec.fa_serial_number := l_src_fa_inst_dtls_tbl(j).fa_serial_number;
                  l_dest_fa_rec.fa_key_ccid := l_src_fa_inst_dtls_tbl(j).fa_key_ccid;

                  ---Distribution Level Info
                  l_dest_fa_dist_rec.location_id := l_dest_fa_location_id ;
                  l_dest_fa_dist_rec.employee_id := l_src_fa_inst_dtls_tbl(j).fa_employee_id ;
                  l_dest_fa_dist_rec.deprn_expense_ccid := l_src_fa_inst_dtls_tbl(j).fa_expense_ccid ;

                  debug( 'INTER-ASSET do_inter_asset_transfer ');

                  do_inter_asset_transfer(
                    p_src_fa_inst_dtls_rec => l_src_fa_inst_dtls_tbl(j),
                    p_dest_move_trans_rec  => p_dest_move_trans_tbl(d_ind),
                    p_dest_fa_rec          => l_dest_fa_rec,
                    p_dest_fa_dist_rec     => l_dest_fa_dist_rec,
                    p_transaction_units    => l_qty_being_process,
                    p_csi_txn_rec          => l_txn_rec,
                    x_return_status        => l_return_status,
                    x_error_msg            => l_error_msg);

                  IF (l_return_status = l_fnd_error) THEN
                    RAISE fnd_api.g_exc_error ;
                  END IF ;
                ELSIF l_fa_action_code = '3' THEN -- INTRA-ASSET

                  l_dest_fa_dist_rec.employee_id := l_src_fa_inst_dtls_tbl(j).fa_employee_id ;
                  l_dest_fa_dist_rec.deprn_expense_ccid := l_src_fa_inst_dtls_tbl(j).fa_expense_ccid ;

                  debug( 'INTRA-ASSET do_dist_transfer ');

                  do_dist_transfer (
                    p_src_fa_inst_dtls_rec => l_src_fa_inst_dtls_tbl(j),
                    p_dest_move_trans_rec  => p_dest_move_trans_tbl(d_ind),
                    p_dest_fa_dist_rec     => l_dest_fa_dist_rec,
                    p_transaction_units    => l_qty_being_process,
                    p_csi_txn_rec          => l_txn_rec,
                    x_return_status        => l_return_status,
                    x_error_msg            => l_error_msg);

                  IF (l_return_status = l_fnd_error) THEN
                    RAISE fnd_api.g_exc_error ;
                  END IF ;
                END IF ; --l_fa_action_code (1,2,3).

                 -- Done with processing txn_qty?
                  IF (l_serial_control_code = 1) THEN
                      l_total_qty_processed := l_total_qty_processed + l_qty_being_process;
                      l_qty_to_process := abs(l_txn_qty) - l_total_qty_processed ;
                      IF l_qty_to_process <=0 THEN
                         debug('done with the fa interface for non serial ');
                         EXIT dest_move_trans_loop ;
                      END IF;
                  ELSE --end if addn for vintage pooling issue

                      l_qty_to_process := l_txn_qty - l_qty_being_process ;
                      IF l_qty_to_process <= 0 THEN
                         debug('done with the fa interface ');
                         EXIT dest_move_trans_loop ;
                     END IF ;
                  END IF;
/*
                l_qty_to_process := l_txn_qty - l_qty_being_process;

                IF l_qty_to_process = 0 THEN
                  -- done with the procesing with current txn and instance.
                  EXIT dest_move_trans_loop ;
                END IF ;
*/
              END LOOP; -- For j IN l_src_fa_inst_dtls_tbl.FIRST .. l_src_fa_inst_dtls_tbl.LAST
            END IF; -- l_src_fa_inst_dtls_tbl.COUNT > 0
          END IF; -- Match Inv Item ID, Serial Number etc.
        END LOOP; -- dest_move_trans_cur
      END LOOP; -- loop thru p_src_move_trans_tbl

    END IF ; --p_src_move_trans_tbl.COUNT

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      x_error_msg     := nvl(l_error_msg, cse_util_pkg.dump_error_stack);
      debug ('Error : '||x_error_msg);
  END update_fa ;


  PROCEDURE complete_csi_txn(
    p_csi_txn_id       IN number,
    x_return_status    OUT nocopy varchar2,
    x_error_message    OUT nocopy varchar2)
  IS
    l_txn_rec          csi_datastructures_pub.transaction_rec;
    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count        number;
    l_msg_data         varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_txn_rec.transaction_id          := p_csi_txn_id;
	l_txn_rec.source_group_ref        := fnd_api.g_miss_char;
    l_txn_rec.source_group_ref_id     := fnd_global.conc_request_id;
    l_txn_rec.transaction_status_code := cse_datastructures_pub.g_complete ;

    SELECT object_version_number
    INTO   l_txn_rec.object_version_number
    FROM   csi_transactions
    WHERE  transaction_id = l_txn_rec.transaction_id;

    csi_transactions_pvt.update_transactions(
      p_api_version      => 1.0,
      p_init_msg_list    => fnd_api.g_true,
      p_commit           => fnd_api.g_false,
      p_validation_level => fnd_api.g_valid_level_full,
      p_transaction_rec  => l_txn_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END complete_csi_txn;



  PROCEDURE process_a_move_txn (
    p_transaction_id      IN NUMBER,
    p_conc_request_id     IN NUMBER,
    x_src_move_trans_tbl  OUT NOCOPY move_trans_tbl,
    x_dest_move_trans_tbl OUT NOCOPY move_trans_tbl,
    x_move_processed_flag OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg           OUT NOCOPY VARCHAR2)
  IS
    l_src_move_trans_tbl      move_trans_tbl ;
    l_dest_move_trans_tbl     move_trans_tbl ;
    l_return_status           varchar2(1);
    l_error_msg               varchar2(2000);
    l_src_txn_object_ver_num  number ;
    l_dest_txn_qty            number ;
    l_dest_txn_processed      number ;
    l_txn_rec                 csi_datastructures_pub.transaction_rec ;

    CURSOR csi_txn_cur (c_transaction_id IN NUMBER) IS
      SELECT object_version_number
      FROM   csi_transactions
      WHERE  transaction_id = c_transaction_id ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    debug('Inside API cse_asset_move_pkg.process_a_move_txn');
    debug('  transaction_id       : '||p_transaction_id);

    get_move_txn_details(
      p_transaction_id        => p_transaction_id,
      x_src_move_trans_tbl    => l_src_move_trans_tbl,
      x_dest_move_trans_tbl   => l_dest_move_trans_tbl,
      x_return_status         => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error ;
    END IF ;

    IF l_src_move_trans_tbl.COUNT = 0 OR l_dest_move_trans_tbl.COUNT=0 THEN
      l_error_msg := 'No changes pending for this transaction..';
      debug(l_error_msg);
    ELSE

      update_fa(
        p_transaction_id      => p_transaction_id,
        p_src_move_trans_tbl  => l_src_move_trans_tbl,
        p_dest_move_trans_tbl => l_dest_move_trans_tbl,
        x_return_status       => l_return_status,
        x_error_msg           => l_error_msg) ;

      IF l_return_status =  fnd_api.G_RET_STS_ERROR THEN
        RAISE fnd_api.g_exc_error ;
      END IF ;

      --Assign Out parameters
      x_src_move_trans_tbl  := l_src_move_trans_tbl ;
      x_dest_move_trans_tbl := l_dest_move_trans_tbl ;
      x_move_processed_flag := 'Y' ;

      complete_csi_txn(
        p_csi_txn_id          => p_transaction_id,
        x_return_status       => l_return_status,
        x_error_message       => l_error_msg);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF ; ---l_src_move_trans_tbl.COUNT is 0.
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_move_processed_flag := 'N' ;
      x_return_status       := fnd_api.G_RET_STS_ERROR ;
      x_error_msg           := l_error_msg ;
  END  process_a_move_txn ;

---------------------------------------------------------------------------------
PROCEDURE process_misc_moves ( x_return_status OUT NOCOPY VARCHAR2,
                               x_error_msg     OUT NOCOPY VARCHAR2,
                               p_inventory_item_id IN NUMBER,
                               p_conc_request_id IN NUMBER ,
                               p_transaction_id IN NUMBER )
IS
l_cost_api_ver                NUMBER  ;
l_api_version                 NUMBER  ;
l_src_transaction_id          NUMBER;
l_src_transaction_type_id     NUMBER;
l_src_inst_asset_query_rec    csi_datastructures_pub.instance_asset_rec  ;
l_src_inst_asset_rec          csi_datastructures_pub.instance_asset_rec  ;
l_dest_inst_asset_rec         csi_datastructures_pub.instance_asset_rec  ;
l_src_inst_asset_tbl          csi_datastructures_pub.instance_asset_tbl;
l_dest_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
l_dest_inst_asset_header_tbl         csi_datastructures_pub.instance_asset_header_tbl;
l_dest_num_of_rows             NUMBER;
l_dest_inst_asset_query_rec    csi_datastructures_pub.instance_asset_query_rec ;
l_dest_transaction_type_id     NUMBER;
l_dest_asset_query_rec         cse_datastructures_pub.asset_query_rec ;
e_goto_next_trans              EXCEPTION;
l_commit                      VARCHAR2(1)  ;
l_init_msg_list               VARCHAR2(1)  ;
l_validation_level        NUMBER   ;
l_msg_data                VARCHAR2(2000);
l_txn_rec                 csi_datastructures_pub.transaction_rec ;
j                         PLS_INTEGER;
i                         PLS_INTEGER;
l_msg_index               NUMBER;
l_msg_count               NUMBER;

l_serial_move_type        VARCHAR2(20) ;
l_trx_error_rec           csi_datastructures_pub.transaction_error_rec;
l_txn_error_id            NUMBER ;
l_api_name                VARCHAR2(100) ;
l_sysdate                 DATE  ;
l_time_stamp              DATE ;
l_move_processed_flag     VARCHAR2(1) ;
l_inst_asset_failed        VARCHAR2(1) ;
l_return_status           VARCHAR2(1) ;
l_distribution_tbl        cse_datastructures_pub.distribution_tbl ;
l_adj_units               NUMBER ;
l_units_to_be_adjusted    NUMBER ;
l_asset_units_avail       NUMBER ;
l_src_txn_object_ver_num  NUMBER ;
l_asset_count_rec             csi_asset_pvt.asset_count_rec ;
l_asset_id_tbl                csi_asset_pvt.asset_id_tbl ;
l_asset_loc_tbl               csi_asset_pvt.asset_loc_tbl ;
l_lookup_tbl                  csi_asset_pvt.lookup_tbl ;
l_error_msg               VARCHAR2(2000);
e_error                   EXCEPTION ;

CURSOR  src_misc_move_trans_cur
IS
SELECT  citdv.transaction_id transaction_id
        ,citdv.transaction_type_id    transaction_type_id
        ,citdv.instance_id   instance_id
        ,DECODE(citdv.serial_number, NULL, (NVL(ciih.old_quantity,0) -
           NVL(ciih.new_quantity,0)), 1) primary_units
        ,citdv.serial_number serial_number
        ,citdv.inv_material_transaction_id
        ,citdv.source_transaction_type
        ,citdv.object_version_number
FROM     csi_inst_txn_details_v   citdv,
         csi_item_instances_h ciih
WHERE    citdv.transaction_id = ciih.transaction_id
AND    citdv.instance_id = ciih.instance_id
AND      citdv.transaction_status_code = cse_datastructures_pub.G_PENDING
AND      NVL(ciih.old_quantity,0) > NVL(ciih.new_quantity,0)
AND      citdv.transaction_id = p_transaction_id
AND      citdv.serial_number is NULL
--ORDER BY 1 ;
ORDER BY citdv.creation_date ;

CURSOR  serial_move_trans_cur
IS
SELECT  citdv.transaction_id transaction_id
        ,citdv.transaction_type_id    transaction_type_id
        ,citdv.instance_id   instance_id
        ,1 primary_units
        ,citdv.serial_number serial_number
        ,citdv.inv_material_transaction_id
        ,citdv.source_transaction_type
        ,citdv.object_version_number
FROM     csi_inst_txn_details_v   citdv
WHERE    citdv.transaction_status_code = cse_datastructures_pub.G_PENDING
AND      citdv.transaction_id = p_transaction_id
AND      citdv.serial_number is NOT NULL
--ORDER BY 1 ;
ORDER BY citdv.creation_date ;

src_misc_move_trans_rec           src_misc_move_trans_cur%ROWTYPE;

CURSOR  dest_misc_move_trans_cur (c_src_transaction_id IN NUMBER)
IS
SELECT  citdv.transaction_id transaction_id
        ,citdv.transaction_type_id    transaction_type_id
        ,citdv.instance_id   instance_id
        ,DECODE(citdv.serial_number, NULL, (NVL(ciih.new_quantity,0) -
           NVL(ciih.old_quantity,0)), 1) primary_units
        ,citdv.serial_number serial_number
        ,citdv.object_version_number
FROM    csi_inst_txn_details_v   citdv ,
        csi_item_instances_h ciih
WHERE   citdv.transaction_id =  c_src_transaction_id
AND     ciih.transaction_id = citdv.transaction_id
AND     ciih.instance_id = citdv.instance_id
AND     NVL(ciih.old_quantity,0) < NVL(ciih.new_quantity,0)
AND     citdv.serial_number IS NULL ;

dest_misc_move_trans_rec           dest_misc_move_trans_cur%ROWTYPE;

CURSOR  instance_assets_cur (c_instance_id IN NUMBER)
IS
SELECT instance_asset_id
      ,fa_location_id
      ,fa_asset_id
      ,fa_book_type_code
      ,asset_quantity
      ,object_version_number
      ,fa_sync_flag
FROM   csi_i_assets
WHERE  update_status IN ('OUT_OF_SERVICE', 'IN_SERVICE')
AND    instance_id  = c_instance_id
AND    asset_quantity > 0
ORDER BY fa_asset_id ;

CURSOR inst_asset_avail_qty (c_instance_id IN NUMBER)
IS
SELECT SUM(asset_quantity)
FROM   csi_i_assets
WHERE  update_status = 'IN_SERVICE'
AND    instance_id  = c_instance_id
AND    asset_quantity > 0 ;

CURSOR csi_txn_error_cur (c_transaction_id IN NUMBER)
IS
SELECT transaction_error_id
FROM   csi_txn_errors
WHERE  transaction_id = c_transaction_id
AND    source_type = 'ASSET_MOVE' ;

BEGIN
    l_cost_api_ver                :=  1;
    l_api_version                 :=  1.0;
    l_commit                      :=  fnd_api.g_false;
    l_init_msg_list               :=  fnd_api.g_true;
    l_validation_level            := fnd_api.g_valid_level_full;
    l_api_name                    := 'CSE_ASSET_MOVE_PKG.process_misc_moves';
    l_sysdate                     := SYSDATE ;
    l_time_stamp                  := NULL ;
    l_move_processed_flag         := 'N';
    l_inst_asset_failed           := 'N' ;

    debug ('Begin - Process Misc. Move Transactions');
    l_adj_units  := 0;
    l_units_to_be_adjusted  := 0;
    SELECT sysdate into l_sysdate from dual ;

    FOR src_misc_move_trans_rec IN src_misc_move_trans_cur
    LOOP
     BEGIN  ---for src_misc_move_trans loop
        l_inst_asset_failed  := 'N' ;
        i := 0;
        --Initialize
        l_src_inst_asset_tbl.DELETE ;

        SAVEPOINT src_trx ;
        l_units_to_be_adjusted := ABS(src_misc_move_trans_rec.primary_units);
        l_src_transaction_id := src_misc_move_trans_rec.transaction_id ;
        l_src_txn_object_ver_num := src_misc_move_trans_rec.object_version_number ;

        debug ('Source Transaction : '|| src_misc_move_trans_rec.transaction_id);
        debug ('This is Misc Move Transaction');
        debug ('Units to be adjusted '||l_units_to_be_adjusted);
        debug ('Units Available : '|| l_asset_units_avail);
        ---First Validate if enough instance Asset units exists
        OPEN inst_asset_avail_qty (src_misc_move_trans_rec.instance_id) ;
        FETCH inst_asset_avail_qty INTO l_asset_units_avail ;
        CLOSE inst_asset_avail_qty ;

        debug ('Units Available : '|| l_asset_units_avail);
        IF NVL(l_asset_units_avail,0) < l_units_to_be_adjusted
        THEN
           ---There may not be enough asset units at the source
           --asset or source asset may not be available at inst_asset.
           debug('Either Source Asset does not found
               or enough asset units does not exists ..');
           fnd_message.set_name('CSE','CSE_SRC_INST_ASSETS_NOTENOUGH');
           fnd_message.set_token('TXN_ID',l_src_transaction_id);
           fnd_message.set_token('INSTANCE_ID',src_misc_move_trans_rec.instance_id);
           l_error_msg := fnd_message.get;
           RAISE e_goto_next_trans ;
        END IF ;

       ---First Update Source Instance Asset
        FOR instance_assets_rec IN instance_assets_cur (
                 src_misc_move_trans_rec.instance_id)
        LOOP
          BEGIN ---instance_asset_loop
           SAVEPOINT inst_asset ;
           l_inst_asset_failed := 'N' ;

           ---Initilize dest record
           l_dest_inst_asset_header_tbl.DELETE ;
           l_dest_inst_asset_rec := NULL ;
           l_dest_asset_query_rec := NULL ;
           l_dest_inst_asset_tbl.DELETE ;
           l_dest_inst_asset_query_rec := cse_util_pkg.init_instance_asset_query_rec;

           i := i+1 ;
           debug ('Units to be adjusted :'||l_units_to_be_adjusted );
          IF l_units_to_be_adjusted > 0
          THEN
           IF l_units_to_be_adjusted < instance_assets_rec.asset_quantity
           THEN
             l_adj_units :=  l_units_to_be_adjusted ;
             l_units_to_be_adjusted := 0 ;
           ELSE
             l_adj_units := instance_assets_rec.asset_quantity ;
             l_units_to_be_adjusted := l_units_to_be_adjusted -
                        l_adj_units ;
           END IF ;

           debug ('New Units to be adjusted :'||l_units_to_be_adjusted );
           ---Update Source Instance Asset
           ---Initialize CSI Transaction Record.
           l_txn_rec                 := cse_util_pkg.init_txn_rec;
           l_txn_rec.transaction_type_id   := cse_util_pkg.get_txn_type_id('INSTANCE_ASSET_TIEBACK','CSE');
           l_txn_rec.transaction_quantity  := l_adj_units ;
           l_src_inst_asset_Rec := CSE_Util_Pkg.Init_Instance_Asset_Rec;
           l_src_inst_asset_rec.instance_asset_id := instance_assets_rec.instance_asset_id ;
           l_src_inst_asset_rec.asset_quantity := instance_assets_rec.asset_quantity  - l_adj_units ;
           l_src_inst_asset_rec.object_version_number := instance_assets_rec.object_version_number  ;
           l_src_inst_asset_rec.check_for_instance_expiry := fnd_api.G_FALSE ;
           l_txn_rec.transaction_status_code :=  cse_datastructures_pub.G_COMPLETE ;
           l_txn_rec.transaction_date      := l_sysdate;
           l_txn_rec.source_transaction_date      := l_sysdate;
           l_txn_rec.object_version_number  :=  1 ;
                      l_txn_rec.transaction_id := NULL ;

           debug ('Update Source Inst Asset');
           ---Update Source Instant Asset.
                      csi_asset_pvt.update_instance_asset (
                       p_api_version         => 1.0
                      ,p_commit              => fnd_api.g_false
                      ,p_init_msg_list       => fnd_api.g_false
                      ,p_validation_level    => fnd_api.g_valid_level_full
                      ,p_instance_asset_rec  => l_src_inst_asset_rec
                      ,p_txn_rec             => l_txn_rec
                      ,x_return_status       => l_return_status
                      ,x_msg_count           => l_msg_count
                      ,x_msg_data            => l_msg_data
                      ,p_lookup_tbl          => l_lookup_tbl
                      ,p_asset_count_rec     => l_asset_count_rec
                      ,p_asset_id_tbl        => l_asset_id_tbl
                      ,p_asset_loc_tbl       => l_asset_loc_tbl );


           debug ('After Update Source Inst Asset');
           IF l_return_status =  fnd_api.G_RET_STS_ERROR
           THEN
              l_error_msg := cse_util_pkg.dump_error_stack ;
              RAISE e_goto_next_trans ;
           END IF;

        --Find Dest Instance Asset and if found
        --increment asset units else create new
        --Instance assets.
        OPEN dest_misc_move_trans_cur(src_misc_move_trans_rec.transaction_id) ;
        FETCH dest_misc_move_trans_cur INTO dest_misc_move_trans_rec ;
        IF dest_misc_move_trans_cur%NOTFOUND
        THEN
           ---This is fatal exceptionn....
           debug('No Dest transaction found for : '||src_misc_move_trans_rec.transaction_id);
           fnd_message.set_name('CSE','CSE_DEST_TXN_NOTFOUND');
           fnd_message.set_token('CSI_TRANSACTION',src_misc_move_trans_rec.transaction_id);
           l_error_msg := fnd_message.get;
           RAISE e_goto_next_trans ;
         END IF ;
        CLOSE dest_misc_move_trans_cur ;

        l_dest_inst_asset_rec.update_status := cse_datastructures_pub.G_IN_SERVICE ;
        l_dest_inst_asset_rec.instance_id  := dest_misc_move_trans_rec.instance_id ;
        l_dest_inst_asset_rec.fa_asset_id  := instance_assets_rec.fa_asset_id ;
        l_dest_inst_asset_rec.fa_book_type_code  := instance_assets_rec.fa_book_type_code ;
        l_dest_inst_asset_rec.fa_location_id  := instance_assets_rec.fa_location_id ;
        l_dest_inst_asset_query_rec.update_status := cse_datastructures_pub.G_IN_SERVICE ;
        l_dest_inst_asset_query_rec.instance_id  := dest_misc_move_trans_rec.instance_id ;
        l_dest_inst_asset_query_rec.fa_asset_id  := instance_assets_rec.fa_asset_id ;
        l_dest_inst_asset_query_rec.fa_book_type_code  := instance_assets_rec.fa_book_type_code ;
        l_dest_inst_asset_query_rec.fa_location_id  := instance_assets_rec.fa_location_id ;

         debug('Dest Instance ID : '||dest_misc_move_trans_rec.instance_id);
         debug('Dest FA Asset ID : '||instance_assets_rec.fa_asset_id );
         debug('Dest Book  : '||instance_assets_rec.fa_book_type_code );
         debug('Dest FA Loc  : '||instance_assets_rec.fa_location_id );
         csi_asset_pvt.get_instance_assets
          (l_api_Version,
           l_commit,
           l_init_msg_list,
           l_validation_Level,
           l_dest_inst_asset_query_rec,
           NULL,
           l_time_stamp ,
           l_dest_inst_asset_header_tbl,
           l_return_status,
           l_msg_count,
           l_msg_data);

         IF NOT l_return_status = fnd_api.G_RET_STS_SUCCESS
         THEN
            l_error_msg := cse_util_pkg.dump_error_stack ;
            RAISE e_goto_next_trans ;
         END IF;

      IF l_dest_inst_asset_header_tbl.COUNT=1
      THEN
        ---Update Destination Instance Asset
        ---Initialize CSI Transaction Record.
        debug ('Destination Instance Asset found');
        l_txn_rec                 := cse_util_pkg.init_txn_rec;
        l_txn_rec.transaction_type_id   := cse_util_pkg.get_txn_type_id('INSTANCE_ASSET_TIEBACK','CSE');
        l_txn_rec.transaction_quantity  := l_adj_units ;
        debug ('Units being transfered : '|| l_txn_rec.transaction_quantity);
        l_dest_inst_asset_rec.asset_quantity := l_dest_inst_asset_header_tbl(1).asset_quantity  + l_adj_units ;
        l_dest_inst_asset_rec.instance_asset_id := l_dest_inst_asset_header_tbl(1).instance_asset_id ;
        l_txn_rec.transaction_status_code :=  cse_datastructures_pub.G_COMPLETE ;
        l_txn_rec.transaction_date      := l_sysdate;
        l_txn_rec.source_transaction_date      := l_sysdate;
        l_txn_rec.object_version_number  := 1 ;
                      ---l_txn_rec.transaction_id := NULL ;
        l_dest_inst_asset_rec.object_version_number := l_dest_inst_asset_header_tbl(1).object_version_number ;
        l_dest_inst_asset_rec.check_for_instance_expiry := fnd_api.G_FALSE ;

                      csi_asset_pvt.update_instance_asset (
                       p_api_version         => 1.0
                      ,p_commit              => fnd_api.g_false
                      ,p_init_msg_list       => fnd_api.g_false
                      ,p_validation_level    => fnd_api.g_valid_level_full
                      ,p_instance_asset_rec  => l_dest_inst_asset_rec
                      ,p_txn_rec             => l_txn_rec
                      ,x_return_status       => l_return_status
                      ,x_msg_count           => l_msg_count
                      ,x_msg_data            => l_msg_data
                      ,p_lookup_tbl          => l_lookup_tbl
                      ,p_asset_count_rec     => l_asset_count_rec
                      ,p_asset_id_tbl        => l_asset_id_tbl
                      ,p_asset_loc_tbl       => l_asset_loc_tbl );

        IF l_return_status =  fnd_api.G_RET_STS_ERROR
        THEN
           l_error_msg := cse_util_pkg.dump_error_stack ;
           RAISE e_goto_next_trans ;
        END IF;
      ELSE
        --Create a new destination Instance
        --Initialize CSI Transaction Record.
        debug ('Destination Instance Asset NOT found');
        l_txn_rec                 := cse_util_pkg.init_txn_rec;
        l_txn_rec.transaction_type_id   := cse_util_pkg.get_txn_type_id('INSTANCE_ASSET_TIEBACK','CSE');
        l_txn_rec.transaction_quantity  := l_adj_units ;
        debug ('Units being transfered : '|| l_txn_rec.transaction_quantity);
        l_txn_rec.transaction_status_code :=  cse_datastructures_pub.G_COMPLETE;
        l_txn_rec.transaction_date      := l_sysdate;
        l_txn_rec.source_transaction_date      := l_sysdate;
        l_txn_rec.object_version_number := 1;

        ---other attributes of inst_asset have already been set in query
        l_dest_inst_asset_rec.update_status := cse_datastructures_pub.G_IN_SERVICE ;
        l_dest_inst_asset_rec.object_version_number := 1 ;
        l_dest_inst_asset_rec.active_start_date  := l_sysdate;
        l_dest_inst_asset_rec.asset_quantity := l_adj_units ;
        l_dest_inst_asset_rec.instance_asset_id  := NULL ;
        l_dest_inst_asset_rec.check_for_instance_expiry := fnd_api.G_FALSE ;
        l_dest_inst_asset_rec.fa_sync_flag := 'Y' ;

           debug (l_dest_inst_asset_rec.fa_asset_id);
         debug('Dest Instance ID : '||l_dest_inst_asset_rec.instance_id);
         debug('Dest FA Asset ID : '||l_dest_inst_asset_rec.fa_asset_id );
         debug('Dest Book  : '||l_dest_inst_asset_rec.fa_book_type_code );
         debug('Dest FA Loc  : '||l_dest_inst_asset_rec.fa_location_id );
           debug ('Calling Create_inst_asset');

                      --l_txn_rec.transaction_id := NULL ;
                      csi_asset_pvt.create_instance_asset (
                       p_api_version         => 1.0
                      ,p_commit              => fnd_api.g_false
                      ,p_init_msg_list       => fnd_api.g_false
                      ,p_validation_level    => fnd_api.g_valid_level_full
                      ,p_instance_asset_rec  => l_dest_inst_asset_rec
                      ,p_txn_rec             => l_txn_rec
                      ,x_return_status       => l_return_status
                      ,x_msg_count           => l_msg_count
                      ,x_msg_data            => l_msg_data
                      ,p_lookup_tbl          => l_lookup_tbl
                      ,p_asset_count_rec     => l_asset_count_rec
                      ,p_asset_id_tbl        => l_asset_id_tbl
                      ,p_asset_loc_tbl       => l_asset_loc_tbl );

       IF l_return_status =  fnd_api.G_RET_STS_ERROR
       THEN
          l_error_msg := cse_util_pkg.dump_error_stack ;
          RAISE e_goto_next_trans ;
       END IF;
      END IF ;---dest instance asset found
    END IF ; ---l_units_to_be_adjusted
   END ; ---instance_asset loop ;
   END LOOP ; --instance_assets_cur
       IF l_inst_asset_failed = 'Y'
       THEN
          debug ('Instance-Asset failed ..');
          RAISE e_goto_next_trans ;
       END IF ;
       ---Succesfully processed the transactions
       ---Mark the status to Complete
        debug ('Updating Transactions as Complete '
|| l_src_transaction_id);
        debug ('Txn Object Version : '||l_src_txn_object_ver_num);

          ---Update Source txn.

          l_txn_rec := cse_util_pkg.init_txn_rec;
          l_txn_rec.transaction_id := l_src_transaction_id ;
          l_txn_rec.source_group_ref_id := p_conc_request_id;

          l_txn_rec.transaction_status_code := cse_datastructures_pub.G_COMPLETE ;

          l_txn_rec.object_version_number := l_src_txn_object_ver_num ;

          csi_transactions_pvt.update_transactions(
          p_api_version      => l_api_version
         ,p_init_msg_list    => l_init_msg_list
         ,p_commit           => l_commit
         ,p_validation_level => l_validation_level
         ,p_transaction_rec  => l_txn_rec
         ,x_return_status    => l_return_status
         ,x_msg_count        => l_msg_count
         ,x_msg_data         => l_msg_data
         );


          IF l_return_status =  fnd_api.G_RET_STS_ERROR
          THEN
              l_error_msg := cse_util_pkg.dump_error_stack ;
              RAISE e_goto_next_trans ;
          END IF;

          ---Update Destination txn.
          IF  l_src_transaction_id <> dest_misc_move_trans_rec.transaction_id
          THEN
            debug ('Updating Dest Transactions as Complete '
             || dest_misc_move_trans_rec.transaction_id);

          l_txn_rec := cse_util_pkg.init_txn_rec;
          l_txn_rec.transaction_id := dest_misc_move_trans_rec.transaction_id ;
          l_txn_rec.source_group_ref_id := p_conc_request_id;

          l_txn_rec.transaction_status_code := cse_datastructures_pub.G_COMPLETE ;

          l_txn_rec.object_version_number:= dest_misc_move_trans_rec.object_version_number ;

          csi_transactions_pvt.update_transactions(
          p_api_version      => l_api_version
         ,p_init_msg_list    => l_init_msg_list
         ,p_commit           => l_commit
         ,p_validation_level => l_validation_level
         ,p_transaction_rec  => l_txn_rec
         ,x_return_status    => l_return_status
         ,x_msg_count        => l_msg_count
         ,x_msg_data         => l_msg_data
         );


          IF l_return_status =  fnd_api.G_RET_STS_ERROR
          THEN
              l_error_msg := cse_util_pkg.dump_error_stack ;
              RAISE e_goto_next_trans ;
          END IF;
        END IF ; --Src txn <> dest txn
       COMMIT ;

     EXCEPTION
     WHEN e_goto_next_trans
     THEN
      debug ('IN Exception - e_goto_next_trans '|| substr(l_error_msg,1,200)) ;
      IF (dest_misc_move_trans_cur%ISOPEN)
      THEN
         CLOSE dest_misc_move_trans_cur ;
      END IF ;

      ROLLBACK TO src_trx ;

      l_trx_error_rec.transaction_id  := l_src_transaction_id ;
      l_trx_error_rec.error_text     :=  l_error_msg;
      l_trx_error_rec.source_type    := 'ASSET_MOVE';
      l_trx_error_rec.source_id      :=  l_src_transaction_id ;
      l_trx_error_rec.source_group_ref_id      :=  p_conc_request_id ;

         l_txn_error_id := NULL ;
            OPEN csi_txn_error_cur (l_trx_error_rec.transaction_id);
            FETCH csi_txn_error_cur INTO l_txn_error_id ;
            CLOSE csi_txn_error_cur ;

         IF l_txn_error_id IS NULL
         THEN
           csi_transactions_pvt.create_txn_error
           (l_api_version, l_init_msg_list, l_commit, l_validation_level,
            l_trx_error_rec, l_return_status, l_msg_count,l_msg_data,
            l_txn_error_id);
         ELSE
            UPDATE  csi_txn_errors
            SET     error_text = l_trx_error_rec.error_text ,
                    source_group_ref_id = p_conc_request_id,
                    last_update_date = l_sysdate
            WHERE   transaction_error_id = l_txn_error_id ;
         END IF ;
     x_error_msg := l_error_msg ;

     WHEN OTHERS
     THEN
       debug ('IN LOOP OTHERS- ');
      IF (dest_misc_move_trans_cur%ISOPEN)
      THEN
         CLOSE dest_misc_move_trans_cur ;
      END IF ;

      ROLLBACK TO src_trx ;

      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;

      l_trx_error_rec.transaction_id := l_src_transaction_id ;
      l_trx_error_rec.error_text     :=  x_error_msg;
      l_trx_error_rec.source_type    := 'ASSET_MOVE';
      l_trx_error_rec.source_id      := l_src_transaction_id ;
      l_trx_error_rec.source_group_ref_id      :=  p_conc_request_id ;

         l_txn_error_id := NULL ;
            OPEN csi_txn_error_cur (l_trx_error_rec.transaction_id);
            FETCH csi_txn_error_cur INTO l_txn_error_id ;
            CLOSE csi_txn_error_cur ;

         IF l_txn_error_id IS NULL
         THEN
           csi_transactions_pvt.create_txn_error
           (l_api_version, l_init_msg_list, l_commit, l_validation_level,
            l_trx_error_rec, l_return_status, l_msg_count,l_msg_data,
            l_txn_error_id);
         ELSE
            UPDATE  csi_txn_errors
            SET     error_text = l_trx_error_rec.error_text ,
                    source_group_ref_id = p_conc_request_id,
                    last_update_date = l_sysdate
            WHERE   transaction_error_id = l_txn_error_id ;
         END IF ;

      l_error_msg := l_error_msg || SQLERRM;
      debug ('IN LOOP OTHERS- '||substr(x_error_msg,1,220));
    END ; ---for src_misc_move_trans loop
    END LOOP ; ---for src_misc_move_trans loop

    ---10-29 Now process Serialized Moves
    FOR serial_move_trans_rec IN serial_move_trans_cur
    LOOP
          debug ('This is Misc Move Transaction for Serial Item');
          ---Update Source txn.

          l_txn_rec := cse_util_pkg.init_txn_rec;
          l_txn_rec.transaction_id := serial_move_trans_rec.transaction_id ;
          l_txn_rec.source_group_ref_id := p_conc_request_id;

          l_txn_rec.transaction_status_code := cse_datastructures_pub.G_COMPLETE ;

          l_txn_rec.object_version_number := serial_move_trans_rec.object_version_number ;

          csi_transactions_pvt.update_transactions(
          p_api_version      => l_api_version
         ,p_init_msg_list    => l_init_msg_list
         ,p_commit           => l_commit
         ,p_validation_level => l_validation_level
         ,p_transaction_rec  => l_txn_rec
         ,x_return_status    => l_return_status
         ,x_msg_count        => l_msg_count
         ,x_msg_data         => l_msg_data
         );


          IF l_return_status =  fnd_api.G_RET_STS_ERROR
          THEN
             l_error_msg := cse_util_pkg.dump_error_stack ;
             RAISE e_error ;
          END IF;

       COMMIT ;
    END LOOP ;

        debug ('End :Process_misc_moves');
EXCEPTION
WHEN e_error
THEN
      IF (dest_misc_move_trans_cur%ISOPEN)
      THEN
         CLOSE dest_misc_move_trans_cur ;
      END IF ;
      x_error_msg := l_error_msg || SQLERRM;
      debug ('OTHERS- '||x_error_msg);
       debug ('End :Process_misc_moves');

WHEN OTHERS
THEN
      IF (dest_misc_move_trans_cur%ISOPEN)
      THEN
         CLOSE dest_misc_move_trans_cur ;
      END IF ;
      x_error_msg := l_error_msg || SQLERRM;
      debug ('OTHERS- '||x_error_msg);
        debug ('End :Process_misc_moves');
END process_misc_moves ;


-------------------------------------------------------------------------------
--       PROCEDURE get_src_dest_inst_srl_code
--
--        Derives the serial control code from the inventory org
--        and to inventory org based on mtl_transaction_id
--        It will return SERIALIZED if the IB Instance with IN_INVENTORY usage
--        has serial number
--        Else it will return NON-SERIALIZED
--
-------------------------------------------------------------------------------
PROCEDURE  get_src_dest_inst_srl_code (
             p_mtl_transaction_id    IN NUMBER
            ,x_src_inst_srl_code     OUT NOCOPY VARCHAR2
            ,x_dest_inst_srl_code    OUT NOCOPY VARCHAR2
            ,x_return_status         OUT NOCOPY VARCHAR2
            ,x_error_msg             OUT NOCOPY VARCHAR2)
IS
CURSOR get_srl_code_from_org
IS
SELECT DECODE (msib.serial_number_control_code,1,'NON-SERIAL',
2, 'SERIAL', 5 ,'SERIAL',6, 'NON-SERIAL','NON-SERIAL') serial_control_code
FROM   mtl_material_transactions mmt
      ,mtl_system_items_b msib
WHERE  mmt.transaction_id    = p_mtl_transaction_id
AND    mmt.inventory_item_id = msib.inventory_item_id
AND    mmt.organization_id   = msib.organization_id ;

CURSOR get_srl_code_to_org
IS
SELECT DECODE (msib.serial_number_control_code,1,'NON-SERIAL',
2, 'SERIAL', 5 ,'SERIAL',6, 'NON-SERIAL','NON-SERIAL') serial_control_code
FROM   mtl_material_transactions mmt
      ,mtl_system_items_b msib
WHERE  mmt.transaction_id    = p_mtl_transaction_id
AND    mmt.inventory_item_id = msib.inventory_item_id
AND    mmt.transfer_organization_id   = msib.organization_id ;

BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

    OPEN get_srl_code_from_org ;
    FETCH  get_srl_code_from_org INTO x_src_inst_srl_code;
    CLOSE get_srl_code_from_org ;

    OPEN get_srl_code_to_org ;
    FETCH  get_srl_code_to_org INTO x_dest_inst_srl_code;
    CLOSE get_srl_code_to_org ;

EXCEPTION
WHEN OTHERS
THEN
    x_return_status := fnd_api.G_RET_STS_ERROR ;
    x_error_msg := SQLERRM ;
END get_src_dest_inst_srl_code ;

  -------------------------------------------------------------------------------
  -- Process internal sales order transactions of a depreciable items
  -- where the serial control codes of shipping inventory org
  -- and receiving inventory org is not same
  -------------------------------------------------------------------------------

  PROCEDURE process_srl_nosrl_xorg_txn (
    p_transaction_id           IN         NUMBER,
    p_transaction_type_id      IN         NUMBER,
    p_material_transaction_id  IN         NUMBER,
    p_conc_request_id          IN         NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2)
  IS

    CURSOR src_nosrl_trans_cur IS
      SELECT ct.transaction_id         transaction_id,
             ct.transaction_type_id    transaction_type_id,
             ciih.instance_id          instance_id,
             DECODE(cii.serial_number, NULL, (NVL(ciih.old_quantity,0)-NVL(ciih.new_quantity,0)), 1) primary_units,
             ct.transaction_quantity,
             cii.serial_number         serial_number,
             ct.inv_material_transaction_id,
             cii.object_version_number,
             cii.inv_subinventory_name,
             cii.location_id,
             'INVENTORY' location_type_code,
             ct.transaction_date,
             cii.inventory_revision,
             cii.instance_usage_code
      FROM   csi_transactions     ct,
             csi_item_instances_h ciih,
             csi_item_instances   cii
      WHERE  ct.transaction_id = p_transaction_id
      AND    ciih.transaction_id = ct.transaction_id
      AND    cii.instance_id = ciih.instance_id
      AND    NVL(ciih.old_quantity,0) > NVL(ciih.new_quantity,0)
      AND    cii.serial_number is NULL
      AND    EXISTS (
        SELECT 'x'
        FROM   csi_transactions   ct1,
               mtl_material_transactions mmt
        WHERE  ct1.transaction_type_id in (131, 142, 143, 144)
        AND    ct1.transaction_status_code = 'PENDING'
        AND    mmt.transaction_id = ct1.inv_material_transaction_id
        AND    mmt.inventory_item_id = mmt.inventory_item_id
        AND    mmt.shipment_number = mmt.shipment_number
        AND    mmt.transaction_id <> p_material_transaction_id);


    l_inventory_item_id      number;
    l_xfer_organization_id   number;
    l_shipment_number        varchar2(30);
    l_src_transaction_type   varchar2(30);

CURSOR  dest_srl_trans_cur  (c_inv_item_id IN NUMBER,
                             c_inv_org_id IN NUMBER,
                             c_shipment_number IN VARCHAR2)
IS
SELECT   citdv.transaction_id transaction_id
        ,citdv.transaction_type_id    transaction_type_id
        ,citdv.instance_id   instance_id
        ,DECODE(citdv.serial_number, NULL, (NVL(ciih.old_quantity,0) -
           NVL(ciih.new_quantity,0)), 1) primary_units
        ,citdv.serial_number serial_number
        ,citdv.object_version_number
        ,ciih.new_inv_organization_id  inv_organization_id
        ,ciih.new_inv_subinventory_name inv_subinventory_name
        ,citdv.location_id
        ,'INVENTORY' location_type_code
        ,citdv.transaction_date
        ,citdv.instance_usage_code
        ,citdv.inventory_item_id
        ,citdv.transaction_quantity
        ,citdv.source_transaction_type
FROM    csi_inst_txn_details_v   citdv,
        mtl_material_transactions mmt,
        csi_item_instances_h ciih
WHERE   mmt.inventory_item_id = c_inv_item_id
AND     mmt.organization_id = c_inv_org_id
AND     mmt.shipment_number = c_shipment_number
AND     citdv.transaction_id = ciih.transaction_id
AND     citdv.instance_id = ciih.instance_id
AND     citdv.inv_material_transaction_id = mmt.transaction_id
AND     citdv.transaction_status_code = 'PENDING'
AND     citdv.inventory_item_id = citdv.inventory_item_id
AND     citdv.serial_number is NOT NULL
AND     citdv.source_transaction_type IN (
                     'INTERORG_TRANS_RECEIPT',
                     'ISO_REQUISITION_RECEIPT',
                     'INTERORG_DIRECT_SHIP',
                     'ISO_DIRECT_SHIP') ;

    CURSOR src_srl_trans_cur IS
      SELECT ct.transaction_id transaction_id,
             ct.transaction_type_id    transaction_type_id,
             cii.instance_id   instance_id,
             DECODE(cii.serial_number, NULL, (NVL(ciih.old_quantity,0) - NVL(ciih.new_quantity,0)), 1) primary_units,
             cii.serial_number serial_number,
             ct.inv_material_transaction_id,
             cii.object_version_number,
             ciih.old_inv_organization_id   inv_organization_id,
             ciih.old_inv_subinventory_name inv_subinventory_name,
             cii.location_id,
             'INVENTORY' location_type_code,
             ct.transaction_date,
             cii.instance_usage_code,
             ct.transaction_quantity
      FROM   csi_transactions     ct,
             csi_item_instances_h ciih ,
             csi_item_instances   cii
      WHERE  ct.transaction_id   = p_transaction_id
      AND    ciih.transaction_id = ct.transaction_id
      AND    cii.instance_id     = ciih.instance_id
      AND    cii.serial_number is NOT NULL
      AND    EXISTS (
        SELECT 'x'
        FROM   csi_transactions   ct1,
               mtl_material_transactions mmt
        WHERE  ct1.transaction_type_id in (131, 142, 143, 144)
        AND    ct1.transaction_status_code = 'PENDING'
        AND    mmt.transaction_id = ct1.inv_material_transaction_id
        AND    mmt.inventory_item_id = mmt.inventory_item_id
        AND    mmt.shipment_number = mmt.shipment_number
        AND    mmt.transaction_id <> p_material_transaction_id);


CURSOR  dest_nosrl_trans_cur  (c_inv_item_id IN NUMBER,
                             c_inv_org_id IN NUMBER,
                             c_shipment_number IN VARCHAR2)
IS
SELECT   citdv.transaction_id transaction_id
        ,citdv.transaction_type_id    transaction_type_id
        ,citdv.instance_id   instance_id
        ,DECODE(citdv.serial_number, NULL, (NVL(ciih.new_quantity,0) -
           NVL(ciih.old_quantity,0)), 1) primary_units
        ,citdv.serial_number serial_number
        ,citdv.object_version_number
        ,citdv.inv_organization_id   inv_organization_id
        ,citdv.inv_subinventory_name  inv_subinventory_name
        ,citdv.location_id
        ,'INVENTORY' location_type_code
        ,citdv.transaction_date
        ,citdv.instance_usage_code
        ,citdv.transaction_quantity
        ,citdv.source_transaction_type
        ,citdv.inventory_item_id
FROM    csi_inst_txn_details_v   citdv,
         csi_item_instances_h ciih,
        mtl_material_transactions mmt
WHERE   mmt.inventory_item_id = c_inv_item_id
AND     citdv.inv_material_transaction_id = mmt.transaction_id
AND     mmt.organization_id = c_inv_org_id
AND     mmt.shipment_number = c_shipment_number
AND     citdv.transaction_status_code = 'PENDING'
AND      citdv.transaction_id = ciih.transaction_id
AND      citdv.instance_id = ciih.instance_id
AND     citdv.inventory_item_id = citdv.inventory_item_id
AND     citdv.serial_number is NULL
AND     citdv.location_type_code = 'INVENTORY'
AND     citdv.source_transaction_type IN (
                     'INTERORG_TRANS_RECEIPT',
                     'ISO_REQUISITION_RECEIPT',
                 'INTERORG_DIRECT_SHIP',
                     'ISO_DIRECT_SHIP') ;

l_sysdate                 DATE ;
l_dest_inst_asset_rec         csi_datastructures_pub.instance_asset_rec ;
l_txn_rec                     csi_datastructures_pub.transaction_rec ;
l_msg_index                   NUMBER;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_return_status               VARCHAR2(1);
l_error_msg                   VARCHAR2(2000);
l_trx_error_rec               csi_datastructures_pub.transaction_error_rec;
i                             NUMBER ;
j                             NUMBER ;
l_src_move_trans_tbl      move_trans_tbl ;
l_dest_move_trans_tbl     move_trans_tbl ;
l_dest_trans_cnt          NUMBER ;
l_txn_error_id            NUMBER ;

e_error                  EXCEPTION ;

CURSOR csi_txn_error_cur (c_transaction_id IN NUMBER)
IS
SELECT transaction_error_id
FROM   csi_txn_errors
WHERE  transaction_id = c_transaction_id
AND    source_type = 'ASSET_MOVE' ;

  BEGIN

    debug('======== Begin : process_srl_nosrl_xorg_txn for CSI Txn ID :'|| p_transaction_id||' =========');

    SELECT sysdate INTO l_sysdate FROM DUAL ;
    i := 0;
    j := 0;
    x_return_status := fnd_api.g_ret_sts_success;

    SELECT inventory_item_id,
           shipment_number,
           transfer_organization_id
    INTO   l_inventory_item_id,
           l_shipment_number,
           l_xfer_organization_id
    FROM   mtl_material_transactions
    WHERE  transaction_id = p_material_transaction_id;

    SELECT source_transaction_type
    INTO   l_src_transaction_type
    FROM   csi_txn_types
    WHERE  transaction_type_id = p_transaction_type_id;

    ---FOR Source Non-Serial and Destination Serial
    FOR src_nosrl_trans_rec IN src_nosrl_trans_cur
    LOOP

      debug('Inside src_nosrl_trans_cur');
      i := i+1 ;
      l_src_move_trans_tbl(i).transaction_id              := p_transaction_id ;
      l_src_move_trans_tbl(i).transaction_date            := src_nosrl_trans_rec.transaction_date  ;
      l_src_move_trans_tbl(i).object_version_number       := src_nosrl_trans_rec.object_version_number ;
      l_src_move_trans_tbl(i).instance_id                 := src_nosrl_trans_rec.instance_id   ;
      l_src_move_trans_tbl(i).primary_units               := src_nosrl_trans_rec.primary_units ;
      l_src_move_trans_tbl(i).instance_usage_code         := src_nosrl_trans_rec.instance_usage_code ;
      l_src_move_trans_tbl(i).serial_number               := src_nosrl_trans_rec.serial_number ;
      l_src_move_trans_tbl(i).inv_material_transaction_id := src_nosrl_trans_rec.inv_material_transaction_id  ;
      l_src_move_trans_tbl(i).source_transaction_type     := l_src_transaction_type ;
      l_src_move_trans_tbl(i).inv_item_id                 := l_inventory_item_id ;
      l_src_move_trans_tbl(i).location_id                 := src_nosrl_trans_rec.location_id  ;
      l_src_move_trans_tbl(i).location_type_code          := src_nosrl_trans_rec.location_type_code ;

      debug('SRC MOve Trans Table : Item ID :'|| l_src_move_trans_tbl(i).inv_item_id);
      debug('SRC MOve Trans Table : Serial_number :'|| l_src_move_trans_tbl(i).serial_number);

      FOR dest_srl_trans_rec IN dest_srl_trans_cur(l_inventory_item_id, l_xfer_organization_id, l_shipment_number)
      LOOP
        j := j+1 ;
        l_dest_trans_cnt := l_dest_trans_cnt+1 ;
        l_dest_move_trans_tbl(j).transaction_id           := dest_srl_trans_rec.transaction_id     ;
        l_dest_move_trans_tbl(j).instance_id              := dest_srl_trans_rec.instance_id ;
        l_dest_move_trans_tbl(j).primary_units            := dest_srl_trans_rec.primary_units ;
        l_dest_move_trans_tbl(j).serial_number            := dest_srl_trans_rec.serial_number  ;
        l_dest_move_trans_tbl(j).object_version_number    := dest_srl_trans_rec.object_version_number  ;
        l_dest_move_trans_tbl(j).location_id              := dest_srl_trans_rec.location_id  ;
        l_dest_move_trans_tbl(j).location_type_code       := dest_srl_trans_rec.location_type_code    ;
        l_dest_move_trans_tbl(j).transaction_date         := dest_srl_trans_rec.transaction_date ;
        l_dest_move_trans_tbl(j).transaction_quantity     := dest_srl_trans_rec.transaction_quantity  ;
        l_dest_move_trans_tbl(j).source_transaction_type  := dest_srl_trans_rec.source_transaction_type  ;
        l_dest_move_trans_tbl(j).inv_item_id              := l_inventory_item_id ;

        debug('DEST MOve Trans Table : Item ID :'|| l_dest_move_trans_tbl(j).inv_item_id);
        debug('DEST MOve Trans Table : Serial_number :'|| l_dest_move_trans_tbl(j).serial_number);
      END LOOP ; --dest_srl_trans_rec
    END LOOP ; --src_nosrl_trans_cur

    IF l_src_move_trans_tbl.COUNT > 0 AND l_dest_move_trans_tbl.COUNT > 0 THEN
      update_fa(
        p_transaction_id        => p_transaction_id,
        p_src_move_trans_tbl    => l_src_move_trans_tbl,
        p_dest_move_trans_tbl   => l_dest_move_trans_tbl,
        x_return_status         => l_return_status,
        x_error_msg             => l_error_msg) ;

      IF l_return_status =  fnd_api.G_RET_STS_ERROR THEN
        debug ('Update Status Failed ..');
        RAISE e_error ;
      END IF ;

      -- Update transaction status code to COMPLETE
      update_txn_status (
        p_src_move_trans_tbl  => l_src_move_trans_tbl,
        p_dest_move_trans_tbl => l_dest_move_trans_tbl,
        p_conc_request_id     => p_conc_request_id,
        x_return_status       => l_return_status,
        x_error_msg           => l_error_msg);

      IF l_return_status =  fnd_api.G_RET_STS_ERROR THEN
        debug ('Update Status Failed ..');
        RAISE e_error ;
      END IF ;

    ELSE
      debug ('Source or Destination tables not populated..');
      RAISE e_error ;
    END IF ;

    -- FOR Source Serial and Destination Non-Serial
    FOR src_srl_trans_rec IN src_srl_trans_cur
    LOOP

      debug('Inside src_srl_trans_cur');
      l_dest_trans_cnt := 0 ;

      i := i+1 ;
      l_src_move_trans_tbl(i).transaction_id              := src_srl_trans_rec.transaction_id ;
      l_src_move_trans_tbl(i).transaction_date            := src_srl_trans_rec.transaction_date  ;
      l_src_move_trans_tbl(i).object_version_number       := src_srl_trans_rec.object_version_number ;
      l_src_move_trans_tbl(i).instance_id                 := src_srl_trans_rec.instance_id   ;
      l_src_move_trans_tbl(i).primary_units               := src_srl_trans_rec.primary_units ;
      l_src_move_trans_tbl(i).instance_usage_code         := src_srl_trans_rec.instance_usage_code ;
      l_src_move_trans_tbl(i).serial_number               := src_srl_trans_rec.serial_number ;
      l_src_move_trans_tbl(i).inv_material_transaction_id := src_srl_trans_rec.inv_material_transaction_id  ;
      l_src_move_trans_tbl(i).source_transaction_type     := l_src_transaction_type ;
      l_src_move_trans_tbl(i).inv_item_id                 := l_inventory_item_id ;
      l_src_move_trans_tbl(i).location_id                 := src_srl_trans_rec.location_id  ;
      l_src_move_trans_tbl(i).location_type_code          := src_srl_trans_rec.location_type_code ;

      debug('SRC MOve Trans Table : Item ID :'|| l_src_move_trans_tbl(i).inv_item_id);
      debug('SRC MOve Trans Table : Serial_number :'|| l_src_move_trans_tbl(i).serial_number);

      FOR dest_nosrl_trans_rec IN dest_nosrl_trans_cur(l_inventory_item_id, l_xfer_organization_id, l_shipment_number)
      LOOP

        debug ('Dest Txn id : '|| dest_nosrl_trans_rec.transaction_id);
        l_dest_trans_cnt := l_dest_trans_cnt+1 ;

        j := j+1 ;
        l_dest_trans_cnt := l_dest_trans_cnt+1 ;
        l_dest_move_trans_tbl(j).transaction_id           := dest_nosrl_trans_rec.transaction_id     ;
        l_dest_move_trans_tbl(j).instance_id              := dest_nosrl_trans_rec.instance_id ;
        l_dest_move_trans_tbl(j).primary_units            := dest_nosrl_trans_rec.primary_units ;
        l_dest_move_trans_tbl(j).serial_number            := dest_nosrl_trans_rec.serial_number  ;
        l_dest_move_trans_tbl(j).object_version_number    := dest_nosrl_trans_rec.object_version_number  ;
        l_dest_move_trans_tbl(j).location_id              := dest_nosrl_trans_rec.location_id  ;
        l_dest_move_trans_tbl(j).location_type_code       := dest_nosrl_trans_rec.location_type_code    ;
        l_dest_move_trans_tbl(j).transaction_date         := dest_nosrl_trans_rec.transaction_date ;
        l_dest_move_trans_tbl(j).transaction_quantity     := dest_nosrl_trans_rec.transaction_quantity  ;
        l_dest_move_trans_tbl(j).source_transaction_type  := dest_nosrl_trans_rec.source_transaction_type  ;
        l_dest_move_trans_tbl(j).inv_item_id              := l_inventory_item_id ;

        debug('DEST MOve Trans Table : Item ID :'|| l_dest_move_trans_tbl(j).inv_item_id);
        debug('DEST MOve Trans Table : Serial_number :'|| l_dest_move_trans_tbl(j).serial_number);

      END LOOP ; --dest_nosrl_trans_rec
    END LOOP ;  -- src_srl_trans_rec

    IF l_src_move_trans_tbl.COUNT > 0 AND l_dest_move_trans_tbl.COUNT > 0 THEN

      update_fa(
        p_transaction_id       => p_transaction_id,
        p_src_move_trans_tbl   => l_src_move_trans_tbl,
        p_dest_move_trans_tbl  => l_dest_move_trans_tbl,
        x_return_status        => l_return_status,
        x_error_msg            => l_error_msg) ;

      IF l_return_status =  fnd_api.G_RET_STS_ERROR THEN
        debug ('Update Status Failed ..');
        RAISE e_error ;
      END IF ;

      -- Update transaction status code to COMPLETE
      update_txn_status (
        p_src_move_trans_tbl  => l_src_move_trans_tbl,
        p_dest_move_trans_tbl => l_dest_move_trans_tbl,
        p_conc_request_id     => p_conc_request_id,
        x_return_status       => l_return_status,
        x_error_msg           => l_error_msg);

      IF l_return_status =  fnd_api.G_RET_STS_ERROR THEN
        debug ('Update Status Failed ..');
        RAISE e_error ;
      END IF ;

    ELSE
      debug ('Source or Destination tables not populated..');
      RAISE e_error ;
    END IF ;



  EXCEPTION
  WHEN e_error
  THEN
      debug ('IN Exception process_srl_nosrl_xorg_txn') ;

      l_trx_error_rec.transaction_id  := p_transaction_id ;
      l_trx_error_rec.error_text     :=  l_error_msg;
      l_trx_error_rec.source_type    := 'ASSET_MOVE';
      l_trx_error_rec.source_id      :=  p_transaction_id ;
      l_trx_error_rec.source_group_ref_id      :=  p_conc_request_id ;


         --For better error reporting
         l_txn_error_id := NULL ;
            OPEN csi_txn_error_cur (l_trx_error_rec.transaction_id);
            FETCH csi_txn_error_cur INTO l_txn_error_id ;
            CLOSE csi_txn_error_cur ;

         IF l_txn_error_id IS NULL
         THEN
           csi_transactions_pvt.create_txn_error
           (1.0, fnd_api.g_true, fnd_api.g_false, fnd_api.g_valid_level_full,
            l_trx_error_rec, l_return_status, l_msg_count,l_msg_data,
            l_txn_error_id);
         ELSE
            UPDATE  csi_txn_errors
            SET     error_text = l_trx_error_rec.error_text ,
                    source_group_ref_id = p_conc_request_id,
                    last_update_date = l_sysdate
            WHERE   transaction_error_id = l_txn_error_id ;
         END IF ;
         --For better error reporting
    x_return_status := fnd_api.g_ret_sts_error;
    x_error_msg := l_error_msg ;

   WHEN OTHERS
   THEN
      debug ('IN Others Exception process_srl_nosrl_xorg_txn :'
                              ||SQLERRM) ;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','process_srl_nosrl_xorg_txn');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;

      l_trx_error_rec.transaction_id := p_transaction_id ;
      l_trx_error_rec.error_text     :=  l_error_msg;
      l_trx_error_rec.source_type    := 'ASSET_MOVE';
      l_trx_error_rec.source_id      := p_transaction_id ;
      l_trx_error_rec.source_group_ref_id      :=  p_conc_request_id ;

         --For better error reporting
         l_txn_error_id := NULL ;
            OPEN csi_txn_error_cur (l_trx_error_rec.transaction_id);
            FETCH csi_txn_error_cur INTO l_txn_error_id ;
            CLOSE csi_txn_error_cur ;

         IF l_txn_error_id IS NULL
         THEN
           csi_transactions_pvt.create_txn_error
           (1.0, fnd_api.g_true, fnd_api.g_false, fnd_api.g_valid_level_full,
            l_trx_error_rec, l_return_status, l_msg_count,l_msg_data,
            l_txn_error_id);
         ELSE
            UPDATE  csi_txn_errors
            SET     error_text = l_trx_error_rec.error_text ,
                    source_group_ref_id = p_conc_request_id,
                    last_update_date = l_sysdate
            WHERE   transaction_error_id = l_txn_error_id ;
         END IF ;
         --For better error reporting
    x_return_status := fnd_api.g_ret_sts_error;

      x_error_msg := l_error_msg || SQLERRM;
END process_srl_nosrl_xorg_txn ;
--------------------------------------------------------------------------------------

  PROCEDURE identify_txn_action(
    p_inventory_item_id   IN number,
    p_csi_txn_rec         IN csi_transactions%rowtype,
    x_txn_context         OUT nocopy txn_context,
    x_action              OUT nocopy varchar2)
  IS

    l_mtl_type_id           number;
    l_mtl_src_type_id       number;
    l_mtl_action_id         number;
    l_mtl_src_line_id       number;
    l_mtl_txn_src_id        number;
    l_mtl_primary_qty       number;
    l_mtl_txn_date          date;

    l_inventory_item_id     number;
    l_organization_id       number;
    l_serial_code           number;
    l_lot_code              number;
    l_primary_uom_code      varchar2(6);
    l_asset_creation_code   varchar2(1);
    l_depreciable_flag      varchar2(1);
    l_redeploy_flag         varchar2(1);
    l_item                  varchar2(80);
    l_item_description      varchar2(240);
    l_mtl_xfer_txn_id       number;

    l_change_owner          varchar2(1);

    l_action                varchar2(30);
    l_asset_exists          varchar2(1) := 'N'; --Added For bug9141680
  BEGIN

    debug('Inside identify_txn_action');

    l_action := 'NONE';

    debug('  csi_txn_date           : '||p_csi_txn_rec.transaction_date);
    debug('  mtl_txn_id             : '||p_csi_txn_rec.inv_material_transaction_id);

    x_txn_context.csi_txn_id          := p_csi_txn_rec.transaction_id;
    x_txn_context.csi_txn_type_id     := p_csi_txn_rec.transaction_type_id;
    x_txn_context.csi_txn_date        := p_csi_txn_rec.transaction_date;

    IF p_csi_txn_rec.inv_material_transaction_id is not null THEN
      SELECT transaction_type_id,
             transaction_source_type_id,
             transaction_action_id ,
             trx_source_line_id,
             transaction_source_id,
             primary_quantity,
             transaction_date,
             inventory_item_id,
             organization_id,
             transfer_transaction_id
      INTO   l_mtl_type_id,
             l_mtl_src_type_id,
             l_mtl_action_id,
             l_mtl_src_line_id,
             l_mtl_txn_src_id,
             l_mtl_primary_qty,
             l_mtl_txn_date,
             l_inventory_item_id,
             l_organization_id,
             l_mtl_xfer_txn_id
      FROM   mtl_material_transactions
      WHERE  transaction_id = p_csi_txn_rec.inv_material_transaction_id;

      debug('  mtl_txn_type_id        : '||l_mtl_type_id);
      debug('  mtl_src_type_id        : '||l_mtl_src_type_id);
      debug('  mtl_txn_action_id      : '||l_mtl_action_id);
      debug('  mtl_txn_date           : '||l_mtl_txn_date);

      x_txn_context.mtl_txn_id          := p_csi_txn_rec.inv_material_transaction_id;
      x_txn_context.mtl_txn_type_id     := l_mtl_type_id;
      x_txn_context.mtl_txn_action_id   := l_mtl_action_id;
      x_txn_context.mtl_txn_src_type_id := l_mtl_src_type_id;
      x_txn_context.mtl_txn_date        := l_mtl_txn_date;
      x_txn_context.mtl_txn_src_id      := l_mtl_txn_src_id;
      x_txn_context.mtl_src_trx_line_id := l_mtl_src_line_id;
      x_txn_context.mtl_xfer_txn_id     := l_mtl_xfer_txn_id;
      x_txn_context.inventory_item_id   := l_inventory_item_id;
      x_txn_context.organization_id     := l_organization_id;
      x_txn_context.primary_quantity    := l_mtl_primary_qty;
      --x_txn_context.dst_serial_code     :=
      --x_txn_context.dst_lot_code        :=

    ELSE
      -- from csi_item_instance figure out the item, org and transaction qty
      SELECT cii.inventory_item_id,
             cii.last_vld_organization_id
      INTO   l_inventory_item_id,
             l_organization_id
      FROM   csi_item_instances cii,
             csi_item_instances_h ciih
      WHERE  ciih.transaction_id  = p_csi_txn_rec.transaction_id
      AND    cii.instance_id      = ciih.instance_id
      AND    rownum = 1;

--bug#6354065
      x_txn_context.inventory_item_id   := l_inventory_item_id  ;

    END IF;

    debug('  inventory_item_id      : '||l_inventory_item_id);
    debug('  organization_id        : '||l_organization_id);

    IF nvl(p_inventory_item_id, l_inventory_item_id) <> l_inventory_item_id THEN
      l_action := 'NONE';
      debug('entered parameter does not match for this transaction. skipping.');
    ELSE

      SELECT serial_number_control_code,
             primary_uom_code,
             asset_creation_code,
             description,
             concatenated_segments
      INTO   l_serial_code,
             l_primary_uom_code,
             l_asset_creation_code,
             l_item_description,
             l_item
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = l_inventory_item_id
      AND    organization_id   = l_organization_id;

      IF nvl(l_asset_creation_code,'0') in ('1', 'Y') THEN
        l_depreciable_flag := 'Y';
      ELSE
        l_depreciable_flag := 'N';
      END IF;

      x_txn_context.primary_uom_code    := l_primary_uom_code;
      x_txn_context.src_serial_code     := l_serial_code;
      x_txn_context.src_lot_code        := l_lot_code;
      x_txn_context.depreciable_flag    := l_depreciable_flag;
      x_txn_context.item                := l_item;
      x_txn_context.item_description    := l_item_description;

      debug('  item_name              : '||l_item);
      debug('  item_description       : '||l_item_description);
        --Added For bug9141680
        IF l_depreciable_flag = 'N' AND p_csi_txn_rec.transaction_type_id in (132, 133) THEN
          IF l_serial_code IN (2, 5) THEN
            BEGIN
              SELECT  'Y'
							INTO    l_asset_exists
              FROM    csi_item_instances_h CIIH,
                      csi_item_instances CII,
                      csi_i_assets cia
              WHERE   CIIH.transaction_id = p_csi_txn_rec.transaction_id
							AND     CIIH.instance_id = CII.instance_id
							AND     CII.instance_id = CIA.instance_id
              AND    CII.inventory_item_id = l_inventory_item_id
              AND     CIA.active_end_date IS NULL OR CIA.active_end_date > SYSDATE;
            EXCEPTION
						  WHEN TOO_MANY_ROWS THEN
							  l_asset_exists := 'Y';
						  WHEN OTHERS THEN
							  l_asset_exists := 'N';
            END;
          ELSE
            BEGIN
              SELECT  'Y'
							INTO    l_asset_exists
              FROM   csi_item_instances_h CIIH,
                     csi_item_instances   CII,
                     csi_i_assets CIA
              WHERE  CIIH.transaction_id   = p_csi_txn_rec.transaction_id
              AND    CII.instance_id       = CIIH.instance_id
              AND    CII.inventory_item_id = l_inventory_item_id
              AND    nvl(CIIH.new_quantity, 0) - nvl(CIIH.old_quantity,0) < 0
							AND    CII.instance_id = CIA.instance_id
              AND     CIA.active_end_date IS NULL OR CIA.active_end_date > SYSDATE;

            EXCEPTION
						  WHEN TOO_MANY_ROWS THEN
							  l_asset_exists := 'Y';
						  WHEN OTHERS THEN
							  l_asset_exists := 'N';
            END;
          END IF;
				END IF;
				  debug('  l_asset_exists         : '||l_asset_exists);
				--Added For bug9141680


      IF p_csi_txn_rec.inv_material_transaction_id is not null THEN
        -- these transactions are handled by "create assets" program
        IF ( p_csi_txn_rec.transaction_type_id IN (
               105, -- PO_RECEIPT_INTO_PROJECT
               112, -- PO_RECEIPT_INTO_INVENTORY
               117, -- MISC_RECEIPT
               128, -- ACCT_RECEIPT
               129) -- ACCT_ALIAS_RECEIPT
             AND
             l_depreciable_flag = 'Y' )
           OR
           ( p_csi_txn_rec.transaction_type_id IN (
               133, -- MISC_ISSUE_HZ_LOC
               132) -- ISSUE_TO_HZ_LOC
             AND
             l_depreciable_flag = 'N' AND l_asset_exists = 'N')--Added For bug9141680
        THEN
          l_action := 'NONE';
          debug('this transaction is to be handled by the create assets program. skipping.');
        ELSIF p_csi_txn_rec.transaction_type_id = 134  THEN -- MISC_RECEIPT_HZ_LOC
          l_action := 'MOVE'; --Always handle MISC_RECEIPT_HZ_LOC as a move transaction
        -- following txns are typical move transactions
        ELSIF (p_csi_txn_rec.transaction_type_id IN (
                113,  -- MOVE_ORDER_ISSUE_TO_PROJECT
                114,  -- SUBINVENTORY_TRANSFER
                115,  -- INTERORG_TRANSFER
                120,  -- MISC_RECEIPT_FROM_PROJECT
                121,  -- MISC_ISSUE_TO_PROJECT
                130,  -- ISO_SHIPMENT
                131,  -- ISO_REQUISITION_RECEIPT
		138,  -- ISO_TRANSFER, Added for Bug 6871633
                139,  -- CYCLE_COUNT_TRANSFER
                143,  -- INTERORG_DIRECT_SHIP
                144,  -- INTERORG_TRANS_RECEIPT
                145,  -- INTERORG_TRANS_SHIPMENT
                146,  -- SALES_ORDER_PICK
                147,  -- ISO_PICK
                151,  -- PROJECT_BORROW
                152,  -- PROJECT_TRANSFER
                153)) -- PROJECT_PAYBACK
              OR
              ( p_csi_txn_rec.transaction_type_id IN (
                  133, -- MISC_ISSUE_HZ_LOC
                  132) -- ISSUE_TO_HZ_LOC
                AND
                l_depreciable_flag = 'Y' )
              OR
              ( p_csi_txn_rec.transaction_type_id IN (
                  133, -- MISC_ISSUE_HZ_LOC
                  132) -- ISSUE_TO_HZ_LOC
              AND
                l_depreciable_flag = 'N' AND l_asset_exists = 'Y')--Added For bug9141680
        THEN
          l_action := 'MOVE';

          IF p_csi_txn_rec.transaction_type_id IN (
               115, -- INTERORG_TRANSFER
               130, -- ISO_SHIPMENT
               131, -- ISO_REQUISITION_RECEIPT
               143, -- INTERORG_DIRECT_SHIP
               144, -- INTERORG_TRANS_RECEIPT
               145) -- INTERORG_TRANS_SHIPMENT
          THEN
            l_action := 'INTER-ORG-MOVE';
          END IF;

        ELSIF p_csi_txn_rec.transaction_type_id IN (
                51,   -- OM_SHIPMENT
                53,   -- RMA_RECEIPT
                116,  -- MISC_ISSUE
                124,  -- ACCT_ISSUE
                125,  -- ACCT_ALIAS_ISSUE
                126,  -- ISO_ISSUE
                127,  -- RETURN_TO_VENDOR
                135,  -- ISO_ISSUE,
		--Bug 5702842
		148,  ---- PO_RCPT_ADJUSTMENT,
                149,  -- INT_REQ_RCPT_ADJUSTMENT
                150)  -- SHIPMENT_RCPT_ADJUSTMENT
        THEN
          -- logic here is based on owner change in installation details
          IF p_csi_txn_rec.transaction_type_id = 51 THEN
            BEGIN
              SELECT nvl(src_change_owner, 'N')
              INTO   l_change_owner
              FROM   csi_ib_txn_types        citt,
                     csi_t_txn_line_details  ctld,
                     csi_t_transaction_lines ctl
              WHERE  ctl.source_transaction_type_id = 51
              AND    ctld.transaction_line_id     = ctl.transaction_line_id
              AND    ctld.source_transaction_flag = 'Y'
              AND    ctld.csi_transaction_id      = p_csi_txn_rec.transaction_id
              AND    citt.sub_type_id             = ctld.sub_type_id
              AND    rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                SELECT nvl(src_change_owner, 'N')
                INTO   l_change_owner
                FROM   csi_ib_txn_types    citt,
                       csi_source_ib_types csit
                WHERE  csit.transaction_type_id = 51
                AND    csit.default_flag        = 'Y'
                and    citt.sub_type_id         = csit.sub_type_id;
            END;

            IF l_change_owner = 'Y' THEN
              l_action := 'ADJUST';
            ELSE
              l_action := 'MOVE';
            END IF;

          ELSIF p_csi_txn_rec.transaction_type_id = 53 THEN

            BEGIN
              SELECT nvl(src_change_owner, 'N')
              INTO   l_change_owner
              FROM   csi_ib_txn_types
              WHERE  sub_type_id  = p_csi_txn_rec.txn_sub_type_id;
            EXCEPTION
              WHEN no_data_found THEN
                SELECT nvl(src_change_owner, 'N')
                INTO   l_change_owner
                FROM   csi_ib_txn_types    citt,
                       csi_source_ib_types csit
                WHERE  csit.transaction_type_id = 53
                AND    csit.default_flag        = 'Y'
                AND    citt.sub_type_id         = csit.sub_type_id;
            END;

            IF l_change_owner = 'N' THEN
              l_action := 'MOVE';
            ELSE
              l_action := 'COMPLETE';
            END IF;

          ELSE
            l_action := 'ADJUST';
          END IF;

        ELSIF p_csi_txn_rec.transaction_type_id IN (
             71,  -- WIP_ISSUE
             72,  -- WIP_RECEIPT
             73,  -- WIP_ASSY_COMPLETION
             74,  -- WIP_ASSY_RETURN
             75,  -- WIP_BYPRODUCT_COMPLETION
             76)  -- WIP_BYPRODUCT_RETURN
        THEN
          l_action := 'COMPLETE';
        END IF;

      ELSE -- non mmt transactions

        IF p_csi_txn_rec.transaction_type_id IN (
                1,    -- UI
                91,   -- EAM_ASSET_CREATION
                106,  -- PROJECT_ITEM_INSTALLED
                107,  -- PROJECT_ITEM_UNINSTALLED
               -- 108,  -- PROJECT_ITEM_IN_SERVICE  --commented for bug8845256
                111)  -- ITEM_MOVE
        THEN
          l_action := 'MOVE';
        ELSIF p_csi_txn_rec.transaction_type_id IN (
               109,  -- IN_SERVICE
               110)  -- OUT_OF_SERVICE
        THEN
          l_action := 'MISC-MOVE';

	--Added for 8845256--
        ELSIF (p_csi_txn_rec.transaction_type_id = 108  -- PROJECT_ITEM_IN_SERVICE
               AND
	       l_depreciable_flag = 'N' )
        THEN
          l_action := 'NONE';
          debug('this transaction is to be handled by the Interface In-service program. skipping.');
        --Added for 8845256--
       ELSIF p_csi_txn_rec.transaction_type_id = 51 THEN -- OM Bill Only SO


            BEGIN
              SELECT nvl(src_change_owner, 'N')
              INTO   l_change_owner
              FROM   csi_ib_txn_types        citt,
                     csi_t_txn_line_details  ctld,
                     csi_t_transaction_lines ctl
              WHERE  ctl.source_transaction_type_id = 51
              AND    ctld.transaction_line_id     = ctl.transaction_line_id
              AND    ctld.source_transaction_flag = 'Y'
              AND    ctld.csi_transaction_id      = p_csi_txn_rec.transaction_id
              AND    citt.sub_type_id             = ctld.sub_type_id
              AND    rownum = 1;

            DEBUG( 'Bill Only Sql 1 '||l_change_owner );
            EXCEPTION
              WHEN no_data_found THEN
                DEBUG( 'Bill Only No Data Found' );
                SELECT nvl(src_change_owner, 'N')
                INTO   l_change_owner
                FROM   csi_ib_txn_types    citt,
                       csi_source_ib_types csit
                WHERE  csit.transaction_type_id = 51
                AND    csit.default_flag        = 'Y'
                and    citt.sub_type_id         = csit.sub_type_id;
            DEBUG( 'Bill Only Sql 2 '||l_change_owner );
            END;

            IF l_change_owner = 'Y' THEN
              l_action := 'ADJUST';
            ELSE
              l_action := 'MOVE';
            END IF;

        END IF;

      END IF;

    END IF; -- parameter check p_inventory_item_id

    x_action := l_action;

  END identify_txn_action;

  PROCEDURE get_instance_info(
    p_csi_txn_rec         IN csi_transactions%rowtype,
    p_txn_context         IN txn_context,
    px_action             IN OUT nocopy varchar2,
    x_instance_tbl           OUT nocopy instance_tbl,
    x_return_status          OUT nocopy varchar2)
  IS

    CURSOR all_inst_cur(p_csi_txn_id IN number, p_inventory_item_id IN number) IS
      SELECT cii.instance_id,
             cii.lot_number,
             cii.serial_number,
             nvl(ciih.old_quantity, 0)  old_quantity,
             nvl(ciih.new_quantity, 0) new_quantity,
             ciih.old_location_type_code,
             ciih.old_location_id,
             ciih.new_location_type_code,
             ciih.new_location_id
      FROM   csi_item_instances_h ciih,
             csi_item_instances   cii
      WHERE  ciih.transaction_id   = p_csi_txn_id
      AND    cii.instance_id       = ciih.instance_id
      AND    cii.inventory_item_id = p_inventory_item_id;

    CURSOR cia_cur(p_inst_id IN number) IS
      SELECT instance_asset_id
      FROM   csi_i_assets
      WHERE  instance_id    = p_inst_id
      AND    asset_quantity > 0
      AND    fa_sync_flag   = 'Y';

    CURSOR cia_pending_in_fma(p_inst_id IN number) IS
      SELECT cia.instance_asset_id
      FROM   csi_i_assets cia,
             fa_mass_additions fma
      WHERE  cia.instance_id    = p_inst_id
      AND    cia.asset_quantity > 0
      AND    cia.fa_asset_id    is null
      AND    fma.mass_addition_id = cia.fa_mass_addition_id
      AND    fma.queue_name       = 'POST'
      AND    fma.posting_status   = 'POST';


    CURSOR pend_txn_cur(p_instance_id IN number, p_csi_txn_id IN number, p_inv_item_id in NUMBER) IS
      SELECT ct.transaction_id
      FROM   csi_transactions ct,
             csi_item_instances cii,
             csi_item_instances_h ciih
      WHERE  ciih.instance_id           = p_instance_id
      AND    ciih.transaction_id        < p_csi_txn_id
      AND    cii.instance_id            = ciih.instance_id
      AND    cii.inventory_item_id      = p_inv_item_id
      AND    ct.transaction_id          = ciih.transaction_id
      AND    ct.transaction_status_code = 'PENDING';

    l_inst_tbl             instance_tbl;
    inst_ind               binary_integer := 0;
    l_cia_found            boolean := FALSE;

  BEGIN

    debug('Inside get_instance_info ');
    FOR all_inst_rec IN all_inst_cur (p_txn_context.csi_txn_id, p_txn_context.inventory_item_id)
    LOOP

      inst_ind := inst_ind + 1;
      l_inst_tbl(inst_ind).instance_id        := all_inst_rec.instance_id;
      l_inst_tbl(inst_ind).csi_txn_id         := p_csi_txn_rec.transaction_id;
      l_inst_tbl(inst_ind).csi_txn_type_id    := p_csi_txn_rec.transaction_type_id;
      l_inst_tbl(inst_ind).csi_txn_date       := p_csi_txn_rec.transaction_date;
      l_inst_tbl(inst_ind).mtl_txn_id         := p_csi_txn_rec.inv_material_transaction_id;
      l_inst_tbl(inst_ind).mtl_txn_date       := p_txn_context.mtl_txn_date;
      l_inst_tbl(inst_ind).mtl_txn_qty        := p_txn_context.primary_quantity;
      l_inst_tbl(inst_ind).quantity           := p_txn_context.primary_quantity;
      l_inst_tbl(inst_ind).inventory_item_id  := p_txn_context.inventory_item_id;
      l_inst_tbl(inst_ind).organization_id    := p_txn_context.organization_id;
      l_inst_tbl(inst_ind).primary_uom_code   := p_txn_context.primary_uom_code;
      l_inst_tbl(inst_ind).serial_number      := all_inst_rec.serial_number;
      l_inst_tbl(inst_ind).lot_number         := all_inst_rec.lot_number;
      l_inst_tbl(inst_ind).location_type_code := all_inst_rec.old_location_type_code;
      l_inst_tbl(inst_ind).location_id        := all_inst_rec.old_location_id;
      l_inst_tbl(inst_ind).depreciable_flag   := p_txn_context.depreciable_flag;
      l_inst_tbl(inst_ind).item               := p_txn_context.item;
      l_inst_tbl(inst_ind).item_description   := p_txn_context.item_description;

--bug#6354065
        debug('Inside get_instance_info Instance Id ' || to_char(all_inst_rec.instance_id) );
     If NOT(l_cia_found) THEN
      FOR cia_rec IN cia_cur (all_inst_rec.instance_id)
      LOOP
        l_cia_found := TRUE;
        debug('Inside get_instance_info CIA Found Instance Id ' || to_char(all_inst_rec.instance_id) );
      END LOOP;
     END IF ;

    END LOOP;

    IF NOT(l_cia_found) THEN
      IF p_txn_context.depreciable_flag = 'N' THEN
        px_action := 'COMPLETE';
      ELSE
        null;
      END IF;
    END IF;

    IF px_action not in ('COMPLETE', 'NONE') THEN
      IF l_inst_tbl.count > 0 THEN
        FOR l_ind IN l_inst_tbl.first .. l_inst_tbl.last
        LOOP
          FOR pend_txn_rec IN pend_txn_cur(
            p_instance_id => l_inst_tbl(l_ind).instance_id,
            p_csi_txn_id  => p_txn_context.csi_txn_id,
            p_inv_item_id => p_txn_context.inventory_item_id)
          LOOP
            px_action := 'NONE';
            debug('there are earlier pending csi transaction for this item instance. skipping.');
            exit;
          END LOOP;
          IF px_action = 'NONE' THEN
            exit;
          END IF;
        END LOOP;

        IF px_action <> 'NONE' THEN
          --check for pending transactions to be interfaced to FA
          FOR l_ind IN l_inst_tbl.first .. l_inst_tbl.last
          LOOP
            FOR pending_rec IN cia_pending_in_fma(l_inst_tbl(l_ind).instance_id)
            LOOP
              px_action := 'NONE';
              debug('unprocessed fa mass additions record found. skipping.');
              exit;
            END LOOP;
            IF px_action = 'NONE' THEN
              exit;
            END IF;
          END LOOP;
        END IF;

      END IF;
    END IF;

    x_instance_tbl := l_inst_tbl;

  END get_instance_info;

  PROCEDURE log_error(
    p_txn_context   IN txn_context,
    p_error_message IN varchar2)
  IS
    l_error_rec          csi_datastructures_pub.transaction_error_rec;
    l_error_id           number;
    l_source_type        varchar2(20);
    l_error_message      varchar2(2000);

    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count          number;
    l_msg_data           varchar2(2000);

  BEGIN

    l_error_message := rtrim(p_error_message);

    IF l_error_message IS NULL  THEN
      l_error_message := cse_util_pkg.dump_error_stack;
      IF l_error_message IS NULL THEN
        l_error_message := substr(sqlerrm, 1, 240);
      END IF;
    END IF;

    -- not making it as 'E' because the it clashes with the CSI Error Logic
    l_error_rec.processed_flag              := 'A';
    l_error_rec.source_type                 := 'CSEFAMOV';
    l_error_rec.source_id                   := p_txn_context.csi_txn_id;
    l_error_rec.transaction_id              := p_txn_context.csi_txn_id;
    l_error_rec.transaction_type_id         := 123;
    l_error_rec.error_text                  := l_error_message;
    l_error_rec.inventory_item_id           := p_txn_context.inventory_item_id;
    l_error_rec.inv_material_transaction_id := p_txn_context.mtl_txn_id;
    l_error_rec.transaction_error_date      := sysdate;

    BEGIN

      SELECT transaction_error_id
      INTO   l_error_id
      FROM   csi_txn_errors
      WHERE  source_type = 'CSEFAMOV'
      AND    source_id   = l_error_rec.source_id
      AND    rownum      < 2;

      UPDATE csi_txn_errors
      SET    error_text           = l_error_rec.error_text,
             last_updated_by      = fnd_global.user_id,
             last_update_login    = fnd_global.login_id,
             last_update_date     = sysdate
      WHERE  transaction_error_id = l_error_id;

      debug('  error updated. transaction_error_id : '||l_error_id);

    EXCEPTION
      WHEN no_data_found THEN

        csi_transactions_pvt.create_txn_error (
          p_api_version          => 1.0,
          p_init_msg_list        => fnd_api.g_true,
          p_commit               => fnd_api.g_false,
          p_validation_level     => fnd_api.g_valid_level_full,
          p_txn_error_rec        => l_error_rec,
          x_transaction_error_id => l_error_id,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        debug('  new error logged. transaction_error_id : '||l_error_id);
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      NULL;
      -- i mean if you can't log the error then what else will you do.
      -- just leave the transaction as pending so that atleast the next run
      -- will pick it yp
  END log_error;


  PROCEDURE process_move_transactions (
    x_retcode             OUT NOCOPY  VARCHAR2,
    x_errbuf              OUT NOCOPY  VARCHAR2,
    p_inventory_item_id   IN  NUMBER)
  IS

    -- transactions that can possibly change IB location or affect quantity on an item instance
    CURSOR csi_pending_txn_cur (c_inventory_item_id IN NUMBER) IS
      SELECT ct.*
      FROM   csi_transactions ct
      WHERE  ct.transaction_type_id IN (
               1,   -- IB_UI
               3,   -- MASS_EDIT
               5,   -- EXPIRE_STATUS
               6,   -- OPEN_INTERFACE
               51,  -- OM_SHIPMENT
               53,  -- RMA_RECEIPT
               55,  -- FIELD_SERVICE_REPORT
               71,  -- WIP_ISSUE
               72,  -- WIP_RECEIPT
               73,  -- WIP_ASSY_COMPLETION
               74,  -- WIP_ASSY_RETURN
               75,  -- WIP_BYPRODUCT_COMPLETION
               76,  -- WIP_BYPRODUCT_RETURN
               91,  -- EAM_ASSET_CREATION
               105, -- PO_RECEIPT_INTO_PROJECT
               106, -- PROJECT_ITEM_INSTALLED
               107, -- PROJECT_ITEM_UNINSTALLED
               108, -- PROJECT_ITEM_IN_SERVICE
               109, -- IN_SERVICE
               110, -- OUT_OF_SERVICE
               111, -- ITEM_MOVE
               112, -- PO_RECEIPT_INTO_INVENTORY
               113, -- MOVE_ORDER_ISSUE_TO_PROJECT
               114, -- SUBINVENTORY_TRANSFER
               115, -- INTERORG_TRANSFER
               116, -- MISC_ISSUE
               117, -- MISC_RECEIPT
               118, -- PHYSICAL_INVENTORY
               119, -- CYCLE_COUNT
               120, -- MISC_RECEIPT_FROM_PROJECT
               121, -- MISC_ISSUE_TO_PROJECT
               122, -- INTERNAL_SALES_ORDER
               124, -- ACCT_ISSUE
               125, -- ACCT_ALIAS_ISSUE
               126, -- ISO_ISSUE
               127, -- RETURN_TO_VENDOR
               128, -- ACCT_RECEIPT
               129, -- ACCT_ALIAS_RECEIPT
               130, -- ISO_SHIPMENT
               131, -- ISO_REQUISITION_RECEIPT
               132, -- ISSUE_TO_HZ_LOC
               133, -- MISC_ISSUE_HZ_LOC
               134, -- MISC_RECEIPT_HZ_LOC
               135, -- ISO_ISSUE
               136, -- MOVE_ORDER_ISSUE
               137, -- MOVE_ORDER_TRANSFER
               138, -- ISO_TRANSFER
               139, -- CYCLE_COUNT_TRANSFER
               140, -- PHYSICAL_INV_TRANSFER
               141, -- BACKFLUSH_TRANSFER
               142, -- ISO_DIRECT_SHIP
               143, -- INTERORG_DIRECT_SHIP
               144, -- INTERORG_TRANS_RECEIPT
               145, -- INTERORG_TRANS_SHIPMENT
               146, -- SALES_ORDER_PICK
               147, -- ISO_PICK
               148, -- PO_RCPT_ADJUSTMENT
               149, -- INT_REQ_RCPT_ADJUSTMENT
               150, -- SHIPMENT_RCPT_ADJUSTMENT
               151, -- PROJECT_BORROW
               152, -- PROJECT_TRANSFER
               153, -- PROJECT_PAYBACK
               326) -- PROJECT_CONTRACT_SHIPMENT
      AND    ct.transaction_status_code = 'PENDING'
      AND    EXISTS (
       SELECT 1
       FROM   csi_item_instances_h ciih,
              csi_item_instances cii
       WHERE  ciih.transaction_id   = ct.transaction_id
       AND    cii.instance_id       = ciih.instance_id
       AND    cii.inventory_item_id = nvl(p_inventory_item_id, cii.inventory_item_id))
      ORDER BY ct.creation_date;

    l_txn_action              varchar2(20);
    l_return_status           varchar2(1);
    l_error_message           varchar2(2000);

    l_csi_txn_rec             csi_datastructures_pub.transaction_rec ;

    ---For Public API's
    l_api_name                varchar2(100);
    l_api_version             number;
    l_commit                  varchar2(1);
    l_init_msg_list           varchar2(1);
    l_validation_level        number;
    l_sysdate                 date;

    skip_txn                  exception;

    l_instance_tbl            instance_tbl;
    l_txn_context             txn_context;

    l_src_inst_srl_code       varchar2(25); --holds 'SERIAL' or 'NON-SERIAL'
    l_dest_inst_srl_code      varchar2(25); --holds 'SERIAL' or 'NON-SERIAL'
    l_src_move_trans_tbl      move_trans_tbl ;
    l_dest_move_trans_tbl     move_trans_tbl ;
    l_move_processed_flag     varchar2(1);

    l_total_pending_txns      number := 0;
    l_total_success_txns      number := 0;
    l_total_failure_txns      number := 0;
    l_total_skipped_txns      number := 0;

    l_success_txn_tbl         txn_id_tbl;
    l_failure_txn_tbl         txn_id_tbl;


  BEGIN

    cse_util_pkg.set_debug;

    debug('Inside process_move_transaction - '||to_char(sysdate, 'dd-mon-yyy hh24:mi:ss'));

    debug('  param.inv_item_id      : '||p_inventory_item_id);

    l_api_name                    :='cse_asset_move_pkg.process_move_transactions';
    l_api_version                 := 1.0;
    l_commit                      := fnd_api.g_false;
    l_init_msg_list               := fnd_api.g_true;
    l_validation_level            := fnd_api.g_valid_level_full;
    l_sysdate                     := sysdate ;

    FOR pending_rec IN csi_pending_txn_cur (p_inventory_item_id)
    LOOP

      debug('====================* BEGIN MOVE TRANSACTION *====================');
      debug('Transaction record # '||csi_pending_txn_cur%rowcount);
      debug('  transaction_id         : '||pending_rec.transaction_id);
      debug('  transaction_date       : '||pending_rec.transaction_date);
      debug('  transaction_type_id    : '||pending_rec.transaction_type_id);
      debug('  mtl_transaction_id     : '||pending_rec.inv_material_transaction_id);

      BEGIN

        savepoint process_move ;

        identify_txn_action(
          p_inventory_item_id => p_inventory_item_id,
          p_csi_txn_rec       => pending_rec,
          x_txn_context       => l_txn_context,
          x_action            => l_txn_action);

        debug('  eib_transaction_action : '||l_txn_action);

        IF l_txn_action = 'NONE' THEN
          RAISE skip_txn;
        ELSE
          null;
          IF l_txn_action <> 'COMPLETE' THEN
            -- this routine figures out if this transaction should be marked for completion
            get_instance_info(
              p_csi_txn_rec         => pending_rec,
              p_txn_context         => l_txn_context,
              px_action             => l_txn_action,
              x_instance_tbl        => l_instance_tbl,
              x_return_status       => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END IF;

        IF l_txn_action = 'NONE' THEN
          RAISE skip_txn;
        END IF;

        IF l_txn_action = 'COMPLETE' THEN
          -- simply update the transaction record status to complete
          complete_csi_txn(
            p_csi_txn_id          => pending_rec.transaction_id,
            x_return_status       => l_return_status,
            x_error_message       => l_error_message);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF l_txn_action = 'MOVE' THEN

          process_a_move_txn (
            p_transaction_id        => pending_rec.transaction_id,
            p_conc_request_id       => fnd_global.conc_request_id,
            x_src_move_trans_tbl    => l_src_move_trans_tbl,
            x_dest_move_trans_tbl   => l_dest_move_trans_tbl,
            x_move_processed_flag   => l_move_processed_flag,
            x_return_status         => l_return_status,
            x_error_msg             => l_error_message) ;

        END IF;

        IF l_txn_action = 'MISC-MOVE' THEN
          process_misc_moves(
            x_return_status         => l_return_status,
            x_error_msg             => l_error_message,
            p_inventory_item_id     => p_inventory_item_id,
            p_conc_request_id       => fnd_global.conc_request_id,
            p_transaction_id        => pending_rec.transaction_id) ;
        END IF;

        IF l_txn_action = 'ADJUST' THEN

          process_adjustment_trans(
            p_transaction_id   => pending_rec.transaction_id,
            p_conc_request_id  => fnd_global.conc_request_id,
            x_return_status    => l_return_status,
            x_error_msg        => l_error_message ) ;

        END IF;

        IF l_txn_action ='INTER-ORG-MOVE' THEN

          get_src_dest_inst_srl_code (
            p_mtl_transaction_id    => pending_rec.inv_material_transaction_id,
            x_src_inst_srl_code     => l_src_inst_srl_code,
            x_dest_inst_srl_code    => l_dest_inst_srl_code,
            x_return_status         => l_return_status,
            x_error_msg             => l_error_message) ;

          IF NVL(l_src_inst_srl_code,'~#$') <> NVL(l_dest_inst_srl_code,'~#$') THEN
            process_srl_nosrl_xorg_txn(
              p_transaction_id      => pending_rec.transaction_id,
              p_transaction_type_id => pending_rec.transaction_type_id,
              p_material_transaction_id => pending_rec.inv_material_transaction_id,
              p_conc_request_id     => fnd_global.conc_request_id,
              x_return_status       => l_return_status,
              x_error_msg           => l_error_message) ;
          ELSE

            process_a_move_txn (
              p_transaction_id        => pending_rec.transaction_id,
              p_conc_request_id       => fnd_global.conc_request_id,
              x_src_move_trans_tbl    => l_src_move_trans_tbl,
              x_dest_move_trans_tbl   => l_dest_move_trans_tbl,
              x_move_processed_flag   => l_move_processed_flag,
              x_return_status         => l_return_status,
              x_error_msg             => l_error_message) ;

          END IF;

        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_txn_action = 'COMPLETE' THEN
          l_total_skipped_txns := l_total_skipped_txns + 1;
        ELSE
          l_total_success_txns := l_total_success_txns + 1;
          l_success_txn_tbl(l_total_success_txns).txn_id     := pending_rec.transaction_id;
          l_success_txn_tbl(l_total_success_txns).txn_action := l_txn_action;
        END IF;

      EXCEPTION
        WHEN skip_txn THEN

          l_total_skipped_txns := l_total_skipped_txns + 1;

        WHEN fnd_api.g_exc_error THEN

          l_total_failure_txns := l_total_failure_txns + 1;
          l_failure_txn_tbl(l_total_failure_txns).txn_id     := pending_rec.transaction_id;
          l_failure_txn_tbl(l_total_failure_txns).txn_action := l_txn_action;
          l_failure_txn_tbl(l_total_failure_txns).txn_error  := l_error_message;

          rollback to process_move ;
          log_error(
            p_txn_context   => l_txn_context,
            p_error_message => l_error_message);
      END ;
      debug('=======================* END MOVE TRANSACTION *====================');
    END LOOP;

    report_output(
      p_success_txn_tbl => l_success_txn_tbl,
      p_failure_txn_tbl => l_failure_txn_tbl);
  END process_move_transactions ;
END cse_asset_move_pkg;

/
