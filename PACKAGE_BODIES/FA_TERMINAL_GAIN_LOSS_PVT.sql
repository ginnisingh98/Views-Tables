--------------------------------------------------------
--  DDL for Package Body FA_TERMINAL_GAIN_LOSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TERMINAL_GAIN_LOSS_PVT" as
/* $Header: FAVTGLB.pls 120.2.12010000.5 2009/10/23 10:48:10 gigupta ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

FUNCTION fadtgl (
   p_asset_id          IN NUMBER,
   p_book_type_code    IN VARCHAR2,
   p_deprn_reserve     IN NUMBER,
   p_mrc_sob_type_code IN VARCHAR2,
   p_set_of_books_id   IN NUMBER
) RETURN NUMBER IS

   l_calling_fn      varchar2(50) := 'FA_TERMINAL_GAIN_LOSS_PVT.fadtgl';
   l_db_title        varchar2(30) := 'fadtgl';
   l_trans_rec       FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
   l_asset_type_rec  FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec   FA_API_TYPES.asset_fin_rec_type;
   l_period_rec      FA_API_TYPES.period_rec_type;
   l_asset_cat_rec   FA_API_TYPES.asset_cat_rec_type;
   l_adj             FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

   l_date_effective  date;
   l_updated_by      number;
   l_update_login   number;

   l_th_rowid       ROWID;
   l_bks_rowid      ROWID;
   l_status         boolean;

   CURSOR c_get_deprn_run_date IS
      select last_update_date
           , last_updated_by
           , last_update_login
      from   fa_book_controls
      where  book_type_code = p_book_type_code;

   CURSOR c_get_mc_deprn_run_date IS
      select last_update_date
           , last_updated_by
           , last_update_login
      from   fa_mc_book_controls
      where  book_type_code = p_book_type_code
      and    set_of_books_id = p_set_of_books_id;

    -- +++++ Get Current Unit and category_id of Group Asset +++++
   CURSOR c_get_unit IS
     select units,
            category_id
     from   fa_asset_history
     where  asset_id = l_asset_hdr_rec.asset_id
     and    transaction_header_id_out is null;

   /*Bug# - 9018861 - To Check whether transaction has been created or not.*/
   CURSOR c_get_trx_id IS
     select transaction_header_id
     from   fa_transaction_headers th, fa_deprn_periods dp
     where  th.asset_id = l_asset_hdr_rec.asset_id
     and    th.book_type_code = l_asset_hdr_rec.book_type_code
     and    th.transaction_key = 'TG'
     and    th.calling_interface = 'FADEPR'
     and    dp.book_type_code = th.book_type_code
     and    dp.period_counter = l_period_rec.period_counter
     and    th.transaction_date_entered between dp.calendar_period_open_date and dp.calendar_period_close_date;

   tgl_err  EXCEPTION;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise tgl_err;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'BEGIN', p_asset_id ,p_log_level_rec => g_log_level_rec);
   end if;

   l_asset_hdr_rec.asset_id := p_asset_id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;

   l_asset_type_rec.asset_type := 'GROUP';

   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => l_asset_hdr_rec.book_type_code
                                ,p_log_level_rec => g_log_level_rec) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling fazcbc',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise tgl_err;
   end if;

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec(
           p_book           => l_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
           ,p_log_level_rec => g_log_level_rec) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling get_period_rec',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise tgl_err;
   end if;

   -- load the old fin structs
   if not FA_UTIL_PVT.get_asset_fin_rec(
           p_asset_hdr_rec         => l_asset_hdr_rec,
           px_asset_fin_rec        => l_asset_fin_rec,
           p_transaction_header_id => NULL,
           p_mrc_sob_type_code     => p_mrc_sob_type_code
           ,p_log_level_rec => g_log_level_rec) then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling get_asset_fin_rec',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise tgl_err;
   end if;

   -- Get last_update_date from fa_book_controls
   -- date effective for this terminal gain loss trx
   -- will be last_update_date - 1 sec.
   if (p_mrc_sob_type_code = 'R') then
      OPEN c_get_mc_deprn_run_date;
      FETCH c_get_mc_deprn_run_date INTO l_date_effective
                                       , l_updated_by
                                       , l_update_login;
      CLOSE c_get_mc_deprn_run_date;
   else
      OPEN c_get_deprn_run_date;
      FETCH c_get_deprn_run_date INTO l_date_effective
                                    , l_updated_by
                                    , l_update_login;
      CLOSE c_get_deprn_run_date;
   end if;

   l_date_effective := l_date_effective - (1/24/60/60);

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'INSERT', 'FA_TRANSACTION_HEADERS',
                       p_log_level_rec => g_log_level_rec);
   end if;

   /*Bug# - 9018861 - Since Deprn code calls this function for reporting book first,
                      Need to create transaction irresective of primary/reporting currency
                      if not created already,Proceed if l_trans_rec.transaction_header_id is null*/
   open c_get_trx_id;
   fetch c_get_trx_id into l_trans_rec.transaction_header_id;
   close c_get_trx_id;

   l_trans_rec.who_info.last_update_date := l_date_effective;
   l_trans_rec.who_info.creation_date := l_date_effective;
   --
   -- Proceed to process FA_TRANSACTION_HEADERS if this is primary book');
   --
   if l_trans_rec.transaction_header_id is null then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'INSERT', 'FA_TRANSACTION_HEADERS',
                          p_log_level_rec => g_log_level_rec);
      end if;

      SELECT fa_transaction_headers_s.nextval
      INTO   l_trans_rec.transaction_header_id
      FROM   DUAL;

      l_trans_rec.transaction_subtype := 'AMORTIZED';
      l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
      l_trans_rec.transaction_key := 'TG';
      l_trans_rec.transaction_date_entered := greatest(l_period_rec.calendar_period_open_date,
                                               least(sysdate,l_period_rec.calendar_period_close_date));
      l_trans_rec.amortization_start_date := l_trans_rec.transaction_date_entered;
      l_trans_rec.calling_interface := 'FADEPR';


      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'Calling', 'FA_XLA_EVENTS_PVT.create_transaction_event',
                          p_log_level_rec => g_log_level_rec);
      end if;
      l_asset_hdr_rec.set_of_books_id  := fa_cache_pkg.fazcbc_record.set_of_books_id;
      if not FA_XLA_EVENTS_PVT.create_transaction_event(
                  p_asset_hdr_rec          => l_asset_hdr_rec,
                  p_asset_type_rec         => l_asset_type_rec,
                  px_trans_rec             => l_trans_rec,
                  p_event_status           => NULL,
                  p_calling_fn             => l_calling_fn
                  ,p_log_level_rec => g_log_level_rec) then

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling create_transaction_event',
                             p_log_level_rec => g_log_level_rec);
         end if;

         raise tgl_err;
      end if;


      FA_TRANSACTION_HEADERS_PKG.Insert_Row
                      (X_Rowid                          => l_th_rowid,
                       X_Transaction_Header_Id          => l_trans_rec.transaction_header_id,
                       X_Book_Type_Code                 => l_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => l_asset_hdr_rec.asset_id,
                       X_Transaction_Type_Code          => l_trans_rec.transaction_type_code,
                       X_Transaction_Date_Entered       => l_trans_rec.transaction_date_entered,
                       X_Date_Effective                 => l_trans_rec.who_info.creation_date,
                       X_Last_Update_Date               => l_trans_rec.who_info.last_update_date,
                       X_Last_Updated_By                => l_trans_rec.who_info.last_updated_by,
                       X_Transaction_Name               => l_trans_rec.transaction_name,
                       X_Invoice_Transaction_Id         => null,
                       X_Source_Transaction_Header_Id   => l_trans_rec.Source_Transaction_Header_Id,
                       X_Mass_Reference_Id              => l_trans_rec.mass_reference_id,
                       X_Last_Update_Login              => l_trans_rec.who_info.last_update_login,
                       X_Transaction_Subtype            => l_trans_rec.transaction_subtype,
                       X_Attribute1                     => l_trans_rec.desc_flex.attribute1,
                       X_Attribute2                     => l_trans_rec.desc_flex.attribute2,
                       X_Attribute3                     => l_trans_rec.desc_flex.attribute3,
                       X_Attribute4                     => l_trans_rec.desc_flex.attribute4,
                       X_Attribute5                     => l_trans_rec.desc_flex.attribute5,
                       X_Attribute6                     => l_trans_rec.desc_flex.attribute6,
                       X_Attribute7                     => l_trans_rec.desc_flex.attribute7,
                       X_Attribute8                     => l_trans_rec.desc_flex.attribute8,
                       X_Attribute9                     => l_trans_rec.desc_flex.attribute9,
                       X_Attribute10                    => l_trans_rec.desc_flex.attribute10,
                       X_Attribute11                    => l_trans_rec.desc_flex.attribute11,
                       X_Attribute12                    => l_trans_rec.desc_flex.attribute12,
                       X_Attribute13                    => l_trans_rec.desc_flex.attribute13,
                       X_Attribute14                    => l_trans_rec.desc_flex.attribute14,
                       X_Attribute15                    => l_trans_rec.desc_flex.attribute15,
                       X_Attribute_Category_Code        => l_trans_rec.desc_flex.attribute_category_code,
                       X_Transaction_Key                => l_trans_rec.transaction_key,
                       X_Amortization_Start_Date        => l_trans_rec.amortization_start_date,
                       X_Calling_Interface              => l_trans_rec.calling_interface,
                       X_Mass_Transaction_ID            => l_trans_rec.mass_transaction_id,
                       X_Member_Transaction_Header_Id   => l_trans_rec.member_transaction_header_id,
                       X_Trx_Reference_Id               => l_trans_rec.trx_reference_id,
                       X_Event_Id                       => l_trans_rec.event_id,
                       X_Return_Status                  => l_status,
                       X_Calling_Fn                     => l_calling_fn
                       ,p_log_level_rec => g_log_level_rec);
      if not l_status then
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_db_title, 'Failed to insert ', 'FA_TRANSACTION_HEADERS',
                             p_log_level_rec => g_log_level_rec);
         end if;
         raise tgl_err;
      end if;

   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'INSERT', 'FA_ADJUSTMENTS',
                       p_log_level_rec => g_log_level_rec);
   end if;

   -- Create following entries in FA_ADJUSTMENTS
   -- DR  RESERVE
   --   CR NBV GAIN or NBV LOSS

   l_adj.asset_id                := l_asset_hdr_rec.asset_id;
   l_adj.book_type_code          := l_asset_hdr_rec.book_type_code;
   l_adj.period_counter_created  := l_period_rec.period_counter;
   l_adj.period_counter_adjusted := l_period_rec.period_counter;
   l_adj.transaction_header_id   := l_trans_rec.transaction_header_id;
   l_adj.source_type_code        := 'ADJUSTMENT';

   l_adj.selection_retid         := 0;
   l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.leveling_flag           := TRUE;
   l_adj.flush_adj_flag          := FALSE;
   l_adj.last_update_date        := sysdate;
   l_adj.gen_ccid_flag           := TRUE;
   l_adj.adjustment_type         := 'RESERVE';
   l_adj.account_type            := 'DEPRN_RESERVE_ACCT';

   l_adj.adjustment_amount       := abs(p_deprn_reserve);

   if (p_deprn_reserve > 0) then
      l_adj.debit_credit_flag    := 'DR';
   else
      l_adj.debit_credit_flag    := 'CR';
   end if;

   l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
   l_adj.set_of_books_id := p_set_of_books_id;


   OPEN c_get_unit;
   FETCH c_get_unit INTO l_adj.current_units , l_asset_cat_rec.category_id;
   CLOSE c_get_unit;

   if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                              l_asset_cat_rec.category_id
                              ,p_log_level_rec => g_log_level_rec) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling fazccb',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise tgl_err;
   end if;

   l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'CALL', 'FA_INS_ADJUST_PKG.faxinaj for RESERVE',
                       p_log_level_rec => g_log_level_rec);
   end if;

   if not FA_INS_ADJUST_PKG.faxinaj(
               l_adj,
               l_trans_rec.who_info.last_update_date,
               l_trans_rec.who_info.last_updated_by,
               l_trans_rec.who_info.last_update_login
               ,p_log_level_rec => g_log_level_rec) then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling faxinaj',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise tgl_err;
   end if;

   l_adj.adjustment_type      := 'NBV RETIRED';
   l_adj.adjustment_amount    := abs(p_deprn_reserve);
   l_adj.flush_adj_flag       := TRUE;

   if (p_deprn_reserve > 0) then
      l_adj.debit_credit_flag := 'CR';
      l_adj.account_type      := 'NBV_RETIRED_GAIN_ACCT';
      l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;
   else
      l_adj.debit_credit_flag := 'DR';
      l_adj.account_type      := 'NBV_RETIRED_LOSS_ACCT';
      l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_loss_acct;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'CALL', 'FA_INS_ADJUST_PKG.faxinaj for NBV GAIN/LOSS',
                       p_log_level_rec => g_log_level_rec);
   end if;

   if not FA_INS_ADJUST_PKG.faxinaj(
               l_adj,
               l_trans_rec.who_info.last_update_date,
               l_trans_rec.who_info.last_updated_by,
               l_trans_rec.who_info.last_update_login
               ,p_log_level_rec => g_log_level_rec) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'ERROR', 'Calling faxinaj',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise tgl_err;
   end if;


   -- Deactivate(Update) FA_BOOKS
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'DEACTIVATE', 'FA_BOOKS',
                       p_log_level_rec => g_log_level_rec);
   end if;

   fa_books_pkg.deactivate_row
        (X_asset_id                  => l_asset_hdr_rec.asset_id,
         X_book_type_code            => l_asset_hdr_rec.book_type_code,
         X_transaction_header_id_out => l_trans_rec.transaction_header_id,
         X_date_ineffective          => l_trans_rec.who_info.last_update_date,
         X_mrc_sob_type_code         => p_mrc_sob_type_code,
         X_set_of_books_id           => p_set_of_books_id,
         X_Calling_Fn                => l_calling_fn
         ,p_log_level_rec => g_log_level_rec);

   -- Insert into FA_BOOKS
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'INSERT', 'FA_BOOKS',
                       p_log_level_rec => g_log_level_rec);
   end if;

   fa_books_pkg.insert_row
         (X_Rowid                        => l_bks_rowid,
          X_Book_Type_Code               => l_asset_hdr_rec.book_type_code,
          X_Asset_Id                     => l_asset_hdr_rec.asset_id,
          X_Date_Placed_In_Service       => l_asset_fin_rec.date_placed_in_service,
          X_Date_Effective               => l_trans_rec.who_info.last_update_date,
          X_Deprn_Start_Date             => l_asset_fin_rec.deprn_start_date,
          X_Deprn_Method_Code            => l_asset_fin_rec.deprn_method_code,
          X_Life_In_Months               => l_asset_fin_rec.life_in_months,
          X_Rate_Adjustment_Factor       => l_asset_fin_rec.rate_adjustment_factor,
          X_Adjusted_Cost                => l_asset_fin_rec.adjusted_cost,
          X_Cost                         => l_asset_fin_rec.cost,
          X_Original_Cost                => l_asset_fin_rec.original_cost,
          X_Salvage_Value                => l_asset_fin_rec.salvage_value,
          X_Prorate_Convention_Code      => l_asset_fin_rec.prorate_convention_code,
          X_Prorate_Date                 => l_asset_fin_rec.prorate_date,
          X_Cost_Change_Flag             => l_asset_fin_rec.cost_change_flag,
          X_Adjustment_Required_Status   => l_asset_fin_rec.adjustment_required_status,
          X_Capitalize_Flag              => l_asset_fin_rec.capitalize_flag,
          X_Retirement_Pending_Flag      => l_asset_fin_rec.retirement_pending_flag,
          X_Depreciate_Flag              => l_asset_fin_rec.depreciate_flag,
          X_Disabled_Flag                => l_asset_fin_rec.disabled_flag, --HH
          X_Last_Update_Date             => l_trans_rec.who_info.last_update_date,
          X_Last_Updated_By              => l_trans_rec.who_info.last_updated_by,
          X_Date_Ineffective             => NULL,
          X_Transaction_Header_Id_In     => l_trans_rec.transaction_header_id,
          X_Transaction_Header_Id_Out    => NULL,
          X_Itc_Amount_Id                => l_asset_fin_rec.itc_amount_id,
          X_Itc_Amount                   => l_asset_fin_rec.itc_amount,
          X_Retirement_Id                => l_asset_fin_rec.retirement_id,
          X_Tax_Request_Id               => l_asset_fin_rec.tax_request_id,
          X_Itc_Basis                    => l_asset_fin_rec.itc_basis,
          X_Basic_Rate                   => l_asset_fin_rec.basic_rate,
          X_Adjusted_Rate                => l_asset_fin_rec.adjusted_rate,
          X_Bonus_Rule                   => l_asset_fin_rec.bonus_rule,
          X_Ceiling_Name                 => l_asset_fin_rec.ceiling_name,
          X_Recoverable_Cost             => l_asset_fin_rec.recoverable_cost,
          X_Last_Update_Login            => l_trans_rec.who_info.last_update_login,
          X_Adjusted_Capacity            => l_asset_fin_rec.adjusted_capacity,
          X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec.fully_rsvd_revals_counter,
          X_Idled_Flag                   => l_asset_fin_rec.idled_flag,
          X_Period_Counter_Capitalized   => l_asset_fin_rec.period_counter_capitalized,
          X_PC_Fully_Reserved            => l_asset_fin_rec.period_counter_fully_reserved,
          X_Period_Counter_Fully_Retired => l_asset_fin_rec.period_counter_fully_retired,
          X_Production_Capacity          => l_asset_fin_rec.production_capacity,
          X_Reval_Amortization_Basis     => l_asset_fin_rec.reval_amortization_basis,
          X_Reval_Ceiling                => l_asset_fin_rec.reval_ceiling,
          X_Unit_Of_Measure              => l_asset_fin_rec.unit_of_measure,
          X_Unrevalued_Cost              => l_asset_fin_rec.unrevalued_cost,
          X_Annual_Deprn_Rounding_Flag   => l_asset_fin_rec.annual_deprn_rounding_flag,
          X_Percent_Salvage_Value        => l_asset_fin_rec.percent_salvage_value,
          X_Allowed_Deprn_Limit          => l_asset_fin_rec.allowed_deprn_limit,
          X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec.allowed_deprn_limit_amount,
          X_Period_Counter_Life_Complete => l_asset_fin_rec.period_counter_life_complete,
          X_Adjusted_Recoverable_Cost    => l_asset_fin_rec.adjusted_recoverable_cost,
          X_Short_Fiscal_Year_Flag       => l_asset_fin_rec.short_fiscal_year_flag,
          X_Conversion_Date              => l_asset_fin_rec.conversion_date,
          X_Orig_Deprn_Start_Date        => l_asset_fin_rec.orig_deprn_start_date,
          X_Remaining_Life1              => l_asset_fin_rec.remaining_life1,
          X_Remaining_Life2              => l_asset_fin_rec.remaining_life2,
          X_Old_Adj_Cost                 => l_asset_fin_rec.old_adjusted_cost,
          X_Formula_Factor               => l_asset_fin_rec.formula_factor,
          X_gf_Attribute1                => l_asset_fin_rec.global_attribute1,
          X_gf_Attribute2                => l_asset_fin_rec.global_attribute2,
          X_gf_Attribute3                => l_asset_fin_rec.global_attribute3,
          X_gf_Attribute4                => l_asset_fin_rec.global_attribute4,
          X_gf_Attribute5                => l_asset_fin_rec.global_attribute5,
          X_gf_Attribute6                => l_asset_fin_rec.global_attribute6,
          X_gf_Attribute7                => l_asset_fin_rec.global_attribute7,
          X_gf_Attribute8                => l_asset_fin_rec.global_attribute8,
          X_gf_Attribute9                => l_asset_fin_rec.global_attribute9,
          X_gf_Attribute10               => l_asset_fin_rec.global_attribute10,
          X_gf_Attribute11               => l_asset_fin_rec.global_attribute11,
          X_gf_Attribute12               => l_asset_fin_rec.global_attribute12,
          X_gf_Attribute13               => l_asset_fin_rec.global_attribute13,
          X_gf_Attribute14               => l_asset_fin_rec.global_attribute14,
          X_gf_Attribute15               => l_asset_fin_rec.global_attribute15,
          X_gf_Attribute16               => l_asset_fin_rec.global_attribute16,
          X_gf_Attribute17               => l_asset_fin_rec.global_attribute17,
          X_gf_Attribute18               => l_asset_fin_rec.global_attribute18,
          X_gf_Attribute19               => l_asset_fin_rec.global_attribute19,
          X_gf_Attribute20               => l_asset_fin_rec.global_attribute20,
          X_global_attribute_category    => l_asset_fin_rec.global_attribute_category,
          X_group_asset_id               => l_asset_fin_rec.group_asset_id,
          X_salvage_type                 => l_asset_fin_rec.salvage_type,
          X_deprn_limit_type             => l_asset_fin_rec.deprn_limit_type,
          X_over_depreciate_option       => l_asset_fin_rec.over_depreciate_option,
          X_super_group_id               => l_asset_fin_rec.super_group_id,
          X_reduction_rate               => l_asset_fin_rec.reduction_rate,
          X_reduce_addition_flag         => l_asset_fin_rec.reduce_addition_flag,
          X_reduce_adjustment_flag       => l_asset_fin_rec.reduce_adjustment_flag,
          X_reduce_retirement_flag       => l_asset_fin_rec.reduce_retirement_flag,
          X_recognize_gain_loss          => l_asset_fin_rec.recognize_gain_loss,
          X_recapture_reserve_flag       => l_asset_fin_rec.recapture_reserve_flag,
          X_limit_proceeds_flag          => l_asset_fin_rec.limit_proceeds_flag,
          X_terminal_gain_loss           => l_asset_fin_rec.terminal_gain_loss,
          X_exclude_proceeds_from_basis  => l_asset_fin_rec.exclude_proceeds_from_basis,
          X_retirement_deprn_option      => l_asset_fin_rec.retirement_deprn_option,
          X_tracking_method              => l_asset_fin_rec.tracking_method,
          X_allocate_to_fully_rsv_flag   => l_asset_fin_rec.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   => l_asset_fin_rec.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => l_asset_fin_rec.exclude_fully_rsv_flag,
          X_excess_allocation_option     => l_asset_fin_rec.excess_allocation_option,
          X_depreciation_option          => l_asset_fin_rec.depreciation_option,
          X_member_rollup_flag           => l_asset_fin_rec.member_rollup_flag,
          X_ytd_proceeds                 => l_asset_fin_rec.ytd_proceeds,
          X_ltd_proceeds                 => l_asset_fin_rec.ltd_proceeds,
          X_eofy_reserve                 => l_asset_fin_rec.eofy_reserve,
          X_cip_cost                     => l_asset_fin_rec.cip_cost,
          X_terminal_gain_loss_amount    => p_deprn_reserve,
          X_terminal_gain_loss_flag      => null,
          X_ltd_cost_of_removal          => l_asset_fin_rec.ltd_cost_of_removal,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => p_set_of_books_id,
          X_Return_Status                => l_status,
          X_Calling_Fn                   => l_calling_fn
          ,p_log_level_rec => g_log_level_rec);


   if not l_status then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'Failed to insert ', 'FA_BOOKS',
                          p_log_level_rec => g_log_level_rec);
      end if;
      raise tgl_err;
   end if;

-- Update FA_BOOKS_SUMMARY
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'Update', 'FA_BOOKS_SUMMARY: '||p_mrc_sob_type_code,
                       p_log_level_rec => g_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      UPDATE FA_MC_BOOKS_SUMMARY
      SET    TERMINAL_GAIN_LOSS_AMOUNT = p_deprn_reserve
           , TERMINAL_GAIN_LOSS_FLAG   = 'C'
           , RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + p_deprn_reserve
           , DEPRN_RESERVE             = DEPRN_RESERVE + p_deprn_reserve
      WHERE  ASSET_ID                  = l_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE            = l_asset_hdr_rec.book_type_code
      AND    PERIOD_COUNTER            = l_period_rec.period_counter
      AND    SET_OF_BOOKS_ID           = p_set_of_books_id;
   else
      UPDATE FA_BOOKS_SUMMARY
      SET    TERMINAL_GAIN_LOSS_AMOUNT = p_deprn_reserve
           , TERMINAL_GAIN_LOSS_FLAG   = 'C'
           , RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + p_deprn_reserve
           , DEPRN_RESERVE             = DEPRN_RESERVE + p_deprn_reserve
      WHERE  ASSET_ID                  = l_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE            = l_asset_hdr_rec.book_type_code
      AND    PERIOD_COUNTER            = l_period_rec.period_counter;
   end if;


   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_db_title, 'END', p_asset_id,
                       p_log_level_rec => g_log_level_rec);
   end if;

   return 0;

EXCEPTION
   WHEN tgl_err THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'EXCEPTION', 'tgl_err',
                          p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_db_title, 'EXCEPTION(tgl_err)', sqlerrm);
      end if;
      return 1;

   WHEN OTHERS THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_db_title, 'EXCEPTION(OTHERS)', sqlerrm);
      end if;
      return 1;

END fadtgl;

END FA_TERMINAL_GAIN_LOSS_PVT;

/
