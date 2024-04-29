--------------------------------------------------------
--  DDL for Package Body CSE_ASSET_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_ASSET_CREATION_PKG" AS
/* $Header: CSEIFACB.pls 120.30.12010000.8 2010/06/25 12:22:10 dsingire ship $  */

  l_debug      varchar2(1) := NVL(fnd_profile.value('cse_debug_option'),'N');
  l_asset_for_exp_item_flag VARCHAR2(1) := NVL(fnd_profile.value('CSE_ASSETS_FOR_EXPENSE_ITEMS'),'Y'); --Added For bug 9488846
  l_asset_for_exp_subinv_flag VARCHAR2(1) := NVL(fnd_profile.value('CSE_ASSETS_FOR_EXPENSE_SUBINV'),'N'); --Added For bug 9488846

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

  FUNCTION fill(
    p_column in varchar2,
    p_width  in number,
    p_side   in varchar2 default 'R')
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

  PROCEDURE out(
    p_message       in varchar2)
  IS
  BEGIN
    IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
      fnd_file.put_line(fnd_file.output, p_message);
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END out;

  PROCEDURE asset_creation_report(
    p_txn_status_tbl          IN txn_status_tbl)
  IS

    l_total_count    number;
    l_error_count    number;
    l_success_count  number;

    FUNCTION valid_txn_count(
      p_ts_tbl IN txn_status_tbl) RETURN NUMBER
    IS
      l_count number := 0;
    BEGIN
      FOR l_ind IN p_ts_tbl.FIRST .. p_ts_tbl.LAST
      LOOP
        IF p_ts_tbl(l_ind).valid_txn_flag = 'Y' THEN
          l_count := l_count + 1;
        END IF;
      END LOOP;
      RETURN l_count;
    END valid_txn_count;

    FUNCTION error_txn_count(
      p_ts_tbl IN txn_status_tbl) RETURN NUMBER
    IS
      l_count number := 0;
    BEGIN
      FOR l_ind IN p_ts_tbl.FIRST .. p_ts_tbl.LAST
      LOOP
        IF p_ts_tbl(l_ind).valid_txn_flag = 'Y' AND p_ts_tbl(l_ind).processed_flag = 'E' THEN
          l_count := l_count + 1;
        END IF;
      END LOOP;
      RETURN l_count;
    END error_txn_count;

  BEGIN
    IF p_txn_status_tbl.COUNT > 0 THEN

      l_total_count := valid_txn_count(p_txn_status_tbl);
      l_error_count := error_txn_count(p_txn_status_tbl);

      l_success_count := l_total_count - l_error_count;
      out(' ');
      out('Transactions :-' );
      out('       Total : '||l_total_count);
      out('   Processed : '||l_success_count);
      out('      Failed : '||l_error_count);

      IF l_error_count > 0 THEN
        out(' ');
        out(fill('csi_transaction_id', 20)||
            fill('error_text', 80));
        out(fill('------------------', 20)||
            fill('----------', 80));
        FOR l_ind IN p_txn_status_tbl.FIRST .. p_txn_status_tbl.LAST
        LOOP
          IF  p_txn_status_tbl(l_ind).processed_flag = 'E' THEN
            out(fill(p_txn_status_tbl(l_ind).csi_txn_id, 20)||
                fill(p_txn_status_tbl(l_ind).error_message, 80));
          END IF;
        END LOOP;
      END IF;

    END IF;
  END asset_creation_report;

  PROCEDURE dump_inst_tbl(
    p_inst_tbl  IN instance_tbl)
  IS
  BEGIN
    IF p_inst_tbl.count > 0 THEN
      FOR l_ind IN p_inst_tbl.first .. p_inst_tbl.last
      LOOP

        debug('instance info :- record # '||l_ind);

        debug('  instance_id            : '||p_inst_tbl(l_ind).instance_id);
        debug('  subinventory_code      : '||p_inst_tbl(l_ind).subinventory_code);
        debug('  primary_uom_code       : '||p_inst_tbl(l_ind).primary_uom_code);
        debug('  serial_number          : '||p_inst_tbl(l_ind).serial_number);
        debug('  lot_number             : '||p_inst_tbl(l_ind).lot_number);
        debug('  pa_project_id          : '||p_inst_tbl(l_ind).pa_project_id);
        debug('  pa_project_task_id     : '||p_inst_tbl(l_ind).pa_project_task_id);
        debug('  rcv_txn_id             : '||p_inst_tbl(l_ind).rcv_txn_id);
        debug('  po_distribution_id     : '||p_inst_tbl(l_ind).po_distribution_id);
        debug('  location_type_code     : '||p_inst_tbl(l_ind).location_type_code);
        debug('  location_id            : '||p_inst_tbl(l_ind).location_id);
        debug('  mtl_dist_acct_id       : '||p_inst_tbl(l_ind).mtl_dist_acct_id);
        debug('  redeploy_flag          : '||p_inst_tbl(l_ind).redeploy_flag);
        debug('  asset_description      : '||p_inst_tbl(l_ind).asset_description);
        debug('  asset_units            : '||p_inst_tbl(l_ind).quantity);
        debug('  asset_unit_cost        : '||p_inst_tbl(l_ind).asset_unit_cost);
        debug('  asset_cost             : '||p_inst_tbl(l_ind).asset_cost);
        debug('  asset_category_id      : '||p_inst_tbl(l_ind).asset_category_id);
        debug('  book_type_code         : '||p_inst_tbl(l_ind).book_type_code);
        debug('  date_placed_in_service : '||p_inst_tbl(l_ind).date_placed_in_service);
        debug('  asset_location_id      : '||p_inst_tbl(l_ind).asset_location_id);
        debug('  asset_key_ccid         : '||p_inst_tbl(l_ind).asset_key_ccid);
        debug('  deprn_expense_ccid     : '||p_inst_tbl(l_ind).deprn_expense_ccid);
        debug('  payables_ccid          : '||p_inst_tbl(l_ind).payables_ccid);
        debug('  tag_number             : '||p_inst_tbl(l_ind).tag_number);
        debug('  model_number           : '||p_inst_tbl(l_ind).tag_number);
        debug('  manufacturer_name      : '||p_inst_tbl(l_ind).manufacturer_name);
        debug('  employee_id            : '||p_inst_tbl(l_ind).employee_id);
        debug('  search_method          : '||p_inst_tbl(l_ind).search_method);

      END LOOP;
    END IF;
  END dump_inst_tbl;

  PROCEDURE log_error(
    p_instance_rec  IN instance_rec,
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
    l_error_rec.source_type                 := 'CSEFATIE';
    l_error_rec.source_id                   := p_instance_rec.csi_txn_id;
    l_error_rec.transaction_id              := p_instance_rec.csi_txn_id;
    l_error_rec.transaction_type_id         := 123;
    l_error_rec.error_text                  := l_error_message;
    l_error_rec.inventory_item_id           := p_instance_rec.inventory_item_id;
    l_error_rec.serial_number               := p_instance_rec.serial_number;
    l_error_rec.lot_number                  := p_instance_rec.lot_number;
    l_error_rec.inv_material_transaction_id := p_instance_rec.mtl_txn_id;
    l_error_rec.transaction_error_date      := sysdate;
    l_error_rec.instance_id                 := p_instance_rec.instance_id;

    BEGIN

      SELECT transaction_error_id
      INTO   l_error_id
      FROM   csi_txn_errors
      WHERE  source_type = 'CSEFATIE'
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

  PROCEDURE get_redeploy_flag(
    p_instance_id      IN  number,
    p_transaction_date IN  date,
    x_redeploy_flag    OUT nocopy varchar2)
  IS
    l_redeploy_flag varchar2(1) := 'N';

    CURSOR all_txn_cur(
      p_serial_number  in varchar2,
      p_item_id        in number,
      p_mtl_txn_id     in number)
    IS
      SELECT mmt.creation_date               mtl_creation_date,
             mmt.transaction_id              mtl_txn_id,
             mmt.transaction_action_id       mtl_action_id,
             mmt.transaction_source_type_id  mtl_src_type_id,
             mmt.ship_to_location_id         location_id
      FROM   mtl_unit_transactions     mut,
             mtl_material_transactions mmt
      WHERE  mut.serial_number       = p_serial_number
      AND    mut.inventory_item_id   = p_item_id
      AND    mmt.transaction_id      = mut.transaction_id
      AND    mmt.transaction_id      < p_mtl_txn_id
      UNION
      SELECT mmt.creation_date               mtl_creation_date,
             mmt.transaction_id              mtl_txn_id,
             mmt.transaction_action_id       mtl_action_id,
             mmt.transaction_source_type_id  mtl_src_type_id,
             mmt.ship_to_location_id         location_id
      FROM   mtl_unit_transactions       mut,
             mtl_transaction_lot_numbers mtln,
             mtl_material_transactions   mmt
      WHERE  mut.serial_number          = p_serial_number
      AND    mut.inventory_item_id      = p_item_id
      AND    mtln.organization_id       = mut.organization_id
      AND    mtln.transaction_date      = mut.transaction_date
      AND    mtln.serial_transaction_id = mut.transaction_id
      AND    mmt.transaction_id         = mtln.transaction_id
      AND    mmt.transaction_id         < p_mtl_txn_id
      ORDER BY 1 desc, 2 desc;


    CURSOR deploy_cur IS
      SELECT 'Y'
      FROM   csi_transactions ct,
             csi_item_instances_h ciih
      WHERE  ciih.instance_id    = p_instance_id
      AND    ct.transaction_id   = ciih.transaction_id
      AND    ct.transaction_date < p_transaction_date
      AND    ct.transaction_type_id in (110, 108, 132, 133);

    /* -- redeploy transactions
       -------------------------------
       110 - out of service
       108 - project item in service
       132 - issue to hz location
       133 - misc issue to hz location
       -------------------------------
    */

  BEGIN
    FOR deploy_rec IN deploy_cur
    LOOP
      l_redeploy_flag := 'Y';
      exit;
    END LOOP;
    x_redeploy_flag := l_redeploy_flag;
  END get_redeploy_flag;

  FUNCTION transaction_pending(
    p_csi_txn_id         IN  number,
    p_instance_id        IN  number)
  RETURN boolean
  IS
    CURSOR txn_cur IS
      SELECT ct.transaction_id
      FROM   csi_transactions ct,
             csi_item_instances_h ciih
      WHERE  ciih.instance_id  = p_instance_id
      AND    ct.transaction_id = ciih.transaction_id
      AND    ct.transaction_id < p_csi_txn_id
      AND    ct.transaction_status_code = 'PENDING';
  BEGIN
    FOR txn_rec IN txn_cur
    LOOP
      RETURN TRUE;
    END LOOP;
    RETURN FALSE;
  END transaction_pending;

  PROCEDURE get_base_amount (
    p_po_distribution_id IN  number,
    p_current_cost       IN  number,
    p_book_type_code     IN  varchar2,
    x_base_amount        OUT nocopy number,
    x_return_status      OUT nocopy varchar2,
    x_error_msg          OUT nocopy varchar2)
  IS
    CURSOR po_sob_currency_cur IS
      SELECT poh.rate_type,
             poh.currency_code,
             pod.rate,
             poh.rate_date,
             sob.currency_code,
             pod.set_of_books_id
      FROM   po_distributions_all pod,
             po_headers_all       poh,
             gl_sets_of_books     sob
      WHERE  pod.po_distribution_id = p_po_distribution_id
      AND    poh.po_header_id       = pod.po_header_id
      AND    sob.set_of_books_id    = pod.set_of_books_id ;

    CURSOR base_currency_cur IS
      SELECT gsob.currency_code
      FROM   gl_sets_of_books gsob,
             fa_book_controls fbc
      WHERE fbc.book_type_code   = p_book_type_code
      AND   gsob.set_of_books_id = fbc.set_of_books_id ;

    l_rate_type             varchar2(30);
    l_po_currency_code      varchar2(15);
    l_po_to_basecur_rate    number;
    l_fa_currency_code      varchar2(15);
    l_po_sob_currency_code  varchar2(15);
    l_po_sob_id             number;
    l_base_amount           number;
    l_rate_date             date;

    PROCEDURE round_currency (
      p_amount          IN  number,
      p_currency_code   IN  varchar2,
      x_rounded_amount  OUT nocopy number)
    IS
      CURSOR round_currency_cur IS
        SELECT decode(fc.minimum_accountable_unit,
                       NULL, ROUND(p_amount, FC.precision),
                       ROUND(p_amount/FC.minimum_accountable_unit) * FC.minimum_accountable_unit)
        FROM  fnd_currencies fc
        WHERE fc.currency_code = p_currency_code;
    BEGIN
      OPEN  round_currency_cur;
      FETCH round_currency_cur INTO x_rounded_amount ;
      CLOSE round_currency_cur;
    END round_currency;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success ;

    OPEN  base_currency_cur ;
    FETCH base_currency_cur INTO l_fa_currency_code ;
    CLOSE base_currency_cur ;

    OPEN po_sob_currency_cur ;
    FETCH po_sob_currency_cur
    INTO  l_rate_type,
          l_po_currency_code,
          l_po_to_basecur_rate,
          l_rate_date,
          l_po_sob_currency_code,
          l_po_sob_id;

    IF (po_sob_currency_cur%NOTFOUND  OR l_rate_type is NULL) THEN
      IF l_fa_currency_code = l_po_sob_currency_code THEN
        debug('p_current_cost : '||p_current_cost);

        l_base_amount := p_current_cost ;
      ELSE
        -- Convert amount from PO Reporting currency to FA Reporting Currency
        l_base_amount := GL_Currency_API.Convert_Amount(
                 l_po_sob_currency_code,
                 l_fa_currency_code,
                 l_rate_date,
                 l_rate_type,
                 p_current_cost);
      END IF;
    END IF;

    IF l_rate_type IS NOT NULL THEN
      IF l_rate_type <> 'User' THEN
        l_base_amount := GL_Currency_API.Convert_Amount(
                 l_po_currency_code,
                 l_fa_currency_code,
                 l_rate_date,
                 l_rate_type,
                 p_current_cost);
      ELSIF l_rate_type = 'User' THEN
        IF l_fa_currency_code = l_po_sob_currency_code THEN
          round_currency ( p_current_cost * l_po_to_basecur_rate, l_fa_currency_code, x_base_amount);
        ELSE
          round_currency( p_current_cost * l_po_to_basecur_rate, l_po_sob_currency_code, x_base_amount);

          l_base_amount := GL_Currency_API.Convert_Amount(
                 l_po_sob_currency_code,
                 l_fa_currency_code,
                 l_rate_date,
                 l_rate_type,
                 x_base_amount);
        END IF ; --l_fa_currency_code = l_po_sob_currency_code
      END IF ; --l_rate_type <> 'USer'
    END IF ; --l_rate_type is NOT NULL

    CLOSE po_sob_currency_cur ;

    IF l_base_amount IS NULL THEN
      x_error_msg     := 'Unable to derive base amount for PO receit transaction';
      RAISE fnd_api.g_exc_error;
    END IF ;

    x_base_amount := l_base_amount;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
  END get_base_amount ;

  PROCEDURE get_fa_location_id(
    p_location_type_code  IN  varchar2,
    p_location_id         IN  number,
    x_fa_location_id      OUT nocopy number,
    x_return_status       OUT nocopy varchar2)
  IS

    l_location_table      varchar2(30);
    l_hz_or_hr            varchar2(1);

    CURSOR loc_map_cur(p_location_table IN varchar2) IS
      SELECT fa_location_id
      FROM   csi_a_locations
      WHERE  location_table in ('LOCATION_CODES', p_location_table)
      AND    location_id    = p_location_id
      AND    sysdate BETWEEN nvl(active_start_date, sysdate - 1)
                     AND     nvl(active_end_date, sysdate + 1);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_location_type_code = 'INVENTORY' THEN
      l_location_table := 'HR_LOCATIONS';
    ELSIF p_location_type_code = 'HZ_LOCATIONS' THEN
      BEGIN
        SELECT 'Y' INTO l_hz_or_hr
        FROM   hz_locations
        WHERE  location_id = p_location_id;
        l_location_table := 'HZ_LOCATIONS';
      EXCEPTION
        WHEN no_data_found THEN
          l_location_table := 'HR_LOCATIONS';
      END;
    ELSE
      l_location_table := 'LOCATION_CODES';
    END IF;

    FOR loc_rec IN loc_map_cur(l_location_table)
    LOOP
      x_fa_location_id := loc_rec.fa_location_id;
      exit;
    END LOOP;

    IF x_fa_location_id is null then
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_fa_location_id;

  PROCEDURE derive_asset_attribs(
    px_instance_tbl   IN OUT nocopy instance_tbl,
    x_return_status      OUT nocopy varchar2,
    x_error_message      OUT nocopy varchar2)
  IS

    l_asset_attrib_rec       cse_datastructures_pub.asset_attrib_rec;

    l_asset_description      varchar2(80);
    l_inst_tbl               instance_tbl;
    l_asset_cost             number;
    l_asset_unit_cost        number;
    l_base_amount            number;
    l_source_type            varchar2(3);
    l_source_txn_id          number;
    l_asset_category         varchar2(240);
    l_asset_category_id      number;
    l_default_group_asset_id number;
    l_book_type_code         varchar2(30);
    l_dpi                    date;
    l_asset_key_ccid         number;
    l_fa_location_id         number;
    l_deprn_expense_ccid     number;
    l_payables_ccid          number;
    l_tag_number             varchar2(15);
    l_model_number           varchar2(40);
    l_manufacturer_name      varchar2(30);
    l_employee_id            number;
    l_search_method          varchar2(10);

    l_hook_used              varchar2(1);
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message          varchar2(2000);

  BEGIN

    debug('inside derive_asset_attribs');

    x_return_status := fnd_api.g_ret_sts_success;

    l_inst_tbl := px_instance_tbl;

    IF l_inst_tbl.COUNT > 0 THEN
      FOR l_ind IN l_inst_tbl.FIRST .. l_inst_tbl.LAST
      LOOP

        IF l_inst_tbl(l_ind).csi_txn_type_id in (105, 112) THEN
          l_source_type := 'PO';
        ELSE
          l_source_type := 'INV';
        END IF;

        SELECT source_transaction_type
        INTO   l_asset_attrib_rec.source_transaction_type
        FROM   csi_txn_types
        WHERE  transaction_type_id =  l_inst_tbl(l_ind).csi_txn_type_id;

        l_asset_attrib_rec.instance_id                 := l_inst_tbl(l_ind).instance_id;
        l_asset_attrib_rec.inventory_item_id           := l_inst_tbl(l_ind).inventory_item_id;
        l_asset_attrib_rec.serial_number               := l_inst_tbl(l_ind).serial_number;
        l_asset_attrib_rec.organization_id             := l_inst_tbl(l_ind).organization_id;
        l_asset_attrib_rec.inv_master_organization_id  := l_inst_tbl(l_ind).organization_id;
        l_asset_attrib_rec.subinventory_name           := l_inst_tbl(l_ind).subinventory_code;
        l_asset_attrib_rec.transaction_quantity        := l_inst_tbl(l_ind).quantity;
        l_asset_attrib_rec.transaction_id              := l_inst_tbl(l_ind).csi_txn_id;
        l_asset_attrib_rec.transaction_date            := l_inst_tbl(l_ind).csi_txn_date;
        l_asset_attrib_rec.depreciable_flag            := l_inst_tbl(l_ind).depreciable_flag;
        l_asset_attrib_rec.transaction_type_id         := l_inst_tbl(l_ind).csi_txn_type_id;
        l_asset_attrib_rec.rcv_transaction_id          := l_inst_tbl(l_ind).rcv_txn_id;
        l_asset_attrib_rec.po_distribution_id          := l_inst_tbl(l_ind).po_distribution_id;
        l_asset_attrib_rec.inv_material_transaction_id := l_inst_tbl(l_ind).mtl_txn_id;
        l_asset_attrib_rec.location_type_code          := l_inst_tbl(l_ind).location_type_code;
        l_asset_attrib_rec.location_id                 := l_inst_tbl(l_ind).location_id;
        l_asset_attrib_rec.source_transaction_type     := l_inst_tbl(l_ind).source_txn_type;

        IF l_ind = 1 THEN

          -- asset description
          l_asset_description := cse_asset_util_pkg.asset_description(
                                   p_asset_attrib_rec  => l_asset_attrib_rec,
                                   x_error_msg         => l_error_message,
                                   x_return_status     => l_return_status);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- asset unit cost
          cse_asset_util_pkg.get_unit_cost(
            p_source_txn_type   => l_source_type,
            p_source_txn_id     => l_inst_tbl(l_ind).rcv_txn_id,
            p_inventory_item_id => l_inst_tbl(l_ind).inventory_item_id,
            p_organization_id   => l_inst_tbl(l_ind).organization_id,
            x_unit_cost         => l_asset_unit_cost,
            x_error_msg         => l_error_message,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('  asset_unit_cost : '||l_asset_unit_cost);

          -- asset category
          l_asset_category_id  :=
            cse_asset_util_pkg.asset_category(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_asset_attrib_rec.asset_category_id := l_asset_category_id;

          IF  nvl(l_asset_attrib_rec.asset_category_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

            SELECT concatenated_segments
            INTO   l_asset_category
            FROM   fa_categories_b_kfv
            WHERE  category_id = l_asset_category_id;

            -- book type code
            l_book_type_code :=
              cse_asset_util_pkg.book_type(
                p_asset_attrib_rec => l_asset_attrib_rec,
                x_error_msg        => l_error_message,
                x_return_status    => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            l_asset_attrib_rec.book_type_code := l_book_type_code;

            -- default asset group id
            BEGIN
              SELECT default_group_asset_id
              INTO   l_default_group_asset_id
              FROM   fa_category_books
              WHERE  category_id    = l_asset_category_id
              AND    book_type_code = l_book_type_code;
            EXCEPTION
              WHEN no_data_found THEN
                fnd_message.set_name('CSE', 'CSE_ASSET_BOOK_CAT_UNDEFINED');
                fnd_message.set_token('ASSET_CAT', l_asset_category);
                fnd_message.set_token('BOOK_TYPE_CODE', l_book_type_code);
                l_error_message := fnd_message.get;
                RAISE fnd_api.g_exc_error;
            END;
          ELSE
            fnd_message.set_name('CSE', 'CSE_ASSET_CAT_ERROR');
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- date placed in service
          l_dpi :=
            cse_asset_util_pkg.date_place_in_service(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_asset_key_ccid :=
            cse_asset_util_pkg.asset_key(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- get fa location
          get_fa_location_id(
            p_location_type_code  => l_inst_tbl(l_ind).location_type_code,
            p_location_id         => l_inst_tbl(l_ind).location_id,
            x_fa_location_id      => l_fa_location_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('  location_type_code   : '||l_inst_tbl(l_ind).location_type_code);
            debug('  location_id          : '||l_inst_tbl(l_ind).location_id);
            fnd_message.set_name('CSE','CSE_FA_CREATION_ATRIB_ERROR');
            fnd_message.set_token('ASSET_ATTRIBUTE','LOCATION');
            fnd_message.set_token('CSI_TRANSACTION_ID',l_inst_tbl(l_ind).csi_txn_id);
            l_error_message := fnd_message.get;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- get deprn expense ccid
          l_deprn_expense_ccid :=
            cse_asset_util_pkg.deprn_expense_ccid(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- payables ccid
          l_payables_ccid :=
            cse_asset_util_pkg.payables_ccid(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            --l_payables_ccid := l_inst_tbl(l_ind).mtl_dist_acct_id;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- tag number
          l_tag_number :=
            cse_asset_util_pkg.tag_number(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- model number
          l_model_number :=
            cse_asset_util_pkg.model_number(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- manufacturer
          l_manufacturer_name :=
            cse_asset_util_pkg.manufacturer(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- employee
          l_employee_id :=
            cse_asset_util_pkg.employee(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- search method
          l_search_method :=
            cse_asset_util_pkg.search_method(
              p_asset_attrib_rec => l_asset_attrib_rec,
              x_error_msg        => l_error_message,
              x_return_status    => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF; -- first record only

        l_asset_cost := NVL(l_inst_tbl(l_ind).quantity,0) * NVL(l_asset_unit_cost,0);

        IF l_source_type = 'PO' THEN
          get_base_amount (
            p_po_distribution_id => l_inst_tbl(l_ind).po_distribution_id,
            p_current_cost       => l_asset_cost,
            p_book_type_code     => l_book_type_code,
            x_base_amount        => l_base_amount,
            x_return_status      => l_return_status,
            x_error_msg          => l_error_message);
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
          l_asset_cost := l_base_amount;

          SELECT poh.po_header_id,
                 poh.segment1,
                 poh.vendor_id
          INTO   l_inst_tbl(l_ind).po_header_id,
                 l_inst_tbl(l_ind).po_number,
                 l_inst_tbl(l_ind).po_vendor_id
          FROM   po_headers_all poh,
                 po_distributions_all pod
          WHERE  pod.po_distribution_id = l_inst_tbl(l_ind).po_distribution_id
          AND    poh.po_header_id       = pod.po_header_id;

        END IF;

        l_inst_tbl(l_ind).asset_description      := l_asset_description;
        l_inst_tbl(l_ind).asset_unit_cost        := l_asset_unit_cost;
        l_inst_tbl(l_ind).asset_cost             := l_asset_cost;
        l_inst_tbl(l_ind).asset_category_id      := l_asset_category_id;
        l_inst_tbl(l_ind).group_asset_id         := l_default_group_asset_id;
        l_inst_tbl(l_ind).book_type_code         := l_book_type_code;
        l_inst_tbl(l_ind).date_placed_in_service := l_dpi;
        l_inst_tbl(l_ind).asset_key_ccid         := l_asset_key_ccid;
        l_inst_tbl(l_ind).asset_location_id      := l_fa_location_id;
        l_inst_tbl(l_ind).deprn_expense_ccid     := l_deprn_expense_ccid;
        l_inst_tbl(l_ind).payables_ccid          := l_payables_ccid;
        l_inst_tbl(l_ind).tag_number             := l_tag_number;
        l_inst_tbl(l_ind).model_number           := l_model_number;
        l_inst_tbl(l_ind).manufacturer_name      := l_manufacturer_name;
        l_inst_tbl(l_ind).employee_id            := l_employee_id;
        l_inst_tbl(l_ind).search_method          := l_search_method;

      END LOOP;
    END IF;
    px_instance_tbl := l_inst_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := l_error_message;
  END derive_asset_attribs;

  PROCEDURE get_fixed_assets(
    p_fa_query_rec     IN  fa_query_rec,
    x_fixed_asset_rec  OUT nocopy fixed_asset_rec,
    x_return_status    OUT nocopy varchar2,
    x_error_message    OUT nocopy varchar2)
  IS

    l_stmt             varchar2(2000)
      := 'SELECT fad.asset_id, fad.asset_number, fad.asset_category_id, fad.asset_key_ccid, '||
                 'fad.tag_number, fad.description, fad.manufacturer_name, fad.serial_number, '||
                 'fad.model_number, fad.current_units, fb.book_type_code, '||
                 'fb.date_placed_in_service, fb.cost, cia.instance_asset_id '||
         'FROM  fa_books fb, fa_additions fad, csi_i_assets cia, csi_item_instances cii '||
         'WHERE fb.asset_id  = fad.asset_id '||
         'AND   fb.date_ineffective is null '||
         'AND   cia.fa_asset_id = fad.asset_id '||
         'AND   cii.instance_id = cia.instance_id ';

    l_and_clause     varchar2(540);

    l_cursor_id      number;
    l_rows_returned  number;
    l_ind            binary_integer := 0;
    l_asset_rec      fixed_asset_rec;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_fa_query_rec.book_type_code is not null THEN
      l_and_clause := 'AND fb.book_type_code = :book_type_code ';
    END IF;

    IF p_fa_query_rec.asset_category_id is not null THEN
      l_and_clause := l_and_clause || 'AND fad.asset_category_id = :asset_category_id ';
    END IF;

    IF p_fa_query_rec.date_placed_in_service IS not null THEN
      l_and_clause := l_and_clause || 'AND fb.date_placed_in_service = :dpi ';
    END IF;

    IF p_fa_query_rec.serial_number IS not null THEN
      l_and_clause := l_and_clause || 'AND fad.serial_number = :serial_number ';
    END IF;

    IF p_fa_query_rec.model_number IS not null THEN
      l_and_clause := l_and_clause || 'AND fad.model_number = :model_number ';
    END IF;

    IF p_fa_query_rec.tag_nuber IS not null THEN
      l_and_clause := l_and_clause || 'AND fad.tag_number = :tag_number ';
    END IF;

    IF p_fa_query_rec.manufacturer_name IS not null THEN
      l_and_clause := l_and_clause || 'AND fad.manfacturer_name = :manufacturer_name ';
    END IF;

    IF p_fa_query_rec.asset_key_ccid IS not null THEN
      l_and_clause := l_and_clause || 'AND fad.asset_key_ccid = :asset_key_ccid ';
    END IF;

    IF p_fa_query_rec.inventory_item_id IS not null THEN
      l_and_clause := l_and_clause || 'AND cii.inventory_item_id = :inventory_item_id ';
    END IF;

    IF p_fa_query_rec.search_method = 'FIFO' THEN
      l_and_clause := l_and_clause || 'ORDER BY fb.date_placed_in_service, fad.asset_id';
    ELSIF p_fa_query_rec.search_method = 'LIFO' THEN
      l_and_clause := l_and_clause || 'ORDER BY fb.date_placed_in_service desc, fad.asset_id desc ';
    END IF;

    l_stmt := l_stmt||l_and_clause;

    debug('fa query : '||l_stmt);

    -- open cursor and parse
    l_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor_id, l_stmt , dbms_sql.native);

    -- bind variables
    IF p_fa_query_rec.inventory_item_id is not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':inventory_item_id', p_fa_query_rec.inventory_item_id);
    END IF;

    IF p_fa_query_rec.book_type_code is not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':book_type_code', p_fa_query_rec.book_type_code);
    END IF;

    IF p_fa_query_rec.asset_category_id is not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':asset_category_id', p_fa_query_rec.asset_category_id);
    END IF;

    IF p_fa_query_rec.date_placed_in_service IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':dpi', p_fa_query_rec.date_placed_in_service);
    END IF;

    IF p_fa_query_rec.serial_number IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':serial_number', p_fa_query_rec.serial_number);
    END IF;

    IF p_fa_query_rec.model_number IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':model_number', p_fa_query_rec.model_number);
    END IF;

    IF p_fa_query_rec.tag_nuber IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':tag_nuber', p_fa_query_rec.tag_nuber);
    END IF;

    IF p_fa_query_rec.manufacturer_name IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':manufacturer_name', p_fa_query_rec.manufacturer_name);
    END IF;

    IF p_fa_query_rec.asset_key_ccid IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':asset_key_ccid', p_fa_query_rec.asset_key_ccid);
    END IF;

    dbms_sql.define_column(l_cursor_id, 1, l_asset_rec.asset_id);
    dbms_sql.define_column(l_cursor_id, 2, l_asset_rec.asset_number, 30);
    dbms_sql.define_column(l_cursor_id, 3, l_asset_rec.asset_category_id);
    dbms_sql.define_column(l_cursor_id, 4, l_asset_rec.asset_key_ccid);
    dbms_sql.define_column(l_cursor_id, 5, l_asset_rec.tag_number, 30);
    dbms_sql.define_column(l_cursor_id, 6, l_asset_rec.asset_description, 240);
    dbms_sql.define_column(l_cursor_id, 7, l_asset_rec.manufacturer_name, 30);
    dbms_sql.define_column(l_cursor_id, 8, l_asset_rec.serial_number, 80);
    dbms_sql.define_column(l_cursor_id, 9, l_asset_rec.model_number, 80);
    dbms_sql.define_column(l_cursor_id, 10, l_asset_rec.current_units);
    dbms_sql.define_column(l_cursor_id, 11, l_asset_rec.book_type_code, 30);
    dbms_sql.define_column(l_cursor_id, 12, l_asset_rec.date_placed_in_service);
    dbms_sql.define_column(l_cursor_id, 13, l_asset_rec.asset_cost);
    dbms_sql.define_column(l_cursor_id, 14, l_asset_rec.instance_asset_id);

    l_rows_returned := dbms_sql.execute(l_cursor_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_cursor_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_cursor_id, 1, l_asset_rec.asset_id);
      dbms_sql.column_value(l_cursor_id, 2, l_asset_rec.asset_number);
      dbms_sql.column_value(l_cursor_id, 3, l_asset_rec.asset_category_id);
      dbms_sql.column_value(l_cursor_id, 4, l_asset_rec.asset_key_ccid);
      dbms_sql.column_value(l_cursor_id, 5, l_asset_rec.tag_number);
      dbms_sql.column_value(l_cursor_id, 6, l_asset_rec.asset_description);
      dbms_sql.column_value(l_cursor_id, 7, l_asset_rec.manufacturer_name);
      dbms_sql.column_value(l_cursor_id, 8, l_asset_rec.serial_number);
      dbms_sql.column_value(l_cursor_id, 9, l_asset_rec.model_number);
      dbms_sql.column_value(l_cursor_id, 10, l_asset_rec.current_units);
      dbms_sql.column_value(l_cursor_id, 11, l_asset_rec.book_type_code);
      dbms_sql.column_value(l_cursor_id, 12, l_asset_rec.date_placed_in_service);
      dbms_sql.column_value(l_cursor_id, 13, l_asset_rec.asset_cost);
      dbms_sql.column_value(l_cursor_id, 14, l_asset_rec.instance_asset_id);

      exit;

    END LOOP;

    dbms_sql.close_cursor(l_cursor_id);

    x_fixed_asset_rec := l_asset_rec;

  END get_fixed_assets;

  PROCEDURE get_instance_asset(
    p_instance_id      IN     number,
    p_asset_id         IN     number,
    x_inst_asset_rec      OUT nocopy csi_datastructures_pub.instance_asset_rec,
    x_return_status       OUT nocopy varchar2,
    x_error_message       OUT nocopy varchar2)
  IS
    l_inst_asset_query_rec csi_datastructures_pub.instance_asset_query_rec;
    l_inst_asset_tbl       csi_datastructures_pub.instance_asset_header_tbl;

    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count            number;
    l_msg_data             varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_inst_asset_query_rec.instance_id := p_instance_id;
    l_inst_asset_query_rec.fa_asset_id := p_asset_id;

    debug('inside api csi_asset_pvt.get_instance_assets');

    csi_asset_pvt.get_instance_assets(
      p_api_version               => 1.0,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_full,
      p_instance_asset_query_rec  => l_inst_asset_query_rec,
      p_resolve_id_columns        => fnd_api.g_true,
      p_time_stamp                => to_date(null),
      x_instance_asset_tbl        => l_inst_asset_tbl,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_inst_asset_tbl.COUNT > 0 THEN
      FOR l_ind IN l_inst_asset_tbl.FIRST .. l_inst_asset_tbl.LAST
      LOOP

        debug('  instance_asset_id      : '||l_inst_asset_tbl(l_ind).instance_asset_id);
        debug('  asset_id               : '||l_inst_asset_tbl(l_ind).fa_asset_id);
        debug('  asset_quantity         : '||l_inst_asset_tbl(l_ind).asset_quantity);
        debug('  active_start_date      : '||l_inst_asset_tbl(l_ind).active_start_date);
        debug('  active_end_date        : '||l_inst_asset_tbl(l_ind).active_end_date);

        IF sysdate BETWEEN nvl(l_inst_asset_tbl(l_ind).active_start_date, sysdate-1)
                   AND     nvl(l_inst_asset_tbl(l_ind).active_end_date, sysdate+1)
        THEN

          x_inst_asset_rec.instance_asset_id     := l_inst_asset_tbl(l_ind).instance_asset_id;
          x_inst_asset_rec.instance_id           := l_inst_asset_tbl(l_ind).instance_id;
          x_inst_asset_rec.asset_quantity        := l_inst_asset_tbl(l_ind).asset_quantity;
          x_inst_asset_rec.fa_asset_id           := l_inst_asset_tbl(l_ind).fa_asset_id;
          x_inst_asset_rec.fa_book_type_code     := l_inst_asset_tbl(l_ind).fa_book_type_code;
          x_inst_asset_rec.fa_location_id        := l_inst_asset_tbl(l_ind).fa_location_id;
          x_inst_asset_rec.object_version_number := l_inst_asset_tbl(l_ind).object_version_number;

          exit;

        END IF;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END get_instance_asset;


  PROCEDURE get_pending_additions(
    p_fa_query_rec     IN  fa_query_rec,
    x_fixed_asset_rec  OUT nocopy fixed_asset_rec,
    x_return_status    OUT nocopy varchar2,
    x_error_message    OUT nocopy varchar2)
  IS

    l_posting_status    constant varchar2(6) := 'POSTED';
    l_split_merged_code constant varchar2(2) := 'MP';

    l_stmt varchar2(2000) :=
      'SELECT fma.mass_addition_id, '||
             'fma.model_number, '||
             'fma.serial_number, '||
             'fma.manufacturer_name, '||
             'fma.description, '||
             'fma.tag_number, '||
             'fma.asset_key_ccid, '||
             'fma.asset_category_id, '||
             'fma.asset_number, '||
             'fma.date_placed_in_service, '||
             'fma.reviewer_comments, '||
             'fma.feeder_system_name, '||
             'cia.instance_asset_id  '||
      'FROM   fa_mass_additions fma, csi_i_assets cia, csi_item_instances cii ';

    l_where_clause      varchar2(240);
    l_and_clause        varchar2(540);

    l_cursor_id         number;
    l_rows_returned     number;
    l_ind               binary_integer := 0;

    l_asset_rec         fixed_asset_rec;

  BEGIN

    l_where_clause := 'WHERE fma.posting_status <> :posting_status '||
                      'AND fma.split_merged_code = :split_merged_code '||
                      'AND cia.fa_mass_addition_id = fma.mass_addition_id '||
                      'AND cii.instance_id = cia.instance_id ';

    IF p_fa_query_rec.book_type_code is not null THEN
      l_and_clause := 'AND fma.book_type_code = :book_type_code ';
    END IF;

    IF p_fa_query_rec.asset_category_id is not null THEN
      l_and_clause := l_and_clause || 'AND fma.asset_category_id = :asset_category_id ';
    END IF;

    /*
    IF p_fa_query_rec.serial_number IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.serial_number = :serial_number ';
    END IF;
    */

    IF p_fa_query_rec.asset_description IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.description = :asset_description ';
    END IF;

    IF p_fa_query_rec.date_placed_in_service IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.date_placed_in_service = :dpi ';
    END IF;

    IF p_fa_query_rec.model_number IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.model_number = :model_number ';
    END IF;

    IF p_fa_query_rec.tag_nuber IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.tag_number = :tag_number ';
    END IF;

    IF p_fa_query_rec.manufacturer_name IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.manfacturer_name = :manufacturer_name ';
    END IF;

    IF p_fa_query_rec.asset_key_ccid IS not null THEN
      l_and_clause := l_and_clause || 'AND fma.asset_key_ccid = :asset_key_ccid ';
    END IF;

    IF p_fa_query_rec.inventory_item_id IS not null THEN
      l_and_clause := l_and_clause || 'AND cii.inventory_item_id = :inventory_item_id ';
    END IF;

    IF p_fa_query_rec.search_method = 'FIFO' THEN
      l_and_clause := l_and_clause ||
                      'ORDER BY fma.date_placed_in_service, fma.mass_addition_id';
    ELSIF p_fa_query_rec.search_method = 'LIFO' THEN
      l_and_clause := l_and_clause ||
                      'ORDER BY fma.date_placed_in_service desc, fma.mass_addition_id desc ';
    END IF;

    l_stmt := l_stmt||l_where_clause||l_and_clause;

    debug('fma query : '||l_stmt);

    l_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor_id, l_stmt , dbms_sql.native);

    -- bind variables
    dbms_sql.bind_variable(l_cursor_id, ':posting_status', l_posting_status);
    dbms_sql.bind_variable(l_cursor_id, ':split_merged_code', l_split_merged_code);

    IF p_fa_query_rec.book_type_code is not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':book_type_code', p_fa_query_rec.book_type_code);
    END IF;

    IF p_fa_query_rec.asset_category_id is not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':asset_category_id', p_fa_query_rec.asset_category_id);
    END IF;

    IF p_fa_query_rec.asset_description IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':asset_description', p_fa_query_rec.asset_description);
    END IF;

    IF p_fa_query_rec.serial_number IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':serial_number', p_fa_query_rec.serial_number);
    END IF;

    IF p_fa_query_rec.date_placed_in_service IS not null  THEN
      dbms_sql.bind_variable(l_cursor_id, ':dpi', p_fa_query_rec.date_placed_in_service);
    END IF;

    IF p_fa_query_rec.model_number IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':model_number', p_fa_query_rec.model_number);
    END IF;

    IF p_fa_query_rec.tag_nuber IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':tag_nuber', p_fa_query_rec.tag_nuber);
    END IF;

    IF p_fa_query_rec.manufacturer_name IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':manufacturer_name', p_fa_query_rec.manufacturer_name);
    END IF;

    IF p_fa_query_rec.asset_key_ccid IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':asset_key_ccid', p_fa_query_rec.asset_key_ccid);
    END IF;

    IF p_fa_query_rec.inventory_item_id IS not null THEN
      dbms_sql.bind_variable(l_cursor_id, ':inventory_item_id', p_fa_query_rec.inventory_item_id);
    END IF;

    dbms_sql.define_column(l_cursor_id, 1, l_asset_rec.mass_addition_id);
    dbms_sql.define_column(l_cursor_id, 2, l_asset_rec.model_number, 80);
    dbms_sql.define_column(l_cursor_id, 3, l_asset_rec.serial_number, 80);
    dbms_sql.define_column(l_cursor_id, 4, l_asset_rec.manufacturer_name, 30);
    dbms_sql.define_column(l_cursor_id, 5, l_asset_rec.asset_description, 240);
    dbms_sql.define_column(l_cursor_id, 6, l_asset_rec.tag_number, 30);
    dbms_sql.define_column(l_cursor_id, 7, l_asset_rec.asset_key_ccid);
    dbms_sql.define_column(l_cursor_id, 8, l_asset_rec.asset_category_id);
    dbms_sql.define_column(l_cursor_id, 9, l_asset_rec.asset_number, 30);
    dbms_sql.define_column(l_cursor_id, 10, l_asset_rec.date_placed_in_service);
    dbms_sql.define_column(l_cursor_id, 11, l_asset_rec.reviewer_comments, 240);
    dbms_sql.define_column(l_cursor_id, 12, l_asset_rec.feeder_system_name, 40);
    dbms_sql.define_column(l_cursor_id, 13, l_asset_rec.instance_asset_id);

    l_rows_returned := dbms_sql.execute(l_cursor_id);

    LOOP

      exit when dbms_sql.fetch_rows(l_cursor_id) = 0;
      l_ind := l_ind + 1;

      dbms_sql.column_value(l_cursor_id, 1, l_asset_rec.mass_addition_id);
      dbms_sql.column_value(l_cursor_id, 2, l_asset_rec.model_number);
      dbms_sql.column_value(l_cursor_id, 3, l_asset_rec.serial_number);
      dbms_sql.column_value(l_cursor_id, 4, l_asset_rec.manufacturer_name);
      dbms_sql.column_value(l_cursor_id, 5, l_asset_rec.asset_description);
      dbms_sql.column_value(l_cursor_id, 6, l_asset_rec.tag_number);
      dbms_sql.column_value(l_cursor_id, 7, l_asset_rec.asset_key_ccid);
      dbms_sql.column_value(l_cursor_id, 8, l_asset_rec.asset_category_id);
      dbms_sql.column_value(l_cursor_id, 9, l_asset_rec.asset_number);
      dbms_sql.column_value(l_cursor_id, 10, l_asset_rec.date_placed_in_service);
      dbms_sql.column_value(l_cursor_id, 11, l_asset_rec.reviewer_comments);
      dbms_sql.column_value(l_cursor_id, 12, l_asset_rec.feeder_system_name);
      dbms_sql.column_value(l_cursor_id, 13, l_asset_rec.instance_asset_id);

      exit;

    END LOOP;

    dbms_sql.close_cursor(l_cursor_id);

    x_fixed_asset_rec := l_asset_rec;

  END get_pending_additions;

  PROCEDURE amend_instance_asset(
    p_action               IN     varchar2,
    p_inst_rec             IN     instance_rec,
    p_mass_addition_id     IN     number,
    p_asset_id             IN     number,
    px_csi_txn_rec         IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_inst_asset_rec          OUT nocopy csi_datastructures_pub.instance_asset_rec,
    x_return_status           OUT nocopy varchar2)
  IS
    l_asset_id               number;
    l_inst_asset_rec         csi_datastructures_pub.instance_asset_rec;
    l_lookup_tbl             csi_asset_pvt.lookup_tbl;
    l_asset_count_rec        csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl           csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl          csi_asset_pvt.asset_loc_tbl;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);
    l_error_message          varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('inside api amend_instance_asset');

    IF p_action = 'ADD_TO_ASSET' THEN

      IF p_inst_rec.fa_group_by = 'ITEM' THEN
        l_asset_id := p_asset_id;
      ELSE
        l_asset_id := fnd_api.g_miss_num;
      END IF;

      get_instance_asset(
        p_instance_id      => p_inst_rec.instance_id,
        p_asset_id         => l_asset_id,
        x_inst_asset_rec   => l_inst_asset_rec,
        x_return_status    => l_return_status,
        x_error_message    => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF nvl(l_inst_asset_rec.instance_asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

        IF p_inst_rec.fa_group_by = 'ITEM' THEN

          SELECT asset_quantity + p_inst_rec.quantity,
                 object_version_number
          INTO   l_inst_asset_rec.asset_quantity,
                 l_inst_asset_rec.object_version_number
          FROM   csi_i_assets
          WHERE  instance_asset_id = l_inst_asset_rec.instance_asset_id;

          l_inst_asset_rec.fa_book_type_code     := p_inst_rec.book_type_code;
          l_inst_asset_rec.fa_asset_id           := p_asset_id;
          l_inst_asset_rec.fa_sync_flag          := 'Y';

          csi_asset_pvt.update_instance_asset(
            p_api_version         => 1.0,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_instance_asset_rec  => l_inst_asset_rec,
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

          debug('instance asset rec updated. instance_asset_id : '||l_inst_asset_rec.instance_asset_id);

        ELSE
          -- for a serialized item instance if you find an asset association then hey
          -- one of your smart user has already associated it to a fixed asset
          -- i am not gonna flex my muscle to do all this over again
          NULL;
        END IF;

      ELSE

        l_inst_asset_rec.instance_asset_id   := fnd_api.g_miss_num;
        l_inst_asset_rec.instance_id         := p_inst_rec.instance_id;
        l_inst_asset_rec.fa_book_type_code   := p_inst_rec.book_type_code;
        l_inst_asset_rec.fa_asset_id         := p_asset_id;
        l_inst_asset_rec.fa_location_id      := p_inst_rec.asset_location_id;
        l_inst_asset_rec.asset_quantity      := p_inst_rec.quantity;
        l_inst_asset_rec.fa_mass_addition_id := p_mass_addition_id;
        l_inst_asset_rec.update_status       := 'IN_SERVICE';
        l_inst_asset_rec.fa_sync_flag        := 'Y';

        csi_asset_pvt.create_instance_asset(
          p_api_version         => 1.0,
          p_commit              => fnd_api.g_false,
          p_init_msg_list       => fnd_api.g_true,
          p_validation_level    => fnd_api.g_valid_level_full,
          p_instance_asset_rec  => l_inst_asset_rec,
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

        debug('instance asset rec created. instance_asset_id : '||l_inst_asset_rec.instance_asset_id);

      END IF;
    ELSIF p_action = 'CREATE_MASS_ADDITION' THEN

      l_inst_asset_rec.instance_id         := p_inst_rec.instance_id;
      l_inst_asset_rec.update_status       := 'IN_SERVICE';
      l_inst_asset_rec.fa_book_type_code   := p_inst_rec.book_type_code;
      l_inst_asset_rec.fa_location_id      := p_inst_rec.asset_location_id;
      l_inst_asset_rec.asset_quantity      := p_inst_rec.quantity;
      l_inst_asset_rec.fa_mass_addition_id := p_mass_addition_id;
      l_inst_asset_rec.fa_sync_flag        := 'N';
      l_inst_asset_rec.check_for_instance_expiry := fnd_api.g_false;

      csi_asset_pvt.create_instance_asset(
        p_api_version         => 1.0,
        p_commit              => fnd_api.g_false,
        p_init_msg_list       => fnd_api.g_true,
        p_validation_level    => fnd_api.g_valid_level_full,
        p_instance_asset_rec  => l_inst_asset_rec,
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

      debug('instance asset rec created. instance_asset_id : '||l_inst_asset_rec.instance_asset_id);
      x_inst_asset_rec := l_inst_asset_rec;

    ELSIF p_action = 'ADD_TO_MASS_ADDITION' THEN

      get_instance_asset(
        p_instance_id      => p_inst_rec.instance_id,
        p_asset_id         => fnd_api.g_miss_num,
        x_inst_asset_rec   => l_inst_asset_rec,
        x_return_status    => l_return_status,
        x_error_message    => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF nvl(l_inst_asset_rec.instance_asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

        IF p_inst_rec.fa_group_by  = 'ITEM' THEN

          SELECT asset_quantity + p_inst_rec.quantity,
                 object_version_number
          INTO   l_inst_asset_rec.asset_quantity,
                 l_inst_asset_rec.object_version_number
          FROM   csi_i_assets
          WHERE  instance_asset_id = l_inst_asset_rec.instance_asset_id;

          l_inst_asset_rec.fa_book_type_code     := p_inst_rec.book_type_code;
          l_inst_asset_rec.fa_mass_addition_id   := p_mass_addition_id;
          l_inst_asset_rec.fa_sync_flag          := 'N';

          csi_asset_pvt.update_instance_asset(
            p_api_version         => 1.0,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_instance_asset_rec  => l_inst_asset_rec,
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

          debug('instance asset rec updated. instance_asset_id : '||l_inst_asset_rec.instance_asset_id);
        END IF;

      ELSE

        l_inst_asset_rec.instance_asset_id   := fnd_api.g_miss_num;
        l_inst_asset_rec.instance_id         := p_inst_rec.instance_id;
        l_inst_asset_rec.fa_book_type_code   := p_inst_rec.book_type_code;
        l_inst_asset_rec.fa_location_id      := p_inst_rec.asset_location_id;
        l_inst_asset_rec.asset_quantity      := p_inst_rec.quantity;
        l_inst_asset_rec.fa_mass_addition_id := p_mass_addition_id;
        l_inst_asset_rec.update_status       := 'IN_SERVICE';
        l_inst_asset_rec.fa_sync_flag        := 'N';

        csi_asset_pvt.create_instance_asset(
          p_api_version         => 1.0,
          p_commit              => fnd_api.g_false,
          p_init_msg_list       => fnd_api.g_true,
          p_validation_level    => fnd_api.g_valid_level_full,
          p_instance_asset_rec  => l_inst_asset_rec,
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

        debug('instance asset rec created. instance_asset_id : '||l_inst_asset_rec.instance_asset_id);

      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END amend_instance_asset;

  PROCEDURE create_mass_addition(
    p_instance_rec      IN     instance_rec,
    x_mass_addition_id     OUT nocopy number,
    x_return_status        OUT nocopy varchar2,
    x_error_message        OUT nocopy varchar2)
  IS

    l_parent_posting_status  varchar2(10) := 'POST' ;
    l_child_posting_status   varchar2(10) := 'MERGED';
    l_parent_merge_code      varchar2(2)  := 'MP';
    l_child_merge_code       varchar2(2)  := 'MC';

    l_p_mass_add_rec         fa_mass_additions%rowtype;
    l_c_mass_add_rec         fa_mass_additions%rowtype;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('inside api create_mass_addition');

    savepoint create_mass_addition;

    -- parent mass addition record

    l_p_mass_add_rec.mass_addition_id             := null;
    l_p_mass_add_rec.description                  := p_instance_rec.asset_description;
    l_p_mass_add_rec.asset_category_id            := p_instance_rec.asset_category_id;
    l_p_mass_add_rec.book_type_code               := p_instance_rec.book_type_code;
    l_p_mass_add_rec.location_id                  := p_instance_rec.asset_location_id;
    l_p_mass_add_rec.asset_key_ccid               := p_instance_rec.asset_key_ccid;
    l_p_mass_add_rec.tag_number                   := p_instance_rec.tag_number;
    l_p_mass_add_rec.model_number                 := p_instance_rec.model_number;
    l_p_mass_add_rec.manufacturer_name            := p_instance_rec.manufacturer_name;
    l_p_mass_add_rec.project_id                   := p_instance_rec.pa_project_id;
    l_p_mass_add_rec.task_id                      := p_instance_rec.pa_project_task_id;
    l_p_mass_add_rec.payables_code_combination_id := p_instance_rec.payables_ccid;
    l_p_mass_add_rec.expense_code_combination_id  := p_instance_rec.deprn_expense_ccid;
    l_p_mass_add_rec.assigned_to                  := p_instance_rec.employee_id;  --Added for bug 9433941

    l_p_mass_add_rec.po_number                    := p_instance_rec.po_number;
    l_p_mass_add_rec.po_vendor_id                 := p_instance_rec.po_vendor_id;
    l_p_mass_add_rec.po_distribution_id           := p_instance_rec.po_distribution_id;

    IF p_instance_rec.fa_group_by = 'ITEM' THEN
      l_p_mass_add_rec.payables_units             := p_instance_rec.mtl_txn_qty;
      l_p_mass_add_rec.fixed_assets_units         := p_instance_rec.mtl_txn_qty;
      l_p_mass_add_rec.date_placed_in_service     := p_instance_rec.date_placed_in_service;
    ELSE
      l_p_mass_add_rec.payables_units             := p_instance_rec.quantity;
      l_p_mass_add_rec.fixed_assets_units         := p_instance_rec.quantity;
      l_p_mass_add_rec.date_placed_in_service     := p_instance_rec.csi_txn_date;
      l_p_mass_add_rec.serial_number              := p_instance_rec.serial_number;
    END IF;

    l_p_mass_add_rec.feeder_system_name           := 'ORACLE ENTERPRISE INSTALL BASE';
    l_p_mass_add_rec.queue_name                   := 'POST';
    l_p_mass_add_rec.asset_type                   := 'CAPITALIZED';
    l_p_mass_add_rec.depreciate_flag              := 'YES';
    l_p_mass_add_rec.created_by                   := fnd_global.user_id;
    l_p_mass_add_rec.creation_date                := sysdate;
    l_p_mass_add_rec.last_update_date             := sysdate;
    l_p_mass_add_rec.last_update_login            := fnd_global.login_id;

    SELECT default_group_asset_id
    INTO   l_p_mass_add_rec.group_asset_id
    FROM   fa_category_books
    WHERE  category_id    = l_p_mass_add_rec.asset_category_id
    AND    book_type_code = l_p_mass_add_rec.book_type_code;

    l_p_mass_add_rec.parent_mass_addition_id      := NULL;
    l_p_mass_add_rec.merge_parent_mass_additions_id := NULL;
    l_p_mass_add_rec.posting_status               := l_parent_posting_status;
    l_p_mass_add_rec.split_merged_code            := l_parent_merge_code;
    l_p_mass_add_rec.merged_code                  := l_parent_merge_code;
    l_p_mass_add_rec.fixed_assets_cost            := 0;
    l_p_mass_add_rec.payables_cost                := 0;

    cse_asset_util_pkg.insert_mass_add(
      p_api_version   => 1.0,
      p_commit        => fnd_api.g_false,
      p_init_msg_list => fnd_api.g_true,
      p_mass_add_rec  => l_p_mass_add_rec,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('mass_addition rec created. parent_mass_addition_id : '||l_p_mass_add_rec.mass_addition_id);

    l_c_mass_add_rec := l_p_mass_add_rec;

    l_c_mass_add_rec.mass_addition_id               := null;
    l_c_mass_add_rec.parent_mass_addition_id        := l_p_mass_add_rec.mass_addition_id;
    l_c_mass_add_rec.merge_parent_mass_additions_id := l_p_mass_add_rec.mass_addition_id;
    l_c_mass_add_rec.posting_status                 := l_child_posting_status;
    l_c_mass_add_rec.split_merged_code              := l_child_merge_code;
    l_c_mass_add_rec.merged_code                    := l_child_merge_code;

    l_c_mass_add_rec.fixed_assets_cost := p_instance_rec.asset_unit_cost *
                                          NVL( l_p_mass_add_rec.fixed_assets_units,0);
    l_c_mass_add_rec.payables_cost     := p_instance_rec.asset_unit_cost *
                                          NVL(l_p_mass_add_rec.payables_units,0);

    cse_asset_util_pkg.insert_mass_add(
      p_api_version   => 1.0,
      p_commit        => fnd_api.g_false,
      p_init_msg_list => fnd_api.g_true,
      p_mass_add_rec  => l_c_mass_add_rec,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_mass_addition_id := l_p_mass_add_rec.mass_addition_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to create_mass_addition;
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := cse_util_pkg.dump_error_stack;
  END create_mass_addition;

  PROCEDURE add_to_mass_addition(
    p_mass_addition_id   IN     number,
    p_instance_rec       IN     instance_rec,
    x_return_status         OUT nocopy varchar2,
    x_error_message         OUT nocopy varchar2)
  IS

    l_child_posting_status   varchar2(10) := 'MERGED';
    l_child_merge_code       varchar2(2)  := 'MC';

    l_c_mass_add_rec         fa_mass_additions%rowtype;

    l_asset_quantity         number;
    l_obj_ver_num            number;

    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(2000);
    l_error_message          varchar2(2000);

  BEGIN

    l_c_mass_add_rec.mass_addition_id               := null;
    l_c_mass_add_rec.description                    := p_instance_rec.asset_description;
    l_c_mass_add_rec.asset_category_id              := p_instance_rec.asset_category_id;
    l_c_mass_add_rec.book_type_code                 := p_instance_rec.book_type_code;
    l_c_mass_add_rec.date_placed_in_service         := p_instance_rec.date_placed_in_service;
    l_c_mass_add_rec.location_id                    := p_instance_rec.asset_location_id;
    l_c_mass_add_rec.asset_key_ccid                 := p_instance_rec.asset_key_ccid;
    l_c_mass_add_rec.tag_number                     := p_instance_rec.tag_number;
    l_c_mass_add_rec.model_number                   := p_instance_rec.model_number;
    l_c_mass_add_rec.manufacturer_name              := p_instance_rec.manufacturer_name;
    l_c_mass_add_rec.project_id                     := p_instance_rec.pa_project_id;
    l_c_mass_add_rec.task_id                        := p_instance_rec.pa_project_task_id;
    l_c_mass_add_rec.payables_code_combination_id   := p_instance_rec.payables_ccid;
    l_c_mass_add_rec.expense_code_combination_id    := p_instance_rec.deprn_expense_ccid;
    l_c_mass_add_rec.feeder_system_name             := 'ORACLE ENTERPRISE INSTALL BASE';
    l_c_mass_add_rec.queue_name                     := 'POST';
    l_c_mass_add_rec.asset_type                     := 'CAPITALIZED';
    l_c_mass_add_rec.depreciate_flag                := 'YES';
    l_c_mass_add_rec.created_by                     := fnd_global.user_id;
    l_c_mass_add_rec.creation_date                  := sysdate;
    l_c_mass_add_rec.last_update_date               := sysdate;
    l_c_mass_add_rec.last_update_login              := fnd_global.login_id;
    l_c_mass_add_rec.assigned_to                    := p_instance_rec.employee_id;  --Added for bug 9433941

    IF p_instance_rec.fa_group_by = 'ITEM' THEN
      l_c_mass_add_rec.payables_units               := p_instance_rec.mtl_txn_qty;
      l_c_mass_add_rec.fixed_assets_units           := p_instance_rec.mtl_txn_qty;
    ELSE
      l_c_mass_add_rec.payables_units               := p_instance_rec.quantity;
      l_c_mass_add_rec.fixed_assets_units           := p_instance_rec.quantity;
    END IF;

    l_c_mass_add_rec.payables_cost                  := p_instance_rec.asset_unit_cost *
                                                       NVL(l_c_mass_add_rec.payables_units,0) ;
    l_c_mass_add_rec.fixed_assets_cost              := p_instance_rec.asset_unit_cost *
                                                       NVL( l_c_mass_add_rec.fixed_assets_units,0);

    l_c_mass_add_rec.mass_addition_id               := null;
    l_c_mass_add_rec.parent_mass_addition_id        := p_mass_addition_id;
    l_c_mass_add_rec.merge_parent_mass_additions_id := p_mass_addition_id;
    l_c_mass_add_rec.posting_status                 := l_child_posting_status;
    l_c_mass_add_rec.split_merged_code              := l_child_merge_code;
    l_c_mass_add_rec.merged_code                    := l_child_merge_code;

    cse_asset_util_pkg.insert_mass_add(
      p_api_version   => 1.0,
      p_commit        => fnd_api.g_false,
      p_init_msg_list => fnd_api.g_true,
      p_mass_add_rec  => l_c_mass_add_rec,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- when a child record is added the parent record does not get the cumulative quantity
    UPDATE fa_mass_additions
    SET    payables_units     = payables_units + NVL(l_c_mass_add_rec.payables_units,0),
           fixed_assets_units = fixed_assets_units + NVL(l_c_mass_add_rec.fixed_assets_units,0)
    WHERE  mass_addition_id   = p_mass_addition_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := cse_util_pkg.dump_error_stack;
  END add_to_mass_addition;

  PROCEDURE get_distribution_id(
    p_mass_add_rec         IN         fa_mass_additions%rowtype,
    x_distribution_id      OUT NOCOPY number ,
    x_return_status        OUT NOCOPY varchar2,
    x_error_message        OUT NOCOPY varchar2 )
  IS

    CURSOR dist_cur IS
      SELECT distribution_id,
             units_assigned
      FROM   fa_distribution_history
      WHERE  asset_id            = p_mass_add_rec.asset_id
      AND    book_type_code      = p_mass_add_rec.book_type_code
      AND    location_id         = p_mass_add_rec.location_id
      AND    code_combination_id = nvl(p_mass_add_rec.expense_code_combination_id , code_combination_id)
      AND    nvl(assigned_to,-1) = nvl(p_mass_add_rec.assigned_to, -1)
      AND    date_ineffective IS null;

    l_distribution_id number := null;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    FOR dist_rec IN dist_cur
    LOOP
      l_distribution_id := dist_rec.distribution_id;
      exit;
    END LOOP;

    x_distribution_id := l_distribution_id;

  END get_distribution_id;


  PROCEDURE create_distribution(
    p_mass_add_rec     IN         fa_mass_additions%rowtype,
    x_return_status    OUT NOCOPY varchar2,
    x_error_message    OUT NOCOPY varchar2)
  IS

    l_distribution_id      number;

    l_fa_trans_rec         FA_API_TYPES.trans_rec_type;
    l_fa_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
    l_fa_dist_tbl          FA_API_TYPES.asset_dist_tbl_type;

    l_error_message        varchar2(2000);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data             varchar2(2000);
    l_msg_count            number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('calling get_distribution_id');

    get_distribution_id(
      p_mass_add_rec      => p_mass_add_rec,
      x_distribution_id   => l_distribution_id,
      x_return_status     => l_return_status,
      x_error_message     => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    fnd_msg_pub.initialize;

    l_fa_trans_rec.transaction_type_code    := 'UNIT ADJUSTMENT';
    l_fa_trans_rec.transaction_date_entered := sysdate;

    l_fa_hdr_rec.asset_id       := p_mass_add_rec.asset_id;
    l_fa_hdr_rec.book_type_code := p_mass_add_rec.book_type_code;

    l_fa_dist_tbl(1).distribution_id   := l_distribution_id;
    l_fa_dist_tbl(1).transaction_units := p_mass_add_rec.payables_units;
    l_fa_dist_tbl(1).assigned_to       := p_mass_add_rec.assigned_to;
    l_fa_dist_tbl(1).expense_ccid      := p_mass_add_rec.expense_code_combination_id;
    l_fa_dist_tbl(1).location_ccid     := p_mass_add_rec.location_id;

    debug('calling do_unit_adjustment');

    fa_unit_adj_pub.do_unit_adjustment(
      p_api_version      => 1.0,
      p_calling_fn       => 'CreateDepreciableAssets',
      px_trans_rec       => l_fa_trans_rec,
      px_asset_hdr_rec   => l_fa_hdr_rec,
      px_asset_dist_tbl  => l_fa_dist_tbl,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      l_error_message := cse_util_pkg.dump_error_stack;
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := l_error_message;
  END create_distribution;

  PROCEDURE add_to_asset(
    p_asset_id           IN     number,
    p_instance_rec       IN     instance_rec,
    x_return_status         OUT nocopy varchar2,
    x_error_message         OUT nocopy varchar2)
  IS

    l_mass_add_rec         fa_mass_additions%rowtype;

    l_asset_quantity       number;
    l_obj_ver_num          number;

    l_inst_asset_rec       csi_datastructures_pub.instance_asset_rec;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message        varchar2(2000);

    l_msg_count            number;
    l_msg_data             varchar2(2000);

    skip_add_to_asset      exception;

  BEGIN

    l_mass_add_rec.mass_addition_id               := null;
    l_mass_add_rec.asset_id                       := p_asset_id;
    l_mass_add_rec.description                    := p_instance_rec.asset_description;
    l_mass_add_rec.asset_category_id              := p_instance_rec.asset_category_id;
    l_mass_add_rec.book_type_code                 := p_instance_rec.book_type_code;
    l_mass_add_rec.location_id                    := p_instance_rec.asset_location_id;
    l_mass_add_rec.asset_key_ccid                 := p_instance_rec.asset_key_ccid;
    l_mass_add_rec.tag_number                     := p_instance_rec.tag_number;
    l_mass_add_rec.model_number                   := p_instance_rec.model_number;
    l_mass_add_rec.manufacturer_name              := p_instance_rec.manufacturer_name;
    l_mass_add_rec.project_id                     := p_instance_rec.pa_project_id;
    l_mass_add_rec.task_id                        := p_instance_rec.pa_project_task_id;
    l_mass_add_rec.payables_code_combination_id   := p_instance_rec.payables_ccid;
    l_mass_add_rec.expense_code_combination_id    := p_instance_rec.deprn_expense_ccid;
    l_mass_add_rec.feeder_system_name             := 'ORACLE ENTERPRISE INSTALL BASE';
    l_mass_add_rec.asset_type                     := 'CAPITALIZED';
    l_mass_add_rec.depreciate_flag                := 'YES';
    l_mass_add_rec.created_by                     := fnd_global.user_id;
    l_mass_add_rec.creation_date                  := sysdate;
    l_mass_add_rec.last_update_date               := sysdate;
    l_mass_add_rec.last_update_login              := fnd_global.login_id;
    l_mass_add_rec.assigned_to                    := p_instance_rec.employee_id;  --Added for bug 7456755

    l_mass_add_rec.po_number                      := p_instance_rec.po_number;
    l_mass_add_rec.po_vendor_id                   := p_instance_rec.po_vendor_id;
    l_mass_add_rec.po_distribution_id             := p_instance_rec.po_distribution_id;

    IF p_instance_rec.fa_group_by = 'ITEM' THEN

      l_mass_add_rec.payables_units               := p_instance_rec.mtl_txn_qty;
      l_mass_add_rec.fixed_assets_units           := p_instance_rec.mtl_txn_qty;

    ELSE

      l_mass_add_rec.payables_units               := p_instance_rec.quantity;
      l_mass_add_rec.fixed_assets_units           := p_instance_rec.quantity;

      get_instance_asset(
        p_instance_id      => p_instance_rec.instance_id,
        p_asset_id         => fnd_api.g_miss_num,
        x_inst_asset_rec   => l_inst_asset_rec,
        x_return_status    => l_return_status,
        x_error_message    => l_error_message);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF nvl(l_inst_asset_rec.instance_asset_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        debug('skipping the add to asset for serialized item instance that already has an asset link.');
        RAISE skip_add_to_asset;
      END IF;

    END IF;

    l_mass_add_rec.payables_cost                  := p_instance_rec.asset_unit_cost *
                                                     NVL(l_mass_add_rec.payables_units,0);
    l_mass_add_rec.fixed_assets_cost              := p_instance_rec.asset_unit_cost *
                                                     NVL(l_mass_add_rec.fixed_assets_units,0);

    l_mass_add_rec.posting_status                 := 'POST';
    l_mass_add_rec.queue_name                     := 'ADD TO ASSET';
    l_mass_add_rec.add_to_asset_id                := p_asset_id;

    SELECT date_placed_in_service
    INTO   l_mass_add_rec.date_placed_in_service
    FROM   fa_books
    WHERE  asset_id       = p_asset_id
    AND    book_type_code = p_instance_rec.book_type_code
    AND    date_ineffective is null;

    cse_asset_util_pkg.insert_mass_add(
      p_api_version   => 1.0,
      p_commit        => fnd_api.g_false,
      p_init_msg_list => fnd_api.g_true,
      p_mass_add_rec  => l_mass_add_rec,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('fa_mass_addition rec created. parent_mass_addition_id : '||l_mass_add_rec.mass_addition_id);

    create_distribution(
      p_mass_add_rec     => l_mass_add_rec,
      x_return_status    => l_return_status,
      x_error_message    => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN skip_add_to_asset THEN
      null;
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := cse_util_pkg.dump_error_stack;
  END add_to_asset;

  PROCEDURE create_depreciable_assets(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_inventory_item_id    IN            NUMBER,
    p_organization_id      IN            NUMBER)
  IS

    l_pending_status   varchar2(30) := 'PENDING';
    l_csi_txn_rec      csi_datastructures_pub.transaction_rec;
    l_ts_tbl           txn_status_tbl;
    l_ts_ind           binary_integer := 0;

    CURSOR csi_pending_txn_cur IS
      SELECT ct.transaction_type_id,
             ct.transaction_id,
             ct.transaction_date,
             ct.inv_material_transaction_id,
             ct.source_dist_ref_id2,
             ct.source_dist_ref_id1
      FROM   csi_transactions ct
      WHERE  ct.transaction_type_id IN (117, 129, 128, 105, 112, 118, 119, 133, 132, 73) --Add WIP Assembly Completion for bug 7489949
      AND    ct.transaction_status_code = l_pending_status
      AND    ct.inv_material_transaction_id is not null
      AND    exists (
        SELECT /*+ no_unnest */ 1 FROM mtl_material_transactions mmt
        WHERE  mmt.transaction_id    = ct.inv_material_transaction_id
        AND    mmt.inventory_item_id = nvl(p_inventory_item_id, mmt.inventory_item_id)
        AND    mmt.organization_id   = nvl(p_organization_id, mmt.organization_id))
      ORDER  BY ct.inv_material_transaction_id; --Added hint for bug 9804454

    -- eib supported transactions for fixed asset creation
    ------------------------------------------------------------
    --  117 - ('MISC_RECEIPT')               - depreciable items
    --  129 - ('ACCT_ALIAS_RECEIPT')         - depreciable items
    --  128 - ('ACCT_RECEIPT')               - depreciable items
    --  105 - ('PO_RECEIPT_INTO_PROJECT')    - depreciable items
    --  112 - ('PO_RECEIPT_INTO_INVENTORY')  - depreciable items
    --  118 - ('PHYSICAL_INVENTORY')         - depreciable items
    --  119 - ('CYCLE_COUNT_ADJUSTMENT'      - depreciable items
    --  133 - ('MISC_ISSUE_HZ_LOC')          - normal items
    --  132 - ('ISSUE_TO_HZ_LOC')            - normal items
    -------------------------------------------------------------

    l_inventory_item_id     number;
    l_organization_id       number;
    l_mtl_txn_type_id       number;
    l_mtl_txn_type_name     varchar2(80);
    l_mtl_txn_date          date;
    l_mmt_quantity          number;

    l_serial_code           number;
    l_primary_uom_code      varchar2(6);
    l_asset_creation_code   varchar2(1);
    l_eam_item_type         number;
    l_subinventory_code     varchar2(30);
    l_location_type_code    varchar2(30);
    l_location_id           number;
    l_instance_id           number;
    l_quantity              number;
    l_pa_project_id         number;
    l_pa_project_task_id    number;
    l_distribution_acct_id  number;
    l_ship_to_location_id   number;

    l_depreciable_flag      varchar2(1);
    l_redeploy_flag         varchar2(1);
    l_fa_qry_rec            fa_query_rec;
    l_fixed_asset_rec       fixed_asset_rec;
    l_pending_fa_rec        fixed_asset_rec;

    l_item                  varchar2(80);
    l_item_description      varchar2(240);
    l_fa_group_by           varchar2(30);
    l_mass_addition_id      number;
    l_fa_action             varchar2(30);
    l_instance_asset_rec    csi_datastructures_pub.instance_asset_rec;
    l_asset_exists          varchar2(1) := 'N'; --Added For bug9141680
    l_inventory_asset_flag  varchar2(1) := 'Y'; --Added For bug 9488846
    l_exp_subinv_flag       varchar2(1) := 'N'; --Added For bug 9488846
    l_create_asset_for_exp  varchar2(1) := 'Y'; --Added For bug 9488846

    CURSOR srl_cur(p_mtl_txn_id IN number) IS
      SELECT mut.serial_number           serial_number,
             to_char(null)               lot_number,
             1                           quantity
      FROM   mtl_unit_transactions mut
      WHERE  mut.transaction_id    = p_mtl_txn_id
      UNION
      SELECT mut.serial_number           serial_number,
             mtln.lot_number             lot_number,
             1                           quantity
      FROM   mtl_transaction_lot_numbers mtln,
             mtl_unit_transactions       mut
      WHERE  mtln.transaction_id   = p_mtl_txn_id
      AND    mut.transaction_id    = mtln.serial_transaction_id;

    CURSOR nsrl_inst_cur(p_csi_txn_id IN number, p_inventory_item_id IN number) IS
      SELECT cii.instance_id,
             cii.lot_number,
             cii.location_type_code,
             cii.location_id,
             cii.instance_usage_code,
             cii.quantity,
             nvl(ciih.old_quantity,0) old_quantity,
             ciih.new_quantity
      FROM   csi_item_instances_h ciih,
             csi_item_instances   cii
      WHERE  ciih.transaction_id   = p_csi_txn_id
      AND    cii.instance_id       = ciih.instance_id
      AND    cii.inventory_item_id = p_inventory_item_id
      AND    nvl(ciih.new_quantity, 0) - nvl(ciih.old_quantity,0) > 0;

    l_inst_tbl          instance_tbl;
    inst_ind            binary_integer := 0;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message     varchar2(2000);
    l_err_inst_rec      instance_rec;

  BEGIN

    cse_util_pkg.set_debug;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_fa_group_by := csi_datastructures_pub.g_install_param_rec.fa_creation_group_by;

    l_csi_txn_rec.transaction_type_id     := 123; -- instance_asset_tieback
    l_csi_txn_rec.source_transaction_date := sysdate;
    l_csi_txn_rec.source_group_ref_id     := fnd_global.conc_request_id;
    l_csi_txn_rec.transaction_status_code := 'COMPLETE';

    FOR csi_txn_rec IN csi_pending_txn_cur
    LOOP

      l_ts_ind := l_ts_ind + 1;
      l_ts_tbl(l_ts_ind).csi_txn_id     := csi_txn_rec.transaction_id;
      l_ts_tbl(l_ts_ind).processed_flag := 'N';
      l_ts_tbl(l_ts_ind).valid_txn_flag := 'N';

      BEGIN

        SAVEPOINT create_depreciable_assets;

        debug('====================* BEGIN CREATE ASSET TRANSACTION *====================');
        debug('  csi transaction_id     : '|| csi_txn_rec.transaction_id);

        l_inst_tbl.delete;
        inst_ind := 0;

        SELECT inventory_item_id,
               organization_id,
               transaction_type_id,
               transaction_date,
               subinventory_code,
               abs(primary_quantity),
               source_project_id,
               source_task_id,
               distribution_account_id,
               ship_to_location_id,
               transaction_quantity
        INTO   l_inventory_item_id,
               l_organization_id,
               l_mtl_txn_type_id,
               l_mtl_txn_date,
               l_subinventory_code,
               l_quantity,
               l_pa_project_id,
               l_pa_project_task_id,
               l_distribution_acct_id,
               l_ship_to_location_id,
               l_mmt_quantity
        FROM   mtl_material_transactions
        WHERE  transaction_id = csi_txn_rec.inv_material_transaction_id;

        SELECT transaction_type_name
        INTO   l_mtl_txn_type_name
        FROM   mtl_transaction_types
        WHERE  transaction_type_id = l_mtl_txn_type_id;

        SELECT serial_number_control_code,
               primary_uom_code,
               asset_creation_code,
               description,
               concatenated_segments,
               nvl(eam_item_type, 0),
               inventory_asset_flag
        INTO   l_serial_code,
               l_primary_uom_code,
               l_asset_creation_code,
               l_item_description,
               l_item,
               l_eam_item_type,
               l_inventory_asset_flag
        FROM   mtl_system_items_kfv
        WHERE  inventory_item_id = l_inventory_item_id
        AND    organization_id   = l_organization_id;

        debug('  csi_txn_type_id        : '||csi_txn_rec.transaction_type_id);
        debug('  inventory_item_id      : '||l_inventory_item_id);
        debug('  organization_id        : '||l_organization_id);

        -- for non serialized, just treat it as item grouping always
        IF l_serial_code in (1, 6) THEN
          l_fa_group_by := 'ITEM';
        END IF;

        IF nvl(l_asset_creation_code,'0') in ('1', 'Y') THEN
          l_depreciable_flag := 'Y';
        ELSE
          l_depreciable_flag := 'N';
        END IF;

        debug('  asset_creation_code    : '||l_asset_creation_code);
        debug('  depreciable_flag       : '||l_depreciable_flag);
        --Added For bug9141680
        IF l_depreciable_flag = 'N' AND csi_txn_rec.transaction_type_id in (132, 133) AND l_eam_item_type <> 1 THEN
          l_asset_exists := 'N';
          l_create_asset_for_exp := 'Y'; --Added For bug 9488846
          IF l_serial_code IN (2, 5) THEN
            BEGIN
              SELECT  'Y'
							INTO    l_asset_exists
              FROM    csi_item_instances_h CIIH,
                      csi_item_instances CII,
                      csi_i_assets cia
              WHERE   CIIH.transaction_id = csi_txn_rec.transaction_id
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
              WHERE  CIIH.transaction_id   = csi_txn_rec.transaction_id
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
          --Added For bug9488846 - start
          SELECT decode(asset_inventory,2,'Y','N') --1=Asset Subinventory 2=Expense subinventory
          INTO   l_exp_subinv_flag
          FROM   mtl_secondary_inventories
          WHERE  organization_id          = l_organization_id
          AND    secondary_inventory_name = l_subinventory_code;

          IF l_inventory_asset_flag = 'N' AND l_asset_for_exp_item_flag = 'N' THEN
            l_create_asset_for_exp := 'N';
          END IF;

          IF l_inventory_asset_flag = 'Y' AND l_exp_subinv_flag = 'Y' AND l_asset_for_exp_subinv_flag = 'N' THEN
            l_create_asset_for_exp := 'N';
          END IF;
          --Added For bug9488846 - start
				END IF;
          debug('  l_asset_exists         : '||l_asset_exists);
          debug('  l_asset_for_exp_item_flag         : '||l_asset_for_exp_item_flag);
          debug('  l_asset_for_exp_subinv_flag         : '||l_asset_for_exp_subinv_flag);
          debug('  l_create_asset_for_exp     : '||l_create_asset_for_exp);
				--Added For bug9141680
        -- only for depreciable item txn or for issue to hz txn of normal items
        IF (l_depreciable_flag = 'Y'
            AND
            csi_txn_rec.transaction_type_id NOT IN (132, 133)
            AND
            l_mmt_quantity > 0)
           OR
           (l_depreciable_flag = 'N' AND csi_txn_rec.transaction_type_id in (132, 133) AND l_eam_item_type <> 1 AND l_asset_exists = 'N' AND l_create_asset_for_exp = 'Y')
        THEN

          l_ts_tbl(l_ts_ind).valid_txn_flag := 'Y';

          debug('  item_name              : '||l_item);
          debug('  item_description       : '||l_item_description);
          debug('  csi_txn_date           : '||csi_txn_rec.transaction_date);
          debug('  mtl_txn_id             : '||csi_txn_rec.inv_material_transaction_id);
          debug('  mtl_txn_type_id        : '||l_mtl_txn_type_id);
          debug('  mtl_txn_type_name      : '||l_mtl_txn_type_name);
          debug('  mtl_txn_date           : '||l_mtl_txn_date);

          -- transactions that receive in to inventory location
          IF csi_txn_rec.transaction_type_id IN (117, 129, 128, 112, 73) THEN

            l_location_type_code := 'INVENTORY';

            SELECT location_id
            INTO   l_location_id
            FROM   mtl_secondary_inventories
            WHERE  organization_id          = l_organization_id
            AND    secondary_inventory_name = l_subinventory_code;

            IF l_location_id IS NULL THEN
              SELECT location_id
              INTO   l_location_id
              FROM   hr_all_organization_units
              WHERE  organization_id = l_organization_id;
            END IF;

          ELSIF csi_txn_rec.transaction_type_id IN (132, 133, 105) THEN

            l_location_type_code := 'HZ_LOCATIONS';

            IF csi_txn_rec.transaction_type_id = 105 THEN

              SELECT deliver_to_location_id
              INTO   l_location_id
              FROM   rcv_transactions
              WHERE  transaction_id = csi_txn_rec.source_dist_ref_id2;

            ELSE
              l_location_id := l_ship_to_location_id;
            END IF;

          END IF;

          IF l_serial_code IN (2, 5) THEN

            FOR srl_rec IN srl_cur(csi_txn_rec.inv_material_transaction_id)
            LOOP

              SELECT instance_id
              INTO   l_instance_id
              FROM   csi_item_instances
              WHERE  inventory_item_id = l_inventory_item_id
              AND    serial_number     = srl_rec.serial_number;

              get_redeploy_flag(
                p_instance_id      => l_instance_id,
                p_transaction_date => csi_txn_rec.transaction_date,
                x_redeploy_flag    => l_redeploy_flag);

              IF transaction_pending(csi_txn_rec.transaction_id, l_instance_id) THEN
                fnd_message.set_name('CSE', 'CSE_PRIOR_TXN_PENDING');
                fnd_msg_pub.add;
                l_error_message := cse_util_pkg.dump_error_stack;
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_redeploy_flag = 'N' THEN

                inst_ind := inst_ind + 1;

                l_inst_tbl(inst_ind).instance_id        := l_instance_id;
                l_inst_tbl(inst_ind).csi_txn_id         := csi_txn_rec.transaction_id;
                l_inst_tbl(inst_ind).csi_txn_type_id    := csi_txn_rec.transaction_type_id;
                l_inst_tbl(inst_ind).csi_txn_date       := csi_txn_rec.transaction_date;
                l_inst_tbl(inst_ind).mtl_txn_id         := csi_txn_rec.inv_material_transaction_id;
                l_inst_tbl(inst_ind).mtl_txn_date       := l_mtl_txn_date;
                l_inst_tbl(inst_ind).mtl_txn_qty        := l_quantity;
                l_inst_tbl(inst_ind).quantity           := 1;
                l_inst_tbl(inst_ind).inventory_item_id  := l_inventory_item_id;
                l_inst_tbl(inst_ind).organization_id    := l_organization_id;
                l_inst_tbl(inst_ind).subinventory_code  := l_subinventory_code;
                l_inst_tbl(inst_ind).primary_uom_code   := l_primary_uom_code;
                l_inst_tbl(inst_ind).serial_number      := srl_rec.serial_number;
                l_inst_tbl(inst_ind).lot_number         := srl_rec.lot_number;
                l_inst_tbl(inst_ind).pa_project_id      := l_pa_project_id;
                l_inst_tbl(inst_ind).pa_project_task_id := l_pa_project_task_id;
                l_inst_tbl(inst_ind).location_type_code := l_location_type_code;
                l_inst_tbl(inst_ind).location_id        := l_location_id;
                l_inst_tbl(inst_ind).depreciable_flag   := l_depreciable_flag;
                l_inst_tbl(inst_ind).item               := l_item;
                l_inst_tbl(inst_ind).item_description   := l_item_description;
                l_inst_tbl(inst_ind).mtl_dist_acct_id   := l_distribution_acct_id;
                l_inst_tbl(inst_ind).fa_group_by        := l_fa_group_by;

                IF csi_txn_rec.transaction_type_id in (105, 112) THEN
                  l_inst_tbl(inst_ind).po_distribution_id := csi_txn_rec.source_dist_ref_id1;
                  l_inst_tbl(inst_ind).rcv_txn_id         := csi_txn_rec.source_dist_ref_id2;
                END IF;

              END IF; -- redeploy check

            END LOOP; -- mtl loop

          ELSE

            FOR nsrl_inst_rec IN nsrl_inst_cur(csi_txn_rec.transaction_id, l_inventory_item_id)
            LOOP

              inst_ind := inst_ind + 1;

              l_inst_tbl(inst_ind).instance_id        := nsrl_inst_rec.instance_id;
              l_inst_tbl(inst_ind).csi_txn_id         := csi_txn_rec.transaction_id;
              l_inst_tbl(inst_ind).csi_txn_type_id    := csi_txn_rec.transaction_type_id;
              l_inst_tbl(inst_ind).csi_txn_date       := csi_txn_rec.transaction_date;
              l_inst_tbl(inst_ind).mtl_txn_id         := csi_txn_rec.inv_material_transaction_id;
              l_inst_tbl(inst_ind).mtl_txn_date       := l_mtl_txn_date;
              l_inst_tbl(inst_ind).mtl_txn_qty        := l_quantity;
              l_inst_tbl(inst_ind).quantity           := l_quantity;
              l_inst_tbl(inst_ind).inventory_item_id  := l_inventory_item_id;
              l_inst_tbl(inst_ind).organization_id    := l_organization_id;
              l_inst_tbl(inst_ind).subinventory_code  := l_subinventory_code;
              l_inst_tbl(inst_ind).primary_uom_code   := l_primary_uom_code;
              l_inst_tbl(inst_ind).serial_number      := null;
              l_inst_tbl(inst_ind).lot_number         := nsrl_inst_rec.lot_number;
              l_inst_tbl(inst_ind).pa_project_id      := l_pa_project_id;
              l_inst_tbl(inst_ind).pa_project_task_id := l_pa_project_task_id;
              l_inst_tbl(inst_ind).location_type_code := l_location_type_code;
              l_inst_tbl(inst_ind).location_id        := l_location_id;
              l_inst_tbl(inst_ind).depreciable_flag   := l_depreciable_flag;
              l_inst_tbl(inst_ind).redeploy_flag      :='N' ;
              l_inst_tbl(inst_ind).item               := l_item;
              l_inst_tbl(inst_ind).item_description   := l_item_description;
              l_inst_tbl(inst_ind).mtl_dist_acct_id   := l_distribution_acct_id;
              l_inst_tbl(inst_ind).fa_group_by        := 'ITEM';

              IF csi_txn_rec.transaction_type_id in (105, 112) THEN
                l_inst_tbl(inst_ind).po_distribution_id := csi_txn_rec.source_dist_ref_id1;
                l_inst_tbl(inst_ind).rcv_txn_id         := csi_txn_rec.source_dist_ref_id2;
              END IF;

            END LOOP;
          END IF;

          IF l_inst_tbl.COUNT > 0 THEN
            -- derive asset specific attribs
            derive_asset_attribs(
              px_instance_tbl   => l_inst_tbl,
              x_return_status   => l_return_status,
              x_error_message   => l_error_message);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              l_err_inst_rec := l_inst_tbl(1);
              RAISE fnd_api.g_exc_error;
            END IF;

            dump_inst_tbl(p_inst_tbl  => l_inst_tbl);

            -- follow asset flow
            FOR l_ind IN l_inst_tbl.FIRST .. l_inst_tbl.LAST
            LOOP

              l_fa_qry_rec       := null;
-- Bug#6318642
--            l_mass_addition_id := null;

              IF ( (l_ind = 1 and l_fa_group_by = 'ITEM') OR ( l_fa_group_by = 'ITEM_SERIAL') )
	      THEN
                  l_mass_addition_id := null;
              END IF ;

              l_fa_qry_rec.asset_id               := null;
              l_fa_qry_rec.inventory_item_id      := l_inst_tbl(l_ind).inventory_item_id;
              l_fa_qry_rec.book_type_code         := l_inst_tbl(l_ind).book_type_code;
              l_fa_qry_rec.asset_category_id      := l_inst_tbl(l_ind).asset_category_id;
              l_fa_qry_rec.asset_description      := l_inst_tbl(l_ind).asset_description;
              l_fa_qry_rec.date_placed_in_service := l_inst_tbl(l_ind).date_placed_in_service;
              l_fa_qry_rec.model_number           := l_inst_tbl(l_ind).model_number;
              l_fa_qry_rec.tag_nuber              := l_inst_tbl(l_ind).tag_number;
              l_fa_qry_rec.manufacturer_name      := l_inst_tbl(l_ind).manufacturer_name;
              l_fa_qry_rec.asset_key_ccid         := l_inst_tbl(l_ind).asset_key_ccid;
              l_fa_qry_rec.search_method          := l_inst_tbl(l_ind).search_method;

              IF l_fa_group_by = 'ITEM' THEN
              IF l_ind = 1 THEN
                  get_fixed_assets(
                    p_fa_query_rec     => l_fa_qry_rec,
                    x_fixed_asset_rec  => l_fixed_asset_rec,
                    x_return_status    => l_return_status,
                    x_error_message    => l_error_message);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    l_err_inst_rec := l_inst_tbl(l_ind);
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  IF l_fixed_asset_rec.asset_id is not null THEN

                    debug('  fixed asset found. asset id : '||l_fixed_asset_rec.asset_id);

                    l_fa_action := 'ADD_TO_ASSET';

                    add_to_asset(
                      p_asset_id           => l_fixed_asset_rec.asset_id,
                      p_instance_rec       => l_inst_tbl(l_ind),
                      x_return_status      => l_return_status,
                      x_error_message      => l_error_message);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      l_err_inst_rec := l_inst_tbl(l_ind);
                      RAISE fnd_api.g_exc_error;
                    END IF;

                  ELSE

                    debug('  fixed asset not found. look for pending mass addition');

                    get_pending_additions(
                      p_fa_query_rec     => l_fa_qry_rec,
                      x_fixed_asset_rec  => l_pending_fa_rec,
                      x_return_status    => l_return_status,
                      x_error_message    => l_error_message);

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                      l_err_inst_rec := l_inst_tbl(l_ind);
                      RAISE fnd_api.g_exc_error;
                    END IF;

                    IF l_pending_fa_rec.mass_addition_id is not null THEN

                      debug('pending add found. mass addtion id : '||
                            l_pending_fa_rec.mass_addition_id);

                      l_fa_action := 'ADD_TO_MASS_ADDITION';

-- Bug#6318642
                      l_mass_addition_id := l_pending_fa_rec.mass_addition_id ;

                      add_to_mass_addition(
                        p_mass_addition_id   => l_pending_fa_rec.mass_addition_id,
                        p_instance_rec       => l_inst_tbl(l_ind),
                        x_return_status      => l_return_status,
                        x_error_message      => l_error_message);

                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        l_err_inst_rec := l_inst_tbl(l_ind);
                        RAISE fnd_api.g_exc_error;
                      END IF;

                    ELSE

                      debug('  pending mass addition not found. create mass addition record');

                      l_fa_action := 'CREATE_MASS_ADDITION';

                      create_mass_addition(
                        p_instance_rec     => l_inst_tbl(l_ind),
                        x_mass_addition_id => l_mass_addition_id,
                        x_return_status    => l_return_status,
                        x_error_message    => l_error_message);

                      IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        l_err_inst_rec := l_inst_tbl(l_ind);
                        RAISE fnd_api.g_exc_error;
                      END IF;

                    END IF; -- pending mass_addition is not null

                  END IF; -- asset id is not null

                END IF; -- first record only

              ELSE -- group by is ITEM_SERIAL

                get_instance_asset(
                  p_instance_id      => l_inst_tbl(l_ind).instance_id,
                  p_asset_id         => fnd_api.g_miss_num,
                  x_inst_asset_rec   => l_instance_asset_rec,
                  x_return_status    => l_return_status,
                  x_error_message    => l_error_message);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                IF nvl(l_instance_asset_rec.instance_asset_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
                THEN

                  l_fa_action := 'CREATE_MASS_ADDITION';

                  create_mass_addition(
                    p_instance_rec     => l_inst_tbl(l_ind),
                    x_mass_addition_id => l_mass_addition_id,
                    x_return_status    => l_return_status,
                    x_error_message    => l_error_message);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    l_err_inst_rec := l_inst_tbl(l_ind);
                    RAISE fnd_api.g_exc_error;
                  END IF;

                ELSE
                  l_fa_action := 'NONE';
                END IF;

              END IF;  -- fa creation group by ITEM/ITEM_SERIAL

              IF l_fa_action <> 'NONE' THEN

                l_csi_txn_rec.transaction_id       := fnd_api.g_miss_num;
                l_csi_txn_rec.source_header_ref    := 'CSI_TXN_ID';
                l_csi_txn_rec.source_header_ref_id := csi_txn_rec.transaction_id;

                IF l_mass_addition_id is not null THEN
                  l_csi_txn_rec.source_line_ref    := 'MASS_ADD_ID';
                  l_csi_txn_rec.source_line_ref_id := l_mass_addition_id;
                END IF;

                amend_instance_asset(
                  p_action            => l_fa_action,
                  p_inst_rec          => l_inst_tbl(l_ind),
                  p_mass_addition_id  => l_mass_addition_id,
                  p_asset_id          => l_fixed_asset_rec.asset_id,
                  px_csi_txn_rec      => l_csi_txn_rec,
                  x_inst_asset_rec    => l_instance_asset_rec,
                  x_return_status     => l_return_status);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;
              END IF;

            END LOOP; -- loop thru instances

            complete_csi_txn(
              p_csi_txn_id     => csi_txn_rec.transaction_id,
              x_return_status  => l_return_status,
              x_error_message  => l_error_message);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            debug('csi transaction interfaced to fa successfully.');

            l_ts_tbl(l_ts_ind).processed_flag := 'Y';

          END IF; -- instances found for transaction

        ELSE

          IF csi_txn_rec.transaction_type_id not in (132, 133) THEN
            -- complete the invalid transaction
            complete_csi_txn(
              p_csi_txn_id     => csi_txn_rec.transaction_id,
              x_return_status  => l_return_status,
              x_error_message  => l_error_message);
          END IF;
					--Added for bug 9488846 start
          IF csi_txn_rec.transaction_type_id in (132, 133) AND l_create_asset_for_exp = 'N' AND l_depreciable_flag = 'N' AND l_asset_exists = 'N' THEN
            complete_csi_txn(
              p_csi_txn_id     => csi_txn_rec.transaction_id,
              x_return_status  => l_return_status,
              x_error_message  => l_error_message);
          END IF;
					--Added for bug 9488846 end
        END IF; -- depreciable item txn or issue to hz loc txn

        COMMIT WORK;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          debug('  error message : '||l_error_message);

          l_ts_tbl(l_ts_ind).processed_flag := 'E';
          l_ts_tbl(l_ts_ind).error_message  := l_error_message;

          ROLLBACK TO create_depreciable_assets;
          log_error(
            p_instance_rec  => l_err_inst_rec,
            p_error_message => l_error_message);
        WHEN others THEN
          l_error_message := substr(sqlerrm, 1, 240);
          debug('  error message : '||l_error_message);

          l_ts_tbl(l_ts_ind).processed_flag := 'E';
          l_ts_tbl(l_ts_ind).error_message  := l_error_message;

          ROLLBACK TO create_depreciable_assets;
          log_error(
            p_instance_rec  => l_err_inst_rec,
            p_error_message => l_error_message);
      END;

      debug('====================* END CREATE ASSET TRANSACTION *====================');

    END LOOP;

    asset_creation_report(p_txn_status_tbl => l_ts_tbl);

  EXCEPTION
    WHEN others THEN
      retcode := 1;
      errbuf  := sqlerrm;
  END create_depreciable_assets;


PROCEDURE find_distribution(
  p_asset_query_rec      IN OUT NOCOPY cse_datastructures_pub.asset_query_rec
, p_mass_add_rec         IN     fa_mass_additions%ROWTYPE
, x_new_dist             OUT NOCOPY         NUMBER
, x_return_status        OUT NOCOPY         VARCHAR2
, x_error_msg            OUT NOCOPY         VARCHAR2 )
IS
l_distribution_id        NUMBER ;
l_api_name  VARCHAR2(100):= 'CSE_ASSET_CREATION_PKG.find_distribution';
CURSOR   dist_cur  IS
SELECT   distribution_id
        ,book_type_code
        ,location_id
        ,code_combination_id
        ,assigned_to
        ,units_assigned
  FROM   fa_distribution_history
 WHERE   asset_id = p_asset_query_rec.asset_id
   AND   book_type_code = NVL(p_asset_query_rec.book_type_code,book_type_code)
   AND   location_id = NVL(p_mass_add_rec.location_id , location_id)
   AND   code_combination_id = NVL(p_mass_add_rec.expense_code_combination_id , code_combination_id)
   AND   NVL(assigned_to, -1) = NVL(p_mass_add_rec.assigned_to, -1)
   AND   date_ineffective IS NULL;

CURSOR dist_cur1 IS
SELECT  distribution_id
       ,book_type_code
       ,location_id
       ,code_combination_id
       ,assigned_to
  FROM  fa_distribution_history
 WHERE  asset_id = p_asset_query_rec.asset_id
   AND  book_type_code = NVL(p_asset_query_rec.book_type_code,book_type_code)
   AND  date_ineffective IS NULL ;

BEGIN
   debug('Begin - find distribution');
   x_return_status := fnd_api.G_RET_STS_SUCCESS ;

   ---Initialize x_new_dist to TRUE (1) Indicating that  matching distribution
   ---has not been found
   x_new_dist := 1 ;

   OPEN dist_cur ;
   FETCH dist_cur INTO  p_asset_query_rec.distribution_id,
                        p_asset_query_rec.book_type_code,
                        p_asset_query_rec.location_id,
                        p_asset_query_rec.deprn_expense_ccid,
                        p_asset_query_rec.employee_id ,
                        p_asset_query_rec.current_units ;

   ---Matching Distribution is found, so there is no need for new distribution.
   ---0 IS FALSE
   IF dist_cur%FOUND
   THEN
      debug('FA Dist ID : In dist_cur'||p_asset_query_rec.distribution_id);
      x_new_dist := 0 ;
   END IF ;
   CLOSE dist_cur ;


   ---1 IS TRUE
   IF x_new_dist = 1
   THEN
      OPEN dist_cur1 ;
      FETCH dist_cur1 INTO p_asset_query_rec.distribution_id,
                           p_asset_query_rec.book_type_code,
                           p_asset_query_rec.location_id,
                           p_asset_query_rec.deprn_expense_ccid,
                           p_asset_query_rec.employee_id ;
      CLOSE dist_cur1 ;
   END IF ;

EXCEPTION
WHEN OTHERS
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
   fnd_message.set_token('API_NAME',l_api_name);
   fnd_message.set_token('SQL_ERROR',SQLERRM);
   x_error_msg := fnd_message.get;
END find_distribution ;

PROCEDURE create_fa_distribution(
  p_asset_query_rec      IN          cse_datastructures_pub.asset_query_rec
, p_mass_add_rec         IN          fa_mass_additions%ROWTYPE
, x_return_status        OUT NOCOPY         VARCHAR2
, x_error_msg            OUT NOCOPY         VARCHAR2 )
IS
l_asset_query_rec       cse_datastructures_pub.asset_query_rec ;
x_new_dist              NUMBER;
x_new_from_dist_id      NUMBER;
x_new_to_dist_id        NUMBER;
e_error                EXCEPTION ;
l_api_name  VARCHAR2(100):= 'CSE_ASSET_CREATION_PKG.create_fa_distribution';

BEGIN
debug('Begin - create distribution');
  x_return_status := fnd_api.G_RET_STS_SUCCESS ;
  l_asset_query_rec := p_asset_query_rec ;

  ---07/24
  ---As find asset may find a distribution which may
  ---NOT be same as distribution in p_mass_add_rec.
  ---Initialize distribution to NULL.

  l_asset_query_rec.distribution_id := NULL;

  IF l_asset_query_rec.distribution_id IS NULL
  THEN
     cse_asset_creation_pkg.find_distribution(
              l_asset_query_rec
            , p_mass_add_rec
            , x_new_dist
            , x_return_status
            , x_error_msg );

     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS
     THEN
        RAISE e_error ;
     END IF ;
  END IF ;

  IF l_asset_query_rec.distribution_id IS NOT NULL
  THEN

     cse_ifa_trans_pkg.adjust_fa_distribution(
            l_asset_query_rec.asset_id
           ,l_asset_query_rec.book_type_code
           ,p_mass_add_rec.payables_units
           ,l_asset_query_rec.location_id
           ,l_asset_query_rec.deprn_expense_ccid
           ,l_asset_query_rec.deprn_employee_id
           ,l_asset_query_rec.distribution_id
           ,x_return_status
           ,x_error_msg  );
    IF x_return_status <> fnd_api.G_RET_STS_SUCCESS
    THEN
       RAISE e_error ;
    END IF ;
  END IF ;

  ---Needs a transfer
  IF x_new_dist = 1 THEN
     cse_ifa_trans_pkg.transfer_fa_distribution(
            l_asset_query_rec.asset_id
           ,l_asset_query_rec.book_type_code
           ,p_mass_add_rec.payables_units
           ,l_asset_query_rec.location_id
           ,l_asset_query_rec.deprn_expense_ccid
           ,l_asset_query_rec.deprn_employee_id
           ,p_mass_add_rec.location_id
           ,p_mass_add_rec.expense_code_combination_id
           ,p_mass_add_rec.assigned_to
           ,x_new_from_dist_id
           ,x_new_to_dist_id
           ,x_return_status
           ,x_error_msg  );
   END IF;

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS
   THEN
      RAISE e_error ;
   END IF ;
EXCEPTION
WHEN e_error
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   x_error_msg      := x_error_msg ;
WHEN OTHERS
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
   fnd_message.set_token('API_NAME',l_api_name);
   fnd_message.set_token('SQL_ERROR',SQLERRM);
   x_error_msg := fnd_message.get;
END create_fa_distribution;

  PROCEDURE find_asset(
    p_asset_query_rec   IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
    p_distribution_tbl     OUT NOCOPY cse_datastructures_pub.distribution_tbl,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_error_msg            OUT NOCOPY VARCHAR2 )
  IS
    l_sql_stmt                     VARCHAR2(6000);
    l_order_by_clause              VARCHAR2(1000);
    l_asset_id                     NUMBER;
    l_search_method                VARCHAR2(4);
    l_asset_number                 VARCHAR2(15) := NULL ;
    l_category_id                  NUMBER;
    l_book_type_code               VARCHAR2(15) := NULL ;
    l_date_placed_in_service       DATE;
    l_asset_key_ccid               NUMBER;
    l_tag_number                   VARCHAR2(15) := NULL ;
    l_description                  VARCHAR2(80) := NULL ;
    l_manufacturer_name            VARCHAR2(30) := NULL ;
    l_serial_number                VARCHAR2(35) := NULL ;
    l_model_number                 VARCHAR2(40) := NULL ;
    l_location_id                  NUMBER;
    l_employee_id                  NUMBER;
    l_deprn_expense_ccid           NUMBER;
    l_inventory_item_id            NUMBER;
    l_code_combination_id          NUMBER;
    x_msg_count                    NUMBER ;
    x_msg_data                     VARCHAR2(2000)  := NULL ;
    l_total_units                  NUMBER :=0;
    l_location_units               NUMBER :=0;
    l_unit_ratio                   NUMBER;
    i                              NUMBER ;
    e_error                        EXCEPTION;
    l_cost                         NUMBER;
    l_total_cost                   NUMBER;
    l_mtl_cost                     NUMBER ;
    l_non_mtl_cost                 NUMBER ;
    l_mtl_ratio                    NUMBER ;

    l_api_name VARCHAR2(100) := 'CSE_ASSET_CREATION_PKG.find_asset';

    CURSOR dist_history_cur IS
      SELECT distribution_id
            ,location_id
            ,assigned_to
            ,code_combination_id
            ,units_assigned
      FROM  fa_distribution_history
      WHERE asset_id = p_asset_query_rec.asset_id
      AND   book_type_code = p_asset_query_rec.book_type_code
      AND   location_id = NVL(p_asset_query_rec.location_id,location_id)
      AND   code_combination_id = NVL(p_asset_query_rec.deprn_expense_ccid,code_combination_id)
      AND   NVL(assigned_to,-1) = NVL(p_asset_query_rec.employee_id,NVL(assigned_to,-1))
      AND   date_ineffective IS NULL ;

    CURSOR asset_cost_cur IS
      SELECT DECODE(attribute15,cse_asset_util_pkg.G_MTL_INDICATOR,SUM(fixed_assets_cost),0)
             Material_cost ,
             DECODE(attribute15,cse_asset_util_pkg.G_MTL_INDICATOR,0,SUM(fixed_assets_cost))
             Non_Material_cost
      FROM   fa_asset_invoices
      WHERE  date_ineffective IS NULL
      AND    asset_id = p_asset_query_rec.asset_id
      GROUP BY attribute15 ;

    CURSOR fa_add_lifo_cur IS
      SELECT fab.asset_id,
             fab.asset_number,
             fab.asset_category_id,
             fab.asset_key_ccid,
             fab.tag_number,
             fab.description,
             fab.manufacturer_name,
             fab.serial_number,
             fab.model_number,
             fab.current_units,
             cii.inventory_item_id,
             fb.book_type_code,
             fb.date_placed_in_service,
             fb.cost
      FROM   csi_item_instances cii,
             csi_i_assets       cia,
             fa_books           fb,
             fa_additions       fab
      WHERE  cii.inventory_item_id = NVL(p_asset_query_rec.inventory_item_id, cii.inventory_item_id)
      AND   cii.instance_id = cia.instance_id
      AND   cia.fa_asset_id    = fab.asset_id
      AND   cia.fa_book_type_code = fb.book_type_code
      AND   TRUNC(fb.date_placed_in_service) =
            TRUNC(NVL(p_asset_query_rec.date_placed_in_service, fb.date_placed_in_service))
      AND   fb.book_type_code = NVL(p_asset_query_rec.book_type_code, fb.book_type_code)
      AND   fb.date_ineffective IS NULL
      AND   fb.asset_id       = fab.asset_id
      AND   NVL(fab.model_number, '!@#^') = NVL(p_asset_query_rec.model_number, NVL(fab.model_number, '!@#^') )
      AND   NVL(fab.serial_number, '!@#^') = NVL(p_asset_query_rec.serial_number, '!@#^')
      AND   NVL(fab.manufacturer_name, '!@#^') = NVL(p_asset_query_rec.manufacturer_name,NVL(fab.manufacturer_name, '!@#^')  )
      AND   NVL(fab.tag_number, '!@#^')    = NVL(p_asset_query_rec.tag_number, NVL(fab.tag_number, '!@#^')  )
      AND   NVL(fab.asset_key_ccid, -1)      = NVL(p_asset_query_rec.asset_key_ccid,NVL(fab.asset_key_ccid, -1) )
      AND   fab.asset_category_id       = NVL(p_asset_query_rec.category_id,fab.asset_category_id)
      AND   fab.asset_number            = NVL(p_asset_query_rec.asset_number,fab.asset_number)
      AND   fab.asset_id                = NVL(p_asset_query_rec.asset_id,fab.asset_id)
      ORDER BY fb.date_placed_in_service DESC, fab.asset_id DESC ;

    CURSOR fa_add_fifo_cur IS
      SELECT fab.asset_id
            ,fab.asset_number
       ,fab.asset_category_id
       ,fab.asset_key_ccid
       ,fab.tag_number
       ,fab.description
       ,fab.manufacturer_name
       ,fab.serial_number
       ,fab.model_number
       ,fab.current_units
       ,cii.inventory_item_id
       ,fb.book_type_code
       ,fb.date_placed_in_service
       ,fb.cost
  FROM  csi_item_instances    cii
        ,csi_i_assets    cia
        ,fa_books    fb
        ,fa_additions   fab
 WHERE  cii.inventory_item_id = NVL(p_asset_query_rec.inventory_item_id,
                                           cii.inventory_item_id)
  AND   cii.instance_id = cia.instance_id
  AND   cia.fa_asset_id    = fab.asset_id
  AND   cia.fa_book_type_code = fb.book_type_code
  AND   TRUNC(fb.date_placed_in_service) =
         TRUNC(NVL(p_asset_query_rec.date_placed_in_service, fb.date_placed_in_service))
  AND   fb.book_type_code = NVL(p_asset_query_rec.book_type_code, fb.book_type_code)
  AND   fb.date_ineffective IS NULL
  AND   fb.asset_id       = fab.asset_id
  AND   NVL(fab.model_number, '!@#^') = NVL(p_asset_query_rec.model_number, NVL(fab.model_number, '!@#^') )
  AND   NVL(fab.serial_number, '!@#^') = NVL(p_asset_query_rec.serial_number, '!@#^')
  AND   NVL(fab.manufacturer_name, '!@#^') = NVL(p_asset_query_rec.manufacturer_name,NVL(fab.manufacturer_name, '!@#^')  )
  AND   NVL(fab.tag_number, '!@#^')    = NVL(p_asset_query_rec.tag_number, NVL(fab.tag_number, '!@#^')  )
  AND   NVL(fab.asset_key_ccid, -1)      = NVL(p_asset_query_rec.asset_key_ccid,NVL(fab.asset_key_ccid, -1) )
  AND   fab.asset_category_id       = NVL(p_asset_query_rec.category_id,fab.asset_category_id)
  AND   fab.asset_number            = NVL(p_asset_query_rec.asset_number,fab.asset_number)
  AND   fab.asset_id                = NVL(p_asset_query_rec.asset_id,fab.asset_id)
  ORDER BY fb.date_placed_in_service , fab.asset_id ;

BEGIN

debug('Begin - find asset');
x_return_status := fnd_api.G_RET_STS_SUCCESS ;
l_asset_number                :=      p_asset_query_rec.asset_number;
l_asset_id                    :=      p_asset_query_rec.asset_id;
l_book_type_code              :=      p_asset_query_rec.book_type_code ;
l_serial_number               :=      UPPER(p_asset_query_rec.serial_number);

IF l_asset_id IS NOT NULL
AND l_book_type_code IS NOT NULL
THEN
  debug('Searching based on Asset ID abd Book Type alone');
   ---Don't serach on following, asset_id and booktype is fine.
   l_category_id                 :=   NULL ;
   l_date_placed_in_service      :=     NULL ;
   l_asset_key_ccid              :=    NULL ;
   l_tag_number                  :=   NULL ;
   l_description                 :=  NULL ;
   l_manufacturer_name           := NULL ;
   l_model_number                :=   NULL ;
ELSE
   l_category_id                 :=      p_asset_query_rec.category_id ;
   l_date_placed_in_service      :=      p_asset_query_rec.date_placed_in_service ;
   l_asset_key_ccid              :=      p_asset_query_rec.asset_key_ccid;
   l_tag_number                  :=      p_asset_query_rec.tag_number;
   l_description                 :=      p_asset_query_rec.description;
   l_manufacturer_name           :=      p_asset_query_rec.manufacturer_name;
   l_model_number                :=      p_asset_query_rec.model_number;
END IF ;

l_location_id                 :=      p_asset_query_rec.location_id;
l_deprn_expense_ccid          :=      p_asset_query_rec.deprn_expense_ccid;
l_inventory_item_id           :=      p_asset_query_rec.inventory_item_id;

IF l_asset_number = FND_API.G_MISS_CHAR
THEN
  debug('l_asset_number                :'||    'NULL');
ELSE
  debug('l_asset_number                :'||      p_asset_query_rec.asset_number);
END IF ;
debug('l_asset_id                    :'||      p_asset_query_rec.asset_id);
debug('l_category_id                 :'||      l_category_id );
debug('l_book_type_code              :'||      l_book_type_code );
debug('l_date_placed_in_service      :'||      l_date_placed_in_service) ;
debug('l_asset_key_ccid              :'||      l_asset_key_ccid);

IF l_tag_number = FND_API.G_MISS_CHAR
THEN
  debug('l_tag_number                :'||    'NULL');
ELSE
  debug('l_tag_number                  :'||      l_tag_number);
END IF ;
IF l_description  = FND_API.G_MISS_CHAR
THEN
  debug('l_description                 :'|| 'NULL');
ELSE
  debug('l_description                 :'||      l_description);
END IF ;

IF l_manufacturer_name  = FND_API.G_MISS_CHAR
THEN
  debug('l_manufacturer_name                 :'|| 'NULL');
ELSE
  debug('l_manufacturer_name                 :'||      l_manufacturer_name);
END IF ;

IF l_serial_number  = FND_API.G_MISS_CHAR
THEN
  debug('l_serial_number                 :'|| 'NULL');
ELSE
  debug('l_serial_number                 :'||      l_serial_number);
END IF ;

IF l_model_number  = FND_API.G_MISS_CHAR
THEN
  debug('l_model_number                 :'|| 'NULL');
ELSE
  debug('l_model_number                 :'||      l_model_number);
END IF ;
debug('l_location_id                 :'||      l_location_id);
debug('l_deprn_expense_ccid          :'||      l_deprn_expense_ccid);
debug('l_inventory_item_id           :'||     l_inventory_item_id);


  IF p_asset_query_rec.search_method = cse_datastructures_pub.G_LIFO_SEARCH
  THEN
     OPEN fa_add_lifo_cur ;
     FETCH fa_add_lifo_cur INTO p_asset_query_rec.asset_id
                      ,p_asset_query_rec.asset_number
                      ,p_asset_query_rec.category_id
                      ,p_asset_query_rec.asset_key_ccid
                      ,p_asset_query_rec.tag_number
                      ,p_asset_query_rec.description
                      ,p_asset_query_rec.manufacturer_name
                      ,p_asset_query_rec.serial_number
                      ,p_asset_query_rec.model_number
                      ,l_total_units
                      ,p_asset_query_rec.inventory_item_id
                      ,p_asset_query_rec.book_type_code
                      ,p_asset_query_rec.date_placed_in_service
                      ,l_cost ;

     IF fa_add_lifo_cur%NOTFOUND
     THEN
        debug('Asset NOT Found ');
        p_asset_query_rec.asset_id := NULL ;
     END IF ;
     CLOSE fa_add_lifo_cur ;

  ELSE
     OPEN fa_add_fifo_cur ;
     FETCH fa_add_fifo_cur INTO p_asset_query_rec.asset_id
                      ,p_asset_query_rec.asset_number
                      ,p_asset_query_rec.category_id
                      ,p_asset_query_rec.asset_key_ccid
                      ,p_asset_query_rec.tag_number
                      ,p_asset_query_rec.description
                      ,p_asset_query_rec.manufacturer_name
                      ,p_asset_query_rec.serial_number
                      ,p_asset_query_rec.model_number
                      ,l_total_units
                      ,p_asset_query_rec.inventory_item_id
                      ,p_asset_query_rec.book_type_code
                      ,p_asset_query_rec.date_placed_in_service
                      ,l_cost ;

     IF fa_add_fifo_cur%NOTFOUND
     THEN
        debug('Asset NOT Found ');
        p_asset_query_rec.asset_id := NULL ;
     END IF ;
     CLOSE fa_add_fifo_cur ;

  END IF;




  IF p_asset_query_rec.asset_id IS NOT NULL
  THEN
     debug('Asset Found , ID is :'||p_asset_query_rec.asset_id);
     x_return_status := FND_API.G_RET_STS_SUCCESS ;

     OPEN asset_cost_cur ;
     FETCH asset_cost_cur into l_mtl_cost ,l_non_mtl_cost ;
     CLOSE asset_cost_cur ;
     l_total_cost := NVL(l_mtl_cost,0)+NVL(l_non_mtl_cost,0);
     debug('Total Cost :'||NVL(l_total_cost,0));

     ---Modified 10-17
     IF l_total_cost = 0
     THEN
        l_mtl_ratio := 1 ;
     ELSE
        l_mtl_ratio := l_mtl_cost/l_total_cost ;
     END IF ;

     debug('l_mtl_ratio : '|| l_mtl_ratio);
     p_asset_query_rec.current_mtl_cost := l_cost*l_mtl_ratio ;
     p_asset_query_rec.current_non_mtl_cost := l_cost - p_asset_query_rec.current_mtl_cost ;

     l_location_units := 0;
     i := 0;

     FOR dist_history_rec IN dist_history_cur
     LOOP
        i := i+1 ;
        p_distribution_tbl(i).asset_id := p_asset_query_rec.asset_id ;
        p_distribution_tbl(i).book_type_code := p_asset_query_rec.book_type_code ;
        p_distribution_tbl(i).distribution_id := dist_history_rec.distribution_id ;
        p_distribution_tbl(i).location_id := dist_history_rec.location_id ;
        p_distribution_tbl(i).employee_id := dist_history_rec.assigned_to ;
        p_distribution_tbl(i).deprn_expense_ccid := dist_history_rec.code_combination_id ;
        p_distribution_tbl(i).current_units := dist_history_rec.units_assigned ;
        p_distribution_tbl(i).pending_ret_units := 0;
        l_location_units := l_location_units + dist_history_rec.units_assigned ;
     END LOOP ;

        debug('l_total_units : '|| l_total_units);
        debug('l_location_units : '|| l_location_units);

-- 10/12
--      l_unit_ratio := l_location_units/l_total_units ;
--      p_asset_query_rec.current_mtl_cost :=
--            p_asset_query_rec.current_mtl_cost * l_unit_ratio ;
--      p_asset_query_rec.current_non_mtl_cost :=
--            p_asset_query_rec.current_non_mtl_cost * l_unit_ratio ;
--

        ---08/28 changed to total_units instead of location_units
        ----p_asset_query_rec.current_units := l_location_units ;
        p_asset_query_rec.current_units := l_total_units  ;

        cse_asset_util_pkg.get_pending_retirements(p_asset_query_rec,
                   p_distribution_tbl,
                   x_return_status,
                   x_error_msg);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        RAISE e_error ;
     END IF;

     cse_asset_util_pkg.get_pending_adjustments(p_asset_query_rec,
                   x_return_status,
                   x_error_msg);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        RAISE e_error;
     END IF;

  ELSE
     p_asset_query_rec.asset_id := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS ;
  END IF;

EXCEPTION
WHEN e_error
THEN
   x_return_status := fnd_api.G_RET_STS_ERROR ;
   --Log Error Here.
   debug('IN e_error:'||x_error_msg);
WHEN OTHERS
THEN
   x_return_status := fnd_api.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
   fnd_message.set_token('API_NAME',l_api_name);
   fnd_message.set_token('SQL_ERROR',SQLERRM);
   x_error_msg := fnd_message.get;

   debug(x_error_msg);
END find_asset;

  PROCEDURE adjust_asset(
    p_asset_query_rec      IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
    p_mass_add_rec         IN OUT NOCOPY fa_mass_additions%ROWTYPE,
    p_mtl_percent          IN            NUMBER,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_error_msg            OUT NOCOPY    VARCHAR2 )
  IS
    l_mass_add_rec           fa_mass_additions%ROWTYPE;
    l_mass_ext_trf_rec       fa_mass_external_transfers%ROWTYPE;

    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    l_group_asset_id         NUMBER ;
    l_mass_external_retire_id       NUMBER ;
    l_prorate_convention            fa_mass_ext_retirements.retirement_prorate_convention%TYPE;
    l_batch_name                    fa_mass_ext_retirements.batch_name%TYPE ;
    l_init_ext_ret_rec              fa_mass_ext_retirements%ROWTYPE ;
    l_ext_ret_rec                   fa_mass_ext_retirements%ROWTYPE ;
    l_sysdate                       DATE := SYSDATE ;

    l_api_name               VARCHAR2(100) := 'CSE_ASSET_CREATION_PKG.adjust_asset';
    l_total_fa_units        NUMBER ;

    CURSOR fa_asset_units (c_asset_id IN NUMBER) IS
      SELECT fad.current_units
      FROM   fa_additions fad
      WHERE  fad.asset_id = c_asset_id ;

    CURSOR dpi_for_ipv (c_asset_id IN NUMBER, c_book_type_code IN VARCHAR2) IS
      SELECT date_placed_in_service
      FROM   fa_books
      WHERE  asset_id = c_asset_id
      AND    book_type_code = c_book_type_code ;

    CURSOR get_group_asset_id_cur (c_asset_category_id IN NUMBER, c_book_type_code IN VARCHAR2) IS
      SELECT default_group_asset_id
      FROM   fa_category_books
      WHERE  category_id = c_asset_category_id
      AND    book_type_code = c_book_type_code ;

    CURSOR prorate_convention_cur (c_book_type_code IN VARCHAR2, c_asset_id IN NUMBER) IS
      SELECT  fcgd.retirement_prorate_convention
      FROM    fa_category_book_defaults    fcgd
             ,fa_books    fb
             ,fa_additions_b    fab
      WHERE  fb.date_placed_in_service BETWEEN fcgd.start_dpis AND
             NVL(fcgd.end_dpis, fb.date_placed_in_service)
      AND    fb.date_ineffective IS NULL
      AND    fb.book_type_code = fcgd.book_type_code
      AND    fb.asset_id = fab.asset_id
      AND    fcgd.book_type_code = c_book_type_code
      AND    fcgd.category_id = fab.asset_category_id
      AND    fab.asset_id = c_asset_id ;

  BEGIN

    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
    debug('inside api cse_asset_creation_pkg.adjust_asset');
    debug(' asset_id                : '||p_asset_query_rec.asset_id);
    debug(' units_to_be_adjusted    : '||p_mass_add_rec.payables_units);

    l_mass_add_rec := p_mass_add_rec ;
    OPEN fa_asset_units (p_asset_query_rec.asset_id ) ;
    FETCH fa_asset_units  INTO l_total_fa_units ;
    CLOSE fa_asset_units ;

    l_total_fa_units := NVL(l_total_fa_units,0);
    debug(' total_fa_units          : '||l_total_fa_units);

    IF nvl(l_total_fa_units,0) - abs(nvl(p_mass_add_rec.payables_units,0)) > 0 THEN

      OPEN get_group_asset_id_cur (p_mass_add_rec.asset_category_id,p_mass_add_rec.book_type_code );
      FETCH get_group_asset_id_cur INTO l_group_asset_id;
      CLOSE get_group_asset_id_cur;

      IF l_group_asset_id IS NOT NULL THEN
        l_mass_add_rec.group_asset_id := l_group_asset_id;
      END IF ;
      l_mass_add_rec.add_to_asset_id := p_asset_query_rec.asset_id ;
      l_mass_add_rec.posting_status  := 'POST' ;
      l_mass_add_rec.queue_name      := 'ADD TO ASSET';

      ---FOR IPV
      IF NVL(p_mass_add_rec.reviewer_comments,'!#$') ='IPV' THEN
        OPEN  dpi_for_ipv (l_mass_add_rec.add_to_asset_id, l_mass_add_rec.book_type_code) ;
        FETCH dpi_for_ipv INTO l_mass_add_rec.date_placed_in_service  ;
        CLOSE dpi_for_ipv ;
      END IF ;

      IF p_mtl_percent <> 0 THEN

        l_mass_add_rec.fixed_assets_cost := p_mass_add_rec.fixed_assets_cost*p_mtl_percent ;
        l_mass_add_rec.payables_cost := p_mass_add_rec.payables_cost*p_mtl_percent ;
        l_mass_add_rec.attribute14 := cse_asset_util_pkg.G_MTL_INDICATOR ;

        cse_asset_util_pkg.insert_mass_add(
          1.0,
          fnd_api.g_false,
          fnd_api.g_true,
          l_mass_add_rec,
          x_return_status,
          x_msg_count,
          x_msg_data);

        IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          x_error_msg := x_msg_data ;
          RAISE fnd_api.g_exc_error;
        END IF ;

      END IF ;  ---Material Cost

      IF p_mtl_percent <> 1 THEN

        l_mass_add_rec.fixed_assets_cost := p_mass_add_rec.fixed_assets_cost*(1 - p_mtl_percent) ;
        l_mass_add_rec.payables_cost := p_mass_add_rec.payables_cost*(1 - p_mtl_percent) ;
        l_mass_add_rec.attribute14 := cse_asset_util_pkg.g_non_mtl_indicator;

        cse_asset_util_pkg.insert_mass_add(
          1.0,
          fnd_api.g_false,
          fnd_api.g_true,
          l_mass_add_rec,
          x_return_status,
          x_msg_count,
          x_msg_data );

        IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          x_error_msg := x_msg_data ;
          RAISE fnd_api.g_exc_error ;
        END IF ;

       END IF ; --Non-material Cost

      -- NON IPV Adjustment
      IF NVL(p_mass_add_rec.reviewer_comments,'!#$') <> 'IPV' THEN

        p_asset_query_rec.location_id := l_mass_add_rec.location_id ;
        p_asset_query_rec.deprn_expense_ccid := l_mass_add_rec.expense_code_combination_id ;
        p_asset_query_rec.employee_id := l_mass_add_rec.assigned_to ;

        create_fa_distribution (
          p_asset_query_rec,
          p_mass_add_rec,
          x_return_status,
          x_error_msg );

        IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE fnd_api.g_exc_error ;
        END IF ;
      ELSE
        NULL ;
        debug('This is IPV Cost Adjustment ONLY');
      END IF ; --IPV

    ELSE --retirement

      debug('need to retire this asset');

      OPEN  prorate_convention_cur ( p_asset_query_rec.book_type_code, p_asset_query_rec.asset_id ) ;
      FETCH prorate_convention_cur INTO l_prorate_convention ;
      CLOSE prorate_convention_cur ;

      SELECT fa_mass_ext_retirements_s.nextval
      INTO   l_mass_external_retire_id
      FROM   dual ;

      l_batch_name := 'BATCH'||TO_CHAR(l_mass_external_retire_id) ;

      l_ext_ret_rec.batch_name              := l_batch_name;
      l_ext_ret_rec.mass_external_retire_id := l_mass_external_retire_id;
      l_ext_ret_rec.book_type_code          := p_asset_query_rec.book_type_code;
      l_ext_ret_rec.review_status           := 'POST';
      l_ext_ret_rec.retirement_type_code    := 'EXTRAORDINARY';
      l_ext_ret_rec.asset_id                := p_asset_query_rec.asset_id;
      l_ext_ret_rec.date_retired            := l_sysdate;
      l_ext_ret_rec.date_effective          := l_sysdate;
      l_ext_ret_rec.cost_retired            := ABS(p_mass_add_rec.fixed_assets_cost);
      l_ext_ret_rec.units                   := ABS(p_mass_add_rec.payables_units );
      l_ext_ret_rec.cost_of_removal         := 0;
      l_ext_ret_rec.proceeds_of_sale        := 0;
      l_ext_ret_rec.calc_gain_loss_flag     := 'N' ;
      l_ext_ret_rec.created_by              := fnd_global.user_id;
      l_ext_ret_rec.creation_date           := l_sysdate;
      l_ext_ret_rec.last_updated_by         := fnd_global.user_id;
      l_ext_ret_rec.last_update_date        := l_sysdate;
      l_ext_ret_rec.last_update_login       := fnd_global.login_id;
      l_ext_ret_rec.retirement_prorate_convention := l_prorate_convention ;

      cse_asset_adjust_pkg.insert_retirement(
        l_ext_ret_rec,
        x_return_status,
        x_error_msg) ;

      IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        debug('Insert into Retirements table failed ');
        RAISE fnd_api.g_exc_error ;
      END IF ;

    END IF ; --retirement

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_error_msg      := x_error_msg ;
    WHEN OTHERS THEN
      x_return_status := fnd_api.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;
  END adjust_asset;


  PROCEDURE create_asset(
    p_inst_tbl          IN  instance_tbl,
    x_return_status     OUT nocopy varchar2,
    x_err_inst_rec      OUT nocopy instance_rec)
  IS
    l_inst_rec              instance_rec;
    l_fa_qry_rec            fa_query_rec;
    l_fixed_asset_rec       fixed_asset_rec;
    l_pending_fa_rec        fixed_asset_rec;

    l_mass_addition_id      number;
    l_fa_action             varchar2(30);

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message         varchar2(2000);

  BEGIN

    IF p_inst_tbl.COUNT > 0 THEN

      FOR l_ind IN p_inst_tbl.FIRST .. p_inst_tbl.LAST
      LOOP

        l_inst_rec := p_inst_tbl(l_ind);

        l_fa_qry_rec := null;

        l_fa_qry_rec.asset_id               := null;
        l_fa_qry_rec.inventory_item_id      := l_inst_rec.inventory_item_id;
        l_fa_qry_rec.book_type_code         := l_inst_rec.book_type_code;
        l_fa_qry_rec.asset_category_id      := l_inst_rec.asset_category_id;
        l_fa_qry_rec.asset_description      := l_inst_rec.asset_description;
        l_fa_qry_rec.date_placed_in_service := l_inst_rec.date_placed_in_service;
        l_fa_qry_rec.model_number           := l_inst_rec.model_number;
        l_fa_qry_rec.tag_nuber              := l_inst_rec.tag_number;
        l_fa_qry_rec.manufacturer_name      := l_inst_rec.manufacturer_name;
        l_fa_qry_rec.asset_key_ccid         := l_inst_rec.asset_key_ccid;
        l_fa_qry_rec.search_method          := l_inst_rec.search_method;

        get_fixed_assets(
          p_fa_query_rec     => l_fa_qry_rec,
          x_fixed_asset_rec  => l_fixed_asset_rec,
          x_return_status    => l_return_status,
          x_error_message    => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_fixed_asset_rec.asset_id is not null THEN

          debug('  fixed asset found. asset id : '||l_fixed_asset_rec.asset_id);

          l_fa_action := 'ADD_TO_ASSET';

          add_to_asset(
            p_asset_id           => l_fixed_asset_rec.asset_id,
            p_instance_rec       => l_inst_rec,
            x_return_status      => l_return_status,
            x_error_message      => l_error_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE

          debug('  fixed asset not found. look for pending mass addition');

          get_pending_additions(
            p_fa_query_rec     => l_fa_qry_rec,
            x_fixed_asset_rec  => l_pending_fa_rec,
            x_return_status    => l_return_status,
            x_error_message    => l_error_message);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_pending_fa_rec.mass_addition_id is not null THEN

            debug('pending add found. mass addtion id : '|| l_pending_fa_rec.mass_addition_id);

            l_fa_action := 'ADD_TO_MASS_ADDITION';

            add_to_mass_addition(
              p_mass_addition_id   => l_pending_fa_rec.mass_addition_id,
              p_instance_rec       => l_inst_rec,
              x_return_status      => l_return_status,
              x_error_message      => l_error_message);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          ELSE

            debug('  pending mass addition not found. create mass addition record');

            l_fa_action := 'CREATE_MASS_ADDITION';

            create_mass_addition(
              p_instance_rec     => l_inst_rec,
              x_mass_addition_id => l_mass_addition_id,
              x_return_status    => l_return_status,
              x_error_message    => l_error_message);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF; -- pending mass_addition is not null

        END IF; -- asset id is not null

      END LOOP;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_err_inst_rec  := l_inst_rec;
  END create_asset;

END cse_asset_creation_pkg;

/
