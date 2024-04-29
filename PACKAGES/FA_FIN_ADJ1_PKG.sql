--------------------------------------------------------
--  DDL for Package FA_FIN_ADJ1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FIN_ADJ1_PKG" AUTHID CURRENT_USER as
/* $Header: faxfa1s.pls 120.2.12010000.2 2009/07/19 13:35:40 glchen ship $ */

  PROCEDURE get_deprn_info(bks_asset_id			in number,
			   bks_book_type_code		in varchar2,
			   bks_depreciation_check	in out nocopy varchar2,
			   bks_current_period_flag	in out nocopy varchar2,
			   bks_calling_fn		varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  -- syoung: added x_return_status
  procedure cal_rec_cost(
		bks_itc_amount_id		in number,
		bks_ceiling_type		in varchar2,
		bks_ceiling_name		in varchar2,
		bks_itc_basis			in number,
		bks_cost			in number,
		bks_salvage_value		in number,
		bks_recoverable_cost		in out nocopy number,
		bks_date_placed_in_service	in date,
		x_return_status		 out nocopy boolean,
		bks_calling_fn			varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  -- syoung: added x_return_status
  procedure update_and_check_amts(
		bks_depreciation_check		in varchar2,
		bks_current_period_flag		in varchar2,
		bks_recoverable_cost		in number,
		bks_deprn_reserve		in number,
		bks_ytd_deprn			in number,
		bks_cost			in number,
		bks_salvage_value		in number,
		x_return_status		 out nocopy boolean,
		bks_calling_fn			varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  procedure chk_val_before_commit(
		bks_cost			in number,
		bks_pc_fully_retired		in number,
		bks_pc_fully_reserved		in out nocopy number,
		bks_depreciation_check		in varchar2,
		bks_current_period_flag		in varchar2,
		bks_recoverable_cost		in number,
		bks_deprn_reserve		in number,
		bks_ytd_deprn			in number,
		bks_salvage_value		in number,
		bks_book_type_code		in varchar2,
		bks_date_placed_in_service	in date,
		bks_rate_source_rule		in varchar2,
		bks_deprn_method_code		in varchar2,
		bks_life_years			in number,
		bks_life_months			in number,
		bks_basic_rate			in number,
		bks_adjusted_rate		in number,
		bks_itc_amount_id		in number,
		bks_ceiling_type		in varchar2,
		bks_depreciate_flag		in varchar2,
		bks_calling_fn			varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  procedure check_changes_before_commit(
		bks_row_id			in varchar2,
		bks_amortize_flag		in varchar2,
		bks_prorate_convention_code	in varchar2,
		bks_orig_deprn_reserve		in number,
		bks_orig_reval_reserve		in number,
		bks_orig_ytd_deprn		in number,
		bks_cost			in number,
		bks_recoverable_cost		in number,
		bks_adjusted_rec_cost           in number,
		bks_date_placed_in_service	in date,
		bks_deprn_method_code		in varchar2,
		bks_life_years			in number,
		bks_life_months			in number,
		bks_salvage_value		in number,
		bks_basic_rate_dsp		in number,
		bks_adjusted_rate_dsp		in number,
		bks_bonus_rule			in varchar2,
		bks_ceiling_name		in varchar2,
		bks_production_capacity		in number,
		bks_deprn_reserve		in number,
		bks_ytd_deprn			in number,
		bks_reval_reserve		in number,
		bks_adjusted_cost		in number,
		bks_orig_adjusted_cost		in number,
		bks_reval_ceiling		in number,
		bks_depreciate_flag		in varchar2,
		bks_unit_of_measure		in varchar2,
                bks_global_attribute1           in varchar2,
                bks_global_attribute2           in varchar2,
                bks_global_attribute3           in varchar2,
                bks_global_attribute4           in varchar2,
                bks_global_attribute5           in varchar2,
                bks_global_attribute6           in varchar2,
                bks_global_attribute7           in varchar2,
                bks_global_attribute8           in varchar2,
                bks_global_attribute9           in varchar2,
                bks_global_attribute10          in varchar2,
                bks_global_attribute11          in varchar2,
                bks_global_attribute12          in varchar2,
                bks_global_attribute13          in varchar2,
                bks_global_attribute14          in varchar2,
                bks_global_attribute15          in varchar2,
                bks_global_attribute16          in varchar2,
                bks_global_attribute17          in varchar2,
                bks_global_attribute18          in varchar2,
                bks_global_attribute19          in varchar2,
                bks_global_attribute20          in varchar2,
                bks_global_attribute_category   in varchar2,
		bks_adjustment_required_status  in out nocopy varchar2,
		bks_calling_fn			varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_FIN_ADJ1_PKG;

/
