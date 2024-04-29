--------------------------------------------------------
--  DDL for Package Body FA_MASSCHG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSCHG_PKG" as
/* $Header: FAMACHB.pls 120.18.12010000.5 2009/10/23 05:44:09 bmaddine ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE do_mass_change (
                p_mass_change_id     IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number) IS

   -- used for bulk fetching
   l_batch_size                 number;
   l_loop_count                 number;

   -- local variables
   l_count                      number;
   l_request_id                 number := -1;
   l_userid                     number := -1;
   l_login                      number := -1;
   l_trx_approval               boolean;
   l_masschg_status             varchar2(10);
   l_book_type_code             varchar2(30);
   l_uom_change                 boolean;
   l_period_of_addition         varchar2(1);

   -- used for method cache
   l_from_rsr                     VARCHAR2(10);
   l_to_rsr                       VARCHAR2(10);

   -- local variables
   TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
   TYPE date_tbl IS TABLE OF DATE         INDEX BY BINARY_INTEGER;


   l_asset_number               v30_tbl;
   l_asset_id                   num_tbl;
   l_conversion_date            date_tbl;
   l_date_effective             date_tbl;
   l_date_placed_in_service     date_tbl;
   l_group_asset_id             num_tbl;

   l_from_convention            varchar2(10);
   l_to_convention              varchar2(10);
   l_from_method_code           varchar2(12);
   l_to_method_code             varchar2(12);
   l_from_life_in_months        number;
   l_to_life_in_months          number;
   l_from_bonus_rule            varchar2(30);
   l_to_bonus_rule              varchar2(30);
   l_mass_date_effective        date;
   l_trx_date_entered           date;
   l_from_basic_rate            number;
   l_to_basic_rate              number;
   l_from_adjusted_rate         number;
   l_to_adjusted_rate           number;
   l_from_production_capacity   number;
   l_to_production_capacity     number;
   l_from_uom                   varchar2(25);
   l_to_uom                     varchar2(25);
   l_from_group_association     varchar2(30);
   l_to_group_association       varchar2(30);
   l_from_group_asset_id        number;
   l_to_group_asset_id          number;
   l_asset_type                 varchar2(30);
   l_amortize_flag              varchar2(1);
   l_allow_overlapping_adj_flag varchar2(1);

   l_from_salvage_type          varchar2(30);
   l_to_salvage_type            varchar2(30);
   l_from_percent_salvage_value number;
   l_to_percent_salvage_value   number;
   l_from_salvage_value         number;
   l_to_salvage_value           number;
   l_from_deprn_limit_type      varchar2(30);
   l_to_deprn_limit_type        varchar2(30);
   l_from_deprn_limit           number;
   l_to_deprn_limit             number;
   l_from_deprn_limit_amount    number;
   l_to_deprn_limit_amount      number;

   l_amortization_start_date      date;
   l_old_amortization_start_date  date;
   l_trxs_exist                   varchar2(1);


   -- variables and structs used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_mesg_count                   number;
   l_mesg                         VARCHAR2(4000);
   l_calling_fn                   VARCHAR2(30) := 'fa_masschg_pkg.do_mass_change';
   l_string                       varchar2(250);

   l_old_salvage_type             varchar2(30);
   l_old_percent_salvage_value    number;
   l_old_salvage_value            number;
   l_old_deprn_limit_type         varchar2(30);
   l_old_deprn_limit              number;
   l_old_deprn_limit_amount       number;

   l_period_rec                   FA_API_TYPES.period_rec_type;
   l_asset_fin_rec_old            FA_API_TYPES.asset_fin_rec_type;

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

   l_mesg_name                    VARCHAR2(30);

   -- mass change info
   cursor c_mass_change_info is
        select mch.status,
               mch.from_convention,
               mch.to_convention,
               mch.from_method_code,
               mch.to_method_code,
               mch.from_life_in_months,
               mch.to_life_in_months,
               mch.from_bonus_rule,
               mch.to_bonus_rule,
               mch.date_effective,
               mch.transaction_date_entered,
               mch.from_basic_rate,
               mch.to_basic_rate,
               mch.from_adjusted_rate,
               mch.to_adjusted_rate,
               mch.from_production_capacity,
               mch.to_production_capacity,
               mch.from_uom,
               mch.to_uom,
               mch.from_group_association,
               mch.to_group_association,
               mch.from_group_asset_id,
               mch.to_group_asset_id,
               mch.asset_type,
               mch.amortize_flag,
               mch.book_type_code,
               -- ,mch.allow_overlapping_adj_flag`
               mch.from_salvage_type,
               mch.to_salvage_type,
               mch.from_percent_salvage_value,
               mch.to_percent_salvage_value,
               mch.from_salvage_value,
               mch.to_salvage_value,
               mch.from_deprn_limit_type,
               mch.to_deprn_limit_type,
               mch.from_deprn_limit,
               mch.to_deprn_limit,
               mch.from_deprn_limit_amount,
               mch.to_deprn_limit_amount
          from fa_mass_changes    mch
         where mch.mass_change_id = p_mass_change_id;

   -- uom
   cursor c_assets_uom is
        select ad.asset_number,
               bk.asset_id
          from fa_additions_b ad,
               fa_books bk,
               fa_mass_changes mch,
               fa_methods me
         where mch.mass_change_id           = p_mass_change_id
           and bk.transaction_header_id_out is null
           and bk.book_type_code            = mch.book_type_code
           and bk.date_placed_in_service    >=
                   nvl(mch.from_date_placed_in_service,
                       bk.date_placed_in_service)
           and bk.date_placed_in_service    <=
                   nvl(mch.to_date_placed_in_service,
                       bk.date_placed_in_service)
           and bk.period_counter_fully_retired is null
           and nvl(bk.period_counter_fully_reserved, -1) =
                   decode(mch.change_fully_rsvd_assets, 'YES',
                         nvl(bk.period_counter_fully_reserved, -1), -1)
           and bk.deprn_method_code            =
                   nvl(mch.from_method_code, bk.deprn_method_code)
           and nvl(bk.production_capacity, -1) =
                   nvl(mch.from_production_capacity,
                       nvl(bk.production_capacity, -1))
           and nvl(bk.unit_of_measure, -1)     =
                   nvl(mch.from_uom,nvl(bk.unit_of_measure, -1))
           and bk.prorate_convention_code      =
                   nvl(mch.from_convention, bk.prorate_convention_code)
           and ad.asset_number                >=
                   nvl(mch.from_asset_number, ad.asset_number)
           and ad.asset_number                <=
                   nvl(mch.to_asset_number, ad.asset_number)
           and ad.asset_type                  <>      'CIP'
           and ad.asset_type                   = nvl(mch.asset_type, ad.asset_type)
           and ad.asset_id                     =       bk.asset_id
           and ad.asset_category_id            =
                   nvl(mch.category_id,ad.asset_category_id)
           and me.method_code = mch.from_method_code
           and me.rate_source_rule = 'PRODUCTION'
           and ad.asset_id > px_max_asset_id
           and MOD(nvl(bk.group_asset_id, ad.asset_id), p_total_requests) = (p_request_number - 1)
          order by ad.asset_id;


     -- non uom
     cursor c_assets is
        select ad.asset_number,
               bk.asset_id,
               bk.conversion_date,
               bk.date_effective,
               bk.date_placed_in_service,
               bk.group_asset_id
          from fa_additions_b                  ad,
               fa_books                        bk,
               fa_mass_changes                 mch,
               fa_methods                      mt --Bug 8928436
         where ad.asset_number         >=
                  nvl(mch.from_asset_number,
                      ad.asset_number)
           and ad.asset_number         <=
                  nvl(mch.to_asset_number,
                      ad.asset_number)
           and ad.asset_type           <>     'CIP'
           and ad.asset_type           =       nvl(mch.asset_type, ad.asset_type)
           and ad.asset_id             =       bk.asset_id
           and ad.asset_category_id    =
               nvl(mch.category_id,
                   ad.asset_category_id)
           and mch.mass_change_id      = p_mass_change_id
           and bk.book_type_code       =       mch.book_type_code
           and bk.transaction_header_id_out is null
           and bk.period_counter_fully_retired is null
           and nvl(bk.disabled_flag, 'N') = 'N' --HH ed.
           and nvl(bk.period_counter_fully_reserved,99)  =
                   decode(mt.rate_source_rule,'PRODUCTION',nvl(bk.period_counter_fully_reserved,99),nvl(bk.period_counter_life_complete,99)) --Bug 8928436
           and nvl(bk.period_counter_fully_reserved, -1) =
                   decode(mch.change_fully_rsvd_assets, 'YES',
                          nvl(bk.period_counter_fully_reserved, -1), -1)
           and bk.date_placed_in_service                >=
                   nvl(mch.from_date_placed_in_service,
                       bk.date_placed_in_service)
           and bk.date_placed_in_service                <=
                   nvl(mch.to_date_placed_in_service,
                       bk.date_placed_in_service)
           and bk.deprn_method_code                      =
                   nvl(mch.from_method_code,
                       bk.deprn_method_code)
           and nvl(bk.life_in_months, -1)                =
                   nvl(mch.from_life_in_months,
                       nvl(bk.life_in_months, -1))
           and nvl(bk.basic_rate, -1)                    =
                   nvl(mch.from_basic_rate,
                       nvl(bk.basic_rate, -1))
           and nvl(bk.adjusted_rate, -1)                 =
                   nvl(mch.from_adjusted_rate,
                       nvl(bk.adjusted_rate, -1))
           and nvl(bk.production_capacity, -1)           =
                   nvl(mch.from_production_capacity,
                       nvl(bk.production_capacity, -1))
           and nvl(bk.unit_of_measure, -1)               =
                   nvl(mch.from_uom,
                       nvl(bk.unit_of_measure, -1))
           and bk.prorate_convention_code                =
                   nvl(mch.from_convention,
                       bk.prorate_convention_code)
           and nvl(bk.bonus_rule, -1)                    =
                   nvl(mch.from_bonus_rule,
                      nvl(bk.bonus_rule,-1))
           and ((mch.from_group_association is null) or
                (mch.from_group_association = 'STANDALONE' and
                 bk.group_asset_id is null) or
                (mch.from_group_association = 'MEMBER' and
                 nvl(bk.group_asset_id, -99) = mch.from_group_asset_id))
           and nvl(bk.salvage_type, 'XX')          =
                   nvl(mch.from_salvage_type,
                       nvl(bk.salvage_type,'XX'))
           and nvl(bk.salvage_value, -99)          =
                   nvl(mch.from_salvage_value,
                       nvl(bk.salvage_value, -99))
           and nvl(bk.percent_salvage_value, -99)          =
                   nvl(mch.from_percent_salvage_value/100,
                       nvl(bk.percent_salvage_value, -99))
           and nvl(bk.deprn_limit_type, 'XX')            =
                   nvl(mch.from_deprn_limit_type,
                       nvl(bk.deprn_limit_type,'XX'))
           and nvl(bk.allowed_deprn_limit, -99)          =
                   nvl(mch.from_deprn_limit/100,
                       nvl(bk.allowed_deprn_limit, -99))
           and nvl(bk.allowed_deprn_limit_amount, -99)            =
                   nvl(mch.from_deprn_limit_amount,
                       nvl(bk.allowed_deprn_limit_amount, -99))
           and mt.method_code = bk.deprn_method_code --Bug 8928436
           and ad.asset_id > px_max_asset_id
           and MOD(nvl(bk.group_asset_id, ad.asset_id), p_total_requests) = (p_request_number - 1)
       MINUS
         select ad.asset_number,
               bk.asset_id,
               bk.conversion_date,
               bk.date_effective,
               bk.date_placed_in_service,
               bk.group_asset_id
          from fa_additions_b                  ad,
               fa_books                        bk,
               fa_mass_changes                 mch
         where ad.asset_number         >=
                  nvl(mch.from_asset_number,
                      ad.asset_number)
           and ad.asset_number         <=
                  nvl(mch.to_asset_number,
                      ad.asset_number)
           and ad.asset_type           <>     'CIP'
           and ad.asset_type           =       nvl(mch.asset_type, ad.asset_type)
           and ad.asset_id             =       bk.asset_id
           and ad.asset_category_id    =
               nvl(mch.category_id,
                   ad.asset_category_id)
           and mch.mass_change_id      = p_mass_change_id
           and bk.book_type_code       =       mch.book_type_code
           and bk.transaction_header_id_out is null
           and bk.period_counter_fully_retired is null
           and nvl(bk.disabled_flag, 'N') = 'N' --HH ed.
           and nvl(bk.period_counter_fully_reserved,99)  =
                   nvl(bk.period_counter_life_complete,99)
           and nvl(bk.period_counter_fully_reserved, -1) =
                   decode(mch.change_fully_rsvd_assets, 'YES',
                          nvl(bk.period_counter_fully_reserved, -1), -1)
           and bk.date_placed_in_service                >=
                   nvl(mch.from_date_placed_in_service,
                       bk.date_placed_in_service)
           and bk.date_placed_in_service                <=
                   nvl(mch.to_date_placed_in_service,
                       bk.date_placed_in_service)
           and bk.deprn_method_code                      =
                   nvl(mch.to_method_code,
                       bk.deprn_method_code)
           and nvl(bk.life_in_months, -1)                =
                   nvl(mch.to_life_in_months,
                       nvl(bk.life_in_months, -1))
           and nvl(bk.basic_rate, -1)                    =
                   nvl(mch.to_basic_rate,
                       nvl(bk.basic_rate, -1))
           and nvl(bk.adjusted_rate, -1)                 =
                   nvl(mch.to_adjusted_rate,
                       nvl(bk.adjusted_rate, -1))
           and nvl(bk.production_capacity, -1)           =
                   nvl(mch.to_production_capacity,
                       nvl(bk.production_capacity, -1))
           and nvl(bk.unit_of_measure, -1)               =
                   nvl(mch.to_uom,
                       nvl(bk.unit_of_measure, -1))
           and bk.prorate_convention_code                =
                   nvl(mch.to_convention,
                       bk.prorate_convention_code)
           and nvl(bk.bonus_rule, -1)                    =
                   nvl(mch.to_bonus_rule,
                      nvl(bk.bonus_rule,-1))
           and nvl (mch.to_group_association,'XXXX') = nvl (mch.from_group_association,'XXXX')
           and nvl (mch.to_group_asset_id,-99) = nvl (mch.from_group_asset_id,-99)
           and nvl(bk.salvage_type, 'XX')          =
                   nvl(mch.to_salvage_type,
                       nvl(bk.salvage_type,'XX'))
           and nvl(bk.salvage_value, -99)          =
                   nvl(mch.to_salvage_value,
                       nvl(bk.salvage_value, -99))
           and nvl(bk.percent_salvage_value, -99)          =
                   nvl(mch.to_percent_salvage_value/100,
                       nvl(bk.percent_salvage_value, -99))
           and nvl(bk.deprn_limit_type, 'XX')            =
                   nvl(mch.to_deprn_limit_type,
                       nvl(bk.deprn_limit_type,'XX'))
           and nvl(bk.allowed_deprn_limit, -99)          =
                   nvl(mch.to_deprn_limit/100,
                       nvl(bk.allowed_deprn_limit, -99))
           and nvl(bk.allowed_deprn_limit_amount, -99)            =
                   nvl(mch.to_deprn_limit_amount,
                       nvl(bk.allowed_deprn_limit_amount, -99))
           and ad.asset_id > px_max_asset_id
           and MOD(nvl(bk.group_asset_id, ad.asset_id), p_total_requests) = (p_request_number - 1)
         order by 2;


   done_exc      EXCEPTION;
   masschg_err   EXCEPTION;
   adj_err       EXCEPTION;

BEGIN

   px_max_asset_id := nvl(px_max_asset_id, 0);
   x_success_count := 0;
   x_failure_count := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  masschg_err;
      end if;
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

   -- get the masschg info
   open c_mass_change_info;
   fetch c_mass_change_info
           into l_masschg_status,
                l_from_convention,
                l_to_convention,
                l_from_method_code,
                l_to_method_code,
                l_from_life_in_months,
                l_to_life_in_months,
                l_from_bonus_rule,
                l_to_bonus_rule,
                l_mass_date_effective,
                l_trx_date_entered,
                l_from_basic_rate,
                l_to_basic_rate,
                l_from_adjusted_rate,
                l_to_adjusted_rate,
                l_from_production_capacity,
                l_to_production_capacity,
                l_from_uom,
                l_to_uom,
                l_from_group_association,
                l_to_group_association,
                l_from_group_asset_id,
                l_to_group_asset_id,
                l_asset_type,
                l_amortize_flag,
                l_book_type_code,
                l_from_salvage_type,
                l_to_salvage_type,
                l_from_percent_salvage_value,
                l_to_percent_salvage_value,
                l_from_salvage_value,
                l_to_salvage_value,
                l_from_deprn_limit_type,
                l_to_deprn_limit_type,
                l_from_deprn_limit,
                l_to_deprn_limit,
                l_from_deprn_limit_amount,
                l_to_deprn_limit_amount;
                -- l_allow_overlapping_adj_flag;

   if (c_mass_change_info%NOTFOUND) then
      close c_mass_change_info;
      raise masschg_err;
   end if;
   close c_mass_change_info;


   if(l_masschg_status <> 'RUNNING') then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_MASSCHG_WRONG_STATUS', p_log_level_rec => g_log_level_rec);   -- NOTE! not placing tokens yet
      raise masschg_err;
   end if;


   -- call the book controls cache
   if not fa_cache_pkg.fazcbc(X_book => l_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise masschg_err;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
           , p_log_level_rec => g_log_level_rec) then raise adj_err;
   end if;

   if (l_from_method_code is not null) then
      -- call the method cache for rate source rule
      if not fa_cache_pkg.fazccmt
          (X_method                => l_from_method_code,
           X_life                  => l_from_life_in_months
          , p_log_level_rec => g_log_level_rec) then
         raise masschg_err;
      end if;
   end if;

   l_from_rsr := fa_cache_pkg.fazccmt_record.rate_source_rule;

   if (l_to_method_code is not null) then
      if not fa_cache_pkg.fazccmt
          (X_method                => l_to_method_code,
           X_life                  => l_to_life_in_months
          , p_log_level_rec => g_log_level_rec) then
         raise masschg_err;
      end if;
   end if;

   l_to_rsr := fa_cache_pkg.fazccmt_record.rate_source_rule;

   if (l_from_rsr              = 'PRODUCTION' and
       l_to_rsr                = 'PRODUCTION' and
       nvl(l_from_convention, 'NULL')        = nvl(l_to_convention, 'NULL') and
       l_from_method_code                    = l_to_method_code and
       nvl(l_from_production_capacity, -1) = nvl(l_to_production_capacity, -1) and
       nvl(l_from_uom, 'NULL')              <> nvl(l_to_uom, 'NULL') and
       fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

       l_uom_change := TRUE;
   else
       l_uom_change := FALSE;
   end if;

   -- initial book control validation
   if (fa_cache_pkg.fazcbc_record.allow_mass_changes <> 'YES') then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_MASSCHG_WRONG_STATUS', p_log_level_rec => g_log_level_rec);
      raise masschg_err;
   elsif (fa_cache_pkg.fazcbc_record.date_ineffective is not null) then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_MASSCHG_WRONG_STATUS', p_log_level_rec => g_log_level_rec);
      raise masschg_err;
   end if;

   if (l_uom_change) then

      --'FA_MASSCHG_UOM_CHANGE_ONLY'
      --action_buf = (text *) "FA_SHARED_FETCH_CURSOR";

      OPEN c_assets_uom;
      FETCH c_assets_uom BULK COLLECT INTO
            l_asset_number,
            l_asset_id
      LIMIT l_batch_size;
      close c_assets_uom;

      if (l_asset_id.count = 0) then
         raise done_exc;
      end if;

      for l_loop_count in 1..l_asset_id.count loop

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

            update fa_books bk
               set bk.unit_of_measure   = l_to_uom,
                   bk.last_update_date  = sysdate,
                   bk.last_updated_by   = l_userid,
                   bk.last_update_login = l_login,
                   bk.annual_deprn_rounding_flag = 'ADJ'
            where  bk.asset_id          = l_asset_id(l_loop_count) and
                   bk.date_ineffective is null and
                   bk.book_type_code in
                      (select bc.book_type_code
                         from fa_book_controls bc,
                              fa_methods me
                        where bc.date_ineffective is null
                          and bc.distribution_source_book = l_book_type_code
                          and bc.book_class      <> 'BUDGET'
                          and me.method_code      = bk.deprn_method_code
                          and me.rate_source_rule = 'PRODUCTION');

            x_success_count := x_success_count + 1;

            write_message(l_asset_number(l_loop_count),
                          'FA_MCP_ADJUSTMENT_SUCCESS');


         EXCEPTION
            when others then
               FND_CONCURRENT.AF_ROLLBACK;
               x_failure_count := x_failure_count + 1;

               write_message(l_asset_number(l_loop_count),
                             null);
               fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

         END;

         -- FND_CONCURRENT.AF_COMMIT each record
         FND_CONCURRENT.AF_COMMIT;

      end loop;

   else -- non-uom or group change

      OPEN c_assets;
      FETCH C_assets BULK COLLECT INTO
           l_asset_number,
           l_asset_id,
           l_conversion_date,
           l_date_effective,
           l_date_placed_in_service,
           l_group_asset_id LIMIT l_batch_size;
      close c_assets;

      if l_asset_number.count = 0 then
         raise done_exc;
      end if;

      for l_loop_count in 1..l_asset_id.count loop

         -- clear the debug stack for each asset
         FA_DEBUG_PKG.Initialize;
         -- reset the message level to prevent bogus errors
         FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

         l_mesg_name := null;

         BEGIN

            -- no need to lock books row since it's a mass trx
            -- Check that assets do not have transactions dated after the
            -- request was submitted

            if l_date_effective(l_loop_count) >= l_mass_date_effective then
               l_mesg_name := 'FA_MASSCHG_DATE';
               raise adj_err;
            end if;

            if not FA_ASSET_VAL_PVT.validate_period_of_addition
                (p_asset_id            => l_asset_id(l_loop_count),
                 p_book                => l_book_type_code,
                 p_mode                => 'ABSOLUTE',
                 px_period_of_addition => l_period_of_addition,
                 p_log_level_rec       => g_log_level_rec) then
               raise adj_err;
            end if;

            -- Prevent adjustments on short tax year assets
            if (l_period_of_addition = 'Y' and l_conversion_date(l_loop_count) is not null) then
               l_mesg_name := 'FA_MASSCHG_ASSET_SHORT_TAX';
               raise adj_err;
            end if;

            -- Check non-production <=> production changes are legal
            if (l_from_rsr <> l_to_rsr) then
               if (l_from_rsr = 'PRODUCTION') then
                  if (l_period_of_addition <> 'Y')  then
                     l_mesg_name := 'FA_MASSCHG_ASSET_DEPRED';
                     raise adj_err;
                  end if;

                  if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

                     select count(*)
                       into l_count
                       from fa_book_controls bc,
                            fa_books bk,
                            fa_methods me
                      where bk.book_type_code    = bc.book_type_code
                        and bk.asset_id          = l_asset_id(l_loop_count)
                        and bk.date_ineffective is null
                        and bc.distribution_source_book = l_book_type_code
                        and bc.date_ineffective is null
                        and bc.book_class        = 'TAX'
                        and me.method_code       = bk.deprn_method_code
                        and nvl(me.life_in_months, -1) = nvl(bk.life_in_months, -1)
                        and me.rate_source_rule  = 'PRODUCTION';

                     if (l_count <> 0) then
                         l_mesg_name := 'FA_MASSCHG_PROD_IN_TAX';
                         raise adj_err;
                     end if;
                  end if;
               elsif (l_to_rsr = 'PRODUCTION') then
                  if (l_period_of_addition <> 'Y') then
                     l_mesg_name := 'FA_MASSCHG_ASSET_DEPRED';
                     raise adj_err;
                  end if;

                  if (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then
                     -- first check isn't need (asset in corp book)

                     select count(*)
                       into l_count
                       from fa_book_controls bc,
                            fa_books bk,
                            fa_methods me
                      where bk.book_type_code    = bc.distribution_source_book
                        and bk.asset_id          = l_asset_id(l_loop_count)
                        and bk.date_ineffective is null
                        and bc.book_type_code    = l_book_type_code
                        and bc.date_ineffective is null
                        and me.method_code       = bk.deprn_method_code
                        and nvl(me.life_in_months, -1) = nvl(bk.life_in_months, -1)
                        and me.rate_source_rule = 'PRODUCTION';

                     if (l_count = 0) then
                        l_mesg_name :=  'FA_MASSCHG_NOT_PROD_IN_CORP';
                        raise adj_err;
                     end if;
                  end if;  -- tax
               end if; -- production checks
            end if;  -- differing rate source rules

            -- set values - most shouldn't be needed -- DOUBLE CHECK ***

            -- check for current period add (not needed)
            -- check for exp after amort  (done in API)
            -- check for subsequent trxs (moved below for overlapping adjs)

            -- set some stuff (most not needed)
            -- calc rem lives for formula and short tax (API)

            -- do adjustment

            -- validation ok, null out then load the structs and process the adjustment
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
            l_group_reclass_options_rec    := NULL;

            -- reset the who info in trans rec
            l_trans_rec.who_info.last_update_date   := sysdate;
            l_trans_rec.who_info.last_updated_by    := FND_GLOBAL.USER_ID;
            l_trans_rec.who_info.created_by         := FND_GLOBAL.USER_ID;
            l_trans_rec.who_info.creation_date      := sysdate;
            l_trans_rec.who_info.last_update_login  := FND_GLOBAL.CONC_LOGIN_ID;
            l_trans_rec.mass_reference_id           := p_parent_request_id;
            l_trans_rec.calling_interface           := 'FAMACH';
            l_trans_rec.mass_transaction_id         := p_mass_change_id;

            l_trans_rec.transaction_date_entered     := l_trx_date_entered;

            -- asset header struct
            l_asset_hdr_rec.asset_id                 := l_asset_id(l_loop_count);
            l_asset_hdr_rec.book_type_code           := l_book_type_code;

            if (l_amortize_flag = 'Y') then
               l_trans_rec.transaction_subtype       := 'AMORTIZED';
               l_amortization_start_date             := l_trx_date_entered;

               -- only validate overlapping adjustments if the
               -- amortization start data is populated and
               -- it also falls in a prior period
               --
               -- form defaults the date as follows:
               -- greatest(fadp.calendar_period_open_date,
               --          least(sysdate, fadp.calendar_period_close_date))

               -- BUG# 2914818 - scrapping this now that we have the
               -- puristic approach for overlapping adjustments

               /*
               if (l_amortization_start_date < l_period_rec.calendar_period_open_date) then

                  -- get the existing fin info
                  if not FA_UTIL_PVT.get_asset_fin_rec
                          (p_asset_hdr_rec         => l_asset_hdr_rec,
                           px_asset_fin_rec        => l_asset_fin_rec_old,
                           p_transaction_header_id => NULL,
                           p_mrc_sob_type_code     => 'P'
                           , p_log_level_rec => g_log_level_rec) then raise adj_err;
                  end if;

                  l_old_amortization_start_date := l_amortization_start_date;
                  if not FA_ASSET_VAL_PVT.validate_amort_start_date
                          (p_transaction_type_code     => l_trans_rec.transaction_type_code,
                           p_asset_id                  => l_asset_hdr_rec.asset_id,
                           p_book_type_code            => l_asset_hdr_rec.book_type_code,
                           p_date_placed_in_service    => l_asset_fin_rec_old.date_placed_in_service,
                           p_conversion_date           => l_asset_fin_rec_old.conversion_date,
                           p_period_rec                => l_period_rec,
                           p_amortization_start_date   => l_old_amortization_start_date,
                           x_amortization_start_date   => l_amortization_start_date,
                           x_trxs_exist                => l_trxs_exist,
                           p_calling_fn                => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                     raise adj_err;
                  end if;

                  -- for now we are not allowing overlapping adjs via mass change
                  -- simply reject any such adjustments

                  if (l_trxs_exist = 'Y') then
                     -- and nvl(l_allow_overlapping_adj_flag, 'N') = 'N') then
                     l_mesg_name := 'FA_MASSCHG_TDATE';
                     raise adj_err;
                  end if;

               end if;

               */  -- end BUG# 2914818


               l_trans_rec.amortization_start_date   := l_amortization_start_date;
               l_trans_rec.transaction_date_entered  := l_amortization_start_date;

            else
               l_trans_rec.transaction_subtype       := 'EXPENSED';

               -- Check that the latest transaction_date_entered is on or
               -- before the transaction_date_entered for the request

               select count(*)
                 into l_count
                 from fa_transaction_headers th
                where th.asset_id       = l_asset_id(l_loop_count)
                  and th.book_type_code = l_book_type_code
                  and th.transaction_date_entered > l_trx_date_entered;

               if (l_count <> 0 ) then
                  l_mesg_name := 'FA_MASSCHG_TDATE';
                  raise adj_err;
               end if;
            end if;

            -- fin struct
            l_asset_fin_rec_adj.production_capacity     := l_to_production_capacity - l_from_production_capacity; -- Bug 3147951
            l_asset_fin_rec_adj.prorate_convention_code := l_to_convention;
            l_asset_fin_rec_adj.deprn_method_code       := l_to_method_code;
            l_asset_fin_rec_adj.life_in_months          := l_to_life_in_months;
            l_asset_fin_rec_adj.bonus_rule              := l_to_bonus_rule;
            l_asset_fin_rec_adj.basic_rate              := l_to_basic_rate;
            l_asset_fin_rec_adj.adjusted_rate           := l_to_adjusted_rate;
            l_asset_fin_rec_adj.unit_of_measure         := l_to_uom;

            if ((l_to_percent_salvage_value/100 is not null) OR
                (l_to_salvage_value is not null) OR
                (l_to_deprn_limit is not null) OR
                (l_to_deprn_limit_amount is not null)) then

               -- Fix for Bug #6707025.  In order to find correct value for the
               -- adj rec, need to get the old rec.
               select salvage_type,
                      nvl(percent_salvage_value, 0),
                      nvl(salvage_value, 0),
                      deprn_limit_type,
                      nvl(allowed_deprn_limit, 0),
                      nvl(allowed_deprn_limit_amount, 0)
               into   l_old_salvage_type,
                      l_old_percent_salvage_value,
                      l_old_salvage_value,
                      l_old_deprn_limit_type,
                      l_old_deprn_limit,
                      l_old_deprn_limit_amount
               from   fa_books
               where  book_type_code = l_book_type_code
               and    asset_id = l_asset_id(l_loop_count)
               and    transaction_header_id_out is null;

               l_asset_fin_rec_adj.salvage_type               :=
                  l_to_salvage_type;
               l_asset_fin_rec_adj.percent_salvage_value      :=
                  l_to_percent_salvage_value/100 - l_old_percent_salvage_value;
               --Bug# 6956721- start
               if (l_from_salvage_type <> l_to_salvage_type
               and l_to_salvage_type = 'AMT') then
                  l_asset_fin_rec_adj.salvage_value              :=
                  l_to_salvage_value;
               else
                 l_asset_fin_rec_adj.salvage_value              :=
                  l_to_salvage_value - l_old_salvage_value;
               end if;
               --Bug# 6956721- end
               l_asset_fin_rec_adj.deprn_limit_type           :=
                  l_to_deprn_limit_type;
               l_asset_fin_rec_adj.allowed_deprn_limit        :=
                  l_to_deprn_limit/100 - l_old_deprn_limit;
               --Bug# 6956721- start
               if (l_from_deprn_limit_type <> l_to_deprn_limit_type
               and l_to_deprn_limit_type = 'AMT') then
                  l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                  l_to_deprn_limit_amount;
               else
                  l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                  l_to_deprn_limit_amount - l_old_deprn_limit_amount;
               end if;
               --Bug# 6956721- end
            end if;
            -- group reclass if applicable
            -- to reclass from or to standalone, we must use G_MISS_NUM
            -- null will leave the asset untouched
            if (l_to_group_association is not null) then
               if (l_to_group_association = 'STANDALONE') then
                  l_asset_fin_rec_adj.group_asset_id := FND_API.G_MISS_NUM;
               else -- member
                  l_asset_fin_rec_adj.group_asset_id := l_to_group_asset_id;
               end if;

               -- set amort start to the member's dpis
               --Bug#8703091 - Don't override the transaction date entered by user.
               if (l_trans_rec.amortization_start_date is null) then
                  l_trans_rec.amortization_start_date   := l_date_placed_in_service(l_loop_count);
                  l_trans_rec.transaction_date_entered  := l_date_placed_in_service(l_loop_count);
               end if;
            end if;
            FA_ADJUSTMENT_PUB.do_adjustment
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
               l_mesg_name := null;
               raise adj_err;
            end if;

            -- Update UOM in TAX books if PROD method
            if (nvl(l_from_uom, 'NULL') <> nvl(l_to_uom, 'NULL')) then

               -- 'FA_MASSCHG_UPDATE_TAX_UOM'
               update fa_books bk
                  set bk.unit_of_measure    = l_to_uom,
                      bk.last_update_date   = sysdate,
                      bk.last_updated_by    = l_userid,
                      bk.last_update_login  = l_login,
                      bk.annual_deprn_rounding_flag = 'ADJ'
                where bk.asset_id           = l_asset_id(l_loop_count)
                  and bk.date_ineffective  is null
                  and bk.book_type_code in
                      (select bc.book_type_code
                         from fa_book_controls bc,
                              fa_methods me
                        where bc.distribution_source_book = l_book_type_code
                          and bc.book_class               = 'TAX'
                          and bc.date_ineffective        is null
                          and me.method_code              = bk.deprn_method_code
                          and me.rate_source_rule         = 'PRODUCTION');
            end if;

            x_success_count := x_success_count + 1;
            write_message(l_asset_number(l_loop_count),
                          'FA_MCP_ADJUSTMENT_SUCCESS');

         EXCEPTION
            when adj_err then
               FND_CONCURRENT.AF_ROLLBACK;
               x_failure_count := x_failure_count + 1;

               write_message(l_asset_number(l_loop_count),
                             l_mesg_name);
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

            when others then
               FND_CONCURRENT.AF_ROLLBACK;
               x_failure_count := x_failure_count + 1;

               write_message(l_asset_number(l_loop_count),
                             null);

               fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

         END;

         -- FND_CONCURRENT.AF_COMMIT each record
         FND_CONCURRENT.AF_COMMIT;

      end loop;  -- main bulk fetch loop

      px_max_asset_id := l_asset_id(l_asset_id.count);

   end if;   --uom_check

   x_return_status :=  0;

EXCEPTION
   when done_exc then
      x_return_status :=  0;

   when masschg_err then
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;
      x_return_status :=  2;

   when others then
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;
      x_return_status :=  2;

END do_mass_change;

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

   l_message := nvl(p_message,  'FA_MASSCHG_FAIL_TRX');

   if (l_message <> 'FA_MCP_ADJUSTMENT_SUCCESS') then
      l_calling_fn := 'fa_masschg_pkg.do_mass_change';
   end if;

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

END FA_MASSCHG_PKG;

/
