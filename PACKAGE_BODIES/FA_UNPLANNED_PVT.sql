--------------------------------------------------------
--  DDL for Package Body FA_UNPLANNED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UNPLANNED_PVT" as
/* $Header: FAVUNPLB.pls 120.22.12010000.3 2009/07/19 14:31:26 glchen ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION do_unplanned
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec           IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec         IN     FA_API_TYPES.asset_deprn_rec_type,
    p_unplanned_deprn_rec     IN     FA_API_TYPES.unplanned_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   -- used for method cache
   l_deprn_basis_rule          VARCHAR2(4);
   l_rate_source_rule          VARCHAR2(10);

   --  used for mrc
   l_debit_credit_flag         VARCHAR2(2);
   l_unplanned_amount          NUMBER;
   l_amount_inserted           NUMBER;

   --
   -- For calling faxama.
   --
   l_deprn_exp           NUMBER := 0;
   l_bonus_deprn_exp     NUMBER := 0;
   l_impairment_exp      NUMBER := 0;
   l_deprn_rsv           NUMBER := 0;
   l_asset_deprn_rec_adj FA_API_TYPES.ASSET_DEPRN_REC_TYPE;
   l_asset_deprn_rec_new FA_API_TYPES.ASSET_DEPRN_REC_TYPE;

   l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;
   l_temp_raf            NUMBER;

   l_status                    boolean;
   l_rowid                     rowid;

   l_transaction_subtype       VARCHAR2(9);
   l_transaction_key           VARCHAR2(2);
   l_rounding_flag             VARCHAR2(3);

   l_adj                       fa_adjust_type_pkg.fa_adj_row_struct;

   -- used for return values
   l_asset_fin_rec             FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_null        FA_API_TYPES.asset_fin_rec_type;

   deprn_override_flag_default varchar2(1);

   l_calling_fn                VARCHAR2(35) := 'fa_unplanned_pvt.do_unplanned';
   unp_err                     EXCEPTION;

   -- Bug:5930979:Japan Tax Reform Project
   l_method_type               number := 0;
   l_success                   integer;
   l_rate_in_use               number;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   l_asset_fin_rec          := p_asset_fin_rec;

   l_unplanned_amount       := p_unplanned_deprn_rec.unplanned_amount;

   l_rounding_flag       := 'ADJ';
   l_transaction_key     := px_trans_rec.transaction_key;
   l_transaction_subtype := p_unplanned_deprn_rec.unplanned_type;

   deprn_override_flag_default:= fa_std_types.FA_NO_OVERRIDE;

   if not FA_CACHE_PKG.fazccmt(p_asset_fin_rec.deprn_method_code,
                               p_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec) then
      raise unp_err;
   end if;


   -- check that method is valid for unplanned - only need to due this for primary

   if (p_mrc_sob_type_code <> 'R') then

      l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
      l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

      if (l_rate_source_rule    = 'TABLE' or
          (l_deprn_basis_rule   = 'NBV' and
           l_rate_source_rule  <> 'FLAT')) and
         (not (l_deprn_basis_rule = 'NBV' and
               l_rate_source_rule = 'PRODUCTION' and
               fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE')) then

            -- Bug:5930979:Japan Tax Reform Project
			if not (l_rate_source_rule  = 'FORMULA') then
			   fa_srvr_msg.add_message
                  (name       => '*** unplanned not allowed ***',
                   calling_fn => l_calling_fn,
                   p_log_level_rec => p_log_level_rec);
               raise unp_err;
            end if;
	  end if;


      -- verify amount is less then recoverable cost or reserve

      -- Fix for bug #2897597.  If group asset has over depreciate
      -- option as YES or DEPRN, then allow the unplanned amount to be
      -- greater than the nbv

      -- BUG# 2898745
      -- nesting the comparison with reserve back under cost > 0
      -- also adding checks to prevent negative cost assets
      -- from over depreciating (previously, no restrictions existed)

      if (p_asset_fin_rec.cost > 0) then
         if (p_unplanned_deprn_rec.unplanned_amount > 0) then
            if (p_unplanned_deprn_rec.unplanned_amount >
                (p_asset_fin_rec.cost - p_asset_deprn_rec.deprn_reserve) and
                (nvl(p_asset_fin_rec.over_depreciate_option, 'NO') not in
                 ('YES', 'DEPRN'))) then

                fa_srvr_msg.add_message
                    (name       => 'FA_UNP_DEP_AMT_1',
                     calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise unp_err;
            end if;
         elsif (p_unplanned_deprn_rec.unplanned_amount < 0) and
               (p_asset_type_rec.asset_type <> 'GROUP') then
            if ((-1) * (p_unplanned_deprn_rec.unplanned_amount)  > p_asset_deprn_rec.deprn_reserve) then

                fa_srvr_msg.add_message
                   (name       => 'FA_UNP_DEP_AMT_2',
                    calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               raise unp_err;
            end if;
         end if;
      elsif (p_asset_fin_rec.cost < 0) then
         if (p_unplanned_deprn_rec.unplanned_amount < 0) then
            if (p_unplanned_deprn_rec.unplanned_amount <
                (p_asset_fin_rec.cost - p_asset_deprn_rec.deprn_reserve) and
                (nvl(p_asset_fin_rec.over_depreciate_option, 'NO') not in
                 ('YES', 'DEPRN'))) then

                fa_srvr_msg.add_message
                    (name       => 'FA_UNP_DEP_AMT_1',
                     calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise unp_err;
            end if;
         elsif (p_unplanned_deprn_rec.unplanned_amount > 0) and
               (p_asset_type_rec.asset_type <> 'GROUP') then
            if (p_unplanned_deprn_rec.unplanned_amount > (-1 * p_asset_deprn_rec.deprn_reserve)) then

                fa_srvr_msg.add_message
                   (name       => 'FA_UNP_DEP_AMT_2',
                    calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               raise unp_err;
            end if;
         end if;

      end if; --(p_asset_fin_rec.cost > 0)

      -- void original addition row in period of addition
      if (p_asset_hdr_rec.period_of_addition = 'Y' and
          G_release = 11) then
          FA_TRANSACTION_HEADERS_PKG.Update_Trx_Type
             (X_Book_Type_Code                => p_asset_hdr_rec.book_type_code,
              X_Asset_Id                      => p_asset_hdr_rec.asset_id,
              X_Transaction_Type_Code         => px_trans_rec.transaction_type_code,
              X_New_Transaction_Type          => px_trans_rec.transaction_type_code || '/VOID',
              X_Return_Status                 => l_status,
              X_Calling_Fn                    => l_calling_fn
             , p_log_level_rec => p_log_level_rec);
      end if;

      if not l_status then
         raise unp_err;
      end if;

      select fa_transaction_headers_s.nextval
        into px_trans_rec.transaction_header_id
        from dual;

      -- SLA UPTAKE
      -- assign an event for the transaction
      -- at this point key info asset/book/trx info is known from initialize
      -- call and the above code (i.e. trx_type, etc)

      if not fa_xla_events_pvt.create_transaction_event
               (p_asset_hdr_rec => p_asset_hdr_rec,
                p_asset_type_rec=> p_asset_type_rec,
                px_trans_rec    => px_trans_rec,
                p_event_status  => NULL,
                p_calling_fn    => l_calling_fn
                ,p_log_level_rec => p_log_level_rec) then
         raise unp_err;
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
                       X_Invoice_Transaction_Id         => NULL,
                       X_Source_Transaction_Header_Id   => px_trans_rec.source_transaction_header_id,
                       X_Mass_Reference_Id              => px_trans_rec.mass_reference_id,
                       X_Last_Update_Login              => px_trans_rec.who_info.last_update_login,
                       X_Transaction_Subtype            => l_transaction_subtype,
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
                       X_Transaction_Key                => l_transaction_key,
                       X_Amortization_Start_Date        => NULL,
                       X_Calling_Interface              => px_trans_rec.calling_interface,
                       X_Mass_Transaction_ID            => px_trans_rec.mass_transaction_id,
                       X_member_transaction_header_id   => px_trans_rec.member_transaction_header_id,
                       X_event_id                       => px_trans_rec.event_id,
                       X_Return_Status                  => l_status,
                       X_Calling_Fn                     => l_calling_fn
                      , p_log_level_rec => p_log_level_rec);

      if not l_status then
         raise unp_err;
      end if;

   end if;  -- primary book

   -- Bug:4944700 (Moved from ALLOCATE IF)
   -- round the amount to correct precision and use correct sign
   if not FA_UTILS_PKG.faxrnd
             (X_amount => l_unplanned_amount,
              X_book   => p_asset_hdr_rec.book_type_code,
              X_set_of_books_id => p_asset_hdr_rec.set_of_books_id,
              p_log_level_rec => p_log_level_rec) then
      raise unp_err;
   end if;


   -- If the processed asset is the member asset whose tracking method is 'ALLOCATE',
   -- system should not process the amortization for the member level.

   -- Bug 5695201 Allowing for Allocate also.

   if (l_asset_fin_rec.group_asset_id is null) or
      (l_asset_fin_rec.group_asset_id is not null and
       nvl(l_asset_fin_rec.tracking_method,'OTHER') <> 'OTHER') then

     -- Bug:4944700
     l_asset_deprn_rec_adj.deprn_amount := p_unplanned_deprn_rec.unplanned_amount;


     if (px_trans_rec.transaction_subtype = 'AMORTIZED') then

	if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_AMORT_PVT.calc_raf_adj_cost', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'before adj cap', l_asset_fin_rec.adjusted_capacity, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'before adj rsv old', p_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
        end if;

        -- Bug:4944700 (removed the faxama call)
	if not FA_AMORT_PVT.calc_raf_adj_cost
                    (p_trans_rec           => px_trans_rec,
                     p_asset_hdr_rec       => p_asset_hdr_rec,
                     p_asset_desc_rec      => p_asset_desc_rec,
                     p_asset_type_rec      => p_asset_type_rec,
                     p_asset_fin_rec_old   => p_asset_fin_rec,
                     px_asset_fin_rec_new  => l_asset_fin_rec,
                     p_asset_deprn_rec_adj => l_asset_deprn_rec_adj,
                     p_asset_deprn_rec_new => p_asset_deprn_rec, -- Bug:4944700
                     p_period_rec          => p_period_rec,
                     p_group_reclass_options_rec => l_group_reclass_options_rec,
                     p_mrc_sob_type_code   => p_mrc_sob_type_code
                     , p_log_level_rec => p_log_level_rec) then
           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'Failed calling', 'FA_AMORT_PVT.calc_raf_adj_cost', p_log_level_rec => p_log_level_rec);
           end if;

           raise unp_err;
        end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'after adj cap', l_asset_fin_rec.adjusted_capacity, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'End Calling', 'FA_AMORT_PVT.calc_raf_adj_cost', p_log_level_rec => p_log_level_rec);
        end if;

        -- no need to insert any catchup as we're already inserting
        -- the value provided... so skipping call to faxiat

     end if;  -- end amortize

     l_asset_fin_rec.adjustment_required_status := 'NONE';

     l_temp_raf := l_asset_fin_rec.rate_adjustment_factor;

     ----------------------------------------------
     -- Call Depreciable Basis Rule
     -- for Unplanned Depreciation
     ----------------------------------------------
     if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                  (
                   p_event_type             => 'UNPLANNED_ADJ',
                   p_asset_fin_rec_new      => p_asset_fin_rec,
                   p_asset_fin_rec_old      => p_asset_fin_rec,
                   p_asset_hdr_rec          => p_asset_hdr_rec,
                   p_asset_type_rec         => p_asset_type_rec,
                   p_asset_deprn_rec        => p_asset_deprn_rec,
		   p_trans_rec              => px_trans_rec,
                   p_period_rec             => p_period_rec,
                   p_unplanned_deprn_rec    => p_unplanned_deprn_rec,
                   p_mrc_sob_type_code      => p_mrc_sob_type_code,
                   px_new_adjusted_cost     => l_asset_fin_rec.adjusted_cost,
                   px_new_raf               => l_asset_fin_rec.rate_adjustment_factor,
                   px_new_formula_factor    => l_asset_fin_rec.formula_factor
                  , p_log_level_rec => p_log_level_rec
                   )
            )
        then
        raise unp_err;
     end if;

     -- Deprn basis function has been called in calc_raf_adj above so
     -- do not call deprn basis function if it's been called
     -- In Addition to the above case,
     -- ENERGY
     -- Replace raf with the raf returned by faxama call.
     -- If this asset is:
     --  1. Member of Energy Straight line group
     --  2. tracking method is calculate
     --  This is because raf is set in previous faxama call.
     --  Also, above depreciable basis call was made without hypo amounts that
     --  is mandatory for raf calculation.
     if ((l_asset_fin_rec.group_asset_id is null and
          px_trans_rec.transaction_subtype = 'AMORTIZED' and
          p_asset_type_rec.asset_type = 'GROUP'))
            or
        ((p_asset_type_rec.asset_type <> 'GROUP') and
         (l_asset_fin_rec.group_asset_id is not null) and
         (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and
         (nvl(l_asset_fin_rec.tracking_method, 'NO TRACK') = 'CALCULATE')) then

        l_asset_fin_rec.rate_adjustment_factor := l_temp_raf;

     end if;

     if (l_unplanned_amount <> 0) then
        l_asset_fin_rec.period_counter_fully_reserved := NULL;
     end if;

     l_asset_fin_rec.period_counter_life_complete := l_asset_fin_rec.period_counter_fully_reserved;

     -- terminate the row
     fa_books_pkg.deactivate_row
        (X_asset_id                  => p_asset_hdr_rec.asset_id,
         X_book_type_code            => p_asset_hdr_rec.book_type_code,
         X_transaction_header_id_out => px_trans_rec.transaction_header_id,
         X_date_ineffective          => px_trans_rec.who_info.last_update_date,
         X_mrc_sob_type_code         => p_mrc_sob_type_code,
         X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
         X_Calling_Fn                => l_calling_fn
         , p_log_level_rec => p_log_level_rec);

     l_rowid := null;

     -- ENERGY
     -- This is not only change for energy.  Allocation of unplanned amount must be done in
     -- process group adjustment in case of large number of member assets exist for a group.
     -- A condition refering 'ENERGY PERIOD END BALANCE' can be removed from rel 12.
     if (px_trans_rec.calling_interface = 'FAXASSET') and
        (l_asset_fin_rec.group_asset_id is null and
         nvl(l_asset_fin_rec.tracking_method, 'NO TRACK') = 'ALLOCATE')
        and (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE')
        then
        l_asset_fin_rec.adjustment_required_status := 'GADJ';

        if (p_mrc_sob_type_code <> 'R') then
           if not fa_xla_events_pvt.update_transaction_event
               (p_ledger_id              => p_asset_hdr_rec.set_of_books_id,
                p_transaction_header_id  => px_trans_rec.transaction_header_id,
                p_book_type_code         => p_asset_hdr_rec.book_type_code,
                p_event_type_code        => 'UNPLANNED_DEPRECIATION',
                p_event_date             => px_trans_rec.transaction_date_entered, --?
                p_event_status_code      => fa_xla_events_pvt.C_EVENT_INCOMPLETE,
                p_calling_fn             => l_calling_fn,
                p_log_level_rec          => p_log_level_rec) then
              raise unp_err;
           end if;
        end if;
     end if;


     -- insert the row
     fa_books_pkg.insert_row
         (X_Rowid                        => l_rowid,
          X_Book_Type_Code               => p_asset_hdr_rec.book_type_code,
          X_Asset_Id                     => p_asset_hdr_rec.asset_id,
          X_Date_Placed_In_Service       => l_asset_fin_rec.date_placed_in_service,
          X_Date_Effective               => px_trans_rec.who_info.last_update_date,
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
          X_Last_Update_Date             => px_trans_rec.who_info.last_update_date,
          X_Last_Updated_By              => px_trans_rec.who_info.last_updated_by,
          X_Date_Ineffective             => NULL,
          X_Transaction_Header_Id_In     => px_trans_rec.transaction_header_id,
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
          X_Last_Update_Login            => px_trans_rec.who_info.last_update_login,
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
          X_Annual_Deprn_Rounding_Flag   => l_rounding_flag,
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
          X_terminal_gain_loss_amount    => l_asset_fin_rec.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => l_asset_fin_rec.ltd_cost_of_removal,
          X_cash_generating_unit_id      =>
                                       l_asset_fin_rec.cash_generating_unit_id,
          X_extended_deprn_flag          => l_asset_fin_rec.extended_deprn_flag, -- Bug:5930979:Japan Tax Reform Project - Phase 3
          X_extended_depreciation_period => l_asset_fin_rec.extended_depreciation_period, -- Bug:5930979:Japan Tax Reform Project - Phase 3
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
          X_Return_Status                => l_status,
          X_Calling_Fn                   => l_calling_fn
          , p_log_level_rec => p_log_level_rec);

     if not l_status then
       raise unp_err;
     end if;

     -- Bug:5930979:Japan Tax Reform Project
     if fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag = 'YES' then
        if (p_mrc_sob_type_code <> 'R') then
           FA_CDE_PKG.faxgfr (X_Book_Type_Code         => p_asset_hdr_rec.book_type_code,
                              X_Asset_Id               => p_asset_hdr_rec.asset_id,
                              X_Short_Fiscal_Year_Flag => l_asset_fin_rec.short_fiscal_year_flag,
                              X_Conversion_Date        => l_asset_fin_rec.conversion_date,
                              X_Prorate_Date           => l_asset_fin_rec.prorate_date,
                              X_Orig_Deprn_Start_Date  => l_asset_fin_rec.orig_deprn_start_date,
                              C_Prorate_Date           => NULL,
                              C_Conversion_Date        => NULL,
                              C_Orig_Deprn_Start_Date  => NULL,
                              X_Method_Code            => l_asset_fin_rec.deprn_method_code,
                              X_Life_In_Months         => l_asset_fin_rec.life_in_months,
                              X_Fiscal_Year            => -99,
         	 	              X_Current_Period	        => p_period_rec.period_counter,
			                  X_calling_interface      => 'UNPLANNED',
                              X_Rate                   => l_rate_in_use,
                              X_Method_Type            => l_method_type,
                              X_Success                => l_success, p_log_level_rec => p_log_level_rec);

           if (l_success <= 0) then
              fa_srvr_msg.add_message(calling_fn => 'FA_UNPLANNED_PVT.do_unplanned', p_log_level_rec => p_log_level_rec);
              raise unp_err;
           end if;

           Update FA_BOOKS
           Set rate_in_use = l_rate_in_use
           Where book_type_code = p_asset_hdr_rec.book_type_code
           And asset_id = p_asset_hdr_rec.asset_id
           And date_ineffective is null;
        end if;
     end if;

     -- Bug 7229863: Removed period of addition specific code while performing unplanned
     /*if (p_asset_hdr_rec.period_of_addition <> 'Y')
        or (nvl(fa_cache_pkg.fazcdrd_record.rule_name, 'NULL') = 'ENERGY PERIOD END BALANCE')
	or ((p_asset_hdr_rec.period_of_addition = 'Y') and
	    (l_asset_fin_rec.date_placed_in_service >= p_period_rec.fy_start_date and
             l_asset_fin_rec.date_placed_in_service <= p_period_rec.fy_end_date))
        then */

     if (l_unplanned_amount > 0) then
        l_debit_credit_flag := 'DR';
        l_unplanned_amount  := l_unplanned_amount;
     else
           l_debit_credit_flag := 'CR';
           l_unplanned_amount  := (-1) * l_unplanned_amount;
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

     l_adj.flush_adj_flag           := TRUE;
     l_adj.gen_ccid_flag            := FALSE;
     l_adj.annualized_adjustment    := 0;
     l_adj.asset_invoice_id         := 0;
     l_adj.code_combination_id      := p_unplanned_deprn_rec.code_combination_id;
     l_adj.distribution_id          := 0;

     l_adj.deprn_override_flag:= '';

     l_adj.source_type_code    := 'DEPRECIATION';
     l_adj.adjustment_type     := 'EXPENSE';
     l_adj.account             := FA_UNPLANNED_PUB.G_expense_account;
     l_adj.account_type        := 'DEPRN_EXPENSE_ACCT';
     l_adj.debit_credit_flag   := l_debit_credit_flag;
     l_adj.adjustment_amount   := l_unplanned_amount;
     l_adj.mrc_sob_type_code   := p_mrc_sob_type_code;
     l_adj.set_of_books_id     := p_asset_hdr_rec.set_of_books_id;

     if (l_asset_fin_rec.group_asset_id is not null) and
        (nvl(l_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
        l_adj.track_member_flag := 'Y';
     else
        l_adj.track_member_flag := null;
     end if;

     if not FA_INS_ADJUST_PKG.faxinaj
               (l_adj,
                px_trans_rec.who_info.last_update_date,
                px_trans_rec.who_info.last_updated_by,
                px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
          raise unp_err;
     end if;

   end if; -- check if the processed asset is not a member asset with ALLOCATE method

   return true;

EXCEPTION
   when unp_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error
          (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END do_unplanned;

END FA_UNPLANNED_PVT;

/
