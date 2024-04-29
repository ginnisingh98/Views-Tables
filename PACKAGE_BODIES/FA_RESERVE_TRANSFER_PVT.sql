--------------------------------------------------------
--  DDL for Package Body FA_RESERVE_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RESERVE_TRANSFER_PVT" AS
/* $Header: FAVRSVXB.pls 120.7.12010000.2 2009/07/19 11:18:22 glchen ship $ */

FUNCTION do_adjustment
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
    p_source_dest              IN     VARCHAR2,
    p_amount                   IN     NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for new group code
   l_adj                 fa_adjust_type_pkg.fa_adj_row_struct;
   l_bks_rowid           varchar2(30);
   l_status              BOOLEAN;

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

   -- set the new structs to the old ones
   -- (values which changes such as adjusted_cost will be set below)

   x_asset_fin_rec_new   := p_asset_fin_rec_old;
   x_asset_deprn_rec_new := p_asset_deprn_rec_old;


   -- call the category books cache for the accounts
   if not fa_cache_pkg.fazccb(X_book   => px_asset_hdr_rec.book_type_code,
                              X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;


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
   l_adj.last_update_date         := px_trans_rec.transaction_date_entered;

   l_adj.flush_adj_flag           := TRUE;
   l_adj.gen_ccid_flag            := TRUE;
   l_adj.annualized_adjustment    := 0;
   l_adj.asset_invoice_id         := 0;
   l_adj.code_combination_id      := 0;
   l_adj.distribution_id          := 0;

   l_adj.deprn_override_flag:= '';

   l_adj.source_type_code         := 'ADJUSTMENT'; -- ???
   l_adj.adjustment_type          := 'RESERVE';
   l_adj.adjustment_amount        := p_amount;
   l_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
   l_adj.account_type             := 'DEPRN_RESERVE_ACCT';
   l_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
   l_adj.set_of_books_id          := px_asset_hdr_rec.set_of_books_id;


   if (p_source_dest = 'S') then
      l_adj.debit_credit_flag        := 'DR';
      l_adj.source_dest_code         := 'SOURCE';
   else
      l_adj.debit_credit_flag        := 'CR';
      l_adj.source_dest_code         := 'DEST';
   end if;

   if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;

   -- for life based methods, this where we would need to recalculate raf, etc
   -- should be able to use the
   --
   -- insure the amort start date is null and then add the amount to the old reserve

   px_trans_rec.amortization_start_date := null;
   if (p_source_dest = 'S') then
      x_asset_deprn_rec_new.deprn_reserve := x_asset_deprn_rec_new.deprn_reserve - p_amount;
      l_asset_deprn_rec_adj.deprn_reserve := -1 * p_amount;
   else
      x_asset_deprn_rec_new.deprn_reserve := x_asset_deprn_rec_new.deprn_reserve + p_amount;
      l_asset_deprn_rec_adj.deprn_reserve := p_amount;
   end if;

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
              p_proceeds_of_sale      => 0,
              p_cost_of_removal       => 0,
              x_deprn_exp             => l_deprn_exp,
              x_bonus_deprn_exp       => l_bonus_deprn_exp,
              x_impairment_exp        => l_impairment_exp,
              x_deprn_rsv             => l_deprn_rsv, p_log_level_rec => p_log_level_rec)) then

      raise adj_err;

   end if; -- (not FA_AMORT_PVT.faxama


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
         ,  p_log_level_rec => p_log_level_rec);

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
          X_allocate_to_fully_rsv_flag   => x_asset_fin_rec_new.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   => x_asset_fin_rec_new.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => x_asset_fin_rec_new.exclude_fully_rsv_flag,
          X_excess_allocation_option     => x_asset_fin_rec_new.excess_allocation_option,
          X_depreciation_option          => x_asset_fin_rec_new.depreciation_option,
          X_member_rollup_flag           => x_asset_fin_rec_new.member_rollup_flag,
          X_ytd_proceeds                 => x_asset_fin_rec_new.ytd_proceeds,
          X_ltd_proceeds                 => x_asset_fin_rec_new.ltd_proceeds,
          X_eofy_reserve                 => x_asset_fin_rec_new.eofy_reserve,
          X_terminal_gain_loss_amount    => x_asset_fin_rec_new.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => x_asset_fin_rec_new.ltd_cost_of_removal,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => px_asset_hdr_rec.set_of_books_id,
          X_Return_Status                => l_status,
          X_Calling_Fn                   => l_calling_fn
         , p_log_level_rec => p_log_level_rec);

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

END do_adjustment;

END FA_RESERVE_TRANSFER_PVT;

/
