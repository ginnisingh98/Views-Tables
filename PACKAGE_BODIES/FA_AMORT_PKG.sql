--------------------------------------------------------
--  DDL for Package Body FA_AMORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_AMORT_PKG" as
/* $Header: FAAMRT1B.pls 120.11.12010000.3 2009/07/31 10:29:27 deemitta ship $ */

adj_ptr_faxiat		FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

FUNCTION faxiat (X_fin_ptr   FA_STD_TYPES.fin_info_struct,
		 X_deprn_exp  number,
		 X_bonus_deprn_exp number,
		 X_ann_adj_amt  number,
		 X_ccid	   number,
		 X_last_update_date date default sysdate,
		 X_last_updated_by number default -1,
		 X_last_update_login number default -1,
                 X_mrc_sob_type_code varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean
is
h_book_type_code	fa_book_controls.book_type_code%type;
h_category_id  		fa_category_books.category_id%type;
h_cost_source		varchar2(30);
h_cost_acct_type	varchar2(30);
h_clearing_acct_type 	varchar2(30);
h_cost_acct       	varchar2(30);
h_clearing_acct   	varchar2(30);
h_expense_acct_type	varchar2(30);
h_expense_acct		varchar2(30);
h_expense_source	varchar2(30);
BEGIN  <<faxiat>>
h_book_type_code:=X_fin_ptr.book;
h_category_id:=X_fin_ptr.category_id;
 if (p_log_level_rec.statement_level)
 then
    FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxiat',
		 element=>'X_last_update_date',
		  value=>X_last_update_date, p_log_level_rec => p_log_level_rec);
 end if;
adj_ptr_faxiat.transaction_header_id := X_fin_ptr.transaction_id;
adj_ptr_faxiat.asset_invoice_id := 0;
adj_ptr_faxiat.asset_id := X_fin_ptr.asset_id;
adj_ptr_faxiat.book_type_code := h_book_type_code;
adj_ptr_faxiat.period_counter_created
		:= X_fin_ptr.period_ctr;
adj_ptr_faxiat.period_counter_adjusted
		:= X_fin_ptr.period_ctr;
adj_ptr_faxiat.current_units := X_fin_ptr.units;
adj_ptr_faxiat.selection_mode
		:= FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
adj_ptr_faxiat.selection_thid := 0;
adj_ptr_faxiat.selection_retid := 0;
adj_ptr_faxiat.flush_adj_flag := FALSE;
adj_ptr_faxiat.gen_ccid_flag := TRUE;
adj_ptr_faxiat.code_combination_id := 0;
adj_ptr_faxiat.distribution_id := 0;
adj_ptr_faxiat.last_update_date := X_last_update_date;
adj_ptr_faxiat.leveling_flag := TRUE;

-- override
 adj_ptr_faxiat.deprn_override_flag := '';

 if not fa_cache_pkg.fazccb(h_book_type_code,
 			    h_category_id, p_log_level_rec => p_log_level_rec)
 then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
 end if;

 if (X_fin_ptr.asset_type = 'CIP')
 then
    h_cost_source := 'CIP ADJUSTMENT';
    h_cost_acct_type := 'CIP_COST_ACCT';
    h_clearing_acct_type := 'CIP_CLEARING_ACCT';
    h_cost_acct := FA_CACHE_PKG.fazccb_record.cip_cost_acct;
    h_clearing_acct := FA_CACHE_PKG.fazccb_record.cip_clearing_acct;
 else
    h_cost_source := 'ADJUSTMENT';
    h_cost_acct_type := 'ASSET_COST_ACCT';
    h_clearing_acct_type := 'ASSET_CLEARING_ACCT';
    h_cost_acct := FA_CACHE_PKG.fazccb_record.asset_cost_acct;
    h_clearing_acct:=FA_CACHE_PKG.fazccb_record.asset_clearing_acct;
 end if;
 adj_ptr_faxiat.annualized_adjustment:=0;
 adj_ptr_faxiat.source_type_code := h_cost_source;
 adj_ptr_faxiat.adjustment_amount
	:= X_fin_ptr.cost - X_fin_ptr.old_cost;
  if (adj_ptr_faxiat.adjustment_amount) <>0
  then
     adj_ptr_faxiat.adjustment_type:='COST';
   if (adj_ptr_faxiat.adjustment_amount) > 0
   then
     adj_ptr_faxiat.debit_credit_flag :='DR';
   else
     adj_ptr_faxiat.adjustment_amount
	:= (-1) * adj_ptr_faxiat.adjustment_amount;
     adj_ptr_faxiat.debit_credit_flag :='CR';
   end if;
   adj_ptr_faxiat.account:=h_cost_acct;
   adj_ptr_faxiat.account_type:=h_cost_acct_type;
   adj_ptr_faxiat.mrc_sob_type_code := X_mrc_sob_type_code;

   --if (p_log_level_rec.statement_level)
   --then
      FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxiat',
		 element=>'Adjustment Amount.. before faxinaj',
		  value=>adj_ptr_faxiat.adjustment_amount, p_log_level_rec => p_log_level_rec);
   --end if;
   if (not FA_INS_ADJUST_PKG.faxinaj(adj_ptr_faxiat,
		                     X_last_update_date=>X_last_update_date,
		    		     X_last_updated_by=>X_last_updated_by,
		    		     X_last_update_login=>X_last_update_login, p_log_level_rec => p_log_level_rec))
   then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
   end if;
   if (p_log_level_rec.statement_level)
   then
      FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxiat',
		 element=>'Amount Inserted',
		  value=>adj_ptr_faxiat.amount_inserted, p_log_level_rec => p_log_level_rec);
   end if;

   adj_ptr_faxiat.adjustment_type:='COST CLEARING';
   if (adj_ptr_faxiat.debit_credit_flag='DR')
   then
      adj_ptr_faxiat.debit_credit_flag :='CR';
   else
       adj_ptr_faxiat.debit_credit_flag :='DR';
   end if;
   adj_ptr_faxiat.account:=h_clearing_acct;
   adj_ptr_faxiat.account_type:=h_clearing_acct_type;
   adj_ptr_faxiat.mrc_sob_type_code := X_mrc_sob_type_code;

   if (X_ccid<>0)
   then
     adj_ptr_faxiat.code_combination_id := X_ccid;
     adj_ptr_faxiat.gen_ccid_flag :=FALSE;
   end if;
      FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxiat',
		 element=>'Adjustment Amount.. before faxinaj CCLEARI',
		  value=>adj_ptr_faxiat.adjustment_amount, p_log_level_rec => p_log_level_rec);

   if (not FA_INS_ADJUST_PKG.faxinaj(adj_ptr_faxiat,
		    		     X_last_update_date=>X_last_update_date,
		    		     X_last_updated_by=>X_last_updated_by,
		    		     X_last_update_login=>X_last_update_login, p_log_level_rec => p_log_level_rec))
   then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
   end if;

   if (X_ccid<>0)
   then
     adj_ptr_faxiat.code_combination_id := 0;
     adj_ptr_faxiat.gen_ccid_flag :=TRUE;
   end if;
 end if;   /* adjustment_amount<>0  */

 h_expense_acct_type := 'DEPRN_EXPENSE_ACCT';
 h_expense_acct := FA_CACHE_PKG.fazccb_record.deprn_expense_acct;
 h_expense_source:='DEPRECIATION';
 adj_ptr_faxiat.source_type_code:=h_expense_source;
 adj_ptr_faxiat.adjustment_type:='EXPENSE';
 adj_ptr_faxiat.debit_credit_flag:='DR';
 adj_ptr_faxiat.account:=h_expense_acct;
 adj_ptr_faxiat.account_type:=h_expense_acct_type;
 adj_ptr_faxiat.flush_adj_flag:=TRUE;
 adj_ptr_faxiat.adjustment_amount:=X_deprn_exp;
 adj_ptr_faxiat.annualized_adjustment:=X_ann_adj_amt;
 adj_ptr_faxiat.mrc_sob_type_code := X_mrc_sob_type_code;

/* manual override  */

if X_fin_ptr.deprn_override_flag in (fa_std_types.FA_OVERRIDE_DPR,
                                     fa_std_types.FA_OVERRIDE_BONUS,
                                     fa_std_types.FA_OVERRIDE_DPR_BONUS) then
   adj_ptr_faxiat.deprn_override_flag := 'Y';
else
   adj_ptr_faxiat.deprn_override_flag := '';
end if;
/* End of Manual override */

   if (p_log_level_rec.statement_level)
   then
      FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxiat',
		 element=>'Adj-AMOUNT-BEFORE DEPRN_EXPENSE',
		  value=>adj_ptr_faxiat.adjustment_amount, p_log_level_rec => p_log_level_rec);
   end if;
  if (adj_ptr_faxiat.adjustment_amount<>0)
  then
    if (not FA_INS_ADJUST_PKG.faxinaj(adj_ptr_faxiat,
		    		      X_last_update_date=>X_last_update_date,
		    		      X_last_updated_by=>X_last_updated_by,
		    		      X_last_update_login=>X_last_update_login, p_log_level_rec => p_log_level_rec))
    then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
    end if;
  else
    adj_ptr_faxiat.transaction_header_id:=0;
    if (not FA_INS_ADJUST_PKG.faxinaj(adj_ptr_faxiat,
		    		      X_last_update_date=>X_last_update_date,
		    		      X_last_updated_by=>X_last_updated_by,
		    		      X_last_update_login=>X_last_update_login, p_log_level_rec => p_log_level_rec))
    then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
    end if;
  end if;



-- bonus.  Verfied that this gets inserted.
--         Now need to calculate
-- always DR, if reduced cost adjustment, negative adjustment_amount.
-- IF statement evaluates if there is any bonus expense to insert into fa_adjustments.
if nvl(X_bonus_deprn_exp,0) <> 0 then

 h_expense_acct_type := 'BONUS_DEPRN_EXPENSE_ACCT';
-- account could be derived from somewhere else, derive from account generat.
 h_expense_acct := FA_CACHE_PKG.fazccb_record.bonus_deprn_expense_acct;
 h_expense_source:='DEPRECIATION';
 adj_ptr_faxiat.source_type_code:=h_expense_source;
 adj_ptr_faxiat.adjustment_type:='BONUS EXPENSE';
 adj_ptr_faxiat.debit_credit_flag:='DR';
 adj_ptr_faxiat.account:=h_expense_acct;
 adj_ptr_faxiat.account_type:=h_expense_acct_type;
 adj_ptr_faxiat.flush_adj_flag:=TRUE;

-- override
 if X_fin_ptr.deprn_override_flag in (
                               fa_std_types.FA_OVERRIDE_BONUS,
                               fa_std_types.FA_OVERRIDE_DPR_BONUS) then
    adj_ptr_faxiat.deprn_override_flag := 'Y';
 else
    adj_ptr_faxiat.deprn_override_flag := '';
 end if;

-- bonus
 adj_ptr_faxiat.adjustment_amount:=X_bonus_deprn_exp;
 adj_ptr_faxiat.annualized_adjustment:=X_ann_adj_amt;
 adj_ptr_faxiat.mrc_sob_type_code := X_mrc_sob_type_code;

   if (p_log_level_rec.statement_level)
   then
      FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxiat',
		 element=>'Adj-AMOUNT-BEFORE BONUS DEPRN_EXPENSE',
		  value=>adj_ptr_faxiat.adjustment_amount, p_log_level_rec => p_log_level_rec);
   end if;
  if (adj_ptr_faxiat.adjustment_amount<>0)
  then
    if (not FA_INS_ADJUST_PKG.faxinaj(adj_ptr_faxiat,
		    		      X_last_update_date=>X_last_update_date,
		    		      X_last_updated_by=>X_last_updated_by,
		    		      X_last_update_login=>X_last_update_login, p_log_level_rec => p_log_level_rec))
    then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
    end if;
  else
    adj_ptr_faxiat.transaction_header_id:=0;
    if (not FA_INS_ADJUST_PKG.faxinaj(adj_ptr_faxiat,
		    		      X_last_update_date=>X_last_update_date,
		    		      X_last_updated_by=>X_last_updated_by,
		    		      X_last_update_login=>X_last_update_login, p_log_level_rec => p_log_level_rec))
    then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxiat', p_log_level_rec => p_log_level_rec);
     return  FALSE;
    end if;
  end if;

end if;



   if (p_log_level_rec.statement_level)
   then
      FA_DEBUG_PKG.ADD(fname	=>'FA_AMORT_PKG.faxiat',
		       element	=>'Amount Inserted',
		       value	=>adj_ptr_faxiat.amount_inserted, p_log_level_rec => p_log_level_rec);
   end if;
  return TRUE;
 exception
  when others then
     FA_SRVR_MSG.ADD_SQL_ERROR (
		CALLING_FN => 'FA_AMORT_PKG.faxiat',  p_log_level_rec => p_log_level_rec);
     return  FALSE;
 END faxiat;

FUNCTION faxraf(X_fin_info_ptr          in out nocopy FA_STD_TYPES.fin_info_struct,
                 X_new_raf              in out nocopy number,
                 X_new_adj_cost         in out nocopy number,
                 X_new_adj_capacity     in out nocopy number,
                 X_new_reval_amo_basis  in out nocopy number,
                 X_new_salvage_value    in out nocopy number,
                 X_reval_deprn_rsv_adj  in out nocopy number,
		 X_new_formula_factor	in out nocopy number,
		 X_bonus_deprn_exp	in out nocopy number,
                 X_mrc_sob_type_code    in     varchar2,
                 X_set_of_books_id      in     number,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

return boolean is
 h_dpr_row	FA_STD_TYPES.dpr_struct;
 h_dpr_out	FA_STD_TYPES.dpr_out_struct;
 h_dpr_arr	FA_STD_TYPES.dpr_arr_type;
 h_add_txn_id   number;
 h_deprn_basis_rule	varchar2(25);
 h_rate_source_rule     varchar2(25);
 h_excl_salvage_val_flag boolean;
 h_deprn_last_year_flag  boolean;
 h_method_id		 integer;
 h_dist_book		varchar2(30);
 h_current_rsv		number;
 h_deprn_rsv            number;
 h_current_ytd          number;
 h_temp			number;
 h_user_id		number;
 h_login_id		number;
 h_err_string		varchar2(500);
 d_new_raf		number;
 d_new_adj_cost		number;
 d_new_reval_amo_basis  number;
 d_current_rsv		number;
 d_reval_deprn_rsv_adj  number;
 d_rec_cost		number;
 d_new_deprn_rsv	number;
-- Added for Dated Adjustment
 fy_name                varchar2(45);
 amortize_per_num       integer;
 amortize_fy            integer;
 start_jdate            integer;
 pers_per_yr            integer;
 amortization_start_jdate integer;
 cur_fy                 integer;
 cur_per_num            integer;
 last_per_ctr           integer;
 amortize_per_ctr       integer;
 adjustment_amount      number;
 h_rsv_amount           number;
 deprn_summary          fa_std_types.fa_deprn_row_struct;
 h_dummy_bool           boolean;--Used to call QUERY_BALANCES_INT
-- End  Added for Dated Adjustment
 temp_deprn_rsv		number;  -- reserve at the beginning of fy
-- Added for bonus rule
 h_bonus_rule 		FA_BONUS_RULES.Bonus_Rule%TYPE;
 h_bonus_deprn_rsv      number;
-- not used.
--  h_deprn_total_rsv 	number;
 h_current_total_rsv 	number;

/**** Enhancement for BT. YYOON - Start */
check_flag  varchar2(3);

/* Manual Override */
use_override boolean;
running_mode     number;
used_by_revaluation number;

-- Added for Depreciable Basis Formula
 h_rule_in		FA_STD_TYPES.fa_deprn_rule_in_struct;
 h_rule_out		FA_STD_TYPES.fa_deprn_rule_out_struct;

 l_ind binary_integer;

cursor check_period_of_addition is
select 'Y' -- 'Y' if the current period of the asset is period of addition.
from dual
where exists
(select 1 from fa_transaction_headers
where transaction_type_code = 'ADDITION'
and transaction_header_id = X_fin_info_ptr.transaction_id);
-- Bug4560593: Commenting out
-- where not exists
-- (select 'x'
--  from fa_deprn_summary
--  where asset_id = X_fin_info_ptr.asset_id
--    and book_type_code = X_fin_info_ptr.book
--    and deprn_amount <> 0
--    and deprn_source_code = 'DEPRN'
-- );

/* Enhancement for BT. YYOON - End */


-- multiple backdate amortization enhancement - begin LSON
cursor amort_date_before_add is
select th.transaction_header_id
from  fa_transaction_headers th, fa_deprn_periods dp
where th.book_type_code = X_fin_info_ptr.book
and   th.asset_id = X_fin_info_ptr.asset_id
and   th.transaction_type_code = 'ADDITION'
and   th.book_type_code = dp.book_type_code
and   th.date_effective between dp.period_open_date and
          nvl(dp.period_close_date,sysdate)
and   X_fin_info_ptr.amortization_start_date < dp.calendar_period_open_date;

--  multiple backdate amortization enhancement - end LSON

   --
   -- This is to check whether the backdated transaction
   -- is dated in the same fy as fy of addition.
   -- This is to determine whether BOOKS row of FA_DEPRN_SUMMARY
   -- can be used or not
   --
   cursor c_check_fiscal_year (c_thid number) is
   select 1
   from   fa_transaction_headers th
        , fa_deprn_periods dp
        , fa_fiscal_year fy
        , fa_calendar_periods cp
   where  th.transaction_header_id = c_thid
   and    th.date_effective between dp.period_open_date and
             nvl(dp.period_close_date,sysdate)
   and    dp.book_type_code = X_fin_info_ptr.book
   and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
   and    cp.start_date =  fy.start_date
   and    cp.period_num = 1
   and    cp.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
   and    dp.calendar_period_open_date between fy.start_date and fy.end_date
   and    X_fin_info_ptr.amortization_start_date between fy.start_date and fy.end_date;

   --
   -- Following two cursorss are to get eofy_reserve
   --
   cursor c_get_reserve is
   select deprn_reserve - ytd_deprn
        , bonus_deprn_reserve - bonus_ytd_deprn
   from   fa_deprn_summary
   where  book_type_code = X_fin_info_ptr.book
   and    asset_id = X_fin_info_ptr.asset_id
   and    deprn_source_code = 'BOOKS';

   cursor c_get_mc_reserve is
   select deprn_reserve - ytd_deprn
        , bonus_deprn_reserve - bonus_ytd_deprn
   from   fa_mc_deprn_summary
   where  book_type_code = X_fin_info_ptr.book
   and    asset_id = X_fin_info_ptr.asset_id
   and    deprn_source_code = 'BOOKS'
   and    set_of_books_id = X_set_of_books_id;

   l_same_fy   NUMBER;

 begin  <<faxraf>>

  -- override
  if X_fin_info_ptr.running_mode = fa_std_types.FA_DPR_PROJECT then
     running_mode:= fa_std_types.FA_DPR_PROJECT;
  else
     running_mode:= fa_std_types.FA_DPR_NORMAL;
  end if;
  -- End of Manual Override

 if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'method code',
                value=>X_fin_info_ptr.method_code, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'life',
                value=>X_fin_info_ptr.life, p_log_level_rec => p_log_level_rec);
    end if;

 if (not FA_CACHE_PKG.fazccmt(X_fin_info_ptr.method_code,
		 X_fin_info_ptr.life, p_log_level_rec => p_log_level_rec))
 then
       FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxraf', p_log_level_rec => p_log_level_rec);
	return FALSE;
 end if;

 h_method_id             := fa_cache_pkg.fazccmt_record.method_id;
 h_rate_source_rule      := fa_cache_pkg.fazccmt_record.rate_source_rule;
 h_deprn_basis_rule      := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

 if fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag = 'YES' then
    h_excl_salvage_val_flag := TRUE;
 else
    h_excl_salvage_val_flag := FALSE;
 end if;

 if fa_cache_pkg.fazccmt_record.depreciate_lastyear_flag = 'YES' then
    h_deprn_last_year_flag := TRUE;
 else
    h_deprn_last_year_flag := FALSE;
 end if;

    if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'After fazccmt',
                value=>2, p_log_level_rec => p_log_level_rec);
    end if;

 h_err_string := 'FA_AMT_BD_DPR_STRUCT';

 if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'deprn_rounding_flag- before faxbds',
                value=>X_fin_info_ptr.deprn_rounding_flag, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'FA_STD TYPE deprn_rnd- before faxbds',
                value=>FA_STD_TYPES.FA_DPR_ROUND_ADJ, p_log_level_rec => p_log_level_rec);
    end if;

/*
 if (not FA_EXP_PKG.faxbds(fin_info_ptr=>X_fin_info_ptr,
	 		   dpr_ptr=>h_dpr_row,
			   dist_book=>h_dist_book,
			   deprn_rsv=>h_current_rsv,
			   amortized_flag=>TRUE, p_log_level_rec => p_log_level_rec))
 then
*/
    if (not fa_exp_pkg.faxbds(X_fin_info_ptr,
			      h_dpr_row,
			      h_dist_book,
			      h_current_rsv,
			      TRUE,
                              X_mrc_sob_type_code, p_log_level_rec => p_log_level_rec))
    then
        FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxraf',
		NAME=>'FA_AMT_BD_DPR_STRUCT', p_log_level_rec => p_log_level_rec);
	return FALSE;
 end if;
 h_current_rsv := h_current_rsv + X_reval_deprn_rsv_adj;
 h_current_ytd:= h_dpr_row.ytd_deprn;


 -- override
 h_dpr_row.used_by_adjustment := TRUE;
 h_dpr_row.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
 -- End of override

 h_err_string := 'FA_AMT_CAL_DP_EXP';
    if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'Before faxcde',
                value=>3, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'h_dpr_row.deprn_rounding_flag ',
                value=>h_dpr_row.deprn_rounding_flag, p_log_level_rec => p_log_level_rec);
    end if;

-- Added for Dated Adjustment
 if (X_fin_info_ptr.amortization_start_date is not null) then
    -- removed fazcbc cache call as it should already be loaded - BMR
    last_per_ctr := fa_cache_pkg.fazcbc_record.last_period_counter;
    cur_fy := fa_cache_pkg.fazcbc_record.current_fiscal_year;
    cur_per_num := mod((last_per_ctr+1),cur_fy);
    amortization_start_jdate := to_number(to_char(X_fin_info_ptr.amortization_start_date, 'J'));
    fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
    if not fa_cache_pkg.fazccp (
        h_dpr_row.calendar_type, fy_name,amortization_start_jdate,
        amortize_per_num, amortize_fy, start_jdate
        , p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
    end if;
    if (not((cur_fy = amortize_fy) and (cur_per_num = amortize_per_num))) then
        if not fa_cache_pkg.fazcct (h_dpr_row.calendar_type, p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf', p_log_level_rec => p_log_level_rec);
            return (FALSE);
        end if;
        pers_per_yr := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
        if (amortize_per_num = 1) then
            h_dpr_row.y_end := amortize_fy - 1;
        else
            h_dpr_row.y_end := amortize_fy;
        end if;
        if (amortize_per_num = 1) then
            h_dpr_row.p_cl_end := pers_per_yr;
        else
            h_dpr_row.p_cl_end := amortize_per_num - 1;
        end if;
    end if; --if (not((cur_fy = amortize_fy) and (cur_per_num = amortize_per_num)))

 end if; --if (X_fin_info_ptr.amortization_start_date is not null)
-- End Added for Dated Adjustment


-- bonus: We need to exclude bonus amounts when calculating raf.
--  proved that bonus_rule is excluded, if exist for asset.
 h_bonus_rule := h_dpr_row.bonus_rule;
 h_dpr_row.bonus_rule := '';
-- row below may not be needed.
--  h_bonus_deprn_rsv := h_dpr_row.bonus_deprn_rsv;
-- h_dpr_row.deprn_rsv is not used.
--  h_deprn_total_rsv := h_dpr_row.deprn_rsv;
--  h_dpr_row.deprn_rsv := h_dpr_row.deprn_rsv - h_dpr_row.bonus_deprn_rsv;
 h_current_total_rsv := h_current_rsv;
 h_current_rsv := h_current_rsv - nvl(h_dpr_row.bonus_deprn_rsv,0);

 used_by_revaluation:= 0;
 if X_fin_info_ptr.used_by_revaluation = 1 then
    used_by_revaluation:= 1;
 end if;

 use_override := ((h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FORMULA) or
           (((h_rate_source_rule = FA_STD_TYPES.FAD_RSR_CALC) or
             (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_TABLE)) and
            (h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_COST)) or
             used_by_revaluation = 1);

    if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf',
                 element=>'Before call to faxcde regular case',
                 value=>h_dpr_row.bonus_rule, p_log_level_rec => p_log_level_rec);
      end if;

 h_dpr_row.mrc_sob_type_code := X_mrc_sob_type_code;
 /*Bug 8742062 Manually overridding the value of SOB ID*/
 h_dpr_row.set_of_books_id := X_set_of_books_id;
 if (not FA_CDE_PKG.faxcde(h_dpr_row,
			   h_dpr_arr,
			   h_dpr_out,
			   running_mode,
                           l_ind,
                           p_log_level_rec)) and (use_override)
 then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxraf',
		   NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
    if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'After faxcde 1st time',
                value=>'False', p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'h_dpr_out.rate_adj_factor',
                value=>h_dpr_row.rate_adj_factor, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'h_dpr_out.adj_capacity',
                value=>h_dpr_row.adj_capacity, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'h_dpr_out.capacity',
                value=>h_dpr_row.capacity, p_log_level_rec => p_log_level_rec);
    end if;
	return FALSE;
 end if;

    -- Override
    fa_std_types.deprn_override_trigger_enabled:= FALSE;
    if use_override then  -- pass deprn_override_flag to faxiat
       X_fin_info_ptr.deprn_override_flag:= h_dpr_out.deprn_override_flag;
       if (p_log_level_rec.statement_level) then
           FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf',
                            element=>'deprn_override_flag1',
                            value=>h_dpr_out.deprn_override_flag, p_log_level_rec => p_log_level_rec);
       end if;
    else
       -- pass fa_no_override to faxiat
       X_fin_info_ptr.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
       -- update the status fa_deprn_override from 'SELECTED' to 'POST'
          UPDATE FA_DEPRN_OVERRIDE
          SET status = 'POST'
          WHERE
              used_by = 'ADJUSTMENT' and
              status = 'SELECTED' and
              transaction_header_id is null;
    end if;
    fa_std_types.deprn_override_trigger_enabled:= TRUE;
    -- End of Manual Override


   --   In most cases, New Adjusted_Cost = New Net Book Value;
   --   New Rate_Adjustment_Factor =
   --             New Net Book Value / New Deprn_Reserve
   --   New Reval_Amortization_Basis = (dpr) Reval_Reserve

-- bonus between here and next, include bonus amounts.


-- bonus: modified according to decision from domain experts:
--        now using Cost - Total Reserve
--        when calculating adjusted_cost for nbv assets and
-- 	  Cost - Regular Reserve (without bonus deprn res) for cost assets

   --   Add the calling Depreciable Basis Formula.
   --if (nvl(fnd_profile.value('FA_ENABLED_DEPRN_BASIS_FORMULA'), 'N') = 'Y') then
   if (fa_cache_pkg.fa_enabled_deprn_basis_formula)then
     -- new_raval_amo_basis and Production rate source rule are
     -- not calculated on Depreciable Basis Formula

     X_new_reval_amo_basis := h_dpr_row.reval_rsv;
     if (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_PROD)
     then
        X_new_raf :=1;
        X_new_adj_capacity := X_fin_info_ptr.capacity - h_dpr_out.new_ltd_prod;
        X_new_formula_factor := 1;
     end if;

     -- Depreciable Basis Formula
     -- set h_rule_in paremters

     h_rule_in.asset_id := X_fin_info_ptr.asset_id;
     h_rule_in.group_asset_id := null;
     h_rule_in.book_type_code := X_fin_info_ptr.book;
     h_rule_in.asset_type := X_fin_info_ptr.asset_type;
     h_rule_in.depreciate_flag := null;
     h_rule_in.method_code := X_fin_info_ptr.method_code;
     h_rule_in.life_in_months := X_fin_info_ptr.life;
     h_rule_in.method_id := null;
     h_rule_in.method_type := h_rate_source_rule;
     h_rule_in.calc_basis := h_deprn_basis_rule;
     h_rule_in.adjustment_amount := X_fin_info_ptr.cost
					- X_fin_info_ptr.old_cost;
     h_rule_in.transaction_flag := null;
     h_rule_in.cost := X_fin_info_ptr.cost;
     h_rule_in.salvage_value := X_new_salvage_value;
     h_rule_in.recoverable_cost := X_fin_info_ptr.rec_cost;
     h_rule_in.adjusted_cost := 0;
     h_rule_in.current_total_rsv := h_current_total_rsv;
     h_rule_in.current_rsv := h_current_rsv;
     h_rule_in.current_total_ytd := h_current_ytd;
     h_rule_in.current_ytd := 0;
     h_rule_in.hyp_basis := h_dpr_out.new_adj_cost;
     h_rule_in.hyp_total_rsv := h_dpr_out.new_deprn_rsv;
     h_rule_in.hyp_rsv := h_dpr_out.new_deprn_rsv
				- h_dpr_out.new_bonus_deprn_rsv;
     h_rule_in.hyp_total_ytd := 0;
     h_rule_in.hyp_ytd := 0;
     h_rule_in.old_adjusted_cost := X_fin_info_ptr.adj_cost;
     h_rule_in.old_total_adjusted_cost := X_fin_info_ptr.adj_cost;
     h_rule_in.old_raf := X_fin_info_ptr.rate_adj_factor;
     h_rule_in.old_formula_factor := X_fin_info_ptr.formula_factor;
     h_rule_in.old_reduction_amount := 0;

     h_rule_in.event_type := 'AMORT_ADJ';

     -- Call Depreciable Basis Formula
     if (p_log_level_rec.statement_level) then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'Before Calling fa_calc_deprn_basis1_pkg.faxcdb',
                value=> h_rule_in.event_type, p_log_level_rec => p_log_level_rec);
     end if;

     if (not FA_CALC_DEPRN_BASIS1_PKG.faxcdb(
				 h_rule_in,
				 h_rule_out,
				 X_fin_info_ptr.amortization_start_date, p_log_level_rec => p_log_level_rec))
     then
  	FA_SRVR_MSG.ADD_MESSAGE
        	(CALLING_FN=>'FA_AMORT_PKG.faxraf',
           	NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
   	return false;
     end if;

     -- set rule_out parameters
     X_new_adj_cost := h_rule_out.new_adjusted_cost;
     X_new_raf := h_rule_out.new_raf;
     X_new_formula_factor := h_rule_out.new_formula_factor;

   else -- Not use Depreciable Basis Formula


      if (h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_COST)   then
	 X_new_adj_cost := X_fin_info_ptr.rec_cost - h_current_rsv;
       else  -- implies NBV
	 X_new_adj_cost := X_fin_info_ptr.rec_cost - h_current_total_rsv;
      end if;

      -- end cost/nbv change
      /* THE SIGN OF THE ADJUSTED COST SHOULD NEVER BE DIFFERENT */
      /* THAN THE SIGN OF THE RECOVERABLE COST.  IF THE ABOVE    */
      /* SUBTRACTION CAUSED THIS, SET THE ADJUSTED COST TO 0.    */
      /* FIX FOR PRODUCTION ASSETS THAT ARE COST ADJUSTED TO LESS*/
      /* THAN THE CURRENT RESERVE.                               */

      /* X_new_formula_factor is set for FORMULA-NBV assets.
      X_new_formula_factor is 1 in all other cases */

      if (p_log_level_rec.statement_level)
	then
           FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'adj cost',
			      value=> x_new_adj_cost, p_log_level_rec => p_log_level_rec);
       end if;

       if (sign(X_fin_info_ptr.rec_cost)<>sign(X_new_adj_cost))
	  then
	   X_new_adj_cost := 0;
       end if;

	if (sign(X_fin_info_ptr.rec_cost)<>0)
	  then
	   h_temp := X_fin_info_ptr.rec_cost - h_dpr_out.new_deprn_rsv;
	   X_new_raf := h_temp / X_fin_info_ptr.rec_cost;
	   if (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FORMULA AND
	       h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_NBV) then

	      X_new_formula_factor :=  h_dpr_out.new_adj_cost /
		X_fin_info_ptr.rec_cost;
	    else
	      X_new_formula_factor := 1;
	   end if;
	 else
	   -- rec_cost == 0 ... Can't divide by it, so use RAF=1
           -- (value doesn't really matter in this case)
	     X_new_raf :=1;
	   X_new_formula_factor := 1;
	end if;

	X_new_reval_amo_basis := h_dpr_row.reval_rsv;

	--  If life-based NBV-based, then RAF = 1
	--  If Flat-Rate Cost-Based, then RAF = 1, AC = Rec_Cost
	--  If Flat-Rate NBV-Based, RAF = old RAF (should be 1)
	--  If Production, then RAF = 1, Adj_Capacity = (Capacity-LTD_Prod)
	--  Otherwise, RAF = (Rec_Cost - New_Deprn_Rsv) / Rec_Cost (as above)

	  if ((h_rate_source_rule = FA_STD_TYPES.FAD_RSR_CALC)
	      OR (h_rate_source_rule=FA_STD_TYPES.FAD_RSR_TABLE))
	  then
	     if (h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_NBV)
	       then
		X_new_raf :=1;
		X_new_formula_factor := 1;
	     end if;
	  end if;

	  if (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT)
	    then
	     if (h_deprn_basis_rule=FA_STD_TYPES.FAD_DBR_COST)
	       then
		X_new_raf := 1;
		X_new_adj_cost := X_fin_info_ptr.rec_cost;
		X_new_formula_factor := 1;
	      else
		X_new_raf := X_fin_info_ptr.rate_adj_factor;
		X_new_formula_factor := 1;
	     end if;
	   elsif (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_PROD)
	     then
	     X_new_raf :=1;
	     X_new_adj_capacity := X_fin_info_ptr.capacity - h_dpr_out.new_ltd_prod;
	     X_new_formula_factor := 1;
	  end if;
      if (p_log_level_rec.statement_level)
	then
           FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'adj cost at end of not use deprn bas',
			      value=> x_new_adj_cost, p_log_level_rec => p_log_level_rec);
       end if;

   END IF; -- End Not Use Depreciable Basis Formula

-- bonus: assigning bonus rule value back.
 h_dpr_row.bonus_rule := h_bonus_rule;
-- not yet needed.
--  h_deprn_row.bonus_deprn_rsv := h_bonus_deprn_rsv;
--  h_dpr_row.deprn_rsv is not used.
--  h_dpr_row.deprn_rsv :=  h_deprn_total_rsv;
 h_current_rsv := h_current_total_rsv;

-- alternative flat rate depreciation caclulation
-- call faxnac: new added function.
      if (p_log_level_rec.statement_level)
	then
           FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'bef. faxnac adj cost',
			      value=> x_new_adj_cost, p_log_level_rec => p_log_level_rec);
       end if;


   -- Add for the Depreciable Basis Formula.
   -- if (nvl(fnd_profile.value('FA_ENABLED_DEPRN_BASIS_FORMULA'), 'N') <> 'Y') then
   if (not fa_cache_pkg.fa_enabled_deprn_basis_formula)then

      if (not FA_AMORT_PKG.faxnac(X_fin_info_ptr.method_code,
				  X_fin_info_ptr.life,
				  X_fin_info_ptr.rec_cost,
				  null,
				  h_current_rsv,
				  h_current_ytd,
				  X_new_adj_cost, p_log_level_rec => p_log_level_rec))
	then
	 FA_SRVR_MSG.ADD_MESSAGE
	   (CALLING_FN=>'FA_AMORT_PKG.faxraf',
	    NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
	 return false;
      end if;
   END IF;
      if (p_log_level_rec.statement_level)
	then
           FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'aft.faxnac adj cost',
			      value=> x_new_adj_cost, p_log_level_rec => p_log_level_rec);
       end if;

   -- End Not Depreciable Basis Formula

   if (p_log_level_rec.statement_level)
   then
     d_new_raf := X_new_raf;
     d_new_adj_cost := X_new_adj_cost;
     d_new_reval_amo_basis := X_new_reval_amo_basis;
     d_current_rsv := h_current_rsv;
     d_reval_deprn_rsv_adj := X_reval_deprn_rsv_adj;
     d_rec_cost := X_fin_info_ptr.rec_cost;
     d_new_deprn_rsv := h_dpr_out.new_deprn_rsv;
  end if;
  if (X_new_raf < 0 OR X_new_raf > 1)
  then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxraf',
		   NAME=>'FA_AMT_RAF_OUT_OF_RANGE', p_log_level_rec => p_log_level_rec);
     return FALSE;
  end if;
-- Added for Dated Adjustment
 X_fin_info_ptr.adj_amount := 0;

 fa_rx_conc_mesg_pkg.log('x_new_raf A: ' || to_char(x_new_raf));

 if (X_fin_info_ptr.amortization_start_date is not null) then
   fa_rx_conc_mesg_pkg.log('x_new_raf B: ' || to_char(x_new_raf));
    if (not((cur_fy = amortize_fy) and (cur_per_num = amortize_per_num))) then

        h_dpr_row.y_begin :=  amortize_fy;
        h_dpr_row.p_cl_begin := amortize_per_num;
        if (cur_per_num = 1) then
            h_dpr_row.y_end := cur_fy - 1;
        else
            h_dpr_row.y_end := cur_fy;
        end if;
        if (cur_per_num = 1) then
            h_dpr_row.p_cl_end := pers_per_yr;
        else
            h_dpr_row.p_cl_end := cur_per_num - 1;
        end if;
        h_dpr_row.rate_adj_factor := X_new_raf;

--
        if (cur_fy = amortize_fy) then
            amortize_per_ctr := (last_per_ctr + 1) -
                                (cur_per_num - amortize_per_num);
        else
            amortize_per_ctr := (last_per_ctr + 1) -
                                (
			        (cur_fy - amortize_fy -1) * pers_per_yr +
                                (pers_per_yr - amortize_per_num + cur_per_num)
			        );
        end if;--if (cur_fy = amortize_fy)
        deprn_summary.asset_id := X_fin_info_ptr.asset_id;
        deprn_summary.book := X_fin_info_ptr.book;
        deprn_summary.period_ctr := amortize_per_ctr - 1;
        deprn_summary.dist_id := 0;
        deprn_summary.mrc_sob_type_code := X_mrc_sob_type_code;

 /**** Commented out for BT Enhancement. YYOON ******
        FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
                deprn_summary,
                'STANDARD',
                FALSE,
                h_dummy_bool,
                'FA_AMORT_PKG.faxraf',
                -1, p_log_level_rec => p_log_level_rec);
******************************************************/

/**** Enhancement for BT. YYOON - Start
BUG#1148053: Ability to add assets with reserve
and amortize over remaining useful life */

        OPEN check_period_of_addition;
        FETCH check_period_of_addition INTO check_flag;


        if (check_period_of_addition%FOUND) then

          CLOSE check_period_of_addition;
-- bonus added.

          FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
                deprn_summary,
                'STANDARD',
                FALSE,
                h_dummy_bool,
                'FA_AMORT_PKG.faxraf',
                -1, p_log_level_rec => p_log_level_rec);

  --          if x_mrc_sob_type_code = 'R' then
  --             select deprn_reserve, bonus_deprn_reserve, ytd_deprn
  --             into deprn_summary.deprn_rsv, deprn_summary.bonus_deprn_rsv,
  --                  deprn_summary.ytd_deprn
  --             from fa_deprn_summary_mrc_v
  --             where asset_id = X_fin_info_ptr.asset_id
  --             and book_type_code = X_fin_info_ptr.book
  --             and deprn_source_code = 'BOOKS';
  --          else
  --             select deprn_reserve, bonus_deprn_reserve, ytd_deprn
  --             into deprn_summary.deprn_rsv, deprn_summary.bonus_deprn_rsv,
  --                  deprn_summary.ytd_deprn
  --             from fa_deprn_summary
  --             where asset_id = X_fin_info_ptr.asset_id
  --             and book_type_code = X_fin_info_ptr.book
  --             and deprn_source_code = 'BOOKS';
  --          end if;

        else

          CLOSE check_period_of_addition;

--  backdate amortization enhancement - begin
          h_add_txn_id := 0;
          if x_fin_info_ptr.amortization_start_date is not null then
              open amort_date_before_add;
              fetch amort_date_before_add
              into h_add_txn_id;
              close amort_date_before_add;

-- when amortization start date is before the addition date
-- call get_reserve to get the actual reserve from the prorate period to before the
-- amortization period
              if (h_add_txn_id > 0) then

                  --
                  -- Bug3281141:
                  -- Get reserve from FA_DEPRN_SUMMARY.  User RSV - YTD of BOOKS row
                  -- if this is backdated to the beginning of fy and addition was
                  -- performed in the same fy.
                  --
                  open c_check_fiscal_year (h_add_txn_id);
                  fetch c_check_fiscal_year into l_same_fy;
                  if (c_check_fiscal_year%FOUND) then

                     close c_check_fiscal_year;

                     if (X_mrc_sob_type_code = 'R') then
                        open c_get_mc_reserve;
                        fetch c_get_mc_reserve into deprn_summary.deprn_rsv,
                                                    deprn_summary.bonus_deprn_rsv;
                        close c_get_mc_reserve;
                     else
                        open c_get_reserve;
                        fetch c_get_reserve into deprn_summary.deprn_rsv,
                                                 deprn_summary.bonus_deprn_rsv;
                        close c_get_reserve;
                     end if;
                     if (fa_cache_pkg.fa_print_debug) then
                        fa_debug_pkg.add('FA_AMORT_PKG.faxraf',
                                         'Got reserve using BOOKS row', 'reserve - ytd', p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add('FA_AMORT_PKG.faxraf',
                                         'deprn_summary.deprn_rsv:deprn_summary.bonus_deprn_rsv',
                                    to_char(deprn_summary.deprn_rsv)||':'||
                                         to_char(deprn_summary.bonus_deprn_rsv));
                     end if;
                  else

                     close c_check_fiscal_year;

                     if not (get_reserve(X_fin_info_ptr,h_add_txn_id,amortize_fy,
                                      amortize_per_num, pers_per_yr,
                                      x_mrc_sob_type_code,
                                      x_set_of_books_id,
                                      h_deprn_rsv,
                                      h_bonus_deprn_rsv,
                                      p_log_level_rec)) then
                        fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf', p_log_level_rec => p_log_level_rec);
                        return FALSE;
                     end if;

                     deprn_summary.deprn_rsv := h_deprn_rsv;
                     deprn_summary.bonus_deprn_rsv := h_bonus_deprn_rsv;

                     if (fa_cache_pkg.fa_print_debug) then
                        fa_debug_pkg.add('FA_AMORT_PKG.faxraf',
                                         'Got reserve from get_reserve function', ' ', p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add('FA_AMORT_PKG.faxraf',
                                         'deprn_summary.deprn_rsv:deprn_summary.bonus_deprn_rsv',
                                    to_char(deprn_summary.deprn_rsv)||':'||
                                         to_char(deprn_summary.bonus_deprn_rsv));
                     end if;

                  end if; -- (c_check_fiscal_year%FOUND)
              end if;
          end if;

          if (x_fin_info_ptr.amortization_start_date is null or
              h_add_txn_id = 0) then
-- backdate amortization enhacement - end

              FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
                  deprn_summary,
                  'STANDARD',
                  FALSE,
                  h_dummy_bool,
                  'FA_AMORT_PKG.faxraf',
                  -1, p_log_level_rec => p_log_level_rec);

              if not (h_dummy_bool) then
                  fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.faxraf', p_log_level_rec => p_log_level_rec);
                  return (FALSE);
              end if;--if not (h_dummy_bool)
          end if;
        end if;
/**** Enhancement for BT. YYOON - End */

        if x_mrc_sob_type_code = 'R' then
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

           INTO adjustment_amount, h_rsv_amount
           FROM FA_MC_ADJUSTMENTS
           WHERE asset_id = X_fin_info_ptr.asset_id
           AND   book_type_code = X_fin_info_ptr.book
           AND   period_counter_adjusted = amortize_per_ctr
           AND   set_of_books_id = X_set_of_books_id;
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

           INTO adjustment_amount, h_rsv_amount
           FROM FA_ADJUSTMENTS
           WHERE asset_id = X_fin_info_ptr.asset_id
           AND   book_type_code = X_fin_info_ptr.book
           AND   period_counter_adjusted = amortize_per_ctr;
        end if;

        temp_deprn_rsv := deprn_summary.deprn_rsv - deprn_summary.bonus_deprn_rsv;


        if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'deprn_summary.deprn_rsv A',
                 value=>deprn_summary.deprn_rsv, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
             element=>'adjustment_amount A',
             value=>adjustment_amount, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
             element=>'deprn_summary.bonus_deprn_rsv A',
             value=>deprn_summary.bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'h_rsv_amount A',
                 value=> h_rsv_amount, p_log_level_rec => p_log_level_rec);
        end if;

-- bug 2510999
-- before
--      deprn_summary.deprn_rsv := deprn_summary.deprn_rsv +
--				   adjustment_amount -
--				   nvl(deprn_summary.bonus_deprn_rsv,0)
--                                   - h_rsv_amount;
-- after

        deprn_summary.deprn_rsv := deprn_summary.deprn_rsv +
				   adjustment_amount -
				   h_rsv_amount;


        if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'deprn_summary.deprn_rsv B',
                 value=>deprn_summary.deprn_rsv, p_log_level_rec => p_log_level_rec);
	end if;

-- alternative flat rate depreciation calculation
	if amortize_per_num=1 then
	   deprn_summary.ytd_deprn:= adjustment_amount;
	else
	   deprn_summary.ytd_deprn:= deprn_summary.ytd_deprn+adjustment_amount;
	end if;

 -- Add for the Depreciable Basis Formula.
 -- if (nvl(fnd_profile.value('FA_ENABLED_DEPRN_BASIS_FORMULA'), 'N') = 'Y') then

	if (fa_cache_pkg.fa_enabled_deprn_basis_formula) then
 fa_rx_conc_mesg_pkg.log('x_new_raf D: ' || to_char(x_new_raf));
   -- Depreciable Basis Formula
   -- set h_rule_in paremters

	   h_rule_in.asset_id := X_fin_info_ptr.asset_id;
	   h_rule_in.group_asset_id := null;
	   h_rule_in.book_type_code := X_fin_info_ptr.book;
	   h_rule_in.asset_type := X_fin_info_ptr.asset_type;
	   h_rule_in.depreciate_flag := null;
	   h_rule_in.method_code := X_fin_info_ptr.method_code;
	   h_rule_in.life_in_months := X_fin_info_ptr.life;
	   h_rule_in.method_id := null;
	   h_rule_in.method_type := h_rate_source_rule;
	   h_rule_in.calc_basis := h_deprn_basis_rule;
	   h_rule_in.adjustment_amount := X_fin_info_ptr.cost - X_fin_info_ptr.old_cost;
	   h_rule_in.transaction_flag := null;
	   h_rule_in.cost := X_fin_info_ptr.cost;
	   h_rule_in.salvage_value := X_new_salvage_value;
	   h_rule_in.recoverable_cost := X_fin_info_ptr.rec_cost;
	   h_rule_in.adjusted_cost := h_dpr_row.adj_cost;
	   h_rule_in.current_total_rsv := deprn_summary.deprn_rsv;
	   h_rule_in.current_rsv := deprn_summary.deprn_rsv
				- deprn_summary.bonus_deprn_rsv;
	   h_rule_in.current_total_ytd := deprn_summary.ytd_deprn;
	   h_rule_in.current_ytd := 0;
	   h_rule_in.hyp_basis := h_dpr_out.new_adj_cost;
	   h_rule_in.hyp_total_rsv := h_dpr_out.new_deprn_rsv;
	   h_rule_in.hyp_rsv := h_dpr_out.new_deprn_rsv - h_dpr_out.new_bonus_deprn_rsv;
	   h_rule_in.hyp_total_ytd := 0;
	   h_rule_in.hyp_ytd := 0;
	   h_rule_in.old_adjusted_cost := h_dpr_row.adj_cost;
	   h_rule_in.old_total_adjusted_cost := h_dpr_row.adj_cost;
	   h_rule_in.old_raf := x_new_raf;
	   h_rule_in.old_formula_factor := x_new_formula_factor;
	   h_rule_in.old_reduction_amount := 0;

	   h_rule_in.event_type := 'AMORT_ADJ2';

   -- Call Depreciable Basis Formula

   	 if (p_log_level_rec.statement_level) then
	       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
                element=>'Before Calling fa_calc_deprn_basis1_pkg.faxcdb',
                value=>h_rule_in.event_type, p_log_level_rec => p_log_level_rec);
	 end if;

	 if (not FA_CALC_DEPRN_BASIS1_PKG.faxcdb (
				h_rule_in,
				h_rule_out,
				X_fin_info_ptr.amortization_start_date, p_log_level_rec => p_log_level_rec))
	   then
  		FA_SRVR_MSG.ADD_MESSAGE
        		(CALLING_FN=>'FA_AMORT_PKG.faxraf',
	           	NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
   		return false;
	  end if;

   -- set rule_out parameters
	  h_dpr_row.adj_cost := h_rule_out.new_adjusted_cost;
	  X_new_raf := h_rule_out.new_raf;
	  X_new_formula_factor := h_rule_out.new_formula_factor;

   else -- Not Use Depreciable Basis Formula
 fa_rx_conc_mesg_pkg.log('x_new_raf E: ' || to_char(x_new_raf));
-- bug 2699656
	  if (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT)
	  and  (h_deprn_basis_rule=FA_STD_TYPES.FAD_DBR_COST)
	  then
		h_dpr_row.adj_cost := X_fin_info_ptr.rec_cost;
	  else

		h_dpr_row.adj_cost := X_fin_info_ptr.rec_cost - deprn_summary.deprn_rsv;
	  end if;

        if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'Before call to faxnac, adjusted_cost',
                 value=>h_dpr_row.adj_cost, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
             element=>'Before call to faxnac, x_fin_info_ptr.rec_cost',
             value=>x_fin_info_ptr.rec_cost, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
             element=>'Before call to faxnac, deprn_summary.deprn_rsv',
             value=>deprn_summary.deprn_rsv, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'Before call to faxnac, bonus_deprn_rsv',
                 value=> deprn_summary.bonus_deprn_rsv , p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'Before call to faxnac, h_rate_source_rule',
                 value=> h_rate_source_rule, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'Before call to faxnac, h_deprn_basis_rule',
                 value=> h_deprn_basis_rule, p_log_level_rec => p_log_level_rec);
        end if;


	if (not FA_AMORT_PKG.faxnac(X_fin_info_ptr.method_code,
				    X_fin_info_ptr.life,
				    X_fin_info_ptr.rec_cost,
				    null,
				    deprn_summary.deprn_rsv,
				    deprn_summary.ytd_deprn,
				    h_dpr_row.adj_cost, p_log_level_rec => p_log_level_rec))
	  then
	   FA_SRVR_MSG.ADD_MESSAGE
	     (CALLING_FN=>'FA_AMORT_PKG.faxraf',
	      NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
	   return false;
	end if;
 end if; -- End Not Use Depreciable Basis Formula

        --fix for 2197401. error out if new nbv result in
        -- opposite sign of new recoverable cost
        if (sign(X_fin_info_ptr.rec_cost)<>sign(h_dpr_row.adj_cost))
        then
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_AMORT_PKG.faxraf',
                       NAME=>'FA_WRONG_REC_COST', p_log_level_rec => p_log_level_rec);
            return FALSE;
        end if;

        h_dpr_row.deprn_rsv := deprn_summary.deprn_rsv;
        h_dpr_row.adj_capacity := X_new_adj_capacity;
-- Bonus: called when amortization_start_date is not null i.e. backdated
-- 	  adjustment.
-- keep the bonus rule value in h_bonus_rule due to amort..._start_date.
	 h_bonus_rule := h_dpr_row.bonus_rule;

--	 h_dpr_row.bonus_rule := '';

        if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'Before call to faxcde, amort_start_date case:bonus_rule',
                 value=>h_dpr_row.bonus_rule, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf ',
                 element=>'Before call to faxcde, adjusted_cost',
                 value=>h_dpr_row.adj_cost, p_log_level_rec => p_log_level_rec);
        end if;


	h_current_total_rsv := h_current_rsv;
	h_current_rsv := h_current_rsv - nvl(h_dpr_row.bonus_deprn_rsv,0);

		h_dpr_row.mrc_sob_type_code := X_mrc_sob_type_code;

        if (not FA_CDE_PKG.faxcde(h_dpr_row,
                           h_dpr_arr,
                           h_dpr_out,
                           running_mode, p_log_level_rec => p_log_level_rec))
        then
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_AMORT_PKG.faxraf',
                       NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
            return FALSE;
        end if;

      -- Override
        if (p_log_level_rec.statement_level) then
            FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.faxraf',
                 element=>'deprn_override_flag2',
                 value=>h_dpr_out.deprn_override_flag, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
		      element=>'h_dpr_out.new_bonus_deprn_rsv after faxcde',
		      value=>h_dpr_out.new_bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
		      element=>'h_dpr_out.new_bonus_deprn_rsv after faxcde',
		      value=>h_dpr_out.new_bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
		      element=>'h_dpr_out.new_deprn_rsv after faxcde',
		      value=>h_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
		      element=>'h_dpr_out.new_adj_cost after faxcde',
		      value=>h_dpr_out.new_adj_cost, p_log_level_rec => p_log_level_rec);

        end if;
        X_fin_info_ptr.deprn_override_flag:= h_dpr_out.deprn_override_flag;

      -- End of Manual Override
      -- Added for Depreciable Basis Formula.
      -- if (nvl(fnd_profile.value('FA_ENABLED_DEPRN_BASIS_FORMULA'), 'N') = 'Y') then


        if (fa_cache_pkg.fa_enabled_deprn_basis_formula) then

	 -- Depreciable Basis Formula
	 -- set h_rule_in paremters

	 h_rule_in.asset_id := X_fin_info_ptr.asset_id;
	 h_rule_in.group_asset_id := null;
	 h_rule_in.book_type_code := X_fin_info_ptr.book;
	 h_rule_in.asset_type := X_fin_info_ptr.asset_type;
	 h_rule_in.depreciate_flag := null;
	 h_rule_in.method_code := X_fin_info_ptr.method_code;
	 h_rule_in.life_in_months := X_fin_info_ptr.life;
	 h_rule_in.method_id := null;
	 h_rule_in.method_type := h_rate_source_rule;
	 h_rule_in.calc_basis := h_deprn_basis_rule;
	 h_rule_in.adjustment_amount := X_fin_info_ptr.cost
	                                   - X_fin_info_ptr.old_cost;
	 h_rule_in.transaction_flag := null;
	 h_rule_in.cost := X_fin_info_ptr.cost;
	 h_rule_in.salvage_value := X_new_salvage_value;
	 h_rule_in.recoverable_cost := X_fin_info_ptr.rec_cost;
	 h_rule_in.adjusted_cost := h_dpr_out.new_adj_cost;
	 h_rule_in.current_total_rsv := 0;
	 h_rule_in.current_rsv := temp_deprn_rsv;
	 h_rule_in.current_total_ytd := 0;
	 h_rule_in.current_ytd := 0;
	 h_rule_in.hyp_basis := h_dpr_out.new_adj_cost;
	 h_rule_in.hyp_total_rsv := h_dpr_out.new_deprn_rsv;
	 h_rule_in.hyp_rsv := h_dpr_out.new_deprn_rsv
	                        - h_dpr_out.new_bonus_deprn_rsv;
	 h_rule_in.hyp_total_ytd := 0;
	 h_rule_in.hyp_ytd := 0;
	 h_rule_in.old_adjusted_cost := x_new_adj_cost;
	 h_rule_in.old_total_adjusted_cost := x_new_adj_cost;
	 h_rule_in.old_raf := x_new_raf;
	 h_rule_in.old_formula_factor := x_new_formula_factor;
	 h_rule_in.old_reduction_amount := 0;

	 h_rule_in.event_type := 'AMORT_ADJ3';

	 -- Call Depreciable Basis Formula

	 if (p_log_level_rec.statement_level) then
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'Before Calling fa_calc_deprn_basis1_pkg.faxcdb',
			      value=>h_rule_in.event_type, p_log_level_rec => p_log_level_rec);
	 end if;

	 if (not FA_CALC_DEPRN_BASIS1_PKG.faxcdb (
						  h_rule_in,
						  h_rule_out,
						  X_fin_info_ptr.amortization_start_date, p_log_level_rec => p_log_level_rec))
	   then
	    FA_SRVR_MSG.ADD_MESSAGE
	      (CALLING_FN=>'FA_AMORT_PKG.faxraf',
	       NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
	    return false;
	 end if;

	 -- set rule_out parameters
	 X_new_adj_cost := h_rule_out.new_adjusted_cost;
	 X_new_raf := h_rule_out.new_raf;
	 X_new_formula_factor := h_rule_out.new_formula_factor;

        else  -- Do Not Use Depreciable Basis Formula

	 if (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FORMULA AND
	     h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_NBV) then

-- bug 2111490
-- temp_deprn_rsv is not containing bonus_deprn_rsv
	     X_new_adj_cost := X_fin_info_ptr.rec_cost -
				     temp_deprn_rsv -
				     nvl(deprn_summary.bonus_deprn_rsv,0);
	  else
            X_new_adj_cost := h_dpr_out.new_adj_cost;
	 end if;

	 if (p_log_level_rec.statement_level) then
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
	      element=>'Before calc adj_amt, h_dpr_out.new_adj_cost',
	      value=>h_dpr_out.new_adj_cost, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
	      element=>'Before calc adj_amt, x_new_adj_cost',
	      value=>x_new_adj_cost, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
	      element=>'Before calc adj_amt, deprn_summary.bonus_deprn_rsv',
	      value=>deprn_summary.bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	 end if;

        end if; -- End Not Use Depreciable Basis Formala

-- bonus, added h_dpr_row.bonus_deprn_rsv field to calculation.
-- bug 2510999
-- original
        X_fin_info_ptr.adj_amount :=
		(h_dpr_out.new_deprn_rsv -
		 deprn_summary.deprn_rsv) -
		 (h_current_rsv - deprn_summary.deprn_rsv) -
		  nvl(h_dpr_row.bonus_deprn_rsv,0);

-- a test, now excluded.
--        X_fin_info_ptr.adj_amount :=
--	 ((h_dpr_out.new_deprn_rsv + nvl(deprn_summary.bonus_deprn_rsv,0)) -
--	   deprn_summary.deprn_rsv) -
--	  (h_current_rsv - deprn_summary.deprn_rsv) -
--		  nvl(h_dpr_row.bonus_deprn_rsv,0);

	 if (p_log_level_rec.statement_level) then
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'x_fin_info_ptr.adj_amount ',
			      value=>x_fin_info_ptr.adj_amount, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'h_dpr_out.new_deprn_rsv ',
			      value=>h_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'deprn_summary.deprn_rsv',
			      value=>deprn_summary.deprn_rsv, p_log_level_rec => p_log_level_rec);
	    FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'h_current_rsv',
			      value=>h_current_rsv, p_log_level_rec => p_log_level_rec);
	 end if;
-- bonus
--  h_dpr_row.bonus_deprn_rsv arrives with value added for bonus_deprn_rsv.
--  the new_bonus_deprn_rsv amount is not vanilla therefore the *2.
--  if it turns out to be wrong calculation, it should be investigated
--  why bonus_deprn_rsv doesn't arrive as expected.
	if (h_dpr_row.bonus_rule is not null) then

           X_bonus_deprn_exp :=
		(h_dpr_out.new_bonus_deprn_rsv -
		 deprn_summary.bonus_deprn_rsv) -
		 ( (h_dpr_row.bonus_deprn_rsv - deprn_summary.bonus_deprn_rsv) * 2);

	    if (p_log_level_rec.statement_level) then
	       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'x_bonus_deprn_exp ',
			      value=>x_bonus_deprn_exp, p_log_level_rec => p_log_level_rec);
	       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'h_dpr_out.new_bonus_deprn_rsv ',
			      value=>h_dpr_out.new_bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'h_dpr_row.bonus_deprn_rsv',
			      value=>h_dpr_row.bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxraf',
			      element=>'deprn_summary.bonus_deprn_rsv',
			      value=>deprn_summary.bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	    end if;
	end if;

-- bonus: assigning bonus rule value back.
	h_dpr_row.bonus_rule := h_bonus_rule;

	h_current_rsv := h_current_total_rsv;

    end if;--if (not((cur_fy = amortize_fy) and (cur_per_num = amortize_per_num)))
 end if;--if (X_fin_info_ptr.amortization_start_date is not null)


-- bug 3572689
 if (h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT AND
     h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_NBV) then

	x_new_raf := 1;
        x_new_formula_factor := 1;
 end if;

  return TRUE;
 exception
    when others then
     FA_SRVR_MSG.ADD_SQL_ERROR
            (CALLING_FN => 'FA_AMORT_PKG.faxraf', p_log_level_rec => p_log_level_rec);
     return  FALSE;
end faxraf;
---------------------------------------------------------------------------
FUNCTION faxama (X_fin_info_ptr   	in out nocopy FA_STD_TYPES.fin_info_struct,
		 X_new_raf		in out nocopy number,
 		 X_new_adj_cost		in out nocopy number,
 		 X_new_adj_capacity 	in out nocopy number,
 		 X_new_reval_amo_basis 	in out nocopy number,
 		 X_new_salvage_value	in out nocopy number,
		 X_new_formula_factor	in out nocopy number,
 		 X_ccid		        in  number,
		 X_ins_adjust_flag	in  boolean,
                 X_mrc_sob_type_code    in  varchar2,
                 X_set_of_books_id      in  number,
		 X_deprn_exp            out nocopy number,
                 X_bonus_deprn_exp      out nocopy number,
		 X_last_update_date date default sysdate,
		 X_last_updated_by number default -1,
		 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is
h_reval_deprn_rsv_adj	number :=0;
h_afn_zero	        number:=0;
h_err_string		varchar2(30);
 begin <<faxama>>

X_deprn_exp := 0;    -- initialize
X_bonus_deprn_exp := 0;

 if (X_fin_info_ptr.asset_type='CIP')
 then
    FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxama',
		   NAME=>'FA_AMT_CIP_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
	return FALSE;
 end if;

 if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxama',
                element=>'First asset_type',
                value=>X_fin_info_ptr.asset_type, p_log_level_rec => p_log_level_rec);
    end if;

 X_fin_info_ptr.used_by_revaluation:= 0;

 if (not faxraf(X_fin_info_ptr,
                 X_new_raf,
                 X_new_adj_cost,
                 X_new_adj_capacity,
                 X_new_reval_amo_basis,
                 X_new_salvage_value,
                 h_reval_deprn_rsv_adj,
		 X_new_formula_factor,
		 X_bonus_deprn_exp,
                 X_mrc_sob_type_code,
                 X_set_of_books_id,
                 p_log_level_rec))
 then
	 FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxama', p_log_level_rec => p_log_level_rec);
	return FALSE;
 end if;

--  save deprn_exp to pass back to calling program
  x_deprn_exp := X_fin_info_ptr.adj_amount;

  if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxama',
                element=>'Before faxiat-Cost',
                value=>X_fin_info_ptr.cost, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxama',
                element=>'Before faxiat-Old Cost',
                value=>X_fin_info_ptr.old_cost, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxama',
                element=>'x_new_adj Cost',
                value=> x_new_adj_cost, p_log_level_rec => p_log_level_rec);
    end if;
   -- syoung: SET_DEBUG_FLAG shouldn't be set randomly when using transaction
   -- engine.
   --FA_DEBUG_PKG.SET_DEBUG_FLAG(debug_flag=>'YES', p_log_level_rec => p_log_level_rec);

 -- BUG# 2248362 - changing this logic as it was firing
 -- even when ins_adj was false
 if (X_ins_adjust_flag and
     ((X_fin_info_ptr.adj_amount <> 0) or
      (X_fin_info_ptr.cost <> X_fin_info_ptr.old_cost)))
 then
	h_afn_zero :=0;
 	h_err_string := 'FA_AMT_FAXIAT_CALL';
-- Bonus: BONUS EXPENSE row is created in fa_adjustments for
--        backdated amortized adjustments. The only known case
-- 	  for amortized adjustments.

  if (p_log_level_rec.statement_level)
    then
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxama',
                element=>'Before faxiat- deprn_exp',
                value=>X_fin_info_ptr.adj_amount, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (fname=>'FA_AMORT_PKG.faxama',
                element=>'Before faxiat-bonus_deprn_exp',
                value=>X_bonus_deprn_exp, p_log_level_rec => p_log_level_rec);
    end if;
     if (not faxiat(X_fin_info_ptr,
                    X_fin_info_ptr.adj_amount,
		    X_bonus_deprn_exp, -- bonus deprn exp.
		    h_afn_zero,
		    X_ccid,
		    X_last_update_date,
		    X_last_updated_by,
		    X_last_update_login,
                    X_mrc_sob_type_code,
                    p_log_level_rec))
     then
	 FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_AMORT_PKG.faxama',
		NAME=>h_err_string, p_log_level_rec => p_log_level_rec);
	return FALSE;
     end if;
  end if;   -- cost = old cost
    return TRUE;
  exception
     when others then
     FA_SRVR_MSG.ADD_SQL_ERROR
            (CALLING_FN => 'FA_AMORT_PKG.faxama', p_log_level_rec => p_log_level_rec);

     return  FALSE;
 end faxama;

---------------------------------------------------------------------------

-- backdate amortization enhancement - begin
-- this function will get books row of addition transaction
-- and call faxcde to calculate what the actual reserve is from the
-- prorate period upto right before the amortization period
FUNCTION get_reserve(X_fin_info_ptr     in out nocopy fa_std_types.fin_info_struct,
			     x_add_txn_id       in number,
			     x_amortize_fy      in integer,
                     x_amortize_per_num in integer,
                     x_pers_per_yr      in integer,
                     x_mrc_sob_type_code in varchar2,
                     x_set_of_books_id  in number,
                     x_deprn_rsv        out nocopy number,
                     x_bonus_deprn_rsv  out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

bk_rec          fa_books%rowtype;
l_fin_info      FA_STD_TYPES.fin_info_struct;
l_dpr_row       FA_STD_TYPES.dpr_struct;
l_dpr_arr       FA_STD_TYPES.dpr_arr_type;
l_dpr_out       FA_STD_TYPES.dpr_out_struct;
dummy_var       varchar2(15);
dummy_num       number;
running_mode    number;

begin

    -- Override for what-if adjustment
    if X_fin_info_ptr.running_mode = fa_std_types.FA_DPR_PROJECT then
           running_mode:= fa_std_types.FA_DPR_PROJECT;
    else
           running_mode:= fa_std_types.FA_DPR_NORMAL;
    end if;
    -- End of Manual Override

    l_fin_info := X_fin_info_ptr;

    if x_mrc_sob_type_code = 'R' then
       select bk.BOOK_TYPE_CODE               ,
              bk.ASSET_ID                     ,
              bk.DATE_PLACED_IN_SERVICE       ,
              bk.DATE_EFFECTIVE               ,
              bk.DEPRN_START_DATE             ,
              bk.DEPRN_METHOD_CODE            ,
              bk.LIFE_IN_MONTHS               ,
              bk.RATE_ADJUSTMENT_FACTOR       ,
              bk.ADJUSTED_COST                ,
              bk.COST                         ,
              bk.ORIGINAL_COST                ,
              bk.SALVAGE_VALUE                ,
              bk.PRORATE_CONVENTION_CODE      ,
              bk.PRORATE_DATE                 ,
              bk.COST_CHANGE_FLAG             ,
              bk.ADJUSTMENT_REQUIRED_STATUS   ,
              bk.CAPITALIZE_FLAG              ,
              bk.RETIREMENT_PENDING_FLAG      ,
              bk.DEPRECIATE_FLAG              ,
              bk.LAST_UPDATE_DATE             ,
              bk.LAST_UPDATED_BY              ,
              bk.DATE_INEFFECTIVE             ,
              bk.TRANSACTION_HEADER_ID_IN     ,
              bk.TRANSACTION_HEADER_ID_OUT    ,
              bk.ITC_AMOUNT_ID                ,
              bk.ITC_AMOUNT                   ,
              bk.RETIREMENT_ID                ,
              bk.TAX_REQUEST_ID               ,
              bk.ITC_BASIS                    ,
              bk.BASIC_RATE                   ,
              bk.ADJUSTED_RATE                ,
              bk.BONUS_RULE                   ,
              bk.CEILING_NAME                 ,
              bk.RECOVERABLE_COST             ,
              bk.LAST_UPDATE_LOGIN            ,
              bk.ADJUSTED_CAPACITY            ,
              bk.FULLY_RSVD_REVALS_COUNTER    ,
              bk.IDLED_FLAG                   ,
              bk.PERIOD_COUNTER_CAPITALIZED   ,
              bk.PERIOD_COUNTER_FULLY_RESERVED,
              bk.PERIOD_COUNTER_FULLY_RETIRED ,
              bk.PRODUCTION_CAPACITY          ,
              bk.REVAL_AMORTIZATION_BASIS     ,
              bk.REVAL_CEILING                ,
              bk.UNIT_OF_MEASURE              ,
              bk.UNREVALUED_COST              ,
              bk.ANNUAL_DEPRN_ROUNDING_FLAG   ,
              bk.PERCENT_SALVAGE_VALUE        ,
              bk.ALLOWED_DEPRN_LIMIT          ,
              bk.ALLOWED_DEPRN_LIMIT_AMOUNT   ,
              bk.PERIOD_COUNTER_LIFE_COMPLETE ,
              bk.ADJUSTED_RECOVERABLE_COST    ,
              bk.ANNUAL_ROUNDING_FLAG         ,
              bk.GLOBAL_ATTRIBUTE1            ,
              bk.GLOBAL_ATTRIBUTE2            ,
              bk.GLOBAL_ATTRIBUTE3            ,
              bk.GLOBAL_ATTRIBUTE4            ,
              bk.GLOBAL_ATTRIBUTE5            ,
              bk.GLOBAL_ATTRIBUTE6            ,
              bk.GLOBAL_ATTRIBUTE7            ,
              bk.GLOBAL_ATTRIBUTE8            ,
              bk.GLOBAL_ATTRIBUTE9            ,
              bk.GLOBAL_ATTRIBUTE10           ,
              bk.GLOBAL_ATTRIBUTE11           ,
              bk.GLOBAL_ATTRIBUTE12           ,
              bk.GLOBAL_ATTRIBUTE13           ,
              bk.GLOBAL_ATTRIBUTE14           ,
              bk.GLOBAL_ATTRIBUTE15           ,
              bk.GLOBAL_ATTRIBUTE16           ,
              bk.GLOBAL_ATTRIBUTE17           ,
              bk.GLOBAL_ATTRIBUTE18           ,
              bk.GLOBAL_ATTRIBUTE19           ,
              bk.GLOBAL_ATTRIBUTE20           ,
              bk.GLOBAL_ATTRIBUTE_CATEGORY    ,
              bk.EOFY_ADJ_COST                ,
              bk.EOFY_FORMULA_FACTOR          ,
              bk.SHORT_FISCAL_YEAR_FLAG       ,
              bk.CONVERSION_DATE              ,
              bk.ORIGINAL_DEPRN_START_DATE    ,
              bk.REMAINING_LIFE1              ,
              bk.REMAINING_LIFE2              ,
              bk.OLD_ADJUSTED_COST            ,
              bk.FORMULA_FACTOR               ,
              bk.GROUP_ASSET_ID
         into bk_rec.BOOK_TYPE_CODE               ,
              bk_rec.ASSET_ID                     ,
              bk_rec.DATE_PLACED_IN_SERVICE       ,
              bk_rec.DATE_EFFECTIVE               ,
              bk_rec.DEPRN_START_DATE             ,
              bk_rec.DEPRN_METHOD_CODE            ,
              bk_rec.LIFE_IN_MONTHS               ,
              bk_rec.RATE_ADJUSTMENT_FACTOR       ,
              bk_rec.ADJUSTED_COST                ,
              bk_rec.COST                         ,
              bk_rec.ORIGINAL_COST                ,
              bk_rec.SALVAGE_VALUE                ,
              bk_rec.PRORATE_CONVENTION_CODE      ,
              bk_rec.PRORATE_DATE                 ,
              bk_rec.COST_CHANGE_FLAG             ,
              bk_rec.ADJUSTMENT_REQUIRED_STATUS   ,
              bk_rec.CAPITALIZE_FLAG              ,
              bk_rec.RETIREMENT_PENDING_FLAG      ,
              bk_rec.DEPRECIATE_FLAG              ,
              bk_rec.LAST_UPDATE_DATE             ,
              bk_rec.LAST_UPDATED_BY              ,
              bk_rec.DATE_INEFFECTIVE             ,
              bk_rec.TRANSACTION_HEADER_ID_IN     ,
              bk_rec.TRANSACTION_HEADER_ID_OUT    ,
              bk_rec.ITC_AMOUNT_ID                ,
              bk_rec.ITC_AMOUNT                   ,
              bk_rec.RETIREMENT_ID                ,
              bk_rec.TAX_REQUEST_ID               ,
              bk_rec.ITC_BASIS                    ,
              bk_rec.BASIC_RATE                   ,
              bk_rec.ADJUSTED_RATE                ,
              bk_rec.BONUS_RULE                   ,
              bk_rec.CEILING_NAME                 ,
              bk_rec.RECOVERABLE_COST             ,
              bk_rec.LAST_UPDATE_LOGIN            ,
              bk_rec.ADJUSTED_CAPACITY            ,
              bk_rec.FULLY_RSVD_REVALS_COUNTER    ,
              bk_rec.IDLED_FLAG                   ,
              bk_rec.PERIOD_COUNTER_CAPITALIZED   ,
              bk_rec.PERIOD_COUNTER_FULLY_RESERVED,
              bk_rec.PERIOD_COUNTER_FULLY_RETIRED ,
              bk_rec.PRODUCTION_CAPACITY          ,
              bk_rec.REVAL_AMORTIZATION_BASIS     ,
              bk_rec.REVAL_CEILING                ,
              bk_rec.UNIT_OF_MEASURE              ,
              bk_rec.UNREVALUED_COST              ,
              bk_rec.ANNUAL_DEPRN_ROUNDING_FLAG   ,
              bk_rec.PERCENT_SALVAGE_VALUE        ,
              bk_rec.ALLOWED_DEPRN_LIMIT          ,
              bk_rec.ALLOWED_DEPRN_LIMIT_AMOUNT   ,
              bk_rec.PERIOD_COUNTER_LIFE_COMPLETE ,
              bk_rec.ADJUSTED_RECOVERABLE_COST    ,
              bk_rec.ANNUAL_ROUNDING_FLAG         ,
              bk_rec.GLOBAL_ATTRIBUTE1            ,
              bk_rec.GLOBAL_ATTRIBUTE2            ,
              bk_rec.GLOBAL_ATTRIBUTE3            ,
              bk_rec.GLOBAL_ATTRIBUTE4            ,
              bk_rec.GLOBAL_ATTRIBUTE5            ,
              bk_rec.GLOBAL_ATTRIBUTE6            ,
              bk_rec.GLOBAL_ATTRIBUTE7            ,
              bk_rec.GLOBAL_ATTRIBUTE8            ,
              bk_rec.GLOBAL_ATTRIBUTE9            ,
              bk_rec.GLOBAL_ATTRIBUTE10           ,
              bk_rec.GLOBAL_ATTRIBUTE11           ,
              bk_rec.GLOBAL_ATTRIBUTE12           ,
              bk_rec.GLOBAL_ATTRIBUTE13           ,
              bk_rec.GLOBAL_ATTRIBUTE14           ,
              bk_rec.GLOBAL_ATTRIBUTE15           ,
              bk_rec.GLOBAL_ATTRIBUTE16           ,
              bk_rec.GLOBAL_ATTRIBUTE17           ,
              bk_rec.GLOBAL_ATTRIBUTE18           ,
              bk_rec.GLOBAL_ATTRIBUTE19           ,
              bk_rec.GLOBAL_ATTRIBUTE20           ,
              bk_rec.GLOBAL_ATTRIBUTE_CATEGORY    ,
              bk_rec.EOFY_ADJ_COST                ,
              bk_rec.EOFY_FORMULA_FACTOR          ,
              bk_rec.SHORT_FISCAL_YEAR_FLAG       ,
              bk_rec.CONVERSION_DATE              ,
              bk_rec.ORIGINAL_DEPRN_START_DATE    ,
              bk_rec.REMAINING_LIFE1              ,
              bk_rec.REMAINING_LIFE2              ,
              bk_rec.OLD_ADJUSTED_COST            ,
              bk_rec.FORMULA_FACTOR               ,
              bk_rec.GROUP_ASSET_ID
       from fa_mc_books bk
       where bk.book_type_code = X_fin_info_ptr.book
       and   bk.asset_id = X_fin_info_ptr.asset_id
       and   bk.transaction_header_id_in = x_add_txn_id
       and   bk.set_of_books_id = X_set_of_books_id;
    else
       select bk.*
       into bk_rec
       from fa_books bk
       where bk.book_type_code = X_fin_info_ptr.book
       and   bk.asset_id = X_fin_info_ptr.asset_id
       and   bk.transaction_header_id_in = x_add_txn_id;
    end if;

    l_fin_info.adj_cost := bk_rec.adjusted_cost;
    l_fin_info.rec_cost := bk_rec.recoverable_cost;
    l_fin_info.reval_amo_basis := bk_rec.reval_amortization_basis;
    l_fin_info.adj_rate := bk_rec.adjusted_rate;
    l_fin_info.capacity := bk_rec.production_capacity;
    l_fin_info.adj_capacity := bk_rec.adjusted_capacity;
    l_fin_info.adj_rec_cost := bk_rec.adjusted_recoverable_cost;
    l_fin_info.salvage_value := bk_rec.salvage_value;
    l_fin_info.method_code := bk_rec.deprn_method_code;
    l_fin_info.life := bk_rec.life_in_months;
    l_fin_info.ceiling_name := bk_rec.ceiling_name;
    l_fin_info.bonus_rule := bk_rec.bonus_rule;
    l_fin_info.deprn_rounding_flag := bk_rec.annual_deprn_rounding_flag;
    l_fin_info.rate_adj_factor := bk_rec.rate_adjustment_factor;
    l_fin_info.prorate_date := bk_rec.prorate_date;
    l_fin_info.deprn_start_date := bk_rec.deprn_start_date;
    l_fin_info.date_placed_in_svc := bk_rec.date_placed_in_service;

    if not (FA_EXP_PKG.faxbds(l_fin_info, l_dpr_row, dummy_var,dummy_num,FALSE,X_mrc_sob_type_code, p_log_level_rec => p_log_level_rec)) then
        fa_srvr_msg.add_message (calling_fn => 'FA_AMORT_PKG.get_reserve', p_log_level_rec => p_log_level_rec);
        return FALSE;
    end if;
    if (x_amortize_per_num = 1) then
       l_dpr_row.y_end := x_amortize_fy - 1;
       l_dpr_row.p_cl_end := x_pers_per_yr;
    else
       l_dpr_row.y_end := x_amortize_fy;
       l_dpr_row.p_cl_end := x_amortize_per_num - 1;
    end if;

    l_dpr_row.bonus_rule := '';
    l_dpr_row.reval_rsv := 0;
    l_dpr_row.prior_fy_exp := 0;
    l_dpr_row.ytd_deprn := 0;
	l_dpr_row.mrc_sob_type_code := x_mrc_sob_type_code;

    if (not FA_CDE_PKG.faxcde(l_dpr_row,
                              l_dpr_arr,
                              l_dpr_out,
                              running_mode, p_log_level_rec => p_log_level_rec)) then
        --                      FA_STD_TYPES.FA_DPR_NORMAL)) then
       FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_AMORT_PKG.get_reserve',
                 NAME=>'FA_AMT_CAL_DP_EXP', p_log_level_rec => p_log_level_rec);
       return FALSE;
    end if;

    X_fin_info_ptr.deprn_override_flag:= l_dpr_out.deprn_override_flag;
        if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.get_reserve ',
                 element=>'l_dpr_out.new_deprn_rsv',
                 value=>l_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(fname=>'FA_AMORT_PKG.get_reserve ',
                 element=>'l_dpr_out.new_bonus_deprn_rsv',
                 value=>l_dpr_out.new_bonus_deprn_rsv, p_log_level_rec => p_log_level_rec);
	end if;
    x_deprn_rsv := l_dpr_out.new_deprn_rsv;
    x_bonus_deprn_rsv := l_dpr_out.new_bonus_deprn_rsv;
    return TRUE;

  exception
    when others then
     FA_SRVR_MSG.ADD_SQL_ERROR
            (CALLING_FN => 'FA_AMORT_PKG.get_reserve', p_log_level_rec => p_log_level_rec);
     return  FALSE;

end get_reserve;
-- backdate amortization enhancement - end


---------------------------------------------------------------------------

-- New function: faxnac
-- Alternative flat rate depreciation calculation.
-- If deprn_basis_formula = 'STRICT_FLAT', use the new adjustment method.
-- When using a NBV based flat rate method, adjustment base amount will be
-- the NBV of the beginning of the year, and when using a Cost based flat rate
-- method, adjustment base amount will be the recoverable cost.

FUNCTION faxnac (X_method_code in varchar2,
                 X_life in number,
                 X_rec_cost in number,
                 X_prior_fy_exp in number,
                 X_deprn_rsv in number,
                 X_ytd_deprn in number,
                 X_adj_cost in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is
  h_deprn_basis_formula varchar2(30);
  h_rate_source_rule varchar2(10);
  h_deprn_basis_rule varchar2(4);
  h_dummy_bool boolean;
  h_dummy_int integer;
begin

  if X_adj_cost is null then return false;
  end if;

  h_deprn_basis_formula := fa_cache_pkg.fazccmt_record.deprn_basis_formula;

  if h_deprn_basis_formula is null then
     return true;
  end if;

-- following cache call is redundant as cache shoudl already be loaded - BMR (double check)
--  if h_deprn_basis_formula = fa_std_types.FAD_DBF_FLAT then
    if h_deprn_basis_formula = 'STRICT_FLAT' then
       if (  not fa_cache_pkg.fazccmt(x_method_code,
                                    x_life, p_log_level_rec => p_log_level_rec)) then
        fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac', p_log_level_rec => p_log_level_rec);
        return false;
     end if;

     h_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
     h_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

     if h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT and h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_COST then
        if x_rec_cost is null then
           fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac', p_log_level_rec => p_log_level_rec);
           return false;
        end if;

        x_adj_cost := x_rec_cost;

     elsif h_rate_source_rule = FA_STD_TYPES.FAD_RSR_FLAT and h_deprn_basis_rule = FA_STD_TYPES.FAD_DBR_NBV then

        if x_rec_cost is null or
           not ( (x_prior_fy_exp is not null) or
                 (x_deprn_rsv is not null and x_ytd_deprn is not null) ) then
           fa_srvr_msg.add_message(calling_fn => 'FA_AMORT_PKG.faxnac', p_log_level_rec => p_log_level_rec);
           return false;
        end if;

        if x_prior_fy_exp is null then
           x_adj_cost := x_rec_cost - x_deprn_rsv + x_ytd_deprn;
        else
           x_adj_cost := x_rec_cost - x_prior_fy_exp;
        end if;
     end if;
  end if;

  return true;
end faxnac;

END FA_AMORT_PKG;

/
