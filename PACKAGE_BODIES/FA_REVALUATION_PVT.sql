--------------------------------------------------------
--  DDL for Package Body FA_REVALUATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_REVALUATION_PVT" AS
/* $Header: FAVRVLB.pls 120.7.12010000.2 2009/07/19 11:19:23 glchen ship $   */
   g_old_nbv       NUMBER;
   g_new_nbv       NUMBER;

   FUNCTION do_reval (
      px_trans_rec            IN OUT NOCOPY   fa_api_types.trans_rec_type,
      px_asset_hdr_rec        IN OUT NOCOPY   fa_api_types.asset_hdr_rec_type,
      p_asset_desc_rec        IN              fa_api_types.asset_desc_rec_type,
      p_asset_type_rec        IN              fa_api_types.asset_type_rec_type,
      p_asset_cat_rec         IN              fa_api_types.asset_cat_rec_type,
      p_asset_fin_rec_old     IN              fa_api_types.asset_fin_rec_type,
      p_asset_deprn_rec_old   IN              fa_api_types.asset_deprn_rec_type,
      p_period_rec            IN              fa_api_types.period_rec_type,
      p_mrc_sob_type_code     IN              VARCHAR2,
      p_reval_options_rec     IN              fa_api_types.reval_options_rec_type,
      p_calling_fn            IN              VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
      RETURN BOOLEAN
   IS
      l_th_rowid              VARCHAR2 (30);
      l_bks_rowid             VARCHAR2 (30);
      l_status                BOOLEAN;
      l_asset_fin_rec_new     fa_api_types.asset_fin_rec_type;
      l_asset_deprn_rec_new   fa_api_types.asset_deprn_rec_type;
      l_reval_out_rec         fa_std_types.reval_out_struct;
      -- rx columns
      l_concat_cat            VARCHAR2 (220);
      l_cat_segs              fa_rx_shared_pkg.seg_array;
      l_override_defaults     VARCHAR2 (80);
      l_reval_fully_rsvd      VARCHAR2 (80);
      l_revalue_cip_assets    VARCHAR2 (80);

      CURSOR yes_no_meaning (p_lookup_code VARCHAR2)
      IS
         SELECT NVL (meaning, p_lookup_code)
           FROM fa_lookups
          WHERE lookup_code = p_lookup_code AND lookup_type = 'YESNO';

      l_calling_fn            VARCHAR2 (35)        := 'fa_reval_pvt.do_reval';
      reval_err               EXCEPTION;

      -- Bug7719742
      l_method_type                  NUMBER := 0;
      l_success                      INTEGER;
      l_rate_in_use                  NUMBER;
   BEGIN
      --set up transaction types for adjustments vs. addition voids
      -- reval is currently not allowed in period of addition
      px_trans_rec.transaction_type_code := 'REVALUATION';

      IF (p_reval_options_rec.run_mode = 'RUN')
      THEN
         -- insert transaction headers
         IF (p_mrc_sob_type_code <> 'R')
         THEN
            -- we need the thid first before reval engine or do we
            SELECT fa_transaction_headers_s.NEXTVAL
              INTO px_trans_rec.transaction_header_id
              FROM DUAL;
         END IF;
      END IF;

      -- load the structs needed by reval engine
      -- this may come later inside fareven, thus passing the
      -- common api structs to that routine

      -- copy current old recs to new and reval engine will overlay them
      -- with the new values where appropriate
      l_asset_fin_rec_new := p_asset_fin_rec_old;
      l_asset_deprn_rec_new := p_asset_deprn_rec_old;

      -- call the revaluation engine
      IF NOT fareven (px_trans_rec                => px_trans_rec,
                      p_asset_hdr_rec             => px_asset_hdr_rec,
                      p_asset_desc_rec            => p_asset_desc_rec,
                      p_asset_type_rec            => p_asset_type_rec,
                      p_asset_cat_rec             => p_asset_cat_rec,
                      p_asset_fin_rec_old         => p_asset_fin_rec_old,
                      px_asset_fin_rec_new        => l_asset_fin_rec_new,
                      p_asset_deprn_rec_old       => p_asset_deprn_rec_old,
                      px_asset_deprn_rec_new      => l_asset_deprn_rec_new,
                      p_period_rec                => p_period_rec,
                      p_mrc_sob_type_code         => p_mrc_sob_type_code,
                      p_reval_options_rec         => p_reval_options_rec,
                      x_reval_out                 => l_reval_out_rec,
                      p_log_level_rec             => p_log_level_rec
                     )
      THEN
         RAISE reval_err;
      END IF;

      /* Bug 7488356 - Begin
      The following logic is added only for SORP.
      When the Impairment is followed by Revaluation,
      This particular flag should be set to 'NONE' such that catchup wont be calculated*/
      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
      THEN
         IF (l_asset_fin_rec_new.adjustment_required_status = 'ADD')
   THEN
       l_asset_fin_rec_new.adjustment_required_status := 'NONE';
  END IF;
      END IF;
      /* Bug 7488356 - End*/

      IF (p_log_level_rec.statement_level)
      THEN
         fa_debug_pkg.ADD (l_calling_fn,
                           'after call to fareven run_mode',
                           p_reval_options_rec.run_mode
                          , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,
                           'after call to fareven insert_txn_flag',
                           l_reval_out_rec.insert_txn_flag
                          , p_log_level_rec => p_log_level_rec);
      END IF;

      -- if run_mode = RUN, then call the table handlers to process
      -- the revaluation else insert into the temp table for preview report
      IF (    p_reval_options_rec.run_mode = 'RUN'
          AND l_reval_out_rec.insert_txn_flag
         )
      THEN
         -- insert transaction headers
         IF (p_mrc_sob_type_code <> 'R')
         THEN
            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD (l_calling_fn,
                                 'trx_date before insert',
                                 px_trans_rec.transaction_date_entered
                                , p_log_level_rec => p_log_level_rec);
            END IF;

         -- SLA UPTAKE
         -- assign an event for the transaction
         -- at this point key info asset/book/trx info is known from above code
         --   *** but trx_date_entered may not be correct! - revisit ***

         if not fa_xla_events_pvt.create_transaction_event
              (p_asset_hdr_rec => px_asset_hdr_rec,
               p_asset_type_rec=> p_asset_type_rec,
               px_trans_rec    => px_trans_rec,
               p_event_status  => NULL,
               p_calling_fn    => l_calling_fn
               ,p_log_level_rec => p_log_level_rec) then
            raise reval_err;
         end if;


            fa_transaction_headers_pkg.insert_row
               (x_rowid                             => l_th_rowid,
                x_transaction_header_id             => px_trans_rec.transaction_header_id,
                x_book_type_code                    => px_asset_hdr_rec.book_type_code,
                x_asset_id                          => px_asset_hdr_rec.asset_id,
                x_transaction_type_code             => px_trans_rec.transaction_type_code,
                x_transaction_date_entered          => px_trans_rec.transaction_date_entered,
                x_date_effective                    => px_trans_rec.who_info.creation_date,
                x_last_update_date                  => px_trans_rec.who_info.last_update_date,
                x_last_updated_by                   => px_trans_rec.who_info.last_updated_by,
                x_transaction_name                  => px_trans_rec.transaction_name,
                x_invoice_transaction_id            => NULL,
                x_source_transaction_header_id      => px_trans_rec.source_transaction_header_id,
                x_mass_reference_id                 => px_trans_rec.mass_reference_id,
                x_last_update_login                 => px_trans_rec.who_info.last_update_login,
                x_transaction_subtype               => px_trans_rec.transaction_subtype,
                x_attribute1                        => px_trans_rec.desc_flex.attribute1,
                x_attribute2                        => px_trans_rec.desc_flex.attribute2,
                x_attribute3                        => px_trans_rec.desc_flex.attribute3,
                x_attribute4                        => px_trans_rec.desc_flex.attribute4,
                x_attribute5                        => px_trans_rec.desc_flex.attribute5,
                x_attribute6                        => px_trans_rec.desc_flex.attribute6,
                x_attribute7                        => px_trans_rec.desc_flex.attribute7,
                x_attribute8                        => px_trans_rec.desc_flex.attribute8,
                x_attribute9                        => px_trans_rec.desc_flex.attribute9,
                x_attribute10                       => px_trans_rec.desc_flex.attribute10,
                x_attribute11                       => px_trans_rec.desc_flex.attribute11,
                x_attribute12                       => px_trans_rec.desc_flex.attribute12,
                x_attribute13                       => px_trans_rec.desc_flex.attribute13,
                x_attribute14                       => px_trans_rec.desc_flex.attribute14,
                x_attribute15                       => px_trans_rec.desc_flex.attribute15,
                x_attribute_category_code           => px_trans_rec.desc_flex.attribute_category_code,
                x_transaction_key                   => px_trans_rec.transaction_key,
                x_amortization_start_date           => px_trans_rec.amortization_start_date,
                x_calling_interface                 => px_trans_rec.calling_interface,
                x_mass_transaction_id               => px_trans_rec.mass_transaction_id,
                x_member_transaction_header_id      => px_trans_rec.member_transaction_header_id,
                x_trx_reference_id                  => px_trans_rec.trx_reference_id,
                x_event_id                          => px_trans_rec.event_id,
                x_return_status                     => l_status,
                x_calling_fn                        => l_calling_fn
               , p_log_level_rec => p_log_level_rec);

            IF NOT l_status
            THEN
               RAISE reval_err;
            END IF;
         END IF;                                        -- primary / reporting

         -- terminate the active row
         fa_books_pkg.deactivate_row
            (x_asset_id                       => px_asset_hdr_rec.asset_id,
             x_book_type_code                 => px_asset_hdr_rec.book_type_code,
             x_transaction_header_id_out      => px_trans_rec.transaction_header_id,
             x_date_ineffective               => px_trans_rec.who_info.last_update_date,
             x_mrc_sob_type_code              => p_mrc_sob_type_code,
             x_set_of_books_id                => px_asset_hdr_rec.set_of_books_id,
             x_calling_fn                     => l_calling_fn
            , p_log_level_rec => p_log_level_rec);

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD (l_calling_fn,
                              'after fa_books_pkg.deactivate_row',
                              1
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         -- fa books
         fa_books_pkg.insert_row
            (x_rowid                             => l_bks_rowid,
             x_book_type_code                    => px_asset_hdr_rec.book_type_code,
             x_asset_id                          => px_asset_hdr_rec.asset_id,
             x_date_placed_in_service            => l_asset_fin_rec_new.date_placed_in_service,
             x_date_effective                    => px_trans_rec.who_info.last_update_date,
             x_deprn_start_date                  => l_asset_fin_rec_new.deprn_start_date,
             x_deprn_method_code                 => l_asset_fin_rec_new.deprn_method_code,
             x_life_in_months                    => l_asset_fin_rec_new.life_in_months,
             x_rate_adjustment_factor            => l_asset_fin_rec_new.rate_adjustment_factor,
             x_adjusted_cost                     => l_asset_fin_rec_new.adjusted_cost,
             x_cost                              => l_asset_fin_rec_new.COST,
             x_original_cost                     => l_asset_fin_rec_new.original_cost,
             x_salvage_value                     => l_asset_fin_rec_new.salvage_value,
             x_prorate_convention_code           => l_asset_fin_rec_new.prorate_convention_code,
             x_prorate_date                      => l_asset_fin_rec_new.prorate_date,
             x_cost_change_flag                  => l_asset_fin_rec_new.cost_change_flag,
             x_adjustment_required_status        => l_asset_fin_rec_new.adjustment_required_status,
             x_capitalize_flag                   => l_asset_fin_rec_new.capitalize_flag,
             x_retirement_pending_flag           => l_asset_fin_rec_new.retirement_pending_flag,
             x_depreciate_flag                   => l_asset_fin_rec_new.depreciate_flag,
             x_disabled_flag                     => l_asset_fin_rec_new.disabled_flag,
             --HH
             x_last_update_date                  => px_trans_rec.who_info.last_update_date,
             x_last_updated_by                   => px_trans_rec.who_info.last_updated_by,
             x_date_ineffective                  => NULL,
             x_transaction_header_id_in          => px_trans_rec.transaction_header_id,
             x_transaction_header_id_out         => NULL,
             x_itc_amount_id                     => l_asset_fin_rec_new.itc_amount_id,
             x_itc_amount                        => l_asset_fin_rec_new.itc_amount,
             x_retirement_id                     => l_asset_fin_rec_new.retirement_id,
             x_tax_request_id                    => l_asset_fin_rec_new.tax_request_id,
             x_itc_basis                         => l_asset_fin_rec_new.itc_basis,
             x_basic_rate                        => l_asset_fin_rec_new.basic_rate,
             x_adjusted_rate                     => l_asset_fin_rec_new.adjusted_rate,
             x_bonus_rule                        => l_asset_fin_rec_new.bonus_rule,
             x_ceiling_name                      => l_asset_fin_rec_new.ceiling_name,
             x_recoverable_cost                  => l_asset_fin_rec_new.recoverable_cost,
             x_last_update_login                 => px_trans_rec.who_info.last_update_login,
             x_adjusted_capacity                 => l_asset_fin_rec_new.adjusted_capacity,
             x_fully_rsvd_revals_counter         => l_asset_fin_rec_new.fully_rsvd_revals_counter,
             x_idled_flag                        => l_asset_fin_rec_new.idled_flag,
             x_period_counter_capitalized        => l_asset_fin_rec_new.period_counter_capitalized,
             x_pc_fully_reserved                 => l_asset_fin_rec_new.period_counter_fully_reserved,
             x_period_counter_fully_retired      => l_asset_fin_rec_new.period_counter_fully_retired,
             x_production_capacity               => l_asset_fin_rec_new.production_capacity,
             x_reval_amortization_basis          => l_asset_fin_rec_new.reval_amortization_basis,
             x_reval_ceiling                     => l_asset_fin_rec_new.reval_ceiling,
             x_unit_of_measure                   => l_asset_fin_rec_new.unit_of_measure,
             x_unrevalued_cost                   => l_asset_fin_rec_new.unrevalued_cost,
             x_annual_deprn_rounding_flag        => l_asset_fin_rec_new.annual_deprn_rounding_flag,
             x_percent_salvage_value             => l_asset_fin_rec_new.percent_salvage_value,
             x_allowed_deprn_limit               => l_asset_fin_rec_new.allowed_deprn_limit,
             x_allowed_deprn_limit_amount        => l_asset_fin_rec_new.allowed_deprn_limit_amount,
             x_period_counter_life_complete      => l_asset_fin_rec_new.period_counter_life_complete,
             x_adjusted_recoverable_cost         => l_asset_fin_rec_new.adjusted_recoverable_cost,
             x_short_fiscal_year_flag            => l_asset_fin_rec_new.short_fiscal_year_flag,
             x_conversion_date                   => l_asset_fin_rec_new.conversion_date,
             x_orig_deprn_start_date             => l_asset_fin_rec_new.orig_deprn_start_date,
             x_remaining_life1                   => l_asset_fin_rec_new.remaining_life1,
             x_remaining_life2                   => l_asset_fin_rec_new.remaining_life2,
             x_old_adj_cost                      => l_asset_fin_rec_new.old_adjusted_cost,
             x_formula_factor                    => l_asset_fin_rec_new.formula_factor,
             x_gf_attribute1                     => l_asset_fin_rec_new.global_attribute1,
             x_gf_attribute2                     => l_asset_fin_rec_new.global_attribute2,
             x_gf_attribute3                     => l_asset_fin_rec_new.global_attribute3,
             x_gf_attribute4                     => l_asset_fin_rec_new.global_attribute4,
             x_gf_attribute5                     => l_asset_fin_rec_new.global_attribute5,
             x_gf_attribute6                     => l_asset_fin_rec_new.global_attribute6,
             x_gf_attribute7                     => l_asset_fin_rec_new.global_attribute7,
             x_gf_attribute8                     => l_asset_fin_rec_new.global_attribute8,
             x_gf_attribute9                     => l_asset_fin_rec_new.global_attribute9,
             x_gf_attribute10                    => l_asset_fin_rec_new.global_attribute10,
             x_gf_attribute11                    => l_asset_fin_rec_new.global_attribute11,
             x_gf_attribute12                    => l_asset_fin_rec_new.global_attribute12,
             x_gf_attribute13                    => l_asset_fin_rec_new.global_attribute13,
             x_gf_attribute14                    => l_asset_fin_rec_new.global_attribute14,
             x_gf_attribute15                    => l_asset_fin_rec_new.global_attribute15,
             x_gf_attribute16                    => l_asset_fin_rec_new.global_attribute16,
             x_gf_attribute17                    => l_asset_fin_rec_new.global_attribute17,
             x_gf_attribute18                    => l_asset_fin_rec_new.global_attribute18,
             x_gf_attribute19                    => l_asset_fin_rec_new.global_attribute19,
             x_gf_attribute20                    => l_asset_fin_rec_new.global_attribute20,
             x_global_attribute_category         => l_asset_fin_rec_new.global_attribute_category,
             x_group_asset_id                    => l_asset_fin_rec_new.group_asset_id,
             x_salvage_type                      => l_asset_fin_rec_new.salvage_type,
             x_deprn_limit_type                  => l_asset_fin_rec_new.deprn_limit_type,
             x_over_depreciate_option            => l_asset_fin_rec_new.over_depreciate_option,
             x_super_group_id                    => l_asset_fin_rec_new.super_group_id,
             x_reduction_rate                    => l_asset_fin_rec_new.reduction_rate,
             x_reduce_addition_flag              => l_asset_fin_rec_new.reduce_addition_flag,
             x_reduce_adjustment_flag            => l_asset_fin_rec_new.reduce_adjustment_flag,
             x_reduce_retirement_flag            => l_asset_fin_rec_new.reduce_retirement_flag,
             x_recognize_gain_loss               => l_asset_fin_rec_new.recognize_gain_loss,
             x_recapture_reserve_flag            => l_asset_fin_rec_new.recapture_reserve_flag,
             x_limit_proceeds_flag               => l_asset_fin_rec_new.limit_proceeds_flag,
             x_terminal_gain_loss                => l_asset_fin_rec_new.terminal_gain_loss,
             x_exclude_proceeds_from_basis       => l_asset_fin_rec_new.exclude_proceeds_from_basis,
             x_retirement_deprn_option           => l_asset_fin_rec_new.retirement_deprn_option,
             x_tracking_method                   => l_asset_fin_rec_new.tracking_method,
             x_allocate_to_fully_rsv_flag        => l_asset_fin_rec_new.allocate_to_fully_rsv_flag,
             x_allocate_to_fully_ret_flag        => l_asset_fin_rec_new.allocate_to_fully_ret_flag,
             x_exclude_fully_rsv_flag            => l_asset_fin_rec_new.exclude_fully_rsv_flag,
             x_excess_allocation_option          => l_asset_fin_rec_new.excess_allocation_option,
             x_depreciation_option               => l_asset_fin_rec_new.depreciation_option,
             x_member_rollup_flag                => l_asset_fin_rec_new.member_rollup_flag,
             x_ytd_proceeds                      => l_asset_fin_rec_new.ytd_proceeds,
             x_ltd_proceeds                      => l_asset_fin_rec_new.ltd_proceeds,
             x_eofy_reserve                      => l_asset_fin_rec_new.eofy_reserve,
             x_cip_cost                          => l_asset_fin_rec_new.cip_cost,
             x_terminal_gain_loss_amount         => l_asset_fin_rec_new.terminal_gain_loss_amount,
             x_ltd_cost_of_removal               => l_asset_fin_rec_new.ltd_cost_of_removal,
             x_cash_generating_unit_id           => l_asset_fin_rec_new.cash_generating_unit_id,
             x_mrc_sob_type_code                 => p_mrc_sob_type_code,
             x_set_of_books_id                   => px_asset_hdr_rec.set_of_books_id,
             x_return_status                     => l_status,
             x_calling_fn                        => l_calling_fn
            , p_log_level_rec => p_log_level_rec);

         IF NOT l_status
         THEN
            RAISE reval_err;
         END IF;

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD (l_calling_fn, 'after books insert', 1, p_log_level_rec => p_log_level_rec);
         END IF;
         --bug7719742
         --Added the following code to populate the rat_in_use column during revaluation
         if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES' then

                 FA_CDE_PKG.faxgfr (X_Book_Type_Code   => px_asset_hdr_rec.book_type_code,
                                  X_Asset_Id               => px_asset_hdr_rec.asset_id,
                                  X_Short_Fiscal_Year_Flag => NULL,
                                  X_Conversion_Date        => NULL,
                                  X_Prorate_Date           => NULL,
                                  X_Orig_Deprn_Start_Date  => NULL,
                                  C_Prorate_Date           => NULL,
                                  C_Conversion_Date        => NULL,
                                  C_Orig_Deprn_Start_Date  => NULL,
                                  X_Method_Code            => l_asset_fin_rec_new.deprn_method_code,
                                  X_Life_In_Months         => l_asset_fin_rec_new.life_in_months,
                                  X_Fiscal_Year            => -99,
                                  X_Current_Period         => -99,
                                  X_calling_interface      => 'AFTER_REV',
                                  X_Rate                   => l_rate_in_use,
                                  X_Method_Type            => l_method_type,
                                  X_Success                => l_success, p_log_level_rec => p_log_level_rec);

                 if (l_success <= 0) then
                     fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                     raise reval_err;
                 end if;

                 UPDATE FA_BOOKS
                 SET rate_in_use = l_rate_in_use
                 WHERE book_type_code = px_asset_hdr_rec.book_type_code
                 AND asset_id = px_asset_hdr_rec.asset_id
                 AND date_ineffective is null;

         end if;
      ELSIF (p_reval_options_rec.run_mode = 'PREVIEW')
      THEN                                              -- run_mode is preview
         -- insert into temp report table (ITF?)
         -- we could also build an array here and insert in bulk periodically (as we do in faxinaj)

         -- Get the category in concatenated string for the asset's current category.
         IF NOT fa_cache_pkg.fazsys(p_log_level_rec)
         THEN
            RAISE reval_err;
         END IF;

         IF p_log_level_rec.statement_level
         THEN
            fa_debug_pkg.ADD
                          (l_calling_fn,
                           'calling concat_category with cat struct: ',
                           fa_cache_pkg.fazsys_record.category_flex_structure
                          , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD (l_calling_fn,
                              'calling concat_category with cat id: ',
                              p_asset_cat_rec.category_id
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         fa_rx_shared_pkg.concat_category
             (struct_id          => fa_cache_pkg.fazsys_record.category_flex_structure,
              ccid               => p_asset_cat_rec.category_id,
              concat_string      => l_concat_cat,
              segarray           => l_cat_segs);

         -- need to reset the flags to YES/NO here
         IF (NVL (p_reval_options_rec.override_defaults_flag, 'N') = 'Y')
         THEN
            l_override_defaults := 'YES';
         ELSE
            l_override_defaults := 'NO';
         END IF;

         IF (NVL (p_reval_options_rec.reval_fully_rsvd_flag, 'N') = 'Y')
         THEN
            l_reval_fully_rsvd := 'YES';
         ELSE
            l_reval_fully_rsvd := 'NO';
         END IF;

         -- get translated values for YESNO flags
         OPEN yes_no_meaning (l_override_defaults);

         FETCH yes_no_meaning
          INTO l_override_defaults;

         CLOSE yes_no_meaning;

         OPEN yes_no_meaning (l_reval_fully_rsvd);

         FETCH yes_no_meaning
          INTO l_reval_fully_rsvd;

         CLOSE yes_no_meaning;

         IF p_log_level_rec.statement_level
         THEN
            fa_debug_pkg.ADD (l_calling_fn,
                              'inserting into: ',
                              'fa_mass_reval_rep_itf'
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         -- Bug6666666 SORP Added columns OLD_NBV and NEW_NBV
         IF p_log_level_rec.statement_level
         THEN
            fa_debug_pkg.ADD (l_calling_fn || ' SORP', 'OLD_NBV', g_old_nbv, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD (l_calling_fn || ' SORP', 'NEW_NBV', g_new_nbv, p_log_level_rec => p_log_level_rec);
         END IF;

         INSERT INTO fa_mass_reval_rep_itf
                     (request_id,
                      mass_reval_id,
                      book_type_code,
                      transaction_date_entered,
                      asset_id,
                      asset_number,
                      description,
                      asset_type,
                      asset_category_id, CATEGORY,
                      old_life,
                      new_life,
                      old_cost, new_cost,
                      old_deprn_reserve,
                      new_deprn_reserve,
                      old_reval_reserve,
                      new_reval_reserve,
                      reval_ceiling,
                      reval_percent, override_defaults,
                      reval_fully_rsvd,
                      life_extension_factor,
                      life_extension_ceiling,
                      max_fully_rsvd_revals, old_nbv,
                      new_nbv, last_update_date,
                      last_updated_by,
                      created_by,
                      creation_date,
                      last_update_login
                     )
              VALUES (px_trans_rec.mass_reference_id,
                      px_trans_rec.mass_transaction_id,
                      px_asset_hdr_rec.book_type_code,
                      px_trans_rec.transaction_date_entered,
                      px_asset_hdr_rec.asset_id,
                      p_asset_desc_rec.asset_number,
                      p_asset_desc_rec.description,
                      p_asset_type_rec.asset_type,
                      p_asset_cat_rec.category_id, l_concat_cat,
                      p_asset_fin_rec_old.life_in_months,
                      l_asset_fin_rec_new.life_in_months,
                      p_asset_fin_rec_old.COST, l_asset_fin_rec_new.COST,
                      p_asset_deprn_rec_old.deprn_reserve,
                      l_asset_deprn_rec_new.deprn_reserve,
                      p_asset_deprn_rec_old.reval_deprn_reserve,
                      l_asset_deprn_rec_new.reval_deprn_reserve,
                      l_asset_fin_rec_new.reval_ceiling,
                      p_reval_options_rec.reval_percent, l_override_defaults,
                      l_reval_fully_rsvd,
                      p_reval_options_rec.life_extension_factor,
                      p_reval_options_rec.life_extension_ceiling,
                      p_reval_options_rec.max_fully_rsvd_revals, g_old_nbv,
                      g_new_nbv, px_trans_rec.who_info.last_update_date,
                      px_trans_rec.who_info.last_updated_by,
                      px_trans_rec.who_info.last_updated_by,
                      px_trans_rec.who_info.last_update_date,
                      px_trans_rec.who_info.last_update_login
                     );

         IF p_log_level_rec.statement_level
         THEN
            fa_debug_pkg.ADD (l_calling_fn,
                              'after inserting into: ',
                              'fa_mass_reval_rep_itf'
                             , p_log_level_rec => p_log_level_rec);
         END IF;
      END IF;                                                      -- run_mode

      RETURN TRUE;
   EXCEPTION
      WHEN reval_err
      THEN
         fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         RETURN FALSE;
      WHEN OTHERS
      THEN
         fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         RETURN FALSE;
   END do_reval;

-----------------------------------------------------------------------------

   -- this function contains validation for reval on an asset
   FUNCTION validate_reval (
      p_trans_rec             IN   fa_api_types.trans_rec_type,
      p_asset_hdr_rec         IN   fa_api_types.asset_hdr_rec_type,
      p_asset_desc_rec        IN   fa_api_types.asset_desc_rec_type,
      p_asset_type_rec        IN   fa_api_types.asset_type_rec_type,
      p_asset_cat_rec         IN   fa_api_types.asset_cat_rec_type,
      p_asset_fin_rec_old     IN   fa_api_types.asset_fin_rec_type,
      p_asset_deprn_rec_old   IN   fa_api_types.asset_deprn_rec_type,
      p_reval_options_rec     IN   fa_api_types.reval_options_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
      RETURN BOOLEAN
   IS
      l_calling_fn   VARCHAR2 (35) := 'do_adjustment_pvt.validate_adj';
   BEGIN
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         RETURN FALSE;
   END validate_reval;

   FUNCTION fareven (
      px_trans_rec             IN OUT NOCOPY   fa_api_types.trans_rec_type,
      p_asset_hdr_rec          IN              fa_api_types.asset_hdr_rec_type,
      p_asset_desc_rec         IN              fa_api_types.asset_desc_rec_type,
      p_asset_type_rec         IN              fa_api_types.asset_type_rec_type,
      p_asset_cat_rec          IN              fa_api_types.asset_cat_rec_type,
      p_asset_fin_rec_old      IN              fa_api_types.asset_fin_rec_type,
      px_asset_fin_rec_new     IN OUT NOCOPY   fa_api_types.asset_fin_rec_type,
      p_asset_deprn_rec_old    IN              fa_api_types.asset_deprn_rec_type,
      px_asset_deprn_rec_new   IN OUT NOCOPY   fa_api_types.asset_deprn_rec_type,
      p_period_rec             IN              fa_api_types.period_rec_type,
      p_mrc_sob_type_code      IN              VARCHAR2,
      p_reval_options_rec      IN              fa_api_types.reval_options_rec_type,
      x_reval_out              OUT NOCOPY      fa_std_types.reval_out_struct
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
      RETURN BOOLEAN
   IS
      l_asset_fin_rec_adj        fa_api_types.asset_fin_rec_type;
      l_reval_rate               NUMBER;
      l_life_extension_factor    NUMBER;
      l_life_extension_ceiling   NUMBER;
      l_method_id                NUMBER;
      l_depr_last_year_flag      BOOLEAN;
      l_rate_source_rule         VARCHAR2 (25);
      l_deprn_basis_rule         VARCHAR2 (25);
      l_recalc_life              NUMBER;
      l_life_ceiling             NUMBER;
      l_reval_ceiling_flag       BOOLEAN;
      l_fully_rsvd_flag          BOOLEAN;
      l_dpr_in                   fa_std_types.dpr_struct;
      l_dpr_out                  fa_std_types.dpr_out_struct;
      l_dpr_arr                  fa_std_types.dpr_arr_type;
      l_running_mode             NUMBER         := fa_std_types.fa_dpr_normal;
      l_reval_amo_basis          NUMBER;
      l_bonus_deprn_exp          NUMBER;
      l_deprn_exp                NUMBER;
      l_impairment_exp           NUMBER;
      l_salvage_value            NUMBER;
      l_adj_in                   fa_adjust_type_pkg.fa_adj_row_struct;
      l_cost_acct                VARCHAR2 (25);
      l_cip_cost_acct            VARCHAR2 (25);
      l_reval_rsv_acct           VARCHAR2 (25);
      l_deprn_rsv_acct           VARCHAR2 (25);
      l_deprn_exp_acct           VARCHAR2 (25);
      -- GBertot: enabled revaluation of YTD deprn.
      l_ytd_deprn_acct           VARCHAR2 (25);
      -- Bonus Deprn YYOON
      l_bonus_deprn_exp_acct     VARCHAR2 (25);
      l_bonus_deprn_rsv_acct     VARCHAR2 (25);
      -- End of Bonus Deprn Change
      l_impairment_exp_acct      VARCHAR2 (25);
      l_impairment_rsv_acct      VARCHAR2 (25);
      l_reval_dep_rsv_flag       VARCHAR2 (5);
      l_amor_reval_rsv_flag      VARCHAR2 (5);
      -- GBertot: enabled revaluation of YTD Deprn.
      l_reval_ytd_deprn_flag     VARCHAR2 (5);
      l_deprn_calendar           VARCHAR2 (30);
      l_fy_name                  VARCHAR2 (30);
      l_last_period_counter      NUMBER;
      l_fy                       NUMBER;
      l_period_num               NUMBER;
      l_polish_rule              NUMBER;
      l_skip_asset               BOOLEAN;
      l_calling_fn               VARCHAR2 (40)
                                              := 'FA_REVALUATION_PVT.fareven';
      fareven_err                EXCEPTION;
      v_imp_effect               NUMBER;
      p_reval_gain               NUMBER;
      p_imp_loss_impact          NUMBER;
      p_impair_loss_acct         NUMBER;
      p_temp_imp_deprn_effect    NUMBER;
      l_sorp_reval_adj           NUMBER;
      p_reval_rsv_deprn_effect   NUMBER;

      l_ind   binary_integer;

   BEGIN
      IF (p_log_level_rec.statement_level)
      THEN
         fa_debug_pkg.ADD ('fareven', 'begin', 1, p_log_level_rec => p_log_level_rec);
      END IF;

      -- validations come here
      IF (p_asset_fin_rec_old.reval_ceiling IS NULL)
      THEN
         l_reval_ceiling_flag := FALSE;
      ELSE
         l_reval_ceiling_flag := TRUE;
      END IF;

      IF (p_reval_options_rec.run_mode = 'RUN')
      THEN
         x_reval_out.insert_txn_flag := TRUE;
      END IF;

      /*Bug8551852# - Made condition common for sorp/non sorp book */
      IF (ABS (p_asset_fin_rec_old.recoverable_cost) <=
                                     (ABS (p_asset_deprn_rec_old.deprn_reserve)+ABS(nvl(p_asset_deprn_rec_old.impairment_reserve,0))))
      THEN
         l_fully_rsvd_flag := TRUE;
      ELSE
         l_fully_rsvd_flag := FALSE;
      END IF;


      IF (    p_asset_fin_rec_old.production_capacity IS NOT NULL
          AND l_fully_rsvd_flag
         )
      THEN
         x_reval_out.insert_txn_flag := FALSE;
         GOTO fareven_exit_noerr;
      END IF;

      IF NOT fa_cache_pkg.fazccmt
                           (x_method      => p_asset_fin_rec_old.deprn_method_code,
                            x_life        => p_asset_fin_rec_old.life_in_months
                           , p_log_level_rec => p_log_level_rec)
      THEN
         RAISE fareven_err;
      END IF;

      IF (    fa_cache_pkg.fazccmt_record.rate_source_rule =
                                                     fa_std_types.fad_rsr_flat
          AND l_fully_rsvd_flag
         )
      THEN
         x_reval_out.insert_txn_flag := FALSE;
         GOTO fareven_exit_noerr;
      END IF;

      IF (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id IS NOT NULL)
      THEN
         l_polish_rule := fa_cache_pkg.fazcdbr_record.polish_rule;
      END IF;

      IF (NVL (l_polish_rule, fa_std_types.fad_dbr_polish_none) IN
             (fa_std_types.fad_dbr_polish_1,
              fa_std_types.fad_dbr_polish_2,
              fa_std_types.fad_dbr_polish_3,
              fa_std_types.fad_dbr_polish_4,
              fa_std_types.fad_dbr_polish_5
             )
         )
      THEN
         x_reval_out.insert_txn_flag := FALSE;
         GOTO fareven_exit_noerr;
      END IF;

      l_reval_dep_rsv_flag :=
                           fa_cache_pkg.fazcbc_record.reval_deprn_reserve_flag;
      l_reval_ytd_deprn_flag :=
                               fa_cache_pkg.fazcbc_record.reval_ytd_deprn_flag;
      l_amor_reval_rsv_flag :=
                        fa_cache_pkg.fazcbc_record.amortize_reval_reserve_flag;
      l_last_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter;
      l_deprn_calendar := fa_cache_pkg.fazcbc_record.deprn_calendar;
      l_fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;

      -- Bug#6666666 SORP Start
      IF (p_log_level_rec.statement_level)  THEN

                      fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'p_asset_fin_rec_old.salvage_value',
                              p_asset_fin_rec_old.salvage_value
                             , p_log_level_rec => p_log_level_rec);

         fa_debug_pkg.ADD ('fareven' || ' SORP',
                           'SORP_Enabled_flag',
                           NVL (fa_cache_pkg.fazcbc_record.sorp_enabled_flag,
                                'N'
                               )
                          );
      END IF;

      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
      THEN
         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'Linked_flag',
                              p_reval_options_rec.linked_flag
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'Value_type',
                              p_reval_options_rec.value_type
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'Value',
                              p_reval_options_rec.reval_percent
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'p_asset_fin_rec_old.recoverable_cost',
                              p_asset_fin_rec_old.recoverable_cost
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'p_asset_deprn_rec_old.deprn_reserve',
                              p_asset_deprn_rec_old.deprn_reserve
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'p_asset_deprn_rec_old.impairment_reserve',
                              NVL (p_asset_deprn_rec_old.impairment_reserve,
                                   0)
                             );
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'RUN_MODE',
                              p_reval_options_rec.run_mode
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         IF p_reval_options_rec.value_type = 'NBV'
         THEN
            x_reval_out.cost_adj :=
                 p_reval_options_rec.reval_percent
               - (  p_asset_fin_rec_old.recoverable_cost
                  - p_asset_deprn_rec_old.deprn_reserve
                                  +NVL(p_asset_fin_rec_old.salvage_value,0)
                  - NVL (p_asset_deprn_rec_old.impairment_reserve, 0)
                 );
            g_old_nbv :=
               (  p_asset_fin_rec_old.recoverable_cost
                - p_asset_deprn_rec_old.deprn_reserve
                                +NVL(p_asset_fin_rec_old.salvage_value,0)
                - NVL (p_asset_deprn_rec_old.impairment_reserve, 0)
               );
            g_new_nbv := p_reval_options_rec.reval_percent;
         ELSIF p_reval_options_rec.value_type = 'AMT'
         THEN
            x_reval_out.cost_adj := p_reval_options_rec.reval_percent;
            g_old_nbv :=
               (  p_asset_fin_rec_old.recoverable_cost
                - p_asset_deprn_rec_old.deprn_reserve
                                +NVL(p_asset_fin_rec_old.salvage_value,0)
                - NVL (p_asset_deprn_rec_old.impairment_reserve, 0)
               );
            g_new_nbv := g_old_nbv + p_reval_options_rec.reval_percent;
         ELSIF p_reval_options_rec.value_type = 'PER'
         THEN
            l_reval_rate := p_reval_options_rec.reval_percent / 100;


               IF (p_log_level_rec.statement_level)
               THEN
                  fa_debug_pkg.ADD ('fareven' || ' SORP',
                                    'PERIOD_COUNTER_FULLY_RESERVED',
                                    'NULL'
                                   , p_log_level_rec => p_log_level_rec);
               END IF;

               IF (l_reval_ceiling_flag)
               THEN
                  IF (p_log_level_rec.statement_level)
                  THEN
                     fa_debug_pkg.ADD ('fareven' || ' SORP',
                                       'l_reval_ceiling_flag',
                                       'TRUE'
                                      , p_log_level_rec => p_log_level_rec);
                  END IF;

                  IF ((  (  p_asset_fin_rec_old.recoverable_cost
                          - p_asset_deprn_rec_old.deprn_reserve
                         )
                       * (1 + l_reval_rate)
                      ) > p_asset_fin_rec_old.reval_ceiling
                     )
                  THEN
                     l_reval_rate :=
                          (  p_asset_fin_rec_old.reval_ceiling
                           / (  p_asset_fin_rec_old.recoverable_cost
                              - p_asset_deprn_rec_old.deprn_reserve
                                                          +NVL(p_asset_fin_rec_old.salvage_value,0)
                              - NVL (p_asset_deprn_rec_old.impairment_reserve,
                                     0
                                    )
                             )
                          )
                        - 1;
                  END IF;
               END IF;

               x_reval_out.cost_adj :=
                    (  p_asset_fin_rec_old.recoverable_cost
                     - p_asset_deprn_rec_old.deprn_reserve
                                         +NVL(p_asset_fin_rec_old.salvage_value,0)
                     - NVL (p_asset_deprn_rec_old.impairment_reserve, 0)
                    )
                  * l_reval_rate;


            g_old_nbv :=
               (  p_asset_fin_rec_old.recoverable_cost
                - p_asset_deprn_rec_old.deprn_reserve
                                +NVL(p_asset_fin_rec_old.salvage_value,0)
                - NVL (p_asset_deprn_rec_old.impairment_reserve, 0)
               );
            g_new_nbv := g_old_nbv + x_reval_out.cost_adj;
         END IF;

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'x_reval_out.cost_adj',
                              x_reval_out.cost_adj
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP', 'g_old_nbv', g_old_nbv, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP', 'g_new_nbv', g_new_nbv, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD
                        ('fareven' || ' SORP',
                         'Calling FA_SORP_REVALUATION_PKG.fa_sorp_link_reval',
                         'START'
                        , p_log_level_rec => p_log_level_rec);
         END IF;

         -- This Call is made to caluclate impairment related amounts while performing linked revaluation
         IF     nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
            AND p_reval_options_rec.linked_flag = 'YES'
         THEN
            fa_sorp_revaluation_pkg.fa_sorp_link_reval
                                        (--g_old_nbv,
                                         x_reval_out.cost_adj,
                                         p_reval_options_rec.mass_reval_id,
                                         p_asset_hdr_rec.asset_id,
                                         p_asset_hdr_rec.book_type_code,
                                         p_reval_options_rec.run_mode,
                                         px_trans_rec.mass_reference_id,
                                         p_mrc_sob_type_code,
                                         p_asset_cat_rec.category_id,
                                         p_reval_options_rec.reval_type_flag,
                                         p_asset_hdr_rec.set_of_books_id,
                                         p_imp_loss_impact,
                                         p_reval_gain,
                                         p_impair_loss_acct,
                                         p_temp_imp_deprn_effect,
                                         p_reval_rsv_deprn_effect
                                        , p_log_level_rec => p_log_level_rec);

            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD
                       ('fareven' || ' SORP',
                        'Calling FA_SORP_REVALUATION_PKG.fa_sorp_link_reval',
                        'END'
                       , p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD
                            ('fareven' || ' SORP',
                             'Calling FA_SORP_REVALUATION_PKG.fa_imp_itf_upd',
                             'START'
                            , p_log_level_rec => p_log_level_rec);

               fa_debug_pkg.ADD
                            ('fareven' || ' SORP',
                             'p_reval_gain',
                             p_reval_gain
                            , p_log_level_rec => p_log_level_rec);
            END IF;

            -- This call is made to update FA_ITF_IMPAIRMENTS table with reversed amounts
            IF p_reval_options_rec.run_mode = 'RUN' and p_reval_gain is not null
            THEN
               fa_sorp_revaluation_pkg.fa_imp_itf_upd
                                      (px_trans_rec.mass_reference_id,
                                       p_asset_hdr_rec.book_type_code,
                                       p_asset_hdr_rec.asset_id,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_date
                                      , p_log_level_rec => p_log_level_rec);
            END IF;

            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD
                           ('fareven' || ' SORP',
                            'Calling FA_SORP_REVALUATION_PKG.fa_imp_itf_upd',
                            'END'
                           , p_log_level_rec => p_log_level_rec);
            END IF;
         END IF;
      ELSE
         l_reval_rate := p_reval_options_rec.reval_percent / 100;
      END IF;

      -- Bug#6666666 SORP End
      l_life_extension_factor := p_reval_options_rec.life_extension_factor;
      l_life_extension_ceiling := p_reval_options_rec.life_extension_ceiling;

      -- Get Book Based Revaluation Rules from Book Controls Cache
      -- Get some more information from the Book Controls Cache
      IF (p_log_level_rec.statement_level)
      THEN
         fa_debug_pkg.ADD ('fareven', 'step', 2, p_log_level_rec => p_log_level_rec);
      END IF;

      -- Find the Depreciation Basis Rule and Rate Source Rule
      -- for this depreciation method
      IF NOT fa_cache_pkg.fazccmt
                           (x_method      => p_asset_fin_rec_old.deprn_method_code,
                            x_life        => p_asset_fin_rec_old.life_in_months
                           , p_log_level_rec => p_log_level_rec)
      THEN
         RAISE fareven_err;
      END IF;

      l_method_id := fa_cache_pkg.fazccmt_record.method_id;

      IF fa_cache_pkg.fazccmt_record.depreciate_lastyear_flag = 'YES'
      THEN
         l_depr_last_year_flag := TRUE;
      ELSE
         l_depr_last_year_flag := FALSE;
      END IF;

      l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
      l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

      IF (p_log_level_rec.statement_level)
      THEN
         fa_debug_pkg.ADD ('fareven', '3', 3, p_log_level_rec => p_log_level_rec);
      END IF;

      -- Bug#6666666 SORP Start
      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
      THEN
         IF (l_reval_ceiling_flag)
         THEN
            IF ((p_asset_fin_rec_old.COST * (1 + l_reval_rate)) >
                                             p_asset_fin_rec_old.reval_ceiling
               )
            THEN
               l_reval_rate :=
                    (  p_asset_fin_rec_old.reval_ceiling
                     / p_asset_fin_rec_old.COST
                    )
                  - 1;
            END IF;
         END IF;
      END IF;

      -- Bug#6666666 SORP End
      IF (p_log_level_rec.statement_level)
      THEN
         fa_debug_pkg.ADD ('fareven', 'l_reval_rate', l_reval_rate, p_log_level_rec => p_log_level_rec);
      END IF;

      --Calculate adjustment to asset cost
      -- Bug#6666666 SORP Start
      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
      THEN
         x_reval_out.cost_adj := p_asset_fin_rec_old.COST * l_reval_rate;
      END IF;

      -- Bug#6666666 SORP End
       -- Round to correct precision
      IF NOT fa_utils_pkg.faxrnd (x_reval_out.cost_adj,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec)
      THEN
         RAISE fareven_err;
      END IF;

      -- Added for SORP
      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
      THEN
         px_asset_fin_rec_new.COST :=
                              p_asset_fin_rec_old.COST + x_reval_out.cost_adj;
      END IF;

      l_recalc_life := p_asset_fin_rec_old.life_in_months;
      l_sorp_reval_adj := x_reval_out.cost_adj;

      IF (p_log_level_rec.statement_level)
      THEN
         fa_debug_pkg.ADD ('fareven', 'old cost', p_asset_fin_rec_old.COST, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD ('fareven',
                           'x_reval_out.cost_adj',
                           x_reval_out.cost_adj
                          , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD ('fareven', 'new cost', px_asset_fin_rec_new.COST, p_log_level_rec => p_log_level_rec);
      END IF;

      -- call fazccbd to initialize cat book defaults which is called in
      -- calc_salvage_value
      IF NOT fa_cache_pkg.fazccbd
               (x_book        => p_asset_hdr_rec.book_type_code,
                x_cat_id      => p_asset_cat_rec.category_id,
                x_jdpis       => TO_NUMBER
                                    (TO_CHAR
                                        (p_asset_fin_rec_old.date_placed_in_service,
                                         'J'
                                        )
                                    ),
                p_log_level_rec => p_log_level_rec
               )
      THEN
         RAISE fareven_err;
      END IF;

      px_asset_fin_rec_new.annual_deprn_rounding_flag := 'REV';

      --If the asset is not fully reserved
      IF (NOT l_fully_rsvd_flag)
      THEN
         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven', 'not fully reserved', 1, p_log_level_rec => p_log_level_rec);
         END IF;

         -- Compute Adjustment to Depreciation Reserve
         --  if  Depreciation Reserve is to be revalued
         IF l_reval_dep_rsv_flag = 'YES'
         THEN
            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven', 'reval_dep_rsv_flag is YES', 1, p_log_level_rec => p_log_level_rec);
            END IF;

            x_reval_out.deprn_rsv_adj :=
                            p_asset_deprn_rec_old.deprn_reserve * l_reval_rate;

            -- Round to correct precision
            IF NOT fa_utils_pkg.faxrnd (x_reval_out.deprn_rsv_adj,
                                        p_asset_hdr_rec.book_type_code,
                                        p_asset_hdr_rec.set_of_books_id,
                                        p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            -- Bonus Deprn  YYOON
            x_reval_out.bonus_deprn_rsv_adj :=
                      p_asset_deprn_rec_old.bonus_deprn_reserve * l_reval_rate;

            -- Round to correct precision
            IF NOT fa_utils_pkg.faxrnd (x_reval_out.bonus_deprn_rsv_adj,
                                        p_asset_hdr_rec.book_type_code,
                                        p_asset_hdr_rec.set_of_books_id,
                                        p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;
         ELSE                  --if Depreciation Reserve is not to be revalued
            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven', 'reval_dep_rsv_flag is NO', 1, p_log_level_rec => p_log_level_rec);
            END IF;

            x_reval_out.deprn_rsv_adj := -p_asset_deprn_rec_old.deprn_reserve;
            x_reval_out.bonus_deprn_rsv_adj :=
                                    -p_asset_deprn_rec_old.bonus_deprn_reserve;

            -- Bug 6666666 START Added for SORP
            IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
            THEN
               IF ABS (x_reval_out.deprn_rsv_adj) <> 0
               THEN
                  IF (x_reval_out.cost_adj > 0)
                  THEN
                     IF (ABS (x_reval_out.deprn_rsv_adj) >=
                                                          x_reval_out.cost_adj
                        )
                     THEN
                        x_reval_out.cost_adj :=
                             (  ABS (x_reval_out.deprn_rsv_adj)
                              - x_reval_out.cost_adj
                             )
                           * -1;
                     ELSE
                        x_reval_out.cost_adj :=
                             x_reval_out.cost_adj
                           - ABS (x_reval_out.deprn_rsv_adj);
                     END IF;
                  END IF;
               END IF;
            END IF;
         -- Bug 6666666 START
         END IF;

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven',
                              'x_reval_out.deprn_rsv_adj',
                              x_reval_out.deprn_rsv_adj
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven',
                              'x_reval_out.bonus_deprn_rsv_adj',
                              x_reval_out.bonus_deprn_rsv_adj
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         fa_debug_pkg.ADD ('fareven',
                           'p_asset_deprn_rec_old.impairment_reserve',
                           p_asset_deprn_rec_old.impairment_reserve
                          , p_log_level_rec => p_log_level_rec);

         IF (p_asset_deprn_rec_old.impairment_reserve <> 0)
         THEN
            IF (x_reval_out.cost_adj > 0)
            THEN
               IF (p_asset_deprn_rec_old.impairment_reserve >=
                                                          x_reval_out.cost_adj
                  )
               THEN
                  -- Bug 6666666 START  Modified for SORP
                  IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
                  THEN
                     x_reval_out.cost_adj :=
                          (  p_asset_deprn_rec_old.impairment_reserve
                           - x_reval_out.cost_adj
                          )
                        * -1;
                     x_reval_out.impairment_rsv_adj :=
                                  p_asset_deprn_rec_old.impairment_reserve
                                  * -1;
                  ELSE
                     x_reval_out.impairment_rsv_adj :=
                                  p_asset_deprn_rec_old.impairment_reserve
                                  * -1;
                  /*   x_reval_out.cost_adj := 0;
                     x_reval_out.deprn_rsv_adj := 0;
                     x_reval_out.reval_rsv_adj := 0;*/
                  END IF;
               ELSE
                  IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
                  THEN
                     x_reval_out.cost_adj :=
                          x_reval_out.cost_adj
                        - p_asset_deprn_rec_old.impairment_reserve;
                     x_reval_out.impairment_rsv_adj :=
                                  p_asset_deprn_rec_old.impairment_reserve
                                  * -1;
                  ELSE
                     x_reval_out.impairment_rsv_adj :=
                                 p_asset_deprn_rec_old.impairment_reserve
                                 * -1;
-- Bug# 6684245      x_reval_out.cost_adj:= x_reval_out.cost_adj - p_asset_deprn_rec_old.impairment_reserve;
                     x_reval_out.deprn_rsv_adj := x_reval_out.deprn_rsv_adj;
                     x_reval_out.reval_rsv_adj :=
                             x_reval_out.cost_adj - x_reval_out.deprn_rsv_adj;
                  END IF;
               END IF;
            ELSE                              -- x_reval_out.deprn_rsv_adj < 0
               IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
               THEN
                  x_reval_out.impairment_rsv_adj := 0;
               ELSE
                  x_reval_out.impairment_rsv_adj :=
                                 p_asset_deprn_rec_old.impairment_reserve
                                 * -1;
                  x_reval_out.cost_adj :=
                        x_reval_out.cost_adj + x_reval_out.impairment_rsv_adj;
               END IF;
            END IF;
         END IF;

         -- Bug 6666666 END  Modified for SORP

         -- GBertot: compute adjustment to YTD deprn. if it is to be revalued
         IF l_reval_ytd_deprn_flag = 'YES'
         THEN
            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven', 'reval_ytd_deprn_flag is YES', 1, p_log_level_rec => p_log_level_rec);
            END IF;

            x_reval_out.ytd_deprn_adj :=
                                p_asset_deprn_rec_old.ytd_deprn * l_reval_rate;

            --round to correct precision
            IF NOT fa_utils_pkg.faxrnd (x_reval_out.ytd_deprn_adj,
                                        p_asset_hdr_rec.book_type_code,
                                        p_asset_hdr_rec.set_of_books_id,
                                        p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            --  Bonus Deprn  YYOON
            x_reval_out.bonus_ytd_deprn_adj :=
                          p_asset_deprn_rec_old.bonus_ytd_deprn * l_reval_rate;
            x_reval_out.ytd_impairment_adj :=
                           p_asset_deprn_rec_old.ytd_impairment * l_reval_rate;

            --round to correct precision
            IF NOT fa_utils_pkg.faxrnd (x_reval_out.bonus_ytd_deprn_adj,
                                        p_asset_hdr_rec.book_type_code,
                                        p_asset_hdr_rec.set_of_books_id,
                                        p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            IF NOT fa_utils_pkg.faxrnd (x_reval_out.ytd_impairment_adj,
                                        p_asset_hdr_rec.book_type_code,
                                        p_asset_hdr_rec.set_of_books_id,
                                        p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;
         ELSE                           -- if YTD deprn. is not to be revalued
            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven', 'reval_ytd_deprn_flag is NO', 1, p_log_level_rec => p_log_level_rec);
            END IF;

            x_reval_out.ytd_deprn_adj := 0;
            x_reval_out.bonus_ytd_deprn_adj := 0;
            x_reval_out.ytd_impairment_adj := 0;
         END IF;

         -- Bonus Deprn - YYOON:
         --   Here in the following calculation of revaluation reserve amount,
         --   the revalued bonus_ytd_adj amount doesn't need to be
         -- involved in the calculation
         --because the ytd_deprn_adj has already included the bonus ytd amount.
         -- Compute Adjustment to Revaluation Reserve

         -- Added for SORP
         IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
         THEN
            x_reval_out.reval_rsv_adj :=
                             x_reval_out.cost_adj - x_reval_out.deprn_rsv_adj;
         END IF;

         -- GBertot: Compute adjustment to revaluation reserve due to YTD deprn.
         x_reval_out.reval_rsv_adj :=
                         x_reval_out.reval_rsv_adj + x_reval_out.ytd_deprn_adj;

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven',
                              'x_reval_out.reval_rsv_adj',
                              x_reval_out.reval_rsv_adj
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         x_reval_out.new_life := p_asset_fin_rec_old.life_in_months;
         x_reval_out.new_fully_rsvd_revals_ctr :=
                                 p_asset_fin_rec_old.fully_rsvd_revals_counter;

         IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
         THEN
            px_asset_fin_rec_new.COST :=
                              p_asset_fin_rec_old.COST + x_reval_out.cost_adj;

            IF p_reval_options_rec.linked_flag = 'YES' and p_reval_gain is not null
            THEN
               x_reval_out.reval_rsv_adj := p_reval_gain;
            ELSE
               x_reval_out.reval_rsv_adj := l_sorp_reval_adj;
            END IF;
         END IF;

         -- Compute Recoverable Cost
         IF NOT fa_asset_calc_pvt.calc_salvage_value
                                (p_trans_rec               => px_trans_rec,
                                 p_asset_hdr_rec           => p_asset_hdr_rec,
                                 p_asset_type_rec          => p_asset_type_rec,
                                 p_asset_fin_rec_old       => p_asset_fin_rec_old,
                                 p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                                 px_asset_fin_rec_new      => px_asset_fin_rec_new,
                                 p_mrc_sob_type_code       => p_mrc_sob_type_code
                                , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE fareven_err;
         END IF;

         x_reval_out.new_salvage_value := px_asset_fin_rec_new.salvage_value;

         IF NOT fa_asset_calc_pvt.calc_rec_cost
                                 (p_asset_hdr_rec           => p_asset_hdr_rec,
                                  p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                                  px_asset_fin_rec_new      => px_asset_fin_rec_new
                                 , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE fareven_err;
         END IF;

         px_asset_fin_rec_new.adjusted_cost :=
                                         px_asset_fin_rec_new.recoverable_cost;

         IF NOT fa_asset_calc_pvt.calc_deprn_limit_adj_rec_cost
                                (p_asset_hdr_rec           => p_asset_hdr_rec,
                                 p_asset_type_rec          => p_asset_type_rec,
                                 p_asset_fin_rec_old       => p_asset_fin_rec_old,
                                 p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                                 px_asset_fin_rec_new      => px_asset_fin_rec_new,
                                 p_mrc_sob_type_code       => p_mrc_sob_type_code
                                , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE fareven_err;
         END IF;

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven',
                              'after calc_salvage_value SV',
                              px_asset_fin_rec_new.salvage_value
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven',
                              'after calc_rec_cost rec cost',
                              px_asset_fin_rec_new.recoverable_cost
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven',
                              'after calc_adj_rec_cost adj_rec_cost',
                              px_asset_fin_rec_new.adjusted_recoverable_cost
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         IF NOT fa_amort_pvt.faxraf
                         (px_trans_rec                => px_trans_rec,
                          p_asset_hdr_rec             => p_asset_hdr_rec,
                          p_asset_desc_rec            => p_asset_desc_rec,
                          p_asset_cat_rec             => p_asset_cat_rec,
                          p_asset_type_rec            => p_asset_type_rec,
                          p_asset_fin_rec_old         => p_asset_fin_rec_old,
                          px_asset_fin_rec_new        => px_asset_fin_rec_new,
                          p_asset_deprn_rec           => p_asset_deprn_rec_old,
                          p_period_rec                => p_period_rec,
                          px_deprn_exp                => l_deprn_exp,
                          px_bonus_deprn_exp          => l_bonus_deprn_exp,
                          px_impairment_exp           => l_impairment_exp,
                          px_reval_deprn_rsv_adj      => x_reval_out.deprn_rsv_adj,
                          p_mrc_sob_type_code         => p_mrc_sob_type_code,
                          p_running_mode              => fa_std_types.fa_dpr_normal,
                          p_used_by_revaluation       => 1
                         , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE fareven_err;
         END IF;
      END IF;                            -- If the asset is not fully reserved

      --If the asset is fully reserved
      IF (l_fully_rsvd_flag)
      THEN
         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven',
                              'REVALUE FULLY RESERVED ASSET',
                              p_reval_options_rec.reval_fully_rsvd_flag
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         IF (   (NVL (p_reval_options_rec.reval_fully_rsvd_flag, 'N') = 'N')
             OR (    (p_asset_fin_rec_old.fully_rsvd_revals_counter >=
                                     p_reval_options_rec.max_fully_rsvd_revals
                     )
                 AND (p_reval_options_rec.max_fully_rsvd_revals <> -1)
                )
            )
         THEN
            x_reval_out.cost_adj := 0;
            x_reval_out.deprn_rsv_adj := 0;
            x_reval_out.reval_rsv_adj := 0;
            x_reval_out.ytd_deprn_adj := 0;
            x_reval_out.bonus_ytd_deprn_adj := 0;
            x_reval_out.bonus_deprn_rsv_adj := 0;
            x_reval_out.ytd_impairment_adj := 0;
            x_reval_out.impairment_rsv_adj := 0;
            x_reval_out.new_life := p_asset_fin_rec_old.life_in_months;
            x_reval_out.new_fully_rsvd_revals_ctr :=
                                p_asset_fin_rec_old.fully_rsvd_revals_counter;
            x_reval_out.new_adj_cost := p_asset_fin_rec_old.adjusted_cost;
            x_reval_out.new_adj_capacity :=
                                        p_asset_fin_rec_old.adjusted_capacity;
            x_reval_out.new_rec_cost := p_asset_fin_rec_old.recoverable_cost;
            x_reval_out.new_raf := p_asset_fin_rec_old.rate_adjustment_factor;
            px_asset_fin_rec_new := p_asset_fin_rec_old;
            px_asset_deprn_rec_new := p_asset_deprn_rec_old;
            x_reval_out.insert_txn_flag := FALSE;
         ELSE
            -- If life extension factor is not specified as a part
            -- of revaluation rules it is an error condition
            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven',
                                 'l_life_extension_factor',
                                 l_life_extension_factor
                                , p_log_level_rec => p_log_level_rec);
            END IF;

            IF (l_life_extension_factor = -1)
            THEN
               RAISE fareven_err;
            END IF;

            --Bug#7488735 - Depreciation not calculated for donated asset as
            -- cost is zero at this point and recoverable_cost is calculated as zero
            IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
            THEN
                                --Bug#7553091
                           --if x_reval_out.cost_adj <> 0 then
               px_asset_fin_rec_new.COST := x_reval_out.cost_adj;
                           --end if;
            end if;

            -- Compute Recoverable Cost
            IF NOT fa_asset_calc_pvt.calc_salvage_value
                                (p_trans_rec               => px_trans_rec,
                                 p_asset_hdr_rec           => p_asset_hdr_rec,
                                 p_asset_type_rec          => p_asset_type_rec,
                                 p_asset_fin_rec_old       => p_asset_fin_rec_old,
                                 p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                                 px_asset_fin_rec_new      => px_asset_fin_rec_new,
                                 p_mrc_sob_type_code       => p_mrc_sob_type_code
                                , p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            IF NOT fa_asset_calc_pvt.calc_rec_cost
                                 (p_asset_hdr_rec           => p_asset_hdr_rec,
                                  p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                                  px_asset_fin_rec_new      => px_asset_fin_rec_new
                                 , p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            IF NOT fa_asset_calc_pvt.calc_deprn_limit_adj_rec_cost
                                (p_asset_hdr_rec           => p_asset_hdr_rec,
                                 p_asset_type_rec          => p_asset_type_rec,
                                 p_asset_fin_rec_old       => p_asset_fin_rec_old,
                                 p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                                 px_asset_fin_rec_new      => px_asset_fin_rec_new,
                                 p_mrc_sob_type_code       => p_mrc_sob_type_code
                                , p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven',
                                 'after calc_salvage_value SV',
                                 px_asset_fin_rec_new.salvage_value
                                , p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD ('fareven',
                                 'after calc_rec_cost rec cost',
                                 px_asset_fin_rec_new.recoverable_cost
                                , p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD
                               ('fareven',
                                'after calc_adj_rec_cost adj_rec_cost',
                                px_asset_fin_rec_new.adjusted_recoverable_cost
                               , p_log_level_rec => p_log_level_rec);
            END IF;

            x_reval_out.new_rec_cost := px_asset_fin_rec_new.recoverable_cost;
            x_reval_out.new_salvage_value :=
                                            px_asset_fin_rec_new.salvage_value;

            IF (l_reval_dep_rsv_flag = 'YES')
            THEN
               -- If Depreciation Reserve is to be revalued
               IF (p_log_level_rec.statement_level)
               THEN
                  fa_debug_pkg.ADD ('fareven', 'reval_dep_rsv_flag is YES',
                                    1, p_log_level_rec => p_log_level_rec);
               END IF;

               -- Extend Life by the life extension factor limited by
               -- life extension ceiling (if specified) to compute Catchup
               -- Depreciation
               l_recalc_life :=
                  TRUNC (  p_asset_fin_rec_old.life_in_months
                         * l_life_extension_factor
                        );

               IF (p_log_level_rec.statement_level)
               THEN
                  fa_debug_pkg.ADD ('fareven', 'RECALC LIFE1', 1, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD ('fareven',
                                    'l_recalc_life1.1',
                                    l_recalc_life
                                   , p_log_level_rec => p_log_level_rec);
               END IF;

               IF (l_life_extension_ceiling <> -1)
               THEN
                  l_life_ceiling :=
                     TRUNC (  p_asset_fin_rec_old.life_in_months
                            * l_life_extension_ceiling
                           );

                  IF (l_recalc_life > l_life_ceiling)
                  THEN
                     l_recalc_life := l_life_ceiling;
                  END IF;
               END IF;

               IF (p_log_level_rec.statement_level)
               THEN
                  fa_debug_pkg.ADD ('fareven',
                                    'l_recalc_life1.2',
                                    l_recalc_life
                                   , p_log_level_rec => p_log_level_rec);
               END IF;

               -- Find if the Depreciation Method for this
               -- calculated life exists
               IF (   (l_rate_source_rule = fa_std_types.fad_rsr_calc)
                   OR (l_rate_source_rule = fa_std_types.fad_rsr_table)
                   OR (l_rate_source_rule = fa_std_types.fad_rsr_formula)
                  )
               THEN
                  IF NOT fa_cache_pkg.fazccmt
                           (x_method      => p_asset_fin_rec_old.deprn_method_code,
                            x_life        => l_recalc_life
                           , p_log_level_rec => p_log_level_rec)
                  THEN
                     IF (l_rate_source_rule = fa_std_types.fad_rsr_calc)
                     THEN
                        IF (p_log_level_rec.statement_level)
                        THEN
                           fa_debug_pkg.ADD ('fareven',
                                             'calling',
                                             'validate_life'
                                            , p_log_level_rec => p_log_level_rec);
                           fa_debug_pkg.ADD
                                       ('fareven',
                                        'p_deprn_method',
                                        px_asset_fin_rec_new.deprn_method_code
                                       , p_log_level_rec => p_log_level_rec);
                           fa_debug_pkg.ADD ('fareven',
                                             'l_recalc_life',
                                             l_recalc_life
                                            , p_log_level_rec => p_log_level_rec);
                        END IF;

                        IF NOT fa_asset_val_pvt.validate_life
                                 (p_deprn_method          => p_asset_fin_rec_old.deprn_method_code,
                                  p_rate_source_rule      => l_rate_source_rule,
                                  p_life_in_months        => l_recalc_life,
                                  p_lim                   => l_recalc_life,
                                  p_user_id               => px_trans_rec.who_info.last_updated_by,
                                  p_curr_date             => px_trans_rec.who_info.last_update_date,
                                  px_new_life             => l_recalc_life,
                                  p_calling_fn            => 'fareven'
                                 , p_log_level_rec => p_log_level_rec)
                        THEN
                           RAISE fareven_err;
                        END IF;
                     ELSE
                        IF (p_reval_options_rec.run_mode = 'PREVIEW')
                        THEN
                           x_reval_out.life_notdef := l_recalc_life;
                           x_reval_out.new_life := l_recalc_life;
                           GOTO fareven_exit_noerr;
                        ELSE
                           RAISE fareven_err;
                        END IF;                        -- ins_txn_flag = FALSE
                     END IF;              -- l_rate_source_rule = FAD_RSR_CALC
                  END IF;                            -- end if for not fazccmt
               END IF;                             -- CALC or TABLE or FORMULA

               -- Assign all values to the depreciation engine to compute the
               -- total depreciation on the asset that would have accrued till
               -- this point if the life of the asset had been 'recalc life'
               -- and cost had been new_rec_cost
               l_dpr_in.adj_cost := x_reval_out.new_rec_cost;
               l_dpr_in.rec_cost := x_reval_out.new_rec_cost;
               l_dpr_in.reval_amo_basis := 0;
               l_dpr_in.deprn_rsv := 0;
               l_dpr_in.reval_rsv := 0;
               -- Bonus Deprn  YYOON
               l_dpr_in.bonus_deprn_rsv := 0;
               l_dpr_in.impairment_rsv := 0;
               -- End of Bonus Deprn Change
               l_dpr_in.adj_rate := p_asset_fin_rec_old.adjusted_rate;
               l_dpr_in.rate_adj_factor := 1;
               -- Fix For Bug #2018862.  Set formula factor to 1
               l_dpr_in.formula_factor := 1;
               l_dpr_in.capacity := p_asset_fin_rec_old.production_capacity;
               l_dpr_in.adj_capacity :=
                                       p_asset_fin_rec_old.production_capacity;
               l_dpr_in.ltd_prod := 0;
               l_dpr_in.asset_num := p_asset_desc_rec.asset_number;
               l_dpr_in.calendar_type := l_deprn_calendar;
               l_dpr_in.ceil_name := p_asset_fin_rec_old.ceiling_name;
               l_dpr_in.bonus_rule := p_asset_fin_rec_old.bonus_rule;
               l_dpr_in.book := p_asset_hdr_rec.book_type_code;
               l_dpr_in.method_code := p_asset_fin_rec_old.deprn_method_code;
               l_dpr_in.asset_id := p_asset_hdr_rec.asset_id;
               l_dpr_in.jdate_in_service :=
                  TO_NUMBER
                         (TO_CHAR (p_asset_fin_rec_old.date_placed_in_service,
                                   'J'
                                  )
                         );
               l_dpr_in.prorate_jdate :=
                   TO_NUMBER (TO_CHAR (p_asset_fin_rec_old.prorate_date, 'J'));
               l_dpr_in.deprn_start_jdate :=
                  TO_NUMBER (TO_CHAR (p_asset_fin_rec_old.deprn_start_date,
                                      'J'
                                     )
                            );
               l_dpr_in.jdate_retired := 0;
               l_dpr_in.ret_prorate_jdate := 0;
               l_dpr_in.life := l_recalc_life;
               l_dpr_in.rsv_known_flag := TRUE;
               -- copy adjusted recoverable cost to l_dpr_in to
               -- make it compatible with faxcde() which supports
               -- asset with depreciation limit

               -- **************************************************
-- Assign adj_rec_cost calculated in faucrc to
-- l_dpr_in.adj_rec_cost. For fully reserved assets that
-- should still be fully reserved after life extension
-- factor, will not calculate new reserve correctly if
-- recalculated adj_rec_cost is not passed to faxcde
-- Fix for 1229608 SNARAYAN
-- ***************************************************
               l_dpr_in.adj_rec_cost :=
                                px_asset_fin_rec_new.adjusted_recoverable_cost;
               --fix for 1666248 - assign new salvage value which was
               --calculated based on the percent specified in category
               l_dpr_in.salvage_value := x_reval_out.new_salvage_value;
               l_dpr_in.salvage_value := px_asset_fin_rec_new.salvage_value;
               l_dpr_in.deprn_rounding_flag := 'REV';
               -- Copy prior_fy_exp from reval_in_struct to
               -- deprn_struct.
               l_dpr_in.prior_fy_exp := p_asset_deprn_rec_old.prior_fy_expense;
               l_dpr_in.ytd_deprn := p_asset_deprn_rec_old.ytd_deprn;
               -- Bonus Deprn  YYOON
               l_dpr_in.prior_fy_bonus_exp :=
                                  p_asset_deprn_rec_old.prior_fy_bonus_expense;
               l_dpr_in.bonus_ytd_deprn :=
                                         p_asset_deprn_rec_old.bonus_ytd_deprn;
               -- End of Bonus Deprn Change
               l_dpr_in.ytd_impairment := p_asset_deprn_rec_old.ytd_impairment;
               l_fy := -1;
               l_period_num := -1;

               SELECT fy.fiscal_year, cp.period_num
                 INTO l_fy, l_period_num
                 FROM fa_fiscal_year fy, fa_calendar_periods cp
                WHERE fy.fiscal_year_name = l_fy_name
                  AND cp.calendar_type = l_deprn_calendar
                  AND p_asset_fin_rec_old.prorate_date BETWEEN cp.start_date
                                                           AND cp.end_date
                  AND p_asset_fin_rec_old.prorate_date BETWEEN fy.start_date
                                                           AND fy.end_date;

               l_dpr_in.y_begin := l_fy;
               l_dpr_in.p_cl_begin := 1;
               l_fy := -1;
               l_period_num := -1;

               SELECT dp.fiscal_year, dp.period_num
                 INTO l_fy, l_period_num
                 FROM fa_deprn_periods dp
                WHERE dp.book_type_code = p_asset_hdr_rec.book_type_code
                  AND dp.period_counter = l_last_period_counter;

               l_dpr_in.y_end := l_fy;
               l_dpr_in.p_cl_end := l_period_num;
               -- Added for code from fa.m
               l_dpr_in.mrc_sob_type_code := p_mrc_sob_type_code;
               l_dpr_in.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
               l_dpr_in.tracking_method := p_asset_fin_rec_old.tracking_method;
               l_dpr_in.allocate_to_fully_ret_flag :=
                                p_asset_fin_rec_old.allocate_to_fully_ret_flag;
               l_dpr_in.allocate_to_fully_rsv_flag :=
                                p_asset_fin_rec_old.allocate_to_fully_rsv_flag;
               l_dpr_in.excess_allocation_option :=
                                  p_asset_fin_rec_old.excess_allocation_option;
               l_dpr_in.depreciation_option :=
                                       p_asset_fin_rec_old.depreciation_option;
               l_dpr_in.member_rollup_flag :=
                                        p_asset_fin_rec_old.member_rollup_flag;
               l_dpr_in.eofy_reserve := p_asset_fin_rec_old.eofy_reserve;
               l_dpr_in.update_override_status := FALSE;
               l_dpr_in.over_depreciate_option :=
                                    p_asset_fin_rec_old.over_depreciate_option;
               l_dpr_in.super_group_id := p_asset_fin_rec_old.super_group_id;
               l_dpr_in.COST := px_asset_fin_rec_new.COST;

               --l_dpr_in.asset_type := p_asset_type_rec.asset_type;
               IF (p_log_level_rec.statement_level)
               THEN
                  fa_debug_pkg.ADD ('fareven',
                                    'CALLING FAXCDE FROM FAREVEN',
                                    1
                                   , p_log_level_rec => p_log_level_rec);
               END IF;

               IF (NOT fa_cde_pkg.faxcde (l_dpr_in,
                                          l_dpr_arr,
                                          l_dpr_out,
                                          l_running_mode,
                                          l_ind,
                                          p_log_level_rec
                                         )
                  )
               THEN
                  RAISE fareven_err;
               END IF;

               --Compute Adjustment to Depreciation Reserve
               x_reval_out.deprn_rsv_adj :=
                  l_dpr_out.new_deprn_rsv
                  - p_asset_deprn_rec_old.deprn_reserve;
               -- Bonus Deprn YYOON
               x_reval_out.bonus_deprn_rsv_adj :=
                    l_dpr_out.new_bonus_deprn_rsv
                  - p_asset_deprn_rec_old.bonus_deprn_reserve;
            -- End of Bonus Deprn Change
            ELSE                 -- If Depreciation Reserve is to be revalued.
               x_reval_out.deprn_rsv_adj :=
                                         -p_asset_deprn_rec_old.deprn_reserve;
               x_reval_out.bonus_deprn_rsv_adj :=
                                   -p_asset_deprn_rec_old.bonus_deprn_reserve;

               -- Added for SORP
               IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
               THEN
                  IF ABS (x_reval_out.deprn_rsv_adj) <> 0
                  THEN
                                  --Bug#7553091
                     IF (x_reval_out.cost_adj > 0 or x_reval_out.cost_adj=0 )
                     THEN
                        IF (ABS (x_reval_out.deprn_rsv_adj) >=
                                                          x_reval_out.cost_adj
                           )
                        THEN
                           x_reval_out.cost_adj :=
                                (  ABS (x_reval_out.deprn_rsv_adj)
                                 - x_reval_out.cost_adj
                                )
                              * -1;
                        ELSE
                           x_reval_out.cost_adj :=
                                x_reval_out.cost_adj
                              - ABS (x_reval_out.deprn_rsv_adj);
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;               --If Depreciation Reserve is to be revalued.

            --GBertot: compute adjustment to YTD deprn.
                 -- if it is to be revalued
            IF (l_reval_ytd_deprn_flag = 'YES')
            THEN
               x_reval_out.ytd_deprn_adj :=
                               p_asset_deprn_rec_old.ytd_deprn * l_reval_rate;

               -- round to correct precision
               IF NOT fa_utils_pkg.faxrnd (x_reval_out.ytd_deprn_adj,
                                           p_asset_hdr_rec.book_type_code,
                                           p_asset_hdr_rec.set_of_books_id,
                                           p_log_level_rec => p_log_level_rec)
               THEN
                  RAISE fareven_err;
               END IF;

               -- Bonus Deprn  YYOON
               x_reval_out.bonus_ytd_deprn_adj :=
                          p_asset_deprn_rec_old.bonus_ytd_deprn * l_reval_rate;

               IF NOT fa_utils_pkg.faxrnd (x_reval_out.bonus_ytd_deprn_adj,
                                           p_asset_hdr_rec.book_type_code,
                                           p_asset_hdr_rec.set_of_books_id,
                                           p_log_level_rec => p_log_level_rec)
               THEN
                  RAISE fareven_err;
               END IF;
            -- End of Bonus Deprn Change
            ELSE                        -- if YTD deprn. is not to be revalued
               x_reval_out.ytd_deprn_adj := 0;
               -- Bonus Deprn  YYOON
               x_reval_out.bonus_ytd_deprn_adj := 0;
               --End of Bonus Deprn Change
               x_reval_out.ytd_impairment_adj := 0;
            END IF;                     -- if YTD deprn. is not to be revalued

            -- Compute Adjustment to Revaluation Reserve
            IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
            THEN
               x_reval_out.reval_rsv_adj :=
                             x_reval_out.cost_adj - x_reval_out.deprn_rsv_adj;
            END IF;

            -- GBertot: Compute adjustment to revaluation reserve due
            -- to YTD deprn.
            x_reval_out.reval_rsv_adj :=
                         x_reval_out.reval_rsv_adj + x_reval_out.ytd_deprn_adj;
            fa_debug_pkg.ADD ('SORP Debug',
                              'p_asset_deprn_rec_old.impairment_reserve',
                              p_asset_deprn_rec_old.impairment_reserve
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('SORP Debug',
                              'x_reval_out.cost_adj',
                              x_reval_out.cost_adj
                             , p_log_level_rec => p_log_level_rec);

            IF (p_asset_deprn_rec_old.impairment_reserve <> 0)
            THEN
               IF (x_reval_out.cost_adj > 0)
               THEN
                  IF (p_asset_deprn_rec_old.impairment_reserve >=
                                                          x_reval_out.cost_adj
                     )
                  THEN
                     -- -- Bug 6666666 START  Modified for SORP
                     IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
                     THEN
                        x_reval_out.cost_adj :=
                             (  p_asset_deprn_rec_old.impairment_reserve
                              - x_reval_out.cost_adj
                             )
                           * -1;
                        x_reval_out.impairment_rsv_adj :=
                                  p_asset_deprn_rec_old.impairment_reserve
                                  * -1;
                     ELSE
                        /*Bug#8530038 - */
                        x_reval_out.impairment_rsv_adj :=
                                  p_asset_deprn_rec_old.impairment_reserve * -1;
                     END IF;
                  ELSE
                     IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
                     THEN
                        x_reval_out.cost_adj :=
                             x_reval_out.cost_adj
                           - p_asset_deprn_rec_old.impairment_reserve;
                        x_reval_out.impairment_rsv_adj :=
                                  p_asset_deprn_rec_old.impairment_reserve
                                  * -1;
                     ELSE
                        x_reval_out.impairment_rsv_adj :=
                                 p_asset_deprn_rec_old.impairment_reserve
                                 * -1;
                        x_reval_out.cost_adj :=
                             x_reval_out.cost_adj
                           - p_asset_deprn_rec_old.impairment_reserve;
                        x_reval_out.deprn_rsv_adj := x_reval_out.deprn_rsv_adj;
                        x_reval_out.reval_rsv_adj :=
                              x_reval_out.cost_adj - x_reval_out.deprn_rsv_adj;
                     END IF;
                  END IF;
               ELSE                           -- x_reval_out.deprn_rsv_adj < 0
                  IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
                  THEN
                     x_reval_out.impairment_rsv_adj := 0;
                  ELSE
                     x_reval_out.impairment_rsv_adj :=
                                 p_asset_deprn_rec_old.impairment_reserve
                                 * -1;
                     x_reval_out.cost_adj :=
                        x_reval_out.cost_adj + x_reval_out.impairment_rsv_adj;
                  END IF;
               END IF;
            END IF;

            -- -- Bug 6666666 END  Modified for SORP

            -- Compute new life using life extension factor
            -- regardless of
            -- life extension ceiling
            l_recalc_life :=
                  p_asset_fin_rec_old.life_in_months * l_life_extension_factor;
            l_recalc_life := TRUNC (l_recalc_life);

            IF (p_log_level_rec.statement_level)
            THEN
               fa_debug_pkg.ADD ('fareven', 'RECALC LIFE2', 1, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD ('fareven', 'l_recalc_life2.1',
                                 l_recalc_life, p_log_level_rec => p_log_level_rec);
            END IF;

            -- Find if the Depreciation Method for this
            -- calculated life exists
            IF (   (l_rate_source_rule = fa_std_types.fad_rsr_calc)
                OR (l_rate_source_rule = fa_std_types.fad_rsr_table)
                OR (l_rate_source_rule = fa_std_types.fad_rsr_formula)
               )
            THEN
               IF NOT fa_cache_pkg.fazccmt
                          (x_method      => p_asset_fin_rec_old.deprn_method_code,
                           x_life        => l_recalc_life
                          , p_log_level_rec => p_log_level_rec)
               THEN
                  IF (p_log_level_rec.statement_level)
                  THEN
                     fa_debug_pkg.ADD ('fareven', 'fazccmt false', 1, p_log_level_rec => p_log_level_rec);
                  END IF;

                  IF (l_rate_source_rule = fa_std_types.fad_rsr_calc)
                  THEN
                     IF (p_log_level_rec.statement_level)
                     THEN
                        fa_debug_pkg.ADD ('fareven',
                                          'calling validate_life',
                                          1
                                         , p_log_level_rec => p_log_level_rec);
                     END IF;

                     IF NOT fa_asset_val_pvt.validate_life
                              (p_deprn_method          => p_asset_fin_rec_old.deprn_method_code,
                               p_rate_source_rule      => l_rate_source_rule,
                               p_life_in_months        => l_recalc_life,
                               p_lim                   => l_recalc_life,
                               p_user_id               => px_trans_rec.who_info.last_updated_by,
                               p_curr_date             => px_trans_rec.who_info.last_update_date,
                               px_new_life             => l_recalc_life,
                               p_calling_fn            => 'fareven'
                              , p_log_level_rec => p_log_level_rec)
                     THEN
                        RAISE fareven_err;
                     END IF;
                  ELSE
                     IF (p_reval_options_rec.run_mode = 'PREVIEW')
                     THEN
                        x_reval_out.life_notdef := l_recalc_life;
                        x_reval_out.new_life := l_recalc_life;
                        GOTO fareven_exit_noerr;
                     ELSE
                        -- Display method/life combination that doesn't
                        -- exist, and that the program can't create
                        RAISE fareven_err;
                     END IF;
                  END IF;
               END IF;
            END IF;

            x_reval_out.new_life := l_recalc_life;
            px_asset_fin_rec_new.adjusted_cost :=
                                         px_asset_fin_rec_new.recoverable_cost;
            px_asset_fin_rec_new.life_in_months := l_recalc_life;

            IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
            THEN
               px_asset_fin_rec_new.COST :=
                              p_asset_fin_rec_old.COST + x_reval_out.cost_adj;

               IF p_reval_options_rec.linked_flag = 'YES' and p_reval_gain is not null
               THEN
                  x_reval_out.reval_rsv_adj := p_reval_gain;
               ELSE
                  x_reval_out.reval_rsv_adj := l_sorp_reval_adj;
               END IF;
            END IF;

            IF NOT fa_amort_pvt.faxraf
                         (px_trans_rec                => px_trans_rec,
                          p_asset_hdr_rec             => p_asset_hdr_rec,
                          p_asset_desc_rec            => p_asset_desc_rec,
                          p_asset_cat_rec             => p_asset_cat_rec,
                          p_asset_type_rec            => p_asset_type_rec,
                          p_asset_fin_rec_old         => p_asset_fin_rec_old,
                          px_asset_fin_rec_new        => px_asset_fin_rec_new,
                          p_asset_deprn_rec           => p_asset_deprn_rec_old,
                          p_period_rec                => p_period_rec,
                          px_deprn_exp                => l_deprn_exp,
                          px_bonus_deprn_exp          => l_bonus_deprn_exp,
                          px_impairment_exp           => l_impairment_exp,
                          px_reval_deprn_rsv_adj      => x_reval_out.deprn_rsv_adj,
                          p_mrc_sob_type_code         => p_mrc_sob_type_code,
                          p_running_mode              => fa_std_types.fa_dpr_normal,
                          p_used_by_revaluation       => 1
                         , p_log_level_rec => p_log_level_rec)
            THEN
               RAISE fareven_err;
            END IF;

            x_reval_out.new_fully_rsvd_revals_ctr :=
                             p_asset_fin_rec_old.fully_rsvd_revals_counter + 1;
         END IF;
      --If fully reserved assets are to be revalued and fully
      --reserved reval count is < max fully reserved revaluations
      END IF;                                -- If the asset is fully reserved

      -- populate px_asset_fin_rec_new and px_asset_deprn_rec_new
      IF (p_asset_type_rec.asset_type = 'CIP')
      THEN
         px_asset_fin_rec_new.rate_adjustment_factor := 1;
      END IF;

      px_asset_fin_rec_new.life_in_months := l_recalc_life;
      px_asset_fin_rec_new.fully_rsvd_revals_counter :=
                                         x_reval_out.new_fully_rsvd_revals_ctr;
      px_asset_deprn_rec_new.deprn_reserve :=
               p_asset_deprn_rec_old.deprn_reserve + x_reval_out.deprn_rsv_adj;

      -- Bug  6666666   SORP START
      -- Amortization is calculated on total amount credited to Reval Reserve Account.
      -- This includes reval gain + reversed deprn effect on reval adjustment amount
      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
      THEN
         px_asset_deprn_rec_new.reval_deprn_reserve :=
              p_asset_deprn_rec_old.reval_deprn_reserve
            + x_reval_out.reval_rsv_adj;
      ELSE
         px_asset_deprn_rec_new.reval_deprn_reserve :=
              p_asset_deprn_rec_old.reval_deprn_reserve
            + x_reval_out.reval_rsv_adj
            + NVL (p_reval_rsv_deprn_effect, 0);
      END IF;

      -- Bug  6666666   SORP END
      px_asset_deprn_rec_new.bonus_deprn_reserve :=
           p_asset_deprn_rec_old.bonus_deprn_reserve
         + x_reval_out.bonus_deprn_rsv_adj;

/*  commenting out - this is a duplicate
    px_asset_deprn_rec_new.reval_deprn_reserve :=
                     p_asset_deprn_rec_old.reval_deprn_reserve +
                     x_reval_out.reval_rsv_adj; */

      --  populate new reval_amort basis here
-- Bug# 6684245 impairment_reserve added to amortisation basis
-- Bug  6666666   SORP START
      IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
      THEN
         px_asset_fin_rec_new.reval_amortization_basis :=
              px_asset_deprn_rec_new.reval_deprn_reserve
            + NVL (p_asset_deprn_rec_old.impairment_reserve, 0);
      ELSE
         px_asset_fin_rec_new.reval_amortization_basis :=
                                   px_asset_deprn_rec_new.reval_deprn_reserve;

         IF (p_log_level_rec.statement_level)
         THEN
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'Impairment_reserve',
                              NVL (p_asset_deprn_rec_old.impairment_reserve,
                                   0)
                             );
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'reval_deprn_reserve',
                              px_asset_deprn_rec_new.reval_deprn_reserve
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fareven' || ' SORP',
                              'reval_amortization_basis',
                              px_asset_fin_rec_new.reval_amortization_basis
                             , p_log_level_rec => p_log_level_rec);
         END IF;
      END IF;

-- Bug  6666666   SORP END
    -- If cost adjustment is not 0 or the new life is not the
    -- same as old life and INSERT TRANSACTION_FLAG is TRUE then
    -- insert rows in FA_ADJUSTMENTS
      IF (p_reval_options_rec.run_mode = 'RUN')
      THEN
         IF    (   x_reval_out.cost_adj <> 0
                OR p_asset_fin_rec_old.life_in_months <> x_reval_out.new_life
               )
            OR (   (    x_reval_out.cost_adj = 0
                    AND nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
                   )
                OR p_asset_fin_rec_old.life_in_months <> x_reval_out.new_life
               )
         THEN
            IF ((  p_asset_deprn_rec_old.deprn_reserve
                 + x_reval_out.deprn_rsv_adj
                ) = px_asset_fin_rec_new.recoverable_cost
               )
            THEN
               px_trans_rec.transaction_subtype := 'FULL RSV';
               x_reval_out.pc_fully_res := l_last_period_counter + 1;
            ELSE
               px_trans_rec.transaction_subtype := 'STANDARD';
               x_reval_out.pc_fully_res := NULL;
            END IF;

            px_asset_fin_rec_new.period_counter_fully_reserved :=
                                                      x_reval_out.pc_fully_res;
            px_asset_fin_rec_new.period_counter_life_complete :=
                                                      x_reval_out.pc_fully_res;

            -- Load Adjustment structure for inserting into table
            -- FA_ADJUSTMENTS

            -- Get Asset Cost Account, Revaluation Reserve Account,
            -- Depreciation Reserve Account
            -- and Bonus Deprn Reserve Account
            --  from Category Books Cache
            IF (NOT fa_cache_pkg.fazccb
                                    (x_book        => p_asset_hdr_rec.book_type_code,
                                     x_cat_id      => p_asset_cat_rec.category_id,
                                     p_log_level_rec => p_log_level_rec
                                    )
               )
            THEN
               RAISE fareven_err;
            END IF;

            l_cost_acct := fa_cache_pkg.fazccb_record.asset_cost_acct;
            l_cip_cost_acct := fa_cache_pkg.fazccb_record.cip_cost_acct;
            l_reval_rsv_acct := fa_cache_pkg.fazccb_record.reval_reserve_acct;
            l_deprn_rsv_acct := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
            l_deprn_exp_acct := fa_cache_pkg.fazccb_record.deprn_expense_acct;
            -- Bonus Deprn - YYOON
            --   Getting the bonus deprn expense
            --   and the bonus deprn reserve account
            --   from asset category
            l_adj_in.ACCOUNT :=
                           fa_cache_pkg.fazccb_record.bonus_deprn_expense_acct;
            l_adj_in.ACCOUNT :=
                           fa_cache_pkg.fazccb_record.bonus_deprn_reserve_acct;
            --End of Bonus Deprn Change
            l_impairment_rsv_acct :=
                                fa_cache_pkg.fazccb_record.impair_reserve_acct;
            l_impairment_exp_acct :=
                                fa_cache_pkg.fazccb_record.impair_expense_acct;
            l_adj_in.transaction_header_id :=
                                            px_trans_rec.transaction_header_id;
            l_adj_in.asset_invoice_id := 0;
            l_adj_in.source_type_code := 'REVALUATION';

            IF (p_asset_type_rec.asset_type = 'CIP')
            THEN
               l_adj_in.adjustment_type := 'CIP COST';
            ELSE
               l_adj_in.adjustment_type := 'COST';
            END IF;

            IF (x_reval_out.cost_adj > 0)
            THEN
               l_adj_in.debit_credit_flag := 'DR';
            ELSE
               l_adj_in.debit_credit_flag := 'CR';
            END IF;

            l_adj_in.code_combination_id := 0;
            l_adj_in.book_type_code := p_asset_hdr_rec.book_type_code;
            l_adj_in.period_counter_created := l_last_period_counter + 1;
            l_adj_in.asset_id := p_asset_hdr_rec.asset_id;
            l_adj_in.adjustment_amount := ABS (x_reval_out.cost_adj);
            l_adj_in.period_counter_adjusted := l_last_period_counter + 1;
            l_adj_in.distribution_id := 0;
            l_adj_in.annualized_adjustment := 0;
            l_adj_in.last_update_date :=
                                        px_trans_rec.who_info.last_update_date;

            IF (p_asset_type_rec.asset_type = 'CIP')
            THEN
               l_adj_in.ACCOUNT := l_cip_cost_acct;
               l_adj_in.account_type := 'CIP_COST_ACCT';
            ELSE
               l_adj_in.ACCOUNT := l_cost_acct;
               l_adj_in.account_type := 'ASSET_COST_ACCT';
            END IF;

            l_adj_in.current_units := p_asset_desc_rec.current_units;
            l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active;
            l_adj_in.selection_thid := 0;
            l_adj_in.selection_retid := 0;
            l_adj_in.flush_adj_flag := FALSE;
            l_adj_in.gen_ccid_flag := TRUE;
            l_adj_in.mrc_sob_type_code := p_mrc_sob_type_code;
            l_adj_in.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

            IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
               )
            THEN
               IF (p_log_level_rec.statement_level)
               THEN
                  NULL;
               END IF;

               RAISE fareven_err;
            END IF;

            l_adj_in.leveling_flag := FALSE;
            -- GBertot: Code added to include the depreciation expense
            -- account in the revaluation JE
            l_adj_in.adjustment_type := 'EXPENSE';

            IF (x_reval_out.ytd_deprn_adj > 0)
            THEN
               l_adj_in.debit_credit_flag := 'DR';
            ELSE
               l_adj_in.debit_credit_flag := 'CR';
            END IF;

            l_adj_in.code_combination_id := 0;
            l_adj_in.book_type_code := p_asset_hdr_rec.book_type_code;
            l_adj_in.period_counter_created := l_last_period_counter + 1;
            l_adj_in.asset_id := p_asset_hdr_rec.asset_id;
            l_adj_in.adjustment_amount := ABS (x_reval_out.ytd_deprn_adj);
            l_adj_in.period_counter_adjusted := l_last_period_counter + 1;
            l_adj_in.distribution_id := 0;
            l_adj_in.annualized_adjustment := 0;
            l_adj_in.last_update_date :=
                                        px_trans_rec.who_info.last_update_date;
            -- BUG# 2150841
            -- allow for generating the deprn expense acct
            -- via workflow rules
            -- bridgway
            l_adj_in.ACCOUNT := l_deprn_exp_acct;
            l_adj_in.account_type := 'DEPRN_EXPENSE_ACCT';
            l_adj_in.current_units := p_asset_desc_rec.current_units;
            l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active;
            l_adj_in.selection_thid := 0;
            l_adj_in.selection_retid := 0;
            l_adj_in.flush_adj_flag := FALSE;
            l_adj_in.gen_ccid_flag := TRUE;

            IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
               )
            THEN
               IF (p_log_level_rec.statement_level)
               THEN
                  NULL;
               END IF;

               RAISE fareven_err;
            END IF;

            l_adj_in.gen_ccid_flag := TRUE;

            -- GBertot: End of depreciation expense account coding

            -- Bonus Deprn YYOON
            IF (x_reval_out.bonus_ytd_deprn_adj <> 0)
            THEN
               l_adj_in.adjustment_type := 'BONUS EXPENSE';

               IF (x_reval_out.bonus_ytd_deprn_adj > 0)
               THEN
                  l_adj_in.debit_credit_flag := 'DR';
               ELSE
                  l_adj_in.debit_credit_flag := 'CR';
               END IF;

               l_adj_in.code_combination_id := 0;
               l_adj_in.book_type_code := p_asset_hdr_rec.book_type_code;
               l_adj_in.period_counter_created := l_last_period_counter + 1;
               l_adj_in.asset_id := p_asset_hdr_rec.asset_id;
               l_adj_in.adjustment_amount :=
                                         ABS (x_reval_out.bonus_ytd_deprn_adj);
               l_adj_in.period_counter_adjusted := l_last_period_counter + 1;
               l_adj_in.distribution_id := 0;
               l_adj_in.annualized_adjustment := 0;
               l_adj_in.last_update_date :=
                                        px_trans_rec.who_info.last_update_date;
               l_adj_in.ACCOUNT := l_bonus_deprn_exp_acct;
               l_adj_in.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
               l_adj_in.current_units := p_asset_desc_rec.current_units;
               l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active;
               l_adj_in.selection_thid := 0;
               l_adj_in.selection_retid := 0;
               l_adj_in.flush_adj_flag := FALSE;
               -- The CCID of BONUS EXPENSE row will be generated
               --   through the workflow  YYOON
               l_adj_in.gen_ccid_flag := TRUE;

               IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
                  )
               THEN
                  IF (p_log_level_rec.statement_level)
                  THEN
                     NULL;
                  END IF;

                  RAISE fareven_err;
               END IF;

               l_adj_in.gen_ccid_flag := TRUE;
            END IF;

            -- End of Bonus Deprn Change
            l_adj_in.adjustment_type := 'REVAL RESERVE';

            --Bug 6666666 START  Modified for SORP
            IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
            THEN
               IF p_reval_options_rec.linked_flag = 'YES' and p_reval_gain is not null
               THEN
                  x_reval_out.reval_rsv_adj := p_reval_gain;
               ELSE
                  x_reval_out.reval_rsv_adj := l_sorp_reval_adj;
               END IF;

               fa_debug_pkg.ADD ('SORP',
                                 'x_reval_out.reval_rsv_adj',
                                 x_reval_out.reval_rsv_adj
                                , p_log_level_rec => p_log_level_rec);
            END IF;

            -- Bug#6666666 END
            IF (x_reval_out.reval_rsv_adj > 0)
            THEN
               l_adj_in.debit_credit_flag := 'CR';
            ELSE
               l_adj_in.debit_credit_flag := 'DR';
            END IF;

            l_adj_in.adjustment_amount := ABS (x_reval_out.reval_rsv_adj);
            l_adj_in.ACCOUNT := l_reval_rsv_acct;
            -- Added a new mode to differentiate the reval reserve
            -- value going
            -- from reval engine to fa_adjustments table vs.
            -- the reval reserve
            -- value going from depreciation engine to fa_deprn_detail
            -- table for bug 628863.  aling
            l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active_reval;
            l_adj_in.account_type := 'REVAL_RESERVE_ACCT';

            IF (x_reval_out.reval_rsv_adj <> 0)
            THEN
               IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
                  )
               THEN
                  IF (p_log_level_rec.statement_level)
                  THEN
                     NULL;
                  END IF;

                  RAISE fareven_err;
               END IF;
            END IF;

            -- Bug 6666666 Start Additional Accounting Entries For SORP START
            fa_debug_pkg.ADD ('SORP ACCOUNTING', 'START', 'START', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('SORP_ACCOUNTING',
                              'px_trans_rec.mass_reference_id',
                              px_trans_rec.mass_reference_id
                             , p_log_level_rec => p_log_level_rec);

            IF (    nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') = 'Y'
                AND p_reval_options_rec.linked_flag = 'YES'
                and p_reval_gain is not null
               )
            THEN
               IF NOT fa_sorp_revaluation_pkg.fa_sorp_accounting
                                      (p_asset_hdr_rec.asset_id,
                                       px_trans_rec.mass_reference_id,
                                       l_adj_in,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_date
                                      , p_log_level_rec => p_log_level_rec)
               THEN
                  fa_debug_pkg.ADD ('SORP_ACCOUNTING', 'Failure', 'Failure', p_log_level_rec => p_log_level_rec);
                  RAISE fareven_err;
                  RETURN FALSE;
               END IF;
                -- The code is commented anticipating this is not needed.Will be removed later
            /* IF NOT FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                                             p_imp_loss_impact
                                             , 'N'
                                             , l_adj_in
                                             , px_trans_rec.who_info.last_updated_by
                                             , px_trans_rec.who_info.last_update_date
                                                      , p_log_level_rec => p_log_level_rec) THEN
                   raise fareven_err;
                  RETURN FALSE;
            END IF; */
            END IF;

            -- Bug 6666666 Additioanl Accounting Entries for SORP End
               -- Reset the selection mode back to the original
            l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active;
            l_adj_in.adjustment_type := 'RESERVE';

            IF (x_reval_out.deprn_rsv_adj > 0)
            THEN
               l_adj_in.debit_credit_flag := 'CR';
            ELSE
               l_adj_in.debit_credit_flag := 'DR';
            END IF;

            l_adj_in.adjustment_amount := ABS (x_reval_out.deprn_rsv_adj);
            l_adj_in.ACCOUNT := l_deprn_rsv_acct;
            l_adj_in.account_type := 'DEPRN_RESERVE_ACCT';
            l_adj_in.flush_adj_flag := TRUE;

            IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
               )
            THEN
               IF (p_log_level_rec.statement_level)
               THEN
                  NULL;
               END IF;

               RAISE fareven_err;
            END IF;

            -- Bonus Deprn  YYOON
            IF (x_reval_out.bonus_deprn_rsv_adj <> 0)
            THEN
               l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active;
               l_adj_in.adjustment_type := 'BONUS RESERVE';

               IF (x_reval_out.bonus_deprn_rsv_adj > 0)
               THEN
                  l_adj_in.debit_credit_flag := 'CR';
               ELSE
                  l_adj_in.debit_credit_flag := 'DR';
               END IF;

               l_adj_in.adjustment_amount :=
                                         ABS (x_reval_out.bonus_deprn_rsv_adj);
               l_adj_in.ACCOUNT := l_bonus_deprn_rsv_acct;
               l_adj_in.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
               l_adj_in.flush_adj_flag := TRUE;
               -- The CCID of BONUS EXPENSE row will be generated
               -- through the workflow YYOON
               l_adj_in.gen_ccid_flag := TRUE;

               IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
                  )
               THEN
                  IF (p_log_level_rec.statement_level)
                  THEN
                     NULL;
                  END IF;

                  RAISE fareven_err;
               END IF;
            END IF;

            -- End of Bonus Deprn Change
            IF (x_reval_out.impairment_rsv_adj <> 0)
            THEN
               l_adj_in.selection_mode := fa_adjust_type_pkg.fa_aj_active;
               l_adj_in.adjustment_type := 'IMPAIR RESERVE';

               IF (x_reval_out.impairment_rsv_adj > 0)
               THEN
                  l_adj_in.debit_credit_flag := 'CR';
               ELSE
                  l_adj_in.debit_credit_flag := 'DR';
               END IF;

               l_adj_in.adjustment_amount :=
                                          ABS (x_reval_out.impairment_rsv_adj);
               l_adj_in.ACCOUNT := l_impairment_rsv_acct;
               l_adj_in.account_type := 'IMPAIR_RESERVE_ACCT';
               l_adj_in.flush_adj_flag := TRUE;
               -- The CCID of IMPAIR RESERVE row will be generated
               -- through the workflow
               l_adj_in.gen_ccid_flag := TRUE;

               IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
                  )
               THEN
                  IF (p_log_level_rec.statement_level)
                  THEN
                     NULL;
                  END IF;

                  RAISE fareven_err;
               END IF;

               -- Bug#6666666 SORP START
               -- Below part is byepassed due to reason these are not part of SORP accounting
               IF nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y'
               THEN
                  l_adj_in.adjustment_type := 'REVAL RESERVE';

                  IF (x_reval_out.impairment_rsv_adj > 0)
                  THEN
                     l_adj_in.debit_credit_flag := 'DR';
                  ELSE
                     l_adj_in.debit_credit_flag := 'CR';
                  END IF;

                  l_adj_in.adjustment_amount :=
                                          ABS (x_reval_out.impairment_rsv_adj);
                  l_adj_in.ACCOUNT := l_reval_rsv_acct;
                  l_adj_in.selection_mode :=
                                         fa_adjust_type_pkg.fa_aj_active_reval;
                  l_adj_in.account_type := 'REVAL_RESERVE_ACCT';

                  IF (x_reval_out.impairment_rsv_adj <> 0)
                  THEN
                     IF (NOT fa_ins_adjust_pkg.faxinaj
                                      (l_adj_in,
                                       px_trans_rec.who_info.last_update_date,
                                       px_trans_rec.who_info.last_updated_by,
                                       px_trans_rec.who_info.last_update_login,
                                       p_log_level_rec
                                      )
                        )
                     THEN
                        IF (p_log_level_rec.statement_level)
                        THEN
                           NULL;
                        END IF;

                        RAISE fareven_err;
                     END IF;
                  END IF;
               END IF;
            -- Bug#6666666 SORP END
            END IF;
         END IF;            -- If Cost Adjustment != 0 or new life != old life
      END IF;                             -- If Insert Transaction Flag = TRUE

      <<fareven_exit_noerr>>
      NULL;
      RETURN (TRUE);
   EXCEPTION
      WHEN fareven_err
      THEN
         fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         RETURN FALSE;
      WHEN OTHERS
      THEN
         fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         RETURN FALSE;
   END fareven;
END fa_revaluation_pvt;

/
