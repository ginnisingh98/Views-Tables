--------------------------------------------------------
--  DDL for Package Body FA_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADJUSTMENT_PVT" as
/* $Header: FAVADJB.pls 120.48.12010000.8 2010/02/24 07:04:11 souroy ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION do_adjustment
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new          OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_inv_trans_rec           IN     FA_API_TYPES.inv_trans_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new        OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_reclassed_asset_id      IN     NUMBER default null,
    p_reclass_src_dest        IN     VARCHAR2 default null,
    p_reclassed_asset_dpis    IN     DATE default null,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_calling_fn              IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_th_rowid                        varchar2(30);
   l_bks_rowid                       varchar2(30);

   l_status                          boolean;
   l_ret_status                      varchar2(1);

   l_old_transaction_type_code       varchar2(30);
   l_period_counter                  number;

   l_deprn_exp                       number;
   l_bonus_deprn_exp                 number;
   l_impairment_exp                  number;
   l_deprn_adjustment_amount         number;
   l_deprn_exp_amort_nbv             number;

   -- Bug 8533933
   l_bonus_deprn_exp_adj             number;
   l_bonus_reserve_adj               number;
   -- End Bug 8533933

   --Bug 8297075
   l_mvmt_deprn_reval_reserve        number;
   l_open_deprn_reval_reserve        number;
   --Bug 8297075

   l_raf                             number;

   l_calling_fn                      varchar2(35) := 'fa_adjustment_pvt.do_adjustment';
   deprn_override_flag_default       varchar2(1);

   l_reserve_adjustment_amount       number;
   l_asset_fin_rec_null              FA_API_TYPES.asset_fin_rec_type;

   adj_err                           EXCEPTION;

   -- Track Member
   l_ret_code                     number;
   l_group_level_override         VARCHAR2(1) := 'Y';
   x_group_deprn_amount           number;
   x_group_bonus_amount           number;

   --Bug3548724
   l_asset_deprn_rec_adj          FA_API_TYPES.asset_deprn_rec_type;

   -- SLA
   l_event_status                 varchar2(15);
   l_event_type_code              varchar2(30);

   l_cgu_change_flag              VARCHAR2(1) := 'N';
   l_nbv_at_switch_var            VARCHAR2(1) := 'Y';--bug 7555962
   -- Bug:5930979:Japan Tax Reform Project
   l_method_type                  NUMBER := 0;
   l_success                      INTEGER;
   l_rate_in_use                  NUMBER;

   l_original_Rate                NUMBER;
   l_Revised_Rate                 NUMBER;
   l_Guaranteed_Rate              NUMBER;
   l_is_revised_rate              NUMBER;
   l_comp_val                     NUMBER; --bug 8639894
BEGIN

   --set up transaction types for adjustments vs. addition voids

   if (px_asset_hdr_rec.period_of_addition = 'Y' and
       G_release = 11) then
      if (p_asset_type_rec.asset_type = 'CIP') then
         px_trans_rec.transaction_type_code := 'CIP ADDITION';
         l_old_transaction_type_code := 'CIP ADDITION';
      elsif (p_asset_type_rec.asset_type = 'GROUP') then
         px_trans_rec.transaction_type_code := 'GROUP ADDITION';
         l_old_transaction_type_code := 'GROUP ADDITION';
      else
         px_trans_rec.transaction_type_code := 'ADDITION';
         l_old_transaction_type_code := 'ADDITION';
      end if;
   else
      if (p_asset_type_rec.asset_type = 'CIP') then
         px_trans_rec.transaction_type_code := 'CIP ADJUSTMENT';
         l_old_transaction_type_code := 'CIP ADJUSTMENT';
      elsif  (p_asset_type_rec.asset_type = 'GROUP') then
         l_old_transaction_type_code := 'GROUP ADJUSTMENT';
      else
         px_trans_rec.transaction_type_code := 'ADJUSTMENT';
         l_old_transaction_type_code := 'ADJUSTMENT';
      end if;
   end if;

   deprn_override_flag_default:= fa_std_types.FA_NO_OVERRIDE;

   -- call the calulation engine - see comments below for FA_ADJ

   if not FA_ASSET_CALC_PVT.calc_fin_info
                 (px_trans_rec              => px_trans_rec,
                  p_inv_trans_rec           => p_inv_trans_rec,
                  p_asset_hdr_rec           => px_asset_hdr_rec ,
                  p_asset_desc_rec          => p_asset_desc_rec,
                  p_asset_type_rec          => p_asset_type_rec,
                  p_asset_cat_rec           => p_asset_cat_rec,
                  p_asset_fin_rec_old       => p_asset_fin_rec_old,
                  p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
                  px_asset_fin_rec_new      => x_asset_fin_rec_new,
                  p_asset_deprn_rec_old     => p_asset_deprn_rec_old,
                  p_asset_deprn_rec_adj     => p_asset_deprn_rec_adj,
                  px_asset_deprn_rec_new    => x_asset_deprn_rec_new,
                  p_period_rec              => p_period_rec,
                  p_reclassed_asset_id      => p_reclassed_asset_id,
                  p_reclass_src_dest        => p_reclass_src_dest,
                  p_reclassed_asset_dpis    => p_reclassed_asset_dpis,
                  p_mrc_sob_type_code       => p_mrc_sob_type_code,
                  p_group_reclass_options_rec => p_group_reclass_options_rec,
                  p_calling_fn              => l_calling_fn
                 , p_log_level_rec => p_log_level_rec) then raise adj_err;
   end if;

   -- Fix for Bug:5130208
   if (nvl(p_asset_fin_rec_adj.cash_generating_unit_id,
           nvl(p_asset_fin_rec_old.cash_generating_unit_id, FND_API.G_MISS_NUM)) <>
       nvl(p_asset_fin_rec_old.cash_generating_unit_id, FND_API.G_MISS_NUM)) then
      l_cgu_change_flag := 'Y';
   else
      l_cgu_change_flag := 'N';
   end if;

   -- call the table handlers to process the adjustment

   -- transaction headers

   if (p_mrc_sob_type_code <> 'R') then

      -- validate call is done from public package now

      -- do th processing
      if (px_asset_hdr_rec.period_of_addition = 'Y' and
          G_release = 11) then

         FA_TRANSACTION_HEADERS_PKG.Update_Trx_Type
                       (X_Book_Type_Code                => px_asset_hdr_rec.book_type_code,
                        X_Asset_Id                      => px_asset_hdr_rec.asset_id,
                        X_Transaction_Type_Code         => l_old_transaction_type_code,
                        X_New_Transaction_Type          => l_old_transaction_type_code || '/VOID',
                        X_Return_Status                 => l_status,
                        X_Calling_Fn                    => l_calling_fn
                       , p_log_level_rec => p_log_level_rec);

         if not l_status then
            raise adj_err;
         end if;

         -- for amortize nbv, these need to be set correctly
         -- outside the period of addition trx date is already the amort date
         -- BUG# 2425540 - only set the amort_start_date for amort trxs

         -- group - this is iffy!!!!  do we want trx_date to be dpis in period of add?
         -- whole section if iffy - why are we resetting amort start date here???
         -- should be able to modify reclass engine to redefault the info instead
           -- of exlcuding it here

        --Bug6332519
        --Added the check for amortization_start_date
         if (px_trans_rec.transaction_subtype = 'AMORTIZED' and
             p_asset_type_rec.asset_type <> 'GROUP')  and
             px_trans_rec.amortization_start_date is null then
            px_trans_rec.amortization_start_date  := px_trans_rec.transaction_date_entered;
         end if;

         if (p_asset_type_rec.asset_type <> 'GROUP') then
            px_trans_rec.transaction_date_entered := x_asset_fin_rec_new.date_placed_in_service;
         end if;

      end if;

      -- SLA UPTAKE
      -- assign an event for the transaction
      -- at this point key info asset/book/trx info is known from above code
      --   *** but trx_date_entered may not be correct! - revisit ***
      --
      -- do not assign when this is called from invoice api for like
      -- asset types - an event is already assigned and do not call
      -- when this is called for a group asset from the driving member

      if (nvl(p_inv_trans_rec.transaction_type, 'X') <> 'INVOICE TRANSFER' and
          p_calling_fn = 'fa_adjustment_pub.do_all_books' and
          px_trans_rec.member_transaction_header_id is null and
          G_release <> 11) then

         if (x_asset_fin_rec_new.adjustment_required_status = 'GADJ') then
            l_event_status := FA_XLA_EVENTS_PVT.C_EVENT_INCOMPLETE;
         else
            l_event_status := null; -- default
         end if;

         if not FA_XLA_EVENTS_PVT.create_transaction_event
                 (p_asset_hdr_rec          => px_asset_hdr_rec,
                  p_asset_type_rec         => p_asset_type_rec,
                  px_trans_rec             => px_trans_rec,
                  p_event_status           => l_event_status,
                  p_calling_fn             => l_calling_fn
                  ,p_log_level_rec => p_log_level_rec) then
            raise adj_err;
         end if;

      elsif (x_asset_fin_rec_new.adjustment_required_status = 'GADJ' and
             G_release <> 11) then
         -- enter here if member driven and deferred calculations

         if not fa_xla_events_pvt.get_event_type
           (p_event_id              => px_trans_rec.event_id,
            x_event_type_code       => l_event_type_code,
            p_log_level_rec         => p_log_level_rec
           ) then
           raise adj_err;
         end if;

         if (l_event_type_code in ('SOURCE_LINE_TRANSFERS',
                                   'CIP_SOURCE_LINE_TRANSFERS')) then

            if not fa_xla_events_pvt.update_inter_transaction_event
               (p_ledger_id              => px_asset_hdr_rec.set_of_books_id,
                p_trx_reference_id       => px_trans_rec.trx_reference_id,
                p_book_type_code         => px_asset_hdr_rec.book_type_code,
                p_event_type_code        => l_event_type_code,
                p_event_date             => px_trans_rec.transaction_date_entered,
                p_event_status_code      => FA_XLA_EVENTS_PVT.C_EVENT_INCOMPLETE,
                p_calling_fn             => l_calling_fn,
                p_log_level_rec          => p_log_level_rec) then
              raise adj_err;
            end if;

         else -- non inter asset trx

            if not fa_xla_events_pvt.update_transaction_event
               (p_ledger_id              => px_asset_hdr_rec.set_of_books_id,
                p_transaction_header_id  => px_trans_rec.member_transaction_header_id,
                p_book_type_code         => px_asset_hdr_rec.book_type_code,
                p_event_type_code        => l_event_type_code,
                p_event_date             => px_trans_rec.transaction_date_entered,
                p_event_status_code      => FA_XLA_EVENTS_PVT.C_EVENT_INCOMPLETE,
                p_calling_fn             => l_calling_fn,
                p_log_level_rec          => p_log_level_rec) then
               raise adj_err;
            end if;

         end if;

      end if;

      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('pvt adj api', 'trx_date before insert', px_trans_rec.transaction_date_entered, p_log_level_rec => p_log_level_rec);
      end if;

      FA_TRANSACTION_HEADERS_PKG.Insert_Row
                      (X_Rowid                          => l_th_rowid,
                       X_Transaction_Header_Id          => px_trans_rec.transaction_header_id,
                       X_Book_Type_Code                 => px_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => px_asset_hdr_rec.asset_id,
                       X_Transaction_Type_Code          => px_trans_rec.transaction_type_code,
                       X_Transaction_Date_Entered       => px_trans_rec.transaction_date_entered,
                       X_Date_Effective                 => px_trans_rec.who_info.creation_date,
                       X_Last_Update_Date               => px_trans_rec.who_info.last_update_date,
                       X_Last_Updated_By                => px_trans_rec.who_info.last_updated_by,
                       X_Transaction_Name               => px_trans_rec.transaction_name,
                       X_Invoice_Transaction_Id         => p_inv_trans_rec.invoice_transaction_id ,
                       X_Source_Transaction_Header_Id   => px_trans_rec.Source_Transaction_Header_Id,
                       X_Mass_Reference_Id              => px_trans_rec.mass_reference_id,
                       X_Last_Update_Login              => px_trans_rec.who_info.last_update_login,
                       X_Transaction_Subtype            => px_trans_rec.transaction_subtype,
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
                       X_Transaction_Key                => px_trans_rec.transaction_key,
                       X_Amortization_Start_Date        => px_trans_rec.amortization_start_date,
                       X_Calling_Interface              => px_trans_rec.calling_interface,
                       X_Mass_Transaction_ID            => px_trans_rec.mass_transaction_id,
                       X_Member_Transaction_Header_Id   => px_trans_rec.member_transaction_header_id,
                       X_Trx_Reference_Id               => px_trans_rec.trx_reference_id,
                       X_Event_Id                       => px_trans_rec.event_id,

                       X_Return_Status                  => l_status,
                       X_Calling_Fn                     => l_calling_fn
                      , p_log_level_rec => p_log_level_rec);
      if not l_status then
         raise adj_err;
      end if;
   end if;

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
          X_Disabled_Flag                => x_asset_fin_rec_new.disabled_flag, --HH
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
          X_super_group_id          => x_asset_fin_rec_new.super_group_id,
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
          X_cip_cost                     => x_asset_fin_rec_new.cip_cost,
          X_terminal_gain_loss_amount    => x_asset_fin_rec_new.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => x_asset_fin_rec_new.ltd_cost_of_removal,
          X_contract_id                  => x_asset_fin_rec_new.contract_id, -- Bug:8240522
          X_cash_generating_unit_id      => x_asset_fin_rec_new.cash_generating_unit_id,
          X_extended_deprn_flag            => x_asset_fin_rec_new.extended_deprn_flag,          -- Japan Tax phase3
          X_extended_depreciation_period   => x_asset_fin_rec_new.extended_depreciation_period, -- Japan Tax phase3
          X_mrc_sob_type_code              => p_mrc_sob_type_code,
          X_set_of_books_id                => px_asset_hdr_rec.set_of_books_id,
          X_Return_Status                  => l_status,
          X_Calling_Fn                     => l_calling_fn,
          X_nbv_at_switch                  => x_asset_fin_rec_new.nbv_at_switch,
          -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
          X_prior_deprn_limit_type         => x_asset_fin_rec_new.prior_deprn_limit_type,
          X_prior_deprn_limit_amount       => x_asset_fin_rec_new.prior_deprn_limit_amount,
          X_prior_deprn_limit              => x_asset_fin_rec_new.prior_deprn_limit,
          X_period_counter_fully_rsrved    => x_asset_fin_rec_new.period_counter_fully_reserved,
          --X_extended_depreciation_period => x_asset_fin_rec_new.extended_depreciation_period ,
          X_prior_deprn_method             => x_asset_fin_rec_new.prior_deprn_method,
          X_prior_life_in_months           => x_asset_fin_rec_new.prior_life_in_months,
          X_prior_basic_rate               => x_asset_fin_rec_new.prior_basic_rate,
          X_prior_adjusted_rate            => x_asset_fin_rec_new.prior_adjusted_rate  -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End
   , p_log_level_rec => p_log_level_rec);


   if not l_status then
      raise adj_err;
   end if;

   -- Bug:5930979:Japan Tax Reform Project (Start)
   if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES'
   then
      FA_CDE_PKG.faxgfr (X_Book_Type_Code         => px_asset_hdr_rec.book_type_code,
                         X_Asset_Id               => px_asset_hdr_rec.asset_id,
                         X_Short_Fiscal_Year_Flag => NULL,
                         X_Conversion_Date        => NULL,
                         X_Prorate_Date           => NULL,
                         X_Orig_Deprn_Start_Date  => NULL,
                         C_Prorate_Date           => NULL,
                         C_Conversion_Date        => NULL,
                         C_Orig_Deprn_Start_Date  => NULL,
                         X_Method_Code            => fa_cache_pkg.fazccmt_record.method_code,
                         X_Life_In_Months         => fa_cache_pkg.fazccmt_record.life_in_months,
                         X_Fiscal_Year            => -99,
                         X_Current_Period            => -99,
                         X_calling_interface      => 'AFTER_ADJ',
                         X_Rate                   => l_rate_in_use,
                         X_Method_Type            => l_method_type,
                         X_Success                => l_success, p_log_level_rec => p_log_level_rec);

      if (l_success <= 0) then
         fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.insert_asset',  p_log_level_rec => p_log_level_rec);
         raise adj_err;
      end if;

      BEGIN
        SELECT FF.original_rate
             , FF.revised_rate
             , FF.guarantee_rate
        INTO   l_original_Rate
             , l_Revised_Rate
             , l_Guaranteed_Rate
        FROM   FA_FORMULAS FF
             , FA_METHODS FM
        WHERE  FF.METHOD_ID = FM.METHOD_ID
        AND    FM.METHOD_CODE = x_asset_fin_rec_new.deprn_method_code;
      EXCEPTION
        WHEN OTHERS THEN
             l_original_Rate := 0;
             l_Revised_Rate := 0;
             l_Guaranteed_Rate := 0;
             l_is_revised_rate := 0;
      END;

      -- bug 7668308:Added the trunc and ytd value to calculate correct
      -- rate in use.
      --
      -- Fix for Bug #8226054.  Need to change original_cost to cost for
      -- comparison.
      --Bug 8639894 need to include deprn expense in deprn reserve also
      -- in case some adjustment is done
      IF x_asset_fin_rec_new.eofy_reserve = 0 then
         l_comp_val := x_asset_deprn_rec_new.deprn_reserve - x_asset_deprn_rec_new.ytd_deprn;
      ELSE
         l_comp_val := x_asset_fin_rec_new.eofy_reserve;
      END IF;

      IF (trunc(x_asset_fin_rec_new.cost * l_Guaranteed_Rate)) >
         (trunc((x_asset_fin_rec_new.cost - l_comp_val)* l_original_Rate)) THEN
         l_rate_in_use := l_Revised_Rate;
      ELSE
         l_rate_in_use := l_original_Rate;
      END IF;
      /*-------------------------------------------------------------------
       * Bug 7555962
       * Added the below if condition so that when user modifies the YTD/LTD
       * in period of addition such that asset comes to original state from
       * switched state the NBV_AT_SWITCH becomes null.
       *-------------------------------------------------------------------*/
      l_nbv_at_switch_var := 'Y';
      if (l_rate_in_use <> l_Revised_Rate) THEN
         l_nbv_at_switch_var := 'X';
      end if;

      UPDATE FA_BOOKS
         SET rate_in_use = l_rate_in_use
             ,nbv_at_switch = Decode(l_nbv_at_switch_var,'X',NULL,nbv_at_switch)
         WHERE book_type_code = px_asset_hdr_rec.book_type_code
         AND asset_id = px_asset_hdr_rec.asset_id
         AND date_ineffective is null;

   end if;
   -- Bug:5930979:Japan Tax Reform Project (End)

   -- update TH/BKS/DS/DD for adjustments in period of addition (i.e. voids)

   -- Bug7017134: Added condition not to touch B(OOKS) row if group adjustment is pending

   -- R12 conditional logic
   -- SLA Uptake
   -- this section is altered to account for new period of addition
   -- changes.
   --
   -- 1) Since the prior unplanned solution is obsolete, no need to
   --    track or store deprn_adj_amount
   -- 2) we will only be tracking updates to YTD in the info for
   --    DS/DD, reserve remains untouched

   if (px_asset_hdr_rec.period_of_addition = 'Y') and
      (l_cgu_change_flag = 'N') and
      ((p_asset_type_rec.asset_type <> 'GROUP') or
       (p_asset_type_rec.asset_type = 'GROUP' and
        (nvl(x_asset_fin_rec_new.member_rollup_flag,'N') <> 'Y' and
         (not(px_trans_rec.calling_interface = 'FAXASSET' and
          x_asset_fin_rec_new.adjustment_required_status = 'GADJ'))
                                                  ))
                                                      ) then

      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('pvt adj api', 'logic for update deprn detail/summary', 'Starts', p_log_level_rec => p_log_level_rec);
      end if;

      -- we need to account for unplanned in the period of addition
      --
      -- also for amort nbv scenarios where we don't want to
      -- include the catchup in the reserve amount

      if (nvl(px_trans_rec.transaction_key, 'XX') not in ('UA', 'UE')) then

      if (p_mrc_sob_type_code <> 'R') then
         select nvl(sum(deprn_adjustment_amount), 0)
           into l_deprn_adjustment_amount
           from fa_deprn_detail
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and deprn_source_code = 'B';

         select nvl(sum(decode(debit_credit_flag,
                               'DR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_deprn_exp_amort_nbv
           from fa_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'EXPENSE';

         select nvl(sum(decode(debit_credit_flag,
                               'CR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_reserve_adjustment_amount
           from fa_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'RESERVE';

         -- Bug 8533933
         select nvl(sum(decode(debit_credit_flag,
                               'DR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_bonus_deprn_exp_adj
           from fa_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'BONUS EXPENSE';

         select nvl(sum(decode(debit_credit_flag,
                               'CR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_bonus_reserve_adj
           from fa_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'BONUS RESERVE';
	 -- End Bug 8533933

         select nvl(sum(decode(debit_credit_flag,
                               'CR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_mvmt_deprn_reval_reserve
           from fa_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'REVAL RESERVE';

      else
         select nvl(sum(deprn_adjustment_amount), 0)
           into l_deprn_adjustment_amount
           from fa_mc_deprn_detail
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and deprn_source_code = 'B'
            and set_of_books_id = px_asset_hdr_rec.set_of_books_id;

         select nvl(sum(decode(debit_credit_flag,
                               'DR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_deprn_exp_amort_nbv
           from fa_mc_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'EXPENSE'
            and set_of_books_id = px_asset_hdr_rec.set_of_books_id;

         select nvl(sum(decode(debit_credit_flag,
                               'CR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_reserve_adjustment_amount
           from fa_mc_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'RESERVE'
            and set_of_books_id = px_asset_hdr_rec.set_of_books_id;

         -- Bug 8533933
         select nvl(sum(decode(debit_credit_flag,
                               'DR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_bonus_deprn_exp_adj
           from fa_mc_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'BONUS EXPENSE'
	    and set_of_books_id = px_asset_hdr_rec.set_of_books_id;

         select nvl(sum(decode(debit_credit_flag,
                               'CR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_bonus_reserve_adj
           from fa_mc_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'BONUS RESERVE'
            and set_of_books_id = px_asset_hdr_rec.set_of_books_id;
	 -- End Bug 8533933

         select nvl(sum(decode(debit_credit_flag,
                               'CR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_mvmt_deprn_reval_reserve
           from fa_mc_adjustments
          where book_type_code = px_asset_hdr_rec.book_type_code
            and asset_id       = px_asset_hdr_rec.asset_id
            and adjustment_type  = 'REVAL RESERVE';

      end if;

      end if; -- unplanne

      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('pvt adj api', 'l_deprn_adjustment_amount', l_deprn_adjustment_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add('pvt adj api', 'x_asset_deprn_rec_new.deprn_reserve', x_asset_deprn_rec_new.deprn_reserve, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add('pvt adj api', 'l_deprn_exp_amort_nbv', l_deprn_exp_amort_nbv, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add('pvt adj api', 'l_reserve_adjustment_amount', l_reserve_adjustment_amount, p_log_level_rec => p_log_level_rec);
	fa_debug_pkg.add('pvt adj api', 'l_bonus_deprn_exp_adj', l_bonus_deprn_exp_adj, p_log_level_rec => p_log_level_rec);  -- Bug 8533933
	fa_debug_pkg.add('pvt adj api', 'l_bonus_reserve_adj', l_bonus_reserve_adj, p_log_level_rec => p_log_level_rec);      -- Bug 8533933
        fa_debug_pkg.add('pvt adj api', 'reval amo', x_asset_deprn_rec_new.reval_amortization, p_log_level_rec => p_log_level_rec);
 	fa_debug_pkg.add('pvt adj api', 'reval amo basis ',x_asset_deprn_rec_new.reval_amortization_basis, p_log_level_rec => p_log_level_rec);
 	fa_debug_pkg.add('pvt adj api', 'reval dep expense',x_asset_deprn_rec_new.reval_deprn_expense, p_log_level_rec => p_log_level_rec);
 	fa_debug_pkg.add('pvt adj api', 'reval dep rsve ',x_asset_deprn_rec_new.reval_deprn_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      --bug fix 5672546
      if p_group_reclass_options_rec.group_reclass_type = 'MANUAL' then
        /*Bug#7715051 -- Backported following logic from R12 and commented code for bug Bug7017134
                      -- Incase of group-group reclass for member asset having backdated dpis
                      -- When manual reserve transfer is done the reserve row in fa_adj is inserted from
                      -- FAVGRECB.pls after update in deprn summary because of which reserve amount
                      -- is not considered when calculating l_reserve_adjustment_amount in above select statement
                      -- causing wrong value of reserve to be updated in 'BOOKS' row of deprn summary and detail.*/

        if p_asset_type_rec.asset_type = 'GROUP' then
            if p_reclass_src_dest = 'SOURCE' then
               l_reserve_adjustment_amount := l_reserve_adjustment_amount -
                                                 nvl(p_group_reclass_options_rec.reserve_amount,0) ;
            elsif p_reclass_src_dest = 'DESTINATION' then
               l_reserve_adjustment_amount := l_reserve_adjustment_amount +
                                                 nvl(p_group_reclass_options_rec.reserve_amount,0) ;
            end if;
         end if;
      --Bug#7715051 - end

      elsif p_group_reclass_options_rec.group_reclass_type = 'CALC'  and
            p_asset_type_rec.asset_type = 'GROUP' and
            px_trans_rec.calling_interface <> 'FAXASSET' then

         if p_reclass_src_dest = 'SOURCE' then
            l_reserve_adjustment_amount := l_reserve_adjustment_amount - nvl(p_group_reclass_options_rec.reserve_amount,0);
         end if;

      end if;



      l_open_deprn_reval_reserve := NVL(x_asset_deprn_rec_new.reval_deprn_reserve,0) - l_mvmt_deprn_reval_reserve;
      if (p_log_level_rec.statement_level) THEN
 	    fa_debug_pkg.ADD('pvt adj api', 'reval dep rsve (mvt) ',l_mvmt_deprn_reval_reserve, p_log_level_rec => p_log_level_rec);
 	    fa_debug_pkg.add('pvt adj api', 'reval dep rsve (opbal) ',l_open_deprn_reval_reserve, p_log_level_rec => p_log_level_rec);
      end if;
      FA_DEPRN_SUMMARY_PKG.Update_Row
                      (X_Book_Type_Code                 => px_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => px_asset_hdr_rec.asset_id,
                       X_Deprn_Run_Date                 => px_trans_rec.who_info.last_update_date,
                       X_Deprn_Amount                   => x_asset_deprn_rec_new.deprn_amount,
                       X_Ytd_Deprn                      => x_asset_deprn_rec_new.ytd_deprn -
                                                           l_deprn_exp_amort_nbv,
                       X_Deprn_Reserve                  => x_asset_deprn_rec_new.deprn_reserve -
                                                           l_deprn_exp_amort_nbv -
                                                           l_reserve_adjustment_amount,
                       X_Deprn_Source_Code              => 'BOOKS',
                       X_Adjusted_Cost                  => x_asset_fin_rec_new.adjusted_cost,
                       X_Bonus_Rate                     => NULL,
                       X_Ltd_Production                 => NULL,
                       X_Period_Counter                 => p_period_rec.period_counter - 1,
                       X_Production                     => NULL,
                       X_Reval_Amortization             => x_asset_deprn_rec_new.reval_amortization,
                       X_Reval_Amortization_Basis       => x_asset_deprn_rec_new.reval_amortization_basis,
                       X_Reval_Deprn_Expense            => x_asset_deprn_rec_new.reval_deprn_expense,
                       X_Reval_Reserve                  => l_open_deprn_reval_reserve,
                       X_Ytd_Production                 => NULL,
                       X_Ytd_Reval_Deprn_Expense        => x_asset_deprn_rec_new.reval_ytd_deprn,
                       X_Bonus_Deprn_Amount             => x_asset_deprn_rec_new.bonus_deprn_amount,
                       X_Bonus_Ytd_Deprn                => x_asset_deprn_rec_new.bonus_ytd_deprn -
		                                           l_bonus_deprn_exp_adj,                      -- Bug 8533933
                       X_Bonus_Deprn_Reserve            => x_asset_deprn_rec_new.bonus_deprn_reserve -
		                                           l_bonus_deprn_exp_adj -                     -- Bug 8533933
							   l_bonus_reserve_adj,                        -- Bug 8533933
                       X_Impairment_Amount              => x_asset_deprn_rec_new.impairment_amount,
                       X_Ytd_Impairment                 => x_asset_deprn_rec_new.ytd_impairment,
                       X_impairment_reserve                 => x_asset_deprn_rec_new.impairment_reserve,
                       X_mrc_sob_type_code              => p_mrc_sob_type_code,
                       X_set_of_books_id                => px_asset_hdr_rec.set_of_books_id,
                       X_Calling_Fn                     => l_calling_fn
                      , p_log_level_rec => p_log_level_rec);

       if not FA_INS_DETAIL_PKG.FAXINDD
                     (X_book_type_code           => px_asset_hdr_rec.book_type_code,
                      X_asset_id                 => px_asset_hdr_rec.asset_id,
                      X_deprn_adjustment_amount  => l_deprn_adjustment_amount,
                      X_mrc_sob_type_code        => p_mrc_sob_type_code,
                      X_set_of_books_id    => px_asset_hdr_rec.set_of_books_id
                     , p_log_level_rec => p_log_level_rec) then raise adj_err;
       end if;

     -- now perform amortize nbv if applicable

     if (px_trans_rec.transaction_subtype = 'AMORTIZED' and
         p_asset_type_rec.asset_type = 'CAPITALIZED' and
         l_cgu_change_flag = 'N' and
         x_asset_fin_rec_new.group_asset_id is null and
         G_release = 11)  then

        -- excluding group as calc engine should handle all trxs
        -- (p_asset_type_rec.asset_type = 'GROUP')) and
        -- (p_calling_fn = 'fa_adjustment_pub.do_all_books') then

         -- amortization start date was previously validated from calc engine

         -- Bug3548724
         -- It is important to pass reserve only amount in deprn_rec_adj for faxama.
         --
         l_asset_deprn_rec_adj.ytd_deprn           := x_asset_deprn_rec_new.ytd_deprn -
                                                      p_asset_deprn_rec_old.deprn_amount;
         l_asset_deprn_rec_adj.deprn_reserve       := x_asset_deprn_rec_new.deprn_reserve -
                                                      p_asset_deprn_rec_old.deprn_amount;
         l_asset_deprn_rec_adj.bonus_ytd_deprn     := x_asset_deprn_rec_new.bonus_ytd_deprn -
                                                      p_asset_deprn_rec_old.bonus_deprn_amount;
         l_asset_deprn_rec_adj.bonus_deprn_reserve := x_asset_deprn_rec_new.bonus_deprn_reserve -
                                                      p_asset_deprn_rec_old.bonus_deprn_amount;
         l_asset_deprn_rec_adj.ytd_impairment      := nvl(x_asset_deprn_rec_new.ytd_impairment,0) -
                                                      nvl(p_asset_deprn_rec_old.impairment_amount,0);
         l_asset_deprn_rec_adj.impairment_reserve      := nvl(x_asset_deprn_rec_new.impairment_reserve,0) -
                                                      nvl(p_asset_deprn_rec_old.impairment_amount,0);


         if not FA_AMORT_PVT.faxama
                  (px_trans_rec          => px_trans_rec,
                   p_asset_hdr_rec       => px_asset_hdr_rec,
                   p_asset_desc_rec      => p_asset_desc_rec,
                   p_asset_cat_rec       => p_asset_cat_rec,
                   p_asset_type_rec      => p_asset_type_rec,
                   p_asset_fin_rec_old   => x_asset_fin_rec_new,
                   p_asset_fin_rec_adj   => l_asset_fin_rec_null,
                   px_asset_fin_rec_new  => x_asset_fin_rec_new,
                   p_asset_deprn_rec     => x_asset_deprn_rec_new,
                   p_asset_deprn_rec_adj => l_asset_deprn_rec_adj,    --bug3548724
                   p_period_rec          => p_period_rec,
                   p_mrc_sob_type_code   => p_mrc_sob_type_code,
                   p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                   p_used_by_revaluation => null,
                   x_deprn_exp           => l_deprn_exp,
                   x_bonus_deprn_exp     => l_bonus_deprn_exp,
                   x_impairment_exp      => l_impairment_exp
                  , p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;


         -- insert the deprn amounts
         if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec       => px_trans_rec,
                      p_asset_hdr_rec   => px_asset_hdr_rec,
                      p_asset_desc_rec  => p_asset_desc_rec,
                      p_asset_cat_rec   => p_asset_cat_rec,
                      p_asset_type_rec  => p_asset_type_rec,
                      p_cost            => 0,
                      p_clearing        => 0,
                      p_deprn_expense   => l_deprn_exp,
                      p_bonus_expense   => l_bonus_deprn_exp,
                      p_impair_expense  => l_impairment_exp,
                      p_ann_adj_amt     => 0,
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn      => l_calling_fn
                     , p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         fa_books_pkg.update_row
            (X_asset_id                  => px_asset_hdr_rec.asset_id,
             X_book_type_code            => px_asset_hdr_rec.book_type_code,
             X_rate_adjustment_factor    => x_asset_fin_rec_new.rate_adjustment_factor,
             X_reval_amortization_basis  => x_asset_fin_rec_new.reval_amortization_basis,
             X_adjusted_cost             => x_asset_fin_rec_new.adjusted_cost,
             X_adjusted_capacity         => x_asset_fin_rec_new.adjusted_capacity,
             X_formula_factor            => x_asset_fin_rec_new.formula_factor,
             X_eofy_reserve              => x_asset_fin_rec_new.eofy_reserve,
             X_mrc_sob_type_code         => p_mrc_sob_type_code,
             X_set_of_books_id           => px_asset_hdr_rec.set_of_books_id,
             X_calling_fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);


         -- now update the primary or reporting amounts accordingly
         if (p_mrc_sob_type_code <> 'R') then

            delete from fa_adjustments
             where asset_id        = px_asset_hdr_rec.asset_id
               and book_type_code  = px_asset_hdr_rec.book_type_code
               and adjustment_type in ('COST', 'COST CLEARING');

         else

            delete from fa_mc_adjustments
             where asset_id        = px_asset_hdr_rec.asset_id
               and book_type_code  = px_asset_hdr_rec.book_type_code
               and adjustment_type in ('COST', 'COST CLEARING')
               and set_of_books_id = px_asset_hdr_rec.set_of_books_id;

         end if;


         FA_DEPRN_SUMMARY_PKG.Update_Row
                      (X_Book_Type_Code                 => px_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => px_asset_hdr_rec.asset_id,
                       X_Adjusted_Cost                  => x_asset_fin_rec_new.adjusted_cost,
                       X_Period_Counter                 => p_period_rec.period_counter - 1,
                       X_Reval_Amortization_Basis       => x_asset_deprn_rec_new.reval_amortization_basis,
                       X_mrc_sob_type_code              => p_mrc_sob_type_code,
                       X_set_of_books_id                => px_asset_hdr_rec.set_of_books_id,
                       X_Calling_Fn                     => l_calling_fn
                      , p_log_level_rec => p_log_level_rec);


      end if;   -- end amort nbv

       -- If the processed asset is GROUP asset and tracking method is 'ALLOCATE',
       -- Call TRACK_ASSETS to allocate unplanned amount into members.
       -- For track member feature
       -- Only when the unplanned depreciation is kicked from group asset whose tracking method is
       -- ALLOCATE, system needs to allocate the entered unplanned depreciation amount into
       -- members.
       if x_asset_fin_rec_new.group_asset_id is null and
          nvl(x_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' and
          (x_asset_deprn_rec_new.deprn_reserve - l_deprn_exp_amort_nbv - l_reserve_adjustment_amount) <> 0 then

         if not fa_cache_pkg.fazccmt (x_asset_fin_rec_new.deprn_method_code,x_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           raise adj_err;
         end if;

         l_ret_code := FA_TRACK_MEMBER_PVT.TRACK_ASSETS
                           (P_book_type_code             => px_asset_hdr_rec.book_type_code,
                            P_group_asset_id             => px_asset_hdr_rec.asset_id,
                            P_period_counter             => p_period_rec.period_num,
                            P_fiscal_year                => p_period_rec.fiscal_year,
                            P_group_deprn_basis          => fa_cache_pkg.fazccmt_record.deprn_basis_rule,
                            P_group_exclude_salvage      => fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag,
                            P_group_bonus_rule           => x_asset_fin_rec_new.bonus_rule,
                            P_group_deprn_amount         => x_asset_deprn_rec_new.deprn_reserve -
                                                           l_deprn_exp_amort_nbv -
                                                           l_reserve_adjustment_amount,
                            P_group_bonus_amount         => 0,
                            P_tracking_method            => x_asset_fin_rec_new.tracking_method,
                            P_allocate_to_fully_ret_flag => x_asset_fin_rec_new.allocate_to_fully_ret_flag,
                            P_allocate_to_fully_rsv_flag => x_asset_fin_rec_new.allocate_to_fully_rsv_flag,
                            P_excess_allocation_option   => x_asset_fin_rec_new.excess_allocation_option,
                            P_subtraction_flag           => 'N',
                            P_group_level_override       => l_group_level_override,
                            P_period_of_addition         => 'Y',
                            P_transaction_date_entered   => px_trans_rec.transaction_date_entered,
                            P_mode                       => 'UNPLANNED',
                            P_mrc_sob_type_code          => p_mrc_sob_type_code,
                            P_set_of_books_id            => px_asset_hdr_rec.set_of_books_id,
                            X_new_deprn_amount           => x_group_deprn_amount,
                            X_new_bonus_amount           => x_group_bonus_amount,  p_log_level_rec => p_log_level_rec);

         if l_ret_code <> 0 then
            raise adj_err;
         elsif x_group_deprn_amount <> (x_asset_deprn_rec_new.deprn_reserve
                                       - l_deprn_exp_amort_nbv - l_reserve_adjustment_amount) then
            raise adj_err;
         end if;

       end if; -- End of Group Unplanned at period of addition

   end if;  --  end period of add

   return true;

EXCEPTION

   when adj_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error
          (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END do_adjustment;



-- this function contains check_changes_before_commit logic (from faxfa1b.pls)
-- insure something is changing and that the depreciate flag is not
-- changing in conjuction with something else.
--
-- note: main change check excludes global flex and calculated values
-- may need to add the global and capitalize values later
-- as in the calc engine need to determine intent for nullable fields
--
-- now called from the public api to avoid errors resulting from
-- calls from group/reclass apis that may result in no change

FUNCTION validate_adjustment
   (p_inv_trans_rec           IN     FA_API_TYPES.inv_trans_rec_type,
    p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

    h_asset_id                 number;

    CURSOR c_group_mem_no_depreciate is
    select 1 from dual
    where exists
    (select 'x' from fa_books
    where book_type_code = p_asset_hdr_rec.book_type_code
    and   group_asset_id = h_asset_id
    and   transaction_header_id_out is null
    and   depreciate_flag = 'NO');
    l_dummy_num number;

   l_no_changes_made          boolean;
   l_no_changes_to_uom        boolean;
   l_no_changes_to_dep_flag   boolean;
   l_no_changes_to_method     boolean;
   l_no_changes_to_group      boolean;
   l_no_changes_to_reduction  boolean;
   l_no_changes_to_impairment boolean;
   l_calling_fn               varchar2(35)  := 'do_adjustment_pvt.validate_adj';

BEGIN

if (nvl(p_trans_rec.transaction_key, 'NULL') <> 'SG') then
   -- no need to check for changes made if driven by invoice
   if p_inv_trans_rec.transaction_type is not null then
      l_no_changes_made := FALSE;
   elsif
      (nvl(p_asset_fin_rec_adj.cost, 0)                  = 0 and
       nvl(p_asset_fin_rec_adj.original_cost, 0)         = 0 and
       nvl(p_asset_deprn_rec_adj.deprn_reserve, 0)       = 0 and
       nvl(p_asset_deprn_rec_adj.ytd_deprn, 0)           = 0 and
       --Test code for 9371739
       NOT (NVL(p_asset_deprn_rec_adj.allow_taxup_flag,FALSE)) AND
       --End of test code for 9371739
       nvl(p_asset_deprn_rec_adj.bonus_deprn_reserve, 0) = 0 and
       nvl(p_asset_deprn_rec_adj.bonus_ytd_deprn, 0)     = 0 and
       nvl(p_asset_deprn_rec_adj.impairment_reserve, 0)      = 0 and
       nvl(p_asset_deprn_rec_adj.ytd_impairment, 0)      = 0 and
       nvl(p_asset_deprn_rec_adj.reval_deprn_reserve, 0) = 0 and
       nvl(p_asset_fin_rec_adj.reval_ceiling, 0)         = 0 and
       nvl(p_asset_fin_rec_adj.production_capacity, 0)   = 0 and
       nvl(p_asset_fin_rec_adj.cip_cost, 0)              = 0 and
       nvl(p_asset_fin_rec_adj.percent_salvage_value, 0) = 0 and
       nvl(p_asset_fin_rec_adj.allowed_deprn_limit,0)    = 0 and
       nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) = 0 and
       p_asset_fin_rec_old.date_placed_in_service =
          nvl(p_asset_fin_rec_adj.date_placed_in_service,
              p_asset_fin_rec_old.date_placed_in_service) and
       p_asset_fin_rec_old.prorate_convention_code =
          nvl(p_asset_fin_rec_adj.prorate_convention_code,
              p_asset_fin_rec_old.prorate_convention_code) and
       nvl(p_asset_fin_rec_old.salvage_value, 0) =
          nvl(p_asset_fin_rec_adj.salvage_value,0) +
              nvl(p_asset_fin_rec_old.salvage_value, 0) and
       nvl(p_asset_fin_rec_old.itc_amount_id, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.itc_amount_id,
              nvl(p_asset_fin_rec_old.itc_amount_id, FND_API.G_MISS_NUM)) and
       nvl(p_asset_fin_rec_old.ceiling_name, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.ceiling_name,
              nvl(p_asset_fin_rec_old.ceiling_name, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.short_fiscal_year_flag, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.short_fiscal_year_flag,
              nvl(p_asset_fin_rec_old.short_fiscal_year_flag, FND_API.G_MISS_CHAR)) and

       -- Bug:8240522
       nvl(p_asset_fin_rec_old.contract_id, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.contract_id,
              nvl(p_asset_fin_rec_old.contract_id, FND_API.G_MISS_NUM)) and

       -- group columns
       nvl(p_asset_fin_rec_old.salvage_type, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.salvage_type,
              nvl(p_asset_fin_rec_old.salvage_type, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.deprn_limit_type, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.deprn_limit_type,
              nvl(p_asset_fin_rec_old.deprn_limit_type, FND_API.G_MISS_CHAR)) and

       nvl(p_asset_fin_rec_old.over_depreciate_option,FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.over_depreciate_option,
              nvl(p_asset_fin_rec_old.over_depreciate_option, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.super_group_id, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.super_group_id,
              nvl(p_asset_fin_rec_old.super_group_id, FND_API.G_MISS_NUM)) and

       -- Japan Tax phase3
       nvl(p_asset_fin_rec_old.extended_deprn_flag, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.extended_deprn_flag,
              nvl(p_asset_fin_rec_old.extended_deprn_flag, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.extended_depreciation_period, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.extended_depreciation_period,
              nvl(p_asset_fin_rec_old.extended_depreciation_period, FND_API.G_MISS_NUM)) and

       -- global flex columns
       nvl(p_asset_fin_rec_old.global_attribute1, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute1,
              nvl(p_asset_fin_rec_old.global_attribute1, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute2, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute2,
              nvl(p_asset_fin_rec_old.global_attribute2, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute3, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute3,
              nvl(p_asset_fin_rec_old.global_attribute3, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute4, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute4,
              nvl(p_asset_fin_rec_old.global_attribute4, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute5, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute5,
              nvl(p_asset_fin_rec_old.global_attribute5, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute6, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute6,
              nvl(p_asset_fin_rec_old.global_attribute6, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute7, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute7,
              nvl(p_asset_fin_rec_old.global_attribute7, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute8, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute8,
              nvl(p_asset_fin_rec_old.global_attribute8, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute9, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute9,
              nvl(p_asset_fin_rec_old.global_attribute9, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute10, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute10,
              nvl(p_asset_fin_rec_old.global_attribute10, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute11, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute11,
              nvl(p_asset_fin_rec_old.global_attribute11, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute12, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute12,
              nvl(p_asset_fin_rec_old.global_attribute12, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute13, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute13,
              nvl(p_asset_fin_rec_old.global_attribute13, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute14, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute14,
              nvl(p_asset_fin_rec_old.global_attribute14, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute15, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute15,
              nvl(p_asset_fin_rec_old.global_attribute15, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute16, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute16,
              nvl(p_asset_fin_rec_old.global_attribute16, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute17, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute17,
              nvl(p_asset_fin_rec_old.global_attribute17, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute18, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute18,
              nvl(p_asset_fin_rec_old.global_attribute18, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute19, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute19,
              nvl(p_asset_fin_rec_old.global_attribute19, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute20, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute20,
              nvl(p_asset_fin_rec_old.global_attribute20, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.global_attribute_category, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.global_attribute_category,
              nvl(p_asset_fin_rec_old.global_attribute_category, FND_API.G_MISS_CHAR))) then
         l_no_changes_made := TRUE;
   else
         l_no_changes_made := FALSE;
   end if;

   if nvl(p_asset_fin_rec_old.unit_of_measure, FND_API.G_MISS_CHAR) =
         nvl(p_asset_fin_rec_adj.unit_of_measure,
             nvl(p_asset_fin_rec_old.unit_of_measure, FND_API.G_MISS_CHAR)) then
      l_no_changes_to_uom := TRUE;
   else
      l_no_changes_to_uom := FALSE;
   end if;

   if (p_asset_fin_rec_old.depreciate_flag = nvl(p_asset_fin_rec_adj.depreciate_flag,
                                                 p_asset_fin_rec_old.depreciate_flag)) then
      l_no_changes_to_dep_flag := TRUE;
   else
      l_no_changes_to_dep_flag := FALSE;
   end if;

   if (nvl(p_asset_fin_rec_old.cash_generating_unit_id, FND_API.G_MISS_NUM) =
       nvl(p_asset_fin_rec_adj.cash_generating_unit_id,
        nvl(p_asset_fin_rec_old.cash_generating_unit_id, FND_API.G_MISS_NUM)))
   then
      l_no_changes_to_impairment := TRUE;
   else
      l_no_changes_to_impairment := FALSE;
   end if;

   if  p_asset_fin_rec_old.deprn_method_code =
          nvl(p_asset_fin_rec_adj.deprn_method_code,
              p_asset_fin_rec_old.deprn_method_code) and
       nvl(p_asset_fin_rec_old.life_in_months, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.life_in_months,
              nvl(p_asset_fin_rec_old.life_in_months, FND_API.G_MISS_NUM)) and
       nvl(p_asset_fin_rec_old.basic_rate, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.basic_rate,
              nvl(p_asset_fin_rec_old.basic_rate, FND_API.G_MISS_NUM)) and
       nvl(p_asset_fin_rec_old.adjusted_rate, FND_API.G_MISS_NUM) =
          nvl(p_asset_fin_rec_adj.adjusted_rate,
              nvl(p_asset_fin_rec_old.adjusted_rate, FND_API.G_MISS_NUM)) and
       nvl(p_asset_fin_rec_old.bonus_rule, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.bonus_rule,
              nvl(p_asset_fin_rec_old.bonus_rule, FND_API.G_MISS_CHAR)) then
      l_no_changes_to_method := TRUE;
   else
      l_no_changes_to_method := FALSE;
   end if;


   if (p_asset_type_rec.asset_type =  'GROUP') then
      if  nvl(p_asset_fin_rec_old.recognize_gain_loss, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.recognize_gain_loss,
                 nvl(p_asset_fin_rec_old.recognize_gain_loss, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.recapture_reserve_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.recapture_reserve_flag,
                 nvl(p_asset_fin_rec_old.recapture_reserve_flag, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.limit_proceeds_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.limit_proceeds_flag,
                 nvl(p_asset_fin_rec_old.limit_proceeds_flag, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.terminal_gain_loss, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.terminal_gain_loss,
                 nvl(p_asset_fin_rec_old.terminal_gain_loss, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.tracking_method, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.tracking_method,
                 nvl(p_asset_fin_rec_old.tracking_method, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.exclude_fully_rsv_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.exclude_fully_rsv_flag,
                 nvl(p_asset_fin_rec_old.exclude_fully_rsv_flag, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.excess_allocation_option, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.excess_allocation_option,
                 nvl(p_asset_fin_rec_old.excess_allocation_option, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.depreciation_option, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.depreciation_option,
                 nvl(p_asset_fin_rec_old.depreciation_option, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.member_rollup_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.member_rollup_flag,
                 nvl(p_asset_fin_rec_old.member_rollup_flag, FND_API.G_MISS_CHAR)) and
          nvl(p_asset_fin_rec_old.allocate_to_fully_rsv_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.allocate_to_fully_rsv_flag,
                 nvl(p_asset_fin_rec_old.allocate_to_fully_rsv_flag, FND_API.G_MISS_CHAR)) and
          /* HH group ed */
          nvl(p_asset_fin_rec_old.disabled_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.disabled_flag,
                 nvl(p_asset_fin_rec_old.disabled_flag, FND_API.G_MISS_CHAR)) and /* end HH */
          nvl(p_asset_fin_rec_old.allocate_to_fully_ret_flag, FND_API.G_MISS_CHAR) =
             nvl(p_asset_fin_rec_adj.allocate_to_fully_ret_flag,
                 nvl(p_asset_fin_rec_old.allocate_to_fully_ret_flag, FND_API.G_MISS_CHAR)) then

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('l_calling_fn', 'Do not need to set it to true again', 'TRUE', p_log_level_rec => p_log_level_rec);
          end if;

      else
         l_no_changes_made := FALSE;
      end if;
      l_no_changes_to_group := TRUE;
   else
      if  nvl(p_asset_fin_rec_old.group_asset_id, FND_API.G_MISS_NUM) =
             nvl(p_asset_fin_rec_adj.group_asset_id,
                 nvl(p_asset_fin_rec_old.group_asset_id, FND_API.G_MISS_NUM)) then
         l_no_changes_to_group := TRUE;
      else
         l_no_changes_to_group := FALSE;
      end if;
   end if;

   if  nvl(p_asset_fin_rec_adj.reduction_rate, 0) = 0 and
       nvl(p_asset_fin_rec_old.reduce_addition_flag, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.reduce_addition_flag,
              nvl(p_asset_fin_rec_old.reduce_addition_flag, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.reduce_adjustment_flag, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.reduce_adjustment_flag,
              nvl(p_asset_fin_rec_old.reduce_adjustment_flag, FND_API.G_MISS_CHAR)) and
       nvl(p_asset_fin_rec_old.reduce_retirement_flag, FND_API.G_MISS_CHAR) =
          nvl(p_asset_fin_rec_adj.reduce_retirement_flag,
              nvl(p_asset_fin_rec_old.reduce_retirement_flag, FND_API.G_MISS_CHAR)) then
      l_no_changes_to_reduction := TRUE;
   else
      l_no_changes_to_reduction := FALSE;
   end if;

   if (l_no_changes_made) then
      if (l_no_changes_to_uom) then
         if (l_no_changes_to_group) and (l_no_changes_to_reduction) and (l_no_changes_to_method) then
            if (l_no_changes_to_dep_flag) and (l_no_changes_to_impairment) then
               fa_srvr_msg.add_message(
                   calling_fn => l_calling_fn,
                   name       => 'FA_SHARED_NO_CHANGES_TO_COMMIT', p_log_level_rec => p_log_level_rec);
               return FALSE;

               -- old code would handle adj_req_status here as an else stmt
               -- we're doing it in calc engine
            end if;
         end if;
      end if;

      if (not l_no_changes_to_group) and ((not l_no_changes_to_method) and
         (nvl(p_asset_fin_rec_adj.depreciation_option,
              nvl(p_asset_fin_rec_old.depreciation_option, 'NULL')) <> 'GROUP')) then

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add('l_calling_fn', 'No method change if depreciation_option <> ', 'GROUP', p_log_level_rec => p_log_level_rec);
         end if;

         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_BK_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if (not l_no_changes_to_dep_flag) and
         ((not l_no_changes_to_reduction) or
          (not l_no_changes_to_group) or
          (not l_no_changes_to_impairment) or
          (not l_no_changes_to_method)) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_BK_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if (not l_no_changes_to_impairment) and
         ((not l_no_changes_to_reduction) or
          (not l_no_changes_to_group) or
          (not l_no_changes_made) or
          (not l_no_changes_to_method)) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_BK_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

   else

      if (not l_no_changes_to_dep_flag) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_BK_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if (not l_no_changes_to_impairment) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_BK_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if (not l_no_changes_to_group) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_BK_NO_MULTIPLE_CHANGES', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

   end if;

end if;

IF not FA_ASSET_VAL_PVT.validate_energy_transactions (
 	       p_trans_rec            => p_trans_rec,
 	       p_asset_type_rec       => p_asset_type_rec,
 	       p_asset_fin_rec_old    => p_asset_fin_rec_old,
 	       p_asset_fin_rec_adj    => p_asset_fin_rec_adj,
 	       p_asset_hdr_rec        => p_asset_hdr_rec ,
 	       p_log_level_rec        => p_log_level_rec) then

   return FALSE;
END IF;


   return true;

END validate_adjustment;


END FA_ADJUSTMENT_PVT;

/
