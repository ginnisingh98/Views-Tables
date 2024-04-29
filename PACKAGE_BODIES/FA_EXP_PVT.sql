--------------------------------------------------------
--  DDL for Package Body FA_EXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_EXP_PVT" as
/* $Header: FAVEXAJB.pls 120.12.12010000.6 2009/11/13 11:57:32 deemitta ship $ */

g_release                  number  := fa_cache_pkg.fazarel_release;

Function faxbds
     (
     p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
     px_asset_fin_rec_new IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     p_asset_deprn_rec    IN     FA_API_TYPES.asset_deprn_rec_type,
     p_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
     X_dpr_ptr               out NOCOPY fa_std_types.dpr_struct,
     X_deprn_rsv             out NOCOPY number,
     X_bonus_deprn_rsv       out NOCOPY number,
     X_impairment_rsv        out NOCOPY number,
     p_amortized_flag                   boolean,
     p_extended_flag                    boolean default FALSE, -- Japan Tax Phase3 Bug 6624784
     p_mrc_sob_type_code  IN     VARCHAR2
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   l_rate_source_rule   varchar2(40);
   l_prorate_calendar   varchar2(48);
   l_fy_name            varchar2(45);
   l_deprn_calendar     varchar2(48);
   l_period_num         integer;
   l_start_jdate        integer;
   l_prorate_jdate      integer;
   l_deprn_start_jdate  integer;
   l_jdate_in_svc       integer;
   l_use_jdate          integer;
   l_prorate_fy         integer;
   l_deprn_period       integer;
   l_deprn_fy           integer;
   l_pers_per_yr        integer;
   l_last_per_ctr       integer;
   l_cur_fy             integer;
   l_cur_per_num        integer;
   l_start_per_num      integer := 1 ; -- Japan Tax Phase3 Bug 6624784
   l_dummy_per_num      integer;
   l_dummy_int          integer;
   l_dummy_bool         boolean;
   l_dummy_varch        varchar2(16);

begin <<FAXBDS>>

   if (not FA_CACHE_PKG.fazccmt(px_asset_fin_rec_new.deprn_method_code,
                                px_asset_fin_rec_new.life_in_months,
                                p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   l_rate_source_rule      := fa_cache_pkg.fazccmt_record.rate_source_rule;

   X_dpr_ptr.adj_cost        := px_asset_fin_rec_new.adjusted_cost;
   X_dpr_ptr.rec_cost        := px_asset_fin_rec_new.recoverable_cost;
   X_dpr_ptr.reval_amo_basis := px_asset_fin_rec_new.reval_amortization_basis;
   X_dpr_ptr.adj_rate        := px_asset_fin_rec_new.adjusted_rate;
   X_dpr_ptr.capacity        := px_asset_fin_rec_new.production_capacity;
   X_dpr_ptr.adj_capacity    := px_asset_fin_rec_new.adjusted_capacity;
   X_dpr_ptr.adj_rec_cost    := px_asset_fin_rec_new.adjusted_recoverable_cost;
   X_dpr_ptr.salvage_value   := px_asset_fin_rec_new.salvage_value;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('faxbds','faamrt1 2nd user exit new adj cost',
                       px_asset_fin_rec_new.adjusted_recoverable_cost, p_log_level_rec);
      fa_debug_pkg.add('faxbds','faamrt1 3rd user exit salvage_value',
                       px_asset_fin_rec_new.salvage_value, p_log_level_rec);
      fa_debug_pkg.add('faxbds','Japan Tax p_extended_flag',
                       p_extended_flag, p_log_level_rec);
   end if;

   X_dpr_ptr.deprn_rounding_flag := px_asset_fin_rec_new.annual_deprn_rounding_flag;
   X_dpr_ptr.ceil_name           := px_asset_fin_rec_new.ceiling_name;
   X_dpr_ptr.bonus_rule          := px_asset_fin_rec_new.bonus_rule;
   X_dpr_ptr.life                := px_asset_fin_rec_new.life_in_months;
   X_dpr_ptr.method_code         := px_asset_fin_rec_new.deprn_method_code;
   X_dpr_ptr.asset_num           := p_asset_desc_rec.asset_number;

   if (p_amortized_flag) then
      X_dpr_ptr.rate_adj_factor := 1;
   else
      X_dpr_ptr.rate_adj_factor := px_asset_fin_rec_new.rate_adjustment_factor;
   end if;

   l_last_per_ctr            := fa_cache_pkg.fazcbc_record.last_period_counter;
   l_cur_fy                  := fa_cache_pkg.fazcbc_record.current_fiscal_year;
   l_cur_per_num             := mod((l_last_per_ctr+1),l_cur_fy);
   l_deprn_calendar          := fa_cache_pkg.fazcbc_record.deprn_calendar;
   l_prorate_calendar        := fa_cache_pkg.fazcbc_record.prorate_calendar;
   l_prorate_jdate           := to_number(to_char(px_asset_fin_rec_new.prorate_date, 'J'));
   l_deprn_start_jdate       := to_number(to_char(px_asset_fin_rec_new.deprn_start_date, 'J'));
   l_jdate_in_svc            := to_number(to_char(px_asset_fin_rec_new.date_placed_in_service, 'J'));

   l_fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;

   if not fa_cache_pkg.fazccp(l_prorate_calendar,
                              l_fy_name,
                              l_prorate_jdate,
                              l_dummy_per_num,
                              l_prorate_fy,
                              l_start_jdate,
                              p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   if (l_rate_source_rule = fa_std_types.FAD_RSR_CALC) or
      (l_rate_source_rule = fa_std_types.FAD_RSR_FORMULA) then
      l_use_jdate := l_prorate_jdate;
   else
      l_use_jdate := l_deprn_start_jdate;
   end if;

   if not fa_cache_pkg.fazccp(l_deprn_calendar,
                              l_fy_name,
                              l_use_jdate,
                              l_deprn_period,
                              l_deprn_fy,
                              l_start_jdate,
                              p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   if not fa_cache_pkg.fazcct (l_deprn_calendar, p_log_level_rec => p_log_level_rec) then
     fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
     return (FALSE);
   end if;

   l_pers_per_yr               := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
   X_dpr_ptr.calendar_type     := fa_cache_pkg.fazcbc_record.deprn_calendar;
   X_dpr_ptr.prorate_jdate     := l_prorate_jdate;
   X_dpr_ptr.deprn_start_jdate := l_deprn_start_jdate;
   X_dpr_ptr.jdate_retired     := 0;
   X_dpr_ptr.ret_prorate_jdate := 0;
   X_dpr_ptr.jdate_in_service  := l_jdate_in_svc;
   X_dpr_ptr.asset_id          := p_asset_hdr_rec.asset_id;
   X_dpr_ptr.book              := p_asset_hdr_rec.book_type_code;

   -- no need to call query balances as it's been done
   -- previously and contents are in deprn_rec

   -- Send in 0 value in faxcde for deprn_rsv and bonus_rsv
   -- X_dpr_ptr.bonus_deprn_rsv   := p_asset_deprn_rec.bonus_deprn_rsv;
   X_deprn_rsv                 := p_asset_deprn_rec.deprn_reserve;
   X_bonus_deprn_rsv           := p_asset_deprn_rec.bonus_deprn_reserve;
   X_impairment_rsv            := p_asset_deprn_rec.impairment_reserve;
   X_dpr_ptr.reval_rsv         := p_asset_deprn_rec.reval_deprn_reserve;
   X_dpr_ptr.prior_fy_exp      := p_asset_deprn_rec.prior_fy_expense;
   X_dpr_ptr.ytd_deprn         := p_asset_deprn_rec.ytd_deprn;
   X_dpr_ptr.bonus_ytd_deprn   := p_asset_deprn_rec.bonus_ytd_deprn;
   X_dpr_ptr.ytd_impairment    := p_asset_deprn_rec.ytd_impairment;

   -- Pass zero ltd_prod into faxcde(), just like we do for deprn_rsv
   X_dpr_ptr.ltd_prod := 0;

   -- Japan Tax Phase3 Bug 6624784
   -- For extended transaction expense needs to be calculated
   -- from extended_depreciation_period
   if (p_extended_flag) then
      if (px_asset_fin_rec_new.extended_depreciation_period < (l_last_per_ctr + 1 )) then
         -- Extended Period
         BEGIN
            select fiscal_year, period_num
            into   l_prorate_fy, l_start_per_num
            from   fa_deprn_periods
            where  period_counter = px_asset_fin_rec_new.extended_depreciation_period
            and    book_type_code = p_asset_hdr_rec.book_type_code;
            -- Added by Satish Byreddy To cater the Extended Depreciation Catchup calculation for Migrated Assets
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               select fc.period_num
                    , ffy.fiscal_year
               into   l_start_per_num
                    , l_prorate_fy
               from   fa_calendar_periods fc
                    , fa_book_controls fb
                    , fa_fiscal_year ffy
                    , fa_calendar_types fct
               where  fc.calendar_type = fb.deprn_calendar
               and    fb.book_type_code = p_asset_hdr_rec.book_type_code
               and    ffy.fiscal_year_name = fb.fiscal_year_name
               and    ffy.fiscal_year_name = fct.fiscal_year_name
               and    fc.calendar_type = fct.calendar_type
               and    fct.calendar_type = fb.deprn_calendar
               and    fc.start_date >= ffy.start_date
               and    fc.end_date <= ffy.end_date
               and    (ffy.fiscal_year *  fct.number_per_fiscal_year + fc.period_num) =
                                                                     px_asset_fin_rec_new.extended_depreciation_period;

            WHEN OTHERS THEN
               l_prorate_fy := l_cur_fy;
               l_start_per_num := l_cur_per_num;
         END;
         -- End Of Addition by Satish Byreddy To cater the Extended Depreciation Catchup calculation for Migrated Assets
      end if;
   end if;

   X_dpr_ptr.y_begin := l_prorate_fy;

   if (l_cur_per_num = 1) then
      X_dpr_ptr.y_end := l_cur_fy - 1;
   else
      X_dpr_ptr.y_end := l_cur_fy;
   end if;

   X_dpr_ptr.p_cl_begin := l_start_per_num; -- Japan Tax Phase3 Bug 6624784

   if (l_cur_per_num = 1) then
      X_dpr_ptr.p_cl_end := l_pers_per_yr;
   else
      X_dpr_ptr.p_cl_end := l_cur_per_num - 1;
   end if;

   X_dpr_ptr.deprn_rsv      := 0;
   X_dpr_ptr.rsv_known_flag := TRUE;

   -- Adding the following for short tax years and formula based
   X_dpr_ptr.short_fiscal_year_flag := px_asset_fin_rec_new.short_fiscal_year_flag;
   X_dpr_ptr.conversion_date        := px_asset_fin_rec_new.conversion_date;
   X_dpr_ptr.prorate_date           := px_asset_fin_rec_new.prorate_date;
   X_dpr_ptr.orig_deprn_start_date  := px_asset_fin_rec_new.orig_deprn_start_date;
   X_dpr_ptr.formula_factor         := NVL(px_asset_fin_rec_new.formula_factor,1); --bug2692127

   return(TRUE);

exception
   when others then
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
end FAXBDS;

Function faxexp
         (px_trans_rec         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec      IN     FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec     IN     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old  IN     FA_API_TYPES.asset_fin_rec_type,
          px_asset_fin_rec_new IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec    IN     FA_API_TYPES.asset_deprn_rec_type,
          p_period_rec         IN     FA_API_TYPES.period_rec_type,
          p_mrc_sob_type_code  IN     VARCHAR2,
          p_running_mode         IN     NUMBER,
          p_used_by_revaluation  IN     NUMBER,
          x_deprn_exp             out NOCOPY number,
          x_bonus_deprn_exp       out NOCOPY number,
          x_impairment_exp        out NOCOPY number,
          x_ann_adj_deprn_exp     out NOCOPY number,
          x_ann_adj_bonus_deprn_exp   out NOCOPY number,
          p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   l_cur_deprn_rsv       number;
   l_cur_bonus_deprn_rsv number;
   l_cur_impairment_rsv  number;
   l_rate_source_rule    varchar2(40);
   l_deprn_basis_rule    varchar(40);
   l_dpr                 fa_std_types.dpr_struct;
   l_dpr_out             fa_std_types.dpr_out_struct;
   l_dpr_asset_num       varchar2(16);
   l_dpr_calendar_type   varchar2(16);
   l_dpr_ceil_name       varchar2(31);
   l_dummy_dpr_arr       fa_std_types.dpr_arr_type;
   l_dummy_int           integer;
   l_dummy_bool          boolean;
   l_pers_per_yr         integer      := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
   l_start_per_num       integer      := 1;

   -- NOTE: Fixed to bug#1583869 - hsugimot
   -- This solve the problem that you do expensed adjustment
   -- when the depreciation flag of the asset is off.

   l_new_deprn_rsv     number;
   l_new_prior_fy_exp  number;
   l_new_adj_cost      number;

   -- Fixed to bug#1762518 - hsugimot
   l_cur_fy              integer;
   l_cur_per_num         integer;

   --For Depreciable Basis Rule
   l_hyp_total_ytd        number;
   -- bug 9110995 FP Bug 8571102 During catchup for flat rates/NBV, we are in strict flat mode.
   l_hyp_total_rsv        number;
   l_hyp_rsv              number;
   -- bug 9110995 FP Bug 8571102
   -- override for what if
   l_running_mode         number;

   -- Japan Tax Phase3
   l_set_extend_flag      boolean := FALSE;
   l_reset_extend_flag    boolean := FALSE;
   -- Bug 6624784
   l_asset_fin_rec        FA_API_TYPES.asset_fin_rec_type;

   --Bug8350248
   CURSOR c_extend_get_original_adjcost(p_asset_id       number,
                                        p_book_type_code varchar2) is
      select bk_old.adjusted_cost
      from   fa_books bk_old
           , fa_books bk_extnd
      where  bk_old.book_type_code = p_book_type_code
      and    bk_old.asset_id = p_asset_id
      and    bk_old.extended_depreciation_period is null
      and    bk_extnd.book_type_code = p_book_type_code
      and    bk_extnd.asset_id = p_asset_id
      and    bk_extnd.extended_depreciation_period is not null
      and    bk_extnd.transaction_header_id_in = bk_old.transaction_header_id_out
      order by bk_extnd.transaction_header_id_in desc;

   l_adjusted_cost number;

begin <<FAXEXP>>

   -- Japan Tax Phase3
   l_asset_fin_rec := px_asset_fin_rec_new;
   if ((nvl(px_asset_fin_rec_new.extended_deprn_flag,'N') = 'Y') and
       (nvl(p_asset_fin_rec_old.extended_deprn_flag,'N') in ('N','D'))) then
      l_set_extend_flag := TRUE;
   elsif ((nvl(px_asset_fin_rec_new.extended_deprn_flag,'N') in ('N','D')) and
          (nvl(p_asset_fin_rec_old.extended_deprn_flag,'N') = 'Y')) then
      l_reset_extend_flag := TRUE;
      -- While resetting extended_deprn_flag, catchup that needs to be reversed
      -- should be calculated based on old fin rec.
      l_asset_fin_rec := p_asset_fin_rec_old;
   end if;

   -- bonus: function is also called from FAAMRT1B.pls, FATXRSVB.pls
   if not faxbds
          (p_asset_hdr_rec      => p_asset_hdr_rec,
           px_asset_fin_rec_new => l_asset_fin_rec,
           p_asset_deprn_rec    => p_asset_deprn_rec,
           p_asset_desc_rec     => p_asset_desc_rec,
           X_dpr_ptr            => l_dpr,
           X_deprn_rsv          => l_cur_deprn_rsv,
           X_bonus_deprn_rsv    => l_cur_bonus_deprn_rsv,
           X_impairment_rsv     => l_cur_impairment_rsv,
           p_amortized_flag     => FALSE,
           p_extended_flag      => (l_set_extend_flag or l_reset_extend_flag),
           p_mrc_sob_type_code  => p_mrc_sob_type_code,
           p_Log_level_rec      => p_Log_level_rec) then
      fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   --
   -- Bug3379855: ytd needs to be 0 for expense adjustment since rsv is 0
   --      in faxbds as well bonus rsv is not 0 so keep bonus ytd as it is.
   --
   l_dpr.ytd_deprn         := 0;

   px_trans_rec.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;

   -- Don't calculate expense for CIP/EXPENSED assets
   --
   -- Bug 1952858
   -- Need to check if the asset cost = 0 and the
   -- depreciate_flag = 'N'. This way we could
   -- recalculate the expense after the user
   -- adjusts the cost to 0.

   if (p_asset_type_rec.asset_type = 'CAPITALIZED' ) then
      if (px_asset_fin_rec_new.depreciate_flag = 'YES')  OR
         (px_asset_fin_rec_new.cost = 0 and
          px_asset_fin_rec_new.depreciate_flag = 'NO') then
         -- Call faxcde to get the recalculated expense
         -- bonus: here is a solution for bringing cur_bonus_deprn_rsv
         -- it may get necessary to add a new parameter to faxbds call,
         -- and handle bonus deprn rsv simular as deprn rsv.

         -- Bug#5032680 No reason to reset this:  l_cur_bonus_deprn_rsv := l_dpr.bonus_deprn_rsv;
         l_dpr.bonus_deprn_rsv := 0;

         l_cur_impairment_rsv := l_dpr.impairment_rsv;
         l_dpr.impairment_rsv := 0;

         -- Manual Override
         l_dpr.used_by_adjustment  := TRUE;
         l_dpr.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
         l_dpr.mrc_sob_type_code := p_mrc_sob_type_code;
         l_dpr.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
         l_dpr.update_override_status := TRUE;

         if p_running_mode = fa_std_types.FA_DPR_PROJECT then
            l_running_mode:= fa_std_types.FA_DPR_PROJECT;
         else
            l_running_mode:= fa_std_types.FA_DPR_NORMAL;
         end if;
         -- End of Manual Override

         -- this will not be called from projections
         -- so running mode is always running_mode:= fa_std_types.FA_DPR_NORMAL;
         l_dpr.cost := px_asset_fin_rec_new.cost;

         -- Japan Tax phase3 Start
         if (l_set_extend_flag) then

            px_asset_fin_rec_new.adjusted_cost := px_asset_fin_rec_new.cost - NVL(p_asset_deprn_rec.deprn_reserve,0) -
                                                  NVL(px_asset_fin_rec_new.allowed_deprn_limit_amount,0);
            X_deprn_exp       := 0;
            X_bonus_deprn_exp := 0;
            X_impairment_exp  := 0;

            if (px_asset_fin_rec_new.extended_depreciation_period < p_period_rec.period_counter) then

               l_dpr.adj_cost := px_asset_fin_rec_new.adjusted_cost ;

               if l_dpr.method_code = 'JP-STL-EXTND' then
                  if (l_start_per_num = 1) then
                     if l_dpr.y_end > l_dpr.y_begin + (l_dpr.life /l_pers_per_yr) - 1 then
                        l_dpr.y_end := l_dpr.y_begin + (l_dpr.life /l_pers_per_yr);
                        l_dpr.p_cl_end := l_start_per_num;
                     end if;
                  end if;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('faxexp', 'Japan Tax:1 Before 2nd faxcde l_dpr.y_begin', l_dpr.y_begin, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:2 Before 2nd faxcde l_dpr.y_end', l_dpr.y_end, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:3 Before 2nd faxcde l_dpr.p_cl_begin', l_dpr.p_cl_begin, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:4 Before 2nd faxcde l_dpr.p_cl_end', l_dpr.p_cl_end, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:5 Calling 2nd faxcde ', 'here', p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:1 Before 2nd faxcde px_asset_fin_rec_new.adjusted_cost',
                                   px_asset_fin_rec_new.adjusted_cost, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:2 Before 2nd faxcde p_asset_deprn_rec.deprn_reserve',
                                   p_asset_deprn_rec.deprn_reserve, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:3 Before 2nd faxcde px_asset_fin_rec_new.cost ',
                                   px_asset_fin_rec_new.cost, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:4 Before 2nd faxcde px_asset_fin_rec_new.allowed_deprn_limit_amount',
                                   px_asset_fin_rec_new.allowed_deprn_limit_amount, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:6 Before 2nd faxcde px_asset_fin_rec_new.adjusted_recoverable_cost ',
                                   px_asset_fin_rec_new.adjusted_recoverable_cost , p_log_level_rec);
               end if;

               IF NVL(px_trans_rec.calling_interface,'XXX') <> 'FAXASSET' OR
                  px_trans_rec.transaction_type_code <> 'ADDITION' OR
                  G_release = 12 THEN
                  if not fa_cde_pkg.faxcde(l_dpr,
                                           l_dummy_dpr_arr,
                                           l_dpr_out,
                                           fa_std_types.FA_DPR_NORMAL,
                                           p_log_level_rec => p_log_level_rec) then
                     fa_srvr_msg.add_message(calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
                     return (FALSE);
                  end if;
               END IF;

               X_deprn_exp := l_dpr_out.new_deprn_rsv;
               X_bonus_deprn_exp := l_dpr_out.new_bonus_deprn_rsv;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('faxexp', 'Japan Tax:6 After 2nd faxcde l_dpr_out.new_deprn_rsv', l_dpr_out.new_deprn_rsv, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:6 After 2nd faxcde l_dpr_out.deprn_exp', l_dpr_out.deprn_exp, p_log_level_rec);
               end if;

            end if;
         elsif (l_reset_extend_flag) then

            fa_debug_pkg.add('faxexp', 'Japan Tax:3 Adjustment logic', 'Reset extnded asset', p_log_level_rec);
            -- Bug 6624784 Reverse the catchup taken during extended depreciation.
            if p_period_rec.period_counter > p_asset_fin_rec_old.extended_depreciation_period then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('faxexp', 'Japan Tax:1 Before 2nd faxcde l_dpr.y_begin', l_dpr.y_begin, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:2 Before 2nd faxcde l_dpr.y_end', l_dpr.y_end, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:3 Before 2nd faxcde l_dpr.p_cl_begin', l_dpr.p_cl_begin, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:4 Before 2nd faxcde l_dpr.p_cl_end', l_dpr.p_cl_end, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:5 Calling 2nd faxcde ', 'here', p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:1 Before 2nd faxcde px_asset_fin_rec_new.adjusted_cost',
                                   px_asset_fin_rec_new.adjusted_cost, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:2 Before 2nd faxcde p_asset_deprn_rec.deprn_reserve',
                                   p_asset_deprn_rec.deprn_reserve, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:3 Before 2nd faxcde px_asset_fin_rec_new.cost ',
                                   px_asset_fin_rec_new.cost, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:4 Before 2nd faxcde px_asset_fin_rec_new.allowed_deprn_limit_amount',
                                   px_asset_fin_rec_new.allowed_deprn_limit_amount, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:6 Before 2nd faxcde px_asset_fin_rec_new.adjusted_recoverable_cost ',
                                   px_asset_fin_rec_new.adjusted_recoverable_cost , p_log_level_rec);
               end if;

               if not fa_cde_pkg.faxcde(l_dpr,
                                        l_dummy_dpr_arr,
                                        l_dpr_out,
                                        fa_std_types.FA_DPR_NORMAL,
                                        p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
                  return (FALSE);
               end if;

               X_deprn_exp := -1 * l_dpr_out.new_deprn_rsv;
               X_bonus_deprn_exp := -1 * l_dpr_out.new_bonus_deprn_rsv;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('faxexp', 'Japan Tax:6 After 2nd faxcde l_dpr_out.new_deprn_rsv', l_dpr_out.new_deprn_rsv, p_log_level_rec);
                  fa_debug_pkg.add('faxexp', 'Japan Tax:6 After 2nd faxcde l_dpr_out.deprn_exp', l_dpr_out.deprn_exp, p_log_level_rec);
               end if;
            end if;

            --bug8350248 Added the cursor to fetch the original adjusted cost
             OPEN c_extend_get_original_adjcost(p_asset_hdr_rec.asset_id, p_asset_hdr_rec.book_type_code);
             FETCH c_extend_get_original_adjcost INTO  l_adjusted_cost;
             CLOSE c_extend_get_original_adjcost;

             px_asset_fin_rec_new.adjusted_cost := l_adjusted_cost;
             -- Japan Tax phase3 End
         else
            -- this will not be called from projections
            -- so running mode is always running_mode:= fa_std_types.FA_DPR_NORMAL;
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('faxexp', 'Japan Tax1:1 Before 2nd faxcde l_dpr.y_begin', l_dpr.y_begin, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax2:2 Before 2nd faxcde l_dpr.y_end', l_dpr.y_end, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax3:3 Before 2nd faxcde l_dpr.p_cl_begin', l_dpr.p_cl_begin, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax4:4 Before 2nd faxcde l_dpr.p_cl_end', l_dpr.p_cl_end, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax5:5 Calling 2nd faxcde ', 'here', p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax6:1 Before 2nd faxcde px_asset_fin_rec_new.adjusted_cost',
                                px_asset_fin_rec_new.adjusted_cost, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax7:2 Before 2nd faxcde p_asset_deprn_rec.deprn_reserve',
                                p_asset_deprn_rec.deprn_reserve, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax8:3 Before 2nd faxcde px_asset_fin_rec_new.cost ',
                                px_asset_fin_rec_new.cost, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax9:4 Before 2nd faxcde px_asset_fin_rec_new.allowed_deprn_limit_amount',
                                px_asset_fin_rec_new.allowed_deprn_limit_amount, p_log_level_rec);
               fa_debug_pkg.add('faxexp', 'Japan Tax0:6 Before 2nd faxcde px_asset_fin_rec_new.adjusted_recoverable_cost ',
                                px_asset_fin_rec_new.adjusted_recoverable_cost , p_log_level_rec);
            end if;

            IF NVL(px_trans_rec.calling_interface,'XXX') <> 'FAXASSET' OR
               px_trans_rec.transaction_type_code <> 'ADDITION' or
               G_release = 12 THEN

               if not fa_cde_pkg.faxcde(l_dpr,
                                        l_dummy_dpr_arr,
                                        l_dpr_out,
                                        fa_std_types.FA_DPR_NORMAL,
                                        p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
                  return (FALSE);
               end if;
            END IF;

            X_deprn_exp := l_dpr_out.new_deprn_rsv - l_cur_deprn_rsv;

            -- R12 conditional handling
            if (G_release <> 11) then
               X_ann_adj_deprn_exp := l_dpr_out.ann_adj_exp;
            end if;

            -- pass eofy_reserve to CALL_DEPRN_BASIS
            px_asset_fin_rec_new.eofy_reserve := l_dpr_out.new_eofy_reserve;

            -- bonus: new_bonus_deprn_rsv added to dpr_out_struct.
            -- Investigate dpr.bonus_deprn_rsv if value is correct.==> YES!
            -- Now new_bonus_deprn_rsv needs to be correctly calculated in faxcde.
            -- Bug no 4962663
            -- Adding an nvl for l_cur_bonus_deprn_rsv
            if nvl(px_asset_fin_rec_new.bonus_rule, 'NONE') <> 'NONE' then
               X_bonus_deprn_exp := l_dpr_out.new_bonus_deprn_rsv - nvl(l_cur_bonus_deprn_rsv,0);
            else
               X_bonus_deprn_exp := 0;
            end if;

            -- R12 conditional handling
            if (G_release <> 11) then
               X_ann_adj_bonus_deprn_exp := 0;
            end if;

            X_impairment_exp := l_dpr_out.new_impairment_rsv - l_cur_impairment_rsv;

            -- Manual Override
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add ('faxexp', 'deprn_override_flag', l_dpr_out.deprn_override_flag, p_log_level_rec);
            end if;

            -- pass override_flag to faxiat
            px_trans_rec.deprn_override_flag:= l_dpr_out.deprn_override_flag;

         end if;
      else
         X_deprn_exp       := 0;
         X_bonus_deprn_exp := 0;
         X_impairment_exp  := 0;

         if (G_release <> 11) then
            X_ann_adj_deprn_exp       := 0;
            X_ann_adj_bonus_deprn_exp := 0;
         end if;
      end if;
   end if;

   -- NOTE
   --
   -- This is incorrect; the annualized adjustment for this should not
   -- be zero.  The correct way to calculate this would be to
   -- recalculate deprn under the old conditions, and determine what the
   -- annualized deprn amount is for the current fiscal year.  Then
   -- compare that with the recalculation of deprn under the new
   -- conditions.  The difference is the annualized adjustment amount.
   -- In order to calculate this, we would need a snapshot of the asset
   -- before the transaction.  Since this requires a significant change
   -- to the fin_info_struct structure, we will defer the fix until a
   -- later release.  The impact of this is that if the user executes an
   -- expensed change, and then a prior-period transfer or retirement
   -- whose effective date is before the current date, the depreciation
   -- expense transferred will not include any amount relevant to the
   -- expensed change.  -Dave
   --
   -- this is handled in faxiat now

   if (not FA_CACHE_PKG.fazccmt(px_asset_fin_rec_new.deprn_method_code,
                                px_asset_fin_rec_new.life_in_months,
                                p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   l_rate_source_rule      := fa_cache_pkg.fazccmt_record.rate_source_rule;
   l_deprn_basis_rule      := fa_cache_pkg.fazccmt_record.deprn_basis_rule;


   -- Added for the Depreciable Basis Formula.
   l_cur_fy      := fa_cache_pkg.fazcbc_record.current_fiscal_year;
   l_cur_per_num := mod(p_period_rec.period_counter,l_cur_fy);


   ----------------------------------------------
   -- Call Depreciable Basis Rule
   -- for Expensed Adjustment
   ----------------------------------------------
   if (l_cur_per_num = 1) then
     l_hyp_total_ytd  := 0;
   else
     -- Bug3213016:
     -- Use l_dpr_out.new_ytd_deprn for new ytd_deprn instead of
     --  l_dpr_out.new_deprn_rsv - (l_dpr_out.new_prior_fy_exp - l_dpr.prior_fy_exp)
     --
     l_hyp_total_ytd := l_dpr_out.new_ytd_deprn;
   end if;

   -- Japan Tax Phase3 call CALL_DEPRN_BASIS only if
   if (not (l_set_extend_flag or l_reset_extend_flag)) then
   --Bug 9110995 FP Bug 8571102
   --We  need to ensure we force the deprn basis for flat/nbv/non_strict_flat
   --to behave like strict_flat during catchup.
   --So, we subtract l_hyp_total_ytd from l_hyp_total_rsv/l_hyp_rsv
   --To force the right basis reset during catchup.
   --
      l_hyp_total_rsv   := nvl(l_dpr_out.new_deprn_rsv,0);
      l_hyp_rsv         := nvl(l_dpr_out.new_deprn_rsv,0) - nvl(l_dpr_out.new_bonus_deprn_rsv,0);
      l_hyp_total_ytd   := nvl(l_hyp_total_ytd,0);
      if p_asset_hdr_rec.period_of_addition = 'Y' AND
         px_trans_rec.transaction_type_code = 'ADDITION' AND
         fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'NBV' AND
         fa_cache_pkg.fazccmt_record.rate_source_rule = 'FLAT' AND
         nvl(fa_cache_pkg.fazccmt_record.deprn_basis_formula,'X') <> 'STRICT_FLAT' then

             -- During catchup we force normal flat mode to strict flat mode
             l_hyp_total_rsv := l_hyp_total_rsv - l_hyp_total_ytd;
             l_hyp_rsv       := l_hyp_rsv       - l_hyp_total_ytd;
      end if;

      if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS (
                        p_event_type             => 'EXPENSED_ADJ',
                        p_asset_fin_rec_new      => px_asset_fin_rec_new,
                        p_asset_fin_rec_old      => p_asset_fin_rec_old,
                        p_asset_hdr_rec          => p_asset_hdr_rec,
                        p_asset_type_rec         => p_asset_type_rec,
                        p_asset_deprn_rec        => p_asset_deprn_rec,
                        p_trans_rec              => px_trans_rec,
                        p_period_rec             => p_period_rec,
                        p_recoverable_cost       => l_dpr.rec_cost,
                        p_current_total_rsv      => l_cur_deprn_rsv,
                        p_current_total_ytd      => l_dpr.ytd_deprn,
                        p_hyp_basis              => l_dpr_out.new_adj_cost,
                        p_hyp_total_rsv          => l_hyp_total_rsv,  --bug 9110995 FP bug 8571102
                        p_hyp_rsv                => l_hyp_rsv,        --bug 9110995 FP bug 8571102
                        p_hyp_total_ytd          => l_hyp_total_ytd,  --bug 9110995 FP bug 8571102
                        p_mrc_sob_type_code      => p_mrc_sob_type_code,
                        px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                        px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                        px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                        p_log_level_rec          => p_log_level_rec)) then
         fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
         return false;
      end if;
   end if;

   -- Bug 8726493 overridding the value of adjusted cost in case
   --   an asset is added with JP-250DB method and backdated DPIS
   --   and without reserve
   if px_trans_rec.transaction_type_code = 'ADDITION' and
      l_dpr.method_code like 'JP-250DB%' then
      px_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
   end if;

   return(TRUE);

exception
   when others then
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
end FAXEXP;

END FA_EXP_PVT;

/
