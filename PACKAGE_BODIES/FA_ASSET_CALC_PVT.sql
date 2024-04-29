--------------------------------------------------------
--  DDL for Package Body FA_ASSET_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_CALC_PVT" as
/* $Header: FAVCALB.pls 120.138.12010000.39 2010/05/28 08:56:23 gigupta ship $   */

G_primary_new_cost            NUMBER;
G_primary_salvage_value       NUMBER;
G_primary_deprn_limit_amount  NUMBER;

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION calc_fin_info
   (px_trans_rec                IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_inv_trans_rec           IN     FA_API_TYPES.inv_trans_rec_type,
    p_asset_hdr_rec             IN            FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec            IN            FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec            IN            FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec             IN            FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old         IN            FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj         IN            FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new        IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old       IN            FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj       IN            FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec                IN            FA_API_TYPES.period_rec_type,
    p_reclassed_asset_id        IN            NUMBER default null,
    p_reclass_src_dest          IN            VARCHAR2 default null,
    p_reclassed_asset_dpis      IN            DATE default null,
    p_mrc_sob_type_code         IN            VARCHAR2,
    p_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_calling_fn                IN            VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   l_adjust_type            varchar2(15);
   l_deprn_exp              number := 0;
   l_bonus_deprn_exp        number := 0;
   l_impairment_exp         number := 0;
   l_deprn_rsv              number := 0;
   l_bonus_deprn_rsv        number := 0;
   l_ann_adj_deprn_exp      number := 0;
   l_ann_adj_bonus_deprn_exp number := 0;

   l_clearing               number := 0;
   l_cost_to_insert         number := 0;
   l_clearing_to_insert     number := 0;

   l_jdpis                  number;
   l_asset_deprn_rec_adj    FA_API_TYPES.asset_deprn_rec_type;

   -- used for method cache
   l_method_id              number;
   l_rate_source_rule       varchar2(10);
   l_deprn_basis_rule       varchar2(4);
   l_set_extend_flag             boolean := FALSE;
   l_reset_extend_flag           boolean := FALSE;
   l_extended_flag           boolean := FALSE;
   l_amortization_start_date date;
   l_old_amortization_start_date date;

   l_group_level_override    varchar2(1) := NULL;
   x_new_deprn_amount        number;
   x_new_bonus_amount        number;
   x_new_impairment_amount   number;
   l_rc                      number;

   l_trxs_exist              VARCHAR2(1);
   l_calling_fn              varchar2(40) := 'fa_asset_calc_pvt.calc_fin_info';
   l_last_trx_count          number;

   l_deprn_reserve_exists    number;

   l_temp_deprn_reserve      number; -- Used to pass deprn reserve depending whether
                                     -- asset is in period of addition or not.
   l_call_faxama            boolean;

   l_disabled_flag_changed   boolean :=FALSE; --HH used to check
   l_call_bs                 boolean := TRUE; --whether faxama for group should be called
                                              -- or not
   l_old_dpis               date;

   l_cap_temp_value         number;  -- temporary variable to manipulate eop(fy)_rec_cost(sal)
                                     -- for capitalization.

   CURSOR c_get_member_trx is
      select asset_id
           , transaction_header_id
           , transaction_type_code
           , transaction_date_entered
           , transaction_name
           , source_transaction_header_id
           , mass_reference_id
           , transaction_subtype
           , transaction_key
           , amortization_start_date
           , calling_interface
           , mass_transaction_id
           , member_transaction_header_id
           , trx_reference_id
           , last_update_date
           , last_updated_by
           , last_update_login
      from   fa_transaction_headers
      where  transaction_header_id = px_trans_rec.member_transaction_header_id;

   -- Bug4958977: Introducing new cursor to trap dpis change only trx.
   CURSOR c_check_dpis_change is
       select inbk.transaction_header_id_in
       from   fa_books inbk
            , fa_books outbk
       where  inbk.transaction_header_id_in   = px_trans_rec.member_transaction_header_id
       and    outbk.asset_id                  = inbk.asset_id
       and    outbk.book_type_code            = p_asset_hdr_rec.book_type_code
       and    outbk.transaction_header_id_out = px_trans_rec.member_transaction_header_id
       and    inbk.cost                       = outbk.cost
       and    nvl(inbk.salvage_value, 0)              = nvl(outbk.salvage_value, 0)
       and    nvl(inbk.allowed_deprn_limit_amount, 0) = nvl(outbk.allowed_deprn_limit_amount, 0)
       and    inbk.date_placed_in_service     <> outbk.date_placed_in_service;

   --Bug8244128 Added a new cursor to fetch recognize_gain_loss
   --from retirements table
   CURSOR c_recognize_gain_loss_ret (l_thid number) is
   select recognize_gain_loss
   from   fa_retirements
   where  transaction_header_id_in = l_thid;

   CURSOR c_recognize_gain_loss_res (l_thid number) is
   select recognize_gain_loss
   from   fa_retirements
   where  transaction_header_id_out = l_thid;

   -- Bug 8520695
   CURSOR c_check_addn is   -- to check if there exists an addition transaction before current transaction
      select count(1)
      from fa_transaction_headers
      where asset_id              = p_asset_hdr_rec.asset_id
      and   transaction_header_id < px_trans_rec.transaction_header_id
      and   transaction_type_code = 'ADDITION';

   l_addn_cnt               number;
   -- End Bug 8520695

   -- Bug4958977: following 2 new variables
   l_temp_thid  number;
   l_dpis_change boolean := FALSE;

   l_trans_rec              FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec         FA_API_TYPES.asset_desc_rec_type;
   l_asset_fin_rec          FA_API_TYPES.asset_fin_rec_type;
   l_asset_cat_rec          FA_API_TYPES.asset_cat_rec_type;
   l_asset_type_rec         FA_API_TYPES.asset_type_rec_type;
   l_asset_deprn_rec        FA_API_TYPES.asset_deprn_rec_type; --Bug7008015

   l_recognize_gain_loss VARCHAR2(5); -- Bug8244128

   calc_err                 EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('calc_fin_info', 'at beginning of', 'calc_fin_info', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('calc_fin_info',
                       'p_asset_fin_rec_adj.over_depreciate_option',
                        p_asset_fin_rec_adj.over_depreciate_option, p_log_level_rec => p_log_level_rec);
   end if;


   -- get category default info

   l_jdpis := to_number(to_char(
                  nvl(px_asset_fin_rec_new.date_placed_in_service,
                     nvl(p_asset_fin_rec_adj.date_placed_in_service,
                         p_asset_fin_rec_old.date_placed_in_service)), 'J'));

   if not fa_cache_pkg.fazccbd (X_book   => p_asset_hdr_rec.book_type_code,
                                X_cat_id => p_asset_cat_rec.category_id,
                                X_jdpis  => l_jdpis, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;


   -- load the global attribute information
   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute1,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute1,
        x_char_new  => px_asset_fin_rec_new.global_attribute1, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute2,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute2,
        x_char_new  => px_asset_fin_rec_new.global_attribute2, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute3,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute3,
        x_char_new  => px_asset_fin_rec_new.global_attribute3, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute4,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute4,
        x_char_new  => px_asset_fin_rec_new.global_attribute4, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute5,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute5,
        x_char_new  => px_asset_fin_rec_new.global_attribute5, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute6,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute6,
        x_char_new  => px_asset_fin_rec_new.global_attribute6, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute7,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute7,
        x_char_new  => px_asset_fin_rec_new.global_attribute7, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute8,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute8,
        x_char_new  => px_asset_fin_rec_new.global_attribute8, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute9,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute9,
        x_char_new  => px_asset_fin_rec_new.global_attribute9, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute10,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute10,
        x_char_new  => px_asset_fin_rec_new.global_attribute10, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute11,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute11,
        x_char_new  => px_asset_fin_rec_new.global_attribute11, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute12,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute12,
        x_char_new  => px_asset_fin_rec_new.global_attribute12, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute13,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute13,
        x_char_new  => px_asset_fin_rec_new.global_attribute13, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute14,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute14,
        x_char_new  => px_asset_fin_rec_new.global_attribute14, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute15,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute15,
        x_char_new  => px_asset_fin_rec_new.global_attribute15, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute16,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute16,
        x_char_new  => px_asset_fin_rec_new.global_attribute16, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute17,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute17,
        x_char_new  => px_asset_fin_rec_new.global_attribute17, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute18,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute18,
        x_char_new  => px_asset_fin_rec_new.global_attribute18, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute19,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute19,
        x_char_new  => px_asset_fin_rec_new.global_attribute19, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute20,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute20,
        x_char_new  => px_asset_fin_rec_new.global_attribute20, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.global_attribute_category,
        p_char_adj  => p_asset_fin_rec_adj.global_attribute_category,
        x_char_new  => px_asset_fin_rec_new.global_attribute_category, p_log_level_rec => p_log_level_rec);

-- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy  Start

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.nbv_at_switch,
        p_num_adj  => p_asset_fin_rec_adj.nbv_at_switch,
        x_num_new  => px_asset_fin_rec_new.nbv_at_switch, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.prior_deprn_limit_type,
        p_char_adj  => p_asset_fin_rec_adj.prior_deprn_limit_type,
        x_char_new  => px_asset_fin_rec_new.prior_deprn_limit_type, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.prior_deprn_limit_amount,
        p_num_adj  => p_asset_fin_rec_adj.prior_deprn_limit_amount,
        x_num_new  => px_asset_fin_rec_new.prior_deprn_limit_amount, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.prior_deprn_limit,
        p_num_adj  => p_asset_fin_rec_adj.prior_deprn_limit,
        x_num_new  => px_asset_fin_rec_new.prior_deprn_limit, p_log_level_rec => p_log_level_rec);

   --Bug 8620902 No need to set px_asset_fin_rec_new.period_counter_fully_reserved as it will
   --             be set to null by adj and later set by depreciation.
   --bug 8819226 commenting this as same thing is handelled below also.
   /*IF (nvl(p_asset_fin_rec_old.extended_deprn_flag, '-1') <>
                        nvl(p_asset_fin_rec_adj.extended_deprn_flag, '-1')) and
       nvl(fnd_profile.value('FA_JAPAN_TAX_REFORMS'),'N') = 'Y' then

      FA_UTIL_PVT.load_num_value
          (p_num_old  => p_asset_fin_rec_old.period_counter_fully_reserved,
           p_num_adj  => p_asset_fin_rec_adj.period_counter_fully_reserved,
           x_num_new  => px_asset_fin_rec_new.period_counter_fully_reserved,
           p_log_level_rec => p_log_level_rec);

   END IF;*/

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.extended_depreciation_period,
        p_num_adj  => p_asset_fin_rec_adj.extended_depreciation_period,
        x_num_new  => px_asset_fin_rec_new.extended_depreciation_period, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_char_value
       (p_char_old  => p_asset_fin_rec_old.prior_deprn_method,
        p_char_adj  => p_asset_fin_rec_adj.prior_deprn_method,
        x_char_new  => px_asset_fin_rec_new.prior_deprn_method, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.prior_life_in_months,
        p_num_adj  => p_asset_fin_rec_adj.prior_life_in_months,
        x_num_new  => px_asset_fin_rec_new.prior_life_in_months, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.prior_basic_rate,
        p_num_adj  => p_asset_fin_rec_adj.prior_basic_rate,
        x_num_new  => px_asset_fin_rec_new.prior_basic_rate, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.prior_adjusted_rate,
        p_num_adj  => p_asset_fin_rec_adj.prior_adjusted_rate,
        x_num_new  => px_asset_fin_rec_new.prior_adjusted_rate, p_log_level_rec => p_log_level_rec);
-- Changes made as per the ER No.s 6606548 and 6606552 by End

   if (px_trans_rec.transaction_type_code = 'ADDITION' or
       px_trans_rec.transaction_type_code = 'CIP ADDITION' or
       px_trans_rec.transaction_type_code = 'GROUP ADDITION' or
       px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
       px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT' or
       px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT') then

     -- Bug:8240522
         FA_UTIL_PVT.load_num_value
            (p_num_old  => p_asset_fin_rec_old.contract_id,
             p_num_adj  => p_asset_fin_rec_adj.contract_id,
             x_num_new  => px_asset_fin_rec_new.contract_id, p_log_level_rec => p_log_level_rec);

      px_asset_fin_rec_new.prorate_convention_code   :=
         nvl(p_asset_fin_rec_adj.prorate_convention_code,
             nvl(p_asset_fin_rec_old.prorate_convention_code,
                 fa_cache_pkg.fazccbd_record.prorate_convention_code));
      px_asset_fin_rec_new.depreciate_flag           :=
         nvl(p_asset_fin_rec_adj.depreciate_flag,
             nvl(p_asset_fin_rec_old.depreciate_flag,
                 fa_cache_pkg.fazccbd_record.depreciate_flag));

      --HH group ed.
      px_asset_fin_rec_new.disabled_flag := p_asset_fin_rec_adj.disabled_flag;
      --End HH
      -- the following values can be nulled out either during
      -- an adjustment (exc bonus) or during addition in comparison to
      -- what would have been defaulted from the category.

      -- note we check the old method because trx_type is not
      -- enough as we only want the cat defaulting to occur
      -- during the initial addition, not during a void in period of add

      FA_UTIL_PVT.load_char_value
         (p_char_old  => p_asset_fin_rec_old.bonus_rule,
          p_char_adj  => p_asset_fin_rec_adj.bonus_rule,
          x_char_new  => px_asset_fin_rec_new.bonus_rule, p_log_level_rec => p_log_level_rec);

      -- do not allow the nulling out of bonus rule during adj
      if (px_asset_fin_rec_new.bonus_rule is null and
          p_asset_fin_rec_old.bonus_rule  is not null) then
         fa_srvr_msg.add_message(
            calling_fn => l_calling_fn,
             name       => 'FA_DEPRN_UPDATE_BONUS_RULE', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;

      FA_UTIL_PVT.load_char_value
         (p_char_old  => p_asset_fin_rec_old.ceiling_name,
          p_char_adj  => p_asset_fin_rec_adj.ceiling_name,
          x_char_new  => px_asset_fin_rec_new.ceiling_name, p_log_level_rec => p_log_level_rec);

      -- This is for FLAT RATE EXTENSION deprn basis rule
      FA_UTIL_PVT.load_char_value
         (p_char_old  => p_asset_fin_rec_old.exclude_fully_rsv_flag,
          p_char_adj  => p_asset_fin_rec_adj.exclude_fully_rsv_flag,
          x_char_new  => px_asset_fin_rec_new.exclude_fully_rsv_flag, p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_num_value
         (p_num_old  => p_asset_fin_rec_old.cash_generating_unit_id,
          p_num_adj  => p_asset_fin_rec_adj.cash_generating_unit_id,
          x_num_new  => px_asset_fin_rec_new.cash_generating_unit_id, p_log_level_rec => p_log_level_rec);

      if p_asset_type_rec.asset_type <> 'GROUP' then

         FA_UTIL_PVT.load_num_value
            (p_num_old  => p_asset_fin_rec_old.group_asset_id,
             p_num_adj  => p_asset_fin_rec_adj.group_asset_id,
             x_num_new  => px_asset_fin_rec_new.group_asset_id, p_log_level_rec => p_log_level_rec);

         -- validate new group info
         if (px_asset_fin_rec_new.group_asset_id is not null) then
            -- verify the asset exist in the book already
            if not FA_ASSET_VAL_PVT.validate_group_asset
                     (p_group_asset_id => px_asset_fin_rec_new.group_asset_id,
                      p_book_type_code => p_asset_hdr_rec.book_type_code,
                      p_asset_type     => p_asset_type_rec.asset_type
                     , p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

         end if;

      end if;

      if not calc_new_amounts
              (px_trans_rec              => px_trans_rec,
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_desc_rec          => p_asset_desc_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_cat_rec           => p_asset_cat_rec,
               p_asset_fin_rec_old       => p_asset_fin_rec_old,
               p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
               px_asset_fin_rec_new      => px_asset_fin_rec_new,
               p_asset_deprn_rec_old     => p_asset_deprn_rec_old,
               p_asset_deprn_rec_adj     => p_asset_deprn_rec_adj,
               px_asset_deprn_rec_new    => px_asset_deprn_rec_new,
               p_mrc_sob_type_code       => p_mrc_sob_type_code,
               p_log_level_rec           => p_log_level_rec
              ) then
         raise calc_err;
      end if;

      -- BUG# 3200703
      -- do not allow amortization if not allowed at book level

      if ((px_trans_rec.transaction_subtype = 'AMORTIZED' or
           px_trans_rec.amortization_start_date is not null) and
          fa_cache_pkg.fazcbc_record.amortize_flag = 'NO') then
         fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_BOOK_AMORTIZED_NOT_ALLOW', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;

      -- keeping this code after moving validate_asset_book call above
      -- but not sure if it's correct ???
      if (px_asset_fin_rec_new.group_asset_id is not null) then
         if (px_asset_fin_rec_new.super_group_id is not null) then
             -- *** validate super group exists ***
            fa_srvr_msg.add_message(
                   calling_fn => l_calling_fn,
                   name       => 'FA_NO_SUPER_GROUP_ALLOWED', p_log_level_rec => p_log_level_rec);
            raise calc_err;
         end if;
      end if;

      if (p_calling_fn = 'fa_cip_pvt.do_cap_rev') then
         l_old_dpis := px_asset_fin_rec_new.date_placed_in_service;
      else
         l_old_dpis := p_asset_fin_rec_old.date_placed_in_service;
      end if;

      if not fa_asset_val_pvt.validate_dpis
              (p_transaction_type_code  => px_trans_rec.transaction_type_code,
               p_book_type_code         => p_asset_hdr_rec.book_type_code,
               p_date_placed_in_service =>
                  px_asset_fin_rec_new.date_placed_in_service,
               p_prorate_convention_code =>
                  px_asset_fin_rec_new.prorate_convention_code,
               p_old_date_placed_in_service =>                       -- Bug3724207
                  l_old_dpis,        -- Bug3724207
               p_asset_id               => p_asset_hdr_rec.asset_id, -- Bug3724207
               p_transaction_subtype    => px_trans_rec.transaction_subtype,
               p_asset_type             => p_asset_type_rec.asset_type, -- bug 5501090
               p_calling_interface      => px_trans_rec.calling_interface,
               p_calling_fn             => l_calling_fn
              , p_log_level_rec => p_log_level_rec)then
         raise calc_err;
      end if;

      if (px_asset_fin_rec_new.group_asset_id is not null) then
         if not fa_asset_val_pvt.validate_member_dpis
                (p_book_type_code          => p_asset_hdr_rec.book_type_code,
                 p_date_placed_in_service  =>
                    px_asset_fin_rec_new.date_placed_in_service,
                 p_group_asset_Id          =>
                    px_asset_fin_rec_new.group_asset_id,
                 p_calling_fn              => l_calling_fn, p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;
      end if;

      if not fa_asset_val_pvt.validate_depreciate_flag
             (p_depreciate_flag         => px_asset_fin_rec_new.depreciate_flag,
              p_calling_fn              => l_calling_fn
              , p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      -- need to calc the prorate date before calling calc_deprn_info
      -- due to subcomponent life rule defaulting


      if not calc_prorate_date
              (p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
               px_asset_fin_rec_new      => px_asset_fin_rec_new,
               p_period_rec              => p_period_rec,
               p_log_level_rec           => p_log_level_rec
              ) then
         raise calc_err;
      end if;

      if not calc_deprn_info
              (p_trans_rec               => px_trans_rec,
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_desc_rec          => p_asset_desc_rec,
               p_asset_cat_rec           => p_asset_cat_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_fin_rec_old       => p_asset_fin_rec_old,
               p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
               px_asset_fin_rec_new      => px_asset_fin_rec_new,
               p_asset_deprn_rec_adj     => p_asset_deprn_rec_adj,
               p_asset_deprn_rec_new     => px_asset_deprn_rec_new,
               p_period_rec              => p_period_rec,
               p_log_level_rec           => p_log_level_rec
              ) then
         raise calc_err;
      end if;

      if not calc_derived_amounts
              (px_trans_rec              => px_trans_rec,
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_desc_rec          => p_asset_desc_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_cat_rec           => p_asset_cat_rec,
               p_asset_fin_rec_old       => p_asset_fin_rec_old,
               p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
               px_asset_fin_rec_new      => px_asset_fin_rec_new,
               p_asset_deprn_rec_old     => p_asset_deprn_rec_old,
               p_asset_deprn_rec_adj     => p_asset_deprn_rec_adj,
               px_asset_deprn_rec_new    => px_asset_deprn_rec_new,
               p_period_rec              => p_period_rec,
               p_mrc_sob_type_code       => p_mrc_sob_type_code,
               p_log_level_rec           => p_log_level_rec
              ) then
         raise calc_err;
      end if;

      if p_asset_type_rec.asset_type <> 'GROUP' then
         -- member level information must be copied from old to new
         if px_asset_fin_rec_new.group_asset_id is not null then

           if not calc_member_info
                 (p_trans_rec               => px_trans_rec,
                  p_asset_hdr_rec           => p_asset_hdr_rec,
                  p_asset_fin_rec_old       => p_asset_fin_rec_old,
                  p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
                  px_asset_fin_rec_new      => px_asset_fin_rec_new,
                  p_asset_deprn_rec_old     => p_asset_deprn_rec_old,
                  p_log_level_rec           => p_log_level_rec
                 ) then
              raise calc_err;
           end if;

         else

           if not calc_standalone_info
                 (p_asset_hdr_rec       => p_asset_hdr_rec,
                  p_asset_fin_rec_old   => p_asset_fin_rec_old,
                  p_asset_fin_rec_adj   => p_asset_fin_rec_adj,
                  px_asset_fin_rec_new  => px_asset_fin_rec_new,
                  p_asset_deprn_rec_new => px_asset_deprn_rec_new,
                  p_log_level_rec           => p_log_level_rec
                 ) then
              raise calc_err;
           end if;
         end if; -- (px_asset_fin_rec_new.group_asset_id is not null)

      else -- Asset type is Group
         --HH Validate disabled_flag
         if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => px_asset_fin_rec_new.group_asset_id,
                   p_book_type_code => p_asset_hdr_rec.book_type_code,
                   p_old_flag       => p_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => px_asset_fin_rec_new.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;

         --Check for flag change
         if nvl(p_asset_fin_rec_old.disabled_flag, FND_API.G_MISS_CHAR) <>
             nvl(px_asset_fin_rec_new.disabled_flag,
                 nvl(p_asset_fin_rec_old.disabled_flag, FND_API.G_MISS_CHAR)) then
             l_disabled_flag_changed := TRUE;
         end if;--End HH
         -- the following line is where we could allowed multi-tier
         -- group associates / hierarchies is desired
         px_asset_fin_rec_new.group_asset_id := NULL;

         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_new_info before calc group',
                     'p_asset_fin_rec_adj.over_depreciate_option',
                      p_asset_fin_rec_adj.over_depreciate_option, p_log_level_rec => p_log_level_rec);
         end if;

         if not FA_ASSET_VAL_PVT.validate_super_group (
                  p_book_type_code       => p_asset_hdr_rec.book_type_code,
                  p_old_super_group_id   => p_asset_fin_rec_old.super_group_id,
                  p_new_super_group_id   => px_asset_fin_rec_new.super_group_id,
                  p_calling_fn           => l_calling_fn, p_log_level_rec => p_log_level_rec) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling function', 'FA_ASSET_VAL_PVT.validate_super_group',  p_log_level_rec => p_log_level_rec);
            end if;

            raise calc_err;
         end if;

         if not calc_group_info
                 (p_trans_rec               => px_trans_rec,
                  p_asset_hdr_rec           => p_asset_hdr_rec,
                  p_asset_fin_rec_old       => p_asset_fin_rec_old,
                  p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
                  px_asset_fin_rec_new      => px_asset_fin_rec_new,
                  p_asset_deprn_rec_old     => p_asset_deprn_rec_old,
                  p_log_level_rec           => p_log_level_rec
                 ) then
            raise calc_err;
         end if;

         -- SLA: ***REVISIT***
         if p_asset_hdr_rec.period_of_addition = 'Y' then
            l_temp_deprn_reserve := px_asset_deprn_rec_new.deprn_reserve;
         else
            l_temp_deprn_reserve := to_number(null);
         end if;

         if not fa_asset_val_pvt.validate_over_depreciate
              (p_asset_hdr_rec              => p_asset_hdr_rec,
               p_asset_type                 => p_asset_type_rec.asset_type,
               p_over_depreciate_option     => px_asset_fin_rec_new.over_depreciate_option,
               p_adjusted_recoverable_cost  => px_asset_fin_rec_new.adjusted_recoverable_cost,
               p_recoverable_cost           => px_asset_fin_rec_new.recoverable_cost,
               p_deprn_reserve_new          => l_temp_deprn_reserve,
               p_rate_source_rule           => fa_cache_pkg.fazccmt_record.rate_source_rule,
               p_deprn_basis_rule           => fa_cache_pkg.fazccmt_record.deprn_basis_rule,
               p_recapture_reserve_flag     => px_asset_fin_rec_new.recapture_reserve_flag,
               p_deprn_limit_type           => px_asset_fin_rec_new.deprn_limit_type
              , p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;

      end if; --p_asset_type_rec.asset_type

      -- Check to prevent prior period trx with Energy UOP
     if not FA_ASSET_VAL_PVT.validate_egy_prod_date (
               p_calendar_period_start_date  => p_period_rec.calendar_period_open_date,
               p_transaction_date            => nvl(px_trans_rec.amortization_start_date,
                                                    px_trans_rec.transaction_date_entered),
               p_transaction_key             => px_trans_rec.transaction_key,
               p_rate_source_rule            => fa_cache_pkg.fazccmt_record.rate_source_rule,
               p_rule_name                   => fa_cache_pkg.fazcdrd_record.rule_name,
               p_calling_fn                  => l_calling_fn,
               p_log_level_rec               => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Failed calling',
                             'FA_ASSET_VAL_PVT.validate_egy_prod_date',  p_log_level_rec => p_log_level_rec);
         end if;
         raise calc_err;
      end if;

      if (px_trans_rec.transaction_type_code in
                 ('ADDITION', 'CIP ADDITION', 'GROUP ADDITION',
                  'ADJUSTMENT', 'CIP ADJUSTMENT', 'GROUP ADJUSTMENT')) then

         -- Fix for Bug #3187975.  Do Polish rule validations.

         -- Check adjustment (since old rec is null for regular addition)
         -- For adjustment, this is to prevent a method change out of a
         -- polish rule as well as a regular adjustment.
         if (p_asset_fin_rec_old.deprn_method_code is not null) then
            if not FA_ASSET_VAL_PVT.validate_polish (
               p_transaction_type_code => 'ADJUSTMENT',
               p_method_code           => p_asset_fin_rec_old.deprn_method_code,
               p_life_in_months        => p_asset_fin_rec_old.life_in_months,
               p_asset_type            => p_asset_type_rec.asset_type,
               p_bonus_rule            => p_asset_fin_rec_old.bonus_rule,
               p_ceiling_name          => p_asset_fin_rec_old.ceiling_name,
               p_deprn_limit_type      => p_asset_fin_rec_old.deprn_limit_type,
               p_group_asset_id        => p_asset_fin_rec_old.group_asset_id,
               p_calling_fn            => l_calling_fn
            , p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

            -- For adjustment, this is to prevent a method change into a
            -- polish rule as well as a regular adjustment.
            if not FA_ASSET_VAL_PVT.validate_polish (
               p_transaction_type_code => 'ADJUSTMENT',
               p_method_code           =>
                                   px_asset_fin_rec_new.deprn_method_code,
               p_life_in_months        => px_asset_fin_rec_new.life_in_months,
               p_asset_type            => p_asset_type_rec.asset_type,
               p_bonus_rule            => px_asset_fin_rec_new.bonus_rule,
               p_ceiling_name          => px_asset_fin_rec_new.ceiling_name,
               p_deprn_limit_type      => px_asset_fin_rec_new.deprn_limit_type,
               p_group_asset_id        => px_asset_fin_rec_new.group_asset_id,
               p_calling_fn            => l_calling_fn
            , p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;
         else
            -- Validate addition since old rec is null.
            if not FA_ASSET_VAL_PVT.validate_polish (
               p_transaction_type_code => 'ADDITION',
               p_method_code           =>
                                   px_asset_fin_rec_new.deprn_method_code,
               p_life_in_months        => px_asset_fin_rec_new.life_in_months,
               p_asset_type            => p_asset_type_rec.asset_type,
               p_bonus_rule            => px_asset_fin_rec_new.bonus_rule,
               p_ceiling_name          => px_asset_fin_rec_new.ceiling_name,
               p_deprn_limit_type      => px_asset_fin_rec_new.deprn_limit_type,
               p_group_asset_id        => px_asset_fin_rec_new.group_asset_id,
               p_date_placed_in_service
                                       =>
                                   px_asset_fin_rec_new.date_placed_in_service,
               p_calendar_period_open_date
                                       =>
                                   p_period_rec.calendar_period_open_date,
               p_ytd_deprn             => px_asset_deprn_rec_new.ytd_deprn,
               p_deprn_reserve         => px_asset_deprn_rec_new.deprn_reserve,
               p_calling_fn            => l_calling_fn
            , p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;
         end if;
      end if;

      -- perform final validation on all calculated amounts
      -- and only do so in the period of addition

      -- do not perform this check on groups nor on assets which
      -- may have been in a group during the period of addition
      -- the latter poses a problem in that this could be called
      -- from a transaction following a group reclass such that
      -- there is no difference in old and new.   We might have
      -- do see if the asset was ever in a group than bypass

      -- R12 conditional handling
      -- SLA Uptake
      -- further restricting only to the first ADDITION
      -- bug 8649223 (Added condition px_trans_rec.transaction_type_code = 'ADJUSTMENT')
      if (p_asset_hdr_rec.period_of_addition = 'Y' and
          p_asset_type_rec.asset_type <> 'GROUP' and
          p_asset_fin_rec_old.group_asset_id is null and
          px_asset_fin_rec_new.group_asset_id is null and
          (G_release = 11 or
           (px_trans_rec.transaction_type_code = 'ADDITION' or
            -- px_trans_rec.transaction_type_code = 'ADJUSTMENT' or -- reverted for bug 8765988
            px_trans_rec.transaction_type_code = 'CIP ADDITION'))) then

         -- BUG# 2323997
         -- no longer calling validate_rec_cost_reserve here
         -- as it is handled by the following check for non-deprn-basis
         -- assets...  also changed passed value to be adj_rec_cost - BMR

---------Added by Satish Byreddy As part of Reverse Catch up calculation Bug No.        6951549

            if (nvl(px_asset_fin_rec_new.extended_deprn_flag,'X') in ('N','D',FND_API.G_MISS_CHAR)) then
               l_reset_extend_flag := TRUE;
               l_extended_flag := FALSE; -- Bug 6737486 don't need validations when resetting
            ELSE
              l_reset_extend_flag := FALSE;

            end if;

              IF NOT (l_reset_extend_flag) THEN

                 if not fa_asset_val_pvt.validate_adj_rec_cost
                         (p_adjusted_recoverable_cost => px_asset_fin_rec_new.adjusted_recoverable_cost,
                          p_deprn_reserve             => px_asset_deprn_rec_new.deprn_reserve,
                          p_calling_fn                => l_calling_fn
                         , p_log_level_rec => p_log_level_rec) then
                    raise calc_err;
                 end if;
               END IF;

---------End OF Addition by Satish Byreddy As part of Reverse Catch up calculation Bug No.      6951549

         /*Bug#9682863 - Modified the parameters - instead of individual value passing records. */
         if not fa_asset_val_pvt.validate_ytd_reserve
                 (p_asset_hdr_rec             => p_asset_hdr_rec,
                  p_asset_type_rec            => p_asset_type_rec,
                  p_asset_fin_rec_new         => px_asset_fin_rec_new,
		  p_asset_deprn_rec_new       => px_asset_deprn_rec_new,
		  p_asset_deprn_rec_old       => p_asset_deprn_rec_old,    -- Fix for bug 8790562
                  p_period_rec                => p_period_rec,
                  p_calling_fn                => l_calling_fn
                 , p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;
-- Bug 7491479 Need to set the period counter fully reserved if the asset was
-- added with cost = reserve
         if (nvl(fnd_profile.value('FA_JAPAN_TAX_REFORMS'),'N') = 'N' OR
            (nvl(fnd_profile.value('FA_JAPAN_TAX_REFORMS'),'N') = 'Y' AND
             px_asset_fin_rec_new.deprn_method_code <> 'JP-STL-EXTND'))  then
            if (p_asset_type_rec.asset_type = 'CAPITALIZED') then
               if (nvl(px_asset_fin_rec_new.cost,0) <> 0) then
                  if (nvl(p_asset_fin_rec_adj.period_counter_fully_reserved, -- Bug 7661870
                          p_period_rec.period_counter) = p_period_rec.period_counter) then
                     if (nvl(px_asset_fin_rec_new.allowed_deprn_limit_amount,0) <> 0) then
                        if (nvl(px_asset_fin_rec_new.cost,0) -
                            nvl(px_asset_deprn_rec_new.deprn_reserve,0) -
                            nvl(px_asset_fin_rec_new.allowed_deprn_limit_amount,0) = 0) then
                           px_asset_fin_rec_new.period_counter_fully_reserved :=
                           p_period_rec.period_counter;
                           px_asset_fin_rec_new.period_counter_life_complete :=
                           p_period_rec.period_counter;
                        else
                           px_asset_fin_rec_new.period_counter_fully_reserved := null;
                           px_asset_fin_rec_new.period_counter_life_complete := null;
                        end if;
                     else
                        if (nvl(px_asset_fin_rec_new.cost,0) -
                            nvl(px_asset_deprn_rec_new.deprn_reserve,0) -
                            nvl(px_asset_fin_rec_new.salvage_value,0)  = 0) then
                            px_asset_fin_rec_new.period_counter_fully_reserved :=
                            p_period_rec.period_counter;
                            px_asset_fin_rec_new.period_counter_life_complete :=
                            p_period_rec.period_counter;
                        else
                            px_asset_fin_rec_new.period_counter_fully_reserved := null;
                            px_asset_fin_rec_new.period_counter_life_complete := null;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
-- End of Bug 7491479
      end if;

      -- Bug 8722521 : Validation for Japan methods during Tax upload
      if (nvl(px_trans_rec.calling_interface,'X') = 'FATAXUP') and
         (nvl(fnd_profile.value('FA_JAPAN_TAX_REFORMS'),'N') = 'Y') then
         if not FA_ASSET_VAL_PVT.validate_jp_taxupl (
                   p_trans_rec            =>     px_trans_rec,
                   p_asset_type_rec       =>     p_asset_type_rec,
                   p_asset_fin_rec        =>     px_asset_fin_rec_new,
                   p_asset_hdr_rec        =>     p_asset_hdr_rec,
                   p_asset_deprn_rec      =>     px_asset_deprn_rec_new,
                   p_log_level_rec        =>     p_log_level_rec) then
            raise calc_err;
         end if;
      end if;

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_fin_info',
                     'px_asset_fin_rec_new.production_capacity',
                      px_asset_fin_rec_new.production_capacity, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info',
                     'px_asset_deprn_rec_new.ltd_prod',
                      px_asset_deprn_rec_new.ltd_production, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info',
                     'px_asset_deprn_rec_new.ytd_prod',
                      px_asset_deprn_rec_new.ytd_production, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info',
                     'px_asset_fin_rec_new.short_fiscal_year_flag',
                      px_asset_fin_rec_new.short_fiscal_year_flag, p_log_level_rec => p_log_level_rec);
      end if;

      -- New Adjustments Behavior
      -- ------------------------
      -- Original versions simply called faadjust as usual.
      -- New model is as follows:
      --
      -- 1) the invoice engine will cllear all payables cost against
      --    the payables ccid for each line (prim and reporting)
      -- 2) faadjust is called with ins_adj passed as false
      --    and returns the amounts for expense and bonus expense
      -- 3) we determine any difference between the payables cost cleared
      --    and the delta cost which still needs to be flex built and posted
      -- 4) we pass all four amounts to a new version of faxiat which
      --    will insert them
      --
      -- Note: we can potentially enabled this at the time of addition
      -- as well instead of relying on CJE when desired.

      if not fa_cache_pkg.fazccmt
              (X_method                => px_asset_fin_rec_new.Deprn_Method_Code,
               X_life                  => px_asset_fin_rec_new.Life_In_Months
              , p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      l_method_id        := fa_cache_pkg.fazccmt_record.method_id;
      l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
      l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

      ----------------------------------------------
      -- Call Depreciable Basis Rule
      -- Event type: Initial Addition
      -- This event type calculates adjusted_cost
      -- at the period of DPIS.
      ----------------------------------------------
      if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                    (
                     p_event_type             => 'INITIAL_ADDITION',
                     p_asset_fin_rec_new      => px_asset_fin_rec_new,
                     p_asset_fin_rec_old      => p_asset_fin_rec_old,
                     p_asset_hdr_rec          => p_asset_hdr_rec,
                     p_asset_type_rec         => p_asset_type_rec,
                     p_asset_deprn_rec        => px_asset_deprn_rec_new,
                     p_trans_rec              => px_trans_rec,
                     p_period_rec             => p_period_rec,
                     p_used_by_adjustment     => 'ADJUSTMENT',
                     p_mrc_sob_type_code      => p_mrc_sob_type_code,
                     px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                     px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                     px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                     p_log_level_rec          => p_log_level_rec
                    )
                 )
      then
        raise calc_err;
      end if;

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_fin_info', 'trx_subtype',
                                px_trans_rec.transaction_subtype, p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info', 'transaction_type_code',
                                px_trans_rec.transaction_type_code, p_log_level_rec);
      end if;

      if (px_trans_rec.transaction_subtype = 'AMORTIZED') then

         -- validate the amortization_start_date (do for add and adj)
         -- when not in period of addition, amort date is set to trx date
         -- BUG# 3194910 - for group, only do this for direct adjustments
         --                and not those spawned by members

         if (px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
             px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT' or
             (px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
              px_trans_rec.transaction_key       = 'GJ')) then
            l_amortization_start_date := px_trans_rec.transaction_date_entered;
         else
            l_amortization_start_date := px_trans_rec.amortization_start_date;
         end if;

         -- Fix for Bug #2668073.  Need to pass different variables to OUT
         -- NOCOPY and IN parameters for amort start date;
         l_old_amortization_start_date := l_amortization_start_date;


         if not FA_ASSET_VAL_PVT.validate_amort_start_date
                 (p_transaction_type_code     => px_trans_rec.transaction_type_code,
                  p_asset_id                  => p_asset_hdr_rec.asset_id,
                  p_book_type_code            => p_asset_hdr_rec.book_type_code,
                  p_date_placed_in_service    => px_asset_fin_rec_new.date_placed_in_service,
                  p_conversion_date           => px_asset_fin_rec_new.conversion_date,
                  p_period_rec                => p_period_rec,
                  p_amortization_start_date   => l_old_amortization_start_date,
                  p_db_rule_name              => fa_cache_pkg.fazcdrd_record.rule_name,
                  p_rate_source_rule          => fa_cache_pkg.fazccmt_record.rate_source_rule,
                  p_transaction_key           => px_trans_rec.transaction_key,
                  x_amortization_start_date   => l_amortization_start_date,
                  x_trxs_exist                => l_trxs_exist,
                  p_calling_fn                => l_calling_fn, p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;

         if (px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
             px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT' or
             px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT') then
             if ( l_amortization_start_date is not null) then
                px_trans_rec.transaction_date_entered := l_amortization_start_date;
             end if;
            px_trans_rec.amortization_start_date := l_amortization_start_date;
         else
            px_trans_rec.amortization_start_date := l_amortization_start_date;
         end if;
      end if;

      if (px_trans_rec.transaction_subtype = 'AMORTIZED') and
         (px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT') then

         if not FA_ASSET_VAL_PVT.validate_cost_change (
                  p_asset_id                => p_asset_hdr_rec.asset_id,
                  p_group_asset_id          => px_asset_fin_rec_new.group_asset_id, --hh
                  p_book_type_code          => p_asset_hdr_rec.book_type_code,
                  p_asset_type              => p_asset_type_rec.asset_type,
                  p_transaction_header_id   => px_trans_rec.transaction_header_id,
                  p_transaction_date        => nvl(px_trans_rec.amortization_start_date,
                                                   px_trans_rec.transaction_date_entered),
                  p_cost                    => p_asset_fin_rec_old.cost,
                  p_cost_adj                => p_asset_fin_rec_adj.cost,
                  p_salvage_value           => p_asset_fin_rec_old.salvage_value,
                  p_salvage_value_adj       => p_asset_fin_rec_adj.salvage_value,
                  p_deprn_limit_amount      => p_asset_fin_rec_old.allowed_deprn_limit_amount,
                  p_deprn_limit_amount_adj  => p_asset_fin_rec_adj.allowed_deprn_limit_amount,
                  p_mrc_sob_type_code       => p_mrc_sob_type_code,
                  p_set_of_books_id         => p_asset_hdr_rec.set_of_books_id,
                  p_over_depreciate_option  => px_asset_fin_rec_new.over_depreciate_option, --hh
                  p_log_level_rec           => p_log_level_rec
                 ) then
            raise calc_err;
         end if;

     end if;

      -- note: we want to pick up adjustments to group assets in the period
      -- of addition, but not the initial shell.  in that case, the
      -- old struct will be null so comparing that

      -- do not pick up such groups if an initial reserve adjustment has
      -- already been performed

      -- R12 conditional logic
      -- SLA: since voids are obsolete changing the condition

      if (((G_release = 11 and
            px_trans_rec.transaction_type_code = 'GROUP ADDITION') or
           (G_release <> 11 and
            px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
            p_asset_hdr_rec.period_of_addition = 'Y' )) and
          p_asset_fin_rec_old.rate_adjustment_factor is not null ) then
         select count(*)
           into l_deprn_reserve_exists
           from fa_deprn_summary
          where asset_id = p_asset_hdr_rec.asset_id
            and book_type_code = p_asset_hdr_rec.book_type_code
            and deprn_source_code = 'BOOKS'
            and deprn_reserve <> 0;

         if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('calc_fin_info', 'l_deprn_reserve_exists for group', l_deprn_reserve_exists, p_log_level_rec => p_log_level_rec);
         end if;

      end if;

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_old.rate_adjustment_factor', p_asset_fin_rec_old.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'l_deprn_reserve_exists', l_deprn_reserve_exists, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'p_asset_deprn_rec_adj.deprn_reserve', p_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
      end if;

       --Bug8244128 Fetching recognize_gain_loss from retirements table
       if ( px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and px_trans_rec.transaction_key  = 'MR' ) then
          open c_recognize_gain_loss_ret( px_trans_rec.member_transaction_header_id);
          fetch c_recognize_gain_loss_ret into l_recognize_gain_loss;
          close c_recognize_gain_loss_ret;

       elsif ( px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and px_trans_rec.transaction_key  = 'MS') then
          open c_recognize_gain_loss_res( px_trans_rec.member_transaction_header_id);
          fetch c_recognize_gain_loss_res into l_recognize_gain_loss;
          close c_recognize_gain_loss_res;
       end if;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'l_recognize_gain_loss', l_recognize_gain_loss, p_log_level_rec);
       end if;

      -- Bug7017134: Modified condition below to handle adjustment in period of
      -- group addition.  Following condition has to be true in order to properly
      -- skip call to any functions in faxama

      -- R12 conditional logic
      -- SLA Uptake
      -- enter this code for additions and adjustments in period of addition
      -- to force catchup where needed too
      -- ** doesn't work coes asset isn't inserted yet **

      if (px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT' or
          (G_release = 11 and
           (px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' or
            (px_trans_rec.transaction_type_code = 'GROUP ADDITION' and
             p_asset_fin_rec_old.rate_adjustment_factor is not null and
             l_deprn_reserve_exists = 0 and
             (px_trans_rec.transaction_key <> 'GJ' or
              (px_trans_rec.transaction_key = 'GJ' and
               nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) = 0))))) or
          (G_release <> 11 and
            (px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
             nvl(l_deprn_reserve_exists,0) = 0 and
             (px_trans_rec.transaction_key <> 'GJ' or
              (px_trans_rec.transaction_key = 'GJ' and
               nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) = 0))) or
            (px_trans_rec.transaction_type_code = 'ADDITION' and
             p_asset_fin_rec_old.rate_adjustment_factor is not null))) then

         if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('calc_fin_info', 'in adjustment logic', 'before check for dep_flag', p_log_level_rec => p_log_level_rec);
         end if;

         -- much of this logic is based upon faxfa2b.pls

         if (px_trans_rec.transaction_subtype = 'AMORTIZED' and
             px_asset_fin_rec_new.cost <> 0) or
            (px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' or
             px_trans_rec.transaction_type_code = 'GROUP ADDITION') then
             l_adjust_type := 'AMORTIZED';
         else
             l_adjust_type := 'EXPENSED';
         end if;

         -- temporarily adding this until they are correctly built into the calc routines
         px_asset_fin_rec_new.rate_adjustment_factor := p_asset_fin_rec_old.rate_adjustment_factor;
         px_asset_fin_rec_new.formula_factor         := 1;

         -- Bug#3845714
         -- Following logic was added not to process BS for Sumup Case (to fix Bug3737670)
         -- Now Sumup Group will not be processed for FA_ADJ row
         if (px_asset_fin_rec_new.group_asset_id is null and
             nvl(px_asset_fin_rec_new.member_rollup_flag,'N') = 'Y') then
            l_call_bs := FALSE;
         end if;

         -- SLA Uptake
         -- adding nvl around old value since additions will enter this code now
         -- also entering this logic when dep flag is set to yes when
         -- previously was no

         if ((px_asset_fin_rec_new.depreciate_flag       = nvl(p_asset_fin_rec_old.depreciate_flag,
                                                              px_asset_fin_rec_new.depreciate_flag) or
             (G_release = 11 or
              (nvl(p_asset_fin_rec_old.depreciate_flag, 'YES') = 'NO' and
              px_asset_fin_rec_new.adjustment_required_status = 'ADD'))) and
         --HH only if disabled_flag is not Y.
             nvl(px_asset_fin_rec_new.disabled_flag,'N') = nvl(p_asset_fin_rec_old.disabled_flag,'N') and
             nvl(px_asset_fin_rec_new.reval_ceiling, 0) = nvl(p_asset_fin_rec_old.reval_ceiling, 0) and not
             (p_inv_trans_rec.invoice_transaction_id is not null and
              nvl(p_asset_fin_rec_adj.cost, 0) = 0)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_fin_info', 'inside',
                                 'main adjustment logic', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info', 'calling_interface', px_trans_rec.calling_interface, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info', 'TRX_KEY before faxama', px_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('calc_fin_info', 'group_reclass_type before faxama',
                                 p_group_reclass_options_rec.group_reclass_type, p_log_level_rec => p_log_level_rec);

            end if;

            -- BUG# 4684363
            -- removing validation originally added for FA_NO_GC_CALC_FULLYRSV
            -- see older code for details

            if ((px_asset_fin_rec_new.group_asset_id is null and
                 nvl(px_asset_fin_rec_new.member_rollup_flag,'N') <> 'Y') or
                (px_asset_fin_rec_new.group_asset_id is not null and
                 nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'CALCULATE')) then

               -- new method
               -- BUG# 3134846
               --    need to account for the value of l_adjust_type rather than just
               --    just the value of the subtype here (see above)
               --
               -- if (px_trans_rec.transaction_subtype = 'AMORTIZED' and
               if (l_adjust_type = 'AMORTIZED' and
                  --HH
                   (nvl(px_asset_fin_rec_new.disabled_flag,'N') = 'N')) then

                  l_call_faxama := TRUE;

                  -- BUG# 6987729
                  -- determine reclass case in order to skip calc/expense logic
                  -- when inbound or outbound from a group
                  -- and avoid calling as we don't want to double the
                  -- hits to faxama/faxinaj here and in favgrecb.pls

                  if ((nvl(px_asset_fin_rec_new.group_asset_id, -99) <>
                       nvl(p_asset_fin_rec_old.group_asset_id, -99)) AND
                      (px_asset_fin_rec_new.group_asset_id is null OR
                       p_asset_fin_rec_old.group_asset_id is null)) then
                     l_call_faxama := FALSE;
                     l_call_bs := FALSE;
                  end if;


                  -- if called from faxasset set flag for conc program
                  -- to call faxama for backdated transactions.
                  -- This is for backdated transactions that affect a group
                  -- asset so that faxama is not invoked from form but from
                  -- process group adjustments.

                  --
                  -- This is the place where prior period transaction and group reclass
                  -- to be processed with Process Group Adjustment concurrent program.
                  -- Comment following if statement out for testing with script.
                  -- There are 5 more places needs to be commented out in FAVGRECB.pls in
                  -- order to make process to be done without concurrent program
                  --
                  if (px_trans_rec.calling_interface = 'FAXASSET') then
                     if (p_asset_type_rec.asset_type = 'GROUP') then
                        if (px_trans_rec.transaction_key in(
                                        'MA','MJ','MC','MV','MD','MN','GJ') and
                           px_trans_rec.amortization_start_date <
                           p_period_rec.calendar_period_open_date) then

                           px_asset_fin_rec_new.adjustment_required_status := 'GADJ';
                           l_call_faxama := FALSE;
                           l_call_bs := FALSE;
                        elsif (px_trans_rec.transaction_key = 'GC' and
                           p_group_reclass_options_rec.group_reclass_type = 'CALC') then
                           px_asset_fin_rec_new.adjustment_required_status := 'GADJ';
                           l_call_faxama := FALSE;
                           l_call_bs := FALSE;
                        elsif (px_trans_rec.transaction_key = 'GC' and
                           p_group_reclass_options_rec.group_reclass_type = 'MANUAL') then
                           l_call_faxama := FALSE;
                           l_call_bs := FALSE;
                        elsif (px_trans_rec.transaction_key in ('MR', 'MS')) and                         -- ENERGY
                              (px_asset_fin_rec_new.tracking_method = 'ALLOCATE') and                    -- ENERGY
                              (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and  -- ENERGY
                              (l_recognize_gain_loss = 'NO') then -- ENERGY
                           -- Energy implementation requires FA_RETIREMENT_PVT.Do_Allocate to            -- ENERGY
                           -- be called from Process Group Adjsutment Conc program.                      -- ENERGY
                            --8244128 Added the check for recognize gain and loss
                           px_asset_fin_rec_new.adjustment_required_status := 'GADJ';                    -- ENERGY
                        elsif (px_trans_rec.transaction_key in ('MR', 'MS')) and                         -- ENERGY
                              (px_asset_fin_rec_new.tracking_method = 'ALLOCATE') and                    -- ENERGY
                              (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and  -- ENERGY
                              (l_recognize_gain_loss = 'YES')  then                                      -- ENERGY
                           --8244128 Added the condition to set adjustment_required_status
                           -- for case with recognize_gain_loss as YES
                           px_asset_fin_rec_new.adjustment_required_status := 'NONE';                    -- ENERGY
                        end if;
                     elsif (p_asset_type_rec.asset_type <> 'GROUP' and
                           p_asset_fin_rec_old.group_asset_id is not null and
                           px_asset_fin_rec_new.group_asset_id is null and
                           p_group_reclass_options_rec.group_reclass_type is not null) then
                        l_call_faxama := FALSE;
                        l_call_bs := FALSE;
                     end if;
                  end if;
                  --
                  --
                  --

                  /*Bug 8941132 MRC Reclass -Start*/
                  if (p_asset_type_rec.asset_type = 'GROUP') then
                     if (px_trans_rec.transaction_key = 'GC' and p_group_reclass_options_rec.group_reclass_type = 'CALC') then
                        px_asset_fin_rec_new.adjustment_required_status := 'GADJ';
                        l_call_faxama := FALSE;
                        l_call_bs := FALSE;
                     elsif (px_trans_rec.transaction_key = 'GC' and p_group_reclass_options_rec.group_reclass_type = 'MANUAL') then
                        l_call_faxama := FALSE;
                        l_call_bs := FALSE;
                     end if;
                  end if;
                  /*Bug 8941132 MRC Reclass -End*/

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add('calc_fin_info', 'adjustment_required_status',
                                       px_asset_fin_rec_new.adjustment_required_status, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add('calc_fin_info', 'l_call_faxama', l_call_faxama, p_log_level_rec => p_log_level_rec);
                  end if;

                  --HH we want to skip over faxama and faxexp below if disabled_flag is 'Y'
                  if l_disabled_flag_changed then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add('calc_fin_info', 'Disabled_flag Change', l_disabled_flag_changed, p_log_level_rec => p_log_level_rec);
                     end if;
                     l_call_faxama := FALSE;
                  end if;  --end HH

                  --* Bug#3737670
                  -- Skip to call faxama if the processing asset and transaction is matched with followings.
                  --  Transaction - Group Reclassification
                  --  Tracking Method - Calculate
                  --  Depreciation Option - Member
                  if nvl(px_asset_fin_rec_new.group_asset_id,-99) <> nvl(p_asset_fin_rec_old.group_asset_id,-99) and
                     nvl(px_asset_fin_rec_new.tracking_method,'NONE') = 'CALCULATE' and
                     nvl(px_asset_fin_rec_new.depreciation_option,'NONE') = 'MEMBER' then
                      if (p_log_level_rec.statement_level) then
                         fa_debug_pkg.add('calc_fin_info', 'Skip faxama since group reclass in calculate and Member', 'l_call_faxama is FALSE', p_log_level_rec => p_log_level_rec);
                      end if;
                      l_call_faxama := FALSE;
                  end if;

                  -- Fix for Bug #3846324.  Do not call faxama if the asset is not depreciating.  We
                  -- do not want a deprn expense catchup row created here.
                  -- Bug4318400: for group(non-sumup group), faxama needs to be called.
                  -- Not to call faxama for sumup group is taken care before this point
                  if (px_asset_fin_rec_new.depreciate_flag = 'NO') and
                     (p_asset_type_rec.asset_type <> 'GROUP') then
                     l_call_faxama := FALSE;
                  end if;

                  -- Bug4958977: Adding following entire if statement.
                  -- trx could be dpis change if following conditions are met
                  -- even though trx date is in current period
                  if (px_trans_rec.transaction_key = 'MJ' and
                      nvl(p_asset_fin_rec_adj.cost, 0) = 0 and
                      nvl(p_asset_fin_rec_adj.cip_cost, 0) = 0 and
                      nvl(p_asset_fin_rec_adj.salvage_value, 0) = 0 and
                      nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) = 0) and
                     (nvl(px_trans_rec.amortization_start_date,
                          px_trans_rec.transaction_date_entered) >=
                                 p_period_rec.calendar_period_open_date) then

                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add('calc_fin_info', 'could be dpis change', 'cont', p_log_level_rec => p_log_level_rec);
                     end if;

                     OPEN c_check_dpis_change;
                     FETCH c_check_dpis_change INTO l_temp_thid;
                     CLOSE c_check_dpis_change;

                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add('calc_fin_info', 'temp_thid', l_temp_thid, p_log_level_rec => p_log_level_rec);
                     end if;

                     if (l_temp_thid is not null) then
                        l_dpis_change := TRUE;
                     else
                        l_dpis_change := FALSE;
                     end if;
                  end if;

                  -- Call faxama only if this is prior period trx
                  -- Bug4958977: Added condition "or (l_dpis_change)"
                  if (((p_period_rec.calendar_period_open_date >
                                         px_trans_rec.amortization_start_date) or
                       (l_dpis_change))and
                      l_call_faxama) then

                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add('calc_fin_info', 'calling FAXAMA', 'faxama', p_log_level_rec => p_log_level_rec);
                     end if;

                     if (p_asset_type_rec.asset_type <> 'GROUP' and
                       -- Bug# 7245510:Expense not calculated for Only Contract_id adjustment
                         not nvl(p_asset_fin_rec_adj.contract_change_flag,FALSE))
then  /*Bug 7712756 added nvl */

                        if not FA_AMORT_PVT.faxama
                           (px_trans_rec           => px_trans_rec,
                            p_asset_hdr_rec        => p_asset_hdr_rec,
                            p_asset_desc_rec       => p_asset_desc_rec,
                            p_asset_cat_rec        => p_asset_cat_rec,
                            p_asset_type_rec       => p_asset_type_rec,
                            p_asset_fin_rec_old    => p_asset_fin_rec_old,
                            p_asset_fin_rec_adj    => p_asset_fin_rec_adj,
                            px_asset_fin_rec_new   => px_asset_fin_rec_new,
                            p_asset_deprn_rec      => p_asset_deprn_rec_old,
                            p_asset_deprn_rec_adj  => p_asset_deprn_rec_adj,
                            p_period_rec           => p_period_rec,
                            p_mrc_sob_type_code    => p_mrc_sob_type_code,
                            p_running_mode         => fa_std_types.FA_DPR_NORMAL,
                            p_used_by_revaluation  => null,
                            p_reclassed_asset_id   => p_reclassed_asset_id,
                            p_reclass_src_dest     => p_reclass_src_dest,
                            p_reclassed_asset_dpis => p_reclassed_asset_dpis,
                            x_deprn_exp            => l_deprn_exp,
                            x_bonus_deprn_exp      => l_bonus_deprn_exp,
                            x_impairment_exp       => l_impairment_exp
                            , p_log_level_rec => p_log_level_rec) then
                           return (FALSE);
                        end if;
                     end if; -- (p_asset_type_rec.asset_type <> 'GROUP')

                  else
                     -- calc_raf_adj_cost is the function to recalculate adj cost,
                     -- raf, and formular factor and it is godd enough for current
                     -- period trx.
                     /*Bug 8941132: MRC Reclass For Group Reclass l_call_bs is always false
                                    Since faxama is called by FAPGADJB.pls
                     if ((px_trans_rec.calling_interface <> 'FAXASSET') and
                         (px_trans_rec.transaction_key = 'GC' and
                         (p_group_reclass_options_rec.group_reclass_type = 'CALC'))) or
                     */
                     if (px_trans_rec.transaction_key in ('MR', 'MS')) then
                        l_call_bs := TRUE;
                     else
                        l_call_bs := FALSE;
                     end if;

                     -- 6950629 -> Only Contract_id adjustment, adjusted_cost calc is not updated*
                     -- Bug7017134: There is no need to call calc_raf_adj_cost in case of
                     -- GC, MR, MS.
                     -- Bug 7390952, added nvl function
                     if (nvl(px_trans_rec.transaction_key,'zz') not in ('GC', 'MR', 'MS') and
                        not nvl(p_asset_fin_rec_adj.contract_change_flag,FALSE)) then
                        if not FA_AMORT_PVT.calc_raf_adj_cost
                                        (p_trans_rec           => px_trans_rec,
                                         p_asset_hdr_rec       => p_asset_hdr_rec,
                                         p_asset_desc_rec      => p_asset_desc_rec,
                                         p_asset_type_rec      => p_asset_type_rec,
                                         p_asset_fin_rec_old   => p_asset_fin_rec_old,
                                         px_asset_fin_rec_new  => px_asset_fin_rec_new,
                                         p_asset_deprn_rec_adj => p_asset_deprn_rec_adj,
                                         p_asset_deprn_rec_new => px_asset_deprn_rec_new,
                                         p_period_rec          => p_period_rec,
                                         p_group_reclass_options_rec => p_group_reclass_options_rec,
                                         p_mrc_sob_type_code   => p_mrc_sob_type_code
                                         , p_log_level_rec => p_log_level_rec) then
                                 raise calc_err;
                        end if;
                     end if;

                     /* Begin of Bug 6803812 : Reverse the fa_adj entry created
 * for period of addition
 *                         if reserve change is made */

                     -- R12 conditional handling
                     if (((nvl(p_asset_deprn_rec_adj.deprn_reserve,0) <> 0) or
                          (nvl(p_asset_deprn_rec_adj.ytd_deprn,0) <> 0)) and
                         (p_asset_fin_rec_old.date_placed_in_service < p_period_rec.calendar_period_open_date) and
                         (p_asset_hdr_rec.period_of_addition = 'Y') and
                         G_release <> 11) then

                        begin
                           if (p_mrc_sob_type_code <> 'R') then
                              SELECT sum(decode(adj.debit_credit_flag,'DR',
                                                -1 * adj.adjustment_amount,
                                                adj.adjustment_amount)),
				     sum(decode(adj.debit_credit_flag,'DR',
                                                -1 * adj.annualized_adjustment,
                                                adj.annualized_adjustment))
                              INTO   l_deprn_exp,l_ann_adj_deprn_exp
                              FROM   fa_adjustments adj,
                                     fa_transaction_headers th
                              WHERE  th.book_type_code = p_asset_hdr_rec.book_type_code
                              and    th.asset_id = p_asset_hdr_rec.asset_id
                              and    th.transaction_type_code in ('ADDITION', 'ADJUSTMENT') --Bug7409454
                              and    adj.book_type_code = p_asset_hdr_rec.book_type_code
                              and    adj.asset_id = p_asset_hdr_rec.asset_id
                              and    adj.transaction_header_id = th.transaction_header_id
                              and    adj.source_type_code = 'DEPRECIATION'
                              and    adj.adjustment_type = 'EXPENSE'
                              and    adj.period_counter_created = p_period_rec.period_counter;

                           else

                              SELECT sum(decode(adj.debit_credit_flag,'DR',
                                                -1 * adj.adjustment_amount,
                                                adj.adjustment_amount)),
				     sum(decode(adj.debit_credit_flag,'DR',
                                                -1 * adj.annualized_adjustment,
                                                adj.annualized_adjustment))
                              INTO   l_deprn_exp,l_ann_adj_deprn_exp
                              FROM   fa_mc_adjustments adj,
                                     fa_transaction_headers th
                              WHERE  th.book_type_code = p_asset_hdr_rec.book_type_code
                              and    th.asset_id = p_asset_hdr_rec.asset_id
                              and    th.transaction_type_code in ('ADDITION', 'ADJUSTMENT') ----Bug7409454
                              and    adj.book_type_code = p_asset_hdr_rec.book_type_code
                              and    adj.asset_id = p_asset_hdr_rec.asset_id
                              and    adj.transaction_header_id = th.transaction_header_id
                              and    adj.source_type_code = 'DEPRECIATION'
                              and    adj.adjustment_type = 'EXPENSE'
                              and    adj.period_counter_created = p_period_rec.period_counter
                              and    adj.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

                           end if;
                        EXCEPTION
                           WHEN OTHERS THEN
                              l_deprn_exp := 0;
			      l_ann_adj_deprn_exp := 0;
                        END;

                     end if; /* End of Bug 6803812 */

                  end if; -- (p_period_rec.calendar_period_open_date >

               else

                  -- R12 conditional handling
                  -- Begin of Bug 7153740 : Reverse the fa_adj entry created  for period of addition
                  -- if manual reserve change is done
                  if (((nvl(p_asset_deprn_rec_adj.deprn_reserve,0) <> 0) or
                       (nvl(p_asset_deprn_rec_adj.ytd_deprn,0) <> 0)
							  OR (NVL(p_asset_deprn_rec_adj.allow_taxup_flag,FALSE))) and
                      (p_asset_fin_rec_old.date_placed_in_service < p_period_rec.calendar_period_open_date) and
                      (p_asset_hdr_rec.period_of_addition = 'Y') and
                      G_release <> 11) then

                     --Bug#8598745 : To recalculate adjusted_cost.
                     if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS (
                                           p_event_type          => 'EXPENSED_ADJ',
                                           p_asset_fin_rec_new   => px_asset_fin_rec_new,
                                           p_asset_fin_rec_old   => p_asset_fin_rec_old,
                                           p_asset_hdr_rec       => p_asset_hdr_rec,
                                           p_asset_type_rec      => p_asset_type_rec,
                                           p_asset_deprn_rec     => px_asset_deprn_rec_new,
                                           p_trans_rec           => px_trans_rec,
                                           p_period_rec          => p_period_rec,
                                           p_used_by_adjustment  => 'ADJUSTMENT',
                                           p_mrc_sob_type_code   => p_mrc_sob_type_code,
                                           p_hyp_total_rsv       => px_asset_deprn_rec_new.deprn_reserve,
                                           p_recoverable_cost    => px_asset_fin_rec_new.recoverable_cost,
                                           px_new_adjusted_cost  => px_asset_fin_rec_new.adjusted_cost,
                                           px_new_raf            => px_asset_fin_rec_new.rate_adjustment_factor,
                                           px_new_formula_factor => px_asset_fin_rec_new.formula_factor,
                                           p_log_level_rec       => p_log_level_rec))then
                        raise calc_err;
                     end if;

                     BEGIN
                        if (p_mrc_sob_type_code <> 'R') then
                           SELECT sum(decode(adj.debit_credit_flag,'DR',
                                                        -1 * adj.adjustment_amount,
                                                        adj.adjustment_amount)),
				  sum(decode(adj.debit_credit_flag,'DR',
                                                        -1 * adj.annualized_adjustment,
                                                        adj.annualized_adjustment))
                           INTO   l_deprn_exp,l_ann_adj_deprn_exp
                           FROM   fa_adjustments adj,
                                  fa_transaction_headers th
                           WHERE  th.book_type_code = p_asset_hdr_rec.book_type_code
                           and    th.asset_id = p_asset_hdr_rec.asset_id
                           and    th.transaction_type_code in ('ADDITION', 'ADJUSTMENT')
                           and    adj.book_type_code = p_asset_hdr_rec.book_type_code
                           and    adj.asset_id = p_asset_hdr_rec.asset_id
                           and    adj.transaction_header_id = th.transaction_header_id
                           and    adj.source_type_code = 'DEPRECIATION'
                           and    adj.adjustment_type = 'EXPENSE'
                           and    adj.period_counter_created = p_period_rec.period_counter;

                        else

                           SELECT sum(decode(adj.debit_credit_flag,'DR',
                                                        -1 * adj.adjustment_amount,
                                                        adj.adjustment_amount)),
				  sum(decode(adj.debit_credit_flag,'DR',
                                                        -1 * adj.annualized_adjustment,
                                                        adj.annualized_adjustment))
                           INTO   l_deprn_exp,l_ann_adj_deprn_exp
                           FROM   fa_mc_adjustments adj,
                                  fa_transaction_headers th
                           WHERE  th.book_type_code = p_asset_hdr_rec.book_type_code
                           and    th.asset_id = p_asset_hdr_rec.asset_id
                           and    th.transaction_type_code in ('ADDITION', 'ADJUSTMENT')
                           and    adj.book_type_code = p_asset_hdr_rec.book_type_code
                           and    adj.asset_id = p_asset_hdr_rec.asset_id
                           and    adj.transaction_header_id = th.transaction_header_id
                           and    adj.source_type_code = 'DEPRECIATION'
                           and    adj.adjustment_type = 'EXPENSE'
                           and    adj.period_counter_created = p_period_rec.period_counter
                           and    adj.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

                        end if;
                     EXCEPTION
                        WHEN OTHERS THEN
                           l_deprn_exp := 0;
			   l_ann_adj_deprn_exp := 0;
                     END;
                  else

                     --HH we want to skip over faxexp if disabled_flag just changed
                    --although we probably should never get in here.
                     if not l_disabled_flag_changed
                        /*Bug#9062728 - No need to call faxexp if CGU is changed */
			and (nvl(p_asset_fin_rec_old.cash_generating_unit_id, FND_API.G_MISS_NUM) =
                             nvl(p_asset_fin_rec_adj.cash_generating_unit_id,
                             nvl(p_asset_fin_rec_old.cash_generating_unit_id, FND_API.G_MISS_NUM))) then
                        if not FA_EXP_PVT.faxexp
                        (px_trans_rec          => px_trans_rec,
                         p_asset_hdr_rec       => p_asset_hdr_rec,
                         p_asset_desc_rec      => p_asset_desc_rec,
                         p_asset_cat_rec       => p_asset_cat_rec,
                         p_asset_type_rec      => p_asset_type_rec,
                         p_asset_fin_rec_old   => p_asset_fin_rec_old,
                         px_asset_fin_rec_new  => px_asset_fin_rec_new,
                         p_asset_deprn_rec     => p_asset_deprn_rec_old,
                         p_period_rec          => p_period_rec,
                         p_mrc_sob_type_code   => p_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp,
                         x_ann_adj_deprn_exp   => l_ann_adj_deprn_exp,
                         x_ann_adj_bonus_deprn_exp => l_ann_adj_bonus_deprn_exp,
                         p_log_level_rec => p_log_level_rec) then
                           raise calc_err;
                     end if;
                  end if; --disabled_flag changed.
               end if; --  if (((nvl(p_asset_deprn_rec_adj.deprn_reserve,0) <> 0)..
           end if;  -- amortized / expensed

               if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('calc_fin_info', 'after user exits, adj_cost',
                                    px_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
               end if;

               -- manual override - this is the only section in faadjust that
               -- needs to be propogated here
               if px_trans_rec.deprn_override_flag in (fa_std_types.FA_OVERRIDE_DPR,
                               fa_std_types.FA_OVERRIDE_BONUS,
                               fa_std_types.FA_OVERRIDE_DPR_BONUS) then

                  fa_std_types.deprn_override_trigger_enabled:= FALSE;

                  if (NVL(p_asset_fin_rec_old.tracking_method, ' ') = 'ALLOCATE') then
                     UPDATE FA_DEPRN_OVERRIDE ov
                        SET ov.transaction_header_id = px_trans_rec.transaction_header_id
                      WHERE ov.book_type_code        = p_asset_hdr_rec.book_type_code
                        AND ov.used_by               = 'ADJUSTMENT'
                        AND ov.status                = 'SELECTED'
                        AND ov.transaction_header_id is null
                        AND ov.asset_id IN
                            (SELECT bk.asset_id
                               FROM fa_books bk
                              WHERE bk.book_type_code = ov.book_type_code
                                AND bk.group_asset_id = p_asset_hdr_rec.asset_id
                                AND bk.date_ineffective IS NULL);
                  else
                     UPDATE FA_DEPRN_OVERRIDE
                        SET transaction_header_id = px_trans_rec.transaction_header_id
                      WHERE book_type_code        = p_asset_hdr_rec.book_type_code
                        AND asset_id              = p_asset_hdr_rec.asset_id
                        AND used_by               = 'ADJUSTMENT'
                        AND status                = 'SELECTED'
                        AND transaction_header_id is null;
                  end if;

                  fa_std_types.deprn_override_trigger_enabled:= TRUE;
               end if;

               --    need to account for the value of l_adjust_type rather than just
               --    just the value of the subtype here (see above)
               --
               -- if (px_trans_rec.transaction_subtype = 'AMORTIZED' and
               if (l_adjust_type = 'AMORTIZED' and
                   px_asset_fin_rec_new.cost = 0) then
                  px_asset_fin_rec_new.rate_adjustment_factor := 1;
               end if;

               if ((px_asset_fin_rec_new.formula_factor <> 1 or
                    px_asset_fin_rec_new.rate_adjustment_factor <> 1) and
                   l_rate_source_rule = 'FORMULA') then
                  px_asset_fin_rec_new.old_adjusted_cost := p_asset_fin_rec_old.adjusted_cost;
               end if;

            elsif p_asset_type_rec.asset_type='GROUP' and
                  nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'CALCULATE' and
                  nvl(px_asset_fin_rec_new.member_rollup_flag,'N') = 'Y'
            then

              -- The returned adjusted_cost is supported only CCA.

              if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                    (p_event_type             => 'AMORT_ADJ',
                     p_asset_fin_rec_new      => px_asset_fin_rec_new,
                     p_asset_fin_rec_old      => p_asset_fin_rec_old,
                     p_asset_hdr_rec          => p_asset_hdr_rec,
                     p_asset_type_rec         => p_asset_type_rec,
                     p_asset_deprn_rec        => px_asset_deprn_rec_new,
                     p_trans_rec              => px_trans_rec,
                     p_period_rec             => p_period_rec,
                     p_current_total_rsv      => px_asset_deprn_rec_new.deprn_reserve,
                     p_current_rsv            => px_asset_deprn_rec_new.deprn_reserve -
                                                 px_asset_deprn_rec_new.bonus_deprn_reserve - nvl(px_asset_deprn_rec_new.impairment_reserve,0),
                     p_current_total_ytd      => px_asset_deprn_rec_new.ytd_deprn,
                     p_adj_reserve            => p_asset_deprn_rec_adj.deprn_reserve,
                     p_mrc_sob_type_code      => p_mrc_sob_type_code,
                     p_used_by_adjustment     => 'ADJUSTMENT',
                     px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                     px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                     px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                     p_log_level_rec          => p_log_level_rec)
              ) then
                 raise calc_err;
              end if;

            end if; -- Tracking Method is not Allocate for Group Member Asset.

         elsif not (p_inv_trans_rec.invoice_transaction_id is not null and
                    nvl(p_asset_fin_rec_adj.cost, 0) = 0) then  -- depreciate flag changed

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_fin_info', 'entering',
                                 'logic for depreciate flag change', p_log_level_rec => p_log_level_rec);
            end if;

            -- Recalculate eofy_reserve
            if px_asset_fin_rec_new.depreciate_flag='YES' and
               px_asset_deprn_rec_new.ytd_deprn =0
            then
               px_asset_fin_rec_new.eofy_reserve := px_asset_deprn_rec_new.deprn_reserve;
            end if;

            ----------------------------------------------
            -- Call Depreciable Basis Rule
            -- for depreciate flag adjustment
            ----------------------------------------------
            if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                    (
                     p_event_type             => 'DEPRECIATE_FLAG_ADJ',
                     p_asset_fin_rec_new      => px_asset_fin_rec_new,
                     p_asset_fin_rec_old      => p_asset_fin_rec_old,
                     p_asset_hdr_rec          => p_asset_hdr_rec,
                     p_asset_type_rec         => p_asset_type_rec,
                     p_asset_deprn_rec        => px_asset_deprn_rec_new,
                     p_trans_rec              => px_trans_rec,
                     p_period_rec             => p_period_rec,
                     p_mrc_sob_type_code      => p_mrc_sob_type_code,
                     px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                     px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                     px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                     p_log_level_rec          => p_log_level_rec
                    )
                 )
             then
                 raise calc_err;
             end if;
         else -- BUG# 3615096: 0 cost change from invoice transaction
             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add('calc_fin_info', 'entering',
                                  'logic for zero cost invoice changes', p_log_level_rec => p_log_level_rec);
             end if;

             px_asset_fin_rec_new := p_asset_fin_rec_old;
         end if;              -- change in depreciate flag

      -- R12 conditional logic
      -- SLA: since voids are obsolete chaning condition for group

      elsif (px_trans_rec.transaction_type_code = 'ADDITION' or
             px_trans_rec.transaction_type_code = 'CIP ADDITION' or
             px_trans_rec.transaction_type_code = 'GROUP ADDITION' or
             (G_release <> 11 and
              px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
              p_asset_hdr_rec.period_of_addition = 'Y')) then

        if (p_asset_type_rec.asset_type = 'GROUP') and
           (l_deprn_reserve_exists <> 0 or nvl(p_asset_deprn_rec_adj.deprn_reserve,0) <> 0 )then

           /*Bug 8941132: MRC Reclass -No need to call faxama.
           if ((px_trans_rec.calling_interface <> 'FAXASSET') and
               (px_trans_rec.transaction_key = 'GC')) or */

           if (px_trans_rec.transaction_key in ('MR', 'MS')) then
              l_call_bs := TRUE;
           else
              l_call_bs := FALSE;
           end if;

           if not FA_AMORT_PVT.calc_raf_adj_cost
                        (p_trans_rec           => px_trans_rec,
                         p_asset_hdr_rec       => p_asset_hdr_rec,
                         p_asset_desc_rec      => p_asset_desc_rec,
                         p_asset_type_rec      => p_asset_type_rec,
                         p_asset_fin_rec_old   => p_asset_fin_rec_old,
                         px_asset_fin_rec_new  => px_asset_fin_rec_new,
                         p_asset_deprn_rec_adj => p_asset_deprn_rec_adj,
                         p_asset_deprn_rec_new => px_asset_deprn_rec_new,
                         p_period_rec          => p_period_rec,
                         p_mrc_sob_type_code   => p_mrc_sob_type_code
                         , p_log_level_rec => p_log_level_rec) then
                    raise calc_err;
           end if;

        else
           ----------------------------------------------
           -- Call Depreciable Basis Rule
           -- for Addition
           ----------------------------------------------
           -- Bug4403330: passing 0 values to p_eofy_recoverable_cost,
           -- p_eop_recoverable_cost, p_eofy_salvage_value, and p_eop_salvage_value
           -- is necessary to avoid calling GET_EOFY_EOP in deprn basis function because
           -- the sql gets old non depreciable value that should be excluded.
           if (px_trans_rec.transaction_type_code = 'ADDITION') and
              (p_calling_fn = 'fa_cip_pvt.do_cap_rev') then
              l_cap_temp_value := 0;
           else
              l_cap_temp_value := null;
           end if;

           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('calc_fin_info1', 'p_asset_fin_rec_old.deprn_method_code1111111',
                               p_asset_fin_rec_old.deprn_method_code, p_log_level_rec);
              fa_debug_pkg.add('calc_fin_info1', 'px_asset_fin_rec_new.deprn_method_code1111111',
                               px_asset_fin_rec_new.deprn_method_code, p_log_level_rec);
           end if;

----------------Added by Satish Byreddy as part of calculating Catchup Bug number 6951549
           IF px_asset_fin_rec_new.deprn_method_code = 'JP-STL-EXTND' OR
              p_asset_fin_rec_old.deprn_method_code = 'JP-STL-EXTND' THEN

              if px_trans_rec.calling_interface NOT IN ('FATAXUP','FAMAPT') THEN
                 --Bug 8834683 no need to cal catch up when asset with JP-STL-EXTND method code
                 --is added with reserve.
                 if (nvl(p_asset_deprn_rec_adj.deprn_reserve,0) =  0 )and
                    (p_asset_fin_rec_old.date_placed_in_service < p_period_rec.calendar_period_open_date) and
                    (p_asset_hdr_rec.period_of_addition = 'Y') and
                    (px_trans_rec.transaction_type_code = 'ADDITION') then
                    if not l_disabled_flag_changed  then
                       -- Bug 8520695
                       open  c_check_addn;
                       fetch c_check_addn into l_addn_cnt;
                       close c_check_addn;

                       -- Prevent call to faxexp if the adj transaction is in POA
                       if l_addn_cnt = 0 then
                          if not FA_EXP_PVT.faxexp
                              (px_trans_rec          => px_trans_rec,
                               p_asset_hdr_rec       => p_asset_hdr_rec,
                               p_asset_desc_rec      => p_asset_desc_rec,
                               p_asset_cat_rec       => p_asset_cat_rec,
                               p_asset_type_rec      => p_asset_type_rec,
                               p_asset_fin_rec_old   => p_asset_fin_rec_old,
                               px_asset_fin_rec_new  => px_asset_fin_rec_new,
                               p_asset_deprn_rec     => p_asset_deprn_rec_old,
                               p_period_rec          => p_period_rec,
                               p_mrc_sob_type_code   => p_mrc_sob_type_code,
                               p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                               p_used_by_revaluation => null,
                               x_deprn_exp           => l_deprn_exp,
                               x_bonus_deprn_exp     => l_bonus_deprn_exp,
                               x_impairment_exp      => l_impairment_exp,
                               x_ann_adj_deprn_exp   => l_ann_adj_deprn_exp,
                               x_ann_adj_bonus_deprn_exp => l_ann_adj_bonus_deprn_exp,
                               p_log_level_rec => p_log_level_rec) then
                              raise calc_err;
                          end if;
                       end if;  -- End Bug 8520695
                    end if; --disabled_flag changed.
                 end if;--deprn resereve = 0
              end if;
           end if; -- px_asset_fin_rec_new.deprn_method_code = 'JP-STL-EXTND' OR


----------------End OF addition by Satish Byreddy as part of calculating Catchup Bug number     6951549

          if px_trans_rec.calling_interface <> 'FAEXDEPR' THEN
           if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                       (
                        p_event_type             => 'ADDITION',
                        p_asset_fin_rec_new      => px_asset_fin_rec_new,
                        p_asset_fin_rec_old      => p_asset_fin_rec_old,
                        p_asset_hdr_rec          => p_asset_hdr_rec,
                        p_asset_type_rec         => p_asset_type_rec,
                        p_asset_deprn_rec        => px_asset_deprn_rec_new,
                        p_trans_rec              => px_trans_rec,
                        p_period_rec             => p_period_rec,
                        p_eofy_recoverable_cost  => l_cap_temp_value,
                        p_eop_recoverable_cost   => l_cap_temp_value,
                        p_eofy_salvage_value     => l_cap_temp_value,
                        p_eop_salvage_value      => l_cap_temp_value,
                        p_mrc_sob_type_code      => p_mrc_sob_type_code,
                        px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                        px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                        px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                        p_log_level_rec          => p_log_level_rec
                       )
                    )
           then
                    raise calc_err;
           end if;
         end if;
         if (px_trans_rec.transaction_type_code = 'ADDITION') then
            IF px_asset_fin_rec_new.deprn_method_code = 'JP-STL-EXTND' OR p_asset_fin_rec_old.deprn_method_code = 'JP-STL-EXTND'  THEN
                   if (p_log_level_rec.statement_level) then
                               fa_debug_pkg.add('calc_fin_info1',
                                     'x_deprn_exp.deprn_reserve22222',
                                      l_deprn_exp, p_log_level_rec => p_log_level_rec);
                   end if;
            px_asset_deprn_rec_new.deprn_reserve := nvl(px_asset_deprn_rec_new.deprn_reserve, 0) + nvl(l_deprn_exp, 0);
            px_asset_deprn_rec_new.ytd_deprn     := nvl(px_asset_deprn_rec_new.ytd_deprn, 0) + nvl(l_deprn_exp, 0);

          end if;
         end if;

        end if;

      end if;



      --
      -- Following faxama will return catch-up for group.
      -- This is the one will use FA_BOOKS_SUMMARY table to calculate
      -- and maintain FA_BOOKS_SUMMARY.
      --
      if (p_asset_type_rec.asset_type = 'GROUP') and
            (l_call_bs) then

         if -- (p_group_reclass_options_rec.group_reclass_type = 'CALC') and
            (p_asset_type_rec.asset_type = 'GROUP') and
            (p_reclass_src_dest = 'DESTINATION') then
            l_asset_deprn_rec_adj.deprn_reserve := nvl(l_asset_deprn_rec_adj.deprn_reserve, 0) +
                                                   p_group_reclass_options_rec.reserve_amount;
         else
            l_asset_deprn_rec_adj := p_asset_deprn_rec_adj;
         end if;

         if (not FA_AMORT_PVT.faxama(
                         px_trans_rec            => px_trans_rec,
                         p_asset_hdr_rec         => p_asset_hdr_rec,
                         p_asset_desc_rec        => p_asset_desc_rec,
                         p_asset_cat_rec         => p_asset_cat_rec,
                         p_asset_type_rec        => p_asset_type_rec,
                         p_asset_fin_rec_old     => p_asset_fin_rec_old,
                         p_asset_fin_rec_adj     => p_asset_fin_rec_adj,
                         px_asset_fin_rec_new    => px_asset_fin_rec_new,
                         p_asset_deprn_rec       => p_asset_deprn_rec_old,
                         p_asset_deprn_rec_adj   => l_asset_deprn_rec_adj,
                         p_period_rec            => p_period_rec,
                         p_mrc_sob_type_code     => p_mrc_sob_type_code,
                         p_running_mode          => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation   => null,
                         p_reclassed_asset_id    => p_reclassed_asset_id,
                         p_reclass_src_dest      => p_reclass_src_dest,
                         p_reclassed_asset_dpis  => p_reclassed_asset_dpis,
                         p_update_books_summary  => TRUE,
                         p_proceeds_of_sale      => 0,
                         p_cost_of_removal       => 0,
                         x_deprn_exp             => l_deprn_exp,
                         x_bonus_deprn_exp       => l_bonus_deprn_exp,
                         x_impairment_exp        => l_impairment_exp,
                         x_deprn_rsv             => l_deprn_rsv, p_log_level_rec => p_log_level_rec)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_fin_info', 'calling FA_AMORT_PVT.faxama', 'FAILED',  p_log_level_rec => p_log_level_rec);
            end if;

            raise calc_err;

         end if; -- (not FA_AMORT_PVT.faxama

         if (p_group_reclass_options_rec.group_reclass_type = 'CALC') and
            (p_asset_type_rec.asset_type = 'GROUP') and
            (p_reclass_src_dest = 'SOURCE') then
            p_group_reclass_options_rec.reserve_amount := -1 * l_deprn_rsv;
         end if;

      end if; -- (p_asset_type_rec.asset_type = 'GROUP')


      if (px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT') then

         -- get the total amounted cleared for payables cost
         -- from the invoice engine (assumes its been flushed)
         if (p_mrc_sob_type_code <> 'R') then
            select nvl(sum(decode(debit_credit_flag,
                                  'CR', adjustment_amount,
                                  adjustment_amount * -1)), 0)
              into l_clearing
              from fa_adjustments
             where asset_id = p_asset_hdr_rec.asset_id
               and book_type_code = p_asset_hdr_rec.book_type_code
               and period_counter_created = p_period_rec.period_counter
               and transaction_header_id = px_trans_rec.transaction_header_id
               and adjustment_type = 'COST CLEARING';
         else
            select nvl(sum(decode(debit_credit_flag,
                                  'CR', adjustment_amount,
                                  adjustment_amount * -1)), 0)
              into l_clearing
              from fa_mc_adjustments
             where asset_id = p_asset_hdr_rec.asset_id
               and book_type_code = p_asset_hdr_rec.book_type_code
               and period_counter_created = p_period_rec.period_counter
               and transaction_header_id = px_trans_rec.transaction_header_id
               and adjustment_type = 'COST CLEARING'
               and set_of_books_id = p_asset_hdr_rec.set_of_books_id ;
         end if;
      end if;



      -- process groups here to for the catchup but not for clearing

      -- R12 conditional handling
      -- SLA: now insert catchup for capitalization

      if (px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'GROUP ADDITION'  or
          (px_trans_rec.transaction_type_code = 'ADDITION' and
           p_asset_fin_rec_old.rate_adjustment_factor is not null and
           G_release <> 11 )) then

         if (px_trans_rec.transaction_type_code = 'GROUP ADDITION' or
             (G_release <> 11 and
              (px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
               p_asset_hdr_rec.period_of_addition = 'Y') or
              (px_trans_rec.transaction_type_code = 'ADJUSTMENT' and
               p_asset_hdr_rec.period_of_addition = 'Y' and
               (nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) = 0 and
                nvl(p_asset_deprn_rec_adj.ytd_deprn, 0) = 0 )))) then

                  IF NOT (NVL(p_asset_deprn_rec_adj.allow_taxup_flag,FALSE)) THEN
                       px_asset_deprn_rec_new.deprn_reserve := nvl(px_asset_deprn_rec_new.deprn_reserve, 0) + nvl(l_deprn_exp, 0);
                       px_asset_deprn_rec_new.ytd_deprn     := nvl(px_asset_deprn_rec_new.ytd_deprn, 0) + nvl(l_deprn_exp, 0);
                  ELSE

                       IF (p_asset_deprn_rec_adj.deprn_reserve <> 0) THEN
                          px_asset_deprn_rec_new.deprn_reserve := nvl(px_asset_deprn_rec_new.deprn_reserve, 0) + nvl(l_deprn_exp, 0);
                       END IF;

                       IF (p_asset_deprn_rec_adj.ytd_deprn <> 0) THEN
                          px_asset_deprn_rec_new.ytd_deprn     := nvl(px_asset_deprn_rec_new.ytd_deprn, 0) + nvl(l_deprn_exp, 0);
                       END IF;

                 END IF;

            -- Bug 8533933
            px_asset_deprn_rec_new.bonus_ytd_deprn     := nvl(px_asset_deprn_rec_new.bonus_ytd_deprn, 0) + nvl(l_bonus_deprn_exp, 0);
            px_asset_deprn_rec_new.bonus_deprn_reserve := nvl(px_asset_deprn_rec_new.bonus_deprn_reserve, 0) + nvl(l_bonus_deprn_exp, 0);
            -- End Bug 8533933
         end if;
         --bug 8765988/8649223 ( Adding this validation to prevent -ve NBV in POA via adjustement)
         if (p_asset_hdr_rec.period_of_addition = 'Y' and px_trans_rec.transaction_type_code = 'ADJUSTMENT') then
            if not fa_asset_val_pvt.validate_adj_rec_cost
                 (p_adjusted_recoverable_cost => px_asset_fin_rec_new.adjusted_recoverable_cost,
                  p_deprn_reserve             => px_asset_deprn_rec_new.deprn_reserve,
                  p_calling_fn                => l_calling_fn,
                  p_log_level_rec             => p_log_level_rec
                 ) then
               raise calc_err;
            end if;

            /*Bug#9488077/9130653 - added following condition */
            if (p_asset_deprn_rec_adj.deprn_reserve <> 0 OR p_asset_deprn_rec_adj.ytd_deprn <> 0) then
               --bug 8785230 Missing Validation for POA and +ve deprn reserve
               /*Bug#9682863 - Modified the parameters - instead of individual value passing records. */
               if not fa_asset_val_pvt.validate_ytd_reserve
                 (p_asset_hdr_rec             => p_asset_hdr_rec,
                  p_asset_type_rec            => p_asset_type_rec,
                  p_asset_fin_rec_new         => px_asset_fin_rec_new,
                  p_asset_deprn_rec_new       => px_asset_deprn_rec_new,
                  p_period_rec                => p_period_rec,
                  p_asset_deprn_rec_old       => p_asset_deprn_rec_old,    /*Fix for bug 8790562 */
                  p_calling_fn                => l_calling_fn,
                  p_log_level_rec             => p_log_level_rec) then

                 raise calc_err;
               end if;
            end if;
         end if;

	 -- Bug#9161943: Checking validation after recalculating new adjusted reserve
	 -- Bug#7172602: Validate Salvage value change
         if (p_asset_type_rec.asset_type <> 'GROUP' and p_asset_fin_rec_old.group_asset_id is null and
            px_asset_fin_rec_new.group_asset_id is null) then
            if not FA_ASSET_VAL_PVT.validate_salvage_value
                 ( p_salvage_value => px_asset_fin_rec_new.salvage_value,
                   p_nbv           => nvl(px_asset_fin_rec_new.cost,0) -
                                      nvl(px_asset_deprn_rec_new.deprn_reserve,0) -
                                      nvl(px_asset_deprn_rec_new.impairment_reserve,0),
                   p_calling_fn    => l_calling_fn,
                   p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;
	 end if;

         -- insure we do not post any catchup for group member
         if (px_asset_fin_rec_new.group_asset_id is not null) and
            nvl(px_asset_fin_rec_new.tracking_method,'OTHER') <> 'CALCULATE' then
            l_deprn_exp       := 0;
            l_bonus_deprn_exp := 0;
            l_impairment_exp  := 0;
         end if;


         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('calx_fin_info', 'calling', 'faxiat', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('calc_fin_info', 'after user exits, adj_cost',
                              px_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
         end if;

         -- insert all the amounts
         -- HH only if this is not a disabled_flag transaction

         -- R12 conditional handling
         -- SLA do not insert cost/clearing for capitalization
         if (px_trans_rec.transaction_type_code = 'ADDITION' and
             (p_asset_fin_rec_old.rate_adjustment_factor is not null or
              G_release = 11)) then
            l_cost_to_insert     := 0;
            l_clearing_to_insert := 0;
         else
            l_cost_to_insert     := p_asset_fin_rec_adj.cost;
            l_clearing_to_insert := p_asset_fin_rec_adj.cost - l_clearing;
         end if;

         if ((G_release <> 11 or
              px_trans_rec.transaction_type_code not in
                ('ADDITION', 'CIP ADDITION')) and
             not l_disabled_flag_changed) then
            if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec       => px_trans_rec,
                      p_asset_hdr_rec   => p_asset_hdr_rec,
                      p_asset_desc_rec  => p_asset_desc_rec,
                      p_asset_cat_rec   => p_asset_cat_rec,
                      p_asset_type_rec  => p_asset_type_rec,
                      p_cost            => l_cost_to_insert,
                      p_clearing        => l_clearing_to_insert,
                      p_deprn_expense   => l_deprn_exp,
                      p_bonus_expense   => l_bonus_deprn_exp,
                      p_impair_expense  => l_impairment_exp,
                      p_ann_adj_amt     => l_ann_adj_deprn_exp, --0
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn      => l_calling_fn
                     , p_log_level_rec => p_log_level_rec) then raise calc_err;
            end if;
         end if; --no change to disabled_flag

         -- ENERGY and allocate in general
         -- Dupulicate group FA_ADJUSTMENTS entries on member asset
         --
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_deprn_exp', l_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_bonus_deprn_exp', l_bonus_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_asset_type_rec.asset_type', p_asset_type_rec.asset_type, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'px_trans_rec.member_transaction_header_id',
                             px_trans_rec.member_transaction_header_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_disabled_flag_changed', l_disabled_flag_changed, p_log_level_rec => p_log_level_rec);
         end if;

         -- Bug7008015: Relocated the condition about amount so that even if there is no expense
         -- at group level, process go thorugh following to determine if there is member reserve
         -- to backed out as expense.
         -- Bug7140693: Removed reinstatement from following condition
         if  (p_asset_type_rec.asset_type = 'GROUP') and
             (px_trans_rec.member_transaction_header_id is not null) and
             (not (l_disabled_flag_changed)) and
             (nvl(px_asset_fin_rec_new.tracking_method,'NO TRACK') = 'ALLOCATE') and
             (px_trans_rec.transaction_key <> 'MR')  then

            OPEN c_get_member_trx;
            FETCH c_get_member_trx INTO l_asset_hdr_rec.asset_id
                                      , l_trans_rec.transaction_header_id
                                      , l_trans_rec.transaction_type_code
                                      , l_trans_rec.transaction_date_entered
                                      , l_trans_rec.transaction_name
                                      , l_trans_rec.source_transaction_header_id
                                      , l_trans_rec.mass_reference_id
                                      , l_trans_rec.transaction_subtype
                                      , l_trans_rec.transaction_key
                                      , l_trans_rec.amortization_start_date
                                      , l_trans_rec.calling_interface
                                      , l_trans_rec.mass_transaction_id
                                      , l_trans_rec.member_transaction_header_id
                                      , l_trans_rec.trx_reference_id
                                      , l_trans_rec.who_info.last_update_date
                                      , l_trans_rec.who_info.last_updated_by
                                      , l_trans_rec.who_info.last_update_login;
            CLOSE c_get_member_trx;

            l_trans_rec.who_info.created_by := l_trans_rec.who_info.last_updated_by;
            l_trans_rec.who_info.creation_date := l_trans_rec.who_info.last_update_date;

            l_asset_hdr_rec.book_type_code := p_asset_hdr_rec.book_type_code;
            l_asset_hdr_rec.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

            -- load the old structs
            if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec,
                     px_asset_fin_rec        => l_asset_fin_rec,
                     p_transaction_header_id => NULL,
                     p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

            if not FA_UTIL_PVT.get_asset_desc_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec,
                     px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

            if not FA_UTIL_PVT.get_asset_cat_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec,
                     px_asset_cat_rec        => l_asset_cat_rec,
                     p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

            if not FA_UTIL_PVT.get_asset_type_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec,
                     px_asset_type_rec       => l_asset_type_rec,
                     p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

            --Bug7008015: Need member reserve
            if not FA_UTIL_PVT.get_asset_deprn_rec
                   (p_asset_hdr_rec         => l_asset_hdr_rec ,
                    px_asset_deprn_rec      => l_asset_deprn_rec,
                    p_period_counter        => NULL,
                    p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;

            -- Bug7008015
            -- Fully reserve member asset if
            -- - l_adjust_type is AMORTIZED: If this is expensed, this won't be necessary as it takes care this
            -- - This is a member asset.  - premature to apply this for all assets
            -- - Tracking method is allocate - premature to apply this for all assets
            -- - This is not group reclass
            -- - There is a change in cost
            -- - New reserve is more than the adj rec cost or adj rec cost is 0 while there is rsv balance
            -- If all above condition is met, asset will be fully reserve by expensing remaining nbv (adj rec cost - rsv)
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_adjust_type', l_adjust_type, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_new.group_asset_id', px_asset_fin_rec_new.group_asset_id, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_new.tracking_method', px_asset_fin_rec_new.tracking_method, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'px_trans_rec.transaction_key', px_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.cost', p_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve', l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.adjusted_recoverable_cost', l_asset_fin_rec.adjusted_recoverable_cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_deprn_exp', l_deprn_exp, p_log_level_rec => p_log_level_rec);
            end if;

            if l_adjust_type = 'AMORTIZED' and
               (not (px_trans_rec.calling_interface = 'FAXASSET' and
                     px_asset_fin_rec_new.adjustment_required_status = 'GADJ')) and
               l_asset_fin_rec.group_asset_id is not null and
               l_asset_fin_rec.tracking_method = 'ALLOCATE' and
               px_trans_rec.transaction_key <> 'GC' and
               nvl(p_asset_fin_rec_adj.cost , 0) <> 0 and
               ( ( ( sign(nvl(l_asset_deprn_rec.deprn_reserve, 0) + nvl(l_deprn_exp, 0)) =
                                                         sign(l_asset_fin_rec.adjusted_recoverable_cost) ) and
                      ( abs(nvl(l_asset_deprn_rec.deprn_reserve, 0) + nvl(l_deprn_exp, 0)) >
                                                         abs(l_asset_fin_rec.adjusted_recoverable_cost)   )  ) or
                 (l_asset_fin_rec.adjusted_recoverable_cost = 0 and l_asset_deprn_rec.deprn_reserve <> 0)     ) then
               l_deprn_exp := l_asset_fin_rec.adjusted_recoverable_cost - nvl(l_asset_deprn_rec.deprn_reserve, 0);
            end if;

            -- Bug7008015: call faxiat only if there is expense to back out for member assets
            if (nvl(l_deprn_exp, 0) <> 0 or nvl(l_bonus_deprn_exp, 0) <> 0 or nvl(l_impairment_exp, 0) <> 0) then
               if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec       => l_trans_rec,
                      p_asset_hdr_rec   => l_asset_hdr_rec,
                      p_asset_desc_rec  => l_asset_desc_rec,
                      p_asset_cat_rec   => l_asset_cat_rec,
                      p_asset_type_rec  => l_asset_type_rec,
                      p_cost            => 0,
                      p_clearing        => 0,
                      p_deprn_expense   => l_deprn_exp,
                      p_bonus_expense   => l_bonus_deprn_exp,
                      p_impair_expense  => l_impairment_exp,
                      p_ann_adj_amt     => 0,
                      p_track_member_flag => 'Y',
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn      => l_calling_fn, p_log_level_rec => p_log_level_rec) then
                  raise calc_err;
               end if;
            end if;

         end if;
         -- End of ENERGY Change

         -- When Group Adjustment is processed for the group whose tracking
         -- method is allocate but the transaction kicked at group level,
         -- expense must be allocated to members.
         -- HH assuming this is not a change to disabled_flag

         -- R12 conditional logic
         -- SLA voids are obsolete so group adjustments happen in period of add
         -- why are group adjustments i period of add not processed here

         if (G_release = 11 or
             p_asset_hdr_rec.period_of_addition <> 'Y') and
            px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
            px_trans_rec.member_transaction_header_id is null and
            nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' and
            not l_disabled_flag_changed then

           -- Call TRACK_ASSETS
           l_rc := fa_track_member_pvt.track_assets
                     (P_book_type_code             => p_asset_hdr_rec.book_type_code,
                      P_group_asset_id             => p_asset_hdr_rec.asset_id,
                      P_period_counter             => p_period_rec.period_num,
                      P_fiscal_year                => p_period_rec.fiscal_year,
                      P_group_deprn_basis          => fa_cache_pkg.fazccmt_record.deprn_basis_rule,
                      P_group_exclude_salvage      => fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag,
                      P_group_bonus_rule           => px_asset_fin_rec_new.bonus_rule,
                      P_group_deprn_amount         => l_deprn_exp,
                      P_group_bonus_amount         => l_bonus_deprn_exp,
                      P_tracking_method            => px_asset_fin_rec_new.tracking_method,
                      P_allocate_to_fully_ret_flag => px_asset_fin_rec_new.allocate_to_fully_ret_flag,
                      P_allocate_to_fully_rsv_flag => px_asset_fin_rec_new.allocate_to_fully_rsv_flag,
                      P_excess_allocation_option   => px_asset_fin_rec_new.excess_allocation_option,
                      P_depreciation_option        => px_asset_fin_rec_new.depreciation_option,
                      P_member_rollup_flag         => px_asset_fin_rec_new.member_rollup_flag,
                      P_group_level_override       => l_group_level_override,
                      P_period_of_addition         => p_asset_hdr_rec.period_of_addition,
                      P_transaction_date_entered   =>
                      px_trans_rec.transaction_date_entered, --HH: Added for 6782497
                      P_mode                       => 'GROUP ADJUSTMENT',
                      P_mrc_sob_type_code          => p_mrc_sob_type_code,
                      P_set_of_books_id            => p_asset_hdr_rec.set_of_books_id,
                      X_new_deprn_amount           => x_new_deprn_amount,
                      X_new_bonus_amount           => x_new_bonus_amount,  p_log_level_rec => p_log_level_rec);
           if l_rc <> 0  then
             raise calc_err;
           end if;
         end if;


      end if;

   end if;
   return true;

EXCEPTION

   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_fin_info;


FUNCTION calc_new_amounts
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_reval_ceiling_adj NUMBER; -- BUG 2620221

   l_calling_fn     VARCHAR2(40) := 'fa_asset_calc_pvt.calc_new_amounts';
   calc_err         EXCEPTION;

BEGIN


   --  This procedure basically sets all new info by deriving it from the old and adjustment structures.
   --  For additions, all will end up coming from the adj struct.
   --
   --  Different values can be intentionally nulled out / removed, but most can not...
   --  The depreciation related info, including method, life, short tax, bonus, etc will all
   --  be addressed by the validate_deprn_info function

   -- Set all non-calculated and non-method info

   -- these values can be nulled out intentionally so we use
   -- G_MISS values for defaults - ceiling hand group have been removed
   -- and merged in the bonus area becuase of the impacts of
   -- defaulting for additions

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.itc_amount_id,
        p_num_adj  => p_asset_fin_rec_adj.itc_amount_id,
        x_num_new  => px_asset_fin_rec_new.itc_amount_id, p_log_level_rec => p_log_level_rec);

   -- added for group enhancements

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.super_group_id,
        p_num_adj  => p_asset_fin_rec_adj.super_group_id,
        x_num_new  => px_asset_fin_rec_new.super_group_id, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
       (p_num_old  => p_asset_fin_rec_old.cash_generating_unit_id,
        p_num_adj  => p_asset_fin_rec_adj.cash_generating_unit_id,
        x_num_new  => px_asset_fin_rec_new.cash_generating_unit_id, p_log_level_rec => p_log_level_rec);

   -- moved dirivation of the salvage and limit types back down to their respective functions

   -- these values must be populated - null in adjust means they must be set to old values

   px_asset_fin_rec_new.date_placed_in_service    := nvl(p_asset_fin_rec_adj.date_placed_in_service,
                                                           p_asset_fin_rec_old.date_placed_in_service);

   -- amounts that may increase to adjustment
   px_asset_fin_rec_new.cost                      := nvl(p_asset_fin_rec_adj.cost, 0) +
                                                       nvl(p_asset_fin_rec_old.cost, 0);

   if (p_asset_type_rec.asset_type = 'CIP' or
       p_asset_type_rec.asset_type = 'GROUP') then
      px_asset_fin_rec_new.cip_cost               := nvl(p_asset_fin_rec_adj.cip_cost, 0) +
                                                       nvl(p_asset_fin_rec_old.cip_cost, 0);
   else
      px_asset_fin_rec_new.cip_cost               := 0;
   end if;

   px_asset_fin_rec_new.production_capacity       := nvl(p_asset_fin_rec_adj.production_capacity, 0) +
                                                       nvl(p_asset_fin_rec_old.production_capacity, 0);
   px_asset_fin_rec_new.fully_rsvd_revals_counter := nvl(p_asset_fin_rec_adj.fully_rsvd_revals_counter, 0) +
                                                       nvl(p_asset_fin_rec_old.fully_rsvd_revals_counter, 0);
   px_asset_fin_rec_new.reval_amortization_basis  := nvl(p_asset_fin_rec_adj.reval_amortization_basis, 0) +
                                                       nvl(p_asset_fin_rec_old.reval_amortization_basis, 0);

   -- Bug 6795070: insert into fa_deprn_summary is based on
   -- px_asset_deprn_rec_new
   px_asset_deprn_rec_new.reval_amortization_basis  := nvl(p_asset_deprn_rec_adj.reval_amortization_basis, 0) +
                                                       nvl(p_asset_deprn_rec_old.reval_amortization_basis, 0);

   -- Commenting this for the bug 2620221
   /*
   if (p_asset_fin_rec_old.reval_ceiling is null and
       p_asset_fin_rec_adj.reval_ceiling is null) then
       px_asset_fin_rec_new.reval_ceiling         := null;
   else
       px_asset_fin_rec_new.reval_ceiling         := nvl(p_asset_fin_rec_adj.reval_ceiling, 0) +
                                                       nvl(p_asset_fin_rec_old.reval_ceiling, 0);
   end if;
   */


   -- Adding this for the BUG 2620221
   -- If the value of  p_asset_fin_rec_adj.reval_ceiling is FND_API.G_MISS_NUM then make it NULL
   -- And after this calculate the value of New Reval Ceiling differently when the Adjusted Reval
   -- Ceiling is NULL.
   if (p_asset_fin_rec_adj.reval_ceiling = FND_API.G_MISS_NUM) then
       l_reval_ceiling_adj := null;
   else
       l_reval_ceiling_adj := p_asset_fin_rec_adj.reval_ceiling;
   end if;

   if (l_reval_ceiling_adj is NULL) then
       px_asset_fin_rec_new.reval_ceiling := NULL;
   else
       px_asset_fin_rec_new.reval_ceiling := nvl(l_reval_ceiling_adj, 0) +
                                             nvl(p_asset_fin_rec_old.reval_ceiling, 0);
   end if;

   px_asset_fin_rec_new.unrevalued_cost           := nvl(p_asset_fin_rec_adj.unrevalued_cost,
                                                           nvl(p_asset_fin_rec_adj.cost, 0)) +
                                                       nvl(p_asset_fin_rec_old.unrevalued_cost,
                                                           nvl(p_asset_fin_rec_old.cost, 0));
   px_asset_fin_rec_new.cip_cost                  := nvl(p_asset_fin_rec_adj.cip_cost, 0) +
                                                       nvl(p_asset_fin_rec_old.cip_cost, 0);


   -- SLA Uptake
   -- keeping this for now, but it may need to change
   -- intention is to allow the new amounts to be calculated,
   -- but insert the ADJ via faxiat


   if (p_asset_hdr_rec.period_of_addition = 'Y') then

      if px_trans_rec.transaction_type_code = 'ADDITION' then /*Bug# - 9212314 */
         px_asset_fin_rec_new.original_cost             := nvl(p_asset_fin_rec_adj.original_cost,
                                                              nvl(p_asset_fin_rec_adj.cost, 0)) +
                                                          nvl(p_asset_fin_rec_old.original_cost,
                                                              nvl(p_asset_fin_rec_old.cost, 0));
      else
         px_asset_fin_rec_new.original_cost             := nvl(p_asset_fin_rec_old.original_cost,0);
      end if;
      px_asset_deprn_rec_new.deprn_amount            := 0;
      px_asset_deprn_rec_new.deprn_reserve           := nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) +
                                                          nvl(p_asset_deprn_rec_old.deprn_reserve, 0);
      px_asset_deprn_rec_new.ytd_deprn               := nvl(p_asset_deprn_rec_adj.ytd_deprn, 0) +
                                                          nvl(p_asset_deprn_rec_old.ytd_deprn, 0);
      px_asset_deprn_rec_new.reval_deprn_reserve     := nvl(p_asset_deprn_rec_adj.reval_deprn_reserve, 0) +
                                                          nvl(p_asset_deprn_rec_old.reval_deprn_reserve, 0);
      px_asset_deprn_rec_new.reval_ytd_deprn         := nvl(p_asset_deprn_rec_adj.reval_ytd_deprn, 0) +
                                                          nvl(p_asset_deprn_rec_old.reval_ytd_deprn, 0);
      px_asset_deprn_rec_new.production              := nvl(p_asset_deprn_rec_adj.production, 0) +
                                                          nvl(p_asset_deprn_rec_old.production, 0);
      px_asset_deprn_rec_new.ltd_production          := nvl(p_asset_deprn_rec_adj.ltd_production, 0) +
                                                          nvl(p_asset_deprn_rec_old.ltd_production, 0);
      px_asset_deprn_rec_new.ytd_production          := nvl(p_asset_deprn_rec_adj.ytd_production, 0) +
                                                          nvl(p_asset_deprn_rec_old.ytd_production, 0);

      px_asset_deprn_rec_new.bonus_deprn_amount      := 0;
      px_asset_deprn_rec_new.bonus_deprn_reserve     := nvl(p_asset_deprn_rec_adj.bonus_deprn_reserve, 0) +
                                                          nvl(p_asset_deprn_rec_old.bonus_deprn_reserve, 0);
      px_asset_deprn_rec_new.bonus_ytd_deprn         := nvl(p_asset_deprn_rec_adj.bonus_ytd_deprn, 0) +
                                                          nvl(p_asset_deprn_rec_old.bonus_ytd_deprn, 0);
      px_asset_deprn_rec_new.impairment_amount       := 0;
      px_asset_deprn_rec_new.ytd_impairment          := 0;
      px_asset_deprn_rec_new.impairment_reserve          := 0;
   else

      px_asset_fin_rec_new.original_cost             := nvl(p_asset_fin_rec_old.original_cost,0);
      px_asset_deprn_rec_new.deprn_reserve           := nvl(p_asset_deprn_rec_old.deprn_reserve, 0);
      px_asset_deprn_rec_new.ytd_deprn               := nvl(p_asset_deprn_rec_old.ytd_deprn, 0);
      px_asset_deprn_rec_new.reval_deprn_reserve     := nvl(p_asset_deprn_rec_old.reval_deprn_reserve, 0);
      px_asset_deprn_rec_new.reval_ytd_deprn         := nvl(p_asset_deprn_rec_old.reval_ytd_deprn, 0);
      px_asset_deprn_rec_new.ltd_production          := nvl(p_asset_deprn_rec_old.ltd_production, 0);
      px_asset_deprn_rec_new.ytd_production          := nvl(p_asset_deprn_rec_old.ytd_production, 0);
      px_asset_deprn_rec_new.bonus_deprn_reserve     := nvl(p_asset_deprn_rec_old.bonus_deprn_reserve, 0);
      px_asset_deprn_rec_new.bonus_ytd_deprn         := nvl(p_asset_deprn_rec_old.bonus_ytd_deprn, 0);
      px_asset_deprn_rec_new.impairment_amount       := nvl(p_asset_deprn_rec_old.impairment_amount, 0);
      px_asset_deprn_rec_new.ytd_impairment          := nvl(p_asset_deprn_rec_old.ytd_impairment, 0);
      px_asset_deprn_rec_new.impairment_reserve          := nvl(p_asset_deprn_rec_old.impairment_reserve, 0);

   end if;

   px_asset_fin_rec_new.short_fiscal_year_flag    := nvl(p_asset_fin_rec_adj.short_fiscal_year_flag,
                                                           nvl(p_asset_fin_rec_old.short_fiscal_year_flag, 'NO'));

   if (px_asset_fin_rec_new.short_fiscal_year_flag = 'YES') then
      px_asset_fin_rec_new.conversion_date           := nvl(p_asset_fin_rec_adj.conversion_date,
                                                              p_asset_fin_rec_old.conversion_date);
      px_asset_fin_rec_new.orig_deprn_start_date     := nvl(p_asset_fin_rec_adj.orig_deprn_start_date,
                                                              p_asset_fin_rec_old.orig_deprn_start_date);
   else
      px_asset_fin_rec_new.conversion_date           := null;
      px_asset_fin_rec_new.orig_deprn_start_date     := null;
   end if;

   -- Japan Tax Phase3
   FA_UTIL_PVT.load_char_value
      (p_char_old  => p_asset_fin_rec_old.extended_deprn_flag,
       p_char_adj  => p_asset_fin_rec_adj.extended_deprn_flag,
       x_char_new  => px_asset_fin_rec_new.extended_deprn_flag, p_log_level_rec => p_log_level_rec);

   FA_UTIL_PVT.load_num_value
      (p_num_old  => p_asset_fin_rec_old.extended_depreciation_period,
       p_num_adj  => p_asset_fin_rec_adj.extended_depreciation_period,
       x_num_new  => px_asset_fin_rec_new.extended_depreciation_period, p_log_level_rec => p_log_level_rec);

   -- round those values holding currency amounts
   -- converted to use utils package instead of fa_round_pkg
   -- so that the correct sob (P/R) is always used to get currency


   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;


   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.original_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.reval_amortization_basis,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.reval_ceiling,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.unrevalued_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.cip_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.deprn_reserve,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.ytd_deprn,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.reval_deprn_reserve,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.reval_ytd_deprn,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.bonus_deprn_reserve,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.bonus_ytd_deprn,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.impairment_reserve,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_deprn_rec_new.ytd_impairment,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if (p_mrc_sob_type_code <> 'R' and p_asset_type_rec.asset_type <> 'GROUP') then --Bug 9099190
       G_primary_new_cost := px_asset_fin_rec_new.cost;
   end if;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;


END calc_new_amounts;

FUNCTION calc_derived_amounts
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_count        number := 0;
   l_calling_fn   VARCHAR2(40) := 'fa_asset_calc_pvt.calc_derived_amounts';
   calc_err       EXCEPTION;

BEGIN

   if not calc_deprn_start_date
          (p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
           px_asset_fin_rec_new      => px_asset_fin_rec_new,
           p_log_level_rec           => p_log_level_rec
          ) then
            raise calc_err;
   end if;

   if not calc_salvage_value
          (p_trans_rec               => px_trans_rec,
           p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_type_rec          => p_asset_type_rec,
           p_asset_fin_rec_old       => p_asset_fin_rec_old,
           p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
           px_asset_fin_rec_new      => px_asset_fin_rec_new,
           p_mrc_sob_type_code       => p_mrc_sob_type_code,
           p_log_level_rec           => p_log_level_rec
          ) then
      raise calc_err;
   end if;

   -- BUG# 2650528
   -- need to call calc_itc_info before calc_rec_cost
   -- in order to get the itc_basis otherwise the rec_cost
   -- would just be set to null

   if (fa_cache_pkg.fazcbc_record.book_class = 'TAX' and
       px_asset_fin_rec_new.itc_amount_id is not null) then
      if not calc_itc_info
             (p_asset_hdr_rec           => p_asset_hdr_rec,
              p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
              px_asset_fin_rec_new      => px_asset_fin_rec_new,
              p_log_level_rec           => p_log_level_rec
             ) then
         raise calc_err;
      end if;
   end if;

   if not calc_rec_cost
          (p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
           px_asset_fin_rec_new      => px_asset_fin_rec_new,
           p_log_level_rec           => p_log_level_rec
          ) then
      raise calc_err;
   end if;


   if not calc_deprn_limit_adj_rec_cost
          (p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_type_rec          => p_asset_type_rec,
           p_asset_fin_rec_old       => p_asset_fin_rec_old,
           p_asset_fin_rec_adj       => p_asset_fin_rec_adj,
           px_asset_fin_rec_new      => px_asset_fin_rec_new,
           p_mrc_sob_type_code       => p_mrc_sob_type_code,
           p_log_level_rec           => p_log_level_rec
          ) then
      raise calc_err;
   end if;


   if not calc_flags
          (p_trans_rec               => px_trans_rec,
           p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_type_rec          => p_asset_type_rec,
           p_asset_fin_rec_old       => p_asset_fin_rec_old,
           px_asset_fin_rec_new      => px_asset_fin_rec_new,
           p_asset_deprn_rec         => px_asset_deprn_rec_new,
           p_period_rec              => p_period_rec,
           p_log_level_rec           => p_log_level_rec
          ) then
      raise calc_err;
   end if;

   -- Japan Tax phase3 Start
   -- Bug 8559068 base bug 7707540: load_num_value is called only while setting/resetting
   -- the extended_deprn_flag also removed the fix for 6707623
   -- bug 8819226 do not change the value of both flags when deprn flag is switched ON/OFF
   -- Bug 9244648: Set pc_fully_rsvd when called from tax upload
   if ((nvl(p_asset_fin_rec_old.extended_deprn_flag, '-1') <> nvl(p_asset_fin_rec_adj.extended_deprn_flag, '-1'))
        OR (nvl(p_asset_fin_rec_old.extended_deprn_flag, '-1') = 'Y')
        OR (nvl(px_trans_rec.calling_interface,'X') = 'FATAXUP'))
       and nvl(fnd_profile.value('FA_JAPAN_TAX_REFORMS'),'N') = 'Y' then

      FA_UTIL_PVT.load_num_value
         (p_num_old  => p_asset_fin_rec_old.period_counter_life_complete,
          p_num_adj  => p_asset_fin_rec_adj.period_counter_life_complete,
          x_num_new  => px_asset_fin_rec_new.period_counter_life_complete,
          p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_num_value
         (p_num_old  => p_asset_fin_rec_old.period_counter_fully_reserved,
          p_num_adj  => p_asset_fin_rec_adj.period_counter_fully_reserved,
          x_num_new  => px_asset_fin_rec_new.period_counter_fully_reserved,
          p_log_level_rec => p_log_level_rec);

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: deprn_method_code', px_asset_fin_rec_new.deprn_method_code, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: life_in_months', px_asset_fin_rec_new.life_in_months, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: salvage_value', px_asset_fin_rec_new.salvage_value, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: period_counter_fully_reserved',
                       px_asset_fin_rec_new.period_counter_fully_reserved, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: period_counter_life_complete',
                       px_asset_fin_rec_new.period_counter_life_complete, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: basic_rate', px_asset_fin_rec_new.basic_rate, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: adjusted_rate', px_asset_fin_rec_new.adjusted_rate, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: allowed_deprn_limit',
                       px_asset_fin_rec_new.allowed_deprn_limit, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: deprn_limit_type', px_asset_fin_rec_new.deprn_limit_type, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: allowed_deprn_limit_amount',
                       px_asset_fin_rec_new.allowed_deprn_limit_amount, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: recoverable_cost', px_asset_fin_rec_new.recoverable_cost, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'JPTX1: adjusted_rate', p_asset_fin_rec_old.adjusted_rate, p_log_level_rec);
   end if;
   -- Japan Tax phase3 End

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_derived_amounts;


FUNCTION calc_prorate_date
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_count                number:= 0;
   l_prorate_calendar     varchar2(15);
   l_fiscal_year_name     varchar2(30);
   l_calling_fn           varchar2(40) := 'fa_asset_calc_pvt.calc_prorate_date';
   calc_err               EXCEPTION;

BEGIN

   l_prorate_calendar     := fa_cache_pkg.fazcbc_record.prorate_calendar;
   l_fiscal_year_name     := fa_cache_pkg.fazcbc_record.fiscal_year_name;

   if (p_asset_type_rec.asset_type = 'GROUP') then
      px_asset_fin_rec_new.prorate_date := px_asset_fin_rec_new.date_placed_in_service;
   else

      if (px_asset_fin_rec_new.prorate_convention_code is null) then
          fa_srvr_msg.add_message(
                   calling_fn => l_calling_fn,
                   name       => 'FA_EXP_GET_PRORATE_INFO', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;

      if not fa_cache_pkg.fazccvt
               (x_prorate_convention_code => px_asset_fin_rec_new.prorate_convention_code,
                x_fiscal_year_name        => l_fiscal_year_name, p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_new.prorate_convention_code', px_asset_fin_rec_new.prorate_convention_code, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_new.date_placed_in_service', px_asset_fin_rec_new.date_placed_in_service, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_prorate_calendar', l_prorate_calendar, p_log_level_rec => p_log_level_rec);
      end if;

      select /*+ leading(conv) use_nl(conv cp) index(cp) */
             prorate_date
        into px_asset_fin_rec_new.prorate_date
        from fa_calendar_periods cp,
             fa_conventions conv
       where conv.prorate_convention_code   = px_asset_fin_rec_new.prorate_convention_code
         and conv.start_date               <= px_asset_fin_rec_new.date_placed_in_service
         and conv.end_date                 >= px_asset_fin_rec_new.date_placed_in_service
         and cp.calendar_type               = l_prorate_calendar
         and conv.prorate_date             >= cp.start_date
         and conv.prorate_date             <= cp.end_date;

         -- BUG# 2251278
         -- removing the following as it prevent prorate periods that
         -- fall in a future period (such as FOL-MONTH)
         --
         -- and conv.prorate_date             <= p_period_rec.fy_end_date;

    end if; -- (p_asset_type_rec.asset_type = 'GROUP')

    -- For Polish, we need additional changes here.
    -- First find out if we have a polish mechanism here
    if (nvl(px_asset_fin_rec_new.deprn_method_code,
            p_asset_fin_rec_adj.deprn_method_code) is not null) and
       (fa_cache_pkg.fazccmt (
       X_method                => nvl(px_asset_fin_rec_new.deprn_method_code,
                                      p_asset_fin_rec_adj.deprn_method_code),
       X_life                  => nvl(px_asset_fin_rec_new.life_in_months,
                                      p_asset_fin_rec_adj.life_in_months),
       p_log_level_rec         => p_log_level_rec
    )) then
       if (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id is not null) then
          if (fa_cache_pkg.fazcdbr_record.polish_rule in (
                   FA_STD_TYPES.FAD_DBR_POLISH_1,
                   FA_STD_TYPES.FAD_DBR_POLISH_2)) then
             -- For Polish rules 1 and 2, set prorate_date based on dpis
             -- regardless of prorate convention.
             px_asset_fin_rec_new.prorate_date :=
                px_asset_fin_rec_new.date_placed_in_service;
          end if;
       end if;
    end if;

    return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when no_data_found then
      fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_EXP_GET_PRORATE_INFO', p_log_level_rec => p_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

END calc_prorate_date;

FUNCTION calc_deprn_start_date
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_dwaf              varchar2(3);
   l_fiscal_year_name  varchar2(30);
   l_calling_fn        varchar2(40) := 'fa_asset_calc_pvt.calc_deprn_start_date';
   calc_err            EXCEPTION;

BEGIN

    l_fiscal_year_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;

    if not fa_cache_pkg.fazccvt
             (x_prorate_convention_code => px_asset_fin_rec_new.prorate_convention_code,
              x_fiscal_year_name        => l_fiscal_year_name, p_log_level_rec => p_log_level_rec) then
       raise calc_err;
    end if;

    l_dwaf := fa_cache_pkg.fazccvt_record.depr_when_acquired_flag;

    if (l_dwaf = 'YES') then
       px_asset_fin_rec_new.deprn_start_date := px_asset_fin_rec_new.date_placed_in_service;
    else
       px_asset_fin_rec_new.deprn_start_date := px_asset_fin_rec_new.prorate_date;
    end if;

    if px_asset_fin_rec_new.deprn_start_date is null then
      raise calc_err;
    end if;

    return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_deprn_start_date;


FUNCTION calc_rec_cost
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   CURSOR c_get_rec_cost_w_ceiling IS
    select least(px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value,
                      nvl(ce.limit, px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value))
      from fa_ceilings ce
     where ce.ceiling_name  = px_asset_fin_rec_new.ceiling_name
       and px_asset_fin_rec_new.date_placed_in_service
               between ce.start_date and
                       nvl(ce.end_date, px_asset_fin_rec_new.date_placed_in_service);

   l_ceiling_type   varchar2(30);
   l_calling_fn     varchar2(40) := 'fa_asset_calc_pvt.calc_rec_cost';

   l_temp_rec_cost  number;

   calc_err         EXCEPTION;

BEGIN

   -- can probably convert to cache calls here

   if (px_asset_fin_rec_new.ceiling_name is not null) then
         select ceiling_type
           into l_ceiling_type
           from fa_ceiling_types
          where ceiling_name = px_asset_fin_rec_new.ceiling_name;
   end if;

   if (px_asset_fin_rec_new.itc_amount_id is null) then

      if l_ceiling_type = 'RECOVERABLE COST CEILING' then

         OPEN c_get_rec_cost_w_ceiling;
         FETCH c_get_rec_cost_w_ceiling INTO l_temp_rec_cost;

         if c_get_rec_cost_w_ceiling%NOTFOUND then
            px_asset_fin_rec_new.recoverable_cost := px_asset_fin_rec_new.cost -
                                                     px_asset_fin_rec_new.salvage_value;
         else
            px_asset_fin_rec_new.recoverable_cost := l_temp_rec_cost;
         end if;

         CLOSE c_get_rec_cost_w_ceiling;

      else
         px_asset_fin_rec_new.recoverable_cost :=
            px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value;

      end if;
   else
      if (l_ceiling_type = 'RECOVERABLE COST CEILING') then
         select least(px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value -
                      px_asset_fin_rec_new.itc_basis * ir.basis_reduction_rate,
                      nvl(ce.limit, px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value -
                                    px_asset_fin_rec_new.itc_basis * ir.basis_reduction_rate))
          into px_asset_fin_rec_new.recoverable_cost
          from fa_ceilings ce,
               fa_itc_rates ir
         where ir.itc_amount_id = px_asset_fin_rec_new.itc_amount_id
           and ce.ceiling_name = px_asset_fin_rec_new.ceiling_name
           and px_asset_fin_rec_new.date_placed_in_service
               between ce.start_date and
                       nvl(ce.end_date, px_asset_fin_rec_new.date_placed_in_service);

      else
         select px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value -
                px_asset_fin_rec_new.itc_basis * ir.basis_reduction_rate
           into px_asset_fin_rec_new.recoverable_cost
           from fa_itc_rates ir
          where ir.itc_amount_id = px_asset_fin_rec_new.itc_amount_id;
      end if;
   end if;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_rec_cost;


FUNCTION calc_deprn_limit_adj_rec_cost
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_called_from_faxama      IN     BOOLEAN DEFAULT FALSE, -- Bug 6604235
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn     VARCHAR2(40) := 'fa_asset_calc_pvt.calc_deprn_limit';
   calc_err         EXCEPTION;

BEGIN

   -- like % salvage, we will now allow direct entry of limits on
   -- an asset by asset basis as part of the group project and
   -- no longer mandate from category

   -- reclass with redefault MUST explicitly populate the
   -- fin_adj rec with the new categories info (including treating
   -- the amount as a delta) ???  verify feasibility of ths last point ???

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'deprn_limit type',
                       p_asset_fin_rec_old.deprn_limit_type, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'salvage type',
                       p_asset_fin_rec_adj.deprn_limit_type, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'delta deprn limit',
                       p_asset_fin_rec_adj.allowed_deprn_limit, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'delta deprn limit amount',
                       p_asset_fin_rec_adj.allowed_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
   end if;

   px_asset_fin_rec_new.deprn_limit_type :=
      nvl(p_asset_fin_rec_adj.deprn_limit_type,
          nvl(p_asset_fin_rec_old.deprn_limit_type, 'NONE'));

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'limit type',
                       px_asset_fin_rec_new.deprn_limit_type, p_log_level_rec => p_log_level_rec);
   end if;

   -- Bug 6863138 When called from faxama, adj rec will have new values
   if p_called_from_faxama then
         px_asset_fin_rec_new.allowed_deprn_limit := p_asset_fin_rec_adj.allowed_deprn_limit;
         px_asset_fin_rec_new.allowed_deprn_limit_amount := p_asset_fin_rec_adj.allowed_deprn_limit_amount;
-- Bug#6913554,For calculating correct reserve amount during back dated retirement transaction.
       if px_asset_fin_rec_new.cost <> 0 then
         px_asset_fin_rec_new.adjusted_recoverable_cost :=
                   px_asset_fin_rec_new.cost - nvl(px_asset_fin_rec_new.allowed_deprn_limit_amount,0);
       else
         px_asset_fin_rec_new.adjusted_recoverable_cost := 0;
       end if;
--Bug#6913554,End of fix.


      -- round the  adj_rec_cost
      if not FA_UTILS_PKG.faxfloor(px_asset_fin_rec_new.adjusted_recoverable_cost,
                                   p_asset_hdr_rec.book_type_code,
                                   p_asset_hdr_rec.set_of_books_id,
                                   p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'From faxama new allowed_deprn_limit_amount',
                          px_asset_fin_rec_new.allowed_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,
                          'new allowed_deprn_limit',
                          px_asset_fin_rec_new.allowed_deprn_limit, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,
                          'px_asset_fin_rec_new.adjusted_recoverable_cost',
                          px_asset_fin_rec_new.adjusted_recoverable_cost, p_log_level_rec => p_log_level_rec);
      end if;

      return true;

   end if;
   -- Bug 6863138 End

   if (px_asset_fin_rec_new.deprn_limit_type = 'SUM' and
       p_asset_type_rec.asset_type <> 'GROUP') then
      fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => '***FA_NO_SUM_NO_GROUP***',
                   p_log_level_rec => p_log_level_rec);
      raise calc_err;
   elsif (px_asset_fin_rec_new.deprn_limit_type = 'AMT' and
       p_asset_type_rec.asset_type = 'GROUP') then
      fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => '***FA_NO_LIM_AMT_FOR_GROUP***',
                   p_log_level_rec => p_log_level_rec);
      raise calc_err;
   elsif (px_asset_fin_rec_new.deprn_limit_type <> 'AMT' and
          px_asset_fin_rec_new.deprn_limit_type <> 'PCT' and
          px_asset_fin_rec_new.deprn_limit_type <> 'SUM' and
          px_asset_fin_rec_new.deprn_limit_type <> 'NONE') then
      fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => 'FA_INVALID_PARAMETER',
         token1     => 'VALUE',
         value1     => px_asset_fin_rec_new.deprn_limit_type,
         token2     => 'PARAM',
         value2     => 'DEPRN_LIMIT_TYPE', p_log_level_rec => p_log_level_rec);
      raise calc_err;
   end if;



   -- enhancing for group and core to allow direct percentage
   -- entry for the assets and not just defaults from category
   -- note that we initially set the new value for the salvage %
   -- in calc_new_amounts and use that here.
   --
   -- NOTE: we loaded the "new.deprn_limit_type" value previously
   -- NOTE2: limit amount must be truncated
   --
   if (px_asset_fin_rec_new.deprn_limit_type = 'PCT') then
      -- use the percentage
      px_asset_fin_rec_new.allowed_deprn_limit := (nvl(p_asset_fin_rec_adj.allowed_deprn_limit, 0) +
                                                   nvl(p_asset_fin_rec_old.allowed_deprn_limit, 0));

      px_asset_fin_rec_new.allowed_deprn_limit_amount := px_asset_fin_rec_new.cost -
                                            (px_asset_fin_rec_new.cost *
                                             px_asset_fin_rec_new.allowed_deprn_limit);

      -- BUG# 3092066
      -- use ceiling here, not round
      -- this results in a floor on the final amount
      if not FA_UTILS_PKG.faxceil(px_asset_fin_rec_new.allowed_deprn_limit_amount,
                                   p_asset_hdr_rec.book_type_code,
                                   p_asset_hdr_rec.set_of_books_id,
                                   p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      px_asset_fin_rec_new.adjusted_recoverable_cost :=
              px_asset_fin_rec_new.cost - px_asset_fin_rec_new.allowed_deprn_limit_amount;

   elsif (px_asset_fin_rec_new.deprn_limit_type = 'SUM') then
      -- this is used only for group assets
      -- performance may not be too great here


      -- BUG# 3198440
      -- for additions (old rec is null) just set to 0

      px_asset_fin_rec_new.allowed_deprn_limit := null;

      if (p_asset_fin_rec_old.deprn_limit_type is null) then
         px_asset_fin_rec_new.allowed_deprn_limit_amount := 0;
      elsif (p_asset_fin_rec_old.deprn_limit_type <> 'SUM') then
         if (p_mrc_sob_type_code <> 'R') then
            select nvl(sum(allowed_deprn_limit_amount), 0)
              into px_asset_fin_rec_new.allowed_deprn_limit_amount
              from fa_books bk,
                   fa_additions_b ad
             where bk.transaction_header_id_out is null
               and bk.group_asset_id = p_asset_hdr_rec.asset_id
               and bk.asset_id = ad.asset_id
               and bk.book_type_code = p_asset_hdr_rec.book_type_code
               and ad.asset_type = 'CAPITALIZED';
         else
            select nvl(sum(allowed_deprn_limit_amount), 0)
              into px_asset_fin_rec_new.allowed_deprn_limit_amount
              from fa_mc_books bk,
                   fa_additions_b ad
             where bk.transaction_header_id_out is null
               and bk.group_asset_id = p_asset_hdr_rec.asset_id
               and bk.asset_id = ad.asset_id
               and bk.book_type_code = p_asset_hdr_rec.book_type_code
               and ad.asset_type = 'CAPITALIZED'
               and bk.set_of_books_id = p_asset_hdr_rec.set_of_books_id;
         end if;

      else
         px_asset_fin_rec_new.allowed_deprn_limit_amount :=
               nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) +
               nvl(p_asset_fin_rec_old.allowed_deprn_limit_amount, 0);
      end if;

      -- validation
      if (px_asset_fin_rec_new.allowed_deprn_limit_amount = 0) then
          px_asset_fin_rec_new.adjusted_recoverable_cost :=
             px_asset_fin_rec_new.recoverable_cost;
      else
         px_asset_fin_rec_new.adjusted_recoverable_cost :=
            px_asset_fin_rec_new.cost - px_asset_fin_rec_new.allowed_deprn_limit_amount;
      end if;
   elsif (px_asset_fin_rec_new.deprn_limit_type = 'AMT') then
      px_asset_fin_rec_new.allowed_deprn_limit := null;

      -- delta salvage amount may or may not be null
      -- use it or 0 for the delta
      if (p_mrc_sob_type_code <> 'R') then

         -- BUG# 3516255
         -- when changing types, the delta is treated as the new amount
         -- we will not add to the prior value that may have been
         -- existed/calculated from previous type of PCT or SUM
         -- Bug 6705332 While extending assets
         -- p_asset_fin_rec_adj.allowed_deprn_limit_amount contains the final value.
         -- BUG 6806294 added the another 'OR' condition to check for ext deprn flag change
         if (p_asset_fin_rec_old.deprn_limit_type <> 'AMT') or
            ((nvl(p_asset_fin_rec_old.extended_deprn_flag,'N') <> 'Y') and
             (nvl(px_asset_fin_rec_new.extended_deprn_flag,'N') = 'Y'))
             or
             ((nvl(p_asset_fin_rec_old.extended_deprn_flag,'N') = 'Y') and
              (nvl(px_asset_fin_rec_new.extended_deprn_flag,'N') <> 'Y')) then
            px_asset_fin_rec_new.allowed_deprn_limit_amount :=
               nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0);

         else
            px_asset_fin_rec_new.allowed_deprn_limit_amount :=
               nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) +
                  nvl(p_asset_fin_rec_old.allowed_deprn_limit_amount, 0);
         end if;

         -- Bug 6604235 The validation need not be executed when
         -- calc_deprn_limit_adj_rec_cost is called from faxama
         -- (where we are recalculating from beginning).
         if (not p_called_from_faxama) and
            ((px_asset_fin_rec_new.cost > 0 and
              px_asset_fin_rec_new.allowed_deprn_limit_amount < 0) or
             (px_asset_fin_rec_new.cost < 0 and
              px_asset_fin_rec_new.allowed_deprn_limit_amount > 0)) then
            fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => '***FA_DIFF_SIGN_LIMIT***',
                   p_log_level_rec => p_log_level_rec);
            raise calc_err;
         elsif (px_asset_fin_rec_new.cost = 0) then
            px_asset_fin_rec_new.allowed_deprn_limit_amount  := 0;
         end if;

         G_primary_deprn_limit_amount := px_asset_fin_rec_new.allowed_deprn_limit_amount;

      else
          -- Fix for Bug #2914328.  Need to also make sure that
          -- G_primary_new_cost is not zero to avoid zero divide error.
         if (px_asset_fin_rec_new.cost <> 0) and
            (G_primary_new_cost <> 0) then
            px_asset_fin_rec_new.allowed_deprn_limit_amount :=
               G_primary_deprn_limit_amount *
                  (px_asset_fin_rec_new.cost / G_primary_new_cost);
         else
            px_asset_fin_rec_new.allowed_deprn_limit_amount  := 0;
         end if;

      end if;

      -- round the limit
      if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.allowed_deprn_limit_amount,
                                   p_asset_hdr_rec.book_type_code,
                                   p_asset_hdr_rec.set_of_books_id,
                                   p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      px_asset_fin_rec_new.adjusted_recoverable_cost :=
         px_asset_fin_rec_new.cost - px_asset_fin_rec_new.allowed_deprn_limit_amount;

   else -- NONE
      px_asset_fin_rec_new.allowed_deprn_limit_amount := NULL;
      px_asset_fin_rec_new.allowed_deprn_limit        := NULL;

      px_asset_fin_rec_new.adjusted_recoverable_cost :=
         px_asset_fin_rec_new.recoverable_cost;

   end if;

   -- round the  adj_rec_cost
   if not FA_UTILS_PKG.faxfloor(px_asset_fin_rec_new.adjusted_recoverable_cost,
                                p_asset_hdr_rec.book_type_code,
                                p_asset_hdr_rec.set_of_books_id,
                                p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'new allowed_deprn_limit_amount',
                       px_asset_fin_rec_new.allowed_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'px_asset_fin_rec_new.adjusted_recoverable_cost',
                       px_asset_fin_rec_new.adjusted_recoverable_cost, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_deprn_limit_adj_rec_cost;


FUNCTION calc_itc_info
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   l_itc_amount_rate            number;
   l_basis_reduction_rate       number;
   l_itc_basis                  number;
   l_itc_basis_reduction_amount number;
   l_ceiling_limit              number := 0;
   l_calling_fn                 varchar2(40) := 'fa_asset_calc_pvt.calc_itc_info';
   calc_err                     EXCEPTION;

BEGIN

   select itc_amount_rate,
          basis_reduction_rate
     into l_itc_amount_rate,
          l_basis_reduction_rate
     from fa_itc_rates
    where itc_amount_id = px_asset_fin_rec_new.itc_amount_id;

   if (px_asset_fin_rec_new.ceiling_name is not null) then
      select limit
        into l_ceiling_limit
        from fa_ceilings
       where ceiling_name = px_asset_fin_rec_new.ceiling_name
         and px_asset_fin_rec_new.date_placed_in_service between
               start_date and nvl(end_date, px_asset_fin_rec_new.date_placed_in_service);
   end if;

   if (nvl(l_ceiling_limit, 0) = 0) then
      px_asset_fin_rec_new.itc_basis := px_asset_fin_rec_new.cost;
   else
      px_asset_fin_rec_new.itc_basis := least(px_asset_fin_rec_new.cost, l_ceiling_limit);
   end if;


   px_asset_fin_rec_new.itc_amount := px_asset_fin_rec_new.itc_basis * l_itc_amount_rate;

   -- ????

   -- round the amounts
   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.itc_amount,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.itc_basis,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;


   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_itc_info;

FUNCTION calc_salvage_value
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   calc_err         EXCEPTION;
   l_calling_fn     VARCHAR2(40) := 'fa_asset_calc_pvt.calc_salvage_value';

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'old salvage type',
                       p_asset_fin_rec_old.salvage_type, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'adj salvage type',
                       p_asset_fin_rec_adj.salvage_type, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'delta salvage',
                       p_asset_fin_rec_adj.salvage_value, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,
                       'delta percent salvage',
                       p_asset_fin_rec_adj.percent_salvage_value, p_log_level_rec => p_log_level_rec);
   end if;

   -- note that the addition api will already derive the type
   -- so it should never be null here, but placing just in case

   if (p_asset_type_rec.asset_type = 'GROUP') then
      px_asset_fin_rec_new.salvage_type :=
         nvl(p_asset_fin_rec_adj.salvage_type,
            nvl(p_asset_fin_rec_old.salvage_type, 'PCT'));
   else
      px_asset_fin_rec_new.salvage_type :=
         nvl(p_asset_fin_rec_adj.salvage_type,
            nvl(p_asset_fin_rec_old.salvage_type, 'AMT'));
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'salvage type',
                       px_asset_fin_rec_new.salvage_type, p_log_level_rec => p_log_level_rec);
   end if;

   if (px_asset_fin_rec_new.salvage_type = 'SUM' and
       p_asset_type_rec.asset_type <> 'GROUP') then
      fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => '***FA_NO_SUM_NO_GROUP***',
                   p_log_level_rec => p_log_level_rec);
      raise calc_err;
   elsif (px_asset_fin_rec_new.salvage_type = 'AMT' and
       p_asset_type_rec.asset_type = 'GROUP') then
      fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => '***FA_NO_SAL_AMT_FOR_GROUP***',
                   p_log_level_rec => p_log_level_rec);
      raise calc_err;
   elsif (px_asset_fin_rec_new.salvage_type <> 'AMT' and
          px_asset_fin_rec_new.salvage_type <> 'PCT' and
          px_asset_fin_rec_new.salvage_type <> 'SUM') then
      fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => 'FA_INVALID_PARAMETER',
         token1     => 'VALUE',
         value1     => px_asset_fin_rec_new.salvage_type,
         token2     => 'PARAM',
         value2     => 'SALVAGE_TYPE', p_log_level_rec => p_log_level_rec);
      raise calc_err;
   end if;



   -- enhancing for group and core to allow direct percentage
   -- entry for the assets and not just defaults from category
   -- note that we initially set the new value for the salvage %
   -- in calc_new_amounts and use that here.
   --
   -- NOTE: we loaded the "new.type" value previously

   if (px_asset_fin_rec_new.salvage_type = 'PCT') then

      px_asset_fin_rec_new.percent_salvage_value := (nvl(p_asset_fin_rec_adj.percent_salvage_value, 0) +
                                                     nvl(p_asset_fin_rec_old.percent_salvage_value, 0));

      px_asset_fin_rec_new.salvage_value := (px_asset_fin_rec_new.cost *
                                             px_asset_fin_rec_new.percent_salvage_value);

      if not FA_UTILS_PKG.faxceil(px_asset_fin_rec_new.salvage_value,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

   elsif (px_asset_fin_rec_new.salvage_type = 'SUM') then
      -- this is used only for group assets
      -- performance may not be too great here

      -- BUG# 3198440
      -- for additions (old rec is null) just set to 0
      px_asset_fin_rec_new.percent_salvage_value := null;

      if (p_asset_fin_rec_old.salvage_type is null) then
         px_asset_fin_rec_new.salvage_value := 0;
      elsif (p_asset_fin_rec_old.salvage_type <> 'SUM') then
         if (p_mrc_sob_type_code <> 'R') then
            select nvl(sum(salvage_value), 0)
              into px_asset_fin_rec_new.salvage_value
              from fa_books bk,
                   fa_additions_b ad
             where bk.transaction_header_id_out is null
               and bk.group_asset_id = p_asset_hdr_rec.asset_id
               and bk.asset_id = ad.asset_id
               and bk.book_type_code = p_asset_hdr_rec.book_type_code
               and ad.asset_type = 'CAPITALIZED';
         else
            select nvl(sum(salvage_value), 0)
              into px_asset_fin_rec_new.salvage_value
              from fa_mc_books bk,
                   fa_additions_b ad
             where bk.transaction_header_id_out is null
               and bk.group_asset_id = p_asset_hdr_rec.asset_id
               and bk.asset_id = ad.asset_id
               and bk.book_type_code = p_asset_hdr_rec.book_type_code
               and ad.asset_type = 'CAPITALIZED'
               and bk.set_of_books_id = p_asset_hdr_rec.set_of_books_id;
         end if;
      else
         px_asset_fin_rec_new.salvage_value :=
                            nvl(p_asset_fin_rec_adj.salvage_value, 0) +
                            nvl(p_asset_fin_rec_old.salvage_value, 0);
      end if;

   else -- AMT

      px_asset_fin_rec_new.percent_salvage_value := null;

      if (p_mrc_sob_type_code <> 'R') then
         -- delta salvage amount may or may not be null
         -- use it or 0 for the delta

         -- NOTE: when changing types, the delta is treated as the new amount
         -- we will not add to the prior value that may have been
         -- existed/calculated from previous type of PCT or SUM

         if (nvl(p_asset_fin_rec_old.salvage_type, 'AMT') <> 'AMT') then
            px_asset_fin_rec_new.salvage_value := nvl(p_asset_fin_rec_adj.salvage_value, 0);
         else
            px_asset_fin_rec_new.salvage_value := nvl(p_asset_fin_rec_adj.salvage_value, 0) +
                                                  nvl(p_asset_fin_rec_old.salvage_value, 0);
         end if;

         -- BUG# 3873652
         if (px_asset_fin_rec_new.cost = 0) then
            px_asset_fin_rec_new.salvage_value := 0;
         end if;

         G_primary_salvage_value := px_asset_fin_rec_new.salvage_value;

      else
         if (G_primary_new_cost <> 0) then
            px_asset_fin_rec_new.salvage_value := G_primary_salvage_value *
                                                  (px_asset_fin_rec_new.cost / G_primary_new_cost);
         else
            px_asset_fin_rec_new.salvage_value := 0;
         end if;
      end if;
   end if;

   -- round the amount
   if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.salvage_value,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'new salvage',
                       px_asset_fin_rec_new.salvage_value, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_salvage_value;


FUNCTION calc_subcomp_life
  (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
   p_period_rec               IN     FA_API_TYPES.period_rec_type,
   px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
   p_calling_fn               IN     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_asset_type_rec FA_API_TYPES.asset_type_rec_type;
   l_calling_fn     varchar2(40) := 'fa_asset_calc_pvt.calc_subcomp_life';

   CURSOR RATE_DEF IS
   SELECT DISTINCT RATE_SOURCE_RULE
     FROM FA_METHODS
    WHERE METHOD_CODE = px_asset_fin_rec.deprn_method_code;

   l_rate_source_rule   varchar2(10);

   l_cat_bk_lim              number;
   l_min_life_in_months      number;
   l_sub_life_rule           varchar2(13);

   CURSOR LIFE1_DEF IS
   select nvl(life_in_months,0),
          nvl(life_in_months,0),
          prorate_date
     from fa_books
    where book_type_code   = p_asset_hdr_rec.book_type_code
      and asset_id         = p_asset_desc_rec.parent_asset_id
      and transaction_header_id_out is null;

   l_lim                       number;
   l_parent_life               number;
   l_parent_prorate_date       date;

   -- can cache bc, ct, use dep_rec fpr fy
   CURSOR FY_DEF IS
   select round
          (nvl(sum
               (decode (bc.deprn_allocation_code,'E',
                1/ct.number_per_fiscal_year,
                (cp.end_date + 1 - cp.start_date) /
                (fy.end_date + 1 - fy.start_date))),0) * 12, 0)
     from fa_calendar_periods cp,
          fa_calendar_types ct,
          fa_book_controls bc,
          fa_fiscal_year fy
    where bc.book_type_code   = p_asset_hdr_rec.book_type_code
      and bc.date_ineffective is null
      and ct.calendar_type    = bc.prorate_calendar
      and ct.fiscal_year_name = bc.fiscal_year_name
      and cp.calendar_type    = ct.calendar_type
      and ((cp.start_date    >= l_parent_prorate_date and
            cp.end_date      <= px_asset_fin_rec.prorate_date) )
      and fy.fiscal_year_name = bc.fiscal_year_name
      and fy.start_date      <= cp.start_date
      and fy.end_date        >= cp.end_date;

-- excluded due to bug 3872361
/*
or
           (cp.start_date    <= l_parent_prorate_date and
            cp.end_date      >= l_parent_prorate_date and
            cp.start_date    <= px_asset_fin_rec.prorate_date and
            cp.end_date      <= px_asset_fin_rec.prorate_date)
*/

   l_fy                        number;
   l_new_life                  number;

   calc_err                    EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'entering', 'subcomponent life logic', p_log_level_rec => p_log_level_rec);
   end if;

   OPEN RATE_DEF;
   FETCH RATE_DEF INTO
      l_rate_source_rule;

   if (RATE_DEF%NOTFOUND) then
      CLOSE RATE_DEF;
      fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME => 'FA_SHARED_OBJECT_NOT_DEF',
                TOKEN1 => 'OBJECT',
                VALUE1 => 'Method', p_log_level_rec => p_log_level_rec);
      raise calc_err;
   else
      CLOSE RATE_DEF;
   end if;

   if (l_rate_source_rule in ('FLAT', 'PRODUCTION')) then
      fa_srvr_msg.add_message(
          CALLING_FN => l_calling_fn,
          NAME => 'FA_MTH_LFR_INCOMPAT', p_log_level_rec => p_log_level_rec);
      raise calc_err;
   end if;

   if not fa_cache_pkg.fazccbd
            (X_book    => p_asset_hdr_rec.book_type_code,
             X_cat_id  => p_asset_cat_rec.category_id,
             X_jdpis   => to_number(to_char(px_asset_fin_rec.date_placed_in_service, 'J')),
             p_log_level_rec => p_log_level_rec
            ) then
      raise calc_err;
   else
      l_cat_bk_lim              := nvl(fa_cache_pkg.fazccbd_record.life_in_months, 0);
      l_min_life_in_months      := nvl(fa_cache_pkg.fazccbd_record.minimum_life_in_months, 0);
      l_sub_life_rule           := fa_cache_pkg.fazccbd_record.subcomponent_life_rule;
   end if;

   -- get the parents info
   OPEN LIFE1_DEF;
   FETCH LIFE1_DEF INTO
         l_lim,
         l_parent_life,
         l_parent_prorate_date;

   if (LIFE1_DEF%NOTFOUND) then
      CLOSE LIFE1_DEF;
      fa_srvr_msg.add_message(
               CALLING_FN => l_calling_fn,
               NAME => 'FA_PARENT_BKS_NOT_EXIST', p_log_level_rec => p_log_level_rec);
      raise calc_err;
   else
      CLOSE LIFE1_DEF;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'l_cat_bk_lim',          l_cat_bk_lim, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_min_life_in_months',  l_min_life_in_months, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_sub_life_rule',       l_sub_life_rule, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_lim',                 l_lim, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_parent_life',         l_parent_life, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_parent_prorate_date', l_parent_prorate_date, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_rate_source_rule',    l_rate_source_rule, p_log_level_rec => p_log_level_rec);
   end if;

   if (l_sub_life_rule = 'SAME LIFE') then
      if (l_lim  = 0) then
         l_lim := l_cat_bk_lim;
         fa_srvr_msg.add_message(
               CALLING_FN => l_calling_fn,
               NAME       => 'FA_PARENT_LIFE_NOT_SETUP', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;
   elsif (l_sub_life_rule = 'SAME END DATE') then
      if (l_parent_life = 0) then
         l_lim := l_cat_bk_lim;
         fa_srvr_msg.add_message(
               CALLING_FN => l_calling_fn,
               NAME       => 'FA_PARENT_LIFE_NOT_SETUP', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      else

         -- need to derive the prorate convention and date if
         -- needed here as this is being called before
         -- the calc engine for an addition and cursor will
         -- return 0

         if (px_asset_fin_rec.prorate_convention_code is null) then
            px_asset_fin_rec.prorate_convention_code   :=
               fa_cache_pkg.fazccbd_record.prorate_convention_code;
         end if;

         -- just needs to be <> GROUP
         l_asset_type_rec.asset_type := 'CAPITALIZED';

         if not calc_prorate_date
              (p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_type_rec          => l_asset_type_rec,
               p_asset_fin_rec_adj       => px_asset_fin_rec,
               px_asset_fin_rec_new      => px_asset_fin_rec,
               p_period_rec              => p_period_rec,
               p_log_level_rec           => p_log_level_rec
              ) then
            raise calc_err;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec.prorate_date ', px_asset_fin_rec.prorate_date , p_log_level_rec => p_log_level_rec);
         end if;


         l_fy := 0;
         OPEN FY_DEF;
         FETCH FY_DEF INTO l_fy;
         if (FY_DEF%NOTFOUND) then
            CLOSE FY_DEF;
            fa_srvr_msg.add_message(
               CALLING_FN => l_calling_fn,
               NAME => 'FA_SHARED_OBJECT_NOT_DEF',
               TOKEN1 => 'OBJECT',
               VALUE1 => 'Fiscal Year or Calendar Period', p_log_level_rec => p_log_level_rec);
            raise calc_err;
         end if;
         CLOSE FY_DEF;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_fy', l_fy, p_log_level_rec => p_log_level_rec);
         end if;

         -- If the parent asset is fully reserved i.e it's remaining life as
         -- computed here is <= 0 then the life of the subcomponent asset
         -- is one month.

         if (l_fy >= l_parent_life) then
            -- If the parent asset is fully rsvd
            l_lim := 1;
         else
            -- The life is the lesser of the Category's life and parent's remaining life
            -- BUG# 1898874 - correcting the check to use l_cat_bk_lim instead of l_lim
            -- so that this is actually what happens.  Previously, the same end date
            -- was always implemented no matter how much the child's life was inflated.
            --     bridgway   07/24/01

            if ((l_parent_life - l_fy) < l_cat_bk_lim) then
               l_lim := l_parent_life - l_fy;
            else
               l_lim := l_cat_bk_lim;
            end if;

            if (l_lim < l_min_life_in_months) then
               if (l_cat_bk_lim < l_min_life_in_months) then
                  l_lim := l_min_life_in_months;
               else
                  l_lim := l_cat_bk_lim;
               end if;
            end if;

         end if;  -- If the parent asset is fully reserved

      end if;  -- If parent's life is not setup

   else

      l_lim := l_cat_bk_lim;

   end if;

   --  l_new_life := 0;  -- Change to l_lim to fix bug 737503
   l_new_life := l_lim;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'calling',        'validate_life', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_deprn_method', px_asset_fin_rec.deprn_method_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_cat_bk_lim',   l_cat_bk_lim, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_lim',          l_lim, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_new_life',     l_new_life, p_log_level_rec => p_log_level_rec);
   end if;

   if not fa_asset_val_pvt.validate_life
            (p_deprn_method      => px_asset_fin_rec.deprn_method_code,
             p_rate_source_rule  => l_rate_source_rule,
             p_life_in_months    => l_cat_bk_lim,
             p_lim               => l_lim,
             p_user_id           => p_trans_rec.who_info.last_updated_by,
             p_curr_date         => p_trans_rec.who_info.last_update_date,
             px_new_life         => l_new_life,
             p_calling_fn        => l_calling_fn
            , p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   else

      if (l_new_life <> 0) then
         px_asset_fin_rec.life_in_months := l_new_life;
      end if;

   end if;

   return TRUE;


EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_subcomp_life;



FUNCTION calc_flags
  (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
   p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
   px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
   p_asset_deprn_rec         IN     FA_API_TYPES.asset_deprn_rec_type,
   p_period_rec              IN     FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_first_period number := 0;

   l_current_fiscal_year number;
   l_fiscal_year_name    varchar2(30);

   l_rate_source_rule      varchar2(10);
   l_deprn_basis_rule      varchar2(4);

   l_depreciate_flag       varchar2(3);
   l_dep_flag_thid         number;
   l_count_dep_flag        number;

   l_sty_success           varchar2(3) := 'NO';
   l_calling_fn            varchar2(40) := 'fa_asset_calc_pvt.calc_flags';

   calc_err                EXCEPTION;

BEGIN

   -- this logic needs verification - ref faxfa2b.pls

   l_current_fiscal_year := fa_cache_pkg.fazcbc_record.current_fiscal_year;
   l_fiscal_year_name    := fa_cache_pkg.fazcbc_record.fiscal_year_name;

   if not fa_cache_pkg.fazccmt
          ( X_method                => px_asset_fin_rec_new.Deprn_Method_Code
           ,X_life                  => px_asset_fin_rec_new.Life_In_Months, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

      l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
      l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;


   px_asset_fin_rec_new.cost_change_flag        := 'NO';
   px_asset_fin_rec_new.retirement_pending_flag := 'NO';


   if (p_asset_type_rec.asset_type = 'CAPITALIZED' or
       p_asset_type_rec.asset_type = 'CIP' or
       p_asset_type_rec.asset_type = 'GROUP') then

      px_asset_fin_rec_new.capitalize_flag := 'YES';
      --  changed the following logic to mirror the forms
      --  though there discrepancies between faxfa1b.pls

      -- SLA Uptake
      -- since we're taking the catchup here,
      -- reset flags as if no catchup is needed

      if ((p_asset_hdr_rec.period_of_addition = 'Y') or
          (p_asset_hdr_rec.period_of_addition = 'N' and
           p_trans_rec.transaction_type_code = 'ADDITION')) then

         if (p_asset_deprn_rec.deprn_reserve <> 0) then     -- reserve
               /* Bug 8408871 - when reserve supplied no catchup required for any asset type */
               px_asset_fin_rec_new.adjustment_required_status := 'NONE';
               px_asset_fin_rec_new.annual_deprn_rounding_flag := 'RES';
         else

            if (px_asset_fin_rec_new.date_placed_in_service >= p_period_rec.calendar_period_open_date and
                px_asset_fin_rec_new.date_placed_in_service <=  p_period_rec.calendar_period_close_date) then
               px_asset_fin_rec_new.adjustment_required_status := 'ADD';
               px_asset_fin_rec_new.annual_deprn_rounding_flag := NULL;
            else -- not a current period addition

               if (px_asset_fin_rec_new.date_placed_in_service >= p_period_rec.fy_start_date and
                   px_asset_fin_rec_new.date_placed_in_service <= p_period_rec.fy_end_date ) then
                  px_asset_fin_rec_new.adjustment_required_status := 'ADD';
                  px_asset_fin_rec_new.annual_deprn_rounding_flag := NULL;
               else -- backdated addition to prior year
                  px_asset_fin_rec_new.annual_deprn_rounding_flag := 'ADD';
                  px_asset_fin_rec_new.adjustment_required_status := 'ADD';
               end if;
            end if;

            -- BUG# 2522675
            -- when asset is set to amortize nbv, the adj_req flag must be
            -- set to none to avoid any additional catchup
            if ((p_trans_rec.transaction_subtype = 'AMORTIZED' and
                 p_asset_type_rec.asset_type = 'CAPITALIZED') or
                (p_asset_type_rec.asset_type = 'GROUP')) then
               px_asset_fin_rec_new.adjustment_required_status := 'NONE';
            end if;

            -- Bug4401476: Set rounding falg to RES if it is amortize nbv
            -- to avoid huge catchup even though entered reserve is 0..
            if (p_trans_rec.transaction_subtype = 'AMORTIZED' and
                 p_asset_type_rec.asset_type = 'CAPITALIZED') then
               px_asset_fin_rec_new.annual_deprn_rounding_flag := 'RES';
            end if;

         end if;

      else  -- adjustment

         -- BUG# 3516246
         -- when adjustment is performed in period of capitalization
         -- we need to set to NONE and avoid catchup.

         if (p_asset_fin_rec_old.adjustment_required_status = 'ADD') then
            px_asset_fin_rec_new.adjustment_required_status := 'NONE';
         else
            px_asset_fin_rec_new.adjustment_required_status :=
               p_asset_fin_rec_old.adjustment_required_status;
         end if;

         -- Bug#3709494
         -- if the asset was added with the depreciate_flag set to NO
         -- and this is the FIRST time that we are changing it to YES,
         -- then perform catchup by setting adjustment_required_status to
         -- ADD.

         -- R12 conditional logic
         if (G_release <> 11) then
            if (p_asset_fin_rec_old.adjustment_required_status = 'ADD') then

            -- Bug#3709494
            -- if the asset was added with the depreciate_flag set to NO
            -- and this is the FIRST time that we are changing it to YES,
            -- then perform catchup by setting adjustment_required_status to
            -- ADD.

            -- SLA: revisit this as catchup must occur at time of trx now!!!!
            -- ****

               if (nvl(p_asset_fin_rec_old.depreciate_flag, 'YES') = 'NO') then
                  --SLA: no need for flag, take catchup now
                  -- catchup
                  px_asset_fin_rec_new.adjustment_required_status :=
                     p_asset_fin_rec_old.adjustment_required_status;

               else
                  -- No catchup
                  px_asset_fin_rec_new.adjustment_required_status := 'NONE';
               end if;
            else
               px_asset_fin_rec_new.adjustment_required_status :=
                  p_asset_fin_rec_old.adjustment_required_status;
            end if;

         elsif ((nvl(p_asset_fin_rec_old.depreciate_flag, 'YES') = 'NO') and
             (nvl(px_asset_fin_rec_new.depreciate_flag, 'YES') = 'YES')) then

            -- We confirmed that we have changed the depreciate_flag from
            -- NO to YES.  Now we need to check if this is the asset were
            -- originally NO, and this is the first time it was changed to YES.

            begin

               select bk.depreciate_flag,
                      bk.transaction_header_id_in
               into   l_depreciate_flag,
                      l_dep_flag_thid
               from   fa_books bk,
                      fa_transaction_headers th
               where  th.asset_id = p_asset_hdr_rec.asset_id
               and    th.book_type_code = p_asset_hdr_rec.book_type_code
               and    th.transaction_type_code = 'ADDITION'
               and    th.transaction_header_id = bk.transaction_header_id_in;
            exception
               when others then
                  l_depreciate_flag := 'YES';
            end;

            if (l_depreciate_flag = 'NO') then

               -- The flag was originally NO.   Now is this the first change?
               begin

                  select count(*)
                  into   l_count_dep_flag
                  from   fa_books
                  where  asset_id = p_asset_hdr_rec.asset_id
                  and    book_type_code = p_asset_hdr_rec.book_type_code
                  and    depreciate_flag = 'YES'
                  and    transaction_header_id_in >= l_dep_flag_thid
                  and    transaction_header_id_in <> p_trans_rec.transaction_header_id; /*Bug# 8631034 - For MRC */

               exception
                  when others then
                     l_count_dep_flag := 1;
               end;

               if (l_count_dep_flag = 0) then
                  -- catchup
                  -- Bug:5385123
                  if p_trans_rec.transaction_subtype <> 'AMORTIZED' then
                      px_asset_fin_rec_new.adjustment_required_status := 'ADD';
                  end if;
               end if;
            end if;
         end if;

         -- BUG# 2678718
         -- removing prior logic for checking first period
         -- of fiscal year and always setting flag to ADJ

         /*
         select count(1)
           into l_first_period
           from fa_fiscal_year fy,
                fa_deprn_periods dp
          where l_fiscal_year_name           = fy.fiscal_year_name
            and l_current_fiscal_year        = fy.fiscal_year
            and dp.book_type_code            = p_asset_hdr_rec.book_type_code
            and dp.calendar_period_open_date = fy.start_date
            and p_trans_rec.transaction_date_entered   between
                     dp.calendar_period_open_date and
                     dp.calendar_period_close_date
            and rownum < 2;

         if (l_first_period = 0) then
             px_asset_fin_rec_new.annual_deprn_rounding_flag := 'ADJ';
         else

            if l_rate_source_rule = 'FLAT' then
               px_asset_fin_rec_new.annual_deprn_rounding_flag := 'ADJ';
            else
               px_asset_fin_rec_new.annual_deprn_rounding_flag := NULL;
            end if;

         end if;

         */

         px_asset_fin_rec_new.annual_deprn_rounding_flag := 'ADJ';

      end if;

   else -- expensed asset

      px_asset_fin_rec_new.adjustment_required_status := 'NONE';
      px_asset_fin_rec_new.annual_deprn_rounding_flag := NULL;
      px_asset_fin_rec_new.capitalize_flag            := 'NO';

   end if;

/*
   -- calculate the short tax and formula info
   if (l_Rate_Source_Rule = 'FORMULA') then

      -- Get current fiscal year start and end dates.

      fa_short_tax_years_pkg.calculate_short_tax_vals(
                X_Asset_Id                      => p_asset_hdr_rec.Asset_Id,
                X_Book_Type_Code                => p_asset_hdr_rec.Book_type_Code,
                -- new columns
                X_Short_Fiscal_Year_Flag        => px_asset_fin_rec_new.Short_Fiscal_Year_Flag,
                X_Date_Placed_In_Service        => px_asset_fin_rec_new.Date_Placed_In_Service,
                X_Deprn_Start_Date              => px_asset_fin_rec_new.Deprn_Start_Date,
                X_Prorate_Date                  => px_asset_fin_rec_new.Prorate_Date,
                X_Conversion_Date               => px_asset_fin_rec_new.Conversion_Date,
                X_Orig_Deprn_Start_Date         => px_asset_fin_rec_new.Orig_Deprn_Start_Date,
                X_Curr_Fy_Start_Date            => p_period_rec.fy_start_date,
                X_Curr_Fy_End_Date              => p_period_rec.fy_end_date,
                X_Life_In_Months                => px_asset_fin_rec_new.Life_In_Months,
                X_Rate_Source_Rule              => l_Rate_Source_Rule,  -- BUG# 2016824
                X_Remaining_Life1               => px_asset_fin_rec_new.remaining_life1,
                X_Remaining_Life2               => px_asset_fin_rec_new.remaining_life2,
                X_Success                       => l_sty_success, p_log_level_rec => p_log_level_rec);

        if (l_sty_success = 'NO') then
           raise calc_err;
        end if;

   end if;
*/

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_flags;


FUNCTION calc_deprn_info
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_new     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_count                       number;
   l_result                      boolean;
   l_unit_of_measure             FA_BOOKS.UNIT_OF_MEASURE%TYPE;

   l_method_id                   number;
   l_rate_source_rule            FA_METHODS.rate_source_rule%TYPE;
   l_deprn_basis_rule            FA_METHODS.deprn_basis_rule%TYPE;

   l_last_period_counter         number;
   l_calendar_period_open_date   date;
   l_calendar_period_close_date  date;
   h_prod_method                 number;  -- added this for bug 3245984

   CURSOR unit_of_measure IS
          select unit_of_measure
            from fa_books
           where asset_id           = p_asset_hdr_rec.asset_id
             and book_type_code     = fa_cache_pkg.fazcbc_record.distribution_source_book
             and transaction_header_id_out  is NULL
             and deprn_method_code  = px_asset_fin_rec_new.deprn_method_code;

   l_calling_fn                  VARCHAR2(40) := 'fa_asset_calc_pvt.calc_deprn_info';
   calc_err                      EXCEPTION;

BEGIN

   l_last_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter;

   -- NOTE: moved additions defaulting to the private additions apit's init procedure
   -- as part of group project...

   -- Set deprn info - "all or nothing"  - this means that if you are changing the
   -- method you must provide the other info (life or rates for instance).
   -- the semi exception is production capacity which is done above based on delta
   if (p_asset_fin_rec_adj.deprn_method_code is not null) then
      px_asset_fin_rec_new.deprn_method_code   := p_asset_fin_rec_adj.deprn_method_code;
      px_asset_fin_rec_new.life_in_months      := p_asset_fin_rec_adj.life_in_months;
      px_asset_fin_rec_new.basic_rate          := p_asset_fin_rec_adj.basic_rate;
      px_asset_fin_rec_new.adjusted_rate       := p_asset_fin_rec_adj.adjusted_rate;
      px_asset_fin_rec_new.unit_of_measure     := p_asset_fin_rec_adj.unit_of_measure;
   else

      if (p_asset_fin_rec_adj.life_in_months      is not null OR
          p_asset_fin_rec_adj.basic_rate          is not null OR
          p_asset_fin_rec_adj.adjusted_rate       is not null) then
          -- nvl(p_asset_fin_rec_adj.production_capacity, 0) <> 0) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_EXP_GET_METHOD_INFO', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;

      if (p_asset_fin_rec_old.deprn_method_code is not null) then
         px_asset_fin_rec_new.deprn_method_code   := p_asset_fin_rec_old.deprn_method_code;
         px_asset_fin_rec_new.life_in_months      := p_asset_fin_rec_old.life_in_months;
         px_asset_fin_rec_new.basic_rate          := p_asset_fin_rec_old.basic_rate;
         px_asset_fin_rec_new.adjusted_rate       := p_asset_fin_rec_old.adjusted_rate;
         px_asset_fin_rec_new.unit_of_measure     := p_asset_fin_rec_old.unit_of_measure;
      end if;

   end if;


   -- do not allow method change is unplanned has been entered
   -- needed to check the methods per BUG# 2435403
--fix for bug no.2536674
  /* if (p_trans_rec.transaction_type_code <> 'ADDITION' and
       p_trans_rec.transaction_type_code <> 'CIP ADDITION' and
       p_trans_rec.transaction_type_code <> 'GROUP ADDITION' and
       (p_asset_fin_rec_old.deprn_method_code <>
        p_asset_fin_rec_adj.deprn_method_code)) then
      if fa_asset_val_pvt.validate_unplanned_exists
               (p_book     => p_asset_hdr_rec.book_type_code,
                p_asset_id => p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(
             calling_fn => 'l_calling_fn',
             name       => '***FA_NO_METHOD_CHG_UNP***');
         raise calc_err;
      end if;
   end if;
 */

   -- verify deprn information is valid by calling the method
   -- cache function - modified from STYR to handle all types.
   -- FYI: we MUST call the cache even when there is no method change
   -- because of potential impact of the flags on the depreciable
   -- basis, deprn_start_date and on adjusted_cost for nbv methods
   if not FA_CACHE_PKG.fazccmt(
                  X_method                 => px_asset_fin_rec_new.deprn_method_code,
                  X_life                   => px_asset_fin_rec_new.life_in_months
                 , p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;


   l_method_id        := fa_cache_pkg.fazccmt_record.method_id;
   l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
   l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

   -- verify that basic rate and adj_rate are valid for flat
   -- rate methods and that production info is correct

   if (px_asset_fin_rec_new.deprn_method_code is not null) then
      if (l_rate_source_rule = 'FLAT') then

         select count(*)
           into l_count
           from fa_flat_rates
          where method_id     = l_method_id
            and basic_rate    = px_asset_fin_rec_new.basic_rate
            and adjusted_rate = px_asset_fin_rec_new.adjusted_rate;

         if (l_count = 0) then
            fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_SHARED_INVALID_METHOD_RATE', p_log_level_rec => p_log_level_rec);
            raise calc_err;
         else
            px_asset_fin_rec_new.life_in_months      := NULL;
            px_asset_fin_rec_new.production_capacity := NULL;
            px_asset_fin_rec_new.unit_of_measure     := NULL;
         end if;

      elsif (l_rate_source_rule  = 'PRODUCTION') then

         if (px_asset_fin_rec_new.production_capacity is null) then
            fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_BOOKS_NULL_PROD', p_log_level_rec => p_log_level_rec);
            raise calc_err;
         else
            px_asset_fin_rec_new.life_in_months    := NULL;
            px_asset_fin_rec_new.adjusted_rate     := NULL;
            px_asset_fin_rec_new.basic_rate        := NULL;
         end if;

         -- verify corp asset is UOP and get unit of measure
         -- Depreciate flag may not be 'NO'
         if ((nvl(fa_cache_pkg.fazcdbr_record.rule_name,'ZZ')  <> 'ENERGY PERIOD END BALANCE'
              OR p_asset_type_rec.asset_type = 'GROUP') and
             px_asset_fin_rec_new.depreciate_flag <> 'YES') then    -- Added for bug8584206
            fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                    name            => 'FA_BOOK_INVALID_DEPRN_FLAG',
                                    p_log_level_rec => p_log_level_rec);
            raise calc_err;
         end if;

         if (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then
            OPEN unit_of_measure;
            FETCH unit_of_measure INTO px_asset_fin_rec_new.unit_of_measure;

            if (unit_of_measure%NOTFOUND) then
               CLOSE unit_of_measure;
               fa_srvr_msg.add_message(
                   calling_fn => l_calling_fn,
                   name       => 'FA_MASSCHG_NOT_PROD_IN_CORP', p_log_level_rec => p_log_level_rec);
               raise calc_err;
            end if;
            CLOSE unit_of_measure;

         end if;

      elsif (l_rate_source_rule  = 'TABLE') then
         px_asset_fin_rec_new.adjusted_rate        := NULL;
         px_asset_fin_rec_new.basic_rate           := NULL;
         px_asset_fin_rec_new.production_capacity  := NULL;
         px_asset_fin_rec_new.unit_of_measure      := NULL;
      elsif (l_rate_source_rule  = 'FORMULA') then
         px_asset_fin_rec_new.adjusted_rate        := NULL;
         px_asset_fin_rec_new.basic_rate           := NULL;

         -- added this for bug 3245984
         h_prod_method := instr (fa_cache_pkg.fazcfor_record.formula_actual,'CAPACITY');
         -- if the formula has 'CAPACITY' in it, then it is a Production method
         -- otherwise, it is a Life method.
         if (h_prod_method = 0) then
             px_asset_fin_rec_new.production_capacity  := NULL;
             px_asset_fin_rec_new.unit_of_measure      := NULL;
         end if;

      else
         px_asset_fin_rec_new.production_capacity  := NULL;
         px_asset_fin_rec_new.unit_of_measure      := NULL;
      end if;

   end if; -- new method code is not null

   px_asset_fin_rec_new.adjusted_capacity       := px_asset_fin_rec_new.production_capacity;


-- BUG# 4676908
   -- make sure the proate period match the method
   if (fa_cache_pkg.fazccmt_record.prorate_periods_per_year is not null) then
      if not fa_cache_pkg.fazcct
               (X_calendar => fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

      if (fa_cache_pkg.fazccmt_record.prorate_periods_per_year <>
          fa_cache_pkg.fazcct_record.number_per_fiscal_year) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_INVALID_DEPRN_METHOD', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;
   end if;

   -- verify reserve and ytd = 0 for UOP

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('calc_fin_info', 'p_asset_deprn_rec_adj.deprn_reserve',
                       p_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec);
      fa_debug_pkg.add('calc_fin_info', 'p_asset_deprn_rec_adj.ytd_deprn',
                       p_asset_deprn_rec_adj.ytd_deprn, p_log_level_rec);
      fa_debug_pkg.add('calc_fin_info', 'p_asset_deprn_rec_adj.ltd_prod',
                       p_asset_deprn_rec_adj.ltd_production, p_log_level_rec);
      fa_debug_pkg.add('calc_fin_info', 'p_asset_deprn_rec_adj.ytd_prod',
                       p_asset_deprn_rec_adj.ytd_production, p_log_level_rec);
      fa_debug_pkg.add('calc_fin_info', 'px_asset_fin_rec_new.short_fiscal_year_flag',
                       px_asset_fin_rec_new.short_fiscal_year_flag, p_log_level_rec);
   end if;

   -- modified for bug 8584206
   if (l_rate_source_rule  = 'PRODUCTION') and
      ( ((nvl(p_trans_rec.transaction_key, 'XX') not in ('MR', 'MS','GC')) and  p_asset_type_rec.asset_type = 'GROUP')
        OR
         (p_asset_type_rec.asset_type = 'CAPITALIZED' and
         (px_asset_fin_rec_new.depreciate_flag = 'YES' OR
          nvl(px_asset_fin_rec_new.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM OR
          fa_cache_pkg.fazcdbr_record.rule_name  <> 'ENERGY PERIOD END BALANCE')) )  then

      if (nvl(p_asset_deprn_rec_adj.deprn_reserve,0) <> 0 OR
          nvl(p_asset_deprn_rec_adj.ytd_deprn,0) <> 0) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_NO_RESERVE_FOR_PROD', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;
   end if;

   -- verify STY information is valid
   if not fa_asset_val_pvt.validate_short_tax_year
            (p_book_type_code            => p_asset_hdr_rec.book_type_code,
             p_transaction_type_code     => p_trans_rec.transaction_type_code,
             p_asset_type                => p_asset_type_rec.asset_type,
             p_short_fiscal_year_flag    => px_asset_fin_rec_new.short_fiscal_year_flag,
             p_conversion_date           => px_asset_fin_rec_new.conversion_date,
             px_orig_deprn_start_date    => px_asset_fin_rec_new.orig_deprn_start_date,
             p_date_placed_in_service    => px_asset_fin_rec_new.date_placed_in_service,
             p_ytd_deprn                 => p_asset_deprn_rec_new.ytd_deprn,
             p_deprn_reserve             => p_asset_deprn_rec_new.deprn_reserve,
             p_period_rec                => p_period_rec,
             p_calling_fn                => l_calling_fn
            , p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   -- Check Bonus Rule

   if (px_asset_fin_rec_new.bonus_rule IS NOT NULL) then
      select count(*)
        into l_count
        from fa_bonus_rules
       where bonus_rule = px_asset_fin_rec_new.bonus_rule;

      if (l_count = 0) then
         fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_INVALID_BONUS_RULE', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if;
   end if;


   -- check super group
   if (l_rate_source_rule <> 'FLAT' and
       px_asset_fin_rec_new.super_group_id is not null) then
      fa_srvr_msg.add_message(
          calling_fn => l_calling_fn,
          name       => '***FA_NO_SUPER_NO_FLAT***',
                   p_log_level_rec => p_log_level_rec);
      raise calc_err;
   end if;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_deprn_info;


FUNCTION calc_group_info
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

  CURSOR c_find_member_asset IS
   SELECT 'Y'
     FROM FA_BOOKS
    WHERE GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND TRANSACTION_HEADER_ID_OUT is NULL;

   l_calling_fn                  VARCHAR2(40) := 'fa_asset_calc_pvt.calc_group_info';

   l_member_exists               VARCHAR2(1) := null;

   calc_err                      EXCEPTION;

BEGIN

   -- this will validate/set all the new group asset flags
   -- note that  the addition api has already defaulted the
   -- values if they weren't specified.  here we need to
   -- check for changes and validate the values

   -- +++++ Reduction Rate +++++

   px_asset_fin_rec_new.reduction_rate :=
         nvl(p_asset_fin_rec_adj.reduction_rate, 0) +
         nvl(p_asset_fin_rec_old.reduction_rate, 0);

   --
   -- Function call fazccmt is mandatory before calling this function.
   -- Currently fazccmt is called in calc_deprn_info and calc_flag which
   -- is called from calc_derived_amounts.
   -- If calc_deprn_info is called before this function, then I can simply use
   -- new so don't need this much of the code.
   if (p_asset_fin_rec_adj.deprn_method_code is not null) then
      if not fa_cache_pkg.fazccmt
                 (X_method => p_asset_fin_rec_adj.Deprn_Method_Code,
                  X_life   => p_asset_fin_rec_adj.Life_In_Months
                 , p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;
   else
      if not fa_cache_pkg.fazccmt
                 (X_method => p_asset_fin_rec_old.Deprn_Method_Code,
                  X_life   => p_asset_fin_rec_old.Life_In_Months
                 , p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;
   end if;

   if (nvl(fa_cache_pkg.fazcdrd_record.allow_reduction_rate_flag, 'N') = 'N') then
      px_asset_fin_rec_new.reduction_rate := to_number(null);
   end if;


   FA_UTIL_PVT.load_char_value
        (p_char_old  => p_asset_fin_rec_old.over_depreciate_option,
         p_char_adj  => p_asset_fin_rec_adj.over_depreciate_option,
         x_char_new  => px_asset_fin_rec_new.over_depreciate_option
        , p_log_level_rec => p_log_level_rec);

   --
   -- Set Over Depreciate to 'NO'
   --  1. If it is set to DEPRN and FLAT-NBV method
   --  2. If it is not NO and there is some deprn limit
   --
   if (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then

      if (px_asset_fin_rec_new.over_depreciate_option =
          fa_std_types.FA_OVER_DEPR_DEPRN) and
         (fa_cache_pkg.fazccmt_record.rate_source_rule = 'FLAT' and
          fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'NBV') then
         px_asset_fin_rec_new.over_depreciate_option :=
            fa_std_types.FA_OVER_DEPR_NO;
      end if;

   end if;

   -- +++++ Over Depreciate +++++
   -- Validation moved to fa_asset_val_pvt.validate_over_depreciate

   -- +++++ Reduction Flags +++++
   if (px_asset_fin_rec_new.reduction_rate is null) then
      px_asset_fin_rec_new.reduce_addition_flag := null;
      px_asset_fin_rec_new.reduce_adjustment_flag := null;
      px_asset_fin_rec_new.reduce_retirement_flag := null;
   else
     FA_UTIL_PVT.load_char_value
          (p_char_old  => p_asset_fin_rec_old.reduce_addition_flag,
           p_char_adj  => p_asset_fin_rec_adj.reduce_addition_flag,
           x_char_new  => px_asset_fin_rec_new.reduce_addition_flag
          , p_log_level_rec => p_log_level_rec);
     FA_UTIL_PVT.load_char_value
          (p_char_old  => p_asset_fin_rec_old.reduce_adjustment_flag,
           p_char_adj  => p_asset_fin_rec_adj.reduce_adjustment_flag,
           x_char_new  => px_asset_fin_rec_new.reduce_adjustment_flag
          , p_log_level_rec => p_log_level_rec);
     FA_UTIL_PVT.load_char_value
          (p_char_old  => p_asset_fin_rec_old.reduce_retirement_flag,
           p_char_adj  => p_asset_fin_rec_adj.reduce_retirement_flag,
           x_char_new  => px_asset_fin_rec_new.reduce_retirement_flag
          , p_log_level_rec => p_log_level_rec);
   end if;

   -- +++++ Retirement and Tracking Options +++++
   -- From here, these values are not updateable
   -- once depreciation is run or first member asset
   -- is added.

   if (p_asset_hdr_rec.period_of_addition = 'Y') then
      OPEN c_find_member_asset;
      FETCH c_find_member_asset INTO l_member_exists;

      if (c_find_member_asset%NOTFOUND) then
        l_member_exists := 'N';
      end if;

      CLOSE c_find_member_asset;

   end if;

   if (p_asset_hdr_rec.period_of_addition <> 'Y') or
      (l_member_exists = 'Y') then

      px_asset_fin_rec_new.recognize_gain_loss :=
                  p_asset_fin_rec_old.recognize_gain_loss;

      px_asset_fin_rec_new.recapture_reserve_flag :=
                  p_asset_fin_rec_old.recapture_reserve_flag;

      px_asset_fin_rec_new.limit_proceeds_flag :=
                  p_asset_fin_rec_old.limit_proceeds_flag;

      px_asset_fin_rec_new.terminal_gain_loss :=
                  p_asset_fin_rec_old.terminal_gain_loss;

      px_asset_fin_rec_new.exclude_proceeds_from_basis :=
                  p_asset_fin_rec_old.exclude_proceeds_from_basis;

      px_asset_fin_rec_new.retirement_deprn_option :=
                  p_asset_fin_rec_old.retirement_deprn_option;

      px_asset_fin_rec_new.tracking_method :=
                  p_asset_fin_rec_old.tracking_method;

      px_asset_fin_rec_new.allocate_to_fully_rsv_flag :=
                  p_asset_fin_rec_old.allocate_to_fully_rsv_flag;

      px_asset_fin_rec_new.allocate_to_fully_ret_flag :=
                  p_asset_fin_rec_old.allocate_to_fully_ret_flag;

      px_asset_fin_rec_new.excess_allocation_option :=
                  p_asset_fin_rec_old.excess_allocation_option;

      px_asset_fin_rec_new.depreciation_option :=
                  p_asset_fin_rec_old.depreciation_option;

      px_asset_fin_rec_new.member_rollup_flag :=
                  p_asset_fin_rec_old.member_rollup_flag;

   else -- No member asset in this group and still in period of addition

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.recognize_gain_loss,
            p_char_adj  => p_asset_fin_rec_adj.recognize_gain_loss,
            x_char_new  => px_asset_fin_rec_new.recognize_gain_loss
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.recapture_reserve_flag,
            p_char_adj  => p_asset_fin_rec_adj.recapture_reserve_flag,
            x_char_new  => px_asset_fin_rec_new.recapture_reserve_flag
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.limit_proceeds_flag,
            p_char_adj  => p_asset_fin_rec_adj.limit_proceeds_flag,
            x_char_new  => px_asset_fin_rec_new.limit_proceeds_flag
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.terminal_gain_loss,
            p_char_adj  => p_asset_fin_rec_adj.terminal_gain_loss,
            x_char_new  => px_asset_fin_rec_new.terminal_gain_loss
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.exclude_proceeds_from_basis,
            p_char_adj  => p_asset_fin_rec_adj.exclude_proceeds_from_basis,
            x_char_new  => px_asset_fin_rec_new.exclude_proceeds_from_basis
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.retirement_deprn_option,
            p_char_adj  => p_asset_fin_rec_adj.retirement_deprn_option,
            x_char_new  => px_asset_fin_rec_new.retirement_deprn_option
           , p_log_level_rec => p_log_level_rec);

      --
      -- Retirement Option Validations
      --
      if (nvl(px_asset_fin_rec_new.recognize_gain_loss, 'XXX')
                                      not in ('NO', 'YES')) then
         px_asset_fin_rec_new.recognize_gain_loss := 'NO';
      end if;

      if (px_asset_fin_rec_new.over_depreciate_option <>
             fa_std_types.FA_OVER_DEPR_NO) and
         (nvl(px_asset_fin_rec_new.recapture_reserve_flag, 'N') <> 'N') then
         px_asset_fin_rec_new.recapture_reserve_flag := 'N';
      elsif (nvl(px_asset_fin_rec_new.recapture_reserve_flag, 'N') not in ('N', 'Y')) then
         px_asset_fin_rec_new.recapture_reserve_flag := 'N';
      end if;

      if (px_asset_fin_rec_new.recognize_gain_loss = 'YES') and
         (nvl(px_asset_fin_rec_new.limit_proceeds_flag, 'N') <> 'Y') then
         px_asset_fin_rec_new.limit_proceeds_flag := 'N';
      elsif (nvl(px_asset_fin_rec_new.limit_proceeds_flag, 'N') not in ('N', 'Y')) then
         px_asset_fin_rec_new.limit_proceeds_flag := 'N';
      end if;

      if (nvl(px_asset_fin_rec_new.terminal_gain_loss, 'XXX')
                                 not in ('NO', 'YES', 'END_OF_YEAR')) then
         px_asset_fin_rec_new.terminal_gain_loss := 'YES';
      end if;

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.tracking_method,
            p_char_adj  => p_asset_fin_rec_adj.tracking_method,
            x_char_new  => px_asset_fin_rec_new.tracking_method
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.allocate_to_fully_rsv_flag,
            p_char_adj  => p_asset_fin_rec_adj.allocate_to_fully_rsv_flag,
            x_char_new  => px_asset_fin_rec_new.allocate_to_fully_rsv_flag
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.allocate_to_fully_ret_flag,
            p_char_adj  => p_asset_fin_rec_adj.allocate_to_fully_ret_flag,
            x_char_new  => px_asset_fin_rec_new.allocate_to_fully_ret_flag
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.excess_allocation_option,
            p_char_adj  => p_asset_fin_rec_adj.excess_allocation_option,
            x_char_new  => px_asset_fin_rec_new.excess_allocation_option
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.depreciation_option,
            p_char_adj  => p_asset_fin_rec_adj.depreciation_option,
            x_char_new  => px_asset_fin_rec_new.depreciation_option
           , p_log_level_rec => p_log_level_rec);

      FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.member_rollup_flag,
            p_char_adj  => p_asset_fin_rec_adj.member_rollup_flag,
            x_char_new  => px_asset_fin_rec_new.member_rollup_flag
           , p_log_level_rec => p_log_level_rec);

      --
      -- Tracking Option Validations
       --HH check allow_member_tracking_flag too.
      --
      if (px_asset_fin_rec_new.tracking_method is null) OR
         (nvl(fa_cache_pkg.fazcbc_record.allow_member_tracking_flag,'N') <> 'Y')then

         px_asset_fin_rec_new.allocate_to_fully_rsv_flag := null;
         px_asset_fin_rec_new.allocate_to_fully_ret_flag := null;
         px_asset_fin_rec_new.excess_allocation_option   := null;
         px_asset_fin_rec_new.depreciation_option        := null;
         px_asset_fin_rec_new.member_rollup_flag         := null;

      elsif (px_asset_fin_rec_new.tracking_method = 'ALLOCATE') then

         if (px_asset_fin_rec_new.allocate_to_fully_rsv_flag = 'Y') then
            px_asset_fin_rec_new.allocate_to_fully_ret_flag := 'Y';
            px_asset_fin_rec_new.excess_allocation_option   := null;
         elsif (px_asset_fin_rec_new.allocate_to_fully_rsv_flag = 'N') then
            px_asset_fin_rec_new.allocate_to_fully_ret_flag := 'N';
            if (nvl(px_asset_fin_rec_new.excess_allocation_option, 'XXX')
                                        not in ('REDUCE', 'DISTRIBUTE')) then
               px_asset_fin_rec_new.excess_allocation_option := 'REDUCE';
            end if;
         else
            px_asset_fin_rec_new.allocate_to_fully_rsv_flag := 'N';
            px_asset_fin_rec_new.allocate_to_fully_ret_flag := 'N';
         end if;

         px_asset_fin_rec_new.depreciation_option         := null;
         px_asset_fin_rec_new.member_rollup_flag         := null;

      elsif (px_asset_fin_rec_new.tracking_method = 'CALCULATE') then
         if (nvl(px_asset_fin_rec_new.depreciation_option, 'XXX') not in ('GROUP', 'MEMBER')) then
            px_asset_fin_rec_new.depreciation_option := 'MEMBER';
         end if;

         if (nvl(px_asset_fin_rec_new.member_rollup_flag, 'X') not in ('Y', 'N')) then
            px_asset_fin_rec_new.member_rollup_flag := 'N';
         end if;

         --
         -- Bug5032617:  Following if is just to ensure to prevent
         -- wrong combination of group setup values. (for API)
         --
         if ((px_asset_fin_rec_new.recognize_gain_loss = 'NO') or
             (px_asset_fin_rec_new.terminal_gain_loss <> 'YES')) and
            (px_asset_fin_rec_new.member_rollup_flag = 'Y') then
            fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_calc_pvt.calc_group_info',
                  name       => 'FA_INVALID_PARAMETER',
                  token1     => 'VALUE',
                  value1     => px_asset_fin_rec_new.recognize_gain_loss,
                  token2     => 'PARAM',
                  value2     => 'RECOGNIZE_GAIN_LOSS',  p_log_level_rec => p_log_level_rec);
            fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_calc_pvt.calc_group_info',
                  name       => 'FA_INVALID_PARAMETER',
                  token1     => 'VALUE',
                  value1     => px_asset_fin_rec_new.terminal_gain_loss,
                  token2     => 'PARAM',
                  value2     => 'TERMINAL_GAIN_LOSS',  p_log_level_rec => p_log_level_rec);
            fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_calc_pvt.calc_group_info',
                  name       => 'FA_INVALID_PARAMETER',
                  token1     => 'VALUE',
                  value1     => px_asset_fin_rec_new.member_rollup_flag,
                  token2     => 'PARAM',
                  value2     => 'MEMBER_ROLLUP_FLAG',  p_log_level_rec => p_log_level_rec);

            raise calc_err;
         end if;


         px_asset_fin_rec_new.allocate_to_fully_rsv_flag := null;
         px_asset_fin_rec_new.allocate_to_fully_ret_flag := null;
         px_asset_fin_rec_new.excess_allocation_option   := null;

      else
         fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_INVALID_TRACKING_METHOD', p_log_level_rec => p_log_level_rec);
         raise calc_err;
      end if; -- (px_asset_fin_rec_new.tracking_method is null)

   end if; -- (p_asset_hdr_rec.period_of_addition = 'Y') and

   px_asset_fin_rec_new.ytd_proceeds :=
      nvl(p_asset_fin_rec_adj.ytd_proceeds, 0) +
      nvl(p_asset_fin_rec_old.ytd_proceeds, 0);

   px_asset_fin_rec_new.ltd_proceeds :=
      nvl(p_asset_fin_rec_adj.ltd_proceeds, 0) +
      nvl(p_asset_fin_rec_old.ltd_proceeds, 0);

   px_asset_fin_rec_new.eofy_reserve :=
      nvl(p_asset_fin_rec_adj.eofy_reserve, 0) +
      nvl(p_asset_fin_rec_old.eofy_reserve, 0);

   FA_UTIL_PVT.load_char_value
           (p_char_old  => p_asset_fin_rec_old.terminal_gain_loss_flag,
            p_char_adj  => p_asset_fin_rec_adj.terminal_gain_loss_flag,
            x_char_new  => px_asset_fin_rec_new.terminal_gain_loss_flag, p_log_level_rec => p_log_level_rec);


   if (px_asset_fin_rec_new.cost <> 0) and
      (p_asset_fin_rec_old.terminal_gain_loss_flag = 'Y') then
      px_asset_fin_rec_new.terminal_gain_loss_flag := 'N';
   end if;

   if (px_asset_fin_rec_new.terminal_gain_loss_flag = 'Y') and
      (p_trans_rec.member_transaction_header_id is not null) then
      px_asset_fin_rec_new.terminal_gain_loss_flag := 'N';
   end if;

   return true;

EXCEPTION
   when calc_err then
      if (c_find_member_asset%ISOPEN) then
         CLOSE c_find_member_asset;
      end if;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      if (c_find_member_asset%ISOPEN) then
         CLOSE c_find_member_asset;
      end if;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_group_info;

FUNCTION calc_member_info
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

  CURSOR c_get_group_values IS
   SELECT recognize_gain_loss,
          recapture_reserve_flag,
          limit_proceeds_flag,
          terminal_gain_loss,
          exclude_proceeds_from_basis,
          retirement_deprn_option,
          tracking_method,
          allocate_to_fully_rsv_flag,
          allocate_to_fully_ret_flag,
          excess_allocation_option,
          depreciation_option,
          member_rollup_flag,
          reduction_rate,
          reduce_addition_flag,
          reduce_adjustment_flag,
          reduce_retirement_flag,
          disabled_flag, --hh
          over_depreciate_option -- hh
     FROM FA_BOOKS
    WHERE ASSET_ID = px_asset_fin_rec_new.group_asset_id
      AND BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND transaction_header_id_out is null;

   l_recognize_gain_loss         varchar2(30);
   l_recapture_reserve_flag      varchar2(1);
   l_limit_proceeds_flag         varchar2(1);
   l_terminal_gain_loss          varchar2(30);
   l_exclude_proceeds_from_basis varchar2(1);
   l_retirement_deprn_option     varchar2(30);
   l_tracking_method             varchar2(30);
   l_allocate_to_fully_rsv_flag  varchar2(1);
   l_allocate_to_fully_ret_flag  varchar2(1);
   l_excess_allocation_option    varchar2(30);
   l_depreciation_option         varchar2(30);
   l_member_rollup_flag          varchar2(1);
   l_reduction_rate              number;
   l_reduce_addition_flag        varchar2(1);
   l_reduce_adjustment_flag      varchar2(1);
   l_reduce_retirement_flag      varchar2(1);
   l_disabled_flag               varchar2(1); --HH
   l_over_depreciate_option      varchar2(30); --hh

   l_calling_fn                  VARCHAR2(40) := 'fa_asset_calc_pvt.calc_member_info';

   calc_member_err               EXCEPTION;

BEGIN

   -- This function will copy the tracking related columns from old structure
   -- to new structure. And if the group assignment is changed,
   -- get new tracking related columns from FA_BOOKS instead of copying
   -- old to new.

   -- Only when this asset is assigned to group, this module will be available.

   if px_asset_fin_rec_new.group_asset_id is not null then

     --
     -- Get group information for reduction rate and tracking related values.
     -- If there will be more, this can be replaced with get_asset_fin_rec.
     -- User cursor for now since we only need part of fa_books.
     --
     open c_get_group_values;
     fetch c_get_group_values into l_recognize_gain_loss,
                                   l_recapture_reserve_flag,
                                   l_limit_proceeds_flag,
                                   l_terminal_gain_loss,
                                   l_exclude_proceeds_from_basis,
                                   l_retirement_deprn_option,
                                   l_tracking_method,
                                   l_allocate_to_fully_rsv_flag,
                                   l_allocate_to_fully_ret_flag,
                                   l_excess_allocation_option,
                                   l_depreciation_option,
                                   l_member_rollup_flag,
                                   l_reduction_rate,
                                   l_reduce_addition_flag,
                                   l_reduce_adjustment_flag,
                                   l_reduce_retirement_flag,
                                   l_disabled_flag,
                                   l_over_depreciate_option;

     --
     -- Set reduction rate
     -- If this is addition and REDUCE_ADDITION flag is Y or
     -- this is adjustment and REDUCE_ADJUSTMENT flag is Y, then
     -- set group reduction rate is no value is passed in fin_rec_adj.
     -- Otherwise, add fin_rec_adj reduction rate to old one.
     --
     if ((p_trans_rec.transaction_type_code = 'ADDITION') and
         (l_reduce_addition_flag = 'Y')) or
        ((p_trans_rec.transaction_type_code = 'ADJUSTMENT') and
         (l_reduce_adjustment_flag = 'Y')) then
        if (p_asset_fin_rec_adj.reduction_rate is null) and
           (p_asset_fin_rec_old.reduction_rate is null) then
           px_asset_fin_rec_new.reduction_rate := nvl(l_reduction_rate, 0);
        else
           px_asset_fin_rec_new.reduction_rate :=
             nvl(p_asset_fin_rec_old.reduction_rate, 0) +
             nvl(p_asset_fin_rec_adj.reduction_rate, 0);
        end if;
     else
        px_asset_fin_rec_new.reduction_rate := to_number(null);
     end if;

     if px_asset_fin_rec_new.group_asset_id <>
        nvl(p_asset_fin_rec_old.group_asset_id,-99) then

        -- In case the group asset is changed, need to replace with new
        -- tracking related columns from FA_BOOKS.

        if c_get_group_values%NOTFOUND then

           -- This is a case in which tracking method is not assigned to the group
           -- to which this member asset belongs...

           fa_srvr_msg.add_message(
                     calling_fn => 'fa_asset_calc_pvt.calc_member_info',
                     name       => 'FA_BOOK_INEFFECTIVE_BOOK',  p_log_level_rec => p_log_level_rec);
           raise calc_member_err;

        else

           -- New tracking related columns will be set to new structure.

           px_asset_fin_rec_new.recognize_gain_loss        := l_recognize_gain_loss;
           px_asset_fin_rec_new.recapture_reserve_flag     := l_recapture_reserve_flag;
           px_asset_fin_rec_new.limit_proceeds_flag        := l_limit_proceeds_flag;
           px_asset_fin_rec_new.terminal_gain_loss         := l_terminal_gain_loss;
           px_asset_fin_rec_new.exclude_proceeds_from_basis := l_exclude_proceeds_from_basis;
           px_asset_fin_rec_new.retirement_deprn_option    := l_retirement_deprn_option;
           px_asset_fin_rec_new.tracking_method            := l_tracking_method;
           px_asset_fin_rec_new.allocate_to_fully_rsv_flag := l_allocate_to_fully_rsv_flag;
           px_asset_fin_rec_new.allocate_to_fully_ret_flag := l_allocate_to_fully_ret_flag;
           px_asset_fin_rec_new.excess_allocation_option   := l_excess_allocation_option;
           px_asset_fin_rec_new.depreciation_option        := l_depreciation_option;
           px_asset_fin_rec_new.member_rollup_flag         := l_member_rollup_flag;
           px_asset_fin_rec_new.disabled_flag              := l_disabled_flag; --HH
           px_asset_fin_rec_new.over_depreciate_option     := l_over_depreciate_option; --hh

        end if;

     else -- group assignment is not changed
          -- In this case, just copy from old to new.
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,'group assignment','not changed', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn,'old OD option',p_asset_fin_rec_old.over_depreciate_option, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn,'New OD option',px_asset_fin_rec_new.over_depreciate_option, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn,'selected OD option',l_over_depreciate_option, p_log_level_rec => p_log_level_rec);
        end if;

        px_asset_fin_rec_new.recognize_gain_loss :=
                  p_asset_fin_rec_old.recognize_gain_loss;

        px_asset_fin_rec_new.recapture_reserve_flag :=
                  p_asset_fin_rec_old.recapture_reserve_flag;

        px_asset_fin_rec_new.limit_proceeds_flag :=
                  p_asset_fin_rec_old.limit_proceeds_flag;

        px_asset_fin_rec_new.exclude_proceeds_from_basis :=
                  p_asset_fin_rec_old.exclude_proceeds_from_basis;

        px_asset_fin_rec_new.retirement_deprn_option :=
                  p_asset_fin_rec_old.retirement_deprn_option;

        px_asset_fin_rec_new.terminal_gain_loss :=
                  p_asset_fin_rec_old.terminal_gain_loss;

        px_asset_fin_rec_new.tracking_method :=
                  p_asset_fin_rec_old.tracking_method;

        px_asset_fin_rec_new.allocate_to_fully_rsv_flag :=
                  p_asset_fin_rec_old.allocate_to_fully_rsv_flag;

        px_asset_fin_rec_new.allocate_to_fully_ret_flag :=
                  p_asset_fin_rec_old.allocate_to_fully_ret_flag;

        px_asset_fin_rec_new.excess_allocation_option :=
                  p_asset_fin_rec_old.excess_allocation_option;

        px_asset_fin_rec_new.depreciation_option :=
                  p_asset_fin_rec_old.depreciation_option;

        px_asset_fin_rec_new.member_rollup_flag :=
                  p_asset_fin_rec_old.member_rollup_flag;
        --HH
        px_asset_fin_rec_new.disabled_flag :=
                  p_asset_fin_rec_old.disabled_flag;
        --make sure there is a value here for cost sign change function
        px_asset_fin_rec_new.over_depreciate_option     :=
                  nvl(p_asset_fin_rec_old.over_depreciate_option, l_over_depreciate_option);
       --eHH

      end if; -- px_asset_fin_rec_new.group_asset_id <> nvl(p_asset_f.....

      close c_get_group_values;

   end if; -- px_asset_fin_rec_new.group_asset_id is not null;

   if p_asset_hdr_rec.period_of_addition = 'Y' then
      px_asset_fin_rec_new.eofy_reserve := nvl(p_asset_deprn_rec_old.deprn_reserve, 0) -
                                           nvl(p_asset_deprn_rec_old.ytd_deprn, 0);
   else
      px_asset_fin_rec_new.eofy_reserve :=
         nvl(p_asset_fin_rec_adj.eofy_reserve, 0) +
         nvl(p_asset_fin_rec_old.eofy_reserve, 0);
   end if;

   return true;

EXCEPTION
   when calc_member_err then
      if (c_get_group_values%ISOPEN) then
         CLOSE c_get_group_values;
      end if;

      return false;

   when others then
      if (c_get_group_values%ISOPEN) then
         CLOSE c_get_group_values;
      end if;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_member_info;


--RELOCATED
--RELOCATED  Relocated to FAVAMRTB.pls
--RELOCATED
--RELOCATED FUNCTION calc_raf_adj_cost
--RELOCATED    (p_trans_rec           IN            FA_API_TYPES.trans_rec_type,
--RELOCATED     p_asset_hdr_rec       IN            FA_API_TYPES.asset_hdr_rec_type,
--RELOCATED     p_asset_desc_rec      IN            FA_API_TYPES.asset_desc_rec_type,
--RELOCATED     p_asset_type_rec      IN            FA_API_TYPES.asset_type_rec_type,
--RELOCATED     p_asset_fin_rec_old   IN            FA_API_TYPES.asset_fin_rec_type,
--RELOCATED     px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
--RELOCATED     p_asset_deprn_rec_adj IN            FA_API_TYPES.asset_deprn_rec_type,
--RELOCATED     p_asset_deprn_rec_new IN            FA_API_TYPES.asset_deprn_rec_type,
--RELOCATED     p_period_rec          IN            FA_API_TYPES.period_rec_type,
--RELOCATED     p_mrc_sob_type_code   IN            VARCHAR2
--RELOCATED    ) RETURN BOOLEAN IS
--RELOCATED
--RELOCATED
--RELOCATED BEGIN
--RELOCATED
--RELOCATED return true;
--RELOCATED
--RELOCATED END calc_raf_adj_cost;
--RELOCATED


FUNCTION calc_standalone_info
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_Hdr_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_new     IN     FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   l_calling_fn                  VARCHAR2(40) := 'fa_asset_calc_pvt.calc_standalone_info';

BEGIN

   --
   -- Setting Group Related variables
   px_asset_fin_rec_new.reduction_rate := null;
   px_asset_fin_rec_new.reduce_addition_flag := null;
   px_asset_fin_rec_new.reduce_adjustment_flag := null;
   px_asset_fin_rec_new.reduce_retirement_flag := null;

   px_asset_fin_rec_new.recognize_gain_loss         := null;
   px_asset_fin_rec_new.recapture_reserve_flag      := null;
   px_asset_fin_rec_new.limit_proceeds_flag         := null;
   px_asset_fin_rec_new.terminal_gain_loss          := null;
   px_asset_fin_rec_new.exclude_proceeds_from_basis := null;
   px_asset_fin_rec_new.retirement_deprn_option     := null;

   px_asset_fin_rec_new.tracking_method             := null;
   px_asset_fin_rec_new.allocate_to_fully_rsv_flag  := null;
   px_asset_fin_rec_new.allocate_to_fully_ret_flag  := null;
   px_asset_fin_rec_new.excess_allocation_option    := null;
   px_asset_fin_rec_new.depreciation_option         := null;
   px_asset_fin_rec_new.member_rollup_flag          := null;
   px_asset_fin_rec_new.super_group_id              := null;
   px_asset_fin_rec_new.over_depreciate_option      := null;
   px_asset_fin_rec_new.ytd_proceeds                := null;
   px_asset_fin_rec_new.ltd_proceeds                := null;
   px_asset_fin_rec_new.ltd_cost_of_removal         := null;
   px_asset_fin_rec_new.exclude_fully_rsv_flag      := null;
   px_asset_fin_rec_new.terminal_gain_loss_flag     := null;

   if p_asset_hdr_rec.period_of_addition = 'Y' then
      px_asset_fin_rec_new.eofy_reserve := nvl(p_asset_deprn_rec_new.deprn_reserve, 0) -
                                           nvl(p_asset_deprn_rec_new.ytd_deprn, 0);
   else
      px_asset_fin_rec_new.eofy_reserve :=
         nvl(p_asset_fin_rec_adj.eofy_reserve, 0) +
         nvl(p_asset_fin_rec_old.eofy_reserve, 0);
   end if;

   return true;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_standalone_info;



END FA_ASSET_CALC_PVT;

/
