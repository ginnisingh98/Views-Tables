--------------------------------------------------------
--  DDL for Package Body FA_TRACK_MEMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRACK_MEMBER_PVT" as
/* $Header: FAVTRACKB.pls 120.55.12010000.13 2010/02/19 10:06:48 anujain ship $ */

function populate_unplanned_exp(p_set_of_books_id IN NUMBER,
                           p_mrc_sob_type_code in VARCHAR2,
                           p_book_type_code IN VARCHAR2,
                           p_period_counter IN NUMBER,
                           p_group_asset_id IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

function search_index_table(p_period_counter IN number,
                      p_member_asset_id in number,
                      p_group_asset_id in number,
                      p_sob_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return number;

procedure put_track_index(p_period_counter IN number,
                          p_member_asset_id in number,
                          p_group_asset_id in number,
                          p_sob_id in number,
                          p_index_value in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

procedure delete_track_index(p_period_counter IN number,
                          p_member_asset_id in number,
                          p_group_asset_id in number,
                          p_sob_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

primary_cost number; -- Used in override function

-- Bug 8703676 : To be used in ins_dd_adj
type num_tbl_type  is table of number        index by binary_integer;
g_primary_trx_hdr_id_tbl num_tbl_type ;

--------------------------------------------------------------------------
--
--   Function: track_assets
--
--   Description:
--      Main logic to track individual asset level amounts.
--
--   Returns:
--      0 - No error / 1 - Error
--
--------------------------------------------------------------------------

FUNCTION track_assets(P_book_type_code             in varchar2,
                      P_group_asset_id             in number,
                      P_period_counter             in number,
                      P_fiscal_year                in number,
                      P_loop_end_year              in number, -- default NULL,
                      P_loop_end_period            in number, -- default NULL,
                      P_group_deprn_basis          in varchar2,
                      P_group_exclude_salvage      in varchar2, -- default NULL,
                      P_group_bonus_rule           in varchar2, -- default NULL,
                      P_group_deprn_amount         in number, -- default 0,
                      P_group_bonus_amount         in number, -- default 0,
                      P_tracking_method            in varchar2, -- default null,
                      P_allocate_to_fully_ret_flag in varchar2, -- default null,
                      P_allocate_to_fully_rsv_flag in varchar2, -- default null,
                      P_excess_allocation_option   in varchar2, -- default 'REDUCE',
                      P_depreciation_option        in varchar2, -- default null,
                      P_member_rollup_flag         in varchar2, -- default null,
                      P_subtraction_flag           in varchar2, -- default NULL,
                      P_group_level_override       in out nocopy varchar2, -- default NULL,
                      P_update_override_status     in boolean, -- default ture,
                      P_period_of_addition         in varchar2, -- default NULL,
                      P_transaction_date_entered   in date, -- default null,
                      P_mode                       in varchar2, -- default NULL,
                      P_mrc_sob_type_code          in varchar2, -- default 'N',
                      p_set_of_books_id            in number,
                      X_new_deprn_amount           out nocopy number,
                      X_new_bonus_amount           out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
  return number is

-- variables for the input and output parameters
x_counter               number;
x_fully_reserved_flag   varchar2(1);
x_fully_retired_flag    varchar2(1);
x_group_deprn_amount    number;
x_group_bonus_amount    number;

h_deprn_calendar        varchar2(15);
h_perds_per_yr          number;
h_period_counter        number;
h_reporting_flag        varchar2(1);
h_dummy                 number;
h_rtn                   boolean := TRUE;

h_loop_end_year         number := nvl(P_loop_end_year,to_number(NULL));
h_loop_end_period       number := nvl(P_loop_end_period,to_number(NULL));

-- Structure for track members
l_track_members         track_member_type;

l_calling_fn        varchar2(35) := 'fa_track_member_pvt.track_assets';

main_err            exception;

-- cursor to check data existing
cursor CHECK_TEMP_TABLE is
  select 1
    from FA_TRACK_MEMBERS
   where group_asset_id = P_group_asset_id
     and period_counter = h_period_counter - 1
     and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

-- cursor to get Period Counter
cursor GET_PERIOD_COUNTER is
  select period_counter
    from fa_deprn_periods
   where book_type_code=P_book_type_code
     and fiscal_year=P_fiscal_year
     and period_num=P_period_counter;

cursor GET_PERIOD_COUNTER_MRC is
  select period_counter
    from fa_mc_deprn_periods
   where book_type_code=P_book_type_code
     and fiscal_year=P_fiscal_year
     and period_num=P_period_counter
     and set_of_books_id = p_set_of_books_id;

begin <<TRACK_ASSETS>>
if (p_log_level_rec.statement_level) then
  fa_debug_pkg.add(l_calling_fn,'== TRACK_ASSET is Started ==','Parameters', p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn,'P_group_asset_id',P_group_asset_id, p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn,'P_fiscal_year:P_period_counter:h_period_counter',P_fiscal_year||':'||P_period_counter||':'||h_period_counter, p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn,'P_group_deprn_amount:P_group_bonus_amount',P_group_deprn_amount||':'||P_group_bonus_amount, p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn,'P_tracking_method:P_mode:P_mrc_sob_type_code',P_tracking_method||':'||P_mode||':'||P_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn,'P_allocate_to_fully_ret:rsv_flag', P_allocate_to_fully_ret_flag||':'||P_allocate_to_fully_rsv_flag, p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn,'P_excess_allocation_option:P_subtraction_flag',P_excess_allocation_option||':'||P_subtraction_flag, p_log_level_rec => p_log_level_rec);
end if;

-- Check if Cache Package has been called:
if FA_CACHE_PKG.fazcbc_record.set_of_books_id is null then
     if (NOT fa_cache_pkg.fazcbc(X_book => P_book_type_code, p_log_level_rec => p_log_level_rec)) then
      raise main_err;
   end if;
end if;

-- Get Period Counter
if p_mrc_sob_type_code <> 'R' then

  open GET_PERIOD_COUNTER;
  fetch GET_PERIOD_COUNTER into h_period_counter;
  if GET_PERIOD_COUNTER%NOTFOUND then
    select deprn_calendar into h_deprn_calendar
      from fa_book_controls
     where book_type_code=P_Book_Type_code;
    if not fa_cache_pkg.fazcct(X_calendar=>h_deprn_calendar, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        raise main_err;
    end if;
    h_perds_per_yr   := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
    h_period_counter := P_fiscal_Year * h_perds_per_yr + P_Period_Counter;
  end if;
  close GET_PERIOD_COUNTER;
else -- For Reporting Book

  open GET_PERIOD_COUNTER_MRC;
  fetch GET_PERIOD_COUNTER_MRC into h_period_counter;
  if GET_PERIOD_COUNTER_MRC%NOTFOUND then
    select deprn_calendar into h_deprn_calendar
      from fa_book_controls
     where book_type_code=P_Book_Type_code;
    if not fa_cache_pkg.fazcct(X_Calendar=>h_deprn_calendar, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        raise main_err;
    end if;
    h_perds_per_yr   := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
    h_period_counter := P_fiscal_Year * h_perds_per_yr + P_Period_Counter;
  end if;
  close GET_PERIOD_COUNTER_MRC;
end if;

if nvl(P_tracking_method,'OTHER') = 'ALLOCATE' then

  -- Call Allocation Logic function
  if not allocate(P_book_type_code => P_book_type_code,
                  P_group_asset_id => P_group_asset_id,
                  P_period_counter => h_period_counter,
                  P_fiscal_year    => P_fiscal_year,
                  P_group_deprn_basis => P_group_deprn_basis,
                  P_group_exclude_salvage => P_group_exclude_salvage,
                  P_group_bonus_rule  => P_group_bonus_rule,
                  P_group_deprn_amount => P_group_deprn_amount,
                  P_group_bonus_amount => P_group_bonus_amount,
                  P_allocate_to_fully_ret_flag => P_allocate_to_fully_ret_flag,
                  P_allocate_to_fully_rsv_flag => P_allocate_to_fully_rsv_flag,
                  P_excess_allocation_option   => P_excess_allocation_option,
                  P_subtraction_flag => P_subtraction_flag,
                  P_group_level_override => P_group_level_override,
                  P_update_override_status => P_update_override_status,
                  P_mrc_sob_type_code    => p_mrc_sob_type_code,
                  P_set_of_books_id      => p_set_of_books_id,
                  P_mode                 => P_mode,
                  X_new_deprn_amount     => X_new_deprn_amount,
                  X_new_bonus_amount     => X_new_bonus_amount,
                  p_log_level_rec => p_log_level_rec) then
      raise main_err;
  end if;

else  -- Calculation Type
  -- Debug
  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn,'P_depreciation_option:P_member_rollup_flag',P_depreciation_option||':'||P_member_rollup_flag, p_log_level_rec => p_log_level_rec);
  end if;
  /* for now, Calculate Method is handled in Depreciation Engine. in this case, this part will be just skipped.  */
end if;

if nvl(P_mode,'DEPRECIATION') = 'UNPLANNED' or
   nvl(P_mode,'DEPRECIATION') = 'GROUP ADJUSTMENT' then

-- This is a case when this program is called from Group Adjustments.
-- So allocated amount will be inserted/updated into FA_ADJUSTMENTS or FA_DEPRN_SUMMARY/DETAIL
-- or FA_BOOKS following P_mode

   if not ins_dd_adj(P_book_type_Code => P_book_type_code,
                     P_group_asset_id => P_group_asset_id,
                     P_period_counter => h_period_counter,
                     P_fiscal_year    => P_fiscal_year,
                     P_period_of_addition => P_period_of_addition,
                     P_transaction_date_entered => P_transaction_date_entered,
                     P_mrc_sob_type_code => P_mrc_sob_type_code,
                     P_set_of_books_id => p_set_of_books_id,
                     P_mode           => P_mode,
                     p_log_level_rec => p_log_level_rec) then
      raise main_err;
   end if;
end if;

return 0;

exception
  when main_err then
    delete fa_track_members;
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return 1;

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return 1;
end TRACK_ASSETS;

--------------------------------------------------------------------------
--
--  Function: allocate
--
--  Description:
--     Calculate the allocated amount based on the parameters
--
--------------------------------------------------------------------------

FUNCTION allocate(P_book_type_code             in varchar2,
                  P_group_asset_id             in number,
                  P_period_counter             in number,
                  P_fiscal_year                in number,
                  P_group_deprn_basis          in varchar2,
                  P_group_exclude_salvage      in varchar2, -- default NULL,
                  P_group_bonus_rule           in varchar2, -- default NULL,
                  P_group_deprn_amount         in number, -- default 0,
                  P_group_bonus_amount         in number, -- default 0,
                  P_allocate_to_fully_ret_flag in varchar2, -- default NULL,
                  P_allocate_to_fully_rsv_flag in varchar2, -- default NULL,
                  P_excess_allocation_option   in varchar2, -- default 'REDUCE',
                  P_subtraction_flag           in varchar2, -- default NULL,
                  P_group_level_override       in out nocopy varchar2, -- default NULL,
                  P_update_override_status     in boolean, -- default true,
                  P_mrc_sob_type_code          in varchar2, -- default 'N',
                  P_set_of_books_id            in number,
                  P_mode                       in varchar2, -- default NULL,
                  X_new_deprn_amount           out nocopy number,
                  X_new_bonus_amount           out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

-- variables for the input and output parameters
h_book_type_code      varchar2(30);
h_group_asset_id      number;
h_period_counter      number;
h_fiscal_year         number;
h_fully_reserved_flag varchar2(1);
h_perds_per_yr        number;

h_rec_cost_for_odda   number; -- Added to fix bug
h_sv_for_odda         number; -- Added to fix bug

h_cost                       number;
h_total_allocation_basis     number;
h_adjusted_recoverable_cost  number;
h_adjusted_cost              number;
h_salvage_value              number;
h_recoverable_cost           number;
h_deprn_reserve              number;
h_ytd_deprn                  number;
h_bonus_deprn_reserve        number;
h_bonus_ytd_deprn            number;

h_excl_sv                    varchar2(1);
h_allocation_basis           number;
h_system_deprn_amount        number;
h_system_bonus_amount        number;
h_difference_deprn_amount    number;
h_difference_bonus_amount    number;

h_total_cost                 number;
h_total_adjusted_cost        number;
h_total_recoverable_cost     number;

h_group_adjusted_cost        number;
h_group_rec_cost             number;

h_member_asset_id            number;
h_adjustment_type            number;
h_adjustment_amount          number;
h_debit_credit_flag          varchar2(30);
h_all_member_fully_reserved  varchar2(1);
h_group_deprn_amount         number;
h_group_bonus_amount         number;
h_catchup_expense            number;
h_catchup_bonus              number;

h_group_expense              number;
h_group_bonus                number;
h_deprn_amount               number;
h_bonus_amount               number;
h_fixed_deprn_amount         number;
h_fixed_bonus_amount         number;

h_member_override_flag       varchar2(1);
h_period_num                 number;
h_current_period_number      number;

h_perd_ctr                   number;
h_adjusted_cost_next_period  number;
h_prior_year_reserve         number;
h_fiscal_year_next_period    number;
h_fully_rsv_member           varchar2(1);
-- variables for work
x_total_allocated_deprn_amount  number;
x_total_allocated_bonus_amount  number;
x_allocated_deprn_amount        number;
x_allocated_bonus_amount        number;
x_check_amount                  number;
x_calc_done                     varchar2(1) := 'N';
x_sum_of_deprn_amount           number;
x_sum_of_bonus_amount           number;
x_check_reserve_flag            varchar2(1);
x_fully_reserved_flag           varchar2(1);
x_allocated_normal_amount       number;


h_reporting_flag             varchar2(1);
h_ds_fy                      number;

h_deprn_expense              number;
h_bonus_expense              number;
h_added_group_deprn_amount   number;
h_added_group_bonus_amount   number;
h_fix_amount_member          number;
h_total_deprn_expense        number;
h_total_bonus_expense        number;

l_track_member_in            track_member_struct;
l_track_member_out           track_member_struct;
l_processed_number           number;
l_last_asset_index           number;

--* unplanned treatment
h_unplanned_member_asset     number;
h_unplanned_expense          number;
h_unplanned_expense_mem      number;

l_reserve_amount             number;  -- ENERGY
l_group_dbr_name             varchar2(80); -- deprn basis rule name for group -- ENERGY
l_temp_num                   number; -- ENERGY
l_temp_char                  varchar2(30);   -- ENERGY
l_temp_bool                  boolean;   -- ENERGY
l_group_reserve              number; -- ENERGY

l_calling_fn                 varchar2(35) := 'fa_track_member_pvt.allocate';
allocate_err                 exception;
allocate_override_err        exception;
-- bug 8394833
   type num_tbl_type  is table of number        index by binary_integer;
   l_mem_asset_id_tbl                               num_tbl_type;
   l_unplanned_exp_tbl                              num_tbl_type;
   l_unplanned_exp_mem_tbl                          num_tbl_type;
   l_batch_size                                     NUMBER;
-- bug 8394833

---- For regular mode
--* Cursor for All Members
  cursor ALL_MEMBERS is
   select bk.asset_id,
          bk.cost,
          decode(h_excl_sv,'N',bk.adjusted_cost,bk.adjusted_cost+bk.salvage_value) adjusted_cost,
          bk.salvage_value,
          bk.recoverable_cost,
          bk.adjusted_recoverable_cost,
          bk.period_counter_fully_retired,
          bk.period_counter_fully_reserved,
          bk.eofy_reserve,
          nvl(ds.period_counter,0) period_counter,
          nvl(ds.deprn_reserve,0) deprn_reserve,
          nvl(ds.ytd_deprn,0) ytd_deprn,
          nvl(ds.bonus_deprn_reserve,0) bonus_deprn_reserve,
          nvl(ds.bonus_ytd_deprn,0) bonus_ytd_deprn
     from fa_books bk,
          fa_deprn_summary ds,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.book_type_code = h_book_type_code
      and bk.date_ineffective is null
      and bk.depreciate_flag = 'YES'
      and ds.book_type_code = h_book_type_code
      and ds.asset_id = bk.asset_id
      and ds.period_counter =
            (select max(ds1.period_counter)
               from fa_deprn_summary ds1
              where ds1.book_type_code = h_book_type_code
                and ds1.asset_id = bk.asset_id
                and ds1.period_counter <= h_period_counter - 1)
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED'
    order by ad.asset_number;

-- ENERGY
  cursor c_get_adj(c_asset_id  number) is
--    select nvl(sum(decode(aj.adjustment_type, 'RESERVE', decode(aj.debit_credit_flag, 'DR', -1, 1) * aj.adjustment_amount,
--                                              'EXPENSE',  )), 0)
    select nvl(sum(decode(aj.adjustment_type, 'RESERVE',decode(aj.debit_credit_flag, 'DR', -1, 1),
                                           'EXPENSE',decode(aj.debit_credit_flag, 'CR', -1, 1))* aj.adjustment_amount), 0)
    from   fa_adjustments aj
    where  aj.asset_id = c_asset_id
    and    aj.book_type_code = h_book_type_code
    and    aj.period_counter_created = h_period_counter
    and    aj.adjustment_type in ('RESERVE',  'EXPENSE');

-- ENERGY
  cursor c_get_mc_adj(c_asset_id  number) is
    select nvl(sum(decode(aj.adjustment_type, 'RESERVE',decode(aj.debit_credit_flag, 'DR', -1, 1),
                                           'EXPENSE',decode(aj.debit_credit_flag, 'CR', -1, 1))* aj.adjustment_amount), 0)
    from   fa_mc_adjustments aj
    where  aj.asset_id = c_asset_id
    and    aj.book_type_code = h_book_type_code
    and    aj.period_counter_created = h_period_counter
    and    aj.adjustment_type in ('RESERVE',  'EXPENSE')
    and    aj.set_of_books_id = p_set_of_books_id;

  cursor ALL_MEMBERS_MRC is
   select bk.asset_id,
          bk.cost,
          decode(h_excl_sv,'N',bk.adjusted_cost,bk.adjusted_cost+bk.salvage_value) adjusted_cost,
          bk.salvage_value,
          bk.recoverable_cost,
          bk.adjusted_recoverable_cost,
          bk.period_counter_fully_retired,
          bk.period_counter_fully_reserved,
          bk.eofy_reserve,
          nvl(ds.period_counter,0) period_counter,
          nvl(ds.deprn_reserve,0) deprn_reserve,
          nvl(ds.ytd_deprn,0) ytd_deprn,
          nvl(ds.bonus_deprn_reserve,0) bonus_deprn_reserve,
          nvl(ds.bonus_ytd_deprn,0) bonus_ytd_deprn
     from fa_mc_books bk,
          fa_mc_deprn_summary ds,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.book_type_code = h_book_type_code
      and bk.date_ineffective is null
      and bk.depreciate_flag = 'YES'
      and bk.set_of_books_id = p_set_of_books_id
      and ds.book_type_code = h_book_type_code
      and ds.asset_id = bk.asset_id
      and ds.period_counter =
            (select max(ds1.period_counter)
               from fa_mc_deprn_summary ds1
              where ds1.book_type_code = h_book_type_code
                and ds1.asset_id = bk.asset_id
                and ds1.set_of_books_id = p_set_of_books_id
                and ds1.period_counter <= h_period_counter - 1)
      and ds.set_of_books_id(+) = p_set_of_books_id
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED'
    order by ad.asset_number;

--* Cursor for All Members total depreciable basis
  cursor ALL_MEMBERS_TOTAL is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.depreciate_flag = 'YES'
      and bk.book_type_code = h_book_type_code
      and ad.asset_id = bk.asset_id
      and ad.asset_type='CAPITALIZED';

  cursor ALL_MEMBERS_TOTAL_MRC is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_mc_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.book_type_code = h_book_type_code
      and bk.set_of_books_id = p_set_of_books_id
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

--* Cursor for total of Members excluded fully retired
  cursor MEMBERS_EX_RETIRED_TOTAL is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.period_counter_fully_retired is null
      and bk.book_type_code = h_book_type_code
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

  cursor MEMBERS_EX_RETIRED_TOTAL_MRC is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_mc_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.period_counter_fully_retired is null
      and bk.book_type_code = h_book_type_code
      and bk.set_of_books_id = p_set_of_books_id
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

--* Cursor for total of Members excluded fully reserved
  cursor MEMBERS_EX_RESERVED_TOTAL is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.period_counter_fully_reserved is null
      and bk.book_type_code = h_book_type_code
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

  cursor MEMBERS_EX_RESERVED_TOTAL_MRC is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_mc_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.period_counter_fully_reserved is null
      and bk.book_type_code = h_book_type_code
      and bk.set_of_books_id = p_set_of_books_id
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

--* Cursor for total of Members excluded both fully retired and fully reserved
  cursor MEMBER_EX_BOTH_TOTAL is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.period_counter_fully_retired is null
      and bk.period_counter_fully_reserved is null
      and bk.book_type_code = h_book_type_code
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

  cursor MEMBER_EX_BOTH_TOTAL_MRC is
   select sum(bk.cost),
          decode(h_excl_sv,'N',sum(bk.adjusted_cost),sum(bk.adjusted_cost+bk.salvage_value)),
          sum(bk.recoverable_cost)
     from fa_mc_books bk,
          fa_additions_b ad
    where bk.group_asset_id = h_group_asset_id
      and bk.date_ineffective is null
      and bk.period_counter_fully_retired is null
      and bk.period_counter_fully_reserved is null
      and bk.book_type_code = h_book_type_code
      and bk.set_of_books_id = p_set_of_books_id
      and bk.depreciate_flag = 'YES'
      and ad.asset_id = bk.asset_id
      and ad.asset_type = 'CAPITALIZED';

--* Cursor to check if the member becomes fully reserved
cursor FULLY_RSV_MEMBER is
  select 'Y'
    from fa_track_members
   where group_asset_id=h_group_asset_id
     and member_asset_id=h_member_asset_id
     and period_counter=h_period_counter
     and (fully_reserved_flag is not null
          or
          fully_retired_flag is not null)
     and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

--* Cursor for Reallocation
cursor REALLOCATE_MEMBER is
  select tr.member_asset_id,
         tr.cost,
         tr.allocation_basis,
         nvl(tr.override_flag,'N') override_flag,
         bk.adjusted_recoverable_cost,
         bk.recoverable_cost,
         bk.salvage_value,
         ds.deprn_reserve,
         ds.ytd_deprn,
         ds.bonus_deprn_reserve,
         ds.bonus_ytd_deprn
    from fa_track_members tr,
         fa_books         bk,
         fa_deprn_summary ds,
         fa_deprn_periods dp,
         fa_additions_b   ad
   where tr.group_asset_id = h_group_asset_id
     and tr.period_counter = h_period_counter
     and tr.fiscal_year = h_fiscal_year
     and nvl(tr.set_of_books_id,-99) = nvl(p_set_of_books_id,-99)
     and nvl(tr.fully_reserved_flag,'N') <> 'Y'
--     and nvl(tr.override_flag,'N') <> 'Y'
     and bk.book_type_code = h_book_type_code
     and bk.asset_id = tr.member_asset_id
     and bk.date_effective <= nvl(dp.period_close_date,sysdate)
     and nvl(bk.date_ineffective,sysdate) >= nvl(dp.period_close_date,sysdate)
     and dp.book_type_code = bk.book_type_code
     and dp.period_counter = h_period_counter
     and ds.book_type_code = bk.book_type_code
     and ds.period_counter = h_period_counter - 1
     and ds.asset_id = bk.asset_id
     and ad.asset_id = bk.asset_id
   order by ad.asset_number;

cursor REALLOCATE_MEMBER_MRC is
  select tr.member_asset_id,
         tr.cost,
         tr.allocation_basis,
         nvl(tr.override_flag,'N') override_flag,
         bk.adjusted_recoverable_cost,
         bk.recoverable_cost,
         bk.salvage_value,
         ds.deprn_reserve,
         ds.ytd_deprn,
         ds.bonus_deprn_reserve,
         ds.bonus_ytd_deprn
    from fa_track_members tr,
         fa_mc_books      bk,
         fa_mc_deprn_summary ds,
         fa_mc_deprn_periods dp,
         fa_additions_b   ad
   where tr.group_asset_id = h_group_asset_id
     and tr.period_counter = h_period_counter
     and tr.fiscal_year = h_fiscal_year
     and nvl(tr.set_of_books_id,-99) = nvl(p_set_of_books_id,-99)
     and nvl(tr.fully_reserved_flag,'N') <> 'Y'
--     and nvl(tr.override_flag,'N') <> 'Y'
     and bk.book_type_code = h_book_type_code
     and bk.asset_id = tr.member_asset_id
     and bk.set_of_books_id = p_set_of_books_id
     and bk.date_effective <= nvl(dp.period_close_date,sysdate)
     and nvl(bk.date_ineffective,sysdate) >= nvl(dp.period_close_date,sysdate)
     and dp.book_type_code = bk.book_type_code
     and dp.period_counter = h_period_counter
     and dp.set_of_books_id = p_set_of_books_id
     and ds.book_type_code = bk.book_type_code
     and ds.period_counter = h_period_counter - 1
     and ds.asset_id = bk.asset_id
     and ds.set_of_books_id = p_set_of_books_id
     and ad.asset_id = bk.asset_id
   order by ad.asset_number;

--* Cursor for Group Adjusted Cost or Recoverable Cost
cursor GROUP_BASIS is
  select decode(h_excl_sv,'N',bk.adjusted_cost,bk.adjusted_cost+bk.salvage_value) adjusted_cost,
         bk.recoverable_cost recoverable_cost
    from fa_books bk
   where bk.book_type_code=h_book_type_code
     and bk.asset_id = h_group_asset_id
     and bk.date_ineffective is null;

cursor GROUP_BASIS_MRC is
  select decode(h_excl_sv,'N',bk.adjusted_cost,bk.adjusted_cost+bk.salvage_value) adjusted_cost,
         bk.recoverable_cost recoverable_cost
    from fa_mc_books bk
   where bk.book_type_code=h_book_type_code
     and bk.asset_id = h_group_asset_id
     and bk.date_ineffective is null
     and bk.set_of_books_id = p_set_of_books_id;

--* cursor to get period number
cursor GET_PERIOD_NUM(p_period_counter number) is
  select period_num
    from fa_deprn_periods
   where book_type_code = h_book_type_code
     and period_counter = p_period_counter;

cursor GET_PERIOD_NUM_MRC(p_period_counter number) is
  select period_num
    from fa_mc_deprn_periods
   where book_type_code = h_book_type_code
     and period_counter = p_period_counter
     and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

--* Cursor for FA_ADJUSTMENTS
cursor FA_ADJ_EXPENSE(p_member_asset_id number) is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_transaction_headers th1,
          fa_transaction_headers th2,
          fa_adjustments adj
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = nvl(p_member_asset_id,th2.asset_id);

cursor FA_ADJ_EXPENSE_MRC (p_member_asset_id number) is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_mc_adjustments adj,
          fa_transaction_headers th1,
          fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and adj.set_of_books_id = p_set_of_books_id
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = nvl(p_member_asset_id,th2.asset_id);

--* Cursor for member assets not to reallocate
cursor FIX_AMOUNT_MEMBER is
  select member_asset_id
    from fa_track_members
   where group_asset_id = P_group_asset_id
     and period_counter = P_period_counter
     and fiscal_year = P_fiscal_year
     and (nvl(fully_reserved_flag,'N') = 'Y' or nvl(override_flag,'N') = 'Y');

--* Cursor for FA_ADJUSTMENTS for unplanned depreciation
cursor FA_ADJ_UNPLANNED is
   select /*+ ORDERED Index(TH2 FA_TRANSACTION_HEADERS_N1)
               INDEX(TH1 FA_TRANSACTION_HEADERS_N7)
               INDEX(ADJ FA_ADJUSTMENTS_U1)*/
       sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_transaction_headers th2,
          fa_transaction_headers th1,
          fa_adjustments adj
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = h_unplanned_member_asset
      and th2.transaction_type_code = 'ADJUSTMENT'
      and th2.transaction_key in ('UA','UE');

cursor FA_ADJ_UNPLANNED_MEM is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_adjustments adj,
          fa_transaction_headers th
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_unplanned_member_asset
      and adj.period_counter_adjusted = h_period_counter
      and adj.transaction_header_id = th.transaction_header_id
      and th.transaction_type_code = 'ADJUSTMENT'
      and th.transaction_key in ('UA','UE')
      and nvl(adj.track_member_flag,'N') = 'N';

cursor FA_ADJ_UNPLANNED_MRC is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_mc_adjustments adj,
          fa_transaction_headers th1,
          fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and adj.set_of_books_id = p_set_of_books_id
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = h_unplanned_member_asset
      and th2.transaction_type_code = 'ADJUSTMENT'
      and th2.transaction_key in ('UA','UE');

cursor FA_ADJ_UNPLANNED_MEM_MRC is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_mc_adjustments adj,
          fa_transaction_headers th
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.set_of_books_id = p_set_of_books_id
      and adj.period_counter_adjusted = h_period_counter
      and adj.transaction_header_id = th.transaction_header_id
      and th.transaction_type_code = 'ADJUSTMENT'
      and th.transaction_key in ('UA','UE');

-- Bug # 8394833 Added below index hint to improve the performance
cursor C_MEM_UNPLAN_ADJ is
   select /*+ Index (TM fa_track_members_N1) */
              member_asset_id
             ,sum(decode(adj.adjustment_type,'EXPENSE'
                 , decode(adj.debit_credit_flag, 'DR',adj.adjustment_amount
                 , 'CR', -1 * adj.adjustment_amount))
                 )
   from  fa_track_members tm
         , fa_adjustments adj
         , fa_transaction_headers th1
         , fa_transaction_headers th2
   where tm.group_asset_id = P_group_asset_id
     and tm.period_counter = P_period_counter
     and tm.fiscal_year = P_fiscal_year
     and nvl(tm.set_of_books_id,-99) = nvl(p_set_of_books_id,-99)
     and adj.transaction_header_id = th1.transaction_header_id
     and adj.asset_id = h_group_asset_id
     and adj.book_type_code = h_book_type_code
     and adj.period_counter_adjusted = h_period_counter
     and th1.asset_id = adj.asset_id
     and th1.member_transaction_header_id = th2.transaction_header_id
     and tm.member_asset_id = th2.asset_id  /* h_unplanned_member_asset */
     and th2.transaction_type_code = 'ADJUSTMENT'
     and th2.transaction_key in ('UA','UE')
   Group by member_asset_id;

cursor C_MEM_UNPLAN_ADJ_MRC is
   select /*+ Index (TM fa_track_members_N1) */
              member_asset_id
             ,sum(decode(adj.adjustment_type,'EXPENSE'
                 , decode(adj.debit_credit_flag, 'DR',adj.adjustment_amount
                 , 'CR', -1 * adj.adjustment_amount))
                 )
   from  fa_track_members tm
         , fa_mc_adjustments adj
         , fa_transaction_headers th1
         , fa_transaction_headers th2
   where tm.group_asset_id = P_group_asset_id
      and tm.period_counter = P_period_counter
      and tm.fiscal_year = P_fiscal_year
      and nvl(tm.set_of_books_id,-99) = nvl(p_set_of_books_id,-99)
      and adj.transaction_header_id = th1.transaction_header_id
      and adj.set_of_books_id = p_set_of_books_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and tm.member_asset_id = th2.asset_id  /* h_unplanned_member_asset */
      and th2.transaction_type_code = 'ADJUSTMENT'
      and th2.transaction_key in ('UA','UE')
   Group by member_asset_id;

-- ENERGY
-- ENERGY
cursor c_get_basis_rule_name is
  select db.rule_name
  from   fa_deprn_basis_rules db
       , fa_methods mt
       , fa_books bk
  where  db.deprn_basis_rule_id = mt.deprn_basis_rule_id
  and    mt.method_code = bk.deprn_method_code
  and    nvl(mt.life_in_months, -99) = nvl(bk.life_in_months, -99)
  and    bk.book_type_code = h_book_type_code
  and    bk.asset_id = P_group_asset_id
  and    bk.transaction_header_id_out is null;
-- ENERGY
-- ENERGY

--Bug 6809835, 6879353
l_total_reserve number;
l_check_amount  number;

main_err            exception;

BEGIN <<ALLOCATE>>

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'++ ALLOCATE Started ++','+++', p_log_level_rec => p_log_level_rec);
   end if;

   -- Set parameters into internal variables
   h_group_asset_id := P_group_asset_id;
   h_book_type_code := P_book_type_code;
   h_period_counter := P_period_counter;
   h_fiscal_year     := P_fiscal_year;

   -- Apply MRC related feature --
   if p_mrc_sob_type_code <> 'R' then

      open GET_PERIOD_NUM(h_period_counter);
      fetch GET_PERIOD_NUM into h_current_period_number;

      if GET_PERIOD_NUM%NOTFOUND then
         h_current_period_number := h_period_counter - (h_fiscal_year * h_perds_per_yr);
      end if;

      close GET_PERIOD_NUM;
   else

      open GET_PERIOD_NUM_MRC(h_period_counter);
      fetch GET_PERIOD_NUM_MRC into h_current_period_number;

      if GET_PERIOD_NUM_MRC%NOTFOUND then
         h_current_period_number := h_period_counter - (h_fiscal_year * h_perds_per_yr);
      end if;

      close GET_PERIOD_NUM_MRC;
   end if;

   h_perds_per_yr   := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'h_sob_id:book:period_ctr:cur_period_num:perds_per_fy'
                                   , p_set_of_books_id||':'||h_book_type_code||':'||
                                     h_period_counter||':'||h_current_period_number||':'||h_perds_per_yr, p_log_level_rec => p_log_level_rec);
   end if;

   l_group_dbr_name := null;                            -- ENERGY
                                                        -- ENERGY
   OPEN c_get_basis_rule_name;                          -- ENERGY
   FETCH c_get_basis_rule_name INTO l_group_dbr_name;   -- ENERGY
   CLOSE c_get_basis_rule_name;                         -- ENERGY

   if (l_group_dbr_name = 'ENERGY PERIOD END BALANCE') then

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Call',
                                'fa_query_balances_pkg.query_balances', p_log_level_rec => p_log_level_rec);
      end if;

      fa_query_balances_pkg.query_balances(
                      X_asset_id => p_group_asset_id,
                      X_book => P_book_type_code,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_group_reserve,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_temp_num,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_temp_num,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                      X_set_of_books_id => p_set_of_books_id,
                      p_log_level_rec => p_log_level_rec);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_group_reserve',
                                l_group_reserve, p_log_level_rec => p_log_level_rec);
      end if;

   end if; -- (l_group_dbr_name = 'ENERGY PERIOD END BALANCE')

   if nvl(P_group_exclude_salvage,'N') in ('YES','Y') then
      h_excl_sv := 'Y';
   else
      h_excl_sv := 'N';
   end if;

   -- Initialize the variables
   x_total_allocated_deprn_amount := 0;
   x_total_allocated_bonus_amount := 0;
   x_check_reserve_flag  := 'Y';

   if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

      if not p_track_member_table.exists(1) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'populate previous rows', 'call here', p_log_level_rec => p_log_level_rec);
         end if;

         if not populate_previous_rows(p_book_type_code => h_book_type_code,
                                       p_group_asset_id => h_group_asset_id,
                                       p_period_counter => h_period_counter,
                                       p_fiscal_year    => h_fiscal_year,
                                       p_transaction_header_id => null,
                                       p_allocate_to_fully_ret_flag => nvl(P_allocate_to_fully_ret_flag,'N'),
                                       p_allocate_to_fully_rsv_flag => nvl(P_allocate_to_fully_rsv_flag,'N'),
                                       p_mrc_sob_type_code => P_mrc_sob_type_code,
                                       p_set_of_books_id => P_set_of_books_id,
                                       p_log_level_rec => p_log_level_rec) then
            raise allocate_err;
         end if;
      end if; -- End of preparion for Adjustment mode
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Before start to loop for total amounts:p_track_member_table.COUNT',
                       p_track_member_table.count, p_log_level_rec => p_log_level_rec);
   end if;

   -- Get the Allocation Basis
   if nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' then

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

         h_total_cost := 0;
         h_total_adjusted_cost := 0;
         h_total_recoverable_cost := 0;

-- issue query against fa_books_summary
         For i IN 1 .. p_track_member_table.COUNT LOOP

            if p_track_member_table(i).group_asset_id = h_group_asset_id and
               p_track_member_table(i).period_counter = h_period_counter and
               nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then

               if nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N' and
                  nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N' then

                  h_total_cost := h_total_cost + p_track_member_table(i).cost;
                  h_total_recoverable_cost := h_total_recoverable_cost + p_track_member_table(i).recoverable_cost;

                  if h_excl_sv = 'Y' then
                     h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost +
                                              p_track_member_table(i).salvage_value;
                  else
                     h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost;
                  end if;
               end if;
            end if;

         END LOOP;

      else -- Regular Mode
         --Bug6795984
--bug6919091         if p_mrc_sob_type_code <> 'R' then
--bug6919091            open MEMBERS_EX_RETIRED_TOTAL;
--bug6919091            fetch MEMBERS_EX_RETIRED_TOTAL into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
--bug6919091            close MEMBERS_EX_RETIRED_TOTAL;
--bug6919091         else
--bug6919091            open MEMBERS_EX_RETIRED_TOTAL_MRC;
--bug6919091            fetch MEMBERS_EX_RETIRED_TOTAL_MRC into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
--bug6919091            close MEMBERS_EX_RETIRED_TOTAL_MRC;
--bug6919091         end if;

         if p_mrc_sob_type_code <> 'R' then
            open MEMBER_EX_BOTH_TOTAL;
            fetch MEMBER_EX_BOTH_TOTAL into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
            close MEMBER_EX_BOTH_TOTAL;
         else -- Reporting Book
            open MEMBER_EX_BOTH_TOTAL_MRC;
            fetch MEMBER_EX_BOTH_TOTAL_MRC into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
            close MEMBER_EX_BOTH_TOTAL_MRC;
         end if;
      end if; -- nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

   elsif nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y' then

      x_check_reserve_flag := 'N';

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

         h_total_cost := 0;
         h_total_adjusted_cost := 0;
         h_total_recoverable_cost := 0;

         For i IN 1 .. p_track_member_table.COUNT LOOP

            if p_track_member_table(i).group_asset_id = h_group_asset_id and
               p_track_member_table(i).period_counter = h_period_counter and
               nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then

               if nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N' then
                  h_total_cost := h_total_cost + p_track_member_table(i).cost;
                  h_total_recoverable_cost := h_total_recoverable_cost + p_track_member_table(i).recoverable_cost;

                  if h_excl_sv = 'Y' then
                     h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost +
                                              p_track_member_table(i).salvage_value;
                  else
                     h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost;
                  end if;
               end if;
            end if;

         END LOOP;

      else -- Regular Mode
         if p_mrc_sob_type_code <> 'R' then
            open MEMBERS_EX_RETIRED_TOTAL;
            fetch MEMBERS_EX_RETIRED_TOTAL into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
            close MEMBERS_EX_RETIRED_TOTAL;
         else
            open MEMBERS_EX_RETIRED_TOTAL_MRC;
            fetch MEMBERS_EX_RETIRED_TOTAL_MRC into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
            close MEMBERS_EX_RETIRED_TOTAL_MRC;
         end if;
      end if;

   elsif nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' then

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

         h_total_cost := 0;
         h_total_adjusted_cost := 0;
         h_total_recoverable_cost := 0;

         For i IN 1 .. p_track_member_table.COUNT LOOP

            if p_track_member_table(i).group_asset_id = h_group_asset_id and
               p_track_member_table(i).period_counter = h_period_counter and
               nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then

               if nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N' then
                  h_total_cost := h_total_cost + p_track_member_table(i).cost;
                  h_total_recoverable_cost := h_total_recoverable_cost + p_track_member_table(i).recoverable_cost;

                  if h_excl_sv = 'Y' then
                     h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost +
                     p_track_member_table(i).salvage_value;
                  else
                     h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost;
                  end if;
               end if;
            end if;

         END LOOP;

      else -- Regular Mode
        --Bug6795984
--bug6919091        if p_mrc_sob_type_code <> 'R' then
--bug6919091            open ALL_MEMBERS_TOTAL;
--bug6919091            fetch ALL_MEMBERS_TOTAL into h_total_cost, h_total_adjusted_cost,h_total_recoverable_cost;
--bug6919091            close ALL_MEMBERS_TOTAL;
--bug6919091         else
--bug6919091            open ALL_MEMBERS_TOTAL_MRC;
--bug6919091            fetch ALL_MEMBERS_TOTAL_MRC into h_total_cost, h_total_adjusted_cost,h_total_recoverable_cost;
--bug6919091            close ALL_MEMBERS_TOTAL_MRC;
--bug6919091         end if;

         if p_mrc_sob_type_code <> 'R' then
            open MEMBERS_EX_RESERVED_TOTAL;
            fetch MEMBERS_EX_RESERVED_TOTAL into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
            close MEMBERS_EX_RESERVED_TOTAL;
         else
            open MEMBERS_EX_RESERVED_TOTAL_MRC;
            fetch MEMBERS_EX_RESERVED_TOTAL_MRC into h_total_cost,h_total_adjusted_cost,h_total_recoverable_cost;
            close MEMBERS_EX_RESERVED_TOTAL_MRC;
         end if;
      end if;

   else -- Both are 'Y'

      x_check_reserve_flag := 'N';

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

         h_total_cost := 0;
         h_total_adjusted_cost := 0;
         h_total_recoverable_cost := 0;

         For i IN 1 .. p_track_member_table.COUNT LOOP

            if p_track_member_table(i).group_asset_id = h_group_asset_id and
               p_track_member_table(i).period_counter = h_period_counter and
               nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then

               h_total_cost := h_total_cost + p_track_member_table(i).cost;
               h_total_recoverable_cost := h_total_recoverable_cost + p_track_member_table(i).recoverable_cost;

               if h_excl_sv = 'Y' then
                  h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost +
                  p_track_member_table(i).salvage_value;
               else
                  h_total_adjusted_cost := h_total_adjusted_cost + p_track_member_table(i).adjusted_cost;
               end if;
            end if;

         END LOOP;

      else -- Regular Mode
         if p_mrc_sob_type_code <> 'R' then
            open ALL_MEMBERS_TOTAL;
            fetch ALL_MEMBERS_TOTAL into h_total_cost, h_total_adjusted_cost,h_total_recoverable_cost;
            close ALL_MEMBERS_TOTAL;
         else
            open ALL_MEMBERS_TOTAL_MRC;
            fetch ALL_MEMBERS_TOTAL_MRC into h_total_cost, h_total_adjusted_cost,h_total_recoverable_cost;
            close ALL_MEMBERS_TOTAL_MRC;
         end if;
      end if;
   end if; -- Total allocation basis logic end

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'h_total_cost:h_total_adj_cost:h_total_rec_cost',
                       h_total_cost||':'||h_total_adjusted_cost||':'||h_total_recoverable_cost, p_log_level_rec => p_log_level_rec);
   end if;

   --* Calculate allocated amounts for all member assets
   -- Set Total Allocation Base for Denominator
   -- Bug7487450: Removed energy specific treatment as NBV part below
   --             takes care the calculation
   if P_group_deprn_basis = 'COST' then
      h_total_allocation_basis := h_total_recoverable_cost;
   else
      h_total_allocation_basis := h_total_adjusted_cost;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'P_mode', P_mode, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_group_dbr_name', l_group_dbr_name, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'P_group_deprn_basis', P_group_deprn_basis, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'h_total_allocation_basis', h_total_allocation_basis, p_log_level_rec => p_log_level_rec);
   end if;

   --bug6923135
   -- bypassing following check if the mode is DEPRECIATION so that even allocation basis is zero,
   -- member asset retired in this period will be picked up and gets row in FA_TRACK_MEMBERS and
   -- eventually gets rows in DD and DS.  Since I do not know the impact for ADJUSTMENT case, lifting this
   -- for DEPRECIATION only
   if nvl(h_total_allocation_basis,0) = 0
                  and nvl(P_mode,'DEPRECIATION') <> 'DEPRECIATION' --bug6923135
               then -- Since system cannot calculate the allocation
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Since total allocation basis is ZERO','Skip out this function', p_log_level_rec => p_log_level_rec);
      end if;

      goto skip_allocate;
   end if;


   -- Adjustment Mode
   if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

      -- Get period Number
      open GET_PERIOD_NUM(P_period_counter+1);
      fetch GET_PERIOD_NUM into h_perd_ctr;

      if GET_PERIOD_NUM%NOTFOUND then
         h_perd_ctr := (P_period_counter + 1) - (h_fiscal_year * h_perds_per_yr);

         if h_perd_ctr > h_perds_per_yr then
            h_perd_ctr := h_perd_ctr - h_perds_per_yr;
         end if;
      end if;

      close GET_PERIOD_NUM;

      For i in 1 .. p_track_member_table.COUNT loop

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'adjustment-loop started: indicator of this loop', i, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'+++ In Loop (1) +++','+++');
         end if;

         if p_track_member_table(i).group_asset_id = h_group_asset_id and
            p_track_member_table(i).period_counter = h_period_counter and
            nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then

            if (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
                nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N' and
                nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N')
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
                nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N')
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y' and
                nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N')
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y') then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,
                                   'table('||i||').group_asset_id:period_counter,sob_id,reserved_flag:retired_flag ',
                                   p_track_member_table(i).group_Asset_id||':'||
                                   p_track_member_table(i).period_counter||
                                   ':'|| p_track_member_table(i).set_of_books_id||':'||
                                   p_track_member_table(i).fully_reserved_flag||':'||
                                   p_track_member_table(i).fully_retired_flag);
               end if;

               l_track_member_in := p_track_member_table(i);
               h_deprn_reserve := nvl(l_track_member_in.deprn_reserve,0);
               h_bonus_deprn_reserve := nvl(l_track_member_in.bonus_deprn_reserve,0);
               h_member_asset_id := l_track_member_in.member_asset_id;

               if h_current_period_number = 1 then
                  h_ytd_deprn  := 0;
                  h_bonus_ytd_deprn := 0;
               else
                  h_ytd_deprn     := p_track_member_table(i).ytd_deprn;
                  h_bonus_ytd_deprn := p_track_member_table(i).bonus_ytd_deprn;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '+++ In Loop (2) ++ Loop indicator ', i);
                  fa_debug_pkg.add(l_calling_fn, 'member_in.member_asset_id:deprn_reserve',
                                   l_track_member_in.member_asset_id||':'||l_track_member_in.deprn_reserve, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'h_period_num:h_ytd_deprn', h_perd_ctr||':'||h_ytd_deprn, p_log_level_rec => p_log_level_rec);
               end if;

               -- Set Allocation Basis
                                                                               -- ENERGY
               if (l_group_dbr_name = 'ENERGY PERIOD END BALANCE') then        -- ENERGY
                  h_allocation_basis := p_track_member_table(i).adjusted_cost; -- ENERGY
               elsif P_group_deprn_basis = 'COST' then                         -- ENERGY
                  h_allocation_basis := p_track_member_table(i).recoverable_cost;
               elsif h_excl_sv = 'Y' then
                  h_allocation_basis := p_track_member_table(i).adjusted_cost + p_track_member_table(i).salvage_value;
               else
                  h_allocation_basis := p_track_member_table(i).adjusted_cost;
               end if;

               h_rec_cost_for_odda := p_track_member_table(i).recoverable_cost;
               h_sv_for_odda := p_track_member_table(i).salvage_value;

               h_deprn_amount := P_group_deprn_amount;
               h_bonus_amount := nvl(P_group_bonus_amount,0);
               x_calc_done := 'N';

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '+++ In Loop (3) ++ Before call allocation_main', '+++');
                  fa_debug_pkg.add(l_calling_fn, 'h_allocation_basis:total_allocation_basis:check_reserve_flag',
                                   h_allocation_basis||':'||h_total_allocation_basis||':'|| x_check_reserve_flag, p_log_level_rec => p_log_level_rec);
               end if;

               -- Call Allocation_main to allocate the group amount to member assets
               if not allocation_main(P_book_type_code => h_book_type_code,
                                      P_group_asset_id => h_group_asset_id,
                                      P_member_asset_id => l_track_member_in.member_asset_id,
                                      P_period_counter => h_period_counter,
                                      P_fiscal_year => h_fiscal_year,
                                      P_group_bonus_rule => P_group_bonus_rule,
                                      P_group_deprn_amount => h_deprn_amount,
                                      P_group_bonus_amount => h_bonus_amount,
                                      P_allocation_basis => h_allocation_basis,
                                      P_total_allocation_basis => h_total_allocation_basis,
                                      P_ytd_deprn => h_ytd_deprn,
                                      P_bonus_ytd_deprn => h_bonus_ytd_deprn,
                                      P_track_member_in => l_track_member_in,
                                      P_check_reserve_flag => x_check_reserve_flag,
                                      P_subtraction_flag => P_subtraction_flag,
                                      P_group_level_override => P_group_level_override,
                                      P_update_override_status => P_update_override_status,
                                      PX_difference_deprn_amount => h_difference_deprn_amount,
                                      PX_difference_bonus_amount => h_difference_bonus_amount,
                                      X_system_deprn_amount => h_system_deprn_amount,
                                      X_system_bonus_amount => h_system_bonus_amount,
                                      X_track_member_out => l_track_member_out,
                                      P_mrc_sob_type_code => P_mrc_sob_type_code,
                                      P_set_of_books_id => p_set_of_books_id,
                                      P_mode => P_mode,
                                      P_rec_cost_for_odda => h_rec_cost_for_odda,
                                      P_sv_for_odda => h_sv_for_odda,
                                      p_log_level_rec => p_log_level_rec) then
                  raise allocate_err;
               end if; -- call allocation_main

               x_calc_done := 'Y';

               if h_perd_ctr <> 1 then
                  h_prior_year_reserve := nvl(p_track_member_table(i).eofy_reserve,0);
                  h_fiscal_year_next_period := h_fiscal_year;
               else -- This is the first period of the fiscal year
                  h_prior_year_reserve := nvl(l_track_member_out.deprn_reserve,0);
                  h_fiscal_year_next_period := h_fiscal_year + 1;
               end if;

               -- Update current period row of P_TRACK_MEMBER table
               if p_track_member_table(i).group_asset_id = h_group_Asset_id and
                  p_track_member_table(i).member_asset_id = l_track_member_in.member_asset_id and
                  p_track_member_table(i).period_counter = h_period_counter and
                  p_track_member_table(i).fiscal_year = h_fiscal_year and
                  p_track_member_table(i).set_of_books_id = nvl(p_set_of_books_id, -99) then

                  p_track_member_table(i).cost := l_track_member_out.cost;
                  p_track_member_table(i).adjusted_cost := l_track_member_out.adjusted_cost;
                  p_track_member_table(i).recoverable_cost := l_track_member_out.recoverable_cost;
                  p_track_member_table(i).salvage_value := l_track_member_out.salvage_value;
                  p_track_member_table(i).adjusted_recoverable_cost := l_track_member_out.adjusted_recoverable_cost;
                  p_track_member_table(i).allocation_basis := l_track_member_out.allocation_basis;
                  p_track_member_table(i).total_allocation_basis := l_track_member_out.total_allocation_basis;
                  p_track_member_table(i).allocated_deprn_amount := l_track_member_out.allocated_deprn_amount;
                  p_track_member_table(i).allocated_bonus_amount := l_track_member_out.allocated_bonus_amount;
                  p_track_member_table(i).fully_reserved_flag := l_track_member_out.fully_reserved_flag;
                  p_track_member_table(i).system_deprn_amount := l_track_member_out.system_deprn_amount;
                  p_track_member_table(i).system_bonus_amount := l_track_member_out.system_bonus_amount;
                  p_track_member_table(i).override_flag := l_track_member_out.override_flag;
                  p_track_member_table(i).deprn_reserve := l_track_member_out.deprn_reserve;
                  p_track_member_table(i).ytd_deprn := l_track_member_out.ytd_deprn;
                  p_track_member_table(i).bonus_deprn_reserve := l_track_member_out.bonus_deprn_reserve;
                  p_track_member_table(i).bonus_ytd_deprn := l_track_member_out.bonus_ytd_deprn;

                  l_last_asset_index := i;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Updated current period row into p_track_member_table', '***');

                     if not display_debug_message2(i, l_calling_fn,
p_log_level_rec) then
                        fa_debug_pkg.add(l_calling_fn, 'display_debug_message2', 'error returned', p_log_level_rec => p_log_level_rec);
                     end if;

                  end if;
               end if;

            end if;

         end if; -- This record is for this group and period?

      end loop;

   else -- Regular Mode

      h_deprn_amount := P_group_deprn_amount;
      h_bonus_amount := nvl(P_group_bonus_amount,0);

      -- Added code for group depreciation amount in case of year end balance
      -- passed group amount doesn't include current period catchup expense,
      -- so add up the catchup expense at this place
      if nvl(P_subtraction_flag,'N') = 'Y' then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'++ Start to add current period expense catch up ++','+++', p_log_level_rec => p_log_level_rec);
         end if;

         if p_mrc_sob_type_code <> 'R' then
            -- Get group level adjustment
            open FA_ADJ_EXPENSE(to_number(NULL));
            fetch FA_ADJ_EXPENSE into h_deprn_expense, h_bonus_expense;
            close FA_ADJ_EXPENSE;
         else
            -- Get group level adjustment
            open FA_ADJ_EXPENSE_MRC(to_number(NULL));
            fetch FA_ADJ_EXPENSE_MRC into h_deprn_expense, h_bonus_expense;
            close FA_ADJ_EXPENSE_MRC;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'h_deprn_expense:h_bonus_expense', h_deprn_expense||':'||h_bonus_expense, p_log_level_rec => p_log_level_rec);
         end if;

  --       h_deprn_amount := h_deprn_amount + nvl(h_deprn_expense,0);
  --       h_bonus_amount := h_bonus_amount + nvl(h_bonus_expense,0);
      end if;

      h_added_group_deprn_amount := h_deprn_amount;
      h_added_group_bonus_amount := h_bonus_amount;

      if p_mrc_sob_type_code <> 'R' then

         For mem in ALL_MEMBERS loop
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'asset_id', mem.asset_id, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'P_allocate_to_fully_ret_flag', P_allocate_to_fully_ret_flag, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'P_allocate_to_fully_rsv_flag', P_allocate_to_fully_rsv_flag, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'mem.period_counter_fully_reserved', mem.period_counter_fully_reserved, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'mem.period_counter_fully_retired', mem.period_counter_fully_retired, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'h_period_counter', h_period_counter, p_log_level_rec => p_log_level_rec);

               fa_debug_pkg.add(l_calling_fn,'regular-loop started: ', '(1)++Primary/Non-MRC Book');
               fa_debug_pkg.add(l_calling_fn,'+++ In Loop (1) +++','+++');
            end if;

            --ENERGY
            if (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
               (mem.period_counter_fully_reserved is NULL or mem.period_counter_fully_reserved = h_period_counter) and /*Bug#9145376 */
               (mem.period_counter_fully_retired is NULL  or mem.period_counter_fully_retired = h_period_counter)) -- ENERGY
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and -- Bug6923135
                (mem.period_counter_fully_retired = h_period_counter))                                          -- Bug6923135
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
                mem.period_counter_fully_reserved is NULL)
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y' and
                (mem.period_counter_fully_retired is NULL or mem.period_counter_fully_retired = h_period_counter)) -- ENERGY
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y') then

              l_reserve_amount := 0;                  -- ENERGY
              OPEN c_get_adj(mem.asset_id);           -- ENERGY
              FETCH c_get_adj INTO l_reserve_amount;  -- ENERGY
              CLOSE c_get_adj;                        -- ENERGY
              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn,'l_reserve_amount', l_reserve_amount, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn,'mem.deprn_reserve', mem.deprn_reserve, p_log_level_rec => p_log_level_rec);
              end if;

               l_track_member_in.deprn_reserve := mem.deprn_reserve + l_reserve_amount; -- ENERGY
               l_track_member_in.reserve_adjustment_amount := l_reserve_amount;         -- ENERGY
--               h_deprn_reserve := mem.deprn_reserve;                                  -- ENERGY
                h_deprn_reserve := mem.deprn_reserve + l_reserve_amount;                -- ENERGY
               h_member_asset_id := mem.asset_id;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '+++ In Loop (2) ++ Member Asset to be processed ',
                                   h_member_asset_id);
               end if;

               -- Check fiscal year of populated deprn summary
               select fiscal_year into h_ds_fy
                 from fa_deprn_periods
                where book_type_code = h_book_type_code
                  and period_counter = mem.period_counter;

               if h_fiscal_year <> h_ds_fy then
                  mem.ytd_deprn := 0;
                  mem.bonus_ytd_deprn := 0;
               end if;

               if h_current_period_number = 1 then
                  h_ytd_deprn := 0;
                  h_bonus_ytd_deprn := 0;
               else
                  h_ytd_deprn := mem.ytd_deprn;
                  h_bonus_ytd_deprn := mem.bonus_ytd_deprn;
               end if;

               l_track_member_in.bonus_deprn_reserve := mem.bonus_deprn_reserve;
               l_track_member_in.member_asset_id := mem.asset_id;
               l_track_member_in.salvage_value   := mem.salvage_value;

               if h_excl_sv = 'Y' then
                  l_track_member_in.adjusted_cost := mem.adjusted_cost - mem.salvage_value;
               else
                  l_track_member_in.adjusted_cost := mem.adjusted_cost;
               end if;

               l_track_member_in.recoverable_cost := mem.recoverable_cost;
               h_recoverable_cost := l_track_member_in.recoverable_cost;
               l_track_member_in.adjusted_recoverable_cost := mem.adjusted_recoverable_cost;
               h_adjusted_recoverable_cost := l_track_member_in.adjusted_recoverable_cost;
               l_track_member_in.cost := mem.cost;

               -- Set Allocation Basis
               if (l_group_dbr_name = 'ENERGY PERIOD END BALANCE') then        -- ENERGY
                  h_allocation_basis := l_track_member_in.recoverable_cost - l_track_member_in.deprn_reserve; -- ENERGY
               elsif P_group_deprn_basis = 'COST' then                         -- ENERGY
                  h_allocation_basis := mem.recoverable_cost;
               else
                  h_allocation_basis := mem.adjusted_cost;
               end if;

               h_rec_cost_for_odda := mem.recoverable_cost;
               h_sv_for_odda := mem.salvage_value;

               x_calc_done := 'N';

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '+++ In Loop (3) ++ Before call allocation_main', '+++');
                  fa_debug_pkg.add(l_calling_fn, 'h_allocation_basis:total_allocation_basis:check_reserve_flag',
                                   h_allocation_basis||':'||h_total_allocation_basis||':'||x_check_reserve_flag, p_log_level_rec => p_log_level_rec);
               end if;

               -- Call Allocation_main to allocate the group amount to member assets
               if not allocation_main(P_book_type_code => h_book_type_code,
                                      P_group_asset_id => h_group_asset_id,
                                      P_member_asset_id => mem.asset_id,
                                      P_period_counter => h_period_counter,
                                      P_fiscal_year => h_fiscal_year,
                                      P_group_bonus_rule => P_group_bonus_rule,
                                      P_group_deprn_amount => h_deprn_amount,
                                      P_group_bonus_amount => h_bonus_amount,
                                      P_allocation_basis => h_allocation_basis,
                                      P_total_allocation_basis => h_total_allocation_basis,
                                      P_ytd_deprn => h_ytd_deprn,
                                      P_bonus_ytd_deprn => h_bonus_ytd_deprn,
                                      P_track_member_in => l_track_member_in,
                                      P_check_reserve_flag => x_check_reserve_flag,
                                      P_subtraction_flag => P_subtraction_flag,
                                      P_group_level_override => P_group_level_override,
                                      P_update_override_status => P_update_override_status,
                                      PX_difference_deprn_amount => h_difference_deprn_amount,
                                      PX_difference_bonus_amount => h_difference_bonus_amount,
                                      X_system_deprn_amount => h_system_deprn_amount,
                                      X_system_bonus_amount => h_system_bonus_amount,
                                      X_track_member_out => l_track_member_out,
                                      P_mrc_sob_type_code => 'P',
                                      P_set_of_books_id => P_set_of_books_id,
                                      P_mode => P_mode,
                                      P_rec_cost_for_odda => h_rec_cost_for_odda,
                                      P_sv_for_odda => h_sv_for_odda,
                                      p_log_level_rec => p_log_level_rec) then
                  raise allocate_err;
               end if; -- call allocation main
               x_calc_done := 'Y';

               --
               -- This is necessary because original adj cost update was performed when group
               -- adj cost was updated but at that time, member adj cost was not updated
               -- correctly because of lack of allocated unplanned amounts
               --
               if (l_group_dbr_name = 'ENERGY PERIOD END BALANCE') and                                          -- ENERGY
                  (mem.asset_id is not null) and                                                                -- ENERGY
                  (nvl(l_track_member_out.allocated_deprn_amount, 0) <> 0) and                                  -- ENERGY
                  (nvl(P_mode,'DEPRECIATION') = 'UNPLANNED') then                                               -- ENERGY
                                                                                                                -- ENERGY
                  update fa_books                                                                               -- ENERGY
                  set    adjusted_cost = adjusted_cost - nvl(l_track_member_out.allocated_deprn_amount, 0)      -- ENERGY
                  where transaction_header_id_out is null                                                       -- ENERGY
                  and   asset_id = mem.asset_id                                                                 -- ENERGY
                  and   book_type_code = h_book_type_code;                                                      -- ENERGY
                                                                                                                -- ENERGY
               end if;                                                                                          -- ENERGY

            end if; -- check flag
         end loop;

      else -- Reporting Book Case

         For mem in ALL_MEMBERS_MRC loop

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'regular-loop started: ', '(1)++Reporting Book');
               fa_debug_pkg.add(l_calling_fn,'+++ In Loop (1) +++','+++');
            end if;

            if (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
                mem.period_counter_fully_reserved is NULL and (mem.period_counter_fully_retired is NULL or  -- ENERGY
                                                               mem.period_counter_fully_retired = h_period_counter)) -- ENERGY
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and -- Bug6923135
                (mem.period_counter_fully_retired = h_period_counter))                                          -- Bug6923135
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
                mem.period_counter_fully_reserved is NULL)
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'N' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y' and
                (mem.period_counter_fully_retired is NULL or mem.period_counter_fully_retired = h_period_counter)) -- ENERGY
              or
               (nvl(P_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(P_allocate_to_fully_rsv_flag,'N') = 'Y') then

              l_reserve_amount := 0;                  -- ENERGY
              OPEN c_get_mc_adj(mem.asset_id);           -- ENERGY
              FETCH c_get_mc_adj INTO l_reserve_amount;  -- ENERGY
              CLOSE c_get_mc_adj;                        -- ENERGY
              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn,'l_reserve_amount', l_reserve_amount, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn,'mem.deprn_reserve', mem.deprn_reserve, p_log_level_rec => p_log_level_rec);
              end if;

               l_track_member_in.deprn_reserve := mem.deprn_reserve + l_reserve_amount; -- ENERGY
               l_track_member_in.reserve_adjustment_amount := l_reserve_amount;         -- ENERGY
               h_deprn_reserve := mem.deprn_reserve + l_reserve_amount;                -- ENERGY

               l_track_member_in.deprn_reserve := h_deprn_reserve;
               h_member_asset_id := mem.asset_id;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '+++ In Loop (2) ++ Member Asset to be processed ',
                                   h_member_asset_id);
               end if;

               -- Check fiscal year of populated deprn summary
               select fiscal_year into h_ds_fy
                 from fa_mc_deprn_periods
                where book_type_code = h_book_type_code
                  and period_counter = mem.period_counter
                  and set_of_books_id = p_set_of_books_id;

               if h_fiscal_year <> h_ds_fy then
                  mem.ytd_deprn := 0;
                  mem.bonus_ytd_deprn := 0;
               end if;

               if h_current_period_number = 1 then
                  h_ytd_deprn := 0;
                  h_bonus_ytd_deprn := 0;
               else
                  h_ytd_deprn := mem.ytd_deprn;
                  h_bonus_ytd_deprn := mem.bonus_ytd_deprn;
               end if;

               l_track_member_in.bonus_deprn_reserve := mem.bonus_deprn_reserve;
               l_track_member_in.member_asset_id := mem.asset_id;
               l_track_member_in.salvage_value   := mem.salvage_value;

               if h_excl_sv = 'Y' then
                  l_track_member_in.adjusted_cost := mem.adjusted_cost - mem.salvage_value;
               else
                  l_track_member_in.adjusted_cost := mem.adjusted_cost;
               end if;

               l_track_member_in.recoverable_cost := mem.recoverable_cost;
               h_recoverable_cost := l_track_member_in.recoverable_cost;
               l_track_member_in.adjusted_recoverable_cost := mem.adjusted_recoverable_cost;
               h_adjusted_recoverable_cost := l_track_member_in.adjusted_recoverable_cost;
               l_track_member_in.cost := mem.cost;

               -- Set Allocation Basis
               if P_group_deprn_basis = 'COST' then
                  h_allocation_basis := mem.recoverable_cost;
               else
                  h_allocation_basis := mem.adjusted_cost;
               end if;

               h_rec_cost_for_odda := mem.recoverable_cost;
               h_sv_for_odda := mem.salvage_value;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '+++ In Loop (3) ++ Before call allocation_main', '+++');
                  fa_debug_pkg.add(l_calling_fn, 'h_allocation_basis:total_allocation_basis:check_reserve_flag',
                                h_allocation_basis||':'||h_total_allocation_basis||':'||x_check_reserve_flag, p_log_level_rec => p_log_level_rec);
               end if;

               -- Call Allocation_main to allocate the group amount to member assets
               if not allocation_main(P_book_type_code => h_book_type_code,
                                   P_group_asset_id => h_group_asset_id,
                                   P_member_asset_id => mem.asset_id,
                                   P_period_counter => h_period_counter,
                                   P_fiscal_year => h_fiscal_year,
                                   P_group_bonus_rule => P_group_bonus_rule,
                                   P_group_deprn_amount => h_deprn_amount,
                                   P_group_bonus_amount => h_bonus_amount,
                                   P_allocation_basis => h_allocation_basis,
                                   P_total_allocation_basis => h_total_allocation_basis,
                                   P_ytd_deprn => h_ytd_deprn,
                                   P_bonus_ytd_deprn => h_bonus_ytd_deprn,
                                   P_track_member_in => l_track_member_in,
                                   P_check_reserve_flag => x_check_reserve_flag,
                                   P_subtraction_flag => P_subtraction_flag,
                                   P_group_level_override => P_group_level_override,
                                   P_update_override_status => P_update_override_status,
                                   PX_difference_deprn_amount => h_difference_deprn_amount,
                                   PX_difference_bonus_amount => h_difference_bonus_amount,
                                   X_system_deprn_amount => h_system_deprn_amount,
                                   X_system_bonus_amount => h_system_bonus_amount,
                                   X_track_member_out => l_track_member_out,
                                   P_mrc_sob_type_code => 'R',
                                   P_set_of_books_id => p_set_of_books_id,
                                   P_mode => P_mode,
                                   P_rec_cost_for_odda => h_rec_cost_for_odda,
                                   P_sv_for_odda => h_sv_for_odda,
                                   p_log_level_rec => p_log_level_rec) then
                  raise allocate_err;
               end if; -- call allocation main

               x_calc_done := 'Y';

               --
               -- This is necessary because original adj cost update was performed when group
               -- adj cost was updated but at that time, member adj cost was not updated
               -- correctly because of lack of allocated unplanned amounts
               --
               if (l_group_dbr_name = 'ENERGY PERIOD END BALANCE') and                                          -- ENERGY
                  (mem.asset_id is not null) and                                                                -- ENERGY
                  (nvl(l_track_member_out.allocated_deprn_amount, 0) <> 0) and                                  -- ENERGY
                  (nvl(P_mode,'DEPRECIATION') = 'UNPLANNED') then                                               -- ENERGY

                  update fa_mc_books                                                                         -- ENERGY
                  set    adjusted_cost = adjusted_cost - nvl(l_track_member_out.allocated_deprn_amount, 0)      -- ENERGY
                  where transaction_header_id_out is null                                                       -- ENERGY
                  and   asset_id = mem.asset_id                                                                 -- ENERGY
                  and   book_type_code = h_book_type_code                                                      -- ENERGY
                  and   set_of_books_id = p_set_of_books_id;

               end if;                                                                                          -- ENERGY

            end if; -- check flag
         end loop;
      end if; -- Check Primary book or Reporting Book?
   end if; -- Case for RUN_MODE

   -- Following is a logic for last asset (whose asset numbre is biggest.)

   if nvl(x_calc_done,'N') = 'Y' and nvl(l_track_member_out.override_flag,'N') <> 'Y' then

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '+++ Final Asset Rounding Logic', 'for ADJUSTMENT', p_log_level_rec => p_log_level_rec);
         end if;

         x_sum_of_deprn_amount := 0;
         x_sum_of_bonus_amount := 0;

         For j IN 1 .. p_track_member_table.COUNT LOOP
            if p_track_member_table(j).group_asset_id = h_group_asset_id and
               p_track_member_table(j).period_counter = h_period_counter and
               nvl(p_track_member_table(j).set_of_books_id, -99) = nvl(p_set_of_books_id,-99) and
               p_track_member_table(j).member_asset_id <> l_track_member_in.member_asset_id then

               x_sum_of_deprn_amount := x_sum_of_deprn_amount + nvl(p_track_member_table(j).system_deprn_amount,0);
               x_sum_of_bonus_amount := x_sum_of_bonus_amount + nvl(p_track_member_table(j).system_bonus_amount,0);

            end if;
         END LOOP;
      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '+++ Final Asset Rounding Logic', 'for DEPRECIATION', p_log_level_rec => p_log_level_rec);
         end if;

         select nvl(sum(system_deprn_amount),0),
                nvl(sum(system_bonus_amount),0)
           into x_sum_of_deprn_amount,x_sum_of_bonus_amount
           from fa_track_members
           where group_asset_id = P_group_asset_id
            and member_asset_id <> l_track_member_in.member_asset_id
            and period_counter = P_period_counter
            and fiscal_year    = P_fiscal_year
            and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

         --Bug6916669
         --to check if the last member is already fully reserved
          begin
                  select fully_reserved_flag
                   into x_fully_reserved_flag
                   from fa_track_members
                   where group_asset_id = P_group_asset_id
                    and member_asset_id = l_track_member_in.member_asset_id
                    and period_counter = P_period_counter
                    and fiscal_year    = P_fiscal_year
                    and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
          exception
                When Others then
                 x_fully_reserved_flag := 'N';
          end;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'x_sum_of_deprn:bonus_amount',
                          x_sum_of_deprn_amount||':'||x_sum_of_bonus_amount, p_log_level_rec => p_log_level_rec);
      end if;

      -- Final Asset Rounding Adjustment
      x_allocated_deprn_amount := P_group_deprn_amount - x_sum_of_deprn_amount; -- h_system_deprn_amount);
      x_allocated_bonus_amount := nvl(P_group_bonus_amount,0) - nvl(x_sum_of_bonus_amount,0);
                                                                                -- nvl(h_system_bonus_amount,0));

      h_system_deprn_amount := x_allocated_deprn_amount;
      h_system_bonus_amount := x_allocated_bonus_amount;

      -- In case subtraction flag is set, subtract previous ytd from current ytd
      if nvl(P_subtraction_flag,'N') = 'Y' then
         x_allocated_deprn_amount := x_allocated_deprn_amount - h_ytd_deprn;
         x_allocated_bonus_amount := x_allocated_bonus_amount - h_bonus_ytd_deprn;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn:bonus_amount(1)', x_allocated_deprn_amount||':'||
                          x_allocated_bonus_amount);
         fa_debug_pkg.add(l_calling_fn, 'x_check_reserve_flag', x_check_reserve_flag, p_log_level_rec => p_log_level_rec);
      end if;

      if nvl(x_check_reserve_flag,'N') = 'Y' then -- Check is necessary only when allocate_fully_reserve flag is 'N'.
         -- Check if this member asset is not fully reserved due to this allocated amount.
         x_check_amount := l_track_member_in.adjusted_recoverable_cost;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'member_in.deprn_reserve', l_track_member_in.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn:bonus_amount(2)', x_allocated_deprn_amount||':'||
                             x_allocated_bonus_amount);
            fa_debug_pkg.add(l_calling_fn, 'x_check_amount', x_check_amount, p_log_level_rec => p_log_level_rec);
         end if;



        -- Bug6987667:Old way did not handle when cost is -ve and rsv is +ve.
        -- So modified to multiply -1 if cost is -ve.
        --Bug6809835 Modified fix done for bug 6520356
        --abs should only be taken if total reserve and cost are both -ive
        -- Bug 6879353 : Use local variables instead of modifying the actual values
        if (x_check_amount < 0) then
            l_total_reserve := -1*(l_track_member_in.deprn_reserve + x_allocated_deprn_amount);
            l_check_amount := -1*(x_check_amount);
        else
            l_total_reserve := l_track_member_in.deprn_reserve + x_allocated_deprn_amount;
            l_check_amount := x_check_amount;
        end if;

        --Bug6916669
         --to check if the last member is already fully reserved
        -- Bug 6879353 : Use local variables for the check
        if ( l_total_reserve >= l_check_amount ) or ( nvl(x_fully_reserved_flag,'N') = 'Y' ) then
            x_fully_reserved_flag := 'Y';

            --Bug7008015: reset allocate_deprn_amount only if it was not fully reserved even before allocation
            -- This is to avoid backing out and reallocate rsv due to downward cost adjustments
            -- if reserve (before allocation) is greater than the adjusted_recoverable_cost, then allocate 0 amount
            -- and add original allocated amount as difference and reallocate it to other member assets
            if ((x_check_amount < 0) and
                (l_check_amount > -1*(l_track_member_in.deprn_reserve))) or
               ((x_check_amount > 0) and
                (l_check_amount > (l_track_member_in.deprn_reserve))) then
               h_difference_deprn_amount := h_difference_deprn_amount + (x_allocated_deprn_amount - x_check_amount);
               x_allocated_deprn_amount := x_check_amount - l_track_member_in.deprn_reserve;
            else
               h_difference_deprn_amount := h_difference_deprn_amount + x_allocated_deprn_amount;
               x_allocated_deprn_amount := 0;
            end if;

            if P_group_bonus_rule is not null then

               x_allocated_normal_amount := x_allocated_deprn_amount - l_track_member_out.allocated_bonus_amount;

               if (x_allocated_deprn_amount - x_allocated_normal_amount < x_check_amount) and
                  (x_allocated_deprn_amount - x_allocated_normal_amount > 0) then

                  h_difference_bonus_amount := h_difference_bonus_amount + (x_allocated_bonus_amount -
                                               (x_allocated_deprn_amount - x_allocated_normal_amount));
                  x_allocated_bonus_amount := x_allocated_deprn_amount - x_allocated_normal_amount;
               else
                  h_difference_bonus_amount := h_difference_bonus_amount + x_allocated_bonus_amount;
                  x_allocated_bonus_amount := 0;
               end if;
            end if;
         end if; -- Check if this asset becomes fully reserved
      end if;

      -- Get Period number
      if p_mrc_sob_type_code <> 'R' then

         open GET_PERIOD_NUM(P_period_counter);
         fetch GET_PERIOD_NUM into h_period_num;

         if GET_PERIOD_NUM%NOTFOUND then
            h_period_num := P_period_counter - (P_fiscal_year * h_perds_per_yr);
         end if;

         close GET_PERIOD_NUM;
      else

         open GET_PERIOD_NUM_MRC(P_period_counter);
         fetch GET_PERIOD_NUM_MRC into h_period_num;

         if GET_PERIOD_NUM_MRC%NOTFOUND then
            h_period_num := P_period_counter - (P_fiscal_year * h_perds_per_yr);
         end if;

         close GET_PERIOD_NUM_MRC;
      end if;

      -- Reduce subtraction case
      if nvl(P_mode,'DEPRECIATION') = 'DEPRECIATION' and nvl(P_subtraction_flag,'N') = 'Y' then

         -- Subtract group level catchup expense since it will be added later.
         h_deprn_expense := 0;
         h_bonus_expense := 0;

         if p_mrc_sob_type_code <> 'R' then
            open FA_ADJ_EXPENSE(l_track_member_in.member_asset_id);
            fetch FA_ADJ_EXPENSE into h_deprn_expense, h_bonus_expense;
            close FA_ADJ_EXPENSE;
         else
            open FA_ADJ_EXPENSE_MRC(l_track_member_in.member_asset_id);
            fetch FA_ADJ_EXPENSE_MRC into h_deprn_expense, h_bonus_expense;
            close FA_ADJ_EXPENSE_MRC;
         end if;

         x_allocated_deprn_amount := x_allocated_deprn_amount - nvl(h_deprn_expense,0);
         x_allocated_bonus_amount := x_allocated_bonus_amount - nvl(h_bonus_expense,0);
 --        X_system_deprn_amount := x_system_deprn_amount - nvl(h_deprn_expense,0);
 --        X_system_bonus_amount := x_system_bonus_amount - nvl(h_bonus_expense,0);
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '** after Subtraction Case **', '***');
            fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn:bonus_amount',
                             x_allocated_deprn_amount||':'||x_allocated_deprn_amount, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_deprn:bonus_expense', h_deprn_expense||':'||h_bonus_expense, p_log_level_rec => p_log_level_rec);
         end if;
      end if;

      -- Calculate Deprn Reserve
--      h_deprn_reserve := nvl(h_deprn_reserve,0) + nvl(x_allocated_deprn_amount,0); -- ENERGY
      h_deprn_reserve := nvl(h_deprn_reserve,0) + nvl(x_allocated_deprn_amount,0) - nvl(l_reserve_amount, 0); -- ENERGY
      h_bonus_deprn_reserve := nvl(h_bonus_deprn_reserve,0) + nvl(x_allocated_bonus_amount,0);

      if h_period_num <> 1 then
         h_ytd_deprn := nvl(h_ytd_deprn,0) + nvl(x_allocated_deprn_amount,0);
         h_bonus_ytd_deprn := nvl(h_bonus_ytd_deprn,0) + nvl(x_allocated_bonus_amount,0);
      else
         h_ytd_deprn := nvl(x_allocated_deprn_amount,0);
         h_bonus_ytd_deprn := nvl(x_allocated_bonus_amount,0);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'+++ Just before update table or PL/SQL table +++', P_mode, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'x_allocated_deprn:bonus_amount',
                          x_allocated_deprn_amount||':'||x_allocated_bonus_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'h_ytd_deprn:h_deprn_reserve:h_bonus_ytd_deprn:h_bonus_deprn_reserve',
                                          h_ytd_deprn||':'||h_deprn_reserve||':'||h_bonus_deprn_reserve||
                                        ':'||h_bonus_ytd_deprn, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'x_fully_reserved_flag', x_fully_reserved_flag, p_log_level_rec => p_log_level_rec);

         if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
            fa_debug_pkg.add(l_calling_fn, 'l_last_asset_index(ADJUSTMENT mode)', l_last_asset_index);
         end if;
      end if;

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

         p_track_member_table(l_last_asset_index).allocated_deprn_amount := x_allocated_deprn_amount;
         p_track_member_table(l_last_asset_index).allocated_bonus_amount := x_allocated_bonus_amount;
         p_track_member_table(l_last_asset_index).fully_reserved_flag := x_fully_reserved_flag;
         p_track_member_table(l_last_asset_index).system_deprn_amount := h_system_deprn_amount;
         p_track_member_table(l_last_asset_index).system_bonus_amount := h_system_bonus_amount;
         p_track_member_table(l_last_asset_index).deprn_reserve := h_deprn_reserve;
         p_track_member_table(l_last_asset_index).ytd_deprn := h_ytd_deprn;
         p_track_member_table(l_last_asset_index).bonus_deprn_reserve := h_bonus_deprn_reserve;
         p_track_member_table(l_last_asset_index).bonus_ytd_deprn := h_bonus_ytd_deprn;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'In final asset rounding, Updated following row into p_track_member_table',
                             l_last_asset_index, p_log_level_rec => p_log_level_rec);

            if not display_debug_message2(l_last_asset_index, l_calling_fn,
p_log_level_rec) then
               fa_debug_pkg.add(l_calling_fn, 'display_debug_message2', 'error returned', p_log_level_rec => p_log_level_rec);
            end if;
         end if;
      else
-- ENERGY
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'before update ', '1', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn_amount', x_allocated_deprn_amount, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_ytd_deprn', h_ytd_deprn, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_deprn_reserve', h_deprn_reserve, p_log_level_rec => p_log_level_rec);
        end if;
-- ENERGY

         -- Update FA_TRACK_MEMBERS table
        update FA_TRACK_MEMBERS
           set allocated_deprn_amount = x_allocated_deprn_amount,
               allocated_bonus_amount = x_allocated_bonus_amount,
               fully_reserved_flag = x_fully_reserved_flag,
               system_deprn_amount = h_system_deprn_amount,
               system_bonus_amount = h_system_bonus_amount,
               deprn_reserve = h_deprn_reserve,
               ytd_deprn = h_ytd_deprn,
               bonus_deprn_reserve = h_bonus_deprn_reserve,
               bonus_ytd_deprn = h_bonus_ytd_deprn
         where group_asset_id = P_group_asset_id
           and member_asset_id = h_member_asset_id
           and period_counter = P_period_counter
           and fiscal_year = P_fiscal_year
           and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
      end if;
   end if; -- Final Asset treatment

   --* Calculate the Difference from original group amount

   if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
      x_total_allocated_deprn_amount := 0;
      x_total_allocated_bonus_amount := 0;

      For j IN 1 .. p_track_member_table.COUNT LOOP

         if p_track_member_table(j).group_asset_id = h_group_asset_id and
            p_track_member_table(j).period_counter = h_period_counter and
            nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id,-99) then

            if nvl(P_subtraction_flag,'N') = 'N' and nvl(p_track_member_table(j).override_flag,'N') <> 'Y' then
               x_total_allocated_deprn_amount := x_total_allocated_deprn_amount +
                                                 nvl(p_track_member_table(j).allocated_deprn_amount, 0); --bug6912446: Added nvl
               x_total_allocated_bonus_amount := x_total_allocated_bonus_amount +
                                                 nvl(p_track_member_table(j).allocated_bonus_amount, 0); --bug6912446: Added nvl
            else
               x_total_allocated_deprn_amount := x_total_allocated_deprn_amount +
                                                 nvl(p_track_member_table(j).system_deprn_amount, 0); --bug6912446: Added nvl
               x_total_allocated_bonus_amount := x_total_allocated_bonus_amount +
                                                 nvl(p_track_member_table(j).system_bonus_amount, 0); --bug6912446: Added nvl
            end if;
         end if;
      END LOOP;
   else
     select sum(decode(nvl(P_subtraction_flag,'N'),'N',
                decode(nvl(override_flag,'N'),'Y',system_deprn_amount,allocated_deprn_amount), -- Periodic Case
                system_deprn_amount)), -- Subtraction Case
            sum(decode(nvl(P_subtraction_flag,'N'),'N',
                decode(nvl(override_flag,'N'),'Y',system_bonus_amount,allocated_bonus_amount), -- Periodic Case
                system_bonus_amount)) -- Subtraction Case
       into x_total_allocated_deprn_amount,x_total_allocated_bonus_amount
       from fa_track_members
      where group_asset_id = P_group_asset_id
        and period_counter = P_period_counter
        and fiscal_year = P_fiscal_year
        and nvl(set_of_books_id,-99) = p_set_of_books_id;
   end if;

   h_difference_deprn_amount := P_group_deprn_amount - nvl(x_total_allocated_deprn_amount,0);
   h_difference_bonus_amount := nvl(P_group_bonus_amount,0) - nvl(x_total_allocated_bonus_amount,0);

   if nvl(P_allocate_to_fully_rsv_flag,'N') = 'N' and
      (P_excess_allocation_option = 'DISTRIBUTE' or nvl(P_group_level_override,'N') <> 'N') then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '+++ Reallocation Logic Start +++', '+++', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'h_difference_deprn:bonus_amount',
                          h_difference_deprn_amount||':'||h_difference_bonus_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'P_allocate_to_fully_rsv_flag:P_excess_allocation_option',
                                         P_allocate_to_fully_rsv_flag||':'||P_excess_allocation_option, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'P_group_level_override', P_group_level_override, p_log_level_rec => p_log_level_rec);
      end if;

      -- Logic to reallocate amounts
      h_group_deprn_amount := h_deprn_amount;
      h_group_bonus_amount := h_bonus_amount;

      h_all_member_fully_reserved := 'N';
      --Bug6907818
      x_fully_reserved_flag := 'N';

      Loop -- This loop continues until all amounts are distributed or all members become fully reserved.

         exit when (nvl(h_difference_deprn_amount,0) = 0 and nvl(h_difference_bonus_amount,0) = 0);
         exit when (nvl(h_all_member_fully_reserved,'N') = 'Y');

         if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
            h_fixed_deprn_amount := 0;
            h_fixed_bonus_amount := 0;

            For j IN 1 .. p_track_member_table.COUNT LOOP

               if p_track_member_table(j).group_asset_id = h_group_asset_id and
                  p_track_member_table(j).period_counter = h_period_counter and
                  nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id,-99) then

                  if nvl(p_track_member_table(j).fully_reserved_flag,'N') = 'Y' or
                     nvl(p_track_member_table(j).override_flag,'N') = 'Y' then

                     if nvl(P_subtraction_flag,'N') = 'N' and
                        nvl(p_track_member_table(j).fully_reserved_flag,'N') = 'Y' then

                        h_fixed_deprn_amount := h_fixed_deprn_amount + p_track_member_table(j).allocated_deprn_amount;
                        h_fixed_bonus_amount := h_fixed_bonus_amount + p_track_member_table(j).allocated_bonus_amount;
                     else
                        h_fixed_deprn_amount := h_fixed_deprn_amount + p_track_member_table(j).system_deprn_amount;
                        h_fixed_bonus_amount := h_fixed_bonus_amount + p_track_member_table(j).system_bonus_amount;
                     end if;
                  end if;
               end if;
            END LOOP;
         else
            -- Total Amount to be distributed
            select nvl(sum(decode(nvl(P_subtraction_flag,'N'),'N',
                       decode(nvl(fully_reserved_flag,'N'),'Y',
                                                allocated_deprn_amount,
                                                system_deprn_amount), -- Normal Case
                       system_deprn_amount)), -- Subtraction Case
                       0),
                   nvl(sum(decode(nvl(P_subtraction_flag,'N'),'N',
                      decode(nvl(fully_reserved_flag,'N'),'Y',
                                                allocated_bonus_amount,
                                                system_bonus_amount), -- Normal Case
                       system_deprn_amount)), -- Subtraction Case
                       0)
              into h_fixed_deprn_amount,h_fixed_bonus_amount
              from fa_track_members
             where group_asset_id = P_group_asset_id
               and period_counter = P_period_counter
               and fiscal_year = P_fiscal_year
               and (nvl(fully_reserved_flag,'N') = 'Y' or nvl(override_flag,'N') = 'Y');

            --* Query up the non-reallocate member assets in case of subtraction
            if nvl(P_mode,'DEPRECIATION') = 'DEPRECIATION' and
               nvl(P_subtraction_flag,'N') = 'Y' then

               -- Subtract group level catchup expense since it will be added later.
               h_total_deprn_expense := 0;
               h_total_bonus_expense := 0;

               FOR fix_member IN FIX_AMOUNT_MEMBER LOOP

                  h_fix_amount_member := fix_member.member_asset_id;
                  h_deprn_expense := 0;
                  h_bonus_expense := 0;

                  if p_mrc_sob_type_code <> 'R' then
                     open FA_ADJ_EXPENSE(l_track_member_in.member_asset_id);
                     fetch FA_ADJ_EXPENSE into h_deprn_expense, h_bonus_expense;
                     close FA_ADJ_EXPENSE;
                  else
                     open FA_ADJ_EXPENSE_MRC(l_track_member_in.member_asset_id);
                     fetch FA_ADJ_EXPENSE_MRC into h_deprn_expense, h_bonus_expense;
                     close FA_ADJ_EXPENSE_MRC;
                  end if;

--                   h_total_deprn_expense := h_total_deprn_expense + nvl(h_deprn_expense,0);
--                   h_total_bonus_expense := h_total_bonus_expense + nvl(h_bonus_expense,0);
               end loop;

               h_fixed_deprn_amount := nvl(h_fixed_deprn_amount,0) + nvl(h_total_deprn_expense,0);
               h_fixed_deprn_amount := nvl(h_fixed_deprn_amount,0) + nvl(h_total_deprn_expense,0);
            end if;

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'h_fixed_deprn:bonus_amount',
                             h_fixed_deprn_amount||':'||h_fixed_bonus_amount, p_log_level_rec => p_log_level_rec);
         end if;

         h_group_deprn_amount := h_deprn_amount - h_fixed_deprn_amount;
         h_group_bonus_amount := h_bonus_amount - h_fixed_bonus_amount;

         if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
            h_total_allocation_basis := 0;

            For j IN 1 .. p_track_member_table.COUNT LOOP

               if p_track_member_table(j).group_asset_id = h_group_asset_id and
                  p_track_member_table(j).period_counter = h_period_counter + 1 and
                  nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id,-99) then

                  if nvl(p_track_member_table(j).fully_reserved_flag,'N') <> 'Y' and
                     nvl(p_track_member_table(j).override_flag,'N')<> 'Y' and
                     p_track_member_table(j).group_asset_id = P_group_asset_id and
                     p_track_member_table(j).period_counter = P_period_counter + 1 then

                     h_total_allocation_basis := h_total_allocation_basis + p_track_member_table(j).allocation_basis;
                  end if;
               end if;
            END LOOP;
         else
            Select nvl(sum(allocation_basis),0) into h_total_allocation_basis
              from fa_track_members
             where group_asset_id = P_group_asset_id
               and period_counter = P_period_counter
               and fiscal_year = P_fiscal_year
               and nvl(fully_reserved_flag,'N') <> 'Y'
               and nvl(override_flag,'N') <> 'Y';
         end if;

         -- Reset the difference variables
         h_difference_deprn_amount := 0;
         h_difference_bonus_amount := 0;
         h_all_member_fully_reserved := 'Y';

         if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

            For j in 1 .. p_track_member_table.COUNT loop

               if p_track_member_table(j).group_asset_id = h_group_asset_id and
                  p_track_member_table(j).period_counter = h_period_counter and
                  nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id,-99) then

                  if nvl(p_track_member_table(j).fully_reserved_flag,'N') <> 'Y' and
                     nvl(p_track_member_table(j).override_flag,'N')<> 'Y' and
                     p_track_member_table(j).group_asset_id = P_group_asset_id and
                     p_track_member_table(j).period_counter = P_period_counter + 1 then

                     l_track_member_in := p_track_member_table(j);
                     h_member_asset_id := l_track_member_in.member_asset_id;

                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Reallocate to member asset (Adjustment Mode)',
                                                       l_track_member_in.member_asset_id);
                     end if;

                     if h_current_period_number = 1 then
                        h_ytd_deprn := 0;
                        h_bonus_ytd_deprn     := 0;
                     else
                        h_ytd_deprn           := p_track_member_table(j).ytd_deprn;
                        h_bonus_ytd_deprn     := p_track_member_table(j).bonus_ytd_deprn;
                     end if;

                     -- Set Allocation Basis
                     h_allocation_basis := p_track_member_table(j).allocation_basis;
                     h_all_member_fully_reserved := 'N';

                     h_rec_cost_for_odda := p_track_member_table(j).recoverable_cost;
                     h_sv_for_odda := p_tracK_member_table(j).salvage_value;

                     -- Call Allocation_main to allocate the group amount to member assets
                     x_calc_done := 'N';

                     if not allocation_main(P_book_type_code => h_book_type_code,
                                           P_group_asset_id => h_group_asset_id,
                                           P_member_asset_id => l_track_member_in.member_asset_id,
                                           P_period_counter => h_period_counter,
                                           P_fiscal_year => h_fiscal_year,
                                           P_group_bonus_rule => P_group_bonus_rule,
                                           P_group_deprn_amount => h_group_deprn_amount,
                                           P_group_bonus_amount => h_group_bonus_amount,
                                           P_allocation_basis => h_allocation_basis,
                                           P_total_allocation_basis => h_total_allocation_basis,
                                           P_ytd_deprn => h_ytd_deprn,
                                           P_bonus_ytd_deprn => h_bonus_ytd_deprn,
                                           P_track_member_in => l_track_member_in,
                                           P_check_reserve_flag => x_check_reserve_flag,
                                           P_subtraction_flag => P_subtraction_flag,
                                           P_group_level_override => P_group_level_override,
                                           P_update_override_status => P_update_override_status,
                                           P_member_override_flag => h_member_override_flag,
                                           PX_difference_deprn_amount => h_difference_deprn_amount,
                                           PX_difference_bonus_amount => h_difference_bonus_amount,
                                           X_system_deprn_amount => h_system_deprn_amount,
                                           X_system_bonus_amount => h_system_bonus_amount,
                                           X_track_member_out => l_track_member_out,
                                           P_mrc_sob_type_code => 'P',
                                           P_set_of_books_id => p_set_of_books_id,
                                           P_mode => P_mode,
                                           P_rec_cost_for_odda => h_rec_cost_for_odda,
                                           P_sv_for_odda => h_sv_for_odda,
                                           p_log_level_rec => p_log_level_rec) then
                        raise allocate_err;
                     end if;

                     x_calc_done := 'Y';

                     -- Update the PX_TRACK_MEMBER(J) for the next period
                     p_track_member_table(j).allocated_deprn_amount := l_track_member_out.allocated_deprn_amount;
                     p_track_member_table(j).allocated_bonus_amount := l_track_member_out.allocated_bonus_amount;
                     p_track_member_table(j).fully_reserved_flag := l_track_member_out.fully_reserved_flag;
                     p_track_member_table(j).system_deprn_amount := l_track_member_out.system_deprn_amount;
                     p_track_member_table(j).system_bonus_amount := l_track_member_out.system_bonus_amount;
                     p_track_member_table(j).deprn_reserve := l_track_member_out.deprn_reserve;
                     p_track_member_table(j).ytd_deprn := l_track_member_out.ytd_deprn;
                     p_track_member_table(j).bonus_deprn_reserve := l_track_member_out.bonus_deprn_reserve;
                     p_track_member_table(j).bonus_ytd_deprn := l_track_member_out.bonus_ytd_deprn;

                     l_processed_number := j;

                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn,
                                         'In reallocation logic, Updated following row into p_track_member_table',
                                         l_processed_number, p_log_level_rec => p_log_level_rec);

                        if not display_debug_message2(l_processed_number, l_calling_fn, p_log_level_rec) then
                           fa_debug_pkg.add(l_calling_fn, 'display_debug_message2', 'error returned', p_log_level_rec => p_log_level_rec);
                        end if;
                     end if;

                  end if;
               end if;
            end loop; -- Loop for P_TRACK_MEMBER_TABLE

         else -- regular mode


            if P_mrc_sob_type_code <> 'R' then

               For realloc in REALLOCATE_MEMBER loop

                  l_track_member_in.group_asset_id := P_group_Asset_id;
                  l_track_member_in.member_asset_id := realloc.member_asset_id;
                  h_member_asset_id := realloc.member_asset_id;
                  l_track_member_in.override_flag := nvl(realloc.override_flag,'N');

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Reallocate to member asset(Prmary Book)',
                                      l_track_member_in.member_asset_id);
                  end if;

                  if h_current_period_number = 1 then
                     h_ytd_deprn     := 0;
                     h_bonus_ytd_deprn     := 0;
                  else
                     h_ytd_deprn     := realloc.ytd_deprn;
                     h_bonus_ytd_deprn     := realloc.bonus_ytd_deprn;
                  end if;

                  --Bug6989520: Adding same logic as main loop above.
                  --This also resets l_track_member_in.reserve_adjustment_amount.
                  l_reserve_amount := 0;
                  OPEN c_get_adj(realloc.member_asset_id);
                  FETCH c_get_adj INTO l_reserve_amount;
                  CLOSE c_get_adj;
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'l_reserve_amount', l_reserve_amount, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn,'realloc.deprn_reserve', realloc.deprn_reserve, p_log_level_rec => p_log_level_rec);
                  end if;

                  l_track_member_in.deprn_reserve := realloc.deprn_reserve + l_reserve_amount;
                  l_track_member_in.reserve_adjustment_amount := l_reserve_amount;

                  l_track_member_in.bonus_deprn_reserve := realloc.bonus_deprn_reserve;
                  l_track_member_in.cost := realloc.cost;

                  -- Set Allocation Basis
                  h_allocation_basis := realloc.allocation_basis;
                  h_all_member_fully_reserved := 'N';
                  h_rec_Cost_for_odda := realloc.recoverable_cost;
                  h_sv_for_odda := realloc.salvage_value;

                  --bug6795984
                  l_track_member_in.recoverable_cost := realloc.recoverable_cost;
                  l_track_member_in.adjusted_recoverable_cost := realloc.adjusted_recoverable_cost;

                  -- Call Allocation_main to allocate the group amount to member assets
                  x_calc_done := 'N';
                  if not allocation_main(P_book_type_code => h_book_type_code,
                                         P_group_asset_id => h_group_asset_id,
                                         P_member_asset_id => realloc.member_asset_id,
                                         P_period_counter => h_period_counter,
                                         P_fiscal_year => h_fiscal_year,
                                         P_group_bonus_rule => P_group_bonus_rule,
                                         P_group_deprn_amount => h_group_deprn_amount,
                                         P_group_bonus_amount => h_group_bonus_amount,
                                         P_allocation_basis => h_allocation_basis,
                                         P_total_allocation_basis => h_total_allocation_basis,
                                         P_ytd_deprn => h_ytd_deprn,
                                         P_bonus_ytd_deprn => h_bonus_ytd_deprn,
                                         P_track_member_in => l_track_member_in,
                                         P_check_reserve_flag => x_check_reserve_flag,
                                         P_subtraction_flag => P_subtraction_flag,
                                         P_group_level_override => P_group_level_override,
                                         P_update_override_status => P_update_override_status,
                                         P_member_override_flag => h_member_override_flag,
                                         PX_difference_deprn_amount => h_difference_deprn_amount,
                                         PX_difference_bonus_amount => h_difference_bonus_amount,
                                         X_system_deprn_amount => h_system_deprn_amount,
                                         X_system_bonus_amount => h_system_bonus_amount,
                                         X_track_member_out => l_track_member_out,
                                         P_mrc_sob_type_code => 'P',
                                         P_set_of_books_id => p_set_of_books_id,
                                         P_mode => P_mode,
                                         P_rec_cost_for_odda => h_rec_cost_for_odda,
                                         P_sv_for_odda => h_sv_for_odda,
                                         p_log_level_rec => p_log_level_rec) then
                     raise allocate_err;
                  end if;

                  x_calc_done := 'Y';

               end loop;

            else -- For Reporting Book

               For realloc in REALLOCATE_MEMBER_MRC loop

                  l_track_member_in.group_Asset_id := P_group_asset_id;
                  l_track_member_in.member_asset_id := realloc.member_asset_id;
                  h_member_asset_id := realloc.member_asset_id;
                  l_track_member_in.override_flag := nvl(realloc.override_flag,'N');

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Reallocate to member asset (Reporting Book)',
                                      l_track_member_in.member_asset_id);
                  end if;

                  if h_current_period_number = 1 then
                     h_ytd_deprn       := 0;
                     h_bonus_ytd_deprn := 0;
                  else
                     h_ytd_deprn       := realloc.ytd_deprn;
                     h_bonus_ytd_deprn := realloc.bonus_ytd_deprn;
                  end if;

                  --Bug6989520: Adding same logic as main loop above.
                  --This also resets l_track_member_in.reserve_adjustment_amount.
                  l_reserve_amount := 0;
                  OPEN c_get_mc_adj(realloc.member_asset_id);
                  FETCH c_get_mc_adj INTO l_reserve_amount;
                  CLOSE c_get_mc_adj;
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'l_reserve_amount', l_reserve_amount, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn,'realloc.deprn_reserve', realloc.deprn_reserve, p_log_level_rec => p_log_level_rec);
                  end if;

                  l_track_member_in.deprn_reserve := realloc.deprn_reserve + l_reserve_amount;
                  l_track_member_in.reserve_adjustment_amount := l_reserve_amount;

                  l_track_member_in.bonus_deprn_reserve := realloc.bonus_deprn_reserve;
                  l_track_member_in.cost := realloc.cost;

                  -- Set Allocation Basis
                  h_allocation_basis := realloc.allocation_basis;
                  h_all_member_fully_reserved := 'N';
                  h_rec_cost_for_odda := realloc.recoverable_cost;
                  h_sv_for_odda := realloc.salvage_value;

                  -- Call Allocation_main to allocate the group amount to member assets
                  x_calc_done := 'N';

                  if not allocation_main(P_book_type_code => h_book_type_code,
                                         P_group_asset_id => h_group_asset_id,
                                         P_member_asset_id => realloc.member_asset_id,
                                         P_period_counter => h_period_counter,
                                         P_fiscal_year => h_fiscal_year,
                                         P_group_bonus_rule => P_group_bonus_rule,
                                         P_group_deprn_amount => h_group_deprn_amount,
                                         P_group_bonus_amount => h_group_bonus_amount,
                                         P_allocation_basis => h_allocation_basis,
                                         P_total_allocation_basis => h_total_allocation_basis,
                                         P_ytd_deprn => h_ytd_deprn,
                                         P_bonus_ytd_deprn => h_bonus_ytd_deprn,
                                         P_track_member_in => l_track_member_in,
                                         P_check_reserve_flag => x_check_reserve_flag,
                                         P_subtraction_flag => P_subtraction_flag,
                                         P_group_level_override => P_group_level_override,
                                         P_update_override_status => P_update_override_status,
                                         P_member_override_flag => h_member_override_flag,
                                         PX_difference_deprn_amount => h_difference_deprn_amount,
                                         PX_difference_bonus_amount => h_difference_bonus_amount,
                                         X_system_deprn_amount => h_system_deprn_amount,
                                         X_system_bonus_amount => h_system_bonus_amount,
                                         X_track_member_out => l_track_member_out,
                                         P_mrc_sob_type_code => 'R',
                                         P_set_of_books_id => p_set_of_books_id,
                                         P_mode => P_mode,
                                         P_rec_cost_for_odda => h_rec_cost_for_odda,
                                         P_sv_for_odda => h_sv_for_odda,
                                         p_log_level_rec => p_log_level_rec) then
                     raise allocate_err;
                  end if;

                  x_calc_done := 'Y';

               end loop;

            end if; -- Reporting Book or Primary Book?

         end if; -- Adjutment Mode or Regular Mode

         if nvl(x_calc_done,'N') = 'Y' and
            nvl(l_track_member_out.override_flag,'N') <> 'Y' and nvl(h_all_member_fully_reserved,'N') = 'N' then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '+++ Final Asset Rounding (Reallocation) Start ++', '+++');
               fa_debug_pkg.add(l_calling_fn, 'h_system_deprn:bonus_amount',
                                h_system_deprn_amount||':'||h_system_bonus_amount, p_log_level_rec => p_log_level_rec);
            end if;

            if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
               x_sum_of_deprn_amount := 0;
               x_sum_of_bonus_amount := 0;

               For j IN 1 .. p_track_member_table.COUNT LOOP

                  if p_track_member_table(j).group_asset_id = h_group_asset_id and
                     p_track_member_table(j).period_counter = h_period_counter and
                     nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id,-99) then

                     if nvl(p_track_member_table(j).fully_reserved_flag,'N') <> 'Y' and
                        nvl(p_track_member_table(j).override_flag,'N') <> 'Y' and
                        p_track_member_table(j).group_Asset_id = P_group_Asset_id and
                        p_track_member_table(j).member_asset_id <> l_track_member_in.member_asset_id and
                        p_track_member_table(j).period_counter = P_period_counter then

                        x_sum_of_deprn_amount := x_sum_of_deprn_amount + p_track_member_table(j).system_deprn_amount;
                        x_sum_of_bonus_amount := x_sum_of_bonus_amount + p_track_member_table(j).system_bonus_amount;

                     end if;

                  end if;

               END LOOP;
            else
               select nvl(sum(system_deprn_amount),0),nvl(sum(system_bonus_amount),0)
                 into x_sum_of_deprn_amount,x_sum_of_bonus_amount
                 from fa_track_members
                where group_asset_id = P_group_asset_id
                  and member_asset_id <> l_track_member_in.member_asset_id
                  and period_counter = P_period_counter
                  and fiscal_year    = P_fiscal_year
                  and nvl(fully_reserved_flag,'N') <> 'Y'
                  and nvl(override_flag,'N') <> 'Y'
                  and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'x_sum_of_deprn:bonus_amount(realloc)',
                                x_sum_of_deprn_amount||':'||x_sum_of_bonus_amount);
            end if;

            -- Final Asset Rounding Adjustment
            x_allocated_deprn_amount := h_group_deprn_amount - x_sum_of_deprn_amount; -- h_system_deprn_amount);
            x_allocated_bonus_amount := nvl(h_group_bonus_amount,0) - nvl(x_sum_of_bonus_amount,0);
                                                                                     -- nvl(h_system_bonus_amount,0));

            h_system_deprn_amount := x_allocated_deprn_amount;
            h_system_bonus_amount := x_allocated_bonus_amount;

            -- subtraction flag
            if nvl(P_subtraction_flag,'N') = 'Y' then
               x_allocated_deprn_amount := x_allocated_deprn_amount - h_ytd_deprn;
               x_allocated_bonus_amount := x_allocated_bonus_amount - h_bonus_ytd_deprn;

               if nvl(P_mode,'DEPRECIATION') = 'DEPRECIATION' then

                  -- Subtract group level catchup expense since it will be added later.
                  h_deprn_expense := 0;
                  h_bonus_expense := 0;

                  if p_mrc_sob_type_code <> 'R' then
                     open FA_ADJ_EXPENSE(l_track_member_in.member_asset_id);
                     fetch FA_ADJ_EXPENSE into h_deprn_expense, h_bonus_expense;
                     close FA_ADJ_EXPENSE;
                  else
                     open FA_ADJ_EXPENSE_MRC(l_track_member_in.member_asset_id);
                     fetch FA_ADJ_EXPENSE_MRC into h_deprn_expense, h_bonus_expense;
                     close FA_ADJ_EXPENSE_MRC;
                  end if;

                  if nvl(P_mode,'ADJUSTMENT') <> 'DEPRECIATION' then
                     x_allocated_deprn_amount := x_allocated_deprn_amount - nvl(h_deprn_expense,0);
                     x_allocated_bonus_amount := x_allocated_bonus_amount - nvl(h_bonus_expense,0);
                  end if;
               end if;
            end if;

            -- Check if this member asset is not fully reserved die to this allocated amount.
            x_check_amount := l_track_member_in.adjusted_recoverable_cost;

            --bug6911981
            --Need to add following logic like bug6809835 (below is the same comment for the bug)
            --Bug6809835 Modified fix done for bug 6520356
            --abs should only be taken if total reserve and cost are both -ive
            -- Bug 6879353 : Use local variables instead of modifying the actual values
            -- Bug6987667:Old way did not handle when cost is -ve and rsv is +ve.
            -- So modified to multiply -1 if cost is -ve.
            if (x_check_amount < 0) then
               l_total_reserve := -1*(l_track_member_in.deprn_reserve + x_allocated_deprn_amount);
               l_check_amount := -1*(x_check_amount);
            else
               l_total_reserve := l_track_member_in.deprn_reserve + x_allocated_deprn_amount;
               l_check_amount := x_check_amount;
            end if;

            --bug6911981
            --Need to add following logic like bug6879353 (below is the same comment for the bug)
            -- Bug 6879353 : Use local variables for the check
            if l_total_reserve >= l_check_amount then

--bug6911981            if l_track_member_in.deprn_reserve + x_allocated_deprn_amount >= x_check_amount then
               x_fully_reserved_flag := 'Y';
               h_difference_deprn_amount := h_difference_deprn_amount + (x_allocated_deprn_amount -
                                                                              (x_check_amount - l_track_member_in.deprn_reserve));
               x_allocated_deprn_amount := x_check_amount - l_track_member_in.deprn_reserve;

               if P_group_bonus_rule is not null then

                  x_allocated_normal_amount := x_allocated_deprn_amount - x_allocated_bonus_amount;

                  if (x_allocated_deprn_amount - x_allocated_normal_amount < x_check_amount) and
                     (x_allocated_deprn_amount - x_allocated_normal_amount > 0) then

                     h_difference_bonus_amount := h_difference_bonus_amount + (x_allocated_bonus_amount -
                                                  (x_allocated_deprn_amount - x_allocated_normal_amount));
                     x_allocated_bonus_amount := x_allocated_deprn_amount - x_allocated_normal_amount;
                  else
                     h_difference_bonus_amount := h_difference_bonus_amount + x_allocated_bonus_amount;
                     x_allocated_bonus_amount := 0;
                  end if;
               end if;
            end if;

            -- Recalculate Reserve
            h_deprn_reserve := l_track_member_in.deprn_reserve + x_allocated_deprn_amount;
            h_bonus_deprn_reserve := nvl(l_track_member_in.bonus_deprn_reserve,0) + nvl(x_allocated_bonus_amount,0);

            if h_period_num <> 1 then
               h_ytd_deprn     := h_ytd_deprn + x_allocated_deprn_amount;
               h_bonus_ytd_deprn     := nvl(h_bonus_ytd_deprn,0) + nvl(x_allocated_bonus_amount,0);
            else
               h_ytd_deprn     := x_allocated_deprn_amount;
               h_bonus_ytd_deprn     := nvl(x_allocated_bonus_amount,0);
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'+++ Just before update table or PL/SQL table (Realloc) +++', P_mode);
               fa_debug_pkg.add(l_calling_fn,'x_allocated_deprn:bonus_amount',
                                x_allocated_deprn_amount||':'||x_allocated_bonus_amount, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'h_ytd_deprn:h_deprn_reserve:h_bonus_ytd_deprn:h_bonus_deprn_reserve',
                                               h_ytd_deprn||':'||h_deprn_reserve||':'||h_bonus_deprn_reserve||':'||
                                               h_bonus_ytd_deprn, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'x_fully_reserved_flag', x_fully_reserved_flag, p_log_level_rec => p_log_level_rec);

               if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
                  fa_debug_pkg.add(l_calling_fn, 'l_processed_number', l_processed_number, p_log_level_rec => p_log_level_rec);
               end if;
            end if;

            if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
               p_track_member_table(l_processed_number).allocated_deprn_amount := x_allocated_deprn_amount;
               p_track_member_table(l_processed_number).allocated_bonus_amount := x_allocated_bonus_amount;
               p_track_member_table(l_processed_number).fully_reserved_flag := x_fully_reserved_flag;
               p_track_member_table(l_processed_number).system_deprn_amount := h_system_deprn_amount;
               p_track_member_table(l_processed_number).system_bonus_amount := h_system_bonus_amount;
               p_track_member_table(l_processed_number).deprn_reserve := h_deprn_reserve;
               p_track_member_table(l_processed_number).ytd_deprn := h_ytd_deprn;
               p_track_member_table(l_processed_number).bonus_deprn_reserve := h_bonus_deprn_reserve;
               p_track_member_table(l_processed_number).bonus_ytd_deprn := h_bonus_ytd_deprn;
            else
-- ENERGY
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'before update ', '2', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn_amount', x_allocated_deprn_amount, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_ytd_deprn', h_ytd_deprn, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_deprn_reserve', h_deprn_reserve, p_log_level_rec => p_log_level_rec);
        end if;
-- ENERGY
               -- Update FA_TRACK_MEMBERS table
               update FA_TRACK_MEMBERS
                  set allocated_deprn_amount = x_allocated_deprn_amount,
                      allocated_bonus_amount = x_allocated_bonus_amount,
                      fully_reserved_flag = x_fully_reserved_flag,
                      system_deprn_amount = h_system_deprn_amount,
                      system_bonus_amount = h_system_bonus_amount,
                      deprn_reserve = h_deprn_reserve,
                      ytd_deprn = h_ytd_deprn,
                      bonus_deprn_reserve = h_bonus_deprn_reserve,
                      bonus_ytd_deprn = h_bonus_ytd_deprn
                where group_asset_id = P_group_asset_id
                  and member_asset_id = h_member_asset_id
                  and period_counter = P_period_counter
                  and fiscal_year = P_fiscal_year
                  and  nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
            end if;
         end if;
      end loop;

      if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

         x_total_allocated_deprn_amount := 0;
         x_total_allocated_bonus_amount := 0;

         For j IN 1 .. p_track_member_table.COUNT LOOP
            if p_track_member_table(j).group_asset_id = P_group_Asset_id and
               p_track_member_table(j).period_counter = P_period_counter and
               nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id,-99) then

               x_total_allocated_deprn_amount := x_total_allocated_deprn_amount +
                                                 nvl(p_track_member_table(j).allocated_deprn_amount, 0); -- bug6912446: Added nvl
               x_total_allocated_bonus_amount := x_total_allocated_bonus_amount +
                                                 nvl(p_track_member_table(j).allocated_bonus_amount, 0); -- bug6912446: Added nvl
            end if;
         END LOOP;
      else
         -- Query total of allocated amounts
         select sum(allocated_deprn_amount),sum(allocated_bonus_amount)
           into x_total_allocated_deprn_amount,x_total_allocated_bonus_amount
           from fa_track_members
          where group_asset_id = P_group_asset_id
            and period_counter = P_period_counter
            and fiscal_year    = P_fiscal_year
            and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
         end if;

         if h_all_member_fully_reserved = 'Y' and
            (nvl(h_difference_deprn_amount,0) <> 0 or nvl(h_difference_bonus_amount,0) <> 0) and
            nvl(P_group_level_override,'N') <> 'N' then

            -- This is a case when all member asset has been fully reserved and group level has been overridden.
            raise allocate_override_err;

         elsif nvl(h_difference_deprn_amount,0) <> 0 or nvl(h_difference_bonus_amount,0) <> 0 and
               nvl(P_group_level_override,'N') <> 'N' then
            raise allocate_override_err;
         else
            X_new_deprn_amount := x_total_allocated_deprn_amount;
            X_new_bonus_amount := x_total_allocated_bonus_amount;
         end if;
      else -- This is a case in which system doesn't need to reallocate amounts

         if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

            x_total_allocated_deprn_amount := 0;
            x_total_allocated_bonus_amount := 0;

            For j IN 1 .. p_track_member_table.COUNT LOOP

               if p_track_member_table(j).group_asset_id = P_group_Asset_id and
                  p_track_member_table(j).period_counter = P_period_counter and
                  nvl(p_track_member_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then

                  x_total_allocated_deprn_amount := x_total_allocated_deprn_amount +
                                                    p_track_member_table(j).allocated_deprn_amount;
                  x_total_allocated_bonus_amount := x_total_allocated_bonus_amount +
                                                    p_track_member_table(j).allocated_bonus_amount;
               end if;
            END LOOP;
         else
            -- Query total of allocated amounts using really applocated amounts
            select sum(allocated_deprn_amount),sum(allocated_bonus_amount)
              into x_total_allocated_deprn_amount,x_total_allocated_bonus_amount
              from fa_track_members
             where group_asset_id = P_group_asset_id
               and period_counter = P_period_counter
               and fiscal_year    = P_fiscal_year
               and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
          end if;

         X_new_deprn_amount := x_total_allocated_deprn_amount;
         X_new_bonus_amount := x_total_allocated_bonus_amount;
      end if;

      if nvl(p_mode,'DEPRECIATION') = 'ADJUSTMENT' then
         -- Insert new row into P_TRACK_MEMBER table for the next period
         l_processed_number := p_track_member_table.count;

        /* bug 7195989, used new function for bulk processing */
         if not populate_unplanned_exp(p_set_of_books_id => p_set_of_books_id,
                                       p_mrc_sob_type_code => p_mrc_sob_type_code,
                                       p_book_type_code => h_book_type_code,
                                       p_period_counter => p_period_counter,
                                       p_group_asset_id => P_group_asset_id,
                                       p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            raise main_err;
         end if;

         For j IN 1 .. p_track_member_table.count loop

          if p_track_member_table(j).group_asset_id = P_group_asset_id and
             p_track_member_table(j).period_counter = P_period_counter and
             nvl(p_track_member_table(j).set_of_books_id, -99) = nvl(p_set_of_books_id, -99) and
             nvl(p_track_member_table(j).fully_reserved_flag,'N') <> 'Y' then

             h_unplanned_expense := nvl(p_track_member_table(j).unplanned_deprn_amount,0);

            if h_unplanned_expense <> 0 then
               p_track_member_table(j).allocated_deprn_amount :=
                                      nvl(p_track_member_table(j).allocated_deprn_amount,0) + h_unplanned_expense;
               p_track_member_table(j).ytd_deprn := nvl(p_track_member_table(j).ytd_deprn,0) + h_unplanned_expense;
               p_track_member_table(j).deprn_reserve := nvl(p_track_member_table(j).deprn_reserve,0) +
                                                        h_unplanned_expense;
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,'Added Unplanned Depreciation Expense',
                                   h_unplanned_member_asset||':'||h_unplanned_expense||','||h_period_counter, p_log_level_rec => p_log_level_rec);
               end if;
            end if;

            l_processed_number := l_processed_number + 1;
            p_track_member_table(l_processed_number).group_asset_id := p_track_member_table(j).group_asset_id;
            p_track_member_table(l_processed_number).member_asset_id := p_track_member_table(j).member_asset_id;
            p_track_member_table(l_processed_number).period_counter := h_period_counter + 1;
            p_track_member_table(l_processed_number).fiscal_year := h_fiscal_year_next_period;
            p_track_member_table(l_processed_number).set_of_books_id := p_track_member_table(j).set_of_books_id;
            p_track_member_table(l_processed_number).cost := p_track_member_table(j).cost;
            p_track_member_table(l_processed_number).adjusted_cost := p_track_member_table(j).adjusted_cost;
            p_track_member_table(l_processed_number).recoverable_cost := p_track_member_table(j).recoverable_cost;
            p_track_member_table(l_processed_number).salvage_value := p_track_member_table(j).salvage_value;
            p_track_member_table(l_processed_number).adjusted_recoverable_cost :=
                                                                p_track_member_table(j).adjusted_recoverable_cost;
            p_track_member_table(l_processed_number).allocation_basis := p_track_member_table(j).allocation_basis;
            p_track_member_table(l_processed_number).total_allocation_basis :=
                                                                p_track_member_table(j).total_allocation_basis;
            p_track_member_table(l_processed_number).allocated_deprn_amount := 0;
            p_track_member_table(l_processed_number).allocated_bonus_amount := 0;
            p_track_member_table(l_processed_number).fully_reserved_flag :=
                                                                p_track_member_table(j).fully_reserved_flag;
            p_track_member_table(l_processed_number).system_deprn_amount := 0;
            p_track_member_table(l_processed_number).system_bonus_amount := 0;
            p_track_member_table(l_processed_number).override_flag := p_track_member_table(j).override_flag;
            p_track_member_table(l_processed_number).deprn_reserve := p_track_member_table(j).deprn_reserve;
            p_track_member_table(l_processed_number).ytd_deprn := p_track_member_table(j).ytd_deprn;
            p_track_member_table(l_processed_number).bonus_deprn_reserve :=
                                                                      p_track_member_table(j).bonus_deprn_reserve;
            p_track_member_table(l_processed_number).bonus_ytd_deprn := p_track_member_table(j).bonus_ytd_deprn;

            if h_fiscal_year_next_period <> h_fiscal_year then
               p_track_member_table(l_processed_number).eofy_reserve := p_track_member_table(j).deprn_reserve;
            else
               p_track_member_table(l_processed_number).eofy_reserve := p_track_member_table(j).eofy_reserve;
            end if;

            -- Add new record to index table
            put_track_index(p_track_member_table(l_processed_number).period_counter,
                            p_track_member_table(l_processed_number).member_asset_id ,
                            p_track_member_table(l_processed_number).group_asset_id,
                            p_track_member_table(l_processed_number).set_of_books_id,l_processed_number,
                            p_log_level_rec);

            if (p_log_level_rec.statement_level) then

               fa_debug_pkg.add(l_calling_fn, 'Inserted new row into p_track_member_table', l_processed_number, p_log_level_rec => p_log_level_rec);

               if not display_debug_message2(l_processed_number, l_calling_fn, p_log_level_rec) then
                  fa_debug_pkg.add(l_calling_fn, 'display_debug_message2', 'error returned', p_log_level_rec => p_log_level_rec);
               end if;
            end if;
         end if;
      end LOOP; -- All PL/SQL table check
   elsif nvl(p_mode,'DEPRECIATION') = 'DEPRECIATION' then
   -- Bug # 8394833 Added below code for bluk changes
       l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);
       If p_mrc_sob_type_code <> 'R' then
          Open c_mem_unplan_adj;
            loop
            fetch c_mem_unplan_adj bulk collect
            into l_mem_asset_id_tbl,
                 l_unplanned_exp_tbl
                  limit l_batch_size;
             if (l_mem_asset_id_tbl.count = 0)
                then exit;
             end if;
             for l_count in 1..l_mem_asset_id_tbl.count loop
                  h_unplanned_member_asset := l_mem_asset_id_tbl(l_count);
                  open FA_ADJ_UNPLANNED_MEM;
                  fetch FA_ADJ_UNPLANNED_MEM into l_unplanned_exp_mem_tbl(l_count);
                  close FA_ADJ_UNPLANNED_MEM;
                  l_unplanned_exp_tbl(l_count) := l_unplanned_exp_tbl(l_count) + l_unplanned_exp_mem_tbl(l_count);
             end loop;

             FORALL l_count IN 1..l_mem_asset_id_tbl.count
                UPDATE FA_BOOKS_SUMMARY
                  SET DEPRN_AMOUNT = l_unplanned_exp_tbl(l_count) + DEPRN_AMOUNT,
                      YTD_DEPRN = l_unplanned_exp_tbl(l_count) + YTD_DEPRN
                WHERE BOOK_TYPE_CODE = h_book_type_code
                  AND PERIOD_COUNTER = h_period_counter
                  AND ASSET_ID = l_mem_asset_id_tbl(l_count)
                  AND l_unplanned_exp_tbl(l_count) <> 0;
              end loop;
            close c_mem_unplan_adj;
          Else
             Open c_mem_unplan_adj_mrc;
               loop
               fetch c_mem_unplan_adj_mrc bulk collect
               into l_mem_asset_id_tbl,
                    l_unplanned_exp_tbl
                     limit l_batch_size;
                if (l_mem_asset_id_tbl.count = 0) then exit; end if;

                for l_count in 1..l_mem_asset_id_tbl.count loop
                     h_unplanned_member_asset := l_mem_asset_id_tbl(l_count);
                     open FA_ADJ_UNPLANNED_MEM_MRC;
                     fetch FA_ADJ_UNPLANNED_MEM_MRC into l_unplanned_exp_mem_tbl(l_count);
                     close FA_ADJ_UNPLANNED_MEM_MRC;
                     l_unplanned_exp_tbl(l_count) := l_unplanned_exp_tbl(l_count) + l_unplanned_exp_mem_tbl(l_count);
                end loop;

                FORALL l_count IN 1..l_mem_asset_id_tbl.count
                   UPDATE FA_MC_BOOKS_SUMMARY
                     SET DEPRN_AMOUNT = l_unplanned_exp_tbl(l_count) + DEPRN_AMOUNT,
                         YTD_DEPRN = l_unplanned_exp_tbl(l_count) + YTD_DEPRN
                   WHERE BOOK_TYPE_CODE = h_book_type_code
                     AND PERIOD_COUNTER = h_period_counter
		     AND SET_OF_BOOKS_ID = p_set_of_books_id
                     AND ASSET_ID = l_mem_asset_id_tbl(l_count)
                     AND l_unplanned_exp_tbl(l_count) <> 0;
                 end loop;
               close c_mem_unplan_adj_mrc;
           End if;
   end if; -- Adjustment mode check

<<skip_allocate>>
   if X_new_deprn_amount is null then
      X_new_deprn_amount := 0;
   end if;

   if X_new_bonus_amount is null then
      X_new_bonus_amount := 0;
   end if;

   return(true);

exception
   when allocate_err then
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return (FALSE);

   when allocate_override_err then
      fa_srvr_msg.add_message (calling_fn => l_calling_fn,
                               name => 'FA_NO_MEMBER_OVERRIDE', p_log_level_rec => p_log_level_rec);
      return (FALSE);

   when others then
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return (FALSE);
end allocate;

---------------------------------------------------------------------------
--
--  Function:  check_group_amounts
--
--  Description:
--              This function is called when system needs to update
--              Group Level Amounts as a result of tracking logic.
--              If system cannot update the group level amounts
--              due to some reason, this function will return false.
--
--  Returns:
--     0 - No error / 1 - error
--
---------------------------------------------------------------------------

FUNCTION check_group_amounts(P_book_type_code        in varchar2,
                           P_group_asset_id        in number,
                           P_period_counter        in number,
                           P_perd_deprn_exp        in number,
                           P_year_deprn_exp        in number,
                           P_recoverable_cost      in number,
                           P_adj_rec_cost          in number,
                           P_current_deprn_reserve in number,
                           P_nbv_threshold         in number,
                           P_nbv_thresh_amount     in number,
                           P_rec_cost_abs_value    in number,
                           X_life_complete_flag    out nocopy varchar2,
                           X_fully_reserved_flag   out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
   return number is

-- varibales for internal
nbv_absval              number;
adj_rec_cost_absval     number;
rsv_absval              number;

l_calling_fn            varchar2(40) := 'fa_track_member_pvt.check_group_amount';
chk_grp_amt_err         exception;

begin <<CHECK_GROUP_AMOUNT>>

-- If the remaining depreciation is small (absolutely OR relatively), then fully depreciate the asset
-- Calculate the absolute value of the asset's new NBV, Use adj_rec_cost as base instead of dpr.rec_cost
nbv_absval := abs(P_adj_rec_cost - (P_current_deprn_reserve + P_year_deprn_exp + P_perd_deprn_exp));

-- Debug
if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn,'++ CHECK_GROUP_AMOUNT ++++', 'Parameters', p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn,'P_adj_rec_cost:P_cur_deprn_rsv:P_year_deprn_exp:P_perd_deprn_exp',
                                   P_adj_rec_cost||':'||P_current_deprn_reserve||':'||P_year_deprn_exp||':'||P_perd_deprn_exp, p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn,'nbv_absval:P_nbv_threshold:P_nbv_threshold_amount',
                                   nbv_absval||':'||P_nbv_threshold||':'||P_nbv_thresh_amount, p_log_level_rec => p_log_level_rec);
end if;

-- Get the absolute value of the asset's Adjusted Recoverable Cost, do not use Recoverable Cost
adj_rec_cost_absval := abs (P_adj_rec_cost);

/* Unnecessary Check
-- Check the NBV against the constant value, and then
-- against the fraction of the Adjusted Recoverable Cost
if (nbv_absval < P_nbv_thresh_amount) or (nbv_absval <  P_nbv_threshold * adj_rec_cost_absval)  then
   -- In this case, system must update the Depreciation Expense Amount but passed amount cannot be updated.
   -- So at this time error will be raised.
  raise chk_grp_amt_err;
end if;
*/

rsv_absval := abs (P_current_deprn_reserve + P_year_deprn_exp + P_perd_deprn_exp);

-- if asset's deprn reserve is greater than adjusted revoverable cost, set fully reserve flag.
-- For assets which do not have deprn limit, recoverable cost is always equal to adjusted recoverable cost
if  adj_rec_cost_absval < rsv_absval then
   -- In this case, reserve is excessed Depreciation Limit.
   raise chk_grp_amt_err;
elsif adj_rec_cost_absval = rsv_absval then
  X_fully_reserved_flag := 'Y';
  X_life_complete_flag := 'Y';
end if;

return 0;

exception
  when chk_grp_amt_err then
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return 1;

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return 1;

end check_group_amounts;

---------------------------------------------------------------------------
--
--  Function:  allocation_main
--
--  Description:
--              This function is called to allocate group level amount
--              to member assets. This is the main logic to allocate amounts
--              to members.
--
----------------------------------------------------------------------------

FUNCTION allocation_main(P_book_type_code            in varchar2,
                         P_group_asset_id            in number,
                         P_member_asset_id           in number,
                         P_period_counter            in number,
                         P_fiscal_year               in number,
                         P_group_bonus_rule          in varchar2, -- default null,
                         P_group_deprn_amount        in number,
                         P_group_bonus_amount        in number, -- default 0,
                         P_allocation_basis          in number,
                         P_total_allocation_basis    in number,
                         P_ytd_deprn                 in number,
                         P_bonus_ytd_deprn           in number, -- default 0,
                         P_track_member_in           in track_member_struct,
                         P_check_reserve_flag        in Varchar2, -- default null,
                         P_subtraction_flag          in varchar2, -- default null,
                         P_group_level_override      in out nocopy varchar2, -- default null,
                         P_update_override_status    in boolean, -- default true,
                         P_member_override_flag      in varchar2, -- default null,
                         PX_difference_deprn_amount  in out nocopy number,
                         PX_difference_bonus_amount  in out nocopy number,
                         X_system_deprn_amount       out nocopy number,
                         X_system_bonus_amount       out nocopy number,
                         X_track_member_out          out nocopy track_member_struct,
                         P_mrc_sob_type_code         in varchar2, -- default 'N',
                         P_set_of_books_id           in number,
                         P_mode                      in Varchar2,
                         P_rec_cost_for_odda         in number,
                         P_sv_for_odda               in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

-- variables
x_calc_done                  varchar2(1);
x_alloccation_basis          number;
x_total_allocation_amounts   number;
x_allocated_deprn_amount     number;
x_allocated_bonus_amount     number;
x_allocated_normal_amount    number;
x_fully_reserved_flag        varchar2(1);
x_check_amount               number;

x_deprn_reserve              number;
x_ytd_deprn                  number;
x_bonus_deprn_reserve        number;
x_bonus_ytd_deprn            number;
x_dummy                      number;

-- variables to call override function
x_override_flag              varchar2(1);
h_used_by                    boolean;
h_perd_ctr                   number;
h_perd_deprn_amount          number;
h_perd_bonus_amount          number;
h_deprn_override_flag        varchar2(1);
h_return_code                number;
h_catchup_expense            number;
h_catchup_bonus              number;

h_perds_per_yr               number;
h_book_type_code             varchar2(30);
h_group_asset_id             number;
h_member_asset_id            number;
h_period_counter             number;
h_fiscal_year                number;
h_allocation_basis           number;
h_total_allocation_basis     number;

h_reporting_flag             varchar2(1);

h_cost                       number;
h_adjusted_cost              number;
h_salvage_value              number;
h_recoverable_cost           number;
h_adjusted_recoverable_cost  number;

h_prior_year_reserve         number;
h_eofy_recoverable_cost      number;
h_eop_recoverable_cost       number;
h_eofy_salvage_value         number;
h_eop_salvage_value          number;
h_deprn_override             number;

h_deprn_expense              number;
h_bonus_expense              number;

l_calling_fn                 varchar2(35) := 'fa_track_member_pvt.allocation_main';
allocation_main_err          exception;
allocation_main_override_err exception;
allocation_main_update_err exception;

-- Check cursor
cursor CHECK_EXISTS is
 select 1
   from fa_track_members
  where group_asset_id = h_group_asset_id
    and member_asset_id = h_member_asset_id
    and period_counter = h_period_counter
    and fiscal_year = h_fiscal_year
    and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

--* cursor to get period number
cursor GET_PERIOD_NUM(p_per_counter number) is
  select period_num
    from fa_deprn_periods
   where book_type_code = P_book_type_code
     and period_counter = p_per_counter;

cursor GET_PERIOD_NUM_MRC(p_per_counter number) is
  select period_num
    from fa_mc_deprn_periods
   where book_type_code = P_book_type_code
     and period_counter = p_per_counter
     and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

--* Cursor for FA_ADJUSTMENTS
cursor FA_ADJ_EXPENSE(p_member_asset_id number) is
   select /*+ ORDERED
          Index(TH2 FA_TRANSACTION_HEADERS_N1)
          INDEX(TH1 FA_TRANSACTION_HEADERS_N7)
          INDEX(ADJ FA_ADJUSTMENTS_U1)*/
          sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_transaction_headers th2,
          fa_transaction_headers th1,
          fa_adjustments adj
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = p_group_asset_id
      and adj.book_type_code = p_book_type_code
      and adj.period_counter_adjusted = p_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = nvl(p_member_asset_id,th2.asset_id);

--* Cursor for FA_ADJUSTMENTS
cursor FA_ADJ_EXPENSE_MRC (p_member_asset_id number) is
      select
          sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_transaction_headers th2,
          fa_transaction_headers th1,
          fa_mc_adjustments adj
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = p_group_asset_id
      and adj.book_type_code = p_book_type_code
      and adj.period_counter_adjusted = p_period_counter
      and adj.set_of_books_id = p_set_of_books_id
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = nvl(p_member_asset_id,th2.asset_id);

--Bug 6809835, 6879353
l_total_reserve number;
l_check_amount  number;

begin
   /* Apply MRC related feature */

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '+++ ALLOCATION_MAIN start +++', '+++', p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_set_of_books_id', p_set_of_books_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'P_group_deprn_amount:P_allocation_basis:P_total_allocation_basis:P_ytd_deprn',
                                       P_group_deprn_amount||':'||P_allocation_basis||':'||P_total_allocation_basis||':'||P_ytd_deprn, p_log_level_rec => p_log_level_rec);
   end if;

   -- Reset calculation flag
   x_calc_done := 'N';

   -- Get period Number
   if P_mrc_sob_type_code <> 'R' then
     open GET_PERIOD_NUM(P_period_counter);
     fetch GET_PERIOD_NUM into h_perd_ctr;
     if GET_PERIOD_NUM%NOTFOUND then
       h_perds_per_yr   := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
       h_perd_ctr := P_period_counter - (P_fiscal_year * h_perds_per_yr);
     end if;
     close GET_PERIOD_NUM;
   else
     open GET_PERIOD_NUM_MRC(P_period_counter);
     fetch GET_PERIOD_NUM_MRC into h_perd_ctr;
     if GET_PERIOD_NUM_MRC%NOTFOUND then
       h_perds_per_yr   := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
       h_perd_ctr := P_period_counter - (P_fiscal_year * h_perds_per_yr);
     end if;
     close GET_PERIOD_NUM_MRC;
   end if;

   -- Calculate Allocated Amount
   -- In case subtraction_flag = 'Y', P_group_amount and P_group_bonus_amount will be
   -- YTD amount, otherwise those will be periodic depreciation.

   --Bug7022054: Avoid 0 divisor
   if (nvl(P_total_allocation_basis, 0) = 0) then
      x_allocated_deprn_amount := 0;
      x_allocated_bonus_amount := 0;
   else
      x_allocated_deprn_amount := P_group_deprn_amount * P_allocation_basis / P_total_allocation_basis;
      x_allocated_bonus_amount := nvl(P_group_bonus_amount,0) * P_allocation_basis / P_total_allocation_basis;
   end if;


   -- Rounding
   if not fa_utils_pkg.faxrnd
          (x_amount => x_allocated_deprn_amount,
           x_book   => P_book_type_code,
           x_set_of_books_id => p_set_of_books_id,
           p_log_level_rec => p_log_level_rec) then
          raise allocation_main_err;
   end if;
   if not fa_utils_pkg.faxrnd
          (x_amount => x_allocated_bonus_amount,
           x_book => P_book_type_code,
           x_set_of_books_id => p_set_of_books_id,
           p_log_level_rec => p_log_level_rec) then
      raise allocation_main_err;
   end if;

   -- System Allocated Amount is YTD when Subtraction Flag is 'Y' and these amounts may be updated later.
   X_system_deprn_amount := x_allocated_deprn_amount;
   X_system_bonus_amount := x_allocated_bonus_amount;

   -- Calculate subtract amount when subtraction flag is 'Y'
   if nvl(P_subtraction_flag,'N') = 'Y' then
      x_allocated_deprn_amount := x_allocated_deprn_amount - P_ytd_deprn;
      x_allocated_bonus_amount := x_allocated_bonus_amount - P_bonus_ytd_deprn;
      X_system_deprn_amount := x_allocated_deprn_amount + P_ytd_deprn;
      X_system_bonus_amount := x_allocated_bonus_amount + P_bonus_ytd_deprn;
   end if;

   x_allocated_normal_amount := x_allocated_deprn_amount - x_allocated_bonus_amount;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn:bonus_amount(1)', x_allocated_deprn_amount||':'||x_allocated_bonus_amount);
       fa_debug_pkg.add(l_calling_fn, 'x_system_deprn:bonus_amount', x_system_deprn_amount||':'||x_system_bonus_amount, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'x_allocated_normal_amount', x_allocated_normal_amount, p_log_level_rec => p_log_level_rec);
   end if;

   -- Set calculation flag
   x_calc_done := 'Y';
   x_override_flag := 'N';

   -- Manual Override feature call
   if (fa_cache_pkg.fa_deprn_override_enabled) and
      nvl(P_mode,'DEPRECIATION') in ('DEPRECIATION','ADJUSTMENT') then

   -- Override feature is applicable only when this is processed
   -- in Depreciation or Catchup Calculation in Adjustment
     if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then
        h_used_by := TRUE;
     else
        h_used_by := FALSE;
     end if;

   savepoint member_override; -- In case this override is not acceptable, need to be rollbacked

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'l_processing_member_table', l_processing_member_table, p_log_level_rec => p_log_level_rec);
     end if;

     if nvl(l_processing_member_table,'NO') = 'YES' then -- This is a case to call override_member_amounts

       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Query overridden amount from override table', '***');
       end if;

       if not override_member_amount(p_book_type_code => P_book_type_code,
                                     p_member_asset_id => P_member_asset_id,
                                     p_fiscal_year => P_fiscal_year,
                                     p_period_num => h_perd_ctr,
                                     p_ytd_deprn => P_ytd_deprn,
                                     p_bonus_ytd_deprn => P_bonus_ytd_deprn,
                                     x_override_deprn_amount => h_perd_deprn_amount,
                                     x_override_bonus_amount => h_perd_bonus_amount,
                                     x_deprn_override_flag => h_deprn_override_flag,
                                     p_calling_fn => 'POPULATE_MEMBER_ASSETS_TABLE',
                                     p_mrc_sob_type_code => P_mrc_sob_type_code,
                                     p_recoverable_cost => P_rec_cost_for_odda,
                                     p_salvage_value => P_sv_for_odda,
                                     p_log_level_rec => p_log_level_rec) then
          rollback to member_override;
          raise allocation_main_err;
       end if;
     else
       if not FA_CDE_PKG.faodda(book=> P_book_type_code,
                              used_by_adjustment => h_used_by,
                              asset_id => P_member_asset_id,
                              bonus_rule => P_group_bonus_rule,
                              fyctr => P_fiscal_year,
                              perd_ctr => h_perd_ctr,
                              prod_rate_src_flag => FALSE,
                              deprn_projecting_flag => FALSE,
                              override_depr_amt => h_perd_deprn_amount,
                              override_bonus_amt => h_perd_bonus_amount,
                              deprn_override_flag => h_deprn_override_flag,
                              return_code => h_return_code,
                              p_ytd_deprn => P_ytd_deprn,
                              p_bonus_ytd_deprn => P_bonus_ytd_deprn,
                              p_update_override_status => P_update_override_status,
                              p_mrc_sob_type_code => P_mrc_sob_type_code,
                              p_set_of_books_id => p_set_of_books_id,
                              p_recoverable_cost => P_rec_cost_for_odda,
                              p_salvage_value => P_sv_for_odda, p_log_level_rec => p_log_level_rec) then
                rollback to member_override;
                raise allocation_main_err;
       end if;
     end if;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'h_deprn_override_flag', h_deprn_override_flag, p_log_level_rec => p_log_level_rec);
     end if;

     h_deprn_override := 0;
     if h_deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE then
        if nvl(P_group_level_override,'N') = 'Y' then
           rollback to member_override;
           raise allocation_main_override_err;
        else
           x_override_flag := 'Y';
        end if;
        if h_deprn_override_flag = fa_std_types.FA_OVERRIDE_DPR then
           x_allocated_deprn_amount := h_perd_deprn_amount;
           h_deprn_override := 1;
        elsif h_deprn_override_flag = fa_std_types.FA_OVERRIDE_DPR_BONUS then
           x_allocated_deprn_amount := h_perd_deprn_amount;
           x_allocated_bonus_amount := h_perd_bonus_amount;
           h_deprn_override := 3;
        elsif h_deprn_override_flag = fa_std_types.FA_OVERRIDE_BONUS then
           x_allocated_bonus_amount := h_perd_bonus_amount;
           h_deprn_override := 2;
        end if; -- override type check

        P_group_level_override := h_deprn_override_flag;
     end if; -- override flag check
   end if; -- override is enable or not

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'P_group_deprn_override', P_group_level_override, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'P_check_reserve_flag', P_check_reserve_flag, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'P_track_member_in.adjusted_recoverable_cost:recoverable_cost',
                                                      P_track_member_in.adjusted_recoverable_cost||':'||P_track_member_in.recoverable_cost, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'P_track_member_in.deprn_reserve',P_track_member_in.deprn_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn_amount',x_allocated_deprn_amount, p_log_level_rec => p_log_level_rec);
   end if;

   -- Check if this member asset is not fully reserved due to this allocated amount.
   if P_check_reserve_flag = 'Y' then
      x_check_amount := P_track_member_in.adjusted_recoverable_cost;

      -- Bug6987667:Old way did not handle when cost is -ve and rsv is +ve.
      -- So modified to multiply -1 if cost is -ve.
      --Bug6809835 Modified fix done for bug 6520356
      --abs should only be taken if total reserve and cost are both -ive
      -- Bug 6879353 : Use local variables instead of modifying the actual values
      if (x_check_amount < 0) then
            l_total_reserve := -1*(P_track_member_in.deprn_reserve + x_allocated_deprn_amount);
            l_check_amount := -1*(x_check_amount);
      else
            l_total_reserve := P_track_member_in.deprn_reserve + x_allocated_deprn_amount;
            l_check_amount := x_check_amount;
      end if;

      -- Bug 6879353 : Use local variables for the check
      if l_total_reserve >= l_check_amount then
         if nvl(x_override_flag,'N') <> 'Y' then
            x_fully_reserved_flag := 'Y';

            --Bug7008015: reset allocate_deprn_amount only if it was not fully reserved even before allocation
            -- This is to avoid backing out and reallocate rsv due to downward cost adjustments
            -- if reserve (before allocation) is greater than the adjusted_recoverable_cost, then allocate 0 amount
            -- and add original allocated amount as difference and reallocate it to other member assets
            if ((x_check_amount < 0) and
                (l_check_amount > -1*(P_track_member_in.deprn_reserve))) or
               ((x_check_amount > 0) and
                (l_check_amount > (P_track_member_in.deprn_reserve))) then
               PX_difference_deprn_amount := PX_difference_deprn_amount +
                                             x_allocated_deprn_amount - (x_check_amount - P_track_member_in.deprn_reserve);
               x_allocated_deprn_amount := x_check_amount - P_track_member_in.deprn_reserve;
            else
               PX_difference_deprn_amount := PX_difference_deprn_amount + x_allocated_deprn_amount;
               x_allocated_deprn_amount := 0;
            end if;


            if (x_allocated_deprn_amount - x_allocated_normal_amount < x_check_amount) and
               (x_allocated_deprn_amount - x_allocated_normal_amount > 0) and
                P_group_bonus_rule is not null then
               PX_difference_bonus_amount := PX_difference_bonus_amount + x_allocated_bonus_amount -
                                                        (x_allocated_deprn_amount - x_allocated_normal_amount);
               x_allocated_bonus_amount := x_allocated_deprn_amount - x_allocated_normal_amount;
            else
               PX_difference_bonus_amount := PX_difference_bonus_amount + x_allocated_bonus_amount;
               x_allocated_bonus_amount := 0;
            end if;

            -- In case Subtraction Flag is 'Y', replace the system amount with limited amount.
            if nvl(P_subtraction_flag,'N') = 'Y' then
               X_system_deprn_amount := x_allocated_deprn_amount + P_ytd_deprn;
               X_system_bonus_amount := x_allocated_bonus_amount + P_bonus_ytd_deprn;
            end if;

         else -- If the deprn amount is overridden....
            rollback to member_override;
            raise allocation_main_update_err;

         end if; -- Check if Overridden or not
      end if; -- The case not to excess the limit
   end if; -- Check if reserve check is required or not

   -- Reduce subtraction case
   if nvl(P_mode,'DEPRECIATION') = 'DEPRECIATION' and nvl(P_subtraction_flag,'N') = 'Y' then
      -- Subtract group level catchup expense since it will be added later.
     h_deprn_expense := 0;
     h_bonus_expense := 0;
     if p_mrc_sob_type_code <> 'R' then
       open FA_ADJ_EXPENSE(p_member_asset_id);
       fetch FA_ADJ_EXPENSE into h_deprn_expense, h_bonus_expense;
       close FA_ADJ_EXPENSE;
     else
       open FA_ADJ_EXPENSE_MRC(p_member_asset_id);
       fetch FA_ADJ_EXPENSE_MRC into h_deprn_expense, h_bonus_expense;
       close FA_ADJ_EXPENSE_MRC;
     end if;
     x_allocated_deprn_amount := x_allocated_deprn_amount - nvl(h_deprn_expense,0);
     x_allocated_bonus_amount := x_allocated_bonus_amount - nvl(h_bonus_expense,0);
   --  X_system_deprn_amount := x_system_deprn_amount - nvl(h_deprn_expense,0);
   --  X_system_bonus_amount := x_system_bonus_amount - nvl(h_bonus_expense,0);
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '** after Subtraction Case **', '***');
       fa_debug_pkg.add(l_calling_fn, 'x_allocated_deprn:bonus_amount', x_allocated_deprn_amount||':'||x_allocated_deprn_amount, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'x_system_deprn:bonus_amount', x_system_deprn_amount||':'||x_system_deprn_amount, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'h_deprn:bonus_expense', h_deprn_expense||':'||h_bonus_expense, p_log_level_rec => p_log_level_rec);
     end if;
   end if;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'P_track_member_in.reserve_adjustment_amount', -- ENERGY
                      P_track_member_in.reserve_adjustment_amount, p_log_level_rec => p_log_level_rec);                -- ENERGY
   end if;

   -- Calculate Reserve Amount
   x_deprn_reserve := nvl(P_track_member_in.deprn_reserve,0) + nvl(x_allocated_deprn_amount,0) -- ENERGY
                      - nvl(P_track_member_in.reserve_adjustment_amount, 0);                   -- ENERGY

   if h_perd_ctr <> 1 then
      x_ytd_deprn := nvl(P_ytd_deprn,0) + nvl(x_allocated_deprn_amount,0);
   else
      x_ytd_deprn := nvl(x_allocated_deprn_amount,0);
   end if;

   x_bonus_deprn_reserve := nvl(P_track_member_in.bonus_deprn_reserve,0) + nvl(x_allocated_bonus_amount,0);

   if h_perd_ctr <> 1 then
      x_bonus_ytd_deprn     := nvl(P_bonus_ytd_deprn,0) + nvl(x_allocated_bonus_amount,0);
   else
      x_bonus_ytd_deprn     := nvl(x_allocated_bonus_amount,0);
   end if;

   -- Debugging
   h_group_asset_id := P_group_asset_id;
   h_member_asset_id := P_member_asset_id;
   h_period_counter := P_period_counter;
   h_fiscal_year := P_fiscal_year;
   h_allocation_basis := P_allocation_basis;
   h_total_allocation_basis := P_total_allocation_basis;
   h_cost := P_track_member_in.cost;
   h_adjusted_cost := P_track_member_in.adjusted_cost;
   h_salvage_value := P_track_member_in.salvage_value;
   h_recoverable_cost := P_track_member_in.recoverable_cost;
   h_adjusted_recoverable_cost := P_track_member_in.adjusted_recoverable_cost;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'+++ Just before storing calculated amounts (mode=)', P_mode);
      fa_debug_pkg.add(l_calling_fn,'h_group_asset:h_member_asset:h_period_counter:h_fiscal_year',
                                     h_group_asset_id||':'||h_member_asset_id||':'||h_period_counter||':'||h_fiscal_year, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'h_cost:h_adjusted_cost:h_salvage_value:h_recoverable_cost:h_adj_rec_cost',
                                     h_cost||':'||h_adjusted_cost||':'||h_salvage_value||':'||h_recoverable_cost||':'||h_adjusted_recoverable_cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'x_allocated_deprn:bonus_amount(2)', x_allocated_deprn_amount||':'||x_allocated_bonus_amount);
      fa_debug_pkg.add(l_calling_fn,'x_system_deprn:bonus_amount(2)', x_system_deprn_amount||':'||x_system_bonus_amount);
      fa_debug_pkg.add(l_calling_fn, 'x_ytd_deprn:x_deprn_reserve:x_bonus_ytd_deprn:x_bonus_deprn_reserve',
                                     x_ytd_deprn||':'||x_deprn_reserve||':'||x_bonus_deprn_reserve||':'||x_bonus_ytd_deprn, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'h_total_allocation_basis:h_allocation_basis', h_total_allocation_basis||':'||h_allocation_basis, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'h_fully_reserved_flag', x_fully_reserved_flag, p_log_level_rec => p_log_level_rec);
   end if;

   if nvl(P_mode,'DEPRECIATION') <> 'ADJUSTMENT' then
     -- Check if the row has been inserted
     x_dummy := to_number(NULL);

     open CHECK_EXISTS;
     fetch CHECK_EXISTS into x_dummy;
     close CHECK_EXISTS;
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('allocation_main','insert/update check', x_dummy, p_log_level_rec => p_log_level_rec);
     end if;

     --bug6923135
     --Placing nvl around variables so that pro*c code can handle the fetched value.
     if x_dummy is NULL then
       -- Insert into  FA_TRACK_MEMBERS table
       Insert into FA_TRACK_MEMBERS(group_asset_id,
                                member_asset_id,
                                period_counter,
                                fiscal_year,
                                set_of_books_id,
                                allocation_basis,
                                total_allocation_basis,
                                allocated_deprn_amount,
                                allocated_bonus_amount,
                                fully_reserved_flag,
                                system_deprn_amount,
                                system_bonus_amount,
                                cost,
                                adjusted_cost,
                                salvage_value,
                                recoverable_cost,
                                adjusted_recoverable_cost,
                                override_flag,
                                deprn_reserve,
                                ytd_deprn,
                                bonus_deprn_reserve,
                                bonus_ytd_deprn,
                                deprn_override_flag)
          values
              (h_group_asset_id,
               h_member_asset_id,
               h_period_counter,
               h_fiscal_year,
               p_set_of_books_id,
               h_allocation_basis,
               h_total_allocation_basis,
               nvl(x_allocated_deprn_amount, 0), --bug6923135
               nvl(x_allocated_bonus_amount, 0), --bug6923135
               x_fully_reserved_flag,
               nvl(X_system_deprn_amount, 0), --bug6923135
               nvl(X_system_bonus_amount, 0), --bug6923135
               h_cost,
               h_adjusted_cost,
               h_salvage_value,
               h_recoverable_cost,
               h_adjusted_recoverable_cost,
               x_override_flag,
               x_deprn_reserve,
               x_ytd_deprn,
               x_bonus_deprn_reserve,
               x_bonus_ytd_deprn,
               h_deprn_override);
     else -- Need to update
       if nvl(P_member_override_flag,'N') <> 'Y' then
         Update FA_TRACK_MEMBERS
            set allocation_basis = h_allocation_basis,
                total_allocation_basis = h_total_allocation_basis,
                allocated_deprn_amount = x_allocated_deprn_amount,
                allocated_bonus_amount = x_allocated_bonus_amount,
                fully_reserved_flag = x_fully_reserved_flag,
                system_deprn_amount = x_system_deprn_amount,
                system_bonus_amount = x_system_bonus_amount,
                deprn_reserve = x_deprn_reserve,
                ytd_deprn = x_ytd_deprn,
                bonus_deprn_reserve = x_bonus_deprn_reserve,
                bonus_ytd_deprn = x_bonus_ytd_deprn
          where group_asset_id = h_group_asset_id
            and member_asset_id = h_member_asset_id
            and period_counter = h_period_counter
            and fiscal_year = h_fiscal_year
            and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
       else -- In case this member has been overridden...
         Update FA_TRACK_MEMBERS
            set system_deprn_amount = x_system_deprn_amount,
                system_bonus_amount = x_system_bonus_amount
          where group_asset_id = h_group_asset_id
            and member_asset_id = h_member_asset_id
            and period_counter = h_period_counter
            and fiscal_year = h_fiscal_year
            and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);
       end if; -- P_member_override_flag
     end if; -- h_dummy
   end if; -- Adjustment or not

   -- Set P_track_member_out
   X_track_member_out.group_Asset_id := h_group_asset_id;
   X_track_member_out.member_asset_id := h_member_asset_id;
   X_track_member_out.period_counter := h_period_counter;
   X_track_member_out.fiscal_year := h_fiscal_year;
   X_track_member_out.set_of_books_id := p_set_of_books_id;
   X_track_member_out.cost := h_cost;
   X_track_member_out.adjusted_cost := h_adjusted_cost;
   X_track_member_out.salvage_value := h_salvage_value;
   X_track_member_out.recoverable_cost := h_recoverable_cost;
   X_track_member_out.adjusted_recoverable_cost := h_adjusted_recoverable_cost;
   X_track_member_out.allocation_basis := h_allocation_basis;
   X_track_member_out.total_allocation_basis := h_total_allocation_basis;
   X_track_member_out.allocated_deprn_amount := x_allocated_deprn_amount;
   X_track_member_out.allocated_bonus_amount := x_allocated_bonus_amount;
   X_track_member_out.fully_reserved_flag := x_fully_reserved_flag;
   X_track_member_out.system_deprn_amount := X_system_deprn_amount;
   X_track_member_out.system_bonus_amount := X_system_bonus_amount;
   X_track_member_out.cost := h_cost;
   X_track_member_out.adjusted_cost := h_adjusted_cost;
   X_track_member_out.salvage_value := h_salvage_value;
   X_track_member_out.recoverable_cost := h_recoverable_cost;
   X_track_member_out.adjusted_recoverable_cost := h_adjusted_recoverable_cost;
   X_track_member_out.override_flag := x_override_flag;
   X_track_member_out.deprn_reserve := x_deprn_reserve;
   X_track_member_out.ytd_deprn := x_ytd_deprn;
   X_track_member_out.bonus_deprn_reserve := x_bonus_deprn_reserve;
   X_track_member_out.bonus_ytd_deprn := x_bonus_ytd_deprn;

   -- Set Calc Flag
   x_calc_done := 'Y';

   return(true);

exception
  when allocation_main_err then
    rollback to member_override;
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

  when allocation_main_override_err then
    rollback to member_override;
    fa_srvr_msg.add_message (calling_fn => l_calling_fn,
                             name => 'FA_NO_MEMBER_OVERRIDE', p_log_level_rec => p_log_level_rec);
    return(false);

  when allocation_main_update_err then
    rollback to member_override;
    fa_srvr_msg.add_message (calling_fn => l_calling_fn,
                                 name => 'FA_CANNOT_UPDATE_OVERRIDE', p_log_level_rec => p_log_level_rec);
    return(false);

  when others then
    rollback to member_override;
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

end allocation_main;

----------------------------------------------------------------------------
--
--  Function:   update_depreciable_basis
--
--  Description:
--              This function is called to update Depreciable Basis in some cases.
--              The case when this function is called is that the group level depreciable
--              basis rule has group level check logic, such as 50% rules for CCA or India.
--              In these logic, system needs to check group level net amount for the specified
--              period to decide if 50% reduction is applied or not.
--              This cannot be checked at member level. So after group level depreciable basis
--              updated is done, Deprn Basis Rule function will call this function to update
--              member level depreciable basis.
--              to members.
--              When l_process_deprn_for_member is 'NO', this is not processed.
--
----------------------------------------------------------------------------

FUNCTION update_deprn_basis(p_group_rule_in          in fa_std_types.fa_deprn_rule_in_struct,
                            p_apply_reduction_flag   in varchar2, -- default NULL,
                            p_mode                   in varchar2
                            ,p_log_level_rec       IN fa_api_types.log_level_rec_type) -- default NULL)
  return boolean is

--* Structure to call Deprn Basis Rule
fa_rule_in      fa_std_types.fa_deprn_rule_in_struct;
fa_rule_out     fa_std_types.fa_deprn_rule_out_struct;

--* Internal Variables
x_counter               number;
x_added_cost            number;
x_retired_cost          number;
x_asset_type            varchar2(15);
x_fully_retired_flag    varchar2(1);
h_current_adjusted_cost number;
h_current_cost          number;
h_current_salvage_value number;
h_current_adj_recoverable_cost number;
h_current_recoverable_cost number;

h_adj_cost              number;
h_adj_salvage_value     number;
h_adj_adjusted_rec_cost number;
h_adj_transaction_header_id        number;
h_adj_member_trans_header_id       number;
h_adj_eofy_reserve      number;

h_adj_salvage_type      varchar2(30);
h_adj_percent_salvage   number;
h_adj_limit_type        varchar2(30);
h_adj_percent_limit     number;

h_transaction_type_code            varchar2(20);
h_transaction_key                  varchar2(2);
h_asset_id                         number;
h_cur_period_counter  number;

h_check_adj_cost  number;

--* Host related variables
h_book_type_code        varchar2(30);
h_group_asset_id        number;
h_member_asset_id       number;
h_period_counter        number;
h_fiscal_year           number;
h_set_of_books_id       number;
h_trans_period_counter  number;

h_eofy_rec_cost         number;
h_eofy_salvage_value    number;
h_eofy_adj_cost         number;
h_new_prior_year_reserve    number;
h_new_eofy_recoverable_cost number;
h_new_eofy_salvage_value number;
h_new_eop_recoverable_cost number;
h_new_eop_salvage_value number;
h_new_eofy_reserve       number;

h_eop_adj_cost           number;
h_prior_eofy_reserve     number;

h_catchup_expense       number;
h_bonus_catchup_expense number;
h_catchup_expense_mem   number;
h_bonus_catchup_mem     number;
h_dummy                 number;
h_recognize_gain_loss   varchar2(15);
k                       number;
h_memory_update_status  varchar2(3);

h_rsv_adjustment        number;
h_bonus_rsv_adjustment  number;
h_rsv_adjustment_mem    number;
h_bonus_rsv_adj_mem     number;
h_net_proceeds          number;
h_net_proceeds_mem      number;
h_reserve_retired       number;

h_ds_fy                 number;
l_addition_check        varchar2(1);
l_addition_number       number;
l_track_member          track_member_struct;

l_adj_asset_type        varchar2(11);
l_transaction_header_id number;
l_transaction_date_entered date;

h_trans_fiscal_year     number;
h_trans_period_num      number;
h_fiscal_year_name      varchar2(30);
h_calendar_type         varchar2(15);
h_period_per_fiscal_year number;

h_exclude_fully_rsv_flag varchar2(1);

h_check_row_existing    varchar2(1);

l_calling_fn            varchar2(40) := 'fa_track_member_pvt.update_deprn_basis';
upd_deprn_err           exception;

--* cursor to query members belonged to the specified group
--  this is used to update deprn basis when group level is updated
cursor ALL_MEMBERS is
  select bk.group_asset_id group_asset_id,
         bk.asset_id       member_asset_id,
         bk.cost           cost,
         bk.salvage_value  salvage_value,
         bk.recoverable_cost recoverable_cost,
         bk.adjusted_cost  adjusted_cost,
         bk.adjusted_recoverable_cost adjusted_recoverable_cost,
         bk.period_counter_fully_retired fully_retired_flag,
         bk.period_counter_fully_reserved fully_reserved_flag,
         bk.eofy_reserve    bk_eofy_reserve,
         bk.eofy_adj_cost  eofy_adj_cost,
         ds.period_counter ds_period_counter,
         ds.deprn_reserve  ds_deprn_reserve,
         ds.ytd_deprn      ds_ytd_deprn,
         ds.bonus_deprn_reserve ds_bonus_deprn_reserve,
         ds.bonus_ytd_deprn ds_bonus_ytd_deprn,
         temp.deprn_reserve temp_deprn_reserve,
         temp.ytd_deprn     temp_ytd_deprn,
         temp.bonus_deprn_reserve temp_bonus_deprn_reserve,
         temp.bonus_ytd_deprn temp_bonus_ytd_deprn,
         temp.prior_year_reserve temp_prior_year_reserve,
         temp.eofy_recoverable_cost temp_eofy_recoverable_cost,
         temp.eop_recoverable_cost temp_eop_recoverable_cost,
         temp.eofy_salvage_value temp_eofy_salvage_value,
         temp.eop_salvage_value  temp_eop_salvage_value
    from fa_books bk,
         fa_deprn_summary ds,
         fa_track_members temp
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_group_asset_id
     and bk.date_ineffective is null
     and ds.book_type_code = bk.book_type_code
     and ds.asset_id = bk.asset_id
     and (ds.period_counter =
          (select max(ds1.period_counter)
             from fa_deprn_summary ds1
            where ds1.book_type_code=h_book_type_code
              and ds1.asset_id=bk.asset_id
              and ds1.period_counter <= h_period_counter - 1)
         or
          ds.period_counter = nvl(bk.period_counter_fully_reserved,-99))
     and temp.member_asset_id (+) = bk.asset_id
     and temp.period_counter (+) = h_period_counter
     and temp.fiscal_year (+) = h_fiscal_year
     and temp.set_of_books_id (+) = nvl(h_set_of_books_id,-99);

cursor ALL_MEMBERS_MRC is
  select bk.group_asset_id group_asset_id,
         bk.asset_id       member_asset_id,
         bk.cost           cost,
         bk.salvage_value  salvage_value,
         bk.recoverable_cost recoverable_cost,
         bk.adjusted_cost  adjusted_cost,
         bk.adjusted_recoverable_cost adjusted_recoverable_cost,
         bk.period_counter_fully_retired fully_retired_flag,
         bk.period_counter_fully_reserved fully_reserved_flag,
         bk.eofy_reserve    bk_eofy_reserve,
         bk.eofy_adj_cost  eofy_adj_cost,
         ds.period_counter ds_period_counter,
         ds.deprn_reserve  ds_deprn_reserve,
         ds.ytd_deprn      ds_ytd_deprn,
         ds.bonus_deprn_reserve ds_bonus_deprn_reserve,
         ds.bonus_ytd_deprn ds_bonus_ytd_deprn,
         temp.deprn_reserve temp_deprn_reserve,
         temp.ytd_deprn     temp_ytd_deprn,
         temp.bonus_deprn_reserve temp_bonus_deprn_reserve,
         temp.bonus_ytd_deprn temp_bonus_ytd_deprn,
         temp.prior_year_reserve temp_prior_year_reserve,
         temp.eofy_recoverable_cost temp_eofy_recoverable_cost,
         temp.eop_recoverable_cost temp_eop_recoverable_cost,
         temp.eofy_salvage_value temp_eofy_salvage_value,
         temp.eop_salvage_value  temp_eop_salvage_value
    from fa_mc_books bk,
         fa_mc_deprn_summary ds,
         fa_track_members temp
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_group_asset_id
     and bk.date_ineffective is null
     and bk.set_of_books_id =h_set_of_books_id
     and ds.book_type_code = bk.book_type_code
     and ds.asset_id = bk.asset_id
--     and ds.period_counter = h_period_counter - 1
     and (ds.period_counter =
          (select max(ds1.period_counter)
             from fa_mc_deprn_summary ds1
            where ds1.book_type_code=h_book_type_code
              and ds1.asset_id=bk.asset_id
              and ds1.set_of_books_id = h_set_of_books_id
              and ds1.period_counter <= h_period_counter - 1)
         or
          ds.period_counter = nvl(bk.period_counter_fully_reserved,-99))
     and ds.set_of_books_id = h_set_of_books_id
     and temp.member_asset_id (+) = bk.asset_id
     and temp.period_counter (+) = h_period_counter
     and temp.fiscal_year (+) = h_fiscal_year
     and nvl(temp.set_of_books_id (+),-99) = nvl(h_set_of_books_id,-99);

--* New Adjusted Cost to call Deprn Basis Rule
cursor CURRENT_ADJ_COST is
  select temp.cost,
         temp.salvage_value,
         temp.recoverable_cost,
         temp.adjusted_cost,
         temp.adjusted_recoverable_cost
    from fa_track_members temp
   where temp.group_asset_id = h_group_asset_id
     and temp.member_asset_id = h_member_asset_id
     and temp.period_counter = h_period_counter
     and nvl(temp.set_of_books_id,-99) = nvl(h_set_of_books_id,-99);

--* Check if current period table exists or not
cursor CHECK_CURRENT_TABLE is
 select 1
   from fa_track_members
  where group_asset_id = h_group_asset_id
    and member_asset_id = h_member_asset_id
    and period_counter = h_period_counter
    and fiscal_year = h_fiscal_year
    and nvl(set_of_books_id,-99) = nvl(h_set_of_books_id,-99);

--* For ADJUSTMENT table
--* Cursor for FA_ADJUSTMENTS
cursor FA_ADJ_EXPENSE is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_adjustments adj,
          fa_transaction_headers th1,
          fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = h_member_asset_id;

cursor FA_ADJ_EXPENSE_MEM is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.period_counter_adjusted = h_period_counter;

--* Cursor for FA_ADJUSTMENTS
cursor FA_ADJ_EXPENSE_MRC is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_mc_adjustments adj,
          fa_transaction_headers th1,
          fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and adj.set_of_books_id = h_set_of_books_id
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = h_member_asset_id;

cursor FA_ADJ_EXPENSE_MEM_MRC is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_mc_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.set_of_books_id = h_set_of_books_id
      and adj.period_counter_adjusted = h_period_counter;

--* Cursor for Delta
cursor GET_DELTA is
           select new_bk.cost - old_bk.cost,
                  decode(new_bk.salvage_type,'AMT',
                         decode(old_bk.salvage_type,'AMT', new_bk.salvage_value - old_bk.salvage_value,
                                                           new_bk.salvage_value)),
                  decode(new_bk.deprn_limit_type,'AMT',
                         decode(old_bk.deprn_limit_type,'AMT',
                                new_bk.adjusted_recoverable_cost - old_bk.adjusted_recoverable_cost,
                                new_bk.adjusted_recoverable_cost)),
                  new_bk.salvage_type,
                  decode(new_bk.salvage_type,'PCT',new_bk.percent_salvage_value),
                  new_bk.deprn_limit_type,
                  decode(new_bk.deprn_limit_type,'PCT',new_bk.allowed_deprn_limit)
             from fa_books new_bk,
                  fa_books old_bk
            where new_bk.book_type_code = p_group_rule_in.book_type_code
              and new_bk.asset_id = h_member_asset_id
              and new_bk.transaction_header_id_in = h_adj_member_trans_header_id
              and old_bk.book_type_code = new_bk.book_type_code
              and old_bk.asset_id = new_bk.asset_id
              and old_bk.transaction_header_id_out = new_bk.transaction_header_id_in;

cursor GET_DELTA_MRC is
           select new_bk.cost - old_bk.cost,
                  decode(new_bk.salvage_type,'AMT',
                         decode(old_bk.salvage_type,'AMT', new_bk.salvage_value - old_bk.salvage_value,
                                                           new_bk.salvage_value)),
                  decode(new_bk.deprn_limit_type,'AMT',
                         decode(old_bk.deprn_limit_type,'AMT',
                                new_bk.adjusted_recoverable_cost - old_bk.adjusted_recoverable_cost,
                                new_bk.adjusted_recoverable_cost)),
                  new_bk.salvage_type,
                  decode(new_bk.salvage_type,'PCT',new_bk.percent_salvage_value),
                  new_bk.deprn_limit_type,
                  decode(new_bk.deprn_limit_type,'PCT',new_bk.allowed_deprn_limit)
             from fa_mc_books new_bk,
                  fa_mc_books old_bk
            where new_bk.book_type_code = p_group_rule_in.book_type_code
              and new_bk.asset_id = h_member_asset_id
              and new_bk.transaction_header_id_in = h_adj_member_trans_header_id
              and new_bk.set_of_books_id = h_set_of_books_id
              and old_bk.book_type_code = new_bk.book_type_code
              and old_bk.asset_id = new_bk.asset_id
              and old_bk.transaction_header_id_out = new_bk.transaction_header_id_in
              and old_bk.set_of_books_id = h_set_of_books_id;

--* Cursor for FA_ADJUSTMENTS (Reserve Adjustments)
/*
cursor FA_ADJ_RESERVE is
   select sum(decode(adj.adjustment_type,'RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          nvl(sum(decode(adj.adjustment_type,'PROCEEDS CLR',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),0) -
          nvl(sum(decode(adj.adjustment_type,'REMOVALCOST CLR',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),0)
     from fa_adjustments adj,
          fa_transaction_headers th1,
          fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = h_member_asset_id
      and th2.transaction_header_id <> nvl(h_adj_member_trans_header_id,0);
*/
-- ENERGY
-- ENERGY
cursor FA_ADJ_RESERVE is
   select sum(decode(adj.adjustment_type,'RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          nvl(sum(decode(adj.adjustment_type,'PROCEEDS CLR',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),0) -
          nvl(sum(decode(adj.adjustment_type,'REMOVALCOST CLR',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),0)
     from fa_adjustments adj,
          fa_transaction_headers th1
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_member_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and th1.asset_id = adj.asset_id
      and th1.transaction_header_id <> nvl(h_adj_member_trans_header_id,0);
-- ENERGY
-- ENERGY


cursor FA_ADJ_RESERVE_MEM is
   select sum(decode(adj.adjustment_type,'RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          nvl(sum(decode(adj.adjustment_type,'PROCEEDS CLR',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),0) -
          nvl(sum(decode(adj.adjustment_type,'REMOVALCOST CLR',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),0)
     from fa_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.period_counter_adjusted = h_period_counter
      and nvl(adj.track_member_flag, 'N') = 'N';   -- ENERGY

--* Cursor for FA_ADJUSTMENTS
cursor FA_ADJ_RESERVE_MRC is
  select /*+ ORDERED
                  Index(TH2 FA_TRANSACTION_HEADERS_N1)
                  INDEX(TH1 FA_TRANSACTION_HEADERS_N7)
                  INDEX(ADJ FA_ADJUSTMENTS_U1)*/
          sum(decode(adj.adjustment_type,'RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          nvl(sum(decode(adj.adjustment_type,'PROCEEDS CLR',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),0) +
          nvl(sum(decode(adj.adjustment_type,'REMOVALCOST CLR',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),0)
     from fa_transaction_headers th2,
          fa_transaction_headers th1,
          fa_mc_adjustments adj
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = h_period_counter
      and adj.set_of_books_id = h_set_of_books_id
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.asset_id = h_member_asset_id
      and th2.transaction_header_id <> nvl(h_adj_member_trans_header_id,0);

cursor FA_ADJ_RESERVE_MEM_MRC is
   select sum(decode(adj.adjustment_type,'RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS RESERVE',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),
          nvl(sum(decode(adj.adjustment_type,'PROCEEDS CLR',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),0) +
          nvl(sum(decode(adj.adjustment_type,'REMOVALCOST CLR',
                     decode(adj.debit_credit_flag,
                     'CR',adj.adjustment_amount,
                     'DR', -1 * adj.adjustment_amount))),0)
     from fa_mc_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.set_of_books_id = h_set_of_books_id
      and adj.period_counter_adjusted = h_period_counter
      and nvl(adj.track_member_flag, 'N') = 'N';   -- ENERGY

cursor GET_TRANS_ASSET_TYPE is
   select ad.asset_type
     from fa_transaction_headers th,
          fa_additions_b ad
    where th.transaction_header_id = p_group_rule_in.adj_transaction_header_id
      and ad.asset_id = th.asset_id;

cursor GET_NEW_BOOKS is
   select new_bk.cost,
          new_bk.salvage_value,
          new_bk.adjusted_recoverable_cost,
          new_bk.salvage_type,
          new_bk.percent_salvage_value,
          new_bk.deprn_limit_type,
          new_bk.allowed_deprn_limit
     from fa_books new_bk
    where new_bk.book_type_code = p_group_rule_in.book_type_code
      and new_bk.asset_id = h_member_asset_id
      and new_bk.transaction_header_id_in = h_adj_member_trans_header_id;

cursor GET_NEW_BOOKS_MRC is
   select new_bk.cost,
          new_bk.salvage_value,
          new_bk.adjusted_recoverable_cost,
          new_bk.salvage_type,
          new_bk.percent_salvage_value,
          new_bk.deprn_limit_type,
          new_bk.allowed_deprn_limit
     from fa_mc_books new_bk
    where new_bk.book_type_code = p_group_rule_in.book_type_code
      and new_bk.asset_id = h_member_asset_id
      and new_bk.transaction_header_id_in = h_adj_member_trans_header_id
      and new_bk.set_of_books_id = h_set_of_books_id;

cursor GET_EXCLUDE_FULLY_RSV_FLAG is
  select exclude_fully_rsv_flag
    from fa_books
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and date_ineffective is null;

cursor GET_EXCLUDE_FULLY_RSV_FLAG_MRC is
  select exclude_fully_rsv_flag
    from fa_mc_books
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and date_ineffective is null
     and set_of_books_id = h_set_of_books_id;

begin

if p_group_rule_in.tracking_method = 'ALLOCATE' and nvl(l_process_deprn_for_member,'YES') = 'YES' then

if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, '+++ Update Depreciable Basis for member assets +++', '+++', p_log_level_rec => p_log_level_rec);
end if;

-- Initialization
h_book_type_code := p_group_rule_in.book_type_code;
h_group_asset_id := p_group_rule_in.asset_id;
h_period_counter := p_group_rule_in.period_counter;
h_fiscal_year    := p_group_rule_in.fiscal_year;
h_cur_period_counter := FA_CACHE_PKG.fazcbc_record.last_period_counter + 1;
h_set_of_books_id := p_group_rule_in.set_of_books_id;

/* Apply MRC related feature */
if p_group_rule_in.mrc_sob_type_code <> 'R' then

  open GET_EXCLUDE_FULLY_RSV_FLAG;
  fetch GET_EXCLUDE_FULLY_RSV_FLAG into h_exclude_fully_rsv_flag;
  close GET_EXCLUDE_FULLY_RSV_FLAG;
else

  open GET_EXCLUDE_FULLY_RSV_FLAG_MRC;
  fetch GET_EXCLUDE_FULLY_RSV_FLAG_MRC into h_exclude_fully_rsv_flag;
  close GET_EXCLUDE_FULLY_RSV_FLAG_MRC;
end if;

if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'h_sob_id:group_asset_id:period_counter:fiscal_year:cur_period_num:mode',
                           h_set_of_books_id||':'||h_group_asset_id||':'||h_period_counter||':'||h_fiscal_year||':'||h_cur_period_counter||':'||p_mode, p_log_level_rec => p_log_level_rec);
end if;

-- If this is called during Adjustment and this is oldest period to be calculated,
-- Query necessary data from table and insert those into FA_TRACKING_TEMP

if nvl(P_mode,'DEPRECIATION') = 'ADJUSTMENT' then

      if not p_track_member_table.exists(1) then
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '++ populate previous rows call ++', 'ADJUSTMENT MDOE', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'h_period_counter', h_period_counter, p_log_level_rec => p_log_level_rec);
        end if;

        l_transaction_header_id := p_group_rule_in.adj_mem_transaction_header_id;

        if p_group_rule_in.adj_mem_transaction_header_id is null and
           p_group_rule_in.adj_transaction_header_id is not null then

          open GET_TRANS_ASSET_TYPE;
          fetch GET_TRANS_ASSET_TYPE into l_adj_asset_type;
          close GET_TRANS_ASSET_TYPE;

          if l_adj_asset_type = 'CAPITALIZED' then
            l_transaction_header_id := p_group_rule_in.adj_transaction_header_id;
          end if;
        end if;

        if not populate_previous_rows(p_book_type_code => h_book_type_code,
                                      p_group_asset_id => h_group_asset_id,
                                      p_period_counter => h_period_counter,
                                      p_fiscal_year    => h_fiscal_year,
                                      p_transaction_header_id => l_transaction_header_id,
                                      p_allocate_to_fully_ret_flag => p_group_rule_in.allocate_to_fully_ret_flag,
                                      p_allocate_to_fully_rsv_flag => p_group_rule_in.allocate_to_fully_rsv_flag,
                                      p_mrc_sob_type_code => p_group_rule_in.mrc_sob_type_code,
                                      p_set_of_books_id=>h_set_of_books_id,
                      p_log_level_rec => p_log_level_rec) then
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ populate_member_amounts_table ++', 'Returned FALSE', p_log_level_rec => p_log_level_rec);
          end if;
          raise upd_deprn_err;
        end if;
      end if; -- End of preparion for Adjustment mode

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++ populate_previous_rows done ++', '+++', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'group_in.adj_transaction_header_id',
                                                          p_group_rule_in.adj_transaction_header_id, p_log_level_rec => p_log_level_rec);
      end if;

      -- Before starting to process member deprn basis update,
      -- check the transaction if Transaction Header ID is not Null
      -- If the transaction is made as Addition, dummy row will be inserted
      -- into tracking table

      h_adj_member_trans_header_id := NULL;
      if p_group_rule_in.adj_mem_transaction_header_id is not NULL then
          -- In this period, come transaction has occurred.
          h_adj_member_trans_header_id := p_group_rule_in.adj_mem_transaction_header_id;

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '++ Logic for member header id is not NULL ++', '+++', p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'h_adj_member_trans_header_id', h_adj_member_trans_header_id, p_log_level_rec => p_log_level_rec);
          end if;

          select asset_id,transaction_type_code,transaction_key,nvl(amortization_start_date,transaction_date_entered)
            into h_asset_id,h_transaction_type_code,h_transaction_key,l_transaction_date_entered
            from fa_transaction_headers
           where transaction_header_id = h_adj_member_trans_header_id;

          h_period_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

          select fiscal_year_name, deprn_calendar
            into h_fiscal_year_name,h_calendar_type
            from fa_book_controls
           where book_type_code=h_book_type_code;

          select fiscal_year into h_trans_fiscal_year
            from fa_fiscal_year
           where fiscal_year_name = h_fiscal_year_name
             and start_date <= l_transaction_date_entered
             and end_date >= l_transaction_date_entered;

          select period_num into h_trans_period_num
            from fa_calendar_periods
           where calendar_type = h_calendar_type
             and start_date <= l_transaction_date_entered
             and end_date >= l_transaction_date_entered;

          h_trans_period_counter := h_trans_fiscal_year*h_period_per_fiscal_year+h_trans_period_num;

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'h_asset_id', h_asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_transaction_type_code:h_transaction_key', h_transaction_type_code||':'||h_transaction_key, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_trans_period_counter', h_trans_period_counter, p_log_level_rec => p_log_level_rec);
          end if;
      end if;

    if p_group_rule_in.event_type <> 'AFTER_DEPRN' then

      For i in 1 .. p_track_member_table.count loop

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1): Loop indicator +++', i);
           fa_debug_pkg.add(l_calling_fn, 'Loop until (exit number)', p_track_member_table.count);
        end if;

        l_track_member := p_track_member_table(i);

        if  nvl(l_track_member.group_Asset_id, -99) = h_group_asset_id and
            l_track_member.period_counter = nvl(h_trans_period_counter,-99) and
            nvl(l_track_member.set_of_books_id,-99) = nvl(h_set_of_books_id,-99) and
          ((nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(l_track_member.fully_retired_flag,'N') = 'N' and nvl(l_track_member.fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(l_track_member.fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'Y' and
            nvl(l_track_member.fully_retired_flag,'N') = 'N')
          or
           (nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'Y'))

        then

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'member_table('||i||').member_asset_id:retired_flag:reserved_flag:period_counter',
                                          p_track_member_table(i).member_asset_id||':'||p_track_member_table(i).fully_retired_flag||':'||
                                          p_track_member_table(i).fully_reserved_flag||':'||p_track_member_table(i).period_counter);
        end if;

        h_member_asset_id := l_track_member.member_asset_id;
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ In Loop (2) + h_member_asset_id', h_member_asset_id);
        end if;

        h_adj_eofy_reserve := 0;

        -- Get the delta for this transaction
        if nvl(h_asset_id,-99) = h_member_asset_id
--           and nvl(h_transaction_type_code,'NULL') <> 'ADDITION'
--           and nvl(h_transaction_type_code,'NULL') <> 'ADDITION/VOID' then
           and h_period_counter = h_trans_period_counter then -- This transaction is for this member

           -- Query old fa_books and new fa_books to calculate delta
          if p_group_rule_in.mrc_sob_type_code <> 'R' then
            open GET_DELTA;
            fetch GET_DELTA into h_adj_cost,h_adj_salvage_value,h_adj_adjusted_rec_cost,
                                 h_adj_salvage_type,h_adj_percent_salvage,
                                 h_adj_limit_type,h_adj_percent_limit;
            if GET_DELTA%NOTFOUND then
              open GET_NEW_BOOKS;
              fetch GET_NEW_BOOKS into h_adj_cost,h_adj_salvage_value,h_adj_adjusted_rec_cost,
                                       h_adj_salvage_type,h_adj_percent_salvage,
                                       h_adj_limit_type,h_adj_percent_limit;
              if GET_NEW_BOOKS%NOTFOUND then
                h_adj_cost := 0;
                h_adj_salvage_value := 0;
                h_adj_adjusted_rec_cost := 0;
                h_adj_salvage_type := 'NULL';
                h_adj_percent_salvage := 0;
                h_adj_limit_type := 'NULL';
                h_adj_percent_limit := 0;
              end if;
              close GET_NEW_BOOKS;
            end if;
            close GET_DELTA;
          else
            open GET_DELTA_MRC;
            fetch GET_DELTA_MRC into h_adj_cost,h_adj_salvage_value,h_adj_adjusted_rec_cost,
                                     h_adj_salvage_type,h_adj_percent_salvage,
                                     h_adj_limit_type,h_adj_percent_limit;

            if GET_DELTA_MRC%NOTFOUND then
              open GET_NEW_BOOKS_MRC;
              fetch GET_NEW_BOOKS_MRC into h_adj_cost,h_adj_salvage_value,h_adj_adjusted_rec_cost,
                                           h_adj_salvage_type,h_adj_percent_salvage,
                                           h_adj_limit_type,h_adj_percent_limit;

              if GET_NEW_BOOKS_MRC%NOTFOUND then
                h_adj_cost := 0;
                h_adj_salvage_value := 0;
                h_adj_adjusted_rec_cost := 0;
                h_adj_salvage_type := 'NULL';
                h_adj_percent_salvage := 0;
                h_adj_limit_type := 'NULL';
                h_adj_percent_limit := 0;
              end if;
              close GET_NEW_BOOKS_MRC;
            end if;
            close GET_DELTA_MRC;
          end if;

          if nvl(h_asset_id,-99) = h_member_asset_id
           and h_period_counter = h_trans_period_counter
           and nvl(h_transaction_type_code,'NULL') in ('PARTIAL RETIREMENT','FULL RETIREMENT') then

           -- Query fa_retirements for entered eofy_reserve
            if p_group_rule_in.mrc_sob_type_code <> 'R' then

              select recognize_gain_loss,nvl(eofy_reserve,0),(-1)*nvl(reserve_retired,0)
                into h_recognize_gain_loss,h_adj_eofy_reserve,h_reserve_retired
                from fa_retirements
               where transaction_header_id_in = h_adj_member_trans_header_id;
            else

              select recognize_gain_loss,nvl(eofy_reserve,0),(-1)*nvl(reserve_retired,0)
                into h_recognize_gain_loss,h_adj_eofy_reserve,h_reserve_retired
                from fa_mc_retirements
               where transaction_header_id_in = h_adj_member_trans_header_id
                 and set_of_books_id = h_set_of_books_id;
            end if;

            if nvl(h_recognize_gain_loss,'NO') = 'NO' then
              h_adj_eofy_reserve := 0;
            end if;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'h_adj_eofy_reserve', h_adj_eofy_reserve, p_log_level_rec => p_log_level_rec);
            end if;
          end if;
        else  -- This transaction is not for this transaction
          h_adj_cost := 0;
          h_adj_salvage_value := 0;
          h_adj_adjusted_rec_cost := 0;
          h_adj_salvage_type := 'NULL';
          h_adj_percent_salvage := 0;
          h_adj_limit_type := 'NULL';
          h_adj_percent_limit := 0;
        end if;

-- get reserve/expense adjustments
        if p_group_rule_in.mrc_sob_type_code <> 'R' then
          open FA_ADJ_RESERVE;
          fetch FA_ADJ_RESERVE into h_rsv_adjustment,h_bonus_rsv_adjustment,h_net_proceeds;
          close FA_ADJ_RESERVE;

          open FA_ADJ_RESERVE_MEM;
          fetch FA_ADJ_RESERVE_MEM into h_rsv_adjustment_mem,h_bonus_rsv_adj_mem,h_net_proceeds_mem;
          close FA_ADJ_RESERVE_MEM;
        else
          open FA_ADJ_RESERVE_MRC;
          fetch FA_ADJ_RESERVE_MRC into h_rsv_adjustment,h_bonus_rsv_adjustment,h_net_proceeds;
          close FA_ADJ_RESERVE_MRC;

          open FA_ADJ_RESERVE_MEM_MRC;
          fetch FA_ADJ_RESERVE_MEM_MRC into h_rsv_adjustment_mem,h_bonus_rsv_adj_mem,h_net_proceeds_mem;
          close FA_ADJ_RESERVE_MEM_MRC;
        end if;

      -- Added member level catchup and reserve adjustment
        h_catchup_expense := nvl(h_catchup_expense,0) + nvl(h_catchup_expense_mem,0);
        h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0) + nvl(h_bonus_catchup_mem,0);
        h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_rsv_adjustment_mem,0) + nvl(h_reserve_retired,0);
        h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_rsv_adj_mem,0);

        h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_catchup_expense,0);
        h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_catchup_expense,0);
        h_net_proceeds := nvl(h_net_proceeds,0);
        h_catchup_expense := nvl(h_catchup_expense,0);
        h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0);

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'h_catchup_expense:h_bonus_catchup_expense', h_catchup_expense||':'||h_bonus_catchup_expense, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_rsv_adjustment:h_bonus_rsv_adjustment', h_rsv_adjustment||':'||h_bonus_rsv_adjustment, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_net_proceeds', h_net_proceeds, p_log_level_rec => p_log_level_rec);
        end if;

        h_current_cost := l_track_member.cost;
        h_current_salvage_value := l_track_member.salvage_value;
        h_current_recoverable_cost := l_track_member.recoverable_cost;
        h_current_adjusted_cost := l_track_member.adjusted_cost;
        h_current_adj_recoverable_cost := l_track_member.adjusted_recoverable_cost;

        -- Update current cost
        if nvl(h_asset_id,-99) = h_member_asset_id
           and nvl(h_transaction_type_code,'NULL') in ('FULL RETIREMENT','PARTIAL RETIREMENT') then
          if nvl(h_recognize_gain_loss,'NO') = 'YES' then
            h_current_cost := h_current_cost + h_adj_cost;
          else
            h_current_cost := h_current_cost;
          end if;
        else
          h_current_cost := h_current_cost + h_adj_cost;
        end if;

        if h_adj_salvage_type = 'PCT' then
          h_current_salvage_value := h_current_cost * h_adj_percent_salvage;
        else
          h_current_salvage_value := h_current_salvage_value + h_adj_salvage_value;
        end if;

        h_current_recoverable_cost := h_current_cost - h_current_salvage_value;

        if h_adj_limit_type = 'PCT' then
          h_current_adj_recoverable_cost := h_current_cost * h_adj_percent_limit;
        else
          h_current_adj_recoverable_cost := h_current_adj_recoverable_cost + h_adj_adjusted_rec_cost;
        end if;

        if l_track_member.cost = 0 then -- fully retired now
           x_fully_retired_flag := 'Y';
        else
           x_fully_retired_flag := 'N';
        end if;

        -- Set the input parameters for Deprn Basis Rule
        fa_rule_in := p_group_rule_in;

        fa_rule_in.group_asset_id := h_group_asset_id;
        fa_rule_in.asset_id := l_track_member.member_asset_id;

        if nvl(h_asset_id,-99) = h_member_asset_id
           and nvl(h_transaction_type_code,'NULL') in ('FULL RETIREMENT','PARTIAL RETIREMENT') then
          fa_rule_in.event_type := 'RETIREMENT';
          fa_rule_in.adjustment_amount := (-1)*fa_rule_in.adjustment_amount;
        end if;

        -- Get Asset type
        select asset_type into x_asset_type
          from fa_additions_b
         where asset_id = l_track_member.member_asset_id;

        fa_rule_in.asset_type := x_asset_type;
        if nvl(h_asset_id,-99) <> l_track_member.member_asset_id then
          fa_rule_in.adjustment_amount := 0;
        end if;
        fa_rule_in.cost := h_current_cost;
        fa_rule_in.salvage_value := h_current_salvage_value;
        fa_rule_in.recoverable_cost := h_current_recoverable_cost;
        fa_rule_in.adjusted_cost := l_track_member.adjusted_cost;
        fa_rule_in.current_total_rsv := l_track_member.deprn_reserve + h_rsv_adjustment;
        fa_rule_in.current_rsv := (l_track_member.deprn_reserve + h_rsv_adjustment)
                                 - (l_track_member.bonus_deprn_reserve + h_bonus_rsv_adjustment);
        fa_rule_in.current_total_ytd := l_track_member.ytd_deprn + h_catchup_expense;
        fa_rule_in.current_ytd := (l_track_member.ytd_deprn + h_catchup_expense)
                                 - (l_track_member.bonus_ytd_deprn + h_bonus_catchup_expense);
        fa_rule_in.old_adjusted_cost := h_current_adjusted_cost;

        -- Get eofy, eop amounts
        if not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
          (p_asset_id =>       fa_rule_in.asset_id,
           p_book_type_code => fa_rule_in.book_type_code,
           p_fiscal_year =>    fa_rule_in.fiscal_year,
           p_period_num =>     fa_rule_in.period_num,
           p_recoverable_cost => fa_rule_in.recoverable_cost,
           p_salvage_value => fa_rule_in.salvage_value,
           p_transaction_date_entered => fa_rule_in.transaction_date_entered,
           p_mrc_sob_type_code => p_group_rule_in.mrc_sob_type_code,
           p_set_of_books_id => p_group_rule_in.set_of_books_id,
           x_eofy_recoverable_cost => h_new_eofy_recoverable_cost,
           x_eofy_salvage_value => h_new_eofy_salvage_value,
           x_eop_recoverable_cost => h_new_eop_recoverable_cost,
           x_eop_salvage_value => h_new_eop_salvage_value, p_log_level_rec => p_log_level_rec) then
         raise upd_deprn_err;
        end if;

        fa_rule_in.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
        fa_rule_in.eop_recoverable_cost := h_new_eop_recoverable_cost;
        fa_rule_in.eofy_salvage_value := h_new_eofy_salvage_value;
        fa_rule_in.eop_salvage_value := h_new_eop_salvage_value;
        fa_rule_in.eofy_reserve := l_track_member.eofy_reserve - nvl(h_adj_eofy_reserve,0);

        l_track_member.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
        l_track_member.eop_recoverable_cost := h_new_eop_recoverable_cost;
        l_track_member.eofy_salvage_value := h_new_eofy_salvage_value;
        l_track_member.eop_salvage_value := h_new_eop_salvage_value;

        fa_rule_in.apply_reduction_flag := nvl(p_apply_reduction_flag,'N');

        if (p_log_level_rec.statement_level) then
          if not display_debug_message(fa_rule_in => fa_rule_in,
                                       p_calling_fn => l_calling_fn,
                                       p_log_level_rec => p_log_level_rec) then
            fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
          end if;
        end if;

        -- Call Deprn Basis Rule for this transaction or period
        if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                                rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
           raise upd_deprn_err;
        end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost',
                                                                   fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_current_cost', h_current_cost, p_log_level_rec => p_log_level_rec);
        end if;

        -- delete from existing table
        delete_track_index(p_track_member_table(i).period_counter, p_track_member_table(i).member_asset_id,
                        p_track_member_table(i).group_asset_id,p_track_member_table(i).set_of_books_id, p_log_level_rec);

        p_track_member_table(i).group_asset_id := h_group_asset_id;
        p_track_member_table(i).member_asset_id := h_member_asset_id;
        p_track_member_table(i).period_counter := h_period_counter;
        p_track_member_table(i).fiscal_year := h_fiscal_year;
        p_track_member_table(i).set_of_books_id := h_set_of_books_id;
        p_track_member_table(i).cost := h_current_cost;
        p_track_member_table(i).adjusted_cost := fa_rule_out.new_adjusted_cost;
        p_track_member_table(i).salvage_value := h_current_salvage_value;
        p_track_member_table(i).recoverable_cost := h_current_recoverable_cost;
        p_track_member_table(i).adjusted_recoverable_cost := h_current_adj_recoverable_cost;
        p_track_member_table(i).eofy_reserve := l_track_member.eofy_reserve - nvl(h_adj_eofy_reserve,0);
        p_track_member_table(i).eofy_recoverable_cost := l_track_member.eofy_recoverable_cost;
        p_track_member_table(i).eop_recoverable_cost := l_track_member.eop_recoverable_cost;
        p_track_member_table(i).eofy_salvage_value := l_track_member.eofy_salvage_value;
        p_track_member_table(i).eop_salvage_value := l_track_member.eop_salvage_value;

        /* Populate index table */
        put_track_index(h_period_counter, h_member_asset_id,h_group_asset_id,h_set_of_books_id,i, p_log_level_rec);

        For j in 1 .. p_track_member_eofy_table.COUNT loop
         if p_track_member_eofy_table(j).group_asset_id = h_group_asset_id and
            p_track_member_eofy_table(j).member_asset_id = h_member_asset_id and
            nvl(p_track_member_eofy_table(j).set_of_books_id, -99) = nvl(h_set_of_books_id, -99) then
           p_track_member_eofy_table(j).cost := h_current_cost;
           p_track_member_eofy_table(j).salvage_value := h_current_salvage_value;
           p_track_member_eofy_table(j).recoverable_cost := h_current_recoverable_cost;
           p_track_member_eofy_table(j).adjusted_cost := fa_rule_out.new_adjusted_cost;
           p_track_member_eofy_table(j).eofy_reserve := p_track_member_table(i).eofy_reserve;
           exit;
         end if;
        END LOOP;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ Finally updated p_track_member_table ', i, p_log_level_rec => p_log_level_rec);
           if not display_debug_message2(i => i, p_calling_fn => l_calling_fn, p_log_level_rec=> p_log_level_rec) then
             fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
           end if;
        end if;

       end if; -- allocation type
      end loop;

    else -- In case of AFTER_DEPRN with ADJUSTMENT mode

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '+++ In Loop (0) for AFTER_DEPRN ++ Indicator ++', 'Just before loop');
         fa_debug_pkg.add(l_calling_fn, 'h_group_asset_id:h_period_counter', h_group_asset_id||':'||h_period_counter, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'period_Counter to be updated', (h_period_counter + 1));
      end if;

      For i in 1 .. p_track_member_table.count loop

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) for AFTER_DEPRN ++ Indicator ++', i);
           fa_debug_pkg.add(l_calling_fn, 'Loop until (exit number)', p_track_member_table.count);
        end if;

        l_track_member := p_track_member_table(i);
        if  nvl(l_track_member.group_asset_id, -99) = h_group_asset_id and
            l_track_member.period_counter = h_period_counter + 1 and
            nvl(l_track_member.set_of_books_id,-99) = nvl(h_set_of_books_id,-99) and
          ((nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(l_track_member.fully_retired_flag,'N') = 'N' and nvl(l_track_member.fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(l_track_member.fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'Y' and
            nvl(l_track_member.fully_retired_flag,'N') = 'N')
          or
           (nvl(p_group_rule_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_group_rule_in.allocate_to_fully_rsv_flag,'N') = 'Y'))

        then

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'p_track_member_table('||i||').member_asset_id:retired_flag:reserved_flag:period_counter',
                                                        p_track_member_table(i).member_asset_id||':'||p_track_member_table(i).fully_retired_flag||':'||
                                                        p_track_member_table(i).fully_reserved_flag||':'||p_track_member_table(i).period_counter);
        end if;

        h_member_asset_id := l_track_member.member_asset_id;
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
        end if;

        h_current_cost := l_track_member.cost;
        h_current_salvage_value := l_track_member.salvage_value;
        h_current_recoverable_cost := l_track_member.recoverable_cost;
        h_current_adjusted_cost := l_track_member.adjusted_cost;
        h_current_adj_recoverable_cost := l_track_member.adjusted_recoverable_cost;

        if l_track_member.cost = 0 then -- fully retired now
           x_fully_retired_flag := 'Y';
        else
           x_fully_retired_flag := 'N';
        end if;

        -- Set the input parameters for Deprn Basis Rule
        fa_rule_in := p_group_rule_in;

        fa_rule_in.group_asset_id := h_group_asset_id;
        fa_rule_in.asset_id := l_track_member.member_asset_id;

        -- Get Asset type
        select asset_type into x_asset_type
          from fa_additions_b
         where asset_id = h_member_asset_id;

-- get reserve/expense adjustments
        if p_group_rule_in.mrc_sob_type_code <> 'R' then
          open FA_ADJ_RESERVE;
          fetch FA_ADJ_RESERVE into h_rsv_adjustment,h_bonus_rsv_adjustment,h_net_proceeds;
          close FA_ADJ_RESERVE;


          open FA_ADJ_RESERVE_MEM;
          fetch FA_ADJ_RESERVE_MEM into h_rsv_adjustment_mem,h_bonus_rsv_adj_mem,h_net_proceeds_mem;
          close FA_ADJ_RESERVE_MEM;

        else
          open FA_ADJ_RESERVE_MRC;
          fetch FA_ADJ_RESERVE_MRC into h_rsv_adjustment,h_bonus_rsv_adjustment,h_net_proceeds;
          close FA_ADJ_RESERVE_MRC;

          open FA_ADJ_RESERVE_MEM_MRC;
          fetch FA_ADJ_RESERVE_MEM_MRC into h_rsv_adjustment_mem,h_bonus_rsv_adj_mem,h_net_proceeds_mem;
          close FA_ADJ_RESERVE_MEM_MRC;

        end if;

      -- Added member level catchup and reserve adjustment
        h_catchup_expense := nvl(h_catchup_expense,0) + nvl(h_catchup_expense_mem,0);
        h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0) + nvl(h_bonus_catchup_mem,0);
        h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_rsv_adjustment_mem,0);
        h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_rsv_adj_mem,0);

        h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_catchup_expense,0);
        h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_catchup_expense,0);
        h_net_proceeds := nvl(h_net_proceeds,0);
        h_catchup_expense := nvl(h_catchup_expense,0);
        h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0);

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'h_catchup_expense:h_bonus_catchup_expense', h_catchup_expense||':'||h_bonus_catchup_expense, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_rsv_adjustment:h_bonus_rsv_adjustment', h_rsv_adjustment||':'||h_bonus_rsv_adjustment, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_net_proceeds', h_net_proceeds, p_log_level_rec => p_log_level_rec);
        end if;

        fa_rule_in.asset_type := x_asset_type;
        fa_rule_in.adjustment_amount := nvl(x_added_cost,0) + nvl(x_retired_cost,0);
        fa_rule_in.cost := h_current_cost;
        fa_rule_in.salvage_value := h_current_salvage_value;
        fa_rule_in.recoverable_cost := h_current_recoverable_cost;
        fa_rule_in.adjusted_cost := l_track_member.adjusted_cost;
        fa_rule_in.current_total_rsv := l_track_member.deprn_reserve + h_rsv_adjustment;
        fa_rule_in.current_rsv := (l_track_member.deprn_reserve + h_rsv_adjustment)
                                 - (l_track_member.bonus_deprn_reserve + h_bonus_rsv_adjustment);
        fa_rule_in.current_total_ytd := l_track_member.ytd_deprn + h_catchup_expense;
        fa_rule_in.current_ytd := (l_track_member.ytd_deprn + h_catchup_expense)
                                 - (l_track_member.bonus_ytd_deprn + h_bonus_catchup_expense);
        fa_rule_in.old_adjusted_cost := h_current_adjusted_cost;

        fa_rule_in.eofy_reserve := l_track_member.eofy_reserve;

        -- Get eofy, eop amounts
        if not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
          (p_asset_id =>       fa_rule_in.asset_id,
           p_book_type_code => fa_rule_in.book_type_code,
           p_fiscal_year =>    fa_rule_in.fiscal_year,
           p_period_num =>     fa_rule_in.period_num,
           p_recoverable_cost => fa_rule_in.recoverable_cost,
           p_salvage_value => fa_rule_in.salvage_value,
           p_transaction_date_entered => fa_rule_in.transaction_date_entered,
           p_mrc_sob_type_code => p_group_rule_in.mrc_sob_type_code,
           p_set_of_books_id =>  p_group_rule_in.set_of_books_id,
           x_eofy_recoverable_cost => h_new_eofy_recoverable_cost,
           x_eofy_salvage_value => h_new_eofy_salvage_value,
           x_eop_recoverable_cost => h_new_eop_recoverable_cost,
           x_eop_salvage_value => h_new_eop_salvage_value, p_log_level_rec => p_log_level_rec) then
         raise upd_deprn_err;

        end if;

        fa_rule_in.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
        fa_rule_in.eop_recoverable_cost := h_new_eop_recoverable_cost;
        fa_rule_in.eofy_salvage_value := h_new_eofy_salvage_value;
        fa_rule_in.eop_salvage_value := h_new_eop_salvage_value;

        fa_rule_in.apply_reduction_flag := nvl(p_apply_reduction_flag,'N');

        if (p_log_level_rec.statement_level) then
           if not display_debug_message(fa_rule_in => fa_rule_in,
                                        p_calling_fn => l_calling_fn,
                                        p_log_level_rec => p_log_level_rec) then
             fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
           end if;
        end if;

        -- Call Deprn Basis Rule for this transaction or period
        if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                                rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
           raise upd_deprn_err;
        end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost', fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_current_cost', h_current_cost, p_log_level_rec => p_log_level_rec);
        end if;

         -- Calculate EOFY_RESERVE as prior year reserve amount
         if nvl(fa_rule_in.eofy_flag,'N') = 'Y' then
           h_new_eofy_reserve := l_track_member.deprn_reserve;
         else
           h_new_eofy_reserve := l_track_member.eofy_reserve;
         end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'update_deprn:h_new_eofy_reserve', h_new_eofy_reserve, p_log_level_rec => p_log_level_rec);
        end if;

        p_track_member_table(i).adjusted_cost := fa_rule_out.new_adjusted_cost;
        p_track_member_table(i).eofy_reserve := h_new_eofy_reserve;

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '++ End of updating p_track_member_table after depreciation', i, p_log_level_rec => p_log_level_rec);
          if not display_debug_message2(i, l_calling_fn, p_log_level_rec) then
            fa_debug_pkg.add(l_calling_fn, 'display_debug_message2','returned error', p_log_level_rec => p_log_level_rec);
          end if;
        end if;

       end if; -- allocation type

      end loop;

      --* Following logic is prepared for exclude_salvage_value in FA_BOOKS is set.
      --  In this case, adjusted_cost of fully reserved should be removed from adjusted_cost
      -- of group asset. so need to maintain the memory table adjusted cost
      if nvl(h_exclude_fully_rsv_flag,'N') = 'Y' and
         nvl(p_group_rule_in.eofy_flag,'N') =  'Y' and
         nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule,'COST') = 'NBV' then

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'Fully Reserve Asset treatment', 'Starts++++', p_log_level_rec => p_log_level_rec);
        end if;

        For t IN 1.. p_track_member_table.COUNT LOOP
          if nvl(p_track_member_table(t).fully_reserved_flag,'N') = 'Y' and
             nvl(p_track_member_table(t).set_of_books_id,-99) = nvl(h_set_of_books_id,-99) then
            p_track_member_table(t).adjusted_cost := nvl(p_track_member_table(t).recoverable_cost,0)
                                                    - nvl(p_track_member_table(t).deprn_reserve,0);
            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'Updated fully reserved member asset', h_member_asset_id, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'Newly set Adjusted_cost and period_counter',
                                  p_track_member_table(t).adjusted_Cost||','||p_track_member_table(t).period_counter);
            end if;
          end if;
        End Loop;

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'Fully Reserve Asset treatment', 'Ended++++', p_log_level_rec => p_log_level_rec);
        end if;
      end if;

      end if; -- event_type check

   else -- Regular Mode: Periodic Update after depreciation

     if p_group_rule_in.mrc_sob_type_code <> 'R' then

      For member in ALL_MEMBERS loop

         h_member_asset_id := member.member_asset_id;

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) ++ started for Primary/Non-MRC Book +++', '+++');
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
         end if;

         fa_rule_in := p_group_rule_in;

         h_asset_id := null;
         h_transaction_type_code := null;

         if p_group_rule_in.adj_mem_transaction_header_id is not NULL then
           -- In this period, come transaction has occurred.
           h_adj_member_trans_header_id := p_group_rule_in.adj_mem_transaction_header_id;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'h_adj_member_trans_header_id', h_adj_member_trans_header_id, p_log_level_rec => p_log_level_rec);
           end if;

           if h_adj_member_trans_header_id is not null then
              select asset_id,transaction_type_code
                into h_asset_id,h_transaction_type_code
                from fa_transaction_headers
               where transaction_header_id = h_adj_member_trans_header_id;
           else
              h_asset_id := null;
           end if;
         end if;

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'processed member_asset_id', h_asset_id, p_log_level_rec => p_log_level_rec);
         end if;

         fa_rule_in.asset_id := member.member_asset_id;
         fa_rule_in.group_asset_id := h_group_asset_id;

         -- Get Asset type
         select asset_type into x_asset_type
           from fa_additions_b
          where asset_id = member.member_asset_id;

         fa_rule_in.asset_type := x_asset_type;
         fa_rule_in.cost := member.cost;
         fa_rule_in.salvage_value := member.salvage_value;
         fa_rule_in.recoverable_cost := member.recoverable_cost;
         fa_rule_in.adjusted_cost := member.adjusted_cost;

         fa_rule_in.hyp_basis := 0;
         fa_rule_in.hyp_total_rsv := 0;
         fa_rule_in.hyp_rsv := 0;
         fa_rule_in.hyp_total_ytd := 0;
         fa_rule_in.hyp_ytd := 0;

         fa_rule_in.old_adjusted_cost := member.adjusted_cost;
         fa_rule_in.old_raf := 1;
         fa_rule_in.old_formula_factor := 1;

-- ENERGY

         open FA_ADJ_RESERVE;
         fetch FA_ADJ_RESERVE into h_rsv_adjustment,h_bonus_rsv_adjustment,h_net_proceeds;
         close FA_ADJ_RESERVE;

--h_rsv_adjustment := 0;
--h_bonus_rsv_adjustment := 0;
--h_net_proceeds := 0;
-- ENERGY
         open FA_ADJ_EXPENSE;
         fetch FA_ADJ_EXPENSE into h_catchup_expense,h_bonus_catchup_expense;
         close FA_ADJ_EXPENSE;

         open FA_ADJ_RESERVE_MEM;
         fetch FA_ADJ_RESERVE_MEM into h_rsv_adjustment_mem,h_bonus_rsv_adj_mem,h_net_proceeds_mem;
         close FA_ADJ_RESERVE_MEM;

         open FA_ADJ_EXPENSE_MEM;
         fetch FA_ADJ_EXPENSE_MEM into h_catchup_expense_mem,h_bonus_catchup_mem;
         close FA_ADJ_EXPENSE_MEM;

      -- Added member level catchup and reserve adjustment
        h_catchup_expense := nvl(h_catchup_expense,0) + nvl(h_catchup_expense_mem,0);
        h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0) + nvl(h_bonus_catchup_mem,0);
        h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_rsv_adjustment_mem,0);
        h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_rsv_adj_mem,0);

         h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_catchup_expense,0);
         h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_catchup_expense,0);
         h_net_proceeds := nvl(h_net_proceeds,0);
         h_catchup_expense := nvl(h_catchup_expense,0);
         h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0);

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'h_catchup_expense:h_bonus_catchup_expense', h_catchup_expense||':'||h_bonus_catchup_expense, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_rsv_adjustment:h_bonus_rsv_adjustment', h_rsv_adjustment||':'||h_bonus_rsv_adjustment, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_net_proceeds', h_net_proceeds, p_log_level_rec => p_log_level_rec);
         end if;

         if p_group_rule_in.event_type = 'AFTER_DEPRN' and member.fully_reserved_flag is null then
           -- Check FA_ADJUSTMENTS table if there is any depreciation expense during this period.

              fa_rule_in.current_total_rsv := member.temp_deprn_reserve + nvl(h_rsv_adjustment,0);
              fa_rule_in.current_rsv := member.temp_deprn_reserve + nvl(h_rsv_adjustment,0)
                                            - (member.temp_bonus_deprn_reserve + nvl(h_bonus_rsv_adjustment,0));
              fa_rule_in.current_total_ytd := member.temp_ytd_deprn + nvl(h_catchup_expense,0);
              fa_rule_in.current_ytd := member.temp_ytd_deprn + nvl(h_catchup_expense,0)
                                            - (member.temp_bonus_ytd_deprn + nvl(h_bonus_catchup_expense,0));

              fa_rule_in.eofy_reserve := member.temp_prior_year_reserve;
              fa_rule_in.eofy_recoverable_cost := member.temp_eofy_recoverable_cost;
              fa_rule_in.eop_recoverable_cost := member.temp_eop_recoverable_cost;
              fa_rule_in.eofy_salvage_value := member.temp_eofy_salvage_value;
              fa_rule_in.eop_salvage_value := member.temp_eop_salvage_value;

         else

            -- Check if current fiscal year is same year as populated deprn summary table
            select fiscal_year into h_ds_fy
              from fa_deprn_periods
             where book_type_code = h_book_type_code
               and period_counter = member.ds_period_counter;

            if h_ds_fy <> h_fiscal_year then
--              member.bk_eofy_reserve := member.bk_eofy_reserve;  + member.ds_ytd_deprn;
              member.ds_ytd_deprn := 0;
            end if;

            fa_rule_in.current_total_rsv := member.ds_deprn_reserve + h_rsv_adjustment;
            fa_rule_in.current_rsv := (member.ds_deprn_reserve + h_rsv_adjustment)
                                    - (member.ds_bonus_deprn_reserve + h_bonus_rsv_adjustment);
            fa_rule_in.current_total_ytd := member.ds_ytd_deprn + h_catchup_expense;
            fa_rule_in.current_ytd := (member.ds_ytd_deprn + h_catchup_expense)
                                    - (member.ds_bonus_ytd_deprn + h_bonus_catchup_expense);

            fa_rule_in.eofy_reserve :=member.bk_eofy_reserve;

            -- Get eofy, eop amounts
            if not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
               (p_asset_id =>       fa_rule_in.asset_id,
                p_book_type_code => fa_rule_in.book_type_code,
                p_fiscal_year =>    fa_rule_in.fiscal_year,
                p_period_num =>     fa_rule_in.period_num,
                p_recoverable_cost => fa_rule_in.recoverable_cost,
                p_salvage_value => fa_rule_in.salvage_value,
                p_transaction_date_entered => fa_rule_in.transaction_date_entered,
                p_mrc_sob_type_code => p_group_rule_in.mrc_sob_type_code,
                p_set_of_books_id => p_group_rule_in.set_of_books_id,
                x_eofy_recoverable_cost => h_new_eofy_recoverable_cost,
                x_eofy_salvage_value => h_new_eofy_salvage_value,
                x_eop_recoverable_cost => h_new_eop_recoverable_cost,
                x_eop_salvage_value => h_new_eop_salvage_value, p_log_level_rec => p_log_level_rec) then
              fa_srvr_msg.add_message(calling_fn => 'fa_track_member_pvt.udpate_deprn_basis.get_eofy_eop',  p_log_level_rec => p_log_level_rec);
              return(false);

            end if;

            fa_rule_in.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
            fa_rule_in.eop_recoverable_cost := h_new_eop_recoverable_cost;
            fa_rule_in.eofy_salvage_value := h_new_eofy_salvage_value;
            fa_rule_in.eop_salvage_value := h_new_eop_salvage_value;

            if nvl(h_asset_id,-99) <> member.member_asset_id then
               -- This transaction is not for this member asset
               -- so I need to remove

               fa_rule_in.adjustment_amount := 0;
               fa_rule_in.transaction_header_id := to_number(NULL);
               fa_rule_in.proceeds_of_sale := 0;
               fa_rule_in.cost_of_removal := 0;
               fa_rule_in.unplanned_amount := 0;

            end if;  -- Transaction Check

         end if; -- AFTER_DEPRN ?

         fa_rule_in.apply_reduction_flag := nvl(p_apply_reduction_flag,'N');

         if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                                 rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
            raise upd_deprn_err;
         end if;

         --* Update FA_BOOKS table
         if nvl(fa_rule_in.eofy_flag,'N') = 'Y' then
           h_prior_eofy_reserve := member.bk_eofy_reserve;
           h_new_eofy_reserve := fa_rule_in.current_total_rsv;
           h_eofy_adj_cost   := member.adjusted_cost;
           h_eop_adj_cost := null;
         else
           if member.bk_eofy_reserve is not null then
             h_new_eofy_reserve := member.bk_eofy_reserve;
           else
             h_new_eofy_reserve := null;
           end if;
           h_eop_adj_cost := member.adjusted_cost;
           h_prior_eofy_reserve := null;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ update FA_BOOKS for ',member.member_asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost ',fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_eofy_adj_cost:h_eop_adj_cost:h_new_eofy_reserve ',
                                            h_eofy_adj_cost||':'||h_eop_adj_cost||':'||h_new_eofy_reserve, p_log_level_rec => p_log_level_rec);
         end if;

         update fa_books
            set adjusted_cost = fa_rule_out.new_adjusted_cost,
                eofy_adj_cost = h_eofy_adj_cost,
                eofy_reserve = h_new_eofy_reserve,
                eop_adj_cost = h_eop_adj_cost,
                prior_eofy_reserve = h_prior_eofy_reserve,
                adjustment_required_status='NONE'
          where book_type_code = p_group_rule_in.book_type_code
            and asset_id = member.member_asset_id
            and date_ineffective is null;

       end loop;

     else -- Reporting Book

      For member in ALL_MEMBERS_MRC loop

         h_member_asset_id := member.member_asset_id;

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) ++ started for Reporting Book +++', '+++');
           fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
         end if;

         fa_rule_in := p_group_rule_in;

         h_asset_id := null;
         h_transaction_type_code := null;

         if p_group_rule_in.adj_mem_transaction_header_id is not NULL then
           -- In this period, come transaction has occurred.
           h_adj_member_trans_header_id := p_group_rule_in.adj_mem_transaction_header_id;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'h_adj_member_trans_header_id',h_adj_member_trans_header_id, p_log_level_rec => p_log_level_rec);
           end if;

           if h_adj_member_trans_header_id is not null then
              select asset_id,transaction_type_code
                into h_asset_id,h_transaction_type_code
                from fa_transaction_headers
               where transaction_header_id = h_adj_member_trans_header_id;
           else
              h_asset_id := null;
           end if;
         end if;

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'processed member_asset_id', h_asset_id, p_log_level_rec => p_log_level_rec);
         end if;

         fa_rule_in.asset_id := member.member_asset_id;
         fa_rule_in.group_asset_id := h_group_asset_id;

         -- Get Asset type
         select asset_type into x_asset_type
           from fa_additions_b
          where asset_id = member.member_asset_id;

         fa_rule_in.asset_type := x_asset_type;
         fa_rule_in.cost := member.cost;
         fa_rule_in.salvage_value := member.salvage_value;
         fa_rule_in.recoverable_cost := member.recoverable_cost;
         fa_rule_in.adjusted_cost := member.adjusted_cost;
         fa_rule_in.eofy_reserve := member.bk_eofy_reserve;

          open FA_ADJ_RESERVE_MRC;
          fetch FA_ADJ_RESERVE_MRC into h_rsv_adjustment,h_bonus_rsv_adjustment,h_net_proceeds;
          close FA_ADJ_RESERVE_MRC;

          open FA_ADJ_EXPENSE_MRC;
          fetch FA_ADJ_EXPENSE_MRC into h_catchup_expense,h_bonus_catchup_expense;
          close FA_ADJ_EXPENSE_MRC;

          open FA_ADJ_RESERVE_MEM_MRC;
          fetch FA_ADJ_RESERVE_MEM_MRC into h_rsv_adjustment_mem,h_bonus_rsv_adj_mem,h_net_proceeds_mem;
          close FA_ADJ_RESERVE_MEM_MRC;

          open FA_ADJ_EXPENSE_MEM_MRC;
          fetch FA_ADJ_EXPENSE_MEM_MRC into h_catchup_expense_mem,h_bonus_catchup_mem;
          close FA_ADJ_EXPENSE_MEM_MRC;

      -- Added member level catchup and reserve adjustment
        h_catchup_expense := nvl(h_catchup_expense,0) + nvl(h_catchup_expense_mem,0);
        h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0) + nvl(h_bonus_catchup_mem,0);
        h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_rsv_adjustment_mem,0);
        h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_rsv_adj_mem,0);

          h_rsv_adjustment := nvl(h_rsv_adjustment,0) + nvl(h_catchup_expense,0);
          h_bonus_rsv_adjustment := nvl(h_bonus_rsv_adjustment,0) + nvl(h_bonus_catchup_expense,0);
          h_net_proceeds := nvl(h_net_proceeds,0);
          h_catchup_expense := nvl(h_catchup_expense,0);
          h_bonus_catchup_expense := nvl(h_bonus_catchup_expense,0);

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'h_catchup_expense:h_bonus_catchup_expense', h_catchup_expense||':'||h_bonus_catchup_expense, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_rsv_adjustment:h_bonus_rsv_adjustment', h_rsv_adjustment||':'||h_bonus_rsv_adjustment, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_net_proceeds', h_net_proceeds, p_log_level_rec => p_log_level_rec);
          end if;

         if p_group_rule_in.event_type = 'AFTER_DEPRN' and member.fully_reserved_flag is null then
           -- Check if there is catchup expense in this period.

            fa_rule_in.current_total_rsv := member.temp_deprn_reserve + nvl(h_rsv_adjustment,0);
            fa_rule_in.current_rsv := member.temp_deprn_reserve + nvl(h_rsv_adjustment,0)
                                            - (member.temp_bonus_deprn_reserve + nvl(h_bonus_rsv_adjustment,0));
            fa_rule_in.current_total_ytd := member.temp_ytd_deprn + nvl(h_catchup_expense,0);
            fa_rule_in.current_ytd := member.temp_ytd_deprn + nvl(h_catchup_expense,0)
                                            - (member.temp_bonus_ytd_deprn + nvl(h_bonus_catchup_expense,0));

            fa_rule_in.eofy_reserve := member.temp_prior_year_reserve;
            fa_rule_in.eofy_recoverable_cost := member.temp_eofy_recoverable_cost;
            fa_rule_in.eop_recoverable_cost := member.temp_eop_recoverable_cost;
            fa_rule_in.eofy_salvage_value := member.temp_eofy_salvage_value;
            fa_rule_in.eop_salvage_value := member.temp_eop_salvage_value;

         else

            -- Check if current fiscal year is same year as populated deprn summary table
            select fiscal_year into h_ds_fy
              from fa_deprn_periods
             where book_type_code = h_book_type_code
               and period_counter = member.ds_period_counter;

            if h_ds_fy <> h_fiscal_year then
--              member.bk_eofy_reserve := member.bk_eofy_reserve; -- + member.ds_ytd_deprn;
              member.ds_ytd_deprn := 0;
            end if;

            fa_rule_in.current_total_rsv := member.ds_deprn_reserve + h_rsv_adjustment;
            fa_rule_in.current_rsv := (member.ds_deprn_reserve + h_rsv_adjustment)
                                    - (member.ds_bonus_deprn_reserve + h_bonus_rsv_adjustment);
            fa_rule_in.current_total_ytd := member.ds_ytd_deprn + h_catchup_expense;
            fa_rule_in.current_ytd := (member.ds_ytd_deprn + h_catchup_expense)
                                    - (member.ds_bonus_ytd_deprn + h_bonus_catchup_expense);

            fa_rule_in.eofy_reserve := member.bk_eofy_reserve;

            -- Get eofy, eop amounts
            if not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
               (p_asset_id =>       fa_rule_in.asset_id,
                p_book_type_code => fa_rule_in.book_type_code,
                p_fiscal_year =>    fa_rule_in.fiscal_year,
                p_period_num =>     fa_rule_in.period_num,
                p_recoverable_cost => fa_rule_in.recoverable_cost,
                p_salvage_value => fa_rule_in.salvage_value,
                p_transaction_date_entered => fa_rule_in.transaction_date_entered,
                p_mrc_sob_type_code => p_group_rule_in.mrc_sob_type_code,
                p_set_of_books_id => p_group_rule_in.set_of_books_id,
                x_eofy_recoverable_cost => h_new_eofy_recoverable_cost,
                x_eofy_salvage_value => h_new_eofy_salvage_value,
                x_eop_recoverable_cost => h_new_eop_recoverable_cost,
                x_eop_salvage_value => h_new_eop_salvage_value, p_log_level_rec => p_log_level_rec) then
              raise upd_deprn_err;

            end if;

            fa_rule_in.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
            fa_rule_in.eop_recoverable_cost := h_new_eop_recoverable_cost;
            fa_rule_in.eofy_salvage_value := h_new_eofy_salvage_value;
            fa_rule_in.eop_salvage_value := h_new_eop_salvage_value;

            if nvl(h_asset_id,-99) <> member.member_asset_id then
               -- This transaction is not for this member asset
               -- so I need to remove

               fa_rule_in.adjustment_amount := 0;
               fa_rule_in.transaction_header_id := to_number(NULL);
               fa_rule_in.proceeds_of_sale := 0;
               fa_rule_in.cost_of_removal := 0;
               fa_rule_in.unplanned_amount := 0;

            end if;  -- Transaction Check

         end if; -- AFTER DEPRN?

         fa_rule_in.apply_reduction_flag := nvl(p_apply_reduction_flag,'N');

         if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                                 rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
            raise upd_deprn_err;
         end if;

         --* Update FA_BOOKS table
         if nvl(fa_rule_in.eofy_flag,'N') = 'Y' then
           h_new_eofy_reserve := fa_rule_in.current_total_rsv;
           h_eofy_adj_cost   := member.adjusted_cost;
           h_prior_eofy_reserve := member.bk_eofy_reserve;
           h_eop_adj_cost   := null;
         else
           if member.bk_eofy_reserve is not null then
             h_new_eofy_reserve := member.bk_eofy_reserve;
           else
             h_new_eofy_reserve := null;
           end if;
           h_eop_adj_cost   := member.eofy_adj_cost;
           h_prior_eofy_reserve := null;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ update FA_BOOKS for ',member.member_asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost ',fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'h_eofy_adj_cost:h_eop_adj_cost:h_new_eofy_reserve ',
                                            h_eofy_adj_cost||':'||h_eop_adj_cost||':'||h_new_eofy_reserve, p_log_level_rec => p_log_level_rec);
         end if;

         update fa_mc_books
            set adjusted_cost = fa_rule_out.new_adjusted_cost,
                eofy_adj_cost = h_eofy_adj_cost,
                eofy_reserve = h_new_eofy_reserve,
                eop_adj_cost = h_eop_adj_cost,
                prior_eofy_reserve = h_prior_eofy_reserve
          where book_type_code = p_group_rule_in.book_type_code
            and asset_id = member.member_asset_id
            and date_ineffective is null
            and set_of_books_id = h_set_of_books_id;

       end loop;

     end if; -- Primary or Reporting Book?

   end if; -- AJUSTMENT?

end if; -- ALLOCATE?

return(true);

exception
  when upd_deprn_err then
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

end update_deprn_basis;


----------------------------------------------------------------------------
--
--  Function:   ins_dd_adj
--
--  Description:
--
--              This function is called to insert allocated amount
--              into FA_ADJ or FA_DEPRN_DETAIL/SUMMARY in case
--              that Unplanned Depreciation is made.
--
----------------------------------------------------------------------------

FUNCTION ins_dd_adj(p_book_type_code         in varchar2,
                    p_group_asset_id         in number,
                    p_period_counter         in number,
                    p_fiscal_year            in number,
                    p_period_of_addition     in varchar2, -- default NULL,
                    p_transaction_date_entered in date, -- default NULL,
                    p_mrc_sob_type_code      in varchar2, -- default 'N',
                    p_set_of_books_id        in number,
                    p_mode                   in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

--* Internal structure
p_asset_hdr_rec      FA_API_TYPES.asset_hdr_rec_type;
x_asset_fin_rec      FA_API_TYPES.asset_fin_rec_type;
l_asset_deprn_rec    FA_API_TYPES.asset_deprn_rec_type;
l_adj                fa_adjust_type_pkg.fa_adj_row_struct;

--* Internal Variable
p_transaction_header_id   number;
l_transaction_key         varchar2(2);

l_status                  boolean;

l_calling_fn              varchar2(35) := 'fa_track_member_pvt.ins_dd_adj';
ins_dd_adj_err            exception;
l_rowid                   rowid;

l_debit_credit_flag       varchar(2);
l_allocated_deprn_amount  number;
l_deprn_adjustment_amount number;

l_index                   number := 1; -- Bug 8703676

--* cursor to query the member inserted into FA_TRACK_MEMBERS
-- after allocation
cursor MEMBERS is
  select member_asset_id,
         allocated_deprn_amount,
         fully_reserved_flag
    from fa_track_members
   where group_asset_id = p_group_asset_id
     and period_counter = p_period_counter
     and fiscal_year = p_fiscal_year
     and nvl(set_of_books_id,-99) = nvl(p_set_of_books_id,-99);

begin

/* Apply MRC related feature */

if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, '+++ INS_DD_ADJ start +++', '+++', p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn, 'p_set_of_books_id', p_set_of_books_id, p_log_level_rec => p_log_level_rec);
end if;

-- Currently this function will be called only after Unplanned Depreciation for Group Level.

if p_mode = 'UNPLANNED' or P_mode = 'GROUP ADJUSTMENT' then

  if P_mode = 'UNPLANNED' then
    l_transaction_key := 'UA';
  else
    l_transaction_key := NULL;
  end if;

  -- Loop for members
  for member in MEMBERS loop

   if member.allocated_deprn_amount <> 0 then
    -- Set p_asset_hdr_rec
    p_asset_hdr_rec.asset_id := member.member_asset_id;
    p_asset_hdr_rec.book_type_code := p_book_type_code;
    p_asset_hdr_rec.set_of_books_id := p_set_of_books_id;

    -- Call get_asset_fin_rec
    if not FA_UTIL_PVT.get_asset_fin_rec(p_asset_hdr_rec => p_asset_hdr_rec,
                                         px_asset_fin_rec => x_asset_fin_rec,
                                         p_transaction_header_id => NULL,
                                         p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise ins_dd_adj_err;
    end if;

    --Bug#8692192 - To create transaction for primary book only
    if p_mrc_sob_type_code <> 'R' then
       -- Get new Transaction Header ID
       select fa_transaction_headers_s.nextval
         into p_transaction_header_id
         from dual;

       -- Bug 8703676 : Store the trx_hdr_id during the primary loop
       g_primary_trx_hdr_id_tbl(l_index) :=  p_transaction_header_id;
       l_index := l_index + 1;

       FA_TRANSACTION_HEADERS_PKG.Insert_Row
                      (X_Rowid                          => l_rowid,
                       X_Transaction_Header_Id          => p_transaction_header_id,
                       X_Book_Type_Code                 => p_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => p_asset_hdr_rec.asset_id,
                       X_Transaction_Type_Code          => 'ADJUSTMENT',
                       X_Transaction_Date_Entered       => p_transaction_date_entered,
                       X_Date_Effective                 => sysdate,
                       X_Last_Update_Date               => sysdate,
                       X_Last_Updated_By                => -1,
                       X_Transaction_Name               => NULL,
                       X_Invoice_Transaction_Id         => NULL,
                       X_Source_Transaction_Header_Id   => NULL,
                       X_Mass_Reference_Id              => NULL,
                       X_Last_Update_Login              => -1,
                       X_Transaction_Subtype            => 'AMORTIZED',
                       X_Attribute1                     => null,
                       X_Attribute2                     => null,
                       X_Attribute3                     => null,
                       X_Attribute4                     => null,
                       X_Attribute5                     => null,
                       X_Attribute6                     => null,
                       X_Attribute7                     => null,
                       X_Attribute8                     => null,
                       X_Attribute9                     => null,
                       X_Attribute10                    => null,
                       X_Attribute11                    => null,
                       X_Attribute12                    => null,
                       X_Attribute13                    => null,
                       X_Attribute14                    => null,
                       X_Attribute15                    => null,
                       X_Attribute_Category_Code        => null,
                       X_Transaction_Key                => l_transaction_key,
                       X_Amortization_Start_Date        => NULL,
                       X_Calling_Interface              => null,
                       X_Mass_Transaction_ID            => null,
                       X_Return_Status                  => l_status,
                       X_Calling_Fn                     => 'fa_track_member_pvt.ins_dd_adj'
                      ,  p_log_level_rec => p_log_level_rec);

             if not l_status then
                raise ins_dd_adj_err;
             end if;
    else

       -- Bug 8703676 : Get the trx_hdr_id saved during the primary loop
       p_transaction_header_id := g_primary_trx_hdr_id_tbl(l_index);
       l_index := l_index + 1;

    end if;

               -- terminate the row
             fa_books_pkg.deactivate_row
                     (X_asset_id                  => p_asset_hdr_rec.asset_id,
                      X_book_type_code            => p_asset_hdr_rec.book_type_code,
                      X_transaction_header_id_out => p_transaction_header_id,
                      X_date_ineffective          => sysdate,
                      X_mrc_sob_type_code         => p_mrc_sob_type_code,
                      X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
                      X_Calling_Fn                => 'fa_track_member_pvt.ins_dd_adj'
                      ,  p_log_level_rec => p_log_level_rec);

             l_rowid := null;

             if nvl(member.fully_reserved_flag,'N') = 'Y'  then /*Bug# 9145376 */
                x_asset_fin_rec.period_counter_fully_reserved := p_period_counter;
             else
                x_asset_fin_rec.period_counter_fully_reserved := NULL;
             end if;

             x_asset_fin_rec.period_counter_life_complete := x_asset_fin_rec.period_counter_fully_reserved;

             -- insert the row
             fa_books_pkg.insert_row
                     (X_Rowid                        => l_rowid,
                      X_Book_Type_Code               => p_asset_hdr_rec.book_type_code,
                      X_Asset_Id                     => p_asset_hdr_rec.asset_id,
                      X_Date_Placed_In_Service       => x_asset_fin_rec.date_placed_in_service,
                      X_Date_Effective               => sysdate,
                      X_Deprn_Start_Date             => x_asset_fin_rec.deprn_start_date,
                      X_Deprn_Method_Code            => x_asset_fin_rec.deprn_method_code,
                      X_Life_In_Months               => x_asset_fin_rec.life_in_months,
                      X_Rate_Adjustment_Factor       => x_asset_fin_rec.rate_adjustment_factor,
                      X_Adjusted_Cost                => x_asset_fin_rec.adjusted_cost,
                      X_Cost                         => x_asset_fin_rec.cost,
                      X_Original_Cost                => x_asset_fin_rec.original_cost,
                      X_Salvage_Value                => x_asset_fin_rec.salvage_value,
                      X_Prorate_Convention_Code      => x_asset_fin_rec.prorate_convention_code,
                      X_Prorate_Date                 => x_asset_fin_rec.prorate_date,
                      X_Cost_Change_Flag             => x_asset_fin_rec.cost_change_flag,
                      X_Adjustment_Required_Status   => x_asset_fin_rec.adjustment_required_status,
                      X_Capitalize_Flag              => x_asset_fin_rec.capitalize_flag,
                      X_Retirement_Pending_Flag      => x_asset_fin_rec.retirement_pending_flag,
                      X_Depreciate_Flag              => x_asset_fin_rec.depreciate_flag,
                      X_Last_Update_Date             => sysdate,
                      X_Last_Updated_By              => -1,
                      X_Date_Ineffective             => NULL,
                      X_Transaction_Header_Id_In     => p_transaction_header_id,
                      X_Transaction_Header_Id_Out    => NULL,
                      X_Itc_Amount_Id                => x_asset_fin_rec.itc_amount_id,
                      X_Itc_Amount                   => x_asset_fin_rec.itc_amount,
                      X_Retirement_Id                => x_asset_fin_rec.retirement_id,
                      X_Tax_Request_Id               => x_asset_fin_rec.tax_request_id,
                      X_Itc_Basis                    => x_asset_fin_rec.itc_basis,
                      X_Basic_Rate                   => x_asset_fin_rec.basic_rate,
                      X_Adjusted_Rate                => x_asset_fin_rec.adjusted_rate,
                      X_Bonus_Rule                   => x_asset_fin_rec.bonus_rule,
                      X_Ceiling_Name                 => x_asset_fin_rec.ceiling_name,
                      X_Recoverable_Cost             => x_asset_fin_rec.recoverable_cost,
                      X_Last_Update_Login            => -1,
                      X_Adjusted_Capacity            => x_asset_fin_rec.adjusted_capacity,
                      X_Fully_Rsvd_Revals_Counter    => x_asset_fin_rec.fully_rsvd_revals_counter,
                      X_Idled_Flag                   => x_asset_fin_rec.idled_flag,
                      X_Period_Counter_Capitalized   => x_asset_fin_rec.period_counter_capitalized,
                      X_PC_Fully_Reserved            => x_asset_fin_rec.period_counter_fully_reserved,
                      X_Period_Counter_Fully_Retired => x_asset_fin_rec.period_counter_fully_retired,
                      X_Production_Capacity          => x_asset_fin_rec.production_capacity,
                      X_Reval_Amortization_Basis     => x_asset_fin_rec.reval_amortization_basis,
                      X_Reval_Ceiling                => x_asset_fin_rec.reval_ceiling,
                      X_Unit_Of_Measure              => x_asset_fin_rec.unit_of_measure,
                      X_Unrevalued_Cost              => x_asset_fin_rec.unrevalued_cost,
                      X_Annual_Deprn_Rounding_Flag   => 'ADJ',
                      X_Percent_Salvage_Value        => x_asset_fin_rec.percent_salvage_value,
                      X_Allowed_Deprn_Limit          => x_asset_fin_rec.allowed_deprn_limit,
                      X_Allowed_Deprn_Limit_Amount   => x_asset_fin_rec.allowed_deprn_limit_amount,
                      X_Period_Counter_Life_Complete => x_asset_fin_rec.period_counter_life_complete,
                      X_Adjusted_Recoverable_Cost    => x_asset_fin_rec.adjusted_recoverable_cost,
                      X_Short_Fiscal_Year_Flag       => x_asset_fin_rec.short_fiscal_year_flag,
                      X_Conversion_Date              => x_asset_fin_rec.conversion_date,
                      X_Orig_Deprn_Start_Date        => x_asset_fin_rec.orig_deprn_start_date,
                      X_Remaining_Life1              => x_asset_fin_rec.remaining_life1,
                      X_Remaining_Life2              => x_asset_fin_rec.remaining_life2,
                      X_Old_Adj_Cost                 => x_asset_fin_rec.old_adjusted_cost,
                      X_Formula_Factor               => x_asset_fin_rec.formula_factor,
                      X_gf_Attribute1                => x_asset_fin_rec.global_attribute1,
                      X_gf_Attribute2                => x_asset_fin_rec.global_attribute2,
                      X_gf_Attribute3                => x_asset_fin_rec.global_attribute3,
                      X_gf_Attribute4                => x_asset_fin_rec.global_attribute4,
                      X_gf_Attribute5                => x_asset_fin_rec.global_attribute5,
                      X_gf_Attribute6                => x_asset_fin_rec.global_attribute6,
                      X_gf_Attribute7                => x_asset_fin_rec.global_attribute7,
                      X_gf_Attribute8                => x_asset_fin_rec.global_attribute8,
                      X_gf_Attribute9                => x_asset_fin_rec.global_attribute9,
                      X_gf_Attribute10               => x_asset_fin_rec.global_attribute10,
                      X_gf_Attribute11               => x_asset_fin_rec.global_attribute11,
                      X_gf_Attribute12               => x_asset_fin_rec.global_attribute12,
                      X_gf_Attribute13               => x_asset_fin_rec.global_attribute13,
                      X_gf_Attribute14               => x_asset_fin_rec.global_attribute14,
                      X_gf_Attribute15               => x_asset_fin_rec.global_attribute15,
                      X_gf_Attribute16               => x_asset_fin_rec.global_attribute16,
                      X_gf_Attribute17               => x_asset_fin_rec.global_attribute17,
                      X_gf_Attribute18               => x_asset_fin_rec.global_attribute18,
                      X_gf_Attribute19               => x_asset_fin_rec.global_attribute19,
                      X_gf_Attribute20               => x_asset_fin_rec.global_attribute20,
                      X_global_attribute_category    => x_asset_fin_rec.global_attribute_category,
                      X_group_asset_id               => x_asset_fin_rec.group_asset_id,
                      X_salvage_type                 => x_asset_fin_rec.salvage_type,
                      X_deprn_limit_type             => x_asset_fin_rec.deprn_limit_type,
                      X_over_depreciate_option       => x_asset_fin_rec.over_depreciate_option,
                      X_super_group_id               => x_asset_fin_rec.super_group_id,
                      X_reduction_rate               => x_asset_fin_rec.reduction_rate,
                      X_reduce_addition_flag         => x_asset_fin_rec.reduce_addition_flag,
                      X_reduce_adjustment_flag       => x_asset_fin_rec.reduce_adjustment_flag,
                      X_reduce_retirement_flag       => x_asset_fin_rec.reduce_retirement_flag,
                      X_recognize_gain_loss          => x_asset_fin_rec.recognize_gain_loss,
                      X_recapture_reserve_flag       => x_asset_fin_rec.recapture_reserve_flag,
                      X_limit_proceeds_flag          => x_asset_fin_rec.limit_proceeds_flag,
                      X_terminal_gain_loss           => x_asset_fin_rec.terminal_gain_loss,
                      X_tracking_method              => x_asset_fin_rec.tracking_method,
                      X_allocate_to_fully_rsv_flag   => x_asset_fin_rec.allocate_to_fully_rsv_flag,
                      X_allocate_to_fully_ret_flag   => x_asset_fin_rec.allocate_to_fully_ret_flag,
                      X_exclude_fully_rsv_flag       => x_asset_fin_rec.exclude_fully_rsv_flag,
                      X_excess_allocation_option     => x_asset_fin_rec.excess_allocation_option,
                      X_depreciation_option          => x_asset_fin_rec.depreciation_option,
                      X_member_rollup_flag           => x_asset_fin_rec.member_rollup_flag,
                      X_ytd_proceeds                 => x_asset_fin_rec.ytd_proceeds,
                      X_ltd_proceeds                 => x_asset_fin_rec.ltd_proceeds,
                      X_eofy_reserve                 => x_asset_fin_rec.eofy_reserve,
                      X_cip_cost                     => x_asset_fin_rec.cip_cost,
                      X_terminal_gain_loss_amount    => x_asset_fin_rec.terminal_gain_loss_amount,
                      X_ltd_cost_of_removal          => x_asset_fin_rec.ltd_cost_of_removal,
                      X_exclude_proceeds_from_basis  => x_asset_fin_rec.exclude_proceeds_from_basis,
                      X_retirement_deprn_option      => x_asset_fin_rec.retirement_deprn_option,
                      X_terminal_gain_loss_flag      => x_asset_fin_rec.terminal_gain_loss_flag,
                      X_mrc_sob_type_code            => p_mrc_sob_type_code,
                      X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
                      X_Return_Status                => l_status,
                      X_Calling_Fn                   => 'fa_track_member_pvt.ins_dd_adj'
                ,p_log_level_rec => p_log_level_rec);

          if not l_status then
             raise ins_dd_adj_err;
          end if;

          if (nvl(p_period_of_addition,'N') <> 'Y') then

                l_debit_credit_flag := 'DR';
                l_allocated_deprn_amount  := l_allocated_deprn_amount;


             l_adj.transaction_header_id    := p_transaction_header_id;
             l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
             l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
             l_adj.period_counter_created   := p_period_counter;
             l_adj.period_counter_adjusted  := p_period_counter;
             l_adj.current_units            := 0;
             l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
             l_adj.selection_thid           := 0;
             l_adj.selection_retid          := 0;
             l_adj.leveling_flag            := FALSE;
             l_adj.last_update_date         := sysdate;

             l_adj.flush_adj_flag           := TRUE;
             l_adj.gen_ccid_flag            := FALSE;
             l_adj.annualized_adjustment    := 0;
             l_adj.asset_invoice_id         := 0;
             l_adj.code_combination_id      := 0;
             l_adj.distribution_id          := 0;

             l_adj.deprn_override_flag:= '';

             l_adj.source_type_code    := 'DEPRECIATION';
             l_adj.adjustment_type     := 'EXPENSE';
             l_adj.account             := 0;
             l_adj.account_type        := 'DEPRN_EXPENSE_ACCT';
             l_adj.debit_credit_flag   := l_debit_credit_flag;
             l_adj.adjustment_amount   := member.allocated_deprn_amount;
             l_adj.mrc_sob_type_code   := p_mrc_sob_type_code;
             l_adj.set_of_books_id     := p_set_of_books_id;
             l_adj.track_member_flag   := 'Y';

             if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 sysdate,
                 -1,
                 -1, p_log_level_rec => p_log_level_rec) then
                raise ins_dd_adj_err;
             end if;

          else  -- period of addition

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'period of addition', 'processed', p_log_level_rec => p_log_level_rec);
            end if;

            -- get any current deprn adjustment amount balance (not available in query bal)
            if (p_mrc_sob_type_code = 'R') then

              select sum(nvl(deprn_adjustment_amount, 0))
                into l_deprn_adjustment_amount
                from fa_mc_deprn_detail
               where asset_id       = p_asset_hdr_rec.asset_id
                 and book_type_code = p_asset_hdr_rec.book_type_code
                 and set_of_books_id = p_set_of_books_id;

           else -- primary

             select sum(nvl(deprn_adjustment_amount, 0))
               into l_deprn_adjustment_amount
               from fa_deprn_detail
              where asset_id       = p_asset_hdr_rec.asset_id
                and book_type_code = p_asset_hdr_rec.book_type_code;

           end if;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'l_deprn_adjustment_amount', l_deprn_adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

           -- calculate new value using unplanned amount as delta
           -- get current balance
           if not FA_UTIL_PVT.get_asset_deprn_rec(p_asset_hdr_rec => p_asset_hdr_rec,
                                                  px_asset_deprn_rec => l_asset_deprn_rec,
                                                  p_period_counter => p_period_counter - 1,
                                                  p_mrc_sob_type_code => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
              raise ins_dd_adj_err;

           end if;

           l_asset_deprn_rec.deprn_reserve := member.allocated_deprn_amount + nvl(l_asset_deprn_rec.deprn_reserve, 0);
           l_asset_deprn_rec.ytd_deprn     := member.allocated_deprn_amount + nvl(l_asset_deprn_rec.ytd_deprn, 0);

           l_deprn_adjustment_amount       := member.allocated_deprn_amount + nvl(l_deprn_adjustment_amount, 0);

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'member.allocated_deprn_amount', member.allocated_deprn_amount, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve:ytd_deprn',
                                                      l_asset_deprn_rec.deprn_reserve||':'||l_asset_deprn_rec.ytd_deprn, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'l_deprn_adjustment_amount', l_deprn_adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

           FA_DEPRN_SUMMARY_PKG.Update_Row
                      (X_Book_Type_Code                 => p_asset_hdr_rec.book_type_code,
                       X_Asset_Id                       => p_asset_hdr_rec.asset_id,
                       X_Ytd_Deprn                      => l_asset_deprn_rec.ytd_deprn,
                       X_Deprn_Reserve                  => l_asset_deprn_rec.deprn_reserve,
                       X_Period_Counter                 => p_period_counter - 1,
                       X_mrc_sob_type_code              => p_mrc_sob_type_code,
                       X_set_of_books_id                => p_asset_hdr_rec.set_of_books_id,

                       X_Calling_Fn                     => 'fa_track_member_pvt.ins_dd_adj'
                      ,  p_log_level_rec => p_log_level_rec);

           if not FA_INS_DETAIL_PKG.FAXINDD
                 (X_book_type_code           => p_asset_hdr_rec.book_type_code,
                  X_asset_id                 => p_asset_hdr_rec.asset_id,
                  X_deprn_adjustment_amount  => l_deprn_adjustment_amount,
                  X_mrc_sob_type_code        => p_mrc_sob_type_code,
                  X_set_of_books_id          => p_asset_hdr_rec.set_of_books_id
                 , p_log_level_rec => p_log_level_rec) then
              raise ins_dd_adj_err;

      end if;

   end if; -- end if period of addition
  end if; -- Adjustment_Amount is zero or not

  end loop;

end if; -- UNPLANNED?

return true;

EXCEPTION
   when ins_dd_adj_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error
          (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

end ins_dd_adj;

----------------------------------------------------------------------------
--
--  Function:   populate previous rows
--
--  Description:
--
--              This function is called to prepare PL/SQL table to process
--              allocation under ADJUSTMENT mode
--              If PL/SQL table doesn't exist, this function will extend the
--              table with necessary values for member assets to be processed
--              at one period before the starting period made subsequently.
--
----------------------------------------------------------------------------
FUNCTION populate_previous_rows(p_book_type_code     in varchar2,
                                p_group_asset_id     in number,
                                p_period_counter     in number,
                                p_fiscal_year        in number,
                                p_transaction_header_id in number,
                                p_loop_end_year      in number,
                                p_loop_end_period    in number,
                                p_allocate_to_fully_ret_flag in varchar2,
                                p_allocate_to_fully_rsv_flag in varchar2,
                                p_mrc_sob_type_code  in varchar2, -- default 'N'
                                p_set_of_books_id    in number,
                                p_calling_fn         in varchar2 ,p_log_level_rec       IN     fa_api_types.log_level_rec_type) -- default null
  return boolean is

--* Structure to call Deprn Basis Rule
fa_rule_in      fa_std_types.fa_deprn_rule_in_struct;
fa_rule_out     fa_std_types.fa_deprn_rule_out_struct;

--* Host related variables
h_book_type_code        varchar2(30);
h_group_asset_id        number;
h_member_asset_id       number;
h_period_counter        number;
h_fiscal_year           number;
h_period_number         number;
h_current_year_flag     varchar2(1);
h_transaction_date      date;
h_last_trans_id         number;
h_perd_per_fiscal_year  number;

h_cost                  number;
h_adjusted_cost         number;
h_recoverable_cost      number;
h_salvage_value         number;
h_adjusted_recoverable_cost     number;
h_pc_fully_reserved     number;
h_pc_fully_retired      number;
h_eofy_reserve          number;
h_deprn_reserve         number;
h_ytd_deprn             number;
h_bonus_deprn_reserve   number;
h_bonus_ytd_deprn       number;
h_eop_fiscal_year       number;

h_loop_end_year         number;
h_loop_end_period       number;
h_loop_period_counter   number;

h_method_code           varchar2(30);
h_life_in_months        number;

h_eofy_rec_cost         number;
h_eofy_salvage_value    number;
h_eofy_adj_cost         number;

h_eofy_reserve_adjustment   number;
h_adj_reserve           number;

h_amort_addition_date   date;
h_temp_deprn_reserve    number;
h_temp_ytd_deprn        number;

i                       number;
h_adj_asset_id          number;
h_adj_trans_type        varchar2(20);

l_calling_fn            varchar2(45) := 'fa_track_member_pvt.populate_previous_rows';
populate_previous_rows_err           exception;

l_member_asset_id  number;

   cursor c_get_member_asset_id is
      select mth.asset_id
      from   fa_transaction_headers mth
--           , fa_transaction_headers gth
--      where  gth.transaction_header_id = p_transaction_header_id
--      and    mth.transaction_header_id = gth.member_transaction_header_id;
      where  mth.transaction_header_id = p_transaction_header_id;


-- cursor to get period close date
cursor GET_PERD_CLOSE_DATE is
  select nvl(calendar_period_close_date,sysdate)
    from fa_deprn_periods
   where book_type_code = h_book_type_code
     and period_counter = h_loop_period_counter;

cursor GET_PERD_CLOSE_DATE_MRC is
  select nvl(calendar_period_close_date,sysdate)
    from fa_mc_deprn_periods
   where book_type_code = h_book_type_code
     and period_counter = h_loop_period_counter
     and set_of_books_id = p_set_of_books_id;

-- cursor to get period close date
cursor GET_TRANS_DATE is
  select nvl(amortization_start_date,transaction_date_entered), asset_id, transaction_type_code
    from fa_transaction_headers
   where book_type_code = h_book_type_code
     and transaction_header_id = p_transaction_header_id;

-- cursor to get all members at the specified period
cursor ALL_MEMBERS(h_date date) is
  select bk.asset_id
    from fa_books  bk,
         fa_additions_b ad
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_group_asset_id
     and bk.date_placed_in_service <= h_date
     and bk.depreciate_flag = 'YES'
     and bk.date_ineffective is null
     and ad.asset_id = bk.asset_id
     and ad.asset_type = 'CAPITALIZED'
     and bk.asset_id = nvl(l_member_asset_id, bk.asset_id)
   order by ad.asset_number;

cursor ALL_MEMBERS_MRC(h_date date) is
  select bk.asset_id
    from fa_mc_books  bk,
         fa_additions_b ad
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_group_asset_id
     and bk.set_of_books_id = p_set_of_books_id
     and bk.date_placed_in_service <= h_date
     and bk.depreciate_flag = 'YES'
     and bk.date_ineffective is null
     and bk.set_of_books_id = p_set_of_books_id
     and ad.asset_id = bk.asset_id
     and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number;

-- cursor to query start period condition of all members belonged to the specified group
cursor ALL_MEMBER_FOR_ADJ_MODE(p_member_asset_id number) is
  select bk.cost,
         bk.adjusted_cost,
         bk.recoverable_cost,
         bk.salvage_value,
         bk.adjusted_recoverable_cost,
         bk.period_counter_fully_reserved,
         bk.period_counter_fully_retired,
         decode(ds.deprn_source_code,'BOOKS',ds.deprn_reserve - ds.ytd_deprn,
                decode(dp1.fiscal_year,h_fiscal_year,ds.deprn_reserve - ds.ytd_deprn,
                       ds.deprn_reserve)), -- bk.eofy_reserve,
         ds.deprn_reserve,
         decode(dp1.fiscal_year,h_fiscal_year,ds.ytd_deprn,0),
         ds.bonus_deprn_reserve,
         decode(dp1.fiscal_year,h_fiscal_year,ds.bonus_ytd_deprn,0),
         dp1.fiscal_year
    from fa_books  bk,
         fa_deprn_periods dp,
         fa_deprn_periods dp1,
         fa_deprn_summary ds,
         fa_additions_b ad
   where dp.book_type_code = h_book_type_code
     and dp.period_counter = h_loop_period_counter
     and bk.book_type_code = dp.book_type_code
     and bk.asset_id = p_member_asset_id
     and (bk.transaction_header_id_out = p_transaction_header_id or
          bk.transaction_header_id_out = h_last_trans_id or
         (bk.date_ineffective is null and
          bk.transaction_header_id_in <> nvl(p_transaction_header_id,-1) and
          not exists (select 'y'
                        from fa_books bk1
                       where bk1.book_type_code = bk.book_type_code
                         and bk1.asset_id = bk.asset_id
                         and bk1.transaction_header_id_out = nvl(p_transaction_header_id,-1))))
     and bk.depreciate_flag = decode(p_transaction_header_id,NULL,'YES',bk.depreciate_flag) -- added for bug 8584206
     and ds.book_type_code = bk.book_type_code
     and ds.period_counter =
         (select min(period_counter)
            from fa_deprn_summary ds1
           where ds1.book_type_code = h_book_type_code
             and ds1.asset_id = bk.asset_id
             and ds1.period_counter >= h_period_counter - 1)
     and ds.asset_id = bk.asset_id
     and dp1.book_type_code = h_book_type_code
     and dp1.period_counter = ds.period_counter
     and ad.asset_id = bk.asset_id
     and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number;

cursor ALL_MEMBER_FOR_ADJ_MODE_MRC(p_member_asset_id number) is
  select bk.cost,
         bk.adjusted_cost,
         bk.recoverable_cost,
         bk.salvage_value,
         bk.adjusted_recoverable_cost,
         bk.period_counter_fully_reserved,
         bk.period_counter_fully_retired,
         decode(ds.deprn_source_code,'BOOKS',ds.deprn_reserve - ds.ytd_deprn,
                decode(dp1.fiscal_year,h_fiscal_year,ds.deprn_reserve - ds.ytd_deprn,
                ds.deprn_reserve)), -- bk.eofy_reserve,
         ds.deprn_reserve,
         decode(dp1.fiscal_year,h_fiscal_year,ds.ytd_deprn,0),
         ds.bonus_deprn_reserve,
         decode(dp1.fiscal_year,h_fiscal_year,ds.bonus_ytd_deprn,0),
         dp1.fiscal_year
    from fa_mc_books  bk,
         fa_mc_deprn_periods dp,
         fa_mc_deprn_periods dp1,
         fa_mc_deprn_summary ds,
         fa_additions_b ad
   where dp.book_type_code = h_book_type_code
     and dp.period_counter = h_loop_period_counter
     and dp.set_of_books_id = p_set_of_books_id
     and bk.book_type_code = dp.book_type_code
     and bk.asset_id = p_member_asset_id
     and bk.set_of_books_id = p_set_of_books_id
     and (bk.transaction_header_id_out = p_transaction_header_id or
         bk.transaction_header_id_out = h_last_trans_id or
         (bk.date_ineffective is null and
          bk.transaction_header_id_in <> nvl(p_transaction_header_id,-1) and
          not exists (select 'y'
                        from fa_mc_books bk1
                       where bk1.book_type_code = bk.book_type_code
                         and bk1.asset_id = bk.asset_id
                         and bk1.transaction_header_id_out = nvl(p_transaction_header_id,-1)
                         and set_of_books_id = p_set_of_books_id)))
     and bk.depreciate_flag = decode(p_transaction_header_id,NULL,'YES',bk.depreciate_flag) -- added for bug 8584206
     and ds.book_type_code = bk.book_type_code
     and ds.period_counter =
         (select min(period_counter)
            from fa_mc_deprn_summary ds1
           where ds1.book_type_code = h_book_type_code
             and ds1.asset_id = bk.asset_id
             and ds1.period_counter >= h_period_counter - 1)
     and ds.set_of_books_id = p_set_of_books_id
     and ds.asset_id = bk.asset_id
     and dp1.book_type_code = h_book_type_code
     and dp1.period_counter = ds.period_counter
     and dp1.set_of_books_id = p_set_of_books_id
     and ad.asset_id = bk.asset_id
     and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number;

-- cursor to query start period condition of all members belonged to the specified group
cursor ALL_MEMBER_FOR_ADDITION(p_member_asset_id number) is
  select bk.cost,
         bk.adjusted_cost,
         bk.recoverable_cost,
         bk.salvage_value,
         bk.adjusted_recoverable_cost,
         bk.period_counter_fully_reserved,
         bk.period_counter_fully_retired,
         decode(ds.deprn_source_code,'BOOKS',ds.deprn_reserve - ds.ytd_deprn,
                decode(dp.fiscal_year,h_fiscal_year,ds.deprn_reserve - ds.ytd_deprn,
                       ds.deprn_reserve)), -- bk.eofy_reserve,
         ds.deprn_reserve,
         ds.ytd_deprn,
         ds.bonus_deprn_reserve,
         ds.bonus_ytd_deprn,
         dp.fiscal_year
    from fa_books  bk,
         fa_deprn_periods dp,
         fa_deprn_summary ds,
         fa_additions_b ad
   where dp.book_type_code = h_book_type_code
     and dp.period_counter = h_loop_period_counter
     and bk.book_type_code = dp.book_type_code
     and bk.asset_id = p_member_asset_id
     and bk.date_ineffective is null
     and bk.depreciate_flag = 'YES'
     and ds.book_type_code = bk.book_type_code
     and ds.period_counter =
         (select min(period_counter)
            from fa_deprn_summary ds1
           where ds1.book_type_code = h_book_type_code
             and ds1.asset_id = bk.asset_id
             and ds1.period_counter >= h_period_counter - 1)
     and ds.asset_id = bk.asset_id
     and ad.asset_id = bk.asset_id
     and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number;

cursor ALL_MEMBER_FOR_ADDITION_MRC(p_member_asset_id number) is
  select bk.cost,
         bk.adjusted_cost,
         bk.recoverable_cost,
         bk.salvage_value,
         bk.adjusted_recoverable_cost,
         bk.period_counter_fully_reserved,
         bk.period_counter_fully_retired,
         decode(ds.deprn_source_code,'BOOKS',ds.deprn_reserve - ds.ytd_deprn,
                decode(dp.fiscal_year,h_fiscal_year,ds.deprn_reserve - ds.ytd_deprn,
                       ds.deprn_reserve)), -- bk.eofy_reserve,
         ds.deprn_reserve,
         ds.ytd_deprn,
         ds.bonus_deprn_reserve,
         ds.bonus_ytd_deprn,
         dp.fiscal_year
    from fa_mc_books  bk,
         fa_mc_deprn_periods dp,
         fa_mc_deprn_summary ds,
         fa_additions_b ad
   where dp.book_type_code = h_book_type_code
     and dp.period_counter = h_loop_period_counter
     and dp.set_of_books_id = p_set_of_books_id
     and bk.book_type_code = dp.book_type_code
     and bk.asset_id = p_member_asset_id
     and bk.set_of_books_id = p_set_of_books_id
     and bk.date_ineffective is null
     and bk.depreciate_flag = 'YES'
     and ds.book_type_code = bk.book_type_code
     and ds.period_counter =
         (select min(period_counter)
            from fa_mc_deprn_summary ds1
           where ds1.book_type_code = h_book_type_code
             and ds1.asset_id = bk.asset_id
             and ds1.period_counter >= h_period_counter - 1)
     and ds.set_of_books_id = p_set_of_books_id
     and ds.asset_id = bk.asset_id
     and ad.asset_id = bk.asset_id
     and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number;

cursor MEMBER_START_PERIOD is
  select bk.recoverable_cost,
         bk.salvage_value
    from fa_books  bk,
         fa_deprn_periods dp
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_member_asset_id
     and bk.date_effective <= nvl(dp.period_close_date,sysdate)
     and nvl(bk.date_ineffective,sysdate) >= nvl(dp.period_close_date,sysdate)
     and dp.book_type_code = bk.book_type_code
     and dp.fiscal_year = h_fiscal_year - 1
     and dp.period_num = (select max(period_num) from fa_deprn_periods dp1
                           where dp1.book_type_code = h_book_type_code
                             and dp1.fiscal_year = h_fiscal_year - 1);

cursor MEMBER_START_PERIOD_MRC is
  select bk.recoverable_cost,
         bk.salvage_value
    from fa_mc_books  bk,
         fa_mc_deprn_periods dp
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_member_asset_id
     and bk.set_of_books_id = p_set_of_books_id
     and bk.date_effective <= nvl(dp.period_close_date,sysdate)
     and nvl(bk.date_ineffective,sysdate) >= nvl(dp.period_close_date,sysdate)
     and dp.book_type_code = bk.book_type_code
     and dp.fiscal_year = h_fiscal_year - 1
     and dp.period_num = (select max(period_num) from fa_mc_deprn_periods dp1
                           where dp1.book_type_code = h_book_type_code
                             and dp1.fiscal_year = h_fiscal_year - 1
                             and dp1.set_of_books_id = p_set_of_books_id)
     and dp.set_of_books_id = p_set_of_books_id;

cursor GET_PERIOD is
  select period_counter + 1
    from fa_deprn_periods
   where book_type_code = h_book_type_code
     and fiscal_year = h_loop_end_year
     and period_num = h_loop_end_period;

cursor GET_PERIOD_MRC is
  select period_counter + 1
    from fa_mc_deprn_periods
   where book_type_code = h_book_type_code
     and fiscal_year = h_loop_end_year
     and period_num = h_loop_end_period
     and set_of_books_id = p_set_of_books_id;

--* Cursor for EOFY_RESERVE adjustment
cursor FA_RET_RSV is
  select sum(nvl(ret.reserve_retired,0) - nvl(ret.eofy_reserve,0))
    from fa_retirements ret
   where ret.book_type_code = h_book_type_code
     and ret.asset_id = h_member_asset_id
     and exists
         (select th1.transaction_header_id
            from fa_transaction_headers th1,
                 fa_deprn_periods dp1,
                 fa_deprn_periods dp3
           where th1.asset_id = ret.asset_id
             and dp1.book_type_code = h_book_type_code
             and dp1.fiscal_year =
                 (select dp2.fiscal_year
                    from fa_deprn_periods dp2
                   where dp2.book_type_code = dp1.book_type_code
                     and dp2.period_Counter = h_period_counter - 1)
             and dp1.period_num = 1
             and dp3.book_type_code = dp1.book_type_code
             and dp3.period_counter = h_period_counter - 1
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) >= dp1.calendar_period_open_date
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) <= dp3.calendar_period_close_date
             and th1.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT')
             and th1.transaction_header_id = ret.transaction_header_id_in);

cursor FA_RET_RSV_MRC is
  select sum(nvl(ret.reserve_retired,0) - nvl(ret.eofy_reserve,0))
    from fa_mc_retirements ret
   where ret.book_type_code = h_book_type_code
     and ret.asset_id = h_member_asset_id
     and ret.set_of_books_id = p_set_of_books_id
     and exists
         (select th1.transaction_header_id
            from fa_transaction_headers th1,
                 fa_deprn_periods dp1,
                 fa_deprn_periods dp3
           where th1.asset_id = ret.asset_id
             and dp1.book_type_code = h_book_type_code
             and dp1.fiscal_year =
                 (select dp2.fiscal_year
                    from fa_deprn_periods dp2
                   where dp2.book_type_code = dp1.book_type_code
                     and dp2.period_Counter = h_period_counter - 1)
             and dp1.period_num = 1
             and dp3.book_type_code = dp1.book_type_code
             and dp3.period_counter = h_period_counter - 1
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) >= dp1.calendar_period_open_date
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) <= dp3.calendar_period_close_date
             and th1.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT')
             and th1.transaction_header_id = ret.transaction_header_id_in);

cursor FA_ADJ_RESERVE is
   select sum(decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))
     from fa_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.adjustment_type = 'RESERVE'
      and adj.source_type_code = 'ADJUSTMENT'
      and nvl(adj.track_member_flag, 'N') = 'N' -- ENERGY
      and adj.period_counter_adjusted in
         (select dp2.period_counter
            from fa_deprn_periods dp1,
                 fa_deprn_periods dp2
           where dp1.book_type_code = adj.book_type_code
             and dp1.period_counter = h_period_counter - 1
             and dp2.book_type_code = dp1.book_type_code
             and dp2.fiscal_year = dp1.fiscal_year
             and dp2.period_counter <= dp1.period_counter);

cursor FA_ADJ_RESERVE_MRC is
   select sum(decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))
     from fa_mc_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.adjustment_type = 'RESERVE'
      and adj.source_type_code = 'ADJUSTMENT'
      and adj.set_of_books_id = p_set_of_books_id
      and nvl(adj.track_member_flag, 'N') = 'N'    -- ENERGY
      and adj.period_counter_adjusted in
         (select dp2.period_counter
            from fa_mc_deprn_periods dp1,
                 fa_mc_deprn_periods dp2
           where dp1.book_type_code = adj.book_type_code
             and dp1.period_counter = h_period_counter - 1
             and dp1.set_of_books_id = p_set_of_books_id
             and dp2.book_type_code = dp1.book_type_code
             and dp2.fiscal_year = dp1.fiscal_year
             and dp2.set_of_books_id = p_set_of_books_id
             and dp2.period_counter <= dp1.period_counter);

cursor ADDITION_RESERVE_YTD is
   select ds.deprn_reserve,
          ds.ytd_deprn
     from fa_deprn_summary ds
    where ds.book_type_code=h_book_type_code
      and ds.asset_id=h_member_asset_id
      and ds.deprn_source_code='BOOKS';

cursor ADDITION_RESERVE_YTD_MRC is
   select ds.deprn_reserve,
          ds.ytd_deprn
     from fa_mc_deprn_summary ds
    where ds.book_type_code=h_book_type_code
      and ds.asset_id=h_member_asset_id
      and ds.deprn_source_code='BOOKS'
      and ds.set_of_books_id=p_set_of_books_id;

cursor ADDITION_DATE is
  select nvl(amortization_start_date,transaction_date_entered)
    from fa_transaction_headers
   where transaction_type_code = 'ADDITION'
     and asset_id = h_member_asset_id;

--* Get latest transaction id for the member asset
cursor GET_LAST_TRANS_ID(p_member_asset_id number, p_trans_id number) is
  select TH.TRANSACTION_HEADER_ID
    from FA_TRANSACTION_HEADERS TH,
         FA_TRANSACTION_HEADERS TH1,
         FA_CALENDAR_PERIODS DP,
         FA_FISCAL_YEAR FY
   where DP.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
     and FY.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
     and TH.asset_id = p_member_asset_id
     and TH.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN', 'TRANSFER', 'TRANSFER IN/VOID',
                                          'RECLASS', 'UNIT ADJUSTMENT','REINSTATEMENT')
     and nvl(TH.amortization_start_date,TH.transaction_date_entered) between DP.start_date and DP.end_date
     and DP.start_date >= FY.start_date
     and DP.end_date <= FY.end_date
     and TH1.transaction_header_id = p_trans_id
     and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) between DP.start_date and DP.end_date
     and nvl(TH.amortization_start_date,TH.transaction_date_entered) <= nvl(TH1.amortization_start_date,TH1.transaction_date_entered)
order by nvl(TH.amortization_start_date,TH.transaction_date_entered), TH.transaction_header_id desc;

begin

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, '+++ populate_previous_rows: Just Started +++', 'Parameters', p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add(l_calling_fn, 'p_book:group:period_ctr:fiscal_yr:trans_hdr_id:mrc_type',
         p_book_type_code||':'||p_group_asset_id||':'||p_period_counter||':'||p_fiscal_year||':'||p_transaction_header_id||':'||p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
end if;


if (nvl(fa_cache_pkg.fazcdrd_record.allow_reduction_rate_flag, 'N') = 'N') then
open c_get_member_asset_id;
fetch c_get_member_asset_id into l_member_asset_id;
close c_get_member_asset_id;
if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'l_member_asset_id', l_member_asset_id, p_log_level_rec => p_log_level_rec);
end if;
end if;


h_book_type_code := p_book_type_code;
h_group_asset_id := p_group_asset_id;
h_period_counter := p_period_counter;
h_fiscal_year := p_fiscal_year;
h_loop_end_year := p_loop_end_year;
h_loop_end_period := p_loop_end_period;

/* Apply MRC related feature */

-- Query necessary data from table and insert those into FA_TRACKING_TEMP

if p_mrc_sob_type_code <> 'R' then

  if h_loop_end_year is not null and h_loop_end_period is not null then
  /* Get period counter of the next period of loop end */
    open GET_PERIOD;
    fetch GET_PERIOD into h_loop_period_counter;
    if GET_PERIOD%NOTFOUND then
      close GET_PERIOD;
       raise populate_previous_rows_err;
    end if;
    close GET_PERIOD;
  else
    h_loop_period_counter := h_period_counter;
  end if;

  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'h_loop_period_counter', h_loop_period_counter, p_log_level_rec => p_log_level_rec);
  end if;

  if nvl(p_calling_fn,'OTHER') = 'TRACK_ASSETS' then -- Get group level info
    select deprn_method_code,life_in_months
      into h_method_code,h_life_in_months
      from fa_books
     where book_type_code = h_book_type_code
       and asset_id = h_group_asset_id
       and date_ineffective is null;
  end if;

  i := 0;
  h_adj_asset_id := NULL;
  h_adj_trans_type := NULL;

  if p_transaction_header_id is not null then
   open GET_TRANS_DATE;
   fetch GET_TRANS_DATE into h_transaction_date, h_adj_asset_id, h_adj_trans_type;
   close GET_TRANS_DATE;
  else
   open GET_PERD_CLOSE_DATE;
   fetch GET_PERD_CLOSE_DATE into h_transaction_date;
   close GET_PERD_CLOSE_DATE;
  end if;

  if h_transaction_date is null then -- This is a case this process is called to process allocation
                                     -- other than the transaction.need to get period end date for
                                     -- transaction date
   h_perd_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
   if h_perd_per_fiscal_year is null then
      if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
         raise populate_previous_rows_err;
      end if;
      h_perd_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
   end if;

   select DP.end_date into h_transaction_date
     from FA_FISCAL_YEAR FY,
          FA_CALENDAR_PERIODS DP
    where DP.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
      and DP.period_num = p_period_counter - p_fiscal_year*h_perd_per_fiscal_year
      and FY.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
      and FY.fiscal_year = p_fiscal_year
      and DP.start_date >= FY.start_date
      and DP.end_date <= FY.end_date;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'h_transaction_date from table', h_transaction_date, p_log_level_rec => p_log_level_rec);
   end if;
--   h_transaction_date := sysdate;
  end if;

  For pop_mem in ALL_MEMBERS(h_transaction_date) loop

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) for member loop starts +++ (transaction_date)', h_transaction_date);
     fa_debug_pkg.add(l_calling_fn, 'pop_mem.member_asset', pop_mem.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   h_member_asset_id := pop_mem.asset_id;

-- Check if selected member asset is the asset to be processed or not.
-- Support backdated addition with reserve case.
   open ADDITION_DATE;
   fetch ADDITION_DATE into h_amort_addition_date;
   if ADDITION_DATE%NOTFOUND then
     close ADDITION_DATE;
     raise populate_previous_rows_err;
   end if;
   close ADDITION_DATE;

   if h_amort_addition_date > h_transaction_date then -- Addition start date is later than this period
     open ADDITION_RESERVE_YTD;
     fetch ADDITION_RESERVE_YTD into h_temp_deprn_reserve, h_temp_ytd_deprn;
     close ADDITION_RESERVE_YTD;
     if nvl(h_temp_deprn_reserve,0) <> 0 then
       goto skip_process;
     end if;
   end if;

-- Query Retirement Related Amounts
   open FA_RET_RSV;
   fetch FA_RET_RSV into h_eofy_reserve_adjustment;
   close FA_RET_RSV;

-- Query Reserve Adjustment
   open FA_ADJ_RESERVE;
   fetch FA_ADJ_RESERVE into h_adj_reserve;
   close FA_ADJ_RESERVE;

   h_eofy_reserve_adjustment := nvl(h_eofy_reserve_adjustment,0);

-- Check if the passed transaction is the transaction for this member asset
   if nvl(h_adj_asset_id,-99) <> h_member_asset_id then
     open GET_LAST_TRANS_ID(h_member_asset_id, p_transaction_header_id);
     fetch GET_LAST_TRANS_ID into h_last_trans_id;
     close GET_LAST_TRANS_ID;
   else
     h_last_trans_id := p_transaction_header_id;
   end if;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'h_eofy_reserve_adjustment', h_eofy_reserve_adjustment, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'h_last_trans_id', h_last_trans_id, p_log_level_rec => p_log_level_rec);
   end if;

   open ALL_MEMBER_FOR_ADJ_MODE(h_member_asset_id);
   fetch ALL_MEMBER_FOR_ADJ_MODE into h_cost, h_adjusted_cost, h_recoverable_cost,
                                        h_salvage_value, h_adjusted_recoverable_cost,
                                        h_pc_fully_reserved,
                                        h_pc_fully_retired,
                                        h_eofy_reserve,
                                        h_deprn_reserve, h_ytd_deprn,
                                        h_bonus_deprn_reserve, h_bonus_ytd_deprn, h_eop_fiscal_year;
   if ALL_MEMBER_FOR_ADJ_MODE%NOTFOUND then

     open ALL_MEMBER_FOR_ADDITION(h_member_asset_id);
     fetch ALL_MEMBER_FOR_ADDITION into h_cost, h_adjusted_cost, h_recoverable_cost,
                                        h_salvage_value, h_adjusted_recoverable_cost,
                                        h_pc_fully_reserved,
                                        h_pc_fully_retired,
                                        h_eofy_reserve,
                                        h_deprn_reserve, h_ytd_deprn,
                                        h_bonus_deprn_reserve, h_bonus_ytd_deprn, h_eop_fiscal_year;
     if ALL_MEMBER_FOR_ADDITION%NOTFOUND then
       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'No rows in FA_BOOKS of member asset', h_member_asset_id, p_log_level_rec => p_log_level_rec);
       end if;
     else
       i := i + 1;
       p_track_member_table(i).group_asset_id := h_group_asset_id;
       p_track_member_table(i).member_asset_id := h_member_asset_id;
       p_track_member_table(i).set_of_books_id := p_set_of_books_id;
       p_track_member_table(i).period_counter := h_period_counter;
       p_track_member_table(i).fiscal_year := h_fiscal_year;
       p_track_member_table(i).cost := 0;
       p_track_member_table(i).salvage_value := 0;
       p_track_member_table(i).adjusted_cost := 0;
       p_track_member_table(i).recoverable_cost := 0;
       p_track_member_table(i).adjusted_recoverable_cost := 0;
       p_track_member_table(i).deprn_reserve := nvl(h_deprn_reserve,0);
       p_track_member_table(i).ytd_deprn := nvl(h_ytd_deprn,0);
       p_track_member_table(i).bonus_deprn_reserve := 0;
       p_track_member_table(i).bonus_ytd_deprn := 0;
       p_track_member_table(i).eofy_reserve := nvl(h_deprn_reserve,0) - nvl(h_ytd_deprn,0);
       p_track_member_table(i).eofy_recoverable_cost := 0;
       p_track_member_table(i).eop_recoverable_cost := 0;
       p_track_member_table(i).eofy_salvage_value := 0;
       p_track_member_table(i).eop_salvage_value := 0;

       /* Populate index table */
       put_track_index(h_period_counter, h_member_asset_id,h_group_asset_id,p_set_of_books_id,i,p_log_level_rec);

       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++ Stored values for added member asset indicator', i, p_log_level_rec => p_log_level_rec);
         if not display_debug_message2(i => i, p_calling_fn=> l_calling_fn,
p_log_level_rec => p_log_level_rec) then
           fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
         end if;
       end if;
     end if;
     close ALL_MEMBER_FOR_ADDITION;
   elsif ((nvl(p_allocate_to_fully_ret_flag,'N') = 'N' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'N' and
        nvl(h_pc_fully_retired,h_period_counter) >= h_period_counter and
        nvl(h_pc_fully_reserved,h_period_counter+1) > h_period_counter)
               or
       (nvl(p_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'N' and
        nvl(h_pc_fully_reserved,h_period_counter+1) > h_period_counter)
               or
       (nvl(p_allocate_to_fully_ret_flag,'N') = 'N' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'Y' and
        nvl(h_pc_fully_retired,h_period_counter) >= h_period_counter)
               Or
       (nvl(p_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'Y'))

      then
       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('fa_track_member_pvt', '++ In case when member asset is queried ++ ', i, p_log_level_rec => p_log_level_rec);
       end if;
       if h_eop_fiscal_year = h_fiscal_year then
         h_eofy_reserve := nvl(h_eofy_reserve,0) + nvl(h_eofy_reserve_adjustment,0) + nvl(h_adj_reserve,0);
       end if;

       -- Try to query eofy_reserve from memory
       if (nvl(h_adj_asset_id,-99) <> h_member_asset_id and
          nvl(h_adj_trans_type,'NULL') <> 'ADDITION' )then

        For j in 1 .. p_track_member_eofy_table.COUNT loop
         if p_track_member_eofy_table(j).group_asset_id = h_group_asset_id and
            p_track_member_eofy_table(j).member_asset_id = h_member_asset_id and
            nvl(p_track_member_eofy_table(j).set_of_books_id,-99) = nvl(p_set_of_books_id, -99) then
--            p_track_member_eofy_table(j).fiscal_year = h_fiscal_year then
           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'p_track_member_eofy_table('||j||').cost:salvage:rec_cost:adj_cost:eofy_reserve',
                                             p_track_member_eofy_table(j).cost||':'||p_track_member_eofy_table(j).salvage_value||':'||
                                             p_track_member_eofy_table(j).recoverable_cost||':'||p_track_member_eofy_table(j).adjusted_cost||':'||
                                             p_track_member_eofy_table(j).eofy_reserve);
           end if;
           h_cost := p_track_member_eofy_table(j).cost;
           h_salvage_value := p_track_member_eofy_table(j).salvage_value;
           h_recoverable_cost := p_track_member_eofy_table(j).recoverable_cost;
           h_adjusted_cost := p_track_member_eofy_table(j).adjusted_cost;
           h_eofy_reserve := p_track_member_eofy_table(j).eofy_reserve;
           exit;
         end if;
        END LOOP;
       end if; -- if this processed transactin is addition of this member...

       i := i + 1;

       open MEMBER_START_PERIOD;
       fetch MEMBER_START_PERIOD into h_eofy_rec_cost,h_eofy_salvage_value;
       close MEMBER_START_PERIOD;

       -- Set p_track_member_type
       p_track_member_table(i).group_asset_id := h_group_asset_id;
       p_track_member_table(i).member_asset_id := h_member_asset_id;
       p_track_member_table(i).set_of_books_id := p_set_of_books_id;
       p_track_member_table(i).period_counter := h_period_counter;
       p_track_member_table(i).fiscal_year := h_fiscal_year;
       p_track_member_table(i).cost := h_cost;
       p_track_member_table(i).salvage_value := h_salvage_value;
       p_track_member_table(i).adjusted_cost := h_adjusted_cost;
       p_track_member_table(i).recoverable_cost := h_recoverable_cost;
       p_track_member_table(i).adjusted_recoverable_cost := h_adjusted_recoverable_cost;
       p_track_member_table(i).deprn_reserve := h_deprn_reserve;
       p_track_member_table(i).ytd_deprn := h_ytd_deprn;
       p_track_member_table(i).bonus_deprn_reserve := h_bonus_deprn_reserve;
       p_track_member_table(i).bonus_ytd_deprn := h_bonus_ytd_deprn;
       p_track_member_table(i).eofy_reserve := h_eofy_reserve; -- + h_eofy_reserve_adjustment;
       p_track_member_table(i).eofy_recoverable_cost := h_eofy_rec_cost;
       p_track_member_table(i).eop_recoverable_cost := h_recoverable_cost;
       p_track_member_table(i).eofy_salvage_value := h_eofy_salvage_value;
       p_track_member_table(i).eop_salvage_value := h_salvage_value;

       /* Populate index table */
       put_track_index(h_period_counter, h_member_asset_id,h_group_asset_id,p_set_of_books_id,i,p_log_level_rec);

       if nvl(h_pc_fully_reserved,h_period_counter+1) > h_period_counter then
         p_track_member_table(i).fully_reserved_flag := 'N';
       else
         p_track_member_table(i).fully_reserved_flag := 'Y';
       end if;
       if nvl(h_pc_fully_retired,h_period_counter+1) > h_period_counter then
         p_track_member_table(i).fully_retired_flag := 'N';
       else
         p_track_member_table(i).fully_retired_flag := 'Y';
       end if;

     end if; -- This is an asset to be processed
     close ALL_MEMBER_FOR_ADJ_MODE;
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++ Stored values indicator', i, p_log_level_rec => p_log_level_rec);
       if i > 0 then
        if not display_debug_message2(i => i, p_calling_fn=> l_calling_fn,
p_log_level_rec => p_log_level_rec) then
          fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
        end if;
       end if;
     end if;
<<skip_process>>
    null;

  end loop;

else -- For Reporting Book

  if h_loop_end_year is not null and h_loop_end_period is not null then
    /* Get period counter of the next period of loop end */
    open GET_PERIOD_MRC;
    fetch GET_PERIOD_MRC into h_loop_period_counter;
    if GET_PERIOD_MRC%NOTFOUND then
      close GET_PERIOD_MRC;
       raise populate_previous_rows_err;
    end if;
    close GET_PERIOD_MRC;
  else
    h_loop_period_counter := h_period_counter;
  end if;

  if nvl(p_calling_fn,'OTHER') = 'TRACK_ASSETS' then -- Get group level info
    select deprn_method_code,life_in_months
      into h_method_code,h_life_in_months
      from fa_mc_books
     where book_type_code = h_book_type_code
       and asset_id = h_group_asset_id
       and date_ineffective is null
       and set_of_books_id = p_set_of_books_id;
  end if;

  i := 0;
  h_adj_asset_id := NULL;
  h_adj_trans_type := NULL;

  if p_transaction_header_id is not null then
   open GET_TRANS_DATE;
   fetch GET_TRANS_DATE into h_transaction_date,h_adj_asset_id,h_adj_trans_type;
   close GET_TRANS_DATE;
  else
   open GET_PERD_CLOSE_DATE_MRC;
   fetch GET_PERD_CLOSE_DATE_MRC into h_transaction_date;
   close GET_PERD_CLOSE_DATE_MRC;
  end if;

  if h_transaction_date is null then -- This is a case this process is called to process allocation
                                     -- other than the transaction.need to get period end date for
                                     -- transaction date
   h_perd_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
   if h_perd_per_fiscal_year is null then
      if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
         raise populate_previous_rows_err;
      end if;
      h_perd_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
   end if;

   select DP.end_date into h_transaction_date
     from FA_FISCAL_YEAR FY,
          FA_CALENDAR_PERIODS DP
    where DP.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
      and DP.period_num = p_period_counter - p_fiscal_year*h_perd_per_fiscal_year
      and FY.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
      and FY.fiscal_year = p_fiscal_year
      and DP.start_date >= FY.start_date
      and DP.end_date <= FY.end_date;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'h_transaction_date from table', h_transaction_date, p_log_level_rec => p_log_level_rec);
   end if;
--   h_transaction_date := sysdate;
  end if;

  For pop_mem in ALL_MEMBERS_MRC(h_transaction_date) loop

    h_member_asset_id := pop_mem.asset_id;

    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) for member loop starts +++ (Reporting Book/transaction_date)',
                                                                                                    h_transaction_date);
      fa_debug_pkg.add(l_calling_fn, 'pop_mem.member_asset', pop_mem.asset_id, p_log_level_rec => p_log_level_rec);
    end if;

-- Check if selected member asset is the asset to be processed or not.
-- Support backdated addition with reserve case.
   open ADDITION_DATE;
   fetch ADDITION_DATE into h_amort_addition_date;
   if ADDITION_DATE%NOTFOUND then
     close ADDITION_DATE;
     raise populate_previous_rows_err;
   end if;
   close ADDITION_DATE;

   if h_amort_addition_date > h_transaction_date then -- Addition start date is later than this period
     open ADDITION_RESERVE_YTD;
     fetch ADDITION_RESERVE_YTD into h_temp_deprn_reserve, h_temp_ytd_deprn;
     close ADDITION_RESERVE_YTD;
     if nvl(h_temp_deprn_reserve,0) <> 0 then
       goto skip_process;
     end if;
   end if;

-- Query Retirement Related Amounts
   open FA_RET_RSV_MRC;
   fetch FA_RET_RSV_MRC into h_eofy_reserve_adjustment;
   close FA_RET_RSV_MRC;

-- Query Reserve Adjustment
   open FA_ADJ_RESERVE_MRC;
   fetch FA_ADJ_RESERVE_MRC into h_adj_reserve;
   close FA_ADJ_RESERVE_MRC;

   h_eofy_reserve_adjustment := nvl(h_eofy_reserve_adjustment,0);
   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'h_eofy_reserve_adjustment', h_eofy_reserve_adjustment, p_log_level_rec => p_log_level_rec);
   end if;



    open ALL_MEMBER_FOR_ADJ_MODE_MRC(h_member_asset_id);
    fetch ALL_MEMBER_FOR_ADJ_MODE_MRC into h_cost, h_adjusted_cost, h_recoverable_cost,
                                        h_salvage_value, h_adjusted_recoverable_cost,
                                        h_pc_fully_reserved,
                                        h_pc_fully_retired,
                                        h_eofy_reserve,
                                        h_deprn_reserve, h_ytd_deprn,
                                        h_bonus_deprn_reserve, h_bonus_ytd_deprn, h_eop_fiscal_year;
   if ALL_MEMBER_FOR_ADJ_MODE_MRC%NOTFOUND then

     open ALL_MEMBER_FOR_ADDITION_MRC(h_member_asset_id);
     fetch ALL_MEMBER_FOR_ADDITION_MRC into h_cost, h_adjusted_cost, h_recoverable_cost,
                                        h_salvage_value, h_adjusted_recoverable_cost,
                                        h_pc_fully_reserved,
                                        h_pc_fully_retired,
                                        h_eofy_reserve,
                                        h_deprn_reserve, h_ytd_deprn,
                                        h_bonus_deprn_reserve, h_bonus_ytd_deprn, h_eop_fiscal_year;
     if ALL_MEMBER_FOR_ADDITION_MRC%NOTFOUND then
       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'No rows in FA_BOOKS(Reporting Book) of member asset', h_member_asset_id);
       end if;
       i := i + 1;
       p_track_member_table(i).group_asset_id := h_group_asset_id;
       p_track_member_table(i).member_asset_id := h_member_asset_id;
       p_track_member_table(i).set_of_books_id := p_set_of_books_id;
       p_track_member_table(i).period_counter := h_period_counter;
       p_track_member_table(i).fiscal_year := h_fiscal_year;
       p_track_member_table(i).cost := 0;
       p_track_member_table(i).salvage_value := 0;
       p_track_member_table(i).adjusted_cost := 0;
       p_track_member_table(i).recoverable_cost := 0;
       p_track_member_table(i).adjusted_recoverable_cost := 0;
       p_track_member_table(i).deprn_reserve := nvl(h_deprn_reserve,0);
       p_track_member_table(i).ytd_deprn := nvl(h_ytd_deprn,0);
       p_track_member_table(i).bonus_deprn_reserve := 0;
       p_track_member_table(i).bonus_ytd_deprn := 0;
       p_track_member_table(i).eofy_reserve := nvl(h_deprn_reserve,0) - nvl(h_ytd_deprn,0);
       p_track_member_table(i).eofy_recoverable_cost := 0;
       p_track_member_table(i).eop_recoverable_cost := 0;
       p_track_member_table(i).eofy_salvage_value := 0;
       p_track_member_table(i).eop_salvage_value := 0;

       /* Populate index table */
       put_track_index(h_period_counter, h_member_asset_id,h_group_asset_id,p_set_of_books_id,i, p_log_level_rec);

       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++ Stored values indicator', i, p_log_level_rec => p_log_level_rec);
         if not display_debug_message2(i => i, p_calling_fn=> l_calling_fn,
p_log_level_rec=> p_log_level_rec) then
           fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
         end if;
       end if;
     end if;
     close ALL_MEMBER_FOR_ADDITION_MRC;

   elsif ((nvl(p_allocate_to_fully_ret_flag,'N') = 'N' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'N' and
        nvl(h_pc_fully_retired,h_period_counter+1) > h_period_counter and
        nvl(h_pc_fully_reserved,h_period_counter+1) > h_period_counter)
               or
       (nvl(p_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'N' and
        nvl(h_pc_fully_reserved,h_period_counter+1) > h_period_counter)
               or
       (nvl(p_allocate_to_fully_ret_flag,'N') = 'N' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'Y' and
        nvl(h_pc_fully_retired,h_period_counter+1) > h_period_counter)
               Or
       (nvl(p_allocate_to_fully_ret_flag,'N') = 'Y' and nvl(p_allocate_to_fully_rsv_flag,'N') = 'Y'))

      then
       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('fa_track_member_pvt', '++ In case when member asset is queried ++ ', i, p_log_level_rec => p_log_level_rec);
       end if;
       if h_eop_fiscal_year = h_fiscal_year then
         h_eofy_reserve := nvl(h_eofy_reserve,0) + nvl(h_eofy_reserve_adjustment,0) + nvl(h_adj_reserve,0);
       end if;

    -- Try to query eofy_reserve from memory
       if (nvl(h_adj_asset_id,-99) <> h_member_asset_id and
          nvl(h_adj_trans_type,'NULL') <> 'ADDITION' )then

        For j in 1 .. p_track_member_eofy_table.COUNT loop
         if p_track_member_eofy_table(j).group_asset_id = h_group_asset_id and
            p_track_member_eofy_table(j).member_asset_id = h_member_asset_id and
            nvl(p_track_member_eofy_table(j).set_of_books_id, -99) = nvl(p_set_of_books_id, -99) then
--            p_track_member_eofy_table(j).fiscal_year = h_fiscal_year then
           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'p_track_member_eofy_table('||j||').cost:salvage:rec_cost:adj_cost:eofy_reserve',
                                             p_track_member_eofy_table(j).cost||':'||p_track_member_eofy_table(j).salvage_value||':'||
                                             p_track_member_eofy_table(j).recoverable_cost||':'||p_track_member_eofy_table(j).adjusted_cost||':'||
                                             p_track_member_eofy_table(j).eofy_reserve);
           end if;
           h_cost := p_track_member_eofy_table(j).cost;
           h_salvage_value := p_track_member_eofy_table(j).salvage_value;
           h_recoverable_cost := p_track_member_eofy_table(j).recoverable_cost;
           h_adjusted_cost := p_track_member_eofy_table(j).adjusted_cost;
           h_eofy_reserve := p_track_member_eofy_table(j).eofy_reserve;
           exit;
         end if;
        END LOOP;
       end if;

       i := i + 1;

       open MEMBER_START_PERIOD_MRC;
       fetch MEMBER_START_PERIOD_MRC into h_eofy_rec_cost,h_eofy_salvage_value;
       close MEMBER_START_PERIOD_MRC;

       -- Set p_track_member_type
       p_track_member_table(i).group_asset_id := h_group_asset_id;
       p_track_member_table(i).member_asset_id := pop_mem.asset_id;
       p_track_member_table(i).set_of_books_id := p_set_of_books_id;
       p_track_member_table(i).period_counter := h_period_counter;
       p_track_member_table(i).fiscal_year := h_fiscal_year;
       p_track_member_table(i).cost := h_cost;
       p_track_member_table(i).salvage_value := h_salvage_value;
       p_track_member_table(i).adjusted_cost := h_adjusted_cost;
       p_track_member_table(i).recoverable_cost := h_recoverable_cost;
       p_track_member_table(i).adjusted_recoverable_cost := h_adjusted_recoverable_cost;
       p_track_member_table(i).deprn_reserve := h_deprn_reserve;
       p_track_member_table(i).ytd_deprn := h_ytd_deprn;
       p_track_member_table(i).bonus_deprn_reserve := h_bonus_deprn_reserve;
       p_track_member_table(i).bonus_ytd_deprn := h_bonus_ytd_deprn;
       p_track_member_table(i).eofy_reserve := h_eofy_reserve; -- + h_eofy_reserve_adjustment;
       p_track_member_table(i).eofy_recoverable_cost := h_eofy_rec_cost;
       p_track_member_table(i).eop_recoverable_cost := h_recoverable_cost;
       p_track_member_table(i).eofy_salvage_value := h_eofy_salvage_value;
       p_track_member_table(i).eop_salvage_value := h_salvage_value;

       /* Populate index table */
       put_track_index(h_period_counter,pop_mem.asset_id,h_group_asset_id,p_set_of_books_id,i,p_log_level_rec);


       if nvl(h_pc_fully_reserved,h_period_counter+1) > h_period_counter then
         p_track_member_table(i).fully_reserved_flag := 'N';
       else
         p_track_member_table(i).fully_reserved_flag := 'Y';
       end if;
       if nvl(h_pc_fully_retired,h_period_counter+1) > h_period_counter then
         p_track_member_table(i).fully_retired_flag := 'N';
       else
         p_track_member_table(i).fully_retired_flag := 'Y';
       end if;

     end if; -- This is an asset to be processed
     close ALL_MEMBER_FOR_ADJ_MODE_MRC;
     if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '+++ Stored values (For MRC book) indicator ', i);
         if i > 0 then
           if not display_debug_message2(i => i, p_calling_fn => l_calling_fn, p_log_level_rec=> p_log_level_rec) then
             fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
           end if;
         end if;
     end if;
   <<skip_process>>
     null;

  end loop;

end if; -- Primary Book or Reporting Book?

return(true);

exception
  when populate_previous_rows_err then
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

end populate_previous_rows;

--+=====================================================================
-- Function: get_member_at_start
--
--  This function will be called from adjustment engine
--  to poulate the member assets at the time of running faxcde
--  Using transaction_date_entered passed from engine,
--  member assets are defined.
--  And populate the necessary info into FA_TRACK_MEMBER table.
--
--+=====================================================================

FUNCTION get_member_at_start(p_period_rec                 in FA_API_TYPES.period_rec_type,
                             p_trans_rec                  in FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec              in FA_API_TYPES.asset_hdr_rec_type,
                             p_asset_fin_rec              in FA_API_TYPES.asset_fin_rec_type,
                             p_dpr_in                     in FA_STD_TYPES.dpr_struct,
                             p_mrc_sob_type_code          in varchar2 default 'N', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

--* Host related variables
h_book_type_code        varchar2(30);
h_group_asset_id        number;
h_set_of_books_id       number;

h_period_counter        number;
h_fiscal_year           number;
h_period_num            number;

h_fiscal_year_name      varchar2(30);
h_calendar_type         varchar2(15);

h_member_asset_id       number;
i                       number;

h_deprn_method_code     varchar2(15);
h_life_in_months        number;
h_apply_reduction_flag  varchar2(1);
h_deprn_source_code     varchar2(30);
h_ytd_deprn             number;
h_deprn_reserve         number;
h_group_deprn_basis     varchar2(4);
h_eofy_flag             varchar2(1);
h_period_per_fiscal_year number;
h_last_trans_id         number;

h_trans_exists_flag     boolean := FALSE;
h_transaction_header_id number;
h_delta_cost            number;
h_delta_recoverable_cost number;
h_new_limit_type        varchar2(15);
h_old_limit_type        varchar2(15);
h_new_deprn_limit       number;
h_new_deprn_limit_amount number;
h_depreciate_flag       varchar2(3);

h_old_cost              number;
h_old_salvage_value     number;
h_old_recoverable_cost  number;
h_old_adjusted_rec_cost number;

h_bonus_deprn_reserve   number;
h_bonus_ytd_deprn       number;

l_new_ind               number;
h_temp_limit_amount     number;

h_adj_cost              number;
h_adj_rec_cost          number;
h_adj_salvage_value     number;

h_new_cost              number;
h_new_recoverable_cost  number;
h_new_salvage_value     number;
h_new_adjusted_rec_cost number;
h_eofy_reserve          number;

--* Recalculation Start Period
h_start_fiscal_year     number;
h_start_period_num      number;
h_start_period_counter  number;

h_fully_reserved_flag   varchar2(1);
h_fully_retired_flag    varchar2(1);

--* Reclass Check variable
h_old_group_asset_id    number;
h_new_group_asset_id    number;
h_mem_trans_thid        number;

l_calling_fn            varchar2(45) := 'fa_track_member_pvt.get_member_at_start';
get_member_at_start_err           exception;

--* Structure to call Deprn Basis Rule
fa_rule_in      fa_std_types.fa_deprn_rule_in_struct;
fa_rule_out     fa_std_types.fa_deprn_rule_out_struct;

--* Get all transaction headers exists until the specified period
cursor ALL_TRANS_IN_PERIOD(p_fiscal_year  number, p_period_num number,p_member_asset_id number) is
  select TH.TRANSACTION_HEADER_ID
    from FA_TRANSACTION_HEADERS TH,
         FA_FISCAL_YEAR FY,
         FA_CALENDAR_PERIODS DP
   where DP.calendar_type = h_calendar_type
     and DP.period_num = p_period_num
     and FY.fiscal_year_name = h_fiscal_year_name
     and FY.fiscal_year = p_fiscal_year
     and TH.asset_id = p_member_asset_id
     and TH.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN', 'TRANSFER', 'TRANSFER IN/VOID',
                                          'RECLASS', 'UNIT ADJUSTMENT','REINSTATEMENT')
     and nvl(th.amortization_start_date,TH.transaction_date_entered) <= DP.end_date
     and DP.start_date >= FY.start_date
     and DP.end_date <= FY.end_date
order by nvl(th.amortization_start_date,TH.transaction_date_entered), TH.transaction_header_id asc;

--* Get delta between the amounts before the transaction and after the transaction
cursor GET_DELTA_FOR_MEMBER(p_member_asset_id number, p_transaction_header_id number) is
  select BK_IN.COST - nvl(BK_OUT.COST,0) delta_cost,
         BK_IN.RECOVERABLE_COST - nvl(BK_OUT.RECOVERABLE_COST,0) delta_rec_cost,
         BK_IN.DEPRN_LIMIT_TYPE new_limit_type,
         BK_OUT.DEPRN_LIMIT_TYPE old_limit_type,
         BK_IN.ALLOWED_DEPRN_LIMIT new_deprn_limit,
         BK_IN.ALLOWED_DEPRN_LIMIT_AMOUNT new_deprn_limit_amount,
         BK_IN.DEPRECIATE_FLAG depreciate_flag
    from FA_BOOKS BK_IN,
         FA_BOOKS BK_OUT
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.asset_id = h_member_asset_id
     and BK_IN.transaction_header_id_in = p_transaction_header_id
     and BK_OUT.book_type_code(+) = BK_IN.book_type_code
     and BK_OUT.asset_id(+) = BK_IN.asset_id
     and BK_OUT.transaction_header_id_out(+) = BK_IN.transaction_header_id_in;

cursor GET_DELTA_FOR_MEMBER_MRC(p_member_asset_id number, p_transaction_header_id number) is
  select BK_IN.COST - nvl(BK_OUT.COST,0) delta_cost,
         BK_IN.RECOVERABLE_COST - nvl(BK_OUT.RECOVERABLE_COST,0) delta_rec_cost,
         BK_IN.DEPRN_LIMIT_TYPE new_limit_type,
         BK_OUT.DEPRN_LIMIT_TYPE old_limit_type,
         BK_IN.ALLOWED_DEPRN_LIMIT new_deprn_limit,
         BK_IN.ALLOWED_DEPRN_LIMIT_AMOUNT old_deprn_limit,
         BK_IN.DEPRECIATE_FLAG depreciate_flag
    from FA_MC_BOOKS BK_IN,
         FA_MC_BOOKS BK_OUT
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.asset_id = h_member_asset_id
     and BK_IN.transaction_header_id_in = p_transaction_header_id
     and BK_IN.set_of_books_id = h_set_of_books_id
     and BK_OUT.book_type_code(+) = BK_IN.book_type_code
     and BK_OUT.asset_id(+) = BK_IN.asset_id
     and BK_OUT.transaction_header_id_out(+) = BK_IN.transaction_header_id_in
     and BK_OUT.set_of_books_id = h_set_of_books_id;

-- cursor to get all members at the specified period
cursor ALL_MEMBERS_AT_AMORT(p_fiscal_year number,p_period_num number) is
select distinct bk.asset_id member_asset_id, ad.asset_number
  from fa_books bk,
       fa_additions_b ad
 where bk.book_type_code = h_book_type_code
   and bk.group_asset_id = h_group_asset_id
   and bk.depreciate_flag = 'YES'
   and exists
         (select TH1.TRANSACTION_HEADER_ID
            from FA_TRANSACTION_HEADERS TH1,
                 FA_CALENDAR_PERIODS DP1,
                 FA_FISCAL_YEAR FY
           where TH1.book_type_code = BK.book_type_code
             and DP1.calendar_type = h_calendar_type
             and DP1.period_num = p_period_num
             and FY.fiscal_year_name = h_fiscal_year_name
             and FY.fiscal_year = p_fiscal_year
             and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) <= DP1.end_date
             and DP1.end_date <= FY.end_date
             and BK.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID)
   and ad.asset_id = bk.asset_id
   and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number asc;

cursor ALL_MEMBERS_AT_AMORT_MRC(p_fiscal_year number,p_period_num number) is
select distinct bk.asset_id member_asset_id, ad.asset_number
  from fa_mc_books bk,
       fa_additions_b ad
 where bk.book_type_code = h_book_type_code
   and bk.group_asset_id = h_group_asset_id
   and bk.depreciate_flag = 'YES'
   and bk.set_of_books_id = h_set_of_books_id
   and exists
         (select TH1.TRANSACTION_HEADER_ID
            from FA_TRANSACTION_HEADERS TH1,
                 FA_CALENDAR_PERIODS DP1,
                 FA_FISCAL_YEAR FY
           where TH1.book_type_code = BK.book_type_code
             and DP1.calendar_type = h_calendar_type
             and DP1.period_num = p_period_num
             and FY.fiscal_year_name = h_fiscal_year_name
             and FY.fiscal_year = p_fiscal_year
             and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) <= DP1.end_date
             and DP1.end_date <= FY.end_date
             and BK.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID)
   and ad.asset_id = bk.asset_id
   and ad.asset_type = 'CAPITALIZED'
   order by ad.asset_number asc;

cursor RECLASS_TRANS_CHECK(p_member_asset_id number,p_thid number) is
  select BK_IN.group_asset_id
    from fa_books BK_IN
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.asset_id = p_member_asset_id
     and BK_IN.transaction_header_id_in = p_thid;

cursor RECLASS_TRANS_CHECK_MRC(p_member_asset_id number,p_thid number) is
  select BK_IN.group_asset_id
    from fa_mc_books BK_IN
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.asset_id = p_member_asset_id
     and BK_IN.transaction_header_id_in = p_thid
     and BK_IN.set_of_books_id = h_set_of_books_id;

cursor GET_RESERVE_AT_ADDITION(p_asset_id number, p_period_counter number) is
  select deprn_source_code,
         ytd_deprn,
         deprn_reserve
    from fa_deprn_summary
   where book_type_code = h_book_type_code
     and asset_id = p_asset_id
     and period_counter = p_period_counter;

cursor GET_RESERVE_AT_ADDITION_MRC(p_asset_id number, p_period_counter number) is
  select deprn_source_code,
         ytd_deprn,
         deprn_reserve
    from fa_mc_deprn_summary
   where book_type_code = h_book_type_code
     and asset_id = p_asset_id
     and period_counter = p_period_counter
     and set_of_books_id = h_set_of_books_id;

begin

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, '+++ Get Member at Start ++ started', 'Parameters', p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add(l_calling_fn, 'book_type_code:group_asset_id:mem_thid',
                           p_asset_hdr_rec.book_type_code||':'||p_asset_hdr_rec.asset_id||':'||p_trans_rec.member_transaction_header_id, p_log_level_rec => p_log_level_rec);
end if;

p_track_member_table.delete;
p_track_mem_index_table.delete;

h_book_type_code := p_asset_hdr_rec.book_type_code;
h_group_asset_id := p_asset_hdr_rec.asset_id;
h_start_fiscal_year := p_dpr_in.y_begin;
h_start_period_num := p_dpr_in.p_cl_begin;

h_period_counter := p_period_rec.period_counter;
h_fiscal_year := p_period_rec.fiscal_year;
h_period_num  := p_period_rec.period_num;

h_deprn_method_code := p_asset_fin_rec.deprn_method_code;
h_life_in_months := p_asset_fin_rec.life_in_months;

h_mem_trans_thid := nvl(p_trans_rec.member_transaction_header_id,-99);
--* Prepare to call Deprn Basis Rule - 1
h_period_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
h_start_period_counter := h_start_fiscal_year*h_period_per_fiscal_year+h_start_period_num;

h_set_of_books_id := p_asset_hdr_rec.set_of_books_id;

select fiscal_year_name, deprn_calendar
  into h_fiscal_year_name,h_calendar_type
  from fa_book_controls
 where book_type_code = h_book_type_code;

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'h_fiscal_year_name:h_calendar_type', h_fiscal_year_name||':'||h_calendar_type, p_log_level_rec => p_log_level_rec);
end if;


--* Need to call deprn basis rule to get correct adjusted cost at the loop start period.
-- Followings are preparation to call faxcdb
if (p_log_level_rec.statement_level) then
  fa_debug_pkg.add(l_calling_fn, '+++ Preparation to call deprn basis rule function +++', '+++', p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn, 'h_period_counter:h_fiscal_year:h_deprn_method_code:h_life_in_months',
                                  h_period_counter||':'||h_fiscal_year||':'||h_deprn_method_code||':'||h_life_in_months, p_log_level_rec => p_log_level_rec);
  fa_debug_pkg.add(l_calling_fn, 'Method Cache is called.', '***');
end if;

if not fa_cache_pkg.fazccmt(X_method => h_deprn_method_code,
                            X_life => h_life_in_months, p_log_level_rec => p_log_level_rec) then
  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, '++ fa_cache_pkg.fazccmt is errored out ++', '+++', p_log_level_rec => p_log_level_rec);
  end if;
  raise get_member_at_start_err;
end if;

-- Populate Method related information from cache
h_group_deprn_basis := fa_cache_pkg.fazccmt_record.deprn_basis_rule; -- COST or NBV

--* If this proceesing period is last period of the fiscal year set h_eofy_flag = 'Y'
--* call depreciable basis rule function to update adjusted cost for the next year
if h_start_period_num = h_period_per_fiscal_year then
   h_eofy_flag := 'Y';
else
   h_eofy_flag := 'N';
end if;

--* Set group level parameters
fa_rule_in.event_type := 'AMORT_ADJ';
fa_rule_in.book_type_code := h_book_type_code;
fa_rule_in.fiscal_year := h_start_fiscal_year;
fa_rule_in.period_num := h_start_period_num;
fa_rule_in.method_code := h_deprn_method_code;
fa_rule_in.life_in_months := h_life_in_months;
fa_rule_in.method_type := fa_cache_pkg.fazccmt_record.rate_source_rule;
fa_rule_in.calc_basis := fa_cache_pkg.fazccmt_record.deprn_basis_rule;
fa_rule_in.mrc_sob_type_code := p_mrc_sob_type_code;
fa_rule_in.set_of_books_id := h_set_of_books_id;
fa_rule_in.group_asset_id := h_group_asset_id;
fa_rule_in.period_counter := h_start_period_counter;

--* Group Level information (50% application) if the basis rule assigned to this method enables reduction rate
if fa_cache_pkg.fazcdrd_record.rule_name in ('YEAR END BALANCE WITH POSITIVE REDUCTION',
                                             'YEAR END BALANCE WITH HALF YEAR RULE') then

  if not check_reduction_application(p_rule_name => fa_cache_pkg.fazcdrd_record.rule_name,
                                     p_group_asset_id => h_group_asset_id,
                                     p_book_type_code => h_book_type_code,
                                     p_period_counter => h_start_period_counter,
                                     p_group_deprn_basis => h_group_deprn_basis,
                                     p_reduction_rate => p_asset_fin_rec.reduction_rate,
                                     p_group_eofy_rec_cost => 0, -- Since this is called for first period of life
                                     p_group_eofy_salvage_value => 0,
                                     p_group_eofy_reserve => 0,
                                     p_mrc_sob_type_code => p_mrc_sob_type_code,
                                     p_set_of_books_id => h_set_of_books_id,
                                     x_apply_reduction_flag => h_apply_reduction_flag,
                                     p_log_level_rec => p_log_level_rec) then
     raise get_member_at_start_err;
  end if;
end if;

-- Query member assets from FA_BOOKS at the time of transction_date_entered

i := 0;
if p_mrc_sob_type_code <> 'R' then

  -- Loop for all member assets existed in the amort period populated above
  For get_member in ALL_MEMBERS_AT_AMORT(h_fiscal_year,h_period_num) loop

    i := i + 1; -- Count up for subscript
    h_member_asset_id := get_member.member_asset_id;

    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) : member asset id', h_member_asset_id);
      fa_debug_pkg.add(l_calling_fn, 'h_mem_trans_thid', h_mem_trans_thid, p_log_level_rec => p_log_level_rec);
    end if;

    --* Check if this transaction is reclass and this member asset is now reclassed or not
    if h_mem_trans_thid <> -99 then

      open RECLASS_TRANS_CHECK(h_member_asset_id, h_mem_trans_thid);
      fetch RECLASS_TRANS_CHECK into h_new_group_asset_id;
      if RECLASS_TRANS_CHECK%NOTFOUND then
        null;
      elsif h_new_group_asset_id is null then
        -- Now this asset becomes single asset. Don't need to include the calculation
        close RECLASS_TRANS_CHECK;
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'This member asset doesnt belong to this group asset','+++', p_log_level_rec => p_log_level_rec);
        end if;
        goto skip_processing;
      elsif h_new_group_asset_id <> h_group_asset_id then -- This is a case of reclass and this asset is now going to other group
        close RECLASS_TRANS_CHECK;
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'This member asset doesnt belong to this group asset','+++', p_log_level_rec => p_log_level_rec);
        end if;
        goto skip_processing;
      end if;
      close RECLASS_TRANS_CHECK;
    end if;

    --* Process get delta of cost, rec cost, salvage value etc...
    --* Query transaction header id of this member assetin this period
    h_trans_exists_flag := FALSE;
    h_transaction_header_id := to_number(NULL);
    h_delta_cost := 0;
    h_delta_recoverable_cost := 0;
    h_new_adjusted_rec_cost := to_number(NULL);

    h_adj_cost := 0;
    h_adj_rec_cost := 0;
    h_adj_salvage_value := 0;

    For ALL_TRANS IN ALL_TRANS_IN_PERIOD(h_fiscal_year,h_period_num, h_member_asset_id) Loop
       h_trans_exists_flag := TRUE;
       h_transaction_header_id := ALL_TRANS.transaction_header_id;

       --* query delta for this transaction
       open GET_DELTA_FOR_MEMBER(h_member_asset_id, h_transaction_header_id);
       fetch GET_DELTA_FOR_MEMBER into h_delta_cost, h_delta_recoverable_cost, h_new_limit_type, h_old_limit_type,
                                       h_new_deprn_limit, h_new_deprn_limit_amount, h_depreciate_flag;
       if GET_DELTA_FOR_MEMBER%NOTFOUND then
         h_trans_exists_flag := FALSE;
         h_transaction_header_id := to_number(NULL);
         h_delta_cost := 0;
         h_delta_recoverable_cost := 0;
         h_new_adjusted_rec_cost := to_number(NULL);
       end if;
       close GET_DELTA_FOR_MEMBER;

       h_adj_cost := h_adj_cost + h_delta_cost;
       h_adj_rec_cost := h_adj_rec_cost + h_delta_recoverable_cost;
       h_adj_salvage_value := h_adj_cost - h_adj_rec_cost;

       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++++ LOOP FOR GETTING DELTA *** THID', h_transaction_header_id);
         fa_debug_pkg.add(l_calling_fn, 'h_delta_cost:h_delta_recoverable_cost', h_delta_cost||':'||h_delta_recoverable_cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'h_adj_cost:h_adj_rec_cost:h_adj_salvage_value', h_adj_cost||':'||h_adj_salvage_value, p_log_level_rec => p_log_level_rec);
       end if;
    End loop;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++++ AFTER LOOP FOR ALL_TRANS_IN_PERIOD ****', '****');
       fa_debug_pkg.add(l_calling_fn, 'h_new_limit_type:h_new_deprn_limit:h_new_deprn_limit_amount',
                                       h_new_limit_type||':'||h_new_deprn_limit||':'||h_new_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
    end if;

     --* Set old amounts as zero since this process will be made for just start period
     h_old_cost := 0;
     h_old_salvage_value := 0;
     h_old_recoverable_cost := 0;
     h_old_adjusted_rec_cost := 0;

     h_bonus_deprn_reserve := 0;
     h_bonus_ytd_deprn := 0;
     -- Then enter this asset to extended memory table at this moment
     l_new_ind := nvl(p_track_member_table.COUNT,0) + 1;
     --* This is a case when this asset is added in this period.
     open GET_RESERVE_AT_ADDITION(h_member_asset_id, h_start_period_counter - 1);
     fetch GET_RESERVE_AT_ADDITION into h_deprn_source_code, h_ytd_deprn, h_deprn_reserve;

     if GET_RESERVE_AT_ADDITION%NOTFOUND then

       -- Set zero initial reserve
       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'Member asset which cannot find DEPRN SUMMARY table',
                           h_member_asset_id, p_log_level_rec => p_log_level_rec);
       end if;

       h_ytd_deprn := 0;
       h_deprn_reserve := 0;

     elsif h_deprn_source_code <> 'BOOK' then
       -- Set zero initial reserve

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'This Member asset record', h_deprn_source_code, p_log_level_rec => p_log_level_rec);
       end if;

       h_ytd_deprn := 0;
       h_deprn_reserve := 0;

     end if;
     close GET_RESERVE_AT_ADDITION;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'l_new_ind', l_new_ind, p_log_level_rec => p_log_level_rec);
     end if;
     p_track_member_table(l_new_ind).group_asset_id := h_group_asset_id;
     p_track_member_table(l_new_ind).member_asset_id := h_member_asset_id;
     p_track_member_table(l_new_ind).set_of_books_id := h_set_of_books_id;
     p_track_member_table(l_new_ind).period_counter := h_start_period_counter;
     p_track_member_table(l_new_ind).fiscal_year := h_start_fiscal_year;
     p_track_member_table(l_new_ind).cost := h_old_cost;
     p_track_member_table(l_new_ind).salvage_value := h_old_salvage_value;
     p_track_member_table(l_new_ind).adjusted_cost := h_old_recoverable_cost;
     p_track_member_table(l_new_ind).recoverable_cost := h_old_recoverable_cost;
     p_track_member_table(l_new_ind).adjusted_recoverable_cost := h_old_adjusted_rec_cost;
     p_track_member_table(l_new_ind).deprn_reserve := h_deprn_reserve;
     p_track_member_table(l_new_ind).ytd_deprn := h_ytd_deprn;
     p_track_member_table(l_new_ind).bonus_deprn_reserve := 0;
     p_track_member_table(l_new_ind).bonus_ytd_deprn := 0;
     p_track_member_table(l_new_ind).eofy_reserve := h_deprn_reserve - h_ytd_deprn;
     p_track_member_table(l_new_ind).eofy_recoverable_cost := 0;
     p_track_member_table(l_new_ind).eop_recoverable_cost := 0;
     p_track_member_table(l_new_ind).eofy_salvage_value := 0;
     p_track_member_table(l_new_ind).eop_salvage_value := 0;
     p_track_member_table(l_new_ind).set_of_books_id := nvl(h_set_of_books_id, -99);
     h_eofy_reserve := h_deprn_reserve - h_ytd_deprn;

     /* Populate index table */
     put_track_index(h_start_period_counter,h_member_asset_id,h_group_asset_id,h_set_of_books_id,l_new_ind,p_log_level_rec);

   --* Member Asset level information
     --* adjust by the delta
     h_new_cost := h_old_cost + h_adj_cost;
     h_new_recoverable_cost := h_old_recoverable_cost + h_adj_rec_cost;
     h_new_salvage_value := h_old_salvage_value + h_adj_salvage_value;

     if nvl(h_new_limit_type,'NONE') = 'PCT' then
         h_temp_limit_amount := h_new_cost*(1 - h_new_deprn_limit);
         fa_round_pkg.fa_floor(h_temp_limit_amount,h_book_type_code, p_log_level_rec => p_log_level_rec);
         h_new_adjusted_rec_cost := h_new_cost - h_temp_limit_amount;
     elsif nvl(h_new_limit_type,'NONE') = 'NONE' then
         h_new_adjusted_rec_cost := h_new_recoverable_cost; -- In this case, it should be same as new recoverable cost
     else
         h_new_adjusted_rec_cost := h_new_deprn_limit_amount;
     end if;

     if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'h_new_cost:h_new_rec_cost:h_new_salvage:h_new_adj_rec_cost',
                                         h_new_cost||':'||h_new_recoverable_cost||':'||h_new_salvage_value||':'||h_new_adjusted_rec_cost, p_log_level_rec => p_log_level_rec);
     end if;

     -- Get Asset type
     select ASSET_TYPE
       into fa_rule_in.asset_type
       from fa_additions_b
      where asset_id = h_member_asset_id;

     --* Set fa_rule_in to call deprn basis rule function
     fa_rule_in.asset_id := h_member_asset_id;
     fa_rule_in.depreciate_flag := h_depreciate_flag;
     fa_rule_in.adjustment_amount := 0;
     fa_rule_in.cost := h_new_cost;
     fa_rule_in.salvage_value := h_new_salvage_value;
     fa_rule_in.recoverable_cost := h_new_recoverable_cost;
     fa_rule_in.adjusted_cost := h_new_recoverable_cost;
     fa_rule_in.current_total_rsv := h_deprn_reserve;
     fa_rule_in.current_rsv := h_deprn_reserve;
     fa_rule_in.current_total_ytd := h_ytd_deprn;
     fa_rule_in.current_ytd := h_ytd_deprn;
     fa_rule_in.old_adjusted_cost := h_new_recoverable_cost;
     fa_rule_in.eofy_reserve := nvl(h_deprn_reserve,0) - nvl(h_ytd_deprn,0);

     fa_rule_in.eofy_recoverable_cost := 0;
     fa_rule_in.eop_recoverable_cost := 0;
     fa_rule_in.eofy_salvage_value := 0;
     fa_rule_in.eop_salvage_value := 0;
     fa_rule_in.apply_reduction_flag := h_apply_reduction_flag;

     if (p_log_level_rec.statement_level) then
       if not display_debug_message(fa_rule_in => fa_rule_in,
                                    p_calling_fn => l_calling_fn,
                                    p_log_level_rec => p_log_level_rec) then
       fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
       end if;
     end if;

     -- Call Deprn Basis Rule for this transaction or period
     if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                             rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'FAXCDB is errored out', '+++', p_log_level_rec => p_log_level_rec);
       end if;
       raise get_member_at_start_err;
     end if;

     --* Since the fully reserved asset is included in the depreciable basis to calculate RAF
     p_track_member_table(l_new_ind).fully_reserved_flag := NULL;
     p_track_member_table(l_new_ind).fully_retired_flag := NULL;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', fa_rule_in.asset_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost', fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
     end if;

     --* Set calculated adjusted cost into p_track_member_table
     p_track_member_table(l_new_ind).cost := h_new_cost;
     p_track_member_table(l_new_ind).salvage_value := h_new_salvage_value;
     p_track_member_table(l_new_ind).recoverable_cost := h_new_recoverable_cost;
     p_track_member_table(l_new_ind).adjusted_cost := fa_rule_out.new_adjusted_cost;
     p_track_member_table(l_new_ind).adjusted_recoverable_cost := h_new_adjusted_rec_cost;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++ In Loop (2) indicator', i);
       if not display_debug_message2(i => i, p_calling_fn => l_calling_fn,
p_log_level_rec => p_log_level_rec) then
          fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
       end if;
     end if;

<<skip_processing>>
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++ End of Loop ++', i, p_log_level_rec => p_log_level_rec);
     end if;

  end loop;

else -- Reporting Book
  -- Loop for all member assets existed in the amort period populated above
  For get_member in ALL_MEMBERS_AT_AMORT_MRC(h_fiscal_year,h_period_num) loop

    i := i + 1; -- Count up for subscript
    h_member_asset_id := get_member.member_asset_id;

    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '+++ In Loop (1) : member asset id', h_member_asset_id);
    end if;

    --* Check if this transaction is reclass and this member asset is now reclassed or not
    if h_mem_trans_thid <> -99 then
      open RECLASS_TRANS_CHECK(h_member_asset_id, h_mem_trans_thid);
      fetch RECLASS_TRANS_CHECK into h_new_group_asset_id;
      if RECLASS_TRANS_CHECK%NOTFOUND then
        null;
      elsif h_new_group_asset_id is null then
        -- Now this asset becomes single asset. Don't need to include the calculation
        close RECLASS_TRANS_CHECK;
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'This member asset doesnt belong to this group asset','+++', p_log_level_rec => p_log_level_rec);
        end if;
        goto skip_processing;
      elsif h_new_group_asset_id <> h_group_asset_id then -- This is a case of reclass and this asset is now going to other group
        close RECLASS_TRANS_CHECK;
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'This member asset doesnt belong to this group asset','+++', p_log_level_rec => p_log_level_rec);
        end if;
        goto skip_processing;
      end if;
      close RECLASS_TRANS_CHECK;
    end if;

    --* Process get delta of cost, rec cost, salvage value etc...
    --* Query transaction header id of this member assetin this period
    h_trans_exists_flag := FALSE;
    h_transaction_header_id := to_number(NULL);
    h_delta_cost := 0;
    h_delta_recoverable_cost := 0;
    h_new_adjusted_rec_cost := to_number(NULL);

    h_adj_cost := 0;
    h_adj_rec_cost := 0;
    h_adj_salvage_value := 0;

    For ALL_TRANS IN ALL_TRANS_IN_PERIOD(h_fiscal_year,h_period_num, h_member_asset_id) Loop
       h_trans_exists_flag := TRUE;
       h_transaction_header_id := ALL_TRANS.transaction_header_id;

       --* query delta for this transaction
       open GET_DELTA_FOR_MEMBER_MRC(h_member_asset_id, h_transaction_header_id);
       fetch GET_DELTA_FOR_MEMBER_MRC into h_delta_cost, h_delta_recoverable_cost, h_new_limit_type, h_old_limit_type,
                                       h_new_deprn_limit, h_new_deprn_limit_amount, h_depreciate_flag;
       if GET_DELTA_FOR_MEMBER_MRC%NOTFOUND then
         h_trans_exists_flag := FALSE;
         h_transaction_header_id := to_number(NULL);
         h_delta_cost := 0;
         h_delta_recoverable_cost := 0;
         h_new_adjusted_rec_cost := to_number(NULL);
       end if;
       close GET_DELTA_FOR_MEMBER_MRC;

       h_adj_cost := h_adj_cost + h_delta_cost;
       h_adj_rec_cost := h_adj_rec_cost + h_delta_recoverable_cost;
       h_adj_salvage_value := h_adj_cost - h_adj_rec_cost;

       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++++ LOOP FOR GET_DELTA_FOR_MEMBER_MRC *** THID', h_transaction_header_id);
         fa_debug_pkg.add(l_calling_fn, 'h_delta_cost:h_delta_rec_cost', h_delta_cost||':'||h_delta_recoverable_cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'h_adj_cost:h_adj_rec_cost:h_adj_salvage_value', h_adj_cost||':'||h_adj_rec_cost||':'||h_adj_salvage_value, p_log_level_rec => p_log_level_rec);
       end if;
    End loop;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++++ AFTER LOOP FOR GETTING DELTA ****', '****');
       fa_debug_pkg.add(l_calling_fn, 'h_new_limit_type:h_new_deprn_limit:h_new_deprn_limit_amount',
                                       h_new_limit_type||':'||h_new_deprn_limit||':'||h_new_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
     end if;

     --* Set old amounts as zero since this process will be made for just start period
     h_old_cost := 0;
     h_old_salvage_value := 0;
     h_old_recoverable_cost := 0;
     h_old_adjusted_rec_cost := 0;

     h_bonus_deprn_reserve := 0;
     h_bonus_ytd_deprn := 0;
     -- Then enter this asset to extended memory table at this moment
     l_new_ind := nvl(p_track_member_table.COUNT,0) + 1;
     --* This is a case when this asset is added in this period.
     open GET_RESERVE_AT_ADDITION_MRC(h_member_asset_id, h_start_period_counter - 1);
     fetch GET_RESERVE_AT_ADDITION_MRC into h_deprn_source_code, h_ytd_deprn, h_deprn_reserve;

     if GET_RESERVE_AT_ADDITION_MRC%NOTFOUND then
       -- Set zero initial reserve

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'Member asset which cannot find DEPRN SUMMARY table',
                           h_member_asset_id, p_log_level_rec => p_log_level_rec);
       end if;

       h_ytd_deprn := 0;
       h_deprn_reserve := 0;

     elsif h_deprn_source_code <> 'BOOK' then
       -- Set zero initial reserve

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'This Member asset record', h_deprn_source_code, p_log_level_rec => p_log_level_rec);
       end if;

       h_ytd_deprn := 0;
       h_deprn_reserve := 0;

     end if;
     close GET_RESERVE_AT_ADDITION_MRC;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'l_new_ind', l_new_ind, p_log_level_rec => p_log_level_rec);
     end if;
     p_track_member_table(l_new_ind).group_asset_id := h_group_asset_id;
     p_track_member_table(l_new_ind).member_asset_id := h_member_asset_id;
     p_track_member_table(l_new_ind).set_of_books_id := h_set_of_books_id;
     p_track_member_table(l_new_ind).period_counter := h_start_period_counter;
     p_track_member_table(l_new_ind).fiscal_year := h_start_fiscal_year;
     p_track_member_table(l_new_ind).cost := h_old_cost;
     p_track_member_table(l_new_ind).salvage_value := h_old_salvage_value;
     p_track_member_table(l_new_ind).adjusted_cost := h_old_recoverable_cost;
     p_track_member_table(l_new_ind).recoverable_cost := h_old_recoverable_cost;
     p_track_member_table(l_new_ind).adjusted_recoverable_cost := h_old_adjusted_rec_cost;
     p_track_member_table(l_new_ind).deprn_reserve := h_deprn_reserve;
     p_track_member_table(l_new_ind).ytd_deprn := h_ytd_deprn;
     p_track_member_table(l_new_ind).bonus_deprn_reserve := 0;
     p_track_member_table(l_new_ind).bonus_ytd_deprn := 0;
     p_track_member_table(l_new_ind).eofy_reserve := h_deprn_reserve - h_ytd_deprn;
     p_track_member_table(l_new_ind).eofy_recoverable_cost := 0;
     p_track_member_table(l_new_ind).eop_recoverable_cost := 0;
     p_track_member_table(l_new_ind).eofy_salvage_value := 0;
     p_track_member_table(l_new_ind).eop_salvage_value := 0;
     p_track_member_table(l_new_ind).set_of_books_id := nvl(h_set_of_books_id, -99);
     h_eofy_reserve := h_deprn_reserve - h_ytd_deprn;

     /* Populate index table */
     put_track_index(h_start_period_counter,h_member_asset_id,h_group_asset_id,h_set_of_books_id,l_new_ind,p_log_level_rec);

   --* Member Asset level information
     --* adjust by the delta
     h_new_cost := h_old_cost + h_adj_cost;
     h_new_recoverable_cost := h_old_recoverable_cost + h_adj_rec_cost;
     h_new_salvage_value := h_old_salvage_value + h_adj_salvage_value;

     if nvl(h_new_limit_type,'NONE') = 'PCT' then
         h_temp_limit_amount := h_new_cost*(1 - h_new_deprn_limit);
         fa_round_pkg.fa_floor(h_temp_limit_amount,h_book_type_code, p_log_level_rec => p_log_level_rec);
         h_new_adjusted_rec_cost := h_new_cost - h_temp_limit_amount;
     elsif nvl(h_new_limit_type,'NONE') = 'NONE' then
         h_new_adjusted_rec_cost := h_new_recoverable_cost; -- In this case, it should be same as new recoverable cost
     else
         h_new_adjusted_rec_cost := h_new_deprn_limit_amount;
     end if;

     if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++++ AFTER GETTING NEW COST etc ***', '*****');
         fa_debug_pkg.add(l_calling_fn, 'h_new_cost:h_new_rec_cost:h_new_salvage:h_new_adj_rec_cost',
                                         h_new_cost||':'||h_new_recoverable_cost||':'||h_new_salvage_value||':'||h_new_adjusted_rec_cost, p_log_level_rec => p_log_level_rec);
     end if;

     -- Get Asset type
     select ASSET_TYPE
       into fa_rule_in.asset_type
       from fa_additions_b
      where asset_id = h_member_asset_id;

     --* Set fa_rule_in to call deprn basis rule function
     fa_rule_in.asset_id := h_member_asset_id;
     fa_rule_in.depreciate_flag := h_depreciate_flag;
     fa_rule_in.adjustment_amount := 0;
     fa_rule_in.cost := h_new_cost;
     fa_rule_in.salvage_value := h_new_salvage_value;
     fa_rule_in.recoverable_cost := h_new_recoverable_cost;
     fa_rule_in.adjusted_cost := h_new_recoverable_cost;
     fa_rule_in.current_total_rsv := h_deprn_reserve;
     fa_rule_in.current_rsv := h_deprn_reserve;
     fa_rule_in.current_total_ytd := h_ytd_deprn;
     fa_rule_in.current_ytd := h_ytd_deprn;
     fa_rule_in.old_adjusted_cost := h_new_recoverable_cost;
     fa_rule_in.eofy_reserve := nvl(h_deprn_reserve,0) - nvl(h_ytd_deprn,0);

     fa_rule_in.eofy_recoverable_cost := 0;
     fa_rule_in.eop_recoverable_cost := 0;
     fa_rule_in.eofy_salvage_value := 0;
     fa_rule_in.eop_salvage_value := 0;
     fa_rule_in.apply_reduction_flag := h_apply_reduction_flag;

     if (p_log_level_rec.statement_level) then
       if not display_debug_message(fa_rule_in => fa_rule_in,
                                    p_calling_fn => l_calling_fn,
p_log_level_rec => p_log_level_rec) then
       fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
       end if;
     end if;

     -- Call Deprn Basis Rule for this transaction or period
     if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                             rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'FAXCDB is errored out', '+++', p_log_level_rec => p_log_level_rec);
       end if;
       raise get_member_at_start_err;
     end if;

     --* Since the fully reserved asset is included in the depreciable basis to calculate RAF
     p_track_member_table(l_new_ind).fully_reserved_flag := NULL;
     p_track_member_table(l_new_ind).fully_retired_flag := NULL;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', fa_rule_in.asset_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost', fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
     end if;

     --* Set calculated adjusted cost into p_track_member_table
     p_track_member_table(l_new_ind).cost := h_new_cost;
     p_track_member_table(l_new_ind).salvage_value := h_new_salvage_value;
     p_track_member_table(l_new_ind).recoverable_cost := h_new_recoverable_cost;
     p_track_member_table(l_new_ind).adjusted_cost := fa_rule_out.new_adjusted_cost;
     p_track_member_table(l_new_ind).adjusted_recoverable_cost := h_new_adjusted_rec_cost;

     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++ In Loop (2) indicator', i);
       if not display_debug_message2(i => i, p_calling_fn => l_calling_fn,
p_log_level_rec=> p_log_level_rec) then
          fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
       end if;
     end if;

<<skip_processing>>
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '++ End of Loop ++', i, p_log_level_rec => p_log_level_rec);
     end if;

  end loop;

end if;

return(true);

exception
  when get_member_at_start_err then
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

end get_member_at_start;

--+=====================================================================
-- Function: update_member_books
--
--  This function will be called from adjustment engine
--  to update FA_BOOKS for each member assets
--  Using stored adjusted_cost in FA_TRACK_MEMBERS,
--  FA_BOOKS will be updated.
--
--+=====================================================================

FUNCTION update_member_books(p_trans_rec          in FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec      in FA_API_TYPES.asset_hdr_rec_type,
                             p_dpr_in             in FA_STD_TYPES.dpr_struct,
                             p_mrc_sob_type_code  in varchar2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type) -- default 'N'
  return boolean is

--* Host related variables
h_book_type_code        varchar2(30);
h_group_asset_id        number;
h_member_asset_id       number;
h_fiscal_year           number;
h_period_num            number;
h_period_counter        number;
h_set_of_books_id       number;

h_adjusted_cost         number;
h_eofy_reserve          number;

l_calling_fn            varchar2(45) := 'fa_track_member_pvt.update_member_books';
update_member_err           exception;


l_member_asset_id  number;

   cursor c_get_member_asset_id is
      select mth.asset_id
      from   fa_transaction_headers mth
      where  mth.transaction_header_id = p_trans_rec.member_transaction_header_id;

-- cursor to get period_counter
cursor GET_PERIOD_COUNTER is
  select period_counter
    from fa_deprn_periods
   where book_type_code = h_book_type_code
     and fiscal_year = h_fiscal_year
     and period_num = h_period_num;

cursor GET_PERIOD_COUNTER_MRC is
  select period_counter
    from fa_mc_deprn_periods
   where book_type_code = h_book_type_code
     and fiscal_year = h_fiscal_year
     and period_num = h_period_num
     and set_of_books_id = h_set_of_books_id;

-- cursor to query start period condition of all members belonged to the specified group
cursor ALL_MEMBERS is
  select bk.asset_id,
         bk.group_asset_id
    from fa_books bk
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_group_asset_id
     and bk.date_ineffective is null
     and bk.depreciate_flag = 'YES'
     and bk.asset_id = nvl(l_member_asset_id, bk.asset_id)
   order by asset_id;

cursor ALL_MEMBERS_MRC is
  select bk.asset_id,
         bk.group_asset_id
    from fa_mc_books bk
   where bk.book_type_code = h_book_type_code
     and bk.group_asset_id = h_group_asset_id
     and bk.date_ineffective is null
     and bk.depreciate_flag = 'YES'
     and bk.set_of_books_id = h_set_of_books_id
   order by asset_id;

begin

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add('fa_track_member_pvt', '*** update_member_books Started', '***');
   fa_debug_pkg.add('fa_track_member_pvt', 'book_type_code:group_asset_id', p_asset_hdr_rec.book_type_code||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
end if;

h_book_type_code := p_asset_hdr_rec.book_type_code;
h_group_asset_id := p_asset_hdr_rec.asset_id;
h_fiscal_year := p_dpr_in.y_end;
h_period_num := p_dpr_in.p_cl_end;
h_set_of_books_id := p_asset_hdr_rec.set_of_books_id;

if (nvl(fa_cache_pkg.fazcdrd_record.allow_reduction_rate_flag, 'N') = 'N') then
open c_get_member_asset_id;
fetch c_get_member_asset_id into l_member_asset_id;
close c_get_member_asset_id;
if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'l_member_asset_id', l_member_asset_id, p_log_level_rec => p_log_level_rec);
end if;
end if;


if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'fiscal_year:period_num', h_fiscal_year||':'||h_period_num, p_log_level_rec => p_log_level_rec);
end if;

/* Apply MRC related feature */
if p_mrc_sob_type_code <> 'R' then

  open GET_PERIOD_COUNTER;
  fetch GET_PERIOD_COUNTER into h_period_counter;
  close GET_PERIOD_COUNTER;
else

  open GET_PERIOD_COUNTER_MRC;
  fetch GET_PERIOD_COUNTER_MRC into h_period_counter;
  close GET_PERIOD_COUNTER_MRC;
end if;

h_period_counter := h_period_counter + 1;

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'h_set_of_books_id:period_counter', h_set_of_books_id||':'||h_period_counter, p_log_level_rec => p_log_level_rec);
end if;

-- Query member assets from FA_BOOKS with current date
if p_mrc_sob_type_code <> 'R' then

  -- Loop for all member populated above
  For update_member in ALL_MEMBERS loop

    h_member_asset_id := update_member.asset_id;

    h_adjusted_cost := null;
    h_eofy_reserve := null;

    For i IN 1 .. p_track_member_table.COUNT LOOP

      if p_track_member_table(i).group_asset_id = h_group_asset_id and
         p_track_member_table(i).member_asset_id = h_member_asset_id and
         p_track_member_table(i).period_counter = h_period_counter and
         nvl(p_track_member_table(i).set_of_books_id, -99) = nvl(h_set_of_books_id, -99) and

          ((nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N' and nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'Y' and
            nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N')
          or
           (nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'Y'))

     then

           h_adjusted_cost := nvl(p_track_member_table(i).adjusted_cost,0);
           h_eofy_reserve := p_track_member_table(i).eofy_reserve;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('fa_track_member_pvt', 'member asset id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('fa_track_member_pvt', 'adjusted cost', h_adjusted_cost, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('fa_track_member_pvt', 'eofy reserve', h_eofy_reserve, p_log_level_rec => p_log_level_rec);
           end if;

           -- Update FA_BOOKS table
           Update FA_BOOKS set adjusted_cost = h_adjusted_cost,
                               eofy_reserve = h_eofy_reserve,
                               last_update_date = sysdate,
                               last_updated_by = -1
                         where book_type_code = h_book_type_code
                           and asset_id = h_member_asset_id
                           and group_asset_id = h_group_asset_id
                           and date_ineffective is null;
/* Bug 6929073 -  The following update statement added for half year basis rule with 50% reduction rule.
                  when the member asset is added in second half then its adjusted_cost should be 50%.
                  But its being populated as full value in 'Book' row of fa_ds. in Fa_books also its populated with full value.
                  But the above update statement is updating the correct value, if tracking method is allocate.
                  The following update statement written similar to above. */
           Update fa_deprn_summary set   adjusted_cost = h_adjusted_cost
                                   where book_type_code = h_book_type_code
                                     and asset_id = h_member_asset_id
                                     and not exists (select 'non period of addition'
                                                     from   fa_Deprn_summary
                                                     where  deprn_source_code = 'DEPRN'
                                                        and asset_id = h_member_asset_id
                                                        and book_type_code = h_book_type_code)
                                     and exists (select 'reduction rate'
                                                 from fa_books
                                                 where asset_id = h_group_asset_id
                                                   and book_type_code = h_book_type_code
                                                   and transaction_header_id_out is null
                                                   and nvl(reduction_rate,0) <> 0
                                                   and reduce_addition_flag = 'Y')
                                     and deprn_source_code = 'BOOKS';

           exit;
      end if;
    END LOOP;

  end loop; -- get_member loop

else -- Reporting Book

  -- Loop for all member populated above
  For update_member in ALL_MEMBERS_MRC loop

    h_member_asset_id := update_member.asset_id;

    h_adjusted_cost := null;
    h_eofy_reserve := null;

    For i IN 1 .. p_track_member_table.COUNT LOOP

      if p_track_member_table(i).group_asset_id = h_group_asset_id and
         p_track_member_table(i).member_asset_id = h_member_asset_id and
         p_track_member_table(i).period_counter = h_period_counter and
         nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(h_set_of_books_id,-99) and

          ((nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N' and nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'N' and
            nvl(p_track_member_table(i).fully_reserved_flag,'N') = 'N')
          or
           (nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'N' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'Y' and
            nvl(p_track_member_table(i).fully_retired_flag,'N') = 'N')
          or
           (nvl(p_dpr_in.allocate_to_fully_ret_flag,'N') = 'Y' and
            nvl(p_dpr_in.allocate_to_fully_rsv_flag,'N') = 'Y'))

      then

           h_adjusted_cost := p_track_member_table(i).adjusted_cost;
           h_eofy_reserve := p_track_member_table(i).eofy_reserve;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('fa_track_member_pvt', 'member asset id', h_member_asset_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('fa_track_member_pvt', 'adjusted cost', h_adjusted_cost, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('fa_track_member_pvt', 'eofy reserve', h_eofy_reserve, p_log_level_rec => p_log_level_rec);
           end if;

           -- Update FA_BOOKS table
           Update FA_MC_BOOKS set adjusted_cost = h_adjusted_cost,
                                     eofy_reserve = h_eofy_reserve,
                                     last_update_date = sysdate,
                                     last_updated_by = -1
                               where book_type_code = h_book_type_code
                                 and asset_id = h_member_asset_id
                                 and group_asset_id = h_group_asset_id
                                 and date_ineffective is null
                                 and set_of_books_id = h_set_of_books_id;

/* Bug 6929073 -  The following update statement added for half year basis rule with 50% reduction rule.
                  when the member asset is added in second half then its adjusted_cost should be 50%.
                  But its being populated as full value. in Fa_books also its populated with full value.
                  But the above update statement is updating the correct value, if tracking method is allocate.
                  The following update statement written similar to above. */

           Update fa_mc_deprn_summary set   adjusted_cost = h_adjusted_cost
                                   where book_type_code = h_book_type_code
                                     and asset_id = h_member_asset_id
                                     and not exists (select 'non period of addition'
                                                     from   fa_mc_deprn_summary
                                                     where  deprn_source_code = 'DEPRN'
                                                        and asset_id = h_member_asset_id
                                                        and book_type_code = h_book_type_code
                                                        and set_of_books_id = h_set_of_books_id)
                                     and exists (select 'reduction rate'
                                                 from FA_MC_BOOKS
                                                 where asset_id = h_group_asset_id
                                                   and book_type_code = h_book_type_code
                                                   and transaction_header_id_out is null
                                                   and nvl(reduction_rate,0) <> 0
                                                   and reduce_addition_flag = 'Y'
                                                   and set_of_books_id = h_set_of_books_id)
                                     and deprn_source_code = 'BOOKS'
                                     and set_of_books_id = h_set_of_books_id;

           exit;
      end if;
    END LOOP;

  end loop; -- get_member loop

end if; -- Primary Book or Reporting Book?

return(true);

exception
  when update_member_err then
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

end update_member_books;

--+=====================================================================
-- Function: member_eofy_rsv
--
--  This function will be called from adjustment engine at the end
--  of main loop.
--  In order to pass of each member's eofy_reserve,
--  calculated eofy_reserve will be kept in PL\SQL table
--
--+=====================================================================

FUNCTION member_eofy_rsv(p_asset_hdr_rec      in FA_API_TYPES.asset_hdr_rec_type,
                         p_dpr_in             in FA_STD_TYPES.dpr_struct,
                         p_mrc_sob_type_code  in varchar2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type) -- default 'N'
  return boolean is

--* Host related variables
h_book_type_code        varchar2(30);
h_group_asset_id        number;
h_member_asset_id       number;
h_fiscal_year           number;
h_period_num            number;
h_period_counter        number;
h_set_of_books_id       number;

h_cost                  number;
h_salvage_value         number;
h_recoverable_cost      number;
h_adjusted_cost         number;
h_eofy_reserve          number;
j                       number;

l_calling_fn            varchar2(45) := 'fa_track_member_pvt.member_eofy_rsv';
member_eofy_rsv_err           exception;

-- cursor to get period_counter
cursor GET_PERIOD_COUNTER is
  select period_counter
    from fa_deprn_periods
   where book_type_code = h_book_type_code
     and fiscal_year = h_fiscal_year
     and period_num = h_period_num;

cursor GET_PERIOD_COUNTER_MRC is
  select period_counter
    from fa_mc_deprn_periods
   where book_type_code = h_book_type_code
     and fiscal_year = h_fiscal_year
     and period_num = h_period_num
     and set_of_books_id = h_set_of_books_id;

begin

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, '++++ member_eofy_rsv:Just Started ++++', '++++++', p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add(l_calling_fn, 'book_type_code:group_asset_id', p_asset_hdr_rec.book_type_code||':'||p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
end if;

h_book_type_code := p_asset_hdr_rec.book_type_code;
h_group_asset_id := p_asset_hdr_rec.asset_id;
h_fiscal_year := p_dpr_in.y_end;
h_period_num := p_dpr_in.p_cl_end;

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'fiscal_year:period_num', h_fiscal_year||':'||h_period_num, p_log_level_rec => p_log_level_rec);
end if;

/* Apply MRC related feature */
if p_mrc_sob_type_code <> 'R' then

  open GET_PERIOD_COUNTER;
  fetch GET_PERIOD_COUNTER into h_period_counter;
  close GET_PERIOD_COUNTER;
else
  open GET_PERIOD_COUNTER_MRC;
  fetch GET_PERIOD_COUNTER_MRC into h_period_counter;
  close GET_PERIOD_COUNTER_MRC;
end if;

h_period_counter := h_period_counter + 1;

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn, 'h_set_of_books_id:period_counter', h_set_of_books_id||':'||h_period_counter, p_log_level_rec => p_log_level_rec);
end if;

if nvl(p_track_member_eofy_table.count,0) > 0 then
  p_track_member_eofy_table.delete;
  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'p_track_member_eofy_table is deleted', 1, p_log_level_rec => p_log_level_rec);
  end if;
end if;

j := 0;
-- Loop for all member populated above
For i in 1 .. p_track_member_table.COUNT loop

  if p_track_member_table(i).group_asset_id = h_group_asset_id and
     p_track_member_table(i).period_counter = h_period_counter and
     nvl(p_track_member_table(i).set_of_books_id,-99) = nvl(h_set_of_books_id,-99) then

     j := j + 1;
     h_member_asset_id := p_track_member_table(i).member_asset_id;
     h_cost := p_track_member_table(i).cost;
     h_salvage_value := p_track_member_table(i).salvage_value;
     h_recoverable_cost := p_track_member_table(i).recoverable_cost;
     h_adjusted_cost := p_track_member_table(i).adjusted_cost;
     h_eofy_reserve := p_track_member_table(i).eofy_reserve;
     if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '+++ member_eofy_rsv:Folloings are stored +++', '+++', p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'set_of_books_id:group_asset_id:member_asset_id', h_set_of_books_id||':'||h_group_asset_id||':'||h_member_asset_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'fiscal_year', h_fiscal_year, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'cost:salvage:rec_cost:adj_cost:eofy_rsv',
                                      h_cost||':'||h_salvage_value||':'||h_recoverable_cost||':'||h_adjusted_cost||':'||h_eofy_reserve, p_log_level_rec => p_log_level_rec);
     end if;

     p_track_member_eofy_table(j).group_asset_id := h_group_asset_id;
     p_track_member_eofy_table(j).member_asset_id := h_member_asset_id;
--     p_track_member_eofy_table(j).fiscal_year := h_fiscal_year;
     p_track_member_eofy_table(j).cost := h_cost;
     p_track_member_eofy_table(j).salvage_value := h_salvage_value;
     p_track_member_eofy_table(j).recoverable_cost := h_recoverable_cost;
     p_track_member_eofy_table(j).adjusted_cost := h_adjusted_cost;
     p_track_member_eofy_table(j).eofy_reserve := h_eofy_reserve;
     p_track_member_eofy_table(j).set_of_books_id := h_set_of_books_id;

  end if;

END LOOP;

return(true);

exception
  when member_eofy_rsv_err then
    fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return(false);

end member_eofy_rsv;

--+=====================================================================
-- Function: populate_member_assets_table
--
--  This function will be called to extend member assets PL/SQL table
--  to process faxcde correctly.
--  When this function is called, allocation calculation will be
--  made from group DPIS to one period before when recalculation will start
--
--+=====================================================================

FUNCTION populate_member_assets_table(p_asset_hdr_rec           in FA_API_TYPES.asset_hdr_rec_type,
                                      p_asset_fin_rec_new       in FA_API_TYPES.asset_fin_rec_type,
                                      p_populate_for_recalc_period  in varchar2,
                                      p_amort_start_date        in date,
                                      p_recalc_start_fy         in number,
                                      p_recalc_start_period_num in number,
                                      p_no_allocation_for_last  in varchar2,
                                      p_mrc_sob_type_code       in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

--* Local variables used in this process
h_book_type_code             varchar2(30);
h_set_of_books_id            number;
h_group_asset_id             number;
h_group_dpis                 date;
h_group_dpis_period_counter  number;
h_group_dpis_fiscal_year     number;
h_group_dpis_period_num      number;
h_amort_period_counter       number;
h_recalc_period_counter      number;
h_length_of_loop             number;
h_processing_period_counter  number;
h_processing_fiscal_year     number;
h_processing_period_num      number;
h_cur_period_counter         number;

h_first_period_counter     number;

-- Processing member information
h_member_asset_id            number;
h_new_cost                   number;
h_new_salvage_value          number;
h_new_recoverable_cost       number;
h_new_adjusted_rec_cost      number;
h_new_eofy_recoverable_cost  number;
h_new_eop_recoverable_cost   number;
h_new_eofy_salvage_value     number;
h_new_eop_salvage_value      number;
h_depreciate_flag            varchar2(3);

h_old_cost                   number;
h_old_salvage_value          number;
h_old_recoverable_cost       number;
h_old_adjusted_cost          number;
h_old_adjusted_rec_cost      number;
h_eofy_reserve               number;

-- variables for bs table
h_fiscal_year                number;
h_period_num                 number;
h_deprn_method_code          varchar(30);
h_life_in_months             number;
h_calendar_period_open_date  date;
h_calendar_period_close_date date;
h_group_cost                 number;
h_group_adjusted_rec_cost    number;
h_group_salvage_value        number;
h_group_adjusted_cost        number;
h_group_recoverable_cost     number;
h_group_deprn_amount         number;
h_group_ytd_deprn            number;
h_group_deprn_reserve        number;
h_group_bonus_deprn_amount   number;
h_group_bonus_ytd_deprn      number;
h_group_bonus_deprn_reserve  number;
h_group_system_deprn_amount  number;
h_group_system_bonus_deprn   number;
h_group_eofy_reserve         number;
h_group_eofy_rec_cost        number;
h_group_eofy_salvage_value   number;
h_group_deprn_override       varchar2(1);
h_group_bonus_rule           varchar2(30);
h_group_recognize_gain_loss  varchar2(30);

h_temp_system_deprn_amount   number;
h_temp_system_bonus_deprn    number;

h_perd_ctr_fully_retired     number;
h_perd_ctr_fully_reserved    number;

-- Parameters for CALC_REDUCTION_AMOUNT
h_half_year_rule_flag        varchar2(1);
h_change_in_cost             number;
h_change_in_cost_to_reduce   number;
h_total_change_in_cost       number;
h_net_proceeds               number;
h_net_proceeds_to_reduce     number;
h_total_net_proceeds         number;
h_first_half_cost            number;
h_first_half_cost_to_reduce  number;
h_second_half_cost           number;
h_second_half_cost_to_reduce number;

h_apply_reduction_flag       varchar2(1);
h_reduction_amount           number;
h_fy_begin_nbv               number;
h_check_amount               number;
h_reduction_rate             number;

h_group_adj_expense          number;
h_group_adj_bonus_expense    number;

h_periodic_expense           number;
h_periodic_bonus_expense     number;

h_group_deprn_basis          varchar2(4);
h_group_exclude_salvage      varchar2(1);
h_group_deprn_amount_parm    number;
h_group_bonus_amount_parm    number;
h_tracking_method            varchar2(30);
h_allocate_to_fully_rsv_flag varchar2(1);
h_allocate_to_fully_ret_flag varchar2(1);
h_excess_allocation_option   varchar2(30);
h_depreciation_option        varchar2(30);
h_member_rollup_flag         varchar2(1);
h_subtraction_flag           varchar2(1);
h_eofy_flag                  varchar2(1);

h_deprn_calendar             varchar2(15);
h_fiscal_year_name           varchar2(30);
h_period_per_fiscal_year     number;

h_find_flag_1                boolean := FALSE;
h_find_flag_2                boolean := FALSE;
h_find_flag_3                boolean := FALSE;

x_new_deprn_amount           number;
x_new_bonus_amount           number;

l_new_ind                    number;
l_processing_ind             binary_integer;
k                            binary_integer;
h_deprn_source_code          varchar2(15);
h_deprn_reserve              number;
h_ytd_deprn                  number;
h_bonus_deprn_reserve        number;
h_bonus_ytd_deprn            number;

--* variables for Delta
h_trans_exists_flag          boolean := FALSE;
h_transaction_header_id      number;
h_delta_cost                 number;
h_delta_adjusted_cost        number; -- Bug 8484007
h_new_delta_adjusted_cost    number; -- Bug 8484007
h_delta_recoverable_cost     number;
h_new_limit_type             varchar2(15);
h_old_limit_type             varchar2(15);
h_new_deprn_limit            number;
h_new_deprn_limit_amount     number;
h_new_group_asset_id         number;
h_new_perd_ctr_ret           number;

h_adj_cost                   number;
h_adj_rec_cost               number;
h_adj_salvage_value          number;
h_temp_limit_amount          number;

h_transaction_type_code      varchar2(20);
h_transaction_key            varchar2(2); -- Bug 8484007
h_adj_eofy_reserve           number;
h_new_eofy_reserve           number;
h_adj_reserve_retired        number;
h_new_reserve_retired        number;
h_recognize_gain_loss        varchar2(30);
h_eofy_reserve_zero          varchar2(1);

--* To control Cache call
h_old_deprn_method_code          varchar(30) := NULL;
h_old_life_in_months             number := -99;

h_temp_fiscal_year           number;
h_temp_period_num            number;

h_exclude_fully_rsv_flag     varchar2(1);

--* Check reclassed member assets
h_max_thid_in_this_group     number;
h_max_thid_in_other_group    number;
h_skip_control               boolean := false;

--* Exception
x_rtn_code                   number;
l_calling_fn                 varchar2(50) := 'fa_track_member_pvt.populate_member_assets_table';
pop_mem_table_err            exception;


--* Cursor to get period counter from date
cursor GET_FY_PERDNUM(p_date date) is
  select FY.fiscal_year,
         DP.period_num
    from fa_fiscal_year FY,
         fa_calendar_periods DP
   where FY.fiscal_year_name = h_fiscal_year_name
     and DP.calendar_type = h_deprn_calendar
     and DP.end_date <= FY.end_date
     and p_date >= DP.start_date
     and p_date <= DP.end_date
     and p_date >= FY.start_date
     and p_date <= FY.end_date;

--* Cursor to populate member assets exist at the period
/* Modified for bug 7195989
This cursor returns asset_ids of which are part of the group in the given period.
a . Column "max_trx_id_in_this_group" is the max(transaction_header_id) for an asset in the given period
    and when asset is member of the current group. In line view "bk_max" fetches such record.
b. Column "max_trx_id_in_other_group" is the max(transaction_header_id) for an asset in the given period
    and when asset is NOT member of the current group.

To get max(transaction_header_id) for in current and other group, we used in line views bk_max and
   bk_other_max.

Same logic applies to cursor GET_MEMBER_ASSETS_MRC as well
*/
cursor GET_MEMBER_ASSETS(p_fiscal_year number,p_period_num number) is
  select distinct BK.ASSET_ID, AD.asset_number,
         bk_max.transaction_header_id_in as max_trx_id_in_this_group,
         bk_other_max.transaction_header_id_in as max_trx_id_in_other_group
    from FA_BOOKS BK,
         FA_ADDITIONS_B AD,
      (
      select distinct bk_in.asset_id, bk_in.book_type_code,
             first_value(bk_in.transaction_header_id_in)
             over (partition by bk_in.asset_id, bk_in.book_type_code
             order by bk_in.transaction_header_id_in desc nulls last) as transaction_header_id_in
      from   fa_books bk_in,
             FA_TRANSACTION_HEADERS TH1,
             FA_CALENDAR_PERIODS DP1,
             FA_FISCAL_YEAR FY
      where TH1.book_type_code = BK_in.book_type_code
       and DP1.calendar_type = h_deprn_calendar
       and DP1.period_num = p_period_num
       and FY.fiscal_year_name = h_fiscal_year_name
       and FY.fiscal_year = p_fiscal_year
       and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) <= DP1.end_date
       and DP1.start_date >= FY.start_date
       and DP1.end_date <= FY.end_date
       and BK_in.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID
       and bk_in.book_type_code = h_book_type_code
       and bk_in.group_asset_id = h_group_asset_id
      ) bk_max,
      (
      select distinct bk_in.asset_id, bk_in.book_type_code,
             first_value(bk_in.transaction_header_id_in)
             over (partition by bk_in.asset_id, bk_in.book_type_code
             order by bk_in.transaction_header_id_in desc nulls last) as transaction_header_id_in
      from   fa_books bk_in,
             FA_TRANSACTION_HEADERS TH1,
             FA_CALENDAR_PERIODS DP1,
             FA_FISCAL_YEAR FY
      where TH1.book_type_code = BK_in.book_type_code
       and DP1.calendar_type = h_deprn_calendar
       and DP1.period_num = p_period_num
       and FY.fiscal_year_name = h_fiscal_year_name
       and FY.fiscal_year = p_fiscal_year
       and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) <= DP1.end_date
       and DP1.start_date >= FY.start_date
       and DP1.end_date <= FY.end_date
       and BK_in.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID
       and bk_in.book_type_code = h_book_type_code
       and nvl(bk_in.group_asset_id,-1) <> h_group_asset_id
       and (bk_in.asset_id, bk_in.book_type_code) in
           (
            select distinct bk_in2.asset_id, bk_in2.book_type_code
            from   fa_books bk_in2,
                   FA_TRANSACTION_HEADERS TH2,
                   FA_CALENDAR_PERIODS DP2,
                   FA_FISCAL_YEAR FY2
            where TH1.book_type_code = BK_in2.book_type_code
             and DP2.calendar_type = h_deprn_calendar
             and DP2.period_num = p_period_num
             and FY2.fiscal_year_name = h_fiscal_year_name
             and FY2.fiscal_year = p_fiscal_year
             and nvl(TH2.amortization_start_date,TH2.transaction_date_entered) <= DP1.end_date
             and DP2.start_date >= FY.start_date
             and DP2.end_date <= FY.end_date
             and BK_in2.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID
             and bk_in2.book_type_code = h_book_type_code
             and bk_in2.group_asset_id = h_group_asset_id
           )
      ) bk_other_max
      where BK.book_type_code = h_book_type_code
      and BK.group_asset_id = h_group_asset_id
      and AD.asset_id = BK.asset_id
      and AD.asset_type = 'CAPITALIZED'
      and bk_max.asset_id = bk.asset_id
      and bk_max.book_type_code = bk.book_type_code
      and bk_other_max.asset_id(+) = bk.asset_id
      and bk_other_max.book_type_code(+) = bk.book_type_code
      order by AD.asset_number asc;

cursor GET_MEMBER_ASSETS_MRC(p_fiscal_year number,p_period_num number) is
  select distinct BK.ASSET_ID, AD.asset_number,
         bk_max.transaction_header_id_in as max_trx_id_in_this_group,
         bk_other_max.transaction_header_id_in as max_trx_id_in_other_group
    from FA_MC_BOOKS BK,
         FA_ADDITIONS_B AD,
      (
      select distinct bk_in.asset_id, bk_in.book_type_code,
             first_value(bk_in.transaction_header_id_in)
             over (partition by bk_in.asset_id, bk_in.book_type_code
             order by bk_in.transaction_header_id_in desc nulls last) as transaction_header_id_in
      from   fa_mc_books bk_in,
             FA_TRANSACTION_HEADERS TH1,
             FA_CALENDAR_PERIODS DP1,
             FA_FISCAL_YEAR FY
      where TH1.book_type_code = BK_in.book_type_code
       and DP1.calendar_type = h_deprn_calendar
       and DP1.period_num = p_period_num
       and FY.fiscal_year_name = h_fiscal_year_name
       and FY.fiscal_year = p_fiscal_year
       and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) <= DP1.end_date
       and DP1.start_date >= FY.start_date
       and DP1.end_date <= FY.end_date
       and BK_in.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID
       and bk_in.book_type_code = h_book_type_code
       and bk_in.group_asset_id = h_group_asset_id
       and bk_in.set_of_books_id = h_set_of_books_id
      ) bk_max,
      (
      select distinct bk_in.asset_id, bk_in.book_type_code,
             first_value(bk_in.transaction_header_id_in)
             over (partition by bk_in.asset_id, bk_in.book_type_code
             order by bk_in.transaction_header_id_in desc nulls last) as transaction_header_id_in
      from   fa_mc_books bk_in,
             FA_TRANSACTION_HEADERS TH1,
             FA_CALENDAR_PERIODS DP1,
             FA_FISCAL_YEAR FY
      where TH1.book_type_code = BK_in.book_type_code
       and DP1.calendar_type = h_deprn_calendar
       and DP1.period_num = p_period_num
       and FY.fiscal_year_name = h_fiscal_year_name
       and FY.fiscal_year = p_fiscal_year
       and nvl(TH1.amortization_start_date,TH1.transaction_date_entered) <= DP1.end_date
       and DP1.start_date >= FY.start_date
       and DP1.end_date <= FY.end_date
       and BK_in.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID
       and bk_in.book_type_code = h_book_type_code
       and nvl(bk_in.group_asset_id,-1) <> h_group_asset_id
       and bk_in.set_of_books_id = h_set_of_books_id
       and (bk_in.asset_id, bk_in.book_type_code) in
           (
            select distinct bk_in2.asset_id, bk_in2.book_type_code
            from   fa_mc_books bk_in2,
                   FA_TRANSACTION_HEADERS TH2,
                   FA_CALENDAR_PERIODS DP2,
                   FA_FISCAL_YEAR FY2
            where TH1.book_type_code = BK_in2.book_type_code
             and DP2.calendar_type = h_deprn_calendar
             and DP2.period_num = p_period_num
             and FY2.fiscal_year_name = h_fiscal_year_name
             and FY2.fiscal_year = p_fiscal_year
             and nvl(TH2.amortization_start_date,TH2.transaction_date_entered) <= DP1.end_date
             and DP2.start_date >= FY.start_date
             and DP2.end_date <= FY.end_date
             and BK_in2.TRANSACTION_HEADER_ID_IN = TH1.TRANSACTION_HEADER_ID
             and bk_in2.book_type_code = h_book_type_code
             and bk_in2.group_asset_id = h_group_asset_id
             and bk_in2.set_of_books_id = h_set_of_books_id
           )
      ) bk_other_max
      where BK.book_type_code = h_book_type_code
      and BK.group_asset_id = h_group_asset_id
      and BK.set_of_books_id = h_set_of_books_id
      and AD.asset_id = BK.asset_id
      and AD.asset_type = 'CAPITALIZED'
      and bk_max.asset_id = bk.asset_id
      and bk_max.book_type_code = bk.book_type_code
      and bk_other_max.asset_id(+) = bk.asset_id
      and bk_other_max.book_type_code(+) = bk.book_type_code
      order by AD.asset_number asc;


--* Check fully reserve or fully retired
cursor CHK_FULLY_RESERVE_RETIRED(p_asset_id number) is
  select bk.allocate_to_fully_ret_flag,
         bk.allocate_to_fully_rsv_flag,
         bk.period_counter_fully_retired,
         bk.period_counter_fully_reserved
    from fa_books bk
   where bk.book_type_code = h_book_type_code
     and bk.asset_id = p_asset_id
     and bk.date_ineffective is null;

cursor CHK_FULLY_RESERVE_RETIRED_MRC(p_asset_id number) is
  select bk.allocate_to_fully_ret_flag,
         bk.allocate_to_fully_rsv_flag,
         bk.period_counter_fully_retired,
         bk.period_counter_fully_reserved
    from fa_mc_books bk
   where bk.book_type_code = h_book_type_code
     and bk.asset_id = p_asset_id
     and bk.date_ineffective is null
     and bk.set_of_books_id = h_set_of_books_id;

--* Get all transaction headers exists in the specified period
cursor ALL_TRANS_IN_PERIOD(p_fiscal_year number, p_period_num number, p_member_asset_id number) is
  select TH.TRANSACTION_HEADER_ID, TH.TRANSACTION_TYPE_CODE,TH.TRANSACTION_KEY --Bug 8484007
    from FA_TRANSACTION_HEADERS TH,
         FA_CALENDAR_PERIODS DP,
         FA_FISCAL_YEAR FY
   where DP.calendar_type = h_deprn_calendar
     and DP.period_num = p_period_num
     and FY.fiscal_year_name = h_fiscal_year_name
     and FY.fiscal_year = p_fiscal_year
     and TH.asset_id = p_member_asset_id
     and TH.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN', 'TRANSFER', 'TRANSFER IN/VOID',
--
--                                          'RECLASS', 'UNIT ADJUSTMENT','REINSTATEMENT')
                                         'RECLASS', 'UNIT ADJUSTMENT')
     and nvl(TH.amortization_start_date,TH.transaction_date_entered) between DP.start_date and DP.end_date
     and DP.start_date >= FY.start_date
     and DP.end_date <= FY.end_date
order by nvl(TH.amortization_start_date,TH.transaction_date_entered), TH.transaction_header_id asc;

--* Get delta between the amounts before the transaction and after the transaction
cursor GET_DELTA_FOR_MEMBER(p_member_asset_id number, p_transaction_header_id number) is
  select BK_IN.COST - nvl(BK_OUT.COST,0) delta_cost,
         BK_IN.RECOVERABLE_COST - nvl(BK_OUT.RECOVERABLE_COST,0) delta_rec_cost,
         BK_IN.DEPRN_LIMIT_TYPE new_limit_type,
         BK_OUT.DEPRN_LIMIT_TYPE old_limit_type,
         BK_IN.ALLOWED_DEPRN_LIMIT new_deprn_limit,
         BK_IN.ALLOWED_DEPRN_LIMIT_AMOUNT new_deprn_limit_amount,
         BK_IN.DEPRECIATE_FLAG depreciate_flag,
         BK_IN.group_asset_id group_asset_id,
         BK_IN.period_counter_fully_retired period_counter_fully_retired,
         bk_in.adjusted_cost -nvl(bk_out.adjusted_cost, 0) delta_adjusted_cost -- Bug 8484007
    from FA_BOOKS BK_IN,
         FA_BOOKS BK_OUT
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.group_asset_id = h_group_asset_id
     and BK_IN.asset_id = h_member_asset_id
     and BK_IN.transaction_header_id_in = p_transaction_header_id
     and BK_OUT.book_type_code(+) = BK_IN.book_type_code
     and BK_OUT.group_asset_id(+) = BK_IN.group_Asset_id
     and BK_OUT.asset_id(+) = BK_IN.asset_id
     and BK_OUT.transaction_header_id_out(+) = BK_IN.transaction_header_id_in;

cursor GET_DELTA_FOR_MEMBER_MRC(p_member_asset_id number, p_transaction_header_id number) is
  select BK_IN.COST - nvl(BK_OUT.COST,0) delta_cost,
         BK_IN.RECOVERABLE_COST - nvl(BK_OUT.RECOVERABLE_COST,0) delta_rec_cost,
         BK_IN.DEPRN_LIMIT_TYPE new_limit_type,
         BK_OUT.DEPRN_LIMIT_TYPE old_limit_type,
         BK_IN.ALLOWED_DEPRN_LIMIT new_deprn_limit,
         BK_IN.ALLOWED_DEPRN_LIMIT_AMOUNT old_deprn_limit,
         BK_IN.DEPRECIATE_FLAG depreciate_flag,
         BK_IN.group_Asset_id group_asset_id,
         BK_IN.period_counter_fully_retired period_counter_fully_retired,
         bk_in.adjusted_cost -nvl(bk_out.adjusted_cost,0) delta_adjusted_cost -- Bug 8484007
    from FA_MC_BOOKS BK_IN,
         FA_MC_BOOKS BK_OUT
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.group_asset_id = h_group_asset_id
     and BK_IN.asset_id = h_member_asset_id
     and BK_IN.transaction_header_id_in = p_transaction_header_id
     and BK_IN.set_of_books_id = h_set_of_books_id
     and BK_OUT.book_type_code(+) = BK_IN.book_type_code
     and BK_OUT.group_asset_id(+) = BK_IN.group_Asset_id
     and BK_OUT.asset_id(+) = BK_IN.asset_id
     and BK_OUT.transaction_header_id_out(+) = BK_IN.transaction_header_id_in
     and BK_OUT.set_of_books_id(+) = h_set_of_books_id ; --Bug 8941132

--* Cursor to get eofy_reserve adjustment from fa_retirements
cursor GET_RETIREMENTS(p_thid number) is
  select recognize_gain_loss,
         nvl(eofy_reserve,0),
         (-1)*nvl(reserve_retired,0)
    from fa_retirements
   where transaction_header_id_in = p_thid;

cursor GET_RETIREMENTS_MRC(p_thid number) is
  select recognize_gain_loss,
         nvl(eofy_reserve,0),
         (-1)*nvl(reserve_retired,0)
    from fa_mc_retirements
   where transaction_header_id_in = p_thid
     and set_of_books_id = h_set_of_books_id;

--* Cursor to get reserve retired for reinstatement
cursor GET_REINSTATEMENT(p_thid number) is
  select recognize_gain_loss,
         nvl(eofy_reserve,0),
         nvl(reserve_retired,0)
    from fa_retirements
   where transaction_header_id_out = p_thid;

cursor GET_REINSTATEMENT_MRC(p_thid number) is
  select recognize_gain_loss,
         nvl(eofy_reserve,0),
         nvl(reserve_retired,0)
    from fa_mc_retirements
   where transaction_header_id_out = p_thid
     and set_of_books_id = h_set_of_books_id;

--* Cursor to query reserve/ytd at addition
cursor GET_RESERVE_AT_ADDITION(p_asset_id number, p_period_counter number) is
  select deprn_source_code,
         ytd_deprn,
         deprn_reserve
    from fa_deprn_summary
   where book_type_code = h_book_type_code
     and asset_id = p_asset_id
     and period_counter = p_period_counter;

cursor GET_RESERVE_AT_ADDITION_MRC(p_asset_id number, p_period_counter number) is
  select deprn_source_code,
         ytd_deprn,
         deprn_reserve
    from fa_mc_deprn_summary
   where book_type_code = h_book_type_code
     and asset_id = p_asset_id
     and period_counter = p_period_counter
     and set_of_books_id = h_set_of_books_id;

--* Get Catchup Expense for the group asset
cursor GET_ADJ_EXPENSE(p_period_counter number) is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_adjustments adj
    where adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = p_period_counter;

cursor GET_ADJ_EXPENSE_MRC(p_period_counter number) is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))),
          sum(decode(adj.adjustment_type,'BONUS EXPENSE',
                     decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount)))
     from fa_mc_adjustments adj
    where adj.asset_id = h_group_asset_id
      and adj.book_type_code = h_book_type_code
      and adj.period_counter_adjusted = p_period_counter
      and set_of_books_id = h_set_of_books_id;

--* cursor to populate Group Assets record from FA_BOOKS_SUMMARY
cursor GET_GROUP_INFO(p_period_counter number) is
  select FISCAL_YEAR,
         PERIOD_NUM,
         CALENDAR_PERIOD_OPEN_DATE,
         CALENDAR_PERIOD_CLOSE_DATE,
         COST,
         SALVAGE_VALUE,
         RECOVERABLE_COST,
         ADJUSTED_RECOVERABLE_COST,
         ADJUSTED_COST,
         DEPRN_METHOD_CODE,
         LIFE_IN_MONTHS,
         BONUS_RULE,
         DEPRN_AMOUNT,
         YTD_DEPRN,
         DEPRN_RESERVE,
         BONUS_DEPRN_AMOUNT,
         BONUS_YTD_DEPRN,
         BONUS_DEPRN_RESERVE,
         DEPRN_OVERRIDE_FLAG,
--         EOFY_RECOVERABLE_COST,
--         EOFY_SALVAGE_VALULE,
         EOFY_RESERVE,
         SYSTEM_DEPRN_AMOUNT,
         SYSTEM_BONUS_DEPRN_AMOUNT
    from FA_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and period_counter = p_period_counter;

cursor GET_GROUP_INFO_MRC(p_period_counter number) is
  select FISCAL_YEAR,
         PERIOD_NUM,
         CALENDAR_PERIOD_OPEN_DATE,
         CALENDAR_PERIOD_CLOSE_DATE,
         COST,
         SALVAGE_VALUE,
         RECOVERABLE_COST,
         ADJUSTED_RECOVERABLE_COST,
         ADJUSTED_COST,
         DEPRN_METHOD_CODE,
         LIFE_IN_MONTHS,
         BONUS_RULE,
         DEPRN_AMOUNT,
         YTD_DEPRN,
         DEPRN_RESERVE,
         BONUS_DEPRN_AMOUNT,
         BONUS_YTD_DEPRN,
         BONUS_DEPRN_RESERVE,
         DEPRN_OVERRIDE_FLAG,
--         EOFY_RECOVERABLE_COST,
--         EOFY_SALVAGE_VALULE,
         EOFY_RESERVE,
         SYSTEM_DEPRN_AMOUNT,
         SYSTEM_BONUS_DEPRN_AMOUNT
    from FA_MC_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and period_counter = p_period_counter
     and set_of_books_id = h_set_of_books_id;

cursor GET_GROUP_SYSTEM_INFO(p_fiscal_year number, p_period_counter_end number) is
  select sum(nvl(SYSTEM_DEPRN_AMOUNT,0)),
         sum(nvl(SYSTEM_BONUS_DEPRN_AMOUNT,0))
    from FA_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and fiscal_year = p_fiscal_year
     and period_counter <= p_period_counter_end;

cursor GET_GROUP_SYSTEM_INFO_MRC(p_fiscal_year number, p_period_counter_end number) is
  select sum(nvl(SYSTEM_DEPRN_AMOUNT,0)),
         sum(nvl(SYSTEM_BONUS_DEPRN_AMOUNT,0))
    from FA_MC_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and fiscal_year = p_fiscal_year
     and period_counter <= p_period_counter_end
     and set_of_books_id = h_set_of_books_id;

--* cursor to populate Group Assets record (Temporary)
cursor GET_GROUP_SALVAGE(p_fiscal_year number, p_period_num number) is
  select SALVAGE_VALUE,
         RECOVERABLE_COST
    from FA_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and fiscal_year = p_fiscal_year
     and period_num = p_period_num;

cursor GET_GROUP_SALVAGE_MRC(p_fiscal_year number, p_period_num number) is
  select SALVAGE_VALUE,
         RECOVERABLE_COST
    from FA_MC_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and asset_id = h_group_asset_id
     and fiscal_year = p_fiscal_year
     and period_num = p_period_num
     and set_of_books_id = h_set_of_books_id;

-- cursor to query fa_books_summary for this member/period
cursor GET_PRV_ROW_BS is
  select COST,
         SALVAGE_VALUE,
         RECOVERABLE_COST,
         ADJUSTED_COST,
         ADJUSTED_RECOVERABLE_COST,
         DEPRN_RESERVE,
         BONUS_DEPRN_RESERVE,
         YTD_DEPRN,
         BONUS_YTD_DEPRN,
         EOFY_RESERVE
    from FA_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and group_asset_id = h_group_asset_id
     and period_counter = h_processing_period_counter -1
     and asset_id = h_member_asset_id;

cursor GET_PRV_ROW_BS_MRC is
  select COST,
         SALVAGE_VALUE,
         RECOVERABLE_COST,
         ADJUSTED_COST,
         ADJUSTED_RECOVERABLE_COST,
         DEPRN_RESERVE,
         BONUS_DEPRN_RESERVE,
         YTD_DEPRN,
         BONUS_YTD_DEPRN,
         EOFY_RESERVE
    from FA_MC_BOOKS_SUMMARY
   where book_type_code = h_book_type_code
     and group_asset_id = h_group_asset_id
     and period_counter = h_processing_period_counter -1
     and asset_id = h_member_asset_id
     and set_of_books_id = h_set_of_books_id;

--* Get new group asset id
cursor GET_NEW_GROUP(p_member_asset_id number, p_transaction_header_id number) is
  select BK_IN.group_asset_id group_asset_id
    from FA_BOOKS BK_IN,
         FA_BOOKS BK_OUT
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.asset_id = h_member_asset_id
     and BK_IN.transaction_header_id_in = p_transaction_header_id
     and BK_OUT.book_type_code(+) = BK_IN.book_type_code
     and BK_OUT.group_asset_id(+) = h_group_Asset_id
     and BK_OUT.asset_id(+) = BK_IN.asset_id
     and BK_OUT.transaction_header_id_out(+) = BK_IN.transaction_header_id_in;

cursor GET_NEW_GROUP_MRC(p_member_asset_id number, p_transaction_header_id number) is
  select BK_IN.group_Asset_id group_asset_id
    from FA_MC_BOOKS BK_IN,
         FA_MC_BOOKS BK_OUT
   where BK_IN.book_type_code = h_book_type_code
     and BK_IN.asset_id = h_member_asset_id
     and BK_IN.transaction_header_id_in = p_transaction_header_id
     and BK_IN.set_of_books_id = h_set_of_books_id
     and BK_OUT.book_type_code(+) = BK_IN.book_type_code
     and BK_OUT.group_asset_id(+) = h_group_Asset_id
     and BK_OUT.asset_id(+) = BK_IN.asset_id
     and BK_OUT.transaction_header_id_out(+) = BK_IN.transaction_header_id_in
     and BK_OUT.set_of_books_id(+) = h_set_of_books_id; --Bug 8941132

--* Structure to call Deprn Basis Rule
fa_rule_in      fa_std_types.fa_deprn_rule_in_struct;
fa_rule_out     fa_std_types.fa_deprn_rule_out_struct;


BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '+++ Populate Member Assets Table ++ is Started ++', '+++', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_populate_for_recalc_period', p_populate_for_recalc_period, p_log_level_rec => p_log_level_rec);
   end if;

   -- Get basic information from input parameters
   h_book_type_code := p_asset_hdr_rec.book_type_code;
   h_group_asset_id := p_asset_hdr_rec.asset_id;
   h_group_dpis := p_asset_fin_rec_new.date_placed_in_service;
   h_set_of_books_id := p_asset_hdr_rec.set_of_books_id;

   -- Query Group Asset DPIS' period counter and amort date's period counter from FA_BOOKS
   select deprn_calendar, fiscal_year_name
   into   h_deprn_calendar, h_fiscal_year_name
   from   fa_book_controls
   where  book_type_code = h_book_type_code;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'h_deprn_calendar:h_fiscal_year_name',
                      h_deprn_calendar||':'||h_fiscal_year_name, p_log_level_rec => p_log_level_rec);
   end if;

   if not fa_cache_pkg.fazcct(h_deprn_calendar, p_log_level_rec => p_log_level_rec) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Calendar Cache call is failed', '+++', p_log_level_rec => p_log_level_rec);
      end if;
      raise pop_mem_table_err;
   end if;

   h_period_per_fiscal_year := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   open GET_FY_PERDNUM(p_amort_start_date);
   fetch GET_FY_PERDNUM into h_temp_fiscal_year,h_temp_period_num;

   if GET_FY_PERDNUM%NOTFOUND then
      close GET_FY_PERDNUM;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, '++ No record is found for the date (1)', p_amort_start_date);
      end if;

      raise pop_mem_table_err;

   end if;

   close GET_FY_PERDNUM;

   h_amort_period_counter := h_temp_fiscal_year*h_period_per_fiscal_year+h_temp_period_num;
   h_recalc_period_counter := p_recalc_start_fy*h_period_per_fiscal_year+p_recalc_start_period_num;

   h_temp_fiscal_year := 0;
   h_temp_period_num := 0;

   if nvl(p_populate_for_recalc_period,'N') = 'N' then

      open GET_FY_PERDNUM(h_group_dpis);
      fetch GET_FY_PERDNUM into h_temp_fiscal_year,h_temp_period_num;

      if GET_FY_PERDNUM%NOTFOUND then
         close GET_FY_PERDNUM;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ No record is found for the date (2)', h_group_dpis);
         end if;
         raise pop_mem_table_err;
      end if;

      close GET_FY_PERDNUM;

      h_group_dpis_period_counter := h_temp_fiscal_year*h_period_per_fiscal_year+h_temp_period_num;
      h_group_dpis_fiscal_year := h_temp_fiscal_year;
      h_group_dpis_period_num := h_temp_period_num;

   else
      h_group_dpis_period_counter := h_recalc_period_counter;
      h_group_dpis_fiscal_year := p_recalc_start_fy;
      h_group_dpis_period_num := p_recalc_start_period_num;

   end if;

   h_processing_fiscal_year := h_group_dpis_fiscal_year;
   h_processing_period_num := h_group_dpis_period_num -1 ;

   -- If this is Reporting Books, get set of books id
   if p_mrc_sob_type_code <> 'R' then

      select period_counter
        into h_cur_period_Counter
        from fa_deprn_periods
       where book_type_Code = h_book_type_code
         and period_close_date is null;

      select exclude_fully_rsv_flag,recognize_gain_loss
        into h_exclude_fully_rsv_flag,h_group_recognize_gain_loss
        from fa_books
       where book_type_code = h_book_type_code
         and asset_id = h_group_asset_id
         and date_ineffective is null;

   else -- Reporting Book

      select period_counter
        into h_cur_period_Counter
        from fa_mc_deprn_periods
       where book_type_Code = h_book_type_code
         and period_close_date is null
         and set_of_books_id = h_set_of_books_id;

      select exclude_fully_rsv_flag,recognize_gain_loss
        into h_exclude_fully_rsv_flag,h_group_recognize_gain_loss
        from fa_mc_books
       where book_type_code = h_book_type_code
         and asset_id = h_group_asset_id
         and date_ineffective is null
         and set_of_books_id = h_set_of_books_id;
   end if;

   if h_group_dpis_period_counter is null or h_amort_period_counter is null then
      raise pop_mem_table_err;
   end if;

   -- Prepare Loop for until recalculation start period so that depreciation engine
   -- can allocate new amounts correctly.
   h_length_of_loop := h_recalc_period_counter - h_group_dpis_period_counter + 1;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'h_group_dpis_period_counter', h_group_dpis_period_counter, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'h_length_of_loop', h_length_of_loop, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'h_period_per_fiscal_year', h_period_per_fiscal_year, p_log_level_rec => p_log_level_rec);
   end if;

   -- Now loop between h_group_dpis_period_counter and h_prv_period_counter to populate
   -- member assets amounts
   For i IN 1.. h_length_of_loop LOOP

      -- Current processing period counter
      h_processing_period_counter := h_group_dpis_period_counter + (i-1);
      h_processing_period_num := h_processing_period_num + 1;

      if h_processing_period_num > h_period_per_fiscal_year then
         h_processing_period_num := 1;
         h_processing_fiscal_year := h_processing_fiscal_year + 1;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'h_processing_period_counter:fiscal_year:period_num',
                          h_processing_period_counter||':'||h_processing_fiscal_year||':'||
                          h_processing_period_num, p_log_level_rec => p_log_level_rec);
      end if;

      -- Check if this period is later than amortization start date.
      -- If so, books_summary table information should be populated from
      -- global variable's table instead of querying table.
      h_find_flag_1 := FALSE;
      h_find_flag_2 := FALSE;
      h_first_period_counter := NULL;

      if h_processing_period_counter >= h_amort_period_counter then

         --* Populate Group Asset information from global variables
         For m IN 1.. fa_amort_pvt.t_period_counter.COUNT LOOP
            if fa_amort_pvt.t_period_counter(m) = h_processing_period_counter then
               h_find_flag_1 := TRUE;
               h_fiscal_year := fa_amort_pvt.t_fiscal_year(m);
               h_period_num := fa_amort_pvt.t_period_num(m);
               h_calendar_period_open_date := fa_amort_pvt.t_calendar_period_open_date(m);
               h_calendar_period_close_date := fa_amort_pvt.t_calendar_period_close_date(m);
               h_group_cost := fa_amort_pvt.t_cost(m);
               h_group_salvage_value := fa_amort_pvt.t_salvage_value(m);
               h_group_recoverable_cost := fa_amort_pvt.t_recoverable_cost(m);
               h_group_adjusted_rec_cost := fa_amort_pvt.t_adjusted_recoverable_cost(m);
               h_group_adjusted_cost := fa_amort_pvt.t_adjusted_cost(m);
               h_deprn_method_code := fa_amort_pvt.t_deprn_method_code(m);
               h_life_in_months := fa_amort_pvt.t_life_in_months(m);
               h_group_bonus_rule := fa_amort_pvt.t_bonus_rule(m);
               h_group_deprn_amount := fa_amort_pvt.t_deprn_amount(m);
               h_group_ytd_deprn := fa_amort_pvt.t_ytd_deprn(m);
               h_group_deprn_reserve := fa_amort_pvt.t_deprn_reserve(m);
               h_group_bonus_deprn_amount := fa_amort_pvt.t_bonus_deprn_amount(m);
               h_group_bonus_ytd_deprn := fa_amort_pvt.t_bonus_ytd_deprn(m);
               h_group_bonus_deprn_reserve := fa_amort_pvt.t_bonus_deprn_reserve(m);
               h_group_deprn_override := fa_amort_pvt.t_deprn_override_flag(m);
               h_group_eofy_reserve := fa_amort_pvt.t_eofy_reserve(m);
               h_group_system_deprn_amount := fa_amort_pvt.t_system_deprn_amount(m);
               h_group_system_bonus_deprn := fa_amort_pvt.t_system_bonus_deprn_amount(m);
            end if;
         End Loop;

         if (h_find_flag_1) then

            For n IN 1.. fa_amort_pvt.t_period_counter.COUNT LOOP

               if fa_amort_pvt.t_fiscal_year(n) = h_fiscal_year - 1 and
                  fa_amort_pvt.t_period_num(n) = h_period_per_fiscal_year then

                  h_find_flag_2 := TRUE;
                  h_group_eofy_rec_cost := fa_amort_pvt.t_recoverable_cost(n);
                  h_group_eofy_salvage_value := fa_amort_pvt.t_salvage_value(n);

               end if;

            End Loop;

         end if;

      end if; -- (if processing period counter >= amort period counter)

      if (p_log_level_rec.statement_level) then
         if (h_find_flag_1) then
            fa_debug_pkg.add(l_calling_fn, 'Memory Table has data for this asset', '+++', p_log_level_rec => p_log_level_rec);
         else
            fa_debug_pkg.add(l_calling_fn, 'Need to query fa_books_summary table due to no data in'||
                             ' memory table','+++', p_log_level_rec => p_log_level_rec);
         end if;
      end if;

      if not (h_find_flag_1) then -- there is no record for this group asset/period in global variables.

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'h_processing_period_counter', h_processing_period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code', p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
         end if;

         if p_mrc_sob_type_code <> 'R' then
            --* Query Group Asset information for this processing period
            open GET_GROUP_INFO(h_processing_period_counter);
            fetch GET_GROUP_INFO into h_fiscal_year
                                    , h_period_num
                                    , h_calendar_period_open_date
                                    , h_calendar_period_close_date
                                    , h_group_cost
                                    , h_group_salvage_value
                                    , h_group_recoverable_cost
                                    , h_group_adjusted_rec_cost
                                    , h_group_adjusted_cost
                                    , h_deprn_method_code
                                    , h_life_in_months
                                    , h_group_bonus_rule
                                    , h_group_deprn_amount
                                    , h_group_ytd_deprn
                                    , h_group_deprn_reserve
                                    , h_group_bonus_deprn_amount
                                    , h_group_bonus_ytd_deprn
                                    , h_group_bonus_deprn_reserve
                                    , h_group_deprn_override
 --                                   , h_group_eofy_rec_cost
 --                                   , h_group_eofy_salvage_value
                                    , h_group_eofy_reserve
                                    , h_group_system_deprn_amount
                                    , h_group_system_bonus_deprn;
            close GET_GROUP_INFO;
         else
            --* Query Group Asset information for this processing period
            open GET_GROUP_INFO_MRC(h_processing_period_counter);
            fetch GET_GROUP_INFO_MRC into h_fiscal_year
                                        , h_period_num
                                        , h_calendar_period_open_date
                                        , h_calendar_period_close_date
                                        , h_group_cost
                                        , h_group_salvage_value
                                        , h_group_recoverable_cost
                                        , h_group_adjusted_rec_cost
                                        , h_group_adjusted_cost
                                        , h_deprn_method_code
                                        , h_life_in_months
                                        , h_group_bonus_rule
                                        , h_group_deprn_amount
                                        , h_group_ytd_deprn
                                        , h_group_deprn_reserve
                                        , h_group_bonus_deprn_amount
                                        , h_group_bonus_ytd_deprn
                                        , h_group_bonus_deprn_reserve
                                        , h_group_deprn_override
 --                                       ,  h_group_eofy_rec_cost
 --                                       , h_group_eofy_salvage_value
                                        , h_group_eofy_reserve
                                        , h_group_system_deprn_amount
                                        , h_group_system_bonus_deprn;
            close GET_GROUP_INFO_MRC;
         end if; -- (p_mrc_sob_type_code)
      end if; -- (h_find_flag)

      if not (h_find_flag_2) then
         -- There is no record for this group and eofy period in global variables.

         if p_mrc_sob_type_code <> 'R' then
            open GET_GROUP_SALVAGE(h_fiscal_year-1, h_period_per_fiscal_year);
            fetch GET_GROUP_SALVAGE into h_group_eofy_salvage_value, h_group_eofy_rec_cost;
            close GET_GROUP_SALVAGE;
         else
            open GET_GROUP_SALVAGE_MRC(h_fiscal_year-1, h_period_per_fiscal_year);
            fetch GET_GROUP_SALVAGE_MRC into h_group_eofy_salvage_value, h_group_eofy_rec_cost;
            close GET_GROUP_SALVAGE_MRC;
         end if;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'h_deprn_method_code:h_life_in_months',
                          h_deprn_method_code||':'||h_life_in_months, p_log_level_rec => p_log_level_rec);
      end if;

      --* Prepare Cache for Method information
      if i <> 1 and
         h_old_deprn_method_code <> h_deprn_method_code and
         nvl(h_old_life_in_months,-99) <> nvl(h_life_in_months,-99) then

         if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Method Cache is called.', '***');
         end if;

         if not fa_cache_pkg.fazccmt(X_method => h_deprn_method_code,
                                     X_life => h_life_in_months, p_log_level_rec => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '++ fa_cache_pkg.fazccmt is errored out ++', '+++', p_log_level_rec => p_log_level_rec);
            end if;

            raise pop_mem_table_err;
         end if;

         h_old_deprn_method_code := h_deprn_method_code;
         h_old_life_in_months := h_life_in_months;
      end if;

      -- Populate Method related information from cache
      h_group_deprn_basis := fa_cache_pkg.fazccmt_record.deprn_basis_rule; -- COST or NBV

      --* Get system deprn amount if subtraction flag is 'Y'
      if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '++ Logic in case the subtraction flag is Y (1)' , '+++');
          fa_debug_pkg.add(l_calling_fn, 'h_processing_fiscal_year', h_processing_fiscal_year, p_log_level_rec => p_log_level_rec);
        end if;

         h_first_period_counter := NULL;
         h_temp_system_deprn_amount := 0;
         h_temp_system_bonus_deprn := 0;

         For m IN 1.. fa_amort_pvt.t_period_counter.COUNT LOOP
           if fa_amort_pvt.t_fiscal_year(m) = h_processing_fiscal_year
              and fa_amort_pvt.t_period_counter(m) <= h_processing_period_counter then

              if h_first_period_counter is null then
                h_first_period_counter := fa_amort_pvt.t_period_counter(m);
              elsif h_first_period_counter > fa_amort_pvt.t_period_counter(m) then
                h_first_period_counter := fa_amort_pvt.t_period_counter(m);
              end if;

              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, '++ Logic in case the subtraction flag is Y (2-1)' , '+++');
                fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_period_counter(m)', fa_amort_pvt.t_period_counter(m));
                fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_system_deprn_amount(m)', fa_amort_pvt.t_system_deprn_amount(m));
                fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_system_bonus_deprn_amount(m)',
                                                             fa_amort_pvt.t_system_bonus_deprn_amount(m));
              end if;

              h_temp_system_deprn_amount := nvl(h_temp_system_deprn_amount,0) + nvl(fa_amort_pvt.t_system_deprn_amount(m),0);
              h_temp_system_bonus_deprn := nvl(h_temp_system_bonus_deprn,0) + nvl(fa_amort_pvt.t_system_bonus_deprn_amount(m),0);

              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, '++ Logic in case the subtraction flag is Y (2-2)' , '+++');
                fa_debug_pkg.add(l_calling_fn, 'h_first_period_counter', h_first_period_counter, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'h_temp_system_deprn:bonus_amount', h_temp_system_deprn_amount||':'||h_temp_system_bonus_deprn, p_log_level_rec => p_log_level_rec);
              end if;
          end if;
        End Loop;

        if h_first_period_counter is null then -- NO summation is calculated from memory table
          if p_mrc_sob_type_code <> 'R' then
            open GET_GROUP_SYSTEM_INFO(h_processing_fiscal_year, h_processing_period_counter);
            fetch GET_GROUP_SYSTEM_INFO into h_group_system_deprn_amount, h_group_system_bonus_deprn;
            close GET_GROUP_SYSTEM_INFO;
          else
            open GET_GROUP_SYSTEM_INFO_MRC(h_processing_fiscal_year, h_processing_period_counter);
            fetch GET_GROUP_SYSTEM_INFO_MRC into h_group_system_deprn_amount, h_group_system_bonus_deprn;
            close GET_GROUP_SYSTEM_INFO_MRC;
          end if;
        else -- some amounts has been calculated
          if p_mrc_sob_type_code <> 'R' then
            open GET_GROUP_SYSTEM_INFO(h_processing_fiscal_year, h_first_period_counter - 1);
            fetch GET_GROUP_SYSTEM_INFO into h_group_system_deprn_amount, h_group_system_bonus_deprn;
            close GET_GROUP_SYSTEM_INFO;
          else
            open GET_GROUP_SYSTEM_INFO_MRC(h_processing_fiscal_year, h_first_period_counter -1);
            fetch GET_GROUP_SYSTEM_INFO_MRC into h_group_system_deprn_amount, h_group_system_bonus_deprn;
            close GET_GROUP_SYSTEM_INFO_MRC;
          end if;
          h_group_system_deprn_amount := nvl(h_group_system_deprn_amount,0) + nvl(h_temp_system_deprn_amount,0);
          h_group_system_bonus_deprn := nvl(h_group_system_bonus_deprn,0) + nvl(h_temp_system_bonus_deprn,0);

        end if;

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '++ Logic in case the subtraction flag is Y (3)' , '+++');
          fa_debug_pkg.add(l_calling_fn, 'h_group_system_deprn:bonus_amount', h_group_system_deprn_amount||':'||h_group_system_bonus_deprn, p_log_level_rec => p_log_level_rec);
        end if;

      end if; -- Subtraction


      --* Prepare to call Deprn Basis Rule - 1

      --* If this proceesing period is last period of the fiscal year set h_eofy_flag = 'Y'
      --* call depreciable basis rule function to update adjusted cost for the next year
      if h_period_num = h_period_per_fiscal_year then
         h_eofy_flag := 'Y';
      else
         h_eofy_flag := 'N';
      end if;

      fa_rule_in.event_type := 'AMORT_ADJ';
      fa_rule_in.book_type_code := h_book_type_code;
      fa_rule_in.fiscal_year := h_fiscal_year;
      fa_rule_in.period_num := h_period_num;
      fa_rule_in.period_counter := h_processing_period_counter;
      fa_rule_in.method_code := h_deprn_method_code;
      fa_rule_in.life_in_months := h_life_in_months;
      fa_rule_in.method_type := fa_cache_pkg.fazccmt_record.rate_source_rule;
      fa_rule_in.calc_basis := fa_cache_pkg.fazccmt_record.deprn_basis_rule;
      fa_rule_in.mrc_sob_type_code := p_mrc_sob_type_code;
      fa_rule_in.set_of_books_id := h_set_of_books_id;
      fa_rule_in.group_asset_id := h_group_asset_id;
      fa_rule_in.recognize_gain_loss := h_group_recognize_gain_loss;

      --* Group Level information (50% application) if the basis rule assigned to this method enables reduction rate
      if fa_cache_pkg.fazcdrd_record.rule_name in ('YEAR END BALANCE WITH POSITIVE REDUCTION',
                                                   'YEAR END BALANCE WITH HALF YEAR RULE') then

        if not check_reduction_application(p_rule_name => fa_cache_pkg.fazcdrd_record.rule_name,
                                           p_group_asset_id => h_group_asset_id,
                                           p_book_type_code => h_book_type_code,
                                           p_period_counter => h_processing_period_counter,
                                           p_group_deprn_basis => h_group_deprn_basis,
                                           p_reduction_rate => p_asset_fin_rec_new.reduction_rate,
                                           p_group_eofy_rec_cost => h_group_eofy_rec_cost,
                                           p_group_eofy_salvage_value => h_group_eofy_salvage_value,
                                           p_group_eofy_reserve => h_group_eofy_reserve,
                                           p_mrc_sob_type_code => p_mrc_sob_type_code,
                                           p_set_of_books_id =>
h_set_of_books_id,
                                           x_apply_reduction_flag => h_apply_reduction_flag,
                                           p_log_level_rec => p_log_level_rec) then
            raise pop_mem_table_err;
        end if;
       end if;

       if p_mrc_sob_type_code <> 'R' then -- Primary Book's treatment

         --* Loop for all member assets which has existed in the processing period
         For ALL_MEMBER in GET_MEMBER_ASSETS(h_processing_fiscal_year, h_processing_period_num) Loop
           h_member_asset_id := ALL_MEMBER.asset_id;

           h_max_thid_in_this_group := all_member.max_trx_id_in_this_group ;
           h_max_thid_in_other_group := all_member.max_trx_id_in_other_group;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '*** Check member has been reclassified out or not ***',
                                          h_member_asset_id||':'||h_processing_fiscal_year||':'||h_processing_period_num);
           end if;

           --* First of all, check if this selected member is actually reclassed out or not
           if h_max_thid_in_this_group < nvl(h_max_thid_in_other_group,-1) then
             if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '*** This member has been reclassified out ***', '***');
               fa_debug_pkg.add(l_calling_fn, 'h_max_thid_in_this_group:h_max_thid_in_other_group',
                                               h_max_thid_in_this_group||':'||h_max_thid_in_other_group, p_log_level_rec => p_log_level_rec);
             end if;
             goto skip_asset;
           end if;

           open CHK_FULLY_RESERVE_RETIRED(h_member_asset_id);
           fetch CHK_FULLY_RESERVE_RETIRED into h_allocate_to_fully_ret_flag,h_allocate_to_fully_rsv_flag,
                                                h_perd_ctr_fully_retired, h_perd_ctr_fully_reserved;
           close CHK_FULLY_RESERVE_RETIRED;

           if nvl(h_allocate_to_fully_ret_flag,'N') = 'N' and
              nvl(h_perd_ctr_fully_retired,h_processing_period_counter+1) < h_processing_period_counter then

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'Skip this asset due to fully retired', h_member_asset_id, p_log_level_rec => p_log_level_rec);
              end if;
              goto skip_asset;
           end if;

           if nvl(h_allocate_to_fully_rsv_flag,'N') = 'N' and
              nvl(h_perd_ctr_fully_reserved,h_processing_period_counter+1) < h_processing_period_counter then

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'Skip this asset due to fully reserved', h_member_asset_id, p_log_level_rec => p_log_level_rec);
              end if;
              goto skip_asset;
           end if;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '*** Member Loop Starts ***', '***');
             fa_debug_pkg.add(l_calling_fn, 'Processing Member Asset', h_member_asset_id, p_log_level_rec => p_log_level_rec);
           end if;

           --* Process get delta of cost, rec cost, salvage value etc...
           --* Query transaction header id of this member assetin this period
           h_trans_exists_flag := FALSE;
           h_transaction_header_id := to_number(NULL);
           h_delta_cost := 0;
           h_delta_adjusted_cost := 0;  --Bug8484007
           h_new_delta_adjusted_cost := 0;  --Bug8484007
           h_delta_recoverable_cost := 0;
           h_new_adjusted_rec_cost := to_number(NULL);

           h_adj_cost := 0;
           h_adj_rec_cost := 0;
           h_adj_salvage_value := 0;

           h_new_limit_type := NULL;
           h_new_deprn_limit := to_number(NULL);
           h_new_deprn_limit_amount := to_number(NULL);
           h_new_group_asset_id := h_group_asset_id;

           h_recognize_gain_loss := NULL;
           h_adj_eofy_reserve := 0;
           h_new_eofy_reserve := 0;
           h_adj_reserve_retired := 0;
           h_new_reserve_retired := 0;

           h_new_perd_ctr_ret := to_number(NULL);
           h_eofy_reserve_zero := 'N';

           For ALL_TRANS IN ALL_TRANS_IN_PERIOD(h_processing_fiscal_year,h_processing_period_num, h_member_asset_id) Loop
             h_trans_exists_flag := TRUE;
             h_transaction_header_id := ALL_TRANS.transaction_header_id;
             h_transaction_type_code := ALL_TRANS.transaction_type_code;
             h_transaction_key := ALL_TRANS.transaction_key; --Bug8484007

             --* query delta for this transaction
             open GET_DELTA_FOR_MEMBER(h_member_asset_id, h_transaction_header_id);
             fetch GET_DELTA_FOR_MEMBER into h_delta_cost, h_delta_recoverable_cost, h_new_limit_type, h_old_limit_type,
                                             h_new_deprn_limit, h_new_deprn_limit_amount, h_depreciate_flag, h_new_group_asset_id
                                             ,h_new_perd_ctr_ret,h_new_delta_adjusted_cost; --Bug8484007
             if GET_DELTA_FOR_MEMBER%FOUND then
               close GET_DELTA_FOR_MEMBER;
               h_adj_cost := h_adj_cost + h_delta_cost;
               h_adj_rec_cost := h_adj_rec_cost + h_delta_recoverable_cost;
               h_adj_salvage_value := h_adj_cost - h_adj_rec_cost;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++++ LOOP FOR GETTING DELTA *** THID', h_transaction_header_id);
                 fa_debug_pkg.add(l_calling_fn, 'h_delta_cost:h_delta_rec_cost', h_delta_cost||':'||h_delta_recoverable_cost, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'h_adj_cost:h_adj_rec_cost:h_adj_salvage', h_adj_cost||':'||h_adj_rec_cost||':'||h_adj_salvage_value, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'h_new_perd_ctr_ret', h_new_perd_ctr_ret, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcdrd_record.rule_name',
                                  fa_cache_pkg.fazcdrd_record.rule_name, p_log_level_rec => p_log_level_rec);
               end if;

               if nvl(h_transaction_type_code,'NULL') in ('PARTIAL RETIREMENT','FULL RETIREMENT') then
                 open GET_RETIREMENTS(h_transaction_header_id);
                 fetch GET_RETIREMENTS into h_recognize_gain_loss, h_adj_eofy_reserve, h_adj_reserve_retired;
                 close GET_RETIREMENTS;

                 -- ENERGY
                 -- reserve retired will not be equal to cost when recognize_gain_loss = 'NO'
                 -- ONLY if fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE'
                 if nvl(h_recognize_gain_loss,'NO') = 'NO' and -- ENERGY
                    (nvl(fa_cache_pkg.fazcdrd_record.rule_name, 'NONE') <> 'ENERGY PERIOD END BALANCE') then
                   h_new_eofy_reserve := 0;
                 else
                   h_new_eofy_reserve := nvl(h_new_eofy_reserve,0) + nvl(h_adj_eofy_reserve,0);
                   h_new_reserve_retired := nvl(h_new_reserve_retired,0) + nvl(h_adj_reserve_retired,0);
                 end if;

                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, '++++ LOOP FOR GETTING RETIREMENT *** THID', h_transaction_header_id);
                   fa_debug_pkg.add(l_calling_fn, 'h_new_eofy_reserve:h_new_reserve_retired',
                                    h_new_eofy_reserve||':'||h_new_reserve_retired, p_log_level_rec => p_log_level_rec);
                 end if;
               elsif (nvl(h_transaction_type_code,'NULL') = 'REINSTATEMENT') and
                     (nvl(fa_cache_pkg.fazcdrd_record.rule_name, 'NONE') = 'ENERGY PERIOD END BALANCE') then
                     --
                 open GET_REINSTATEMENT(h_transaction_header_id);
                 fetch GET_REINSTATEMENT into h_recognize_gain_loss, h_adj_eofy_reserve, h_adj_reserve_retired;
                 close GET_REINSTATEMENT;

                 if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn, 'h_adj_reserve_retired', h_adj_reserve_retired, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_calling_fn, 'h_new_reserve_retired', h_new_reserve_retired, p_log_level_rec => p_log_level_rec);
                 end if;

                 h_new_reserve_retired := nvl(h_new_reserve_retired,0) + nvl(h_adj_reserve_retired,0);
               end if; -- Retirement treatment

               -- Added for bug 8484007
               if (h_transaction_key = 'RA') then
                  h_delta_adjusted_cost := h_delta_adjusted_cost + h_new_delta_adjusted_cost;
               end if;
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'h_new_delta_adjusted_cost', h_new_delta_adjusted_cost, p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'h_delta_adjusted_cost', h_delta_adjusted_cost, p_log_level_rec);
               end if;

             else  --   if GET_DELTA_FOR_MEMBER%NOTFOUND then
               close GET_DELTA_FOR_MEMBER;
                -- Check if this transaction is reclassification and if this is a reason why the delta cannot be found, then
                -- just skip this member's process.
               open GET_NEW_GROUP(h_member_asset_id, h_transaction_header_id);
               fetch GET_NEW_GROUP into h_new_group_asset_id;
               if GET_NEW_GROUP%FOUND then
                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, '++++ Check the transaction is reclass or not ***', h_transaction_header_id);
                   fa_debug_pkg.add(l_calling_fn, 'h_group_asset_id:h_new_group_asset_id', h_group_asset_id||':'||h_new_group_asset_id, p_log_level_rec => p_log_level_rec);
                 end if;
                 if h_group_Asset_id <> nvl(h_new_group_Asset_id,-99) then
                   close GET_NEW_GROUP;
                   goto skip_thid;
                 end if;
               end if;
               close GET_NEW_GROUP;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++++ Just set null to all ****', h_transaction_header_id);
               end if;
            end if;
    <<skip_thid>>
               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '*** This is the end of loop ***', h_transaction_header_id);
               end if;

           End loop;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '++++ AFTER LOOP FOR GETTING DELTA ****', '****');
             fa_debug_pkg.add(l_calling_fn, 'h_new_limit_type:new_limit:new_limit_amount',
                                             h_new_limit_type||':'||h_new_deprn_limit||':'||h_new_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'h_new_group_asset_id', h_new_group_Asset_id, p_log_level_rec => p_log_level_rec);
           end if;

           h_find_flag_3 := FALSE;

         --* If the bs table of the previous period exists, query bs table
         if nvl(p_populate_for_recalc_period,'N') = 'T' then
             open GET_PRV_ROW_BS;
             fetch GET_PRV_ROW_BS into h_old_cost,
                                       h_old_salvage_value,
                                       h_old_recoverable_cost,
                                       h_old_adjusted_cost,
                                       h_old_adjusted_rec_cost,
                                       h_deprn_reserve,
                                       h_bonus_deprn_reserve,
                                       h_ytd_deprn,
                                       h_bonus_ytd_deprn,
                                       h_eofy_reserve;
             if GET_PRV_ROW_BS%NOTFOUND then
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'No data in FA_BOOKS_SUMMARY', '***');
                end if;
             else
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'Data in FA_BOOKS_SUMMARY', 'FOUND', p_log_level_rec => p_log_level_rec);
                end if;
                if h_processing_period_num = 1 then
                  h_ytd_deprn := 0;
                  h_bonus_ytd_deprn := 0;
                  h_eofy_reserve := h_deprn_reserve;
                end if;
                h_find_flag_3 := TRUE;
                if h_new_limit_type is null then
                  h_new_limit_type := 'AMT';
                  h_new_deprn_limit_amount := h_old_cost - h_old_adjusted_rec_cost;
                end if;
             end if;

             close GET_PRV_ROW_BS;

          else -- Other case

           --* Check if this asset exists in p_track_member table
           k := 0;
           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'p_track_member_table.count', p_track_member_table.COUNT, p_log_level_rec => p_log_level_rec);
           end if;
           /* Bug 7231274, added for bug - start */
           k := search_index_table(h_processing_period_counter,h_member_asset_id,
                             h_group_asset_id, h_set_of_books_id,p_log_level_rec);

           if ( k > 0 ) then
              h_find_flag_3 := TRUE;
              l_processing_ind := k; -- Keep index for memory table.
              h_old_cost := p_track_member_table(k).cost;
              h_old_salvage_value := p_track_member_table(k).salvage_value;
              h_old_recoverable_cost := p_track_member_table(k).recoverable_cost;
              h_old_adjusted_rec_cost := p_track_member_table(k).adjusted_recoverable_cost;

              h_deprn_reserve := p_track_member_table(k).deprn_reserve;
              h_bonus_deprn_reserve := p_track_member_table(k).bonus_deprn_reserve;
              h_ytd_deprn := p_track_member_table(k).ytd_deprn;
              h_bonus_ytd_deprn := p_track_member_table(k).bonus_ytd_deprn;
              h_eofy_reserve := p_track_member_table(k).eofy_reserve;

              if h_new_limit_type is null then
                h_new_limit_type := 'AMT';
                h_new_deprn_limit_amount := h_old_cost - h_old_adjusted_rec_cost;
              end if;

              if nvl(h_new_group_asset_id, -99) <> h_group_asset_id then
                delete_track_index(h_processing_period_counter, h_member_asset_id,
                        h_group_asset_id,h_set_of_books_id,p_log_level_rec);

                p_track_member_table(k).group_asset_id := h_new_group_asset_id;

                put_track_index(h_processing_period_counter, h_member_asset_id,h_new_group_asset_id,h_set_of_books_id,k,p_log_level_rec);

                if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'This member does not belong to this group anymore', '+++', p_log_level_rec => p_log_level_rec);
                end if;
              end if;
           end if;
           /* Bug 7231274, added for bug - end */

         end if; -- If bs table should be queried or not...

           if nvl(h_new_group_asset_id, -99) <> h_group_asset_id then
             goto skip_asset;
           end if;

           if not (h_find_flag_3) then  -- This is a case the processing member asset doesn't exist in memory table
              h_old_cost := 0;
              h_old_salvage_value := 0;
              h_old_recoverable_cost := 0;
              h_old_adjusted_rec_cost := 0;

              h_bonus_deprn_reserve := 0;
              h_bonus_ytd_deprn := 0;
              --* This is a case when this asset is added in this period.
              open GET_RESERVE_AT_ADDITION(h_member_asset_id, h_processing_period_counter - 1);
              fetch GET_RESERVE_AT_ADDITION into h_deprn_source_code, h_ytd_deprn, h_deprn_reserve;
              if GET_RESERVE_AT_ADDITION%NOTFOUND then
                -- Set zero initial reserve

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'Member asset which cannot find DEPRN SUMMARY table',
                                    h_member_asset_id, p_log_level_rec => p_log_level_rec);
                end if;

                h_ytd_deprn := 0;
                h_deprn_reserve := 0;
              elsif h_deprn_source_code <> 'BOOKS' then
                -- Set zero initial reserve

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'This Member assets record', h_deprn_source_code, p_log_level_rec => p_log_level_rec);
                end if;
                h_ytd_deprn := 0;
                h_deprn_reserve := 0;
              end if;
              close GET_RESERVE_AT_ADDITION;
           end if;


           if nvl(p_populate_for_recalc_period,'N') = 'T'  or
              not (h_find_flag_3) then

              -- Then enter this asset to extended memory table at this moment
              l_new_ind := nvl(p_track_member_table.COUNT,0) + 1;
              l_processing_ind := l_new_ind;
              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'l_new_ind', l_new_ind, p_log_level_rec => p_log_level_rec);
              end if;
              p_track_member_table(l_new_ind).group_asset_id := h_group_asset_id;
              p_track_member_table(l_new_ind).member_asset_id := h_member_asset_id;
              p_track_member_table(l_new_ind).set_of_books_id := h_set_of_books_id;
              p_track_member_table(l_new_ind).period_counter := h_processing_period_counter;
              p_track_member_table(l_new_ind).fiscal_year := h_fiscal_year;
              p_track_member_table(l_new_ind).cost := h_old_cost;
              p_track_member_table(l_new_ind).salvage_value := h_old_salvage_value;
              p_track_member_table(l_new_ind).adjusted_cost := h_old_recoverable_cost;
              p_track_member_table(l_new_ind).recoverable_cost := h_old_recoverable_cost;
              p_track_member_table(l_new_ind).adjusted_recoverable_cost := h_old_adjusted_rec_cost;
              p_track_member_table(l_new_ind).deprn_reserve := h_deprn_reserve;
              p_track_member_table(l_new_ind).ytd_deprn := h_ytd_deprn;
              p_track_member_table(l_new_ind).bonus_deprn_reserve := 0;
              p_track_member_table(l_new_ind).bonus_ytd_deprn := 0;
              if nvl(p_populate_for_recalc_period,'N') = 'T' and (h_find_flag_3) then
                p_track_member_table(l_new_ind).eofy_reserve := h_eofy_reserve;
              else
                p_track_member_table(l_new_ind).eofy_reserve := h_deprn_reserve - h_ytd_deprn;
                h_eofy_reserve := h_deprn_reserve - h_ytd_deprn;
              end if;
              p_track_member_table(l_new_ind).eofy_recoverable_cost := 0;
              p_track_member_table(l_new_ind).eop_recoverable_cost := 0;
              p_track_member_table(l_new_ind).eofy_salvage_value := 0;
              p_track_member_table(l_new_ind).eop_salvage_value := 0;
              p_track_member_table(l_new_ind).set_of_books_id := nvl(h_set_of_books_id, -99);

              /* Populate index table */
              put_track_index(h_processing_period_counter,h_member_asset_id,h_group_asset_id,h_set_of_books_id,l_new_ind,p_log_level_rec);

           end if;

         --* Member Asset level information
           --* adjust by the delta
           h_new_cost := h_old_cost + h_adj_cost;
           h_new_recoverable_cost := h_old_recoverable_cost + h_adj_rec_cost;
           h_new_salvage_value := h_old_salvage_value + h_adj_salvage_value;

           if nvl(h_new_limit_type,'NONE') = 'PCT' then
             h_temp_limit_amount := h_new_cost*(1 - h_new_deprn_limit);
             fa_round_pkg.fa_floor(h_temp_limit_amount,h_book_type_code, p_log_level_rec => p_log_level_rec);
             h_new_adjusted_rec_cost := h_new_cost - h_temp_limit_amount;
           elsif nvl(h_new_limit_type,'NONE') = 'NONE' then
             h_new_adjusted_rec_cost := h_new_recoverable_cost; -- In this case, it should be same as new recoverable cost
           else
             h_new_adjusted_rec_cost := h_new_cost - h_new_deprn_limit_amount;
           end if;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '++++ AFTER GETTING NEW COST etc ***', '*****');
             fa_debug_pkg.add(l_calling_fn, 'h_new_cost:h_new_rec_cost:h_new_salvage:h_new_adj_rec_cost',
                                             h_new_cost||':'||h_new_recoverable_cost||':'||h_new_salvage_value||':'||h_new_adjusted_rec_cost, p_log_level_rec => p_log_level_rec);
           end if;

           -- Get Asset type
           select ASSET_TYPE
             into fa_rule_in.asset_type
             from fa_additions_b
            where asset_id = h_member_asset_id;

           -- Get eofy, eop amounts
           if not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
                        (p_asset_id =>       h_member_asset_id,
                         p_book_type_code => h_book_type_code,
                         p_fiscal_year =>    h_fiscal_year,
                         p_period_num =>     h_period_num,
                         p_mrc_sob_type_code => p_mrc_sob_type_code,
                         p_set_of_books_id => h_set_of_books_id,
                         x_eofy_recoverable_cost => h_new_eofy_recoverable_cost,
                         x_eofy_salvage_value => h_new_eofy_salvage_value,
                         x_eop_recoverable_cost => h_new_eop_recoverable_cost,
                         x_eop_salvage_value => h_new_eop_salvage_value, p_log_level_rec => p_log_level_rec) then
             raise pop_mem_table_err;
           end if;

           fa_rule_in.asset_id := h_member_asset_id;
           fa_rule_in.depreciate_flag := h_depreciate_flag;
           fa_rule_in.adjustment_amount := nvl(h_new_cost,0) - nvl(h_old_cost,0);
           fa_rule_in.cost := h_new_cost;
           fa_rule_in.salvage_value := h_new_salvage_value;
           fa_rule_in.recoverable_cost := h_new_recoverable_cost;
           fa_rule_in.adjusted_cost := h_old_adjusted_cost;
           fa_rule_in.current_total_rsv := h_deprn_reserve + nvl(h_new_reserve_retired,0) - nvl(h_delta_adjusted_cost,0); --Bug8484007
           fa_rule_in.current_rsv := h_deprn_reserve + nvl(h_new_reserve_retired,0) - nvl(h_bonus_deprn_reserve,0) - nvl(h_delta_adjusted_cost,0); --Bug8484007
           fa_rule_in.current_total_ytd := h_ytd_deprn;
           fa_rule_in.current_ytd := h_ytd_deprn - nvl(h_bonus_ytd_deprn,0);
           fa_rule_in.old_adjusted_cost := h_old_adjusted_cost;
           fa_rule_in.eofy_reserve := h_eofy_reserve - nvl(h_new_eofy_reserve,0);

           fa_rule_in.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
           fa_rule_in.eop_recoverable_cost := h_new_eop_recoverable_cost;
           fa_rule_in.eofy_salvage_value := h_new_eofy_salvage_value;
           fa_rule_in.eop_salvage_value := h_new_eop_salvage_value;
           fa_rule_in.apply_reduction_flag := h_apply_reduction_flag;

           if (p_log_level_rec.statement_level) then
             if not display_debug_message(fa_rule_in => fa_rule_in,
                                          p_calling_fn => l_calling_fn,
p_log_level_rec=> p_log_level_rec) then
               fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
             end if;
           end if;

           -- Call Deprn Basis Rule for this transaction or period
           if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                                   rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
             if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'FAXCDB is errored out', '+++', p_log_level_rec => p_log_level_rec);
             end if;
             raise pop_mem_table_err;
           end if;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', fa_rule_in.asset_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost', fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'h_current_cost', h_new_cost, p_log_level_rec => p_log_level_rec);
           end if;

           --* Set calculated adjusted cost into p_track_member_table

            p_track_member_table(l_processing_ind).cost := h_new_cost;
            p_track_member_table(l_processing_ind).salvage_value := h_new_salvage_value;
            p_track_member_table(l_processing_ind).recoverable_cost := h_new_recoverable_cost;
            p_track_member_table(l_processing_ind).adjusted_cost := fa_rule_out.new_adjusted_cost;
            p_track_member_table(l_processing_ind).adjusted_recoverable_cost := h_new_adjusted_rec_cost;
            p_track_member_table(l_processing_ind).deprn_reserve := p_track_member_table(l_processing_ind).deprn_reserve - nvl(h_delta_adjusted_cost,0); --Bug8484007

            if h_new_reserve_retired is not null then
              p_track_member_table(l_processing_ind).deprn_reserve := p_track_member_table(l_processing_ind).deprn_reserve + nvl(h_new_reserve_retired,0);
            end if;
            if h_new_eofy_reserve is not null then
              p_track_member_table(l_processing_ind).eofy_reserve := p_track_member_table(l_processing_ind).eofy_reserve - nvl(h_new_eofy_reserve,0);
            end if;

            if h_new_perd_ctr_ret is not null then
              if h_new_perd_ctr_ret <= h_processing_period_counter then
                p_track_member_table(l_processing_ind).fully_retired_flag := 'Y';
              end if;
            end if;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'New p_track_member_table is as follows: Indicator', l_processing_ind, p_log_level_rec => p_log_level_rec);
              if not display_debug_message2(l_processing_ind, l_calling_fn,
p_log_level_rec) then
                 null;
              end if;
            end if;

    <<skip_asset>>
            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, '+++ End of Loop +++', '++++', p_log_level_rec => p_log_level_rec);
            end if;

         End Loop; -- (For ALL_MMEBER)

    else -- Reporting Book's treatment

         --* Loop for all member assets which has existed in the processing period
         For ALL_MEMBER in  GET_MEMBER_ASSETS_MRC(h_processing_fiscal_year,h_processing_period_num) Loop
           h_member_asset_id := ALL_MEMBER.asset_id;

           h_max_thid_in_this_group := all_member.max_trx_id_in_this_group ;
           h_max_thid_in_other_group := all_member.max_trx_id_in_other_group;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '*** Check member has been reclassified out or not ***',
                                          h_member_asset_id||':'||h_processing_fiscal_year||':'||h_processing_period_num);
           end if;

           if h_max_thid_in_this_group < nvl(h_max_thid_in_other_group,-1) then
             if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '*** This member has been reclassified out ***', '***');
               fa_debug_pkg.add(l_calling_fn, 'h_max_thid_in_this_group:h_max_thid_in_other_group',
                                               h_max_thid_in_this_group||':'||h_max_thid_in_other_group, p_log_level_rec => p_log_level_rec);
             end if;
             goto skip_asset;
           end if;

           open CHK_FULLY_RESERVE_RETIRED_MRC(h_member_asset_id);
           fetch CHK_FULLY_RESERVE_RETIRED_MRC into h_allocate_to_fully_ret_flag,h_allocate_to_fully_rsv_flag,
                                                h_perd_ctr_fully_retired, h_perd_ctr_fully_reserved;
           close CHK_FULLY_RESERVE_RETIRED_MRC;

           if nvl(h_allocate_to_fully_ret_flag,'N') = 'N' and
              nvl(h_perd_ctr_fully_retired,h_processing_period_counter+1) < h_processing_period_counter then

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'Skip this asset due to fully retired',
                                  h_member_asset_id, p_log_level_rec => p_log_level_rec);
              end if;
              goto skip_asset;
           end if;

           if nvl(h_allocate_to_fully_rsv_flag,'N') = 'N' and
              nvl(h_perd_ctr_fully_reserved,h_processing_period_counter+1) < h_processing_period_counter then

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'Skip this asset due to fully reserved',
                                  h_member_asset_id, p_log_level_rec => p_log_level_rec);
              end if;

              goto skip_asset;
           end if;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '*** Member Loop Starts ***', '*Reporting Book*');
             fa_debug_pkg.add(l_calling_fn, 'Processing Member Asset', h_member_asset_id, p_log_level_rec => p_log_level_rec);
           end if;

           --* Process get delta of cost, rec cost, salvage value etc...
           --* Query transaction header id of this member assetin this period
           h_trans_exists_flag := FALSE;
           h_transaction_header_id := to_number(NULL);
           h_delta_cost := 0;
           h_delta_adjusted_cost := 0; --Bug8484007
           h_new_delta_adjusted_cost := 0; --Bug8484007
           h_delta_recoverable_cost := 0;
           h_new_adjusted_rec_cost := to_number(NULL);

           h_adj_cost := 0;
           h_adj_rec_cost := 0;
           h_adj_salvage_value := 0;

           h_new_limit_type := NULL;
           h_new_deprn_limit := to_number(NULL);
           h_new_deprn_limit_amount := to_number(NULL);
           h_new_group_asset_id := h_group_asset_id;

           h_recognize_gain_loss := NULL;
           h_adj_eofy_reserve := 0;
           h_new_eofy_reserve := 0;
           h_adj_reserve_retired := 0;
           h_new_reserve_retired := 0;

           For ALL_TRANS IN ALL_TRANS_IN_PERIOD(h_processing_fiscal_year,h_processing_period_num, h_member_asset_id) Loop
             h_trans_exists_flag := TRUE;
             h_transaction_header_id := ALL_TRANS.transaction_header_id;
             h_transaction_type_code := ALL_TRANS.transaction_type_code;
             h_transaction_key := ALL_TRANS.transaction_key; -- Bug8484007

             --* query delta for this transaction
             open GET_DELTA_FOR_MEMBER_MRC(h_member_asset_id, h_transaction_header_id);
             fetch GET_DELTA_FOR_MEMBER_MRC into h_delta_cost, h_delta_recoverable_cost, h_new_limit_type, h_old_limit_type,
                                             h_new_deprn_limit, h_new_deprn_limit_amount, h_depreciate_flag, h_new_group_Asset_id
                                             ,h_new_perd_ctr_ret,h_new_delta_adjusted_cost;
             if GET_DELTA_FOR_MEMBER_MRC%FOUND then
               close GET_DELTA_FOR_MEMBER_MRC;
               h_adj_cost := h_adj_cost + h_delta_cost;
               h_adj_rec_cost := h_adj_rec_cost + h_delta_recoverable_cost;
               h_adj_salvage_value := h_adj_cost - h_adj_rec_cost;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++++ LOOP FOR GETTING DELTA *** THID', h_transaction_header_id);
                 fa_debug_pkg.add(l_calling_fn, 'h_delta_cost:h_delta_rec_cost', h_delta_cost||':'||h_delta_recoverable_cost, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'h_adj_cost:h_adj_rec_cost:h_adj_salvage', h_adj_cost||':'||h_adj_rec_cost||':'||h_adj_salvage_value, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, 'h_new_perd_ctr_ret', h_new_perd_ctr_ret, p_log_level_rec => p_log_level_rec);
               end if;

               if nvl(h_transaction_type_code,'NULL') in ('PARTIAL RETIREMENT','FULL RETIREMENT') then
                 open GET_RETIREMENTS_MRC(h_transaction_header_id);
                 fetch GET_RETIREMENTS_MRC into h_recognize_gain_loss, h_adj_eofy_reserve, h_adj_reserve_retired;
                 close GET_RETIREMENTS_MRC;

                 if nvl(h_recognize_gain_loss,'NO') = 'NO' then
                   h_new_eofy_reserve := 0;
                 else
                   h_new_eofy_reserve := nvl(h_new_eofy_reserve,0) + nvl(h_adj_eofy_reserve,0);
                   h_new_reserve_retired := nvl(h_new_reserve_retired,0) + nvl(h_adj_reserve_retired,0);
                 end if;

                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, '++++ LOOP FOR GETTING RETIREMENT *** THID', h_transaction_header_id);
                   fa_debug_pkg.add(l_calling_fn, 'h_new_eofy_reserve:h_new_reserve_retired', h_new_eofy_reserve||':'||h_new_reserve_retired, p_log_level_rec => p_log_level_rec);
                 end if;
               end if; -- Retirement treatment

               -- Added for bug 8484007
               if (h_transaction_key = 'RA') then
                  h_delta_adjusted_cost := h_delta_adjusted_cost + h_new_delta_adjusted_cost;
               end if;
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'h_new_delta_adjusted_cost', h_new_delta_adjusted_cost, p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'h_delta_adjusted_cost', h_delta_adjusted_cost, p_log_level_rec);
               end if;

             else  --   if GET_DELTA_FOR_MEMBER%NOTFOUND then
               close GET_DELTA_FOR_MEMBER_MRC;
                -- Check if this transaction is reclassification and if this is a reason why the delta cannot be found, then
                -- just skip this member's process.
               open GET_NEW_GROUP_MRC(h_member_asset_id, h_transaction_header_id);
               fetch GET_NEW_GROUP_MRC into h_new_group_asset_id;
               if GET_NEW_GROUP_MRC%FOUND then
                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, '++++ Check the transaction is reclass or not ***', h_transaction_header_id);
                   fa_debug_pkg.add(l_calling_fn, 'h_group_asset_id:h_new_group_asset_id', h_group_asset_id||':'||h_new_group_asset_id, p_log_level_rec => p_log_level_rec);
                 end if;
                 if h_group_Asset_id <> nvl(h_new_group_Asset_id,-99) then
                   close GET_NEW_GROUP_MRC;
                   goto skip_thid;
                 end if;
               end if;
               close GET_NEW_GROUP_MRC;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++++ Just set null to all ****', h_transaction_header_id);
               end if;
            end if;
    <<skip_thid>>
               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '*** This is the end of loop ***', h_transaction_header_id);
               end if;

           End loop;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '++++ AFTER LOOP FOR GETTING DELTA ***', '****');
             fa_debug_pkg.add(l_calling_fn, 'h_new_limit_type:limit:limit_amount', h_new_limit_type||':'||h_new_deprn_limit||':'||h_new_deprn_limit_amount, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'h_new_group_asset_id', h_new_group_Asset_id, p_log_level_rec => p_log_level_rec);
           end if;

           h_find_flag_3 := FALSE;

         --* If the bs table of the previous period exists, query bs table
         if nvl(p_populate_for_recalc_period,'N') = 'T' then
             open GET_PRV_ROW_BS_MRC;
             fetch GET_PRV_ROW_BS_MRC into h_old_cost,
                                       h_old_salvage_value,
                                       h_old_recoverable_cost,
                                       h_old_adjusted_cost,
                                       h_old_adjusted_rec_cost,
                                       h_deprn_reserve,
                                       h_bonus_deprn_reserve,
                                       h_ytd_deprn,
                                       h_bonus_ytd_deprn,
                                       h_eofy_reserve;
             if GET_PRV_ROW_BS_MRC%NOTFOUND then
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'No data in FA_BOOKS_SUMMARY', '***');
                end if;
             else
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'Data in FA_BOOKS_SUMMARY', 'FOUND', p_log_level_rec => p_log_level_rec);
                end if;
                if h_processing_period_num = 1 then
                  h_ytd_deprn := 0;
                  h_bonus_ytd_deprn := 0;
                  h_eofy_reserve := h_deprn_reserve;
                end if;
                h_find_flag_3 := TRUE;
                if h_new_limit_type is null then
                  h_new_limit_type := 'AMT';
                  h_new_deprn_limit_amount := h_old_cost - h_old_adjusted_rec_cost;
                end if;
             end if;
             close GET_PRV_ROW_BS_MRC;

          else -- Other case

           k := 0;
           --* Check if this exists in p_track_member table

           /* Bug 7231274, added for bug - start */
           k := search_index_table(h_processing_period_counter,h_member_asset_id,
                             h_group_asset_id, h_set_of_books_id,
p_log_level_rec);

           if ( k > 0 ) then
              h_find_flag_3 := TRUE;
              l_processing_ind := k; -- Keep index for memory table.
              h_old_cost := p_track_member_table(k).cost;
              h_old_salvage_value := p_track_member_table(k).salvage_value;
              h_old_recoverable_cost := p_track_member_table(k).recoverable_cost;
              h_old_adjusted_rec_cost := p_track_member_table(k).adjusted_recoverable_cost;

              h_deprn_reserve := p_track_member_table(k).deprn_reserve;
              h_bonus_deprn_reserve := p_track_member_table(k).bonus_deprn_reserve;
              h_ytd_deprn := p_track_member_table(k).ytd_deprn;
              h_bonus_ytd_deprn := p_track_member_table(k).bonus_ytd_deprn;
              h_eofy_reserve := p_track_member_table(k).eofy_reserve;

              if h_new_limit_type is null then
                h_new_limit_type := 'AMT';
                h_new_deprn_limit_amount := h_old_cost - h_old_adjusted_rec_cost;
              end if;

              if nvl(h_new_group_asset_id, -99) <> h_group_asset_id then
                delete_track_index(h_processing_period_counter, h_member_asset_id,
                        h_group_asset_id,h_set_of_books_id, p_log_level_rec);

                p_track_member_table(k).group_asset_id := h_new_group_asset_id;

                put_track_index(h_processing_period_counter, h_member_asset_id,h_new_group_asset_id,h_set_of_books_id,k,p_log_level_rec);

                if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'This member does not belong to this group anymore', '+++', p_log_level_rec => p_log_level_rec);
                end if;
              end if;
           end if;
           /* Bug 7231274, added for bug - end */

         end if; -- If bs table should be queried or not...

           if nvl(h_new_group_asset_id, -99) <> h_group_asset_id then
             goto skip_asset;
           end if;

           if not (h_find_flag_3) then  -- This is a case the processing member asset doesn't exist in memory table
              h_old_cost := 0;
              h_old_salvage_value := 0;
              h_old_recoverable_cost := 0;
              h_old_adjusted_rec_cost := 0;


              h_bonus_deprn_reserve := 0;
              h_bonus_ytd_deprn := 0;
              --* This is a case when this asset is added in this period.
              open GET_RESERVE_AT_ADDITION_MRC(h_member_asset_id, h_processing_period_counter);
              fetch GET_RESERVE_AT_ADDITION_MRC into h_deprn_source_code, h_ytd_deprn, h_deprn_reserve;
              if GET_RESERVE_AT_ADDITION_MRC%NOTFOUND then
                -- Set zero initial reserve

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'Member asset which cannot find DEPRN SUMMARY table',
                                    h_member_asset_id, p_log_level_rec => p_log_level_rec);
                end if;

                h_ytd_deprn := 0;
                h_deprn_reserve := 0;
              elsif h_deprn_source_code <> 'BOOKS' then
                -- Set zero initial reserve

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn, 'This Member assets record', h_deprn_source_code, p_log_level_rec => p_log_level_rec);
                end if;

                h_ytd_deprn := 0;
                h_deprn_reserve := 0;
              end if;
              close GET_RESERVE_AT_ADDITION_MRC;
            end if;

            if nvl(p_populate_for_recalc_period,'N') = 'T' or
               not (h_find_flag_3) then

              -- Then enter this asset to extended memory table at this moment
              l_new_ind := p_track_member_table.COUNT + 1;
              l_processing_ind := l_new_ind;
              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'l_new_ind', l_new_ind, p_log_level_rec => p_log_level_rec);
              end if;
              p_track_member_table(l_new_ind).group_asset_id := h_group_asset_id;
              p_track_member_table(l_new_ind).member_asset_id := h_member_asset_id;
              p_track_member_table(l_new_ind).set_of_books_id := h_set_of_books_id;
              p_track_member_table(l_new_ind).period_counter := h_processing_period_counter;
              p_track_member_table(l_new_ind).fiscal_year := h_fiscal_year;
              p_track_member_table(l_new_ind).cost := h_new_cost;
              p_track_member_table(l_new_ind).salvage_value := h_new_salvage_value;
              p_track_member_table(l_new_ind).adjusted_cost := h_new_recoverable_cost;
              p_track_member_table(l_new_ind).recoverable_cost := h_new_recoverable_cost;
              p_track_member_table(l_new_ind).adjusted_recoverable_cost := h_new_adjusted_rec_cost;
              p_track_member_table(l_new_ind).deprn_reserve := h_deprn_reserve;
              p_track_member_table(l_new_ind).ytd_deprn := h_ytd_deprn;
              p_track_member_table(l_new_ind).bonus_deprn_reserve := 0;
              p_track_member_table(l_new_ind).bonus_ytd_deprn := 0;
              if nvl(p_populate_for_recalc_period,'N') = 'T' and (h_find_flag_3) then
                p_track_member_table(l_new_ind).eofy_reserve := h_eofy_reserve;
              else
                p_track_member_table(l_new_ind).eofy_reserve := h_deprn_reserve - h_ytd_deprn;
                h_eofy_reserve := h_deprn_reserve - h_ytd_deprn;
              end if;
              p_track_member_table(l_new_ind).eofy_recoverable_cost := 0;
              p_track_member_table(l_new_ind).eop_recoverable_cost := 0;
              p_track_member_table(l_new_ind).eofy_salvage_value := 0;
              p_track_member_table(l_new_ind).eop_salvage_value := 0;
              p_track_member_table(l_new_ind).set_of_books_id := h_set_of_books_id;

              /* Populate index table */
              put_track_index(h_processing_period_counter,h_member_asset_id,h_group_asset_id,h_set_of_books_id,l_new_ind,p_log_level_rec);

           end if;

           --* Member Asset level information

           --* adjust by the delta
           h_new_cost := h_old_cost + h_adj_cost;
           h_new_recoverable_cost := h_old_recoverable_cost + h_adj_rec_cost;
           h_new_salvage_value := h_old_salvage_value + h_adj_salvage_value;

           if nvl(h_new_limit_type,'NONE') = 'PCT' then
             h_temp_limit_amount := h_new_cost*(1-h_new_deprn_limit);
             fa_round_pkg.fa_floor(h_temp_limit_amount,h_book_type_code, p_log_level_rec => p_log_level_rec);
             h_new_adjusted_rec_cost := h_new_cost - h_temp_limit_amount;
           elsif nvl(h_new_limit_type,'NONE') = 'NONE' then
             h_new_adjusted_rec_cost := h_new_recoverable_cost; -- In this case, it should be same as new recoverable cost
           else
             h_new_adjusted_rec_cost := h_new_cost - h_new_deprn_limit_amount;
           end if;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, '++++ AFTER GETTING NEW COST etc ***', '*****');
             fa_debug_pkg.add(l_calling_fn, 'h_new_cost:h_new_rec_cost:h_new_salvage:h_new_adj_rec_cost',
                                             h_new_cost||':'||h_new_recoverable_cost||':'||h_new_salvage_value||':'||h_new_adjusted_rec_cost, p_log_level_rec => p_log_level_rec);
           end if;

           -- Get Asset type
           select ASSET_TYPE
             into fa_rule_in.asset_type
             from fa_additions_b
            where asset_id = h_member_asset_id;

           -- Get eofy, eop amounts
           if not FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
                        (p_asset_id =>       h_member_asset_id,
                         p_book_type_code => h_book_type_code,
                         p_fiscal_year =>    h_fiscal_year,
                         p_period_num =>     h_period_num,
                         p_mrc_sob_type_code => p_mrc_sob_type_code,
                         p_set_of_books_id => h_set_of_books_id,
                         x_eofy_recoverable_cost => h_new_eofy_recoverable_cost,
                         x_eofy_salvage_value => h_new_eofy_salvage_value,
                         x_eop_recoverable_cost => h_new_eop_recoverable_cost,
                         x_eop_salvage_value => h_new_eop_salvage_value, p_log_level_rec => p_log_level_rec) then
             raise pop_mem_table_err;
           end if;

           fa_rule_in.asset_id := h_member_asset_id;
           fa_rule_in.depreciate_flag := h_depreciate_flag;
           fa_rule_in.adjustment_amount := nvl(h_new_cost,0) - nvl(h_old_cost,0);
           fa_rule_in.cost := h_new_cost;
           fa_rule_in.salvage_value := h_new_salvage_value;
           fa_rule_in.recoverable_cost := h_new_recoverable_cost;
           fa_rule_in.adjusted_cost := h_old_adjusted_cost;
           fa_rule_in.current_total_rsv := h_deprn_reserve + nvl(h_new_reserve_retired,0) - nvl(h_delta_adjusted_cost,0); --Bug8484007
           fa_rule_in.current_rsv := h_deprn_reserve + nvl(h_new_reserve_retired,0) - nvl(h_bonus_deprn_reserve,0) - nvl(h_delta_adjusted_cost,0); --Bug8484007
           fa_rule_in.current_total_ytd := h_ytd_deprn;
           fa_rule_in.current_ytd := h_ytd_deprn - nvl(h_bonus_ytd_deprn,0);
           fa_rule_in.old_adjusted_cost := h_old_adjusted_cost;

           if nvl(h_eofy_reserve_zero,'N') = 'Y' then
             fa_rule_in.eofy_reserve := 0;
           else
             fa_rule_in.eofy_reserve := h_eofy_reserve - nvl(h_new_eofy_reserve,0);
           end if;

           fa_rule_in.eofy_recoverable_cost := h_new_eofy_recoverable_cost;
           fa_rule_in.eop_recoverable_cost := h_new_eop_recoverable_cost;
           fa_rule_in.eofy_salvage_value := h_new_eofy_salvage_value;
           fa_rule_in.eop_salvage_value := h_new_eop_salvage_value;
           fa_rule_in.apply_reduction_flag := h_apply_reduction_flag;

           if (p_log_level_rec.statement_level) then
             if not display_debug_message(fa_rule_in => fa_rule_in,
                                          p_calling_fn => l_calling_fn,
                                          p_log_level_rec => p_log_level_rec) then
               fa_debug_pkg.add(l_calling_fn, 'display_debug_message', 'error', p_log_level_rec => p_log_level_rec);
             end if;
           end if;

           -- Call Deprn Basis Rule for this transaction or period
           if (not fa_calc_deprn_basis1_pkg.faxcdb(rule_in => fa_rule_in,
                                                   rule_out => fa_rule_out, p_log_level_rec => p_log_level_rec)) then
             raise pop_mem_table_err;
           end if;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'h_member_asset_id', fa_rule_in.asset_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'fa_rule_out.new_adjusted_cost', fa_rule_out.new_adjusted_cost, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'h_current_cost', h_new_cost, p_log_level_rec => p_log_level_rec);
           end if;

           --* Set calculated adjusted cost into p_track_member_table

            p_track_member_table(l_processing_ind).cost := h_new_cost;
            p_track_member_table(l_processing_ind).salvage_value := h_new_salvage_value;
            p_track_member_table(l_processing_ind).recoverable_cost := h_new_recoverable_cost;
            p_track_member_table(l_processing_ind).adjusted_cost := fa_rule_out.new_adjusted_cost;
            p_track_member_table(l_processing_ind).adjusted_recoverable_cost := h_new_adjusted_rec_cost;
            p_track_member_table(l_processing_ind).deprn_reserve := p_track_member_table(l_processing_ind).deprn_reserve - nvl(h_delta_adjusted_cost,0); --Bug8484007

            if h_new_reserve_retired is not null then
              p_track_member_table(l_processing_ind).deprn_reserve := p_track_member_table(l_processing_ind).deprn_reserve + nvl(h_new_reserve_retired,0);
            end if;
            if h_new_eofy_reserve is not null then
              p_track_member_table(l_processing_ind).eofy_reserve := p_track_member_table(l_processing_ind).eofy_reserve - nvl(h_new_eofy_reserve,0);
            end if;

            if h_new_perd_ctr_ret is not null then
              if h_new_perd_ctr_ret <= h_processing_period_counter then
                p_track_member_table(l_processing_ind).fully_retired_flag := 'Y';
              end if;
            end if;

    <<skip_asset>>
            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, '+++ End of Loop +++', '++++', p_log_level_rec => p_log_level_rec);
            end if;

         End Loop; -- (For ALL_MMEBER)
      end if;  -- Primary or Reporting?

      --* From this point, Start to process allocate logic
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, '*** Ended all member assets treatment ***', '***');
        fa_debug_pkg.add(l_calling_fn, '*** Start process to allocate group level amount ***', '***');
      end if;

      if p_mrc_sob_type_code <> 'R' then

        -- Get expense/bonus expense adjustment of this group asset at this period
        open GET_ADJ_EXPENSE(h_processing_period_counter);
        fetch GET_ADJ_EXPENSE into h_group_adj_expense, h_group_adj_bonus_expense;
        close GET_ADJ_EXPENSE;

      else

        -- Get expense/bonus expense adjustment of this group asset at this period
        open GET_ADJ_EXPENSE_MRC(h_processing_period_counter);
        fetch GET_ADJ_EXPENSE_MRC into h_group_adj_expense, h_group_adj_bonus_expense;
        close GET_ADJ_EXPENSE_MRC;

      end if;

      -- Calculate purely periodic expense
      h_periodic_expense := h_group_deprn_amount - nvl(h_group_adj_expense,0);
      h_periodic_bonus_expense := nvl(h_group_bonus_deprn_amount,0) - nvl(h_group_adj_bonus_expense,0);

      if fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag = 'YES' then
        h_group_exclude_salvage := 'Y';
      else
        h_group_exclude_salvage := 'N';
      end if;

      h_group_deprn_amount_parm := h_group_system_deprn_amount;
      h_group_bonus_amount_parm := h_group_system_bonus_deprn;
      h_tracking_method := p_asset_fin_rec_new.tracking_method;
      h_allocate_to_fully_rsv_flag := p_asset_fin_rec_new.allocate_to_fully_rsv_flag;
      h_allocate_to_fully_ret_flag := p_asset_fin_rec_new.allocate_to_fully_ret_flag;
      h_excess_allocation_option := p_asset_fin_rec_new.excess_allocation_option;
      h_depreciation_option := p_asset_fin_rec_new.depreciation_option;
      h_member_rollup_flag := p_asset_fin_rec_new.member_rollup_flag;
      h_subtraction_flag := fa_cache_pkg.fazcdrd_record.subtract_ytd_flag;

      if h_processing_period_counter <> h_recalc_period_counter or
         (h_processing_period_counter = h_recalc_period_counter and
          p_no_allocation_for_last = 'N') then


         l_processing_member_table := 'YES';

         x_rtn_code :=  TRACK_ASSETS(P_book_type_code => h_book_type_code,
                             P_group_asset_id => h_group_asset_id,
                             P_period_counter => h_period_num,
                             P_fiscal_year => h_fiscal_year,
                             P_group_deprn_basis => h_group_deprn_basis,
                             P_group_exclude_salvage => h_group_exclude_salvage,
                             P_group_bonus_rule => h_group_bonus_rule,
                             P_group_deprn_amount => h_group_deprn_amount_parm,
                             P_group_bonus_amount => h_group_bonus_amount_parm,
                             P_tracking_method => h_tracking_method,
                             P_allocate_to_fully_ret_flag => h_allocate_to_fully_ret_flag,
                             P_allocate_to_fully_rsv_flag => h_allocate_to_fully_rsv_flag,
                             P_excess_allocation_option => h_excess_allocation_option,
                             P_depreciation_option => h_depreciation_option,
                             P_member_rollup_flag => h_member_rollup_flag,
                             P_subtraction_flag => h_subtraction_flag,
                             P_group_level_override => h_group_deprn_override,
                             P_mode => 'ADJUSTMENT',
                             P_mrc_sob_type_code => p_mrc_sob_type_code,
                             P_set_of_books_id => h_set_of_books_id,
                             X_new_deprn_amount => x_new_deprn_amount,
                             X_new_bonus_amount => x_new_bonus_amount,
                             p_log_level_rec => p_log_level_rec);

        if x_rtn_code <> 0 then
          l_processing_member_table := 'NO';
          raise pop_mem_table_err;
        end if;

        l_processing_member_table := 'NO';

      else

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '**** This processing period is last period of loop ****',
                            '****');
        end if;

      end if;

      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, '*** End of Period Loop ** Period Counter processed',
                         h_processing_period_counter);
      end if;

   End Loop; -- (For i IN 1.. h_length_of_loop)

   --* Following logic is prepared for exclude_salvage_value in FA_BOOKS is set.
   --  In this case, adjusted_cost of fully reserved should be removed from adjusted_cost
   -- of group asset. so need to maintain the memory table adjusted cost
         if nvl(h_exclude_fully_rsv_flag,'N') = 'Y'  and
            nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule,'COST') = 'NBV' then

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'Fully Reserve Asset treatment', 'Starts++++', p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'h_processing_fiscal_year lopped out', h_processing_fiscal_year, p_log_level_rec => p_log_level_rec);
           end if;

          -- If the fully reserved period is in the different fiscal year than
          -- the fiscal year when the process is done.
           For t IN 1.. p_track_member_table.COUNT LOOP
             if nvl(p_track_member_table(t).fully_reserved_flag,'N') = 'Y' and
                nvl(p_track_member_table(t).fiscal_year,h_group_dpis_fiscal_year) <> h_processing_fiscal_year and
                nvl(p_track_member_table(t).set_of_books_id,-99) = nvl(h_set_of_books_id,-99) then
               p_track_member_table(t).adjusted_cost := nvl(p_track_member_table(t).recoverable_cost,0)
                                                       - nvl(p_track_member_table(t).deprn_reserve,0);
               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'Updated fully reserved member asset',
                                                     p_track_member_table(t).member_asset_id);
                 fa_debug_pkg.add(l_calling_fn, 'Newly set Adjusted_cost and period_counter',
                                     p_track_member_table(t).adjusted_Cost||','||p_track_member_table(t).period_counter);
               end if;
             end if;
           End Loop;

           if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'Fully Reserve Asset treatment', 'Ended++++', p_log_level_rec => p_log_level_rec);
           end if;

         end if;


   return(true);

EXCEPTION
   when pop_mem_table_err then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;


end populate_member_assets_table;



--+=====================================================================
-- Function: populate_member_reserve
--
--  This function will be called to query tracked reserve amount
--  for group reclassification.
--  This function is used to skip recalculation from DPIS to reclassification
--  date populating member level reserve amount tracked.
--
--+=====================================================================

FUNCTION populate_member_reserve(p_trans_rec               in FA_API_TYPES.trans_rec_type,
                                 p_asset_hdr_rec           in FA_API_TYPES.asset_hdr_rec_type,
                                 p_asset_fin_rec_new       in FA_API_TYPES.asset_fin_rec_type,
                                 p_mrc_sob_type_code       in varchar2,
                                 x_deprn_reserve           out nocopy number,
                                 x_eofy_reserve            out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

   l_asset_fin_rec_new           FA_API_TYPES.asset_fin_rec_type;

   h_book_type_code              varchar2(30);
   h_member_asset_id             number(15);
   h_group_asset_id              number(15);
   h_period_counter              number;
   h_cur_fiscal_year             number;
   h_cur_period_num              number;

   h_trans_period_counter        number;

   h_reserve_dpis_current        number;
   h_eofy_reserve                number;
   h_set_of_books_id             number;

   h_ytd_deprn                   number;
   h_ds_fiscal_year              number;

   h_adj_eofy_reserve            number;
   h_adj_reserve                 number;

--* Cursor to populate the member level amounts
   cursor FETCH_MEMBER_ASSET is
     select asset_id
       from fa_transaction_headers
      where transaction_header_id = p_trans_rec.member_transaction_header_id;

--* Cursor to get current open period
    cursor GET_CUR_PERIOD is
     select period_counter, fiscal_year, period_num
       from fa_deprn_periods
      where book_type_code = h_book_type_code
        and period_close_date is null;

    cursor GET_CUR_PERIOD_MRC is
     select period_counter, fiscal_year, period_num
       from fa_mc_deprn_periods
      where book_type_code = h_book_type_code
        and period_close_date is null
        and set_of_books_id = h_set_of_books_id;

   cursor MEM_EXP_RESERVE is
     select ds1.deprn_reserve,ds1.ytd_deprn,dp1.fiscal_year
       from fa_deprn_summary ds1,
            fa_deprn_periods dp1
      where ds1.book_type_code = h_book_type_code
        and ds1.asset_id = h_member_asset_id
        and dp1.book_type_code = ds1.book_type_Code
        and dp1.period_counter = ds1.period_counter
        and ds1.period_counter =
            (select max(period_counter)
               from fa_deprn_summary ds2
              where ds2.book_type_code = h_book_type_code
                and ds2.asset_id = h_member_asset_id
                and period_counter <= h_period_counter);

   cursor MEM_EXP_RESERVE_MRC is
     select ds1.deprn_reserve,ds1.ytd_deprn,dp1.fiscal_year
       from fa_mc_deprn_summary ds1,
            fa_mc_deprn_periods dp1
      where ds1.book_type_code = h_book_type_code
        and ds1.asset_id = h_member_asset_id
        and ds1.set_of_books_id = h_set_of_books_id
        and dp1.book_type_code = ds1.book_type_Code
        and dp1.period_counter = ds1.period_counter
        and dp1.set_of_books_id = h_set_of_books_id
        and ds1.period_counter =
            (select max(period_counter)
               from fa_mc_deprn_summary ds2
              where ds2.book_type_code = h_book_type_code
                and ds2.asset_id = h_member_asset_id
                and period_counter <= h_period_counter
                and set_of_books_id = h_set_of_books_id);

--* Cursor for EOFY_RESERVE adjustment
cursor FA_RET_RSV is
  select sum(nvl(ret.reserve_retired,0) - nvl(ret.eofy_reserve,0))
    from fa_retirements ret
   where ret.book_type_code = h_book_type_code
     and ret.asset_id = h_member_asset_id
     and exists
         (select th1.transaction_header_id
            from fa_transaction_headers th1,
                 fa_deprn_periods dp1,
                 fa_deprn_periods dp3
           where th1.asset_id = ret.asset_id
             and dp1.book_type_code = h_book_type_code
             and dp1.fiscal_year =
                 (select dp2.fiscal_year
                    from fa_deprn_periods dp2
                   where dp2.book_type_code = dp1.book_type_code
                     and dp2.period_Counter = h_period_counter - 1)
             and dp1.period_num = 1
             and dp3.book_type_code = dp1.book_type_code
             and dp3.period_counter = h_period_counter - 1
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) >= dp1.calendar_period_open_date
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) <= dp3.calendar_period_close_date
             and th1.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT')
             and th1.transaction_header_id = ret.transaction_header_id_in);

cursor FA_RET_RSV_MRC is
  select sum(nvl(ret.reserve_retired,0) - nvl(ret.eofy_reserve,0))
    from fa_mc_retirements ret
   where ret.book_type_code = h_book_type_code
     and ret.asset_id = h_member_asset_id
     and ret.set_of_books_id = h_set_of_books_id
     and exists
         (select th1.transaction_header_id
            from fa_transaction_headers th1,
                 fa_mc_deprn_periods dp1,
                 fa_mc_deprn_periods dp3
           where th1.asset_id = ret.asset_id
             and dp1.book_type_code = h_book_type_code
             and dp1.fiscal_year =
                 (select dp2.fiscal_year
                    from fa_mc_deprn_periods dp2
                   where dp2.book_type_code = dp1.book_type_code
                     and dp2.period_Counter = h_period_counter - 1
                     and dp2.set_of_books_id = h_set_of_books_id
                     and dp2.set_of_books_id = h_set_of_books_id)
             and dp1.period_num = 1
             and dp3.book_type_code = dp1.book_type_code
             and dp3.period_counter = h_period_counter - 1
             and dp1.set_of_books_id = h_set_of_books_id
             and dp3.set_of_books_id = h_set_of_books_id
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) >= dp1.calendar_period_open_date
             and nvl(th1.amortization_start_date,th1.transaction_date_entered) <= dp3.calendar_period_close_date
             and th1.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT')
             and th1.transaction_header_id = ret.transaction_header_id_in);

cursor FA_ADJ_RESERVE is
   select sum(decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))
     from fa_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.adjustment_type = 'RESERVE'
      and nvl(adj.track_member_flag, 'N') = 'N' -- ENERGY
      and adj.source_type_code = 'ADJUSTMENT'
      and exists
         (select dp2.period_counter
            from fa_deprn_periods dp1,
                 fa_deprn_periods dp2
           where dp1.book_type_code = adj.book_type_code
             and dp1.period_counter = h_period_counter - 1
             and dp2.book_type_code = dp1.book_type_code
             and dp2.fiscal_year = dp1.fiscal_year
             and dp2.period_counter <= dp1.period_counter
             and dp2.period_counter = adj.period_counter_adjusted);

cursor FA_ADJ_RESERVE_MRC is
   select sum(decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))
     from fa_mc_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.adjustment_type = 'RESERVE'
      and nvl(adj.track_member_flag, 'N') = 'N'    -- ENERGY
      and adj.source_type_code = 'ADJUSTMENT'
      and adj.set_of_books_id = h_set_of_books_id
      and exists
         (select dp2.period_counter
            from fa_mc_deprn_periods dp1,
                 fa_mc_deprn_periods dp2
           where dp1.book_type_code = adj.book_type_code
             and dp1.period_counter = h_period_counter - 1
             and dp2.book_type_code = dp1.book_type_code
             and dp2.fiscal_year = dp1.fiscal_year
             and dp2.period_counter <= dp1.period_counter
             and dp2.period_counter = adj.period_counter_adjusted
             and dp1.set_of_books_id = h_set_of_books_id
             and dp2.set_of_books_id = h_set_of_books_id);


   l_calling_fn                  VARCHAR2(50) := 'fa_group_reclass_pvt.populate_member_amounts';
   pop_mem_amt_err               EXCEPTION;


BEGIN

if (p_log_level_rec.statement_level) then
  fa_debug_pkg.add(l_calling_fn, '+++ populate member reserve starts +++ ',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
end if;

-- Populate Member Asset id processed in this transaction
open FETCH_MEMBER_ASSET;
fetch FETCH_MEMBER_ASSET into h_member_asset_id;

if FETCH_MEMBER_ASSET%NOTFOUND then

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'No transaction information for this group THID',
                       p_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'No transaction information for this member THID',
                       p_trans_rec.member_transaction_header_id, p_log_level_rec => p_log_level_rec);
   end if;
  close FETCH_MEMBER_ASSET;

else -- Normal processing

  close FETCH_MEMBER_ASSET;

  -- Get current open period counter and transaction period counter

  h_book_type_code := p_asset_hdr_rec.book_type_code;
  h_group_asset_id := p_asset_hdr_rec.asset_id;
  h_set_of_books_id := p_asset_hdr_rec.set_of_books_id;

  -- Populate Subtract Ytd Flag
  if not fa_cache_pkg.fazccmt(X_method => p_asset_fin_rec_new.deprn_method_code,
                              X_life => p_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec) then
    raise pop_mem_amt_err;
  end if;

  -- Populate reserve from dpis to current, eofy_reserve
  if nvl(p_mrc_sob_type_code, 'N') <> 'R' then

    open GET_CUR_PERIOD;
    fetch GET_CUR_PERIOD into h_period_counter, h_cur_fiscal_year, h_cur_period_num;
    if GET_CUR_PERIOD%NOTFOUND then
      raise pop_mem_amt_err;
    end if;

    open MEM_EXP_RESERVE;
    fetch MEM_EXP_RESERVE into h_reserve_dpis_current,h_ytd_deprn,h_ds_fiscal_year;
    if MEM_EXP_RESERVE%NOTFOUND then
      h_reserve_dpis_current := 0;
    end if;
    close MEM_EXP_RESERVE;

    open FA_RET_RSV;
    fetch FA_RET_RSV into h_adj_eofy_reserve;
    close FA_RET_RSV;

    open FA_ADJ_RESERVE;
    fetch FA_ADJ_RESERVE into h_adj_reserve;
    close FA_ADJ_RESERVE;

    select eofy_reserve into h_eofy_reserve
      from fa_books
     where book_type_code = h_book_type_code
       and asset_id = h_member_asset_id
       and date_ineffective is null;

  else

    open GET_CUR_PERIOD_MRC;
    fetch GET_CUR_PERIOD_MRC into h_period_counter, h_cur_fiscal_year, h_cur_period_num;
    if GET_CUR_PERIOD_MRC%NOTFOUND then
      raise pop_mem_amt_err;
    end if;

    open MEM_EXP_RESERVE_MRC;
    fetch MEM_EXP_RESERVE_MRC into h_reserve_dpis_current,h_ytd_deprn,h_ds_fiscal_year;
    if MEM_EXP_RESERVE_MRC%NOTFOUND then
      h_reserve_dpis_current := 0;
    end if;
    close MEM_EXP_RESERVE_MRC;

    open FA_RET_RSV_MRC;
    fetch FA_RET_RSV_MRC into h_adj_eofy_reserve;
    close FA_RET_RSV_MRC;

    open FA_ADJ_RESERVE_MRC;
    fetch FA_ADJ_RESERVE_MRC into h_adj_reserve;
    close FA_ADJ_RESERVE_MRC;

    select eofy_reserve into h_eofy_reserve
      from fa_mc_books
     where book_type_code = h_book_type_code
       and asset_id = h_member_asset_id
       and date_ineffective is null
       and set_of_books_id = h_set_of_books_id;

  end if;

  if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'h_eofy_reserve:reserve_dpis_current',h_eofy_reserve||':'||h_reserve_dpis_current, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'h_period_counter:cur_fiscal_year:cur_period_num',h_period_counter||':'||h_cur_fiscal_year||':'||h_cur_period_num, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'h_ds_fiscal_year', h_ds_fiscal_year, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'h_ytd_deprn', h_ytd_deprn, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'h_adj_eofy_reserve:h_adj_reserve',h_adj_eofy_reserve||':'||h_adj_reserve, p_log_level_rec => p_log_level_rec);
  end if;

  if nvl(h_eofy_reserve,0) = 0 then
    if h_cur_fiscal_year = h_ds_fiscal_year then
       h_eofy_reserve := h_reserve_dpis_current - h_ytd_deprn + nvl(h_adj_eofy_reserve,0) + nvl(h_adj_reserve,0);
    else
       h_eofy_reserve := h_reserve_dpis_current;
    end if;
  end if;

  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'x_deprn_reserve:x_eofy_reserve', h_reserve_dpis_current||':'||h_eofy_reserve, p_log_level_rec => p_log_level_rec);
  end if;

  -- Set return value
  x_deprn_reserve := h_reserve_dpis_current;
  x_eofy_reserve := h_eofy_reserve;

end if;

return true;

EXCEPTION
   when pop_mem_amt_err then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;


end populate_member_reserve;

--+=====================================================================
-- Function: check_reduction_application
--
--  This function will be called to check if 50% rule is applied at group
--  level or not before calling deprn basis rule function for each member
--
--+=====================================================================

FUNCTION check_reduction_application(p_rule_name           in varchar2,
                                     p_group_asset_id      in number,
                                     p_book_type_code      in varchar2,
                                     p_period_counter      in number,
                                     p_group_deprn_basis   in varchar2,
                                     p_reduction_rate      in number,
                                     p_group_eofy_rec_cost in number,
                                     p_group_eofy_salvage_value in number,
                                     p_group_eofy_reserve  in number,
                                     p_mrc_sob_type_code   in varchar2,
                                     p_set_of_books_id     in number,
                                     x_apply_reduction_flag out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

--* Local variables
h_half_year_rule_flag      varchar2(1);

h_change_in_cost           number;
h_change_in_cost_to_reduce number;
h_total_change_in_cost     number;
h_net_proceeds             number;
h_net_proceeds_to_reduce   number;
h_total_net_proceeds       number;
h_first_half_cost          number;
h_first_half_cost_to_reduce number;
h_second_half_cost         number;
h_second_half_cost_to_reduce number;

h_reduction_amount         number;
h_fy_begin_nbv             number;
h_check_amount             number;

l_calling_fn               varchar2(50) := 'FA_TRACK_MEMBER_PVT.CHECK_REDUCTION_APPLICATION';
chk_reduction_err          exception;

begin

  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, '+++ Start to check 50% rule application ++ ', '+++');
  end if;

  if p_rule_name in ('YEAR END BALANCE WITH POSITIVE REDUCTION',
                     'YEAR END BALANCE WITH HALF YEAR RULE') then
    --* Set necessary parameters to call CALC_REDUCTION_AMOUNT
    if p_rule_name = 'YEAR END BALANCE WITH HALF YEAR RULE' then
      h_half_year_rule_flag := 'Y';
    else
      h_half_year_rule_flag := 'N';
    end if;

    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Just before calling CALC_REDUCTION_AMOUNT', '***');
    end if;

    if not FA_CALC_DEPRN_BASIS1_PKG.CALC_REDUCTION_AMOUNT
          (p_asset_id                   => p_group_asset_id,
           p_group_asset_id             => p_group_asset_id,
           p_asset_type                 => 'GROUP',
           p_book_type_code             => p_book_type_code,
           p_period_counter             => p_period_counter,
           p_half_year_rule_flag        => h_half_year_rule_flag,
           p_mrc_sob_type_code          => p_mrc_sob_type_code,
           p_set_of_books_id            => p_set_of_books_id,
           x_change_in_cost             => h_change_in_cost,
           x_change_in_cost_to_reduce   => h_change_in_cost_to_reduce,
           x_total_change_in_cost       => h_total_change_in_cost,
           x_net_proceeds               => h_net_proceeds,
           x_net_proceeds_to_reduce     => h_net_proceeds_to_reduce,
           x_total_net_proceeds         => h_total_net_proceeds,
           x_first_half_cost            => h_first_half_cost,
           x_first_half_cost_to_reduce  => h_first_half_cost_to_reduce,
           x_second_half_cost           => h_second_half_cost,
           x_second_half_cost_to_reduce => h_second_half_cost_to_reduce, p_log_level_rec => p_log_level_rec) then

      raise chk_reduction_err;

    end if; -- Call CALC_REDUCTION_AMOUNT

    h_reduction_amount := 0;
    x_apply_reduction_flag := NULL;

    -- Check the deprn basis rule name
    if p_rule_name = 'YEAR END BALANCE WITH POSITIVE REDUCTION' then
      -- This is a logic for Positive Reduction
      -- Check to apply reduction amount and calculate reduction amount

      If (h_change_in_cost - h_net_proceeds >0) then
        if p_group_deprn_basis ='COST' then
          h_reduction_amount := nvl(h_change_in_cost_to_reduce,0);
        else -- NBV Base
          h_reduction_amount := nvl(h_change_in_cost_to_reduce,0) - nvl(h_net_proceeds_to_reduce,0);
        end if;
      end if;  -- Reduction amount condition

      if h_reduction_amount<>0 then
        -- Apply reduction amount to group asset
        x_apply_reduction_flag :='Y';
      end if;

    else -- Case for Half Year Rule
      -- Check whether 1st half year's reduction amount
      h_fy_begin_nbv := nvl(p_group_eofy_rec_cost,0) + nvl(p_group_eofy_salvage_value,0)
                                                             - nvl(p_group_eofy_reserve,0);

      h_check_amount := nvl(h_fy_begin_nbv,0) + nvl(h_first_half_cost,0) - nvl(h_net_proceeds,0);

      x_apply_reduction_flag := 'N';
      -- Calculate first reduction amount
      if (h_check_amount < 0) then
        h_reduction_amount := h_check_amount*nvl(p_reduction_rate,0);
        if h_reduction_amount<>0 then
          -- Apply reduction amount to group asset
          x_apply_reduction_flag :='Y';
        end if;
      else
        x_apply_reduction_flag := 'Y';
      end if; -- End calculate first reduction amount
    end if; -- (if Rule Name = POSITIVE REDUCTION?)
  end if; -- (if Rule Name in (POSITIVE REDUCTION, HALF YEAR)?)
  --* This is the end of 50% rule applicablity check

return (true);

EXCEPTION
   when chk_reduction_err then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;


end check_reduction_application;


--+=====================================================================
-- Function: display_debug_message
--
--  This function will be called to display debug message
--
--+=====================================================================

FUNCTION display_debug_message(fa_rule_in                  in fa_std_types.fa_deprn_rule_in_struct,
                               p_calling_fn                in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean is

--* local variables
l_calling_fn         varchar2(50);
begin

l_calling_fn := p_calling_fn;

fa_debug_pkg.add(l_calling_fn, '++ Debug Message for fa_rule_in structure ++', fa_rule_in.asset_id, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.event_type', fa_rule_in.event_type, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.book_type_code', fa_rule_in.book_type_code, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.asset_type', fa_rule_in.asset_type, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.method_code', fa_rule_in.method_code, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.life_in_months', fa_rule_in.life_in_months, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.cost',fa_rule_in.cost, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.salvage_value',fa_rule_in.salvage_value, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.recoverable_cost',fa_rule_in.recoverable_cost, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.current_total_rsv', fa_rule_in.current_total_rsv, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.current_rsv', fa_rule_in.current_rsv, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.current_total_ytd', fa_rule_in.current_total_ytd, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.old_adjusted_cost', fa_rule_in.old_adjusted_cost, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.old_raf',fa_rule_in.old_raf, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.period_counter', fa_rule_in.period_counter, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.fiscal_year', fa_rule_in.fiscal_year, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.tracking_method',fa_rule_in.tracking_method, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.used_by_adjustment', fa_rule_in.used_by_adjustment, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.eofy_flag', fa_rule_in.eofy_flag, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.eofy_reserve', fa_rule_in.eofy_reserve, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'fa_rule_in.mrc_sob_type_code', fa_rule_in.mrc_sob_type_code, p_log_level_rec => p_log_level_rec);

return(true);

end display_debug_message;

--+=====================================================================
-- Function: display_debug_message2
--
--  This function will be called to display debug message
--  This is for p_track_member_table
--+=====================================================================

FUNCTION display_debug_message2(i                  in number,
                                p_calling_fn       in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean is

--* local variables
l_calling_fn         varchar2(50);
begin

l_calling_fn := p_calling_fn;

fa_debug_pkg.add(l_calling_fn, '++ Debug Message display for p_track_member_table ++ Indicator ', i, p_log_level_rec => p_log_level_rec);
fa_debug_pkg.add(l_calling_fn, 'member_asset_id', p_track_member_table(i).member_asset_id);
fa_debug_pkg.add(l_calling_fn, 'set_of_books_id', p_track_member_table(i).set_of_books_id);
fa_debug_pkg.add(l_calling_fn, 'period_counter', p_track_member_table(i).period_counter);
fa_debug_pkg.add(l_calling_fn, 'fiscal_year', p_track_member_table(i).fiscal_year);
fa_debug_pkg.add(l_calling_fn, 'cost', p_track_member_table(i).cost);
fa_debug_pkg.add(l_calling_fn, 'salvage_value', p_track_member_table(i).salvage_value);
fa_debug_pkg.add(l_calling_fn, 'recoverable_cost', p_track_member_table(i).recoverable_cost);
fa_debug_pkg.add(l_calling_fn, 'adjusted_cost', p_track_member_table(i).adjusted_cost);
fa_debug_pkg.add(l_calling_fn, 'adjusted_recoverable_cost', p_track_member_table(i).adjusted_recoverable_cost);
fa_debug_pkg.add(l_calling_fn, 'deprn_amount', p_track_member_table(i).allocated_deprn_amount);
fa_debug_pkg.add(l_calling_fn, 'deprn_reserve', p_track_member_table(i).deprn_reserve);
fa_debug_pkg.add(l_calling_fn, 'ytd_deprn', p_track_member_table(i).ytd_deprn);
fa_debug_pkg.add(l_calling_fn, 'bonus_deprn_amount', p_track_member_table(i).allocated_bonus_amount);
fa_debug_pkg.add(l_calling_fn, 'bonus_deprn_reserve', p_track_member_table(i).bonus_deprn_reserve);
fa_debug_pkg.add(l_calling_fn, 'bonus_ytd_deprn', p_track_member_table(i).bonus_ytd_deprn);
fa_debug_pkg.add(l_calling_fn, 'eofy_reserve', p_track_member_table(i).eofy_reserve);
fa_debug_pkg.add(l_calling_fn, 'eofy_recoverable_cost', p_track_member_table(i).eofy_recoverable_cost);
fa_debug_pkg.add(l_calling_fn, 'eofy_salvage_value', p_track_member_table(i).eofy_salvage_value);
fa_debug_pkg.add(l_calling_fn, 'fully_reserved_flag', p_track_member_table(i).fully_reserved_flag);
fa_debug_pkg.add(l_calling_fn, 'fully_retired_flag', p_track_member_table(i).fully_retired_flag);

return true;

end display_debug_message2;

--+=====================================================================
-- Function: copy_member_table
--
--  This function will be called to backup the memory table
--  restore backuped memory table
--
--+=====================================================================

FUNCTION copy_member_table(p_backup_restore        in varchar2,
                           p_current_fiscal_year   in number,
                           p_current_period_num    in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

  return boolean is

--* local variables
h_period_counter     number;
h_number_per_fy      number;
l_calling_fn         varchar2(50) := 'FA_TRACK_MEMBER_PVT.COPY_MEMBER_TABLE';

begin

if p_backup_restore = 'BACKUP' then
  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, '++++ Backup p_track_member_table starts ++++', '++++', p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn, 'Backup p_track_member_table rows', p_track_member_table.COUNT, p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn, 'Last processed fiscal year:period_num', p_current_fiscal_year||':'||p_current_period_num, p_log_level_rec => p_log_level_rec);
  end if;

  if p_current_fiscal_year is not null and p_current_period_num is not null then
    h_number_per_fy := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
    h_period_counter := p_current_fiscal_year*h_number_per_fy+p_current_period_num;
  else
    h_period_counter := NULL;
  end if;

  p_track_member_table_for_deprn.delete;

  For l_ind IN 1.. p_track_member_table.COUNT LOOP

   p_track_member_table_for_deprn(l_ind).group_asset_id := p_track_member_table(l_ind).group_asset_id;
   p_track_member_table_for_deprn(l_ind).member_asset_id := p_track_member_table(l_ind).member_asset_id;
   p_track_member_table_for_deprn(l_ind).period_counter := p_track_member_table(l_ind).period_counter;
   p_track_member_table_for_deprn(l_ind).fiscal_year := p_track_member_table(l_ind).fiscal_year;
   p_track_member_table_for_deprn(l_ind).set_of_books_id := p_track_member_table(l_ind).set_of_books_id;
   p_track_member_table_for_deprn(l_ind).allocation_basis := p_track_member_table(l_ind).allocation_basis;
   p_track_member_table_for_deprn(l_ind).total_allocation_basis := p_track_member_table(l_ind).total_allocation_basis;
   p_track_member_table_for_deprn(l_ind).allocated_deprn_amount:= p_track_member_table(l_ind).allocated_deprn_amount;
   p_track_member_table_for_deprn(l_ind).allocated_bonus_amount:= p_track_member_table(l_ind).allocated_bonus_amount;
   p_track_member_table_for_deprn(l_ind).system_deprn_amount:= p_track_member_table(l_ind).system_deprn_amount;
   p_track_member_table_for_deprn(l_ind).system_bonus_amount:= p_track_member_table(l_ind).system_bonus_amount;
   p_track_member_table_for_deprn(l_ind).fully_reserved_flag := p_track_member_table(l_ind).fully_reserved_flag;
   p_track_member_table_for_deprn(l_ind).fully_retired_flag := p_track_member_table(l_ind).fully_retired_flag;
   p_track_member_table_for_deprn(l_ind).override_flag := p_track_member_table(l_ind).override_flag;
   p_track_member_table_for_deprn(l_ind).cost := p_track_member_table(l_ind).cost;
   p_track_member_table_for_deprn(l_ind).adjusted_cost := p_track_member_table(l_ind).adjusted_cost;
   p_track_member_table_for_deprn(l_ind).eofy_adj_cost := p_track_member_table(l_ind).eofy_adj_cost;
   p_track_member_table_for_deprn(l_ind).recoverable_cost := p_track_member_table(l_ind).recoverable_cost;
   p_track_member_table_for_deprn(l_ind).salvage_value := p_track_member_table(l_ind).salvage_value;
   p_track_member_table_for_deprn(l_ind).adjusted_recoverable_cost := p_track_member_table(l_ind).adjusted_recoverable_cost;
   p_track_member_table_for_deprn(l_ind).eofy_reserve := p_track_member_table(l_ind).eofy_reserve;
   p_track_member_table_for_deprn(l_ind).deprn_reserve := p_track_member_table(l_ind).deprn_reserve;
   p_track_member_table_for_deprn(l_ind).ytd_deprn := p_track_member_table(l_ind).ytd_deprn;
   p_track_member_table_for_deprn(l_ind).bonus_deprn_reserve := p_track_member_table(l_ind).bonus_deprn_reserve;
   p_track_member_table_for_deprn(l_ind).bonus_ytd_deprn := p_track_member_table(l_ind).bonus_ytd_deprn;
   p_track_member_table_for_deprn(l_ind).eofy_recoverable_cost := p_track_member_table(l_ind).eofy_recoverable_cost;
   p_track_member_table_for_deprn(l_ind).eop_recoverable_cost := p_track_member_table(l_ind).eop_recoverable_cost;
   p_track_member_table_for_deprn(l_ind).eofy_salvage_value := p_track_member_table(l_ind).eofy_salvage_value;
   p_track_member_table_for_deprn(l_ind).eop_salvage_value := p_track_member_table(l_ind).eop_salvage_value;

   --p_track_member_table_for_deprn(l_ind).member_index := p_track_member_table(l_ind).member_index;

 End Loop;

else
  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, '++++ Restore p_track_member_table starts ++++', '++++', p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn, 'Restored p_track_member_table rows', p_track_member_table_for_deprn.COUNT, p_log_level_rec => p_log_level_rec);
  end if;

  p_track_member_table.delete;
  p_track_mem_index_table.delete;

  For l_ind IN 1.. p_track_member_table_for_deprn.COUNT LOOP

   p_track_member_table(l_ind).group_asset_id := p_track_member_table_for_deprn(l_ind).group_asset_id;
   p_track_member_table(l_ind).member_asset_id := p_track_member_table_for_deprn(l_ind).member_asset_id;
   p_track_member_table(l_ind).period_counter := p_track_member_table_for_deprn(l_ind).period_counter;
   p_track_member_table(l_ind).fiscal_year := p_track_member_table_for_deprn(l_ind).fiscal_year;
   p_track_member_table(l_ind).set_of_books_id := p_track_member_table_for_deprn(l_ind).set_of_books_id;
   p_track_member_table(l_ind).allocation_basis := p_track_member_table_for_deprn(l_ind).allocation_basis;
   p_track_member_table(l_ind).total_allocation_basis := p_track_member_table_for_deprn(l_ind).total_allocation_basis;
   p_track_member_table(l_ind).allocated_deprn_amount:= p_track_member_table_for_deprn(l_ind).allocated_deprn_amount;
   p_track_member_table(l_ind).allocated_bonus_amount:= p_track_member_table_for_deprn(l_ind).allocated_bonus_amount;
   p_track_member_table(l_ind).system_deprn_amount:= p_track_member_table_for_deprn(l_ind).system_deprn_amount;
   p_track_member_table(l_ind).system_bonus_amount:= p_track_member_table_for_deprn(l_ind).system_bonus_amount;
   p_track_member_table(l_ind).fully_reserved_flag := p_track_member_table_for_deprn(l_ind).fully_reserved_flag;
   p_track_member_table(l_ind).fully_retired_flag := p_track_member_table_for_deprn(l_ind).fully_retired_flag;
   p_track_member_table(l_ind).override_flag := p_track_member_table_for_deprn(l_ind).override_flag;
   p_track_member_table(l_ind).cost := p_track_member_table_for_deprn(l_ind).cost;
   p_track_member_table(l_ind).adjusted_cost := p_track_member_table_for_deprn(l_ind).adjusted_cost;
   p_track_member_table(l_ind).eofy_adj_cost := p_track_member_table_for_deprn(l_ind).eofy_adj_cost;
   p_track_member_table(l_ind).recoverable_cost := p_track_member_table_for_deprn(l_ind).recoverable_cost;
   p_track_member_table(l_ind).salvage_value := p_track_member_table_for_deprn(l_ind).salvage_value;
   p_track_member_table(l_ind).adjusted_recoverable_cost := p_track_member_table_for_deprn(l_ind).adjusted_recoverable_cost;
   p_track_member_table(l_ind).eofy_reserve := p_track_member_table_for_deprn(l_ind).eofy_reserve;
   p_track_member_table(l_ind).deprn_reserve := p_track_member_table_for_deprn(l_ind).deprn_reserve;
   p_track_member_table(l_ind).ytd_deprn := p_track_member_table_for_deprn(l_ind).ytd_deprn;
   p_track_member_table(l_ind).bonus_deprn_reserve := p_track_member_table_for_deprn(l_ind).bonus_deprn_reserve;
   p_track_member_table(l_ind).bonus_ytd_deprn := p_track_member_table_for_deprn(l_ind).bonus_ytd_deprn;
   p_track_member_table(l_ind).eofy_recoverable_cost := p_track_member_table_for_deprn(l_ind).eofy_recoverable_cost;
   p_track_member_table(l_ind).eop_recoverable_cost := p_track_member_table_for_deprn(l_ind).eop_recoverable_cost;
   p_track_member_table(l_ind).eofy_salvage_value := p_track_member_table_for_deprn(l_ind).eofy_salvage_value;
   p_track_member_table(l_ind).eop_salvage_value := p_track_member_table_for_deprn(l_ind).eop_salvage_value;

 put_track_index(p_track_member_table_for_deprn(l_ind).period_counter,p_track_member_table_for_deprn(l_ind).member_asset_id,
                 p_track_member_table_for_deprn(l_ind).group_asset_id,p_track_member_table_for_deprn(l_ind).set_of_books_id,
                 l_ind,p_log_level_rec);

   --p_track_member_table(l_ind).member_index := p_track_member_table_for_deprn(l_ind).member_index;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('#### HH Test ###', 'Period Counter, member_asset_id restored',
                      p_track_member_table(l_ind).period_counter||','||
                      p_track_member_table(l_ind).member_asset_id);
   end if;

 End Loop;

end if;

if (p_log_level_rec.statement_level) then
  fa_debug_pkg.add(l_calling_fn, p_backup_restore||' has been done ++++', '++++', p_log_level_rec => p_log_level_rec);
end if;

return(true);

end copy_member_table;

--+=====================================================================
-- Function: create_update_books_summary
--
--  This function will be called to insert row into fa_books_summary if not exists
--  update fa_books_summary row if exists
--  Used merge statement for bug 7195989
--+=====================================================================

FUNCTION create_update_bs_table(p_trans_rec         in FA_API_TYPES.trans_rec_type,
                                p_book_type_code    in varchar2,
                                p_group_asset_id    in varchar2,
                                p_mrc_sob_type_code in varchar2,
                                p_sob_id            in number, --Bug 8941132
                                p_calling_fn        in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

--* Local variables
l_calling_fn        varchar2(50) := 'FA_TRACK_MEMBER_PVT.create_update_bs_table';

type t_type_num is table of number index by binary_integer;
type t_type_varchar is table of varchar2(1000) index by binary_integer;
type t_type_date is table of date index by binary_integer;
l_tbl_group_asset_id t_type_num;
l_tbl_member_asset_id t_type_num;
l_tbl_period_counter t_type_num;
l_tbl_set_of_books_id t_type_num;
l_tbl_alloc_deprn_amt t_type_num;
l_tbl_alloc_bonus_amt t_type_num;
l_tbl_cost t_type_num;
l_tbl_adjusted_cost t_type_num;
l_tbl_recoverable_cost t_type_num;
l_tbl_salvage_value t_type_num;
l_tbl_adj_recoverable_cost t_type_num;
l_tbl_deprn_reserve t_type_num;
l_tbl_ytd_deprn t_type_num;
l_tbl_bonus_ytd_deprn t_type_num;
l_tbl_bonus_deprn_reserve t_type_num;
l_tbl_eofy_reserve t_type_num;

l_primary_sob number; --Bug 8941132
k number; --Bug 8941132


begin
      l_primary_sob := fa_cache_pkg.fazcbc_record.set_of_books_id; --Bug 8941132
      k:=1; --Bug 8941132

      for i IN 1.. p_track_member_table.COUNT
      loop
         if p_sob_id = p_track_member_table(i).SET_OF_BOOKS_ID then
            l_tbl_group_asset_id(k)  := p_track_member_table(i).GROUP_ASSET_ID;
            l_tbl_member_asset_id(k) := p_track_member_table(i).MEMBER_ASSET_ID;
            l_tbl_period_counter(k)  := p_track_member_table(i).PERIOD_COUNTER;
            l_tbl_set_of_books_id(k) := p_track_member_table(i).SET_OF_BOOKS_ID;
            l_tbl_alloc_deprn_amt(k) := p_track_member_table(i).ALLOCATED_DEPRN_AMOUNT;
            l_tbl_alloc_bonus_amt(k) := p_track_member_table(i).ALLOCATED_BONUS_AMOUNT;
            l_tbl_cost(k)             := p_track_member_table(i).COST;
            l_tbl_adjusted_cost(k)    := p_track_member_table(i).ADJUSTED_COST;
            l_tbl_recoverable_cost(k) := p_track_member_table(i).RECOVERABLE_COST;
            l_tbl_salvage_value(k)    := p_track_member_table(i).SALVAGE_VALUE;
            l_tbl_adj_recoverable_cost(k) :=  p_track_member_table(i).ADJUSTED_RECOVERABLE_COST;
            l_tbl_deprn_reserve(k)    := p_track_member_table(i).DEPRN_RESERVE;
            l_tbl_ytd_deprn(k)        := p_track_member_table(i).YTD_DEPRN;
            l_tbl_bonus_deprn_reserve(k) := p_track_member_table(i).BONUS_DEPRN_RESERVE;
            l_tbl_bonus_ytd_deprn(k)  := p_track_member_table(i).BONUS_YTD_DEPRN;
            l_tbl_eofy_reserve(k) := p_track_member_table(i).EOFY_RESERVE;
            k:= k+1;
         end if;
      end loop;

   if p_mrc_sob_type_code = 'R' then
      forall j in 1..l_tbl_member_asset_id.COUNT
      MERGE INTO FA_MC_BOOKS_SUMMARY BS
      USING (SELECT
                  l_tbl_group_asset_id(j) as group_asset_id,
                  l_tbl_member_asset_id(j) as member_asset_id,
                  l_tbl_period_counter(j) as period_counter,
                  l_tbl_set_of_books_id(j) as set_of_books_id,
                  l_tbl_alloc_deprn_amt(j) as allocated_deprn_amount,
                  l_tbl_alloc_bonus_amt(j) as allocated_bonus_amount,
                  l_tbl_cost(j) as cost,
                  l_tbl_adjusted_cost(j) as adjusted_cost,
                  l_tbl_recoverable_cost(j) as recoverable_cost,
                  l_tbl_salvage_value(j) as salvage_value,
                  l_tbl_adj_recoverable_cost(j) as adjusted_recoverable_cost,
                  l_tbl_deprn_reserve(j) as deprn_reserve,
                  l_tbl_ytd_deprn(j) as ytd_deprn,
                  l_tbl_bonus_deprn_reserve(j) as bonus_deprn_reserve,
                  l_tbl_bonus_ytd_deprn(j) as bonus_ytd_deprn,
                  l_tbl_eofy_reserve(j) as eofy_reserve
            from dual
            ) TM
         ON ((BS.ASSET_ID = tm.member_asset_id) AND
             (BS.BOOK_TYPE_CODE = p_book_type_code) AND
             (BS.SET_OF_BOOKS_ID = tm.set_of_books_id) AND
             (BS.PERIOD_COUNTER = tm.period_counter))
         WHEN MATCHED THEN
            UPDATE
            SET    BS.COST                       = tm.cost,
                   BS.SALVAGE_VALUE              = tm.salvage_value,
                   BS.RECOVERABLE_COST           = tm.recoverable_cost,
                   BS.ADJUSTED_RECOVERABLE_COST  = tm.adjusted_recoverable_cost,
                   BS.ADJUSTED_COST              = tm.adjusted_cost,
                   BS.DEPRN_AMOUNT               = tm.allocated_deprn_amount,
                   BS.YTD_DEPRN                  = tm.ytd_deprn,
                   BS.DEPRN_RESERVE              = tm.deprn_reserve,
                   BS.BONUS_DEPRN_AMOUNT         = tm.allocated_bonus_amount,
                   BS.BONUS_YTD_DEPRN            = tm.bonus_ytd_deprn,
                   BS.BONUS_DEPRN_RESERVE        = tm.bonus_deprn_reserve,
                   BS.EOFY_RESERVE               = tm.eofy_reserve,
                   BS.LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date,
                   BS.LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by,
                   BS.LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
         WHEN NOT MATCHED THEN
            INSERT (BS.SET_OF_BOOKS_ID,
                    BS.ASSET_ID,
                    BS.GROUP_ASSET_ID,
                    BS.BOOK_TYPE_CODE,
                    BS.PERIOD_COUNTER,
                    BS.COST,
                    BS.SALVAGE_VALUE,
                    BS.RECOVERABLE_COST,
                    BS.ADJUSTED_COST,
                    BS.ADJUSTED_RECOVERABLE_COST,
                    BS.DEPRN_AMOUNT,
                    BS.BONUS_DEPRN_AMOUNT,
                    BS.DEPRN_RESERVE,
                    BS.BONUS_DEPRN_RESERVE,
                    BS.YTD_DEPRN,
                    BS.BONUS_YTD_DEPRN,
                    BS.EOFY_RESERVE,
                    BS.CREATION_DATE,
                    BS.CREATED_BY,
                    BS.LAST_UPDATE_DATE,
                    BS.LAST_UPDATED_BY,
                    BS.LAST_UPDATE_LOGIN
            ) VALUES (
                    tm.set_of_books_id,
                    tm.member_asset_id,
                    tm.group_asset_id,
                    p_book_type_code,
                    tm.period_counter,
                    tm.cost,
                    tm.salvage_value,
                    tm.recoverable_cost,
                    tm.adjusted_cost,
                    tm.adjusted_recoverable_cost,
                    tm.allocated_deprn_amount,
                    tm.allocated_bonus_amount,
                    tm.deprn_reserve,
                    tm.bonus_deprn_reserve,
                    tm.ytd_deprn,
                    tm.bonus_ytd_deprn,
                    tm.eofy_reserve,
                    p_trans_rec.who_info.last_update_date,
                    p_trans_rec.who_info.last_updated_by,
                    p_trans_rec.who_info.last_update_date,
                    p_trans_rec.who_info.last_updated_by,
                    p_trans_rec.who_info.last_update_login
            );

   else
      forall j in 1..l_tbl_member_asset_id.COUNT
      MERGE INTO FA_BOOKS_SUMMARY BS
      USING (
            SELECT
                  l_tbl_group_asset_id(j) as group_asset_id,
                  l_tbl_member_asset_id(j) as member_asset_id,
                  l_tbl_period_counter(j) as period_counter,
                  l_tbl_set_of_books_id(j) as set_of_books_id,
                  l_tbl_alloc_deprn_amt(j) as allocated_deprn_amount,
                  l_tbl_alloc_bonus_amt(j) as allocated_bonus_amount,
                  l_tbl_cost(j) as cost,
                  l_tbl_adjusted_cost(j) as adjusted_cost,
                  l_tbl_recoverable_cost(j) as recoverable_cost,
                  l_tbl_salvage_value(j) as salvage_value,
                  l_tbl_adj_recoverable_cost(j) as adjusted_recoverable_cost,
                  l_tbl_deprn_reserve(j) as deprn_reserve,
                  l_tbl_ytd_deprn(j) as ytd_deprn,
                  l_tbl_bonus_deprn_reserve(j) as bonus_deprn_reserve,
                  l_tbl_bonus_ytd_deprn(j) as bonus_ytd_deprn,
                  l_tbl_eofy_reserve(j) as eofy_reserve
            from dual
            ) TM
         ON ((BS.ASSET_ID = tm.member_asset_id) AND
             (BS.BOOK_TYPE_CODE = p_book_type_code) AND
             (BS.PERIOD_COUNTER = tm.period_counter))
         WHEN MATCHED THEN
            UPDATE
            SET    BS.COST                       = tm.cost,
                   BS.SALVAGE_VALUE              = tm.salvage_value,
                   BS.RECOVERABLE_COST           = tm.recoverable_cost,
                   BS.ADJUSTED_RECOVERABLE_COST  = tm.adjusted_recoverable_cost,
                   BS.ADJUSTED_COST              = tm.adjusted_cost,
                   BS.DEPRN_AMOUNT               = tm.allocated_deprn_amount,
                   BS.YTD_DEPRN                  = tm.ytd_deprn,
                   BS.DEPRN_RESERVE              = tm.deprn_reserve,
                   BS.BONUS_DEPRN_AMOUNT         = tm.allocated_bonus_amount,
                   BS.BONUS_YTD_DEPRN            = tm.bonus_ytd_deprn,
                   BS.BONUS_DEPRN_RESERVE        = tm.bonus_deprn_reserve,
                   BS.EOFY_RESERVE               = tm.eofy_reserve,
                   BS.LAST_UPDATE_DATE           = p_trans_rec.who_info.last_update_date,
                   BS.LAST_UPDATED_BY            = p_trans_rec.who_info.last_updated_by,
                   BS.LAST_UPDATE_LOGIN          = p_trans_rec.who_info.last_update_login
         WHEN NOT MATCHED THEN
            INSERT (BS.ASSET_ID,
                    BS.GROUP_ASSET_ID,
                    BS.BOOK_TYPE_CODE,
                    BS.PERIOD_COUNTER,
                    BS.COST,
                    BS.SALVAGE_VALUE,
                    BS.RECOVERABLE_COST,
                    BS.ADJUSTED_COST,
                    BS.ADJUSTED_RECOVERABLE_COST,
                    BS.DEPRN_AMOUNT,
                    BS.BONUS_DEPRN_AMOUNT,
                    BS.DEPRN_RESERVE,
                    BS.BONUS_DEPRN_RESERVE,
                    BS.YTD_DEPRN,
                    BS.BONUS_YTD_DEPRN,
                    BS.EOFY_RESERVE,
                    BS.CREATION_DATE,
                    BS.CREATED_BY,
                    BS.LAST_UPDATE_DATE,
                    BS.LAST_UPDATED_BY,
                    BS.LAST_UPDATE_LOGIN
            ) VALUES (
                    tm.member_asset_id,
                    tm.group_asset_id,
                    p_book_type_code,
                    tm.period_counter,
                    tm.cost,
                    tm.salvage_value,
                    tm.recoverable_cost,
                    tm.adjusted_cost,
                    tm.adjusted_recoverable_cost,
                    tm.allocated_deprn_amount,
                    tm.allocated_bonus_amount,
                    tm.deprn_reserve,
                    tm.bonus_deprn_reserve,
                    tm.ytd_deprn,
                    tm.bonus_ytd_deprn,
                    tm.eofy_reserve,
                    p_trans_rec.who_info.last_update_date,
                    p_trans_rec.who_info.last_updated_by,
                    p_trans_rec.who_info.last_update_date,
                    p_trans_rec.who_info.last_updated_by,
                    p_trans_rec.who_info.last_update_login
            );
   end if;
   return (true);

exception
  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

end create_update_bs_table;

--+=====================================================================
-- Function: override_member_amount
--
--  This function will be called to override deprn amount of member assets
--  This is called only when populate_member_assets_table calls
--
--+=====================================================================

FUNCTION override_member_amount(p_book_type_code        in varchar2,
                                p_member_asset_id       in number,
                                p_fiscal_year           in number,
                                p_period_num            in number,
                                p_ytd_deprn             in number,
                                p_bonus_ytd_deprn       in number,
                                x_override_deprn_amount out nocopy number,
                                x_override_bonus_amount out nocopy number,
                                x_deprn_override_flag   out nocopy varchar2,
                                p_calling_fn            in varchar2,
                                p_mrc_sob_type_code     in varchar2,
                                p_recoverable_cost      in number,
                                p_salvage_value         in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean is

--* Local variables
h_period_name             varchar2(15);
h_set_of_books_id         number;
h_reporting_flag          varchar2(1);

h_calendar_type           varchar2(15);
h_fy_name                 varchar2(30);
h_num_per_fy              number;

h_subtract_ytd_flag       varchar2(1);
h_deprn_override_id       number;

report_cost               number;
l_avg_rate                number;

--* Exceptions
l_calling_fn              varchar2(50) := 'FA_TRACK_MEMBER_PVT.OVERRIDE_MEMBER_AMOUNTS';

--* Cursor to query FA_DEPRN_OVERRIDE with 'POSTED' and 'DEPRECIATION'
cursor GET_OVERRIDE_AMOUNT is
   SELECT deprn_amount, bonus_deprn_amount, subtract_ytd_flag, deprn_override_id
     FROM FA_DEPRN_OVERRIDE
    WHERE
      book_type_code = p_book_type_code and
      asset_id = p_member_asset_id and
      period_name = h_period_name and
      used_by = 'DEPRECIATION' and
      status = 'POSTED';

begin

if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, '*** Start OVERRIDE for populate_member_assets_table process', '***');
    fa_debug_pkg.add(l_calling_fn, 'p_book_type_code:p_member_asset_id:p_mrc_sob_type_code',
                                    p_book_type_code||':'||p_member_asset_id||':'||p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
    fa_debug_pkg.add(l_calling_fn, 'p_calling_fn', p_calling_fn, p_log_level_rec => p_log_level_rec);
end if;

if nvl(p_calling_fn,'NULL') = 'POPULATE_MEMBER_ASSETS_TABLE' then
  -- This funcation can work only during processing populate_member_assets_table

  IF p_mrc_sob_type_code = 'R' THEN
    h_reporting_flag := 'R';
  ELSE
    h_reporting_flag := 'P';
  END IF;

  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'h_set_of_books_id:h_reporting_flag', h_set_of_books_id||':'||h_reporting_flag, p_log_level_rec => p_log_level_rec);
  end if;
   /* select the corresponding period_counter for the current period: fyctr, perd_ctr */
  h_calendar_type:= fa_cache_pkg.fazcbc_record.deprn_calendar;
  h_fy_name:= fa_cache_pkg.fazcbc_record.fiscal_year_name;
  h_num_per_fy:= fa_cache_pkg.fazcct_record.number_per_fiscal_year;

  select cp.period_name
    into h_period_name
    from fa_calendar_periods cp, fa_fiscal_year fy
   where cp.calendar_type = h_calendar_type and
         cp.period_num = p_period_num and
         cp.start_date >= fy.start_date and
         cp.end_date <= fy.end_date and
         fy.fiscal_year_name = h_fy_name and
         fy.fiscal_year = p_fiscal_year;

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'h_period_name', h_period_name, p_log_level_rec => p_log_level_rec);
  end if;
  /* Query override table */
  open GET_OVERRIDE_AMOUNT;
  fetch GET_OVERRIDE_AMOUNT INTO x_override_deprn_amount, x_override_bonus_amount, h_subtract_ytd_flag, h_deprn_override_id;
  close GET_OVERRIDE_AMOUNT;

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'x_override_deprn:bonus_amount', x_override_deprn_amount||':'||x_override_bonus_amount, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'p_ytd_deprn:bonus_ytd', p_ytd_deprn||':'||p_bonus_ytd_deprn, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'p_recoverable_cost:p_salvage_value', p_recoverable_cost||':'||p_salvage_value, p_log_level_rec => p_log_level_rec);
  end if;

  l_avg_rate := 1;

  if (h_reporting_flag <> 'R') then
     primary_cost:= p_recoverable_cost + p_salvage_value;
  else
     report_cost:= p_recoverable_cost + p_salvage_value;
  end if;

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'primary_cost:report_cost', primary_cost||':'||report_cost, p_log_level_rec => p_log_level_rec);
  end if;

   -- ratio = Reporting Books Cost / Primary books Cost for adjustment.
   --         the above calculation can be used once the depreciaion
   --         program was built in one-step.
   --       = use latest average rate for depreciation until one-step depreciation is built.

  if primary_cost <> 0 then
    l_avg_rate:= report_cost / primary_cost;
  end if;

  IF x_override_deprn_amount is not null THEN
      x_deprn_override_flag:= fa_std_types.FA_OVERRIDE_DPR;
      x_deprn_override_flag:= fa_std_types.FA_OVERRIDE_DPR;
      if (h_reporting_flag = 'R') then
          x_override_deprn_amount := x_override_deprn_amount * l_avg_rate;
      end if;
      IF x_override_bonus_amount is not null THEN
         x_deprn_override_flag:= fa_std_types.FA_OVERRIDE_DPR_BONUS;
         if (h_reporting_flag = 'R') then
           x_override_bonus_amount:= x_override_bonus_amount * l_avg_rate;
         end if;
      END IF;
  ELSIF x_override_bonus_amount is not null THEN
      x_deprn_override_flag:= fa_std_types.FA_OVERRIDE_BONUS;
      if (h_reporting_flag = 'R') then
         x_override_bonus_amount:= x_override_bonus_amount * l_avg_rate;
      end if;
   ELSE
      x_deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
   END IF;

  --  When user provided YTD amount
  IF NVL(h_subtract_ytd_flag,'N') = 'Y' THEN
    x_override_deprn_amount := x_override_deprn_amount - (p_ytd_deprn - p_bonus_ytd_deprn);
    x_override_bonus_amount := x_override_bonus_amount - p_bonus_ytd_deprn;
  END IF;

  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'x_override_deprn:bonus_amount:override_flag',
                     x_override_deprn_amount||':'||x_override_bonus_amount||':'||x_deprn_override_flag, p_log_level_rec => p_log_level_rec);
  end if;

end if;

return(TRUE);

exception
   when others then
      x_deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return(TRUE);

end override_member_amount;

/* This function populates unplanned expense details
to PL-SQL table p_track_member_table
created for bug 7195989
*/
FUNCTION populate_unplanned_exp(p_set_of_books_id IN NUMBER,
                           p_mrc_sob_type_code in VARCHAR2,
                           p_book_type_code IN VARCHAR2,
                           p_period_counter IN NUMBER,
                           p_group_asset_id IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return boolean IS
cursor C_FA_ADJ_UNPLANNED is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                       decode(adj.debit_credit_flag,
                 'DR',adj.adjustment_amount,
                 'CR', -1 * adj.adjustment_amount))) as grp_unpln_exp,
          sum(decode(adj.adjustment_type,'EXPENSE',
                       decode(adj.debit_credit_flag,
                 'DR',adj.adjustment_amount,
                 'CR', -1 * adj.adjustment_amount))) as mem_unpln_exp,
          th2.asset_id member_asset_id
     from fa_adjustments adj,
        fa_adjustments adj_mem,
        fa_transaction_headers th1,
        fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = p_group_asset_id
      and adj.book_type_code = p_book_type_code
      and adj.period_counter_adjusted = p_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.transaction_type_code = 'ADJUSTMENT'
      and th2.transaction_key in ('UA','UE')
      and adj_mem.transaction_header_id(+) = th2.transaction_header_id
      and adj_mem.period_counter_adjusted(+) = p_period_counter
      and adj_mem.asset_id(+) = th2.asset_id
      and nvl(adj_mem.track_member_flag(+),'N') = 'N'
   group by th2.asset_id;

cursor C_FA_ADJ_UNPLANNED_MRC is
   select sum(decode(adj.adjustment_type,'EXPENSE',
                       decode(adj.debit_credit_flag,
                 'DR',adj.adjustment_amount,
                 'CR', -1 * adj.adjustment_amount))) as grp_unpln_exp,
          sum(decode(adj.adjustment_type,'EXPENSE',
                       decode(adj.debit_credit_flag,
                 'DR',adj.adjustment_amount,
                 'CR', -1 * adj.adjustment_amount))) as mem_unpln_exp,
          th2.asset_id member_asset_id
     from fa_mc_adjustments adj,
        fa_mc_adjustments adj_mem,
        fa_transaction_headers th1,
        fa_transaction_headers th2
    where adj.transaction_header_id = th1.transaction_header_id
      and adj.asset_id = p_group_asset_id
      and adj.book_type_code = p_book_type_code
      and adj.period_counter_adjusted = p_period_counter
      and th1.asset_id = adj.asset_id
      and th1.member_transaction_header_id = th2.transaction_header_id
      and th2.transaction_type_code = 'ADJUSTMENT'
      and th2.transaction_key in ('UA','UE')
      and adj_mem.transaction_header_id(+) = th2.transaction_header_id
      and adj_mem.period_counter_adjusted(+) = p_period_counter
      and adj_mem.asset_id(+) = th2.asset_id
      and nvl(adj_mem.track_member_flag(+),'N') = 'N'
      and adj.set_of_books_id = p_set_of_books_id
      and adj_mem.set_of_books_id(+) = p_set_of_books_id
   group by th2.asset_id;

   type t_tbl_unpln_exp is TABLE of C_FA_ADJ_UNPLANNED%rowtype index by binary_integer;
   l_tbl_unpln_exp t_tbl_unpln_exp;
   l_calling_fn   varchar2(50) := 'FA_TRACK_MEMBER_PVT.POPULATE_UNPLANNED_EXP';
begin

   if p_mrc_sob_type_code <> 'R' then
         open C_FA_ADJ_UNPLANNED;
         fetch C_FA_ADJ_UNPLANNED bulk collect into l_tbl_unpln_exp;
         close C_FA_ADJ_UNPLANNED;
   else
         open C_FA_ADJ_UNPLANNED_MRC;
         fetch C_FA_ADJ_UNPLANNED_MRC bulk collect into l_tbl_unpln_exp;
         close C_FA_ADJ_UNPLANNED_MRC;
   end if;

   for i in 1..l_tbl_unpln_exp.COUNT
   loop
      for j in 1..p_track_member_table.count
      loop
         if p_track_member_table(j).group_asset_id = P_group_asset_id and
             p_track_member_table(j).period_counter = P_period_counter and
             p_track_member_table(j).member_asset_id = l_tbl_unpln_exp(i).member_asset_id and
             nvl(p_track_member_table(j).set_of_books_id, -99) = nvl(p_set_of_books_id, -99) then
             if  nvl(p_track_member_table(j).fully_reserved_flag,'N') <> 'Y' then
                 p_track_member_table(j).unplanned_deprn_amount := nvl(l_tbl_unpln_exp(i).grp_unpln_exp,0) +
                                                    nvl(l_tbl_unpln_exp(i).mem_unpln_exp,0);
             end if;
             EXIT;
         end if;
      end loop;
   end loop;
   return (TRUE);
exception
  when others then
    fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;
end populate_unplanned_exp;

  function search_index_table(p_period_counter IN number,
                      p_member_asset_id IN number,
                      p_group_asset_id IN number,
                      p_sob_id IN number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
  return number is
    l_calling_fn   varchar2(50) := 'FA_TRACK_MEMBER_PVT.SEARCH_INDEX_TABLE';
    l_index_key varchar2(152);
    main_err    exception;
  Begin
    l_index_key := lpad(p_period_counter,38,'0')||lpad(p_member_asset_id,38,'0')||lpad(p_group_asset_id,38,'0')||lpad(nvl(p_sob_id,-99),38,'0');
    if (p_track_mem_index_table.exists(l_index_key)) then
      return p_track_mem_index_table(l_index_key);
    else
       return -1;
    end if;
  Exception
    when others then
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise main_err;
  end search_index_table;

  procedure put_track_index(p_period_counter IN number,
                          p_member_asset_id IN number,
                          p_group_asset_id IN number,
                          p_sob_id IN number,
                          p_index_value IN number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
    l_calling_fn   varchar2(50) := 'FA_TRACK_MEMBER_PVT.PUT_TRACK_INDEX';
    l_index_key varchar2(152);
    main_err    exception;
  begin
    l_index_key := lpad(p_period_counter,38,'0')||lpad(p_member_asset_id,38,'0')||lpad(p_group_asset_id,38,'0')||lpad(nvl(p_sob_id,-99),38,'0');
    p_track_mem_index_table(l_index_key) := p_index_value;
  Exception
    when others then
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise main_err;
  end put_track_index;


  procedure delete_track_index(p_period_counter IN number,
                          p_member_asset_id IN number,
                          p_group_asset_id IN number,
                          p_sob_id IN number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
    l_calling_fn   varchar2(50) := 'FA_TRACK_MEMBER_PVT.DELETE_TRACK_INDEX';
    l_index_key varchar2(152);
    main_err    exception;
  begin
    l_index_key := lpad(p_period_counter,38,'0')||lpad(p_member_asset_id,38,'0')||lpad(p_group_asset_id,38,'0')||lpad(nvl(p_sob_id,-99),38,'0');
    if (p_track_mem_index_table.exists(l_index_key)) then
      p_track_mem_index_table.delete(l_index_key);
    end if;
  Exception
    when others then
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise main_err;
  end;


END FA_TRACK_MEMBER_PVT;

/
