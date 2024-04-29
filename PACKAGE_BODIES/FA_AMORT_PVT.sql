--------------------------------------------------------
--  DDL for Package Body FA_AMORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_AMORT_PVT" as
/* $Header: FAVAMRTB.pls 120.204.12010000.36 2010/04/13 09:56:23 dvjoshi ship $ */


/* Global temporary variables */
g_temp_date1                   date;
g_temp_date2                   date;
g_temp_integer                 BINARY_INTEGER;
g_temp_number                  number;
g_temp_char30                    varchar2(30);

g_release                  number  := fa_cache_pkg.fazarel_release; -- Bug#8605817

/* Global constant variables */

G_ASSET_TYPE_GROUP             varchar2(5) := 'GROUP';
G_TRX_TYPE_TFR_OUT             varchar2(30) := 'TRANSFER OUT';
G_TRX_TYPE_TFR_IN              varchar2(30) := 'TRANSFER IN';
G_TRX_TYPE_TFR                 varchar2(30) := 'TRANSFER';
G_TRX_TYPE_TFR_VOID            varchar2(30) := 'TRANSFER IN/VOID';
G_TRX_TYPE_REI                 varchar2(30) := 'REINSTATEMENT';
G_TRX_TYPE_FUL_RET             varchar2(30) := 'FULL RETIREMENT';
G_TRX_TYPE_PAR_RET             varchar2(30) := 'PARTIAL RETIREMENT';
G_TRX_TYPE_GRP_CHG             varchar2(30) := 'GROUP CHANGE';
G_TRX_TYPE_REC                 varchar2(30) := 'RECLASS';
G_TRX_TYPE_UNIT_ADJ            varchar2(30) := 'UNIT ADJUSTMENT';
G_TRX_TYPE_REV                 varchar2(30) := 'REVALUATION';
G_TRX_TYPE_TAX                 varchar2(30) := 'TAX';
G_TRX_TYPE_ADD_VOID            varchar2(30) := 'ADDITION/VOID'; -- Bug#5074327
G_TRX_TYPE_CIP_ADJ             varchar2(30) := 'CIP ADJUSTMENT'; -- Bug#5191200
G_TRX_TYPE_ADD                 varchar2(30) := 'ADDITION';
G_TRX_TYPE_ADJ                 varchar2(30) := 'ADJUSTMENT';
G_TRX_TYPE_CIP_ADD_VOID        varchar2(30) := 'CIP ADDITION/VOID'; -- Bug:6019450
G_TRX_TYPE_CIP_ADD             varchar2(30) := 'CIP ADDITION'; -- Bug:6798953

/* Global temporary variables for member asset */
g_mem_deprn_reserve            NUMBER;
g_mem_eofy_reserve             NUMBER;
g_mem_ytd_deprn                NUMBER;
g_mem_bonus_ytd_deprn          NUMBER;
g_mem_bonus_deprn_reserve      NUMBER;
g_mem_ytd_impairment           NUMBER;
g_mem_impairment_reserve       NUMBER;
g_mem_asset_id                 NUMBER;

--Bug 5149789
FUNCTION check_member_existence (
                 p_asset_hdr_rec       IN            FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;

--Bug4938977: Adding a private function.
FUNCTION check_dpis_change (
              p_book_type_code                     VARCHAR2,
              p_transaction_header_id              NUMBER,
              p_group_asset_id                     NUMBER,
              x_asset_fin_rec           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
              x_period_counter_out      OUT NOCOPY NUMBER,
              p_mrc_sob_type_code                  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;

PROCEDURE printBooksSummary(p_asset_id  number,
                            p_book_type_code varchar2,
                            p_period_counter number default 0, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

   CURSOR c_get_books_summary IS
      select period_counter
           , cost
--           , salvage_value
           , member_salvage_value
           , allowed_deprn_limit_amount
           , adjusted_rate
           , rate_adjustment_factor
           , deprn_adjustment_amount
           , deprn_amount
           , ytd_deprn
           , reserve_adjustment_amount
           , deprn_reserve
      from   fa_books_summary
      where  asset_id = p_asset_id
      and    book_type_code = p_book_type_code
      and    period_counter >= nvl(p_period_counter, 1);

BEGIN

--tk_util.debug('period#:      cost:      sal:      art:       raf:      eaj:      exp:       ytd:    rsvadj:       rsv');
/*
for r_bs in c_get_books_summary loop
--tk_util.debug(rpad(to_char(r_bs.period_counter), 7, ' ')||':'||
              lpad(to_char(r_bs.cost), 10, ' ')||':'||
              lpad(to_char(r_bs.member_salvage_value), 9, ' ')||':'||
              lpad(nvl(to_char(r_bs.allowed_deprn_limit_amount), 'null'), 9, ' ')||':'||
              lpad(to_char(r_bs.adjusted_rate), 9, ' ')||':'||
              lpad(substrb(to_char(r_bs.rate_adjustment_factor), 1, 10), 10, ' ')||':'||
              lpad(to_char(r_bs.deprn_adjustment_amount), 9, ' ')||':'||
              lpad(to_char(r_bs.deprn_amount), 9, ' ')||':'||
              lpad(to_char(r_bs.ytd_deprn), 10, ' ')||':'||
              lpad(to_char(r_bs.reserve_adjustment_amount), 10, ' ')||':'||
              lpad(to_char(r_bs.deprn_reserve), 10, ' ')
             );
end loop;
*/
null;
END printBooksSummary;

--+==============================================================================
-- Function: GetPeriodInfo
--
--   This function return period information.
--   The function should be called when period information is not available in
--   fa_deprn_periods, for all other cases, should call fazcdp to obtain period
--   information.
--+==============================================================================
FUNCTION GetPeriodInfo(
     p_jdate                     NUMBER,
     p_book_type_code            VARCHAR2,
     p_mrc_sob_type_code         VARCHAR2,
     p_set_of_books_id           NUMBER,
     x_period_rec     OUT NOCOPY FA_API_TYPES.period_rec_type
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

  l_calling_fn  VARCHAR2(50) := 'FA_AMORT_PVT.GetPeriodInfo';
  get_err    EXCEPTION;

  CURSOR c_get_deprn_period_info IS
    select period_counter
         , period_name
         , period_open_date
         , period_close_date
         , calendar_period_open_date
         , calendar_period_close_date
         , fiscal_year
         , period_num
    from   fa_deprn_periods
    where  book_type_code = p_book_type_code
    and    to_date (to_char (p_jdate), 'J') between calendar_period_open_date
                                                and calendar_period_close_date;

  CURSOR c_get_mc_deprn_period_info IS
    select period_counter
         , period_name
         , period_open_date
         , period_close_date
         , calendar_period_open_date
         , calendar_period_close_date
         , fiscal_year
         , period_num
    from   fa_mc_deprn_periods
    where  set_of_books_id = p_set_of_books_id
    and    book_type_code = p_book_type_code
    and    to_date (to_char (p_jdate), 'J') between calendar_period_open_date
                                                and calendar_period_close_date;

  CURSOR c_get_period_info IS
    select start_date
         , end_date
    from   fa_calendar_periods
    where  calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
    and    to_date (to_char (p_jdate), 'J') between start_date
                                                and end_date;

BEGIN
  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'Begin', p_jdate, p_log_level_rec => p_log_level_rec);
  end if;

  if p_mrc_sob_type_code = 'R' then
     OPEN c_get_mc_deprn_period_info;
     FETCH c_get_mc_deprn_period_info INTO x_period_rec.period_counter
                                      , x_period_rec.period_name
                                      , x_period_rec.period_open_date
                                      , x_period_rec.period_close_date
                                      , x_period_rec.calendar_period_open_date
                                      , x_period_rec.calendar_period_close_date
                                      , x_period_rec.fiscal_year
                                      , x_period_rec.period_num;

     if (c_get_mc_deprn_period_info%NOTFOUND) then

        if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
           raise get_err;
        end if;

        if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.deprn_calendar,
                                   fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                   p_jdate,
                                   x_period_rec.period_num,
                                   x_period_rec.fiscal_year,
                                   g_temp_number, p_log_level_rec => p_log_level_rec) then
           raise get_err;
        end if;

        x_period_rec.period_counter := x_period_rec.fiscal_year *
                            fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR +
                            x_period_rec.period_num;

        OPEN c_get_period_info;
        FETCH c_get_period_info INTO x_period_rec.calendar_period_open_date,
                                     x_period_rec.calendar_period_close_date;
        CLOSE c_get_period_info;

     end if;

     CLOSE c_get_mc_deprn_period_info;

  else -- Primary book

     OPEN c_get_deprn_period_info;
     FETCH c_get_deprn_period_info INTO x_period_rec.period_counter
                                      , x_period_rec.period_name
                                      , x_period_rec.period_open_date
                                      , x_period_rec.period_close_date
                                      , x_period_rec.calendar_period_open_date
                                      , x_period_rec.calendar_period_close_date
                                      , x_period_rec.fiscal_year
                                      , x_period_rec.period_num;

     if (c_get_deprn_period_info%NOTFOUND) then

        if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
           raise get_err;
        end if;

        if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.deprn_calendar,
                                   fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                   p_jdate,
                                   x_period_rec.period_num,
                                   x_period_rec.fiscal_year,
                                   g_temp_number, p_log_level_rec => p_log_level_rec) then
           raise get_err;
        end if;

        x_period_rec.period_counter := x_period_rec.fiscal_year *
                            fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR +
                            x_period_rec.period_num;

        OPEN c_get_period_info;
        FETCH c_get_period_info INTO x_period_rec.calendar_period_open_date,
                                     x_period_rec.calendar_period_close_date;
        CLOSE c_get_period_info;

     end if;

     CLOSE c_get_deprn_period_info;

  end if;

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'End', x_period_rec.period_counter||':'||
                                           x_period_rec.fiscal_year||':'||
                                           x_period_rec.period_num||':'||
                                           to_char(x_period_rec.calendar_period_open_date, 'DD-MON-YYYY')||':'||
                                           to_char(x_period_rec.calendar_period_close_date, 'DD-MON-YYYY'));
  end if;

  return TRUE;

EXCEPTION
   WHEN get_err THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'get_err', p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   WHEN others THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END GetPeriodInfo;


--+==============================================================================
-- Function catchupBooksSummary
--
--  This function will create missing records from period where last record
--  exists up to current period.
--+==============================================================================
FUNCTION catchupBooksSummary (
    p_trans_rec              FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type,
    p_period_rec             FA_API_TYPES.period_rec_type,
    p_asset_fin_rec_new      FA_API_TYPES.asset_fin_rec_type,
    p_depreciate_flag_change BOOLEAN,
    p_disabled_flag_change   BOOLEAN,
    p_mrc_sob_type_code      VARCHAR2,
    p_calling_fn             VARCHAR
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn      VARCHAR2(50) := 'FA_AMORT_PVT.catchupBooksSummary';

   CURSOR c_get_mc_last_period_counter IS
     select bs.period_counter
          , bs.calendar_period_close_date
          , bs.fiscal_year
          , bs.period_num
     from   fa_mc_books_summary bs
     where  bs.asset_id = p_asset_hdr_rec.asset_id
     and    bs.book_type_code = p_asset_hdr_rec.book_type_code
     and    bs.set_of_books_id = p_asset_hdr_rec.set_of_books_id
     order by period_counter desc;

   CURSOR c_get_last_period_counter IS
     select bs.period_counter
          , bs.calendar_period_close_date
          , bs.fiscal_year
          , bs.period_num
     from   fa_books_summary bs
     where  bs.asset_id = p_asset_hdr_rec.asset_id
     and    bs.book_type_code = p_asset_hdr_rec.book_type_code
     order by period_counter desc;

   --
   -- Get all possible period information that the group asset needs
   --
   CURSOR c_get_period_rec (c_start_date  date) IS
     select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM period_counter
          , cp.start_date calendar_period_open_date
          , cp.end_date calendar_period_close_date
          , cp.period_num period_num
          , fy.fiscal_year fiscal_year
          , 'N'
     from   fa_book_controls bc
          , fa_fiscal_year fy
          , fa_calendar_types ct
          , fa_calendar_periods cp
     where  bc.book_type_code = p_asset_hdr_rec.book_type_code
     and    bc.deprn_calendar = ct.calendar_type
     and    bc.fiscal_year_name = fy.fiscal_year_name
     and    ct.fiscal_year_name = bc.fiscal_year_name
     and    ct.calendar_type = cp.calendar_type
     and    cp.start_date between fy.start_date and fy.end_date
     and    bc.last_period_counter + 1 >= fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
     and    cp.end_date >= c_start_date
     order by period_counter;

   tbs_period_counter              tab_num15_type;
   tbs_calendar_period_open_date   tab_date_type;
   tbs_calendar_period_close_date  tab_date_type;
   tbs_period_num                  tab_num15_type;
   tbs_fiscal_year                 tab_num15_type;
   tbs_reset_adjusted_cost_flag    tab_char1_type;

   tbs_adjusted_cost               tab_num_type;
   tbs_eofy_adj_cost               tab_num_type;
   tbs_eofy_formula_factor         tab_num_type;
   tbs_eofy_reserve                tab_num_type;
   tbs_eop_adj_cost                tab_num_type;
   tbs_eop_formula_factor          tab_num_type;
   tbs_depreciate_flag             tab_char1_type;
   tbs_disabled_flag               tab_char1_type;
   tbs_formula_factor              tab_num_type;

   tbs_ytd_deprn                   tab_num_type;
   tbs_bonus_ytd_deprn             tab_num_type;
   tbs_ytd_impairment              tab_num_type;
   tbs_ytd_production              tab_num_type;
   tbs_ytd_reval_deprn_expense     tab_num_type;
   tbs_ytd_proceeds_of_sale        tab_num_type;
   tbs_ytd_cost_of_removal         tab_num_type;

   l_last_period_counter           NUMBER(15);
   l_last_period_close_date        DATE;
   l_last_fiscal_year              NUMBER(15);
   l_last_period_num               NUMBER(15);

   l_ind                           BINARY_INTEGER;

--
-- Think about unplan, reserve tr, and ret adj against asset not depreciating
--

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()+', 'asset_id', p_asset_hdr_rec.asset_id);
   end if;

   if p_mrc_sob_type_code = 'R' then

      OPEN c_get_mc_last_period_counter;
      FETCH c_get_mc_last_period_counter INTO l_last_period_counter
                                         , l_last_period_close_date
                                         , l_last_fiscal_year
                                         , l_last_period_num;
      CLOSE c_get_mc_last_period_counter;
   else
      OPEN c_get_last_period_counter;
      FETCH c_get_last_period_counter INTO l_last_period_counter
                                         , l_last_period_close_date
                                         , l_last_fiscal_year
                                         , l_last_period_num;
      CLOSE c_get_last_period_counter;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'l_last_period_counter', l_last_period_counter, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_last_period_close_date', l_last_period_close_date, p_log_level_rec => p_log_level_rec);
   end if;

   if (p_period_rec.period_counter = l_last_period_counter) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'This asset has record up to current period',l_last_period_counter, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn||'()-', 'asset_id', p_asset_hdr_rec.asset_id);
      end if;

      return TRUE;

   end if;

   --
   -- This asset needs records up to current period
   --
   OPEN c_get_period_rec ((l_last_period_close_date + 1));
   FETCH c_get_period_rec BULK COLLECT INTO tbs_period_counter
                                          , tbs_calendar_period_open_date
                                          , tbs_calendar_period_close_date
                                          , tbs_period_num
                                          , tbs_fiscal_year
                                          , tbs_reset_adjusted_cost_flag
                                          ;
   CLOSE c_get_period_rec;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '# of record creating', tbs_period_counter.COUNT, p_log_level_rec => p_log_level_rec);
   end if;

   l_ind := p_period_rec.period_counter - l_last_period_counter;
   FOR i in 1..l_ind LOOP
      --
      -- If anything requires table value manipulation for each period
      -- this is the place. So far, it's been absorved in insert statement.
      null;

   END LOOP; -- i in 1..(p_period_rec.period_counter - l_last_period_counter)


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Insert into', 'FA_BOOKS_SUMMARY', p_log_level_rec => p_log_level_rec);
   end if;
   --
   -- Insert all necessary records from period where DPIS falls into
   --
   if p_mrc_sob_type_code = 'R' then
      FORALL i in tbs_period_counter.FIRST..tbs_period_counter.LAST
         INSERT INTO FA_MC_BOOKS_SUMMARY(
                    SET_OF_BOOKS_ID
                  , ASSET_ID
                  , BOOK_TYPE_CODE
                  , PERIOD_COUNTER
                  , FISCAL_YEAR
                  , PERIOD_NUM
                  , CALENDAR_PERIOD_OPEN_DATE
                  , CALENDAR_PERIOD_CLOSE_DATE
                  , RESET_ADJUSTED_COST_FLAG
                  , CHANGE_IN_COST
                  , CHANGE_IN_ADDITIONS_COST
                  , CHANGE_IN_ADJUSTMENTS_COST
                  , CHANGE_IN_RETIREMENTS_COST
                  , CHANGE_IN_CIP_COST
                  , COST
                  , CIP_COST
                  , SALVAGE_TYPE
                  , PERCENT_SALVAGE_VALUE
                  , SALVAGE_VALUE
                  , MEMBER_SALVAGE_VALUE
                  , RECOVERABLE_COST
                  , DEPRN_LIMIT_TYPE
                  , ALLOWED_DEPRN_LIMIT
                  , ALLOWED_DEPRN_LIMIT_AMOUNT
                  , MEMBER_DEPRN_LIMIT_AMOUNT
                  , ADJUSTED_RECOVERABLE_COST
                  , ADJUSTED_COST
                  , DEPRECIATE_FLAG
                  , DISABLED_FLAG
                  , DATE_PLACED_IN_SERVICE
                  , DEPRN_METHOD_CODE
                  , LIFE_IN_MONTHS
                  , RATE_ADJUSTMENT_FACTOR
                  , ADJUSTED_RATE
                  , FORMULA_FACTOR
                  , BONUS_RULE
                  , ADJUSTED_CAPACITY
                  , PRODUCTION_CAPACITY
                  , UNIT_OF_MEASURE
                  , REMAINING_LIFE1
                  , REMAINING_LIFE2
                  , UNREVALUED_COST
                  , REVAL_CEILING
                  , CEILING_NAME
                  , REVAL_AMORTIZATION_BASIS
                  , EOFY_ADJ_COST
                  , EOFY_FORMULA_FACTOR
                  , EOFY_RESERVE
                  , EOP_ADJ_COST
                  , EOP_FORMULA_FACTOR
                  , SHORT_FISCAL_YEAR_FLAG
                  , GROUP_ASSET_ID
                  , SUPER_GROUP_ID
                  , OVER_DEPRECIATE_OPTION
                  , TERMINAL_GAIN_LOSS_AMOUNT
                  , TERMINAL_GAIN_LOSS_FLAG
                  , DEPRN_AMOUNT
                  , YTD_DEPRN
                  , DEPRN_RESERVE
                  , BONUS_DEPRN_AMOUNT
                  , BONUS_YTD_DEPRN
                  , BONUS_DEPRN_RESERVE
                  , IMPAIRMENT_AMOUNT
                  , impairment_reserve
                  , YTD_IMPAIRMENT
                  , LTD_PRODUCTION
                  , YTD_PRODUCTION
                  , PRODUCTION
                  , REVAL_AMORTIZATION
                  , REVAL_DEPRN_EXPENSE
                  , REVAL_RESERVE
                  , YTD_REVAL_DEPRN_EXPENSE
                  , DEPRN_OVERRIDE_FLAG
                  , SYSTEM_DEPRN_AMOUNT
                  , YTD_PROCEEDS_OF_SALE
                  , LTD_PROCEEDS_OF_SALE
                  , YTD_COST_OF_REMOVAL
                  , LTD_COST_OF_REMOVAL
                  , DEPRN_ADJUSTMENT_AMOUNT
                  , EXPENSE_ADJUSTMENT_AMOUNT
                  , UNPLANNED_AMOUNT
                  , RESERVE_ADJUSTMENT_AMOUNT
                  , CREATION_DATE
                  , CREATED_BY
                  , LAST_UPDATE_DATE
                  , LAST_UPDATED_BY
                  )
         SELECT     p_asset_hdr_rec.set_of_books_id
                  , p_asset_hdr_rec.asset_id
                  , p_asset_hdr_rec.book_type_code
                  , tbs_period_counter(i)
                  , tbs_fiscal_year(i)
                  , tbs_period_num(i)
                  , tbs_calendar_period_open_date(i)
                  , tbs_calendar_period_close_date(i)
                  , tbs_reset_adjusted_cost_flag(i)
                  , 0                 --CHANGE_IN_COST
                  , 0                 --CHANGE_IN_ADDITIONS_COST
                  , 0                 --CHANGE_IN_ADJUSTMENTS_COST
                  , 0                 --CHANGE_IN_RETIREMENTS_COST
                  , 0                 --CHANGE_IN_CIP_COST
                  , BS.COST
                  , BS.CIP_COST
                  , BS.SALVAGE_TYPE
                  , BS.PERCENT_SALVAGE_VALUE
                  , BS.SALVAGE_VALUE
                  , BS.MEMBER_SALVAGE_VALUE
                  , BS.RECOVERABLE_COST
                  , BS.DEPRN_LIMIT_TYPE
                  , BS.ALLOWED_DEPRN_LIMIT
                  , BS.ALLOWED_DEPRN_LIMIT_AMOUNT
                  , BS.MEMBER_DEPRN_LIMIT_AMOUNT
                  , BS.ADJUSTED_RECOVERABLE_COST
                  , BS.ADJUSTED_COST
                  , BS.DEPRECIATE_FLAG
                  , BS.DISABLED_FLAG
                  , BS.DATE_PLACED_IN_SERVICE
                  , BS.DEPRN_METHOD_CODE
                  , BS.LIFE_IN_MONTHS
                  , BS.RATE_ADJUSTMENT_FACTOR
                  , BS.ADJUSTED_RATE
                  , BS.FORMULA_FACTOR
                  , BS.BONUS_RULE
                  , BS.ADJUSTED_CAPACITY
                  , BS.PRODUCTION_CAPACITY
                  , BS.UNIT_OF_MEASURE
                  , BS.REMAINING_LIFE1
                  , BS.REMAINING_LIFE2
                  , BS.UNREVALUED_COST
                  , BS.REVAL_CEILING
                  , BS.CEILING_NAME
                  , BS.REVAL_AMORTIZATION_BASIS
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.EOFY_ADJ_COST, BS.ADJUSTED_COST) --EOFY_ADJ_COST
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.EOFY_FORMULA_FACTOR, BS.FORMULA_FACTOR) --EOFY_FORMULA_FACTOR
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.EOFY_RESERVE,
                                           tbs_fiscal_year(i) - 1, BS.DEPRN_RESERVE, 0) --EOFY_RESERVE
                  , BS.ADJUSTED_COST --EOP_ADJ_COST
                  , BS.FORMULA_FACTOR --EOP_FORMULA_FACTOR
                  , BS.SHORT_FISCAL_YEAR_FLAG
                  , BS.GROUP_ASSET_ID
                  , BS.SUPER_GROUP_ID
                  , BS.OVER_DEPRECIATE_OPTION
                  , 0                 --TERMINAL_GAIN_LOSS_AMOUNT
                  , 'N'               --TERMINAL_GAIN_LOSS_FLAG
                  , 0                 --DEPRN_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_DEPRN, 0) --YTD_DEPRN
                  , BS.DEPRN_RESERVE
                  , 0                 --BONUS_DEPRN_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.BONUS_YTD_DEPRN, 0) --BONUS_YTD_DEPRN
                  , BS.BONUS_DEPRN_RESERVE
                  , 0                 --IMPAIRMENT_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_IMPAIRMENT, 0) --YTD_IMPAIRMENT
                  , BS.impairment_reserve
                  , BS.LTD_PRODUCTION
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_PRODUCTION, 0) --YTD_PRODUCTION
                  , null              --PRODUCTION
                  , 0                 --REVAL_AMORTIZATION
                  , 0                 --REVAL_DEPRN_EXPENSE
                  , BS.REVAL_RESERVE
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_REVAL_DEPRN_EXPENSE, 0) --YTD_REVAL_DEPRN_EXPENSE
                  , 'N'                --DEPRN_OVERRIDE_FLAG
                  , 0                 --SYSTEM_DEPRN_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_PROCEEDS_OF_SALE, 0) --YTD_PROCEEDS_OF_SALE
                  , BS.LTD_PROCEEDS_OF_SALE
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_COST_OF_REMOVAL, 0) --YTD_COST_OF_REMOVAL
                  , BS.LTD_COST_OF_REMOVAL
                  , 0                 --DEPRN_ADJUSTMENT_AMOUNT
                  , 0                 --EXPENSE_ADJUSTMENT_AMOUNT
                  , 0                 --UNPLANNED_AMOUNT
                  , 0                 --RESERVE_ADJUSTMENT_AMOUNT
                  , p_trans_rec.who_info.creation_date
                  , p_trans_rec.who_info.created_by
                  , p_trans_rec.who_info.last_update_date
                  , p_trans_rec.who_info.last_updated_by
         FROM FA_MC_BOOKS_SUMMARY BS
         WHERE BS.ASSET_ID = p_asset_hdr_rec.asset_id
         AND   BS.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND   BS.period_counter = l_last_period_counter
         AND   BS.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   else
      FORALL i in tbs_period_counter.FIRST..tbs_period_counter.LAST
         INSERT INTO FA_BOOKS_SUMMARY(
                    ASSET_ID
                  , BOOK_TYPE_CODE
                  , PERIOD_COUNTER
                  , FISCAL_YEAR
                  , PERIOD_NUM
                  , CALENDAR_PERIOD_OPEN_DATE
                  , CALENDAR_PERIOD_CLOSE_DATE
                  , RESET_ADJUSTED_COST_FLAG
                  , CHANGE_IN_COST
                  , CHANGE_IN_ADDITIONS_COST
                  , CHANGE_IN_ADJUSTMENTS_COST
                  , CHANGE_IN_RETIREMENTS_COST
                  , CHANGE_IN_CIP_COST
                  , COST
                  , CIP_COST
                  , SALVAGE_TYPE
                  , PERCENT_SALVAGE_VALUE
                  , SALVAGE_VALUE
                  , MEMBER_SALVAGE_VALUE
                  , RECOVERABLE_COST
                  , DEPRN_LIMIT_TYPE
                  , ALLOWED_DEPRN_LIMIT
                  , ALLOWED_DEPRN_LIMIT_AMOUNT
                  , MEMBER_DEPRN_LIMIT_AMOUNT
                  , ADJUSTED_RECOVERABLE_COST
                  , ADJUSTED_COST
                  , DEPRECIATE_FLAG
                  , DISABLED_FLAG
                  , DATE_PLACED_IN_SERVICE
                  , DEPRN_METHOD_CODE
                  , LIFE_IN_MONTHS
                  , RATE_ADJUSTMENT_FACTOR
                  , ADJUSTED_RATE
                  , FORMULA_FACTOR
                  , BONUS_RULE
                  , ADJUSTED_CAPACITY
                  , PRODUCTION_CAPACITY
                  , UNIT_OF_MEASURE
                  , REMAINING_LIFE1
                  , REMAINING_LIFE2
                  , UNREVALUED_COST
                  , REVAL_CEILING
                  , CEILING_NAME
                  , REVAL_AMORTIZATION_BASIS
                  , EOFY_ADJ_COST
                  , EOFY_FORMULA_FACTOR
                  , EOFY_RESERVE
                  , EOP_ADJ_COST
                  , EOP_FORMULA_FACTOR
                  , SHORT_FISCAL_YEAR_FLAG
                  , GROUP_ASSET_ID
                  , SUPER_GROUP_ID
                  , OVER_DEPRECIATE_OPTION
                  , TERMINAL_GAIN_LOSS_AMOUNT
                  , TERMINAL_GAIN_LOSS_FLAG
                  , DEPRN_AMOUNT
                  , YTD_DEPRN
                  , DEPRN_RESERVE
                  , BONUS_DEPRN_AMOUNT
                  , BONUS_YTD_DEPRN
                  , BONUS_DEPRN_RESERVE
                  , IMPAIRMENT_AMOUNT
                  , impairment_reserve
                  , YTD_IMPAIRMENT
                  , LTD_PRODUCTION
                  , YTD_PRODUCTION
                  , PRODUCTION
                  , REVAL_AMORTIZATION
                  , REVAL_DEPRN_EXPENSE
                  , REVAL_RESERVE
                  , YTD_REVAL_DEPRN_EXPENSE
                  , DEPRN_OVERRIDE_FLAG
                  , SYSTEM_DEPRN_AMOUNT
                  , YTD_PROCEEDS_OF_SALE
                  , LTD_PROCEEDS_OF_SALE
                  , YTD_COST_OF_REMOVAL
                  , LTD_COST_OF_REMOVAL
                  , DEPRN_ADJUSTMENT_AMOUNT
                  , EXPENSE_ADJUSTMENT_AMOUNT
                  , UNPLANNED_AMOUNT
                  , RESERVE_ADJUSTMENT_AMOUNT
                  , CREATION_DATE
                  , CREATED_BY
                  , LAST_UPDATE_DATE
                  , LAST_UPDATED_BY
                  )
         SELECT     p_asset_hdr_rec.asset_id
                  , p_asset_hdr_rec.book_type_code
                  , tbs_period_counter(i)
                  , tbs_fiscal_year(i)
                  , tbs_period_num(i)
                  , tbs_calendar_period_open_date(i)
                  , tbs_calendar_period_close_date(i)
                  , tbs_reset_adjusted_cost_flag(i)
                  , 0                 --CHANGE_IN_COST
                  , 0                 --CHANGE_IN_ADDITIONS_COST
                  , 0                 --CHANGE_IN_ADJUSTMENTS_COST
                  , 0                 --CHANGE_IN_RETIREMENTS_COST
                  , 0                 --CHANGE_IN_CIP_COST
                  , BS.COST
                  , BS.CIP_COST
                  , BS.SALVAGE_TYPE
                  , BS.PERCENT_SALVAGE_VALUE
                  , BS.SALVAGE_VALUE
                  , BS.MEMBER_SALVAGE_VALUE
                  , BS.RECOVERABLE_COST
                  , BS.DEPRN_LIMIT_TYPE
                  , BS.ALLOWED_DEPRN_LIMIT
                  , BS.ALLOWED_DEPRN_LIMIT_AMOUNT
                  , BS.MEMBER_DEPRN_LIMIT_AMOUNT
                  , BS.ADJUSTED_RECOVERABLE_COST
                  , BS.ADJUSTED_COST
                  , BS.DEPRECIATE_FLAG
                  , BS.DISABLED_FLAG
                  , BS.DATE_PLACED_IN_SERVICE
                  , BS.DEPRN_METHOD_CODE
                  , BS.LIFE_IN_MONTHS
                  , BS.RATE_ADJUSTMENT_FACTOR
                  , BS.ADJUSTED_RATE
                  , BS.FORMULA_FACTOR
                  , BS.BONUS_RULE
                  , BS.ADJUSTED_CAPACITY
                  , BS.PRODUCTION_CAPACITY
                  , BS.UNIT_OF_MEASURE
                  , BS.REMAINING_LIFE1
                  , BS.REMAINING_LIFE2
                  , BS.UNREVALUED_COST
                  , BS.REVAL_CEILING
                  , BS.CEILING_NAME
                  , BS.REVAL_AMORTIZATION_BASIS
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.EOFY_ADJ_COST, BS.ADJUSTED_COST) --EOFY_ADJ_COST
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.EOFY_FORMULA_FACTOR, BS.FORMULA_FACTOR) --EOFY_FORMULA_FACTOR
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.EOFY_RESERVE,
                                           tbs_fiscal_year(i) - 1, BS.DEPRN_RESERVE, 0) --EOFY_RESERVE
                  , BS.ADJUSTED_COST --EOP_ADJ_COST
                  , BS.FORMULA_FACTOR --EOP_FORMULA_FACTOR
                  , BS.SHORT_FISCAL_YEAR_FLAG
                  , BS.GROUP_ASSET_ID
                  , BS.SUPER_GROUP_ID
                  , BS.OVER_DEPRECIATE_OPTION
                  , 0                 --TERMINAL_GAIN_LOSS_AMOUNT
                  , 'N'               --TERMINAL_GAIN_LOSS_FLAG
                  , 0                 --DEPRN_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_DEPRN, 0) --YTD_DEPRN
                  , BS.DEPRN_RESERVE
                  , 0                 --BONUS_DEPRN_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.BONUS_YTD_DEPRN, 0) --BONUS_YTD_DEPRN
                  , BS.BONUS_DEPRN_RESERVE
                  , 0                 --IMPAIRMENT_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_IMPAIRMENT, 0) --YTD_IMPAIRMENT
                  , BS.impairment_reserve
                  , BS.LTD_PRODUCTION
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_PRODUCTION, 0) --YTD_PRODUCTION
                  , null              --PRODUCTION
                  , 0                 --REVAL_AMORTIZATION
                  , 0                 --REVAL_DEPRN_EXPENSE
                  , BS.REVAL_RESERVE
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_REVAL_DEPRN_EXPENSE, 0) --YTD_REVAL_DEPRN_EXPENSE
                  , 'N'                --DEPRN_OVERRIDE_FLAG
                  , 0                 --SYSTEM_DEPRN_AMOUNT
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_PROCEEDS_OF_SALE, 0) --YTD_PROCEEDS_OF_SALE
                  , BS.LTD_PROCEEDS_OF_SALE
                  , DECODE(BS.FISCAL_YEAR, tbs_fiscal_year(i), BS.YTD_COST_OF_REMOVAL, 0) --YTD_COST_OF_REMOVAL
                  , BS.LTD_COST_OF_REMOVAL
                  , 0                 --DEPRN_ADJUSTMENT_AMOUNT
                  , 0                 --EXPENSE_ADJUSTMENT_AMOUNT
                  , 0                 --UNPLANNED_AMOUNT
                  , 0                 --RESERVE_ADJUSTMENT_AMOUNT
                  , p_trans_rec.who_info.creation_date
                  , p_trans_rec.who_info.created_by
                  , p_trans_rec.who_info.last_update_date
                  , p_trans_rec.who_info.last_updated_by
         FROM FA_BOOKS_SUMMARY BS
         WHERE BS.ASSET_ID = p_asset_hdr_rec.asset_id
         AND   BS.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND   BS.period_counter = l_last_period_counter;
   end if; --p_mrc_sob_type_code = 'R'

   if p_depreciate_flag_change then

      if p_mrc_sob_type_code = 'R' then
         UPDATE FA_MC_BOOKS_SUMMARY
         SET    DEPRECIATE_FLAG = p_asset_fin_rec_new.depreciate_flag
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
      else
         UPDATE FA_BOOKS_SUMMARY
         SET    DEPRECIATE_FLAG = p_asset_fin_rec_new.depreciate_flag
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code;
     end if;

   elsif p_disabled_flag_change then

      if p_mrc_sob_type_code = 'R' then
         UPDATE FA_MC_BOOKS_SUMMARY
         SET    DISABLED_FLAG = p_asset_fin_rec_new.depreciate_flag
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
      else
         UPDATE FA_BOOKS_SUMMARY
         SET    DISABLED_FLAG = p_asset_fin_rec_new.depreciate_flag
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code;
     end if;

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()-', '# of records inserted', tbs_period_counter.COUNT);
   end if;

   return true;

EXCEPTION
   WHEN OTHERS THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'(OTHERS)-', 'sqlcode', sqlcode);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

END catchupBooksSummary;



--+==============================================================================
-- Procedure initMemberTable
--
-- Initialize global variables defined in specification.
--+==============================================================================
PROCEDURE initMemberTable IS
BEGIN

   --
   -- Initialize global variables
   --
   fa_amort_pvt.tmd_period_counter.delete;
   fa_amort_pvt.tmd_cost.delete;
   fa_amort_pvt.tm_cost.delete;
   fa_amort_pvt.tmd_cip_cost.delete;
   fa_amort_pvt.tm_cip_cost.delete;
   fa_amort_pvt.tmd_salvage_value.delete;
   fa_amort_pvt.tm_salvage_value.delete;
   fa_amort_pvt.tmd_deprn_limit_amount.delete;
   fa_amort_pvt.tm_deprn_limit_amount.delete;

END initMemberTable;

--+==============================================================================
-- Procedure InitGlobeVariables
--
-- Initialize global variables defined in specification.
--+==============================================================================
PROCEDURE InitGlobeVariables IS
BEGIN

   --
   -- Initialize global variables
   --
   fa_amort_pvt.t_period_counter.delete;
   fa_amort_pvt.t_fiscal_year.delete;
   fa_amort_pvt.t_period_num.delete;
   fa_amort_pvt.t_calendar_period_open_date.delete;
   fa_amort_pvt.t_calendar_period_close_date.delete;
   fa_amort_pvt.t_reset_adjusted_cost_flag.delete;
   fa_amort_pvt.t_change_in_cost.delete;
   fa_amort_pvt.t_cost.delete;
   fa_amort_pvt.t_cip_cost.delete;
   fa_amort_pvt.t_salvage_type.delete;
   fa_amort_pvt.t_percent_salvage_value.delete;
   fa_amort_pvt.t_salvage_value.delete;
   fa_amort_pvt.t_member_salvage_value.delete;
   fa_amort_pvt.t_recoverable_cost.delete;
   fa_amort_pvt.t_deprn_limit_type.delete;
   fa_amort_pvt.t_allowed_deprn_limit.delete;
   fa_amort_pvt.t_allowed_deprn_limit_amount.delete;
   fa_amort_pvt.t_member_deprn_limit_amount.delete;
   fa_amort_pvt.t_adjusted_recoverable_cost.delete;
   fa_amort_pvt.t_adjusted_cost.delete;
   fa_amort_pvt.t_depreciate_flag.delete;
   fa_amort_pvt.t_date_placed_in_service.delete;
   fa_amort_pvt.t_deprn_method_code.delete;
   fa_amort_pvt.t_life_in_months.delete;
   fa_amort_pvt.t_rate_adjustment_factor.delete;
   fa_amort_pvt.t_adjusted_rate.delete;
   fa_amort_pvt.t_bonus_rule.delete;
   fa_amort_pvt.t_adjusted_capacity.delete;
   fa_amort_pvt.t_production_capacity.delete;
   fa_amort_pvt.t_unit_of_measure.delete;
   fa_amort_pvt.t_remaining_life1.delete;
   fa_amort_pvt.t_remaining_life2.delete;
   fa_amort_pvt.t_formula_factor.delete;
   fa_amort_pvt.t_unrevalued_cost.delete;
   fa_amort_pvt.t_reval_amortization_basis.delete;
   fa_amort_pvt.t_reval_ceiling.delete;
   fa_amort_pvt.t_ceiling_name.delete;
   fa_amort_pvt.t_eofy_adj_cost.delete;
   fa_amort_pvt.t_eofy_formula_factor.delete;
   fa_amort_pvt.t_eofy_reserve.delete;
   fa_amort_pvt.t_eop_adj_cost.delete;
   fa_amort_pvt.t_eop_formula_factor.delete;
   fa_amort_pvt.t_short_fiscal_year_flag.delete;
   fa_amort_pvt.t_group_asset_id.delete;
   fa_amort_pvt.t_super_group_id.delete;
   fa_amort_pvt.t_over_depreciate_option.delete;
   fa_amort_pvt.t_deprn_amount.delete;
   fa_amort_pvt.t_ytd_deprn.delete;
   fa_amort_pvt.t_deprn_reserve.delete;
   fa_amort_pvt.t_bonus_deprn_amount.delete;
   fa_amort_pvt.t_bonus_ytd_deprn.delete;
   fa_amort_pvt.t_bonus_deprn_reserve.delete;
   fa_amort_pvt.t_bonus_rate.delete;
   fa_amort_pvt.t_impairment_amount.delete;
   fa_amort_pvt.t_ytd_impairment.delete;
   fa_amort_pvt.t_impairment_reserve.delete;
   fa_amort_pvt.t_ltd_production.delete;
   fa_amort_pvt.t_ytd_production.delete;
   fa_amort_pvt.t_production.delete;
   fa_amort_pvt.t_reval_amortization.delete;
   fa_amort_pvt.t_reval_deprn_expense.delete;
   fa_amort_pvt.t_reval_reserve.delete;
   fa_amort_pvt.t_ytd_reval_deprn_expense.delete;
   fa_amort_pvt.t_deprn_override_flag.delete;
   fa_amort_pvt.t_system_deprn_amount.delete;
   fa_amort_pvt.t_system_bonus_deprn_amount.delete;
   fa_amort_pvt.t_ytd_proceeds_of_sale.delete;
   fa_amort_pvt.t_ltd_proceeds_of_sale.delete;
   fa_amort_pvt.t_ytd_cost_of_removal.delete;
   fa_amort_pvt.t_ltd_cost_of_removal.delete;
   fa_amort_pvt.t_deprn_adjustment_amount.delete;
   fa_amort_pvt.t_expense_adjustment_amount.delete;
   fa_amort_pvt.t_reserve_adjustment_amount.delete;

END InitGlobeVariables;

--+==============================================================================
-- Function: createGroup
--
-- Description:
--     This function should be called to maintain group asset that has not
--     depreciated or a member asset has not assigned.
--     What this function does is to recreate records in FA_BOOKS_SUMAMRY by
--     deleting all of them and reinsert all of them.
--
--+==============================================================================
FUNCTION createGroup(
    p_trans_rec            FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec        FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec       FA_API_TYPES.asset_type_rec_type,
    p_period_rec           FA_API_TYPES.period_rec_type,
    p_asset_fin_rec        FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec      FA_API_TYPES.asset_deprn_rec_type,
    p_mrc_sob_type_code    VARCHAR2,
    p_calling_fn           VARCHAR
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

   l_calling_fn  VARCHAR2(50) := 'FA_AMORT_PVT.createGroup';

   --
   -- Get all possible period information that the group asset needs
   --
   CURSOR c_get_period_rec IS
     select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM period_counter
          , cp.start_date calendar_period_open_date
          , cp.end_date calendar_period_close_date
          , cp.period_num period_num
          , fy.fiscal_year fiscal_year
          , 'N'
     from   fa_fiscal_year fy
          , fa_calendar_types ct
          , fa_calendar_periods cp
     where  ct.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
     and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
     and    ct.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
     and    ct.calendar_type = cp.calendar_type
     and    cp.start_date between fy.start_date and fy.end_date
     and    fa_cache_pkg.fazcbc_record.last_period_counter + 1 >=
                 fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
     and    cp.end_date >= p_asset_fin_rec.date_placed_in_service
     order by period_counter;

   tbs_period_counter              tab_num15_type;
   tbs_calendar_period_open_date   tab_date_type;
   tbs_calendar_period_close_date  tab_date_type;
   tbs_period_num                  tab_num15_type;
   tbs_fiscal_year                 tab_num15_type;
   tbs_reset_adjusted_cost_flag    tab_char1_type;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()+', 'asset_id', p_asset_hdr_rec.asset_id);
   end if;

   --
   -- Delete all records for this group asset to recreate them
   --
   if p_mrc_sob_type_code = 'R' then
      DELETE FROM FA_MC_BOOKS_SUMMARY
      WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
   else
      DELETE FROM FA_BOOKS_SUMMARY
      WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Construct Period information', '.', p_log_level_rec => p_log_level_rec);
   end if;

   --
   -- Construct period information part for FA_BOOKS_SUMAMRY
   --
   OPEN c_get_period_rec;
   FETCH c_get_period_rec BULK COLLECT INTO tbs_period_counter
                                          , tbs_calendar_period_open_date
                                          , tbs_calendar_period_close_date
                                          , tbs_period_num
                                          , tbs_fiscal_year
                                          , tbs_reset_adjusted_cost_flag
                                          ;
   CLOSE c_get_period_rec;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()-', '# of records will be inserted',
                       tbs_period_counter.COUNT);
   end if;

   if (tbs_period_counter.COUNT = 0) then
      tbs_period_counter(1) := p_period_rec.period_counter;
      tbs_calendar_period_open_date(1) := p_period_rec.calendar_period_open_date;
      tbs_calendar_period_close_date(1) := p_period_rec.calendar_period_close_date;
      tbs_period_num(1) := p_period_rec.period_num;
      tbs_fiscal_year(1) := p_period_rec.fiscal_year;
      tbs_reset_adjusted_cost_flag(1) := 'Y';
   end if;
   --
   -- First record always get adjusted cost reset
   --
   tbs_reset_adjusted_cost_flag(1) := 'Y';

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Insert into', 'FA_BOOKS_SUMMARY', p_log_level_rec => p_log_level_rec);
   end if;
   --
   -- Insert all necessary records from period where DPIS falls into
   --
   if p_mrc_sob_type_code = 'R' then
      FORALL i in tbs_period_counter.FIRST..tbs_period_counter.LAST
         INSERT INTO FA_MC_BOOKS_SUMMARY(
                   SET_OF_BOOKS_ID
                 , ASSET_ID
                 , BOOK_TYPE_CODE
                 , PERIOD_COUNTER
                 , FISCAL_YEAR
                 , PERIOD_NUM
                 , CALENDAR_PERIOD_OPEN_DATE
                 , CALENDAR_PERIOD_CLOSE_DATE
                 , RESET_ADJUSTED_COST_FLAG
                 , CHANGE_IN_COST
                 , CHANGE_IN_ADDITIONS_COST
                 , CHANGE_IN_ADJUSTMENTS_COST
                 , CHANGE_IN_RETIREMENTS_COST
                 , CHANGE_IN_CIP_COST
                 , COST
                 , CIP_COST
                 , SALVAGE_TYPE
                 , PERCENT_SALVAGE_VALUE
                 , SALVAGE_VALUE
                 , MEMBER_SALVAGE_VALUE
                 , RECOVERABLE_COST
                 , DEPRN_LIMIT_TYPE
                 , ALLOWED_DEPRN_LIMIT
                 , ALLOWED_DEPRN_LIMIT_AMOUNT
                 , MEMBER_DEPRN_LIMIT_AMOUNT
                 , ADJUSTED_RECOVERABLE_COST
                 , ADJUSTED_COST
                 , DEPRECIATE_FLAG
                 , DISABLED_FLAG
                 , DATE_PLACED_IN_SERVICE
                 , DEPRN_METHOD_CODE
                 , LIFE_IN_MONTHS
                 , RATE_ADJUSTMENT_FACTOR
                 , ADJUSTED_RATE
                 , FORMULA_FACTOR
                 , BONUS_RULE
                 , ADJUSTED_CAPACITY
                 , PRODUCTION_CAPACITY
                 , UNIT_OF_MEASURE
                 , REMAINING_LIFE1
                 , REMAINING_LIFE2
                 , UNREVALUED_COST
                 , REVAL_CEILING
                 , CEILING_NAME
                 , REVAL_AMORTIZATION_BASIS
                 , EOFY_ADJ_COST
                 , EOFY_FORMULA_FACTOR
                 , EOFY_RESERVE
                 , EOP_ADJ_COST
                 , EOP_FORMULA_FACTOR
                 , SHORT_FISCAL_YEAR_FLAG
                 , GROUP_ASSET_ID
                 , SUPER_GROUP_ID
                 , OVER_DEPRECIATE_OPTION
                 , TERMINAL_GAIN_LOSS_AMOUNT
                 , TERMINAL_GAIN_LOSS_FLAG
                 , DEPRN_AMOUNT
                 , YTD_DEPRN
                 , DEPRN_RESERVE
                 , BONUS_DEPRN_AMOUNT
                 , BONUS_YTD_DEPRN
                 , BONUS_DEPRN_RESERVE
                 , IMPAIRMENT_AMOUNT
                 , YTD_IMPAIRMENT
                 , impairment_reserve
                 , LTD_PRODUCTION
                 , YTD_PRODUCTION
                 , PRODUCTION
                 , REVAL_AMORTIZATION
                 , REVAL_DEPRN_EXPENSE
                 , REVAL_RESERVE
                 , YTD_REVAL_DEPRN_EXPENSE
                 , DEPRN_OVERRIDE_FLAG
                 , SYSTEM_DEPRN_AMOUNT
                 , YTD_PROCEEDS_OF_SALE
                 , LTD_PROCEEDS_OF_SALE
                 , YTD_COST_OF_REMOVAL
                 , LTD_COST_OF_REMOVAL
                 , DEPRN_ADJUSTMENT_AMOUNT
                 , EXPENSE_ADJUSTMENT_AMOUNT
                 , UNPLANNED_AMOUNT
                 , RESERVE_ADJUSTMENT_AMOUNT
                 , CREATION_DATE
                 , CREATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATED_BY
                            )
         VALUES(   p_asset_hdr_rec.set_of_books_id
                 , p_asset_hdr_rec.asset_id
                 , p_asset_hdr_rec.book_type_code
                 , tbs_period_counter(i)
                 , tbs_fiscal_year(i)
                 , tbs_period_num(i)
                 , tbs_calendar_period_open_date(i)
                 , tbs_calendar_period_close_date(i)
                 , tbs_reset_adjusted_cost_flag(i)
                 , 0        --CHANGE_IN_COST
                 , 0        --CHANGE_IN_ADDITIONS_COST
                 , 0        --CHANGE_IN_ADJUSTMENTS_COST
                 , 0        --CHANGE_IN_RETIREMENTS_COST
                 , 0        --CHANGE_IN_CIP_COST
                 , 0        --COST
                 , 0        --CIP_COST
                 , p_asset_fin_rec.salvage_type           --SALVAGE_TYPE
                 , p_asset_fin_rec.percent_salvage_value  --PERCENT_SALVAGE_VALUE
                 , 0        --SALVAGE_VALUE
                 , 0        --MEMBER_SALVAGE_VALUE
                 , 0        --RECOVERABLE_COST
                 , p_asset_fin_rec.deprn_limit_type       --DEPRN_LIMIT_TYPE
                 , p_asset_fin_rec.allowed_deprn_limit    --ALLOWED_DEPRN_LIMIT
                 , 0        --ALLOWED_DEPRN_LIMIT_AMOUNT
                 , 0        --MEMBER_DEPRN_LIMIT_AMOUNT
                 , 0        --ADJUSTED_RECOVERABLE_COST
                 , 0        --ADJUSTED_COST
                 , p_asset_fin_rec.depreciate_flag        --DEPRECIATE_FLAG
                 , p_asset_fin_rec.disabled_flag          --DISABLED_FLAG
                 , p_asset_fin_rec.date_placed_in_service --DATE_PLACED_IN_SERVICE
                 , p_asset_fin_rec.deprn_method_code      --DEPRN_METHOD_CODE
                 , p_asset_fin_rec.life_in_months         --LIFE_IN_MONTHS
                 , 1        --RATE_ADJUSTMENT_FACTOR
                 , p_asset_fin_rec.adjusted_rate          --ADJUSTED_RATE
                 , 1        --FORMULA_FACTOR
                 , p_asset_fin_rec.bonus_rule             --BONUS_RULE
                 , p_asset_fin_rec.adjusted_capacity      --ADJUSTED_CAPACITY
                 , p_asset_fin_rec.production_capacity    --PRODUCTION_CAPACITY
                 , p_asset_fin_rec.unit_of_measure        --UNIT_OF_MEASURE
                 , p_asset_fin_rec.remaining_life1        --REMAINING_LIFE1
                 , p_asset_fin_rec.remaining_life2        --REMAINING_LIFE2
                 , 0        --UNREVALUED_COST
                 , p_asset_fin_rec.reval_ceiling          --REVAL_CEILING
                 , p_asset_fin_rec.ceiling_name           --CEILING_NAME
                 , 0        --REVAL_AMORTIZATION_BASIS
                 , 0        --EOFY_ADJ_COST
                 , 1        --EOFY_FORMULA_FACTOR
                 , 0        --EOFY_RESERVE
                 , 0        --EOP_ADJ_COST
                 , 1        --EOP_FORMULA_FACTOR
                 , 'NO'     --SHORT_FISCAL_YEAR_FLAG
                 , null     --GROUP_ASSET_ID
                 , p_asset_fin_rec.super_group_id         --SUPER_GROUP_ID
                 , p_asset_fin_rec.over_depreciate_option --OVER_DEPRECIATE_OPTION
                 , 0        --TERMINAL_GAIN_LOSS_AMOUNT
                 , 'N'      --TERMINAL_GAIN_LOSS_FLAG
                 , 0        --DEPRN_AMOUNT
                 , 0        --YTD_DEPRN
                 , 0        --DEPRN_RESERVE
                 , 0        --BONUS_DEPRN_AMOUNT
                 , 0        --BONUS_YTD_DEPRN
                 , 0        --BONUS_DEPRN_RESERVE
                 , 0        --IMPAIRMENT_AMOUNT
                 , 0        --YTD_IMPAIRMENT
                 , 0        --impairment_reserve
                 , null     --LTD_PRODUCTION
                 , null     --YTD_PRODUCTION
                 , null     --PRODUCTION
                 , 0        --REVAL_AMORTIZATION
                 , 0        --REVAL_DEPRN_EXPENSE
                 , 0        --REVAL_RESERVE
                 , 0        --YTD_REVAL_DEPRN_EXPENSE
                 , 'N'      --DEPRN_OVERRIDE_FLAG
                 , 0        --SYSTEM_DEPRN_AMOUNT
                 , 0        --YTD_PROCEEDS_OF_SALE
                 , 0        --LTD_PROCEEDS_OF_SALE
                 , 0        --YTD_COST_OF_REMOVAL
                 , 0        --LTD_COST_OF_REMOVAL
                 , 0        --DEPRN_ADJUSTMENT_AMOUNT
                 , 0        --EXPENSE_ADJUSTMENT_AMOUNT
                 , 0        --UNPLANNED_AMOUNT
                 , 0        --RESERVE_ADJUSTMENT_AMOUNT
                 , p_trans_rec.who_info.creation_date
                 , p_trans_rec.who_info.created_by
                 , p_trans_rec.who_info.last_update_date
                 , p_trans_rec.who_info.last_updated_by
                 );

   else

      FORALL i in tbs_period_counter.FIRST..tbs_period_counter.LAST
         INSERT INTO FA_BOOKS_SUMMARY(
                   ASSET_ID
                 , BOOK_TYPE_CODE
                 , PERIOD_COUNTER
                 , FISCAL_YEAR
                 , PERIOD_NUM
                 , CALENDAR_PERIOD_OPEN_DATE
                 , CALENDAR_PERIOD_CLOSE_DATE
                 , RESET_ADJUSTED_COST_FLAG
                 , CHANGE_IN_COST
                 , CHANGE_IN_ADDITIONS_COST
                 , CHANGE_IN_ADJUSTMENTS_COST
                 , CHANGE_IN_RETIREMENTS_COST
                 , CHANGE_IN_CIP_COST
                 , COST
                 , CIP_COST
                 , SALVAGE_TYPE
                 , PERCENT_SALVAGE_VALUE
                 , SALVAGE_VALUE
                 , MEMBER_SALVAGE_VALUE
                 , RECOVERABLE_COST
                 , DEPRN_LIMIT_TYPE
                 , ALLOWED_DEPRN_LIMIT
                 , ALLOWED_DEPRN_LIMIT_AMOUNT
                 , MEMBER_DEPRN_LIMIT_AMOUNT
                 , ADJUSTED_RECOVERABLE_COST
                 , ADJUSTED_COST
                 , DEPRECIATE_FLAG
                 , DISABLED_FLAG
                 , DATE_PLACED_IN_SERVICE
                 , DEPRN_METHOD_CODE
                 , LIFE_IN_MONTHS
                 , RATE_ADJUSTMENT_FACTOR
                 , ADJUSTED_RATE
                 , FORMULA_FACTOR
                 , BONUS_RULE
                 , ADJUSTED_CAPACITY
                 , PRODUCTION_CAPACITY
                 , UNIT_OF_MEASURE
                 , REMAINING_LIFE1
                 , REMAINING_LIFE2
                 , UNREVALUED_COST
                 , REVAL_CEILING
                 , CEILING_NAME
                 , REVAL_AMORTIZATION_BASIS
                 , EOFY_ADJ_COST
                 , EOFY_FORMULA_FACTOR
                 , EOFY_RESERVE
                 , EOP_ADJ_COST
                 , EOP_FORMULA_FACTOR
                 , SHORT_FISCAL_YEAR_FLAG
                 , GROUP_ASSET_ID
                 , SUPER_GROUP_ID
                 , OVER_DEPRECIATE_OPTION
                 , TERMINAL_GAIN_LOSS_AMOUNT
                 , TERMINAL_GAIN_LOSS_FLAG
                 , DEPRN_AMOUNT
                 , YTD_DEPRN
                 , DEPRN_RESERVE
                 , BONUS_DEPRN_AMOUNT
                 , BONUS_YTD_DEPRN
                 , BONUS_DEPRN_RESERVE
                 , IMPAIRMENT_AMOUNT
                 , YTD_IMPAIRMENT
                 , impairment_reserve
                 , LTD_PRODUCTION
                 , YTD_PRODUCTION
                 , PRODUCTION
                 , REVAL_AMORTIZATION
                 , REVAL_DEPRN_EXPENSE
                 , REVAL_RESERVE
                 , YTD_REVAL_DEPRN_EXPENSE
                 , DEPRN_OVERRIDE_FLAG
                 , SYSTEM_DEPRN_AMOUNT
                 , YTD_PROCEEDS_OF_SALE
                 , LTD_PROCEEDS_OF_SALE
                 , YTD_COST_OF_REMOVAL
                 , LTD_COST_OF_REMOVAL
                 , DEPRN_ADJUSTMENT_AMOUNT
                 , EXPENSE_ADJUSTMENT_AMOUNT
                 , UNPLANNED_AMOUNT
                 , RESERVE_ADJUSTMENT_AMOUNT
                 , CREATION_DATE
                 , CREATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATED_BY
                 )
         VALUES(   p_asset_hdr_rec.asset_id
                 , p_asset_hdr_rec.book_type_code
                 , tbs_period_counter(i)
                 , tbs_fiscal_year(i)
                 , tbs_period_num(i)
                 , tbs_calendar_period_open_date(i)
                 , tbs_calendar_period_close_date(i)
                 , tbs_reset_adjusted_cost_flag(i)
                 , 0        --CHANGE_IN_COST
                 , 0        --CHANGE_IN_ADDITIONS_COST
                 , 0        --CHANGE_IN_ADJUSTMENTS_COST
                 , 0        --CHANGE_IN_RETIREMENTS_COST
                 , 0        --CHANGE_IN_CIP_COST
                 , 0        --COST
                 , 0        --CIP_COST
                 , p_asset_fin_rec.salvage_type           --SALVAGE_TYPE
                 , p_asset_fin_rec.percent_salvage_value  --PERCENT_SALVAGE_VALUE
                 , 0        --SALVAGE_VALUE
                 , 0        --MEMBER_SALVAGE_VALUE
                 , 0        --RECOVERABLE_COST
                 , p_asset_fin_rec.deprn_limit_type       --DEPRN_LIMIT_TYPE
                 , p_asset_fin_rec.allowed_deprn_limit    --ALLOWED_DEPRN_LIMIT
                 , 0        --ALLOWED_DEPRN_LIMIT_AMOUNT
                 , 0        --MEMBER_DEPRN_LIMIT_AMOUNT
                 , 0        --ADJUSTED_RECOVERABLE_COST
                 , 0        --ADJUSTED_COST
                 , p_asset_fin_rec.depreciate_flag        --DEPRECIATE_FLAG
                 , p_asset_fin_rec.disabled_flag          --DISABLED_FLAG
                 , p_asset_fin_rec.date_placed_in_service --DATE_PLACED_IN_SERVICE
                 , p_asset_fin_rec.deprn_method_code      --DEPRN_METHOD_CODE
                 , p_asset_fin_rec.life_in_months         --LIFE_IN_MONTHS
                 , 1        --RATE_ADJUSTMENT_FACTOR
                 , p_asset_fin_rec.adjusted_rate          --ADJUSTED_RATE
                 , 1        --FORMULA_FACTOR
                 , p_asset_fin_rec.bonus_rule             --BONUS_RULE
                 , p_asset_fin_rec.adjusted_capacity      --ADJUSTED_CAPACITY
                 , p_asset_fin_rec.production_capacity    --PRODUCTION_CAPACITY
                 , p_asset_fin_rec.unit_of_measure        --UNIT_OF_MEASURE
                 , p_asset_fin_rec.remaining_life1        --REMAINING_LIFE1
                 , p_asset_fin_rec.remaining_life2        --REMAINING_LIFE2
                 , 0        --UNREVALUED_COST
                 , p_asset_fin_rec.reval_ceiling          --REVAL_CEILING
                 , p_asset_fin_rec.ceiling_name           --CEILING_NAME
                 , 0        --REVAL_AMORTIZATION_BASIS
                 , 0        --EOFY_ADJ_COST
                 , 1        --EOFY_FORMULA_FACTOR
                 , 0        --EOFY_RESERVE
                 , 0        --EOP_ADJ_COST
                 , 1        --EOP_FORMULA_FACTOR
                 , 'NO'     --SHORT_FISCAL_YEAR_FLAG
                 , null     --GROUP_ASSET_ID
                 , p_asset_fin_rec.super_group_id         --SUPER_GROUP_ID
                 , p_asset_fin_rec.over_depreciate_option --OVER_DEPRECIATE_OPTION
                 , 0        --TERMINAL_GAIN_LOSS_AMOUNT
                 , 'N'      --TERMINAL_GAIN_LOSS_FLAG
                 , 0        --DEPRN_AMOUNT
                 , 0        --YTD_DEPRN
                 , 0        --DEPRN_RESERVE
                 , 0        --BONUS_DEPRN_AMOUNT
                 , 0        --BONUS_YTD_DEPRN
                 , 0        --BONUS_DEPRN_RESERVE
                 , 0        --IMPAIRMENT_AMOUNT
                 , 0        --YTD_IMPAIRMENT
                 , 0        --impairment_reserve
                 , null     --LTD_PRODUCTION
                 , null     --YTD_PRODUCTION
                 , null     --PRODUCTION
                 , 0        --REVAL_AMORTIZATION
                 , 0        --REVAL_DEPRN_EXPENSE
                 , 0        --REVAL_RESERVE
                 , 0        --YTD_REVAL_DEPRN_EXPENSE
                 , 'N'      --DEPRN_OVERRIDE_FLAG
                 , 0        --SYSTEM_DEPRN_AMOUNT
                 , 0        --YTD_PROCEEDS_OF_SALE
                 , 0        --LTD_PROCEEDS_OF_SALE
                 , 0        --YTD_COST_OF_REMOVAL
                 , 0        --LTD_COST_OF_REMOVAL
                 , 0        --DEPRN_ADJUSTMENT_AMOUNT
                 , 0        --EXPENSE_ADJUSTMENT_AMOUNT
                 , 0        --UNPLANNED_AMOUNT
                 , 0        --RESERVE_ADJUSTMENT_AMOUNT
                 , p_trans_rec.who_info.creation_date
                 , p_trans_rec.who_info.created_by
                 , p_trans_rec.who_info.last_update_date
                 , p_trans_rec.who_info.last_updated_by
                 );
   end if; --p_mrc_sob_type_code = 'R'

   printBooksSummary(p_asset_id       => p_asset_hdr_rec.asset_id,
                     p_book_type_code => p_asset_hdr_rec.book_type_code,
                     p_period_counter => tbs_period_counter(1),
                     p_log_level_rec  => p_log_level_rec);

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()-', '# of records inserted', tbs_period_counter.COUNT);
   end if;

   return true;

EXCEPTION
   WHEN OTHERS THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'(OTHERS)-', 'sqlcode', sqlcode);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;
END createGroup;

--+==============================================================================
-- Function: buildMemberTable
--
--+==============================================================================
FUNCTION buildMemberTable(
     p_trans_rec                          FA_API_TYPES.trans_rec_type,
     p_asset_hdr_rec                      FA_API_TYPES.asset_hdr_rec_type,
     p_period_rec                         FA_API_TYPES.period_rec_type,
     p_date_placed_in_service             DATE,
     p_group_asset_id                     NUMBER,
     p_reclass_multiplier                 NUMBER,
     p_reclass_src_dest                   VARCHAR2,
     p_salvage_limit_type                 VARCHAR2,
     x_td_period_counter       OUT NOCOPY fa_amort_pvt.tab_num15_type,
     x_td_cost                 OUT NOCOPY fa_amort_pvt.tab_num_type,
     x_td_cip_cost             OUT NOCOPY fa_amort_pvt.tab_num_type,
     x_td_salvage_value        OUT NOCOPY fa_amort_pvt.tab_num_type,
     x_td_deprn_limit_amount   OUT NOCOPY fa_amort_pvt.tab_num_type,
     x_asset_fin_rec           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     x_asset_fin_rec_reclass   OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     p_mrc_sob_type_code                  VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)return BOOLEAN IS

   l_calling_fn  VARCHAR2(50) := 'FA_AMORT_PVT.buildMemberTable';

   --
   -- Get Period and 0s for cost, cip_cost, salvage value,
   -- deprn limit amount, percent_salvage_value, and allowed_deprn_limit
   -- and nulls for salvage_type and deprn_limit_type for building
   -- tables
   CURSOR c_get_period_counters (c_date date,
                                c_group_asset_id number) IS
      select period_counter,
             0, 0, 0, 0, 0, null, 0, null, 0, 0, 0
      from   fa_books_summary
      where  asset_id = c_group_asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    calendar_period_close_date >= c_date
      order by period_counter;


  CURSOR c_get_member_trx IS
    select th.transaction_header_id
         , th.transaction_type_code
         , th.transaction_subtype
         , th.transaction_key
         , bs.period_counter
    from   fa_transaction_headers th
         , fa_books_summary bs
         , fa_transaction_headers mth
         , fa_books bk
    where  mth.transaction_header_id = p_trans_rec.member_transaction_header_id
    and    th.asset_id = mth.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    bs.asset_id = p_group_asset_id
    and    bs.book_type_code = p_asset_hdr_rec.book_type_code
    and    bk.transaction_header_id_in = th.transaction_header_id
    and    decode(th.transaction_subtype,
                  'EXPENSED', greatest(decode(bk.group_asset_id,
                                       null,p_date_placed_in_service,
                                            nvl(th.amortization_start_date,
                                                th.transaction_date_entered)), p_date_placed_in_service),
                              greatest(nvl(th.amortization_start_date,
                                           th.transaction_date_entered), p_date_placed_in_service))
                                      between bs.calendar_period_open_date
                                          and bs.calendar_period_close_date
    and    (th.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                            'TRANSFER', 'TRANSFER IN/VOID',
                                            'RECLASS', 'UNIT ADJUSTMENT',
                                            'REINSTATEMENT')
        or  (th.transaction_type_code = 'REINSTATEMENT' and
             th.transaction_header_id = p_trans_rec.member_transaction_header_id));

   CURSOR c_get_member_trx_single IS
     select mth.transaction_header_id
          , mth.transaction_type_code
          , mth.transaction_subtype
          , mth.transaction_key
          , bs.period_counter
    from    fa_books_summary bs
          , fa_transaction_headers mth
          , fa_books bk
    where   mth.transaction_header_id = p_trans_rec.member_transaction_header_id
    and     bs.asset_id = p_group_asset_id
    and     bs.book_type_code = p_asset_hdr_rec.book_type_code
    and     bk.transaction_header_id_in = mth.transaction_header_id
    and     decode(mth.transaction_subtype,
                   'EXPENSED', greatest(decode(bk.group_asset_id,
                                        null,p_date_placed_in_service,
                                             nvl(mth.amortization_start_date,
                                                 mth.transaction_date_entered)), p_date_placed_in_service),
                               greatest(nvl(mth.amortization_start_date,
                                            mth.transaction_date_entered), p_date_placed_in_service))
                                       between bs.calendar_period_open_date
                                           and bs.calendar_period_close_date
    and     (mth.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                             'TRANSFER', 'TRANSFER IN/VOID',
                                             'RECLASS', 'UNIT ADJUSTMENT',
                                             'REINSTATEMENT')
       or    (mth.transaction_type_code = 'REINSTATEMENT' and
              mth.transaction_header_id = p_trans_rec.member_transaction_header_id));

   --
   -- Cursor to get retirement information using retirement
   -- transaction_header_id
   --
   CURSOR c_get_ret_info (c_transaction_header_id number) IS
     select ret.date_retired
          , ret.cost_retired
          , nvl(ret.reserve_retired, 0)
          , ret.proceeds_of_sale
          , ret.cost_of_removal
     from   fa_retirements ret
     where  ret.transaction_header_id_in = c_transaction_header_id
     and    ret.transaction_header_id_out is null;

   CURSOR c_get_mc_ret_info (c_transaction_header_id number) IS
     select ret.date_retired
          , ret.cost_retired
          , nvl(ret.reserve_retired, 0)
          , ret.proceeds_of_sale
          , ret.cost_of_removal
     from   fa_mc_retirements ret
     where  ret.transaction_header_id_in = c_transaction_header_id
     and    ret.transaction_header_id_out is null
     and    ret.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   --bug6912446
   -- Following cursors to get retirement period for reinstatement trx
   CURSOR c_get_ret_period (c_transaction_header_id number)IS
      select bs.period_counter
      from   fa_books_summary bs
           , fa_retirements rt
      where  bs.asset_id = p_group_asset_id
      and    bs.book_type_code = p_asset_hdr_rec.book_type_code
      and    rt.date_retired between bs.calendar_period_open_date and bs.calendar_period_close_date
      and    rt.transaction_header_id_out = c_transaction_header_id;

   CURSOR c_get_mc_ret_period (c_transaction_header_id number)IS
      select bs.period_counter
      from   fa_mc_books_summary bs
           , fa_mc_retirements rt
      where  bs.asset_id = p_group_asset_id
      and    bs.book_type_code = p_asset_hdr_rec.book_type_code
      and    bs.set_of_books_id = p_asset_hdr_rec.set_of_books_id
      and    rt.date_retired between bs.calendar_period_open_date and bs.calendar_period_close_date
      and    rt.transaction_header_id_out = c_transaction_header_id
      and    rt.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   --End of bug6912446

   --
   -- Cursor to get delta information in cost for a given transaction
   -- p_reclass_multiplier will be -1 if this is source group asset process.
   -- it wil be 1 for all other cases.
   --
   CURSOR c_get_deltas ( c_transaction_header_id number) IS
     select p_reclass_multiplier * (inbk.cost - nvl(outbk.cost, 0))
          , p_reclass_multiplier * (nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0))
          , p_reclass_multiplier * (decode(inbk.salvage_type,
                                             outbk.salvage_type,
                                               inbk.salvage_value - nvl(outbk.salvage_value, 0),
                                               inbk.salvage_value))
          , p_reclass_multiplier *
                (decode(inbk.deprn_limit_type,
                           outbk.deprn_limit_type,
                              nvl(decode(inbk.deprn_limit_type, 'NONE', inbk.salvage_value,
                                                                     inbk.allowed_deprn_limit_amount), 0) -
                              nvl(decode(outbk.deprn_limit_type, 'NONE', outbk.salvage_value,
                                                                     outbk.allowed_deprn_limit_amount), 0),
                              nvl(decode(inbk.deprn_limit_type, 'NONE', inbk.salvage_value,
                                                                        inbk.allowed_deprn_limit_amount), 0)))
          , inbk.salvage_type
          , outbk.salvage_type
          , inbk.percent_salvage_value
          , outbk.percent_salvage_value
          , inbk.deprn_limit_type
          , outbk.deprn_limit_type
          , inbk.allowed_deprn_limit
          , outbk.allowed_deprn_limit
     from   fa_books inbk,
            fa_books outbk
          , fa_transaction_headers mth
     where  mth.transaction_header_id = p_trans_rec.member_transaction_header_id
     and    inbk.asset_id = mth.asset_id
     and    outbk.asset_id(+) = inbk.asset_id
     and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
     and    outbk.book_type_code(+) = inbk.book_type_code
     and    inbk.transaction_header_id_in = c_transaction_header_id
     and    outbk.transaction_header_id_out(+) = inbk.transaction_header_id_in;

   CURSOR c_get_mc_deltas ( c_transaction_header_id number) IS
     select p_reclass_multiplier * (inbk.cost - nvl(outbk.cost, 0))
          , p_reclass_multiplier * (nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0))
          , p_reclass_multiplier * (decode(inbk.salvage_type,
                                             outbk.salvage_type,
                                               inbk.salvage_value - nvl(outbk.salvage_value, 0),
                                               inbk.salvage_value))
          , p_reclass_multiplier *
                (decode(inbk.deprn_limit_type,
                           outbk.deprn_limit_type,
                              nvl(decode(inbk.deprn_limit_type, 'NONE', inbk.salvage_value,
                                                                     inbk.allowed_deprn_limit_amount), 0) -
                              nvl(decode(outbk.deprn_limit_type, 'NONE', outbk.salvage_value,
                                                                     outbk.allowed_deprn_limit_amount), 0),
                              nvl(decode(inbk.deprn_limit_type, 'NONE', inbk.salvage_value,
                                                                        inbk.allowed_deprn_limit_amount), 0)))
          , inbk.salvage_type
          , outbk.salvage_type
          , inbk.percent_salvage_value
          , outbk.percent_salvage_value
          , inbk.deprn_limit_type
          , outbk.deprn_limit_type
          , inbk.allowed_deprn_limit
          , outbk.allowed_deprn_limit
     from   fa_mc_books inbk,
            fa_mc_books outbk
          , fa_transaction_headers mth
     where  mth.transaction_header_id = p_trans_rec.member_transaction_header_id
     and    inbk.asset_id = mth.asset_id
     and    outbk.asset_id(+) = inbk.asset_id
     and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
     and    outbk.book_type_code(+) = inbk.book_type_code
     and    inbk.transaction_header_id_in = c_transaction_header_id
     and    outbk.transaction_header_id_out(+) = inbk.transaction_header_id_in
     and    inbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
     and    outbk.set_of_books_id(+) = p_asset_hdr_rec.set_of_books_id;
--toru

   --
   -- Tables to store member information
   --
   t_transaction_header_id        fa_amort_pvt.tab_num15_type;

   l_dpis_pc                      NUMBER(15); -- Period counter where member's dpis falls in

   tr_transaction_header_id       fa_amort_pvt.tab_num15_type;
   tr_transaction_type_code       fa_amort_pvt.tab_char30_type;
   tr_transaction_subtype         fa_amort_pvt.tab_char30_type;
   tr_transaction_key             fa_amort_pvt.tab_char3_type;
   tr_period_counter              fa_amort_pvt.tab_num15_type;

   l_date_retired                 DATE;
   l_cost_retired                 NUMBER;
   l_reserve_retired              NUMBER;
   l_proceeds_of_sale             NUMBER;
   l_cost_of_removal              NUMBER;

   l_cost                         NUMBER;
   l_cip_cost                     NUMBER;
   l_salvage_value                NUMBER;
   l_deprn_limit_amount           NUMBER;
   l_salvage_type                 VARCHAR2(30);
   l_old_salvage_type             VARCHAR2(30);
   l_percent_salvage_value        NUMBER;
   l_old_percent_salvage_value    NUMBER;
   l_deprn_limit_type             VARCHAR2(30);
   l_old_deprn_limit_type         VARCHAR2(30);
   l_allowed_deprn_limit          NUMBER;
   l_old_allowed_deprn_limit      NUMBER;

   t_period_counter               fa_amort_pvt.tab_num15_type;
   t_cost                         fa_amort_pvt.tab_num_type;
   t_cip_cost                     fa_amort_pvt.tab_num_type;
   t_salvage_type                 fa_amort_pvt.tab_char30_type;
   t_percent_salvage_value        fa_amort_pvt.tab_num_type;
   t_salvage_value                fa_amort_pvt.tab_num_type;
   t_deprn_limit_type             fa_amort_pvt.tab_char30_type;
   t_allowed_deprn_limit          fa_amort_pvt.tab_num_type;
   t_deprn_limit_amount           fa_amort_pvt.tab_num_type;
   t_sal_thid                     fa_amort_pvt.tab_num15_type;
   t_limit_thid                   fa_amort_pvt.tab_num15_type;


   l_sal_thid              NUMBER(15) := 0;
   l_limit_thid            NUMBER(15) := 0;

   -- Bug4958977: Adding following 4 new variables
   l_asset_fin_rec          FA_API_TYPES.asset_fin_rec_type;
   l_period_counter         NUMBER;
   bld_err                  EXCEPTION;
   l_cur_trx_period_counter NUMBER;

   l_ind                   BINARY_INTEGER; -- Index variable
   l_temp_num              NUMBER;  -- used for calling fa_round_pkg
   ld_ind                  BINARY_INTEGER := 0;
   l_reinstated            BOOLEAN;


BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()+', 'asset_id', p_asset_hdr_rec.asset_id);
      fa_debug_pkg.add(l_calling_fn, 'group_asset_id', p_group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;
--tk_util.debug('p_reclass_multiplier: '||to_char(p_reclass_multiplier));

   if (p_reclass_src_dest = 'DESTINATION') and
      (fa_amort_pvt.tmd_period_counter.COUNT > 0) then
      l_ind := p_period_rec.period_counter - (fa_amort_pvt.tmd_period_counter(1) - 1);

      FOR i in l_ind..fa_amort_pvt.tmd_period_counter.COUNT LOOP
--tk_util.debug('i: '||to_char(i));
         ld_ind := ld_ind + 1;
         x_td_period_counter(ld_ind) := fa_amort_pvt.tmd_period_counter(i);
         x_td_cost(ld_ind) := -1 * fa_amort_pvt.tmd_cost(i);
         x_td_cip_cost(ld_ind) := -1 * fa_amort_pvt.tmd_cip_cost(i);
         x_td_salvage_value(ld_ind) := -1 * fa_amort_pvt.tmd_salvage_value(i);
         x_td_deprn_limit_amount(ld_ind) := -1 * fa_amort_pvt.tmd_deprn_limit_amount(i);
--tk_util.debug('fa_amort_pvt.tmd_period_counter(i): '||to_char(fa_amort_pvt.tmd_period_counter(i)));
--tk_util.debug('fa_amort_pvt.tm_cost(i): '||to_char(fa_amort_pvt.tm_cost(i)));
--tk_util.debug('fa_amort_pvt.tmd_cost(i): '||to_char(fa_amort_pvt.tmd_cost(i)));
--tk_util.debug('x_td_cost(ld_ind): '||to_char(x_td_cost(ld_ind)));
      END LOOP;
--tk_util.debug('Post loop');
      x_asset_fin_rec_reclass.cost := -1 * fa_amort_pvt.tm_cost(l_ind);
--tk_util.debug('x_asset_fin_rec_reclass.cost: '||to_char(x_asset_fin_rec_reclass.cost));
      x_asset_fin_rec_reclass.cip_cost := -1 * fa_amort_pvt.tm_cip_cost(l_ind);
      x_asset_fin_rec_reclass.salvage_value := -1 * fa_amort_pvt.tm_salvage_value(l_ind);
      x_asset_fin_rec_reclass.allowed_deprn_limit_amount :=
                                          -1 * fa_amort_pvt.tm_deprn_limit_amount(l_ind);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'()-', '# of rows in delta tables', x_td_cost.COUNT);
      end if;

      return TRUE;

   end if;
   --
   -- Construct member asset table using group's data in FA_BOOKS_SUMMARY
   --
--tk_util.debug('c_date: '||to_char(p_date_placed_in_service, 'DD-MON-YYYY'));
   OPEN c_get_period_counters (p_date_placed_in_service,
                               p_group_asset_id);

   FETCH c_get_period_counters BULK COLLECT INTO t_period_counter
                                               , t_transaction_header_id
                                               , fa_amort_pvt.tmd_cost
                                               , fa_amort_pvt.tmd_cip_cost
                                               , fa_amort_pvt.tmd_salvage_value
                                               , fa_amort_pvt.tmd_deprn_limit_amount
                                               , t_salvage_type
                                               , t_percent_salvage_value
                                               , t_deprn_limit_type
                                               , t_allowed_deprn_limit
                                               , t_sal_thid
                                               , t_limit_thid;
   CLOSE c_get_period_counters;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Finish Constructing Memebr Table',
                       t_period_counter.COUNT, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.transaction_key', p_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_salvage_limit_type', p_salvage_limit_type, p_log_level_rec => p_log_level_rec);
   end if;

   l_dpis_pc := t_period_counter(1);

   --
   -- Get member asset's transactions
   --
--tk_util.debug('asset_id: '||to_char(p_asset_hdr_rec.asset_id));
--tk_util.debug('book: '||p_asset_hdr_rec.book_type_code);
--tk_util.debug('p_dpis: '||to_char(p_date_placed_in_service, 'DD-MM-YYYY'));
--tk_util.debug('p_group_asset_id: '||to_char(p_group_asset_id));

   --
   -- bug5149789: if we can prevent salvage_type or deprn_limit_type
   -- change once the member is added, then we can check against
   -- trx key.  Otherwise we need to go with type now.
--   if (p_trans_rec.transaction_key = 'GC') then -- bug5149789
   if (p_trans_rec.transaction_key = 'GC') or (p_salvage_limit_type = 'SUM') then
      OPEN c_get_member_trx;
      FETCH c_get_member_trx BULK COLLECT INTO tr_transaction_header_id
                                             , tr_transaction_type_code
                                             , tr_transaction_subtype
                                             , tr_transaction_key
                                             , tr_period_counter
                                               ;
      CLOSE c_get_member_trx;
   else -- bug5149789
      --
      -- bug5149789
      -- Even thought following cursor is using bulk, it should only return
      -- one row.  It is using pl/sql table of columns to be consistent.
      OPEN c_get_member_trx_single;
      FETCH c_get_member_trx_single BULK COLLECT INTO tr_transaction_header_id
                                                    , tr_transaction_type_code
                                                    , tr_transaction_subtype
                                                    , tr_transaction_key
                                                    , tr_period_counter
                                                     ;
      CLOSE c_get_member_trx_single;

   end if; -- bug5149789

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()+', 'Finish Getting Memebr Trxs',
                       tr_transaction_header_id.COUNT);
   end if;

   --
   -- Get Delta information for each transaction and populate delta information.
   --
   FOR i in 1..tr_transaction_header_id.COUNT LOOP

      --bug6912446
      if (tr_transaction_type_code(i) = 'REINSTATEMENT') then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'following period counter may change', tr_period_counter(i));
         end if;
         if (p_mrc_sob_type_code = 'R') then
            OPEN c_get_mc_ret_period(tr_transaction_header_id(i));
            FETCH c_get_mc_ret_period INTO tr_period_counter(i);
            CLOSE c_get_mc_ret_period;
         else
            OPEN c_get_ret_period(tr_transaction_header_id(i));
            FETCH c_get_ret_period INTO tr_period_counter(i);
            CLOSE c_get_ret_period;
         end if;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'new tr_period_counter(i)', tr_period_counter(i));
         end if;
      end if;
      --End bug6912446

      --Bug4622110: Following part of code have been uncommented
      -- Guess it was coded but not tested so it has never been used before
      l_reinstated := FALSE;

      if (p_mrc_sob_type_code = 'R') then
         if (tr_transaction_key(i) = 'R') then
            OPEN c_get_mc_ret_info(tr_transaction_header_id(i));
            FETCH c_get_mc_ret_info INTO l_date_retired
                                       , l_cost_retired
                                       , l_reserve_retired
                                       , l_proceeds_of_sale
                                       , l_cost_of_removal;
            if c_get_mc_ret_info%NOTFOUND then
               l_reinstated := TRUE;
            end if;

            CLOSE c_get_mc_ret_info;

         end if;
      else
         if (tr_transaction_key(i) = 'R') then
            OPEN c_get_ret_info(tr_transaction_header_id(i));
            FETCH c_get_ret_info INTO l_date_retired
                                    , l_cost_retired
                                    , l_reserve_retired
                                    , l_proceeds_of_sale
                                    , l_cost_of_removal;
            if c_get_ret_info%NOTFOUND then
               l_reinstated := TRUE;
            end if;

            CLOSE c_get_ret_info;

         end if;
      end if;

      if (not l_reinstated) or
         ((l_reinstated) and
          (tr_transaction_header_id(i) =
                   p_trans_rec.member_transaction_header_id)) then

         if (p_mrc_sob_type_code = 'R') then
            OPEN c_get_mc_deltas(tr_transaction_header_id(i));
            FETCH c_get_mc_deltas INTO l_cost
                                  , l_cip_cost
                                  , l_salvage_value
                                  , l_deprn_limit_amount
                                  , l_salvage_type
                                  , l_old_salvage_type
                                  , l_percent_salvage_value
                                  , l_old_percent_salvage_value
                                  , l_deprn_limit_type
                                  , l_old_deprn_limit_type
                                  , l_allowed_deprn_limit
                                  , l_old_allowed_deprn_limit;
            CLOSE c_get_mc_deltas;
         else
            OPEN c_get_deltas(tr_transaction_header_id(i));
            FETCH c_get_deltas INTO l_cost
                                  , l_cip_cost
                                  , l_salvage_value
                                  , l_deprn_limit_amount
                                  , l_salvage_type
                                  , l_old_salvage_type
                                  , l_percent_salvage_value
                                  , l_old_percent_salvage_value
                                  , l_deprn_limit_type
                                  , l_old_deprn_limit_type
                                  , l_allowed_deprn_limit
                                  , l_old_allowed_deprn_limit;
            CLOSE c_get_deltas;
         end if;
/*
--tk_util.debug('thid:cost:sal:dl: '||to_char(tr_transaction_header_id(i))||':'||
                                       to_char(l_cost)||':'||
                                       to_char(l_salvage_value)||':'||
                                       to_char(l_deprn_limit_amount));
*/

         if (tr_transaction_header_id(i) <>
                                  p_trans_rec.member_transaction_header_id) then

            -- Fix for 4713623
            -- this case happens when dpis of member is changed after ADDITION
            -- for example from jan to mar and bs table is only from march
            -- In such cases l_ind using tr_period_counter(i) - l_dpis_pc + 1
            -- can be negative.
            -- the fix handles that any transaction before current dpis
            -- is made to look from current dpis period

            if (tr_period_counter(i) < l_dpis_pc) then
               l_ind := 1;
            else
                l_ind := tr_period_counter(i) - l_dpis_pc + 1;
            end if;

            fa_amort_pvt.tmd_cost(l_ind)               :=
                                fa_amort_pvt.tmd_cost(l_ind) + l_cost;
            fa_amort_pvt.tmd_cip_cost(l_ind)           :=
                                fa_amort_pvt.tmd_cip_cost(l_ind) + l_cip_cost;
            fa_amort_pvt.tmd_salvage_value(l_ind)      :=
                                fa_amort_pvt.tmd_salvage_value(l_ind) +
                                l_salvage_value;
            fa_amort_pvt.tmd_deprn_limit_amount(l_ind) :=
                                fa_amort_pvt.tmd_deprn_limit_amount(l_ind) +
                                l_deprn_limit_amount;

            --
            -- Following line may be removed.  This is not necessary
            -- since introduction of t_sal(limit)_thids.
            t_transaction_header_id(l_ind) := tr_transaction_header_id(i);

            --
            -- Subsequent retroactive salvage/deprn limit change may override
            -- previously entered information. So copy only qualified salvage/
            -- deprn limit changes.
            --
--tk_util.debug('t_sal_thid(l_ind): '||to_char(t_sal_thid(l_ind)));
--tk_util.debug('tr_transaction_header_id(i): '||to_char(tr_transaction_header_id(i)));
--tk_util.debug('l_percent_salvage_value: '||to_char(l_percent_salvage_value));
--tk_util.debug('l_old_percent_salvage_value: '||to_char(l_old_percent_salvage_value));
--tk_util.debug('l_salvage_type: '||l_salvage_type);
--tk_util.debug('l_salvage_value: '||to_char(l_salvage_value));

            if (t_sal_thid(l_ind) < tr_transaction_header_id(i)) and
               ((l_salvage_type <> l_old_salvage_type) or
                (nvl(l_percent_salvage_value, 0) <> nvl(l_old_percent_salvage_value, 0)) or
                (l_salvage_type = 'AMT' and l_salvage_value <> 0)) then

               t_sal_thid(l_ind) := tr_transaction_header_id(i);
               t_salvage_type(l_ind)          := l_salvage_type;
               t_percent_salvage_value(l_ind) := l_percent_salvage_value;

            end if;

            if (t_limit_thid(l_ind) < tr_transaction_header_id(i)) and
               ((l_deprn_limit_type <> l_old_deprn_limit_type) or
                (l_allowed_deprn_limit <> l_old_allowed_deprn_limit) or
                (l_deprn_limit_type = 'AMT' and l_deprn_limit_amount <> 0)) then

               t_limit_thid(l_ind) := tr_transaction_header_id(i);
               t_deprn_limit_type(l_ind)      := l_deprn_limit_type;
               t_allowed_deprn_limit(l_ind)   := l_allowed_deprn_limit;

            end if;

         else
            l_cur_trx_period_counter                   := tr_period_counter(i); -- Bug4958977
            x_asset_fin_rec.cost                       := l_cost;
            x_asset_fin_rec.cip_cost                   := l_cip_cost;
            x_asset_fin_rec.salvage_value              := l_salvage_value;
            x_asset_fin_rec.allowed_deprn_limit_amount := l_deprn_limit_amount;
            x_asset_fin_rec.salvage_type               := l_salvage_type;
            x_asset_fin_rec.percent_salvage_value      := l_percent_salvage_value;
            x_asset_fin_rec.deprn_limit_type           := l_deprn_limit_type;
            x_asset_fin_rec.allowed_deprn_limit        := l_allowed_deprn_limit;

            -- Bug4958977: Adding following if statements
            if (nvl(l_cost, 0) = 0) and
               (nvl(l_cip_cost, 0) = 0) and
               (nvl(l_salvage_value, 0) = 0) and
               (nvl(l_deprn_limit_amount, 0) = 0) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling', 'check_dpis_change', p_log_level_rec => p_log_level_rec);
               end if;

               if not check_dpis_change (
                          p_book_type_code        => p_asset_hdr_rec.book_type_code
                        , p_transaction_header_id => tr_transaction_header_id(i)
                        , p_group_asset_id        => p_group_asset_id
                        , x_asset_fin_rec         => l_asset_fin_rec
                        , x_period_counter_out    => l_period_counter
                        , p_mrc_sob_type_code     => p_mrc_sob_type_code
                        , p_log_level_rec         => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'error calling', 'check_dpis_change', p_log_level_rec => p_log_level_rec);
                  end if;
                  raise bld_err;
               end if;

               if (l_period_counter is not null) then
                  x_asset_fin_rec.cost                       := l_asset_fin_rec.cost;
                  x_asset_fin_rec.cip_cost                   := l_asset_fin_rec.cip_cost;
                  x_asset_fin_rec.salvage_value              := l_asset_fin_rec.salvage_value;
                  x_asset_fin_rec.allowed_deprn_limit_amount := l_asset_fin_rec.allowed_deprn_limit_amount;
               end if;
            end if; -- (nvl(l_cost, 0) = 0) and

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'cost', x_asset_fin_rec.cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'cip_cost', x_asset_fin_rec.cip_cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'salvage_value', x_asset_fin_rec.salvage_value, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'allowed_deprn_limit_amount',
                                x_asset_fin_rec.allowed_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'salvage_type', x_asset_fin_rec.salvage_type, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'percent_salvage_value', x_asset_fin_rec.percent_salvage_value, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'deprn_limit_type', x_asset_fin_rec.deprn_limit_type, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'allowed_deprn_limit', x_asset_fin_rec.allowed_deprn_limit, p_log_level_rec => p_log_level_rec);
            end if;

         end if; -- (tr_transaction_header_id(i) <>

      end if; -- (not l_reinstated) or

   END LOOP;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()+', 'Finish Getting Deltas for Each Trx',
                       tr_transaction_header_id.COUNT);
   end if;

   --
   -- if this is not reclass, return delta
   -- if this is reclass, return member's from dpis no matter
   -- what is reclass date is.
   -- if reclass date is not dpis, update won't include upto that period.
   -- adjust foall update statement to update necessary period
   -- note: in that case, first period for the reclass got some hit
   -- of cost, reserve from dpis to the period
   --

   if (p_reclass_src_dest is not null) then
      l_sal_thid := t_transaction_header_id(1);
      l_limit_thid := t_transaction_header_id(1);

      fa_amort_pvt.tmd_period_counter(1) := t_period_counter(1);

      x_td_cost(1) := fa_amort_pvt.tmd_cost(1);
      t_cost(1) := fa_amort_pvt.tmd_cost(1);
      fa_amort_pvt.tm_cost(1) := fa_amort_pvt.tmd_cost(1);
      x_td_cip_cost(1) := fa_amort_pvt.tmd_cip_cost(1);
      t_cip_cost(1) := fa_amort_pvt.tmd_cip_cost(1);
      fa_amort_pvt.tm_cip_cost(1) := fa_amort_pvt.tmd_cip_cost(1);

--tk_util.debug('fa_amort_pvt.tmd_period_counter(1): '||to_char(fa_amort_pvt.tmd_period_counter(1)));
--tk_util.debug('fa_amort_pvt.tmd_cost(1): '||to_char(fa_amort_pvt.tmd_cost(1)));
--tk_util.debug('fa_amort_pvt.tmd_cip_cost(1): '||to_char(fa_amort_pvt.tmd_cip_cost(1)));
--tk_util.debug('fa_amort_pvt.tmd_salvage_value(1): '||to_char(fa_amort_pvt.tmd_salvage_value(1)));

      if (t_salvage_type(1) = 'PCT') then
         l_temp_num := t_cost(1) * t_percent_salvage_value(1);
         fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         x_td_salvage_value(1) := l_temp_num;
         t_salvage_value(1) := l_temp_num;
         fa_amort_pvt.tmd_salvage_value(1) := l_temp_num;
         fa_amort_pvt.tm_salvage_value(1) := l_temp_num;
      else
         x_td_salvage_value(1) := fa_amort_pvt.tmd_salvage_value(1);
         t_salvage_value(1) := fa_amort_pvt.tmd_salvage_value(1);
         fa_amort_pvt.tmd_salvage_value(1) := fa_amort_pvt.tmd_salvage_value(1);
         fa_amort_pvt.tm_salvage_value(1) := fa_amort_pvt.tmd_salvage_value(1);
      end if;
--tk_util.debug('x_td_salvage_value(1): '||to_char(x_td_salvage_value(1)));

      if (t_deprn_limit_type(1) = 'PCT') then
         l_temp_num := t_cost(1) * (1 - t_allowed_deprn_limit(1));
         fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         x_td_deprn_limit_amount(1) := l_temp_num;
         t_deprn_limit_amount(1) := l_temp_num;
         fa_amort_pvt.tmd_deprn_limit_amount(1) := l_temp_num;
         fa_amort_pvt.tm_deprn_limit_amount(1) := l_temp_num;
      elsif (t_deprn_limit_type(1) = 'NONE') then
         x_td_deprn_limit_amount(1) := x_td_salvage_value(1);
         t_deprn_limit_amount(1) := x_td_salvage_value(1);
         fa_amort_pvt.tmd_deprn_limit_amount(1) := x_td_salvage_value(1);
         fa_amort_pvt.tm_deprn_limit_amount(1) := x_td_salvage_value(1);
      else
         x_td_deprn_limit_amount(1) := fa_amort_pvt.tmd_deprn_limit_amount(1);
         t_deprn_limit_amount(1) := fa_amort_pvt.tmd_deprn_limit_amount(1);
         fa_amort_pvt.tmd_deprn_limit_amount(1) := fa_amort_pvt.tmd_deprn_limit_amount(1);
         fa_amort_pvt.tm_deprn_limit_amount(1) := fa_amort_pvt.tmd_deprn_limit_amount(1);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'()+', 'Finish Populating First Record',
                          x_td_cost(1));
      end if;

      FOR i in 2..t_period_counter.COUNT LOOP

         fa_amort_pvt.tmd_period_counter(i) := t_period_counter(i);
         x_td_cost(i) := fa_amort_pvt.tmd_cost(i);
         t_cost(i) := fa_amort_pvt.tmd_cost(i) + t_cost(i - 1);
         fa_amort_pvt.tm_cost(i) := fa_amort_pvt.tmd_cost(i) + t_cost(i - 1);
         x_td_cip_cost(i) := fa_amort_pvt.tmd_cip_cost(i);
         t_cip_cost(i) := fa_amort_pvt.tmd_cip_cost(i) + t_cip_cost(i - 1);
         fa_amort_pvt.tm_cip_cost(i) := fa_amort_pvt.tmd_cip_cost(i) + t_cip_cost(i - 1);
--tk_util.debug('fa_amort_pvt.tmd_period_counter(i): '||to_char(fa_amort_pvt.tmd_period_counter(i)));
--tk_util.debug('fa_amort_pvt.tm_cost(i): '||to_char(fa_amort_pvt.tm_cost(i)));
--tk_util.debug('fa_amort_pvt.tmd_cost(i): '||to_char(fa_amort_pvt.tmd_cost(i)));
--tk_util.debug('x_td_cost(i): '||to_char(x_td_cost(i)));
--tk_util.debug('fa_amort_pvt.tmd_cip_cost(i): '||to_char(fa_amort_pvt.tmd_cip_cost(i)));
--tk_util.debug('fa_amort_pvt.tmd_salvage_value(i): '||to_char(fa_amort_pvt.tmd_salvage_value(i)));

         if (t_sal_thid(i) = 0) or
            (l_sal_thid >= t_sal_thid(i)) then
            t_salvage_type(i) := t_salvage_type(i - 1);
            t_percent_salvage_value(i) := t_percent_salvage_value(i - 1);
         end if;

         if (t_limit_thid(i) = 0) or
            (l_limit_thid >= t_limit_thid(i)) then
            t_deprn_limit_type(i) := t_deprn_limit_type(i - 1);
            t_allowed_deprn_limit(i) := t_allowed_deprn_limit(i - 1);
         end if;

         if (t_salvage_type(i) = 'PCT') then
            l_temp_num := t_cost(i) * t_percent_salvage_value(i);
            fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            x_td_salvage_value(i) := l_temp_num;
            t_salvage_value(i) := l_temp_num - x_td_salvage_value(i - 1);
            fa_amort_pvt.tmd_salvage_value(i) := l_temp_num - fa_amort_pvt.tm_salvage_value(i - 1);
            fa_amort_pvt.tm_salvage_value(i) := l_temp_num;
         else
            x_td_salvage_value(i) :=  fa_amort_pvt.tmd_salvage_value(i) +
                                      x_td_salvage_value(i - 1);
            t_salvage_value(i) := fa_amort_pvt.tmd_salvage_value(i);
            fa_amort_pvt.tm_salvage_value(i) := fa_amort_pvt.tmd_salvage_value(i) +
                                                 t_salvage_value(i - 1);
         end if;
--tk_util.debug('x_td_salvage_value(i): '||to_char(x_td_salvage_value(i)));

         if (t_deprn_limit_type(i) = 'PCT') then
            l_temp_num := t_cost(i) * (1 - t_allowed_deprn_limit(i));
            fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            t_deprn_limit_amount(i) := l_temp_num;
            x_td_deprn_limit_amount(i) := l_temp_num - t_deprn_limit_amount(i - 1);
            fa_amort_pvt.tmd_deprn_limit_amount(i) := l_temp_num -
                                                       fa_amort_pvt.tm_deprn_limit_amount(i - 1);
            fa_amort_pvt.tm_deprn_limit_amount(i) := l_temp_num;
         elsif (t_deprn_limit_type(i) = 'NONE') then
            t_deprn_limit_amount(i) :=  x_td_salvage_value(i);
            x_td_deprn_limit_amount(i) := t_salvage_value(i) - t_deprn_limit_amount(i - 1);
            fa_amort_pvt.tmd_deprn_limit_amount(i) := fa_amort_pvt.tm_salvage_value(i) -
                                                       fa_amort_pvt.tm_deprn_limit_amount(i - 1);
            fa_amort_pvt.tm_deprn_limit_amount(i) := x_td_salvage_value(i);
         else
            t_deprn_limit_amount(i) := fa_amort_pvt.tmd_deprn_limit_amount(i);
            x_td_deprn_limit_amount(i) := fa_amort_pvt.tmd_deprn_limit_amount(i) +
                                       x_td_deprn_limit_amount(i - 1);
            fa_amort_pvt.tm_deprn_limit_amount(i) := fa_amort_pvt.tmd_deprn_limit_amount(i) +
                                                      x_td_deprn_limit_amount(i - 1);
         end if;
  --tk_util.debug('bottom of loop');
      END LOOP; -- i in 2..t_period_counter.COUNT
--tk_util.debug('End Loop');

      l_ind := p_period_rec.period_counter - t_period_counter(1) + 1;
--tk_util.debug('l_ind: '||to_char(l_ind));

      x_asset_fin_rec_reclass.cost := t_cost(l_ind);
      x_asset_fin_rec_reclass.cip_cost := t_cip_cost(l_ind);
      x_asset_fin_rec_reclass.salvage_value := x_td_salvage_value(l_ind);
      x_asset_fin_rec_reclass.allowed_deprn_limit_amount := x_td_deprn_limit_amount(l_ind);

   else

      --
      -- Prepare delta for non-group reclass adjustments
      --

      l_sal_thid := t_transaction_header_id(1);
      l_limit_thid := t_transaction_header_id(1);
      t_cost(1) := fa_amort_pvt.tmd_cost(1);
      t_cip_cost(1) := fa_amort_pvt.tmd_cip_cost(1);

      if (t_salvage_type(1) = 'PCT') then
         l_temp_num := t_cost(1) * t_percent_salvage_value(1);
         fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         t_salvage_value(1) := l_temp_num;
      else
         t_salvage_value(1) := fa_amort_pvt.tmd_salvage_value(1);
      end if;

--tk_util.debug('t_percent_salvage_value(1): '||to_char(t_percent_salvage_value(1)));
--tk_util.debug('t_salvage_value(1): '||to_char(t_salvage_value(1)));

      if (t_deprn_limit_type(1) = 'PCT') then
         l_temp_num := t_cost(1) * (1 - t_allowed_deprn_limit(1));
         fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         t_deprn_limit_amount(1) := l_temp_num;
      elsif (t_deprn_limit_type(1) = 'NONE') then
         t_deprn_limit_amount(1) := t_salvage_value(1);
      else
         t_deprn_limit_amount(1) := fa_amort_pvt.tmd_deprn_limit_amount(1);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'()+', 'Finish Populating First Record',
                          t_cost(1));
      end if;

      FOR i in 2..t_period_counter.COUNT LOOP

         t_cost(i) := fa_amort_pvt.tmd_cost(i) + t_cost(i - 1);
         t_cip_cost(i) := fa_amort_pvt.tmd_cip_cost(i) + t_cip_cost(i - 1);

            if (t_sal_thid(i) = 0) or
               (l_sal_thid >= t_sal_thid(i)) then
               t_salvage_type(i) := t_salvage_type(i - 1);
               t_percent_salvage_value(i) := t_percent_salvage_value(i - 1);
            end if;

            if (t_limit_thid(i) = 0) or
               (l_limit_thid >= t_limit_thid(i)) then
               t_deprn_limit_type(i) := t_deprn_limit_type(i - 1);
               t_allowed_deprn_limit(i) := t_allowed_deprn_limit(i - 1);
            end if;

         if (t_salvage_type(i) = 'PCT') then
            l_temp_num := t_cost(i) * t_percent_salvage_value(i);
            fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            t_salvage_value(i) := l_temp_num;
         else
            t_salvage_value(i) := fa_amort_pvt.tmd_salvage_value(i) +
                                                 t_salvage_value(i - 1);
         end if;
--tk_util.debug('t_percent_salvage_value('||to_char(i)||'): '||to_char(t_percent_salvage_value(i)));
--tk_util.debug('t_salvage_value('||to_char(i)||'): '||to_char(t_salvage_value(i)));

         if (t_deprn_limit_type(i) = 'PCT') then
            l_temp_num := t_cost(i) * (1 - t_allowed_deprn_limit(i));
            fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            t_deprn_limit_amount(i) := l_temp_num;
         elsif (t_deprn_limit_type(i) = 'NONE') then
            t_deprn_limit_amount(i) := t_salvage_value(i);
         else
            t_deprn_limit_amount(i) := fa_amort_pvt.tmd_deprn_limit_amount(i) +
                                                      t_deprn_limit_amount(i - 1);
         end if;

      END LOOP; -- i in 2..t_period_counter.COUNT

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'()+', 'Finish Populating All Records',
                          t_cost(t_period_counter.COUNT));
      end if;

      /* Added if condition for bug 7511470 */
      if p_trans_rec.transaction_key = 'MS' then
        l_ind := l_cur_trx_period_counter - t_period_counter(1) + 1;
      else
        l_ind := p_period_rec.period_counter - t_period_counter(1) + 1;
      end if;

--tk_util.debug('x_td_cost(1): '||to_char(x_asset_fin_rec.cost));
--tk_util.debug('l_ind: '||to_char(l_ind));

      --
      -- Now Construct delta table to be applied against group table
      --
      -- Bug4958977: Replacing with following if statement.
      -- Original lines are executed if first condition is met

      x_td_period_counter(1) := t_period_counter(l_ind);
      if (l_cur_trx_period_counter = x_td_period_counter(1)) then
         x_td_cost(1) := x_asset_fin_rec.cost;
         x_td_cip_cost(1) := x_asset_fin_rec.cip_cost;
      elsif (l_period_counter = x_td_period_counter(1)) then
         x_td_cost(1)               := (-1 * l_asset_fin_rec.cost);
         x_td_cip_cost(1)           := (-1 * l_asset_fin_rec.cip_cost);
      else
         x_td_cost(1) := 0;
         x_td_cip_cost(1) := 0;
      end if;

      -- Bug4958977: Use x_td_xxxx instead of x_asset_fin_rec
      t_cost(l_ind) := t_cost(l_ind) + x_td_cost(1);
      t_cip_cost(l_ind) := t_cip_cost(l_ind) + x_td_cip_cost(1);

--tk_util.debug('x_td_period_counter(1): '||                              to_char(x_td_period_counter(1)));
--tk_util.debug('x_td_cost(1): '||                                        to_char(x_td_cost(1)));
--tk_util.debug('t_cost('||to_char(l_ind)||'): '||                        to_char(t_cost(l_ind)));
--tk_util.debug('t_salvage_type('||to_char(l_ind)||'): '||                t_salvage_type(l_ind));
--tk_util.debug('x_asset_fin_rec.percent_salvage_value: '||               to_char(x_asset_fin_rec.percent_salvage_value));
--tk_util.debug('fa_amort_pvt.tmd_salvage_value('||to_char(l_ind)||'): '||to_char(fa_amort_pvt.tmd_salvage_value(l_ind)));
--tk_util.debug('t_salvage_value('||to_char(l_ind)||'): '||               to_char(t_salvage_value(l_ind)));

      if (t_salvage_type(l_ind) = 'PCT') then
--         l_temp_num := t_cost(l_ind) * t_percent_salvage_value(l_ind);
         l_temp_num := t_cost(l_ind) * x_asset_fin_rec.percent_salvage_value;
         fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);

         x_td_salvage_value(1) := l_temp_num - t_salvage_value(l_ind);
         t_salvage_value(l_ind) := l_temp_num;
      else
         x_td_salvage_value(1) := x_asset_fin_rec.salvage_value;
         t_salvage_value(l_ind) :=  t_salvage_value(l_ind) + x_asset_fin_rec.salvage_value;
      end if;

      if (t_deprn_limit_type(l_ind) = 'PCT') then
--         l_temp_num := t_cost(l_ind) * (1 - t_allowed_deprn_limit(l_ind));
         l_temp_num := t_cost(l_ind) * (1 - x_asset_fin_rec.allowed_deprn_limit);
         fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         x_td_deprn_limit_amount(1) := l_temp_num - t_deprn_limit_amount(l_ind);

         t_deprn_limit_amount(l_ind) := l_temp_num;
      else
         x_td_deprn_limit_amount(1) := x_asset_fin_rec.allowed_deprn_limit_amount;
         t_deprn_limit_amount(l_ind) := t_deprn_limit_amount(l_ind) +
                                        x_asset_fin_rec.allowed_deprn_limit_amount;
      end if;
--tk_util.debug('x_td_salvage_value(1): '||to_char(x_td_salvage_value(1)));
--tk_util.debug('x_td_deprn_limit_amount(1): '||to_char(x_td_deprn_limit_amount(1)));


      FOR i in 2..(t_period_counter.LAST - l_ind + 1)  LOOP
         l_ind := l_ind + 1;


         --Bug4958977: Conditionally populate x_td_cost(cip_cost) instead of populating
         -- 0 all the time.  Modified until next debug statement
         x_td_period_counter(i) := t_period_counter(l_ind);

         if (l_cur_trx_period_counter = x_td_period_counter(i)) then
            x_td_cost(i)      := x_asset_fin_rec.cost;
            x_td_cip_cost(i)  := x_asset_fin_rec.cip_cost;
            t_cost(l_ind) := t_cost(l_ind) + x_td_cost(i);
            t_cip_cost(l_ind) := t_cip_cost(l_ind) + x_td_cip_cost(i);
         elsif (l_period_counter = x_td_period_counter(i)) then
            x_td_cost(i)      := (-1 * l_asset_fin_rec.cost);
            x_td_cip_cost(i)  := (-1 * l_asset_fin_rec.cip_cost);
            t_cost(l_ind) := t_cost(l_ind) + x_td_cost(i);
            t_cip_cost(l_ind) := t_cip_cost(l_ind) + x_td_cip_cost(i);
         else
            x_td_cost(i) := 0;
            x_td_cip_cost(i) := 0;
            /*Bug# 8548876 Modified following assignments*/
            t_cost(l_ind) := t_cost(l_ind) + x_asset_fin_rec.cost;
            t_cip_cost(l_ind) := t_cip_cost(l_ind) + x_asset_fin_rec.cip_cost;
         end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'i', i, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'x_td_period_counter(i)', x_td_period_counter(i));
           fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.tmd_salvage_value',
                            fa_amort_pvt.tmd_salvage_value(l_ind));
           fa_debug_pkg.add(l_calling_fn, 't_salvage_type(l_ind)', t_salvage_type(l_ind));
           fa_debug_pkg.add(l_calling_fn, 't_salvage_value', t_salvage_value(l_ind));
        end if;


         if (t_salvage_type(l_ind) = 'PCT') then
            l_temp_num := t_cost(l_ind) * x_asset_fin_rec.percent_salvage_value;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_temp_num', l_temp_num, p_log_level_rec => p_log_level_rec);
            end if;

            fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);

            x_td_salvage_value(i) := l_temp_num - t_salvage_value(l_ind);

            t_salvage_value(l_ind) := l_temp_num;
         else
            x_td_salvage_value(i) := t_salvage_value(l_ind - 1) - t_salvage_value(l_ind);

            t_salvage_value(i) := t_salvage_value(l_ind) + t_salvage_value(l_ind - 1);
         end if;
--tk_util.debug('x_td_salvage_value('||to_char(i)||'): '||to_char(x_td_salvage_value(i)));

         if (t_deprn_limit_type(i) = 'PCT') then
--            l_temp_num := t_cost(l_ind) * (1 - t_allowed_deprn_limit(l_ind));
            l_temp_num := t_cost(l_ind) * (1 - x_asset_fin_rec.allowed_deprn_limit);
            fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);

            x_td_deprn_limit_amount(i) := l_temp_num - t_deprn_limit_amount(l_ind);

            t_deprn_limit_amount(l_ind) := l_temp_num;
         else
            x_td_deprn_limit_amount(i) := t_deprn_limit_amount(l_ind - 1) -
                                          t_deprn_limit_amount(l_ind);

            t_deprn_limit_amount(l_ind) := t_deprn_limit_amount(l_ind) +
                                           t_deprn_limit_amount(l_ind - 1);
         end if;

      END LOOP; -- i in 2..t_cost.COUNT

   end if; -- (p_reclass_src_dest is null)

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()-', '# of rows in delta tables', x_td_cost.COUNT);
   end if;

   return TRUE;

EXCEPTION
   WHEN bld_err THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'bld_err', p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   WHEN OTHERS THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'(OTHERS)-', 'sqlcode', sqlcode);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END buildMemberTable;

--+==============================================================================
-- Function: CurrentPeriodAdj
--
--
--
--
--
--+==============================================================================
FUNCTION CurrentPeriodAdj(
    p_trans_rec                         FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec                     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec                    FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old                 FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj                 FA_API_TYPES.asset_fin_rec_type default null,
    px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_period_rec                        FA_API_TYPES.period_rec_type,
    p_asset_deprn_rec_adj               FA_API_TYPES.asset_deprn_rec_type default null,
    p_proceeds_of_sale                  NUMBER default 0,
    p_cost_of_removal                   NUMBER default 0,
    p_calling_fn                        VARCHAR2,
    p_mrc_sob_type_code                 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return BOOLEAN is

  l_calling_fn  VARCHAR2(50) := 'FA_AMORT_PVT.CurrentPeriodAdj';

  CURSOR c_get_deltas IS
    select inbk.salvage_value - nvl(outbk.salvage_value, 0)
         , nvl(inbk.allowed_deprn_limit_amount, 0) -
               nvl(outbk.allowed_deprn_limit_amount, 0)
    from   fa_books inbk,
           fa_books outbk
    where  outbk.asset_id(+) = inbk.asset_id
    and    outbk.book_type_code(+) = inbk.book_type_code
    and    inbk.transaction_header_id_in = p_trans_rec.member_transaction_header_id
    and    outbk.transaction_header_id_out(+) = inbk.transaction_header_id_in;

  CURSOR c_get_mc_deltas IS
    select inbk.salvage_value - nvl(outbk.salvage_value, 0)
         , nvl(inbk.allowed_deprn_limit_amount, 0) -
               nvl(outbk.allowed_deprn_limit_amount, 0)
    from   fa_mc_books inbk,
           fa_mc_books outbk
    where  outbk.asset_id(+) = inbk.asset_id
    and    outbk.book_type_code(+) = inbk.book_type_code
    and    inbk.transaction_header_id_in = p_trans_rec.member_transaction_header_id
    and    outbk.transaction_header_id_out(+) = inbk.transaction_header_id_in
    and    inbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
    and    outbk.set_of_books_id(+) = p_asset_hdr_rec.set_of_books_id; --Bug 9099329

  --
  -- Cursor to get retirement information using retirement
  -- transaction_header_id
  --
  CURSOR c_get_ret_info (c_transaction_header_id number) IS
    select ret.proceeds_of_sale
         , ret.cost_of_removal
         , -1 * nvl(ret.reserve_retired, 0)
         , -1 * nbv_retired
    from   fa_retirements ret
    where  ret.transaction_header_id_in = c_transaction_header_id
    and    ret.transaction_header_id_out is null;

  CURSOR c_get_mc_ret_info (c_transaction_header_id number) IS
    select ret.proceeds_of_sale
         , ret.cost_of_removal
         , -1 * nvl(ret.reserve_retired, 0)
         , -1 * nbv_retired
    from   fa_mc_retirements ret
    where  ret.transaction_header_id_in = c_transaction_header_id
    and    ret.transaction_header_id_out is null
    and    ret.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

  --
  -- Cursor to get retirement information using reinsatement
  -- transaction_header_id
  --
  CURSOR c_get_rein_info (c_transaction_header_id number) IS
    select -1 * ret.proceeds_of_sale
         , -1 * ret.cost_of_removal
         ,  nvl(ret.reserve_retired, 0)
         ,  nbv_retired
    from   fa_retirements ret
         , fa_transaction_headers mth
    where  mth.transaction_header_id = c_transaction_header_id
    and    mth.asset_id = ret.asset_id
    and    mth.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out = c_transaction_header_id;

  CURSOR c_get_mc_rein_info (c_transaction_header_id number) IS
    select -1 * ret.proceeds_of_sale
         , -1 * ret.cost_of_removal
         ,  nvl(ret.reserve_retired, 0)
         ,  nbv_retired
    from   fa_mc_retirements ret
         , fa_transaction_headers mth
    where  mth.transaction_header_id = c_transaction_header_id
    and    mth.asset_id = ret.asset_id
    and    mth.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out = c_transaction_header_id
    and    ret.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   CURSOR c_check_record_exists IS
      select bs.period_counter
      from   fa_books_summary bs
      where  bs.asset_id = p_asset_hdr_rec.asset_id
      and    bs.book_type_code = p_asset_hdr_rec.book_type_code
      and    bs.period_counter = p_period_rec.period_counter;

   CURSOR c_check_mc_record_exists IS
      select bs.period_counter
      from   fa_mc_books_summary bs
      where  bs.asset_id = p_asset_hdr_rec.asset_id
      and    bs.book_type_code = p_asset_hdr_rec.book_type_code
      and    bs.period_counter = p_period_rec.period_counter
      and    bs.set_of_books_id = p_asset_hdr_rec.set_of_books_id ;


  l_asset_id                      NUMBER(15);
  l_delta_salvage_value           NUMBER;
  l_delta_deprn_limit_amount      NUMBER;
  l_expense_amount                NUMBER;
  l_reserve_amount                NUMBER;
  l_unplanned_amount              NUMBER := 0;

  l_proceeds_of_sale              NUMBER;
  l_cost_of_removal               NUMBER;
  l_reserve_retired               NUMBER;
  l_nbv_retired                   NUMBER;

  l_depreciate_flag_change        BOOLEAN := FALSE;
  l_disabled_flag_change          BOOLEAN := FALSE;

   l_temp_num                     NUMBER; -- temporary numbers for calculation
   l_valid_type_change            BOOLEAN := TRUE;

  adj_err    EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()+', 'asset type', p_asset_type_rec.asset_type);
      fa_debug_pkg.add(l_calling_fn, 'member trx id',
                       p_trans_rec.member_transaction_header_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'trx key',
                       p_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
   end if;

   -- Bug5149789: checking whether member exists or not
   -- Call function check_member_existence if either of
   -- salvage or deprn limit type is being changed and there is 0 group cost
   if (((px_asset_fin_rec_new.salvage_type = 'SUM') and
        (px_asset_fin_rec_new.salvage_type <> nvl(p_asset_fin_rec_old.salvage_type,
                                                  px_asset_fin_rec_new.salvage_type))) or
       ((px_asset_fin_rec_new.deprn_limit_type = 'SUM') and
        (px_asset_fin_rec_new.deprn_limit_type <> nvl(p_asset_fin_rec_old.deprn_limit_type,
                                                      px_asset_fin_rec_new.deprn_limit_type)))) then

      if (px_asset_fin_rec_new.cost = 0) then

         if not check_member_existence (p_asset_hdr_rec => p_asset_hdr_rec,
                                        p_log_level_rec => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling check_member_existence', 'FAILED', p_log_level_rec => p_log_level_rec);
            end if;

            l_valid_type_change := FALSE;

         end if;

      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Method.deprn_limit type change', 'FAILED', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'cost', px_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
         end if;

         l_valid_type_change := FALSE;

      end if;

      if (not l_valid_type_change) then
         if (px_asset_fin_rec_new.salvage_type = 'SUM') then
            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec_new.salvage_type,
               token2     => 'PARAM',
               value2     => 'SALVAGE_TYPE', p_log_level_rec => p_log_level_rec);

         else
            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec_new.deprn_limit_type,
               token2     => 'PARAM',
               value2     => 'DEPRN_LIMIT_TYPE', p_log_level_rec => p_log_level_rec);
         end if;

         return false;
      end if;

   end if; -- (((px_asset_fin_rec_new.salvage_type = 'SUM') and

   /*Bug#8205561 - To populate fa_books_summary in case of dpis change*/
 	if (p_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
 	    p_trans_rec.transaction_key = 'GJ' and
 	    p_asset_fin_rec_old.date_placed_in_service <> px_asset_fin_rec_new.date_placed_in_service) then
 	    -- Group adjustment in period of group addition before
 	    -- depreciation run or first member addition
 	    if not createGroup(
 	                       p_trans_rec            => p_trans_rec,
 	                       p_asset_hdr_rec        => p_asset_hdr_rec,
 	                       p_asset_type_rec       => p_asset_type_rec,
 	                       p_period_rec           => p_period_rec,
 	                       p_asset_fin_rec        => px_asset_fin_rec_new,
 	                       p_asset_deprn_rec      => p_asset_deprn_rec_adj,
 	                       p_mrc_sob_type_code    => p_mrc_sob_type_code,
 	                       p_calling_fn           => l_calling_fn
 	                      ,p_log_level_rec => p_log_level_rec) then

 	       if (p_log_level_rec.statement_level) then
 	          fa_debug_pkg.add(l_calling_fn, 'calling FA_AMORT_PVT.createGroup', 'FAILED'
 	                         ,p_log_level_rec => p_log_level_rec);
 	       end if;
 	       raise adj_err;
 	    end if;
 	end if;
   /*Bug#8205561 end */

   if (p_asset_fin_rec_old.depreciate_flag = 'NO') or
      (nvl(p_asset_fin_rec_old.disabled_flag, 'N') = 'Y') then

      l_depreciate_flag_change := (p_asset_fin_rec_old.depreciate_flag <>
                                   px_asset_fin_rec_new.depreciate_flag);

      l_disabled_flag_change := (nvl(p_asset_fin_rec_old.disabled_flag, 'N') <>
                                 nvl(px_asset_fin_rec_new.disabled_flag, 'N'));

      if (not catchupBooksSummary (
                       p_trans_rec              => p_trans_rec,
                       p_asset_hdr_rec          => p_asset_hdr_rec,
                       p_period_rec             => p_period_rec,
                       p_asset_fin_rec_new      => px_asset_fin_rec_new,
                       p_depreciate_flag_change => l_depreciate_flag_change,
                       p_disabled_flag_change   => l_disabled_flag_change,
                       p_mrc_sob_type_code      => p_mrc_sob_type_code,
                       p_calling_fn             => l_calling_fn,
                       p_log_level_rec          => p_log_level_rec)) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'catchupBooksSummary', p_log_level_rec => p_log_level_rec);
         end if;

         raise adj_err;

      end if;
   elsif (p_asset_fin_rec_old.period_counter_fully_reserved is not null) or
         (p_asset_fin_rec_old.period_counter_life_complete is not null) then
      l_temp_num := null;

      if (p_mrc_sob_type_code = 'R') then
         OPEN c_check_mc_record_exists;
         FETCH c_check_mc_record_exists INTO l_temp_num;
         CLOSE c_check_mc_record_exists;
      else
         OPEN c_check_record_exists;
         FETCH c_check_record_exists INTO l_temp_num;
         CLOSE c_check_record_exists;
      end if;

      if l_temp_num is null then
         if (not catchupBooksSummary (
                       p_trans_rec              => p_trans_rec,
                       p_asset_hdr_rec          => p_asset_hdr_rec,
                       p_period_rec             => p_period_rec,
                       p_asset_fin_rec_new      => px_asset_fin_rec_new,
                       p_depreciate_flag_change => l_depreciate_flag_change,
                       p_disabled_flag_change   => l_disabled_flag_change,
                       p_mrc_sob_type_code      => p_mrc_sob_type_code,
                       p_calling_fn             => l_calling_fn,
                       p_log_level_rec          => p_log_level_rec)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling', 'catchupBooksSummary', p_log_level_rec => p_log_level_rec);
            end if;

            raise adj_err;

         end if;
      end if;
   end if;

/*
   --
   -- Unplanned Depreciation
   --
   if (p_trans_rec.transaction_key in ('UA', 'UE')) then
      -- Expecting unplanned amount stored in p_asset_deprn_rec_adj.deprn_amount
      l_expense_amount := p_asset_deprn_rec_adj.deprn_amount;
      l_unplanned_amount := p_asset_deprn_rec_adj.deprn_amount;
   elsif (p_trans_rec.transaction_key in ('GV', 'GR')) then
     l_reserve_amount := p_asset_deprn_rec_adj.deprn_reserve;
   end if;
*/
   l_expense_amount := nvl(p_asset_deprn_rec_adj.deprn_amount, 0);
   l_unplanned_amount := nvl(p_asset_deprn_rec_adj.deprn_amount, 0);
   l_reserve_amount := nvl(p_asset_deprn_rec_adj.deprn_reserve, 0);

--tk_util.debug('p_asset_fin_rec_old.adjusted_capacity: '||to_char(p_asset_fin_rec_old.adjusted_capacity));
--tk_util.debug('p_asset_fin_rec_adj.adjusted_capacity: '||to_char(p_asset_fin_rec_adj.adjusted_capacity));

/*
   if (nvl(px_asset_fin_rec_new.tracking_method, 'NO TRACK') = 'ALLOCATE') and    -- ENERGY
      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and  -- ENERGY
      (fa_cache_pkg.fazccmt_record.rate_source_rule = FA_STD_TYPES.FAD_RSR_PROD) then
      px_asset_fin_rec_new.adjusted_capacity := nvl(px_asset_fin_rec_new.production_capacity, 0) +
                                                nvl(p_asset_fin_rec_adj.adjusted_capacity, 0);
   end if;
*/

   if (p_trans_rec.member_transaction_header_id is null) then

--tk_util.debug('p_asset_fin_rec_adj.cost: '||to_char(p_asset_fin_rec_adj.cost));
--tk_util.debug('p_asset_fin_rec_adj.cip_cost: '||to_char(p_asset_fin_rec_adj.cip_cost));
--tk_util.debug('l_delta_salvage_value: '||to_char(l_delta_salvage_value));
--tk_util.debug('l_delta_deprn_limit_amount: '||to_char(l_delta_deprn_limit_amount));
--tk_util.debug('p_proceeds_of_sale: '||to_char(p_proceeds_of_sale));
--tk_util.debug('p_cost_of_removal: '||to_char(p_cost_of_removal));
--tk_util.debug('l_unplanned_amount: '||to_char(l_unplanned_amount));
--tk_util.debug('l_expense_amount: '||to_char(l_expense_amount));
--tk_util.debug('l_reserve_amount: '||to_char(l_reserve_amount));

      if (p_mrc_sob_type_code = 'R') then

         UPDATE FA_MC_BOOKS_SUMMARY
         SET    RESET_ADJUSTED_COST_FLAG   = 'Y'
              , SALVAGE_TYPE               = px_asset_fin_rec_new.salvage_type
              , PERCENT_SALVAGE_VALUE      = px_asset_fin_rec_new.percent_salvage_value
              , SALVAGE_VALUE              = px_asset_fin_rec_new.salvage_value
              , RECOVERABLE_COST           = px_asset_fin_rec_new.recoverable_cost
              , DEPRN_LIMIT_TYPE           = px_asset_fin_rec_new.deprn_limit_type
              , ALLOWED_DEPRN_LIMIT        = px_asset_fin_rec_new.allowed_deprn_limit
              , ALLOWED_DEPRN_LIMIT_AMOUNT = px_asset_fin_rec_new.allowed_deprn_limit_amount
              , ADJUSTED_RECOVERABLE_COST  = px_asset_fin_rec_new.adjusted_recoverable_cost
              , ADJUSTED_COST              = px_asset_fin_rec_new.adjusted_cost
              , DEPRECIATE_FLAG            = px_asset_fin_rec_new.depreciate_flag
              , DISABLED_FLAG              = px_asset_fin_rec_new.disabled_flag
              , DEPRN_METHOD_CODE          = px_asset_fin_rec_new.deprn_method_code
              , LIFE_IN_MONTHS             = px_asset_fin_rec_new.life_in_months
              , RATE_ADJUSTMENT_FACTOR     = px_asset_fin_rec_new.rate_adjustment_factor
              , ADJUSTED_RATE              = px_asset_fin_rec_new.adjusted_rate
              , BONUS_RULE                 = px_asset_fin_rec_new.bonus_rule
              , ADJUSTED_CAPACITY          = px_asset_fin_rec_new.adjusted_capacity
              , PRODUCTION_CAPACITY        = px_asset_fin_rec_new.production_capacity
              , UNIT_OF_MEASURE            = px_asset_fin_rec_new.unit_of_measure
              , REMAINING_LIFE1            = px_asset_fin_rec_new.remaining_life1
              , REMAINING_LIFE2            = px_asset_fin_rec_new.remaining_life2
              , FORMULA_FACTOR             = px_asset_fin_rec_new.formula_factor
              , CEILING_NAME               = px_asset_fin_rec_new.ceiling_name
              , SHORT_FISCAL_YEAR_FLAG     = px_asset_fin_rec_new.short_fiscal_year_flag
              , SUPER_GROUP_ID             = px_asset_fin_rec_new.super_group_id
              , OVER_DEPRECIATE_OPTION     = px_asset_fin_rec_new.over_depreciate_option
              , DEPRN_AMOUNT               = DEPRN_AMOUNT + l_expense_amount
              , YTD_DEPRN                  = YTD_DEPRN + l_expense_amount
              , DEPRN_RESERVE              = DEPRN_RESERVE + l_expense_amount + l_reserve_amount
              , YTD_PROCEEDS_OF_SALE       = nvl(YTD_PROCEEDS_OF_SALE, 0) + p_proceeds_of_sale
              , LTD_PROCEEDS_OF_SALE       = nvl(LTD_PROCEEDS_OF_SALE, 0) + p_proceeds_of_sale
              , YTD_COST_OF_REMOVAL        = nvl(YTD_COST_OF_REMOVAL, 0) + p_cost_of_removal
              , LTD_COST_OF_REMOVAL        = nvl(LTD_COST_OF_REMOVAL, 0) + p_cost_of_removal
              , UNPLANNED_AMOUNT           = UNPLANNED_AMOUNT + l_unplanned_amount
              , EXPENSE_ADJUSTMENT_AMOUNT  = EXPENSE_ADJUSTMENT_AMOUNT + l_expense_amount
              , RESERVE_ADJUSTMENT_AMOUNT  = RESERVE_ADJUSTMENT_AMOUNT + l_reserve_amount
              , LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date
              , LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by
              , LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    PERIOD_COUNTER = p_period_rec.period_counter
         AND    SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id;

      else

         UPDATE FA_BOOKS_SUMMARY
         SET    RESET_ADJUSTED_COST_FLAG   = 'Y'
              , SALVAGE_TYPE               = px_asset_fin_rec_new.salvage_type
              , PERCENT_SALVAGE_VALUE      = px_asset_fin_rec_new.percent_salvage_value
              , SALVAGE_VALUE              = px_asset_fin_rec_new.salvage_value
              , RECOVERABLE_COST           = px_asset_fin_rec_new.recoverable_cost
              , DEPRN_LIMIT_TYPE           = px_asset_fin_rec_new.deprn_limit_type
              , ALLOWED_DEPRN_LIMIT        = px_asset_fin_rec_new.allowed_deprn_limit
              , ALLOWED_DEPRN_LIMIT_AMOUNT = px_asset_fin_rec_new.allowed_deprn_limit_amount
              , ADJUSTED_RECOVERABLE_COST  = px_asset_fin_rec_new.adjusted_recoverable_cost
              , ADJUSTED_COST              = px_asset_fin_rec_new.adjusted_cost
              , DEPRECIATE_FLAG            = px_asset_fin_rec_new.depreciate_flag
              , DISABLED_FLAG              = px_asset_fin_rec_new.disabled_flag
              , DEPRN_METHOD_CODE          = px_asset_fin_rec_new.deprn_method_code
              , LIFE_IN_MONTHS             = px_asset_fin_rec_new.life_in_months
              , RATE_ADJUSTMENT_FACTOR     = px_asset_fin_rec_new.rate_adjustment_factor
              , ADJUSTED_RATE              = px_asset_fin_rec_new.adjusted_rate
              , BONUS_RULE                 = px_asset_fin_rec_new.bonus_rule
              , ADJUSTED_CAPACITY          = px_asset_fin_rec_new.adjusted_capacity
              , PRODUCTION_CAPACITY        = px_asset_fin_rec_new.production_capacity
              , UNIT_OF_MEASURE            = px_asset_fin_rec_new.unit_of_measure
              , REMAINING_LIFE1            = px_asset_fin_rec_new.remaining_life1
              , REMAINING_LIFE2            = px_asset_fin_rec_new.remaining_life2
              , FORMULA_FACTOR             = px_asset_fin_rec_new.formula_factor
              , CEILING_NAME               = px_asset_fin_rec_new.ceiling_name
              , SHORT_FISCAL_YEAR_FLAG     = px_asset_fin_rec_new.short_fiscal_year_flag
              , SUPER_GROUP_ID             = px_asset_fin_rec_new.super_group_id
              , OVER_DEPRECIATE_OPTION     = px_asset_fin_rec_new.over_depreciate_option
              , DEPRN_AMOUNT               = DEPRN_AMOUNT + l_expense_amount
              , YTD_DEPRN                  = YTD_DEPRN + l_expense_amount
              , DEPRN_RESERVE              = DEPRN_RESERVE + l_expense_amount + l_reserve_amount
              , YTD_PROCEEDS_OF_SALE       = nvl(YTD_PROCEEDS_OF_SALE, 0) + p_proceeds_of_sale
              , LTD_PROCEEDS_OF_SALE       = nvl(LTD_PROCEEDS_OF_SALE, 0) + p_proceeds_of_sale
              , YTD_COST_OF_REMOVAL        = nvl(YTD_COST_OF_REMOVAL, 0) + p_cost_of_removal
              , LTD_COST_OF_REMOVAL        = nvl(LTD_COST_OF_REMOVAL, 0) + p_cost_of_removal
              , UNPLANNED_AMOUNT           = UNPLANNED_AMOUNT + l_unplanned_amount
              , EXPENSE_ADJUSTMENT_AMOUNT  = EXPENSE_ADJUSTMENT_AMOUNT + l_expense_amount
              , RESERVE_ADJUSTMENT_AMOUNT  = RESERVE_ADJUSTMENT_AMOUNT + l_reserve_amount
              , LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date
              , LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by
              , LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    PERIOD_COUNTER = p_period_rec.period_counter;

      end if;

   else

      if (p_mrc_sob_type_code = 'R') then
         OPEN c_get_mc_deltas;
         FETCH c_get_mc_deltas INTO l_delta_salvage_value
                               , l_delta_deprn_limit_amount;
         CLOSE c_get_mc_deltas;
      else
         OPEN c_get_deltas;
         FETCH c_get_deltas INTO l_delta_salvage_value
                               , l_delta_deprn_limit_amount;
         CLOSE c_get_deltas;
      end if;

      --
      -- Get Retirement information
      --
      if (p_trans_rec.transaction_key = 'MR') then
         if (p_mrc_sob_type_code = 'R') then
            OPEN c_get_mc_ret_info(p_trans_rec.member_transaction_header_id);
            FETCH c_get_mc_ret_info INTO l_proceeds_of_sale
                                       , l_cost_of_removal
                                       , l_reserve_retired
                                       , l_nbv_retired;
            CLOSE c_get_mc_ret_info;
         else
            OPEN c_get_ret_info(p_trans_rec.member_transaction_header_id);
            FETCH c_get_ret_info INTO l_proceeds_of_sale
                                    , l_cost_of_removal
                                    , l_reserve_retired
                                    , l_nbv_retired;
            CLOSE c_get_ret_info;
         end if;
      elsif (p_trans_rec.transaction_key = 'MS') then
         if (p_mrc_sob_type_code = 'R') then
            OPEN c_get_mc_rein_info(p_trans_rec.member_transaction_header_id);
            FETCH c_get_mc_rein_info INTO l_proceeds_of_sale
                                        , l_cost_of_removal
                                        , l_reserve_retired
                                        , l_nbv_retired;
            CLOSE c_get_mc_rein_info;
         else
            OPEN c_get_rein_info(p_trans_rec.member_transaction_header_id);
            FETCH c_get_rein_info INTO l_proceeds_of_sale
                                     , l_cost_of_removal
                                     , l_reserve_retired
                                     , l_nbv_retired;
            CLOSE c_get_rein_info;
         end if;

         l_reserve_amount := l_reserve_retired;
      else
         l_proceeds_of_sale := 0;
         l_cost_of_removal  := 0;
         l_reserve_retired  := 0;
         l_nbv_retired      := 0;
      end if;

--tk_util.debug('p_asset_fin_rec_adj.cost: '||to_char(p_asset_fin_rec_adj.cost));
--tk_util.debug('p_asset_fin_rec_adj.cip_cost: '||to_char(p_asset_fin_rec_adj.cip_cost));
--tk_util.debug('l_delta_salvage_value: '||to_char(l_delta_salvage_value));
--tk_util.debug('l_delta_deprn_limit_amount: '||to_char(l_delta_deprn_limit_amount));
--tk_util.debug('p_proceeds_of_sale: '||to_char(l_proceeds_of_sale));
--tk_util.debug('p_cost_of_removal: '||to_char(l_cost_of_removal));
--tk_util.debug('l_unplanned_amount: '||to_char(l_unplanned_amount));
--tk_util.debug('l_expense_amount: '||to_char(l_expense_amount));
--tk_util.debug('l_reserve_amount: '||to_char(l_reserve_amount));

      if (p_mrc_sob_type_code = 'R') then

         UPDATE FA_MC_BOOKS_SUMMARY
         SET RESET_ADJUSTED_COST_FLAG   = 'Y'
           , CHANGE_IN_COST             = CHANGE_IN_COST + nvl(p_asset_fin_rec_adj.cost, 0)
           , CHANGE_IN_CIP_COST         = CHANGE_IN_CIP_COST + nvl(p_asset_fin_rec_adj.cip_cost, 0)
           , COST                       = px_asset_fin_rec_new.cost
           , CIP_COST                   = px_asset_fin_rec_new.cip_cost
           , SALVAGE_VALUE              = px_asset_fin_rec_new.salvage_value
           , MEMBER_SALVAGE_VALUE       = MEMBER_SALVAGE_VALUE + nvl(l_delta_salvage_value, 0)
           , RECOVERABLE_COST           = px_asset_fin_rec_new.recoverable_cost
           , ALLOWED_DEPRN_LIMIT_AMOUNT = px_asset_fin_rec_new.allowed_deprn_limit_amount
           , MEMBER_DEPRN_LIMIT_AMOUNT  = MEMBER_DEPRN_LIMIT_AMOUNT +
                                          nvl(l_delta_deprn_limit_amount,
                                              decode(MEMBER_DEPRN_LIMIT_AMOUNT, NULL, NUll, 0))
           , ADJUSTED_RECOVERABLE_COST  = px_asset_fin_rec_new.adjusted_recoverable_cost
           , ADJUSTED_COST              = px_asset_fin_rec_new.ADJUSTED_COST
           , UNREVALUED_COST            = px_asset_fin_rec_new.UNREVALUED_COST
           , REVAL_AMORTIZATION_BASIS   = px_asset_fin_rec_new.REVAL_AMORTIZATION_BASIS
           , DEPRN_AMOUNT               = DEPRN_AMOUNT + l_expense_amount
           , YTD_DEPRN                  = YTD_DEPRN + l_expense_amount
           , DEPRN_RESERVE              = DEPRN_RESERVE + l_expense_amount + l_reserve_amount
           , YTD_PROCEEDS_OF_SALE       = nvl(YTD_PROCEEDS_OF_SALE, 0) + l_proceeds_of_sale
           , LTD_PROCEEDS_OF_SALE       = nvl(LTD_PROCEEDS_OF_SALE, 0) + l_proceeds_of_sale
           , YTD_COST_OF_REMOVAL        = nvl(YTD_COST_OF_REMOVAL, 0) + l_cost_of_removal
           , LTD_COST_OF_REMOVAL        = nvl(LTD_COST_OF_REMOVAL, 0) + l_cost_of_removal
           , UNPLANNED_AMOUNT           = UNPLANNED_AMOUNT + l_unplanned_amount
           , EXPENSE_ADJUSTMENT_AMOUNT  = EXPENSE_ADJUSTMENT_AMOUNT + l_expense_amount
           , RESERVE_ADJUSTMENT_AMOUNT  = RESERVE_ADJUSTMENT_AMOUNT + l_reserve_amount
           , LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date
           , LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by
           , LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
         WHERE ASSET_ID = p_asset_hdr_rec.asset_id
         AND   BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND   PERIOD_COUNTER = p_period_rec.period_counter
         AND   SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id;

      else

         UPDATE FA_BOOKS_SUMMARY
         SET RESET_ADJUSTED_COST_FLAG   = 'Y'
           , CHANGE_IN_COST             = CHANGE_IN_COST + nvl(p_asset_fin_rec_adj.cost, 0)
           , CHANGE_IN_CIP_COST         = CHANGE_IN_CIP_COST + nvl(p_asset_fin_rec_adj.cip_cost, 0)
           , COST                       = COST + nvl(p_asset_fin_rec_adj.cost, 0)
           , CIP_COST                   = CIP_COST + nvl(p_asset_fin_rec_adj.cip_cost, 0)
           , SALVAGE_VALUE              = px_asset_fin_rec_new.salvage_value
           , MEMBER_SALVAGE_VALUE       = MEMBER_SALVAGE_VALUE + nvl(l_delta_salvage_value, 0)
           , RECOVERABLE_COST           = px_asset_fin_rec_new.recoverable_cost
           , ALLOWED_DEPRN_LIMIT_AMOUNT = px_asset_fin_rec_new.allowed_deprn_limit_amount
           , MEMBER_DEPRN_LIMIT_AMOUNT  = MEMBER_DEPRN_LIMIT_AMOUNT +
                                          nvl(l_delta_deprn_limit_amount,
                                              decode(MEMBER_DEPRN_LIMIT_AMOUNT, NULL, NUll, 0))
           , ADJUSTED_RECOVERABLE_COST  = px_asset_fin_rec_new.adjusted_recoverable_cost
           , ADJUSTED_COST              = px_asset_fin_rec_new.ADJUSTED_COST
           , UNREVALUED_COST            = px_asset_fin_rec_new.UNREVALUED_COST
           , REVAL_AMORTIZATION_BASIS   = px_asset_fin_rec_new.REVAL_AMORTIZATION_BASIS
           , DEPRN_AMOUNT               = DEPRN_AMOUNT + l_expense_amount
           , YTD_DEPRN                  = YTD_DEPRN + l_expense_amount
           , DEPRN_RESERVE              = DEPRN_RESERVE + l_expense_amount + l_reserve_amount
           , YTD_PROCEEDS_OF_SALE       = nvl(YTD_PROCEEDS_OF_SALE, 0) + l_proceeds_of_sale
           , LTD_PROCEEDS_OF_SALE       = nvl(LTD_PROCEEDS_OF_SALE, 0) + l_proceeds_of_sale
           , YTD_COST_OF_REMOVAL        = nvl(YTD_COST_OF_REMOVAL, 0) + l_cost_of_removal
           , LTD_COST_OF_REMOVAL        = nvl(LTD_COST_OF_REMOVAL, 0) + l_cost_of_removal
           , UNPLANNED_AMOUNT           = UNPLANNED_AMOUNT + l_unplanned_amount
           , EXPENSE_ADJUSTMENT_AMOUNT  = EXPENSE_ADJUSTMENT_AMOUNT + l_expense_amount
           , RESERVE_ADJUSTMENT_AMOUNT  = RESERVE_ADJUSTMENT_AMOUNT + l_reserve_amount
           , LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date
           , LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by
           , LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
         WHERE ASSET_ID = p_asset_hdr_rec.asset_id
         AND   BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND   PERIOD_COUNTER = p_period_rec.period_counter;

      end if;

   end if;

   printBooksSummary(p_asset_id       => p_asset_hdr_rec.asset_id,
                     p_book_type_code => p_asset_hdr_rec.book_type_code,
                     p_log_level_rec  => p_log_level_rec);
--                     p_period_counter => p_period_rec.period_counter);

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn||'()-', 'asset id', p_asset_hdr_rec.asset_id);
   end if;

   return TRUE;

EXCEPTION
   WHEN adj_err THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'(adj_err)-', 'sqlcode', sqlcode);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn||'(OTHERS)-', 'sqlcode', sqlcode);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END CurrentPeriodAdj;

--+==============================================================================
-- Function: bsRecalculate
--
--   This function calculate catch-up amounts due to backdated
--   amortization transactions.

--      3.2: Call faxcde to get reserve for adjusted_cost, raf and formula_factor
--      3.3: Call Deprn Basis function to get new adjusted_cost, raf and formula_factor.
--   4: Return catch-up amount.
--+==============================================================================
FUNCTION bsRecalculate(
    p_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec                     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec                    FA_API_TYPES.asset_type_rec_type,
    p_asset_desc_rec                    FA_API_TYPES.asset_desc_rec_type,
    p_asset_fin_rec_old                 FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj                 FA_API_TYPES.asset_fin_rec_type default null,
    p_period_rec                        FA_API_TYPES.period_rec_type,
    px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec                   FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj               FA_API_TYPES.asset_deprn_rec_type default null,
    x_deprn_expense          OUT NOCOPY NUMBER,
    x_bonus_expense          OUT NOCOPY NUMBER,
    x_impairment_expense     OUT NOCOPY NUMBER,
    x_deprn_reserve          OUT NOCOPY NUMBER,
    p_running_mode        IN            NUMBER,
    p_used_by_revaluation IN            NUMBER,
    p_reclassed_asset_id                NUMBER,
    p_reclass_src_dest                  VARCHAR2,
    p_reclassed_asset_dpis              DATE,
    p_update_books_summary              BOOLEAN default FALSE,
    p_mrc_sob_type_code                 VARCHAR2,
    p_calling_fn                        VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

   l_calling_fn                   VARCHAR2(100) := 'FA_AMORT_PVT.bsRecalculate';

   --
   -- This is to get date placed in service using transaction header id
   -- Bug4958977: Needed to modify to use older dpis
   CURSOR c_get_dpis (c_thid number) IS
      select least(inbk.date_placed_in_service, nvl(outbk.date_placed_in_service, inbk.date_placed_in_service))
      from   fa_books inbk
           , fa_books outbk
      where  inbk.transaction_header_id_in = c_thid
      and    outbk.transaction_header_id_out(+) = inbk.transaction_header_id_in
      and    outbk.asset_id(+) = inbk.asset_id
      and    outbk.book_type_code(+) = inbk.book_type_code;


   --
   -- This is to get period counter using FA_BOOKS_SUMMARY table
   --
   CURSOR c_get_books_summary(c_period_counter number) IS
     select
            bs.period_counter
          , bs.fiscal_year
          , bs.period_num
          , bs.calendar_period_open_date
          , bs.calendar_period_close_date
          , bs.reset_adjusted_cost_flag
          , bs.change_in_cost
          , bs.change_in_cip_cost
          , bs.cost
          , bs.cip_cost
          , bs.salvage_type
          , bs.percent_salvage_value
          , bs.salvage_value
          , bs.member_salvage_value
          , bs.recoverable_cost
          , bs.deprn_limit_type
          , bs.allowed_deprn_limit
          , bs.allowed_deprn_limit_amount
          , bs.member_deprn_limit_amount
          , bs.adjusted_recoverable_cost
          , bs.adjusted_cost
          , bs.depreciate_flag
          , bs.date_placed_in_service
          , bs.deprn_method_code
          , bs.life_in_months
          , bs.rate_adjustment_factor
          , bs.adjusted_rate
          , bs.bonus_rule
          , bs.adjusted_capacity
          , bs.production_capacity
          , bs.unit_of_measure
          , bs.remaining_life1
          , bs.remaining_life2
          , bs.formula_factor
          , bs.unrevalued_cost
          , bs.reval_amortization_basis
          , bs.reval_ceiling
          , bs.ceiling_name
          , bs.eofy_adj_cost
          , bs.eofy_formula_factor
          , bs.eofy_reserve
          , bs.eop_adj_cost
          , bs.eop_formula_factor
          , bs.short_fiscal_year_flag
          , bs.group_asset_id
          , bs.super_group_id
          , bs.over_depreciate_option
          , bs.deprn_amount
          , bs.ytd_deprn
          , bs.deprn_reserve
          , bs.bonus_deprn_amount
          , bs.bonus_ytd_deprn
          , bs.bonus_deprn_reserve
          , bs.bonus_rate
          , bs.impairment_amount
          , bs.ytd_impairment
          , bs.impairment_reserve
          , bs.ltd_production
          , bs.ytd_production
          , bs.production
          , bs.reval_amortization
          , bs.reval_deprn_expense
          , bs.reval_reserve
          , bs.ytd_reval_deprn_expense
          , bs.deprn_override_flag
          , bs.system_deprn_amount
          , bs.system_bonus_deprn_amount
          , bs.ytd_proceeds_of_sale
          , bs.ltd_proceeds_of_sale
          , bs.ytd_cost_of_removal
          , bs.ltd_cost_of_removal
          , bs.deprn_adjustment_amount
          , bs.expense_adjustment_amount
          , bs.reserve_adjustment_amount
          , bs.change_in_eofy_reserve
          , 0  impairment_amount
          , 0  ytd_impairment
          , 0  impairment_reserve
     from   fa_books_summary bs
     where  bs.asset_id = p_asset_hdr_rec.asset_id
     and    bs.book_type_code = p_asset_hdr_rec.book_type_code
     and    bs.period_counter >= c_period_counter
     order by bs.period_counter;

   CURSOR c_get_mc_books_summary(c_period_counter number) IS
     select
            bs.period_counter
          , bs.fiscal_year
          , bs.period_num
          , bs.calendar_period_open_date
          , bs.calendar_period_close_date
          , bs.reset_adjusted_cost_flag
          , bs.change_in_cost
          , bs.change_in_cip_cost
          , bs.cost
          , bs.cip_cost
          , bs.salvage_type
          , bs.percent_salvage_value
          , bs.salvage_value
          , bs.member_salvage_value
          , bs.recoverable_cost
          , bs.deprn_limit_type
          , bs.allowed_deprn_limit
          , bs.allowed_deprn_limit_amount
          , bs.member_deprn_limit_amount
          , bs.adjusted_recoverable_cost
          , bs.adjusted_cost
          , bs.depreciate_flag
          , bs.date_placed_in_service
          , bs.deprn_method_code
          , bs.life_in_months
          , bs.rate_adjustment_factor
          , bs.adjusted_rate
          , bs.bonus_rule
          , bs.adjusted_capacity
          , bs.production_capacity
          , bs.unit_of_measure
          , bs.remaining_life1
          , bs.remaining_life2
          , bs.formula_factor
          , bs.unrevalued_cost
          , bs.reval_amortization_basis
          , bs.reval_ceiling
          , bs.ceiling_name
          , bs.eofy_adj_cost
          , bs.eofy_formula_factor
          , bs.eofy_reserve
          , bs.eop_adj_cost
          , bs.eop_formula_factor
          , bs.short_fiscal_year_flag
          , bs.group_asset_id
          , bs.super_group_id
          , bs.over_depreciate_option
          , bs.deprn_amount
          , bs.ytd_deprn
          , bs.deprn_reserve
          , bs.bonus_deprn_amount
          , bs.bonus_ytd_deprn
          , bs.bonus_deprn_reserve
          , bs.bonus_rate
          , bs.impairment_amount
          , bs.ytd_impairment
          , bs.impairment_reserve
          , bs.ltd_production
          , bs.ytd_production
          , bs.production
          , bs.reval_amortization
          , bs.reval_deprn_expense
          , bs.reval_reserve
          , bs.ytd_reval_deprn_expense
          , bs.deprn_override_flag
          , bs.system_deprn_amount
          , bs.system_bonus_deprn_amount
          , bs.ytd_proceeds_of_sale
          , bs.ltd_proceeds_of_sale
          , bs.ytd_cost_of_removal
          , bs.ltd_cost_of_removal
          , deprn_adjustment_amount
          , bs.expense_adjustment_amount
          , bs.reserve_adjustment_amount
          , bs.change_in_eofy_reserve
          , 0  impairment_amount
          , 0  ytd_impairment
          , 0  impairment_reserve
     from   fa_mc_books_summary bs
     where  bs.asset_id = p_asset_hdr_rec.asset_id
     and    bs.book_type_code = p_asset_hdr_rec.book_type_code
     and    bs.period_counter >= c_period_counter
     and    bs.set_of_books_id = p_asset_hdr_rec.set_of_books_id
     order by bs.period_counter;


   CURSOR c_get_eofy_amts(c_period_counter number) IS
     select recoverable_cost
          , salvage_value
          , deprn_reserve
     from   fa_books_summary
     where  asset_id = p_asset_hdr_rec.asset_id
     and    book_type_code = p_asset_hdr_rec.book_type_code
     and    period_counter = c_period_counter;

   CURSOR c_get_mc_eofy_amts(c_period_counter number) IS
     select recoverable_cost
          , salvage_value
          , deprn_reserve
     from   fa_mc_books_summary
     where  asset_id = p_asset_hdr_rec.asset_id
     and    book_type_code = p_asset_hdr_rec.book_type_code
     and    period_counter = c_period_counter
     and    set_of_books_id = p_asset_hdr_rec.set_of_books_id ;

  --
  -- Cursor to get retirement information using reinsatement
  -- transaction_header_id
  --
  CURSOR c_get_rein_info IS
    select -1 * ret.proceeds_of_sale
         , -1 * ret.cost_of_removal
         ,  ret.reserve_retired
         ,  nbv_retired
         ,  ret.recognize_gain_loss -- Added for bug 8425794 / 8244128
         ,  ret.recapture_amount
    from   fa_retirements ret
         , fa_transaction_headers mth
    where  mth.transaction_header_id = p_trans_rec.member_transaction_header_id
    and    mth.asset_id = ret.asset_id
    and    mth.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out = p_trans_rec.member_transaction_header_id;

  CURSOR c_get_mc_rein_info IS
    select -1 * ret.proceeds_of_sale
         , -1 * ret.cost_of_removal
         ,  nvl(ret.reserve_retired, 0)
         ,  nbv_retired
         ,  ret.recognize_gain_loss -- Added for bug 8425794 / 8244128
         ,  ret.recapture_amount
    from   fa_mc_retirements ret
         , fa_transaction_headers mth
    where  mth.transaction_header_id = p_trans_rec.member_transaction_header_id
    and    mth.asset_id = ret.asset_id
    and    mth.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out = p_trans_rec.member_transaction_header_id
    and    ret.set_of_books_id = p_asset_hdr_rec.set_of_books_id ;

   CURSOR c_check_record_exists IS
      select bs.period_counter
      from   fa_books_summary bs
      where  bs.asset_id = p_asset_hdr_rec.asset_id
      and    bs.book_type_code = p_asset_hdr_rec.book_type_code
      and    bs.period_counter = p_period_rec.period_counter;

   CURSOR c_check_mc_record_exists IS
      select bs.period_counter
      from   fa_mc_books_summary bs
      where  bs.asset_id = p_asset_hdr_rec.asset_id
      and    bs.book_type_code = p_asset_hdr_rec.book_type_code
      and    bs.period_counter = p_period_rec.period_counter
      and    bs.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

/* Following cursor is added by HHIRAGA for tracking */
   CURSOR c_get_current_period IS
      select dp.period_counter
        from fa_deprn_periods dp
       where dp.book_type_code = p_asset_hdr_rec.book_type_code
         and dp.period_close_date is null;

   CURSOR c_get_current_period_mrc IS
      select dp.period_counter
        from fa_mc_deprn_periods dp
       where dp.book_type_code = p_asset_hdr_rec.book_type_code
         and dp.period_close_date is null
         and dp.set_of_books_id = p_asset_hdr_rec.set_of_books_id ;


   l_mem_trx                      BOOLEAN := FALSE; -- FALSE if this is group trx
   l_temp_num                     NUMBER; -- temporary numbers for calculation

  l_period_rec                   FA_API_TYPES.period_rec_type;      -- Store period information of
                                                                    -- the period where trx date
                                                                    -- falls into
                                                                    -- the period where trx date
                                                                    -- falls into, then
                                                                    -- store period info for
                                                                    -- each period processed.
  l_trx_period_rec               FA_API_TYPES.period_rec_type;      -- Store period information of
                                                                    -- the period where trx date
                                                                    -- falls into

   l_ind                         BINARY_INTEGER; -- Used to find delta amounts for each period
   l_temp_ind                    BINARY_INTEGER; -- Indicate where to start updating FA_BOOKS_SUMMARY
   l_old_reserve                  NUMBER;

   --
   -- Tables to store member delta information
   --
   td_period_counter              fa_amort_pvt.tab_num15_type;  -- not used
   td_cost                        fa_amort_pvt.tab_num_type;    -- not used
   td_cip_cost                    fa_amort_pvt.tab_num_type;    -- not used
   td_salvage_value               fa_amort_pvt.tab_num_type;
   td_deprn_limit_amount          fa_amort_pvt.tab_num_type;


   l_transaction_date_entered     date; -- This is used as parameter for c_get_books_summary
   l_period_counter               NUMBER(15);

   l_bs_ind                       BINARY_INTEGER := 1;
   d                              BINARY_INTEGER := 0; -- index for delta tables
   e                              BINARY_INTEGER := 0; -- index for delta tables to look for
                                                       -- next period to maintain books summary


   --
   -- Used to populate dpr_in
   --
   l_fiscal_year                  NUMBER(15);
   l_period_num                   NUMBER(15);
   l_adjusted_ind                 BINARY_INTEGER;
   l_count                        BINARY_INTEGER := 0; -- Stores count of tbs tables

  --+++++ Store data related to each transactions +++++
  l_trans_rec                    FA_API_TYPES.trans_rec_type;       -- Not used
  l_asset_deprn_rec              FA_API_TYPES.asset_deprn_rec_type; -- For Deprn Basis
  l_asset_deprn_rec_raf          FA_API_TYPES.asset_deprn_rec_type; -- For Deprn Basis
  l_asset_fin_rec_old            FA_API_TYPES.asset_fin_rec_type;   -- For Deprn Basis
  l_asset_fin_rec_new            FA_API_TYPES.asset_fin_rec_type;

  --+++++ Variables for calling buildMemberTable function +++++
  l_asset_hdr_rec                FA_API_TYPES.asset_hdr_rec_type;  -- Store member info
  t_period_counter               fa_amort_pvt.tab_num15_type;
  t_delta_cost                   fa_amort_pvt.tab_num_type;
  t_delta_cip_cost               fa_amort_pvt.tab_num_type;
  t_delta_salvage_value          fa_amort_pvt.tab_num_type;
  t_delta_deprn_limit_amount     fa_amort_pvt.tab_num_type;
  l_member_dpis                  DATE;
  l_multiplier                   NUMBER := 1;
  l_m_asset_fin_rec_adj          FA_API_TYPES.asset_fin_rec_type; -- member's delta info
  l_asset_fin_rec_reclass        FA_API_TYPES.asset_fin_rec_type; -- correct fin rec adj for
  l_salvage_limit_type           VARCHAR2(30);
                                                                  -- reclass

  --+++++ Variables for CURSOR c_get_rein_info +++++
  l_nbv_retired                  NUMBER := 0;
  l_reserve_retired              NUMBER;
  l_proceeds_of_sale             NUMBER := 0;
  l_cost_of_removal              NUMBER := 0;
  l_recognize_gain_loss          fa_retirements.recognize_gain_loss%type; -- Added for bug 8425794 / 8244128
  l_recapture_amount             NUMBER := 0;


  --+++++++++++++++ For calling faxcde +++++++++++++++
  l_dpr_in                       FA_STD_TYPES.dpr_struct;
  l_dpr_out                      FA_STD_TYPES.dpr_out_struct;
  l_dpr_arr                      FA_STD_TYPES.dpr_arr_type;
  l_running_mode                 NUMBER;

  --
  -- These are used to store return values from faxcde which
  -- may not be used.
  --
  l_out_deprn_exp                NUMBER;
  l_out_reval_exp                NUMBER;
  l_out_reval_amo                NUMBER;
  l_out_prod                     NUMBER;
  l_out_ann_adj_exp              NUMBER;
  l_out_ann_adj_reval_exp        NUMBER;
  l_out_ann_adj_reval_amo        NUMBER;
  l_out_bonus_rate_used          NUMBER;
  l_out_full_rsv_flag            BOOLEAN;
  l_out_life_comp_flag           BOOLEAN;
  l_out_deprn_override_flag      VARCHAR2(1);



  --+++++++ variables for old information +++++++
  l_eofy_rec_cost                NUMBER; -- This needs to be populated from tbs
  l_eofy_sal_val                 NUMBER; -- This needs to be populated from tbs
  l_eop_rec_cost                 NUMBER; -- This needs to be populated from tbs
  l_eop_sal_val                  NUMBER; -- This needs to be populated from tbs
  l_eofy_reserve                 NUMBER;


  --++++++++ variables for manual override ++++++++
  l_rate_source_rule             VARCHAR2(25);
  l_deprn_basis_rule             VARCHAR2(25);

  --++++++++ variables for calling catchupBooksSummary ++++++++
  l_depreciate_flag_change        BOOLEAN := FALSE;
  l_disabled_flag_change          BOOLEAN := FALSE;

  l_gr_asset_deprn_rec            FA_API_TYPES.asset_deprn_rec_type; -- For Reclass
  l_gr_ind                        BINARY_INTEGER;

  --+ HHIRAGA added on Oct/Nov in 2003
  --++++++++ variables for Trackking Member Feature ++++++++
  l_processed_flag               BOOLEAN := FALSE;
  l_backup_processed_flag        BOOLEAN := FALSE;
  l_raf_processed_flag           BOOLEAN := FALSE;
  l_first_process                BOOLEAN := TRUE;
  l_current_period_counter       NUMBER;
  l_mem_period_counter           NUMBER;

  l_mem_deprn_reserve            NUMBER;
  l_mem_eofy_reserve             NUMBER;
  l_mem_loop_first               BOOLEAN := TRUE;

  l_mem_ytd_deprn_addition       NUMBER;
  l_mem_deprn_reserve_addition   NUMBER;

  l_recalc_start_fy              NUMBER;
  l_recalc_start_period_num      NUMBER;
  l_recalc_start_period_counter  NUMBER;
  l_old_recalc_start_fy          NUMBER;
  l_old_recalc_start_period_num  NUMBER;
  l_old_recalc_end_fy            NUMBER;
  l_old_recalc_end_period_num    NUMBER;
  l_no_allocation_for_last       VARCHAR2(1);
  l_chk_bs_row_exists            VARCHAR2(1);

   CURSOR c_chk_bs_row_exists IS
      select 'Y'
        from fa_books_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and group_asset_id = p_asset_hdr_rec.asset_id
         and asset_id <> group_asset_id
         and period_counter = l_recalc_start_period_counter - 1;

   CURSOR c_get_mem_bs_row IS
      select ytd_deprn,deprn_reserve,bonus_ytd_deprn,bonus_deprn_reserve,
             eofy_reserve,ytd_impairment,impairment_reserve
        from fa_books_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and asset_id = p_reclassed_asset_id
         and group_asset_id = p_asset_hdr_rec.asset_id
         and period_counter = l_trx_period_rec.period_counter - 1;

   CURSOR c_get_ytd_deprn IS
      select ytd_deprn,deprn_reserve
        from fa_deprn_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and asset_id = p_reclassed_asset_id
         and period_counter = l_mem_period_counter
         and deprn_source_code = 'BOOKS';

   --+ MRCsupport
   CURSOR c_chk_bs_row_exists_mrc IS
      select 'Y'
        from fa_mc_books_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and group_asset_id = p_asset_hdr_rec.asset_id
         and asset_id <> group_asset_id
         and period_counter = l_recalc_start_period_counter - 1
         and set_of_books_id = p_asset_hdr_rec.set_of_books_id ;

   CURSOR c_get_mem_bs_row_mrc IS
      select ytd_deprn,deprn_reserve,bonus_ytd_deprn,bonus_deprn_reserve,
             eofy_reserve, ytd_impairment, impairment_reserve
        from fa_mc_books_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and asset_id = p_reclassed_asset_id
         and group_asset_id = p_asset_hdr_rec.asset_id
         and period_counter = l_trx_period_rec.period_counter - 1
         and set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   CURSOR c_get_ytd_deprn_mrc IS
      select ytd_deprn,deprn_reserve
        from fa_mc_deprn_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and asset_id = p_reclassed_asset_id
         and period_counter = l_mem_period_counter
         and deprn_source_code = 'BOOKS'
         and set_of_books_id = p_asset_hdr_rec.set_of_books_id;


  --+++++++++++++++++ Exceptions ++++++++++++++++++++++
  invalid_trx_to_overlap         EXCEPTION; --This is currently not used but there is a
                                            --section in exception handling for future use.
  calc_failed                    EXCEPTION;
  l_adj_amt                      number;     ----- bug# 5768759
  /*Bug 8765735 - Start*/
  l_dpr                FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
  l_run_mode           VARCHAR2(20) := 'TRANSACTION';
  l_status             BOOLEAN;
  /*Bug 8765735 - End*/


BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_type_rec.asset_type||
                                              ':'||p_asset_hdr_rec.asset_id , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Reclass values', p_reclass_src_dest||
                                     ':'||to_char(p_reclassed_asset_id)||':'||
                                     to_char(p_reclassed_asset_dpis, 'DD-MON-RR'));
      fa_debug_pkg.add(l_calling_fn, 'Begin BSrec sob_id',
p_asset_hdr_rec.set_of_books_id);


   end if;

   if (p_asset_fin_rec_old.depreciate_flag = 'NO') or
      (nvl(p_asset_fin_rec_old.disabled_flag, 'N') = 'Y') then

      l_depreciate_flag_change := (p_asset_fin_rec_old.depreciate_flag <>
                                   px_asset_fin_rec_new.depreciate_flag);

      l_disabled_flag_change := (nvl(p_asset_fin_rec_old.disabled_flag, 'N') <>
                                 nvl(px_asset_fin_rec_new.disabled_flag, 'N'));

      if (not catchupBooksSummary (
                       p_trans_rec              => p_trans_rec,
                       p_asset_hdr_rec          => p_asset_hdr_rec,
                       p_period_rec             => p_period_rec,
                       p_asset_fin_rec_new      => px_asset_fin_rec_new,
                       p_depreciate_flag_change => l_depreciate_flag_change,
                       p_disabled_flag_change   => l_disabled_flag_change,
                       p_mrc_sob_type_code      => p_mrc_sob_type_code,
                       p_calling_fn             => l_calling_fn,
                       p_log_level_rec          => p_log_level_rec)) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'catchupBooksSummary', p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;

      end if;
   elsif (p_asset_fin_rec_old.period_counter_fully_reserved is not null) or
         (p_asset_fin_rec_old.period_counter_life_complete is not null) then
      l_temp_num := null;

      if (p_mrc_sob_type_code = 'R') then
         OPEN c_check_mc_record_exists;
         FETCH c_check_mc_record_exists INTO l_temp_num;
         CLOSE c_check_mc_record_exists;
      else
         OPEN c_check_record_exists;
         FETCH c_check_record_exists INTO l_temp_num;
         CLOSE c_check_record_exists;
      end if;

      if l_temp_num is null then
         if (not catchupBooksSummary (
                          p_trans_rec              => p_trans_rec,
                          p_asset_hdr_rec          => p_asset_hdr_rec,
                          p_period_rec             => p_period_rec,
                          p_asset_fin_rec_new      => px_asset_fin_rec_new,
                          p_depreciate_flag_change => l_depreciate_flag_change,
                          p_disabled_flag_change   => l_disabled_flag_change,
                          p_mrc_sob_type_code      => p_mrc_sob_type_code,
                          p_calling_fn             => l_calling_fn,
                          p_log_level_rec          => p_log_level_rec)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling', 'catchupBooksSummary', p_log_level_rec => p_log_level_rec);
            end if;

            raise calc_failed;

         end if;
      end if;
   end if;


   --
   -- Initialize global variables
   --
   InitGlobeVariables;

   x_deprn_reserve := 0;

   l_mem_trx := (p_trans_rec.member_transaction_header_id is not null);

   l_transaction_date_entered := nvl(p_trans_rec.amortization_start_date,
                                     p_trans_rec.transaction_date_entered);

   --
   -- Get period information of the period where transaction date falls into.
   --
   if not GetPeriodInfo(to_number(to_char(l_transaction_date_entered, 'J')),
                        p_asset_hdr_rec.book_type_code,
                        p_mrc_sob_type_code,
                        p_asset_hdr_rec.set_of_books_id,
                        l_period_rec,
                        p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Error calling', 'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;

   end if;

   l_trx_period_rec := l_period_rec;

   if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazcct', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;

   end if;

   if (l_mem_trx) then

      --
      -- Find member's date placed in service
      --
      if (p_trans_rec.transaction_key = 'GC') then
         l_member_dpis := p_reclassed_asset_dpis;
      else
         OPEN c_get_dpis(p_trans_rec.member_transaction_header_id);
         FETCH c_get_dpis INTO l_member_dpis;
         CLOSE c_get_dpis;
      end if;

      -- Bug4958977: Adding following entire if statement
      if (p_trans_rec.transaction_key not in ('MR', 'MS', 'GC') and
          nvl(p_asset_fin_rec_adj.cost, 0) = 0 and
          nvl(p_asset_fin_rec_adj.cip_cost, 0) = 0 and
          nvl(p_asset_fin_rec_adj.salvage_value, 0) = 0 and
          nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) = 0) then


         --
         -- Get period information of the period where transaction date falls into.
         --
         if not GetPeriodInfo(to_number(to_char(l_member_dpis, 'J')),
                        p_asset_hdr_rec.book_type_code,
                        p_mrc_sob_type_code,
                        p_asset_hdr_rec.set_of_books_id,
                        l_period_rec,
                        p_log_level_rec) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling', 'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
            end if;

            raise calc_failed;

         end if;

         l_trx_period_rec := l_period_rec;

      end if;

      l_asset_hdr_rec := p_asset_hdr_rec;
      l_asset_hdr_rec.asset_id := p_reclassed_asset_id;

      if (p_reclass_src_dest = 'SOURCE') then
         l_multiplier := -1;
      end if;

      --
      -- bug5141789: Need to pass this new variable to see if
      -- we need to track sum of member salvage value or not.
      --
      if (px_asset_fin_rec_new.salvage_type = 'SUM' or
          px_asset_fin_rec_new.deprn_limit_type = 'SUM') then
         l_salvage_limit_type := 'SUM';
      else
         l_salvage_limit_type := 'PCT';
      end if;

      if not buildMemberTable(
                  p_trans_rec               => p_trans_rec,
                  p_asset_hdr_rec           => l_asset_hdr_rec,
                  p_period_rec              => l_period_rec,
                  p_date_placed_in_service  => l_member_dpis,
                  p_group_asset_id          => p_asset_hdr_rec.asset_id,
                  p_reclass_multiplier      => l_multiplier,
                  p_reclass_src_dest        => p_reclass_src_dest,
                  p_salvage_limit_type      => l_salvage_limit_type,
                  x_td_period_counter       => td_period_counter,
                  x_td_cost                 => td_cost,
                  x_td_cip_cost             => td_cip_cost,
                  x_td_salvage_value        => td_salvage_value,
                  x_td_deprn_limit_amount   => td_deprn_limit_amount,
                  x_asset_fin_rec           => l_m_asset_fin_rec_adj,
                  x_asset_fin_rec_reclass   => l_asset_fin_rec_reclass,
                  p_mrc_sob_type_code       => p_mrc_sob_type_code,
                  p_log_level_rec           => p_log_level_rec) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'buildMemberTable', p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '# of rows in delta talbe', td_cost.COUNT, p_log_level_rec => p_log_level_rec);
      end if;

   else
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Group Transaction', p_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
      end if;
   end if; -- (l_mem_trx)

   -- NOTE:
   -- if reclass NOT from DPIS
   -- then create one record to find cost, sal, etc... as of the date.
   -- for rest of period, apply delta directly.
   -- This means that if reclass from dpis, apply delta directly.
   -- if it is from current, use member's latest info.
   -- if it is from between dpis and current, then build first row
   -- and apply it and then apply rest of records.

   -- HHIRAGA
   -- In case this is DESTINATION, group_asset_id in FA_BOOKS_SUMMARY must be updated before starting to
   -- processing

   if (p_reclass_src_dest = 'DESTINATION') and
      nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'ALLOCATE' then

      -- Bug 6903588: Initialize global variables
      -- similar to what is done in the case of 'SOURCE' below
      if (nvl(p_reclassed_asset_id, 0) <> nvl(g_mem_asset_id, 0)) then
         g_mem_ytd_deprn := 0;
         g_mem_deprn_reserve := 0;
         g_mem_bonus_ytd_deprn := 0;
         g_mem_bonus_deprn_reserve := 0;
         g_mem_ytd_impairment := 0;
         g_mem_impairment_reserve := 0;
         g_mem_eofy_reserve := 0;
      end if;

      begin

        l_mem_period_counter := l_trx_period_rec.period_counter - 1;

        if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Insert new row for proceessing','Start', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'Insert row',
                      l_asset_hdr_rec.book_type_code||':'||p_reclassed_asset_id||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'Insert row',
                      l_mem_period_counter||':'||g_mem_ytd_deprn||':'||g_mem_deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'Insert row',
                      g_mem_bonus_ytd_deprn||':'||g_mem_bonus_deprn_reserve||':'||g_mem_eofy_reserve, p_log_level_rec => p_log_level_rec);
        end if;

        -- Query YTD and Reserve from FA_DEPRN_SUMMARY for addition
        if p_mrc_sob_type_Code <> 'R' then

           update fa_books_summary
           set group_Asset_id = p_asset_hdr_rec.asset_id
           where asset_id=p_reclassed_asset_id
           and period_counter >= l_trx_period_rec.period_counter;

           open c_get_ytd_deprn;
           fetch c_get_ytd_deprn into l_mem_ytd_deprn_addition,l_mem_deprn_reserve_addition;
           close c_get_ytd_deprn;

           if nvl(g_mem_ytd_deprn,0) = 0 and l_mem_ytd_deprn_addition is not null then
              g_mem_ytd_deprn := nvl(l_mem_ytd_deprn_addition,0);
           end if;

           if nvl(g_mem_deprn_reserve,0) = 0 and l_mem_deprn_reserve_addition is not null then
              g_mem_deprn_reserve := nvl(l_mem_deprn_reserve_addition,0);
              g_mem_eofy_reserve := g_mem_deprn_reserve - g_mem_ytd_deprn;
           end if;

           insert into fa_books_summary(book_type_code,
                                        asset_id,
                                        group_asset_id,
                                        period_counter,
                                        cost,
                                        salvage_value,
                                        recoverable_cost,
                                        adjusted_cost,
                                        adjusted_recoverable_cost,
                                        deprn_amount,
                                        ytd_deprn,
                                        deprn_reserve,
                                        bonus_ytd_deprn,
                                        bonus_deprn_reserve,
                                        ytd_impairment,
                                        impairment_reserve,
                                        eofy_reserve,
                                        creation_date,
                                        created_by,
                                        last_update_date,
                                        last_updated_by)
            values (l_asset_hdr_rec.book_type_code,
                    p_reclassed_asset_id,
                    p_asset_hdr_rec.asset_id,
                    l_mem_period_counter,
                    0,0,0,0,0,0,
                    nvl(g_mem_ytd_deprn,0),
                    nvl(g_mem_deprn_reserve,0),
                    nvl(g_mem_bonus_ytd_deprn,0),
                    nvl(g_mem_bonus_deprn_reserve,0),
                    nvl(g_mem_ytd_impairment,0),
                    nvl(g_mem_impairment_reserve,0),
                    nvl(g_mem_eofy_reserve,0),
                    p_trans_rec.who_info.creation_date,
                    p_trans_rec.who_info.created_by,
                    p_trans_rec.who_info.last_update_date,
                    p_trans_rec.who_info.last_updated_by);
        else -- Reporting

           update fa_mc_books_summary
           set group_Asset_id = p_asset_hdr_rec.asset_id
           where asset_id=p_reclassed_asset_id
           and period_counter >= l_trx_period_rec.period_counter
           and set_of_books_id = p_asset_hdr_rec.set_of_books_id;

           open c_get_ytd_deprn_mrc;
           fetch c_get_ytd_deprn_mrc into l_mem_ytd_deprn_addition,l_mem_deprn_reserve_addition;
           close c_get_ytd_deprn_mrc;

           if nvl(g_mem_ytd_deprn,0) = 0 and l_mem_ytd_deprn_addition is not null then
              g_mem_ytd_deprn := nvl(l_mem_ytd_deprn_addition,0);
           end if;

           if nvl(g_mem_deprn_reserve,0) = 0 and l_mem_deprn_reserve_addition is not null then
              g_mem_deprn_reserve := nvl(l_mem_deprn_reserve_addition,0);
              g_mem_eofy_reserve := g_mem_deprn_reserve - g_mem_ytd_deprn;
           end if;

           insert into fa_mc_books_summary(set_of_books_id,
                                              book_type_code,
                                              asset_id,
                                              group_asset_id,
                                              period_counter,
                                              cost,
                                              salvage_value,
                                              recoverable_cost,
                                              adjusted_cost,
                                              adjusted_recoverable_cost,
                                              deprn_amount,
                                              ytd_deprn,
                                              deprn_reserve,
                                              bonus_ytd_deprn,
                                              bonus_deprn_reserve,
                                              ytd_impairment,
                                              impairment_reserve,
                                              eofy_reserve,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by)
           values (l_asset_hdr_rec.set_of_books_id,
                   l_asset_hdr_rec.book_type_code,
                   p_reclassed_asset_id,
                   p_asset_hdr_rec.asset_id,
                   l_mem_period_counter,
                   0,0,0,0,0,0,
                   nvl(g_mem_ytd_deprn,0),
                   nvl(g_mem_deprn_reserve,0),
                   nvl(g_mem_bonus_ytd_deprn,0),
                   nvl(g_mem_bonus_deprn_reserve,0),
                   nvl(g_mem_ytd_impairment,0),
                   nvl(g_mem_impairment_reserve,0),
                   nvl(g_mem_eofy_reserve,0),
                   p_trans_rec.who_info.creation_date,
                   p_trans_rec.who_info.created_by,
                   p_trans_rec.who_info.last_update_date,
                   p_trans_rec.who_info.last_updated_by);

        end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Inserted rows','Without Error', p_log_level_rec => p_log_level_rec);
        end if;

      exception
         when others then
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Insert new row for proceessing','Error', p_log_level_rec => p_log_level_rec);
          end if;
           null;
      end;
   end if;

   if (p_reclass_src_dest = 'SOURCE') then

     --+ HHIRAGA added on Oct/Nov in 2003
     --
     -- If this processing is for Group Asset whose tracking method is
     -- setup and user specified reclassification date (amort date) is
     -- in the current open period, system don't need to recalculate from
     -- DPIS of the member asset to reclassify but jut get stored reserve,
     -- YTD Depreciation and EOFY Reserve from table using populate_member_reserve function
     -- defined in FA_TRACK_MEMBER_PVT.
     --
     -- Initialize global variables
     g_mem_asset_id  := nvl(p_reclassed_asset_id, 0);
     g_mem_ytd_deprn := 0;
     g_mem_deprn_reserve := 0;
     g_mem_bonus_ytd_deprn := 0;
     g_mem_bonus_deprn_reserve := 0;
     g_mem_ytd_impairment := 0;
     g_mem_impairment_reserve := 0;
     g_mem_eofy_reserve := 0;

     -- Query current open period counter
     if p_mrc_sob_type_code <> 'R' then
         open c_get_current_period;
         fetch c_get_current_period into l_current_period_counter;
         close c_get_current_period;

        if nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'ALLOCATE' then
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_trx_period_rec.period_counter', l_trx_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_Asset_hdr_rec.book_type_code', p_Asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_reclassed_asset_id', p_reclassed_asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_asset_hdr_rec.asset_id', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
          end if;
           open c_get_mem_bs_row;
           fetch c_get_mem_bs_row into g_mem_ytd_deprn,g_mem_deprn_reserve,
 	                                    g_mem_bonus_ytd_deprn,g_mem_bonus_deprn_reserve,g_mem_eofy_reserve,
                                       g_mem_ytd_impairment,g_mem_impairment_reserve;

 	        close c_get_mem_bs_row;
           /*Bug 8765735 and 8814747 - Start*/
           if (fa_cache_pkg.fazcdbr_record.rule_name = 'ENERGY PERIOD END BALANCE') then
           l_dpr.asset_id   := p_reclassed_asset_id;
           l_dpr.book       := p_asset_hdr_rec.book_type_code;
           l_dpr.period_ctr := l_trx_period_rec.period_counter;
           l_dpr.dist_id    := 0;
           l_dpr.mrc_sob_type_code := p_mrc_sob_type_code;

           l_run_mode := 'STANDARD';

           fa_query_balances_pkg.query_balances_int(
 	                              X_DPR_ROW               => l_dpr,
 	                              X_RUN_MODE              => l_run_mode,
 	                              X_DEBUG                 => FALSE,
 	                              X_SUCCESS               => l_status,
 	                              X_CALLING_FN            => l_calling_fn,
 	                              X_TRANSACTION_HEADER_ID => -1
 	                              ,p_log_level_rec => p_log_level_rec);
           g_mem_ytd_deprn := l_dpr.ytd_deprn;
           g_mem_deprn_reserve := l_dpr.deprn_rsv;
           g_mem_bonus_ytd_deprn := l_dpr.bonus_ytd_deprn;
           g_mem_bonus_deprn_reserve := l_dpr.bonus_deprn_rsv;
           end if;
           /*Bug 8765735 and 8814747- End*/
        end if;
     else
         open c_get_current_period_mrc;
         fetch c_get_current_period_mrc into l_current_period_counter;
         close c_get_current_period_mrc;

        if nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'ALLOCATE' then
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_trx_period_rec.period_counter', l_trx_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_Asset_hdr_rec.book_type_code', p_Asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_reclassed_asset_id', p_reclassed_asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_asset_hdr_rec.asset_id', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
          end if;
           open c_get_mem_bs_row_mrc;
           fetch c_get_mem_bs_row_mrc into g_mem_ytd_deprn,g_mem_deprn_reserve,
 	                                        g_mem_bonus_ytd_deprn,g_mem_bonus_deprn_reserve,g_mem_eofy_reserve,
                                           g_mem_ytd_impairment,g_mem_impairment_reserve;

           close c_get_mem_bs_row_mrc;
           /*Bug 8765735 and 8814747 - Start*/
           if (fa_cache_pkg.fazcdbr_record.rule_name = 'ENERGY PERIOD END BALANCE') then
           l_dpr.asset_id   := p_reclassed_asset_id;
           l_dpr.book       := p_asset_hdr_rec.book_type_code;
           l_dpr.period_ctr := l_trx_period_rec.period_counter;
           l_dpr.dist_id    := 0;
           l_dpr.mrc_sob_type_code := p_mrc_sob_type_code;
           l_dpr.set_of_books_id := p_asset_hdr_rec.set_of_books_id; /*9090184 */

 	        l_run_mode := 'STANDARD';

 	        fa_query_balances_pkg.query_balances_int(
 	                              X_DPR_ROW               => l_dpr,
 	                              X_RUN_MODE              => l_run_mode,
 	                              X_DEBUG                 => FALSE,
 	                              X_SUCCESS               => l_status,
 	                              X_CALLING_FN            => l_calling_fn,
 	                              X_TRANSACTION_HEADER_ID => -1
 	                              ,p_log_level_rec => p_log_level_rec);
           g_mem_ytd_deprn := l_dpr.ytd_deprn;
           g_mem_deprn_reserve := l_dpr.deprn_rsv;
           g_mem_bonus_ytd_deprn := l_dpr.bonus_ytd_deprn;
           g_mem_bonus_deprn_reserve := l_dpr.bonus_deprn_rsv;
           end if;
           /*Bug 8765735 and 8814747- End*/
        end if;
     end if;

     if nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'CALCULATE' and
        l_trx_period_rec.period_counter = l_current_period_counter then

        -- Call populate_member_reserve
        if not FA_TRACK_MEMBER_PVT.populate_member_reserve
                              (p_trans_rec => p_trans_rec,
                               p_asset_hdr_rec => p_asset_hdr_rec,
                               p_asset_fin_rec_new => px_asset_fin_rec_new,
                               p_mrc_sob_type_code => p_mrc_sob_type_code,
                               x_deprn_reserve => l_mem_deprn_reserve,
                               x_eofy_reserve => l_mem_eofy_reserve, p_log_level_rec => p_log_level_rec) then
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'populate_member_reserve', p_log_level_rec => p_log_level_rec);
          end if;

          raise calc_failed;
        end if;

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '++ This is after POPULATE_MEMBER_RESERVE ++', '+++++', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'x_deprn_reserve', l_mem_deprn_reserve, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'x_eofy_reserve', l_mem_eofy_reserve, p_log_level_rec => p_log_level_rec);
        end if;

        --
        -- Get period information of the period from member dpis
        --
        if not GetPeriodInfo(to_number(to_char(l_transaction_date_entered, 'J')),
                             p_asset_hdr_rec.book_type_code,
                             p_mrc_sob_type_code,
                             p_asset_hdr_rec.set_of_books_id,
                             l_period_rec,
                             p_log_level_rec) then

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
          end if;

          raise calc_failed;

        end if;

      elsif nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'ALLOCATE' and
            g_mem_deprn_reserve is not null then

            l_mem_deprn_reserve := g_mem_deprn_reserve;
            l_mem_eofy_reserve := nvl(g_mem_eofy_reserve,0);

            l_mem_loop_first := TRUE;

            If (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, '++ This is a case for ALLOCATE and reclass in source group ++', '+++++', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'x_deprn_reserve', g_mem_deprn_reserve, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'x_eofy_reserve', g_mem_eofy_reserve, p_log_level_rec => p_log_level_rec);
            end if;
            /*115.211.211 branch to mainline porting - strats*/
            if (fa_cache_pkg.fazcdbr_record.rule_name <> 'ENERGY PERIOD END BALANCE') then
               if not GetPeriodInfo(to_number(to_char(p_reclassed_asset_dpis, 'J')),
                                    p_asset_hdr_rec.book_type_code,
                                    p_mrc_sob_type_code,
                                    p_asset_hdr_rec.set_of_books_id,
                                    l_period_rec,
                                    p_log_level_rec) then

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling', 'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;

               end if;

               l_transaction_date_entered := p_reclassed_asset_dpis;
            end if;
            /*115.211.211 branch to mainline porting - ends*/


      else -- Tracking is not used or period is not current period

      -- If this reclass is for source, group's books summary needs
      -- to be adjusted previously added period.
      -- If this is first time reclass out, it needs to be adjusted
      -- from dpis of the member asset.  If not, period which this member
      -- became member needs to be addjusted until now.
      -- In here, the date needs to be determined.
      -- If this is for dest, trx date is the date that this member
      -- becomes the dest group's member.
      --
      -- Get period information of the period from member dpis
      --
      if not GetPeriodInfo(to_number(to_char(p_reclassed_asset_dpis, 'J')),
                           p_asset_hdr_rec.book_type_code,
                           p_mrc_sob_type_code,
                           p_asset_hdr_rec.set_of_books_id,
                           l_period_rec,
                           p_log_level_rec) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;

      end if;

      l_transaction_date_entered := p_reclassed_asset_dpis;

     end if; -- HHIRAGA if-statement

   end if;

/*****************
   This part of code will be removed by adding new column change_in_eofy_reserve
 *****************
   --
   -- Setting period counter which is used to determine from which period
   -- is fa_books_summary records needed to be updated.
   -- If there is eofy_reserve in fin_rec_adj, need to get record from
   -- previous eofy record to reflect the amount and recalculate.
   --
--tk_util.debug('p_asset_fin_rec_adj.eofy_reserve: '||to_char(p_asset_fin_rec_adj.eofy_reserve));

   if (nvl(p_asset_fin_rec_adj.eofy_reserve, 0) <> 0) then
      --
      -- In case of trx w/ some eofy_reserve
      --   Update reserve_adjustment_amount by adj.eofy_reserve and reserve of the last eofy record,
      --   Update current fiscal years records' eofy_reserve
      --   Update current period's reserve_adjustment_amount with adj.reserve - adj.eofy_reserve
      -- This is why it needs to get extra periods(records before amortization start date) records

      l_period_counter := (l_period_rec.period_counter - l_period_rec.period_num);
   else
      l_period_counter := l_period_rec.period_counter - 1;
   end if; -- (p_asset_fin_rec_adj.eofy_reserve is not null)
*/

   l_period_counter := l_period_rec.period_counter - 1;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Starting Period',
                       l_period_counter, p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then

      OPEN c_get_mc_books_summary (l_period_counter);
      FETCH c_get_mc_books_summary BULK COLLECT INTO
               fa_amort_pvt.t_period_counter
             , fa_amort_pvt.t_fiscal_year
             , fa_amort_pvt.t_period_num
             , fa_amort_pvt.t_calendar_period_open_date
             , fa_amort_pvt.t_calendar_period_close_date
             , fa_amort_pvt.t_reset_adjusted_cost_flag
             , fa_amort_pvt.t_change_in_cost
             , fa_amort_pvt.t_change_in_cip_cost
             , fa_amort_pvt.t_cost
             , fa_amort_pvt.t_cip_cost
             , fa_amort_pvt.t_salvage_type
             , fa_amort_pvt.t_percent_salvage_value
             , fa_amort_pvt.t_salvage_value
             , fa_amort_pvt.t_member_salvage_value
             , fa_amort_pvt.t_recoverable_cost
             , fa_amort_pvt.t_deprn_limit_type
             , fa_amort_pvt.t_allowed_deprn_limit
             , fa_amort_pvt.t_allowed_deprn_limit_amount
             , fa_amort_pvt.t_member_deprn_limit_amount
             , fa_amort_pvt.t_adjusted_recoverable_cost
             , fa_amort_pvt.t_adjusted_cost
             , fa_amort_pvt.t_depreciate_flag
             , fa_amort_pvt.t_date_placed_in_service
             , fa_amort_pvt.t_deprn_method_code
             , fa_amort_pvt.t_life_in_months
             , fa_amort_pvt.t_rate_adjustment_factor
             , fa_amort_pvt.t_adjusted_rate
             , fa_amort_pvt.t_bonus_rule
             , fa_amort_pvt.t_adjusted_capacity
             , fa_amort_pvt.t_production_capacity
             , fa_amort_pvt.t_unit_of_measure
             , fa_amort_pvt.t_remaining_life1
             , fa_amort_pvt.t_remaining_life2
             , fa_amort_pvt.t_formula_factor
             , fa_amort_pvt.t_unrevalued_cost
             , fa_amort_pvt.t_reval_amortization_basis
             , fa_amort_pvt.t_reval_ceiling
             , fa_amort_pvt.t_ceiling_name
             , fa_amort_pvt.t_eofy_adj_cost
             , fa_amort_pvt.t_eofy_formula_factor
             , fa_amort_pvt.t_eofy_reserve
             , fa_amort_pvt.t_eop_adj_cost
             , fa_amort_pvt.t_eop_formula_factor
             , fa_amort_pvt.t_short_fiscal_year_flag
             , fa_amort_pvt.t_group_asset_id
             , fa_amort_pvt.t_super_group_id
             , fa_amort_pvt.t_over_depreciate_option
             , fa_amort_pvt.t_deprn_amount
             , fa_amort_pvt.t_ytd_deprn
             , fa_amort_pvt.t_deprn_reserve
             , fa_amort_pvt.t_bonus_deprn_amount
             , fa_amort_pvt.t_bonus_ytd_deprn
             , fa_amort_pvt.t_bonus_deprn_reserve
             , fa_amort_pvt.t_bonus_rate
             , fa_amort_pvt.t_impairment_amount
             , fa_amort_pvt.t_ytd_impairment
             , fa_amort_pvt.t_impairment_reserve
             , fa_amort_pvt.t_ltd_production
             , fa_amort_pvt.t_ytd_production
             , fa_amort_pvt.t_production
             , fa_amort_pvt.t_reval_amortization
             , fa_amort_pvt.t_reval_deprn_expense
             , fa_amort_pvt.t_reval_reserve
             , fa_amort_pvt.t_ytd_reval_deprn_expense
             , fa_amort_pvt.t_deprn_override_flag
             , fa_amort_pvt.t_system_deprn_amount
             , fa_amort_pvt.t_system_bonus_deprn_amount
             , fa_amort_pvt.t_ytd_proceeds_of_sale
             , fa_amort_pvt.t_ltd_proceeds_of_sale
             , fa_amort_pvt.t_ytd_cost_of_removal
             , fa_amort_pvt.t_ltd_cost_of_removal
             , fa_amort_pvt.t_deprn_adjustment_amount
             , fa_amort_pvt.t_expense_adjustment_amount
             , fa_amort_pvt.t_reserve_adjustment_amount
             , fa_amort_pvt.t_change_in_eofy_reserve
             , fa_amort_pvt.t_impairment_amount
             , fa_amort_pvt.t_ytd_impairment
             , fa_amort_pvt.t_impairment_reserve
             ;

      CLOSE c_get_mc_books_summary;

   else

      OPEN c_get_books_summary (l_period_counter);
      FETCH c_get_books_summary BULK COLLECT INTO
               fa_amort_pvt.t_period_counter
             , fa_amort_pvt.t_fiscal_year
             , fa_amort_pvt.t_period_num
             , fa_amort_pvt.t_calendar_period_open_date
             , fa_amort_pvt.t_calendar_period_close_date
             , fa_amort_pvt.t_reset_adjusted_cost_flag
             , fa_amort_pvt.t_change_in_cost
             , fa_amort_pvt.t_change_in_cip_cost
             , fa_amort_pvt.t_cost
             , fa_amort_pvt.t_cip_cost
             , fa_amort_pvt.t_salvage_type
             , fa_amort_pvt.t_percent_salvage_value
             , fa_amort_pvt.t_salvage_value
             , fa_amort_pvt.t_member_salvage_value
             , fa_amort_pvt.t_recoverable_cost
             , fa_amort_pvt.t_deprn_limit_type
             , fa_amort_pvt.t_allowed_deprn_limit
             , fa_amort_pvt.t_allowed_deprn_limit_amount
             , fa_amort_pvt.t_member_deprn_limit_amount
             , fa_amort_pvt.t_adjusted_recoverable_cost
             , fa_amort_pvt.t_adjusted_cost
             , fa_amort_pvt.t_depreciate_flag
             , fa_amort_pvt.t_date_placed_in_service
             , fa_amort_pvt.t_deprn_method_code
             , fa_amort_pvt.t_life_in_months
             , fa_amort_pvt.t_rate_adjustment_factor
             , fa_amort_pvt.t_adjusted_rate
             , fa_amort_pvt.t_bonus_rule
             , fa_amort_pvt.t_adjusted_capacity
             , fa_amort_pvt.t_production_capacity
             , fa_amort_pvt.t_unit_of_measure
             , fa_amort_pvt.t_remaining_life1
             , fa_amort_pvt.t_remaining_life2
             , fa_amort_pvt.t_formula_factor
             , fa_amort_pvt.t_unrevalued_cost
             , fa_amort_pvt.t_reval_amortization_basis
             , fa_amort_pvt.t_reval_ceiling
             , fa_amort_pvt.t_ceiling_name
             , fa_amort_pvt.t_eofy_adj_cost
             , fa_amort_pvt.t_eofy_formula_factor
             , fa_amort_pvt.t_eofy_reserve
             , fa_amort_pvt.t_eop_adj_cost
             , fa_amort_pvt.t_eop_formula_factor
             , fa_amort_pvt.t_short_fiscal_year_flag
             , fa_amort_pvt.t_group_asset_id
             , fa_amort_pvt.t_super_group_id
             , fa_amort_pvt.t_over_depreciate_option
             , fa_amort_pvt.t_deprn_amount
             , fa_amort_pvt.t_ytd_deprn
             , fa_amort_pvt.t_deprn_reserve
             , fa_amort_pvt.t_bonus_deprn_amount
             , fa_amort_pvt.t_bonus_ytd_deprn
             , fa_amort_pvt.t_bonus_deprn_reserve
             , fa_amort_pvt.t_bonus_rate
             , fa_amort_pvt.t_impairment_amount
             , fa_amort_pvt.t_ytd_impairment
             , fa_amort_pvt.t_impairment_reserve
             , fa_amort_pvt.t_ltd_production
             , fa_amort_pvt.t_ytd_production
             , fa_amort_pvt.t_production
             , fa_amort_pvt.t_reval_amortization
             , fa_amort_pvt.t_reval_deprn_expense
             , fa_amort_pvt.t_reval_reserve
             , fa_amort_pvt.t_ytd_reval_deprn_expense
             , fa_amort_pvt.t_deprn_override_flag
             , fa_amort_pvt.t_system_deprn_amount
             , fa_amort_pvt.t_system_bonus_deprn_amount
             , fa_amort_pvt.t_ytd_proceeds_of_sale
             , fa_amort_pvt.t_ltd_proceeds_of_sale
             , fa_amort_pvt.t_ytd_cost_of_removal
             , fa_amort_pvt.t_ltd_cost_of_removal
             , fa_amort_pvt.t_deprn_adjustment_amount
             , fa_amort_pvt.t_expense_adjustment_amount
             , fa_amort_pvt.t_reserve_adjustment_amount
             , fa_amort_pvt.t_change_in_eofy_reserve
             , fa_amort_pvt.t_impairment_amount
             , fa_amort_pvt.t_ytd_impairment
             , fa_amort_pvt.t_impairment_reserve
             ;

      CLOSE c_get_books_summary;

   end if;

--tk_util.debug('period# :      cost:   adjcost:       exp:      eofy:     rsvaj:       rsv:      dlmt:      arec');
/*
for i in fa_amort_pvt.t_cost.FIRST..fa_amort_pvt.t_cost.LAST loop
--tk_util.debug(rpad(to_char(fa_amort_pvt.t_period_counter(i)), 8, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_cost(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_adjusted_cost(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_deprn_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_eofy_reserve(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_reserve_adjustment_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_deprn_reserve(i)), 10, ' ')||':'||
              lpad(nvl(to_char(fa_amort_pvt.t_allowed_deprn_limit_amount(i)), 'null'), 5, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_adjusted_recoverable_cost(i)), 10, ' ')
             );
end loop;
*/
   l_count := fa_amort_pvt.t_period_counter.COUNT;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Number of period fetched', l_count, p_log_level_rec => p_log_level_rec);
   end if;

   if (l_count = 1) then
      --
      -- Get eofy information from fa_books_summary_table
      --
      if (p_mrc_sob_type_code = 'R') then
         OPEN c_get_mc_eofy_amts(fa_amort_pvt.t_period_counter(1) - fa_amort_pvt.t_period_num(1));
         FETCH c_get_mc_eofy_amts INTO l_eofy_rec_cost
                                  , l_eofy_sal_val
                                  , l_eofy_reserve;
         if c_get_mc_eofy_amts%NOTFOUND then
            CLOSE c_get_mc_eofy_amts;
            l_eofy_rec_cost := 0;
            l_eofy_sal_val := 0;
            l_eofy_reserve := 0;
         else
            CLOSE c_get_mc_eofy_amts;
         end if;
      else
         OPEN c_get_eofy_amts(fa_amort_pvt.t_period_counter(1) - fa_amort_pvt.t_period_num(1));
         FETCH c_get_eofy_amts INTO l_eofy_rec_cost
                                  , l_eofy_sal_val
                                  , l_eofy_reserve;
         if c_get_eofy_amts%NOTFOUND then
            CLOSE c_get_eofy_amts;
            l_eofy_rec_cost := 0;
            l_eofy_sal_val := 0;
            l_eofy_reserve := 0;
         else
            CLOSE c_get_eofy_amts;
         end if;
      end if;

   else
      --
      -- Get eofy information from fa_books_summary_table
      --
      if (p_mrc_sob_type_code = 'R') then
         OPEN c_get_mc_eofy_amts(fa_amort_pvt.t_period_counter(2) - fa_amort_pvt.t_period_num(2));
         FETCH c_get_mc_eofy_amts INTO l_eofy_rec_cost
                                  , l_eofy_sal_val
                                  , l_eofy_reserve;
         if c_get_mc_eofy_amts%NOTFOUND then
            CLOSE c_get_mc_eofy_amts;
            l_eofy_rec_cost := 0;
            l_eofy_sal_val := 0;
            l_eofy_reserve := 0;
         else
            CLOSE c_get_mc_eofy_amts;
         end if;
      else
         OPEN c_get_eofy_amts(fa_amort_pvt.t_period_counter(2) - fa_amort_pvt.t_period_num(2));
         FETCH c_get_eofy_amts INTO l_eofy_rec_cost
                                  , l_eofy_sal_val
                                  , l_eofy_reserve;
         if c_get_eofy_amts%NOTFOUND then
            CLOSE c_get_eofy_amts;
            l_eofy_rec_cost := 0;
            l_eofy_sal_val := 0;
            l_eofy_reserve := 0;
         else
            CLOSE c_get_eofy_amts;
         end if;
      end if;

   end if; -- (l_count = 1)

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_eofy_reserve', l_eofy_reserve, p_log_level_rec => p_log_level_rec);
      end if;

/*** REMOVED
   end if;
 ***/

   --
   -- At this point, l_bs_ind holds indicator for previous period of the period
   -- where amortization start date falls in.
   --
--tk_util.debug('l_transaction_date_entered: '||to_char(l_transaction_date_entered, 'DD-MON-YYYY'));
--tk_util.debug('close date: '||to_char(fa_amort_pvt.t_calendar_period_close_date(l_bs_ind),  'DD-MON-YYYY'));
--tk_util.debug('count: '||to_char(fa_amort_pvt.t_period_counter.COUNT));

   if (fa_amort_pvt.t_period_counter.COUNT > 1) and
      (l_transaction_date_entered >
       fa_amort_pvt.t_calendar_period_close_date(l_bs_ind))then
      l_bs_ind := l_bs_ind + 1;
   end if;
--tk_util.debug('l_bs_ind: '||to_char(l_bs_ind));

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Populating local fin_rec_old',
                       fa_amort_pvt.t_cost(l_bs_ind));
   end if;

   l_asset_fin_rec_old.cost := fa_amort_pvt.t_cost(l_bs_ind);
   l_asset_fin_rec_old.formula_factor := fa_amort_pvt.t_formula_factor(l_bs_ind);

   l_asset_fin_rec_old.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(l_bs_ind);
   l_asset_fin_rec_old.adjusted_cost := fa_amort_pvt.t_adjusted_cost(l_bs_ind);
   l_asset_fin_rec_old.salvage_value := fa_amort_pvt.t_salvage_value(l_bs_ind);
   l_asset_fin_rec_old.recoverable_cost := fa_amort_pvt.t_recoverable_cost(l_bs_ind);


   l_asset_fin_rec_old.deprn_method_code := fa_amort_pvt.t_deprn_method_code(l_bs_ind);
   l_asset_fin_rec_old.life_in_months := fa_amort_pvt.t_life_in_months(l_bs_ind);
   l_asset_fin_rec_old.group_asset_id := fa_amort_pvt.t_group_asset_id(l_bs_ind);
   l_asset_fin_rec_old.depreciate_flag := fa_amort_pvt.t_depreciate_flag(l_bs_ind);
   l_asset_fin_rec_old.recognize_gain_loss := px_asset_fin_rec_new.recognize_gain_loss;
   l_asset_fin_rec_old.tracking_method := px_asset_fin_rec_new.tracking_method;

   l_asset_fin_rec_old.allocate_to_fully_rsv_flag := px_asset_fin_rec_new.allocate_to_fully_rsv_flag;
   l_asset_fin_rec_old.allocate_to_fully_ret_flag := px_asset_fin_rec_new.allocate_to_fully_ret_flag;
   l_asset_fin_rec_old.excess_allocation_option := px_asset_fin_rec_new.excess_allocation_option;
   l_asset_fin_rec_old.depreciation_option := px_asset_fin_rec_new.depreciation_option;
   l_asset_fin_rec_old.member_rollup_flag := px_asset_fin_rec_new.member_rollup_flag;

   l_asset_fin_rec_new.reduction_rate := px_asset_fin_rec_new.reduction_rate;
   l_asset_fin_rec_new.recognize_gain_loss := l_asset_fin_rec_old.recognize_gain_loss;
   l_asset_fin_rec_new.tracking_method := l_asset_fin_rec_old.tracking_method;
   l_asset_fin_rec_new.allocate_to_fully_rsv_flag := l_asset_fin_rec_old.allocate_to_fully_rsv_flag;
   l_asset_fin_rec_new.allocate_to_fully_ret_flag := l_asset_fin_rec_old.allocate_to_fully_ret_flag;
   l_asset_fin_rec_new.excess_allocation_option := l_asset_fin_rec_old.excess_allocation_option;
   l_asset_fin_rec_new.depreciation_option := l_asset_fin_rec_old.depreciation_option;
   l_asset_fin_rec_new.member_rollup_flag := l_asset_fin_rec_old.member_rollup_flag;
   --Bug3286560: This will be old adj cost in deprn basis function
   l_asset_fin_rec_new.adjusted_cost := fa_amort_pvt.t_adjusted_cost(l_bs_ind);
   -- Bug 4700524: first time in loop fin_rec_old.cost needs to be old cost
   l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(l_bs_ind);

   --
   -- Setting reset_adjusted_cost_flag
   -- If this is source group, it is not always first period of recalculation because
   -- pl/sql table always has data from member's dpis
   -- Also find value for l_temp_ind and it will be used to update table at the end.
   --
   if (p_reclass_src_dest = 'SOURCE') then

      l_temp_ind := l_bs_ind + l_trx_period_rec.period_counter - fa_amort_pvt.t_period_counter(l_bs_ind);
      fa_amort_pvt.t_reset_adjusted_cost_flag(l_temp_ind) := 'Y';

--tk_util.debug('l_temp_ind: '||to_char(l_temp_ind));
--tk_util.debug('period counter: '||to_char(fa_amort_pvt.t_period_counter(l_temp_ind)));

      --
      -- Store old reserve so that it can be used to determine how much reserve needs to be
      -- taken out from srouce group at reclassed period.
      --
      if (l_temp_ind = 1) then
         l_old_reserve := 0;
      else
         /*Bug# 8548876 -uncommented changes done for 5768759*/
         l_old_reserve := fa_amort_pvt.t_deprn_reserve(l_temp_ind - 1);
      end if;

   else
      l_temp_ind := l_bs_ind;

      if (p_reclass_src_dest is not null) then
         fa_amort_pvt.t_reset_adjusted_cost_flag(l_bs_ind) := 'Y';
      end if;

--   else
--      fa_amort_pvt.t_reset_adjusted_cost_flag(l_bs_ind) := 'Y';
--      l_temp_ind := l_bs_ind;
   end if;

   if (p_trans_rec.transaction_key = 'MS') then
      if (p_mrc_sob_type_code = 'R') then
         OPEN c_get_mc_rein_info;
         FETCH c_get_mc_rein_info INTO l_proceeds_of_sale
                                  , l_cost_of_removal
                                  , l_reserve_retired
                                  , l_nbv_retired
                                  , l_recognize_gain_loss -- Added for bug 8425794 / 8244128
                                  , l_recapture_amount;
         CLOSE c_get_mc_rein_info;
      else
         OPEN c_get_rein_info;
         FETCH c_get_rein_info INTO l_proceeds_of_sale
                                  , l_cost_of_removal
                                  , l_reserve_retired
                                  , l_nbv_retired
                                  , l_recognize_gain_loss -- Added for bug 8425794 / 8244128
                                  , l_recapture_amount;
         CLOSE c_get_rein_info;
      end if;

      if (l_reserve_retired is null) and
         (l_recognize_gain_loss = 'NO') then
         l_reserve_retired := px_asset_fin_rec_new.cost - p_asset_fin_rec_old.cost;
      elsif (l_reserve_retired is null) then -- Added for bug 8425794 / 8244128
         l_reserve_retired := 0;
      end if;

      --bug6912446
      -- Lifting below to calculate reserve retired for all ALLOCATE and DO NOT RECOGNIZE CASE
      if (p_asset_fin_rec_old.tracking_method = 'ALLOCATE') and
         (l_recognize_gain_loss = 'NO') then
         -- l_proceeds_of_sale and l_cost_of_removal has -1 multiplied in cursor c_get_rein_info
         -- so that it can be added whether the trx is ret or rein later when maintaining
         -- ytd and ltd for books summary table.
         l_reserve_retired := p_asset_fin_rec_adj.cost + l_proceeds_of_sale - l_cost_of_removal + nvl(l_recapture_amount,0);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'This is Reinstatement', l_reserve_retired, p_log_level_rec => p_log_level_rec);
      end if;

   else
      l_reserve_retired := 0;
   end if;


   --
   -- Need to find out how unplanned expense is passed to here
   --
   fa_amort_pvt.t_expense_adjustment_amount(l_bs_ind) :=
                      fa_amort_pvt.t_expense_adjustment_amount(l_bs_ind) +
                      nvl(p_asset_deprn_rec_adj.deprn_amount, 0);

   fa_amort_pvt.t_reserve_adjustment_amount(l_bs_ind) :=
                      fa_amort_pvt.t_reserve_adjustment_amount(l_bs_ind) +
                      nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) + l_reserve_retired;
--                      nvl(p_asset_deprn_rec_adj.deprn_reserve, 0);
--                      (nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) -
--                       nvl(p_asset_fin_rec_adj.eofy_reserve, 0)) +



   fa_amort_pvt.t_change_in_eofy_reserve(l_bs_ind) :=
                        nvl(fa_amort_pvt.t_change_in_eofy_reserve(l_bs_ind), 0) +
                        nvl(p_asset_fin_rec_adj.eofy_reserve, 0);


   --Bug7487450: Modified "> 2" with "> 1" as it was not setting correct amount
   --            for reserve if there are only two period.
   if (p_reclass_src_dest = 'SOURCE') then
      if (l_trx_period_rec.period_counter > fa_amort_pvt.t_period_counter(1)) and
         (l_trx_period_rec.period_counter >= fa_amort_pvt.t_period_counter(l_bs_ind)) and
         (fa_amort_pvt.t_period_counter.COUNT > 1) then

--tk_util.debug('last period counter: '||to_char(fa_amort_pvt.t_period_counter(fa_amort_pvt.t_period_counter.LAST)));
--tk_util.debug('l_trx_period_rec.period_counter: '||to_char(l_trx_period_rec.period_counter));

         l_gr_ind := fa_amort_pvt.t_period_counter.COUNT -
                     (fa_amort_pvt.t_period_counter(fa_amort_pvt.t_period_counter.LAST) -
                      (l_trx_period_rec.period_counter - 1));

--tk_util.debug('l_gr_ind: '||to_char(l_gr_ind));
--tk_util.debug('ytd: '||to_char(fa_amort_pvt.t_ytd_deprn(l_gr_ind)));

            l_gr_asset_deprn_rec.deprn_amount        := fa_amort_pvt.t_deprn_amount(l_gr_ind);
            l_gr_asset_deprn_rec.ytd_deprn           := fa_amort_pvt.t_ytd_deprn(l_gr_ind);
            l_gr_asset_deprn_rec.deprn_reserve       := fa_amort_pvt.t_deprn_reserve(l_gr_ind);
            l_gr_asset_deprn_rec.bonus_deprn_amount  := fa_amort_pvt.t_bonus_deprn_amount(l_gr_ind);
            l_gr_asset_deprn_rec.bonus_ytd_deprn     := fa_amort_pvt.t_bonus_ytd_deprn(l_gr_ind);
            l_gr_asset_deprn_rec.bonus_deprn_reserve := fa_amort_pvt.t_bonus_deprn_reserve(l_gr_ind);
            l_gr_asset_deprn_rec.impairment_amount   := fa_amort_pvt.t_impairment_amount(l_gr_ind);
            l_gr_asset_deprn_rec.ytd_impairment      := fa_amort_pvt.t_ytd_impairment(l_gr_ind);
            l_gr_asset_deprn_rec.impairment_reserve  := fa_amort_pvt.t_impairment_reserve(l_gr_ind);
            l_gr_asset_deprn_rec.ltd_production      := fa_amort_pvt.t_ltd_production(l_gr_ind);
            l_gr_asset_deprn_rec.ytd_production      := fa_amort_pvt.t_ytd_production(l_gr_ind);
            l_gr_asset_deprn_rec.production          := fa_amort_pvt.t_production(l_gr_ind);
            l_gr_asset_deprn_rec.reval_amortization  := fa_amort_pvt.t_reval_amortization(l_gr_ind);
            l_gr_asset_deprn_rec.reval_deprn_expense := fa_amort_pvt.t_reval_deprn_expense(l_gr_ind);
            l_gr_asset_deprn_rec.reval_deprn_reserve := fa_amort_pvt.t_reval_reserve(l_gr_ind);
            l_gr_asset_deprn_rec.reval_ytd_deprn     := fa_amort_pvt.t_ytd_reval_deprn_expense(l_gr_ind);
      else
            l_gr_asset_deprn_rec.deprn_amount        := 0;
            l_gr_asset_deprn_rec.ytd_deprn           := 0;
            l_gr_asset_deprn_rec.deprn_reserve       := 0;
            l_gr_asset_deprn_rec.bonus_deprn_amount  := 0;
            l_gr_asset_deprn_rec.bonus_ytd_deprn     := 0;
            l_gr_asset_deprn_rec.bonus_deprn_reserve := 0;
            l_gr_asset_deprn_rec.impairment_amount   := 0;
            l_gr_asset_deprn_rec.ytd_impairment      := 0;
            l_gr_asset_deprn_rec.impairment_reserve      := 0;
            l_gr_asset_deprn_rec.ltd_production      := 0;
            l_gr_asset_deprn_rec.ytd_production      := 0;
            l_gr_asset_deprn_rec.production          := 0;
            l_gr_asset_deprn_rec.reval_amortization  := 0;
            l_gr_asset_deprn_rec.reval_deprn_expense := 0;
            l_gr_asset_deprn_rec.reval_deprn_reserve := 0;
            l_gr_asset_deprn_rec.reval_ytd_deprn     := 0;
      end if;
   end if;


   d := 0;

--tk_util.debug('period# :      cost:   adjcost:       exp:      eofy:     rsvaj:       rsv:      dlmt:      arec');
/*
for i in fa_amort_pvt.t_cost.FIRST..fa_amort_pvt.t_cost.LAST loop
--tk_util.debug(rpad(to_char(fa_amort_pvt.t_period_counter(i)), 8, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_cost(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_adjusted_cost(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_deprn_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_eofy_reserve(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_reserve_adjustment_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_deprn_reserve(i)), 10, ' ')||':'||
              lpad(nvl(to_char(fa_amort_pvt.t_allowed_deprn_limit_amount(i)), 'null'), 5, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_adjusted_recoverable_cost(i)), 10, ' ')
             );
end loop;
*/
               --
               -- Update FA_BOOKS_SUMMARY
               --

   -- *********************** --
   --  Main Loop Starts Here  --
   -- *********************** --
   FOR i IN l_bs_ind..l_count LOOP
      d := d + 1;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Processing period',
                          fa_amort_pvt.t_period_counter(i));
      end if;

      if i <> 1 then
         l_asset_fin_rec_old := l_asset_fin_rec_new;
      end if;

      --
      -- Populate l_period_rec for deprn basis
      --
      l_period_rec.period_counter := fa_amort_pvt.t_period_counter(i);
      l_period_rec.fiscal_year := fa_amort_pvt.t_fiscal_year(i);
      l_period_rec.period_num := fa_amort_pvt.t_period_num(i);

--tk_util.debug('fa_amort_pvt.t_cost: '||to_char(fa_amort_pvt.t_cost(i)));

      if (l_mem_trx) then

--tk_util.debug('td_cost('||to_char(d)||'): '||to_char(td_cost(d)));
--tk_util.debug('l_trx_period_rec.period_counter: '||to_char(l_trx_period_rec.period_counter));
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_change_in_cost(i)' , fa_amort_pvt.t_change_in_cost(i), p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'td_cost(d)' , td_cost(d), p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_reclass.cost' , l_asset_fin_rec_reclass.cost, p_log_level_rec);
        end if;

        if (p_reclass_src_dest = 'DESTINATION') and
           (l_trx_period_rec.period_counter = fa_amort_pvt.t_period_counter(i)) then

--tk_util.debug('GROUP RECLASS: '||to_char(fa_amort_pvt.t_period_counter(i)));

           fa_amort_pvt.t_change_in_cost(i) := fa_amort_pvt.t_change_in_cost(i) + l_asset_fin_rec_reclass.cost;
           fa_amort_pvt.t_change_in_cip_cost(i) := fa_amort_pvt.t_change_in_cip_cost(i) +
                                            l_asset_fin_rec_reclass.cip_cost;
        else
--tk_util.debug('fa_amort_pvt.t_change_in_cost('||to_char(d)||'): '|| to_char(fa_amort_pvt.t_change_in_cost(i)));

           fa_amort_pvt.t_change_in_cost(i) := fa_amort_pvt.t_change_in_cost(i) + td_cost(d);
           fa_amort_pvt.t_change_in_cip_cost(i) := fa_amort_pvt.t_change_in_cip_cost(i) + td_cip_cost(d);

        end if;

--tk_util.debug('fa_amort_pvt.t_change_in_cost('||to_char(i)||'): '|| to_char(fa_amort_pvt.t_change_in_cost(i)));
--tk_util.debug('td_salvage_value('||to_char(d)||'): '|| to_char(td_salvage_value(d)));

         if (p_reclass_src_dest = 'SOURCE') and (l_trx_period_rec.period_counter = fa_amort_pvt.t_period_counter(i)) then
 	         fa_amort_pvt.t_change_in_cost(i) := fa_amort_pvt.t_change_in_cost(i) +
 	                                             (l_asset_fin_rec_reclass.cost - td_cost(d));
 	         fa_amort_pvt.t_change_in_cip_cost(i) := fa_amort_pvt.t_change_in_cip_cost(i) +
 	                                                 (l_asset_fin_rec_reclass.cip_cost - td_cip_cost(d));
 	         --tk_util.debug('Synchronizing change_in_cost: '||to_char(fa_amort_pvt.t_change_in_cost(i)));
 	      end if;

         if (i = 1) then
            fa_amort_pvt.t_cost(i) := fa_amort_pvt.t_change_in_cost(i);
            fa_amort_pvt.t_cip_cost(i) := fa_amort_pvt.t_change_in_cip_cost(i);

            if (p_reclass_src_dest is not null) and
               (l_trx_period_rec.period_counter = fa_amort_pvt.t_period_counter(i)) then
               fa_amort_pvt.t_member_salvage_value(i) := fa_amort_pvt.t_member_salvage_value(i) +
                                                         l_asset_fin_rec_reclass.salvage_value;
               fa_amort_pvt.t_member_deprn_limit_amount(i) := fa_amort_pvt.t_member_deprn_limit_amount(i) +
                                                              l_asset_fin_rec_reclass.allowed_deprn_limit_amount;
            else
               fa_amort_pvt.t_member_salvage_value(i) := fa_amort_pvt.t_member_salvage_value(i) +
                                                         td_salvage_value(d);
               fa_amort_pvt.t_member_deprn_limit_amount(i) := fa_amort_pvt.t_member_deprn_limit_amount(i) +
                                                              td_deprn_limit_amount(d);
            end if;

            fa_amort_pvt.t_rate_adjustment_factor(i) := 1;
         else
            --bug6903588: Need to back out this fix as it was distructing the testcase for this bug
            -- Cannot reproduce during the test.
            if (p_log_level_rec.statement_level) then
 	             fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_cost(i - 1)' , fa_amort_pvt.t_cost(i - 1), p_log_level_rec);
 	             fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_change_in_cost(i)' , fa_amort_pvt.t_change_in_cost(i), p_log_level_rec);
 	         end if;
            fa_amort_pvt.t_cost(i) := fa_amort_pvt.t_cost(i - 1) + fa_amort_pvt.t_change_in_cost(i);
            fa_amort_pvt.t_cip_cost(i) := fa_amort_pvt.t_cip_cost(i - 1) + fa_amort_pvt.t_change_in_cip_cost(i);


            if (p_reclass_src_dest is not null) and
               (l_trx_period_rec.period_counter = fa_amort_pvt.t_period_counter(i)) then
               fa_amort_pvt.t_member_salvage_value(i) := fa_amort_pvt.t_member_salvage_value(i) +
                                                         l_asset_fin_rec_reclass.salvage_value;
               fa_amort_pvt.t_member_deprn_limit_amount(i) := fa_amort_pvt.t_member_deprn_limit_amount(i) +
                                                              l_asset_fin_rec_reclass.allowed_deprn_limit_amount;
            else
               fa_amort_pvt.t_member_salvage_value(i) := fa_amort_pvt.t_member_salvage_value(i) +
                                                         td_salvage_value(d);
               fa_amort_pvt.t_member_deprn_limit_amount(i) := fa_amort_pvt.t_member_deprn_limit_amount(i) +
                                                              td_deprn_limit_amount(d);
            end if;

            fa_amort_pvt.t_rate_adjustment_factor(i) := fa_amort_pvt.t_rate_adjustment_factor(i - 1);
         end if;
       end if;

--tk_util.debug('fa_amort_pvt.t_member_salvage_value('||to_char(i)||'): '|| to_char(fa_amort_pvt.t_member_salvage_value(i)));
--tk_util.debug('fa_amort_pvt.t_cost('||to_char(d)||'): '|| to_char(fa_amort_pvt.t_cost(i)));

      --
      -- Apply delta to books sumamry global variables
      --
      fa_amort_pvt.t_salvage_type(i) := nvl(p_asset_fin_rec_adj.salvage_type,
                                             fa_amort_pvt.t_salvage_type(i));
      fa_amort_pvt.t_deprn_limit_type(i) := nvl(p_asset_fin_rec_adj.deprn_limit_type,
                                                 fa_amort_pvt.t_deprn_limit_type(i));

      if (px_asset_fin_rec_new.depreciate_flag <>
          p_asset_fin_rec_old.depreciate_flag) then
         fa_amort_pvt.t_depreciate_flag(i) := px_asset_fin_rec_new.depreciate_flag;
      end if;

      if (nvl(p_asset_fin_rec_old.deprn_method_code,
              px_asset_fin_rec_new.deprn_method_code) <> px_asset_fin_rec_new.deprn_method_code) then
         fa_amort_pvt.t_deprn_method_code(i) := px_asset_fin_rec_new.deprn_method_code;
         fa_amort_pvt.t_life_in_months(i) := px_asset_fin_rec_new.life_in_months;
         fa_amort_pvt.t_adjusted_rate(i) := px_asset_fin_rec_new.adjusted_rate;
--tk_util.debug('1 adjusted_rate: '||to_char(fa_amort_pvt.t_adjusted_rate(i)));
      else
         fa_amort_pvt.t_life_in_months(i) := nvl(p_asset_fin_rec_adj.life_in_months,
                                                  fa_amort_pvt.t_life_in_months(i));
         fa_amort_pvt.t_adjusted_rate(i) := nvl(p_asset_fin_rec_adj.adjusted_rate,
                                                 fa_amort_pvt.t_adjusted_rate(i));
--tk_util.debug('adj adjusted_rate: '||to_char(p_asset_fin_rec_adj.adjusted_rate));
--tk_util.debug('2 adjusted_rate: '||to_char(fa_amort_pvt.t_adjusted_rate(i)));
      end if;

      fa_amort_pvt.t_bonus_rule(i) := nvl(p_asset_fin_rec_adj.bonus_rule,
                                           fa_amort_pvt.t_bonus_rule(i));
      --   fa_amort_pvt.t_adjusted_capacity(i) :=
      fa_amort_pvt.t_production_capacity(i) := nvl(fa_amort_pvt.t_production_capacity(i), 0) +
                                                nvl(p_asset_fin_rec_adj.production_capacity, 0);
      fa_amort_pvt.t_unit_of_measure(i) := nvl(p_asset_fin_rec_adj.unit_of_measure,
                                            fa_amort_pvt.t_unit_of_measure(i));
      --
      -- I don't know what to store in these columns
      --
--   fa_amort_pvt.t_remaining_life1(i) :=
--   fa_amort_pvt.t_remaining_life2(i) :=

      fa_amort_pvt.t_ceiling_name(i) := nvl(p_asset_fin_rec_adj.ceiling_name,
                                              fa_amort_pvt.t_ceiling_name(i));

      if (p_asset_fin_rec_old.group_asset_id = px_asset_fin_rec_new.group_asset_id) then
         null;
      else
         fa_amort_pvt.t_group_asset_id(i) := px_asset_fin_rec_new.group_asset_id;
      end if;

      if (nvl(p_asset_fin_rec_old.super_group_id, 0) = nvl(px_asset_fin_rec_new.super_group_id, 0)) then
         null;
      else
         fa_amort_pvt.t_super_group_id(i) := px_asset_fin_rec_new.super_group_id;
      end if;

      fa_amort_pvt.t_over_depreciate_option(i) := nvl(p_asset_fin_rec_adj.over_depreciate_option,
                                                       fa_amort_pvt.t_over_depreciate_option(i));

      if (nvl(p_asset_fin_rec_old.salvage_type,
              px_asset_fin_rec_new.salvage_type) = px_asset_fin_rec_new.salvage_type) then
         fa_amort_pvt.t_percent_salvage_value(i) := fa_amort_pvt.t_percent_salvage_value(i) +
                                                     nvl(p_asset_fin_rec_adj.percent_salvage_value, 0);
      else
         fa_amort_pvt.t_percent_salvage_value(i) := nvl(px_asset_fin_rec_new.percent_salvage_value, 0);
      end if;

      if (nvl(p_asset_fin_rec_old.deprn_limit_type,
         px_asset_fin_rec_new.deprn_limit_type) = px_asset_fin_rec_new.deprn_limit_type) then
         fa_amort_pvt.t_allowed_deprn_limit(i) := fa_amort_pvt.t_allowed_deprn_limit(i) +
                                                   nvl(p_asset_fin_rec_adj.allowed_deprn_limit, 0);
      else
         fa_amort_pvt.t_allowed_deprn_limit(i) := nvl(px_asset_fin_rec_new.allowed_deprn_limit, 0);
      end if;

      if (fa_amort_pvt.t_salvage_type(i) = 'PCT') then
         l_temp_num := fa_amort_pvt.t_cost(i) * fa_amort_pvt.t_percent_salvage_value(i);
         fa_round_pkg.fa_ceil(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         fa_amort_pvt.t_salvage_value(i) := l_temp_num;
      else -- case of SUM
         fa_amort_pvt.t_salvage_value(i) := fa_amort_pvt.t_member_salvage_value(i);
      end if;

      if (fa_amort_pvt.t_deprn_limit_type(i) = 'PCT') then
         l_temp_num := fa_amort_pvt.t_cost(i) * (1 -  fa_amort_pvt.t_allowed_deprn_limit(i));
         fa_round_pkg.fa_floor(l_temp_num, p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         fa_amort_pvt.t_allowed_deprn_limit_amount(i) := l_temp_num;
      elsif(fa_amort_pvt.t_deprn_limit_type(i) = 'SUM') then
         fa_amort_pvt.t_allowed_deprn_limit_amount(i) := fa_amort_pvt.t_member_deprn_limit_amount(i);
      else  -- case of 'NONE'
         fa_amort_pvt.t_allowed_deprn_limit_amount(i) := null;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_salvage_type('||to_char(i)||')',
                          fa_amort_pvt.t_salvage_type(i));
         fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_percent_salvage_value('||to_char(i)||')',
                          fa_amort_pvt.t_percent_salvage_value(i));
         fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_salvage_value('||to_char(i)||')',
                          fa_amort_pvt.t_salvage_value(i));
         fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_member_salvage_value('||to_char(i)||')',
                          fa_amort_pvt.t_member_salvage_value(i));
         fa_debug_pkg.add(l_calling_fn,
                          'fa_amort_pvt.t_deprn_limit_type('||to_char(i)||')',
                          fa_amort_pvt.t_deprn_limit_type(i));
         fa_debug_pkg.add(l_calling_fn,
                          'fa_amort_pvt.t_allowed_deprn_limit('||to_char(i)||')',
                          fa_amort_pvt.t_allowed_deprn_limit(i));
         fa_debug_pkg.add(l_calling_fn,
                          'fa_amort_pvt.t_allowed_deprn_limit_amount('||to_char(i)||')',
                          fa_amort_pvt.t_allowed_deprn_limit_amount(i));
         fa_debug_pkg.add(l_calling_fn,
                          'fa_amort_pvt.t_member_deprn_limit_amount('||to_char(i)||')',
                          fa_amort_pvt.t_member_deprn_limit_amount(i));
      end if;


      --
      -- At this point, all attributes to determine whether resetting adjusted cost is necessary
      -- or not. Here is the list of the attributes
      --  change_in_cost, change_in_cip_cost, member_salvage_value, member_deprn_limit_amount,
      --  percent_salvage_value, allowed_deprn_limit, salvage_value, allowed_deprn_limit_amount
      --  deprn_method_code, adjusted_rate, bonus_rule
      -- If this is destination asset for reclass transaction, this place is too late to
      -- set reset_adjusted_cost_flag
      if (i = 1) or
         (fa_amort_pvt.t_change_in_cost(i) <> 0) or
         (fa_amort_pvt.t_change_in_cip_cost(i) <> 0) then
         fa_amort_pvt.t_reset_adjusted_cost_flag(i) := 'Y';
--tk_util.debug('tktk1');
      elsif (nvl(fa_amort_pvt.t_percent_salvage_value(i), 0) <> nvl(fa_amort_pvt.t_percent_salvage_value(i-1),0)) or
            (nvl(fa_amort_pvt.t_allowed_deprn_limit(i), 0) <> nvl(fa_amort_pvt.t_allowed_deprn_limit(i-1), 0)) or
            (fa_amort_pvt.t_salvage_value(i) <> fa_amort_pvt.t_salvage_value(i-1)) or
            (nvl(fa_amort_pvt.t_allowed_deprn_limit_amount(i), 0) <>
                                         nvl(fa_amort_pvt.t_allowed_deprn_limit_amount(i-1), 0)) or
            (fa_amort_pvt.t_deprn_method_code(i) <> fa_amort_pvt.t_deprn_method_code(i-1)) or
            (nvl(fa_amort_pvt.t_adjusted_rate(i), 0) <> nvl(fa_amort_pvt.t_adjusted_rate(i-1), 0)) or
            (nvl(fa_amort_pvt.t_bonus_rule(i), 'NULL') <> nvl(fa_amort_pvt.t_bonus_rule(i-1), 'NULL') or
            (fa_amort_pvt.t_expense_adjustment_amount(i) <> 0) or
            (fa_amort_pvt.t_reserve_adjustment_amount(i) <> 0)) then

         fa_amort_pvt.t_reset_adjusted_cost_flag(i) := 'Y';

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('tk','1',fa_amort_pvt.t_member_salvage_value(i-1));
            fa_debug_pkg.add('tk','2', fa_amort_pvt.t_member_deprn_limit_amount(i-1));
            fa_debug_pkg.add('tk','3', fa_amort_pvt.t_percent_salvage_value(i-1));
            fa_debug_pkg.add('tk','4', fa_amort_pvt.t_allowed_deprn_limit(i-1));
            fa_debug_pkg.add('tk','5', fa_amort_pvt.t_salvage_value(i-1));
            fa_debug_pkg.add('tk','6', fa_amort_pvt.t_allowed_deprn_limit_amount(i-1));
            fa_debug_pkg.add('tk','7', fa_amort_pvt.t_deprn_method_code(i-1));
            fa_debug_pkg.add('tk','8', fa_amort_pvt.t_adjusted_rate(i-1));
            fa_debug_pkg.add('tk','9', fa_amort_pvt.t_bonus_rule(i-1));
            fa_debug_pkg.add('tk','0', fa_amort_pvt.t_expense_adjustment_amount(i-1));
            fa_debug_pkg.add('tk','1', fa_amort_pvt.t_reserve_adjustment_amount(i-1));
         end if;

      elsif ((p_reclass_src_dest is not null) and
         --bug3872075: Need group's change_in_cost etc instead of delta
         --(td_cost(d) is not null)) then
            ((nvl(fa_amort_pvt.t_change_in_cost(i), 0) <> 0) or
            (nvl(fa_amort_pvt.t_change_in_cip_cost(i), 0) <> 0))) then

         fa_amort_pvt.t_reset_adjusted_cost_flag(i) := 'Y';

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Reclass trx and still change in', 'COST', p_log_level_rec => p_log_level_rec);
         end if;

      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Setting reset adj cost flag to ', 'N', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'Resetting adjusted cost', 'Not Required', p_log_level_rec => p_log_level_rec);
         end if;

         fa_amort_pvt.t_reset_adjusted_cost_flag(i) := 'N';

         if (i = 2)  then
            if (  fa_amort_pvt.t_period_num(i) = 1) and

               (nvl(fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag, 'N') = 'Y') or
               (  (nvl(fa_amort_pvt.t_change_in_cost(i), 0) <> 0) or
                  (nvl(fa_amort_pvt.t_change_in_cip_cost(i), 0) <> 0)) then

               fa_amort_pvt.t_reset_adjusted_cost_flag(i) := 'Y';
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'There is still something changed', 'Resetting adj cost required', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'Resetting adjusted cost', 'Still  Required', p_log_level_rec => p_log_level_rec);
               end if;
            elsif (nvl(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') = 'Y') then -- Added for bug 8425794 / 8244128
               fa_amort_pvt.t_reset_adjusted_cost_flag(i) := 'Y';
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'There is still something changed', 'Resetting adj cost required', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'Resetting adjusted cost', 'Still  Required', p_log_level_rec => p_log_level_rec);
               end if;
            else
               fa_amort_pvt.t_adjusted_cost(i) := fa_amort_pvt.t_adjusted_cost(i-1);
               -- Bug5732277: Adding following to reflect adjusted_cost
               l_asset_fin_rec_new.adjusted_cost := fa_amort_pvt.t_adjusted_cost(i);

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Inheriting adj cost from', 'Previous Period', p_log_level_rec => p_log_level_rec);
               end if;

            end if;

         elsif (i = 1) then
            fa_amort_pvt.t_adjusted_cost(i) := 0;
            -- Bug5732277: Adding following to reflect adjusted_cost
            l_asset_fin_rec_new.adjusted_cost := fa_amort_pvt.t_adjusted_cost(i);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Resetting adjusted cost with ', '0', p_log_level_rec => p_log_level_rec);
            end if;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_adjusted_cost('||to_char(i)||')', fa_amort_pvt.t_adjusted_cost(i));
            fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost', l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
         end if;

      end if; -- (i = 1) or

      fa_amort_pvt.t_recoverable_cost(i) := fa_amort_pvt.t_cost(i) - fa_amort_pvt.t_salvage_value(i);
      fa_amort_pvt.t_adjusted_recoverable_cost(i) := fa_amort_pvt.t_cost(i) -
                                                      nvl(fa_amort_pvt.t_allowed_deprn_limit_amount(i),
                                                          fa_amort_pvt.t_salvage_value(i));

      fa_amort_pvt.t_date_placed_in_service(i) := nvl(p_asset_fin_rec_adj.date_placed_in_service,
                                                       fa_amort_pvt.t_date_placed_in_service(i));


      fa_amort_pvt.t_ytd_proceeds_of_sale(i) := fa_amort_pvt.t_ytd_proceeds_of_sale(i) +
                                                 nvl(p_asset_fin_rec_adj.ytd_proceeds, 0) +
                                                 l_proceeds_of_sale;

      fa_amort_pvt.t_ltd_proceeds_of_sale(i) := fa_amort_pvt.t_ltd_proceeds_of_sale(i) +
                                                 nvl(p_asset_fin_rec_adj.ltd_proceeds, 0) +
                                                 l_proceeds_of_sale;

      --
      -- Not Yet Implemented
      --
      fa_amort_pvt.t_ytd_cost_of_removal(i) := fa_amort_pvt.t_ytd_cost_of_removal(i) +
                                                nvl(p_asset_fin_rec_adj.ltd_cost_of_removal , 0) +
                                                l_cost_of_removal;

      fa_amort_pvt.t_ltd_cost_of_removal(i) := fa_amort_pvt.t_ltd_cost_of_removal(i) +
                                                nvl(p_asset_fin_rec_adj.ltd_cost_of_removal , 0) +
                                                l_cost_of_removal;


      fa_amort_pvt.t_unrevalued_cost(i) := fa_amort_pvt.t_unrevalued_cost(i) +
                                            nvl(p_asset_fin_rec_adj.unrevalued_cost, 0);

      fa_amort_pvt.t_reval_amortization_basis(i) := fa_amort_pvt.t_reval_amortization_basis(i) +
                                                     nvl(p_asset_fin_rec_adj.reval_amortization_basis, 0);


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Finish Populating Global Variables', ' ', p_log_level_rec => p_log_level_rec);
      end if;

      --   fa_amort_pvt.t_reval_ceiling(i) :=

      --   fa_amort_pvt.t_eofy_adj_cost(i) -- Unchanged
      --   fa_amort_pvt.t_eofy_formula_factor(i) Unchanged
      --   fa_amort_pvt.t_eofy_reserve(i) Unchanged
      if (i = 1) then
         fa_amort_pvt.t_eop_adj_cost(i)            := 0;
         fa_amort_pvt.t_eop_formula_factor(i)      := 1;

         fa_amort_pvt.t_eofy_adj_cost(i)           := 0;
         fa_amort_pvt.t_eofy_formula_factor(i)     := 1;
         fa_amort_pvt.t_eofy_reserve (i)           := nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);

      else
         fa_amort_pvt.t_eop_adj_cost(i)            := fa_amort_pvt.t_adjusted_cost(i - 1);
         fa_amort_pvt.t_eop_formula_factor(i)      := fa_amort_pvt.t_formula_factor(i - 1);

         if (fa_amort_pvt.t_period_num(i) = 1) then
            fa_amort_pvt.t_eofy_adj_cost(i)       := fa_amort_pvt.t_adjusted_cost(i - 1);
            fa_amort_pvt.t_eofy_formula_factor(i) := fa_amort_pvt.t_formula_factor(i - 1);
            fa_amort_pvt.t_eofy_reserve (i)       := fa_amort_pvt.t_deprn_reserve(i - 1) +
                                                     nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
         else
            fa_amort_pvt.t_eofy_adj_cost(i)       := fa_amort_pvt.t_eofy_adj_cost(i - 1);
            fa_amort_pvt.t_eofy_formula_factor(i) := fa_amort_pvt.t_eofy_formula_factor(i - 1);
            fa_amort_pvt.t_eofy_reserve (i)       := fa_amort_pvt.t_eofy_reserve(i - 1) +
                                                     nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
         end if;

      end if;


--tk_util.debug('l_bs_ind: '||to_char(l_bs_ind));
--tk_util.debug('l_asset_deprn_rec.deprn_reserve: '||to_char(l_asset_deprn_rec.deprn_reserve));
   --
   -- Proceed if the period being processed is not current period and depreciation
   -- has not been recalculated yet, or
   -- This is current period but has some transaction entered and requires to recalculate
   -- adjusted_cost.
   -- Bug7487450: following need to be true  if deprn basis is period update for cur period
   --
   if ((l_bs_ind <= i) and
       (fa_amort_pvt.t_period_counter(i) < p_period_rec.period_counter)) or
      ((fa_amort_pvt.t_period_counter(i) = p_period_rec.period_counter) and
       (   (fa_amort_pvt.t_reset_adjusted_cost_flag(i) = 'Y') or
        nvl(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') = 'Y'   )     )    then

      fa_amort_pvt.t_deprn_amount(i) := fa_amort_pvt.t_expense_adjustment_amount(i);
--tk_util.debug('l_trx_period_rec.period_counter: '||to_char(l_trx_period_rec.period_counter));
--tk_util.debug('fa_amort_pvt.t_period_counter(i): '||to_char(fa_amort_pvt.t_period_counter(i)));

      if (p_reclass_src_dest = 'SOURCE') and
         (l_trx_period_rec.period_counter = fa_amort_pvt.t_period_counter(i)) then
         if (i = 1) then
           null;
         else

           -- HHIRAGA Added code for current period reclass under tracking
           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: tracking_method', px_asset_fin_rec_new.tracking_method, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: l_trx_period_rec.period_counter', l_trx_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: l_current_period_counter', l_current_period_counter, p_log_level_rec => p_log_level_rec);
           end if;

           if nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'CALCULATE' and
              l_trx_period_rec.period_counter = l_current_period_counter then

              --115.211.211 branch to mainline porting starts
              --Bug6987743: member reserve should be taken out is passed form
              -- outside (source is fa_trx_references
              -- Reserve adjustment  amount has already been maintained before this line.
              --    x_deprn_reserve := (-1)*l_mem_deprn_reserve;

              x_deprn_reserve := (fa_amort_pvt.t_deprn_reserve(i - 1) - l_old_reserve);
              --115.211.211 branch to mainline porting ends
              fa_amort_pvt.t_reserve_adjustment_amount(i) :=
                 fa_amort_pvt.t_reserve_adjustment_amount(i) + x_deprn_reserve;

              fa_amort_pvt.t_eofy_reserve(i) := fa_amort_pvt.t_eofy_reserve(i) - l_mem_eofy_reserve;
              fa_amort_pvt.t_change_in_eofy_reserve(i) := (-1)* l_mem_eofy_reserve;

              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: x_deprn_reserve', x_deprn_reserve, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: reserve_adjustment_amount',
                                                           fa_amort_pvt.t_reserve_adjustment_amount(i));
              end if;

           elsif nvl(px_asset_fin_rec_new.tracking_method,'NULL') = 'ALLOCATE' and
              (l_mem_loop_first) then

              --115.211.211 branch to mainline porting starts
              --Bug6987743: member reserve should be taken out is passed form
              -- outside (source is fa_trx_references
              -- Reserve adjustment  amount has already been maintained before this line.

              if (fa_cache_pkg.fazcdbr_record.rule_name = 'ENERGY PERIOD END BALANCE') then
                  x_deprn_reserve := (-1)*l_mem_deprn_reserve;
              else
                  x_deprn_reserve := (fa_amort_pvt.t_deprn_reserve(i - 1) - l_old_reserve);
              end if;
              --115.211.211 branch to mainline porting ends
              fa_amort_pvt.t_reserve_adjustment_amount(i) :=
                 fa_amort_pvt.t_reserve_adjustment_amount(i) + x_deprn_reserve;

              fa_amort_pvt.t_eofy_reserve(i) := fa_amort_pvt.t_eofy_reserve(i) - l_mem_eofy_reserve;
              fa_amort_pvt.t_change_in_eofy_reserve(i) := (-1)* l_mem_eofy_reserve;
              l_mem_loop_first := FALSE;

              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: x_deprn_reserve', x_deprn_reserve, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: reserve_adjustment_amount',
                                                           fa_amort_pvt.t_reserve_adjustment_amount(i));
                fa_debug_pkg.add(l_calling_fn, 'HHIRAGA Debug: eofy_reserve',
                                                           fa_amort_pvt.t_eofy_reserve(i));
              end if;

           else
/* commented due to bug# 5601379
            fa_amort_pvt.t_reserve_adjustment_amount(i) :=
                 fa_amort_pvt.t_reserve_adjustment_amount(i) +
                 (fa_amort_pvt.t_deprn_reserve(i - 1) - l_old_reserve);        */
--tk_util.debug('l_old_reserve: '||to_char(l_old_reserve));
--tk_util.debug('t_deprn_reserve: '||to_char(fa_amort_pvt.t_deprn_reserve(i - 1)));
            x_deprn_reserve := (fa_amort_pvt.t_deprn_reserve(i - 1) - l_old_reserve);

           end if; -- End of HHIRAGA if-statement

            -- Bug7005716: Need to set previous periods amount back even in the period in loop is current period
            -- Bug3537474: Don't need to reset previous deprn info because this reclass is
            -- happens in period of member addition
            --
            -- Bug4328772:
            -- Commenting out following condition and replacing with a condition with the line below
--            if (p_reclassed_asset_dpis < fa_amort_pvt.t_calendar_period_open_date(l_count)) then
            if (l_trx_period_rec.period_counter <= fa_amort_pvt.t_period_counter(l_count)) then --115.211.211 branch to mainline porting
               fa_amort_pvt.t_ytd_deprn(i - 1)               := l_gr_asset_deprn_rec.ytd_deprn;
               fa_amort_pvt.t_deprn_reserve(i - 1)           := l_gr_asset_deprn_rec.deprn_reserve;
               fa_amort_pvt.t_bonus_ytd_deprn(i - 1)         := l_gr_asset_deprn_rec.bonus_ytd_deprn;
               fa_amort_pvt.t_bonus_deprn_reserve(i - 1)     := l_gr_asset_deprn_rec.bonus_deprn_reserve;
               fa_amort_pvt.t_ytd_impairment(i - 1)         := l_gr_asset_deprn_rec.ytd_impairment;
               fa_amort_pvt.t_impairment_reserve(i - 1)     := l_gr_asset_deprn_rec.impairment_reserve;
               fa_amort_pvt.t_ltd_production(i - 1)          := l_gr_asset_deprn_rec.ltd_production;
               fa_amort_pvt.t_ytd_production(i - 1)          := l_gr_asset_deprn_rec.ytd_production;
               fa_amort_pvt.t_ytd_reval_deprn_expense(i - 1) := l_gr_asset_deprn_rec.reval_ytd_deprn;
               fa_amort_pvt.t_reval_reserve(i - 1)           := l_gr_asset_deprn_rec.reval_deprn_reserve;
            end if;
         end if; -- (i = 1)
      end if; -- (p_reclass_src_dest = 'SOURCE') and

      if (i = 1) then
         l_eop_rec_cost := 0;
         l_eop_sal_val := 0;
         fa_amort_pvt.t_ytd_deprn(i)               := fa_amort_pvt.t_deprn_amount(i);
         fa_amort_pvt.t_deprn_reserve(i)           := fa_amort_pvt.t_deprn_amount(i) +
                                                       fa_amort_pvt.t_reserve_adjustment_amount(i);
         fa_amort_pvt.t_bonus_ytd_deprn(i)         := 0;
         fa_amort_pvt.t_bonus_deprn_reserve(i)     := 0;
         fa_amort_pvt.t_ytd_impairment(i)          := 0;
         fa_amort_pvt.t_impairment_reserve(i)      := 0;
         fa_amort_pvt.t_ltd_production(i)          := 0;
         fa_amort_pvt.t_ytd_production(i)          := 0;
         fa_amort_pvt.t_ytd_reval_deprn_expense(i) := 0;
         fa_amort_pvt.t_reval_reserve(i)           := 0;
      else
         l_eop_rec_cost := fa_amort_pvt.t_recoverable_cost(i - 1);
         l_eop_sal_val := fa_amort_pvt.t_salvage_value(i - 1);
         if (fa_amort_pvt.t_period_num(i) = 1) then
            fa_amort_pvt.t_ytd_deprn(i)               := fa_amort_pvt.t_deprn_amount(i);
            fa_amort_pvt.t_bonus_ytd_deprn(i)         := 0;
            fa_amort_pvt.t_ytd_impairment(i)          := 0;
            fa_amort_pvt.t_ytd_production(i)          := 0;
            fa_amort_pvt.t_ytd_reval_deprn_expense(i) := 0;
         else
            fa_amort_pvt.t_ytd_deprn(i)               := fa_amort_pvt.t_deprn_amount(i) +
                                                          fa_amort_pvt.t_ytd_deprn(i - 1);
            fa_amort_pvt.t_bonus_ytd_deprn(i)         := fa_amort_pvt.t_bonus_ytd_deprn(i - 1);
            fa_amort_pvt.t_ytd_impairment(i)          := fa_amort_pvt.t_ytd_impairment(i - 1);
            fa_amort_pvt.t_ytd_production(i)          := fa_amort_pvt.t_ltd_production(i - 1);
         fa_amort_pvt.t_ytd_reval_deprn_expense(i) := fa_amort_pvt.t_ytd_reval_deprn_expense(i - 1);

         end if;
--tk_util.debug('fa_amort_pvt.t_deprn_reserve(i - 1): '||to_char(fa_amort_pvt.t_deprn_reserve(i - 1)));
         fa_amort_pvt.t_deprn_reserve(i)           := fa_amort_pvt.t_deprn_amount(i) +
                                                       fa_amort_pvt.t_reserve_adjustment_amount(i) +
                                                       fa_amort_pvt.t_deprn_reserve(i - 1);
         fa_amort_pvt.t_bonus_deprn_reserve(i)     := fa_amort_pvt.t_bonus_deprn_reserve(i - 1);
         fa_amort_pvt.t_impairment_reserve(i)      := fa_amort_pvt.t_impairment_reserve(i - 1);
         fa_amort_pvt.t_ltd_production(i)          := fa_amort_pvt.t_ltd_production(i - 1);
         fa_amort_pvt.t_reval_reserve(i)           := fa_amort_pvt.t_reval_reserve(i - 1);

      end if;

/* TEST BY HH */
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'HH CHECK i =',
                                   i || 'at Line Number from 4555', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_deprn_amount(i)',
                                   fa_amort_pvt.t_deprn_amount(i));
                  if (i > 1) then
                     fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_deprn_reserve(i - 1)',
                                      fa_amort_pvt.t_deprn_reserve(i - 1));
                  end if;
                  fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_reserve_adjustment_amount(i)',
                                   fa_amort_pvt.t_reserve_adjustment_amount(i));
                  fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_deprn_reserve(i)',
                                   fa_amort_pvt.t_deprn_reserve(i));

               end if;
/* End of TEST BY HH */


         --
         -- Populate l_asset_deprn_rec with previous period information
         --
--         l_asset_deprn_rec := p_asset_deprn_rec;

         if (i = 1) then
            l_asset_deprn_rec.deprn_amount        := 0;
            l_asset_deprn_rec.ytd_deprn           := 0;
             l_asset_deprn_rec.deprn_reserve       := fa_amort_pvt.t_reserve_adjustment_amount(i) + fa_amort_pvt.t_expense_adjustment_amount(i); --Bug 8765715
            l_asset_deprn_rec.bonus_deprn_amount  := 0;
            l_asset_deprn_rec.bonus_ytd_deprn     := 0;
            l_asset_deprn_rec.bonus_deprn_reserve := 0;
            l_asset_deprn_rec.impairment_amount   := 0;
            l_asset_deprn_rec.ytd_impairment      := 0;
            l_asset_deprn_rec.impairment_reserve      := 0;
            l_asset_deprn_rec.ltd_production      := 0;
            l_asset_deprn_rec.ytd_production      := 0;
            l_asset_deprn_rec.production          := 0;
            l_asset_deprn_rec.reval_amortization  := 0;
            l_asset_deprn_rec.reval_deprn_expense := 0;
            l_asset_deprn_rec.reval_deprn_reserve := 0;
            l_asset_deprn_rec.reval_ytd_deprn     := 0;
         else
            l_asset_deprn_rec.deprn_amount        := fa_amort_pvt.t_deprn_amount(i);
            l_asset_deprn_rec.ytd_deprn           := fa_amort_pvt.t_ytd_deprn(i);
            l_asset_deprn_rec.deprn_reserve       := fa_amort_pvt.t_deprn_reserve(i);
            l_asset_deprn_rec.bonus_deprn_amount  := fa_amort_pvt.t_bonus_deprn_amount(i);
            l_asset_deprn_rec.bonus_ytd_deprn     := fa_amort_pvt.t_bonus_ytd_deprn(i);
            l_asset_deprn_rec.bonus_deprn_reserve := fa_amort_pvt.t_bonus_deprn_reserve(i);
            l_asset_deprn_rec.impairment_amount   := fa_amort_pvt.t_impairment_amount(i);
            l_asset_deprn_rec.ytd_impairment      := fa_amort_pvt.t_ytd_impairment(i);
            l_asset_deprn_rec.impairment_reserve      := fa_amort_pvt.t_impairment_reserve(i);
            l_asset_deprn_rec.ltd_production      := fa_amort_pvt.t_ltd_production(i);
            l_asset_deprn_rec.ytd_production      := fa_amort_pvt.t_ytd_production(i);
            l_asset_deprn_rec.production          := fa_amort_pvt.t_production(i);
            l_asset_deprn_rec.reval_amortization  := fa_amort_pvt.t_reval_amortization(i);
            l_asset_deprn_rec.reval_deprn_expense := fa_amort_pvt.t_reval_deprn_expense(i);
            l_asset_deprn_rec.reval_deprn_reserve := fa_amort_pvt.t_reval_reserve(i);
            l_asset_deprn_rec.reval_ytd_deprn     := fa_amort_pvt.t_ytd_reval_deprn_expense(i);
         end if;

         --
         -- Populate l_asset_fin_rec_new
         --
         l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(i);
         l_asset_fin_rec_new.salvage_value := fa_amort_pvt.t_salvage_value(i);
         l_asset_fin_rec_new.recoverable_cost := fa_amort_pvt.t_recoverable_cost(i);
         l_asset_fin_rec_new.deprn_method_code := fa_amort_pvt.t_deprn_method_code(i);
         l_asset_fin_rec_new.life_in_months := fa_amort_pvt.t_life_in_months(i);
         l_asset_fin_rec_new.group_asset_id := fa_amort_pvt.t_group_asset_id(i);
         l_asset_fin_rec_new.depreciate_flag := fa_amort_pvt.t_depreciate_flag(i);
         l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);
         l_asset_fin_rec_new.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(i);
         l_asset_fin_rec_new.formula_factor := fa_amort_pvt.t_formula_factor(i);
         l_asset_fin_rec_new.super_group_id := fa_amort_pvt.t_super_group_id(i);
         l_asset_fin_rec_new.adjusted_capacity := fa_amort_pvt.t_adjusted_capacity(i); --Bug 8477192

         l_dpr_in.asset_num := p_asset_desc_rec.asset_number;
         l_dpr_in.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
         l_dpr_in.book := p_asset_hdr_rec.book_type_code;
         l_dpr_in.asset_id := p_asset_hdr_rec.asset_id;

         l_dpr_in.adj_cost := fa_amort_pvt.t_recoverable_cost(i);
         l_dpr_in.rec_cost := fa_amort_pvt.t_recoverable_cost(i);
         l_dpr_in.reval_amo_basis := fa_amort_pvt.t_reval_amortization_basis(i);
         l_dpr_in.adj_rate := fa_amort_pvt.t_adjusted_rate(i);
         l_dpr_in.rate_adj_factor := 1;
         l_dpr_in.capacity := fa_amort_pvt.t_production_capacity(i);
         l_dpr_in.adj_capacity := fa_amort_pvt.t_adjusted_capacity(i);
         l_dpr_in.ltd_prod := 0;
         l_dpr_in.ytd_deprn := 0;    -- This needs to be 0 for this faxcde call
         l_dpr_in.deprn_rsv := 0;
         l_dpr_in.reval_rsv := l_asset_deprn_rec.reval_deprn_reserve;
         l_dpr_in.bonus_deprn_exp := l_asset_deprn_rec.bonus_deprn_amount;
         l_dpr_in.bonus_ytd_deprn := l_asset_deprn_rec.bonus_ytd_deprn;
         l_dpr_in.bonus_deprn_rsv := l_asset_deprn_rec.bonus_deprn_reserve;
         l_dpr_in.impairment_exp := l_asset_deprn_rec.impairment_amount;
         l_dpr_in.ytd_impairment := l_asset_deprn_rec.ytd_impairment;
         l_dpr_in.impairment_rsv := l_asset_deprn_rec.impairment_reserve;
         l_dpr_in.prior_fy_bonus_exp := l_asset_deprn_rec.prior_fy_bonus_expense;
         l_dpr_in.impairment_exp := l_asset_deprn_rec.impairment_amount;
         l_dpr_in.ytd_impairment := l_asset_deprn_rec.ytd_impairment;
         l_dpr_in.impairment_rsv := l_asset_deprn_rec.impairment_reserve;

         l_dpr_in.ceil_name := fa_amort_pvt.t_ceiling_name(i);
         l_dpr_in.bonus_rule := fa_amort_pvt.t_bonus_rule(i);
         l_dpr_in.method_code := fa_amort_pvt.t_deprn_method_code(i);
         l_dpr_in.jdate_in_service :=
                to_number(to_char(fa_amort_pvt.t_date_placed_in_service(i), 'J'));
         --
         -- Use dpis as prorate and deprn start date
         -- This is ok since this code is only for group now
         -- Need to pass actual prorate/deprn start date if this code is open for standalone assets
         --
         l_dpr_in.prorate_jdate := to_number(to_char(fa_amort_pvt.t_date_placed_in_service(i), 'J'));
         l_dpr_in.deprn_start_jdate :=
                to_number(to_char(fa_amort_pvt.t_date_placed_in_service(i), 'J'));
         l_dpr_in.prorate_date := fa_amort_pvt.t_date_placed_in_service(i);
         l_dpr_in.orig_deprn_start_date := fa_amort_pvt.t_date_placed_in_service(i);


         l_dpr_in.jdate_retired := 0; -- don't know this is correct or not
         l_dpr_in.ret_prorate_jdate := 0; -- don't know this is correct or not
         l_dpr_in.life := fa_amort_pvt.t_life_in_months(i);

         l_dpr_in.rsv_known_flag := TRUE;
         l_dpr_in.salvage_value := fa_amort_pvt.t_salvage_value(i);

         l_dpr_in.adj_rec_cost := fa_amort_pvt.t_adjusted_recoverable_cost(i);
         l_dpr_in.prior_fy_exp := 0;                 -- This needs to be 0 for this faxcde call

         l_dpr_in.short_fiscal_year_flag := fa_amort_pvt.t_short_fiscal_year_flag(i);

         l_dpr_in.old_adj_cost := fa_amort_pvt.t_adjusted_cost(i);
         l_dpr_in.formula_factor := fa_amort_pvt.t_formula_factor(i);

         l_dpr_in.super_group_id := fa_amort_pvt.t_super_group_id(i);
         l_dpr_in.over_depreciate_option := fa_amort_pvt.t_over_depreciate_option(i);

         --
         -- These values are not stored in Books_Summary since these value won't be
         -- Changed over periods.
         --
         l_dpr_in.tracking_method := px_asset_fin_rec_new.tracking_method;
         l_dpr_in.allocate_to_fully_ret_flag := px_asset_fin_rec_new.allocate_to_fully_ret_flag;
         l_dpr_in.allocate_to_fully_rsv_flag := px_asset_fin_rec_new.allocate_to_fully_rsv_flag;
         l_dpr_in.excess_allocation_option := px_asset_fin_rec_new.excess_allocation_option;
         l_dpr_in.depreciation_option := px_asset_fin_rec_new.depreciation_option;
         l_dpr_in.member_rollup_flag := px_asset_fin_rec_new.member_rollup_flag;
         l_dpr_in.mrc_sob_type_code := p_mrc_sob_type_code;
         l_dpr_in.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

         --
         -- There is no plane to store following variables in books summary now
         -- so copy value from fin_rec_new
         l_dpr_in.pc_life_end := px_asset_fin_rec_new.period_counter_life_complete;
         l_dpr_in.conversion_date := px_asset_fin_rec_new.conversion_date;


         --
         -- Following may needed to be added and implemented in Books Summary
         -- 'ADJ' for now
         --
         l_dpr_in.deprn_rounding_flag := 'ADJ';


         l_dpr_in.deprn_override_flag := p_trans_rec.deprn_override_flag;
         l_dpr_in.used_by_adjustment := TRUE;


         --
         -- Not for what-if yet
         --
         l_running_mode := fa_std_types.FA_DPR_NORMAL;


         if (not fa_cache_pkg.fazccmt(
                 fa_amort_pvt.t_deprn_method_code(i),
                 fa_amort_pvt.t_life_in_months(i),
                 p_log_level_rec)) then
            if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                       'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            end if;

            raise calc_failed;
         end if;

         if i = 1 then
            if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                       fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                       l_dpr_in.prorate_jdate,
                                       g_temp_number,
                                       l_dpr_in.y_begin,
                                       g_temp_integer, p_log_level_rec => p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                   fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                   fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);

               end if;

               raise calc_failed;
            end if;
         end if;

         --
         -- Skip faxcde call for raf
         -- If rate source rule is FLAT and depreciable basis is Cost
         -- Bug4778244 Added the NVL to avoid condition if(not(null or false)) which will
         -- always return NULL in place of FALSE, which is incorrect
         -- Bug7487450: Skip hypo reserve calculation if it is UOP
         if (not (nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') = fa_std_types.FAD_RSR_PROD)) and
            (not((nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') = fa_std_types.FAD_RSR_FLAT) and
                 (nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule,' ') = fa_std_types.FAD_DBR_COST) and
                 (nvl(fa_cache_pkg.fazcdbr_record.rule_name, ' ')  in ('PERIOD END BALANCE',
                                                                       'PERIOD END AVERAGE',
                                                                       'USE RECOVERABLE COST',
                                                                       'BEGINNING PERIOD')))) then

         if (fa_amort_pvt.t_reset_adjusted_cost_flag(i) = 'Y') or
 	             nvl(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') = 'Y' then
            if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                       fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                       l_dpr_in.prorate_jdate,
                                       g_temp_number,
                                       l_dpr_in.y_begin,
                                       g_temp_integer, p_log_level_rec => p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                   fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                   fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);

               end if;

               raise calc_failed;
            end if;

            l_dpr_in.p_cl_begin := 1;

            if (fa_amort_pvt.t_period_num(i) = 1) then
               l_dpr_in.y_end := fa_amort_pvt.t_fiscal_year(i) - 1;
               l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
            else
               l_dpr_in.y_end := fa_amort_pvt.t_fiscal_year(i);
               l_dpr_in.p_cl_end := fa_amort_pvt.t_period_num(i) - 1;
            end if;

            l_dpr_in.rate_adj_factor := 1;

            -- manual override
            if fa_cache_pkg.fa_deprn_override_enabled then

               l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
               l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

               -- update override status only if satisfies condintion,
               -- otherwise do not update status when calculating RAF
               -- 1. formula; or
               -- 2. (calc or table) and cost

               l_dpr_in.update_override_status :=
                  ((l_rate_source_rule = fa_std_types.FAD_RSR_FORMULA)
                  OR (((l_rate_source_rule = fa_std_types.FAD_RSR_CALC)
                  OR (l_rate_source_rule = fa_std_types.FAD_RSR_TABLE))
                  AND (l_deprn_basis_rule = fa_std_types.FAD_DBR_COST)));
            end if;

            --* HHIRAGA modified on Oct/Nov in 2003.
            -- Changed parameter to period counter when the recalculation of
            -- RAF needs.
            -- This function will populates all member assets to be used to
            -- hypothetical allocation internally.
            --
            --+++++++ Call Tracking Function to populate Member in case ALLOCATE ++++++
            if p_asset_type_rec.asset_type = 'GROUP' and
               nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then

               l_raf_processed_flag := TRUE;
               l_dpr_in.tracking_method := NULL;

/*
               if not FA_TRACK_MEMBER_PVT.get_member_at_start(
                       p_period_rec => l_period_rec,
                       p_trans_rec => p_trans_rec,
                       p_asset_hdr_rec => p_asset_hdr_rec,
                       p_asset_fin_rec => px_asset_fin_rec_new,
                       p_dpr_in => l_dpr_in,
                       p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn, 'Error calling', 'FA_TRACK_MEMBER_PVT.get_member_at_start',  p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;

               end if;
*/
            end if; -- nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE'

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, ' Call ', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
            end if;

            --+++++++ Call Depreciation engine for rate adjustment factor +++++++
            if not FA_CDE_PKG.faxcde(l_dpr_in,
                                     l_dpr_arr,
                                     l_dpr_out,
                                     l_running_mode, p_log_level_rec => p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                       'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_deprn_rsv',
                          l_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
            end if;

            -- manual override
            if fa_cache_pkg.fa_deprn_override_enabled then
               if l_dpr_in.update_override_status then
                  p_trans_rec.deprn_override_flag := l_dpr_out.deprn_override_flag;
               else
                  p_trans_rec.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
               end if;
            end if;

            l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
            l_asset_fin_rec_new.reval_amortization_basis := l_dpr_out.new_reval_amo_basis;
            l_asset_deprn_rec_raf.deprn_reserve := l_dpr_out.new_deprn_rsv;
            l_asset_deprn_rec_raf.reval_deprn_reserve := l_dpr_out.new_reval_rsv;
            l_asset_fin_rec_new.adjusted_capacity := l_asset_fin_rec_new.production_capacity -
                                   l_dpr_out.new_ltd_prod;
            l_asset_deprn_rec_raf.ltd_production := l_dpr_out.new_ltd_prod;
            l_asset_deprn_rec_raf.prior_fy_expense := l_dpr_out.new_prior_fy_exp;
            l_asset_deprn_rec_raf.bonus_deprn_amount := l_dpr_out.bonus_deprn_exp;
            l_asset_deprn_rec_raf.bonus_deprn_reserve := l_dpr_out.new_bonus_deprn_rsv;
            l_asset_deprn_rec_raf.impairment_amount := l_dpr_out.impairment_exp;
            l_asset_deprn_rec_raf.impairment_reserve := l_dpr_out.new_impairment_rsv;
            l_asset_deprn_rec_raf.prior_fy_bonus_expense := l_dpr_out.new_prior_fy_bonus_exp;

            -- HHIRAGA
            --++++++++ Tracking=ALLOCATE case ++++++++++++++
            if (l_raf_processed_flag) then
               l_dpr_in.tracking_method := 'ALLOCATE';
               l_raf_processed_flag := FALSE;
            end if;

            if nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then

               fa_track_member_pvt.p_track_member_table.delete;
               fa_track_member_pvt.p_track_mem_index_table.delete;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'fa_track_member_pvt.p_track_member_table',
                               'deleted',  p_log_level_rec => p_log_level_rec);
               end if;
            end if;
         end if;

         else
            l_asset_fin_rec_new.adjusted_cost := l_asset_fin_rec_new.recoverable_cost;
         end if; ---- skip faxcde call for raf


         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, ' Call ',
                       'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.transaction_type_code',
                       p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_trans_rec.transaction_type_code',
                       l_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.eofy_reserve',
                       l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve',
                       l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.bonus_deprn_reserve',
                       l_asset_deprn_rec.bonus_deprn_reserve, p_log_level_rec => p_log_level_rec);
         end if;

            --* HHIRAGA modified on OCT/NOV in 2003
            -- Prepare memory table to be able to process depreciation recalculation
            -- This function should be called only when memory table has not been populated.
            -- if l_processed_flag is FALSE, process this preparation function
            if p_asset_type_rec.asset_type = 'GROUP' and
               nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then

               l_no_allocation_for_last := 'Y';
               if (fa_amort_pvt.t_reset_adjusted_cost_flag(i) = 'Y') and
                  (not (l_first_process)
                  and p_trans_rec.transaction_type_code = 'GROUP ADDITION') then

                 l_no_allocation_for_last := 'N';
                 if fa_amort_pvt.t_period_num(i) = 1 then
                   l_recalc_start_fy := fa_amort_pvt.t_fiscal_year(i) - 1;
                   l_recalc_start_period_num := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                 else
                   l_recalc_start_fy := fa_amort_pvt.t_fiscal_year(i);
                   l_recalc_start_period_num := fa_amort_pvt.t_period_num(i) - 1;
                 end if;

                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, '++++ Call ++++', 'FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE',  p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_reset_adjusted_cost_flag(i)',
                                                              fa_amort_pvt.t_reset_adjusted_cost_flag(i));
                   fa_debug_pkg.add(l_calling_fn, 'l_recalc_start_fy', l_recalc_start_fy, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add(l_calling_fn, 'l_recalc_start_period_num', l_recalc_start_period_num, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add(l_calling_fn, 'l_old_recalc_end_fy', l_old_recalc_end_fy, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add(l_calling_fn, 'l_old_recalc_end_period_num', l_old_recalc_end_period_num, p_log_level_rec => p_log_level_rec);
                 end if;

                 if (nvl(l_old_recalc_end_fy,l_recalc_start_fy) = l_recalc_start_fy and
                     nvl(l_old_recalc_end_period_num,l_recalc_start_period_num+1) <> l_recalc_start_period_num) then
                   l_backup_processed_flag := FALSE;
                 elsif (l_backup_processed_flag) then
                   l_recalc_start_fy := fa_amort_pvt.t_fiscal_year(i);
                   l_recalc_start_period_num := fa_amort_pvt.t_period_num(i);
                 end if;

               else

                   l_recalc_start_fy := fa_amort_pvt.t_fiscal_year(i);
                   l_recalc_start_period_num := fa_amort_pvt.t_period_num(i);

                   l_processed_flag := TRUE;
                   fa_track_member_pvt.l_process_deprn_for_member := 'NO';
/*
                   l_asset_fin_rec_new.tracking_method := NULL;
                   l_asset_fin_rec_old.tracking_method := NULL;
*/

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, '++++ Call ++++', 'FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE',  p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_reset_adjusted_cost_flag(i)',
                                                               fa_amort_pvt.t_reset_adjusted_cost_flag(i));
                     fa_debug_pkg.add(l_calling_fn, 'l_recalc_start_fy', l_recalc_start_fy, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'l_recalc_start_period_num', l_recalc_start_period_num, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'l_old_recalc_end_fy', l_old_recalc_end_fy, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'l_old_recalc_end_period_num', l_old_recalc_end_period_num, p_log_level_rec => p_log_level_rec);
                  end if;

                 if l_old_recalc_end_fy is not NULL and l_old_recalc_end_period_num is not NULL then
                   if l_old_recalc_end_period_num = fa_cache_pkg.fazcct_record.number_per_fiscal_year then
                     l_old_recalc_end_fy := l_old_recalc_end_fy + 1;
                     l_old_recalc_end_period_num := 1;
                   else
                     l_old_recalc_end_period_num := l_old_recalc_end_period_num + 1;
                   end if;
                 end if;

                 if (nvl(l_old_recalc_end_fy,l_recalc_start_fy) = l_recalc_start_fy and
                     nvl(l_old_recalc_end_period_num,l_recalc_start_period_num+1) <> l_recalc_start_period_num) then
                   l_backup_processed_flag := FALSE;
                 end if;

               end if;

               --* Calcualte recalc_start_period_counter
               if (l_first_process) then
                  l_recalc_start_period_counter := l_recalc_start_fy*(fa_cache_pkg.fazcct_record.number_per_fiscal_year)
                                                                                         + l_recalc_start_period_num;

                  if p_mrc_sob_type_code <> 'R' then
                    open c_chk_bs_row_exists;
                    fetch c_chk_bs_row_exists into l_chk_bs_row_exists;
                    if c_chk_bs_row_exists%FOUND then
                      if not FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE
                                         (p_asset_hdr_rec => p_asset_hdr_rec,
                                          p_asset_fin_rec_new => px_asset_fin_rec_new,
                                          p_populate_for_recalc_period => 'T',
                                          p_amort_start_date => l_transaction_date_entered,
                                          p_recalc_start_fy => l_recalc_start_fy,
                                          p_recalc_start_period_num => l_recalc_start_period_num,
                                          p_no_allocation_for_last => l_no_allocation_for_last,
                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                        if (p_log_level_rec.statement_level) then
                          fa_debug_pkg.add(l_calling_fn, 'Error calling', 'POPULATE_MEMBER_ASSETS_TABLE', p_log_level_rec => p_log_level_rec);
                        end if;
                        raise calc_failed;
                      end if;
                    else
                      if not FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE
                                         (p_asset_hdr_rec => p_asset_hdr_rec,
                                          p_asset_fin_rec_new => px_asset_fin_rec_new,
                                          p_amort_start_date => l_transaction_date_entered,
                                          p_recalc_start_fy => l_recalc_start_fy,
                                          p_recalc_start_period_num => l_recalc_start_period_num,
                                          p_no_allocation_for_last => l_no_allocation_for_last,
                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                        if (p_log_level_rec.statement_level) then
                          fa_debug_pkg.add(l_calling_fn, 'Error calling', 'POPULATE_MEMBER_ASSETS_TABLE', p_log_level_rec => p_log_level_rec);
                        end if;
                        raise calc_failed;
                      end if;
                    end if;
                    close c_chk_bs_row_exists;

                  else -- MRC

                    open c_chk_bs_row_exists_mrc;
                    fetch c_chk_bs_row_exists_mrc into l_chk_bs_row_exists;
                    if c_chk_bs_row_exists_mrc%FOUND then
                      if not FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE
                                         (p_asset_hdr_rec => p_asset_hdr_rec,
                                          p_asset_fin_rec_new => px_asset_fin_rec_new,
                                          p_populate_for_recalc_period => 'T',
                                          p_amort_start_date => l_transaction_date_entered,
                                          p_recalc_start_fy => l_recalc_start_fy,
                                          p_recalc_start_period_num => l_recalc_start_period_num,
                                          p_no_allocation_for_last => l_no_allocation_for_last,
                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                        if (p_log_level_rec.statement_level) then
                          fa_debug_pkg.add(l_calling_fn, 'Error calling', 'POPULATE_MEMBER_ASSETS_TABLE', p_log_level_rec => p_log_level_rec);
                        end if;
                        raise calc_failed;
                      end if;
                    else
                      if not FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE
                                         (p_asset_hdr_rec => p_asset_hdr_rec,
                                          p_asset_fin_rec_new => px_asset_fin_rec_new,
                                          p_amort_start_date => l_transaction_date_entered,
                                          p_recalc_start_fy => l_recalc_start_fy,
                                          p_recalc_start_period_num => l_recalc_start_period_num,
                                          p_no_allocation_for_last => l_no_allocation_for_last,
                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                        if (p_log_level_rec.statement_level) then
                          fa_debug_pkg.add(l_calling_fn, 'Error calling', 'POPULATE_MEMBER_ASSETS_TABLE', p_log_level_rec => p_log_level_rec);
                        end if;
                        raise calc_failed;
                      end if;
                    end if;
                    close c_chk_bs_row_exists_mrc;
                   end if; -- MRC or Primary
                  l_old_recalc_start_fy := l_recalc_start_fy;
                  l_old_recalc_start_period_num := l_recalc_start_period_num;

               else

                 l_old_recalc_start_fy := l_recalc_start_fy;
                 l_old_recalc_start_period_num := l_recalc_start_period_num;

                 if not (l_backup_processed_flag) then
                   if not FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE
                                         (p_asset_hdr_rec => p_asset_hdr_rec,
                                          p_asset_fin_rec_new => px_asset_fin_rec_new,
                                          p_amort_start_date => l_transaction_date_entered,
                                          p_recalc_start_fy => l_recalc_start_fy,
                                          p_recalc_start_period_num => l_recalc_start_period_num,
                                          p_no_allocation_for_last => l_no_allocation_for_last,
                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn, 'Error calling', 'POPULATE_MEMBER_ASSETS_TABLE', p_log_level_rec => p_log_level_rec);
                     end if;
                     raise calc_failed;
                   end if;

                 else

                   if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, '##### bakcup table counter #####',
                                fa_track_member_pvt.p_track_member_table_for_deprn.COUNT,  p_log_level_rec => p_log_level_rec);
                   end if;

                   if not FA_TRACK_MEMBER_PVT.copy_member_table(p_backup_restore => 'RESTORE', p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn, 'Error calling', 'COPY_MEMBER_TABLE', p_log_level_rec => p_log_level_rec);
                     end if;
                     raise calc_failed;
                   end if;

                   --* Calculate only for this period
                   if not FA_TRACK_MEMBER_PVT.POPULATE_MEMBER_ASSETS_TABLE
                                         (p_asset_hdr_rec => p_asset_hdr_rec,
                                          p_asset_fin_rec_new => px_asset_fin_rec_new,
                                          p_populate_for_recalc_period => 'Y',
                                          p_amort_start_date => l_transaction_date_entered,
                                          p_recalc_start_fy => l_recalc_start_fy,
                                          p_recalc_start_period_num => l_recalc_start_period_num,
                                          p_no_allocation_for_last => 'Y',
                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                   if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling', 'POPULATE_MEMBER_ASSETS_TABLE', p_log_level_rec => p_log_level_rec);
                   end if;
                   raise calc_failed;
                 end if;

                 l_processed_flag := TRUE;
                 fa_track_member_pvt.l_process_deprn_for_member := 'NO';

               end if; -- IF not (l_backup_processed_flag)

             end if;  -- l_first_process_flag

             if (l_first_process) then
               l_first_process := FALSE;
             end if;


            end if; -- HHIRAGA if-statement

   --
   -- From old fin rec followings are necessary
   -- formula_factor
   -- rate_adjustment_factor
   -- adjusted_cost
   -- cost
   --
   -- From new fin rec followings are necessary
   -- Method
   -- life
   -- group asset id
   -- depreciate_flag
   -- cost
   -- salvage_value
   -- recoverable_cost
   -- reduction_rate
   -- eofy_reserve
   -- recognize_gain_loss
   -- tracking_method
   -- allocate_to_fully_rsv_flag
   -- allocate_to_fully_ret_flag
   -- excess_allocation_option
   -- depreciation_option
   -- member_rollup_flag

      if (fa_cache_pkg.fazcdbr_record.rule_name = 'ENERGY PERIOD END BALANCE') and
         (p_asset_fin_rec_old.tracking_method = 'ALLOCATE') and
         (p_trans_rec.transaction_key = 'MS') then
         l_reserve_retired := 0;
      end if;

         --
         -- reset_adjusted_cost_flag can be no or null in case
         -- this is reclass source group.
         -- otherwise, deprn basis rule function gets called all the time
         -- if process reaches here.
         -- Bug7487450: need to call below if deprn basis is period update
         --
         if (fa_amort_pvt.t_reset_adjusted_cost_flag(i) = 'Y') or
            nvl(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') = 'Y' then
            if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                                (p_event_type             => 'AMORT_ADJ',
                                 p_asset_fin_rec_new      => l_asset_fin_rec_new,
                                 p_asset_fin_rec_old      => l_asset_fin_rec_old,
                                 p_asset_hdr_rec          => p_asset_hdr_rec,
                                 p_asset_type_rec         => p_asset_type_rec,
                                 p_asset_deprn_rec        => l_asset_deprn_rec,
                                 p_trans_rec              => p_trans_rec,
                                 p_trans_rec_adj          => l_trans_rec,
                                 p_period_rec             => l_period_rec,
                                 p_current_total_rsv      => l_asset_deprn_rec.deprn_reserve,
                                 p_current_rsv            => l_asset_deprn_rec.deprn_reserve -
                                                             nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) - nvl(l_asset_deprn_rec.impairment_reserve, 0),
                                 p_current_total_ytd      => l_asset_deprn_rec.ytd_deprn,
                                 p_adj_reserve            => p_asset_deprn_rec_adj.deprn_reserve,
                                 p_reserve_retired        => l_reserve_retired,
                                 p_hyp_basis              => l_asset_fin_rec_new.adjusted_cost,
                                 p_hyp_total_rsv          => l_asset_deprn_rec_raf.deprn_reserve,
                                 p_hyp_rsv                => l_asset_deprn_rec_raf.deprn_reserve -
                                                             nvl(l_asset_deprn_rec_raf.bonus_deprn_reserve, 0) - nvl(l_asset_deprn_rec_raf.impairment_reserve,0),
                                 p_eofy_recoverable_cost  => l_eofy_rec_cost,
                                 p_eop_recoverable_cost   => l_eop_rec_cost,
                                 p_eofy_salvage_value     => l_eofy_sal_val,
                                 p_eop_salvage_value      => l_eop_sal_val,
                                 p_mrc_sob_type_code      => p_mrc_sob_type_code,
                                 p_used_by_adjustment     => 'ADJUSTMENT',
                                 px_new_adjusted_cost     => l_asset_fin_rec_new.adjusted_cost,
                                 px_new_raf               => l_asset_fin_rec_new.rate_adjustment_factor,
                                 px_new_formula_factor    => l_asset_fin_rec_new.formula_factor,
                                 p_log_level_rec       => p_log_level_rec)) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            fa_amort_pvt.t_adjusted_cost(i) := l_asset_fin_rec_new.adjusted_cost;
            fa_amort_pvt.t_rate_adjustment_factor(i) := l_asset_fin_rec_new.rate_adjustment_factor;
            fa_amort_pvt.t_formula_factor(i) := l_asset_fin_rec_new.formula_factor;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Returned values from ',
                                'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost',
                                l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.rate_adjustment_factor',
                                l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.formula_factor',
                                l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
            end if;
         else
            --
            -- Adjusted_cost and formula_factor are setup in last faxcde call so skipping
            -- deprn basis call should require no action
            --
            fa_amort_pvt.t_rate_adjustment_factor(i) := fa_amort_pvt.t_rate_adjustment_factor(i-1);
         end if;

         --* HHIRAGA - Tracking Test

         if (l_processed_flag) then
           fa_track_member_pvt.l_process_deprn_for_member := 'YES';
           l_processed_flag := FALSE;
         end if;

         --
         -- Now this is current period, so don't need to run depreciation
         --
--tk_util.debug('l_count - l_bs_ind + 1: '||to_char(l_count - l_bs_ind + 1)||':'||to_char(i));

         if (fa_amort_pvt.t_period_counter(i) = p_period_rec.period_counter) then

--tk_util.debug('Exit');
            EXIT;
         end if;

         --
         -- Run Depreciation if:
         --  - next available transaction (in table) is NOT the same period
         --  - This is the last transaction to recalculate which is not in
         --    current period.
         --  - This is the last trnsaction because of the limit specified
         --    at BULK fetch above. (Inside of following if clause, try to get
         --    next transaction from database and determine if depreciation needs
         --    to be called or not.
         --
--tk_util.debug('l_period_rec.period_counter: '||to_char(l_period_rec.period_counter));
--tk_util.debug('fa_amort_pvt.t_period_counter: '||to_char(fa_amort_pvt.t_period_counter(i)));

--         if (p_period_rec.period_counter <> fa_amort_pvt.t_period_counter(i)) or
--            (px_asset_fin_rec_new.depreciate_flag = 'NO' or
--             px_asset_fin_rec_new.disabled_flag = 'Y') then

         if (p_period_rec.period_counter <> fa_amort_pvt.t_period_counter(i)) and
            (not (fa_amort_pvt.t_depreciate_flag(i) = 'NO' or
                  nvl(px_asset_fin_rec_new.disabled_flag, 'N') = 'Y')) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Run Depreciation ', i, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_period_rec.period_counter',
                                l_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'p_period_rec.period_counter',
                                p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            end if;

            -- look for next period which requires adjusted_cost reset.
            -- Find out the period and run depreciation a period before the
            -- found period.  If there isn't one, run depreciation until the end
            l_adjusted_ind := 0;

--tk_util.debug('i and count: '||to_char(i)||':'||to_char(l_count));

            --
            -- In case of destination asset for reclass transaction, this loop needs to find
            -- the period which will have t_reset_adjusted_cost_flag = 'Y' but not reflected
            -- yet.
            e := d;
            if (p_reclass_src_dest = 'DESTINATION') then
               FOR j in (i + 1)..(l_count) LOOP
                  l_adjusted_ind := l_adjusted_ind + 1;
                  e := e + 1;

--tk_util.debug('reset_adjusted_cost_flag: '||fa_amort_pvt.t_reset_adjusted_cost_flag(j));
--tk_util.debug('cost(e):salvage_value(e):cip_cost(e):deprn_limit_amount(e):'||to_char(td_cost(e))||':'||to_char(td_salvage_value(e))||':'||to_char(td_cip_cost(e))||':'||to_char(td_deprn_limit_amount(e)));

                  --
                  -- Needed to use (e - 1) for sal and limit because delta table
                  -- contains actual amounts for these values since there is no chagne
                  -- in columns for these values.
                  --
                  if (fa_amort_pvt.t_reset_adjusted_cost_flag(j) = 'Y') or
                     (j = (l_count)) or
                     (td_cost(e) <> 0) or
                     ((td_salvage_value(e) - td_salvage_value(e - 1)) <> 0) or
                     (td_cip_cost(e) <> 0) or
                     ((td_deprn_limit_amount(e) - td_deprn_limit_amount(e - 1)) <> 0) then

                     if (fa_amort_pvt.t_period_num(j) = 1) then
                        l_fiscal_year := fa_amort_pvt.t_fiscal_year(j) - 1;
                        l_period_num := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                     else
                        l_fiscal_year := fa_amort_pvt.t_fiscal_year(j);
                        l_period_num := fa_amort_pvt.t_period_num(j) - 1;
                     end if;

                     l_period_counter := fa_amort_pvt.t_period_counter(j) - 1;
                     EXIT;
                  end if;

               END LOOP;
            else
               FOR j in (i + 1)..(l_count) LOOP
                  l_adjusted_ind := l_adjusted_ind + 1;

--tk_util.debug('reset_adjusted_cost_flag: '||fa_amort_pvt.t_reset_adjusted_cost_flag(j));

                  if (fa_amort_pvt.t_reset_adjusted_cost_flag(j) = 'Y') or
                     (j = (l_count)) then
                     if (fa_amort_pvt.t_period_num(j) = 1) then
                        l_fiscal_year := fa_amort_pvt.t_fiscal_year(j) - 1;
                        l_period_num := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                     else
                        l_fiscal_year := fa_amort_pvt.t_fiscal_year(j);
                        l_period_num := fa_amort_pvt.t_period_num(j) - 1;
                     end if;

                     l_period_counter := fa_amort_pvt.t_period_counter(j) - 1;
                     EXIT;
                  end if;

               END LOOP;
            end if;
--tk_util.debug('fy:pn: '||to_char(l_fiscal_year)||':'||to_char(l_period_num));

            --
            -- Prepare Running Depreciation
            --
            l_dpr_in.y_begin := fa_amort_pvt.t_fiscal_year(i);
            l_dpr_in.p_cl_begin := fa_amort_pvt.t_period_num(i);
            l_dpr_in.y_end := l_fiscal_year;
            l_dpr_in.p_cl_end := l_period_num;

            -- HHIRAGA set loop ended period
            l_old_recalc_end_fy := l_dpr_in.y_end;
            l_old_recalc_end_period_num := l_dpr_in.p_cl_end;
            --

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Depreciation starts from period of ', l_dpr_in.p_cl_begin, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'and year of ', l_dpr_in.y_begin, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'Depreciation will end at period of ', l_dpr_in.p_cl_end, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'and year of ', l_dpr_in.y_end, p_log_level_rec => p_log_level_rec);
            end if;

            if (fa_amort_pvt.t_period_num(i) <> 1) then
               l_dpr_in.deprn_rounding_flag := 'ADJ';
            end if;

            l_dpr_in.prior_fy_exp := l_asset_deprn_rec.prior_fy_expense;
            l_dpr_in.ytd_deprn := l_asset_deprn_rec.ytd_deprn;
            l_dpr_in.deprn_rsv := l_asset_deprn_rec.deprn_reserve;
            l_dpr_in.adj_cost := l_asset_fin_rec_new.adjusted_cost;
            l_dpr_in.eofy_reserve := l_asset_fin_rec_new.eofy_reserve;
            l_dpr_in.rate_adj_factor := l_asset_fin_rec_new.rate_adjustment_factor;
            l_dpr_in.formula_factor := l_asset_fin_rec_new.formula_factor;
            l_dpr_in.super_group_id := l_asset_fin_rec_new.super_group_id;
--tk_util.debug('l_dpr_in.super_group_id: '||to_char(l_dpr_in.super_group_id));
            l_dpr_in.cost := l_asset_fin_rec_new.cost;

           l_dpr_in.mrc_sob_type_code := p_mrc_sob_type_code;
           l_dpr_in.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

            -- manual override
            if fa_cache_pkg.fa_deprn_override_enabled then
               l_dpr_in.update_override_status := TRUE;
            end if;

            --
            -- Running Depreciation
            --
   --tk_util.debug('i: '||to_char(i));

            if not FA_CDE_PKG.faxcde(l_dpr_in,
                                     l_dpr_arr,
                                     l_dpr_out,
                                     l_running_mode,
                                     i, p_log_level_rec => p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_ytd_deprn',
                                l_dpr_out.new_ytd_deprn, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_deprn_rsv',
                                l_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
            end if;

            -- manual override
            if fa_cache_pkg.fa_deprn_override_enabled then
               p_trans_rec.deprn_override_flag := l_dpr_out.deprn_override_flag;
            end if;

            if (l_asset_fin_rec_new.adjusted_cost <> 0) or
               (l_dpr_out.new_adj_cost <> 0) then
               l_asset_fin_rec_new.reval_amortization_basis := l_dpr_out.new_reval_amo_basis;
               l_asset_deprn_rec.deprn_reserve := l_dpr_out.new_deprn_rsv;
               l_asset_deprn_rec.ytd_deprn := l_dpr_out.new_ytd_deprn;
               l_asset_deprn_rec.reval_deprn_reserve := l_dpr_out.new_reval_rsv;
               l_asset_fin_rec_new.adjusted_capacity := l_dpr_out.new_adj_capacity;
               l_asset_deprn_rec.ltd_production := l_dpr_out.new_ltd_prod;
               l_asset_fin_rec_new.eofy_reserve := l_dpr_out.new_eofy_reserve;

               l_asset_deprn_rec.prior_fy_expense := l_dpr_out.new_prior_fy_exp;
               l_asset_deprn_rec.bonus_deprn_amount := l_dpr_out.bonus_deprn_exp;
               l_asset_deprn_rec.bonus_deprn_reserve := l_dpr_out.new_bonus_deprn_rsv;
               l_asset_deprn_rec.prior_fy_bonus_expense := l_dpr_out.new_prior_fy_bonus_exp;
               l_asset_deprn_rec.impairment_amount := l_dpr_out.impairment_exp;
               l_asset_deprn_rec.impairment_reserve := l_dpr_out.new_impairment_rsv;

            end if;

            --++++++ Put adjusted cost back ++++++
            l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
            l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;

            l_out_deprn_exp := l_dpr_out.deprn_exp;
            l_out_reval_exp := l_dpr_out.reval_exp;
            l_out_reval_amo := l_dpr_out.reval_amo;
            l_out_prod := l_dpr_out.prod;
            l_out_ann_adj_exp := l_dpr_out.ann_adj_exp;
            l_out_ann_adj_reval_exp := l_dpr_out.ann_adj_reval_exp;
            l_out_ann_adj_reval_amo := l_dpr_out.ann_adj_reval_amo;
            l_out_bonus_rate_used := l_dpr_out.bonus_rate_used;
            l_out_full_rsv_flag := l_dpr_out.full_rsv_flag;
            l_out_life_comp_flag := l_dpr_out.life_comp_flag;
            l_out_deprn_override_flag := l_dpr_out.deprn_override_flag;

            l_eop_rec_cost := l_asset_fin_rec_new.recoverable_cost;
            l_eop_sal_val := l_asset_fin_rec_new.salvage_value;

            -- HHIRAGA
            --+++++++++ Call member level maintenance for tracking +++++++
            if nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then

               if not FA_TRACK_MEMBER_PVT.member_eofy_rsv(p_asset_hdr_rec => p_asset_hdr_rec,
                                                          p_dpr_in => l_dpr_in,
                                                          p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_TRACK_MEMBER_PVT.member_eofy_rsv',  p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;

               end if;

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '###### Copy to backup #######',
                                 fa_track_member_pvt.p_track_member_table.COUNT,  p_log_level_rec => p_log_level_rec);
              end if;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '##### bakcup table counter #####',
                                fa_track_member_pvt.p_track_member_table_for_deprn.COUNT,  p_log_level_rec => p_log_level_rec);
               end if;

                 if not FA_TRACK_MEMBER_PVT.copy_member_table(p_backup_restore => 'BACKUP',
                                                              p_current_fiscal_year => l_dpr_in.y_begin,
                                                              p_current_period_num => l_dpr_in.p_cl_begin, p_log_level_rec => p_log_level_rec) then
                   if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling', 'COPY_MEMBER_TABLE', p_log_level_rec => p_log_level_rec);
                   end if;
                   raise calc_failed;
                 end if;
              l_backup_processed_flag := TRUE;

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++++ FA_TRACK_MEMBER_PVT.MEMBER_EOFY_RSV +++', '++++',  p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'Copied p_track_member_table to bakcup area', '++++', p_log_level_rec => p_log_level_rec);
              end if;

            end if; -- nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE'
            -- End of HHIRAGA

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('    '||l_calling_fn, 'ytd_deprn', l_asset_deprn_rec.ytd_deprn, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('    '||l_calling_fn, 'deprn_reserve', l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
            end if;

--tk_util.debug('l_adjusted_ind: '||to_char(l_adjusted_ind));
            l_bs_ind := l_bs_ind + l_adjusted_ind;

         else

            l_asset_deprn_rec.ytd_deprn := fa_amort_pvt.t_ytd_deprn(i);
            l_asset_deprn_rec.deprn_reserve := fa_amort_pvt.t_deprn_reserve(i);
            l_asset_deprn_rec.bonus_ytd_deprn := fa_amort_pvt.t_bonus_ytd_deprn(i);
            l_asset_deprn_rec.bonus_deprn_reserve := fa_amort_pvt.t_bonus_deprn_reserve(i);

            l_asset_deprn_rec.ytd_impairment := fa_amort_pvt.t_ytd_impairment(i);
            l_asset_deprn_rec.impairment_reserve := fa_amort_pvt.t_impairment_reserve(i);


            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('    '||l_calling_fn, 'Depreciation is ', 'SKIPPED' , p_log_level_rec => p_log_level_rec);
            end if;

         end if; -- (l_period_rec.period_counter <> fa_amort_pvt.t_period_counter(i)) or

      else
         if (i = 1) then
            fa_amort_pvt.t_ytd_deprn(i)               := fa_amort_pvt.t_deprn_amount(i);
            fa_amort_pvt.t_deprn_reserve(i)           := fa_amort_pvt.t_deprn_amount(i) +
                                                          fa_amort_pvt.t_reserve_adjustment_amount(i);
            fa_amort_pvt.t_bonus_ytd_deprn(i)         := 0;
            fa_amort_pvt.t_bonus_deprn_reserve(i)     := 0;
            fa_amort_pvt.t_ytd_impairment(i)          := 0;
            fa_amort_pvt.t_impairment_reserve(i)      := 0;
            fa_amort_pvt.t_ltd_production(i)          := 0;
            fa_amort_pvt.t_ytd_production(i)          := 0;
            fa_amort_pvt.t_ytd_reval_deprn_expense(i) := 0;
            fa_amort_pvt.t_reval_reserve(i)           := 0;
         else
            if (fa_amort_pvt.t_period_num(i) = 1) then
               fa_amort_pvt.t_ytd_deprn(i)               := fa_amort_pvt.t_deprn_amount(i);
               fa_amort_pvt.t_bonus_ytd_deprn(i)         := 0;
               fa_amort_pvt.t_ytd_impairment(i)         := 0;
               fa_amort_pvt.t_ytd_production(i)          := 0;
               fa_amort_pvt.t_ytd_reval_deprn_expense(i) := 0;
            else
               fa_amort_pvt.t_ytd_deprn(i)               := fa_amort_pvt.t_deprn_amount(i) +
                                                             fa_amort_pvt.t_ytd_deprn(i - 1);
               fa_amort_pvt.t_bonus_ytd_deprn(i)         := fa_amort_pvt.t_bonus_ytd_deprn(i - 1);
               fa_amort_pvt.t_ytd_impairment(i)          := fa_amort_pvt.t_ytd_impairment(i - 1);
               fa_amort_pvt.t_ytd_production(i)          := fa_amort_pvt.t_ltd_production(i - 1);
            fa_amort_pvt.t_ytd_reval_deprn_expense(i) := fa_amort_pvt.t_ytd_reval_deprn_expense(i - 1);

            end if;
--tk_util.debug('fa_amort_pvt.t_deprn_reserve(i - 1): '||to_char(fa_amort_pvt.t_deprn_reserve(i - 1)));
            fa_amort_pvt.t_deprn_reserve(i)           := fa_amort_pvt.t_deprn_amount(i) +
                                                          fa_amort_pvt.t_reserve_adjustment_amount(i) +
                                                          fa_amort_pvt.t_deprn_reserve(i - 1);
            fa_amort_pvt.t_bonus_deprn_reserve(i)     := fa_amort_pvt.t_bonus_deprn_reserve(i - 1);
            fa_amort_pvt.t_impairment_reserve(i)      := fa_amort_pvt.t_impairment_reserve(i - 1);
            fa_amort_pvt.t_ltd_production(i)          := fa_amort_pvt.t_ltd_production(i - 1);
            fa_amort_pvt.t_reval_reserve(i)           := fa_amort_pvt.t_reval_reserve(i - 1);

         end if;

         --
         -- This is necessary to call FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS.
         --
         l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(i);
         l_asset_fin_rec_new.salvage_value := fa_amort_pvt.t_salvage_value(i);
         l_asset_fin_rec_new.recoverable_cost := fa_amort_pvt.t_recoverable_cost(i);
         l_asset_fin_rec_new.deprn_method_code := fa_amort_pvt.t_deprn_method_code(i);
         l_asset_fin_rec_new.life_in_months := fa_amort_pvt.t_life_in_months(i);
         l_asset_fin_rec_new.group_asset_id := fa_amort_pvt.t_group_asset_id(i);
         l_asset_fin_rec_new.depreciate_flag := fa_amort_pvt.t_depreciate_flag(i);
         l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);
         l_asset_fin_rec_new.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(i);
         l_asset_fin_rec_new.formula_factor := fa_amort_pvt.t_formula_factor(i);
         l_asset_fin_rec_new.super_group_id := fa_amort_pvt.t_super_group_id(i);

      end if; -- (l_bs_ind <= i)

   END LOOP; -- FOR i IN 1..l_count LOOP

   --
   -- Need to reset eofy and eop rec cost and salvage value
   -- for deprn basis call
   --
   if (l_count > fa_cache_pkg.fazcct_record.number_per_fiscal_year) then
      l_eofy_rec_cost := fa_amort_pvt.t_recoverable_cost(l_count - fa_amort_pvt.t_period_num(l_count));
      l_eofy_sal_val  := fa_amort_pvt.t_salvage_value(l_count - fa_amort_pvt.t_period_num(l_count));

      if (l_count > 1) then
         l_eop_rec_cost := fa_amort_pvt.t_recoverable_cost(l_count - 1);
         l_eop_sal_val  := fa_amort_pvt.t_salvage_value(l_count - 1);
      end if;
   end if;

   -- Call Depreciable Basis Rule for Formula/NBV Basis
   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                  (p_event_type             => 'AMORT_ADJ3',
                   p_asset_fin_rec_new      => l_asset_fin_rec_new,
                   p_asset_fin_rec_old      => l_asset_fin_rec_new,
                   p_asset_hdr_rec          => p_asset_hdr_rec,
                   p_asset_type_rec         => p_asset_type_rec,
                   p_asset_deprn_rec        => l_asset_deprn_rec,
                   p_trans_rec              => p_trans_rec,
                   p_period_rec             => l_period_rec,
                   p_adjusted_cost          => l_asset_fin_rec_new.adjusted_cost,
                   p_current_total_rsv      => l_asset_deprn_rec.deprn_reserve,
                   p_adj_reserve            => p_asset_deprn_rec_adj.deprn_reserve,
                   p_current_rsv            => l_asset_deprn_rec.deprn_reserve -
                                               l_asset_deprn_rec.bonus_deprn_reserve -
                                               nvl(l_asset_deprn_rec.impairment_reserve,0),
                   p_current_total_ytd      => l_asset_deprn_rec.ytd_deprn,
                   p_hyp_basis              => l_asset_fin_rec_new.adjusted_cost,
                   p_hyp_total_rsv          => l_asset_deprn_rec_raf.deprn_reserve,
                   p_hyp_rsv                => l_asset_deprn_rec_raf.deprn_reserve -
                                               l_asset_deprn_rec_raf.bonus_deprn_reserve -
                                               nvl(l_asset_deprn_rec_raf.impairment_reserve,0),
                   p_eofy_recoverable_cost  => l_eofy_rec_cost,
                   p_eop_recoverable_cost   => l_eop_rec_cost,
                   p_eofy_salvage_value     => l_eofy_sal_val,
                   p_eop_salvage_value      => l_eop_sal_val,
                   p_mrc_sob_type_code      => p_mrc_sob_type_code,
                   p_used_by_adjustment     => 'ADJUSTMENT',
                   px_new_adjusted_cost     => l_asset_fin_rec_new.adjusted_cost,
                   px_new_raf               => l_asset_fin_rec_new.rate_adjustment_factor,
                   px_new_formula_factor    => l_asset_fin_rec_new.formula_factor,
                   p_log_level_rec          => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Error calling',
                          'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;
   end if; -- (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Returned values from ',
                                     'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS AMORT_ADJ3', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost',
                                     l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.rate_adjustment_factor',
                                     l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.formula_factor',
                                     l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
   end if;

   px_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(l_count);
   px_asset_fin_rec_new.recoverable_cost:= fa_amort_pvt.t_recoverable_cost(l_count);
   px_asset_fin_rec_new.adjusted_recoverable_cost:=
                                  fa_amort_pvt.t_adjusted_recoverable_cost(l_count);
   px_asset_fin_rec_new.salvage_value := fa_amort_pvt.t_salvage_value(l_count);
   px_asset_fin_rec_new.allowed_deprn_limit_amount :=
                                  fa_amort_pvt.t_allowed_deprn_limit_amount(l_count);
   px_asset_fin_rec_new.percent_salvage_value := fa_amort_pvt.t_percent_salvage_value(l_count);
   px_asset_fin_rec_new.allowed_deprn_limit := fa_amort_pvt.t_allowed_deprn_limit(l_count);

   -- For now, this won't be touched.
--   px_asset_fin_rec_new.unrevalued_cost := fa_amort_pvt.t_unrevalued_cost(l_count);

   px_asset_fin_rec_new.production_capacity := fa_amort_pvt.t_production_capacity(l_count);
   px_asset_fin_rec_new.reval_ceiling := fa_amort_pvt.t_reval_ceiling(l_count);
--   px_asset_fin_rec_new.adjusted_cost := fa_amort_pvt.t_adjusted_cost(l_count);
   px_asset_fin_rec_new.adjusted_cost := l_asset_fin_rec_new.adjusted_cost;
--   px_asset_fin_rec_new.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(l_count);
   px_asset_fin_rec_new.rate_adjustment_factor := l_asset_fin_rec_new.rate_adjustment_factor;
   px_asset_fin_rec_new.reval_amortization_basis :=
                                  fa_amort_pvt.t_reval_amortization_basis(l_count);
   px_asset_fin_rec_new.adjusted_capacity := fa_amort_pvt.t_adjusted_capacity(l_count);
--   px_asset_fin_rec_new.formula_factor := fa_amort_pvt.t_formula_factor(l_count);
   px_asset_fin_rec_new.formula_factor := l_asset_fin_rec_new.formula_factor;
   px_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(l_count);

   --
   -- When returning catch up expenses, amounts in p_asset_deprn_rec_adj need to be
   -- excluded because it was included at beginning to find correct catchup but
   -- these amounts cannot be expensed in this period.
   --
--   if (px_asset_fin_rec_new.depreciate_flag = 'NO') or
--      (px_asset_fin_rec_new.disabled_flag = 'Y') then
   if (px_asset_fin_rec_new.disabled_flag = 'Y') then
      x_deprn_expense := 0;
      x_bonus_expense := 0;
      x_impairment_expense := 0;
   else
      --Bug8425794 / 8244128: In case of reinstatement, p_asset_deprn_rec_adj.deprn_reserve
      --            is only used to back out reserve retired from fabs.rsv_adj column
      --            but when calculating difference between old reserve and new reserve
      --            should not be used(double counted).
      if (l_asset_deprn_rec.deprn_reserve = p_asset_deprn_rec.deprn_reserve) or (p_trans_rec.transaction_key = 'MS') then
         x_deprn_expense := l_asset_deprn_rec.deprn_reserve - p_asset_deprn_rec.deprn_reserve;
         x_bonus_expense := l_asset_deprn_rec.bonus_deprn_reserve - p_asset_deprn_rec.bonus_deprn_reserve;
      elsif (p_reclass_src_dest = 'SOURCE') then
         x_deprn_expense := l_asset_deprn_rec.deprn_reserve - p_asset_deprn_rec.deprn_reserve - x_deprn_reserve;
         x_bonus_expense := l_asset_deprn_rec.bonus_deprn_reserve - p_asset_deprn_rec.bonus_deprn_reserve - nvl(p_asset_deprn_rec_adj.bonus_deprn_reserve, 0);
      else
         x_deprn_expense := l_asset_deprn_rec.deprn_reserve - p_asset_deprn_rec.deprn_reserve - x_deprn_reserve - nvl(p_asset_deprn_rec_adj.deprn_reserve, 0);
         x_bonus_expense := l_asset_deprn_rec.bonus_deprn_reserve - p_asset_deprn_rec.bonus_deprn_reserve - nvl(p_asset_deprn_rec_adj.bonus_deprn_reserve, 0);
      end if;
      x_impairment_expense := nvl(l_asset_deprn_rec.impairment_reserve,0) - nvl(p_asset_deprn_rec.impairment_reserve,0) - nvl(p_asset_deprn_rec_adj.impairment_reserve,0);
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'x_deprn_reserve', x_deprn_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve', l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_deprn_rec.deprn_reserve', p_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_deprn_rec_adj.deprn_reserve', p_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_deprn_reserve('||to_char(l_count)||')',
                       fa_amort_pvt.t_deprn_reserve(l_count));
   end if;

   -- HHIRAGA
   --+++++++++ Call member level maintenance for tracking +++++++
   if nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then

      if not FA_TRACK_MEMBER_PVT.update_member_books(p_trans_rec=> p_trans_rec,
                                     p_asset_hdr_rec => p_asset_hdr_rec,
                                     p_dpr_in => l_dpr_in,
                                     p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_TRACK_MEMBER_PVT.update_member_books',  p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;
      end if;

      fa_track_member_pvt.p_track_member_eofy_table.delete;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fa_track_member_pvt.p_track_member_eofy_table',
                                        'deleted',  p_log_level_rec => p_log_level_rec);
      end if;

      if (p_log_level_rec.statement_level) then
         for i in 1.. fa_track_member_pvt.p_track_member_table.count loop
            fa_debug_pkg.add('HH DEBUG**', 'all records in p_track_member_table', i);
            if not fa_track_member_pvt.display_debug_message2(i, 'HH DEBUG**', p_log_leveL_rec) then
               null;
            end if;
         end loop;
      end if;

   end if; -- nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE'
   -- End of HHIRAGA
   -- HHIRAGA
   --+++++++++ Call member level maintenance for tracking +++++++
   if nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then

      if not FA_TRACK_MEMBER_PVT.create_update_bs_table(p_trans_rec => p_trans_rec,
                                     p_book_type_code => p_asset_hdr_rec.book_type_code,
                                     p_group_asset_id => p_asset_hdr_rec.asset_id,
                                     p_mrc_sob_type_code => p_mrc_sob_type_code, --Bug 8941132
                                     p_sob_id            => p_asset_hdr_rec.set_of_books_id, --Bug 8941132
                                     p_calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_TRACK_MEMBER_PVT.create_update_bs_table',  p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;
      end if;

   end if; -- nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE'
   -- End of HHIRAGA

   if (p_update_books_summary) then
               --
               -- Update FA_BOOKS_SUMMARY
               --
--tk_util.debug('period# :      cost:    chcost:      msal:       exp:       ytd:       rsv:       rsv');
--tk_util.debug('period# :      cost:   adjcost:       exp:      eofy:     rsvaj:       rsv:      dlmt:      arec');
/*
for i in fa_amort_pvt.t_cost.FIRST..fa_amort_pvt.t_cost.LAST loop
--tk_util.debug(rpad(to_char(fa_amort_pvt.t_period_counter(i)), 8, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_cost(i)), 10, ' ')||':'||
--              lpad(substrb(to_char(fa_amort_pvt.t_rate_adjustment_factor(i)), 1, 10), 10, ' ')||':'||
--              fa_amort_pvt.t_reset_adjusted_cost_flag(i)||':'||
--              lpad(to_char(fa_amort_pvt.t_change_in_cost(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_adjusted_cost(i)), 10, ' ')||':'||
--              lpad(to_char(fa_amort_pvt.t_salvage_value(i)), 10, ' ')||':'||
--              lpad(to_char(fa_amort_pvt.t_member_salvage_value(i)), 10, ' ')||':'||
--              lpad(to_char(fa_amort_pvt.t_deprn_adjustment_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_deprn_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_ytd_deprn(i)), 10, ' ')||':'||
--              lpad(to_char(fa_amort_pvt.t_eofy_reserve(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_reserve_adjustment_amount(i)), 10, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_deprn_reserve(i)), 10, ' ')||':'||
--              lpad(nvl(to_char(fa_amort_pvt.t_allowed_deprn_limit_amount(i)), 'null'), 5, ' ')||':'||
              lpad(to_char(fa_amort_pvt.t_adjusted_recoverable_cost(i)), 10, ' ')
             );
end loop;
*/
      if (p_mrc_sob_type_code = 'R') then
               FORALL i in l_temp_ind..fa_amort_pvt.t_cost.LAST
                  UPDATE FA_MC_BOOKS_SUMMARY
                  SET RESET_ADJUSTED_COST_FLAG   = fa_amort_pvt.t_reset_adjusted_cost_flag(i)
                    , CHANGE_IN_COST             = fa_amort_pvt.t_change_in_cost(i)
                    , CHANGE_IN_CIP_COST         = fa_amort_pvt.t_change_in_cip_cost(i)
                    , COST                       = fa_amort_pvt.t_cost(i)
                    , CIP_COST                   = fa_amort_pvt.t_cip_cost(i)
                    , SALVAGE_TYPE               = fa_amort_pvt.t_salvage_type(i)
                    , PERCENT_SALVAGE_VALUE      = fa_amort_pvt.t_percent_salvage_value(i)
                    , SALVAGE_VALUE              = fa_amort_pvt.t_salvage_value(i)
                    , MEMBER_SALVAGE_VALUE       = fa_amort_pvt.t_member_salvage_value(i)
                    , RECOVERABLE_COST           = fa_amort_pvt.t_recoverable_cost(i)
                    , DEPRN_LIMIT_TYPE           = fa_amort_pvt.t_deprn_limit_type(i)
                    , ALLOWED_DEPRN_LIMIT        = fa_amort_pvt.t_allowed_deprn_limit(i)
                    , ALLOWED_DEPRN_LIMIT_AMOUNT = fa_amort_pvt.t_allowed_deprn_limit_amount(i)
                    , MEMBER_DEPRN_LIMIT_AMOUNT  = fa_amort_pvt.t_member_deprn_limit_amount(i)
                    , ADJUSTED_RECOVERABLE_COST  = fa_amort_pvt.t_adjusted_recoverable_cost(i)
                    , ADJUSTED_COST              = fa_amort_pvt.t_adjusted_cost(i)
                    , DEPRECIATE_FLAG            = fa_amort_pvt.t_depreciate_flag(i)
                    , DEPRN_METHOD_CODE          = fa_amort_pvt.t_deprn_method_code(i)
                    , LIFE_IN_MONTHS             = fa_amort_pvt.t_life_in_months(i)
                    , RATE_ADJUSTMENT_FACTOR     = fa_amort_pvt.t_rate_adjustment_factor(i)
                    , ADJUSTED_RATE              = fa_amort_pvt.t_adjusted_rate(i)
                    , BONUS_RULE                 = fa_amort_pvt.t_bonus_rule(i)
                    , ADJUSTED_CAPACITY          = fa_amort_pvt.t_adjusted_capacity(i)
                    , PRODUCTION_CAPACITY        = fa_amort_pvt.t_production_capacity(i)
                    , UNIT_OF_MEASURE            = fa_amort_pvt.t_unit_of_measure(i)
                    , REMAINING_LIFE1            = fa_amort_pvt.t_remaining_life1(i)
                    , REMAINING_LIFE2            = fa_amort_pvt.t_remaining_life2(i)
                    , FORMULA_FACTOR             = fa_amort_pvt.t_formula_factor(i)
                    , UNREVALUED_COST            = fa_amort_pvt.t_unrevalued_cost(i)
                    , REVAL_AMORTIZATION_BASIS   = fa_amort_pvt.t_reval_amortization_basis(i)
                    , REVAL_CEILING              = fa_amort_pvt.t_reval_ceiling(i)
                    , CEILING_NAME               = fa_amort_pvt.t_ceiling_name(i)
                    , EOFY_ADJ_COST              = fa_amort_pvt.t_eofy_adj_cost(i)
                    , EOFY_FORMULA_FACTOR        = fa_amort_pvt.t_eofy_formula_factor(i)
                    , EOFY_RESERVE               = fa_amort_pvt.t_eofy_reserve(i)
                    , EOP_ADJ_COST               = fa_amort_pvt.t_eop_adj_cost(i)
                    , EOP_FORMULA_FACTOR         = fa_amort_pvt.t_eop_formula_factor(i)
                    , SHORT_FISCAL_YEAR_FLAG     = fa_amort_pvt.t_short_fiscal_year_flag(i)
                    , GROUP_ASSET_ID             = fa_amort_pvt.t_group_asset_id(i)
                    , SUPER_GROUP_ID             = fa_amort_pvt.t_super_group_id(i)
                    , OVER_DEPRECIATE_OPTION     = fa_amort_pvt.t_over_depreciate_option(i)
                    , DEPRN_AMOUNT               = fa_amort_pvt.t_deprn_amount(i)
                    , YTD_DEPRN                  = fa_amort_pvt.t_ytd_deprn(i)
                    , DEPRN_RESERVE              = fa_amort_pvt.t_deprn_reserve(i)
                    , BONUS_DEPRN_AMOUNT         = fa_amort_pvt.t_bonus_deprn_amount(i)
                    , BONUS_YTD_DEPRN            = fa_amort_pvt.t_bonus_ytd_deprn(i)
                    , BONUS_DEPRN_RESERVE        = fa_amort_pvt.t_bonus_deprn_reserve(i)
                    , BONUS_RATE                 = fa_amort_pvt.t_bonus_rate(i)
                    , IMPAIRMENT_AMOUNT          = fa_amort_pvt.t_impairment_amount(i)
                    , YTD_IMPAIRMENT             = fa_amort_pvt.t_ytd_impairment(i)
                    , impairment_reserve             = fa_amort_pvt.t_impairment_reserve(i)
                    , LTD_PRODUCTION             = fa_amort_pvt.t_ltd_production(i)
                    , YTD_PRODUCTION             = fa_amort_pvt.t_ytd_production(i)
                    , PRODUCTION                 = fa_amort_pvt.t_production(i)
                    , REVAL_AMORTIZATION         = fa_amort_pvt.t_reval_amortization(i)
                    , REVAL_DEPRN_EXPENSE        = fa_amort_pvt.t_reval_deprn_expense(i)
                    , REVAL_RESERVE              = fa_amort_pvt.t_reval_reserve(i)
                    , YTD_REVAL_DEPRN_EXPENSE    = fa_amort_pvt.t_ytd_reval_deprn_expense(i)
                    , DEPRN_OVERRIDE_FLAG        = fa_amort_pvt.t_deprn_override_flag(i)
                    , SYSTEM_DEPRN_AMOUNT        = fa_amort_pvt.t_system_deprn_amount(i)
                    , SYSTEM_BONUS_DEPRN_AMOUNT  = fa_amort_pvt.t_system_bonus_deprn_amount(i)
                    , YTD_PROCEEDS_OF_SALE       = fa_amort_pvt.t_ytd_proceeds_of_sale(i)
                    , LTD_PROCEEDS_OF_SALE       = fa_amort_pvt.t_ltd_proceeds_of_sale(i)
                    , YTD_COST_OF_REMOVAL        = fa_amort_pvt.t_ytd_cost_of_removal(i)
                    , LTD_COST_OF_REMOVAL        = fa_amort_pvt.t_ltd_cost_of_removal(i)
                    , DEPRN_ADJUSTMENT_AMOUNT    = fa_amort_pvt.t_deprn_adjustment_amount(i)
                    , EXPENSE_ADJUSTMENT_AMOUNT  = fa_amort_pvt.t_expense_adjustment_amount(i)
                    , RESERVE_ADJUSTMENT_AMOUNT  = fa_amort_pvt.t_reserve_adjustment_amount(i)
                    , CHANGE_IN_EOFY_RESERVE     = fa_amort_pvt.t_change_in_eofy_reserve(i)
                    , LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date
                    , LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by
                    , LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
                  WHERE ASSET_ID = p_asset_hdr_rec.asset_id
                  AND   BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                  AND   PERIOD_COUNTER = fa_amort_pvt.t_period_counter(i)
                  AND   SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id;

      else
               FORALL i in l_temp_ind..fa_amort_pvt.t_cost.LAST
                  UPDATE FA_BOOKS_SUMMARY
                  SET RESET_ADJUSTED_COST_FLAG   = fa_amort_pvt.t_reset_adjusted_cost_flag(i)
                    , CHANGE_IN_COST             = fa_amort_pvt.t_change_in_cost(i)
                    , CHANGE_IN_CIP_COST         = fa_amort_pvt.t_change_in_cip_cost(i)
                    , COST                       = fa_amort_pvt.t_cost(i)
                    , CIP_COST                   = fa_amort_pvt.t_cip_cost(i)
                    , SALVAGE_TYPE               = fa_amort_pvt.t_salvage_type(i)
                    , PERCENT_SALVAGE_VALUE      = fa_amort_pvt.t_percent_salvage_value(i)
                    , SALVAGE_VALUE              = fa_amort_pvt.t_salvage_value(i)
                    , MEMBER_SALVAGE_VALUE       = fa_amort_pvt.t_member_salvage_value(i)
                    , RECOVERABLE_COST           = fa_amort_pvt.t_recoverable_cost(i)
                    , DEPRN_LIMIT_TYPE           = fa_amort_pvt.t_deprn_limit_type(i)
                    , ALLOWED_DEPRN_LIMIT        = fa_amort_pvt.t_allowed_deprn_limit(i)
                    , ALLOWED_DEPRN_LIMIT_AMOUNT = fa_amort_pvt.t_allowed_deprn_limit_amount(i)
                    , MEMBER_DEPRN_LIMIT_AMOUNT  = fa_amort_pvt.t_member_deprn_limit_amount(i)
                    , ADJUSTED_RECOVERABLE_COST  = fa_amort_pvt.t_adjusted_recoverable_cost(i)
                    , ADJUSTED_COST              = fa_amort_pvt.t_adjusted_cost(i)
                    , DEPRECIATE_FLAG            = fa_amort_pvt.t_depreciate_flag(i)
                    , DEPRN_METHOD_CODE          = fa_amort_pvt.t_deprn_method_code(i)
                    , LIFE_IN_MONTHS             = fa_amort_pvt.t_life_in_months(i)
                    , RATE_ADJUSTMENT_FACTOR     = fa_amort_pvt.t_rate_adjustment_factor(i)
                    , ADJUSTED_RATE              = fa_amort_pvt.t_adjusted_rate(i)
                    , BONUS_RULE                 = fa_amort_pvt.t_bonus_rule(i)
                    , ADJUSTED_CAPACITY          = fa_amort_pvt.t_adjusted_capacity(i)
                    , PRODUCTION_CAPACITY        = fa_amort_pvt.t_production_capacity(i)
                    , UNIT_OF_MEASURE            = fa_amort_pvt.t_unit_of_measure(i)
                    , REMAINING_LIFE1            = fa_amort_pvt.t_remaining_life1(i)
                    , REMAINING_LIFE2            = fa_amort_pvt.t_remaining_life2(i)
                    , FORMULA_FACTOR             = fa_amort_pvt.t_formula_factor(i)
                    , UNREVALUED_COST            = fa_amort_pvt.t_unrevalued_cost(i)
                    , REVAL_AMORTIZATION_BASIS   = fa_amort_pvt.t_reval_amortization_basis(i)
                    , REVAL_CEILING              = fa_amort_pvt.t_reval_ceiling(i)
                    , CEILING_NAME               = fa_amort_pvt.t_ceiling_name(i)
                    , EOFY_ADJ_COST              = fa_amort_pvt.t_eofy_adj_cost(i)
                    , EOFY_FORMULA_FACTOR        = fa_amort_pvt.t_eofy_formula_factor(i)
                    , EOFY_RESERVE               = fa_amort_pvt.t_eofy_reserve(i)
                    , EOP_ADJ_COST               = fa_amort_pvt.t_eop_adj_cost(i)
                    , EOP_FORMULA_FACTOR         = fa_amort_pvt.t_eop_formula_factor(i)
                    , SHORT_FISCAL_YEAR_FLAG     = fa_amort_pvt.t_short_fiscal_year_flag(i)
                    , GROUP_ASSET_ID             = fa_amort_pvt.t_group_asset_id(i)
                    , SUPER_GROUP_ID             = fa_amort_pvt.t_super_group_id(i)
                    , OVER_DEPRECIATE_OPTION     = fa_amort_pvt.t_over_depreciate_option(i)
                    , DEPRN_AMOUNT               = fa_amort_pvt.t_deprn_amount(i)
                    , YTD_DEPRN                  = fa_amort_pvt.t_ytd_deprn(i)
                    , DEPRN_RESERVE              = fa_amort_pvt.t_deprn_reserve(i)
                    , BONUS_DEPRN_AMOUNT         = fa_amort_pvt.t_bonus_deprn_amount(i)
                    , BONUS_YTD_DEPRN            = fa_amort_pvt.t_bonus_ytd_deprn(i)
                    , BONUS_DEPRN_RESERVE        = fa_amort_pvt.t_bonus_deprn_reserve(i)
                    , BONUS_RATE                 = fa_amort_pvt.t_bonus_rate(i)
                    , IMPAIRMENT_AMOUNT          = fa_amort_pvt.t_impairment_amount(i)
                    , YTD_IMPAIRMENT             = fa_amort_pvt.t_ytd_impairment(i)
                    , impairment_reserve             = fa_amort_pvt.t_impairment_reserve(i)
                    , LTD_PRODUCTION             = fa_amort_pvt.t_ltd_production(i)
                    , YTD_PRODUCTION             = fa_amort_pvt.t_ytd_production(i)
                    , PRODUCTION                 = fa_amort_pvt.t_production(i)
                    , REVAL_AMORTIZATION         = fa_amort_pvt.t_reval_amortization(i)
                    , REVAL_DEPRN_EXPENSE        = fa_amort_pvt.t_reval_deprn_expense(i)
                    , REVAL_RESERVE              = fa_amort_pvt.t_reval_reserve(i)
                    , YTD_REVAL_DEPRN_EXPENSE    = fa_amort_pvt.t_ytd_reval_deprn_expense(i)
                    , DEPRN_OVERRIDE_FLAG        = fa_amort_pvt.t_deprn_override_flag(i)
                    , SYSTEM_DEPRN_AMOUNT        = fa_amort_pvt.t_system_deprn_amount(i)
                    , SYSTEM_BONUS_DEPRN_AMOUNT  = fa_amort_pvt.t_system_bonus_deprn_amount(i)
                    , YTD_PROCEEDS_OF_SALE       = fa_amort_pvt.t_ytd_proceeds_of_sale(i)
                    , LTD_PROCEEDS_OF_SALE       = fa_amort_pvt.t_ltd_proceeds_of_sale(i)
                    , YTD_COST_OF_REMOVAL        = fa_amort_pvt.t_ytd_cost_of_removal(i)
                    , LTD_COST_OF_REMOVAL        = fa_amort_pvt.t_ltd_cost_of_removal(i)
                    , DEPRN_ADJUSTMENT_AMOUNT    = fa_amort_pvt.t_deprn_adjustment_amount(i)
                    , EXPENSE_ADJUSTMENT_AMOUNT  = fa_amort_pvt.t_expense_adjustment_amount(i)
                    , RESERVE_ADJUSTMENT_AMOUNT  = fa_amort_pvt.t_reserve_adjustment_amount(i)
                    , CHANGE_IN_EOFY_RESERVE     = fa_amort_pvt.t_change_in_eofy_reserve(i)
                    , LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date
                    , LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by
                    , LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
                  WHERE ASSET_ID = p_asset_hdr_rec.asset_id
                  AND   BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                  AND   PERIOD_COUNTER = fa_amort_pvt.t_period_counter(i);
      end if;

   end if; -- (p_update_books_summary)

   --
   -- Initialize global variables
   --
   InitGlobeVariables;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End',
                       x_deprn_expense||':'||x_bonus_expense||':'||x_deprn_reserve, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
  WHEN invalid_trx_to_overlap THEN
    --
    -- Initialize global variables
    --
    InitGlobeVariables;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'invalid_trx_to_overlap', p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                            name       => 'FA_INVALID_TRX_TO_OVERLAP', p_log_level_rec => p_log_level_rec);
    return false;
  WHEN calc_failed THEN
    --
    -- Initialize global variables
    --
    InitGlobeVariables;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'calc_failed', p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

  WHEN OTHERS THEN
    --
    -- Initialize global variables
    --
    InitGlobeVariables;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    raise;
END bsRecalculate;

--+==============================================================================
-- Procedure: populate_fin_rec
--
--   This procedure popualte asset_fin_rec_adj in case it is not provided.
--
--+==============================================================================
PROCEDURE populate_fin_rec(
             p_trans_rec                     FA_API_TYPES.trans_rec_type,
             p_asset_fin_rec_old             FA_API_TYPES.asset_fin_rec_type,
             p_asset_fin_rec_adj             FA_API_TYPES.asset_fin_rec_type default null,
             p_asset_fin_rec_new             FA_API_TYPES.asset_fin_rec_type,
             x_asset_fin_rec_adj  OUT NOCOPY FA_API_TYPES.asset_fin_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN
/*
   if (nvl(p_asset_fin_rec_old.cost, 0) = nvl(p_asset_fin_rec_new.cost, 0) and
       p_asset_fin_rec_adj.cost is null) and
      (nvl(p_asset_fin_rec_old.cip_cost, 0) = nvl(p_asset_fin_rec_new.cip_cost, 0) and
       p_asset_fin_rec_adj.cip_cost is null) and
      (nvl(p_asset_fin_rec_old.salvage_type, 'NULL') = nvl(p_asset_fin_rec_new.salvage_type, 'NULL') and
       p_asset_fin_rec_adj.salvage_type is NULL) and
      (p_asset_fin_rec_adj.percent_salvage_value is null) and
      (nvl(p_asset_fin_rec_old.salvage_value, 0) = nvl(p_asset_fin_rec_new.salvage_value, 0) and
       p_asset_fin_rec_adj.salvage_value is null) and
      (p_asset_fin_rec_adj.recoverable_cost is null) and
      (p_asset_fin_rec_adj.adjusted_recoverable_cost is null) and
      (nvl(p_asset_fin_rec_old.deprn_limit_type, 'NULL') = nvl(p_asset_fin_rec_new.deprn_limit_type, 'NULL') and
       p_asset_fin_rec_adj.deprn_limit_type is null) and
      (p_asset_fin_rec_adj.allowed_deprn_limit is null) and
      (nvl(p_asset_fin_rec_old.allowed_deprn_limit_amount, 0) = nvl(p_asset_fin_rec_new.allowed_deprn_limit_amount, 0) and
       p_asset_fin_rec_adj.allowed_deprn_limit_amount is null) and
      (p_asset_fin_rec_adj.production_capacity is null) and
      (p_asset_fin_rec_adj.reval_ceiling is null) and
      (p_asset_fin_rec_adj.unrevalued_cost is null) and
      (p_asset_fin_rec_adj.deprn_method_code is null) and
      (p_asset_fin_rec_adj.basic_rate is null) and
      (p_asset_fin_rec_adj.adjusted_rate is null) and
      (p_asset_fin_rec_adj.life_in_months is null) and
      (p_asset_fin_rec_adj.date_placed_in_service is null) and
      (p_asset_fin_rec_adj.prorate_date is null) and
      (p_asset_fin_rec_adj.bonus_rule is null) then
*/
   if (p_asset_fin_rec_adj.cost is null) and
      (p_asset_fin_rec_adj.cip_cost is null) and
      (p_asset_fin_rec_adj.salvage_type is null) and
      (p_asset_fin_rec_adj.percent_salvage_value is null) and
      (p_asset_fin_rec_adj.salvage_value is null) and
      (p_asset_fin_rec_adj.recoverable_cost is null) and
      (p_asset_fin_rec_adj.adjusted_recoverable_cost is null) and
      (p_asset_fin_rec_adj.deprn_limit_type is null) and
      (p_asset_fin_rec_adj.allowed_deprn_limit is null) and
      (p_asset_fin_rec_adj.allowed_deprn_limit_amount is null) and
      (p_asset_fin_rec_adj.production_capacity is null) and
      (p_asset_fin_rec_adj.reval_ceiling is null) and
      (p_asset_fin_rec_adj.unrevalued_cost is null) and
      (p_asset_fin_rec_adj.deprn_method_code is null) and
      (p_asset_fin_rec_adj.basic_rate is null) and
      (p_asset_fin_rec_adj.adjusted_rate is null) and
      (p_asset_fin_rec_adj.life_in_months is null) and
      (p_asset_fin_rec_adj.date_placed_in_service is null) and
      (p_asset_fin_rec_adj.prorate_date is null) and
      (p_asset_fin_rec_adj.bonus_rule is null) then
--tk_util.debug('Fin Adj is NULL!!!!!!');
      x_asset_fin_rec_adj := p_asset_fin_rec_new;

if  p_trans_rec.transaction_type_code <> 'ADDITION' then

      if (p_asset_fin_rec_adj.cost is not null) then
         x_asset_fin_rec_adj.cost :=p_asset_fin_rec_adj.cost;
      else
         x_asset_fin_rec_adj.cost := nvl(p_asset_fin_rec_new.cost, 0) -
                                     nvl(p_asset_fin_rec_old.cost, 0);
      end if;

      if (p_asset_fin_rec_adj.cip_cost is not null) then
         x_asset_fin_rec_adj.cip_cost := p_asset_fin_rec_adj.cip_cost;
      elsif (p_asset_fin_rec_new.cip_cost is not null) then
         x_asset_fin_rec_adj.cip_cost := nvl(p_asset_fin_rec_new.cip_cost, 0) -
                                        nvl(p_asset_fin_rec_old.cip_cost, 0);
      end if;

      if (p_asset_fin_rec_adj.salvage_value is not null) then
         x_asset_fin_rec_adj.salvage_value := p_asset_fin_rec_adj.salvage_value;
      elsif (p_asset_fin_rec_new.salvage_value is not null) then
         x_asset_fin_rec_adj.salvage_value := nvl(p_asset_fin_rec_new.salvage_value, 0) -
                                              nvl(p_asset_fin_rec_old.salvage_value, 0);
      end if;

      if (p_asset_fin_rec_adj.recoverable_cost is not null) then
         x_asset_fin_rec_adj.recoverable_cost :=
                                              p_asset_fin_rec_adj.recoverable_cost;
      elsif (p_asset_fin_rec_new.recoverable_cost is not null) then
         x_asset_fin_rec_adj.recoverable_cost :=
                                              nvl(p_asset_fin_rec_new.recoverable_cost, 0) -
                                              nvl(p_asset_fin_rec_old.recoverable_cost, 0);
      end if;

      if (p_asset_fin_rec_adj.adjusted_recoverable_cost is not null) then
         x_asset_fin_rec_adj.adjusted_recoverable_cost :=
                                     p_asset_fin_rec_adj.adjusted_recoverable_cost;
      elsif (p_asset_fin_rec_new.adjusted_recoverable_cost is not null) then
         x_asset_fin_rec_adj.adjusted_recoverable_cost :=
                                     nvl(p_asset_fin_rec_new.adjusted_recoverable_cost, 0) -
                                     nvl(p_asset_fin_rec_old.adjusted_recoverable_cost, 0);
      end if;

      if (p_asset_fin_rec_adj.original_cost is not null) then
            x_asset_fin_rec_adj.original_cost := p_asset_fin_rec_adj.original_cost;
      elsif (p_asset_fin_rec_new.original_cost is not null) then
            x_asset_fin_rec_adj.original_cost := nvl(p_asset_fin_rec_new.original_cost, 0) -
                                                 nvl(p_asset_fin_rec_old.original_cost, 0);
      end if;

      if (p_asset_fin_rec_adj.production_capacity is not null) then
         x_asset_fin_rec_adj.production_capacity :=
                                     p_asset_fin_rec_adj.production_capacity;
      elsif (p_asset_fin_rec_new.production_capacity is not null) then
         x_asset_fin_rec_adj.production_capacity :=
                                     nvl(p_asset_fin_rec_new.production_capacity, 0) -
                                     nvl(p_asset_fin_rec_old.production_capacity, 0);
      end if;

      if (p_asset_fin_rec_adj.reval_ceiling is not null) then
         x_asset_fin_rec_adj.reval_ceiling :=
                                     p_asset_fin_rec_adj.reval_ceiling;
      elsif (p_asset_fin_rec_new.reval_ceiling is not null) then
         x_asset_fin_rec_adj.reval_ceiling :=
                                     nvl(p_asset_fin_rec_new.reval_ceiling, 0) -
                                     nvl(p_asset_fin_rec_old.reval_ceiling, 0);
      end if;


      if (p_asset_fin_rec_adj.unrevalued_cost is not null) then
         x_asset_fin_rec_adj.unrevalued_cost :=
                                     p_asset_fin_rec_adj.unrevalued_cost;
      elsif (p_asset_fin_rec_new.unrevalued_cost is not null) then
         x_asset_fin_rec_adj.unrevalued_cost :=
                                     nvl(p_asset_fin_rec_new.unrevalued_cost, 0) -
                                     nvl(p_asset_fin_rec_old.unrevalued_cost, 0);
      end if;

      if (p_asset_fin_rec_new.salvage_type = 'PCT') then
         x_asset_fin_rec_adj.percent_salvage_value := nvl(p_asset_fin_rec_new.percent_salvage_value, 0) -
                                                      nvl(p_asset_fin_rec_old.percent_salvage_value, 0);
      else
         x_asset_fin_rec_adj.percent_salvage_value := to_number(null);
      end if;

      if (x_asset_fin_rec_adj.deprn_limit_type = 'NONE') then
         x_asset_fin_rec_adj.deprn_limit_type := 'NONE';
         x_asset_fin_rec_adj.allowed_deprn_limit := to_number(null);
         x_asset_fin_rec_adj.allowed_deprn_limit_amount := to_number(null);
      elsif (p_asset_fin_rec_new.deprn_limit_type <>
             p_asset_fin_rec_old.deprn_limit_type) then
         x_asset_fin_rec_adj.deprn_limit_type := p_asset_fin_rec_new.deprn_limit_type;
         x_asset_fin_rec_adj.allowed_deprn_limit := p_asset_fin_rec_new.allowed_deprn_limit;
         x_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                              p_asset_fin_rec_new.allowed_deprn_limit_amount;
      else
         x_asset_fin_rec_adj.allowed_deprn_limit := p_asset_fin_rec_new.allowed_deprn_limit -
                                                    p_asset_fin_rec_old.allowed_deprn_limit;
         x_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                              p_asset_fin_rec_new.allowed_deprn_limit_amount -
                                              p_asset_fin_rec_old.allowed_deprn_limit_amount;
      end if;

end if;

      x_asset_fin_rec_adj.eofy_reserve := null;

      if p_asset_fin_rec_old.deprn_method_code = p_asset_fin_rec_new.deprn_method_code and
         nvl(p_asset_fin_rec_old.life_in_months, 0) =
                                nvl(p_asset_fin_rec_new.life_in_months, 0) and
         nvl(p_asset_fin_rec_old.basic_rate, 0) =
                                nvl(p_asset_fin_rec_new.basic_rate, 0) and
         nvl(p_asset_fin_rec_old.adjusted_rate, 0) =
                                nvl(p_asset_fin_rec_new.adjusted_rate, 0) and
         nvl(p_asset_fin_rec_old.production_capacity, 0) =
                                nvl(p_asset_fin_rec_new.production_capacity, 0) and
         p_trans_rec.transaction_type_code <> 'ADDITION' then

         x_asset_fin_rec_adj.deprn_method_code := null;
         x_asset_fin_rec_adj.life_in_months := to_number(null);
         x_asset_fin_rec_adj.basic_rate := to_number(null);
         x_asset_fin_rec_adj.adjusted_rate := to_number(null);
         x_asset_fin_rec_adj.production_capacity := to_number(null);
      end if;

   else
--tk_util.debug('Fin Adj is NOT null');
      x_asset_fin_rec_adj := p_asset_fin_rec_adj;

      -- Bug3041716
      -- New faxama is expecting delta information so method information only needs to
      -- be populated only if there is a change in method related values
      --
      if p_asset_fin_rec_old.deprn_method_code = p_asset_fin_rec_new.deprn_method_code and
         nvl(p_asset_fin_rec_old.life_in_months, 0) =
                                nvl(p_asset_fin_rec_new.life_in_months, 0) and
         nvl(p_asset_fin_rec_old.basic_rate, 0) =
                                nvl(p_asset_fin_rec_new.basic_rate, 0) and
         nvl(p_asset_fin_rec_old.adjusted_rate, 0) =
                                nvl(p_asset_fin_rec_new.adjusted_rate, 0) and
         nvl(p_asset_fin_rec_old.production_capacity, 0) =
                                nvl(p_asset_fin_rec_new.production_capacity, 0) then

         x_asset_fin_rec_adj.deprn_method_code := null;
         x_asset_fin_rec_adj.life_in_months := to_number(null);
         x_asset_fin_rec_adj.basic_rate := to_number(null);
         x_asset_fin_rec_adj.adjusted_rate := to_number(null);
         x_asset_fin_rec_adj.production_capacity := to_number(null);
      end if;

   end if;



END populate_fin_rec;

---------------------------------------------------------------------------

FUNCTION faxama
         (px_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec                      FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec                     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec                      FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec                     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old                  FA_API_TYPES.asset_fin_rec_type,
          p_asset_fin_rec_adj                  FA_API_TYPES.asset_fin_rec_type default null,
          px_asset_fin_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec                    FA_API_TYPES.asset_deprn_rec_type,
          p_asset_deprn_rec_adj                FA_API_TYPES.asset_deprn_rec_type default null,
          p_period_rec                         FA_API_TYPES.period_rec_type,
          p_mrc_sob_type_code                  VARCHAR2,
          p_running_mode                       NUMBER,
          p_used_by_revaluation                NUMBER,
          p_reclassed_asset_id                 NUMBER default null,
          p_reclass_src_dest                   VARCHAR2 default null,
          p_reclassed_asset_dpis               DATE default null,
          p_update_books_summary               BOOLEAN default FALSE,
          p_proceeds_of_sale                   NUMBER default 0,
          p_cost_of_removal                    NUMBER default 0,
          x_deprn_exp               OUT NOCOPY NUMBER,
          x_bonus_deprn_exp         OUT NOCOPY NUMBER,
          x_impairment_exp          OUT NOCOPY NUMBER,
          x_deprn_rsv               OUT NOCOPY NUMBER
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   l_calling_fn           varchar2(50) := 'newFA_AMORT_PVT.faxama';
   l_reval_deprn_rsv_adj  number :=0;
   l_afn_zero             number:=0;

   l_asset_fin_rec_adj    FA_API_TYPES.asset_fin_rec_type;

   -- Bug4958977: Adding following cursor and 2 new variables
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

   l_temp_thid          number;
   l_call_bs            BOOLEAN := FALSE;

   l_valid_type_change  BOOLEAN := TRUE; -- bug5149789

   calc_err             EXCEPTION;

/*
   err number;

   cursor c_get_profiler is
     select runid,
            run_date,
            run_comment
     from plsql_profiler_runs;
*/

begin <<faxama>>
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-+++++-');
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_type_rec.asset_type||':'||
                                              p_asset_hdr_rec.asset_id||':'||
                                              to_char(px_trans_rec.transaction_header_id));
      fa_debug_pkg.add(l_calling_fn, 'Begin sob_id', p_asset_hdr_rec.set_of_books_id);

   end if;


--   err:=DBMS_PROFILER.START_PROFILER ('faxama:'||to_char(sysdate,'dd-Mon-YYYY hh:mi:ss'));

   X_deprn_exp       := 0;
   X_bonus_deprn_exp := 0;
   x_impairment_exp  := 0;

   if (p_asset_type_rec.asset_type='CIP') then
      FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxama',
             NAME       => 'FA_AMT_CIP_NOT_ALLOWED',
             TOKEN1     => 'TYPE',
             VALUE1     => 'Amortized',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

--tk_util.DumpTrxRec(px_trans_rec, 'px_trans_rec');
--tk_util.DumpFinRec(p_asset_fin_rec_old, 'old fin_rec');
--tk_util.DumpFinRec(p_asset_fin_rec_adj, 'adj fin_rec');
--tk_util.DumpFinRec(px_asset_fin_rec_new, 'new_fin_rec');
--tk_util.DumpDeprnRec(p_asset_deprn_rec, 'old deprn');
--tk_util.DumpDeprnRec(p_asset_deprn_rec_adj, 'adj deprn');

   -- Bug5149789: checking whether member exists or not
   -- Call function check_member_existence if either of
   -- salvage or deprn limit type is being changed and there is 0 group cost
   if (((px_asset_fin_rec_new.salvage_type = 'SUM') and
        (px_asset_fin_rec_new.salvage_type <> nvl(p_asset_fin_rec_old.salvage_type,
                                                  px_asset_fin_rec_new.salvage_type))) or
       ((px_asset_fin_rec_new.deprn_limit_type = 'SUM') and
        (px_asset_fin_rec_new.deprn_limit_type <> nvl(p_asset_fin_rec_old.deprn_limit_type,
                                                      px_asset_fin_rec_new.deprn_limit_type)))) then

      if (px_asset_fin_rec_new.cost = 0) then

         if not check_member_existence (p_asset_hdr_rec => p_asset_hdr_rec,
                                        p_log_level_rec => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling check_member_existence', 'FAILED', p_log_level_rec => p_log_level_rec);
            end if;

            l_valid_type_change := FALSE;

         end if;

      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Method.deprn_limit type change', 'FAILED', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'cost', px_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
         end if;

         l_valid_type_change := FALSE;

      end if;

      if (not l_valid_type_change) then
         if (px_asset_fin_rec_new.salvage_type = 'SUM') then
            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec_new.salvage_type,
               token2     => 'PARAM',
               value2     => 'SALVAGE_TYPE', p_log_level_rec => p_log_level_rec);

         else
            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec_new.deprn_limit_type,
               token2     => 'PARAM',
               value2     => 'DEPRN_LIMIT_TYPE', p_log_level_rec => p_log_level_rec);
         end if;

         return false;
      end if;

   end if; -- (((px_asset_fin_rec_new.salvage_type = 'SUM') and

   if ((px_trans_rec.transaction_type_code = 'GROUP ADDITION' and
       nvl(p_asset_deprn_rec.deprn_reserve, 0) = 0) and
      (px_trans_rec.transaction_key not in( 'MA','MJ','MC','MV','MD','MN'))
     and (px_asset_fin_rec_new.cost = 0 and px_asset_fin_rec_new.cip_cost = 0) -- Necessary??
        or ( px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
             px_trans_rec.transaction_key = 'GJ' and
             p_asset_fin_rec_old.date_placed_in_service <> px_asset_fin_rec_new.date_placed_in_service))
     then
     -- Group Addition or adjustment in period of group addition before
     -- depreciation run or first member addition

      if not createGroup(
                         p_trans_rec            => px_trans_rec,
                         p_asset_hdr_rec        => p_asset_hdr_rec,
                         p_asset_type_rec       => p_asset_type_rec,
                         p_period_rec           => p_period_rec,
                         p_asset_fin_rec        => px_asset_fin_rec_new,
                         p_asset_deprn_rec      => p_asset_deprn_rec_adj,
                         p_mrc_sob_type_code    => p_mrc_sob_type_code,
                         p_calling_fn           => l_calling_fn,
                         p_log_level_rec        => p_log_level_rec) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('calc_fin_info', 'calling FA_AMORT_PVT.createGroup', 'FAILED',  p_log_level_rec => p_log_level_rec);
         end if;

         return (FALSE);

      end if;

      return true;
   elsif (px_trans_rec.transaction_type_code = 'ADDITION' or
          px_trans_rec.transaction_type_code = 'CIP ADDITION' or
           px_trans_rec.transaction_type_code = 'ADJUSTMENT' or
          px_trans_rec.transaction_type_code = 'CIP ADJUSTMENT') and
         (p_asset_fin_rec_old.group_asset_id is not null or
          px_asset_fin_rec_new.group_asset_id is not null)
      and (nvl(px_trans_rec.amortization_start_date,
               px_trans_rec.transaction_date_entered) <
           p_period_rec.calendar_period_open_date)
      then
      -- Member addition and adjustment that has impact to the group

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('calc_fin_info', 'calling FA_AMORT_PVT.maintainGroup', 'FAILED',  p_log_level_rec => p_log_level_rec);
         end if;

   end if;


   populate_fin_rec(
             p_trans_rec          => px_trans_rec,
             p_asset_fin_rec_old  => p_asset_fin_rec_old,
             p_asset_fin_rec_adj  => p_asset_fin_rec_adj,
             p_asset_fin_rec_new  => px_asset_fin_rec_new,
             x_asset_fin_rec_adj  => l_asset_fin_rec_adj,
             p_log_level_rec      => p_log_level_rec);

   -- Bug4958977: Adding following entire if statement
   -- trx could be dpis change if following conditions are met
   -- even though trx date is in current period
--tk_util.DumpFinRec(p_asset_fin_rec_adj, 'adj fin_rec');
   if (px_trans_rec.transaction_key = 'MJ' and
       nvl(p_asset_fin_rec_adj.cost, 0) = 0 and
       nvl(p_asset_fin_rec_adj.cip_cost, 0) = 0 and
       nvl(p_asset_fin_rec_adj.salvage_value, 0) = 0 and
       nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) = 0) and
      (nvl(px_trans_rec.amortization_start_date,
           px_trans_rec.transaction_date_entered) >=
                  p_period_rec.calendar_period_open_date) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'could be dpis change', 'cont', p_log_level_rec => p_log_level_rec);
      end if;

      OPEN c_check_dpis_change;
      FETCH c_check_dpis_change INTO l_temp_thid;
      CLOSE c_check_dpis_change;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'temp_thid', l_temp_thid, p_log_level_rec => p_log_level_rec);
      end if;

      if (l_temp_thid is not null) then
         l_call_bs := TRUE;
      else
         l_call_bs := FALSE;
      end if;
   end if;

   -- Bug4037112: Change for ATT 0 cost change
   X_deprn_rsv := 0;

   if (not l_call_bs) and
      (px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT') and
      (nvl(px_asset_fin_rec_new.tracking_method, 'NULL') <> 'CALCULATE') and
      (nvl(l_asset_fin_rec_adj.cost, 0) = 0) and
      ((px_trans_rec.transaction_key = 'MA')
          or
       (px_trans_rec.transaction_key = 'MJ' and
        (px_asset_fin_rec_new.salvage_type not in ('SUM', 'AMT')) and
        (px_asset_fin_rec_new.deprn_limit_type not in ('SUM', 'AMT')))
         ) then

      -- Bug4958977: Need to check possibility of dpis change.
      -- This time, possible that dpis is changed from current to old
      -- date.
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'could be dpis change(cur to old)', 'cont');
      end if;

      OPEN c_check_dpis_change;
      FETCH c_check_dpis_change INTO l_temp_thid;
      CLOSE c_check_dpis_change;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'temp_thid', l_temp_thid, p_log_level_rec => p_log_level_rec);
      end if;

      if (l_temp_thid is not null) then
         l_call_bs := TRUE;
      else
         l_call_bs := FALSE;
      end if;

      if (not l_call_bs) then
         -- No Need to Maintain FA_BOOKS_SUMMARY Table
         return true;
      end if;
   end if;


   if (p_asset_type_rec.asset_type = 'GROUP') then
      if (nvl(px_trans_rec.amortization_start_date,
              px_trans_rec.transaction_date_entered) >=
          p_period_rec.calendar_period_open_date) and
         (px_trans_rec.transaction_key not in ('MR', 'MS', 'GC')) and (not l_call_bs) then

         if (not  CurrentPeriodAdj(
                    p_trans_rec           => px_trans_rec,
                    p_asset_hdr_rec       => p_asset_hdr_rec,
                    p_asset_type_rec      => p_asset_type_rec,
                    p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                    p_asset_fin_rec_old   => p_asset_fin_rec_old,
                    px_asset_fin_rec_new  => px_asset_fin_rec_new,
                    p_period_rec          => p_period_rec,
                    p_asset_deprn_rec_adj => p_asset_deprn_rec_adj,
                    p_proceeds_of_sale    => nvl(p_proceeds_of_sale, 0),
                    p_cost_of_removal     => nvl(p_cost_of_removal, 0),
                    p_calling_fn          => l_calling_fn,
                    p_mrc_sob_type_code   => p_mrc_sob_type_code,
                    p_log_level_rec       => p_log_level_rec)) then
            raise calc_err;
         end if;

      else

         if (l_asset_fin_rec_adj.eofy_reserve is null) and
            (p_asset_deprn_rec_adj.deprn_reserve is not null) and
            (p_asset_deprn_rec_adj.ytd_deprn is not null) then
            l_asset_fin_rec_adj.eofy_reserve :=
                  p_asset_deprn_rec_adj.deprn_reserve - p_asset_deprn_rec_adj.ytd_deprn;
         end if;


         if (not bsRecalculate(
                   p_trans_rec            => px_trans_rec,
                   p_asset_hdr_rec        => p_asset_hdr_rec,
                   p_asset_type_rec       => p_asset_type_rec,
                   p_asset_desc_rec       => p_asset_desc_rec,
                   p_asset_fin_rec_old    => p_asset_fin_rec_old,
                   p_asset_fin_rec_adj    => l_asset_fin_rec_adj,
                   p_period_rec           => p_period_rec,
                   px_asset_fin_rec_new   => px_asset_fin_rec_new,
                   p_asset_deprn_rec      => p_asset_deprn_rec,
                   p_asset_deprn_rec_adj  => p_asset_deprn_rec_adj,
                   x_deprn_expense        => x_deprn_exp,
                   x_bonus_expense        => x_bonus_deprn_exp,
                   x_impairment_expense   => x_impairment_exp,
                   x_deprn_reserve        => x_deprn_rsv,
                   p_running_mode         => p_running_mode,
                   p_used_by_revaluation  => p_used_by_revaluation,
                   p_reclassed_asset_id   => p_reclassed_asset_id,
                   p_reclass_src_dest     => p_reclass_src_dest,
                   p_reclassed_asset_dpis => p_reclassed_asset_dpis,
                   p_update_books_summary => p_update_books_summary,
                   p_mrc_sob_type_code    => p_mrc_sob_type_code,
                   p_calling_fn           => l_calling_fn,
                    p_log_level_rec       => p_log_level_rec)) then
            raise calc_err;
         end if;
      end if; -- (nvl(px_trans_rec.amortization_start_date,
   end if; -- (p_asset_type_rec.asset_type = 'GROUP')

--tk_util.DumpFinRec(px_asset_fin_rec_new, 'Nfaxama');

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', p_asset_type_rec.asset_type||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;
--tk_util.debug('-+++++-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');

--   err:=DBMS_PROFILER.STOP_PROFILER;

/*
for r_get_profiler in c_get_profiler loop
null;
--tk_util.debug('runid: '||to_char(r_get_profiler.runid));
--tk_util.debug('run_date: '||to_char(r_get_profiler.run_date, 'DD-MON-YYYY HH24:MI:SS'));
--tk_util.debug('run_comment: '||r_get_profiler.run_comment);
end loop;
*/

   return TRUE;

exception
   when calc_err then
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'calc_err', p_log_level_rec => p_log_level_rec);
        end if;

        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
        end if;

        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return  FALSE;
end faxama;


--+==============================================================================
-- Function: GetExpRsv
--
--   This function return expense or reserve amounts incurred due to some
--   transaction such as unplanned, reserve transfer and retirement adjustment.
--
--   Transaction                   Transaction_Key
--  ----------------------         ---------------
--  Retirement Adjustment          GR
--  Reserve Transfer               GV
--  Unplanned Depreciation         UA or UE
--
--+==============================================================================
FUNCTION GetExpRsv(
     p_trans_rec                        FA_API_TYPES.trans_rec_type,
     p_asset_hdr_rec                    FA_API_TYPES.asset_hdr_rec_type,
     p_period_rec                       FA_API_TYPES.period_rec_type,
     p_mrc_sob_type_code                VARCHAR2,
     x_exp_rsv_amount       OUT NOCOPY  NUMBER
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

  l_calling_fn     VARCHAR2(50) := 'FA_AMORT_PVT.GetExpRsv';

  --
  -- This cursor doesn't include period counter created as condition
  -- because it is not certain that prior period unplanned is allowed
  -- and if it is allowed, whether fa_adjsutments stores period_counter
  -- created as the period of amortization start date or not.
  -- If period counter created is the period of amortization start date,
  -- then period counter can be used as a one of condition.
  --
  CURSOR c_get_exp_amount IS
    select
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0)
    from   fa_adjustments adj
    where adj.transaction_header_id = p_trans_rec.transaction_header_id
    and   adj.asset_id = p_asset_hdr_rec.asset_id
    and   adj.book_type_code = p_asset_hdr_rec.book_type_code;

  CURSOR c_get_mc_exp_amount IS
    select
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0)
    from   fa_mc_adjustments adj
    where adj.transaction_header_id = p_trans_rec.transaction_header_id
    and   adj.asset_id = p_asset_hdr_rec.asset_id
    and   adj.book_type_code = p_asset_hdr_rec.book_type_code
    and   adj.set_of_books_id = p_asset_hdr_rec.set_of_books_id;


BEGIN

   --
   -- Case of Unplanned Depreciation
   --
   if (p_mrc_sob_type_code = 'R') then
      OPEN c_get_mc_exp_amount;
      FETCH c_get_mc_exp_amount INTO x_exp_rsv_amount;
      CLOSE c_get_mc_exp_amount;
   else
      OPEN c_get_exp_amount;
      FETCH c_get_exp_amount INTO x_exp_rsv_amount;
      CLOSE c_get_exp_amount;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Found Expense:'||p_trans_rec.transaction_key, x_exp_rsv_amount, p_log_level_rec => p_log_level_rec);
   end if;


   return true;

EXCEPTION
   WHEN others THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END GetExpRsv;

--+==============================================================================
-- Function: GetDeprnRec
--
--   The function returns FA_API_TYPES.asset_deprn_rec_type.
--   This will be the starting point for recalculating depreciation.
--
--+==============================================================================
FUNCTION GetDeprnRec (
     p_trans_rec                        FA_API_TYPES.trans_rec_type,
     p_asset_hdr_rec                    FA_API_TYPES.asset_hdr_rec_type,
     p_period_rec                       FA_API_TYPES.period_rec_type,
     p_incoming_trx_type_code           VARCHAR2 default 'NULL',
     x_asset_deprn_rec       OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
     p_mrc_sob_type_code                VARCHAR2,
     p_unplanned_exp      IN OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  CURSOR c_check_period IS
    select 'Y'
    from   fa_deprn_summary
    where  asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    period_counter <= p_period_rec.period_counter;
/*
    from   fa_deprn_periods
    where  book_type_code = p_asset_hdr_rec.book_type_code
    and    period_counter = p_period_rec.period_counter;
*/

  -- Return values if year of first transaction is the same year as addition happened.
  CURSOR c_get_eofy_rsv IS
    select ds.deprn_reserve - ds.ytd_deprn
         , ds.bonus_deprn_reserve - ds.bonus_ytd_deprn
         , ds.impairment_reserve - ds.ytd_impairment
         , ds.ltd_production - ds.ytd_production
         , ds.reval_reserve - ds.ytd_reval_deprn_expense
    from   fa_fiscal_year fy
         , fa_deprn_summary ds
         , fa_deprn_periods dp
    where  ds.asset_id = p_asset_hdr_rec.asset_id
    and    ds.book_type_code = p_asset_hdr_rec.book_type_code
    and    ds.deprn_source_code = 'BOOKS'
    and    dp.book_type_code = p_asset_hdr_rec.book_type_code
    and    dp.period_counter = ds.period_counter + 1 --Bug6987743: add one
    and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
    and    fy.fiscal_year = (dp.period_counter - dp.period_num)/fa_cache_pkg.fazcct_record.number_per_fiscal_year
    and    fy.fiscal_year = (p_period_rec.period_counter + 1 - p_period_rec.period_num)/
                                 fa_cache_pkg.fazcct_record.number_per_fiscal_year;

  CURSOR c_get_books_rsv IS
    select ds.deprn_reserve
         , ds.bonus_deprn_reserve
         , ds.impairment_reserve
         , ds.ltd_production
         , ds.reval_reserve
    from   fa_deprn_summary ds
    where  ds.asset_id = p_asset_hdr_rec.asset_id
    and    ds.book_type_code = p_asset_hdr_rec.book_type_code
    and    ds.deprn_source_code = 'BOOKS';

  CURSOR c_get_adjs IS
     SELECT NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                              'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'BONUS RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                              'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'BONUS EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'IMPAIR RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                              'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'IMPAIR EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'DEPRN ADJUST',
                           DECODE(fa_cache_pkg.fazcbc_record.book_class,'TAX',
                                  DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT)))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'REVAL EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                              'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'REVAL AMORT',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                       'REVAL RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.SOURCE_TYPE_CODE,
                            'REVALUATION',
                              DECODE(ADJ.ADJUSTMENT_TYPE,
                                      'EXPENSE',
                                        DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                                'DR', ADJ.ADJUSTMENT_AMOUNT,
                                                'CR', -1*ADJ.ADJUSTMENT_AMOUNT)))), 0),
            NVL(SUM(DECODE(TH.TRANSACTION_KEY,
                           'UE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT),
                           'UA',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT)
                                )),
                0)
     FROM   FA_ADJUSTMENTS ADJ,
            FA_TRANSACTION_HEADERS TH
     WHERE  TH.ASSET_ID = p_asset_hdr_rec.asset_id
     AND    TH.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
     AND    TH.TRANSACTION_HEADER_ID <> p_trans_rec.transaction_header_id
     AND    TH.TRANSACTION_DATE_ENTERED <= p_trans_rec.transaction_date_entered
     AND    TH.DATE_EFFECTIVE < p_trans_rec.who_info.creation_date
     AND    TH.DATE_EFFECTIVE BETWEEN nvl(p_period_rec.period_open_date, TH.DATE_EFFECTIVE)
                                  AND nvl(p_period_rec.period_close_date, TH.DATE_EFFECTIVE)
     AND    TH.TRANSACTION_HEADER_ID = ADJ.TRANSACTION_HEADER_ID
     AND    ADJ.ASSET_ID =  p_asset_hdr_rec.asset_id
     AND    ADJ.BOOK_TYPE_CODE =  p_asset_hdr_rec.book_type_code
     --
     -- Bug3387996: next condition is nevessary to get adj amount only for this period
     -- Bug4741374: period_counter+1 is required to get the rsv from period of addition
     AND ADJ.PERIOD_COUNTER_CREATED = p_period_rec.period_counter + 1
     AND    ADJ.ADJUSTMENT_TYPE in ('RESERVE', 'EXPENSE')
     AND not exists ( select 1 from
                      fa_retirements ret,
                      fa_conventions con
                      where  th.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)
                      and    ret.transaction_header_id_in = th.transaction_header_id
                      and    ret.asset_id = p_asset_hdr_rec.asset_id
                      and    ret.book_type_code = p_asset_hdr_rec.book_type_code
                      and    ret.RETIREMENT_PRORATE_CONVENTION = con.PRORATE_CONVENTION_CODE
                      and    ret.date_retired between con.start_date and con.end_date
                      and    con.prorate_date > p_trans_rec.transaction_date_entered); -- Bug6899375 Added the not exists condition

  CURSOR c_get_mc_adjs IS
     SELECT NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                              'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'BONUS RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                              'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'BONUS EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'IMPAIR RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                              'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'IMPAIR EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'DEPRN ADJUST',
                           DECODE(fa_cache_pkg.fazcbc_record.book_class,'TAX',
                                  DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT)))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'REVAL EXPENSE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                              'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                           'REVAL AMORT',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                       'REVAL RESERVE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                0),
            NVL(SUM(DECODE(ADJ.SOURCE_TYPE_CODE,
                            'REVALUATION',
                              DECODE(ADJ.ADJUSTMENT_TYPE,
                                      'EXPENSE',
                                        DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                                'DR', ADJ.ADJUSTMENT_AMOUNT,
                                                'CR', -1*ADJ.ADJUSTMENT_AMOUNT)))), 0),
            NVL(SUM(DECODE(TH.TRANSACTION_KEY,
                           'UE',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT),
                           'UA',
                           DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                  'DR', ADJ.ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJ.ADJUSTMENT_AMOUNT)
                                )),
                0)
     FROM   FA_MC_ADJUSTMENTS ADJ,
            FA_TRANSACTION_HEADERS TH
     WHERE  TH.ASSET_ID = p_asset_hdr_rec.asset_id
     AND    TH.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
     AND    TH.TRANSACTION_HEADER_ID <> p_trans_rec.transaction_header_id
     AND    TH.TRANSACTION_DATE_ENTERED <= p_trans_rec.transaction_date_entered
     AND    TH.DATE_EFFECTIVE < p_trans_rec.who_info.creation_date
     AND    TH.DATE_EFFECTIVE BETWEEN nvl(p_period_rec.period_open_date, TH.DATE_EFFECTIVE)
                                  AND nvl(p_period_rec.period_close_date, TH.DATE_EFFECTIVE)
     AND    TH.TRANSACTION_HEADER_ID = ADJ.TRANSACTION_HEADER_ID
     AND    ADJ.ASSET_ID =  p_asset_hdr_rec.asset_id
     AND    ADJ.BOOK_TYPE_CODE =  p_asset_hdr_rec.book_type_code
     --
     -- Bug3387996: next condition is nevessary to get adj amount only for this period
     -- Bug4741374: period_counter+1 is required to get the rsv from period of addition
     AND ADJ.PERIOD_COUNTER_CREATED = p_period_rec.period_counter + 1
     AND ADJ.ADJUSTMENT_TYPE in ('RESERVE', 'EXPENSE')
     AND ADJ.SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id
     AND not exists ( select 1 from
                      fa_retirements ret,
                      fa_conventions con
                      where  th.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)
                      and    ret.transaction_header_id_in = th.transaction_header_id
                      and    ret.asset_id = p_asset_hdr_rec.asset_id
                      and    ret.book_type_code = p_asset_hdr_rec.book_type_code
                      and    ret.RETIREMENT_PRORATE_CONVENTION = con.PRORATE_CONVENTION_CODE
                      and    ret.date_retired between con.start_date and con.end_date
                      and    con.prorate_date > p_trans_rec.transaction_date_entered); -- Bug6899375 Added the not exists condition


  l_calling_fn         VARCHAR2(100) := 'FA_AMORT_PVT.GetDeprnRec';
  l_dpr                FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
  l_run_mode           VARCHAR2(20) := 'TRANSACTION';
  l_status             BOOLEAN;

  l_deprn_rsv          number;
  l_deprn_exp          number;
  l_bonus_deprn_rsv    number;
  l_bonus_deprn_amount number;
  l_impairment_rsv     number;
  l_impairment_amount  number;
  l_deprn_adjust_exp   number;
  l_reval_deprn_exp    number;
  l_reval_amo          number;
  l_reval_rsv          number;
  l_reval_exp          number;

  l_unplanned_exp       number;
  l_period_exists      VARCHAR2(1) := 'N';
  l_find_eofy_reserve  VARCHAR2(1) := 'Y';
  l_books_row_exists   boolean := FALSE;
  error_found   EXCEPTION;

BEGIN
  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'Begin', p_trans_rec.transaction_type_code||':'||
                      p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
  end if;

  OPEN c_check_period;
  FETCH c_check_period INTO l_period_exists;

  if (c_check_period%NOTFOUND) then
     l_period_exists := 'N';
  end if;

  CLOSE c_check_period;

--tk_util.debug('l_period_exists: '||l_period_exists);

  if (l_period_exists = 'Y') and (p_incoming_trx_type_code not like  '%ADDITION') then

     l_dpr.asset_id   := p_asset_hdr_rec.asset_id;
     l_dpr.book       := p_asset_hdr_rec.book_type_code;
     l_dpr.period_ctr := p_period_rec.period_counter;
     l_dpr.dist_id    := 0;
     l_dpr.mrc_sob_type_code := p_mrc_sob_type_code;
     l_dpr.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

     l_run_mode := 'STANDARD';

     fa_query_balances_pkg.query_balances_int(
                             X_DPR_ROW               => l_dpr,
                             X_RUN_MODE              => l_run_mode,
                             X_DEBUG                 => FALSE,
                             X_SUCCESS               => l_status,
                             X_CALLING_FN            => l_calling_fn,
                             X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

     if (NOT l_status) then

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'ERROR',
                            'Calling fa_query_balances_pkg.query_balances_int', p_log_level_rec => p_log_level_rec);
        end if;

        raise error_found;
     end if;

--     x_asset_deprn_rec.deprn_amount             := l_dpr.deprn_exp;
     x_asset_deprn_rec.deprn_amount             := 0; -- This needs to be 0 because this should only include
                                                      -- current period(period that starts recalculate) amounts
     x_asset_deprn_rec.ytd_deprn                := l_dpr.ytd_deprn;
     x_asset_deprn_rec.deprn_reserve            := l_dpr.deprn_rsv;
     x_asset_deprn_rec.prior_fy_expense         := l_dpr.prior_fy_exp;
--     x_asset_deprn_rec.bonus_deprn_amount       := l_dpr.bonus_deprn_amount;
     x_asset_deprn_rec.bonus_deprn_amount       := 0; -- This needs to be 0 because this should only include
                                                      -- current period(period that starts recalculate) amounts
     x_asset_deprn_rec.bonus_ytd_deprn          := l_dpr.bonus_ytd_deprn;
     x_asset_deprn_rec.bonus_deprn_reserve      := l_dpr.bonus_deprn_rsv;
     x_asset_deprn_rec.prior_fy_bonus_expense   := l_dpr.prior_fy_bonus_exp;
     x_asset_deprn_rec.impairment_amount        := 0;
     x_asset_deprn_rec.ytd_impairment           := l_dpr.ytd_impairment;
     x_asset_deprn_rec.impairment_reserve           := l_dpr.impairment_rsv;
     x_asset_deprn_rec.reval_amortization       := l_dpr.reval_amo;
     x_asset_deprn_rec.reval_amortization_basis := l_dpr.reval_amo_basis;
     x_asset_deprn_rec.reval_deprn_expense      := l_dpr.reval_deprn_exp;
     x_asset_deprn_rec.reval_ytd_deprn          := l_dpr.ytd_reval_deprn_exp;
     x_asset_deprn_rec.reval_deprn_reserve      := l_dpr.reval_rsv;
     x_asset_deprn_rec.production               := l_dpr.prod;
     x_asset_deprn_rec.ytd_production           := l_dpr.ytd_prod;
     x_asset_deprn_rec.ltd_production           := l_dpr.ltd_prod;
     x_asset_deprn_rec.impairment_reserve           := l_dpr.impairment_rsv;
     x_asset_deprn_rec.ytd_impairment           := l_dpr.ytd_impairment;
     x_asset_deprn_rec.impairment_amount        := l_dpr.impairment_amount;


  else
--tk_util.debug('No deprn info in db');
     if (p_incoming_trx_type_code like  '%ADDITION') then

        x_asset_deprn_rec.deprn_reserve            := 0;
        x_asset_deprn_rec.bonus_deprn_reserve      := 0;
        x_asset_deprn_rec.impairment_reserve           := 0;
        x_asset_deprn_rec.ltd_production           := 0;
        x_asset_deprn_rec.reval_deprn_reserve      := 0;

     else
--tk_util.debug('Get deprn info from BOOKS  row');
        if (fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag = 'Y') then
            OPEN c_get_eofy_rsv;
            FETCH c_get_eofy_rsv INTO x_asset_deprn_rec.deprn_reserve
                                , x_asset_deprn_rec.bonus_deprn_reserve
                                , x_asset_deprn_rec.impairment_reserve
                                , x_asset_deprn_rec.ltd_production
                                , x_asset_deprn_rec.reval_deprn_reserve;
            CLOSE c_get_eofy_rsv;
            l_books_row_exists := TRUE;
         end if;
         if (not l_books_row_exists) then
            OPEN c_get_books_rsv;
            FETCH c_get_books_rsv INTO x_asset_deprn_rec.deprn_reserve
                                , x_asset_deprn_rec.bonus_deprn_reserve
                                , x_asset_deprn_rec.impairment_reserve
                                , x_asset_deprn_rec.ltd_production
                                , x_asset_deprn_rec.reval_deprn_reserve;
            CLOSE c_get_books_rsv;
            l_books_row_exists := TRUE;
         end if;
        if (not l_books_row_exists) then
           x_asset_deprn_rec.deprn_reserve            := 0;
           x_asset_deprn_rec.bonus_deprn_reserve      := 0;
           x_asset_deprn_rec.impairment_reserve       := 0;
           x_asset_deprn_rec.ltd_production           := 0;
           x_asset_deprn_rec.reval_deprn_reserve      := 0;
        end if;

     end if;

     x_asset_deprn_rec.deprn_amount             := 0;
     x_asset_deprn_rec.ytd_deprn                := 0;
     x_asset_deprn_rec.prior_fy_expense         := 0;
     x_asset_deprn_rec.bonus_deprn_amount       := 0;
     x_asset_deprn_rec.impairment_amount        := 0;
     x_asset_deprn_rec.bonus_ytd_deprn          := 0;
     x_asset_deprn_rec.prior_fy_bonus_expense   := 0;
     x_asset_deprn_rec.ytd_impairment           := 0;
     x_asset_deprn_rec.reval_amortization       := 0;
     x_asset_deprn_rec.reval_amortization_basis := 0;
     x_asset_deprn_rec.reval_ytd_deprn          := 0;
     x_asset_deprn_rec.reval_deprn_reserve      := 0;
     x_asset_deprn_rec.production               := 0;
     x_asset_deprn_rec.ytd_production           := 0;


  end if;
--tk_util.DumpDeprnRec(x_asset_deprn_rec, 'GDS');

  if (p_mrc_sob_type_code = 'R') then
     OPEN c_get_mc_adjs;
     FETCH c_get_mc_adjs INTO l_deprn_rsv,
                              l_deprn_exp,
                              l_bonus_deprn_rsv,
                              l_bonus_deprn_amount,
                              l_impairment_rsv,
                              l_impairment_amount,
                              l_deprn_adjust_exp,
                              l_reval_deprn_exp,
                              l_reval_amo,
                              l_reval_rsv,
                              l_reval_exp,
                              l_unplanned_exp;
     CLOSE c_get_mc_adjs;
  else
     OPEN c_get_adjs;
     FETCH c_get_adjs INTO l_deprn_rsv,
                           l_deprn_exp,
                           l_bonus_deprn_rsv,
                           l_bonus_deprn_amount,
                           l_impairment_rsv,
                           l_impairment_amount,
                           l_deprn_adjust_exp,
                           l_reval_deprn_exp,
                           l_reval_amo,
                           l_reval_rsv,
                           l_reval_exp,
                           l_unplanned_exp;
     CLOSE c_get_adjs;
   end if;

  if (l_deprn_exp <> 0) then
     x_asset_deprn_rec.deprn_amount  := x_asset_deprn_rec.deprn_amount + l_deprn_exp;
     x_asset_deprn_rec.ytd_deprn     := x_asset_deprn_rec.ytd_deprn + l_deprn_exp;
     x_asset_deprn_rec.deprn_reserve := x_asset_deprn_rec.deprn_reserve  + l_deprn_exp -
                                        l_reval_exp;
  end if;

  if (l_bonus_deprn_amount <> 0) then
     x_asset_deprn_rec.bonus_deprn_amount  := x_asset_deprn_rec.bonus_deprn_amount +
                                              l_bonus_deprn_amount;
     x_asset_deprn_rec.bonus_ytd_deprn     := x_asset_deprn_rec.bonus_ytd_deprn +
                                              l_bonus_deprn_amount;
     x_asset_deprn_rec.bonus_deprn_reserve := x_asset_deprn_rec.bonus_deprn_reserve +
                                              l_bonus_deprn_amount;
  end if;

  if (l_impairment_amount <> 0) then
     x_asset_deprn_rec.impairment_amount  := x_asset_deprn_rec.impairment_amount +
                                             l_impairment_amount;
     x_asset_deprn_rec.ytd_impairment     := x_asset_deprn_rec.ytd_impairment +
                                             l_impairment_amount;
     x_asset_deprn_rec.impairment_reserve     := x_asset_deprn_rec.impairment_reserve +
                                             l_impairment_amount;
  end if;

  if (l_deprn_rsv <> 0) then
    x_asset_deprn_rec.deprn_reserve := x_asset_deprn_rec.deprn_reserve - l_deprn_rsv;
  end if;

--tk_util.DumpDeprnRec(x_asset_deprn_rec, 'GDA');
   p_unplanned_exp := l_unplanned_exp;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', x_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
  when error_found then
     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'error_found', p_log_level_rec => p_log_level_rec);
     end if;

     fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     return false;

  when others then
     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
     end if;

     fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     return false;

END GetDeprnRec;

--+==============================================================================
-- Function: GetEofyReserve
--
--+==============================================================================
FUNCTION GetEofyReserve(
     p_trans_rec                            FA_API_TYPES.trans_rec_type,
     p_trans_rec_cur                        FA_API_TYPES.trans_rec_type,
     p_asset_hdr_rec                        FA_API_TYPES.asset_hdr_rec_type,
     p_asset_type_rec                       FA_API_TYPES.asset_type_rec_type,
     p_period_rec                           FA_API_TYPES.period_rec_type,
     x_eofy_reserve              OUT NOCOPY NUMBER,
     x_transaction_header_id     OUT NOCOPY NUMBER,
     x_transaction_date_entered  OUT NOCOPY DATE,
     x_date_effective            OUT NOCOPY DATE,
     x_transaction_type_code     OUT NOCOPY VARCHAR2,
     p_mrc_sob_type_code                    VARCHAR2,
     p_calling_fn                           VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

  l_calling_fn  VARCHAR2(50) := 'FA_AMORT_PVT.GetEofyReserve';
  get_err    EXCEPTION;

  --
  -- Find transaction which is
  --   Entered in the same fiscal year as given transaction date
  --   The transaction has transaction_date ealier than the fiscal year start date
  -- In this case, Recalculation needs to go back more to recalculate because
  -- it is impossible to find eofy_reserve from fa_deprn_summary
  -- Bug 5654286 Excluded ADDITION/VOID transaction
  CURSOR c_get_other_trx IS
    select th.transaction_header_id    transaction_header_id,
           nvl(th.amortization_start_date, th.transaction_date_entered) transaction_date_entered,
           th.date_effective date_effective,
           th.transaction_type_code transaction_type_code
    from
           fa_transaction_headers th,
           fa_deprn_periods dp,
           fa_book_controls bc,
           fa_fiscal_year fy
    where  th.asset_id                  = p_asset_hdr_rec.asset_id
    and    th.book_type_code            = p_asset_hdr_rec.book_type_code
    and    bc.book_type_code            = p_asset_hdr_rec.book_type_code
    and    bc.fiscal_year_name          = fy.fiscal_year_name
    and    dp.book_type_code            = p_asset_hdr_rec.book_type_code
    and    dp.fiscal_year               = fy.fiscal_year
    and    dp.calendar_period_open_date = fy.start_date
    and    p_trans_rec.transaction_date_entered
                      between fy.start_date and end_date
    and    th.date_effective           >= dp.period_open_date
    and    th.transaction_date_entered < dp.calendar_period_open_date
    and    th.transaction_header_id    < p_trans_rec.transaction_header_id
    and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                            G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                            G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                            G_TRX_TYPE_TFR_VOID)
    and    not exists (select 1
from fa_deprn_summary ds
   , fa_deprn_periods dp2
where ds.asset_id = p_asset_hdr_rec.asset_id
and   ds.book_type_code            = p_asset_hdr_rec.book_type_code
and   dp.book_type_code =  p_asset_hdr_rec.book_type_code
and   dp.fiscal_year = fy.fiscal_year
and   ds.period_counter = dp2.period_counter -1
and   ds.deprn_source_code = 'BOOKS'
and   ds.deprn_reserve <> 0
and   th.date_effective between dp2.period_open_date and dp2.period_close_date
and   th.transaction_type_code    in (G_TRX_TYPE_ADD, G_TRX_TYPE_ADD_VOID))
;

  CURSOR c_get_ret_trx IS
    select nvl(sum(ret.reserve_retired), 0),
           nvl(sum(ret.eofy_reserve), 0)
    from   fa_retirements ret,
           fa_transaction_headers mth,
           fa_transaction_headers gth,
           fa_book_controls bc,
           fa_fiscal_year fy
    where  gth.asset_id                     = p_asset_hdr_rec.asset_id
    and    gth.book_type_code               = p_asset_hdr_rec.book_type_code
    and    bc.book_type_code                = p_asset_hdr_rec.book_type_code
    and    bc.fiscal_year_name              = fy.fiscal_year_name
    and    ret.date_retired between fy.start_date
                                and p_trans_rec.transaction_date_entered
    and    gth.member_transaction_header_id = mth.transaction_header_id
    and    mth.book_type_code               = p_asset_hdr_rec.book_type_code
    and    mth.transaction_header_id        = ret.transaction_header_id_in
    and    mth.asset_id                     = ret.asset_id
    and    gth.member_transaction_header_id = ret.transaction_header_id_in
    and    ret.book_type_code               = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out is null
    and    fy.start_date =
              (select fy.start_date
                 from fa_fiscal_year fy,
                      fa_book_controls bc
                where bc.book_type_code = p_asset_hdr_rec.book_type_code
                  and bc.fiscal_year_name  = fy.fiscal_year_name
                  and fy.start_date <= p_trans_rec.transaction_date_entered
                  and fy.end_date >= p_trans_rec.transaction_date_entered
              );

  CURSOR c_get_mc_ret_trx IS
    select nvl(sum(ret.reserve_retired), 0),
           nvl(sum(ret.eofy_reserve), 0)
    from   fa_mc_retirements ret,
           fa_transaction_headers mth,
           fa_transaction_headers gth,
           fa_mc_book_controls mbc,
           fa_book_controls bc,
           fa_fiscal_year fy
    where  gth.asset_id                     = p_asset_hdr_rec.asset_id
    and    gth.book_type_code               = p_asset_hdr_rec.book_type_code
    and    bc.book_type_code                = p_asset_hdr_rec.book_type_code
    and    mbc.book_type_code               = p_asset_hdr_rec.book_type_code
    and    mbc.set_of_books_id              = p_asset_hdr_rec.set_of_books_id
    and    bc.fiscal_year_name              = fy.fiscal_year_name
    and    ret.date_retired between fy.start_date
                                and p_trans_rec.transaction_date_entered
    and    gth.member_transaction_header_id = mth.transaction_header_id
    and    mth.book_type_code               = p_asset_hdr_rec.book_type_code
    and    mth.transaction_header_id        = ret.transaction_header_id_in
    and    mth.asset_id                     = ret.asset_id
    and    gth.member_transaction_header_id = ret.transaction_header_id_in
    and    ret.book_type_code               = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out is null
    and    ret.set_of_books_id               = p_asset_hdr_rec.set_of_books_id
    and    fy.start_date =
              (select fy.start_date
                 from fa_fiscal_year fy,
                      fa_mc_book_controls bc
                where bc.book_type_code = p_asset_hdr_rec.book_type_code
                  and bc.set_of_books_id = p_asset_hdr_rec.set_of_books_id
                  and bc.fiscal_year_name  = fy.fiscal_year_name
                  and fy.start_date <= p_trans_rec.transaction_date_entered
                  and fy.end_date >= p_trans_rec.transaction_date_entered
              );

  CURSOR c_get_ret_trx2 IS
    select nvl(sum(ret.reserve_retired), 0),
           nvl(sum(ret.eofy_reserve), 0)
    from   fa_retirements ret,
           fa_transaction_headers th,
           fa_book_controls bc,
           fa_fiscal_year fy
    where  th.asset_id                     = p_asset_hdr_rec.asset_id
    and    th.book_type_code               = p_asset_hdr_rec.book_type_code
    and    bc.book_type_code               = p_asset_hdr_rec.book_type_code
    and    bc.fiscal_year_name             = fy.fiscal_year_name
    and    ret.date_retired between fy.start_date
                                and p_trans_rec.transaction_date_entered
    and    th.transaction_header_id        = ret.transaction_header_id_in
    and    th.asset_id                     = ret.asset_id
    and    ret.book_type_code              = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id_out is null;

--  CURSOR c_get_mc_ret_trx2 IS

  CURSOR c_get_deprn_period IS
    select period_counter - 1
         , period_open_date
         , period_close_date
         , period_num
    from   fa_deprn_periods
    where  book_type_code = p_asset_hdr_rec.book_type_code
    and    p_trans_rec.transaction_date_entered between
             calendar_period_open_date and calendar_period_close_date;

  -- Get the transaction before the member addition's transaction which member is reclassed
  -- on same fiscal year.

  CURSOR c_get_other_trx2 IS
    select th.transaction_header_id    transaction_header_id,
           nvl(th.amortization_start_date, th.transaction_date_entered) transaction_date_entered,
           th.date_effective date_effective,
           th.transaction_type_code transaction_type_code
    from   fa_transaction_headers th
    where  th.asset_id              = p_asset_hdr_rec.asset_id
    and    th.book_type_code        = p_asset_hdr_rec.book_type_code
    and    th.transaction_header_id =
       -- Get the latest trasnaction of reclassed member asset on group asset
      (select max(th.transaction_header_id)
       from   fa_transaction_headers th
       where  th.asset_id              =p_asset_hdr_rec.asset_id
       and    th.book_type_code        = p_asset_hdr_rec.book_type_code
       and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                               G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                               G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                               G_TRX_TYPE_TFR_VOID)
       and   th.transaction_header_id <
          -- Get first transaction of reclassed member asset on group asset
         (select min(th.transaction_header_id)
          from   fa_transaction_headers th
          where  th.book_type_code  = p_asset_hdr_rec.book_type_code
          and    th.asset_id        = p_asset_hdr_rec.asset_id
          and    th.member_transaction_header_id in
             -- Get reclassed member's all transaction headers
            (select th.transaction_header_id
             from   fa_transaction_headers th
             where  th.book_type_code        = p_asset_hdr_rec.book_type_code
             and    th.asset_id in
                -- Get reclassed member's asset_id
               (select th.asset_id
                from   fa_transaction_headers th
                where  th.book_type_code  = p_asset_hdr_rec.book_type_code
                and    transaction_header_id in
                   -- Get reclassed transaction after this transaction's fiscal year
                  (select th.member_transaction_header_id
                   from   fa_transaction_headers th,
                          fa_deprn_periods dp,
                          fa_fiscal_year   fy,
                          fa_book_controls bc
                   where  th.asset_id           = p_asset_hdr_rec.asset_id
                   and    th.book_type_code     = p_asset_hdr_rec.book_type_code
                   and    dp.book_type_code     = p_asset_hdr_rec.book_type_code
                   and    dp.book_type_code = bc.book_type_code
                   and    bc.fiscal_year_name = fy.fiscal_year_name
                   and    p_trans_rec.transaction_date_entered
                                  between fy.start_date and fy.end_date
                   and    dp.fiscal_year= fy.fiscal_year
                   and    dp.period_num =1
                   and    th.date_effective >= dp.period_open_date
                   and    th.trx_reference_id is not null
                   and    th.member_transaction_header_id is not null
                   and    th.transaction_header_id    < p_trans_rec.transaction_header_id

    )))));


  CURSOR c_cur_eofy_reserve IS
    select nvl(bk.eofy_reserve,0)
    from   FA_BOOKS bk
    where  asset_id       = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id_out is null;


  l_transaction_header_id     NUMBER;
  l_transaction_date_entered  DATE;
  l_date_effective            DATE;
  l_transaction_type_code     VARCHAR2(30);

  l_period_rec                FA_API_TYPES.period_rec_type;
  l_asset_deprn_rec           FA_API_TYPES.asset_deprn_rec_type;

  l_unplanned_exp             NUMBER := 0;
  l_reserve_retired           NUMBER := 0;
  l_eofy_reserve_retired      NUMBER := 0;

BEGIN

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add('====='||l_calling_fn||'=====', 'Begin', to_char(p_trans_rec.transaction_header_id)||'=====');
  end if;

  if p_trans_rec_cur.transaction_header_id = p_trans_rec.transaction_header_id
       and p_trans_rec.transaction_date_entered between
             p_period_rec.calendar_period_open_date and p_period_rec.calendar_period_close_date
  then
      -- At current open period's transaction, get eofy_reserve from FA_BOOKS.

      x_transaction_header_id    := to_number(null);
      x_transaction_date_entered := null;
      x_date_effective           := null;

      OPEN c_cur_eofy_reserve;
      FETCH c_cur_eofy_reserve into x_eofy_reserve;
      CLOSE c_cur_eofy_reserve;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Can determine current eofy reserve from db ', x_eofy_reserve, p_log_level_rec => p_log_level_rec);
      end if;

  else

    OPEN c_get_other_trx;
    FETCH c_get_other_trx INTO l_transaction_header_id, l_transaction_date_entered,
                             l_date_effective, l_transaction_type_code;

--tk_util.debug('l_transaction_header_id: '||to_char(l_transaction_header_id));

    if (c_get_other_trx%NOTFOUND) then
--tk_util.debug('c_get_other_trx not found');
      OPEN c_get_other_trx2;
      FETCH c_get_other_trx2 INTO l_transaction_header_id, l_transaction_date_entered,
                             l_date_effective, l_transaction_type_code;
    end if;

    if (c_get_other_trx%NOTFOUND and c_get_other_trx2%NOTFOUND) then

       x_transaction_header_id    := to_number(null);
       x_transaction_date_entered := null;
       x_date_effective           := null;


        OPEN c_get_deprn_period;
        FETCH c_get_deprn_period INTO l_period_rec.period_counter,
                                      l_period_rec.period_open_date,
                                      l_period_rec.period_close_date,
                                      l_period_rec.period_num;

        if (c_get_deprn_period%NOTFOUND) then
           CLOSE c_get_deprn_period;

           x_eofy_reserve := 0;

           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'This must be addition so eofy reserve ', x_eofy_reserve, p_log_level_rec => p_log_level_rec);
           end if;
        else
          CLOSE c_get_deprn_period;

           if not GetDeprnRec (
                    p_trans_rec             => p_trans_rec,
                    p_asset_hdr_rec         => p_asset_hdr_rec,
                    p_period_rec            => l_period_rec,
                    x_asset_deprn_rec       => l_asset_deprn_rec,
                    p_mrc_sob_type_code     => p_mrc_sob_type_code,
                    p_unplanned_exp         => l_unplanned_exp,
                    p_log_level_rec       => p_log_level_rec) then

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                 'GetDeprnRec', p_log_level_rec => p_log_level_rec);
             end if;

             raise get_err;
           end if;

           if (p_mrc_sob_type_code = 'R') then
              OPEN c_get_mc_ret_trx;
              FETCH c_get_mc_ret_trx INTO l_reserve_retired, l_eofy_reserve_retired;
              CLOSE c_get_mc_ret_trx;
           else
              OPEN c_get_ret_trx;
              FETCH c_get_ret_trx INTO l_reserve_retired, l_eofy_reserve_retired;
              CLOSE c_get_ret_trx;
           end if;

           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'Sum of Reserve Retired',
                               l_reserve_retired, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'Sum of Eofy Reserve Retired',
                               l_eofy_reserve_retired, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'l_unplanned_exp ', l_unplanned_exp, p_log_level_rec => p_log_level_rec);
           end if;

           if (l_period_rec.period_num = 1) then
              x_eofy_reserve := l_asset_deprn_rec.deprn_reserve
                                + l_reserve_retired
                                - l_eofy_reserve_retired
                                - l_unplanned_exp;
           else
              x_eofy_reserve := l_asset_deprn_rec.deprn_reserve
                                + l_reserve_retired
                                - l_asset_deprn_rec.ytd_deprn
                                - l_eofy_reserve_retired;
                             -- - l_unplanned_exp; /* Commented for bug#7246137 */
           end if;

           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'Can determine eofy reserve from db ', x_eofy_reserve, p_log_level_rec => p_log_level_rec);
           end if;

        end if;

    else  -- c_get_other_trx/2 FOUND

       x_eofy_reserve             := to_number(null);
       x_transaction_header_id    := l_transaction_header_id;
       x_transaction_date_entered := l_transaction_date_entered;
       x_date_effective           := l_date_effective;
       x_transaction_type_code    := l_transaction_type_code;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'Need to go earlier trx',
                                       to_char(x_transaction_header_id)||':'||
                                       to_char(x_transaction_date_entered, 'DD-MON-RR HH24:MI:SS')||':'||
                                       to_char(x_date_effective, 'DD-MON-RR HH24:MI:SS'));
       end if;

    end if;  -- End of c_get_other_trx/2 NOTFOUND

    CLOSE c_get_other_trx;
    IF c_get_other_trx2%ISOPEN then
      CLOSE c_get_other_trx2;
    end if;

  end if; -- End of current period transaction or not

  fa_debug_pkg.add('====='||l_calling_fn||'=====', 'End', '=====', p_log_level_rec => p_log_level_rec);

  return TRUE;

EXCEPTION
   WHEN get_err THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'get_err', p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   WHEN others THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END GetEofyReserve;

--+==============================================================================
-- Function:  GetFinAdjRec
--
--
--
--
--
--+==============================================================================
FUNCTION GetFinAdjRec(
     p_asset_hdr_rec                         FA_API_TYPES.asset_hdr_rec_type,
     p_reclass_src_dest                      VARCHAR2,
     p_transaction_date_entered              DATE,
     x_asset_fin_rec_adj          OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     p_mrc_sob_type_code                     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return BOOLEAN is

  l_calling_fn  VARCHAR2(50) := 'FA_AMORT_PVT.GetFinAdjRec';
  get_err    EXCEPTION;

  CURSOR c_get_fin_adj_rec IS
    select decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(inbk.cost - nvl(outbk.cost, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(inbk.salvage_value - nvl(outbk.salvage_value, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(decode(inbk.production_capacity,
                      null, decode(outbk.production_capacity,
                                   null, null,
                                         outbk.production_capacity),
                            nvl(inbk.production_capacity, 0) -
                            nvl(outbk.production_capacity, 0)))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(decode(inbk.reval_amortization_basis,
                  null, decode(outbk.reval_amortization_basis,
                               null, null,
                                     outbk.reval_amortization_basis),
                        nvl(inbk.reval_amortization_basis, 0) -
                        nvl(outbk.reval_amortization_basis, 0)))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(decode(inbk.reval_ceiling,
                      null, decode(outbk.reval_ceiling,
                                   null, null,
                                         outbk.reval_ceiling),
                            nvl(inbk.reval_ceiling, 0) - nvl(outbk.reval_ceiling, 0)))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(inbk.unrevalued_cost - nvl(outbk.unrevalued_cost, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(nvl(inbk.allowed_deprn_limit_amount, 0) -
               nvl(outbk.allowed_deprn_limit_amount, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0))
    from   fa_transaction_headers th,
           fa_books inbk,
           fa_books outbk
    where  inbk.asset_id = p_asset_hdr_rec.asset_id
    and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
    and    outbk.asset_id(+) = p_asset_hdr_rec.asset_id
    and    outbk.book_type_code(+) = p_asset_hdr_rec.book_type_code
    and    inbk.transaction_header_id_in = th.transaction_header_id
    and    outbk.transaction_header_id_out(+) = th.transaction_header_id
    and    th.asset_id = p_asset_hdr_rec.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                               G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                               G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                               G_TRX_TYPE_TFR_VOID)
    and    nvl(th.amortization_start_date,
               th.transaction_date_entered) <= p_transaction_date_entered
    and    not exists(select 'Exclude This Retirement'
                      from   fa_retirements ret,
                             fa_transaction_headers reith
                      where  ret.transaction_header_id_in = th.transaction_header_id
                      and    ret.transaction_header_id_out = reith.transaction_header_id
                      and    nvl(reith.amortization_start_date,
                              reith.transaction_date_entered) <= p_transaction_date_entered)
    order by transaction_date_entered;

  CURSOR c_get_mc_fin_adj_rec IS
    select decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(inbk.cost - nvl(outbk.cost, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(inbk.salvage_value - nvl(outbk.salvage_value, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(decode(inbk.production_capacity,
                      null, decode(outbk.production_capacity,
                                   null, null,
                                         outbk.production_capacity),
                            nvl(inbk.production_capacity, 0) -
                            nvl(outbk.production_capacity, 0)))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(decode(inbk.reval_amortization_basis,
                  null, decode(outbk.reval_amortization_basis,
                               null, null,
                                     outbk.reval_amortization_basis),
                        nvl(inbk.reval_amortization_basis, 0) -
                        nvl(outbk.reval_amortization_basis, 0)))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(decode(inbk.reval_ceiling,
                      null, decode(outbk.reval_ceiling,
                                   null, null,
                                         outbk.reval_ceiling),
                            nvl(inbk.reval_ceiling, 0) - nvl(outbk.reval_ceiling, 0)))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(inbk.unrevalued_cost - nvl(outbk.unrevalued_cost, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(nvl(inbk.allowed_deprn_limit_amount, 0) -
               nvl(outbk.allowed_deprn_limit_amount, 0))
         , decode(p_reclass_src_dest, 'SOURCE', -1, 1) * sum(nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0))
    from   fa_transaction_headers th,
           fa_mc_books inbk,
           fa_mc_books outbk
    where  inbk.asset_id = p_asset_hdr_rec.asset_id
    and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
    and    inbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
    and    outbk.asset_id(+) = p_asset_hdr_rec.asset_id
    and    outbk.book_type_code(+) = p_asset_hdr_rec.book_type_code
    and    outbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
    and    inbk.transaction_header_id_in = th.transaction_header_id
    and    outbk.transaction_header_id_out(+) = th.transaction_header_id
    and    th.asset_id = p_asset_hdr_rec.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                               G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                               G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                               G_TRX_TYPE_TFR_VOID)
    and    nvl(th.amortization_start_date,
               th.transaction_date_entered) <= p_transaction_date_entered
    and    not exists(select 'Exclude This Retirement'
                      from   fa_mc_retirements ret,
                             fa_transaction_headers reith
                      where  ret.transaction_header_id_in = th.transaction_header_id
                      and    ret.transaction_header_id_out = reith.transaction_header_id
                      and    ret.set_of_books_id = p_asset_hdr_rec.set_of_books_id
                      and    nvl(reith.amortization_start_date,
                              reith.transaction_date_entered) <= p_transaction_date_entered)
    order by transaction_date_entered;


BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin',
                       to_char(p_asset_hdr_rec.asset_id)||':'||
                       to_char(p_transaction_date_entered, 'DD-MON-YYYY'));
   end if;

   if (p_mrc_sob_type_code = 'R') then
      OPEN c_get_mc_fin_adj_rec;
      FETCH c_get_mc_fin_adj_rec INTO x_asset_fin_rec_adj.cost
                                    , x_asset_fin_rec_adj.salvage_value
                                    , x_asset_fin_rec_adj.production_capacity
                                    , x_asset_fin_rec_adj.reval_amortization_basis
                                    , x_asset_fin_rec_adj.reval_ceiling
                                    , x_asset_fin_rec_adj.unrevalued_cost
                                    , x_asset_fin_rec_adj.allowed_deprn_limit_amount
                                    , x_asset_fin_rec_adj.cip_cost;
      CLOSE c_get_mc_fin_adj_rec;
   else
      OPEN c_get_fin_adj_rec;
      FETCH c_get_fin_adj_rec INTO x_asset_fin_rec_adj.cost
                                 , x_asset_fin_rec_adj.salvage_value
                                 , x_asset_fin_rec_adj.production_capacity
                                 , x_asset_fin_rec_adj.reval_amortization_basis
                                 , x_asset_fin_rec_adj.reval_ceiling
                                 , x_asset_fin_rec_adj.unrevalued_cost
                                 , x_asset_fin_rec_adj.allowed_deprn_limit_amount
                                 , x_asset_fin_rec_adj.cip_cost;
      CLOSE c_get_fin_adj_rec;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End',
                       to_char(x_asset_fin_rec_adj.cost)||':'||
                       to_char(x_asset_fin_rec_adj.salvage_value)||':'||
                       to_char(x_asset_fin_rec_adj.production_capacity)||':'||
                       to_char(x_asset_fin_rec_adj.reval_amortization_basis)||':'||
                       to_char(x_asset_fin_rec_adj.reval_ceiling)||':'||
                       to_char(x_asset_fin_rec_adj.unrevalued_cost)||':'||
                       to_char(x_asset_fin_rec_adj.allowed_deprn_limit_amount)||':'||
                       to_char(x_asset_fin_rec_adj.cip_cost));
   end if;

   return true;

EXCEPTION
   WHEN get_err THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'get_err', p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   WHEN others THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;
END GetFinAdjRec;

--+==============================================================================
-- Function:  GetFinRec
--
--
--
--
--
--+==============================================================================
FUNCTION GetFinRec(
     p_trans_rec                  IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
     p_asset_hdr_rec                            FA_API_TYPES.asset_hdr_rec_type,
     p_asset_type_rec                           FA_API_TYPES.asset_type_rec_type,
     px_asset_fin_rec             IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     p_asset_fin_rec_adj                        FA_API_TYPES.asset_fin_rec_type,
     p_asset_fin_rec_new                        FA_API_TYPES.asset_fin_rec_type,
     x_asset_fin_rec_new             OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     p_init_transaction_header_id               FA_TRANSACTION_HEADERS.TRANSACTION_HEADER_ID%TYPE,
     p_use_fin_rec_adj                          BOOLEAN,
     p_use_new_deprn_rule                       BOOLEAN,
     p_process_this_trx                         BOOLEAN,
     x_dpis_change                   OUT NOCOPY BOOLEAN,
     p_mrc_sob_type_code                        VARCHAR2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
) return BOOLEAN IS

  Cursor c_get_init_bk IS
    select date_placed_in_service
         , deprn_start_date
         , deprn_method_code
         , life_in_months
         , rate_adjustment_factor
         , adjusted_cost
         , cost
         , original_cost
         , salvage_value
         , prorate_convention_code
         , prorate_date
         , cost_change_flag
         , adjustment_required_status
         , capitalize_flag
         , retirement_pending_flag
         , depreciate_flag
         , itc_amount_id
         , itc_amount
         , retirement_id
         , tax_request_id
         , itc_basis
         , basic_rate
         , adjusted_rate
         , bonus_rule
         , ceiling_name
         , recoverable_cost
         , adjusted_capacity
         , fully_rsvd_revals_counter
         , idled_flag
         , period_counter_capitalized
         , period_counter_fully_reserved
         , period_counter_fully_retired
         , production_capacity
         , reval_amortization_basis
         , reval_ceiling
         , unit_of_measure
         , unrevalued_cost
         , annual_deprn_rounding_flag
         , percent_salvage_value
         , allowed_deprn_limit
         , allowed_deprn_limit_amount
         , period_counter_life_complete
         , adjusted_recoverable_cost
         , annual_rounding_flag
         , eofy_adj_cost
         , eofy_formula_factor
         , short_fiscal_year_flag
         , conversion_date
         , ORIGINAL_DEPRN_START_DATE
         , remaining_life1
         , remaining_life2
         , group_asset_id
         , old_adjusted_cost
         , formula_factor
         , salvage_type
         , deprn_limit_type
         , over_depreciate_option
         , super_group_id
         , reduction_rate
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , recognize_gain_loss
         , recapture_reserve_flag
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , ytd_proceeds
         , ltd_proceeds
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , cip_cost
         , terminal_gain_loss_amount
         , ltd_cost_of_removal
         , prior_eofy_reserve
         , eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , global_attribute1
         , global_attribute2
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute20
         , global_attribute_category
         , nbv_at_switch
         , prior_deprn_limit_type
         , prior_deprn_limit_amount
         , prior_deprn_limit
         , prior_deprn_method
         , prior_life_in_months
         , prior_basic_rate
         , prior_adjusted_rate
    from   fa_books
    where  asset_id                   = p_asset_hdr_rec.asset_id
    and    book_type_code             = p_asset_hdr_rec.book_type_code
    and    (transaction_header_id_out = p_trans_rec.transaction_header_id
        or  (transaction_header_id_in < p_trans_rec.transaction_header_id and
             transaction_header_id_out is null))
    order by transaction_header_id_in desc;


  Cursor c_get_init_bk_winit IS
    select date_placed_in_service
         , deprn_start_date
         , deprn_method_code
         , life_in_months
         , rate_adjustment_factor
         , adjusted_cost
         , cost
         , original_cost
         , salvage_value
         , prorate_convention_code
         , prorate_date
         , cost_change_flag
         , adjustment_required_status
         , capitalize_flag
         , retirement_pending_flag
         , depreciate_flag
         , itc_amount_id
         , itc_amount
         , retirement_id
         , tax_request_id
         , itc_basis
         , basic_rate
         , adjusted_rate
         , bonus_rule
         , ceiling_name
         , recoverable_cost
         , adjusted_capacity
         , fully_rsvd_revals_counter
         , idled_flag
         , period_counter_capitalized
         , period_counter_fully_reserved
         , period_counter_fully_retired
         , production_capacity
         , reval_amortization_basis
         , reval_ceiling
         , unit_of_measure
         , unrevalued_cost
         , annual_deprn_rounding_flag
         , percent_salvage_value
         , allowed_deprn_limit
         , allowed_deprn_limit_amount
         , period_counter_life_complete
         , adjusted_recoverable_cost
         , annual_rounding_flag
         , eofy_adj_cost
         , eofy_formula_factor
         , short_fiscal_year_flag
         , conversion_date
         , ORIGINAL_DEPRN_START_DATE
         , remaining_life1
         , remaining_life2
         , group_asset_id
         , old_adjusted_cost
         , formula_factor
         , salvage_type
         , deprn_limit_type
         , over_depreciate_option
         , super_group_id
         , reduction_rate
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , recognize_gain_loss
         , recapture_reserve_flag
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , ytd_proceeds
         , ltd_proceeds
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , cip_cost
         , terminal_gain_loss_amount
         , ltd_cost_of_removal
         , prior_eofy_reserve
         , eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , global_attribute1
         , global_attribute2
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute20
         , global_attribute_category
         , nbv_at_switch
         , prior_deprn_limit_type
         , prior_deprn_limit_amount
         , prior_deprn_limit
         , prior_deprn_method
         , prior_life_in_months
         , prior_basic_rate
         , prior_adjusted_rate
    from   fa_books
    where  asset_id                   = p_asset_hdr_rec.asset_id
    and    book_type_code             = p_asset_hdr_rec.book_type_code
    and    (transaction_header_id_out = p_init_transaction_header_id
        or  (p_init_transaction_header_id > transaction_header_id_in and
             transaction_header_id_in < p_trans_rec.transaction_header_id and
             transaction_header_id_out is null))
    order by transaction_header_id_in desc;

  Cursor c_get_init_mcbk IS
    select date_placed_in_service
         , deprn_start_date
         , deprn_method_code
         , life_in_months
         , rate_adjustment_factor
         , adjusted_cost
         , cost
         , original_cost
         , salvage_value
         , prorate_convention_code
         , prorate_date
         , cost_change_flag
         , adjustment_required_status
         , capitalize_flag
         , retirement_pending_flag
         , depreciate_flag
         , itc_amount_id
         , itc_amount
         , retirement_id
         , tax_request_id
         , itc_basis
         , basic_rate
         , adjusted_rate
         , bonus_rule
         , ceiling_name
         , recoverable_cost
         , adjusted_capacity
         , fully_rsvd_revals_counter
         , idled_flag
         , period_counter_capitalized
         , period_counter_fully_reserved
         , period_counter_fully_retired
         , production_capacity
         , reval_amortization_basis
         , reval_ceiling
         , unit_of_measure
         , unrevalued_cost
         , annual_deprn_rounding_flag
         , percent_salvage_value
         , allowed_deprn_limit
         , allowed_deprn_limit_amount
         , period_counter_life_complete
         , adjusted_recoverable_cost
         , annual_rounding_flag
         , eofy_adj_cost
         , eofy_formula_factor
         , short_fiscal_year_flag
         , conversion_date
         , ORIGINAL_DEPRN_START_DATE
         , remaining_life1
         , remaining_life2
         , group_asset_id
         , old_adjusted_cost
         , formula_factor
         , salvage_type
         , deprn_limit_type
         , over_depreciate_option
         , super_group_id
         , reduction_rate
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , recognize_gain_loss
         , recapture_reserve_flag
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , ytd_proceeds
         , ltd_proceeds
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , cip_cost
         , terminal_gain_loss_amount
         , ltd_cost_of_removal
         , prior_eofy_reserve
         , eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , global_attribute1
         , global_attribute2
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute20
         , global_attribute_category
    from   fa_mc_books
    where  asset_id                  = p_asset_hdr_rec.asset_id
    and    set_of_books_id           = p_asset_hdr_rec.set_of_books_id
    and    book_type_code            = p_asset_hdr_rec.book_type_code
    and    (transaction_header_id_out = p_trans_rec.transaction_header_id
        or  (transaction_header_id_in < p_trans_rec.transaction_header_id and
             transaction_header_id_out is null))
    order by transaction_header_id_in desc;

  Cursor c_get_init_mcbk_winit IS
    select date_placed_in_service
         , deprn_start_date
         , deprn_method_code
         , life_in_months
         , rate_adjustment_factor
         , adjusted_cost
         , cost
         , original_cost
         , salvage_value
         , prorate_convention_code
         , prorate_date
         , cost_change_flag
         , adjustment_required_status
         , capitalize_flag
         , retirement_pending_flag
         , depreciate_flag
         , itc_amount_id
         , itc_amount
         , retirement_id
         , tax_request_id
         , itc_basis
         , basic_rate
         , adjusted_rate
         , bonus_rule
         , ceiling_name
         , recoverable_cost
         , adjusted_capacity
         , fully_rsvd_revals_counter
         , idled_flag
         , period_counter_capitalized
         , period_counter_fully_reserved
         , period_counter_fully_retired
         , production_capacity
         , reval_amortization_basis
         , reval_ceiling
         , unit_of_measure
         , unrevalued_cost
         , annual_deprn_rounding_flag
         , percent_salvage_value
         , allowed_deprn_limit
         , allowed_deprn_limit_amount
         , period_counter_life_complete
         , adjusted_recoverable_cost
         , annual_rounding_flag
         , eofy_adj_cost
         , eofy_formula_factor
         , short_fiscal_year_flag
         , conversion_date
         , ORIGINAL_DEPRN_START_DATE
         , remaining_life1
         , remaining_life2
         , group_asset_id
         , old_adjusted_cost
         , formula_factor
         , salvage_type
         , deprn_limit_type
         , over_depreciate_option
         , super_group_id
         , reduction_rate
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , recognize_gain_loss
         , recapture_reserve_flag
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , ytd_proceeds
         , ltd_proceeds
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , cip_cost
         , terminal_gain_loss_amount
         , ltd_cost_of_removal
         , prior_eofy_reserve
         , eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , global_attribute1
         , global_attribute2
         , global_attribute3
         , global_attribute4
         , global_attribute5
         , global_attribute6
         , global_attribute7
         , global_attribute8
         , global_attribute9
         , global_attribute10
         , global_attribute11
         , global_attribute12
         , global_attribute13
         , global_attribute14
         , global_attribute15
         , global_attribute16
         , global_attribute17
         , global_attribute18
         , global_attribute19
         , global_attribute20
         , global_attribute_category
    from   fa_mc_books
    where  set_of_books_id           = p_asset_hdr_rec.set_of_books_id
    and    asset_id                  = p_asset_hdr_rec.asset_id
    and    book_type_code            = p_asset_hdr_rec.book_type_code
    and    (transaction_header_id_out = p_init_transaction_header_id
        or  (p_init_transaction_header_id > transaction_header_id_in and
             transaction_header_id_in < p_trans_rec.transaction_header_id and
             transaction_header_id_out is null))
    order by transaction_header_id_in desc;

 /* Bug 4043619 : Modified the cursor for salvage_value, allow_deprn_limit and allow_deprn_limit_adjusted. */
 /* Bug 5384014 : Modified the cursor so that it returns the deprn_method_code correctly for assets
                  using depreciation method 'Units of production in hours' */
 /* Bug 6863138 : Need to calculate new deprn_limit values instead of delta */

  Cursor c_get_bk (c_asset_id              number,
                   c_transaction_header_id number) IS
    select inbk.date_placed_in_service
         , inbk.deprn_start_date
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code,
                        decode(inbk.life_in_months,
                                  outbk.life_in_months,
                                      decode(inbk.basic_rate,
                                                outbk.basic_rate,
                                                   decode(inbk.adjusted_rate,
                                                             outbk.adjusted_rate,
                                                                decode(inbk.production_capacity,
                                                                         outbk.production_capacity,
                                                                                    null,
                                                                                    inbk.deprn_method_code),
                                                                inbk.deprn_method_code),
                                                   inbk.deprn_method_code),
                                      inbk.deprn_method_code),
                        inbk.deprn_method_code)
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code,
                        decode(inbk.life_in_months,
                                outbk.life_in_months, null,
                                                      inbk.life_in_months),
                        inbk.life_in_months)
         , inbk.rate_adjustment_factor
         , inbk.adjusted_cost
         , inbk.cost - nvl(outbk.cost, 0)
         , inbk.original_cost
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                              'AMT',nvl(inbk.salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                               'PCT',nvl(inbk.salvage_value, 0)))
         , inbk.prorate_convention_code
         , inbk.prorate_date
         , inbk.cost_change_flag
         , inbk.adjustment_required_status
         , inbk.capitalize_flag
         , inbk.retirement_pending_flag
         , inbk.depreciate_flag
         , inbk.itc_amount_id
         , inbk.itc_amount
         , inbk.retirement_id
         , inbk.tax_request_id
         , inbk.itc_basis
--bug fix 5718524
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code,
                            decode(inbk.basic_rate,
                                    outbk.basic_rate,  decode(inbk.adjusted_rate,
                                                              outbk.adjusted_rate, null,
                                                              inbk.basic_rate),
                                                      inbk.basic_rate),
                            inbk.basic_rate)
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code,
                            decode(inbk.adjusted_rate,
                                    outbk.adjusted_rate,  decode(inbk.basic_rate,
                                                              outbk.basic_rate, null,
                                                              inbk.adjusted_rate),
                                                         inbk.adjusted_rate),
                            inbk.adjusted_rate)
         , inbk.bonus_rule
         , inbk.ceiling_name
         , inbk.recoverable_cost
         , inbk.adjusted_capacity
         , decode(inbk.fully_rsvd_revals_counter,
                  null, decode(outbk.fully_rsvd_revals_counter,
                               null, null,
                                     outbk.fully_rsvd_revals_counter),
                        nvl(inbk.fully_rsvd_revals_counter, 0) -
                        nvl(outbk.fully_rsvd_revals_counter, 0))
         , inbk.idled_flag
         , inbk.period_counter_capitalized
         , inbk.period_counter_fully_reserved
         , inbk.period_counter_fully_retired
         , decode(inbk.production_capacity,
                  null, decode(outbk.production_capacity,
                               null, null,
                                     outbk.production_capacity),
                        nvl(inbk.production_capacity, 0) - nvl(outbk.production_capacity, 0))
         , decode(inbk.reval_amortization_basis,
                  null, decode(outbk.reval_amortization_basis,
                               null, null,
                                     outbk.reval_amortization_basis),
                        nvl(inbk.reval_amortization_basis, 0) -
                        nvl(outbk.reval_amortization_basis, 0))
         , decode(inbk.reval_ceiling,
                  null, decode(outbk.reval_ceiling,
                               null, null,
                                     outbk.reval_ceiling),
                        nvl(inbk.reval_ceiling, 0) - nvl(outbk.reval_ceiling, 0))
         , inbk.unit_of_measure
         , inbk.unrevalued_cost - nvl(outbk.unrevalued_cost, 0)
         , inbk.annual_deprn_rounding_flag
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                              'AMT',nvl(inbk.percent_salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                               'PCT',nvl(inbk.percent_salvage_value, 0)))
         ,decode(p_trans_rec.calling_interface, 'FAXASSET',decode(inbk.deprn_limit_type,
                                                        'PCT', nvl(inbk.allowed_deprn_limit, 0),
                                                        'AMT', nvl(inbk.allowed_deprn_limit, 0)),
                                              decode(inbk.deprn_limit_type,
                                                          'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                      'PCT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                                                                      'AMT',nvl(inbk.allowed_deprn_limit, 0)),
                                                          'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                       'AMT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                                                                       'PCT',nvl(inbk.allowed_deprn_limit, 0)))) --Bug7196658

         , decode(p_trans_rec.calling_interface, 'FAXASSET',decode(inbk.deprn_limit_type,
                                                          'PCT', nvl(inbk.allowed_deprn_limit_amount, 0),
                                                          'AMT', nvl(inbk.allowed_deprn_limit_amount, 0)),
                                                 decode(inbk.deprn_limit_type,
                                                          'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                      'PCT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                                                                      'AMT',nvl(inbk.allowed_deprn_limit_amount, 0)),
                                                          'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                       'AMT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                                                                       'PCT',nvl(inbk.allowed_deprn_limit_amount, 0)))) --Bug7196658
         , inbk.period_counter_life_complete
         , inbk.adjusted_recoverable_cost
         , inbk.annual_rounding_flag
         , inbk.eofy_adj_cost
         , inbk.eofy_formula_factor
         , inbk.short_fiscal_year_flag
         , inbk.conversion_date
         , inbk.ORIGINAL_DEPRN_START_DATE
         , inbk.remaining_life1
         , inbk.remaining_life2
         , inbk.group_asset_id
         , inbk.old_adjusted_cost
         , inbk.formula_factor
         , inbk.salvage_type
         , inbk.deprn_limit_type
         , inbk.over_depreciate_option
         , decode(inbk.super_group_id, outbk.super_group_id, null, inbk.super_group_id)
         , decode(inbk.reduction_rate,
                  null, decode(outbk.reduction_rate,
                               null, null,
                                     outbk.reduction_rate),
                        nvl(inbk.reduction_rate, 0) - nvl(outbk.reduction_rate, 0))
         , inbk.reduce_addition_flag
         , inbk.reduce_adjustment_flag
         , inbk.reduce_retirement_flag
         , inbk.recognize_gain_loss
         , inbk.recapture_reserve_flag
         , inbk.limit_proceeds_flag
         , inbk.terminal_gain_loss
         , inbk.tracking_method
         , inbk.exclude_fully_rsv_flag
         , inbk.excess_allocation_option
         , inbk.depreciation_option
         , inbk.member_rollup_flag
         , inbk.ytd_proceeds
         , inbk.ltd_proceeds
         , inbk.allocate_to_fully_rsv_flag
         , inbk.allocate_to_fully_ret_flag
         , nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0)
         , inbk.terminal_gain_loss_amount
         , inbk.ltd_cost_of_removal
         , inbk.prior_eofy_reserve
         , nvl(inbk.eofy_reserve, 0) - nvl(outbk.eofy_reserve, 0)
         , inbk.eop_adj_cost
         , inbk.eop_formula_factor
         , inbk.global_attribute1
         , inbk.global_attribute2
         , inbk.global_attribute3
         , inbk.global_attribute4
         , inbk.global_attribute5
         , inbk.global_attribute6
         , inbk.global_attribute7
         , inbk.global_attribute8
         , inbk.global_attribute9
         , inbk.global_attribute10
         , inbk.global_attribute11
         , inbk.global_attribute12
         , inbk.global_attribute13
         , inbk.global_attribute14
         , inbk.global_attribute15
         , inbk.global_attribute16
         , inbk.global_attribute17
         , inbk.global_attribute18
         , inbk.global_attribute19
         , inbk.global_attribute20
         , inbk.global_attribute_category
         , inbk.nbv_at_switch
         , inbk.prior_deprn_limit_type
         , inbk.prior_deprn_limit_amount
         , inbk.prior_deprn_limit
         , inbk.prior_deprn_method
         , inbk.prior_life_in_months
         , inbk.prior_basic_rate
         , inbk.prior_adjusted_rate
    from   fa_books inbk,
           fa_books outbk
    where  inbk.asset_id = c_asset_id
    and    inbk.asset_id = outbk.asset_id(+)
    and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
    and    inbk.book_type_code = outbk.book_type_code(+)
    and    inbk.transaction_header_id_in = c_transaction_header_id
    and    inbk.transaction_header_id_in = outbk.transaction_header_id_out(+);

/* Bug 4043619 : Modified the mrc cursor for salvage_value, allow_deprn_limit and allow_deprn_limit_adjusted. */
/* Bug 5384014 : Modified the mrc cursor so that it returns the deprn_method_code correctly for assets
                  using depreciation method 'Units of production in hours' */
/* Bug 6863138 : Need to calculate new deprn_limit values instead of delta */

  Cursor c_get_mcbk (c_asset_id              number,
                   c_transaction_header_id number) IS
    select inbk.date_placed_in_service
         , inbk.deprn_start_date
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code,
                        decode(inbk.life_in_months,
                                  outbk.life_in_months,
                                      decode(inbk.basic_rate,
                                                outbk.basic_rate,
                                                   decode(inbk.adjusted_rate,
                                                             outbk.adjusted_rate,
                                                                decode(inbk.production_capacity,
                                                                         outbk.production_capacity,
                                                                                    null,
                                                                                    inbk.deprn_method_code),
                                                                inbk.deprn_method_code),
                                                   inbk.deprn_method_code),
                                      inbk.deprn_method_code),
                        inbk.deprn_method_code)
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code, decode(inbk.life_in_months,
                                                        outbk.life_in_months, null,
                                                                            inbk.life_in_months),
                                              inbk.life_in_months)
         , inbk.rate_adjustment_factor
         , inbk.adjusted_cost
         , inbk.cost - nvl(outbk.cost, 0)
         , inbk.original_cost
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                              'AMT',nvl(inbk.salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                               'PCT',nvl(inbk.salvage_value, 0)))
         , inbk.prorate_convention_code
         , inbk.prorate_date
         , inbk.cost_change_flag
         , inbk.adjustment_required_status
         , inbk.capitalize_flag
         , inbk.retirement_pending_flag
         , inbk.depreciate_flag
         , inbk.itc_amount_id
         , inbk.itc_amount
         , inbk.retirement_id
         , inbk.tax_request_id
         , inbk.itc_basis
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code, decode(inbk.basic_rate,
                                                        outbk.basic_rate, decode(inbk.adjusted_rate,
                                                                                 outbk.adjusted_rate, null,
                                                                                 inbk.basic_rate),
                                                                        inbk.basic_rate),
                                              inbk.basic_rate)
         , decode(inbk.deprn_method_code,
                     outbk.deprn_method_code, decode(inbk.adjusted_rate,
                                                        outbk.adjusted_rate, decode(inbk.basic_rate,
                                                                                    outbk.basic_rate, null,
                                                                                    inbk.adjusted_rate),
                                                                           inbk.adjusted_rate),
                                              inbk.adjusted_rate)
         , inbk.bonus_rule
         , inbk.ceiling_name
         , inbk.recoverable_cost
         , inbk.adjusted_capacity
         , decode(inbk.fully_rsvd_revals_counter,
                  null, decode(outbk.fully_rsvd_revals_counter,
                               null, null,
                                     outbk.fully_rsvd_revals_counter),
                        nvl(inbk.fully_rsvd_revals_counter, 0) -
                        nvl(outbk.fully_rsvd_revals_counter, 0))
         , inbk.idled_flag
         , inbk.period_counter_capitalized
         , inbk.period_counter_fully_reserved
         , inbk.period_counter_fully_retired
         , decode(inbk.production_capacity,
                  null, decode(outbk.production_capacity,
                               null, null,
                                     outbk.production_capacity),
                        nvl(inbk.production_capacity, 0) - nvl(outbk.production_capacity, 0))
         , decode(inbk.reval_amortization_basis,
                  null, decode(outbk.reval_amortization_basis,
                               null, null,
                                     outbk.reval_amortization_basis),
                        nvl(inbk.reval_amortization_basis, 0) -
                        nvl(outbk.reval_amortization_basis, 0))
         , decode(inbk.reval_ceiling,
                  null, decode(outbk.reval_ceiling,
                               null, null,
                                     outbk.reval_ceiling),
                        nvl(inbk.reval_ceiling, 0) - nvl(outbk.reval_ceiling, 0))
         , inbk.unit_of_measure
         , inbk.unrevalued_cost - nvl(outbk.unrevalued_cost, 0)
         , inbk.annual_deprn_rounding_flag
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                              'AMT',nvl(inbk.percent_salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                               'PCT',nvl(inbk.percent_salvage_value, 0)))
         ,decode(p_trans_rec.calling_interface, 'FAXASSET',decode(inbk.deprn_limit_type,
                                                        'PCT', nvl(inbk.allowed_deprn_limit, 0),
                                                        'AMT', nvl(inbk.allowed_deprn_limit, 0)),
                                              decode(inbk.deprn_limit_type,
                                                          'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                      'PCT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                                                                      'AMT',nvl(inbk.allowed_deprn_limit, 0)),
                                                          'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                       'AMT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                                                                       'PCT',nvl(inbk.allowed_deprn_limit, 0)))) --Bug7196658

         , decode(p_trans_rec.calling_interface, 'FAXASSET',decode(inbk.deprn_limit_type,
                                                          'PCT', nvl(inbk.allowed_deprn_limit_amount, 0),
                                                          'AMT', nvl(inbk.allowed_deprn_limit_amount, 0)),
                                                 decode(inbk.deprn_limit_type,
                                                          'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                      'PCT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                                                                      'AMT',nvl(inbk.allowed_deprn_limit_amount, 0)),
                                                          'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                                                                       'AMT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                                                                       'PCT',nvl(inbk.allowed_deprn_limit_amount, 0)))) --Bug7196658
         , inbk.period_counter_life_complete
         , inbk.adjusted_recoverable_cost
         , inbk.annual_rounding_flag
         , inbk.eofy_adj_cost
         , inbk.eofy_formula_factor
         , inbk.short_fiscal_year_flag
         , inbk.conversion_date
         , inbk.ORIGINAL_DEPRN_START_DATE
         , inbk.remaining_life1
         , inbk.remaining_life2
         , inbk.group_asset_id
         , inbk.old_adjusted_cost
         , inbk.formula_factor
         , inbk.salvage_type
         , inbk.deprn_limit_type
         , inbk.over_depreciate_option
         , decode(inbk.super_group_id, outbk.super_group_id, null, inbk.super_group_id)
         , decode(inbk.reduction_rate,
                  null, decode(outbk.reduction_rate,
                               null, null,
                                     outbk.reduction_rate),
                        nvl(inbk.reduction_rate, 0) - nvl(outbk.reduction_rate, 0))
         , inbk.reduce_addition_flag
         , inbk.reduce_adjustment_flag
         , inbk.reduce_retirement_flag
         , inbk.recognize_gain_loss
         , inbk.recapture_reserve_flag
         , inbk.limit_proceeds_flag
         , inbk.terminal_gain_loss
         , inbk.tracking_method
         , inbk.exclude_fully_rsv_flag
         , inbk.excess_allocation_option
         , inbk.depreciation_option
         , inbk.member_rollup_flag
         , inbk.ytd_proceeds
         , inbk.ltd_proceeds
         , inbk.allocate_to_fully_rsv_flag
         , inbk.allocate_to_fully_ret_flag
         , nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0)
         , inbk.terminal_gain_loss_amount
         , inbk.ltd_cost_of_removal
         , inbk.prior_eofy_reserve
         , nvl(inbk.eofy_reserve, 0) - nvl(outbk.eofy_reserve, 0)
         , inbk.eop_adj_cost
         , inbk.eop_formula_factor
         , inbk.global_attribute1
         , inbk.global_attribute2
         , inbk.global_attribute3
         , inbk.global_attribute4
         , inbk.global_attribute5
         , inbk.global_attribute6
         , inbk.global_attribute7
         , inbk.global_attribute8
         , inbk.global_attribute9
         , inbk.global_attribute10
         , inbk.global_attribute11
         , inbk.global_attribute12
         , inbk.global_attribute13
         , inbk.global_attribute14
         , inbk.global_attribute15
         , inbk.global_attribute16
         , inbk.global_attribute17
         , inbk.global_attribute18
         , inbk.global_attribute19
         , inbk.global_attribute20
         , inbk.global_attribute_category
    from   fa_mc_books inbk,
           fa_mc_books outbk
    where  inbk.asset_id = c_asset_id
    and    inbk.asset_id = outbk.asset_id(+)
    and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
    and    inbk.book_type_code = outbk.book_type_code(+)
    and    inbk.transaction_header_id_in = c_transaction_header_id
    and    inbk.transaction_header_id_in = outbk.transaction_header_id_out(+)
    and    inbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
    and    outbk.set_of_books_id(+) = p_asset_hdr_rec.set_of_books_id;

/* Bug 4043619 : Modified the cursor for salvage_value, allow_deprn_limit and allow_deprn_limit_adjusted. */

  -- In case px_asset_fin_rec is null
  Cursor c_get_bk2 (c_asset_id              number,
                        c_transaction_header_id number) IS
    select inbk.date_placed_in_service
         , inbk.deprn_start_date
         , inbk.deprn_method_code
         , inbk.life_in_months
         , inbk.rate_adjustment_factor
         , inbk.adjusted_cost
         , inbk.cost - nvl(outbk.cost, 0)
         , inbk.original_cost
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                              'AMT',nvl(inbk.salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                               'PCT',nvl(inbk.salvage_value, 0)))
         , inbk.prorate_convention_code
         , inbk.prorate_date
         , inbk.cost_change_flag
         , inbk.adjustment_required_status
         , inbk.capitalize_flag
         , inbk.retirement_pending_flag
         , inbk.depreciate_flag
         , inbk.itc_amount_id
         , inbk.itc_amount
         , inbk.retirement_id
         , inbk.tax_request_id
         , inbk.itc_basis
         , inbk.basic_rate
         , inbk.adjusted_rate
         , inbk.bonus_rule
         , inbk.ceiling_name
         , inbk.recoverable_cost
         , inbk.adjusted_capacity
         , decode(inbk.fully_rsvd_revals_counter,
                  null, decode(outbk.fully_rsvd_revals_counter,
                               null, null,
                                     outbk.fully_rsvd_revals_counter),
                        nvl(inbk.fully_rsvd_revals_counter, 0) -
                        nvl(outbk.fully_rsvd_revals_counter, 0))
         , inbk.idled_flag
         , inbk.period_counter_capitalized
         , inbk.period_counter_fully_reserved
         , inbk.period_counter_fully_retired
         , decode(inbk.production_capacity,
                  null, decode(outbk.production_capacity,
                               null, null,
                                     outbk.production_capacity),
                        nvl(inbk.production_capacity, 0) - nvl(outbk.production_capacity, 0))
         , decode(inbk.reval_amortization_basis,
                  null, decode(outbk.reval_amortization_basis,
                               null, null,
                                     outbk.reval_amortization_basis),
                        nvl(inbk.reval_amortization_basis, 0) -
                        nvl(outbk.reval_amortization_basis, 0))
         , decode(inbk.reval_ceiling,
                  null, decode(outbk.reval_ceiling,
                               null, null,
                                     outbk.reval_ceiling),
                        nvl(inbk.reval_ceiling, 0) - nvl(outbk.reval_ceiling, 0))
         , inbk.unit_of_measure
         , inbk.unrevalued_cost - nvl(outbk.unrevalued_cost, 0)
         , inbk.annual_deprn_rounding_flag
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                              'AMT',nvl(inbk.percent_salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                               'PCT',nvl(inbk.percent_salvage_value, 0)))
         , decode(inbk.deprn_limit_type,
                  'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                              'PCT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                              'AMT',nvl(inbk.allowed_deprn_limit, 0)),
                  'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                               'AMT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                               'PCT',nvl(inbk.allowed_deprn_limit, 0)))
        , decode(inbk.deprn_limit_type,
                  'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                              'PCT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                              'AMT',nvl(inbk.allowed_deprn_limit_amount, 0)),
                  'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                               'AMT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                               'PCT',nvl(inbk.allowed_deprn_limit_amount, 0)))
         , inbk.period_counter_life_complete
         , inbk.adjusted_recoverable_cost
         , inbk.annual_rounding_flag
         , inbk.eofy_adj_cost
         , inbk.eofy_formula_factor
         , inbk.short_fiscal_year_flag
         , inbk.conversion_date
         , inbk.ORIGINAL_DEPRN_START_DATE
         , inbk.remaining_life1
         , inbk.remaining_life2
         , inbk.group_asset_id
         , inbk.old_adjusted_cost
         , inbk.formula_factor
         , inbk.salvage_type
         , inbk.deprn_limit_type
         , inbk.over_depreciate_option
         , decode(inbk.super_group_id, outbk.super_group_id, null, inbk.super_group_id)
         , decode(inbk.reduction_rate,
                  null, decode(outbk.reduction_rate,
                               null, null,
                                     outbk.reduction_rate),
                        nvl(inbk.reduction_rate, 0) - nvl(outbk.reduction_rate, 0))
         , inbk.reduce_addition_flag
         , inbk.reduce_adjustment_flag
         , inbk.reduce_retirement_flag
         , inbk.recognize_gain_loss
         , inbk.recapture_reserve_flag
         , inbk.limit_proceeds_flag
         , inbk.terminal_gain_loss
         , inbk.tracking_method
         , inbk.exclude_fully_rsv_flag
         , inbk.excess_allocation_option
         , inbk.depreciation_option
         , inbk.member_rollup_flag
         , inbk.ytd_proceeds
         , inbk.ltd_proceeds
         , inbk.allocate_to_fully_rsv_flag
         , inbk.allocate_to_fully_ret_flag
         , nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0)
         , inbk.terminal_gain_loss_amount
         , inbk.ltd_cost_of_removal
         , inbk.prior_eofy_reserve
         , nvl(inbk.eofy_reserve, 0) - nvl(outbk.eofy_reserve, 0)
         , inbk.eop_adj_cost
         , inbk.eop_formula_factor
         , inbk.global_attribute1
         , inbk.global_attribute2
         , inbk.global_attribute3
         , inbk.global_attribute4
         , inbk.global_attribute5
         , inbk.global_attribute6
         , inbk.global_attribute7
         , inbk.global_attribute8
         , inbk.global_attribute9
         , inbk.global_attribute10
         , inbk.global_attribute11
         , inbk.global_attribute12
         , inbk.global_attribute13
         , inbk.global_attribute14
         , inbk.global_attribute15
         , inbk.global_attribute16
         , inbk.global_attribute17
         , inbk.global_attribute18
         , inbk.global_attribute19
         , inbk.global_attribute20
         , inbk.global_attribute_category
         , inbk.nbv_at_switch
         , inbk.prior_deprn_limit_type
         , inbk.prior_deprn_limit_amount
         , inbk.prior_deprn_limit
         , inbk.prior_deprn_method
         , inbk.prior_life_in_months
         , inbk.prior_basic_rate
         , inbk.prior_adjusted_rate
    from   fa_books inbk,
           fa_books outbk
    where  inbk.asset_id = c_asset_id
    and    inbk.asset_id = outbk.asset_id(+)
    and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
    and    inbk.book_type_code = outbk.book_type_code(+)
    and    inbk.transaction_header_id_in = c_transaction_header_id
    and    inbk.transaction_header_id_in = outbk.transaction_header_id_out(+);


/* Bug 4043619 : Modified the mrc cursor for salvage_value, allow_deprn_limit and allow_deprn_limit_adjusted. */

  -- In case px_asset_fin_rec is null
  Cursor c_get_mcbk2 (c_asset_id              number,
                   c_transaction_header_id number) IS
    select inbk.date_placed_in_service
         , inbk.deprn_start_date
         , inbk.deprn_method_code
         , inbk.life_in_months
         , inbk.rate_adjustment_factor
         , inbk.adjusted_cost
         , inbk.cost - nvl(outbk.cost, 0)
         , inbk.original_cost
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                              'AMT',nvl(inbk.salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',inbk.salvage_value - nvl(outbk.salvage_value, 0),
                               'PCT',nvl(inbk.salvage_value, 0)))
         , inbk.prorate_convention_code
         , inbk.prorate_date
         , inbk.cost_change_flag
         , inbk.adjustment_required_status
         , inbk.capitalize_flag
         , inbk.retirement_pending_flag
         , inbk.depreciate_flag
         , inbk.itc_amount_id
         , inbk.itc_amount
         , inbk.retirement_id
         , inbk.tax_request_id
         , inbk.itc_basis
         , inbk.basic_rate
         , inbk.adjusted_rate
         , inbk.bonus_rule
         , inbk.ceiling_name
         , inbk.recoverable_cost
         , inbk.adjusted_capacity
         , decode(inbk.fully_rsvd_revals_counter,
                  null, decode(outbk.fully_rsvd_revals_counter,
                               null, null,
                                     outbk.fully_rsvd_revals_counter),
                        nvl(inbk.fully_rsvd_revals_counter, 0) -
                        nvl(outbk.fully_rsvd_revals_counter, 0))
         , inbk.idled_flag
         , inbk.period_counter_capitalized
         , inbk.period_counter_fully_reserved
         , inbk.period_counter_fully_retired
         , decode(inbk.production_capacity,
                  null, decode(outbk.production_capacity,
                               null, null,
                                     outbk.production_capacity),
                        nvl(inbk.production_capacity, 0) - nvl(outbk.production_capacity, 0))
         , decode(inbk.reval_amortization_basis,
                  null, decode(outbk.reval_amortization_basis,
                               null, null,
                                     outbk.reval_amortization_basis),
                        nvl(inbk.reval_amortization_basis, 0) -
                        nvl(outbk.reval_amortization_basis, 0))
         , decode(inbk.reval_ceiling,
                  null, decode(outbk.reval_ceiling,
                               null, null,
                                     outbk.reval_ceiling),
                        nvl(inbk.reval_ceiling, 0) - nvl(outbk.reval_ceiling, 0))
         , inbk.unit_of_measure
         , inbk.unrevalued_cost - nvl(outbk.unrevalued_cost, 0)
         , inbk.annual_deprn_rounding_flag
         , decode(inbk.salvage_type,
                  'PCT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                              'PCT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                              'AMT',nvl(inbk.percent_salvage_value, 0)),
                  'AMT', decode(nvl(outbk.salvage_type, inbk.salvage_type),
                               'AMT',nvl(inbk.percent_salvage_value, 0)  - nvl(outbk.percent_salvage_value, 0),
                               'PCT',nvl(inbk.percent_salvage_value, 0)))
         , decode(inbk.deprn_limit_type,
                  'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                              'PCT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                              'AMT',nvl(inbk.allowed_deprn_limit, 0)),
                  'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                               'AMT',nvl(inbk.allowed_deprn_limit, 0) - nvl(outbk.allowed_deprn_limit, 0),
                               'PCT',nvl(inbk.allowed_deprn_limit, 0)))
        , decode(inbk.deprn_limit_type,
                  'PCT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                              'PCT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                              'AMT',nvl(inbk.allowed_deprn_limit_amount, 0)),
                  'AMT', decode(nvl(outbk.deprn_limit_type, inbk.deprn_limit_type),
                               'AMT',nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0),
                               'PCT',nvl(inbk.allowed_deprn_limit_amount, 0)))
         , inbk.period_counter_life_complete
         , inbk.adjusted_recoverable_cost
         , inbk.annual_rounding_flag
         , inbk.eofy_adj_cost
         , inbk.eofy_formula_factor
         , inbk.short_fiscal_year_flag
         , inbk.conversion_date
         , inbk.ORIGINAL_DEPRN_START_DATE
         , inbk.remaining_life1
         , inbk.remaining_life2
         , inbk.group_asset_id
         , inbk.old_adjusted_cost
         , inbk.formula_factor
         , inbk.salvage_type
         , inbk.deprn_limit_type
         , inbk.over_depreciate_option
         , decode(inbk.super_group_id, outbk.super_group_id, null, inbk.super_group_id)
         , decode(inbk.reduction_rate,
                  null, decode(outbk.reduction_rate,
                               null, null,
                                     outbk.reduction_rate),
                        nvl(inbk.reduction_rate, 0) - nvl(outbk.reduction_rate, 0))
         , inbk.reduce_addition_flag
         , inbk.reduce_adjustment_flag
         , inbk.reduce_retirement_flag
         , inbk.recognize_gain_loss
         , inbk.recapture_reserve_flag
         , inbk.limit_proceeds_flag
         , inbk.terminal_gain_loss
         , inbk.tracking_method
         , inbk.exclude_fully_rsv_flag
         , inbk.excess_allocation_option
         , inbk.depreciation_option
         , inbk.member_rollup_flag
         , inbk.ytd_proceeds
         , inbk.ltd_proceeds
         , inbk.allocate_to_fully_rsv_flag
         , inbk.allocate_to_fully_ret_flag
         , nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0)
         , inbk.terminal_gain_loss_amount
         , inbk.ltd_cost_of_removal
         , inbk.prior_eofy_reserve
         , nvl(inbk.eofy_reserve, 0) - nvl(outbk.eofy_reserve, 0)
         , inbk.eop_adj_cost
         , inbk.eop_formula_factor
         , inbk.global_attribute1
         , inbk.global_attribute2
         , inbk.global_attribute3
         , inbk.global_attribute4
         , inbk.global_attribute5
         , inbk.global_attribute6
         , inbk.global_attribute7
         , inbk.global_attribute8
         , inbk.global_attribute9
         , inbk.global_attribute10
         , inbk.global_attribute11
         , inbk.global_attribute12
         , inbk.global_attribute13
         , inbk.global_attribute14
         , inbk.global_attribute15
         , inbk.global_attribute16
         , inbk.global_attribute17
         , inbk.global_attribute18
         , inbk.global_attribute19
         , inbk.global_attribute20
         , inbk.global_attribute_category
    from   fa_mc_books inbk,
           fa_mc_books outbk
    where  inbk.asset_id = c_asset_id
    and    inbk.asset_id = outbk.asset_id(+)
    and    inbk.book_type_code = p_asset_hdr_rec.book_type_code
    and    inbk.book_type_code = outbk.book_type_code(+)
    and    inbk.transaction_header_id_in = c_transaction_header_id
    and    inbk.transaction_header_id_in = outbk.transaction_header_id_out(+)
    and    inbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
    and    outbk.set_of_books_id(+) = p_asset_hdr_rec.set_of_books_id;



  CURSOR c_get_member_asset_id IS
    select asset_id
    from fa_transaction_headers
    where transaction_header_id = p_trans_rec.member_transaction_header_id;

  l_calling_fn         VARCHAR2(100) := 'FA_AMORT_PVT.GetFinRec';
  l_asset_fin_rec_adj  FA_API_TYPES.asset_fin_rec_type;
  l_asset_desc_rec     FA_API_TYPES.asset_desc_rec_type;
  l_asset_cat_rec      FA_API_TYPES.asset_cat_rec_type;
  l_asset_deprn_rec    FA_API_TYPES.asset_deprn_rec_type;
  l_period_rec         FA_API_TYPES.period_rec_type;

  l_is_member_trx_for_group      BOOLEAN := FALSE;
  l_asset_id                     NUMBER;
  l_transaction_header_id        NUMBER;

  l_tmp_cost                     NUMBER;
  l_tmp_percent_salvage_value    NUMBER;
  l_tmp_salvage_value            NUMBER;
  l_tmp_allowed_deprn_limit      NUMBER;
  l_tmp_allowed_deprn_limit_amt  NUMBER;
  l_tmp_production_capacity      NUMBER;
  l_tmp_fully_rsv_revals_counter NUMBER;
  l_tmp_reval_amortization_basis NUMBER;
  l_tmp_reval_ceiling            NUMBER;
  l_tmp_unrevalued_cost          NUMBER;
  l_tmp_eofy_reserve             NUMBER;
  l_tmp_deprn_limit_type         varchar2(30); -- Bug 6863138

  l_adj_found                    BOOLEAN := FALSE;
  l_reclass_trx                  BOOLEAN := FALSE;

  calc_failed  EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', px_asset_fin_rec.date_placed_in_service||':'||
                                              p_init_transaction_header_id, p_log_level_rec => p_log_level_rec);
   end if;

   x_dpis_change := FALSE;

   if (p_trans_rec.transaction_header_id is null and
       p_trans_rec.member_transaction_header_id is not null) then
      l_is_member_trx_for_group := TRUE;

      OPEN c_get_member_asset_id;
      FETCH c_get_member_asset_id INTO l_asset_id;
      CLOSE c_get_member_asset_id;

      l_transaction_header_id := p_trans_rec.member_transaction_header_id;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'Need to get Delta from member', l_asset_id, p_log_level_rec => p_log_level_rec);
       end if;

   else
     l_asset_id := p_asset_hdr_rec.asset_id;
     l_transaction_header_id := p_trans_rec.transaction_header_id;
   end if;

--tk_util.DumpFinRec(px_asset_fin_rec, 'GO1');

   if (nvl(p_mrc_sob_type_code, 'P') = 'R') then
      if (px_asset_fin_rec.date_placed_in_service is  null) then

         if p_init_transaction_header_id is null then
            OPEN c_get_init_mcbk;
            FETCH c_get_init_mcbk INTO px_asset_fin_rec.date_placed_in_service
                                  , px_asset_fin_rec.deprn_start_date
                                  , px_asset_fin_rec.deprn_method_code
                                  , px_asset_fin_rec.life_in_months
                                  , px_asset_fin_rec.rate_adjustment_factor
                                  , px_asset_fin_rec.adjusted_cost
                                  , px_asset_fin_rec.cost
                                  , px_asset_fin_rec.original_cost
                                  , px_asset_fin_rec.salvage_value
                                  , px_asset_fin_rec.prorate_convention_code
                                  , px_asset_fin_rec.prorate_date
                                  , px_asset_fin_rec.cost_change_flag
                                  , px_asset_fin_rec.adjustment_required_status
                                  , px_asset_fin_rec.capitalize_flag
                                  , px_asset_fin_rec.retirement_pending_flag
                                  , px_asset_fin_rec.depreciate_flag
                                  , px_asset_fin_rec.itc_amount_id
                                  , px_asset_fin_rec.itc_amount
                                  , px_asset_fin_rec.retirement_id
                                  , px_asset_fin_rec.tax_request_id
                                  , px_asset_fin_rec.itc_basis
                                  , px_asset_fin_rec.basic_rate
                                  , px_asset_fin_rec.adjusted_rate
                                  , px_asset_fin_rec.bonus_rule
                                  , px_asset_fin_rec.ceiling_name
                                  , px_asset_fin_rec.recoverable_cost
                                  , px_asset_fin_rec.adjusted_capacity
                                  , px_asset_fin_rec.fully_rsvd_revals_counter
                                  , px_asset_fin_rec.idled_flag
                                  , px_asset_fin_rec.period_counter_capitalized
                                  , px_asset_fin_rec.period_counter_fully_reserved
                                  , px_asset_fin_rec.period_counter_fully_retired
                                  , px_asset_fin_rec.production_capacity
                                  , px_asset_fin_rec.reval_amortization_basis
                                  , px_asset_fin_rec.reval_ceiling
                                  , px_asset_fin_rec.unit_of_measure
                                  , px_asset_fin_rec.unrevalued_cost
                                  , px_asset_fin_rec.annual_deprn_rounding_flag
                                  , px_asset_fin_rec.percent_salvage_value
                                  , px_asset_fin_rec.allowed_deprn_limit
                                  , px_asset_fin_rec.allowed_deprn_limit_amount
                                  , px_asset_fin_rec.period_counter_life_complete
                                  , px_asset_fin_rec.adjusted_recoverable_cost
                                  , px_asset_fin_rec.annual_rounding_flag
                                  , px_asset_fin_rec.eofy_adj_cost
                                  , px_asset_fin_rec.eofy_formula_factor
                                  , px_asset_fin_rec.short_fiscal_year_flag
                                  , px_asset_fin_rec.conversion_date
                                  , px_asset_fin_rec.orig_deprn_start_date
                                  , px_asset_fin_rec.remaining_life1
                                  , px_asset_fin_rec.remaining_life2
                                  , px_asset_fin_rec.group_asset_id
                                  , px_asset_fin_rec.old_adjusted_cost
                                  , px_asset_fin_rec.formula_factor
                                  , px_asset_fin_rec.salvage_type
                                  , px_asset_fin_rec.deprn_limit_type
                                  , px_asset_fin_rec.over_depreciate_option
                                  , px_asset_fin_rec.super_group_id
                                  , px_asset_fin_rec.reduction_rate
                                  , px_asset_fin_rec.reduce_addition_flag
                                  , px_asset_fin_rec.reduce_adjustment_flag
                                  , px_asset_fin_rec.reduce_retirement_flag
                                  , px_asset_fin_rec.recognize_gain_loss
                                  , px_asset_fin_rec.recapture_reserve_flag
                                  , px_asset_fin_rec.limit_proceeds_flag
                                  , px_asset_fin_rec.terminal_gain_loss
                                  , px_asset_fin_rec.tracking_method
                                  , px_asset_fin_rec.exclude_fully_rsv_flag
                                  , px_asset_fin_rec.excess_allocation_option
                                  , px_asset_fin_rec.depreciation_option
                                  , px_asset_fin_rec.member_rollup_flag
                                  , px_asset_fin_rec.ytd_proceeds
                                  , px_asset_fin_rec.ltd_proceeds
                                  , px_asset_fin_rec.allocate_to_fully_rsv_flag
                                  , px_asset_fin_rec.allocate_to_fully_ret_flag
                                  , px_asset_fin_rec.cip_cost
                                  , px_asset_fin_rec.terminal_gain_loss_amount
                                  , px_asset_fin_rec.ltd_cost_of_removal
                                  , px_asset_fin_rec.prior_eofy_reserve
                                  , px_asset_fin_rec.eofy_reserve
                                  , px_asset_fin_rec.eop_adj_cost
                                  , px_asset_fin_rec.eop_formula_factor
                                  , px_asset_fin_rec.global_attribute1
                                  , px_asset_fin_rec.global_attribute2
                                  , px_asset_fin_rec.global_attribute3
                                  , px_asset_fin_rec.global_attribute4
                                  , px_asset_fin_rec.global_attribute5
                                  , px_asset_fin_rec.global_attribute6
                                  , px_asset_fin_rec.global_attribute7
                                  , px_asset_fin_rec.global_attribute8
                                  , px_asset_fin_rec.global_attribute9
                                  , px_asset_fin_rec.global_attribute10
                                  , px_asset_fin_rec.global_attribute11
                                  , px_asset_fin_rec.global_attribute12
                                  , px_asset_fin_rec.global_attribute13
                                  , px_asset_fin_rec.global_attribute14
                                  , px_asset_fin_rec.global_attribute15
                                  , px_asset_fin_rec.global_attribute16
                                  , px_asset_fin_rec.global_attribute17
                                  , px_asset_fin_rec.global_attribute18
                                  , px_asset_fin_rec.global_attribute19
                                  , px_asset_fin_rec.global_attribute20
                                  , px_asset_fin_rec.global_attribute_category;
            CLOSE c_get_init_mcbk;
         else
            OPEN c_get_init_mcbk_winit;
            FETCH c_get_init_mcbk_winit INTO px_asset_fin_rec.date_placed_in_service
                                  , px_asset_fin_rec.deprn_start_date
                                  , px_asset_fin_rec.deprn_method_code
                                  , px_asset_fin_rec.life_in_months
                                  , px_asset_fin_rec.rate_adjustment_factor
                                  , px_asset_fin_rec.adjusted_cost
                                  , px_asset_fin_rec.cost
                                  , px_asset_fin_rec.original_cost
                                  , px_asset_fin_rec.salvage_value
                                  , px_asset_fin_rec.prorate_convention_code
                                  , px_asset_fin_rec.prorate_date
                                  , px_asset_fin_rec.cost_change_flag
                                  , px_asset_fin_rec.adjustment_required_status
                                  , px_asset_fin_rec.capitalize_flag
                                  , px_asset_fin_rec.retirement_pending_flag
                                  , px_asset_fin_rec.depreciate_flag
                                  , px_asset_fin_rec.itc_amount_id
                                  , px_asset_fin_rec.itc_amount
                                  , px_asset_fin_rec.retirement_id
                                  , px_asset_fin_rec.tax_request_id
                                  , px_asset_fin_rec.itc_basis
                                  , px_asset_fin_rec.basic_rate
                                  , px_asset_fin_rec.adjusted_rate
                                  , px_asset_fin_rec.bonus_rule
                                  , px_asset_fin_rec.ceiling_name
                                  , px_asset_fin_rec.recoverable_cost
                                  , px_asset_fin_rec.adjusted_capacity
                                  , px_asset_fin_rec.fully_rsvd_revals_counter
                                  , px_asset_fin_rec.idled_flag
                                  , px_asset_fin_rec.period_counter_capitalized
                                  , px_asset_fin_rec.period_counter_fully_reserved
                                  , px_asset_fin_rec.period_counter_fully_retired
                                  , px_asset_fin_rec.production_capacity
                                  , px_asset_fin_rec.reval_amortization_basis
                                  , px_asset_fin_rec.reval_ceiling
                                  , px_asset_fin_rec.unit_of_measure
                                  , px_asset_fin_rec.unrevalued_cost
                                  , px_asset_fin_rec.annual_deprn_rounding_flag
                                  , px_asset_fin_rec.percent_salvage_value
                                  , px_asset_fin_rec.allowed_deprn_limit
                                  , px_asset_fin_rec.allowed_deprn_limit_amount
                                  , px_asset_fin_rec.period_counter_life_complete
                                  , px_asset_fin_rec.adjusted_recoverable_cost
                                  , px_asset_fin_rec.annual_rounding_flag
                                  , px_asset_fin_rec.eofy_adj_cost
                                  , px_asset_fin_rec.eofy_formula_factor
                                  , px_asset_fin_rec.short_fiscal_year_flag
                                  , px_asset_fin_rec.conversion_date
                                  , px_asset_fin_rec.orig_deprn_start_date
                                  , px_asset_fin_rec.remaining_life1
                                  , px_asset_fin_rec.remaining_life2
                                  , px_asset_fin_rec.group_asset_id
                                  , px_asset_fin_rec.old_adjusted_cost
                                  , px_asset_fin_rec.formula_factor
                                  , px_asset_fin_rec.salvage_type
                                  , px_asset_fin_rec.deprn_limit_type
                                  , px_asset_fin_rec.over_depreciate_option
                                  , px_asset_fin_rec.super_group_id
                                  , px_asset_fin_rec.reduction_rate
                                  , px_asset_fin_rec.reduce_addition_flag
                                  , px_asset_fin_rec.reduce_adjustment_flag
                                  , px_asset_fin_rec.reduce_retirement_flag
                                  , px_asset_fin_rec.recognize_gain_loss
                                  , px_asset_fin_rec.recapture_reserve_flag
                                  , px_asset_fin_rec.limit_proceeds_flag
                                  , px_asset_fin_rec.terminal_gain_loss
                                  , px_asset_fin_rec.tracking_method
                                  , px_asset_fin_rec.exclude_fully_rsv_flag
                                  , px_asset_fin_rec.excess_allocation_option
                                  , px_asset_fin_rec.depreciation_option
                                  , px_asset_fin_rec.member_rollup_flag
                                  , px_asset_fin_rec.ytd_proceeds
                                  , px_asset_fin_rec.ltd_proceeds
                                  , px_asset_fin_rec.allocate_to_fully_rsv_flag
                                  , px_asset_fin_rec.allocate_to_fully_ret_flag
                                  , px_asset_fin_rec.cip_cost
                                  , px_asset_fin_rec.terminal_gain_loss_amount
                                  , px_asset_fin_rec.ltd_cost_of_removal
                                  , px_asset_fin_rec.prior_eofy_reserve
                                  , px_asset_fin_rec.eofy_reserve
                                  , px_asset_fin_rec.eop_adj_cost
                                  , px_asset_fin_rec.eop_formula_factor
                                  , px_asset_fin_rec.global_attribute1
                                  , px_asset_fin_rec.global_attribute2
                                  , px_asset_fin_rec.global_attribute3
                                  , px_asset_fin_rec.global_attribute4
                                  , px_asset_fin_rec.global_attribute5
                                  , px_asset_fin_rec.global_attribute6
                                  , px_asset_fin_rec.global_attribute7
                                  , px_asset_fin_rec.global_attribute8
                                  , px_asset_fin_rec.global_attribute9
                                  , px_asset_fin_rec.global_attribute10
                                  , px_asset_fin_rec.global_attribute11
                                  , px_asset_fin_rec.global_attribute12
                                  , px_asset_fin_rec.global_attribute13
                                  , px_asset_fin_rec.global_attribute14
                                  , px_asset_fin_rec.global_attribute15
                                  , px_asset_fin_rec.global_attribute16
                                  , px_asset_fin_rec.global_attribute17
                                  , px_asset_fin_rec.global_attribute18
                                  , px_asset_fin_rec.global_attribute19
                                  , px_asset_fin_rec.global_attribute20
                                  , px_asset_fin_rec.global_attribute_category;
            CLOSE c_get_init_mcbk_winit;

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Found initial fin_rec from db',
                             px_asset_fin_rec.cost, p_log_level_rec => p_log_level_rec);
         end if;

/*
         if p_trans_rec.transaction_type_code in
                       (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET) and
            not (p_use_fin_rec_adj) then
            x_asset_fin_rec_new := px_asset_fin_rec;

--tk_util.DumpFinRec(px_asset_fin_rec, 'GO2');
--tk_util.DumpFinRec(x_asset_fin_rec_new, 'GN');

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'End', x_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
            end if;

            return TRUE;
         end if;
*/

--      els -- BUG# 3947146

         if not (p_process_this_trx) then
            x_asset_fin_rec_new := px_asset_fin_rec;
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'End', x_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
            end if;

            return TRUE;

         end if;

      end if;

      if (px_asset_fin_rec.deprn_method_code is null) then
         OPEN c_get_mcbk2(l_asset_id, l_transaction_header_id);
         FETCH c_get_mcbk2 INTO l_asset_fin_rec_adj.date_placed_in_service
                        , l_asset_fin_rec_adj.deprn_start_date
                        , l_asset_fin_rec_adj.deprn_method_code
                        , l_asset_fin_rec_adj.life_in_months
                        , l_asset_fin_rec_adj.rate_adjustment_factor
                        , l_asset_fin_rec_adj.adjusted_cost
                        , l_asset_fin_rec_adj.cost
                        , l_asset_fin_rec_adj.original_cost
                        , l_asset_fin_rec_adj.salvage_value
                        , l_asset_fin_rec_adj.prorate_convention_code
                        , l_asset_fin_rec_adj.prorate_date
                        , l_asset_fin_rec_adj.cost_change_flag
                        , l_asset_fin_rec_adj.adjustment_required_status
                        , l_asset_fin_rec_adj.capitalize_flag
                        , l_asset_fin_rec_adj.retirement_pending_flag
                        , l_asset_fin_rec_adj.depreciate_flag
                        , l_asset_fin_rec_adj.itc_amount_id
                        , l_asset_fin_rec_adj.itc_amount
                        , l_asset_fin_rec_adj.retirement_id
                        , l_asset_fin_rec_adj.tax_request_id
                        , l_asset_fin_rec_adj.itc_basis
                        , l_asset_fin_rec_adj.basic_rate
                        , l_asset_fin_rec_adj.adjusted_rate
                        , l_asset_fin_rec_adj.bonus_rule
                        , l_asset_fin_rec_adj.ceiling_name
                        , l_asset_fin_rec_adj.recoverable_cost
                        , l_asset_fin_rec_adj.adjusted_capacity
                        , l_asset_fin_rec_adj.fully_rsvd_revals_counter
                        , l_asset_fin_rec_adj.idled_flag
                        , l_asset_fin_rec_adj.period_counter_capitalized
                        , l_asset_fin_rec_adj.period_counter_fully_reserved
                        , l_asset_fin_rec_adj.period_counter_fully_retired
                        , l_asset_fin_rec_adj.production_capacity
                        , l_asset_fin_rec_adj.reval_amortization_basis
                        , l_asset_fin_rec_adj.reval_ceiling
                        , l_asset_fin_rec_adj.unit_of_measure
                        , l_asset_fin_rec_adj.unrevalued_cost
                        , l_asset_fin_rec_adj.annual_deprn_rounding_flag
                        , l_asset_fin_rec_adj.percent_salvage_value
                        , l_asset_fin_rec_adj.allowed_deprn_limit
                        , l_asset_fin_rec_adj.allowed_deprn_limit_amount
                        , l_asset_fin_rec_adj.period_counter_life_complete
                        , l_asset_fin_rec_adj.adjusted_recoverable_cost
                        , l_asset_fin_rec_adj.annual_rounding_flag
                        , l_asset_fin_rec_adj.eofy_adj_cost
                        , l_asset_fin_rec_adj.eofy_formula_factor
                        , l_asset_fin_rec_adj.short_fiscal_year_flag
                        , l_asset_fin_rec_adj.conversion_date
                        , l_asset_fin_rec_adj.orig_deprn_start_date
                        , l_asset_fin_rec_adj.remaining_life1
                        , l_asset_fin_rec_adj.remaining_life2
                        , l_asset_fin_rec_adj.group_asset_id
                        , l_asset_fin_rec_adj.old_adjusted_cost
                        , l_asset_fin_rec_adj.formula_factor
                        , l_asset_fin_rec_adj.salvage_type
                        , l_asset_fin_rec_adj.deprn_limit_type
                        , l_asset_fin_rec_adj.over_depreciate_option
                        , l_asset_fin_rec_adj.super_group_id
                        , l_asset_fin_rec_adj.reduction_rate
                        , l_asset_fin_rec_adj.reduce_addition_flag
                        , l_asset_fin_rec_adj.reduce_adjustment_flag
                        , l_asset_fin_rec_adj.reduce_retirement_flag
                        , l_asset_fin_rec_adj.recognize_gain_loss
                        , l_asset_fin_rec_adj.recapture_reserve_flag
                        , l_asset_fin_rec_adj.limit_proceeds_flag
                        , l_asset_fin_rec_adj.terminal_gain_loss
                        , l_asset_fin_rec_adj.tracking_method
                        , l_asset_fin_rec_adj.exclude_fully_rsv_flag
                        , l_asset_fin_rec_adj.excess_allocation_option
                        , l_asset_fin_rec_adj.depreciation_option
                        , l_asset_fin_rec_adj.member_rollup_flag
                        , l_asset_fin_rec_adj.ytd_proceeds
                        , l_asset_fin_rec_adj.ltd_proceeds
                        , l_asset_fin_rec_adj.allocate_to_fully_rsv_flag
                        , l_asset_fin_rec_adj.allocate_to_fully_ret_flag
                        , l_asset_fin_rec_adj.cip_cost
                        , l_asset_fin_rec_adj.terminal_gain_loss_amount
                        , l_asset_fin_rec_adj.ltd_cost_of_removal
                        , l_asset_fin_rec_adj.prior_eofy_reserve
                        , l_asset_fin_rec_adj.eofy_reserve
                        , l_asset_fin_rec_adj.eop_adj_cost
                        , l_asset_fin_rec_adj.eop_formula_factor
                        , l_asset_fin_rec_adj.global_attribute1
                        , l_asset_fin_rec_adj.global_attribute2
                        , l_asset_fin_rec_adj.global_attribute3
                        , l_asset_fin_rec_adj.global_attribute4
                        , l_asset_fin_rec_adj.global_attribute5
                        , l_asset_fin_rec_adj.global_attribute6
                        , l_asset_fin_rec_adj.global_attribute7
                        , l_asset_fin_rec_adj.global_attribute8
                        , l_asset_fin_rec_adj.global_attribute9
                        , l_asset_fin_rec_adj.global_attribute10
                        , l_asset_fin_rec_adj.global_attribute11
                        , l_asset_fin_rec_adj.global_attribute12
                        , l_asset_fin_rec_adj.global_attribute13
                        , l_asset_fin_rec_adj.global_attribute14
                        , l_asset_fin_rec_adj.global_attribute15
                        , l_asset_fin_rec_adj.global_attribute16
                        , l_asset_fin_rec_adj.global_attribute17
                        , l_asset_fin_rec_adj.global_attribute18
                        , l_asset_fin_rec_adj.global_attribute19
                        , l_asset_fin_rec_adj.global_attribute20
                        , l_asset_fin_rec_adj.global_attribute_category;
         l_adj_found := c_get_mcbk2%FOUND;
         CLOSE c_get_mcbk2;

      else
         OPEN c_get_mcbk(l_asset_id, l_transaction_header_id);
         FETCH c_get_mcbk INTO l_asset_fin_rec_adj.date_placed_in_service
                        , l_asset_fin_rec_adj.deprn_start_date
                        , l_asset_fin_rec_adj.deprn_method_code
                        , l_asset_fin_rec_adj.life_in_months
                        , l_asset_fin_rec_adj.rate_adjustment_factor
                        , l_asset_fin_rec_adj.adjusted_cost
                        , l_asset_fin_rec_adj.cost
                        , l_asset_fin_rec_adj.original_cost
                        , l_asset_fin_rec_adj.salvage_value
                        , l_asset_fin_rec_adj.prorate_convention_code
                        , l_asset_fin_rec_adj.prorate_date
                        , l_asset_fin_rec_adj.cost_change_flag
                        , l_asset_fin_rec_adj.adjustment_required_status
                        , l_asset_fin_rec_adj.capitalize_flag
                        , l_asset_fin_rec_adj.retirement_pending_flag
                        , l_asset_fin_rec_adj.depreciate_flag
                        , l_asset_fin_rec_adj.itc_amount_id
                        , l_asset_fin_rec_adj.itc_amount
                        , l_asset_fin_rec_adj.retirement_id
                        , l_asset_fin_rec_adj.tax_request_id
                        , l_asset_fin_rec_adj.itc_basis
                        , l_asset_fin_rec_adj.basic_rate
                        , l_asset_fin_rec_adj.adjusted_rate
                        , l_asset_fin_rec_adj.bonus_rule
                        , l_asset_fin_rec_adj.ceiling_name
                        , l_asset_fin_rec_adj.recoverable_cost
                        , l_asset_fin_rec_adj.adjusted_capacity
                        , l_asset_fin_rec_adj.fully_rsvd_revals_counter
                        , l_asset_fin_rec_adj.idled_flag
                        , l_asset_fin_rec_adj.period_counter_capitalized
                        , l_asset_fin_rec_adj.period_counter_fully_reserved
                        , l_asset_fin_rec_adj.period_counter_fully_retired
                        , l_asset_fin_rec_adj.production_capacity
                        , l_asset_fin_rec_adj.reval_amortization_basis
                        , l_asset_fin_rec_adj.reval_ceiling
                        , l_asset_fin_rec_adj.unit_of_measure
                        , l_asset_fin_rec_adj.unrevalued_cost
                        , l_asset_fin_rec_adj.annual_deprn_rounding_flag
                        , l_asset_fin_rec_adj.percent_salvage_value
                        , l_asset_fin_rec_adj.allowed_deprn_limit
                        , l_asset_fin_rec_adj.allowed_deprn_limit_amount
                        , l_asset_fin_rec_adj.period_counter_life_complete
                        , l_asset_fin_rec_adj.adjusted_recoverable_cost
                        , l_asset_fin_rec_adj.annual_rounding_flag
                        , l_asset_fin_rec_adj.eofy_adj_cost
                        , l_asset_fin_rec_adj.eofy_formula_factor
                        , l_asset_fin_rec_adj.short_fiscal_year_flag
                        , l_asset_fin_rec_adj.conversion_date
                        , l_asset_fin_rec_adj.orig_deprn_start_date
                        , l_asset_fin_rec_adj.remaining_life1
                        , l_asset_fin_rec_adj.remaining_life2
                        , l_asset_fin_rec_adj.group_asset_id
                        , l_asset_fin_rec_adj.old_adjusted_cost
                        , l_asset_fin_rec_adj.formula_factor
                        , l_asset_fin_rec_adj.salvage_type
                        , l_asset_fin_rec_adj.deprn_limit_type
                        , l_asset_fin_rec_adj.over_depreciate_option
                        , l_asset_fin_rec_adj.super_group_id
                        , l_asset_fin_rec_adj.reduction_rate
                        , l_asset_fin_rec_adj.reduce_addition_flag
                        , l_asset_fin_rec_adj.reduce_adjustment_flag
                        , l_asset_fin_rec_adj.reduce_retirement_flag
                        , l_asset_fin_rec_adj.recognize_gain_loss
                        , l_asset_fin_rec_adj.recapture_reserve_flag
                        , l_asset_fin_rec_adj.limit_proceeds_flag
                        , l_asset_fin_rec_adj.terminal_gain_loss
                        , l_asset_fin_rec_adj.tracking_method
                        , l_asset_fin_rec_adj.exclude_fully_rsv_flag
                        , l_asset_fin_rec_adj.excess_allocation_option
                        , l_asset_fin_rec_adj.depreciation_option
                        , l_asset_fin_rec_adj.member_rollup_flag
                        , l_asset_fin_rec_adj.ytd_proceeds
                        , l_asset_fin_rec_adj.ltd_proceeds
                        , l_asset_fin_rec_adj.allocate_to_fully_rsv_flag
                        , l_asset_fin_rec_adj.allocate_to_fully_ret_flag
                        , l_asset_fin_rec_adj.cip_cost
                        , l_asset_fin_rec_adj.terminal_gain_loss_amount
                        , l_asset_fin_rec_adj.ltd_cost_of_removal
                        , l_asset_fin_rec_adj.prior_eofy_reserve
                        , l_asset_fin_rec_adj.eofy_reserve
                        , l_asset_fin_rec_adj.eop_adj_cost
                        , l_asset_fin_rec_adj.eop_formula_factor
                        , l_asset_fin_rec_adj.global_attribute1
                        , l_asset_fin_rec_adj.global_attribute2
                        , l_asset_fin_rec_adj.global_attribute3
                        , l_asset_fin_rec_adj.global_attribute4
                        , l_asset_fin_rec_adj.global_attribute5
                        , l_asset_fin_rec_adj.global_attribute6
                        , l_asset_fin_rec_adj.global_attribute7
                        , l_asset_fin_rec_adj.global_attribute8
                        , l_asset_fin_rec_adj.global_attribute9
                        , l_asset_fin_rec_adj.global_attribute10
                        , l_asset_fin_rec_adj.global_attribute11
                        , l_asset_fin_rec_adj.global_attribute12
                        , l_asset_fin_rec_adj.global_attribute13
                        , l_asset_fin_rec_adj.global_attribute14
                        , l_asset_fin_rec_adj.global_attribute15
                        , l_asset_fin_rec_adj.global_attribute16
                        , l_asset_fin_rec_adj.global_attribute17
                        , l_asset_fin_rec_adj.global_attribute18
                        , l_asset_fin_rec_adj.global_attribute19
                        , l_asset_fin_rec_adj.global_attribute20
                        , l_asset_fin_rec_adj.global_attribute_category;
         l_adj_found := c_get_mcbk%FOUND;
         CLOSE c_get_mcbk;

      end if; -- (px_asset_fin_rec.deprn_method_code is null)

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Got bk to find delta from db',
                         l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
      end if;

   else
      if (px_asset_fin_rec.date_placed_in_service is null) then

         if p_init_transaction_header_id is null then
            OPEN c_get_init_bk;
            FETCH c_get_init_bk INTO px_asset_fin_rec.date_placed_in_service
                           , px_asset_fin_rec.deprn_start_date
                           , px_asset_fin_rec.deprn_method_code
                           , px_asset_fin_rec.life_in_months
                           , px_asset_fin_rec.rate_adjustment_factor
                           , px_asset_fin_rec.adjusted_cost
                           , px_asset_fin_rec.cost
                           , px_asset_fin_rec.original_cost
                           , px_asset_fin_rec.salvage_value
                           , px_asset_fin_rec.prorate_convention_code
                           , px_asset_fin_rec.prorate_date
                           , px_asset_fin_rec.cost_change_flag
                           , px_asset_fin_rec.adjustment_required_status
                           , px_asset_fin_rec.capitalize_flag
                           , px_asset_fin_rec.retirement_pending_flag
                           , px_asset_fin_rec.depreciate_flag
                           , px_asset_fin_rec.itc_amount_id
                           , px_asset_fin_rec.itc_amount
                           , px_asset_fin_rec.retirement_id
                           , px_asset_fin_rec.tax_request_id
                           , px_asset_fin_rec.itc_basis
                           , px_asset_fin_rec.basic_rate
                           , px_asset_fin_rec.adjusted_rate
                           , px_asset_fin_rec.bonus_rule
                           , px_asset_fin_rec.ceiling_name
                           , px_asset_fin_rec.recoverable_cost
                           , px_asset_fin_rec.adjusted_capacity
                           , px_asset_fin_rec.fully_rsvd_revals_counter
                           , px_asset_fin_rec.idled_flag
                           , px_asset_fin_rec.period_counter_capitalized
                           , px_asset_fin_rec.period_counter_fully_reserved
                           , px_asset_fin_rec.period_counter_fully_retired
                           , px_asset_fin_rec.production_capacity
                           , px_asset_fin_rec.reval_amortization_basis
                           , px_asset_fin_rec.reval_ceiling
                           , px_asset_fin_rec.unit_of_measure
                           , px_asset_fin_rec.unrevalued_cost
                           , px_asset_fin_rec.annual_deprn_rounding_flag
                           , px_asset_fin_rec.percent_salvage_value
                           , px_asset_fin_rec.allowed_deprn_limit
                           , px_asset_fin_rec.allowed_deprn_limit_amount
                           , px_asset_fin_rec.period_counter_life_complete
                           , px_asset_fin_rec.adjusted_recoverable_cost
                           , px_asset_fin_rec.annual_rounding_flag
                           , px_asset_fin_rec.eofy_adj_cost
                           , px_asset_fin_rec.eofy_formula_factor
                           , px_asset_fin_rec.short_fiscal_year_flag
                           , px_asset_fin_rec.conversion_date
                           , px_asset_fin_rec.orig_deprn_start_date
                           , px_asset_fin_rec.remaining_life1
                           , px_asset_fin_rec.remaining_life2
                           , px_asset_fin_rec.group_asset_id
                           , px_asset_fin_rec.old_adjusted_cost
                           , px_asset_fin_rec.formula_factor
                           , px_asset_fin_rec.salvage_type
                           , px_asset_fin_rec.deprn_limit_type
                           , px_asset_fin_rec.over_depreciate_option
                           , px_asset_fin_rec.super_group_id
                           , px_asset_fin_rec.reduction_rate
                           , px_asset_fin_rec.reduce_addition_flag
                           , px_asset_fin_rec.reduce_adjustment_flag
                           , px_asset_fin_rec.reduce_retirement_flag
                           , px_asset_fin_rec.recognize_gain_loss
                           , px_asset_fin_rec.recapture_reserve_flag
                           , px_asset_fin_rec.limit_proceeds_flag
                           , px_asset_fin_rec.terminal_gain_loss
                           , px_asset_fin_rec.tracking_method
                           , px_asset_fin_rec.exclude_fully_rsv_flag
                           , px_asset_fin_rec.excess_allocation_option
                           , px_asset_fin_rec.depreciation_option
                           , px_asset_fin_rec.member_rollup_flag
                           , px_asset_fin_rec.ytd_proceeds
                           , px_asset_fin_rec.ltd_proceeds
                           , px_asset_fin_rec.allocate_to_fully_rsv_flag
                           , px_asset_fin_rec.allocate_to_fully_ret_flag
                           , px_asset_fin_rec.cip_cost
                           , px_asset_fin_rec.terminal_gain_loss_amount
                           , px_asset_fin_rec.ltd_cost_of_removal
                           , px_asset_fin_rec.prior_eofy_reserve
                           , px_asset_fin_rec.eofy_reserve
                           , px_asset_fin_rec.eop_adj_cost
                           , px_asset_fin_rec.eop_formula_factor
                           , px_asset_fin_rec.global_attribute1
                           , px_asset_fin_rec.global_attribute2
                           , px_asset_fin_rec.global_attribute3
                           , px_asset_fin_rec.global_attribute4
                           , px_asset_fin_rec.global_attribute5
                           , px_asset_fin_rec.global_attribute6
                           , px_asset_fin_rec.global_attribute7
                           , px_asset_fin_rec.global_attribute8
                           , px_asset_fin_rec.global_attribute9
                           , px_asset_fin_rec.global_attribute10
                           , px_asset_fin_rec.global_attribute11
                           , px_asset_fin_rec.global_attribute12
                           , px_asset_fin_rec.global_attribute13
                           , px_asset_fin_rec.global_attribute14
                           , px_asset_fin_rec.global_attribute15
                           , px_asset_fin_rec.global_attribute16
                           , px_asset_fin_rec.global_attribute17
                           , px_asset_fin_rec.global_attribute18
                           , px_asset_fin_rec.global_attribute19
                           , px_asset_fin_rec.global_attribute20
                           , px_asset_fin_rec.global_attribute_category
                           , px_asset_fin_rec.nbv_at_switch
                           , px_asset_fin_rec.prior_deprn_limit_type
                           , px_asset_fin_rec.prior_deprn_limit_amount
                           , px_asset_fin_rec.prior_deprn_limit
                           , px_asset_fin_rec.prior_deprn_method
                           , px_asset_fin_rec.prior_life_in_months
                           , px_asset_fin_rec.prior_basic_rate
                           , px_asset_fin_rec.prior_adjusted_rate ;
            CLOSE c_get_init_bk;
         else
            OPEN c_get_init_bk_winit;
            FETCH c_get_init_bk_winit INTO px_asset_fin_rec.date_placed_in_service
                           , px_asset_fin_rec.deprn_start_date
                           , px_asset_fin_rec.deprn_method_code
                           , px_asset_fin_rec.life_in_months
                           , px_asset_fin_rec.rate_adjustment_factor
                           , px_asset_fin_rec.adjusted_cost
                           , px_asset_fin_rec.cost
                           , px_asset_fin_rec.original_cost
                           , px_asset_fin_rec.salvage_value
                           , px_asset_fin_rec.prorate_convention_code
                           , px_asset_fin_rec.prorate_date
                           , px_asset_fin_rec.cost_change_flag
                           , px_asset_fin_rec.adjustment_required_status
                           , px_asset_fin_rec.capitalize_flag
                           , px_asset_fin_rec.retirement_pending_flag
                           , px_asset_fin_rec.depreciate_flag
                           , px_asset_fin_rec.itc_amount_id
                           , px_asset_fin_rec.itc_amount
                           , px_asset_fin_rec.retirement_id
                           , px_asset_fin_rec.tax_request_id
                           , px_asset_fin_rec.itc_basis
                           , px_asset_fin_rec.basic_rate
                           , px_asset_fin_rec.adjusted_rate
                           , px_asset_fin_rec.bonus_rule
                           , px_asset_fin_rec.ceiling_name
                           , px_asset_fin_rec.recoverable_cost
                           , px_asset_fin_rec.adjusted_capacity
                           , px_asset_fin_rec.fully_rsvd_revals_counter
                           , px_asset_fin_rec.idled_flag
                           , px_asset_fin_rec.period_counter_capitalized
                           , px_asset_fin_rec.period_counter_fully_reserved
                           , px_asset_fin_rec.period_counter_fully_retired
                           , px_asset_fin_rec.production_capacity
                           , px_asset_fin_rec.reval_amortization_basis
                           , px_asset_fin_rec.reval_ceiling
                           , px_asset_fin_rec.unit_of_measure
                           , px_asset_fin_rec.unrevalued_cost
                           , px_asset_fin_rec.annual_deprn_rounding_flag
                           , px_asset_fin_rec.percent_salvage_value
                           , px_asset_fin_rec.allowed_deprn_limit
                           , px_asset_fin_rec.allowed_deprn_limit_amount
                           , px_asset_fin_rec.period_counter_life_complete
                           , px_asset_fin_rec.adjusted_recoverable_cost
                           , px_asset_fin_rec.annual_rounding_flag
                           , px_asset_fin_rec.eofy_adj_cost
                           , px_asset_fin_rec.eofy_formula_factor
                           , px_asset_fin_rec.short_fiscal_year_flag
                           , px_asset_fin_rec.conversion_date
                           , px_asset_fin_rec.orig_deprn_start_date
                           , px_asset_fin_rec.remaining_life1
                           , px_asset_fin_rec.remaining_life2
                           , px_asset_fin_rec.group_asset_id
                           , px_asset_fin_rec.old_adjusted_cost
                           , px_asset_fin_rec.formula_factor
                           , px_asset_fin_rec.salvage_type
                           , px_asset_fin_rec.deprn_limit_type
                           , px_asset_fin_rec.over_depreciate_option
                           , px_asset_fin_rec.super_group_id
                           , px_asset_fin_rec.reduction_rate
                           , px_asset_fin_rec.reduce_addition_flag
                           , px_asset_fin_rec.reduce_adjustment_flag
                           , px_asset_fin_rec.reduce_retirement_flag
                           , px_asset_fin_rec.recognize_gain_loss
                           , px_asset_fin_rec.recapture_reserve_flag
                           , px_asset_fin_rec.limit_proceeds_flag
                           , px_asset_fin_rec.terminal_gain_loss
                           , px_asset_fin_rec.tracking_method
                           , px_asset_fin_rec.exclude_fully_rsv_flag
                           , px_asset_fin_rec.excess_allocation_option
                           , px_asset_fin_rec.depreciation_option
                           , px_asset_fin_rec.member_rollup_flag
                           , px_asset_fin_rec.ytd_proceeds
                           , px_asset_fin_rec.ltd_proceeds
                           , px_asset_fin_rec.allocate_to_fully_rsv_flag
                           , px_asset_fin_rec.allocate_to_fully_ret_flag
                           , px_asset_fin_rec.cip_cost
                           , px_asset_fin_rec.terminal_gain_loss_amount
                           , px_asset_fin_rec.ltd_cost_of_removal
                           , px_asset_fin_rec.prior_eofy_reserve
                           , px_asset_fin_rec.eofy_reserve
                           , px_asset_fin_rec.eop_adj_cost
                           , px_asset_fin_rec.eop_formula_factor
                           , px_asset_fin_rec.global_attribute1
                           , px_asset_fin_rec.global_attribute2
                           , px_asset_fin_rec.global_attribute3
                           , px_asset_fin_rec.global_attribute4
                           , px_asset_fin_rec.global_attribute5
                           , px_asset_fin_rec.global_attribute6
                           , px_asset_fin_rec.global_attribute7
                           , px_asset_fin_rec.global_attribute8
                           , px_asset_fin_rec.global_attribute9
                           , px_asset_fin_rec.global_attribute10
                           , px_asset_fin_rec.global_attribute11
                           , px_asset_fin_rec.global_attribute12
                           , px_asset_fin_rec.global_attribute13
                           , px_asset_fin_rec.global_attribute14
                           , px_asset_fin_rec.global_attribute15
                           , px_asset_fin_rec.global_attribute16
                           , px_asset_fin_rec.global_attribute17
                           , px_asset_fin_rec.global_attribute18
                           , px_asset_fin_rec.global_attribute19
                           , px_asset_fin_rec.global_attribute20
                           , px_asset_fin_rec.global_attribute_category
                           , px_asset_fin_rec.nbv_at_switch
                           , px_asset_fin_rec.prior_deprn_limit_type
                           , px_asset_fin_rec.prior_deprn_limit_amount
                           , px_asset_fin_rec.prior_deprn_limit
                           , px_asset_fin_rec.prior_deprn_method
                           , px_asset_fin_rec.prior_life_in_months
                           , px_asset_fin_rec.prior_basic_rate
                           , px_asset_fin_rec.prior_adjusted_rate ;
            CLOSE c_get_init_bk_winit;

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Found initial fin_rec from db',
                             px_asset_fin_rec.cost, p_log_level_rec => p_log_level_rec);
         end if;
/*
         if p_trans_rec.transaction_type_code in
                       (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET) and
            not (p_use_fin_rec_adj) then

            x_asset_fin_rec_new := px_asset_fin_rec;

--tk_util.DumpFinRec(px_asset_fin_rec, 'GO2');
--tk_util.DumpFinRec(x_asset_fin_rec_new, 'GN');

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'End', x_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
            end if;

            return TRUE;

         els*/

         if not (p_process_this_trx) then
            x_asset_fin_rec_new := px_asset_fin_rec;
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'End', x_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
            end if;

            return TRUE;
         end if;

      end if;

      if (px_asset_fin_rec.deprn_method_code is null)  then
         OPEN c_get_bk2(l_asset_id, l_transaction_header_id);
         FETCH c_get_bk2 INTO l_asset_fin_rec_adj.date_placed_in_service
                        , l_asset_fin_rec_adj.deprn_start_date
                        , l_asset_fin_rec_adj.deprn_method_code
                        , l_asset_fin_rec_adj.life_in_months
                        , l_asset_fin_rec_adj.rate_adjustment_factor
                        , l_asset_fin_rec_adj.adjusted_cost
                        , l_asset_fin_rec_adj.cost
                        , l_asset_fin_rec_adj.original_cost
                        , l_asset_fin_rec_adj.salvage_value
                        , l_asset_fin_rec_adj.prorate_convention_code
                        , l_asset_fin_rec_adj.prorate_date
                        , l_asset_fin_rec_adj.cost_change_flag
                        , l_asset_fin_rec_adj.adjustment_required_status
                        , l_asset_fin_rec_adj.capitalize_flag
                        , l_asset_fin_rec_adj.retirement_pending_flag
                        , l_asset_fin_rec_adj.depreciate_flag
                        , l_asset_fin_rec_adj.itc_amount_id
                        , l_asset_fin_rec_adj.itc_amount
                        , l_asset_fin_rec_adj.retirement_id
                        , l_asset_fin_rec_adj.tax_request_id
                        , l_asset_fin_rec_adj.itc_basis
                        , l_asset_fin_rec_adj.basic_rate
                        , l_asset_fin_rec_adj.adjusted_rate
                        , l_asset_fin_rec_adj.bonus_rule
                        , l_asset_fin_rec_adj.ceiling_name
                        , l_asset_fin_rec_adj.recoverable_cost
                        , l_asset_fin_rec_adj.adjusted_capacity
                        , l_asset_fin_rec_adj.fully_rsvd_revals_counter
                        , l_asset_fin_rec_adj.idled_flag
                        , l_asset_fin_rec_adj.period_counter_capitalized
                        , l_asset_fin_rec_adj.period_counter_fully_reserved
                        , l_asset_fin_rec_adj.period_counter_fully_retired
                        , l_asset_fin_rec_adj.production_capacity
                        , l_asset_fin_rec_adj.reval_amortization_basis
                        , l_asset_fin_rec_adj.reval_ceiling
                        , l_asset_fin_rec_adj.unit_of_measure
                        , l_asset_fin_rec_adj.unrevalued_cost
                        , l_asset_fin_rec_adj.annual_deprn_rounding_flag
                        , l_asset_fin_rec_adj.percent_salvage_value
                        , l_asset_fin_rec_adj.allowed_deprn_limit
                        , l_asset_fin_rec_adj.allowed_deprn_limit_amount
                        , l_asset_fin_rec_adj.period_counter_life_complete
                        , l_asset_fin_rec_adj.adjusted_recoverable_cost
                        , l_asset_fin_rec_adj.annual_rounding_flag
                        , l_asset_fin_rec_adj.eofy_adj_cost
                        , l_asset_fin_rec_adj.eofy_formula_factor
                        , l_asset_fin_rec_adj.short_fiscal_year_flag
                        , l_asset_fin_rec_adj.conversion_date
                        , l_asset_fin_rec_adj.orig_deprn_start_date
                        , l_asset_fin_rec_adj.remaining_life1
                        , l_asset_fin_rec_adj.remaining_life2
                        , l_asset_fin_rec_adj.group_asset_id
                        , l_asset_fin_rec_adj.old_adjusted_cost
                        , l_asset_fin_rec_adj.formula_factor
                        , l_asset_fin_rec_adj.salvage_type
                        , l_asset_fin_rec_adj.deprn_limit_type
                        , l_asset_fin_rec_adj.over_depreciate_option
                        , l_asset_fin_rec_adj.super_group_id
                        , l_asset_fin_rec_adj.reduction_rate
                        , l_asset_fin_rec_adj.reduce_addition_flag
                        , l_asset_fin_rec_adj.reduce_adjustment_flag
                        , l_asset_fin_rec_adj.reduce_retirement_flag
                        , l_asset_fin_rec_adj.recognize_gain_loss
                        , l_asset_fin_rec_adj.recapture_reserve_flag
                        , l_asset_fin_rec_adj.limit_proceeds_flag
                        , l_asset_fin_rec_adj.terminal_gain_loss
                        , l_asset_fin_rec_adj.tracking_method
                        , l_asset_fin_rec_adj.exclude_fully_rsv_flag
                        , l_asset_fin_rec_adj.excess_allocation_option
                        , l_asset_fin_rec_adj.depreciation_option
                        , l_asset_fin_rec_adj.member_rollup_flag
                        , l_asset_fin_rec_adj.ytd_proceeds
                        , l_asset_fin_rec_adj.ltd_proceeds
                        , l_asset_fin_rec_adj.allocate_to_fully_rsv_flag
                        , l_asset_fin_rec_adj.allocate_to_fully_ret_flag
                        , l_asset_fin_rec_adj.cip_cost
                        , l_asset_fin_rec_adj.terminal_gain_loss_amount
                        , l_asset_fin_rec_adj.ltd_cost_of_removal
                        , l_asset_fin_rec_adj.prior_eofy_reserve
                        , l_asset_fin_rec_adj.eofy_reserve
                        , l_asset_fin_rec_adj.eop_adj_cost
                        , l_asset_fin_rec_adj.eop_formula_factor
                        , l_asset_fin_rec_adj.global_attribute1
                        , l_asset_fin_rec_adj.global_attribute2
                        , l_asset_fin_rec_adj.global_attribute3
                        , l_asset_fin_rec_adj.global_attribute4
                        , l_asset_fin_rec_adj.global_attribute5
                        , l_asset_fin_rec_adj.global_attribute6
                        , l_asset_fin_rec_adj.global_attribute7
                        , l_asset_fin_rec_adj.global_attribute8
                        , l_asset_fin_rec_adj.global_attribute9
                        , l_asset_fin_rec_adj.global_attribute10
                        , l_asset_fin_rec_adj.global_attribute11
                        , l_asset_fin_rec_adj.global_attribute12
                        , l_asset_fin_rec_adj.global_attribute13
                        , l_asset_fin_rec_adj.global_attribute14
                        , l_asset_fin_rec_adj.global_attribute15
                        , l_asset_fin_rec_adj.global_attribute16
                        , l_asset_fin_rec_adj.global_attribute17
                        , l_asset_fin_rec_adj.global_attribute18
                        , l_asset_fin_rec_adj.global_attribute19
                        , l_asset_fin_rec_adj.global_attribute20
                        , l_asset_fin_rec_adj.global_attribute_category
                           , l_asset_fin_rec_adj.nbv_at_switch
                           , l_asset_fin_rec_adj.prior_deprn_limit_type
                           , l_asset_fin_rec_adj.prior_deprn_limit_amount
                           , l_asset_fin_rec_adj.prior_deprn_limit
                           , l_asset_fin_rec_adj.prior_deprn_method
                           , l_asset_fin_rec_adj.prior_life_in_months
                           , l_asset_fin_rec_adj.prior_basic_rate
                           , l_asset_fin_rec_adj.prior_adjusted_rate ;
         l_adj_found := c_get_bk2%FOUND;
         CLOSE c_get_bk2;

--tk_util.DumpFinRec(l_asset_fin_rec_adj, 'GO2.5');
      else
         OPEN c_get_bk(l_asset_id, l_transaction_header_id);
         FETCH c_get_bk INTO l_asset_fin_rec_adj.date_placed_in_service
                        , l_asset_fin_rec_adj.deprn_start_date
                        , l_asset_fin_rec_adj.deprn_method_code
                        , l_asset_fin_rec_adj.life_in_months
                        , l_asset_fin_rec_adj.rate_adjustment_factor
                        , l_asset_fin_rec_adj.adjusted_cost
                        , l_asset_fin_rec_adj.cost
                        , l_asset_fin_rec_adj.original_cost
                        , l_asset_fin_rec_adj.salvage_value
                        , l_asset_fin_rec_adj.prorate_convention_code
                        , l_asset_fin_rec_adj.prorate_date
                        , l_asset_fin_rec_adj.cost_change_flag
                        , l_asset_fin_rec_adj.adjustment_required_status
                        , l_asset_fin_rec_adj.capitalize_flag
                        , l_asset_fin_rec_adj.retirement_pending_flag
                        , l_asset_fin_rec_adj.depreciate_flag
                        , l_asset_fin_rec_adj.itc_amount_id
                        , l_asset_fin_rec_adj.itc_amount
                        , l_asset_fin_rec_adj.retirement_id
                        , l_asset_fin_rec_adj.tax_request_id
                        , l_asset_fin_rec_adj.itc_basis
                        , l_asset_fin_rec_adj.basic_rate
                        , l_asset_fin_rec_adj.adjusted_rate
                        , l_asset_fin_rec_adj.bonus_rule
                        , l_asset_fin_rec_adj.ceiling_name
                        , l_asset_fin_rec_adj.recoverable_cost
                        , l_asset_fin_rec_adj.adjusted_capacity
                        , l_asset_fin_rec_adj.fully_rsvd_revals_counter
                        , l_asset_fin_rec_adj.idled_flag
                        , l_asset_fin_rec_adj.period_counter_capitalized
                        , l_asset_fin_rec_adj.period_counter_fully_reserved
                        , l_asset_fin_rec_adj.period_counter_fully_retired
                        , l_asset_fin_rec_adj.production_capacity
                        , l_asset_fin_rec_adj.reval_amortization_basis
                        , l_asset_fin_rec_adj.reval_ceiling
                        , l_asset_fin_rec_adj.unit_of_measure
                        , l_asset_fin_rec_adj.unrevalued_cost
                        , l_asset_fin_rec_adj.annual_deprn_rounding_flag
                        , l_asset_fin_rec_adj.percent_salvage_value
                        , l_asset_fin_rec_adj.allowed_deprn_limit
                        , l_asset_fin_rec_adj.allowed_deprn_limit_amount
                        , l_asset_fin_rec_adj.period_counter_life_complete
                        , l_asset_fin_rec_adj.adjusted_recoverable_cost
                        , l_asset_fin_rec_adj.annual_rounding_flag
                        , l_asset_fin_rec_adj.eofy_adj_cost
                        , l_asset_fin_rec_adj.eofy_formula_factor
                        , l_asset_fin_rec_adj.short_fiscal_year_flag
                        , l_asset_fin_rec_adj.conversion_date
                        , l_asset_fin_rec_adj.orig_deprn_start_date
                        , l_asset_fin_rec_adj.remaining_life1
                        , l_asset_fin_rec_adj.remaining_life2
                        , l_asset_fin_rec_adj.group_asset_id
                        , l_asset_fin_rec_adj.old_adjusted_cost
                        , l_asset_fin_rec_adj.formula_factor
                        , l_asset_fin_rec_adj.salvage_type
                        , l_asset_fin_rec_adj.deprn_limit_type
                        , l_asset_fin_rec_adj.over_depreciate_option
                        , l_asset_fin_rec_adj.super_group_id
                        , l_asset_fin_rec_adj.reduction_rate
                        , l_asset_fin_rec_adj.reduce_addition_flag
                        , l_asset_fin_rec_adj.reduce_adjustment_flag
                        , l_asset_fin_rec_adj.reduce_retirement_flag
                        , l_asset_fin_rec_adj.recognize_gain_loss
                        , l_asset_fin_rec_adj.recapture_reserve_flag
                        , l_asset_fin_rec_adj.limit_proceeds_flag
                        , l_asset_fin_rec_adj.terminal_gain_loss
                        , l_asset_fin_rec_adj.tracking_method
                        , l_asset_fin_rec_adj.exclude_fully_rsv_flag
                        , l_asset_fin_rec_adj.excess_allocation_option
                        , l_asset_fin_rec_adj.depreciation_option
                        , l_asset_fin_rec_adj.member_rollup_flag
                        , l_asset_fin_rec_adj.ytd_proceeds
                        , l_asset_fin_rec_adj.ltd_proceeds
                        , l_asset_fin_rec_adj.allocate_to_fully_rsv_flag
                        , l_asset_fin_rec_adj.allocate_to_fully_ret_flag
                        , l_asset_fin_rec_adj.cip_cost
                        , l_asset_fin_rec_adj.terminal_gain_loss_amount
                        , l_asset_fin_rec_adj.ltd_cost_of_removal
                        , l_asset_fin_rec_adj.prior_eofy_reserve
                        , l_asset_fin_rec_adj.eofy_reserve
                        , l_asset_fin_rec_adj.eop_adj_cost
                        , l_asset_fin_rec_adj.eop_formula_factor
                        , l_asset_fin_rec_adj.global_attribute1
                        , l_asset_fin_rec_adj.global_attribute2
                        , l_asset_fin_rec_adj.global_attribute3
                        , l_asset_fin_rec_adj.global_attribute4
                        , l_asset_fin_rec_adj.global_attribute5
                        , l_asset_fin_rec_adj.global_attribute6
                        , l_asset_fin_rec_adj.global_attribute7
                        , l_asset_fin_rec_adj.global_attribute8
                        , l_asset_fin_rec_adj.global_attribute9
                        , l_asset_fin_rec_adj.global_attribute10
                        , l_asset_fin_rec_adj.global_attribute11
                        , l_asset_fin_rec_adj.global_attribute12
                        , l_asset_fin_rec_adj.global_attribute13
                        , l_asset_fin_rec_adj.global_attribute14
                        , l_asset_fin_rec_adj.global_attribute15
                        , l_asset_fin_rec_adj.global_attribute16
                        , l_asset_fin_rec_adj.global_attribute17
                        , l_asset_fin_rec_adj.global_attribute18
                        , l_asset_fin_rec_adj.global_attribute19
                        , l_asset_fin_rec_adj.global_attribute20
                        , l_asset_fin_rec_adj.global_attribute_category
                           , l_asset_fin_rec_adj.nbv_at_switch
                           , l_asset_fin_rec_adj.prior_deprn_limit_type
                           , l_asset_fin_rec_adj.prior_deprn_limit_amount
                           , l_asset_fin_rec_adj.prior_deprn_limit
                           , l_asset_fin_rec_adj.prior_deprn_method
                           , l_asset_fin_rec_adj.prior_life_in_months
                           , l_asset_fin_rec_adj.prior_basic_rate
                           , l_asset_fin_rec_adj.prior_adjusted_rate ;
         l_adj_found := c_get_bk%FOUND;
         CLOSE c_get_bk;
      end if; -- (px_asset_fin_rec.deprn_method_code is null)

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Got bk to find delta from db',
                          l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
      end if;


   end if; -- (nvl(p_mrc_sob_type_code, 'P') = 'R')

--tk_util.DumpFinRec(px_asset_fin_rec, 'GO2');

   l_reclass_trx :=  (nvl(px_asset_fin_rec.group_asset_id, 0) <>
                      nvl(l_asset_fin_rec_adj.group_asset_id, px_asset_fin_rec.group_asset_id)); -- bug# 5383699

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'p_use_fin_rec_adj', p_use_fin_rec_adj, p_log_level_rec => p_log_level_rec);
   end if;

   if ((not(p_use_fin_rec_adj)) and
       (p_use_new_deprn_rule)) or
      (l_is_member_trx_for_group) then
      --
      -- Process transaction from db but use current rules in the case this transaction
      -- happened after current transaction
      --
      l_tmp_cost                      := l_asset_fin_rec_adj.cost;
      l_tmp_percent_salvage_value     := l_asset_fin_rec_adj.percent_salvage_value;
      l_tmp_salvage_value             := l_asset_fin_rec_adj.salvage_value;
      l_tmp_allowed_deprn_limit       := l_asset_fin_rec_adj.allowed_deprn_limit;
      l_tmp_allowed_deprn_limit_amt   := l_asset_fin_rec_adj.allowed_deprn_limit_amount;
      l_tmp_production_capacity       := l_asset_fin_rec_adj.production_capacity;
      l_tmp_fully_rsv_revals_counter  := l_asset_fin_rec_adj.fully_rsvd_revals_counter;
      l_tmp_reval_amortization_basis  := l_asset_fin_rec_adj.reval_amortization_basis;
      l_tmp_reval_ceiling             := l_asset_fin_rec_adj.reval_ceiling;
      l_tmp_unrevalued_cost           := l_asset_fin_rec_adj.unrevalued_cost;
      l_tmp_eofy_reserve              := l_asset_fin_rec_adj.eofy_reserve;

      l_asset_fin_rec_adj := p_asset_fin_rec_new;

      l_asset_fin_rec_adj.cost := l_tmp_cost;
      l_asset_fin_rec_adj.percent_salvage_value := l_tmp_percent_salvage_value;
      l_asset_fin_rec_adj.salvage_value := l_tmp_salvage_value;
      -- Bug 6863138 Considering deprn_limit as non delta amounts
      /* Bug 8356539..commenting the below code. as now we'll pass 'TRUE'
      for p_called_from_faxama in call to FA_ASSET_CALC_PVT.calc_deprn_limit_adj_rec_cost*/
      /* -- Bug 7283130
       if (l_asset_fin_rec_adj.deprn_limit_type = 'AMT' ) then
           l_asset_fin_rec_adj.allowed_deprn_limit := Null;
          if  p_trans_rec.calling_interface <>'FAXASSET' then
              l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
              l_tmp_allowed_deprn_limit_amt;
          end if;
      else
         l_asset_fin_rec_adj.allowed_deprn_limit := l_tmp_allowed_deprn_limit;
      end if;
      --Bug 7283130 ends
      */
      l_asset_fin_rec_adj.production_capacity :=l_tmp_production_capacity;
      l_asset_fin_rec_adj.fully_rsvd_revals_counter := l_tmp_fully_rsv_revals_counter;
      l_asset_fin_rec_adj.reval_amortization_basis := l_tmp_reval_amortization_basis;
      l_asset_fin_rec_adj.reval_ceiling := l_tmp_reval_ceiling;
      l_asset_fin_rec_adj.unrevalued_cost := l_tmp_unrevalued_cost;
      l_asset_fin_rec_adj.eofy_reserve := l_tmp_eofy_reserve;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Need to use latest values except amounts',
                          l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
      end if;

   elsif ((p_use_fin_rec_adj) or
          (l_asset_fin_rec_adj.date_placed_in_service is null)) and
          ((not (l_adj_found)) or (l_reclass_trx)) then
      --
      -- Process current transaction
      --
      l_asset_fin_rec_adj := p_asset_fin_rec_adj;

     -- Bug# 7046389
     -- Call below module only if calling form application.
     -- This will not be executed if called from adjustment API.

     --bug 8356539 commenting below if condition

     --if (p_trans_rec.calling_interface = 'FAXASSET') then

      -- Bug 6863138 Need to get the new value of deprn_limit in
      -- in l_asset_fin_rec_adj
      if l_asset_fin_rec_adj.deprn_limit_type is not null then

         SELECT bk1.deprn_limit_type, nvl(bk1.allowed_deprn_limit_amount,0), nvl(bk1.allowed_deprn_limit,0)
         INTO   l_tmp_deprn_limit_type, l_tmp_allowed_deprn_limit_amt, l_tmp_allowed_deprn_limit
         FROM   fa_books bk1
         WHERE  bk1.asset_id = p_asset_hdr_rec.asset_id
         and    bk1.book_type_code = p_asset_hdr_rec.book_type_code
         and    bk1.transaction_header_id_out is null;

         -- Bug#7046389
         if nvl(l_tmp_deprn_limit_type,'NONE') = l_asset_fin_rec_adj.deprn_limit_type then
            l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                    nvl(l_asset_fin_rec_adj.allowed_deprn_limit_amount,0) + l_tmp_allowed_deprn_limit_amt;
            if l_asset_fin_rec_adj.deprn_limit_type = 'PCT' then
               l_asset_fin_rec_adj.allowed_deprn_limit :=
                       nvl(l_asset_fin_rec_adj.allowed_deprn_limit,0) + l_tmp_allowed_deprn_limit;
               /* Bug 8356539..recalculate the deprn limit amount in case the type is 'PCT'
                  and adjustment is done through API*/
               if p_trans_rec.calling_interface <> 'FAXASSET' then
                  l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                           (1-l_asset_fin_rec_adj.allowed_deprn_limit) * (px_asset_fin_rec.cost+l_asset_fin_rec_adj.cost);
               end if;
            end if;
         end if;
      end if;
     -- end if; /* End if for p_trans_rec.calling_interface = 'FAXASSET' */  --8356539

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'This is the transaction user entered',
                          l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'After if allowed_deprn_limit_amount',
                          l_asset_fin_rec_adj.allowed_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'After if allowed_deprn_limit',
                          l_asset_fin_rec_adj.allowed_deprn_limit, p_log_level_rec => p_log_level_rec);
      end if;

   else
      -- Process transaction from db.  Current transaction has date later than this.
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Delta comes from db', l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
      end if;
   end if;

--tk_util.DumpFinRec(l_asset_fin_rec_adj, 'GA');

  if (instrb(p_trans_rec.transaction_type_code, 'ADDITION') <> 0) and
     (px_asset_fin_rec.date_placed_in_service is not null) then
    x_asset_fin_rec_new := px_asset_fin_rec;
  else
    x_asset_fin_rec_new := l_asset_fin_rec_adj;
  end if;
  -- 7184690 below lines are commented out
  -- These lines were introduced by bug#7109525
  --if p_trans_rec.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT') THEN
  --      x_asset_fin_rec_new.cost := 0;
  --      l_asset_fin_rec_adj.cost := 0;
  --end if;
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'x_asset_fin_rec_new.cost', x_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.transaction_type_code', p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
      end if;

  --
  -- Defaulting Values
  --
  x_asset_fin_rec_new.prorate_convention_code   :=
         nvl(l_asset_fin_rec_adj.prorate_convention_code,
             nvl(px_asset_fin_rec.prorate_convention_code,
                 fa_cache_pkg.fazccbd_record.prorate_convention_code));

  x_asset_fin_rec_new.depreciate_flag           :=
         nvl(l_asset_fin_rec_adj.depreciate_flag,
             nvl(px_asset_fin_rec.depreciate_flag,
                 fa_cache_pkg.fazccbd_record.depreciate_flag));

  FA_UTIL_PVT.load_char_value
         (p_char_old  => px_asset_fin_rec.bonus_rule,
          p_char_adj  => l_asset_fin_rec_adj.bonus_rule,
          x_char_new  => x_asset_fin_rec_new.bonus_rule, p_log_level_rec => p_log_level_rec);

  FA_UTIL_PVT.load_char_value
         (p_char_old  => px_asset_fin_rec.ceiling_name,
          p_char_adj  => l_asset_fin_rec_adj.ceiling_name,
          x_char_new  => x_asset_fin_rec_new.ceiling_name, p_log_level_rec => p_log_level_rec);

  -- This is for FLAT RATE EXTENSION deprn basis rule
  FA_UTIL_PVT.load_char_value
         (p_char_old  => px_asset_fin_rec.exclude_fully_rsv_flag,
          p_char_adj  => l_asset_fin_rec_adj.exclude_fully_rsv_flag,
          x_char_new  => x_asset_fin_rec_new.exclude_fully_rsv_flag, p_log_level_rec => p_log_level_rec);

  x_asset_fin_rec_new.recognize_gain_loss :=
                  p_asset_fin_rec_new.recognize_gain_loss;

  x_asset_fin_rec_new.recapture_reserve_flag :=
                  p_asset_fin_rec_new.recapture_reserve_flag;

  x_asset_fin_rec_new.limit_proceeds_flag :=
                  p_asset_fin_rec_new.limit_proceeds_flag;

  x_asset_fin_rec_new.terminal_gain_loss :=
                  p_asset_fin_rec_new.terminal_gain_loss;

  x_asset_fin_rec_new.exclude_proceeds_from_basis :=
                  p_asset_fin_rec_new.exclude_proceeds_from_basis;

  x_asset_fin_rec_new.retirement_deprn_option :=
                  p_asset_fin_rec_new.retirement_deprn_option;

  x_asset_fin_rec_new.tracking_method :=
                  p_asset_fin_rec_new.tracking_method;

  x_asset_fin_rec_new.allocate_to_fully_rsv_flag :=
                  p_asset_fin_rec_new.allocate_to_fully_rsv_flag;

  x_asset_fin_rec_new.allocate_to_fully_ret_flag :=
                  p_asset_fin_rec_new.allocate_to_fully_ret_flag;

  x_asset_fin_rec_new.excess_allocation_option :=
                  p_asset_fin_rec_new.excess_allocation_option;

  x_asset_fin_rec_new.depreciation_option :=
                  p_asset_fin_rec_new.depreciation_option;

  x_asset_fin_rec_new.member_rollup_flag :=
                  p_asset_fin_rec_new.member_rollup_flag;

  if not FA_ASSET_CALC_PVT.calc_new_amounts(
               px_trans_rec              => p_trans_rec,
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_desc_rec          => l_asset_desc_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_cat_rec           => l_asset_cat_rec,
               p_asset_fin_rec_old       => px_asset_fin_rec,
               p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
               px_asset_fin_rec_new      => x_asset_fin_rec_new,
               p_asset_deprn_rec_old     => l_asset_deprn_rec,
               p_asset_deprn_rec_adj     => l_asset_deprn_rec,
               px_asset_deprn_rec_new    => l_asset_deprn_rec,
               p_mrc_sob_type_code       => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then

     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                         'FA_ASSET_CALC_PVT.calc_new_amounts',  p_log_level_rec => p_log_level_rec);
     end if;

     raise calc_failed;
  end if;

   x_asset_fin_rec_new.eofy_reserve  := nvl(l_asset_fin_rec_adj.eofy_reserve, 0) +
                                        nvl(px_asset_fin_rec.eofy_reserve, 0);

   if not FA_UTILS_PKG.faxrnd(x_asset_fin_rec_new.eofy_reserve,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
      raise calc_failed;
   end if;

  if not FA_ASSET_CALC_PVT.calc_prorate_date
              (p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
               px_asset_fin_rec_new      => x_asset_fin_rec_new,
               p_period_rec              => l_period_rec, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                          'FA_ASSET_CALC_PVT.calc_prorate_date',  p_log_level_rec => p_log_level_rec);
      end if;

    raise calc_failed;
  end if;

  if not FA_ASSET_CALC_PVT.calc_deprn_info
              (p_trans_rec               => p_trans_rec,
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_desc_rec          => l_asset_desc_rec,
               p_asset_cat_rec           => l_asset_cat_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_fin_rec_old       => px_asset_fin_rec,
               p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
               px_asset_fin_rec_new      => x_asset_fin_rec_new,
               p_asset_deprn_rec_adj     => l_asset_deprn_rec,
               p_asset_deprn_rec_new     => l_asset_deprn_rec,
               p_period_rec              => l_period_rec
              , p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                          'FA_ASSET_CALC_PVT.calc_deprn_info',  p_log_level_rec => p_log_level_rec);
      end if;

    raise calc_failed;
  end if;

  if not FA_ASSET_CALC_PVT.calc_deprn_start_date(
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
               px_asset_fin_rec_new      => x_asset_fin_rec_new, p_log_level_rec => p_log_level_rec) then

     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                         'FA_ASSET_CALC_PVT.calc_deprn_start_date',  p_log_level_rec => p_log_level_rec);
     end if;

     raise calc_failed;
  end if;

  if not FA_ASSET_CALC_PVT.calc_salvage_value(
               p_trans_rec               => p_trans_rec,
               p_asset_hdr_rec           => p_asset_hdr_rec,
               p_asset_type_rec          => p_asset_type_rec,
               p_asset_fin_rec_old       => px_asset_fin_rec,
               p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
               px_asset_fin_rec_new      => x_asset_fin_rec_new,
               p_mrc_sob_type_code       => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                          'FA_ASSET_CALC_PVT.calc_salvage_value',  p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;
  end if;

  if not FA_ASSET_CALC_PVT.calc_rec_cost
          (p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
           px_asset_fin_rec_new      => x_asset_fin_rec_new, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                          'FA_ASSET_CALC_PVT.calc_rec_cost',  p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;
  end if;

  if not FA_ASSET_CALC_PVT.calc_deprn_limit_adj_rec_cost
          (p_asset_hdr_rec           => p_asset_hdr_rec,
           p_asset_type_rec          => p_asset_type_rec,
           p_asset_fin_rec_old       => px_asset_fin_rec,
           p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
           px_asset_fin_rec_new      => x_asset_fin_rec_new,
	   /*bug 9006343 need to pass p_called_from_faxama as FALSE for trx in which extended deprn is availed*/
           p_called_from_faxama      => (nvl(p_trans_rec.transaction_key,'XX') <> 'ES'),
          /* Commented for bug# 7046389 */
           --p_called_from_faxama      => TRUE,-- 8356539 -- Bug 6604235
           --p_called_from_faxama      => (p_trans_rec.calling_interface = 'FAXASSET'),-- bug 8356539
           p_mrc_sob_type_code       => p_mrc_sob_type_code,
                    p_log_level_rec       => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                          'FA_ASSET_CALC_PVT.calc_deprn_limit_adj_rec_cost',  p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;
  end if;
--tk_util.debug('adj_rec_cost: '|| to_char(x_asset_fin_rec_new.adjusted_recoverable_cost));


  if (fa_cache_pkg.fazcbc_record.book_class = 'TAX' and
       x_asset_fin_rec_new.itc_amount_id is not null) then
     if not FA_ASSET_CALC_PVT.calc_itc_info
             (p_asset_hdr_rec           => p_asset_hdr_rec,
              p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
              px_asset_fin_rec_new      => x_asset_fin_rec_new, p_log_level_rec => p_log_level_rec) then

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Falied calling',
                            'FA_ASSET_CALC_PVT.calc_itc_info',  p_log_level_rec => p_log_level_rec);
        end if;

        raise calc_failed;
     end if;

  end if;

  x_dpis_change := (px_asset_fin_rec.date_placed_in_service <> l_asset_fin_rec_adj.date_placed_in_service);

--tk_util.DumpFinRec(x_asset_fin_rec_new, 'GN');

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'End', x_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
  end if;

  return TRUE;
EXCEPTION
  WHEN calc_failed THEN
     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'calc_failed', p_log_level_rec => p_log_level_rec);
     end if;

    if c_get_init_mcbk%ISOPEN then
      CLOSE c_get_init_mcbk;
    end if;

    if c_get_init_bk%ISOPEN then
      CLOSE c_get_init_bk;
    end if;

    if c_get_mcbk%ISOPEN then
      CLOSE c_get_mcbk;
    end if;

    if c_get_bk%ISOPEN then
      CLOSE c_get_bk;
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    if c_get_init_mcbk%ISOPEN then
      CLOSE c_get_init_mcbk;
    end if;

    if c_get_init_bk%ISOPEN then
      CLOSE c_get_init_bk;
    end if;

    if c_get_mcbk%ISOPEN then
      CLOSE c_get_mcbk;
    end if;

    if c_get_bk%ISOPEN then
      CLOSE c_get_bk;
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

END GetFinRec;

--+==============================================================================
-- Function: Recalculate
--
--   This function calculate catch-up amounts due to backdated
--   amortization transactions.

--   1: Find transaction to start recalculation.
--   2: Get initial asset_fin_rec, and asset_deprn_rec.  Values in these rec will
--      be chagned as recalculation proceeds.
--   3: Process all transaction dated after transaction found at first step.
--      xxx All trx except Revaluation, Tax Reserve Adjustment, Reinstatement,
--          Unit Adjustment, Transfer, and Reclass.
--      3.1: Fetch one transaction
--      3.2: Call faxcde to get reserve for adjusted_cost, raf and formula_factor
--      3.3: Call Deprn Basis function to get new adjusted_cost, raf and formula_factor.
--      3.4: If there is no transaction in this period, call faxcde until next trx
--           to process (If there is no next trx, depreciate until current period).
--      NOTE: Retirement which has been reinstated will not be processed at all.
--   4: Return catch-up amount.
--+==============================================================================
FUNCTION Recalculate(
    p_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec                     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec                    FA_API_TYPES.asset_type_rec_type,
    p_asset_desc_rec                    FA_API_TYPES.asset_desc_rec_type,
    p_asset_fin_rec_old                 FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj                 FA_API_TYPES.asset_fin_rec_type default null,
    p_period_rec                        FA_API_TYPES.period_rec_type,
    px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec                   FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj               FA_API_TYPES.asset_deprn_rec_type default null,
    x_deprn_expense          OUT NOCOPY FA_DEPRN_SUMMARY.DEPRN_AMOUNT%TYPE,
    x_bonus_expense          OUT NOCOPY FA_DEPRN_SUMMARY.BONUS_DEPRN_AMOUNT%TYPE,
    x_impairment_expense     OUT NOCOPY FA_DEPRN_SUMMARY.IMPAIRMENT_AMOUNT%TYPE,
    p_running_mode        IN            NUMBER,
    p_used_by_revaluation IN            NUMBER,
    p_reclassed_asset_id                NUMBER,
    p_reclass_src_dest                  VARCHAR2,
    p_reclassed_asset_dpis              DATE,
    p_source_transaction_type_code      VARCHAR2,
    p_mrc_sob_type_code                 VARCHAR2,
    p_calling_fn                        VARCHAR2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
)  RETURN BOOLEAN IS

   l_calling_fn                   VARCHAR2(100) := 'FA_AMORT_CALC_PVT.Recalculate';

   --Bug3696765
   l_process_addition             BINARY_INTEGER := 1; -- 1: process (amort nbv) addition,
                                                       -- 0: do not process (amort nbv) addition

   l_depreciate_flag              VARCHAR2(3); -- Bug 5726160
   l_entered_reserve              NUMBER; -- Bug 5443855
   l_entered_ytd                  NUMBER;

   -- Bug 8674466 :
   l_ret_prorate_pc  NUMBER;
   l_future_ret_count NUMBER;

   CURSOR c_get_deprn_period_date IS
     select dp.calendar_period_open_date
           ,ds.ytd_deprn
           ,ds.deprn_reserve
     from   fa_deprn_summary ds
          , fa_deprn_periods dp
     where  dp.book_type_code = p_asset_hdr_rec.book_type_code
     and    ds.book_type_code = p_asset_hdr_rec.book_type_code
     and    ds.asset_id = p_asset_hdr_rec.asset_id
     and    ds.deprn_source_code = 'BOOKS'
     and    dp.period_counter = ds.period_counter + 1;

   -- Bug 8686315 : Added trx_type_code also
   CURSOR c_get_first_trx IS
     select th.transaction_header_id
          , nvl(th.amortization_start_date, th.transaction_date_entered)
          , th.date_effective
          , th.transaction_type_code
     from fa_transaction_headers th
     where th.asset_id = p_asset_hdr_rec.asset_id
     and   th.book_type_code = p_asset_hdr_rec.book_type_code
     and th.transaction_header_id = (select min(th2.transaction_header_id)
                                     from   fa_transaction_headers th2
                                     where  th2.asset_id = p_asset_hdr_rec.asset_id
                                     and    th2.book_type_code = p_asset_hdr_rec.book_type_code);

   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- This is the cursor to find a transaction which has older
   -- transaction_date_entered but newer calendar_period_close_open_date
   -- than given transaction_date_entered.
   -- 1st select returns transaction like mention above.
   --
   -- 2nd select returns reinstatement transactioin for core asset as
   -- dated transaction back to retirement date so if given
   -- transaction_date_entered is between retirement and reinstatement,
   -- this program makes sure to start recalculate at least before
   -- the retirement.
   --
   -- 3rd select returns reinstatement transactioin of member for group
   -- as dated transaction back to retirement date so if given
   -- transaction_date_entered is between retirement and reinstatement,
   -- this program makes sure to start recalculate at least before
   -- the retirement.
   --
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Bug3797105: 1st part of following cursor was returning trx which
   -- has performed in the same period as the period that passed date
   -- falls in.
   -- Bug5332733: The second column in the select clause was returning null
   -- so, added else part to the decode clause.

   CURSOR c_check_overlap (c_transaction_date_entered date,
                           c_transaction_header_id    number,
                           c_date_effective           date) IS
    select th.transaction_header_id    transaction_header_id,
           decode(l_process_addition,
                   1, decode( th.transaction_subtype,
                             'EXPENSED', px_asset_fin_rec_new.date_placed_in_service,
                              decode(th.transaction_type_code,
                                 'ADDITION', th.transaction_date_entered,
                                 'ADDITION/VOID', th.transaction_date_entered,
                                  nvl(th.amortization_start_date,th.transaction_date_entered)),
                              nvl(th.amortization_start_date,th.transaction_date_entered),
                              nvl(th.amortization_start_date,th.transaction_date_entered)
                            ),
                   nvl(th.amortization_start_date,th.transaction_date_entered)
                  )  transaction_date_entered,
           th.date_effective date_effective,
           th.transaction_type_code transaction_type_code
    from   fa_transaction_headers th
         , fa_deprn_periods dp
    where  th.asset_id = p_asset_hdr_rec.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    dp.book_type_code = p_asset_hdr_rec.book_type_code
--    and    th.date_effective between dp.period_open_date
--                                 and nvl(dp.period_close_date, sysdate)
    and c_transaction_date_entered between dp.calendar_period_open_date
                                             and dp.calendar_period_close_date
    -- and (th.date_effective > nvl(dp.period_close_date, sysdate))
    -- Bug 6612507
    and ((th.date_effective > nvl(dp.period_close_date, sysdate)) or
         ((th.date_effective between dp.period_open_date and nvl(dp.period_close_date, sysdate)) and
          (nvl(th.transaction_subtype,'EXPENSED') ='AMORTIZED')))
    and    (    nvl(th.amortization_start_date,
                    decode(th.transaction_subtype,
                           'EXPENSED', px_asset_fin_rec_new.date_placed_in_service,
                           th.transaction_date_entered
                          )
                    ) <= c_transaction_date_entered
            and th.date_effective < c_date_effective)
    and    c_transaction_date_entered <= dp.calendar_period_close_date
    and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                            G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                            G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                            G_TRX_TYPE_TFR_VOID)
   union all
    select ret.transaction_header_id    transaction_header_id,
           ret.transaction_date_entered transaction_date_entered,
           ret.date_effective date_effective,
           ret.transaction_type_code transaction_type_code
    from   fa_transaction_headers ret,
           fa_transaction_headers rei,
           fa_retirements faret
    where  ret.asset_id = p_asset_hdr_rec.asset_id
    and    rei.asset_id = p_asset_hdr_rec.asset_id
    and    ret.book_type_code = p_asset_hdr_rec.book_type_code
    and    rei.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.transaction_header_id = faret.transaction_header_id_in
    and    rei.transaction_header_id = faret.transaction_header_id_out
    and    c_transaction_date_entered between
                 ret.transaction_date_entered and rei.transaction_date_entered
    and    ret.date_effective < c_date_effective
    and    ret.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)
    and    rei.transaction_type_code = G_TRX_TYPE_REI
    and    ret.transaction_header_id <> c_transaction_header_id
    order by transaction_header_id;

   CURSOR c_check_overlap2 is
      select th.transaction_header_id    transaction_header_id,
             decode(th.transaction_subtype,
                        'EXPENSED', px_asset_fin_rec_new.date_placed_in_service,
                                    nvl(th.amortization_start_date,th.transaction_date_entered)
                   )  transaction_date_entered,
             th.date_effective date_effective,
             th.transaction_type_code transaction_type_code
      from   fa_transaction_headers th
      where  th.asset_id = p_asset_hdr_rec.asset_id
      and    th.book_type_code = p_asset_hdr_rec.book_type_code
      and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                              G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                              G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                              G_TRX_TYPE_TFR_VOID, G_TRX_TYPE_ADD_VOID,
                                              G_TRX_TYPE_ADD)
      and    decode(th.transaction_subtype, null, px_asset_fin_rec_new.date_placed_in_service,
                                                  th.amortization_start_date) <
              nvl(p_trans_rec.amortization_start_date, p_trans_rec.transaction_date_entered);

--toru
   l_incoming_thid                number(15);

   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- This cursor gets all transaction needs to be reprocessed in
   -- order of transaction_date_entered.
   -- 1st select gets all (group) asset transactions except followings
   --   1. Transaction Type Code of TRANSFER OUT(IN), TRANSFER, TRANSFER IN/VOID,
   --      RECLASS, UNIT ADJUSTMENT, and REINSTATEMENT.
   --   2. Transaction of group if there is a member transaction associated with
   --      this transaction and the member is not currently this group's member
   --   3. Transaction of group reclass
   -- 2nd select gets all member transactions which has no group associated
   -- group transaction or there is a group transaction associated to the transaction
   -- but the group is not the same as current group asset.
   -- 3rd select returns current transaction.  This doesn't return anything
   -- if it is not member of this processed group asset or transaction type
   -- code is one of mentioned above.
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- This is basically the same as c_get_ths_gadj but non-group asset
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    CURSOR c_get_ths_adj (c_transaction_date_entered date,
                         c_date_effective           date,
                         c_transaction_header_id    number,
                         c_retirement_flag          varchar2) IS
    select th.transaction_header_id transaction_header_id,
           th.transaction_type_code transaction_type_code,
           decode(l_process_addition,
                   1, decode(th.transaction_type_code,
                            'ADDITION', th.transaction_date_entered,
                            'ADDITION/VOID', th.transaction_date_entered,
                                decode(th.transaction_key, 'IM', to_date('01-'||to_char(add_months(th.amortization_start_date, 1), 'MM-YYYY'), 'DD-MM-YYYY'),
                                  /* Japan Tax phase3 */   'ES', (select calendar_period_open_date
                                                                  from fa_deprn_periods
                                                                  where book_type_code = p_asset_hdr_rec.book_type_code
                                                                  and period_counter = bk.extended_depreciation_period),
                                                                  nvl(th.amortization_start_date,
                                    decode(th.transaction_subtype,
                                            'EXPENSED', decode(outbk.depreciate_flag,
                                                               'NO', decode(bk.depreciate_flag,
                                                                            'YES', decode(ds.deprn_reserve,
                                                                                          0, bk.date_placed_in_service,
                                                                                             th.transaction_date_entered),
--Bug6190904: Replacing a line above with this could be an option.    bk.date_placed_in_service),
                                                                                   -- Bug#4699743 th.transaction_date_entered),
                                                                                   bk.date_placed_in_service),
                                                                     -- Bug# 4049799 bk.date_placed_in_service),
                                                                     px_asset_fin_rec_new.date_placed_in_service),
                                                         th.transaction_date_entered)))),
                         decode(th.transaction_key, 'IM', to_date('01-'||to_char(add_months(th.amortization_start_date, 1), 'MM-YYYY'), 'DD-MM-YYYY'),
                           /* Japan Tax phase3 */   'ES', (select calendar_period_open_date
                                                           from fa_deprn_periods
                                                           where book_type_code = p_asset_hdr_rec.book_type_code
                                                           and period_counter = bk.extended_depreciation_period),
                                                           nvl(th.amortization_start_date,
                                decode(th.transaction_subtype,
                                          'EXPENSED', decode(outbk.depreciate_flag,
                                                                'NO', decode(bk.depreciate_flag,
                                                                               'YES', decode(ds.deprn_reserve,
                                                                                                  0, bk.date_placed_in_service,
                                                                                                     th.transaction_date_entered),
                                                                                      th.transaction_date_entered),
                                                                      -- Bug# 4049799 bk.date_placed_in_service),
                                                                     px_asset_fin_rec_new.date_placed_in_service),
                                                      th.transaction_date_entered)))) transaction_date_entered,
           th.date_effective date_effective,
           th.transaction_name transaction_name,
           th.source_transaction_header_id source_transaction_header_id,
           th.mass_reference_id mass_reference_id,
           th.transaction_subtype transaction_subtype,
           th.transaction_key transaction_key,
           th.amortization_start_date amortization_start_date,
           th.calling_interface calling_interface,
           th.mass_transaction_id mass_transaction_id,
           fa_std_types.FA_NO_OVERRIDE deprn_override_flag,
           th.member_transaction_header_id member_transaction_header_id,
           th.trx_reference_id trx_reference_id,
           th.invoice_transaction_id,
           '1st SELECT in c_get_ths_adj'
    from   fa_transaction_headers th,
           fa_books bk
         , fa_books outbk
         , fa_deprn_summary ds
    where  th.asset_id = p_asset_hdr_rec.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    bk.asset_id = p_asset_hdr_rec.asset_id
    and    bk.book_type_code = p_asset_hdr_rec.book_type_code
    and    bk.transaction_header_id_in = th.transaction_header_id
    and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                            G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                            G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                            G_TRX_TYPE_TFR_VOID, G_TRX_TYPE_REI,
                                            G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET,
    --
    --Bug6933891: Fix for bug5074327 included addition void trx as trx NOT to be processed
    --            However void trx needs to come in as the subsequent trx in the period of addition
    --            may not share the same trx date.  As a result, we need to process the some void trx
    --            Whether to process the void trx will be determined in the main loop.  Not here.
    --            Leave CIP ADDITION Void trx for now but it may be removed from this not in condition
    --            as well later.
                                            G_TRX_TYPE_CIP_ADJ, -- Bug# 5074327, 5191200
                                            G_TRX_TYPE_CIP_ADD_VOID, G_TRX_TYPE_CIP_ADD) -- Bug: 6019450, 6798953
    and    (th.transaction_header_id >= c_transaction_header_id
      or       th.transaction_header_id < c_transaction_header_id
         and   th.date_effective <= c_date_effective  --Bug6617982
--         and   th.transaction_date_entered > c_transaction_date_entered)
         and   decode(th.transaction_subtype, NULL,
                            decode(th.transaction_type_code,
                                     'ADDITION/VOID', px_asset_fin_rec_new.date_placed_in_service,
                                     'CIP ADDITION/VOID', px_asset_fin_rec_new.date_placed_in_service,
                                                          th.transaction_date_entered),
                                                    th.transaction_date_entered) > c_transaction_date_entered)
    and    th.transaction_header_id <> l_incoming_thid
    and    not exists (select 'Exclude reclass trx'
                       from   fa_trx_references tr
                       where  tr.member_asset_id = th.asset_id
                       and    tr.member_transaction_header_id = th.transaction_header_id
                       and    tr.book_type_code = p_asset_hdr_rec.book_type_code
                       and    tr.transaction_type = G_TRX_TYPE_GRP_CHG)
    /*Bug# 8946649 - No need to pick rolled back impairment and transaction got created to reverse impairment*/
    and    bk.transaction_header_id_out not in (select transaction_header_id
                                                from   fa_transaction_headers th2
                                                where  th2.asset_id = th.asset_id
                                                and    th2.book_type_code = p_asset_hdr_rec.book_type_code
                                                and    th2.transaction_key = 'RM')
    and    nvl(th.transaction_key,'XX') <> 'RM' /*Bug#9355389 - placed nvl around key */
    and    ds.asset_id(+) = p_asset_hdr_rec.asset_id
    and    ds.book_type_code(+) = p_asset_hdr_rec.book_type_code
    and    ds.deprn_source_code(+) = 'BOOKS'
    and    outbk.asset_id(+) = p_asset_hdr_rec.asset_id
    and    outbk.book_type_code(+) = p_asset_hdr_rec.book_type_code
    and    outbk.transaction_header_id_out(+) = bk.transaction_header_id_in
    and    bk.depreciate_flag = outbk.depreciate_flag(+)  /* Bug 7199183 add this condition*//*Bug 7653832 Added folloing*/
    and    decode(th.transaction_type_code, 'ADDITION/VOID',th.transaction_date_entered,
                                            'CIP ADDITION/VOID',th.transaction_date_entered,
                                            px_asset_fin_rec_new.date_placed_in_service) <= px_asset_fin_rec_new.date_placed_in_service
--
-- Bug3421263: Added following select to takes care retirement
--             prorate date as retirement trx date.
--
    union all
    select th.transaction_header_id transaction_header_id,
           th.transaction_type_code transaction_type_code,
           decode(sign(con.prorate_date - cptrx.start_date),
                       1, decode(sign(con.prorate_date - cptrx.end_date),
                          -1, ret.date_retired,
                          0, ret.date_retired,
                          con.prorate_date),
                       0, decode(sign(con.prorate_date - cptrx.end_date),
                          -1, ret.date_retired,
                          0, ret.date_retired,
                          con.prorate_date),
                       con.prorate_date) transaction_date_entered,
           th.date_effective date_effective,
           th.transaction_name transaction_name,
           th.source_transaction_header_id source_transaction_header_id,
           th.mass_reference_id mass_reference_id,
           th.transaction_subtype transaction_subtype,
           th.transaction_key transaction_key,
           th.amortization_start_date amortization_start_date,
           th.calling_interface calling_interface,
           th.mass_transaction_id mass_transaction_id,
           fa_std_types.FA_NO_OVERRIDE deprn_override_flag,
           th.member_transaction_header_id member_transaction_header_id,
           th.trx_reference_id trx_reference_id,
           th.invoice_transaction_id,
           '2nd SELECT in c_get_ths_adj'
    from   fa_transaction_headers th,
           fa_retirements ret,
           fa_conventions con,
           fa_calendar_periods cp,
           fa_calendar_periods cptrx
    where  th.asset_id = p_asset_hdr_rec.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    ret.asset_id = p_asset_hdr_rec.asset_id
    and    ret.book_type_code = p_asset_hdr_rec.book_type_code
    and    (ret.transaction_header_id_out is null or   -- Bug # 7307047
            ret.transaction_header_id_out = l_incoming_thid)
    and    ret.RETIREMENT_PRORATE_CONVENTION = con.PRORATE_CONVENTION_CODE
    and    ret.date_retired between con.start_date and con.end_date
    and    cp.calendar_type = fa_cache_pkg.fazcbc_record.prorate_calendar
    and    con.prorate_date between cp.start_date and cp.end_date
    and    th.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)
--    and    th.transaction_header_id >= c_transaction_header_id
    and    th.transaction_header_id <> l_incoming_thid
    and    cptrx.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
    and    ret.date_retired between cptrx.start_date and cptrx.end_date
    and    th.transaction_header_id = ret.transaction_header_id_in
--bug4363712
--    and    con.prorate_date >= c_transaction_date_entered
--bug fix 4547599
    and    (   (con.prorate_date > c_transaction_date_entered)
            or
-- Bug 4622110: Modified to handle ret trx date is later than its prorate date.
-- Bug 6740618: changed the decode
-- Bug 6885405: changed the decode
               (decode(c_retirement_flag, 'Y', th.transaction_date_entered, con.prorate_date) <= c_transaction_date_entered and
                th.date_effective >= c_date_effective)
           )
--
--
    union all select
           l_incoming_thid transaction_header_id,
           p_trans_rec.transaction_type_code transaction_type_code,
           nvl(p_trans_rec.amortization_start_date,
               p_trans_rec.transaction_date_entered) transaction_date_entered,
           p_trans_rec.who_info.creation_date date_effective,
           p_trans_rec.transaction_name transaction_name,
           p_trans_rec.source_transaction_header_id source_transaction_header_id,
           p_trans_rec.mass_reference_id mass_reference_id,
           p_trans_rec.transaction_subtype transaction_subtype,
           p_trans_rec.transaction_key transaction_key,
           p_trans_rec.amortization_start_date amortization_start_date,
           p_trans_rec.calling_interface calling_interface,
           p_trans_rec.mass_transaction_id mass_transaction_id,
           p_trans_rec.deprn_override_flag deprn_override_flag,
           p_trans_rec.member_transaction_header_id member_transaction_header_id,
           p_trans_rec.trx_reference_id trx_reference_id,
           to_number(null), -- invoice_transaction_id
           '3rd SELECT in c_get_ths_adj'
    from   fa_books bk
    where  bk.asset_id = p_asset_hdr_rec.asset_id
    and    bk.book_type_code = p_asset_hdr_rec.book_type_code
    and    bk.transaction_header_id_out is null
    and    p_trans_rec.transaction_type_code
                                       not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                               G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                               G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                               G_TRX_TYPE_TFR_VOID, G_TRX_TYPE_REI)
    order by transaction_date_entered, 4; -- 4 is date_effective


  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- This cursor fetchs next transaction information.
  -- Since main cursor to get transactions only fetchs 100 records at once,
  -- this is necessary to fetch 101th record if tehre is any.
  -- This is similar to main cursor.  Second union fetchs entered transaction
  -- which has not yet sotred in db.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_next_ths (c_transaction_date_entered date,
                         c_date_effective           date) IS
    select th.transaction_date_entered transaction_date_entered,
           th.date_effective date_effective
    from   fa_transaction_headers th
    where  th.asset_id = p_asset_hdr_rec.asset_id
    and    th.book_type_code = p_asset_hdr_rec.book_type_code
    and    th.transaction_date_entered >= c_transaction_date_entered
    and    th.date_effective > c_date_effective
    and    (p_asset_type_rec.asset_type <> G_ASSET_TYPE_GROUP or
            not exists (select 'Y'
                        from fa_transaction_headers mth,
                             fa_books bk
                        where mth.transaction_header_id = th.member_transaction_header_id
                        and   mth.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.asset_id = mth.asset_id
                        and   bk.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.transaction_header_id_out is null
                        and   ((bk.asset_id <> nvl(p_reclassed_asset_id, 0) and
                                bk.group_asset_id is null) or
                               bk.group_asset_id <> p_asset_hdr_rec.asset_id)
                         )
            )
    union all select
           p_trans_rec.transaction_date_entered transaction_date_entered,
           p_trans_rec.who_info.creation_date date_effective
    from   dual
    where  p_reclass_src_dest is null
    and    p_trans_rec.transaction_date_entered >= c_transaction_date_entered
    and    p_trans_rec.who_info.creation_date = c_date_effective
    and    (p_asset_type_rec.asset_type <> G_ASSET_TYPE_GROUP or
            not exists (select 'Y'
                        from fa_transaction_headers mth,
                             fa_books bk
                        where mth.transaction_header_id = p_trans_rec.member_transaction_header_id
                        and   mth.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.asset_id = mth.asset_id
                        and   bk.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.transaction_header_id_out is null
                        and   ((bk.asset_id <> nvl(p_reclassed_asset_id, 0) and
                                bk.group_asset_id is null) or
                               bk.group_asset_id <> p_asset_hdr_rec.asset_id)
                         )
            )
    order by transaction_date_entered, date_effective;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- This cursor gets retirement information for given transaction_header_id
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_retirement (c_transaction_header_id number) IS
    select retirement_id,
           cost_retired,
           cost_of_removal,
           proceeds_of_sale,
           nvl(reserve_retired, 0),
           nvl(eofy_reserve, 0),
           reval_reserve_retired,
           unrevalued_cost_retired,
           bonus_reserve_retired,
           impair_reserve_retired,
           null --         recognize_gain_loss
    from   fa_retirements
    where  transaction_header_id_in = c_transaction_header_id
    and    transaction_header_id_out is null ;
    -- 7130809 pulled out the below code line as this is creating
    -- regression for adjusted cost in fa_books. This line was
    -- added for the Bug# 6341966
    /*or transaction_header_id_out = p_trans_rec.transaction_header_id; */
    -- Bug#6341966,Added condition to pick the reinstated retirement on asset.

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC
  -- This cursor gets retirement information for given transaction_header_id
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_retirement (c_transaction_header_id number) IS
    select retirement_id,
           cost_retired,
           cost_of_removal,
           proceeds_of_sale,
           nvl(reserve_retired, 0),
           nvl(eofy_reserve, 0),
           reval_reserve_retired,
           unrevalued_cost_retired,
           bonus_reserve_retired,
           impair_reserve_retired,
           null --         recognize_gain_loss
    from   fa_mc_retirements
    where  transaction_header_id_in = c_transaction_header_id
    and    transaction_header_id_out is null
    and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- gets reserve retired amounts if FA_RETIREMENTS doesn't store it
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_rsv_retired (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'CR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_adjustments
    where  source_type_code = 'RETIREMENT'
    and    adjustment_type = 'RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC
  -- gets reserve retired amounts if FA_RETIREMENTS doesn't store it
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_rsv_retired (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'CR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_mc_adjustments
    where  source_type_code = 'RETIREMENT'
    and    adjustment_type = 'RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id
    and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- gets reval reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_reval_rsv (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_adjustments
    where  source_type_code = 'REVALUATION'
    and    adjustment_type = 'RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC:  gets reval reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_reval_rsv (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_mc_adjustments
    where  source_type_code = 'REVALUATION'
    and    adjustment_type = 'RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id
    and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- gets reval reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_bonus_reval_rsv (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_adjustments
    where  source_type_code = 'REVALUATION'
    and    adjustment_type = 'BONUS RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC:  gets reval reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_bonus_reval_rsv (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_mc_adjustments
    where  source_type_code = 'REVALUATION'
    and    adjustment_type = 'BONUS RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id
    and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
/*
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- gets reval reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_impair_reval_rsv (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_adjustments
    where  source_type_code = 'REVALUATION'
    and    adjustment_type = 'IMPAIR RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC:  gets reval reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_impair_reval_rsv (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_mc_adjustments
    where  source_type_code = 'REVALUATION'
    and    adjustment_type = 'IMPAIR RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id
    and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
*/
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- gets (reval) impairment reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_impair_rsv (c_transaction_header_id number,
                           c_source_type_code varchar2) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_adjustments
    where  source_type_code = c_source_type_code
    and    adjustment_type = 'IMPAIR RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC:  gets (reval) impairment reserve amount
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_impair_rsv (c_transaction_header_id number,
                              c_source_type_code varchar2) IS
    select sum(decode(debit_credit_flag, 'DR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_mc_adjustments
    where  source_type_code = c_source_type_code
    and    adjustment_type = 'IMPAIR RESERVE'
    and    asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = c_transaction_header_id
    and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- This cursor gets group asset's transaction_header_id which was
  -- created for member addition.  The reason why is because Recalculation
  -- needs to start before this transaction in case reclass is backdated
  -- to member's dpis.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_init_thid IS
    select gth.transaction_header_id
    from   fa_transaction_headers gth
    where  gth.asset_id = p_asset_hdr_rec.asset_id
    and    gth.book_type_code = p_asset_hdr_rec.book_type_code
    and    gth.member_transaction_header_id =
                (select min(mth.transaction_header_id)
                 from   fa_transaction_headers mth
                 where  mth.asset_id = p_reclassed_asset_id
                 and    mth.book_type_code = p_asset_hdr_rec.book_type_code);

   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- This cursor returns latest transaction of group
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   CURSOR c_get_group_trx IS
     select th.transaction_header_id    transaction_header_id,
            nvl(th.amortization_start_date,
                th.transaction_date_entered) transaction_date_entered,
            th.date_effective date_effective,
            th.transaction_type_code transaction_type_code
     from   fa_transaction_headers th
     where  asset_id = p_asset_hdr_rec.asset_id
     and    book_type_code = p_asset_hdr_rec.book_type_code
     and    not exists (select 'Y'
                        from fa_transaction_headers mth,
                             fa_books bk
                        where mth.transaction_header_id = th.member_transaction_header_id
                        and   mth.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.asset_id = mth.asset_id
                        and   bk.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.transaction_header_id_out is null
                        and   ((bk.asset_id <> nvl(p_reclassed_asset_id, 0) and
                                bk.group_asset_id is null) or
                               bk.group_asset_id <> p_asset_hdr_rec.asset_id)
                         )
     union all
     select p_trans_rec.transaction_header_id    transaction_header_id,
            nvl(p_trans_rec.amortization_start_date,
                p_trans_rec.transaction_date_entered) transaction_date_entered,
            p_trans_rec.who_info.creation_date date_effective,
            p_trans_rec.transaction_type_code transaction_type_code
     from   dual
     where  not exists (select 'Y'
                        from fa_transaction_headers mth,
                             fa_books bk
                        where mth.transaction_header_id = p_trans_rec.member_transaction_header_id
                        and   mth.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.asset_id = mth.asset_id
                        and   bk.book_type_code = p_asset_hdr_rec.book_type_code
                        and   bk.transaction_header_id_out is null
                        and   ((bk.asset_id <> nvl(p_reclassed_asset_id, 0) and
                                bk.group_asset_id is null) or
                               bk.group_asset_id <> p_asset_hdr_rec.asset_id)
                         )
     order by transaction_header_id desc;

   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- This cursor returns maximum group transaction header id which is
   -- not a group transaction of non-member asset before give transaction
   -- header id to get correct initial books row.
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   CURSOR c_get_init_trx2 (c_transaction_header_id number) IS
     select outgth.transaction_header_id
     from   fa_transaction_headers outgth,
            fa_transaction_headers ingth,
            fa_books gbk
     where  outgth.asset_id = p_asset_hdr_rec.asset_id
     and    outgth.book_type_code = p_asset_hdr_rec.book_type_code
     and    outgth.transaction_header_id <= c_transaction_header_id
     and    ingth.asset_id = p_asset_hdr_rec.asset_id
     and    ingth.book_type_code = p_asset_hdr_rec.book_type_code
     and    gbk.transaction_header_id_out = outgth.transaction_header_id
     and    gbk.transaction_header_id_in = ingth.transaction_header_id
     and    not exists (select 1
                        from   fa_transaction_headers mth,
                               fa_books bk
                        where  mth.transaction_header_id = ingth.member_transaction_header_id
                        and    mth.asset_id = bk.asset_id
                        and    bk.book_type_code = p_asset_hdr_rec.book_type_code
                        and    bk.transaction_header_id_out is null
                        and    (bk.asset_id <> p_reclassed_asset_id
                           and  nvl(bk.group_asset_id, 0) <> p_asset_hdr_rec.asset_id))
     order by outgth.transaction_header_id desc;

-- bug 4428646, modified from 'B' to 'BOOKS'.
  CURSOR c_get_brow IS
     select ytd_deprn, deprn_reserve
     from   fa_deprn_summary
     where  asset_id = p_asset_hdr_rec.asset_id
     and    book_type_code = p_asset_hdr_rec.book_type_code
     and    deprn_source_code = 'BOOKS';

  CURSOR c_get_mc_brow IS
     select ytd_deprn, deprn_reserve
     from   fa_mc_deprn_summary
     where  asset_id = p_asset_hdr_rec.asset_id
     and    book_type_code = p_asset_hdr_rec.book_type_code
     and    deprn_source_code = 'BOOKS'
     and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

  -- code fix for bug no.4016503
  -- Get previous trx with given thid
  --Added conditions to where clause for bug 4168841
  -- Bug 5654286 Excluded ADDITION/VOID transaction
  CURSOR c_get_prev_trx (c_thid number) IS
    select th.transaction_header_id
         , th.transaction_date_entered
         , th.date_effective
         , th.transaction_type_code
    from   fa_transaction_headers th
         ,  fa_books bk
    where bk.transaction_header_id_out <  c_thid
    and   bk.book_type_code = p_asset_hdr_rec.book_type_code
    and   th.book_type_code = p_asset_hdr_rec.book_type_code
    and   th.asset_id = p_asset_hdr_rec.asset_id
    and   bk.asset_id = p_asset_hdr_rec.asset_id
    and   bk.transaction_header_id_in = th.transaction_header_id
    and    th.transaction_type_code not in (G_TRX_TYPE_TFR_OUT, G_TRX_TYPE_TFR_IN,
                                            G_TRX_TYPE_TFR, G_TRX_TYPE_TFR_VOID,
                                            G_TRX_TYPE_REC, G_TRX_TYPE_UNIT_ADJ,
                                            G_TRX_TYPE_TFR_VOID ,G_TRX_TYPE_REI,
                                            G_TRX_TYPE_ADD_VOID)
    order by transaction_header_id desc;

   -- Bug6190904: Need following cursor to store prorate period info
   -- to find out whether adjustment date (amortized) may need the info
   -- if the date falls in the prorate period and impact the catch-up.
   CURSOR c_get_prorate_date (c_date_placed_in_service date
                            , c_prorate_convention_code varchar2) is
   select prorate_date, start_date, end_date
   from   fa_conventions
   where  prorate_convention_code = c_prorate_convention_code
   and    c_date_placed_in_service between start_date and end_date;

   -- Bug6190904: Used with above cursor.
   l_prorate_date   date;
   l_start_date     date;
   l_end_date       date;

   -- Bug 8211842 : Get the prorated retirement date
   -- for a reinstatement transaction
   CURSOR c_get_retirement_pdate IS
   select con.prorate_date
   from   fa_conventions con,
          fa_retirements ret
   where  ret.transaction_header_id_out = p_trans_rec.transaction_header_id
   and    ret.book_type_code = p_asset_hdr_rec.book_type_code
   and    ret.asset_id = p_asset_hdr_rec.asset_id
   and    ret.retirement_prorate_convention = con.prorate_convention_code
   and    ret.date_retired between con.start_date and con.end_date;

   l_override_limit_date date;
   l_override_limit_period_rec FA_API_TYPES.period_rec_type;

  --++++++++++++++++++ Table types ++++++++++++++++++
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char1_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE tab_char150_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

  -- table to store returned values from c_check_overlap2
  t_co_thid                      tab_num15_type;
  t_co_date_effective            tab_date_type;
  t_co_trx_date                  tab_date_type;
  t_co_trx_type_code             tab_char30_type;


  --+++ Table variables to for main transaction cursor +++
  t_transaction_header_id        tab_num15_type;
  t_transaction_type_code        tab_char30_type;
  t_transaction_date_entered     tab_date_type;
  t_date_effective               tab_date_type;
  t_transaction_name             tab_char30_type;
  t_source_transaction_header_id tab_num15_type;
  t_mass_reference_id            tab_num15_type;
  t_transaction_subtype          tab_char30_type;
  t_transaction_key              tab_char30_type;
  t_amortization_start_date      tab_date_type;
  t_calling_interface            tab_char30_type;
  t_mass_transaction_id          tab_num15_type;
  t_deprn_override_flag          tab_char1_type;
  t_member_transaction_header_id tab_num15_type;
  t_trx_reference_id             tab_num15_type;
  t_invoice_transaction_id       tab_num15_type;
  t_which_select                 tab_char30_type;


  l_row_count                    NUMBER := 0;

  --+++++ Store data related to each transactions +++++
  l_trans_rec                    FA_API_TYPES.trans_rec_type;
  l_invoice_transaction_id       NUMBER;
  l_period_rec                   FA_API_TYPES.period_rec_type;
  l_asset_deprn_rec              FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_raf          FA_API_TYPES.asset_deprn_rec_type;
  l_asset_fin_rec_old            FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_adj            FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new            FA_API_TYPES.asset_fin_rec_type;
  l_asset_retire_rec             FA_API_TYPES.asset_retire_rec_type;

  l_least_thid                   number(15); -- Stored least transaction_header_id
                                             -- to find starting fa_books record
  l_member_asset_id              number(15) := to_number(null); -- Store member asset id
  l_member_trx_key               varchar2(2); -- member transaction key
  l_member_hdr_rec               FA_API_TYPES.asset_hdr_rec_type;
  l_next_period_rec              FA_API_TYPES.period_rec_type;
  l_transaction_type_code        varchar2(30); -- Used to find reinstatement

  l_temp_period_counter          number(15); -- This is to store period counter because GetDeprnRec needs
                                             -- period counter = period_counter - 1

  l_use_new_deprn_rule           BOOLEAN := FALSE; -- True: if it needs to inherit passed
                                                   -- asset_fin_rec values except amounts.
  l_use_fin_rec_adj              BOOLEAN := FALSE; -- True: if it is processing passed transaction

  l_limit               CONSTANT BINARY_INTEGER := 1800; -- main transaction_cursor limit constant;

  --+++++++++++++++ For calling faxcde +++++++++++++++
  l_dpr_in                       FA_STD_TYPES.dpr_struct;
  l_dpr_out                      FA_STD_TYPES.dpr_out_struct;
  l_dpr_arr                      FA_STD_TYPES.dpr_arr_type;
  l_running_mode                 NUMBER;

  --++++++++++ For storing retirement values ++++++++++
  l_retirement_id                NUMBER(15);
  l_cost_of_removal              NUMBER;
  l_proceeds_of_sales            NUMBER;
  l_reserve_retired              NUMBER;
  l_eofy_reserve_retired         NUMBER;
  l_reval_reserve_retired        NUMBER;
  l_unrevalued_cost_retired      NUMBER;
  l_bonus_reserve_retired        NUMBER;
  l_impair_reserve_retired       NUMBER;
  l_recognize_gain_loss          VARCHAR2(30);
  l_cost_retired                 NUMBER;

  --++++++++++ For storing revaluation values ++++++++++
  l_reval_reserve                NUMBER;
  l_reval_bonus_reserve          NUMBER;
  l_reval_impair_reserve         NUMBER;

  l_impair_reserve               NUMBER;

  l_process_this_trx             BOOLEAN := TRUE; -- False: if this transaction is retirement and
                                                  --        reinstatement exists for this retirement.
                                                  --        If this is false, it won't process this transaction.

  --
  -- These are used to store return values from faxcde which
  -- may not be used.
  --
  l_out_deprn_exp                NUMBER;
  l_out_reval_exp                NUMBER;
  l_out_reval_amo                NUMBER;
  l_out_prod                     NUMBER;
  l_out_ann_adj_exp              NUMBER;
  l_out_ann_adj_reval_exp        NUMBER;
  l_out_ann_adj_reval_amo        NUMBER;
  l_out_bonus_rate_used          NUMBER;
  l_out_full_rsv_flag            BOOLEAN;
  l_out_life_comp_flag           BOOLEAN;
  l_out_deprn_override_flag      VARCHAR2(1);

  --+++++++ variables for cursor c_get_next_ths +++++++
  l_next_trx_period_counter      NUMBER(15);
  l_next_trx_fiscal_year         NUMBER(15);
  l_next_trx_period_num          NUMBER(15);
  l_next_trx_trx_date_entered    DATE;
  l_next_trx_date_effective      DATE;

  --+++++++ variables for cursor c_get_init_thid ++++++
  l_member_init_thid             NUMBER;

  --+++++++ variables FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP +++++++
  l_eofy_rec_cost                NUMBER;
  l_eofy_sal_val                 NUMBER;
  l_eop_rec_cost                 NUMBER;
  l_eop_sal_val                  NUMBER;

  l_eofy_fy                      NUMBER; -- Fiscal year which is used to get
                                         -- end of fiscal year recoverable cost and
                                         -- salvage value

  l_period_counter               NUMBER(15);

  --++++++++ variables for calling GetEofyReserve ++++++++
  l_eofy_thid                    NUMBER(15);
  l_eofy_trx_date_entered        DATE;
  l_eofy_date_effective          DATE;
  l_eofy_reserve                 NUMBER;
  l_eofy_trx_type_code           VARCHAR2(30);

  --++++++++ variables for cursor c_get_deprn_period_date +++++++
  l_calendar_period_start_date   date;
  --++++++++ variables for manual override ++++++++
  l_rate_source_rule             VARCHAR2(25);
  l_deprn_basis_rule             VARCHAR2(25);

  --++++++++ variables for cursor c_get_reclass_reserve +++++++++
  l_src_asset_id                 NUMBER(15);
  l_dest_asset_id                NUMBER(15);
  l_reclassed_reserve            NUMBER;
  l_reclass_src_dest             VARCHAR2(12);

  --++++++++ Other Variables +++++++
  l_calc_deprn_flag              BOOLEAN := FALSE;
  l_temp_adjusted_cost           NUMBER;
  l_reserve_adj                  NUMBER;

  --+++++++++++++++++ Exceptions ++++++++++++++++++++++
  invalid_trx_to_overlap         EXCEPTION;
  calc_failed                    EXCEPTION;
  l_check_overlap_found          BOOLEAN := FALSE;

  l_temp_cnt binary_integer := 0;

  --bug3548724
  l_is_this_void                 BOOLEAN := FALSE;
  l_adj_processed                BOOLEAN := FALSE;
  l_add_processed                BOOLEAN := FALSE;
  l_add_void_exist               BOOLEAN := FALSE;
  l_add_exist                    BOOLEAN := FALSE;

  --Bug3724207
  l_dpis_change                  BOOLEAN := FALSE;
  l_dbr_event_type               VARCHAR2(30);
  l_brow_ytd_deprn               NUMBER;
  l_brow_deprn_reserve           NUMBER;

  l_energy_member                BOOLEAN := FALSE;  -- ENERGY
  l_retirement_flag              VARCHAR2(1) := 'N'; --Bug4622110

  l_impair_adj_cost              NUMBER;
  l_impair_raf                   NUMBER;
  l_impair_formula_factor        NUMBER;
  l_unplanned_exp                NUMBER;
  l_start_from_first             BOOLEAN := TRUE;

  -- Bug PKO
  l_retirement_thid              NUMBER := -1;
  l_catchup_begin_deprn_rec      FA_API_TYPES.asset_deprn_rec_type;
  l_temp_reserve                 NUMBER;

  l_cost_frac                    NUMBER;  -- Bug 5893429

  l_old_pc_reserved              NUMBER;  -- Japan Bug 6645061
  l_new_pc_reserved              NUMBER;  -- Japan Bug 6645061
  l_check_tax_overlap            NUMBER;  -- 9003531

  --Bug6755649
  l_cur_adj_cost                NUMBER := 0;
  l_old_cost_frac               NUMBER;

  l_start_extended              VARCHAR2(1) := 'N'; -- Bug 8211842
  l_get_eofy_thid               NUMBER; -- Bug 8537330

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_type_rec.asset_type||
                                              ':'||p_asset_hdr_rec.asset_id , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Reclass values', p_reclass_src_dest||
                                                       ':'||to_char(p_reclassed_asset_id)||':'||
                                                       to_char(p_reclassed_asset_dpis, 'DD-MON-RR'));
   end if;

   l_asset_deprn_rec := p_asset_deprn_rec;
   l_asset_fin_rec_adj := p_asset_fin_rec_adj;

   l_incoming_thid                       := nvl(p_trans_rec.transaction_header_id, 999999999999);
   l_trans_rec.transaction_type_code     := p_trans_rec.transaction_type_code;
   l_trans_rec.transaction_header_id     :=  l_incoming_thid;
   l_trans_rec.transaction_date_entered  := nvl(p_trans_rec.amortization_start_date,
                                               p_trans_rec.transaction_date_entered);
   l_trans_rec.who_info.last_update_date := nvl(p_trans_rec.who_info.last_update_date, sysdate);

   if ((px_asset_fin_rec_new.group_asset_id is null) and
       (p_asset_fin_rec_old.group_asset_id is not null)) or
      ((px_asset_fin_rec_new.group_asset_id is not null) and
       (p_asset_fin_rec_old.group_asset_id is null)) and
      (p_asset_type_rec.asset_type = 'CAPITALIZED') then
      l_calc_deprn_flag := TRUE;
   end if;

   /* Bug 6281311 fetching it here */
   OPEN c_get_deprn_period_date;
   FETCH c_get_deprn_period_date INTO l_calendar_period_start_date, l_entered_ytd, l_entered_reserve;
   CLOSE c_get_deprn_period_date;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 0.9 ==========','', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_calendar_period_start_date', l_calendar_period_start_date, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_entered_ytd', l_entered_ytd, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_entered_reserve', l_entered_reserve, p_log_level_rec => p_log_level_rec);
   end if;
   /* Bug 6281311 fetching it here */

   --
   -- Bug3696765:
   -- Due to necessity of using user entered reserve occasionally (only if user backdated
   -- to 1st peirod of fiscal, this check is necessary and the return value will be
   -- used in check_overlap cursor and main cursor.
   --
   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 1.0 ==========','', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ p_trans_rec.transaction_header_id', p_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_incoming_thid', l_incoming_thid, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ p_trans_rec.transaction_type_code', p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ p_trans_rec.transaction_date_entered', p_trans_rec.transaction_date_entered, p_log_level_rec => p_log_level_rec);
   end if;

   if (p_trans_rec.transaction_type_code not like '%ADDITION') and
      (p_trans_rec.amortization_start_date is not null) then
      if not GetPeriodInfo(to_number(to_char(p_trans_rec.amortization_start_date, 'J')),
                           p_asset_hdr_rec.book_type_code,
                           p_mrc_sob_type_code,
                           p_asset_hdr_rec.set_of_books_id,
                           l_period_rec,
                           p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;
      end if;

      /* Bug 6281311 Reset l_process_addition only if the asset
         was added with reserve */
      if l_period_rec.period_num = 1 and l_entered_reserve <> 0 then
         l_process_addition := 0;
      else
         l_process_addition := 1;
      end if;
      fa_debug_pkg.add(l_calling_fn, 'l_process_addition: After changing', l_process_addition, p_log_level_rec => p_log_level_rec);
   end if;

-- Bug 5726160
   if p_running_mode = fa_std_types.FA_DPR_CATCHUP then

      if p_trans_rec.transaction_type_code = 'REINSTATEMENT' then

        begin
          select transaction_header_id_in
          into l_retirement_thid -- retirement thid
          from fa_retirements
          where asset_id = p_asset_hdr_rec.asset_id
            and book_type_code = p_asset_hdr_rec.book_type_code
            and transaction_header_id_out = l_incoming_thid;
        exception when others then null;
        end;

      end if;

   end if;

   -- Bug 8211842 : Get the user provided transaction date
   -- In case of reinstatement it is the retirement prorate date
   l_override_limit_date := p_trans_rec.transaction_date_entered;
   if p_trans_rec.transaction_type_code = 'REINSTATEMENT' then
      OPEN c_get_retirement_pdate;
      FETCH c_get_retirement_pdate
      INTO l_override_limit_date;
      if c_get_retirement_pdate%notfound then
         fa_debug_pkg.add(l_calling_fn, 'Error Fetching cursor',
                          'c_get_retirement_pdate');
         raise calc_failed;
      end if;
      CLOSE c_get_retirement_pdate;
   end if;

   -- Get the Period corresponding to l_override_limit_date
   if not GetPeriodInfo(to_number(to_char(l_override_limit_date, 'J')),
                        p_asset_hdr_rec.book_type_code,
                        p_mrc_sob_type_code,
                        p_asset_hdr_rec.set_of_books_id,
                        l_override_limit_period_rec,
                        p_log_level_rec) then
         fa_debug_pkg.add(l_calling_fn, 'Error calling',
                          'GetPeriodInfo');
      raise calc_failed;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Checking overlapped trxs',
                       p_asset_type_rec.asset_type||':'||p_asset_hdr_rec.asset_id , p_log_level_rec => p_log_level_rec);
   end if;

   /* Bug 6281311 moving this code to above
   OPEN c_get_deprn_period_date;
   FETCH c_get_deprn_period_date INTO l_calendar_period_start_date, l_entered_ytd, l_entered_reserve;
   CLOSE c_get_deprn_period_date;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 1.9 ==========','', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_calendar_period_start_date', l_calendar_period_start_date, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_entered_ytd', l_entered_ytd, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, '++ l_entered_reserve', l_entered_reserve, p_log_level_rec => p_log_level_rec);
   end if; */


   LOOP

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 2.0 ==========','', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, '++ IN 1st LOOP: l_trans_rec.transaction_header_id', l_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.transaction_date_entered', to_char(l_trans_rec.transaction_date_entered, 'MM/DD/YYYY'));
         fa_debug_pkg.add(l_calling_fn, '++ Period of Addition: l_calendar_period_start_date', to_char(l_calendar_period_start_date,'MM/DD/YYYY'));

         fa_debug_pkg.add(l_calling_fn, 'l_process_addition', l_process_addition, p_log_level_rec => p_log_level_rec);
      end if;

      -- fyi: l_calendar_period_start_date: The start date of the period in which the asset was added: Period of addition

      if (l_calendar_period_start_date >l_trans_rec.transaction_date_entered) then
         --
         -- There is a case that we don't want to recalculate from addition if entered trx
         -- is back dated to first period of fy and user provided ytd and deprn reserve at the time
         -- of addition
         --
         if l_process_addition = 0 then
            --
            -- If entered trx is back dated to period 1 then look for a trx prevent recalculation
            -- from the period 1 such as other trx back dated beyond the period.
            -- if there is no such trx exists then we can recalculate from the period 1 using
            -- user entered ytd and deprn reserve at the time of addition. so skip c_check_overlap
            --
--toru
            OPEN c_check_overlap2;
            FETCH c_check_overlap2 BULK COLLECT INTO t_co_thid,
                                                     t_co_date_effective,
                                                     t_co_trx_date,
                                                     t_co_trx_type_code;

            CLOSE c_check_overlap2;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 't_co_thid.count', t_co_thid.count, p_log_level_rec => p_log_level_rec);
            end if;

            l_start_from_first := FALSE;

            for i in 1..t_co_thid.count loop
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 't_co_trx_date', t_co_trx_date(i));
               end if;

               if (t_co_trx_date(i) < l_period_rec.calendar_period_open_date) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'l_start_from_first', 'TRUE', p_log_level_rec => p_log_level_rec);
                  end if;
                  l_start_from_first := TRUE;
                  EXIT;
               elsif (t_co_trx_date(i) < nvl(l_trans_rec.transaction_date_entered,
                                             nvl(p_trans_rec.amortization_start_date,
                                                 p_trans_rec.transaction_date_entered))) then
                  l_trans_rec.transaction_header_id := t_co_thid(i);
                  l_trans_rec.transaction_date_entered := t_co_trx_date(i);
                  l_trans_rec.who_info.creation_date := t_co_date_effective(i);
                  l_trans_rec.transaction_type_code := t_co_trx_type_code(i);
               end if;
            end loop;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'End of for loop', 'end', p_log_level_rec => p_log_level_rec);
            end if;

         else
            l_start_from_first := TRUE;
         end if;

         if (l_start_from_first) then
            OPEN c_get_first_trx;
            FETCH c_get_first_trx INTO l_trans_rec.transaction_header_id,
                                       l_trans_rec.transaction_date_entered,
                                       l_trans_rec.who_info.creation_date,
                                       l_trans_rec.transaction_type_code;
            CLOSE c_get_first_trx;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 2.1 : FROM c_get_first_trx cursor ==========','', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, '++ TRX_DATE_ENTERED is prior to Period of Addition, EXIT AND GO TO ADDITION ','', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, '++ NEW FIRST TRX: l_trans_rec.transaction_header_id', l_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, '++                l_trans_rec.transaction_date_entered', to_char(l_trans_rec.transaction_date_entered,'MM/DD/YYYY'));
              fa_debug_pkg.add(l_calling_fn, '++                l_trans_rec.who_info.creation_date', to_char(l_trans_rec.who_info.creation_date, 'MM/DD/YYYY HH24:MI:SS'));
            end if;

         end if; -- (l_start_from_first)

         EXIT;

      end if;

      OPEN c_check_overlap(l_trans_rec.transaction_date_entered,
                           l_trans_rec.transaction_header_id,
                           l_trans_rec.who_info.creation_date);
      FETCH c_check_overlap INTO g_temp_number,
                                 g_temp_date1,
                                 g_temp_date2,
                                 g_temp_char30;

--tk_util.debug('transaction_header_id: '||to_char(g_temp_number));
--tk_util.debug('creation_date: '||to_char(g_temp_date2, 'DD-MON-RR HH24:MI:SS'));
--tk_util.debug('l_trans_rec.transaction_type_code: '||g_temp_char30);

      if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 2.2 : IN c_check_overlap ==========','', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++ INPUT: l_trans_rec.transaction_header_id', l_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++        l_trans_rec.transaction_date_entered', to_char(l_trans_rec.transaction_date_entered,'MM/DD/YYYY'));
           fa_debug_pkg.add(l_calling_fn, '++        l_trans_rec.who_info.creation_date', to_char(l_trans_rec.who_info.creation_date,'MM/DD/YYYY HH24:MI:SS'));
           fa_debug_pkg.add(l_calling_fn, '++ OUTPUT: g_temp_number: THID', g_temp_number, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++         g_temp_date1: Trx Date', g_temp_date1, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++         g_temp_date2: Effective_Date', g_temp_date2, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++         g_temp_char30: Trx Type Code', g_temp_char30, p_log_level_rec => p_log_level_rec);
      end if;

      -- Bug#4049799: Replaced this with the following: l_check_overlap_found := c_check_overlap%FOUND; */
      if c_check_overlap%NOTFOUND then
        l_check_overlap_found := FALSE;
      else
        l_check_overlap_found := TRUE;
      end if;

      CLOSE c_check_overlap;

      if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.0 ==========','', p_log_level_rec => p_log_level_rec);
           if (l_check_overlap_found) then
             fa_debug_pkg.add(l_calling_fn, '++ l_check_overlap_found', 'TRUE', p_log_level_rec => p_log_level_rec);
           else
             fa_debug_pkg.add(l_calling_fn, '++ l_check_overlap_found', 'FALSE', p_log_level_rec => p_log_level_rec);
           end if;
      end if;

      if (l_check_overlap_found) then

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.1 ==========','', p_log_level_rec => p_log_level_rec);
         end if;

         l_trans_rec.transaction_header_id := g_temp_number;
         l_trans_rec.transaction_date_entered := g_temp_date1;
         l_trans_rec.who_info.creation_date := g_temp_date2;
         l_trans_rec.transaction_type_code := g_temp_char30;

         --
         -- Bug3696765:
         -- Due to necessity of using user entered reserve occasionally (only if user backdated
         -- to 1st peirod of fiscal, this check is necessary and the return value will be
         -- used in check_overlap cursor and main cursor.
         --
         if (l_trans_rec.transaction_type_code not like '%ADDITION') then
            if not GetPeriodInfo(to_number(to_char(l_trans_rec.transaction_date_entered, 'J')),
                                 p_asset_hdr_rec.book_type_code,
                                 p_mrc_sob_type_code,
                                 p_asset_hdr_rec.set_of_books_id,
                                 l_period_rec,
                                 p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            -- Bug 5443855 if l_period_rec.period_num = 1 then
            if l_period_rec.period_num = 1 or l_entered_reserve <> 0 then
               l_process_addition := 0;
            else
               l_process_addition := 1;
            end if;
         end if;

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.2 WHEN l_check_overlap FOUND ==========','', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++ l_process_addition', l_process_addition, p_log_level_rec => p_log_level_rec);
         end if;

      else

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.2 WHEN l_check_overlap NOT FOUND  ==========','', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++ l_process_addition', l_process_addition, p_log_level_rec => p_log_level_rec);
         end if;

         --
         -- If the member asset is currently a member or will be a member
         -- do not call GetEofyReserve since it could require to go back
         -- to addition to recalcualte without letting user know which is not
         -- good especially if this asset has added with reserve which will be
         -- wiped out during recalculation.
         --
         if ((p_asset_fin_rec_old.group_asset_id is null and
              px_asset_fin_rec_new.group_asset_id is null)) or
              (l_trans_rec.transaction_type_code like '%RETIREMENT') then    -- ENERGY

            if (fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag = 'Y') then

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.2.1 ==========','', p_log_level_rec => p_log_level_rec);
               end if;

               if not GetEofyReserve(
                         p_trans_rec                => l_trans_rec,
                         p_trans_rec_cur            => p_trans_rec,
                         p_asset_hdr_rec            => p_asset_hdr_rec,
                         p_asset_type_rec           => p_asset_type_rec,
                         p_period_rec               => p_period_rec,
                         x_eofy_reserve             => l_eofy_reserve,
                         x_transaction_header_id    => l_eofy_thid,
                         x_transaction_date_entered => l_eofy_trx_date_entered,
                         x_date_effective           => l_eofy_date_effective,
                         x_transaction_type_code    => l_eofy_trx_type_code,
                         p_mrc_sob_type_code        => p_mrc_sob_type_code,
                         p_calling_fn               => l_calling_fn,
                    p_log_level_rec       => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'GetEofyReserve', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;

               end if;
               -- Bug 8537330: Save the transaction for which GetEofyReserve was called.
               l_get_eofy_thid := l_trans_rec.transaction_header_id;
            end if;

            if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.3 ==========','', p_log_level_rec => p_log_level_rec);
            end if;


            if (nvl(fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag, 'N') = 'N') or
               (l_eofy_reserve is not null) then
              --adding the following code for bug no.4016503
              --the retirement transaction is ignored during recalculate
              -- if it is reinstated by any following transaction.

                if (l_trans_rec.transaction_type_code like '%RETIREMENT') then

                  l_retirement_id           := null;
                  l_cost_retired            := null;
                  l_cost_of_removal         := null;
                  l_proceeds_of_sales       := null;
                  l_reserve_retired         := null;
                  l_eofy_reserve_retired    := null;
                  l_reval_reserve_retired   := null;
                  l_unrevalued_cost_retired := null;
                  l_bonus_reserve_retired   := null;
                  l_impair_reserve_retired  := null;
                  l_recognize_gain_loss     := null;

                  if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.3.1 ==========','', p_log_level_rec => p_log_level_rec);
                  end if;

                  OPEN c_get_retirement(l_trans_rec.transaction_header_id);
                  FETCH c_get_retirement INTO l_retirement_id,
                                              l_cost_retired,
                                              l_cost_of_removal,
                                              l_proceeds_of_sales,
                                              l_reserve_retired,
                                              l_eofy_reserve_retired,
                                              l_reval_reserve_retired,
                                              l_unrevalued_cost_retired,
                                              l_bonus_reserve_retired,
                                              l_impair_reserve_retired,
                                              l_recognize_gain_loss;

                  if c_get_retirement%NOTFOUND then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Check Overlap', 'Search previous trx', p_log_level_rec => p_log_level_rec);
                     end if;

                     CLOSE c_get_retirement;

                     if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.3.2 ==========','', p_log_level_rec => p_log_level_rec);
                     end if;

                     --find a trx before this retirement
                     OPEN c_get_prev_trx (l_trans_rec.transaction_header_id);
                     FETCH c_get_prev_trx INTO l_trans_rec.transaction_header_id
                                             , l_trans_rec.transaction_date_entered
                                             , l_trans_rec.who_info.creation_date
                                             , l_trans_rec.transaction_type_code;
                     /*Added for bug 4168841*/
                     if c_get_prev_trx%NOTFOUND then
                        CLOSE c_get_prev_trx;
                        exit;
                     end if;

                     if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.3.2.1 ==========','', p_log_level_rec => p_log_level_rec);
                     end if;

                     CLOSE c_get_prev_trx;
                  else
                     -- This retirement has not reinstated yet so ok to proceed
                     CLOSE c_get_retirement;

                     if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.3.3 ==========','', p_log_level_rec => p_log_level_rec);
                     end if;

                     exit;
                  end if; -- c_get_retirement%NOTFOUND
               else
                  if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.3.9 ==========','', p_log_level_rec => p_log_level_rec);
                  end if;

                  exit;
               end if; -- l_trans_rec.transaction_type_code like '%RETIREMENT

            else
               if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.4.1 ==========','', p_log_level_rec => p_log_level_rec);
               end if;

               l_trans_rec.transaction_header_id := l_eofy_thid;
               l_trans_rec.transaction_date_entered := l_eofy_trx_date_entered;
               l_trans_rec.who_info.creation_date := l_eofy_date_effective;
            end if;
         else
            if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 3.5 ==========','', p_log_level_rec => p_log_level_rec);
            end if;

            -- Will find eofy_reserve from old books row.
            exit;
         end if; -- (p_asset_fin_rec_old.group_asset_id is null and
      end if;

      l_period_rec := null;

      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      -- temporary code to prevent infinite loop
      --
      l_temp_cnt := l_temp_cnt + 1;

      if (l_temp_cnt > 200) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ Checking overlapped trxs with ',
                             to_char(l_trans_rec.transaction_date_entered, 'MM/DD/YYYY HH24:MI:SS'));
         end if;

         raise calc_failed;
      end if;
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   END LOOP;


   --Bug4622110
   if l_trans_rec.transaction_type_code like '%RETIREMENT' then
      l_retirement_flag := 'Y';
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 4 : BEFORE LOOP FOR CURSOR c_get_ths_adj ==========','', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ FETCHING TRANSACTIONS AFTER - TRX_DATE : EFF_DATE',
                       to_char(l_trans_rec.transaction_date_entered, 'MM/DD/YYYY') || ' : '||
                       to_char(l_trans_rec.who_info.creation_date, 'MM/DD/YYYY HH24:MI:SS'));
      fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.transaction_date_entered', to_char(l_trans_rec.transaction_date_entered,'MM/DD/YYYY HH24:MI:SS'));
      fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.who_info.creation_date', to_char(l_trans_rec.who_info.creation_date,'MM/DD/YYYY HH24:MI:SS'));
      fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.transaction_header_id', l_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_retirement_flag', l_retirement_flag, p_log_level_rec => p_log_level_rec);
    end if;

    -- Bug 8674466 : Propagating fix of 7699305
    -- Check if there are any future prorate retirements in the period
    -- in which the current retirement is done .. then start from Addition,
    -- instead of the retirement transaction

    -- Bug 8250142 Added the reinstatement and l_process_addition condition
    if ((l_retirement_flag = 'Y') and
        (p_trans_rec.transaction_type_code <> 'REINSTATEMENT') and
        (l_process_addition = 1)) then

       -- Get the prorate period counter for the retirement
       select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
       into l_ret_prorate_pc
       from fa_calendar_periods cp,
            fa_book_controls bc,
            fa_fiscal_year fy,
            fa_calendar_types ct,
            fa_retirements ret,
            fa_conventions con
       WHERE ret.book_type_code = p_asset_hdr_rec.book_type_code
       and   ret.asset_id = p_asset_hdr_rec.asset_id
       and   ret.transaction_header_id_in = l_trans_rec.transaction_header_id
       and   ret.RETIREMENT_PRORATE_CONVENTION = con.PRORATE_CONVENTION_CODE
       and   ret.date_retired between con.start_date and con.end_date
       and   bc.book_type_code = p_asset_hdr_rec.book_type_code
       and   bc.deprn_calendar = ct.calendar_type
       and   bc.fiscal_year_name = fy.fiscal_year_name
       and   ct.fiscal_year_name = bc.fiscal_year_name
       and   ct.calendar_type = cp.calendar_type
       and   cp.start_date between fy.start_date and fy.end_date
       and   con.prorate_date between cp.start_date and cp.end_date;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '========== Recalc Bug 7699305:1 After l_ret_prorate_pc ==========','');
          fa_debug_pkg.add(l_calling_fn, '++ l_ret_prorate_pc', l_ret_prorate_pc);
       end if;

       SELECT count(th.transaction_header_id)
       INTO  l_future_ret_count
       FROM  fa_deprn_periods dp,
             fa_transaction_headers th,
             fa_retirements ret,
             fa_conventions con
       WHERE th.book_type_code = p_asset_hdr_rec.book_type_code
       and   th.asset_id = p_asset_hdr_rec.asset_id
       and   th.transaction_type_code like '%RETIREMENT'
       and   th.date_effective between dp.period_open_date and dp.period_close_Date
       and   dp.period_counter = l_ret_prorate_pc - 1
       and   dp.book_type_code = th.book_type_code
       and   th.transaction_header_id = ret.transaction_header_id_in
       and   ret.RETIREMENT_PRORATE_CONVENTION = con.PRORATE_CONVENTION_CODE
       and   ret.date_retired between con.start_date and con.end_date
       and   con.prorate_date > dp.calendar_period_close_date;

       if l_future_ret_count > 0 then
          -- fetch addition
          SELECT th.transaction_date_entered,
                 th.date_effective,
                 th.transaction_header_id,
                 'N'
          INTO  l_trans_rec.transaction_date_entered,
                l_trans_rec.who_info.creation_date,
                l_trans_rec.transaction_header_id,
                l_retirement_flag
          FROM  fa_transaction_headers th
          WHERE th.book_type_code = p_asset_hdr_rec.book_type_code
          and   th.asset_id = p_asset_hdr_rec.asset_id
          and   th.transaction_type_code = 'ADDITION';

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '========== Recalc Bug 7699305: BEFORE LOOP FOR CURSOR c_get_ths_adj ==========','');
             fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.transaction_date_entered', to_char(l_trans_rec.transaction_date_entered,'MM/DD/YYYY HH24:MI:SS'));
             fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.who_info.creation_date', to_char(l_trans_rec.who_info.creation_date,'MM/DD/YYYY HH24:MI:SS'));
             fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.transaction_header_id', l_trans_rec.transaction_header_id);
             fa_debug_pkg.add(l_calling_fn, '++ l_retirement_flag', l_retirement_flag);
          end if;

       end if;
    end if;
   --Bug 8674466 :  End of fix

   -- Bug 8537330: If the driving transaction for c_get_ths_adj
   -- is not the transaction for which GetEofyReserve was called .. then
   -- make l_eofy_reserve as 0
   if (l_get_eofy_thid is not null and
       l_get_eofy_thid <> l_trans_rec.transaction_header_id) then
      l_eofy_reserve := 0;
   end if;

   OPEN c_get_ths_adj(l_trans_rec.transaction_date_entered,
                      l_trans_rec.who_info.creation_date,
                      l_trans_rec.transaction_header_id,
                      l_retirement_flag); --Bug4622110

   LOOP -- Main loop for all transactions


      FETCH c_get_ths_adj BULK COLLECT INTO t_transaction_header_id,
                                            t_transaction_type_code,
                                            t_transaction_date_entered,
                                            t_date_effective,
                                            t_transaction_name,
                                            t_source_transaction_header_id,
                                            t_mass_reference_id,
                                            t_transaction_subtype,
                                            t_transaction_key,
                                            t_amortization_start_date,
                                            t_calling_interface,
                                            t_mass_transaction_id,
                                            t_deprn_override_flag,
                                            t_member_transaction_header_id,
                                            t_trx_reference_id,
                                            t_invoice_transaction_id,
                                            t_which_select
                                            LIMIT l_limit;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 4.1 IN Fetch c_get_ths_adj  ==========','', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Number of rows fetched',
                          t_transaction_header_id.COUNT, p_log_level_rec => p_log_level_rec);
      end if;

      -- Store total row count
      l_row_count := c_get_ths_adj%ROWCOUNT;

      EXIT WHEN t_transaction_header_id.COUNT = 0;

      FOR i IN 1..t_transaction_header_id.COUNT LOOP -- for every 100 transactions
         if (t_transaction_type_code(i) = 'TAX') then
              -- bug 9003531. check if retirement trx is overlapping with
              -- TAX reserve transaction. If they are overlapped raise exception
            begin
              Select 1 into l_check_tax_overlap
              from fa_transaction_headers hdr,
                   fa_transaction_headers tax
              where hdr.transaction_header_id  < t_transaction_header_id(i) --Transaction header id for TAX transaction
              and hdr.transaction_date_entered <= t_transaction_date_entered(i) --Transaction date for TAX transaction
              and hdr.transaction_type_code like '%RETIREMENT'
              and hdr.book_type_code        = tax.book_type_code
              and hdr.asset_id              =  tax.asset_id
              and tax.transaction_header_id = t_transaction_header_id(i);
            exception when no_data_found then
              l_check_tax_overlap := 0;
            end ;
            if ( l_check_tax_overlap = 1) then
                raise invalid_trx_to_overlap;
            end if;
         end if;

         l_dbr_event_type := 'AMORT_ADJ';
         l_impair_reserve := 0;


         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 4.1.1 IN For-Loop of c_get_ths_adj ==========','', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++ IN c_get_ths_adj: t_which_select('||to_char(i)||')',t_which_select(i));
           fa_debug_pkg.add(l_calling_fn, '++    t_transaction_header_id('||to_char(i)||')',t_transaction_header_id(i));
           fa_debug_pkg.add(l_calling_fn, '++    t_transaction_type_code('||to_char(i)||')',t_transaction_type_code(i));
           fa_debug_pkg.add(l_calling_fn, '++    t_transaction_date_entered('||to_char(i)||')',to_char(t_transaction_date_entered(i),'MM/DD/YYYY'));
           fa_debug_pkg.add(l_calling_fn, '++    t_amortization_start_date('||to_char(i)||')',to_char(t_amortization_start_date(i),'MM/DD/YYYY'));
           fa_debug_pkg.add(l_calling_fn, '++    t_date_effective('||to_char(i)||')',to_char(t_date_effective(i),'MM/DD/YYYY HH24:MI:SS'));
           fa_debug_pkg.add(l_calling_fn, '++    t_transaction_subtype('||to_char(i)||')',t_transaction_subtype(i));
           fa_debug_pkg.add(l_calling_fn, '++    l_dbr_event_type',l_dbr_event_type, p_log_level_rec => p_log_level_rec);
         end if;


         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ BEFORE SETTING', '...', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_adj_processed', l_adj_processed, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_process_this_trx', l_process_this_trx, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_add_processed', l_add_processed, p_log_level_rec => p_log_level_rec);
         end if;

         --
         -- don't want to process addition after any trx.
         --
         if (not(l_adj_processed)) and
            (t_transaction_type_code(i) not in ('ADDITION', 'ADDITION/VOID', 'CIP ADIITION', 'CIP ADDITION/VOID')) then
            l_adj_processed := TRUE;
         elsif (l_adj_processed) and
               (t_transaction_type_code(i) like '%ADDITION%') then
            l_process_this_trx := FALSE;
         end if;

         --
         -- don't want to process addition/void after addition
         --
         if (not(l_add_processed)) and
            (t_transaction_type_code(i) = 'ADDITION') then
            l_add_processed := TRUE;
         elsif (l_add_processed) and
               (p_trans_rec.transaction_type_code <> 'ADDITION/VOID') and
               (t_transaction_type_code(i) in ('ADDITION/VOID', 'CIP ADDITION/VOID')) then
            l_process_this_trx := FALSE;
         end if;

         l_is_this_void := FALSE;

         if (not(l_adj_processed)) and
            (not(l_add_processed)) then
            l_is_this_void := TRUE;
         end if;


         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ AFTER SETTING', '...', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_adj_processed', l_adj_processed, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_process_this_trx', l_process_this_trx, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_add_processed', l_add_processed, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, '++    l_is_this_void', l_is_this_void, p_log_level_rec => p_log_level_rec);
         end if;


         l_asset_fin_rec_old := l_asset_fin_rec_new;

         l_trans_rec := null;
         l_next_period_rec := null;
         l_member_asset_id := null;
         l_member_trx_key := null;

         l_trans_rec.transaction_header_id := t_transaction_header_id(i);
         l_trans_rec.transaction_type_code := t_transaction_type_code(i);
         l_trans_rec.transaction_date_entered := t_transaction_date_entered(i);
         l_trans_rec.who_info.creation_date := t_date_effective(i);
         l_trans_rec.transaction_name := t_transaction_name(i);
         l_trans_rec.source_transaction_header_id := t_source_transaction_header_id(i);
         l_trans_rec.mass_reference_id := t_mass_reference_id(i);
         l_trans_rec.transaction_subtype := t_transaction_subtype(i);
         l_trans_rec.transaction_key := t_transaction_key(i);
         l_trans_rec.amortization_start_date := t_amortization_start_date(i);
         l_trans_rec.calling_interface := t_calling_interface(i);
         l_trans_rec.mass_transaction_id := t_mass_transaction_id(i);
         l_trans_rec.deprn_override_flag := t_deprn_override_flag(i);
         l_trans_rec.member_transaction_header_id := t_member_transaction_header_id(i);
         l_trans_rec.trx_reference_id := t_trx_reference_id(i);
         l_invoice_transaction_id := t_invoice_transaction_id(i);

--tk_util.DumpTrxRec(l_trans_rec, to_char(i));

         if (i=1) or
            (l_trans_rec.transaction_date_entered > l_period_rec.calendar_period_close_date) then

            -- Bug6190904: Need to determine correct date to find out from which period catch-up
            --             needs to be calculated.  This is true even for the adjustment.
            if (i=1) then

               OPEN c_get_prorate_date(px_asset_fin_rec_new.date_placed_in_service
                                     , px_asset_fin_rec_new.prorate_convention_code);
               FETCH c_get_prorate_date INTO l_prorate_date, l_start_date, l_end_date;
               CLOSE c_get_prorate_date;

            end if;

            if (nvl(l_trans_rec.amortization_start_date,l_trans_rec.transaction_date_entered) > l_end_date) then
               l_prorate_date := nvl(l_trans_rec.amortization_start_date,l_trans_rec.transaction_date_entered);
            end if;
            -- End of Bug6190904

            -- Bug6190904: use date determined by above logic instead of
            --             transaction_date_entered
            if not GetPeriodInfo(to_number(to_char(l_prorate_date, 'J')),
                                 p_asset_hdr_rec.book_type_code,
                                 p_mrc_sob_type_code,
                                 p_asset_hdr_rec.set_of_books_id,
                                 l_period_rec,
                                 p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

         end if;

--tk_util.DumpPerRec(l_period_rec, to_char(i));

         --
         -- Special processes for first transaction only
         --
         if (i = 1) and (l_row_count <= l_limit) then

            -- Find least transaction header id
            FOR j IN 1..t_transaction_header_id.COUNT LOOP

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'This is first trx', l_incoming_thid, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 't_transaction_header_id(j)', t_transaction_header_id(j));
                  fa_debug_pkg.add(l_calling_fn, 't_transaction_type_code(j)', t_transaction_type_code(j));
               end if;

               --Bug6933891
               -- This is for void trx to be pocessed if that is dated before addition trx.
               if (t_transaction_type_code(i) = 'ADDITION') and
                  (not l_add_void_exist) then   --Bug6933891 necessary
                  l_add_exist      := TRUE;
               elsif (t_transaction_type_code(j) = 'ADDITION') and
                  (not l_add_void_exist) then   --Bug6933891
                  l_add_exist      := TRUE;
               elsif (t_transaction_type_code(j) = 'ADDITION/VOID') then
                  l_add_void_exist := TRUE;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'l_add_void_exist', l_add_void_exist, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_add_exist', l_add_exist, p_log_level_rec => p_log_level_rec);
               end if;


               if (nvl(l_least_thid, l_incoming_thid) <> t_transaction_header_id(j)) and
                  (nvl(l_least_thid, l_incoming_thid) > t_transaction_header_id(j)) and
                  (((p_asset_type_rec.asset_type = G_ASSET_TYPE_GROUP) and
                    (t_transaction_header_id(j) is not null)) or
                   (p_asset_type_rec.asset_type <> G_ASSET_TYPE_GROUP)) then

                  --
                  -- Cannot process addition after adjustment???  not sure this will work
                  -- Also, do not process addition void after addition
                  --
                  -- Bug4490414: Commenting out part of the following if condition
                  -- 2nd part of if (after or) does not have to check the 1st
                  -- trx type code. Commenting out "t_transaction_type_code(i)  = 'ADDITION' and"
                  -- from 2nd part of if below.
                  if (t_transaction_type_code(i) <> 'ADDITION' and
                      t_transaction_type_code(j) = 'ADDITION' ) or
                     (t_transaction_type_code(j) like '%ADDITION/VOID' ) then
                     null;
                  else
                     l_least_thid := t_transaction_header_id(j);
                  end if;
               end if;

            END LOOP;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Least transaction header id',
                                l_least_thid, p_log_level_rec => p_log_level_rec);
            end if;


            l_temp_period_counter := l_period_rec.period_counter;
            l_period_rec.period_counter := l_period_rec.period_counter -1;

            if not GetDeprnRec (
                       p_trans_rec             => l_trans_rec,
                       p_asset_hdr_rec         => p_asset_hdr_rec,
                       p_period_rec            => l_period_rec,
                       p_incoming_trx_type_code => p_trans_rec.transaction_type_code,
                       x_asset_deprn_rec       => l_asset_deprn_rec,
                       p_mrc_sob_type_code     => p_mrc_sob_type_code,
                       p_unplanned_exp          => l_unplanned_exp,
                    p_log_level_rec       => p_log_level_rec) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'GetDeprnRec', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            l_period_rec.period_counter := l_temp_period_counter;

--tk_util.DumpDeprnRec(l_asset_deprn_rec, 'GD');

            l_dpr_in.asset_num := p_asset_desc_rec.asset_number;
            l_dpr_in.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
            l_dpr_in.book := p_asset_hdr_rec.book_type_code;
            l_dpr_in.asset_id := p_asset_hdr_rec.asset_id;

            --
            -- Need to reset ytd amounts for first period of the fiscal year
            --
            if (l_period_rec.period_num = 1) then
               l_asset_deprn_rec.ytd_deprn := l_asset_deprn_rec.deprn_amount;
               l_asset_deprn_rec.bonus_ytd_deprn := l_asset_deprn_rec.bonus_deprn_amount;
               l_asset_deprn_rec.ytd_impairment := l_asset_deprn_rec.impairment_amount;
            end if;
         end if; -- End of Special processes for first transaction

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_add_void_exist', l_add_void_exist, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_add_exist', l_add_exist, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_process_this_trx', l_process_this_trx, p_log_level_rec => p_log_level_rec);
         end if;

         --Bug6933891
         -- This is for void trx to be pocessed if that is dated before addition trx.
         -- Setting void trx as not void in this loop so that the trx will be processed.
         if (l_add_void_exist) and (not(l_add_exist)) and
            (t_transaction_type_code(i) = 'ADDITION/VOID') then
            l_process_this_trx := TRUE;
            l_is_this_void     := FALSE;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Process this trx even if this is void trx', t_transaction_type_code(i));
               fa_debug_pkg.add(l_calling_fn, 'l_is_this_void', l_is_this_void, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_process_this_trx', l_process_this_trx, p_log_level_rec => p_log_level_rec);
            end if;
         end if;

         if (l_asset_fin_rec_old.recoverable_cost is null) then
            -- This means this is the first time coming through in this main loop

            if (not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP (
                    p_asset_id              => p_asset_hdr_rec.asset_id,
                    p_book_type_code        => p_asset_hdr_rec.book_type_code,
                    p_fiscal_year           => l_period_rec.fiscal_year,
                    p_asset_type            => p_asset_type_rec.asset_type,
                    p_period_num            => l_period_rec.period_num,
                    p_mrc_sob_type_code     => p_mrc_sob_type_code,
                    p_set_of_books_id       => p_asset_hdr_rec.set_of_books_id,
                    x_eofy_recoverable_cost => l_eofy_rec_cost,
                    x_eofy_salvage_value    => l_eofy_sal_val,
                    x_eop_recoverable_cost  => l_eop_rec_cost,
                    x_eop_salvage_value     => l_eop_sal_val, p_log_level_rec => p_log_level_rec)) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;

            end if;

            if (l_eofy_rec_cost is null) then
               l_eofy_rec_cost := 0;
               l_eofy_sal_val := 0;
            end if;

            l_eofy_fy := l_period_rec.fiscal_year;

            if (l_eop_rec_cost is null) then
               l_eop_rec_cost := 0;
               l_eop_sal_val := 0;
            end if;

         elsif (l_eofy_fy < l_period_rec.fiscal_year) then
            -- set new end of fiscal year new recoverable cost, salvage
            -- value and previous fiscal year.

            l_eofy_rec_cost := l_asset_fin_rec_old.recoverable_cost;
            l_eofy_sal_val := l_asset_fin_rec_old.salvage_value;
            l_eofy_fy := l_period_rec.fiscal_year;

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_eofy_fy', l_eofy_fy, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_eofy_rec_cost', l_eofy_rec_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_eofy_sal_val', l_eofy_sal_val, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_eop_rec_cost', l_eop_rec_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_eop_sal_val', l_eop_sal_val, p_log_level_rec => p_log_level_rec);
         end if;

         if (l_trans_rec.transaction_header_id = l_incoming_thid) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Entered Transaction', 'TRUE', p_log_level_rec => p_log_level_rec);
            end if;

            l_asset_deprn_rec.deprn_reserve := l_asset_deprn_rec.deprn_reserve +
                                               nvl(p_asset_deprn_rec_adj.deprn_reserve, 0);
            l_asset_deprn_rec.reval_deprn_reserve :=
                           l_asset_deprn_rec.reval_deprn_reserve +
                           nvl(p_asset_deprn_rec_adj.reval_deprn_reserve, 0);
            l_asset_deprn_rec.bonus_deprn_reserve :=
                           l_asset_deprn_rec.bonus_deprn_reserve +
                           nvl(p_asset_deprn_rec_adj.bonus_deprn_reserve, 0);
            l_asset_deprn_rec.impairment_reserve :=
                           l_asset_deprn_rec.impairment_reserve +
                           nvl(p_asset_deprn_rec_adj.impairment_reserve, 0);

            -- Bug 9231768 : Populate ytd_deprn also.
            l_asset_deprn_rec.ytd_deprn := l_asset_deprn_rec.ytd_deprn +
                                               nvl(p_asset_deprn_rec_adj.ytd_deprn, 0);

            l_use_fin_rec_adj     := TRUE;
            l_use_new_deprn_rule  := TRUE;

            --+++++++ Setting this flag to resume depreciation calculation +++++
            if (l_calc_deprn_flag) then
               l_calc_deprn_flag := FALSE;
            end if;
         else
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Entered Transaction', 'FALSE', p_log_level_rec => p_log_level_rec);
            end if;

            l_use_fin_rec_adj := FALSE;
         end if;

         if l_trans_rec.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)  then

            l_reserve_retired := null;

            if (p_mrc_sob_type_code = 'R') then

               OPEN c_get_mc_retirement(nvl(l_trans_rec.member_transaction_header_id,
                                            l_trans_rec.transaction_header_id));
               FETCH c_get_mc_retirement INTO l_retirement_id,
                                              l_cost_retired,
                                              l_cost_of_removal,
                                              l_proceeds_of_sales,
                                              l_reserve_retired,
                                              l_eofy_reserve_retired,
                                              l_reval_reserve_retired,
                                              l_unrevalued_cost_retired,
                                              l_bonus_reserve_retired,
                                              l_impair_reserve_retired,
                                              l_recognize_gain_loss;

               if c_get_mc_retirement%NOTFOUND then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Process this transaction', 'FALSE', p_log_level_rec => p_log_level_rec);
                  end if;

                  l_process_this_trx := FALSE;
               else
                  if (l_reserve_retired = 0) then
                     OPEN c_get_mc_rsv_retired (nvl(l_trans_rec.member_transaction_header_id,
                                                    l_trans_rec.transaction_header_id));
                     FETCH c_get_mc_rsv_retired INTO l_reserve_retired;
                     CLOSE c_get_mc_rsv_retired;
                  end if;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Process this '||
                                      l_trans_rec.transaction_type_code, 'TRUE', p_log_level_rec => p_log_level_rec);
                  end if;
               end if; -- c_get_mc_retirement%NOTFOUND

               CLOSE c_get_mc_retirement;
            else
--tk_util.debug('thid: '||to_char(nvl(l_trans_rec.member_transaction_header_id, l_trans_rec.transaction_header_id)));
               OPEN c_get_retirement(nvl(l_trans_rec.member_transaction_header_id,
                                         l_trans_rec.transaction_header_id));
               FETCH c_get_retirement INTO l_retirement_id,
                                           l_cost_retired,
                                           l_cost_of_removal,
                                           l_proceeds_of_sales,
                                           l_reserve_retired,
                                           l_eofy_reserve_retired,
                                           l_reval_reserve_retired,
                                           l_unrevalued_cost_retired,
                                           l_bonus_reserve_retired,
                                           l_impair_reserve_retired,
                                           l_recognize_gain_loss;

               if c_get_retirement%NOTFOUND then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Process this transaction', 'FALSE', p_log_level_rec => p_log_level_rec);
                  end if;

                  l_process_this_trx := FALSE;
               else

                  if (l_reserve_retired = 0) then
                     OPEN c_get_rsv_retired (nvl(l_trans_rec.member_transaction_header_id,
                                                 l_trans_rec.transaction_header_id));
                     FETCH c_get_rsv_retired INTO l_reserve_retired;
                     CLOSE c_get_rsv_retired;
                  end if;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Process this '||
                                      l_trans_rec.transaction_type_code, 'TRUE', p_log_level_rec => p_log_level_rec);
                  end if;

               end if; -- c_get_retirement%NOTFOUND

               CLOSE c_get_retirement;

            end if; -- (p_mrc_sob_type_code = 'R')

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Retirement Id',
                                l_retirement_id, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'Retired Reserve',
                                l_reserve_retired, p_log_level_rec => p_log_level_rec);
            end if;

         elsif l_trans_rec.transaction_type_code = G_TRX_TYPE_REV then

            if (p_mrc_sob_type_code = 'R') then
               OPEN c_get_mc_reval_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                           l_trans_rec.transaction_header_id));
               FETCH c_get_mc_reval_rsv INTO l_reval_reserve;
               CLOSE c_get_mc_reval_rsv;

               OPEN c_get_mc_bonus_reval_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                           l_trans_rec.transaction_header_id));
               FETCH c_get_mc_bonus_reval_rsv INTO l_reval_bonus_reserve;
               CLOSE c_get_mc_bonus_reval_rsv;
               OPEN c_get_mc_impair_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                           l_trans_rec.transaction_header_id),
                                        G_TRX_TYPE_REV);
               FETCH c_get_mc_impair_rsv INTO l_reval_impair_reserve;
               CLOSE c_get_mc_impair_rsv;

            else
               OPEN c_get_reval_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                        l_trans_rec.transaction_header_id));
               FETCH c_get_reval_rsv INTO l_reval_reserve;
               CLOSE c_get_reval_rsv;

               OPEN c_get_bonus_reval_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                              l_trans_rec.transaction_header_id));
               FETCH c_get_bonus_reval_rsv INTO l_reval_bonus_reserve;
               CLOSE c_get_bonus_reval_rsv;

               OPEN c_get_impair_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                              l_trans_rec.transaction_header_id),
                                     G_TRX_TYPE_REV);
               FETCH c_get_impair_rsv INTO l_reval_impair_reserve;
               CLOSE c_get_impair_rsv;

            end if;


            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Revaluation Reserve',
                                l_reval_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'Revaluation Reserve',
                                l_reval_bonus_reserve, p_log_level_rec => p_log_level_rec);
            end if;

         elsif (l_trans_rec.transaction_key = 'IM') then
            if (p_mrc_sob_type_code = 'R') then
               OPEN c_get_mc_impair_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                           l_trans_rec.transaction_header_id),
                                        G_TRX_TYPE_ADJ);
               FETCH c_get_mc_impair_rsv INTO l_impair_reserve;
               CLOSE c_get_mc_impair_rsv;
            else
               OPEN c_get_impair_rsv(nvl(l_trans_rec.member_transaction_header_id,
                                              l_trans_rec.transaction_header_id),
                                     G_TRX_TYPE_ADJ);
               FETCH c_get_impair_rsv INTO l_impair_reserve;
               CLOSE c_get_impair_rsv;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Impairment Reserve', l_impair_reserve, p_log_level_rec => p_log_level_rec);
            end if;

         end if; -- l_trans_rec.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)

         --
         -- Construct new fa_books row.
         -- For first transaction, also get initial fa_books row.
         if (l_process_this_trx) or
            ((i = 1) and (l_row_count < l_limit)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 6.0 : Calling GetFinRec ==========','', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '++ l_trans_rec.transaction_header_id', l_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
            end if;

            -- Bug # 8356539 added below code to pass deprn limit type to
            -- adjustment api when called from backend
            if l_asset_fin_rec_adj.deprn_limit_type is null and p_trans_rec.calling_interface <> 'FAXASSET'
               and l_use_fin_rec_adj then
               l_asset_fin_rec_adj.deprn_limit_type := p_asset_fin_rec_old.deprn_limit_type;
            end if;

            if not GetFinRec(p_trans_rec                  => l_trans_rec,
                             p_asset_hdr_rec              => p_asset_hdr_rec,
                             p_asset_type_rec             => p_asset_type_rec,
                             px_asset_fin_rec             => l_asset_fin_rec_old,
                             p_asset_fin_rec_adj          => l_asset_fin_rec_adj,
                             p_asset_fin_rec_new          => px_asset_fin_rec_new,
                             x_asset_fin_rec_new          => l_asset_fin_rec_new,
                             p_init_transaction_header_id => l_least_thid,
                             p_use_fin_rec_adj            => l_use_fin_rec_adj,
                             p_use_new_deprn_rule         => l_use_new_deprn_rule,
                             p_process_this_trx           => (l_process_this_trx or l_is_this_void),
                             x_dpis_change                => l_dpis_change,
                             p_mrc_sob_type_code          => p_mrc_sob_type_code) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'GetFinRec', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            --
            -- This portion of codes are relocated from before GetFinRec because it sometime
            -- requires to find old cost(new cost - cost retired).
            --
            if (l_trans_rec.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)) then
               if (l_reserve_retired <> 0) then
                  l_reserve_retired := l_asset_deprn_rec.deprn_reserve *
                                       (l_cost_retired /nvl(l_asset_fin_rec_old.cost,l_asset_fin_rec_new.cost - l_cost_retired));
                  if not FA_UTILS_PKG.faxrnd(l_reserve_retired, p_asset_hdr_rec.book_type_code, p_asset_hdr_rec.set_of_books_id,p_log_level_rec => p_log_level_rec) then
                     fa_debug_pkg.add(l_calling_fn, 'calling FA_UTILS_PKG.faxrnd', 'FAILED', p_log_level_rec => p_log_level_rec);
                     raise calc_failed;
                  end if;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Recalculated Reserve Retired',
                                   l_reserve_retired, p_log_level_rec => p_log_level_rec);
               end if;

               -- Populate local retire rec for depreciable basis to bahave like retirement
               l_asset_retire_rec.cost_retired := l_cost_retired;
               l_asset_retire_rec.proceeds_of_sale := l_proceeds_of_sales;
               l_asset_retire_rec.cost_of_removal := l_cost_of_removal;
               l_asset_retire_rec.detail_info.nbv_retired := l_cost_retired - l_reserve_retired;

               l_dbr_event_type := 'RETIREMENT';

            end if; -- l_trans_rec.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)

            if (l_dpis_change) then
               if (p_mrc_sob_type_code = 'R') then
                  OPEN c_get_mc_brow;
                  FETCH c_get_mc_brow INTO l_brow_ytd_deprn, l_brow_deprn_reserve;
                  CLOSE c_get_mc_brow;
               else
                  OPEN c_get_brow;
                  FETCH c_get_brow INTO l_brow_ytd_deprn, l_brow_deprn_reserve;
                  CLOSE c_get_brow;
               end if;
--tk_util.debug('check: '||to_char(l_brow_ytd_deprn)||':'||to_char(l_brow_deprn_reserve));
--
-- need to initialize l_asset_deprn_rec with B row.
               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 6.5 : Resetting l_asset_deprn_rec to ZERO due to DPIS Change ==========','', p_log_level_rec => p_log_level_rec);
               end if;

               l_asset_deprn_rec.deprn_amount             := 0;
               l_asset_deprn_rec.ytd_deprn                := 0; --bug 8540563 nvl(l_brow_ytd_deprn, 0);
               l_asset_deprn_rec.deprn_reserve            := 0; --bug 8540563 nvl(l_brow_deprn_reserve, 0);
               l_asset_deprn_rec.prior_fy_expense         := 0;
               l_asset_deprn_rec.bonus_deprn_amount       := 0;
               l_asset_deprn_rec.bonus_ytd_deprn          := 0;
               l_asset_deprn_rec.bonus_deprn_reserve      := 0;
               l_asset_deprn_rec.prior_fy_bonus_expense   := 0;
               l_asset_deprn_rec.impairment_amount        := 0;
               l_asset_deprn_rec.ytd_impairment           := 0;
               l_asset_deprn_rec.impairment_reserve           := 0;
               l_asset_deprn_rec.reval_amortization       := 0;
               l_asset_deprn_rec.reval_amortization_basis := 0;
               l_asset_deprn_rec.reval_deprn_expense      := 0;
               l_asset_deprn_rec.reval_ytd_deprn          := 0;
               l_asset_deprn_rec.reval_deprn_reserve      := 0;
               l_asset_deprn_rec.production               := 0;
               l_asset_deprn_rec.ytd_production           := 0;
               l_asset_deprn_rec.ltd_production           := 0;

               if (l_trans_rec.transaction_subtype = 'EXPENSED') then
                  --Bug#4049799 l_dbr_event_type := 'EXPENSED_ADJ';
                  l_dbr_event_type := 'AMORT_ADJ';
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'DPIS Change', l_dbr_event_type, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'new ytd_deprn', l_asset_deprn_rec.ytd_deprn, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'new deprn_reserve', l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
               end if;
            end if;
--tk_util.debug('1 rec_cost: '||to_char(px_asset_fin_rec_new.recoverable_cost));

            if l_trans_rec.transaction_type_code not in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET)  then
               if ((i = 1) and not(l_start_from_first) and (l_process_addition = 0)) then
--tk_util.debug('toru: '||to_char(l_asset_deprn_rec.deprn_reserve));
                  l_asset_fin_rec_new.eofy_reserve := l_asset_deprn_rec.deprn_reserve;

               elsif ((i = 1) and (l_row_count < l_limit)) then
                  --
                  -- if this is member or will be a member, l_eofy_reserve may not be populated
                  -- in GetFinRec so use the one returned by GetEofyReserve function.
                  --
                  if (p_asset_fin_rec_old.group_asset_id is null and
                      px_asset_fin_rec_new.group_asset_id is null) then
                     l_asset_fin_rec_new.eofy_reserve := l_eofy_reserve;
                  end if;
               else
                  l_asset_fin_rec_new.eofy_reserve := l_asset_fin_rec_old.eofy_reserve;
               end if;
            end if;

         else
            l_asset_fin_rec_new := l_asset_fin_rec_old;
         end if; -- (l_process_this_trx)

         l_impair_adj_cost := l_asset_fin_rec_new.adjusted_cost;
         l_impair_raf := l_asset_fin_rec_new.rate_adjustment_factor;
         l_impair_formula_factor := l_asset_fin_rec_new.formula_factor;

         if (l_impair_reserve <> 0) then
            l_asset_deprn_rec.impairment_reserve := l_asset_deprn_rec.impairment_reserve + l_impair_reserve;
         end if;
--tk_util.debug('1eofy rsv: '||to_char(l_asset_fin_rec_new.eofy_reserve));

         l_dpr_in.adj_cost := l_asset_fin_rec_new.recoverable_cost;
         l_dpr_in.rec_cost := l_asset_fin_rec_new.recoverable_cost;
	 l_dpr_in.reval_amo_basis := l_asset_deprn_rec.reval_deprn_reserve; -- bug 7256190
         l_dpr_in.deprn_rsv := 0;
         l_dpr_in.reval_rsv := l_asset_deprn_rec.reval_deprn_reserve;
         l_dpr_in.adj_rate := l_asset_fin_rec_new.adjusted_rate;
         l_dpr_in.rate_adj_factor := l_asset_fin_rec_new.rate_adjustment_factor;
         l_dpr_in.capacity := l_asset_fin_rec_new.production_capacity;
         l_dpr_in.adj_capacity := l_asset_fin_rec_new.adjusted_capacity;
         l_dpr_in.ltd_prod := 0;

         l_dpr_in.ceil_name := l_asset_fin_rec_new.ceiling_name;
         l_dpr_in.bonus_rule := l_asset_fin_rec_new.bonus_rule;
         l_dpr_in.method_code := l_asset_fin_rec_new.deprn_method_code;
         l_dpr_in.jdate_in_service :=
                      to_number(to_char(l_asset_fin_rec_new.date_placed_in_service, 'J'));
         l_dpr_in.prorate_jdate := to_number(to_char(l_asset_fin_rec_new.prorate_date, 'J'));
         l_dpr_in.deprn_start_jdate :=
                      to_number(to_char(l_asset_fin_rec_new.deprn_start_date, 'J'));
         l_dpr_in.jdate_retired := 0; -- don't know this is correct or not
         l_dpr_in.ret_prorate_jdate := 0; -- don't know this is correct or not
         l_dpr_in.life := l_asset_fin_rec_new.life_in_months;

         l_dpr_in.rsv_known_flag := TRUE;
         l_dpr_in.salvage_value := l_asset_fin_rec_new.salvage_value;
         l_dpr_in.pc_life_end := l_asset_fin_rec_new.period_counter_life_complete;
         l_dpr_in.adj_rec_cost := l_asset_fin_rec_new.adjusted_recoverable_cost;
         l_dpr_in.prior_fy_exp := 0;                             -- This needs to be 0 for this faxcde call

         -- Bug:5291878
         l_dpr_in.deprn_rounding_flag := null;

         l_dpr_in.deprn_override_flag := p_trans_rec.deprn_override_flag;
         l_dpr_in.used_by_adjustment := TRUE;
         l_dpr_in.ytd_deprn := 0;                                -- This needs to be 0 for this faxcde call
         l_dpr_in.short_fiscal_year_flag := l_asset_fin_rec_new.short_fiscal_year_flag;
         l_dpr_in.conversion_date := l_asset_fin_rec_new.conversion_date;
         l_dpr_in.prorate_date := l_asset_fin_rec_new.prorate_date;
         l_dpr_in.orig_deprn_start_date := l_asset_fin_rec_new.orig_deprn_start_date;
         l_dpr_in.old_adj_cost := l_asset_fin_rec_new.old_adjusted_cost;
         l_dpr_in.formula_factor := nvl(l_asset_fin_rec_new.formula_factor,
                                        l_asset_fin_rec_old.formula_factor);
         l_dpr_in.bonus_deprn_exp := l_asset_deprn_rec.bonus_deprn_amount;
         l_dpr_in.bonus_ytd_deprn := l_asset_deprn_rec.bonus_ytd_deprn;
         l_dpr_in.bonus_deprn_rsv := l_asset_deprn_rec.bonus_deprn_reserve;
         l_dpr_in.prior_fy_bonus_exp := l_asset_deprn_rec.prior_fy_bonus_expense;
         l_dpr_in.impairment_exp := l_asset_deprn_rec.impairment_amount;
         l_dpr_in.ytd_impairment := l_asset_deprn_rec.ytd_impairment;
         l_dpr_in.impairment_rsv := l_asset_deprn_rec.impairment_reserve;


         l_dpr_in.tracking_method := l_asset_fin_rec_new.tracking_method;
         l_dpr_in.allocate_to_fully_ret_flag := l_asset_fin_rec_new.allocate_to_fully_ret_flag;
         l_dpr_in.allocate_to_fully_rsv_flag := l_asset_fin_rec_new.allocate_to_fully_rsv_flag;
         l_dpr_in.excess_allocation_option := l_asset_fin_rec_new.excess_allocation_option;
         l_dpr_in.depreciation_option := l_asset_fin_rec_new.depreciation_option;
         l_dpr_in.member_rollup_flag := l_asset_fin_rec_new.member_rollup_flag;
         l_dpr_in.mrc_sob_type_code := p_mrc_sob_type_code;
         l_dpr_in.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
         l_dpr_in.super_group_id := l_asset_fin_rec_new.super_group_id;
         l_dpr_in.over_depreciate_option := l_asset_fin_rec_new.over_depreciate_option;

         --
         -- Not for what-if yet
         --
         l_running_mode := fa_std_types.FA_DPR_NORMAL;
--tk_util.debug('2 rec_cost: '||to_char(px_asset_fin_rec_new.recoverable_cost));

         if (l_process_this_trx) then

            if (not fa_cache_pkg.fazccmt(
                       l_asset_fin_rec_new.deprn_method_code,
                       l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec)) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_failed;
            end if;

            l_energy_member := FALSE;
--tk_util.debug('fa_cache_pkg.fazcdbr_record.rule_name: ' ||fa_cache_pkg.fazcdbr_record.rule_name);
--tk_util.debug('p_asset_fin_rec_old.tracking_method: '||p_asset_fin_rec_old.tracking_method);
            --
            -- Set l_energy_member to skip periodic depreciation call in this functioin
            --
            if (fa_cache_pkg.fazcdbr_record.rule_name = 'ENERGY PERIOD END BALANCE') and
               (p_asset_fin_rec_old.tracking_method = 'ALLOCATE') then
               l_energy_member := TRUE;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Japan Tax: l_trans_rec.transaction_key',
                                      l_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
            end if;

            -- skip faxcde call for raf
            -- Bug4778244 Added the NVL to avoid condition not(null or false) which will
            -- always return NULL in the place of FALSE, which is incorrect
            if (not(((nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') = fa_std_types.FAD_RSR_FLAT) and
                     (nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule, ' ') = fa_std_types.FAD_DBR_COST) and
                     (nvl(fa_cache_pkg.fazcdbr_record.rule_name, ' ')  in ('PERIOD END BALANCE',

                                                                'PERIOD END AVERAGE',
                                                                'USE RECOVERABLE COST',
                                                                'BEGINNING PERIOD'))) or
                     ((nvl(fa_cache_pkg.fazcdbr_record.rule_name,' ') = 'ENERGY PERIOD END BALANCE') and
                      (nvl(p_asset_fin_rec_old.tracking_method,' ') = 'ALLOCATE')) or
                     (nvl(l_trans_rec.transaction_key,'X') = 'ES') -- Japan Tax Phase3
                   )) then

               if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                          fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                          l_dpr_in.prorate_jdate,
                                          g_temp_number,
                                          l_dpr_in.y_begin,
                                          g_temp_integer, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                      fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                      fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);

                  end if;

                  raise calc_failed;
               end if;

               if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
                  raise calc_failed;
               end if;

               l_dpr_in.p_cl_begin := 1;

               if (l_period_rec.period_num = 1) then
                  l_dpr_in.y_end := l_period_rec.fiscal_year - 1;
                  l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
               else
                  l_dpr_in.y_end := l_period_rec.fiscal_year;
                  l_dpr_in.p_cl_end := l_period_rec.period_num - 1;
               end if;

               l_dpr_in.rate_adj_factor := 1;
               l_dpr_in.eofy_reserve := 0;

               -- manual override
               if fa_cache_pkg.fa_deprn_override_enabled then

                  l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
                  l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

                  -- update override status only if satisfies condintion,
                  -- otherwise do not update status when calculating RAF
                  -- 1. formula; or
                  -- 2. (calc or table) and cost

                  l_dpr_in.update_override_status :=
                     ((l_rate_source_rule = fa_std_types.FAD_RSR_FORMULA)
                     OR (((l_rate_source_rule = fa_std_types.FAD_RSR_CALC)
                     OR (l_rate_source_rule = fa_std_types.FAD_RSR_TABLE))
                     AND (l_deprn_basis_rule = fa_std_types.FAD_DBR_COST)));
               end if;

               --+++++++ Call Tracking Function to populate Member in case ALLOCATE ++++++
               if nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then
/*
                  if not FA_TRACK_MEMBER_PVT.get_member_at_start(
                                      p_trans_rec => l_trans_rec,
                                      p_asset_hdr_rec => p_asset_hdr_rec,
                                      p_dpr_in => l_dpr_in,
                                      p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                         'FA_TRACK_MEMBER_PVT.get_member_at_start',  p_log_level_rec => p_log_level_rec);
                     end if;

                     raise calc_failed;

                  end if;
*/null;
               end if; -- nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE'

              l_dpr_in.cost_frac := null;  -- Bug 5893429

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '========== Recalc Before Calling faxcde 1 ==========','', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, ' Call ', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               --+++++++ Call Depreciation engine for rate adjustment factor +++++++
               if not FA_CDE_PKG.faxcde(l_dpr_in,
                                        l_dpr_arr,
                                        l_dpr_out,
                                        l_running_mode, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '========== Recalc After Calling faxcde 1 ==========','', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_deprn_rsv',
                                   l_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
               end if;

               -- manual override
               if fa_cache_pkg.fa_deprn_override_enabled then
                  if l_dpr_in.update_override_status then
                     p_trans_rec.deprn_override_flag := l_dpr_out.deprn_override_flag;
                  else
                     p_trans_rec.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
                  end if;
               end if;

               l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
               l_asset_fin_rec_new.reval_amortization_basis := l_dpr_out.new_reval_amo_basis;
               l_asset_deprn_rec_raf.deprn_reserve := l_dpr_out.new_deprn_rsv;
               l_asset_deprn_rec_raf.reval_deprn_reserve := l_dpr_out.new_reval_rsv;
               l_asset_fin_rec_new.adjusted_capacity := l_asset_fin_rec_new.production_capacity -
                                                        l_dpr_out.new_ltd_prod;
               l_asset_deprn_rec_raf.ltd_production := l_dpr_out.new_ltd_prod;
               l_asset_deprn_rec_raf.prior_fy_expense := l_dpr_out.new_prior_fy_exp;
               l_asset_deprn_rec_raf.bonus_deprn_amount := l_dpr_out.bonus_deprn_exp;
               l_asset_deprn_rec_raf.bonus_deprn_reserve := l_dpr_out.new_bonus_deprn_rsv;
               l_asset_deprn_rec_raf.prior_fy_bonus_expense := l_dpr_out.new_prior_fy_bonus_exp;
               l_asset_deprn_rec_raf.impairment_amount := l_dpr_out.impairment_exp;
               l_asset_deprn_rec_raf.impairment_reserve := l_dpr_out.new_impairment_rsv;


               -- Bug7610832
               -- Bug8208356. Calling transaction type should only be addition.
               -- Bug 6022155. If Calling transaction type is 'ADDITION' and user entered Accumlated Reserve,
               -- Then we need to consider Added Reserve but not eofy_reserve. i.e in period of addition we
               -- always give priority to added reserve than eofy_reserve. If there is not added reserve then
               -- only we take eofy_reserve. the if eofy_reserve <> 0 condition is added such that it is added
               -- In previous years and not in current year. Need to verify this is applicable for other rules
               -- also not only for USE FISCAL YEAR BEGINNING BASIS. This is coorect fix only because of fix
               -- 8208356, which makes sure that this is only addition.
               if l_dbr_event_type = 'AMORT_ADJ' and
                  fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'NBV' and
                  fa_cache_pkg.fazccmt_record.rate_source_rule  = 'FLAT' and
                  p_source_transaction_type_code = 'ADDITION' then
                        if (p_mrc_sob_type_code = 'R') then
                            OPEN c_get_mc_brow;
                            FETCH c_get_mc_brow INTO l_brow_ytd_deprn, l_brow_deprn_reserve;
                            CLOSE c_get_mc_brow;
                        else
                            OPEN c_get_brow;
                            FETCH c_get_brow INTO l_brow_ytd_deprn, l_brow_deprn_reserve;
                            CLOSE c_get_brow;
                        end if;
                        IF (fa_cache_pkg.fazcdbr_record.rule_name = 'USE FISCAL YEAR BEGINNING BASIS' and
                            nvl(l_dpr_out.new_eofy_reserve,0) <> 0 and l_brow_deprn_reserve <> 0) THEN
                            l_asset_fin_rec_new.eofy_reserve := l_brow_deprn_reserve - l_brow_ytd_deprn;
                        ELSE
                            l_asset_fin_rec_new.eofy_reserve := l_dpr_out.new_eofy_reserve;
                        END IF;
                end if;

               --++++++++ Tracking=ALLOCATE case ++++++++++++++
               if nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then

                  fa_track_member_pvt.p_track_member_table.delete;
                  fa_track_member_pvt.p_track_mem_index_table.delete;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'fa_track_member_pvt.p_track_member_table',
                                                    'deleted',  p_log_level_rec => p_log_level_rec);
                  end if;
               end if;

            else
               l_asset_fin_rec_new.adjusted_cost := l_asset_fin_rec_new.recoverable_cost;
            end if; ---- skip faxcde call for raf
--tk_util.debug('2eofy rsv: '||to_char(l_asset_fin_rec_new.eofy_reserve));

            --++++ Eofy Reserve in case of reclass ++++
            if l_trans_rec.transaction_type_code <> 'GROUP ADDITION' then
               l_asset_fin_rec_new.eofy_reserve := l_asset_fin_rec_new.eofy_reserve +
                                                   nvl(p_asset_fin_rec_adj.eofy_reserve,0);
            end if;

            if l_trans_rec.transaction_type_code in (G_TRX_TYPE_FUL_RET, G_TRX_TYPE_PAR_RET) then
               l_asset_fin_rec_new.eofy_reserve := l_asset_fin_rec_new.eofy_reserve -
                                                   l_eofy_reserve_retired;

               --++++ Skip followings because these values are already take care
               --++++ by using asset_deprn_rec_adj
               if (l_trans_rec.transaction_header_id <> p_trans_rec.transaction_header_id) then
                  l_asset_deprn_rec.deprn_reserve := l_asset_deprn_rec.deprn_reserve -
                                                     l_reserve_retired;
                  l_asset_deprn_rec.reval_deprn_reserve := l_asset_deprn_rec.reval_deprn_reserve -
                                                           l_reval_reserve_retired;
                  l_asset_deprn_rec.bonus_deprn_reserve := l_asset_deprn_rec.bonus_deprn_reserve -
                                                           l_bonus_reserve_retired;
                  l_asset_deprn_rec.impairment_reserve := l_asset_deprn_rec.impairment_reserve -
                                                           l_impair_reserve_retired;

               end if;
            elsif l_trans_rec.transaction_type_code = G_TRX_TYPE_REV then
               if (l_trans_rec.transaction_header_id <> p_trans_rec.transaction_header_id) then
                  /* Bug#7478702 In case of SORP when revaluation is done deprn_reserve is canceled against reval reserve
                     so when calculating adjusted cost deprn_reserve is zero */
                  if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then
                     l_asset_deprn_rec.deprn_reserve := 0;
                     /* For Cost based method adjusted_cost is same as recoverable cost at the time of revaluation
                        so setting impairment_reserve to zero */
                     if fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'COST' then
                        l_asset_deprn_rec.impairment_reserve := 0;
                     end if;
                  else
                     l_asset_deprn_rec.deprn_reserve := l_asset_deprn_rec.deprn_reserve +
                                                     nvl(l_reval_reserve, 0);
                     l_asset_deprn_rec.reval_deprn_reserve := l_asset_deprn_rec.reval_deprn_reserve +
                                                           nvl(l_reval_reserve, 0);
                     l_asset_deprn_rec.bonus_deprn_reserve := l_asset_deprn_rec.bonus_deprn_reserve +
                                                           nvl(l_reval_bonus_reserve, 0);
                     l_asset_deprn_rec.impairment_reserve := l_asset_deprn_rec.impairment_reserve +
                                                           nvl(l_reval_impair_reserve, 0);
                  end if;
               end if;
            end if;

--tk_util.debug('3 rec_cost: '||to_char(px_asset_fin_rec_new.recoverable_cost));

            -- Get Unplanned amount
            if (l_trans_rec.transaction_key in ('UE', 'UA')) then

               if (not GetExpRsv(p_trans_rec         => l_trans_rec,
                                 p_asset_hdr_rec     => p_asset_hdr_rec,
                                 p_period_rec        => l_period_rec,
                                 p_mrc_sob_type_code => p_mrc_sob_type_code,
                                 x_exp_rsv_amount    => l_reserve_adj,
                    p_log_level_rec       => p_log_level_rec )) then

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'GetExpRsv', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;
               end if;

               l_asset_deprn_rec.deprn_reserve := l_asset_deprn_rec.deprn_reserve + l_reserve_adj;

               if (l_trans_rec.transaction_key in ('UE', 'UA')) then
                  l_asset_deprn_rec.ytd_deprn := l_asset_deprn_rec.ytd_deprn + l_reserve_adj;
               end if;

            end if;

--tk_util.debug('3eofy rsv: '||to_char(l_asset_fin_rec_new.eofy_reserve));
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, ' Call ',
                                'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '========== Recalc Before Calling call_deprn_basis 1 ==========','', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.transaction_type_code',
                                p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_trans_rec.transaction_type_code',
                                l_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_eofy_reserve_retired',
                                l_eofy_reserve_retired, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_adj.eofy_reserve',
                                l_asset_fin_rec_adj.eofy_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.eofy_reserve',
                                l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve',
                                l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
            end if;

--tk_util.debug('4 rec_cost: '||to_char(px_asset_fin_rec_new.recoverable_cost));
            --
            -- if this is source line trx and there is no cost impact,
            -- do not call deprn basis function
            --
            if (not (l_invoice_transaction_id is not null and
                     nvl(l_asset_fin_rec_old.cost, 0) = l_asset_fin_rec_new.cost)) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '========== Recalc Before Calling call_deprn_basis 1.1 ==========','', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.adjusted_cost', l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dbr_event_type', l_dbr_event_type, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.adjusted_recoverable_cost', l_asset_fin_rec_new.adjusted_recoverable_cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.method_code', l_asset_fin_rec_new.deprn_method_code, p_log_level_rec => p_log_level_rec);
               end if;
               -- Bug 6704518 Populate the transaction_key for Extended method
               -- Bug 8211842: Pass trx_key as ES if extended has started else pass EN
               if (l_asset_fin_rec_new.deprn_method_code = 'JP-STL-EXTND') then
                  if p_period_rec.period_counter >= p_asset_fin_rec_old.extended_depreciation_period then
                     l_trans_rec.transaction_key := 'ES';
                  else
                     l_trans_rec.transaction_key := 'EN';
                  end if;
               end if;

               if (l_trans_rec.transaction_key = 'IM') then
                  l_asset_deprn_rec.impairment_reserve := l_asset_deprn_rec.impairment_reserve + l_asset_deprn_rec.deprn_reserve;
               end if;

               if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                             (p_event_type             => l_dbr_event_type,
                              p_asset_fin_rec_new      => l_asset_fin_rec_new,
                              p_asset_fin_rec_old      => l_asset_fin_rec_old,
                              p_asset_hdr_rec          => p_asset_hdr_rec,
                              p_asset_type_rec         => p_asset_type_rec,
                              p_asset_deprn_rec        => l_asset_deprn_rec,
                              p_asset_retire_rec       => l_asset_retire_rec,
                              p_trans_rec              => p_trans_rec,
                              p_trans_rec_adj          => l_trans_rec,
                              p_period_rec             => l_period_rec,
                              p_recoverable_cost       => px_asset_fin_rec_new.recoverable_cost,
                              p_current_total_rsv      => l_asset_deprn_rec.deprn_reserve,
                              p_current_rsv            => l_asset_deprn_rec.deprn_reserve -
                                                          l_asset_deprn_rec.bonus_deprn_reserve - nvl(l_asset_deprn_rec.impairment_reserve,0),
                              p_current_total_ytd      => l_asset_deprn_rec.ytd_deprn,
                              p_adj_reserve            => p_asset_deprn_rec_adj.deprn_reserve,
                              p_reserve_retired        => l_reserve_retired,
                              p_hyp_basis              => l_asset_fin_rec_new.adjusted_cost,
                              p_hyp_total_rsv          => l_asset_deprn_rec_raf.deprn_reserve,
                              p_hyp_rsv                => l_asset_deprn_rec_raf.deprn_reserve -
                                                          l_asset_deprn_rec_raf.bonus_deprn_reserve - nvl(l_asset_deprn_rec_raf.impairment_reserve,0),
                              p_eofy_recoverable_cost  => l_eofy_rec_cost,
                              p_eop_recoverable_cost   => l_eop_rec_cost,
                              p_eofy_salvage_value     => l_eofy_sal_val,
                              p_eop_salvage_value      => l_eop_sal_val,
                              p_mrc_sob_type_code      => p_mrc_sob_type_code,
                              p_adjusted_cost      => l_asset_fin_rec_new.adjusted_cost, -- ADDED by ZZZZ
                              p_used_by_adjustment     => 'ADJUSTMENT',
                              px_new_adjusted_cost     => l_asset_fin_rec_new.adjusted_cost,
                              px_new_raf               => l_asset_fin_rec_new.rate_adjustment_factor,
                              px_new_formula_factor    => l_asset_fin_rec_new.formula_factor,
                    p_log_level_rec       => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;
               end if;

               if (l_trans_rec.transaction_key = 'IM') then
                  l_asset_deprn_rec.impairment_reserve := l_asset_deprn_rec.impairment_reserve - l_asset_deprn_rec.deprn_reserve;
               end if;

               --Bug6978180 Added the following code to run for full retirement after extnd deprn.
               if nvl(l_trans_rec.transaction_key,'X') = 'ES' and
                                       p_trans_rec.transaction_type_code = 'FULL RETIREMENT'
                                       and nvl(l_asset_fin_rec_new.recoverable_cost,0) <>  0
                                       and fa_cache_pkg.fazccmt_record.rate_source_rule = 'CALCULATED'
                                       and p_asset_type_rec.asset_type  <> 'GROUP'
                                       and fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'COST' then

                  l_asset_fin_rec_new.adjusted_cost := l_asset_fin_rec_new.cost - nvl(l_asset_deprn_rec.deprn_reserve,0)
                                                       - nvl(l_asset_deprn_rec.impairment_reserve ,0);

               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '========== Recalc After Calling CALL_DEPRN_BASIS 1 ==========','', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.adjusted_cost', l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.rate_adjustment_factor', l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
               end if;

            else
               l_asset_fin_rec_new.adjusted_cost := l_asset_fin_rec_old.adjusted_cost;
               l_asset_fin_rec_new.rate_adjustment_factor := l_asset_fin_rec_old.rate_adjustment_factor;
               l_asset_fin_rec_new.formula_factor := l_asset_fin_rec_old.formula_factor;
            end if;

            if (p_log_level_rec.statement_level) then

               fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'impairment_reserve',
                   value   => p_asset_deprn_rec.impairment_reserve, p_log_level_rec => p_log_level_rec);

               fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'trx_type_code',
                   value   => p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
            end if;

            -- Fix for Bug #4940011.  Need to set correct adjusted cost for
            -- reinstatement of an impairment
            if (nvl(p_asset_deprn_rec.impairment_reserve,0) <> 0) and
               (p_trans_rec.transaction_type_code = 'REINSTATEMENT') then
               l_asset_fin_rec_new.adjusted_cost := l_impair_adj_cost;
               l_asset_fin_rec_new.rate_adjustment_factor := l_impair_raf;
               l_asset_fin_rec_new.formula_factor := l_impair_formula_factor;
            end if;

--tk_util.debug('l_asset_fin_rec_new.cost: '||to_char(l_asset_fin_rec_new.cost));
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Returned values from ',
                                'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost',
                                l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.rate_adjustment_factor',
                                l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.formula_factor',
                                l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
            end if;

         end if; -- (l_process_this_trx)

         --++++++ Don't want to calculate depreciation this period +++++++
         if (l_calc_deprn_flag) then
            l_temp_adjusted_cost := l_asset_fin_rec_new.adjusted_cost;
            l_asset_fin_rec_new.adjusted_cost := 0;
         end if;

         --
         -- Run Depreciation if:
         --  - next available transaction (in table) is NOT the same period
         --  - This is the last transaction to recalculate which is not in
         --    current period.
         --  - This is the last trnsaction because of the limit specified
         --    at BULK fetch above. (Inside of following if clause, try to get
         --    next transaction from database and determine if depreciation needs
         --    to be called or not.
         --
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Run Depreciation ', i, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 't_transaction_header_id.COUNT',
                             t_transaction_header_id.COUNT, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_period_rec.period_counter',
                             l_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_period_rec.period_counter',
                             p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
         end if;

         if (i < t_transaction_header_id.COUNT) then

            --
            -- Get period informatioin for next period
            -- If the next transaction is not in the current period, call cache.
            -- Otherwise, copy current one to next period info local variable.
            --
            -- Bug6190904: there is a case that following amortized adjustment needs to be processed
            --             before moving on to the next period depending on prorate convention setting.
            --             l_end_date stores end date of prorate period where dpis falls in and if
            --             subsequent trx's amort date is before that, we want to process the trx
            --             before moving on to the next period.
            if (t_transaction_date_entered(i+1) > l_period_rec.calendar_period_close_date) and
               (t_transaction_date_entered(i+1) > l_end_date) then

               if not GetPeriodInfo(to_number(to_char(t_transaction_date_entered(i+1), 'J')),
                                    p_asset_hdr_rec.book_type_code,
                                    p_mrc_sob_type_code,
                                    p_asset_hdr_rec.set_of_books_id,
                                    l_next_period_rec,
                                    p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;
               end if;

            else
               l_next_period_rec := l_period_rec;
            end if; -- (t_transaction_date_entered(i+1) > l_period_rec.calendar_period_close_date)

--tk_util.DumpPerRec(l_next_period_rec, to_char(i));

         end if; -- (i < t_transaction_header_id.COUNT)

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 8.0 : Checking whether to run Deprn ==========','', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, '++ i', i, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, '++ l_period_rec.period_counter', l_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, '++ l_next_period_rec.period_counter', l_next_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, '++ l_next_trx_trx_date_entered', to_char(l_next_trx_trx_date_entered,'MM/DD/YYYY'));
            fa_debug_pkg.add(l_calling_fn, '++ l_limit', l_limit, p_log_level_rec => p_log_level_rec);
         end if;
         --Bug6755649
         --If the transaction processed is partial retirement then save the calculated adj cost
         -- and cost frac.
         if l_trans_rec.transaction_type_code = G_TRX_TYPE_PAR_RET then
            if (p_asset_fin_rec_old.cost is null or p_asset_fin_rec_old.cost = 0) then
               l_old_cost_frac := null;
            else
               l_old_cost_frac := l_cost_retired / px_asset_fin_rec_new.cost;
            end if;

            l_cur_adj_cost := l_asset_fin_rec_new.adjusted_cost;
         end if;

         --Bug6755649 ends

         if ((i < t_transaction_header_id.COUNT) and
             (l_period_rec.period_counter < l_next_period_rec.period_counter)) or
            ((i = t_transaction_header_id.COUNT) and
             (i < l_limit) and
             (l_period_rec.period_counter < p_period_rec.period_counter)) or
            (i = l_limit) then
            --
            -- Find out from db that next transaction is in the same period or not.
            --
            if (i = l_limit) then
               OPEN c_get_next_ths (t_transaction_date_entered(i), t_date_effective(i));
               FETCH c_get_next_ths INTO l_next_trx_trx_date_entered,
                                             l_next_trx_date_effective;
               CLOSE c_get_next_ths;

               if (l_next_trx_trx_date_entered is not null) then
                  if not GetPeriodInfo(to_number(to_char(l_next_trx_trx_date_entered, 'J')),
                                       p_asset_hdr_rec.book_type_code,
                                       p_mrc_sob_type_code,
                                       p_asset_hdr_rec.set_of_books_id,
                                       l_next_period_rec,
                                       p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                         'GetPeriodInfo', p_log_level_rec => p_log_level_rec);
                     end if;

                     raise calc_failed;
                  end if;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Fetched next transaction information ', l_limit, p_log_level_rec => p_log_level_rec);
               end if;

            end if; -- (i = l_limit)

            --
            -- If there is no subsequent transaction or next transaction
            -- is in different period, complete runnning depreciation to close
            -- previous period or perivious period of the period that next transaction
            -- exists.
            --
            -- Bug3548724: Added l_is_this_void.  Skip faxcde call if current trx is void.
            --

            -- Fix for Bug #6190904.
            if (p_trans_rec.transaction_type_code like '%RETIREMENT') then

               -- Bug 5726160
               declare
                 cursor c_depreciate_flag is
                   select bk.depreciate_flag
                   from fa_books bk
                       ,fa_deprn_periods dp
                   where bk.asset_id = p_asset_hdr_rec.asset_id
                     and bk.book_type_code = p_asset_hdr_rec.book_type_code
                     and bk.date_effective <= nvl(dp.period_close_date, sysdate)
                     and dp.book_type_code = p_asset_hdr_rec.book_type_code
                     and dp.period_counter = l_period_rec.period_counter
                   order by bk.date_effective desc;
               begin
                   open c_depreciate_flag;
                   fetch c_depreciate_flag into l_depreciate_flag;
                   if (c_depreciate_flag%notfound) then
                      if (l_asset_fin_rec_new.depreciate_flag = 'YES')  then
                         l_depreciate_flag := 'YES';
                      else
                         l_depreciate_flag := 'NO';
                      end if;
                   end if;
                   close c_depreciate_flag;
               exception when others then null;
               end;
            else
               l_depreciate_flag := l_asset_fin_rec_new.depreciate_flag;
            end if;


            if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, '========== Recalc Step 8.5 :Checking whether to run Deprn ==========','', p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_next_trx_trx_date_entered', to_char(l_next_trx_trx_date_entered,'MM/DD/YYYY'));
                fa_debug_pkg.add(l_calling_fn, 'l_next_period_rec.period_counter', l_next_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_period_rec.period_counter', l_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_old.depreciate_flag', l_asset_fin_rec_old.depreciate_flag, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.depreciate_flag', l_asset_fin_rec_new.depreciate_flag, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_depreciate_flag', l_depreciate_flag, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve', l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'px_asset_fin_rec_new.depreciate_flag', px_asset_fin_rec_new.depreciate_flag, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_depreciate_flag', l_depreciate_flag, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_energy_member', l_energy_member, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_is_this_void', l_is_this_void, p_log_level_rec => p_log_level_rec);
            end if;

            if (l_next_trx_trx_date_entered is null or
                l_next_period_rec.period_counter > l_period_rec.period_counter) and
               (not(l_is_this_void)) and
               (not(l_energy_member)) and
               (px_asset_fin_rec_new.depreciate_flag = 'YES') -- Bug6190904 for case5: Need to replace a line above
               then

               l_dpr_in.y_begin := l_period_rec.fiscal_year;
               l_dpr_in.p_cl_begin := l_period_rec.period_num;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Depreciation starts from period of ', l_dpr_in.p_cl_begin, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'and year of ', l_dpr_in.y_begin, p_log_level_rec => p_log_level_rec);
               end if;

               if (i < t_transaction_header_id.COUNT) or (i = l_limit) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Depreciate until ', 'Next Transaction', p_log_level_rec => p_log_level_rec);
                  end if;
                  --
                  -- Find how many periods to depreciate until next transaction headers
                  -- Set FA_STD_TYPES.dpr_struct for depreciation(faxcde) call.
                  --
                  if (nvl(l_next_period_rec.period_counter, p_period_rec.period_counter) = 1) then
                     l_dpr_in.y_end := nvl(l_next_period_rec.fiscal_year, p_period_rec.fiscal_year) - 1;
                     l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                  else
                     l_dpr_in.y_end := nvl(l_next_period_rec.fiscal_year, p_period_rec.fiscal_year);
                     l_dpr_in.p_cl_end := nvl(l_next_period_rec.period_num, p_period_rec.period_num) - 1;
                  end if;

               elsif (i = t_transaction_header_id.COUNT) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Depreciate until ', 'Current period', p_log_level_rec => p_log_level_rec);
                  end if;
                  --
                  -- This is the last transaction to process.  So depreciate
                  -- until last period.
                  --
                  if (p_period_rec.period_num = 1) then
                     l_dpr_in.y_end := p_period_rec.fiscal_year - 1;
                     l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                  else
                     l_dpr_in.y_end := p_period_rec.fiscal_year;
                     l_dpr_in.p_cl_end := p_period_rec.period_num - 1;
                  end if;

               end if; -- (i < t_transaction_header_id.COUNT) or (i = l_limit)

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Depreciation will end at period of ', l_dpr_in.p_cl_end, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'and year of ', l_dpr_in.y_end, p_log_level_rec => p_log_level_rec);
               end if;

               if (l_period_rec.period_num <> 1) then
                  l_dpr_in.deprn_rounding_flag := 'ADJ';
               end if;

               l_dpr_in.prior_fy_exp := l_asset_deprn_rec.prior_fy_expense;
               l_dpr_in.ytd_deprn := l_asset_deprn_rec.ytd_deprn;
               l_dpr_in.deprn_rsv := l_asset_deprn_rec.deprn_reserve;
               l_dpr_in.adj_cost := l_asset_fin_rec_new.adjusted_cost;
               l_dpr_in.eofy_reserve := l_asset_fin_rec_new.eofy_reserve;
               l_dpr_in.rate_adj_factor := l_asset_fin_rec_new.rate_adjustment_factor;
               l_dpr_in.formula_factor := l_asset_fin_rec_new.formula_factor;
               l_dpr_in.super_group_id := l_asset_fin_rec_new.super_group_id;
               l_dpr_in.cost := l_asset_fin_rec_new.cost;
               --Bug 6510877
               l_dpr_in.adj_capacity := l_asset_fin_rec_new.adjusted_capacity;

               -- manual override
               if fa_cache_pkg.fa_deprn_override_enabled then
                  l_dpr_in.update_override_status := TRUE;
               end if;

               -- Bug fix 5893429
               if l_trans_rec.transaction_type_code = G_TRX_TYPE_PAR_RET then
                  if (p_asset_fin_rec_old.cost is null or p_asset_fin_rec_old.cost = 0) then
                     l_cost_frac := null;
                  else
                    l_cost_frac := l_cost_retired / px_asset_fin_rec_new.cost;
                  end if;
               else
                  l_cost_frac := null;
               end if;

               --Bug6755649
               --Added a condition to check if after all the transactions have been processed the value
               --of adjusted cost is same as the one calculated during partial retirement then
               --populate cost fraction with the old value.
               if (l_asset_fin_rec_new.adjusted_cost = l_cur_adj_cost) and (i = t_transaction_header_id.COUNT)then
                        l_cost_frac := l_old_cost_frac;
               end if;
               --Bug6755649 ends

               l_dpr_in.cost_frac := l_cost_frac;

               fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.cost_frac', l_dpr_in.cost_frac, p_log_level_rec => p_log_level_rec);
                -- End of bug fix 5893429


               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '========== Recalc Before Calling faxcde 2 ==========','', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.cost',l_dpr_in.cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.adj_cost',l_dpr_in.adj_cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.rate_adj_factor',l_dpr_in.rate_adj_factor, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.prior_fy_exp',l_dpr_in.prior_fy_exp, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.eofy_reserve',l_dpr_in.eofy_reserve, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_in.deprn_rsv',l_dpr_in.deprn_rsv, p_log_level_rec => p_log_level_rec);
               end if;

               -- 8211842 : faxcde will look for POSTED depreciation overrides
               -- for periods before override_period_counter
               l_dpr_in.override_period_counter := l_override_limit_period_rec.period_counter;

               --
               -- +++++ faxcde will not be called if adjusted_cost is 0.
               --
               if not FA_CDE_PKG.faxcde(l_dpr_in,
                                        l_dpr_arr,
                                        l_dpr_out,
                                        l_running_mode, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;
               end if;


               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '========== Recalc After Calling faxcde 2 ==========','', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ Depreciation started from YEAR : PERIOD ', l_dpr_in.y_begin ||' : '|| l_dpr_in.p_cl_begin, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ Depreciation ended at YEAR : PERIOD ', l_dpr_in.y_end   ||' : '|| l_dpr_in.p_cl_end, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ l_dpr_out.new_adj_cost', l_dpr_out.new_adj_cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_ytd_deprn', l_dpr_out.new_ytd_deprn, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_deprn_rsv', l_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost',l_asset_fin_rec_new.adjusted_cost , p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_recoverable_cost',l_asset_fin_rec_new.adjusted_recoverable_cost , p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '++ AFTER: l_asset_deprn_rec.deprn_reserve (+ +)', l_asset_deprn_rec.deprn_reserve);
               end if;


               -- manual override
               if fa_cache_pkg.fa_deprn_override_enabled then
                  p_trans_rec.deprn_override_flag := l_dpr_out.deprn_override_flag;
               end if;

               if (l_asset_fin_rec_new.adjusted_cost <> 0)or
--bug fix 4731687 added for the case when due to deprn limit adj_rec_cost is <>0 and adj_cost is 0
                  (l_asset_fin_rec_new.adjusted_recoverable_cost <> 0) then
                  l_asset_fin_rec_new.reval_amortization_basis := l_dpr_out.new_reval_amo_basis;
                  l_asset_deprn_rec.deprn_reserve := l_dpr_out.new_deprn_rsv;
                  l_asset_deprn_rec.ytd_deprn := l_dpr_out.new_ytd_deprn;
                  l_asset_deprn_rec.reval_deprn_reserve := l_dpr_out.new_reval_rsv;
-- bug 5336669
--                l_asset_fin_rec_new.adjusted_capacity := l_dpr_out.new_adj_capacity;
--
                  l_asset_deprn_rec.ltd_production := l_dpr_out.new_ltd_prod;
                  l_asset_fin_rec_new.eofy_reserve := l_dpr_out.new_eofy_reserve;

                  l_asset_deprn_rec.prior_fy_expense := l_dpr_out.new_prior_fy_exp;
                  l_asset_deprn_rec.bonus_deprn_amount := l_dpr_out.bonus_deprn_exp;
                  l_asset_deprn_rec.bonus_deprn_reserve := l_dpr_out.new_bonus_deprn_rsv;
                  l_asset_deprn_rec.prior_fy_bonus_expense := l_dpr_out.new_prior_fy_bonus_exp;
                  l_asset_deprn_rec.impairment_amount := l_dpr_out.impairment_exp;
                  l_asset_deprn_rec.impairment_reserve := l_dpr_out.new_impairment_rsv;
               end if;

               --++++++ Put adjusted cost back ++++++
               l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
               l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;

               l_out_deprn_exp := l_dpr_out.deprn_exp;
               l_out_reval_exp := l_dpr_out.reval_exp;
               l_out_reval_amo := l_dpr_out.reval_amo;
               l_out_prod := l_dpr_out.prod;
               l_out_ann_adj_exp := l_dpr_out.ann_adj_exp;
               l_out_ann_adj_reval_exp := l_dpr_out.ann_adj_reval_exp;
               l_out_ann_adj_reval_amo := l_dpr_out.ann_adj_reval_amo;
               l_out_bonus_rate_used := l_dpr_out.bonus_rate_used;
               l_out_full_rsv_flag := l_dpr_out.full_rsv_flag;
               l_out_life_comp_flag := l_dpr_out.life_comp_flag;
               l_out_deprn_override_flag := l_dpr_out.deprn_override_flag;

               l_eop_rec_cost := l_asset_fin_rec_new.recoverable_cost;
               l_eop_sal_val := l_asset_fin_rec_new.salvage_value;

               --+++++++++ Call member level maintenance for tracking +++++++
               if nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then

                  if not FA_TRACK_MEMBER_PVT.member_eofy_rsv(p_asset_hdr_rec => p_asset_hdr_rec,
                                                             p_dpr_in => l_dpr_in,
                                                             p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                         'FA_TRACK_MEMBER_PVT.member_eofy_rsv',  p_log_level_rec => p_log_level_rec);
                     end if;

                     raise calc_failed;

                  end if;

               end if; -- nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE'

            elsif (l_energy_member) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'This is energy member ',
                                   'No member level deprn calculation', p_log_level_rec => p_log_level_rec);
               end if;



            else
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'There is another transactions to process this period',
                                   'or this is current period', p_log_level_rec => p_log_level_rec);
               end if;

            end if; -- (l_next_trx_period_counter is null or

         end if; -- (not ((i < l_limit) and

         if (l_calc_deprn_flag) then
            l_asset_fin_rec_new.adjusted_cost := l_temp_adjusted_cost;
         end if;

         l_process_this_trx := TRUE;


         if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '++ calc_catchup: p_trans_rec.transaction_type_code', p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
         end if;

         -- Bug 5726160
         if p_running_mode = fa_std_types.FA_DPR_CATCHUP then

           if p_trans_rec.transaction_type_code = 'REINSTATEMENT' then

              if l_retirement_thid = l_trans_rec.transaction_header_id then

                 l_catchup_begin_deprn_rec.deprn_reserve := l_asset_deprn_rec.deprn_reserve;
                 l_catchup_begin_deprn_rec.bonus_deprn_reserve := l_asset_deprn_rec.bonus_deprn_reserve;
                 l_catchup_begin_deprn_rec.impairment_reserve := l_asset_deprn_rec.impairment_reserve;

                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('    '||l_calling_fn, 'SETTING l_catchup_begin_deprn_rec.deprn_reserve (+ +)', l_catchup_begin_deprn_rec.deprn_reserve);
                 end if;

              end if;

           elsif p_trans_rec.transaction_type_code like '%RETIREMENT' then

              if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('    '||l_calling_fn, '++ calc_catchup: l_trans_rec.transaction_type_code 1...', l_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add('    '||l_calling_fn, '++ calc_catchup: l_entered_reserve 1...', l_entered_reserve, p_log_level_rec => p_log_level_rec);
              end if;

              if l_trans_rec.transaction_type_code = 'ADDITION' and l_entered_reserve <> 0 then

                  -- reset deprn_reserve to the deprn_reserve in fa_deprn_summary
                  select deprn_reserve
                  into l_temp_reserve
                  from fa_deprn_summary ds1
                  where ds1.asset_id = p_asset_hdr_rec.asset_id
                    and ds1.book_type_code = p_asset_hdr_rec.book_type_code
                    and ds1.period_counter =
                        (select ds2.period_counter + 1
                         from fa_deprn_summary ds2
                         where ds2.asset_id = p_asset_hdr_rec.asset_id
                           and ds2.book_type_code = p_asset_hdr_rec.book_type_code
                           and ds2.deprn_source_code = 'BOOKS');

                  l_asset_deprn_rec.deprn_reserve := l_temp_reserve;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add('    '||l_calling_fn, '++   RESETTING l_asset_deprn_rec.deprn_reserve (+ +) ...', l_asset_deprn_rec.deprn_reserve);
                  end if;

              end if;

           end if;

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('    '||l_calling_fn, 'ytd_deprn', l_asset_deprn_rec.ytd_deprn, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('    '||l_calling_fn, 'deprn_reserve', l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, '++ AFTER 2: l_asset_deprn_rec.deprn_reserve (+ +)', l_asset_deprn_rec.deprn_reserve);
         end if;

      END LOOP; -- FOR i IN 1..t_transaction_header_id.COUNT LOOP

      EXIT WHEN c_get_ths_adj%NOTFOUND;

   END LOOP; -- for transactions

   CLOSE c_get_ths_adj;

   if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ Recalc Step 9 : End of c_get_ths_adj LOOP ------------------------------------------------','', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '+++++++++++ Recalc Step 9 : BEFORE calling CALL_DEPRN_BASIS ++++++++++','', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.cost',l_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.adjusted_cost',l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.rate_adjustment_factor',l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.formula_factor',l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.prior_deprn_limit_amount',l_asset_fin_rec_new.prior_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.prior_deprn_limit',l_asset_fin_rec_new.prior_deprn_limit, p_log_level_rec => p_log_level_rec);
   end if;

   -- Call Depreciable Basis Rule for Formula/NBV Basis
   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
              (p_event_type             => 'AMORT_ADJ3',
               p_asset_fin_rec_new      => l_asset_fin_rec_new,
               p_asset_fin_rec_old      => l_asset_fin_rec_new,
               p_asset_hdr_rec          => p_asset_hdr_rec,
               p_asset_type_rec         => p_asset_type_rec,
               p_asset_deprn_rec        => l_asset_deprn_rec,
               p_trans_rec              => p_trans_rec,
               p_period_rec             => l_period_rec,
               p_adjusted_cost          => l_asset_fin_rec_new.adjusted_cost,
               p_current_total_rsv      => l_asset_deprn_rec.deprn_reserve,
               p_current_rsv            => l_asset_deprn_rec.deprn_reserve -
                                           l_asset_deprn_rec.bonus_deprn_reserve - nvl(l_asset_deprn_rec.impairment_reserve,0),
               p_current_total_ytd      => l_asset_deprn_rec.ytd_deprn,
               p_hyp_basis              => l_asset_fin_rec_new.adjusted_cost,
               p_hyp_total_rsv          => l_asset_deprn_rec_raf.deprn_reserve,
               p_hyp_rsv                => l_asset_deprn_rec_raf.deprn_reserve -
                                           l_asset_deprn_rec_raf.bonus_deprn_reserve - nvl(l_asset_deprn_rec_raf.impairment_reserve,0),
               p_eofy_recoverable_cost  => l_eofy_rec_cost,
               p_eop_recoverable_cost   => l_eop_rec_cost,
               p_eofy_salvage_value     => l_eofy_sal_val,
               p_eop_salvage_value      => l_eop_sal_val,
               p_mrc_sob_type_code      => p_mrc_sob_type_code,
               p_used_by_adjustment     => 'ADJUSTMENT',
               px_new_adjusted_cost     => l_asset_fin_rec_new.adjusted_cost,
               px_new_raf               => l_asset_fin_rec_new.rate_adjustment_factor,
               px_new_formula_factor    => l_asset_fin_rec_new.formula_factor,
               p_log_level_rec => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Error calling',
                          'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_failed;
   end if; -- (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '++ Recalc Step 10 : AFTER calling CALL_DEPRN_BASIS ------------------------------------------------','', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.cost',l_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.adjusted_cost',l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.rate_adjustment_factor',l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.formula_factor',l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Returned values from ',
                                     'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS AMORT_ADJ3', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost',
                                     l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.rate_adjustment_factor',
                                     l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.formula_factor',
                                     l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
   end if;

   px_asset_fin_rec_new.cost := l_asset_fin_rec_new.cost;
   px_asset_fin_rec_new.recoverable_cost:= l_asset_fin_rec_new.recoverable_cost;
   px_asset_fin_rec_new.adjusted_recoverable_cost:= l_asset_fin_rec_new.adjusted_recoverable_cost;
   px_asset_fin_rec_new.salvage_value := l_asset_fin_rec_new.salvage_value;
   px_asset_fin_rec_new.allowed_deprn_limit_amount := l_asset_fin_rec_new.allowed_deprn_limit_amount;
   px_asset_fin_rec_new.percent_salvage_value := l_asset_fin_rec_new.percent_salvage_value;
   px_asset_fin_rec_new.allowed_deprn_limit := l_asset_fin_rec_new.allowed_deprn_limit;
   px_asset_fin_rec_new.unrevalued_cost := l_asset_fin_rec_new.unrevalued_cost;
   px_asset_fin_rec_new.production_capacity := l_asset_fin_rec_new.production_capacity;
   px_asset_fin_rec_new.reval_ceiling := l_asset_fin_rec_new.reval_ceiling;
   px_asset_fin_rec_new.adjusted_cost := l_asset_fin_rec_new.adjusted_cost;
   px_asset_fin_rec_new.rate_adjustment_factor := l_asset_fin_rec_new.rate_adjustment_factor;
   px_asset_fin_rec_new.reval_amortization_basis := l_asset_fin_rec_new.reval_amortization_basis;
   px_asset_fin_rec_new.adjusted_capacity := l_asset_fin_rec_new.adjusted_capacity;
   px_asset_fin_rec_new.formula_factor := l_asset_fin_rec_new.formula_factor;
   px_asset_fin_rec_new.eofy_reserve := l_asset_fin_rec_new.eofy_reserve;

   --
   -- When returning catch up expenses, amounts in p_asset_deprn_rec_adj need to be
   -- excluded because it was included at beginning to find correct catchup but
   -- these amounts cannot be expensed in this period.
   --
   -- Bug3548724:if this is addition, there is no need to back out adj reserve
   -- because it is reserve from previous period
   --

   -- Japan Bug 6645061 use period_counter_fully_extended for assets which
   -- have extended_deprn_flag set.
   begin
      -- Bug 8211842: Use pc_fully_extended only if the asset has started
      -- extended depreciation
      if p_period_rec.period_counter >=
              nvl(p_asset_fin_rec_old.extended_depreciation_period,999999) then
         l_start_extended := 'Y';
      end if;

      select decode(nvl(p_asset_fin_rec_old.extended_deprn_flag,'N'),
                    'Y', decode(l_start_extended,
                                'Y', p_asset_fin_rec_old.period_counter_fully_extended,
                                     p_asset_fin_rec_old.period_counter_fully_reserved),
                    p_asset_fin_rec_old.period_counter_fully_reserved),
             decode(nvl(l_asset_fin_rec_new.extended_deprn_flag,'N'),
                    'Y', decode(l_start_extended,
                                'Y', l_asset_fin_rec_new.period_counter_fully_extended,
                                     l_asset_fin_rec_new.period_counter_fully_reserved),
                    l_asset_fin_rec_new.period_counter_fully_reserved)
      into   l_old_pc_reserved,
             l_new_pc_reserved
      from dual;

   end;

   -- bug 5383699 nvl clause added
   if (l_old_pc_reserved is not null
       and l_new_pc_reserved is not null) then

      -- Fix for Bug #6403182.  If the period you are backdating the retirement
      -- too is before the period that the retirement occurs in, then you
      -- need to backout some reserve.
      -- Japan Bug 6645061
      if (nvl(l_period_rec.period_counter, 9999999) <= l_old_pc_reserved) then

         x_deprn_expense := nvl(l_asset_deprn_rec.deprn_reserve, 0) -
                            nvl(p_asset_deprn_rec.deprn_reserve, 0);
         x_bonus_expense := nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                            nvl(p_asset_deprn_rec.bonus_deprn_reserve, 0);
         x_impairment_expense := nvl(l_asset_deprn_rec.impairment_reserve, 0) -
                                 nvl(p_asset_deprn_rec.impairment_reserve, 0);
      else
         -- Bug 5377543
         x_deprn_expense := 0;
         x_bonus_expense := 0;
         x_impairment_expense := 0;
      end if;

   elsif (p_trans_rec.transaction_type_code = 'ADDITION') then
      x_deprn_expense := nvl(l_asset_deprn_rec.deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec.deprn_reserve, 0);
      x_bonus_expense := nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec.bonus_deprn_reserve, 0);
      x_impairment_expense := nvl(l_asset_deprn_rec.impairment_reserve, 0) -
                              nvl(p_asset_deprn_rec.impairment_reserve, 0);

   elsif (p_trans_rec.transaction_type_code = 'REINSTATEMENT') then
     -- Bug 5726160
     if p_running_mode = fa_std_types.FA_DPR_CATCHUP then
      x_deprn_expense := nvl(l_asset_deprn_rec.deprn_reserve, 0) -
                         nvl(l_catchup_begin_deprn_rec.deprn_reserve, 0);
      x_bonus_expense := nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                         nvl(l_catchup_begin_deprn_rec.bonus_deprn_reserve, 0);
      x_impairment_expense := nvl(l_asset_deprn_rec.impairment_reserve, 0) -
                              nvl(l_catchup_begin_deprn_rec.impairment_reserve, 0);
     else
      x_deprn_expense := nvl(l_asset_deprn_rec.deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec.deprn_reserve, 0);
      x_bonus_expense := nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec.bonus_deprn_reserve, 0);
      x_impairment_expense := nvl(l_asset_deprn_rec.impairment_reserve, 0) -
                              nvl(p_asset_deprn_rec.impairment_reserve, 0);
     end if;

   else
      x_deprn_expense := nvl(l_asset_deprn_rec.deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec.deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec_adj.deprn_reserve, 0);
      x_bonus_expense := nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec.bonus_deprn_reserve, 0) -
                         nvl(p_asset_deprn_rec_adj.bonus_deprn_reserve, 0);
      x_impairment_expense := nvl(l_asset_deprn_rec.impairment_reserve, 0) -
                              nvl(p_asset_deprn_rec.impairment_reserve, 0) -
                              nvl(p_asset_deprn_rec_adj.impairment_reserve, 0);
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '++++ Recalc Step 11 : Set x_deprn_expense ','...', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ p_asset_fin_rec_old.period_counter_fully_reserved', p_asset_fin_rec_old.period_counter_fully_reserved, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ l_asset_fin_rec_new.period_counter_fully_reserved', l_asset_fin_rec_new.period_counter_fully_reserved, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ ++ p_asset_deprn_rec.deprn_reserve (INPUT)', p_asset_deprn_rec.deprn_reserve);
      fa_debug_pkg.add(l_calling_fn, '++ ++ p_asset_deprn_rec_adj.deprn_reserve (INPUT)', p_asset_deprn_rec_adj.deprn_reserve);
      fa_debug_pkg.add(l_calling_fn, '++ ++ l_asset_deprn_rec.deprn_reserve (NEW)', l_asset_deprn_rec.deprn_reserve);
      fa_debug_pkg.add(l_calling_fn, '++ ++ x_deprn_expense (INPUT-NEW=OUTPUT)', x_deprn_expense);
   end if;

   --+++++++++ Call member level maintenance for tracking +++++++
   if nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then

      if not FA_TRACK_MEMBER_PVT.update_member_books(p_trans_rec=> p_trans_rec,
                                                     p_asset_hdr_rec => p_asset_hdr_rec,
                                                     p_dpr_in => l_dpr_in,
                                                     p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_TRACK_MEMBER_PVT.update_member_books',  p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_failed;
      end if;

      fa_track_member_pvt.p_track_member_eofy_table.delete;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fa_track_member_pvt.p_track_member_eofy_table',
                                        'deleted',  p_log_level_rec => p_log_level_rec);
      end if;

   end if; -- nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE'

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End',
                       x_deprn_expense||':'||x_bonus_expense, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
  WHEN invalid_trx_to_overlap THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'invalid_trx_to_overlap', p_log_level_rec => p_log_level_rec);
    end if;

    if c_get_ths_adj%ISOPEN then
      CLOSE c_get_ths_adj;
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                            name       => 'FA_INVALID_TRX_TO_OVERLAP', p_log_level_rec => p_log_level_rec);
    return false;
  WHEN calc_failed THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'calc_failed', p_log_level_rec => p_log_level_rec);
    end if;

    if c_get_ths_adj%ISOPEN then
      CLOSE c_get_ths_adj;
    end if;

    -- Bug 8211842
    if c_get_retirement_pdate%ISOPEN then
      CLOSE c_get_retirement_pdate;
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    if c_check_overlap%ISOPEN then
      CLOSE c_check_overlap;
    end if;

    if c_get_ths_adj%ISOPEN then
      CLOSE c_get_ths_adj;
    end if;

    if c_get_next_ths%ISOPEN then
      CLOSE c_get_next_ths;
    end if;

    if c_get_retirement%ISOPEN then
      CLOSE c_get_retirement;
    end if;

    -- Bug 8211842
    if c_get_retirement_pdate%ISOPEN then
      CLOSE c_get_retirement_pdate;
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    raise;
END Recalculate;

---------------------------------------------------------------------------

FUNCTION faxama
         (px_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec        IN            FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec       IN            FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec        IN            FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec       IN            FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old    IN            FA_API_TYPES.asset_fin_rec_type,
          p_asset_fin_rec_adj    IN            FA_API_TYPES.asset_fin_rec_type default null,
          px_asset_fin_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec      IN            FA_API_TYPES.asset_deprn_rec_type,
          p_asset_deprn_rec_adj  IN            FA_API_TYPES.asset_deprn_rec_type default null,
          p_period_rec           IN            FA_API_TYPES.period_rec_type,
          p_mrc_sob_type_code    IN            VARCHAR2,
          p_running_mode         IN            NUMBER,
          p_used_by_revaluation  IN            NUMBER,
          p_reclassed_asset_id                 NUMBER default null,
          p_reclass_src_dest                   VARCHAR2 default null,
          p_reclassed_asset_dpis               DATE default null,
          x_deprn_exp               OUT NOCOPY NUMBER,
          x_bonus_deprn_exp         OUT NOCOPY NUMBER,
          x_impairment_exp          OUT NOCOPY NUMBER
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   l_calling_fn           varchar2(50) := 'FA_AMORT_PVT.faxama';
   l_reval_deprn_rsv_adj  number :=0;
   l_afn_zero             number:=0;

   l_asset_fin_rec_adj    FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_new   FA_API_TYPES.asset_deprn_rec_type; -- Added to call calc_raf_adj

   calc_err   EXCEPTION;

/*
   err number;

   cursor c_get_profiler is
     select runid,
            run_date,
            run_comment
     from plsql_profiler_runs;
*/

begin <<faxama>>
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-+++++-');
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_type_rec.asset_type||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;


--   err:=DBMS_PROFILER.START_PROFILER ('faxama:'||to_char(sysdate,'dd-Mon-YYYY hh:mi:ss'));

   X_deprn_exp       := 0;
   X_bonus_deprn_exp := 0;
   X_impairment_exp  := 0;

   if (p_asset_type_rec.asset_type='CIP') then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Nothing to calculate with CIP asset',' ', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Exiting faxama immediately',
         p_asset_type_rec.asset_type||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      end if;
      return true;

      --FA_SRVR_MSG.ADD_MESSAGE
      --      (CALLING_FN => 'FA_AMORT_PKG.faxama',
      --       NAME       => 'FA_AMT_CIP_NOT_ALLOWED',
      --       TOKEN1     => 'TYPE',
      --       VALUE1     => 'Amortized',  p_log_level_rec => p_log_level_rec);
      --return FALSE;
   end if;

   if (p_log_level_rec.statement_level) then
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxama',
                element => 'First asset_type',
                value   => p_asset_type_rec.asset_type, p_log_level_rec => p_log_level_rec);
   end if;

--
--  Function call faxraf may be removed.
--
--     if (not faxraf
--            (px_trans_rec           => px_trans_rec,
--             p_asset_hdr_rec        => p_asset_hdr_rec,
--             p_asset_desc_rec       => p_asset_desc_rec,
--             p_asset_cat_rec        => p_asset_cat_rec,
--             p_asset_type_rec       => p_asset_type_rec,
--             p_asset_fin_rec_old    => p_asset_fin_rec_old,
--             px_asset_fin_rec_new   => px_asset_fin_rec_new,
--             p_asset_deprn_rec      => p_asset_deprn_rec,
--             p_period_rec           => p_period_rec,
--             px_deprn_exp           => x_deprn_exp,
--             px_bonus_deprn_exp     => x_bonus_deprn_exp,
--             px_impairment_exp      => x_impairment_exp,
--             px_reval_deprn_rsv_adj => l_reval_deprn_rsv_adj,
--             p_mrc_sob_type_code    => p_mrc_sob_type_code,
--             p_running_mode         => p_running_mode,
--             p_used_by_revaluation  => p_used_by_revaluation)) then
--       raise calc_err;
--     end if;

--tk_util.DumpTrxRec(px_trans_rec, 'px_trans_rec');
--tk_util.DumpFinRec(p_asset_fin_rec_old, 'old fin_rec');
--tk_util.DumpFinRec(p_asset_fin_rec_adj, 'adj fin_rec');
--tk_util.DumpFinRec(px_asset_fin_rec_new, 'new_fin_rec');
--tk_util.DumpDeprnRec(p_asset_deprn_rec, 'old deprn');
--tk_util.DumpDeprnRec(p_asset_deprn_rec_adj, 'adj deprn');

    /*Bug#8652791- reverted changes done for #8417751 */
    if (px_trans_rec.transaction_type_code = 'REINSTATEMENT') then
     --Bug6401134
     px_asset_fin_rec_new := p_asset_fin_rec_old;
   end if;

   --
   -- Energy: Need to reinstate member reserve entry cre
   if (nvl(p_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE') and    -- ENERGY
      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and  -- ENERGY
      (px_trans_rec.transaction_type_code = 'REINSTATEMENT') then -- ENERGY
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'calling function ',
                          'FA_AMORT_PVT.calc_raf_adj_cost',  p_log_level_rec => p_log_level_rec);
      end if;

      l_asset_deprn_rec_new := p_asset_deprn_rec;
      --Bug6401134 commented this code ass it has already been written before the if condition
     -- px_asset_fin_rec_new := p_asset_fin_rec_old;
      px_asset_fin_rec_new.cost := p_asset_fin_rec_old.cost + nvl(p_asset_fin_rec_adj.cost, 0);
      /* Added if condition for bug 8484007 */
      if (nvl(px_asset_fin_rec_new.percent_salvage_value,0) > 0) then
         px_asset_fin_rec_new.salvage_value := px_asset_fin_rec_new.cost * px_asset_fin_rec_new.percent_salvage_value;
      else
         px_asset_fin_rec_new.salvage_value := p_asset_fin_rec_old.salvage_value + nvl(p_asset_fin_rec_adj.salvage_value, 0);
      end if;
      px_asset_fin_rec_new.unrevalued_cost := px_asset_fin_rec_new.cost;
      /* End 8484007 */
--Bug8425794 / 8244128 px_asset_fin_rec_new.salvage_value := px_asset_fin_rec_new.cost * .1;
      px_asset_fin_rec_new.recoverable_cost := px_asset_fin_rec_new.cost - px_asset_fin_rec_new.salvage_value;
      px_asset_fin_rec_new.adjusted_recoverable_cost := px_asset_fin_rec_new.recoverable_cost;

      if not FA_AMORT_PVT.calc_raf_adj_cost
                           (p_trans_rec           => px_trans_rec,
                            p_asset_hdr_rec       => p_asset_hdr_rec,
                            p_asset_desc_rec      => p_asset_desc_rec,
                            p_asset_type_rec      => p_asset_type_rec,
                            p_asset_fin_rec_old   => p_asset_fin_rec_old,
                            px_asset_fin_rec_new  => px_asset_fin_rec_new,
                            p_asset_deprn_rec_adj => p_asset_deprn_rec_adj,
                            p_asset_deprn_rec_new => l_asset_deprn_rec_new,
                            p_period_rec          => p_period_rec,
--                            p_group_reclass_options_rec => p_group_reclass_options_rec,
                            p_mrc_sob_type_code   => p_mrc_sob_type_code
                                      , p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;
   else
      populate_fin_rec(
                p_trans_rec          => px_trans_rec,
                p_asset_fin_rec_old  => p_asset_fin_rec_old,
                p_asset_fin_rec_adj  => p_asset_fin_rec_adj,
                p_asset_fin_rec_new  => px_asset_fin_rec_new,
                x_asset_fin_rec_adj  => l_asset_fin_rec_adj,
                p_log_level_rec => p_log_level_rec);

      if (not Recalculate(
                p_trans_rec            => px_trans_rec,
                p_asset_hdr_rec        => p_asset_hdr_rec,
                p_asset_type_rec       => p_asset_type_rec,
                p_asset_desc_rec       => p_asset_desc_rec,
                p_asset_fin_rec_old    => p_asset_fin_rec_old,
                p_asset_fin_rec_adj    => l_asset_fin_rec_adj,
                p_period_rec           => p_period_rec,
                px_asset_fin_rec_new   => px_asset_fin_rec_new,
                p_asset_deprn_rec      => p_asset_deprn_rec,
                p_asset_deprn_rec_adj  => p_asset_deprn_rec_adj,
                x_deprn_expense        => x_deprn_exp,
                x_bonus_expense        => x_bonus_deprn_exp,
                x_impairment_expense   => x_impairment_exp,
                p_running_mode         => p_running_mode,
                p_used_by_revaluation  => p_used_by_revaluation,
                p_reclassed_asset_id   => p_reclassed_asset_id,
                p_reclass_src_dest     => p_reclass_src_dest,
                p_reclassed_asset_dpis => p_reclassed_asset_dpis,
                p_source_transaction_type_code
                                       => px_trans_rec.transaction_type_code,
                p_mrc_sob_type_code    => p_mrc_sob_type_code,
                p_calling_fn           => l_calling_fn,
                p_log_level_rec => p_log_level_rec)) then
         raise calc_err;
      end if;

   end if;
--tk_util.DumpFinRec(px_asset_fin_rec_new, 'Nfaxama');

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', p_asset_type_rec.asset_type||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;
--tk_util.debug('-+++++-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');
--tk_util.debug('-');

--   err:=DBMS_PROFILER.STOP_PROFILER;

/*
for r_get_profiler in c_get_profiler loop
null;
--tk_util.debug('runid: '||to_char(r_get_profiler.runid));
--tk_util.debug('run_date: '||to_char(r_get_profiler.run_date, 'DD-MON-YYYY HH24:MI:SS'));
--tk_util.debug('run_comment: '||r_get_profiler.run_comment);
end loop;
*/

   return TRUE;

exception
   when calc_err then
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'calc_err', p_log_level_rec => p_log_level_rec);
        end if;

        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others: '||sqlerrm, p_log_level_rec => p_log_level_rec);
        end if;

        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return  FALSE;
end faxama;

----------------------------------------------------------------------------

-- backdate amortization enhancement - begin
-- this function will get books row of addition transaction
-- and call faxcde to calculate what the actual reserve is from the
-- prorate period upto right before the amortization period

FUNCTION get_reserve(px_trans_rec        in out nocopy FA_API_TYPES.trans_rec_type,
                     p_asset_hdr_rec     in     FA_API_TYPES.asset_hdr_rec_type,
                     p_asset_desc_rec    in     FA_API_TYPES.asset_desc_rec_type,
                     px_asset_fin_rec    in out nocopy FA_API_TYPES.asset_fin_rec_type,
                     p_add_txn_id        in     number,
                     p_amortize_fy       in     integer,
                     p_amortize_per_num  in     integer,
                     p_pers_per_yr       in     integer,
                     p_mrc_sob_type_code in     varchar2,
                     x_deprn_rsv            out nocopy number,
                     x_bonus_deprn_rsv      out nocopy number,
                     x_impairment_rsv       out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

   l_asset_fin_rec   FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec FA_API_TYPES.asset_deprn_rec_type;

   l_dpr_row       FA_STD_TYPES.dpr_struct;
   l_dpr_arr       FA_STD_TYPES.dpr_arr_type;
   l_dpr_out       FA_STD_TYPES.dpr_out_struct;

   l_cur_deprn_rsv number;
   l_cur_bonus_deprn_rsv number;
   l_cur_impairment_rsv  number;

   dummy_var       varchar2(15);
   dummy_num       number;

begin

   l_asset_fin_rec := px_asset_fin_rec;

   if p_mrc_sob_type_code = 'R' then
      select adjusted_cost,
             recoverable_cost,
             reval_amortization_basis,
             adjusted_rate,
             production_capacity,
             adjusted_capacity,
             adjusted_recoverable_cost,
             salvage_value,
             deprn_method_code,
             life_in_months,
             ceiling_name,
             bonus_rule,
             annual_deprn_rounding_flag,
             rate_adjustment_factor,
             prorate_date,
             deprn_start_date,
             date_placed_in_service
        into l_asset_fin_rec.adjusted_cost,
             l_asset_fin_rec.recoverable_cost,
             l_asset_fin_rec.reval_amortization_basis,
             l_asset_fin_rec.adjusted_rate,
             l_asset_fin_rec.production_capacity,
             l_asset_fin_rec.adjusted_capacity,
             l_asset_fin_rec.adjusted_recoverable_cost,
             l_asset_fin_rec.salvage_value,
             l_asset_fin_rec.deprn_method_code,
             l_asset_fin_rec.life_in_months,
             l_asset_fin_rec.ceiling_name,
             l_asset_fin_rec.bonus_rule,
             l_asset_fin_rec.annual_deprn_rounding_flag,
             l_asset_fin_rec.rate_adjustment_factor,
             l_asset_fin_rec.prorate_date,
             l_asset_fin_rec.deprn_start_date,
             l_asset_fin_rec.date_placed_in_service
        from fa_mc_books bk
       where bk.book_type_code           = p_asset_hdr_rec.book_type_code
         and bk.asset_id                 = p_asset_hdr_rec.asset_id
         and bk.transaction_header_id_in = p_add_txn_id
         and bk.set_of_books_id          = p_asset_hdr_rec.set_of_books_id;
   else
      select adjusted_cost,
             recoverable_cost,
             reval_amortization_basis,
             adjusted_rate,
             production_capacity,
             adjusted_capacity,
             adjusted_recoverable_cost,
             salvage_value,
             deprn_method_code,
             life_in_months,
             ceiling_name,
             bonus_rule,
             annual_deprn_rounding_flag,
             rate_adjustment_factor,
             prorate_date,
             deprn_start_date,
             date_placed_in_service
        into l_asset_fin_rec.adjusted_cost,
             l_asset_fin_rec.recoverable_cost,
             l_asset_fin_rec.reval_amortization_basis,
             l_asset_fin_rec.adjusted_rate,
             l_asset_fin_rec.production_capacity,
             l_asset_fin_rec.adjusted_capacity,
             l_asset_fin_rec.adjusted_recoverable_cost,
             l_asset_fin_rec.salvage_value,
             l_asset_fin_rec.deprn_method_code,
             l_asset_fin_rec.life_in_months,
             l_asset_fin_rec.ceiling_name,
             l_asset_fin_rec.bonus_rule,
             l_asset_fin_rec.annual_deprn_rounding_flag,
             l_asset_fin_rec.rate_adjustment_factor,
             l_asset_fin_rec.prorate_date,
             l_asset_fin_rec.deprn_start_date,
             l_asset_fin_rec.date_placed_in_service
        from fa_books bk
       where bk.book_type_code           = p_asset_hdr_rec.book_type_code
         and bk.asset_id                 = p_asset_hdr_rec.asset_id
         and bk.transaction_header_id_in = p_add_txn_id;
   end if;

   if not FA_EXP_PVT.faxbds
           (p_asset_hdr_rec      => p_asset_hdr_rec,
            px_asset_fin_rec_new => l_asset_fin_rec,
            p_asset_deprn_rec    => l_asset_deprn_rec,
            p_asset_desc_rec     => p_asset_desc_rec,
            X_dpr_ptr            => l_dpr_row,
            X_deprn_rsv          => l_cur_deprn_rsv,
            X_bonus_deprn_rsv    => l_cur_bonus_deprn_rsv,
            X_impairment_rsv     => l_cur_impairment_rsv,
            p_amortized_flag     => FALSE,
            p_mrc_sob_type_code  => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   if (p_amortize_per_num = 1) then
      l_dpr_row.y_end    := p_amortize_fy - 1;
      l_dpr_row.p_cl_end := p_pers_per_yr;
   else
      l_dpr_row.y_end    := p_amortize_fy;
      l_dpr_row.p_cl_end := p_amortize_per_num - 1;
   end if;

   l_dpr_row.bonus_rule := '';
   l_dpr_row.reval_rsv := 0;
   l_dpr_row.prior_fy_exp := 0;
   l_dpr_row.ytd_deprn := 0;
   l_dpr_row.mrc_sob_type_code := p_mrc_sob_type_code;
   l_dpr_row.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

   if (not FA_CDE_PKG.faxcde(l_dpr_row,
                             l_dpr_arr,
                             l_dpr_out,
                             FA_STD_TYPES.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'faxcde3', p_log_level_rec => p_log_level_rec);
      FA_SRVR_MSG.ADD_MESSAGE
               (CALLING_FN => 'FA_AMORT_PKG.get_reserve',
                NAME=>'FA_AMT_CAL_DP_EXP',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   px_trans_rec.deprn_override_flag := l_dpr_out.deprn_override_flag;
   x_deprn_rsv       := l_dpr_out.new_deprn_rsv;
   x_bonus_deprn_rsv := l_dpr_out.new_bonus_deprn_rsv;
   x_impairment_rsv  := l_dpr_out.new_impairment_rsv;

   return TRUE;

exception
  when others then
       FA_SRVR_MSG.ADD_SQL_ERROR
            (CALLING_FN => 'FA_AMORT_PKG.get_reserve',  p_log_level_rec => p_log_level_rec);
       return  FALSE;

end get_reserve;

-- backdate amortization enhancement - end

-------------------------------------------------------------------------------

-- New function: faxnac
-- Alternative flat rate depreciation calculation.
-- If deprn_basis_formula = 'STRICT_FLAT', use the new adjustment method.
-- When using a NBV based flat rate method, adjustment base amount will be
-- the NBV of the beginning of the year, and when using a Cost based flat rate
-- method, adjustment base amount will be the recoverable cost.

FUNCTION faxnac (p_method_code  in varchar2,
                 p_life         in number,
                 p_rec_cost     in number,
                 p_prior_fy_exp in number,
                 p_deprn_rsv    in number,
                 p_ytd_deprn    in number,
                 px_adj_cost    in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   l_deprn_basis_formula varchar2(30);
   l_rate_source_rule varchar2(10);
   l_deprn_basis_rule varchar2(4);
   l_dummy_bool boolean;
   l_dummy_int integer;

begin

   if px_adj_cost is null then
      fa_srvr_msg.add_message(name => '***ADJ_COST_NULL***',
                              calling_fn => 'FA_AMORT_PKG.faxnac', p_log_level_rec => p_log_level_rec);
      return false;
   end if;

   if (not fa_cache_pkg.fazccmt(p_method_code,
                                p_life, p_log_level_rec => p_log_level_rec)) then
      fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac',  p_log_level_rec => p_log_level_rec);
      return false;
   end if;

   l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule_id;

   if l_deprn_basis_formula is null then
      return true;
   end if;

   --  if l_deprn_basis_formula = fa_std_types.FAD_DBF_FLAT then
   if l_deprn_basis_formula = 'STRICT_FLAT' then
      if (not fa_cache_pkg.fazccmt(p_method_code,
                                   p_life, p_log_level_rec => p_log_level_rec)) then
         fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac',  p_log_level_rec => p_log_level_rec);
         return false;
      end if;

      l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
      l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

      if l_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT and
         l_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_COST then
         if p_rec_cost is null then
            fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac',  p_log_level_rec => p_log_level_rec);
            return false;
         end if;
         px_adj_cost := p_rec_cost;
      elsif l_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT and
            l_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_NBV then
         if p_rec_cost is null or
            not ((p_prior_fy_exp is not null) or
                 (p_deprn_rsv is not null and p_ytd_deprn is not null) ) then
            fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac',  p_log_level_rec => p_log_level_rec);
            return false;
         end if;

         if p_prior_fy_exp is null then
            px_adj_cost := p_rec_cost - p_deprn_rsv + p_ytd_deprn;
         else
            px_adj_cost := p_rec_cost - p_prior_fy_exp;
         end if;
      end if;
   end if;
   return true;

end faxnac;

FUNCTION faxraf
         (px_trans_rec            IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec       IN     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec        IN     FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec       IN     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old    IN     FA_API_TYPES.asset_fin_rec_type,
          px_asset_fin_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec      IN     FA_API_TYPES.asset_deprn_rec_type,
          p_period_rec           IN     FA_API_TYPES.period_rec_type,
          px_deprn_exp           IN OUT NOCOPY number,
          px_bonus_deprn_exp     IN OUT NOCOPY number,
          px_impairment_exp      IN OUT NOCOPY number,
          px_reval_deprn_rsv_adj IN out NOCOPY number,
          p_mrc_sob_type_code    IN     VARCHAR2,
          p_running_mode         IN     NUMBER,
          p_used_by_revaluation  IN     NUMBER
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   l_dpr_row                  FA_STD_TYPES.dpr_struct;
   l_dpr_out                  FA_STD_TYPES.dpr_out_struct;
   l_dpr_arr                  FA_STD_TYPES.dpr_arr_type;
   l_add_txn_id               number;
   l_deprn_basis_rule         varchar2(25);
   l_rate_source_rule         varchar2(25);
   l_excl_salvage_val_flag    boolean;
   l_deprn_last_year_flag     boolean;
   l_method_id                integer;
   l_cur_rsv                  number;
   l_cur_bonus_rsv            number;
   l_cur_impairment_rsv       number;
   l_cur_ytd                  number;
   l_deprn_rsv                number;
   l_temp                     number;
   l_err_string               varchar2(500);

   -- Added for Dated Adjustment
   l_fy_name                  varchar2(45);
   l_amortize_per_num         integer;
   l_amortize_fy              integer;
   l_start_jdate              integer;
   l_pers_per_yr              integer;
   l_amortization_start_jdate integer;
   l_cur_fy                   integer;
   l_cur_per_num              integer;
   l_last_per_ctr             integer;
   l_amortize_per_ctr         integer;
   l_adjustment_amount        number;
   l_rsv_amount               number;
   l_deprn_summary            fa_std_types.fa_deprn_row_struct;
   l_dummy_bool               boolean; --Used to call QUERY_BALANCES_INT

   l_temp_deprn_rsv           number;  -- reserve at the beginning of fy
   l_cur_total_rsv        number;

   -- Added for bonus rule
   l_bonus_rule               FA_BONUS_RULES.Bonus_Rule%TYPE;
   l_bonus_deprn_rsv          number;

   l_impairment_rsv           number;

   -- Manual Override
   l_use_override             boolean;
   l_running_mode             number;
   l_used_by_revaluation      number;

   -- Depreciable Basis Rule
   l_deprn_used_by_adjustment varchar2(10):= null;

   -- multiple backdate amortization enhancement - begin LSON
   cursor amort_date_before_add is
   select th.transaction_header_id
     from fa_transaction_headers th,
          fa_deprn_periods dp
    where th.book_type_code = p_asset_hdr_rec.book_type_code
      and th.asset_id = p_asset_hdr_rec.asset_id
      and th.transaction_type_code = 'ADDITION'
      and th.book_type_code = dp.book_type_code
      and th.date_effective between dp.period_open_date and
            nvl(dp.period_close_date,sysdate)
      and px_trans_rec.amortization_start_date < dp.calendar_period_open_date;

begin  <<faxraf>>

  -- override
  if p_running_mode = fa_std_types.FA_DPR_PROJECT then
     l_running_mode:= fa_std_types.FA_DPR_PROJECT;
  else
     l_running_mode:= fa_std_types.FA_DPR_NORMAL;
  end if;
  -- End of Manual Override

   if (p_log_level_rec.statement_level) then
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'method code',
                value   => px_asset_fin_rec_new.deprn_method_code, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'life',
                value   => px_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec);
   end if;

   if (not FA_CACHE_PKG.fazccmt
             (px_asset_fin_rec_new.deprn_method_code,
              px_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   l_method_id             := fa_cache_pkg.fazccmt_record.method_id;
   l_rate_source_rule      := fa_cache_pkg.fazccmt_record.rate_source_rule;
   l_deprn_basis_rule      := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

   if fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag = 'YES' then
      l_excl_salvage_val_flag := TRUE;
   else
      l_excl_salvage_val_flag := FALSE;
   end if;

   if fa_cache_pkg.fazccmt_record.depreciate_lastyear_flag = 'YES' then
      l_deprn_last_year_flag := TRUE;
   else
      l_deprn_last_year_flag := FALSE;
   end if;

   if (p_log_level_rec.statement_level) then
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'After fazccmt',
                value   => 2, p_log_level_rec => p_log_level_rec);
   end if;

   l_err_string := 'FA_AMT_BD_DPR_STRUCT';

   if (p_log_level_rec.statement_level)then
       FA_DEBUG_PKG.ADD
               (fname   =>' FA_AMORT_PKG.faxraf',
                element => 'deprn_rounding_flag- before faxbds',
                value   => px_asset_fin_rec_new.annual_deprn_rounding_flag, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'FA_STD TYPE deprn_rnd- before faxbds',
                value   => FA_STD_TYPES.FA_DPR_ROUND_ADJ, p_log_level_rec => p_log_level_rec);
   end if;

   if not FA_EXP_PVT.faxbds
          (p_asset_hdr_rec      => p_asset_hdr_rec,
           px_asset_fin_rec_new => px_asset_fin_rec_new,
           p_asset_deprn_rec    => p_asset_deprn_rec,
           p_asset_desc_rec     => p_asset_desc_rec,
           X_dpr_ptr            => l_dpr_row,
           X_deprn_rsv          => l_cur_rsv,
           X_bonus_deprn_rsv    => l_cur_bonus_rsv,
           X_impairment_rsv     => l_cur_impairment_rsv,
           p_amortized_flag     => TRUE,
           p_mrc_sob_type_code  => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message (calling_fn => 'fa_amort_pkg.faxraf',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   l_cur_rsv := l_cur_rsv + px_reval_deprn_rsv_adj;
   l_cur_ytd := l_dpr_row.ytd_deprn;

    -- override
   l_dpr_row.used_by_adjustment := TRUE;
   l_dpr_row.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;

   -- l_err_string := 'FA_AMT_CAL_DP_EXP';
   if (p_log_level_rec.statement_level) then
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'Before faxcde',
                value   => 3, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'l_dpr_row.deprn_rounding_flag ',
                value   => l_dpr_row.deprn_rounding_flag, p_log_level_rec => p_log_level_rec);
   end if;

   -- Added for Dated Adjustment
   if (px_trans_rec.amortization_start_date is not null) then

      l_last_per_ctr := fa_cache_pkg.fazcbc_record.last_period_counter;
      l_cur_fy       := fa_cache_pkg.fazcbc_record.current_fiscal_year;
      l_cur_per_num  := mod((l_last_per_ctr+1),l_cur_fy);
      l_fy_name      := fa_cache_pkg.fazcbc_record.fiscal_year_name;
      l_amortization_start_jdate := to_number(to_char(px_trans_rec.amortization_start_date, 'J'));  --BMR

      if not fa_cache_pkg.fazccp(
                l_dpr_row.calendar_type,
                l_fy_name,
                l_amortization_start_jdate,
                l_amortize_per_num,
                l_amortize_fy,
                l_start_jdate, p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
         return (FALSE);
      end if;

      if (not((l_cur_fy      = l_amortize_fy) and
              (l_cur_per_num = l_amortize_per_num))) then
         if not fa_cache_pkg.fazcct (l_dpr_row.calendar_type, p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
            return (FALSE);
         end if;

         -- if this transaction is not at current period, set ADJUSTMENT mode
         -- on Depreciable basis rule
         l_deprn_used_by_adjustment   := 'ADJUSTMENT';

         l_pers_per_yr := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

         if (l_amortize_per_num = 1) then
            l_dpr_row.y_end := l_amortize_fy - 1;
         else
            l_dpr_row.y_end := l_amortize_fy;
         end if;

         if (l_amortize_per_num = 1) then
            l_dpr_row.p_cl_end := l_pers_per_yr;
         else
            l_dpr_row.p_cl_end := l_amortize_per_num - 1;
         end if;
      end if; --if (not((l_cur_fy = l_amortize_fy) and (l_cur_per_num = l_amortize_per_num)))
   end if; --if (px_trans_rec.amortization_start_date is not null)

   -- End Added for Dated Adjustment

   -- bonus: We need to exclude bonus amounts when calculating raf.
   --  proved that bonus_rule is excluded, if exist for asset.
   l_bonus_rule         := l_dpr_row.bonus_rule;
   l_dpr_row.bonus_rule := '';

   -- row below may not be needed.
   -- l_bonus_deprn_rsv   := l_dpr_row.bonus_deprn_rsv;
   -- l_dpr_row.deprn_rsv is not used.
   -- l_deprn_total_rsv   := l_dpr_row.deprn_rsv;
   -- l_dpr_row.deprn_rsv := l_dpr_row.deprn_rsv - l_dpr_row.bonus_deprn_rsv;
   l_cur_total_rsv := l_cur_rsv;
   l_cur_rsv       := l_cur_rsv - nvl(l_dpr_row.bonus_deprn_rsv,0) -
                                  nvl(l_dpr_row.impairment_rsv,0);

   l_used_by_revaluation:= 0;

   if p_used_by_revaluation = 1 then
      l_used_by_revaluation:= 1;
   end if;

   l_use_override := ((l_rate_source_rule = FA_STD_TYPES.FAD_RSR_FORMULA) or
                      (((l_rate_source_rule = FA_STD_TYPES.FAD_RSR_CALC) or
                        (l_rate_source_rule = FA_STD_TYPES.FAD_RSR_TABLE)) and
                        (l_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_COST)));

   -- Set Tracking related variables
   l_dpr_row.tracking_method := p_asset_fin_rec_old.tracking_method;
   l_dpr_row.allocate_to_fully_ret_flag := p_asset_fin_rec_old.allocate_to_fully_ret_flag;
   l_dpr_row.allocate_to_fully_rsv_flag := p_asset_fin_rec_old.allocate_to_fully_rsv_flag;
   l_dpr_row.excess_allocation_option := p_asset_fin_rec_old.excess_allocation_option;
   l_dpr_row.depreciation_option := p_asset_fin_rec_old.depreciation_option;
   l_dpr_row.member_rollup_flag := p_asset_fin_rec_old.member_rollup_flag;
   l_dpr_row.mrc_sob_type_code := p_mrc_sob_type_code;
   l_dpr_row.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD(fname   => 'FA_AMORT_PKG.faxraf',
                       element => 'Before call to faxcde regular case',
                       value   => l_dpr_row.bonus_rule, p_log_level_rec => p_log_level_rec);
   end if;

   if (not FA_CDE_PKG.faxcde
                 (l_dpr_row,
                  l_dpr_arr,
                  l_dpr_out,
                  FA_STD_TYPES.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxraf',
             NAME=>'FA_AMT_CAL_DP_EXP',  p_log_level_rec => p_log_level_rec);
      if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'After faxcde',
                value   => 'False', p_log_level_rec => p_log_level_rec);
         FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'l_dpr_out.rate_adj_factor',
                value   => l_dpr_row.rate_adj_factor, p_log_level_rec => p_log_level_rec);
         FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'l_dpr_out.adj_capacity',
                value   => l_dpr_row.adj_capacity, p_log_level_rec => p_log_level_rec);
         FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxraf',
                element => 'l_dpr_out.capacity',
                value   => l_dpr_row.capacity, p_log_level_rec => p_log_level_rec);
      end if;
      return FALSE;
   end if;

   -- Override
   fa_std_types.deprn_override_trigger_enabled:= FALSE;
   if l_use_override then  -- pass deprn_override_flag to faxiat
      px_trans_rec.deprn_override_flag:= l_dpr_out.deprn_override_flag;
      if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf',
                           element=>'deprn_override_flag1',
                           value=>l_dpr_out.deprn_override_flag, p_log_level_rec => p_log_level_rec);
      end if;
   else
      -- pass fa_no_override to faxiat
      px_trans_rec.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
      -- update the status fa_deprn_override from 'SELECTED' to 'POST'
      UPDATE FA_DEPRN_OVERRIDE
         SET status  = 'POST'
       WHERE used_by = 'ADJUSTMENT'
         AND status  = 'SELECTED'
         AND transaction_header_id is null;
   end if;

   fa_std_types.deprn_override_trigger_enabled:= TRUE;

   --
   -- In most cases, New Adjusted_Cost = New Net Book Value;
   --   New Rate_Adjustment_Factor = New Net Book Value / New Deprn_Reserve
   --   New Reval_Amortization_Basis = (dpr) Reval_Reserve

   -- bonus between here and next, include bonus amounts.
   -- bonus: modified according to decision from domain experts:
   --        now using Cost - Total Reserve
   --        when calculating adjusted_cost for nbv assets and
   --        Cost - Regular Reserve (without bonus deprn res) for cost assets

   -- new_raval_amo_basis and Production rate source rule are
   -- not calculated on Depreciable Basis Formula

   px_asset_fin_rec_new.reval_amortization_basis := l_dpr_row.reval_rsv;

   if (l_rate_source_rule = FA_STD_TYPES.FAD_RSR_PROD) then
        px_asset_fin_rec_new.rate_adjustment_factor := 1;
        px_asset_fin_rec_new.adjusted_capacity
                       := px_asset_fin_rec_new.production_capacity -
                          l_dpr_out.new_ltd_prod;
        px_asset_fin_rec_new.formula_factor := 1;
   end if;
   ----------------------------------------------
   -- Call Depreciable Basis Rule
   -- for Amortized Adjustment of current period
   ----------------------------------------------
/*Bug8230037 - Added condition based on sorp_enabled_flag
             - No need to call CALL_DEPRN_BASIS for Double Declining methods */
if (not l_rate_source_rule = FA_STD_TYPES.FAD_RSR_CALC)
   and nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y' then
   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS (
                p_event_type             => 'AMORT_ADJ',
                p_asset_fin_rec_new      => px_asset_fin_rec_new,
                p_asset_fin_rec_old      => p_asset_fin_rec_old,
                p_asset_hdr_rec          => p_asset_hdr_rec,
                p_asset_type_rec         => p_asset_type_rec,
                p_asset_deprn_rec        => p_asset_deprn_rec,
                p_trans_rec              => px_trans_rec,
                p_period_rec             => p_period_rec,
                p_current_total_rsv      => l_cur_total_rsv,
                p_current_rsv            => l_cur_rsv,
                p_current_total_ytd      => l_cur_ytd,
                p_hyp_basis              => l_dpr_out.new_adj_cost,
                p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                p_hyp_rsv                => l_dpr_out.new_deprn_rsv -
                                            l_dpr_out.new_bonus_deprn_rsv -
                                            nvl(l_dpr_out.new_impairment_rsv,0),
                p_mrc_sob_type_code      => p_mrc_sob_type_code,
                p_used_by_adjustment     => l_deprn_used_by_adjustment,
                px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                p_log_level_rec => p_Log_level_rec)) then

       FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
       FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'FA_AMORT_PKG.faxraf',
                 NAME=>'FA_AMT_CAL_DP_EXP',  p_log_level_rec => p_log_level_rec);
       return false;

   end if;
else
    px_asset_fin_rec_new.adjusted_cost :=
                       px_asset_fin_rec_new.recoverable_cost - l_cur_rsv;
    if (sign(px_asset_fin_rec_new.recoverable_cost)<>0)
          then
           l_temp := px_asset_fin_rec_new.recoverable_cost -
                     l_dpr_out.new_deprn_rsv;
           px_asset_fin_rec_new.rate_adjustment_factor :=
                     l_temp / px_asset_fin_rec_new.recoverable_cost;
           px_asset_fin_rec_new.formula_factor := 1;
         else
           px_asset_fin_rec_new.rate_adjustment_factor :=1;
           px_asset_fin_rec_new.formula_factor := 1;
    end if;
end if;


   -- bonus: assigning bonus rule value back.
   l_dpr_row.bonus_rule := l_bonus_rule;
   -- not yet needed.
   --  l_deprn_row.bonus_deprn_rsv := l_bonus_deprn_rsv;
   --  l_dpr_row.deprn_rsv is not used.
   --  l_dpr_row.deprn_rsv :=  l_deprn_total_rsv;

   l_cur_rsv := l_cur_total_rsv;

   if (px_asset_fin_rec_new.rate_adjustment_factor < 0 OR
       px_asset_fin_rec_new.rate_adjustment_factor > 1)then
      FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxraf',
             NAME=>'FA_AMT_RAF_OUT_OF_RANGE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Added for Dated Adjustment
   px_deprn_exp := 0;

   if (px_trans_rec.amortization_start_date is not null) then
      if (not((l_cur_fy = l_amortize_fy) and
              (l_cur_per_num = l_amortize_per_num))) then
         l_dpr_row.y_begin    := l_amortize_fy;
         l_dpr_row.p_cl_begin := l_amortize_per_num;

         if (l_cur_per_num = 1) then
            l_dpr_row.y_end := l_cur_fy - 1;
         else
            l_dpr_row.y_end := l_cur_fy;
         end if;

         if (l_cur_per_num = 1) then
            l_dpr_row.p_cl_end := l_pers_per_yr;
         else
            l_dpr_row.p_cl_end := l_cur_per_num - 1;
         end if;

         l_dpr_row.rate_adj_factor := px_asset_fin_rec_new.rate_adjustment_factor;

         if (l_cur_fy = l_amortize_fy) then
            l_amortize_per_ctr := (l_last_per_ctr + 1) -
                                (l_cur_per_num - l_amortize_per_num);
         else
            l_amortize_per_ctr := (l_last_per_ctr + 1) -
                                  ((l_cur_fy - l_amortize_fy -1) * l_pers_per_yr +
                                   (l_pers_per_yr - l_amortize_per_num + l_cur_per_num));
         end if;

         l_deprn_summary.asset_id   := p_asset_hdr_rec.asset_id;
         l_deprn_summary.book       := p_asset_hdr_rec.book_type_code;
         l_deprn_summary.period_ctr := l_amortize_per_ctr - 1;
         l_deprn_summary.dist_id    := 0;

         -- Enhancement for BT. YYOON - Start
         -- BUG#1148053: Ability to add assets with reserve
         -- and amortize over remaining useful life

         if (p_asset_hdr_rec.period_of_addition = 'Y') then
            -- bonus added.
            if p_mrc_sob_type_code = 'R' then
               select deprn_reserve,
                      bonus_deprn_reserve,
                      ytd_deprn,
                      impairment_reserve
                 into l_deprn_summary.deprn_rsv,
                      l_deprn_summary.bonus_deprn_rsv,
                      l_deprn_summary.ytd_deprn,
                      l_deprn_summary.impairment_rsv
                 from fa_mc_deprn_summary
                where asset_id          = p_asset_hdr_rec.asset_id
                  and book_type_code    = p_asset_hdr_rec.book_type_code
                  and deprn_source_code = 'BOOKS'
                  and set_of_books_id   = p_asset_hdr_rec.set_of_books_id;
            else
               select deprn_reserve,
                      bonus_deprn_reserve,
                      ytd_deprn,
                      impairment_reserve
                 into l_deprn_summary.deprn_rsv,
                      l_deprn_summary.bonus_deprn_rsv,
                      l_deprn_summary.ytd_deprn,
                      l_deprn_summary.impairment_rsv
                 from fa_deprn_summary
                where asset_id          = p_asset_hdr_rec.asset_id
                  and book_type_code    = p_asset_hdr_rec.book_type_code
                  and deprn_source_code = 'BOOKS';
            end if;
         else
            --  backdate amortization enhancement - begin
            l_add_txn_id := 0;
            if px_trans_rec.amortization_start_date is not null then
               open amort_date_before_add;
               fetch amort_date_before_add
                into l_add_txn_id;
               close amort_date_before_add;

               -- when amortization start date is before the addition date
               -- call get_reserve to get the actual reserve from the prorate period to before the
               -- amortization period
               if (l_add_txn_id > 0) then
                  if not (get_reserve
                              (px_trans_rec,
                               p_asset_hdr_rec,
                               p_asset_desc_rec,
                               px_asset_fin_rec_new,
                               l_add_txn_id,
                               l_amortize_fy,
                               l_amortize_per_num,
                               l_pers_per_yr,
                               p_mrc_sob_type_code,
                               l_deprn_rsv,
                               l_bonus_deprn_rsv,
                               l_impairment_rsv,
                               p_log_level_rec)) then
                     fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
                     return FALSE;
                  end if;
                  l_deprn_summary.deprn_rsv       := l_deprn_rsv;
                  l_deprn_summary.bonus_deprn_rsv := l_bonus_deprn_rsv;
                  l_deprn_summary.impairment_rsv  := l_impairment_rsv;
               end if;
            end if;

            if (px_trans_rec.amortization_start_date is null or l_add_txn_id = 0) then
               -- backdate amortization enhacement - end
               FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
                  l_deprn_summary,
                  'STANDARD',
                  FALSE, -- DEBUG
                  l_dummy_bool,
                  'FA_AMORT_PKG.faxraf',
                  -1, p_log_level_rec => p_log_level_rec);

               if not (l_dummy_bool) then
                  fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
                  return (FALSE);
               end if;
            end if;
         end if;

         /**** Enhancement for BT. YYOON - End */

         if p_mrc_sob_type_code = 'R' then
            SELECT NVL(SUM(DECODE(ADJUSTMENT_TYPE,
                           'EXPENSE',
                           DECODE(DEBIT_CREDIT_FLAG,
                                  'DR', ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJUSTMENT_AMOUNT))),0),
                   -- backdate amortization enhancement - begin
                   NVL(SUM(DECODE(ADJUSTMENT_TYPE,
                            'RESERVE',
                             DECODE(DEBIT_CREDIT_FLAG,
                            'DR', ADJUSTMENT_AMOUNT,
                            'CR', -1 * ADJUSTMENT_AMOUNT))),0)
                   -- backdate amortization enhancement - end
              INTO l_adjustment_amount,
                   l_rsv_amount
              FROM FA_MC_ADJUSTMENTS
             WHERE asset_id                = p_asset_hdr_rec.asset_id
               AND book_type_code          = p_asset_hdr_rec.book_type_code
               AND period_counter_adjusted = l_amortize_per_ctr
               AND SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id;
         else
            SELECT NVL(SUM(DECODE(ADJUSTMENT_TYPE,
                           'EXPENSE',
                           DECODE(DEBIT_CREDIT_FLAG,
                                  'DR', ADJUSTMENT_AMOUNT,
                                  'CR', -1 * ADJUSTMENT_AMOUNT))),0),
                   -- backdate amortization enhancement - begin
                   NVL(SUM(DECODE(ADJUSTMENT_TYPE,
                            'RESERVE',
                             DECODE(DEBIT_CREDIT_FLAG,
                            'DR', ADJUSTMENT_AMOUNT,
                            'CR', -1 * ADJUSTMENT_AMOUNT))),0)
                   -- backdate amortization enhancement - end
              INTO l_adjustment_amount,
                   l_rsv_amount
              FROM FA_ADJUSTMENTS
             WHERE asset_id                = p_asset_hdr_rec.asset_id
               AND book_type_code          = p_asset_hdr_rec.book_type_code
               AND period_counter_adjusted = l_amortize_per_ctr;
         end if;

         l_temp_deprn_rsv := l_deprn_summary.deprn_rsv - l_deprn_summary.bonus_deprn_rsv - nvl(l_deprn_summary.impairment_rsv,0);

         -- bonus
         l_deprn_summary.deprn_rsv := l_deprn_summary.deprn_rsv +
                                      l_adjustment_amount -
                                      l_rsv_amount;

         -- alternative flat rate depreciation calculation
         if l_amortize_per_num = 1 then
            l_deprn_summary.ytd_deprn := l_adjustment_amount;
         else
            l_deprn_summary.ytd_deprn := l_deprn_summary.ytd_deprn + l_adjustment_amount;
         end if;

         -- Add for the Depreciable Basis Formula.

           ----------------------------------------------
           -- Call Depreciable Basis Rule
           -- for Amortized Adjustment with back dated.
           -- Before faxcde calling
           ----------------------------------------------

           if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS (
                     p_event_type             => 'AMORT_ADJ2',
                     p_asset_fin_rec_new      => px_asset_fin_rec_new,
                     p_asset_fin_rec_old      => p_asset_fin_rec_old,
                     p_asset_hdr_rec          => p_asset_hdr_rec,
                     p_asset_type_rec         => p_asset_type_rec,
                     p_asset_deprn_rec        => p_asset_deprn_rec,
                     p_trans_rec              => px_trans_rec,
                     p_period_rec             => p_period_rec,
                     p_adjusted_cost          => l_dpr_row.adj_cost,
                     p_current_total_rsv      => l_deprn_summary.deprn_rsv,
                     p_current_rsv            => l_deprn_summary.deprn_rsv -
                                                 l_deprn_summary.bonus_deprn_rsv - nvl(l_deprn_summary.impairment_rsv,0),
                     p_current_total_ytd      => l_deprn_summary.ytd_deprn,
                     p_hyp_basis              => l_dpr_out.new_adj_cost,
                     p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                     p_hyp_rsv                => l_dpr_out.new_deprn_rsv -
                                                 l_dpr_out.new_bonus_deprn_rsv - nvl(l_dpr_out.new_impairment_rsv,0),
                     p_mrc_sob_type_code      => p_mrc_sob_type_code,
                     p_used_by_adjustment     => 'ADJUSTMENT',
                     px_new_adjusted_cost     => l_dpr_row.adj_cost,
                     px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                     px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
               p_log_level_rec => p_log_level_rec)) then
             FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
             FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'FA_AMORT_PKG.faxraf',
                 NAME=>'FA_AMT_CAL_DP_EXP',  p_log_level_rec => p_log_level_rec);
             return false;

           end if;

        --fix for 2197401. error out if new nbv result in
        -- opposite sign of new recoverable cost
         if (sign(px_asset_fin_rec_new.recoverable_cost)<>sign(l_dpr_row.adj_cost)) then
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_AMORT_PKG.faxraf',
                       NAME=>'FA_WRONG_REC_COST',  p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;

         l_dpr_row.deprn_rsv     := l_deprn_summary.deprn_rsv;
         l_dpr_row.adj_capacity  := px_asset_fin_rec_new.adjusted_capacity;

         -- Bonus: called when amortization_start_date is not null i.e. backdated
         --        adjustment.
         --        We probably need to modify to exclude bonus amounts.
         l_bonus_rule := l_dpr_row.bonus_rule;

         l_cur_total_rsv := l_cur_rsv;
         l_cur_rsv       := l_cur_rsv - nvl(l_dpr_row.bonus_deprn_rsv,0) -
                                        nvl(l_dpr_row.impairment_rsv,0);
         l_dpr_row.mrc_sob_type_code := p_mrc_sob_type_code;
         l_dpr_row.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

         if (not FA_CDE_PKG.faxcde
                       (l_dpr_row,
                        l_dpr_arr,
                        l_dpr_out,
                        FA_STD_TYPES.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec)) then
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'faxcde2', p_log_level_rec => p_log_level_rec);
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_AMORT_PKG.faxraf',
                 NAME       => 'FA_AMT_CAL_DP_EXP',  p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;

         -- Override
         if (p_log_level_rec.statement_level) then
            FA_DEBUG_PKG.ADD
                (fname   => 'FA_AMORT_PKG.faxraf',
                 element => 'deprn_override_flag2',
                 value   => l_dpr_out.deprn_override_flag, p_log_level_rec => p_log_level_rec);
         end if;

         px_trans_rec.deprn_override_flag:= l_dpr_out.deprn_override_flag;

         -- Added for Depreciable Basis Formula.

           ----------------------------------------------
           -- Call Depreciable Basis Rule
           -- for Amortized Adjustment with back dated.
           -- After faxcde calling
           ----------------------------------------------

           if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS (
                     p_event_type             => 'AMORT_ADJ3',
                     p_asset_fin_rec_new      => px_asset_fin_rec_new,
                     p_asset_fin_rec_old      => p_asset_fin_rec_old,
                     p_asset_hdr_rec          => p_asset_hdr_rec,
                     p_asset_type_rec         => p_asset_type_rec,
                     p_asset_deprn_rec        => p_asset_deprn_rec,
                     p_trans_rec              => px_trans_rec,
                     p_period_rec             => p_period_rec,
                     p_adjusted_cost          => l_dpr_row.adj_cost,
                     p_current_rsv            => l_temp_deprn_rsv,
                     p_current_total_ytd      => l_deprn_summary.ytd_deprn,
                     p_hyp_basis              => l_dpr_out.new_adj_cost,
                     p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                     p_hyp_rsv                => l_dpr_out.new_deprn_rsv
                                                   - l_dpr_out.new_bonus_deprn_rsv - nvl(l_dpr_out.new_impairment_rsv,0),
                     p_mrc_sob_type_code      => p_mrc_sob_type_code,
                     p_used_by_adjustment     => 'ADJUSTMENT',
                     px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                     px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                     px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
               p_log_level_rec => p_log_level_rec)) then
             FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
             FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'FA_AMORT_PKG.faxraf',
                 NAME=>'FA_AMT_CAL_DP_EXP',  p_log_level_rec => p_log_level_rec);
             return false;

           end if;

         -- bonus, added l_dpr_row.bonus_deprn_rsv field to calculation.
          px_deprn_exp := (l_dpr_out.new_deprn_rsv - l_deprn_summary.deprn_rsv) -
                          (l_cur_rsv - l_deprn_summary.deprn_rsv) -
                          nvl(l_dpr_row.bonus_deprn_rsv,0) -
                          nvl(l_dpr_row.impairment_rsv,0);

         -- bonus
         --  l_dpr_row.bonus_deprn_rsv arrives with value added for bonus_deprn_rsv.
         --  the new_bonus_deprn_rsv amount is not vanilla therefore the *2.
         --  if it turns out to be wrong calculation, it should be investigated
         --  why bonus_deprn_rsv doesn't arrive as expected.
         if (l_dpr_row.bonus_rule is not null) then
            px_bonus_deprn_exp :=
                (l_dpr_out.new_bonus_deprn_rsv -
                 l_deprn_summary.bonus_deprn_rsv) -
                 ( (l_dpr_row.bonus_deprn_rsv * 2) - l_deprn_summary.bonus_deprn_rsv);

           if (p_log_level_rec.statement_level) then
               FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                                 element=>'px_bonus_deprn_exp ',
                                 value=>px_bonus_deprn_exp, p_log_level_rec => p_log_level_rec);
               FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                                 element=>'l_dpr_out.new_bonus_deprn_rsv ',
                                 value=>l_dpr_out.new_bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
               FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                                 element=>'l_dpr_row.bonus_deprn_rsv',
                                 value=>l_dpr_row.bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
               FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                                 element=>'l_dpr_row.bonus_deprn_rsv',
                                 value=>l_deprn_summary.bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
            end if;
         end if;

         px_impairment_exp :=
                (l_dpr_out.new_impairment_rsv -
                 l_deprn_summary.impairment_rsv) -
                 ( (l_dpr_row.impairment_rsv * 2) - l_deprn_summary.impairment_rsv);

         -- bonus: assigning bonus rule value back.
         l_dpr_row.bonus_rule := l_bonus_rule;
         l_cur_rsv        := l_cur_total_rsv;

      end if; --if (not((l_cur_fy = l_amortize_fy) and (l_cur_per_num = l_amortize_per_num)))
   end if; --if (px_trans_rec.amortization_start_date is not null)

   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR
             (CALLING_FN => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
        return  FALSE;
end faxraf;

FUNCTION calc_raf_adj_cost
   (p_trans_rec           IN            FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec       IN            FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec      IN            FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec      IN            FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old   IN            FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_adj IN            FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_new IN            FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec          IN            FA_API_TYPES.period_rec_type,
    p_group_reclass_options_rec IN      FA_API_TYPES.group_reclass_options_rec_type default null,
    p_mrc_sob_type_code   IN            VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


  l_calling_fn     VARCHAR2(50) := 'fa_amort_pvt.calc_raf_adj_cost';

  --+++++++ variables for Eofy Recoverable Cost/Salvage Value +++++++
  l_eofy_rec_cost                NUMBER;
  l_eofy_sal_val                 NUMBER;

  --++++++++ variables for EOP Recoverable Cost/Salvage Value ++++++++
  l_eop_rec_cost                 NUMBER;
  l_eop_sal_val                  NUMBER;

  --++++++++ variables for manual override ++++++++
  l_rate_source_rule             VARCHAR2(25);
  l_deprn_basis_rule             VARCHAR2(25);

  --+++++++++++++++ For calling faxcde +++++++++++++++
  l_dpr_in                       FA_STD_TYPES.dpr_struct;
  l_dpr_out                      FA_STD_TYPES.dpr_out_struct;
  l_dpr_arr                      FA_STD_TYPES.dpr_arr_type;
  l_running_mode                 NUMBER;

  l_deprn_reserve                NUMBER;
  l_temp_integer                 BINARY_INTEGER;
  l_temp_number                  number;

  --+ HHIRAGA added on Oct/Nov in 2003
  --++++++++ variables for Trackking Member Feature ++++++++
  l_processed_flag               BOOLEAN := FALSE;
  l_raf_processed_flag           BOOLEAN := FALSE;
  l_current_period_counter       NUMBER;
  l_mem_deprn_reserve            NUMBER;
  l_mem_eofy_reserve             NUMBER;

  l_recalc_start_fy              NUMBER;
  l_recalc_start_period_num      NUMBER;
  l_recalc_start_period_counter  NUMBER;
  l_no_allocation_for_last       VARCHAR2(1);
  l_chk_bs_row_exists            VARCHAR2(1);


   CURSOR c_chk_bs_row_exists IS
      select 'Y'
        from fa_books_summary
       where book_type_code = p_asset_hdr_rec.book_type_code
         and group_asset_id = p_asset_hdr_rec.asset_id
         and asset_id <> group_asset_id
         and period_counter = l_recalc_start_period_counter - 1;

  l_asset_fin_rec_adj            FA_API_TYPES.asset_fin_rec_type;

  --Bug6988399
  Cursor c_year_switch is
  select 'N'
  from fa_deprn_periods
  where book_type_code = p_asset_hdr_rec.book_type_code
  and period_counter = p_asset_fin_rec_old.period_counter_fully_reserved
  and fiscal_year = p_period_rec.fiscal_year;

  l_year_switch varchar2(1);   --Bug6988399
  l_last_trx_count NUMBER := 0; -- Bug 7138798

  calc_err                       EXCEPTION;

BEGIN

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
  end if;

  -- Skipping call to the function because it is not necessary for straight line
  -- or flat-cost with period end balance and use recoverable cost basis rules
  -- There are more cases which calling this function unnecessary but not include for this time.
  if (not(   (fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_CALC)
          or ((fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT) and
              (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_COST) and
              (fa_cache_pkg.fazcdbr_record.rule_name  in ('PERIOD END BALANCE','USE RECOVERABLE COST'))))) then

    -- Get Eofy/Eop Recovearble Cost and Salvage Value
    if (not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP (
                p_asset_id              => p_asset_hdr_rec.asset_id,
                p_book_type_code        => p_asset_hdr_rec.book_type_code,
                p_fiscal_year           => p_period_rec.fiscal_year,
                p_asset_type            => p_asset_type_rec.asset_type,
                p_period_num            => p_period_rec.period_num,
                p_mrc_sob_type_code     => p_mrc_sob_type_code,
                p_set_of_books_id       => p_asset_hdr_rec.set_of_books_id,
                x_eofy_recoverable_cost => l_eofy_rec_cost,
                x_eofy_salvage_value    => l_eofy_sal_val,
                x_eop_recoverable_cost  => l_eop_rec_cost,
                x_eop_salvage_value     => l_eop_sal_val, p_log_level_rec => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                         'FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_err;

    end if;
  end if;

  if (l_eofy_rec_cost is null) then
    l_eofy_rec_cost := 0;
    l_eofy_sal_val := 0;
  end if;

  if (l_eop_rec_cost is null) then
    l_eop_rec_cost := 0;
    l_eop_sal_val := 0;
  end if;

  -- Skipping call to faxcde because it is unnecessary for flat-cost with period end balance,
  -- use recoverable cost, period average, and beginning balance basis rules
  -- There are more cases which calling this function unnecessary but not include for this time.
  if (not(((fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT) and
           (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_COST) and
           (fa_cache_pkg.fazcdbr_record.rule_name  in ('PERIOD END BALANCE', 'PERIOD END AVERAGE',
                                                      'USE RECOVERABLE COST', 'BEGINNING PERIOD'))
--Bug 6312866           or fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_PROD
        ))) then

      l_dpr_in.asset_num := p_asset_desc_rec.asset_number;
      l_dpr_in.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
      l_dpr_in.book := p_asset_hdr_rec.book_type_code;
      l_dpr_in.asset_id := p_asset_hdr_rec.asset_id;
      l_dpr_in.adj_cost := px_asset_fin_rec_new.recoverable_cost;
      l_dpr_in.rec_cost := px_asset_fin_rec_new.recoverable_cost;
      l_dpr_in.reval_amo_basis := px_asset_fin_rec_new.reval_amortization_basis;
      l_dpr_in.deprn_rsv := 0;
      l_dpr_in.reval_rsv := p_asset_deprn_rec_new.reval_deprn_reserve;
      l_dpr_in.adj_rate := px_asset_fin_rec_new.adjusted_rate;
      l_dpr_in.rate_adj_factor := px_asset_fin_rec_new.rate_adjustment_factor;
      l_dpr_in.capacity := px_asset_fin_rec_new.production_capacity;
      l_dpr_in.adj_capacity := px_asset_fin_rec_new.adjusted_capacity;
      l_dpr_in.ltd_prod := 0;

      l_dpr_in.ceil_name := px_asset_fin_rec_new.ceiling_name;
      l_dpr_in.bonus_rule := px_asset_fin_rec_new.bonus_rule;
      l_dpr_in.method_code := px_asset_fin_rec_new.deprn_method_code;
      l_dpr_in.jdate_in_service :=
                    to_number(to_char(px_asset_fin_rec_new.date_placed_in_service, 'J'));
      l_dpr_in.prorate_jdate := to_number(to_char(px_asset_fin_rec_new.prorate_date, 'J'));
      l_dpr_in.deprn_start_jdate := to_number(to_char(px_asset_fin_rec_new.deprn_start_date, 'J'));
      l_dpr_in.jdate_retired := 0; -- don't know this is correct or not
      l_dpr_in.ret_prorate_jdate := 0; -- don't know this is correct or not
      l_dpr_in.life := px_asset_fin_rec_new.life_in_months;

      l_dpr_in.rsv_known_flag := TRUE;
      l_dpr_in.salvage_value := px_asset_fin_rec_new.salvage_value;
      l_dpr_in.pc_life_end := px_asset_fin_rec_new.period_counter_life_complete;
      l_dpr_in.adj_rec_cost := px_asset_fin_rec_new.adjusted_recoverable_cost;
      l_dpr_in.prior_fy_exp := p_asset_deprn_rec_new.prior_fy_expense;
      l_dpr_in.deprn_rounding_flag := px_asset_fin_rec_new.annual_deprn_rounding_flag;
      l_dpr_in.deprn_override_flag := p_trans_rec.deprn_override_flag;
      l_dpr_in.used_by_adjustment := TRUE;
      l_dpr_in.ytd_deprn := p_asset_deprn_rec_new.ytd_deprn;
      l_dpr_in.short_fiscal_year_flag := px_asset_fin_rec_new.short_fiscal_year_flag;
      l_dpr_in.conversion_date := px_asset_fin_rec_new.conversion_date;
      l_dpr_in.prorate_date := px_asset_fin_rec_new.prorate_date;
      l_dpr_in.orig_deprn_start_date := px_asset_fin_rec_new.orig_deprn_start_date;
      l_dpr_in.old_adj_cost := px_asset_fin_rec_new.old_adjusted_cost;
      l_dpr_in.formula_factor := nvl(px_asset_fin_rec_new.formula_factor,
                                     p_asset_fin_rec_old.formula_factor);
      l_dpr_in.bonus_deprn_exp := p_asset_deprn_rec_new.bonus_deprn_amount;
      l_dpr_in.bonus_ytd_deprn := p_asset_deprn_rec_new.bonus_ytd_deprn;
      l_dpr_in.bonus_deprn_rsv := p_asset_deprn_rec_new.bonus_deprn_reserve;
      l_dpr_in.prior_fy_bonus_exp := p_asset_deprn_rec_new.prior_fy_bonus_expense;
      l_dpr_in.impairment_exp := p_asset_deprn_rec_new.impairment_amount;
      l_dpr_in.ytd_impairment := p_asset_deprn_rec_new.ytd_impairment;
      l_dpr_in.impairment_rsv := p_asset_deprn_rec_new.impairment_reserve;

      l_dpr_in.tracking_method := px_asset_fin_rec_new.tracking_method;
      l_dpr_in.allocate_to_fully_ret_flag := px_asset_fin_rec_new.allocate_to_fully_ret_flag;
      l_dpr_in.allocate_to_fully_rsv_flag := px_asset_fin_rec_new.allocate_to_fully_rsv_flag;
      l_dpr_in.excess_allocation_option := px_asset_fin_rec_new.excess_allocation_option;
      l_dpr_in.depreciation_option := px_asset_fin_rec_new.depreciation_option;
      l_dpr_in.member_rollup_flag := px_asset_fin_rec_new.member_rollup_flag;
      l_dpr_in.over_depreciate_option := px_asset_fin_rec_new.over_depreciate_option;
      l_dpr_in.mrc_sob_type_code := p_mrc_sob_type_code;
      l_dpr_in.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

      --
      -- Not for what-if yet
      --
      l_running_mode := fa_std_types.FA_DPR_NORMAL;

      if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                 fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                 l_dpr_in.prorate_jdate,
                                 l_temp_number,
                                 l_dpr_in.y_begin,
                                 l_temp_integer, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                             fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                             fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_err;
      end if;


      l_dpr_in.p_cl_begin := 1;

      if (p_period_rec.period_num = 1) then
         l_dpr_in.y_end := p_period_rec.fiscal_year - 1;
         l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
      else
         l_dpr_in.y_end := p_period_rec.fiscal_year;
         l_dpr_in.p_cl_end := p_period_rec.period_num - 1;
      end if;

      l_dpr_in.rate_adj_factor := 1;

      -- manual override
      if fa_cache_pkg.fa_deprn_override_enabled then
         if (not fa_cache_pkg.fazccmt(
                     px_asset_fin_rec_new.deprn_method_code,
                     px_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec)) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            end if;

            raise calc_err;
         end if;

         l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
         l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

         -- update override status only if satisfies condintion,
         -- otherwise do not update status when calculating RAF
         -- 1. formula; or
         -- 2. (calc or table) and cost

         l_dpr_in.update_override_status :=
               ((l_rate_source_rule = fa_std_types.FAD_RSR_FORMULA)
               OR (((l_rate_source_rule = fa_std_types.FAD_RSR_CALC)
               OR (l_rate_source_rule = fa_std_types.FAD_RSR_TABLE))
               AND (l_deprn_basis_rule = fa_std_types.FAD_DBR_COST)));
      end if;

            --* HHIRAGA modified on Oct/Nov in 2003.
            -- Changed parameter to period counter when the recalculation of
            -- RAF needs.
            -- This function will populates all member assets to be used to
            -- hypothetical allocation internally.
            --
            --+++++++ Call Tracking Function to populate Member in case ALLOCATE ++++++
            if p_asset_type_rec.asset_type = 'GROUP' and
               nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then

               l_raf_processed_flag := TRUE;
               l_dpr_in.tracking_method := NULL;

/*
               if not FA_TRACK_MEMBER_PVT.get_member_at_start(
                       p_period_rec => l_period_rec,
                       p_trans_rec => p_trans_rec,
                       p_asset_hdr_rec => p_asset_hdr_rec,
                       p_asset_fin_rec => px_asset_fin_rec_new,
                       p_dpr_in => l_dpr_in,
                       p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn, 'Error calling', 'FA_TRACK_MEMBER_PVT.get_member_at_start',  p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_failed;

               end if;
*/
            end if; -- nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE'
            -- End of HHIRAGA

      --+++++++ Call Depreciation engine for rate adjustment factor +++++++
      if not FA_CDE_PKG.faxcde(l_dpr_in,
                               l_dpr_arr,
                               l_dpr_out,
                               l_running_mode, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_err;
      end if;

      -- Bug 4129984.

      if ((fa_cache_pkg.fazcbc_record.AMORTIZE_REVAL_RESERVE_FLAG='YES') and
          (px_asset_fin_rec_new.Reval_Amortization_Basis is not null) and
          (p_asset_type_rec.asset_type = 'CAPITALIZED') and
          (px_asset_fin_rec_new.group_asset_id is null)) then

         px_asset_fin_rec_new.reval_amortization_basis := p_asset_deprn_rec_new.reval_deprn_reserve;
      end if;

   else -- in the case of skipping faxcde call
     l_dpr_out.new_adj_cost := px_asset_fin_rec_new.recoverable_cost;
     l_dpr_out.new_deprn_rsv := p_asset_deprn_rec_new.deprn_reserve;
     l_dpr_out.new_bonus_deprn_rsv := p_asset_deprn_rec_new.bonus_deprn_reserve;
     l_dpr_out.new_impairment_rsv := p_asset_deprn_rec_new.impairment_reserve;
   end if;


   --
   -- Bug4213715: new reserve has already include adj_reserve in case of group
   --             reclass with enter option.
   --
   if (p_asset_type_rec.asset_type = 'GROUP') and
      (p_trans_rec.transaction_key = 'GC') then
      -- reclass w/ enter option at group level

      l_deprn_reserve := nvl(p_asset_deprn_rec_new.deprn_reserve, 0);

   elsif (p_asset_type_rec.asset_type <> 'GROUP') and
         (nvl(p_asset_fin_rec_old.group_asset_id, 0) <>
               nvl(px_asset_fin_rec_new.group_asset_id, 0)) then

      l_deprn_reserve := nvl(p_asset_deprn_rec_new.deprn_reserve, 0);
   -- Bug 8605817: In case of Period of addition, p_asset_deprn_rec_new
   -- contains the new reserve
   elsif ( G_release <> 11 and p_asset_hdr_rec.period_of_addition = 'Y') then
      l_deprn_reserve := nvl(p_asset_deprn_rec_new.deprn_reserve, 0);
   else
      -- Ordinary behavior
      l_deprn_reserve := p_asset_deprn_rec_new.deprn_reserve +
                         nvl(p_asset_deprn_rec_adj.deprn_reserve, 0);
   end if;


   -- code fix for bug no.3630495. added the following line to calculate the adjusted capacity
   if (nvl(px_asset_fin_rec_new.tracking_method, 'NO TRACK') = 'ALLOCATE') and    -- ENERGY
      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then  -- ENERGY
      null;
   else
      px_asset_fin_rec_new.adjusted_capacity:=px_asset_fin_rec_new.production_capacity- nvl(l_dpr_out.new_ltd_prod, 0);
   end if;

   if (p_asset_hdr_rec.period_of_addition = 'Y') and
      (p_asset_type_rec.asset_type = 'GROUP') then
      px_asset_fin_rec_new.eofy_reserve := nvl(px_asset_fin_rec_new.eofy_reserve,
                                               p_asset_deprn_rec_new.deprn_reserve -
                                               p_asset_deprn_rec_new.ytd_deprn);
   else

      -- Bug 7138798: Check for any transaction in current fiscal year
      select count(*)
      into   l_last_trx_count
      from   fa_books bks,
             fa_deprn_periods dp
      where  bks.asset_id = p_asset_hdr_rec.asset_id
      and    bks.book_type_code = p_asset_hdr_rec.book_type_code
      and    bks.date_ineffective  is null
      and    dp.book_type_code = p_asset_hdr_rec.book_type_code
      and    bks.date_effective between
                 dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    dp.fiscal_year = fa_cache_pkg.fazcbc_record.current_fiscal_year;


      -- Fix for Bug#4541399: We have to activate this code
      -- only when px_asset_fin_rec_new.eofy_reserve is NULL
      -- Bug 7138798: If there are no transactions in curent fiscal year
      -- and if depreciate_flag is 'NO' then recalculate eofy_reserve
      if (px_asset_fin_rec_new.eofy_reserve is null) or
         ((l_last_trx_count = 0 )  and
          (px_asset_fin_rec_new.depreciate_flag = 'NO')) then
         px_asset_fin_rec_new.eofy_reserve := p_asset_deprn_rec_new.deprn_reserve -
                                              p_asset_deprn_rec_new.ytd_deprn;
      end if;

   end if;

   -- HHIRAGA
   --+++++++ Call Tracking Function to populate Member in case ALLOCATE ++++++
   if (l_raf_processed_flag) then
     l_dpr_in.tracking_method := 'ALLOCATE';
     l_raf_processed_flag := FALSE;
   end if;

   -- HHIRAGA
   --+++++++ Call Populate_member_assets_table function
   if nvl(l_dpr_in.tracking_method,'OTHER') = 'ALLOCATE' then
     fa_track_member_pvt.p_track_member_table.delete;
     fa_track_member_pvt.p_track_mem_index_table.delete;
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'Delete p_track_member_table', '+++', p_log_level_rec => p_log_level_rec);
     end if;
   end if;

    --Bug6988399 Added the code to populate the eofy reserve if the asset has become non fully reserved after
    -- deprn limit change. Note this has been done only for deprn limit change and the condition can be removed
    -- in future if other cases come
    if ((p_asset_fin_rec_old.period_counter_fully_reserved is not null)
    and ( p_asset_fin_rec_old.period_counter_fully_reserved <> nvl(px_asset_fin_rec_new.period_counter_fully_reserved,0) )
    and  (p_asset_fin_rec_old.allowed_deprn_limit_amount <> px_asset_fin_rec_new.allowed_deprn_limit_amount)
    and  fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'NBV') then
         open c_year_switch;
         fetch c_year_switch into l_year_switch;
         if c_year_switch%NOTFOUND then
                        px_asset_fin_rec_new.eofy_reserve := p_asset_deprn_rec_new.deprn_reserve;
         end if;
        close c_year_switch;
    end if;

   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                       (p_event_type             => 'AMORT_ADJ',
                        p_asset_fin_rec_new      => px_asset_fin_rec_new,
                        p_asset_fin_rec_old      => p_asset_fin_rec_old,
                        p_asset_hdr_rec          => p_asset_hdr_rec,
                        p_asset_type_rec         => p_asset_type_rec,
                        p_asset_deprn_rec        => p_asset_deprn_rec_new,
                        p_trans_rec              => p_trans_rec,
                        p_period_rec             => p_period_rec,
                        p_current_total_rsv      => l_deprn_reserve,
                        p_current_rsv            => l_deprn_reserve -
                                                    p_asset_deprn_rec_new.bonus_deprn_reserve - nvl(p_asset_deprn_rec_new.impairment_reserve,0),
                        p_current_total_ytd      => p_asset_deprn_rec_new.ytd_deprn,
                        p_adj_reserve            => p_asset_deprn_rec_adj.deprn_reserve,
                        p_hyp_basis              => l_dpr_out.new_adj_cost,
                        p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                        p_hyp_rsv                => l_dpr_out.new_deprn_rsv -
                                                    l_dpr_out.new_bonus_deprn_rsv - nvl(l_dpr_out.new_impairment_rsv,0),
                        p_eofy_recoverable_cost  => l_eofy_rec_cost,
                        p_eop_recoverable_cost   => l_eop_rec_cost,
                        p_eofy_salvage_value     => l_eofy_sal_val,
                        p_eop_salvage_value      => l_eop_sal_val,
                        p_mrc_sob_type_code      => p_mrc_sob_type_code,
                        p_used_by_adjustment     => 'ADJUSTMENT',
                        px_new_adjusted_cost     => px_asset_fin_rec_new.adjusted_cost,
                        px_new_raf               => px_asset_fin_rec_new.rate_adjustment_factor,
                        px_new_formula_factor    => px_asset_fin_rec_new.formula_factor,
                        p_log_level_rec => p_log_level_rec)) then
      raise calc_err;
   end if;
    --Bug6736655
    --Calling the createGroup function if the Group asset has been backdated during period of addition
    if (p_trans_rec.transaction_subtype = 'AMORTIZED') and
         (p_trans_rec.transaction_type_code = 'GROUP ADDITION' )
         and p_asset_fin_rec_old.date_placed_in_service > px_asset_fin_rec_new.date_placed_in_service
         then

          if not createGroup(
                         p_trans_rec            => p_trans_rec,
                         p_asset_hdr_rec        => p_asset_hdr_rec,
                         p_asset_type_rec       => p_asset_type_rec,
                         p_period_rec           => p_period_rec,
                         p_asset_fin_rec        => px_asset_fin_rec_new,
                         p_asset_deprn_rec      => p_asset_deprn_rec_adj,
                         p_mrc_sob_type_code    => p_mrc_sob_type_code,
                         p_calling_fn           => l_calling_fn,
               p_log_level_rec => p_log_level_rec) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'calling FA_AMORT_PVT.createGroup', 'FAILED',  p_log_level_rec => p_log_level_rec);
         end if;

         return (FALSE);

        end if;


    end if;
   --++ HHIRAGA
   --++++++++ tracking is allocate case, create bs table
   if nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then

      if not FA_TRACK_MEMBER_PVT.update_member_books(p_trans_rec => p_trans_rec,
                                                     p_asset_hdr_rec => p_asset_hdr_rec,
                                                     p_dpr_in => l_dpr_in,
                                                     p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_TRACK_MEMBER_PVT.update_member_books',  p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fa_track_member_pvt.create_update_bs_table',
                                        'called',  p_log_level_rec => p_log_level_rec);
      end if;

      if not FA_TRACK_MEMBER_PVT.create_update_bs_table(p_trans_rec => p_trans_rec,
                                                        p_book_type_code => p_asset_hdr_rec.book_type_code,
                                                        p_group_asset_id => p_asset_hdr_rec.asset_id,
                                                        p_mrc_sob_type_code => p_mrc_sob_type_code, --Bug 8941132
                                                        p_sob_id            => p_asset_hdr_rec.set_of_books_id, --Bug 8941132
                                                        p_calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_TRACK_MEMBER_PVT.create_update_bs_table',  p_log_level_rec => p_log_level_rec);
         end if;

         raise calc_err;
      end if;

      fa_track_member_pvt.p_track_member_eofy_table.delete;
      fa_track_member_pvt.p_track_member_table.delete;
      fa_track_member_pvt.p_track_mem_index_table.delete;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fa_track_member_pvt.p_track_member_eofy_table/member_table',
                                        'deleted',  p_log_level_rec => p_log_level_rec);
      end if;

   end if; -- nvl(px_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE'
   -- End of HHIRAGA

   -- Bug7715880: BP fix for bug7446301.  Removed tracking method condition so that process
   -- will satisfy following if condition even if the asset type is not GROUP
   -- if (nvl(px_asset_fin_rec_new.tracking_method, 'NO TRACK') = 'ALLOCATE') and    -- ENERGY
   IF  (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') and  -- ENERGY
      (fa_cache_pkg.fazccmt_record.rate_source_rule = FA_STD_TYPES.FAD_RSR_PROD) then
      px_asset_fin_rec_new.adjusted_capacity := nvl(px_asset_fin_rec_new.production_capacity, 0) -
                                                nvl(p_asset_deprn_rec_new.ltd_production, 0);
   end if;

   --
   -- Purpose of calling CurrentPeriodAdj is to reflect the trx to
   -- FA_BOOKS_SUMMARY.  Not for calculating a catch-up.
   -- Call CurrentPeriodAdj if:
   --   This is group asset.
   --   This is current period trx
   --   This is not member ret/rein, group reclass or group reclas with enter.
   --
   if (p_asset_type_rec.asset_type = 'GROUP') and
      (nvl(p_trans_rec.amortization_start_date,
           p_trans_rec.transaction_date_entered) >=
       p_period_rec.calendar_period_open_date) and
      (p_trans_rec.transaction_key not in ('MR', 'MS', 'GC') or
       ((p_trans_rec.transaction_key = 'GC' and
         nvl(p_group_reclass_options_rec.group_reclass_type, 'NULL') = 'MANUAL'))) then

--tk_util.DumpTrxRec(p_trans_rec, 'p_trans_rec');
--tk_util.DumpFinRec(p_asset_fin_rec_old, 'old fin_rec');
--tk_util.DumpFinRec(px_asset_fin_rec_new, 'new_fin_rec');
--tk_util.DumpDeprnRec(p_asset_deprn_rec_adj, 'adj deprn');

      populate_fin_rec(
             p_trans_rec          => p_trans_rec,
             p_asset_fin_rec_old  => p_asset_fin_rec_old,
             p_asset_fin_rec_new  => px_asset_fin_rec_new,
             x_asset_fin_rec_adj  => l_asset_fin_rec_adj,
p_log_level_rec => p_Log_level_rec);

      if (not  CurrentPeriodAdj(
                    p_trans_rec           => p_trans_rec,
                    p_asset_hdr_rec       => p_asset_hdr_rec,
                    p_asset_type_rec      => p_asset_type_rec,
                    p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                    p_asset_fin_rec_old   => p_asset_fin_rec_old,
                    px_asset_fin_rec_new  => px_asset_fin_rec_new,
                    p_period_rec          => p_period_rec,
                    p_asset_deprn_rec_adj => p_asset_deprn_rec_adj,
                    p_proceeds_of_sale    => 0,
                    p_cost_of_removal     => 0,
                    p_calling_fn          => l_calling_fn,
                    p_mrc_sob_type_code   => p_mrc_sob_type_code,
p_log_level_rec => p_Log_level_rec)) then
         raise calc_err;
      end if;

   end if; -- (p_asset_type_rec.asset_type = 'GROUP')

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', px_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END calc_raf_adj_cost;

FUNCTION check_dpis_change (
              p_book_type_code                     VARCHAR2,
              p_transaction_header_id              NUMBER,
              p_group_asset_id                     NUMBER,
              x_asset_fin_rec           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
              x_period_counter_out      OUT NOCOPY NUMBER,
              p_mrc_sob_type_code                  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN is

   l_calling_fn varchar2(100) := 'FA_AMORT_PVT.check_dpis_change';

   CURSOR c_check_dpis_change is
       select inbk.cost
            , inbk.cip_cost
            , inbk.salvage_value
            , inbk.allowed_deprn_limit_amount
            , bs.period_counter
       from   fa_books inbk
            , fa_books outbk
            , fa_transaction_headers inth
            , fa_transaction_headers outth
            , fa_books_summary bs
       where  inbk.transaction_header_id_in   = p_transaction_header_id
       and    outbk.asset_id                  = inbk.asset_id
       and    outbk.book_type_code            = p_book_type_code
       and    outbk.transaction_header_id_out = p_transaction_header_id
       and    outbk.transaction_header_id_in  = outth.transaction_header_id
       and    bs.asset_id                     = p_group_asset_id
       and    bs.book_type_code               = p_book_type_code
       and    nvl(outth.amortization_start_date,
                   outth.transaction_date_entered) between bs.calendar_period_open_date
                                                       and bs.calendar_period_close_date
       and    inbk.cost                       = outbk.cost
       and    nvl(inbk.salvage_value, 0)              = nvl(outbk.salvage_value, 0)
       and    nvl(inbk.allowed_deprn_limit_amount, 0) = nvl(outbk.allowed_deprn_limit_amount, 0)
       and    inbk.date_placed_in_service     <> outbk.date_placed_in_service
;
   chk_err   exception;
BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_transaction_header_id, p_log_level_rec => p_log_level_rec);
   end if;

   OPEN c_check_dpis_change;
   FETCH c_check_dpis_change into x_asset_fin_rec.cost
                                , x_asset_fin_rec.cip_cost
                                , x_asset_fin_rec.salvage_value
                                , x_asset_fin_rec.allowed_deprn_limit_amount
                                , x_period_counter_out;

   CLOSE c_check_dpis_change;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'x_period_counter_out', x_period_counter_out, p_log_level_rec => p_log_level_rec);
   end if;


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'x_period_counter_out', x_period_counter_out, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'x_asset_fin_rec.cost', x_asset_fin_rec.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'End', x_asset_fin_rec.cost, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   when chk_err then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END check_dpis_change;

FUNCTION check_member_existence (
                 p_asset_hdr_rec       IN            FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN is

   l_calling_fn varchar2(100) := 'FA_AMORT_PVT.check_member_existence';

   CURSOR c_mem_exists IS
      select transaction_header_id_in
      from   fa_books
      where  group_asset_id = p_asset_hdr_rec.asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    transaction_header_id_out is null;

   l_temp_thid   NUMBER;

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   OPEN c_mem_exists;
   FETCH c_mem_exists INTO l_temp_thid;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', c_mem_exists%notfound);
   end if;

   if (c_mem_exists%notfound) then
      CLOSE c_mem_exists;
      return true;
   else
      CLOSE c_mem_exists;
      return false;
   end if;

EXCEPTION
   when others then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Error', sqlerrm, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END check_member_existence;


END FA_AMORT_PVT;

/
