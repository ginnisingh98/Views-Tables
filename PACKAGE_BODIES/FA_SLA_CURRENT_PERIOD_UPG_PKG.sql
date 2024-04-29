--------------------------------------------------------
--  DDL for Package Body FA_SLA_CURRENT_PERIOD_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SLA_CURRENT_PERIOD_UPG_PKG" as
/* $Header: FACPUPGB.pls 120.23.12010000.3 2009/07/19 12:22:31 glchen ship $   */

Procedure Upgrade_Addition (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
             ,p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) IS

c_upgrade_bugno             constant number(15) := -4107161;
c_fnd_user                  constant number(15) := 2;

-- this value can be altered in order to process more of less per batch
l_batch_size                NUMBER;

l_rows_processed            NUMBER;

l_precision                 NUMBER;

   cursor c_additions is
   select /*+ leading(th) rowid(th) */
          th.transaction_header_id   ,
          th.asset_id                ,
          th.book_type_code          ,
          th.transaction_type_code   ,
          bk.cost                    ,
          ad.asset_category_id       ,
          ad.asset_type              ,
          ad.current_units           ,
          bc.set_of_books_id
   from   fa_transaction_headers th,
          fa_deprn_periods dp,
          fa_books bk,
          fa_category_books cb,
          fa_additions_b ad,
          fa_book_controls bc
   where  th.rowid between p_start_rowid and p_end_rowid
   and    th.book_type_code = dp.book_type_code
   and    th.date_effective > dp.period_open_date
   and    dp.period_close_date is null
   and    dp.book_type_code = bc.book_type_code
   and    bc.book_class <> 'BUDGET'
   and    bc.date_ineffective is null
   and    bc.book_type_code = cb.book_type_code
   and    ad.asset_category_id = cb.category_id
   and    th.transaction_type_code in ('ADDITION', 'CIP ADDITION')
   and    th.transaction_header_id = bk.transaction_header_id_in
   and    bk.cost <> 0
   and    th.asset_id = ad.asset_id
   and not exists (select 'x'
                   from   fa_adjustments aj
                   where  aj.asset_id = th.asset_id
                   and    aj.book_type_code = th.book_type_code
                   and    aj.transaction_header_id = th.transaction_header_id
                   and    aj.adjustment_type like '%COST');

   cursor c_invoices (p_asset_id number) is
   select AI.Payables_Code_Combination_ID,
          NVL(AI.Payables_Cost, 0),
          AI.Asset_Invoice_ID,
          AI.source_line_id
     FROM FA_ASSET_INVOICES AI
    WHERE AI.ASSET_ID = p_asset_id
      AND AI.Payables_Code_Combination_ID IS NOT NULL
      AND AI.Date_Ineffective IS NULL
    ORDER BY AI.Payables_Code_Combination_ID,
             AI.PO_Vendor_ID,
             AI.Invoice_Number;

   TYPE tab_varchar  IS TABLE OF varchar2(150) INDEX BY BINARY_INTEGER;
   TYPE tab_number   IS TABLE OF number        INDEX BY BINARY_INTEGER;

   -- for bulk collect
   l_thid              tab_number;
   l_asset_id          tab_number;
   l_book_type_code    tab_varchar;
   l_trx_type_code     tab_varchar;
   l_cost              tab_number;
   l_category_id       tab_number;
   l_asset_type        tab_varchar;
   l_current_units     tab_number;
   l_set_of_books_id   tab_number;

   l_payables_ccid     tab_number;
   l_payables_cost     tab_number;
   l_asset_invoice_id  tab_number;
   l_source_line_id    tab_number;

   l_sum_payables_cost  number := 0;
   l_clearing_to_insert number := 0;
   l_mrc_sob_type_code  varchar2(1) := 'P';

   -- for api callouts
   l_trans_rec         fa_api_types.trans_rec_type;
   l_asset_hdr_rec     fa_api_types.asset_hdr_rec_type;
   l_asset_desc_rec    fa_api_types.asset_desc_rec_type;
   l_asset_cat_rec     fa_api_types.asset_cat_rec_type;
   l_asset_type_rec    fa_api_types.asset_type_rec_type;

   l_adj               fa_adjust_type_pkg.fa_adj_row_struct;
   l_calling_fn        varchar2(35) := 'FACPUPGB.Upgrade_Addition';
   l_log_level_rec     FA_API_TYPES.log_level_rec_type;

   error_found         exception;

BEGIN

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   loop

     OPEN c_additions;

     FETCH c_additions BULK COLLECT
      INTO   l_thid              ,
             l_asset_id          ,
             l_book_type_code    ,
             l_trx_type_code     ,
             l_cost              ,
             l_category_id       ,
             l_asset_type        ,
             l_current_units     ,
             l_set_of_books_id
     LIMIT l_batch_size;
     CLOSE c_additions;

     l_rows_processed := l_thid.count;

     l_trans_rec.who_info.last_update_date := sysdate;
     l_trans_rec.who_info.last_updated_by := c_upgrade_bugno;
     l_trans_rec.who_info.last_update_login := c_upgrade_bugno;

     for i in 1..l_thid.count loop

	 --Added for bug# 5213257
	 fnd_profile.put('GL_SET_OF_BKS_ID', l_set_of_books_id(i));
         fnd_client_info.set_currency_context (l_set_of_books_id(i));

	 -- call the cache
         if not (fa_cache_pkg.fazcbc(x_book => l_book_type_code(i))) then
            raise error_found;
         end if;

         -- load the api rec types
         l_trans_rec.transaction_header_id      := l_thid (i);
         l_asset_hdr_rec.asset_id               := l_asset_id(i);
         l_asset_hdr_rec.book_type_code         := l_book_type_code(i);
         l_trans_rec.transaction_type_code      := l_trx_type_code(i);
         l_asset_cat_rec.category_id            := l_category_id(i);
         l_asset_type_rec.asset_type            := l_asset_type(i);
         l_asset_desc_rec.current_units         := l_current_units(i);

         l_adj.transaction_header_id    := l_thid (i);
         l_adj.asset_id                 := l_asset_id(i);
         l_adj.book_type_code           := l_book_type_code(i);
         l_adj.period_counter_created   :=
               fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.period_counter_adjusted  :=
               fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.current_units            := l_current_units(i) ;
         l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.selection_thid           := 0;
         l_adj.selection_retid          := 0;
         l_adj.leveling_flag            := TRUE;
         l_adj.last_update_date         :=
               l_trans_rec.who_info.last_update_date;

         l_adj.flush_adj_flag           := FALSE;
         l_adj.gen_ccid_flag            := FALSE;
         l_adj.annualized_adjustment    := 0;
         l_adj.distribution_id          := 0;

         l_adj.adjustment_type          := 'COST CLEARING';
         l_adj.source_type_code         := l_trx_type_code(i);
         l_adj.mrc_sob_type_code        := 'P';

         if l_asset_type(i) = 'CIP' then
            l_adj.account_type     := 'CIP_CLEARING_ACCT';
         else
            l_adj.account_type     := 'ASSET_CLEARING_ACCT';
         end if;

         /* commented for bug# 5213257
	 fnd_profile.put('GL_SET_OF_BKS_ID', l_set_of_books_id(i));
         fnd_client_info.set_currency_context (l_set_of_books_id(i)); */

         l_sum_payables_cost := 0;

         -- process invoices first
         OPEN c_invoices (p_asset_id => l_asset_id(i));

         FETCH c_invoices BULK COLLECT
          INTO l_payables_ccid     ,
               l_payables_cost     ,
               l_asset_invoice_id  ,
               l_source_line_id    ;

         CLOSE c_invoices;

         for x in 1..l_payables_ccid.count loop

            l_sum_payables_cost       := l_sum_payables_cost +
                                         l_payables_cost(x);

            l_adj.asset_invoice_id    := l_asset_invoice_id(x);
            l_adj.source_line_id      := l_source_line_id(x);
            l_adj.code_combination_id := l_payables_ccid(x);

            if l_payables_cost(x) > 0 then
               l_adj.debit_credit_flag   := 'CR';
               l_adj.adjustment_amount   := l_payables_cost(x);
            else
               l_adj.debit_credit_flag   := 'DR';
               l_adj.adjustment_amount   := -l_payables_cost(x);
            end if;

            if not FA_INS_ADJUST_PKG.faxinaj
               (l_adj,
                l_trans_rec.who_info.last_update_date,
                l_trans_rec.who_info.last_updated_by,
                l_trans_rec.who_info.last_update_login,
                l_log_level_rec) then
               raise error_found;
            end if;

         end loop;

         -- now calc difference between invoice total and
         l_clearing_to_insert := l_cost(i) - l_sum_payables_cost;

         -- now insert cost, etc

         if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec         => l_trans_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_desc_rec    => l_asset_desc_rec,
                      p_asset_cat_rec     => l_asset_cat_rec,
                      p_asset_type_rec    => l_asset_type_rec,
                      p_cost              => l_cost(i),
                      p_clearing          => l_clearing_to_insert,
                      p_deprn_expense     => 0,
                      p_bonus_expense     => 0,
                      p_impair_expense    => 0,
                      p_ann_adj_amt       => 0,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn,
                      p_log_level_rec     => l_log_level_rec
                    ) then
            raise error_found;
         end if;

      end loop; -- additions

      -- flush remaining rows
      l_adj.transaction_header_id := 0;
      l_adj.flush_adj_flag        := TRUE;
      l_adj.leveling_flag         := TRUE;

      if not FA_INS_ADJUST_PKG.faxinaj
             (l_adj,
              l_trans_rec.who_info.last_update_date,
              l_trans_rec.who_info.last_updated_by,
              l_trans_rec.who_info.last_update_login,
              l_log_level_rec) then

          raise error_found;
      end if;

      COMMIT;

      l_thid.delete;
      l_asset_id.delete;
      l_book_type_code.delete;
      l_trx_type_code.delete;
      l_cost.delete;
      l_category_id.delete;
      l_asset_type.delete;
      l_current_units.delete;
      l_set_of_books_id.delete;
      l_payables_ccid.delete;
      l_payables_cost.delete;
      l_asset_invoice_id.delete;
      l_source_line_id.delete;

      if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;

EXCEPTION
   when error_found then
        if (c_additions%ISOPEN) then
           close c_additions;
        end if;
        rollback;
        raise;
/*
   when others then
        close c_additions;
        rollback;
        --raise;
*/
END Upgrade_Addition;

Procedure Upgrade_Addition_MRC (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
             ,p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) IS

c_upgrade_bugno             constant number(15) := -4107161;
c_fnd_user                  constant number(15) := 2;

-- this value can be altered in order to process more of less per batch
l_batch_size                NUMBER;

l_rows_processed            NUMBER;

l_precision                 NUMBER;

   cursor c_additions_mrc is
   select /*+ leading(th) rowid(th) */
          th.transaction_header_id   ,
          th.asset_id                ,
          th.book_type_code          ,
          th.transaction_type_code   ,
          bk.cost                    ,
          ad.asset_category_id       ,
          ad.asset_type              ,
          ad.current_units           ,
          mcbc.set_of_books_id
   from   fa_transaction_headers th,
          fa_mc_deprn_periods dp,
          fa_mc_books bk,
          fa_additions_b ad,
          fa_category_books cb,
          fa_book_controls bc,
          fa_mc_book_controls mcbc
   where  th.rowid between p_start_rowid and p_end_rowid
   and    th.book_type_code = dp.book_type_code
   and    th.date_effective > dp.period_open_date
   and    dp.period_close_date is null
   and    dp.book_type_code = bc.book_type_code
   and    bc.book_class <> 'BUDGET'
   and    bc.date_ineffective is null
   and    bc.book_type_code = cb.book_type_code
   and    ad.asset_category_id = cb.category_id
   and    dp.book_type_code = mcbc.book_type_code
   and    dp.set_of_books_id = mcbc.set_of_books_id
   and    th.transaction_type_code in ('ADDITION', 'CIP ADDITION')
   and    th.transaction_header_id = bk.transaction_header_id_in
   and    bk.set_of_books_id = mcbc.set_of_books_id
   and    bk.book_type_code = mcbc.book_type_code
   and    mcbc.enabled_flag = 'Y'
   and    bk.cost <> 0
   and    th.asset_id = ad.asset_id
   and not exists (select 'x'
                   from   fa_mc_adjustments aj
                   where  aj.asset_id = th.asset_id
                   and    aj.book_type_code = th.book_type_code
                   and    aj.set_of_books_id = mcbc.set_of_books_id
                   and    aj.book_type_code = mcbc.book_type_code
                   and    aj.transaction_header_id = th.transaction_header_id
                   and    aj.adjustment_type like '%COST')
    order by set_of_books_id;

   cursor c_invoices_mrc (p_asset_id number,
                          p_set_of_books_id number) is
   select AI.Payables_Code_Combination_ID,
          NVL(AI.Payables_Cost, 0),
          AI.Asset_Invoice_ID,
          AI.source_line_id
     FROM FA_MC_ASSET_INVOICES AI
    WHERE AI.ASSET_ID = p_asset_id
      AND AI.set_of_books_id = p_set_of_books_id
      AND AI.Payables_Code_Combination_ID IS NOT NULL
      AND AI.Date_Ineffective IS NULL
    ORDER BY AI.Payables_Code_Combination_ID,
             AI.PO_Vendor_ID,
             AI.Invoice_Number;

   TYPE tab_varchar  IS TABLE OF varchar2(150) INDEX BY BINARY_INTEGER;
   TYPE tab_number   IS TABLE OF number        INDEX BY BINARY_INTEGER;

   -- for bulk collect
   l_thid              tab_number;
   l_asset_id          tab_number;
   l_book_type_code    tab_varchar;
   l_trx_type_code     tab_varchar;
   l_cost              tab_number;
   l_category_id       tab_number;
   l_asset_type        tab_varchar;
   l_current_units     tab_number;
   l_set_of_books_id   tab_number;

   l_payables_ccid     tab_number;
   l_payables_cost     tab_number;
   l_asset_invoice_id  tab_number;
   l_source_line_id    tab_number;

   l_sum_payables_cost  number := 0;
   l_clearing_to_insert number := 0;
   l_mrc_sob_type_code  varchar2(1) := 'R';

   -- for api callouts
   l_trans_rec         fa_api_types.trans_rec_type;
   l_asset_hdr_rec     fa_api_types.asset_hdr_rec_type;
   l_asset_desc_rec    fa_api_types.asset_desc_rec_type;
   l_asset_cat_rec     fa_api_types.asset_cat_rec_type;
   l_asset_type_rec    fa_api_types.asset_type_rec_type;

   l_adj               fa_adjust_type_pkg.fa_adj_row_struct;
   l_calling_fn        varchar2(35) := 'FACPUPGB.Upgrade_Addition_MRC';
   l_log_level_rec     FA_API_TYPES.log_level_rec_type;

   error_found         exception;

BEGIN

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   loop

     OPEN c_additions_mrc;

     FETCH c_additions_mrc BULK COLLECT
      INTO   l_thid              ,
             l_asset_id          ,
             l_book_type_code    ,
             l_trx_type_code     ,
             l_cost              ,
             l_category_id       ,
             l_asset_type        ,
             l_current_units     ,
             l_set_of_books_id
     LIMIT   l_batch_size;
     CLOSE c_additions_mrc;

     l_rows_processed := l_thid.count;

     l_trans_rec.who_info.last_update_date := sysdate;
     l_trans_rec.who_info.last_updated_by := c_upgrade_bugno;
     l_trans_rec.who_info.last_update_login := c_upgrade_bugno;

      for i in 1..l_thid.count loop

         -- Added for bug# 5213257
	 fnd_profile.put('GL_SET_OF_BKS_ID', l_set_of_books_id(i));
         fnd_client_info.set_currency_context (l_set_of_books_id(i));

	 -- call the cache
         if not (fa_cache_pkg.fazcbc(x_book => l_book_type_code(i))) then
            raise error_found;
         end if;

         -- load the api rec types
         l_trans_rec.transaction_header_id      := l_thid (i);
         l_asset_hdr_rec.asset_id               := l_asset_id(i);
         l_asset_hdr_rec.book_type_code         := l_book_type_code(i);
         l_trans_rec.transaction_type_code      := l_trx_type_code(i);
         l_asset_cat_rec.category_id            := l_category_id(i);
         l_asset_type_rec.asset_type            := l_asset_type(i);
         l_asset_desc_rec.current_units         := l_current_units(i);

         l_adj.transaction_header_id    := l_thid (i);
         l_adj.asset_id                 := l_asset_id(i);
         l_adj.book_type_code           := l_book_type_code(i);
         l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.current_units            := l_current_units(i) ;
         l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.selection_thid           := 0;
         l_adj.selection_retid          := 0;
         l_adj.leveling_flag            := TRUE;
         l_adj.last_update_date         := l_trans_rec.who_info.last_update_date;

         l_adj.flush_adj_flag           := FALSE;
         l_adj.gen_ccid_flag            := FALSE;
         l_adj.annualized_adjustment    := 0;
         l_adj.distribution_id          := 0;

         l_adj.adjustment_type          := 'COST CLEARING';
         l_adj.source_type_code         := l_trx_type_code(i);
         l_adj.mrc_sob_type_code        := 'R';

         if l_asset_type(i) = 'CIP' then
            l_adj.account_type     := 'CIP_CLEARING_ACCT';
         else
            l_adj.account_type     := 'ASSET_CLEARING_ACCT';
         end if;

         /* commented for bug# 5213257
	 fnd_profile.put('GL_SET_OF_BKS_ID', l_set_of_books_id(i));
         fnd_client_info.set_currency_context (l_set_of_books_id(i)); */

         l_sum_payables_cost := 0;

         -- process invoices first
         OPEN c_invoices_mrc (p_asset_id => l_asset_id(i),
                              p_set_of_books_id => l_set_of_books_id(i));

         FETCH c_invoices_mrc BULK COLLECT
          INTO l_payables_ccid     ,
               l_payables_cost     ,
               l_asset_invoice_id  ,
               l_source_line_id    ;

         CLOSE c_invoices_mrc;

         for x in 1..l_payables_ccid.count loop

            l_sum_payables_cost       := l_sum_payables_cost + l_payables_cost(x);

            l_adj.asset_invoice_id    := l_asset_invoice_id(x);
            l_adj.source_line_id      := l_source_line_id(x);
            l_adj.code_combination_id := l_payables_ccid(x);

            if l_payables_cost(x) > 0 then
               l_adj.debit_credit_flag   := 'CR';
               l_adj.adjustment_amount   := l_payables_cost(x);
            else
               l_adj.debit_credit_flag   := 'DR';
               l_adj.adjustment_amount   := -l_payables_cost(x);
            end if;

            if not FA_INS_ADJUST_PKG.faxinaj
               (l_adj,
                l_trans_rec.who_info.last_update_date,
                l_trans_rec.who_info.last_updated_by,
                l_trans_rec.who_info.last_update_login,
                l_log_level_rec) then
               raise error_found;
            end if;

         end loop;

         -- now calc difference between invoice total and
         l_clearing_to_insert := l_cost(i) - l_sum_payables_cost;


         -- now insert cost, etc

         if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec         => l_trans_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_desc_rec    => l_asset_desc_rec,
                      p_asset_cat_rec     => l_asset_cat_rec,
                      p_asset_type_rec    => l_asset_type_rec,
                      p_cost              => l_cost(i),
                      p_clearing          => l_clearing_to_insert,
                      p_deprn_expense     => 0,
                      p_bonus_expense     => 0,
                      p_impair_expense    => 0,
                      p_ann_adj_amt       => 0,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn,
                      p_log_level_rec     => l_log_level_rec
                    ) then
            raise error_found;
         end if;

      end loop; -- additions

      -- flush remaining rows
      l_adj.transaction_header_id := 0;
      l_adj.flush_adj_flag        := TRUE;
      l_adj.leveling_flag         := TRUE;

      if not FA_INS_ADJUST_PKG.faxinaj
             (l_adj,
              l_trans_rec.who_info.last_update_date,
              l_trans_rec.who_info.last_updated_by,
              l_trans_rec.who_info.last_update_login,
              l_log_level_rec) then
          raise error_found;
      end if;

      COMMIT;

      l_thid.delete;
      l_asset_id.delete;
      l_book_type_code.delete;
      l_trx_type_code.delete;
      l_cost.delete;
      l_category_id.delete;
      l_asset_type.delete;
      l_current_units.delete;
      l_set_of_books_id.delete;
      l_payables_ccid.delete;
      l_payables_cost.delete;
      l_asset_invoice_id.delete;
      l_source_line_id.delete;

      if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;

EXCEPTION
   when error_found then
        if (c_additions_mrc%ISOPEN) then
           close c_additions_mrc;
        end if;
        rollback;
        raise;

   when others then
        close c_additions_mrc;
        rollback;
        raise;

END Upgrade_Addition_MRC;

Procedure Upgrade_Backdated_Trxns (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number,
             p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
                                                     default null
            ) IS

   c_upgrade_bugno             constant number(15) := -4107161;
   c_fnd_user                  constant number(15) := 2;

   -- this value can be altered in order to process more of less per batch
   l_batch_size                NUMBER;

   l_rows_processed            NUMBER;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   -- used for bulk fetching
   -- main cursor
   l_transaction_header_id_tbl                  num_tbl_type;
   l_asset_id_tbl                               num_tbl_type;
   l_book_type_code_tbl                         char_tbl_type;
   l_adj_req_status_tbl                         char_tbl_type;
   l_asset_type_tbl                             char_tbl_type;
   l_current_units_tbl                          num_tbl_type;
   l_category_id_tbl                            num_tbl_type;
   l_transaction_type_code_tbl                  char_tbl_type;
   l_set_of_books_id_tbl                        num_tbl_type;
   l_transaction_subtype_tbl                    char_tbl_type;
   l_transaction_name_tbl                       char_tbl_type;
   l_src_thid_tbl                               num_tbl_type;
   l_transaction_key_tbl                        char_tbl_type;
   l_amortization_start_date_tbl                date_tbl_type;
   l_group_asset_id_tbl                         num_tbl_type;
   l_ann_deprn_rounding_flag_tbl                char_tbl_type;
   l_transaction_date_entered_tbl               date_tbl_type;
   l_cost_tbl                                   num_tbl_type;
   l_adjusted_cost_tbl                          num_tbl_type;
   l_recoverable_cost_tbl                       num_tbl_type;
   l_reval_amortization_basis_tbl               num_tbl_type;
   l_adjusted_rate_tbl                          num_tbl_type;
   l_production_capacity_tbl                    num_tbl_type;
   l_adjusted_capacity_tbl                      num_tbl_type;
   l_adj_recoverable_cost_tbl                   num_tbl_type;
   l_deprn_method_code_tbl                      char_tbl_type;
   l_life_in_months_tbl                         num_tbl_type;
   l_salvage_value_tbl                          num_tbl_type;
   l_depreciate_flag_tbl                        char_tbl_type;
   l_ceiling_name_tbl                           char_tbl_type;
   l_rate_adjustment_factor_tbl                 num_tbl_type;
   l_bonus_rule_tbl                             char_tbl_type;
   l_prorate_date_tbl                           date_tbl_type;
   l_deprn_start_date_tbl                       date_tbl_type;
   l_date_placed_in_service_tbl                 date_tbl_type;
   l_short_fiscal_year_flag_tbl                 char_tbl_type;
   l_conversion_date_tbl                        date_tbl_type;
   l_orig_deprn_start_date_tbl                  date_tbl_type;
   l_formula_factor_tbl                         num_tbl_type;
   l_eofy_reserve_tbl                           num_tbl_type;
   l_asset_number_tbl                           char_tbl_type;
   l_deprn_amount_tbl                           num_tbl_type;
   l_ytd_deprn_tbl                              num_tbl_type;
   l_deprn_reserve_tbl                          num_tbl_type;
   l_prior_fy_expense_tbl                       num_tbl_type;
   l_bonus_deprn_amount_tbl                     num_tbl_type;
   l_bonus_ytd_deprn_tbl                        num_tbl_type;
   l_prior_fy_bonus_expense_tbl                 num_tbl_type;
   l_reval_amortization_tbl                     num_tbl_type;
   l_reval_amortization_basis                   num_tbl_type;
   l_reval_deprn_expense_tbl                    num_tbl_type;
   l_reval_ytd_deprn_tbl                        num_tbl_type;
   l_reval_deprn_reserve_tbl                    num_tbl_type;
   l_production_tbl                             num_tbl_type;
   l_ytd_production_tbl                         num_tbl_type;
   l_ltd_production_tbl                         num_tbl_type;

   l_period_rec               fa_api_types.period_rec_type;
   l_trans_rec                FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
   l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
   l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
   l_asset_fin_rec_null       FA_API_TYPES.asset_fin_rec_type := null;

   l_deprn_exp                    NUMBER;
   l_bonus_deprn_exp              NUMBER;
   l_impairment_exp               NUMBER;
   l_ann_adj_deprn_exp            NUMBER;
   l_ann_adj_bonus_deprn_exp      NUMBER;

   l_book_type_code               VARCHAR2(15);
   l_asset_id                     NUMBER(15);
   l_transaction_header_id        NUMBER(15);
   l_mrc_sob_type_code            VARCHAR2(1);
   l_dist                         NUMBER;
   l_mrc_books                    NUMBER;

   l_calling_fn        varchar2(35) := 'FACPUPGB.Upgrade_Backdated_Trxns';
   l_log_level_rec     FA_API_TYPES.log_level_rec_type;

   error_found         exception;

   cursor c_trx is
   select /*+ leading(th) rowid(th) swap_join_inputs(bc) */
          th.transaction_header_id,
          th.asset_id,
          th.book_type_code,
          bks.adjustment_required_status,
          ad.asset_type,
          ad.current_units,
          ad.asset_category_id,
          th.transaction_type_code,
          bc.set_of_books_id,
          th.transaction_subtype,
          bks.group_asset_id,
          bks.annual_deprn_rounding_flag,
          th.transaction_date_entered,
          th.transaction_name,
          th.source_transaction_header_id,
          th.transaction_key,
          th.amortization_start_date,
          bks.cost,
          bks.adjusted_cost,
          bks.recoverable_cost,
          bks.reval_amortization_basis,
          bks.adjusted_rate,
          bks.production_capacity,
          bks.adjusted_capacity,
          bks.adjusted_recoverable_cost,
          bks.deprn_method_code,
          bks.life_in_months,
          bks.salvage_value,
          bks.depreciate_flag,
          bks.ceiling_name,
          bks.rate_adjustment_factor,
          bks.bonus_rule,
          bks.prorate_date,
          bks.deprn_start_date,
          bks.date_placed_in_service,
          bks.short_fiscal_year_flag,
          bks.conversion_date,
          bks.original_deprn_start_date,
          bks.formula_factor,
          bks.eofy_reserve,
          ad.asset_number,
          ds.deprn_amount,
          ds.ytd_deprn,
          ds.deprn_reserve,
          ds.prior_fy_expense,
          ds.bonus_deprn_amount,
          ds.bonus_ytd_deprn,
          ds.prior_fy_bonus_expense,
          ds.reval_amortization,
          ds.reval_amortization_basis,
          ds.reval_deprn_expense,
          ds.ytd_reval_deprn_expense,
          ds.reval_reserve,
          ds.production,
          ds.ytd_production,
          ds.ltd_production
   from   fa_transaction_headers th,
          fa_books bks,
          fa_additions_b ad,
          fa_book_controls bc,
          fa_category_books cb,
          fa_deprn_summary ds,
          fa_deprn_periods dp
   where  th.rowid between p_start_rowid and p_end_rowid
   and    bc.book_type_code = th.book_type_code
   and    nvl(bc.date_ineffective, sysdate) <= sysdate
   and    bc.book_type_code = cb.book_type_code
   and    ad.asset_category_id = cb.category_id
   and    th.transaction_header_id = bks.transaction_header_id_in
   and    bks.transaction_header_id_out is null
   and    bks.adjustment_required_status in ('ADD', 'TFR')
   and    th.asset_id = ad.asset_id
   and    th.asset_id = ds.asset_id
   and    th.book_type_code = ds.book_type_code
   and    ds.deprn_source_code = 'BOOKS'
   and    dp.book_type_code = th.book_type_code
   and    dp.period_close_date is null
   and    th.date_effective between dp.period_open_date and sysdate;

   cursor c_mc_trx is
   select /*+ leading(th) rowid(th) swap_join_inputs(bc) */
          th.transaction_header_id,
          th.asset_id,
          th.book_type_code,
          bks.adjustment_required_status,
          ad.asset_type,
          ad.current_units,
          ad.asset_category_id,
          th.transaction_type_code,
          mcbc.set_of_books_id,
          th.transaction_subtype,
          bks.group_asset_id,
          bks.annual_deprn_rounding_flag,
          th.transaction_date_entered,
          th.transaction_name,
          th.source_transaction_header_id,
          th.transaction_key,
          th.amortization_start_date,
          bks.cost,
          bks.adjusted_cost,
          bks.recoverable_cost,
          bks.reval_amortization_basis,
          bks.adjusted_rate,
          bks.production_capacity,
          bks.adjusted_capacity,
          bks.adjusted_recoverable_cost,
          bks.deprn_method_code,
          bks.life_in_months,
          bks.salvage_value,
          bks.depreciate_flag,
          bks.ceiling_name,
          bks.rate_adjustment_factor,
          bks.bonus_rule,
          bks.prorate_date,
          bks.deprn_start_date,
          bks.date_placed_in_service,
          bks.short_fiscal_year_flag,
          bks.conversion_date,
          bks.original_deprn_start_date,
          bks.formula_factor,
          bks.eofy_reserve,
          ad.asset_number,
          ds.deprn_amount,
          ds.ytd_deprn,
          ds.deprn_reserve,
          ds.prior_fy_expense,
          ds.bonus_deprn_amount,
          ds.bonus_ytd_deprn,
          ds.prior_fy_bonus_expense,
          ds.reval_amortization,
          ds.reval_amortization_basis,
          ds.reval_deprn_expense,
          ds.ytd_reval_deprn_expense,
          ds.reval_reserve,
          ds.production,
          ds.ytd_production,
          ds.ltd_production
   from   fa_transaction_headers th,
          fa_mc_books bks,
          fa_additions_b ad,
          fa_book_controls bc,
          fa_category_books cb,
          fa_mc_book_controls mcbc,
          fa_mc_deprn_summary ds,
          fa_mc_deprn_periods dp
   where  th.rowid between p_start_rowid and p_end_rowid
   and    bc.book_type_code = th.book_type_code
   and    nvl(bc.date_ineffective, sysdate) <= sysdate
   and    bc.book_type_code = cb.book_type_code
   and    ad.asset_category_id = cb.category_id
   and    bc.book_type_code = mcbc.book_type_code
   and    mcbc.enabled_flag = 'Y'
   and    mcbc.book_type_code = bks.book_type_code
   and    mcbc.set_of_books_id = bks.set_of_books_id
   and    mcbc.book_type_code = ds.book_type_code
   and    mcbc.set_of_books_id = ds.set_of_books_id
   and    th.transaction_header_id = bks.transaction_header_id_in
   and    bks.transaction_header_id_out is null
   and    bks.adjustment_required_status = 'ADD'
   and    th.asset_id = ad.asset_id
   and    th.asset_id = ds.asset_id
   and    th.book_type_code = ds.book_type_code
   and    ds.deprn_source_code = 'BOOKS'
   and    nvl(th.transaction_subtype, 'EXPENSED') <> 'AMORTIZED'
   and    ad.asset_type = 'CAPITALIZED'
   and    bks.group_asset_id is null
   and    nvl(bks.annual_deprn_rounding_flag, 'ADD') <> 'RES'
   and    dp.book_type_code = mcbc.book_type_code
   and    dp.set_of_books_id = mcbc.set_of_books_id
   and    dp.book_type_code = th.book_type_code
   and    dp.period_close_date is null
   and    th.date_effective between dp.period_open_date and sysdate;


   cursor c_distributions is
   select dh.distribution_id,
          dh.units_assigned,
          dh.transaction_units,
          dh.assigned_to,
          dh.code_combination_id,
          dh.location_id
   from   fa_distribution_history dh
   where  dh.book_type_code = l_book_type_code
   and    dh.asset_id = l_asset_id
   and    dh.transaction_header_id_out = l_transaction_header_id
   union all
   select dh.distribution_id,
          dh.units_assigned,
          dh.transaction_units,
          dh.assigned_to,
          dh.code_combination_id,
          dh.location_id
   from   fa_distribution_history dh
   where  dh.book_type_code = l_book_type_code
   and    dh.asset_id = l_asset_id
   and    dh.transaction_header_id_in = l_transaction_header_id;

BEGIN

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   loop

     OPEN c_trx;

     FETCH c_trx BULK COLLECT
      INTO l_transaction_header_id_tbl,
           l_asset_id_tbl,
           l_book_type_code_tbl,
           l_adj_req_status_tbl,
           l_asset_type_tbl,
           l_current_units_tbl,
           l_category_id_tbl,
           l_transaction_type_code_tbl,
           l_set_of_books_id_tbl,
           l_transaction_subtype_tbl,
           l_group_asset_id_tbl,
           l_ann_deprn_rounding_flag_tbl,
           l_transaction_date_entered_tbl,
           l_transaction_name_tbl,
           l_src_thid_tbl,
           l_transaction_key_tbl,
           l_amortization_start_date_tbl,
           l_cost_tbl,
           l_adjusted_cost_tbl,
           l_recoverable_cost_tbl,
           l_reval_amortization_basis_tbl,
           l_adjusted_rate_tbl,
           l_production_capacity_tbl,
           l_adjusted_capacity_tbl,
           l_adj_recoverable_cost_tbl,
           l_deprn_method_code_tbl,
           l_life_in_months_tbl,
           l_salvage_value_tbl,
           l_depreciate_flag_tbl,
           l_ceiling_name_tbl,
           l_rate_adjustment_factor_tbl,
           l_bonus_rule_tbl,
           l_prorate_date_tbl,
           l_deprn_start_date_tbl,
           l_date_placed_in_service_tbl,
           l_short_fiscal_year_flag_tbl,
           l_conversion_date_tbl,
           l_orig_deprn_start_date_tbl,
           l_formula_factor_tbl,
           l_eofy_reserve_tbl,
           l_asset_number_tbl,
           l_deprn_amount_tbl,
           l_ytd_deprn_tbl,
           l_deprn_reserve_tbl,
           l_prior_fy_expense_tbl,
           l_bonus_deprn_amount_tbl,
           l_bonus_ytd_deprn_tbl,
           l_prior_fy_bonus_expense_tbl,
           l_reval_amortization_tbl,
           l_reval_amortization_basis,
           l_reval_deprn_expense_tbl,
           l_reval_ytd_deprn_tbl,
           l_reval_deprn_reserve_tbl,
           l_production_tbl,
           l_ytd_production_tbl,
           l_ltd_production_tbl
     LIMIT l_batch_size;
     CLOSE c_trx;

     l_rows_processed := l_transaction_header_id_tbl.count;

     for i in 1..l_transaction_header_id_tbl.count loop

         fnd_profile.put('GL_SET_OF_BKS_ID', l_set_of_books_id_tbl(i));
         fnd_client_info.set_currency_context (l_set_of_books_id_tbl(i));

         -- call the cache
         if not (fa_cache_pkg.fazcbc(x_book => l_book_type_code_tbl(i))) then
            raise error_found;
         end if;

         l_trans_rec.transaction_header_id := l_transaction_header_id_tbl(i);
         l_trans_rec.transaction_type_code := l_transaction_type_code_tbl(i);
         l_trans_rec.transaction_date_entered :=
            l_transaction_date_entered_tbl(i);
         l_trans_rec.transaction_subtype := l_transaction_subtype_tbl(i);
         l_trans_rec.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
         l_trans_rec.transaction_name := l_transaction_name_tbl(i);
         l_trans_rec.source_transaction_header_id := l_src_thid_tbl(i);
         l_trans_rec.transaction_key := l_transaction_key_tbl(i);
         l_trans_rec.amortization_start_date :=
            l_amortization_start_date_tbl(i);
         l_trans_rec.calling_interface := 'R12 Upgrade';
         l_trans_rec.who_info.created_by := c_fnd_user;
         l_trans_rec.who_info.creation_date := sysdate;
         l_trans_rec.who_info.last_update_date := sysdate;
         l_trans_rec.who_info.last_updated_by := c_fnd_user;
         l_trans_rec.who_info.last_update_login := c_upgrade_bugno;

         l_asset_hdr_rec.asset_id := l_asset_id_tbl(i);
         l_asset_hdr_rec.book_type_code := l_book_type_code_tbl(i);
         l_asset_hdr_rec.set_of_books_id := l_set_of_books_id_tbl(i);

         l_asset_desc_rec.asset_number := l_asset_number_tbl(i);
         l_asset_desc_rec.current_units := l_current_units_tbl(i);

         l_asset_cat_rec.category_id := l_category_id_tbl(i);

         l_asset_type_rec.asset_type := l_asset_type_tbl(i);

         l_asset_fin_rec.set_of_books_id := l_set_of_books_id_tbl(i);
         l_asset_fin_rec.cost :=  l_cost_tbl(i);
         l_asset_fin_rec.adjusted_cost := l_adjusted_cost_tbl(i);
         l_asset_fin_rec.recoverable_cost := l_recoverable_cost_tbl(i);
         l_asset_fin_rec.reval_amortization_basis :=
            l_reval_amortization_basis_tbl(i);
         l_asset_fin_rec.adjusted_rate :=  l_adjusted_rate_tbl(i);
         l_asset_fin_rec.production_capacity := l_production_capacity_tbl(i);
         l_asset_fin_rec.adjusted_capacity := l_adjusted_capacity_tbl(i);
         l_asset_fin_rec.adjusted_recoverable_cost :=
            l_adj_recoverable_cost_tbl(i);
         l_asset_fin_rec.deprn_method_code := l_deprn_method_code_tbl(i);
         l_asset_fin_rec.life_in_months := l_life_in_months_tbl(i);
         l_asset_fin_rec.salvage_value := l_salvage_value_tbl(i);
         l_asset_fin_rec.depreciate_flag := l_depreciate_flag_tbl(i);
         l_asset_fin_rec.ceiling_name := l_ceiling_name_tbl(i);
         l_asset_fin_rec.rate_adjustment_factor :=
            l_rate_adjustment_factor_tbl(i);
         l_asset_fin_rec.bonus_rule := l_bonus_rule_tbl(i);
         l_asset_fin_rec.prorate_date := l_prorate_date_tbl(i);
         l_asset_fin_rec.deprn_start_date := l_deprn_start_date_tbl(i);
         l_asset_fin_rec.date_placed_in_service :=
            l_date_placed_in_service_tbl(i);
         l_asset_fin_rec.short_fiscal_year_flag :=
            l_short_fiscal_year_flag_tbl(i);
         l_asset_fin_rec.conversion_date := l_conversion_date_tbl(i);
         l_asset_fin_rec.orig_deprn_start_date :=
            l_orig_deprn_start_date_tbl(i);
         l_asset_fin_rec.formula_factor := l_formula_factor_tbl(i);
         l_asset_fin_rec.eofy_reserve := l_eofy_reserve_tbl(i);
         l_asset_fin_rec.group_asset_id := l_group_asset_id_tbl(i);
         l_asset_fin_rec.annual_deprn_rounding_flag :=
            l_ann_deprn_rounding_flag_tbl(i);

         l_asset_deprn_rec.set_of_books_id := l_set_of_books_id_tbl(i);
         l_asset_deprn_rec.deprn_amount := l_deprn_amount_tbl(i);
         l_asset_deprn_rec.ytd_deprn := l_ytd_deprn_tbl(i);
         l_asset_deprn_rec.deprn_reserve := l_deprn_reserve_tbl(i);
         l_asset_deprn_rec.prior_fy_expense := l_prior_fy_expense_tbl(i);
         l_asset_deprn_rec.bonus_deprn_amount := l_bonus_deprn_amount_tbl(i);
         l_asset_deprn_rec.bonus_ytd_deprn := l_bonus_ytd_deprn_tbl(i);
         l_asset_deprn_rec.prior_fy_bonus_expense :=
            l_prior_fy_bonus_expense_tbl(i);
         l_asset_deprn_rec.reval_amortization := l_reval_amortization_tbl(i);
         l_asset_deprn_rec.reval_amortization_basis :=
            l_reval_amortization_basis(i);
         l_asset_deprn_rec.reval_deprn_expense := l_reval_deprn_expense_tbl(i);
         l_asset_deprn_rec.reval_ytd_deprn := l_reval_ytd_deprn_tbl(i);
         l_asset_deprn_rec.reval_deprn_reserve := l_reval_deprn_reserve_tbl(i);
         l_asset_deprn_rec.production := l_production_tbl(i);
         l_asset_deprn_rec.ytd_production := l_ytd_production_tbl(i);
         l_asset_deprn_rec.ltd_production := l_ltd_production_tbl(i);

         l_mrc_sob_type_code := 'P';

         if (NOT FA_UTIL_PVT.get_period_rec (
            p_book           => l_asset_hdr_rec.book_type_code,
            p_effective_date => NULL,
            x_period_rec     => l_period_rec,
            p_log_level_rec  => p_log_level_rec)) then
            raise error_found;
         end if;

         if (l_adj_req_status_tbl(i) = 'ADD') then

           -- Catchup addition by calling FA_EXP_PVT.faxexp

           if ((nvl(l_trans_rec.transaction_subtype, 'EXPENSED') <>
                                                     'AMORTIZED') and
               (l_asset_type_rec.asset_type = 'CAPITALIZED') and
               (l_asset_fin_rec.group_asset_id is null) and
               (nvl(l_asset_fin_rec.annual_deprn_rounding_flag,'ADD') <>
                                                               'RES') and
               (l_trans_rec.transaction_date_entered <
                l_period_rec.calendar_period_open_date)
           ) then

              if not FA_EXP_PVT.faxexp
                        (px_trans_rec          => l_trans_rec,
                         p_asset_hdr_rec       => l_asset_hdr_rec,
                         p_asset_desc_rec      => l_asset_desc_rec,
                         p_asset_cat_rec       => l_asset_cat_rec,
                         p_asset_type_rec      => l_asset_type_rec,
                         p_asset_fin_rec_old   => l_asset_fin_rec_null,
                         px_asset_fin_rec_new  => l_asset_fin_rec,
                         p_asset_deprn_rec     => l_asset_deprn_rec,
                         p_period_rec          => l_period_rec,
                         p_mrc_sob_type_code   => l_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp,
                         x_ann_adj_deprn_exp   => l_ann_adj_deprn_exp,
                         x_ann_adj_bonus_deprn_exp
                                               => l_ann_adj_bonus_deprn_exp,
                         p_log_level_rec       => l_log_level_rec) then

                 raise error_found;
              end if;

              if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec         => l_trans_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_desc_rec    => l_asset_desc_rec,
                      p_asset_cat_rec     => l_asset_cat_rec,
                      p_asset_type_rec    => l_asset_type_rec,
                      p_cost              => 0,
                      p_clearing          => 0,
                      p_deprn_expense     => l_deprn_exp,
                      p_bonus_expense     => l_bonus_deprn_exp,
                      p_impair_expense    => l_impairment_exp,
                      p_deprn_reserve     => 0,
                      p_bonus_reserve     => 0,
                      p_ann_adj_amt       => l_ann_adj_deprn_exp,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn,
                      p_log_level_rec     => l_log_level_rec
                     ) then raise error_found;
              end if;

              -- Reflect post catch-up info to fa_books
              fa_books_pkg.update_row
                 (X_asset_id          => l_asset_hdr_rec.asset_id,
                  X_book_type_code    => l_asset_hdr_rec.book_type_code,
                  X_Adjustment_Required_Status
                                      => 'NONE',
                  X_rate_adjustment_factor
                                      => l_asset_fin_rec.rate_adjustment_factor,
                  X_reval_amortization_basis
                                      =>
                     l_asset_fin_rec.reval_amortization_basis,
                  X_adjusted_cost     => l_asset_fin_rec.adjusted_cost,
                  X_adjusted_capacity => l_asset_fin_rec.adjusted_capacity,
                  X_formula_factor    => l_asset_fin_rec.formula_factor,
                  X_eofy_reserve      => l_asset_fin_rec.eofy_reserve,
                  X_mrc_sob_type_code => l_mrc_sob_type_code,
                  X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                  X_calling_fn        => l_calling_fn,
                  p_log_level_rec     => l_log_level_rec
              );
           end if;

        elsif (l_adj_req_status_tbl(i) = 'TFR') then
           -- Catchup transfer by calling FA_TRANSFER_PVT.fadppt

          if (l_asset_type_rec.asset_type = 'GROUP' or
              l_asset_type_rec.asset_type = 'CAPITALIZED'
          ) then

             -- Need to populate the distributions tbl
             l_dist := 0;
             l_asset_dist_tbl.delete;
             l_book_type_code := l_book_type_code_tbl(i);
             l_asset_id := l_asset_id_tbl(i);
             l_transaction_header_id := l_transaction_header_id_tbl(i);

             open c_distributions;
             loop
                l_dist := l_dist + 1;
                fetch c_distributions into
                   l_asset_dist_rec.distribution_id,
                   l_asset_dist_rec.units_assigned,
                   l_asset_dist_rec.transaction_units,
                   l_asset_dist_rec.assigned_to,
                   l_asset_dist_rec.expense_ccid,
                   l_asset_dist_rec.location_ccid;
                if (c_distributions%NOTFOUND) then
                   exit;
                end if;
                l_asset_dist_tbl(l_dist) := l_asset_dist_rec;
             end loop;
             close c_distributions;

             if (l_asset_dist_tbl.count > 0) then
                if not FA_TRANSFER_PVT.fadppt
                   (p_trans_rec       => l_trans_rec,
                    p_asset_hdr_rec   => l_asset_hdr_rec,
                    p_asset_desc_rec  => l_asset_desc_rec,
                    p_asset_cat_rec   => l_asset_cat_rec,
                    p_asset_dist_tbl  => l_asset_dist_tbl,
                    p_log_level_rec   => l_log_level_rec) then
                   raise error_found;
                end if;

                -- Reflect post catch-up info to fa_books
                fa_books_pkg.update_row
                   (X_asset_id          => l_asset_hdr_rec.asset_id,
                    X_book_type_code    => l_asset_hdr_rec.book_type_code,
                    X_Adjustment_Required_Status
                                        => 'NONE',
                    X_mrc_sob_type_code => 'P',
                    X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                    X_calling_fn        => l_calling_fn,
                    p_log_level_rec     => l_log_level_rec
                );
             end if;
          end if;
        end if;
     end loop;

     COMMIT;

     l_period_rec := null;
     l_trans_rec := null;
     l_asset_hdr_rec := null;
     l_asset_desc_rec := null;
     l_asset_cat_rec := null;
     l_asset_type_rec := null;
     l_asset_fin_rec := null;
     l_asset_deprn_rec := null;
     l_asset_dist_rec := null;
     l_asset_dist_tbl.delete;

     l_transaction_header_id_tbl.delete;
     l_asset_id_tbl.delete;
     l_book_type_code_tbl.delete;
     l_adj_req_status_tbl.delete;
     l_asset_type_tbl.delete;
     l_current_units_tbl.delete;
     l_category_id_tbl.delete;
     l_transaction_type_code_tbl.delete;
     l_set_of_books_id_tbl.delete;
     l_transaction_subtype_tbl.delete;
     l_group_asset_id_tbl.delete;
     l_ann_deprn_rounding_flag_tbl.delete;
     l_transaction_date_entered_tbl.delete;
     l_transaction_name_tbl.delete;
     l_src_thid_tbl.delete;
     l_transaction_key_tbl.delete;
     l_amortization_start_date_tbl.delete;
     l_cost_tbl.delete;
     l_adjusted_cost_tbl.delete;
     l_recoverable_cost_tbl.delete;
     l_reval_amortization_basis_tbl.delete;
     l_adjusted_rate_tbl.delete;
     l_production_capacity_tbl.delete;
     l_adjusted_capacity_tbl.delete;
     l_adj_recoverable_cost_tbl.delete;
     l_deprn_method_code_tbl.delete;
     l_life_in_months_tbl.delete;
     l_salvage_value_tbl.delete;
     l_depreciate_flag_tbl.delete;
     l_ceiling_name_tbl.delete;
     l_rate_adjustment_factor_tbl.delete;
     l_bonus_rule_tbl.delete;
     l_prorate_date_tbl.delete;
     l_deprn_start_date_tbl.delete;
     l_date_placed_in_service_tbl.delete;
     l_short_fiscal_year_flag_tbl.delete;
     l_conversion_date_tbl.delete;
     l_orig_deprn_start_date_tbl.delete;
     l_formula_factor_tbl.delete;
     l_eofy_reserve_tbl.delete;
     l_asset_number_tbl.delete;
     l_deprn_amount_tbl.delete;
     l_ytd_deprn_tbl.delete;
     l_deprn_reserve_tbl.delete;
     l_prior_fy_expense_tbl.delete;
     l_bonus_deprn_amount_tbl.delete;
     l_bonus_ytd_deprn_tbl .delete;
     l_prior_fy_bonus_expense_tbl.delete;
     l_reval_amortization_tbl.delete;
     l_reval_amortization_basis.delete;
     l_reval_deprn_expense_tbl.delete;
     l_reval_ytd_deprn_tbl.delete;
     l_reval_deprn_reserve_tbl.delete;
     l_production_tbl.delete;
     l_ytd_production_tbl.delete;
     l_ltd_production_tbl.delete;

     if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;

   -- Now run for MRC only if there are mrc books

   select count(*)
   into   l_mrc_books
   from   fa_mc_book_controls
   where  enabled_flag = 'Y';

   if (l_mrc_books > 0) then

    loop

     OPEN c_mc_trx;

     FETCH c_mc_trx BULK COLLECT
      INTO l_transaction_header_id_tbl,
           l_asset_id_tbl,
           l_book_type_code_tbl,
           l_adj_req_status_tbl,
           l_asset_type_tbl,
           l_current_units_tbl,
           l_category_id_tbl,
           l_transaction_type_code_tbl,
           l_set_of_books_id_tbl,
           l_transaction_subtype_tbl,
           l_group_asset_id_tbl,
           l_ann_deprn_rounding_flag_tbl,
           l_transaction_date_entered_tbl,
           l_transaction_name_tbl,
           l_src_thid_tbl,
           l_transaction_key_tbl,
           l_amortization_start_date_tbl,
           l_cost_tbl,
           l_adjusted_cost_tbl,
           l_recoverable_cost_tbl,
           l_reval_amortization_basis_tbl,
           l_adjusted_rate_tbl,
           l_production_capacity_tbl,
           l_adjusted_capacity_tbl,
           l_adj_recoverable_cost_tbl,
           l_deprn_method_code_tbl,
           l_life_in_months_tbl,
           l_salvage_value_tbl,
           l_depreciate_flag_tbl,
           l_ceiling_name_tbl,
           l_rate_adjustment_factor_tbl,
           l_bonus_rule_tbl,
           l_prorate_date_tbl,
           l_deprn_start_date_tbl,
           l_date_placed_in_service_tbl,
           l_short_fiscal_year_flag_tbl,
           l_conversion_date_tbl,
           l_orig_deprn_start_date_tbl,
           l_formula_factor_tbl,
           l_eofy_reserve_tbl,
           l_asset_number_tbl,
           l_deprn_amount_tbl,
           l_ytd_deprn_tbl,
           l_deprn_reserve_tbl,
           l_prior_fy_expense_tbl,
           l_bonus_deprn_amount_tbl,
           l_bonus_ytd_deprn_tbl,
           l_prior_fy_bonus_expense_tbl,
           l_reval_amortization_tbl,
           l_reval_amortization_basis,
           l_reval_deprn_expense_tbl,
           l_reval_ytd_deprn_tbl,
           l_reval_deprn_reserve_tbl,
           l_production_tbl,
           l_ytd_production_tbl,
           l_ltd_production_tbl
     LIMIT l_batch_size;
     CLOSE c_mc_trx;

     l_rows_processed := l_transaction_header_id_tbl.count;

     for i in 1..l_transaction_header_id_tbl.count loop

         fnd_profile.put('GL_SET_OF_BKS_ID', l_set_of_books_id_tbl(i));
         fnd_client_info.set_currency_context (l_set_of_books_id_tbl(i));

         -- call the cache
         if not (fa_cache_pkg.fazcbc(x_book => l_book_type_code_tbl(i))) then
            raise error_found;
         end if;

         l_trans_rec.transaction_header_id := l_transaction_header_id_tbl(i);
         l_trans_rec.transaction_type_code := l_transaction_type_code_tbl(i);
         l_trans_rec.transaction_date_entered :=
            l_transaction_date_entered_tbl(i);
         l_trans_rec.transaction_subtype := l_transaction_subtype_tbl(i);
         l_trans_rec.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
         l_trans_rec.transaction_name := l_transaction_name_tbl(i);
         l_trans_rec.source_transaction_header_id := l_src_thid_tbl(i);
         l_trans_rec.transaction_key := l_transaction_key_tbl(i);
         l_trans_rec.amortization_start_date :=
            l_amortization_start_date_tbl(i);
         l_trans_rec.calling_interface := 'R12 Upgrade';
         l_trans_rec.who_info.created_by := c_fnd_user;
         l_trans_rec.who_info.creation_date := sysdate;
         l_trans_rec.who_info.last_update_date := sysdate;
         l_trans_rec.who_info.last_updated_by := c_fnd_user;
         l_trans_rec.who_info.last_update_login := c_upgrade_bugno;

         l_asset_hdr_rec.asset_id := l_asset_id_tbl(i);
         l_asset_hdr_rec.book_type_code := l_book_type_code_tbl(i);
         l_asset_hdr_rec.set_of_books_id := l_set_of_books_id_tbl(i);

         l_asset_desc_rec.asset_number := l_asset_number_tbl(i);
         l_asset_desc_rec.current_units := l_current_units_tbl(i);

         l_asset_cat_rec.category_id := l_category_id_tbl(i);

         l_asset_type_rec.asset_type := l_asset_type_tbl(i);

         l_asset_fin_rec.set_of_books_id := l_set_of_books_id_tbl(i);
         l_asset_fin_rec.cost :=  l_cost_tbl(i);
         l_asset_fin_rec.adjusted_cost := l_adjusted_cost_tbl(i);
         l_asset_fin_rec.recoverable_cost := l_recoverable_cost_tbl(i);
         l_asset_fin_rec.reval_amortization_basis :=
            l_reval_amortization_basis_tbl(i);
         l_asset_fin_rec.adjusted_rate :=  l_adjusted_rate_tbl(i);
         l_asset_fin_rec.production_capacity := l_production_capacity_tbl(i);
         l_asset_fin_rec.adjusted_capacity := l_adjusted_capacity_tbl(i);
         l_asset_fin_rec.adjusted_recoverable_cost :=
            l_adj_recoverable_cost_tbl(i);
         l_asset_fin_rec.deprn_method_code := l_deprn_method_code_tbl(i);
         l_asset_fin_rec.life_in_months := l_life_in_months_tbl(i);
         l_asset_fin_rec.salvage_value := l_salvage_value_tbl(i);
         l_asset_fin_rec.depreciate_flag := l_depreciate_flag_tbl(i);
         l_asset_fin_rec.ceiling_name := l_ceiling_name_tbl(i);
         l_asset_fin_rec.rate_adjustment_factor :=
            l_rate_adjustment_factor_tbl(i);
         l_asset_fin_rec.bonus_rule := l_bonus_rule_tbl(i);
         l_asset_fin_rec.prorate_date := l_prorate_date_tbl(i);
         l_asset_fin_rec.deprn_start_date := l_deprn_start_date_tbl(i);
         l_asset_fin_rec.date_placed_in_service :=
            l_date_placed_in_service_tbl(i);
         l_asset_fin_rec.short_fiscal_year_flag :=
            l_short_fiscal_year_flag_tbl(i);
         l_asset_fin_rec.conversion_date := l_conversion_date_tbl(i);
         l_asset_fin_rec.orig_deprn_start_date :=
            l_orig_deprn_start_date_tbl(i);
         l_asset_fin_rec.formula_factor := l_formula_factor_tbl(i);
         l_asset_fin_rec.eofy_reserve := l_eofy_reserve_tbl(i);
         l_asset_fin_rec.group_asset_id := l_group_asset_id_tbl(i);
         l_asset_fin_rec.annual_deprn_rounding_flag :=
            l_ann_deprn_rounding_flag_tbl(i);

         l_asset_deprn_rec.set_of_books_id := l_set_of_books_id_tbl(i);
         l_asset_deprn_rec.deprn_amount := l_deprn_amount_tbl(i);
         l_asset_deprn_rec.ytd_deprn := l_ytd_deprn_tbl(i);
         l_asset_deprn_rec.deprn_reserve := l_deprn_reserve_tbl(i);
         l_asset_deprn_rec.prior_fy_expense := l_prior_fy_expense_tbl(i);
         l_asset_deprn_rec.bonus_deprn_amount := l_bonus_deprn_amount_tbl(i);
         l_asset_deprn_rec.bonus_ytd_deprn := l_bonus_ytd_deprn_tbl(i);
         l_asset_deprn_rec.prior_fy_bonus_expense :=
            l_prior_fy_bonus_expense_tbl(i);
         l_asset_deprn_rec.reval_amortization := l_reval_amortization_tbl(i);
         l_asset_deprn_rec.reval_amortization_basis :=
            l_reval_amortization_basis(i);
         l_asset_deprn_rec.reval_deprn_expense := l_reval_deprn_expense_tbl(i);
         l_asset_deprn_rec.reval_ytd_deprn := l_reval_ytd_deprn_tbl(i);
         l_asset_deprn_rec.reval_deprn_reserve := l_reval_deprn_reserve_tbl(i);
         l_asset_deprn_rec.production := l_production_tbl(i);
         l_asset_deprn_rec.ytd_production := l_ytd_production_tbl(i);
         l_asset_deprn_rec.ltd_production := l_ltd_production_tbl(i);

         l_mrc_sob_type_code := 'R';

         if (NOT FA_UTIL_PVT.get_period_rec (
            p_book           => l_asset_hdr_rec.book_type_code,
            p_effective_date => NULL,
            x_period_rec     => l_period_rec,
            p_log_level_rec  => p_log_level_rec)) then
            raise error_found;
         end if;

         if (l_adj_req_status_tbl(i) = 'ADD') then
           -- Catchup addition by calling FA_EXP_PVT.faxexp

           if ((nvl(l_trans_rec.transaction_subtype, 'EXPENSED') <>
                                                     'AMORTIZED') and
               (l_asset_type_rec.asset_type = 'CAPITALIZED') and
               (l_asset_fin_rec.group_asset_id is null) and
               (nvl(l_asset_fin_rec.annual_deprn_rounding_flag,'ADD') <>
                                                               'RES') and
               (l_trans_rec.transaction_date_entered <
                l_period_rec.calendar_period_open_date)
           ) then

              if not FA_EXP_PVT.faxexp
                        (px_trans_rec          => l_trans_rec,
                         p_asset_hdr_rec       => l_asset_hdr_rec,
                         p_asset_desc_rec      => l_asset_desc_rec,
                         p_asset_cat_rec       => l_asset_cat_rec,
                         p_asset_type_rec      => l_asset_type_rec,
                         p_asset_fin_rec_old   => l_asset_fin_rec_null,
                         px_asset_fin_rec_new  => l_asset_fin_rec,
                         p_asset_deprn_rec     => l_asset_deprn_rec,
                         p_period_rec          => l_period_rec,
                         p_mrc_sob_type_code   => l_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp,
                         x_ann_adj_deprn_exp   => l_ann_adj_deprn_exp,
                         x_ann_adj_bonus_deprn_exp
                                               => l_ann_adj_bonus_deprn_exp,
                         p_log_level_rec       => l_log_level_rec) then
                 raise error_found;
              end if;

              if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec         => l_trans_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_desc_rec    => l_asset_desc_rec,
                      p_asset_cat_rec     => l_asset_cat_rec,
                      p_asset_type_rec    => l_asset_type_rec,
                      p_cost              => 0,
                      p_clearing          => 0,
                      p_deprn_expense     => l_deprn_exp,
                      p_bonus_expense     => l_bonus_deprn_exp,
                      p_impair_expense    => l_impairment_exp,
                      p_deprn_reserve     => 0,
                      p_bonus_reserve     => 0,
                      p_ann_adj_amt       => l_ann_adj_deprn_exp,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn,
                      p_log_level_rec     => l_log_level_rec
                     ) then raise error_found;
              end if;

              -- Reflect post catch-up info to fa_books
              fa_books_pkg.update_row
                 (X_asset_id          => l_asset_hdr_rec.asset_id,
                  X_book_type_code    => l_asset_hdr_rec.book_type_code,
                  X_Adjustment_Required_Status
                                      => 'NONE',
                  X_rate_adjustment_factor
                                      => l_asset_fin_rec.rate_adjustment_factor,
                  X_reval_amortization_basis
                                      =>
                     l_asset_fin_rec.reval_amortization_basis,
                  X_adjusted_cost     => l_asset_fin_rec.adjusted_cost,
                  X_adjusted_capacity => l_asset_fin_rec.adjusted_capacity,
                  X_formula_factor    => l_asset_fin_rec.formula_factor,
                  X_eofy_reserve      => l_asset_fin_rec.eofy_reserve,
                  X_mrc_sob_type_code => l_mrc_sob_type_code,
                  X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                  X_calling_fn        => l_calling_fn,
                  p_log_level_rec     => l_log_level_rec
              );
           end if;
        end if;
     end loop;

     COMMIT;

     l_period_rec := null;
     l_trans_rec := null;
     l_asset_hdr_rec := null;
     l_asset_desc_rec := null;
     l_asset_cat_rec := null;
     l_asset_type_rec := null;
     l_asset_fin_rec := null;
     l_asset_deprn_rec := null;
     l_asset_dist_rec := null;
     l_asset_dist_tbl.delete;

     l_transaction_header_id_tbl.delete;
     l_asset_id_tbl.delete;
     l_book_type_code_tbl.delete;
     l_adj_req_status_tbl.delete;
     l_asset_type_tbl.delete;
     l_current_units_tbl.delete;
     l_category_id_tbl.delete;
     l_transaction_type_code_tbl.delete;
     l_set_of_books_id_tbl.delete;
     l_transaction_subtype_tbl.delete;
     l_group_asset_id_tbl.delete;
     l_ann_deprn_rounding_flag_tbl.delete;
     l_transaction_date_entered_tbl.delete;
     l_transaction_name_tbl.delete;
     l_src_thid_tbl.delete;
     l_transaction_key_tbl.delete;
     l_amortization_start_date_tbl.delete;
     l_cost_tbl.delete;
     l_adjusted_cost_tbl.delete;
     l_recoverable_cost_tbl.delete;
     l_reval_amortization_basis_tbl.delete;
     l_adjusted_rate_tbl.delete;
     l_production_capacity_tbl.delete;
     l_adjusted_capacity_tbl.delete;
     l_adj_recoverable_cost_tbl.delete;
     l_deprn_method_code_tbl.delete;
     l_life_in_months_tbl.delete;
     l_salvage_value_tbl.delete;
     l_depreciate_flag_tbl.delete;
     l_ceiling_name_tbl.delete;
     l_rate_adjustment_factor_tbl.delete;
     l_bonus_rule_tbl.delete;
     l_prorate_date_tbl.delete;
     l_deprn_start_date_tbl.delete;
     l_date_placed_in_service_tbl.delete;
     l_short_fiscal_year_flag_tbl.delete;
     l_conversion_date_tbl.delete;
     l_orig_deprn_start_date_tbl.delete;
     l_formula_factor_tbl.delete;
     l_eofy_reserve_tbl.delete;
     l_asset_number_tbl.delete;
     l_deprn_amount_tbl.delete;
     l_ytd_deprn_tbl.delete;
     l_deprn_reserve_tbl.delete;
     l_prior_fy_expense_tbl.delete;
     l_bonus_deprn_amount_tbl.delete;
     l_bonus_ytd_deprn_tbl .delete;
     l_prior_fy_bonus_expense_tbl.delete;
     l_reval_amortization_tbl.delete;
     l_reval_amortization_basis.delete;
     l_reval_deprn_expense_tbl.delete;
     l_reval_ytd_deprn_tbl.delete;
     l_reval_deprn_reserve_tbl.delete;
     l_production_tbl.delete;
     l_ytd_production_tbl.delete;
     l_ltd_production_tbl.delete;

     if (l_rows_processed < l_batch_size) then exit; end if;

    end loop;

  end if;


EXCEPTION
   when error_found then
        if (c_trx%isopen) then
           close c_trx;
        elsif (c_mc_trx%isopen) then
           close c_mc_trx;
        end if;

        rollback;
        raise;

   when others then
        if (c_trx%isopen) then
           close c_trx;
        elsif (c_mc_trx%isopen) then
           close c_mc_trx;
        end if;

        rollback;
        raise;

END Upgrade_Backdated_Trxns;

Procedure Upgrade_Invoices (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
             ,p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) IS

-- this value can be altered in order to process more of less per batch
l_batch_size                NUMBER;

l_rows_processed            NUMBER;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   -- used for bulk fetching
   -- main cursor
   l_adj_rowid_tbl                              rowid_tbl_type;
   l_source_line_id_tbl                         num_tbl_type;
   l_source_dest_code_tbl                       char_tbl_type;
   l_asset_id_tbl                               num_tbl_type;
   l_book_type_code_tbl                         char_tbl_type;
   l_distribution_id_tbl                        num_tbl_type;
   l_transaction_header_id_tbl                  num_tbl_type;
   l_source_type_code_tbl                       char_tbl_type;
   l_adjustment_type_tbl                        char_tbl_type;
   l_debit_credit_flag_tbl                      char_tbl_type;
   l_code_combination_id_tbl                    num_tbl_type;

cursor c_invoices is
   select /*+ leading(th) rowid(th) */
          adj.rowid,
          ai.source_line_id,
          mult.source_dest_code,
          adj.asset_id,
          adj.book_type_code,
          adj.distribution_id,
          adj.transaction_header_id,
          adj.source_type_code,
          adj.adjustment_type,
          adj.debit_credit_flag,
          adj.code_combination_id
   from   fa_transaction_headers th,
          fa_book_controls bc,
          fa_deprn_periods dp,
          fa_adjustments adj,
          fa_asset_invoices ai,
          fa_invoice_transactions it,
          (select 'SOURCE' source_dest_code from dual union all
           select 'DEST'   source_dest_code from dual) mult
   where  th.rowid between p_start_rowid and p_end_rowid
   and    bc.book_type_code = th.book_type_code
   and    nvl(bc.date_ineffective, sysdate) <= sysdate
   and    bc.book_type_code = dp.book_type_code
   and    dp.period_close_date is null
   and    th.date_effective > dp.period_open_date
   and    th.transaction_header_id = adj.transaction_header_id
   and    th.asset_id = adj.asset_id
   and    th.book_type_code = adj.book_type_code
   and    adj.asset_id = ai.asset_id
   and    adj.asset_invoice_id = ai.asset_invoice_id
   and    it.invoice_transaction_id =
          decode(mult.source_dest_code,
                 'SOURCE', ai.invoice_transaction_id_out,
                 'DEST'  , ai.invoice_transaction_id_in)
   and    th.invoice_transaction_id = it.invoice_transaction_id
   and    th.book_type_code = it.book_type_code
   and    it.transaction_type = 'INVOICE TRANSFER'
   and    adj.source_line_id is null;

cursor c_transfers is
   select /*+ leading(th) rowid(th) */
          adj.rowid,
          mult.source_dest_code,
          adj.asset_id,
          adj.book_type_code,
          adj.distribution_id,
          adj.transaction_header_id,
          adj.source_type_code,
          adj.adjustment_type,
          adj.debit_credit_flag,
          adj.code_combination_id
   from   fa_transaction_headers th,
          fa_book_controls bc,
          fa_deprn_periods dp,
          fa_adjustments adj,
          fa_distribution_history dh,
          (select 'SOURCE' source_dest_code from dual union all
           select 'DEST'   source_dest_code from dual) mult
   where  th.rowid between p_start_rowid and p_end_rowid
   and    bc.book_type_code = th.book_type_code
   and    nvl(bc.date_ineffective, sysdate) <= sysdate
   and    bc.book_type_code = dp.book_type_code
   and    dp.period_close_date is null
   and    th.date_effective > dp.period_open_date
   and    th.transaction_header_id = adj.transaction_header_id
   and    th.asset_id = adj.asset_id
   and    th.book_type_code = adj.book_type_code
   and    adj.asset_id = dh.asset_id
   and    adj.book_type_code = dh.book_type_code
   and    adj.distribution_id = dh.distribution_id
   and    adj.transaction_header_id =
          decode (mult.source_dest_code,
                  'SOURCE', dh.transaction_header_id_out,
                  'DEST'  , dh.transaction_header_id_in)
   and    adj.source_dest_code is null;

BEGIN

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   loop

      open c_invoices;
      fetch c_invoices bulk collect into
         l_adj_rowid_tbl,
         l_source_line_id_tbl,
         l_source_dest_code_tbl,
         l_asset_id_tbl,
         l_book_type_code_tbl,
         l_distribution_id_tbl,
         l_transaction_header_id_tbl,
         l_source_type_code_tbl,
         l_adjustment_type_tbl,
         l_debit_credit_flag_tbl,
         l_code_combination_id_tbl
         limit l_batch_size;
      close c_invoices;

      l_rows_processed := l_adj_rowid_tbl.count;

      forall i in 1..l_adj_rowid_tbl.count
      update fa_adjustments
      set    source_line_id = l_source_line_id_tbl(i),
             source_dest_code = l_source_dest_code_tbl(i)
      where  rowid = l_adj_rowid_tbl(i);

      forall i in 1..l_adj_rowid_tbl.count
      update fa_mc_adjustments
      set    source_line_id = l_source_line_id_tbl(i),
             source_dest_code = l_source_dest_code_tbl(i)
      where  asset_id = l_asset_id_tbl(i)
      and    book_type_code = l_book_type_code_tbl(i)
      and    distribution_id = l_distribution_id_tbl(i)
      and    transaction_header_id = l_transaction_header_id_tbl(i)
      and    source_type_code = l_source_type_code_tbl(i)
      and    adjustment_type = l_adjustment_type_tbl(i)
      and    debit_credit_flag = l_debit_credit_flag_tbl(i)
      and    code_combination_id = l_code_combination_id_tbl(i);

      commit;

      l_adj_rowid_tbl.delete;
      l_source_line_id_tbl.delete;
      l_asset_id_tbl.delete;
      l_book_type_code_tbl.delete;
      l_distribution_id_tbl.delete;
      l_transaction_header_id_tbl.delete;
      l_source_type_code_tbl.delete;
      l_adjustment_type_tbl.delete;
      l_debit_credit_flag_tbl.delete;
      l_code_combination_id_tbl.delete;

      if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;

   loop

      open c_transfers;
      fetch c_transfers bulk collect into
         l_adj_rowid_tbl,
         l_source_dest_code_tbl,
         l_asset_id_tbl,
         l_book_type_code_tbl,
         l_distribution_id_tbl,
         l_transaction_header_id_tbl,
         l_source_type_code_tbl,
         l_adjustment_type_tbl,
         l_debit_credit_flag_tbl,
         l_code_combination_id_tbl
         limit l_batch_size;
      close c_transfers;

      l_rows_processed := l_adj_rowid_tbl.count;

      forall i in 1..l_adj_rowid_tbl.count
      update fa_adjustments
      set    source_dest_code = l_source_dest_code_tbl(i)
      where  rowid = l_adj_rowid_tbl(i);

      forall i in 1..l_adj_rowid_tbl.count
      update fa_mc_adjustments
      set    source_dest_code = l_source_dest_code_tbl(i)
      where  asset_id = l_asset_id_tbl(i)
      and    book_type_code = l_book_type_code_tbl(i)
      and    distribution_id = l_distribution_id_tbl(i)
      and    transaction_header_id = l_transaction_header_id_tbl(i)
      and    source_type_code = l_source_type_code_tbl(i)
      and    adjustment_type = l_adjustment_type_tbl(i)
      and    debit_credit_flag = l_debit_credit_flag_tbl(i)
      and    code_combination_id = l_code_combination_id_tbl(i);

      commit;

      l_adj_rowid_tbl.delete;
      l_source_line_id_tbl.delete;
      l_asset_id_tbl.delete;
      l_book_type_code_tbl.delete;
      l_distribution_id_tbl.delete;
      l_transaction_header_id_tbl.delete;
      l_source_type_code_tbl.delete;
      l_adjustment_type_tbl.delete;
      l_debit_credit_flag_tbl.delete;
      l_code_combination_id_tbl.delete;

      if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;

END Upgrade_Invoices;

END FA_SLA_CURRENT_PERIOD_UPG_PKG;

/
