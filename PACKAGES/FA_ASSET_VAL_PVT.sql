--------------------------------------------------------
--  DDL for Package FA_ASSET_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_VAL_PVT" AUTHID CURRENT_USER as
/* $Header: FAVVALS.pls 120.26.12010000.23 2010/05/28 08:54:40 gigupta ship $   */

G_asset_key_required boolean;

FUNCTION validate
   (p_trans_rec          IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec     IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec      IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec      IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec    IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_dist_tbl     IN     FA_API_TYPES.asset_dist_tbl_type,
    p_inv_tbl            IN     FA_API_TYPES.inv_tbl_type,
    p_calling_fn         IN     VARCHAR2,
    p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_asset_number
   (p_transaction_type_code  IN    VARCHAR2,
    p_asset_number           IN    VARCHAR2,
    p_asset_id               IN    NUMBER   DEFAULT NULL,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_owned_leased
   (p_transaction_type_code  IN    VARCHAR2,
    p_owned_leased           IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_category
   (p_transaction_type_code  IN    VARCHAR2,
    p_category_id            IN    NUMBER,
    p_book_type_code         IN    VARCHAR2 DEFAULT NULL,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

-- Bug No#5708875
-- Addding validation for current units
--current units cannot be in fractions

FUNCTION validate_current_units
   (p_transaction_type_code  IN    VARCHAR2,
    p_current_units          IN    NUMBER,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_category_df
   (p_transaction_type_code  IN    VARCHAR2,
    p_cat_desc_flex          IN    FA_API_TYPES.desc_flex_rec_type,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_serial_number
   (p_transaction_type_code  IN    VARCHAR2,
    p_serial_number          IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_asset_key
   (p_transaction_type_code  IN    VARCHAR2,
    p_asset_key_ccid         IN    NUMBER,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_asset_type
   (p_transaction_type_code     IN  VARCHAR2,
    p_asset_type                IN  VARCHAR2,
    p_book_type_code            IN  VARCHAR2,
    p_category_id               IN  NUMBER,
    p_calling_fn                IN  VARCHAR2,
    p_log_level_rec             IN  FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_depreciate_flag
   (p_depreciate_flag      IN      VARCHAR2,
    p_calling_fn           IN      VARCHAR2,
    p_log_level_rec        IN      FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_supplier_name
   (p_transaction_type_code  IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_supplier_number
   (p_transaction_type_code  IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_asset_book
   (p_transaction_type_code IN     VARCHAR2,
    p_book_type_code        IN     VARCHAR2,
    p_asset_id              IN     NUMBER,
    p_calling_fn            IN     VARCHAR2,
    p_log_level_rec         IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_cost
   (p_transaction_type_code IN     VARCHAR2,
    p_cost                  IN     NUMBER,
    p_asset_type            IN     VARCHAR2,
    p_num_invoices          IN     NUMBER    DEFAULT 0,
    p_calling_fn            IN     VARCHAR2,
    p_log_level_rec         IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_assigned_to
   (p_transaction_type_code IN     VARCHAR2,
    p_assigned_to           IN     NUMBER,
    p_date                  IN     DATE  DEFAULT sysdate,
    p_calling_fn            IN     VARCHAR2,
    p_log_level_rec         IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_expense_ccid
   (p_expense_ccid              IN     NUMBER,
    p_gl_chart_id               IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_location_ccid
   (p_transaction_type_code IN     VARCHAR2,
    p_location_ccid         IN     NUMBER,
    p_calling_fn            IN     VARCHAR2,
    p_log_level_rec         IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_dpis
   (p_transaction_type_code      IN   VARCHAR2,
    p_book_type_code             IN   VARCHAR2,
    p_date_placed_in_service     IN   DATE,
    p_prorate_convention_code    IN   VARCHAR2 DEFAULT NULL,
    p_old_date_placed_in_service IN   DATE DEFAULT NULL,
    p_asset_id                   IN   NUMBER   DEFAULT NULL,
    p_db_rule_name               IN   VARCHAR2 DEFAULT NULL,  -- ENERGY
    p_rate_source_rule           IN   VARCHAR2 DEFAULT NULL,  -- ENERGY
    p_transaction_subtype        IN   VARCHAR2 DEFAULT 'EXPENSED',
    p_asset_type                 IN   VARCHAR2 DEFAULT NULL,
    p_calling_interface          IN   VARCHAR2 DEFAULT NULL,
    p_calling_fn                 IN   VARCHAR2,
    p_log_level_rec              IN   FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_rec_cost_reserve
   (p_transaction_type_code   IN   VARCHAR2,
    p_recoverable_cost        IN   NUMBER,
    p_deprn_reserve           IN   NUMBER,
    p_calling_fn              IN   VARCHAR2,
    p_log_level_rec           IN   FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_adj_rec_cost
   (p_adjusted_recoverable_cost IN NUMBER,
    p_deprn_reserve             IN NUMBER,
    p_calling_fn                IN VARCHAR2,
    p_log_level_rec             IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_ytd_reserve  /*Bug#9682863 - Modified the parameters - instead of individual value passing records. */
   (p_asset_hdr_rec             IN FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec            IN FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_new         IN FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_new       IN FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec                IN FA_API_TYPES.period_rec_type,
    p_asset_deprn_rec_old       IN FA_API_TYPES.asset_deprn_rec_type,    /*Fix for bug 8790562 */
    p_calling_fn                IN VARCHAR2,
    p_log_level_rec             IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_short_tax_year
   (p_book_type_code            IN     VARCHAR2,
    p_transaction_type_code     IN     VARCHAR2,
    p_asset_type                IN     VARCHAR2,
    p_short_fiscal_year_flag    IN     VARCHAR2,
    p_conversion_date           IN     DATE,
    px_orig_deprn_start_date    IN OUT NOCOPY DATE,
    p_date_placed_in_service    IN     DATE,
    p_ytd_deprn                 IN     NUMBER,
    p_deprn_reserve             IN     NUMBER,
    p_period_rec                IN     FA_API_TYPES.period_rec_type,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_trx_date_entered
   (p_transaction_type_code     IN    VARCHAR2,
    p_book_type_code            IN    VARCHAR2,
    p_transaction_date_entered  IN    DATE,
    p_period_rec                IN    FA_API_TYPES.period_rec_type,
    p_calling_fn                IN    VARCHAR2,
    p_log_level_rec             IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_amort_start_date
   (p_transaction_type_code     IN     VARCHAR2,
    p_asset_id                  IN     NUMBER,
    p_book_type_code            IN     VARCHAR2,
    p_date_placed_in_service    IN     DATE      DEFAULT NULL,
    p_conversion_date           IN     DATE      DEFAULT NULL,
    p_period_rec                IN     FA_API_TYPES.period_rec_type,
    p_amortization_start_date   IN     DATE,
    p_db_rule_name              IN     VARCHAR2 DEFAULT NULL,  -- ENERGY
    p_rate_source_rule          IN     VARCHAR2 DEFAULT NULL,  -- ENERGY
    p_transaction_key           IN     VARCHAR2 DEFAULT 'XX',
    x_amortization_start_date      OUT NOCOPY DATE,
    x_trxs_exist                   OUT NOCOPY VARCHAR2,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_life
   (p_deprn_method              IN     VARCHAR2,
    p_rate_source_rule          IN     VARCHAR2,
    p_life_in_months            IN     NUMBER,
    p_lim                       IN     NUMBER,
    p_user_id                   IN     NUMBER,
    p_curr_date                 IN     DATE,
    px_new_life                 IN OUT NOCOPY NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_payables_ccid
   (px_payables_ccid            IN OUT NOCOPY NUMBER,
    p_gl_chart_id               IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_fixed_assets_cost
   (p_fixed_assets_cost         IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_fixed_assets_units
   (p_fixed_assets_units        IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_payables_cost
   (p_payables_cost             IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_payables_units
   (p_payables_units            IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_po_vendor_id
   (p_po_vendor_id              IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_unit_of_measure
   (p_unit_of_measure           IN     VARCHAR2,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_salvage_value
   (p_salvage_value             IN     NUMBER,
    p_nbv                       IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_tag_number
   (p_tag_number                IN     VARCHAR2,
    p_mass_addition_id          IN     NUMBER    DEFAULT NULL,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_split_merged_code
   (p_split_merged_code         IN     VARCHAR2,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

/* Japan Tax Phase 3 -- Added New parameter */
FUNCTION validate_exp_after_amort
  (p_asset_id            IN     number,
   p_book                IN     varchar2,
   p_extended_flag       IN     BOOLEAN DEFAULT FALSE,
   p_log_level_rec       IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

FUNCTION validate_unplanned_exists
  (p_asset_id           IN     number,
   p_book               IN     varchar2,
   p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_period_of_addition
  (p_asset_id            IN     number,
   p_book                IN     varchar2,
   p_mode                IN     varchar2 DEFAULT 'ABSOLUTE',
   px_period_of_addition IN OUT NOCOPY varchar2,
   p_log_level_rec       IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

FUNCTION validate_fully_retired
  (p_asset_id            IN     number,
   p_book                IN     varchar2,
   p_log_level_rec       IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_add_to_asset_pending
  (p_asset_id           in  number,
   p_book               in  varchar2,
   p_log_level_rec      IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION validate_asset_id_exist
  (p_asset_id       in    number,
   p_log_level_rec  IN    FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION validate_ret_rst_pending
   (p_asset_id      in  number,
    p_book          in  varchar2,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION validate_fa_lookup_code
   (p_lookup_type   in  varchar2,
    p_lookup_code   in  varchar2,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION validate_dist_id
   (p_asset_id      in  number,
    p_dist_id       in  number,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION validate_corp_pending_ret
   (p_asset_id                  in  number,
    p_book                      in  varchar2,
    p_transaction_header_id_in  in  number,
    p_log_level_rec             IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN;
-- end of validations introduced by Retirement API

FUNCTION validate_parent_asset(
         p_parent_asset_id  IN number,
         p_asset_id         IN number,
         p_log_level_rec    IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_lease(
         p_asset_id      IN number,
         p_lease_id      IN number,
         p_log_level_rec IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_warranty (
  p_warranty_id                 IN     NUMBER,
  p_date_placed_in_service      IN     DATE,
  p_book_type_code              IN     VARCHAR2,
  p_log_level_rec               IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_property_type(p_property_type_code in VARCHAR2,
                                p_log_level_rec      IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_1245_1250_code(p_1245_1250_code in VARCHAR2,
                                 p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_group_asset
  (p_group_asset_id in NUMBER,
   p_book_type_code in VARCHAR2,
   p_asset_type     in VARCHAR2,
   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_disabled_flag
  (p_group_asset_id in NUMBER,
   p_book_type_code in VARCHAR2,
   p_old_flag       IN VARCHAR2,
   p_new_flag       IN VARCHAR2,
   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_group_info
  (p_group_asset_id in NUMBER,
   p_book_type_code in VARCHAR2,
   p_calling_fn     in VARCHAR2,
   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_over_depreciate
   (p_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type                 VARCHAR2,
    p_over_depreciate_option     VARCHAR2 default null,
    p_adjusted_recoverable_cost  NUMBER   default null,
    p_recoverable_cost           NUMBER   default null,
    p_deprn_reserve_new          NUMBER   default null,
    p_rate_source_rule           VARCHAR2 default null,
    p_deprn_basis_rule           VARCHAR2 default null,
    p_recapture_reserve_flag     VARCHAR2 default null,
    p_deprn_limit_type           VARCHAR2 default null,
    p_log_level_rec              FA_API_TYPES.log_level_rec_type) return boolean;

--
-- Function
--      validate_cost_change
--
-- Description
--      This function returns false if user entered cost/
--      salvage_value/allowed_deprn_limit_amount
--      which result in different sign from current sign.
--
FUNCTION validate_cost_change (
         p_asset_id               number,
         p_group_asset_id         number,
         p_book_type_code         varchar2,
         p_asset_type             varchar2,
         p_transaction_header_id  number,
         p_transaction_date       date,
         p_cost                   number default 0,
         p_cost_adj               number default 0,
         p_salvage_value          number default 0,
         p_salvage_value_adj      number default 0,
         p_deprn_limit_amount     number default 0,
         p_deprn_limit_amount_adj number default 0,
         p_mrc_sob_type_code      varchar2,
         p_set_of_books_id        number,
         p_over_depreciate_option varchar2,
         p_log_level_rec          FA_API_TYPES.log_level_rec_type) return boolean;

-- New function due for bug2846357
--
-- check if duplicate distribution info exist in p_asset_dist_tbl
-- current row( p_curr_index) of p_asset_dist_tbl is compared to
-- all of previous rows of p_asset_dist_tbl
-- to check for duplicates

FUNCTION validate_duplicate_dist (
         p_transaction_type_code IN             VARCHAR2,
         p_asset_dist_tbl        IN OUT NOCOPY  FA_API_TYPES.asset_dist_tbl_type,
         p_curr_index            IN             NUMBER,
         p_log_level_rec         IN             FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_polish
   (p_transaction_type_code     IN    VARCHAR2,
    p_method_code               IN    VARCHAR2,
    p_life_in_months            IN    NUMBER   DEFAULT NULL,
    p_asset_type                IN    VARCHAR2 DEFAULT NULL,
    p_bonus_rule                IN    VARCHAR2 DEFAULT NULL,
    p_ceiling_name              IN    VARCHAR2 DEFAULT NULL,
    p_deprn_limit_type          IN    VARCHAR2 DEFAULT NULL,
    p_group_asset_id            IN    NUMBER   DEFAULT NULL,
    p_date_placed_in_service    IN    DATE     DEFAULT NULL,
    p_calendar_period_open_date IN    DATE     DEFAULT NULL,
    p_ytd_deprn                 IN    NUMBER   DEFAULT NULL,
    p_deprn_reserve             IN    NUMBER   DEFAULT NULL,
    p_calling_fn                IN    VARCHAR2,
    p_log_level_rec             IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_jp250db
   (p_transaction_type_code   IN    VARCHAR2,
    p_book_type_code          IN    VARCHAR2,
    p_asset_id                IN    NUMBER,
    p_method_code             IN    VARCHAR2,
    p_life_in_months          IN    NUMBER   DEFAULT NULL,
    p_asset_type              IN    VARCHAR2 DEFAULT NULL,
    p_bonus_rule              IN    VARCHAR2 DEFAULT NULL,
    p_transaction_key         IN    VARCHAR2 DEFAULT NULL,
    p_cash_generating_unit_id IN    VARCHAR2 DEFAULT NULL,
    p_deprn_override_flag     IN    VARCHAR2 DEFAULT 'N',
    p_calling_fn              IN    VARCHAR2,
    p_log_level_rec           IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

--
-- Check to see that whether new super_group has already been used or not
-- If it is used by other group, raise error
-- Do not call this if the book is not primary book.

FUNCTION validate_super_group (
   p_book_type_code       IN VARCHAR2,
   p_old_super_group_id   IN NUMBER,
   p_new_super_group_id   IN NUMBER,
   p_calling_fn           IN VARCHAR2,
   p_log_level_rec        IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

FUNCTION validate_member_dpis
   (p_book_type_code             IN   VARCHAR2,
    p_date_placed_in_service     IN   DATE,
    p_group_asset_Id             IN   NUMBER,
    p_calling_fn                 IN   VARCHAR2,
    p_log_level_rec              IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION validate_egy_prod_date (                             -- ENERGY
   p_calendar_period_start_date IN DATE,                      -- ENERGY
   p_transaction_date           IN DATE,                      -- ENERGY
   p_transaction_key            IN VARCHAR2,
   p_rate_source_rule           IN VARCHAR2,                  -- ENERGY
   p_rule_name                  IN VARCHAR2,                  -- ENERGY
   p_calling_fn                 IN VARCHAR2,
   p_log_level_rec              IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN; -- ENERGY

-- Bug:5154035
FUNCTION validate_reval_exists (
    p_book_type_code       IN   VARCHAR2,
    p_asset_Id             IN   NUMBER,
    p_calling_fn           IN   VARCHAR2,
    p_log_level_rec        IN   FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;


/* Japan Tax Phase3 Prevent cost adjustment
   and method change for assets in extended depreciation */
FUNCTION validate_extended_asset (
   p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_fin_rec_old    IN     FA_API_TYPES.asset_fin_rec_type,
   p_asset_fin_rec_adj    IN     FA_API_TYPES.asset_fin_rec_type,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

--Adding new Functions for bug 7698030

FUNCTION validate_JP_STL_EXTND(
                    p_prior_deprn_method            IN VARCHAR2 DEFAULT NULL,
                    p_prior_basic_rate              IN NUMBER   DEFAULT NULL,
                    p_prior_adjusted_rate           IN NUMBER   DEFAULT NULL,
                    p_prior_life_in_months          IN NUMBER   DEFAULT NULL,
                    p_calling_fn                    IN VARCHAR2,
                    p_log_level_rec                 IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

FUNCTION validate_earl_deprn_limit(
                    p_prior_deprn_limit_amount      IN NUMBER   DEFAULT NULL,
                    p_prior_deprn_limit             IN NUMBER   DEFAULT NULL,
                    p_prior_deprn_limit_type        IN VARCHAR2 DEFAULT NULL,
                    p_calling_fn                    IN VARCHAR2,
                    p_log_level_rec                 IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

FUNCTION validate_period_fully_reserved(
                    p_book_type_code                IN VARCHAR2,
                    p_pc_fully_reserved             IN NUMBER   DEFAULT NULL,
                    p_date_placed_in_service        IN DATE,
                    p_calling_fn                    IN VARCHAR2,
                    p_log_level_rec                 IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

FUNCTION validate_fst_prd_extd_deprn(
                    p_book_type_code                IN VARCHAR2,
                    p_extended_deprn_period         IN NUMBER   DEFAULT NULL,
                    p_date_placed_in_service        IN DATE,
                    p_calling_fn                    IN VARCHAR2,
                    p_log_level_rec                 IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

FUNCTION validate_NOT_JP_STL_EXTND(
                    p_book_type_code                IN VARCHAR2,
                    p_deprn_limit                   IN NUMBER   DEFAULT NULL,
                    p_sp_deprn_limit                IN NUMBER   DEFAULT NULL,
                    p_deprn_reserve                 IN NUMBER   DEFAULT NULL,
                    p_asset_type                    IN VARCHAR2 DEFAULT NULL,
                    p_pc_fully_reserved             IN NUMBER   DEFAULT NULL,
                    p_date_placed_in_service        IN DATE,
                    p_cost                          IN NUMBER   DEFAULT NULL,
                    p_calling_fn                    IN VARCHAR2,
                    p_log_level_rec                 IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

FUNCTION validate_JP_250_DB(
                    p_deprn_method_code             IN VARCHAR2 DEFAULT NULL,
                    p_cost                          IN NUMBER   DEFAULT NULL,
                    p_nbv_at_switch                 IN NUMBER   DEFAULT NULL,
                    p_deprn_reserve                 IN NUMBER   DEFAULT NULL,
                    p_ytd_deprn                     IN NUMBER   DEFAULT NULL,
                    p_calling_fn                    IN VARCHAR2,
                    p_log_level_rec                 IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

-- End of adding new Fuctions 7698030

FUNCTION validate_reserve_transfer (
    p_book_type_code         IN    VARCHAR2 DEFAULT NULL,
    p_asset_id               IN    NUMBER   DEFAULT NULL,
    p_transfer_amount        IN    NUMBER   DEFAULT 0,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

/* Bug#8351285-To validate change of salvage_type or deprn_limit_type of group asset */
FUNCTION validate_sal_deprn_sum (
    p_asset_hdr_rec        IN   FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_old    IN   FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj    IN   FA_API_TYPES.asset_fin_rec_type,
    p_log_level_rec        IN   FA_API_TYPES.log_level_rec_type default null
   )  RETURN BOOLEAN;

FUNCTION validate_impairment_exists
  (p_asset_id           IN     number,
   p_book               IN     varchar2,
   p_mrc_sob_type_code  IN     varchar2,
   p_set_of_books_id    IN     number,
   p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type
   ) RETURN BOOLEAN ;

/*Bug# 8527619 This function is called from public APIs to check if group will become over depreciate
  NBV should not have sign different than cost, when over_depreciation_option is set to NO*/
FUNCTION validate_over_depreciation (
    p_asset_hdr_rec        IN  fa_api_types.asset_hdr_rec_type,
    p_asset_fin_rec        IN  FA_API_TYPES.asset_fin_rec_type default null,
    p_validation_type      IN  varchar2,
    p_cost_adj             IN  number,
    p_rsv_adj              IN  number,
    p_asset_retire_rec     IN  FA_API_TYPES.asset_retire_rec_type default null,
    p_log_level_rec        IN  FA_API_TYPES.log_level_rec_type default null
   )  RETURN BOOLEAN;

   FUNCTION validate_grp_track_method(
           p_asset_fin_rec_old         IN fa_api_types.asset_fin_rec_type,
           p_asset_fin_rec_new         IN fa_api_types.asset_fin_rec_type,
	   p_group_reclass_options_rec IN FA_API_TYPES.group_reclass_options_rec_type,
	   p_log_level_rec             IN FA_API_TYPES.log_level_rec_type DEFAULT NULL) RETURN BOOLEAN;

/*Bug 8601485 - Verify the if transfer date of asset is before DPIS */
FUNCTION validate_asset_transfer_date
   (p_asset_hdr_rec   IN  FA_API_TYPES.asset_hdr_rec_type,
    p_trans_rec       IN  FA_API_TYPES.trans_rec_type,
    p_calling_fn      IN VARCHAR2,
    p_log_level_rec   IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

/* Bug#8584206-To validate type of transactions allowed on Energy UOP assets  */
FUNCTION validate_energy_transactions (
             p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
             p_asset_type_rec       IN     FA_API_TYPES.asset_type_rec_type default null,
             p_asset_fin_rec_old    IN     FA_API_TYPES.asset_fin_rec_type default null,
             p_asset_fin_rec_adj    IN     FA_API_TYPES.asset_fin_rec_type  default null,
             p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
             p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

/* Bug#8633654-To validate reinstatement possible or not */
FUNCTION validate_mbr_reins_possible (
            p_asset_retire_rec IN     FA_API_TYPES.asset_retire_rec_type,
            p_asset_fin_rec    IN     FA_API_TYPES.asset_fin_rec_type,
            p_log_level_rec    IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

-- Bug 8722521 : Validation for Japan methods during Tax upload
FUNCTION validate_jp_taxupl (
   p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
   p_asset_type_rec       IN     FA_API_TYPES.asset_type_rec_type,
   p_asset_fin_rec        IN     FA_API_TYPES.asset_fin_rec_type,
   p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_deprn_rec      IN     FA_API_TYPES.asset_deprn_rec_type,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

--Bug 8828394 - Group Asset ID should be valid Group Asset ID
FUNCTION validate_group_asset_id(
   p_asset_id      IN   NUMBER,
   p_log_level_rec IN   FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

-- Bug 8471701-To prevent reserve change if any 'B' row distribution is inactive
FUNCTION validate_ltd_deprn_change(
    p_book_type_code       IN   VARCHAR2,
    p_asset_Id             IN   NUMBER,
    p_calling_fn           IN   VARCHAR2,
    p_log_level_rec        IN   FA_API_TYPES.log_level_rec_type
   ) RETURN BOOLEAN;
-- End Bug 8471701
/*phase5 This function will validate if current transaction is overlapping to any previously done impairment*/
FUNCTION check_overlapping_impairment (
             p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
             p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
             p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

/*phase5 This function will restrict any impairment posted on Asset added with depreciate flag NO and wiithout reserve*/
FUNCTION check_non_depreciating_asset (
   p_asset_id       IN   NUMBER,
   p_book_type_code IN   VARCHAR2,
   p_log_level_rec  IN   FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

END FA_ASSET_VAL_PVT;

/
