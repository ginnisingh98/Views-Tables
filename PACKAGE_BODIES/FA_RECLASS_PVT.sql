--------------------------------------------------------
--  DDL for Package Body FA_RECLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RECLASS_PVT" as
/* $Header: FAVRECB.pls 120.17.12010000.2 2009/07/19 11:16:17 glchen ship $   */


/* ---------------------------------------------------------------
 * Name            : Do_reclass
 * Type            : Function
 * Returns         : Boolean
 * Purpose         : Perform reclass transaction for an asset
 * Calling Details : This function expects the following parameters with
 *                   valid data for it to perform the Reclass transaction
 *                   successfully
 *                   px_trans_rec.amortization_start_date
 *                   px_asset_desc_rec.asset_number
 *                   pxx_asset_cat_rec_new.category_id
 * ---------------------------------------------------------------- */
  FUNCTION do_reclass (
            px_trans_rec           IN OUT NOCOPY   FA_API_TYPES.trans_rec_type,
            px_asset_desc_rec      IN OUT NOCOPY   FA_API_TYPES.asset_desc_rec_type,
            px_asset_hdr_rec       IN OUT NOCOPY   FA_API_TYPES.asset_hdr_rec_type,
            px_asset_type_rec      IN OUT NOCOPY   FA_API_TYPES.asset_type_rec_type,
            px_asset_cat_rec_old   IN OUT NOCOPY   FA_API_TYPES.asset_cat_rec_type,
            px_asset_cat_rec_new   IN OUT NOCOPY   FA_API_TYPES.asset_cat_rec_type,
            p_recl_opt_rec         IN              FA_API_TYPES.reclass_options_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                                                   return boolean IS

      l_err_stage       varchar2(230);
      i                 integer:= 1;
      l_asset_dist_tbl  FA_API_TYPES.asset_dist_tbl_type;
      l_trans_rec       FA_API_TYPES.trans_rec_type;

      l_calling_fn varchar2(40) := 'fa_reclass_pvt.do_reclass';
      call_err  EXCEPTION;

  BEGIN

     l_err_stage:= 'validate_reclass';
     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '-', 'before '||l_err_stage, p_log_level_rec => p_log_level_rec);
     end if;

     if NOT validate_reclass(
                             p_trans_rec         => px_trans_rec,
                             p_asset_desc_rec    => px_asset_desc_rec,
                             p_asset_hdr_rec     => px_asset_hdr_rec,
                             p_asset_type_rec    => px_asset_type_rec,
                             p_asset_cat_rec_old => px_asset_cat_rec_old,
                             p_asset_cat_rec_new => px_asset_cat_rec_new,
                             p_log_level_rec     => p_log_level_rec ) then

          raise call_err;
     end if;

     -- perform basic reclass
     -- Populate old and new dist lines
     l_err_stage:= 'fa_reclass_util_pvt.get_asset_distribution';

     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '-', 'before '||l_err_stage, p_log_level_rec => p_log_level_rec);
     end if;

     if NOT fa_reclass_util_pvt.get_asset_distribution(
                                p_trans_rec         => px_trans_rec,
                                p_asset_hdr_rec     => px_asset_hdr_rec,
                                p_asset_cat_rec_old => px_asset_cat_rec_old,
                                p_asset_cat_rec_new => px_asset_cat_rec_new,
                                px_asset_dist_tbl   => l_asset_dist_tbl,
                                p_calling_fn        => l_calling_fn , p_log_level_rec => p_log_level_rec) then
             raise call_err;
     end if;


    -- populate category desc flex info based on
    -- p_rec_opt_rec.copy_cat_desc_flag
     l_err_stage:= 'fa_reclass_util_pvt.get_cat_desc_flex';
     -- dbms_output.put_line(l_err_stage);
     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '-', 'before '||l_err_stage, p_log_level_rec => p_log_level_rec);
     end if;

     if NOT fa_reclass_util_pvt.get_cat_desc_flex(
                                p_asset_hdr_rec      => px_asset_hdr_rec,
                                px_asset_desc_rec    => px_asset_desc_rec,
                                p_asset_cat_rec_old  => px_asset_cat_rec_old,
                                px_asset_cat_rec_new => px_asset_cat_rec_new,
                                p_recl_opt_rec       => p_recl_opt_rec,
                                p_calling_fn         => l_calling_fn , p_log_level_rec => p_log_level_rec) then
            raise call_err;
     end if;

     -- save for future use as the do_distributions api populates the
     -- the transaction_subtype to RECLASS. This fails call to do_adjustments
     -- as it expects EXPENSED or AMORTIZED as trx_subtype
     l_trans_rec := px_trans_rec;

     -- BUG# 3325400
     -- forcing selection of the thid here rather
     -- then relying on table handler
     select fa_transaction_headers_s.nextval
       into px_trans_rec.transaction_header_id
       from dual;

     l_err_stage:= 'fa_distribution_pvt.do_distribution';
     -- dbms_output.put_line(l_err_stage);
     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '-', 'before '||l_err_stage, p_log_level_rec => p_log_level_rec);
     end if;

     if not fa_distribution_pvt.do_distribution(
                                px_trans_rec         => px_trans_rec,
                                px_asset_hdr_rec     => px_asset_hdr_rec,
                                px_asset_cat_rec_new => px_asset_cat_rec_new,
                                px_asset_dist_tbl    => l_asset_dist_tbl , p_log_level_rec => p_log_level_rec) then
            raise call_err;
     end if;

     /*
      * Code hook for IAC
      */
     if (FA_IGI_EXT_PKG.IAC_Enabled) then
     l_err_stage:= 'FA_IGI_EXT_PKG.Do_Reclass';
     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '-', 'before '||l_err_stage, p_log_level_rec => p_log_level_rec);
     end if;

        if not FA_IGI_EXT_PKG.Do_Reclass(
                    p_trans_rec         => px_trans_rec,
                    p_asset_hdr_rec     => px_asset_hdr_rec,
                    p_asset_cat_rec_old => px_asset_cat_rec_old,
                    p_asset_cat_rec_new => px_asset_cat_rec_new,
                    p_asset_desc_rec    => px_asset_desc_rec,
                    p_asset_type_rec    => px_asset_type_rec,
                    p_calling_function  => l_calling_fn ) then

            raise call_err;
        end if;
     end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

     -- save the transaction date for future use
     l_trans_rec.transaction_date_entered:= px_trans_rec.transaction_date_entered;

     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'transaction_date_entered', l_trans_rec.transaction_date_entered, p_log_level_rec => p_log_level_rec);
     end if;
     -- keep the rest same as original because the dist api updates few columns
     -- which we may not need
     l_trans_rec.transaction_header_id := px_trans_rec.transaction_header_id;
     px_trans_rec := l_trans_rec;

     if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'redefault_flag', p_recl_opt_rec.redefault_flag, p_log_level_rec => p_log_level_rec);
     end if;

     -- perform redefault
     if p_recl_opt_rec.redefault_flag = 'YES' then
       -- validate redefault
       -- dbms_output.put_line('validate redefault');
       if NOT validate_redefault(
                 px_trans_rec         => px_trans_rec,
                 px_asset_desc_rec    => px_asset_desc_rec,
                 px_asset_hdr_rec     => px_asset_hdr_rec,
                 px_asset_type_rec    => px_asset_type_rec,
                 px_asset_cat_rec_old => px_asset_cat_rec_old,
                 px_asset_cat_rec_new => px_asset_cat_rec_new,
                 p_mass_request_id    => null,
                 p_log_level_rec     => p_log_level_rec )  then
             raise call_err;
         end if;

       if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '-', 'before do_redefault', p_log_level_rec => p_log_level_rec);
       end if;
       -- do_redefault
       if NOT do_redefault(
                 px_trans_rec         => px_trans_rec,
                 px_asset_desc_rec    => px_asset_desc_rec,
                 px_asset_hdr_rec     => px_asset_hdr_rec,
                 px_asset_type_rec    => px_asset_type_rec,
                 px_asset_cat_rec_old => px_asset_cat_rec_old,
                 px_asset_cat_rec_new => px_asset_cat_rec_new,
                 p_mass_request_id    => p_recl_opt_rec.mass_request_id ,
                 p_log_level_rec     => p_log_level_rec)  then
             raise call_err;
         end if;

       end if;  /* p_redefault_flag */


     -- dbms_output.put_line('end of fa_reclass_pvt');
     return TRUE;

EXCEPTION
   when call_err then
         fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   when others then
         fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_reclass;


-- ------------------------------------------------------

-- ------------------------------------------------------
FUNCTION validate_reclass (
         p_trans_rec           IN   FA_API_TYPES.trans_rec_type,
         p_asset_desc_rec      IN   FA_API_TYPES.asset_desc_rec_type,
         p_asset_hdr_rec       IN   FA_API_TYPES.asset_hdr_rec_type,
         p_asset_type_rec      IN   FA_API_TYPES.asset_type_rec_type,
         p_asset_cat_rec_old   IN   FA_API_TYPES.asset_cat_rec_type,
         p_asset_cat_rec_new   IN   FA_API_TYPES.asset_cat_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

    l_err_stage varchar2(100);
    l_calling_fn varchar2(40) := 'fa_reclass_pvt.validate_reclass';
    call_err EXCEPTION;
BEGIN

    l_err_stage:= 'fa_reclass_util_pvt.validate_units';
    -- dbms_output.put_line(l_err_stage);
    if not fa_reclass_util_pvt.validate_units(
                                p_trans_rec.transaction_type_code,
                                p_asset_hdr_rec.asset_id,
                                l_calling_fn  , p_log_level_rec => p_log_level_rec) then
      raise call_err;
    end if;

    l_err_stage:= 'fa_reclass_util_pvt.validate_cat_types';
    -- dbms_output.put_line(l_err_stage);
    if not fa_reclass_util_pvt.validate_cat_types(
                               p_trans_rec.transaction_type_code,
                               p_asset_cat_rec_old.category_id,
                               p_asset_cat_rec_new.category_id,
                               p_asset_desc_rec.lease_id,
                               p_asset_hdr_rec.asset_id,
                               l_calling_fn  , p_log_level_rec => p_log_level_rec) then
      raise call_err;
    end if;

    -- validate CIP accounts
    l_err_stage:= 'fa_reclass_util_pvt.validate_CIP_accounts';
    -- dbms_output.put_line(l_err_stage);
    if not fa_reclass_util_pvt.validate_CIP_accounts(
                               p_trans_rec.transaction_type_code,
                               p_asset_hdr_rec.book_type_code,
                               p_asset_type_rec.asset_type,
                               p_asset_cat_rec_new.category_id,
                               l_calling_fn , p_log_level_rec => p_log_level_rec) then
      raise call_err;
    end if;

    l_err_stage:= 'fa_reclass_util_pvt.check_cat_book_setup';
    -- dbms_output.put_line(l_err_stage);
    if not fa_reclass_util_pvt.check_cat_book_setup(
                               p_trans_rec.transaction_type_code,
                               p_asset_cat_rec_new.category_id,
                               p_asset_hdr_rec.asset_id,
                               l_calling_fn  , p_log_level_rec => p_log_level_rec) then
      raise call_err;
    end if;

    l_err_stage:= 'fa_reclass_util_pvt.validate_pending_retire';
    -- dbms_output.put_line(l_err_stage);
    if not fa_reclass_util_pvt.validate_pending_retire(
                               p_trans_rec.transaction_type_code,
                               p_asset_hdr_rec.asset_id,
                               l_calling_fn  , p_log_level_rec => p_log_level_rec) then
      raise call_err;
    end if;

    l_err_stage:= 'fa_reclass_util_pvt.validate_fully_retired';
    -- dbms_output.put_line(l_err_stage);
    if not fa_reclass_util_pvt.validate_fully_retired(
                               p_trans_rec.transaction_type_code,
                               p_asset_hdr_rec.asset_id,
                               l_calling_fn , p_log_level_rec => p_log_level_rec) then
      raise call_err;
    end if;

/*
     -- validate transaction date
    if not fa_reclass_util_pvt.validate_transaction_date(
                                p_trans_rec,
                                p_asset_hdr_rec.asset_id,
                                p_asset_hdr_rec.book_type_code,
                                l_calling_fn , p_log_level_rec => p_log_level_rec) then
        raise call_err;
    end if;
*/


     return TRUE;

EXCEPTION
   when call_err then
   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   when others then
   fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END validate_reclass;

-- ----------------------------------------------------


-- ----------------------------------------------------

FUNCTION validate_redefault(
         px_trans_rec            IN   OUT NOCOPY  FA_API_TYPES.trans_rec_type,
         px_asset_desc_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_desc_rec_type,
         px_asset_hdr_rec        IN   OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
         px_asset_type_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_type_rec_type,
         px_asset_cat_rec_old    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         px_asset_cat_rec_new    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         p_mass_request_id       IN        NUMBER DEFAULT null , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS


BEGIN
   null;

  return TRUE;
END validate_redefault;


/* --------------------------------------------------------------------
*
*
*
*
* ---------------------------------------------------------------------- */
FUNCTION do_redefault(
         px_trans_rec            IN   OUT NOCOPY  FA_API_TYPES.trans_rec_type,
         px_asset_desc_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_desc_rec_type,
         px_asset_hdr_rec        IN   OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
         px_asset_type_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_type_rec_type,
         px_asset_cat_rec_old    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         px_asset_cat_rec_new    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         p_mass_request_id       IN        NUMBER DEFAULT null , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    CURSOR book_cr( p_asset_id number ) IS
            SELECT   TH.book_type_code
            FROM  FA_BOOK_CONTROLS BC,
                  FA_TRANSACTION_HEADERS TH
            WHERE TH.transaction_type_code||''  IN ('ADDITION','CIP ADDITION', 'GROUP ADDITION')
            AND      TH.asset_id = p_asset_id
            AND      BC.book_type_code = TH.book_type_code
            AND      nvl(BC.date_ineffective, sysdate + 1) > sysdate
            GROUP BY TH.book_type_code
            ORDER BY MIN(TH.date_effective);

    CURSOR get_old_rules( p_book varchar2, p_asset number ) IS
       SELECT book_type_code,
              date_placed_in_service, date_placed_in_service,
              prorate_convention_code, deprn_method_code,
              life_in_months, basic_rate, adjusted_rate,
              production_capacity, unit_of_measure,
              bonus_rule, NULL, ceiling_name,
              depreciate_flag, allowed_deprn_limit,
              allowed_deprn_limit_amount, percent_salvage_value
       FROM   FA_BOOKS bk
       WHERE  bk.book_type_code = p_book
       AND    bk.asset_id = p_asset
       AND    bk.date_ineffective IS NULL;

   l_book_type_code    varchar2(30);
   l_amortize_flag     varchar2(3);
   l_last_updated_by   number;
   l_last_update_date  date;
   l_last_update_login number;

   l_old_rules FA_LOAD_TBL_PKG.asset_deprn_info:= null;
   l_new_rules FA_LOAD_TBL_PKG.asset_deprn_info:= null;
   l_found BOOLEAN := FALSE;
   l_rule_change_exists boolean;

   l_rate_source_rules VARCHAR2(10);
   l_deprn_basis_rule  VARCHAR2(10);
   l_prorate_date      date;

   l_trans_rec           FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec       FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec      FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec      FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec       FA_API_TYPES.asset_cat_rec_type;
   l_asset_fin_rec       FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_adj   FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new   FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_adj FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new FA_API_TYPES.asset_deprn_rec_type;
   l_asset_dist_tbl      FA_API_TYPES.asset_dist_tbl_type;

   l_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;
   l_asset_deprn_mrc_tbl_new   FA_API_TYPES.asset_deprn_tbl_type;
   l_inv_trans_rec_dummy       FA_API_TYPES.inv_trans_rec_type;
   l_inv_tbl_dummy             FA_API_TYPES.inv_tbl_type;
   l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

   l_return_status  VARCHAR2(1);
   l_mesg_count      NUMBER;
   l_mesg_data       VARCHAR2(2000);

   l_corp_book varchar2(30);
   l_jdpis     number;

   l_calling_fn varchar2(40) := 'fa_reclass_pvt.do_redefault';
   call_err EXCEPTION;

BEGIN

    -- dbms_output.put_line('start do_default');

    if px_trans_rec.transaction_subtype = 'AMORTIZED' then
      l_amortize_flag := 'YES';
    else
      l_amortize_flag := 'NO';
    end if;

    if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'transaction_subtype', px_trans_rec.transaction_subtype, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_corp_book', px_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
    end if;
    -- Always corp book is passed in the asset_hdr_rec
    -- so save it for future use
    l_corp_book := px_asset_hdr_rec.book_type_code;

      -- load new deprn_rules
      -- dbms_output.put_line('load_Deprn_Rules');

      /* BUG# 3296729 - replacing this with call to common cache
       *
       * FA_LOAD_TBL_PKG.Load_Deprn_Rules_Tbl(
       *                p_corp_book => l_corp_book,
       *                p_category_id  => px_asset_cat_rec_new.category_id,
       *                x_return_status => l_found);
       * IF NOT l_found THEN
       *     raise call_err;
       * END IF;
       */


    FOR book_rec in book_cr(px_asset_hdr_rec.asset_id) LOOP

      -- validate redefault for each book
      -- dbms_output.put_line('FA_RECLASS_UTIL_PVT.Validate_Adjustment', p_log_level_rec => p_log_level_rec);
      if NOT FA_RECLASS_UTIL_PVT.Validate_Adjustment(
                                 p_transaction_type_code => px_trans_rec.transaction_type_code,
                                 p_asset_id              => px_asset_hdr_rec.asset_id,
                                 p_book_type_code        => book_rec.book_type_code,
                                 p_amortize_flag         => l_amortize_flag,
                                 p_mr_req_id             => null , p_log_level_rec => p_log_level_rec) then
          raise call_err;
      end if;

      -- Get old(current) depreciation rules from the current books row.
      -- dbms_output.put_line('get_old_rules for :'||book_rec.book_type_code);

      OPEN get_old_rules( book_rec.book_type_code, px_asset_hdr_rec.asset_id);
      FETCH get_old_rules INTO l_old_rules;
      CLOSE get_old_rules;

      l_found:= FALSE;
      -- dbms_output.put_line('Get_Deprn_Rules for : '||book_rec.book_type_code);
      -- dbms_output.put_line('start_dpis'||to_char(l_old_rules.start_dpis));
      -- Get new depreciation rules for the cursor_book.

      /* BUG# 3296729 - replacing this with call to common cache
       *
       * FA_LOAD_TBL_PKG.Get_Deprn_Rules(
       *            p_book_type_code         => book_rec.book_type_code,
       *            p_date_placed_in_service => l_old_rules.start_dpis,
       *            x_deprn_rules_rec        => l_new_rules,
       *            x_found                  => l_found );
       *  IF not l_found THEN
       *     raise call_err;
       *  END IF;
       */

      l_jdpis := to_number(to_char(l_old_rules.start_dpis, 'J'));

      if not fa_cache_pkg.fazccbd
               (X_book   => book_rec.book_type_code,
                X_cat_id => px_asset_cat_rec_new.category_id,
                X_jdpis  => l_jdpis, p_log_level_rec => p_log_level_rec) then
         raise call_err;
      end if;

      if (l_old_rules.deprn_method = 'JP-STL-EXTND') then
          l_new_rules := l_old_rules;
      else
          -- now load cached values into the new rules table
          l_new_rules.book_type_code          := book_rec.book_type_code;
          l_new_rules.start_dpis              := fa_cache_pkg.fazccbd_record.start_dpis;
          l_new_rules.end_dpis                := fa_cache_pkg.fazccbd_record.end_dpis;
          l_new_rules.prorate_conv_code       := fa_cache_pkg.fazccbd_record.prorate_convention_code;
          l_new_rules.deprn_method            := fa_cache_pkg.fazccbd_record.deprn_method;
          l_new_rules.life_in_months          := fa_cache_pkg.fazccbd_record.life_in_months;
          l_new_rules.basic_rate              := fa_cache_pkg.fazccbd_record.basic_rate;
          l_new_rules.adjusted_rate           := fa_cache_pkg.fazccbd_record.adjusted_rate;
          l_new_rules.production_capacity     := fa_cache_pkg.fazccbd_record.production_capacity;
          l_new_rules.unit_of_measure         := fa_cache_pkg.fazccbd_record.unit_of_measure;
          l_new_rules.bonus_rule              := fa_cache_pkg.fazccbd_record.bonus_rule;
          l_new_rules.itc_amount              := NULL;
          l_new_rules.ceiling_name            := fa_cache_pkg.fazccbd_record.ceiling_name;
          l_new_rules.depreciate_flag         := fa_cache_pkg.fazccbd_record.depreciate_flag;
          l_new_rules.allow_deprn_limit       := fa_cache_pkg.fazccbd_record.allowed_deprn_limit;
          l_new_rules.deprn_limit_amount      := fa_cache_pkg.fazccbd_record.special_deprn_limit_amount;
          l_new_rules.percent_salvage_value   := fa_cache_pkg.fazccbd_record.percent_salvage_value;

      end if;

      -- dbms_output.put_line('See if any rule change is needed');
      -- See if any rule change is needed.
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.book_type_code       ',l_new_rules.book_type_code       , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.start_dpis           ',l_new_rules.start_dpis           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.end_dpis             ',l_new_rules.end_dpis             , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.prorate_conv_code    ',l_new_rules.prorate_conv_code    , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.prorate_conv_code    ',l_old_rules.prorate_conv_code    , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.deprn_method         ',l_new_rules.deprn_method         , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.deprn_method         ',l_old_rules.deprn_method         , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.life_in_months       ',l_new_rules.life_in_months       , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.life_in_months       ',l_old_rules.life_in_months       , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.basic_rate           ',l_new_rules.basic_rate           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.basic_rate           ',l_old_rules.basic_rate           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.adjusted_rate        ',l_new_rules.adjusted_rate        , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.adjusted_rate        ',l_old_rules.adjusted_rate        , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.production_capacity  ',l_new_rules.production_capacity  , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.production_capacity  ',l_old_rules.production_capacity  , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.unit_of_measure      ',l_new_rules.unit_of_measure      , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.unit_of_measure      ',l_old_rules.unit_of_measure      , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.bonus_rule           ',l_new_rules.bonus_rule           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.bonus_rule           ',l_old_rules.bonus_rule           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.itc_amount           ',l_new_rules.itc_amount           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.itc_amount           ',l_old_rules.itc_amount           , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.ceiling_name         ',l_new_rules.ceiling_name         , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.ceiling_name         ',l_old_rules.ceiling_name         , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.depreciate_flag      ',l_new_rules.depreciate_flag      , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.depreciate_flag      ',l_old_rules.depreciate_flag      , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.allow_deprn_limit    ',l_new_rules.allow_deprn_limit    , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.allow_deprn_limit    ',l_old_rules.allow_deprn_limit    , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.deprn_limit_amount   ',l_new_rules.deprn_limit_amount   , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.deprn_limit_amount   ',l_old_rules.deprn_limit_amount   , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_new_rules.percent_salvage_value',l_new_rules.percent_salvage_value, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_old_rules.percent_salvage_value',l_old_rules.percent_salvage_value, p_log_level_rec => p_log_level_rec);

      end if;

      IF ((l_old_rules.prorate_conv_code = l_new_rules.prorate_conv_code) AND
          (l_old_rules.deprn_method = l_new_rules.deprn_method) AND
           (nvl(l_old_rules.life_in_months, 99999) =
                nvl(l_new_rules.life_in_months, 99999)) AND
           (nvl(l_old_rules.basic_rate, 99999) =
                nvl(l_new_rules.basic_rate, 99999)) AND
           (nvl(l_old_rules.adjusted_rate, 99999) =
                nvl(l_new_rules.adjusted_rate, 99999)) AND
           (nvl(l_old_rules.production_capacity, 99999) =
                nvl(l_new_rules.production_capacity, 99999)) AND
           (nvl(l_old_rules.unit_of_measure, 99999) =
                nvl(l_new_rules.unit_of_measure, 99999)) AND
           (nvl(l_old_rules.bonus_rule, 'NULL') =
                nvl(l_new_rules.bonus_rule, 'NULL')) AND
           (nvl(l_old_rules.ceiling_name, 'NULL') =
                nvl(l_new_rules.ceiling_name, 'NULL')) AND
/* Skip this check -- we will not change depreciate flag through mass reclass.
               (l_old_rules.depreciate_flag = l_new_rules.depreciate_flag) AND
*/
           (nvl(l_old_rules.percent_salvage_value, 99) =
                nvl(l_new_rules.percent_salvage_value, 99)))
      THEN
         if l_old_rules.allow_deprn_limit is not null then
            if (nvl(l_old_rules.allow_deprn_limit, 99) =
                nvl(l_new_rules.allow_deprn_limit, 99))  then
               l_rule_change_exists := FALSE;
            else
               l_rule_change_exists := TRUE;
            end if;
         elsif  l_old_rules.deprn_limit_amount is not null then
            if (nvl(to_char(l_old_rules.deprn_limit_amount), 'NULL') =
                nvl(to_char(l_new_rules.deprn_limit_amount), 'NULL'))  then
               l_rule_change_exists := FALSE;
            else
               l_rule_change_exists := TRUE;
            end if;
         elsif (l_new_rules.allow_deprn_limit is not null or
                l_new_rules.deprn_limit_amount is not null) then
            l_rule_change_exists := TRUE;
         else
            l_rule_change_exists := FALSE;
         end if;
      ELSE
         l_rule_change_exists := TRUE;
      END IF;
     --Bug6395440 starts
      --Commenting the following check and adding an IF condition below
      /*
      IF (NOT l_rule_change_exists) then
         return TRUE;
      END IF;
      */
      IF l_rule_change_exists then

	      /*==================================+
	       | Perform Redefault Transaction    |
	       +==================================*/
	       l_asset_hdr_rec:= null;
	       l_asset_hdr_rec:= px_asset_hdr_rec;
	       l_asset_hdr_rec.book_type_code := book_rec.book_type_code;

	       -- dbms_output.put_line('populate_adjust_info');
	       if (p_log_level_rec.statement_level) then
		    fa_debug_pkg.add(l_calling_fn, '-', 'before populate_adjust_info', p_log_level_rec => p_log_level_rec);
	       end if;
	       if NOT populate_adjust_info (
		       px_trans_rec               => px_trans_rec,
		       px_asset_hdr_rec           => l_asset_hdr_rec,
		       px_asset_desc_rec          => px_asset_desc_rec,
		       px_asset_type_rec          => px_asset_type_rec,
		       px_asset_cat_rec           => px_asset_cat_rec_new,
		       px_asset_fin_rec           => l_asset_fin_rec,
		       px_asset_fin_rec_adj       => l_asset_fin_rec_adj,
		       px_asset_deprn_rec         => l_asset_deprn_rec,
		       px_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
		       p_old_rules                => l_old_rules,
		       p_new_rules                => l_new_rules,
                       p_log_level_rec     => p_log_level_rec ) then
		   raise call_err;
	       end if;

	       -- reset the header_id for next book
	       px_trans_rec.transaction_header_id:= null;

	       /* Bug 2718610:
		  Passing the transaction_date_entered and amortization_start_date
		  as null to the Public Adjustments API. The Adj API will take care of
		  populating these values according to the current open period
		  of the book_type_code */

	       /* ****** commenting this fix for bug 3446237 ***** */
	       -- px_trans_rec.transaction_date_entered := null; -- bug 2718610
	       -- px_trans_rec.amortization_start_date  := null; -- bug 2718610
	       /* bug 2718610 is now indirectly fixed by bug 2888021 */


	       -- dbms_output.put_line('FA_ADJUSTMENT_PUB.do_adjustment');
	       if (p_log_level_rec.statement_level) then
		    fa_debug_pkg.add(l_calling_fn, '-', 'before FA_ADJUSTMENT_PUB.do_adjustment', p_log_level_rec => p_log_level_rec);
	       end if;
	       FA_ADJUSTMENT_PUB.do_adjustment(
				 p_api_version             => 1.0,
				 p_init_msg_list           => FND_API.G_FALSE,
				 p_commit                  => FND_API.G_FALSE,
				 p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
				 x_return_status           => l_return_status,
				 x_msg_count               => l_mesg_count,
				 x_msg_data                => l_mesg_data,
				 p_calling_fn              => 'FA_RECLASS_PVT.do_redefault',
				 px_trans_rec              => px_trans_rec,
				 px_asset_hdr_rec          => l_asset_hdr_rec,
				 p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
				 x_asset_fin_rec_new       => l_asset_fin_rec_new,
				 x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
				 px_inv_trans_rec          => l_inv_trans_rec_dummy,
				 px_inv_tbl                => l_inv_tbl_dummy,
				 p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
				 x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
				 x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
				 p_group_reclass_options_rec => l_group_reclass_options_rec );


	      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
		 -- dbms_output.put_line('fa_adjustment_pub error');
		 raise call_err;
	      end if;
	END IF;
   END LOOP;

   return TRUE;

EXCEPTION
   when call_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_redefault;


FUNCTION populate_adjust_info (
               px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
               px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
               px_asset_desc_rec         IN OUT NOCOPY FA_API_TYPES.asset_desc_rec_type,
               px_asset_type_rec         IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
               px_asset_cat_rec          IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
               px_asset_fin_rec          IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
               px_asset_fin_rec_adj      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
               px_asset_deprn_rec        IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
               px_asset_deprn_rec_adj    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
               p_old_rules               IN     FA_LOAD_TBL_PKG.asset_deprn_info,
               p_new_rules               IN     FA_LOAD_TBL_PKG.asset_deprn_info
               , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

     CURSOR get_prorate_date(p_dpis date) IS
            SELECT conv.prorate_date
            FROM FA_CONVENTIONS conv
            WHERE conv.prorate_convention_code = p_new_rules.prorate_conv_code
            AND p_dpis between conv.start_date and conv.end_date;

     l_use_deprn_limits_flag    VARCHAR2(3) := 'NO';
     l_prorate_date date;
     l_status boolean;
     l_fiscal_year_name varchar2(30);

     l_calling_fn varchar2(40) := 'fa_reclass_pvt.populate_adjust_info';
     call_err EXCEPTION;
BEGIN


     if NOT FA_UTIL_PVT.get_asset_desc_rec(
                        p_asset_hdr_rec    => px_asset_hdr_rec,
                        px_asset_desc_rec  => px_asset_desc_rec , p_log_level_rec => p_log_level_rec) then
         raise call_err;
     end if;

     if NOT FA_UTIL_PVT.get_asset_type_rec(
                        p_asset_hdr_rec    => px_asset_hdr_rec,
                        px_asset_type_rec  => px_asset_type_rec,
                        p_date_effective   => null , p_log_level_rec => p_log_level_rec)  then
       raise call_err;
     end if;

     if NOT FA_UTIL_PVT.get_asset_cat_rec(
                        p_asset_hdr_rec  => px_asset_hdr_rec,
                        px_asset_cat_rec => px_asset_cat_rec,
                        p_date_effective => null , p_log_level_rec => p_log_level_rec) then
       raise call_err;
     end if;

     if NOT FA_UTIL_PVT.get_asset_fin_rec(
                        p_asset_hdr_rec         => px_asset_hdr_rec,
                        px_asset_fin_rec        => px_asset_fin_rec,
                        p_transaction_header_id => null,
                        p_mrc_sob_type_code     => 'P', p_log_level_rec => p_log_level_rec) then
       raise call_err;
     end if;

     -- copy orig record to adjusted record
     -- px_asset_fin_rec_adj:= px_asset_fin_rec;

     if NOT FA_UTIL_PVT.get_asset_deprn_rec(
                        p_asset_hdr_rec     => px_asset_hdr_rec,
                        px_asset_deprn_rec  => px_asset_deprn_rec,
                        p_period_counter    => null,
                        p_mrc_sob_type_code => 'P', p_log_level_rec => p_log_level_rec) then
       raise call_err;
     end if;

     -- copy orig record to adjusted record
     -- px_asset_deprn_rec_adj:= px_asset_deprn_rec;


     -- assign new values to the adj record, based on the new rules
     --
     -- BUG# 3361196 - we need to populate the delta not the new values
     -- note the premise that null values in category result in
     -- null values in the new (don't treat null as delta here)

     px_asset_fin_rec_adj.unit_of_measure            := p_new_rules.unit_of_measure;
     px_asset_fin_rec_adj.deprn_method_code          := p_new_rules.deprn_method;
     px_asset_fin_rec_adj.life_in_months             := p_new_rules.life_in_months;
     px_asset_fin_rec_adj.prorate_convention_code    := p_new_rules.prorate_conv_code;
     -- BUG# 3930865
     -- we should not be setting dep_flag as part of redefault
     -- already removed from prior checks
     -- px_asset_fin_rec_adj.depreciate_flag            := p_new_rules.depreciate_flag;
     px_asset_fin_rec_adj.basic_rate                 := p_new_rules.basic_rate;
     px_asset_fin_rec_adj.adjusted_rate              := p_new_rules.adjusted_rate;


     -- use G_MISS_* here....

     if (p_new_rules.ceiling_name is null) then
         px_asset_fin_rec_adj.ceiling_name           := FND_API.G_MISS_CHAR;
     else
         px_asset_fin_rec_adj.ceiling_name           := p_new_rules.ceiling_name;
     end if;

     if (p_new_rules.bonus_rule is null) then
        px_asset_fin_rec_adj.bonus_rule              := FND_API.G_MISS_CHAR;
     else
        px_asset_fin_rec_adj.bonus_rule              := p_new_rules.bonus_rule;
     end if;


     -- these are where we need to derive values using the delta
     -- first derive the types
     --
     -- note the premise that null values in category result in
     -- null values in the new (don't treat null as delta here)
     -- the behavior on delta salvage is dabateable
     --
     -- (whether to remove/reverse or treat as no delta)
     -- for now going with no delta since majority of customer
     -- do not use percent salvage on the category

     if (p_new_rules.percent_salvage_value is not null) then
        px_asset_fin_rec_adj.salvage_type          := 'PCT';
        px_asset_fin_rec_adj.percent_salvage_value :=
           p_new_rules.percent_salvage_value -
              nvl(p_old_rules.percent_salvage_value, 0);
     else
        px_asset_fin_rec_adj.percent_salvage_value      := NULL;

        -- use default type  based on asset type
        if (px_asset_type_rec.asset_type = 'GROUP') then
           px_asset_fin_rec_adj.salvage_type := 'PCT';
        else
           px_asset_fin_rec_adj.salvage_type := 'AMT';
        end if;
     end if;

     if (p_new_rules.allow_deprn_limit is not null) then
        px_asset_fin_rec_adj.deprn_limit_type           := 'PCT';
        px_asset_fin_rec_adj.allowed_deprn_limit        :=
           p_new_rules.allow_deprn_limit -
              nvl(p_old_rules.allow_deprn_limit, 0);
     elsif (p_new_rules.deprn_limit_amount is not null) then
        px_asset_fin_rec_adj.deprn_limit_type           := 'AMT';
        if (p_old_rules.allow_deprn_limit is not null) then
           px_asset_fin_rec_adj.allowed_deprn_limit_amount :=
              p_new_rules.deprn_limit_amount;
        else
           px_asset_fin_rec_adj.allowed_deprn_limit_amount :=
              p_new_rules.deprn_limit_amount -
                 nvl(p_old_rules.deprn_limit_amount, 0);
        end if;

     else
         -- type of NONE will handle the reversal from prior info
        px_asset_fin_rec_adj.deprn_limit_type           := 'NONE';
        px_asset_fin_rec_adj.allowed_deprn_limit        := NULL;
        px_asset_fin_rec_adj.allowed_deprn_limit_amount := NULL;
     end if;

     if (p_new_rules.production_capacity is not null) then
        px_asset_fin_rec_adj.production_capacity        :=
           p_new_rules.production_capacity -
              nvl(p_old_rules.production_capacity, 0);
     end if;

     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_adj.deprn_limit_type',px_asset_fin_rec_adj.deprn_limit_type, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_adj.allowed_deprn_limit', px_asset_fin_rec_adj.allowed_deprn_limit, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_adj.allowed_deprn_limit_amount', px_asset_fin_rec_adj.allowed_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_adj.salvage_type', px_asset_fin_rec_adj.salvage_type, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_adj.percent_salvage_value', px_asset_fin_rec_adj.percent_salvage_value, p_log_level_rec => p_log_level_rec);
    end if;

     /*** this was where the old code for old trx engine call was ***/

     return TRUE;

EXCEPTION
  when call_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     return FALSE;

END populate_adjust_info;


END FA_RECLASS_PVT;

/
