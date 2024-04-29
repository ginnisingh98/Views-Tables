--------------------------------------------------------
--  DDL for Package FA_RX_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_GROUP" AUTHID CURRENT_USER AS
/* $Header: farxgas.pls 120.4.12010000.3 2009/10/30 10:21:55 pmadas ship $ */



FA_RXGA_POSITIVE_REDUCTION  CONSTANT VARCHAR2(80) :=
           'YEAR END BALANCE WITH POSITIVE REDUCTION AMOUNT';
FA_RXGA_HALF_YEAR_RULE  CONSTANT VARCHAR2(80) :=
           'YEAR END BALANCE WITH HALF YEAR RULE';


TYPE group_rec_type IS RECORD (
  -- columns of fa_group_rep_itf (GRP_xxx, MEM_xxx)
  asset_number                fa_group_rep_itf.grp_asset_number%TYPE,
  description                 fa_group_rep_itf.grp_description%TYPE,
  asset_type                  fa_group_rep_itf.grp_asset_type%TYPE,
  major_category              fa_group_rep_itf.grp_major_category%TYPE,
  minor_category              fa_group_rep_itf.grp_minor_category%TYPE,
  other_category              fa_group_rep_itf.grp_other_category%TYPE,
  date_placed_in_service      fa_group_rep_itf.grp_date_placed_in_service%TYPE,
  deprn_method_code           fa_group_rep_itf.grp_deprn_method_code%TYPE,
  rule_name                   fa_group_rep_itf.grp_rule_name%TYPE,
  tracking_method             fa_group_rep_itf.grp_tracking_method%TYPE,
                              -- group only
  adjusted_rate               fa_group_rep_itf.grp_adjusted_rate%TYPE,
  life_year_month             fa_group_rep_itf.grp_life_year_month%TYPE,
  cost                        fa_group_rep_itf.grp_cost%TYPE,
  salvage_value               fa_group_rep_itf.grp_salvage_value%TYPE,
  adjusted_recoverable_cost   fa_group_rep_itf.grp_adjusted_recoverable_cost%TYPE,
  beginning_nbv               fa_group_rep_itf.grp_beginning_nbv%TYPE,
  first_half_addition         fa_group_rep_itf.grp_first_half_addition%TYPE,
  second_half_addition        fa_group_rep_itf.grp_second_half_addition%TYPE,
  addition_amount             fa_group_rep_itf.grp_addition_amount%TYPE,
  adjustment_amount           fa_group_rep_itf.grp_adjustment_amount%TYPE,
  net_proceeds                fa_group_rep_itf.grp_net_proceeds%TYPE,
  proceeds_of_sale            fa_group_rep_itf.grp_proceeds_of_sale%TYPE,
  cost_of_removal             fa_group_rep_itf.grp_cost_of_removal%TYPE,
  cost_retired                fa_group_rep_itf.grp_cost_retired%TYPE,
  reserve_retired             fa_group_rep_itf.grp_reserve_retired%TYPE,
  recapture_amount            fa_group_rep_itf.grp_recapture_amount%TYPE,
                              -- group only
  terminal_gain_loss_amount   fa_group_rep_itf.grp_terminal_gain_loss_amount%TYPE,
                              -- group only
  nbv_before_deprn            fa_group_rep_itf.grp_nbv_before_deprn%TYPE,
  deprn_basis_adjustment      fa_group_rep_itf.grp_deprn_basis_adjustment%TYPE,
  reduced_nbv                 fa_group_rep_itf.grp_reduced_nbv%TYPE,
  regular_deprn_amount        fa_group_rep_itf.grp_regular_deprn_amount%TYPE,
                              -- group only
  reduced_deprn_amount        fa_group_rep_itf.grp_reduced_deprn_amount%TYPE,
                              -- group only
  annual_deprn_amount         fa_group_rep_itf.grp_annual_deprn_amount%TYPE,
  deprn_reserve               fa_group_rep_itf.grp_deprn_reserve%TYPE,
  ending_nbv                  fa_group_rep_itf.grp_ending_nbv%TYPE,
  status                      fa_group_rep_itf.mem_status%TYPE,
                              -- member only
  -- necessities for query and calculation
  asset_id                    fa_additions.asset_id%TYPE,
  pre_group_asset_id          fa_books.group_asset_id%TYPE,
  life_year_month_string      VARCHAR2(10),
  deprn_basis_rule            fa_methods.deprn_basis_rule%TYPE,
  exclude_salvage_value_flag  fa_methods.exclude_salvage_value_flag%TYPE,
  reduction_rate              fa_books.reduction_rate%TYPE,
  depreciation_option         fa_books.depreciation_option%TYPE,
  recognize_gain_loss         fa_books.recognize_gain_loss%TYPE,
  exclude_proceeds_from_basis fa_books.exclude_proceeds_from_basis%TYPE,
  period_counter_fully_retired  fa_books.period_counter_fully_retired%TYPE,
  period_counter_fully_reserved fa_books.period_counter_fully_reserved%TYPE,
  max_period_counter            fa_deprn_summary.period_counter%TYPE
);


TYPE info_rec_type IS RECORD (
  book_type_code              fa_books.book_type_code%TYPE,
  request_id                  fa_group_rep_itf.request_id%TYPE,
  user_id                     fa_group_rep_itf.created_by%TYPE,
  organization_name           fa_group_rep_itf.organization_name%TYPE,
  functional_currency_code    fa_group_rep_itf.functional_currency_code%TYPE,
  set_of_books_id             fa_group_rep_itf.set_of_books_id%TYPE,
  deprn_calendar              fa_group_rep_itf.deprn_calendar%TYPE,
  fiscal_year                 fa_group_rep_itf.fiscal_year%TYPE,
  max_period_counter          fa_deprn_periods.period_counter%TYPE,
  min_period_counter          fa_deprn_periods.period_counter%TYPE,
  major_cat_select_stmt       VARCHAR2(100),
  minor_cat_select_stmt       VARCHAR2(100),
  other_cat_select_stmt       VARCHAR2(100),
  member_query_mode           VARCHAR2(20)
);


PROCEDURE get_group_asset_info (
  p_book_type_code          IN  VARCHAR2,
  p_sob_id                  IN  VARCHAR2 default NULL,   -- MRC: Set of books id
  p_start_fiscal_year       IN  VARCHAR2,
  p_end_fiscal_year         IN  VARCHAR2,
  p_major_category_low      IN  VARCHAR2,
  p_major_category_high     IN  VARCHAR2,
  p_minor_category_low      IN  VARCHAR2,
  p_minor_category_high     IN  VARCHAR2,
  p_category_segment_name   IN  VARCHAR2,
  p_category_segment_low    IN  VARCHAR2,
  p_category_segment_high   IN  VARCHAR2,
  p_asset_number_low        IN  VARCHAR2,
  p_asset_number_high       IN  VARCHAR2,
  p_drill_down              IN  VARCHAR2,
  p_request_id              IN  NUMBER,
  p_user_id                 IN  NUMBER,
  x_retcode                 OUT NOCOPY NUMBER,
  x_errbuf                  OUT NOCOPY VARCHAR2
);


PROCEDURE get_category_sql (
  p_application_id          IN  NUMBER,
  p_category_flex_structure IN  NUMBER,
  p_qualifier               IN  VARCHAR2,
  p_category_low            IN  VARCHAR2,
  p_category_high           IN  VARCHAR2,
  x_select_stmt             OUT NOCOPY VARCHAR2,
  x_where_stmt              OUT NOCOPY VARCHAR2
);

PROCEDURE get_from_sql_stmt (
  p_info_rec                IN  info_rec_type,
  p_group_asset_id          IN  NUMBER,
  p_mrcsobtype              IN  VARCHAR2 default NULL,   -- MRC: SOB Type
  x_sql_stmt                OUT NOCOPY VARCHAR2
);

PROCEDURE get_where_sql_stmt (
  p_info_rec                IN  info_rec_type,
  p_group_asset_id          IN  NUMBER,
  p_mrcsobtype              IN  VARCHAR2 default NULL,   -- MRC: SOB Type
  x_sql_stmt                OUT NOCOPY VARCHAR2
);

PROCEDURE get_trx_amount_sql (
  p_group_rec               IN  group_rec_type,
  p_info_rec                IN  info_rec_type,
  p_group_asset_id          IN  NUMBER,
  p_mrcsobtype              IN  VARCHAR2 default NULL,   -- MRC: SOB Type
  x_sql_stmt                OUT NOCOPY VARCHAR2
);

PROCEDURE get_retirement_sql (
  p_info_rec                IN  info_rec_type,
  p_group_asset_id          IN  NUMBER,
  p_mrcsobtype              IN  VARCHAR2 default NULL,   -- MRC: SOB Type
  x_sql_stmt                OUT NOCOPY VARCHAR2
);

PROCEDURE insert_data (
  p_info_rec                IN  info_rec_type,
  p_group_rec               IN  group_rec_type,
  p_member_rec              IN  group_rec_type
);

PROCEDURE query_member_assets (
  p_info_rec                IN  info_rec_type,
  p_group_rec               IN  group_rec_type,
  p_mrcsobtype              IN  VARCHAR2 default NULL    -- MRC: SOB Type
);

END FA_RX_GROUP;

/
