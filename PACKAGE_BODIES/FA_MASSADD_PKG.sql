--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_PKG" as
/* $Header: FAMAPTB.pls 120.32.12010000.6 2010/05/03 12:29:59 spooyath ship $   */

----------------------------------------------------------------


g_log_level_rec fa_api_types.log_level_rec_type;

G_times_called  number := 0;
G_count         number := 0;  -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy

-- used for new MP assets in current session
type mp_asset_rec_type IS RECORD (
       asset_id               number,
       asset_type             varchar2(15),
       category_id            number,
       date_placed_in_service date,
       description            varchar2(150),
       fiscal_year            varchar2(4),
       start_date             date,
       end_date               date);

type mp_asset_tbl_type IS TABLE of mp_asset_rec_type INDEX BY BINARY_INTEGER;

G_new_mp_asset_tbl mp_asset_tbl_type;
g_last_mp_category_id number := -1;

PROCEDURE Do_Mass_Addition
            (p_book_type_code          IN     VARCHAR2,
             p_mode                    IN     VARCHAR2,
             p_loop_count              IN     NUMBER,
             p_parent_request_id       IN     NUMBER,
             p_total_requests          IN     NUMBER,
             p_request_number          IN     NUMBER,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number) IS

   Error      varchar2(100);
   l_calling_fn                VARCHAR2(50) := 'fa_massadd_pkg.do_mass_addition';
   l_inv_indicator             NUMBER := 1;
   l_inv_rate                  NUMBER := 0;
   l_dist                      NUMBER := 0;
   l_inv_rate_tbl_count        NUMBER := 0;
   i                           NUMBER;   -- used for main massadd loop

   -- this value can be altered in order to process more of less per batch
   l_batch_size                NUMBER;

   -- variables for api calls
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(4000);
   l_return_status             VARCHAR2(1);



   l_trans_rec                 FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec            FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec            FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec             FA_API_TYPES.asset_cat_rec_type;
   l_asset_type_rec            FA_API_TYPES.asset_type_rec_type;
   l_asset_hierarchy_rec       FA_API_TYPES.asset_hierarchy_rec_type;
   l_asset_fin_rec_adj         FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new         FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;
   l_inv_trans_rec             FA_API_TYPES.inv_trans_rec_type;
   l_inv_rec                   FA_API_TYPES.inv_rec_type;
   l_inv_tbl                   FA_API_TYPES.inv_tbl_type;
   l_inv_rate_rec              FA_API_TYPES.inv_rate_rec_type;
   l_asset_deprn_rec_adj       FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new       FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new   FA_API_TYPES.asset_deprn_tbl_type;
   l_asset_dist_rec            FA_API_TYPES.asset_dist_rec_type;
   l_asset_dist_tbl            FA_API_TYPES.asset_dist_tbl_type;
   l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;
   l_recl_opt_rec              FA_API_TYPES.reclass_options_rec_type;

   -- Fix for Bug #6336083
   l_trans_desc_flex_rec       FA_API_TYPES.desc_flex_rec_type;

   l_dist_id_tbl               num_tbl_type;
   l_dist_units_tbl            num_tbl_type;
   l_dist_ccid_tbl             num_tbl_type;
   l_dist_locid_tbl            num_tbl_type;
   l_dist_assigned_to_tbl      num_tbl_type;

   l_units_adjusted            number:= 0;

   -- used for bulk fetching
   -- main cursor
   l_mass_addition_id_tbl              num_tbl_type;
   l_asset_number_tbl                  char_tbl_type;
   l_tag_number_tbl                    char_tbl_type;
   l_description_tbl                   char_tbl_type;
   l_asset_category_id_tbl             num_tbl_type;
   l_manufacturer_name_tbl             char_tbl_type;
   l_serial_number_tbl                 char_tbl_type;
   l_model_number_tbl                  char_tbl_type;
   l_book_type_code_tbl                char_tbl_type;
   l_date_placed_in_service_tbl        date_tbl_type;
   l_fixed_assets_cost_tbl             num_tbl_type;
   l_payables_units_tbl                num_tbl_type;
   l_fixed_assets_units_tbl            num_tbl_type;
   l_payables_ccid_tbl                 num_tbl_type;
   l_expense_ccid_tbl                  num_tbl_type;
   l_location_id_tbl                   num_tbl_type;
   l_assigned_to_tbl                   num_tbl_type;
   l_feeder_system_name_tbl            char_tbl_type;
   l_create_batch_date_tbl             date_tbl_type;
   l_create_batch_id_tbl               num_tbl_type;
   l_last_update_date_tbl              date_tbl_type;
   l_last_updated_by_tbl               num_tbl_type;
   l_reviewer_comments_tbl             char_tbl_type;
   l_invoice_number_tbl                char_tbl_type;
   l_vendor_number_tbl                 char_tbl_type;
   l_po_vendor_id_tbl                  num_tbl_type;
   l_po_number_tbl                     char_tbl_type;
   l_posting_status_tbl                char_tbl_type;
   l_queue_name_tbl                    char_tbl_type;
   l_invoice_date_tbl                  date_tbl_type;
   l_invoice_created_by_tbl            num_tbl_type;
   l_invoice_updated_by_tbl            num_tbl_type;
   l_payables_cost_tbl                 num_tbl_type;
   l_invoice_id_tbl                    num_tbl_type;
   l_payables_batch_name_tbl           char_tbl_type;
   l_depreciate_flag_tbl               char_tbl_type;
   l_parent_mass_addition_id_tbl       num_tbl_type;
   l_parent_asset_id_tbl               num_tbl_type;
   l_split_merged_code_tbl             char_tbl_type;
   l_ap_dist_line_num_tbl              num_tbl_type;
   l_post_batch_id_tbl                 num_tbl_type;
   l_add_to_asset_id_tbl               num_tbl_type;
   l_amortize_flag_tbl                 char_tbl_type;
   l_new_master_flag_tbl               char_tbl_type;
   l_asset_key_ccid_tbl                num_tbl_type;
   l_asset_type_tbl                    char_tbl_type;
   l_deprn_reserve_tbl                 num_tbl_type;
   l_ytd_deprn_tbl                     num_tbl_type;
   l_beginning_nbv_tbl                 num_tbl_type;
   l_created_by_tbl                    num_tbl_type;
   l_creation_date_tbl                 date_tbl_type;
   l_last_update_login_tbl             num_tbl_type;
   l_salvage_value_tbl                 num_tbl_type;
   l_accounting_date_tbl               date_tbl_type;
   l_attribute_category_code_tbl       char_tbl_type;
   l_fully_rsvd_revals_ctr_tbl         num_tbl_type;
   l_merge_invoice_number_tbl          char_tbl_type;
   l_merge_vendor_number_tbl           char_tbl_type;
   l_production_capacity_tbl           num_tbl_type;
   l_reval_amortization_basis_tbl      num_tbl_type;
   l_reval_reserve_tbl                 num_tbl_type;
   l_unit_of_measure_tbl               char_tbl_type;
   l_unrevalued_cost_tbl               num_tbl_type;
   l_ytd_reval_deprn_expense_tbl       num_tbl_type;
   l_merged_code_tbl                   char_tbl_type;
   l_split_code_tbl                    char_tbl_type;
   l_merge_parent_massadd_id_tbl       num_tbl_type;
   l_split_parent_massadd_id_tbl       num_tbl_type;
   l_project_asset_line_id_tbl         num_tbl_type;
   l_project_id_tbl                    num_tbl_type;
   l_task_id_tbl                       num_tbl_type;
   l_sum_units_tbl                     char_tbl_type;
   l_dist_name_tbl                     char_tbl_type;
   l_context_tbl                       char_tbl_type;
   l_inventorial_tbl                   char_tbl_type;
   l_short_fiscal_year_flag_tbl        char_tbl_type;
   l_conversion_date_tbl               date_tbl_type;
   l_orig_deprn_start_date_tbl         date_tbl_type;
   l_group_asset_id_tbl                num_tbl_type;
   l_cua_parent_hierarchy_id_tbl       num_tbl_type;
   l_units_to_adjust_tbl               num_tbl_type;
   l_bonus_ytd_deprn_tbl               num_tbl_type;
   l_bonus_deprn_reserve_tbl           num_tbl_type;
   l_amortize_nbv_flag_tbl             char_tbl_type;
   l_amortization_start_date_tbl       date_tbl_type;
   l_transaction_type_code_tbl         char_tbl_type;
   l_transaction_date_tbl              date_tbl_type;
   l_warranty_id_tbl                   num_tbl_type;
   l_lease_id_tbl                      num_tbl_type;
   l_lessor_id_tbl                     num_tbl_type;
   l_property_type_code_tbl            char_tbl_type;
   l_property_1245_1250_code_tbl       char_tbl_type;
   l_in_use_flag_tbl                   char_tbl_type;
   l_owned_leased_tbl                  char_tbl_type;
   l_new_used_tbl                      char_tbl_type;
   l_asset_id_tbl                      num_tbl_type;
   l_material_indicator_flag_tbl       char_tbl_type;
   l_mass_property_flag_tbl            char_tbl_type;
   l_deprn_method_code_tbl             char_tbl_type; -- start new fields
   l_life_in_months_tbl                num_tbl_type;
   l_basic_rate_tbl                    num_tbl_type;
   l_adjusted_rate_tbl                 num_tbl_type;
   l_prorate_convention_code_tbl       char_tbl_type;
   l_bonus_rule_tbl                    char_tbl_type;
   l_salvage_type_tbl                  char_tbl_type;
   l_percent_salvage_value_tbl         num_tbl_type;
   l_deprn_limit_type_tbl              char_tbl_type;
   l_allowed_deprn_limit_amt_tbl       num_tbl_type;
   l_allowed_deprn_limit_tbl           num_tbl_type;
   l_invoice_distribution_id_tbl       num_tbl_type;
   l_invoice_line_number_tbl           num_tbl_type;
   l_po_distribution_id_tbl            num_tbl_type;  -- end new fields
   l_attribute1_tbl                    char_tbl_type;
   l_attribute2_tbl                    char_tbl_type;
   l_attribute3_tbl                    char_tbl_type;
   l_attribute4_tbl                    char_tbl_type;
   l_attribute5_tbl                    char_tbl_type;
   l_attribute6_tbl                    char_tbl_type;
   l_attribute7_tbl                    char_tbl_type;
   l_attribute8_tbl                    char_tbl_type;
   l_attribute9_tbl                    char_tbl_type;
   l_attribute10_tbl                   char_tbl_type;
   l_attribute11_tbl                   char_tbl_type;
   l_attribute12_tbl                   char_tbl_type;
   l_attribute13_tbl                   char_tbl_type;
   l_attribute14_tbl                   char_tbl_type;
   l_attribute15_tbl                   char_tbl_type;
   l_attribute16_tbl                   char_tbl_type;
   l_attribute17_tbl                   char_tbl_type;
   l_attribute18_tbl                   char_tbl_type;
   l_attribute19_tbl                   char_tbl_type;
   l_attribute20_tbl                   char_tbl_type;
   l_attribute21_tbl                   char_tbl_type;
   l_attribute22_tbl                   char_tbl_type;
   l_attribute23_tbl                   char_tbl_type;
   l_attribute24_tbl                   char_tbl_type;
   l_attribute25_tbl                   char_tbl_type;
   l_attribute26_tbl                   char_tbl_type;
   l_attribute27_tbl                   char_tbl_type;
   l_attribute28_tbl                   char_tbl_type;
   l_attribute29_tbl                   char_tbl_type;
   l_attribute30_tbl                   char_tbl_type;
   l_global_attribute1_tbl             char_tbl_type;
   l_global_attribute2_tbl             char_tbl_type;
   l_global_attribute3_tbl             char_tbl_type;
   l_global_attribute4_tbl             char_tbl_type;
   l_global_attribute5_tbl             char_tbl_type;
   l_global_attribute6_tbl             char_tbl_type;
   l_global_attribute7_tbl             char_tbl_type;
   l_global_attribute8_tbl             char_tbl_type;
   l_global_attribute9_tbl             char_tbl_type;
   l_global_attribute10_tbl            char_tbl_type;
   l_global_attribute11_tbl            char_tbl_type;
   l_global_attribute12_tbl            char_tbl_type;
   l_global_attribute13_tbl            char_tbl_type;
   l_global_attribute14_tbl            char_tbl_type;
   l_global_attribute15_tbl            char_tbl_type;
   l_global_attribute16_tbl            char_tbl_type;
   l_global_attribute17_tbl            char_tbl_type;
   l_global_attribute18_tbl            char_tbl_type;
   l_global_attribute19_tbl            char_tbl_type;
   l_global_attribute20_tbl            char_tbl_type;
   l_global_attribute_cat_tbl          char_tbl_type;

   l_th_attribute1_tbl                 char_tbl_type;
   l_th_attribute2_tbl                 char_tbl_type;
   l_th_attribute3_tbl                 char_tbl_type;
   l_th_attribute4_tbl                 char_tbl_type;
   l_th_attribute5_tbl                 char_tbl_type;
   l_th_attribute6_tbl                 char_tbl_type;
   l_th_attribute7_tbl                 char_tbl_type;
   l_th_attribute8_tbl                 char_tbl_type;
   l_th_attribute9_tbl                 char_tbl_type;
   l_th_attribute10_tbl                char_tbl_type;
   l_th_attribute11_tbl                char_tbl_type;
   l_th_attribute12_tbl                char_tbl_type;
   l_th_attribute13_tbl                char_tbl_type;
   l_th_attribute14_tbl                char_tbl_type;
   l_th_attribute15_tbl                char_tbl_type;
   l_th_attribute_cat_code_tbl         char_tbl_type;
   l_nbv_at_switch_tbl                 num_tbl_type;  -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy
   l_prior_deprn_limit_type_tbl        char_tbl_type;
   l_prior_deprn_limit_amt_tbl         num_tbl_type;
   l_prior_deprn_limit_tbl             num_tbl_type;
   --l_period_full_reserve_tbl         num_tbl_type;
   --l_period_extd_deprn_tbl           num_tbl_type;
   l_period_full_reserve_tbl           char_tbl_type;
   l_period_extd_deprn_tbl             char_tbl_type;
   l_prior_deprn_method_tbl            char_tbl_type;
   l_prior_life_in_months_tbl          num_tbl_type;
   l_prior_basic_rate_tbl              num_tbl_type;

   l_prior_adjusted_rate_tbl           num_tbl_type;  -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End

   -- merged child cursor
   l_c_mass_addition_id_tbl              num_tbl_type;
   l_c_description_tbl                   char_tbl_type;
   l_c_payables_units_tbl                num_tbl_type;
   l_c_fixed_assets_cost_tbl             num_tbl_type;
   l_c_payables_ccid_tbl                 num_tbl_type;
   l_c_feeder_system_name_tbl            char_tbl_type;
   l_c_create_batch_date_tbl             date_tbl_type;
   l_c_create_batch_id_tbl               num_tbl_type;
   l_c_invoice_number_tbl                char_tbl_type;
   l_c_po_vendor_id_tbl                  num_tbl_type;
   l_c_po_number_tbl                     char_tbl_type;
   l_c_invoice_date_tbl                  date_tbl_type;
   l_c_payables_cost_tbl                 num_tbl_type;
   l_c_invoice_id_tbl                    num_tbl_type;
   l_c_payables_batch_name_tbl           char_tbl_type;
   l_c_split_merged_code_tbl             char_tbl_type;
   l_c_ap_dist_line_num_tbl              num_tbl_type;
   l_c_deprn_reserve_tbl                 num_tbl_type;
   l_c_ytd_deprn_tbl                     num_tbl_type;
   l_c_reval_amort_basis_tbl             num_tbl_type;
   l_c_reval_reserve_tbl                 num_tbl_type;
   l_c_unrevalued_cost_tbl               num_tbl_type;
   l_c_ytd_reval_deprn_exp_tbl           num_tbl_type;
   l_c_merged_code_tbl                   char_tbl_type;
   l_c_split_code_tbl                    char_tbl_type;
   l_c_merge_parent_massadd_tbl          num_tbl_type;
   l_c_split_parent_massadd_tbl          num_tbl_type;
   l_c_project_asset_line_id_tbl         num_tbl_type;
   l_c_project_id_tbl                    num_tbl_type;
   l_c_task_id_tbl                       num_tbl_type;
   l_c_bonus_ytd_deprn_tbl               num_tbl_type;
   l_c_bonus_deprn_reserve_tbl           num_tbl_type;
   l_c_material_indicator_flag           char_tbl_type;
   l_c_invoice_dist_id_tbl               num_tbl_type;
   l_c_invoice_line_number_tbl           num_tbl_type;
   l_c_po_distribution_id_tbl            num_tbl_type;


   -- mass rates cursor
   l_set_of_books_id_tbl                 num_tbl_type;
   l_exchange_rate_tbl                   num_tbl_type;
   l_mc_fixed_assets_cost_tbl            num_tbl_type;

   -- massadd distributions cursor
   l_mad_units_tbl                       num_tbl_type;
   l_mad_employee_id_tbl                 num_tbl_type;
   l_mad_deprn_expense_ccid_tbl          num_tbl_type;
   l_mad_location_id_tbl                 num_tbl_type;


   l_md               number;
   l_distid           number;
   l_units_assigned   number;
   l_ccid             number;
   l_locid            number;
   l_assigned_to      number;


   -- unit adjustment dists cursor
   l_dh_distribution_id_tbl              num_tbl_type;
   l_dh_units_assigned_tbl               num_tbl_type;

   l_succ_asset_number           varchar2(15);
   l_fail_mass_addition_id_tbl   num_tbl_type;


   error_found                EXCEPTION;
   error_found_trx            EXCEPTION;
   done_exc                   EXCEPTION;
   init_err                   EXCEPTION;


   CURSOR c_mass_additions
             (p_book_type_code             varchar2,
              p_parent_request_id          number,
              p_request_number             number,
              p_process_order              number) IS
     select ma.mass_addition_id                            ,
            ma.asset_number                                ,
            ma.tag_number                                  ,
            ma.description                                 ,
            ma.asset_category_id                           ,
            ma.manufacturer_name                           ,
            ma.serial_number                               ,
            ma.model_number                                ,
            ma.book_type_code                              ,
            ma.date_placed_in_service                      ,
            ma.fixed_assets_cost                           ,
            ma.payables_units                              ,
            ma.fixed_assets_units                          ,
            ma.payables_code_combination_id                ,
            ma.expense_code_combination_id                 ,
            ma.location_id                                 ,
            ma.assigned_to                                 ,
            ma.feeder_system_name                          ,
            ma.create_batch_date                           ,
            ma.create_batch_id                             ,
            ma.last_update_date                            ,
            ma.last_updated_by                             ,
            ma.reviewer_comments                           ,
            ma.invoice_number                              ,
            ma.vendor_number                               ,
            ma.po_vendor_id                                ,
            ma.po_number                                   ,
            ma.posting_status                              ,
            ma.queue_name                                  ,
            ma.invoice_date                                ,
            ma.invoice_created_by                          ,
            ma.invoice_updated_by                          ,
            ma.payables_cost                               ,
            ma.invoice_id                                  ,
            ma.payables_batch_name                         ,
            ma.depreciate_flag                             ,
            ma.parent_mass_addition_id                     ,
            ma.parent_asset_id                             ,
            ma.split_merged_code                           ,
            ma.ap_distribution_line_number                 ,
            ma.post_batch_id                               ,
            ma.add_to_asset_id                             ,
            ma.amortize_flag                               ,
            ma.new_master_flag                             ,
            ma.asset_key_ccid                              ,
            ma.asset_type                                  ,
            ma.deprn_reserve                               ,
            ma.ytd_deprn                                   ,
            ma.beginning_nbv                               ,
            ma.created_by                                  ,
            ma.creation_date                               ,
            ma.last_update_login                           ,
            ma.salvage_value                               ,
            ma.accounting_date                             ,
            ma.attribute_category_code                     ,
            ma.fully_rsvd_revals_counter                   ,
            ma.merge_invoice_number                        ,
            ma.merge_vendor_number                         ,
            ma.production_capacity                         ,
            ma.reval_amortization_basis                    ,
            ma.reval_reserve                               ,
            ma.unit_of_measure                             ,
            ma.unrevalued_cost                             ,
            ma.ytd_reval_deprn_expense                     ,
            ma.merged_code                                 ,
            ma.split_code                                  ,
            ma.merge_parent_mass_additions_id              ,
            ma.split_parent_mass_additions_id              ,
            ma.project_asset_line_id                       ,
            ma.project_id                                  ,
            ma.task_id                                     ,
            ma.sum_units                                   ,
            ma.dist_name                                   ,
            ma.context                                     ,
            ma.inventorial                                 ,
            ma.short_fiscal_year_flag                      ,
            ma.conversion_date                             ,
            ma.original_deprn_start_date                   ,
            ma.group_asset_id                              ,
            ma.cua_parent_hierarchy_id                     ,
            ma.units_to_adjust                             ,
            ma.bonus_ytd_deprn                             ,
            ma.bonus_deprn_reserve                         ,
            ma.amortize_nbv_flag                           ,
            ma.amortization_start_date                     ,
            ma.transaction_type_code                       ,
            ma.transaction_date                            ,
            ma.warranty_id                                 ,
            ma.lease_id                                    ,
            ma.lessor_id                                   ,
            ma.property_type_code                          ,
            ma.property_1245_1250_code                     ,
            ma.in_use_flag                                 ,
            ma.owned_leased                                ,
            ma.new_used                                    ,
            ma.asset_id                                    ,
            ma.material_indicator_flag                     ,
            ma.mass_property_flag                          ,
            ma.deprn_method_code                           , -- additional columns
            ma.life_in_months                              ,
            ma.basic_rate                                  ,
            ma.adjusted_rate                               ,
            ma.prorate_convention_code                     ,
            ma.bonus_rule                                  ,
            ma.salvage_type                                ,
            ma.percent_salvage_value                       ,
            ma.deprn_limit_type                            ,
            ma.allowed_deprn_limit_amount                  ,
            ma.allowed_deprn_limit                         ,
            ma.invoice_distribution_id                     ,
            ma.invoice_line_number                         ,
            ma.po_distribution_id                          , -- end additional columns
            ma.attribute1                                  ,
            ma.attribute2                                  ,
            ma.attribute3                                  ,
            ma.attribute4                                  ,
            ma.attribute5                                  ,
            ma.attribute6                                  ,
            ma.attribute7                                  ,
            ma.attribute8                                  ,
            ma.attribute9                                  ,
            ma.attribute10                                 ,
            ma.attribute11                                 ,
            ma.attribute12                                 ,
            ma.attribute13                                 ,
            ma.attribute14                                 ,
            ma.attribute15                                 ,
            ma.attribute16                                 ,
            ma.attribute17                                 ,
            ma.attribute18                                 ,
            ma.attribute19                                 ,
            ma.attribute20                                 ,
            ma.attribute21                                 ,
            ma.attribute22                                 ,
            ma.attribute23                                 ,
            ma.attribute24                                 ,
            ma.attribute25                                 ,
            ma.attribute26                                 ,
            ma.attribute27                                 ,
            ma.attribute28                                 ,
            ma.attribute29                                 ,
            ma.attribute30                                 ,
            ma.global_attribute1                           ,
            ma.global_attribute2                           ,
            ma.global_attribute3                           ,
            ma.global_attribute4                           ,
            ma.global_attribute5                           ,
            ma.global_attribute6                           ,
            ma.global_attribute7                           ,
            ma.global_attribute8                           ,
            ma.global_attribute9                           ,
            ma.global_attribute10                          ,
            ma.global_attribute11                          ,
            ma.global_attribute12                          ,
            ma.global_attribute13                          ,
            ma.global_attribute14                          ,
            ma.global_attribute15                          ,
            ma.global_attribute16                          ,
            ma.global_attribute17                          ,
            ma.global_attribute18                          ,
            ma.global_attribute19                          ,
            ma.global_attribute20                          ,
            ma.global_attribute_category                   ,
            ma.th_attribute1                               ,
            ma.th_attribute2                               ,
            ma.th_attribute3                               ,
            ma.th_attribute4                               ,
            ma.th_attribute5                               ,
            ma.th_attribute6                               ,
            ma.th_attribute7                               ,
            ma.th_attribute8                               ,
            ma.th_attribute9                               ,
            ma.th_attribute10                              ,
            ma.th_attribute11                              ,
            ma.th_attribute12                              ,
            ma.th_attribute13                              ,
            ma.th_attribute14                              ,
            ma.th_attribute15                              ,
            ma.th_attribute_category_code                  ,
            ma.nbv_at_switch,         -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy
            ma.prior_deprn_limit_type,
            ma.prior_deprn_limit_amount,
            ma.prior_deprn_limit,
            --ma.period_counter_fully_reserved,
            --ma.extended_depreciation_period,
            ma.period_full_reserve,
            ma.period_extd_deprn,
            ma.prior_deprn_method,
            ma.prior_life_in_months,
            ma.prior_basic_rate,
            ma.prior_adjusted_rate    -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy
       from fa_mass_additions    ma
      where ma.posting_status    = 'POST'
        and ma.book_type_code    = p_book_type_code
        and ma.request_id        = p_parent_request_id
        and ma.worker_id         = p_request_number
        and ma.process_order     = p_process_order
      order by ma.mass_addition_id;

   CURSOR c_mass_rates (p_massadd_id NUMBER) IS
     SELECT set_of_books_id,
            exchange_rate,
            fixed_assets_cost
       from fa_mc_mass_rates
      where mass_addition_id = p_massadd_id;

   CURSOR c_merged_children (P_massadd_id NUMBER) IS
     SELECT child.po_vendor_id,
            child.mass_addition_id,
            child.fixed_assets_cost,
            child.po_number,
            child.invoice_number,
            child.payables_batch_name,
            child.payables_code_combination_id,
            child.feeder_system_name,
            child.create_batch_date,
            child.create_batch_id,
            child.invoice_date,
            child.payables_cost,
            child.invoice_id,
            child.ap_distribution_line_number,
            child.payables_units,
            'MC',
            child.split_code,
            'MC',
            child.description,
            child.split_parent_mass_additions_id,
            child.merge_parent_mass_additions_id,
            child.project_id,
            child.task_id,
            child.project_asset_line_id,
            child.ytd_deprn,
            child.deprn_reserve,
            child.bonus_ytd_deprn,
            child.bonus_deprn_reserve,
            child.reval_amortization_basis,
            child.ytd_reval_deprn_expense,
            child.reval_reserve,
            child.material_indicator_flag,
            child.invoice_distribution_id,
            child.invoice_line_number,
            child.po_distribution_id
       FROM fa_mass_additions child
      WHERE child.merge_parent_mass_additions_id = p_massadd_id;

   CURSOR c_distributions (p_massadd_id NUMBER) IS
     select dist.employee_id,
            dist.deprn_expense_ccid,
            dist.location_id,
            sum(dist.units)
       from (select mad.units,
                    mad.employee_id,
                    mad.deprn_expense_ccid,
                    mad.location_id
               from fa_massadd_distributions mad
              where mad.mass_addition_id = p_massadd_id
              union all
             select mad.units,
                    mad.employee_id,
                    mad.deprn_expense_ccid,
                    mad.location_id
               from fa_massadd_distributions mad,
                    fa_mass_additions mac,
                    fa_mass_additions map
              where map.sum_units = 'YES'
                and map.mass_addition_id = p_massadd_id
                and map.mass_addition_id = mac.merge_parent_mass_additions_id
                and mad.mass_addition_id = mac.mass_addition_id) dist
   group by dist.employee_id,
            dist.deprn_expense_ccid,
            dist.location_id;

   CURSOR c_dist_history (p_add_to_asset_id number) is
     select dh.distribution_id,
            dh.units_assigned,
       dh.code_combination_id,
       dh.location_id,
       dh.assigned_to
       from fa_distribution_history dh
      where dh.asset_id       = p_add_to_asset_id
        and dh.book_type_code = p_book_type_code
        and dh.date_ineffective IS NULL
        and dh.retirement_id IS NULL;

   -- start dist
   CURSOR c_dh (p_add_to_asset_id number, p_ccid number, p_locid number,p_empid number) is
     select dh.distribution_id,
            dh.units_assigned,
            dh.code_combination_id,
            dh.location_id,
            dh.assigned_to
       from fa_distribution_history dh
      where dh.asset_id               = p_add_to_asset_id
        and dh.book_type_code         = p_book_type_code
        and dh.code_combination_id    = p_ccid
        and dh.location_id            = p_locid
        and nvl(dh.assigned_to,-99)   = nvl(p_empid,-99)
        and dh.date_ineffective      IS NULL
        and dh.retirement_id         IS NULL;

    --Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
    l_mass_add_id           varchar2(100);
    l_exception_err         varchar2(100);
    l_count                 number := 0;
    --Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

    l_japan_tax_reform      varchar2(1) := fnd_profile.value('FA_JAPAN_TAX_REFORMS');

BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

   -- call the book_controls cache
   if NOT fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- values that remain constant for all lines
   l_asset_hdr_rec.book_type_code     := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id    := fa_cache_pkg.fazcbc_record.set_of_books_id;
   l_inv_trans_rec.transaction_type   := 'MASS ADDITION';
   l_trans_rec.calling_interface      := 'FAMAPT';
   l_dist_trans_rec.calling_interface := 'FAMAPT';
   l_trans_rec.mass_reference_id      := p_parent_request_id;

   if (g_times_called = 1) then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'p_book', p_book_type_code,
                          p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_mode', p_mode,
                          p_log_level_rec => g_log_level_rec);
      end if;

   end if;

   open c_mass_additions
             (p_book_type_code             => p_book_type_code,
              p_parent_request_id          => p_parent_request_id,
              p_request_number             => p_request_number,
              p_process_order              => p_loop_count);

   fetch c_mass_additions bulk collect
       into l_mass_addition_id_tbl                             ,
            l_asset_number_tbl                                 ,
            l_tag_number_tbl                                   ,
            l_description_tbl                                  ,
            l_asset_category_id_tbl                            ,
            l_manufacturer_name_tbl                            ,
            l_serial_number_tbl                                ,
            l_model_number_tbl                                 ,
            l_book_type_code_tbl                               ,
            l_date_placed_in_service_tbl                       ,
            l_fixed_assets_cost_tbl                            ,
            l_payables_units_tbl                               ,
            l_fixed_assets_units_tbl                           ,
            l_payables_ccid_tbl                                ,
            l_expense_ccid_tbl                                 ,
            l_location_id_tbl                                  ,
            l_assigned_to_tbl                                  ,
            l_feeder_system_name_tbl                           ,
            l_create_batch_date_tbl                            ,
            l_create_batch_id_tbl                              ,
            l_last_update_date_tbl                             ,
            l_last_updated_by_tbl                              ,
            l_reviewer_comments_tbl                            ,
            l_invoice_number_tbl                               ,
            l_vendor_number_tbl                                ,
            l_po_vendor_id_tbl                                 ,
            l_po_number_tbl                                    ,
            l_posting_status_tbl                               ,
            l_queue_name_tbl                                   ,
            l_invoice_date_tbl                                 ,
            l_invoice_created_by_tbl                           ,
            l_invoice_updated_by_tbl                           ,
            l_payables_cost_tbl                                ,
            l_invoice_id_tbl                                   ,
            l_payables_batch_name_tbl                          ,
            l_depreciate_flag_tbl                              ,
            l_parent_mass_addition_id_tbl                      ,
            l_parent_asset_id_tbl                              ,
            l_split_merged_code_tbl                            ,
            l_ap_dist_line_num_tbl                             ,
            l_post_batch_id_tbl                                ,
            l_add_to_asset_id_tbl                              ,
            l_amortize_flag_tbl                                ,
            l_new_master_flag_tbl                              ,
            l_asset_key_ccid_tbl                               ,
            l_asset_type_tbl                                   ,
            l_deprn_reserve_tbl                                ,
            l_ytd_deprn_tbl                                    ,
            l_beginning_nbv_tbl                                ,
            l_created_by_tbl                                   ,
            l_creation_date_tbl                                ,
            l_last_update_login_tbl                            ,
            l_salvage_value_tbl                                ,
            l_accounting_date_tbl                              ,
            l_attribute_category_code_tbl                      ,
            l_fully_rsvd_revals_ctr_tbl                        ,
            l_merge_invoice_number_tbl                         ,
            l_merge_vendor_number_tbl                          ,
            l_production_capacity_tbl                          ,
            l_reval_amortization_basis_tbl                     ,
            l_reval_reserve_tbl                                ,
            l_unit_of_measure_tbl                              ,
            l_unrevalued_cost_tbl                              ,
            l_ytd_reval_deprn_expense_tbl                      ,
            l_merged_code_tbl                                  ,
            l_split_code_tbl                                   ,
            l_merge_parent_massadd_id_tbl                      ,
            l_split_parent_massadd_id_tbl                      ,
            l_project_asset_line_id_tbl                        ,
            l_project_id_tbl                                   ,
            l_task_id_tbl                                      ,
            l_sum_units_tbl                                    ,
            l_dist_name_tbl                                    ,
            l_context_tbl                                      ,
            l_inventorial_tbl                                  ,
            l_short_fiscal_year_flag_tbl                       ,
            l_conversion_date_tbl                              ,
            l_orig_deprn_start_date_tbl                        ,
            l_group_asset_id_tbl                               ,
            l_cua_parent_hierarchy_id_tbl                      ,
            l_units_to_adjust_tbl                              ,
            l_bonus_ytd_deprn_tbl                              ,
            l_bonus_deprn_reserve_tbl                          ,
            l_amortize_nbv_flag_tbl                            ,
            l_amortization_start_date_tbl                      ,
            l_transaction_type_code_tbl                        ,
            l_transaction_date_tbl                             ,
            l_warranty_id_tbl                                  ,
            l_lease_id_tbl                                     ,
            l_lessor_id_tbl                                    ,
            l_property_type_code_tbl                           ,
            l_property_1245_1250_code_tbl                      ,
            l_in_use_flag_tbl                                  ,
            l_owned_leased_tbl                                 ,
            l_new_used_tbl                                     ,
            l_asset_id_tbl                                     ,
            l_material_indicator_flag_tbl                      ,
            l_mass_property_flag_tbl                           ,
            l_deprn_method_code_tbl                            , -- start new fields
            l_life_in_months_tbl                               ,
            l_basic_rate_tbl                                   ,
            l_adjusted_rate_tbl                                ,
            l_prorate_convention_code_tbl                      ,
            l_bonus_rule_tbl                                   ,
            l_salvage_type_tbl                                 ,
            l_percent_salvage_value_tbl                        ,
            l_deprn_limit_type_tbl                             ,
            l_allowed_deprn_limit_amt_tbl                      ,
            l_allowed_deprn_limit_tbl                          ,
            l_invoice_distribution_id_tbl                      ,
            l_invoice_line_number_tbl                          ,
            l_po_distribution_id_tbl                           , -- end new fields
            l_attribute1_tbl                                   ,
            l_attribute2_tbl                                   ,
            l_attribute3_tbl                                   ,
            l_attribute4_tbl                                   ,
            l_attribute5_tbl                                   ,
            l_attribute6_tbl                                   ,
            l_attribute7_tbl                                   ,
            l_attribute8_tbl                                   ,
            l_attribute9_tbl                                   ,
            l_attribute10_tbl                                  ,
            l_attribute11_tbl                                  ,
            l_attribute12_tbl                                  ,
            l_attribute13_tbl                                  ,
            l_attribute14_tbl                                  ,
            l_attribute15_tbl                                  ,
            l_attribute16_tbl                                  ,
            l_attribute17_tbl                                  ,
            l_attribute18_tbl                                  ,
            l_attribute19_tbl                                  ,
            l_attribute20_tbl                                  ,
            l_attribute21_tbl                                  ,
            l_attribute22_tbl                                  ,
            l_attribute23_tbl                                  ,
            l_attribute24_tbl                                  ,
            l_attribute25_tbl                                  ,
            l_attribute26_tbl                                  ,
            l_attribute27_tbl                                  ,
            l_attribute28_tbl                                  ,
            l_attribute29_tbl                                  ,
            l_attribute30_tbl                                  ,
            l_global_attribute1_tbl                            ,
            l_global_attribute2_tbl                            ,
            l_global_attribute3_tbl                            ,
            l_global_attribute4_tbl                            ,
            l_global_attribute5_tbl                            ,
            l_global_attribute6_tbl                            ,
            l_global_attribute7_tbl                            ,
            l_global_attribute8_tbl                            ,
            l_global_attribute9_tbl                            ,
            l_global_attribute10_tbl                           ,
            l_global_attribute11_tbl                           ,
            l_global_attribute12_tbl                           ,
            l_global_attribute13_tbl                           ,
            l_global_attribute14_tbl                           ,
            l_global_attribute15_tbl                           ,
            l_global_attribute16_tbl                           ,
            l_global_attribute17_tbl                           ,
            l_global_attribute18_tbl                           ,
            l_global_attribute19_tbl                           ,
            l_global_attribute20_tbl                           ,
            l_global_attribute_cat_tbl                         ,
            l_th_attribute1_tbl                                ,
            l_th_attribute2_tbl                                ,
            l_th_attribute3_tbl                                ,
            l_th_attribute4_tbl                                ,
            l_th_attribute5_tbl                                ,
            l_th_attribute6_tbl                                ,
            l_th_attribute7_tbl                                ,
            l_th_attribute8_tbl                                ,
            l_th_attribute9_tbl                                ,
            l_th_attribute10_tbl                               ,
            l_th_attribute11_tbl                               ,
            l_th_attribute12_tbl                               ,
            l_th_attribute13_tbl                               ,
            l_th_attribute14_tbl                               ,
            l_th_attribute15_tbl                               ,
            l_th_attribute_cat_code_tbl,
            l_nbv_at_switch_tbl,            -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy
            l_prior_deprn_limit_type_tbl,
            l_prior_deprn_limit_amt_tbl,
            l_prior_deprn_limit_tbl,
            l_period_full_reserve_tbl,
            l_period_extd_deprn_tbl,
            l_prior_deprn_method_tbl,
            l_prior_life_in_months_tbl,
            l_prior_basic_rate_tbl,
            l_prior_adjusted_rate_tbl       -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy
            limit l_batch_size;
   close c_mass_additions;

   if l_mass_addition_id_tbl.count = 0 then
      raise done_exc;
   end if;

   for i in 1..l_mass_addition_id_tbl.count loop

      savepoint famapt;

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      BEGIN  -- start asset level block

         l_inv_indicator        := 1;
         l_units_adjusted       := 0;


         -- purge the records and tables from prior run

         l_trans_rec.transaction_header_id      := null;
         l_trans_rec.transaction_date_entered   := null;
         l_trans_rec.transaction_subtype        := null;
         l_trans_rec.transaction_name           := null;
         l_trans_rec.amortization_start_date    := null;
         l_trans_rec.desc_flex                  := null;

         l_dist_trans_rec.desc_flex             := null;

         l_inv_trans_rec.invoice_transaction_id := null;
         l_asset_hdr_rec.asset_id               := NULL;

         l_asset_desc_rec           := NULL;
         l_asset_cat_rec            := NULL;
         l_asset_type_rec           := NULL;
         l_asset_hierarchy_rec      := NULL;
         l_asset_fin_rec_adj        := NULL;
         l_asset_fin_rec_new        := NULL;
         l_inv_rec                  := NULL;
         l_inv_rate_rec             := NULL;
         l_asset_deprn_rec_adj      := NULL;
         l_asset_deprn_rec_new      := NULL;
         l_asset_dist_rec           := NULL;


         l_asset_fin_mrc_tbl_new.delete;
         l_inv_tbl.delete;
         l_asset_deprn_mrc_tbl_new.delete;
         l_asset_dist_tbl.delete;
         l_c_mass_addition_id_tbl.delete;
         l_c_description_tbl.delete;
         l_c_payables_units_tbl.delete;
         l_c_fixed_assets_cost_tbl.delete;
         l_c_payables_ccid_tbl.delete;
         l_c_feeder_system_name_tbl.delete;
         l_c_create_batch_date_tbl.delete;
         l_c_create_batch_id_tbl.delete;
         l_c_invoice_number_tbl.delete;
         l_c_po_vendor_id_tbl.delete;
         l_c_po_number_tbl.delete;
         l_c_invoice_date_tbl.delete;
         l_c_payables_cost_tbl.delete;
         l_c_invoice_id_tbl.delete;
         l_c_payables_batch_name_tbl.delete;
         l_c_split_merged_code_tbl.delete;
         l_c_ap_dist_line_num_tbl.delete;
         l_c_deprn_reserve_tbl.delete;
         l_c_ytd_deprn_tbl.delete;
         l_c_reval_amort_basis_tbl.delete;
         l_c_reval_reserve_tbl.delete;
         l_c_unrevalued_cost_tbl.delete;
         l_c_ytd_reval_deprn_exp_tbl.delete;
         l_c_merged_code_tbl.delete;
         l_c_split_code_tbl.delete;
         l_c_merge_parent_massadd_tbl.delete;
         l_c_split_parent_massadd_tbl.delete;
         l_c_project_asset_line_id_tbl.delete;
         l_c_project_id_tbl.delete;
         l_c_task_id_tbl.delete;
         l_c_bonus_ytd_deprn_tbl.delete;
         l_c_bonus_deprn_reserve_tbl.delete;
         l_c_invoice_dist_id_tbl.delete;
         l_c_invoice_line_number_tbl.delete;
         l_c_po_distribution_id_tbl.delete;

         l_set_of_books_id_tbl.delete;
         l_exchange_rate_tbl.delete;
         l_mc_fixed_assets_cost_tbl.delete;

         l_mad_units_tbl.delete;
         l_mad_employee_id_tbl.delete;
         l_mad_deprn_expense_ccid_tbl.delete;
         l_mad_location_id_tbl.delete;

         l_dh_distribution_id_tbl.delete;
         l_dh_units_assigned_tbl.delete;

         -- Fix for Bug #6336083.  Populate trans flexfield
         l_trans_desc_flex_rec.attribute1  := l_th_attribute1_tbl(i);
         l_trans_desc_flex_rec.attribute2  := l_th_attribute2_tbl(i);
         l_trans_desc_flex_rec.attribute3  := l_th_attribute3_tbl(i);
         l_trans_desc_flex_rec.attribute4  := l_th_attribute4_tbl(i);
         l_trans_desc_flex_rec.attribute5  := l_th_attribute5_tbl(i);
         l_trans_desc_flex_rec.attribute6  := l_th_attribute6_tbl(i);
         l_trans_desc_flex_rec.attribute7  := l_th_attribute7_tbl(i);
         l_trans_desc_flex_rec.attribute8  := l_th_attribute8_tbl(i);
         l_trans_desc_flex_rec.attribute9  := l_th_attribute9_tbl(i);
         l_trans_desc_flex_rec.attribute10 := l_th_attribute10_tbl(i);
         l_trans_desc_flex_rec.attribute11 := l_th_attribute11_tbl(i);
         l_trans_desc_flex_rec.attribute12 := l_th_attribute12_tbl(i);
         l_trans_desc_flex_rec.attribute13 := l_th_attribute13_tbl(i);
         l_trans_desc_flex_rec.attribute14 := l_th_attribute14_tbl(i);
         l_trans_desc_flex_rec.attribute15 := l_th_attribute15_tbl(i);
         l_trans_desc_flex_rec.attribute_category_code :=
            l_th_attribute_cat_code_tbl(i);
         l_trans_rec.desc_flex             := l_trans_desc_flex_rec;
         l_dist_trans_rec.desc_flex        := l_trans_desc_flex_rec;

         -- determine transaction type and load the trans struct
         if (l_transaction_type_code_tbl(i) = 'FUTURE CAP' or
            l_transaction_type_code_tbl(i) = 'FUTURE REV') then

            l_asset_hdr_rec.asset_id                   := l_add_to_asset_id_tbl(i);
            l_asset_fin_rec_adj.date_placed_in_service := l_transaction_date_tbl(i);
            l_trans_rec.transaction_date_entered       := l_transaction_date_tbl(i);


            if (l_transaction_type_code_tbl(i) = 'FUTURE CAP') then
               FA_CIP_PUB.do_capitalization
                  (p_api_version             => 1.0,
                   p_init_msg_list           => FND_API.G_FALSE,
                   p_commit                  => FND_API.G_FALSE,
                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status           => l_return_status,
                   x_msg_count               => l_msg_count,
                   x_msg_data                => l_msg_data,
                   p_calling_fn              => l_calling_fn,
                   px_trans_rec              => l_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   px_asset_fin_rec          => l_asset_fin_rec_adj
               );
            else
               FA_CIP_PUB.do_reverse
                  (p_api_version             => 1.0,
                   p_init_msg_list           => FND_API.G_FALSE,
                   p_commit                  => FND_API.G_FALSE,
                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status           => l_return_status,
                   x_msg_count               => l_msg_count,
                   x_msg_data                => l_msg_data,
                   p_calling_fn              => l_calling_fn,
                   px_trans_rec              => l_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   px_asset_fin_rec          => l_asset_fin_rec_adj
               );
            end if;


            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
               raise error_found_trx;
            end if;

         else -- add or adj

            if (l_amortize_flag_tbl(i) = 'YES' or
                l_amortize_nbv_flag_tbl(i) = 'Y') then  -- BUG# 2410525
               l_trans_rec.transaction_subtype     := 'AMORTIZED';
               l_trans_rec.amortization_start_date := l_amortization_start_date_tbl(i);
            end if;


            -- load the invoice record
            l_inv_rec.po_vendor_id                   := l_po_vendor_id_tbl(i);
            l_inv_rec.asset_invoice_id               := l_mass_addition_id_tbl(i);
            l_inv_rec.fixed_assets_cost              := l_fixed_assets_cost_tbl(i);
            l_inv_rec.deleted_flag                   := 'NO';
            l_inv_rec.po_number                      := l_po_number_tbl(i);
            l_inv_rec.invoice_number                 := l_invoice_number_tbl(i);
            l_inv_rec.payables_batch_name            := l_payables_batch_name_tbl(i);
            l_inv_rec.payables_code_combination_id   := l_payables_ccid_tbl(i);
            l_inv_rec.feeder_system_name             := l_feeder_system_name_tbl(i);
            l_inv_rec.create_batch_date              := l_create_batch_date_tbl(i);
            l_inv_rec.create_batch_id                := l_create_batch_id_tbl(i);
            l_inv_rec.invoice_date                   := l_invoice_date_tbl(i);
            l_inv_rec.payables_cost                  := l_payables_cost_tbl(i);
            l_inv_rec.post_batch_id                  := p_parent_request_id;
            l_inv_rec.invoice_id                     := l_invoice_id_tbl(i);
            l_inv_rec.ap_distribution_line_number    := l_ap_dist_line_num_tbl(i);
            l_inv_rec.payables_units                 := l_payables_units_tbl(i);
            l_inv_rec.split_merged_code              := l_split_merged_code_tbl(i);
            l_inv_rec.description                    := l_description_tbl(i);
            l_inv_rec.parent_mass_addition_id        := l_parent_mass_addition_id_tbl(i);
            l_inv_rec.unrevalued_cost                := l_unrevalued_cost_tbl(i);
            l_inv_rec.merged_code                    := l_merged_code_tbl(i);
            l_inv_rec.split_code                     := l_split_code_tbl(i);
            l_inv_rec.merge_parent_mass_additions_id := l_merge_parent_massadd_id_tbl(i);
            l_inv_rec.split_parent_mass_additions_id := l_split_parent_massadd_id_tbl(i);
            l_inv_rec.project_asset_line_id          := l_project_asset_line_id_tbl(i);
            l_inv_rec.project_id                     := l_project_id_tbl(i);
            l_inv_rec.task_id                        := l_task_id_tbl(i);
            l_inv_rec.ytd_deprn                      := l_ytd_deprn_tbl(i);
            l_inv_rec.deprn_reserve                  := l_deprn_reserve_tbl(i);
            l_inv_rec.bonus_ytd_deprn                := l_bonus_ytd_deprn_tbl(i);
            l_inv_rec.bonus_deprn_reserve            := l_bonus_deprn_reserve_tbl(i);
            l_inv_rec.reval_amortization_basis       := l_reval_amortization_basis_tbl(i);
            l_inv_rec.reval_ytd_deprn                := l_ytd_reval_deprn_expense_tbl(i);
            l_inv_rec.reval_deprn_reserve            := l_reval_reserve_tbl(i);
            l_inv_rec.material_indicator_flag        := l_material_indicator_flag_tbl(i);
            l_inv_rec.invoice_distribution_id        := l_invoice_distribution_id_tbl(i);
            l_inv_rec.invoice_line_number            := l_invoice_line_number_tbl(i);
            l_inv_rec.po_distribution_id             := l_po_distribution_id_tbl(i);


            -- place the main invoice in the array
            l_inv_tbl(l_inv_indicator) := l_inv_rec;

            -- load the rates for the main/parent invoice
            if (nvl(fa_cache_pkg.fazcbc_record.mc_source_flag, 'N') = 'Y') then
               open c_mass_rates (p_massadd_id => l_mass_addition_id_tbl(i));
               fetch c_mass_rates bulk collect
                into l_set_of_books_id_tbl,
                     l_exchange_rate_tbl,
                     l_mc_fixed_assets_cost_tbl;
               close c_mass_rates;

               for l_inv_rate in 1..l_set_of_books_id_tbl.count loop
                  l_inv_rate_rec.set_of_books_id := l_set_of_books_id_tbl(l_inv_rate);
                  l_inv_rate_rec.exchange_rate   := l_exchange_rate_tbl(l_inv_rate);
                  l_inv_rate_rec.cost            := l_mc_fixed_assets_cost_tbl(l_inv_rate);

                  -- R12: nesting the array
                  -- l_inv_rate_tbl(l_inv_rate)     := l_inv_rate_rec;
                  l_inv_tbl(l_inv_indicator).inv_rate_tbl(l_inv_rate) :=
                     l_inv_rate_rec;

               end loop;
            end if;

            l_inv_rec  := null;
            l_inv_rate_rec := null;

            -- load any merged children into the invoice array for add and adj
            if (nvl(l_merged_code_tbl(i), 'NULL') = 'MP') then
               open c_merged_children(p_massadd_id => l_mass_addition_id_tbl(i));
               l_inv_indicator := l_inv_indicator + 1;
               fetch c_merged_children bulk collect
               into l_c_po_vendor_id_tbl,
                    l_c_mass_addition_id_tbl,
                    l_c_fixed_assets_cost_tbl,
                    l_c_po_number_tbl,
                    l_c_invoice_number_tbl,
                    l_c_payables_batch_name_tbl,
                    l_c_payables_ccid_tbl,
                    l_c_feeder_system_name_tbl,
                    l_c_create_batch_date_tbl,
                    l_c_create_batch_id_tbl,
                    l_c_invoice_date_tbl,
                    l_c_payables_cost_tbl,
                    l_c_invoice_id_tbl,
                    l_c_ap_dist_line_num_tbl,
                    l_c_payables_units_tbl,
                    l_c_split_merged_code_tbl,
                    l_c_split_code_tbl,
                    l_c_merged_code_tbl,
                    l_c_description_tbl,
                    l_c_split_parent_massadd_tbl,
                    l_c_merge_parent_massadd_tbl,
                    l_c_project_id_tbl,
                    l_c_task_id_tbl,
                    l_c_project_asset_line_id_tbl,
                    l_c_ytd_deprn_tbl,
                    l_c_deprn_reserve_tbl,
                    l_c_bonus_ytd_deprn_tbl,
                    l_c_bonus_deprn_reserve_tbl,
                    l_c_reval_amort_basis_tbl,
                    l_c_ytd_reval_deprn_exp_tbl,
                    l_c_reval_reserve_tbl,
                    l_c_material_indicator_flag,
                    l_c_invoice_dist_id_tbl,
                    l_c_invoice_line_number_tbl,
                    l_c_po_distribution_id_tbl;
               close c_merged_children;

               for l_inv_indicator in 1..l_c_mass_addition_id_tbl.count loop
                  l_inv_rec.po_vendor_id                    := l_c_po_vendor_id_tbl(l_inv_indicator);
                  l_inv_rec.asset_invoice_id                := l_c_mass_addition_id_tbl(l_inv_indicator);
                  l_inv_rec.fixed_assets_cost               := l_c_fixed_assets_cost_tbl(l_inv_indicator);
                  l_inv_rec.deleted_flag                    := 'NO';
                  l_inv_rec.po_number                       := l_c_po_number_tbl(l_inv_indicator);
                  l_inv_rec.invoice_number                  := l_c_invoice_number_tbl(l_inv_indicator);
                  l_inv_rec.payables_batch_name             := l_c_payables_batch_name_tbl(l_inv_indicator);
                  l_inv_rec.payables_code_combination_id    := l_c_payables_ccid_tbl(l_inv_indicator);
                  l_inv_rec.feeder_system_name              := l_c_feeder_system_name_tbl(l_inv_indicator);
                  l_inv_rec.create_batch_date               := l_c_create_batch_date_tbl(l_inv_indicator);
                  l_inv_rec.create_batch_id                 := l_c_create_batch_id_tbl(l_inv_indicator);
                  l_inv_rec.invoice_date                    := l_c_invoice_date_tbl(l_inv_indicator);
                  l_inv_rec.payables_cost                   := l_c_payables_cost_tbl(l_inv_indicator);
                  l_inv_rec.post_batch_id                   := p_parent_request_id;
                  l_inv_rec.invoice_id                      := l_c_invoice_id_tbl(l_inv_indicator);
                  l_inv_rec.ap_distribution_line_number     := l_c_ap_dist_line_num_tbl(l_inv_indicator);
                  l_inv_rec.payables_units                  := l_c_payables_units_tbl(l_inv_indicator);
                  l_inv_rec.split_merged_code               := 'MC';
                  l_inv_rec.split_code                      := l_c_split_code_tbl(l_inv_indicator);
                  l_inv_rec.merged_code                     := 'MC';
                  l_inv_rec.description                     := l_c_description_tbl(l_inv_indicator);
                  l_inv_rec.parent_mass_addition_id         := l_mass_addition_id_tbl(i);
                  l_inv_rec.split_parent_mass_additions_id  := l_c_split_parent_massadd_tbl(l_inv_indicator);
                  l_inv_rec.merge_parent_mass_additions_id  := l_c_merge_parent_massadd_tbl(l_inv_indicator);
                  l_inv_rec.project_id                      := l_c_project_id_tbl(l_inv_indicator);
                  l_inv_rec.task_id                         := l_c_task_id_tbl(l_inv_indicator);
                  l_inv_rec.project_asset_line_id           := l_c_project_asset_line_id_tbl(l_inv_indicator);
                  l_inv_rec.ytd_deprn                       := l_c_ytd_deprn_tbl(l_inv_indicator);
                  l_inv_rec.deprn_reserve                   := l_c_deprn_reserve_tbl(l_inv_indicator);
                  l_inv_rec.bonus_ytd_deprn                 := l_c_bonus_ytd_deprn_tbl(l_inv_indicator);
                  l_inv_rec.bonus_deprn_reserve             := l_c_bonus_deprn_reserve_tbl(l_inv_indicator);
                  l_inv_rec.reval_amortization_basis        := l_c_reval_amort_basis_tbl(l_inv_indicator);
                  l_inv_rec.reval_ytd_deprn                 := l_c_ytd_reval_deprn_exp_tbl(l_inv_indicator);
                  l_inv_rec.reval_deprn_reserve             := l_c_reval_reserve_tbl(l_inv_indicator);
                  l_inv_rec.material_indicator_flag         := l_c_material_indicator_flag(l_inv_indicator);
                  l_inv_rec.invoice_distribution_id         := l_c_invoice_dist_id_tbl(l_inv_indicator);
                  l_inv_rec.invoice_line_number             := l_c_invoice_line_number_tbl(l_inv_indicator);
                  l_inv_rec.po_distribution_id              := l_c_po_distribution_id_tbl(l_inv_indicator);
                  l_inv_rec.inv_indicator                   := l_inv_indicator + 1;

                  -- removing crl logic here

                  -- append to the existing row(s) in the table of invoices (always + 1)
                  l_inv_tbl(l_inv_indicator + 1)            := l_inv_rec;

                  -- process mrc rates for the children
                  if (fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y') then
                     open c_mass_rates(p_massadd_id => l_inv_rec.asset_invoice_id);
                     fetch c_mass_rates bulk collect
                      into l_set_of_books_id_tbl ,
                           l_exchange_rate_tbl,
                           l_mc_fixed_assets_cost_tbl;
                     close c_mass_rates;

                     for l_rate in 1..l_set_of_books_id_tbl.count loop
                        l_inv_rate_rec.set_of_books_id := l_set_of_books_id_tbl(l_rate);
                        l_inv_rate_rec.exchange_rate   := l_exchange_rate_tbl(l_rate);
                        l_inv_rate_rec.cost            := l_mc_fixed_assets_cost_tbl(l_rate);

                        -- get the current number of rows in rate table and append
                        -- since there may be more than 1 reporting book, we need to get new count
                        -- R12: nesting the array

                        l_inv_tbl(l_inv_indicator + 1).inv_rate_tbl(l_rate) :=
                           l_inv_rate_rec;

                     end loop;

                  end if;
               end loop;  -- merged children loop
            end if;

            -- adding specific processing

            if (l_add_to_asset_id_tbl(i) is null) then

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,
                     'Regular addition',
                     l_asset_id_tbl(i),
                     p_log_level_rec => g_log_level_rec);
               end if;

               -- used for future add
               l_asset_hdr_rec.asset_id := l_asset_id_tbl(i);

               -- load the descriptive struct
               l_asset_desc_rec.asset_number            := l_asset_number_tbl(i);
               l_asset_desc_rec.description             := l_description_tbl(i);
               l_asset_desc_rec.tag_number              := l_tag_number_tbl(i);
               l_asset_desc_rec.serial_number           := l_serial_number_tbl(i);
               l_asset_desc_rec.asset_key_ccid          := l_asset_key_ccid_tbl(i);
               l_asset_desc_rec.parent_asset_id         := l_parent_asset_id_tbl(i);
               l_asset_desc_rec.manufacturer_name       := l_manufacturer_name_tbl(i);
               l_asset_desc_rec.model_number            := l_model_number_tbl(i);
               l_asset_desc_rec.warranty_id             := l_warranty_id_tbl(i);
               l_asset_desc_rec.lease_id                := l_lease_id_tbl(i);
               l_asset_desc_rec.in_use_flag             := l_in_use_flag_tbl(i);
               l_asset_desc_rec.inventorial             := l_inventorial_tbl(i);
               l_asset_desc_rec.property_type_code      := l_property_type_code_tbl(i);
               l_asset_desc_rec.property_1245_1250_code := l_property_1245_1250_code_tbl(i);
               l_asset_desc_rec.owned_leased            := l_owned_leased_tbl(i);
               l_asset_desc_rec.new_used                := l_new_used_tbl(i);
               l_asset_desc_rec.current_units           := l_fixed_assets_units_tbl(i);

               -- load the category and asset_type structs
               l_asset_type_rec.asset_type           := l_asset_type_tbl(i);
               l_asset_cat_rec.category_id           := l_asset_category_id_tbl(i);
               l_asset_cat_rec.desc_flex.attribute1  := l_attribute1_tbl(i);
               l_asset_cat_rec.desc_flex.attribute2  := l_attribute2_tbl(i);
               l_asset_cat_rec.desc_flex.attribute3  := l_attribute3_tbl(i);
               l_asset_cat_rec.desc_flex.attribute4  := l_attribute4_tbl(i);
               l_asset_cat_rec.desc_flex.attribute5  := l_attribute5_tbl(i);
               l_asset_cat_rec.desc_flex.attribute6  := l_attribute6_tbl(i);
               l_asset_cat_rec.desc_flex.attribute7  := l_attribute7_tbl(i);
               l_asset_cat_rec.desc_flex.attribute8  := l_attribute8_tbl(i);
               l_asset_cat_rec.desc_flex.attribute9  := l_attribute9_tbl(i);
               l_asset_cat_rec.desc_flex.attribute10 := l_attribute10_tbl(i);
               l_asset_cat_rec.desc_flex.attribute11 := l_attribute11_tbl(i);
               l_asset_cat_rec.desc_flex.attribute12 := l_attribute12_tbl(i);
               l_asset_cat_rec.desc_flex.attribute13 := l_attribute13_tbl(i);
               l_asset_cat_rec.desc_flex.attribute14 := l_attribute14_tbl(i);
               l_asset_cat_rec.desc_flex.context     := l_context_tbl(i);  -- Bug#2619312 Added ..

               -- load the global flexfield
               l_asset_desc_rec.global_desc_flex.attribute1  := l_global_attribute1_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute2  := l_global_attribute2_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute3  := l_global_attribute3_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute4  := l_global_attribute4_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute5  := l_global_attribute5_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute6  := l_global_attribute6_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute7  := l_global_attribute7_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute8  := l_global_attribute8_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute9  := l_global_attribute9_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute10 := l_global_attribute10_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute11 := l_global_attribute11_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute12 := l_global_attribute12_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute13 := l_global_attribute13_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute14 := l_global_attribute14_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute15 := l_global_attribute15_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute16 := l_global_attribute16_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute17 := l_global_attribute17_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute18 := l_global_attribute18_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute19 := l_global_attribute19_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute20 := l_global_attribute20_tbl(i);
               l_asset_desc_rec.global_desc_flex.attribute_category_code := l_global_attribute_cat_tbl(i);
               -- removing CRL logic
               l_asset_cat_rec.desc_flex.attribute15 := l_attribute15_tbl(i);
               l_asset_cat_rec.desc_flex.attribute16 := l_attribute16_tbl(i);
               l_asset_cat_rec.desc_flex.attribute17 := l_attribute17_tbl(i);
               l_asset_cat_rec.desc_flex.attribute18 := l_attribute18_tbl(i);
               l_asset_cat_rec.desc_flex.attribute19 := l_attribute19_tbl(i);
               l_asset_cat_rec.desc_flex.attribute20 := l_attribute20_tbl(i);
               l_asset_cat_rec.desc_flex.attribute21 := l_attribute21_tbl(i);
               l_asset_cat_rec.desc_flex.attribute22 := l_attribute22_tbl(i);
               l_asset_cat_rec.desc_flex.attribute23 := l_attribute23_tbl(i);
               l_asset_cat_rec.desc_flex.attribute24 := l_attribute24_tbl(i);
               l_asset_cat_rec.desc_flex.attribute25 := l_attribute25_tbl(i);
               l_asset_cat_rec.desc_flex.attribute26 := l_attribute26_tbl(i);
               l_asset_cat_rec.desc_flex.attribute27 := l_attribute27_tbl(i);
               l_asset_cat_rec.desc_flex.attribute28 := l_attribute28_tbl(i);
               l_asset_cat_rec.desc_flex.attribute29 := l_attribute29_tbl(i);
               l_asset_cat_rec.desc_flex.attribute30 := l_attribute30_tbl(i);
               l_asset_cat_rec.desc_flex.attribute_category_code :=
                  l_attribute_category_code_tbl(i);


               -- load the required/non-calculated financial columns
               l_asset_fin_rec_adj.date_placed_in_service   := l_date_placed_in_service_tbl(i);
               l_asset_fin_rec_adj.depreciate_flag          := l_depreciate_flag_tbl(i);
               l_asset_fin_rec_adj.salvage_value            := l_salvage_value_tbl(i);
               l_asset_fin_rec_adj.production_capacity      := l_production_capacity_tbl(i);
               l_asset_fin_rec_adj.reval_amortization_basis := l_reval_amortization_basis_tbl(i);
               l_asset_fin_rec_adj.unit_of_measure          := l_unit_of_measure_tbl(i);
               l_asset_fin_rec_adj.short_fiscal_year_flag   := l_short_fiscal_year_flag_tbl(i);
               l_asset_fin_rec_adj.conversion_date          := l_conversion_date_tbl(i);
               l_asset_fin_rec_adj.orig_deprn_start_date    := l_orig_deprn_start_date_tbl(i);
               l_asset_fin_rec_adj.group_asset_id           := l_group_asset_id_tbl(i);

               -- Bug 9156959 : No need to populate cost / reserve. They are
               -- already handled in inv_rec. Populate the japan specific fields
               -- only when the Japan profile is on.
               if nvl(l_japan_tax_reform,'N') = 'Y' then

                  -- Bug#7698326 start
                  l_asset_fin_rec_adj.nbv_at_switch                 := l_nbv_at_switch_tbl(i);
                  l_asset_fin_rec_adj.prior_deprn_limit_type        := l_prior_deprn_limit_type_tbl(i);
                  l_asset_fin_rec_adj.prior_deprn_limit_amount      := l_prior_deprn_limit_amt_tbl(i);
                  l_asset_fin_rec_adj.prior_deprn_limit             := l_prior_deprn_limit_tbl(i);
                  l_asset_fin_rec_adj.prior_deprn_method            := l_prior_deprn_method_tbl(i);
                  l_asset_fin_rec_adj.prior_life_in_months          := l_prior_life_in_months_tbl(i);
                  l_asset_fin_rec_adj.prior_basic_rate              := l_prior_basic_rate_tbl(i);
                  l_asset_fin_rec_adj.prior_adjusted_rate           := l_prior_adjusted_rate_tbl(i);
                  l_asset_fin_rec_adj.period_full_reserve           := l_period_full_reserve_tbl(i);
                  l_asset_fin_rec_adj.period_extd_deprn             := l_period_extd_deprn_tbl(i);
                  -- End 7698326
               end if;

               -- start new fields
               l_asset_fin_rec_adj.deprn_method_code          := l_deprn_method_code_tbl(i);
               l_asset_fin_rec_adj.life_in_months             := l_life_in_months_tbl(i);
               l_asset_fin_rec_adj.basic_rate                 := l_basic_rate_tbl(i);
               l_asset_fin_rec_adj.adjusted_rate              := l_adjusted_rate_tbl(i);
               l_asset_fin_rec_adj.prorate_convention_code    := l_prorate_convention_code_tbl(i);
               l_asset_fin_rec_adj.bonus_rule                 := l_bonus_rule_tbl(i);
               l_asset_fin_rec_adj.salvage_type               := l_salvage_type_tbl(i);
               l_asset_fin_rec_adj.percent_salvage_value      := l_percent_salvage_value_tbl(i);
               l_asset_fin_rec_adj.deprn_limit_type           := l_deprn_limit_type_tbl(i);
               l_asset_fin_rec_adj.allowed_deprn_limit_amount := l_allowed_deprn_limit_amt_tbl(i);
               l_asset_fin_rec_adj.allowed_deprn_limit        := l_allowed_deprn_limit_tbl(i);
               -- end new r12 fields

               -- load all distribution lines into the distribution array for add

               open c_distributions(p_massadd_id => l_mass_addition_id_tbl(i));
               fetch c_distributions bulk collect
                into l_mad_employee_id_tbl,
                     l_mad_deprn_expense_ccid_tbl,
                     l_mad_location_id_tbl,
                     l_mad_units_tbl;
               close c_distributions;


               for l_dist in 1..l_mad_units_tbl.count loop
                  l_asset_dist_rec.units_assigned := l_mad_units_tbl(l_dist);
                  l_asset_dist_rec.assigned_to    := l_mad_employee_id_tbl(l_dist);
                  l_asset_dist_rec.expense_ccid   := l_mad_deprn_expense_ccid_tbl(l_dist);
                  l_asset_dist_rec.location_ccid  := l_mad_location_id_tbl(l_dist);
                  l_asset_dist_tbl(l_dist)        := l_asset_dist_rec;
               end loop;


               -- call the appropriate api
               fa_addition_pub.do_addition
                  (p_api_version             => 1.0,
                   p_init_msg_list           => FND_API.G_FALSE,
                   p_commit                  => FND_API.G_FALSE,
                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status           => l_return_status,
                   x_msg_count               => l_msg_count,
                   x_msg_data                => l_msg_data,
                   p_calling_fn              => null,
                   px_trans_rec              => l_trans_rec,
                   px_dist_trans_rec         => l_dist_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   px_asset_desc_rec         => l_asset_desc_rec,
                   px_asset_type_rec         => l_asset_type_rec,
                   px_asset_cat_rec          => l_asset_cat_rec,
                   px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
                   px_asset_fin_rec          => l_asset_fin_rec_adj,
                   px_asset_deprn_rec        => l_asset_deprn_rec_adj,
                   px_asset_dist_tbl         => l_asset_dist_tbl,
                   px_inv_tbl                => l_inv_tbl
                  );

               if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  raise error_found_trx;
               end if;


            else  -- add_to_asset_id populated for adj

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,
                     'Add to asset_id',
                     l_add_to_asset_id_tbl(i));
               end if;

               l_asset_hdr_rec.asset_id        := l_add_to_asset_id_tbl(i);

               FA_ADJUSTMENT_PUB.do_adjustment
                  (p_api_version             => 1.0,
                   p_init_msg_list           => FND_API.G_FALSE,
                   p_commit                  => FND_API.G_FALSE,
                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status           => l_return_status,
                   x_msg_count               => l_msg_count,
                   x_msg_data                => l_msg_data,
                   p_calling_fn              => null,
                   px_trans_rec              => l_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                   x_asset_fin_rec_new       => l_asset_fin_rec_new,
                   x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
                   px_inv_trans_rec          => l_inv_trans_rec,
                   px_inv_tbl                => l_inv_tbl,
                   p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                   x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                   x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
                   p_group_reclass_options_rec => l_group_reclass_options_rec
                  );

               if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  raise error_found_trx;
               end if;

               if (l_new_master_flag_tbl(i) = 'YES') then

                  l_trans_rec.transaction_type_code    := 'RECLASS';
                  l_trans_rec.transaction_header_id    := null;
                  l_trans_rec.transaction_date_entered := null;
                  l_trans_rec.transaction_subtype      := null;
                  l_trans_rec.transaction_name         := null;
                  l_trans_rec.amortization_start_date  := null;
                  l_asset_cat_rec.category_id          := l_asset_category_id_tbl(i);

                  FA_RECLASS_PUB.do_reclass
                     (p_api_version         => 1.0,
                      p_init_msg_list       => FND_API.G_FALSE,
                      p_commit              => FND_API.G_FALSE,
                      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                      p_calling_fn          => l_calling_fn,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data,
                      px_trans_rec          => l_trans_rec,
                      px_asset_hdr_rec      => l_asset_hdr_rec,
                      px_asset_cat_rec_new  => l_asset_cat_rec,
                      p_recl_opt_rec        => l_recl_opt_rec
                     );

                  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                     raise error_found_trx;
                  end if;

                  update fa_additions_tl
                     set description = l_description_tbl(i),
                         source_lang = userenv('LANG')
                   where asset_id    = l_add_to_asset_id_tbl(i)
                     and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

               end if;  -- reclass

               if (nvl(l_units_to_adjust_tbl(i), 0) <> 0) then

                  l_trans_rec.transaction_type_code    := 'UNIT ADJUSTMENT';
                  l_trans_rec.transaction_header_id    := null;
                  l_trans_rec.transaction_date_entered := null;
                  l_trans_rec.transaction_subtype      := null;
                  l_trans_rec.transaction_name         := null;
                  l_trans_rec.amortization_start_date  := null;

                  -- get the assets current units
                  if not FA_UTIL_PVT.get_asset_desc_rec
                     (p_asset_hdr_rec         => l_asset_hdr_rec,
                      px_asset_desc_rec       => l_asset_desc_rec
                     , p_log_level_rec => g_log_level_rec) then
                     raise error_found_trx;
                  end if;

                  if (l_units_to_adjust_tbl(i) < 0) and
                     ((l_units_to_adjust_tbl(i) +
                       l_asset_desc_rec.current_units) <0) then
                     fa_srvr_msg.add_message(
                         calling_fn  => l_calling_fn,
                         name        => 'CUA_NEGATIVE_UNITS_NOT_ALLOWED',
                         application => 'CUA', p_log_level_rec => g_log_level_rec);
                     raise error_found_trx;
                  end if;

                  if l_mass_property_flag_tbl(i) = 'Y' then
                     if (g_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'trans_units', l_asset_dist_rec.transaction_units, p_log_level_rec => g_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'distid', l_asset_dist_rec.distribution_id, p_log_level_rec => g_log_level_rec);
                     end if;

                     open c_distributions(p_massadd_id => l_mass_addition_id_tbl(i));
                     fetch c_distributions bulk collect
                      into l_mad_employee_id_tbl,
                           l_mad_deprn_expense_ccid_tbl,
                           l_mad_location_id_tbl,
                           l_mad_units_tbl;

                     close c_distributions;

                     if (g_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'After massadd_dist bulkfetch', '', p_log_level_rec => g_log_level_rec);
                     end if;

                     for l_md in 1..l_mad_units_tbl.count loop
                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'After massadd_dist loop', l_md, p_log_level_rec => g_log_level_rec);
                        end if;

                        if l_mad_deprn_expense_ccid_tbl(l_md) is not null then

                           if (g_log_level_rec.statement_level) then
                              fa_debug_pkg.add(l_calling_fn, 'mad ccid is not null', l_mad_deprn_expense_ccid_tbl(l_md));
                           end if;

                           open c_dh (l_add_to_asset_id_tbl(i), l_mad_deprn_expense_ccid_tbl(l_md),l_mad_location_id_tbl(l_md),l_mad_employee_id_tbl(l_md));
                           fetch c_dh
                            into l_distid,
                                 l_units_assigned,
                                 l_ccid,
                                 l_locid,
                                 l_assigned_to;

                           if c_dh%FOUND then
                              -- add units to existing fa_dh row.
                              l_asset_dist_rec                   := null;
                              l_asset_dist_rec.distribution_id   := l_distid;
                              l_asset_dist_rec.transaction_units := l_mad_units_tbl(l_md);
                              l_asset_dist_tbl(l_md) := l_asset_dist_rec;

                              if (g_log_level_rec.statement_level) then
                                 fa_debug_pkg.add(l_calling_fn, 'c_dh found trans_units', l_asset_dist_rec.transaction_units, p_log_level_rec => g_log_level_rec);
                                 fa_debug_pkg.add(l_calling_fn, 'c_dh found distid', l_asset_dist_rec.distribution_id, p_log_level_rec => g_log_level_rec);
                              end if;

                           else -- dist doesn't exist
                              -- create new distribution row.

                              l_asset_dist_rec.transaction_units := l_mad_units_tbl(l_md);
                              l_asset_dist_rec.assigned_to       := l_mad_employee_id_tbl(l_md);
                              l_asset_dist_rec.expense_ccid      := l_mad_deprn_expense_ccid_tbl(l_md);
                              l_asset_dist_rec.location_ccid     := l_mad_location_id_tbl(l_md);
                              l_asset_dist_tbl(l_md)             := l_asset_dist_rec;

                              if (g_log_level_rec.statement_level) then
                                 fa_debug_pkg.add(l_calling_fn, 'c_dh notfound trans_units', l_asset_dist_rec.transaction_units, p_log_level_rec => g_log_level_rec);
                                 fa_debug_pkg.add(l_calling_fn, 'c_dh notfound ccid', l_asset_dist_rec.expense_ccid, p_log_level_rec => g_log_level_rec);
                              end if;
                           end if; -- c_dh
                           close c_dh;
                        else -- ccid is null
                           -- do same as old solution, i.e. same as in else --l_mass_property_flag below.
                           -- start duplicate cod.  strive for one new procedure to be called.
                           if (g_log_level_rec.statement_level) then
                              fa_debug_pkg.add(l_calling_fn, 'ccid is null', '', p_log_level_rec => g_log_level_rec);
                           end if;

                           -- get the current distributions
                           open c_dist_history(l_add_to_asset_id_tbl(i));
                           fetch c_dist_history bulk collect
                            into l_dist_id_tbl,
                                 l_dist_units_tbl,
                                 l_dist_ccid_tbl,
                                 l_dist_locid_tbl,
                                 l_dist_assigned_to_tbl;
                            close c_dist_history;

                           for l_dist in 1..l_dist_id_tbl.count loop

                              if (l_dist = l_dist_id_tbl.count) then
                                 -- Last Dist line to Adjust so assign it the Remaining Units
                                 l_dist_units_tbl(l_dist) := l_units_to_adjust_tbl(i) -
                                                             l_units_adjusted;
                              else
                                 l_dist_units_tbl(l_dist) :=
                                    (l_dist_units_tbl(l_dist)/
                                     l_asset_desc_rec.current_units) *
                                    l_units_to_adjust_tbl(i);
                              end if;

                              -- see BUG# 2097087 we actually allowed a higher precision in core
                              l_dist_units_tbl(l_dist) := round(l_dist_units_tbl(l_dist) ,2);
                              l_units_adjusted         := l_units_adjusted + l_dist_units_tbl(l_dist) ;

                              -- load the dst tbl for passage to api
                              l_asset_dist_rec                   := null;
                              l_asset_dist_rec.distribution_id   := l_dist_id_tbl(l_dist);
                              l_asset_dist_rec.transaction_units := l_dist_units_tbl(l_dist);

                              if (g_log_level_rec.statement_level) then
                                 fa_debug_pkg.add(l_calling_fn, 'trans_units', l_asset_dist_rec.transaction_units, p_log_level_rec => g_log_level_rec);
                                 fa_debug_pkg.add(l_calling_fn, 'distid', l_asset_dist_rec.distribution_id, p_log_level_rec => g_log_level_rec);
                              end if;

                             l_asset_dist_tbl(l_dist)           := l_asset_dist_rec;

                          end loop;

                          -- end duplicate code.   strive for one new procedure to be called.
                       end if;

                     end loop; -- massadd dist loop

                     -- mp end new code

                  else -- l_mass_property_flag

                     -- get the current distributions
                     open c_dist_history(l_add_to_asset_id_tbl(i));
                     fetch c_dist_history bulk collect
                      into l_dist_id_tbl,
                           l_dist_units_tbl,
                           l_dist_ccid_tbl,
                           l_dist_locid_tbl,
                           l_dist_assigned_to_tbl;
                     close c_dist_history;

                     --  mp there is no logic to create new distributions.
                     for l_dist in 1..l_dist_id_tbl.count loop
                        if (l_dist = l_dist_id_tbl.count) then
                           -- Last Dist line to Adjust so assign it the Remaining Units
                           l_dist_units_tbl(l_dist) := l_units_to_adjust_tbl(i) -
                                                       l_units_adjusted;
                        else
                           l_dist_units_tbl(l_dist) :=
                              (l_dist_units_tbl(l_dist)/
                               l_asset_desc_rec.current_units) *
                               l_units_to_adjust_tbl(i);
                        end if;

                        -- see BUG# 2097087 we actually allowed a higher precision in core
                        l_dist_units_tbl(l_dist) := round(l_dist_units_tbl(l_dist) ,2);
                        l_units_adjusted         := l_units_adjusted + l_dist_units_tbl(l_dist) ;

                        -- load the dst tbl for passage to api
                        l_asset_dist_rec                   := null;
                        l_asset_dist_rec.distribution_id   := l_dist_id_tbl(l_dist);
                        l_asset_dist_rec.transaction_units := l_dist_units_tbl(l_dist);

                        if (g_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'trans_units', l_asset_dist_rec.transaction_units, p_log_level_rec => g_log_level_rec);
                           fa_debug_pkg.add(l_calling_fn, 'distid', l_asset_dist_rec.distribution_id, p_log_level_rec => g_log_level_rec);
                        end if;

                        l_asset_dist_tbl(l_dist)           := l_asset_dist_rec;

                     end loop;

                     -- mp
                  end if; -- mass_property = YES...

                  l_trans_rec.transaction_type_code := 'UNIT ADJUSTMENT';

                  FA_UNIT_ADJ_PUB.do_unit_adjustment
                     (p_api_version         => 1.0,
                      p_init_msg_list       => FND_API.G_FALSE,
                      p_commit              => FND_API.G_FALSE,
                      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                      p_calling_fn          => l_calling_fn,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data,
                      px_trans_rec          => l_trans_rec,
                      px_asset_hdr_rec      => l_asset_hdr_rec,
                      px_asset_dist_tbl     => l_asset_dist_tbl);


                  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                     raise error_found_trx;
                  end if;

               end if;  --unit adjustment

            end if; -- add/adj

         end if;  -- cap/rev

         x_success_count := x_success_count + 1;

         if (l_add_to_asset_id_tbl(i) is null) then
            l_succ_asset_number := l_asset_desc_rec.asset_number;
         else
            l_succ_asset_number := null;
         end if;

         update fa_mass_additions
            set posting_status    = 'POSTED',
                queue_name        = 'POSTED',
                post_batch_id     = p_parent_request_id,
                asset_number      = l_succ_asset_number,
                last_update_date  = sysdate,
                last_updated_by   = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          where mass_addition_id  = l_mass_addition_id_tbl(i);

         update fa_mass_additions
            set posting_status    = 'POSTED',
                queue_name        = 'POSTED',
                post_batch_id     = p_parent_request_id,
                asset_number      = l_succ_asset_number,
                add_to_asset_id   = l_add_to_asset_id_tbl(i),
                asset_category_id = l_asset_category_id_tbl(i),
                asset_type        = l_asset_type_tbl(i),
                last_update_date  = sysdate,
                last_updated_by   = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          where merge_parent_mass_additions_id = l_mass_addition_id_tbl(i);


         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         end if;

         fa_srvr_msg.add_message(
            calling_fn => NULL,
            name       => 'FA_MAP_SUCCESS',
            token1     => 'MASS_ADDITION_ID',
            value1     => l_mass_addition_id_tbl(i),
            p_log_level_rec => g_log_level_rec);

      EXCEPTION

         WHEN error_found_trx THEN
            rollback to famapt;
            x_failure_count := x_failure_count + 1;
            l_fail_mass_addition_id_tbl(l_fail_mass_addition_id_tbl.count + 1) := l_mass_addition_id_tbl(i);

            update fa_mass_additions
               set posting_status    = 'ON HOLD',
                   queue_name        = 'ON HOLD'
             where mass_addition_id  = l_mass_addition_id_tbl(i);

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_MAP_FAILED',
               token1     => 'MASS_ADDITION_ID',
               value1     => l_mass_addition_id_tbl(i),
               p_log_level_rec => g_log_level_rec);

         WHEN OTHERS THEN
            rollback to famapt;
            x_failure_count := x_failure_count + 1;
            l_fail_mass_addition_id_tbl(l_fail_mass_addition_id_tbl.count + 1) := l_mass_addition_id_tbl(i);

            update fa_mass_additions
               set posting_status    = 'ON HOLD',
                   queue_name        = 'ON HOLD'
             where mass_addition_id  = l_mass_addition_id_tbl(i);

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_MAP_FAILED',
               token1     => 'MASS_ADDITION_ID',
               value1     => l_mass_addition_id_tbl(i),
               p_log_level_rec => g_log_level_rec);

      END;  -- asset level block

      -- commit each record
      commit;
   -- Bug# 6951660
   end loop;  -- array loop

      l_attribute1_tbl.delete;
      l_attribute2_tbl.delete;
      l_attribute3_tbl.delete;
      l_attribute4_tbl.delete;
      l_attribute5_tbl.delete;
      l_attribute6_tbl.delete;
      l_attribute7_tbl.delete;
      l_attribute8_tbl.delete;
      l_attribute9_tbl.delete;
      l_attribute10_tbl.delete;
      l_attribute11_tbl.delete;
      l_attribute12_tbl.delete;
      l_attribute13_tbl.delete;
      l_attribute14_tbl.delete;
      l_attribute15_tbl.delete;
      l_attribute16_tbl.delete;
      l_attribute17_tbl.delete;
      l_attribute18_tbl.delete;
      l_attribute19_tbl.delete;
      l_attribute20_tbl.delete;
      l_attribute21_tbl.delete;
      l_attribute22_tbl.delete;
      l_attribute23_tbl.delete;
      l_attribute24_tbl.delete;
      l_attribute25_tbl.delete;
      l_attribute26_tbl.delete;
      l_attribute27_tbl.delete;
      l_attribute28_tbl.delete;
      l_attribute29_tbl.delete;
      l_attribute30_tbl.delete;
      l_attribute_category_code_tbl.delete;
      l_global_attribute1_tbl.delete;
      l_global_attribute2_tbl.delete;
      l_global_attribute3_tbl.delete;
      l_global_attribute4_tbl.delete;
      l_global_attribute5_tbl.delete;
      l_global_attribute6_tbl.delete;
      l_global_attribute7_tbl.delete;
      l_global_attribute8_tbl.delete;
      l_global_attribute9_tbl.delete;
      l_global_attribute10_tbl.delete;
      l_global_attribute11_tbl.delete;
      l_global_attribute12_tbl.delete;
      l_global_attribute13_tbl.delete;
      l_global_attribute14_tbl.delete;
      l_global_attribute15_tbl.delete;
      l_global_attribute16_tbl.delete;
      l_global_attribute17_tbl.delete;
      l_global_attribute18_tbl.delete;
      l_global_attribute19_tbl.delete;
      l_global_attribute20_tbl.delete;
      l_global_attribute_cat_tbl.delete;
      l_th_attribute1_tbl.delete;
      l_th_attribute2_tbl.delete;
      l_th_attribute3_tbl.delete;
      l_th_attribute4_tbl.delete;
      l_th_attribute5_tbl.delete;
      l_th_attribute6_tbl.delete;
      l_th_attribute7_tbl.delete;
      l_th_attribute8_tbl.delete;
      l_th_attribute9_tbl.delete;
      l_th_attribute10_tbl.delete;
      l_th_attribute11_tbl.delete;
      l_th_attribute12_tbl.delete;
      l_th_attribute13_tbl.delete;
      l_th_attribute14_tbl.delete;
      l_th_attribute15_tbl.delete;
      l_th_attribute_cat_code_tbl.delete;



   commit;

   --Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
   if x_failure_count = 0 then
    fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_JP_NO_ERROR_FOUND', p_log_level_rec => g_log_level_rec);




   end if;

   x_return_status   := 0;


EXCEPTION
   when done_exc then
      rollback;
      x_return_status := 0;
   when init_err then
      rollback;
      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;

   when error_found then
      rollback;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;

   when others then
      rollback;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;


END Do_Mass_Addition;

----------------------------------------------------------------

FUNCTION Do_mass_property(
         p_book_type_code               IN      VARCHAR2,
         p_rowid_tbl                    IN      char_tbl_type ,
         p_mass_addition_id_tbl         IN      num_tbl_type  ,
         px_asset_id_tbl                IN OUT  NOCOPY num_tbl_type  ,
         px_add_to_asset_id_tbl         IN OUT  NOCOPY num_tbl_type  ,
         p_asset_category_id_tbl        IN      num_tbl_type  ,
         p_asset_type_tbl               IN      char_tbl_type ,
         px_date_placed_in_service_tbl  IN OUT  NOCOPY date_tbl_type ,
         px_amortize_flag_tbl           IN OUT  NOCOPY char_tbl_type ,
         px_amortization_start_date_tbl IN OUT  NOCOPY date_tbl_type ,
         px_description_tbl             IN OUT  NOCOPY char_tbl_type ,
         p_fixed_assets_units_tbl       IN      num_tbl_type  ,
         px_units_to_adjust_tbl         IN OUT  NOCOPY num_tbl_type  )    RETURN BOOLEAN IS

  Error      varchar2(100);

  Cursor c_fy_add (p_category_id             number,
                   p_asset_type              varchar2,
                   p_book_type_code          varchar2,
                   p_date_placed_in_service  date) is
      Select 'Mass Property Asset Exists',
             ad.asset_id,
             ad.asset_type,
             bk.date_placed_in_service,
             ad.description,
             fy1.start_date,
             fy1.end_date
        from fa_books            bk,
             fa_additions        ad,
             fa_book_controls    bc,
             fa_fiscal_year      fy1,
             fa_fiscal_year      fy2,
             fa_calendar_periods cp1
       where ad.asset_category_id      = p_category_id
         and ad.asset_type             = p_asset_type
         and bk.book_type_code         = p_book_type_code
         and bc.book_type_code         = bk.book_type_code
         and bc.fiscal_year_name       = fy1.fiscal_year_name
         and bk.asset_id               = ad.asset_id
         and bk.period_counter_fully_retired is null
	 and bk.transaction_header_id_out is NULL
         and bk.date_placed_in_service = cp1.start_date
         and cp1.calendar_type         = bc.deprn_calendar
         and cp1.period_num            = 1
         and cp1.start_date      between fy1.start_date and fy1.end_date
         and fy2.fiscal_year           = fy1.fiscal_year
         and fy2.fiscal_year_name      = bc.fiscal_year_name
         and trunc(p_date_placed_in_service) between
               fy2.start_date and fy2.end_date
        order by ad.asset_id;

   mprec   c_fy_add%ROWTYPE;

   l_new_dpis           date;
   l_new_desc_year      varchar2(4);
   l_new_desc_category  fa_categories.description%TYPE;
   l_new_start_date     date;
   l_new_end_date       date;

   l_mp_found           boolean;
   l_mp_asset_indicator number;

   l_process_order      num_tbl_type;

   l_calling_fn         varchar2(60) := 'fa_massadd_Pkg.do_mass_property';

BEGIN

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
         'In do_mass_property',
         '', p_log_level_rec => g_log_level_rec);
   end if;

   -- loop through the lines passed via arrays
   for i in 1..p_rowid_tbl.count loop

      -- first search current global array for match
      l_mp_asset_indicator := 0;

      -- cursor is order by category and dpis
      -- thus we can clear global arrays when category of FY changes
      -- fy is unlikely as most assets would be current period / year

      if (g_last_mp_category_id <> p_asset_category_id_tbl(i)) then
         G_new_mp_asset_tbl.delete;
         G_last_mp_category_id := p_asset_category_id_tbl(i);
      end if;

      if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, entering new mp table loop',
               '', p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, p_asset_category_id_tbl count',
               p_asset_category_id_tbl.count, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, G_new_mp_asset_tbl count',
               G_new_mp_asset_tbl.count, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, px_date_placed_in_service_tbl count',
               px_date_placed_in_service_tbl.count, p_log_level_rec => g_log_level_rec);

      end if;

      for x in 1..G_new_mp_asset_tbl.count loop

          if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, in global table loop - x value is',
               x, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, p_asset_category_id_tbl(i)',
               p_asset_category_id_tbl(i));
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, G_new_mp_asset_tbl(x).category_id',
               G_new_mp_asset_tbl(x).category_id);
         end if;

         if (p_asset_category_id_tbl(i)            = G_new_mp_asset_tbl(x).category_id and
             px_date_placed_in_service_tbl(i) between G_new_mp_asset_tbl(x).start_date
                                                 and G_new_mp_asset_tbl(x).end_date) then

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                  'do_mass_property, match found in global table',
                  '', p_log_level_rec => g_log_level_rec);
            end if;

            l_mp_found := TRUE;
            l_mp_asset_indicator := x;

            exit;
         end if;
      end loop;

      -- if not found in array, search posted assets
      if (l_mp_asset_indicator = 0) then

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, not found in array',
               '', p_log_level_rec => g_log_level_rec);
         end if;

         open c_fy_add
                  (p_category_id             => p_asset_category_id_tbl(i),
                   p_asset_type              => p_asset_type_tbl(i),
                   p_book_type_code          => p_book_type_code,
                   p_date_placed_in_service  => px_date_placed_in_service_tbl(i)) ;
         fetch c_fy_add into mprec;
         if c_fy_add%FOUND then

            l_mp_found := TRUE;

            -- load the returned value into the global MP asset arrays
            l_mp_asset_indicator := G_new_mp_asset_tbl.count + 1;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                  'After mass_property, l_mp_asset_indicator to load global tabe',
                  l_mp_asset_indicator, p_log_level_rec => g_log_level_rec);
            end if;

            G_new_mp_asset_tbl(l_mp_asset_indicator).asset_id               := mprec.asset_id;
            G_new_mp_asset_tbl(l_mp_asset_indicator).asset_type             := mprec.asset_type;
            G_new_mp_asset_tbl(l_mp_asset_indicator).category_id            := p_asset_category_id_tbl(i);
            G_new_mp_asset_tbl(l_mp_asset_indicator).date_placed_in_service := mprec.date_placed_in_service;
            G_new_mp_asset_tbl(l_mp_asset_indicator).description            := mprec.description;
            G_new_mp_asset_tbl(l_mp_asset_indicator).fiscal_year            := to_char(mprec.start_date, 'YYYY');
            G_new_mp_asset_tbl(l_mp_asset_indicator).start_date             := mprec.start_date;
            G_new_mp_asset_tbl(l_mp_asset_indicator).end_date               := mprec.end_date;


            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                  'found existing assetid',
                  mprec.asset_id, p_log_level_rec => g_log_level_rec);
            end if;

         end if;
         close c_fy_add;

      end if;  -- table search

      -- if neither is found, this lines becomes the MP asset
      if (l_mp_asset_indicator = 0) then

         l_mp_found := FALSE;
         l_mp_asset_indicator := G_new_mp_asset_tbl.count + 1;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, not found in array nor tables',
               '', p_log_level_rec => g_log_level_rec);
         end if;

         -- Bug 5454552 changed to_char(fy.start_date,'YYYY') to
         -- to_char(fy.fiscal_year)

         Select fy.start_date,
                to_char(fy.fiscal_year),
                cat.description,
                fy.start_date,
                fy.end_date
           Into l_new_dpis,
                l_new_desc_year,
                l_new_desc_category,
                l_new_start_date,
                l_new_end_date
           From fa_fiscal_year fy,
                fa_book_controls bc,
                fa_categories cat
          Where px_date_placed_in_service_tbl(i) between fy.start_date and fy.end_date
            And fy.fiscal_year_name      = bc.fiscal_year_name
            And bc.book_type_code        = p_book_type_code
            And cat.category_id          = p_asset_category_id_tbl(i);

         if (px_asset_id_tbl(i) is null) then
            select fa_additions_s.nextval
              into px_asset_id_tbl(i)
              from dual;
         end if;

         G_new_mp_asset_tbl(l_mp_asset_indicator).asset_id               := px_asset_id_tbl(i);
         G_new_mp_asset_tbl(l_mp_asset_indicator).asset_type             := p_asset_type_tbl(i);
         G_new_mp_asset_tbl(l_mp_asset_indicator).category_id            := p_asset_category_id_tbl(i);
         G_new_mp_asset_tbl(l_mp_asset_indicator).date_placed_in_service := l_new_dpis;
         G_new_mp_asset_tbl(l_mp_asset_indicator).description            := 'MP' || l_new_desc_year || ' ' || l_new_desc_category;
         G_new_mp_asset_tbl(l_mp_asset_indicator).fiscal_year            := l_new_desc_year;
         G_new_mp_asset_tbl(l_mp_asset_indicator).start_date             := l_new_start_date;
         G_new_mp_asset_tbl(l_mp_asset_indicator).end_date               := l_new_end_date;
      end if ;



      -- derivation code (move in from main block for bulk and allocation)
      -- GROUP will always create a new mp-asset, because no adjustments allowed.

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
            'do_mass_property, entering main derivation code',
            '', p_log_level_rec => g_log_level_rec);
      end if;

      if (l_mp_found = TRUE and
          p_asset_type_tbl(i) <> 'GROUP') then

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'do_mass_property, mp found and capitalized',
               '', p_log_level_rec => g_log_level_rec);
         end if;

         if px_add_to_asset_id_tbl(i) is null then
            px_add_to_asset_id_tbl(i) := G_new_mp_asset_tbl(l_mp_asset_indicator).asset_id;
            px_units_to_adjust_tbl(i) := p_fixed_assets_units_tbl(i);
         end if;

         if (G_new_mp_asset_tbl(l_mp_asset_indicator).asset_type = 'CAPITALIZED') then

            px_amortization_start_date_tbl(i)  := px_date_placed_in_service_tbl(i);
            px_amortize_flag_tbl(i)            := 'YES';

         end if;

         l_process_order(i) := 1;

      else -- mp asset not found is null or group asset

         -- fix for bug 2723293
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'After do_mass_property, dpis',
               px_date_placed_in_service_tbl(i));
            fa_debug_pkg.add(l_calling_fn,
               'After do_mass_property, asset_type',
               p_asset_type_tbl(i));
         end if;

         if p_asset_type_tbl(i) in ('CAPITALIZED', 'GROUP') then

            if (px_date_placed_in_service_tbl(i) <>
                G_new_mp_asset_tbl(l_mp_asset_indicator).date_placed_in_service) then
               px_amortize_flag_tbl(i) := 'YES';
            end if;

            px_amortization_start_date_tbl(i) := px_date_placed_in_service_tbl(i);
         end if;

         px_description_tbl(i)            := G_new_mp_asset_tbl(l_mp_asset_indicator).description;
         px_date_placed_in_service_tbl(i) := G_new_mp_asset_tbl(l_mp_asset_indicator).date_placed_in_service;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
               'After mass_property, amort_start_date',
               px_amortization_start_date_tbl(i));
            fa_debug_pkg.add(l_calling_fn,
               'After mass_property, dpis',
               px_date_placed_in_service_tbl(i));
         end if;

         l_process_order(i) := null;

      end if; -- mp_asset_id_found

   end loop;


   -- now update the rows in the interface with newly derived values

   forall i in 1..p_rowid_tbl.count
   update fa_mass_additions
      set description             = px_description_tbl(i),
          date_placed_in_service  = px_date_placed_in_service_tbl(i),
          asset_id                = px_asset_id_tbl(i),
          add_to_asset_id         = px_add_to_asset_id_tbl(i),
          units_to_adjust         = px_units_to_adjust_tbl(i),
          amortize_flag           = px_amortize_flag_tbl(i),
          amortization_start_date = px_amortization_start_date_tbl(i),
          mass_property_flag      = 'Y',
          process_order           = l_process_order(i)
    where rowid                   = p_rowid_tbl(i);

   return true;

EXCEPTION
   WHEN others THEN
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return false;

END Do_Mass_Property;


----------------------------------------------------------------

-- This function will select all candidate mass additions in a single
-- shot (no longer distinguishes between parent / child). The primary
-- cursors have removed logic for checking if parent or group exist.
-- We will only stripe the worker number based on the following order:
--
-- In the initial phase, we will use a mod as before with precedence:
--      group / add_to_asset / parent /child
--
-- Rare case of group reclasses or multi-tier parent / add-to-asset
-- relationship will not be handled here and could result in errors
-- due to locking...
--
-- Currently, FAXMADDS does not allow parents nor groups to be chosen
-- from the interface, only from existing assets
--  (i.e. even with FUTURE lines)


PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_mode               IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER) IS

   -- local variables
   l_period_rec                 FA_API_TYPES.period_rec_type;
   l_calendar_period_close_date date;

   -- Used for bulk fetching
   l_batch_size                  number;

   l_rowid_tbl                   char_tbl_type ;
   l_mass_addition_id_tbl        num_tbl_type  ;
   l_asset_id_tbl                num_tbl_type  ;
   l_add_to_asset_id_tbl         num_tbl_type  ;
   l_asset_category_id_tbl       num_tbl_type  ;
   l_asset_type_tbl              char_tbl_type ;
   l_date_placed_in_service_tbl  date_tbl_type ;
   l_amortize_flag_tbl           char_tbl_type ;
   l_amortization_start_date_tbl date_tbl_type ;
   l_description_tbl             char_tbl_type ;
   l_units_to_adjust_tbl         num_tbl_type  ;
   l_fixed_assets_units_tbl      num_tbl_type  ;

   cursor c_mp_future is
    select mad.rowid,
           mad.mass_addition_id,
           mad.asset_id,
           mad.add_to_asset_id,
           mad.asset_category_id,
           mad.asset_type,
           mad.date_placed_in_service,
           mad.amortize_flag,
           mad.amortization_start_date,
           mad.description,
           mad.fixed_assets_units,
           mad.units_to_adjust
      from fa_mass_additions         mad,
           fa_category_book_defaults cbd
     where mad.book_type_code    = p_book_type_code
       and mad.posting_status    = 'POST'
       and mad.add_to_asset_id  is null
       and mad.merge_parent_mass_additions_id is null
       and mad.asset_type       <> 'EXPENSED'
       and mad.transaction_date is not null
       and mad.transaction_date <= l_calendar_period_close_date
       and nvl(mad.transaction_type_code, 'FUTURE ADD') in ('FUTURE ADD', 'FUTURE ADJ')
       and mad.asset_category_id = cbd.category_id
       and mad.book_type_code    = cbd.book_type_code
       and mad.date_placed_in_service
           between start_dpis and nvl(end_dpis,add_months(sysdate,1200))
       and cbd.mass_property_flag = 'Y'
     order by mad.asset_category_id, mad.date_placed_in_service;

   cursor c_mp_normal is
    select mad.rowid,
           mad.mass_addition_id,
           mad.asset_id,
           mad.add_to_asset_id,
           mad.asset_category_id,
           mad.asset_type,
           mad.date_placed_in_service,
           mad.amortize_flag,
           mad.amortization_start_date,
           mad.description,
           mad.fixed_assets_units,
           mad.units_to_adjust
      from fa_mass_additions         mad,
           fa_category_book_defaults cbd
     where mad.book_type_code         = p_book_type_code
       and mad.posting_status         = 'POST'
       and mad.add_to_asset_id  is null
       and mad.merge_parent_mass_additions_id is null
       and mad.asset_type       <> 'EXPENSED'
       and mad.transaction_date  is null
       and mad.asset_category_id  = cbd.category_id
       and mad.book_type_code     = cbd.book_type_code
       and mad.date_placed_in_service
           between start_dpis and nvl(end_dpis,add_months(sysdate,1200))
       and cbd.mass_property_flag = 'Y'
     order by mad.asset_category_id, mad.date_placed_in_service;

   massadd_err                  exception;
   massprop_err                 exception;
   l_calling_fn                 varchar2(40) := 'fa_massadd_pkg.allocate_workers';

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  massadd_err;
      end if;
   end if;

   if(g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,  'at beginning of', 'worker allocation', p_log_level_rec => g_log_level_rec);
   end if;

   x_return_status := 0;

   -- get corp book information
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise massadd_err;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- get corp period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_book_type_code,
           p_period_counter => fa_cache_pkg.fazcbc_record.last_period_counter + 1,
           x_period_rec     => l_period_rec
          , p_log_level_rec => g_log_level_rec) then
      raise massadd_err;
   end if;

   -- get corp period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_book_type_code,
           p_period_counter => fa_cache_pkg.fazcbc_record.last_period_counter + 1,
           x_period_rec     => l_period_rec
          , p_log_level_rec => g_log_level_rec) then
      raise massadd_err;
   end if;

   l_calendar_period_close_date := l_period_rec.calendar_period_close_date;



   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
         'Calling do_mass_property',
         '', p_log_level_rec => g_log_level_rec);
   end if;

   -- mass property handling - needs to be done before stiping...
   -- note that in the past mass property was done a row by row basis
   -- because we're doing bulk and doing it before posting, the possibility
   -- exists that multiple lines would create the same mass property asset
   -- during this allocation run.
   --
   -- thus we need to maintain an array of new MP assets and check that
   -- in addition to posted assets.  All code is now therefore in do_mp itself

   if (p_mode = 'NORMAL') then
      open c_mp_normal;
   else
      open c_mp_future;
   end if;

   loop  -- bulk loop

      if (p_mode = 'NORMAL') then
         fetch c_mp_normal bulk collect
          into l_rowid_tbl                   ,
               l_mass_addition_id_tbl        ,
               l_asset_id_tbl                ,
               l_add_to_asset_id_tbl         ,
               l_asset_category_id_tbl       ,
               l_asset_type_tbl              ,
               l_date_placed_in_service_tbl  ,
               l_amortize_flag_tbl           ,
               l_amortization_start_date_tbl ,
               l_description_tbl             ,
               l_fixed_assets_units_tbl      ,
               l_units_to_adjust_tbl
         limit l_batch_size;
      else
         fetch c_mp_future bulk collect
          into l_rowid_tbl                   ,
               l_mass_addition_id_tbl        ,
               l_asset_id_tbl                ,
               l_add_to_asset_id_tbl         ,
               l_asset_category_id_tbl       ,
               l_asset_type_tbl              ,
               l_date_placed_in_service_tbl  ,
               l_amortize_flag_tbl           ,
               l_amortization_start_date_tbl ,
               l_description_tbl             ,
               l_fixed_assets_units_tbl      ,
               l_units_to_adjust_tbl
         limit l_batch_size;
      end if;

      if (l_rowid_tbl.count = 0) then
         exit;
      end if;

      if not do_mass_property
              (p_book_type_code               => p_book_type_code              ,
               p_rowid_tbl                    => l_rowid_tbl                   ,
               p_mass_addition_id_tbl         => l_mass_addition_id_tbl        ,
               px_asset_id_tbl                => l_asset_id_tbl                ,
               px_add_to_asset_id_tbl         => l_add_to_asset_id_tbl         ,
               p_asset_category_id_tbl        => l_asset_category_id_tbl       ,
               p_asset_type_tbl               => l_asset_type_tbl              ,
               px_date_placed_in_service_tbl  => l_date_placed_in_service_tbl  ,
               px_amortize_flag_tbl           => l_amortize_flag_tbl           ,
               px_amortization_start_date_tbl => l_amortization_start_date_tbl ,
               px_description_tbl             => l_description_tbl             ,
               p_fixed_assets_units_tbl       => l_fixed_assets_units_tbl      ,
               px_units_to_adjust_tbl         => l_units_to_adjust_tbl  ) then
         raise massadd_err;
      end if;

   end loop;

   if (p_mode = 'NORMAL') then
      close c_mp_normal;
   else
      close c_mp_future;
   end if;

   -- end mp

   -- main group defaulting and worker striping code

   if (p_mode = 'NORMAL') then

      -- update group asset information if we're not copying from corp
      if nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y' then

         update fa_mass_additions mad
            set group_asset_id =
                (select cbd.group_asset_id
                   from fa_category_book_defaults    cbd
                  where mad.asset_category_id        = cbd.category_id
                    and mad.book_type_code           = p_book_type_code
                    and cbd.book_type_code           = p_book_type_code
                    and mad.date_placed_in_service   between
                        cbd.start_dpis and nvl(cbd.end_dpis, mad.transaction_date)
                    and cbd.group_asset_id          is not null)
          where book_type_code        = p_book_type_code
            and posting_status        = 'POST'
            and mad.transaction_date is null
            and mad.add_to_asset_id  is null
            and mad.group_asset_id   is null
            and nvl(mad.transaction_type_code, 'FUTURE ADD') not in ('FUTURE CAP', 'FUTURE REV');

         update fa_mass_additions mad
            set group_asset_id =
                (select group_asset_id
                   from fa_books bk
                  where bk.asset_id = mad.add_to_asset_id
                    and bk.book_type_code = mad.book_type_code
                    and bk.transaction_header_id_out is null)
          where book_type_code        = p_book_type_code
            and posting_status        = 'POST'
            and mad.transaction_date is null
            and mad.add_to_asset_id  is not null
            and mad.group_asset_id   is null
            and nvl(mad.transaction_type_code, 'FUTURE ADD') not in ('FUTURE CAP', 'FUTURE REV');


      end if;

      update fa_mass_additions mad
         set mad.request_id        = p_parent_request_id,
             mad.worker_id         = mod(nvl(mad.group_asset_id,
                                             nvl(mad.add_to_asset_id,
                                                 nvl(mad.asset_id,
                                                     mad.mass_addition_id))),
                                         p_total_requests) + 1,
             mad.process_order     = decode(mad.process_order,
                                            null, 1,
                                            mad.process_order + 1)
       where mad.book_type_code    = p_book_type_code
         and mad.posting_status    = 'POST'
         and mad.transaction_date is null;

   else

      -- update group asset information if we're not copying from corp
      if nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y' then

         update fa_mass_additions mad
            set group_asset_id =
                (select cbd.group_asset_id
                   from fa_category_book_defaults    cbd
                  where mad.asset_category_id        = cbd.category_id
                    and mad.book_type_code           = p_book_type_code
                    and cbd.book_type_code           = p_book_type_code
                    and mad.date_placed_in_service   between
                        cbd.start_dpis and nvl(cbd.end_dpis, mad.transaction_date)
                    and cbd.group_asset_id          is not null
                    and mad.add_to_asset_id is null)
          where book_type_code        = p_book_type_code
            and posting_status        = 'POST'
            and mad.transaction_date is not null
            and mad.transaction_date <= l_calendar_period_close_date
            and mad.add_to_asset_id  is null
            and mad.group_asset_id   is null
            and nvl(mad.transaction_type_code, 'FUTURE ADD') not in ('FUTURE CAP', 'FUTURE REV');

         update fa_mass_additions mad
            set group_asset_id =
                (select group_asset_id
                   from fa_books bk
                  where bk.asset_id = mad.add_to_asset_id
                    and bk.book_type_code = mad.book_type_code
                    and bk.transaction_header_id_out is null)
          where book_type_code        = p_book_type_code
            and posting_status        = 'POST'
            and mad.transaction_date is not null
            and mad.transaction_date <= l_calendar_period_close_date
            and mad.add_to_asset_id  is not null
            and mad.group_asset_id   is null
            and nvl(mad.transaction_type_code, 'FUTURE ADD') not in ('FUTURE CAP', 'FUTURE REV');

      end if;

      update fa_mass_additions mad
         set mad.request_id        = p_parent_request_id,
             mad.worker_id         = mod(nvl(mad.group_asset_id,
                                             nvl(mad.add_to_asset_id,
                                                 nvl(mad.asset_id,
                                                     mad.mass_addition_id))),
                                         p_total_requests) + 1,
             mad.process_order     = decode(mad.process_order,
                                            null, decode(mad.transaction_type_code,
                                            'FUTURE ADD', 2,
                                            'FUTURE ADJ', 3,
                                            'FUTURE CAP', 3,
                                            'FUTURE REV', 3,
                                            NULL),
                                            'FUTURE ADD', 3,
                                            'FUTURE ADJ', 4,
                                            'FUTURE CAP', 4,
                                            'FUTURE REV', 4,
                                            NULL)
       where mad.book_type_code    = p_book_type_code
         and mad.posting_status    = 'POST'
         and mad.transaction_date is not null
         and mad.transaction_date <= l_calendar_period_close_date;

   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into fa_mass_addition_trxs', sql%rowcount);
   end if;

   commit;

   x_return_status := 0;

EXCEPTION
   WHEN massadd_err THEN
      ROLLBACK;
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      X_return_status := 2;

   WHEN OTHERS THEN
      ROLLBACK;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;


END allocate_workers;

----------------------------------------------------------------

END FA_MASSADD_PKG;

/
