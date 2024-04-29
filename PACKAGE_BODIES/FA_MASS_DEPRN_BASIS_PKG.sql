--------------------------------------------------------
--  DDL for Package Body FA_MASS_DEPRN_BASIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_DEPRN_BASIS_PKG" as
/* $Header: faxmcdbb.pls 120.4.12010000.3 2009/07/31 11:45:39 bmaddine ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE mass_faxccdb (
   p_book_type_code           IN            VARCHAR2,
   p_period_counter           IN            NUMBER,
   p_run_date		      IN            VARCHAR2,
   p_mrc_sob_type_code        IN            NUMBER,
   p_set_of_books_id          IN            NUMBER,
   p_total_requests           IN            NUMBER,
   p_request_number           IN            NUMBER,
   x_return_status            OUT NOCOPY    NUMBER) IS

   c_batch_size                  constant number := 1000;

   l_rows_processed              number;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   -- used for bulk fetching
   -- main cursor
   l_bks_rowid_tbl                              rowid_tbl_type;
   l_asset_id_tbl                               num_tbl_type;
   l_group_asset_id_tbl                         num_tbl_type;
   l_asset_type_tbl                             char_tbl_type;
   l_depreciate_flag_tbl                        char_tbl_type;
   l_method_code_tbl                            char_tbl_type;
   l_life_in_months_tbl                         num_tbl_type;
   l_method_id_tbl                              num_tbl_type;
   l_method_type_tbl                            char_tbl_type;
   l_calc_basis_tbl                             char_tbl_type;
   l_cost_tbl                                   num_tbl_type;
   l_salvage_value_tbl                          num_tbl_type;
   l_recoverable_cost_tbl                       num_tbl_type;
   l_adjusted_cost_tbl                          num_tbl_type;
   l_current_total_rsv_tbl                      num_tbl_type;
   l_current_rsv_tbl                            num_tbl_type;
   l_current_total_ytd_tbl                      num_tbl_type;
   l_hyp_total_rsv_tbl                          num_tbl_type;
   l_old_adjusted_cost_tbl                      num_tbl_type;
   l_old_raf_tbl                                num_tbl_type;
   l_old_formula_factor_tbl                     num_tbl_type;
   l_new_adjusted_cost_tbl                      num_tbl_type;
   l_new_raf_tbl                                num_tbl_type;
   l_new_formula_factor_tbl                     num_tbl_type;
   l_eofy_reserve_tbl                           num_tbl_type;
   l_tracking_method_tbl                        char_tbl_type;
   l_eofy_formula_factor_tbl                    num_tbl_type;
   l_adjusted_capacity_tbl                      num_tbl_type;
   l_new_adjusted_capacity_tbl                  num_tbl_type;
   l_exclude_fully_rsv_flag_tbl                 char_tbl_type;
   l_deprn_basis_rule_id_tbl                    num_tbl_type;
   l_period_update_flag_tbl                     char_tbl_type;
   l_use_eofy_reserve_flag                      char_tbl_type; -- Bug4940246
   l_polish_rule_tbl                            num_tbl_type;
   l_impairment_reserve_tbl                     num_tbl_type; -- P2IAS36

   l_fiscal_year                                number;
   l_eofy_flag                                  varchar2(1);
   l_mrc_sob_type_code				varchar2(1);
   l_period_num					number;
   l_run_date					date;
   l_status					number;
   mass_faxccdb_err				exception;

   l_asset_id			number;

   -- Bug:5930979:Japan Tax Reform Project
   l_guarantee_rate_flag_tbl                    char_tbl_type;
   l_rate_in_use_tbl                            num_tbl_type;
   l_method_type                                NUMBER := 0;
   l_success                                    INTEGER;

   l_calling_fn   varchar2(45) := 'fa_mass_deprn_basis_pkg.mass_faxccdb';

   cursor c_assets is
      select ds.asset_id,
             bks.rowid,
             bks.group_asset_id,
             ad.asset_type,
             bks.depreciate_flag,
             bks.deprn_method_code,
             bks.life_in_months,
             mt.method_id,
             mt.rate_source_rule,
             mt.deprn_basis_rule,
             bks.cost,
             bks.salvage_value,
             bks.recoverable_cost,
             bks.adjusted_cost,
             ds.deprn_reserve,
             ds.deprn_reserve - ds.deprn_amount,
             ds.ytd_deprn,
             ds.deprn_reserve,
             bks.adjusted_cost,
             bks.rate_adjustment_factor,
             bks.formula_factor,
             bks.eofy_reserve,
             bks.tracking_method,
             bks.eofy_formula_factor,
             bks.adjusted_capacity,
             bks.production_capacity - ds.ltd_production,
             bks.exclude_fully_rsv_flag,
             nvl(mt.deprn_basis_rule_id, 0),
             nvl(drd.period_update_flag, 'N'),
             nvl(drd.use_eofy_reserve_flag, 'N'),  -- Bug4940246
             decode (drd.rule_name,
              'POLISH 30% WITH A SWITCH TO DECLINING CLASSICAL AND FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_1,
              'POLISH 30% WITH A SWITCH TO FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_2,
              'POLISH DECLINING MODIFIED WITH A SWITCH TO DECLINING CLASSICAL AND FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_3,
              'POLISH DECLINING MODIFIED WITH A SWITCH TO FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_4,
              'POLISH STANDARD DECLINING WITH A SWITCH TO FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_5,
              FA_STD_TYPES.FAD_DBR_POLISH_NONE)
           , nvl(ds.impairment_reserve, 0) -- P2IAS36
           , nvl(mt.guarantee_rate_method_flag, 'NO') -- Bug:5930979:Japan Tax Reform Project
      from   fa_deprn_summary ds,
             fa_books bks,
             fa_methods mt,
             fa_deprn_rule_details drd,
             fa_additions_b ad
      where  ds.book_type_code = p_book_type_code
      and    ds.period_counter = p_period_counter
      -- and    MOD(ds.asset_id, p_total_requests) = (p_request_number - 1)
      and    MOD(nvl(bks.group_asset_id,bks.asset_id), p_total_requests) = (p_request_number - 1)
      and    ds.book_type_code = bks.book_type_code
      and    ds.asset_id = bks.asset_id
      and    bks.transaction_header_id_out is null
      and    bks.deprn_method_code = mt.method_code
      and    nvl(bks.life_in_months, -99) = nvl(mt.life_in_months, -99)
      and    mt.deprn_basis_rule_id = drd.deprn_basis_rule_id (+)
      and    mt.rate_source_rule = drd.rate_source_rule (+)
      and    mt.deprn_basis_rule = drd.deprn_basis_rule (+)
      and    ds.deprn_run_date >= to_date(p_run_date, 'DD/MM/YYYY HH24:MI:SS')
      and    ds.asset_id = ad.asset_id;
      --and    rownum < 1050;

   cursor c_mc_assets is
      select ds.asset_id,
             bks.rowid,
             bks.group_asset_id,
             ad.asset_type,
             bks.depreciate_flag,
             bks.deprn_method_code,
             bks.life_in_months,
             mt.method_id,
             mt.rate_source_rule,
             mt.deprn_basis_rule,
             bks.cost,
             bks.salvage_value,
             bks.recoverable_cost,
             bks.adjusted_cost,
             ds.deprn_reserve,
             ds.deprn_reserve - ds.deprn_amount,
             ds.ytd_deprn,
             ds.deprn_reserve,
             bks.adjusted_cost,
             bks.rate_adjustment_factor,
             bks.formula_factor,
             bks.eofy_reserve,
             bks.tracking_method,
             bks.eofy_formula_factor,
             bks.adjusted_capacity,
             bks.production_capacity - ds.ltd_production,
             bks.exclude_fully_rsv_flag,
             nvl(mt.deprn_basis_rule_id, 0),
             nvl(drd.period_update_flag, 'N'),
             nvl(drd.use_eofy_reserve_flag, 'N'),  -- Bug4940246
             decode (drd.rule_name,
              'POLISH 30% WITH A SWITCH TO DECLINING CLASSICAL AND FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_1,
              'POLISH 30% WITH A SWITCH TO FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_2,
              'POLISH DECLINING MODIFIED WITH A SWITCH TO DECLINING CLASSICAL AND FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_3,
              'POLISH DECLINING MODIFIED WITH A SWITCH TO FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_4,
              'POLISH STANDARD DECLINING WITH A SWITCH TO FLAT RATE',
                 FA_STD_TYPES.FAD_DBR_POLISH_5,
              FA_STD_TYPES.FAD_DBR_POLISH_NONE)
           , nvl(ds.impairment_reserve, 0) -- P2IAS36
           , nvl(mt.guarantee_rate_method_flag, 'NO') -- Bug:5930979:Japan Tax Reform Project
      from   fa_mc_deprn_summary ds,
             fa_mc_books bks,
             fa_methods mt,
             fa_deprn_rule_details drd,
             fa_additions_b ad
      where  ds.book_type_code = p_book_type_code
      and    ds.period_counter = p_period_counter
      and    ds.set_of_books_id = p_set_of_books_id
      --and    MOD(ds.asset_id, p_total_requests) = (p_request_number - 1)
      and    MOD(nvl(bks.group_asset_id,bks.asset_id), p_total_requests) = (p_request_number - 1)
      and    ds.book_type_code = bks.book_type_code
      and    ds.asset_id = bks.asset_id
      and    bks.transaction_header_id_out is null
      and    bks.set_of_books_id = p_set_of_books_id
      and    bks.deprn_method_code = mt.method_code
      and    nvl(bks.life_in_months, -99) = nvl(mt.life_in_months, -99)
      and    mt.deprn_basis_rule_id = drd.deprn_basis_rule_id (+)
      and    mt.rate_source_rule = drd.rate_source_rule (+)
      and    mt.deprn_basis_rule = drd.deprn_basis_rule (+)
      and    ds.deprn_run_date >= to_date(p_run_date, 'DD/MM/YYYY HH24:MI:SS')
      and    ds.asset_id = ad.asset_id;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise mass_faxccdb_err;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'BEGIN',1, p_log_level_rec => g_log_level_rec);
   end if;

   if p_mrc_sob_type_code = 0 then
      l_mrc_sob_type_code := 'P';
   elsif p_mrc_sob_type_code = 1 then
      l_mrc_sob_type_code := 'R';
   end if;

   l_run_date := to_date(p_run_date, 'DD/MM/YYYY HH24:MI:SS');

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'l_run_date',p_run_date, p_log_level_rec => g_log_level_rec);
   end if;

   if (l_mrc_sob_type_code = 'R') then

      select dp.fiscal_year,
             decode (dp.period_num,
                     ct.number_per_fiscal_year, 'Y',
                     'N') eofy_flag
      into   l_fiscal_year,
             l_eofy_flag
      from   fa_book_controls bc,
             fa_mc_book_controls mbc,
             fa_mc_deprn_periods dp,
             fa_calendar_types ct
      where  dp.book_type_code = p_book_type_code
      and    dp.period_counter = p_period_counter
      and    dp.set_of_books_id = p_set_of_books_id
      and    bc.book_type_code = p_book_type_code
      and    bc.deprn_calendar = ct.calendar_type
      and    mbc.book_type_code = p_book_type_code
      and    mbc.set_of_books_id = p_set_of_books_id;

   else

      select dp.fiscal_year,
             decode (dp.period_num,
                     ct.number_per_fiscal_year, 'Y',
                     'N') eofy_flag,
	     dp.period_num
      into   l_fiscal_year,
             l_eofy_flag,
	     l_period_num
      from   fa_book_controls bc,
             fa_deprn_periods dp,
             fa_calendar_types ct
      where  dp.book_type_code = p_book_type_code
      and    dp.period_counter = p_period_counter
      and    bc.book_type_code = p_book_type_code
      and    bc.deprn_calendar = ct.calendar_type;

   end if;

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'BEGIN',2, p_log_level_rec => g_log_level_rec);
   end if;

   if (l_mrc_sob_type_code = 'R') then
      open c_mc_assets;
   else
      open c_assets;
   end if;

   loop

      if (l_mrc_sob_type_code = 'R') then
         fetch c_mc_assets bulk collect
          into l_asset_id_tbl,
               l_bks_rowid_tbl,
               l_group_asset_id_tbl,
               l_asset_type_tbl,
               l_depreciate_flag_tbl,
               l_method_code_tbl,
               l_life_in_months_tbl,
               l_method_id_tbl,
               l_method_type_tbl,
               l_calc_basis_tbl,
               l_cost_tbl,
               l_salvage_value_tbl,
               l_recoverable_cost_tbl,
               l_adjusted_cost_tbl,
               l_current_total_rsv_tbl,
               l_current_rsv_tbl,
               l_current_total_ytd_tbl,
               l_hyp_total_rsv_tbl,
               l_old_adjusted_cost_tbl,
               l_old_raf_tbl,
               l_old_formula_factor_tbl,
               l_eofy_reserve_tbl,
               l_tracking_method_tbl,
               l_eofy_formula_factor_tbl,
               l_adjusted_capacity_tbl,
               l_new_adjusted_capacity_tbl,
               l_exclude_fully_rsv_flag_tbl,
               l_deprn_basis_rule_id_tbl,
               l_period_update_flag_tbl,
               l_use_eofy_reserve_flag,-- Bug4940246
               l_polish_rule_tbl,
               l_impairment_reserve_tbl, -- P2IAS36
	       l_guarantee_rate_flag_tbl  -- Bug:5930979:Japan Tax Reform Project
	       limit c_batch_size;

      else
         fetch c_assets bulk collect
          into l_asset_id_tbl,
               l_bks_rowid_tbl,
               l_group_asset_id_tbl,
               l_asset_type_tbl,
               l_depreciate_flag_tbl,
               l_method_code_tbl,
               l_life_in_months_tbl,
               l_method_id_tbl,
               l_method_type_tbl,
               l_calc_basis_tbl,
               l_cost_tbl,
               l_salvage_value_tbl,
               l_recoverable_cost_tbl,
               l_adjusted_cost_tbl,
               l_current_total_rsv_tbl,
               l_current_rsv_tbl,
               l_current_total_ytd_tbl,
               l_hyp_total_rsv_tbl,
               l_old_adjusted_cost_tbl,
               l_old_raf_tbl,
               l_old_formula_factor_tbl,
               l_eofy_reserve_tbl,
               l_tracking_method_tbl,
               l_eofy_formula_factor_tbl,
               l_adjusted_capacity_tbl,
               l_new_adjusted_capacity_tbl,
               l_exclude_fully_rsv_flag_tbl,
               l_deprn_basis_rule_id_tbl,
               l_period_update_flag_tbl,
               l_use_eofy_reserve_flag,  -- Bug4940246
               l_polish_rule_tbl,
               l_impairment_reserve_tbl, -- P2IAS36
	       l_guarantee_rate_flag_tbl  -- Bug:5930979:Japan Tax Reform Project
	       limit c_batch_size;

      end if;

      if (g_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,'BEGIN',3, p_log_level_rec => g_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'l_eofy_flag',l_eofy_flag, p_log_level_rec => g_log_level_rec);
      end if;

      l_rows_processed := l_asset_id_tbl.count;
      if l_rows_processed = 0 then
         exit;
      end if;
      for i in 1..l_asset_id_tbl.count loop

           if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'l_asset_id',l_asset_id_tbl(i));
           end if;

           l_asset_id := l_asset_id_tbl(i);

           -- Bug 5912071
	   if (l_method_type_tbl(i) in ('TABLE','FORMULA') -- Formula added for bug 6039584
               and l_calc_basis_tbl(i) = 'NBV'
	       and nvl(l_deprn_basis_rule_id_tbl(i),0) = 0) then

                  l_use_eofy_reserve_flag(i) := 'Y';

           end if;
	   -- End bug fix 5912071

           -- Bug4940246: Added following if statement
           -- Do not call deprn basis rule if it is not eofy and period update is no or
           -- it is eofy but period update and use eofy are no.
           if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'l_period_update_flag_tbl', l_period_update_flag_tbl(i));
            fa_debug_pkg.add(l_calling_fn,'l_use_eofy_reserve_flag', l_use_eofy_reserve_flag(i));
           end if;

           if ((l_eofy_flag = 'N') and
               (l_period_update_flag_tbl(i) = 'N')) or
              ((l_eofy_flag = 'Y') and
               (l_use_eofy_reserve_flag(i) = 'N') and
               (l_period_update_flag_tbl(i) = 'N')) then

              l_new_adjusted_cost_tbl(i) := l_old_adjusted_cost_tbl(i);
              l_new_raf_tbl(i)           := l_old_raf_tbl(i);
              l_new_formula_factor_tbl(i):= l_old_formula_factor_tbl(i);

              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn,'Not calling deprn basis function', l_new_adjusted_cost_tbl(i));
              end if;

           else
              l_status := FA_BASIS_OVERRIDE_INIT_PKG.faxccdb(
              event_type                   => 'AFTER_DEPRN',
              asset_id                     => l_asset_id_tbl(i),
              group_asset_id               => l_group_asset_id_tbl(i),
              book_type_code               => p_book_type_code,
              asset_type                   => l_asset_type_tbl(i),
              depreciate_flag              => l_depreciate_flag_tbl(i),
              method_code                  => l_method_code_tbl(i),
              life_in_months               => l_life_in_months_tbl(i),
              method_id                    => l_method_id_tbl(i),
              method_type                  => l_method_type_tbl(i),
              calc_basis                   => l_calc_basis_tbl(i),
              adjustment_amount            => 0,
              transaction_flag             => null,
              cost                         => l_cost_tbl(i),
              salvage_value                => l_salvage_value_tbl(i),
              recoverable_cost             => l_recoverable_cost_tbl(i),
              adjusted_cost                => l_adjusted_cost_tbl(i),
              current_total_rsv            => l_current_total_rsv_tbl(i),
              current_rsv                  => l_current_rsv_tbl(i),
              current_total_ytd            => l_current_total_ytd_tbl(i),
              current_ytd                  => 0,
              hyp_basis                    => 0,
              hyp_total_rsv                => l_hyp_total_rsv_tbl(i),
              hyp_rsv                      => 0,
              hyp_total_ytd                => 0,
              hyp_ytd                      => 0,
              old_adjusted_cost            => l_old_adjusted_cost_tbl(i),
              old_raf                      => l_old_raf_tbl(i),
              old_formula_factor           => l_old_formula_factor_tbl(i),
              new_adjusted_cost            => l_new_adjusted_cost_tbl(i),
              new_raf                      => l_new_raf_tbl(i),
              new_formula_factor           => l_new_formula_factor_tbl(i),
              p_period_counter             => l_period_num,
              p_fiscal_year                => l_fiscal_year,
              p_eofy_reserve               => l_eofy_reserve_tbl(i),
              p_tracking_method            => l_tracking_method_tbl(i),
              p_eofy_flag                  => l_eofy_flag,
              p_polish_rule                => l_polish_rule_tbl(i),
              p_impairment_reserve         => l_impairment_reserve_tbl(i), -- P2IAS36
              p_mrc_sob_type_code          => l_mrc_sob_type_code,
              p_set_of_books_id            => p_set_of_books_id
            );
            if l_status <> 0 then
               raise mass_faxccdb_err;
            end if;
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'after faxccdb',1, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,'new adj_cost',
   			l_new_adjusted_cost_tbl(i));
            end if;

         end if; -- if ((l_eofy_flag = 'N') and -- Bug4940246

      end loop;

      -- Update fa_books with the new values.  Business rules are:
      -- 1. Do not update fa_books for any value if polish asset
      -- 2. Only update eop_adj_cost, eop_formula_factor, adjusted_capacity,
      --    old_adjusted_capacity if period_update_flag or
      --    exclude_fully_reserve_flag is Yes
      -- 3. Only update eofy_adj_cost and eofy_formula_factor if eofy_flag
      --    is Yes
      -- 4. Update eofy_adj_cost and eofy_formula_factor if the following:
      --    a. eofy_flag is Yes and period_update_flag is No and
      --       deprn_basis_rule is NBV and deprn_basis_rule_id exists
      -- 5. Update eofy_reserve and prior_eofy_reserve if the following:
      --    a. eofy_flag is Yes and period_update_flag is No and
      --       deprn_basis_rule is NBV and deprn_basis_rule_id exists
      --    b. period_update_flag is Yes or exclude_fully_reserve_flag is Yes
      --       or deprn_basis_rule is COST or deprn_basis_rule_id doesn't exist
      --

      if (g_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,'BEGIN',5, p_log_level_rec => g_log_level_rec);
      end if;

      if (l_mrc_sob_type_code = 'R') then

         if (l_eofy_flag = 'Y') then

            forall i IN 1..l_asset_id_tbl.count
            update fa_mc_books
            set    adjusted_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_adjusted_cost_tbl(i), 0),
                      l_old_adjusted_cost_tbl(i)),
                   formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_formula_factor_tbl(i), 1),
                      l_old_formula_factor_tbl(i)),
                   eofy_adj_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         l_old_adjusted_cost_tbl(i),
                      eofy_adj_cost),
                   eofy_formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         l_new_formula_factor_tbl(i),
                      eofy_formula_factor),
                   eofy_reserve = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_current_total_rsv_tbl(i), 0),
                      eofy_reserve),
                   prior_eofy_reserve = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_eofy_reserve_tbl(i), 0),
                      prior_eofy_reserve),
                   eop_adj_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                               eop_adj_cost)),
                      eop_adj_cost),
                   eop_formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                                eop_formula_factor)),
                      eop_formula_factor),
                   adjusted_capacity = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                               adjusted_capacity)),
                      adjusted_capacity)
            where  rowid = l_bks_rowid_tbl(i);

         else

            forall i IN 1..l_asset_id_tbl.count
            update fa_mc_books
            set    adjusted_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_adjusted_cost_tbl(i), 0),
                      l_old_adjusted_cost_tbl(i)),
                   formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_formula_factor_tbl(i), 1),
                      l_old_formula_factor_tbl(i)),
                   prior_eofy_reserve = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_eofy_reserve_tbl(i), 0),
                      prior_eofy_reserve),
                   eop_adj_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                               eop_adj_cost)),
                      eop_adj_cost),
                   eop_formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                                eop_formula_factor)),
                      eop_formula_factor),
                   adjusted_capacity = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                               adjusted_capacity)),
                      adjusted_capacity)
            where  rowid = l_bks_rowid_tbl(i);

         end if;
      else

         if (g_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,'BEGIN',6, p_log_level_rec => g_log_level_rec);
         end if;
         if (l_eofy_flag = 'Y') then

            forall i IN 1..l_asset_id_tbl.count
            update fa_books
            set    adjusted_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_adjusted_cost_tbl(i), 0),
                      l_old_adjusted_cost_tbl(i)),
                   formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_formula_factor_tbl(i), 1),
                      l_old_formula_factor_tbl(i)),
                   eofy_adj_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         l_old_adjusted_cost_tbl(i),
                      eofy_adj_cost),
                   eofy_formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         l_new_formula_factor_tbl(i),
                      eofy_formula_factor),
                   eofy_reserve = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_current_total_rsv_tbl(i), 0),
                      eofy_reserve),
                   prior_eofy_reserve = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_eofy_reserve_tbl(i), 0),
                      prior_eofy_reserve),
                   eop_adj_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                               eop_adj_cost)),
                      eop_adj_cost),
                   eop_formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                                eop_formula_factor)),
                      eop_formula_factor),
                   adjusted_capacity = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                               adjusted_capacity)),
                      adjusted_capacity)
            where  rowid = l_bks_rowid_tbl(i);

         else

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'BEGIN',7, p_log_level_rec => g_log_level_rec);
            end if;

            forall i IN 1..l_asset_id_tbl.count
            update fa_books
            set    adjusted_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_adjusted_cost_tbl(i), 0),
                      l_old_adjusted_cost_tbl(i)),
                   formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_new_formula_factor_tbl(i), 1),
                      l_old_formula_factor_tbl(i)),
                   prior_eofy_reserve = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         nvl(l_eofy_reserve_tbl(i), 0),
                      prior_eofy_reserve),
                   eop_adj_cost = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_old_adjusted_cost_tbl(i), 0),
                               eop_adj_cost)),
                      eop_adj_cost),
                   eop_formula_factor = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_eofy_formula_factor_tbl(i), 1),
                                eop_formula_factor)),
                      eop_formula_factor),
                   adjusted_capacity = decode (l_polish_rule_tbl(i),
                      FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                         decode (l_period_update_flag_tbl(i),
                            'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                            decode (l_exclude_fully_rsv_flag_tbl(i),
                               'Y', nvl(l_new_adjusted_capacity_tbl(i), 0),
                               adjusted_capacity)),
                      adjusted_capacity)
            where  rowid = l_bks_rowid_tbl(i);

         end if;

      end if;

      -- Bug:5930979:Japan Tax Reform Project
      if (l_mrc_sob_type_code <> 'R') then

	 if (g_log_level_rec.statement_level) then
	    fa_debug_pkg.add(l_calling_fn,'++++ eofy_flag', l_eofy_flag, p_log_level_rec => g_log_level_rec);
         end if;

         if (l_eofy_flag = 'Y') then

	    for i IN 1..l_asset_id_tbl.count loop

     	       if (g_log_level_rec.statement_level) then
		  fa_debug_pkg.add(l_calling_fn,'++++ asset_id', l_asset_id_tbl(i));
                  fa_debug_pkg.add(l_calling_fn,'++++ guarantee_rate_method_flag', l_guarantee_rate_flag_tbl(i));
               end if;

	       if nvl(l_guarantee_rate_flag_tbl(i),'NO') = 'YES' then

			  FA_CDE_PKG.faxgfr (X_Book_Type_Code => p_book_type_code,
                           X_Asset_Id               => l_asset_id_tbl(i),
                           X_Short_Fiscal_Year_Flag => NULL,
                           X_Conversion_Date        => NULL,
                           X_Prorate_Date           => NULL,
                           X_Orig_Deprn_Start_Date  => NULL,
                           C_Prorate_Date           => NULL,
                           C_Conversion_Date        => NULL,
                           C_Orig_Deprn_Start_Date  => NULL,
                           X_Method_Code            => l_method_code_tbl(i),
                           X_Life_In_Months         => l_life_in_months_tbl(i),
                           X_Fiscal_Year            => -99,
         		   X_Current_Period	    => -99,
			   X_calling_interface      => 'DEPRN_END',
                           X_Rate                   => l_rate_in_use_tbl(i),
                           X_Method_Type            => l_method_type,
                           X_Success                => l_success,
                           p_log_level_rec          => g_log_level_rec);

                          if (l_success <= 0) then
                              fa_srvr_msg.add_message(calling_fn => 'FA_MASS_DEPRN_BASIS_PKG.mass_faxccdb',  p_log_level_rec => g_log_level_rec);
                               raise mass_faxccdb_err;
                         end if;
		 else
		        l_rate_in_use_tbl(i) := NULL;
	         end if;  -- if l_guarantee_rate_flag_tbl
	      end loop;

     	    forall i IN 1..l_bks_rowid_tbl.count
            update fa_books
		    set rate_in_use = l_rate_in_use_tbl(i)
  		    where rowid = l_bks_rowid_tbl(i)
			and l_guarantee_rate_flag_tbl(i) = 'YES';

         end if;  -- if l_eofy_flag = 'Y'
      end if; -- if l_mrc_sob_type <> 'R'
      -- Bug:5930979:Japan Tax Reform Project (End)

      l_bks_rowid_tbl.delete;
      l_asset_id_tbl.delete;
      l_group_asset_id_tbl.delete;
      l_asset_type_tbl.delete;
      l_depreciate_flag_tbl.delete;
      l_method_code_tbl.delete;
      l_life_in_months_tbl.delete;
      l_method_id_tbl.delete;
      l_method_type_tbl.delete;
      l_calc_basis_tbl.delete;
      l_cost_tbl.delete;
      l_salvage_value_tbl.delete;
      l_recoverable_cost_tbl.delete;
      l_adjusted_cost_tbl.delete;
      l_current_total_rsv_tbl.delete;
      l_current_rsv_tbl.delete;
      l_current_total_ytd_tbl.delete;
      l_hyp_total_rsv_tbl.delete;
      l_old_adjusted_cost_tbl.delete;
      l_old_raf_tbl.delete;
      l_old_formula_factor_tbl.delete;
      l_new_adjusted_cost_tbl.delete;
      l_new_raf_tbl.delete;
      l_new_formula_factor_tbl.delete;
      l_eofy_reserve_tbl.delete;
      l_tracking_method_tbl.delete;
      l_eofy_formula_factor_tbl.delete;
      l_adjusted_capacity_tbl.delete;
      l_new_adjusted_capacity_tbl.delete;
      l_exclude_fully_rsv_flag_tbl.delete;
      l_deprn_basis_rule_id_tbl.delete;
      l_period_update_flag_tbl.delete;
      l_polish_rule_tbl.delete;

      -- Bug:5930979:Japan Tax Reform Project
      l_rate_in_use_tbl.delete;
      l_guarantee_rate_flag_tbl.delete;
      commit;

      if (l_rows_processed < c_batch_size) then exit; end if;

   end loop;

  if (l_mrc_sob_type_code = 'R') then
      close c_mc_assets;
   else
      close c_assets;
   end if;


   x_return_status := 0;

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'END',1, p_log_level_rec => g_log_level_rec);
   end if;


EXCEPTION
   WHEN mass_faxccdb_err then
        rollback;
        x_return_status := -1;
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_addition_pub.do_all_books', p_log_level_rec => g_log_level_rec);

      rollback;

      x_return_status := -1;

END mass_faxccdb;

END FA_MASS_DEPRN_BASIS_PKG;


/
