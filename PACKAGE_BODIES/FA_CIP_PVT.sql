--------------------------------------------------------
--  DDL for Package Body FA_CIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CIP_PVT" as
/* $Header: FAVCIPB.pls 120.21.12010000.8 2010/04/29 12:54:06 dvjoshi ship $   */

g_cap_event_id  number;
g_cap_thid      number;
g_event_status  varchar2(1);

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION do_validation
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec           IN     FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION do_cap_rev
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    px_asset_type_rec         IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec          IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec_old        FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new        FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_old      FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_adj      FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new      FA_API_TYPES.asset_deprn_rec_type;
   l_inv_trans_rec            FA_API_TYPES.inv_trans_rec_type;

   l_old_transaction_type_code varchar2(30);
   l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

   l_rowid                    rowid;
   l_status                   boolean;
   l_ret_status               varchar2(1);
   l_calling_fn               varchar2(30) := 'fa_cip_pvt.do_cap_rev';
   l_amount_inserted          number;

   l_adj                      fa_adjust_type_pkg.fa_adj_row_struct;
   l_clear_adj                fa_adjust_type_pkg.fa_adj_row_struct;

   -- Japan Tax CIP Enhancement 6688475
   l_method_type              number := 0;
   l_success                  integer;
   l_rate_in_use              number;

   cap_rev_err                exception;

   l_adj_row_rec              FA_ADJUSTMENTS%rowtype;

   CURSOR c_mrc_adjustments (p_thid number) IS
   SELECT code_combination_id    ,
          distribution_id        ,
          debit_credit_flag      ,
          adjustment_amount      ,
          adjustment_type
     FROM fa_mc_adjustments
    WHERE transaction_header_id = p_thid
      AND set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   CURSOR c_adjustments (p_thid number) IS
   SELECT code_combination_id    ,
          distribution_id        ,
          debit_credit_flag      ,
          adjustment_amount      ,
          adjustment_type
     FROM fa_adjustments
    WHERE transaction_header_id = p_thid;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'calling do val', '', p_log_level_rec => p_log_level_rec);
   end if;

   -- do validation is this is the primary book
   if (p_mrc_sob_type_code <> 'R') then
      if not do_validation
             (p_trans_rec            => px_trans_rec,
              p_asset_hdr_rec        => p_asset_hdr_rec,
              p_asset_fin_rec        => px_asset_fin_rec,
              p_log_level_rec        => p_log_level_rec) then
         raise cap_rev_err;
      end if;
   end if;

   -- SLA uptake
   -- need the thid before calc engine
   if (p_mrc_sob_type_code <> 'R') then
      select fa_transaction_headers_s.nextval
        into px_trans_rec.transaction_header_id
        from dual;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'calling get_fin_info', '', p_log_level_rec => p_log_level_rec);
   end if;

   -- for reverse, set the new fin info = the old
   -- for capitalizing, call calculation engine which will handle differences
   -- in redefaults due to reverse/cap (i.e. ccbd/salvage)
   -- including the life derivation for child assets
   --   (baiscally reversals are untouched caps are recalculated)
   --
   -- period of addition has been set using absolute mode
   -- meaning is this the period in which asset was first added

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'calling calc engine', '', p_log_level_rec => p_log_level_rec);
   end if;

   l_asset_fin_rec_old := p_asset_fin_rec_old;

   if (px_trans_rec.transaction_type_code = 'ADDITION') then

      -- the calculation engine needs info in the adj struct (esp for additions)
      -- initialize only the not derived values

      l_asset_fin_rec_adj.date_placed_in_service := px_asset_fin_rec.date_placed_in_service;
-- BUG 4553782
      l_asset_fin_rec_adj.deprn_method_code       := px_asset_fin_rec.deprn_method_code;
      l_asset_fin_rec_adj.life_in_months          := px_asset_fin_rec.life_in_months;
      l_asset_fin_rec_adj.basic_rate              := px_asset_fin_rec.basic_rate;
      l_asset_fin_rec_adj.adjusted_rate           := px_asset_fin_rec.adjusted_rate;
      l_asset_fin_rec_adj.prorate_convention_code := px_asset_fin_rec.prorate_convention_code;
      l_asset_fin_rec_adj.depreciate_flag         := px_asset_fin_rec.depreciate_flag;
      l_asset_fin_rec_adj.bonus_rule              := px_asset_fin_rec.bonus_rule;
      l_asset_fin_rec_adj.ceiling_name            := px_asset_fin_rec.ceiling_name;
--      l_asset_fin_rec_adj.production_capacity     := px_asset_fin_rec.production_capacity; -- bug8247611
      l_asset_fin_rec_adj.unit_of_measure         := px_asset_fin_rec.unit_of_measure;
-- END BUG

      -- null out the old struct before calc call
      -- defaulting within calc engine has been removed for group
      --  values are passed to adj_struct in public api
      --
      -- l_asset_fin_rec_old := NULL;

      -- SLA Uptake
      -- as with FAPADDB.pls, we need to insure prior fy expense is 0
      -- not null to get catchup

      -- should be ok with following:
      --  l_asset_deprn_rec_old.prior_fy_expense := 0;

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => p_asset_hdr_rec ,
               px_asset_deprn_rec      => l_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => p_mrc_sob_type_code
               ,p_log_level_rec => p_log_level_rec) then raise cap_rev_err;
      end if;


      -- SLA Uptake - sense new asset type to calc engine to
      -- force catchup from faxexp

      l_asset_type_rec.asset_type := 'CAPITALIZED';

   if (p_log_level_rec.statement_level) then

      fa_debug_pkg.add(l_calling_fn,
                     'before calc_fin_info adj life', l_asset_fin_rec_adj.life_in_months, p_log_level_rec => p_log_level_rec);
   end if;


      if not FA_ASSET_CALC_PVT.calc_fin_info
                 (px_trans_rec              => px_trans_rec,
                  p_inv_trans_rec           => l_inv_trans_rec,
                  p_asset_hdr_rec           => p_asset_hdr_rec ,
                  p_asset_desc_rec          => p_asset_desc_rec,
                  p_asset_type_rec          => l_asset_type_rec,
                  p_asset_cat_rec           => p_asset_cat_rec,
                  p_asset_fin_rec_old       => l_asset_fin_rec_old,
                  p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                  px_asset_fin_rec_new      => l_asset_fin_rec_new,
                  p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                  p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                  px_asset_deprn_rec_new    => l_asset_deprn_rec_new,
                  p_period_rec              => p_period_rec,
                  p_mrc_sob_type_code       => p_mrc_sob_type_code,
		  p_group_reclass_options_rec => l_group_reclass_options_rec,
                  p_calling_fn              => l_calling_fn
                 , p_log_level_rec => p_log_level_rec) then raise cap_rev_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                       'after calc_fin_info', l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec);

         fa_debug_pkg.add(l_calling_fn,
                          'after calc_engine, cost', l_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
      end if;

      -- insure original cost is reset
      l_asset_fin_rec_new.original_cost              := l_asset_fin_rec_new.cost;
      l_asset_fin_rec_new.period_counter_capitalized := p_period_rec.period_counter;

      /*
      --Bug 7300699:
      --Ensure subcomponent life is correctly derived.
      --fazccbd should have been called in the public api.
      --Contrary to comments above, child life is not derived in calc_fin_info
      --and it does not make sense to do it there for this purpose anyway.
     */
      if (nvl(fa_cache_pkg.fazccbd_record.subcomponent_life_rule, 'NULL') <> 'NULL' and
            nvl(p_asset_desc_rec.parent_asset_id, -99) <> -99) then

           if not FA_ASSET_CALC_PVT.calc_subcomp_life
                    (p_trans_rec                => px_trans_rec,
                     p_asset_hdr_rec            => p_asset_hdr_rec,
                     p_asset_cat_rec            => p_asset_cat_rec,
                     p_asset_desc_rec           => p_asset_desc_rec,
                     p_period_rec               => p_period_rec,
                     px_asset_fin_rec           => l_asset_fin_rec_new,
                     p_calling_fn               => l_calling_fn
                    , p_log_level_rec => p_log_level_rec) then
              raise cap_rev_err;
           end if;
      end if; -- (nvl(fa_cache_pkg.fazccbd_recor ...

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'after calc_subcomp_life', l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec);
      end if;

   else -- reverse

      l_asset_fin_rec_new                            := l_asset_fin_rec_old;
      l_asset_fin_rec_new.annual_deprn_rounding_flag := NULL;
      l_asset_fin_rec_new.period_counter_capitalized := NULL;

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'period_of_addition', p_asset_hdr_rec.period_of_addition , p_log_level_rec => p_log_level_rec);
   end if;

   if (p_asset_hdr_rec.period_of_addition = 'Y' and
       G_release = 11) then

      -- use table handler due to mrc!!!!!

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'calling book update_row','', p_log_level_rec => p_log_level_rec);
      end if;

      -- Bug4483408: Recoverable_cost was passed as X_Adjusted_Cost and now it
      -- uses adjusted_cost returned from calc_fin_info.

      FA_BOOKS_PKG.Update_Row(
             X_book_type_code                 => p_asset_hdr_rec.book_type_code,
             X_asset_id                       => p_asset_hdr_rec.asset_id,
             X_Date_Placed_In_Service         => l_asset_fin_rec_new.date_placed_in_service,
             X_Deprn_Start_Date               => l_asset_fin_rec_new.deprn_start_date,
             X_Deprn_Method_Code              => l_asset_fin_rec_new.deprn_method_code,
             X_Life_In_Months                 => nvl(l_asset_fin_rec_new.life_in_months,FND_API.G_MISS_NUM), --bug7416326
             X_Adjusted_Cost                  => l_asset_fin_rec_new.adjusted_cost,
             X_Original_Cost                  => l_asset_fin_rec_new.original_cost,
             X_Salvage_Value                  => l_asset_fin_rec_new.salvage_value,
             X_Prorate_Convention_Code        => l_asset_fin_rec_new.prorate_convention_code,  -- same in both???
             X_Prorate_Date                   => l_asset_fin_rec_new.prorate_date,
             X_Cost_Change_Flag               => l_asset_fin_rec_new.cost_change_flag,
             X_Adjustment_Required_Status     => l_asset_fin_rec_new.adjustment_required_status,
             X_Capitalize_Flag                => l_asset_fin_rec_new.capitalize_flag,
             X_Depreciate_Flag                => l_asset_fin_rec_new.depreciate_flag,
             X_Disabled_Flag                  => l_asset_fin_rec_new.disabled_flag,--HH
             X_Basic_Rate                     => l_asset_fin_rec_new.basic_rate,
             X_Adjusted_Rate                  => l_asset_fin_rec_new.adjusted_rate,
             X_Bonus_Rule                     => l_asset_fin_rec_new.bonus_rule,
             X_Ceiling_Name                   => l_asset_fin_rec_new.ceiling_name,
             X_Recoverable_Cost               => l_asset_fin_rec_new.recoverable_cost,
             X_Adjusted_Capacity              => l_asset_fin_rec_new.production_capacity,
             X_Period_Counter_Capitalized     => l_asset_fin_rec_new.period_counter_capitalized,
             X_Production_Capacity            => l_asset_fin_rec_new.production_capacity,
             X_Unit_Of_Measure                => l_asset_fin_rec_new.unit_of_measure,
             X_Annual_Deprn_Rounding_Flag     => l_asset_fin_rec_new.annual_deprn_rounding_flag,
             X_Percent_Salvage_Value          => l_asset_fin_rec_new.percent_salvage_value,
             X_Allowed_Deprn_Limit            => l_asset_fin_rec_new.allowed_deprn_limit,
             X_Allowed_Deprn_Limit_Amount     => l_asset_fin_rec_new.allowed_deprn_limit_amount,
             X_Adjusted_Recoverable_Cost      => l_asset_fin_rec_new.adjusted_recoverable_cost,
             X_Group_Asset_ID                 => l_asset_fin_rec_new.group_asset_id,
             X_mrc_sob_type_code              => p_mrc_sob_type_code,
             X_set_of_books_id                => p_asset_hdr_rec.set_of_books_id,
             X_Calling_Fn                     => l_calling_fn,
             p_log_level_rec                  => p_log_level_rec);

      -- Japan Tax CIP Enhancement 6688475 (Start)
      if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES'
         and (px_trans_rec.transaction_type_code <> 'CIP REVERSE') then

         FA_CDE_PKG.faxgfr (X_Book_Type_Code         => p_asset_hdr_rec.book_type_code,
                           X_Asset_Id               => p_asset_hdr_rec.asset_id,
                           X_Short_Fiscal_Year_Flag => l_asset_fin_rec_new.short_fiscal_year_flag,
                           X_Conversion_Date        => l_asset_fin_rec_new.conversion_date,
                           X_Prorate_Date           => l_asset_fin_rec_new.prorate_date,
                           X_Orig_Deprn_Start_Date  => l_asset_fin_rec_new.orig_deprn_start_date,
                           C_Prorate_Date           => NULL,
                           C_Conversion_Date        => NULL,
                           C_Orig_Deprn_Start_Date  => NULL,
                           X_Method_Code            => l_asset_fin_rec_new.deprn_method_code,
                           X_Life_In_Months         => l_asset_fin_rec_new.life_in_months,
                           X_Fiscal_Year            => -99,
                           X_Current_Period	    => l_asset_fin_rec_new.period_counter_capitalized,
                           X_calling_interface      => 'ADDITION',
                           X_Rate                   => l_rate_in_use,
                           X_Method_Type            => l_method_type,
                           X_Success                => l_success, p_log_level_rec => p_log_level_rec);

         if (l_success <= 0) then
            fa_srvr_msg.add_message(calling_fn => 'fa_cip_pvt.do_cap_rev',  p_log_level_rec => p_log_level_rec);
            raise cap_rev_err;
         end if;

         UPDATE FA_BOOKS
         SET rate_in_use = l_rate_in_use
         WHERE book_type_code = p_asset_hdr_rec.book_type_code
         AND asset_id = p_asset_hdr_rec.asset_id
         AND date_ineffective is null;

      end if;
      -- Japan Tax CIP Enhancement 6688475 (End)

      -- use table handler!!!!
      if (p_mrc_sob_type_code <> 'R') then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'setting trx info','', p_log_level_rec => p_log_level_rec);
      end if;


         if (px_trans_rec.transaction_type_code = 'ADDITION') then
             px_trans_rec.transaction_date_entered := px_asset_fin_rec.date_placed_in_service;
         end if;

         if (px_trans_rec.transaction_type_code = 'CIP REVERSE') then
            px_trans_rec.transaction_type_code := 'CIP ADDITION';
            l_old_transaction_type_code        := 'ADDITION';
            px_asset_type_rec.asset_type        := 'CIP';
         else
            px_trans_rec.transaction_type_code := 'ADDITION';
            l_old_transaction_type_code        := 'CIP ADDITION';
            px_asset_type_rec.asset_type        := 'CAPITALIZED';
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'calling trx update_row','', p_log_level_rec => p_log_level_rec);
         end if;

         -- fix for 4541467
         select rowid
         into l_rowid
         from fa_transaction_headers
         where asset_id = p_asset_hdr_rec.asset_id
         and   book_type_code = p_asset_hdr_rec.book_type_code
         and   transaction_type_code = l_old_transaction_type_code;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'got rowid before trx update_row','', p_log_level_rec => p_log_level_rec);
         end if;


         FA_TRANSACTION_HEADERS_PKG.Update_row
                    (X_Rowid                         => l_rowid,
                     X_Book_Type_Code                => p_asset_hdr_rec.book_type_code,
                     X_Asset_Id                      => p_asset_hdr_rec.asset_id,
                     X_Transaction_Type_Code         => px_trans_rec.transaction_type_code,
                     X_Transaction_Date_Entered      => px_asset_fin_rec.date_placed_in_service,
                     X_Calling_Fn                    => l_calling_fn
                    , p_log_level_rec => p_log_level_rec);

         if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'calling book ah update_row','', p_log_level_rec => p_log_level_rec);
            end if;

            fa_asset_history_pkg.update_row
               (X_asset_id           => p_asset_hdr_rec.asset_id,
                X_asset_type         => px_asset_type_rec.asset_type,
                X_last_update_date   => px_trans_rec.who_info.last_update_date,
                X_last_updated_by    => px_trans_rec.who_info.last_updated_by,
                X_Return_Status      => l_status,
                X_calling_fn         => l_calling_fn, p_log_level_rec => p_log_level_rec);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'calling book ad update_row','', p_log_level_rec => p_log_level_rec);
            end if;

            fa_additions_pkg.update_row
               (X_asset_id           => p_asset_hdr_rec.asset_id,
                X_asset_type         => px_asset_type_rec.asset_type,
                X_last_update_date   => px_trans_rec.who_info.last_update_date,
                X_last_updated_by    => px_trans_rec.who_info.last_updated_by,
                X_last_update_login  => px_trans_rec.who_info.last_update_login,
                X_return_status      => l_status,
                X_calling_fn         => l_calling_fn, p_log_level_rec => p_log_level_rec);

            -- Added update for bug 4541467
            update fa_transaction_headers
            set transaction_date_entered = px_asset_fin_rec.date_placed_in_service
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_type_code = 'TRANSFER IN';

         end if;

      end if;

   else  -- asset originally added in prior period

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'in prior period logic','', p_log_level_rec => p_log_level_rec);
      end if;

      if (p_mrc_sob_type_code <> 'R') then

         -- trx_types are already set correctly
         if (px_trans_rec.transaction_type_code = 'CIP REVERSE') then
            px_asset_type_rec.asset_type := 'CIP';
         else
            px_asset_type_rec.asset_type := 'CAPITALIZED';
            px_trans_rec.transaction_date_entered := px_asset_fin_rec.date_placed_in_service;
         end if;

        if (px_trans_rec.transaction_type_code = 'CIP REVERSE' and
            G_release <> 11) then

             if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'checking','event status'
				,p_log_level_rec => p_log_level_rec);
             end if;

             select event_id,
                    transaction_header_id
               into g_cap_event_id,
                    g_cap_thid
               from fa_transaction_headers
              where asset_id              = p_asset_hdr_rec.asset_id
                and book_type_code        = p_asset_hdr_rec.book_type_code
                and transaction_type_code = 'ADDITION';

             if (g_cap_event_id is not null) then

                if not fa_xla_events_pvt.get_trx_event_status
                         (p_set_of_books_id       => p_asset_hdr_rec.set_of_books_id
                         ,p_transaction_header_id => g_cap_thid
                         ,p_event_id              => g_cap_event_id
                         ,p_book_type_code        => p_asset_hdr_rec.book_type_code
                         ,x_event_status          => g_event_status
                         ,p_log_level_rec         => p_log_level_rec) then
                   raise cap_rev_err;
                end if;

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'event status ', g_event_status
                                      ,p_log_level_rec => p_log_level_rec);
                end if;

             end if;

         end if;


         -- SLA UPTAKE
         -- assign an event for the transaction
         -- always for cap, only if not deleting for rev

         if ((px_trans_rec.transaction_type_code = 'CIP REVERSE' and
              g_event_status = FA_XLA_EVENTS_PVT.C_EVENT_PROCESSED) OR
             px_trans_rec.transaction_type_code <> 'CIP REVERSE') then

            if not fa_xla_events_pvt.create_transaction_event
                 (p_asset_hdr_rec => p_asset_hdr_rec,
                  p_asset_type_rec=> px_asset_type_rec,
                  px_trans_rec    => px_trans_rec,
                  p_event_status  => NULL,
                  p_calling_fn    => l_calling_fn
                  ,p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

         elsif (px_trans_rec.transaction_type_code = 'CIP REVERSE' and
                 g_event_status <> FA_XLA_EVENTS_PVT.C_EVENT_PROCESSED) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'deleting capitalization event',
                                g_cap_thid
                                ,p_log_level_rec => p_log_level_rec);
            end if;

            -- now handle event impacts
            -- create the event for the transaction

            if not fa_xla_events_pvt.delete_transaction_event
              (p_ledger_id             => fa_cache_pkg.fazcbc_record.set_of_books_id,
               p_transaction_header_id => g_cap_thid,
               p_book_type_code        => p_asset_hdr_rec.book_type_code,
               p_asset_type            => px_asset_type_rec.asset_type, --bug 8630242/8678674
               p_calling_fn            => l_calling_fn
               ,p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'deleting accounting impacts for cap thid',
                                g_cap_thid
                                ,p_log_level_rec => p_log_level_rec);
            end if;

            update fa_transaction_headers
               set event_id = NULL
             where transaction_header_id = g_cap_thid;

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'calling trx insert_row','', p_log_level_rec => p_log_level_rec);
         end if;

         FA_TRANSACTION_HEADERS_PKG.Insert_Row
                      (X_Rowid                          => l_rowid,
                       X_Transaction_Header_Id          => px_trans_rec.transaction_header_id,
                       X_Book_Type_Code                 => p_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => p_asset_hdr_rec.asset_id,
                       X_Transaction_Type_Code          => px_trans_rec.transaction_type_code,
                       X_Transaction_Date_Entered       => px_trans_rec.transaction_date_entered,
                       X_Date_Effective                 => px_trans_rec.who_info.creation_date,
                       X_Last_Update_Date               => px_trans_rec.who_info.last_update_date,
                       X_Last_Updated_By                => px_trans_rec.who_info.last_updated_by,
                       X_Transaction_Name               => px_trans_rec.transaction_name,
                       X_Invoice_Transaction_Id         => null,
                       X_Source_Transaction_Header_Id   => px_trans_rec.Source_Transaction_Header_Id,
                       X_Mass_Reference_Id              => px_trans_rec.mass_reference_id,
                       X_Last_Update_Login              => px_trans_rec.who_info.last_update_login,
                       X_Transaction_Subtype            => null,
                       X_Attribute1                     => px_trans_rec.desc_flex.attribute1,
                       X_Attribute2                     => px_trans_rec.desc_flex.attribute2,
                       X_Attribute3                     => px_trans_rec.desc_flex.attribute3,
                       X_Attribute4                     => px_trans_rec.desc_flex.attribute4,
                       X_Attribute5                     => px_trans_rec.desc_flex.attribute5,
                       X_Attribute6                     => px_trans_rec.desc_flex.attribute6,
                       X_Attribute7                     => px_trans_rec.desc_flex.attribute7,
                       X_Attribute8                     => px_trans_rec.desc_flex.attribute8,
                       X_Attribute9                     => px_trans_rec.desc_flex.attribute9,
                       X_Attribute10                    => px_trans_rec.desc_flex.attribute10,
                       X_Attribute11                    => px_trans_rec.desc_flex.attribute11,
                       X_Attribute12                    => px_trans_rec.desc_flex.attribute12,
                       X_Attribute13                    => px_trans_rec.desc_flex.attribute13,
                       X_Attribute14                    => px_trans_rec.desc_flex.attribute14,
                       X_Attribute15                    => px_trans_rec.desc_flex.attribute15,
                       X_Attribute_Category_Code        => px_trans_rec.desc_flex.attribute_category_code,
                       X_Transaction_Key                => null,
                       X_Amortization_Start_Date        => null,
                       X_Calling_Interface              => px_trans_rec.calling_interface,
                       X_Mass_Transaction_ID            => px_trans_rec.mass_transaction_id,
                       X_Trx_Reference_Id               => px_trans_rec.trx_reference_id,
                       X_Event_Id                       => px_trans_rec.event_id,
                       X_Return_Status                  => l_status,
                       X_Calling_Fn                     => l_calling_fn
                      , p_log_level_rec => p_log_level_rec);

         if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'calling ah update_row, thid out',px_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
            end if;

            fa_asset_history_pkg.update_row
               (X_asset_id                  => p_asset_hdr_rec.asset_id,
                X_transaction_header_id_out => px_trans_rec.transaction_header_id,
                X_date_ineffective          => px_trans_rec.who_info.last_update_date,
                X_last_update_date          => px_trans_rec.who_info.last_update_date,
                X_last_updated_by           => px_trans_rec.who_info.last_updated_by,
                X_Return_Status             => l_status,
                X_calling_fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'calling ah insert_row','', p_log_level_rec => p_log_level_rec);
            end if;

            fa_asset_history_pkg.insert_row(
                X_Rowid                     => l_rowid,
                X_Asset_Id                  => p_asset_hdr_rec.asset_id,
                X_Category_Id               => p_asset_cat_rec.category_id,
                X_Asset_Type                => px_asset_type_rec.asset_type,
                X_Units                     => p_asset_desc_rec.current_units,
                X_Date_Effective            => px_trans_rec.who_info.last_update_date,
                X_Date_Ineffective          => null,
                X_Transaction_Header_Id_In  => px_trans_rec.transaction_header_id,
                X_Transaction_Header_Id_Out => null,
                X_Last_Update_Date          => px_trans_rec.who_info.last_update_date,
                X_Last_Updated_By           => px_trans_rec.who_info.last_updated_by,
                X_Last_Update_Login         => px_trans_rec.who_info.last_update_login,
                X_Return_Status             => l_status,
                X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

         end if;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'calling bk deactivate_row','', p_log_level_rec => p_log_level_rec);
      end if;

      -- use table handler for mrc
      fa_books_pkg.deactivate_row
        (X_asset_id                  => p_asset_hdr_rec.asset_id,
         X_book_type_code            => p_asset_hdr_rec.book_type_code,
         X_transaction_header_id_out => px_trans_rec.transaction_header_id,
         X_date_ineffective          => px_trans_rec.who_info.last_update_date,
         X_mrc_sob_type_code         => p_mrc_sob_type_code,
         X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
         X_Calling_Fn                => l_calling_fn
         , p_log_level_rec => p_log_level_rec);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'calling bk insert_row','', p_log_level_rec => p_log_level_rec);
      end if;

      fa_books_pkg.insert_row
         (X_Rowid                        => l_rowid,
          X_Book_Type_Code               => p_asset_hdr_rec.book_type_code,
          X_Asset_Id                     => p_asset_hdr_rec.asset_id,
          X_Date_Placed_In_Service       => l_asset_fin_rec_new.date_placed_in_service,
          X_Date_Effective               => px_trans_rec.who_info.last_update_date,
          X_Deprn_Start_Date             => l_asset_fin_rec_new.deprn_start_date,
          X_Deprn_Method_Code            => l_asset_fin_rec_new.deprn_method_code,
          X_Life_In_Months               => l_asset_fin_rec_new.life_in_months,
          X_Rate_Adjustment_Factor       => l_asset_fin_rec_new.rate_adjustment_factor,
          X_Adjusted_Cost                => l_asset_fin_rec_new.adjusted_cost,
          X_Cost                         => l_asset_fin_rec_new.cost,
          X_Original_Cost                => l_asset_fin_rec_new.original_cost,
          X_Salvage_Value                => l_asset_fin_rec_new.salvage_value,
          X_Prorate_Convention_Code      => l_asset_fin_rec_new.prorate_convention_code,
          X_Prorate_Date                 => l_asset_fin_rec_new.prorate_date,
          X_Cost_Change_Flag             => l_asset_fin_rec_new.cost_change_flag,
          X_Adjustment_Required_Status   => l_asset_fin_rec_new.adjustment_required_status,
          X_Capitalize_Flag              => l_asset_fin_rec_new.capitalize_flag,
          X_Retirement_Pending_Flag      => l_asset_fin_rec_new.retirement_pending_flag,
          X_Depreciate_Flag              => l_asset_fin_rec_new.depreciate_flag,
          X_Disabled_Flag                => l_asset_fin_rec_new.disabled_flag,--HH
          X_Last_Update_Date             => px_trans_rec.who_info.last_update_date,
          X_Last_Updated_By              => px_trans_rec.who_info.last_updated_by,
          X_Date_Ineffective             => NULL,
          X_Transaction_Header_Id_In     => px_trans_rec.transaction_header_id,
          X_Transaction_Header_Id_Out    => NULL,
          X_Itc_Amount_Id                => l_asset_fin_rec_new.itc_amount_id,
          X_Itc_Amount                   => l_asset_fin_rec_new.itc_amount,
          X_Retirement_Id                => l_asset_fin_rec_new.retirement_id,
          X_Tax_Request_Id               => l_asset_fin_rec_new.tax_request_id,
          X_Itc_Basis                    => l_asset_fin_rec_new.itc_basis,
          X_Basic_Rate                   => l_asset_fin_rec_new.basic_rate,
          X_Adjusted_Rate                => l_asset_fin_rec_new.adjusted_rate,
          X_Bonus_Rule                   => l_asset_fin_rec_new.bonus_rule,
          X_Ceiling_Name                 => l_asset_fin_rec_new.ceiling_name,
          X_Recoverable_Cost             => l_asset_fin_rec_new.recoverable_cost,
          X_Last_Update_Login            => px_trans_rec.who_info.last_update_login,
          X_Adjusted_Capacity            => l_asset_fin_rec_new.adjusted_capacity,
          X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec_new.fully_rsvd_revals_counter,
          X_Idled_Flag                   => l_asset_fin_rec_new.idled_flag,
          X_Period_Counter_Capitalized   => l_asset_fin_rec_new.period_counter_capitalized,
          X_PC_Fully_Reserved            => l_asset_fin_rec_new.period_counter_fully_reserved,
          X_Period_Counter_Fully_Retired => l_asset_fin_rec_new.period_counter_fully_retired,
          X_Production_Capacity          => l_asset_fin_rec_new.production_capacity,
          X_Reval_Amortization_Basis     => l_asset_fin_rec_new.reval_amortization_basis,
          X_Reval_Ceiling                => l_asset_fin_rec_new.reval_ceiling,
          X_Unit_Of_Measure              => l_asset_fin_rec_new.unit_of_measure,
          X_Unrevalued_Cost              => l_asset_fin_rec_new.unrevalued_cost,
          X_Annual_Deprn_Rounding_Flag   => l_asset_fin_rec_new.annual_deprn_rounding_flag,
          X_Percent_Salvage_Value        => l_asset_fin_rec_new.percent_salvage_value,
          X_Allowed_Deprn_Limit          => l_asset_fin_rec_new.allowed_deprn_limit,
          X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec_new.allowed_deprn_limit_amount,
          X_Period_Counter_Life_Complete => l_asset_fin_rec_new.period_counter_life_complete,
          X_Adjusted_Recoverable_Cost    => l_asset_fin_rec_new.adjusted_recoverable_cost,
          X_Short_Fiscal_Year_Flag       => l_asset_fin_rec_new.short_fiscal_year_flag,
          X_Conversion_Date              => l_asset_fin_rec_new.conversion_date,
          X_Orig_Deprn_Start_Date        => l_asset_fin_rec_new.orig_deprn_start_date,
          X_Remaining_Life1              => l_asset_fin_rec_new.remaining_life1,
          X_Remaining_Life2              => l_asset_fin_rec_new.remaining_life2,
          X_Old_Adj_Cost                 => l_asset_fin_rec_new.old_adjusted_cost,
          X_Formula_Factor               => l_asset_fin_rec_new.formula_factor,
          X_gf_Attribute1                => l_asset_fin_rec_new.global_attribute1,
          X_gf_Attribute2                => l_asset_fin_rec_new.global_attribute2,
          X_gf_Attribute3                => l_asset_fin_rec_new.global_attribute3,
          X_gf_Attribute4                => l_asset_fin_rec_new.global_attribute4,
          X_gf_Attribute5                => l_asset_fin_rec_new.global_attribute5,
          X_gf_Attribute6                => l_asset_fin_rec_new.global_attribute6,
          X_gf_Attribute7                => l_asset_fin_rec_new.global_attribute7,
          X_gf_Attribute8                => l_asset_fin_rec_new.global_attribute8,
          X_gf_Attribute9                => l_asset_fin_rec_new.global_attribute9,
          X_gf_Attribute10               => l_asset_fin_rec_new.global_attribute10,
          X_gf_Attribute11               => l_asset_fin_rec_new.global_attribute11,
          X_gf_Attribute12               => l_asset_fin_rec_new.global_attribute12,
          X_gf_Attribute13               => l_asset_fin_rec_new.global_attribute13,
          X_gf_Attribute14               => l_asset_fin_rec_new.global_attribute14,
          X_gf_Attribute15               => l_asset_fin_rec_new.global_attribute15,
          X_gf_Attribute16               => l_asset_fin_rec_new.global_attribute16,
          X_gf_Attribute17               => l_asset_fin_rec_new.global_attribute17,
          X_gf_Attribute18               => l_asset_fin_rec_new.global_attribute18,
          X_gf_Attribute19               => l_asset_fin_rec_new.global_attribute19,
          X_gf_Attribute20               => l_asset_fin_rec_new.global_attribute20,
          X_global_attribute_category    => l_asset_fin_rec_new.global_attribute_category,
          X_group_asset_id               => l_asset_fin_rec_new.group_asset_id,
          X_salvage_type                 => l_asset_fin_rec_new.salvage_type,
          X_deprn_limit_type             => l_asset_fin_rec_new.deprn_limit_type,
          X_over_depreciate_option       => l_asset_fin_rec_new.over_depreciate_option,
          X_super_group_id               => l_asset_fin_rec_new.super_group_id,
          X_reduction_rate               => L_asset_fin_rec_new.reduction_rate,
          X_reduce_addition_flag         => l_asset_fin_rec_new.reduce_addition_flag,
          X_reduce_adjustment_flag       => l_asset_fin_rec_new.reduce_adjustment_flag,
          X_reduce_retirement_flag       => l_asset_fin_rec_new.reduce_retirement_flag,
          X_recognize_gain_loss          => l_asset_fin_rec_new.recognize_gain_loss,
          X_recapture_reserve_flag       => l_asset_fin_rec_new.recapture_reserve_flag,
          X_limit_proceeds_flag          => l_asset_fin_rec_new.limit_proceeds_flag,
          X_terminal_gain_loss           => l_asset_fin_rec_new.terminal_gain_loss,
          X_tracking_method              => l_asset_fin_rec_new.tracking_method,
          X_allocate_to_fully_rsv_flag   => l_asset_fin_rec_new.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   => l_asset_fin_rec_new.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => l_asset_fin_rec_new.exclude_fully_rsv_flag,
          X_excess_allocation_option     => l_asset_fin_rec_new.excess_allocation_option,
          X_depreciation_option          => l_asset_fin_rec_new.depreciation_option,
          X_member_rollup_flag           => l_asset_fin_rec_new.member_rollup_flag,
          X_ytd_proceeds                 => l_asset_fin_rec_new.ytd_proceeds,
          X_ltd_proceeds                 => l_asset_fin_rec_new.ltd_proceeds,
          X_eofy_reserve                 => l_asset_fin_rec_new.eofy_reserve,
          X_cip_cost                     => l_asset_fin_rec_new.cip_cost,
          X_terminal_gain_loss_amount    => l_asset_fin_rec_new.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => l_asset_fin_rec_new.ltd_cost_of_removal,
          X_cash_generating_unit_id      =>
                                   l_asset_fin_rec_new.cash_generating_unit_id,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
          X_Return_Status                => l_status,
          X_Calling_Fn                   => l_calling_fn
         , p_log_level_rec => p_log_level_rec);

      -- Japan Tax CIP Enhancement 6688475 (Start)
      if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES'
         and (px_trans_rec.transaction_type_code <> 'CIP REVERSE') then

         FA_CDE_PKG.faxgfr (X_Book_Type_Code         => p_asset_hdr_rec.book_type_code,
                           X_Asset_Id               => p_asset_hdr_rec.asset_id,
                           X_Short_Fiscal_Year_Flag => l_asset_fin_rec_new.short_fiscal_year_flag,
                           X_Conversion_Date        => l_asset_fin_rec_new.conversion_date,
                           X_Prorate_Date           => l_asset_fin_rec_new.prorate_date,
                           X_Orig_Deprn_Start_Date  => l_asset_fin_rec_new.orig_deprn_start_date,
                           C_Prorate_Date           => NULL,
                           C_Conversion_Date        => NULL,
                           C_Orig_Deprn_Start_Date  => NULL,
                           X_Method_Code            => l_asset_fin_rec_new.deprn_method_code,
                           X_Life_In_Months         => l_asset_fin_rec_new.life_in_months,
                           X_Fiscal_Year            => -99,
                           X_Current_Period	    => l_asset_fin_rec_new.period_counter_capitalized,
                           X_calling_interface      => 'ADDITION',
                           X_Rate                   => l_rate_in_use,
                           X_Method_Type            => l_method_type,
                           X_Success                => l_success, p_log_level_rec => p_log_level_rec);

         if (l_success <= 0) then
            fa_srvr_msg.add_message(calling_fn => 'fa_cip_pvt.do_cap_rev',  p_log_level_rec => p_log_level_rec);
            raise cap_rev_err;
         end if;

         UPDATE FA_BOOKS
         SET rate_in_use = l_rate_in_use
         WHERE book_type_code = p_asset_hdr_rec.book_type_code
         AND asset_id = p_asset_hdr_rec.asset_id
         AND date_ineffective is null;

      end if;
      -- Japan Tax CIP Enhancement 6688475 (End)

      --Code added for 6748832

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'calling deprn summary update_row',''
				,p_log_level_rec => p_log_level_rec);
      end if;


      if (p_asset_hdr_rec.period_of_addition = 'Y') then

	                FA_DEPRN_SUMMARY_PKG.Update_Row
	                                     (X_Book_Type_Code => p_asset_hdr_rec.book_type_code,
	                                      X_Asset_Id      => p_asset_hdr_rec.asset_id,
	                                      X_Deprn_Run_Date => px_trans_rec.who_info.last_update_date,
	                                      X_Adjusted_Cost  => l_asset_fin_rec_new.adjusted_cost,
	                                      X_Period_Counter => p_period_rec.period_counter-1,
	                                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                                              X_set_of_books_id   => p_asset_hdr_rec.set_of_books_id,
	                                      X_Calling_Fn  => l_calling_fn
	                                     ,p_log_level_rec => p_log_level_rec);
      end if;


      if (p_mrc_sob_type_code <> 'R') then

         if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'calling ad update_row','', p_log_level_rec => p_log_level_rec);
            end if;

            fa_additions_pkg.update_row
               (X_asset_id          => p_asset_hdr_rec.asset_id,
                X_asset_type        => px_asset_type_rec.asset_type,
                X_last_update_date  => px_trans_rec.who_info.last_update_date,
                X_last_updated_by   => px_trans_rec.who_info.last_updated_by,
                X_last_update_login => px_trans_rec.who_info.last_update_login,
                X_Return_Status     => l_status,
                X_Calling_Fn        => l_calling_fn, p_log_level_rec => p_log_level_rec);

         end if; -- corp
      end if;    -- primary

      if (px_trans_rec.transaction_type_code = 'CIP REVERSE') then

         if (p_mrc_sob_type_code <> 'R') then
             if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'calling th update trx type','', p_log_level_rec => p_log_level_rec);
             end if;

             FA_TRANSACTION_HEADERS_PKG.Update_Trx_Type
                       (X_Book_Type_Code                => p_asset_hdr_rec.book_type_code,
                        X_Asset_Id                      => p_asset_hdr_rec.asset_id,
                        X_Transaction_Type_Code         => 'ADDITION',
                        X_New_Transaction_Type          => 'ADDITION/VOID',
                        X_Return_Status                 => l_status,
                        X_Calling_Fn                    => l_calling_fn
                       , p_log_level_rec => p_log_level_rec);
         end if;

         if (G_release <> 11 and
             g_event_status = FA_XLA_EVENTS_PVT.C_EVENT_PROCESSED) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'reversing accounting impacts for cap',
                                'from fa_adjustments'
				,p_log_level_rec => p_log_level_rec);
            end if;

            if (p_mrc_sob_type_code = 'R') then
              open c_mrc_adjustments(p_thid => g_cap_thid);
            else
              open c_adjustments(p_thid => g_cap_thid);
            end if;

            loop
               if (p_mrc_sob_type_code = 'R') then
                  fetch c_mrc_adjustments
                   into l_adj_row_rec.code_combination_id    ,
                        l_adj_row_rec.distribution_id        ,
                        l_adj_row_rec.debit_credit_flag      ,
                        l_adj_row_rec.adjustment_amount      ,
                        l_adj_row_rec.adjustment_type;
               else
                  fetch c_adjustments
                   into l_adj_row_rec.code_combination_id    ,
                        l_adj_row_rec.distribution_id        ,
                        l_adj_row_rec.debit_credit_flag      ,
                        l_adj_row_rec.adjustment_amount      ,
                        l_adj_row_rec.adjustment_type;
               end if;

               if (p_mrc_sob_type_code = 'R') then
                  EXIT WHEN c_mrc_adjustments%NOTFOUND;
               else
                  EXIT WHEN c_adjustments%NOTFOUND;
               end if;


               l_adj.transaction_header_id    := px_trans_rec.transaction_header_id;
               l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
               l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
               l_adj.period_counter_created   := p_period_rec.period_counter;
               l_adj.period_counter_adjusted  := p_period_rec.period_counter;
               l_adj.current_units            := p_asset_desc_rec.current_units
;
               l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_SINGLE;
               l_adj.selection_thid           := 0;
               l_adj.selection_retid          := 0;
               l_adj.leveling_flag            := FALSE;
               l_adj.last_update_date         := px_trans_rec.who_info.last_update_date;

               l_adj.gen_ccid_flag            := FALSE;
               l_adj.annualized_adjustment    := 0;
               l_adj.asset_invoice_id         := 0;
               l_adj.code_combination_id      := l_adj_row_rec.code_combination_id;
               l_adj.distribution_id          := l_adj_row_rec.distribution_id;

               l_adj.adjustment_amount        := l_adj_row_rec.adjustment_amount;
               l_adj.flush_adj_flag           := FALSE;
               l_adj.adjustment_type          := l_adj_row_rec.adjustment_type;

               if (l_adj_row_rec.debit_credit_flag = 'DR') then
                  l_adj.debit_credit_flag     := 'CR';
               else
                  l_adj.debit_credit_flag     := 'DR';
               end if;

               l_adj.account                  := NULL;

               if (l_adj_row_rec.adjustment_type = 'COST') then
                  l_adj.account_type             := 'ASSET_COST_ACCT';
                  l_adj.source_type_code         := 'ADDITION';
               elsif (l_adj_row_rec.adjustment_type = 'CIP COST') then
                  l_adj.account_type             := 'CIP_COST_ACCT';
                  l_adj.source_type_code         := 'ADDITION';
               elsif (l_adj_row_rec.adjustment_type = 'EXPENSE') then
                  l_adj.account_type             := 'DEPRN_EXPENSE_ACCT';
                  l_adj.source_type_code         := 'DEPRECIATION';
               -- Bug:6404609
               elsif (l_adj_row_rec.adjustment_type = 'COST CLEARING') then
                  l_adj.adjustment_type          := 'CIP COST';
                  l_adj.account_type             := 'CIP_COST_ACCT';
                  l_adj.source_type_code         := 'CIP ADDITION';
			   else
                  l_adj.account_type             := 'BONUS_DEPRN_EXPENSE_ACCT';
                  l_adj.source_type_code         := 'DEPRECIATION';
               end if;

               l_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
               l_adj.set_of_books_id          := p_asset_hdr_rec.set_of_books_id;

               if not FA_INS_ADJUST_PKG.faxinaj
                        (l_adj,
                         px_trans_rec.who_info.last_update_date,
                         px_trans_rec.who_info.last_updated_by,
                         px_trans_rec.who_info.last_update_login
                         ,p_log_level_rec => p_log_level_rec) then
                  raise cap_rev_err;
               end if;

            end loop;

            -- now flush the rows to db
            l_adj.transaction_header_id := 0;
            l_adj.flush_adj_flag        := TRUE;
            l_adj.leveling_flag         := TRUE;

            if not FA_INS_ADJUST_PKG.faxinaj
                     (l_adj,
                      px_trans_rec.who_info.last_update_date,
                      px_trans_rec.who_info.last_updated_by,
                      px_trans_rec.who_info.last_update_login
                      ,p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

            if (p_mrc_sob_type_code = 'R') then
              close c_mrc_adjustments;
            else
              close c_adjustments;
            end if;

         else

            if (p_mrc_sob_type_code <> 'R') then

               delete from fa_adjustments
                where transaction_header_id = g_cap_thid;

            else

               delete from fa_mc_adjustments
                where transaction_header_id = g_cap_thid
                  and set_of_books_id = p_asset_hdr_rec.set_of_books_id;
            end if;

         end if;

      else  -- capitalizing

         -- now insert adjustments via faxinaj (when outside period of add)
         -- period of add flag has been set in absolute mode

         -- converted to use faxinaj instead of faxinadj for mrc

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'calling faxinaj','', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,
                             'calling faxinaj - adj_amount', l_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
         end if;

         l_adj.transaction_header_id    := px_trans_rec.transaction_header_id;
         l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
         l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
         l_adj.period_counter_created   := p_period_rec.period_counter;
         l_adj.period_counter_adjusted  := p_period_rec.period_counter;
         l_adj.current_units            := p_asset_desc_rec.current_units ;
         l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.selection_thid           := 0;
         l_adj.selection_retid          := 0;
         l_adj.leveling_flag            := FALSE;
         l_adj.last_update_date         := px_trans_rec.who_info.last_update_date;

         l_adj.gen_ccid_flag            := TRUE;
         l_adj.annualized_adjustment    := 0;
         l_adj.asset_invoice_id         := 0;
         l_adj.code_combination_id      := 0;
         l_adj.distribution_id          := 0;

         l_adj.adjustment_amount        := l_asset_fin_rec_new.cost;
         l_adj.source_type_code         := 'ADDITION';


         -- cost first
         l_adj.flush_adj_flag           := TRUE;   -- ??
         l_adj.adjustment_type          := 'COST';
         l_adj.debit_credit_flag        := 'DR';
         l_adj.account                  := fa_cache_pkg.fazccb_record.asset_cost_acct;
         l_adj.account_type             := 'ASSET_COST_ACCT';
         l_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
         l_adj.set_of_books_id          := p_asset_hdr_rec.set_of_books_id;

         if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise cap_rev_err;
         end if;

         -- cip cost next
         l_adj.flush_adj_flag           := TRUE;
         l_adj.adjustment_type          := 'CIP COST';
         l_adj.debit_credit_flag        := 'CR';
         l_adj.account                  := fa_cache_pkg.fazccb_record.cip_cost_acct;
         l_adj.account_type             := 'CIP_COST_ACCT';

         if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise cap_rev_err;
         end if;

      end if; -- reverse/cap

   end if;    -- current/prior period

   -- return the full fin struct back to public api for mrc rate insertion
   px_asset_fin_rec := l_asset_fin_rec_new;


   return TRUE;  -- all good

exception
   when cap_rev_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;


end do_cap_rev;

-------------------------------------------------------------------------

function do_validation
    (p_trans_rec      IN   FA_API_TYPES.trans_rec_type,
     p_asset_hdr_rec  IN   FA_API_TYPES.asset_hdr_rec_type,
     p_asset_fin_rec  IN   FA_API_TYPES.asset_fin_rec_type
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   l_count                 number;
   l_period_of_addition    varchar2(1);
   l_calling_fn            varchar2(30) := 'fa_cip_pvt.do_validation';
   val_err                 exception;

begin

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'cap trans type code ', p_trans_rec.transaction_type_code , p_log_level_rec => p_log_level_rec);
      end if;


   if (p_trans_rec.transaction_type_code = 'ADDITION') then

      -- validate dpis
      if not fa_asset_val_pvt.validate_dpis
              (p_transaction_type_code    => p_trans_rec.transaction_type_code,
               p_book_type_code           => p_asset_hdr_rec.book_type_code,
               p_date_placed_in_service   =>
                  p_asset_fin_rec.date_placed_in_service,
               p_prorate_convention_code  =>
                  p_asset_fin_rec.prorate_convention_code,
               p_calling_fn               => l_calling_fn, p_log_level_rec => p_log_level_rec) then
          raise val_err;
      end if;

   else

      -- check addition (don't allow after period of capitalization)
      if not fa_asset_val_pvt.validate_period_of_addition
              (p_asset_id            => p_asset_hdr_rec.asset_id,
               p_book                => p_asset_hdr_rec.book_type_code,
               p_mode                => 'CAPITALIZED',
               px_period_of_addition => l_period_of_addition, p_log_level_rec => p_log_level_rec) then
          raise val_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'cap period_of_addition', l_period_of_addition , p_log_level_rec => p_log_level_rec);
      end if;

      if (l_period_of_addition = 'N') then
         fa_srvr_msg.add_message
              (calling_fn => l_calling_fn,
               name       => 'FA_CWA_NOT_ADDED_THIS_PERIOD', p_log_level_rec => p_log_level_rec);
         raise val_err;
      end if;

      -- chk trx after add (don't allow if any trx after capitalization)
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'checking subsequent trxs', '' , p_log_level_rec => p_log_level_rec);
      end if;

      select count(*)
        into l_count
        from fa_transaction_headers th_add,
             fa_transaction_headers th_other
       where th_add.asset_id              = p_asset_hdr_rec.asset_id
         and th_add.book_type_code        = p_asset_hdr_rec.book_type_code
         and th_add.transaction_type_code = 'ADDITION'
         and th_other.asset_id            = p_asset_hdr_rec.asset_id
         and th_other.book_type_code      = p_asset_hdr_rec.book_type_code
         and th_other.date_effective      > th_add.date_effective;

      if (l_count <> 0) then
         fa_srvr_msg.add_message
              (calling_fn => l_calling_fn,
               name       => 'FA_CWA_TRX_AFTER_ADDITION', p_log_level_rec => p_log_level_rec);
         raise val_err;
      end if;


      -- BUG# 4609532
      -- removing the following validation due to the fact that
      -- we now allow cip revaluations
      -- check invoices cost for corp only

   end if;  -- capitalize / reverse


   -- check retirements (pending / full)

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'checking fully ret', '' , p_log_level_rec => p_log_level_rec);
   end if;

   if fa_asset_val_pvt.validate_fully_retired
      (p_asset_id            => p_asset_hdr_rec.asset_id,
       p_book                => p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec)  then
      fa_srvr_msg.add_message
         (name       => 'FA_REC_RETIRED',
          calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise val_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'checking ret pending', '' , p_log_level_rec => p_log_level_rec);
   end if;

   if fa_asset_val_pvt.validate_ret_rst_pending
      (p_asset_id            => p_asset_hdr_rec.asset_id,
       p_book                => p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec)  then
       raise val_err;
   end if;

   return true;

exception
   when val_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

end do_validation;

------------------------------------------------------------------------

END FA_CIP_PVT;

/
