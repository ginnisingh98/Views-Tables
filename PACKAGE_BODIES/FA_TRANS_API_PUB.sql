--------------------------------------------------------
--  DDL for Package Body FA_TRANS_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANS_API_PUB" AS
/* $Header: FAPTAPIB.pls 120.26.12010000.2 2009/07/19 12:04:23 glchen ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE do_addition (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_asset_id                        OUT NOCOPY NUMBER,
     x_asset_number                    OUT NOCOPY VARCHAR2,
     x_transaction_header_id           OUT NOCOPY NUMBER,
     x_dist_transaction_header_id      OUT NOCOPY NUMBER,
     -- Transaction Info (Books) --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_transaction_subtype          IN     VARCHAR2 DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Transaction Info (Distributions) --
     p_dist_transaction_name        IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute1              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute2              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute3              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute4              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute5              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute6              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute7              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute8              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute9              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute10             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute11             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute12             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute13             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute14             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute15             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute_category_code IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER   DEFAULT NULL,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Description Info --
     p_asset_number                 IN     VARCHAR2 DEFAULT NULL,
     p_description                  IN     VARCHAR2,
     p_tag_number                   IN     VARCHAR2 DEFAULT NULL,
     p_serial_number                IN     VARCHAR2 DEFAULT NULL,
     p_asset_key_ccid               IN     NUMBER   DEFAULT NULL,
     p_parent_asset_id              IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL,
     p_manufacturer_name            IN     VARCHAR2 DEFAULT NULL,
     p_model_number                 IN     VARCHAR2 DEFAULT NULL,
     p_warranty_id                  IN     NUMBER   DEFAULT NULL,
     p_property_type_code           IN     VARCHAR2,
     p_property_1245_1250_code      IN     VARCHAR2,
     p_in_use_flag                  IN     VARCHAR2,
     p_inventorial                  IN     VARCHAR2 DEFAULT NULL,
     p_commitment	   	    IN     VARCHAR2 DEFAULT NULL,
     p_investment_law		    IN     VARCHAR2 DEFAULT NULL,
     p_owned_leased                 IN     VARCHAR2,
     p_new_used                     IN     VARCHAR2,
     p_lease_id                     IN     NUMBER   DEFAULT NULL,
     p_ls_attribute1                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute2                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute3                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute4                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute5                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute6                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute7                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute8                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute9                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute10               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute11               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute12               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute13               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute14               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute15               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute_category_code   IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute1         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute2         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute3         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute4         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute5         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute6         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute7         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute8         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute9         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute10        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute11        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute12        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute13        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute14        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute15        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute16        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute17        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute18        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute19        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute20        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute_category IN     VARCHAR2 DEFAULT NULL,
     -- Asset Type Info --
     p_asset_type                   IN     VARCHAR2,
     -- Asset Category Info --
     p_category_id                  IN     NUMBER,
     p_cat_attribute1               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute2               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute3               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute4               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute5               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute6               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute7               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute8               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute9               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute10              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute11              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute12              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute13              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute14              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute15              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute16              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute17              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute18              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute19              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute20              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute21              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute22              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute23              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute24              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute25              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute26              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute27              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute28              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute29              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute30              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute_category_code  IN     VARCHAR2 DEFAULT NULL,
     p_context                      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Hierarchy Info --
     p_parent_hierarchy_id          IN     NUMBER   DEFAULT NULL,
     -- Asset Financial Info --
     p_cost                         IN     NUMBER,
     p_original_cost                IN     NUMBER,
     p_unrevalued_cost              IN     NUMBER   DEFAULT NULL,
     p_salvage_value                IN     NUMBER,
     p_ceiling_name                 IN     VARCHAR2 DEFAULT NULL,
     p_reval_ceiling                IN     NUMBER   DEFAULT NULL,
     p_depreciate_flag              IN     VARCHAR2,
     -- HH group ed.
     p_disabled_flag                IN     VARCHAR2 DEFAULT NULL,
     p_date_placed_in_service       IN     DATE,
     p_prorate_convention_code      IN     VARCHAR2,
     p_deprn_method_code            IN     VARCHAR2,
     p_life_in_months               IN     NUMBER   DEFAULT NULL,
     p_basic_rate                   IN     NUMBER   DEFAULT NULL,
     p_adjusted_rate                IN     NUMBER   DEFAULT NULL,
     p_production_capacity          IN     NUMBER   DEFAULT NULL,
     p_unit_of_measure              IN     VARCHAR2 DEFAULT NULL,
     p_bonus_rule                   IN     VARCHAR2 DEFAULT NULL,
     p_itc_amount_id                IN     NUMBER   DEFAULT NULL,
     p_short_fiscal_year_flag       IN     VARCHAR2 DEFAULT NULL,
     p_conversion_date              IN     DATE     DEFAULT NULL,
     p_orig_deprn_start_date        IN     DATE     DEFAULT NULL,
     p_group_asset_id               IN     NUMBER   DEFAULT NULL,
/* toru */
     -- Addition for Group Depreciation
     p_percent_salvage_value        IN     NUMBER   DEFAULT NULL,
     p_allowed_deprn_limit          IN     NUMBER   DEFAULT NULL,
     p_allowed_deprn_limit_amount   IN     NUMBER   DEFAULT NULL,
     p_super_group_id               IN     NUMBER   DEFAULT NULL,
     p_reduction_rate               IN     NUMBER   DEFAULT NULL,
     p_reduce_addition_flag         IN     VARCHAR2 DEFAULT NULL,
     p_reduce_adjustment_flag       IN     VARCHAR2 DEFAULT NULL,
     p_reduce_retirement_flag       IN     VARCHAR2 DEFAULT NULL,
     p_over_depreciate_option       IN     VARCHAR2 DEFAULT NULL,
     p_recognize_gain_loss          IN     VARCHAR2 DEFAULT NULL,
     p_recapture_reserve_flag       IN     VARCHAR2 DEFAULT NULL,
     p_limit_proceeds_flag          IN     VARCHAR2 DEFAULT NULL,
     p_terminal_gain_loss           IN     VARCHAR2 DEFAULT NULL,
     p_exclude_proceeds_from_basis  IN     VARCHAR2 DEFAULT NULL,
     p_retirement_deprn_option      IN     VARCHAR2 DEFAULT NULL,
     p_salvage_type                 IN     VARCHAR2 DEFAULT NULL,
     p_deprn_limit_type             IN     VARCHAR2 DEFAULT NULL,
     p_tracking_method              IN     VARCHAR2 DEFAULT NULL,
     p_allocate_to_fully_rsv_flag   IN     VARCHAR2 DEFAULT NULL,
     p_allocate_to_fully_ret_flag   IN     VARCHAR2 DEFAULT NULL,
     p_excess_allocation_option     IN     VARCHAR2 DEFAULT NULL,
     p_depreciation_option          IN     VARCHAR2 DEFAULT NULL,
     p_member_rollup_flag           IN     VARCHAR2 DEFAULT NULL,
     p_ytd_proceeds                 IN     NUMBER   DEFAULT NULL,
     p_ltd_proceeds                 IN     NUMBER   DEFAULT NULL,
     p_exclude_fully_rsv_flag       IN     VARCHAR2 DEFAULT NULL,
     p_eofy_reserve                 IN     NUMBER   DEFAULT NULL,
     p_reclass_transfer_type        IN     VARCHAR2 DEFAULT NULL,
     p_reclass_transfer_amount      IN     NUMBER   DEFAULT NULL,
     p_reclass_src_expense          IN     NUMBER   DEFAULT NULL,
     p_reclass_dest_expense         IN     NUMBER   DEFAULT NULL,
     p_reclass_src_eofy_reserve     IN     NUMBER   DEFAULT NULL,
     p_reclass_dest_eofy_reserve    IN     NUMBER   DEFAULT NULL,
     -- End of Addition for Group Depreciation
/* Etoru */
     p_bk_global_attribute1         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute2         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute3         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute4         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute5         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute6         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute7         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute8         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute9         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute10        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute11        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute12        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute13        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute14        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute15        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute16        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute17        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute18        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute19        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute20        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute_category IN     VARCHAR2 DEFAULT NULL,
     -- Asset Depreciation Info --
     p_ytd_deprn                    IN     NUMBER   DEFAULT NULL,
     p_deprn_reserve                IN     NUMBER   DEFAULT NULL,
     p_reval_deprn_reserve          IN     NUMBER   DEFAULT NULL,
     p_ytd_production               IN     NUMBER   DEFAULT NULL,
     p_ltd_production               IN     NUMBER   DEFAULT NULL,
     -- IAS36 Impairment Info --
     p_cash_generating_unit_id      IN     NUMBER   DEFAULT NULL,
-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
     p_nbv_at_switch                IN     NUMBER   DEFAULT NULL,
     p_prior_deprn_limit_type       IN     VARCHAR2 DEFAULT NULL,
     p_prior_deprn_limit_amount     IN     NUMBER   DEFAULT NULL,
     p_prior_deprn_limit            IN     NUMBER   DEFAULT NULL,
     p_period_counter_fully_rsrved  IN     NUMBER   DEFAULT NULL,
     p_extended_depreciation_period IN     NUMBER   DEFAULT NULL,
     p_prior_deprn_method           IN     VARCHAR2 DEFAULT NULL,
     p_prior_life_in_months         IN     NUMBER   DEFAULT NULL,
     p_prior_basic_rate             IN     NUMBER   DEFAULT NULL,
     p_prior_adjusted_rate          IN     NUMBER   DEFAULT NULL,
     p_extended_deprn_flag          IN     VARCHAR2 DEFAULT NULL
-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
) AS

    l_trans_rec                 fa_api_types.trans_rec_type;
    l_dist_trans_rec            fa_api_types.trans_rec_type;
    l_asset_hdr_rec             fa_api_types.asset_hdr_rec_type;
    l_asset_desc_rec            fa_api_types.asset_desc_rec_type;
    l_asset_cat_rec             fa_api_types.asset_cat_rec_type;
    l_asset_hierarchy_rec       fa_api_types.asset_hierarchy_rec_type;
    l_asset_type_rec            fa_api_types.asset_type_rec_type;
    l_asset_fin_rec             fa_api_types.asset_fin_rec_type;
    l_asset_deprn_rec           fa_api_types.asset_deprn_rec_type;
    l_asset_dist_rec            fa_api_types.asset_dist_rec_type;
    l_asset_dist_tbl            fa_api_types.asset_dist_tbl_type;
    l_inv_rec                   fa_api_types.inv_rec_type;
    l_inv_tbl                   fa_api_types.inv_tbl_type;
/* toru */
    l_group_reclass_options_rec fa_api_types.group_reclass_options_rec_type;
/* Etoru */

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   l_trans_rec.transaction_subtype := p_transaction_subtype;
   --l_trans_rec.transaction_key :=
   l_trans_rec.amortization_start_date := p_amortization_start_date;
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- Fix for Bug #2797309.  For CIP Assets, amortization_start_date
   -- should always be NULL.
   if (p_asset_type = 'CIP') then
      l_trans_rec.amortization_start_date := NULL;
   end if;

   -- ***** Distribution Transaction Info ***** --
   --l_dist_trans_rec.transaction_header_id :=
   l_dist_trans_rec.transaction_name := p_dist_transaction_name;
   l_dist_trans_rec.calling_interface := p_calling_interface;
   l_dist_trans_rec.desc_flex.attribute1 := p_dist_attribute1;
   l_dist_trans_rec.desc_flex.attribute2 := p_dist_attribute2;
   l_dist_trans_rec.desc_flex.attribute3 := p_dist_attribute3;
   l_dist_trans_rec.desc_flex.attribute4 := p_dist_attribute4;
   l_dist_trans_rec.desc_flex.attribute5 := p_dist_attribute5;
   l_dist_trans_rec.desc_flex.attribute6 := p_dist_attribute6;
   l_dist_trans_rec.desc_flex.attribute7 := p_dist_attribute7;
   l_dist_trans_rec.desc_flex.attribute8 := p_dist_attribute8;
   l_dist_trans_rec.desc_flex.attribute9 := p_dist_attribute9;
   l_dist_trans_rec.desc_flex.attribute10 := p_dist_attribute10;
   l_dist_trans_rec.desc_flex.attribute11 := p_dist_attribute11;
   l_dist_trans_rec.desc_flex.attribute12 := p_dist_attribute12;
   l_dist_trans_rec.desc_flex.attribute13 := p_dist_attribute13;
   l_dist_trans_rec.desc_flex.attribute14 := p_dist_attribute14;
   l_dist_trans_rec.desc_flex.attribute15 := p_dist_attribute15;
   l_dist_trans_rec.desc_flex.attribute_category_code :=
       p_dist_attribute_category_code;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_asset_id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Descriptive Info ***** --
   l_asset_desc_rec.asset_number := p_asset_number;
   l_asset_desc_rec.description := p_description;
   l_asset_desc_rec.tag_number := p_tag_number;
   l_asset_desc_rec.serial_number := p_serial_number;
   l_asset_desc_rec.asset_key_ccid := p_asset_key_ccid;
   l_asset_desc_rec.parent_asset_id := p_parent_asset_id;
   l_asset_desc_rec.manufacturer_name := p_manufacturer_name;
   l_asset_desc_rec.model_number := p_model_number;
   l_asset_desc_rec.warranty_id := p_warranty_id;
   l_asset_desc_rec.lease_id := p_lease_id;
   l_asset_desc_rec.in_use_flag := p_in_use_flag;

   -- toru
   -- Inventorial is always 'NO' for group asset
   --
   if (p_asset_type = 'GROUP') then
    l_asset_desc_rec.inventorial := 'NO';
   else
     l_asset_desc_rec.inventorial := p_inventorial;
   end if;

   l_asset_desc_rec.property_type_code := p_property_type_code;
   l_asset_desc_rec.property_1245_1250_code := p_property_1245_1250_code;
   l_asset_desc_rec.owned_leased := p_owned_leased;
   l_asset_desc_rec.new_used := p_new_used;
   l_asset_desc_rec.commitment := p_commitment;
   l_asset_desc_rec.investment_law := p_investment_law;
   --l_asset_desc_rec.unit_adjustment_flag  :=
   --l_asset_desc_rec.add_cost_je_flag :=
   l_asset_desc_rec.status := p_status;
   l_asset_desc_rec.lease_desc_flex.attribute1 := p_ls_attribute1;
   l_asset_desc_rec.lease_desc_flex.attribute2 := p_ls_attribute2;
   l_asset_desc_rec.lease_desc_flex.attribute3 := p_ls_attribute3;
   l_asset_desc_rec.lease_desc_flex.attribute4 := p_ls_attribute4;
   l_asset_desc_rec.lease_desc_flex.attribute5 := p_ls_attribute5;
   l_asset_desc_rec.lease_desc_flex.attribute6 := p_ls_attribute6;
   l_asset_desc_rec.lease_desc_flex.attribute7 := p_ls_attribute7;
   l_asset_desc_rec.lease_desc_flex.attribute8 := p_ls_attribute8;
   l_asset_desc_rec.lease_desc_flex.attribute9 := p_ls_attribute9;
   l_asset_desc_rec.lease_desc_flex.attribute10 := p_ls_attribute10;
   l_asset_desc_rec.lease_desc_flex.attribute11 := p_ls_attribute11;
   l_asset_desc_rec.lease_desc_flex.attribute12 := p_ls_attribute12;
   l_asset_desc_rec.lease_desc_flex.attribute13 := p_ls_attribute13;
   l_asset_desc_rec.lease_desc_flex.attribute14 := p_ls_attribute14;
   l_asset_desc_rec.lease_desc_flex.attribute15 := p_ls_attribute15;
   l_asset_desc_rec.lease_desc_flex.attribute_category_code :=
      p_ls_attribute_category_code;
   l_asset_desc_rec.global_desc_flex.attribute1 := p_ad_global_attribute1;
   l_asset_desc_rec.global_desc_flex.attribute2 := p_ad_global_attribute2;
   l_asset_desc_rec.global_desc_flex.attribute3 := p_ad_global_attribute3;
   l_asset_desc_rec.global_desc_flex.attribute4 := p_ad_global_attribute4;
   l_asset_desc_rec.global_desc_flex.attribute5 := p_ad_global_attribute5;
   l_asset_desc_rec.global_desc_flex.attribute6 := p_ad_global_attribute6;
   l_asset_desc_rec.global_desc_flex.attribute7 := p_ad_global_attribute7;
   l_asset_desc_rec.global_desc_flex.attribute8 := p_ad_global_attribute8;
   l_asset_desc_rec.global_desc_flex.attribute9 := p_ad_global_attribute9;
   l_asset_desc_rec.global_desc_flex.attribute10 := p_ad_global_attribute10;
   l_asset_desc_rec.global_desc_flex.attribute11 := p_ad_global_attribute11;
   l_asset_desc_rec.global_desc_flex.attribute12 := p_ad_global_attribute12;
   l_asset_desc_rec.global_desc_flex.attribute13 := p_ad_global_attribute13;
   l_asset_desc_rec.global_desc_flex.attribute14 := p_ad_global_attribute14;
   l_asset_desc_rec.global_desc_flex.attribute15 := p_ad_global_attribute15;
   l_asset_desc_rec.global_desc_flex.attribute16 := p_ad_global_attribute16;
   l_asset_desc_rec.global_desc_flex.attribute17 := p_ad_global_attribute17;
   l_asset_desc_rec.global_desc_flex.attribute18 := p_ad_global_attribute18;
   l_asset_desc_rec.global_desc_flex.attribute19 := p_ad_global_attribute19;
   l_asset_desc_rec.global_desc_flex.attribute20 := p_ad_global_attribute20;
   l_asset_desc_rec.global_desc_flex.attribute_category_code :=
      p_ad_global_attribute_category;

   -- ***** Asset Type Info ***** --
   l_asset_type_rec.asset_type := p_asset_type;

   -- ***** Asset Category Info ***** --
   l_asset_cat_rec.category_id := p_category_id;
   l_asset_cat_rec.desc_flex.attribute1 := p_cat_attribute1;
   l_asset_cat_rec.desc_flex.attribute2 := p_cat_attribute2;
   l_asset_cat_rec.desc_flex.attribute3 := p_cat_attribute3;
   l_asset_cat_rec.desc_flex.attribute4 := p_cat_attribute4;
   l_asset_cat_rec.desc_flex.attribute5 := p_cat_attribute5;
   l_asset_cat_rec.desc_flex.attribute6 := p_cat_attribute6;
   l_asset_cat_rec.desc_flex.attribute7 := p_cat_attribute7;
   l_asset_cat_rec.desc_flex.attribute8 := p_cat_attribute8;
   l_asset_cat_rec.desc_flex.attribute9 := p_cat_attribute9;
   l_asset_cat_rec.desc_flex.attribute10 := p_cat_attribute10;
   l_asset_cat_rec.desc_flex.attribute11 := p_cat_attribute11;
   l_asset_cat_rec.desc_flex.attribute12 := p_cat_attribute12;
   l_asset_cat_rec.desc_flex.attribute13 := p_cat_attribute13;
   l_asset_cat_rec.desc_flex.attribute14 := p_cat_attribute14;
   l_asset_cat_rec.desc_flex.attribute15 := p_cat_attribute15;
   l_asset_cat_rec.desc_flex.attribute16 := p_cat_attribute16;
   l_asset_cat_rec.desc_flex.attribute17 := p_cat_attribute17;
   l_asset_cat_rec.desc_flex.attribute18 := p_cat_attribute18;
   l_asset_cat_rec.desc_flex.attribute19 := p_cat_attribute19;
   l_asset_cat_rec.desc_flex.attribute20 := p_cat_attribute20;
   l_asset_cat_rec.desc_flex.attribute21 := p_cat_attribute21;
   l_asset_cat_rec.desc_flex.attribute22 := p_cat_attribute22;
   l_asset_cat_rec.desc_flex.attribute23 := p_cat_attribute23;
   l_asset_cat_rec.desc_flex.attribute24 := p_cat_attribute24;
   l_asset_cat_rec.desc_flex.attribute25 := p_cat_attribute25;
   l_asset_cat_rec.desc_flex.attribute26 := p_cat_attribute26;
   l_asset_cat_rec.desc_flex.attribute27 := p_cat_attribute27;
   l_asset_cat_rec.desc_flex.attribute28 := p_cat_attribute28;
   l_asset_cat_rec.desc_flex.attribute29 := p_cat_attribute29;
   l_asset_cat_rec.desc_flex.attribute30 := p_cat_attribute30;
   l_asset_cat_rec.desc_flex.attribute_category_code :=
      p_cat_attribute_category_code;
   l_asset_cat_rec.desc_flex.context := p_context;

   -- ***** Asset Hierarchy Info ***** --
   l_asset_hierarchy_rec.parent_hierarchy_id := p_parent_hierarchy_id;

   -- ***** Asset Financial Info ***** --
   l_asset_fin_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
   l_asset_fin_rec.date_placed_in_service := p_date_placed_in_service;
   l_asset_fin_rec.deprn_method_code := p_deprn_method_code;
   l_asset_fin_rec.life_in_months := p_life_in_months;
   l_asset_fin_rec.cost := p_cost;
   l_asset_fin_rec.original_cost := p_original_cost;
   l_asset_fin_rec.unrevalued_cost := p_unrevalued_cost;
   l_asset_fin_rec.salvage_value := p_salvage_value;
   l_asset_fin_rec.prorate_convention_code := p_prorate_convention_code;
   l_asset_fin_rec.depreciate_flag := p_depreciate_flag;
   --HH group ed.
   l_asset_fin_rec.disabled_flag := p_disabled_flag;
   l_asset_fin_rec.itc_amount_id := p_itc_amount_id;
   l_asset_fin_rec.basic_rate := p_basic_rate;
   l_asset_fin_rec.adjusted_rate := p_adjusted_rate;
   l_asset_fin_rec.bonus_rule := p_bonus_rule;
   l_asset_fin_rec.ceiling_name := p_ceiling_name;
   --l_asset_fin_rec.idled_flag :=
   l_asset_fin_rec.production_capacity := p_production_capacity;
   l_asset_fin_rec.reval_ceiling := p_reval_ceiling;
   l_asset_fin_rec.unit_of_measure := p_unit_of_measure;
   --@@@l_asset_fin_rec.allowed_deprn_limit := p_allowed_deprn_limit;
   --l_asset_fin_rec.allowed_deprn_limit_amount := p_allowed_deprn_limit_amount;
/* toru */
   l_asset_fin_rec.percent_salvage_value := p_percent_salvage_value;
   l_asset_fin_rec.allowed_deprn_limit := p_allowed_deprn_limit;
   l_asset_fin_rec.allowed_deprn_limit_amount := p_allowed_deprn_limit_amount;
/* Etoru */
   l_asset_fin_rec.short_fiscal_year_flag := p_short_fiscal_year_flag;
   l_asset_fin_rec.conversion_date := p_conversion_date;
   l_asset_fin_rec.orig_deprn_start_date := p_orig_deprn_start_date;
   l_asset_fin_rec.group_asset_id := p_group_asset_id;
/* toru */
   l_asset_fin_rec.super_group_id := p_super_group_id;
   l_asset_fin_rec.reduction_rate := p_reduction_rate;
   l_asset_fin_rec.reduce_addition_flag := p_reduce_addition_flag;
   l_asset_fin_rec.reduce_adjustment_flag := p_reduce_adjustment_flag;
   l_asset_fin_rec.reduce_retirement_flag := p_reduce_retirement_flag;
   l_asset_fin_rec.over_depreciate_option := p_over_depreciate_option;
   l_asset_fin_rec.recognize_gain_loss := p_recognize_gain_loss;
   l_asset_fin_rec.recapture_reserve_flag := p_recapture_reserve_flag;
   l_asset_fin_rec.limit_proceeds_flag := p_limit_proceeds_flag;
   l_asset_fin_rec.terminal_gain_loss := p_terminal_gain_loss;
   l_asset_fin_rec.exclude_proceeds_from_basis := p_exclude_proceeds_from_basis;
   l_asset_fin_rec.retirement_deprn_option := p_retirement_deprn_option;
   l_asset_fin_rec.salvage_type := p_salvage_type;
   l_asset_fin_rec.deprn_limit_type := p_deprn_limit_type;
   l_asset_fin_rec.tracking_method := p_tracking_method;
   l_asset_fin_rec.allocate_to_fully_rsv_flag := p_allocate_to_fully_rsv_flag;
   l_asset_fin_rec.allocate_to_fully_ret_flag := p_allocate_to_fully_ret_flag;
   l_asset_fin_rec.excess_allocation_option := p_excess_allocation_option;
   l_asset_fin_rec.depreciation_option := p_depreciation_option;
   l_asset_fin_rec.member_rollup_flag := p_member_rollup_flag;
   l_asset_fin_rec.ytd_proceeds := p_ytd_proceeds;
   l_asset_fin_rec.ltd_proceeds := p_ltd_proceeds;
   l_asset_fin_rec.exclude_fully_rsv_flag := p_exclude_fully_rsv_flag;
   l_asset_fin_rec.eofy_reserve := p_eofy_reserve;

   l_asset_fin_rec.cash_generating_unit_id := p_cash_generating_unit_id;

-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
l_asset_fin_rec.nbv_at_switch                 :=  p_nbv_at_switch;
l_asset_fin_rec.prior_deprn_limit_type        :=  p_prior_deprn_limit_type     ;
l_asset_fin_rec.prior_deprn_limit_amount      :=  p_prior_deprn_limit_amount ;
l_asset_fin_rec.prior_deprn_limit             :=  p_prior_deprn_limit        ;
l_asset_fin_rec.period_counter_fully_reserved :=  p_period_counter_fully_rsrved        ;
l_asset_fin_rec.extended_depreciation_period  :=  p_extended_depreciation_period         ;
l_asset_fin_rec.prior_deprn_method            :=  p_prior_deprn_method      ;
l_asset_fin_rec.prior_life_in_months          :=  p_prior_life_in_months    ;
l_asset_fin_rec.prior_basic_rate              :=  p_prior_basic_rate        ;
l_asset_fin_rec.prior_adjusted_rate  	      :=  p_prior_adjusted_rate     ;
l_asset_fin_rec.extended_deprn_flag  	      :=  p_extended_deprn_flag     ;

-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End

/* Etoru */
   l_asset_fin_rec.global_attribute1 := p_bk_global_attribute1;
   l_asset_fin_rec.global_attribute2 := p_bk_global_attribute2;
   l_asset_fin_rec.global_attribute3 := p_bk_global_attribute3;
   l_asset_fin_rec.global_attribute4 := p_bk_global_attribute4;
   l_asset_fin_rec.global_attribute5 := p_bk_global_attribute5;
   l_asset_fin_rec.global_attribute6 := p_bk_global_attribute6;
   l_asset_fin_rec.global_attribute7 := p_bk_global_attribute7;
   l_asset_fin_rec.global_attribute8 := p_bk_global_attribute8;
   l_asset_fin_rec.global_attribute9 := p_bk_global_attribute9;
   l_asset_fin_rec.global_attribute10 := p_bk_global_attribute10;
   l_asset_fin_rec.global_attribute11 := p_bk_global_attribute11;
   l_asset_fin_rec.global_attribute12 := p_bk_global_attribute12;
   l_asset_fin_rec.global_attribute13 := p_bk_global_attribute13;
   l_asset_fin_rec.global_attribute14 := p_bk_global_attribute14;
   l_asset_fin_rec.global_attribute15 := p_bk_global_attribute15;
   l_asset_fin_rec.global_attribute16 := p_bk_global_attribute16;
   l_asset_fin_rec.global_attribute17 := p_bk_global_attribute17;
   l_asset_fin_rec.global_attribute18 := p_bk_global_attribute18;
   l_asset_fin_rec.global_attribute19 := p_bk_global_attribute19;
   l_asset_fin_rec.global_attribute20 := p_bk_global_attribute20;
   l_asset_fin_rec.global_attribute_category := p_bk_global_attribute_category;

   -- ***** Asset Depreciation Info ***** --
   l_asset_deprn_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
   --l_asset_deprn_rec.deprn_amount :=
   l_asset_deprn_rec.ytd_deprn := p_ytd_deprn;
   l_asset_deprn_rec.deprn_reserve := p_deprn_reserve;
   --l_asset_deprn_rec.prior_fy_expense :=
   --l_asset_deprn_rec.bonus_deprn_amount :=
   --l_asset_deprn_rec.bonus_ytd_deprn :=
   --l_asset_deprn_rec.prior_fy_bonus_expense :=
   --l_asset_deprn_rec.reval_amortization :=
   --l_asset_deprn_rec.reval_amortization_basis :=
   --l_asset_deprn_rec.reval_deprn_expense :=
   --l_asset_deprn_rec.reval_ytd_deprn :=
   l_asset_deprn_rec.reval_deprn_reserve := p_reval_deprn_reserve;
   --l_asset_deprn_rec.production :=
   l_asset_deprn_rec.ltd_production := p_ltd_production;
   l_asset_deprn_rec.ytd_production := p_ytd_production;

   -- ***** Asset Distribution Info ***** --
   l_asset_dist_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.dist_table
   for i in 1 .. fa_load_tbl_pkg.dist_table.count loop
      if (fa_load_tbl_pkg.dist_table(i).record_status = 'INSERT') then
         l_asset_dist_rec.distribution_id :=
            fa_load_tbl_pkg.dist_table(i).dist_id;
         l_asset_dist_rec.units_assigned :=
            fa_load_tbl_pkg.dist_table(i).trans_units;
         l_asset_dist_rec.transaction_units := NULL;
         l_asset_dist_rec.assigned_to :=
            fa_load_tbl_pkg.dist_table(i).assigned_to;
         l_asset_dist_rec.expense_ccid := fa_load_tbl_pkg.dist_table(i).ccid;
         l_asset_dist_rec.location_ccid :=
            fa_load_tbl_pkg.dist_table(i).location_id;

         l_asset_dist_tbl(i) := l_asset_dist_rec;
      end if;
   end loop;

   -- ***** Invoice Info ***** --
   l_inv_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.inv_table
   for i in 1 .. fa_load_tbl_pkg.inv_table.COUNT loop

      l_inv_rec.po_vendor_id := fa_load_tbl_pkg.inv_table(i).po_vendor_id;
      l_inv_rec.asset_invoice_id :=
         fa_load_tbl_pkg.inv_table(i).asset_invoice_id;
      l_inv_rec.fixed_assets_cost :=
         fa_load_tbl_pkg.inv_table(i).fixed_assets_cost;
      l_inv_rec.deleted_flag :=  fa_load_tbl_pkg.inv_table(i).deleted_flag;
      l_inv_rec.po_number := fa_load_tbl_pkg.inv_table(i).po_number;
      l_inv_rec.invoice_number := fa_load_tbl_pkg.inv_table(i).invoice_number;
      l_inv_rec.payables_batch_name :=
         fa_load_tbl_pkg.inv_table(i).payables_batch_name;
      l_inv_rec.payables_code_combination_id :=
         fa_load_tbl_pkg.inv_table(i).payables_ccid;
      l_inv_rec.feeder_system_name :=
         fa_load_tbl_pkg.inv_table(i).feeder_system_name;
      l_inv_rec.create_batch_date :=
         fa_load_tbl_pkg.inv_table(i).create_batch_date;
      l_inv_rec.create_batch_id :=
         fa_load_tbl_pkg.inv_table(i).create_batch_id;
      l_inv_rec.invoice_date := fa_load_tbl_pkg.inv_table(i).invoice_date;
      l_inv_rec.payables_cost := fa_load_tbl_pkg.inv_table(i).payables_cost;
      l_inv_rec.post_batch_id := fa_load_tbl_pkg.inv_table(i).post_batch_id;
      l_inv_rec.invoice_id := fa_load_tbl_pkg.inv_table(i).invoice_id;
      l_inv_rec.invoice_distribution_id := fa_load_tbl_pkg.inv_table(i).invoice_distribution_id;
      l_inv_rec.invoice_line_number := fa_load_tbl_pkg.inv_table(i).invoice_line_number;
      l_inv_rec.po_distribution_id := fa_load_tbl_pkg.inv_table(i).po_distribution_id;
      l_inv_rec.ap_distribution_line_number :=
         fa_load_tbl_pkg.inv_table(i).ap_dist_line_num;
      l_inv_rec.payables_units := fa_load_tbl_pkg.inv_table(i).payables_units;
      --l_inv_rec.split_merged_code :=
      l_inv_rec.description := fa_load_tbl_pkg.inv_table(i).description;
      --l_inv_rec.parent_mass_additions_id :=
      --l_inv_rec.unrevalued_cost :=
      --l_inv_rec.merged_code :=
      --l_inv_rec.split_code :=
      --l_inv_rec.merge_parent_mass_additions_id :=
      --l_inv_rec.split_parent_mass_additions_id :=
      l_inv_rec.project_asset_line_id :=
         fa_load_tbl_pkg.inv_table(i).project_asset_line_id;
      l_inv_rec.project_id := fa_load_tbl_pkg.inv_table(i).project_id;
      l_inv_rec.task_id := fa_load_tbl_pkg.inv_table(i).task_id;
      l_inv_rec.material_indicator_flag :=
         fa_load_tbl_pkg.inv_table(i).material_indicator_flag;
      l_inv_rec.depreciate_in_group_flag :=
         fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.source_line_id := fa_load_tbl_pkg.inv_table(i).source_line_id;
      l_inv_rec.depreciate_in_group_flag := fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.attribute1 := fa_load_tbl_pkg.inv_table(i).attribute1;
      l_inv_rec.attribute2 := fa_load_tbl_pkg.inv_table(i).attribute2;
      l_inv_rec.attribute3 := fa_load_tbl_pkg.inv_table(i).attribute3;
      l_inv_rec.attribute4 := fa_load_tbl_pkg.inv_table(i).attribute4;
      l_inv_rec.attribute5 := fa_load_tbl_pkg.inv_table(i).attribute5;
      l_inv_rec.attribute6 := fa_load_tbl_pkg.inv_table(i).attribute6;
      l_inv_rec.attribute7 := fa_load_tbl_pkg.inv_table(i).attribute7;
      l_inv_rec.attribute8 := fa_load_tbl_pkg.inv_table(i).attribute8;
      l_inv_rec.attribute9 := fa_load_tbl_pkg.inv_table(i).attribute9;
      l_inv_rec.attribute10 := fa_load_tbl_pkg.inv_table(i).attribute10;
      l_inv_rec.attribute11 := fa_load_tbl_pkg.inv_table(i).attribute11;
      l_inv_rec.attribute12 := fa_load_tbl_pkg.inv_table(i).attribute12;
      l_inv_rec.attribute13 := fa_load_tbl_pkg.inv_table(i).attribute13;
      l_inv_rec.attribute14 := fa_load_tbl_pkg.inv_table(i).attribute14;
      l_inv_rec.attribute15 := fa_load_tbl_pkg.inv_table(i).attribute15;
      l_inv_rec.attribute_category_code :=
         fa_load_tbl_pkg.inv_table(i).attribute_cat_code;

      l_inv_tbl(i) := l_inv_rec;
   end loop;


/* toru */
   -- ***** Group Reclass Options ***** --
   l_group_reclass_options_rec.group_reclass_type := p_reclass_transfer_type;
   l_group_reclass_options_rec.reserve_amount := p_reclass_transfer_amount;
   l_group_reclass_options_rec.source_exp_amount := p_reclass_src_expense;
   l_group_reclass_options_rec.destination_exp_amount := p_reclass_dest_expense;
   l_group_reclass_options_rec.source_eofy_reserve := p_reclass_src_eofy_reserve;
   l_group_reclass_options_rec.destination_eofy_reserve := p_reclass_dest_eofy_reserve;
/* Etoru */

   -- Fix for Bug #2392236.  It is possible to NULL out fields for an addition
   -- if the user does not want the value to default from a category, etc.
   -- From an external interface, the user would pass G_MISS* for that field.
   -- However, from the form, we need to derive it here since forms cannot
   -- access global variables defined in PL/SQL.  We only need to distinguish
   -- between Detail Add snd Quick Add since there are some values you cannot
   -- NULL out a value from Quick Add that you can in Detail Add.
   -- For a form call, the p_calling_interface is FAXASSET
   -- Detail Add, p_calling_fn is fa_addition_eng.post_forms_commit
   -- Quick Add, p_calling_fn is fa_addition_dist1.call_quick_add
   if (p_calling_interface = 'FAXASSET') then

      -- Check bonus rule.  Can only be nulled out in Detail Add.
      if ((p_bonus_rule is NULL) and
          (p_calling_fn = 'fa_addition_eng.post_forms_commit')) then

         l_asset_fin_rec.bonus_rule := FND_API.G_MISS_CHAR;
      end if;

      -- Check ceiling name.  Can only be nulled out in Detail Add.
      if ((p_ceiling_name is NULL) and
          (p_calling_fn = 'fa_addition_eng.post_forms_commit')) then

         l_asset_fin_rec.ceiling_name := FND_API.G_MISS_CHAR;
      end if;

      -- Check group_asset_id.  Can be nulled out in Detail or Quick Add.
      if (p_group_asset_id is NULL) then
         l_asset_fin_rec.group_asset_id := FND_API.G_MISS_NUM;
      end if;
   end if;

   -- Call the Public Additions API
   fa_addition_pub.do_addition
      (p_api_version             => p_api_version,
       p_init_msg_list           => p_init_msg_list,
       p_commit                  => p_commit,
       p_validation_level        => p_validation_level,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_calling_fn              => p_calling_fn,
       px_trans_rec              => l_trans_rec,
       px_dist_trans_rec         => l_dist_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       px_asset_desc_rec         => l_asset_desc_rec,
       px_asset_type_rec         => l_asset_type_rec,
       px_asset_cat_rec          => l_asset_cat_rec,
       px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
       px_asset_fin_rec          => l_asset_fin_rec,
       px_asset_deprn_rec        => l_asset_deprn_rec,
       px_asset_dist_tbl         => l_asset_dist_tbl,
       px_inv_tbl                => l_inv_tbl
      );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   -- Set the output variables to return back to the calling program.
   x_asset_id := l_asset_hdr_rec.asset_id;
   x_asset_number := l_asset_desc_rec.asset_number;
   x_transaction_header_id := l_trans_rec.transaction_header_id;
   x_dist_transaction_header_id := l_dist_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_addition',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_addition;

PROCEDURE do_adjustment (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                    IN    VARCHAR2 DEFAULT 'NO',
     p_reset_miss_flag               IN    VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info (Books) --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_transaction_subtype          IN     VARCHAR2 DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Financial Info --
     p_cost                         IN     NUMBER   DEFAULT NULL,
     p_original_cost                IN     NUMBER   DEFAULT NULL,
     p_unrevalued_cost              IN     NUMBER   DEFAULT NULL,
     p_recoverable_cost             IN     NUMBER   DEFAULT NULL,
     p_salvage_value                IN     NUMBER   DEFAULT NULL,
     p_ceiling_name                 IN     VARCHAR2 DEFAULT NULL,
     p_reval_ceiling                IN     NUMBER   DEFAULT NULL,
     p_depreciate_flag              IN     VARCHAR2 DEFAULT NULL,
     -- HH group ed.
     p_disabled_flag                IN     VARCHAR2 DEFAULT NULL,
     p_date_placed_in_service       IN     DATE     DEFAULT NULL,
     p_prorate_convention_code      IN     VARCHAR2 DEFAULT NULL,
     p_deprn_method_code            IN     VARCHAR2 DEFAULT NULL,
     p_life_in_months               IN     NUMBER   DEFAULT NULL,
     p_basic_rate                   IN     NUMBER   DEFAULT NULL,
     p_adjusted_rate                IN     NUMBER   DEFAULT NULL,
     p_production_capacity          IN     NUMBER   DEFAULT NULL,
     p_unit_of_measure              IN     VARCHAR2 DEFAULT NULL,
     p_bonus_rule                   IN     VARCHAR2 DEFAULT NULL,
     p_itc_amount_id                IN     NUMBER   DEFAULT NULL,
     p_short_fiscal_year_flag       IN     VARCHAR2 DEFAULT NULL,
     p_conversion_date              IN     DATE     DEFAULT NULL,
     p_orig_deprn_start_date        IN     DATE     DEFAULT NULL,
     p_group_asset_id               IN     NUMBER   DEFAULT NULL,
/* toru */
     -- Addition for Group Depreciation
     p_percent_salvage_value        IN     NUMBER   DEFAULT NULL,
     p_allowed_deprn_limit          IN     NUMBER   DEFAULT NULL,
     p_allowed_deprn_limit_amount   IN     NUMBER   DEFAULT NULL,
     p_super_group_id               IN     NUMBER   DEFAULT NULL,
     p_reduction_rate               IN     NUMBER   DEFAULT NULL,
     p_reduce_addition_flag         IN     VARCHAR2 DEFAULT NULL,
     p_reduce_adjustment_flag       IN     VARCHAR2 DEFAULT NULL,
     p_reduce_retirement_flag       IN     VARCHAR2 DEFAULT NULL,
     p_over_depreciate_option       IN     VARCHAR2 DEFAULT NULL,
     p_recognize_gain_loss          IN     VARCHAR2 DEFAULT NULL,
     p_recapture_reserve_flag       IN     VARCHAR2 DEFAULT NULL,
     p_limit_proceeds_flag          IN     VARCHAR2 DEFAULT NULL,
     p_terminal_gain_loss           IN     VARCHAR2 DEFAULT NULL,
     p_exclude_proceeds_from_basis  IN     VARCHAR2 DEFAULT NULL,
     p_retirement_deprn_option      IN     VARCHAR2 DEFAULT NULL,
     p_salvage_type                 IN     VARCHAR2 DEFAULT NULL,
     p_deprn_limit_type             IN     VARCHAR2 DEFAULT NULL,
     p_tracking_method              IN     VARCHAR2 DEFAULT NULL,
     p_allocate_to_fully_rsv_flag   IN     VARCHAR2 DEFAULT NULL,
     p_allocate_to_fully_ret_flag   IN     VARCHAR2 DEFAULT NULL,
     p_excess_allocation_option     IN     VARCHAR2 DEFAULT NULL,
     p_depreciation_option          IN     VARCHAR2 DEFAULT NULL,
     p_member_rollup_flag           IN     VARCHAR2 DEFAULT NULL,
     p_ytd_proceeds                 IN     NUMBER   DEFAULT NULL,
     p_ltd_proceeds                 IN     NUMBER   DEFAULT NULL,
     p_exclude_fully_rsv_flag       IN     VARCHAR2 DEFAULT NULL,
     p_eofy_reserve                 IN     NUMBER   DEFAULT NULL,
     p_reclass_transfer_type        IN     VARCHAR2 DEFAULT NULL,
     p_reclass_transfer_amount      IN     NUMBER   DEFAULT NULL,
     p_reclass_src_expense          IN     NUMBER   DEFAULT NULL,
     p_reclass_dest_expense         IN     NUMBER   DEFAULT NULL,
     p_reclass_src_eofy_reserve     IN     NUMBER   DEFAULT NULL,
     p_reclass_dest_eofy_reserve    IN     NUMBER   DEFAULT NULL,
     -- End of Addition for Group Depreciation
/* Etoru */
     p_bk_global_attribute1         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute2         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute3         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute4         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute5         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute6         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute7         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute8         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute9         IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute10        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute11        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute12        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute13        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute14        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute15        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute16        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute17        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute18        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute19        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute20        IN     VARCHAR2 DEFAULT NULL,
     p_bk_global_attribute_category IN     VARCHAR2 DEFAULT NULL,
     -- Asset Depreciation Info --
     p_ytd_deprn                    IN     NUMBER   DEFAULT NULL,
     p_deprn_reserve                IN     NUMBER   DEFAULT NULL,
     p_reval_deprn_reserve          IN     NUMBER   DEFAULT NULL,
     p_ytd_production               IN     NUMBER   DEFAULT NULL,
     p_ltd_production               IN     NUMBER   DEFAULT NULL,
     -- Invoice Info --
     p_invoice_transaction_type     IN     VARCHAR2 DEFAULT NULL,
     -- Group Reclass Options --
     p_transfer_flag                IN     VARCHAR2 DEFAULT NULL,
     p_manual_amount                IN     NUMBER   DEFAULT NULL,
     p_manual_flag                  IN     VARCHAR2 DEFAULT NULL,
     -- IAS36 Impairment Info --
     p_cash_generating_unit_id      IN     NUMBER   DEFAULT NULL,
-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
     p_nbv_at_switch                IN     NUMBER   DEFAULT NULL,
     p_prior_deprn_limit_type       IN     VARCHAR2 DEFAULT NULL,
     p_prior_deprn_limit_amount     IN     NUMBER   DEFAULT NULL,
     p_prior_deprn_limit            IN     NUMBER   DEFAULT NULL,
     p_period_counter_fully_rsrved  IN     VARCHAR2 DEFAULT NULL,
     p_extended_depreciation_period            IN     VARCHAR2 DEFAULT NULL,
     p_prior_deprn_method           IN     VARCHAR2 DEFAULT NULL,
     p_prior_life_in_months         IN     NUMBER   DEFAULT NULL,
     p_prior_basic_rate             IN     NUMBER   DEFAULT NULL,
     p_prior_adjusted_rate          IN     NUMBER   DEFAULT NULL,
     p_extended_deprn_flag          IN     VARCHAR2 DEFAULT NULL
-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
) AS

    adj_err                      exception;

    l_trans_rec                  fa_api_types.trans_rec_type;
    l_asset_hdr_rec              fa_api_types.asset_hdr_rec_type;
    l_asset_fin_rec              fa_api_types.asset_fin_rec_type;
    l_asset_fin_rec_old          fa_api_types.asset_fin_rec_type;
    l_asset_fin_rec_adj          fa_api_types.asset_fin_rec_type;
    l_asset_fin_rec_new          fa_api_types.asset_fin_rec_type;
    l_asset_fin_mrc_tbl_new      fa_api_types.asset_fin_tbl_type;
    l_asset_deprn_rec            fa_api_types.asset_deprn_rec_type;
    l_asset_deprn_rec_old        fa_api_types.asset_deprn_rec_type;
    l_asset_deprn_rec_adj        fa_api_types.asset_deprn_rec_type;
    l_asset_deprn_rec_new        fa_api_types.asset_deprn_rec_type;
    l_asset_deprn_mrc_tbl_new    fa_api_types.asset_deprn_tbl_type;
    l_inv_trans_rec              fa_api_types.inv_trans_rec_type;
    l_inv_rec                    fa_api_types.inv_rec_type;
    l_inv_rec_old                fa_api_types.inv_rec_type;
    l_inv_tbl                    fa_api_types.inv_tbl_type;
    l_group_reclass_options_rec  fa_api_types.group_reclass_options_rec_type;

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   l_trans_rec.transaction_subtype := p_transaction_subtype;
   --l_trans_rec.transaction_key :=
   l_trans_rec.amortization_start_date := p_amortization_start_date;
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code :=
      p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- If amort start date is set, then this will be the trans date
   if (l_trans_rec.amortization_start_date is NOT NULL) then
      l_trans_rec.transaction_date_entered :=
         l_trans_rec.amortization_start_date;
      l_trans_rec.transaction_subtype := 'AMORTIZED';
   end if;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- Get the old asset financial record
   if (NOT fa_util_pvt.get_asset_fin_rec (
        p_asset_hdr_rec         => l_asset_hdr_rec,
        px_asset_fin_rec        => l_asset_fin_rec_old,
        p_mrc_sob_type_code     => 'P',
        p_log_level_rec => g_log_level_rec
   )) then
      raise adj_err;
   end if;

   -- Need to call the cache for book
   if (NOT fa_cache_pkg.fazcbc (
      X_book => l_asset_hdr_rec.book_type_code,
      p_log_level_rec => g_log_level_rec
   )) then
      raise adj_err;
   end if;

   if (NOT fa_util_pvt.get_asset_deprn_rec (
        p_asset_hdr_rec         => l_asset_hdr_rec,
        px_asset_deprn_rec      => l_asset_deprn_rec_old,
        p_mrc_sob_type_code     => 'P',
        p_log_level_rec => g_log_level_rec
   )) then
      raise adj_err;
   end if;

   -- ***** Asset Financial Info ***** --
   l_asset_fin_rec_adj.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
   l_asset_fin_rec_adj.date_placed_in_service := p_date_placed_in_service;
   l_asset_fin_rec_adj.deprn_method_code := p_deprn_method_code;
   l_asset_fin_rec_adj.life_in_months := p_life_in_months;
   l_asset_fin_rec_adj.cost := p_cost - nvl(l_asset_fin_rec_old.cost,0);
   l_asset_fin_rec_adj.original_cost :=
      p_original_cost - nvl(l_asset_fin_rec_old.original_cost,0);
-- Relocate this in below because of introceing salvage_type
--   l_asset_fin_rec_adj.salvage_value :=
--      p_salvage_value - nvl(l_asset_fin_rec_old.salvage_value,0);
   l_asset_fin_rec_adj.prorate_convention_code := p_prorate_convention_code;
   l_asset_fin_rec_adj.depreciate_flag := p_depreciate_flag;
   --HH group ed
   l_asset_fin_rec_adj.disabled_flag := p_disabled_flag;
   l_asset_fin_rec_adj.itc_amount_id := p_itc_amount_id;
   l_asset_fin_rec_adj.basic_rate := p_basic_rate;
   l_asset_fin_rec_adj.adjusted_rate := p_adjusted_rate;
   l_asset_fin_rec_adj.bonus_rule := p_bonus_rule;
   l_asset_fin_rec_adj.ceiling_name := p_ceiling_name;
   l_asset_fin_rec_adj.recoverable_cost :=
      p_recoverable_cost - nvl(l_asset_fin_rec_old.recoverable_cost,0);
   l_asset_fin_rec_adj.production_capacity :=
      p_production_capacity - nvl(l_asset_fin_rec_old.production_capacity,0);

   if (p_reval_ceiling is NULL) then
     l_asset_fin_rec_adj.reval_ceiling := NULL;
   else
     l_asset_fin_rec_adj.reval_ceiling :=
                            p_reval_ceiling -
                            nvl(l_asset_fin_rec_old.reval_ceiling,0);
   end if;

   l_asset_fin_rec_adj.unit_of_measure := p_unit_of_measure;
   l_asset_fin_rec_adj.unrevalued_cost :=
      p_unrevalued_cost - nvl(l_asset_fin_rec_old.unrevalued_cost,0);
   l_asset_fin_rec_adj.short_fiscal_year_flag := p_short_fiscal_year_flag;
   l_asset_fin_rec_adj.conversion_date := p_conversion_date;
   l_asset_fin_rec_adj.orig_deprn_start_date := p_orig_deprn_start_date;
   l_asset_fin_rec_adj.group_asset_id := p_group_asset_id;

   l_asset_fin_rec_adj.salvage_value :=
       p_salvage_value - nvl(l_asset_fin_rec_old.salvage_value,0);
   if (l_asset_fin_rec_old.salvage_type <>
       nvl(p_salvage_type, l_asset_fin_rec_old.salvage_type)) then
     l_asset_fin_rec_adj.salvage_value := p_salvage_value;
     l_asset_fin_rec_adj.percent_salvage_value := p_percent_salvage_value;
   else
     l_asset_fin_rec_adj.salvage_value :=
          p_salvage_value - nvl(l_asset_fin_rec_old.salvage_value,0);
     l_asset_fin_rec_adj.percent_salvage_value :=
          p_percent_salvage_value - nvl(l_asset_fin_rec_old.percent_salvage_value, 0);
   end if; -- (l_asset_fin_rec_old.salvage_type <>

   if (nvl(p_deprn_limit_type,'NONE') = 'NONE') then
     l_asset_fin_rec_adj.allowed_deprn_limit := to_number(null);
     l_asset_fin_rec_adj.allowed_deprn_limit_amount := to_number(null);
   elsif (l_asset_fin_rec_old.deprn_limit_type <>
       nvl(p_deprn_limit_type, l_asset_fin_rec_old.deprn_limit_type)) then
     l_asset_fin_rec_adj.allowed_deprn_limit := p_allowed_deprn_limit;
     l_asset_fin_rec_adj.allowed_deprn_limit_amount := p_allowed_deprn_limit_amount;
   else
     l_asset_fin_rec_adj.allowed_deprn_limit :=
          p_allowed_deprn_limit - nvl(l_asset_fin_rec_old.allowed_deprn_limit, 0);
     l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                               p_allowed_deprn_limit_amount -
                               nvl(l_asset_fin_rec_old.allowed_deprn_limit_amount, 0);
   end if; -- (l_asset_fin_rec_old.salvage_type <>

   l_asset_fin_rec_adj.super_group_id := nvl(p_super_group_id, FND_API.G_MISS_NUM);
   l_asset_fin_rec_adj.reduction_rate := nvl(p_reduction_rate, 0) -
                                         nvl(l_asset_fin_rec_old.reduction_rate, 0);

   l_asset_fin_rec_adj.reduce_addition_flag := p_reduce_addition_flag;
   l_asset_fin_rec_adj.reduce_adjustment_flag := p_reduce_adjustment_flag;
   l_asset_fin_rec_adj.reduce_retirement_flag := p_reduce_retirement_flag;
   l_asset_fin_rec_adj.over_depreciate_option := p_over_depreciate_option;
   l_asset_fin_rec_adj.recognize_gain_loss := p_recognize_gain_loss;
   l_asset_fin_rec_adj.recapture_reserve_flag := p_recapture_reserve_flag;
   l_asset_fin_rec_adj.limit_proceeds_flag := p_limit_proceeds_flag;
   l_asset_fin_rec_adj.terminal_gain_loss := p_terminal_gain_loss;
   l_asset_fin_rec_adj.exclude_proceeds_from_basis := p_exclude_proceeds_from_basis;

   if (p_retirement_deprn_option is null) then
      l_asset_fin_rec_adj.retirement_deprn_option := FND_API.G_MISS_CHAR;
   else
      l_asset_fin_rec_adj.retirement_deprn_option := p_retirement_deprn_option;
   end if;

   l_asset_fin_rec_adj.salvage_type := p_salvage_type;
   l_asset_fin_rec_adj.deprn_limit_type := p_deprn_limit_type;
   l_asset_fin_rec_adj.tracking_method := p_tracking_method;

   if (p_tracking_method is null) then
      l_asset_fin_rec_adj.tracking_method := FND_API.G_MISS_CHAR;
   else
      l_asset_fin_rec_adj.tracking_method := p_tracking_method;
   end if;

   l_asset_fin_rec_adj.allocate_to_fully_rsv_flag := p_allocate_to_fully_rsv_flag;
   l_asset_fin_rec_adj.allocate_to_fully_ret_flag := p_allocate_to_fully_ret_flag;
   l_asset_fin_rec_adj.excess_allocation_option := p_excess_allocation_option;
   l_asset_fin_rec_adj.depreciation_option := p_depreciation_option;
   l_asset_fin_rec_adj.member_rollup_flag := p_member_rollup_flag;
   -- Bug3200566:
   --these value cannot be something due to adjustments
   --   l_asset_fin_rec_adj.ytd_proceeds := p_ytd_proceeds;
   --   l_asset_fin_rec_adj.ltd_proceeds := p_ltd_proceeds;
   l_asset_fin_rec_adj.exclude_fully_rsv_flag := p_exclude_fully_rsv_flag;

   if (p_cash_generating_unit_id is null) then
      l_asset_fin_rec_adj.cash_generating_unit_id := FND_API.G_MISS_NUM;
   else
      l_asset_fin_rec_adj.cash_generating_unit_id := p_cash_generating_unit_id;
   end if;

-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
l_asset_fin_rec_adj.nbv_at_switch                 :=  p_nbv_at_switch;
l_asset_fin_rec_adj.prior_deprn_limit_type        :=  p_prior_deprn_limit_type     ;
l_asset_fin_rec_adj.prior_deprn_limit_amount      :=  p_prior_deprn_limit_amount ;
l_asset_fin_rec_adj.prior_deprn_limit             :=  p_prior_deprn_limit        ;
l_asset_fin_rec_adj.period_counter_fully_reserved :=  p_period_counter_fully_rsrved        ;
l_asset_fin_rec_adj.extended_depreciation_period  :=  p_extended_depreciation_period         ;
l_asset_fin_rec_adj.prior_deprn_method            :=  p_prior_deprn_method      ;
l_asset_fin_rec_adj.prior_life_in_months          :=  p_prior_life_in_months    ;
l_asset_fin_rec_adj.prior_basic_rate              :=  p_prior_basic_rate        ;
l_asset_fin_rec_adj.prior_adjusted_rate  	  :=  p_prior_adjusted_rate     ;
l_asset_fin_rec_adj.extended_deprn_flag  	  :=  p_extended_deprn_flag     ;
-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End

---- End of Addition

   l_asset_fin_rec_adj.global_attribute1 := p_bk_global_attribute1;
   l_asset_fin_rec_adj.global_attribute2 := p_bk_global_attribute2;
   l_asset_fin_rec_adj.global_attribute3 := p_bk_global_attribute3;
   l_asset_fin_rec_adj.global_attribute4 := p_bk_global_attribute4;
   l_asset_fin_rec_adj.global_attribute5 := p_bk_global_attribute5;
   l_asset_fin_rec_adj.global_attribute6 := p_bk_global_attribute6;
   l_asset_fin_rec_adj.global_attribute7 := p_bk_global_attribute7;
   l_asset_fin_rec_adj.global_attribute8 := p_bk_global_attribute8;
   l_asset_fin_rec_adj.global_attribute9 := p_bk_global_attribute9;
   l_asset_fin_rec_adj.global_attribute10 := p_bk_global_attribute10;
   l_asset_fin_rec_adj.global_attribute11 := p_bk_global_attribute11;
   l_asset_fin_rec_adj.global_attribute12 := p_bk_global_attribute12;
   l_asset_fin_rec_adj.global_attribute13 := p_bk_global_attribute13;
   l_asset_fin_rec_adj.global_attribute14 := p_bk_global_attribute14;
   l_asset_fin_rec_adj.global_attribute15 := p_bk_global_attribute15;
   l_asset_fin_rec_adj.global_attribute16 := p_bk_global_attribute16;
   l_asset_fin_rec_adj.global_attribute17 := p_bk_global_attribute17;
   l_asset_fin_rec_adj.global_attribute18 := p_bk_global_attribute18;
   l_asset_fin_rec_adj.global_attribute19 := p_bk_global_attribute19;
   l_asset_fin_rec_adj.global_attribute20 := p_bk_global_attribute20;
   l_asset_fin_rec_adj.global_attribute_category :=
      p_bk_global_attribute_category;

   if ((p_reset_miss_flag = 'YES') and
       (p_invoice_transaction_type is null)) then

      -- Fix for Bug #2653564.  Need to pass different record groups to IN
      -- and OUT parameters.
      l_asset_fin_rec := l_asset_fin_rec_adj;

      if (NOT fa_trans_api_pvt.set_asset_fin_rec (
           p_asset_hdr_rec         => l_asset_hdr_rec,
           p_asset_fin_rec         => l_asset_fin_rec,
           x_asset_fin_rec_new     => l_asset_fin_rec_adj,
           p_mrc_sob_type_code     => 'P'
      )) then
         raise adj_err;
      end if;
   end if;

   -- ***** Asset Depreciation Info ***** --
   l_asset_deprn_rec_adj.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
   l_asset_deprn_rec_adj.ytd_deprn :=
      p_ytd_deprn - nvl(l_asset_deprn_rec_old.ytd_deprn,0);
   l_asset_deprn_rec_adj.deprn_reserve :=
      p_deprn_reserve - nvl(l_asset_deprn_rec_old.deprn_reserve,0);
   l_asset_deprn_rec_adj.reval_deprn_reserve :=
      p_reval_deprn_reserve - nvl(l_asset_deprn_rec_old.reval_deprn_reserve,0);
   --l_asset_deprn_rec_adj.ltd_production :=
   --l_asset_deprn_rec_adj.ytd_production :=

   -- This needs to be taken care only after asset_deprn_rec_adj is determined
   l_asset_fin_rec_adj.eofy_reserve := l_asset_deprn_rec_adj.deprn_reserve -
                                       l_asset_deprn_rec_adj.ytd_deprn;

   if ((p_reset_miss_flag = 'YES') and
       (p_invoice_transaction_type is null)) then

      -- Fix for Bug #2653564.  Need to pass different record groups to IN
      -- and OUT parameters.
      l_asset_deprn_rec := l_asset_deprn_rec_adj;

      if (NOT fa_trans_api_pvt.set_asset_deprn_rec (
           p_asset_hdr_rec         => l_asset_hdr_rec,
           p_asset_deprn_rec       => l_asset_deprn_rec,
           x_asset_deprn_rec_new   => l_asset_deprn_rec_adj,
           p_mrc_sob_type_code     => 'P'
      )) then
         raise adj_err;
      end if;
   end if;

   -- ***** Invoice Transaction Info ***** --
   --l_inv_trans_rec.invoice_transaction_id :=
   l_inv_trans_rec.transaction_type := p_invoice_transaction_type;

   -- ***** Invoice Information ***** --
   l_inv_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.inv_table
   for i in 1 .. fa_load_tbl_pkg.inv_table.COUNT loop

      l_inv_rec.po_vendor_id := fa_load_tbl_pkg.inv_table(i).po_vendor_id;
      l_inv_rec.asset_invoice_id :=
         fa_load_tbl_pkg.inv_table(i).asset_invoice_id;
      l_inv_rec.fixed_assets_cost :=
         fa_load_tbl_pkg.inv_table(i).inv_new_cost -
         nvl(fa_load_tbl_pkg.inv_table(i).fixed_assets_cost, 0);
      l_inv_rec.deleted_flag :=  fa_load_tbl_pkg.inv_table(i).deleted_flag;
      l_inv_rec.po_number := fa_load_tbl_pkg.inv_table(i).po_number;
      l_inv_rec.invoice_number := fa_load_tbl_pkg.inv_table(i).invoice_number;
      l_inv_rec.payables_batch_name :=
         fa_load_tbl_pkg.inv_table(i).payables_batch_name;
      l_inv_rec.payables_code_combination_id :=
         fa_load_tbl_pkg.inv_table(i).payables_ccid;
      l_inv_rec.feeder_system_name :=
         fa_load_tbl_pkg.inv_table(i).feeder_system_name;
      l_inv_rec.create_batch_date :=
         fa_load_tbl_pkg.inv_table(i).create_batch_date;
      l_inv_rec.create_batch_id :=
         fa_load_tbl_pkg.inv_table(i).create_batch_id;
      l_inv_rec.invoice_date := fa_load_tbl_pkg.inv_table(i).invoice_date;
      l_inv_rec.payables_cost := fa_load_tbl_pkg.inv_table(i).payables_cost;
      l_inv_rec.post_batch_id := fa_load_tbl_pkg.inv_table(i).post_batch_id;
      l_inv_rec.invoice_id := fa_load_tbl_pkg.inv_table(i).invoice_id;
      l_inv_rec.invoice_distribution_id := fa_load_tbl_pkg.inv_table(i).invoice_distribution_id;
      l_inv_rec.invoice_line_number := fa_load_tbl_pkg.inv_table(i).invoice_line_number;
      l_inv_rec.po_distribution_id := fa_load_tbl_pkg.inv_table(i).po_distribution_id;
      l_inv_rec.ap_distribution_line_number :=
         fa_load_tbl_pkg.inv_table(i).ap_dist_line_num;
      l_inv_rec.payables_units := fa_load_tbl_pkg.inv_table(i).payables_units;
      --l_inv_rec.split_merged_code :=
      l_inv_rec.description := fa_load_tbl_pkg.inv_table(i).description;
      --l_inv_rec.parent_mass_additions_id :=
      --l_inv_rec.unrevalued_cost :=
      --l_inv_rec.merged_code :=
      --l_inv_rec.split_code :=
      --l_inv_rec.merge_parent_mass_additions_id :=
      --l_inv_rec.split_parent_mass_additions_id :=
      l_inv_rec.project_asset_line_id :=
         fa_load_tbl_pkg.inv_table(i).project_asset_line_id;
      l_inv_rec.project_id := fa_load_tbl_pkg.inv_table(i).project_id;
      l_inv_rec.task_id := fa_load_tbl_pkg.inv_table(i).task_id;
      l_inv_rec.material_indicator_flag :=
         fa_load_tbl_pkg.inv_table(i).material_indicator_flag;
      l_inv_rec.depreciate_in_group_flag :=
         fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.source_line_id := fa_load_tbl_pkg.inv_table(i).source_line_id;
      l_inv_rec.attribute1 := fa_load_tbl_pkg.inv_table(i).attribute1;
      l_inv_rec.attribute2 := fa_load_tbl_pkg.inv_table(i).attribute2;
      l_inv_rec.attribute3 := fa_load_tbl_pkg.inv_table(i).attribute3;
      l_inv_rec.attribute4 := fa_load_tbl_pkg.inv_table(i).attribute4;
      l_inv_rec.attribute5 := fa_load_tbl_pkg.inv_table(i).attribute5;
      l_inv_rec.attribute6 := fa_load_tbl_pkg.inv_table(i).attribute6;
      l_inv_rec.attribute7 := fa_load_tbl_pkg.inv_table(i).attribute7;
      l_inv_rec.attribute8 := fa_load_tbl_pkg.inv_table(i).attribute8;
      l_inv_rec.attribute9 := fa_load_tbl_pkg.inv_table(i).attribute9;
      l_inv_rec.attribute10 := fa_load_tbl_pkg.inv_table(i).attribute10;
      l_inv_rec.attribute11 := fa_load_tbl_pkg.inv_table(i).attribute11;
      l_inv_rec.attribute12 := fa_load_tbl_pkg.inv_table(i).attribute12;
      l_inv_rec.attribute13 := fa_load_tbl_pkg.inv_table(i).attribute13;
      l_inv_rec.attribute14 := fa_load_tbl_pkg.inv_table(i).attribute14;
      l_inv_rec.attribute15 := fa_load_tbl_pkg.inv_table(i).attribute15;
      l_inv_rec.attribute_category_code :=
         fa_load_tbl_pkg.inv_table(i).attribute_cat_code;

      if ((p_reset_miss_flag = 'YES') and
          (l_inv_trans_rec.transaction_type = 'INVOICE ADJUSTMENT')) then

         -- Fix for Bug #2653564.  Need to pass different record groups to
         -- IN and OUT parameters.
         l_inv_rec_old := l_inv_rec;

         if (NOT fa_trans_api_pvt.set_inv_rec (
             p_inv_rec               => l_inv_rec_old,
             x_inv_rec_new           => l_inv_rec,
             p_mrc_sob_type_code     => 'P'
         )) then
            raise adj_err;
         end if;
      end if;

      l_inv_tbl(i) := l_inv_rec;
   end loop;


   -- ***** Group Reclass Options ***** --
   l_group_reclass_options_rec.transfer_flag := p_transfer_flag;
   l_group_reclass_options_rec.manual_flag := p_manual_flag;
   l_group_reclass_options_rec.manual_amount := p_manual_amount;
/* toru */
   l_group_reclass_options_rec.group_reclass_type := p_reclass_transfer_type;
   l_group_reclass_options_rec.reserve_amount := p_reclass_transfer_amount;
   l_group_reclass_options_rec.source_exp_amount := p_reclass_src_expense;
   l_group_reclass_options_rec.destination_exp_amount := p_reclass_dest_expense;
   l_group_reclass_options_rec.source_eofy_reserve := p_reclass_src_eofy_reserve;
   l_group_reclass_options_rec.destination_eofy_reserve := p_reclass_dest_eofy_reserve;
/* Etoru */

   -- Call the Public Adjustments API
   fa_adjustment_pub.do_adjustment
      (p_api_version               => p_api_version,
       p_init_msg_list             => p_init_msg_list,
       p_commit                    => p_commit,
       p_validation_level          => p_validation_level,
       x_return_status             => x_return_status,
       x_msg_count                 => x_msg_count,
       x_msg_data                  => x_msg_data,
       p_calling_fn                => p_calling_fn,
       px_trans_rec                => l_trans_rec,
       px_asset_hdr_rec            => l_asset_hdr_rec,
       p_asset_fin_rec_adj         => l_asset_fin_rec_adj,
       x_asset_fin_rec_new         => l_asset_fin_rec_new,
       x_asset_fin_mrc_tbl_new     => l_asset_fin_mrc_tbl_new,
       p_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
       x_asset_deprn_rec_new       => l_asset_deprn_rec_new,
       x_asset_deprn_mrc_tbl_new   => l_asset_deprn_mrc_tbl_new,
       px_inv_trans_rec            => l_inv_trans_rec,
       px_inv_tbl                  => l_inv_tbl,
       p_group_reclass_options_rec => l_group_reclass_options_rec
      );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when adj_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pub.do_adjustment',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_adjustment',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_adjustment;

PROCEDURE do_unit_adjustment (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL
) AS

   l_trans_rec             fa_api_types.trans_rec_type;
   l_asset_hdr_rec         fa_api_types.asset_hdr_rec_type;
   l_asset_dist_rec        fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl        fa_api_types.asset_dist_tbl_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Distribution Info ***** --
   l_asset_dist_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.dist_tbl;
   for i in fa_load_tbl_pkg.dist_table.FIRST ..
            fa_load_tbl_pkg.dist_table.LAST loop
      l_asset_dist_rec.distribution_id :=
         fa_load_tbl_pkg.dist_table(i).dist_id;
      --l_asset_dist_rec.units_assigned :=
      l_asset_dist_rec.transaction_units :=
         fa_load_tbl_pkg.dist_table(i).trans_units;
      l_asset_dist_rec.assigned_to :=
         fa_load_tbl_pkg.dist_table(i).assigned_to;
      l_asset_dist_rec.expense_ccid := fa_load_tbl_pkg.dist_table(i).ccid;
      l_asset_dist_rec.location_ccid :=
         fa_load_tbl_pkg.dist_table(i).location_id;

      l_asset_dist_tbl(i) := l_asset_dist_rec;
   end loop;

   -- Call Public Unit Adjustment API
   fa_unit_adj_pub.do_unit_adjustment(
              p_api_version       => p_api_version,
              p_init_msg_list     => p_init_msg_list,
              p_commit            => p_commit,
              p_validation_level  => p_validation_level,
              p_calling_fn        => p_calling_fn,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              px_trans_rec        => l_trans_rec,
              px_asset_hdr_rec    => l_asset_hdr_rec,
              px_asset_dist_tbl   => l_asset_dist_tbl);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_unit_adj',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_unit_adjustment;

PROCEDURE do_transfer (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL
) AS

   l_trans_rec             fa_api_types.trans_rec_type;
   l_asset_hdr_rec         fa_api_types.asset_hdr_rec_type;
   l_asset_dist_rec        fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl        fa_api_types.asset_dist_tbl_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Distribution Info ***** --
   l_asset_dist_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.dist_tbl;
   for i in fa_load_tbl_pkg.dist_table.FIRST ..
            fa_load_tbl_pkg.dist_table.LAST loop
      l_asset_dist_rec.distribution_id :=
         fa_load_tbl_pkg.dist_table(i).dist_id;
      --l_asset_dist_rec.units_assigned :=
      l_asset_dist_rec.transaction_units :=
         fa_load_tbl_pkg.dist_table(i).trans_units;
      l_asset_dist_rec.assigned_to :=
         fa_load_tbl_pkg.dist_table(i).assigned_to;
      l_asset_dist_rec.expense_ccid := fa_load_tbl_pkg.dist_table(i).ccid;
      l_asset_dist_rec.location_ccid :=
         fa_load_tbl_pkg.dist_table(i).location_id;

      l_asset_dist_tbl(i) := l_asset_dist_rec;
   end loop;

   -- Call Public Transfer API
   fa_transfer_pub.do_transfer(
              p_api_version       => p_api_version,
              p_init_msg_list     => p_init_msg_list,
              p_commit            => p_commit,
              p_validation_level  => p_validation_level,
              p_calling_fn        => p_calling_fn,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              px_trans_rec        => l_trans_rec,
              px_asset_hdr_rec    => l_asset_hdr_rec,
              px_asset_dist_tbl   => l_asset_dist_tbl);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_transfer',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_transfer;

PROCEDURE do_invoice_transfer (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_src_transaction_header_id           OUT NOCOPY NUMBER,
     x_dest_transaction_header_id          OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     -- Source Asset Header Info --
     p_src_asset_id                 IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Destination Asset Header Info --
     p_dest_asset_id                IN     NUMBER
) AS

   l_src_trans_rec                fa_api_types.trans_rec_type;
   l_src_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
   l_dest_trans_rec               fa_api_types.trans_rec_type;
   l_dest_asset_hdr_rec           fa_api_types.asset_hdr_rec_type;
   l_inv_rec                      fa_api_types.inv_rec_type;
   l_inv_tbl                      fa_api_types.inv_tbl_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Source Asset Transaction Info ***** --
   --l_src_trans_rec.transaction_header_id :=
   --l_src_trans_rec.transaction_type_code :=
   l_src_trans_rec.transaction_date_entered := p_transaction_date_entered;
   --l_src_trans_rec.transaction_name :=
   --l_src_trans_rec.source_transaction_header_id :=
   l_src_trans_rec.mass_reference_id := p_mass_reference_id;
   if (p_amortization_start_date is not null) then
      l_src_trans_rec.transaction_subtype := 'AMORTIZED';
   end if;
   --l_src_trans_rec.transaction_subtype :=
   --l_src_trans_rec.transaction_key :=
   l_src_trans_rec.amortization_start_date := p_amortization_start_date;
   l_src_trans_rec.calling_interface := p_calling_interface;
   --l_src_trans_rec.desc_flex.attribute1 :=
   --l_src_trans_rec.desc_flex.attribute2 :=
   --l_src_trans_rec.desc_flex.attribute3 :=
   --l_src_trans_rec.desc_flex.attribute4 :=
   --l_src_trans_rec.desc_flex.attribute5 :=
   --l_src_trans_rec.desc_flex.attribute6 :=
   --l_src_trans_rec.desc_flex.attribute7 :=
   --l_src_trans_rec.desc_flex.attribute8 :=
   --l_src_trans_rec.desc_flex.attribute9 :=
   --l_src_trans_rec.desc_flex.attribute10 :=
   --l_src_trans_rec.desc_flex.attribute11 :=
   --l_src_trans_rec.desc_flex.attribute11 :=
   --l_src_trans_rec.desc_flex.attribute12 :=
   --l_src_trans_rec.desc_flex.attribute13 :=
   --l_src_trans_rec.desc_flex.attribute14 :=
   --l_src_trans_rec.desc_flex.attribute15 :=
   --l_src_trans_rec.desc_flex.attribute_category_code :=
   l_src_trans_rec.who_info.last_update_date := p_last_update_date;
   l_src_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_src_trans_rec.who_info.created_by := p_created_by;
   l_src_trans_rec.who_info.creation_date := p_creation_date;
   l_src_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Source Asset Header Info ***** --
   l_src_asset_hdr_rec.asset_id := p_src_asset_id;
   l_src_asset_hdr_rec.book_type_code := p_book_type_code;
   l_src_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_src_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_src_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_src_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_src_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Destination Asset Transaction Info ***** --
   --l_dest_trans_rec.transaction_header_id :=
   --l_dest_trans_rec.transaction_type_code :=
   l_dest_trans_rec.transaction_date_entered := p_transaction_date_entered;
   --l_dest_trans_rec.transaction_name :=
   --l_dest_trans_rec.source_transaction_header_id :=
   l_dest_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_dest_trans_rec.transaction_subtype :=
   if (p_amortization_start_date is not null) then
      l_dest_trans_rec.transaction_subtype := 'AMORTIZED';
   end if;
   --l_dest_trans_rec.transaction_key :=
   l_dest_trans_rec.amortization_start_date := p_amortization_start_date;
   l_dest_trans_rec.calling_interface := p_calling_interface;
   --l_dest_trans_rec.desc_flex.attribute1 :=
   --l_dest_trans_rec.desc_flex.attribute2 :=
   --l_dest_trans_rec.desc_flex.attribute3 :=
   --l_dest_trans_rec.desc_flex.attribute4 :=
   --l_dest_trans_rec.desc_flex.attribute5 :=
   --l_dest_trans_rec.desc_flex.attribute6 :=
   --l_dest_trans_rec.desc_flex.attribute7 :=
   --l_dest_trans_rec.desc_flex.attribute8 :=
   --l_dest_trans_rec.desc_flex.attribute9 :=
   --l_dest_trans_rec.desc_flex.attribute10 :=
   --l_dest_trans_rec.desc_flex.attribute11 :=
   --l_dest_trans_rec.desc_flex.attribute11 :=
   --l_dest_trans_rec.desc_flex.attribute12 :=
   --l_dest_trans_rec.desc_flex.attribute13 :=
   --l_dest_trans_rec.desc_flex.attribute14 :=
   --l_dest_trans_rec.desc_flex.attribute15 :=
   --l_dest_trans_rec.desc_flex.attribute_category_code :=
   l_dest_trans_rec.who_info.last_update_date := p_last_update_date;
   l_dest_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_dest_trans_rec.who_info.created_by := p_created_by;
   l_dest_trans_rec.who_info.creation_date := p_creation_date;
   l_dest_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Destination Asset Header Info ***** --
   l_dest_asset_hdr_rec.asset_id := p_dest_asset_id;
   l_dest_asset_hdr_rec.book_type_code := p_book_type_code;
   l_dest_asset_hdr_rec.set_of_books_id := l_src_asset_hdr_rec.set_of_books_id;
   --l_dest_asset_hdr_rec.period_of_addition :=

   -- ***** Invoice Info ***** --
   l_inv_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.inv_table
   for i in 1 .. fa_load_tbl_pkg.inv_table.COUNT loop

      l_inv_rec.po_vendor_id := fa_load_tbl_pkg.inv_table(i).po_vendor_id;
      l_inv_rec.asset_invoice_id :=
         fa_load_tbl_pkg.inv_table(i).asset_invoice_id;
      l_inv_rec.fixed_assets_cost := 0 -
         fa_load_tbl_pkg.inv_table(i).inv_transfer_cost;
      l_inv_rec.deleted_flag :=  fa_load_tbl_pkg.inv_table(i).deleted_flag;
      l_inv_rec.po_number := fa_load_tbl_pkg.inv_table(i).po_number;
      l_inv_rec.invoice_number := fa_load_tbl_pkg.inv_table(i).invoice_number;
      l_inv_rec.payables_batch_name :=
         fa_load_tbl_pkg.inv_table(i).payables_batch_name;
      l_inv_rec.payables_code_combination_id :=
         fa_load_tbl_pkg.inv_table(i).payables_ccid;
      l_inv_rec.feeder_system_name :=
         fa_load_tbl_pkg.inv_table(i).feeder_system_name;
      l_inv_rec.create_batch_date :=
         fa_load_tbl_pkg.inv_table(i).create_batch_date;
      l_inv_rec.create_batch_id :=
         fa_load_tbl_pkg.inv_table(i).create_batch_id;
      l_inv_rec.invoice_date := fa_load_tbl_pkg.inv_table(i).invoice_date;
      l_inv_rec.payables_cost := fa_load_tbl_pkg.inv_table(i).payables_cost;
      l_inv_rec.post_batch_id := fa_load_tbl_pkg.inv_table(i).post_batch_id;
      l_inv_rec.invoice_id := fa_load_tbl_pkg.inv_table(i).invoice_id;
      l_inv_rec.invoice_distribution_id := fa_load_tbl_pkg.inv_table(i).invoice_distribution_id;
      l_inv_rec.invoice_line_number := fa_load_tbl_pkg.inv_table(i).invoice_line_number;
      l_inv_rec.po_distribution_id := fa_load_tbl_pkg.inv_table(i).po_distribution_id;
      l_inv_rec.ap_distribution_line_number :=
         fa_load_tbl_pkg.inv_table(i).ap_dist_line_num;
      l_inv_rec.payables_units := fa_load_tbl_pkg.inv_table(i).payables_units;
      --l_inv_rec.split_merged_code :=
      l_inv_rec.description := fa_load_tbl_pkg.inv_table(i).description;
      --l_inv_rec.parent_mass_additions_id :=
      --l_inv_rec.unrevalued_cost :=
      --l_inv_rec.merged_code :=
      --l_inv_rec.split_code :=
      --l_inv_rec.merge_parent_mass_additions_id :=
      --l_inv_rec.split_parent_mass_additions_id :=
      l_inv_rec.project_asset_line_id :=
         fa_load_tbl_pkg.inv_table(i).project_asset_line_id;
      l_inv_rec.project_id := fa_load_tbl_pkg.inv_table(i).project_id;
      l_inv_rec.task_id := fa_load_tbl_pkg.inv_table(i).task_id;
      l_inv_rec.material_indicator_flag :=
         fa_load_tbl_pkg.inv_table(i).material_indicator_flag;
      l_inv_rec.depreciate_in_group_flag :=
         fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.source_line_id := fa_load_tbl_pkg.inv_table(i).source_line_id;
      l_inv_rec.attribute1 := fa_load_tbl_pkg.inv_table(i).attribute1;
      l_inv_rec.attribute2 := fa_load_tbl_pkg.inv_table(i).attribute2;
      l_inv_rec.attribute3 := fa_load_tbl_pkg.inv_table(i).attribute3;
      l_inv_rec.attribute4 := fa_load_tbl_pkg.inv_table(i).attribute4;
      l_inv_rec.attribute5 := fa_load_tbl_pkg.inv_table(i).attribute5;
      l_inv_rec.attribute6 := fa_load_tbl_pkg.inv_table(i).attribute6;
      l_inv_rec.attribute7 := fa_load_tbl_pkg.inv_table(i).attribute7;
      l_inv_rec.attribute8 := fa_load_tbl_pkg.inv_table(i).attribute8;
      l_inv_rec.attribute9 := fa_load_tbl_pkg.inv_table(i).attribute9;
      l_inv_rec.attribute10 := fa_load_tbl_pkg.inv_table(i).attribute10;
      l_inv_rec.attribute11 := fa_load_tbl_pkg.inv_table(i).attribute11;
      l_inv_rec.attribute12 := fa_load_tbl_pkg.inv_table(i).attribute12;
      l_inv_rec.attribute13 := fa_load_tbl_pkg.inv_table(i).attribute13;
      l_inv_rec.attribute14 := fa_load_tbl_pkg.inv_table(i).attribute14;
      l_inv_rec.attribute15 := fa_load_tbl_pkg.inv_table(i).attribute15;
      l_inv_rec.attribute_category_code :=
         fa_load_tbl_pkg.inv_table(i).attribute_cat_code;

      l_inv_tbl(i) := l_inv_rec;
   end loop;

   -- Call the Public Invoice Transfer API
   fa_inv_xfr_pub.do_transfer
      (p_api_version         => p_api_version,
       p_init_msg_list       => p_init_msg_list,
       p_commit              => p_commit,
       p_validation_level    => p_validation_level,
       p_calling_fn          => p_calling_fn,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       px_src_trans_rec      => l_src_trans_rec,
       px_src_asset_hdr_rec  => l_src_asset_hdr_rec,
       px_dest_trans_rec     => l_dest_trans_rec,
       px_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
       p_inv_tbl             => l_inv_tbl
   );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_src_transaction_header_id := l_src_trans_rec.transaction_header_id;
   x_dest_transaction_header_id := l_dest_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_inv_xfr',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_invoice_transfer;

PROCEDURE do_reclass (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_transaction_subtype          IN     VARCHAR2 DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     -- Asset Category Info --
     p_new_category_id              IN     NUMBER,
     p_cat_attribute1               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute2               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute3               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute4               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute5               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute6               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute7               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute8               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute9               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute10              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute11              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute12              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute13              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute14              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute15              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute16              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute17              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute18              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute19              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute20              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute21              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute22              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute23              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute24              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute25              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute26              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute27              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute28              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute29              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute30              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute_category_code  IN     VARCHAR2 DEFAULT NULL,
     p_context                      IN     VARCHAR2 DEFAULT NULL,
     -- Reclass Options Info --
     p_copy_cat_desc_flag           IN     VARCHAR2 DEFAULT 'NO',
     p_redefault_flag               IN     VARCHAR2 DEFAULT 'NO'
) AS

   l_trans_rec           fa_api_types.trans_rec_type;
   l_asset_hdr_rec       fa_api_types.asset_hdr_rec_type;
   l_asset_cat_rec_new   fa_api_types.asset_cat_rec_type;
   l_reclass_options_rec fa_api_types.reclass_options_rec_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   l_trans_rec.transaction_subtype := p_transaction_subtype;
   --l_trans_rec.transaction_key :=
   l_trans_rec.amortization_start_date :=  p_amortization_start_date;
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   if (p_amortization_start_date is NOT NULL) then
       l_trans_rec.transaction_subtype := 'AMORTIZED';
   end if;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id       := p_asset_id;
   --l_asset_hdr_rec.book_type_code :=
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
/* select set_of_books_id
   into   l_asset_hdr_rec.set_of_books_id
   from   fa_book_controls
   where  book_type_code = l_asset_hdr_rec.book_type_code;
*/
   -- ***** Asset Category Info ***** --
   l_asset_cat_rec_new.category_id := p_new_category_id;
   l_asset_cat_rec_new.desc_flex.attribute1 := p_cat_attribute1;
   l_asset_cat_rec_new.desc_flex.attribute2 := p_cat_attribute2;
   l_asset_cat_rec_new.desc_flex.attribute3 := p_cat_attribute3;
   l_asset_cat_rec_new.desc_flex.attribute4 := p_cat_attribute4;
   l_asset_cat_rec_new.desc_flex.attribute5 := p_cat_attribute5;
   l_asset_cat_rec_new.desc_flex.attribute6 := p_cat_attribute6;
   l_asset_cat_rec_new.desc_flex.attribute7 := p_cat_attribute7;
   l_asset_cat_rec_new.desc_flex.attribute8 := p_cat_attribute8;
   l_asset_cat_rec_new.desc_flex.attribute9 := p_cat_attribute9;
   l_asset_cat_rec_new.desc_flex.attribute10 := p_cat_attribute10;
   l_asset_cat_rec_new.desc_flex.attribute11 := p_cat_attribute11;
   l_asset_cat_rec_new.desc_flex.attribute12 := p_cat_attribute12;
   l_asset_cat_rec_new.desc_flex.attribute13 := p_cat_attribute13;
   l_asset_cat_rec_new.desc_flex.attribute14 := p_cat_attribute14;
   l_asset_cat_rec_new.desc_flex.attribute15 := p_cat_attribute15;
   l_asset_cat_rec_new.desc_flex.attribute16 := p_cat_attribute16;
   l_asset_cat_rec_new.desc_flex.attribute17 := p_cat_attribute17;
   l_asset_cat_rec_new.desc_flex.attribute18 := p_cat_attribute18;
   l_asset_cat_rec_new.desc_flex.attribute19 := p_cat_attribute19;
   l_asset_cat_rec_new.desc_flex.attribute20 := p_cat_attribute20;
   l_asset_cat_rec_new.desc_flex.attribute21 := p_cat_attribute21;
   l_asset_cat_rec_new.desc_flex.attribute22 := p_cat_attribute22;
   l_asset_cat_rec_new.desc_flex.attribute23 := p_cat_attribute23;
   l_asset_cat_rec_new.desc_flex.attribute24 := p_cat_attribute24;
   l_asset_cat_rec_new.desc_flex.attribute25 := p_cat_attribute25;
   l_asset_cat_rec_new.desc_flex.attribute26 := p_cat_attribute26;
   l_asset_cat_rec_new.desc_flex.attribute27 := p_cat_attribute27;
   l_asset_cat_rec_new.desc_flex.attribute28 := p_cat_attribute28;
   l_asset_cat_rec_new.desc_flex.attribute29 := p_cat_attribute29;
   l_asset_cat_rec_new.desc_flex.attribute30 := p_cat_attribute30;
   l_asset_cat_rec_new.desc_flex.attribute_category_code :=
      p_cat_attribute_category_code;
   l_asset_cat_rec_new.desc_flex.context := p_context;

   -- ***** Asset Reclass Options Info ***** --
   l_reclass_options_rec.copy_cat_desc_flag := p_copy_cat_desc_flag;
   l_reclass_options_rec.redefault_flag := p_redefault_flag;
   -- ?? include fully reserved assets?

   -- Call Public Reclass API
   fa_reclass_pub.do_reclass (
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           p_calling_fn        => p_calling_fn,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           px_trans_rec          => l_trans_rec,
           px_asset_hdr_rec      => l_asset_hdr_rec,
           px_asset_cat_rec_new  => l_asset_cat_rec_new,
           p_recl_opt_rec        => l_reclass_options_rec);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_reclass',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_reclass;

PROCEDURE do_retirement (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_retirement_id                   OUT NOCOPY NUMBER,
     x_transaction_header_id           OUT NOCOPY NUMBER,
     x_dist_transaction_header_id      OUT NOCOPY NUMBER,
     -- Transaction Info (Retirement) --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Transaction Info (Distributions) --
     p_dist_transaction_name        IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute1              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute2              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute3              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute4              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute5              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute6              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute7              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute8              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute9              IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute10             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute11             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute12             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute13             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute14             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute15             IN     VARCHAR2 DEFAULT NULL,
     p_dist_attribute_category_code IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Retirement Info --
     p_calculate_gain_loss          IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_units_retired                IN     NUMBER   DEFAULT NULL,
     p_cost_retired                 IN     NUMBER   DEFAULT NULL,
     p_proceeds_of_sale             IN     NUMBER   DEFAULT NULL,
     p_cost_of_removal              IN     NUMBER   DEFAULT NULL,
     p_retirement_type_code         IN     VARCHAR2 DEFAULT NULL,
     p_retire_prorate_convention    IN     VARCHAR2 DEFAULT NULL,
     p_stl_method_code              IN     VARCHAR2 DEFAULT NULL,
     p_stl_life_in_months           IN     NUMBER   DEFAULT NULL,
     p_sold_to                      IN     VARCHAR2 DEFAULT NULL,
     p_trade_in_asset_id            IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL,
     p_reference_num                IN     VARCHAR2 DEFAULT NULL,
     p_recognize_gain_loss          IN     VARCHAR2 DEFAULT NULL,
     p_recapture_reserve_flag       IN     VARCHAR2 DEFAULT NULL,
     p_limit_proceeds_flag          IN     VARCHAR2 DEFAULT NULL,
     p_terminal_gain_loss           IN     VARCHAR2 DEFAULT NULL,
     p_reduction_rate               IN     NUMBER   DEFAULT NULL,
     p_reserve_retired              IN     NUMBER   DEFAULT NULL,
     p_eofy_reserve                 IN     NUMBER   DEFAULT NULL,
     p_ret_attribute1               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute2               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute3               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute4               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute5               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute6               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute7               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute8               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute9               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute10              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute11              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute12              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute13              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute14              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute15              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute_category_code  IN     VARCHAR2 DEFAULT NULL
) AS

   l_trans_rec              fa_api_types.trans_rec_type;
   l_dist_trans_rec         fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_retire_rec       fa_api_types.asset_retire_rec_type;
   l_asset_dist_rec         fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl         fa_api_types.asset_dist_tbl_type;
   l_subcomp_rec            fa_api_types.subcomp_rec_type;
   l_subcomp_tbl            fa_api_types.subcomp_tbl_type;
   l_inv_rec                fa_api_types.inv_rec_type;
   l_inv_tbl                fa_api_types.inv_tbl_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code :=
      p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Distribution Transaction Info ***** --
   --l_dist_trans_rec.transaction_header_id :=
   l_dist_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_dist_trans_rec.transaction_name := p_dist_transaction_name;
   l_dist_trans_rec.calling_interface := p_calling_interface;
   l_dist_trans_rec.desc_flex.attribute1 := p_dist_attribute1;
   l_dist_trans_rec.desc_flex.attribute2 := p_dist_attribute2;
   l_dist_trans_rec.desc_flex.attribute3 := p_dist_attribute3;
   l_dist_trans_rec.desc_flex.attribute4 := p_dist_attribute4;
   l_dist_trans_rec.desc_flex.attribute5 := p_dist_attribute5;
   l_dist_trans_rec.desc_flex.attribute6 := p_dist_attribute6;
   l_dist_trans_rec.desc_flex.attribute7 := p_dist_attribute7;
   l_dist_trans_rec.desc_flex.attribute8 := p_dist_attribute8;
   l_dist_trans_rec.desc_flex.attribute9 := p_dist_attribute9;
   l_dist_trans_rec.desc_flex.attribute10 := p_dist_attribute10;
   l_dist_trans_rec.desc_flex.attribute11 := p_dist_attribute11;
   l_dist_trans_rec.desc_flex.attribute12 := p_dist_attribute12;
   l_dist_trans_rec.desc_flex.attribute13 := p_dist_attribute13;
   l_dist_trans_rec.desc_flex.attribute14 := p_dist_attribute14;
   l_dist_trans_rec.desc_flex.attribute15 := p_dist_attribute15;
   l_dist_trans_rec.desc_flex.attribute_category_code :=
      p_dist_attribute_category_code;
   l_dist_trans_rec.who_info.last_update_date := p_last_update_date;
   l_dist_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_dist_trans_rec.who_info.created_by := p_created_by;
   l_dist_trans_rec.who_info.creation_date := p_creation_date;
   l_dist_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := NULL;

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Retirement Info ***** --
   --l_asset_retire_rec.retirement_id :=
   l_asset_retire_rec.date_retired := p_transaction_date_entered;
   l_asset_retire_rec.units_retired := p_units_retired;
   l_asset_retire_rec.cost_retired := p_cost_retired;
   l_asset_retire_rec.proceeds_of_sale := p_proceeds_of_sale;
   l_asset_retire_rec.cost_of_removal := p_cost_of_removal;
   l_asset_retire_rec.retirement_type_code := p_retirement_type_code;
   l_asset_retire_rec.retirement_prorate_convention :=
      p_retire_prorate_convention;
   l_asset_retire_rec.detail_info.stl_method_code := p_stl_method_code;
   l_asset_retire_rec.detail_info.stl_life_in_months := p_stl_life_in_months;
   l_asset_retire_rec.sold_to := p_sold_to;
   l_asset_retire_rec.trade_in_asset_id := p_trade_in_asset_id;
   l_asset_retire_rec.status := p_status;
   l_asset_retire_rec.reference_num := p_reference_num;
-- toru
-- New variables
   l_asset_retire_rec.recognize_gain_loss := p_recognize_gain_loss;
   l_asset_retire_rec.recapture_reserve_flag := p_recapture_reserve_flag;
   l_asset_retire_rec.limit_proceeds_flag := p_limit_proceeds_flag;
   l_asset_retire_rec.terminal_gain_loss := p_terminal_gain_loss;
   l_asset_retire_rec.reserve_retired := p_reserve_retired;
   l_asset_retire_rec.eofy_reserve := p_eofy_reserve;
   l_asset_retire_rec.reduction_rate :=p_reduction_rate;
--
   l_asset_retire_rec.calculate_gain_loss := p_calculate_gain_loss;
   l_asset_retire_rec.desc_flex.attribute1 := p_ret_attribute1;
   l_asset_retire_rec.desc_flex.attribute2 := p_ret_attribute2;
   l_asset_retire_rec.desc_flex.attribute3 := p_ret_attribute3;
   l_asset_retire_rec.desc_flex.attribute4 := p_ret_attribute4;
   l_asset_retire_rec.desc_flex.attribute5 := p_ret_attribute5;
   l_asset_retire_rec.desc_flex.attribute6 := p_ret_attribute6;
   l_asset_retire_rec.desc_flex.attribute7 := p_ret_attribute7;
   l_asset_retire_rec.desc_flex.attribute8 := p_ret_attribute8;
   l_asset_retire_rec.desc_flex.attribute9 := p_ret_attribute9;
   l_asset_retire_rec.desc_flex.attribute10 := p_ret_attribute10;
   l_asset_retire_rec.desc_flex.attribute11 := p_ret_attribute11;
   l_asset_retire_rec.desc_flex.attribute12 := p_ret_attribute12;
   l_asset_retire_rec.desc_flex.attribute13 := p_ret_attribute13;
   l_asset_retire_rec.desc_flex.attribute14 := p_ret_attribute14;
   l_asset_retire_rec.desc_flex.attribute15 := p_ret_attribute15;
   l_asset_retire_rec.desc_flex.attribute_category_code :=
      p_ret_attribute_category_code;

   -- ***** Asset Distribution Info ***** --
   l_asset_dist_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.dist_tbl;
   for i in 1 .. fa_load_tbl_pkg.dist_table.COUNT loop
      if (fa_load_tbl_pkg.dist_table(i).record_status = 'UPDATE') then
         l_asset_dist_rec.distribution_id :=
            fa_load_tbl_pkg.dist_table(i).dist_id;
         l_asset_dist_rec.transaction_units :=
            fa_load_tbl_pkg.dist_table(i).trans_units;
         l_asset_dist_rec.units_assigned := NULL;
         l_asset_dist_rec.assigned_to :=
            fa_load_tbl_pkg.dist_table(i).assigned_to;
         l_asset_dist_rec.expense_ccid := fa_load_tbl_pkg.dist_table(i).ccid;
         l_asset_dist_rec.location_ccid :=
            fa_load_tbl_pkg.dist_table(i).location_id;

         l_asset_dist_tbl(i) := l_asset_dist_rec;
      end if;
   end loop;

   -- ***** Subcomponent Asset Info ***** --
   -- Don't need to worry about subcomponents for now because you can only
   -- retire subcomponents through Mass Retirements and not the Workbench.
   l_subcomp_tbl.delete;

   -- ***** Invoice Info ***** --
   l_inv_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.inv_table
   for i in 1 .. fa_load_tbl_pkg.inv_table.COUNT loop

      l_inv_rec.po_vendor_id := fa_load_tbl_pkg.inv_table(i).po_vendor_id;
      l_inv_rec.asset_invoice_id :=
         fa_load_tbl_pkg.inv_table(i).asset_invoice_id;
      l_inv_rec.fixed_assets_cost :=
         fa_load_tbl_pkg.inv_table(i).inv_new_cost -
         nvl(fa_load_tbl_pkg.inv_table(i).fixed_assets_cost, 0);
      l_inv_rec.deleted_flag :=  fa_load_tbl_pkg.inv_table(i).deleted_flag;
      l_inv_rec.po_number := fa_load_tbl_pkg.inv_table(i).po_number;
      l_inv_rec.invoice_number := fa_load_tbl_pkg.inv_table(i).invoice_number;
      l_inv_rec.payables_batch_name :=
         fa_load_tbl_pkg.inv_table(i).payables_batch_name;
      l_inv_rec.payables_code_combination_id :=
         fa_load_tbl_pkg.inv_table(i).payables_ccid;
      l_inv_rec.feeder_system_name :=
         fa_load_tbl_pkg.inv_table(i).feeder_system_name;
      l_inv_rec.create_batch_date :=
         fa_load_tbl_pkg.inv_table(i).create_batch_date;
      l_inv_rec.create_batch_id :=
         fa_load_tbl_pkg.inv_table(i).create_batch_id;
      l_inv_rec.invoice_date := fa_load_tbl_pkg.inv_table(i).invoice_date;
      l_inv_rec.payables_cost := fa_load_tbl_pkg.inv_table(i).payables_cost;
      l_inv_rec.post_batch_id := fa_load_tbl_pkg.inv_table(i).post_batch_id;
      l_inv_rec.invoice_id := fa_load_tbl_pkg.inv_table(i).invoice_id;
      l_inv_rec.invoice_distribution_id := fa_load_tbl_pkg.inv_table(i).invoice_distribution_id;
      l_inv_rec.invoice_line_number := fa_load_tbl_pkg.inv_table(i).invoice_line_number;
      l_inv_rec.po_distribution_id := fa_load_tbl_pkg.inv_table(i).po_distribution_id;
      l_inv_rec.ap_distribution_line_number :=
         fa_load_tbl_pkg.inv_table(i).ap_dist_line_num;
      l_inv_rec.payables_units := fa_load_tbl_pkg.inv_table(i).payables_units;
      --l_inv_rec.split_merged_code :=
      l_inv_rec.description := fa_load_tbl_pkg.inv_table(i).description;
      --l_inv_rec.parent_mass_additions_id :=
      --l_inv_rec.unrevalued_cost :=
      --l_inv_rec.merged_code :=
      --l_inv_rec.split_code :=
      --l_inv_rec.merge_parent_mass_additions_id :=
      --l_inv_rec.split_parent_mass_additions_id :=
      l_inv_rec.project_asset_line_id :=
         fa_load_tbl_pkg.inv_table(i).project_asset_line_id;
      l_inv_rec.project_id := fa_load_tbl_pkg.inv_table(i).project_id;
      l_inv_rec.task_id := fa_load_tbl_pkg.inv_table(i).task_id;
      l_inv_rec.material_indicator_flag :=
         fa_load_tbl_pkg.inv_table(i).material_indicator_flag;
      l_inv_rec.depreciate_in_group_flag :=
         fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.source_line_id := fa_load_tbl_pkg.inv_table(i).source_line_id;
      l_inv_rec.attribute1 := fa_load_tbl_pkg.inv_table(i).attribute1;
      l_inv_rec.attribute2 := fa_load_tbl_pkg.inv_table(i).attribute2;
      l_inv_rec.attribute3 := fa_load_tbl_pkg.inv_table(i).attribute3;
      l_inv_rec.attribute4 := fa_load_tbl_pkg.inv_table(i).attribute4;
      l_inv_rec.attribute5 := fa_load_tbl_pkg.inv_table(i).attribute5;
      l_inv_rec.attribute6 := fa_load_tbl_pkg.inv_table(i).attribute6;
      l_inv_rec.attribute7 := fa_load_tbl_pkg.inv_table(i).attribute7;
      l_inv_rec.attribute8 := fa_load_tbl_pkg.inv_table(i).attribute8;
      l_inv_rec.attribute9 := fa_load_tbl_pkg.inv_table(i).attribute9;
      l_inv_rec.attribute10 := fa_load_tbl_pkg.inv_table(i).attribute10;
      l_inv_rec.attribute11 := fa_load_tbl_pkg.inv_table(i).attribute11;
      l_inv_rec.attribute12 := fa_load_tbl_pkg.inv_table(i).attribute12;
      l_inv_rec.attribute13 := fa_load_tbl_pkg.inv_table(i).attribute13;
      l_inv_rec.attribute14 := fa_load_tbl_pkg.inv_table(i).attribute14;
      l_inv_rec.attribute15 := fa_load_tbl_pkg.inv_table(i).attribute15;
      l_inv_rec.attribute_category_code :=
         fa_load_tbl_pkg.inv_table(i).attribute_cat_code;

      l_inv_tbl(i) := l_inv_rec;
   end loop;

   -- Call Public Retirement API
   fa_retirement_pub.do_retirement
      (p_api_version               => p_api_version,
       p_init_msg_list             => p_init_msg_list,
       p_commit                    => p_commit,
       p_validation_level          => p_validation_level,
       p_calling_fn                => p_calling_fn,
       x_return_status             => x_return_status,
       x_msg_count                 => x_msg_count,
       x_msg_data                  => x_msg_data,
       px_trans_rec                => l_trans_rec,
       px_dist_trans_rec           => l_dist_trans_rec,
       px_asset_hdr_rec            => l_asset_hdr_rec,
       px_asset_retire_rec         => l_asset_retire_rec,
       p_asset_dist_tbl            => l_asset_dist_tbl,
       p_subcomp_tbl               => l_subcomp_tbl,
       p_inv_tbl                   => l_inv_tbl);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_retirement_id := l_asset_retire_rec.retirement_id;
   x_transaction_header_id := l_trans_rec.transaction_header_id;
   x_dist_transaction_header_id := l_dist_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_retirement',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_retirement;

PROCEDURE undo_retirement (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Transaction Info --
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_last_update_login            IN     NUMBER,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Retirement Info --
     p_retirement_id                IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL
) AS

   l_trans_rec              fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_retire_rec       fa_api_types.asset_retire_rec_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   --l_trans_rec.transaction_date_entered :=
   --l_trans_rec.transaction_name :=
   --l_trans_rec.source_transaction_header_id :=
   --l_trans_rec.mass_reference_id :=
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   --l_trans_rec.calling_interface :=
   --l_trans_rec.desc_flex.attribute1 :=
   --l_trans_rec.desc_flex.attribute2 :=
   --l_trans_rec.desc_flex.attribute3 :=
   --l_trans_rec.desc_flex.attribute4 :=
   --l_trans_rec.desc_flex.attribute5 :=
   --l_trans_rec.desc_flex.attribute6 :=
   --l_trans_rec.desc_flex.attribute7 :=
   --l_trans_rec.desc_flex.attribute8 :=
   --l_trans_rec.desc_flex.attribute9 :=
   --l_trans_rec.desc_flex.attribute10 :=
   --l_trans_rec.desc_flex.attribute11 :=
   --l_trans_rec.desc_flex.attribute12 :=
   --l_trans_rec.desc_flex.attribute13 :=
   --l_trans_rec.desc_flex.attribute14 :=
   --l_trans_rec.desc_flex.attribute15 :=
   --l_trans_rec.desc_flex.attribute_category_code :=
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := NULL;
   l_trans_rec.who_info.creation_date := NULL;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := NULL;

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Retirement Info ***** --
   l_asset_retire_rec.retirement_id := p_retirement_id;
   --l_asset_retire_rec.date_retired :=
   --l_asset_retire_rec.units_retired :=
   --l_asset_retire_rec.cost_retired :=
   --l_asset_retire_rec.proceeds_of_sale :=
   --l_asset_retire_rec.cost_of_removal :=
   --l_asset_retire_rec.retirement_type_code :=
   --l_asset_retire_rec.retirement_prorate_convention :=
   --l_asset_retire_rec.sold_to :=
   --l_asset_retire_rec.trade_in_asset_id :=
   l_asset_retire_rec.status := p_status;
   --l_asset_retire_rec.reference_num :=
   --l_asset_retire_rec.calculate_gain_loss :=
   --l_asset_retire_rec.desc_flex.attribute1 :=
   --l_asset_retire_rec.desc_flex.attribute2 :=
   --l_asset_retire_rec.desc_flex.attribute3 :=
   --l_asset_retire_rec.desc_flex.attribute4 :=
   --l_asset_retire_rec.desc_flex.attribute5 :=
   --l_asset_retire_rec.desc_flex.attribute6 :=
   --l_asset_retire_rec.desc_flex.attribute7 :=
   --l_asset_retire_rec.desc_flex.attribute8 :=
   --l_asset_retire_rec.desc_flex.attribute9 :=
   --l_asset_retire_rec.desc_flex.attribute10 :=
   --l_asset_retire_rec.desc_flex.attribute11 :=
   --l_asset_retire_rec.desc_flex.attribute12 :=
   --l_asset_retire_rec.desc_flex.attribute13 :=
   --l_asset_retire_rec.desc_flex.attribute14 :=
   --l_asset_retire_rec.desc_flex.attribute15 :=
   --l_asset_retire_rec.desc_flex.attribute_category_code :=

   -- Call Public Undo Retirement API
   fa_retirement_pub.undo_retirement (
        p_api_version           => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        p_validation_level      => p_validation_level,
        p_calling_fn            => p_calling_fn,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        px_trans_rec            => l_trans_rec,
        px_asset_hdr_rec        => l_asset_hdr_rec,
        px_asset_retire_rec     => l_asset_retire_rec
   );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.undo_ret',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END undo_retirement;

PROCEDURE do_reinstatement (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Retirement Info --
     p_calculate_gain_loss          IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_retirement_id                IN     NUMBER   DEFAULT NULL,
     p_proceeds_of_sale             IN     NUMBER   DEFAULT NULL,
     p_cost_of_removal              IN     NUMBER   DEFAULT NULL,
     p_retirement_type_code         IN     VARCHAR2 DEFAULT NULL,
     p_retire_prorate_convention    IN     VARCHAR2 DEFAULT NULL,
     p_sold_to                      IN     VARCHAR2 DEFAULT NULL,
     p_trade_in_asset_id            IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL,
     p_reference_num                IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute1               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute2               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute3               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute4               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute5               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute6               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute7               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute8               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute9               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute10              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute11              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute12              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute13              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute14              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute15              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute_category_code  IN     VARCHAR2 DEFAULT NULL
) AS

   l_trans_rec              fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_retire_rec       fa_api_types.asset_retire_rec_type;
   l_asset_dist_rec         fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl         fa_api_types.asset_dist_tbl_type;
   l_subcomp_rec            fa_api_types.subcomp_rec_type;
   l_subcomp_tbl            fa_api_types.subcomp_tbl_type;
   l_inv_rec                fa_api_types.inv_rec_type;
   l_inv_tbl                fa_api_types.inv_tbl_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code :=
      p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := NULL;

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Retirement Info ***** --
   l_asset_retire_rec.retirement_id := p_retirement_id;
   --l_asset_retire_rec.date_retired :=
   --l_asset_retire_rec.units_retired :=
   --l_asset_retire_rec.cost_retired :=
   l_asset_retire_rec.proceeds_of_sale := p_proceeds_of_sale;
   l_asset_retire_rec.cost_of_removal := p_cost_of_removal;
   l_asset_retire_rec.retirement_type_code := p_retirement_type_code;
   l_asset_retire_rec.retirement_prorate_convention :=
      p_retire_prorate_convention;
   l_asset_retire_rec.sold_to := p_sold_to;
   l_asset_retire_rec.trade_in_asset_id := p_trade_in_asset_id;
   l_asset_retire_rec.status := p_status;
   l_asset_retire_rec.reference_num := p_reference_num;
   l_asset_retire_rec.calculate_gain_loss := p_calculate_gain_loss;
   l_asset_retire_rec.desc_flex.attribute1 := p_ret_attribute1;
   l_asset_retire_rec.desc_flex.attribute2 := p_ret_attribute2;
   l_asset_retire_rec.desc_flex.attribute3 := p_ret_attribute3;
   l_asset_retire_rec.desc_flex.attribute4 := p_ret_attribute4;
   l_asset_retire_rec.desc_flex.attribute5 := p_ret_attribute5;
   l_asset_retire_rec.desc_flex.attribute6 := p_ret_attribute6;
   l_asset_retire_rec.desc_flex.attribute7 := p_ret_attribute7;
   l_asset_retire_rec.desc_flex.attribute8 := p_ret_attribute8;
   l_asset_retire_rec.desc_flex.attribute9 := p_ret_attribute9;
   l_asset_retire_rec.desc_flex.attribute10 := p_ret_attribute10;
   l_asset_retire_rec.desc_flex.attribute11 := p_ret_attribute11;
   l_asset_retire_rec.desc_flex.attribute12 := p_ret_attribute12;
   l_asset_retire_rec.desc_flex.attribute13 := p_ret_attribute13;
   l_asset_retire_rec.desc_flex.attribute14 := p_ret_attribute14;
   l_asset_retire_rec.desc_flex.attribute15 := p_ret_attribute15;
   l_asset_retire_rec.desc_flex.attribute_category_code :=
      p_ret_attribute_category_code;

   -- ***** Asset Distribution Info ***** --
   l_asset_dist_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.dist_tbl;
   for i in 1 .. fa_load_tbl_pkg.dist_table.COUNT loop
      if (fa_load_tbl_pkg.dist_table(i).record_status = 'UPDATE') then
         l_asset_dist_rec.distribution_id :=
            fa_load_tbl_pkg.dist_table(i).dist_id;
         l_asset_dist_rec.units_assigned :=
            fa_load_tbl_pkg.dist_table(i).trans_units;
         l_asset_dist_rec.transaction_units := NULL;
         l_asset_dist_rec.assigned_to :=
            fa_load_tbl_pkg.dist_table(i).assigned_to;
         l_asset_dist_rec.expense_ccid := fa_load_tbl_pkg.dist_table(i).ccid;
         l_asset_dist_rec.location_ccid :=
            fa_load_tbl_pkg.dist_table(i).location_id;

         l_asset_dist_tbl(i) := l_asset_dist_rec;
      end if;
   end loop;

   -- ***** Subcomponent Asset Info ***** --
   -- Don't need to worry about subcomponents for now because you can only
   -- retire subcomponents through Mass Retirements and not the Workbench.
   l_subcomp_tbl.delete;
   --l_subcomp_rec.asset_id :=
   --l_subcomp_rec.parent_flag :=

   -- ***** Invoice Info ***** --
   l_inv_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.inv_table
   for i in 1 .. fa_load_tbl_pkg.inv_table.COUNT loop

      l_inv_rec.po_vendor_id := fa_load_tbl_pkg.inv_table(i).po_vendor_id;
      l_inv_rec.asset_invoice_id :=
         fa_load_tbl_pkg.inv_table(i).asset_invoice_id;
      l_inv_rec.fixed_assets_cost :=
         fa_load_tbl_pkg.inv_table(i).fixed_assets_cost;
      l_inv_rec.deleted_flag :=  fa_load_tbl_pkg.inv_table(i).deleted_flag;
      l_inv_rec.po_number := fa_load_tbl_pkg.inv_table(i).po_number;
      l_inv_rec.invoice_number := fa_load_tbl_pkg.inv_table(i).invoice_number;
      l_inv_rec.payables_batch_name :=
         fa_load_tbl_pkg.inv_table(i).payables_batch_name;
      l_inv_rec.payables_code_combination_id :=
         fa_load_tbl_pkg.inv_table(i).payables_ccid;
      l_inv_rec.feeder_system_name :=
         fa_load_tbl_pkg.inv_table(i).feeder_system_name;
      l_inv_rec.create_batch_date :=
         fa_load_tbl_pkg.inv_table(i).create_batch_date;
      l_inv_rec.create_batch_id :=
         fa_load_tbl_pkg.inv_table(i).create_batch_id;
      l_inv_rec.invoice_date := fa_load_tbl_pkg.inv_table(i).invoice_date;
      l_inv_rec.payables_cost := fa_load_tbl_pkg.inv_table(i).payables_cost;
      l_inv_rec.post_batch_id := fa_load_tbl_pkg.inv_table(i).post_batch_id;
      l_inv_rec.invoice_id := fa_load_tbl_pkg.inv_table(i).invoice_id;
      l_inv_rec.invoice_distribution_id := fa_load_tbl_pkg.inv_table(i).invoice_distribution_id;
      l_inv_rec.invoice_line_number := fa_load_tbl_pkg.inv_table(i).invoice_line_number;
      l_inv_rec.po_distribution_id := fa_load_tbl_pkg.inv_table(i).po_distribution_id;
      l_inv_rec.ap_distribution_line_number :=
         fa_load_tbl_pkg.inv_table(i).ap_dist_line_num;
      l_inv_rec.payables_units := fa_load_tbl_pkg.inv_table(i).payables_units;
      --l_inv_rec.split_merged_code :=
      l_inv_rec.description := fa_load_tbl_pkg.inv_table(i).description;
      --l_inv_rec.parent_mass_additions_id :=
      --l_inv_rec.unrevalued_cost :=
      --l_inv_rec.merged_code :=
      --l_inv_rec.split_code :=
      --l_inv_rec.merge_parent_mass_additions_id :=
      --l_inv_rec.split_parent_mass_additions_id :=
      l_inv_rec.project_asset_line_id :=
         fa_load_tbl_pkg.inv_table(i).project_asset_line_id;
      l_inv_rec.project_id := fa_load_tbl_pkg.inv_table(i).project_id;
      l_inv_rec.task_id := fa_load_tbl_pkg.inv_table(i).task_id;
      l_inv_rec.material_indicator_flag :=
         fa_load_tbl_pkg.inv_table(i).material_indicator_flag;
      l_inv_rec.depreciate_in_group_flag :=
         fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.source_line_id := fa_load_tbl_pkg.inv_table(i).source_line_id;
      l_inv_rec.attribute1 := fa_load_tbl_pkg.inv_table(i).attribute1;
      l_inv_rec.attribute2 := fa_load_tbl_pkg.inv_table(i).attribute2;
      l_inv_rec.attribute3 := fa_load_tbl_pkg.inv_table(i).attribute3;
      l_inv_rec.attribute4 := fa_load_tbl_pkg.inv_table(i).attribute4;
      l_inv_rec.attribute5 := fa_load_tbl_pkg.inv_table(i).attribute5;
      l_inv_rec.attribute6 := fa_load_tbl_pkg.inv_table(i).attribute6;
      l_inv_rec.attribute7 := fa_load_tbl_pkg.inv_table(i).attribute7;
      l_inv_rec.attribute8 := fa_load_tbl_pkg.inv_table(i).attribute8;
      l_inv_rec.attribute9 := fa_load_tbl_pkg.inv_table(i).attribute9;
      l_inv_rec.attribute10 := fa_load_tbl_pkg.inv_table(i).attribute10;
      l_inv_rec.attribute11 := fa_load_tbl_pkg.inv_table(i).attribute11;
      l_inv_rec.attribute12 := fa_load_tbl_pkg.inv_table(i).attribute12;
      l_inv_rec.attribute13 := fa_load_tbl_pkg.inv_table(i).attribute13;
      l_inv_rec.attribute14 := fa_load_tbl_pkg.inv_table(i).attribute14;
      l_inv_rec.attribute15 := fa_load_tbl_pkg.inv_table(i).attribute15;
      l_inv_rec.attribute_category_code :=
         fa_load_tbl_pkg.inv_table(i).attribute_cat_code;

      l_inv_tbl(i) := l_inv_rec;
   end loop;

   -- Call Public Reinstatement API
   fa_retirement_pub.do_reinstatement
      (p_api_version               => p_api_version,
       p_init_msg_list             => p_init_msg_list,
       p_commit                    => p_commit,
       p_validation_level          => p_validation_level,
       p_calling_fn                => p_calling_fn,
       x_return_status             => x_return_status,
       x_msg_count                 => x_msg_count,
       x_msg_data                  => x_msg_data,
       px_trans_rec                => l_trans_rec,
       px_asset_hdr_rec            => l_asset_hdr_rec,
       px_asset_retire_rec         => l_asset_retire_rec,
       p_asset_dist_tbl            => l_asset_dist_tbl,
       p_subcomp_tbl               => l_subcomp_tbl,
       p_inv_tbl                   => l_inv_tbl);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_reinst',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_reinstatement;

PROCEDURE undo_reinstatement (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Transaction Info (Retirement) --
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_last_update_login            IN     NUMBER,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Retirement Info --
     p_retirement_id                IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL
) AS

   l_trans_rec              fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_retire_rec       fa_api_types.asset_retire_rec_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   --l_trans_rec.transaction_date_entered :=
   --l_trans_rec.transaction_name :=
   --l_trans_rec.source_transaction_header_id :=
   --l_trans_rec.mass_reference_id :=
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   --l_trans_rec.calling_interface :=
   --l_trans_rec.desc_flex.attribute1 :=
   --l_trans_rec.desc_flex.attribute2 :=
   --l_trans_rec.desc_flex.attribute3 :=
   --l_trans_rec.desc_flex.attribute4 :=
   --l_trans_rec.desc_flex.attribute5 :=
   --l_trans_rec.desc_flex.attribute6 :=
   --l_trans_rec.desc_flex.attribute7 :=
   --l_trans_rec.desc_flex.attribute8 :=
   --l_trans_rec.desc_flex.attribute9 :=
   --l_trans_rec.desc_flex.attribute10 :=
   --l_trans_rec.desc_flex.attribute11 :=
   --l_trans_rec.desc_flex.attribute12 :=
   --l_trans_rec.desc_flex.attribute12 :=
   --l_trans_rec.desc_flex.attribute13 :=
   --l_trans_rec.desc_flex.attribute14 :=
   --l_trans_rec.desc_flex.attribute15 :=
   --l_trans_rec.desc_flex.attribute_category_code :=
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := NULL;
   l_trans_rec.who_info.creation_date := NULL;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := p_asset_id;
   l_asset_hdr_rec.book_type_code  := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := NULL;

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Retirement Info ***** --
   l_asset_retire_rec.retirement_id := p_retirement_id;
   --l_asset_retire_rec.date_retired :=
   --l_asset_retire_rec.units_retired :=
   --l_asset_retire_rec.cost_retired :=
   --l_asset_retire_rec.proceeds_of_sale :=
   --l_asset_retire_rec.cost_of_removal :=
   --l_asset_retire_rec.retirement_type_code :=
   --l_asset_retire_rec.retirement_prorate_convention :=
   --l_asset_retire_rec.sold_to :=
   --l_asset_retire_rec.trade_in_asset_id :=
   l_asset_retire_rec.status := p_status;
   --l_asset_retire_rec.reference_num :=
   --l_asset_retire_rec.calculate_gain_loss :=
   --l_asset_retire_rec.desc_flex.attribute1 :=
   --l_asset_retire_rec.desc_flex.attribute2 :=
   --l_asset_retire_rec.desc_flex.attribute3 :=
   --l_asset_retire_rec.desc_flex.attribute4 :=
   --l_asset_retire_rec.desc_flex.attribute5 :=
   --l_asset_retire_rec.desc_flex.attribute6 :=
   --l_asset_retire_rec.desc_flex.attribute7 :=
   --l_asset_retire_rec.desc_flex.attribute8 :=
   --l_asset_retire_rec.desc_flex.attribute9 :=
   --l_asset_retire_rec.desc_flex.attribute10 :=
   --l_asset_retire_rec.desc_flex.attribute11 :=
   --l_asset_retire_rec.desc_flex.attribute12 :=
   --l_asset_retire_rec.desc_flex.attribute13 :=
   --l_asset_retire_rec.desc_flex.attribute14 :=
   --l_asset_retire_rec.desc_flex.attribute15 :=
   --l_asset_retire_rec.desc_flex.attribute_category_code :=

   -- Call Public Undo Reinstatement API
   fa_retirement_pub.undo_reinstatement (
        p_api_version           => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        p_validation_level      => p_validation_level,
        p_calling_fn            => p_calling_fn,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        px_trans_rec            => l_trans_rec,
        px_asset_hdr_rec        => l_asset_hdr_rec,
        px_asset_retire_rec     => l_asset_retire_rec
   );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.undo_reinst',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END undo_reinstatement;

PROCEDURE do_capitalization (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Financial Info --
     p_date_placed_in_service       IN     DATE
) AS

   l_trans_rec              fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_fin_rec          fa_api_types.asset_fin_rec_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_asset_id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := NULL;

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Financial Info ***** --
   l_asset_fin_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
   l_asset_fin_rec.date_placed_in_service := p_date_placed_in_service;
   --l_asset_fin_rec.cost :=

   -- Call Capitalization API
   fa_cip_pub.do_capitalization
      (p_api_version              => p_api_version,
       p_init_msg_list            => p_init_msg_list,
       p_commit                   => p_commit,
       p_validation_level         => p_validation_level,
       p_calling_fn               => p_calling_fn,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       px_trans_rec               => l_trans_rec,
       px_asset_hdr_rec           => l_asset_hdr_rec,
       px_asset_fin_rec           => l_asset_fin_rec);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_cap',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
END do_capitalization;

PROCEDURE do_reverse (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Financial Info --
     p_date_placed_in_service       IN     DATE
) AS

   l_trans_rec              fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_fin_rec          fa_api_types.asset_fin_rec_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_asset_id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := NULL;

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Financial Info ***** --
   l_asset_fin_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
   l_asset_fin_rec.date_placed_in_service := p_date_placed_in_service;
   --l_asset_fin_rec.cost :=

   -- Call Reverse API
   fa_cip_pub.do_reverse
      (p_api_version              => p_api_version,
       p_init_msg_list            => p_init_msg_list,
       p_commit                   => p_commit,
       p_validation_level         => p_validation_level,
       p_calling_fn               => p_calling_fn,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       px_trans_rec               => l_trans_rec,
       px_asset_hdr_rec           => l_asset_hdr_rec,
       px_asset_fin_rec           => l_asset_fin_rec);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_rev',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
END do_reverse;

PROCEDURE do_asset_desc_update (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     p_reset_miss_flag              IN     VARCHAR2 DEFAULT 'NO',
     -- Transaction Info --
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_last_update_login            IN     NUMBER,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     -- Asset Description Info --
     p_asset_number                 IN     VARCHAR2 DEFAULT NULL,
     p_description                  IN     VARCHAR2 DEFAULT NULL,
     p_tag_number                   IN     VARCHAR2 DEFAULT NULL,
     p_serial_number                IN     VARCHAR2 DEFAULT NULL,
     p_asset_key_ccid               IN     NUMBER   DEFAULT NULL,
     p_current_units                IN     NUMBER   DEFAULT NULL,
     p_parent_asset_id              IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL,
     p_manufacturer_name            IN     VARCHAR2 DEFAULT NULL,
     p_model_number                 IN     VARCHAR2 DEFAULT NULL,
     p_warranty_id                  IN     NUMBER   DEFAULT NULL,
     p_property_type_code           IN     VARCHAR2 DEFAULT NULL,
     p_property_1245_1250_code      IN     VARCHAR2 DEFAULT NULL,
     p_in_use_flag                  IN     VARCHAR2 DEFAULT NULL,
     p_inventorial                  IN     VARCHAR2 DEFAULT NULL,
     p_commitment		    IN	   VARCHAR2 DEFAULT NULL,
     p_investment_law		    IN     VARCHAR2 DEFAULT NULL,
     p_owned_leased                 IN     VARCHAR2 DEFAULT NULL,
     p_new_used                     IN     VARCHAR2 DEFAULT NULL,
     p_lease_id                     IN     NUMBER   DEFAULT NULL,
     p_ls_attribute1                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute2                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute3                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute4                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute5                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute6                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute7                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute8                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute9                IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute10               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute11               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute12               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute13               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute14               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute15               IN     VARCHAR2 DEFAULT NULL,
     p_ls_attribute_category_code   IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute1         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute2         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute3         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute4         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute5         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute6         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute7         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute8         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute9         IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute10        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute11        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute12        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute13        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute14        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute15        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute16        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute17        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute18        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute19        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute20        IN     VARCHAR2 DEFAULT NULL,
     p_ad_global_attribute_category IN     VARCHAR2 DEFAULT NULL,
     -- Asset Category Info --
     p_cat_attribute1               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute2               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute3               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute4               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute5               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute6               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute7               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute8               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute9               IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute10              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute11              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute12              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute13              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute14              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute15              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute16              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute17              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute18              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute19              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute20              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute21              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute22              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute23              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute24              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute25              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute26              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute27              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute28              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute29              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute30              IN     VARCHAR2 DEFAULT NULL,
     p_cat_attribute_category_code  IN     VARCHAR2 DEFAULT NULL,
     p_context                      IN     VARCHAR2 DEFAULT NULL
) AS

    l_trans_rec                fa_api_types.trans_rec_type;
    l_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
    l_asset_desc_rec           fa_api_types.asset_desc_rec_type;
    l_asset_desc_rec_old       fa_api_types.asset_desc_rec_type;
    l_asset_cat_rec            fa_api_types.asset_cat_rec_type;
    l_asset_cat_rec_old        fa_api_types.asset_cat_rec_type;

    desc_err                   exception;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   --l_trans_rec.transaction_date_entered :=
   --l_trans_rec.transaction_name :=
   --l_trans_rec.source_transaction_header_id :=
   --l_trans_rec.mass_reference_id :=
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   --l_trans_rec.calling_interface :=
   --l_trans_rec.desc_flex.attribute1 :=
   --l_trans_rec.desc_flex.attribute2 :=
   --l_trans_rec.desc_flex.attribute3 :=
   --l_trans_rec.desc_flex.attribute4 :=
   --l_trans_rec.desc_flex.attribute5 :=
   --l_trans_rec.desc_flex.attribute6 :=
   --l_trans_rec.desc_flex.attribute7 :=
   --l_trans_rec.desc_flex.attribute8 :=
   --l_trans_rec.desc_flex.attribute9 :=
   --l_trans_rec.desc_flex.attribute10 :=
   --l_trans_rec.desc_flex.attribute11 :=
   --l_trans_rec.desc_flex.attribute12 :=
   --l_trans_rec.desc_flex.attribute13 :=
   --l_trans_rec.desc_flex.attribute14 :=
   --l_trans_rec.desc_flex.attribute15 :=
   --l_trans_rec.desc_flex.attribute_category_code :=
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := NULL;
   l_trans_rec.who_info.creation_date := NULL;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_asset_id;
   --l_asset_hdr_rec.book_type_code :=
   --l_asset_hdr_rec.set_of_books_id :=
   --l_asset_hdr_rec.period_of_addition :=

   --@@@ Derive set of books id for primary book
/* select set_of_books_id
   into   l_asset_hdr_rec.set_of_books_id
   from   fa_book_controls
   where  book_type_code = l_asset_hdr_rec.book_type_code;
*/

   -- ***** Asset Descriptive Info ***** --
   l_asset_desc_rec.asset_number := p_asset_number;
   l_asset_desc_rec.description := p_description;
   l_asset_desc_rec.tag_number := p_tag_number;
   l_asset_desc_rec.serial_number := p_serial_number;
   l_asset_desc_rec.asset_key_ccid := p_asset_key_ccid;
   l_asset_desc_rec.parent_asset_id := p_parent_asset_id;
   l_asset_desc_rec.manufacturer_name := p_manufacturer_name;
   l_asset_desc_rec.model_number := p_model_number;
   l_asset_desc_rec.warranty_id := p_warranty_id;
   l_asset_desc_rec.lease_id := p_lease_id;
   l_asset_desc_rec.in_use_flag := p_in_use_flag;
   l_asset_desc_rec.inventorial := p_inventorial;
   l_asset_desc_rec.commitment := p_commitment;
   l_asset_desc_rec.investment_law := p_investment_law;
   l_asset_desc_rec.property_type_code := p_property_type_code;
   l_asset_desc_rec.property_1245_1250_code := p_property_1245_1250_code;
   l_asset_desc_rec.owned_leased := p_owned_leased;
   l_asset_desc_rec.new_used := p_new_used;
   l_asset_desc_rec.current_units := p_current_units;
   --l_asset_desc_rec.unit_adjustment_flag  :=
   --l_asset_desc_rec.add_cost_je_flag :=
   l_asset_desc_rec.status := p_status;
   l_asset_desc_rec.lease_desc_flex.attribute1 := p_ls_attribute1;
   l_asset_desc_rec.lease_desc_flex.attribute2 := p_ls_attribute2;
   l_asset_desc_rec.lease_desc_flex.attribute3 := p_ls_attribute3;
   l_asset_desc_rec.lease_desc_flex.attribute4 := p_ls_attribute4;
   l_asset_desc_rec.lease_desc_flex.attribute5 := p_ls_attribute5;
   l_asset_desc_rec.lease_desc_flex.attribute6 := p_ls_attribute6;
   l_asset_desc_rec.lease_desc_flex.attribute7 := p_ls_attribute7;
   l_asset_desc_rec.lease_desc_flex.attribute8 := p_ls_attribute8;
   l_asset_desc_rec.lease_desc_flex.attribute9 := p_ls_attribute9;
   l_asset_desc_rec.lease_desc_flex.attribute10 := p_ls_attribute10;
   l_asset_desc_rec.lease_desc_flex.attribute11 := p_ls_attribute11;
   l_asset_desc_rec.lease_desc_flex.attribute12 := p_ls_attribute12;
   l_asset_desc_rec.lease_desc_flex.attribute13 := p_ls_attribute13;
   l_asset_desc_rec.lease_desc_flex.attribute14 := p_ls_attribute14;
   l_asset_desc_rec.lease_desc_flex.attribute15 := p_ls_attribute15;
   l_asset_desc_rec.lease_desc_flex.attribute_category_code :=
      p_ls_attribute_category_code;
   l_asset_desc_rec.global_desc_flex.attribute1 := p_ad_global_attribute1;
   l_asset_desc_rec.global_desc_flex.attribute2 := p_ad_global_attribute2;
   l_asset_desc_rec.global_desc_flex.attribute3 := p_ad_global_attribute3;
   l_asset_desc_rec.global_desc_flex.attribute4 := p_ad_global_attribute4;
   l_asset_desc_rec.global_desc_flex.attribute5 := p_ad_global_attribute5;
   l_asset_desc_rec.global_desc_flex.attribute6 := p_ad_global_attribute6;
   l_asset_desc_rec.global_desc_flex.attribute7 := p_ad_global_attribute7;
   l_asset_desc_rec.global_desc_flex.attribute8 := p_ad_global_attribute8;
   l_asset_desc_rec.global_desc_flex.attribute9 := p_ad_global_attribute9;
   l_asset_desc_rec.global_desc_flex.attribute10 := p_ad_global_attribute10;
   l_asset_desc_rec.global_desc_flex.attribute11 := p_ad_global_attribute11;
   l_asset_desc_rec.global_desc_flex.attribute12 := p_ad_global_attribute12;
   l_asset_desc_rec.global_desc_flex.attribute13 := p_ad_global_attribute13;
   l_asset_desc_rec.global_desc_flex.attribute14 := p_ad_global_attribute14;
   l_asset_desc_rec.global_desc_flex.attribute15 := p_ad_global_attribute15;
   l_asset_desc_rec.global_desc_flex.attribute16 := p_ad_global_attribute16;
   l_asset_desc_rec.global_desc_flex.attribute17 := p_ad_global_attribute17;
   l_asset_desc_rec.global_desc_flex.attribute18 := p_ad_global_attribute18;
   l_asset_desc_rec.global_desc_flex.attribute19 := p_ad_global_attribute19;
   l_asset_desc_rec.global_desc_flex.attribute20 := p_ad_global_attribute20;
   l_asset_desc_rec.global_desc_flex.attribute_category_code :=
      p_ad_global_attribute_category;

   if (p_reset_miss_flag = 'YES') then
       -- Fix for Bug #2653564.  Need to pass different record groups to
       -- IN and OUT parameters.
      l_asset_desc_rec_old := l_asset_desc_rec;

      if (NOT fa_trans_api_pvt.set_asset_desc_rec (
           p_asset_hdr_rec        => l_asset_hdr_rec,
           p_asset_desc_rec       => l_asset_desc_rec_old,
           x_asset_desc_rec_new   => l_asset_desc_rec
      )) then
         raise desc_err;
      end if;
   end if;

   -- ***** Asset Category Info ***** --
   --l_asset_cat_rec.category_id :=
   l_asset_cat_rec.desc_flex.attribute1 := p_cat_attribute1;
   l_asset_cat_rec.desc_flex.attribute2 := p_cat_attribute2;
   l_asset_cat_rec.desc_flex.attribute3 := p_cat_attribute3;
   l_asset_cat_rec.desc_flex.attribute4 := p_cat_attribute4;
   l_asset_cat_rec.desc_flex.attribute5 := p_cat_attribute5;
   l_asset_cat_rec.desc_flex.attribute6 := p_cat_attribute6;
   l_asset_cat_rec.desc_flex.attribute7 := p_cat_attribute7;
   l_asset_cat_rec.desc_flex.attribute8 := p_cat_attribute8;
   l_asset_cat_rec.desc_flex.attribute9 := p_cat_attribute9;
   l_asset_cat_rec.desc_flex.attribute10 := p_cat_attribute10;
   l_asset_cat_rec.desc_flex.attribute11 := p_cat_attribute11;
   l_asset_cat_rec.desc_flex.attribute12 := p_cat_attribute12;
   l_asset_cat_rec.desc_flex.attribute13 := p_cat_attribute13;
   l_asset_cat_rec.desc_flex.attribute14 := p_cat_attribute14;
   l_asset_cat_rec.desc_flex.attribute15 := p_cat_attribute15;
   l_asset_cat_rec.desc_flex.attribute16 := p_cat_attribute16;
   l_asset_cat_rec.desc_flex.attribute17 := p_cat_attribute17;
   l_asset_cat_rec.desc_flex.attribute18 := p_cat_attribute18;
   l_asset_cat_rec.desc_flex.attribute19 := p_cat_attribute19;
   l_asset_cat_rec.desc_flex.attribute20 := p_cat_attribute20;
   l_asset_cat_rec.desc_flex.attribute21 := p_cat_attribute21;
   l_asset_cat_rec.desc_flex.attribute22 := p_cat_attribute22;
   l_asset_cat_rec.desc_flex.attribute23 := p_cat_attribute23;
   l_asset_cat_rec.desc_flex.attribute24 := p_cat_attribute24;
   l_asset_cat_rec.desc_flex.attribute25 := p_cat_attribute25;
   l_asset_cat_rec.desc_flex.attribute26 := p_cat_attribute26;
   l_asset_cat_rec.desc_flex.attribute27 := p_cat_attribute27;
   l_asset_cat_rec.desc_flex.attribute28 := p_cat_attribute28;
   l_asset_cat_rec.desc_flex.attribute29 := p_cat_attribute29;
   l_asset_cat_rec.desc_flex.attribute30 := p_cat_attribute30;
   l_asset_cat_rec.desc_flex.attribute_category_code :=
      p_cat_attribute_category_code;
   l_asset_cat_rec.desc_flex.context := p_context;

   if (p_reset_miss_flag = 'YES') then
      -- Fix for Bug #2653564.  Need to pass different record groups to
      -- IN and OUT parameters.
      l_asset_cat_rec_old := l_asset_cat_rec;

      if (NOT fa_trans_api_pvt.set_asset_cat_rec (
           p_asset_hdr_rec        => l_asset_hdr_rec,
           p_asset_cat_rec        => l_asset_cat_rec_old,
           x_asset_cat_rec_new    => l_asset_cat_rec
      )) then
         raise desc_err;
      end if;
   end if;

   -- Call Public Asset Description Update API
   fa_asset_desc_pub.update_desc (
          p_api_version          => p_api_version,
          p_init_msg_list        => p_init_msg_list,
          p_commit               => p_commit,
          p_validation_level     => p_validation_level,
          x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data,
          p_calling_fn           => p_calling_fn,
          px_trans_rec           => l_trans_rec,
          px_asset_hdr_rec       => l_asset_hdr_rec,
          px_asset_desc_rec_new  => l_asset_desc_rec,
          px_asset_cat_rec_new   => l_asset_cat_rec);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

EXCEPTION
   when desc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pub.do_desc_update',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_desc_update',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
END do_asset_desc_update;

PROCEDURE do_invoice_desc_update (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     p_reset_miss_flag              IN     VARCHAR2 DEFAULT 'NO',
     -- Transaction Info --
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_last_update_login            IN     NUMBER,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL
) AS

    l_trans_rec                fa_api_types.trans_rec_type;
    l_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
    l_inv_rec                  fa_api_types.inv_rec_type;
    l_inv_rec_old              fa_api_types.inv_rec_type;
    l_inv_tbl                  fa_api_types.inv_tbl_type;

    desc_err                   exception;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   --l_trans_rec.transaction_date_entered :=
   --l_trans_rec.transaction_name :=
   --l_trans_rec.source_transaction_header_id :=
   --l_trans_rec.mass_reference_id :=
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   --l_trans_rec.calling_interface :=
   --l_trans_rec.desc_flex.attribute1 :=
   --l_trans_rec.desc_flex.attribute2 :=
   --l_trans_rec.desc_flex.attribute3 :=
   --l_trans_rec.desc_flex.attribute4 :=
   --l_trans_rec.desc_flex.attribute5 :=
   --l_trans_rec.desc_flex.attribute6 :=
   --l_trans_rec.desc_flex.attribute7 :=
   --l_trans_rec.desc_flex.attribute8 :=
   --l_trans_rec.desc_flex.attribute9 :=
   --l_trans_rec.desc_flex.attribute10 :=
   --l_trans_rec.desc_flex.attribute11 :=
   --l_trans_rec.desc_flex.attribute12 :=
   --l_trans_rec.desc_flex.attribute13 :=
   --l_trans_rec.desc_flex.attribute14 :=
   --l_trans_rec.desc_flex.attribute15 :=
   --l_trans_rec.desc_flex.attribute_category_code :=
   l_trans_rec.who_info.last_update_date := p_Last_Update_Date;
   l_trans_rec.who_info.last_updated_by := p_Last_Updated_By;
   l_trans_rec.who_info.created_by := NULL;
   l_trans_rec.who_info.creation_date := NULL;
   l_trans_rec.who_info.last_update_login := p_Last_Update_Login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_Asset_Id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Invoice Info ***** --
   l_inv_tbl.delete;

   -- Get the details from fa_load_tbl_pkg.inv_table
   for i in 1 .. fa_load_tbl_pkg.inv_table.COUNT loop

      l_inv_rec.po_vendor_id := fa_load_tbl_pkg.inv_table(i).po_vendor_id;
      l_inv_rec.asset_invoice_id :=
         fa_load_tbl_pkg.inv_table(i).asset_invoice_id;
      l_inv_rec.fixed_assets_cost :=
         fa_load_tbl_pkg.inv_table(i).fixed_assets_cost;
      l_inv_rec.deleted_flag :=  fa_load_tbl_pkg.inv_table(i).deleted_flag;
      l_inv_rec.po_number := fa_load_tbl_pkg.inv_table(i).po_number;
      l_inv_rec.invoice_number := fa_load_tbl_pkg.inv_table(i).invoice_number;
      l_inv_rec.payables_batch_name :=
         fa_load_tbl_pkg.inv_table(i).payables_batch_name;
      l_inv_rec.payables_code_combination_id :=
         fa_load_tbl_pkg.inv_table(i).payables_ccid;
      l_inv_rec.feeder_system_name :=
         fa_load_tbl_pkg.inv_table(i).feeder_system_name;
      l_inv_rec.create_batch_date :=
         fa_load_tbl_pkg.inv_table(i).create_batch_date;
      l_inv_rec.create_batch_id :=
         fa_load_tbl_pkg.inv_table(i).create_batch_id;
      l_inv_rec.invoice_date := fa_load_tbl_pkg.inv_table(i).invoice_date;
      l_inv_rec.payables_cost := fa_load_tbl_pkg.inv_table(i).payables_cost;
      l_inv_rec.post_batch_id := fa_load_tbl_pkg.inv_table(i).post_batch_id;
      l_inv_rec.invoice_id := fa_load_tbl_pkg.inv_table(i).invoice_id;
      l_inv_rec.invoice_distribution_id := fa_load_tbl_pkg.inv_table(i).invoice_distribution_id;
      l_inv_rec.invoice_line_number := fa_load_tbl_pkg.inv_table(i).invoice_line_number;
      l_inv_rec.po_distribution_id := fa_load_tbl_pkg.inv_table(i).po_distribution_id;
      l_inv_rec.ap_distribution_line_number :=
         fa_load_tbl_pkg.inv_table(i).ap_dist_line_num;
      l_inv_rec.payables_units := fa_load_tbl_pkg.inv_table(i).payables_units;
      --l_inv_rec.split_merged_code :=
      l_inv_rec.description := fa_load_tbl_pkg.inv_table(i).description;
      --l_inv_rec.parent_mass_additions_id :=
      --l_inv_rec.unrevalued_cost :=
      --l_inv_rec.merged_code :=
      --l_inv_rec.split_code :=
      --l_inv_rec.merge_parent_mass_additions_id :=
      --l_inv_rec.split_parent_mass_additions_id :=
      l_inv_rec.project_asset_line_id :=
         fa_load_tbl_pkg.inv_table(i).project_asset_line_id;
      l_inv_rec.project_id := fa_load_tbl_pkg.inv_table(i).project_id;
      l_inv_rec.task_id := fa_load_tbl_pkg.inv_table(i).task_id;
      l_inv_rec.material_indicator_flag :=
         fa_load_tbl_pkg.inv_table(i).material_indicator_flag;
      l_inv_rec.depreciate_in_group_flag :=
         fa_load_tbl_pkg.inv_table(i).depreciate_in_group_flag;
      l_inv_rec.source_line_id := fa_load_tbl_pkg.inv_table(i).source_line_id;
      l_inv_rec.attribute1 := fa_load_tbl_pkg.inv_table(i).attribute1;
      l_inv_rec.attribute2 := fa_load_tbl_pkg.inv_table(i).attribute2;
      l_inv_rec.attribute3 := fa_load_tbl_pkg.inv_table(i).attribute3;
      l_inv_rec.attribute4 := fa_load_tbl_pkg.inv_table(i).attribute4;
      l_inv_rec.attribute5 := fa_load_tbl_pkg.inv_table(i).attribute5;
      l_inv_rec.attribute6 := fa_load_tbl_pkg.inv_table(i).attribute6;
      l_inv_rec.attribute7 := fa_load_tbl_pkg.inv_table(i).attribute7;
      l_inv_rec.attribute8 := fa_load_tbl_pkg.inv_table(i).attribute8;
      l_inv_rec.attribute9 := fa_load_tbl_pkg.inv_table(i).attribute9;
      l_inv_rec.attribute10 := fa_load_tbl_pkg.inv_table(i).attribute10;
      l_inv_rec.attribute11 := fa_load_tbl_pkg.inv_table(i).attribute11;
      l_inv_rec.attribute12 := fa_load_tbl_pkg.inv_table(i).attribute12;
      l_inv_rec.attribute13 := fa_load_tbl_pkg.inv_table(i).attribute13;
      l_inv_rec.attribute14 := fa_load_tbl_pkg.inv_table(i).attribute14;
      l_inv_rec.attribute15 := fa_load_tbl_pkg.inv_table(i).attribute15;
      l_inv_rec.attribute_category_code :=
         fa_load_tbl_pkg.inv_table(i).attribute_cat_code;

      if (p_reset_miss_flag = 'YES') then
         -- Fix for Bug #2653564.  Need to pass different record groups to
         -- IN and OUT parameters.
         l_inv_rec_old := l_inv_rec;

         if (NOT fa_trans_api_pvt.set_inv_rec (
             p_inv_rec               => l_inv_rec_old,
             x_inv_rec_new           => l_inv_rec,
             p_mrc_sob_type_code     => 'P'
         )) then
            raise desc_err;
         end if;
      end if;

      l_inv_tbl(i) := l_inv_rec;
   end loop;

   fa_asset_desc_pub.update_invoice_desc (
          p_api_version      => p_api_version,
          p_init_msg_list    => p_init_msg_list ,
          p_commit           => p_commit,
          p_validation_level => p_validation_level,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          p_calling_fn       => p_calling_fn,
          px_trans_rec       => l_trans_rec,
          px_asset_hdr_rec   => l_asset_hdr_rec,
          px_inv_tbl_new     => l_inv_tbl);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

EXCEPTION
   when desc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pub.do_inv_desc_upd',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_inv_desc_upd',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_invoice_desc_update;

PROCEDURE do_retirement_desc_update (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     p_reset_miss_flag               IN    VARCHAR2 DEFAULT 'NO',
     -- Transaction Info (Retirement) --
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_last_update_login            IN     NUMBER,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Asset Retirement Info --
     p_retirement_id                IN     NUMBER,
     p_proceeds_of_sale             IN     NUMBER   DEFAULT NULL,
     p_cost_of_removal              IN     NUMBER   DEFAULT NULL,
     p_retirement_type_code         IN     VARCHAR2 DEFAULT NULL,
     p_retire_prorate_convention    IN     VARCHAR2 DEFAULT NULL,
     p_sold_to                      IN     VARCHAR2 DEFAULT NULL,
     p_trade_in_asset_id            IN     NUMBER   DEFAULT NULL,
     p_status                       IN     VARCHAR2 DEFAULT NULL,
     p_reference_num                IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute1               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute2               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute3               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute4               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute5               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute6               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute7               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute8               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute9               IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute10              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute11              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute12              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute13              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute14              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute15              IN     VARCHAR2 DEFAULT NULL,
     p_ret_attribute_category_code  IN     VARCHAR2 DEFAULT NULL
) AS

    l_trans_rec                fa_api_types.trans_rec_type;
    l_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
    l_asset_retire_rec         fa_api_types.asset_retire_rec_type;
    l_asset_retire_rec_old     fa_api_types.asset_retire_rec_type;

    desc_err                   exception;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   --l_trans_rec.transaction_date_entered :=
   --l_trans_rec.transaction_name :=
   --l_trans_rec.source_transaction_header_id :=
   --l_trans_rec.mass_reference_id :=
   --l_trans_rec.transaction_subtype :=
   --l_trans_rec.transaction_key :=
   --l_trans_rec.amortization_start_date :=
   --l_trans_rec.calling_interface :=
   --l_trans_rec.desc_flex.attribute1 :=
   --l_trans_rec.desc_flex.attribute2 :=
   --l_trans_rec.desc_flex.attribute3 :=
   --l_trans_rec.desc_flex.attribute4 :=
   --l_trans_rec.desc_flex.attribute5 :=
   --l_trans_rec.desc_flex.attribute6 :=
   --l_trans_rec.desc_flex.attribute7 :=
   --l_trans_rec.desc_flex.attribute8 :=
   --l_trans_rec.desc_flex.attribute9 :=
   --l_trans_rec.desc_flex.attribute10 :=
   --l_trans_rec.desc_flex.attribute11 :=
   --l_trans_rec.desc_flex.attribute12 :=
   --l_trans_rec.desc_flex.attribute13 :=
   --l_trans_rec.desc_flex.attribute14 :=
   --l_trans_rec.desc_flex.attribute15 :=
   --l_trans_rec.desc_flex.attribute_category_code :=
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := NULL;
   l_trans_rec.who_info.creation_date := NULL;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_Asset_Id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Asset Retirement Info ***** --
   l_asset_retire_rec.retirement_id := p_retirement_id;
   l_asset_retire_rec.proceeds_of_sale := p_proceeds_of_sale;
   l_asset_retire_rec.cost_of_removal := p_cost_of_removal;
   l_asset_retire_rec.retirement_type_code := p_retirement_type_code;
   l_asset_retire_rec.retirement_prorate_convention :=
      p_retire_prorate_convention;
   l_asset_retire_rec.sold_to := p_sold_to;
   l_asset_retire_rec.trade_in_asset_id := p_trade_in_asset_id;
   l_asset_retire_rec.status := p_status;
   l_asset_retire_rec.reference_num := p_reference_num;
   l_asset_retire_rec.desc_flex.attribute1 := p_ret_attribute1;
   l_asset_retire_rec.desc_flex.attribute2 := p_ret_attribute2;
   l_asset_retire_rec.desc_flex.attribute3 := p_ret_attribute3;
   l_asset_retire_rec.desc_flex.attribute4 := p_ret_attribute4;
   l_asset_retire_rec.desc_flex.attribute5 := p_ret_attribute5;
   l_asset_retire_rec.desc_flex.attribute6 := p_ret_attribute6;
   l_asset_retire_rec.desc_flex.attribute7 := p_ret_attribute7;
   l_asset_retire_rec.desc_flex.attribute8 := p_ret_attribute8;
   l_asset_retire_rec.desc_flex.attribute9 := p_ret_attribute9;
   l_asset_retire_rec.desc_flex.attribute10 := p_ret_attribute10;
   l_asset_retire_rec.desc_flex.attribute11 := p_ret_attribute11;
   l_asset_retire_rec.desc_flex.attribute12 := p_ret_attribute12;
   l_asset_retire_rec.desc_flex.attribute13 := p_ret_attribute13;
   l_asset_retire_rec.desc_flex.attribute14 := p_ret_attribute14;
   l_asset_retire_rec.desc_flex.attribute15 := p_ret_attribute15;
   l_asset_retire_rec.desc_flex.attribute_category_code :=
      p_ret_attribute_category_code;

   if (p_reset_miss_flag = 'YES') then
      -- Fix for Bug #2653564.  Need to pass different record groups to
      -- IN and OUT parameters.
      l_asset_retire_rec_old := l_asset_retire_rec;

      if (NOT fa_trans_api_pvt.set_asset_retire_rec (
           p_asset_retire_rec      => l_asset_retire_rec_old,
           x_asset_retire_rec_new  => l_asset_retire_rec,
           p_mrc_sob_type_code     => 'P'
      )) then
         raise desc_err;
      end if;
   end if;

   fa_asset_desc_pub.update_retirement_desc (
          p_api_version           => p_api_version,
          p_init_msg_list         => p_init_msg_list,
          p_commit                => p_commit,
          p_validation_level      => p_validation_level,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_calling_fn            => p_calling_fn,
          px_trans_rec            => l_trans_rec,
          px_asset_hdr_rec        => l_asset_hdr_rec,
          px_asset_retire_rec_new => l_asset_retire_rec);

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

EXCEPTION
   when desc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pub.do_ret_desc_upd',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_ret_desc_upd',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_retirement_desc_update;

PROCEDURE do_unplanned (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_transaction_subtype          IN     VARCHAR2 DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     p_set_of_books_id              IN     NUMBER   DEFAULT NULL,
     -- Unplanned Depreciation Info --
     p_code_combination_id          IN     NUMBER,
     p_unplanned_amount             IN     NUMBER,
     p_unplanned_type               IN     VARCHAR2 DEFAULT NULL
) AS

    l_trans_rec                fa_api_types.trans_rec_type;
    l_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
    l_unplanned_deprn_rec      fa_api_types.unplanned_deprn_rec_type;

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Asset Transaction Info ***** --
   --l_trans_rec.transaction_header_id :=
   --l_trans_rec.transaction_type_code :=
   l_trans_rec.transaction_date_entered := p_transaction_date_entered;
   l_trans_rec.transaction_name := p_transaction_name;
   --l_trans_rec.source_transaction_header_id :=
   --l_trans_rec.mass_reference_id :=
   l_trans_rec.transaction_subtype := p_transaction_subtype;
   --l_trans_rec.transaction_key :=
   l_trans_rec.amortization_start_date := p_amortization_start_date;
   l_trans_rec.calling_interface := p_calling_interface;
   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   if (p_amortization_start_date is NOT NULL) then
      --l_trans_rec.transaction_date_entered := p_amortization_start_date;
      l_trans_rec.transaction_subtype := 'AMORTIZED';
      l_trans_rec.amortization_start_date := NULL;
   end if;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_asset_id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;
   --l_asset_hdr_rec.period_of_addition :=

   -- Derive set of books id for primary book
   if (l_asset_hdr_rec.set_of_books_id is NULL) then
      select set_of_books_id
      into   l_asset_hdr_rec.set_of_books_id
      from   fa_book_controls
      where  book_type_code = l_asset_hdr_rec.book_type_code;
   end if;

   -- ***** Unplanned Depreciation Info ***** --
   l_unplanned_deprn_rec.code_combination_id := p_code_combination_id;
   l_unplanned_deprn_rec.unplanned_amount := p_unplanned_amount;
   l_unplanned_deprn_rec.unplanned_type := substr(p_unplanned_type,1,9);

   -- Call Public Unplanned Depreciation API
   fa_unplanned_pub.do_unplanned
      (p_api_version         => p_api_version,
       p_init_msg_list       => p_init_msg_list,
       p_commit              => p_commit,
       p_validation_level    => p_validation_level,
       p_calling_fn          => p_calling_fn,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       px_trans_rec          => l_trans_rec,
       px_asset_hdr_rec      => l_asset_hdr_rec,
       p_unplanned_deprn_rec => l_unplanned_deprn_rec
   );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      return;
   end if;

   x_transaction_header_id := l_trans_rec.transaction_header_id;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_unplanned',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_unplanned;

PROCEDURE do_reserve_transfer (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_src_transaction_header_id       OUT NOCOPY NUMBER,
     x_dest_transaction_header_id      OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_transaction_subtype          IN     VARCHAR2 DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_src_asset_id                 IN     NUMBER,  -- Source Asset Id
     p_book_type_code               IN     VARCHAR2,-- Source Book Type Code
     -- Reserve Transfer Info --
     p_transfer_amount              IN     NUMBER,
     p_dest_asset_id                IN     NUMBER   -- Destination Asset Id
) IS

  l_src_trans_rec     FA_API_TYPES.trans_rec_type;
  l_dest_trans_rec    FA_API_TYPES.trans_rec_type;

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  if FND_API.To_Boolean(p_init_msg_list) then
    -- Initialize error message stack.
    FA_SRVR_MSG.Init_Server_Message;

    -- Initialize debug message stack.
    FA_DEBUG_PKG.Initialize;
  end if;

  -- Override FA:PRINT_DEBUG profile option.
  if (p_debug_flag = 'YES') then
    FA_DEBUG_PKG.Set_Debug_Flag;
  end if;

   -- ***** Source Asset Transaction Info ***** --
   l_src_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   l_src_trans_rec.transaction_subtype := 'AMORTIZED';

   l_src_trans_rec.who_info.last_update_date := p_last_update_date;
   l_src_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_src_trans_rec.who_info.created_by := p_created_by;
   l_src_trans_rec.who_info.creation_date := p_creation_date;
   --l_src_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Destination Asset Transaction Info ***** --
   l_dest_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   l_dest_trans_rec.transaction_subtype := 'AMORTIZED';

   l_dest_trans_rec.who_info.last_update_date := p_last_update_date;
   l_dest_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_dest_trans_rec.who_info.created_by := p_created_by;
   l_dest_trans_rec.who_info.creation_date := p_creation_date;
   --l_dest_trans_rec.who_info.last_update_login := p_last_update_login;



  FA_RESERVE_TRANSFER_PUB.do_reserve_transfer (
    p_api_version       => p_api_version,
    p_init_msg_list     => p_init_msg_list,
    p_commit            => p_commit,
    p_validation_level  => p_validation_level,
    p_calling_fn        => p_calling_fn,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_src_asset_id      => p_src_asset_id,
    p_dest_asset_id     => p_dest_asset_id,
    p_book_type_code    => p_book_type_code,
    p_amount            => p_transfer_amount,
    px_src_trans_rec    => l_src_trans_rec,
    px_dest_trans_rec   => l_dest_trans_rec);

  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    x_src_transaction_header_id := l_src_trans_rec.transaction_header_id;
    x_dest_transaction_header_id := l_dest_trans_rec.transaction_header_id;
    return;
  end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_rsv_xfr',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END do_reserve_transfer;

PROCEDURE do_retirement_adjustment (
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_date_entered     IN     DATE     DEFAULT NULL,
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_transaction_subtype          IN     VARCHAR2 DEFAULT NULL,
     p_amortization_start_date      IN     DATE     DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     -- Retirement Adjustment Info --
     p_proceeds_of_sale             IN     NUMBER,
     p_cost_of_removal              IN     NUMBER
) IS

    l_trans_rec                fa_api_types.trans_rec_type;
    l_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;

BEGIN
  l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
  l_trans_rec.transaction_subtype := 'AMORTIZED';

  l_trans_rec.who_info.last_update_date := p_last_update_date;
  l_trans_rec.who_info.last_updated_by := p_last_updated_by;
  l_trans_rec.who_info.created_by := p_created_by;
  l_trans_rec.who_info.creation_date := p_creation_date;

  -- ***** Asset Header Info ***** --
  l_asset_hdr_rec.asset_id := p_asset_id;
  l_asset_hdr_rec.book_type_code := p_book_type_code;
--  l_asset_hdr_rec.set_of_books_id := p_set_of_books_id;

  FA_RETIREMENT_ADJUSTMENT_PUB.do_retirement_adjustment
        (p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         p_commit           => p_commit,
         p_validation_level => p_validation_level,
         p_calling_fn       => p_calling_fn,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         px_trans_rec       => l_trans_rec,
         px_asset_hdr_rec   => l_asset_hdr_rec,
         p_cost_of_removal  => p_cost_of_removal,
         p_proceeds         => p_proceeds_of_sale
        );

  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    x_transaction_header_id := l_trans_rec.transaction_header_id;
    return;
  end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_ret_adj',
                   p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
END do_retirement_adjustment;

PROCEDURE do_tax_reserve_adjustment(
     -- Standard Parameters --
     p_api_version                  IN     NUMBER,
     p_init_msg_list                IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                       IN     VARCHAR2 := FND_API.G_FALSE,
     p_validation_level             IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                   OUT NOCOPY VARCHAR2,
     x_msg_count                       OUT NOCOPY NUMBER,
     x_msg_data                        OUT NOCOPY VARCHAR2,
     p_calling_fn                   IN     VARCHAR2,
     -- API Options --
     p_debug_flag                   IN     VARCHAR2 DEFAULT 'NO',
     -- Out Parameters --
     x_transaction_header_id           OUT NOCOPY NUMBER,
     -- Transaction Info --
     p_transaction_name             IN     VARCHAR2 DEFAULT NULL,
     p_mass_reference_id            IN     NUMBER   DEFAULT NULL,
     p_calling_interface            IN     VARCHAR2 DEFAULT 'CUSTOM',
     p_last_update_date             IN     DATE,
     p_last_updated_by              IN     NUMBER,
     p_created_by                   IN     NUMBER,
     p_creation_date                IN     DATE,
     p_last_update_login            IN     NUMBER,
     p_attribute1                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute2                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute3                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute4                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute5                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute6                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute7                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute8                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute9                   IN     VARCHAR2 DEFAULT NULL,
     p_attribute10                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute11                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute12                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute13                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute14                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute15                  IN     VARCHAR2 DEFAULT NULL,
     p_attribute_category_code      IN     VARCHAR2 DEFAULT NULL,
     -- Asset Header Info --
     p_asset_id                     IN     NUMBER,
     p_book_type_code               IN     VARCHAR2,
     -- Tax Reserve Adjustment Info --
     p_fiscal_year                  IN     NUMBER,
     p_adjusted_ytd_deprn           IN OUT NOCOPY NUMBER,      -- Delta (New_FY_Ytd_Deprn - Old_FY_Ytd_Deprn)
     p_deprn_basis_formula          IN     NUMBER,
     p_run_mode                     IN     VARCHAR2 DEFAULT 'RUN'
) IS

    l_trans_rec                fa_api_types.trans_rec_type;
    l_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
    l_asset_tax_rsv_adj_rec    fa_api_types.asset_tax_rsv_adj_rec_type;

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      -- Initialize error message stack.
      FA_SRVR_MSG.Init_Server_Message;

      -- Initialize debug message stack.
      FA_DEBUG_PKG.Initialize;
   END IF;

   -- Override FA:PRINT_DEBUG profile option.
   IF (p_debug_flag = 'YES') THEN
      FA_DEBUG_PKG.Set_Debug_Flag;
   END IF;

   -- ***** Tax reserve adjustment Info ***** --
   l_asset_tax_rsv_adj_rec.fiscal_year := p_fiscal_year;
   l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn := p_adjusted_ytd_deprn;
   l_asset_tax_rsv_adj_rec.deprn_basis_formula := p_deprn_basis_formula;
   l_asset_tax_rsv_adj_rec.run_mode := p_run_mode;
    -- ***** Transaction Header Info ***** --
   l_trans_rec.transaction_name := p_transaction_name;
   l_trans_rec.mass_reference_id := p_mass_reference_id;
   l_trans_rec.calling_interface := p_calling_interface;

   If  l_asset_tax_rsv_adj_rec.deprn_basis_formula = 'STRICT_FLAT' then
       l_trans_rec.transaction_subtype := 'AMORTIZED';
       l_trans_rec.amortization_start_date := sysdate;
   else
       l_trans_rec.transaction_subtype := 'EXPENSED';
       l_trans_rec.amortization_start_date := NULL;
   end if;

   l_trans_rec.desc_flex.attribute1 := p_attribute1;
   l_trans_rec.desc_flex.attribute2 := p_attribute2;
   l_trans_rec.desc_flex.attribute3 := p_attribute3;
   l_trans_rec.desc_flex.attribute4 := p_attribute4;
   l_trans_rec.desc_flex.attribute5 := p_attribute5;
   l_trans_rec.desc_flex.attribute6 := p_attribute6;
   l_trans_rec.desc_flex.attribute7 := p_attribute7;
   l_trans_rec.desc_flex.attribute8 := p_attribute8;
   l_trans_rec.desc_flex.attribute9 := p_attribute9;
   l_trans_rec.desc_flex.attribute10 := p_attribute10;
   l_trans_rec.desc_flex.attribute11 := p_attribute11;
   l_trans_rec.desc_flex.attribute12 := p_attribute12;
   l_trans_rec.desc_flex.attribute13 := p_attribute13;
   l_trans_rec.desc_flex.attribute14 := p_attribute14;
   l_trans_rec.desc_flex.attribute15 := p_attribute15;
   l_trans_rec.desc_flex.attribute_category_code := p_attribute_category_code;
   l_trans_rec.who_info.last_update_date := p_last_update_date;
   l_trans_rec.who_info.last_updated_by := p_last_updated_by;
   l_trans_rec.who_info.created_by := p_created_by;
   l_trans_rec.who_info.creation_date := p_creation_date;
   l_trans_rec.who_info.last_update_login := p_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id := p_asset_id;
   l_asset_hdr_rec.book_type_code := p_book_type_code;

   fa_tax_rsv_adj_pub.do_tax_rsv_adj
        (p_api_version           => p_api_version,
         p_init_msg_list         => p_init_msg_list,
         p_commit                => p_commit,
         p_validation_level      => p_validation_level,
         p_calling_fn            => p_calling_fn,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         px_trans_rec            => l_trans_rec,
         px_asset_hdr_rec        => l_asset_hdr_rec,
         p_asset_tax_rsv_adj_rec => l_asset_tax_rsv_adj_rec
        );

   if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       x_transaction_header_id := l_trans_rec.transaction_header_id;
       return;
   end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pub.do_tax_rsv_adj');
      x_return_status := FND_API.G_RET_STS_ERROR;
END do_tax_reserve_adjustment;


END FA_TRANS_API_PUB;

/
