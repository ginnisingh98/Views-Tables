--------------------------------------------------------
--  DDL for Package Body FA_QUERY_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_QUERY_BALANCES_PKG" as
/* $Header: faxqbalb.pls 120.9.12010000.2 2009/07/19 10:00:04 glchen ship $ */


-- Call this procedure from a Forms 4.5 client, or any PLSQL below
-- version 2.0.  This just loads the dpr_row struct to pass to
-- QUERY_BALANCES_INT, and unpacks the results.

-- Can call in several "RUN_MODEs":
-- STANDARD: Query detail/summary in given period from CORPORATE book.
-- ADJUSTED: Query detail/summary in given period from TAX book.
-- For both STANDARD/ADJUSTED: Returns period-closing balances if period
--  is closed.  If current period, returns last period's closing balances
--  plus any adjustments from this period.
-- DEPRN: Query everything except deprn balances... return these as
--      zero so as not to interfere with deprn program which calls this.
--  Also query PRIOR period's deprn row to get balances for
--  depreciation program.
-- TRANSACTION: Query detail/summary balances of asset in given book
-- (either CORP or TAX) right after the given transaction is applied.
-- Don't need to indicate which period or book class.  Also, trx_id need
-- not be for this asset; it need only exist in the system.


-- BUG# 1823498 MRC changes
-- transfers and reclasses will be calling this directly
-- for each reporting book as well as primary so each function will
-- determine whether to select from the corp or mc tables based on the
-- value of the GL SOB profile
--   -- bridgway 06/20/01


PROCEDURE QUERY_BALANCES
                (X_ASSET_ID                     NUMBER,
                 X_BOOK                         VARCHAR2,
                 X_PERIOD_CTR                   NUMBER  DEFAULT 0,
                 X_DIST_ID                      NUMBER  DEFAULT 0,
                 X_RUN_MODE                     VARCHAR2  DEFAULT 'STANDARD',
                 X_COST                     OUT NOCOPY NUMBER,
                 X_DEPRN_RSV                OUT NOCOPY NUMBER,
                 X_REVAL_RSV                OUT NOCOPY NUMBER,
                 X_YTD_DEPRN                OUT NOCOPY NUMBER,
                 X_YTD_REVAL_EXP            OUT NOCOPY NUMBER,
                 X_REVAL_DEPRN_EXP          OUT NOCOPY NUMBER,
                 X_DEPRN_EXP                OUT NOCOPY NUMBER,
                 X_REVAL_AMO                OUT NOCOPY NUMBER,
                 X_PROD                     OUT NOCOPY NUMBER,
                 X_YTD_PROD                 OUT NOCOPY NUMBER,
                 X_LTD_PROD                 OUT NOCOPY NUMBER,
                 X_ADJ_COST                 OUT NOCOPY NUMBER,
                 X_REVAL_AMO_BASIS          OUT NOCOPY NUMBER,
                 X_BONUS_RATE               OUT NOCOPY NUMBER,
                 X_DEPRN_SOURCE_CODE        OUT NOCOPY VARCHAR2,
                 X_ADJUSTED_FLAG            OUT NOCOPY BOOLEAN,
                 X_TRANSACTION_HEADER_ID IN     NUMBER DEFAULT -1,
                 X_BONUS_DEPRN_RSV          OUT NOCOPY NUMBER,
                 X_BONUS_YTD_DEPRN          OUT NOCOPY NUMBER,
                 X_BONUS_DEPRN_AMOUNT       OUT NOCOPY NUMBER,
                 X_IMPAIRMENT_RSV           OUT NOCOPY NUMBER,
                 X_YTD_IMPAIRMENT           OUT NOCOPY NUMBER,
                 X_IMPAIRMENT_AMOUNT        OUT NOCOPY NUMBER,
                 X_CAPITAL_ADJUSTMENT       OUT NOCOPY NUMBER, -- Bug 6666666
                 X_GENERAL_FUND             OUT NOCOPY NUMBER, -- Bug 6666666
                 X_MRC_SOB_TYPE_CODE         IN VARCHAR2,
                 X_SET_OF_BOOKS_ID           IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  -- Use the Standard Type define in faxstds.pls
  H_DPR_ROW    FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
  H_SUCCESS    BOOLEAN;

  cursor c_get_group_info is
        select group_asset_id, member_rollup_flag
        from fa_books
        where asset_id = X_ASSET_ID
        and book_type_code = X_BOOK
        and transaction_header_id_out is null;

  l_group_asset_id      number;
  l_member_rollup_flag  varchar2(1);

  error_found exception;

BEGIN

  -- Load dpr_row structure with input parameters.
  H_DPR_ROW.ASSET_ID := X_ASSET_ID;
  H_DPR_ROW.BOOK := X_BOOK;
  H_DPR_ROW.PERIOD_CTR := X_PERIOD_CTR;
  H_DPR_ROW.DIST_ID := X_DIST_ID;

  -- clear/load the book controls caches in case it's
  -- either stale or not populated, since this routine
  -- is only called on an asset by asset basis from the
  -- form, performance is not a huge concern.

  if (nvl(fa_cache_pkg.fazcbc_record.book_type_code, '-NULL') <> X_book) then
     if not fa_cache_pkg.fazcbc(X_BOOK => X_BOOK
              ,p_log_level_rec => p_log_level_rec) then
        raise error_found;
     end if;
  end if;

  h_dpr_row.mrc_sob_type_code := x_mrc_sob_type_code;
  h_dpr_row.set_of_books_id := x_set_of_books_id;

  OPEN c_get_group_info;
  FETCH c_get_group_info INTO l_group_asset_id, l_member_rollup_flag;
  CLOSE c_get_group_info;

  if (l_group_asset_id is null and
      l_member_rollup_flag = 'Y') then
     h_dpr_row.asset_type := 'GROUP';
     h_dpr_row.member_rollup_flag := l_member_rollup_flag;
  end if;

  -- Call internal function.

  QUERY_BALANCES_INT (
          X_DPR_ROW               => H_DPR_ROW,
          X_RUN_MODE              => X_RUN_MODE,
          X_DEBUG                 => FALSE,
          X_SUCCESS               => H_SUCCESS,
          X_CALLING_FN            => 'QUERY_BALANCES',
          X_TRANSACTION_HEADER_ID => X_TRANSACTION_HEADER_ID,
          p_log_level_rec         => p_log_level_rec);

  -- Unpack output parameters from dpr_row structure.

  X_COST               := H_DPR_ROW.COST;
  X_DEPRN_RSV          := H_DPR_ROW.DEPRN_RSV;
  X_REVAL_RSV          := H_DPR_ROW.REVAL_RSV;
  X_YTD_DEPRN          := H_DPR_ROW.YTD_DEPRN;
  X_REVAL_DEPRN_EXP    := H_DPR_ROW.REVAL_DEPRN_EXP;
  X_DEPRN_EXP          := H_DPR_ROW.DEPRN_EXP;
  X_YTD_REVAL_EXP      := H_DPR_ROW.YTD_REVAL_DEPRN_EXP;
  X_REVAL_AMO          := H_DPR_ROW.REVAL_AMO;
  X_PROD               := H_DPR_ROW.PROD;
  X_YTD_PROD           := H_DPR_ROW.YTD_PROD;
  X_LTD_PROD           := H_DPR_ROW.LTD_PROD;
  X_ADJ_COST           := H_DPR_ROW.ADJ_COST;
  X_REVAL_AMO_BASIS    := H_DPR_ROW.REVAL_AMO_BASIS;
  X_BONUS_RATE         := H_DPR_ROW.BONUS_RATE;
  X_DEPRN_SOURCE_CODE  := H_DPR_ROW.DEPRN_SOURCE_CODE;
  X_ADJUSTED_FLAG      := H_DPR_ROW.ADJUSTED_FLAG;
  X_BONUS_DEPRN_RSV    := H_DPR_ROW.BONUS_DEPRN_RSV;
  X_BONUS_YTD_DEPRN    := H_DPR_ROW.BONUS_YTD_DEPRN;
  X_BONUS_DEPRN_AMOUNT := H_DPR_ROW.BONUS_DEPRN_AMOUNT;
  X_IMPAIRMENT_RSV     := H_DPR_ROW.IMPAIRMENT_RSV;
  X_YTD_IMPAIRMENT     := H_DPR_ROW.YTD_IMPAIRMENT;
  X_IMPAIRMENT_AMOUNT  := H_DPR_ROW.IMPAIRMENT_AMOUNT;
  X_CAPITAL_ADJUSTMENT := H_DPR_ROW.CAPITAL_ADJUSTMENT;  -- Bug 6666666
  X_GENERAL_FUND       := H_DPR_ROW.GENERAL_FUND;        -- Bug 6666666


EXCEPTION
  when error_found then
       fa_srvr_msg.add_sql_error(
          calling_fn => 'QUERY_BALANCES', p_log_level_rec => p_log_level_rec);
       fa_srvr_msg.add_message(
          calling_fn => 'QUERY_BALANCES',
          name       => 'FA_WHATIF_ASSET_QUERY_BAL',
          token1     => 'ASSET_ID',
          value1     => to_char(X_asset_id),
          p_log_level_rec => p_log_level_rec);
       fa_standard_pkg.raise_error(
          CALLED_FN  => 'QUERY_BALANCES',
          CALLING_FN => 'CLIENT', p_log_level_rec => p_log_level_rec);
  when others then
       if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD(
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_BALANCES',
             element => 'ASSET_ID',
             value   => H_DPR_ROW.ASSET_ID, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_BALANCES',
             element => 'BOOK',
             value   => H_DPR_ROW.BOOK, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD(
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_BALANCES',
             element => 'COST',
             value   => H_DPR_ROW.COST, p_log_level_rec => p_log_level_rec);
       end if;
       fa_srvr_msg.add_sql_error(
          calling_fn => 'QUERY_BALANCES', p_log_level_rec => p_log_level_rec);
       fa_srvr_msg.add_message(
          calling_fn => 'QUERY_BALANCES',
          name       => 'FA_WHATIF_ASSET_QUERY_BAL',
          token1     => 'ASSET_ID',
          value1     => to_char(X_asset_id),
          p_log_level_rec => p_log_level_rec);
       fa_standard_pkg.raise_error(
          CALLED_FN  => 'QUERY_BALANCES',
          CALLING_FN => 'CLIENT', p_log_level_rec => p_log_level_rec);

END QUERY_BALANCES;

-----------------------------------------------------------------------------------


-- Adds the current period's adjustments (ADJ_DRS) to the
-- financial info in the most recent depreciation row (DEST_DRS).
-- S.B. called right after get_adjustments.
-- This should go away in Rel11, where adjustments will update
-- deprn rows.


PROCEDURE ADD_ADJ_TO_DEPRN
            (X_ADJ_DRS      IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
             X_DEST_DRS     IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
             X_SUCCESS         OUT NOCOPY BOOLEAN,
             X_CALLING_FN          VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   IS

  h_deprn_expense_adjs       NUMBER;
  h_curr_period_counter      NUMBER;
  h_dummy                    NUMBER;


BEGIN


  X_success := FALSE;

  --  Get current period  counter and book class.
  --  This change is done by Sujit Dalai when YTD revaluation was implemented .
  --  Fix for 947800.  Added h_dummy to avoid ORA-1403.

  if (X_ADJ_DRS.BOOK is not null) then
     h_curr_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
     h_dummy               := 1;
  end if;

  -- Get adjustment amount from fa_adjustment when adjustment_type is 'EXPENSE'
  -- and source_type_code is 'REVALUATION'. This change is done by Sujit Dalai.
  --  Fix for 947800.  Added h_dummy to avoid ORA-1403.

  if (h_curr_period_counter is not null) then
     /* Bug 6348506 Split the query into UNION ALL for improving performance */

     /* Bug 6915685: Fix for perf fix 6348506 caused ora-1422.
        Thats because each SQL within UNION ALL had a group-by function
        that would always return 1 row each. Therefore, UNION ALL will
        cause 2 rows to be returned, cause ORA-1422.
        To fix this, added IF condition. This should definitely take care of
        both performance issue (6348506) and ora-1422 issue (6915685)  */

     if (x_adj_drs.mrc_sob_type_code  = 'R') then
       if (x_adj_drs.dist_id = 0) then   -- bugfix 6915685: added IF clause
        SELECT NVL(SUM(DECODE(ADJ.DEBIT_CREDIT_FLAG,
                             'DR', ADJ.ADJUSTMENT_AMOUNT,
                             'CR', -1*ADJ.ADJUSTMENT_AMOUNT)), 0), 1
          INTO h_deprn_expense_adjs, h_dummy
          FROM FA_MC_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID               = x_adj_drs.asset_id
           AND ADJ.BOOK_TYPE_CODE         = x_adj_drs.book
           AND ADJ.PERIOD_COUNTER_CREATED = h_curr_period_counter
           AND ADJ.SOURCE_TYPE_CODE       = 'REVALUATION'
           AND ADJ.ADJUSTMENT_TYPE        = 'EXPENSE'
           AND ADJ.SET_OF_BOOKS_ID        = x_adj_drs.set_of_books_id;
       else
        SELECT NVL(SUM(DECODE(ADJ.DEBIT_CREDIT_FLAG,
                             'DR', ADJ.ADJUSTMENT_AMOUNT,
                             'CR', -1*ADJ.ADJUSTMENT_AMOUNT)), 0), 1
          INTO h_deprn_expense_adjs, h_dummy
          FROM FA_MC_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID               = x_adj_drs.asset_id
           AND ADJ.BOOK_TYPE_CODE         = x_adj_drs.book
           AND ADJ.PERIOD_COUNTER_CREATED = h_curr_period_counter
           AND ADJ.SOURCE_TYPE_CODE       = 'REVALUATION'
           AND ADJ.ADJUSTMENT_TYPE        = 'EXPENSE'
           AND ADJ.DISTRIBUTION_ID        = x_adj_drs.dist_id
           AND ADJ.SET_OF_BOOKS_ID        = x_adj_drs.set_of_books_id;
       end if;
     else
       if (x_adj_drs.dist_id = 0) then   -- bugfix 6915685: added IF clause
        SELECT NVL(SUM(DECODE(ADJ.DEBIT_CREDIT_FLAG,
                             'DR', ADJ.ADJUSTMENT_AMOUNT,
                             'CR', -1*ADJ.ADJUSTMENT_AMOUNT)), 0), 1
          INTO h_deprn_expense_adjs, h_dummy
          FROM FA_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID               = x_adj_drs.asset_id
           AND ADJ.BOOK_TYPE_CODE         = x_adj_drs.book
           AND ADJ.PERIOD_COUNTER_CREATED = h_curr_period_counter
           AND ADJ.SOURCE_TYPE_CODE       = 'REVALUATION'
           AND ADJ.ADJUSTMENT_TYPE        = 'EXPENSE';
       else
        SELECT NVL(SUM(DECODE(ADJ.DEBIT_CREDIT_FLAG,
                             'DR', ADJ.ADJUSTMENT_AMOUNT,
                             'CR', -1*ADJ.ADJUSTMENT_AMOUNT)), 0), 1
          INTO h_deprn_expense_adjs, h_dummy
          FROM FA_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID               = x_adj_drs.asset_id
           AND ADJ.BOOK_TYPE_CODE         = x_adj_drs.book
           AND ADJ.PERIOD_COUNTER_CREATED = h_curr_period_counter
           AND ADJ.SOURCE_TYPE_CODE       = 'REVALUATION'
           AND ADJ.ADJUSTMENT_TYPE        = 'EXPENSE'
           AND ADJ.DISTRIBUTION_ID        = x_adj_drs.dist_id;
       end if;
     end if;

  end if ;

  -- Add expense adjustment to reserve.
  if (X_adj_drs.deprn_exp <> 0) then
     X_dest_drs.deprn_exp := X_dest_drs.deprn_exp  + X_adj_drs.deprn_exp;
     X_dest_drs.ytd_deprn := X_dest_drs.ytd_deprn  + X_adj_drs.deprn_exp;
     X_dest_drs.deprn_rsv := (X_dest_drs.deprn_rsv + X_adj_drs.deprn_exp
                              - h_deprn_expense_adjs) ;
  end if;

  -- Add bonus expense adjustment to bonus reserve.
  if (X_adj_drs.bonus_deprn_amount <> 0) then
     X_dest_drs.bonus_deprn_amount := X_dest_drs.bonus_deprn_amount + X_adj_drs.bonus_deprn_amount;
     X_dest_drs.bonus_ytd_deprn    := X_dest_drs.bonus_ytd_deprn    + X_adj_drs.bonus_deprn_amount;
     X_dest_drs.bonus_deprn_rsv    := (X_dest_drs.bonus_deprn_rsv   + X_adj_drs.bonus_deprn_amount);
  -- bonus: not handling revaluation expense as done for regular deprn. - h_deprn_expense_adjs
  end if;

  -- Add impairment expense adjustment to impairment reserve.
  if (X_adj_drs.impairment_amount <> 0) then
     X_dest_drs.impairment_amount := X_dest_drs.impairment_amount +
                                     X_adj_drs.impairment_amount;
     X_dest_drs.ytd_impairment    := X_dest_drs.ytd_impairment +
                                     X_adj_drs.impairment_amount;
/* This statement is commented for bug 7460979. This causes wrong Deprn Reserve values.
     X_dest_drs.impairment_rsv    := X_dest_drs.impairment_rsv +
                                     X_adj_drs.impairment_amount;*/
  end if;

  -- Bug 6666666 : SORP Complaince
  if (X_adj_drs.capital_adjustment <> 0) then
      X_dest_drs.capital_adjustment := X_dest_drs.capital_adjustment + X_adj_drs.capital_adjustment;
  end if;

  if (X_adj_drs.general_fund <> 0) then
      X_dest_drs.general_fund := X_dest_drs.general_fund + X_adj_drs.general_fund;
  end if;

  -- Add reval deprn expense adjustment to existing reval deprn
  -- expense balance.
  if (X_adj_drs.reval_deprn_exp <> 0) then
     X_dest_drs.reval_deprn_exp := X_dest_drs.reval_deprn_exp + X_adj_drs.reval_deprn_exp;
  end if;

  -- Add reval reserve and amortization.
  if (X_adj_drs.reval_amo <> 0) then
     X_dest_drs.reval_amo := X_dest_drs.reval_amo + X_adj_drs.reval_amo;
     X_dest_drs.reval_rsv := X_dest_drs.reval_rsv - X_adj_drs.reval_amo;
  end if;

  -- Add production adjustments to production balances.
  if (X_adj_drs.prod <> 0) then
     X_dest_drs.prod     := X_dest_drs.prod     + X_adj_drs.prod;
     X_dest_drs.ytd_prod := X_dest_drs.ytd_prod + X_adj_drs.prod;
     X_dest_drs.ltd_prod := X_dest_drs.ltd_prod + X_adj_drs.prod;
  end if;

  -- Deprn reserve adjustments
  if (X_adj_drs.deprn_rsv <> 0) then
     X_dest_drs.deprn_rsv := X_dest_drs.deprn_rsv - X_adj_drs.deprn_rsv;
  end if;

  -- Bonus Deprn reserve adjustments
  if (X_adj_drs.bonus_deprn_rsv <> 0) then
     X_dest_drs.bonus_deprn_rsv := X_dest_drs.bonus_deprn_rsv - X_adj_drs.bonus_deprn_rsv;
  end if;

  -- Impairment reserve adjustments
  if (X_adj_drs.impairment_rsv <> 0) then
     X_dest_drs.impairment_rsv := X_dest_drs.impairment_rsv - X_adj_drs.impairment_rsv;
  end if;

  -- Reval reserve adjustments
  if (X_adj_drs.reval_rsv <> 0) then
     X_dest_drs.reval_rsv := X_dest_drs.reval_rsv - X_adj_drs.reval_rsv;
  end if;

  -- Cost adjustments
  if (X_adj_drs.cost <> 0) then
     X_dest_drs.cost := X_dest_drs.cost + X_adj_drs.cost;
  end if;

  -- Addition-cost-to-clear adjustments
  if (X_adj_drs.add_cost_to_clear <> 0) then
     X_dest_drs.add_cost_to_clear := X_dest_drs.add_cost_to_clear +
                    X_adj_drs.add_cost_to_clear;
  end if;

  X_success := TRUE;

EXCEPTION
  when others then
       fa_srvr_msg.add_sql_error(calling_fn => 'ADD_ADJ_TO_DEPRN', p_log_level_rec => p_log_level_rec);
       fa_standard_pkg.raise_error(
          CALLED_FN  => 'ADD_ADJ_TO_DEPRN',
          CALLING_FN => X_CALLING_FN, p_log_level_rec => p_log_level_rec);

END ADD_ADJ_TO_DEPRN;


--------------------------------------------------------------------------------


PROCEDURE QUERY_BALANCES_INT(
     X_DPR_ROW               IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
     X_RUN_MODE                     VARCHAR2,
     X_DEBUG                        BOOLEAN,
     X_SUCCESS                  OUT NOCOPY BOOLEAN,
     X_CALLING_FN                   VARCHAR2,
     X_TRANSACTION_HEADER_ID IN     NUMBER DEFAULT -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   IS


  h_found_per_ctr          number;
  h_is_acc_null            boolean;
  h_dpr_adjs               fa_std_types.fa_deprn_row_struct;
  h_success                boolean;
  h_count                  number;
  h_mrc_sob_type_code      varchar2(1);

  h_mesg_name              varchar2(30);
  bad_mode                 exception;
  bad_trx_id               exception;
  sob_cache_error          exception;

BEGIN

  h_mesg_name := 'FA_WHATIF_ASSET_QUERY_BAL';

  X_success := FALSE;
  h_is_acc_null := FALSE;

  if (X_RUN_MODE not in ('STANDARD','ADJUSTED','DEPRN',
          'TRANSACTION','INVALID')) then
    raise bad_mode;
  end if;


  -- If running in TRANSACTION mode, then
  -- set period_ctr to whichever period the transaction occurred.

  if (X_run_mode = 'TRANSACTION') then

    h_mesg_name := 'FA_POST_SQL_PC';

    select dp.period_counter-1,
           count(*)
      into X_dpr_row.period_ctr,
           h_count
      from fa_deprn_periods dp,
           fa_transaction_headers th
     where dp.book_type_code = X_dpr_row.book
       and th.date_effective between
             dp.period_open_date and
             nvl(dp.period_close_date,to_date('31-12-4712','DD-MM-YYYY'))
       and th.transaction_header_id = X_transaction_header_id
     group by dp.period_counter-1;

    h_mesg_name := 'FA_WHATIF_ASSET_QUERY_BAL';

  end if;

  if h_count=0 then raise bad_trx_id;  end if;

  -- If dist_id is given, then query that distribution only...
  -- Query from fa_deprn_detail.
  -- If dist_id is 0, then query at summary level: fa_deprn_summary.

  if (X_dpr_row.dist_id <> 0) then

    QUERY_DEPRN_DETAIL
              (X_DPR_ROW        => X_dpr_row,
               X_FOUND_PER_CTR  => h_found_per_ctr,
               X_IS_ACC_NULL    => h_is_acc_null,
               X_RUN_MODE       => X_run_mode,
               X_SUCCESS        => h_success,
               X_CALLING_FN     =>'QUERY_BALANCES_INT',
               p_log_level_rec  => p_log_level_rec);

    -- If querying current period, or if period indicated does not have
    -- deprn rows, or if querying from TAX book, then unaccounted adjustments
    -- may exist... We need to add these to information from deprn rows.

    if (h_found_per_ctr = 0  OR
        h_found_per_ctr <> X_dpr_row.period_ctr  OR
        X_run_mode in ('ADJUSTED','TRANSACTION')) then

       h_dpr_adjs.asset_id := X_dpr_row.asset_id;
       h_dpr_adjs.book := X_dpr_row.book;
       h_dpr_adjs.mrc_sob_type_code := X_dpr_row.mrc_sob_type_code;
       h_dpr_adjs.set_of_books_id := X_dpr_row.set_of_books_id;

       if (X_run_mode = 'TRANSACTION') then
          h_dpr_adjs.period_ctr := X_dpr_row.period_ctr + 1;
       else
          h_dpr_adjs.period_ctr := X_dpr_row.period_ctr;
       end if;

       h_dpr_adjs.dist_id := X_dpr_row.dist_id;

       -- Get adjustments info
       GET_ADJUSTMENTS_INFO
                 (X_ADJ_ROW               => h_dpr_adjs,
                  X_FOUND_PER_CTR         => h_found_per_ctr,
                  X_RUN_MODE              => X_run_mode,
                  X_TRANSACTION_HEADER_ID => X_transaction_header_id,
                  X_SUCCESS               => h_success,
                  X_CALLING_FN            => 'QUERY_BALANCES_INT',
                  p_log_level_rec         => p_log_level_rec);

    end if;

  elsif (X_dpr_row.dist_id = 0) then

    h_mrc_sob_type_code := X_dpr_row.mrc_sob_type_code;

    -- Query at summary level
    QUERY_DEPRN_SUMMARY
              (X_DPR_ROW        => X_dpr_row,
               X_FOUND_PER_CTR  => h_found_per_ctr,
               X_RUN_MODE       => X_run_mode,
               X_SUCCESS        => h_success,
               X_CALLING_FN     => 'QUERY_BALANCES_INT',
               p_log_level_rec  => p_log_level_rec);

    -- If given period has no deprn row, or if querying TAX book,
    -- then need to check for adjustments and add to info from deprn rows.

    if (X_dpr_row.period_ctr <> h_found_per_ctr  OR
       X_run_mode in ('ADJUSTED','TRANSACTION')) then

       h_dpr_adjs.asset_id := X_dpr_row.asset_id;
       h_dpr_adjs.book := X_dpr_row.book;
       h_dpr_adjs.mrc_sob_type_code := X_dpr_row.mrc_sob_type_code;
       h_dpr_adjs.set_of_books_id := X_dpr_row.set_of_books_id;

       if (X_run_mode = 'TRANSACTION') then
          h_dpr_adjs.period_ctr := X_dpr_row.period_ctr + 1;
       else
          h_dpr_adjs.period_ctr := X_dpr_row.period_ctr;
       end if;
       h_dpr_adjs.dist_id := X_dpr_row.dist_id;

       h_dpr_adjs.asset_type := X_dpr_row.asset_type;
       h_dpr_adjs.member_rollup_flag := X_dpr_row.member_rollup_flag;

       GET_ADJUSTMENTS_INFO
                 (X_ADJ_ROW               => h_dpr_adjs,
                  X_FOUND_PER_CTR         => h_found_per_ctr,
                  X_RUN_MODE              => X_run_mode,
                  X_TRANSACTION_HEADER_ID => X_transaction_header_id,
                  X_SUCCESS               => h_success,
                  X_CALLING_FN            => 'QUERY_BALANCES_INT',
                  p_log_level_rec         => p_log_level_rec);

    end if;
  end if;

  -- now add the detail/summary structure values to the adjustments
  add_adj_to_deprn
             (X_ADJ_DRS    => h_dpr_adjs,
              X_DEST_DRS   => X_dpr_row,
              X_SUCCESS    => h_success,
              X_CALLING_FN =>'QUERY_BALANCES_INT',
              p_log_level_rec  => p_log_level_rec);


  -- Indicate whether cost has been cleared or not.
  if (h_is_acc_null) then
     X_dpr_row.add_cost_to_clear := 0;
  end if;

  -- Give period of the info returned (useful if we asked for
  -- current period.
  X_dpr_row.period_ctr := h_found_per_ctr;

  -- Indicate if any adjustments were found that had to be added to
  -- info from deprn rows.
  X_dpr_row.adjusted_flag := h_dpr_adjs.adjusted_flag;

  X_success := TRUE;

EXCEPTION
  when bad_mode then
       fa_standard_pkg.raise_error(
          CALLED_FN  =>'QUERY_BALANCES_INT',
          CALLING_FN => X_CALLING_FN,
          NAME       => 'FA_QADD_INVALID_MODE', p_log_level_rec => p_log_level_rec);

  when bad_trx_id then
       fa_standard_pkg.raise_error(
          CALLED_FN  =>'QUERY_BALANCES_INT',
          CALLING_FN => X_CALLING_FN,
          NAME       => 'FA_QADD_INVALID_TRXID', p_log_level_rec => p_log_level_rec);

  when sob_cache_error then
       fa_srvr_msg.add_sql_error
         (calling_fn => 'fa_query_balances_pkg.query_balances_int', p_log_level_rec => p_log_level_rec);
       fa_standard_pkg.raise_error(
          CALLED_FN  =>'QUERY_BALANCES_INT',
          CALLING_FN => X_CALLING_FN,
          NAME       => 'FA_QADD_INVALID_TRXID', p_log_level_rec => p_log_level_rec);

  when others then
       if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD (
             fname     => 'FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT',
             element   => 'DIST_ID',
             value     => X_DPR_ROW.DIST_ID, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
             fname     => 'FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT',
             element   => 'PERIOD_CTR',
             value     => X_DPR_ROW.PERIOD_CTR, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
             fname     => 'FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT',
             element   => 'RUN_MODE',
             value     => X_RUN_MODE, p_log_level_rec => p_log_level_rec);
       end if;
       fa_srvr_msg.add_sql_error(calling_fn => 'QUERY_BALANCES_INT', p_log_level_rec => p_log_level_rec);
       if h_mesg_name = 'FA_WHATIF_ASSET_QUERY_BAL' then
          fa_srvr_msg.add_message
            (calling_fn => 'QUERY_BALANCES_INT',
             name       => h_mesg_name,
             token1     => 'ASSET_ID',
             value1     => to_char(X_dpr_row.asset_id),
             p_log_level_rec => p_log_level_rec);
       else
          fa_srvr_msg.add_message
            (calling_fn => 'QUERY_BALANCES_INT',
             name       => h_mesg_name, p_log_level_rec => p_log_level_rec);
       end if;
       fa_standard_pkg.raise_error(
          CALLED_FN     =>'QUERY_BALANCES_INT',
          CALLING_FN    => X_CALLING_FN,
          NAME          => h_mesg_name, p_log_level_rec => p_log_level_rec);

END QUERY_BALANCES_INT;

-----------------------------------------------------------------------------

-- This procedure gets info related to the current period:
-- period counter, fiscal year, and number of periods in fiscal year

PROCEDURE GET_PERIOD_INFO (
                 X_BOOK                VARCHAR2,
                 X_CUR_PER_CTR  IN OUT NOCOPY NUMBER,
                 X_CUR_FY       IN OUT NOCOPY NUMBER,
                 X_NUM_PERS_FY  IN OUT NOCOPY NUMBER,
                 X_SUCCESS         OUT NOCOPY BOOLEAN,
                 X_CALLING_FN          VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

   error_found  exception;

BEGIN

  X_SUCCESS := FALSE;

  -- select period counter, number of periods
  -- per fiscal year, and the current fiscal year

  X_CUR_PER_CTR := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
  X_CUR_FY      := fa_cache_pkg.fazcbc_record.current_fiscal_year;

  if not fa_cache_pkg.fazcct
         (X_calendar => fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
     raise error_found;
  end if;

  X_NUM_PERS_FY := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
  X_SUCCESS := TRUE;

EXCEPTION
  when error_found then
       fa_srvr_msg.add_sql_error(
          calling_fn => 'FA_QUERY_BALANCES_PKG.GET_PERIOD_INFO', p_log_level_rec => p_log_level_rec);
       fa_srvr_msg.add_message(
          calling_fn => 'FA_QUERY_BALANCES_PKG.GET_PERIOD_INFO',
          name       => 'FA_EXP_GET_CUR_PERIOD_INFO', p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR (
          CALLED_FN  => 'fa_query_balances_pkg.get_period_info',
          CALLING_FN => X_CALLING_FN, p_log_level_rec => p_log_level_rec);
  when others then
       if (p_log_level_rec.statement_level) then
           FA_DEBUG_PKG.ADD (
              fname   =>'FA_QUERY_BALANCES_PKG.GET_PERIOD_INFO',
              element =>'CUR_PER_CTR',
              value   =>X_CUR_PER_CTR, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
              fname   =>'FA_QUERY_BALANCES_PKG.GET_PERIOD_INFO',
              element => 'NUM_PERS_FY',
              value   => X_NUM_PERS_FY, p_log_level_rec => p_log_level_rec);
       end if;

       fa_srvr_msg.add_sql_error(
          calling_fn => 'FA_QUERY_BALANCES_PKG.GET_PERIOD_INFO', p_log_level_rec => p_log_level_rec);
       fa_srvr_msg.add_message(
          calling_fn => 'FA_QUERY_BALANCES_PKG.GET_PERIOD_INFO',
          name       => 'FA_EXP_GET_CUR_PERIOD_INFO', p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR (
          CALLED_FN  => 'fa_query_balances_pkg.get_period_info',
          CALLING_FN => X_CALLING_FN, p_log_level_rec => p_log_level_rec);

END GET_PERIOD_INFO;

-------------------------------------------------------------------------------------

-- Use this procedure to query summary-level information
-- from fa_deprn_summary in given period (or current period if 0)


PROCEDURE QUERY_DEPRN_SUMMARY (
                 X_DPR_ROW       IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_FOUND_PER_CTR IN OUT NOCOPY NUMBER,
                 X_RUN_MODE             VARCHAR2,
                 X_SUCCESS          OUT NOCOPY BOOLEAN,
                 X_CALLING_FN           VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

  h_cur_per_ctr          number;
  h_num_pers_fy          number;
  h_cur_fy               number;
  h_fy                   number;
  h_period_counter       number;
  h_is_acc_null_num      number;
  h_proc_success         boolean;

  h_mesg_name            varchar2(30);


  -- Main select statement.  Get summary-level info for most recent period
  -- at or before given period.
  -- If RUN_MODE = 'DEPRN', return 0 for deprn_amount, reval_deprn_expense,
  -- and reval_amortization.  Also decrement period counter tto get last
  -- period's info (used in depreciation program).

  CURSOR GET_MC_DS IS
         SELECT 0,
                DEPRN_RESERVE,
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, DEPRN_AMOUNT,
                               0)),
                NVL(REVAL_RESERVE, 0),
                DECODE (FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                        h_fy, YTD_DEPRN,
                        0),
                DECODE (FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                        h_fy, NVL(YTD_REVAL_DEPRN_EXPENSE, 0),
                        0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_DEPRN_EXPENSE, 0),
                               0)),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_AMORTIZATION, 0),
                               0)),
                NVL(BONUS_DEPRN_RESERVE,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, BONUS_YTD_DEPRN,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, BONUS_DEPRN_AMOUNT,
                               0)),
                NVL(impairment_reserve,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_IMPAIRMENT,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, IMPAIRMENT_AMOUNT,
                               0)),
                PERIOD_COUNTER,
                NVL(PRODUCTION, 0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_PRODUCTION, 0),
                       0),
                NVL(LTD_PRODUCTION, 0),
                ADJUSTED_COST,
                NVL(REVAL_AMORTIZATION_BASIS, 0),
                NVL(BONUS_RATE, 0),
                DEPRN_SOURCE_CODE,
                0,
                NVL(PRIOR_FY_EXPENSE, 0),
                NVL(PRIOR_FY_BONUS_EXPENSE, 0),
                NVL(CAPITAL_ADJUSTMENT,0), --Bug 6666666
                NVL(GENERAL_FUND,0)        --Bug 6666666
           FROM FA_MC_DEPRN_SUMMARY DS
          WHERE DS.ASSET_ID             =  X_dpr_row.asset_id
            AND DS.BOOK_TYPE_CODE       =  X_dpr_row.book
            AND DS.PERIOD_COUNTER      <= h_period_counter
            AND DS.SET_OF_BOOKS_ID      =  X_dpr_row.set_of_books_id
         ORDER BY PERIOD_COUNTER DESC;


  CURSOR GET_DS IS
         SELECT 0,
                DEPRN_RESERVE,
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, DEPRN_AMOUNT,
                               0)),
                NVL(REVAL_RESERVE, 0),
/* Bug# 6353715     DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_DEPRN,
                       0),*/
                DECODE(FLOOR(
                       DECODE(deprn_source_code
                             ,'BOOKS',PERIOD_COUNTER
                                     , (PERIOD_COUNTER - 1))/ h_num_pers_fy),
                       h_fy, YTD_DEPRN,
                       0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_REVAL_DEPRN_EXPENSE, 0),
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_DEPRN_EXPENSE, 0),
                               0)),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_AMORTIZATION, 0),
                               0)),
                NVL(BONUS_DEPRN_RESERVE,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, BONUS_YTD_DEPRN,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, BONUS_DEPRN_AMOUNT,
                               0)),
                NVL(impairment_reserve,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_IMPAIRMENT,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, IMPAIRMENT_AMOUNT,
                               0)),
                PERIOD_COUNTER,
                NVL(PRODUCTION, 0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_PRODUCTION, 0),
                       0),
                NVL(LTD_PRODUCTION, 0),
                ADJUSTED_COST,
                NVL(REVAL_AMORTIZATION_BASIS, 0),
                NVL(BONUS_RATE, 0),
                DEPRN_SOURCE_CODE,
                0,
                NVL(PRIOR_FY_EXPENSE, 0),
                NVL(PRIOR_FY_BONUS_EXPENSE, 0),
                NVL(CAPITAL_ADJUSTMENT,0), --Bug 6666666
                NVL(GENERAL_FUND,0)        --Bug 6666666
           FROM FA_DEPRN_SUMMARY DS
          WHERE DS.ASSET_ID             =  X_dpr_row.asset_id
            AND DS.BOOK_TYPE_CODE       =  X_dpr_row.book
            AND DS.PERIOD_COUNTER       <= h_period_counter
         ORDER BY PERIOD_COUNTER DESC;


  -- for Sumup Assets
  CURSOR GET_MC_DM IS
         SELECT 0,
                sum(DEPRN_RESERVE),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, DEPRN_AMOUNT,
                               0))),
                sum(NVL(REVAL_RESERVE, 0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_DEPRN,
                       0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_REVAL_DEPRN_EXPENSE, 0),
                       0)),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_DEPRN_EXPENSE, 0),
                               0))),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_AMORTIZATION, 0),
                               0))),
                sum(NVL(BONUS_DEPRN_RESERVE,0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, BONUS_YTD_DEPRN,
                       0)),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, BONUS_DEPRN_AMOUNT,
                               0))),
                sum(NVL(impairment_reserve,0)),       -- bug 5951733 (added sum function)
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy), -- bug 5951733 (added sum function)
                       h_fy, YTD_IMPAIRMENT,
                       0)),
                sum(decode (X_RUN_MODE,               -- bug 5951733 (added sum function)
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, IMPAIRMENT_AMOUNT,
                               0))),
                max(PERIOD_COUNTER), -- Bug#6350172
                sum(NVL(PRODUCTION, 0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_PRODUCTION, 0),
                       0)),
                sum(NVL(LTD_PRODUCTION, 0)),
                sum(ADJUSTED_COST),
                sum(NVL(REVAL_AMORTIZATION_BASIS, 0)),
                sum(NVL(BONUS_RATE, 0)),
                'DEPRN' DEPRN_SOURCE_CODE,
                0,
                sum(NVL(PRIOR_FY_EXPENSE, 0)),
                sum(NVL(PRIOR_FY_BONUS_EXPENSE, 0)),
                sum(NVL(CAPITAL_ADJUSTMENT,0)), --Bug 6666666
                sum(NVL(GENERAL_FUND,0))        --Bug 6666666
           FROM FA_MC_DEPRN_SUMMARY DS
          WHERE DS.ASSET_ID             in (select bk.asset_id
                                            from   fa_books bk
                                            where bk.book_type_code = x_dpr_row.book
                                            and   bk.transaction_header_id_out is null
                                            and    bk.group_asset_id = x_dpr_row.asset_id)
            AND DS.BOOK_TYPE_CODE       =  X_dpr_row.book
            AND DS.SET_OF_BOOKS_ID      =  X_dpr_row.set_of_books_id
            -- Bug#6350172: Modified query to fetch correct reserve values
            AND DS.PERIOD_COUNTER = ( select max(period_counter) from fa_mc_deprn_summary
                                      where asset_id = ds.asset_id
                                      and book_type_code = X_dpr_row.book
                                      and set_of_books_id = X_dpr_row.set_of_books_id);

  -- for Sumup Assets
  CURSOR GET_DM IS
         SELECT 0,
                sum(DEPRN_RESERVE),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, DEPRN_AMOUNT,
                               0))),
                sum(NVL(REVAL_RESERVE, 0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_DEPRN,
                       0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_REVAL_DEPRN_EXPENSE, 0),
                       0)),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_DEPRN_EXPENSE, 0),
                               0))),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_AMORTIZATION, 0),
                               0))),
                sum(NVL(BONUS_DEPRN_RESERVE,0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, BONUS_YTD_DEPRN,
                       0)),
                sum(decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, BONUS_DEPRN_AMOUNT,
                               0))),
                sum(NVL(impairment_reserve,0)),         -- bug 5951733 (added sum function)
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),    -- bug 5951733 (added sum function)
                       h_fy, YTD_IMPAIRMENT,
                       0)),
                sum(decode (X_RUN_MODE,            -- bug 5951733 (added sum function)
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, IMPAIRMENT_AMOUNT,
                               0))),
                max(PERIOD_COUNTER), -- Bug#6350172
                sum(NVL(PRODUCTION, 0)),
                sum(DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_PRODUCTION, 0),
                       0)),
                sum(NVL(LTD_PRODUCTION, 0)),
                sum(ADJUSTED_COST),
                sum(NVL(REVAL_AMORTIZATION_BASIS, 0)),
                sum(NVL(BONUS_RATE, 0)),
                'DEPRN' DEPRN_SOURCE_CODE,
                0,
                sum(NVL(PRIOR_FY_EXPENSE, 0)),
                sum(NVL(PRIOR_FY_BONUS_EXPENSE, 0)),
                sum(NVL(CAPITAL_ADJUSTMENT,0)), --Bug 6666666
                sum(NVL(GENERAL_FUND,0))        --Bug 6666666
           FROM FA_DEPRN_SUMMARY DS
          WHERE DS.ASSET_ID             in (select bk.asset_id
                                            from   fa_books bk
                                            where bk.book_type_code = x_dpr_row.book
                                            and   bk.transaction_header_id_out is null
                                            and    bk.group_asset_id = x_dpr_row.asset_id)
            AND DS.BOOK_TYPE_CODE       =  X_dpr_row.book
            -- Bug#6350172: Modified query to fetch correct reserve values
            AND DS.PERIOD_COUNTER = ( select max(period_counter) from fa_deprn_summary
                                      where asset_id = ds.asset_id and book_type_code = X_dpr_row.book );


BEGIN

  X_success := FALSE;

  -- Get the current period's counter, fiscal year, number of periods
  -- in fiscal year.

  h_mesg_name := 'FA_EXP_GET_CUR_PERIOD_INFO';

  get_period_info(
     X_BOOK        => X_DPR_ROW.BOOK,
     X_CUR_PER_CTR => h_cur_per_ctr,
     X_CUR_FY      => h_cur_fy,
     X_NUM_PERS_FY => h_num_pers_fy,
     X_SUCCESS     => h_proc_success,
     X_CALLING_FN  => 'QUERY_DEPRN_DETAIL',
     p_log_level_rec  => p_log_level_rec);


  -- Determine current period_counter given RUN_MODE and
  -- period_ctr given in X_DPR_ROW

  -- If running in DEPRN mode,
  -- decrement period counter to get LAST period's
  -- info.

  if (X_RUN_MODE in ('DEPRN')) then
     h_period_counter := h_cur_per_ctr - 1;
     h_fy := h_cur_fy;

  -- If period counter not given, set to current period.
  elsif (X_dpr_row.period_ctr = 0) then
     h_period_counter := h_cur_per_ctr;
     h_fy := h_cur_fy;

  -- If period counter given AND not DEPRN mode, then
  -- need to reselect fiscal year.
  else
     h_period_counter := X_dpr_row.period_ctr;
     h_mesg_name := 'FA_PURGE_GET_FISCAL_YEAR';
--bugfix 3666915 starts
     begin
         select fiscal_year
         into h_fy
         from fa_deprn_periods
         where book_type_code = X_dpr_row.book
               and period_counter = h_period_counter;
         Exception
            when no_data_found then
                 null;
     end;
--bugfix 3666915 ends
  end if;


  -- Retrieve row that matches current period counter.
  -- If such a row doesn't exist, then get row that
  -- matches most recent period counter.

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  if (X_dpr_row.asset_type = 'GROUP' and
      X_dpr_row.member_rollup_flag = 'Y') then
     -- for Sumup Assets
     if (x_dpr_row.mrc_sob_type_code  = 'R') then
       OPEN GET_MC_DM;
     else
       OPEN GET_DM;
     end if;
  else -- non sumup assets
     if (x_dpr_row.mrc_sob_type_code  = 'R') then
       OPEN GET_MC_DS;
     else
       OPEN GET_DS;
     end if;
  end if;


  h_mesg_name := 'FA_DEPRN_SQL_FCUR';

  if (X_dpr_row.asset_type = 'GROUP' and
      X_dpr_row.member_rollup_flag = 'Y') then
     -- for Sumup Assets
     if (x_dpr_row.mrc_sob_type_code  = 'R') then
        FETCH GET_MC_DM INTO
                 X_dpr_row.cost,
                 X_dpr_row.deprn_rsv,
                 X_dpr_row.deprn_exp,
                 X_dpr_row.reval_rsv,
                 X_dpr_row.ytd_deprn,
                 X_dpr_row.ytd_reval_deprn_exp,
                 X_dpr_row.reval_deprn_exp,
                 X_dpr_row.reval_amo,
                 X_dpr_row.bonus_deprn_rsv,
                 X_dpr_row.bonus_ytd_deprn,
                 X_dpr_row.bonus_deprn_amount,
                 X_dpr_row.impairment_rsv,
                 X_dpr_row.ytd_impairment,
                 X_dpr_row.impairment_amount,
                 X_found_per_ctr,
                 X_dpr_row.prod,
                 X_dpr_row.ytd_prod,
                 X_dpr_row.ltd_prod,
                 X_dpr_row.adj_cost,
                 X_dpr_row.reval_amo_basis,
                 X_dpr_row.bonus_rate,
                 X_dpr_row.deprn_source_code,
                 X_dpr_row.add_cost_to_clear,
                 X_dpr_row.prior_fy_exp,
                 X_dpr_row.prior_fy_bonus_exp,
                 X_dpr_row.capital_adjustment, -- Bug 6666666
                 X_dpr_row.general_fund;       -- Bug 6666666

        if (GET_MC_DM%NOTFOUND) then

           X_dpr_row.cost := 0;
           X_dpr_row.deprn_rsv := 0;
           X_dpr_row.deprn_exp := 0;
           X_dpr_row.reval_rsv := 0;
           X_dpr_row.ytd_deprn := 0;
           X_dpr_row.ytd_reval_deprn_exp := 0;
           X_dpr_row.reval_deprn_exp := 0;
           X_dpr_row.reval_amo := 0;
           X_dpr_row.bonus_deprn_rsv := 0;
           X_dpr_row.bonus_ytd_deprn := 0;
           X_dpr_row.bonus_deprn_amount := 0;
           X_dpr_row.impairment_rsv := 0;
           X_dpr_row.ytd_impairment := 0;
           X_dpr_row.impairment_amount := 0;
           X_dpr_row.add_cost_to_clear := 0;
           X_found_per_ctr := 0;
           X_dpr_row.prod := 0;
           X_dpr_row.ytd_prod := 0;
           X_dpr_row.ltd_prod := 0;
           X_dpr_row.adj_cost := 0;
           X_dpr_row.reval_amo_basis := 0;
           X_dpr_row.bonus_rate := 0;
           X_dpr_row.deprn_source_code := '';
           X_dpr_row.prior_fy_exp := 0;
           X_dpr_row.prior_fy_bonus_exp := 0;
           X_dpr_row.capital_adjustment := 0; -- Bug 6666666
           X_dpr_row.general_fund       := 0; -- Bug 6666666

        end if;

     else
        FETCH GET_DM INTO
                 X_dpr_row.cost,
                 X_dpr_row.deprn_rsv,
                 X_dpr_row.deprn_exp,
                 X_dpr_row.reval_rsv,
                 X_dpr_row.ytd_deprn,
                 X_dpr_row.ytd_reval_deprn_exp,
                 X_dpr_row.reval_deprn_exp,
                 X_dpr_row.reval_amo,
                 X_dpr_row.bonus_deprn_rsv,
                 X_dpr_row.bonus_ytd_deprn,
                 X_dpr_row.bonus_deprn_amount,
                 X_dpr_row.impairment_rsv,
                 X_dpr_row.ytd_impairment,
                 X_dpr_row.impairment_amount,
                 X_found_per_ctr,
                 X_dpr_row.prod,
                 X_dpr_row.ytd_prod,
                 X_dpr_row.ltd_prod,
                 X_dpr_row.adj_cost,
                 X_dpr_row.reval_amo_basis,
                 X_dpr_row.bonus_rate,
                 X_dpr_row.deprn_source_code,
                 X_dpr_row.add_cost_to_clear,
                 X_dpr_row.prior_fy_exp,
                 X_dpr_row.prior_fy_bonus_exp,
                 X_dpr_row.capital_adjustment, -- Bug 6666666
                 X_dpr_row.general_fund;       -- Bug 6666666


        -- If no fa_deprn_summary row exists, then return all zeroes.

        if (GET_DM%NOTFOUND) then

           X_dpr_row.cost := 0;
           X_dpr_row.deprn_rsv := 0;
           X_dpr_row.deprn_exp := 0;
           X_dpr_row.reval_rsv := 0;
           X_dpr_row.ytd_deprn := 0;
           X_dpr_row.ytd_reval_deprn_exp := 0;
           X_dpr_row.reval_deprn_exp := 0;
           X_dpr_row.reval_amo := 0;
           X_dpr_row.bonus_deprn_rsv := 0;
           X_dpr_row.bonus_ytd_deprn := 0;
           X_dpr_row.bonus_deprn_amount := 0;
           X_dpr_row.impairment_rsv := 0;
           X_dpr_row.ytd_impairment := 0;
           X_dpr_row.impairment_amount := 0;
           X_dpr_row.add_cost_to_clear := 0;
           X_found_per_ctr := 0;
           X_dpr_row.prod := 0;
           X_dpr_row.ytd_prod := 0;
           X_dpr_row.ltd_prod := 0;
           X_dpr_row.adj_cost := 0;
           X_dpr_row.reval_amo_basis := 0;
           X_dpr_row.bonus_rate := 0;
           X_dpr_row.deprn_source_code := '';
           X_dpr_row.prior_fy_exp := 0;
           X_dpr_row.prior_fy_bonus_exp := 0;
           X_dpr_row.capital_adjustment := 0; -- Bug 6666666
           X_dpr_row.general_fund       := 0; -- Bug 6666666
        end if;

     end if;

  else -- Non Sumup assets
     if (x_dpr_row.mrc_sob_type_code  = 'R') then
        FETCH GET_MC_DS INTO
                 X_dpr_row.cost,
                 X_dpr_row.deprn_rsv,
                 X_dpr_row.deprn_exp,
                 X_dpr_row.reval_rsv,
                 X_dpr_row.ytd_deprn,
                 X_dpr_row.ytd_reval_deprn_exp,
                 X_dpr_row.reval_deprn_exp,
                 X_dpr_row.reval_amo,
                 X_dpr_row.bonus_deprn_rsv,
                 X_dpr_row.bonus_ytd_deprn,
                 X_dpr_row.bonus_deprn_amount,
                 X_dpr_row.impairment_rsv,
                 X_dpr_row.ytd_impairment,
                 X_dpr_row.impairment_amount,
                 X_found_per_ctr,
                 X_dpr_row.prod,
                 X_dpr_row.ytd_prod,
                 X_dpr_row.ltd_prod,
                 X_dpr_row.adj_cost,
                 X_dpr_row.reval_amo_basis,
                 X_dpr_row.bonus_rate,
                 X_dpr_row.deprn_source_code,
                 X_dpr_row.add_cost_to_clear,
                 X_dpr_row.prior_fy_exp,
                 X_dpr_row.prior_fy_bonus_exp,
                 X_dpr_row.capital_adjustment, -- Bug 6666666
                 X_dpr_row.general_fund;       -- Bug 6666666

        if (GET_MC_DS%NOTFOUND) then

           X_dpr_row.cost := 0;
           X_dpr_row.deprn_rsv := 0;
           X_dpr_row.deprn_exp := 0;
           X_dpr_row.reval_rsv := 0;
           X_dpr_row.ytd_deprn := 0;
           X_dpr_row.ytd_reval_deprn_exp := 0;
           X_dpr_row.reval_deprn_exp := 0;
           X_dpr_row.reval_amo := 0;
           X_dpr_row.bonus_deprn_rsv := 0;
           X_dpr_row.bonus_ytd_deprn := 0;
           X_dpr_row.bonus_deprn_amount := 0;
           X_dpr_row.impairment_rsv := 0;
           X_dpr_row.ytd_impairment := 0;
           X_dpr_row.impairment_amount := 0;
           X_dpr_row.add_cost_to_clear := 0;
           X_found_per_ctr := 0;
           X_dpr_row.prod := 0;
           X_dpr_row.ytd_prod := 0;
           X_dpr_row.ltd_prod := 0;
           X_dpr_row.adj_cost := 0;
           X_dpr_row.reval_amo_basis := 0;
           X_dpr_row.bonus_rate := 0;
           X_dpr_row.deprn_source_code := '';
           X_dpr_row.prior_fy_exp := 0;
           X_dpr_row.prior_fy_bonus_exp := 0;
           X_dpr_row.capital_adjustment := 0; -- Bug 6666666
           X_dpr_row.general_fund       := 0; -- Bug 6666666

        end if;

     else
        FETCH GET_DS INTO
                 X_dpr_row.cost,
                 X_dpr_row.deprn_rsv,
                 X_dpr_row.deprn_exp,
                 X_dpr_row.reval_rsv,
                 X_dpr_row.ytd_deprn,
                 X_dpr_row.ytd_reval_deprn_exp,
                 X_dpr_row.reval_deprn_exp,
                 X_dpr_row.reval_amo,
                 X_dpr_row.bonus_deprn_rsv,
                 X_dpr_row.bonus_ytd_deprn,
                 X_dpr_row.bonus_deprn_amount,
                 X_dpr_row.impairment_rsv,
                 X_dpr_row.ytd_impairment,
                 X_dpr_row.impairment_amount,
                 X_found_per_ctr,
                 X_dpr_row.prod,
                 X_dpr_row.ytd_prod,
                 X_dpr_row.ltd_prod,
                 X_dpr_row.adj_cost,
                 X_dpr_row.reval_amo_basis,
                 X_dpr_row.bonus_rate,
                 X_dpr_row.deprn_source_code,
                 X_dpr_row.add_cost_to_clear,
                 X_dpr_row.prior_fy_exp,
                 X_dpr_row.prior_fy_bonus_exp,
                 X_dpr_row.capital_adjustment, -- Bug 6666666
                 X_dpr_row.general_fund;       -- Bug 6666666

        -- If no fa_deprn_summary row exists, then return all zeroes.

        if (GET_DS%NOTFOUND) then

           X_dpr_row.cost := 0;
           X_dpr_row.deprn_rsv := 0;
           X_dpr_row.deprn_exp := 0;
           X_dpr_row.reval_rsv := 0;
           X_dpr_row.ytd_deprn := 0;
           X_dpr_row.ytd_reval_deprn_exp := 0;
           X_dpr_row.reval_deprn_exp := 0;
           X_dpr_row.reval_amo := 0;
           X_dpr_row.bonus_deprn_rsv := 0;
           X_dpr_row.bonus_ytd_deprn := 0;
           X_dpr_row.bonus_deprn_amount := 0;
           X_dpr_row.impairment_rsv := 0;
           X_dpr_row.ytd_impairment := 0;
           X_dpr_row.impairment_amount := 0;
           X_dpr_row.add_cost_to_clear := 0;
           X_found_per_ctr := 0;
           X_dpr_row.prod := 0;
           X_dpr_row.ytd_prod := 0;
           X_dpr_row.ltd_prod := 0;
           X_dpr_row.adj_cost := 0;
           X_dpr_row.reval_amo_basis := 0;
           X_dpr_row.bonus_rate := 0;
           X_dpr_row.deprn_source_code := '';
           X_dpr_row.prior_fy_exp := 0;
           X_dpr_row.prior_fy_bonus_exp := 0;
           X_dpr_row.capital_adjustment := 0; -- Bug 6666666
           X_dpr_row.general_fund       := 0; -- Bug 6666666

        end if;

     end if;

  end if; -- (X_dpr_row.asset_type = 'GROUP' and

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  if (X_dpr_row.asset_type = 'GROUP' and
      X_dpr_row.member_rollup_flag = 'Y') then
     if (x_dpr_row.mrc_sob_type_code  = 'R') then
        CLOSE GET_MC_DM;
     else
        CLOSE GET_DM;
     end if;
  else
     if (x_dpr_row.mrc_sob_type_code  = 'R') then
        CLOSE GET_MC_DS;
     else
        CLOSE GET_DS;
     end if;
  end if;

  X_success := TRUE;

EXCEPTION
  when others then
       if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD (
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_SUMMARY',
             element => 'ASSET_ID',
             value   => X_DPR_ROW.ASSET_ID, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_SUMMARY',
             element => 'BOOK',
             value   => X_DPR_ROW.BOOK, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_SUMMARY',
             element => 'h_cur_per_ctr',
             value   => h_cur_per_ctr, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
             fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_SUMMARY',
             element => 'RUN_MODE',
             value   => X_RUN_MODE, p_log_level_rec => p_log_level_rec);
        end if;

        fa_srvr_msg.add_sql_error(
           calling_fn => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_SUMMARY', p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_message(
           calling_fn => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_SUMMARY',
           name       => h_mesg_name, p_log_level_rec => p_log_level_rec);
        fa_standard_pkg.raise_error(
           CALLED_FN  => 'QUERY_DEPRN_SUMMARY',
           CALLING_FN => X_CALLING_FN,
           NAME       => h_mesg_name, p_log_level_rec => p_log_level_rec);


END QUERY_DEPRN_SUMMARY;

-----------------------------------------------------------------------

-- Use this procedure to query detail-level information
-- from fa_deprn_detail for given distribution
-- in given period (or current period if 0)


PROCEDURE QUERY_DEPRN_DETAIL (
                 X_DPR_ROW       IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_FOUND_PER_CTR IN OUT NOCOPY NUMBER,
                 X_IS_ACC_NULL   IN OUT NOCOPY BOOLEAN,
                 X_RUN_MODE             VARCHAR2,
                 X_SUCCESS          OUT NOCOPY BOOLEAN,
                 X_CALLING_FN           VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

  h_cur_per_ctr          number;
  h_num_pers_fy          number;
  h_cur_fy               number;
  h_fy                   number;
  h_period_counter       number;
  h_is_acc_null_num      number;
  h_proc_success         boolean;

  h_mesg_name              varchar2(30);


  -- Main select statement.  Get detail-level info for given distribution
  -- in most recent period at or before given period.
  -- If RUN_MODE = 'DEPRN', return 0 for deprn_amount, reval_deprn_expense,
  -- and reval_amortization.  Also decrement period counter tto get last
  -- period's info (used in depreciation program).

  CURSOR GET_MC_DD IS
         SELECT NVL(COST, 0),
                DEPRN_RESERVE,
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, DEPRN_AMOUNT,
                               0)),
                NVL(REVAL_RESERVE, 0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_DEPRN,
                       0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_REVAL_DEPRN_EXPENSE, 0),
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_DEPRN_EXPENSE, 0),
                               0)),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_AMORTIZATION, 0),
                               0)),
                NVL(BONUS_DEPRN_RESERVE,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, BONUS_YTD_DEPRN,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, BONUS_DEPRN_AMOUNT,
                               0)),
                NVL(impairment_reserve,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_IMPAIRMENT,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, IMPAIRMENT_AMOUNT,
                               0)),
                PERIOD_COUNTER,
                NVL(ADDITION_COST_TO_CLEAR, 0),
                DECODE(ADDITION_COST_TO_CLEAR,
                       NULL, 1,
                       0),
                NVL(CAPITAL_ADJUSTMENT,0),  -- Bug 6666666
                NVL(GENERAL_FUND,0)         -- Bug 6666666
           FROM FA_MC_DEPRN_DETAIL DD
          WHERE DD.ASSET_ID         = X_dpr_row.asset_id
            AND DD.BOOK_TYPE_CODE   = X_dpr_row.book
            AND DD.PERIOD_COUNTER  <= h_period_counter
            AND DD.DISTRIBUTION_ID  = X_dpr_row.dist_id
            AND DD.SET_OF_BOOKS_ID  = x_dpr_row.set_of_books_id
          ORDER BY PERIOD_COUNTER DESC;

  CURSOR GET_DD IS
         SELECT NVL(COST, 0),
                DEPRN_RESERVE,
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, DEPRN_AMOUNT,
                               0)),
                NVL(REVAL_RESERVE, 0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_DEPRN,
                       0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, NVL(YTD_REVAL_DEPRN_EXPENSE, 0),
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_DEPRN_EXPENSE, 0),
                               0)),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, NVL(REVAL_AMORTIZATION, 0),
                               0)),
                NVL(BONUS_DEPRN_RESERVE,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, BONUS_YTD_DEPRN,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, BONUS_DEPRN_AMOUNT,
                               0)),
                NVL(impairment_reserve,0),
                DECODE(FLOOR((PERIOD_COUNTER - 1) / h_num_pers_fy),
                       h_fy, YTD_IMPAIRMENT,
                       0),
                decode (X_RUN_MODE,
                        'DEPRN', 0,
                        DECODE(PERIOD_COUNTER,
                               h_period_counter, IMPAIRMENT_AMOUNT,
                               0)),
                PERIOD_COUNTER,
                NVL(ADDITION_COST_TO_CLEAR, 0),
                DECODE(ADDITION_COST_TO_CLEAR,
                       NULL, 1,
                       0),
                NVL(CAPITAL_ADJUSTMENT,0),  -- Bug 6666666
                NVL(GENERAL_FUND,0)         -- Bug 6666666
           FROM FA_DEPRN_DETAIL DD
          WHERE DD.ASSET_ID         = X_dpr_row.asset_id
            AND DD.BOOK_TYPE_CODE   = X_dpr_row.book
            AND DD.PERIOD_COUNTER  <= h_period_counter
            AND DD.DISTRIBUTION_ID  = X_dpr_row.dist_id
          ORDER BY PERIOD_COUNTER DESC;

BEGIN


  X_success := FALSE;

  -- Get all the period info

  -- Get the current period's counter, fiscal year, number of periods
  -- in fiscal year.

  h_mesg_name := 'FA_EXP_GET_CUR_PERIOD_INFO';

  get_period_info(
     X_BOOK        => X_DPR_ROW.BOOK,
     X_CUR_PER_CTR => h_cur_per_ctr,
     X_CUR_FY      => h_cur_fy,
     X_NUM_PERS_FY => h_num_pers_fy,
     X_SUCCESS     => h_proc_success,
     X_CALLING_FN  => 'QUERY_DEPRN_DETAIL',
     p_log_level_rec  => p_log_level_rec);

  -- Determine current period_counter given RUN_MODE and
  --  period_ctr given in X_DPR_ROW

  -- If running in DEPRN mode, decrement period counter to get LAST period
  -- info.

  if (X_RUN_MODE = 'DEPRN') then
     h_period_counter := h_cur_per_ctr - 1;
     h_fy := h_cur_fy;

  -- If period counter not given, set to current period.
  elsif (X_dpr_row.period_ctr = 0) then
     h_period_counter := h_cur_per_ctr;
     h_fy := h_cur_fy;

  -- If period counter given AND not DEPRN mode, then
  -- need to reselect fiscal year.
  else
     h_period_counter := X_dpr_row.period_ctr;
     h_mesg_name := 'FA_PURGE_GET_FISCAL_YEAR';
--bugfix 3666915 starts
     begin
         select fiscal_year
         into h_fy
         from fa_deprn_periods
         where book_type_code = X_dpr_row.book
               and period_counter = h_period_counter;
         Exception
            when no_data_found then
                 null;
     end;
--bugfix 3666915 ends

  end if;

  -- Retrieve row that matches current period counter.
  -- If such a row doesn't exist, then get row that
  -- matches most recent period counter.

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  if (x_dpr_row.mrc_sob_type_code  = 'R') then
     OPEN GET_MC_DD;
  else
     OPEN GET_DD;
  end if;

  h_mesg_name := 'FA_DEPRN_SQL_FCUR';

  if (x_dpr_row.mrc_sob_type_code = 'R') then
     FETCH GET_MC_DD INTO
              X_dpr_row.cost,
              X_dpr_row.deprn_rsv,
              X_dpr_row.deprn_exp,
              X_dpr_row.reval_rsv,
              X_dpr_row.ytd_deprn,
              X_dpr_row.ytd_reval_deprn_exp,
              X_dpr_row.reval_deprn_exp,
              X_dpr_row.reval_amo,
              X_dpr_row.bonus_deprn_rsv,
              X_dpr_row.bonus_ytd_deprn,
              X_dpr_row.bonus_deprn_amount,
              X_dpr_row.impairment_rsv,
              X_dpr_row.ytd_impairment,
              X_dpr_row.impairment_amount,
              X_found_per_ctr,
              X_dpr_row.add_cost_to_clear,
              h_is_acc_null_num,
              X_dpr_row.capital_adjustment, -- Bug 6666666
              X_dpr_row.general_fund;       -- Bug 6666666

     -- If no fa_deprn_summary row exists, then return all zeroes.

     if (GET_MC_DD%NOTFOUND) then
        X_dpr_row.cost := 0;
        X_dpr_row.deprn_rsv := 0;
        X_dpr_row.deprn_exp := 0;
        X_dpr_row.reval_rsv := 0;
        X_dpr_row.ytd_deprn := 0;
        X_dpr_row.ytd_reval_deprn_exp := 0;
        X_dpr_row.reval_deprn_exp := 0;
        X_dpr_row.reval_amo := 0;
        X_dpr_row.bonus_deprn_rsv := 0;
        X_dpr_row.bonus_ytd_deprn := 0;
        X_dpr_row.bonus_deprn_amount := 0;
        X_dpr_row.impairment_rsv := 0;
        X_dpr_row.ytd_impairment := 0;
        X_dpr_row.impairment_amount := 0;
        X_dpr_row.add_cost_to_clear := 0;
        X_found_per_ctr := 0;
        X_is_acc_null := TRUE;
        X_dpr_row.capital_adjustment := 0; -- Bug 6666666
        X_dpr_row.general_fund := 0;       -- Bug 6666666
     end if;

  else
     FETCH GET_DD INTO
              X_dpr_row.cost,
              X_dpr_row.deprn_rsv,
              X_dpr_row.deprn_exp,
              X_dpr_row.reval_rsv,
              X_dpr_row.ytd_deprn,
              X_dpr_row.ytd_reval_deprn_exp,
              X_dpr_row.reval_deprn_exp,
              X_dpr_row.reval_amo,
              X_dpr_row.bonus_deprn_rsv,
              X_dpr_row.bonus_ytd_deprn,
              X_dpr_row.bonus_deprn_amount,
              X_dpr_row.impairment_rsv,
              X_dpr_row.ytd_impairment,
              X_dpr_row.impairment_amount,
              X_found_per_ctr,
              X_dpr_row.add_cost_to_clear,
              h_is_acc_null_num,
              X_dpr_row.capital_adjustment, -- Bug 6666666
              X_dpr_row.general_fund;       -- Bug 6666666

     -- If no fa_deprn_summary row exists, then return all zeroes.

     if (GET_DD%NOTFOUND) then
        X_dpr_row.cost := 0;
        X_dpr_row.deprn_rsv := 0;
        X_dpr_row.deprn_exp := 0;
        X_dpr_row.reval_rsv := 0;
        X_dpr_row.ytd_deprn := 0;
        X_dpr_row.ytd_reval_deprn_exp := 0;
        X_dpr_row.reval_deprn_exp := 0;
        X_dpr_row.reval_amo := 0;
        X_dpr_row.bonus_deprn_rsv := 0;
        X_dpr_row.bonus_ytd_deprn := 0;
        X_dpr_row.bonus_deprn_amount := 0;
        X_dpr_row.impairment_rsv := 0;
        X_dpr_row.ytd_impairment := 0;
        X_dpr_row.impairment_amount := 0;
        X_dpr_row.add_cost_to_clear := 0;
        X_found_per_ctr := 0;
        X_is_acc_null := TRUE;
        X_dpr_row.capital_adjustment := 0;  -- Bug 6666666
        X_dpr_row.general_fund := 0;        -- Bug 6666666
     end if;
  end if;


  h_mesg_name := 'FA_DEPRN_SQL_CCUR';
  if (x_dpr_row.mrc_sob_type_code  = 'R') then
     CLOSE GET_MC_DD;
  else
     CLOSE GET_DD;
  end if;

  -- Return zeroes for production, adjusted_cost, reval_amo_basis,
  -- and bonus rate, as this info is kept at summary level only.

  X_dpr_row.prod := 0;
  X_dpr_row.ytd_prod := 0;
  X_dpr_row.ltd_prod := 0;
  X_dpr_row.adj_cost := 0;
  X_dpr_row.reval_amo_basis := 0;
  X_dpr_row.bonus_rate := 0;
  X_dpr_row.deprn_source_code := '';

  -- Indicate whether cost has been cleared.
  -- (is_acc_null = TRUE indicates that cost has been cleared)

  if (not(X_is_acc_null) and h_is_acc_null_num = 1) then
     X_is_acc_null := TRUE;
  else
     X_is_acc_null := FALSE;
  end if;

  X_success := TRUE;

EXCEPTION
  when others then
       if (p_log_level_rec.statement_level) then
          FA_DEBUG_PKG.ADD (
              fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_DETAIL',
              element => 'ASSET_ID',
              value   => X_DPR_ROW.ASSET_ID, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
              fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_DETAIL',
              element => 'BOOK',
              value   => X_DPR_ROW.BOOK, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
              fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_DETAIL',
              element => 'h_cur_per_ctr',
              value   => h_cur_per_ctr, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
              fname   => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_DETAIL',
              element => 'RUN_MODE',
              value   => X_RUN_MODE, p_log_level_rec => p_log_level_rec);
       end if;
       fa_srvr_msg.add_sql_error(
          calling_fn => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_DETAIL', p_log_level_rec => p_log_level_rec);
       fa_srvr_msg.add_message(
          calling_fn => 'FA_QUERY_BALANCES_PKG.QUERY_DEPRN_DETAIL',
          name       => h_mesg_name, p_log_level_rec => p_log_level_rec);
       fa_standard_pkg.raise_error(
          CALLED_FN  => 'QUERY_DEPRN_DETAIL',
          CALLING_FN => X_CALLING_FN,
          NAME       => h_mesg_name, p_log_level_rec => p_log_level_rec);


END QUERY_DEPRN_DETAIL;

-----------------------------------------------------------------------------------


-- Get info for any adjustments that occurred after the creation of
-- the deprn row from which we selected financial info.

PROCEDURE GET_ADJUSTMENTS_INFO (
                 X_ADJ_ROW              IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_FOUND_PER_CTR        IN OUT NOCOPY NUMBER,
                 X_RUN_MODE                    VARCHAR2,
                 X_TRANSACTION_HEADER_ID       NUMBER,
                 X_SUCCESS                 OUT NOCOPY BOOLEAN,
                 X_CALLING_FN                  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

  h_found_per_ctr         number;
  h_num_adjs              number;
  h_mode_str              varchar2(8);
  h_asset_clearing_adjs   number;
  h_cip_clearing_adjs     number;
  h_book_class            varchar2(15);

  h_mesg_name             varchar2(30);

BEGIN


  X_success := FALSE;

  -- If period counter not set, then set to current period.

  if (nvl(X_ADJ_ROW.period_ctr,0) = 0) then

     h_mesg_name := 'FA_EXP_GET_CUR_PERIOD_INFO';

     X_ADJ_ROW.period_ctr := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
  end if;

  -- If running in ADJUSTED mode (querying from TAX book) then we're
  -- also interested in tax book's deprn adjustments.  If in
  -- STANDARD or DEPRN mode, then we want to disregard these.

  if (X_RUN_MODE = 'ADJUSTED') then
     h_mode_str := 'ADJUSTED';
  else
     h_mode_str := 'STANDARD';
  end if;

  -- Get book class
  h_book_class := fa_cache_pkg.fazcbc_record.book_class;

  -- Look for adjustments... sum the amounts under each
  -- adjustment type.
  -- bonus Implemented.
  h_mesg_name := 'FA_AMT_SEL_AJ';

  if (X_adj_row.asset_type = 'GROUP' and
      X_adj_row.member_rollup_flag = 'Y') then
     if (x_adj_row.mrc_sob_type_code  = 'R') then
        SELECT NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT),
                              'CIP COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
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
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT),
                           'LINK IMPAIR EXP',
                            DECODE(ADJ.DEBIT_CREDIT_FLAG,  /*For Bug 7460979, we need to Consider LINK IMP EXP while calculating YTD_IMPAIRMENT*/
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'DEPRN ADJUST',
                              DECODE(h_book_class,'TAX',
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
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'ASSET CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'CIP CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'CAPITAL ADJ',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'GENERAL FUND',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'CR', ADJ.ADJUSTMENT_AMOUNT,
                                     'DR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               COUNT(*)
          INTO X_ADJ_ROW.cost,
               X_ADJ_ROW.deprn_rsv,
               X_ADJ_ROW.deprn_exp,
               X_ADJ_ROW.bonus_deprn_rsv,
               X_ADJ_ROW.bonus_deprn_amount,
               X_ADJ_ROW.impairment_rsv,
               X_ADJ_ROW.impairment_amount,
               X_ADJ_ROW.deprn_adjust_exp,
               X_ADJ_ROW.reval_deprn_exp,
               X_ADJ_ROW.reval_amo,
               X_ADJ_ROW.reval_rsv,
               h_asset_clearing_adjs,
               h_cip_clearing_adjs,
               X_ADJ_ROW.capital_adjustment, --Bug 6666666
               X_ADJ_ROW.general_fund,       --Bug 6666666
               h_num_adjs
          FROM FA_MC_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID in (select bk.asset_id
                                from   fa_mc_books bk
                                where  bk.book_type_code = x_adj_row.book
                                and    bk.transaction_header_id_out is null
                                and    bk.group_asset_id = x_adj_row.asset_id
                                and    bk.set_of_books_id = x_adj_row.set_of_books_id) AND
               ADJ.BOOK_TYPE_CODE =  X_ADJ_ROW.book AND
               ADJ.PERIOD_COUNTER_CREATED > X_found_per_ctr AND
               DECODE(h_book_class,
                      'TAX', ADJ.PERIOD_COUNTER_ADJUSTED,
                      ADJ.PERIOD_COUNTER_CREATED)
                   <= X_ADJ_ROW.period_ctr AND
               DECODE(X_transaction_header_id,-1,transaction_header_id,
                      X_transaction_header_id) >= transaction_header_id AND
               ADJ.DISTRIBUTION_ID =
                   DECODE(X_ADJ_ROW.dist_id,
                          0, ADJ.DISTRIBUTION_ID,
                          X_ADJ_ROW.dist_id) AND
               ADJ.SET_OF_BOOKS_ID = X_ADJ_ROW.set_of_books_id;


     else
        SELECT NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT),
                              'CIP COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
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
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT),
                           'LINK IMPAIR EXP',
                            DECODE(ADJ.DEBIT_CREDIT_FLAG,  /*For Bug 7460979, we need to Consider LINK IMP EXP while calculating YTD_IMPAIRMENT*/
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'DEPRN ADJUST',
                              DECODE(h_book_class,'TAX',
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
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'ASSET CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'CIP CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'CAPITAL ADJ',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'GENERAL FUND',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'CR', ADJ.ADJUSTMENT_AMOUNT,
                                     'DR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               COUNT(*)
          INTO X_ADJ_ROW.cost,
               X_ADJ_ROW.deprn_rsv,
               X_ADJ_ROW.deprn_exp,
               X_ADJ_ROW.bonus_deprn_rsv,
               X_ADJ_ROW.bonus_deprn_amount,
               X_ADJ_ROW.impairment_rsv,
               X_ADJ_ROW.impairment_amount,
               X_ADJ_ROW.deprn_adjust_exp,
               X_ADJ_ROW.reval_deprn_exp,
               X_ADJ_ROW.reval_amo,
               X_ADJ_ROW.reval_rsv,
               h_asset_clearing_adjs,
               h_cip_clearing_adjs,
               X_ADJ_ROW.capital_adjustment, --Bug 6666666
               X_ADJ_ROW.general_fund,       --Bug 6666666
               h_num_adjs
          FROM FA_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID in (select bk.asset_id
                                from   fa_books bk
                                where bk.book_type_code = x_adj_row.book
                                and   bk.transaction_header_id_out is null
                                and    bk.group_asset_id = x_adj_row.asset_id) AND
               ADJ.BOOK_TYPE_CODE =  X_ADJ_ROW.book AND
               ADJ.PERIOD_COUNTER_CREATED > X_found_per_ctr AND
               DECODE(h_book_class,
                      'TAX', ADJ.PERIOD_COUNTER_ADJUSTED,
                      ADJ.PERIOD_COUNTER_CREATED)
                   <= X_ADJ_ROW.period_ctr AND
               DECODE(X_transaction_header_id,-1,transaction_header_id,
                      X_transaction_header_id) >= transaction_header_id AND
               ADJ.DISTRIBUTION_ID =
                   DECODE(X_ADJ_ROW.dist_id,
                          0, ADJ.DISTRIBUTION_ID,
                          X_ADJ_ROW.dist_id);

     end if;


  else -- non sumup assets
     if (x_adj_row.mrc_sob_type_code  = 'R') then
        SELECT NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT),
                              'CIP COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
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
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT),
                           'LINK IMPAIR EXP',
                            DECODE(ADJ.DEBIT_CREDIT_FLAG,  /*For Bug 7460979, we need to Consider LINK IMP EXP while calculating YTD_IMPAIRMENT*/
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'DEPRN ADJUST',
                              DECODE(h_book_class,'TAX',
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
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'ASSET CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'CIP CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'CAPITAL ADJ',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'GENERAL FUND',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'CR', ADJ.ADJUSTMENT_AMOUNT,
                                     'DR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               COUNT(*)
          INTO X_ADJ_ROW.cost,
               X_ADJ_ROW.deprn_rsv,
               X_ADJ_ROW.deprn_exp,
               X_ADJ_ROW.bonus_deprn_rsv,
               X_ADJ_ROW.bonus_deprn_amount,
               X_ADJ_ROW.impairment_rsv,
               X_ADJ_ROW.impairment_amount,
               X_ADJ_ROW.deprn_adjust_exp,
               X_ADJ_ROW.reval_deprn_exp,
               X_ADJ_ROW.reval_amo,
               X_ADJ_ROW.reval_rsv,
               h_asset_clearing_adjs,
               h_cip_clearing_adjs,
               X_ADJ_ROW.capital_adjustment, --Bug 6666666
               X_ADJ_ROW.general_fund,       --Bug 6666666
               h_num_adjs
          FROM FA_MC_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID = X_ADJ_ROW.asset_id AND
               ADJ.BOOK_TYPE_CODE =  X_ADJ_ROW.book AND
               ADJ.PERIOD_COUNTER_CREATED > X_found_per_ctr AND
               DECODE(h_book_class,
                      'TAX', ADJ.PERIOD_COUNTER_ADJUSTED,
                      ADJ.PERIOD_COUNTER_CREATED)
                   <= X_ADJ_ROW.period_ctr AND
               DECODE(X_transaction_header_id,-1,transaction_header_id,
                      X_transaction_header_id) >= transaction_header_id AND
               ADJ.DISTRIBUTION_ID =
                   DECODE(X_ADJ_ROW.dist_id,
                          0, ADJ.DISTRIBUTION_ID,
                          X_ADJ_ROW.dist_id) AND
               ADJ.SET_OF_BOOKS_ID = X_ADJ_ROW.set_of_books_id;


     else
        SELECT NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT),
                              'CIP COST',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR',-1*ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
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
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT),
                           'LINK IMPAIR EXP',
                            DECODE(ADJ.DEBIT_CREDIT_FLAG,  /*For Bug 7460979, we need to Consider LINK IMP EXP while calculating YTD_IMPAIRMENT*/
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                              'DEPRN ADJUST',
                              DECODE(h_book_class,'TAX',
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
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'ASSET CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,
                          'CIP CLEARING',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'CAPITAL ADJ',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'DR', ADJ.ADJUSTMENT_AMOUNT,
                                     'CR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               NVL(SUM(DECODE(ADJ.ADJUSTMENT_TYPE,             -- Bug 6666666
                          'GENERAL FUND',
                              DECODE(ADJ.DEBIT_CREDIT_FLAG,
                                     'CR', ADJ.ADJUSTMENT_AMOUNT,
                                     'DR', -1 * ADJ.ADJUSTMENT_AMOUNT))),
                   0),
               COUNT(*)
          INTO X_ADJ_ROW.cost,
               X_ADJ_ROW.deprn_rsv,
               X_ADJ_ROW.deprn_exp,
               X_ADJ_ROW.bonus_deprn_rsv,
               X_ADJ_ROW.bonus_deprn_amount,
               X_ADJ_ROW.impairment_rsv,
               X_ADJ_ROW.impairment_amount,
               X_ADJ_ROW.deprn_adjust_exp,
               X_ADJ_ROW.reval_deprn_exp,
               X_ADJ_ROW.reval_amo,
               X_ADJ_ROW.reval_rsv,
               h_asset_clearing_adjs,
               h_cip_clearing_adjs,
               X_ADJ_ROW.capital_adjustment, --Bug 6666666
               X_ADJ_ROW.general_fund,       --Bug 6666666
               h_num_adjs
          FROM FA_ADJUSTMENTS ADJ
         WHERE ADJ.ASSET_ID =  X_ADJ_ROW.asset_id AND
               ADJ.BOOK_TYPE_CODE =  X_ADJ_ROW.book AND
               ADJ.PERIOD_COUNTER_CREATED > X_found_per_ctr AND
               DECODE(h_book_class,
                      'TAX', ADJ.PERIOD_COUNTER_ADJUSTED,
                      ADJ.PERIOD_COUNTER_CREATED)
                   <= X_ADJ_ROW.period_ctr AND
               DECODE(X_transaction_header_id,-1,transaction_header_id,
                      X_transaction_header_id) >= transaction_header_id AND
               ADJ.DISTRIBUTION_ID =
                   DECODE(X_ADJ_ROW.dist_id,
                          0, ADJ.DISTRIBUTION_ID,
                          X_ADJ_ROW.dist_id);

     end if;
  end if;



  -- Interested only in total cost-to-clear, regardless of whether it's
  -- CIP or capitalized.

  X_ADJ_ROW.add_cost_to_clear := h_asset_clearing_adjs + h_cip_clearing_adjs;

  -- Indicate if any adjustments were encountered.

  if (h_num_adjs <> 0) then
     X_ADJ_ROW.adjusted_flag := TRUE;
  else
     X_ADJ_ROW.adjusted_flag := FALSE;
  end if;

  X_success := TRUE;

EXCEPTION
  when others then
       if (SQL%NOTFOUND) then
          X_ADJ_ROW.cost := 0;
          X_ADJ_ROW.deprn_rsv := 0;
          X_ADJ_ROW.deprn_adjust_exp := 0;
          X_ADJ_ROW.reval_deprn_exp := 0;
          X_ADJ_ROW.bonus_deprn_rsv := 0;
          X_ADJ_ROW.bonus_deprn_amount := 0;
          X_ADJ_ROW.reval_amo := 0;
          X_ADJ_ROW.reval_rsv := 0;
          h_num_adjs := 0;
          X_success := TRUE;
       else
          if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD (
                 fname   => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
                 element => 'FOUND_PER_CTR',
                 value   => X_FOUND_PER_CTR, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (
                 fname   => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
                 element => 'RUN_MODE',
                 value   => h_mode_str, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (
                 fname   => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
                 element => 'ASSET_ID',
                 value   => X_ADJ_ROW.ASSET_ID, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (
                 fname   => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
                 element => 'BOOK',
                 value   => X_ADJ_ROW.BOOK, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (
                 fname   => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
                 element => 'DIST_ID',
                 value   => X_ADJ_ROW.DIST_ID, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (
                 fname   => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
                 element => 'TRANSACTION_HEADER_ID',
                 value   => X_TRANSACTION_HEADER_ID, p_log_level_rec => p_log_level_rec);
          end if;
          fa_srvr_msg.add_sql_error(
             calling_fn => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO', p_log_level_rec => p_log_level_rec);
          fa_srvr_msg.add_message(
             calling_fn => 'FA_QUERY_BALANCES_PKG.GET_ADJUSTMENTS_INFO',
             name       => h_mesg_name, p_log_level_rec => p_log_level_rec);
          fa_standard_pkg.raise_error(
             CALLED_FN  => 'GET_ADJUSTMENTS_INFO',
             CALLING_FN => X_CALLING_FN,
             NAME       => 'FA_QADD_DET_ADJS', p_log_level_rec => p_log_level_rec);
       end if;

END GET_ADJUSTMENTS_INFO;

END FA_QUERY_BALANCES_PKG;

/
