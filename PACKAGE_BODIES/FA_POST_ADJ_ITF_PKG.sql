--------------------------------------------------------
--  DDL for Package Body FA_POST_ADJ_ITF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_POST_ADJ_ITF_PKG" as
/* $Header: fapadjib.pls 120.1.12010000.2 2010/04/17 13:19:46 deemitta noship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE fapadji(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number) IS

   -- messaging
   l_batch_size                   NUMBER;
   l_loop_count                   NUMBER;
   l_count		          NUMBER := 0;
   p_msg_count                    NUMBER := 0;
   p_msg_data                     VARCHAR2(512);
   l_name                         VARCHAR2(30);
   l_temp                         VARCHAR2(30);

   -- misc
   l_debug                        boolean;
   l_request_id                   NUMBER;
   l_trx_approval                 BOOLEAN;
   rbs_name	                      VARCHAR2(30);
   sql_stmt                       VARCHAR2(101);
   l_status                       VARCHAR2(1);
   l_result                       BOOLEAN := TRUE;

   -- types
   TYPE rowid_tbl  IS TABLE OF VARCHAR2(50)  INDEX BY BINARY_INTEGER;
   TYPE number_tbl IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
   TYPE date_tbl   IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
   TYPE v30_tbl    IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
   TYPE v15_tbl    IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;

   -- used for main cursor
   l_itf_rowid                    rowid_tbl;
   l_asset_id                     number_tbl;
   l_cgu_id                       number_tbl;
   l_asset_number                 v30_tbl;
   l_asset_type                   v30_tbl;
   l_adjusted_rate                number_tbl;
   l_basic_rate                   number_tbl;
   l_bonus_rule                   v30_tbl;
   l_ceiling_name                 v30_tbl;
   l_cost                         number_tbl;
   l_date_placed_in_service       date_tbl;
   l_depreciate_flag              v30_tbl;
   l_deprn_method_code            v30_tbl;
   l_itc_amount_id                number_tbl;
   l_life_in_months               number_tbl;
   l_original_cost                number_tbl;
   l_production_capacity          number_tbl;
   l_prorate_convention_code      v30_tbl;
   l_salvage_value                number_tbl;
   l_short_fiscal_year_flag       v30_tbl;
   l_conversion_date              date_tbl;
   l_original_deprn_start_date    date_tbl;
   l_fully_rsvd_revals_counter    number_tbl;
   l_unrevalued_cost              number_tbl;
   l_reval_ceiling                number_tbl;
   l_deprn_reserve                number_tbl;
   l_ytd_deprn                    number_tbl;
   l_reval_amortization_basis     number_tbl;
   l_reval_reserve                number_tbl;
   l_ytd_reval_deprn_expense      number_tbl;
   l_transaction_subtype          v30_tbl;
   l_amortization_start_date      date_tbl;
   l_transaction_name             v30_tbl;
   l_attribute1                   v30_tbl;
   l_attribute2                   v30_tbl;
   l_attribute3                   v30_tbl;
   l_attribute4                   v30_tbl;
   l_attribute5                   v30_tbl;
   l_attribute6                   v30_tbl;
   l_attribute7                   v30_tbl;
   l_attribute8                   v30_tbl;
   l_attribute9                   v30_tbl;
   l_attribute10                  v30_tbl;
   l_attribute11                  v30_tbl;
   l_attribute12                  v30_tbl;
   l_attribute13                  v30_tbl;
   l_attribute14                  v30_tbl;
   l_attribute15                  v30_tbl;
   l_attribute_category_code      v30_tbl;
   l_global_attribute1            v30_tbl;
   l_global_attribute2            v30_tbl;
   l_global_attribute3            v30_tbl;
   l_global_attribute4            v30_tbl;
   l_global_attribute5            v30_tbl;
   l_global_attribute6            v30_tbl;
   l_global_attribute7            v30_tbl;
   l_global_attribute8            v30_tbl;
   l_global_attribute9            v30_tbl;
   l_global_attribute10           v30_tbl;
   l_global_attribute11           v30_tbl;
   l_global_attribute12           v30_tbl;
   l_global_attribute13           v30_tbl;
   l_global_attribute14           v30_tbl;
   l_global_attribute15           v30_tbl;
   l_global_attribute16           v30_tbl;
   l_global_attribute17           v30_tbl;
   l_global_attribute18           v30_tbl;
   l_global_attribute19           v30_tbl;
   l_global_attribute20           v30_tbl;
   l_global_attribute_category    v30_tbl;
   l_group_asset_id               number_tbl;
   l_cash_generating_unit_id      number_tbl;
   l_prd_counter_fully_reserved   v15_tbl;
   l_prd_counter_fully_retired    v15_tbl;

   -- used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_mesg_count                   number;
   l_mesg                         VARCHAR2(4000);
   l_mesg_name                    VARCHAR2(30);

   l_calling_fn                   VARCHAR2(30) := 'fa_post_adj_itf_pkg.fapadji';
   l_string                       varchar2(250);

   l_trans_rec                    FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec                FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_adj            FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new            FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new        FA_API_TYPES.asset_fin_tbl_type;
   l_inv_trans_rec                FA_API_TYPES.inv_trans_rec_type;
   l_inv_tbl                      FA_API_TYPES.inv_tbl_type;
   l_asset_deprn_rec_adj          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new      FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec    FA_API_TYPES.group_reclass_options_rec_type;

   l_asset_fin_rec_old            FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_old          FA_API_TYPES.asset_deprn_rec_type;

   l_deprn_exp_amort_nbv          number;
   l_amort_count                  number;

   CURSOR c_assets IS
          select ajitf.rowid,
                 ad.asset_id,
                 ajitf.asset_number,
                 ad.asset_type,
                 ajitf.adjusted_rate,
                 ajitf.basic_rate,
                 ajitf.bonus_rule,
                 ajitf.ceiling_name,
                 ajitf.cost,
                 ajitf.date_placed_in_service,
                 ajitf.depreciate_flag,
                 ajitf.deprn_method_code,
                 ajitf.itc_amount_id,
                 ajitf.life_in_months,
                 ajitf.original_cost,
                 ajitf.production_capacity,
                 ajitf.prorate_convention_code,
                 ajitf.salvage_value,
                 ajitf.short_fiscal_year_flag,
                 ajitf.conversion_date,
                 ajitf.original_deprn_start_date,
                 ajitf.fully_rsvd_revals_counter,
                 ajitf.unrevalued_cost,
                 ajitf.reval_ceiling,
                 ajitf.deprn_reserve,
                 ajitf.ytd_deprn,
                 ajitf.reval_amortization_basis,
                 ajitf.reval_reserve,
                 ajitf.ytd_reval_deprn_expense,
                 decode(ajitf.amortize_nbv_flag,
                        'YES', 'AMORTIZED',
                        'EXPENSED')  transaction_subtype,
                 ajitf.amortization_start_date,
                 nvl(ajitf.transaction_name, 'Adjustments Interface') transaction_name,
                 ajitf.attribute1,
                 ajitf.attribute2,
                 ajitf.attribute3,
                 ajitf.attribute4,
                 ajitf.attribute5,
                 ajitf.attribute6,
                 ajitf.attribute7,
                 ajitf.attribute8,
                 ajitf.attribute9,
                 ajitf.attribute10,
                 ajitf.attribute11,
                 ajitf.attribute12,
                 ajitf.attribute13,
                 ajitf.attribute14,
                 ajitf.attribute15,
                 ajitf.attribute_category_code,
                 nvl(ajitf.global_attribute1,
                     bk.global_attribute1) global_attribute1,
                 nvl(ajitf.global_attribute2,
                     bk.global_attribute2) global_attribute2,
                 nvl(ajitf.global_attribute3,
                     bk.global_attribute3) global_attribute3,
                 nvl(ajitf.global_attribute4,
                     bk.global_attribute4) global_attribute4,
                 nvl(ajitf.global_attribute5,
                     bk.global_attribute5) global_attribute5,
                 nvl(ajitf.global_attribute6,
                     bk.global_attribute6) global_attribute6,
                 nvl(ajitf.global_attribute7,
                     bk.global_attribute7) global_attribute7,
                 nvl(ajitf.global_attribute8,
                     bk.global_attribute8) global_attribute8,
                 nvl(ajitf.global_attribute9,
                     bk.global_attribute9) global_attribute9,
                 nvl(ajitf.global_attribute10,
                     bk.global_attribute10) global_attribute10,
                 nvl(ajitf.global_attribute11,
                     bk.global_attribute11) global_attribute11,
                 nvl(ajitf.global_attribute12,
                     bk.global_attribute12) global_attribute12,
                 nvl(ajitf.global_attribute13,
                     bk.global_attribute13) global_attribute13,
                 nvl(ajitf.global_attribute14,
                     bk.global_attribute14) global_attribute14,
                 nvl(ajitf.global_attribute15,
                     bk.global_attribute15) global_attribute15,
                 nvl(ajitf.global_attribute16,
                     bk.global_attribute16) global_attribute16,
                 nvl(ajitf.global_attribute17,
                     bk.global_attribute17) global_attribute17,
                 nvl(ajitf.global_attribute18,
                     bk.global_attribute18) global_attribute18,
                 nvl(ajitf.global_attribute19,
                     bk.global_attribute19) global_attribute19,
                 nvl(ajitf.global_attribute20,
                     bk.global_attribute20) global_attribute20,
                 nvl(ajitf.global_attribute_category,
                     bk.global_attribute_category) global_attribute_category,
                 ajitf.group_asset_id,
                 ajitf.cash_generating_unit_id,
                 bk.period_counter_fully_reserved,
                 bk.period_counter_fully_retired,
                 bk.cash_generating_unit_id
            from fa_adjustments_t ajitf,
                 fa_books bk,
                 fa_additions_b ad
           where ajitf.book_type_code        = p_book_type_code
             and ajitf.posting_status        = 'POST'
             and ajitf.asset_number          = ad.asset_number
             and bk.asset_id              = ad.asset_id
             and bk.book_type_code        = p_book_type_code
             and bk.date_ineffective      is null
             and ad.asset_id > px_max_asset_id
             -- any potenajitfal change in group will be
             -- assigned to the first worker avoiding
             -- the potential locking issues between workers
             and decode(ajitf.group_asset_id,
                        null,
                        MOD(nvl(bk.group_asset_id, ad.asset_id), p_total_requests),
                        0) = (p_request_number - 1)
           order by ad.asset_id;


   cursor check_exp_amort (p_asset_id   in number,
                           p_book       in varchar2) is
    select count(*)
     into l_amort_count
     from fa_books bk
    where bk.book_type_code           = p_book
      and bk.asset_id                 = p_asset_id
      and (bk.rate_Adjustment_factor <> 1 OR
           (bk.rate_adjustment_factor = 1 and
               exists (select 'YES'            -- and amortized before.
                   from fa_transaction_headers th,
                         fa_methods mt
                   where th.book_type_code = bk.book_type_code
                   and  th.asset_id =  bk.asset_id
                   and  th.transaction_type_code = 'ADJUSTMENT'
                   and  (th.transaction_subtype = 'AMORTIZED' OR th.transaction_key = 'UA')
                   and  th.transaction_header_id = bk.transaction_header_id_in
                   and  mt.method_code = bk.deprn_method_code
                   and  mt.rate_source_rule IN ('TABLE','FLAT','PRODUCTION'))));

   -- Exceptions
   done_exc               EXCEPTION;
   data_error             EXCEPTION;
   fapadj_err             EXCEPTION;
   unqualified_asset      EXCEPTION;


BEGIN

   px_max_asset_id := nvl(px_max_asset_id, 0);
   x_success_count := 0;
   x_failure_count := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  fapadj_err;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
       l_debug := TRUE;
   else
       l_debug := FALSE;
   end if;

   if (px_max_asset_id = 0) then

      FND_FILE.put(FND_FILE.output,'');
      FND_FILE.new_line(FND_FILE.output,1);

      -- dump out the headings
      fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_COLUMN');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

      fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_LINE');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;


   -- Get transacajitfon approval and lock the book.
   l_request_id := fnd_global.conc_request_id;

   if (rbs_name is not null) then
       sql_stmt := 'Set Transaction Use Rollback Segment '|| rbs_name;
       execute immediate sql_stmt;
   end if;

   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise fapadj_err ;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

   if (l_debug) then
      fa_debug_pkg.add(l_calling_fn,
                       'performing','fetching upload data', p_log_level_rec => g_log_level_rec);
   end if;

   open c_assets;
   fetch c_assets bulk collect
       into l_itf_rowid                    ,
            l_asset_id                     ,
            l_asset_number                 ,
            l_asset_type                   ,
            l_adjusted_rate                ,
            l_basic_rate                   ,
            l_bonus_rule                   ,
            l_ceiling_name                 ,
            l_cost                         ,
            l_date_placed_in_service       ,
            l_depreciate_flag              ,
            l_deprn_method_code            ,
            l_itc_amount_id                ,
            l_life_in_months               ,
            l_original_cost                ,
            l_production_capacity          ,
            l_prorate_convention_code      ,
            l_salvage_value                ,
            l_short_fiscal_year_flag       ,
            l_conversion_date              ,
            l_original_deprn_start_date    ,
            l_fully_rsvd_revals_counter    ,
            l_unrevalued_cost              ,
            l_reval_ceiling                ,
            l_deprn_reserve                ,
            l_ytd_deprn                    ,
            l_reval_amortization_basis     ,
            l_reval_reserve                ,
            l_ytd_reval_deprn_expense      ,
            l_transaction_subtype          ,
            l_amortization_start_date      ,
            l_transaction_name             ,
            l_attribute1                   ,
            l_attribute2                   ,
            l_attribute3                   ,
            l_attribute4                   ,
            l_attribute5                   ,
            l_attribute6                   ,
            l_attribute7                   ,
            l_attribute8                   ,
            l_attribute9                   ,
            l_attribute10                  ,
            l_attribute11                  ,
            l_attribute12                  ,
            l_attribute13                  ,
            l_attribute14                  ,
            l_attribute15                  ,
            l_attribute_category_code      ,
            l_global_attribute1            ,
            l_global_attribute2            ,
            l_global_attribute3            ,
            l_global_attribute4            ,
            l_global_attribute5            ,
            l_global_attribute6            ,
            l_global_attribute7            ,
            l_global_attribute8            ,
            l_global_attribute9            ,
            l_global_attribute10           ,
            l_global_attribute11           ,
            l_global_attribute12           ,
            l_global_attribute13           ,
            l_global_attribute14           ,
            l_global_attribute15           ,
            l_global_attribute16           ,
            l_global_attribute17           ,
            l_global_attribute18           ,
            l_global_attribute19           ,
            l_global_attribute20           ,
            l_global_attribute_category    ,
            l_group_asset_id               ,
            l_cash_generating_unit_id      ,
            l_prd_counter_fully_reserved   ,
            l_prd_counter_fully_retired    ,
            l_cgu_id
         limit l_batch_size;
   close c_assets;

   if (l_debug) then
      fa_debug_pkg.add(l_calling_fn,
                       'performing','after fetching upload data', p_log_level_rec => g_log_level_rec);
   end if;

   if l_itf_rowid.count = 0 then
      raise done_exc;
   end if;

   for l_loop_count in 1..l_itf_rowid.count loop

      -- set savepoint
      savepoint fapadj_savepoint;

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      l_mesg_name := null;
      fa_srvr_msg.add_message(
          calling_fn => NULL,
          name       => 'FA_SHARED_ASSET_NUMBER',
          token1     => 'NUMBER',
          value1     => l_asset_number(l_loop_count),
                   p_log_level_rec => g_log_level_rec);

      BEGIN

         -- reset the structs to null
         l_trans_rec                    := NULL;
         l_asset_hdr_rec                := NULL;
         l_asset_fin_rec_adj            := NULL;
         l_asset_fin_rec_new            := NULL;
         l_asset_fin_mrc_tbl_new.delete;
         l_inv_trans_rec                := NULL;
         l_inv_tbl.delete;
         l_asset_deprn_rec_adj          := NULL;
         l_asset_deprn_rec_new          := NULL;
         l_asset_deprn_mrc_tbl_new.delete;

         -- reset the who info in trans rec
         l_trans_rec.who_info.last_updated_by    := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.created_by         := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.creation_date      := sysdate;
         l_trans_rec.who_info.last_update_date   := sysdate;
         l_trans_rec.who_info.last_update_login  := FND_GLOBAL.CONC_LOGIN_ID;
         l_trans_rec.mass_reference_id           := p_parent_request_id;
         l_trans_rec.calling_interface           := 'FAPADJ';

         -- counter for the number of assets
         l_count       := l_count + 1;

         if (l_debug) then
            fa_debug_pkg.add(l_calling_fn,
                             'asset_number',l_asset_number(l_loop_count));
            fa_debug_pkg.add(l_calling_fn,
                             'asset_id',l_asset_id(l_loop_count));
         end if;
         -- Retrieve addition_info, to retrieve asset id and shared info
         -- across books for the asset

         -- verify asset is capitalized or group
         if (l_asset_type(l_loop_count) not in ('CAPITALIZED', 'GROUP')) then
             l_mesg_name := 'FA_NO_ASSIGN_CGU_CIP';
             raise unqualified_asset;
         end if;

         -- verify asset is not reserved
        /*Bug 9562001 ..No need to restrict CGU assignment for a fully reserved asset
	if (l_prd_counter_fully_reserved(l_loop_count) is not NULL) then
             l_mesg_name := 'FA_NO_ASSIGN_CGU_RSVD';
             raise unqualified_asset;
         end if;
*/
         -- verify asset is not fully retired
         if (l_prd_counter_fully_retired(l_loop_count) is not NULL) then
             l_mesg_name := 'FA_NO_ASSIGN_CGU_RTRD';
             raise unqualified_asset;
         end if;

         -- verify asset is not already has a cgu assigned
         if (l_cgu_id(l_loop_count) is not NULL) then
             l_mesg_name := 'FA_NO_ASSIGN_CGU_WCGU';
             raise unqualified_asset;
         end if;

         -- set all the structures up with deltas
         l_asset_hdr_rec.asset_id       := l_asset_id(l_loop_count);
         l_asset_hdr_rec.book_type_code := p_book_type_code;

         l_asset_fin_rec_adj.adjusted_rate :=
            l_adjusted_rate(l_loop_count);
         l_asset_fin_rec_adj.basic_rate :=
            l_basic_rate(l_loop_count);
         l_asset_fin_rec_adj.bonus_rule :=
            l_bonus_rule(l_loop_count);
         l_asset_fin_rec_adj.ceiling_name :=
            l_ceiling_name(l_loop_count);
         l_asset_fin_rec_adj.cost :=
            l_cost(l_loop_count);
         l_asset_fin_rec_adj.date_placed_in_service :=
            l_date_placed_in_service(l_loop_count);
         l_asset_fin_rec_adj.depreciate_flag :=
            l_depreciate_flag(l_loop_count);
         l_asset_fin_rec_adj.deprn_method_code :=
            l_deprn_method_code(l_loop_count);
         l_asset_fin_rec_adj.itc_amount_id :=
            l_itc_amount_id(l_loop_count);
         l_asset_fin_rec_adj.life_in_months :=
            l_life_in_months(l_loop_count);
         l_asset_fin_rec_adj.original_cost :=
            l_original_cost(l_loop_count);
         l_asset_fin_rec_adj.production_capacity :=
            l_production_capacity(l_loop_count);
         l_asset_fin_rec_adj.prorate_convention_code :=
            l_prorate_convention_code(l_loop_count);
         l_asset_fin_rec_adj.salvage_value :=
            l_salvage_value(l_loop_count);
         l_asset_fin_rec_adj.short_fiscal_year_flag :=
            l_short_fiscal_year_flag(l_loop_count);
         l_asset_fin_rec_adj.conversion_date :=
            l_conversion_date(l_loop_count);
         l_asset_fin_rec_adj.orig_deprn_start_date :=
            l_original_deprn_start_date(l_loop_count);
         l_asset_fin_rec_adj.fully_rsvd_revals_counter :=
            l_fully_rsvd_revals_counter(l_loop_count);
         l_asset_fin_rec_adj.unrevalued_cost :=
            l_unrevalued_cost(l_loop_count);
         l_asset_fin_rec_adj.reval_ceiling :=
            l_reval_ceiling(l_loop_count);
         l_asset_deprn_rec_adj.deprn_reserve :=
            l_deprn_reserve(l_loop_count);
         l_asset_deprn_rec_adj.ytd_deprn :=
            l_ytd_deprn(l_loop_count);
         l_asset_deprn_rec_adj.reval_amortization_basis :=
            l_reval_amortization_basis(l_loop_count);
         l_asset_deprn_rec_adj.reval_deprn_reserve :=
            l_reval_reserve(l_loop_count);
         l_asset_deprn_rec_adj.reval_ytd_deprn :=
            l_ytd_reval_deprn_expense(l_loop_count);
         l_trans_rec.transaction_subtype :=
            l_transaction_subtype(l_loop_count);
         l_trans_rec.amortization_start_date :=   -- trx date entered?
            l_amortization_start_date(l_loop_count);
         l_trans_rec.transaction_name :=
            l_transaction_name(l_loop_count);
         l_trans_rec.desc_flex.attribute1 :=
            l_attribute1(l_loop_count);
         l_trans_rec.desc_flex.attribute2 :=
            l_attribute2(l_loop_count);
         l_trans_rec.desc_flex.attribute3 :=
            l_attribute3(l_loop_count);
         l_trans_rec.desc_flex.attribute4 :=
            l_attribute4(l_loop_count);
         l_trans_rec.desc_flex.attribute5 :=
            l_attribute5(l_loop_count);
         l_trans_rec.desc_flex.attribute6 :=
            l_attribute6(l_loop_count);
         l_trans_rec.desc_flex.attribute7 :=
            l_attribute7(l_loop_count);
         l_trans_rec.desc_flex.attribute8 :=
            l_attribute8(l_loop_count);
         l_trans_rec.desc_flex.attribute9 :=
            l_attribute9(l_loop_count);
         l_trans_rec.desc_flex.attribute10 :=
            l_attribute10(l_loop_count);
         l_trans_rec.desc_flex.attribute11 :=
            l_attribute11(l_loop_count);
         l_trans_rec.desc_flex.attribute12 :=
            l_attribute12(l_loop_count);
         l_trans_rec.desc_flex.attribute13 :=
            l_attribute13(l_loop_count);
         l_trans_rec.desc_flex.attribute14 :=
            l_attribute14(l_loop_count);
         l_trans_rec.desc_flex.attribute15 :=
            l_attribute15(l_loop_count);
         l_trans_rec.desc_flex.attribute_category_code :=
            l_attribute_category_code(l_loop_count);
         l_asset_fin_rec_adj.global_attribute1 :=
            l_global_attribute1(l_loop_count);
         l_asset_fin_rec_adj.global_attribute2 :=
            l_global_attribute2(l_loop_count);
         l_asset_fin_rec_adj.global_attribute3 :=
            l_global_attribute3(l_loop_count);
         l_asset_fin_rec_adj.global_attribute4 :=
            l_global_attribute4(l_loop_count);
         l_asset_fin_rec_adj.global_attribute5 :=
            l_global_attribute5(l_loop_count);
         l_asset_fin_rec_adj.global_attribute6 :=
            l_global_attribute6(l_loop_count);
         l_asset_fin_rec_adj.global_attribute7 :=
            l_global_attribute7(l_loop_count);
         l_asset_fin_rec_adj.global_attribute8 :=
            l_global_attribute8(l_loop_count);
         l_asset_fin_rec_adj.global_attribute9 :=
            l_global_attribute9(l_loop_count);
         l_asset_fin_rec_adj.global_attribute10 :=
            l_global_attribute10(l_loop_count);
         l_asset_fin_rec_adj.global_attribute11 :=
            l_global_attribute11(l_loop_count);
         l_asset_fin_rec_adj.global_attribute12 :=
            l_global_attribute12(l_loop_count);
         l_asset_fin_rec_adj.global_attribute13 :=
            l_global_attribute13(l_loop_count);
         l_asset_fin_rec_adj.global_attribute14 :=
            l_global_attribute14(l_loop_count);
         l_asset_fin_rec_adj.global_attribute15 :=
            l_global_attribute15(l_loop_count);
         l_asset_fin_rec_adj.global_attribute16 :=
            l_global_attribute16(l_loop_count);
         l_asset_fin_rec_adj.global_attribute17 :=
            l_global_attribute17(l_loop_count);
         l_asset_fin_rec_adj.global_attribute18 :=
            l_global_attribute18(l_loop_count);
         l_asset_fin_rec_adj.global_attribute19 :=
            l_global_attribute19(l_loop_count);
         l_asset_fin_rec_adj.global_attribute20 :=
            l_global_attribute20(l_loop_count);
         l_asset_fin_rec_adj.global_attribute_category:=
            l_global_attribute_category(l_loop_count);
         l_asset_fin_rec_adj.group_asset_id :=
            l_group_asset_id(l_loop_count);
         l_asset_fin_rec_adj.cash_generating_unit_id :=
            l_cash_generating_unit_id(l_loop_count);

         if (l_asset_fin_rec_adj.cash_generating_unit_id is not null) then
            open check_exp_amort(l_asset_hdr_rec.asset_id,l_asset_hdr_rec.book_type_code);
            fetch check_exp_amort into l_amort_count;
            close check_exp_amort;
            if l_amort_count <> 0 then
               l_trans_rec.transaction_subtype := 'AMORTIZED';
            end if;
         end if;

         -- load the current fin and deprn info
         if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_asset_hdr_rec,
                  px_asset_fin_rec        => l_asset_fin_rec_old,
                  p_transaction_header_id => NULL,
                  p_mrc_sob_type_code     => 'P'
                 , p_log_level_rec => g_log_level_rec) then
            raise data_error;
         end if;

         if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec        => l_asset_hdr_rec,
                  px_asset_deprn_rec     => l_asset_deprn_rec_old,
                  p_period_counter       => NULL,
                  p_mrc_sob_type_code    => 'P'
                 , p_log_level_rec => g_log_level_rec) then
            raise data_error;
         end if;

         -- now fetch any exisajitfng catchup expense in fa_adjustments
         -- and account for this when calculaajitfng the old deprn values

         select nvl(sum(decode(debit_credit_flag,
                               'DR', adjustment_amount,
                               -adjustment_amount)), 0)
           into l_deprn_exp_amort_nbv
           from fa_adjustments
          where book_type_code = l_asset_hdr_rec.book_type_code
            and asset_id       = l_asset_hdr_rec.asset_id
           and source_type_code = 'DEPRECIATION'
            and adjustment_type  = 'EXPENSE';


          l_asset_deprn_rec_old.deprn_reserve := l_asset_deprn_rec_old.deprn_reserve -
                                                 l_deprn_exp_amort_nbv;
          l_asset_deprn_rec_old.ytd_deprn     := l_asset_deprn_rec_old.ytd_deprn -
                                                 l_deprn_exp_amort_nbv;

         -- Set all non-calculated and non-method info
         -- the amount columns are delta's so take the difference
         -- between upload value and current value

         if (l_asset_fin_rec_adj.salvage_value is not null) then
            if (l_asset_fin_rec_old.salvage_type = 'AMT') then
               l_asset_fin_rec_adj.salvage_value         := nvl(l_asset_fin_rec_adj.salvage_value,
                                                                l_asset_fin_rec_old.salvage_value) -
                                                                l_asset_fin_rec_old.salvage_value;
            else
               l_asset_fin_rec_adj.salvage_value         := l_asset_fin_rec_adj.salvage_value;
               l_asset_fin_rec_adj.salvage_type          := 'AMT';
            end if;
         end if;


         l_asset_fin_rec_adj.production_capacity         := nvl(l_asset_fin_rec_adj.production_capacity,
                                                                l_asset_fin_rec_old.production_capacity) -
                                                                l_asset_fin_rec_old.production_capacity;
         l_asset_fin_rec_adj.cost                        := nvl(l_asset_fin_rec_adj.cost,
                                                                l_asset_fin_rec_old.cost) -
                                                                l_asset_fin_rec_old.cost;
         l_asset_fin_rec_adj.original_cost               := nvl(l_asset_fin_rec_adj.original_cost,
                                                                l_asset_fin_rec_old.original_cost) -
                                                                l_asset_fin_rec_old.original_cost;
         if (l_asset_fin_rec_adj.unrevalued_cost is not null) then
            l_asset_fin_rec_adj.unrevalued_cost          := l_asset_fin_rec_adj.unrevalued_cost -
                                                            l_asset_fin_rec_old.unrevalued_cost;
         end if;

         l_asset_fin_rec_adj.reval_ceiling               := nvl(l_asset_fin_rec_adj.reval_ceiling,
                                                                l_asset_fin_rec_old.reval_ceiling) -
                                                                l_asset_fin_rec_old.reval_ceiling;
         l_asset_deprn_rec_adj.deprn_reserve             := nvl(l_asset_deprn_rec_adj.deprn_reserve,
                                                                l_asset_deprn_rec_old.deprn_reserve) -
                                                                l_asset_deprn_rec_old.deprn_reserve;
         l_asset_deprn_rec_adj.ytd_deprn                 := nvl(l_asset_deprn_rec_adj.ytd_deprn,
                                                                l_asset_deprn_rec_old.ytd_deprn) -
                                                                l_asset_deprn_rec_old.ytd_deprn;
         l_asset_deprn_rec_adj.reval_amortization_basis  := nvl(l_asset_deprn_rec_adj.reval_amortization_basis,
                                                                l_asset_deprn_rec_old.reval_amortization_basis) -
                                                                l_asset_deprn_rec_old.reval_amortization_basis;
         l_asset_deprn_rec_adj.reval_deprn_reserve       := nvl(l_asset_deprn_rec_adj.reval_deprn_reserve,
                                                                l_asset_deprn_rec_old.reval_deprn_reserve) -
                                                                l_asset_deprn_rec_old.reval_deprn_reserve;
         l_asset_deprn_rec_adj.reval_ytd_deprn           := nvl(l_asset_deprn_rec_adj.reval_ytd_deprn,
                                                                l_asset_deprn_rec_old.reval_ytd_deprn) -
                                                                l_asset_deprn_rec_old.reval_ytd_deprn;

         -- round those values holding currency amounts

         fa_round_pkg.fa_round(l_asset_fin_rec_adj.salvage_value,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_fin_rec_adj.cost,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_fin_rec_adj.original_cost,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_fin_rec_adj.unrevalued_cost,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_fin_rec_adj.reval_ceiling,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_deprn_rec_adj.deprn_reserve,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_deprn_rec_adj.ytd_deprn,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_deprn_rec_adj.reval_amortization_basis,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_deprn_rec_adj.reval_deprn_reserve,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_round_pkg.fa_round(l_asset_deprn_rec_adj.reval_ytd_deprn,
                               p_book_type_code, p_log_level_rec => g_log_level_rec);

         -- set up other needed struct values
         l_trans_rec.mass_reference_id := l_request_id;

         -- perform the Adjustment
         fa_adjustment_pub.do_adjustment
            (p_api_version             => l_api_version,
             p_init_msg_list           => l_init_msg_list,
             p_commit                  => l_commit,
             p_validation_level        => l_validation_level,
             x_return_status           => l_return_status,
             x_msg_count               => l_mesg_count,
             x_msg_data                => l_mesg,
             p_calling_fn              => l_calling_fn,
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
            raise data_error;
         end if;

         -- flag interface record as posted
         update fa_adjustments_t
            set posting_status   = 'POSTED',
                request_id   = l_request_id
          where rowid            = l_itf_rowid(l_loop_count);

         -- Increment asset count and dump asset_number to the log file
         x_success_count := x_success_count + 1;
         write_message(l_asset_number(l_loop_count),
                       'FA_MCP_ADJUSTMENT_SUCCESS');

         if (l_debug) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         end if;


      EXCEPTION -- exceptions

         when data_error then
            x_failure_count := x_failure_count + 1;

            write_message(l_asset_number(l_loop_count),
                          l_mesg_name);

            if (l_debug) then
                fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            update fa_adjustments_t
            set posting_status   = 'ERROR',
                request_id   = l_request_id
            where rowid      = l_itf_rowid(l_loop_count);

         when unqualified_asset then
            write_message(l_asset_number(l_loop_count),
                          l_mesg_name);

            if (l_debug) then
                fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            update fa_adjustments_t
            set posting_status   = 'WARNING',
                request_id   = l_request_id
            where rowid      = l_itf_rowid(l_loop_count);

         when others then
            x_failure_count := x_failure_count + 1;

            write_message(l_asset_number(l_loop_count),
                          'FA_PADJI_FAIL_TRX');
            fa_srvr_msg.add_sql_error(
                 calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

            if (l_debug) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            update fa_adjustments_t
            set posting_status   = 'ERROR',
                request_id   = l_request_id
            where rowid      = l_itf_rowid(l_loop_count);

      END;    -- end

      -- commit every batch and reset the large rollback segment
      COMMIT WORK;

   end loop; -- inner loop to loop through arrays

   px_max_asset_id := l_asset_id(l_asset_id.count);
   x_return_status := 0;

EXCEPTION
   when done_exc then
      x_return_status := 0;

   when fapadj_err then
      ROLLBACK WORK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- Dump Debug messages when run in debug mode to log file
      if (l_debug) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;

   when others then
      ROLLBACK WORK;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- Dump Debug messages when run in debug mode to log file
      if (l_debug) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;


END fapadji;   -- end

-----------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2) IS

   l_message      varchar2(30);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);   -- condiajitfonally populated below

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd
   l_message := nvl(p_message,  'FA_PADJI_FAIL_TRX');

   l_calling_fn := 'FA_POST_ADJ_ITF_PKG.fapadji';

   fnd_message.set_name('OFA', l_message);
   l_mesg := substrb(fnd_message.get, 1, 100);

   l_string       := rpad(p_asset_number, 15) || ' ' || l_mesg;

   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

   -- now process the messages for the log file
   fa_srvr_msg.add_message
       (calling_fn => l_calling_fn,
        name       => l_message, p_log_level_rec => g_log_level_rec);

EXCEPTION
   when others then
       raise;

END write_message;

END FA_POST_ADJ_ITF_PKG;

/
