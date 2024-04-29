--------------------------------------------------------
--  DDL for Package Body FA_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_EXP_PKG" as
/* $Header: FAEXADJB.pls 120.9.12010000.3 2009/07/24 15:40:25 deemitta ship $ */

Function faxbds
        (
        X_fin_info_ptr in out nocopy fa_std_types.fin_info_struct
        ,X_dpr_ptr out nocopy fa_std_types.dpr_struct
        ,X_dist_book out nocopy varchar2
        ,X_deprn_rsv out nocopy number
        ,X_amortized_flag boolean
        ,X_mrc_sob_type_code varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is
rate_source_rule        varchar2(40);
rate_calendar           varchar2(48);
fy_name                 varchar2(45);
calendar_type           varchar2(48);
period_num              integer;
start_jdate             integer;
prorate_jdate           integer;
deprn_start_jdate       integer;
jdate_in_svc            integer;
use_jdate               integer;
prorate_fy              integer;
deprn_period            integer;
deprn_fy                integer;
pers_per_yr             integer;
last_per_ctr            integer;
cur_fy                  integer;
cur_per_num             integer;
deprn_summary           fa_std_types.fa_deprn_row_struct;
h_dummy_int             integer;
h_dummy_bool            boolean;
h_dummy_varch           varchar2(16);
begin <<FAXBDS>>

if not fa_cache_pkg.fazccmt
        (X_fin_info_ptr.method_code,
        X_fin_info_ptr.life, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;

rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;


X_dpr_ptr.adj_cost := X_fin_info_ptr.adj_cost;
X_dpr_ptr.rec_cost := X_fin_info_ptr.rec_cost;
X_dpr_ptr.reval_amo_basis := X_fin_info_ptr.reval_amo_basis;
X_dpr_ptr.adj_rate := X_fin_info_ptr.adj_rate;
X_dpr_ptr.capacity := X_fin_info_ptr.capacity;
X_dpr_ptr.adj_capacity := X_fin_info_ptr.adj_capacity;
X_dpr_ptr.adj_rec_cost := X_fin_info_ptr.adj_rec_cost;
X_dpr_ptr.salvage_value := X_fin_info_ptr.salvage_value;

if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('faxbds','faamrt1 2nd user exit new adj cost',
                X_fin_info_ptr.adj_rec_cost, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add('faxbds','faamrt1 3rd user exit salvage_value',
                X_fin_info_ptr.salvage_value, p_log_level_rec => p_log_level_rec);
end if;

X_dpr_ptr.deprn_rounding_flag := X_fin_info_ptr.deprn_rounding_flag;

X_dpr_ptr.ceil_name := X_fin_info_ptr.ceiling_name;
X_dpr_ptr.bonus_rule := X_fin_info_ptr.bonus_rule;
X_dpr_ptr.life := X_fin_info_ptr.life;
X_dpr_ptr.method_code := X_fin_info_ptr.method_code;
X_dpr_ptr.asset_num := X_fin_info_ptr.asset_number;

if (X_amortized_flag) then
        X_dpr_ptr.rate_adj_factor := 1;
else
        X_dpr_ptr.rate_adj_factor := X_fin_info_ptr.rate_adj_factor;
end if;

--  Bug 424489. When invoice lines are transferred between assets
--  immediately after running deprn then the destination asset has incorrect
--  DEPRN EXPENSE in fa_adjustments table. It happens when this is the
--  first adjustment in the period. It is suspected to be a caching problem
--  -hence we have an extra select statement as below here. This problem
--  is similar to bug 415719.
--
--  this is fixes with new caching mechanisms
--  reinstating the cache  - BMR
--
--  note there is no need to call the cache again here as it would already be loaded
--

last_per_ctr := fa_cache_pkg.fazcbc_record.last_period_counter;
cur_fy := fa_cache_pkg.fazcbc_record.current_fiscal_year;
cur_per_num := mod((last_per_ctr+1),cur_fy);
X_dpr_ptr.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
rate_calendar := fa_cache_pkg.fazcbc_record.prorate_calendar;
X_dist_book := fa_cache_pkg.fazcbc_record.distribution_source_book;

prorate_jdate := to_number(to_char(X_fin_info_ptr.prorate_date, 'J'));
deprn_start_jdate := to_number(to_char(X_fin_info_ptr.deprn_start_date, 'J'));
jdate_in_svc := to_number(to_char(X_fin_info_ptr.date_placed_in_svc, 'J'));

fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;

if not fa_cache_pkg.fazccp (
        rate_calendar, fy_name, prorate_jdate,
        period_num, prorate_fy, start_jdate
        , p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;

if (rate_source_rule = fa_std_types.FAD_RSR_CALC) or
   (rate_source_rule = fa_std_types.FAD_RSR_FORMULA) then
        use_jdate := prorate_jdate;
else
        use_jdate := deprn_start_jdate;
end if;

if not fa_cache_pkg.fazccp (
        calendar_type, fy_name, use_jdate,
        deprn_period, deprn_fy, start_jdate
        , p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;

if not fa_cache_pkg.fazcct (calendar_type, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;
pers_per_yr := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

X_dpr_ptr.prorate_jdate := prorate_jdate;
X_dpr_ptr.deprn_start_jdate := deprn_start_jdate;
X_dpr_ptr.jdate_retired := 0;
X_dpr_ptr.ret_prorate_jdate := 0;
X_dpr_ptr.jdate_in_service := jdate_in_svc;
X_fin_info_ptr.jdate_in_svc := jdate_in_svc;
X_dpr_ptr.asset_id := X_fin_info_ptr.asset_id;
X_dpr_ptr.book := X_fin_info_ptr.book;
deprn_summary.asset_id := X_fin_info_ptr.asset_id;
deprn_summary.book := X_fin_info_ptr.book;
deprn_summary.period_ctr := 0;
deprn_summary.dist_id := 0;
deprn_summary.mrc_sob_type_code := X_mrc_sob_type_code;

FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
        deprn_summary,
        'STANDARD',
        FALSE,
        h_dummy_bool,
        'fa_exp_pkg.faxbds',
        -1, p_log_level_rec => p_log_level_rec);

if not (h_dummy_bool) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;

if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('faxbds','after call to fauqadd: prior_fy_exp',
                deprn_summary.prior_fy_exp, p_log_level_rec => p_log_level_rec);
end if;

-- Send in 0 value in faxcde for deprn_rsv
X_deprn_rsv := deprn_summary.deprn_rsv;
X_dpr_ptr.reval_rsv := deprn_summary.reval_rsv;
-- bonus: bonus_deprn_rsv exists in dpr_struct.
X_dpr_ptr.bonus_deprn_rsv := deprn_summary.bonus_deprn_rsv;

--
-- Copy prior_fy_exp from deprn_row_struct to deprn_struct.
--
X_dpr_ptr.prior_fy_exp := deprn_summary.prior_fy_exp;
X_dpr_ptr.ytd_deprn := deprn_summary.ytd_deprn;
-- bonus: necessary? both variables below exist in struct.
X_dpr_ptr.bonus_ytd_deprn := deprn_summary.bonus_ytd_deprn;

--
-- Pass zero ltd_prod into faxcde(), just like
-- we do for deprn_rsv
--
X_dpr_ptr.ltd_prod := 0;

X_dpr_ptr.y_begin := prorate_fy;
if (cur_per_num = 1) then
        X_dpr_ptr.y_end := cur_fy - 1;
else
        X_dpr_ptr.y_end := cur_fy;
end if;

X_dpr_ptr.p_cl_begin := 1;
if (cur_per_num = 1) then
        X_dpr_ptr.p_cl_end := pers_per_yr;
else
        X_dpr_ptr.p_cl_end := cur_per_num - 1;
end if;

X_dpr_ptr.deprn_rsv := 0;
X_dpr_ptr.rsv_known_flag := TRUE;

-- Adding the following for short tax years and formula based

X_dpr_ptr.short_fiscal_year_flag := X_fin_info_ptr.short_fiscal_year_flag;
X_dpr_ptr.conversion_date := X_fin_info_ptr.conversion_date;
X_dpr_ptr.prorate_date := X_fin_info_ptr.prorate_date;
X_dpr_ptr.orig_deprn_start_date := X_fin_info_ptr.orig_deprn_start_date;
X_dpr_ptr.formula_factor := NVL(X_fin_info_ptr.formula_factor,1); -- bug2692127

return(TRUE);

exception
        when others then
                fa_srvr_msg.add_sql_error (calling_fn => 'fa_exp_pkg.faxbds',  p_log_level_rec => p_log_level_rec);
                return (FALSE);
end FAXBDS;



Function faxexp
        (
        X_fin_info_ptr in out nocopy fa_std_types.fin_info_struct
        ,X_new_adj_cost out nocopy number
        ,X_ccid integer
        ,X_sysdate_val date
        ,X_last_updated_by number
        ,X_last_update_login number
        ,X_ins_adj_flag boolean
        ,X_mrc_sob_type_code varchar2
        ,X_deprn_exp out nocopy number
        ,X_bonus_deprn_exp out nocopy number
        ,X_new_formula_factor in out nocopy number
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is
dist_book varchar2(16);
cur_deprn_rsv number;
cur_bonus_deprn_rsv number;
h_deprn_exp number;
h_bonus_deprn_exp number;
rate_source_rule varchar2(40);
deprn_basis_rule varchar(40);
afn_zero number;
dpr fa_std_types.dpr_struct;
dpr_out fa_std_types.dpr_out_struct;
dpr_asset_num varchar2(16);
dpr_calendar_type varchar2(16);
dpr_ceil_name varchar2(31);
h_dummy_dpr_arr fa_std_types.dpr_arr_type;
h_dummy_int integer;
h_dummy_bool boolean;

-- NOTE: Fixed to bug#1583869 - hsugimot
-- This solve the problem that you do expensed adjustment
-- when the depreciation flag of the asset is off.

h_new_deprn_rsv number;
h_new_prior_fy_exp number;
h_new_adj_cost number;

-- Fixed to bug#1762518 - hsugimot
cur_fy                  integer;
cur_per_num             integer;

-- Added for Depreciable Basis Formula
 h_rule_in              FA_STD_TYPES.fa_deprn_rule_in_struct;
 h_rule_out             FA_STD_TYPES.fa_deprn_rule_out_struct;

-- override for what if
running_mode             number;

begin <<FAXEXP>>

-- bonus: function is also called from FAAMRT1B.pls, FATXRSVB.pls
--
if not faxbds(X_fin_info_ptr, dpr, dist_book,cur_deprn_rsv, FALSE, X_mrc_sob_type_code, p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;

--
-- Don't calculate expense for CIP/EXPENSED assets
--

 X_fin_info_ptr.deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;

/*+++++++++++++++++++++++++++++++++++++++++++++++
 + Bug 1952858                                  +
 + Need to check if the asset cost = 0 and the  +
 + depreciate_flag = 'N'. This way we could     +
 + recalculate the expense after the user       +
 + adjusts the cost to 0.                       +
 +++++++++++++++++++++++++++++++++++++++++++++++*/

if (X_fin_info_ptr.asset_type = 'CAPITALIZED' ) then
  if (X_fin_info_ptr.dep_flag)  OR
        (X_fin_info_ptr.Cost = 0 and NOT(X_fin_info_ptr.dep_flag) ) then
        --
        -- Call faxcde to get the recalculated expense
        --
-- bonus: here is a solution for bringing cur_bonus_deprn_rsv
--        it may get necessary to add a new parameter to faxbds call,
--        and handle bonus deprn rsv simular as deprn rsv.
        cur_bonus_deprn_rsv := dpr.bonus_deprn_rsv;
        dpr.bonus_deprn_rsv := 0;

        -- Manual Override
        dpr.used_by_adjustment := TRUE;
        dpr.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
        if X_fin_info_ptr.running_mode = fa_std_types.FA_DPR_PROJECT then
           running_mode:= fa_std_types.FA_DPR_PROJECT;
        else
           running_mode:= fa_std_types.FA_DPR_NORMAL;
        end if;
        dpr.mrc_sob_type_code := x_mrc_sob_type_code;
        /*bug 8725642 overriding SOB*/
        dpr.set_of_books_id := X_fin_info_ptr.set_of_books_id;
        -- End of Manual Override

        if not fa_cde_pkg.faxcde (dpr, h_dummy_dpr_arr, dpr_out,
                running_mode, p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
                return (FALSE);
        end if;

        --
        -- Insert the difference into the FA_ADJUSTMENTS table
        --
        h_deprn_exp := dpr_out.new_deprn_rsv - cur_deprn_rsv;
-- bonus: new_bonus_deprn_rsv added to dpr_out_struct.
-- Investigate dpr.bonus_deprn_rsv if value is correct.==> YES!
-- Now new_bonus_deprn_rsv needs to be correctly calculated in faxcde.
        if nvl(X_fin_info_ptr.bonus_rule, 'NONE') <> 'NONE' then
                h_bonus_deprn_exp := dpr_out.new_bonus_deprn_rsv - cur_bonus_deprn_rsv;
        else
                h_bonus_deprn_exp := 0;
        end if;

    --Manual Override
    if (p_log_level_rec.statement_level)
    then
      fa_debug_pkg.add (
       fname => 'faxexp',
       element=>'deprn_override_flag',
       value=>dpr_out.deprn_override_flag, p_log_level_rec => p_log_level_rec);
    end if;
    -- pass override_flag to faxiat
    X_fin_info_ptr.deprn_override_flag:= dpr_out.deprn_override_flag;

    -- End of manual override

 else
        h_deprn_exp := 0;
        h_bonus_deprn_exp := 0;

 end if;
end if;

/*
          NOTE

      This is incorrect; the annualized adjustment for this should not
      be zero.  The correct way to calculate this would be to
      recalculate deprn under the old conditions, and determine what the
      annualized deprn amount is for the current fiscal year.  Then
      compare that with the recalculation of deprn under the new
      conditions.  The difference is the annualized adjustment amount.
      In order to calculate this, we would need a snapshot of the asset
      before the transaction.  Since this requires a significant change
      to the fin_info_struct structure, we will defer the fix until a
      later release.  The impact of this is that if the user executes an
      expensed change, and then a prior-period transfer or retirement
      whose effective date is before the current date, the depreciation
      expense transferred will not include any amount relevant to the
      expensed change.  -Dave
*/
afn_zero := 0;

if X_ins_adj_flag then
        if not fa_amort_pkg.faxiat (
                X_fin_ptr => X_fin_info_ptr
                ,X_deprn_exp => h_deprn_exp
                ,X_bonus_deprn_exp => h_bonus_deprn_exp
                ,X_ann_adj_amt => afn_zero
                ,X_ccid => X_ccid
                ,X_last_update_date => X_sysdate_val
                ,X_last_updated_by => X_last_updated_by
                ,X_last_update_login => X_last_update_login
                ,X_mrc_sob_type_code => X_mrc_sob_type_code
                , p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
                return (FALSE);
        end if;
end if;

if not fa_cache_pkg.fazccmt (
        X_fin_info_ptr.method_code,
        X_fin_info_ptr.life, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
end if;

rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;


--  Added for the Depreciable Basis Formula.
cur_fy := fa_cache_pkg.fazcbc_record.current_fiscal_year;
cur_per_num := mod(X_fin_info_ptr.period_ctr,cur_fy);

if (fa_cache_pkg.fa_enabled_deprn_basis_formula) then
   -- Depreciable Basis Formula
   -- set h_rule_in paremters

   h_rule_in.asset_id := X_fin_info_ptr.asset_id;
   h_rule_in.group_asset_id := null;
   h_rule_in.book_type_code := X_fin_info_ptr.book;
   h_rule_in.asset_type := X_fin_info_ptr.asset_type;

   if X_fin_info_ptr.dep_flag then
        h_rule_in.depreciate_flag := 'YES';
   else
        h_rule_in.depreciate_flag := 'NO';
   end if;

   h_rule_in.method_code := x_fin_info_ptr.method_code;
   h_rule_in.life_in_months := x_fin_info_ptr.life;
   h_rule_in.method_id := null;
   h_rule_in.method_type := rate_source_rule;
   h_rule_in.calc_basis := deprn_basis_rule;
   h_rule_in.adjustment_amount := 0;
   h_rule_in.transaction_flag := null;
   h_rule_in.cost := x_fin_info_ptr.cost;
   h_rule_in.salvage_value := X_fin_info_ptr.salvage_value;
   h_rule_in.recoverable_cost := dpr.rec_cost;
   h_rule_in.adjusted_cost := X_fin_info_ptr.adj_cost;
   h_rule_in.current_total_rsv := cur_deprn_rsv;
   h_rule_in.current_rsv := 0;
   h_rule_in.current_total_ytd := dpr.ytd_deprn;
   h_rule_in.current_ytd := 0;
   h_rule_in.hyp_basis := dpr_out.new_adj_cost;
   h_rule_in.hyp_total_rsv :=dpr_out.new_deprn_rsv;
   h_rule_in.hyp_rsv :=dpr_out.new_deprn_rsv
                                - dpr_out.new_bonus_deprn_rsv;
   if (cur_per_num = 1) then
        h_rule_in.hyp_total_ytd :=0;
   else
-- change implemented due to problem found when STRICT_FLAT adjustments
-- new
        h_rule_in.hyp_total_ytd :=
                dpr_out.new_deprn_rsv - (dpr_out.new_prior_fy_exp - dpr.prior_fy_exp);

-- old
--      h_rule_in.hyp_total_ytd :=
--              dpr_out.new_deprn_rsv - dpr_out.new_prior_fy_exp;
   end if;

   h_rule_in.hyp_ytd :=0;
   h_rule_in.old_adjusted_cost := 0;
   h_rule_in.old_total_adjusted_cost := 0;
   h_rule_in.old_raf := X_fin_info_ptr.rate_adj_factor;
   h_rule_in.old_formula_factor := X_fin_info_ptr.formula_factor;
   h_rule_in.old_reduction_amount := 0;

   h_rule_in.event_type := 'EXP_ADJ';

   --  Call Depreciable Basis Formula

   If (not FA_CALC_DEPRN_BASIS1_PKG.faxcdb (
                                            h_rule_in,
                                            h_rule_out, p_log_level_rec => p_log_level_rec))
   then
        fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
        return false;
   end if;

   -- set rule_out parameters
   X_new_adj_cost := h_rule_out.new_adjusted_cost;
   X_new_formula_factor := h_rule_out.new_formula_factor;

else -- Not Use Depreciable Basis Formula

   -- NOTE: Fixed to bug#1583869 - hsugimot
   -- This solve the problem that you do expensed adjustment
   --  when the depreciation flag of the asset is off.

     /*+++++++++++++++++++++++++++++++++++++++++++++++
     + Bug 1952858                                  +
     + Need to check if the asset cost = 0 and the  +
     + depreciate_flag = 'N'. This way we could     +
     + recalculate the expense after the user       +
     + adjusts the cost to 0.                       +
     +++++++++++++++++++++++++++++++++++++++++++++++*/

     if (X_fin_info_ptr.asset_type = 'CAPITALIZED' ) then
        if (X_fin_info_ptr.dep_flag)  OR
          (X_fin_info_ptr.Adj_cost = 0 and NOT(X_fin_info_ptr.dep_flag) ) then

           -- Fixed to bug#1762518 - hsugimot

--              cur_fy := fa_cache_pkg.fazcbc_record.current_fiscal_year;
--              cur_per_num := mod(X_fin_info_ptr.period_ctr,cur_fy);

           if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add('faxexp','X_fin_info_ptr.period_ctr',
                        X_fin_info_ptr.period_ctr, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('faxexp','cur_per_num',
                        cur_per_num, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('faxexp','dpr_out.new_deprn_rsv',
                        dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('faxexp','dpr_out.new_prior_fy_exp',
                        dpr_out.new_prior_fy_exp, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('faxexp','dpr_out.new_adj_cost',
                        dpr_out.new_adj_cost, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('faxexp','X_fin_info_ptr.period_ctr',
                        X_fin_info_ptr.period_ctr, p_log_level_rec => p_log_level_rec);
           end if;

           h_new_deprn_rsv := dpr_out.new_deprn_rsv;

           --   h_new_prior_fy_exp := dpr_out.new_prior_fy_exp;
           if (cur_per_num = 1) then
              h_new_prior_fy_exp := h_new_deprn_rsv;
           else
-- if/else/endif below implemented due to STRICT_FLAT adjustments
-- new_prior_fy_exp is returning value from faxcde that is
-- a summary of new calculated (correct) value and old backdated
-- value stored in fa_deprn_summary.
              if (deprn_basis_rule = fa_std_types.FAD_DBR_NBV) then
                 h_new_prior_fy_exp := dpr_out.new_prior_fy_exp -
                                          dpr.prior_fy_exp;
                 if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add('faxexp','dpr.prior_fy_exp',
                               dpr.prior_fy_exp, p_log_level_rec => p_log_level_rec);
                 end if;
              else
                 h_new_prior_fy_exp := dpr_out.new_prior_fy_exp;
              end if;
-- original line.
--      ******h_new_prior_fy_exp := dpr_out.new_prior_fy_exp;
--
           end if;

           h_new_adj_cost := dpr_out.new_adj_cost;
         else

           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('faxexp','cur_deprn_rsv',
                               cur_deprn_rsv, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add('faxexp','dpr.ytd_deprn',
                               dpr.ytd_deprn, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add('faxexp','dpr.rec_cost',
                               dpr.rec_cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add('faxexp','deprn_basis_rule',
                               deprn_basis_rule, p_log_level_rec => p_log_level_rec);
           end if;

           h_new_deprn_rsv := cur_deprn_rsv;
           h_new_prior_fy_exp := cur_deprn_rsv - dpr.ytd_deprn;

           if (deprn_basis_rule = fa_std_types.FAD_DBR_NBV) then
              h_new_adj_cost := dpr.rec_cost - h_new_prior_fy_exp;

           else -- COST basis
                h_new_adj_cost := dpr.rec_cost;
           end if;

        end if;
     end if;


     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('faxexp','h_new_deprn_rsv',
                h_new_deprn_rsv, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add('faxexp','h_new_prior_fy_exp',
                h_new_prior_fy_exp, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add('faxexp','h_new_adj_cost',
                h_new_adj_cost, p_log_level_rec => p_log_level_rec);
     end if;


-- Calculate new adjusted cost differently for Diminishing-Value assets
-- with cost changes; use the new Net Book Value, in this case, as
-- opposed to the Net Book Value at the beginning of the current fiscal
-- year

-- X_new_formula_factor is set for FORMULA-NBV assets.
-- X_new_formula_factor is 1 in all other cases

     if (deprn_basis_rule = fa_std_types.FAD_DBR_NBV and
         X_fin_info_ptr.asset_type = 'CAPITALIZED') then
        if (rate_source_rule <> fa_std_types.FAD_RSR_FORMULA) then
           -- NOTE: Fixed to bug#1583869 - hsugimot
           -- X_new_adj_cost := dpr.rec_cost - dpr_out.new_deprn_rsv;
            X_new_adj_cost := dpr.rec_cost - h_new_deprn_rsv;
            X_new_formula_factor := 1;
        else
            -- NOTE: Fixed to bug#1583869 - hsugimot
            -- X_new_formula_factor := dpr_out.new_adj_cost /
            --                            X_fin_info_ptr.rec_cost;
            X_new_formula_factor := h_new_adj_cost /
                                        X_fin_info_ptr.rec_cost;
            X_new_adj_cost := X_fin_info_ptr.adj_cost;
        end if;
      else
        X_new_adj_cost := X_fin_info_ptr.adj_cost;
        X_new_formula_factor := 1;
     end if;


-- alternative calculation of  flat depreciation adjustment.
-- added for 11.5.2

-- added CAPITALIZED condition for bugfix 2508385
     if (X_fin_info_ptr.asset_type = 'CAPITALIZED' ) then

     -- NOTE: Fixed to bug#1583869
     -- Change parameter from dpr_out.new_prior_fy_exp to h_new_prior_fy_exp
        if (not fa_amort_pkg.faxnac(X_fin_info_ptr.method_code,
                                 X_fin_info_ptr.life,
                                 dpr.rec_cost,
                                 h_new_prior_fy_exp,
                                 null, null,
                                 X_new_adj_cost, p_log_level_rec => p_log_level_rec)) then
          fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
          return (FALSE);
        end if;
     end if;
end if;   -- End NOT USE Depreciable Basis Formula

X_deprn_exp := h_deprn_exp;
-- bonus: Needed for whatif.
X_bonus_deprn_exp := h_bonus_deprn_exp;

return(TRUE);

exception
        when others then
                fa_srvr_msg.add_sql_error (calling_fn => 'fa_exp_pkg.faxexp',  p_log_level_rec => p_log_level_rec);
                return (FALSE);
end FAXEXP;


END FA_EXP_PKG;

/
