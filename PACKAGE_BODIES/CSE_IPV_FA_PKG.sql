--------------------------------------------------------
--  DDL for Package Body CSE_IPV_FA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_IPV_FA_PKG" AS
/* $Header: CSEIPVFB.pls 120.15.12000000.2 2007/07/06 12:58:36 dhdas ship $  */

  l_debug        varchar2(1) := NVL(fnd_profile.value('CSE_DEBUG_OPTION'),'N');

  TYPE ap_ft_rec IS RECORD (
    invoice_type               varchar2(15),
    chrg_dist_id               number,
    item_dist_id               number,
    base_amount                number,
    alloc_amount               number,
    accounting_date            date,
    inv_dist_ccid              number);

  TYPE ap_ft_tbl IS TABLE OF ap_ft_rec index by binary_integer;

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

 PROCEDURE write_report( p_message IN VARCHAR2)
 IS
 BEGIN
    IF fnd_global.conc_request_id is not null THEN
       fnd_file.put_line(fnd_file.output,p_message);
    END IF;
 END write_report;

 PROCEDURE report_output(
          --p_acct_from_date           IN DATE,
          --p_acct_to_date             IN DATE,
          p_po_header_id            IN  number,
          p_inventory_item_id       IN  number,
          p_organization_id         IN  number,
          p_include_zero_ipv         IN VARCHAR2)

  IS
Cursor c_success_count( cp_conc_request_id NUMBER ) IS
select   count(1) success_count
from     ap_invoice_distributions_all
where   request_id = cp_conc_request_id ;

Cursor c_failed_count( cp_conc_request_id NUMBER ) IS
select count(1 ) failed_count
from csi_txn_errors
where source_group_ref_id=cp_conc_request_id ;

Cursor c_Exceptions( cp_conc_request_id NUMBER ) IS
select  aia.invoice_num invoice_number,
        aida.distribution_line_number distribution_line_number,
        aida.quantity_invoiced quantity_invoiced,
        aida.base_invoice_price_variance base_invoice_price_variance,
        cte.error_text error_text
from    ap_invoices_all    aia,
        ap_invoice_distributions_all aida,
        csi_txn_errors cte
where   aida.invoice_id = aia.invoice_id
and     cte.source_id = aida.invoice_distribution_id
and     cte.source_group_ref_id = cp_conc_request_id ;

    l_message          VARCHAR2(32767);
    l_success_count    NUMBER;
    l_failed_count     NUMBER;
    l_total_count      NUMBER;
    l_Exceptions       c_Exceptions%ROWTYPE;
    l_conc_request_id  NUMBER;

  BEGIN
    IF fnd_global.conc_request_id is not null THEN
       l_conc_request_id := fnd_global.conc_request_id ;

       OPEN c_success_count(l_conc_request_id) ;
       FETCH c_success_count INTO l_success_count;
       CLOSE c_success_count ;

       OPEN c_failed_count(l_conc_request_id) ;
       FETCH c_failed_count INTO l_failed_count;
       CLOSE c_failed_count ;

       l_total_count := l_success_count + l_failed_count ;

          l_message := lpad('Report Date :',104,' ') ||to_char(sysdate);
          fnd_file.put_line(fnd_file.output,l_message);
          l_message := lpad('Invoice Adjustments to Assets',71,' ');
          Write_report(l_message);
          l_message := lpad('Summary',57,' ');
          Write_report(l_message);
          l_message := Null;
          Write_report(l_message);
          Write_report(l_message);
          Write_report(l_message);
          Write_report(l_message);
          l_message := rpad(lpad('Number Of Transactions Successfully Processed',53,' '),88,' ')||l_success_count ;
          Write_report(l_message);
          l_message := rpad(lpad('Number Of Transactions Pending or Failed',48,' '),88,' ')|| l_failed_count;
          Write_report(l_message);
          l_message := Null;
          Write_report(l_message);
          l_message := lpad(rpad('-',21,'-'),90,' ');
          Write_report(l_message);
          l_message := rpad(lpad('Total Transactions Processed',63,' '),88,' ')|| l_total_count;
          Write_report(l_message);
          l_message := Null;
          Write_report(l_message);
          Write_report(l_message);
          l_message := lpad('Report Date :',104,' ') ||to_char(sysdate);
          Write_report(l_message);
          l_message := lpad('Invoice Adjustments to Assets',71,' ');
          Write_report(l_message);
          l_message := lpad('Exception Report',57,' ');
          Write_report(l_message);

          l_message := lpad('Quantity  Base Invoice',81,' ') ;
          Write_report(l_message);

          l_message := '  Invoice Number           Distribution Line Number        Invoiced  Price Variance  Error Text' ;
          Write_report(l_message);
          l_message := '  --------------           ------------------------        --------  -------------   -----------';
          Write_report(l_message);
          l_message := Null;

          FOR l_Exceptions in c_Exceptions(l_conc_request_id )
          LOOP
           l_message := rpad( '  '||l_Exceptions.invoice_number,26,' ')||' ';
           l_message := l_message ||rpad(l_Exceptions.distribution_line_number,30,' ')||'  ';
           l_message := l_message ||rpad(to_char(l_Exceptions.quantity_invoiced),8,' ')||'  ';
           l_message := l_message ||rpad(to_char(l_Exceptions.base_invoice_price_variance),15,' ')||' ';
           l_message := l_message ||rpad(l_Exceptions.error_text,40,' ');
           Write_report(l_message);
           IF LENGTH(l_Exceptions.invoice_number) > 24 OR
              LENGTH(l_Exceptions.distribution_line_number) > 30 OR
              LENGTH(l_Exceptions.error_text) > 40 THEN

              l_message := rpad( '  '||substr(l_Exceptions.invoice_number,26),26,' ')||' ';
              l_message := l_message ||rpad(substr(l_Exceptions.distribution_line_number,30),30,' ')||'  ';
              l_message := l_message ||rpad(' ',8,' ')||'  ';
              l_message := l_message ||rpad(' ',15,' ')||' ';
              l_message := l_message ||rpad(substr(l_Exceptions.error_text,40),40,' ');
              Write_report(l_message);
           END IF;
          END LOOP;
           l_message := Null;
           Write_report(l_message);
           Write_report(l_message);
           l_message := '  Report Parameter:                        Value:';
           Write_report(l_message);
            l_message := '   PO Number  :  '||p_po_header_id;
           Write_report(l_message);
           l_message := '   Inventory Item  :  '||p_inventory_item_id;
           Write_report(l_message);
           l_message := '   Organization :  '||p_organization_id;
           Write_report(l_message);
           l_message := '  Include Zero IPV  : '||p_include_zero_ipv;
           Write_report(l_message);
           l_message := Null;
           Write_report(l_message);

    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END report_output;

  PROCEDURE interface_to_fa(
    p_invoice_rec             IN            invoice_rec,
    x_processed_flag             OUT NOCOPY varchar2,
    x_return_status              OUT NOCOPY varchar2)
  IS

    l_total_asset_units       number := 0;
    l_total_pending_units     number := 0;
    l_per_unit_ipv            number;
    l_units                   number;
    l_asset_description       varchar2(240);
    l_asset_category_id       number;
    l_book_type_code          varchar2(30);
    l_date_placed_in_service  date;
    l_expense_ccid            number;

    l_allocated_ipv           number;
    l_link_found              boolean := FALSE;

    l_ind                     binary_integer := 0;
    l_ma_proc_tbl             ma_process_tbl;
    l_mass_add_rec            fa_mass_additions%rowtype;
    l_asset_attrib_rec        cse_datastructures_pub.asset_attrib_rec;
    l_dflt_book_type_code     varchar2(30);

    l_error_message           varchar2(2000);
    l_return_status           varchar2(1);
    l_msg_data                varchar2(2000);
    l_msg_count               number;
    l_conc_request_id  NUMBER;
    l_txn_error_rec            csi_datastructures_pub.transaction_error_rec;
    l_transaction_error_Id     NUMBER;
    -- get the po rcpt txns that are already processed to fa
    CURSOR csi_txn_cur(p_po_dist_id IN number) IS
      SELECT transaction_id,
             inv_material_transaction_id,
             transaction_quantity,
             transaction_uom_code
      FROM   csi_transactions
      WHERE  source_dist_ref_id1     = p_po_dist_id
      AND    transaction_type_id    IN (105, 112) -- po rcpt in to proj/inv
      AND    transaction_status_code = 'COMPLETE';

    -- for po receipt transactions we always create/update destination instance
    -- there is no concept of source instance
    CURSOR asset_cur(p_csi_txn_id IN number, p_po_dist_id in number) IS
      SELECT cia.fa_asset_id         fa_id,
             cia.fa_book_type_code   fa_book_type_code,
             'FA'                    fa_state
      FROM   csi_i_assets         cia,
             csi_item_instances_h ciih
      WHERE  ciih.transaction_id = p_csi_txn_id
      AND    cia.instance_id = ciih.instance_id
      AND    cia.fa_asset_id is not null
      AND EXISTS (
             SELECT 1 FROM fa_asset_invoices fai
             WHERE  fai.asset_id = cia.fa_asset_id
             AND    fai.feeder_system_name = cse_asset_util_pkg.g_fa_feeder_name
             AND    fai.po_distribution_id = p_po_dist_id)
      UNION
      SELECT cia.fa_mass_addition_id fa_id,
             cia.fa_book_type_code   fa_book_type_code,
             'FMA'                   fa_state
      FROM   csi_i_assets         cia,
             csi_item_instances_h ciih
      WHERE  ciih.transaction_id = p_csi_txn_id
      AND    cia.instance_id = ciih.instance_id
      AND    cia.fa_asset_id is null
      AND    EXISTS (
               SELECT 1 FROM fa_mass_additions fma
               WHERE  fma.mass_addition_id = cia.fa_mass_addition_id
               AND    fma.feeder_system_name = cse_asset_util_pkg.g_fa_feeder_name
               AND    fma.po_distribution_id = p_po_dist_id);

    CURSOR fma_cur(p_csi_txn_id IN number, p_book_type_code in VARCHAR2) IS
      SELECT fma.mass_addition_id,
             fma.description,
             fma.asset_category_id,
             fma.book_type_code,
             fma.date_placed_in_service,
             fmd.units
      FROM   csi_item_instances_h     ciih,
             fa_mass_additions        fma,
             fa_massadd_distributions fmd
      WHERE  ciih.transaction_id    = p_csi_txn_id
      AND    fma.reviewer_comments  = to_char(ciih.instance_id)
      AND    fma.feeder_system_name = cse_asset_util_pkg.g_fa_feeder_name
      AND    fma.posting_status    <> 'POSTED'
      AND    fma.book_type_code    = p_book_type_code
      AND    fma.add_to_asset_id   IS null
      AND    fma.split_merged_code  = 'MP'
      AND    fmd.mass_addition_id   = fma.mass_addition_id;

  BEGIN

    debug('inside interface_to_fa');
	 IF fnd_global.conc_request_id is not null THEN
        l_conc_request_id := fnd_global.conc_request_id ;
     END IF;
    x_return_status := fnd_api.g_ret_sts_success;

    FOR csi_txn_rec IN csi_txn_cur(p_invoice_rec.po_dist_id)
    LOOP

      debug('  csi_transaction_id     : '||csi_txn_rec.transaction_id);

      l_asset_attrib_rec.transaction_id    := csi_txn_rec.transaction_id;
      l_asset_attrib_rec.inventory_item_id := p_invoice_rec.inventory_item_id;
      l_asset_attrib_rec.organization_id   := p_invoice_rec.organization_id;

      l_expense_ccid := cse_asset_util_pkg.deprn_expense_ccid(
                          p_asset_attrib_rec => l_asset_attrib_rec,
                          x_error_msg        => l_error_message,
                          x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      debug('  deprn_expense_ccid     : '||l_expense_ccid);

      SELECT fnd_profile.value('CSE_FA_BOOK_TYPE_CODE')
      INTO   l_dflt_book_type_code
      FROM   sys.dual;

      FOR asset_rec in asset_cur(csi_txn_rec.transaction_id, p_invoice_rec.po_dist_id)
      LOOP

        l_link_found := TRUE;

        debug('  asset_rec.fa_state     : '||asset_rec.fa_state);

        IF asset_rec.fa_state = 'FA' THEN

          debug('  asset_rec.fa_id        : '||asset_rec.fa_id);

          -- cost adj case
          SELECT current_units,
                 description,
                 asset_category_id
          INTO   l_units,
                 l_asset_description,
                 l_asset_category_id
          FROM   fa_additions
          WHERE  asset_id = asset_rec.fa_id;

          debug('  asset_description      : '||l_asset_description);

          SELECT date_placed_in_service
          INTO   l_date_placed_in_service
          FROM   fa_books
          WHERE  asset_id       = asset_rec.fa_id
          AND    book_type_code = asset_rec.fa_book_type_code
          AND    date_ineffective is  NULL;

          debug('  date_placed_in_service : '||l_date_placed_in_service);

          l_total_asset_units := l_total_asset_units + l_units;

          l_ind := l_ind + 1;
          l_ma_proc_tbl(l_ind).asset_id               := asset_rec.fa_id;
          l_ma_proc_tbl(l_ind).mass_addition_id       := null;
          l_ma_proc_tbl(l_ind).book_type_code         := asset_rec.fa_book_type_code;
          l_ma_proc_tbl(l_ind).asset_category_id      := l_asset_category_id;
          l_ma_proc_tbl(l_ind).units                  := l_units;
          l_ma_proc_tbl(l_ind).description            := l_asset_description;
          l_ma_proc_tbl(l_ind).date_placed_in_service := l_date_placed_in_service;
          l_ma_proc_tbl(l_ind).expense_ccid           := l_expense_ccid;

        ELSIF asset_rec.fa_state = 'FMA' THEN

          -- merge case pending in fma.
          SELECT description,
                 asset_category_id,
                 book_type_code,
                 date_placed_in_service
          INTO   l_asset_description,
                 l_asset_category_id,
                 l_book_type_code,
                 l_date_placed_in_service
          FROM   fa_mass_additions
          WHERE  mass_addition_id = asset_rec.fa_id;

          SELECT units
          INTO   l_units
          FROM   fa_massadd_distributions
          WHERE  mass_addition_id = asset_rec.fa_id;

          l_total_pending_units := l_total_pending_units + l_units;

          l_ind := l_ind + 1;
          l_ma_proc_tbl(l_ind).asset_id               := null;
          l_ma_proc_tbl(l_ind).mass_addition_id       := asset_rec.fa_id;
          l_ma_proc_tbl(l_ind).book_type_code         := l_book_type_code;
          l_ma_proc_tbl(l_ind).asset_category_id      := l_asset_category_id;
          l_ma_proc_tbl(l_ind).units                  := l_units;
          l_ma_proc_tbl(l_ind).description            := l_asset_description;
          l_ma_proc_tbl(l_ind).date_placed_in_service := l_date_placed_in_service;
          l_ma_proc_tbl(l_ind).expense_ccid           := l_expense_ccid;

        END IF;

      END LOOP; -- cia loop

      -- this is to address the pending data in fma prior to r12
      IF NOT(l_link_found) THEN
        FOR fma_rec IN fma_cur(csi_txn_rec.transaction_id, l_dflt_book_type_code)
        LOOP

          l_link_found := TRUE;

          l_total_pending_units := l_total_pending_units + l_units;

          l_ind := l_ind + 1;
          l_ma_proc_tbl(l_ind).asset_id               := null;
          l_ma_proc_tbl(l_ind).mass_addition_id       := fma_rec.mass_addition_id;
          l_ma_proc_tbl(l_ind).book_type_code         := fma_rec.book_type_code;
          l_ma_proc_tbl(l_ind).asset_category_id      := fma_rec.asset_category_id;
          l_ma_proc_tbl(l_ind).units                  := fma_rec.units;
          l_ma_proc_tbl(l_ind).description            := fma_rec.description;
          l_ma_proc_tbl(l_ind).date_placed_in_service := fma_rec.date_placed_in_service;
          l_ma_proc_tbl(l_ind).expense_ccid           := l_expense_ccid;

        END LOOP;
      END IF;

      IF l_ma_proc_tbl.COUNT > 0 THEN
        FOR ma_ind IN l_ma_proc_tbl.FIRST .. l_ma_proc_tbl.LAST
        LOOP

          l_mass_add_rec := null;

          IF l_ma_proc_tbl(ma_ind).asset_id IS NOT null THEN
            l_mass_add_rec.add_to_asset_id                := l_ma_proc_tbl(ma_ind).asset_id;
            l_mass_add_rec.posting_status                 := 'POST';
            l_mass_add_rec.queue_name                     := 'ADD TO ASSET';
            l_per_unit_ipv := p_invoice_rec.invoice_price_variance/l_total_asset_units;
          END IF;

          IF l_ma_proc_tbl(ma_ind).mass_addition_id IS NOT null THEN
            l_mass_add_rec.parent_mass_addition_id        := l_ma_proc_tbl(ma_ind).mass_addition_id;
            l_mass_add_rec.merge_parent_mass_additions_id := l_ma_proc_tbl(ma_ind).mass_addition_id;
            l_mass_add_rec.queue_name                     := 'POST';
            l_mass_add_rec.posting_status                 := 'MERGED';
            l_mass_add_rec.split_merged_code              := 'MC';
            l_mass_add_rec.merged_code                    := 'MC';
            l_per_unit_ipv := p_invoice_rec.invoice_price_variance/l_total_pending_units;
          END IF;

          l_allocated_ipv                             := l_ma_proc_tbl(ma_ind).units * l_per_unit_ipv;

          l_mass_add_rec.book_type_code               := l_ma_proc_tbl(ma_ind).book_type_code;
          l_mass_add_rec.asset_category_id            := l_ma_proc_tbl(ma_ind).asset_category_id;
          l_mass_add_rec.description                  := l_ma_proc_tbl(ma_ind).description;
          l_mass_add_rec.expense_code_combination_id  := l_ma_proc_tbl(ma_ind).expense_ccid;
          l_mass_add_rec.payables_code_combination_id := p_invoice_rec.payables_ccid;
          l_mass_add_rec.ap_distribution_line_number  := p_invoice_rec.invoice_dist_line_num;
          l_mass_add_rec.po_number                    := p_invoice_rec.po_num;
          l_mass_add_rec.po_vendor_id                 := p_invoice_rec.po_vendor_id;
          l_mass_add_rec.invoice_number               := p_invoice_rec.invoice_num;
          l_mass_add_rec.invoice_id                   := p_invoice_rec.invoice_id;
          --
          l_mass_add_rec.payables_cost                := l_allocated_ipv;
          l_mass_add_rec.fixed_assets_cost            := l_allocated_ipv;
          l_mass_add_rec.fixed_assets_units           := 1;
          --
          l_mass_add_rec.feeder_system_name           := cse_asset_util_pkg.g_fa_feeder_name;
          l_mass_add_rec.reviewer_comments            := 'IPV' ;
          l_mass_add_rec.asset_type                   := 'CAPITALIZED';
          l_mass_add_rec.depreciate_flag              := 'YES' ;
          l_mass_add_rec.creation_date                := sysdate;
          l_mass_add_rec.last_update_date             := sysdate;
          l_mass_add_rec.created_by                   := fnd_global.user_id;
          l_mass_add_rec.last_updated_by              := fnd_global.user_id;
          l_mass_add_rec.last_update_login            := fnd_global.login_id;

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

          x_processed_flag := 'Y';

        END LOOP;
      END IF;

    END LOOP; -- csi_txn_loop;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      l_error_message := nvl(l_error_message, cse_util_pkg.dump_error_stack);
      debug('Error : '||l_error_message);
      x_return_status  := fnd_api.g_ret_sts_error;
      x_processed_flag := 'N';
       l_txn_error_rec := cse_util_pkg.init_txn_error_rec;
            l_txn_error_rec.error_text  := l_error_message;
            l_txn_error_rec.source_group_ref_id  := l_conc_request_id;
            l_txn_error_rec.source_type := 'AP_INVOICE_DISTRIBUTIONS_ALL';
            l_txn_error_rec.source_id   := p_invoice_rec.invoice_dist_id;
            l_txn_error_rec.processed_flag := 'N';
      csi_transactions_pvt.create_txn_error(
        p_api_version          => 1.0,
        p_init_msg_list         => fnd_api.g_true,
        p_commit                => fnd_api.g_false,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_txn_error_rec         => l_txn_error_rec,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_transaction_error_id  => l_transaction_error_id);
  END interface_to_fa ;

  PROCEDURE process_ipv_to_fa(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_po_header_id            IN         number,
    p_inventory_item_id       IN         number,
    p_organization_id         IN         number,
    p_include_zero_ipv        IN         varchar2)
  IS

    l_ib_trackable_flag       varchar2(1);
    l_asset_creation_code     varchar2(1);
    l_conc_request_id         number := fnd_global.conc_request_id;
    l_processed_flag          varchar2(1);
    l_invoice_rec             invoice_rec;
    l_payables_ccid           number;

    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;

    l_txn_error_rec            csi_datastructures_pub.transaction_error_rec;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_transaction_error_Id     NUMBER;
    l_invoice_distribution_id  NUMBER;

    CURSOR invoice_cur IS
      SELECT aida.invoice_id,
             aida.distribution_line_number,
             aida.unit_price,
             aila.quantity_invoiced ,
             aida.invoice_distribution_id,
             aida.po_distribution_id,
             aia.invoice_num,
             nvl(aida.amount, 0) price_variance,
             aila.inventory_item_id,
             aila.org_id
      FROM   ap_invoice_distributions_all aida,
             ap_invoice_lines_all aila,
             ap_invoices_all aia
      WHERE  aida.line_type_lookup_code = 'IPV'
      AND    aida.posted_flag           = 'Y'
      AND    aida.assets_addition_flag  IN ('U','I','N')
      --AND    NVL(aida.assets_tracking_flag,'x') = 'Y'
      AND    aida.po_distribution_id           is not null
      AND    aila.invoice_id            = aida.invoice_id
      AND    aila.line_number           = aida.invoice_line_number
      AND    aila.inventory_item_id     = nvl(p_inventory_item_id, aila.inventory_item_id)
      AND    aia.invoice_id             = aida.invoice_id
      AND    EXISTS (
        SELECT '1'
        FROM   csi_transactions ct
        WHERE  ct.transaction_type_id     in (105, 112)
        AND    ct.transaction_status_code = 'COMPLETE'
        AND    ct.source_dist_ref_id1     = aida.po_distribution_id)
      AND    EXISTS (
        SELECT '1'
        FROM   po_distributions_all pod
        WHERE  pod.po_distribution_id = aida.po_distribution_id
        AND    pod.po_header_id       = nvl(p_po_header_id,pod.po_header_id)
        AND    pod.destination_organization_id = nvl(p_organization_id, pod.destination_organization_id));

    PROCEDURE get_freight_and_tax(
      p_item_dist_id  IN  number,
      p_invoice_id    IN  number,
      p_project_id    IN  number,
      p_task_id       IN  number,
      x_ft_amount     OUT nocopy number,
      px_ap_ft_tbl    OUT nocopy ap_ft_tbl)
    IS

      l_ft_amount        number         := 0;
      l_alloc_ft_amount  number         := 0;
      l_ind              binary_integer := 0;

      CURSOR ft_cur IS
        SELECT aida.line_type_lookup_code     invoice_distribution_type,
               aida.invoice_distribution_id,
               aida.invoice_line_number,
               aia.invoice_type_lookup_code   invoice_type,
               nvl(aida.amount,0)             base_amount,
               aida.accounting_date,
               aida.dist_code_combination_id  inv_dist_ccid
        FROM   ap_invoice_distributions_all aida,
               ap_invoices_all              aia
        WHERE  aida.invoice_id                     = p_invoice_id
        AND    aida.project_id                     = p_project_id
        AND    aida.task_id                        = p_task_id
        AND    aida.line_type_lookup_code IN ('FREIGHT', 'TAX', 'NONREC_TAX')
        AND    aida.posted_flag                    = 'Y'
        AND    aida.pa_addition_flag               = 'N'
        AND    nvl(aida.reversal_flag, 'N')       <> 'Y'
        AND    nvl(aida.tax_recoverable_flag, 'N') = 'N'
        AND    aia.invoice_id                      = aida.invoice_id
        AND    exists (
          SELECT 'x' FROM ap_chrg_allocations_all
          WHERE  item_dist_id   = p_item_dist_id
          AND    charge_dist_id = aida.invoice_distribution_id);

      FUNCTION allocated_amount (pf_item_dist_id IN number, pf_charge_dist_id IN number)
      RETURN   number
      IS
        l_alloc_amount   number := 0;
        CURSOR chrg_alloc_cur IS
          SELECT allocated_amount
          FROM   ap_chrg_allocations_all
          WHERE  item_dist_id   = pf_item_dist_id
          AND    charge_dist_id = pf_charge_dist_id;
      BEGIN
        FOR chrg_alloc_rec IN chrg_alloc_cur
        LOOP
          l_alloc_amount := l_alloc_amount + chrg_alloc_rec.allocated_amount;
        END LOOP;
        RETURN l_alloc_amount;
      END allocated_amount;

    BEGIN
      debug('Inside API get_freight_and_tax');
      FOR ft_rec IN ft_cur
      LOOP
        debug('  invoice_dist_id    : '||ft_rec.invoice_distribution_id);
        debug('  line_type          : '||ft_rec.invoice_type);
        debug('  base_amount        : '||ft_rec.base_amount);

        l_ind := px_ap_ft_tbl.COUNT + 1;
        px_ap_ft_tbl(l_ind).invoice_type            := ft_rec.invoice_type;
        px_ap_ft_tbl(l_ind).chrg_dist_id            := ft_rec.invoice_distribution_id;
        px_ap_ft_tbl(l_ind).item_dist_id            := p_item_dist_id;
        px_ap_ft_tbl(l_ind).base_amount             := ft_rec.base_amount;
        px_ap_ft_tbl(l_ind).accounting_date         := ft_rec.accounting_date;
        px_ap_ft_tbl(l_ind).inv_dist_ccid           := ft_rec.inv_dist_ccid;

        l_alloc_ft_amount := allocated_amount(p_item_dist_id, ft_rec.invoice_distribution_id);
        debug('  allocated_amount       : '||l_alloc_ft_amount);
        px_ap_ft_tbl(l_ind).alloc_amount            := l_alloc_ft_amount;

        l_ft_amount := l_ft_amount + l_alloc_ft_amount;
      END LOOP;
      x_ft_amount := l_ft_amount;
      debug('TOTAL freight and tax amount         : '||l_ft_amount);
    END get_freight_and_tax;

  BEGIN

    cse_util_pkg.set_debug;

    debug('Inside API cse_ipv_fa_pkg.process_ipv_to_fa');
    debug('  param.inv_item_id      : '||p_inventory_item_id);
    debug('  param.inv_org_id       : '||p_organization_id);
    debug('  param.po_header_id     : '||p_po_header_id);
    debug('  param.include_zero_ipv : '||p_include_zero_ipv);

    FOR invoice_rec IN invoice_cur
    LOOP

      debug('processing record # '||invoice_cur%rowcount);
      mo_global.set_policy_context('S', invoice_rec.org_id);

      l_processed_flag := 'N';

      BEGIN

        debug('  invoice_dist_id        : '||invoice_rec.invoice_distribution_id);
        debug('  invoice_dist_line_num  : '||invoice_rec.distribution_line_number);
        debug('  invoice_id             : '||invoice_rec.invoice_id);
        debug('  price_variance         : '||invoice_rec.price_variance);
	l_invoice_distribution_id            := invoice_rec.invoice_distribution_id;
        l_invoice_rec.invoice_dist_id        := invoice_rec.invoice_distribution_id;
        l_invoice_rec.invoice_dist_line_num  := invoice_rec.distribution_line_number;
        l_invoice_rec.invoice_id             := invoice_rec.invoice_id;
        l_invoice_rec.invoice_num            := invoice_rec.invoice_num;
        l_invoice_rec.po_dist_id             := invoice_rec.po_distribution_id;
        l_invoice_rec.invoice_price_variance := invoice_rec.price_variance;
        l_invoice_rec.unit_price             := invoice_rec.unit_price;

        -- Added for bug 5255658
	IF NVL(invoice_rec.quantity_invoiced,0) =0 THEN
          l_invoice_rec.quantity_invoiced      := null;
        ELSE
          l_invoice_rec.quantity_invoiced      := invoice_rec.quantity_invoiced;
        END IF;

        SELECT pol.item_id,
               pod.destination_organization_id,
               pod.variance_account_id,
               poh.segment1,
               poh.vendor_id
        INTO   l_invoice_rec.inventory_item_id,
               l_invoice_rec.organization_id,
               l_invoice_rec.payables_ccid,
               l_invoice_rec.po_num,
               l_invoice_rec.po_vendor_id
        FROM   po_distributions_all pod,
               po_lines_all         pol,
               po_headers_all       poh
        WHERE  pod.po_distribution_id = invoice_rec.po_distribution_id
        AND    pol.po_line_id         = pod.po_line_id
        AND    poh.po_header_id       = pol.po_header_id;

        l_payables_ccid := cse_asset_util_pkg.get_ap_sla_acct_id(
                             p_invoice_id        => invoice_rec.invoice_id,
                             p_invoice_dist_type => 'IPV');

        debug('  price_variance_ccid    : '||l_payables_ccid);

        l_invoice_rec.payables_ccid := nvl(l_payables_ccid, l_invoice_rec.payables_ccid);

        IF l_invoice_rec.inventory_item_id is not null
           AND
           l_invoice_rec.organization_id is not null
        THEN

          SELECT nvl(comms_nl_trackable_flag, 'N'),
                 nvl(asset_creation_code, '0')
          INTO   l_ib_trackable_flag,
                 l_asset_creation_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = l_invoice_rec.inventory_item_id
          AND    organization_id   = l_invoice_rec.organization_id;

          IF l_ib_trackable_flag = 'Y' AND l_asset_creation_code in ('1', 'Y') THEN

            debug('  po_distribution_id     : '|| invoice_rec.po_distribution_id);
            debug('  inventory_item_id      : '||l_invoice_rec.inventory_item_id);
            debug('  organization_id        : '||l_invoice_rec.organization_id);

            interface_to_fa(
              p_invoice_rec     => l_invoice_rec,
              x_processed_flag  => l_processed_flag,
              x_return_status   => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF; -- item based, ib tracked and depreciable

        END IF; -- pol.inventory_item_is is not null;

        IF l_processed_flag = 'Y' THEN
          UPDATE ap_invoice_distributions_all
          SET    assets_addition_flag    = 'Y',
                 request_id              = l_conc_request_id
          WHERE  invoice_distribution_id = invoice_rec.invoice_distribution_id
          AND    assets_addition_flag    <>'Y';

          debug('invoice_distribution_id  : '||invoice_rec.invoice_distribution_id);
          debug('processed successfully. updating ap_invoice_distributions_all.assets_addition_flag = Y');
        END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          --null;
	   l_txn_error_rec := cse_util_pkg.init_txn_error_rec;
            l_txn_error_rec.error_text  := SQLERRM;
            l_txn_error_rec.source_group_ref_id  := l_conc_request_id;
            l_txn_error_rec.source_type := 'AP_INVOICE_DISTRIBUTIONS_ALL';
            l_txn_error_rec.source_id   := invoice_rec.invoice_distribution_id;
            l_txn_error_rec.processed_flag := 'N';
      csi_transactions_pvt.create_txn_error(
        p_api_version          => 1.0,
        p_init_msg_list         => fnd_api.g_true,
        p_commit                => fnd_api.g_false,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_txn_error_rec         => l_txn_error_rec,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_transaction_error_id  => l_transaction_error_id);
      END;

    END LOOP;
	 --for successful
    Report_OutPut( p_po_header_id => p_po_header_id,
                    p_inventory_item_id   => p_inventory_item_id,
                    p_organization_id => p_organization_id,
                    p_include_zero_ipv  => p_include_zero_ipv );
    EXCEPTION
        WHEN OTHERS THEN
            l_txn_error_rec := cse_util_pkg.init_txn_error_rec;
            l_txn_error_rec.error_text  := SQLERRM;
            l_txn_error_rec.source_group_ref_id  := l_conc_request_id;
            l_txn_error_rec.source_type := 'AP_INVOICE_DISTRIBUTIONS_ALL';
            l_txn_error_rec.source_id   := l_invoice_distribution_id;
            l_txn_error_rec.processed_flag := 'N';
      csi_transactions_pvt.create_txn_error(
        p_api_version          => 1.0,
        p_init_msg_list         => fnd_api.g_true,
        p_commit                => fnd_api.g_false,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_txn_error_rec         => l_txn_error_rec,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_transaction_error_id  => l_transaction_error_id);
        Report_OutPut( p_po_header_id => p_po_header_id,
                    p_inventory_item_id   => p_inventory_item_id,
                    p_organization_id => p_organization_id,
                    p_include_zero_ipv  => p_include_zero_ipv );

  END process_ipv_to_fa;

END cse_ipv_fa_pkg;

/
