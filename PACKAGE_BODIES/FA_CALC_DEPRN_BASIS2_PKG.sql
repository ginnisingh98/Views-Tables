--------------------------------------------------------
--  DDL for Package Body FA_CALC_DEPRN_BASIS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CALC_DEPRN_BASIS2_PKG" as
/* $Header: faxcdb2b.pls 120.52.12010000.11 2010/06/10 08:06:16 deemitta ship $ */

--------------------------------------------------------------------------------
-- Procedure NON_STRICT_FLAT:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Use Transaction Period Basis'.
--------------------------------------------------------------------------------

PROCEDURE NON_STRICT_FLAT (
                           px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                           px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is
  l_calling_fn  varchar2(50) := 'fa_calc_deprn_basis2_pkg.non_strict_flat';
  l_rate_in_use          NUMBER;  -- Bug 6366379
  calc_basis_err exception;

begin
  if p_log_level_rec.statement_level then
     fa_debug_pkg.add('NSF', 'BEGIN', px_rule_in.calc_basis, p_log_level_rec => p_log_level_rec);
  end if;

  ------------------------------------------------------
  -- Event Type: EXPENSED_ADJ,AMORT_ADJ and AMORT_ADJ2
  -----------------------------------------------------

  if (px_rule_in.calc_basis = 'NBV' and
      px_rule_in.method_type = 'FLAT') then
     if (px_rule_in.event_type ='EXPENSED_ADJ') then
        if Upper(px_rule_in.depreciate_flag) like 'N%' then
           px_rule_out.new_adjusted_cost := px_rule_in.recoverable_cost -
                                            px_rule_in.current_total_rsv;
        else
           px_rule_out.new_adjusted_cost := px_rule_in.recoverable_cost -
                                            px_rule_in.hyp_total_rsv;
        end if;

     elsif (px_rule_in.event_type ='AMORT_ADJ' or
             (px_rule_in.event_type ='AMORT_ADJ' and
               (px_rule_in.asset_type ='GROUP' or
                (px_rule_in.asset_type <> 'GROUP' and
                 px_rule_in.tracking_method='ALLOCATE')) and
               nvl(px_rule_in.member_transaction_type_code,'NULL') like '%RETIREMENT'
             and px_rule_in.calc_basis = 'NBV')) then  -- Retirement for Group

        --
        -- Bug3463933: Added condition to set adjusted_cost to 0 if cost is 0.
        --
        if px_rule_in.cost = 0 then
           px_rule_out.new_adjusted_cost := 0;
        else
           px_rule_out.new_adjusted_cost := px_rule_in.recoverable_cost -
                                            px_rule_in.current_total_rsv -
                                            px_rule_in.impairment_reserve;
        end if;

     end if;
  elsif (px_rule_in.method_type = 'PRODUCTION' and
         fa_cache_pkg.fazcdrd_record.period_update_flag = 'Y') and   -- ENERGY
         (px_rule_in.event_type <> 'AMORT_ADJ3') then                -- ENERGY
     --                                                              -- ENERGY
     -- There should be no EXPENSED ADJUSTMENT for now and CURRRENT  -- ENERGY
     -- period amortized adjustment is only allowed.                 -- ENERGY
     --                                                              -- ENERGY
     if px_rule_in.recoverable_cost = 0 then
        px_rule_out.new_adjusted_cost := 0;
     else
        px_rule_out.new_adjusted_cost := px_rule_in.recoverable_cost -  -- ENERGY
                                         px_rule_in.current_total_rsv - -- ENERGY
                                         nvl(px_rule_in.unplanned_amount, 0) - -- ENERGY
                                         nvl(px_rule_in.reserve_retired,0) -   --ENERGY
                                         px_rule_in.impairment_reserve;  -- ENERGY -- IAS36
     end if;

  elsif (px_rule_in.method_type = 'CALCULATED') and
        (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and   -- ENERGY
        (px_rule_in.event_type not in ('AMORT_ADJ3','UNPLANNED_ADJ')) then

     if px_rule_in.recoverable_cost = 0 then
        px_rule_out.new_adjusted_cost := 0;
        px_rule_out.new_raf := nvl(px_rule_in.old_raf,1);
     else
        px_rule_out.new_adjusted_cost := px_rule_in.recoverable_cost -         -- ENERGY
                                         px_rule_in.current_total_rsv -        -- ENERGY
                                         nvl(px_rule_in.unplanned_amount, 0) - -- ENERGY
                                         nvl(px_rule_in.reserve_retired,0) -   -- ENERGY
                                         px_rule_in.impairment_reserve;        -- ENERGY -- IAS36
         px_rule_out.new_raf := (px_rule_in.recoverable_cost -
                                           px_rule_in.hyp_total_rsv)/px_rule_in.recoverable_cost;
     end if;

  --bug 9237690..need to reset adjusted cost for NBV+FORMULA methods
  -- Bug 9231768 : Use current_total_ytd instead of current_ytd as current_ytd is not always passed.
  elsif (px_rule_in.method_type = 'FORMULA') and
        (px_rule_in.event_type ='AMORT_ADJ') and
        (px_rule_in.calc_basis = 'NBV' ) and
        (px_rule_in.method_code like 'JP%') and
	(NVL(px_rule_in.transaction_flag,'XX') <> 'JI')then

     /*Bug 9718441 added impairment reserve and salvage value. Added salvage vaue because from now on after phase5
       exclude salvage value flag will be checked for all JP-250DB methods in fa_methods*/

     px_rule_out.new_adjusted_cost := px_rule_in.cost - ( px_rule_in.current_total_rsv - px_rule_in.current_total_ytd)
                                                       - NVL(px_rule_in.impairment_reserve,0) - NVL(px_rule_in.salvage_value,0);

  /* phase5 need caluclate adjusted cost for methods using Japan NBV calculations for Impairments(JP-250DB)*/
  elsif (px_rule_in.method_type = 'FORMULA') and
        (px_rule_in.event_type ='AMORT_ADJ') and
        (px_rule_in.calc_basis = 'NBV' ) and
        (NVL(px_rule_in.transaction_flag,'XX') = 'JI') then

     px_rule_out.new_adjusted_cost := px_rule_in.cost -  px_rule_in.current_total_rsv - NVL(px_rule_in.impairment_reserve,0) - NVL(px_rule_in.salvage_value,0);
  end if;

  if p_log_level_rec.statement_level then
     fa_debug_pkg.add('NSF', 'px_rule_in.method_type', px_rule_in.method_type, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('NSF', 'fa_cache_pkg.fazcdrd_record.period_update_flag', fa_cache_pkg.fazcdrd_record.period_update_flag, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('NSF', 'px_rule_in.recoverable_cost', px_rule_in.recoverable_cost, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('NSF', 'px_rule_in.current_total_rsv', px_rule_in.current_total_rsv, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('NSF', 'px_rule_in.unplanned_amount', px_rule_in.unplanned_amount, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('NSF', 'new_adjusted_cost', px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add('NSF', 'reserve_retired', px_rule_in.reserve_retired, p_log_level_rec => p_log_level_rec);
  end if;

  ------------------------------------------------------------
  -- Event Type: RETIREMENT (Retirements)
  ------------------------------------------------------------

  if (px_rule_in.event_type ='RETIREMENT') then
    if px_rule_in.recognize_gain_loss is not null
    then -- Do not Recognize :Group and member

      if (px_rule_in.calc_basis = 'NBV') then
        px_rule_out.new_adjusted_cost :=
                px_rule_in.recoverable_cost
                  - px_rule_in.current_total_rsv
                  - px_rule_in.impairment_reserve;
      end if;

    end if; -- End of Group and member assets' retirement

  end if; -- End Retirement

  -------------------------------------------------------------
  -- Event Type: DEPRECIATE_FLAG_ADJ (IDLE Asset Control)
  -------------------------------------------------------------
  if (px_rule_in.event_type ='DEPRECIATE_FLAG_ADJ') then

     -- Bug fix 6366379 (Added if part)
     if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES' then

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add('faxcd2b', '+++ Inside Guarantee Logic', 'YES', p_log_level_rec => p_log_level_rec);
        end if;

        SELECT rate_in_use
        INTO l_rate_in_use
        FROM fa_books
        WHERE asset_id = px_rule_in.asset_id
        AND book_type_code = px_rule_in.book_type_code
        AND date_ineffective is null;

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add('faxcdb2b', '+++ Revised Rate : ', fa_cache_pkg.fazcfor_record.revised_rate, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add('faxcdb2b', '+++ FA_Books.Rate : ', l_rate_in_use, p_log_level_rec => p_log_level_rec);
        end if;

        if fa_cache_pkg.fazcfor_record.revised_rate = l_rate_in_use then
           Null; -- Dont change adjusted cost.
        else

           if p_log_level_rec.statement_level then
              fa_debug_pkg.add('faxcd2b', '+++ ORIGINAL RATE', 'YES', p_log_level_rec => p_log_level_rec);
           end if;
            --Bug 7016118 Changed px_rule_in.current_total_rsv to px_rule_in.eofy_reserve
           px_rule_out.new_adjusted_cost :=
                px_rule_in.recoverable_cost
                  - px_rule_in.eofy_reserve
                  - px_rule_in.impairment_reserve;

        end if; -- revised_rate = l_rate_in_use
     -- End bug fix 6366379

     elsif (px_rule_in.calc_basis = 'NBV') then
        px_rule_out.new_adjusted_cost :=
                px_rule_in.recoverable_cost
                  - px_rule_in.current_total_rsv
                  - px_rule_in.impairment_reserve;
    end if;
    null;
  end if; -- End DEPRECIATE_FLAG_ADJ

  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'non_strict_flat',
                         element=>'new_adjusted_cost',
                         value=> px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;

exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when others then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        raise;

end NON_STRICT_FLAT;

--------------------------------------------------------------------------------
-- Procedure FLAT_EXTENSION:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Flat Rate Extension'.
--------------------------------------------------------------------------------

PROCEDURE FLAT_EXTENSION (
                          px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                          px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is

  h_old_recoverable_cost        NUMBER;
  h_old_adjusted_cost           NUMBER;
  h_old_method_code             VARCHAR2(12);
  h_old_calc_basis              VARCHAR2(4);
  h_old_method_type             VARCHAR2(10);
  h_old_salvage_value           NUMBER;

-- added new variables to fix bug 2303276.
  h_old_adj_recoverable_cost    NUMBER;
  h_old_cost                    NUMBER;

  l_temp_limit_remain           NUMBER;
  l_method_change_date          DATE;
  l_cost_at_method_change       NUMBER;
  l_reserve_at_method_change    NUMBER;

  l_nbv_at_method_change        NUMBER;
  l_adjustment_amount           NUMBER;

  l_amort_period                number;
  l_deprn_reserve               number;
  l_ytd_deprn                   number;

  h_set_of_books_id            number; /*Bug# 7462260 to hold value of set_of_books_id for MRC */

  cursor GET_RESERVE is
   select nvl(deprn_reserve,0), nvl(ytd_deprn,0)
     from fa_deprn_summary
    where asset_id = px_rule_in.asset_id
      and period_counter = l_amort_period;

  cursor GET_RESERVE_M is
   select nvl(deprn_reserve,0), nvl(ytd_deprn,0)
     from fa_mc_deprn_summary
    where asset_id = px_rule_in.asset_id
      and period_counter = l_amort_period
      and set_of_books_id = px_rule_in.set_of_books_id;

-- Replace original queries to cursors
  cursor C_OLD_INFO is
          select nvl(bk.recoverable_cost,0),
                 nvl(bk.adjusted_cost,0),
                 nvl(bk.salvage_value,0),
                 bk.deprn_method_code,
                 dm.deprn_basis_rule,
                 dm.rate_source_rule,
          -----------------------------------------
          -- Added following two columns
          -- to fix bug 2303276
          -----------------------------------------
                 nvl(bk.adjusted_recoverable_cost,0),
                 nvl(bk.cost,0)
          from   FA_BOOKS bk, FA_METHODS dm
          where  bk.deprn_method_code = dm.method_code
          and    nvl(bk.life_in_months, 0) = nvl(dm.life_in_months,0)
          and    bk.asset_id = px_rule_in.asset_id
          and    bk.book_type_code = px_rule_in.book_type_code
          and    bk.transaction_header_id_out is null;
   -- MRC
  cursor C_OLD_INFO_M
  is
          select nvl(bk.recoverable_cost,0),
                 nvl(bk.adjusted_cost,0),
                 nvl(bk.salvage_value,0),
                 bk.deprn_method_code,
                 dm.deprn_basis_rule,
                 dm.rate_source_rule,
                 nvl(bk.adjusted_recoverable_cost,0),
                 nvl(bk.cost,0)
          from   FA_MC_BOOKS bk, FA_METHODS dm
          where  bk.deprn_method_code = dm.method_code
          and    nvl(bk.life_in_months, 0) = nvl(dm.life_in_months,0)
          and    bk.asset_id = px_rule_in.asset_id
          and    bk.book_type_code = px_rule_in.book_type_code
          and    bk.transaction_header_id_out is null
          and    bk.set_of_books_id = px_rule_in.set_of_books_id ;

  cursor C_AMORT_PERIOD
  is
  select ap.period_counter
    from fa_deprn_periods ap
   where ap.book_type_code = px_rule_in.book_type_code
    and  ap.calendar_period_open_date
                        <= trunc(px_rule_in.amortization_start_date)
    and nvl(ap.calendar_period_close_date,sysdate)
                        >= trunc(px_rule_in.amortization_start_date);

  -- Select Method Change Date and Cost at Method Change
  cursor C_MTC_BOOK
  is
  select nvl(h.amortization_start_date,h.transaction_date_entered),
         nvl(bk.cost,0)
  from fa_transaction_headers   h,
       fa_books                 bk
  where h.transaction_header_id =
          (select max(transaction_header_id_out)
           from fa_books        b,
                fa_methods      m
          where b.book_type_code = px_rule_in.book_type_code
            and b.asset_id = px_rule_in.asset_id
            and b.deprn_method_code = m.method_code
            and m.deprn_basis_rule = 'NBV')
   and bk.book_type_code = px_rule_in.book_type_code
   and bk.asset_id = px_rule_in.asset_id
   and bk.transaction_header_id_in = h.transaction_header_id;

  cursor C_MTC_BOOK_M
  is
  select nvl(h.amortization_start_date,h.transaction_date_entered),
         nvl(bk.cost,0)
  from fa_transaction_headers   h,
       fa_mc_books                 bk
  where h.transaction_header_id =
          (select max(transaction_header_id_out)
           from fa_mc_books  b,
                fa_methods      m
          where b.book_type_code = px_rule_in.book_type_code
            and b.asset_id = px_rule_in.asset_id
            and b.deprn_method_code = m.method_code
            and b.set_of_books_id = px_rule_in.set_of_books_id
            and m.deprn_basis_rule = 'NBV')
   and bk.book_type_code = px_rule_in.book_type_code
   and bk.asset_id = px_rule_in.asset_id
   and bk.transaction_header_id_in = h.transaction_header_id
   and bk.set_of_books_id = px_rule_in.set_of_books_id;

  -- Select reserve at Method Change (Reserve at the beginning of fy of Method Change)
  cursor C_MTC_SUM (p_method_change_date  date)
  is
  select nvl(deprn_reserve,0) - nvl(ytd_deprn,0)
    from fa_deprn_summary
   where book_type_code = px_rule_in.book_type_code
     and asset_id = px_rule_in.asset_id
     and period_counter =
                (select period_counter
                   from fa_deprn_periods
                  where book_type_code = px_rule_in.book_type_code
                    and calendar_period_open_date <= p_method_change_date
                    and nvl(calendar_period_close_date,sysdate) >= p_method_change_date);

  cursor C_MTC_SUM_M (p_method_change_date  date)
  is
  select nvl(deprn_reserve,0) - nvl(ytd_deprn,0)
    from fa_deprn_summary
   where book_type_code = px_rule_in.book_type_code
     and asset_id = px_rule_in.asset_id
     and period_counter =
                (select period_counter
                   from fa_deprn_periods
                  where book_type_code = px_rule_in.book_type_code
                    and calendar_period_open_date <= p_method_change_date
                    and nvl(calendar_period_close_date,sysdate) >= p_method_change_date);

-- Added for group depreciation

  -- Check exclude_fully_rsv_flag
  CURSOR C_EXC_FULLY_RSV_FLAG
  is
    select exclude_fully_rsv_flag
    from   FA_BOOKS BK
    where  BK.ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.TRANSACTION_HEADER_ID_OUT is null;

  CURSOR C_EXC_FULLY_RSV_FLAG_M
  is
    select exclude_fully_rsv_flag
    from   FA_MC_BOOKS BK
    where  BK.ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.TRANSACTION_HEADER_ID_OUT is null
    and    BK.set_of_books_id = px_rule_in.set_of_books_id ;

  cursor FULL_RSV_MEMBER_TRC (p_period_counter number)
  is
    select nvl(sum(TRC.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(TRC.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(TRC.recoverable_cost),0)  fully_rsv_recoverable_cost,
           nvl(sum(TRC.deprn_reserve),0)     fully_rsv_deprn_reserve
    from   FA_TRACK_MEMBERS TRC
    where  TRC.GROUP_ASSET_ID = px_rule_in.asset_id
    and    TRC.PERIOD_COUNTER <= p_period_counter
    and    TRC.FULLY_RESERVED_FLAG='Y'
    and    nvl(TRC.SET_OF_BOOKS_ID,-99) = nvl(h_set_of_books_id,-99) /*Bug# 7462260 Added filter conition for MRC */
    and    TRC.MEMBER_ASSET_ID is not null;

  cursor CUR_FULL_RSV_MEMBER_TRC (p_period_counter number)
  is
    select nvl(sum(TRC.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(TRC.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(TRC.recoverable_cost),0)  fully_rsv_recoverable_cost,
           nvl(sum(TRC.deprn_reserve),0)     fully_rsv_deprn_reserve
    from   FA_TRACK_MEMBERS TRC
    where  TRC.GROUP_ASSET_ID = px_rule_in.asset_id
    and    TRC.PERIOD_COUNTER = p_period_counter
    and    TRC.FULLY_RESERVED_FLAG='Y'
    and    nvl(TRC.SET_OF_BOOKS_ID,-99) = nvl(h_set_of_books_id,-99) /*Bug# 7462260 Added filter conition for MRC */
    and    TRC.MEMBER_ASSET_ID is not null;

  cursor MIN_TRC_PERIOD
  is
    select min(TRC.period_counter)
    from   FA_TRACK_MEMBERS TRC
    where  TRC.GROUP_ASSET_ID = px_rule_in.asset_id
    and    TRC.MEMBER_ASSET_ID is not null
    and    nvl(TRC.SET_OF_BOOKS_ID,-99) = nvl(h_set_of_books_id,-99); /*Bug# 7462260 Added filter conition for MRC */

  cursor FULL_RSV_MEMBER_BK (p_period_counter   number)
  is
    select nvl(sum(BK.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(BK.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(BK.recoverable_cost),0)  fully_rsv_recoverable_cost,
           nvl(sum(DS.deprn_reserve),0)     fully_rsv_deprn_reserve
    from   FA_BOOKS BK,
           FA_DEPRN_SUMMARY DS
    where  BK.ASSET_ID = DS.ASSET_ID
    and    BK.BOOK_TYPE_CODE = DS.BOOK_TYPE_CODE
    and    BK.PERIOD_COUNTER_FULLY_RESERVED = DS.PERIOD_COUNTER
    and    BK.GROUP_ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    nvl(BK.PERIOD_COUNTER_FULLY_RESERVED,p_period_counter)
                                                < p_period_counter
    and    BK.PERIOD_COUNTER_FULLY_RETIRED is null
    and    BK.DATE_INEFFECTIVE is null;

  cursor FULL_RSV_MEMBER_BK_M  (p_period_counter   number)
  is
    select nvl(sum(BK.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(BK.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(BK.recoverable_cost),0)  fully_rsv_recoverable_cost,
           nvl(sum(DS.deprn_reserve),0)     fully_rsv_deprn_reserve
    from   FA_MC_BOOKS BK,
           FA_MC_DEPRN_SUMMARY DS
    where  BK.ASSET_ID = DS.ASSET_ID
    and    BK.BOOK_TYPE_CODE = DS.BOOK_TYPE_CODE
    and    BK.PERIOD_COUNTER_FULLY_RESERVED = DS.PERIOD_COUNTER
    and    BK.GROUP_ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.set_of_books_id = px_rule_in.set_of_books_id
    and    DS.set_of_books_id = px_rule_in.set_of_books_id
    and    nvl(BK.PERIOD_COUNTER_FULLY_RESERVED,p_period_counter)
                                                < p_period_counter
    and    BK.PERIOD_COUNTER_FULLY_RETIRED is null
    and    BK.DATE_INEFFECTIVE is null;

  cursor CUR_FULL_RSV_MEMBER_BK (p_period_counter   number)
  is
    select nvl(sum(BK.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(BK.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(BK.recoverable_cost),0)  fully_rsv_recoverable_cost
    from   FA_BOOKS BK
    where  BK.GROUP_ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.PERIOD_COUNTER_FULLY_RESERVED = p_period_counter
    and    BK.DATE_INEFFECTIVE is null;

  cursor CUR_FULL_RSV_MEMBER_BK_M  (p_period_counter   number)
  is
    select nvl(sum(BK.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(BK.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(BK.recoverable_cost),0)  fully_rsv_recoverable_cost
    from   FA_MC_BOOKS BK
    where  BK.GROUP_ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.PERIOD_COUNTER_FULLY_RESERVED = p_period_counter
    and    BK.DATE_INEFFECTIVE is null
    and    BK.set_of_books_id = px_rule_in.set_of_books_id;

  cursor ALL_FULL_RSV_MEMBER_BK (p_period_counter   number)
  is
    select nvl(sum(BK.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(BK.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(BK.recoverable_cost),0)  fully_rsv_recoverable_cost
    from   FA_BOOKS BK
    where  BK.GROUP_ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.PERIOD_COUNTER_FULLY_RESERVED <= p_period_counter
    and    BK.DATE_INEFFECTIVE is null;

  cursor ALL_FULL_RSV_MEMBER_BK_M  (p_period_counter   number)
  is
    select nvl(sum(BK.adjusted_cost),0)     fully_rsv_adjusted_cost,
           nvl(sum(BK.salvage_value),0)     fully_rsv_salvage_value,
           nvl(sum(BK.recoverable_cost),0)  fully_rsv_recoverable_cost
    from   FA_MC_BOOKS BK
    where  BK.GROUP_ASSET_ID = px_rule_in.asset_id
    and    BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    BK.PERIOD_COUNTER_FULLY_RESERVED <= p_period_counter
    and    BK.DATE_INEFFECTIVE is null
    and    BK.set_of_books_id = px_rule_in.set_of_books_id ;

  -- Get member's retired adjusted_cost
  cursor C_GET_RET_ADJ_COST
  is
    select nvl(BK1.ADJUSTED_COST,0) - nvl(BK2.ADJUSTED_COST,0)
    from   FA_BOOKS BK1,
           FA_BOOKS BK2
    where  BK1.TRANSACTION_HEADER_ID_OUT = px_rule_in.member_transaction_header_id
    and    BK1.GROUP_ASSET_ID is not null
    and    BK2.TRANSACTION_HEADER_ID_IN = px_rule_in.member_transaction_header_id
    and    BK2.GROUP_ASSET_ID is not null;

   -- MRC
  cursor C_GET_RET_ADJ_COST_M
  is
    select nvl(BK1.ADJUSTED_COST,0) - nvl(BK2.ADJUSTED_COST,0)
    from   FA_MC_BOOKS BK1,
           FA_MC_BOOKS BK2
    where  BK1.TRANSACTION_HEADER_ID_OUT = px_rule_in.member_transaction_header_id
    and    BK1.GROUP_ASSET_ID is not null
    and    BK2.TRANSACTION_HEADER_ID_IN = px_rule_in.member_transaction_header_id
    and    BK2.GROUP_ASSET_ID is not null
    and    BK1.set_of_books_id = px_rule_in.set_of_books_id
    and    BK2.set_of_books_id = px_rule_in.set_of_books_id;

  l_fully_rsv_adjusted_cost      NUMBER :=0; -- Summary of Fully reserved member's adjusted cost
  l_fully_rsv_salvage_value      NUMBER :=0; -- Summary of Fully reserved member's salvage value
  l_fully_rsv_recoverable_cost   NUMBER :=0; -- Summary of Fully reserved member's recoverable cost
  l_fully_rsv_deprn_reserve      NUMBER :=0; -- Summary of Fully reserved member's deprn reserve

  trc_fully_rsv_adjusted_cost     NUMBER :=0; -- Summary of Fully reserved member's adjusted cost from FA_TRACK_MEMBERS
  trc_fully_rsv_salvage_value     NUMBER :=0; -- Summary of Fully reserved member's salvage value from FA_TRACK_MEMBERS
  trc_fully_rsv_recoverable_cost  NUMBER :=0; -- Summary of Fully reserved member's recoverable cost from FA_TRACK_MEMBERS
  trc_fully_rsv_deprn_reserve     NUMBER :=0; -- Summary of Fully reserved member's deprn reserve from FA_TRACK_MEMBERS

  bk_fully_rsv_adjusted_cost      NUMBER :=0; -- Summary of Fully reserved member's adjusted cost from FA_BOOKS
  bk_fully_rsv_salvage_value      NUMBER :=0; -- Summary of Fully reserved member's salvage value from FA_BOOKS
  bk_fully_rsv_recoverable_cost   NUMBER :=0; -- Summary of Fully reserved member's recoverable cost from FA_BOOKS
  bk_fully_rsv_deprn_reserve      NUMBER :=0; -- Summary of Fully reserved member's deprn reserve from FA_BOOKS

  l_exclude_fully_rsv_flag        VARCHAR2(1); -- Exclude fully Reserved flag
  l_exclude_salvage_value_flag    VARCHAR2(3); -- Exclude salvage value flag
  l_trc_min_period_counter        NUMBER :=null;      -- Minimum period counter on FA_TRACK_MEMBERS
  l_mem_ret_adj_cost              NUMBER :=0; -- Member retirement adjusted cost

  l_calling_fn                    VARCHAR2(50) := 'fa_calc_deprn_basis2_pkg.flat_extension';
  l_function                      VARCHAR2(20) := 'flat_extension';

  calc_basis_err exception;

begin
   if (px_rule_in.method_type = 'FLAT') then
      if px_rule_in.event_type ='AMORT_ADJ' and
         not nvl(px_rule_in.member_transaction_type_code,'NULL') like '%RETIREMENT' then

        --
        -- Normal Adjustment
        --
        if (px_rule_in.calc_basis = 'COST') then

           -----------------------------------------
           -- Query old book and method information
           ----------------------------------------
           if px_rule_in.mrc_sob_type_code <>'R' then

              OPEN  C_OLD_INFO;
              FETCH C_OLD_INFO into h_old_recoverable_cost,
                                    h_old_adjusted_cost,
                                    h_old_salvage_value,
                                    h_old_method_code,
                                    h_old_calc_basis,
                                    h_old_method_type,
                                    h_old_adj_recoverable_cost,
                                    h_old_cost;
              CLOSE  C_OLD_INFO;

           else -- MRC
              OPEN  C_OLD_INFO_M;
              FETCH C_OLD_INFO_M into h_old_recoverable_cost,
                                      h_old_adjusted_cost,
                                      h_old_salvage_value,
                                      h_old_method_code,
                                      h_old_calc_basis,
                                      h_old_method_type,
                                      h_old_adj_recoverable_cost,
                                      h_old_cost;
              CLOSE  C_OLD_INFO_M;

           end if; -- End of MRC

           if p_log_level_rec.statement_level then
              fa_debug_pkg.add('deprn_basis2:FLAT_EXTENSION logic:',
                               'After the main SQL Statement', 'queried values', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_recoverable_cost', h_old_recoverable_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_adjusted_cost', h_old_adjusted_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_salvage_value', h_old_salvage_value, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_method_code', h_old_method_code, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_calc_basis', h_old_calc_basis, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_method_type', h_old_method_type, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_adj_recoverable_cost', h_old_adj_recoverable_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'h_old_cost', h_old_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'amortization_start_date',
                               px_rule_in.amortization_start_date, p_log_level_rec => p_log_level_rec);
           end if;
           if (h_old_method_code <> px_rule_in.method_code and
               h_old_calc_basis <> px_rule_in.calc_basis) then
              -------------------------------------------------------------
              -- If old and new method codes are not same
              -- and old and new calculation basis are not same,
              -- Depreciable basis is set the NBV at the fiscal year begin.
              -------------------------------------------------------------

              -------------------------------------------------------------
              -- Bug2303276: following current total rsv and current total ytd
              -- is not correct when the amortization start date is different
              -- period from current.
              -- Check it and if the period is different, query the correct
              -- reserve and ytd with amortization start date
              ------------------------------------------------------------
              if px_rule_in.amortization_start_date is not null then

                 OPEN  C_AMORT_PERIOD;
                 FETCH C_AMORT_PERIOD into l_amort_period;
                 CLOSE C_AMORT_PERIOD;

                 if p_log_level_rec.statement_level then
                    fa_debug_pkg.add(l_function, 'Amortization Start Date Period', l_amort_period, p_log_level_rec => p_log_level_rec);
                 end if;

                 if px_rule_in.mrc_sob_type_code <>'R' then
                    open GET_RESERVE;
                    fetch GET_RESERVE into l_deprn_reserve,l_ytd_deprn;

                    if GET_RESERVE%FOUND then

                       if l_deprn_reserve is not null then
                          px_rule_in.current_total_rsv := nvl(l_deprn_reserve,0);
                       end if;

                       if l_ytd_deprn is not null then
                          px_rule_in.current_total_ytd := nvl(l_ytd_deprn,0);
                       end if;

                    end if;

                    close GET_RESERVE;
                 else -- MRC
                    open GET_RESERVE_M;
                    fetch GET_RESERVE_M into l_deprn_reserve,l_ytd_deprn;

                    if GET_RESERVE_M%FOUND then

                       if l_deprn_reserve is not null then
                          px_rule_in.current_total_rsv := nvl(l_deprn_reserve,0);
                       end if;

                       if l_ytd_deprn is not null then
                          px_rule_in.current_total_ytd := nvl(l_ytd_deprn,0);
                       end if;

                    end if;

                    close GET_RESERVE_M;

                 end if; -- End of MRC

                 if p_log_level_rec.statement_level then
                    fa_debug_pkg.add(l_function, 'Back Dated Amortization Logic',
                                     'Replace Reserve and YTD', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_function, 'Deprn Reserve at Amortization Date',
                                     px_rule_in.current_total_rsv, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_function, 'YTD at Amortization Date',
                                     px_rule_in.current_total_ytd, p_log_level_rec => p_log_level_rec);
                 end if;

              end if; -- px_rule_in.amortization_start_date is not null
              if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_function, 'Method Change logic', 'NBV calculation', p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_function, 'Deprn Reserve at Amortization Date',
                                  px_rule_in.current_total_rsv, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_function, 'YTD at Amortization Date',
                                  px_rule_in.current_total_ytd, p_log_level_rec => p_log_level_rec);
              end if;

              -- Bug3481425:
              -- Adjusted cost cannot be derived using rec cost, ytd and reserve in case
              -- there was a retirement in this fiscal year
              -- so use eofy reserve instead.  The passed eofy reserve should include
              -- retirement effect.
              --
              -- px_rule_out.new_adjusted_cost := nvl(px_rule_in.recoverable_cost,0) -
              --                                  nvl(px_rule_in.current_total_rsv,0) +
              --                                  nvl(px_rule_in.current_total_ytd,0);
              --

              px_rule_out.new_adjusted_cost := nvl(px_rule_in.recoverable_cost,0) -
                                               nvl(px_rule_in.eofy_reserve, 0);

              -------------------------------------------------------------
              -- If the new adjusted_cost above is smaller than zero,
              -- New Adjusted Cost must be calculated as follows;
              -- New Adjusted Cost = NBV at Method Change - Deprn Limit Remaining.
              -------------------------------------------------------------

              if px_rule_out.new_adjusted_cost <= 0 then

                 l_temp_limit_remain := nvl(h_old_cost,0) - nvl(h_old_adj_recoverable_cost,0);

                 if p_log_level_rec.statement_level then
                    fa_debug_pkg.add(l_function, 'Method Change logic', 'Negative NBV calculation', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_function, 'new_adjusted_cost reducing by salvage value',
                                     px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_function, 'h_old_salvage_value', h_old_salvage_value, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_function, 'l_temp_limit_remain', l_temp_limit_remain, p_log_level_rec => p_log_level_rec);
                 end if;

                 px_rule_out.new_adjusted_cost := nvl(px_rule_out.new_adjusted_cost,0) +
                                                  nvl(h_old_salvage_value,0) -
                                                  nvl(l_temp_limit_remain,0) -
                                                  nvl(px_rule_in.impairment_reserve, 0);

              end if;
              -------------------------------------------------------------
              -- If old and new calculation basis are same
              -- and old and new method types are same
              -- and old adjusted cost is not same as old recoverable cost,
              -- Depreciable basis is set
              -- 'old adjusted cost + adjustment amount
              -- (new salvage value - old salvage value)
              -------------------------------------------------------------

           elsif (h_old_calc_basis = px_rule_in.calc_basis and
                  h_old_method_type = px_rule_in.method_type and
                  h_old_adjusted_cost <> h_old_recoverable_cost) then

              -------------------------------------------------------------
              -- If old and new calculation basis are same
              -- and old and new method types are same
              -- and old adjusted cost is not same as old recoverable cost,
              -- Depreciable basis is set
              -- 'old adjusted cost + adjustment amount
              -- (new salvage value - old salvage value)
              -------------------------------------------------------------

              if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_function, 'Cost Change logic',  'before SQL statement', p_log_level_rec => p_log_level_rec);
              end if;

              ---------------------------------------------------------------
              -- Cost Adjustment Case Preparation
              --  Select Reserve-YTD reserve at Method Change
              ---------------------------------------------------------------
              if px_rule_in.mrc_sob_type_code <>'R' then

                 -- Select Method Change Date and Cost at Method Change
                 OPEN  C_MTC_BOOK;
                 FETCH C_MTC_BOOK into l_method_change_date, l_cost_at_method_change;
                 CLOSE C_MTC_BOOK;

                 -- Select reserve at Method Change (Reserve at the beginning of fy of Method Change)
                 OPEN  C_MTC_SUM (l_method_change_date);
                 FETCH C_MTC_SUM into l_reserve_at_method_change;
                 CLOSE C_MTC_SUM;

              else -- MRC
                 -- Select Method Change Date and Cost at Method Change
                 OPEN  C_MTC_BOOK_M;
                 FETCH C_MTC_BOOK_M into l_method_change_date, l_cost_at_method_change;
                 CLOSE C_MTC_BOOK_M;

                 -- Select reserve at Method Change (Reserve at the beginning of fy of Method Change)
                 OPEN  C_MTC_SUM_M (l_method_change_date);
                 FETCH C_MTC_SUM_M into l_reserve_at_method_change;
                 CLOSE C_MTC_SUM_M;

              end if; -- End of MRC

              -- NBV at Method Change --
              --
              l_nbv_at_method_change := nvl(l_cost_at_method_change,0) -
                                        nvl(l_reserve_at_method_change,0);

              --
              -- Difference between Cost at Method Change and New Cost --
              --
              l_adjustment_amount := nvl(px_rule_in.cost,0) - nvl(l_cost_at_method_change,0);

              -- Check if the NBV at Method Change + difference > Salvage Value --

              if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_function, 'Check Salvage Value logic', 'before IF-Clause', p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_function, 'l_nbv_at_method_change', l_nbv_at_method_change, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_function, 'l_adjustment_amount', l_adjustment_amount, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_function, 'salvage_value', px_rule_in.salvage_value, p_log_level_rec => p_log_level_rec);
              end if;

              -- Check if the NBV at Method Change + difference > Salvage Value --
              -- Because user cannot make the Cost Change with small adjustment amount
              -- (Salvage Value > NBV). So the following formula is not considered
              -- such situation.
              px_rule_out.new_adjusted_cost := nvl(l_nbv_at_method_change,0) +
                                               nvl(l_adjustment_amount,0) -
                                               nvl(px_rule_in.salvage_value,0) -
                                               nvl(px_rule_in.impairment_reserve, 0);

              if nvl(l_nbv_at_method_change,0) <> 0 then
                 px_rule_in.use_old_adj_cost_flag :='Y';
              end if;

           end if; -- End if Method Change or Cost Adjustment
	   /*phase5 need caluclate adjusted cost for methods using Japan NBV calculations for Impairments(JP-STL)*/
           if  NVL(px_rule_in.transaction_flag,'XX') = 'JI' then
	      px_rule_out.new_adjusted_cost := px_rule_in.cost -  px_rule_in.current_total_rsv -  NVL(px_rule_in.impairment_reserve,0) - NVL(px_rule_in.salvage_value,0);
	   end if;
	/* phase5 need caluclate adjusted cost for methods using Japan NBV calculations for Impairments(JP-DB)*/
        elsif  (px_rule_in.calc_basis = 'NBV' and NVL(px_rule_in.transaction_flag,'XX') = 'JI') then
	   px_rule_out.new_adjusted_cost := px_rule_in.cost -  px_rule_in.current_total_rsv -  NVL(px_rule_in.impairment_reserve,0) - NVL(px_rule_in.salvage_value,0);
	end if; -- End if Deprn Basis = COST

     elsif px_rule_in.event_type ='AMORT_ADJ' and
           px_rule_in.asset_type ='GROUP' and
           nvl(px_rule_in.member_transaction_type_code,'NULL') like '%RETIREMENT' then
        --
        -- Retirement for group asset
        --
        if px_rule_in.calc_basis = 'COST' and
           px_rule_in.tracking_method is not null then
           --
           -- When group asset has tracking method and cost base,
           -- reduce member's retired adjuted cost from group's adjusted_cost.
           --
           if px_rule_in.mrc_sob_type_code <>'R' then
              OPEN  C_GET_RET_ADJ_COST;
              FETCH C_GET_RET_ADJ_COST into l_mem_ret_adj_cost;
              CLOSE C_GET_RET_ADJ_COST;
           else
              OPEN  C_GET_RET_ADJ_COST_M;
              FETCH C_GET_RET_ADJ_COST_M into l_mem_ret_adj_cost;
              CLOSE C_GET_RET_ADJ_COST_M;
           end if;

           if p_log_level_rec.statement_level then
              fa_debug_pkg.add(l_function, 'l_mem_ret_adj_cost', l_mem_ret_adj_cost, p_log_level_rec => p_log_level_rec);
           end if;

           px_rule_out.new_adjusted_cost := nvl(px_rule_in.old_adjusted_cost,0) -
                                            nvl(l_mem_ret_adj_cost,0);
           px_rule_in.use_old_adj_cost_flag :='Y';

        end if; -- End of Cost and tracking method is null

     end if; -- End if Event Type = AMORT_ADJ

     -------------------------------------------------------------
     -- Event Type: AFTER_DEPRN
     --
     -- Only at fiscal year end, update adjusted_cost of NBV base
     -------------------------------------------------------------
     if (px_rule_in.event_type ='AFTER_DEPRN') then

        -- Reset old adjusted cost flag
        px_rule_in.use_old_adj_cost_flag :=null;

        if  px_rule_in.eofy_flag ='Y' and
            px_rule_in.calc_basis ='NBV'  then
           --
           -- fiscal year end update
           --

           px_rule_out.new_adjusted_cost := px_rule_in.recoverable_cost -
                                            px_rule_in.current_total_rsv -
                                            nvl(px_rule_in.impairment_reserve, 0); --P2IAS36

        else -- period update

           px_rule_out.new_adjusted_cost :=px_rule_in.old_adjusted_cost;
-- - nvl(px_rule_in.impairment_reserve, 0); --P2IAS36
           px_rule_in.use_old_adj_cost_flag :='Y';

        end if;  -- End of eofy flag

        px_rule_out.new_formula_factor := px_rule_in.old_formula_factor;
        px_rule_out.new_raf := px_rule_in.old_raf;
     end if; -- End event type: AFTER_DEPRN


     if p_log_level_rec.statement_level then
        fa_debug_pkg.add(l_function,
                         'new_adjusted_cost before calculating fully reserved member',
                         px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
     end if;

     -------------------------------------------------------------
     -- Reduce depreciable basis of fully reserved member assets
     -- from depreciable basis of group asset
     -------------------------------------------------------------
     if px_rule_in.asset_type = 'GROUP' and
        px_rule_in.tracking_method is not null and
        not (px_rule_in.calc_basis='NBV' and
             px_rule_in.tracking_method='CALCULATE') then

        if px_rule_in.mrc_sob_type_code <>'R' then

           OPEN  C_EXC_FULLY_RSV_FLAG;
           FETCH C_EXC_FULLY_RSV_FLAG into l_exclude_fully_rsv_flag;
           CLOSE C_EXC_FULLY_RSV_FLAG;
           /*Bug# 7462260 Added to fetch set_of_books_id from cache*/
           h_set_of_books_id:= FA_CACHE_PKG.fazcbc_record.set_of_books_id;

        else -- MRC

           OPEN  C_EXC_FULLY_RSV_FLAG_M;
           FETCH C_EXC_FULLY_RSV_FLAG_M into l_exclude_fully_rsv_flag;
           CLOSE C_EXC_FULLY_RSV_FLAG_M;
           /*Bug# 7462260 Added to fetch set_of_books_id from cache*/
           h_set_of_books_id:= nvl(FA_CACHE_PKG.fazcbcs_record.set_of_books_id,
                             FA_CACHE_PKG.fazcbc_record.set_of_books_id);

        end if;

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add(l_function, 'l_exclude_fully_rsv_flag', l_exclude_fully_rsv_flag, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_function, 'use_old_adj_cost_flag', px_rule_in.use_old_adj_cost_flag, p_log_level_rec => p_log_level_rec);
        end if;

        if l_exclude_fully_rsv_flag ='Y' then

           -- Initialize before starting loop
           trc_fully_rsv_adjusted_cost := 0;
           trc_fully_rsv_salvage_value := 0;
           trc_fully_rsv_recoverable_cost := 0;
           trc_fully_rsv_deprn_reserve := 0;


           if px_rule_in.event_type not in ('AFTER_DEPRN2','AMOR_ADJ2',
                                            'AMORT_ADJ3','UNPLANNED_ADJ') then
              if px_rule_in.tracking_method='ALLOCATE' then

                 if nvl(px_rule_in.use_old_adj_cost_flag,'N')='Y' then

                    if nvl(px_rule_in.used_by_adjustment,'NULL') <> 'ADJUSTMENT' then

                       open  CUR_FULL_RSV_MEMBER_TRC (px_rule_in.period_counter);
                       fetch CUR_FULL_RSV_MEMBER_TRC into trc_fully_rsv_adjusted_cost,
                                                          trc_fully_rsv_salvage_value,
                                                          trc_fully_rsv_recoverable_cost,
                                                          trc_fully_rsv_deprn_reserve;
                       close CUR_FULL_RSV_MEMBER_TRC;

                    else -- used_by_adjsutment ='ADJUSTMENT'

                       FOR i IN 1 .. fa_track_member_pvt.p_track_member_table.COUNT LOOP
                          if fa_track_member_pvt.p_track_member_table(i).group_asset_id
                                                                  = px_rule_in.asset_id and
                             fa_track_member_pvt.p_track_member_table(i).period_counter
                                                                  =  px_rule_in.period_counter and
                             nvl(fa_track_member_pvt.p_track_member_table(i).fully_reserved_flag,'N') = 'Y' then

                             trc_fully_rsv_adjusted_cost := trc_fully_rsv_adjusted_cost +
                                         fa_track_member_pvt.p_track_member_table(i).adjusted_cost;
                             trc_fully_rsv_salvage_value := trc_fully_rsv_salvage_value +
                                         fa_track_member_pvt.p_track_member_table(i).salvage_value;
                             trc_fully_rsv_recoverable_cost := trc_fully_rsv_recoverable_cost +
                                         fa_track_member_pvt.p_track_member_table(i).recoverable_cost;
                             trc_fully_rsv_deprn_reserve := trc_fully_rsv_deprn_reserve +
                                         fa_track_member_pvt.p_track_member_table(i).deprn_reserve;

                          end if;

                       END LOOP;
                    end if; -- nvl(px_rule_in.used_by_adjustment,'NULL') <> 'ADJUSTMENT'

                 else  -- Not use old_adjusted_cost

                    if nvl(px_rule_in.used_by_adjustment,'NULL') <> 'ADJUSTMENT' then
                       --
                       -- Query fully Reserved member assets info from FA_TRACK_MEMBERS
                       --
                       open  FULL_RSV_MEMBER_TRC (px_rule_in.period_counter);
                       fetch FULL_RSV_MEMBER_TRC into trc_fully_rsv_adjusted_cost,
                                                      trc_fully_rsv_salvage_value,
                                                      trc_fully_rsv_recoverable_cost,
                                                      trc_fully_rsv_deprn_reserve;
                       close FULL_RSV_MEMBER_TRC;

                       --
                       -- Query Minimum period counter on FA_TRACK_MEMBERS
                       --
                       open  MIN_TRC_PERIOD;
                       fetch MIN_TRC_PERIOD into l_trc_min_period_counter;

                       if MIN_TRC_PERIOD%NOTFOUND then
                          l_trc_min_period_counter := px_rule_in.period_counter + 1;
                       end if;

                       close MIN_TRC_PERIOD;

                    else -- used_by_adjustment 'ADJUSTMENT'

                       FOR i IN 1 .. fa_track_member_pvt.p_track_member_table.COUNT LOOP
                          if fa_track_member_pvt.p_track_member_table(i).group_asset_id
                                                       = px_rule_in.asset_id and
                             fa_track_member_pvt.p_track_member_table(i).period_counter
                                                      <=  px_rule_in.period_counter and
                             nvl(fa_track_member_pvt.p_track_member_table(i).fully_reserved_flag,'N') = 'Y' then

                             trc_fully_rsv_adjusted_cost := trc_fully_rsv_adjusted_cost +
                                        fa_track_member_pvt.p_track_member_table(i).adjusted_cost;
                             trc_fully_rsv_salvage_value := trc_fully_rsv_salvage_value +
                                        fa_track_member_pvt.p_track_member_table(i).salvage_value;
                             trc_fully_rsv_recoverable_cost := trc_fully_rsv_recoverable_cost +
                                        fa_track_member_pvt.p_track_member_table(i).recoverable_cost;
                             trc_fully_rsv_deprn_reserve := trc_fully_rsv_deprn_reserve +
                                        fa_track_member_pvt.p_track_member_table(i).deprn_reserve;

                          end if;

                       END LOOP;

                       FOR i IN 1 .. fa_track_member_pvt.p_track_member_table.COUNT LOOP
                          if fa_track_member_pvt.p_track_member_table(i).period_counter <
                                   nvl(l_trc_min_period_counter,
                                       fa_track_member_pvt.p_track_member_table(i).period_counter+1) and
                             fa_track_member_pvt.p_track_member_table(i).member_asset_id is not null then

                             l_trc_min_period_counter := fa_track_member_pvt.p_track_member_table(i).period_counter;
                          end if;
                       END LOOP;

                       if l_trc_min_period_counter is null then
                          l_trc_min_period_counter := px_rule_in.period_counter + 1;
                       end if;

                    end if; -- nvl(px_rule_in.used_by_adjustment,'NULL') <> 'ADJUSTMENT'

                    if px_rule_in.mrc_sob_type_code <>'R' then
                       open FULL_RSV_MEMBER_BK (l_trc_min_period_counter);
                       fetch FULL_RSV_MEMBER_BK into bk_fully_rsv_adjusted_cost,
                                                     bk_fully_rsv_salvage_value,
                                                     bk_fully_rsv_recoverable_cost,
                                                     bk_fully_rsv_deprn_reserve;
                       close FULL_RSV_MEMBER_BK;
                    else -- MRC
                       open FULL_RSV_MEMBER_BK_M (l_trc_min_period_counter);
                       fetch FULL_RSV_MEMBER_BK_M into bk_fully_rsv_adjusted_cost,
                                                       bk_fully_rsv_salvage_value,
                                                       bk_fully_rsv_recoverable_cost,
                                                       bk_fully_rsv_deprn_reserve;
                       close FULL_RSV_MEMBER_BK_M;
                    end if; -- End of MRC

                 end if; -- End of use_old_adj_cost_flag

              else -- tracking method is 'CALCULATE'

                 if px_rule_in.use_old_adj_cost_flag='Y' then
                    if px_rule_in.mrc_sob_type_code <>'R' then
                       open  CUR_FULL_RSV_MEMBER_BK (px_rule_in.period_counter);
                       fetch CUR_FULL_RSV_MEMBER_BK into bk_fully_rsv_adjusted_cost,
                                                         bk_fully_rsv_salvage_value,
                                                         bk_fully_rsv_recoverable_cost;
                       close CUR_FULL_RSV_MEMBER_BK;
                    else -- MRC
                       open  CUR_FULL_RSV_MEMBER_BK_M (px_rule_in.period_counter);
                       fetch CUR_FULL_RSV_MEMBER_BK_M into bk_fully_rsv_adjusted_cost,
                                                           bk_fully_rsv_salvage_value,
                                                           bk_fully_rsv_recoverable_cost;
                       close CUR_FULL_RSV_MEMBER_BK_M;
                    end if; -- End of MRC

                 else -- use_old_adj_cost_flag is 'N'
                    if px_rule_in.mrc_sob_type_code <>'R' then
                       open ALL_FULL_RSV_MEMBER_BK (px_rule_in.period_counter);
                       fetch ALL_FULL_RSV_MEMBER_BK into bk_fully_rsv_adjusted_cost,
                                                         bk_fully_rsv_salvage_value,
                                                         bk_fully_rsv_recoverable_cost;
                       close ALL_FULL_RSV_MEMBER_BK;
                    else -- MRC
                       open ALL_FULL_RSV_MEMBER_BK_M (px_rule_in.period_counter);
                       fetch ALL_FULL_RSV_MEMBER_BK_M into bk_fully_rsv_adjusted_cost,
                                                           bk_fully_rsv_salvage_value,
                                                           bk_fully_rsv_recoverable_cost;
                       close ALL_FULL_RSV_MEMBER_BK_M;
                    end if; -- End of MRC

                 end if; -- px_rule_in.use_old_adj_cost_flag='Y'

              end if; -- px_rule_in.tracking_method='ALLOCATE'

              l_fully_rsv_adjusted_cost    := nvl(trc_fully_rsv_adjusted_cost,0) +
                                              nvl(bk_fully_rsv_adjusted_cost,0);
              l_fully_rsv_salvage_value    := nvl(trc_fully_rsv_salvage_value,0) +
                                              nvl(bk_fully_rsv_salvage_value,0);
              l_fully_rsv_recoverable_cost := nvl(trc_fully_rsv_recoverable_cost,0) +
                                              nvl(bk_fully_rsv_recoverable_cost,0);
              l_fully_rsv_deprn_reserve    := nvl(trc_fully_rsv_deprn_reserve,0) +
                                              nvl(bk_fully_rsv_deprn_reserve,0);

           end if;  -- End of Event type conditions

           if p_log_level_rec.statement_level then
              fa_debug_pkg.add(l_function, 'l_fully_rsv_adjusted_cost', l_fully_rsv_adjusted_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'l_fully_rsv_salvage_value', l_fully_rsv_salvage_value, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'l_fully_rsv_recoverable_cost', l_fully_rsv_recoverable_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_function, 'l_fully_rsv_deprn_reserve', l_fully_rsv_deprn_reserve, p_log_level_rec => p_log_level_rec);
           end if;

           if px_rule_in.eofy_flag='Y' and
              px_rule_in.calc_basis ='NBV' then
              l_fully_rsv_adjusted_cost := nvl(l_fully_rsv_recoverable_cost,0) -
                                           nvl(l_fully_rsv_deprn_reserve,0);
           end if;

           -------------------------------------------------------------------------
           -- Check Exclude salvage value flag and calculate new adjusted cost
           --
           -- If group asset's methods has the exclude salvage value flag:YES,
           -- Reduce fully reserved adjusted cost and salvage value
           -- new adjusted cost.
           -- If not, Reduce fully reserved adjusted cost only
           -------------------------------------------------------------------------

           if fa_cache_pkg.fazccmt(px_rule_in.method_code,
                                   px_rule_in.life_in_months, p_log_level_rec => p_log_level_rec) then

              if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_function, 'fazccmt',  'Called', p_log_level_rec => p_log_level_rec);
              end if;

              l_exclude_salvage_value_flag := fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag;
           end if;

           if Upper(l_exclude_salvage_value_flag) like 'Y%' and
              px_rule_in.calc_basis= 'NBV' then

              px_rule_out.new_adjusted_cost := nvl(px_rule_out.new_adjusted_cost,
                                                   px_rule_in.old_adjusted_cost) -
                                               nvl(l_fully_rsv_adjusted_cost,0) -
                                               nvl(l_fully_rsv_salvage_value,0);

           else -- Exclude salvage value flag is Off or Calc basis is COST

              px_rule_out.new_adjusted_cost := nvl(px_rule_out.new_adjusted_cost,
                                                   px_rule_in.old_adjusted_cost) -
                                               nvl(l_fully_rsv_adjusted_cost,0);

           end if;  -- End Exclude salvage value flag check

        end if; -- Exclude fully reserved flag
     end if; -- asset type is GROUP

  end if; -- (px_rule_in.method_type = 'FLAT')

  if p_log_level_rec.statement_level then
     fa_debug_pkg.add(l_function, 'new_adjusted_cost', px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;

  if nvl(l_fully_rsv_adjusted_cost,0) <> 0 then
     px_rule_out.new_deprn_rounding_flag := 'ADJ';
  end if;

exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when no_data_found then
  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'flat_extension',
                         element=>'Warning',
                         value=> SQLERRM, p_log_level_rec => p_log_level_rec);
  end if;

when others then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        raise;

end FLAT_EXTENSION;

--------------------------------------------------------------------------------
-- Procedure PERIOD_AVERAGE:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Period End Average'.
--------------------------------------------------------------------------------

PROCEDURE PERIOD_AVERAGE (
                          px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                          px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is

  -- Get current period reseve adjustments for member and standalone
  cursor GET_DEPRN_RSV is
    select nvl(sum(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'RESERVE',
                           decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount))),0) current_period_reserve
    from   fa_adjustments adj
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    adj.period_counter_created = px_rule_in.period_counter
    ;

  cursor GET_DEPRN_RSV_M is
    select nvl(sum(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'RESERVE',
                           decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount))),0) current_period_reserve
    from   fa_mc_adjustments adj
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    adj.period_counter_created = px_rule_in.period_counter
    and    adj.set_of_books_id = px_rule_in.set_of_books_id;

  -- Get current period reseve adjustments for group
  cursor GP_GET_DEPRN_RSV is
    select nvl(sum(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'RESERVE',
                          decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount))),0) current_period_reserve
    from   fa_adjustments adj,
           fa_transaction_headers th1,
           fa_transaction_headers th2
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    adj.period_counter_created = px_rule_in.period_counter
    and    adj.transaction_header_id = th1.transaction_header_id
    and    th1.member_transaction_header_id (+) = th2.transaction_header_id
    and    (th1.transaction_type_code <>'GROUP ADJUSTMENT'
            and th1.trx_reference_id is null)
    and    exists (select th2.asset_id
                   from FA_BOOKS bk
                   where th2.asset_id = bk.asset_id
                   and    bk.book_type_code = px_rule_in.book_type_code
                   and    bk.group_asset_id= px_rule_in.asset_id
                   and    bk.date_ineffective is null);

  cursor GP_GET_DEPRN_RSV_M is
    select nvl(sum(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'RESERVE',
                           decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount))),0) current_period_reserve
    from   fa_mc_adjustments adj,
           fa_transaction_headers th1,
           fa_transaction_headers th2
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    adj.period_counter_created = px_rule_in.period_counter
    and    adj.transaction_header_id = th1.transaction_header_id
    and    adj.set_of_books_id = px_rule_in.set_of_books_id
    and    th1.member_transaction_header_id (+) = th2.transaction_header_id
    and    (th1.transaction_type_code <>'GROUP ADJUSTMENT'
            and th1.trx_reference_id is null)
    and    exists (select th2.asset_id
                   from   FA_MC_BOOKS bk
                   where th2.asset_id = bk.asset_id
                    and  bk.book_type_code = px_rule_in.book_type_code
                    and  bk.group_asset_id= px_rule_in.asset_id
                    and  bk.date_ineffective is null
                    and  bk.set_of_books_id = px_rule_in.set_of_books_id);

  -- Get current deprn expense
  cursor GET_DEPRN_EXP is
    select nvl(sum(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'EXPENSE',
                           decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount))),0) current_period_expense
    from   fa_adjustments         adj,
           fa_transaction_headers th,
           fa_deprn_periods       dp
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    dp.book_type_code = px_rule_in.book_type_code
    and    adj.transaction_header_id = th.transaction_header_id
    and    th.transaction_date_entered
               between dp.calendar_period_open_date and dp.calendar_period_close_date
    and    dp.period_counter = px_rule_in.period_counter
    ;

  cursor GET_DEPRN_EXP_M is
    select nvl(sum(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'EXPENSE',
                           decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount))),0) current_period_expense
    from   fa_mc_adjustments         adj,
           fa_transaction_headers       th,
           fa_mc_deprn_periods       dp
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    dp.book_type_code = px_rule_in.book_type_code
    and    adj.transaction_header_id = th.transaction_header_id
    and    adj.set_of_books_id = px_rule_in.set_of_books_id
    and    th.transaction_date_entered
               between dp.calendar_period_open_date and dp.calendar_period_close_date
    and    dp.period_counter = px_rule_in.period_counter
    and    dp.set_of_books_id = px_rule_in.set_of_books_id;

  l_current_period_expense      NUMBER :=0;  -- Depreciation Expense at this period
  l_current_period_reserve      NUMBER :=0;  -- Reserve at this period
  l_eop_reserve                 NUMBER :=0;  -- End of prior period reserve
  l_exclude_salvage_value_flag  VARCHAR2(3) := null; -- Exclude salvage value flag
  l_retirement_reserve          NUMBER :=0;  -- Retirement Reserve

  l_calling_fn                  VARCHAR2(50) := 'fa_calc_deprn_basis2_pkg.period_average';

  calc_basis_err exception;

begin

  -------------------------------------------------------
  -- This rule is FLAT method type
  -- and Formula NBV base only
  -------------------------------------------------------
  if (px_rule_in.method_type = 'FLAT' OR
      (px_rule_in.method_type = 'FORMULA' AND
      px_rule_in.calc_basis = 'NBV')) then

     if px_rule_in.calc_basis = 'NBV' then


       ---------------------------------------------
       -- All Event types:
       -- Get the current period adjusted reserve
       -- and the current period adjusted expense
       -- And calculate Prior Period Reserve
       ---------------------------------------------
       if px_rule_in.mrc_sob_type_code <>'R' then

         if px_rule_in.asset_type ='GROUP'
         then
           open  GP_GET_DEPRN_RSV;
           fetch GP_GET_DEPRN_RSV into l_current_period_reserve;
           close GP_GET_DEPRN_RSV;
         else -- member and standalone
           open  GET_DEPRN_RSV;
           fetch GET_DEPRN_RSV into l_current_period_reserve;
           close GET_DEPRN_RSV;
         end if;

         open  GET_DEPRN_EXP;
         fetch GET_DEPRN_EXP into l_current_period_expense;
         close GET_DEPRN_EXP;

       else  -- MRC

         if px_rule_in.asset_type ='GROUP'
         then
           open  GP_GET_DEPRN_RSV_M;
           fetch GP_GET_DEPRN_RSV_M into l_current_period_reserve;
           close GP_GET_DEPRN_RSV_M;
         else -- member and standalone
           open  GET_DEPRN_RSV_M;
           fetch GET_DEPRN_RSV_M into l_current_period_reserve;
           close GET_DEPRN_RSV_M;
         end if;

         open  GET_DEPRN_EXP_M;
         fetch GET_DEPRN_EXP_M into l_current_period_expense;
         close GET_DEPRN_EXP_M;

       end if;

       l_eop_reserve := nvl(px_rule_in.current_total_rsv,0)
                         + nvl(px_rule_in.reserve_retired,0)
                         - nvl(l_current_period_expense,0)
                         + nvl(l_current_period_reserve,0);

       if p_log_level_rec.statement_level then
         fa_debug_pkg.add(fname=>'period_average',
                          element=>'l_current_period_expense',
                          value=> l_current_period_expense, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(fname=>'period_average',
                          element=>'l_current_period_reserve',
                          value=> l_current_period_reserve, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(fname=>'period_average',
                          element=>'l_eop_reserve',
                          value=> l_eop_reserve, p_log_level_rec => p_log_level_rec);
      end if;

    end if; -- px_rule_in.calc_basis = 'NBV'

    -------------------------------------------------------------
    -- All event type:
    -- Set raf and formula factor
    -------------------------------------------------------------
    px_rule_out.new_raf :=1;
    px_rule_out.new_formula_factor :=1;

    -------------------------------------------------------------
    -- Event types: ADDITION, AMORT_ADJ
    --
    -- current_total_rsv includes retired_reserve at group asset
    -------------------------------------------------------------

    if px_rule_in.event_type in ('ADDITION','AMORT_ADJ')
    then
      if px_rule_in.calc_basis='COST' then

        px_rule_out.new_adjusted_cost :=
          (nvl(px_rule_in.eop_recoverable_cost,0)
           + nvl(px_rule_in.recoverable_cost,0))/2;

      elsif px_rule_in.calc_basis = 'NBV' then

        px_rule_out.new_adjusted_cost :=
            ((nvl(px_rule_in.eop_recoverable_cost,0) - nvl(l_eop_reserve,0))
             +(nvl(px_rule_in.recoverable_cost,0)
                  - nvl(px_rule_in.current_total_rsv,0)
              ))/2;

      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- End Event type:ADDITION, AMORT_ADJ

    -------------------------------------------------------------
    -- Event types: AMORT_ADJ3
    -------------------------------------------------------------

    if px_rule_in.event_type = 'AMORT_ADJ3'
    then
          px_rule_out.new_adjusted_cost
            := px_rule_in.adjusted_cost;
          px_rule_in.use_old_adj_cost_flag :='Y';
    end if;

    -------------------------------
    -- Event type: EXPENSED_ADJ
    -------------------------------

    if px_rule_in.event_type='EXPENSED_ADJ' then

      if px_rule_in.calc_basis='COST' then
        if Upper(px_rule_in.depreciate_flag) like 'N%' then
          px_rule_out.new_adjusted_cost :=
            (nvl(px_rule_in.eop_recoverable_cost,0)
             + nvl(px_rule_in.recoverable_cost,0))/2;
        else

          px_rule_out.new_adjusted_cost :=
                      nvl(px_rule_in.recoverable_cost,0);
        end if;

      elsif px_rule_in.calc_basis = 'NBV' then

        if Upper(px_rule_in.depreciate_flag) like 'N%' then
          px_rule_out.new_adjusted_cost :=
            ((nvl(px_rule_in.eop_recoverable_cost,0) - nvl(l_eop_reserve,0))
             +(nvl(px_rule_in.recoverable_cost,0)
                  - nvl(px_rule_in.current_total_rsv,0)
              ))/2;
        else
           px_rule_out.new_adjusted_cost :=
             nvl(px_rule_in.recoverable_cost,0)
                - nvl(px_rule_in.hyp_total_rsv,0);
        end if;
      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- End event type: EXPENSED_ADJ

    ----------------------------
    -- Event type: RETIREMENT
    ----------------------------
    if px_rule_in.event_type='RETIREMENT' then

      -- Retirement with Recognized Gain and Loss Immediately When Retired
      if px_rule_in.recognize_gain_loss <>'NO' then
        if px_rule_in.cost = 0 then
          l_retirement_reserve := 0;
        else
          l_retirement_reserve
            := - nvl(px_rule_in.adjustment_amount,0)
               / px_rule_in.cost
               * nvl(px_rule_in.current_total_rsv,0);
        end if;

      else -- Do Not Recogized Gain and loss
          l_retirement_reserve
            := - nvl(px_rule_in.adjustment_amount,0)
                 + nvl(px_rule_in.nbv_retired,0);

      end if; -- End recognize_gain_loss

      if px_rule_in.calc_basis='COST' then

          px_rule_out.new_adjusted_cost :=
            (nvl(px_rule_in.eop_recoverable_cost,0)
             + nvl(px_rule_in.recoverable_cost,0))/2;

      elsif px_rule_in.calc_basis = 'NBV' then
          px_rule_out.new_adjusted_cost :=
              ((nvl(px_rule_in.eop_recoverable_cost,0) - nvl(l_eop_reserve,0))
               +(nvl(px_rule_in.recoverable_cost,0)
                    - nvl(px_rule_in.current_total_rsv,0)
                    - nvl(l_retirement_reserve,0)))/2;
      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- Event type: Retirement

    ----------------------------------------------------------------
    -- Event Type: INITIAL_ADDITION
    ----------------------------------------------------------------

    if (px_rule_in.event_type ='INITIAL_ADDITION') THEN

      px_rule_out.new_adjusted_cost :=
       nvl(px_rule_in.recoverable_cost,0)/2;

      px_rule_in.eop_salvage_value := 0;

      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'period_average',
                         element=>'updated eop_salvage_value',
                         value=> px_rule_in.eop_salvage_value, p_log_level_rec => p_log_level_rec);
      end if;

    end if; -- End of INITIAL_ADDITION

    -------------------------------------------------------------
    -- Event Type: DEPRECIATE_FLAG_ADJ (IDLE Asset Control)
    -------------------------------------------------------------
    if (px_rule_in.event_type ='DEPRECIATE_FLAG_ADJ') then
      if (px_rule_in.calc_basis = 'NBV') then

          px_rule_out.new_adjusted_cost :=
            ((nvl(px_rule_in.eop_recoverable_cost,0) - nvl(l_eop_reserve,0))
             +(nvl(px_rule_in.recoverable_cost,0)
                  - nvl(px_rule_in.current_total_rsv,0)
              ))/2;

      end if;
    end if; -- End DEPRECIATE_FLAG_ADJ

    ------------------------------------------------------------
    -- Event Type: AFTER_DEPRN (After Depreciation)
    ------------------------------------------------------------
    if (px_rule_in.event_type ='AFTER_DEPRN') THEN
      if px_rule_in.calc_basis='COST' then

        px_rule_out.new_adjusted_cost :=
         nvl(px_rule_in.recoverable_cost,0);

        px_rule_in.use_old_adj_cost_flag :='N';
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- All Event types except of 'AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ',
    -- 'AMORT_ADJ2','AMORT_ADJ3':
    -- Check exclude salvage value flag.
    -- And if exclude salvage value flag is Yes,
    -- reduce salvage value from new adjusted cost
    ---------------------------------------------------------------------------
    if fa_cache_pkg.fazccmt(px_rule_in.method_code,
                            px_rule_in.life_in_months, p_log_level_rec => p_log_level_rec) then

      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'period_average',
                         element=>'fazccmt',
                         value=> 'Called', p_log_level_rec => p_log_level_rec);
      end if;

      l_exclude_salvage_value_flag := fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag;

    end if;


    if px_rule_in.event_type
           not in ('AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ','AMORT_ADJ2','AMORT_ADJ3')
       and Upper(l_exclude_salvage_value_flag) like 'Y%'
       and px_rule_in.calc_basis= 'NBV'
    then

      px_rule_out.new_adjusted_cost :=
        px_rule_out.new_adjusted_cost
          - (nvl(px_rule_in.salvage_value,0)
             - nvl(px_rule_in.eop_salvage_value,0))/2;

    end if;

  end if; -- Flat and Formula NBV

  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'period_average',
                         element=>'new_adjusted_cost',
                         value=> px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;


exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when others then
  fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
  raise;
end PERIOD_AVERAGE;

--------------------------------------------------------------------------------
-- Procedure YTD_AVERAGE:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Year to Date Average'.
--------------------------------------------------------------------------------

PROCEDURE YTD_AVERAGE (
                       px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                       px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is

  -- Get Eofy reserve retired on current fiscal year
  Cursor C_EOFY_RESERVE_RETIRED is
    select nvl(sum(RET.EOFY_RESERVE),0)
    from   FA_RETIREMENTS         RET,
           FA_TRANSACTION_HEADERS TH,
           FA_DEPRN_PERIODS       DP,
           FA_FISCAL_YEAR         FY,
           FA_BOOK_CONTROLS       BC
    where  RET.ASSET_ID= px_rule_in.asset_id
    and    RET.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    DP.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    BC.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    RET.TRANSACTION_HEADER_ID_IN = TH.TRANSACTION_HEADER_ID
    and    BC.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    FY.FISCAL_YEAR = px_rule_in.fiscal_year
    and    DP.PERIOD_COUNTER = px_rule_in.period_counter
    and    TH.TRANSACTION_DATE_ENTERED between
              FY.START_DATE and DP.CALENDAR_PERIOD_CLOSE_DATE
    and    RET.STATUS in ('PROCESSED','PENDING')
  ;

  Cursor C_EOFY_RESERVE_RETIRED_M is
    select nvl(sum(RET.EOFY_RESERVE),0)
    from   FA_MC_RETIREMENTS   RET,
           FA_TRANSACTION_HEADERS TH,
           FA_MC_DEPRN_PERIODS DP,
           FA_FISCAL_YEAR         FY,
           FA_MC_BOOK_CONTROLS    MBC,
           FA_BOOK_CONTROLS    BC
    where  RET.ASSET_ID= px_rule_in.asset_id
    and    RET.BOOK_TYPE_CODE = px_rule_in.book_type_code
    and    RET.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    and    DP.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    DP.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    and    BC.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    MBC.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    MBC.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    and    RET.TRANSACTION_HEADER_ID_IN = TH.TRANSACTION_HEADER_ID
    and    BC.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    FY.FISCAL_YEAR = px_rule_in.fiscal_year
    and    DP.PERIOD_COUNTER = px_rule_in.period_counter
    and    TH.TRANSACTION_DATE_ENTERED between
              FY.START_DATE and DP.CALENDAR_PERIOD_CLOSE_DATE
    and    RET.STATUS in ('PROCESSED','PENDING')
  ;

  Cursor GP_EOFY_RESERVE_RETIRED is
    select nvl(sum(RET.EOFY_RESERVE),0)
    from   FA_RETIREMENTS         RET,
           FA_TRANSACTION_HEADERS TH,
           FA_DEPRN_PERIODS       DP,
           FA_FISCAL_YEAR         FY,
           FA_BOOK_CONTROLS       BC
    where  TH.ASSET_ID= px_rule_in.asset_id
    and    TH.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    DP.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    BC.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    RET.TRANSACTION_HEADER_ID_IN = TH.MEMBER_TRANSACTION_HEADER_ID (+)
    and    BC.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    FY.FISCAL_YEAR = px_rule_in.fiscal_year
    and    DP.PERIOD_COUNTER = px_rule_in.period_counter
    and    TH.TRANSACTION_DATE_ENTERED between
              FY.START_DATE and DP.CALENDAR_PERIOD_CLOSE_DATE
    and    RET.STATUS in ('PROCESSED','PENDING')
    and    exists (select RET.ASSET_ID
                   from FA_BOOKS BK
                   where RET.ASSET_ID = BK.ASSET_ID
                     and BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
                     and    BK.GROUP_ASSET_ID = px_rule_in.asset_id
                     and    BK.DATE_INEFFECTIVE is null)
         ;

  Cursor GP_EOFY_RESERVE_RETIRED_M is
    select nvl(sum(RET.EOFY_RESERVE),0)
    from   FA_MC_RETIREMENTS   RET,
           FA_TRANSACTION_HEADERS TH,
           FA_MC_DEPRN_PERIODS DP,
           FA_FISCAL_YEAR         FY,
           FA_MC_BOOK_CONTROLS  MBC,
           FA_BOOK_CONTROLS     BC
    where  TH.ASSET_ID= px_rule_in.asset_id
    and    TH.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    DP.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    DP.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    and    BC.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    MBC.BOOK_TYPE_CODE  = px_rule_in.book_type_code
    and    MBC.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    and    RET.TRANSACTION_HEADER_ID_IN = TH.MEMBER_TRANSACTION_HEADER_ID (+)
    and    RET.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    and    BC.FISCAL_YEAR_NAME = FY.FISCAL_YEAR_NAME
    and    FY.FISCAL_YEAR = px_rule_in.fiscal_year
    and    DP.PERIOD_COUNTER = px_rule_in.period_counter
    and    TH.TRANSACTION_DATE_ENTERED between
              FY.START_DATE and DP.CALENDAR_PERIOD_CLOSE_DATE
    and    RET.STATUS in ('PROCESSED','PENDING')
    and    exists (select RET.ASSET_ID
                   from FA_MC_BOOKS BK
                   where RET.ASSET_ID = BK.ASSET_ID
                     and BK.BOOK_TYPE_CODE = px_rule_in.book_type_code
                     and BK.GROUP_ASSET_ID = px_rule_in.asset_id
                     and BK.DATE_INEFFECTIVE is null
                     and BK.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id)
  ;

  -- current transaction's member eofy reserve retired
  Cursor CUR_EOFY_RESERVE_RETIRED is
    select nvl(sum(RET.EOFY_RESERVE),0)
    from   FA_RETIREMENTS         RET
    where  RET.TRANSACTION_HEADER_ID_IN = px_rule_in.adj_mem_transaction_header_id
    ;

  Cursor CUR_EOFY_RESERVE_RETIRED_M is
    select nvl(sum(RET.EOFY_RESERVE),0)
    from   FA_MC_RETIREMENTS   RET
    where  RET.TRANSACTION_HEADER_ID_IN = px_rule_in.adj_mem_transaction_header_id
    and    RET.SET_OF_BOOKS_ID = px_rule_in.set_of_books_id
    ;

  l_retired_eofy_reserve         NUMBER := 0;
  l_cur_retired_eofy_reserve     NUMBER := 0;
  l_old_eofy_reserve             NUMBER := 0;
  l_exclude_salvage_value_flag   VARCHAR2(3) :=null;
  l_retirement_reserve           NUMBER :=0;  -- Retirement Reserve

  l_calling_fn                   VARCHAR2(50) := 'fa_calc_deprn_basis2_pkg.ytd_average';

  calc_basis_err exception;

begin

  -------------------------------------------------------
  -- This rule is FLAT method type only
  -------------------------------------------------------
  if (px_rule_in.method_type = 'FLAT') then

    -------------------------------------
    -- Get old eofy_reserve
    -------------------------------------
    if px_rule_in.mrc_sob_type_code <>'R' then
      if px_rule_in.asset_type = 'GROUP' then
        OPEN  GP_EOFY_RESERVE_RETIRED;
        FETCH GP_EOFY_RESERVE_RETIRED into l_retired_eofy_reserve;
        CLOSE GP_EOFY_RESERVE_RETIRED;

        OPEN  CUR_EOFY_RESERVE_RETIRED;
        FETCH CUR_EOFY_RESERVE_RETIRED into l_cur_retired_eofy_reserve;
        CLOSE CUR_EOFY_RESERVE_RETIRED;

      else -- member and standalone
        OPEN  C_EOFY_RESERVE_RETIRED;
        FETCH C_EOFY_RESERVE_RETIRED into l_retired_eofy_reserve;
        CLOSE C_EOFY_RESERVE_RETIRED;
      end if;
    else -- MRC
      if px_rule_in.asset_type = 'GROUP' then
        OPEN  GP_EOFY_RESERVE_RETIRED_M;
        FETCH GP_EOFY_RESERVE_RETIRED_M into l_retired_eofy_reserve;
        CLOSE GP_EOFY_RESERVE_RETIRED_M;

        OPEN  CUR_EOFY_RESERVE_RETIRED_M;
        FETCH CUR_EOFY_RESERVE_RETIRED_M into l_cur_retired_eofy_reserve;
        CLOSE CUR_EOFY_RESERVE_RETIRED_M;

      else -- member and standalone
        OPEN  C_EOFY_RESERVE_RETIRED_M;
        FETCH C_EOFY_RESERVE_RETIRED_M into l_retired_eofy_reserve;
        CLOSE C_EOFY_RESERVE_RETIRED_M;
      end if;
    end if;

    l_old_eofy_reserve := nvl(px_rule_in.eofy_reserve,0)
                           + nvl(l_retired_eofy_reserve,0)
                           + nvl(l_cur_retired_eofy_reserve,0);

    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'ytd_average',
                       element=>'l_retired_eofy_reserve',
                       value=> l_retired_eofy_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'ytd_average',
                       element=>'l_cur_retired_eofy_reserve',
                       value=> l_cur_retired_eofy_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'ytd_average',
                       element=>'l_old_eofy_reserve',
                       value=> l_old_eofy_reserve, p_log_level_rec => p_log_level_rec);
    end if;

    -- End of getting old eofy_reserve

    --------------------------------------------------------------
    -- Event types: ADDITION, AMORT_ADJ
    --
    -- current_total_rsv includes retired_reserve at group asset
    --------------------------------------------------------------

    if px_rule_in.event_type in ('ADDITION','AMORT_ADJ')
    then
      if px_rule_in.calc_basis='COST' then

        px_rule_out.new_adjusted_cost :=
          (nvl(px_rule_in.eofy_recoverable_cost,0)
           + nvl(px_rule_in.recoverable_cost,0))/2;

      elsif px_rule_in.calc_basis = 'NBV' then

        px_rule_out.new_adjusted_cost :=
          ((nvl(px_rule_in.eofy_recoverable_cost,0)
                - nvl(l_old_eofy_reserve,0))
           +(nvl(px_rule_in.recoverable_cost,0)
                - nvl(px_rule_in.current_total_rsv,0)
            ))/2;

      else -- unexpected calc_basis
        raise calc_basis_err;

      end if; -- End calc_basis

    end if; -- End Event type:ADDITION, AMORT_ADJ

    ------------------------------
    -- Event type: EXPENSED_ADJ
    ------------------------------

    if px_rule_in.event_type='EXPENSED_ADJ' then

      if px_rule_in.calc_basis='COST' then
        if Upper(px_rule_in.depreciate_flag) like 'N%' then
          px_rule_out.new_adjusted_cost :=
            (nvl(px_rule_in.eofy_recoverable_cost,0)
             + nvl(px_rule_in.recoverable_cost,0))/2;
        else
          px_rule_out.new_adjusted_cost :=
                      nvl(px_rule_in.recoverable_cost,0);
        end if;
      elsif px_rule_in.calc_basis = 'NBV' then
        if Upper(px_rule_in.depreciate_flag) like 'N%' then
          px_rule_out.new_adjusted_cost :=
            ((nvl(px_rule_in.eofy_recoverable_cost,0)
                - nvl(l_old_eofy_reserve,0))
             +(nvl(px_rule_in.recoverable_cost,0)
                - nvl(px_rule_in.current_total_rsv,0)
              ))/2;
        else
          px_rule_out.new_adjusted_cost :=
           nvl(px_rule_in.recoverable_cost,0)
                - nvl(px_rule_in.hyp_total_rsv,0)
                + nvl(px_rule_in.hyp_total_ytd,0);
        end if;
      else -- unexpected calc_basis
        raise calc_basis_err;

      end if; -- End calc_basis

    end if; -- End event type: EXPENSED_ADJ

    ---------------------------
    -- Event type: RETIREMENT
    ---------------------------
    if px_rule_in.event_type='RETIREMENT' then

      -- Retirement with Recognized Gain and Loss Immediately When Retired
      if px_rule_in.recognize_gain_loss<>'NO' then
        if px_rule_in.cost = 0 then
          l_retirement_reserve := 0;
        else
          l_retirement_reserve
            := - nvl(px_rule_in.adjustment_amount,0)
               / px_rule_in.cost
               * nvl(px_rule_in.current_total_rsv,0);
        end if;

      else -- Do Not Recogized Gain and loss
          l_retirement_reserve
            := - nvl(px_rule_in.adjustment_amount,0)
                + nvl(px_rule_in.nbv_retired,0);

      end if; -- End recognize_gain_loss

      if px_rule_in.calc_basis='COST' then

          px_rule_out.new_adjusted_cost :=
            (nvl(px_rule_in.eofy_recoverable_cost,0)
             + nvl(px_rule_in.recoverable_cost,0))/2;

      elsif px_rule_in.calc_basis = 'NBV' then
          px_rule_out.new_adjusted_cost :=
              ((nvl(px_rule_in.eofy_recoverable_cost,0)
               - nvl(l_old_eofy_reserve,0))
               +(nvl(px_rule_in.recoverable_cost,0)
                  - nvl(px_rule_in.current_total_rsv,0)
                  - nvl(l_retirement_reserve,0)))/2;

      else -- unexpected calc_basis
        raise calc_basis_err;

      end if; -- End calc_basis

    end if; -- Event type: Retirement

    -------------------------------------------------
    -- Event types: AFTER_DEPRN
    -------------------------------------------------

    if px_rule_in.event_type ='AFTER_DEPRN'
    then
      if px_rule_in.calc_basis='NBV' then

        if px_rule_in.eofy_flag ='Y' then

          px_rule_out.new_adjusted_cost
            := px_rule_in.recoverable_cost
                 - px_rule_in.current_total_rsv;
        else

          px_rule_out.new_adjusted_cost :=
            ((nvl(px_rule_in.eofy_recoverable_cost,0)
                  - nvl(px_rule_in.eofy_reserve,0))
             +(nvl(px_rule_in.recoverable_cost,0)
                  - nvl(px_rule_in.current_total_rsv,0)))/2;

        end if;  -- eofy flag

      elsif px_rule_in.calc_basis = 'COST' then

        if px_rule_in.eofy_flag ='Y' then
          px_rule_out.new_adjusted_cost :=
             nvl(px_rule_in.recoverable_cost,0);
          px_rule_in.use_old_adj_cost_flag :='N';
        end if;

      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- End Event type: AFTER_DEPRN

    ----------------------------------------------------------------
    -- Event Type: INITIAL_ADDITION
    ----------------------------------------------------------------

    if (px_rule_in.event_type ='INITIAL_ADDITION') THEN

      px_rule_out.new_adjusted_cost :=
       nvl(px_rule_in.recoverable_cost,0)/2;

      px_rule_in.eofy_salvage_value := 0;

      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'ytd_average',
                         element=>'updated eop_salvage_value',
                         value=> px_rule_in.eofy_salvage_value, p_log_level_rec => p_log_level_rec);
      end if;

    end if; -- End of INITIAL_ADDITION

    -------------------------------------------------------------
    -- Event Type: DEPRECIATE_FLAG_ADJ (IDLE Asset Control)
    -------------------------------------------------------------
    if (px_rule_in.event_type ='DEPRECIATE_FLAG_ADJ') then
      if (px_rule_in.calc_basis = 'NBV') then
          px_rule_out.new_adjusted_cost :=
            ((nvl(px_rule_in.eofy_recoverable_cost,0)
                - nvl(l_old_eofy_reserve,0))
             +(nvl(px_rule_in.recoverable_cost,0)
                - nvl(px_rule_in.current_total_rsv,0)
              ))/2;
      end if;
    end if; -- End DEPRECIATE_FLAG_ADJ

    ------------------------------------------------------------
    -- All Event types except of 'AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ',
    -- 'AMORT_ADJ2','AMORT_ADJ3':
    -- Check exclude salvage value flag.
    -- And if exclude salvage value flag is Yes,
    -- reduce salvage value from new adjusted cost
    ------------------------------------------------------------

    if fa_cache_pkg.fazccmt(px_rule_in.method_code,
                            px_rule_in.life_in_months, p_log_level_rec => p_log_level_rec) then

      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'ytd_average',
                         element=>'fazccmt',
                         value=> 'Called', p_log_level_rec => p_log_level_rec);
      end if;

      l_exclude_salvage_value_flag := nvl(fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag,0);

    end if;


    if (px_rule_in.event_type
           not in ('AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ','AMORT_ADJ2','AMORT_ADJ3')
        or (px_rule_in.event_type = 'AFTER_DEPRN'
            and px_rule_in.eofy_flag <>'Y'))
       and Upper(l_exclude_salvage_value_flag) like 'Y%'
       and px_rule_in.calc_basis= 'NBV'
    then

      px_rule_out.new_adjusted_cost :=
        nvl(px_rule_out.new_adjusted_cost,0)
          - (nvl(px_rule_in.salvage_value,0)
             - nvl(px_rule_in.eofy_salvage_value,0))/2;

    end if;

  end if; -- End Flat method type

  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'ytd_average',
                         element=>'new_adjusted_cost',
                         value=> px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;

exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when others then
  fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
  raise;
end YTD_AVERAGE;

--------------------------------------------------------------------------------
-- Procedure POSITIVE_REDUCTION:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Year End Balance with Positive Reduction'.
--------------------------------------------------------------------------------

PROCEDURE POSITIVE_REDUCTION (
                       px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                       px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                       , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is

  -- Cursor to check exclude_proceeds_from_basis
  cursor C_CHECK_FLAGS (p_asset_id number)
  is
  select EXCLUDE_PROCEEDS_FROM_BASIS,
         MEMBER_ROLLUP_FLAG
  from   FA_BOOKS
  where  ASSET_ID = p_asset_id
  and    BOOK_TYPE_CODE = px_rule_in.book_type_code
  and    date_ineffective is null;

   -- MRC
  cursor C_CHECK_FLAGS_M (p_asset_id number)
  is
  select EXCLUDE_PROCEEDS_FROM_BASIS,
         MEMBER_ROLLUP_FLAG
  from   FA_MC_BOOKS
  where  ASSET_ID = p_asset_id
  and    BOOK_TYPE_CODE = px_rule_in.book_type_code
  and    date_ineffective is null
  and    SET_OF_BOOKS_ID = px_rule_in.set_of_books_id ;

  -- Cursor to calculate sum of member assets' eofy_reserve
  cursor C_SUMUP_EOFY_RESERVE
  is
  select sum(nvl(EOFY_RESERVE,0))
  from   FA_BOOKS
  where  GROUP_ASSET_ID = px_rule_in.asset_id
  and    BOOK_TYPE_CODE = px_rule_in.book_type_code
  and    DATE_INEFFECTIVE is null;

   -- MRC
  cursor C_SUMUP_EOFY_RESERVE_M
  is
  select sum(nvl(EOFY_RESERVE,0))
  from   FA_MC_BOOKS
  where  GROUP_ASSET_ID = px_rule_in.asset_id
  and    BOOK_TYPE_CODE = px_rule_in.book_type_code
  and    DATE_INEFFECTIVE is null
  and    SET_OF_BOOKS_ID = px_rule_in.set_of_books_id;

  l_change_in_cost              NUMBER :=0;
  l_change_in_cost_to_reduce    NUMBER :=0;
  l_total_change_in_cost        NUMBER :=0;
  l_net_proceeds                NUMBER :=0;
  l_net_proceeds_to_reduce      NUMBER :=0;
  l_total_net_proceeds          NUMBER :=0;
  l_first_half_cost             NUMBER :=0;
  l_first_half_cost_to_reduce   NUMBER :=0;
  l_second_half_cost            NUMBER :=0;
  l_second_half_cost_to_reduce  NUMBER :=0;

  l_retired_cost                NUMBER :=0;
  l_ltd_proceeds                NUMBER :=0;
  l_ytd_proceeds                NUMBER :=0;

  l_exclude_proceeds_from_basis VARCHAR2(1) :=NULL;
  l_tmp_asset_id                NUMBER(15) := NULL;

  l_member_eofy_reserve         NUMBER :=0;

  l_calling_fn                  VARCHAR2(50) := 'fa_calc_deprn_basis2_pkg.positive_reduction';

  call_reduction_amount_err     exception;
  positive_reduction_err        exception;
  calc_basis_err                exception;

begin


  -------------------------------------------------------
  -- This rule is FLAT method type only
  -------------------------------------------------------
  if (px_rule_in.method_type = 'FLAT') then

    -- Check exclude_proceeds_from_basis flag

    if px_rule_in.group_asset_id is not null then
      l_tmp_asset_id := px_rule_in.group_asset_id;
    else
      l_tmp_asset_id := px_rule_in.asset_id;
    end if;

    if px_rule_in.mrc_sob_type_code <>'R' then
      OPEN  C_CHECK_FLAGS(l_tmp_asset_id);
      FETCH C_CHECK_FLAGS into l_exclude_proceeds_from_basis,
                               px_rule_in.member_rollup_flag;
      CLOSE C_CHECK_FLAGS;
    else --MRC
      OPEN  C_CHECK_FLAGS_M(l_tmp_asset_id);
      FETCH C_CHECK_FLAGS_M into l_exclude_proceeds_from_basis,
                                 px_rule_in.member_rollup_flag;
      CLOSE C_CHECK_FLAGS_M;
    end if;

    if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'positive_reduction',
                         element=>'l_exclude_proceeds_from_basis',
                         value=> l_exclude_proceeds_from_basis, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(fname=>'positive_reduction',
                         element=>'member_rollup_flag',
                         value=> px_rule_in.member_rollup_flag, p_log_level_rec => p_log_level_rec);
    end if;

    ------------------------------------------------------
    -- Event TYPE: AMORT_ADJ
    ------------------------------------------------------
    if px_rule_in.event_type ='AMORT_ADJ'
    then
      ---------------------------------------------------
      -- This is to calculate group asset's adjusted_cost
      -- when group assest is CALCULATE/SUMUP
      ---------------------------------------------------

      if px_rule_in.asset_type='GROUP'
       and nvl(px_rule_in.tracking_method,'NULL')='CALCULATE'
       and nvl(px_rule_in.member_rollup_flag,'NULL')='Y'
      then
        -- Calculate sum of member's eofy_reserve
        if px_rule_in.mrc_sob_type_code <>'R' then
          OPEN  C_SUMUP_EOFY_RESERVE;
          FETCH C_SUMUP_EOFY_RESERVE into l_member_eofy_reserve;
          CLOSE C_SUMUP_EOFY_RESERVE;
        else --MRC
          OPEN  C_SUMUP_EOFY_RESERVE_M;
          FETCH C_SUMUP_EOFY_RESERVE_M into l_member_eofy_reserve;
          CLOSE C_SUMUP_EOFY_RESERVE_M;
        end if;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(fname=>'positive_reduction',
                           element=>'l_member_eofy_reserve',
                           value=> l_member_eofy_reserve, p_log_level_rec => p_log_level_rec);
        end if;

        -- Recalculate new_adjusted_cost using member's eofy_reserve
        if nvl(px_rule_in.member_transaction_type_code,'NULL')
          like '%RETIREMENT'
        then -- This is always Do Not Gain/Loss

          if px_rule_in.calc_basis = 'NBV' then
            px_rule_out.new_adjusted_cost :=
              px_rule_in.recoverable_cost
                 - px_rule_in.adjustment_amount
                 - nvl(l_member_eofy_reserve,0)
                 - nvl(px_rule_in.member_proceeds,0);
          end if; -- End of calc_basis

        else -- Normal Adjustment
          if px_rule_in.calc_basis = 'NBV' then
            px_rule_out.new_adjusted_cost
             := px_rule_in.recoverable_cost
                - l_member_eofy_reserve;
          end if;
        end if; -- End of Group Retirement or Normal Adjustment
      end if;  -- End of Group asset and calculate/sumup

    end if; -- End of AMORT_ADJ

    ------------------------------------------------------
    -- Event TYPE: RETIREMENT
    ------------------------------------------------------
    if px_rule_in.event_type ='RETIREMENT' then

      -- Adjustment amount is cost retired.
      -- Changed positive amount to nevative amount.

      px_rule_in.adjustment_amount
            := - px_rule_in.adjustment_amount;

    end if; -- event type:RETIREMENT

    ------------------------------------------------------
    -- Event TYPE: AFTER_DEPRN
    ------------------------------------------------------
    if px_rule_in.event_type ='AFTER_DEPRN' then
      if px_rule_in.calc_basis ='COST'
       and px_rule_in.eofy_flag ='Y' then  -- End of Fiscal Year

        -- For Class 13
        if px_rule_in.asset_type='GROUP'
         and px_rule_in.tracking_method ='CALCULATE'
         and px_rule_in.member_rollup_flag ='Y'
        then
          px_rule_out.new_adjusted_cost
           := px_rule_in.recoverable_cost
                - px_rule_in.current_total_rsv;
        else
          px_rule_out.new_adjusted_cost
           := px_rule_in.recoverable_cost;
        end if;

      end if;
    end if;

    --------------------------------------------------------
    -- Treated Class 13 (Cost Base) :
    -- When asset is retired, don't subtruct retired cost
    -- from depreciable basis.
    -- Because of this, retire costs of all retirements
    -- are added.
    ---------------------------------------------------------
    if px_rule_in.calc_basis ='COST'
    and px_rule_in.event_type
             not in ('AFTER_DEPRN2','UNPLANNED_ADJ','AMORT_ADJ2','AMORT_ADJ3','DEPRECIATE_FLAG_ADJ')
    then

      if px_rule_in.asset_type='GROUP'
         and px_rule_in.tracking_method ='CALCULATE'
         and px_rule_in.member_rollup_flag ='Y'
         and px_rule_in.event_type <>'AFTER_DEPRN'
      then
        -- Class 13 Report Purpose
        -- Only this condition, the adjusted cost is NBV.
        -- This adjusted cost is not used by the calculation of depreciation engine.

        -- Calcluation of proceeds
        if not FA_CALC_DEPRN_BASIS1_PKG.CALC_PROCEEDS (
                 p_asset_id          => px_rule_in.asset_id,
                 p_asset_type        => px_rule_in.asset_type,
                 p_book_type_code    => px_rule_in.book_type_code,
                 p_period_counter    => px_rule_in.period_counter,
                 p_mrc_sob_type_code => px_rule_in.mrc_sob_type_code,
                 p_set_of_books_id   => px_rule_in.set_of_books_id,
                 x_ltd_proceeds      => l_ltd_proceeds,
                 x_ytd_proceeds      => l_ytd_proceeds
                 , p_log_level_rec => p_log_level_rec)
        then
         raise positive_reduction_err;
        end if; -- End of call CALC_PROCEEDS

        if not FA_CALC_DEPRN_BASIS1_PKG.CALC_RETIRED_COST (
          p_event_type        => px_rule_in.event_type,
          p_asset_id          => px_rule_in.asset_id,
          p_asset_type        => px_rule_in.asset_type,
          p_book_type_code    => px_rule_in.book_type_code,
          p_fiscal_year       => px_rule_in.fiscal_year,
          p_period_num        => px_rule_in.period_num,
          p_adjustment_amount => px_rule_in.adjustment_amount,
          p_ltd_ytd_flag      => 'YTD',
          p_mrc_sob_type_code => px_rule_in.mrc_sob_type_code,
          p_set_of_books_id   => px_rule_in.set_of_books_id,
          x_retired_cost      => l_retired_cost
         , p_log_level_rec => p_log_level_rec)
        then
          raise call_reduction_amount_err;
        end if; -- End of call CALC_RETIRED_COST

        if  nvl(px_rule_in.member_transaction_type_code,'NULL')
            like '%RETIREMENT'
        then
          px_rule_out.new_adjusted_cost
           := px_rule_in.recoverable_cost
             + nvl(l_retired_cost,0)
             - nvl(px_rule_in.eofy_reserve,0)
             - nvl(l_ytd_proceeds,0)
             - nvl(px_rule_in.adjustment_amount,0)
             - nvl(px_rule_in.member_proceeds,0);
        else -- Except of RETIREMENT
          px_rule_out.new_adjusted_cost
           := px_rule_in.recoverable_cost
             + nvl(l_retired_cost,0)
             - nvl(px_rule_in.eofy_reserve,0)
             - nvl(l_ytd_proceeds,0);

        end if;

      else
        if px_rule_in.asset_type<>'GROUP'
           and px_rule_in.tracking_method ='CALCULATE'
           and not (px_rule_in.event_type = 'AFTER_DEPRN'
                     and px_rule_in.eofy_flag ='N')
        then

          if not FA_CALC_DEPRN_BASIS1_PKG.CALC_RETIRED_COST (
            p_event_type        => px_rule_in.event_type,
            p_asset_id          => px_rule_in.asset_id,
            p_asset_type        => px_rule_in.asset_type,
            p_book_type_code    => px_rule_in.book_type_code,
            p_fiscal_year       => px_rule_in.fiscal_year,
            p_period_num        => px_rule_in.period_num,
            p_adjustment_amount => px_rule_in.adjustment_amount,
            p_ltd_ytd_flag      => 'LTD',
            p_mrc_sob_type_code => px_rule_in.mrc_sob_type_code,
            p_set_of_books_id   => px_rule_in.set_of_books_id,
            x_retired_cost      => l_retired_cost
           , p_log_level_rec => p_log_level_rec)
          then
            raise call_reduction_amount_err;
          end if;

          px_rule_out.new_adjusted_cost
           := nvl(px_rule_out.new_adjusted_cost,0) + nvl(l_retired_cost,0);
        end if;

      end if; -- End of Class 13 Report Purpose

    end if;  -- Cost Base

    -------------------------------------------------------
    -- Treated Class 10.1 (NBV Base) :
    -- When asset is retired, don't subtract proceeds
    -- from deprn basis.
    -- Because of this, proceeds are added.
    -------------------------------------------------------
    if px_rule_in.calc_basis ='NBV'
      and px_rule_in.tracking_method='CALCULATE'
      and px_rule_in.member_rollup_flag='Y'
      and  l_exclude_proceeds_from_basis='Y'
      and px_rule_in.event_type
             not in ('AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ','AMORT_ADJ2','AMORT_ADJ3')
    then

      -- Calcluation of proceeds
      if not FA_CALC_DEPRN_BASIS1_PKG.CALC_PROCEEDS (
               p_asset_id          => px_rule_in.asset_id,
               p_asset_type        => px_rule_in.asset_type,
               p_book_type_code    => px_rule_in.book_type_code,
               p_period_counter    => px_rule_in.period_counter,
               p_mrc_sob_type_code => px_rule_in.mrc_sob_type_code,
               p_set_of_books_id   => px_rule_in.set_of_books_id,
               x_ltd_proceeds      => l_ltd_proceeds,
               x_ytd_proceeds      => l_ytd_proceeds
               , p_log_level_rec => p_log_level_rec)
      then
         raise positive_reduction_err;
      end if; -- End of call CALC_PROCEEDS

      if px_rule_in.asset_type='GROUP' then
        px_rule_out.new_adjusted_cost
         := nvl(px_rule_out.new_adjusted_cost,0) + nvl(l_ytd_proceeds,0)
            + nvl(px_rule_in.member_proceeds,0);
      else
        px_rule_out.new_adjusted_cost
         := nvl(px_rule_out.new_adjusted_cost,0) + nvl(l_ytd_proceeds,0)
            + nvl(px_rule_in.nbv_retired,0);
      end if;
    end if; -- End of Class 10.1

    ----------------------------------------
    -- Call CALC_REDUCTION_AMOUNT function
    ----------------------------------------

    if px_rule_in.event_type
             not in ('AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ','AMORT_ADJ2','AMORT_ADJ3')
    then

      if not FA_CALC_DEPRN_BASIS1_PKG.CALC_REDUCTION_AMOUNT
        (
         p_asset_id                   => px_rule_in.asset_id,
         p_group_asset_id             => px_rule_in.group_asset_id,
         p_asset_type                 => px_rule_in.asset_type,
         p_book_type_code             => px_rule_in.book_type_code,
         p_period_counter             => px_rule_in.period_counter,
         p_transaction_date           => px_rule_in.adj_transaction_date_entered,
         p_half_year_rule_flag        =>  'N',
         p_mrc_sob_type_code          => px_rule_in.mrc_sob_type_code,
         p_set_of_books_id            => px_rule_in.set_of_books_id,
         x_change_in_cost             => l_change_in_cost,
         x_change_in_cost_to_reduce   => l_change_in_cost_to_reduce,
         x_total_change_in_cost       => l_total_change_in_cost,
         x_net_proceeds               => l_net_proceeds,
         x_net_proceeds_to_reduce     => l_net_proceeds_to_reduce,
         x_total_net_proceeds         => l_total_net_proceeds,
         x_first_half_cost            => l_first_half_cost,
         x_first_half_cost_to_reduce  => l_first_half_cost_to_reduce,
         x_second_half_cost           => l_second_half_cost,
         x_second_half_cost_to_reduce => l_second_half_cost_to_reduce
        , p_log_level_rec => p_log_level_rec)
      then

        raise call_reduction_amount_err;

      end if; -- Call CALC_REDUCTION_AMOUNT
    end if; -- Condition of CALC_REDUCTION_AMOUNT call

    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'positive_reduction',
                       element=>'l_change_in_cost',
                           value=> l_change_in_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'positive_reduction',
                       element=>'l_change_in_cost_to_reduce',
                       value=> l_change_in_cost_to_reduce, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'positive_reduction',
                       element=>'l_total_change_in_cost',
                       value=> l_total_change_in_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'positive_reduction',
                       element=>'l_net_proceeds',
                       value=> l_net_proceeds, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'positive_reduction',
                       element=>'l_net_proceeds_to_reduce',
                       value=> l_net_proceeds_to_reduce, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'positive_reduction',
                       element=>'l_total_net_proceeds',
                       value=> l_total_net_proceeds, p_log_level_rec => p_log_level_rec);
    end if;

    -- Check to apply reduction amount and calculate reduction amount

    If (l_change_in_cost - l_net_proceeds >0
        and px_rule_in.apply_reduction_flag is null)
      or nvl(px_rule_in.apply_reduction_flag,'N') ='Y'
     then
       if px_rule_in.calc_basis ='COST'
         and not (px_rule_in.asset_type='GROUP'
                  and nvl(px_rule_in.tracking_method,'NULL') ='CALCULATE'
                  and nvl(px_rule_in.member_rollup_flag,'X') ='Y')
       then
         px_rule_in.reduction_amount
           := nvl(l_change_in_cost_to_reduce,0);
       else -- NBV Base and Class 13's Group Asset
         px_rule_in.reduction_amount
           := nvl(l_change_in_cost_to_reduce,0)
               - nvl(l_net_proceeds_to_reduce,0);
       end if;
    else
      px_rule_in.reduction_amount := 0;

    end if;  -- Reduction amount condition

    if px_rule_in.asset_type='GROUP'
     and px_rule_in.reduction_amount<>0 then
       -- Apply reduction amount to group asset
       px_rule_in.apply_reduction_flag :='Y';
    end if;

  end if; -- End Flat method type

  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'positive_reduction',
                         element=>'new_adjusted_cost',
                         value=> px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(fname=>'positive_reduction',
                         element=>'reduction_amount',
                         value=> px_rule_in.reduction_amount, p_log_level_rec => p_log_level_rec);
  end if;

exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when call_reduction_amount_err then
        fa_srvr_msg.add_message (
                calling_fn => l_calling_fn,
                name => 'FA_SHARED_UNKNOWN_ERROR',
                translate => TRUE
                , p_log_level_rec => p_log_level_rec);
        raise;

when positive_reduction_err then
  fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
  raise;

when others then
  fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
  raise;
end POSITIVE_REDUCTION;

--------------------------------------------------------------------------------
-- Procedure HALF_YEAR:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Year End Balance with Half Year Rule'.
--------------------------------------------------------------------------------

PROCEDURE HALF_YEAR (
                     px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                     px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is

  l_change_in_cost              NUMBER :=0;
  l_change_in_cost_to_reduce    NUMBER :=0;
  l_total_change_in_cost        NUMBER :=0;
  l_net_proceeds                NUMBER :=0;
  l_net_proceeds_to_reduce      NUMBER :=0;
  l_total_net_proceeds          NUMBER :=0;
  l_first_half_cost             NUMBER :=0;
  l_first_half_cost_to_reduce   NUMBER :=0;
  l_second_half_cost            NUMBER :=0;
  l_second_half_cost_to_reduce  NUMBER :=0;

  l_first_reduction_amount      NUMBER :=0;
  l_fy_begin_nbv                NUMBER :=0;
  l_check_amount                NUMBER :=0;

  l_calling_fn                  VARCHAR2(50) := 'fa_calc_deprn_basis2_pkg.half_year';

  calc_basis_err                exception;

begin

  ------------------------------------------------------
  -- Event TYPE: RETIREMENT
  ------------------------------------------------------
  if px_rule_in.event_type ='RETIREMENT' then

   -- Adjustment amount is cost retired.
   -- Changed positive amount to negative amount.

   px_rule_in.adjustment_amount
            := - px_rule_in.adjustment_amount;
  end if;

  -------------------------------------------------------
  -- This rule is FLAT method type only
  -------------------------------------------------------
  if (px_rule_in.method_type = 'FLAT') then

    ----------------------------------------
    -- Call CALC_REDUCTION_AMOUNT function
    ----------------------------------------

    if px_rule_in.event_type
             not in ('AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ','AMORT_ADJ2','AMORT_ADJ3')
    then

      if not FA_CALC_DEPRN_BASIS1_PKG.CALC_REDUCTION_AMOUNT
        (
         p_asset_id                   => px_rule_in.asset_id,
         p_group_asset_id             => px_rule_in.group_asset_id,
         p_asset_type                 => px_rule_in.asset_type,
         p_book_type_code             => px_rule_in.book_type_code,
         p_period_counter             => px_rule_in.period_counter,
         p_transaction_date           => px_rule_in.adj_transaction_date_entered,
         p_half_year_rule_flag        => 'Y',
         p_mrc_sob_type_code          => px_rule_in.mrc_sob_type_code,
         p_set_of_books_id            => px_rule_in.set_of_books_id,
         x_change_in_cost             => l_change_in_cost,
         x_change_in_cost_to_reduce   => l_change_in_cost_to_reduce,
         x_total_change_in_cost       => l_total_change_in_cost,
         x_net_proceeds               => l_net_proceeds,
         x_net_proceeds_to_reduce     => l_net_proceeds_to_reduce,
         x_total_net_proceeds         => l_total_net_proceeds,
         x_first_half_cost            => l_first_half_cost,
         x_first_half_cost_to_reduce  => l_first_half_cost_to_reduce,
         x_second_half_cost           => l_second_half_cost,
         x_second_half_cost_to_reduce => l_second_half_cost_to_reduce
        , p_log_level_rec => p_log_level_rec)
      then

        fa_srvr_msg.add_message (
                calling_fn => l_calling_fn,
                name => 'FA_SHARED_UNKNOWN_ERROR',
                translate => FALSE
                , p_log_level_rec => p_log_level_rec);

      end if; -- Call CALC_REDUCTION_AMOUNT
    end if; -- Condition of CALC_REDUCTION_AMOUNT call

    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_change_in_cost',
                           value=> l_change_in_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_change_in_cost_to_reduce',
                       value=> l_change_in_cost_to_reduce, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_total_change_in_cost',
                       value=> l_total_change_in_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_net_proceeds',
                       value=> l_net_proceeds, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_net_proceeds_to_reduce',
                       value=> l_net_proceeds_to_reduce, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_total_net_proceeds',
                       value=> l_total_net_proceeds, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_first_half_cost',
                       value=> l_first_half_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_first_half_cost_to_reduce',
                       value=> l_first_half_cost_to_reduce, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_second_half_cost',
                       value=> l_second_half_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_second_half_cost_to_reduce',
                       value=> l_second_half_cost_to_reduce, p_log_level_rec => p_log_level_rec);
    end if;

    -- Check whether 1st half year's reduction amount
    l_fy_begin_nbv
       := nvl(px_rule_in.eofy_recoverable_cost,0)
         + nvl(px_rule_in.eofy_salvage_value,0)
         - nvl(px_rule_in.eofy_reserve,0);

    l_check_amount
      := nvl(l_fy_begin_nbv,0)
         + nvl(l_first_half_cost,0) - nvl(l_net_proceeds,0);

    -- Calculate first reduction amount
    if (l_check_amount < 0
       and px_rule_in.apply_reduction_flag is null)
      or nvl(px_rule_in.apply_reduction_flag,'N') ='Y'
    then

      l_first_reduction_amount
          := l_check_amount
             *nvl(px_rule_in.reduction_rate,0);

      if px_rule_in.asset_type='GROUP'
       and l_first_reduction_amount<>0 then
         -- Apply reduction amount to group asset
         px_rule_in.apply_reduction_flag :='Y';
      end if;

    else

      l_first_reduction_amount :=0;

    end if; -- End calculate first reduction amount

    -- Cacluate reduction_amount
    if p_log_level_rec.statement_level then
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_first_reduction_amount',
                       value=> l_first_reduction_amount, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(fname=>'half_year',
                       element=>'l_second_half_cost_to_reduce',
                       value=> l_second_half_cost_to_reduce, p_log_level_rec => p_log_level_rec);
    end if;

    px_rule_in.reduction_amount
     := nvl(l_first_reduction_amount,0)
        + nvl(l_second_half_cost_to_reduce,0);

  end if; -- End FLAT method type

  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'half_year',
                         element=>'reduction_amount',
                         value=> px_rule_in.reduction_amount, p_log_level_rec => p_log_level_rec);
  end if;

exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when others then
  fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
  raise;
end HALF_YEAR;

--------------------------------------------------------------------------------
-- Procedure BEGINNING_PERIOD:
-- This procedure is the additional functionality for depreciable basis rule
-- 'Beginning Period'.
--------------------------------------------------------------------------------

PROCEDURE BEGINNING_PERIOD (
                           px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct,
                           px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is

  cursor GET_DEPRN_EXP is
    select nvl(sum(decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount)),0) beginning_period_expense
    from   fa_adjustments adj
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    adj.period_counter_created = px_rule_in.period_counter
    and    adj.source_type_code ='DEPRECIATION'
    and    adj.adjustment_type ='EXPENSE';

  cursor GET_DEPRN_EXP_M is
    select nvl(sum(decode(adj.debit_credit_flag,
                           'DR',adj.adjustment_amount,
                           'CR',-adj.adjustment_amount)),0) beginning_period_expense
    from   fa_mc_adjustments adj
    where  adj.asset_id = px_rule_in.asset_id
    and    adj.book_type_code = px_rule_in.book_type_code
    and    adj.period_counter_created = px_rule_in.period_counter
    and    adj.source_type_code ='DEPRECIATION'
    and    adj.adjustment_type ='EXPENSE'
    and    adj.set_of_books_id = px_rule_in.set_of_books_id ;


   -- create new cursor which look for retirement catchup.
   -- dr retirement expense with positive amount if cost is positive
   -- dr retirement expense with negative amount if cost is negative

  l_current_period_expense      NUMBER :=0; -- Depreciation Expense at this period
  l_eop_reserve                 NUMBER :=0;  -- End of prior period reserve
  l_exclude_salvage_value_flag  VARCHAR2(3); --Exclude salvage value flag
  l_retirement_reserve          NUMBER :=0;  -- Retirement Reserve new line added

  l_calling_fn                  VARCHAR2(50) := 'fa_calc_deprn_basis2_pkg.beginning_period';

  calc_basis_err                exception;

begin

  -------------------------------------------------------
  -- This rule is FLAT method type only
  -------------------------------------------------------
  if (px_rule_in.method_type in ('FLAT', 'FORMULA')) then

    ---------------------------------------------
    -- All Event types:
    -- Get Depreciation Expenses at this period
    -- and calculate Prior Period Reserve
    ---------------------------------------------

    if (px_rule_in.method_type = 'FLAT') then
       if px_rule_in.mrc_sob_type_code <>'R' then
         open GET_DEPRN_EXP;
         fetch GET_DEPRN_EXP into l_current_period_expense;
         close GET_DEPRN_EXP;
       else  -- MRC
         open GET_DEPRN_EXP_M;
         fetch GET_DEPRN_EXP_M into l_current_period_expense;
         close GET_DEPRN_EXP_M;
       end if;

       l_eop_reserve := nvl(px_rule_in.current_total_rsv,0)
                         - nvl(px_rule_in.adj_reserve,0)
                              - nvl(l_current_period_expense,0);
    elsif (px_rule_in.method_type = 'FORMULA') then

        l_eop_reserve := nvl(px_rule_in.current_total_rsv,0) -
                         nvl(px_rule_in.adj_reserve,0);
    end if;

    ----------------------------------------------------------------
    -- Event Type: INITIAL_ADDITION
    ----------------------------------------------------------------
    if (px_rule_in.event_type in ('ADDITION', 'INITIAL_ADDITION')) THEN

      if not fa_cache_pkg.fazcdp
               (x_book_type_code  => px_rule_in.book_type_code,
                x_period_counter  => px_rule_in.period_counter,
                x_effective_date  => null, p_log_level_rec => p_log_level_rec) then
         raise calc_basis_err;
      end if;

      --
      -- Bug4115689:  Added check against reserve and set adj_cost
      -- to rec cost ONLY if this addition is with reserve
      --
      if (px_rule_in.transaction_date_entered <
          fa_cache_pkg.fazcdp_record.calendar_period_open_date) and
         ((nvl(px_rule_in.adj_reserve, 0) <> 0) or
          (nvl(px_rule_in.current_rsv, 0) <> 0))   then

         if px_rule_in.calc_basis='COST' then

            px_rule_out.new_adjusted_cost :=
               nvl(px_rule_in.recoverable_cost,0);

         elsif px_rule_in.calc_basis = 'NBV' then
            px_rule_out.new_adjusted_cost :=
               nvl(px_rule_in.recoverable_cost,0) - nvl(l_eop_reserve,0);

         else -- unexpected calc_basis
            raise calc_basis_err;
         end if; -- End calc_basis

      else
         px_rule_out.new_adjusted_cost := 0;
         px_rule_in.eop_salvage_value := 0;

         if p_log_level_rec.statement_level then
            fa_debug_pkg.add(fname=>'beginning_period',
                             element=>'updated eop_salvage_value',
                             value=> px_rule_in.eop_salvage_value, p_log_level_rec => p_log_level_rec);
         end if;
      end if;

    end if; -- End of ADDITION / INITIAL ADDITION



    ------------------------------------------------
    -- Event types: AMORT_ADJ, AMORT_ADJ2, AMORT_ADJ3
    ------------------------------------------------

    if px_rule_in.event_type in ('AMORT_ADJ','AMORT_ADJ2', 'AMORT_ADJ3')
    then
      if px_rule_in.calc_basis='COST' then

        px_rule_out.new_adjusted_cost :=
           nvl(px_rule_in.eop_recoverable_cost,0);

      elsif px_rule_in.calc_basis = 'NBV' then
        px_rule_out.new_adjusted_cost :=
          nvl(px_rule_in.eop_recoverable_cost,0) - nvl(l_eop_reserve,0);

      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- End Event type: AMORT_ADJ, AMORT_ADJ2 , 'AMORT_ADJ3'

    -------------------------------
    -- Event type: EXPENSED_ADJ
    -------------------------------

    if px_rule_in.event_type='EXPENSED_ADJ' then

      if px_rule_in.calc_basis='COST' then

        px_rule_out.new_adjusted_cost :=
                      nvl(px_rule_in.recoverable_cost,0);

      elsif px_rule_in.calc_basis = 'NBV' then
         px_rule_out.new_adjusted_cost :=
          (nvl(px_rule_in.eop_recoverable_cost,0)
- nvl(px_rule_in.hyp_total_rsv,0));

        -- core development removed these lines
        --   +(nvl(px_rule_in.recoverable_cost,0)
        --        - nvl(px_rule_in.hyp_total_rsv,0)))/2;

      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- End event type: EXPENSED_ADJ

    ----------------------------
    -- Event type: RETIREMENT
    ----------------------------
if px_rule_in.event_type='RETIREMENT' then

      -- Retirement with Recognized Gain and Loss Immediately When Retired
      if px_rule_in.recognize_gain_loss<>'NO' then
        if px_rule_in.cost = 0 then
          l_retirement_reserve := 0;
        else
          l_retirement_reserve
            := - nvl(px_rule_in.adjustment_amount,0)
               / px_rule_in.cost
               * nvl(px_rule_in.current_total_rsv,0);
        end if;

      else -- Do Not Recogized Gain and loss
          l_retirement_reserve
            := - nvl(px_rule_in.adjustment_amount,0)
               + nvl(px_rule_in.nbv_retired,0);
--               + nvl(px_rule_in.proceeds_of_sale,0)
--               - nvl(px_rule_in.cost_of_removal,0);

      end if; -- End recognize_gain_loss

      if px_rule_in.calc_basis='COST' then

          px_rule_out.new_adjusted_cost :=
                     nvl(px_rule_in.eop_recoverable_cost,0);

      elsif px_rule_in.calc_basis = 'NBV' then
          px_rule_out.new_adjusted_cost :=
              nvl(px_rule_in.eop_recoverable_cost,0) - nvl(l_eop_reserve,0);

      else -- unexpected calc_basis
        raise calc_basis_err;
      end if; -- End calc_basis

    end if; -- Event type: Retirement

--end new version

    ------------------------------------------------------------
    -- Event Type: AFTER_DEPRN (After Depreciation)
    ------------------------------------------------------------
    if (px_rule_in.event_type ='AFTER_DEPRN') THEN
      if px_rule_in.calc_basis='COST' then

        px_rule_out.new_adjusted_cost :=
         nvl(px_rule_in.recoverable_cost,0);

        px_rule_in.use_old_adj_cost_flag :='N';
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- All Event types except of 'AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ',:
    -- Check exclude salvage value flag.
    -- And if exclude salvage value flag is Yes,
    -- reduce salvage value from new adjusted cost
    ---------------------------------------------------------------------------
    if fa_cache_pkg.fazccmt(px_rule_in.method_code,
                            px_rule_in.life_in_months, p_log_level_rec => p_log_level_rec) then

      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'beginning_period',
                         element=>'fazccmt',
                         value=> 'Called', p_log_level_rec => p_log_level_rec);
      end if;

      l_exclude_salvage_value_flag := fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag;

    end if;


    if px_rule_in.event_type
           not in ('AFTER_DEPRN','AFTER_DEPRN2','UNPLANNED_ADJ')
       and Upper(l_exclude_salvage_value_flag) like 'Y%'
       and px_rule_in.calc_basis= 'NBV'
    then

      px_rule_out.new_adjusted_cost :=
        px_rule_out.new_adjusted_cost
-nvl(px_rule_in.salvage_value,0);

-- Period Average code used the following:
--             - nvl(px_rule_in.eop_salvage_value,0))/2;

    end if;

  end if; -- Flat or formula method type

  if p_log_level_rec.statement_level then
        fa_debug_pkg.add(fname=>'beginning_period',
                         element=>'new_adjusted_cost',
                         value=> px_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
  end if;


exception
when calc_basis_err then
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

when others then
  fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
end BEGINNING_PERIOD;  --BEGINNING_PERIOD;

end FA_CALC_DEPRN_BASIS2_PKG;

/
