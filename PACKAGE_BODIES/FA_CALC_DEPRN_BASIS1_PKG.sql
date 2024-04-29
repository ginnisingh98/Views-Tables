--------------------------------------------------------
--  DDL for Package Body FA_CALC_DEPRN_BASIS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CALC_DEPRN_BASIS1_PKG" as
 /* $Header: faxcdb1b.pls 120.67.12010000.17 2010/06/08 13:11:07 deemitta ship $ */
-- global variables
g_book_type_code   fa_deprn_periods.book_type_code%TYPE;
g_fiscal_year1     fa_fiscal_year.fiscal_year%TYPE;
g_fiscal_year2     fa_fiscal_year.fiscal_year%TYPE;
g_period_num1      fa_calendar_periods.period_num%TYPE;
g_period_num2      fa_calendar_periods.period_num%TYPE;
g_end_date1        fa_calendar_periods.end_date%TYPE;
g_end_date2        fa_calendar_periods.end_date%TYPE;
g_num_per_fy       fa_calendar_types.number_per_fiscal_year%TYPE;
g_switched_whatif  NUMBER :=0;  --- BUG # 7193797 : Added to calculate the global Count
g_switched_recal   NUMBER :=0;  ---Bug 8639499
g_switched_add     NUMBER :=0;  --bug 8726493
g_old_asset_id NUMBER := -1;

FUNCTION faxcdb(
                rule_in                    IN  fa_std_types.fa_deprn_rule_in_struct,
                rule_out                   OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct,
                p_amortization_start_date  IN  date
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

   rule_id number(15)            DEFAULT NULL;
   l_rule_name varchar2(80)      DEFAULT NULL;
   l_rule_formula varchar2(2000) DEFAULT NULL;

   -- For Event Type: DEPRECIATE_FLAG_ADJ
   l_last_trx_count NUMBER :=0;
   l_book_type_code VARCHAR2(30) DEFAULT NULL;
   l_asset_id NUMBER DEFAULT NULL;

   -- Added for group depreciation
   l_period_update_flag   VARCHAR2(1) DEFAULT NULL;
   l_apply_reduction_flag VARCHAR2(1) DEFAULT NULL;
   l_subtract_ytd_flag    VARCHAR2(1) DEFAULT NULL;

   -- Proceeds
   l_ltd_proceeds         NUMBER := 0;
   l_ytd_proceeds         NUMBER := 0;

   -- Retired cost
   l_retired_cost         NUMBER := 0;
   l_adj_reserve          NUMBER := 0;

   -- For Event type: INITIAL_ADDITION
   l_amort_fiscal_year    NUMBER :=0;
   l_amort_period_num     NUMBER :=0;
   l_amort_period_counter NUMBER :=0;
   l_amort_salvage_value  NUMBER :=0;

   -- For reduction rate
   l_member_reduction_rate   NUMBER := null;
   l_member_transaction_flag VARCHAR2(1) := null;
   l_recognize_gain_loss  varchar2(3);

   l_deprn_amt   number :=0; --bug#6658280

   l_calling_fn         varchar2(35) := 'fa_calc_deprn_basis1_pkg.faxcdb';
   l_original_Rate      number;
   l_Revised_Rate       number;
   l_Guaranteed_Rate    number;
   l_request_short_name VARCHAR2(100);  --- BUG # 7193797 : Added to store the Concurrent Program Short Name
   l_nbv_at_switch      NUMBER;
   l_cur_rate_used      NUMBER :=0;  --Bug 7515920
   l_fbk_exist          VARCHAR2(1) := 'Y'; --- Bug 8834613 need to check if data exist for asset in fa_books

   -- IAS36
   CURSOR c_get_rsv_at_imp is
      select itf.deprn_reserve
           , nvl(itf.impairment_reserve,0)
           , itf.period_counter
      from   fa_itf_impairments itf
           , fa_impairments imp
      where imp.impairment_id = itf.impairment_id
      and   imp.status = 'POSTED'
      and   itf.asset_id = rule_in.asset_id
      and   itf.book_type_code = rule_in.book_type_code
      and   itf.period_counter <= rule_in.period_counter
      order by period_counter desc;

   CURSOR c_get_mc_rsv_at_imp is
      select itf.deprn_reserve
           , nvl(itf.impairment_reserve,0)
           , itf.period_counter
      from   fa_mc_itf_impairments itf
           , fa_mc_impairments imp
      where imp.impairment_id = itf.impairment_id
      and   imp.status = 'POSTED'
      and   imp.set_of_books_id = rule_in.set_of_books_id
      and   itf.asset_id = rule_in.asset_id
      and   itf.book_type_code = rule_in.book_type_code
      and   itf.period_counter <= rule_in.period_counter
      and   itf.set_of_books_id = rule_in.set_of_books_id
      order by period_counter desc;

   l_impairment_reserve   number;
   l_deprn_reserve_at_imp number;
   l_imp_period_counter   number;
   l_imp_fiscal_year      number;
   l_rate_in_use          NUMBER;  -- Bug:5930979:Japan Tax Reform Project
   l_old_method_code      VARCHAR2(12);  -- Bug 6345693
   l_old_salvage_value    NUMBER;   -- Bug 6378955
   l_old_cost             NUMBER;  -- Japan overlapped

   faxcdb_err     exception;
   calc_basis_err exception;
begin

   ------------------------------------------------------------
   -- Debug input parameters
   ------------------------------------------------------------
   if p_log_level_rec.statement_level then
      fa_debug_pkg.add('faxcdb', 'rule_in.event_type', rule_in.event_type, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.asset_id', rule_in.asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.group_asset_id', rule_in.group_asset_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.book_type_code', rule_in.book_type_code, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.asset_type', rule_in.asset_type, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.depreciate_flag', rule_in.depreciate_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.method_code', rule_in.method_code, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.life_in_months', rule_in.life_in_months, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.method_id', rule_in.method_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.method_type', rule_in.method_type, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.calc_basis', rule_in.calc_basis, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.adjustment_amount', rule_in.adjustment_amount, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.transaction_flag', rule_in.transaction_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.cost', rule_in.cost, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.salvage_value', rule_in.salvage_value, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.recoverable_cost', rule_in.recoverable_cost, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.adjusted_cost', rule_in.adjusted_cost, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.current_total_rsv', rule_in.current_total_rsv, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.current_rsv', rule_in.current_rsv, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.current_total_ytd', rule_in.current_total_ytd, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.current_ytd', rule_in.current_ytd, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.hyp_basis', rule_in.hyp_basis, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.hyp_total_rsv', rule_in.hyp_total_rsv, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.hyp_rsv', rule_in.hyp_rsv, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.hyp_total_ytd', rule_in.hyp_total_ytd, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.hyp_ytd', rule_in.hyp_ytd, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.old_adjusted_cost', rule_in.old_adjusted_cost, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.old_raf', rule_in.old_raf, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.old_formula_factor', rule_in.old_formula_factor, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.amortization_start_date', rule_in.amortization_start_date, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.transaction_header_id', rule_in.transaction_header_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.member_transaction_header_id', rule_in.member_transaction_header_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.transaction_date_entered', rule_in.transaction_date_entered, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.adj_transaction_header_id', rule_in.adj_transaction_header_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.adj_mem_transaction_header_id', rule_in.adj_mem_transaction_header_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.adj_transaction_date_entered', rule_in.adj_transaction_date_entered, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.fiscal_year', rule_in.fiscal_year, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.period_num', rule_in.period_num, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.period_counter', rule_in.period_counter, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.proceeds_of_sale', rule_in.proceeds_of_sale, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.cost_of_removal', rule_in.cost_of_removal, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.nbv_retired', rule_in.nbv_retired, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.reduction_rate', rule_in.reduction_rate, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.eofy_reserve', rule_in.eofy_reserve, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.adj_reserve', rule_in.adj_reserve, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.reserve_retired', rule_in.reserve_retired, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.recognize_gain_loss', rule_in.recognize_gain_loss, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.tracking_method', rule_in.tracking_method, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.allocate_to_fully_rsv_flag', rule_in.allocate_to_fully_rsv_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.allocate_to_fully_ret_flag', rule_in.allocate_to_fully_ret_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.excess_allocation_option', rule_in.excess_allocation_option, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.depreciation_option', rule_in.depreciation_option, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.member_rollup_flag', rule_in.member_rollup_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.unplanned_amount', rule_in.unplanned_amount, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.eofy_recoverable_cost', rule_in.eofy_recoverable_cost, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.eop_recoverable_cost', rule_in.eop_recoverable_cost, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.eofy_salvage_value', rule_in.eofy_salvage_value, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.eop_salvage_value', rule_in.eop_salvage_value, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.used_by_adjustment', rule_in.used_by_adjustment, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.eofy_flag', rule_in.eofy_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.apply_reduction_flag', rule_in.apply_reduction_flag, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.mrc_sob_type_code', rule_in.mrc_sob_type_code, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.set_of_books_id', rule_in.set_of_books_id, p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_in.impairment_reserve', rule_in.impairment_reserve, p_log_level_rec);
   end if;

   -----------------------------------------------------------
   -- Copy rule_in to g_rule_in
   -----------------------------------------------------------
   g_rule_in := rule_in;
   -----------------------------------------------------------
   -- Initialize
   -----------------------------------------------------------
   g_rule_in.reduction_amount :=0;
   g_rule_out.new_adjusted_cost  := g_rule_in.old_adjusted_cost;
   g_rule_out.new_raf            := g_rule_in.old_raf;
   g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
   g_rule_in.use_old_adj_cost_flag := null; -- If the calculation uses old adjusted cost
                                            -- old adjusted cost, this flag set Y.
                                            -- This flag is used by FLAT_EXTENSION.
   g_rule_in.member_transaction_type_code := null; -- This is for AMORT_ADJ event type
   g_rule_in.member_proceeds :=0;  -- Member Proceeds which group asset is processed.

   --Bug 8256548 start
   if (rule_in.mrc_sob_type_code = 'R') then
      if NOT fa_cache_pkg.fazcbcs(X_book          => rule_in.book_type_code ,
                                  X_set_of_books_id => rule_in.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) Then
         raise faxcdb_err;
      end if;
   else
      -- call the cache for the primary transaction book
      if NOT fa_cache_pkg.fazcbc(X_book          => rule_in.book_type_code, p_log_level_rec => p_log_level_rec) then
         raise faxcdb_err;
      end if;
   end if;
   --Bug 8256548 end

   -----------------------------------------------------------
   -- Call Depreciable Basis rules
   -----------------------------------------------------------
   if (fa_cache_pkg.fazcdbr_record.deprn_basis_rule_id is null) or
      ((g_rule_in.method_code <> fa_cache_pkg.fazccmt_record.method_code) or
       (nvl(g_rule_in.life_in_months, -99) <> nvl(fa_cache_pkg.fazccmt_record.life_in_months, -99))) then
      if fa_cache_pkg.fazccmt(g_rule_in.method_code, g_rule_in.life_in_months, p_log_level_rec => p_log_level_rec) then
         if p_log_level_rec.statement_level then
            fa_debug_pkg.add(fname=>'faxcdb',
                          element=>'fazcdbr',
                          value=> 'Called', p_log_level_rec => p_log_level_rec);
         end if;
      end if;
   end if;

  -- Set flags for depreciable basis rule setup
  rule_id := fa_cache_pkg.fazcdbr_record.deprn_basis_rule_id;
  l_rule_name := fa_cache_pkg.fazcdbr_record.rule_name;
  l_period_update_flag := fa_cache_pkg.fazcdrd_record.period_update_flag;
  l_subtract_ytd_flag  := fa_cache_pkg.fazcdrd_record.subtract_ytd_flag;
  if p_log_level_rec.statement_level then
     fa_debug_pkg.add(fname   =>'faxcdb',
                      element =>'rule_id',
                      value   => rule_id, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(fname=>'faxcdb',
                      element=>'l_period_update_flag',
                      value=> l_period_update_flag, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(fname=>'faxcdb',
                      element=>'l_subtract_ytd_flag',
                      value=> l_subtract_ytd_flag, p_log_level_rec => p_log_level_rec);
  end if;

  -----------------------------
  -- Validation Check
  -----------------------------
  if not SERVER_VALIDATION(p_log_level_rec)
  then
    raise faxcdb_err;
  end if;

  -------------------------------------------
  -- Populate necessary value for impairment
  -------------------------------------------
  g_rule_in.impairment_reserve := nvl(g_rule_in.impairment_reserve, 0); -- Bug4940246

  if p_log_level_rec.statement_level then
     fa_debug_pkg.add('faxcdb', 'rule_in.impairment_reserve', rule_in.impairment_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', 'g_rule_in.use_passed_imp_rsv_flag', rule_in.use_passed_imp_rsv_flag, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', 'g_rule_in.method_type', g_rule_in.method_type, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', 'g_rule_in.calc_basis', g_rule_in.calc_basis, p_log_level_rec => p_log_level_rec);
  end if;

  -- IAS36 need to adjust ltd_imp
  if (nvl(rule_in.impairment_reserve, 0) <> 0) and
     (nvl(rule_in.use_passed_imp_rsv_flag, 'N') = 'N') and
     (g_rule_in.method_type = 'FLAT') and
     (g_rule_in.calc_basis = 'COST') and
      NVL(g_rule_in.transaction_flag,'XX') <> 'JI'then --phase5
/*
     ((l_rule_name = 'FLAT RATE EXTENSION') or
     ((g_rule_in.method_type = 'FLAT') and
      (g_rule_in.calc_basis = 'COST'))) then
*/

     if (rule_in.mrc_sob_type_code <> 'R') then
        OPEN c_get_rsv_at_imp;
        FETCH c_get_rsv_at_imp INTO l_deprn_reserve_at_imp
                                  , l_impairment_reserve
                                  , l_imp_period_counter;
        CLOSE c_get_rsv_at_imp;
     else
        OPEN c_get_mc_rsv_at_imp;
        FETCH c_get_mc_rsv_at_imp INTO l_deprn_reserve_at_imp
                                     , l_impairment_reserve
                                     , l_imp_period_counter;
        CLOSE c_get_mc_rsv_at_imp;
     end if;

     if p_log_level_rec.statement_level then
       fa_debug_pkg.add('faxcdb', 'l_deprn_reserve_at_imp', l_deprn_reserve_at_imp, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('faxcdb', 'l_impairment_reserve', l_impairment_reserve, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('faxcdb', 'l_imp_period_counter', l_imp_period_counter, p_log_level_rec => p_log_level_rec);
     end if;

     if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
        raise faxcdb_err;
     end if;

     l_imp_fiscal_year := round((l_imp_period_counter - 1)/fa_cache_pkg.fazcct_record.number_per_fiscal_year);

     if (nvl(fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, 'Y')  = 'Y') then
        g_rule_in.impairment_reserve := l_deprn_reserve_at_imp + l_impairment_reserve;
     end if;


  end if;
  ------------------------------------------------------------
  -- Event Type: ADDITION (Additions)
  ------------------------------------------------------------

  if (g_rule_in.event_type ='ADDITION') then
        if (g_rule_in.calc_basis = 'NBV') then
          g_rule_out.new_adjusted_cost :=
                        g_rule_in.recoverable_cost - g_rule_in.current_total_rsv
                        + g_rule_in.current_total_ytd;
     if p_log_level_rec.statement_level then
       fa_debug_pkg.add('faxcdb', 'g_rule_in.recoverable_cost', g_rule_in.recoverable_cost, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('faxcdb', 'g_rule_in.current_total_rsv', g_rule_in.current_total_rsv, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('faxcdb', 'g_rule_in.current_total_ytd', g_rule_in.current_total_ytd, p_log_level_rec => p_log_level_rec);
     end if;
        elsif (g_rule_in.calc_basis = 'COST') then
          g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
        else
          raise calc_basis_err;
        end if;

        g_rule_out.new_raf := 1;
        g_rule_out.new_formula_factor := 1;
  end if;
  ------------------------------------------------------------
  -- Event Type: EXPENSED_ADJ (Expensed Adjustment)
  ------------------------------------------------------------

  if (g_rule_in.event_type ='EXPENSED_ADJ') then
     if (g_rule_in.asset_type = 'CAPITALIZED') then
       if (Upper(g_rule_in.depreciate_flag) like 'Y%') OR
       (g_rule_in.adjusted_cost =0 AND Upper(g_rule_in.depreciate_flag) NOT like 'Y%' ) then
          if (g_rule_in.calc_basis = 'COST') then
            g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
            g_rule_out.new_formula_factor := 1;
          elsif g_rule_in.calc_basis = 'NBV' then
            if (g_rule_in.method_type = 'FORMULA') then

                -- Bug4169773
                if nvl(g_rule_in.short_fy_flag, 'NO') = 'NO' then
                   g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.hyp_total_rsv
                                                                              + g_rule_in.hyp_total_ytd;
                else
                   g_rule_out.new_adjusted_cost := g_rule_in.adjusted_cost;
                end if;

                if g_rule_in.recoverable_cost= 0 then
                  g_rule_out.new_formula_factor := nvl(g_rule_in.old_formula_factor,1);
                else
                  -- Bug4169773
                  if nvl(g_rule_in.short_fy_flag, 'NO') = 'NO' then
                     g_rule_out.new_formula_factor := 1;
                  else
                     g_rule_out.new_formula_factor := g_rule_in.hyp_basis /
                                                      g_rule_in.recoverable_cost;
                  end if;
                end if;
            elsif (g_rule_in.method_type = 'FLAT') then
                    g_rule_out.new_adjusted_cost :=
                        g_rule_in.recoverable_cost - g_rule_in.hyp_total_rsv
                        + g_rule_in.hyp_total_ytd;
                    g_rule_out.new_formula_factor := 1;
            else /* other method type */
                g_rule_out.new_adjusted_cost :=
                        g_rule_in.recoverable_cost - g_rule_in.hyp_total_rsv;
                g_rule_out.new_formula_factor := 1;
            end if;
          else -- unexpected calc_basis
            raise calc_basis_err;
          end if; -- End of calc_basis
        else
          if (g_rule_in.method_type = 'FLAT') then
            if (g_rule_in.calc_basis = 'COST') then
              g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
            elsif g_rule_in.calc_basis = 'NBV' then
              g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.eofy_reserve;
            else
             raise calc_basis_err;
            end if;
          else /* other method type */
            g_rule_out.new_adjusted_cost :=
                g_rule_in.recoverable_cost - g_rule_in.current_total_rsv;
          end if;
            g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
        end if;
        g_rule_out.new_raf := g_rule_in.old_raf;
     elsif g_rule_in.asset_type ='GROUP' then
       -- If the depreciate flag of group asset is NO,
       -- Group asset is called EXPENSED_ADJ
       if  (g_rule_in.method_type = 'FLAT') then
         if (g_rule_in.calc_basis = 'COST') then
           g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
         elsif g_rule_in.calc_basis = 'NBV' then
           g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.eofy_reserve;
         else -- unexpected calc_basis
             raise calc_basis_err;
         end if;
       else -- other method type
            g_rule_out.new_adjusted_cost :=
                g_rule_in.recoverable_cost - g_rule_in.current_total_rsv;
       end if; -- End of method type
       g_rule_out.new_raf := g_rule_in.old_raf;
       g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
     end if; -- End of Group
  end if;
  ------------------------------------------------------------
  -- Event Type: AMORT_ADJ (Amortized Adjustment)
  ------------------------------------------------------------

  if (g_rule_in.event_type ='AMORT_ADJ') then

    -- Check the member transaction type code
    if g_rule_in.asset_type ='GROUP'
    then

      if g_rule_in.member_transaction_header_id is not null then
        if not (GET_MEM_TRANS_INFO (
                p_member_transaction_header_id => g_rule_in.member_transaction_header_id,
                p_mrc_sob_type_code            => g_rule_in.mrc_sob_type_code,
                p_set_of_books_id              => g_rule_in.set_of_books_id,
                x_member_transaction_type_code => g_rule_in.member_transaction_type_code,
                x_member_proceeds              => g_rule_in.member_proceeds,
                x_member_reduction_rate        => l_member_reduction_rate,
                x_recognize_gain_loss          => l_recognize_gain_loss,
                p_log_level_rec => p_log_level_rec
              ))
        then
          raise faxcdb_err;
        end if;
      end if; -- member_transaction_header_id is not null

      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname   =>'faxcdb',
                         element =>'member_transaction_type_code',
                         value   => g_rule_in.member_transaction_type_code, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(fname   =>'faxcdb',
                         element =>'member_proceeds',
                         value   => g_rule_in.member_proceeds, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(fname   =>'faxcdb',
                         element =>'l_member_reduction_rate',
                         value   => l_member_reduction_rate, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(fname   =>'faxcdb',
                         element =>'l_member_transaction_flag',
                         value   => l_member_transaction_flag, p_log_level_rec => p_log_level_rec);
      end if;

      -- If this transaction is member's transaction,
      -- replace the group default reduction rate
      -- to member transaction reduction rate
      if  g_rule_in.member_transaction_header_id is not null then
        g_rule_in.reduction_rate := l_member_reduction_rate;
        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname   =>'faxcdb',
                           element =>'Updated reduction_rate',
                           value   => g_rule_in.reduction_rate, p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if; -- End of checking the member transaction type code
    if (g_rule_in.asset_type ='GROUP'
       or (g_rule_in.asset_type <> 'GROUP' and g_rule_in.tracking_method='ALLOCATE')
       )
       and nvl(g_rule_in.member_transaction_type_code,'NULL') like '%RETIREMENT'
       --Bug7394159: Added following condition to exclude STL method
       and (nvl(g_rule_in.method_type, 'NULL') <> 'CALCULATED' or nvl(l_recognize_gain_loss,'YES') = 'NO')
    then
      -- When member assets are retired, the group asset and allocated member asset
      -- are processed as follows.

      if g_rule_in.calc_basis = 'NBV' then
        --
        -- Bug3463933: Added condition to set adjusted_cost to 0 if cost is 0.
        --
        if g_rule_in.cost = 0 then
          g_rule_out.new_adjusted_cost := 0;
        elsif g_rule_in.recognize_gain_loss like 'N%' then
        -- Do Not Recognaize Gain and Loss
          g_rule_out.new_adjusted_cost :=
            g_rule_in.recoverable_cost - g_rule_in.adjustment_amount
               - g_rule_in.eofy_reserve - nvl(g_rule_in.member_proceeds,0);
        else -- Recog Gain/Loss
          g_rule_out.new_adjusted_cost :=
            g_rule_in.recoverable_cost - g_rule_in.eofy_reserve;
        end if;
      elsif g_rule_in.calc_basis = 'COST' then
        if g_rule_in.cost = 0 then
          g_rule_out.new_adjusted_cost := 0;
        else
          g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
        end if;
      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End of calc_basis

      g_rule_out.new_raf := g_rule_in.old_raf;
      g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
    else -- Normal Adjustment
      if (g_rule_in.calc_basis = 'COST') then
          if (g_rule_in.method_type = 'FLAT') then
            g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
            g_rule_out.new_raf := 1;
          elsif (g_rule_in.method_type = 'PRODUCTION') then
            if g_rule_in.recoverable_cost = 0 then
              g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
            else
              g_rule_out.new_adjusted_cost :=
                        g_rule_in.recoverable_cost - g_rule_in.current_rsv - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
            end if;
              g_rule_out.new_raf := 1;
          else /* other method type */
            if g_rule_in.recoverable_cost = 0 then
              g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
              g_rule_out.new_raf := nvl(g_rule_in.old_raf,1);
            else

              -- Bug fix 5951210
               if (g_rule_in.method_type = 'CALCULATED') then
                  -- Japan Tax Phase3
                  if (nvl(g_rule_in.transaction_flag,'X') = 'ES') then
                     -- Bug 6660490 : Adjusted_cost after reinstatement in extended
                     -- period is based on cost instead of recoverable cost.
                     -- Bug# 6964738 start
                     g_rule_out.new_adjusted_cost :=
                                      g_rule_in.cost - g_rule_in.current_total_rsv - nvl(g_rule_in.impairment_reserve,0) - 1
                              + g_rule_in.current_total_ytd;
                    --Bug# 6964738 end
                  -- Bug 8211842: Extended deprn not started
                  elsif (nvl(g_rule_in.transaction_flag,'X') = 'EN') then
                     g_rule_out.new_adjusted_cost :=
                                      g_rule_in.cost - g_rule_in.current_total_rsv - nvl(g_rule_in.impairment_reserve,0) - 1 ;
                  else
                     g_rule_out.new_adjusted_cost :=
                                      g_rule_in.recoverable_cost - g_rule_in.current_total_rsv - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
                  end if;
               else
                  g_rule_out.new_adjusted_cost :=
                            g_rule_in.recoverable_cost - g_rule_in.current_rsv - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
               end if;
               -- End bug fix 5951210
              -- Bug 6704518 need to use adjusted_recoverable_cost instead of
               -- recoverable_cost for JP-STL-EXTND method
               -- Bug 6761481: raf is 1 for JP-STL-EXTND method
               if (nvl(g_rule_in.transaction_flag,'X') = 'ES') then
                  /*g_rule_out.new_raf := (g_rule_in.adjusted_recoverable_cost -
                          g_rule_in.hyp_total_rsv)/g_rule_in.adjusted_recoverable_cost;*/
                  g_rule_out.new_raf := 1;
               else
	          /*phase5 need to calculate RAF with reserve and cost in extended state only*/
	          IF ((NVL(g_rule_in.transaction_flag,'XX') = 'JI') AND (rule_in.method_code = 'JP-STL-EXTND')) THEN
	             g_rule_out.new_raf := ((rule_in.old_adjusted_cost -
	                                   (rule_in.current_total_rsv - (g_rule_in.cost - (rule_in.old_adjusted_cost + NVL (rule_in.allowed_deprn_limit_amount,0))))
			                    )/ rule_in.old_adjusted_cost );
		     /* bug 9772354 need to exclude salvage value for adj cost calculation for extended assets*/
                     g_rule_out.new_adjusted_cost :=
                                      g_rule_in.cost - g_rule_in.current_total_rsv - nvl(g_rule_in.impairment_reserve,0) - NVL (rule_in.allowed_deprn_limit_amount,0) ;
		    /*bug 9786860 */
		    IF g_rule_out.new_adjusted_cost < 0 THEN
                       g_rule_out.new_adjusted_cost := 0;
		    END IF;

		  ELSE
                     g_rule_out.new_raf := (g_rule_in.recoverable_cost -
                                       g_rule_in.hyp_total_rsv)/g_rule_in.recoverable_cost;
	          END IF;
	       end if;
            end if;
        end if;
          g_rule_out.new_formula_factor := 1;
      elsif g_rule_in.calc_basis = 'NBV' then
          if (g_rule_in.method_type = 'FLAT') then
            g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.eofy_reserve
                                                                       - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
            g_rule_out.new_raf := 1;
            g_rule_out.new_formula_factor := 1;
          elsif (g_rule_in.method_type = 'FORMULA') then
            if g_rule_in.recoverable_cost = 0 then
              g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
              g_rule_out.new_raf := nvl(g_rule_in.old_raf,1);
              g_rule_out.new_formula_factor := nvl(g_rule_in.old_formula_factor,1);
            else

            -- Bug fix 6345693 (Japan Tax Reforms)
            if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES' then

               select bk.deprn_method_code, bk.salvage_value, bk.cost  -- bug 6378955 (added salvage value)
               into l_old_method_code, l_old_salvage_value, l_old_cost  -- l_old_cost added for Japan overlapped
               from FA_BOOKS bk
               where bk.asset_id = g_rule_in.asset_id
               and bk.book_type_code = g_rule_in.book_type_code
               and bk.transaction_header_id_out is null;

               -- Bug 7286617: Combined all the conditions and added one more
               -- condition for overlapped adjustment.
               -- restructured following if-else block for japan overlapped
               if (l_old_cost <> g_rule_in.cost ) or
                  ((g_rule_in.method_code <> l_old_method_code) and
                   (nvl(l_old_salvage_value,0) <> nvl(g_rule_in.salvage_value,0))) or
                  (g_rule_in.method_code = l_old_method_code) or
                  ((g_rule_in.method_code <> l_old_method_code) and
                   (nvl(l_old_salvage_value,0) = nvl(g_rule_in.salvage_value,0))) then
                  g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.current_total_rsv
                                                  + g_rule_in.current_total_ytd - nvl(g_rule_in.impairment_reserve,0);
               end if;

            else
                g_rule_out.new_adjusted_cost :=
                g_rule_in.recoverable_cost - g_rule_in.current_total_rsv - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
            end if;
            -- End bugfix 6345693
              -- Bug4169773
              if nvl(g_rule_in.short_fy_flag, 'NO') = 'NO' then
                 g_rule_out.new_formula_factor := 1;
                 g_rule_out.new_raf := 1;
              else
	         g_rule_out.new_raf := (g_rule_in.recoverable_cost -
                                        g_rule_in.hyp_total_rsv)/g_rule_in.recoverable_cost;
                 g_rule_out.new_formula_factor := g_rule_in.hyp_basis
                                                     / g_rule_in.recoverable_cost;
              end if;
            end if;
          else /* other method types */
            if g_rule_in.recoverable_cost = 0 then
              g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost;
            else
              g_rule_out.new_adjusted_cost :=
                g_rule_in.recoverable_cost - g_rule_in.current_total_rsv - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
            end if;
            g_rule_out.new_raf := 1;
            g_rule_out.new_formula_factor := 1;
          end if; --Method type
      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- Calc Basis

    end if; -- Normal Adjustment
  end if;
  ------------------------------------------------------------
  -- Event Type: AMORT_ADJ2 (Amortized Adjustment 2)
  --
  -- For Back-dated Adjustment
  -- This event type is Obsoleted.
  -- ******  This event type can be obsolete as soon as faxraf and FAAMRT1B.pls
  -- ******  are obsolete
  ------------------------------------------------------------

  if (g_rule_in.event_type ='AMORT_ADJ2') then
        g_rule_out.new_adjusted_cost := g_rule_in.old_adjusted_cost;
        g_rule_out.new_raf := g_rule_in.old_raf;
        g_rule_out.new_formula_factor := g_rule_out.new_formula_factor;
  end if;

  ------------------------------------------------------------
  -- Event Type: AMORT_ADJ3 (Amortized Adjustment 3)
  --
  -- For Back-dated Adjustment
  ------------------------------------------------------------

  if (g_rule_in.event_type ='AMORT_ADJ3') then
        -- Bug:5930979:Japan Tax Reform Project
        -- (Changed below if bcoz Reinstament was causing change in Adjusted_cost,
        --  and here adjusted_cost change is restrcited for guarantee methods)
        if (g_rule_in.method_type = 'FORMULA' and g_rule_in.calc_basis ='NBV'
            AND nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') <> 'YES'
        ) then
            if p_log_level_rec.statement_level then
               fa_debug_pkg.add(l_calling_fn, '++ g_rule_in.current_rsv', g_rule_in.current_rsv, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '++ g_rule_in.eofy_reserve', g_rule_in.eofy_reserve, p_log_level_rec => p_log_level_rec);
            end if;
            -- Bug 5212364
            if (g_rule_in.current_rsv <> 0) then
              g_rule_out.new_adjusted_cost :=
                        g_rule_in.recoverable_cost - g_rule_in.current_rsv;
            else
              g_rule_out.new_adjusted_cost :=
                        g_rule_in.recoverable_cost - nvl(g_rule_in.eofy_reserve,0);
            end if;
        else
           -- Restructured this else part for bug 6717680
            select bk.deprn_method_code
            into l_old_method_code
            from FA_BOOKS bk
            where bk.asset_id = g_rule_in.asset_id
            and bk.book_type_code = g_rule_in.book_type_code
            and bk.transaction_header_id_out is null;

            if g_rule_in.method_code = l_old_method_code then
           g_rule_out.new_adjusted_cost := g_rule_in.adjusted_cost;
          g_rule_in.use_old_adj_cost_flag :='Y';
        end if;
        end if;
         g_rule_out.new_raf := g_rule_in.old_raf;
        g_rule_out.new_formula_factor := g_rule_out.new_formula_factor;
  end if;

  ------------------------------------------------------------
  -- Event Type: RETIREMENT (Retirements)
  --
  ------------------------------------------------------------

  if (g_rule_in.event_type ='RETIREMENT') then

    if g_rule_in.recognize_gain_loss like 'N%'
    then -- Do Not Recognaize Gain and Loss
      if g_rule_in.calc_basis = 'COST'
      then -- Cost Base
        g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
      elsif g_rule_in.calc_basis = 'NBV' then
        g_rule_out.new_adjusted_cost :=
            g_rule_in.recoverable_cost - g_rule_in.eofy_reserve
                - (g_rule_in.nbv_retired) - nvl(g_rule_in.impairment_reserve,0);
      else -- unexpected calc_basis
        raise calc_basis_err;
      end if;
    elsif g_rule_in.recognize_gain_loss like 'Y%'
          and g_rule_in.calc_basis = 'NBV'
          and g_rule_in.group_asset_id is not null
    then  -- Member asset NBV base and Recog Gain/Loss
      g_rule_out.new_adjusted_cost :=
            g_rule_in.recoverable_cost - g_rule_in.eofy_reserve - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
    else -- Member Cost base and standalone asset
      if g_rule_in.cost = 0 then
        g_rule_out.new_adjusted_cost := 0;
      else

/*    Fix for Bug #3901978.  Replaced cost w/ old_cost.
      g_rule_out.new_adjusted_cost :=
           g_rule_in.old_adjusted_cost*
                 (1- g_rule_in.adjustment_amount/g_rule_in.cost);
*/
         -- Fix for Bug #6364053.  Catch the case where this is 0.
         if g_rule_in.old_cost = 0 then

            g_rule_out.new_adjusted_cost :=
               g_rule_in.recoverable_cost -
                  nvl(g_rule_in.impairment_reserve,0);
         -- Japan Tax Phase3 bug 6658280
         elsif (nvl(g_rule_in.transaction_flag,'X') = 'ES') then
          /* Bug 6786225 : Need to get the deprn_limit from calling function
          begin

               select nvl(allowed_deprn_limit_amount,0)
               into l_deprn_amt
               from fa_books
               where asset_id = g_rule_in.asset_id
               and transaction_header_id_out is null;
            exception
              when others then
                 null;
            end;*/
             l_deprn_amt := g_rule_in.allowed_deprn_limit_amount;
                  fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'l_deprn_amt',
                       value=> l_deprn_amt, p_log_level_rec => p_log_level_rec);

            g_rule_out.new_adjusted_cost :=
               (g_rule_in.old_adjusted_cost + l_deprn_amt) *
                    (1- g_rule_in.adjustment_amount/g_rule_in.old_cost) - l_deprn_amt;
         else
            g_rule_out.new_adjusted_cost :=
               g_rule_in.old_adjusted_cost*
                    (1- g_rule_in.adjustment_amount/g_rule_in.old_cost);
         end if;

         g_rule_in.use_old_adj_cost_flag :='Y';

      end if;
    end if; -- End Gain and Loss option

    g_rule_out.new_raf := g_rule_in.old_raf;
    g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
  end if; -- End Retirement

  ------------------------------------------------------------
  -- Event Type: AFTER_DEPRN (After Depreciation)
  --
  -- Recalculate Adjusted Cost After Depreciation of Fiscal
  -- Year End.
  ------------------------------------------------------------
  if p_log_level_rec.statement_level then
     fa_debug_pkg.add('faxcdb', 'After deprn', 'Begin', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', '+++ Event Type : ', g_rule_in.event_type, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', '+++ Calc Basis : ', g_rule_in.calc_basis, p_log_level_rec => p_log_level_rec);
  end if;
  if (g_rule_in.event_type ='AFTER_DEPRN') then

    -- Calculate Adjusted Cost
    IF g_rule_in.eofy_flag ='Y' OR l_period_update_flag='Y' then
      if (g_rule_in.calc_basis = 'COST') then
        g_rule_out.new_adjusted_cost :=g_rule_in.old_adjusted_cost;
        g_rule_in.use_old_adj_cost_flag :='Y';

      elsif g_rule_in.calc_basis = 'NBV' then

         -- Bug:5930979:Japan Tax Reform Project (Start)
         if p_log_level_rec.statement_level then
            fa_debug_pkg.add('faxcdb', '+++ Guarantee Flag : ', fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, p_log_level_rec => p_log_level_rec);
         end if;

         if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES' then

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add('faxcdb', '+++ Inside Guarantee Logic', 'YES', p_log_level_rec => p_log_level_rec);
            end if;

            --- Changed  as the Initial Mass Copy is erroring Out with NO_DATA_FOUND
            --- If Condition is added  as the program is erroring out with NO_DATA_FOUND when Hypothical What-If analysis
            /*bug 8686064 fetched cost, nbv at switch also*/
            BEGIN
               SELECT rate_in_use, deprn_method_code,cost,nbv_at_switch -- Added deprn_method_code for bug fix 6717680
               INTO l_rate_in_use, l_old_method_code,l_old_cost,l_nbv_at_switch
               FROM fa_books
               WHERE asset_id = g_rule_in.asset_id
               AND book_type_code = g_rule_in.book_type_code
               AND transaction_header_id_out is null;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT rate_in_use, deprn_method_code,cost,nbv_at_switch -- Added deprn_method_code for bug fix 6717680
                     INTO l_rate_in_use, l_old_method_code,l_old_cost,l_nbv_at_switch
                     FROM fa_books fb
                        , fa_book_controls fc
                     WHERE fb.asset_id = g_rule_in.asset_id
                     AND fc.book_type_code = g_rule_in.book_type_code
                     AND fc.distribution_source_book = fb.book_type_code
                     AND fb.transaction_header_id_out is null;
                  EXCEPTION
                     WHEN OTHERS THEN
		        l_nbv_at_switch := NULL;
                        l_rate_in_use := NULL;
			l_fbk_exist := 'N';
                        l_old_method_code := rule_in.method_code;
                  END;
            END;
            l_cur_rate_used            := l_rate_in_use;
            l_original_Rate            := fa_cache_pkg.fazcfor_record.original_rate;
            l_Revised_Rate             := fa_cache_pkg.fazcfor_record.revised_rate;
            l_Guaranteed_Rate          := fa_cache_pkg.fazcfor_record.guarantee_rate;

            IF l_rate_in_use IS NULL OR  g_rule_in.method_code <> l_old_method_code THEN
               -- Removed the SQL query in order to make use of the values stored in the cache.

               l_fbk_exist := 'N'; -- Bug:8834613
               IF (rule_in.cost * l_Guaranteed_Rate) >
                  ((rule_in.cost - rule_in.current_rsv)* l_original_Rate) THEN
                  l_rate_in_use := l_Revised_Rate;
               ELSE
                 l_rate_in_use :=  l_original_Rate;
               END IF;
            END IF;

            --- BUG # 7193797: Added the below code to calculate Correct Adjusted cost for the Deprn Method JP-250DB XX
            if fnd_global.conc_request_id is not null AND fnd_global.conc_request_id  <> -1 then
               begin
                  select program_short_name
                  into l_request_short_name
                  from FND_CONC_REQ_SUMMARY_V
                  where request_id = fnd_global.conc_request_id;
               exception
                  when others then
                     l_request_short_name := NULL;
               end;
            end if;

            IF l_request_short_name = 'FAWDPR' then
            /*bug 8686064 fetched the nbv at awitch in above query itself.no need to write another query*/
               -- BUG# 7304706 Added to reset the g_switched_whatif to ZERO., if Processing for New Asset
               if g_old_asset_id <> rule_in.asset_id then
                  g_switched_whatif := 0;
                  g_old_asset_id := rule_in.asset_id;     -- BUG# 7304706 Added to assing current Asset ID to g_old_asset_id.
               end if;
               IF (rule_in.cost * l_Guaranteed_Rate) >
                  ((rule_in.cost - rule_in.current_rsv)* l_original_Rate) THEN
                  l_rate_in_use := l_Revised_Rate;
                  --Bug 7515920 Added AND condition in below if . For assets those are already in swicthed state
                  if (l_nbv_at_switch IS NULL AND (l_cur_rate_used <> l_Revised_Rate ))   then
                     g_switched_whatif := g_switched_whatif + 1;
                  end if;
               ELSE
                 l_rate_in_use :=  l_original_Rate;
               END IF;

            END IF;
            --- BUG # 7193797: End OF Addition.

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add('faxcdb', '+++ Revised Rate : ', fa_cache_pkg.fazcfor_record.revised_rate, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('faxcdb', '+++ FA_Books.Rate : ', l_rate_in_use, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('faxcdb', '+++ FA_Books.deprn_method : ', l_old_method_code, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('faxcdb', '+++ fnd_global.request_id : ', fnd_global.conc_request_id, p_log_level_rec => p_log_level_rec);
               end if;

            --Bug 8639499 ..need to change the value of global count if asset changes its state twice during
            --any recalculation due to method/life change
            IF (rule_in.cost * l_Guaranteed_Rate) < ((rule_in.cost - rule_in.current_rsv)* l_original_Rate) THEN
                  g_switched_recal := 0;
            END IF;

            -- Added if clause for bug fix 6717680
	    /*bug 8686064 compared current and old cost also*/
            if (g_rule_in.method_code <> l_old_method_code) OR (g_rule_in.cost <> l_old_cost) then
               --Need to keep the adjusted cost of an asset constant after switching.
               IF g_switched_recal <> 1 then
                  g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost  - g_rule_in.current_total_rsv;
               ELSE
                  null;
               END IF;
               IF (rule_in.cost * l_Guaranteed_Rate) > ((rule_in.cost - rule_in.current_rsv)* l_original_Rate) THEN
                  g_switched_recal := 1;
               END IF;
            elsif fa_cache_pkg.fazcfor_record.revised_rate = l_rate_in_use then
               --BUG # 7193797: Added the below IF loop for calculating the Adjusted cost During Switch.
               --Bug 8726493 corrected the logic to handel adjusted cost during switch
               --no need to change adjusted cost once it comes into switched state

	       g_switched_add := g_switched_add +1;

	       /* Bug 8834613..added l_fbk_exist flag below so that so that adjusted cost is only changed
	          when asset is added in switched state*/

	       if (g_switched_add = 1   and l_fbk_exist = 'N' ) OR (g_switched_whatif = 1) then
                  g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.current_total_rsv
                                                  - nvl(g_rule_in.impairment_reserve,0);
               end if;
               --BUG # 7193797: End OF Addition
            else

               if p_log_level_rec.statement_level then
                  fa_debug_pkg.add('faxcdb', '+++ ORIGINAL RATE', 'YES', p_log_level_rec => p_log_level_rec);
               end if;

               g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.current_total_rsv
                                               - nvl(g_rule_in.impairment_reserve,0);
            end if; -- revised_rate = l_rate_in_use

         else  -- guarantee rate is 'NO'

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add('faxcdb', '+++ Outside Guarantee Logic', 'YES', p_log_level_rec => p_log_level_rec);
            end if;

            g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.current_total_rsv
                                                                       - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
         end if; -- guarantee rate
        -- Bug:5930979:Japan Tax Reform Project (End)

      else -- unexpected calc_basis
        raise calc_basis_err;
      end if;
    END IF; -- End deprn_end_perd_flag ='Y' OR l_period_update_flag='Y'
      g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
      g_rule_out.new_raf := g_rule_in.old_raf;
  end if; -- End event type

  if p_log_level_rec.statement_level then
     fa_debug_pkg.add('faxcdb', 'After deprn', 'End', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', 'After deprn', g_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;

  -------------------------------------------------------------
  -- Event Type: AFTER_DEPRN2 (After Depreciation 2)
  --
  -- Recalculate Formula Factor after event type 'AFTER_DEPRN'.
  -- When method type is 'FORMULA',calculation basis is 'NBV',
  -- raf is not 1 and formula factor is not 1,
  -- call faxdfcc and call AFTER_DEPRN2 from faxdfcc.
  -------------------------------------------------------------

  if (g_rule_in.event_type ='AFTER_DEPRN2') then

    if g_rule_in.recoverable_cost =0 or g_rule_in.old_adjusted_cost =0 then
      g_rule_out.new_formula_factor := nvl(g_rule_in.old_formula_factor,1);
    else
      -- Bug4169773
      if nvl(g_rule_in.short_fy_flag, 'NO') = 'NO' then
         g_rule_out.new_formula_factor := 1;
      else
         g_rule_out.new_formula_factor := g_rule_in.adjusted_cost *
                                          (g_rule_in.recoverable_cost - g_rule_in.hyp_total_rsv)
                                             / g_rule_in.recoverable_cost / g_rule_in.old_adjusted_cost;
      end if;
    end if;

    g_rule_out.new_adjusted_cost :=g_rule_in.old_adjusted_cost;
    g_rule_out.new_raf := g_rule_in.old_raf;
  end if;

  -------------------------------------------------------------
  -- Event Type: DEPRECIATE_FLAG_ADJ (IDLE Asset Control)
  -- When depreciate flag is changed, this event is called.
  -------------------------------------------------------------

  if (g_rule_in.event_type ='DEPRECIATE_FLAG_ADJ') then

     if (g_rule_in.method_type = 'FORMULA') THEN
        g_rule_out.new_adjusted_cost := g_rule_in.adjusted_cost;
        g_rule_out.new_raf := g_rule_in.old_raf;
        g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
     END IF;

     if (Upper(g_rule_in.depreciate_flag) like 'Y%'
        AND (g_rule_in.calc_basis ='NBV' AND
             (g_rule_in.method_type = 'TABLE' OR g_rule_in.method_type = 'FLAT')))
       THEN

        l_asset_id := g_rule_in.asset_id;
        l_book_type_code := g_rule_in.book_type_code;

        select         count(*)
          into l_last_trx_count
          from fa_books bks,
          fa_deprn_periods dp
          where bks.asset_id = l_asset_id
          and bks.book_type_code = l_book_type_code
          and bks.date_ineffective  is null
            and dp.book_type_code = l_book_type_code
            and bks.date_effective between
            dp.period_open_date and nvl(dp.period_close_date, sysdate)
            and dp.fiscal_year = fa_cache_pkg.fazcbc_record.current_fiscal_year;

          IF (l_last_trx_count =0) THEN
             g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.eofy_reserve
                                                                        - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
           ELSE
             g_rule_out.new_adjusted_cost := g_rule_in.old_adjusted_cost;
             g_rule_in.use_old_adj_cost_flag :='Y';
          END IF;

          g_rule_out.new_raf := g_rule_in.old_raf;
          g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;

      ELSE
        g_rule_out.new_adjusted_cost := g_rule_in.old_adjusted_cost;
        g_rule_out.new_raf := g_rule_in.old_raf;
        g_rule_out.new_formula_factor := 1;

        g_rule_in.use_old_adj_cost_flag :='Y';
     END IF;

  END IF;

  ----------------------------------------------------------------
  -- Event Type: UNPLANNED_ADJ (Unplanned Depreciation)
  ----------------------------------------------------------------
  if (g_rule_in.event_type ='UNPLANNED_ADJ') THEN

    -- Bug 7343482: Prevented the recalculation of adjusted_cost for Formula based assets.
    -- Bug 7331261: Reverted the fix done for Bug 7028719
    -- Adjusted_cost need not be modified for JP-DB methods
    -- Bug 7028719 Modified If condition to unchange adjusted cost for flat rate cost basis method.
    IF (g_rule_in.old_raf <> 1) or
       (fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_PROD and
        rule_in.amortization_start_date is not null ) or
       (g_rule_in.amortization_start_date is not null and
        nvl(g_rule_in.life_in_months, 0) > 0 and
        g_rule_in.method_type <> 'FORMULA') THEN
       g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.current_total_rsv -
                                       g_rule_in.unplanned_amount - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
    ELSE
       g_rule_out.new_adjusted_cost := g_rule_in.old_adjusted_cost;
       g_rule_in.use_old_adj_cost_flag :='Y';
    END IF;

    /* Bug 7331261: Commented the fix made for Bug 7028719
    IF
       g_rule_in.amortization_start_date is null or
      (g_rule_in.amortization_start_date is not null
      and fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT
      and fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_COST)
    THEN
      g_rule_out.new_adjusted_cost := g_rule_in.old_adjusted_cost;
      g_rule_in.use_old_adj_cost_flag :='Y';

    ELSE
      g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - g_rule_in.current_total_rsv -
      g_rule_in.unplanned_amount - nvl(g_rule_in.impairment_reserve,0);

    END IF; */

    g_rule_out.new_raf := g_rule_in.old_raf;
    g_rule_out.new_formula_factor := g_rule_in.old_formula_factor;
  end if;  -- End UNPLANNED_ADJ

  ----------------------------------------------------------------
  -- Event Type: INITIAL_ADDITION
  --
  -- This event type calculates adjusted_cost at the period
  -- of DPIS.
  -- This adjusted cost is defaulted by the calculation of
  -- rate adjustment factor.
  ----------------------------------------------------------------

  if (g_rule_in.event_type ='INITIAL_ADDITION') THEN
    g_rule_out.new_adjusted_cost := g_rule_in.recoverable_cost - nvl(g_rule_in.impairment_reserve,0); -- Added NVL for bug# 5079543
    g_rule_out.new_raf := 1;
    g_rule_out.new_formula_factor :=1;
  end if; -- End of INITIAL_ADDITION

  ------------------------------------------------------------
  -- Call Depreciable Basis Rule
  ------------------------------------------------------------

  l_rule_formula :=
    'BEGIN '||fa_cache_pkg.fazcdbr_record.program_name||';

     exception
         when others then
         fa_srvr_msg.add_sql_error
           (calling_fn => '''||fa_cache_pkg.fazcdbr_record.program_name||''', p_log_level_rec => null); -- BUG# 5171343
         raise;
     END;';

  if p_log_level_rec.statement_level then
     fa_debug_pkg.add('faxcdb', 'Calling faxrnd ', 'before', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', 'book_type_code',  rule_in.book_type_code, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('faxcdb', 'new_adjusted_cost', g_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;


  -- Added for bug# 5171343
  if not fa_utils_pkg.faxrnd(g_rule_out.new_adjusted_cost, rule_in.book_type_code, rule_in.set_of_books_id, p_log_level_rec => p_log_level_rec) then
    fa_srvr_msg.add_message(calling_fn => 'faxcdb', p_log_level_rec => p_log_level_rec);
    return (FALSE);
  end if;
  -----------------------------------------------
  -- Run formula
  -----------------------------------------------

  if (fa_cache_pkg.fazcdbr_record.program_name is not null) then
    if p_log_level_rec.statement_level then

      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'Rule Name before rule logic',
                       value=> l_rule_name, p_log_level_rec => p_log_level_rec);

      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'new_adjusted_cost before rule logic',
                       value=> g_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'new_raf before rule logic',
                       value=> g_rule_out.new_raf, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'new_formula_factor before rule logic',
                       value=> g_rule_out.new_formula_factor, p_log_level_rec => p_log_level_rec);

    end if;

    ----------------------------------------------------------
    -- SEEDED rules are called to use parameters.
    -- and not seeded rules are called to use glbal variables
    -- as parameters.
    ----------------------------------------------------------

    -- Bug:5930979:Japan Tax Reform Project
    if l_rule_name in ('USE TRANSACTION PERIOD BASIS','PERIOD END BALANCE', 'ENERGY PERIOD END BALANCE','DUAL RATE EVALUATION')
    then
      if g_rule_in.calc_basis ='NBV' or l_rule_name = 'ENERGY PERIOD END BALANCE' then

        FA_CALC_DEPRN_BASIS2_PKG.NON_STRICT_FLAT
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
      end if;
    elsif l_rule_name = 'FLAT RATE EXTENSION'
    then
       FA_CALC_DEPRN_BASIS2_PKG.FLAT_EXTENSION
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
    elsif l_rule_name = 'PERIOD END AVERAGE'
    then
       FA_CALC_DEPRN_BASIS2_PKG.PERIOD_AVERAGE
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
--    elsif l_rule_name = 'YEAR TO DATE AVERAGE'
    elsif l_rule_name in ('YEAR TO DATE AVERAGE', 'YEAR TO DATE AVERAGE WITH HALF YEAR RULE')
    then
      FA_CALC_DEPRN_BASIS2_PKG.YTD_AVERAGE
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
    elsif l_rule_name = 'YEAR END BALANCE WITH POSITIVE REDUCTION AMOUNT'
    then
      FA_CALC_DEPRN_BASIS2_PKG.POSITIVE_REDUCTION
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
    elsif l_rule_name = 'YEAR END BALANCE WITH HALF YEAR RULE'
    then
      FA_CALC_DEPRN_BASIS2_PKG.HALF_YEAR
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
    elsif l_rule_name = 'BEGINNING PERIOD'
    then
      FA_CALC_DEPRN_BASIS2_PKG.BEGINNING_PERIOD
          (
           px_rule_in  => g_rule_in,
           px_rule_out => g_rule_out
          , p_log_level_rec => p_log_level_rec);
    else
      IF (p_log_level_rec.statement_level) THEN
       fa_rx_util_pkg.debug('faxcdb: ' || l_rule_formula);
      END IF;

      execute immediate l_rule_formula;
    end if; -- End of rule procedure call

  end if; -- End of program name is not null

  ----------------------------------------------------------
  -- Apply reduction amount to new adjusted cost
  -----------------------------------------------------------
  if (g_rule_in.calc_basis ='COST'
        and g_rule_in.event_type not in
        ('AFTER_DEPRN2','AMORT_ADJ2','AMORT_ADJ3','UNPLANNED_ADJ','DEPRECIATE_FLAG_ADJ','INITIAL_ADDITION'))
       or
       (g_rule_in.calc_basis ='NBV'
        and g_rule_in.event_type not in
        ('AFTER_DEPRN2','AMORT_ADJ2','AMORT_ADJ3','UNPLANNED_ADJ','INITIAL_ADDITION'))
    then
      g_rule_out.new_adjusted_cost := g_rule_out.new_adjusted_cost
                                          - nvl(g_rule_in.reduction_amount,0);
  end if;

  if p_log_level_rec.statement_level then

      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'reduction_amount',
                       value=> g_rule_in.reduction_amount, p_log_level_rec => p_log_level_rec);
  end if;

  -----------------------------------------------------------
  -- Year End Balance type:
  -- Treatement of Do not gain loss retirement.
  -----------------------------------------------------------

  if l_subtract_ytd_flag='Y' then
    if (g_rule_in.calc_basis = 'NBV') and g_rule_in.recognize_gain_loss like 'N%' then

      if g_rule_in.event_type not in
      ('AFTER_DEPRN','AFTER_DEPRN2','AMORT_ADJ2','AMORT_ADJ3','UNPLANNED_ADJ','INITIAL_ADDITION')
      then

        -- Calcluation of proceeds
        if not CALC_PROCEEDS (
                 p_asset_id          => g_rule_in.asset_id,
                 p_asset_type        => g_rule_in.asset_type,
                 p_book_type_code    => g_rule_in.book_type_code,
                 p_period_counter    => g_rule_in.period_counter,
                 p_mrc_sob_type_code => g_rule_in.mrc_sob_type_code,
                 p_set_of_books_id   => g_rule_in.set_of_books_id,
                 x_ltd_proceeds      => l_ltd_proceeds,
                 x_ytd_proceeds      => l_ytd_proceeds,
                 p_log_level_rec     => p_log_level_rec
                 )
        then
         raise faxcdb_err;
        end if; -- End of call CALC_PROCEEDS

        -- Calculation of retired cost
        if not CALC_RETIRED_COST (
          p_event_type        => g_rule_in.event_type,
          p_asset_id          => g_rule_in.asset_id,
          p_asset_type        => g_rule_in.asset_type,
          p_book_type_code    => g_rule_in.book_type_code,
          p_fiscal_year       => g_rule_in.fiscal_year,
          p_period_num        => g_rule_in.period_num,
          p_adjustment_amount => g_rule_in.adjustment_amount,
          p_ltd_ytd_flag      => 'YTD',
          p_mrc_sob_type_code => g_rule_in.mrc_sob_type_code,
          p_set_of_books_id   => g_rule_in.set_of_books_id,
          x_retired_cost      => l_retired_cost,
          p_log_level_rec     => p_log_level_rec
         )
        then
          raise faxcdb_err;
        end if;

        if p_log_level_rec.statement_level then

          fa_debug_pkg.add(fname=>'faxcdb',
                               element=>'l_retired_cost',
                           value=> l_retired_cost, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(fname=>'faxcdb',
                               element=>'l_ytd_proceeds',
                           value=> l_ytd_proceeds, p_log_level_rec => p_log_level_rec);
        end if;

        g_rule_out.new_adjusted_cost := nvl(g_rule_out.new_adjusted_cost,0) + nvl(l_retired_cost,0)
                              - nvl(l_ytd_proceeds,0);

      end if; -- End of event type
    end if; -- End of calc_basis
  end if; -- End of subtract_ytd_flag

  -----------------------------------------------------------
  -- Set Output variables
  -----------------------------------------------------------
  rule_out.new_adjusted_cost := nvl(g_rule_out.new_adjusted_cost,g_rule_in.old_adjusted_cost);
  rule_out.new_raf := nvl(g_rule_out.new_raf,g_rule_in.old_raf);
  rule_out.new_formula_factor := nvl(g_rule_out.new_formula_factor,g_rule_in.old_formula_factor);
  rule_out.new_deprn_rounding_flag := g_rule_out.new_deprn_rounding_flag;

  -----------------------------------------------------------
  -- Bug4267005: Reinstating validation
  -- Checking raf to make sure that it falls in between 0 and 1
  -----------------------------------------------------------
  if g_rule_in.event_type like 'AMORT_ADJ%' then

     if (rule_out.new_raf < 0 OR rule_out.new_raf > 1) then
      fa_debug_pkg.add('faxcdb', 'Rate adjustment factor ',
                       'Out of valid range', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('faxcdb', 'rule_out.new_raf',
                       rule_out.new_raf, p_log_level_rec => p_log_level_rec);
        FA_SRVR_MSG.ADD_MESSAGE
               (CALLING_FN => l_calling_fn,
                      NAME=>'FA_AMT_RAF_OUT_OF_RANGE', p_log_level_rec => p_log_level_rec);
        raise faxcdb_err;
     end if;
  end if;

  ------------------------------------------------------------
  -- Debug output paramters
  ------------------------------------------------------------

  if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'rule_out.new_adjusted_cost',
                       value=> rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'rule_out.new_raf',
                       value=> rule_out.new_raf, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'rule_out.new_formula_factor',
                       value=> rule_out.new_formula_factor, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'faxcdb',
                       element=>'rule_out.new_deprn_rounding_flag',
                       value=> rule_out.new_deprn_rounding_flag, p_log_level_rec => p_log_level_rec);
  end if;

  -----------------------------------------------------------
  -- Call FA_TRACK_MEMBER_PVT.UPDATE_DEPRN_BASIS
  -----------------------------------------------------------

  IF g_rule_in.tracking_method ='ALLOCATE' and g_rule_in.asset_type='GROUP'
    and (g_rule_in.event_type not in ('AMORT_ADJ3','AFTER_DEPRN','AFTER_DEPRN2','INITIAL_ADDITION')
      or (g_rule_in.event_type ='AFTER_DEPRN' and (g_rule_in.eofy_flag ='Y' or l_period_update_flag='Y')))
  then
    IF NOT fa_track_member_pvt.update_deprn_basis
                   (p_group_rule_in        => g_rule_in,
                    p_apply_reduction_flag => g_rule_in.apply_reduction_flag,
                    p_mode                 => g_rule_in.used_by_adjustment, p_log_level_rec => p_log_level_rec)
    THEN
     if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'faxcdb',
                         element=>'fa_track_member_pvt.update_deprn_basis',
                         value=> 'False', p_log_level_rec => p_log_level_rec);
     end if;

     raise faxcdb_err;
    END IF;
  end if;

  return true;

exception
when faxcdb_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);
when calc_basis_err then
        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>l_calling_fn,
                           element=>'g_rule_in.calc_basis',
                           value=> g_rule_in.calc_basis, p_log_level_rec => p_log_level_rec);
        end if;

        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);

when others then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);
end faxcdb;

------------------------------------------------------------------------------
-- Function: CALC_REDUCTION_AMOUNT
--
-- This function queries the reduction rate's applying amount
--
--  p_asset_id                   : Asset Id
--  p_group_asset_id             : Group Asset Id
--  p_asset_type                 : Asset Type
--  p_book_type_code             : Book Type Code
--  p_period_counter             : Period Counter
--  p_transaction_date           : Processing transaction date
--  p_half_year_rule_flag        : Y- Output first and second half amount
--  x_change_in_cost             : Changed cost for a year with only applying
--                                 reduction rate
--  x_change_in_cost_to_reduce   : Reduction amount of changed cost for a year
--  x_total_change_in_cost       : Total changed cost for a year
--  x_net_proceeds               : 'Proceeds - Cost of Removal' for a year
--                                 with only applying reduction rate.
--  x_net_proceeds_to_reduce     : Reduction amount of
--                                 'Proceeds - Cost of Removal' for a year
--  x_total_net_proceeds         : Total of 'Proceeds - Cost of Removal'
--                                 for a year
--  x_first_half_cost            : Changed cost of 1st half year
--                                 with applying reduction amount
--  x_first_half_cost_to_reduce  : Reduction amount of changed cost of
--                                 1st half year.
--  x_second_half_cost           : Changed cost of 2nd half year
--                                 with applying reduction amount
--  x_second_half_cost_to_reduce : Reduction amount of changed cost of
--                                 2nd half year
-------------------------------------------------------------------------------
FUNCTION CALC_REDUCTION_AMOUNT
  (
    p_asset_id                    IN  NUMBER,
    p_group_asset_id              IN  NUMBER,
    p_asset_type                  IN  VARCHAR2,
    p_book_type_code              IN  VARCHAR2,
    p_period_counter              IN  NUMBER,
    p_transaction_date            IN  DATE,
    p_half_year_rule_flag         IN  VARCHAR2,
    p_mrc_sob_type_code           IN  VARCHAR2,
    p_set_of_books_id             IN  NUMBER,
    x_change_in_cost              OUT NOCOPY NUMBER,
    x_change_in_cost_to_reduce    OUT NOCOPY NUMBER,
    x_total_change_in_cost        OUT NOCOPY NUMBER,
    x_net_proceeds                OUT NOCOPY NUMBER,
    x_net_proceeds_to_reduce      OUT NOCOPY NUMBER,
    x_total_net_proceeds          OUT NOCOPY NUMBER,
    x_first_half_cost             OUT NOCOPY NUMBER,
    x_first_half_cost_to_reduce   OUT NOCOPY NUMBER,
    x_second_half_cost            OUT NOCOPY NUMBER,
    x_second_half_cost_to_reduce  OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

  -- Query start date and end date of fiscal year and period
  cursor C_GET_DATE is
    select fy.start_date                  fy_start_date,
           fy.end_date                    fy_end_date,
           fy.mid_year_date               fy_mid_year_date,
           dp.calendar_period_open_date   cp_start_date,
           dp.calendar_period_close_date  cp_end_date
    from   FA_FISCAL_YEAR fy,
           FA_DEPRN_PERIODS dp,
           FA_BOOK_CONTROLS bc
    where  bc.book_type_code = dp.book_type_code
    and    fy.fiscal_year = dp.fiscal_year
    and    bc.fiscal_year_name = fy.fiscal_year_name
    and    dp.book_type_code= p_book_type_code
    and    dp.period_counter = p_period_counter;

  -- Query start date and end date of fiscal year and period for MRC
  cursor C_GET_DATE_M is
    select fy.start_date                  fy_start_date,
           fy.end_date                    fy_end_date,
           fy.mid_year_date               fy_mid_year_date,
           dp.calendar_period_open_date   cp_start_date,
           dp.calendar_period_close_date  cp_end_date
    from   FA_FISCAL_YEAR fy,
           FA_MC_DEPRN_PERIODS dp,
           FA_MC_BOOK_CONTROLS mbc,
           FA_BOOK_CONTROLS BC
    where  bc.book_type_code = dp.book_type_code
    and    mbc.book_type_code = dp.book_type_code
    and    mbc.set_of_books_id = p_set_of_books_id
    and    fy.fiscal_year = dp.fiscal_year
    and    bc.fiscal_year_name = fy.fiscal_year_name
    and    dp.book_type_code= p_book_type_code
    and    dp.period_counter = p_period_counter
    and    dp.set_of_books_id = p_set_of_books_id;

  ----------------------------
  -- For Non MRC
  ---------------------------

  ----------------------------------------------------------------------
  -- For member assets and standalone asset
  ----------------------------------------------------------------------

  -- Query changed cost and proceeds wiht applying reduction rate during a year or half_year

  cursor C_REDUCE_COST_AMOUNT  (t_start_date  date,
                                t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) change_in_cost,
           sum((BK2.COST - nvl(BK1.COST,0))*nvl(BK2.REDUCTION_RATE,0))
                                                                   change_in_cost_to_reduce,
           sum(nvl(RET.NBV_RETIRED,0)) net_proceeds,
           sum((nvl(RET.NBV_RETIRED,0))*nvl(BK2.REDUCTION_RATE,0))  net_proceeds_to_reduce
    from   FA_BOOKS               BK1,
           FA_BOOKS               BK2,
           FA_RETIREMENTS         RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date
    and    nvl(BK2.REDUCTION_RATE,0) >0;

  -- Query all changed costs and proceeds during a year

  cursor C_FY_TOTAL_COST_AMOUNT  (t_start_date  date,
                                  t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) total_change_in_cost,
           sum(nvl(RET.NBV_RETIRED,0)) total_net_proceeds
    from   FA_BOOKS               BK1,
           FA_BOOKS               BK2,
           FA_RETIREMENTS         RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date;

  ----------------------------------------------------------------------------
  -- For Group Assets
  ----------------------------------------------------------------------------

  -- Query changed cost and proceeds wiht applying reduction rate during a year or half_year

  cursor GP_REDUCE_COST_AMOUNT  (t_start_date  date,
                                 t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) change_in_cost,
           sum((BK2.COST - nvl(BK1.COST,0))*nvl(BK3.REDUCTION_RATE,0))
                                                                   change_in_cost_to_reduce,
           sum(nvl(RET.NBV_RETIRED,0)) net_proceeds,
           sum((nvl(RET.NBV_RETIRED,0))*nvl(BK3.REDUCTION_RATE,0)) net_proceeds_to_reduce
    from   FA_BOOKS               BK1,
           FA_BOOKS               BK2,
           FA_BOOKS               BK3,
           FA_RETIREMENTS         RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = BK3.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date
    and    nvl(BK3.REDUCTION_RATE,0) >0
    and    exists (select BK3.ASSET_ID
                   from FA_BOOKS BK4
                   where BK3.ASSET_ID = BK4.ASSET_ID and
                         BK4.BOOK_TYPE_CODE = p_book_type_code and
                         BK4.GROUP_ASSET_ID = p_asset_id and
                         BK4. DATE_INEFFECTIVE is null);

  -- Query all changed costs and proceeds during a year

  cursor GP_FY_TOTAL_COST_AMOUNT  (t_start_date  date,
                                   t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) total_change_in_cost,
           sum(nvl(RET.NBV_RETIRED,0)) total_net_proceeds
    from   FA_BOOKS               BK1,
           FA_BOOKS               BK2,
           FA_BOOKS               BK3,
           FA_RETIREMENTS         RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = BK3.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date
    and    exists (select BK3.ASSET_ID
                   from FA_BOOKS BK4
                   where BK3.ASSET_ID = BK4.ASSET_ID and
                         BK4.BOOK_TYPE_CODE = p_book_type_code and
                         BK4.GROUP_ASSET_ID = p_asset_id and
                         BK4. DATE_INEFFECTIVE is null);

  --------------------------------------------------------------
  -- For MRC
  --------------------------------------------------------------

  ----------------------------------------------------------------------
  -- For member assets and standalone asset
  ----------------------------------------------------------------------

  -- Query changed cost and proceeds wiht applying reduction rate during a year or half_year

  cursor C_REDUCE_COST_AMOUNT_M  (t_start_date  date,
                                  t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) change_in_cost,
           sum((BK2.COST - nvl(BK1.COST,0))*nvl(BK2.REDUCTION_RATE,0))
                                                                   change_in_cost_to_reduce,
           sum(nvl(RET.NBV_RETIRED,0)) net_proceeds,
           sum((nvl(RET.NBV_RETIRED,0))*nvl(BK2.REDUCTION_RATE,0))  net_proceeds_to_reduce
    from   FA_MC_BOOKS         BK1,
           FA_MC_BOOKS         BK2,
           FA_MC_RETIREMENTS  RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    BK1.set_of_books_id = p_set_of_books_id
    and    BK2.set_of_books_id = p_set_of_books_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date
    and    nvl(BK2.REDUCTION_RATE,0) >0;

  -- Query all changed costs and proceeds during a year

  cursor C_FY_TOTAL_COST_AMOUNT_M  (t_start_date  date,
                                    t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) total_change_in_cost,
           sum(nvl(RET.NBV_RETIRED,0)) total_net_proceeds
    from   FA_MC_BOOKS         BK1,
           FA_MC_BOOKS         BK2,
           FA_MC_RETIREMENTS   RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    BK1.set_of_books_id = p_set_of_books_id
    and    BK2.set_of_books_id = p_set_of_books_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date;

  ----------------------------------------------------------------------------
  -- For Group Assets
  ----------------------------------------------------------------------------

  -- Query changed cost and proceeds wiht applying reduction rate during a year or half_year

  cursor GP_REDUCE_COST_AMOUNT_M  (t_start_date  date,
                                   t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) change_in_cost,
           sum((BK2.COST - nvl(BK1.COST,0))*nvl(BK3.REDUCTION_RATE,0))
                                                                   change_in_cost_to_reduce,
           sum(nvl(RET.NBV_RETIRED,0)) net_proceeds,
           sum((nvl(RET.NBV_RETIRED,0))*nvl(BK3.REDUCTION_RATE,0))  net_proceeds_to_reduce
    from   FA_MC_BOOKS         BK1,
           FA_MC_BOOKS         BK2,
           FA_MC_BOOKS         BK3,
           FA_MC_RETIREMENTS  RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = BK3.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    BK1.set_of_books_id = p_set_of_books_id
    and    BK2.set_of_books_id = p_set_of_books_id
    and    BK3.set_of_books_id = p_set_of_books_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date
    and    nvl(BK3.REDUCTION_RATE,0) >0
    and    exists (select BK3.ASSET_ID
                   from FA_MC_BOOKS BK4
                   where BK3.ASSET_ID = BK4.ASSET_ID and
                         BK4.BOOK_TYPE_CODE = p_book_type_code and
                         BK4.GROUP_ASSET_ID = p_asset_id and
                         BK4.DATE_INEFFECTIVE is null and
                         BK4.set_of_books_id = p_set_of_books_id);

  -- Query all changed costs and proceeds during a year

  cursor GP_FY_TOTAL_COST_AMOUNT_M  (t_start_date  date,
                                     t_end_date    date)
  is
    select sum(BK2.COST - nvl(BK1.COST,0)) total_change_in_cost,
           sum(nvl(RET.NBV_RETIRED,0)) total_net_proceeds
    from   FA_MC_BOOKS         BK1,
           FA_MC_BOOKS         BK2,
           FA_MC_BOOKS         BK3,
           FA_MC_RETIREMENTS   RET,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = BK3.TRANSACTION_HEADER_ID_IN
    and    TH.MEMBER_TRANSACTION_HEADER_ID = RET.TRANSACTION_HEADER_ID_IN(+)
    and    BK2.ASSET_ID= p_asset_id
    and    BK2.BOOK_TYPE_CODE = p_book_type_code
    and    BK1.set_of_books_id = p_set_of_books_id
    and    BK2.set_of_books_id = p_set_of_books_id
    and    BK3.set_of_books_id = p_set_of_books_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    TH.TRANSACTION_DATE_ENTERED >= t_start_date
    and    TH.TRANSACTION_DATE_ENTERED <= t_end_date
    and    exists (select BK3.ASSET_ID
                   from FA_MC_BOOKS BK4
                   where BK3.ASSET_ID = BK4.ASSET_ID and
                         BK4.BOOK_TYPE_CODE = p_book_type_code and
                         BK4.GROUP_ASSET_ID = p_asset_id and
                         BK4.DATE_INEFFECTIVE is null and
                         BK4.set_of_books_id = p_set_of_books_id);

  -- Query member's reduction rate in this transaction
  cursor C_REDUCTION_RATE (l_transaction_header_id  number)
  is
    select nvl(REDUCTION_RATE,0)
    from   FA_BOOKS
    where  TRANSACTION_HEADER_ID_IN = l_transaction_header_id;

   -- For MRC
  cursor C_REDUCTION_RATE_M (l_transaction_header_id number)
  is
    select nvl(REDUCTION_RATE,0)
    from   FA_MC_BOOKS
    where  TRANSACTION_HEADER_ID_IN = l_transaction_header_id
    and    set_of_books_id = p_set_of_books_id;

  ------------------------------
  -- Check transaction existing
  ------------------------------
  cursor C_CHK_TRANSACTION (l_transaction_header_id number)
  is
   select count('Y')
   from   FA_TRANSACTION_HEADERS TH
   where  TH.TRANSACTION_HEADER_ID = l_transaction_header_id
   and    TH.ASSET_ID = p_asset_id
   and    TH.BOOK_TYPE_CODE = p_book_type_code;

  --
  l_fy_start_date     date;  -- Fiscal year start date
  l_fy_end_date       date;  -- Fiscal year end date
  l_fy_mid_year_date  date;  -- Fiscal year mid year date
  l_cp_start_date     date;  -- Period start date
  l_cp_end_date       date;  -- Period end date
  l_first_end_date    date;  -- First half year end date
  l_transaction_date date;  -- Processing Transaction Date

  l_change_in_cost              NUMBER := NULL;
  l_change_in_cost_to_reduce    NUMBER := NULL;
  l_total_change_in_cost        NUMBER := NULL;
  l_net_proceeds                NUMBER := NULL;
  l_net_proceeds_to_reduce      NUMBER := NULL;
  l_total_net_proceeds          NUMBER := NULL;
  l_first_half_cost             NUMBER := NULL;
  l_first_half_cost_to_reduce   NUMBER := NULL;
  l_second_half_cost            NUMBER := NULL;
  l_second_half_cost_to_reduce  NUMBER := NULL;

  l_dummy_proceeds              NUMBER; -- Dummy
  l_dummy_to_reduce             NUMBER; -- Dummy
  l_chk_count                   NUMBER := NULL;

  l_group_cost_accounting_flag  VARCHAR2(1);

  l_calling_fn                  VARCHAR2(50) := 'fa_calc_deprn_basis1_pkg.CALC_REDUCITON_AMOUNT';

  no_mid_date_err               exception;
  calc_reduction_amount_err     exception;

begin

  if (p_mrc_sob_type_code <> 'R') then  -- Not MRC

    -- Get Fiscal Year and Period start and End date

    OPEN C_GET_DATE;
    Fetch C_GET_DATE into l_fy_start_date,l_fy_end_date, l_fy_mid_year_date,
                     l_cp_start_date,l_cp_end_date;

    if(C_GET_DATE%NOTFOUND)then
        if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
           raise no_mid_date_err;
        end if;
--bug fix 5005592 starts
        begin
         SELECT cp.start_date,
                cp.end_date,
                fy.start_date,
                fy.end_date,
                fy.mid_year_date
         INTO l_cp_start_date,
              l_cp_end_date,
              l_fy_start_date,
              l_fy_end_date,
              l_fy_mid_year_date
         FROM fa_calendar_periods cp,
              fa_fiscal_year fy,
              fa_calendar_types cal_ty
         WHERE fy.fiscal_year = floor(p_period_counter/cal_ty.NUMBER_PER_FISCAL_YEAR)
          AND fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
          AND cal_ty.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
          AND cp.calendar_type = cal_ty.calendar_type
          AND cp.start_date BETWEEN fy.start_date AND fy.end_date
          AND cp.end_date BETWEEN fy.start_date AND fy.end_date
          and period_num = mod(p_period_counter,cal_ty.NUMBER_PER_FISCAL_YEAR);
        exception
           when others then
             raise no_mid_date_err;
        end;
    end if;
--bug fix ends 5005592
    CLOSE C_GET_DATE;
    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_fy_start_date(1)',
                       value=> l_fy_start_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_fy_end_date(1)',
                       value=> l_fy_end_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_fy_mid_year_date(1)',
                       value=> l_fy_mid_year_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_cp_start_date(1)',
                       value=> l_cp_start_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_cp_end_date(1)',
                       value=> l_cp_end_date);
    end if;

    -- If user will use half year rule and doesn't setup mid year date,
    -- the error is raised.

    If p_half_year_rule_flag='Y' and l_fy_mid_year_date is null then
      raise no_mid_date_err;
    end if;

    -- Set transaction Date
    if p_transaction_date is not null then
      l_transaction_date:= p_transaction_date;
    else
      l_transaction_date:= l_cp_end_date;
    end if;

    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_transaction_date(1)',
                       value=> l_transaction_date);
    end if;

    -- Group asset
    if p_asset_type ='GROUP' then

        -- Get the changed cost and proceeds with applying reduction rate
        -- and those reduction amounts for a year

        open GP_REDUCE_COST_AMOUNT(l_fy_start_date,l_transaction_date);
        fetch GP_REDUCE_COST_AMOUNT into
             l_change_in_cost,l_change_in_cost_to_reduce,
             l_net_proceeds, l_net_proceeds_to_reduce;
        close GP_REDUCE_COST_AMOUNT;

        -- Get the all changed cost and proceeds for a year

        open GP_FY_TOTAL_COST_AMOUNT(l_fy_start_date,l_transaction_date);
        fetch GP_FY_TOTAL_COST_AMOUNT
                into l_total_change_in_cost,l_total_net_proceeds;
        close GP_FY_TOTAL_COST_AMOUNT;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost(1)',
                           value=> l_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost_to_reduce(1)',
                           value=> l_change_in_cost_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_change_in_cost(1)',
                           value=> l_total_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds(1)',
                           value=> l_net_proceeds);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds_to_reduce(1)',
                           value=> l_net_proceeds_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_net_proceeds(1)',
                           value=> l_total_net_proceeds);
        end if;

      else
       -- Individual assets
       -- member assets

        -- Get the changed cost and proceeds with applying reduction rate
        -- and those reduction amounts for a year

        open C_REDUCE_COST_AMOUNT(l_fy_start_date,l_transaction_date);
        fetch C_REDUCE_COST_AMOUNT into
             l_change_in_cost,l_change_in_cost_to_reduce,
             l_net_proceeds, l_net_proceeds_to_reduce;
        close C_REDUCE_COST_AMOUNT;

        -- Get the all changed cost and proceeds for a year

        open C_FY_TOTAL_COST_AMOUNT(l_fy_start_date,l_transaction_date);
        fetch C_FY_TOTAL_COST_AMOUNT
                into l_total_change_in_cost,l_total_net_proceeds;
        close C_FY_TOTAL_COST_AMOUNT;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost(2)',
                           value=> l_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost_to_reduce(2)',
                           value=> l_change_in_cost_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_change_in_cost(2)',
                           value=> l_total_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds(2)',
                           value=> l_net_proceeds);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds_to_reduce(2)',
                           value=> l_net_proceeds_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_net_proceeds(2)',
                           value=> l_total_net_proceeds);
        end if;

    end if; -- End member/group and standalone assets condition


  else  -- MRC

    -- Get Fiscal Year and Period start and End date

    OPEN C_GET_DATE_M;
    Fetch C_GET_DATE_M into l_fy_start_date,l_fy_end_date, l_fy_mid_year_date,
                     l_cp_start_date,l_cp_end_date;
    if(C_GET_DATE_M%NOTFOUND)then
        if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
           raise no_mid_date_err;
        end if;
--bug fix 5005592 starts
        begin
         SELECT cp.start_date,
                cp.end_date,
                fy.start_date,
                fy.end_date,
                fy.mid_year_date
         INTO l_cp_start_date,
              l_cp_end_date,
              l_fy_start_date,
              l_fy_end_date,
              l_fy_mid_year_date
         FROM fa_calendar_periods cp,
              fa_fiscal_year fy,
              fa_calendar_types cal_ty
         WHERE fy.fiscal_year = floor(p_period_counter/cal_ty.NUMBER_PER_FISCAL_YEAR)
          AND fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
          AND cal_ty.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
          AND cp.calendar_type = cal_ty.calendar_type
          AND cp.start_date BETWEEN fy.start_date AND fy.end_date
          AND cp.end_date BETWEEN fy.start_date AND fy.end_date
          and period_num = mod(p_period_counter,cal_ty.NUMBER_PER_FISCAL_YEAR);
        exception
           when others then
             raise no_mid_date_err;
        end;
    end if;
--bug fix 5005592 ends

    Close C_GET_DATE_M;
    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_fy_start_date(2)',
                       value=> l_fy_start_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_fy_end_date(2)',
                       value=> l_fy_end_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_fy_mid_year_date(2)',
                       value=> l_fy_mid_year_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_cp_start_date(2)',
                       value=> l_cp_start_date);
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_cp_end_date(2)',
                       value=> l_cp_end_date);
    end if;

    -- If user will use half year rule and doesn't setup mid year date,
    -- the error is raised.

    If p_half_year_rule_flag='Y' and l_fy_mid_year_date is null then
      raise no_mid_date_err;
    end if;

    -- Set transaction Date
    if p_transaction_date is not null then
      l_transaction_date:= p_transaction_date;
    else
      l_transaction_date:= l_cp_end_date;
    end if;

    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'calc_reduction_amount',
                       element=>'l_transaction_date(2)',
                       value=> l_transaction_date);
    end if;

    -- Group asset
    if p_asset_type ='GROUP' then

        -- Get the changed cost and proceeds with applying reduction rate
        -- and those reduction amounts for a year

        open GP_REDUCE_COST_AMOUNT_M(l_fy_start_date,l_transaction_date);
        fetch GP_REDUCE_COST_AMOUNT_M into
             l_change_in_cost,l_change_in_cost_to_reduce,
             l_net_proceeds, l_net_proceeds_to_reduce;
        close GP_REDUCE_COST_AMOUNT_M;

        -- Get the all changed cost and proceeds for a year

        open GP_FY_TOTAL_COST_AMOUNT_M(l_fy_start_date,l_transaction_date);
        fetch GP_FY_TOTAL_COST_AMOUNT_M
                into l_total_change_in_cost,l_total_net_proceeds;
        close GP_FY_TOTAL_COST_AMOUNT_M;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost(3)',
                           value=> l_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost_to_reduce(3)',
                           value=> l_change_in_cost_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_change_in_cost(3)',
                           value=> l_total_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds(3)',
                           value=> l_net_proceeds);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds_to_reduce(3)',
                           value=> l_net_proceeds_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_net_proceeds(3)',
                           value=> l_total_net_proceeds);
        end if;

      else
        -- Individual assets
        -- member assets

        -- Get the changed cost and proceeds with applying reduction rate
        -- and those reduction amounts for a year

        open C_REDUCE_COST_AMOUNT_M(l_fy_start_date,l_transaction_date);
        fetch C_REDUCE_COST_AMOUNT_M into
             l_change_in_cost,l_change_in_cost_to_reduce,
             l_net_proceeds, l_net_proceeds_to_reduce;
        close C_REDUCE_COST_AMOUNT_M;

        -- Get the all changed cost and proceeds for a year

        open C_FY_TOTAL_COST_AMOUNT_M(l_fy_start_date,l_transaction_date);
        fetch C_FY_TOTAL_COST_AMOUNT_M
                into l_total_change_in_cost,l_total_net_proceeds;
        close C_FY_TOTAL_COST_AMOUNT_M;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost(4)',
                           value=> l_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_change_in_cost_to_reduce(4)',
                           value=> l_change_in_cost_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_change_in_cost(4)',
                           value=> l_total_change_in_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds(4)',
                           value=> l_net_proceeds);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_net_proceeds_to_reduce(4)',
                           value=> l_net_proceeds_to_reduce);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_total_net_proceeds(4)',
                           value=> l_total_net_proceeds);
        end if;

    end if; -- End member/group and standalone assets condition

  end if; -- End of MRC

  -- If Half year rule is applied, get the amounts of 1st and 2nd half year
  If p_half_year_rule_flag='Y' then

    -- Set First half year's end date for query and set 2nd half year's amount
     /* Bug #6776576 - Added one more condition to check p_asset_type <> 'GROUP'
     as this rule should be applied to member asset only */
     If (l_transaction_date < l_fy_mid_year_date) and (p_asset_type <> 'GROUP')  then -- set first half end date
      l_first_end_date := l_transaction_date;

      -- Set 2nd half year's amount to 0
      l_second_half_cost := 0;
      l_second_half_cost_to_reduce := 0;
    else
      l_first_end_date := l_fy_mid_year_date - 1;

      if (p_mrc_sob_type_code <> 'R') then  -- Not MRC

        if p_asset_type ='GROUP' then

          --Get 2nd half year's amount.
/* For bug 6776576, changed second parameter from l_transaction_date to l_fy_end_date */
          open GP_REDUCE_COST_AMOUNT (l_fy_mid_year_date,l_fy_end_date);
          fetch GP_REDUCE_COST_AMOUNT
            into l_second_half_cost,l_second_half_cost_to_reduce,l_dummy_proceeds,l_dummy_to_reduce;
          close GP_REDUCE_COST_AMOUNT;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost(1)',
                             value=> l_second_half_cost);
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost_to_reduce(1)',
                             value=> l_second_half_cost_to_reduce);
          end if;

        else
          -- Individual assets
          -- member assets

          --Get 2nd half year's amount.
          open C_REDUCE_COST_AMOUNT (l_fy_mid_year_date,l_transaction_date);
          fetch C_REDUCE_COST_AMOUNT
            into l_second_half_cost,l_second_half_cost_to_reduce,l_dummy_proceeds,l_dummy_to_reduce;
          close C_REDUCE_COST_AMOUNT;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost(2)',
                             value=> l_second_half_cost);
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost_to_reduce(2)',
                             value=> l_second_half_cost_to_reduce);
          end if;

        end if;

      else -- MRC

        -- Group asset
        if p_asset_type ='GROUP' then

          --Get 2nd half year's amount.
          /* For bug 6776576, changed second parameter from l_transaction_date to l_fy_end_date */
           /* Fixed one more issue. Earliar cursor GP_REDUCE_COST_AMOUNT was used in Open  */
           open GP_REDUCE_COST_AMOUNT_M(l_fy_mid_year_date,l_fy_end_date);
            fetch GP_REDUCE_COST_AMOUNT_M
            into l_second_half_cost,l_second_half_cost_to_reduce,l_dummy_proceeds,l_dummy_to_reduce;
          close GP_REDUCE_COST_AMOUNT_M;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost(3)',
                             value=> l_second_half_cost);
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost_to_reduce(3)',
                             value=> l_second_half_cost_to_reduce);
          end if;

        else
          -- Individual assets
          -- member assets

          --Get 2nd half year's amount.
          open C_REDUCE_COST_AMOUNT_M (l_fy_mid_year_date,l_transaction_date);
          fetch C_REDUCE_COST_AMOUNT_M
            into l_second_half_cost,l_second_half_cost_to_reduce,l_dummy_proceeds,l_dummy_to_reduce;
          close C_REDUCE_COST_AMOUNT_M;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost(4)',
                             value=> l_second_half_cost);
            fa_debug_pkg.add(fname=>'calc_reduction_amount',
                               element=>'l_second_half_cost_to_reduce(4)',
                             value=> l_second_half_cost_to_reduce);
          end if;

        end if; -- End member/group and standalone assets condition

      end if; --End of MRC

    end if;  -- End set first half end date

    -- Set 1st half year amount
    if (p_mrc_sob_type_code <> 'R') then  -- Not MRC

      -- Group assets
      if p_asset_type ='GROUP' then

        -- Get changed cost and reduction amount during 1st half year
        open GP_REDUCE_COST_AMOUNT (l_fy_start_date, l_first_end_date);
        fetch GP_REDUCE_COST_AMOUNT into l_first_half_cost, l_first_half_cost_to_reduce,
                                         l_dummy_proceeds,l_dummy_to_reduce;
        close GP_REDUCE_COST_AMOUNT;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost(1)',
                           value=> l_first_half_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost_to_reduce(1)',
                           value=> l_first_half_cost_to_reduce);
        end if;

      else
        -- Individual assets
        -- member assets

        -- Get changed cost and reduction amount during 1st half year
        open C_REDUCE_COST_AMOUNT (l_fy_start_date, l_first_end_date);
        fetch C_REDUCE_COST_AMOUNT into l_first_half_cost, l_first_half_cost_to_reduce,
                                         l_dummy_proceeds,l_dummy_to_reduce;
        close C_REDUCE_COST_AMOUNT;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost(2)',
                             value=> l_first_half_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost_to_reduce(2)',
                             value=> l_first_half_cost_to_reduce);
        end if;

      end if;

    else  -- MRC

      -- Group assets
      if l_group_cost_accounting_flag <>'Y'
          and p_asset_type ='GROUP' then

        -- Get changed cost and reduction amount during 1st half year
        open GP_REDUCE_COST_AMOUNT_M (l_fy_start_date, l_first_end_date);
        fetch GP_REDUCE_COST_AMOUNT_M into l_first_half_cost, l_first_half_cost_to_reduce,
                                         l_dummy_proceeds,l_dummy_to_reduce;
        close GP_REDUCE_COST_AMOUNT_M;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost(3)',
                           value=> l_first_half_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost_to_reduce(3)',
                           value=> l_first_half_cost_to_reduce);
        end if;

      else -- For member and standalone assets

        -- Get changed cost and reduction amount during 1st half year
        open C_REDUCE_COST_AMOUNT_M (l_fy_start_date, l_first_end_date);
        fetch C_REDUCE_COST_AMOUNT_M into l_first_half_cost, l_first_half_cost_to_reduce,
                                         l_dummy_proceeds,l_dummy_to_reduce;
        close C_REDUCE_COST_AMOUNT_M;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost(4)',
                             value=> l_first_half_cost);
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'l_first_half_cost_to_reduce(4)',
                           value=> l_first_half_cost_to_reduce);
        end if;

      end if;

    end if; -- End of MRC

  end if; -- End Half year rule is applied

  ------------------------------------------------------
  -- Add this transaction's amount to queried variables
  -- for Group asset
  ------------------------------------------------------
  if fa_calc_deprn_basis1_pkg.g_rule_in.transaction_date_entered >= l_fy_start_date
    and fa_calc_deprn_basis1_pkg.g_rule_in.transaction_date_entered <= nvl(l_transaction_date,l_fy_end_date)
    and not (fa_calc_deprn_basis1_pkg.g_rule_in.asset_type <>'GROUP'
             and fa_calc_deprn_basis1_pkg.g_rule_in.tracking_method='ALLOCATE')
  then

    -- Check whether this transaction is existing or not.
    OPEN  C_CHK_TRANSACTION (fa_calc_deprn_basis1_pkg.g_rule_in.transaction_header_id);
    FETCH C_CHK_TRANSACTION into l_chk_count;
    CLOSE C_CHK_TRANSACTION;

    if nvl(l_chk_count,0) = 0 then

      -- Get member entered reduction rate.
      if p_asset_type ='GROUP' then
        if (p_mrc_sob_type_code <> 'R') then
          OPEN  C_REDUCTION_RATE(g_rule_in.member_transaction_header_id);
          FETCH C_REDUCTION_RATE into g_rule_in.reduction_rate;
          CLOSE C_REDUCTION_RATE;
        else  -- Not MRC
          OPEN  C_REDUCTION_RATE_M(g_rule_in.member_transaction_header_id);
          FETCH C_REDUCTION_RATE_M into g_rule_in.reduction_rate;
          CLOSE C_REDUCTION_RATE_M;
        end if; -- End of MRC

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'calc_reduction_amount',
                           element=>'updated reduction_rate',
                             value=> fa_calc_deprn_basis1_pkg.g_rule_in.reduction_rate, p_log_level_rec => p_log_level_rec);
        end if;
      end if;  -- End of Group

      if g_rule_in.event_type='RETIREMENT' then
        x_total_change_in_cost := nvl(l_total_change_in_cost,0);
        x_total_net_proceeds
          := nvl(l_total_net_proceeds,0)
               + nvl(g_rule_in.nbv_retired,0);
      else
        x_total_change_in_cost
          := nvl(l_total_change_in_cost,0) + nvl(g_rule_in.adjustment_amount,0);
        x_total_net_proceeds:= nvl(l_total_net_proceeds,0) + nvl(g_rule_in.member_proceeds,0);
      end if;

      if nvl(g_rule_in.reduction_rate,0) <> 0 then

        if g_rule_in.event_type='RETIREMENT' then
          x_change_in_cost := nvl(l_change_in_cost,0);
          x_change_in_cost_to_reduce := nvl(l_change_in_cost_to_reduce,0);
          x_net_proceeds
            := nvl(l_net_proceeds,0)
                  + nvl(g_rule_in.nbv_retired,0);
          x_net_proceeds_to_reduce
           := nvl(l_net_proceeds_to_reduce,0)
                + nvl(g_rule_in.nbv_retired,0) *nvl(g_rule_in.reduction_rate,0);

        else

          x_change_in_cost
           := nvl(l_change_in_cost,0) + nvl(g_rule_in.adjustment_amount,0);
          x_change_in_cost_to_reduce
           := nvl(l_change_in_cost_to_reduce,0) + nvl(g_rule_in.adjustment_amount,0)*nvl(g_rule_in.reduction_rate,0);
          x_net_proceeds
            := nvl(l_net_proceeds,0) + nvl(g_rule_in.member_proceeds,0);
          x_net_proceeds_to_reduce
           := nvl(l_net_proceeds_to_reduce,0)
              + nvl(g_rule_in.member_proceeds,0) *nvl(g_rule_in.reduction_rate,0);
        end if; -- event type

        if g_rule_in.transaction_date_entered < l_fy_mid_year_date
        then  -- First half year

          if g_rule_in.event_type ='RETIREMENT'
             or (g_rule_in.event_type ='AMORT_ADJ'
                 and nvl(g_rule_in.member_transaction_type_code,'NULL') like '%RETIREMENT'
                 and g_rule_in.asset_type ='GROUP')
          then
            x_first_half_cost := nvl(l_first_half_cost,0) ;
            x_first_half_cost_to_reduce := nvl(l_first_half_cost_to_reduce,0);
          else
            x_first_half_cost
              := nvl(l_first_half_cost,0) + nvl(g_rule_in.adjustment_amount,0);
            x_first_half_cost_to_reduce
              := nvl(l_first_half_cost_to_reduce,0)+ nvl(g_rule_in.adjustment_amount,0)*nvl(g_rule_in.reduction_rate,0);
          end if;

          -- When transaction is 1st half year, the amounts of 2nd half year are not changed.
          x_second_half_cost             := nvl(l_second_half_cost,0);
          x_second_half_cost_to_reduce   := nvl(l_second_half_cost_to_reduce,0);

        else  -- Second half year
          if g_rule_in.event_type ='RETIREMENT'
             or (g_rule_in.event_type ='AMORT_ADJ'
                 and nvl(g_rule_in.member_transaction_type_code,'NULL') like '%RETIREMENT'
                 and g_rule_in.asset_type ='GROUP')
          then
           x_second_half_cost := nvl(l_second_half_cost,0);
           x_second_half_cost_to_reduce:= nvl(l_second_half_cost_to_reduce,0);
          else
           x_second_half_cost
             := nvl(l_second_half_cost,0) + nvl(g_rule_in.adjustment_amount,0);
           x_second_half_cost_to_reduce
             := nvl(l_second_half_cost_to_reduce,0)
                     + nvl(g_rule_in.adjustment_amount,0) *nvl(g_rule_in.reduction_rate,0);
          end if; -- event type

          -- When transaction is 2nd half year, the amounts of 1st half year are not changed.
          x_first_half_cost              := nvl(l_first_half_cost,0);
          x_first_half_cost_to_reduce    := nvl(l_first_half_cost_to_reduce,0);

        end if; -- End first half and second half year

      else -- Reduction rate is null

        x_change_in_cost               := nvl(l_change_in_cost,0);
        x_change_in_cost_to_reduce     := nvl(l_change_in_cost_to_reduce,0);
        x_net_proceeds                 := nvl(l_net_proceeds,0);
        x_net_proceeds_to_reduce       := nvl(l_net_proceeds_to_reduce,0);
        x_first_half_cost              := nvl(l_first_half_cost,0);
        x_first_half_cost_to_reduce    := nvl(l_first_half_cost_to_reduce,0);
        x_second_half_cost             := nvl(l_second_half_cost,0);
        x_second_half_cost_to_reduce   := nvl(l_second_half_cost_to_reduce,0);

      end if; -- Reduction rate is not null

    else -- l_chk_count >0

      x_change_in_cost               := nvl(l_change_in_cost,0);
      x_change_in_cost_to_reduce     := nvl(l_change_in_cost_to_reduce,0);
      x_net_proceeds                 := nvl(l_net_proceeds,0);
      x_net_proceeds_to_reduce       := nvl(l_net_proceeds_to_reduce,0);
      x_first_half_cost              := nvl(l_first_half_cost,0);
      x_first_half_cost_to_reduce    := nvl(l_first_half_cost_to_reduce,0);
      x_second_half_cost             := nvl(l_second_half_cost,0);
      x_second_half_cost_to_reduce   := nvl(l_second_half_cost_to_reduce,0);

    end if; -- End of l_chk_count

  else
     x_total_change_in_cost         := nvl(l_total_change_in_cost,0);
     x_total_net_proceeds           := nvl(l_total_net_proceeds,0);
     x_change_in_cost               := nvl(l_change_in_cost,0);
     x_change_in_cost_to_reduce     := nvl(l_change_in_cost_to_reduce,0);
     x_net_proceeds                 := nvl(l_net_proceeds,0);
     x_net_proceeds_to_reduce       := nvl(l_net_proceeds_to_reduce,0);
     x_first_half_cost              := nvl(l_first_half_cost,0);
     x_first_half_cost_to_reduce    := nvl(l_first_half_cost_to_reduce,0);
     x_second_half_cost             := nvl(l_second_half_cost,0);
     x_second_half_cost_to_reduce   := nvl(l_second_half_cost_to_reduce,0);

  end if; -- Include this transaction to FY total

  return true;

exception
  when no_mid_date_err then
    fa_srvr_msg.add_message (
                calling_fn => l_calling_fn,
                name => 'FA_NO_MID_YEAR_DATE',
                translate => FALSE
                , p_log_level_rec => p_log_level_rec);
    return (FALSE);

  when calc_reduction_amount_err then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);

end CALC_REDUCTION_AMOUNT;


--------------------------------------------------------------
-- Function: GET_REC_COST
--
-- This function is to get recoverable cost and salvage value
-- at the period of parameter's period counter
--
-- p_asset_id                  : Asset Id
-- p_book_type_code            : Book Type Code
-- p_fiscal_year               : Fiscal Year
-- p_period_num                : Period Number
-- p_asset_type                : Asset Type
-- p_recoverable_cost          : Recoverable Cost at p_transaction_date_entered
--                               (Set only when p_transaction_date_entered is set)
-- p_salvage_value             : Salvage value  at p_transaction_date_entered
--                               (Set only when p_transaction_date_entered is set)
-- p_transaction_date_entered  : Transaction Date Entered (INITIAL_ADDITION only)
-- p_mrc_sob_type_code         : MRC Set of Books type code
-- x_recoverable_cost          : Recoverable cost at the parameter's period
-- x_salvage_value             : Salvage value at the parameter's period
-------------------------------------------------------------
FUNCTION GET_REC_COST
  (
    p_asset_id                 IN  NUMBER,
    p_book_type_code           IN  VARCHAR2,
    p_fiscal_year              IN  NUMBER,
    p_period_num               IN  NUMBER,
    p_asset_type               IN  VARCHAR2,
    p_recoverable_cost         IN  NUMBER,
    p_salvage_value            IN  NUMBER,
    p_transaction_date_entered IN  DATE,
    p_mrc_sob_type_code        IN  VARCHAR2,
    p_set_of_books_id          IN  NUMBER,
    x_recoverable_cost         OUT NOCOPY NUMBER,
    x_salvage_value            OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

  l_period_close_date      date;

  -- Get Recoverable cost for Member and Standalone asset
  cursor C_GET_REC_COST is
    select sum(BK2.RECOVERABLE_COST -nvl(BK1.RECOVERABLE_COST,0)) recoverable_cost,
           sum(BK2.SALVAGE_VALUE -nvl(BK1.SALVAGE_VALUE,0)) salvage_value
    from   FA_BOOKS BK1,
           FA_BOOKS BK2,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.ASSET_ID = p_asset_id
    and    TH.BOOK_TYPE_CODE = p_book_type_code
    and    TH.TRANSACTION_DATE_ENTERED <= l_period_close_date;

  cursor C_GET_REC_COST_MRC is
    select sum(BK2.RECOVERABLE_COST -nvl(BK1.RECOVERABLE_COST,0)) recoverable_cost,
           sum(BK2.SALVAGE_VALUE -nvl(BK1.SALVAGE_VALUE,0)) salvage_value
    from   FA_MC_BOOKS BK1,
           FA_MC_BOOKS BK2,
           FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
    and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
    and    TH.ASSET_ID = p_asset_id
    and    TH.BOOK_TYPE_CODE = p_book_type_code
    and    TH.TRANSACTION_DATE_ENTERED <= l_period_close_date
    and    BK1.set_of_books_id = p_set_of_books_id
    and    BK2.set_of_books_id = p_set_of_books_id ;

  -- Get Recoverable cost for Group Asset
  -- For Reclass, get sum of delta recoverable cost and salvage value from member asset
  -- bug 8256548 : removed FA_FISCAL_YEAR and FA_CALENDAR_TYPES
    cursor GP_GET_REC_COST is
      select sum(BK2.COST -nvl(BK1.COST,0))
             - decode(BK3.SALVAGE_TYPE,
                  'PCT', sum(BK2.COST -nvl(BK1.COST,0))* nvl(BK3.PERCENT_SALVAGE_VALUE,0),
                   sum(BK2.SALVAGE_VALUE -nvl(BK1.SALVAGE_VALUE,0)))      recoverable_cost,
             decode(BK3.SALVAGE_TYPE,
                  'PCT', sum(BK2.COST -nvl(BK1.COST,0))* nvl(BK3.PERCENT_SALVAGE_VALUE,0),
                   sum(BK2.SALVAGE_VALUE -nvl(BK1.SALVAGE_VALUE,0)))       salvage_value
      from   FA_BOOKS BK1,
             FA_BOOKS BK2,
             FA_BOOKS BK3,
             FA_TRANSACTION_HEADERS TH,
             FA_CALENDAR_PERIODS CP
      where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
      and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
      and    BK2.BOOK_TYPE_CODE = p_book_type_code
      and    TH.TRANSACTION_DATE_ENTERED <= CP.END_DATE
      and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcbc_record.deprn_calendar
      and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcct_record.calendar_type
      and    CP.END_DATE <= fa_cache_pkg.fazcfy_record.end_date
      and    CP.END_DATE >= fa_cache_pkg.fazcfy_record.start_date
      and    CP.PERIOD_NUM = p_period_num
      and    exists (select TH.ASSET_ID
                   from FA_BOOKS BK4
                   where TH.ASSET_ID = BK4.ASSET_ID and
                         BK4.BOOK_TYPE_CODE = p_book_type_code and
                         BK4.GROUP_ASSET_ID = p_asset_id and
                         BK4. DATE_INEFFECTIVE is null)
      and BK3.TRANSACTION_HEADER_ID_IN=
           (select max(BK.TRANSACTION_HEADER_ID_IN)
            from   FA_BOOKS BK,
                   FA_TRANSACTION_HEADERS TH,
                   FA_CALENDAR_PERIODS CP
            where  BK.ASSET_ID= p_asset_id
            and    BK.BOOK_TYPE_CODE = p_book_type_code
            and    BK.TRANSACTION_HEADER_ID_IN =TH.TRANSACTION_HEADER_ID
            and    BK.ASSET_ID= TH.ASSET_ID
            and    BK.BOOK_TYPE_CODE= TH.BOOK_TYPE_CODE
            and    TH.TRANSACTION_DATE_ENTERED <= CP.END_DATE
            and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcbc_record.deprn_calendar
            and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcct_record.calendar_type
            and    CP.END_DATE <= fa_cache_pkg.fazcfy_record.end_date
            and    CP.END_DATE >= fa_cache_pkg.fazcfy_record.start_date
            and    CP.PERIOD_NUM = p_period_num
              )
      group by BK3.SALVAGE_TYPE,BK3.PERCENT_SALVAGE_VALUE;

  cursor GP_GET_REC_COST_MRC is
      select sum(BK2.COST -nvl(BK1.COST,0))
             - decode(BK3.SALVAGE_TYPE,
                  'PCT', sum(BK2.COST -nvl(BK1.COST,0))* nvl(BK3.PERCENT_SALVAGE_VALUE,0),
                   sum(BK2.SALVAGE_VALUE -nvl(BK1.SALVAGE_VALUE,0)))      recoverable_cost,
             decode(BK3.SALVAGE_TYPE,
                  'PCT', sum(BK2.COST -nvl(BK1.COST,0))* nvl(BK3.PERCENT_SALVAGE_VALUE,0),
                   sum(BK2.SALVAGE_VALUE -nvl(BK1.SALVAGE_VALUE,0)))       salvage_value
      from   FA_MC_BOOKS BK1,
             FA_MC_BOOKS BK2,
             FA_MC_BOOKS BK3,
             FA_TRANSACTION_HEADERS TH,
             FA_CALENDAR_PERIODS CP
      where  TH.TRANSACTION_HEADER_ID = BK1.TRANSACTION_HEADER_ID_OUT(+)
      and    TH.TRANSACTION_HEADER_ID = BK2.TRANSACTION_HEADER_ID_IN
      and    BK2.BOOK_TYPE_CODE = p_book_type_code
      and    BK1.set_of_books_id = p_set_of_books_id
      and    BK2.set_of_books_id = p_set_of_books_id
      and    BK3.set_of_books_id = p_set_of_books_id
      and    TH.TRANSACTION_DATE_ENTERED <= CP.END_DATE
      and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcbcs_record.deprn_calendar
      and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcct_record.calendar_type
      and    CP.END_DATE <= fa_cache_pkg.fazcfy_record.end_date
      and    CP.END_DATE >= fa_cache_pkg.fazcfy_record.start_date
      and    CP.PERIOD_NUM = p_period_num
      and    exists (select TH.ASSET_ID
                   from FA_MC_BOOKS BK4
                   where TH.ASSET_ID = BK4.ASSET_ID and
                         BK4.BOOK_TYPE_CODE = p_book_type_code and
                         BK4.GROUP_ASSET_ID = p_asset_id and
                         BK4. DATE_INEFFECTIVE is null and
                         BK4.set_of_books_id = p_set_of_books_id)
      and BK3.TRANSACTION_HEADER_ID_IN=
           (select max(BK.TRANSACTION_HEADER_ID_IN)
            from   FA_MC_BOOKS BK,
                   FA_TRANSACTION_HEADERS TH,
                   FA_CALENDAR_PERIODS CP,
                   FA_MC_BOOK_CONTROLS BC
            where  BK.ASSET_ID= p_asset_id
            and    BK.BOOK_TYPE_CODE = p_book_type_code
            and    BK.TRANSACTION_HEADER_ID_IN =TH.TRANSACTION_HEADER_ID
            and    BK.ASSET_ID= TH.ASSET_ID
            and    BK.BOOK_TYPE_CODE= TH.BOOK_TYPE_CODE
            and    BK.set_of_books_id = p_set_of_books_id
            and    BC.BOOK_TYPE_CODE = p_book_type_code
            and    BC.set_of_books_id = p_set_of_books_id
            and    TH.TRANSACTION_DATE_ENTERED <= CP.END_DATE
            and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcbcs_record.deprn_calendar
            and    CP.CALENDAR_TYPE = fa_cache_pkg.fazcct_record.calendar_type
            and    CP.END_DATE <= fa_cache_pkg.fazcfy_record.end_date
            and    CP.END_DATE >= fa_cache_pkg.fazcfy_record.start_date
            and    CP.PERIOD_NUM = p_period_num
              )
      group by BK3.SALVAGE_TYPE,BK3.PERCENT_SALVAGE_VALUE;
  -- bug 8256548 END
  -- Get period close date
  cursor C_PERIOD_CLOSE_DATE is
    select CP.END_DATE
    from   FA_CALENDAR_PERIODS CP,
           FA_CALENDAR_TYPES   CT,
           FA_FISCAL_YEAR      FY,
           FA_BOOK_CONTROLS    BC
    where  BC.DEPRN_CALENDAR = CP.CALENDAR_TYPE
    and    CP.CALENDAR_TYPE = CT.CALENDAR_TYPE
    and    CT.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    CP.END_DATE <= FY.END_DATE
    and    CP.END_DATE >= FY.START_DATE
    and    BC.BOOK_TYPE_CODE= p_book_type_code
    and    FY.FISCAL_YEAR = p_fiscal_year
    and    CP.PERIOD_NUM = p_period_num;

  cursor C_PERIOD_CLOSE_DATE_MRC is
    select CP.END_DATE
    from   FA_CALENDAR_PERIODS CP,
           FA_CALENDAR_TYPES   CT,
           FA_FISCAL_YEAR      FY,
           FA_BOOK_CONTROLS    BC
    where  BC.DEPRN_CALENDAR = CP.CALENDAR_TYPE
    and    BC.set_of_books_id = p_set_of_books_id
    and    CP.CALENDAR_TYPE = CT.CALENDAR_TYPE
    and    CT.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    CP.END_DATE <= FY.END_DATE
    and    CP.END_DATE >= FY.START_DATE
    and    BC.BOOK_TYPE_CODE= p_book_type_code
    and    FY.FISCAL_YEAR = p_fiscal_year
    and    CP.PERIOD_NUM = p_period_num;

  cursor C_LAST_AMOUNT is
    select BK.RECOVERABLE_COST,
           BK.SALVAGE_VALUE
    from   FA_BOOKS BK
    where  BK.ASSET_ID = p_asset_id
    and    BK.BOOK_TYPE_CODE = p_book_type_code
    and    BK.TRANSACTION_HEADER_ID_OUT is null;

  cursor C_LAST_AMOUNT_MRC is
    select BK.RECOVERABLE_COST,
           BK.SALVAGE_VALUE
    from   FA_MC_BOOKS BK
    where  BK.ASSET_ID = p_asset_id
    and    BK.BOOK_TYPE_CODE = p_book_type_code
    and    BK.TRANSACTION_HEADER_ID_OUT is null
    and    BK.set_of_books_id = p_set_of_books_id;

--  l_period_close_date      date;
  l_last_recoverable_cost  number;
  l_last_salvage_value     number;

  l_calling_fn             varchar2(40) := 'fa_calc_deprn_basis1_pkg.GET_REC_COST';

  grc_err   exception;

begin
  -- Skipping entire process for straight line and flat-cost PE and User rec cost deprn basis
  -- rule because it is unnecessary.
  if (not(fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_CALC or
          (fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT and
           fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_COST and
           fa_cache_pkg.fazcdbr_record.rule_name in ('PERIOD END BALANCE', 'USE RECOVERABLE COST'))
         )
     ) then

    -------------------------------------------------
    -- Treate this transaction's
    -- Adjustment recoverable cost and salvage value
    -------------------------------------------------

    -- the following global variables are used to improve the performance.

    if p_mrc_sob_type_code <>'R' then
      if p_fiscal_year = nvl(g_fiscal_year1, -99) and
         p_period_num = nvl(g_period_num1, -99) and
         p_book_type_code = g_book_type_code then

         l_period_close_date:= g_end_date1;

      elsif p_fiscal_year = nvl(g_fiscal_year2,-99) and
         p_period_num = nvl(g_period_num2, -99) and
         p_book_type_code = g_book_type_code then

         l_period_close_date:= g_end_date2;

      else
         OPEN  C_PERIOD_CLOSE_DATE;
         FETCH C_PERIOD_CLOSE_DATE into l_period_close_date;
         CLOSE C_PERIOD_CLOSE_DATE;

         if g_period_num1 is null then
             g_fiscal_year1:= p_fiscal_year;
             g_period_num1:= nvl(p_period_num, -99);
             g_end_date1:= l_period_close_date;
         else
             g_fiscal_year2:= p_fiscal_year;
             g_period_num2:= nvl(p_period_num, -99);
             g_end_date2:= l_period_close_date;
         end if;
      end if;
    else

      if p_fiscal_year = nvl(g_fiscal_year1, -99) and
         p_period_num = nvl(g_period_num1, -99) and
         p_book_type_code = g_book_type_code then

         l_period_close_date:= g_end_date1;

      elsif p_fiscal_year = nvl(g_fiscal_year2, -99) and
         p_period_num = nvl(g_period_num2, -99) and
         p_book_type_code = g_book_type_code then

         l_period_close_date:= g_end_date2;

      else
         OPEN  C_PERIOD_CLOSE_DATE_MRC;
         FETCH C_PERIOD_CLOSE_DATE_MRC into l_period_close_date;
         CLOSE C_PERIOD_CLOSE_DATE_MRC;

         if g_period_num1 is null then
             g_fiscal_year1:= p_fiscal_year;
             g_period_num1:= p_period_num;
             g_end_date1:= l_period_close_date;
         else
             g_fiscal_year2:= p_fiscal_year;
             g_period_num2:= p_period_num;
             g_end_date2:= l_period_close_date;
         end if;
      end if;
    end if;

    -- bug 8256548 : Added function calls fazcct fazcfy
    if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
       raise grc_err;
    end if;

    if not fa_cache_pkg.fazcfy(fa_cache_pkg.fazcbc_record.fiscal_year_name,
                               p_fiscal_year, p_log_level_rec => p_log_level_rec) then
       raise grc_err;
    end if;
    -- bug 8256548 END
    if p_mrc_sob_type_code <>'R' then

      if p_asset_type='GROUP' then -- Group Asset
        open GP_GET_REC_COST;
        fetch GP_GET_REC_COST into x_recoverable_cost, x_salvage_value;
        if GP_GET_REC_COST%NOTFOUND then
          x_recoverable_cost := 0;
          x_salvage_value := 0;
        end if;
        close GP_GET_REC_COST;

      else -- Member and stand alone asset


        open C_GET_REC_COST;
        fetch C_GET_REC_COST into x_recoverable_cost, x_salvage_value;
        if C_GET_REC_COST%NOTFOUND then
          x_recoverable_cost := 0;
          x_salvage_value := 0;
        end if;
        close C_GET_REC_COST;
      end if;

    else -- MRC

      if p_asset_type='GROUP' then -- Group Asset
        open GP_GET_REC_COST_MRC;
        fetch GP_GET_REC_COST_MRC into x_recoverable_cost, x_salvage_value;
        if GP_GET_REC_COST_MRC%NOTFOUND then
          x_recoverable_cost := 0;
          x_salvage_value := 0;
        end if;
        close GP_GET_REC_COST_MRC;

      else -- Member and stand alone asset

        open C_GET_REC_COST_MRC;
        fetch C_GET_REC_COST_MRC into x_recoverable_cost, x_salvage_value;
        if C_GET_REC_COST_MRC%NOTFOUND then
          x_recoverable_cost := 0;
          x_salvage_value := 0;
        end if;
        close C_GET_REC_COST_MRC;
      end if;

    end if;  -- End of MRC

    -------------------------------------------------
    -- Treate this transaction's
    -- Adjustment recoverable cost and salvage value
    -------------------------------------------------

--    if p_mrc_sob_type_code <>'R' then
--      OPEN  C_PERIOD_CLOSE_DATE;
--      FETCH C_PERIOD_CLOSE_DATE into l_period_close_date;
--      CLOSE C_PERIOD_CLOSE_DATE;
--    else
--      OPEN  C_PERIOD_CLOSE_DATE_MRC;
--      FETCH C_PERIOD_CLOSE_DATE_MRC into l_period_close_date;
--      CLOSE C_PERIOD_CLOSE_DATE_MRC;
--    end if;

    if p_transaction_date_entered is not null
      and p_transaction_date_entered  <= l_period_close_date
      and p_recoverable_cost is not null
      and p_salvage_value is not null
    then
      if p_mrc_sob_type_code <>'R' then

        OPEN  C_LAST_AMOUNT;
        FETCH C_LAST_AMOUNT into l_last_recoverable_cost, l_last_salvage_value;
        CLOSE C_LAST_AMOUNT;
      else
        OPEN  C_LAST_AMOUNT_MRC;
        FETCH C_LAST_AMOUNT_MRC into l_last_recoverable_cost, l_last_salvage_value;
        CLOSE C_LAST_AMOUNT_MRC;

      end if;

      x_recoverable_cost := nvl(x_recoverable_cost,0)
                              + nvl(p_recoverable_cost,0) - nvl(l_last_recoverable_cost,0);
      x_salvage_value := nvl(x_salvage_value,0)
                           + nvl(p_salvage_value,0) - nvl(l_last_salvage_value,0);
    end if;

  end if;

  ------------------------------------------------------------
  -- If x_recoverable_cost and x_salvage_value is set null,
  -- Set 0 to them
  ------------------------------------------------------------
  x_recoverable_cost := nvl(x_recoverable_cost,0);
  x_salvage_value := nvl(x_salvage_value,0);

  return true;

exception
    when grc_err then
    -- bug 8256548 : Added this exception in case new added cache functions
    -- returns error
    if p_log_level_rec.statement_level then
       fa_debug_pkg.add(fname=> l_calling_fn,
                        element=>'Error calling ',
                        value=> 'Cashe function', p_log_level_rec => p_log_level_rec) ;
    end if;

    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);
    return (false);
    -- bug 8256548 END
  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return (false);

END GET_REC_COST;

--------------------------------------------------------------
-- Function: GET_EOFY_EOP
--
-- This function is to get recoverable cost and salvage value
-- at the end of last fiscal year and last period
-- p_asset_id                  : Asset Id
-- p_book_type_code            : Book Type Code
-- p_fiscal_year               : Fiscal Year
-- p_period_num                : Period Number
-- p_asset_type                : Asset Type
-- p_recoverable_cost          : Recoverable Cost at p_transaction_date_entered
--                               (Set only when p_transaction_date_entered is set)
-- p_salvage_value             : Salvage value  at p_transaction_date_entered
--                               (Set only when p_transaction_date_entered is set)
-- p_transaction_date_entered  : Transaction Date Entered (INITIAL_ADDITION only)
-- p_period_counter            : Period counter
-- p_mrc_sob_type_code         : MRC Set of Books type code
-- x_recoverable_cost          : Recoverable cost at the parameter's period
-- x_salvage_value             : Salvage value at the parameter's period
-------------------------------------------------------------

FUNCTION GET_EOFY_EOP
  (
    p_asset_id                 IN  NUMBER,
    p_book_type_code           IN  VARCHAR2,
    p_fiscal_year              IN  NUMBER,
    p_period_num               IN  NUMBER,
    p_asset_type               IN  VARCHAR2,
    p_recoverable_cost         IN  NUMBER,
    p_salvage_value            IN  NUMBER,
    p_transaction_date_entered IN  DATE,
    p_period_counter           IN  NUMBER,
    p_mrc_sob_type_code        IN  VARCHAR2,
    p_set_of_books_id          IN  NUMBER,
    x_eofy_recoverable_cost    OUT NOCOPY NUMBER,
    x_eofy_salvage_value       OUT NOCOPY NUMBER,
    x_eop_recoverable_cost     OUT NOCOPY NUMBER,
    x_eop_salvage_value        OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

  cursor C_GET_NPFY
  is
  select CT.number_per_fiscal_year
  from   FA_CALENDAR_TYPES   CT,
         FA_BOOK_CONTROLS    BC
  where  BC.DEPRN_CALENDAR = CT.CALENDAR_TYPE
  and    BC.BOOK_TYPE_CODE= p_book_type_code;

  cursor C_GET_NPFY_MRC
  is
  select CT.number_per_fiscal_year
  from   FA_CALENDAR_TYPES   CT,
         FA_MC_BOOK_CONTROLS MBC,
         FA_BOOK_CONTROLS    BC
  where  BC.DEPRN_CALENDAR = CT.CALENDAR_TYPE
  and    BC.BOOK_TYPE_CODE= p_book_type_code
  and    MBC.BOOK_TYPE_CODE= p_book_type_code
  and    MBC.set_of_books_id = p_set_of_books_id;

  CURSOR c_get_bs_amounts(c_period_counter number) IS
     select bs.recoverable_cost
          , bs.salvage_value
     from   fa_books_summary bs
     where  bs.asset_id = p_asset_id
     and    bs.book_type_code = p_book_type_code
     and    bs.period_counter = c_period_counter;

  CURSOR c_get_mc_bs_amounts(c_period_counter number) IS
     select bs.recoverable_cost
          , bs.salvage_value
     from   fa_mc_books_summary bs
     where  bs.asset_id = p_asset_id
     and    bs.book_type_code = p_book_type_code
     and    bs.period_counter = c_period_counter
     and    bs.set_of_books_id = p_set_of_books_id;


  h_num_per_fy          number(15); -- Number per fiscal year

  h_eofy_period_num     number(15) :=null;
  h_eop_period_num      number(15) :=null;
  h_eop_fiscal_year     number(15) :=null;

  l_period_counter      number(15);
  l_temp_period_counter number(15);
  l_rec_cost            number;
  l_salvage_value       number;

  l_calling_fn          varchar2(40) := 'fa_calc_deprn_basis1_pkg.GET_EOFY_EOP';

  l_get_eofy_eop_err    exception;

begin
  if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'p_period_counter:p_period_num', to_char(p_period_counter)||':'||
                                                                      to_char(p_period_num));
  end if;
   -- bug 8256548
   if (p_mrc_sob_type_code = 'R') then
     if NOT fa_cache_pkg.fazcbcs(X_book          => p_book_type_code,
                                 X_set_of_books_id => p_set_of_books_id,
                                 p_log_level_rec => p_log_level_rec) then
        raise l_get_eofy_eop_err;
     end if;
  else
     -- call the cache for the primary transaction book
     if NOT fa_cache_pkg.fazcbc(X_book          => p_book_type_code, p_log_level_rec => p_log_level_rec) then
        raise l_get_eofy_eop_err;
     end if;
  end if;
   -- bug 8256548 END

  if p_asset_type = 'GROUP' then
     if p_period_counter is null  then

        if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
           raise l_get_eofy_eop_err;
        end if;

        l_period_counter := p_fiscal_year *
                            fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR +
                            p_period_num;

     else

        l_period_counter := p_period_counter;
     end if;

     --
     -- eop/eofy amounts are available in FA_BOOKS_SUMMARY table.
     --

     if (p_mrc_sob_type_code = 'R') then
        FOR i in 1..2 LOOP
           --
           -- if i = 1, looking for eofy amounts
           -- is i = 2, looking for eop amounts
           if i = 1 then
              l_temp_period_counter := l_period_counter - p_period_num;
           else
              l_temp_period_counter := l_period_counter - 1;
           end if;

           OPEN c_get_mc_bs_amounts(l_temp_period_counter);
           FETCH c_get_mc_bs_amounts INTO l_rec_cost, l_salvage_value;

           if (c_get_mc_bs_amounts%NOTFOUND) then
              if i = 1 then
                 x_eofy_recoverable_cost := 0;
                 x_eofy_salvage_value := 0;
              else
                 x_eop_recoverable_cost := 0;
                 x_eop_salvage_value := 0;
              end if;
           else
              if i = 1 then
                 x_eofy_recoverable_cost := l_rec_cost;
                 x_eofy_salvage_value := l_salvage_value;
              else
                 x_eop_recoverable_cost := l_rec_cost;
                 x_eop_salvage_value := l_salvage_value;
              end if;
           end if;

           CLOSE c_get_mc_bs_amounts;

        END LOOP;
     else
        FOR i in 1..2 LOOP
           --
           -- if i = 1, looking for eofy amounts
           -- is i = 2, looking for eop amounts
           if i = 1 then
              l_temp_period_counter := l_period_counter - p_period_num;
           else
              l_temp_period_counter := l_period_counter - 1;
           end if;

           OPEN c_get_bs_amounts(l_temp_period_counter);
           FETCH c_get_bs_amounts INTO l_rec_cost, l_salvage_value;

           if (c_get_bs_amounts%NOTFOUND) then
              if i = 1 then
                 x_eofy_recoverable_cost := 0;
                 x_eofy_salvage_value := 0;
              else
                 x_eop_recoverable_cost := 0;
                 x_eop_salvage_value := 0;
              end if;
           else
              if i = 1 then
                 x_eofy_recoverable_cost := l_rec_cost;
                 x_eofy_salvage_value := l_salvage_value;
              else
                 x_eop_recoverable_cost := l_rec_cost;
                 x_eop_salvage_value := l_salvage_value;
              end if;
           end if;

           CLOSE c_get_bs_amounts;

        END LOOP;
     end if;

     if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'GET_EOFY_EOP',
                         element=>'Found amounts from BS',
                         value=> to_char(x_eofy_recoverable_cost)||':'||
                                 to_char(x_eofy_salvage_value)||':'||
                                 to_char(x_eop_recoverable_cost)||':'||
                                 to_char(x_eop_salvage_value));
     end if;

  else
     -------------------------------------------
     -- Query number per fiscal year
     -------------------------------------------

     if p_mrc_sob_type_code <> 'R' then
       if g_book_type_code is null or p_book_type_code <> g_book_type_code then
          OPEN C_GET_NPFY;
          FETCH C_GET_NPFY into h_num_per_fy;
          CLOSE C_GET_NPFY;
          g_book_type_code:= p_book_type_code;
          g_num_per_fy:= h_num_per_fy;
       else
          h_num_per_fy:= g_num_per_fy;
       end if;
     else
        -- to use global variable here, we need org_id too.
          OPEN C_GET_NPFY_MRC;
          FETCH C_GET_NPFY_MRC into h_num_per_fy;
          CLOSE C_GET_NPFY_MRC;
     end if;

     -------------------------------------------
     -- Get recoverable cost and salvage value
     -- at the end of last fiscal year
     -------------------------------------------

     h_eofy_period_num := h_num_per_fy;
     if (not FA_CALC_DEPRN_BASIS1_PKG.GET_REC_COST
                (
                 p_asset_id                 => p_asset_id,
                 p_book_type_code           => p_book_type_code,
                 p_fiscal_year              => p_fiscal_year -1,
                 p_period_num               => h_eofy_period_num,
                 p_asset_type               => p_asset_type,
                 p_recoverable_cost         => p_recoverable_cost,
                 p_salvage_value            => p_salvage_value,
                 p_transaction_date_entered => p_transaction_date_entered,
                 p_mrc_sob_type_code        => p_mrc_sob_type_code,
                 p_set_of_books_id          => p_set_of_books_id,
                 x_recoverable_cost         => x_eofy_recoverable_cost,
                 x_salvage_value            => x_eofy_salvage_value
                , p_log_level_rec => p_log_level_rec))
     then
       raise l_get_eofy_eop_err;
     end if;



     -------------------------------------------
     -- Get recoverable cost and salvage value
     -- at the end of last period
     -------------------------------------------
     if p_period_num -1 = 0 then
       h_eop_period_num  := h_num_per_fy;
       h_eop_fiscal_year := p_fiscal_year -1;
     else
       h_eop_period_num  := p_period_num -1;
       h_eop_fiscal_year := p_fiscal_year;
     end if;

     if (not FA_CALC_DEPRN_BASIS1_PKG.GET_REC_COST
                (
                 p_asset_id                 => p_asset_id,
                 p_book_type_code           => p_book_type_code,
                 p_fiscal_year              => h_eop_fiscal_year,
                 p_period_num               => h_eop_period_num,
                 p_asset_type               => p_asset_type,
                 p_recoverable_cost         => p_recoverable_cost,
                 p_salvage_value            => p_salvage_value,
                 p_transaction_date_entered => p_transaction_date_entered,
                 p_mrc_sob_type_code        => p_mrc_sob_type_code,
                 p_set_of_books_id          => p_set_of_books_id,
                 x_recoverable_cost         => x_eop_recoverable_cost,
                 x_salvage_value            => x_eop_salvage_value
                , p_log_level_rec => p_log_level_rec))
     then
       raise l_get_eofy_eop_err;
     end if;
  end if; -- (p_period_counter is not null and

  return true;

exception
  when l_get_eofy_eop_err then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (false);

END GET_EOFY_EOP;

--------------------------------------------------------
-- Function: CALL_DEPRN_BASIS
--
-- called from depreciation Engine(pl/sql)
-- This is same as CALL_DEPRN_BASIS above except additional
-- parameter x_annual_deprn_rounding_flag
-- This new output is necessary for flat rate extension
--------------------------------------------------------

FUNCTION CALL_DEPRN_BASIS(
     p_event_type             IN            varchar2,
     p_asset_fin_rec_new      IN            fa_api_types.asset_fin_rec_type,
     p_asset_fin_rec_old      IN            fa_api_types.asset_fin_rec_type,
     p_asset_hdr_rec          IN            fa_api_types.asset_hdr_rec_type,
     p_asset_type_rec         IN            fa_api_types.asset_type_rec_type,
     p_asset_deprn_rec        IN            fa_api_types.asset_deprn_rec_type,
     p_trans_rec              IN            fa_api_types.trans_rec_type,
     p_trans_rec_adj          IN            fa_api_types.trans_rec_type,
     p_period_rec             IN            fa_api_types.period_rec_type,
     p_asset_retire_rec       IN            fa_api_types.asset_retire_rec_type,
     p_unplanned_deprn_rec    IN            fa_api_types.unplanned_deprn_rec_type,
     p_dpr                    IN            fa_std_types.dpr_struct,
     p_fiscal_year            IN            number,
     p_period_num             IN            number,
     p_period_counter         IN            number,
     p_recoverable_cost       IN            number,
     p_salvage_value          IN            number,
     p_adjusted_cost          IN            number,
     p_current_total_rsv      IN            number,
     p_current_rsv            IN            number,
     p_current_total_ytd      IN            number,
     p_current_ytd            IN            number,
     p_hyp_basis              IN            number,
     p_hyp_total_rsv          IN            number,
     p_hyp_rsv                IN            number,
     p_hyp_total_ytd          IN            number,
     p_hyp_ytd                IN            number,
     p_eofy_recoverable_cost  IN            number,
     p_eop_recoverable_cost   IN            number,
     p_eofy_salvage_value     IN            number,
     p_eop_salvage_value      IN            number,
     p_eofy_reserve           IN            number,
     p_adj_reserve            IN            number,
     p_reserve_retired        IN            number,
     p_used_by_adjustment     IN            varchar2,
     p_eofy_flag              IN            varchar2,
     p_apply_reduction_flag   IN            varchar2,
     p_mrc_sob_type_code      IN            varchar2,
     px_new_adjusted_cost     IN OUT NOCOPY number,
     px_new_raf               IN OUT NOCOPY number,
     px_new_formula_factor    IN OUT NOCOPY number,
     x_annual_deprn_rounding_flag IN OUT NOCOPY varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

  h_rule_in           fa_std_types.fa_deprn_rule_in_struct;
  h_rule_out          fa_std_types.fa_deprn_rule_out_struct;

  tmp_method_code     varchar2(12);
  tmp_life_in_months  number(4);

  -- Variables added for Japan phase4
  l_original_Rate NUMBER;
  l_Revised_Rate NUMBER;
  l_Guaranteed_Rate NUMBER;
  l_is_revised_rate NUMBER;
  l_old_trx_id NUMBER;
  l_trx_type   VARCHAR2(100);

  l_calling_fn        varchar2(50) := 'fa_calc_deprn_basis1_pkg.CALL_DEPRN_BASIS';
  call_deprn_basis_err exception;

BEGIN


  -------------
  -- Debug
  -------------
  if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'p_event_type',
                       value=> p_event_type, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'p_asset_fin_rec_new.cost',
                       value=> p_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'p_asset_fin_rec_old.cost',
                       value=> p_asset_fin_rec_old.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'p_dpr.cost',
                       value=> p_dpr.cost, p_log_level_rec => p_log_level_rec);

      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'p_dpr.set_of_books_id',
                       value=> p_dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'p_asset_hdr_rec.set_of_books_id',
                       value=> p_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

  end if;

  -------------------------------------------
  -- Get Method information
  -------------------------------------------

  if p_event_type ='AFTER_DEPRN' then
      tmp_method_code    := p_dpr.method_code;
      tmp_life_in_months := p_dpr.life;
  else
      tmp_method_code    := p_asset_fin_rec_new.Deprn_Method_Code;
      tmp_life_in_months := p_asset_fin_rec_new.Life_In_Months;
  end if;

  if (fa_cache_pkg.fazccmt_record.rate_source_rule is null) or
     ((tmp_method_code <> fa_cache_pkg.fazccmt_record.method_code) or
      (nvl(tmp_life_in_months, -99) <> nvl(fa_cache_pkg.fazccmt_record.life_in_months, -99))) then
     if not fa_cache_pkg.fazccmt
          (X_method                => tmp_method_code,
           X_life                  => tmp_life_in_months
          , p_log_level_rec => p_log_level_rec) then

      raise call_deprn_basis_err;
     end if;
  end if;


  ----------------------------------------------------
  -- Set variables by default
  ----------------------------------------------------

  h_rule_in.event_type                 := p_event_type;
  h_rule_in.asset_id                   := p_asset_hdr_rec.asset_id;
  h_rule_in.group_asset_id             := p_asset_fin_rec_new.group_asset_id;
  h_rule_in.book_type_code             := p_asset_hdr_rec.book_type_code;
  h_rule_in.asset_type                 := nvl(p_dpr.asset_type, p_asset_type_rec.asset_type);
  h_rule_in.depreciate_flag            := p_asset_fin_rec_new.depreciate_flag;
  h_rule_in.method_code                := p_asset_fin_rec_new.deprn_method_code;
  h_rule_in.life_in_months             := p_asset_fin_rec_new.life_in_months;
  h_rule_in.method_id                  := fa_cache_pkg.fazccmt_record.method_id;
  h_rule_in.method_type                := fa_cache_pkg.fazccmt_record.rate_source_rule;
  h_rule_in.calc_basis                 := fa_cache_pkg.fazccmt_record.deprn_basis_rule;
  h_rule_in.adjustment_amount          := nvl(p_asset_fin_rec_new.cost,0)
                                            - nvl(p_asset_fin_rec_old.cost,0);
  h_rule_in.transaction_flag           := null;
  h_rule_in.cost                       := nvl(p_asset_fin_rec_new.cost,NVL(p_dpr.cost,0));
  h_rule_in.salvage_value              := nvl(p_asset_fin_rec_new.salvage_value,0);

  h_rule_in.recoverable_cost           := nvl(p_asset_fin_rec_new.recoverable_cost,0);
  h_rule_in.adjusted_cost              := nvl(p_asset_fin_rec_old.adjusted_cost,0);
  h_rule_in.current_total_rsv          := nvl(p_asset_deprn_rec.deprn_reserve,0);
  h_rule_in.current_rsv                := nvl(p_asset_deprn_rec.deprn_reserve,0);
  h_rule_in.current_total_ytd          := nvl(p_asset_deprn_rec.ytd_deprn,0);
  h_rule_in.current_ytd                := nvl(p_asset_deprn_rec.ytd_deprn,0);
  h_rule_in.hyp_basis                  := 0;
  h_rule_in.hyp_total_rsv              := 0;
  h_rule_in.hyp_rsv                    := 0;
  h_rule_in.hyp_total_ytd              := 0;
  h_rule_in.hyp_ytd                    := 0;
  h_rule_in.old_cost                   := nvl(p_asset_fin_rec_old.cost,0);
  h_rule_in.old_adjusted_cost          := nvl(p_asset_fin_rec_old.adjusted_cost,0);
  h_rule_in.old_raf                    := nvl(p_asset_fin_rec_old.rate_adjustment_factor,1);
  h_rule_in.old_formula_factor         := nvl(p_asset_fin_rec_old.formula_factor,1);

  h_rule_in.transaction_header_id      := p_trans_rec.transaction_header_id;
  h_rule_in.member_transaction_header_id := p_trans_rec.member_transaction_header_id;
  h_rule_in.transaction_date_entered   := p_trans_rec.transaction_date_entered;
  h_rule_in.amortization_start_date    := p_trans_rec.amortization_start_date;
  h_rule_in.adj_transaction_header_id  := nvl(p_trans_rec_adj.transaction_header_id,
                                              p_trans_rec.transaction_header_id);
  h_rule_in.adj_mem_transaction_header_id := nvl(p_trans_rec_adj.member_transaction_header_id,
                                                    p_trans_rec.member_transaction_header_id);
  h_rule_in.adj_transaction_date_entered := nvl(p_trans_rec_adj.transaction_date_entered,
                                                p_trans_rec.transaction_date_entered);
  h_rule_in.period_counter             := p_period_rec.period_counter;
  h_rule_in.fiscal_year                := p_period_rec.fiscal_year;
  h_rule_in.period_num                 := nvl(p_period_num,p_period_rec.period_num);
  h_rule_in.proceeds_of_sale           := nvl(p_asset_retire_rec.proceeds_of_sale,0);
  h_rule_in.cost_of_removal            := nvl(p_asset_retire_rec.cost_of_removal,0);
  h_rule_in.nbv_retired                := nvl(p_asset_retire_rec.detail_info.nbv_retired,0);
  h_rule_in.reduction_rate             := p_asset_fin_rec_new.reduction_rate;
  h_rule_in.eofy_reserve               := nvl(p_asset_fin_rec_new.eofy_reserve,0);
  h_rule_in.adj_reserve                := nvl(p_adj_reserve,0);
  h_rule_in.reserve_retired            := nvl(p_reserve_retired,0);
  h_rule_in.recognize_gain_loss        := p_asset_fin_rec_new.recognize_gain_loss;
  h_rule_in.tracking_method            := p_asset_fin_rec_new.tracking_method;
  h_rule_in.allocate_to_fully_rsv_flag := p_asset_fin_rec_new.allocate_to_fully_rsv_flag;
  h_rule_in.allocate_to_fully_ret_flag := p_asset_fin_rec_new.allocate_to_fully_ret_flag;
  h_rule_in.excess_allocation_option   := p_asset_fin_rec_new.excess_allocation_option;
  h_rule_in.depreciation_option        := p_asset_fin_rec_new.depreciation_option;
  h_rule_in.member_rollup_flag         := p_asset_fin_rec_new.member_rollup_flag;
  h_rule_in.unplanned_amount           := nvl(p_unplanned_deprn_rec.unplanned_amount,0);
  h_rule_in.eofy_recoverable_cost      := nvl(p_eofy_recoverable_cost,0);
  h_rule_in.eop_recoverable_cost       := nvl(p_eop_recoverable_cost,0);
  h_rule_in.eofy_salvage_value         := nvl(p_eofy_salvage_value,0);
  h_rule_in.eop_salvage_value          := nvl(p_eop_salvage_value,0);
  h_rule_in.used_by_adjustment         := p_used_by_adjustment;
  h_rule_in.eofy_flag                  := p_eofy_flag;
  h_rule_in.apply_reduction_flag       := p_apply_reduction_flag;
  -- Bug4169773:
  h_rule_in.short_fy_flag              := nvl(p_asset_fin_rec_new.short_fiscal_year_flag, 'NO');
  h_rule_in.mrc_sob_type_code          := p_mrc_sob_type_code;
  h_rule_in.impairment_reserve             := nvl(p_asset_deprn_rec.impairment_reserve, 0); -- IAS36
  h_rule_in.set_of_books_id            := p_asset_hdr_rec.set_of_books_id;

  h_rule_out.new_deprn_rounding_flag := p_dpr.deprn_rounding_flag;

  ----------------------------------------------
  --- Set variables for each event types
  ----------------------------------------------
  if p_event_type ='ADDITION' then

    h_rule_in.old_adjusted_cost    := nvl(px_new_adjusted_cost,0);
    h_rule_in.old_raf              := nvl(px_new_raf,1);
    h_rule_in.old_formula_factor   := nvl(px_new_formula_factor,1);
    --Bug# 6142652 change start
    if(NVL(fa_cache_pkg.fazcdbr_record.rule_name,'') = 'BEGINNING PERIOD') then
        h_rule_in.transaction_date_entered := p_asset_fin_rec_new.date_placed_in_service;
    end if;
    --Bug# 6142652 change end

  elsif p_event_type = 'EXPENSED_ADJ' then
    h_rule_in.recoverable_cost     := nvl(p_recoverable_cost,0);
    h_rule_in.adjusted_cost        := nvl(p_asset_fin_rec_new.adjusted_cost,0);
    h_rule_in.current_total_rsv    := nvl(p_current_total_rsv,0);
    h_rule_in.current_rsv          := nvl(p_current_rsv,0);
    h_rule_in.current_total_ytd    := nvl(p_current_total_ytd,0);
    h_rule_in.current_ytd          := nvl(p_current_ytd,0);
    h_rule_in.hyp_basis            := nvl(p_hyp_basis,0);
    h_rule_in.hyp_total_rsv        := nvl(p_hyp_total_rsv,0);
    h_rule_in.hyp_rsv              := nvl(p_hyp_rsv,0);
    h_rule_in.hyp_total_ytd        := nvl(p_hyp_total_ytd,0);
    h_rule_in.hyp_ytd              := nvl(p_hyp_ytd,0);
    h_rule_in.old_raf              := nvl(px_new_raf,1);
    h_rule_in.old_formula_factor   := nvl(px_new_formula_factor,1);

  elsif p_event_type in ('AMORT_ADJ','AMORT_ADJ2','AMORT_ADJ3') then
    h_rule_in.adjusted_cost        := nvl(p_adjusted_cost,0);
    h_rule_in.current_total_rsv    := nvl(p_current_total_rsv,0);
    h_rule_in.current_rsv          := nvl(p_current_rsv,0);
    h_rule_in.current_total_ytd    := nvl(p_current_total_ytd,0);
    h_rule_in.current_ytd          := nvl(p_current_ytd,0);
    h_rule_in.hyp_basis            := nvl(p_hyp_basis,0);
    h_rule_in.hyp_total_rsv        := nvl(p_hyp_total_rsv,0);
    h_rule_in.hyp_rsv              := nvl(p_hyp_rsv,0);

    if (p_trans_rec_adj.transaction_key = 'IM') or
       (p_event_type = 'AFTER_DEPRN' and
        h_rule_in.calc_basis = 'NBV') then
       h_rule_in.use_passed_imp_rsv_flag := 'Y';
    end if;

    -- Japan Tax Phase3
    -- Bug 8211842: Added 'EN' also for the extended deprn not started case
    if (nvl(p_trans_rec_adj.transaction_key,'X') in ('ES','EN')) then
       h_rule_in.transaction_flag := p_trans_rec_adj.transaction_key;
        -- Bug 6704518 populate adjusted_recoverable_cost with the value from
        -- recalculate
        h_rule_in.adjusted_recoverable_cost  := nvl(p_asset_fin_rec_new.adjusted_recoverable_cost,0);
    end if;

  elsif p_event_type ='RETIREMENT' then
    h_rule_in.adjustment_amount    := nvl(p_asset_retire_rec.cost_retired,0);
    h_rule_in.recoverable_cost     := nvl(p_recoverable_cost,0);
    h_rule_in.salvage_value        := nvl(p_salvage_value,0);

    -- Japan Tax Phase3 bug 6658280
    if (nvl(p_asset_fin_rec_new.extended_deprn_flag,'N') = 'Y') then
       h_rule_in.transaction_flag := 'ES';
        -- Bug 6786225: populating h_rule_in.allowed_deprn_limit_amount
        h_rule_in.allowed_deprn_limit_amount := p_asset_fin_rec_new.allowed_deprn_limit_amount;
    end if;

  elsif p_event_type ='AFTER_DEPRN' then
    h_rule_in.asset_id             := p_dpr.asset_id;
    h_rule_in.book_type_code       := p_dpr.book;
    h_rule_in.method_code          := p_dpr.method_code;
    h_rule_in.life_in_months       := p_dpr.life;
    h_rule_in.salvage_value        := nvl(p_dpr.salvage_value,0);
    h_rule_in.recoverable_cost     := nvl(p_dpr.rec_cost,0);
    h_rule_in.current_total_rsv    := nvl(p_current_total_rsv,0);
    h_rule_in.current_rsv          := nvl(p_current_rsv,0);
    h_rule_in.current_total_ytd    := nvl(p_current_total_ytd,0);
    h_rule_in.old_adjusted_cost    := nvl(px_new_adjusted_cost,0);
    h_rule_in.old_raf              := nvl(p_dpr.rate_adj_factor,1);
    h_rule_in.old_formula_factor   := nvl(p_dpr.formula_factor,1);
    h_rule_in.fiscal_year          := p_fiscal_year;
    h_rule_in.period_num           := p_period_num;
    h_rule_in.period_counter       := p_period_counter;
    h_rule_in.eofy_reserve         := p_eofy_reserve;
    h_rule_in.tracking_method            := p_dpr.tracking_method;
    h_rule_in.allocate_to_fully_rsv_flag := p_dpr.allocate_to_fully_rsv_flag;
    h_rule_in.allocate_to_fully_ret_flag := p_dpr.allocate_to_fully_ret_flag;
    h_rule_in.excess_allocation_option   := p_dpr.excess_allocation_option;
    h_rule_in.depreciation_option        := p_dpr.depreciation_option;
    h_rule_in.member_rollup_flag         := p_dpr.member_rollup_flag;
    h_rule_in.impairment_reserve   := nvl(p_dpr.impairment_rsv, 0); -- P2IAS36
    h_rule_in.set_of_books_id            := p_dpr.set_of_books_id;

    -- Treate asset type
    --
    -- Bug3017395: Make sure the existence of asset id
    -- If not, assume it is CAPITALIZED
    if h_rule_in.asset_type is null and
       nvl(h_rule_in.asset_id, 0) <> 0 then


   BEGIN
     select ah.asset_type
       into h_rule_in.asset_type
       from  fa_asset_history ah
      where h_rule_in.asset_id = ah.asset_id
        and ah.date_ineffective is null;
   EXCEPTION
     WHEN OTHERS THEN
       h_rule_in.asset_type := NULL;
   END;

    elsif h_rule_in.asset_type is null then
       h_rule_in.asset_type := 'CAPITALIZED';
    end if;

  elsif p_event_type ='DEPRECIATE_FLAG_ADJ' then
    null;
  elsif p_event_type ='UNPLANNED_ADJ' then
--    null;
--bug fix 3590003
    h_rule_in.old_raf := px_new_raf;
  end if; -- Set varialbes for each event type

  if p_log_level_rec.statement_level then
    fa_debug_pkg.add(l_calling_fn, '++ fa_cache_pkg.fazcdbr_record.rule_name', fa_cache_pkg.fazcdbr_record.rule_name, p_log_level_rec => p_log_level_rec);
  end if;

  --
  -- eofy and eop amounts are necessary only if deprn basis rules are following
  --   need eop amounts: 'PERIOD END AVERAGE', 'BEGINNING PERIOD'
  --   need eofy amounts: 'YEAR TO DATE AVERAGE', 'YEAR END BALANCE WITH HALF YEAR RULE'
  --
  if (fa_cache_pkg.fazcdbr_record.rule_name in ('PERIOD END AVERAGE', 'BEGINNING PERIOD',
                                                'YEAR TO DATE AVERAGE',
                                                'YEAR END BALANCE WITH HALF YEAR RULE',
                                                'YEAR TO DATE AVERAGE WITH HALF YEAR RULE')) then
     if p_log_level_rec.statement_level then
        fa_debug_pkg.add(l_calling_fn, 'eofy_rec', p_eofy_recoverable_cost, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'eop_rec', p_eop_recoverable_cost, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'eofy_sal', p_eofy_salvage_value, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'eop_sal', p_eop_salvage_value, p_log_level_rec => p_log_level_rec);
     end if;
     ---------------------------------------------
     -- Get end of fiscal year
     -- and end of period recoverable cost
     -- and salvage value
     ---------------------------------------------
     -- Get eofy recoverable cost and salvage value
     if  p_eofy_recoverable_cost is null or
         p_eofy_salvage_value is null or
         p_eop_recoverable_cost is null or
         p_eop_salvage_value is null then

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add(l_calling_fn, '++ calling GET_EOFY_EOP', '...', p_log_level_rec => p_log_level_rec);
       end if;

       if (not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
                (
                 p_asset_id              => h_rule_in.asset_id,
                 p_book_type_code        => h_rule_in.book_type_code,
                 p_fiscal_year           => h_rule_in.fiscal_year,
                 p_period_num            => h_rule_in.period_num,
                 p_asset_type            => h_rule_in.asset_type,
                 p_recoverable_cost      => h_rule_in.recoverable_cost,
                 p_salvage_value         => h_rule_in.salvage_value,
                 p_mrc_sob_type_code     => h_rule_in.mrc_sob_type_code,
                 p_set_of_books_id       => h_rule_in.set_of_books_id,
                 x_eofy_recoverable_cost => h_rule_in.eofy_recoverable_cost,
                 x_eofy_salvage_value    => h_rule_in.eofy_salvage_value,
                 x_eop_recoverable_cost  => h_rule_in.eop_recoverable_cost,
                 x_eop_salvage_value     => h_rule_in.eop_salvage_value
                , p_log_level_rec => p_log_level_rec))
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

  ---------------------------------------------
  -- Call faxcdb (Calculate depreciable basis)
  -- function
  ---------------------------------------------

  /*phase5 Need to pass correct transaction key and deprn limit amount*/
  IF (NVL(p_trans_rec.transaction_key,'XX') = 'JI' and h_rule_in.transaction_flag  is NULL) then
     h_rule_in.transaction_flag := p_trans_rec.transaction_key;
     h_rule_in.allowed_deprn_limit_amount := p_asset_fin_rec_old.allowed_deprn_limit_amount;
  END IF;
  if (not FA_CALC_DEPRN_BASIS1_PKG.faxcdb(h_rule_in,
                                          h_rule_out, p_log_level_rec => p_log_level_rec)) then
    raise call_deprn_basis_err;

  end if;

  if p_dpr.deprn_rounding_flag is not null and h_rule_out.new_deprn_rounding_flag is null then
    h_rule_out.new_deprn_rounding_flag := p_dpr.deprn_rounding_flag;
  end if;

  if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'CALL_DEPRN_BASIS',
                       element=>'h_rule_out.new_deprn_rounding_flag',
                       value=> h_rule_out.new_deprn_rounding_flag, p_log_level_rec => p_log_level_rec);
  end if;

  --- Added  as part of Japn tax Reforms 2007
  l_original_Rate            := fa_cache_pkg.fazcfor_record.original_rate;
  l_Revised_Rate             := fa_cache_pkg.fazcfor_record.revised_rate;
  l_Guaranteed_Rate          := fa_cache_pkg.fazcfor_record.guarantee_rate;
  l_is_revised_rate := 0;
  px_new_adjusted_cost := h_rule_out.new_adjusted_cost;


  IF (p_asset_fin_rec_new.cost * l_Guaranteed_Rate) >
     ((p_asset_fin_rec_new.cost - NVL(p_asset_deprn_rec.deprn_reserve,0))* l_original_Rate) THEN
     l_is_revised_rate := 1;
  END IF;

  if p_log_level_rec.statement_level then
     fa_debug_pkg.add(l_calling_fn, 'l_original_Rate', l_original_Rate, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_Revised_Rate', l_Revised_Rate, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_Guaranteed_Rate', l_Guaranteed_Rate, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'p_event_type', p_event_type, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'h_rule_out.new_adjusted_cost', h_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_new.cost', p_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.transaction_header_id', p_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
  end if;

  -- Added AMORT_ADJ  As part of Bug 7160170  for calculating correct Adjusted Cost
  IF p_event_type  NOT IN ('ADDITION', 'INITIAL_ADDITION', 'AMORT_ADJ3', 'AMORT_ADJ') THEN
     px_new_adjusted_cost := h_rule_out.new_adjusted_cost;
  ELSE
     IF p_asset_fin_rec_new.deprn_method_code = 'JP-STL-EXTND' THEN
        --- Add condition for Addition
        IF (p_event_type IN ( 'ADDITION',  'INITIAL_ADDITION')) and
           (nvl(p_asset_fin_rec_new.prior_deprn_limit_amount,0) > 0) then
           px_new_adjusted_cost := NVL(p_asset_fin_rec_new.prior_deprn_limit_amount,0) - NVL(p_asset_fin_rec_new.allowed_deprn_limit_amount,0);
        END IF;
     ELSIF  p_asset_fin_rec_new.deprn_method_code like 'JP%250DB%' THEN
        IF l_is_revised_rate = 1  THEN
           IF  p_asset_fin_rec_new.nbv_at_switch >= 0  THEN
              px_new_adjusted_cost := p_asset_fin_rec_new.nbv_at_switch;
           END IF;
        ELSIF l_is_revised_rate = 0  THEN
           --- Bug# 7160170   Chnaged the following code in order to calculate
           --  correct Adjusted Cost, when an asset is Reinstated and when NBV_AT_SWITCH is NULL.
           IF p_event_type = 'AMORT_ADJ3'   THEN --- If the Transaction is  REINSTATEMENT
              BEGIN
                 SELECT fth.transaction_type_code
                      , fth.transaction_header_id
                 INTO l_trx_type
                    , l_old_trx_id
                 FROM   fa_retirements fr
                      , fa_books fb
                      , fa_transaction_headers fth
                 WHERE  fr.transaction_header_id_out = p_trans_rec.transaction_header_id
                 AND    fr.transaction_header_id_in = fb.transaction_header_id_in
                 AND    fr.transaction_header_id_in = fth.transaction_header_id
                 AND    fr.asset_id = fb.asset_id
                 AND    fr.book_type_code = fb.book_type_code;
              EXCEPTION
                 WHEN OTHERS THEN
                    l_trx_type := NULL;
                    l_old_trx_id := NULL;
              END ;

              if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_calling_fn, 'l_trx_type', l_trx_type, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'l_old_trx_id', l_old_trx_id, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.transaction_header_id', p_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
              end if;

              IF l_trx_type = 'PARTIAL RETIREMENT' THEN
                 BEGIN
                    SELECT (fb.adjusted_cost * p_asset_fin_rec_new.cost) / fb.COST
                    INTO px_new_adjusted_cost
                    FROM   fa_retirements fr
                         , fa_books fb
                    WHERE  fr.transaction_header_id_out = p_trans_rec.transaction_header_id
                    AND    fr.transaction_header_id_in = fb.transaction_header_id_in
                    AND    fr.asset_id = fb.asset_id
                    AND    fr.book_type_code = fb.book_type_code;
                 EXCEPTION
                    WHEN OTHERS THEN
                       px_new_adjusted_cost := 0;
                 END ;
              ELSIF l_trx_type = 'FULL RETIREMENT' THEN
                 BEGIN
                    SELECT fb.adjusted_cost
                    INTO px_new_adjusted_cost
                    FROM   fa_books fb
                    WHERE  fb.transaction_header_id_out = l_old_trx_id;
                 EXCEPTION
                    WHEN OTHERS THEN
                       px_new_adjusted_cost := 0;
                 END ;
              END IF;
              /*Added for 8692052*/
              if not fa_utils_pkg.faxrnd(px_new_adjusted_cost, h_rule_in.book_type_code, h_rule_in.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                 fa_srvr_msg.add_message(calling_fn => 'faxcdb', p_log_level_rec => p_log_level_rec);
                 return (FALSE);
              end if;
           END IF;
           -- Made changes  As part of Bug 7160170  for calculating correct Adjusted Cost.
        END IF;
     END IF;

  END IF;

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'px_new_adjusted_cost', px_new_adjusted_cost, p_log_level_rec => p_log_level_rec);
   end if;
--- End  as part of Japn tax Reforms 2007

  px_new_raf := h_rule_out.new_raf;
  px_new_formula_factor := h_rule_out.new_formula_factor;
  x_annual_deprn_rounding_flag := h_rule_out.new_deprn_rounding_flag;

  return true;

EXCEPTION
  When call_deprn_basis_err then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

END CALL_DEPRN_BASIS;

--------------------------------------------------------
-- Function: CALL_DEPRN_BASIS
--
-- This function is the cover function to call faxcdb
-- from Transaction API and depreciation Engine
--------------------------------------------------------

FUNCTION CALL_DEPRN_BASIS(
     p_event_type             IN            varchar2,
     p_asset_fin_rec_new      IN            fa_api_types.asset_fin_rec_type,
     p_asset_fin_rec_old      IN            fa_api_types.asset_fin_rec_type,
     p_asset_hdr_rec          IN            fa_api_types.asset_hdr_rec_type,
     p_asset_type_rec         IN            fa_api_types.asset_type_rec_type,
     p_asset_deprn_rec        IN            fa_api_types.asset_deprn_rec_type,
     p_trans_rec              IN            fa_api_types.trans_rec_type,
     p_trans_rec_adj          IN            fa_api_types.trans_rec_type,
     p_period_rec             IN            fa_api_types.period_rec_type,
     p_asset_retire_rec       IN            fa_api_types.asset_retire_rec_type,
     p_unplanned_deprn_rec    IN            fa_api_types.unplanned_deprn_rec_type,
     p_dpr                    IN            fa_std_types.dpr_struct,
     p_fiscal_year            IN            number,
     p_period_num             IN            number,
     p_period_counter         IN            number,
     p_recoverable_cost       IN            number,
     p_salvage_value          IN            number,
     p_adjusted_cost          IN            number,
     p_current_total_rsv      IN            number,
     p_current_rsv            IN            number,
     p_current_total_ytd      IN            number,
     p_current_ytd            IN            number,
     p_hyp_basis              IN            number,
     p_hyp_total_rsv          IN            number,
     p_hyp_rsv                IN            number,
     p_hyp_total_ytd          IN            number,
     p_hyp_ytd                IN            number,
     p_eofy_recoverable_cost  IN            number,
     p_eop_recoverable_cost   IN            number,
     p_eofy_salvage_value     IN            number,
     p_eop_salvage_value      IN            number,
     p_eofy_reserve           IN            number,
     p_adj_reserve            IN            number,
     p_reserve_retired        IN            number,
     p_used_by_adjustment     IN            varchar2,
     p_eofy_flag              IN            varchar2,
     p_apply_reduction_flag   IN            varchar2,
     p_mrc_sob_type_code      IN            varchar2,
     px_new_adjusted_cost     IN OUT NOCOPY number,
     px_new_raf               IN OUT NOCOPY number,
     px_new_formula_factor    IN OUT NOCOPY number

, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

    l_calling_fn        varchar2(50) := 'fa_calc_deprn_basis1_pkg.CALL_DEPRN_BASIS';
    l_annual_deprn_rounding_flag   varchar2(5);
imp_next number;
    call_deprn_basis_err EXCEPTION;
BEGIN
   if not CALL_DEPRN_BASIS(
               p_event_type             => p_event_type,
               p_asset_fin_rec_new      => p_asset_fin_rec_new,
               p_asset_fin_rec_old      => p_asset_fin_rec_old,
               p_asset_hdr_rec          => p_asset_hdr_rec,
               p_asset_type_rec         => p_asset_type_rec,
               p_asset_deprn_rec        => p_asset_deprn_rec,
               p_trans_rec              => p_trans_rec,
               p_trans_rec_adj          => p_trans_rec_adj,
               p_period_rec             => p_period_rec,
               p_asset_retire_rec       => p_asset_retire_rec,
               p_unplanned_deprn_rec    => p_unplanned_deprn_rec,
               p_dpr                    => p_dpr,
               p_fiscal_year            => p_fiscal_year,
               p_period_num             => p_period_num,
               p_period_counter         => p_period_counter,
               p_recoverable_cost       => p_recoverable_cost,
               p_salvage_value          => p_salvage_value,
               p_adjusted_cost          => p_adjusted_cost,
               p_current_total_rsv      => p_current_total_rsv,
               p_current_rsv            => p_current_rsv,
               p_current_total_ytd      => p_current_total_ytd,
               p_current_ytd            => p_current_ytd,
               p_hyp_basis              => p_hyp_basis,
               p_hyp_total_rsv          => p_hyp_total_rsv,
               p_hyp_rsv                => p_hyp_rsv,
               p_hyp_total_ytd          => p_hyp_total_ytd,
               p_hyp_ytd                => p_hyp_ytd,
               p_eofy_recoverable_cost  => p_eofy_recoverable_cost,
               p_eop_recoverable_cost   => p_eop_recoverable_cost,
               p_eofy_salvage_value     => p_eofy_salvage_value,
               p_eop_salvage_value      => p_eop_salvage_value,
               p_eofy_reserve           => p_eofy_reserve,
               p_adj_reserve            => p_adj_reserve,
               p_reserve_retired        => p_reserve_retired,
               p_used_by_adjustment     => p_used_by_adjustment,
               p_eofy_flag              => p_eofy_flag,
               p_apply_reduction_flag   => p_apply_reduction_flag,
               p_mrc_sob_type_code      => p_mrc_sob_type_code,
               px_new_adjusted_cost     => px_new_adjusted_cost,
               px_new_raf               => px_new_raf,
               px_new_formula_factor    => px_new_formula_factor,
               x_annual_deprn_rounding_flag => l_annual_deprn_rounding_flag,
               p_log_level_rec          => p_log_level_rec) then
      raise call_deprn_basis_err;

  end if;
return(true);

EXCEPTION
  When call_deprn_basis_err then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

END CALL_DEPRN_BASIS;

------------------------------------------------------------
-- Function: CALC_PROCEEDS
--
-- This function is to calculate Year-to-Date Proceeds
-- and Life-to Date Proceeds of Do not Recognized Gain/Loss
--
--    p_asset_id            : Asset Id
--    p_asset_type          : Asset Type
--    p_book_type_code      : Book Type Code
--    p_period_counter      : Period Counter
--    p_mrc_sob_type_code   : MRC SOB TYPE Code
--    x_ltd_proceeds        : Life-to Date Proceeds
--    x_ytd_proceeds        : Year-to-Date Proceeds
--
------------------------------------------------------------

Function CALC_PROCEEDS (
    p_asset_id                    IN         NUMBER,
    p_asset_type                  IN         VARCHAR2,
    p_book_type_code              IN         VARCHAR2,
    p_period_counter              IN         NUMBER,
    p_mrc_sob_type_code           IN         VARCHAR2,
    p_set_of_books_id             IN         NUMBER,
    x_ltd_proceeds                OUT NOCOPY NUMBER,
    x_ytd_proceeds                OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN is

  l_fy_start_date     DATE; -- Start date of Fiscal Year
  l_period_end_date   DATE; -- Close date at Transaction Period

  -- Query end date of period
  cursor C_GET_DATE is
    select fy.start_date                  fy_start_date,
           dp.calendar_period_close_date  cp_end_date
    from   FA_FISCAL_YEAR fy,
           FA_DEPRN_PERIODS dp,
           FA_BOOK_CONTROLS bc
    where  bc.book_type_code = dp.book_type_code
    and    fy.fiscal_year = dp.fiscal_year
    and    bc.fiscal_year_name = fy.fiscal_year_name
    and    dp.book_type_code= p_book_type_code
    and    dp.period_counter = p_period_counter;

  cursor C_GET_DATE_M is
    select fy.start_date                  fy_start_date,
           dp.calendar_period_close_date  cp_end_date
    from   FA_FISCAL_YEAR fy,
           FA_MC_DEPRN_PERIODS dp,
           FA_MC_BOOK_CONTROLS mbc,
           FA_BOOK_CONTROLS BC
    where  bc.book_type_code = dp.book_type_code
    and    mbc.book_type_code = dp.book_type_code
    and    mbc.set_of_books_id = p_set_of_books_id
    and    fy.fiscal_year = dp.fiscal_year
    and    bc.fiscal_year_name = fy.fiscal_year_name
    and    dp.book_type_code= p_book_type_code
    and    dp.period_counter = p_period_counter
    and    dp.set_of_books_id = p_set_of_books_id;

  -- Get LTD proceeds
  cursor C_LTD_PROCEEDS (
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ldt_proceeds
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    th.transaction_date_entered <= p_period_end_date;

   -- For Group Asset
  cursor GP_LTD_PROCEEDS (
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ldt_proceeds
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    th.transaction_date_entered <= p_period_end_date;

  cursor C_LTD_PROCEEDS_M (
                           p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ldt_proceeds
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered <= p_period_end_date;

   -- For Group Asset
  cursor GP_LTD_PROCEEDS_M (
                           p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ldt_proceeds
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered <= p_period_end_date;

  -- Get YTD proceeds
  cursor C_YTD_PROCEEDS (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ytd_proceeds
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

   -- For Group Asset
  cursor GP_YTD_PROCEEDS (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ytd_proceeds
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

  cursor C_YTD_PROCEEDS_M (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ytd_proceeds
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

   -- For Group Asset
  cursor GP_YTD_PROCEEDS_M (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.nbv_retired),0)   ytd_proceeds
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

  l_calling_fn        varchar2(50) := 'fa_calc_deprn_basis1_pkg.CALC_PROCEEDS';

Begin

  -- Initialization
  x_ltd_proceeds :=0;
  x_ytd_proceeds :=0;

  if p_mrc_sob_type_code <>'R' then -- Non MRC

    -- Get start date of fiscal year and end date of period
    OPEN  C_GET_DATE;
    FETCH C_GET_DATE into l_fy_start_date, l_period_end_date;
    CLOSE C_GET_DATE;

    if p_asset_type='GROUP' then
      -- Calcluate LTD proceeds
      OPEN  GP_LTD_PROCEEDS (l_period_end_date);
      FETCH GP_LTD_PROCEEDS into x_ltd_proceeds;
      CLOSE GP_LTD_PROCEEDS;

      -- Calcluate YTD proceeds
      OPEN  GP_YTD_PROCEEDS (l_fy_start_date,l_period_end_date);
      FETCH GP_YTD_PROCEEDS into x_ytd_proceeds;
      CLOSE GP_YTD_PROCEEDS;

    else
      -- Calcluate LTD proceeds
      OPEN  C_LTD_PROCEEDS (l_period_end_date);
      FETCH C_LTD_PROCEEDS into x_ltd_proceeds;
      CLOSE C_LTD_PROCEEDS;

      -- Calcluate YTD proceeds
      OPEN  C_YTD_PROCEEDS (l_fy_start_date,l_period_end_date);
      FETCH C_YTD_PROCEEDS into x_ytd_proceeds;
      CLOSE C_YTD_PROCEEDS;
    end if; -- End of GROUP

  else  -- MRC

    -- Get start date of fiscal year and end date of period
    OPEN  C_GET_DATE_M;
    FETCH C_GET_DATE_M into l_fy_start_date, l_period_end_date;
    CLOSE C_GET_DATE_M;

    if p_asset_type='GROUP' then
      -- Calcluate LTD proceeds
      OPEN  GP_LTD_PROCEEDS_M (l_period_end_date);
      FETCH GP_LTD_PROCEEDS_M into x_ltd_proceeds;
      CLOSE GP_LTD_PROCEEDS_M;

      -- Calcluate YTD proceeds
      OPEN  GP_YTD_PROCEEDS_M (l_fy_start_date,l_period_end_date);
      FETCH GP_YTD_PROCEEDS_M into x_ytd_proceeds;
      CLOSE GP_YTD_PROCEEDS_M;

    else
      -- Calcluate LTD proceeds
      OPEN  C_LTD_PROCEEDS_M (l_period_end_date);
      FETCH C_LTD_PROCEEDS_M into x_ltd_proceeds;
      CLOSE C_LTD_PROCEEDS_M;

      -- Calcluate YTD proceeds
      OPEN  C_YTD_PROCEEDS_M (l_fy_start_date,l_period_end_date);
      FETCH C_YTD_PROCEEDS_M into x_ytd_proceeds;
      CLOSE C_YTD_PROCEEDS_M;
    end if; -- End of GROUP

  end if; -- End of MRC

  if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'CALC_PROCEEDS',
                       element=>'x_ltd_proceeds',
                       value=> x_ltd_proceeds, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'CALC_PROCEEDS',
                       element=>'x_ytd_proceeds',
                       value=> x_ytd_proceeds, p_log_level_rec => p_log_level_rec);
  end if;


  return true;

EXCEPTION

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

END CALC_PROCEEDS;

-----------------------------------------------------------------
-- Function: CALC_RETIRED_COST
--
-- This function calculate summary of retired cost.
--
--    p_event_type                  : Event Type
--    p_asset_id                    : Asset ID
--    p_asset_type                  : Asset Type
--    p_book_type_code              : Book Type Code
--    p_fiscal_year                 : Fiscal year number
--    p_period_num                  : Period number of fiscal year
--    p_adjustment_amount           : Retired cost at this transaction
--                                    (Event type:RETIREMENT)
--    p_ltd_ytd_flag                : 'LTD' - Calculate Life to date
--                                            Retired Cost.
--                                    'YTD' - Calculate Year to date
--                                            Retired Cost.
--    p_mrc_sob_type_code           : MRC SOB type code
--    x_retired_cost                : Summary of retired cost
--
-----------------------------------------------------------------

FUNCTION CALC_RETIRED_COST (
    p_event_type                  IN         VARCHAR2,
    p_asset_id                    IN         NUMBER,
    p_asset_type                  IN         VARCHAR2,
    p_book_type_code              IN         VARCHAR2,
    p_fiscal_year                 IN         NUMBER,
    p_period_num                  IN         NUMBER,
    p_adjustment_amount           IN         NUMBER,
    p_ltd_ytd_flag                IN         VARCHAR2,
    p_mrc_sob_type_code           IN         VARCHAR2,
    p_set_of_books_id             IN         NUMBER,
    x_retired_cost                OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN is

  l_fy_start_date        date;
  l_period_end_date      date;

  -- Get period end date of transaction
  cursor C_PERIOD_END_DATE is
    select FY.START_DATE,
           CP.END_DATE
    from   FA_CALENDAR_PERIODS CP,
           FA_CALENDAR_TYPES   CT,
           FA_FISCAL_YEAR      FY,
           FA_BOOK_CONTROLS    BC
    where  BC.DEPRN_CALENDAR = CP.CALENDAR_TYPE
    and    CP.CALENDAR_TYPE = CT.CALENDAR_TYPE
    and    CT.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    CP.END_DATE <= FY.END_DATE
    and    CP.END_DATE >= FY.START_DATE
    and    BC.BOOK_TYPE_CODE= p_book_type_code
    and    FY.FISCAL_YEAR = p_fiscal_year
    and    CP.PERIOD_NUM = p_period_num;

  cursor C_PERIOD_END_DATE_M is
    select FY.START_DATE,
           CP.END_DATE
    from   FA_CALENDAR_PERIODS CP,
           FA_CALENDAR_TYPES   CT,
           FA_FISCAL_YEAR      FY,
           FA_MC_BOOK_CONTROLS MBC,
           FA_BOOK_CONTROLS    BC
    where  BC.DEPRN_CALENDAR = CP.CALENDAR_TYPE
    and    CP.CALENDAR_TYPE = CT.CALENDAR_TYPE
    and    CT.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    CP.END_DATE <= FY.END_DATE
    and    CP.END_DATE >= FY.START_DATE
    and    BC.BOOK_TYPE_CODE= p_book_type_code
    and    MBC.BOOK_TYPE_CODE= p_book_type_code
    and    MBC.SET_OF_BOOKS_ID = p_set_of_books_id
    and    FY.FISCAL_YEAR = p_fiscal_year
    and    CP.PERIOD_NUM = p_period_num;

  -- Get summary of retired cost

  cursor C_LTD_RETIRED_COST (
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    th.transaction_date_entered <= p_period_end_date;

  -- Cursor for LTD Retired Cost

  cursor GP_LTD_RETIRED_COST (
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    th.transaction_date_entered <= p_period_end_date;

  cursor C_LTD_RETIRED_COST_M (
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered <= p_period_end_date;

  cursor GP_LTD_RETIRED_COST_M (
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered <= p_period_end_date;

  -- Cursor for YTD Retired Cost
  cursor C_YTD_RETIRED_COST (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;


  cursor GP_YTD_RETIRED_COST (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

  cursor C_YTD_RETIRED_COST_M (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

  cursor GP_YTD_RETIRED_COST_M (
                         p_fy_start_date      date,
                         p_period_end_date    date
  ) is
    select nvl(sum(ret.cost_retired),0)
    from   FA_MC_RETIREMENTS ret,
           FA_TRANSACTION_HEADERS th
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    ret.status in ('PROCESSED','PENDING')
    and    ret.transaction_header_id_in = th.member_transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id
    and    th.transaction_date_entered >= p_fy_start_date
    and    th.transaction_date_entered <= p_period_end_date;

  l_calling_fn        varchar2(50) := 'fa_calc_deprn_basis1_pkg.calc_retired_cost';


begin

  -- Initialization
  x_retired_cost := 0;

  -- set fy_start_date and period_end_date
  if p_mrc_sob_type_code <>'R' then -- Not MRC

    -- Calculate period end date
    OPEN  C_PERIOD_END_DATE;
    FETCH C_PERIOD_END_DATE into l_fy_start_date,l_period_end_date;
    CLOSE C_PERIOD_END_DATE;
  else -- MRC

    -- Calculate period end date
    OPEN  C_PERIOD_END_DATE_M;
    FETCH C_PERIOD_END_DATE_M into l_fy_start_date, l_period_end_date;
    CLOSE C_PERIOD_END_DATE_M;
  end if; -- End of setting fy_start_date and period_end_date

  if p_mrc_sob_type_code <>'R' then -- Not MRC

    if p_ltd_ytd_flag ='LTD' then
      -- Calculate summary of retired cost
      if p_asset_type ='GROUP' then
        OPEN  GP_LTD_RETIRED_COST (l_period_end_date);
        FETCH GP_LTD_RETIRED_COST into x_retired_cost;
        CLOSE GP_LTD_RETIRED_COST;
      else
        OPEN  C_LTD_RETIRED_COST (l_period_end_date);
        FETCH C_LTD_RETIRED_COST into x_retired_cost;
        CLOSE C_LTD_RETIRED_COST;
      end if; -- End of Group
    else -- YTD
      -- Calculate summary of retired cost
      if p_asset_type ='GROUP' then
        OPEN  GP_YTD_RETIRED_COST (l_fy_start_date,l_period_end_date);
        FETCH GP_YTD_RETIRED_COST into x_retired_cost;
        CLOSE GP_YTD_RETIRED_COST;
      else
        OPEN  C_YTD_RETIRED_COST (l_fy_start_date,l_period_end_date);
        FETCH C_YTD_RETIRED_COST into x_retired_cost;
        CLOSE C_YTD_RETIRED_COST;
      end if; -- End of Group
    end if; -- End of LTD or YTD

  else -- MRC

    if p_ltd_ytd_flag ='LTD' then
      -- Calculate summary of retired cost
      if p_asset_type ='GROUP' then
        OPEN  GP_LTD_RETIRED_COST_M (l_period_end_date);
        FETCH GP_LTD_RETIRED_COST_M into x_retired_cost;
        CLOSE GP_LTD_RETIRED_COST_M;
      else
        OPEN  C_LTD_RETIRED_COST_M (l_period_end_date);
        FETCH C_LTD_RETIRED_COST_M into x_retired_cost;
        CLOSE C_LTD_RETIRED_COST_M;
      end if; -- End of Group
    else -- YTD
      -- Calculate summary of retired cost
      if p_asset_type ='GROUP' then
        OPEN  GP_YTD_RETIRED_COST_M (l_fy_start_date,l_period_end_date);
        FETCH GP_YTD_RETIRED_COST_M into x_retired_cost;
        CLOSE GP_YTD_RETIRED_COST_M;
      else
        OPEN  C_YTD_RETIRED_COST_M (l_fy_start_date,l_period_end_date);
        FETCH C_YTD_RETIRED_COST_M into x_retired_cost;
        CLOSE C_YTD_RETIRED_COST_M;
      end if; -- End of Group
    end if; -- End of LTD or YTD

  end if; -- End of MRC

  if p_event_type ='RETIREMENT'
   and fa_calc_deprn_basis1_pkg.g_rule_in.used_by_adjustment is null
  then
    x_retired_cost := nvl(x_retired_cost,0) + abs(nvl(p_adjustment_amount,0));
  end if;

  if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'CALC_RETIRED_COST',
                       element=>'x_retired_cost',
                       value=> x_retired_cost, p_log_level_rec => p_log_level_rec);
  end if;

  return true;

EXCEPTION

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

END CALC_RETIRED_COST;

---------------------------------------------------------------------
-- Function: GET_MEM_TRANS_INFO
--
-- This function is to get the transaction infomation of member
--
--  p_member_transaction_header_id :Transaction Header Id of member
--  p_mrc_sob_type_code            :MRC SOB Type Code
--  x_member_transaction_type_code :Transaction Type Code of member
--  x_member_proceeds :Proceeds - Cost of Removal at the transaction
--  x_member_reduction_rate: Reduction_rate at the transaction
--
---------------------------------------------------------------------
Function GET_MEM_TRANS_INFO (
    p_member_transaction_header_id  IN         NUMBER,
    p_mrc_sob_type_code             IN         VARCHAR2,
    p_set_of_books_id               IN         NUMBER,
    x_member_transaction_type_code  OUT NOCOPY VARCHAR2,
    x_member_proceeds               OUT NOCOPY NUMBER,
    x_member_reduction_rate         OUT NOCOPY NUMBER,
    x_recognize_gain_loss           OUT NOCOPY VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

  l_calling_fn       VARCHAR2(50) := 'fa_calc_deprn_basis1_pkg.get_mem_trans_info';

  get_mem_trans_info EXCEPTION;

  cursor C_GET_MEM_TRANS_HEADER is
    select TH.TRANSACTION_TYPE_CODE
    from   FA_TRANSACTION_HEADERS TH
    where  TH.TRANSACTION_HEADER_ID = p_member_transaction_header_id;


  -- Get Proceeds of member asset
  cursor C_GET_MEM_PROCEEDS is
    select nvl(RET.NBV_RETIRED,0),recognize_gain_loss
    from   FA_RETIREMENTS RET
    where  RET.TRANSACTION_HEADER_ID_IN = p_member_transaction_header_id;

   -- MRC
  cursor C_GET_MEM_PROCEEDS_M is
    select nvl(RET.NBV_RETIRED,0),recognize_gain_loss
    from   FA_MC_RETIREMENTS RET
    where  RET.TRANSACTION_HEADER_ID_IN = p_member_transaction_header_id
    and    ret.set_of_books_id = p_set_of_books_id;

  -- Get reduction_rate of member asset
  cursor C_GET_REDUCITON_RATE is
    select BK.REDUCTION_RATE
    from   FA_BOOKS BK
    where  BK.TRANSACTION_HEADER_ID_IN = p_member_transaction_header_id;

   -- MRC
  cursor C_GET_REDUCITON_RATE_M is
    select BK.REDUCTION_RATE
    from   FA_MC_BOOKS BK
    where  BK.TRANSACTION_HEADER_ID_IN = p_member_transaction_header_id
    and    BK.set_of_books_id = p_set_of_books_id ;

begin

  -- Set Initialization
  x_member_transaction_type_code := null;
  x_member_proceeds :=0;
  x_member_reduction_rate := null;
  x_recognize_gain_loss := null;

  if p_member_transaction_header_id is null then

    return true;

  else -- p_member_transaction_header_id is not null

    OPEN  C_GET_MEM_TRANS_HEADER;
    FETCH C_GET_MEM_TRANS_HEADER into x_member_transaction_type_code;
    CLOSE C_GET_MEM_TRANS_HEADER;

    -- When the transaction is RETIREMENT,
    -- Get Proceeds - Cost of Removal.

    if x_member_transaction_type_code like '%RETIREMENT' then
      if p_mrc_sob_type_code <>'R' then

        OPEN  C_GET_MEM_PROCEEDS;
        FETCH C_GET_MEM_PROCEEDS into x_member_proceeds,x_recognize_gain_loss;
        CLOSE C_GET_MEM_PROCEEDS;
      else

        OPEN  C_GET_MEM_PROCEEDS_M;
        FETCH C_GET_MEM_PROCEEDS_M into x_member_proceeds,x_recognize_gain_loss;
        CLOSE C_GET_MEM_PROCEEDS_M;
      end if;
    else
      x_member_proceeds := 0;
    end if; -- End of RETIREMENT
  end if; -- End of member_transaction_header_id is not null

  -- Get Reduction Rate at the member transaction
      if p_mrc_sob_type_code <>'R' then

        OPEN  C_GET_REDUCITON_RATE;
        FETCH C_GET_REDUCITON_RATE into x_member_reduction_rate;
        CLOSE C_GET_REDUCITON_RATE;

      else

        OPEN  C_GET_REDUCITON_RATE_M;
        FETCH C_GET_REDUCITON_RATE_M into x_member_reduction_rate;
        CLOSE C_GET_REDUCITON_RATE_M;

      end if;
   -- End of Getting reduction rate

  return true;

EXCEPTION

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

End;

---------------------------------------------------------------------
-- Function: SERVER_VALIDATION
--
-- This function is to validate unexpected values
--
---------------------------------------------------------------------

Function SERVER_VALIDATION(
  p_log_level_rec        IN FA_API_TYPES.log_level_rec_type)

return boolean is

 svr_val_err    exception;
 l_calling_fn   VARCHAR2(50) := 'fa_calc_deprn_basis1_pkg.server_validation';

begin

  -- Validate recognize_gain_loss='Y'
  if g_rule_in.recognize_gain_loss='Y'
    and fa_cache_pkg.fazcdbr_record.rule_name in
         ('YEAR END BALANCE','YEAR END BALANCE WITH POSITIVE REDUCTION AMOUNT',
          'YEAR END BALANCE WITH HALF YEAR RULE')
  then
    if p_log_level_rec.statement_level then
       fa_debug_pkg.add(fname=>'server_validation',
                     element=>'recognize_gain_loss',
                     value=> g_rule_in.recognize_gain_loss, p_log_level_rec => p_log_level_rec);
    end if;

    raise svr_val_err;

  end if;

  -- Validate recognize_gain_loss='N'
  if g_rule_in.recognize_gain_loss='N'
    and (fa_cache_pkg.fazcdbr_record.rule_name in
           ('FLAT RATE EXTENSION',
            'USE FISCAL YEAR BEGINNING BASIS')
         or (fa_cache_pkg.fazcdbr_record.rule_name = 'YEAR TO DATE AVERAGE'
             and g_rule_in.calc_basis = 'NBV')
        )
  then
    if p_log_level_rec.statement_level then
       fa_debug_pkg.add(fname=>'server_validation',
                     element=>'recognize_gain_loss',
                     value=> g_rule_in.recognize_gain_loss, p_log_level_rec => p_log_level_rec);
    end if;

    raise svr_val_err;

  end if;

  return true;

EXCEPTION
  WHEN svr_val_err THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return (false);

End;

end FA_CALC_DEPRN_BASIS1_PKG;

/
