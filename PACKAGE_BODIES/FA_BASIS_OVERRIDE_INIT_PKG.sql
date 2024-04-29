--------------------------------------------------------
--  DDL for Package Body FA_BASIS_OVERRIDE_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_BASIS_OVERRIDE_INIT_PKG" as
/* $Header: FADBOIB.pls 120.19.12010000.4 2009/09/29 04:07:45 tkawamur ship $ */

g_fy fa_deprn_periods.fiscal_year%TYPE;
g_p_num fa_deprn_periods.period_num%TYPE;
g_p_counter fa_deprn_periods.period_counter%TYPE;
g_book fa_deprn_periods.book_type_code%TYPE;

g_log_level_rec fa_api_types.log_level_rec_type;

FUNCTION facodda(book                     in            varchar2,
                 used_by_adjustment       in            number,
                 asset_id                 in            number,
                 bonus_rule               in            varchar2,
                 fyctr                    in            number,
                 perd_ctr                 in            number,
                 prod_rate_src_flag       in            number,
                 deprn_projecting_flag    in            number,
                 p_ytd_deprn              in            NUMBER,
                 p_bonus_ytd_deprn        in            NUMBER,
                 override_depr_amt           out nocopy number,
                 override_bonus_amt          out nocopy number,
                 deprn_override_flag         out nocopy varchar2,
                 return_code                 out nocopy number,
                 p_mrc_sob_type_code      in            VARCHAR2,
                 p_set_of_books_id        in            NUMBER,
                 p_over_depreciate_option in            NUMBER   default null,
                 p_asset_type             in            VARCHAR2 default null,
                 p_deprn_rsv              in            NUMBER   default null,
                 p_cur_adj_cost           in            NUMBER   DEFAULT NULL
                ) return number is

   h_used_by_adjustment_bool      boolean;
   h_deprn_projecting_flag_bool   boolean;
   h_prod_rate_src_flag_bool      boolean;

   l_calling_fn   varchar2(40) := 'fa_basis_override_init_pkg.facodda';
   facodda_err    EXCEPTION;

begin <<FACODDA>>

  -- This is just cover process to call the function FAODDA on FA_CDE_PKG

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec ( x_log_level_rec =>  g_log_level_rec)) then
         raise facodda_err;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('facodda','Just Start the cover program','', p_log_level_rec => g_log_level_rec);
   end if;

   if used_by_adjustment = 1 then
      h_used_by_adjustment_bool := TRUE;
   else
      h_used_by_adjustment_bool := FALSE;
   end if;

   if deprn_projecting_flag = 1 then
      h_deprn_projecting_flag_bool := TRUE;
   else
      h_deprn_projecting_flag_bool := FALSE;
   end if;

   if prod_rate_src_flag = 1 then
      h_prod_rate_src_flag_bool := TRUE;
   else
      h_prod_rate_src_flag_bool := FALSE;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('facodda','Just Call the main program','faodda', p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','book',book, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','used_by_adjustment',used_by_adjustment, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','asset_id',asset_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','bonus_rule',bonus_rule, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','fyctr',fyctr, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','perd_ctr',perd_ctr, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','prod_rate_src_flag',prod_rate_src_flag, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','deprn_projecting_flag',deprn_projecting_flag, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','p_ytd_deprn', p_ytd_deprn, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','p_bonus_ytd_deprn', p_bonus_ytd_deprn, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','override_depr_amt',override_depr_amt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','override_bonus_amt',override_bonus_amt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','deprn_override_flag',deprn_override_flag, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','return_code',return_code, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','p_mrc_sob_type_code',p_mrc_sob_type_code, p_log_level_rec => g_log_level_rec);
   end if;

   if not FA_CDE_PKG.faodda(book                     => book,
                            used_by_adjustment       => h_used_by_adjustment_bool,
                            asset_id                 => asset_id,
                            bonus_rule               => bonus_rule,
                            fyctr                    => fyctr,
                            perd_ctr                 => perd_ctr,
                            prod_rate_src_flag       => h_prod_rate_src_flag_bool,
                            deprn_projecting_flag    => h_deprn_projecting_flag_bool,
                            p_ytd_deprn              => p_ytd_deprn,
                            p_bonus_ytd_deprn        => p_bonus_ytd_deprn,
                            override_depr_amt        => override_depr_amt,
                            override_bonus_amt       => override_bonus_amt,
                            deprn_override_flag      => deprn_override_flag,
                            return_code              => return_code,
                            p_mrc_sob_type_code      => p_mrc_sob_type_code,
                            p_set_of_books_id        => p_set_of_books_id,
                            p_over_depreciate_option => p_over_depreciate_option,
			    p_asset_type             => p_asset_type,
			    p_deprn_rsv              => p_deprn_rsv,
			    p_cur_adj_cost           => p_cur_adj_cost,
                            p_log_level_rec          => g_log_level_rec) then
      raise facodda_err;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('facodda','deprn_projecting_flag',deprn_projecting_flag, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','override_depr_amt',override_depr_amt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','override_bonus_amt',override_bonus_amt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','deprn_override_flag',deprn_override_flag, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('facodda','return_code',return_code, p_log_level_rec => g_log_level_rec);
   end if;

   return 0;

exception
   WHEN facodda_err THEN
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      return 1;

   when others then
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      return 1;

end FACODDA;

/* Function to call faxcdb */
FUNCTION faxccdb (event_type in varchar2,
                 asset_id in number default 0,
                 group_asset_id in number default 0,
                 book_type_code in varchar2 default null,
                 asset_type in varchar2 default null,
                 depreciate_flag in varchar2 default null,
                 method_code in varchar2 default null,
                 life_in_months in number default 0,
                 method_id in number default 0,
                 method_type in varchar2 default null,
                 calc_basis in varchar2 default null,
                 adjustment_amount in number default 0,
                 transaction_flag in varchar2 default null,
                 cost in number default 0,
                 salvage_value in number default 0,
                 recoverable_cost in number default 0,
                 adjusted_cost in number default 0,
                 current_total_rsv in number default 0,
                 current_rsv in number default 0,
                 current_total_ytd in number default 0,
                 current_ytd in number default 0,
                 hyp_basis in number default 0,
                 hyp_total_rsv in number default 0,
                 hyp_rsv in number default 0,
                 hyp_total_ytd in number default 0,
                 hyp_ytd in number default 0,
                 old_adjusted_cost in number default 0,
                 old_raf in number default 0,
                 old_formula_factor in number default 0,
                 new_adjusted_cost out NOCOPY number,
                 new_raf out NOCOPY number,
                 new_formula_factor out NOCOPY number,
                 -- new parameter for group depreciation
                 p_period_counter in number default null,  -- period num
                 p_fiscal_year in number default null,
                 p_eofy_reserve in number default null,
                 p_tracking_method in varchar2 default null,
                 p_allocate_to_fully_rsv_flag in varchar2 default null,
                 p_allocate_to_fully_ret_flag in varchar2 default null,
                 p_depreciation_option in varchar2 default null,
                 p_member_rollup_flag in varchar2 default null,
                 p_eofy_recoverable_cost in number default null,
                 p_eop_recoverable_cost in number default null,
                 p_eofy_salvage_value in number default null,
                 p_eop_salvage_value in number default null,
                 p_used_by_adjustment in number default null,
                 p_eofy_flag in varchar2  default null,
                 -- new parameter for polish enhancement
                 p_polish_rule in number default
                    FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                 p_deprn_factor in number default null,
                 p_alternate_deprn_factor in number default null,
                 p_impairment_reserve number default 0, -- P2IAS36
                 p_mrc_sob_type_code in varchar2 default 'N',
                 p_set_of_books_id in number
                 --
                 ) return number is

  h_rule_in           fa_std_types.fa_deprn_rule_in_struct;
  h_rule_out          fa_std_types.fa_deprn_rule_out_struct;

  -- Added for group depreciation
  Cursor C_PERIOD_COUNTER (
                           l_book_type_code  varchar2,
                           l_fiscal_year     number,
                           l_period_number   number)
  is
    select dp.period_counter
    from   FA_DEPRN_PERIODS dp
    where  dp.book_type_code = l_book_type_code
    and    dp.fiscal_year = l_fiscal_year
    and    dp.period_num = l_period_number;

  Cursor C_PERIOD_COUNTER_MRC (
                           l_book_type_code  varchar2,
                           l_fiscal_year     number,
                           l_period_number   number)
  is
    select dp.period_counter
    from   FA_MC_DEPRN_PERIODS dp
    where  dp.book_type_code = l_book_type_code
    and    dp.fiscal_year = l_fiscal_year
    and    dp.period_num = l_period_number
    and    dp.set_of_books_id = p_set_of_books_id;

  Cursor C_METHOD_CODE (
                        l_asset_id        number,
                        l_book_type_code  varchar2)
  is
    select bk.deprn_method_code,
           bk.life_in_months
    from   FA_BOOKS bk
    where  bk.asset_id = l_asset_id
    and    bk.book_type_code = l_book_type_code
    and    bk.date_ineffective is null;

  Cursor C_METHOD_CODE_MRC (
                        l_asset_id        number,
                        l_book_type_code  varchar2)
  is
    select bk.deprn_method_code,
           bk.life_in_months
    from   FA_MC_BOOKS bk
    where  bk.asset_id = l_asset_id
    and    bk.book_type_code = l_book_type_code
    and    bk.date_ineffective is null
    and    bk.set_of_books_id = p_set_of_books_id;

  h_eofy_recoverable_cost  NUMBER;
  h_eop_recoverable_cost   NUMBER;
  h_eofy_salvage_value     NUMBER;
  h_eop_salvage_value      NUMBER;
  h_used_by_adjustment     VARCHAR2(15);
  h_eofy_flag              VARCHAR2(1);

  l_chk_count              NUMBER;
  l_calling_fn             varchar2(40) := 'fa_basis_override_init_pkg.faxccdb';
  faxccdb_err              exception;

BEGIN <<FAXCCDB>>

  -- fa_debug_pkg.initialize; -- removed to not clear the message stack.

  -- This is just cover process to call the function
  -- of faxcdb on FA_CALC_DEPRN_BASIS1_PKG

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise faxccdb_err;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('faxccdb','Just Start the cover program','', p_log_level_rec => g_log_level_rec);
   end if;

  -- Set default amount to out parameters
  new_adjusted_cost := nvl(old_adjusted_cost,0);
  new_raf := nvl(old_raf,1);
  new_formula_factor := nvl(new_formula_factor,1);

  /* set h_rule_in paremters */

  h_rule_in.event_type := event_type;
  h_rule_in.asset_id := asset_id;
  if group_asset_id = 0 then
    h_rule_in.group_asset_id := null;
  else
    h_rule_in.group_asset_id := group_asset_id;
  end if;
  h_rule_in.book_type_code := book_type_code;
  h_rule_in.asset_type := asset_type;
  h_rule_in.depreciate_flag := depreciate_flag;
  h_rule_in.method_code := method_code;
  h_rule_in.life_in_months := life_in_months;
  h_rule_in.method_id := method_id;
  h_rule_in.method_type := method_type;
  h_rule_in.calc_basis := calc_basis;
  h_rule_in.adjustment_amount := adjustment_amount;
  h_rule_in.transaction_flag := transaction_flag;
  h_rule_in.cost := cost;
  h_rule_in.salvage_value := salvage_value;
  h_rule_in.recoverable_cost := recoverable_cost;
  h_rule_in.adjusted_cost := adjusted_cost;
  h_rule_in.current_total_rsv := current_total_rsv;
  h_rule_in.current_rsv := current_rsv;
  h_rule_in.current_total_ytd := current_total_ytd;
  h_rule_in.current_ytd := current_ytd;
  h_rule_in.hyp_basis := hyp_basis;
  h_rule_in.hyp_total_rsv := hyp_total_rsv;
  h_rule_in.hyp_rsv := hyp_rsv;
  h_rule_in.hyp_total_ytd := hyp_total_ytd;
  h_rule_in.hyp_ytd := hyp_ytd;
  h_rule_in.old_adjusted_cost := old_adjusted_cost;
  h_rule_in.old_raf := old_raf;
  h_rule_in.old_formula_factor := old_formula_factor;

  -- Added for Group depreciation
  h_rule_in.fiscal_year := p_fiscal_year;
  h_rule_in.period_num  := p_period_counter;

  -- Added for Polish Tax depreciation
  h_rule_in.polish_rule := p_polish_rule;
  h_rule_in.deprn_factor := p_deprn_factor;
  h_rule_in.alternate_deprn_factor := p_alternate_deprn_factor;

  if event_type = 'AFTER_DEPRN' then
    if p_mrc_sob_type_code <>'R' then
      if g_book = book_type_code and
         nvl(g_fy, -99) = p_fiscal_year and
         nvl(g_p_num, -99) = p_period_counter then
         h_rule_in.period_counter:= g_p_counter;
      else
         OPEN C_PERIOD_COUNTER(book_type_code,p_fiscal_year,p_period_counter);
         FETCH C_PERIOD_COUNTER into h_rule_in.period_counter;
         CLOSE C_PERIOD_COUNTER;

         g_book:= book_type_code;
         g_fy:= p_fiscal_year;
         g_p_num:= p_period_counter;
         g_p_counter:= h_rule_in.period_counter;
      end if;
    else
      if g_book = book_type_code and
         nvl(g_fy, -99) = p_fiscal_year and
         nvl(g_p_num, -99) = p_period_counter then
         h_rule_in.period_counter:= g_p_counter;
      else
         OPEN C_PERIOD_COUNTER_MRC(book_type_code,p_fiscal_year,p_period_counter);
         FETCH C_PERIOD_COUNTER_MRC into h_rule_in.period_counter;
         CLOSE C_PERIOD_COUNTER_MRC;

         g_book:= book_type_code;
         g_fy:= p_fiscal_year;
         g_p_num:= p_period_counter;
         g_p_counter:= h_rule_in.period_counter;
      end if;
    end if;
  else
    h_rule_in.period_counter := p_period_counter;
  end if;

  h_rule_in.eofy_reserve := p_eofy_reserve;
  h_rule_in.tracking_method := p_tracking_method;
  h_rule_in.allocate_to_fully_rsv_flag := p_allocate_to_fully_rsv_flag;
  h_rule_in.allocate_to_fully_ret_flag := p_allocate_to_fully_ret_flag;
  h_rule_in.depreciation_option := p_depreciation_option;
  h_rule_in.member_rollup_flag := p_member_rollup_flag;
  h_rule_in.eofy_recoverable_cost := p_eofy_recoverable_cost;
  h_rule_in.eop_recoverable_cost := p_eop_recoverable_cost;
  h_rule_in.eofy_salvage_value := p_eofy_salvage_value;
  h_rule_in.eop_salvage_value := p_eop_salvage_value;
  h_rule_in.used_by_adjustment := p_used_by_adjustment;
  h_rule_in.eofy_flag := p_eofy_flag;
  h_rule_in.mrc_sob_type_code := nvl(p_mrc_sob_type_code,'N');
  h_rule_in.set_of_books_id := p_set_of_books_id;

  -- Check method_code

  if (g_log_level_rec.statement_level) then
    fa_debug_pkg.add('faxccdb','h_rule_in.method_code(1)',h_rule_in.method_code);
    fa_debug_pkg.add('faxccdb','h_rule_in.life_in_months(1)',h_rule_in.life_in_months);
  end if;

--  select count(1)
--  into   l_chk_count
--  from   FA_METHODS MT
--  where  mt.method_code = h_rule_in.method_code
--  and    nvl(mt.life_in_months,0) = nvl(h_rule_in.life_in_months,0);

   -- When l_chk_count is 0, get method_code and life_in_months
--  if l_chk_count =0 then
--    if p_mrc_sob_type_code <>'R' then
--      OPEN  C_METHOD_CODE (asset_id, book_type_code);
--      FETCH C_METHOD_CODE into h_rule_in.method_code,
--                               h_rule_in.life_in_months;
--      CLOSE C_METHOD_CODE;
--    else --MRC
--      OPEN  C_METHOD_CODE_MRC (asset_id, book_type_code);
--      FETCH C_METHOD_CODE_MRC into h_rule_in.method_code,
--                                   h_rule_in.life_in_months;
--      CLOSE C_METHOD_CODE_MRC;
--    end if;
--  end if;

  if (g_log_level_rec.statement_level) then
    fa_debug_pkg.add('faxccdb','h_rule_in.method_code(2)',h_rule_in.method_code);
    fa_debug_pkg.add('faxccdb','h_rule_in.life_in_months(2)',h_rule_in.life_in_months);
    fa_debug_pkg.add('faxccdb','method_type',method_type, p_log_level_rec => g_log_level_rec);
    fa_debug_pkg.add('faxccdb','calc_basis',calc_basis, p_log_level_rec => g_log_level_rec);
  end if;

  -- Get rate_source_rule and deprn_basis_rule
  -- to avoid that method_type and calc_basis are set null
  if method_type is null or calc_basis is null then

    if not fa_cache_pkg.fazccmt
          (X_method                => h_rule_in.method_code,
           X_life                  => h_rule_in.life_in_months
          , p_log_level_rec => g_log_level_rec) then

      raise faxccdb_err;

    end if;

     h_rule_in.method_id   := fa_cache_pkg.fazccmt_record.method_id;
     h_rule_in.method_type := fa_cache_pkg.fazccmt_record.rate_source_rule;
     h_rule_in.calc_basis  := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

     if (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id is not null) then
        h_rule_in.polish_rule := fa_cache_pkg.fazcdbr_record.polish_rule;
     end if;

     -- We don't want to use this logic for Polish code.
     if (h_rule_in.polish_rule is not null) and
        (h_rule_in.polish_rule <> FA_STD_TYPES.FAD_DBR_POLISH_NONE) then
        return 0;
     end if;
  end if;

  --
  -- eofy and eop amounts are necessary only if deprn basis rules are following
  --   need eop amounts: 'PERIOD END AVERAGE', 'BEGINNING PERIOD'
  --   need eofy amounts: 'YEAR TO DATE AVERAGE', 'YEAR END BALANCE WITH HALF YEAR RULE'
  --
  if (fa_cache_pkg.fazcdbr_record.rule_name in ('PERIOD END AVERAGE', 'BEGINNING PERIOD',
                                                'YEAR TO DATE AVERAGE',
                                                'YEAR END BALANCE WITH HALF YEAR RULE')) then
     ---------------------------------------------
     -- Get end of fiscal year
     -- and end of period recoverable cost
     -- and salvage value
     ---------------------------------------------
     -- Get eofy recoverable cost and salvage value
     if    p_eofy_recoverable_cost is null
        or p_eofy_salvage_value is null
        or p_eop_recoverable_cost is null
        or p_eop_salvage_value is null
     then

       if (not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
                (
                 p_asset_id              => h_rule_in.asset_id,
                 p_book_type_code        => h_rule_in.book_type_code,
                 p_fiscal_year           => h_rule_in.fiscal_year,
                 p_period_num            => h_rule_in.period_num,
                 p_asset_type            => h_rule_in.asset_type,
                 p_recoverable_cost      => h_rule_in.recoverable_cost,
                 p_salvage_value         => h_rule_in.salvage_value,
                 p_period_counter        => p_period_counter,
                 p_mrc_sob_type_code     => h_rule_in.mrc_sob_type_code,
                 p_set_of_books_id       => h_rule_in.set_of_books_id,
                 x_eofy_recoverable_cost => h_rule_in.eofy_recoverable_cost,
                 x_eofy_salvage_value    => h_rule_in.eofy_salvage_value,
                 x_eop_recoverable_cost  => h_rule_in.eop_recoverable_cost,
                 x_eop_salvage_value     => h_rule_in.eop_salvage_value
                , p_log_level_rec => g_log_level_rec))
       then
         h_rule_in.eofy_recoverable_cost := nvl(p_eofy_recoverable_cost,0);
         h_rule_in.eofy_salvage_value    := nvl(p_eofy_salvage_value,0);
         h_rule_in.eop_recoverable_cost  := nvl(p_eop_recoverable_cost,0);
         h_rule_in.eop_salvage_value     := nvl(p_eop_salvage_value,0);
       end if;
     end if; -- End of getting eofy and eop recoverable cost and salvage value

  else
      h_rule_in.eofy_recoverable_cost := 0;
      h_rule_in.eofy_salvage_value    := 0;
      h_rule_in.eop_recoverable_cost  := 0;
      h_rule_in.eop_salvage_value     := 0;
  end if; -- (fa_cache_pkg.fazcdbr_record.rule_name in (....

  --------------------------------------------
  -- Set 0 to the end of fiscal year
  -- and end of period recoverable cost
  -- and salvage value if they returned 0
  --------------------------------------------
  h_rule_in.eofy_recoverable_cost := nvl(h_rule_in.eofy_recoverable_cost,0);
  h_rule_in.eofy_salvage_value    := nvl(h_rule_in.eofy_salvage_value,0);
  h_rule_in.eop_recoverable_cost  := nvl(h_rule_in.eop_recoverable_cost,0);
  h_rule_in.eop_salvage_value     := nvl(h_rule_in.eop_salvage_value,0);

  h_rule_in.impairment_reserve    := p_impairment_reserve; -- P2IAS36

  -- Initialize output parameters

  h_rule_out.new_adjusted_cost := 0;
  h_rule_out.new_raf := 1;
  h_rule_out.new_formula_factor := 1;

  ------------------------------------------------------
  -- Performance Improvement:
  -- If method_type is FLAT, set null to life_in_months
  -- to reduce the loop on fazccmt which faxcdb calls
  ------------------------------------------------------
  if h_rule_in.method_type = 'FLAT' then
    h_rule_in.life_in_months := null;
  end if;

  --------------------------------------------------
  -- Call Depreciable Basis Formula PL/SQL function
  --------------------------------------------------

  if not FA_CALC_DEPRN_BASIS1_PKG.faxcdb
                     (
                      rule_in     => h_rule_in,
                      rule_out    => h_rule_out
                     , p_log_level_rec => g_log_level_rec)
            then

              raise faxccdb_err;

            END IF;

             /* set rule_out parameters */
            new_adjusted_cost := h_rule_out.new_adjusted_cost;
            new_raf := h_rule_out.new_raf;
            new_formula_factor := h_rule_out.new_formula_factor;

            return 0;

exception
  when faxccdb_err then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
    return 1;

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
    return 1;

end faxccdb;


FUNCTION faoddat(deprn_override_trigger in number
                ) return number is
             h_deprn_override_trigger  boolean;

             l_calling_fn  varchar2(40) := 'fa_basis_override_init_pkg.faoddat';

begin <<FAODDAT>>

   -- fa_debug_pkg.initialize; -- removed to not clear the message stack.

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         null;
      end if;
   end if;

   if deprn_override_trigger = 1 then
      h_deprn_override_trigger := TRUE;
   else
      h_deprn_override_trigger := FALSE;
   end if;

   fa_std_types.deprn_override_trigger_enabled:= h_deprn_override_trigger;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('faoddat','faoddat: deprn_override_trigger_enabled', fa_std_types.deprn_override_trigger_enabled, p_log_level_rec => g_log_level_rec);
   end if;

   return 0;

exception
  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
    return 1;

end faoddat;
END FA_BASIS_OVERRIDE_INIT_PKG;


/
