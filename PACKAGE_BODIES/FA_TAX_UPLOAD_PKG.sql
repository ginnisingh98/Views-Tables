--------------------------------------------------------
--  DDL for Package Body FA_TAX_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TAX_UPLOAD_PKG" as
/* $Header: fataxupb.pls 120.19.12010000.6 2010/03/04 17:03:37 spooyath ship $   */

TYPE g_msg_err_rec IS RECORD(asset_number      VARCHAR2(30)
                            ,exception_code    VARCHAR2(10)
                            );
TYPE g_msg_err_tbl IS TABLE OF g_msg_err_rec INDEX BY BINARY_INTEGER;

g_err_msg    g_msg_err_tbl;
g_count      binary_integer := 1;
g_log_level_rec fa_api_types.log_level_rec_type;

g_release                  number  := fa_cache_pkg.fazarel_release;

----------------------------------------------------------------
-- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam
----------------------------------------------------------------
PROCEDURE faxtaxup(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number ) IS

   -- messaging
   l_batch_size                   NUMBER;
   l_loop_count                   NUMBER;
   l_count                        NUMBER := 0;
   p_msg_count                    NUMBER := 0;
   p_msg_data                     VARCHAR2(512);
   l_name                         VARCHAR2(30);
   l_temp                         VARCHAR2(30);

   -- misc
   l_debug                        boolean;
   l_request_id                   NUMBER;
   l_trx_approval                 BOOLEAN;
   sql_stmt                       VARCHAR2(101);
   l_status                       VARCHAR2(1);
   l_result                       BOOLEAN := TRUE;

   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
   lc_error_flag       VARCHAR2(10);
   l_asset_num         VARCHAR2(100);
   l_exception_err     VARCHAR2(100);
   --Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

   -- types
   TYPE rowid_tbl  IS TABLE OF VARCHAR2(50)  INDEX BY BINARY_INTEGER;
   TYPE number_tbl IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
   TYPE date_tbl   IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
   TYPE v30_tbl    IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

   -- used for main cursor

   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
   l_nbv_at_switch                number_tbl;
   l_prior_deprn_limit_amount     number_tbl;
   l_period_full_reserve          v30_tbl;
   l_prior_deprn_method           v30_tbl;
   l_period_extd_deprn            v30_tbl;
   l_prior_deprn_limit            number_tbl;
   l_prior_basic_rate             number_tbl;
   l_prior_adjusted_rate          number_tbl;
   l_prior_life_in_months         number_tbl;
   l_prior_deprn_limit_type       v30_tbl;
   ln_err_cnt                     number := 0;

   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

   l_tax_rowid                    rowid_tbl;
   l_asset_id                     number_tbl;
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

   -- used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_mesg_count                   number;
   l_mesg                         VARCHAR2(4000);
   l_mesg_name                    VARCHAR2(30);

   l_calling_fn                   VARCHAR2(30) := 'fa_tax_upload_pkg.faxtaxup';
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

   --Bug# 7608030 start
   l_p_rsv_counter         number;
   l_ext_period_counter    number;
   l_fiscal_yr             number;
   l_period_num            number;
   l_num_fy_yr             number;
   l_period_end_dt         date;
   l_current_period_dt     date;
   l_default_dt            date := to_date('01-04-2007','DD-MM-RRRR');
   --#Bug 7608030 end

   CURSOR c_assets IS
          select ti.rowid,
                 ti.asset_id,
                 ti.asset_number,
                 ti.asset_type,
                 ti.adjusted_rate,
                 ti.basic_rate,
                 ti.bonus_rule,
                 ti.ceiling_name,
                 ti.cost,
                 ti.date_placed_in_service,
                 ti.depreciate_flag,
                 ti.deprn_method_code,
                 ti.itc_amount_id,
                 ti.life_in_months,
                 ti.original_cost,
                 ti.production_capacity,
                 ti.prorate_convention_code,
                 ti.salvage_value,
                 ti.short_fiscal_year_flag,
                 ti.conversion_date,
                 ti.original_deprn_start_date,
                 ti.fully_rsvd_revals_counter,
                 ti.unrevalued_cost,
                 ti.reval_ceiling,
                 ti.deprn_reserve,
                 ti.ytd_deprn,
                 ti.reval_amortization_basis,
                 ti.reval_reserve,
                 ti.ytd_reval_deprn_expense,
                 decode(ti.amortize_nbv_flag,
                        'YES', 'AMORTIZED',
                        'EXPENSED')  transaction_subtype,
                 ti.amortization_start_date,
                 nvl(ti.transaction_name, 'Tax Upload Interface') transaction_name,
                 ti.attribute1,
                 ti.attribute2,
                 ti.attribute3,
                 ti.attribute4,
                 ti.attribute5,
                 ti.attribute6,
                 ti.attribute7,
                 ti.attribute8,
                 ti.attribute9,
                 ti.attribute10,
                 ti.attribute11,
                 ti.attribute12,
                 ti.attribute13,
                 ti.attribute14,
                 ti.attribute15,
                 ti.attribute_category_code,
                 nvl(ti.global_attribute1,
                     bk.global_attribute1) global_attribute1,
                 nvl(ti.global_attribute2,
                     bk.global_attribute2) global_attribute2,
                 nvl(ti.global_attribute3,
                     bk.global_attribute3) global_attribute3,
                 nvl(ti.global_attribute4,
                     bk.global_attribute4) global_attribute4,
                 nvl(ti.global_attribute5,
                     bk.global_attribute5) global_attribute5,
                 nvl(ti.global_attribute6,
                     bk.global_attribute6) global_attribute6,
                 nvl(ti.global_attribute7,
                     bk.global_attribute7) global_attribute7,
                 nvl(ti.global_attribute8,
                     bk.global_attribute8) global_attribute8,
                 nvl(ti.global_attribute9,
                     bk.global_attribute9) global_attribute9,
                 nvl(ti.global_attribute10,
                     bk.global_attribute10) global_attribute10,
                 nvl(ti.global_attribute11,
                     bk.global_attribute11) global_attribute11,
                 nvl(ti.global_attribute12,
                     bk.global_attribute12) global_attribute12,
                 nvl(ti.global_attribute13,
                     bk.global_attribute13) global_attribute13,
                 nvl(ti.global_attribute14,
                     bk.global_attribute14) global_attribute14,
                 nvl(ti.global_attribute15,
                     bk.global_attribute15) global_attribute15,
                 nvl(ti.global_attribute16,
                     bk.global_attribute16) global_attribute16,
                 nvl(ti.global_attribute17,
                     bk.global_attribute17) global_attribute17,
                 nvl(ti.global_attribute18,
                     bk.global_attribute18) global_attribute18,
                 nvl(ti.global_attribute19,
                     bk.global_attribute19) global_attribute19,
                 nvl(ti.global_attribute20,
                     bk.global_attribute20) global_attribute20,
                 nvl(ti.global_attribute_category,
                     bk.global_attribute_category) global_attribute_category,
                 ti.group_asset_id,
                 ti.nbv_at_switch,             -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
                 ti.prior_deprn_limit_amount,
                 ti.period_full_reserve,
                 ti.prior_deprn_method,
                 ti.period_extd_deprn,
                 ti.prior_deprn_limit,
                 ti.prior_basic_rate,
                 ti.prior_adjusted_rate,
                 ti.prior_life_in_months,
                 ti.prior_deprn_limit_type   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End
            from fa_tax_interface ti,
                 fa_books bk
           where ti.book_type_code             = p_book_type_code
             and ti.posting_status             = 'POST'
             and ti.tax_request_id             = p_parent_request_id
             and ti.worker_id                  = p_request_number
             and bk.asset_id                   = ti.asset_id
             and bk.book_type_code             = p_book_type_code
             and bk.transaction_header_id_out is null
           order by ti.asset_id;

  -- Bug 7698030 start open period
  cursor l_curr_open_period(p_book_type_code in varchar2
                           )
  is
  select fdp.calendar_period_close_date
  from fa_book_controls fbc
      ,fa_deprn_periods fdp
  where fbc.book_type_code = fdp.book_type_code
  and   fdp.period_counter = fbc.last_period_counter+1
  and   fbc.book_type_code =  p_book_type_code;

  --7608030 full reserv counter
  cursor l_period_info(p_book_type_code in varchar2
                      ,p_period         in varchar2
                      )
  is
  select fcp.end_date
        ,ffy.fiscal_year
        ,fcp.period_num
        ,fct.number_per_fiscal_year
  from fa_fiscal_year      ffy
      ,fa_book_controls    fbc
      ,fa_calendar_periods fcp
      ,fa_calendar_types   fct
  where ffy.fiscal_year_name = fbc.fiscal_year_name
  and ffy.fiscal_year_name   = fct.fiscal_year_name
  and fbc.book_type_code     = p_book_type_code
  and fcp.calendar_type      = fct.calendar_type
  and fct.calendar_type      = fbc.deprn_calendar
  and fcp.start_date        >= ffy.start_date
  and fcp.end_date          <= ffy.end_date
  and upper(fcp.period_name) = upper(p_period);

    --Bug 7698030 end

   -- Exceptions
   done_exc               EXCEPTION;
   data_error             EXCEPTION;
   faxtaxup_err           EXCEPTION;
   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
   l_japan_tax_reform   varchar2(1) := fnd_profile.value('FA_JAPAN_TAX_REFORMS');
   l_extended_deprn_period        number;
   l_pc_fully_reserved            number;
   l_limit_amt                    number;
   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

	--Added for 9371739
   l_book_ytd NUMBER := 0;
   l_book_rsv NUMBER := 0;

BEGIN  <<taxupload_main>>

   px_max_asset_id := nvl(px_max_asset_id, 0);
   x_success_count := 0;
   x_failure_count := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise faxtaxup_err;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;


   if (g_log_level_rec.statement_level) then
       l_debug := TRUE;
   else
       l_debug := FALSE;
   end if;

   -- Get transaction approval and lock the book.
   l_request_id := fnd_global.conc_request_id;

   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise faxtaxup_err ;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

   if (l_debug) then
      fa_debug_pkg.add(l_calling_fn,
                       'performing','fetching upload data', p_log_level_rec => g_log_level_rec);
   end if;

   open c_assets;
   fetch c_assets bulk collect
       into l_tax_rowid                    ,
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
            l_nbv_at_switch                , -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
            l_prior_deprn_limit_amount     ,
            l_period_full_reserve          ,
            l_prior_deprn_method           ,
            l_period_extd_deprn            ,
            l_prior_deprn_limit            ,
            l_prior_basic_rate             ,
            l_prior_adjusted_rate          ,
            l_prior_life_in_months         ,
            l_prior_deprn_limit_type         -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End
         limit l_batch_size;
   close c_assets;

   if (l_debug) then
      fa_debug_pkg.add(l_calling_fn,
                       'performing','after fetching upload data', p_log_level_rec => g_log_level_rec);
   end if;

   if l_tax_rowid.count = 0 then
      raise done_exc;
   end if;

   for l_loop_count in 1..l_tax_rowid.count loop

      -- set savepoint
      savepoint taxup_savepoint;

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      l_mesg_name := null;
      fa_srvr_msg.add_message(
          calling_fn => NULL,
          name       => 'FA_SHARED_ASSET_NUMBER',
          token1     => 'NUMBER',
          value1     => l_asset_number(l_loop_count),
          p_log_level_rec => g_log_level_rec);

      <<taxupload_records>>
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
         l_trans_rec.calling_interface           := 'FATAXUP';



         -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
         if l_deprn_method_code(l_loop_count) like 'JP-250DB%' then
           l_asset_fin_rec_adj.nbv_at_switch            := l_nbv_at_switch(l_loop_count);
           l_asset_fin_rec_adj.period_full_reserve      := l_period_full_reserve(l_loop_count);
           l_asset_fin_rec_adj.prior_deprn_limit_amount := NULL;
           l_asset_fin_rec_adj.prior_deprn_method       := NULL;
           l_asset_fin_rec_adj.period_extd_deprn        := NULL;
           l_asset_fin_rec_adj.prior_deprn_limit        := NULL;
           l_asset_fin_rec_adj.prior_basic_rate         := NULL;
           l_asset_fin_rec_adj.prior_adjusted_rate      := NULL;
           l_asset_fin_rec_adj.prior_life_in_months     := NULL;
           l_asset_fin_rec_adj.prior_deprn_limit_type   := NULL;
         elsif l_deprn_method_code(l_loop_count) = 'JP-STL-EXTND' then
           l_asset_fin_rec_adj.nbv_at_switch            := NULL;
           l_asset_fin_rec_adj.period_full_reserve      := l_period_full_reserve(l_loop_count);
           l_asset_fin_rec_adj.prior_deprn_limit_amount := l_prior_deprn_limit_amount(l_loop_count);
           l_asset_fin_rec_adj.prior_deprn_method       := l_prior_deprn_method(l_loop_count);
           l_asset_fin_rec_adj.period_extd_deprn        := l_period_extd_deprn(l_loop_count);
           l_asset_fin_rec_adj.prior_deprn_limit        := l_prior_deprn_limit(l_loop_count);
           l_asset_fin_rec_adj.prior_basic_rate         := l_prior_basic_rate(l_loop_count);
           l_asset_fin_rec_adj.prior_adjusted_rate      := l_prior_adjusted_rate(l_loop_count);
           l_asset_fin_rec_adj.prior_life_in_months     := l_prior_life_in_months(l_loop_count);
           l_asset_fin_rec_adj.prior_deprn_limit_type   := l_prior_deprn_limit_type(l_loop_count);
           if l_prior_deprn_limit_type(l_loop_count) = 'AMT' then
             l_asset_fin_rec_adj.prior_deprn_limit  := NULL;
           elsif l_prior_deprn_limit_type(l_loop_count) = 'PCT' then
             l_asset_fin_rec_adj.prior_deprn_limit_amount := NULL;
           else
             l_asset_fin_rec_adj.prior_deprn_limit        := NULL;
             l_asset_fin_rec_adj.prior_deprn_limit_amount := NULL;
           end if;
         else
           l_asset_fin_rec_adj.nbv_at_switch            := l_nbv_at_switch(l_loop_count);
           l_asset_fin_rec_adj.period_full_reserve      := l_period_full_reserve(l_loop_count);
           l_asset_fin_rec_adj.prior_deprn_limit_amount := NULL;
           l_asset_fin_rec_adj.prior_deprn_method       := NULL;
           l_asset_fin_rec_adj.period_extd_deprn        := NULL;
           l_asset_fin_rec_adj.prior_deprn_limit        := NULL;
           l_asset_fin_rec_adj.prior_basic_rate         := NULL;
           l_asset_fin_rec_adj.prior_adjusted_rate      := NULL;
           l_asset_fin_rec_adj.prior_life_in_months     := NULL;
           l_asset_fin_rec_adj.prior_deprn_limit_type   := NULL;
         end if;
         -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

         -- counter for the number of assets
         l_count       := l_count + 1;

         if (l_debug) then
            fa_debug_pkg.add(l_calling_fn,
                             'asset_number',l_asset_number(l_loop_count));
            fa_debug_pkg.add(l_calling_fn,
                             'asset_id',l_asset_id(l_loop_count));
         end if;
         -- Retrieve additions_info, to retrieve asset id and shared info
         -- across books for the asset

         -- verify asset is capitalized
         if (l_asset_type(l_loop_count) not in ('CAPITALIZED', 'GROUP')) then
             l_mesg_name := 'FA_NO_TAX_UPLOAD_CIP';
             raise data_error;
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

         -- Bug 6803812: Check whether it is period of addition
         if not FA_ASSET_VAL_PVT.validate_period_of_addition
                 (p_asset_id            => l_asset_hdr_rec.asset_id,
                  p_book                => l_asset_hdr_rec.book_type_code,
                  p_mode                => 'ABSOLUTE',
                  px_period_of_addition => l_asset_hdr_rec.period_of_addition,
                  p_log_level_rec     => g_log_level_rec) then
            raise data_error;
         end if;

         if (l_asset_hdr_rec.period_of_addition <> 'Y' or
             G_release = 11) then
            -- now fetch any existing catchup expense in fa_adjustments
            -- and account for this when calculating the old deprn values
            -- only if it is not in period of addition

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
         end if;

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


         -- Changes made as per the ER No.s 6606548 and 6606552
         -- Bug 8722521 : Moved the validations to FAVCALB.pls
         if l_japan_tax_reform = 'Y' then

            -- Bug 9244648 : pc_fully_reserved should be populated
            -- for all the methods
            if l_period_full_reserve(l_loop_count) is not null then
               l_period_end_dt := null;
               l_period_num    := null;
               l_num_fy_yr     := null;
               l_p_rsv_counter := null;
               open l_period_info(p_book_type_code
                                 ,l_period_full_reserve(l_loop_count));
               fetch l_period_info into l_period_end_dt
                            ,l_fiscal_yr
                            ,l_period_num
                            ,l_num_fy_yr;
               close l_period_info;

               if l_fiscal_yr is null then
                  raise data_error;
               end if;

               l_p_rsv_counter := (l_fiscal_yr * l_num_fy_yr) + l_period_num;
               l_asset_fin_rec_adj.period_counter_fully_reserved := l_p_rsv_counter;
               IF l_asset_fin_rec_adj.period_counter_life_complete IS NULL AND
                  l_p_rsv_counter IS NOT NULL THEN
                  l_asset_fin_rec_adj.period_counter_life_complete  := l_p_rsv_counter;
               END IF;
            end if;

            if l_deprn_method_code(l_loop_count)='JP-STL-EXTND' then

               -- Start extd deprn period
               l_period_end_dt      := null;
               l_period_num         := null;
               l_period_end_dt      := null;
               l_num_fy_yr          := null;
               l_ext_period_counter := null;
               open l_period_info(p_book_type_code
                                 ,l_period_extd_deprn(l_loop_count));
               fetch l_period_info into l_period_end_dt
                                       ,l_fiscal_yr
                                       ,l_period_num
                                       ,l_num_fy_yr;
               close l_period_info;

               l_ext_period_counter := (l_fiscal_yr * l_num_fy_yr) + l_period_num; --  end
               l_asset_fin_rec_adj.extended_depreciation_period  := l_ext_period_counter;

               l_asset_fin_rec_adj.deprn_limit_type           := 'AMT';
               l_asset_fin_rec_adj.allowed_deprn_limit_amount := 1;
               l_asset_fin_rec_adj.allowed_deprn_limit        := null;
               l_asset_fin_rec_adj.extended_deprn_flag := 'Y';
               if l_prior_deprn_limit_type(l_loop_count) = 'PCT' then
                  l_limit_amt := (l_prior_deprn_limit(l_loop_count))*nvl(l_cost(l_loop_count),0);
                  l_limit_amt := nvl(l_cost(l_loop_count),0) - l_limit_amt;
                  l_asset_fin_rec_adj.prior_deprn_limit_amount := l_limit_amt;
               end if;
            end if;
         end if; -- Japan profile option enable if end
         --Changes made as per the ER No.s 6606548 and 6606552

         -- Bug 6795070 : l_asset_fin_rec_adj.reval_amortization_basis also
          -- needs to be populated before calling adj api
          l_asset_fin_rec_adj.reval_amortization_basis := l_asset_deprn_rec_adj.reval_amortization_basis;

         -- set up other needed struct values
         l_trans_rec.mass_reference_id := l_request_id;

         --Change for 9371739
         IF ((l_deprn_reserve(l_loop_count) <> 0) OR (l_ytd_deprn(l_loop_count) <> 0)) AND
            (l_asset_hdr_rec.period_of_addition = 'Y') AND
				(l_asset_deprn_rec_old.deprn_reserve = l_deprn_reserve(l_loop_count)) AND
            (l_asset_type(l_loop_count) = 'CAPITALIZED')THEN

             BEGIN

               SELECT ytd_deprn,deprn_reserve
                 INTO l_book_ytd,l_book_rsv
                 FROM fa_deprn_summary
                WHERE asset_id = l_asset_hdr_rec.asset_id
                  AND book_type_code = l_asset_hdr_rec.book_type_code
                  AND deprn_source_code = 'BOOKS';

             EXCEPTION
             WHEN OTHERS THEN
               RAISE data_error;
             END;

             IF (l_book_ytd = 0 ) OR (l_book_rsv = 0) THEN
                l_asset_deprn_rec_adj.allow_taxup_flag := TRUE;
             END IF;

         END IF;
         --end of change for 9371739

         -- perform the Adjustment
         fa_adjustment_pub.do_adjustment
            (p_api_version               => l_api_version,
             p_init_msg_list             => l_init_msg_list,
             p_commit                    => l_commit,
             p_validation_level          => l_validation_level,
             x_return_status             => l_return_status,
             x_msg_count                 => l_mesg_count,
             x_msg_data                  => l_mesg,
             p_calling_fn                => l_calling_fn,
             px_trans_rec                => l_trans_rec,
             px_asset_hdr_rec            => l_asset_hdr_rec,
             p_asset_fin_rec_adj         => l_asset_fin_rec_adj,
             x_asset_fin_rec_new         => l_asset_fin_rec_new,
             x_asset_fin_mrc_tbl_new     => l_asset_fin_mrc_tbl_new,
             px_inv_trans_rec            => l_inv_trans_rec,
             px_inv_tbl                  => l_inv_tbl,
             p_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
             x_asset_deprn_rec_new       => l_asset_deprn_rec_new,
             x_asset_deprn_mrc_tbl_new   => l_asset_deprn_mrc_tbl_new,
             p_group_reclass_options_rec => l_group_reclass_options_rec
            );

         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise data_error;
         end if;

         -- flag interface record as posted
         update fa_tax_interface
            set posting_status   = 'POSTED',
                tax_request_id   = l_request_id
          where rowid            = l_tax_rowid(l_loop_count);

         -- Increment asset count and dump asset_number to the log file
         x_success_count := x_success_count + 1;
         write_message(l_asset_number(l_loop_count),
                       'FA_MCP_ADJUSTMENT_SUCCESS');

         if (l_debug) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         end if;


      EXCEPTION -- exceptions for taxupload_records block

         when data_error then
            x_failure_count := x_failure_count + 1;

            write_message(l_asset_number(l_loop_count),
                          l_mesg_name);

            if (l_debug) then
                fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            rollback to savepoint taxup_savepoint;

            -- flag interface record as failed
            update fa_tax_interface
               set posting_status   = 'ERROR',
                   tax_request_id   = l_request_id
             where rowid            = l_tax_rowid(l_loop_count);
         when others then
            x_failure_count := x_failure_count + 1;

            write_message(l_asset_number(l_loop_count),
                          'FA_TAXUP_FAIL_TRX');
            fa_srvr_msg.add_sql_error(
                 calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

            if (l_debug) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            rollback to savepoint taxup_savepoint;

            -- flag interface record as failed
            update fa_tax_interface
               set posting_status   = 'ERROR',
                   tax_request_id   = l_request_id
             where rowid            = l_tax_rowid(l_loop_count);

      END;    -- end taxupload_records block

      -- FND_CONCURRENT.AF_COMMIT every batch and reset the large rollback segment
      FND_CONCURRENT.AF_COMMIT;

   end loop; -- inner loop to loop through arrays


   px_max_asset_id := l_asset_id(l_asset_id.count);
   x_return_status := 0;

EXCEPTION
   when done_exc then
      x_return_status := 0;

   when faxtaxup_err then
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- Dump Debug messages when run in debug mode to log file
      if (l_debug) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;

   when others then
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- Dump Debug messages when run in debug mode to log file
      if (l_debug) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;

END faxtaxup;   -- end taxupload_main block

-----------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2) IS

   l_message      varchar2(30);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);   -- conditionally populated below

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   l_message := nvl(p_message,  'FA_TAXUP_FAIL_TRX');

   if (l_message <> 'FA_MCP_ADJUSTMENT_SUCCESS') then
      l_calling_fn := 'fa_masschg_pkg.do_mass_change';
   end if;



   -- now process the messages for the log file
   fa_srvr_msg.add_message
       (calling_fn => l_calling_fn,
        name       => l_message, p_log_level_rec => g_log_level_rec);

EXCEPTION
   when others then
       raise;

END write_message;

----------------------------------------------------------------

-- This function will select all candidate lines in a single
-- shot (no longer distinguishes between parent / child). The primary
-- cursors have removed MOD logic
-- We will only stripe the worker number based on the following order:
--
-- In the initial phase, we will use a mod as before with precedence:
--      group / non-group
--


PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER) IS

   -- Used for bulk fetching
   l_batch_size                  number;

   l_rowid_tbl                   char_tbl_type ;
   l_group_asset_id_tbl          num_tbl_type ;
   l_worker_id_tbl               num_tbl_type ;
   l_asset_id_tbl                num_tbl_type  ;
   l_asset_type_tbl              char_tbl_type  ;

   cursor c_group_asset is
   select tax.rowid,
          nvl(tax.group_asset_id,
              bk.group_asset_id)
     from fa_tax_interface tax,
          fa_additions_b ad,
          fa_books bk
    where tax.book_type_code   = p_book_type_code
      and tax.posting_status   = 'POST'
      and tax.asset_number     = ad.asset_number
      and bk.asset_id          = ad.asset_id
      and bk.book_type_code    = p_book_type_code
      and bk.transaction_header_id_out is null;

   cursor c_tax_interface is
   select tax.rowid,
          mod(nvl(tax.group_asset_id,
                  nvl(ad.asset_id, 1)), p_total_requests) + 1,
          nvl(ad.asset_id, 1),
          ad.asset_type
     from fa_tax_interface tax,
          fa_additions_b   ad
    where tax.book_type_code   = p_book_type_code
      and tax.posting_status   = 'POST'
      and ad.asset_number(+)   = tax.asset_number;

   taxup_err                  exception;
   l_calling_fn               varchar2(40) := 'fa_tax_upload_pkg.allocate_workers';

BEGIN


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise taxup_err;
      end if;
   end if;

   if(g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,  'at beginning of', 'worker allocation', p_log_level_rec => g_log_level_rec);
   end if;

   x_return_status := 0;

   -- get corp book information
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise taxup_err;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);


   -- update the group asset if applicable and currently null
   if (fa_cache_pkg.fazcbc_record.allow_group_deprn_flag = 'Y') then

      open c_group_asset;

      loop

         fetch c_group_asset bulk collect
          into l_rowid_tbl,
               l_group_asset_id_tbl
         limit l_batch_size;

         if (l_rowid_tbl.count = 0) then
            exit;
         end if;

         forall i in 1..l_rowid_tbl.count
         update fa_tax_interface
            set group_asset_id = l_group_asset_id_tbl(i)
          where rowid          = l_rowid_tbl(i);

       end loop;

   end if;


   -- now assign the workers
   open c_tax_interface;

   loop

      fetch c_tax_interface bulk collect
        into l_rowid_tbl,
             l_worker_id_tbl,
             l_asset_id_tbl,
             l_asset_type_tbl
       limit l_batch_size;

      if (l_rowid_tbl.count = 0) then
         exit;
      end if;

      forall i in 1..l_rowid_tbl.count
      update fa_tax_interface
         set asset_id   = l_asset_id_tbl(i),
             asset_type = l_asset_type_tbl(i),
             worker_id  = l_worker_id_tbl(i),
             tax_request_id = p_parent_request_id
       where rowid      = l_rowid_tbl(i);

      -- need to add check for valid asset here...
      -- if outer joins fails to find asset, list it here so we
      -- don't have to outer join in the first query


   end loop;

   close c_tax_interface;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows updated into fa_tax_interface', sql%rowcount);
   end if;

   FND_CONCURRENT.AF_COMMIT;

   x_return_status := 0;

EXCEPTION
   WHEN taxup_err THEN
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      X_return_status := 2;

   WHEN OTHERS THEN
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;

END allocate_workers;

END FA_TAX_UPLOAD_PKG;

/
