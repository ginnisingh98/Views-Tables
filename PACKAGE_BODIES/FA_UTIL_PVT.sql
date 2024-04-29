--------------------------------------------------------
--  DDL for Package Body FA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UTIL_PVT" as
/* $Header: FAVUTILB.pls 120.20.12010000.7 2010/03/04 14:05:24 deemitta ship $   */

FUNCTION get_asset_fin_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_fin_rec        IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_transaction_header_id IN     FA_BOOKS.TRANSACTION_HEADER_ID_IN%TYPE DEFAULT NULL,
    p_mrc_sob_type_code     IN     VARCHAR2
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null
    ) RETURN BOOLEAN IS

  error_found        EXCEPTION;

BEGIN

   if (p_transaction_header_id is null) then
      if (nvl(p_mrc_sob_type_code, 'P') = 'R') then


         select date_placed_in_service        ,
                deprn_start_date              ,
                deprn_method_code             ,
                life_in_months                ,
                rate_adjustment_factor        ,
                adjusted_cost                 ,
                cost                          ,
                original_cost                 ,
                salvage_value                 ,
                prorate_convention_code       ,
                prorate_date                  ,
                cost_change_flag              ,
                adjustment_required_status    ,
                capitalize_flag               ,
                retirement_pending_flag       ,
                depreciate_flag               ,
                disabled_flag                 , /* HH group ed */
                itc_amount_id                 ,
                itc_amount                    ,
                retirement_id                 ,
                tax_request_id                ,
                itc_basis                     ,
                basic_rate                    ,
                adjusted_rate                 ,
                bonus_rule                    ,
                ceiling_name                  ,
                recoverable_cost              ,
                adjusted_capacity             ,
                fully_rsvd_revals_counter     ,
                idled_flag                    ,
                period_counter_capitalized    ,
                period_counter_fully_reserved ,
                period_counter_fully_retired  ,
                production_capacity           ,
                reval_amortization_basis      ,
                reval_ceiling                 ,
                unit_of_measure               ,
                unrevalued_cost               ,
                annual_deprn_rounding_flag    ,
                percent_salvage_value         ,
                allowed_deprn_limit           ,
                allowed_deprn_limit_amount    ,
                period_counter_life_complete  ,
                adjusted_recoverable_cost     ,
                annual_rounding_flag          ,
                eofy_adj_cost                 ,
                eofy_formula_factor           ,
                short_fiscal_year_flag        ,
                conversion_date               ,
                ORIGINAL_DEPRN_START_DATE     ,
                remaining_life1               ,
                remaining_life2               ,
                group_asset_id                ,
                old_adjusted_cost             ,
                formula_factor                ,
                global_attribute1             ,
                global_attribute2             ,
                global_attribute3             ,
                global_attribute4             ,
                global_attribute5             ,
                global_attribute6             ,
                global_attribute7             ,
                global_attribute8             ,
                global_attribute9             ,
                global_attribute10            ,
                global_attribute11            ,
                global_attribute12            ,
                global_attribute13            ,
                global_attribute14            ,
                global_attribute15            ,
                global_attribute16            ,
                global_attribute17            ,
                global_attribute18            ,
                global_attribute19            ,
                global_attribute20            ,
                global_attribute_category     ,
                salvage_type                  ,
                deprn_limit_type              ,
                over_depreciate_option        ,
                super_group_id                ,
                reduction_rate                ,
                reduce_addition_flag          ,
                reduce_adjustment_flag        ,
                reduce_retirement_flag        ,
                recognize_gain_loss           ,
                recapture_reserve_flag        ,
                limit_proceeds_flag           ,
                terminal_gain_loss            ,
                tracking_method               ,
                allocate_to_fully_rsv_flag    ,
                allocate_to_fully_ret_flag    ,
                exclude_fully_rsv_flag        ,
                excess_allocation_option      ,
                depreciation_option           ,
                member_rollup_flag            ,
                ytd_proceeds                  ,
                ltd_proceeds                  ,
                eofy_reserve                  ,
                cip_cost                      ,
                terminal_gain_loss_amount     ,
                ltd_cost_of_removal           ,
                exclude_proceeds_from_basis   ,
                retirement_deprn_option       ,
		contract_id                   ,  /* Bug8240522 */
                cash_generating_unit_id       ,
		rate_in_use                      --phase5 fetching rate_in_use also
           into px_asset_fin_rec.date_placed_in_service        ,
                px_asset_fin_rec.deprn_start_date              ,
                px_asset_fin_rec.deprn_method_code             ,
                px_asset_fin_rec.life_in_months                ,
                px_asset_fin_rec.rate_adjustment_factor        ,
                px_asset_fin_rec.adjusted_cost                 ,
                px_asset_fin_rec.cost                          ,
                px_asset_fin_rec.original_cost                 ,
                px_asset_fin_rec.salvage_value                 ,
                px_asset_fin_rec.prorate_convention_code       ,
                px_asset_fin_rec.prorate_date                  ,
                px_asset_fin_rec.cost_change_flag              ,
                px_asset_fin_rec.adjustment_required_status    ,
                px_asset_fin_rec.capitalize_flag               ,
                px_asset_fin_rec.retirement_pending_flag       ,
                px_asset_fin_rec.depreciate_flag               ,
                px_asset_fin_rec.disabled_flag                 , /* HH group ed */
                px_asset_fin_rec.itc_amount_id                 ,
                px_asset_fin_rec.itc_amount                    ,
                px_asset_fin_rec.retirement_id                 ,
                px_asset_fin_rec.tax_request_id                ,
                px_asset_fin_rec.itc_basis                     ,
                px_asset_fin_rec.basic_rate                    ,
                px_asset_fin_rec.adjusted_rate                 ,
                px_asset_fin_rec.bonus_rule                    ,
                px_asset_fin_rec.ceiling_name                  ,
                px_asset_fin_rec.recoverable_cost              ,
                px_asset_fin_rec.adjusted_capacity             ,
                px_asset_fin_rec.fully_rsvd_revals_counter     ,
                px_asset_fin_rec.idled_flag                    ,
                px_asset_fin_rec.period_counter_capitalized    ,
                px_asset_fin_rec.period_counter_fully_reserved ,
                px_asset_fin_rec.period_counter_fully_retired  ,
                px_asset_fin_rec.production_capacity           ,
                px_asset_fin_rec.reval_amortization_basis      ,
                px_asset_fin_rec.reval_ceiling                 ,
                px_asset_fin_rec.unit_of_measure               ,
                px_asset_fin_rec.unrevalued_cost               ,
                px_asset_fin_rec.annual_deprn_rounding_flag    ,
                px_asset_fin_rec.percent_salvage_value         ,
                px_asset_fin_rec.allowed_deprn_limit           ,
                px_asset_fin_rec.allowed_deprn_limit_amount    ,
                px_asset_fin_rec.period_counter_life_complete  ,
                px_asset_fin_rec.adjusted_recoverable_cost     ,
                px_asset_fin_rec.annual_rounding_flag          ,
                px_asset_fin_rec.eofy_adj_cost                 ,
                px_asset_fin_rec.eofy_formula_factor           ,
                px_asset_fin_rec.short_fiscal_year_flag        ,
                px_asset_fin_rec.conversion_date               ,
                px_asset_fin_rec.orig_deprn_start_date         ,
                px_asset_fin_rec.remaining_life1               ,
                px_asset_fin_rec.remaining_life2               ,
                px_asset_fin_rec.group_asset_id                ,
                px_asset_fin_rec.old_adjusted_cost             ,
                px_asset_fin_rec.formula_factor                ,
                px_asset_fin_rec.global_attribute1            ,
                px_asset_fin_rec.global_attribute2            ,
                px_asset_fin_rec.global_attribute3            ,
                px_asset_fin_rec.global_attribute4            ,
                px_asset_fin_rec.global_attribute5            ,
                px_asset_fin_rec.global_attribute6            ,
                px_asset_fin_rec.global_attribute7            ,
                px_asset_fin_rec.global_attribute8            ,
                px_asset_fin_rec.global_attribute9            ,
                px_asset_fin_rec.global_attribute10           ,
                px_asset_fin_rec.global_attribute11           ,
                px_asset_fin_rec.global_attribute12           ,
                px_asset_fin_rec.global_attribute13           ,
                px_asset_fin_rec.global_attribute14           ,
                px_asset_fin_rec.global_attribute15           ,
                px_asset_fin_rec.global_attribute16           ,
                px_asset_fin_rec.global_attribute17           ,
                px_asset_fin_rec.global_attribute18           ,
                px_asset_fin_rec.global_attribute19           ,
                px_asset_fin_rec.global_attribute20           ,
                px_asset_fin_rec.global_attribute_category    ,
                px_asset_fin_rec.salvage_type                 ,
                px_asset_fin_rec.deprn_limit_type             ,
                px_asset_fin_rec.over_depreciate_option       ,
                px_asset_fin_rec.super_group_id               ,
                px_asset_fin_rec.reduction_rate               ,
                px_asset_fin_rec.reduce_addition_flag         ,
                px_asset_fin_rec.reduce_adjustment_flag       ,
                px_asset_fin_rec.reduce_retirement_flag       ,
                px_asset_fin_rec.recognize_gain_loss          ,
                px_asset_fin_rec.recapture_reserve_flag       ,
                px_asset_fin_rec.limit_proceeds_flag          ,
                px_asset_fin_rec.terminal_gain_loss           ,
                px_asset_fin_rec.tracking_method              ,
                px_asset_fin_rec.allocate_to_fully_rsv_flag   ,
                px_asset_fin_rec.allocate_to_fully_ret_flag   ,
                px_asset_fin_rec.exclude_fully_rsv_flag       ,
                px_asset_fin_rec.excess_allocation_option     ,
                px_asset_fin_rec.depreciation_option          ,
                px_asset_fin_rec.member_rollup_flag           ,
                px_asset_fin_rec.ytd_proceeds                 ,
                px_asset_fin_rec.ltd_proceeds                 ,
                px_asset_fin_rec.eofy_reserve                 ,
                px_asset_fin_rec.cip_cost                     ,
                px_asset_fin_rec.terminal_gain_loss_amount    ,
                px_asset_fin_rec.ltd_cost_of_removal          ,
                px_asset_fin_rec.exclude_proceeds_from_basis  ,
                px_asset_fin_rec.retirement_deprn_option      ,
		px_asset_fin_rec.contract_id                  ,  /* Bug8240522 */
                px_asset_fin_rec.cash_generating_unit_id      ,
		px_asset_fin_rec.rate_in_use                     --phase5
           from fa_mc_books
          where asset_id                         = p_asset_hdr_rec.asset_id
            and book_type_code                   = p_asset_hdr_rec.book_type_code
            and transaction_header_id_out      is null
            and set_of_books_id                  = p_asset_hdr_rec.set_of_books_id;

      else
         select date_placed_in_service        ,
                deprn_start_date              ,
                deprn_method_code             ,
                life_in_months                ,
                rate_adjustment_factor        ,
                adjusted_cost                 ,
                cost                          ,
                original_cost                 ,
                salvage_value                 ,
                prorate_convention_code       ,
                prorate_date                  ,
                cost_change_flag              ,
                adjustment_required_status    ,
                capitalize_flag               ,
                retirement_pending_flag       ,
                depreciate_flag               ,
                disabled_flag                 , /* HH group ed */
                itc_amount_id                 ,
                itc_amount                    ,
                retirement_id                 ,
                tax_request_id                ,
                itc_basis                     ,
                basic_rate                    ,
                adjusted_rate                 ,
                bonus_rule                    ,
                ceiling_name                  ,
                recoverable_cost              ,
                adjusted_capacity             ,
                fully_rsvd_revals_counter     ,
                idled_flag                    ,
                period_counter_capitalized    ,
                period_counter_fully_reserved ,
                period_counter_fully_retired  ,
                production_capacity           ,
                reval_amortization_basis      ,
                reval_ceiling                 ,
                unit_of_measure               ,
                unrevalued_cost               ,
                annual_deprn_rounding_flag    ,
                percent_salvage_value         ,
                allowed_deprn_limit           ,
                allowed_deprn_limit_amount    ,
                period_counter_life_complete  ,
                adjusted_recoverable_cost     ,
                annual_rounding_flag          ,
                eofy_adj_cost                 ,
                eofy_formula_factor           ,
                short_fiscal_year_flag        ,
                conversion_date               ,
                ORIGINAL_DEPRN_START_DATE     ,
                remaining_life1               ,
                remaining_life2               ,
                group_asset_id                ,
                old_adjusted_cost             ,
                formula_factor                ,
                global_attribute1             ,
                global_attribute2             ,
                global_attribute3             ,
                global_attribute4             ,
                global_attribute5             ,
                global_attribute6             ,
                global_attribute7             ,
                global_attribute8             ,
                global_attribute9             ,
                global_attribute10            ,
                global_attribute11            ,
                global_attribute12            ,
                global_attribute13            ,
                global_attribute14            ,
                global_attribute15            ,
                global_attribute16            ,
                global_attribute17            ,
                global_attribute18            ,
                global_attribute19            ,
                global_attribute20            ,
                global_attribute_category     ,
                salvage_type                  ,
                deprn_limit_type              ,
                over_depreciate_option        ,
                super_group_id                ,
                reduction_rate                ,
                reduce_addition_flag          ,
                reduce_adjustment_flag        ,
                reduce_retirement_flag        ,
                recognize_gain_loss           ,
                recapture_reserve_flag        ,
                limit_proceeds_flag           ,
                terminal_gain_loss            ,
                tracking_method               ,
                allocate_to_fully_rsv_flag    ,
                allocate_to_fully_ret_flag    ,
                exclude_fully_rsv_flag        ,
                excess_allocation_option      ,
                depreciation_option           ,
                member_rollup_flag            ,
                ytd_proceeds                  ,
                ltd_proceeds                  ,
                eofy_reserve                  ,
                cip_cost                      ,
                terminal_gain_loss_amount     ,
                ltd_cost_of_removal           ,
                exclude_proceeds_from_basis   ,
                retirement_deprn_option       ,
		contract_id                   ,  /* Bug8240522 */
                cash_generating_unit_id       ,
		extended_deprn_flag           ,   -- Japan Tax phase3
		extended_depreciation_period  ,   -- Japan Tax phase3
		period_counter_fully_extended ,    -- Japan Bug 6645061
		nbv_at_switch		      ,    -- -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
		prior_deprn_limit_type	      ,
		prior_deprn_limit_amount      ,
		prior_deprn_limit	      ,
		prior_deprn_method	      ,
		prior_life_in_months	      ,
		prior_basic_rate	      ,
                prior_adjusted_rate           ,       -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
                rate_in_use                           --phase5
	   into px_asset_fin_rec.date_placed_in_service        ,
                px_asset_fin_rec.deprn_start_date              ,
                px_asset_fin_rec.deprn_method_code             ,
                px_asset_fin_rec.life_in_months                ,
                px_asset_fin_rec.rate_adjustment_factor        ,
                px_asset_fin_rec.adjusted_cost                 ,
                px_asset_fin_rec.cost                          ,
                px_asset_fin_rec.original_cost                 ,
                px_asset_fin_rec.salvage_value                 ,
                px_asset_fin_rec.prorate_convention_code       ,
                px_asset_fin_rec.prorate_date                  ,
                px_asset_fin_rec.cost_change_flag              ,
                px_asset_fin_rec.adjustment_required_status    ,
                px_asset_fin_rec.capitalize_flag               ,
                px_asset_fin_rec.retirement_pending_flag       ,
                px_asset_fin_rec.depreciate_flag               ,
                px_asset_fin_rec.disabled_flag                 , /* HH group ed */
                px_asset_fin_rec.itc_amount_id                 ,
                px_asset_fin_rec.itc_amount                    ,
                px_asset_fin_rec.retirement_id                 ,
                px_asset_fin_rec.tax_request_id                ,
                px_asset_fin_rec.itc_basis                     ,
                px_asset_fin_rec.basic_rate                    ,
                px_asset_fin_rec.adjusted_rate                 ,
                px_asset_fin_rec.bonus_rule                    ,
                px_asset_fin_rec.ceiling_name                  ,
                px_asset_fin_rec.recoverable_cost              ,
                px_asset_fin_rec.adjusted_capacity             ,
                px_asset_fin_rec.fully_rsvd_revals_counter     ,
                px_asset_fin_rec.idled_flag                    ,
                px_asset_fin_rec.period_counter_capitalized    ,
                px_asset_fin_rec.period_counter_fully_reserved ,
                px_asset_fin_rec.period_counter_fully_retired  ,
                px_asset_fin_rec.production_capacity           ,
                px_asset_fin_rec.reval_amortization_basis      ,
                px_asset_fin_rec.reval_ceiling                 ,
                px_asset_fin_rec.unit_of_measure               ,
                px_asset_fin_rec.unrevalued_cost               ,
                px_asset_fin_rec.annual_deprn_rounding_flag    ,
                px_asset_fin_rec.percent_salvage_value         ,
                px_asset_fin_rec.allowed_deprn_limit           ,
                px_asset_fin_rec.allowed_deprn_limit_amount    ,
                px_asset_fin_rec.period_counter_life_complete  ,
                px_asset_fin_rec.adjusted_recoverable_cost     ,
                px_asset_fin_rec.annual_rounding_flag          ,
                px_asset_fin_rec.eofy_adj_cost                 ,
                px_asset_fin_rec.eofy_formula_factor           ,
                px_asset_fin_rec.short_fiscal_year_flag        ,
                px_asset_fin_rec.conversion_date               ,
                px_asset_fin_rec.orig_deprn_start_date         ,
                px_asset_fin_rec.remaining_life1               ,
                px_asset_fin_rec.remaining_life2               ,
                px_asset_fin_rec.group_asset_id                ,
                px_asset_fin_rec.old_adjusted_cost             ,
                px_asset_fin_rec.formula_factor                ,
                px_asset_fin_rec.global_attribute1            ,
                px_asset_fin_rec.global_attribute2            ,
                px_asset_fin_rec.global_attribute3            ,
                px_asset_fin_rec.global_attribute4            ,
                px_asset_fin_rec.global_attribute5            ,
                px_asset_fin_rec.global_attribute6            ,
                px_asset_fin_rec.global_attribute7            ,
                px_asset_fin_rec.global_attribute8            ,
                px_asset_fin_rec.global_attribute9            ,
                px_asset_fin_rec.global_attribute10           ,
                px_asset_fin_rec.global_attribute11           ,
                px_asset_fin_rec.global_attribute12           ,
                px_asset_fin_rec.global_attribute13           ,
                px_asset_fin_rec.global_attribute14           ,
                px_asset_fin_rec.global_attribute15           ,
                px_asset_fin_rec.global_attribute16           ,
                px_asset_fin_rec.global_attribute17           ,
                px_asset_fin_rec.global_attribute18           ,
                px_asset_fin_rec.global_attribute19           ,
                px_asset_fin_rec.global_attribute20           ,
                px_asset_fin_rec.global_attribute_category    ,
                px_asset_fin_rec.salvage_type                 ,
                px_asset_fin_rec.deprn_limit_type             ,
                px_asset_fin_rec.over_depreciate_option       ,
                px_asset_fin_rec.super_group_id               ,
                px_asset_fin_rec.reduction_rate               ,
                px_asset_fin_rec.reduce_addition_flag         ,
                px_asset_fin_rec.reduce_adjustment_flag       ,
                px_asset_fin_rec.reduce_retirement_flag       ,
                px_asset_fin_rec.recognize_gain_loss          ,
                px_asset_fin_rec.recapture_reserve_flag       ,
                px_asset_fin_rec.limit_proceeds_flag          ,
                px_asset_fin_rec.terminal_gain_loss           ,
                px_asset_fin_rec.tracking_method              ,
                px_asset_fin_rec.allocate_to_fully_rsv_flag   ,
                px_asset_fin_rec.allocate_to_fully_ret_flag   ,
                px_asset_fin_rec.exclude_fully_rsv_flag       ,
                px_asset_fin_rec.excess_allocation_option     ,
                px_asset_fin_rec.depreciation_option          ,
                px_asset_fin_rec.member_rollup_flag           ,
                px_asset_fin_rec.ytd_proceeds                 ,
                px_asset_fin_rec.ltd_proceeds                 ,
                px_asset_fin_rec.eofy_reserve                  ,
                px_asset_fin_rec.cip_cost                     ,
                px_asset_fin_rec.terminal_gain_loss_amount    ,
                px_asset_fin_rec.ltd_cost_of_removal          ,
                px_asset_fin_rec.exclude_proceeds_from_basis  ,
                px_asset_fin_rec.retirement_deprn_option      ,
		px_asset_fin_rec.contract_id                  ,  /* Bug8240522 */
                px_asset_fin_rec.cash_generating_unit_id      ,
		px_asset_fin_rec.extended_deprn_flag          ,   -- Japan Tax phase3
		px_asset_fin_rec.extended_depreciation_period ,   -- Japan Tax phase3
                px_asset_fin_rec.period_counter_fully_extended ,   -- Japan Bug 6645061
		px_asset_fin_rec.nbv_at_switch		      ,    -- -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
		px_asset_fin_rec.prior_deprn_limit_type	      ,
		px_asset_fin_rec.prior_deprn_limit_amount      ,
		px_asset_fin_rec.prior_deprn_limit	      ,
		px_asset_fin_rec.prior_deprn_method	      ,
		px_asset_fin_rec.prior_life_in_months	      ,
		px_asset_fin_rec.prior_basic_rate	      ,
                px_asset_fin_rec.prior_adjusted_rate          ,       -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
                px_asset_fin_rec.rate_in_use                          --phase5
	   from fa_books
          where asset_id                         = p_asset_hdr_rec.asset_id
            and book_type_code                   = p_asset_hdr_rec.book_type_code
            and transaction_header_id_out      is null;

       end if;

    else
      if (nvl(p_mrc_sob_type_code, 'P') = 'R') then

         select date_placed_in_service        ,
                deprn_start_date              ,
                deprn_method_code             ,
                life_in_months                ,
                rate_adjustment_factor        ,
                adjusted_cost                 ,
                cost                          ,
                original_cost                 ,
                salvage_value                 ,
                prorate_convention_code       ,
                prorate_date                  ,
                cost_change_flag              ,
                adjustment_required_status    ,
                capitalize_flag               ,
                retirement_pending_flag       ,
                depreciate_flag               ,
                disabled_flag                 , /* HH group ed */
                itc_amount_id                 ,
                itc_amount                    ,
                retirement_id                 ,
                tax_request_id                ,
                itc_basis                     ,
                basic_rate                    ,
                adjusted_rate                 ,
                bonus_rule                    ,
                ceiling_name                  ,
                recoverable_cost              ,
                adjusted_capacity             ,
                fully_rsvd_revals_counter     ,
                idled_flag                    ,
                period_counter_capitalized    ,
                period_counter_fully_reserved ,
                period_counter_fully_retired  ,
                production_capacity           ,
                reval_amortization_basis      ,
                reval_ceiling                 ,
                unit_of_measure               ,
                unrevalued_cost               ,
                annual_deprn_rounding_flag    ,
                percent_salvage_value         ,
                allowed_deprn_limit           ,
                allowed_deprn_limit_amount    ,
                period_counter_life_complete  ,
                adjusted_recoverable_cost     ,
                annual_rounding_flag          ,
                eofy_adj_cost                 ,
                eofy_formula_factor           ,
                short_fiscal_year_flag        ,
                conversion_date               ,
                ORIGINAL_DEPRN_START_DATE     ,
                remaining_life1               ,
                remaining_life2               ,
                group_asset_id                ,
                old_adjusted_cost             ,
                formula_factor                ,
                global_attribute1             ,
                global_attribute2             ,
                global_attribute3             ,
                global_attribute4             ,
                global_attribute5             ,
                global_attribute6             ,
                global_attribute7             ,
                global_attribute8             ,
                global_attribute9             ,
                global_attribute10            ,
                global_attribute11            ,
                global_attribute12            ,
                global_attribute13            ,
                global_attribute14            ,
                global_attribute15            ,
                global_attribute16            ,
                global_attribute17            ,
                global_attribute18            ,
                global_attribute19            ,
                global_attribute20            ,
                global_attribute_category     ,
                salvage_type                  ,
                deprn_limit_type              ,
                over_depreciate_option        ,
                super_group_id                ,
                reduction_rate                ,
                reduce_addition_flag          ,
                reduce_adjustment_flag        ,
                reduce_retirement_flag        ,
                recognize_gain_loss           ,
                recapture_reserve_flag        ,
                limit_proceeds_flag           ,
                terminal_gain_loss            ,
                tracking_method               ,
                allocate_to_fully_rsv_flag    ,
                allocate_to_fully_ret_flag    ,
                exclude_fully_rsv_flag        ,
                excess_allocation_option      ,
                depreciation_option           ,
                member_rollup_flag            ,
                ytd_proceeds                  ,
                ltd_proceeds                  ,
                eofy_reserve                  ,
                cip_cost                      ,
                terminal_gain_loss_amount     ,
                ltd_cost_of_removal           ,
                exclude_proceeds_from_basis   ,
                retirement_deprn_option       ,
		contract_id                   ,  /* Bug8240522 */
                cash_generating_unit_id       ,
		rate_in_use                      --phase5
           into px_asset_fin_rec.date_placed_in_service        ,
                px_asset_fin_rec.deprn_start_date              ,
                px_asset_fin_rec.deprn_method_code             ,
                px_asset_fin_rec.life_in_months                ,
                px_asset_fin_rec.rate_adjustment_factor        ,
                px_asset_fin_rec.adjusted_cost                 ,
                px_asset_fin_rec.cost                          ,
                px_asset_fin_rec.original_cost                 ,
                px_asset_fin_rec.salvage_value                 ,
                px_asset_fin_rec.prorate_convention_code       ,
                px_asset_fin_rec.prorate_date                  ,
                px_asset_fin_rec.cost_change_flag              ,
                px_asset_fin_rec.adjustment_required_status    ,
                px_asset_fin_rec.capitalize_flag               ,
                px_asset_fin_rec.retirement_pending_flag       ,
                px_asset_fin_rec.depreciate_flag               ,
                px_asset_fin_rec.disabled_flag                 , /* HH group ed */
                px_asset_fin_rec.itc_amount_id                 ,
                px_asset_fin_rec.itc_amount                    ,
                px_asset_fin_rec.retirement_id                 ,
                px_asset_fin_rec.tax_request_id                ,
                px_asset_fin_rec.itc_basis                     ,
                px_asset_fin_rec.basic_rate                    ,
                px_asset_fin_rec.adjusted_rate                 ,
                px_asset_fin_rec.bonus_rule                    ,
                px_asset_fin_rec.ceiling_name                  ,
                px_asset_fin_rec.recoverable_cost              ,
                px_asset_fin_rec.adjusted_capacity             ,
                px_asset_fin_rec.fully_rsvd_revals_counter     ,
                px_asset_fin_rec.idled_flag                    ,
                px_asset_fin_rec.period_counter_capitalized    ,
                px_asset_fin_rec.period_counter_fully_reserved ,
                px_asset_fin_rec.period_counter_fully_retired  ,
                px_asset_fin_rec.production_capacity           ,
                px_asset_fin_rec.reval_amortization_basis      ,
                px_asset_fin_rec.reval_ceiling                 ,
                px_asset_fin_rec.unit_of_measure               ,
                px_asset_fin_rec.unrevalued_cost               ,
                px_asset_fin_rec.annual_deprn_rounding_flag    ,
                px_asset_fin_rec.percent_salvage_value         ,
                px_asset_fin_rec.allowed_deprn_limit           ,
                px_asset_fin_rec.allowed_deprn_limit_amount    ,
                px_asset_fin_rec.period_counter_life_complete  ,
                px_asset_fin_rec.adjusted_recoverable_cost     ,
                px_asset_fin_rec.annual_rounding_flag          ,
                px_asset_fin_rec.eofy_adj_cost                 ,
                px_asset_fin_rec.eofy_formula_factor           ,
                px_asset_fin_rec.short_fiscal_year_flag        ,
                px_asset_fin_rec.conversion_date               ,
                px_asset_fin_rec.orig_deprn_start_date         ,
                px_asset_fin_rec.remaining_life1               ,
                px_asset_fin_rec.remaining_life2               ,
                px_asset_fin_rec.group_asset_id                ,
                px_asset_fin_rec.old_adjusted_cost             ,
                px_asset_fin_rec.formula_factor                ,
                px_asset_fin_rec.global_attribute1            ,
                px_asset_fin_rec.global_attribute2            ,
                px_asset_fin_rec.global_attribute3            ,
                px_asset_fin_rec.global_attribute4            ,
                px_asset_fin_rec.global_attribute5            ,
                px_asset_fin_rec.global_attribute6            ,
                px_asset_fin_rec.global_attribute7            ,
                px_asset_fin_rec.global_attribute8            ,
                px_asset_fin_rec.global_attribute9            ,
                px_asset_fin_rec.global_attribute10           ,
                px_asset_fin_rec.global_attribute11           ,
                px_asset_fin_rec.global_attribute12           ,
                px_asset_fin_rec.global_attribute13           ,
                px_asset_fin_rec.global_attribute14           ,
                px_asset_fin_rec.global_attribute15           ,
                px_asset_fin_rec.global_attribute16           ,
                px_asset_fin_rec.global_attribute17           ,
                px_asset_fin_rec.global_attribute18           ,
                px_asset_fin_rec.global_attribute19           ,
                px_asset_fin_rec.global_attribute20           ,
                px_asset_fin_rec.global_attribute_category    ,
                px_asset_fin_rec.salvage_type                 ,
                px_asset_fin_rec.deprn_limit_type             ,
                px_asset_fin_rec.over_depreciate_option       ,
                px_asset_fin_rec.super_group_id               ,
                px_asset_fin_rec.reduction_rate               ,
                px_asset_fin_rec.reduce_addition_flag         ,
                px_asset_fin_rec.reduce_adjustment_flag       ,
                px_asset_fin_rec.reduce_retirement_flag       ,
                px_asset_fin_rec.recognize_gain_loss          ,
                px_asset_fin_rec.recapture_reserve_flag       ,
                px_asset_fin_rec.limit_proceeds_flag          ,
                px_asset_fin_rec.terminal_gain_loss           ,
                px_asset_fin_rec.tracking_method              ,
                px_asset_fin_rec.allocate_to_fully_rsv_flag   ,
                px_asset_fin_rec.allocate_to_fully_ret_flag   ,
                px_asset_fin_rec.exclude_fully_rsv_flag       ,
                px_asset_fin_rec.excess_allocation_option     ,
                px_asset_fin_rec.depreciation_option          ,
                px_asset_fin_rec.member_rollup_flag           ,
                px_asset_fin_rec.ytd_proceeds                 ,
                px_asset_fin_rec.ltd_proceeds                 ,
                px_asset_fin_rec.eofy_reserve                 ,
                px_asset_fin_rec.cip_cost                     ,
                px_asset_fin_rec.terminal_gain_loss_amount    ,
                px_asset_fin_rec.ltd_cost_of_removal          ,
                px_asset_fin_rec.exclude_proceeds_from_basis  ,
                px_asset_fin_rec.retirement_deprn_option      ,
		px_asset_fin_rec.contract_id                  ,  /* Bug8240522 */
                px_asset_fin_rec.cash_generating_unit_id      ,
		px_asset_fin_rec.rate_in_use                     --phase5
           from fa_mc_books
          where asset_id                         = p_asset_hdr_rec.asset_id
            and book_type_code                   = p_asset_hdr_rec.book_type_code
            and transaction_header_id_in         = p_transaction_header_id
            and set_of_books_id                  = p_asset_hdr_rec.set_of_books_id;
      else
         select date_placed_in_service        ,
                deprn_start_date              ,
                deprn_method_code             ,
                life_in_months                ,
                rate_adjustment_factor        ,
                adjusted_cost                 ,
                cost                          ,
                original_cost                 ,
                salvage_value                 ,
                prorate_convention_code       ,
                prorate_date                  ,
                cost_change_flag              ,
                adjustment_required_status    ,
                capitalize_flag               ,
                retirement_pending_flag       ,
                depreciate_flag               ,
                disabled_flag                 , /* HH group ed */
                itc_amount_id                 ,
                itc_amount                    ,
                retirement_id                 ,
                tax_request_id                ,
                itc_basis                     ,
                basic_rate                    ,
                adjusted_rate                 ,
                bonus_rule                    ,
                ceiling_name                  ,
                recoverable_cost              ,
                adjusted_capacity             ,
                fully_rsvd_revals_counter     ,
                idled_flag                    ,
                period_counter_capitalized    ,
                period_counter_fully_reserved ,
                period_counter_fully_retired  ,
                production_capacity           ,
                reval_amortization_basis      ,
                reval_ceiling                 ,
                unit_of_measure               ,
                unrevalued_cost               ,
                annual_deprn_rounding_flag    ,
                percent_salvage_value         ,
                allowed_deprn_limit           ,
                allowed_deprn_limit_amount    ,
                period_counter_life_complete  ,
                adjusted_recoverable_cost     ,
                annual_rounding_flag          ,
                eofy_adj_cost                 ,
                eofy_formula_factor           ,
                short_fiscal_year_flag        ,
                conversion_date               ,
                ORIGINAL_DEPRN_START_DATE     ,
                remaining_life1               ,
                remaining_life2               ,
                group_asset_id                ,
                old_adjusted_cost             ,
                formula_factor                ,
                global_attribute1             ,
                global_attribute2             ,
                global_attribute3             ,
                global_attribute4             ,
                global_attribute5             ,
                global_attribute6             ,
                global_attribute7             ,
                global_attribute8             ,
                global_attribute9             ,
                global_attribute10            ,
                global_attribute11            ,
                global_attribute12            ,
                global_attribute13            ,
                global_attribute14            ,
                global_attribute15            ,
                global_attribute16            ,
                global_attribute17            ,
                global_attribute18            ,
                global_attribute19            ,
                global_attribute20            ,
                global_attribute_category     ,
                salvage_type                  ,
                deprn_limit_type              ,
                over_depreciate_option        ,
                super_group_id                ,
                reduction_rate                ,
                reduce_addition_flag          ,
                reduce_adjustment_flag        ,
                reduce_retirement_flag        ,
                recognize_gain_loss           ,
                recapture_reserve_flag        ,
                limit_proceeds_flag           ,
                terminal_gain_loss            ,
                tracking_method               ,
                allocate_to_fully_rsv_flag    ,
                allocate_to_fully_ret_flag    ,
                exclude_fully_rsv_flag        ,
                excess_allocation_option      ,
                depreciation_option           ,
                member_rollup_flag            ,
                ytd_proceeds                  ,
                ltd_proceeds                  ,
                eofy_reserve                  ,
                cip_cost                      ,
                terminal_gain_loss_amount     ,
                ltd_cost_of_removal           ,
                exclude_proceeds_from_basis   ,
                retirement_deprn_option       ,
		contract_id                   ,  /* Bug8240522 */
                cash_generating_unit_id       ,
		extended_deprn_flag           ,   -- Japan Tax phase3
		extended_depreciation_period  ,   -- Japan Tax phase3
                period_counter_fully_extended     -- Japan Bug 6645061
                period_counter_fully_extended ,    -- Japan Bug 6645061
		nbv_at_switch		      ,    -- -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
		prior_deprn_limit_type	      ,
		prior_deprn_limit_amount      ,
		prior_deprn_limit	      ,
		prior_deprn_method	      ,
		prior_life_in_months	      ,
		prior_basic_rate	      ,
                prior_adjusted_rate           ,      -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
                rate_in_use                          -- phase5
	   into px_asset_fin_rec.date_placed_in_service        ,
                px_asset_fin_rec.deprn_start_date              ,
                px_asset_fin_rec.deprn_method_code             ,
                px_asset_fin_rec.life_in_months                ,
                px_asset_fin_rec.rate_adjustment_factor        ,
                px_asset_fin_rec.adjusted_cost                 ,
                px_asset_fin_rec.cost                          ,
                px_asset_fin_rec.original_cost                 ,
                px_asset_fin_rec.salvage_value                 ,
                px_asset_fin_rec.prorate_convention_code       ,
                px_asset_fin_rec.prorate_date                  ,
                px_asset_fin_rec.cost_change_flag              ,
                px_asset_fin_rec.adjustment_required_status    ,
                px_asset_fin_rec.capitalize_flag               ,
                px_asset_fin_rec.retirement_pending_flag       ,
                px_asset_fin_rec.depreciate_flag               ,
                px_asset_fin_rec.disabled_flag                 , /* HH group ed */
                px_asset_fin_rec.itc_amount_id                 ,
                px_asset_fin_rec.itc_amount                    ,
                px_asset_fin_rec.retirement_id                 ,
                px_asset_fin_rec.tax_request_id                ,
                px_asset_fin_rec.itc_basis                     ,
                px_asset_fin_rec.basic_rate                    ,
                px_asset_fin_rec.adjusted_rate                 ,
                px_asset_fin_rec.bonus_rule                    ,
                px_asset_fin_rec.ceiling_name                  ,
                px_asset_fin_rec.recoverable_cost              ,
                px_asset_fin_rec.adjusted_capacity             ,
                px_asset_fin_rec.fully_rsvd_revals_counter     ,
                px_asset_fin_rec.idled_flag                    ,
                px_asset_fin_rec.period_counter_capitalized    ,
                px_asset_fin_rec.period_counter_fully_reserved ,
                px_asset_fin_rec.period_counter_fully_retired  ,
                px_asset_fin_rec.production_capacity           ,
                px_asset_fin_rec.reval_amortization_basis      ,
                px_asset_fin_rec.reval_ceiling                 ,
                px_asset_fin_rec.unit_of_measure               ,
                px_asset_fin_rec.unrevalued_cost               ,
                px_asset_fin_rec.annual_deprn_rounding_flag    ,
                px_asset_fin_rec.percent_salvage_value         ,
                px_asset_fin_rec.allowed_deprn_limit           ,
                px_asset_fin_rec.allowed_deprn_limit_amount    ,
                px_asset_fin_rec.period_counter_life_complete  ,
                px_asset_fin_rec.adjusted_recoverable_cost     ,
                px_asset_fin_rec.annual_rounding_flag          ,
                px_asset_fin_rec.eofy_adj_cost                 ,
                px_asset_fin_rec.eofy_formula_factor           ,
                px_asset_fin_rec.short_fiscal_year_flag        ,
                px_asset_fin_rec.conversion_date               ,
                px_asset_fin_rec.orig_deprn_start_date         ,
                px_asset_fin_rec.remaining_life1               ,
                px_asset_fin_rec.remaining_life2               ,
                px_asset_fin_rec.group_asset_id                ,
                px_asset_fin_rec.old_adjusted_cost             ,
                px_asset_fin_rec.formula_factor                ,
                px_asset_fin_rec.global_attribute1            ,
                px_asset_fin_rec.global_attribute2            ,
                px_asset_fin_rec.global_attribute3            ,
                px_asset_fin_rec.global_attribute4            ,
                px_asset_fin_rec.global_attribute5            ,
                px_asset_fin_rec.global_attribute6            ,
                px_asset_fin_rec.global_attribute7            ,
                px_asset_fin_rec.global_attribute8            ,
                px_asset_fin_rec.global_attribute9            ,
                px_asset_fin_rec.global_attribute10           ,
                px_asset_fin_rec.global_attribute11           ,
                px_asset_fin_rec.global_attribute12           ,
                px_asset_fin_rec.global_attribute13           ,
                px_asset_fin_rec.global_attribute14           ,
                px_asset_fin_rec.global_attribute15           ,
                px_asset_fin_rec.global_attribute16           ,
                px_asset_fin_rec.global_attribute17           ,
                px_asset_fin_rec.global_attribute18           ,
                px_asset_fin_rec.global_attribute19           ,
                px_asset_fin_rec.global_attribute20           ,
                px_asset_fin_rec.global_attribute_category    ,
                px_asset_fin_rec.salvage_type                 ,
                px_asset_fin_rec.deprn_limit_type             ,
                px_asset_fin_rec.over_depreciate_option       ,
                px_asset_fin_rec.super_group_id               ,
                px_asset_fin_rec.reduction_rate               ,
                px_asset_fin_rec.reduce_addition_flag         ,
                px_asset_fin_rec.reduce_adjustment_flag       ,
                px_asset_fin_rec.reduce_retirement_flag       ,
                px_asset_fin_rec.recognize_gain_loss          ,
                px_asset_fin_rec.recapture_reserve_flag       ,
                px_asset_fin_rec.limit_proceeds_flag          ,
                px_asset_fin_rec.terminal_gain_loss           ,
                px_asset_fin_rec.tracking_method              ,
                px_asset_fin_rec.allocate_to_fully_rsv_flag   ,
                px_asset_fin_rec.allocate_to_fully_ret_flag   ,
                px_asset_fin_rec.exclude_fully_rsv_flag       ,
                px_asset_fin_rec.excess_allocation_option     ,
                px_asset_fin_rec.depreciation_option          ,
                px_asset_fin_rec.member_rollup_flag           ,
                px_asset_fin_rec.ytd_proceeds                 ,
                px_asset_fin_rec.ltd_proceeds                 ,
                px_asset_fin_rec.eofy_reserve                 ,
                px_asset_fin_rec.cip_cost                     ,
                px_asset_fin_rec.terminal_gain_loss_amount    ,
                px_asset_fin_rec.ltd_cost_of_removal          ,
                px_asset_fin_rec.exclude_proceeds_from_basis  ,
                px_asset_fin_rec.retirement_deprn_option      ,
		px_asset_fin_rec.contract_id                  ,  /* Bug8240522 */
                px_asset_fin_rec.cash_generating_unit_id      ,
		px_asset_fin_rec.extended_deprn_flag          ,   -- Japan Tax phase3
		px_asset_fin_rec.extended_depreciation_period ,   -- Japan Tax phase3
                px_asset_fin_rec.period_counter_fully_extended ,   -- Japan Bug 6645061
		px_asset_fin_rec.nbv_at_switch		      ,   -- -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
		px_asset_fin_rec.prior_deprn_limit_type	      ,
		px_asset_fin_rec.prior_deprn_limit_amount      ,
		px_asset_fin_rec.prior_deprn_limit	      ,
		px_asset_fin_rec.prior_deprn_method	      ,
		px_asset_fin_rec.prior_life_in_months	      ,
		px_asset_fin_rec.prior_basic_rate	      ,
                px_asset_fin_rec.prior_adjusted_rate          ,        -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
                px_asset_fin_rec.rate_in_use                           --phase5
	   from fa_books
          where asset_id                         = p_asset_hdr_rec.asset_id
            and book_type_code                   = p_asset_hdr_rec.book_type_code
            and transaction_header_id_in         = p_transaction_header_id;

       end if;


    end if; --(p_transaction_header_id is null)

    return true;

EXCEPTION
  when error_found then
     fa_srvr_msg.add_message(calling_fn => 'fa_util_pvt.get_asset_fin_rec', p_log_level_rec => p_log_level_rec);
     return false;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_asset_fin_rec', p_log_level_rec => p_log_level_rec);
     return false;

END get_asset_fin_rec;


FUNCTION get_asset_deprn_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_deprn_rec      IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_counter        IN     FA_DEPRN_SUMMARY.period_counter%TYPE DEFAULT NULL,
    p_mrc_sob_type_code     IN     VARCHAR2
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null
    ) RETURN BOOLEAN IS

   l_dpr         FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
   l_status      BOOLEAN;
   error_found   EXCEPTION;

BEGIN

   l_dpr.asset_id   := p_asset_hdr_rec.asset_id;
   l_dpr.book       := p_asset_hdr_rec.book_type_code;
   l_dpr.period_ctr := nvl(p_period_counter, 0);
   l_dpr.dist_id    := 0;
   l_dpr.mrc_sob_type_code := p_mrc_sob_type_code;
   l_dpr.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

   fa_query_balances_pkg.query_balances_int(
                           X_DPR_ROW               => l_dpr,
                           X_RUN_MODE              => 'STANDARD',
                           X_DEBUG                 => FALSE,
                           X_SUCCESS               => l_status,
                           X_CALLING_FN            => 'FA_UTIL_PVT.get_asset_deprn_rec',
                           X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

   if (NOT l_status) then
      raise error_found;
   end if;

   px_asset_deprn_rec.deprn_amount             := l_dpr.deprn_exp  ;
   px_asset_deprn_rec.ytd_deprn                := l_dpr.ytd_deprn  ;
   px_asset_deprn_rec.deprn_reserve            := l_dpr.deprn_rsv  ;
   px_asset_deprn_rec.prior_fy_expense         := l_dpr.prior_fy_exp  ;
   px_asset_deprn_rec.bonus_deprn_amount       := l_dpr.bonus_deprn_amount  ;
   px_asset_deprn_rec.bonus_ytd_deprn          := l_dpr.bonus_ytd_deprn  ;
   px_asset_deprn_rec.bonus_deprn_reserve      := l_dpr.bonus_deprn_rsv  ;
   px_asset_deprn_rec.prior_fy_bonus_expense   := l_dpr.prior_fy_bonus_exp  ;
   px_asset_deprn_rec.reval_amortization       := l_dpr.reval_amo  ;
   px_asset_deprn_rec.reval_amortization_basis := l_dpr.reval_amo_basis  ;
   px_asset_deprn_rec.reval_deprn_expense      := l_dpr.reval_deprn_exp  ;
   px_asset_deprn_rec.reval_ytd_deprn          := l_dpr.ytd_reval_deprn_exp  ;
   px_asset_deprn_rec.reval_deprn_reserve      := l_dpr.reval_rsv  ;
   px_asset_deprn_rec.production               := l_dpr.prod  ;
   px_asset_deprn_rec.ytd_production           := l_dpr.ytd_prod  ;
   px_asset_deprn_rec.ltd_production           := l_dpr.ltd_prod  ;
   px_asset_deprn_rec.impairment_reserve           := l_dpr.impairment_rsv;
   px_asset_deprn_rec.ytd_impairment           := l_dpr.ytd_impairment;
   px_asset_deprn_rec.impairment_amount        := l_dpr.impairment_amount;


   return true;

EXCEPTION
  when error_found then
     fa_srvr_msg.add_message(calling_fn => 'fa_util_pvt.get_asset_deprn_rec', p_log_level_rec => p_log_level_rec);
     return false;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_asset_deprn_rec', p_log_level_rec => p_log_level_rec);
     return false;

END get_asset_deprn_rec;



FUNCTION get_asset_cat_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_cat_rec        IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
    p_date_effective        IN     FA_ASSET_HISTORY.date_effective%TYPE DEFAULT NULL
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
    ) RETURN BOOLEAN IS

   l_asset_category_id   FA_ADDITIONS.asset_category_id%TYPE;

BEGIN

    select ah.category_id,
           ad.asset_category_id,
           ad.ATTRIBUTE1 ,
           ad.ATTRIBUTE2 ,
           ad.ATTRIBUTE3 ,
           ad.ATTRIBUTE4 ,
           ad.ATTRIBUTE5 ,
           ad.ATTRIBUTE6 ,
           ad.ATTRIBUTE7 ,
           ad.ATTRIBUTE8 ,
           ad.ATTRIBUTE9 ,
           ad.ATTRIBUTE10,
           ad.ATTRIBUTE11,
           ad.ATTRIBUTE12,
           ad.ATTRIBUTE13,
           ad.ATTRIBUTE14,
           ad.ATTRIBUTE15,
           ad.ATTRIBUTE16,
           ad.ATTRIBUTE17,
           ad.ATTRIBUTE18,
           ad.ATTRIBUTE19,
           ad.ATTRIBUTE20,
           ad.ATTRIBUTE21,
           ad.ATTRIBUTE22,
           ad.ATTRIBUTE23,
           ad.ATTRIBUTE24,
           ad.ATTRIBUTE25,
           ad.ATTRIBUTE26,
           ad.ATTRIBUTE27,
           ad.ATTRIBUTE28,
           ad.ATTRIBUTE29,
           ad.ATTRIBUTE30,
           ad.ATTRIBUTE_CATEGORY_CODE,
           ad.CONTEXT
      into px_asset_cat_rec.category_id,
           l_asset_category_id,
           px_asset_cat_rec.desc_flex.attribute1,
           px_asset_cat_rec.desc_flex.attribute2,
           px_asset_cat_rec.desc_flex.attribute3,
           px_asset_cat_rec.desc_flex.attribute4,
           px_asset_cat_rec.desc_flex.attribute5,
           px_asset_cat_rec.desc_flex.attribute6,
           px_asset_cat_rec.desc_flex.attribute7,
           px_asset_cat_rec.desc_flex.attribute8,
           px_asset_cat_rec.desc_flex.attribute9,
           px_asset_cat_rec.desc_flex.attribute10,
           px_asset_cat_rec.desc_flex.attribute11,
           px_asset_cat_rec.desc_flex.attribute12,
           px_asset_cat_rec.desc_flex.attribute13,
           px_asset_cat_rec.desc_flex.attribute14,
           px_asset_cat_rec.desc_flex.attribute15,
           px_asset_cat_rec.desc_flex.attribute16,
           px_asset_cat_rec.desc_flex.attribute17,
           px_asset_cat_rec.desc_flex.attribute18,
           px_asset_cat_rec.desc_flex.attribute19,
           px_asset_cat_rec.desc_flex.attribute20,
           px_asset_cat_rec.desc_flex.attribute21,
           px_asset_cat_rec.desc_flex.attribute22,
           px_asset_cat_rec.desc_flex.attribute23,
           px_asset_cat_rec.desc_flex.attribute24,
           px_asset_cat_rec.desc_flex.attribute25,
           px_asset_cat_rec.desc_flex.attribute26,
           px_asset_cat_rec.desc_flex.attribute27,
           px_asset_cat_rec.desc_flex.attribute28,
           px_asset_cat_rec.desc_flex.attribute29,
           px_asset_cat_rec.desc_flex.attribute30,
           px_asset_cat_rec.desc_flex.attribute_category_code,
           px_asset_cat_rec.desc_flex.context
     from fa_additions_b   ad,
          fa_asset_history ah
    where ad.asset_id = p_asset_hdr_rec.asset_id
      and ad.asset_id = ah.asset_id
      and ((p_date_effective is null and
            ah.date_ineffective is null) or
           (p_date_effective is not null and
            p_date_effective between
                ah.date_effective and nvl(ah.date_ineffective, sysdate)));

    /*  null out the descriptive flex if the asset was reclassed out
     *  of the category being returned
     */
    if (px_asset_cat_rec.category_id <> l_asset_category_id) then
        px_asset_cat_rec.desc_flex := NULL;
    end if;


    return true;

EXCEPTION
  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_asset_cat_rec', p_log_level_rec => p_log_level_rec);
     return false;

END get_asset_cat_rec;



FUNCTION get_asset_type_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_type_rec       IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
    p_date_effective        IN     FA_ASSET_HISTORY.date_effective%TYPE DEFAULT NULL
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
    ) RETURN BOOLEAN IS

BEGIN

   select ah.asset_type
     into px_asset_type_rec.asset_type
     from fa_additions_b   ad,
          fa_asset_history ah
    where ad.asset_id = p_asset_hdr_rec.asset_id
      and ad.asset_id = ah.asset_id
      and (ah.date_effective =  nvl(p_date_effective, to_date('01/01/0001', 'DD/MM/YYYY')) or
           ah.date_ineffective is null);


   return true;

EXCEPTION
  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_asset_type_rec', p_log_level_rec => p_log_level_rec);
     return false;

END get_asset_type_rec;


FUNCTION get_asset_desc_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_desc_rec        IN OUT NOCOPY FA_API_TYPES.asset_desc_rec_type
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   select asset_number         ,
          description          ,
          tag_number           ,
          serial_number        ,
          asset_key_ccid       ,
          parent_asset_id      ,
          attribute15          , -- status               ,
          manufacturer_name    ,
          model_number         ,
          null                 , -- warranty_number      ,
          lease_id             ,
          in_use_flag          ,
          inventorial          ,
          property_type_code   ,
          property_1245_1250_code  ,
          owned_leased         ,
          new_used             ,
          current_units        ,
          unit_adjustment_flag ,
          add_cost_je_flag     ,
          null, -- ls_attribute1        ,
          null, -- ls_attribute2        ,
          null, -- ls_attribute3        ,
          null, -- ls_attribute4        ,
          null, -- ls_attribute5        ,
          null, -- ls_attribute6        ,
          null, -- ls_attribute7        ,
          null, -- ls_attribute8        ,
          null, -- ls_attribute9        ,
          null, -- ls_attribute10       ,
          null, -- ls_attribute11       ,
          null, -- ls_attribute12       ,
          null, -- ls_attribute13       ,
          null, -- ls_attribute14       ,
          null, -- ls_attribute15       ,
          null, -- ls_attribute_category_code,
          global_attribute1    ,
          global_attribute2    ,
          global_attribute3    ,
          global_attribute4    ,
          global_attribute5    ,
          global_attribute6    ,
          global_attribute7    ,
          global_attribute8    ,
          global_attribute9    ,
          global_attribute10   ,
          global_attribute11   ,
          global_attribute12   ,
          global_attribute13   ,
          global_attribute14   ,
          global_attribute15   ,
          global_attribute16   ,
          global_attribute17   ,
          global_attribute18   ,
          global_attribute19   ,
          global_attribute20   ,
          global_attribute_category
     into px_asset_desc_rec.asset_number         ,
          px_asset_desc_rec.description          ,
          px_asset_desc_rec.tag_number           ,
          px_asset_desc_rec.serial_number        ,
          px_asset_desc_rec.asset_key_ccid       ,
          px_asset_desc_rec.parent_asset_id      ,
          px_asset_desc_rec.status               ,
          px_asset_desc_rec.manufacturer_name    ,
          px_asset_desc_rec.model_number         ,
          px_asset_desc_rec.warranty_id          ,
          px_asset_desc_rec.lease_id             ,
          px_asset_desc_rec.in_use_flag          ,
          px_asset_desc_rec.inventorial          ,
          px_asset_desc_rec.property_type_code   ,
          px_asset_desc_rec.property_1245_1250_code,
          px_asset_desc_rec.owned_leased         ,
          px_asset_desc_rec.new_used             ,
          px_asset_desc_rec.current_units        ,
          px_asset_desc_rec.unit_adjustment_flag ,
          px_asset_desc_rec.add_cost_je_flag     ,
          px_asset_desc_rec.lease_desc_flex.attribute1,
          px_asset_desc_rec.lease_desc_flex.attribute2,
          px_asset_desc_rec.lease_desc_flex.attribute3,
          px_asset_desc_rec.lease_desc_flex.attribute4,
          px_asset_desc_rec.lease_desc_flex.attribute5,
          px_asset_desc_rec.lease_desc_flex.attribute6,
          px_asset_desc_rec.lease_desc_flex.attribute7,
          px_asset_desc_rec.lease_desc_flex.attribute8,
          px_asset_desc_rec.lease_desc_flex.attribute9,
          px_asset_desc_rec.lease_desc_flex.attribute10,
          px_asset_desc_rec.lease_desc_flex.attribute11,
          px_asset_desc_rec.lease_desc_flex.attribute12,
          px_asset_desc_rec.lease_desc_flex.attribute13,
          px_asset_desc_rec.lease_desc_flex.attribute14,
          px_asset_desc_rec.lease_desc_flex.attribute15,
          px_asset_desc_rec.lease_desc_flex.attribute_category_code,
          px_asset_desc_rec.global_desc_flex.attribute1,
          px_asset_desc_rec.global_desc_flex.attribute2,
          px_asset_desc_rec.global_desc_flex.attribute3,
          px_asset_desc_rec.global_desc_flex.attribute4,
          px_asset_desc_rec.global_desc_flex.attribute5,
          px_asset_desc_rec.global_desc_flex.attribute6,
          px_asset_desc_rec.global_desc_flex.attribute7,
          px_asset_desc_rec.global_desc_flex.attribute8,
          px_asset_desc_rec.global_desc_flex.attribute9,
          px_asset_desc_rec.global_desc_flex.attribute10,
          px_asset_desc_rec.global_desc_flex.attribute11,
          px_asset_desc_rec.global_desc_flex.attribute12,
          px_asset_desc_rec.global_desc_flex.attribute13,
          px_asset_desc_rec.global_desc_flex.attribute14,
          px_asset_desc_rec.global_desc_flex.attribute15,
          px_asset_desc_rec.global_desc_flex.attribute16,
          px_asset_desc_rec.global_desc_flex.attribute17,
          px_asset_desc_rec.global_desc_flex.attribute18,
          px_asset_desc_rec.global_desc_flex.attribute19,
          px_asset_desc_rec.global_desc_flex.attribute20,
          px_asset_desc_rec.global_desc_flex.attribute_category_code
     from fa_additions_vl
    where asset_id = p_asset_hdr_rec.asset_id;

    -- Get lease since its not in the view
    begin
       if (px_asset_desc_rec.lease_id is not null) then
          select attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute_category_code
            into px_asset_desc_rec.lease_desc_flex.attribute1,
                 px_asset_desc_rec.lease_desc_flex.attribute2,
                 px_asset_desc_rec.lease_desc_flex.attribute3,
                 px_asset_desc_rec.lease_desc_flex.attribute4,
                 px_asset_desc_rec.lease_desc_flex.attribute5,
                 px_asset_desc_rec.lease_desc_flex.attribute6,
                 px_asset_desc_rec.lease_desc_flex.attribute7,
                 px_asset_desc_rec.lease_desc_flex.attribute8,
                 px_asset_desc_rec.lease_desc_flex.attribute9,
                 px_asset_desc_rec.lease_desc_flex.attribute10,
                 px_asset_desc_rec.lease_desc_flex.attribute11,
                 px_asset_desc_rec.lease_desc_flex.attribute12,
                 px_asset_desc_rec.lease_desc_flex.attribute13,
                 px_asset_desc_rec.lease_desc_flex.attribute14,
                 px_asset_desc_rec.lease_desc_flex.attribute15,
                 px_asset_desc_rec.lease_desc_flex.attribute_category_code
            from fa_leases
           where lease_id = px_asset_desc_rec.lease_id;
       end if;

    exception
       when no_data_found then null;
       when others then
          fa_srvr_msg.add_sql_error (
             calling_fn => 'fa_util_pvt.get_asset_desc_rec', p_log_level_rec => p_log_level_rec);
          return false;
    end;

    -- Get warranty_id since it's not in the view
    begin
       select warranty_id
       into   px_asset_desc_rec.warranty_id
       from   fa_add_warranties
       where  asset_id = p_asset_hdr_rec.asset_id
       and    date_ineffective is NULL;
    exception
       when no_data_found then
          px_asset_desc_rec.warranty_id := NULL;
       when others then
          fa_srvr_msg.add_sql_error (
             calling_fn => 'fa_util_pvt.get_asset_desc_rec', p_log_level_rec => p_log_level_rec);
          return false;
    end;

    return true;
EXCEPTION
  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_asset_desc_rec', p_log_level_rec => p_log_level_rec);
     return false;

END get_asset_desc_rec;


FUNCTION get_inv_rec
   (px_inv_rec              IN OUT NOCOPY FA_API_TYPES.inv_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2,
    p_set_of_books_id       IN     NUMBER,
    p_inv_trans_rec         IN     FA_API_TYPES.inv_trans_rec_type DEFAULT NULL
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  error_found        EXCEPTION;

BEGIN

   if (nvl(p_inv_trans_rec.transaction_type, 'X') = 'REINSTATEMENT') then
      if (p_mrc_sob_type_code = 'R') then

          select Po_Vendor_Id                   ,
                 Asset_Invoice_Id               ,
                 Fixed_Assets_Cost              , --
                 Deleted_Flag                   , --
                 Po_Number                      ,
                 Invoice_Number                 ,
                 Payables_Batch_Name            ,
                 Payables_Code_Combination_Id   ,
                 Feeder_System_Name             ,
                 Create_Batch_Date              ,
                 Create_Batch_Id                ,
                 Invoice_Date                   ,
                 Payables_Cost                  , --
                 Post_Batch_Id                  ,
                 Invoice_Id                     ,
                 Ap_Distribution_Line_Number    ,
                 Payables_Units                 ,
                 Split_Merged_Code              ,
                 Description                    ,
                 Parent_Mass_Addition_Id        ,
                 Attribute1                     ,
                 Attribute2                     ,
                 Attribute3                     ,
                 Attribute4                     ,
                 Attribute5                     ,
                 Attribute6                     ,
                 Attribute7                     ,
                 Attribute8                     ,
                 Attribute9                     ,
                 Attribute10                    ,
                 Attribute11                    ,
                 Attribute12                    ,
                 Attribute13                    ,
                 Attribute14                    ,
                 Attribute15                    ,
                 Attribute_Category_Code        ,
                 Unrevalued_Cost                , --
                 Merged_Code                    ,
                 Split_Code                     ,
                 Merge_Parent_Mass_Additions_Id ,
                 Split_Parent_Mass_Additions_Id ,
                 Project_Asset_Line_Id          ,
                 Project_Id                     ,
                 Task_Id                        ,
                 Depreciate_In_Group_Flag       ,
                 Material_Indicator_Flag        ,
                 NULL                           ,
                 Invoice_Distribution_id        ,
                 Invoice_Line_Number            ,
                 PO_Distribution_Id
            into px_inv_rec.Po_Vendor_Id                   ,
                 px_inv_rec.Asset_Invoice_Id               ,
                 px_inv_rec.Fixed_Assets_Cost              ,
                 px_inv_rec.Deleted_Flag                   ,
                 px_inv_rec.Po_Number                      ,
                 px_inv_rec.Invoice_Number                 ,
                 px_inv_rec.Payables_Batch_Name            ,
                 px_inv_rec.Payables_Code_Combination_Id   ,
                 px_inv_rec.Feeder_System_Name             ,
                 px_inv_rec.Create_Batch_Date              ,
                 px_inv_rec.Create_Batch_Id                ,
                 px_inv_rec.Invoice_Date                   ,
                 px_inv_rec.Payables_Cost                  ,
                 px_inv_rec.Post_Batch_Id                  ,
                 px_inv_rec.Invoice_Id                     ,
                 px_inv_rec.Ap_Distribution_Line_Number    ,
                 px_inv_rec.Payables_Units                 ,
                 px_inv_rec.Split_Merged_Code              ,
                 px_inv_rec.Description                    ,
                 px_inv_rec.Parent_Mass_Addition_Id        ,
                 px_inv_rec.Attribute1                     ,
                 px_inv_rec.Attribute2                     ,
                 px_inv_rec.Attribute3                     ,
                 px_inv_rec.Attribute4                     ,
                 px_inv_rec.Attribute5                     ,
                 px_inv_rec.Attribute6                     ,
                 px_inv_rec.Attribute7                     ,
                 px_inv_rec.Attribute8                     ,
                 px_inv_rec.Attribute9                     ,
                 px_inv_rec.Attribute10                    ,
                 px_inv_rec.Attribute11                    ,
                 px_inv_rec.Attribute12                    ,
                 px_inv_rec.Attribute13                    ,
                 px_inv_rec.Attribute14                    ,
                 px_inv_rec.Attribute15                    ,
                 px_inv_rec.Attribute_Category_Code        ,
                 px_inv_rec.Unrevalued_Cost                ,
                 px_inv_rec.Merged_Code                    ,
                 px_inv_rec.Split_Code                     ,
                 px_inv_rec.Merge_Parent_Mass_Additions_Id ,
                 px_inv_rec.Split_Parent_Mass_Additions_Id ,
                 px_inv_rec.Project_Asset_Line_Id          ,
                 px_inv_rec.Project_Id                     ,
                 px_inv_rec.Task_Id                        ,
                 px_inv_rec.Depreciate_In_Group_Flag       ,
                 px_inv_rec.Material_Indicator_Flag        ,
                 px_inv_rec.prior_source_line_id           ,
                 px_inv_rec.invoice_distribution_id        ,
                 px_inv_rec.invoice_line_number            ,
                 px_inv_rec.po_distribution_id
            from fa_mc_asset_invoices ai,
                 fa_invoice_transactions it
           where ai.source_line_id = px_inv_rec.source_line_id
             and it.invoice_transaction_id = ai.invoice_transaction_id_in
             and it.transaction_type = 'RETIREMENT'
             and set_of_books_id  = p_set_of_books_id;

   else
          select Po_Vendor_Id                   ,
                 Asset_Invoice_Id               ,
                 Fixed_Assets_Cost              , --
                 Deleted_Flag                   , --
                 Po_Number                      ,
                 Invoice_Number                 ,
                 Payables_Batch_Name            ,
                 Payables_Code_Combination_Id   ,
                 Feeder_System_Name             ,
                 Create_Batch_Date              ,
                 Create_Batch_Id                ,
                 Invoice_Date                   ,
                 Payables_Cost                  , --
                 Post_Batch_Id                  ,
                 Invoice_Id                     ,
                 Ap_Distribution_Line_Number    ,
                 Payables_Units                 ,
                 Split_Merged_Code              ,
                 Description                    ,
                 Parent_Mass_Addition_Id        ,
                 Attribute1                     ,
                 Attribute2                     ,
                 Attribute3                     ,
                 Attribute4                     ,
                 Attribute5                     ,
                 Attribute6                     ,
                 Attribute7                     ,
                 Attribute8                     ,
                 Attribute9                     ,
                 Attribute10                    ,
                 Attribute11                    ,
                 Attribute12                    ,
                 Attribute13                    ,
                 Attribute14                    ,
                 Attribute15                    ,
                 Attribute_Category_Code        ,
                 Unrevalued_Cost                , --
                 Merged_Code                    ,
                 Split_Code                     ,
                 Merge_Parent_Mass_Additions_Id ,
                 Split_Parent_Mass_Additions_Id ,
                 Project_Asset_Line_Id          ,
                 Project_Id                     ,
                 Task_Id                        ,
                 Source_Line_ID                 ,
                 Depreciate_In_Group_Flag       ,
                 Material_Indicator_Flag        ,
                 NULL                           ,
                 Invoice_Distribution_id        ,
                 Invoice_Line_Number            ,
                 PO_Distribution_Id
            into px_inv_rec.Po_Vendor_Id                   ,
                 px_inv_rec.Asset_Invoice_Id               ,
                 px_inv_rec.Fixed_Assets_Cost              ,
                 px_inv_rec.Deleted_Flag                   ,
                 px_inv_rec.Po_Number                      ,
                 px_inv_rec.Invoice_Number                 ,
                 px_inv_rec.Payables_Batch_Name            ,
                 px_inv_rec.Payables_Code_Combination_Id   ,
                 px_inv_rec.Feeder_System_Name             ,
                 px_inv_rec.Create_Batch_Date              ,
                 px_inv_rec.Create_Batch_Id                ,
                 px_inv_rec.Invoice_Date                   ,
                 px_inv_rec.Payables_Cost                  ,
                 px_inv_rec.Post_Batch_Id                  ,
                 px_inv_rec.Invoice_Id                     ,
                 px_inv_rec.Ap_Distribution_Line_Number    ,
                 px_inv_rec.Payables_Units                 ,
                 px_inv_rec.Split_Merged_Code              ,
                 px_inv_rec.Description                    ,
                 px_inv_rec.Parent_Mass_Addition_Id        ,
                 px_inv_rec.Attribute1                     ,
                 px_inv_rec.Attribute2                     ,
                 px_inv_rec.Attribute3                     ,
                 px_inv_rec.Attribute4                     ,
                 px_inv_rec.Attribute5                     ,
                 px_inv_rec.Attribute6                     ,
                 px_inv_rec.Attribute7                     ,
                 px_inv_rec.Attribute8                     ,
                 px_inv_rec.Attribute9                     ,
                 px_inv_rec.Attribute10                    ,
                 px_inv_rec.Attribute11                    ,
                 px_inv_rec.Attribute12                    ,
                 px_inv_rec.Attribute13                    ,
                 px_inv_rec.Attribute14                    ,
                 px_inv_rec.Attribute15                    ,
                 px_inv_rec.Attribute_Category_Code        ,
                 px_inv_rec.Unrevalued_Cost                ,
                 px_inv_rec.Merged_Code                    ,
                 px_inv_rec.Split_Code                     ,
                 px_inv_rec.Merge_Parent_Mass_Additions_Id ,
                 px_inv_rec.Split_Parent_Mass_Additions_Id ,
                 px_inv_rec.Project_Asset_Line_Id          ,
                 px_inv_rec.Project_Id                     ,
                 px_inv_rec.Task_Id                        ,
                 px_inv_rec.Source_Line_Id                 ,
                 px_inv_rec.Depreciate_In_Group_Flag       ,
                 px_inv_rec.Material_Indicator_Flag        ,
                 px_inv_rec.Prior_Source_Line_ID           ,
                 px_inv_rec.invoice_distribution_id        ,
                 px_inv_rec.invoice_line_number            ,
                 px_inv_rec.po_distribution_id
            from fa_asset_invoices  ai,
                 fa_invoice_transactions it
           where ai.source_line_id = px_inv_rec.source_line_id
             and it.invoice_transaction_id = ai.invoice_transaction_id_in
             and it.transaction_type = 'RETIREMENT';

      end if;
   else -- non reinstatement
      if (p_mrc_sob_type_code = 'R') then

          select Po_Vendor_Id                   ,
                 Asset_Invoice_Id               ,
                 Fixed_Assets_Cost              , --
                 Deleted_Flag                   , --
                 Po_Number                      ,
                 Invoice_Number                 ,
                 Payables_Batch_Name            ,
                 Payables_Code_Combination_Id   ,
                 Feeder_System_Name             ,
                 Create_Batch_Date              ,
                 Create_Batch_Id                ,
                 Invoice_Date                   ,
                 Payables_Cost                  , --
                 Post_Batch_Id                  ,
                 Invoice_Id                     ,
                 Ap_Distribution_Line_Number    ,
                 Payables_Units                 ,
                 Split_Merged_Code              ,
                 Description                    ,
                 Parent_Mass_Addition_Id        ,
                 Attribute1                     ,
                 Attribute2                     ,
                 Attribute3                     ,
                 Attribute4                     ,
                 Attribute5                     ,
                 Attribute6                     ,
                 Attribute7                     ,
                 Attribute8                     ,
                 Attribute9                     ,
                 Attribute10                    ,
                 Attribute11                    ,
                 Attribute12                    ,
                 Attribute13                    ,
                 Attribute14                    ,
                 Attribute15                    ,
                 Attribute_Category_Code        ,
                 Unrevalued_Cost                , --
                 Merged_Code                    ,
                 Split_Code                     ,
                 Merge_Parent_Mass_Additions_Id ,
                 Split_Parent_Mass_Additions_Id ,
                 Project_Asset_Line_Id          ,
                 Project_Id                     ,
                 Task_Id                        ,
                 Depreciate_In_Group_Flag       ,
                 Material_Indicator_Flag        ,
                 NULL                           ,
                 Invoice_Distribution_id        ,
                 Invoice_Line_Number            ,
                 PO_Distribution_Id
            into px_inv_rec.Po_Vendor_Id                   ,
                 px_inv_rec.Asset_Invoice_Id               ,
                 px_inv_rec.Fixed_Assets_Cost              ,
                 px_inv_rec.Deleted_Flag                   ,
                 px_inv_rec.Po_Number                      ,
                 px_inv_rec.Invoice_Number                 ,
                 px_inv_rec.Payables_Batch_Name            ,
                 px_inv_rec.Payables_Code_Combination_Id   ,
                 px_inv_rec.Feeder_System_Name             ,
                 px_inv_rec.Create_Batch_Date              ,
                 px_inv_rec.Create_Batch_Id                ,
                 px_inv_rec.Invoice_Date                   ,
                 px_inv_rec.Payables_Cost                  ,
                 px_inv_rec.Post_Batch_Id                  ,
                 px_inv_rec.Invoice_Id                     ,
                 px_inv_rec.Ap_Distribution_Line_Number    ,
                 px_inv_rec.Payables_Units                 ,
                 px_inv_rec.Split_Merged_Code              ,
                 px_inv_rec.Description                    ,
                 px_inv_rec.Parent_Mass_Addition_Id        ,
                 px_inv_rec.Attribute1                     ,
                 px_inv_rec.Attribute2                     ,
                 px_inv_rec.Attribute3                     ,
                 px_inv_rec.Attribute4                     ,
                 px_inv_rec.Attribute5                     ,
                 px_inv_rec.Attribute6                     ,
                 px_inv_rec.Attribute7                     ,
                 px_inv_rec.Attribute8                     ,
                 px_inv_rec.Attribute9                     ,
                 px_inv_rec.Attribute10                    ,
                 px_inv_rec.Attribute11                    ,
                 px_inv_rec.Attribute12                    ,
                 px_inv_rec.Attribute13                    ,
                 px_inv_rec.Attribute14                    ,
                 px_inv_rec.Attribute15                    ,
                 px_inv_rec.Attribute_Category_Code        ,
                 px_inv_rec.Unrevalued_Cost                ,
                 px_inv_rec.Merged_Code                    ,
                 px_inv_rec.Split_Code                     ,
                 px_inv_rec.Merge_Parent_Mass_Additions_Id ,
                 px_inv_rec.Split_Parent_Mass_Additions_Id ,
                 px_inv_rec.Project_Asset_Line_Id          ,
                 px_inv_rec.Project_Id                     ,
                 px_inv_rec.Task_Id                        ,
                 px_inv_rec.Depreciate_In_Group_Flag       ,
                 px_inv_rec.Material_Indicator_Flag        ,
                 px_inv_rec.prior_source_line_id           ,
                 px_inv_rec.invoice_distribution_id        ,
                 px_inv_rec.invoice_line_number            ,
                 px_inv_rec.po_distribution_id
            from fa_mc_asset_invoices
           where source_line_id = px_inv_rec.source_line_id
             and date_ineffective is null
             and set_of_books_id = p_set_of_books_id;

      else
          select Po_Vendor_Id                   ,
                 Asset_Invoice_Id               ,
                 Fixed_Assets_Cost              , --
                 Deleted_Flag                   , --
                 Po_Number                      ,
                 Invoice_Number                 ,
                 Payables_Batch_Name            ,
                 Payables_Code_Combination_Id   ,
                 Feeder_System_Name             ,
                 Create_Batch_Date              ,
                 Create_Batch_Id                ,
                 Invoice_Date                   ,
                 Payables_Cost                  , --
                 Post_Batch_Id                  ,
                 Invoice_Id                     ,
                 Ap_Distribution_Line_Number    ,
                 Payables_Units                 ,
                 Split_Merged_Code              ,
                 Description                    ,
                 Parent_Mass_Addition_Id        ,
                 Attribute1                     ,
                 Attribute2                     ,
                 Attribute3                     ,
                 Attribute4                     ,
                 Attribute5                     ,
                 Attribute6                     ,
                 Attribute7                     ,
                 Attribute8                     ,
                 Attribute9                     ,
                 Attribute10                    ,
                 Attribute11                    ,
                 Attribute12                    ,
                 Attribute13                    ,
                 Attribute14                    ,
                 Attribute15                    ,
                 Attribute_Category_Code        ,
                 Unrevalued_Cost                , --
                 Merged_Code                    ,
                 Split_Code                     ,
                 Merge_Parent_Mass_Additions_Id ,
                 Split_Parent_Mass_Additions_Id ,
                 Project_Asset_Line_Id          ,
                 Project_Id                     ,
                 Task_Id                        ,
                 Source_Line_ID                 ,
                 Depreciate_In_Group_Flag       ,
                 Material_Indicator_Flag        ,
                 NULL                           ,
                 Invoice_Distribution_id        ,
                 Invoice_Line_Number            ,
                 PO_Distribution_Id
            into px_inv_rec.Po_Vendor_Id                   ,
                 px_inv_rec.Asset_Invoice_Id               ,
                 px_inv_rec.Fixed_Assets_Cost              ,
                 px_inv_rec.Deleted_Flag                   ,
                 px_inv_rec.Po_Number                      ,
                 px_inv_rec.Invoice_Number                 ,
                 px_inv_rec.Payables_Batch_Name            ,
                 px_inv_rec.Payables_Code_Combination_Id   ,
                 px_inv_rec.Feeder_System_Name             ,
                 px_inv_rec.Create_Batch_Date              ,
                 px_inv_rec.Create_Batch_Id                ,
                 px_inv_rec.Invoice_Date                   ,
                 px_inv_rec.Payables_Cost                  ,
                 px_inv_rec.Post_Batch_Id                  ,
                 px_inv_rec.Invoice_Id                     ,
                 px_inv_rec.Ap_Distribution_Line_Number    ,
                 px_inv_rec.Payables_Units                 ,
                 px_inv_rec.Split_Merged_Code              ,
                 px_inv_rec.Description                    ,
                 px_inv_rec.Parent_Mass_Addition_Id        ,
                 px_inv_rec.Attribute1                     ,
                 px_inv_rec.Attribute2                     ,
                 px_inv_rec.Attribute3                     ,
                 px_inv_rec.Attribute4                     ,
                 px_inv_rec.Attribute5                     ,
                 px_inv_rec.Attribute6                     ,
                 px_inv_rec.Attribute7                     ,
                 px_inv_rec.Attribute8                     ,
                 px_inv_rec.Attribute9                     ,
                 px_inv_rec.Attribute10                    ,
                 px_inv_rec.Attribute11                    ,
                 px_inv_rec.Attribute12                    ,
                 px_inv_rec.Attribute13                    ,
                 px_inv_rec.Attribute14                    ,
                 px_inv_rec.Attribute15                    ,
                 px_inv_rec.Attribute_Category_Code        ,
                 px_inv_rec.Unrevalued_Cost                ,
                 px_inv_rec.Merged_Code                    ,
                 px_inv_rec.Split_Code                     ,
                 px_inv_rec.Merge_Parent_Mass_Additions_Id ,
                 px_inv_rec.Split_Parent_Mass_Additions_Id ,
                 px_inv_rec.Project_Asset_Line_Id          ,
                 px_inv_rec.Project_Id                     ,
                 px_inv_rec.Task_Id                        ,
                 px_inv_rec.Source_Line_Id                 ,
                 px_inv_rec.Depreciate_In_Group_Flag       ,
                 px_inv_rec.Material_Indicator_Flag        ,
                 px_inv_rec.Prior_Source_Line_ID           ,
                 px_inv_rec.invoice_distribution_id        ,
                 px_inv_rec.invoice_line_number            ,
                 px_inv_rec.po_distribution_id
            from fa_asset_invoices
           where source_line_id = px_inv_rec.source_line_id
             and date_ineffective is null;

      end if;
   end if;

   return true;

EXCEPTION
  when error_found then
     fa_srvr_msg.add_message(calling_fn => 'fa_util_pvt.get_inv_rec', p_log_level_rec => p_log_level_rec);
     return false;

  when no_data_found then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_inv_rec',p_log_level_rec => p_log_level_rec);
     fa_srvr_msg.add_message(name       => 'FA_MASSADD_INVOICE',
                             token1     => 'SOURCE_LINE_ID',
                             value1     => px_inv_rec.source_line_id,
                             calling_fn => 'fa_util_pvt.get_inv_rec', p_log_level_rec => p_log_level_rec);
     return false;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_inv_rec', p_log_level_rec => p_log_level_rec);
     return false;

END get_inv_rec;


-----------------------------------------------------------------------------
--  NAME         check_asset_key_req                                         |
--                                                                           |
--  FUNCTION     checks whether the asset key flexfield has any              |
--               required segments                                           |
--                                                                           |
--               -- fdfkfa doesn't appear to allow you to                    |
--                  check the required status of a column                    |
--                  so hard coding this against FND.                         |
-----------------------------------------------------------------------------

FUNCTION check_asset_key_req
   (p_asset_key_chart_id         IN     NUMBER,
    p_asset_key_required            OUT NOCOPY BOOLEAN,
    p_calling_fn                 IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   cursor asset_key_req is
   select 1
   from   fnd_id_flex_segments
   where  application_id = 140
   and    id_flex_code   = 'KEY#'
   and    id_flex_num    =  p_asset_key_chart_id
   and    required_flag  = 'Y';

   l_asset_key_segs_required      NUMBER := 0;

BEGIN

   open asset_key_req;
   loop

      fetch asset_key_req into l_asset_key_segs_required;

      if (asset_key_req%NOTFOUND) then
         exit;
      end if;
   end loop;
   close asset_key_req;

   if (l_asset_key_segs_required > 0) then
       p_asset_key_required := TRUE;
   else
       p_asset_key_required := FALSE;
   end if;

   return TRUE;

EXCEPTION

   when others then
      fa_srvr_msg.add_sql_error(
         calling_fn => 'fa_util_pvt.check_asset_key_req', p_log_level_rec => p_log_level_rec);
      return FALSE;

END check_asset_key_req;


FUNCTION get_current_units
   (p_calling_fn     in  VARCHAR2
   ,p_asset_id       in  NUMBER
   ,x_current_units  out NOCOPY NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

BEGIN

   select units
   into x_current_units
   from fa_asset_history
   where asset_id = p_asset_id
     and date_ineffective is null;

   return TRUE;

EXCEPTION

   when others then

      fa_srvr_msg.add_message(
         calling_fn => 'fa_util_pvt.get_current_units',
         name       => 'FA_SHARED_ACTION_TABLE',
         token1     => 'ACTION',
         value1     => 'SELECT',
         token2     => 'TABLE',
         value2     => 'FA_ASSET_HISTORY', p_log_level_rec => p_log_level_rec);

      return FALSE;

END get_current_units;

FUNCTION get_latest_trans_date
   (p_calling_fn          in  VARCHAR2
   ,p_asset_id            in  NUMBER
   ,p_book                in  VARCHAR2
   ,x_latest_trans_date   out NOCOPY DATE
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

BEGIN

   /* commenting for bug 3768867
   select max(transaction_date_entered)
   into x_latest_trans_date
   from fa_transaction_headers
   where asset_id = p_asset_id
   and book_type_code = p_book
   and transaction_type_code not in ('REINSTATEMENT','FULL RETIREMENT')
   and transaction_type_code not like '%/VOID';
   */

  -- added for bug 3768867
  select max(transaction_date_entered)
  into x_latest_trans_date
  from fa_transaction_headers
  where asset_id = p_asset_id
  and book_type_code = p_book
  and transaction_type_code in ('TAX', 'REVALUATION');

   return TRUE;

EXCEPTION
   when others then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_util_pvt.get_latest_trans_date',
         name       => 'FA_SHARED_ACTION_TABLE',
         token1     => 'ACTION',
         value1     => 'SELECT',
         token2     => 'TABLE',
         value2     => 'FA_TRANSACTION_HEADERS', p_log_level_rec => p_log_level_rec);
      return FALSE;

END get_latest_trans_date;


FUNCTION get_period_rec
   (p_book           in  varchar2
   ,p_period_counter in  number  default null
   ,p_effective_date in  date    default null
   ,x_period_rec     out NOCOPY FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return BOOLEAN IS

   error_found    EXCEPTION;

BEGIN

   if not fa_cache_pkg.fazcdp
           (x_book_type_code => p_book,
            x_period_counter => p_period_counter,
            x_effective_date => p_effective_date, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   x_period_rec.period_counter := fa_cache_pkg.fazcdp_record.period_counter;
   x_period_rec.period_name    := fa_cache_pkg.fazcdp_record.period_name;
   x_period_rec.period_open_date := fa_cache_pkg.fazcdp_record.period_open_date;
   x_period_rec.period_close_date := fa_cache_pkg.fazcdp_record.period_close_date;
   x_period_rec.calendar_period_open_date := fa_cache_pkg.fazcdp_record.calendar_period_open_date;
   x_period_rec.calendar_period_close_date := fa_cache_pkg.fazcdp_record.calendar_period_close_date;
   x_period_rec.deprn_run := fa_cache_pkg.fazcdp_record.deprn_run;
   x_period_rec.fiscal_year := fa_cache_pkg.fazcdp_record.fiscal_year;
   x_period_rec.period_num := fa_cache_pkg.fazcdp_record.period_num;

   if not fa_cache_pkg.fazcfy
          (X_fiscal_year_name => fa_cache_pkg.fazcbc_record.fiscal_year_name,
           X_fiscal_year => x_period_rec.fiscal_year, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   x_period_rec.fy_start_date := fa_cache_pkg.fazcfy_record.start_date;
   x_period_rec.fy_end_date   := fa_cache_pkg.fazcfy_record.end_date;

   return TRUE;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => 'fa_util_pvt.get_period_rec', p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_period_rec', p_log_level_rec => p_log_level_rec);
      return false;

END get_period_rec;


FUNCTION get_asset_retire_rec
   (px_asset_retire_rec   in out NOCOPY FA_API_TYPES.asset_retire_rec_type,
    p_mrc_sob_type_code   IN     VARCHAR2,
    p_set_of_books_id     IN      NUMBER
    , p_log_level_rec     IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

   error_found        EXCEPTION;

BEGIN

   if (nvl(p_mrc_sob_type_code, 'P') = 'R') then

      select retirement_id
            ,asset_id
            ,book_type_code
            ,transaction_header_id_in
            ,date_retired
            ,cost_retired
            ,status
            ,retirement_prorate_convention
            ,transaction_header_id_out
            ,units
            ,cost_of_removal
            ,nbv_retired
            ,gain_loss_amount
            ,proceeds_of_sale
            ,gain_loss_type_code
            ,retirement_type_code
            ,itc_recaptured
            ,itc_recapture_id
            ,reference_num
            ,sold_to
            ,trade_in_asset_id
            ,stl_method_code
            ,stl_life_in_months
            ,stl_deprn_amount
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,attribute_category_code
            ,reval_reserve_retired
            ,unrevalued_cost_retired
            ,bonus_reserve_retired
            ,recognize_gain_loss
            ,recapture_reserve_flag
            ,limit_proceeds_flag
            ,terminal_gain_loss
            ,reserve_retired
            ,eofy_reserve
            ,reduction_rate
            ,recapture_amount
            ,rowid
      into
             px_asset_retire_rec.retirement_id
            ,px_asset_retire_rec.detail_info.asset_id
            ,px_asset_retire_rec.detail_info.book_type_code
            ,px_asset_retire_rec.detail_info.transaction_header_id_in
            ,px_asset_retire_rec.date_retired
            ,px_asset_retire_rec.cost_retired
            ,px_asset_retire_rec.status
            ,px_asset_retire_rec.retirement_prorate_convention
            ,px_asset_retire_rec.detail_info.transaction_header_id_out
            ,px_asset_retire_rec.units_retired
            ,px_asset_retire_rec.cost_of_removal
            ,px_asset_retire_rec.detail_info.nbv_retired
            ,px_asset_retire_rec.detail_info.gain_loss_amount
            ,px_asset_retire_rec.proceeds_of_sale
            ,px_asset_retire_rec.detail_info.gain_loss_type_code
            ,px_asset_retire_rec.retirement_type_code
            ,px_asset_retire_rec.detail_info.itc_recaptured
            ,px_asset_retire_rec.detail_info.itc_recapture_id
            ,px_asset_retire_rec.reference_num
            ,px_asset_retire_rec.sold_to
            ,px_asset_retire_rec.trade_in_asset_id
            ,px_asset_retire_rec.detail_info.stl_method_code
            ,px_asset_retire_rec.detail_info.stl_life_in_months
            ,px_asset_retire_rec.detail_info.stl_deprn_amount
            ,px_asset_retire_rec.desc_flex.attribute1
            ,px_asset_retire_rec.desc_flex.attribute2
            ,px_asset_retire_rec.desc_flex.attribute3
            ,px_asset_retire_rec.desc_flex.attribute4
            ,px_asset_retire_rec.desc_flex.attribute5
            ,px_asset_retire_rec.desc_flex.attribute6
            ,px_asset_retire_rec.desc_flex.attribute7
            ,px_asset_retire_rec.desc_flex.attribute8
            ,px_asset_retire_rec.desc_flex.attribute9
            ,px_asset_retire_rec.desc_flex.attribute10
            ,px_asset_retire_rec.desc_flex.attribute11
            ,px_asset_retire_rec.desc_flex.attribute12
            ,px_asset_retire_rec.desc_flex.attribute13
            ,px_asset_retire_rec.desc_flex.attribute14
            ,px_asset_retire_rec.desc_flex.attribute15
            ,px_asset_retire_rec.desc_flex.attribute_category_code
            ,px_asset_retire_rec.detail_info.reval_reserve_retired
            ,px_asset_retire_rec.detail_info.unrevalued_cost_retired
            ,px_asset_retire_rec.detail_info.bonus_reserve_retired
            ,px_asset_retire_rec.recognize_gain_loss
            ,px_asset_retire_rec.recapture_reserve_flag
            ,px_asset_retire_rec.limit_proceeds_flag
            ,px_asset_retire_rec.terminal_gain_loss
            ,px_asset_retire_rec.reserve_retired
            ,px_asset_retire_rec.eofy_reserve
            ,px_asset_retire_rec.reduction_rate
            ,px_asset_retire_rec.detail_info.recapture_amount
            ,px_asset_retire_rec.detail_info.row_id -- used as parameter when calling fa_retirements_pkg.delete
      from fa_mc_retirements
      where retirement_id = px_asset_retire_rec.retirement_id
        and set_of_books_id  = p_set_of_books_id;

    else

      select retirement_id
            ,asset_id
            ,book_type_code
            ,transaction_header_id_in
            ,date_retired
            ,cost_retired
            ,status
            ,retirement_prorate_convention
            ,transaction_header_id_out
            ,units
            ,cost_of_removal
            ,nbv_retired
            ,gain_loss_amount
            ,proceeds_of_sale
            ,gain_loss_type_code
            ,retirement_type_code
            ,itc_recaptured
            ,itc_recapture_id
            ,reference_num
            ,sold_to
            ,trade_in_asset_id
            ,stl_method_code
            ,stl_life_in_months
            ,stl_deprn_amount
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,attribute_category_code
            ,reval_reserve_retired
            ,unrevalued_cost_retired
            ,bonus_reserve_retired
            ,recognize_gain_loss
            ,recapture_reserve_flag
            ,limit_proceeds_flag
            ,terminal_gain_loss
            ,reserve_retired
            ,eofy_reserve
            ,reduction_rate
            ,recapture_amount
            ,rowid
      into
             px_asset_retire_rec.retirement_id
            ,px_asset_retire_rec.detail_info.asset_id
            ,px_asset_retire_rec.detail_info.book_type_code
            ,px_asset_retire_rec.detail_info.transaction_header_id_in
            ,px_asset_retire_rec.date_retired
            ,px_asset_retire_rec.cost_retired
            ,px_asset_retire_rec.status
            ,px_asset_retire_rec.retirement_prorate_convention
            ,px_asset_retire_rec.detail_info.transaction_header_id_out
            ,px_asset_retire_rec.units_retired
            ,px_asset_retire_rec.cost_of_removal
            ,px_asset_retire_rec.detail_info.nbv_retired
            ,px_asset_retire_rec.detail_info.gain_loss_amount
            ,px_asset_retire_rec.proceeds_of_sale
            ,px_asset_retire_rec.detail_info.gain_loss_type_code
            ,px_asset_retire_rec.retirement_type_code
            ,px_asset_retire_rec.detail_info.itc_recaptured
            ,px_asset_retire_rec.detail_info.itc_recapture_id
            ,px_asset_retire_rec.reference_num
            ,px_asset_retire_rec.sold_to
            ,px_asset_retire_rec.trade_in_asset_id
            ,px_asset_retire_rec.detail_info.stl_method_code
            ,px_asset_retire_rec.detail_info.stl_life_in_months
            ,px_asset_retire_rec.detail_info.stl_deprn_amount
            ,px_asset_retire_rec.desc_flex.attribute1
            ,px_asset_retire_rec.desc_flex.attribute2
            ,px_asset_retire_rec.desc_flex.attribute3
            ,px_asset_retire_rec.desc_flex.attribute4
            ,px_asset_retire_rec.desc_flex.attribute5
            ,px_asset_retire_rec.desc_flex.attribute6
            ,px_asset_retire_rec.desc_flex.attribute7
            ,px_asset_retire_rec.desc_flex.attribute8
            ,px_asset_retire_rec.desc_flex.attribute9
            ,px_asset_retire_rec.desc_flex.attribute10
            ,px_asset_retire_rec.desc_flex.attribute11
            ,px_asset_retire_rec.desc_flex.attribute12
            ,px_asset_retire_rec.desc_flex.attribute13
            ,px_asset_retire_rec.desc_flex.attribute14
            ,px_asset_retire_rec.desc_flex.attribute15
            ,px_asset_retire_rec.desc_flex.attribute_category_code
            ,px_asset_retire_rec.detail_info.reval_reserve_retired
            ,px_asset_retire_rec.detail_info.unrevalued_cost_retired
            ,px_asset_retire_rec.detail_info.bonus_reserve_retired
            ,px_asset_retire_rec.recognize_gain_loss
            ,px_asset_retire_rec.recapture_reserve_flag
            ,px_asset_retire_rec.limit_proceeds_flag
            ,px_asset_retire_rec.terminal_gain_loss
            ,px_asset_retire_rec.reserve_retired
            ,px_asset_retire_rec.eofy_reserve
            ,px_asset_retire_rec.reduction_rate
            ,px_asset_retire_rec.detail_info.recapture_amount
            ,px_asset_retire_rec.detail_info.row_id -- used as parameter when calling fa_retirements_pkg.delete
      from fa_retirements
      where retirement_id = px_asset_retire_rec.retirement_id;

   end if;

   return TRUE;


EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => 'fa_util_pvt.get_asset_retire_rec', p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_util_pvt.get_asset_retire_rec', p_log_level_rec => p_log_level_rec);
      return false;

END get_asset_retire_rec;

FUNCTION get_corp_book( p_asset_id  IN     NUMBER,
                        p_corp_book IN OUT NOCOPY VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

BEGIN

   SELECT bc.book_type_code
   INTO p_corp_book
   FROM fa_books bks,
        fa_book_controls bc
   WHERE bks.book_type_code = bc.distribution_source_book
   AND   bks.book_type_code = bc.book_type_code
   AND   bks.asset_id       = p_asset_id
   AND   bks.transaction_header_id_out is null
   AND   rownum < 2;

   return TRUE;

EXCEPTION
   when others then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_util_pvt.get_corp_book',
         name       => 'FA_SHARED_ACTION_TABLE',
         token1     => 'ACTION',
         value1     => 'SELECT',
         token2     => 'TABLE',
         value2     => 'FA_BOOKS'
       , p_log_level_rec => p_log_level_rec);
      return FALSE;

END get_corp_book;


-- NOTICE: per ATG / performance team, we are changing the standards
-- surrounding the principle of nulling out a column.  Originally
-- the G_MISS_* values were used to indicate no change, but we've flipped
-- the logic.  Null values will be treated as no change, whereas
-- G_MISS_* will indicate the intent to null out a column.

PROCEDURE load_char_value
            (p_char_old  IN     VARCHAR2,
             p_char_adj  IN     VARCHAR2,
             x_char_new  IN OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

   if (p_char_adj is null) then
      x_char_new := p_char_old;
   elsif (p_char_adj = FND_API.G_MISS_CHAR)then
      x_char_new := NULL;
   else
      x_char_new := p_char_adj;
   end if;

END load_char_value;

PROCEDURE load_date_value
            (p_date_old  IN     VARCHAR2,
             p_date_adj  IN     VARCHAR2,
             x_date_new  IN OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

   if (p_date_adj is null) then
      x_date_new := p_date_old;
   elsif (p_date_adj = FND_API.G_MISS_DATE) then
      x_date_new := NULL;
   else
      x_date_new := p_date_adj;
   end if;

END load_date_value;

PROCEDURE load_num_value
            (p_num_old   IN     VARCHAR2,
             p_num_adj   IN     VARCHAR2,
             x_num_new   IN OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

   if (p_num_adj is null) then
      x_num_new := p_num_old;
   elsif (p_num_adj = FND_API.G_MISS_NUM) then
      x_num_new := NULL;
   else
      x_num_new := p_num_adj;
   end if;

END load_num_value;

FUNCTION check_deprn_run
            (X_book          IN      VARCHAR2,
             X_asset_id      IN      NUMBER  DEFAULT 0,
	     X_deprn_amount  OUT  NOCOPY   NUMBER,
             p_log_level_rec IN  FA_API_TYPES.log_level_rec_type default null)
return BOOLEAN IS

   deprn_run           VARCHAR2(1);
   h_count             NUMBER;
   h_mc_source_flag    VARCHAR2(3);
   h_set_of_books_id   NUMBER;
   h_mrc_sob_type_code VARCHAR2(3);
   l_deprn_amt         NUMBER;

BEGIN

   h_mc_source_flag       := FA_CACHE_PKG.fazcbc_record.mc_source_flag;
   h_set_of_books_id      := FA_CACHE_PKG.fazcbc_record.set_of_books_id;

   if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_mrc_sob_type_code,
	    p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_sql_error
            (calling_fn => 'fa_util_pvt.check_deprn_run', p_log_level_rec => p_log_level_rec);
      return(FALSE);
   end if;

   if (X_asset_id = 0) then
      null;
   else

      SELECT ds.deprn_amount
        INTO l_deprn_amt
        FROM fa_deprn_summary ds,
             fa_book_controls bc
       WHERE bc.book_type_code = X_book
         AND ds.book_type_code = bc.book_type_code
         AND ds.period_counter = bc.last_period_counter + 1
         AND ds.asset_id = X_asset_id
         AND ds.deprn_source_code in ('DEPRN','TRACK');

      if (sql%rowcount <> 0) then
	 X_deprn_amount := l_deprn_amt;
         return TRUE;
      else

         select ds.deprn_amount
	  into l_deprn_amt
          FROM fa_deprn_summary ds,
               fa_book_controls bc,
               fa_books bks,
               fa_additions_b ad
         WHERE bc.book_type_code = X_Book
           AND ds.book_type_code = bc.book_type_code
           AND ds.period_counter = bc.last_period_counter + 1
           AND ds.asset_id = bks.asset_id
           AND ds.deprn_source_code in ('DEPRN','TRACK')
           AND bks.group_asset_id = X_Asset_ID
           AND bks.book_type_code = bc.book_type_code
           AND bks.transaction_header_id_out is null
           AND ad.asset_id = X_Asset_ID
           AND ad.asset_type = 'GROUP';

         if (sql%rowcount <> 0) then
	    X_deprn_amount := l_deprn_amt;
	    return TRUE;
         end if;

      end if;

      if (h_mc_source_flag = 'Y' and h_mrc_sob_type_code = 'P') then
         SELECT ds.deprn_amount
           INTO l_deprn_amt
           FROM fa_mc_deprn_summary ds,
                fa_book_controls bc
          WHERE bc.book_type_code = X_book
            AND ds.book_type_code = bc.book_type_code
            AND ds.period_counter = bc.last_period_counter + 1
            AND ds.asset_id = X_asset_id
            AND ds.deprn_source_code in ('DEPRN','TRACK');

         if (sql%rowcount <> 0) then
	    X_deprn_amount := l_deprn_amt;
	    return TRUE;
         end if;
      end if;
   end if; --X_asset_id = 0
X_deprn_amount := NULL;
return FALSE;
Exception
  When NO_DATA_FOUND then
      return FALSE;
END check_deprn_run;

END FA_UTIL_PVT;

/
