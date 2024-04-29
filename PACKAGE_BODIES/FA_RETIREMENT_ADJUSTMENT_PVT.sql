--------------------------------------------------------
--  DDL for Package Body FA_RETIREMENT_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETIREMENT_ADJUSTMENT_PVT" AS
/* $Header: FAVRADJB.pls 120.9.12010000.2 2009/07/19 11:28:34 glchen ship $ */

FUNCTION do_retirement_adjustment
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old        IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old      IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new         OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec               IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code        IN     VARCHAR2,
    p_cost_of_removal          IN     NUMBER,
    p_proceeds                 IN     NUMBER,
    p_cost_of_removal_ccid     IN     NUMBER DEFAULT NULL,
    p_proceeds_ccid            IN     NUMBER DEFAULT NULL
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for new group code
   l_adj                 fa_adjust_type_pkg.fa_adj_row_struct;
   l_bks_rowid           varchar2(30);
   l_status              BOOLEAN;

   -- used for depreciable basis rule
   l_asset_retire_rec    fa_api_types.asset_retire_rec_type;
   l_asset_deprn_rec     fa_api_types.asset_deprn_rec_type;

   --
   -- For calling faxama.
   --
   l_deprn_exp           NUMBER := 0;
   l_bonus_deprn_exp     NUMBER := 0;
   l_impairment_exp      NUMBER := 0;
   l_deprn_rsv           NUMBER := 0;
   l_asset_deprn_rec_adj FA_API_TYPES.ASSET_DEPRN_REC_TYPE;

   l_calling_fn          VARCHAR2(35) := 'fa_group_reserve_pvt.do_transfer';
   adj_err               EXCEPTION;

BEGIN

   -- call the category books cache for the accounts
   if not fa_cache_pkg.fazccb(X_book   => px_asset_hdr_rec.book_type_code,
                              X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;

   -- set the new structs to the old ones
   -- (values which changes such as adjusted_cost will be set below)
   x_asset_fin_rec_new   := p_asset_fin_rec_old;
   x_asset_deprn_rec_new := p_asset_deprn_rec_old;

   --  Use Depreciable Basis Rule
   l_asset_retire_rec.proceeds_of_sale := p_proceeds;
   l_asset_retire_rec.cost_of_removal  := p_cost_of_removal;
   l_asset_retire_rec.cost_retired     := p_asset_fin_rec_old.cost
                                           - x_asset_fin_rec_new.cost;
   l_asset_deprn_rec := x_asset_deprn_rec_new;
   l_asset_deprn_rec.deprn_reserve := nvl(x_asset_deprn_rec_new.deprn_reserve,0)
                                       + nvl(p_proceeds,0)-nvl(p_cost_of_removal,0);

   -- Call Depreciable Basis Rule
   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
             (p_event_type             => 'RETIREMENT',
              p_asset_fin_rec_new      => x_asset_fin_rec_new,
              p_asset_fin_rec_old      => p_asset_fin_rec_old,
              p_asset_hdr_rec          => px_asset_hdr_rec,
              p_asset_type_rec         => p_asset_type_rec,
              p_trans_rec              => px_trans_rec,
              p_period_rec             => p_period_rec,
              p_asset_retire_rec       => l_asset_retire_rec,
              p_asset_deprn_rec        => l_asset_deprn_rec,
              p_recoverable_cost       => x_asset_fin_rec_new.recoverable_cost,
              p_salvage_value          => x_asset_fin_rec_new.salvage_value,
              p_mrc_sob_type_code      => p_mrc_sob_type_code,
              px_new_adjusted_cost     => x_asset_fin_rec_new.adjusted_cost,
              px_new_raf               => x_asset_fin_rec_new.rate_adjustment_factor,
              px_new_formula_factor    => x_asset_fin_rec_new.formula_factor,
              p_log_level_rec          => p_log_level_rec)
      ) then
        fa_srvr_msg.add_message(calling_fn =>l_calling_fn, p_log_level_rec => p_log_level_rec);
        RETURN FALSE;
   end if;

   l_asset_deprn_rec_adj.deprn_reserve := nvl(p_proceeds, 0) - nvl(p_cost_of_removal, 0);

   if (not FA_AMORT_PVT.faxama(
              px_trans_rec            => px_trans_rec,
              p_asset_hdr_rec         => px_asset_hdr_rec,
              p_asset_desc_rec        => p_asset_desc_rec,
              p_asset_cat_rec         => p_asset_cat_rec,
              p_asset_type_rec        => p_asset_type_rec,
              p_asset_fin_rec_old     => p_asset_fin_rec_old,
              px_asset_fin_rec_new    => x_asset_fin_rec_new,
              p_asset_deprn_rec       => p_asset_deprn_rec_old,
              p_asset_deprn_rec_adj   => l_asset_deprn_rec_adj,
              p_period_rec            => p_period_rec,
              p_mrc_sob_type_code     => p_mrc_sob_type_code,
              p_running_mode          => fa_std_types.FA_DPR_NORMAL,
              p_used_by_revaluation   => null,
              p_reclassed_asset_id    => null,
              p_reclass_src_dest      => null,
              p_reclassed_asset_dpis  => null,
              p_update_books_summary  => TRUE,
              p_proceeds_of_sale      => p_proceeds,
              p_cost_of_removal       => p_cost_of_removal,
              x_deprn_exp             => l_deprn_exp,
              x_bonus_deprn_exp       => l_bonus_deprn_exp,
              x_impairment_exp        => l_impairment_exp,
              x_deprn_rsv             => l_deprn_rsv, p_log_level_rec => p_log_level_rec)) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('l_calling_fn', 'calling FA_AMORT_PVT.faxama', 'FAILED',  p_log_level_rec => p_log_level_rec);
      end if;
      raise adj_err;

   end if; -- (not FA_AMORT_PVT.faxama

   -- call faxinaj to insert the amounts (flush them too)
   l_adj.transaction_header_id    := px_trans_rec.transaction_header_id;
   l_adj.asset_id                 := px_asset_hdr_rec.asset_id;
   l_adj.book_type_code           := px_asset_hdr_rec.book_type_code;
   l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.current_units            := p_asset_desc_rec.current_units;
   l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.selection_thid           := 0;
   l_adj.selection_retid          := 0;
   l_adj.leveling_flag            := TRUE;
   l_adj.last_update_date         := px_trans_rec.who_info.last_update_date;

   l_adj.annualized_adjustment    := 0;
   l_adj.asset_invoice_id         := 0;
   l_adj.distribution_id          := 0;

   l_adj.flush_adj_flag           := TRUE;
   l_adj.deprn_override_flag:= '';

   l_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
   l_adj.set_of_books_id          := px_asset_hdr_rec.set_of_books_id;

   l_adj.source_type_code         := 'RETIREMENT';

   -- cost of removal amounts
   if nvl(p_cost_of_removal, 0) <> 0 then

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn || ' for cor ',
                     'thid',
                     l_adj.transaction_header_id, p_log_level_rec => p_log_level_rec);
      end if;


      l_adj.debit_credit_flag        := 'DR';
      l_adj.adjustment_type          := 'RESERVE';  -- GRP COR RESERVE ???
      l_adj.adjustment_amount        := p_cost_of_removal;
      l_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
      l_adj.account_type             := 'DEPRN_RESERVE_ACCT';
      l_adj.code_combination_id      := 0;
      l_adj.gen_ccid_flag            := TRUE;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise adj_err;
      end if;

      if (p_cost_of_removal_ccid is null) then
         l_adj.account               := fa_cache_pkg.fazcbc_record.cost_of_removal_clearing_acct;
         l_adj.code_combination_id   := 0;
         l_adj.gen_ccid_flag         := TRUE;
      else
         l_adj.code_combination_id   := p_cost_of_removal_ccid;
         l_adj.gen_ccid_flag         := FALSE;
      end if;

      l_adj.account_type             := 'COST_OF_REMOVAL_CLEARING_ACCT';
      l_adj.adjustment_type          := 'REMOVALCOST CLR';
      l_adj.debit_credit_flag        := 'CR';

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise adj_err;
      end if;

   end if;

   -- proceeds of sale
   if nvl(p_proceeds, 0) <> 0 then

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn || ' for proceeds ',
                     'thid',
                     l_adj.transaction_header_id, p_log_level_rec => p_log_level_rec);
      end if;


      l_adj.debit_credit_flag        := 'CR';
      l_adj.adjustment_type          := 'RESERVE';  -- GRP PRC RESERVE ???
      l_adj.adjustment_amount        := p_proceeds;
      l_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
      l_adj.account_type             := 'DEPRN_RESERVE_ACCT';
      l_adj.code_combination_id      := 0;
      l_adj.gen_ccid_flag            := TRUE;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise adj_err;
      end if;

      if (p_proceeds_ccid is null) then
         l_adj.account               := fa_cache_pkg.fazcbc_record.proceeds_of_sale_clearing_acct;
         l_adj.code_combination_id   := 0;
         l_adj.gen_ccid_flag         := TRUE;
      else
         l_adj.code_combination_id   := p_proceeds_ccid;
         l_adj.gen_ccid_flag         := FALSE;
      end if;

      l_adj.account_type             := 'PROCEEDS_OF_SALE_CLEARING_ACCT';
      l_adj.adjustment_type          := 'PROCEEDS CLR';
      l_adj.debit_credit_flag        := 'DR';

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise adj_err;
      end if;

   end if;

   /*****************************************************

   -- for life based methods, this where we would need to
   -- recalculate raf, etc

   *****************************************************/


   -- terminate/insert fa_books rows
   -- terminate the active row

   fa_books_pkg.deactivate_row
        (X_asset_id                  => px_asset_hdr_rec.asset_id,
         X_book_type_code            => px_asset_hdr_rec.book_type_code,
         X_transaction_header_id_out => px_trans_rec.transaction_header_id,
         X_date_ineffective          => px_trans_rec.who_info.last_update_date,
         X_mrc_sob_type_code         => p_mrc_sob_type_code,
         X_set_of_books_id           => px_asset_hdr_rec.set_of_books_id,
         X_Calling_Fn                => l_calling_fn
         , p_log_level_rec => p_log_level_rec);

   -- fa books
   fa_books_pkg.insert_row
         (X_Rowid                        => l_bks_rowid,
          X_Book_Type_Code               => px_asset_hdr_rec.book_type_code,
          X_Asset_Id                     => px_asset_hdr_rec.asset_id,
          X_Date_Placed_In_Service       => x_asset_fin_rec_new.date_placed_in_service,
          X_Date_Effective               => px_trans_rec.who_info.last_update_date,
          X_Deprn_Start_Date             => x_asset_fin_rec_new.deprn_start_date,
          X_Deprn_Method_Code            => x_asset_fin_rec_new.deprn_method_code,
          X_Life_In_Months               => x_asset_fin_rec_new.life_in_months,
          X_Rate_Adjustment_Factor       => x_asset_fin_rec_new.rate_adjustment_factor,
          X_Adjusted_Cost                => x_asset_fin_rec_new.adjusted_cost,
          X_Cost                         => x_asset_fin_rec_new.cost,
          X_Original_Cost                => x_asset_fin_rec_new.original_cost,
          X_Salvage_Value                => x_asset_fin_rec_new.salvage_value,
          X_Prorate_Convention_Code      => x_asset_fin_rec_new.prorate_convention_code,
          X_Prorate_Date                 => x_asset_fin_rec_new.prorate_date,
          X_Cost_Change_Flag             => x_asset_fin_rec_new.cost_change_flag,
          X_Adjustment_Required_Status   => x_asset_fin_rec_new.adjustment_required_status,
          X_Capitalize_Flag              => x_asset_fin_rec_new.capitalize_flag,
          X_Retirement_Pending_Flag      => x_asset_fin_rec_new.retirement_pending_flag,
          X_Depreciate_Flag              => x_asset_fin_rec_new.depreciate_flag,
          X_Disabled_Flag                => x_asset_fin_rec_new.disabled_flag,--HH
          X_Last_Update_Date             => px_trans_rec.who_info.last_update_date,
          X_Last_Updated_By              => px_trans_rec.who_info.last_updated_by,
          X_Date_Ineffective             => NULL,
          X_Transaction_Header_Id_In     => px_trans_rec.transaction_header_id,
          X_Transaction_Header_Id_Out    => NULL,
          X_Itc_Amount_Id                => x_asset_fin_rec_new.itc_amount_id,
          X_Itc_Amount                   => x_asset_fin_rec_new.itc_amount,
          X_Retirement_Id                => x_asset_fin_rec_new.retirement_id,
          X_Tax_Request_Id               => x_asset_fin_rec_new.tax_request_id,
          X_Itc_Basis                    => x_asset_fin_rec_new.itc_basis,
          X_Basic_Rate                   => x_asset_fin_rec_new.basic_rate,
          X_Adjusted_Rate                => x_asset_fin_rec_new.adjusted_rate,
          X_Bonus_Rule                   => x_asset_fin_rec_new.bonus_rule,
          X_Ceiling_Name                 => x_asset_fin_rec_new.ceiling_name,
          X_Recoverable_Cost             => x_asset_fin_rec_new.recoverable_cost,
          X_Last_Update_Login            => px_trans_rec.who_info.last_update_login,
          X_Adjusted_Capacity            => x_asset_fin_rec_new.adjusted_capacity,
          X_Fully_Rsvd_Revals_Counter    => x_asset_fin_rec_new.fully_rsvd_revals_counter,
          X_Idled_Flag                   => x_asset_fin_rec_new.idled_flag,
          X_Period_Counter_Capitalized   => x_asset_fin_rec_new.period_counter_capitalized,
          X_PC_Fully_Reserved            => x_asset_fin_rec_new.period_counter_fully_reserved,
          X_Period_Counter_Fully_Retired => x_asset_fin_rec_new.period_counter_fully_retired,
          X_Production_Capacity          => x_asset_fin_rec_new.production_capacity,
          X_Reval_Amortization_Basis     => x_asset_fin_rec_new.reval_amortization_basis,
          X_Reval_Ceiling                => x_asset_fin_rec_new.reval_ceiling,
          X_Unit_Of_Measure              => x_asset_fin_rec_new.unit_of_measure,
          X_Unrevalued_Cost              => x_asset_fin_rec_new.unrevalued_cost,
          X_Annual_Deprn_Rounding_Flag   => x_asset_fin_rec_new.annual_deprn_rounding_flag,
          X_Percent_Salvage_Value        => x_asset_fin_rec_new.percent_salvage_value,
          X_Allowed_Deprn_Limit          => x_asset_fin_rec_new.allowed_deprn_limit,
          X_Allowed_Deprn_Limit_Amount   => x_asset_fin_rec_new.allowed_deprn_limit_amount,
          X_Period_Counter_Life_Complete => x_asset_fin_rec_new.period_counter_life_complete,
          X_Adjusted_Recoverable_Cost    => x_asset_fin_rec_new.adjusted_recoverable_cost,
          X_Short_Fiscal_Year_Flag       => x_asset_fin_rec_new.short_fiscal_year_flag,
          X_Conversion_Date              => x_asset_fin_rec_new.conversion_date,
          X_Orig_Deprn_Start_Date        => x_asset_fin_rec_new.orig_deprn_start_date,
          X_Remaining_Life1              => x_asset_fin_rec_new.remaining_life1,
          X_Remaining_Life2              => x_asset_fin_rec_new.remaining_life2,
          X_Old_Adj_Cost                 => x_asset_fin_rec_new.old_adjusted_cost,
          X_Formula_Factor               => x_asset_fin_rec_new.formula_factor,
          X_gf_Attribute1                => x_asset_fin_rec_new.global_attribute1,
          X_gf_Attribute2                => x_asset_fin_rec_new.global_attribute2,
          X_gf_Attribute3                => x_asset_fin_rec_new.global_attribute3,
          X_gf_Attribute4                => x_asset_fin_rec_new.global_attribute4,
          X_gf_Attribute5                => x_asset_fin_rec_new.global_attribute5,
          X_gf_Attribute6                => x_asset_fin_rec_new.global_attribute6,
          X_gf_Attribute7                => x_asset_fin_rec_new.global_attribute7,
          X_gf_Attribute8                => x_asset_fin_rec_new.global_attribute8,
          X_gf_Attribute9                => x_asset_fin_rec_new.global_attribute9,
          X_gf_Attribute10               => x_asset_fin_rec_new.global_attribute10,
          X_gf_Attribute11               => x_asset_fin_rec_new.global_attribute11,
          X_gf_Attribute12               => x_asset_fin_rec_new.global_attribute12,
          X_gf_Attribute13               => x_asset_fin_rec_new.global_attribute13,
          X_gf_Attribute14               => x_asset_fin_rec_new.global_attribute14,
          X_gf_Attribute15               => x_asset_fin_rec_new.global_attribute15,
          X_gf_Attribute16               => x_asset_fin_rec_new.global_attribute16,
          X_gf_Attribute17               => x_asset_fin_rec_new.global_attribute17,
          X_gf_Attribute18               => x_asset_fin_rec_new.global_attribute18,
          X_gf_Attribute19               => x_asset_fin_rec_new.global_attribute19,
          X_gf_Attribute20               => x_asset_fin_rec_new.global_attribute20,
          X_global_attribute_category    => x_asset_fin_rec_new.global_attribute_category,
          X_group_asset_id               => x_asset_fin_rec_new.group_asset_id,
          X_salvage_type                 => x_asset_fin_rec_new.salvage_type,
          X_deprn_limit_type             => x_asset_fin_rec_new.deprn_limit_type,
          X_over_depreciate_option       => x_asset_fin_rec_new.over_depreciate_option,
          X_super_group_id               => x_asset_fin_rec_new.super_group_id,
          X_reduction_rate               => x_asset_fin_rec_new.reduction_rate,
          X_reduce_addition_flag         => x_asset_fin_rec_new.reduce_addition_flag,
          X_reduce_adjustment_flag       => x_asset_fin_rec_new.reduce_adjustment_flag,
          X_reduce_retirement_flag       => x_asset_fin_rec_new.reduce_retirement_flag,
          X_recognize_gain_loss          => x_asset_fin_rec_new.recognize_gain_loss,
          X_recapture_reserve_flag       => x_asset_fin_rec_new.recapture_reserve_flag,
          X_limit_proceeds_flag          => x_asset_fin_rec_new.limit_proceeds_flag,
          X_terminal_gain_loss           => x_asset_fin_rec_new.terminal_gain_loss,
          X_exclude_proceeds_from_basis  => x_asset_fin_rec_new.exclude_proceeds_from_basis,
          X_retirement_deprn_option      => x_asset_fin_rec_new.retirement_deprn_option,
          X_tracking_method              => x_asset_fin_rec_new.tracking_method,
          X_allocate_to_fully_rsv_flag   =>x_asset_fin_rec_new.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   =>x_asset_fin_rec_new.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => x_asset_fin_rec_new.exclude_fully_rsv_flag,
          X_excess_allocation_option     => x_asset_fin_rec_new.excess_allocation_option,
          X_depreciation_option          => x_asset_fin_rec_new.depreciation_option,
          X_member_rollup_flag           => x_asset_fin_rec_new.member_rollup_flag,
          X_ytd_proceeds                 => nvl(x_asset_fin_rec_new.ytd_proceeds, 0) + p_proceeds,
          X_ltd_proceeds                 => nvl(x_asset_fin_rec_new.ltd_proceeds, 0) + p_proceeds,
          X_eofy_reserve                 => x_asset_fin_rec_new.eofy_reserve,
          X_terminal_gain_loss_amount    => x_asset_fin_rec_new.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => nvl(x_asset_fin_rec_new.ltd_cost_of_removal, 0) +
                                            p_cost_of_removal,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => px_asset_hdr_rec.set_of_books_id,
          X_Return_Status                => l_status,
          X_Calling_Fn                   => l_calling_fn,
          p_log_level_rec                => p_log_level_rec
         );

   if not l_status then
      raise adj_err;
   end if;

   return true;

EXCEPTION
   when adj_err then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

END do_retirement_adjustment;

END FA_RETIREMENT_ADJUSTMENT_PVT;

/
